
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

//注意一点：一般来说SPI写数据宽度大于读数据宽度，所以SPI读取往往不会读取整个DATA_WIDTH的数据，使用时根据需要在外部截取位数；而且有时候SPI时序中会有一些标志位，这些也需要考虑为数据位的一部分。

module SPI #(
    parameter                           DATA_WIDTH                  = 10                   ,//数据宽度(取读/写最大值)
    parameter                           MODE                        = 2'b00                ,//{CPOL,CPHA}
    parameter                           CLK_FRE                     = 50_000_000           ,//系统时钟频率
    parameter                           SPI_FRE                     = 1_000_000            ,//SPI时钟频率
    parameter                           LSB_FIRST                   = 1'b0                                       
)(
    input                               clk                        ,//系统时钟
    input                               rst_n                      ,//系统复位

    input                               start                      ,//启动脉冲

    output reg                          busy                       ,//忙信号
    output reg                          finished                   ,//完成信号

    input        [DATA_WIDTH-1: 0]      data_in                    ,//主设备发送数据，和启动脉冲同步给出
    output reg   [DATA_WIDTH-1: 0]      data_out                   ,//主设备接收数据

    output                              sck                        ,//spi时钟
    input                               miso                       ,//从设备发送数据
    output reg                          mosi                       ,//主设备发送数据
    output                              cs                          //片选信号
    );

    localparam                          CNT_WIDTH     = $clog2(DATA_WIDTH*2-1) ;//数据计数器宽度
    localparam                          SPI_CLK_DIV   = CLK_FRE/SPI_FRE/2      ;//SPI时钟分频系数

    localparam                          MODE00        = 2'b00;             
    localparam                          MODE01        = 2'b01;             
    localparam                          MODE10        = 2'b10;             
    localparam                          MODE11        = 2'b11;        

    localparam                          IDLE          = 2'b00;            //空闲状态
    localparam                          ACTIVE        = 2'b01;            //读取状态

    reg [   2: 0]           state     ;                 
    reg                     sck_reg   ;

    reg [CNT_WIDTH-1: 0]    data_cnt    ;              
    reg [CNT_WIDTH-1: 0]    data_cnt_o  ;
    reg [CNT_WIDTH-1: 0]    data_cnt_i  ;    
    reg                     oi_flag     ;        

    reg [DATA_WIDTH-1: 0]   data_out_reg;

    assign sck  =  sck_reg              ;
    assign cs   =  ~busy                ;

    reg [DATA_WIDTH-1: 0]   data_in_reg ;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_in_reg <= {DATA_WIDTH{1'b0}};//复位主设备发送数据寄存器
        end
        else if (start) begin
            data_in_reg <= data_in;           //开始传输时将输入数据赋给寄存器
        end
    end

    //todo generate SPIx2 CLOCK

    reg         spi_clkx2;
    reg [15:0]   clk_div_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div_cnt <= 16'b0;
            spi_clkx2 <= 1'b0;
        end
        else if (clk_div_cnt == SPI_CLK_DIV - 1) begin
            clk_div_cnt <= 16'b0;
            spi_clkx2 <= ~spi_clkx2;
        end
        else begin
            clk_div_cnt <= clk_div_cnt + 1'b1;
        end
    end

    //TODO FLAG LOGIC

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy <= 1'b0;
        end
        else if (start) begin
            busy <= 1'b1;                                           //开始传输时设置忙信号
        end
        else if (data_cnt == DATA_WIDTH*2 - 1) begin
            busy <= 1'b0;                                           //传输完成时清除忙信号
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            finished <= 1'b0;                                       //复位完成信号
        end
        else if (data_cnt == DATA_WIDTH*2-1) begin
            finished <= 1'b1;                                       //数据计数器达到15时设置完成信号
        end
        else begin
            finished <= 1'b0;                                       //否则清除完成信号
        end
    end

    //TODO DATA COUNTER

    always @(posedge spi_clkx2 or negedge rst_n) begin
        if (!rst_n) begin
            data_cnt <= 'b0;                           //复位时钟信号和数据计数器
            oi_flag  <= 1'b1;                          //复位奇偶标志
            data_cnt_i <= 'b0;                         //复位数据寄存器
            data_cnt_o <= 'b0;                         //复位数据寄存器
        end
        else if (state == ACTIVE) begin                
            data_cnt <= data_cnt + 1'b1;               //每次时钟翻转时增加数据计数器
            oi_flag  <= ~oi_flag;                      //翻转奇偶标志
            if (oi_flag == 1'b1)
                data_cnt_o <= data_cnt_o + 1'b1;       //每两个时钟翻转时增加数据计数器
            else
                data_cnt_i <= data_cnt_i + 1'b1;       //每两个时钟翻转时增加数据计数器
        end
        else begin
            data_cnt <= 'b0;                           //否则将数据计数器清零
            oi_flag  <= 1'b1;                          //复位奇偶标志
            data_cnt_i <= 'b0;                         //复位数据寄存器
            data_cnt_o <= 'b0;                         //复位数据寄存器
        end
    end

    //TODO STATE MACHINE

    always @(posedge spi_clkx2 or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;                                        
        end
        else begin
            case (state)
                IDLE: begin
                    if (busy) begin
                        state <= ACTIVE;                      
                    end
                end
                ACTIVE: begin
                    if(data_cnt == DATA_WIDTH*2 - 1) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

    //TODO OUTPUT/INPUT LOGIC

    always @(posedge spi_clkx2 or negedge rst_n) begin
        if (!rst_n) begin
            sck_reg  <= MODE[1];
            data_out_reg <= {DATA_WIDTH{1'b0}};                     
            mosi <= 1'b1;
        end
        else if(state == ACTIVE) begin
            sck_reg  <= ~sck_reg;
            case(MODE)
                MODE00,MODE10: begin
                    if(!LSB_FIRST) begin
                        data_out_reg[DATA_WIDTH-1-data_cnt_o] <= miso;//从设备接收数据
                        mosi <= data_in_reg[DATA_WIDTH-1-data_cnt_i];//主设备发送数据
                    end
                    else if(LSB_FIRST) begin
                        data_out_reg[data_cnt_o] <= miso;//从设备接收数据
                        mosi <= data_in_reg[data_cnt_i];//主设备发送数据
                    end
                end
                MODE01,MODE11: begin
                    if(!LSB_FIRST) begin
                        data_out_reg[DATA_WIDTH-1-data_cnt_i] <= miso;//从设备接收数据
                        mosi <= data_in_reg[DATA_WIDTH-1-data_cnt_o];//主设备发送数据
                    end
                    else if(LSB_FIRST) begin
                        data_out_reg[data_cnt_i] <= miso;//从设备接收数据
                        mosi <= data_in_reg[data_cnt_o];//主设备发送数据
                    end
                end
            endcase
        end
        else begin //传输结束，状态复位
            sck_reg  <= MODE[1];
            data_out_reg <= {DATA_WIDTH{1'b0}};                   
            mosi <= 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= {DATA_WIDTH{1'b0}};                           
        end
        else if (finished) begin
            data_out <= data_out_reg;//传输完成时将寄存器数据赋给输出
        end
    end

endmodule
