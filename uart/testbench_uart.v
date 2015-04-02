// Top testbench module which instantiates the top level design
// clk and rst_n are the main inputs to the SoC and these are generated here
// This takes in .mem opcode file and reads in a two dimensional array,
// instruction and that will be connected and sent to CPU module which takes
// in during the instruction fetch phase one by one based on the memory
// address.

`include "defines.v"
module soc_top_tb;

	reg clk;
	reg rst_n;
	reg [15:0] instruction [0:127];
	wire [3:0] porta;
	reg [15:0] data_out;
	wire [6:0] addr;
	reg [7:0] tmr;

	integer success_count, error_count;

	// Instantiate the Unit Under Test (UUT)
	soc_top soc (
		.clk(clk), 
		.rst_n(rst_n),
		.porta(porta),
		.ins_out(data_out),
		.pc(addr)
	);

	initial begin
		success_count = 0;
		error_count = 0;
		$readmemb("test.mem",instruction);
		// Initialize Inputs
		clk = 0;
		rst_n = 1;

		// Wait 100 ns for global reset to finish
		#10;
        
		// Add stimulus here
		
		
		#20 rst_n=0;
		#10 rst_n=1;
		$display("========================================");
		$display("Success_count = %d",success_count);
		$display("Error_count = %d",error_count);
		$display("========================================");
		#160 $finish;
		

	end

	always @(posedge clk)
	begin
		data_out = instruction[addr];
	end

	always @(posedge clk or negedge rst_n)
	begin
		if(rst_n == 1'b0)
			tmr <= 8'h00;
		else if (tmr == `TIMER.tmr_reg[3])
			tmr <= 8'h00;
		else if (`TIMER.tmr_reg[2][7] == 1'b1)
			tmr <= tmr + 1'b1;
	end

	always @(posedge clk)
	begin
		if(`TIMER.tmr_reg[0] === tmr)
			success_count = success_count + 1;
		else
			error_count = error_count + 1;
	end
      
	always #1 clk=~clk;
endmodule

