module decode #(
	parameter ADDRESS_BITS = 16
) (
	// Inputs from Fetch
	input [ADDRESS_BITS-1:0] PC,
	input [31:0] instr,

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

localparam [2:0] ZERO_3 = 3'b000;

// These are internal wires that I used. You can use them but you do not have to.
// Wires you do not use can be deleted.
wire[31:0] sb_imm_32;
wire[31:0] u_imm_32;
wire[31:0] i_imm_32;
wire[31:0] s_imm_32;
wire[31:0] uj_imm_32;

wire [1:0] extend_sel;
wire [ADDRESS_BITS-1:0] branch_target;
wire [ADDRESS_BITS-1:0] jal_target;

// static decoding into different fields of all instruction types
// major and minor opcodes
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
reg  [31:0] imm32_reg;

// combinational logic for control buses
reg wb_sel_reg;
reg op_b_sel_reg;
reg [5:0] alu_control_reg;
reg reg_wEn_reg;
reg mem_wEn_reg;
always @* begin
	// ALU compute instr with 2 RS, 1 RD
	if (opcode == R_TYPE) begin
		wEn = 1;
		mem_wEn = 0;
		op_b_sel_reg = 1;
		wb_sel_reg = 0;

		// sub or other?
		if (funct7 == 7'b0100000) alu_control_reg = 6'b_010_000;
		else alu_control_reg = {ZERO_3, funct3};
	end

	// ALU compute with 1 RS and immediate
	else if (opcode == I_TYPE) begin
		wEn = 1;
		mem_wEn = 0;
		op_b_sel_reg = 0;
		alu_control_reg = {ZERO_3, funct3};
		wb_sel_reg = 0;
		imm32_reg = i_imm32;
	end

	// load word
	else if (opcode == LOAD) begin
		wEn = 1;
		mem_wEn = 0;
		op_b_sel_reg = 0;
		// for load/store, ALU acts as AGU
		alu_control_reg = {ZERO_3, funct3};
		wb_sel_reg = 1;
		imm32_reg = i_imm32;
	end

	// store word
	else if (opcode == STORE) begin
		wEn = 0;
		mem_wEn = 1;
		op_b_sel_reg = 0;
		// for load/store, ALU acts as AGU
		alu_control_reg = {ZERO_3, funct3};
		wb_sel_reg = 0;
		imm32_reg = s_imm32;
	end

    // branch instructions
    else if (opcode == BRANCH) begin

    end

    // jal
    else if (opcode == JAL) begin

    end

    // jalr
    else if (opcode == JALR) begin

    end

    // auipc
    else if (opcode == AUIPC) begin

    end

    // lui
    else if (opcode == LUI) begin

    end

	// otherwise switch off all control signals
	else begin
		wEn = 0;
		mem_wEn = 0;
		op_b_sel_reg = 0;
		wb_sel_reg = 0;
	end
end

assign ALU_Control = alu_control_reg;
assign wb_sel = wb_sel_reg;
assign op_B_sel = op_b_sel_reg;
assign wEn = reg_wEn_reg;
assign mem_wEn = mem_wEn_reg;
assign imm32 = imm32_reg;
endmodule
