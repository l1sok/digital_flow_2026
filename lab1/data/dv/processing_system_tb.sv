interface processing_system_if(input logic clk, input logic rst_n);
    logic valid_in;
    logic [15:0] data_a, data_b;
    logic [ 1:0] operation;
    logic clear;
    logic [31:0] range_limit;

    logic result_valid;
    logic [31:0] result;
    logic [ 9:0] count;
    logic [31:0] sum, min, max;
    logic [31:0] range;
    logic range_exceeded;
endinterface

package processing_system_tb_pkg;

    typedef enum logic [1:0] {
        ADD    = 2'b00,
        SUB    = 2'b01,
        MUL    = 2'b10,
        XOR_OP = 2'b11
    } operation_t;

    localparam logic [9:0] COUNT_LIMIT = 16'h03ff;

    typedef struct packed {
        logic [ 9:0] count;
        logic [31:0] sum;
        logic [31:0] min;
        logic [31:0] max;
    } statistics_t;

    typedef struct packed {
        logic clear;
        logic [31:0] result;
        statistics_t statistics;
        logic [31:0] range;
        logic range_exceeded;
        logic [31:0] range_limit;
    } output_t;

    class transaction;
        logic valid_in;
        logic [15:0] a, b;
        logic [ 1:0] op;
        logic clear;
        logic [31:0] range_limit;

        function new(
            logic [15:0] a, b,
            logic [1:0] op,
            logic valid_in = 1,
            logic clear = 0,
            logic [31:0] range_limit = 0
        );
            this.a           = a;
            this.b           = b;
            this.op          = op;
            this.valid_in    = valid_in;
            this.clear       = clear;
            this.range_limit = range_limit;
        endfunction

        function transaction copy();
            transaction t = new(a, b, op, valid_in, clear, range_limit);
            return t;
        endfunction
    endclass

    class driver;
        virtual processing_system_if vif;
        mailbox #(transaction) requests;

        function new(
            virtual processing_system_if vif,
            mailbox #(transaction) requests
        );
            this.vif      = vif;
            this.requests = requests;
        endfunction

        task run();
            transaction t;

            forever begin
                @(posedge vif.clk); // TODO: negedge

                vif.valid_in <= 0;
                vif.clear    <= 0;

                if (vif.rst_n === 1'b1 && requests.try_get(t)) begin
                    vif.data_a      <= t.a;
                    vif.data_b      <= t.b;
                    vif.operation   <= t.op;
                    vif.valid_in    <= t.valid_in;
                    vif.clear       <= t.clear;
                    vif.range_limit <= t.range_limit;
                end
            end
        endtask
    endclass

    class input_monitor;
        virtual processing_system_if vif;
        mailbox #(transaction) inputs;

        function new(
            virtual processing_system_if vif,
            mailbox #(transaction) inputs
        );
            this.vif    = vif;
            this.inputs = inputs;
        endfunction

        task run();
            transaction t;

            forever begin
                @(posedge vif.clk);

                if (vif.rst_n === 1'b1 && vif.valid_in === 1'b1) begin
                    t = new(vif.data_a, vif.data_b, vif.operation);
                    inputs.put(t);
                end
            end
        endtask
    endclass

    class output_monitor;
        virtual processing_system_if vif;
        mailbox #(output_t) outputs;

        function new(
            virtual processing_system_if vif,
            mailbox #(output_t) outputs
        );
            this.vif     = vif;
            this.outputs = outputs;
        endfunction

        task run();
            output_t actual;

            forever begin
                @(posedge vif.clk);

                if (vif.rst_n === 1'b1 && vif.result_valid === 1'b1) begin
                    actual.result = vif.result;
                    actual.clear  = vif.clear;

                    @(negedge vif.clk);
                    if (vif.rst_n === 1'b1) begin
                        actual.statistics.count = vif.count;
                        actual.statistics.sum   = vif.sum;
                        actual.statistics.min   = vif.min;
                        actual.statistics.max   = vif.max;
                        actual.range            = vif.range;
                        actual.range_exceeded   = vif.range_exceeded;
                        actual.range_limit      = vif.range_limit;
                        outputs.put(actual);
                    end
                end
            end
        endtask
    endclass

    class scoreboard;
        virtual processing_system_if vif;
        mailbox #(transaction) inputs;
        mailbox #(output_t) outputs;

        statistics_t model = '0;

        int errors  = 0;
        int checked = 0;

        function new(
            virtual processing_system_if vif,
            mailbox #(transaction) inputs,
            mailbox #(output_t) outputs
        );
            this.vif     = vif;
            this.inputs  = inputs;
            this.outputs = outputs;
        endfunction

        function logic [31:0] predict_result(transaction t);
            logic [31:0] a32, b32;

            a32 = {16'b0, t.a};
            b32 = {16'b0, t.b};

            case (t.op)
                ADD:     return a32 + b32;
                SUB:     return a32 - b32;
                MUL:     return a32 * b32;
                XOR_OP:  return a32 ^ b32;
                default: return 'x;
            endcase
        endfunction

        function void flush_on_reset();
            transaction t;
            output_t actual;

            model = '0;
            while (inputs.try_get(t));
            while (outputs.try_get(actual));
        endfunction

        task watch_control();
            forever begin
                @(posedge vif.clk or negedge vif.rst_n);

                if (vif.rst_n !== 1'b1) begin
                    flush_on_reset();
                    model = '0;
                end
                else if (vif.clear === 1'b1)
                    model = '0;
            end
        endtask

        function void predict(logic [31:0] data);
            if (data > (32'hffff_ffff - model.sum))
                model.sum = 32'hffff_ffff;
            else
                model.sum = model.sum + data;

            if (model.count == 0) begin
                model.min = data;
                model.max = data;
            end
            else begin
                if (data < model.min)
                    model.min = data;
                if (data > model.max)
                    model.max = data;
            end

            if (model.count != COUNT_LIMIT)
                model.count = model.count + 16'd1;
        endfunction

        function void check_range(
            logic [31:0] actual_range,
            logic actual_exceeded,
            logic [31:0] limit
        );
            logic [31:0] expected_range;
            logic expected_exceeded;

            expected_range = (model.count == 0) ? 32'd0 : model.max - model.min;
            expected_exceeded = (model.count != 0) && (expected_range > limit);

            if (actual_range !== expected_range) begin
                errors++;
                $error("range mismatch: actual=%0h expected=%0h",
                       actual_range, expected_range);
            end
            if (actual_exceeded !== expected_exceeded) begin
                errors++;
                $error("range_exceeded mismatch: actual=%0b expected=%0b limit=%0h",
                       actual_exceeded, expected_exceeded, limit);
            end
        endfunction

        task run();
            transaction t;
            output_t actual;
            logic [31:0] expected_result;

            forever begin
                outputs.get(actual);
                if (!inputs.try_get(t))
                    $fatal(1, "Unexpected result without an input operation");

                expected_result = predict_result(t);
                if (actual.result !== expected_result) begin
                    errors++;
                    $error("Result mismatch: real=%0h expected=%0h",
                           actual.result, expected_result);
                end

                if (actual.clear !== 1'b1)
                    predict(expected_result);

                if (actual.statistics.count !== model.count) begin
                    errors++;
                    $error("count mismatch: actual=%0d expected=%0d",
                           actual.statistics.count, model.count);
                end
                if (actual.statistics.sum !== model.sum) begin
                    errors++;
                    $error("sum mismatch: actual=%0h expected=%0h",
                           actual.statistics.sum, model.sum);
                end
                if (actual.statistics.min !== model.min) begin
                    errors++;
                    $error("min mismatch: actual=%0h expected=%0h",
                           actual.statistics.min, model.min);
                end
                if (actual.statistics.max !== model.max) begin
                    errors++;
                    $error("max mismatch: actual=%0h expected=%0h",
                           actual.statistics.max, model.max);
                end

                check_range(actual.range, actual.range_exceeded, actual.range_limit);
                checked++;

                if (errors >= 20)
                    $fatal(1, "Max errors count!");
            end
        endtask

        function void report();
            if (errors != 0)
                $fatal(1, "FAIL: errors=%0d checked=%0d", errors, checked);
            if (checked == 0)
                $fatal(1, "FAIL: no results checked");
            if (inputs.num() != 0 || outputs.num() != 0)
                $fatal(1, "FAIL: unfinished checks");

            $display("PASS: checked=%0d", checked);
        endfunction
    endclass

    class environment;
        virtual processing_system_if vif;
        mailbox #(transaction) requests;
        mailbox #(transaction) inputs;
        mailbox #(output_t) outputs;

        driver         drv;
        input_monitor  in_mon;
        output_monitor out_mon;
        scoreboard     scb;

        function new(virtual processing_system_if vif);
            this.vif = vif;
            requests = new();
            inputs   = new();
            outputs  = new();

            drv     = new(vif, requests);
            in_mon  = new(vif, inputs);
            out_mon = new(vif, outputs);
            scb     = new(vif, inputs, outputs);
        endfunction

        task send_trans(transaction t);
            requests.put(t.copy());
        endtask

        function void flush_on_reset();
            transaction t;
            while (requests.try_get(t));
        endfunction

        task wait_idle();
            while (requests.num() != 0) @(negedge vif.clk);
            repeat (4) @(negedge vif.clk);
            #1;
        endtask

        task run();
            fork
                drv.run();
                in_mon.run();
                out_mon.run();
                scb.run();
                scb.watch_control();
            join_none
        endtask
    endclass

endpackage

module tb;
    import processing_system_tb_pkg::*;

    parameter time CLK_PERIOD = 10ns;

    logic clk = 0;
    logic rst_n = 0;

    processing_system_if bus(clk, rst_n);
    environment env;

    initial begin
        forever #(CLK_PERIOD / 2) clk <= ~clk;
    end

    processing_system dut (
        .clk            (bus.clk           ),
        .rst_n          (bus.rst_n         ),
        .valid_in       (bus.valid_in      ),
        .data_a         (bus.data_a        ),
        .data_b         (bus.data_b        ),
        .operation      (bus.operation     ),
        .clear          (bus.clear         ),
        .range_limit    (bus.range_limit   ),
        .result_valid   (bus.result_valid  ),
        .result         (bus.result        ),
        .count          (bus.count         ),
        .sum            (bus.sum           ),
        .min            (bus.min           ),
        .max            (bus.max           ),
        .range          (bus.range         ),
        .range_exceeded (bus.range_exceeded)
    );

    task automatic do_reset();
        rst_n = 0;
        env.flush_on_reset();
        repeat (20) @(negedge clk);
        rst_n = 1;
    endtask

    task automatic send(
        logic clear,
        logic valid_in,
        logic [15:0] a, b,
        logic [1:0] op,
        logic [31:0] limit = 0
    );
        transaction t;
        t = new(a, b, op, valid_in, clear, limit);
        env.send_trans(t);
    endtask

    task automatic set_limit(logic [31:0] limit);
        bus.range_limit = limit;
    endtask

    initial begin
        logic [15:0] boundary_values [6] = '{
            16'h0000, 16'h0001, 16'h7fff,
            16'h8000, 16'hfffe, 16'hffff
        };

        env = new(bus);
        env.run();
        do_reset();

        send(0, 0, 16'hffff, 16'hffff, MUL);
        send(0, 1, 10, 0, ADD);
        send(0, 1, 5, 0, ADD);
        send(0, 1, 20, 0, ADD);
        env.wait_idle();

        set_limit(16);
        set_limit(15);
        set_limit(14);
        set_limit(0);
        set_limit(32'hffff_ffff);

        send(0, 0, 16'hffff, 1, SUB);
        send(0, 0, 0, 0, MUL);
        send(0, 0, 16'hffff, 16'hffff, ADD);

        send(0, 1, 0, 1, SUB);
        send(1, 1, 42, 0, ADD);
        send(0, 0, 123, 0, ADD);
        env.wait_idle();

        send(1, 0, 0, 0, ADD);
        send(0, 0, 16'hffff, 16'hffff, MUL);
        env.wait_idle();
        set_limit(0);
        set_limit(32'hffff_ffff);
        send(0, 1, 42, 0, ADD);
        env.wait_idle();
        set_limit(0);

        foreach (boundary_values[i]) begin
            foreach (boundary_values[j]) begin
                for (int op = 0; op < 4; op++)
                    send(0, 1, boundary_values[i], boundary_values[j],
                         operation_t'(op));
            end
        end

        for (int i = 0; i < 100; i++)
            send(0, 1, $urandom_range(16'hffff, 0),
                 $urandom_range(16'hffff, 0), operation_t'(i % 4));

        for (int i = 0; i < 16; i++)
            send(0, 1, 16'hffff - i, i + 1, operation_t'(i % 4));

        repeat (100)
            send(0, 1, $urandom_range(16'hffff, 0),
                 $urandom_range(16'hffff, 0),
                 operation_t'($urandom_range(3, 0)));
        env.wait_idle();

        send(1, 0, 0, 0, ADD);
        send(0, 1, 0, 2, SUB);
        send(0, 1, 1, 0, ADD);
        send(0, 1, 100, 0, ADD);
        send(0, 0, 0, 0, ADD);

        send(1, 1, 0, 1, SUB);
        send(0, 1, 0, 0, ADD);
        send(0, 1, 7, 0, ADD);

        send(1, 0, 0, 0, ADD);
        repeat (2**10)
            send(0, 1, 1, 0, ADD);
        send(0, 1, 0, 0, ADD);
        send(0, 1, 2, 0, ADD);
        send(0, 0, 0, 1, SUB);

        send(1, 1, 7, 0, ADD);
        send(0, 0, 100, 0, ADD);
        env.wait_idle();

        repeat (16) send(0, 1, 16'hffff, 16'hffff, MUL);
        repeat (4) @(negedge clk);
        do_reset();
        env.wait_idle();
        set_limit(0);
        send(0, 1, 0, 0, ADD);
        send(0, 1, 1, 0, ADD);

        repeat (1000)
            send($urandom_range(15, 0) == 0,
                 $urandom_range(1, 0),
                 $urandom_range(16'hffff, 0),
                 $urandom_range(16'hffff, 0),
                 operation_t'($urandom_range(3, 0)), $urandom());

        env.wait_idle();
        env.scb.report();
        $finish;
    end

    initial begin
        #1ms;
        $fatal(1, "Test timeout");
    end

    property p_valid;
        @(posedge clk) disable iff (!rst_n)
            ($past(rst_n) === 1'b1) |->
                (bus.result_valid === $past(bus.valid_in));
    endproperty

    assert_valid: assert property (p_valid)
        else $fatal(1, "Неверный result_valid");

endmodule
