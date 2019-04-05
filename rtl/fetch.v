// Name: Your Name
// BU ID: Your ID
// EC413 Project: Fetch Module

module fetch #(
	parameter ADDRESS_BITS = 16
) (
	input  clock,
	input  reset,
	input  next_PC_select,
	input  [ADDRESS_BITS-1:0] target_PC,
	output [ADDRESS_BITS-1:0] PC
);

reg [ADDRESS_BITS-1:0] pc_reg;
always @(posedge clock) begin
    if (reset) pc_reg = 0;
    else begin
        if (next_PC_select)
            pc_reg = target_PC;
        else
            pc_reg = pc_reg + 4;
    end
end
assign PC = pc_reg;

endmodule
