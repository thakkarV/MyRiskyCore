module ram_tb();

parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 16;

reg  clock;

// Instruction Port
reg  [ADDR_WIDTH-1:0] i_address;
wire [DATA_WIDTH-1:0] i_read_data;

// Data Port
reg  wEn;
reg  [ADDR_WIDTH-1:0] d_address;
reg  [DATA_WIDTH-1:0] d_write_data;
wire [DATA_WIDTH-1:0] d_read_data;


ram #(
  .DATA_WIDTH(DATA_WIDTH),
  .ADDR_WIDTH(ADDR_WIDTH)
) uut (
  .clock(clock),

  // Instruction Port
  .i_address(i_address),
  .i_read_data(i_read_data),

  // Data Port
  .wEn(wEn),
  .d_address(d_address),
  .d_write_data(d_write_data),
  .d_read_data(d_read_data)

);

always #5 clock = ~clock;

initial begin
	clock = 1;
	i_address = 32'h134;
	wEn = 1'b0;

	//  $readmemh("/home/void/Desktop/ClassStuff/MyRiskyCore/test/fibonacci.vmh", uut.memory);
	$readmemh("/home/void/Desktop/ClassStuff/MyRiskyCore/test/gcd.vmh", uut.ram);

	// read loaded instruction stream
	#10
	d_address = 0;
	$display("d_address %d: %h", d_address, d_read_data);
	#10
	d_address = 1;
	$display("d_address %d: %h", d_address, d_read_data);
	#10
	d_address = 2;
	$display("d_address %d: %h", d_address, d_read_data);
	#10
	d_address = 3;
	$display("d_address %d: %h", d_address, d_read_data);
	#10
	d_address = 4;
	$display("d_address %d: %h", d_address, d_read_data);
	#10
	d_address = 5;
	$display("d_address %d: %h", d_address, d_read_data);
	#10
	d_address = 6;
	$display("d_address %d: %h", d_address, d_read_data);
	#10
	d_address = 7;
	$display("d_address %d: %h", d_address, d_read_data);
	#10
    d_address = 8;
	$display("d_address %d: %h", d_address, d_read_data);
	#10
    d_address = 12;
	$display("d_address %d: %h", d_address, d_read_data);
	#10
    d_address = 16;
	$display("d_address %d: %h", d_address, d_read_data);
	#10
    d_address = 20;
	$display("d_address %d: %h", d_address, d_read_data);
	#10
	d_write_data = 32'hDEADBEEF;
	d_address = 4;
	#10
	$display("d_address %d: %h", d_address, d_read_data);
	wEn = 1;
	d_write_data = -1;
	d_address = 8;
	#10
	$display("d_address %d: %h", d_address, d_read_data);
	#10
	$stop();

end

endmodule
