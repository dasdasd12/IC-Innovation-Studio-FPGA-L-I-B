`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/09 18:04:04
// Design Name: 
// Module Name: SPI_ctrl
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


module SPI_ctrl(
    input                               clk                        ,//系统时钟 2倍SPI时钟
    input                               rst_n                      ,//系统复位
    input                               mode                       ,//SPI工作模式       
    //SPI端口
    input                               miso                       ,//从设备发送数据
    output                              sck                        ,//时钟信号
    output                              mosi                       ,//主设备发送数据
    output                              cs                          //片选信号
    //读取数据
    //output  [7:0] data_out                //读取数据
    );

    wire                                start                       ;//开始信号
    wire               [  63: 0]        data                        ;//主设备发送数据
    wire                                finished                    ;//完成信号

    wire                                busy                        ;//忙信号
    wire                                busy_reg                    ;//忙信号寄存器

    wire               [   2: 0]        bite_num                    ;//主设备发送数据宽度


    //SPI协议模块
    SPI_top spi_top_inst (
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
        //控制信号
    .start                              (start                     ),
    .finished                           (finished                  ),
        //SPI端口
    .miso                               (miso                      ),
    .mode                               (mode                      ),
    .sck                                (sck                       ),
    .mosi                               (mosi                      ),
    .cs                                 (cs                        ),
        //状态信号
    .busy                               (busy                      ),//忙信号
    .busy_reg                           (busy_reg                  ),//忙信号寄存器
        //数据
    .bite_num                           (bite_num                  ),//发送数据宽度
    .data                               (data                      ),//发送数据
    .data_out                           (                          ) //接收数据

    );

    //SPI发送数据
    SPI_data spi_data_inst (
    .clk                                (clk                       ),
    .rst_n                              (rst_n                     ),
    .busy                               (busy                      ),
    .busy_reg                           (busy_reg                  ),
    .start                              (start                     ),
    .finished                           (finished                  ),
    .data_out                           (data                      ),
    .bite_num                           (bite_num                  ) 
    );
    
endmodule
