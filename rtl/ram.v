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

// combinational read for the instruction fetch
wire [ADDR_WIDTH-1:0] ri_address;
assign ri_address = i_address >> 2; // word align the address
assign i_read_data = ram[ri_address[ADDR_WIDTH-1:0]];

// combinational read for the data
wire [ADDR_WIDTH-1:0] rd_address;
assign rd_address = d_address >> 2; // word align the address
assign d_read_data = ram[rd_address[ADDR_WIDTH-1:0]]; // read the word

// write on the pos-edge for the data
always @(posedge clock) begin
	if (wEn) begin
		ram[rd_address[ADDR_WIDTH-1:0]] <= d_write_data;
	end
end

endmodule
