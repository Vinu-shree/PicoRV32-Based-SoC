`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.09.2025 21:04:08
// Design Name: 
// Module Name: ddr_model
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ddr_model #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 1024    // number of words
)(
    input  logic                   clk,
    input  logic                   reset,    // active-high
    input  logic                   rd_req,
    input  logic                   wr_req,
    input  logic [$clog2(DEPTH)-1:0] addr,    // word address
    input  logic [DATA_WIDTH-1:0]  wr_data,
    output logic [DATA_WIDTH-1:0]  rd_data,
    output logic                   rd_valid
);

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Initialize memory with NOPs by default (optional)
    initial begin : preload_block
        integer i;
        for (i = 0; i < DEPTH; i = i + 1) mem[i] = {DATA_WIDTH{1'b0}};
    end

    // Simple synchronous read/write: read valid same cycle as request for simplicity
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            rd_valid <= 0;
            rd_data <= '0;
        end else begin
            rd_valid <= 0;
            if (wr_req) begin
                mem[addr] <= wr_data;
            end
            if (rd_req) begin
                rd_data <= mem[addr];
                rd_valid <= 1;
            end
        end
    end
endmodule
