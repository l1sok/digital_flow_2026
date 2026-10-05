module processing_unit (
    input  logic        clk,
    input  logic        rst_n,

    input  logic        valid_in,
    input  logic [15:0] data_a,
    input  logic [15:0] data_b,
    input  logic [1:0]  operation,

    output logic        valid_out,
    output logic [31:0] result
);

    localparam RESULT_WIDTH = 32;

    enum logic [1:0] {ADD, SUB, XOR, MULT} core_op;

    logic [31:0] result_nx;
    logic [31:0] result_ff;

    logic valid_ff;

    assign core_op = operation;

    always_comb begin
        case(core_op)
            ADD:     result_nx = RESULT_WIDTH'(data_a + data_b);
            SUB:     result_nx = RESULT_WIDTH'(data_a - data_b);
            XOR:     result_nx = RESULT_WIDTH'(data_a ^ data_b);
            MULT:    result_nx = RESULT_WIDTH'(data_a * data_b);
            default: result_nx = '0;
        endcase
    end

    always_ff @(posedge clk) begin
        if (~rst_n)
            result_ff <= '0;
        else if (valid_in)
            result_ff <= result_nx;
    end

    always_ff @(posedge clk) begin
        if (~rst_n)
            valid_ff <= '0;
        else
            valid_ff <= valid_in;
    end

    assign result    = result_ff;
    assign valid_out = valid_ff;

endmodule
