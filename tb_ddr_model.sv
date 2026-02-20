module tb_ddr_model;

    logic clk;
    logic reset;
    logic rd_req, wr_req;
    logic [9:0] addr;
    logic [31:0] wr_data;
    logic [31:0] rd_data;
    logic rd_valid;

    ddr_model #(.DATA_WIDTH(32), .DEPTH(1024)) dut (
        .clk(clk), .reset(reset),
        .rd_req(rd_req), .wr_req(wr_req),
        .addr(addr), .wr_data(wr_data),
        .rd_data(rd_data), .rd_valid(rd_valid)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1; rd_req = 0; wr_req = 0; addr = 0; wr_data = 0;
        #20 reset = 0;
        #10;

        // write value
        addr = 10; wr_data = 32'hDEADBEEF; wr_req = 1;
        @(posedge clk); wr_req = 0;

        #10;
        // read value
        addr = 10; rd_req = 1;
        @(posedge clk); rd_req = 0;
        wait(rd_valid);
        $display("DDR read returned: %08x", rd_data);

        #20 $finish;
    end
endmodule

