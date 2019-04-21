module memory_tb();

reg clock;
reg wEn;
reg [15:0] address;
reg [31:0] write_data;

wire [31:0] read_data;

memory uut (
  .clock(clock),
  .wEn(wEn),
  .address(address),
  .write_data(write_data),
  .read_data(read_data)
);

always #5 clock = ~clock;


initial begin
  clock = 1'b1;
  address = 16'd0;
  write_data = 16'd0;
  wEn = 1'b0;

  always #5 clock = ~clock;

task print_state;
  begin
    $display("Time:\t%0d", $time);
    for( x=0; x<32; x=x+1) begin
      $display("Register %d: %h", x, dut.regFile_inst.reg_file[x]);
    end
    $display("--------------------------------------------------------------------------------");
    $display("\n\n");
  end
endtask

initial begin
  clock = 1'b1;
  reset = 1'b1;
  write_data = 0;
  // Make sure the .vmh file is in the same directory that you launched the
  // simulation from.
  $readmemh("./fibonacci.vmh", dut.main_memory.ram);

  // read loaded instruction stream
  #10
  address = 0;
  $display("Address %d: %h", address, read_data);
  #10
  address = 1;
  $display("Address %d: %h", address, read_data);
  #10
  address = 2;
  $display("Address %d: %h", address, read_data);
  #10
  address = 3;
  $display("Address %d: %h", address, read_data);
  #10
  address = 4;
  $display("Address %d: %h", address, read_data);
  #10
  address = 5;
  $display("Address %d: %h", address, read_data);
  #10
  address = 6;
  $display("Address %d: %h", address, read_data);
  #10
  address = 7;
  $display("Address %d: %h", address, read_data);
  #10
  write_data = 1;
  address = 4;
  #10
  $display("Address %d: %h", address, read_data);
  write_data = 2;
  address = 8;
  #10
  $display("Address %d: %h", address, read_data);
  #10
  $stop();

end

endmodule
