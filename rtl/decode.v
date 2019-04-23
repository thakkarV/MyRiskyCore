`timescale 1 ns / 1 ps
module decode #(
	parameter ADDRESS_BITS = 16
) (
	// Inputs from Fetch
	input [ADDRESS_BITS-1:0] PC,
	input [31:0] instruction,

	// Inputs from Execute/ALU
	input [ADDRESS_BITS-1:0] JALR_target,
	input branch,

	// Outputs to Fetch
	output next_PC_select,
	output [ADDRESS_BITS-1:0] target_PC,

	// Outputs to Reg File
	output [4:0] read_sel1,
	output [4:0] read_sel2,
	output [4:0] write_sel,
	output wEn,

	// Outputs to Execute/ALU
	output branch_op, // true if branch operation
	output [31:0] imm32,
	output [1:0] op_A_sel,
	output op_B_sel,
	output [5:0] ALU_Control,

	// Outputs to Memory
	output mem_wEn,

	// Outputs to Writeback
	output wb_sel
);

localparam [6:0]
	R_TYPE  = 7'b0110011,
	I_TYPE  = 7'b0010011,
	STORE   = 7'b0100011,
	LOAD    = 7'b0000011,
	BRANCH  = 7'b1100011,
	JALR    = 7'b1100111,
	JAL     = 7'b1101111,
	AUIPC   = 7'b0010111,
	LUI     = 7'b0110111;

// static decoding into different fields of all instruction types
// major and minor opcodes
wire [31:0] instr = instruction;
wire [6:0] opcode = instr[6:0];
wire [6:0] funct7 = instr[31:25];
wire [2:0] funct3 = instr[14:12];

// register selects
assign read_sel1 = instr[19:15];
assign read_sel2 = instr[24:20];
assign write_sel = instr[11:7];

// all immediate types; sign extension always uses instr[31]
wire [31:0] i_imm32 = {{20{instr[31]}}, instr[31:20]};
wire [31:0] s_imm32 = {{20{instr[31]}}, instr[31:25], instr[11:7]};
wire [31:0] b_imm32 = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
wire [31:0] u_imm32 = {instr[31:12], 12'b0};
wire [31:0] j_imm32 = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

// FETCH OUTPUT: PC addresses for branching instructions
// first we calculate the address
// then truncate to the size of the address width
wire [31:0] jal_target_32 =  {{ADDRESS_BITS{1'b0}}, PC} + $signed(j_imm32);
// jalr address is calculated by the toplevel since it needs read_data1
wire [31:0] branch_target_32 = $signed({16'b0, PC}) + $signed(b_imm32);
wire [ADDRESS_BITS-1:0] jal_target = jal_target_32[ADDRESS_BITS-1:0];
wire [ADDRESS_BITS-1:0] jalr_target = JALR_target;
wire [ADDRESS_BITS-1:0] branch_target = branch_target_32[ADDRESS_BITS-1:0];

// UPSTREAM: SET FETCH PC
assign next_PC_select = (((opcode == BRANCH) & (branch == 1)) |
						 (opcode == JAL)                      |
						 (opcode == JALR)
						) ? 1 : 0;

// if branching, set the PC according to the type of branch instruction
// branch target is calculated locally inside the decoder
assign target_PC = ((opcode == BRANCH) & (branch == 1)) ? branch_target :
	// jal target is calculated locally inside the decoder
	(opcode == JAL)  ? jal_target :
	// jalr target is calculated in the top level module
	(opcode == JALR) ? jalr_target : 32'b0;


// DOWNSTREAM: SET CONTROL SIGNALS
assign ALU_Control =
	// Quadrant 2'b00 or 2'b01 : arithmetic
    (opcode == R_TYPE) ? {2'b0, funct7[5], funct3} :
	(opcode == I_TYPE) ?
        // for I type left or right shifts, take care of logical and arithmetic shifts
        ((funct3 == 3'b001) | (funct3 == 3'b101)) ? {2'b0, funct7[5], funct3} :
                                                    {3'b0, funct3}
        :
    // Address generation arithmetic
	((opcode == LOAD) | (opcode == STORE) | (opcode == LUI) | (opcode == AUIPC)) ? 6'b0 :
	(opcode == BRANCH) ? {3'b010, funct3} :
	(opcode == JAL)    ? 6'b011_111       :
	(opcode == JALR)   ? 6'b111_111 : 6'b0;

assign imm32 = (opcode == I_TYPE) ? i_imm32 :
			   (opcode == LOAD)   ? i_imm32 :
			   (opcode == STORE)  ? s_imm32 :
			   (opcode == BRANCH) ? b_imm32 :
			   (opcode == JAL)    ? j_imm32 :
			   (opcode == JALR)   ? i_imm32 :
			   (opcode == AUIPC)  ? u_imm32 :
			   (opcode == LUI)    ? u_imm32 : i_imm32;

assign op_A_sel = ((opcode == JAL) | (opcode == JALR)) ? 2'b10 :
				  (opcode == AUIPC) ? 2'b01 : 2'b00;

assign op_B_sel = ((opcode == R_TYPE) | (opcode == BRANCH)) ? 1 : 0;

assign wEn = ((opcode == R_TYPE) |
              (opcode == I_TYPE) |
              (opcode == LOAD)   |
              (opcode == JALR)   |
              (opcode == JAL)    |
              (opcode == AUIPC)  |
              (opcode == LUI)) ? 1 : 0;

assign mem_wEn   = (opcode == STORE) ? 1 : 0;

assign branch_op = (opcode == BRANCH) ? 1 : 0;

assign wb_sel    = (opcode == LOAD) ? 1 : 0;

endmodule
