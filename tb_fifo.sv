module tb_fifo;
// tb_fifo.sv

    parameter WIDTH = 32;
    parameter DEPTH = 8;

    logic clk;
    logic reset;

    // DUT signals
    logic wr_en;
    logic [WIDTH-1:0] data_in;
    logic full;
    logic rd_en;
    logic [WIDTH-1:0] data_out;
    logic empty;

    fifo_basic #(.DATA_WIDTH(WIDTH), .DEPTH(DEPTH)) dut (
        .clk(clk), .reset(reset),
        .wr_en(wr_en), .data_in(data_in), .full(full),
        .rd_en(rd_en), .data_out(data_out), .empty(empty)
    );

    // clock
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1; wr_en = 0; rd_en = 0; data_in = 0;
        #20 reset = 0;
        #10;

        // write 4 values
        repeat (4) begin
            @(negedge clk);
            wr_en = 1; data_in = $urandom_range(0, 2**32-1);
            @(negedge clk);
            wr_en = 0;
        end

        #20;

        // read 3 values
        repeat (3) begin
            @(negedge clk);
            rd_en = 1;
            @(negedge clk);
            rd_en = 0;
        end

        #50;
        $display("FIFO TB done");
        $finish;
    end
endmodule

   

