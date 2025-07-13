`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/09 16:54:33
// Design Name: 
// Module Name: spi_sim
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


module spi_sim(

    );
    // Testbench for SPI_ctrl module
    reg clk;
    reg rst_n;
    reg miso;
    wire sck;
    wire mosi;
    wire cs;

    // Instantiate the SPI_ctrl module
    SPI_ctrl spi_ctrl_inst (
        .clk(clk),
        .rst_n(rst_n),
        .miso(miso),    
        .sck(sck),
        .mosi(mosi),
        .cs(cs)
    );
    // Clock generation
    initial begin
        clk = 0;
        rst_n = 0;
        #100
        rst_n = 1; // Release reset after 100 ns
        forever #5 clk = ~clk; // 100 MHz clock
    end

endmodule
