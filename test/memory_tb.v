// Name: Your Name
// BU ID: Your ID
// EC413 Lab 3: Memory Test Bench

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

  #1
  #10
  wEn = 1'b1;
  #10
  $display("Address %d: %h", address, read_data);
  write_data = 1;
  address = 4;
  #10
  $display("Address %d: %h", address, read_data);
  write_data = 2;
  address = 8;
  #10
  $display("Address %d: %h", address, read_data);



  /***************************
  * Add more test cases here *
  ***************************/


  #100
  $stop();

end

endmodule
