`timescale 1ns / 1ps
module spi_tb;

    reg clk, rst_n;

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        rst_n = 0;
        #20;
        rst_n = 1; 
    end

    reg  start;
    wire busy,finished,sck,cs,mosi,miso;

    wire [15:0] data_out;
    reg  [11:0] data;

    SPI #(
        .DATA_WIDTH 	(12                    ),
        .MODE       	(00                    ),
        .CLK_FRE    	(100_000_000      ),
        .LSB_FIRST      (1                     )
    ) u_SPI_tx_lsb (
        .clk            (clk                  ),
        .rst_n          (rst_n                ),

        .start          (start                ),
        .finished       (finished             ),
        .busy           (busy                 ),

        .data_in        (data                 ),
        .data_out       (data_out             ),

        .sck            (sck                  ),
        .cs             (cs                   ),
        .miso           (                     ),
        .mosi           (mosi                 )
    );

    SPI #(
    .DATA_WIDTH                         (12                        ),
    .MODE                               (00                        ),
    .CLK_FRE                            (100_000_000               ),
    .LSB_FIRST                          (0                         ) 
    ) u_SPI_tx_msb (
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),

    .start                              (start                     ),
    .finished                           (                          ),
    .busy                               (                          ),

    .data_in                            (data                      ),
    .data_out                           (                          ),

    .sck                                (                          ),
    .cs                                 (                          ),
    .miso                               (miso                      ),
    .mosi                               (                          ) 
    );

    initial begin
        start = 0;
        #40;
        start = 1; // Start SPI transaction
        data  = 12'hA5A; // Example data to send
        #10;
        start = 0; // Clear start signal
    end

    initial begin
        $dumpfile("icarus/spi_tb.vcd");
        $dumpvars(0, spi_tb);
        #30000;
        $finish();
    end

endmodule
