module fetch_tb();

parameter ADDRESS_BITS = 16;

reg clock;
reg reset;
reg next_PC_select;
reg [ADDRESS_BITS-1:0] target_PC;
wire [ADDRESS_BITS-1:0] PC;

fetch #(
	.ADDRESS_BITS(ADDRESS_BITS)
) uut (
	.clock(clock),
	.reset(reset),
	.next_PC_select(next_PC_select),
	.target_PC(target_PC),
	.PC(PC)
);

always #5 clock = ~clock;


initial begin
	clock = 1'b1;
	reset = 1'b1;
	next_PC_select = 1'b0;
	target_PC = 16'h0000;

	#1
	#10
	reset = 1'b0;

	#10
	$display("PC: %h", PC);

	next_PC_select = 1;
	target_PC = 16'h0000;
	#10

	next_PC_select = 0;
	#10
	#10
	#10
	#10
	#10
	next_PC_select = 1;
	target_PC = 16'h0100;
	#10
	#10
	next_PC_select = 0;
	#10
	#10
	#10
	#10

	$stop();
end

endmodule
