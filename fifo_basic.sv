`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.11.2025 21:27:01
// Design Name: 
// Module Name: fifo_basic
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
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.09.2025 20:57:41
// Design Name: 
// Module Name: fifo_basic
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


module fifo_basic #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 16,                // number of entries, must be a power-of-two for simple pointer wrap
    parameter PTR_WIDTH = $clog2(DEPTH)
)(
    input  logic                   clk,
    input  logic                   reset,

    // Write side
    input  logic                   wr_en,
    input  logic [DATA_WIDTH-1:0]  data_in,
    output logic                   full,

    // Read side
    input  logic                   rd_en,
    output logic [DATA_WIDTH-1:0]  data_out,
    output logic                   empty
);

    // Internal memory
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Pointers (binary)
    logic [PTR_WIDTH-1:0] wr_ptr, rd_ptr;
    logic [PTR_WIDTH:0]   count;   // count of elements

    // Write logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            wr_ptr <= '0;
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr] <= data_in;
                wr_ptr <= wr_ptr + 1;
            end
        end
    end

    // Read logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            rd_ptr <= '0;
            data_out <= '0;
        end else begin
            if (rd_en && !empty) begin
                data_out <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1;
            end
        end
    end

    // Count & full/empty
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
        end else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1;
                2'b01: count <= count - 1;
                default: count <= count;
            endcase
        end
    end

    assign full  = (count == DEPTH);
    assign empty = (count == 0);

endmodule
   

