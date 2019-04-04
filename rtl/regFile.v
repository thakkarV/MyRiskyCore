// Vijay Thakkar

module regFile (
	input clock,
	input reset,
	input wEn, // Write Enable
	input [31:0] write_data,
	input [4:0] read_sel1,
	input [4:0] read_sel2,
	input [4:0] write_sel,
	output [31:0] read_data1,
	output [31:0] read_data2
);

reg [31:0] reg_file[0:31];

// reads are combinational for all registers
assign read_data1 = reg_file[read_sel1];
assign read_data2 = reg_file[read_sel2];

// writes on the positive edge
always @(posedge clock) begin
	if (wEn == 1'b1) begin
		// make sure we do not write to zero register (x0)
		if (write_sel == 5'b0) reg_file[0] = 32'b0;
		else reg_file[write_sel] = write_data;
	end
end

always @* begin
	if (reset) begin
		reg_file[00] = 0;
		reg_file[01] = 0;
		reg_file[02] = 0;
		reg_file[03] = 0;
		reg_file[04] = 0;
		reg_file[05] = 0;
		reg_file[06] = 0;
		reg_file[07] = 0;
		reg_file[08] = 0;
		reg_file[09] = 0;
		reg_file[10] = 0;
		reg_file[11] = 0;
		reg_file[12] = 0;
		reg_file[13] = 0;
		reg_file[14] = 0;
		reg_file[15] = 0;
		reg_file[16] = 0;
		reg_file[17] = 0;
		reg_file[18] = 0;
		reg_file[19] = 0;
		reg_file[20] = 0;
		reg_file[21] = 0;
		reg_file[22] = 0;
		reg_file[23] = 0;
		reg_file[24] = 0;
		reg_file[25] = 0;
		reg_file[26] = 0;
		reg_file[27] = 0;
		reg_file[28] = 0;
		reg_file[29] = 0;
		reg_file[30] = 0;
		reg_file[31] = 0;
	end
end

endmodule
