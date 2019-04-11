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

// combinational logic for control buses
reg [5:0] alu_control_reg;
reg [1:0] alu_op_a_sel_reg;
reg alu_op_b_sel_reg;
reg branch_op_reg;
reg  [31:0] imm32_reg;
reg reg_wEn_reg;
reg mem_wEn_reg;
reg wb_sel_reg;

reg next_pc_select_reg;
reg [ADDRESS_BITS-1:0] target_pc_reg;
reg [31:0] branch_target;

always @* begin
    // set fetch for next cycle
    if (branch) begin
        next_pc_select_reg = 1;
        if (opcode == BRANCH) begin
            branch_target = {16'b0, PC} + b_imm32;
            target_pc_reg = branch_target[ADDRESS_BITS-1:0];
        end
        else if (opcode == JAL || opcode == JALR) begin
            target_pc_reg = JALR_target;
        end
    end
    else begin
        next_pc_select_reg = 0;
        target_pc_reg = 0;
    end

    // decode and set control signals
	// ALU compute instr with 2 RS, 1 RD
	if (opcode == R_TYPE) begin
        // sub or other?
		if (funct7 == 7'b0100000) alu_control_reg = 6'b_010_000;
		else alu_control_reg = {ZERO_3, funct3};
		alu_op_a_sel_reg = 2'b0;
		alu_op_b_sel_reg = 1;
        branch_op_reg = 0;
		reg_wEn_reg = 1;
        mem_wEn_reg = 0;
		wb_sel_reg = 0;
	end

	// ALU compute with 1 RS and immediate
	else if (opcode == I_TYPE) begin
		alu_control_reg = {ZERO_3, funct3};
        alu_op_a_sel_reg = 2'b0;
		alu_op_b_sel_reg = 0;
        branch_op_reg = 0;
		imm32_reg = i_imm32;
		reg_wEn_reg = 1;
        mem_wEn_reg = 0;
		wb_sel_reg = 0;
	end

	// load word
	else if (opcode == LOAD) begin
		// for load/store, ALU acts as AGU
		alu_control_reg = {ZERO_3, funct3};
        alu_op_a_sel_reg = 2'b0;
		alu_op_b_sel_reg = 0;
        branch_op_reg = 0;
		imm32_reg = i_imm32;
		reg_wEn_reg = 1;
        mem_wEn_reg = 0;
		wb_sel_reg = 1;
	end

	// store word
	else if (opcode == STORE) begin
		// for load/store, ALU acts as AGU
		alu_control_reg = {ZERO_3, funct3};
        alu_op_a_sel_reg = 2'b0;
		alu_op_b_sel_reg = 0;
        branch_op_reg = 0;
		imm32_reg = s_imm32;
		reg_wEn_reg = 0;
        mem_wEn_reg = 1;
		wb_sel_reg = 0;
	end

    // branch instructions
    else if (opcode == BRANCH) begin
        alu_control_reg = {3'b010, funct3};
        alu_op_a_sel_reg = 2'b0;
		alu_op_b_sel_reg = 1;
        branch_op_reg = 1;
        imm32_reg = b_imm32;
        reg_wEn_reg = 0;
        mem_wEn_reg = 0;
        wb_sel_reg = 0;
    end

    // jal
    else if (opcode == JAL) begin
        alu_control_reg = 6'b011_111;
		alu_op_a_sel_reg = 2'b10;
		alu_op_b_sel_reg = 0;
        branch_op_reg = 1;
        imm32_reg = j_imm32;
        reg_wEn_reg = 0;
        mem_wEn_reg = 0;
        wb_sel_reg = 0;
    end

    // jalr
    else if (opcode == JALR) begin
        alu_control_reg = 6'b111_111;
		alu_op_a_sel_reg = 2'b10;
		alu_op_b_sel_reg = 0;
        branch_op_reg = 1;
        imm32_reg = i_imm32;
        reg_wEn_reg = 1;
        mem_wEn_reg = 0;
        wb_sel_reg = 0;
    end

    // auipc
    else if (opcode == AUIPC) begin
        alu_control_reg = 6'b000_000;
		alu_op_a_sel_reg = 2'b01;
		alu_op_b_sel_reg = 1;
        branch_op_reg = 0;
        imm32_reg = u_imm32;
        reg_wEn_reg = 1;
        mem_wEn_reg = 0;
        wb_sel_reg = 0;
    end

    // lui
    else if (opcode == LUI) begin
        alu_control_reg = 6'b000_000;
		alu_op_a_sel_reg = 2'b0;
		alu_op_b_sel_reg = 1;
        branch_op_reg = 0;
        imm32_reg = u_imm32;
        reg_wEn_reg = 1;
        mem_wEn_reg = 0;
        wb_sel_reg = 0;
    end

	// otherwise switch off all control signals, nop
	else begin
        alu_control_reg = 6'b0;
        alu_op_a_sel_reg = 2'b0;
		alu_op_b_sel_reg = 0;
        branch_op_reg = 0;
		reg_wEn_reg = 0;
        mem_wEn_reg = 0;
		wb_sel_reg = 0;
	end
end

// assign downstream control wires
assign ALU_Control = alu_control_reg;
assign op_A_sel = alu_op_a_sel_reg;
assign op_B_sel = alu_op_b_sel_reg;
assign branch_op = branch_op_reg;
assign imm32 = imm32_reg;
assign wEn = reg_wEn_reg;
assign mem_wEn = mem_wEn_reg;
assign wb_sel = wb_sel_reg;

// assign upstream fetch wires
assign next_PC_select = next_pc_select_reg;
assign target_PC = target_pc_reg;
endmodule
