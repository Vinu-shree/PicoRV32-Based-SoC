module tb_top_picorv32_system;
// tb_top_test.sv


    logic clk;
    logic resetn;

    // instantiate DUT
    top_picorv32_system dut ( .clk(clk), .resetn(resetn) );

    // clock
    initial clk = 0;
    always #5 clk = ~clk;  // 100 MHz

    // reset sequence
    initial begin
        resetn = 0;
        #100;
        resetn = 1;
    end

    // preload program into DDR memory inside DUT
    initial begin
        // program.mem must be in simulation path
        $display("[TB] Loading program.mem into DDR");
        $readmemh("program.mem", dut.ddr_inst.mem);
    end

    // trace waves
    initial begin
        $dumpfile("top_waveform.vcd");
        $dumpvars(0, tb_top_picorv32_system);
        #200000; // run time (ns) - adjust to fit your test
        $display("[TB] Simulation done");
        $finish;
    end

    // optional debug prints
    always @(posedge clk) begin
        // print DDR reads requests for debug
        if (dut.ddr_rd_req) $display("[%0t] DDR rd_req addr=%0d", $time, dut.ddr_addr);
        if (dut.ddr_rd_valid) $display("[%0t] DDR rd_valid data=0x%08x", $time, dut.ddr_rd_data);
    end

endmodule

   

