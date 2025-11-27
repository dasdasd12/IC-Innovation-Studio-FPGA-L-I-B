`timescale 1ns/1ps  // Add timescale directive for simulation compatibility

module uart_tb();

    reg                                 clk                         ;
    reg                                 rst_n                       ;

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        #100;
        rst_n = 1'b1;
    end

    always #5 clk = ~clk;                                           //100M

    // output declaration of module uart_rx
    wire                                rx_pin                      ;
    wire               [   7: 0]        rx_data                     ;
    wire                                rx_data_valid               ;

    reg                                 rx_data_ready               ;

    uart_rx #(
    .CLK_FRE                            (100                       ),
    .BAUD_RATE                          (115200)                   ) 
    u_uart_rx(
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    .rx_data                            (rx_data                   ),
    .rx_data_valid                      (rx_data_valid             ),
    .rx_data_ready                      (rx_data_ready             ),
    .rx_pin                             (rx_pin                    ) 
    );
    
    
    // output declaration of module uart_tx
    wire                                tx_pin                      ;
    wire                                tx_data_ready               ;

    reg                [   7: 0]        tx_data                     ;
    reg                                 tx_data_valid               ;

    uart_tx #(
    .CLK_FRE                            (100                       ),
    .BAUD_RATE                          (115200)                   ) 
    u_uart_tx(
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    .tx_data                            (tx_data                   ),
    .tx_data_valid                      (tx_data_valid             ),
    .tx_data_ready                      (tx_data_ready             ),
    .tx_pin                             (tx_pin                    ) 
    );

    initial begin
        tx_data = 8'hA5;
        tx_data_valid = 1'b0;
        rx_data_ready = 1'b1;

        #200;
        tx_data_valid = 1'b1;

        #10;
        tx_data_valid = 1'b0;

        wait(tx_data_ready == 1'b1);

        #10;
        tx_data = 8'h3C;
        tx_data_valid = 1'b1;
        rx_data_ready = 1'b0;

        #10;
        tx_data_valid = 1'b0;

    end

    assign                              rx_pin                      = tx_pin               ;

    initial begin
        $dumpfile("/icarus/uart_tb.vcd"); // Update dumpfile path
        $dumpvars(0, uart_tb);
        #2000000;
        $finish();
    end

endmodule