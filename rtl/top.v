`timescale 1 ns / 1 ps
module top #(
	parameter ADDRESS_BITS = 16
) (
	input clock,
	input reset,
	output [31:0] wb_data
);

// FETCH Wires
wire [ADDRESS_BITS-1:0] pc;
wire [31:0] instruction;

// DECODE wires
// to reg/mem
wire reg_wen;
wire reg_wb_sel;
wire mem_wen;
wire [4:0] reg_read_sel1;
wire [4:0] reg_read_sel2;
wire [4:0] reg_write_sel;
// to alu
wire [31:0] imm32;
wire [5:0] alu_control;
wire [1:0] alu_op_a_sel;
wire alu_op_b_sel;
// to fetch
wire is_decode_branch_instr;
wire next_pc_sel;
wire [ADDRESS_BITS-1:0] fetch_target_pc;

// REG wires
wire [31:0] reg_write_data;
wire [31:0] reg_read_data1;
wire [31:0] reg_read_data2;
wire [31:0] mem_read_data;

// EXECUTION Wires
wire [31:0] alu_op_a;
wire [31:0] alu_op_b;
wire [31:0] alu_result;
wire alu_is_branch_taken;

// MEM wires
//wire [ADDRESS_BITS-1:0] mem_i_address is the same as pc;
//wire [31:0] mem_i_read_data is the same as instruction;
wire [ADDRESS_BITS-1:0] mem_d_address = alu_result[ADDRESS_BITS-1:0];
wire [31:0] mem_d_read_data;
wire [31:0] mem_write_data = reg_read_data2;

// MISC wires
// JALR target address is assigned outside of the ALU because
// ALU output is passing op A (PC + 4) through for writeback to link register
wire [31:0] jalr_target_32 = $signed(reg_read_data1) + $signed(imm32);
wire [ADDRESS_BITS-1:0] jalr_target = jalr_target_32[ADDRESS_BITS-1:0];

// wb_sel is TRUE if we are reading from memory into register
// wb_sel is FALSE if we are writing ALU result to register
assign wb_data = reg_wb_sel == 1'b1 ? mem_d_read_data : alu_result;
assign reg_write_data = wb_data;

fetch #(
	.ADDRESS_BITS(ADDRESS_BITS)
) fetch_inst (
	.clock(clock),
	.reset(reset),
	.next_PC_select(next_pc_sel),
	.target_PC(fetch_target_pc),
	.PC(pc)
);


decode #(
	.ADDRESS_BITS(ADDRESS_BITS)
) decode_unit (
	// Inputs from Fetch
	.PC(pc),
	.instruction(instruction),

	// Inputs from Execute/ALU
	.JALR_target(jalr_target),
	.branch(alu_is_branch_taken),

	// Outputs to Fetch
	.next_PC_select(next_pc_sel),
	.target_PC(fetch_target_pc),

	// Outputs to Reg File
	.read_sel1(reg_read_sel1),
	.read_sel2(reg_read_sel2),
	.write_sel(reg_write_sel),
	.wEn(reg_wen),

	// Outputs to Execute/ALU
	.branch_op(is_decode_branch_instr),
	.imm32(imm32),
	.op_A_sel(alu_op_a_sel),
	.op_B_sel(alu_op_b_sel),
	.ALU_Control(alu_control),

	// Outputs to Memory
	.mem_wEn(mem_wen),

	// Outputs to Writeback
	.wb_sel(reg_wb_sel)
);


regFile regFile_inst (
	.clock(clock),
	.reset(reset),
	.wEn(reg_wen),
	.write_data(reg_write_data),
	.read_sel1(reg_read_sel1),
	.read_sel2(reg_read_sel2),
	.write_sel(reg_write_sel),
	.read_data1(reg_read_data1),
	.read_data2(reg_read_data2)
);

// assign operand A
wire [31:0] pc_32 = {{ADDRESS_BITS{1'b0}}, pc};
assign alu_op_a = (alu_op_a_sel == 2'b00) ? reg_read_data1 :
				  (alu_op_a_sel == 2'b01) ? pc_32 :
				  (alu_op_a_sel == 2'b10) ? (pc_32 + 4) : reg_read_data1;
// assign operand B
assign alu_op_b = (alu_op_b_sel == 1'b_0) ? imm32 : reg_read_data2;
ALU alu_inst(
	.branch_op(is_decode_branch_instr),
	.ALU_Control(alu_control),
	.operand_A(alu_op_a),
	.operand_B(alu_op_b),
	.ALU_result(alu_result),
	.branch(alu_is_branch_taken)
);


ram #(
	.ADDR_WIDTH(ADDRESS_BITS)
) main_memory (
	.clock(clock),

	// Instruction Port
	.i_address(pc),
	.i_read_data(instruction),

	// Data Port
	.wEn(mem_wen),
	.d_address(mem_d_address),
	.d_write_data(mem_write_data),
	.d_read_data(mem_d_read_data)
);

endmodule
