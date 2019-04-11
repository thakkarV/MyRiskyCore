module ALU (
	input branch_op,
	input [5:0]  ALU_Control,
	input [31:0] operand_A,
	input [31:0] operand_B,
	output [31:0] ALU_result,
	output branch
);

reg [31:0] output_reg;
reg branch_reg;

wire [2:0] funct3;
assign funct3 = ALU_Control[2:0];

// ALU functions
localparam [2:0]
    FUNCT3_ADD  = 3'b000,
    FUNCT3_SHL  = 3'b001,
    FUNCT3_SLT  = 3'b010,
    FUNCT3_SLTU = 3'b011,
    FUNCT3_XOR  = 3'b100,
    FUNCT3_SHR  = 3'b101,
    FUNCT3_OR   = 3'b110,
    FUNCT3_AND  = 3'b111;

// branch compare
localparam [2:0]
    FUNCT3_BEQ  = 3'b000,
    FUNCT3_BNE  = 3'b001,
    FUNCT3_BLT  = 3'b100,
    FUNCT3_BGE  = 3'b101,
    FUNCT3_BLTU = 3'b110,
    FUNCT3_BGEU = 3'b111;

// comparators
reg alu_eq, alu_lts, alu_ltu;
always @* begin
    alu_eq  = operand_A == operand_B;
    alu_lts = $signed(operand_A) < $signed(operand_B);
    alu_ltu = operand_A < operand_B;
end

always @* begin
	case (ALU_Control[4:3])
		// add, and, or, xor, logical shifts
		2'b00: begin
			case (funct3)
				FUNCT3_ADD: output_reg = $signed(operand_A) + $signed(operand_B);
                // for 2'b00 SHL is a logical shift left
                FUNCT3_SHL: output_reg = operand_A << operand_B;
				FUNCT3_SLT: output_reg = {31'b0, alu_lts};
				FUNCT3_SLTU: output_reg = {31'b0, alu_ltu};
				FUNCT3_XOR: output_reg = operand_A ^ operand_B;
                // for 2'b00 SHR is a logical shift right
				FUNCT3_SHR: output_reg = operand_A >> operand_B;
				FUNCT3_OR:  output_reg = operand_A | operand_B;
				FUNCT3_AND: output_reg = operand_A & operand_B;
			endcase
            branch_reg = 0;
        end

		// arithmetic shifts, sub
		2'b01: begin
            /* verilator lint_off CASEINCOMPLETE */
            case (funct3)
				FUNCT3_ADD: output_reg = $signed(operand_A) - $signed(operand_B);

                // for 2'b01 SHL is an airthmetic shift left
                FUNCT3_SHL: output_reg = $signed(operand_A) <<< $signed(operand_B);

                // for 2'b01 SHR is an airthmetic shift right
				FUNCT3_SHR: output_reg = $signed(operand_A) >>> $signed(operand_B);
			endcase
            branch_reg = 0;
        end

		// branch comparisions
		2'b10: begin
            /* verilator lint_off CASEINCOMPLETE */
			case (funct3)
                FUNCT3_BEQ:  branch_reg = alu_eq;
                FUNCT3_BNE:  branch_reg = !alu_eq;
                FUNCT3_BLT:  branch_reg = alu_lts;
                FUNCT3_BGE:  branch_reg = !alu_lts;
                FUNCT3_BLTU: branch_reg = alu_ltu;
                FUNCT3_BGEU: branch_reg = !alu_ltu;
			endcase
            output_reg = 32'b0;
        end

		// jal/jalr, passthrough op A
		2'b11: begin
            branch_reg = 1;
            output_reg = $signed(operand_A) + $signed(operand_B);
        end
	endcase
end

assign branch = branch_reg;
assign ALU_result = output_reg;

endmodule
