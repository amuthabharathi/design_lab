// Author : Kiran A G
// Module name : tmr_8bit
// The module is an 8-bit timer which increments on every clock edge event.
// There is clock gating. Hence the clock division for the timer module take place only when the timer is enabled. This reduces power consumption
// The timer supports prescalar which is two bits in the TMRCON register and on writing a value to it, the timer starts incrementing on the prescaled clock events
// Any arbitrary value can be written into the timer register and it resumes incrementing from that value from the next clock event
// It supports PWM mode of operation where in, it provides output on every register match
// On overflow, it gives out an interrupt. The PWM output and the overflow interrupt output can be routed to any of the 8 pins through the PPS module
// ***************************************************************************
//                               |-------|
//                         rst_n |       |pwm_out
//                         ----->|       |----->
//                               | timer |
//                          clk  |       |ov_int
//                         ----->|       |----->
//                               |       |
//                               |-------|
// ***************************************************************************
 
`include "defines.v"

module tmr_8bit
(
	// Inputs
   	 data_in,
   	 addr1,
   	 addr2,
   	 addr3,
   	 wen,
   	 clk,
   	 rst_n,

	// Outputs
   	 data_out1,
   	 data_out2,
   	 ov_int,
   	 ocmp_out,
   	 tmr_mux
);
 
    	input [7:0] data_in;
    	input [3:0] addr1;
    	input [3:0] addr2;
    	input [3:0] addr3;
    	input wen;
    	input clk;
    	input rst_n;

    	output [7:0] data_out1;
    	output [7:0] data_out2;
    	output reg ov_int;
    	output ocmp_out;
    	output [7:0] tmr_mux;
 
  	reg [7:0] tmr_reg [3:0];
  	wire [1:0] tmr_prescalar;
  	reg clk_by_2;
  	reg clk_by_4;
  	reg clk_by_8;
  	reg tmrclk;
  	wire tmron;
  	wire interrupt;
  	wire write;
  	wire read;

  	assign write = wen& (addr3[3:2] == 2'b10);
  	assign read = ( (addr1[3:2] == 2'b10) || (addr2[3:2] == 2'b10)) ;
  	assign tmr_mux = tmr_reg[2];

  	assign data_out1 = (read) ? tmr_reg[addr1[1:0]] : 8'bzzzzzzzz;
  	assign data_out2 = (read) ? tmr_reg[addr2[1:0]] : 8'bzzzzzzzz;

	// Commenting for the purpose of synthesizing
	// Timer increment operation
	/*  always @ (posedge tmrclk or negedge rst_n)
	    begin
	      if (rst_n == 1'b0)
	        tmr_reg[0] <= 8'h00;
	      else if(tmr_reg[0] == tmr_reg[3])
		tmr_reg[0] <= 8'h00;
	      else if (tmron)
	        tmr_reg[0] <= tmr_reg[0] + 8'h01;
	    end	*/
	  
	  // Register access
	  always @ (posedge tmrclk or negedge rst_n)
	    begin
	      if(rst_n == 1'b0)
	        begin
	          tmr_reg[0] <= 8'h00;
	          tmr_reg[1] <= 8'h00;
	          tmr_reg[2] <= 8'h04;
		  tmr_reg[3] <= 8'hFF;
	        end
	      else if(write)
		tmr_reg[addr3[1:0]] <= data_in;
	      else if(tmr_reg[0] == tmr_reg[3])
		tmr_reg[0] <= 8'h00;
	      else if (tmron)
	        tmr_reg[0] <= tmr_reg[0] + 8'h01;
	    end
	  
	  assign tmron = tmr_reg[2][7];
	  assign tmr_prescalar = tmr_reg[2][6:5];
	  
	  always@*
	    case(tmr_prescalar)
	        2'b00 : tmrclk <= clk;
	        2'b01 : tmrclk <= clk_by_2;
	        2'b10 : tmrclk <= clk_by_4;
	        2'b11 : tmrclk <= clk_by_4;
	    endcase
	  
	  // Clock divider for prescalar  
	  always @(posedge clk or negedge rst_n)
	    if (rst_n == 1'b0) clk_by_2 <= 1'b0;
	    else if (tmron) clk_by_2 <= ~clk_by_2;
	  
	  always @(posedge clk_by_2 or negedge rst_n)
	    if (rst_n == 1'b0) clk_by_4 <= 1'b0;
	    else if (tmron) clk_by_4 <= ~clk_by_4;
	  
	  always @(posedge clk_by_4 or negedge rst_n)
	    if (rst_n == 1'b0) clk_by_8 <= 1'b0;
	    else if (tmron) clk_by_8 <= ~clk_by_8;
	  
	  // Code for PWM generation  
	  assign ocmp_out = (tmr_reg[0] == tmr_reg[1]);
	  
	  // Overflow interrupt generation  
	  assign interrupt = (tmr_reg[0] == tmr_reg[3]);
	  
	  always @(posedge clk)
	    ov_int <= interrupt;  
  
endmodule

