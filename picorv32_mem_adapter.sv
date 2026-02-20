module picorv32_mem_adapter  #(
    parameter ADDR_WIDTH = 10,
    parameter DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  resetn,   // active-low reset

    // PicoRV32 memory bus (master side)
    input  logic                  mem_valid,
    input  logic                  mem_instr,
    output logic                  mem_ready,
    input  logic [31:0]           mem_addr,
    input  logic [31:0]           mem_wdata,
    input  logic [3:0]            mem_wstrb,
    output logic [31:0]           mem_rdata,

    // Controller side (simple)
    output logic                  cpu_wr_req,
    output logic                  cpu_rd_req,
    output logic [ADDR_WIDTH-1:0] cpu_addr,
    output logic [DATA_WIDTH-1:0] cpu_data_in,
    input  logic [DATA_WIDTH-1:0] cpu_data_out,
    input  logic                  cpu_data_valid
);

    // internal buffer for read data
    logic [DATA_WIDTH-1:0] read_buffer;
    logic                  read_buffer_valid;

    // Map 32-bit byte address to word address (ADDR_WIDTH)
    assign cpu_addr    = mem_addr[ADDR_WIDTH+1:2]; // chop low 2 bits for word index
    assign cpu_data_in = mem_wdata;

    // simple request pulses
    assign cpu_wr_req  = mem_valid && (|mem_wstrb); // write when valid and wstrb != 0
    assign cpu_rd_req  = mem_valid && !(|mem_wstrb);

    // Sequential logic
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            mem_ready         <= 0;
            mem_rdata         <= 0;
            read_buffer       <= 0;
            read_buffer_valid <= 0;
        end else begin
            mem_ready <= 0;

            // latch data from controller when it comes
            if (cpu_data_valid) begin
                read_buffer       <= cpu_data_out;
                read_buffer_valid <= 1;
            end

            // when CPU core requests, serve from buffer
            if (mem_valid && cpu_rd_req && read_buffer_valid) begin
                mem_rdata         <= read_buffer;
                mem_ready         <= 1;
                read_buffer_valid <= 0;  // consume buffer
            end

            // writes ? immediate ready
            if (mem_valid && cpu_wr_req) begin
                mem_ready <= 1;
            end
        end
    end

endmodule
