// File Name : soc_top.v
// Module Name : soc_top
// This is the top level design module which integrates a processor and
// a peripheral mux and two peripherals timer and uart

// ***************************************************************************
// 			--------------------------------------
// 			|              soc_top               |
// 			|                                    |
// 			|    ------    --------           |  |
// 			|   |      |  |        |        / |  |
// 			|   |      |==|  Timer |====> |   |  |
// 			|   |      |  |        |      |   |  |
// 	    Instructions|   |      |   --------       | P |  |porta
// 	    ===========>|===| CPU  |   --------       | M |= |<====>
// 			|   |      |  |        |      | U |  |
// 			|   |      |==|  UART  |<===> | X |  |
// 			|   |      |  |        |      |   |  |
// 			|    ------    -------          \ |  |
// 			|                                    |
// 			|                                    |
// 			--------------------------------------
// ***************************************************************************
`include "defines.v"

module soc_top(clk, rst_n, porta, ins_out, pc);

input clk;
input rst_n;
inout [3:0] porta;
input [15:0] ins_out;
output [6:0] pc;

wire [3:0] addr1, addr2, addr3;
wire wen;
wire [7:0] reg_a, reg_b, data_out;
wire [7:0] tmr_mux;
wire [7:0] uart_mux;

cpu_8bit cpu( .clk(clk), .rst_n(rst_n), .addr1(addr1), .addr2(addr2), .addr3(addr3), .wen(wen), .reg_a(reg_a), .reg_b(reg_b), .data_out(data_out), .ins_out(ins_out), .pc(pc));

tmr_8bit timer( .clk(clk), .rst_n(rst_n), .addr1(addr1), .addr2(addr2), .addr3(addr3), .wen(wen), .data_out1(reg_a), .data_out2(reg_b), .data_in(data_out), .ov_int(ov_int), .ocmp_out(ocmp_out), .tmr_mux(tmr_mux) );
 
uart_v1 uart( .clk(clk), .rst_n(rst_n), .addr1(addr1), .addr2(addr2), .addr3(addr3), .wen(wen), .data_out1(reg_a), .data_out2(reg_b), .data_in(data_out), .rx(rx), .tx(tx), .uart_mux(uart_mux) );

pmux peripheral_mux( .clk(clk), .rst_n(rst_n), .tmr_mux(tmr_mux), .ov_int(ov_int), .ocmp_out(ocmp_out), .uart_mux(uart_mux), .rx(rx), .tx(tx), .ra(porta) );

endmodule
