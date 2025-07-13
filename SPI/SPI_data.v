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
        input               clk         ,           //系统时钟 2倍SPI时钟
        input               rst_n       ,           //系统复位
        input               busy        ,           //忙信号    
        input               busy_reg    ,           //忙信号寄存器
        input               finished    ,           //完成信号
        output reg          start       ,           //开始信号
        output     [7:0]    data_out    ,           //从设备接收数据
        output reg          sync                    
    );

    localparam   REG    = 8'h07  ;            

    wire ctrl;

    reg [15:0] wait_cnt;       
    reg en;                            //使能信号

    wire [7:0] data_reg [0:REG-1];               //数据寄存器

    reg [15:0] data_cnt;                        //数据计数器

    assign data_out = data_reg[data_cnt];       //输出数据

    assign ctrl = (~busy & busy_reg)|(busy & ~busy_reg); 

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
        else if (wait_cnt == 16'd999) begin
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

        always @(negedge clk or negedge rst_n)           
            begin                                        
                if(!rst_n)                               
                    sync <= 1'b1;          //复位时同步信号为低                                   
                else if (ctrl && (data_cnt == 16'd0 || (data_cnt == 16'd2 && !start))) begin                         
                    sync <= 1'b0;          //使能信号为高时同步信号为高                                
                end                                          
                else if (ctrl && ((data_cnt == 16'd2 && start) || data_cnt == 16'd7)) begin              
                    sync <= 1'b1;          //完成信号和使能信号同时为高时同步信号为低                
                end                                   
                else 
                    data_cnt <= data_cnt;                                                     
            end                                          

    assign data_reg[0] = 8'h00;
    assign data_reg[1] = 8'hf0;

    // assign data_reg[2] = 8'h01;
    // assign data_reg[3] = 8'hd0;
    // assign data_reg[4] = 8'h00;
    // assign data_reg[5] = 8'h00;

    // assign data_reg[6] = 8'h03;
    // assign data_reg[7] = 8'h00;
    // assign data_reg[8] = 8'h23;
    // assign data_reg[9] = 8'h35;

    assign data_reg[2] = 8'h04;
    assign data_reg[3] = 8'h00;
    assign data_reg[4] = 8'hff;
    assign data_reg[5] = 8'hff;
    assign data_reg[6] = 8'hff;

endmodule