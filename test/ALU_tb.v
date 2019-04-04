// Name: Your Name
// BU ID: Your ID
// EC413 Lab 2 Problem 2: ALU Test Bench

module ALU_tb();

reg [5:0] ctrl;
reg [31:0] opA, opB;

wire [31:0] result;

ALU dut (
	.ALU_Control(ctrl),
	.operand_A(opA),
	.operand_B(opB),
	.ALU_result(result)
);

initial begin
	ctrl = 6'b000000;
	opA = 4;
	opB = 5;
	#20
	$display("ALU Result 4 + 5: %d",result);
	#20
	ctrl = 6'b000010;
	#20
	$display("ALU Result 4 < 5: %d",result);
	#20
	opB = 32'hffffffff;
	#20
	$display("ALU Result 4 < -1: %d",result);
	#20
	ctrl = 6'bb000111;
	opA = 32'hdeadbeef;
	opB = 32'h0000ffff;
	$display("ALU Result 0xDEADBEEF & 0x0000FFFF: %X", result);
	#20
	ctrl = 6'b000100;
	$display("ALU Result 0xDEADBEEF ^ 0x0000FFFF: %X", result);
	#20
	opA = 32'h1;
	opB = 32'hC;
	ctrl = 6'b000010;
	$display("ALU Result 0x1 < 0xC: %X", result);

	#20
	$stop();
end

endmodule
