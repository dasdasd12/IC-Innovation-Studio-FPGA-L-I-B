module IIC_tb();

reg clk;
reg rst_n;

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    rst_n = 0;
    #20;
    rst_n = 1;
end

// output declaration of module IIC_ctrl
wire i2c_clk;
wire i2c_end;
wire [7:0] rd_data;
wire i2c_scl;
wire i2c_sda;
wire wr_en;
wire rd_en;
wire i2c_start;
wire [7:0] addr_num;
wire [7:0] byte_addr;
wire [7:0] wr_data;

IIC_ctrl #(
    .DEVICE_ADDR  	(1111_000     ),
    .SYS_CLK_FREQ 	(100_000_000  ),
    .SCL_FREQ     	(250_000      )
)
u_IIC_ctrl(
    .sys_clk   	(clk    ),
    .sys_rst_n 	(rst_n  ),
    .wr_en     	(wr_en      ),
    .rd_en     	(rd_en      ),
    .i2c_start 	(i2c_start  ),
    .addr_num  	(addr_num   ),
    .byte_addr 	(byte_addr  ),
    .wr_data   	(wr_data    ),
    .i2c_clk   	(i2c_clk    ),
    .i2c_end   	(i2c_end    ),
    .rd_data   	(rd_data    ),
    .i2c_scl   	(i2c_scl    ),
    .i2c_sda   	(i2c_sda    )
);

initial begin
    $dumpfile("icarus/iic_sim.vcd");
    $dumpvars(0, IIC_tb);
    #2000 $finish();
end

task write_one_byte(
    output wr_en,
    output [7:0] byte_addr,
    output [7:0] wr_data,
    output i2c_start,
    output addr_num
)

endmodule