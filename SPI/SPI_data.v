`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/09 18:04:04
// Design Name: 
// Module Name: SPI_data
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


module SPI_data(
    input                               clk                        ,//系统时钟 2倍SPI时钟
    input                               rst_n                      ,//系统复位
    input                               busy                       ,//忙信号    
    input                               busy_reg                   ,//忙信号寄存器
    input                               finished                   ,//完成信号
    output reg                          start                      ,//开始信号
    output               [  63: 0]      data_out                   ,
    output               [   2: 0]      bite_num                    
    );

    localparam                          REG                         = 8'h07 ;            

    reg                [  15: 0]        wait_cnt                    ;
    reg                                 en                          ;//使能信号

    wire               [  63: 0]        data_reg[0:REG-1]           ;//数据寄存器
    wire               [   2: 0]        bite_num_reg[0:REG-1]       ;//数据宽度寄存器

    reg                [  15: 0]        data_cnt                    ;//数据计数器

    assign                              data_out                    = data_reg[data_cnt];//输出数据

    assign                              bite_num                    = bite_num_reg[data_cnt];//输出数据宽度

    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wait_cnt <= 16'd0;
        end
        else if (wait_cnt < 16'd1000) begin
            wait_cnt <= wait_cnt + 1'b1;
        end
        else begin
            wait_cnt <= wait_cnt;
        end
    end

    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            start <= 1'b0;
        end
        else if (wait_cnt == 16'd49) begin
            start <= 1'b1;
        end
        else if (finished && en) begin
            start <= 1'b1;
        end
        else begin
            start <= 1'b0;
        end
    end

    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_cnt <= 16'd0;
        end
        else if (!start && finished) begin
            data_cnt <= data_cnt + 1'b1;
        end
        else begin
            data_cnt <= data_cnt;
        end
    end

    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            en <= 1'b1;
        end
        else if (data_cnt == REG - 1) begin
            en <= 1'b0;
        end
        else begin
            en <= en;
        end
    end

    assign                              data_reg[0]                 = 16'h00f0;

    assign                              bite_num_reg[0]             = 3'd2;
    // assign data_reg[2] = 8'h01;
    // assign data_reg[3] = 8'hd0;
    // assign data_reg[4] = 8'h00;
    // assign data_reg[5] = 8'h00;

    // assign data_reg[6] = 8'h03;
    // assign data_reg[7] = 8'h00;
    // assign data_reg[8] = 8'h23;
    // assign data_reg[9] = 8'h35;

    assign                              data_reg[1]                 = 40'h0400_ffff_ff;

    assign                              bite_num_reg[1]             = 3'd5;

endmodule