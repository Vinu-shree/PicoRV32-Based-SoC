`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.09.2025 22:33:35
// Design Name: 
// Module Name: mem_controller
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


module mem_controller #(
    parameter ADDR_WIDTH = 10,
    parameter DATA_WIDTH = 32
)(
    input  logic                   clk,
    input  logic                   reset,     // active-high reset

    // CPU side
    input  logic                   cpu_wr_req,
    input  logic                   cpu_rd_req,
    input  logic [ADDR_WIDTH-1:0]  cpu_addr,
    input  logic [DATA_WIDTH-1:0]  cpu_data_in,
    output logic [DATA_WIDTH-1:0]  cpu_data_out,
    output logic                   cpu_data_valid,

    // DDR side
    output logic                   ddr_wr_req,
    output logic                   ddr_rd_req,
    output logic [ADDR_WIDTH-1:0]  ddr_addr,
    output logic [DATA_WIDTH-1:0]  ddr_wr_data,
    input  logic [DATA_WIDTH-1:0]  ddr_rd_data,
    input  logic                   ddr_rd_valid
);

    typedef enum logic [2:0] {
        ST_IDLE = 3'd0,
        ST_WR_REQ = 3'd1,
        ST_WR_ACK = 3'd2,
        ST_RD_REQ = 3'd3,
        ST_RD_WAIT = 3'd4,
        ST_RD_RESP = 3'd5
    } state_t;

    state_t state, next_state;

    // state register
    always_ff @(posedge clk or posedge reset) begin
        if (reset) state <= ST_IDLE;
        else state <= next_state;
    end

    // default outputs
    always_comb begin
        next_state = state;
        ddr_wr_req = 0;
        ddr_rd_req = 0;
        ddr_addr   = '0;
        ddr_wr_data= '0;
        cpu_data_out = '0;
        cpu_data_valid = 0;

        case (state)
            ST_IDLE: begin
                if (cpu_wr_req) begin
                    next_state = ST_WR_REQ;
                end else if (cpu_rd_req) begin
                    next_state = ST_RD_REQ;
                end
            end

            ST_WR_REQ: begin
                ddr_wr_req = 1;
                ddr_addr   = cpu_addr;
                ddr_wr_data= cpu_data_in;
                next_state = ST_WR_ACK;
            end

            ST_WR_ACK: begin
                // assume immediate ack from DDR: just go back (DDR model writes in same cycle)
                next_state = ST_IDLE;
            end

            ST_RD_REQ: begin
                ddr_rd_req = 1;
                ddr_addr   = cpu_addr;
                next_state = ST_RD_WAIT;
            end

            ST_RD_WAIT: begin
                if (ddr_rd_valid) begin
                    next_state = ST_RD_RESP;
                end
            end

            ST_RD_RESP: begin
                cpu_data_out = ddr_rd_data;
                cpu_data_valid = 1;
                next_state = ST_IDLE;
            end

            default: next_state = ST_IDLE;
        endcase
    end

endmodule
   
   
