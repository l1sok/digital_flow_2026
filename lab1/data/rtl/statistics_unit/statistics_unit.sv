module statistics_unit (
    input  logic        clk,
    input  logic        rst_n,

    input  logic        clear,
    input  logic        valid_in,
    input  logic [31:0] data_in,

    output logic [15:0] count,
    output logic [31:0] sum,
    output logic [31:0] min,
    output logic [31:0] max
);

    logic        wr_en_count;
    logic        wr_en_sum;
    logic        wr_en_minmax;

    logic [15:0] core_count_ff;
    logic [15:0] core_count_nx;

    logic [31:0] core_sum_ff;
    logic [31:0] core_sum_nx;

    logic [31:0] core_min_ff;
    logic [31:0] core_min_nx;

    logic [31:0] core_max_ff;
    logic [31:0] core_max_nx;

    //------------------
    // statistics write enable
    //------------------
    assign wr_en_minmax =  valid_in | clear;
    assign wr_en_count  = (valid_in & ~(core_count_ff == '1)) | clear;
    assign wr_en_sum    = (valid_in & ~(core_sum_ff   == '1)) | clear;

    //------------------
    // count
    //------------------
    assign core_count_nx = clear ? '0 : core_count + 16'd1;

    always_ff @(posedge clk) begin
        if (~rst_n)
            core_count_ff <= '0;
        else if (wr_en_count)
            core_count_ff <= core_count_nx;
    end

    //------------------
    // sum
    //------------------
    assign core_sum_nx = clear ? '0 : core_sum_ff + data_in;

    always_ff @(posedge clk) begin
        if (~rst_n)
            core_sum_ff <= '0;
        else if (wr_en_sum)
            core_sum_ff <= core_sum_nx;
    end

    //------------------
    // min
    //------------------
    assign core_min_nx = clear                  ? '0 : 
                        (core_min_ff > data_in) ? data_in : core_min_ff;

    always_ff @(posedge clk) begin
        if (~rst_n)
            core_sum_ff <= '0;
        else if (wr_en_minmax)
            core_min_ff <= core_min_nx;
    end

    //------------------
    // max
    //------------------
    assign core_max_nx = clear                  ? '0 : 
                        (core_max_ff < data_in) ? data_in : core_max_ff;

    always_ff @(posedge clk) begin
        if (~rst_n)
            core_sum_ff <= '0;
        else if (wr_en_minmax)
            core_max_ff <= core_max_nx;
    end

endmodule