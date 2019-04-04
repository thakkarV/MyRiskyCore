// Name: Your Name
// BU ID: Your ID
// EC413 Lab 3: Memory

module memory (
	input clock,
	input wEn,
	input [15:0] address,
	input [31:0] write_data,
	output [31:0] read_data
);

reg [31:0] mem [(2**14)-1:0]; // 2^16 bytes or 2^14 words of memory

wire [15:0] real_address;
assign real_address = address >> 2;
assign read_data = mem[real_address[13:0]];

always @(posedge clock) begin
	if (wEn) begin
		mem[real_address[13:0]] <= write_data;
	end
end


endmodule
