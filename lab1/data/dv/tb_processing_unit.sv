interface pu_if(input logic clk, input logic reset);
    logic valid_in;
    logic valid_out;

    logic [15:0] data_a, data_b;
    logic [ 1:0] operation;
    logic [31:0] result;
endinterface

package pu_tb_pkg;

    typedef enum logic [1:0] {
        ADD    = 2'b00,
        SUB    = 2'b01,
        MUL    = 2'b10,
        XOR_OP = 2'b11
    } operation_t;

    class transaction;
        logic [15:0] a, b;
        logic [ 1:0] op;

        function new(logic [15:0] a, b, logic [1:0] op);
            this.a  = a;
            this.b  = b;
            this.op = op;
        endfunction

        function transaction copy();
            transaction t = new(a, b, op);
            return t;
        endfunction
    endclass

    class driver;
        virtual pu_if vif;
        mailbox #(transaction) requests;

        function new(
            virtual pu_if vif,
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

                if (vif.reset === 1'b1 && requests.try_get(t)) begin
                    vif.data_a    <= t.a;
                    vif.data_b    <= t.b;
                    vif.operation <= t.op;
                    vif.valid_in  <= 1'b1;
                end
            end
        endtask
    endclass

    class input_monitor;
        virtual pu_if vif;
        mailbox #(transaction) inputs;

        function new(
            virtual pu_if vif,
            mailbox #(transaction) inputs
        );
            this.vif    = vif;
            this.inputs = inputs;
        endfunction

        task run();
            transaction t;

            forever begin
                @(posedge vif.clk);

                if (vif.reset === 1'b1 && vif.valid_in === 1'b1) begin
                    t = new(vif.data_a, vif.data_b, vif.operation);
                    inputs.put(t);
                end
            end
        endtask
    endclass

    class output_monitor;
        virtual pu_if vif;
        mailbox #(logic [31:0]) outputs;

        function new(
            virtual pu_if vif,
            mailbox #(logic [31:0]) outputs
        );
            this.vif     = vif;
            this.outputs = outputs;
        endfunction

        task run();
            forever begin
                @(posedge vif.clk);

                if (vif.reset === 1'b1 && vif.valid_out === 1'b1)
                    outputs.put(vif.result);
            end
        endtask
    endclass

    class scoreboard;
        mailbox #(transaction)  inputs;
        mailbox #(logic [31:0]) outputs;

        int errors  = 0;
        int checked = 0;

        function new(
            mailbox #(transaction)  inputs,
            mailbox #(logic [31:0]) outputs
        );
            this.inputs  = inputs;
            this.outputs = outputs;
        endfunction

        function logic [31:0] predict(transaction t);
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

        task run();
            transaction t;
            logic [31:0] actual, exp;

            forever begin
                outputs.get(actual);
                inputs .get(t);

                exp = predict(t);

                if (actual !== exp) begin
                    errors++;
                    $error("Result mismatch: real=%0h expected=%0h", actual, exp);
                end

                checked++;
            end
        endtask

        function void flush_on_reset();
            transaction t;
            logic [31:0] actual;

            while (inputs.try_get(t));

            while (outputs.try_get(actual));
        endfunction

        function void report();
            if (errors != 0)
                $fatal(1, "FAIL: errors=%0d checked=%0d", errors, checked);

            $display("PASS: checked=%0d", checked);
        endfunction
    endclass

    class environment;
        virtual pu_if vif;
        mailbox #(transaction) requests;
        mailbox #(transaction) inputs;
        mailbox #(logic [31:0]) outputs;

        driver         drv;
        input_monitor  in_mon;
        output_monitor out_mon;
        scoreboard     scb;

        function new(virtual pu_if vif);
            this.vif = vif;
            requests = new();
            inputs   = new();
            outputs  = new();

            drv     = new(vif, requests);
            in_mon  = new(vif, inputs);
            out_mon = new(vif, outputs);
            scb     = new(inputs, outputs);
        endfunction

        task send_trans(transaction t);
            requests.put(t.copy());
        endtask

        function void flush_on_reset();
            transaction t;

            while (requests.try_get(t));

            scb.flush_on_reset();
        endfunction

        task run();
            fork
                drv.run();
                in_mon.run();
                out_mon.run();
                scb.run();
            join_none
        endtask
    endclass

endpackage

module tb;
    import pu_tb_pkg::*;

    parameter CLK_PERIOD = 10;

    logic clk;
    logic reset;

    pu_if bus(clk, reset);
    environment env;

    // Drive clk.
    initial begin
        clk <= 0;
        forever begin
            #(CLK_PERIOD / 2) clk <= ~clk;
        end
    end

    // Drive reset.
    initial begin
        reset = 0;
        repeat (20) @(posedge clk);
        reset = 1;
    end

    processing_unit dut (
        .clk       (bus.clk      ),
        .rst_n     (bus.reset    ),
        .valid_in  (bus.valid_in ),
        .data_a    (bus.data_a   ),
        .data_b    (bus.data_b   ),
        .operation (bus.operation),
        .valid_out (bus.valid_out),
        .result    (bus.result   )
    );

    initial begin
        transaction t;
        logic [15:0] boundary_values [6] = '{
            16'h0000, 16'h0001, 16'h7fff,
            16'h8000, 16'hfffe, 16'hffff
        };

        env = new(bus);
        env.run();

        foreach (boundary_values[i]) begin
            foreach (boundary_values[j]) begin
                for (int op = 0; op < 4; op++) begin
                    t = new(boundary_values[i], boundary_values[j], operation_t'(op));
                    env.send_trans(t);
                end
            end
        end

        for (int i = 0; i < 100; i++) begin
            t = new(
                $urandom_range(16'hffff, 0),
                $urandom_range(16'hffff, 0),
                operation_t'(i % 4)
            );
            env.send_trans(t);
        end

        for (int i = 0; i < 16; i++) begin
            t = new(16'hffff - i, i + 1, operation_t'(i % 4));
            env.send_trans(t);
        end

        repeat (100) begin
            t = new(
                $urandom_range(16'hffff, 0),
                $urandom_range(16'hffff, 0),
                operation_t'($urandom_range(3, 0))
            );
            env.send_trans(t);
        end

        while (env.requests.num() != 0) @(negedge clk);
        repeat (3) @(negedge clk);

        env.scb.report();
        $finish;
    end

    initial begin
        #10us;
        $fatal(1, "Test timeout");
    end

    property p_valid;
        @(posedge clk) disable iff (!reset)
            (bus.valid_out === $past(bus.valid_in));
    endproperty

    assert_valid: assert property (p_valid)
        else $fatal(1, "Неверный valid_out");

endmodule
