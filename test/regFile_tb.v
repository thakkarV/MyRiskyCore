// Name: Your Name
// BU ID: Your ID
// EC413 Lab 2 Problem 1: Register File Test Bench

module regFile_tb();

reg clock, reset, write_enable;
reg [4:0] read_sel1;
reg [4:0] read_sel2;
reg [4:0] write_sel;
wire [31:0] read_data1;
wire [31:0] read_data2;
reg [31:0] write_data;

regFile uut (
	.clock(clock),
	.reset(reset),
	.wEn(write_enable),
	.write_data(write_data),
	.read_sel1(read_sel1),
	.read_sel2(read_sel2),
	.write_sel(write_sel),
	.read_data1(read_data1),
	.read_data2(read_data2)
);

always #5 clock = ~clock;
initial begin
	// reset to clear all to zero
	clock = 1'b1;
	reset = 1'b1;
	read_sel1 = 5'b0;
	read_sel2 = 5'b0;
	write_sel = 5'b0;
	read_data1 = 32'bX;
	read_data2 = 32'bX;
	write_data = 32'bX;
	write_enable = 1'b0;

	#20;
	reset = 1'b0;

	// write one value
	#20;
	write_enable = 1;
	write_sel = 5'b00010;
	write_data = 32'hDEADBEEF;

	// read it back
	#20;
	write_enable = 0;
	read_sel1 = 5'b00010;
	read_sel2 = 5'b00010;

	#20;
	$stop();
end

endmodule
