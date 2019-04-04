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

reg [ADDRESS_BITS-1:0] PC_reg;

assign PC = PC_reg;

/******************************************************************************
*                      Start Your Code Here
******************************************************************************/

endmodule
