`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:IC Innovation Studio
// Engineer:DDDD
//
// Create Date: 2025/07/09 15:14:55
// Design Name:
// Module Name: SPI_top
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

// SPI总线协议
//master   <->      slave
//SCK   -------->   SCK
//MOSI  -------->   MOSI
//MISO  <--------   MISO
//CS    -------->   CS

// SPI工作模式              SCK_IDLE        SCK_READ        SCK_TRANSFER
//模式0：CPOL=0, CPHA=0        低              ↑                  ↓
//模式1：CPOL=0, CPHA=1        低              ↓                  ↑
//模式2：CPOL=1, CPHA=0        高              ↑                  ↓
//模式3：CPOL=1, CPHA=1        高              ↓                  ↑

//从设备为1

module SPI_top(
    input                               clk                        ,//系统时钟 2倍SPI时钟
    input                               rst_n                      ,//系统复位
    input                               start                      ,//开始信号
    input                [  63: 0]      data                       ,//主设备发送数据
    input                [   2: 0]      bite_num                   ,//主设备发送数据宽度
    input                               miso                       ,//从设备发送数据
    input                [   1: 0]      mode                       ,//SPI工作模式
    output               [  63: 0]      data_out                   ,//从设备接收数据
    output                              sck                        ,//时钟信号
    output                              mosi                       ,//主设备发送数据
    output                              cs                         ,//片选信号
    output reg                          busy                       ,//忙信号
    output reg                          busy_reg                   ,//忙信号寄存器
    output reg                          finished                    //完成信号
    );

    localparam                          MODE00                      = 2'b00 ;             //SPI工作模式0
    localparam                          MODE01                      = 2'b01 ;             //SPI工作模式1
    localparam                          MODE10                      = 2'b10 ;             //SPI工作模式2
    localparam                          MODE11                      = 2'b11 ;             //SPI工作模式3

    localparam                          IDLE                        = 2'b00 ;            //空闲状态
    localparam                          ACTIVE                      = 2'b01 ;            //读取状态

    reg                                 sck_reg                     ;//时钟信号寄存器
    reg                [   7: 0]        data_cnt                    ;//数据计数器
    reg                [   7: 0]        data_cnt_reg                ;//数据寄存器输出
    reg                [   2: 0]        state                       ;//状态寄存器
    reg                [  63: 0]        data_out_reg                ;//从设备接收数据寄存器

    wire               [   6: 0]        data_reg_o                  ;
    wire               [   6: 0]        data_reg_i                  ;

    assign                              sck                         = sck_reg;//将时钟信号寄存器赋值给输出sck
    assign                              cs                          = ~(busy&busy_reg);//片选信号为低，表示从设备被选中
    assign                              data_reg_i                  = (data_cnt%2 == 1'b0)?data_cnt/2:data_cnt_reg/2;
    assign                              data_reg_o                  = ((data_cnt+1'b1)%2 == 1'b1)?(data_cnt_reg+1'b1)/2:(data_cnt+1'b1)/2;

    assign                              mosi                        = (state == ACTIVE)?((mode[0]) ? data[bite_num*8-1-data_reg_o] : data[bite_num*8-1-data_reg_i]) : 1'b0;//根据模式选择发送数据

    assign                              data_out                    = data_out_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy <= 1'b0;
        end
        else if (start && !busy) begin
            busy <= 1'b1;                                           //开始传输时设置忙信号
        end
        else if (finished && busy) begin
            busy <= 1'b0;                                           //传输完成时清除忙信号
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            busy_reg <= 1'b0;                                       //复位时忙信号为低                                   
        else
            busy_reg <= busy;                                       //将忙信号赋给寄存器                                
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_cnt_reg <= 1'b0;                                   //复位时主设备发送数据为低
        end
        else
            data_cnt_reg <= data_cnt;                               //将数据计数器的值赋给寄存器
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sck_reg  <= mode[1];
            data_cnt <= 1'b0;                                       //复位时钟信号和数据计数器
        end
        else if (state == ACTIVE) begin
            sck_reg  <= ~sck_reg;                                   //模式0：CPOL=0, CPHA=0
            data_cnt <= data_cnt + 1'b1;                            //每次时钟翻转时增加数据计数器
        end
        else
            data_cnt <= 1'b0;                                       //否则将数据计数器清零
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            finished <= 1'b0;                                       //复位完成信号
        end
        else if (data_cnt == bite_num*16-1) begin
            finished <= 1'b1;                                       //数据计数器达到15时设置完成信号
        end
        else begin
            finished <= 1'b0;                                       //否则清除完成信号
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;                                          //复位状态寄存器
        end
        else if (busy) begin
            case (state)
                IDLE: begin
                    if (busy&&!busy_reg) begin
                        state <= ACTIVE;                            //进入写入状态
                    end
                end
                ACTIVE: begin
                  case (mode)
                    MODE00: begin

                      data_out_reg[bite_num*8-1-data_reg_o] <= miso;//从设备接收数据
                      if(data_cnt == bite_num*16-1) begin
                        state <= IDLE;
                      end
                    end
                    MODE01: begin

                      data_out_reg[bite_num*8-1-data_reg_i] <= miso;//从设备接收数据
                      if(data_cnt == bite_num*16-1) begin
                        state <= IDLE;
                      end
                    end
                    MODE10: begin

                      data_out_reg[bite_num*8-1-data_reg_o] <= miso;//从设备接收数据
                      if(data_cnt == bite_num*16-1) begin
                        state <= IDLE;
                      end
                    end
                    MODE11: begin

                      data_out_reg[bite_num*8-1-data_reg_i] <= miso;//从设备接收数据
                      if(data_cnt == bite_num*16-1) begin
                        state <= IDLE;
                      end
                    end
                  endcase
                end
            endcase
        end
    end

endmodule
