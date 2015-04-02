// File Name : register.v
// Module Name : register
// It is in the hierarchy of CPU. It contains 8 general purpose registers in the
// register file
// The address range of these registers is 0 - 7
// Data read is done as the combinational logic and will be decoded
// appropriately in ALU
// Data write is properly registered and it always happens a clock after the
// instruction fetch

`include "defines.v"

module register
(
	// Inputs
	clk,
	addr1,
	addr2,
	addr3,
	wen, 
	data_in, 
	
	// Outputs
	data_out1, 
	data_out2 
);

	input 		clk;
	input  [3:0]	addr1; // 4-bit address. 4-th bit is select bit
	input  [3:0]	addr2; // addr1 and addr2 correspond to the operand register address
	input  [3:0]	addr3; // addr3 is the address of the register to be written. Asserted in reg write cycle
	input 		wen;
	input  [`GPR_WIDTH - 1 : 0]   data_in;

	output [`GPR_WIDTH - 1 : 0]   data_out1;
	output [`GPR_WIDTH - 1 : 0]   data_out2;
	
	reg    [`GPR_WIDTH - 1 : 0]   data[`GPR_DEPTH - 1 : 0];
	
	// If MSB of the 4-bit address is 0 choose general register file
	// else the address belongs to peripheral registers
	// ie. the general purpose register range is (0-7)
	// 4'b0000 - 4'b0111 (0-7) 
	
	// data read values of all the registers of all the peripherals and gpr are
	// connected in the top level design
	// The logic is minimized by decoding only using the MSB of the register
	// address bit
	
	assign	data_out1 = ( !addr1[3] ) ? data[addr1] : 8'bzzzzzzzz;
	assign	data_out2 = ( !addr2[3] ) ? data[addr2] : 8'bzzzzzzzz;	
	
	always@(posedge clk)
	begin
		// No reset value for registers as it should be unknown until some
		// valid data will be written into them
		if((wen == 1) && !addr3[3])
			data[addr3]<=data_in;
	end

endmodule
