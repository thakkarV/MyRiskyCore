module ram #(
	parameter DATA_WIDTH = 32,
	parameter ADDR_WIDTH = 16
) (
	input  clock,

	// Instruction Port
	input  [ADDR_WIDTH-1:0] i_address,
	output [DATA_WIDTH-1:0] i_read_data,

	// Data Port
	input  wEn,
	input  [ADDR_WIDTH-1:0] d_address,
	input  [DATA_WIDTH-1:0] d_write_data,
	output [DATA_WIDTH-1:0] d_read_data
);

localparam RAM_DEPTH = 1 << ADDR_WIDTH;
reg [DATA_WIDTH-1:0] ram [0:RAM_DEPTH-1];

// combinational read for instruction fetch
wire [ADDR_WIDTH-1:0] word_aligned_i_addr = i_address >> 2;
assign i_read_data = ram[word_aligned_i_addr];

// combinational read for data
wire [ADDR_WIDTH-1:0] word_aligned_d_addr = d_address >> 2;
assign d_read_data = ram[word_aligned_d_addr];

// write on the pos-edge for the data
always @(posedge clock) begin
	if (wEn) ram[word_aligned_d_addr] <= d_write_data;
end

endmodule
