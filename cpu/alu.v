`include "defines.v"

module alu 
(
	// Inputs
	opcode, 
	op_a, 
	op_b, 
	
	// Output
	result
);

	parameter width=8; // 8 bit operand
	
	input 	[7:0]	op_a; // op_a and op_b are the operands of the instructions
	input 	[7:0]	op_b;
	input 	[3:0]	opcode;
	
	// result = op_a operand op_b
	output 	[7:0]	result; // Outcome of the result to be written to register during next clk event.

	reg  	[7:0]	result;
	
	always@(opcode or op_a or op_b)
	begin
		// Actual execution of the instructions
		case(opcode)
			`ADD, `ADDI: result=op_a + op_b; 
			`SUB, `SUBI: result=op_a - op_b;
			`AND: result=op_a&op_b;
			`OR : result=op_a|op_b;
			`NOT: result=~op_a;
			`MOV: result=op_a;
			`MVI: result=op_a;
			`BC : result=op_a&~op_b;
			`BS : result=op_a|op_b;
			default: result=0;			
		endcase
	end

endmodule
