`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IC Innovation Studio
// Engineer: DDDD
// 
// Create Date: 2025/07/09 18:04:04
// Design Name: 
// Module Name: SPI_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: SPI数据传输/读取模块，支持数据位宽自定义，支持SPI工作模式自定义。使用方
//              法：先在SPI_ctrl模块检查SPI模式是否正确，然后在SPI_data模块中的结尾部分配
//              置好数据和数据位宽一一对应，然后再更改数据传输量常数的值至少为你传输数据
//              的数量+1(比如2个数据就配置3)。目前读模式只支持读一个寄存器的数据，可以采
//              用内部ILA或者外部读取，ctrl模块中给出相关配置(已注释)。
//              PS:本模块只支持从设备的数量为1，多设备可在外部配置
// Dependencies: 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SPI_ctrl(
    input                               clk                        ,//系统时钟 2倍SPI时钟
    input                               rst_n                      ,//系统复位   

    //SPI端口

    input                               miso                       ,//从设备发送数据
    output                              sck                        ,//时钟信号
    output                              mosi                       ,//主设备发送数据
    output                              cs                         ,//片选信号

    //读取数据

    output             [  63: 0]        data_out                    //读取数据
    );

    parameter                           mode                        = 2'b00 ;   //SPI工作模式 默认 CPOL=0, CPHA=0

    wire                                start                       ;//开始信号
    wire               [  63: 0]        data                        ;//主设备发送数据
    wire                                finished                    ;//完成信号

    wire                                busy                        ;//忙信号
    wire                                busy_reg                    ;//忙信号寄存器

    wire               [   2: 0]        bite_num                    ;//主设备发送数据宽度

    // wire               [  63: 0]        data_out                    ;//从设备接收数据

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
    .data_out                           (data_out                  ) //接收数据

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

    // ila_0 ila_inst (
    // .clk                                (clk                       ),
    // .probe0                             (data_out                  ) 
    // );
    
endmodule
