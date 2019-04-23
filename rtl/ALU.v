`timescale 1 ns / 1 ps
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

wire [2:0] funct3    = ALU_Control[2:0];
wire [1:0] alu_block = ALU_Control[4:3];
wire [4:0] shift_val = operand_B[4:0];

// ALU Quadrants
localparam [1:0]
    ALU_BLOCK0 = 2'b00,
    ALU_BLOCK1 = 2'b01,
    ALU_BLOCK2 = 2'b10,
    ALU_BLOCK3 = 2'b11;

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
wire alu_eq  = operand_A == operand_B;
wire alu_neq = ~alu_eq;
wire alu_lts = $signed(operand_A) < $signed(operand_B);
wire alu_ges = ~alu_lts;
wire alu_ltu = $unsigned(operand_A) < $unsigned(operand_B);
wire alu_geu = ~alu_ltu;

// add, and, or, xor, logical shifts
wire [31:0] alu_b0_result =
        (funct3 == FUNCT3_ADD)  ? $signed(operand_A) + $signed(operand_B) :
        (funct3 == FUNCT3_SHL)  ? operand_A << operand_B :
        (funct3 == FUNCT3_SLT)  ? {31'b0, alu_lts} :
        (funct3 == FUNCT3_SLTU) ? {31'b0, alu_ltu} :
        (funct3 == FUNCT3_XOR)  ? operand_A ^ operand_B :
        (funct3 == FUNCT3_SHR)  ? operand_A >> shift_val :
        (funct3 == FUNCT3_OR)   ? operand_A | operand_B :
        /* funct3 == FUNCT3_AND */operand_A & operand_B;

// arithmetic shifts, sub
wire [31:0] alu_b1_result =
    (funct3 == FUNCT3_ADD) ? $signed(operand_A)  -  $signed(operand_B) :
    // for 2'b01 SHL is an airthmetic shift left
    (funct3 == FUNCT3_SHL) ? $signed(operand_A) <<< $signed(shift_val) :
    // for 2'b01 SHR is an airthmetic shift right
    (funct3 == FUNCT3_SHR) ? $signed(operand_A) >>> $signed(shift_val) :
    /* should never get here, illegal */ 32'b0;

    // branch comparisions
wire [31:0] alu_b2_result =
        (funct3 == FUNCT3_BEQ)  ? {31'b0, alu_eq}  :
        (funct3 == FUNCT3_BNE)  ? {31'b0, alu_neq} :
        (funct3 == FUNCT3_BLT)  ? {31'b0, alu_lts} :
        (funct3 == FUNCT3_BGE)  ? {31'b0, alu_ges} :
        (funct3 == FUNCT3_BLTU) ? {31'b0, alu_ltu} :
        /* (funct3 == FUNCT3_BGEU) */ {31'b0, alu_geu};

// jal/jalr, pass-through op A for write back, which is set to PC + 4
wire [31:0] alu_b3_result = operand_A;

assign ALU_result =
    (alu_block == ALU_BLOCK0) ? alu_b0_result :
    (alu_block == ALU_BLOCK1) ? alu_b1_result :
    (alu_block == ALU_BLOCK2) ? alu_b2_result : alu_b3_result;

assign branch = (alu_block == ALU_BLOCK2) ? alu_b3_result[0] : 0;

endmodule
