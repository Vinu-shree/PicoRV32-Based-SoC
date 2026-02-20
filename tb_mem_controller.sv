module tb_mem_controller;
// tb_mem_controller.sv

    logic clk, reset;
    logic cpu_wr_req, cpu_rd_req;
    logic [9:0] cpu_addr;
    logic [31:0] cpu_data_in;
    logic [31:0] cpu_data_out;
    logic cpu_data_valid;

    logic ddr_wr_req, ddr_rd_req;
    logic [9:0] ddr_addr;
    logic [31:0] ddr_wr_data;
    logic [31:0] ddr_rd_data;
    logic ddr_rd_valid;

    mem_controller #(.ADDR_WIDTH(10), .DATA_WIDTH(32)) dut (
        .clk(clk), .reset(reset),
        .cpu_wr_req(cpu_wr_req), .cpu_rd_req(cpu_rd_req), .cpu_addr(cpu_addr),
        .cpu_data_in(cpu_data_in), .cpu_data_out(cpu_data_out), .cpu_data_valid(cpu_data_valid),
        .ddr_wr_req(ddr_wr_req), .ddr_rd_req(ddr_rd_req), .ddr_addr(ddr_addr),
        .ddr_wr_data(ddr_wr_data), .ddr_rd_data(ddr_rd_data), .ddr_rd_valid(ddr_rd_valid)
    );

    // Provide a simple DDR model inside TB to respond
    logic [31:0] mem [0:1023];
    initial begin
        integer i;
        for (i=0;i<1024;i++) mem[i] = 32'h0;
        mem[10] = 32'hCAFEBABE;
    end

    initial clk = 0;
    always #5 clk = ~clk;

    // simulate DDR handshake
    always_ff @(posedge clk) begin
        // write
        if (ddr_wr_req) begin
            mem[ddr_addr] <= ddr_wr_data;
        end
        // read
        if (ddr_rd_req) begin
            ddr_rd_data <= mem[ddr_addr];
            ddr_rd_valid <= 1;
        end else begin
            ddr_rd_valid <= 0;
        end
    end

    initial begin
        reset = 1; cpu_wr_req = 0; cpu_rd_req = 0; cpu_addr = 0; cpu_data_in = 0;
        #20 reset = 0;
        #10;

        // Write to mem[5]
        cpu_addr = 5; cpu_data_in = 32'hDEADBEEF; cpu_wr_req = 1;
        @(posedge clk); cpu_wr_req = 0;

        #20;
        // Read mem[5]
        cpu_addr = 5; cpu_rd_req = 1;
        @(posedge clk); cpu_rd_req = 0;
        wait(cpu_data_valid);
        $display("Read returned: %08x", cpu_data_out);

        // Read mem[10] (preloaded)
        cpu_addr = 10; cpu_rd_req = 1;
        @(posedge clk); cpu_rd_req = 0;
        wait(cpu_data_valid);
        $display("Read preloaded: %08x", cpu_data_out);

        #50 $finish;
    end
endmodule

