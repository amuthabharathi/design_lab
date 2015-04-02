// File Name : pmux.v
// Module name : PPS (Peripheral Pin Select)
// It mainly maps the Peripheral outputs to the I/O pin. This has the advantage of being flexible for routing purpose
// PPS module. RA0 to RA3 ports and two output pins of timer for now. One is PWM output and by default routed to RA0 and overflow interrupt output signal routed to RA1 by default
// There are two registers tmr_int_pps_reg and tmr_pwm_pps_reg. We have to write values into these registers to guide the timer outputs into specified ports from ra0 to ra7 respectively. 0x00 means sending the output to ra0..

// ***************************************************************************
//                               |----------|
//                        pwm_out|          |
//                         ----->|          |
//                         ov_int|          |
//                         ----->|Peripheral| porta
//                          tx   |   mux    |<=====>
//                         ----->|          |
//                          rx   |          |
//                         <-----|          |
//                               |----------|
// ***************************************************************************

`include "defines.v"

module pmux
(
	// Inputs
    	clk,
    	rst_n,
    	ov_int,
    	ocmp_out,
    	tmr_mux,
    	tx,
    	uart_mux,
	
	// Inout
    	ra,

	// Output
    	rx
);

 	 input clk;
 	 input rst_n;
 	 input ov_int;
 	 input ocmp_out;
 	 input [7:0] tmr_mux;
 	 input [7:0] uart_mux;
 	 input tx;

 	 inout [3:0] ra;

 	 output rx;

 	 reg [3:0] ra_reg;
 	
	// Outputs coming from peripheral output ports and moving onto the SoC
	// pins
 	 always @*
 	   begin
 	     ra_reg[tmr_mux[1:0]] = ov_int;
 	     ra_reg[tmr_mux[3:2]] = ocmp_out;
 	     ra_reg[uart_mux[3:2]] = tx;
 	   end

	// Assigning the registered outputs
 	 assign ra = ra_reg;

	// Going to rx pin of UART from the assigned SoC port
 	 assign rx = ra[uart_mux[1:0]];
  
endmodule

