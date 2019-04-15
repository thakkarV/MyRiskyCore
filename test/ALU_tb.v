module ALU_tb();
reg branch_op;
reg [5:0] ctrl;
reg [31:0] opA, opB;

wire [31:0] result;
wire branch;

ALU dut (
  .branch_op(branch_op),
  .ALU_Control(ctrl),
  .operand_A(opA),
  .operand_B(opB),
  .ALU_result(result),
  .branch(branch)
);

initial begin
  branch_op = 1'b0;
  ctrl = 6'b000000;
  opA = 4;
  opB = 5;

  #10
  $display("ALU Result 4 + 5: %d",result);
  #10
  ctrl = 6'b000010;
  #10
  $display("ALU Result 4 < 5: %d",result);
  #10
  opB = 32'hffffffff;
  #10
  $display("ALU Result 4 < -1: %d",result);

  branch_op = 1'b1;
  opB = 32'hffffffff;
  opA = 32'hffffffff;
  ctrl = 6'b010_000; // BEQ
  #10
  $display("ALU Result (BEQ): %d",result);
  $display("Branch (should be 1): %b", branch);

/******************************************************************************
*                      Add Test Cases Here
******************************************************************************/
  ctrl = 6'b010_001; // BNE
  #10
  $display("ALU Result (BNE): %d",result);
  $display("Branch (should be 0): %b", branch);

  ctrl = 6'b010_100; // BLT
  opA = 4;
  opB = 5;
  #10
  $display("ALU Result (BLT): %d",result);
  $display("Branch (should be 1): %b", branch);

  ctrl = 6'b010_101; // BGE
  #10
  $display("ALU Result (BGE): %d",result);
  $display("Branch (should be 0): %b", branch);

  opB = -5;
  ctrl = 6'b010_110; // BLTU
  #10
  $display("ALU Result (BLTU): %d",result);
  $display("Branch (should be 1): %b", branch);

  opA = 5;
  ctrl = 6'b010_110; // BGEU
  #10
  $display("ALU Result (BGEU): %d",result);
  $display("Branch (should be 1): %b", branch);

  branch_op = 1'b0;
  ctrl = 6'b011_111; // JAL
  #10
  $display("ALU Result (JAL): %d",result); //should be 5

  ctrl = 6'b111_111; // JALR
  #10
  $display("ALU Result (JALR): %d",result); //should be 5

  ctrl = 6'b000_011; // SLTI
  #10
  $display("ALU Result (SLTI): %d",result); //should be 0

  opA = 10;
  opB = 7;
  ctrl = 6'b000_100; // XORI
  #10
  $display("ALU Result (XORI): %d",result); //should be 13

  ctrl = 6'b000_110; // ORI
  #10
  $display("ALU Result (ORI): %d",result); //should be 15

  ctrl = 6'b000_111; // ANDI
  #10
  $display("ALU Result (ANDI): %d",result); //should be 2

  opB = 1;
  ctrl = 6'b000_001; // SLLI
  #10
  $display("ALU Result (SLLI): %d",result); //should be 20

  ctrl = 6'b000_101; // SRLI
  #10
  $display("ALU Result (SRLI): %d",result); //should be 5

  opA = -10;
  ctrl = 6'b001_101; // SRAI
  #10
  $display("ALU Result (SRAI): %d",result); //should be -5

  opA = 10;
  opB = -5;
  ctrl = 6'b001_000; // SUB
  #10
  $display("ALU Result (SUB): %d",result); //should be 15

  ctrl = 6'b000_010; // SLT
  #10
  $display("ALU Result (SLT): %d",result); //should be 0

  ctrl = 6'b000_011; // SLTU
  #10
  $display("ALU Result (SLTU): %d",result); //should be 0
  #10
  $stop();

end

endmodule
