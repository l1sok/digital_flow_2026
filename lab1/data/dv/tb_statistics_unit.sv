interface statistics_if(input logic clk, input logic rst_n);
    logic clear    = 0;
    logic valid_in = 0;
    logic [31:0] data_in = 0;
    logic [15:0] count;
    logic [31:0] sum;
    logic [31:0] min;
    logic [31:0] max;
endinterface

package statistics_tb_pkg;

    typedef struct packed {
        logic [15:0] count;
        logic [31:0] sum;
        logic [31:0] min;
        logic [31:0] max;
    } statistics_t;

    class transaction;
        logic clear;
        logic valid_in;
        logic [31:0] data_in;

        function new(
            logic clear,
            logic valid_in,
            logic [31:0] data_in
        );
            this.clear    = clear;
            this.valid_in = valid_in;
            this.data_in  = data_in;
        endfunction

        function transaction copy();
            transaction t = new(clear, valid_in, data_in);
            return t;
        endfunction
    endclass

    class driver;
        virtual statistics_if vif;
        mailbox #(transaction) requests;

        function new(
            virtual statistics_if vif,
            mailbox #(transaction) requests
        );
            this.vif      = vif;
            this.requests = requests;
        endfunction

        task run();
            transaction t;

            forever begin
                @(posedge vif.clk); // TODO negedge
                if (vif.rst_n !== 1'b1) begin
                    vif.clear    <= 1;
                    vif.valid_in <= 0;
                end
                else if (requests.try_get(t)) begin
                    vif.clear    <= t.clear;
                    vif.valid_in <= t.valid_in;
                    vif.data_in  <= t.data_in;
                end
                else reset_data();
            end
        endtask

        task reset_data();
            vif.clear    <= 0;
            vif.valid_in <= 0;
        endtask

    endclass

    class input_monitor;
        virtual statistics_if vif;
        mailbox #(transaction) inputs;

        function new(
            virtual statistics_if vif,
            mailbox #(transaction) inputs
        );
            this.vif    = vif;
            this.inputs = inputs;
        endfunction

        task run();
            transaction t;

            forever begin
                @(posedge vif.clk);

                if( vif.rst_n && (vif.clear || vif.valid_in) ) begin
                    t = new(vif.clear, vif.valid_in, vif.data_in);

                    inputs.put(t);
                end
            end
        endtask

    endclass

    class scoreboard;
        mailbox #(transaction) inputs;

        virtual statistics_if vif;

        statistics_t model;

        int checked, errors;

        function new(
            virtual statistics_if vif,
            mailbox #(transaction)  inputs
        );
            this.vif    = vif;
            this.inputs = inputs;
        endfunction

    function void predict(transaction t);
        if (t.clear === 1'b1) begin
            model = '0;
        end
        else if (t.valid_in === 1'b1) begin
            if (t.data_in > (32'hffff_ffff - model.sum))
                model.sum = 32'hffff_ffff;
            else
                model.sum = model.sum + t.data_in;

            // Первое значение задаёт min и max.
            if (model.count == 0) begin
                model.min = t.data_in;
                model.max = t.data_in;
            end
            else begin
                if (t.data_in < model.min)
                    model.min = t.data_in;

                if (t.data_in > model.max)
                    model.max = t.data_in;
            end

            if (model.count != 10'h3ff)
                model.count = model.count + 16'd1;
        end
    endfunction

        task run();
            transaction t;

            forever begin
                inputs.get(t);

                predict(t);

                @(negedge vif.clk);

                if (vif.count !== model.count) begin
                    errors++;
                    $error("count mismatch: actual=%0d expected=%0d", vif.count, model.count);
                end

                if (vif.sum !== model.sum) begin
                    errors++;
                    $error("sum mismatch: actual=%0h expected=%0h", vif.sum, model.sum);
                end

                if (vif.min !== model.min) begin
                    errors++;
                    $error("min mismatch: actual=%0h expected=%0h", vif.min, model.min);
                end

                if (vif.max !== model.max) begin
                    errors++;
                    $error("max mismatch: actual=%0h expected=%0h", vif.max, model.max);
                end

                checked++;
            end
        endtask

        function void report();
            if (errors != 0)
                $fatal(1, "FAIL: errors=%0d", errors);

            $display("PASS: checked=%0d", checked);
        endfunction
    endclass

    class environment;
        mailbox #(transaction) requests;
        mailbox #(transaction) inputs;
        driver         drv;
        input_monitor  in_mon;
        scoreboard     scb;

        function new(virtual statistics_if vif);
            requests = new();
            inputs   = new();

            drv      = new(vif, requests);
            in_mon   = new(vif, inputs);
            scb      = new(vif, inputs);
        endfunction

        task send_trans(transaction t);
            requests.put(t.copy());
        endtask

        task run();
            fork
                drv.run();
                in_mon.run();
                scb.run();
            join_none
        endtask
    endclass

endpackage

module tb;
    import statistics_tb_pkg::*;

    parameter time CLK_PERIOD = 10ns;

    logic clk;
    logic rst_n;

    statistics_if bus(clk, rst_n);
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
        rst_n = 0;
        repeat (20) @(posedge clk);
        rst_n = 1;
    end

    statistics_unit dut (
        .clk      (bus.clk     ),
        .rst_n    (bus.rst_n   ),
        .clear    (bus.clear   ),
        .valid_in (bus.valid_in),
        .data_in  (bus.data_in ),
        .count    (bus.count   ),
        .sum      (bus.sum     ),
        .min      (bus.min     ),
        .max      (bus.max     )
    );

    task automatic do_reset();
        rst_n = 0;
        repeat (20) @(posedge clk);
        rst_n = 1;
    endtask

    task automatic send(
        logic clear,
        logic valid_in,
        logic [31:0] data_in
    );
        transaction t;
        t = new(clear, valid_in, data_in);
        env.send_trans(t);
    endtask

    initial begin
        env = new(bus);
        env.run();

        // Пустая последовательность и обычное накопление.
        send(0, 0, 32'hdead_beef);
        send(0, 1, 10);
        send(0, 1, 5);
        send(0, 1, 20);

        // valid_in = 0: статистика должна сохраняться.
        send(0, 0, 32'hffff_ffff);
        send(0, 0, 0);
        send(0, 0, 32'h0);
        send(0, 0, 0);

        // clear имеет приоритет над valid_in.
        send(1, 1, 32'hffff_ffff);
        send(0, 0, 123);
        send(0, 1, 42);

        // Сброс
        do_reset();
        send(0, 1, 0);
        send(0, 1, 1);

        // Точное достижение максимальной суммы и насыщение.
        send(1, 0, 0);
        send(0, 1, 32'hffff_fffe);
        send(0, 1, 1);
        send(0, 1, 100);
        send(0, 0, 0);

        // Очистка после насыщения суммы.
        send(1, 1, 32'hffff_ffff);
        send(0, 1, 32'hffff_ffff);
        send(0, 1, 0);
        send(0, 1, 7);

        // Насыщение count.
        send(1, 0, 0);
        repeat (2**10)
            send(0, 1, 1);

        // При насыщенном count сумма, min и max продолжают обновляться.
        send(0, 1, 0);
        send(0, 1, 2);
        send(0, 0, 32'hffff_ffff);

        // Очистка после насыщения count.
        send(1, 1, 100);
        send(0, 1, 7);

        // Случайные комбинации входов.
        repeat (1000) begin
            send(
                $urandom_range(15, 0) == 0,
                $urandom_range(1, 0),
                $urandom()
            );
        end

        while (env.requests.num() != 0) @(negedge clk);
        repeat (3) @(negedge clk);

        env.scb.report();
        $finish;
    end

    // Timeout
    initial begin
        #15us;
        $fatal(1, "Test timeout");
    end

    // Max errors count
    initial begin
        wait( env.scb.errors == 20 );
        $fatal(1, "Max errors count!");
    end
endmodule
