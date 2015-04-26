`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:04:10 04/26/2015
// Design Name:   uart_v1
// Module Name:   /home/bharathi/fpga_projects/uart/uart_tb.v
// Project Name:  uart
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: uart_v1
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module uart_tb;

	// Inputs
	reg clk;
	reg rst_n;
	reg [3:0] addr1;
	reg [3:0] addr2;
	reg [3:0] addr3;
	reg [7:0] data_in;
	reg wen;
	reg rx;

	// Outputs
	wire [7:0] data_out1;
	wire [7:0] data_out2;
	wire tx;
	wire [7:0] uart_mux;

	// Instantiate the Unit Under Test (UUT)
	uart_v1 uut (
		.clk(clk), 
		.rst_n(rst_n), 
		.addr1(addr1), 
		.addr2(addr2), 
		.addr3(addr3), 
		.data_in(data_in), 
		.wen(wen), 
		.rx(rx), 
		.data_out1(data_out1), 
		.data_out2(data_out2), 
		.tx(tx), 
		.uart_mux(uart_mux)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst_n = 1;
		addr1 = 0;
		addr2 = 0;
		addr3 = 0;
		data_in = 0;
		wen = 0;
		rx = 0;

		// Wait 100 ns for global reset to finish
		#10;
        
		// Add stimulus here
		#10 addr3   =4'b1101;
			 data_in =17;
		
		#1	 wen =1;
		#10 wen =0;
		
		#10 addr3   =4'b1100;
			 data_in =128;
		
		#1  wen =1;
		#10 wen =0;
		
		

	end

always #1 clk=~clk;
      
endmodule

