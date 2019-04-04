module ALU (
	input branch_op,
	input [5:0]  ALU_Control,
	input [31:0] operand_A,
	input [31:0] operand_B,
	output [31:0] ALU_result,
	output branch
);

reg [31:0] output_reg;
assign [2:0] funct3 = ALU_Control[2:0];

// ALU functions
localparam [2:0]
	FUNCT3_ADD = 3b'000,
	FUNCT3_SLL = 3b'001,
	FUNCT3_SLT = 3b'010,
	FUNCT3_SLTU = 3b'011,
	FUNCT3_XOR = 3b'100,
	FUNCT3_SRL = 3b'101,
	FUNCT3_OR = 3b'110,
	FUNCT3_AND = 3b'111;

// branch compare
localparam [2:0]
	BEQ  = 3b'000,
	BNE  = 3b'001,
	BLT  = 3b'100,
	BGE  = 3b'101,
	BLTU = 3b'110,
	BGEU = 3b'111;

always @* begin

	case (ALU_Control[4:3]) begin
		// add, and, or, xor, logical shifts
		2'b00:
			case (funct3) begin
				FUNCT3_ADD: output_reg <= $signed(operand_A) + $signed(operand_B);
				FUNCT3_SLL: output_reg <= operand_A << operand_B;
				FUNCT3_SLT:
					output_reg <= ($signed(operand_A) < $signed(operand_B)) ?
						32'b1 : 32'b0;
				FUNCT3_SLTU:
					output_reg <= ($unsigned(operand_A) < $unsigned(operand_B)) ?
						32'b1 : 32'b0;
				FUNCT3_XOR: output_reg <= operand_A ^ operand_B;
				FUNCT3_SRL: output_reg <= operand_A >> operand_B;
				FUNCT3_OR:  output_reg <= operand_A | operand_B;
				FUNCT3_AND: output_reg <= operand_A & operand_B;
			endcase

		// arithmetic shifts, sub
		2'b01:

		// branch comparisions
		2'b10:
			case (funct3) begin
			endcase

		// passthrough
		2'b11:
			output_reg <= operand_A;
	endcase
end

assign ALU_result <= output_reg;

endmodule
