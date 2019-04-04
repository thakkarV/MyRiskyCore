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

localparam [6:0] R_TYPE = 7'b0110011;
localparam [6:0] I_TYPE = 7'b0010011;
localparam [6:0] S_TYPE = 7'b0100011;
localparam [2:0] ZERO_3 = 3'b000;

wire [6:0] opcode;
wire [6:0] funct7;
wire [2:0] funct3;

wire [11:0] imm12;
wire [11:0] i_imm; // Immidiate for I-Type instructions
wire [11:0] s_imm; // Immidiate for S-Type instructions

assign opcode = instruction[6:0];
assign funct7 = instruction[31:25];
assign funct3 = instruction[14:12];

// Immediate
assign i_imm = instruction[31:20];
assign s_imm = {instruction[31:25], instruction[4:0]};
wire[6:0]  s_imm_msb;
wire[4:0]  s_imm_lsb;
wire[19:0] u_imm;
wire[11:0] i_imm_orig;
wire[19:0] uj_imm;
wire[11:0] s_imm_orig;
wire[12:0] sb_imm_orig;
reg [11:0] imm12_latch;

// static assignments for data buses
assign read_sel1 = instruction[19:15];
assign read_sel2 = instruction[24:20];
assign write_sel = instruction[11:7];

// combinational logic for control buses
reg wb_sel_latch;
reg op_b_sel_latch;
reg [5:0] alu_control_latch;
reg reg_wEn_latch;
reg mem_wEn_latch;

always @* begin
	// ALU compute instruction with 2 RS, 1 RD
	if (opcode == R_TYPE) begin
		wEn <= 1;
		mem_wEn <= 0;
		op_b_sel_latch <= 1;
		wb_sel_latch <= 0;
		imm12_latch <= i_imm;

		// sub or other?
		if (funct7 == 7'b0100000) alu_control_latch <= 6'b_010_000;
		else alu_control_latch <={ZERO_3, funct3};
	end

	// ALU compute with 1 RS and immediate
	else if (opcode == I_TYPE) begin
		wEn <= 1;
		mem_wEn <= 0;
		op_b_sel_latch <= 0;
		alu_control_latch <= {ZERO_3, funct3};
		wb_sel_latch <= 0;
		imm12_latch <= i_imm;
	end

	// load word
	else if (opcode == 7'b0000011) begin
		wEn <= 1;
		mem_wEn <= 0;
		op_b_sel_latch <= 0;
		// for load/store, ALU acts as AGU
		alu_control_latch <= {ZERO_3, funct3};
		wb_sel_latch <= 1;
		imm12_latch <= i_imm;
	end

	// store word
	else if (opcode == S_TYPE) begin
		wEn <= 0;
		mem_wEn <= 1;
		op_b_sel_latch <= 0;
		// for load/store, ALU acts as AGU
		alu_control_latch <= {ZERO_3, funct3};
		wb_sel_latch <= 0;
		imm12_latch <= s_imm;
	end

	// otherwise switch off all control signals
	else begin
		wEn <= 0;
		mem_wEn <= 0;
		op_b_sel_latch <= 0;
		wb_sel_latch <= 0;
	end
end

assign ALU_Control = alu_control_latch;
assign wb_sel = wb_sel_latch;
assign op_B_sel = op_b_sel_latch;
assign wEn = reg_wEn_latch;
assign mem_wEn = mem_wEn_latch;
assign imm12 = imm12_latch;
assign imm32 = { {20{imm12[11]}}, imm12 };
endmodule
