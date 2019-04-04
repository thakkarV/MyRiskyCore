// Name: Vijay Thakkar
// BU ID: U23804922

module ALU (
	input [5:0]  ALU_Control,
	input [31:0] operand_A,
	input [31:0] operand_B,
	output [31:0] ALU_result
);

/* Instructions:
	inst   => opcode

	add(i) => 6'b000000
	sub    => 6'b001000
	slt    => 6'b000010
	xor    => 6'b000100
	and    => 6'b000111
*/
reg [31:0] output_reg;
always @* begin
	case (ALU_Control)
		// add
		6'b000000: output_reg <= $signed(operand_A) + $signed(operand_B);

		// sub
		6'b001000: output_reg <= $signed(operand_A) - $signed(operand_B);

		// slt
		6'b000010: output_reg <= ($signed(operand_A) < $signed(operand_B)) ? 32'b1 : 32'b0;

		// xor
		6'b000100: output_reg <= operand_A ^ operand_B;

		// and
		6'b000111: output_reg <= operand_A & operand_B;
	endcase
end

assign ALU_result = output_reg;

endmodule
