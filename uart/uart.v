// File Name : uart.v
// Module Name: uart_v1
// Description: A UART module implemetation for our custom microprocessor
// Additional Comments: 
// 1.Transmitter working and is synthesizable. increased tx_buff_data to 
//   9-bit format since start bit should be pulled low
// 2.TXC bit will be set in UARTCON register once transmission is
//   complete
//////////////////////////////////////////////////////////////////////////////////
// UART registers:
// 0. UARTCON | tx_en | rx_en | baud_rate| baud_rate | txc | rxc |reserve|reserve 
// 1. UARTTX
// 2. UARTRX
// 3. UARTPIN [7:0] where [3:0] => pin map info
// 		Ex: 00 01 ( tx | rx) go to 0th and 1st pin of o/p
// 			10 11 ( tx | rx) go to 2nd and 3rd pin of o/p
//
// clk freq assumption is 32 Mhz and base rate is 19200
// baud_rate bits | Actual baudrate
// 
//      00		  | 32mhz/1 = 32Mhz
// 	01		  | 38400  32mhz/(2*38400) = 416.667
// 	10		  | 57600  32mhz/(2*57600) = 277.77
// 	11		  | 115200 32mhz/(2*115200)= 138.88

`include "defines.v"

module uart_v1
(
	// Inputs
	clk, 
	rst_n, 
	addr1, 
	addr2, 
	addr3, 
	data_in,
       	wen, 
	rx, 

	// Outputs
	data_out1,
       	data_out2, 
	tx,
	uart_mux
);

	input	[7:0]	data_in; // Data to be written
	input	[3:0]   addr1;
	input	[3:0]   addr2;
	input	[3:0]   addr3;
	input 		wen;
	input 		clk;
	input		rst_n;
	input		rx;
	
	output 		tx;
	output   [7:0]  data_out1;
	output   [7:0]  data_out2;
	output   [7:0]  uart_mux;
	
	wire		tx_en;
	wire		rx_en;
	reg		rxc = 0;
	reg		txc = 0;
	reg	[7:0]	uart_reg [0:3]; // 4 UART registers
	reg	[7:0]	rx_data;
	reg		tx = 1; // Idle mode transmitter pin is always high
	reg	[9:0]	baud_val = 0; // 10-bit value 
	reg		baud_clk = 0;
	reg 	[3:0]	tx_count = 0; //for data transmission
	reg	[3:0]	rx_count = 0;
	reg 		tx_buff_empty; // initial value will be 8'hxxxx 
	reg		rx_buff_empty = 1; 
	reg		rx_start = 0;
	reg	[9:0]   baud;
	reg  	[8:0]   tx_data_buff;
	reg		tx_start;
	
	assign tx_en   = uart_reg[0][7]; // 7th bit of ctl register
	assign rx_en   = uart_reg[0][6]; // 6th bit of ctl register
	
	assign uart_mux = uart_reg[3];
	
	assign read = ( (addr1[3:2] == 2'b11) || (addr2[3:2] == 2'b11)) ;
	assign write = wen & (addr3[3:2] == 2'b11);
	
	assign data_out1 = (read) ? uart_reg[addr1[1:0]] : 8'bzzzzzzzz;
	assign data_out2 = (read) ? uart_reg[addr2[1:0]] : 8'bzzzzzzzz;
	
	
	/**********************************************************************/
	always@(posedge(clk))
	begin
		case( uart_reg[0][5:4] ) // Check baud rate bits of UARTCON register 0
			2'b00: baud_val <= 0; // 0 system clk/2 
			2'b01: baud_val <= 417; // 416.67
			2'b10: baud_val <= 278; // 277.77
			2'b11: baud_val <= 139; // 138.889
		endcase
	end
	/**********************************************************************/
	
	/**********************************************************************/
	
	always@(posedge(clk))
	begin
			if( baud != baud_val && baud_val != 0 )
				baud<=baud+1;
			else 
			begin
				baud 	 <= 0;
				baud_clk <= ~baud_clk;
			end
	
	end
	
	/**********************************************************************/
	always@( posedge(clk) )
	begin
		if(write == 1 && rst_n == 1 )
		begin
			// && addr3[1:0] != 2'b10) // If write is enabled and not UARTRX read-only register is the target 
			case(addr3[1:0])
				2'b00: uart_reg[0] <= data_in ;
				2'b01: uart_reg[1] <= data_in;
				2'b10: ;
				2'b11: uart_reg[3] <= data_in;
			endcase		
	
		end
		if(txc == 1 || rxc == 1)
		begin
			uart_reg[0] <= uart_reg[0] | (txc<<3) | (rxc<<2) ;
		end
		
		else if(rst_n == 0)
		begin
			uart_reg[0] <= 8'h00;//UARTCON
			uart_reg[1] <= 8'h00;//UARTTX
			uart_reg[3] <= 8'b00001011;//UARTPIN
		end
	end
	
	/**********************************************************************/
	
	always@(posedge(tx_en))
	begin
		tx_data_buff[8:1]<= uart_reg[1]; // take the transmission data into buffer
		tx_data_buff[0]<=0; //tx start bit is zero
		tx_start <= 1'b1;
	
	//	tx_buff_empty<=0; // Tx buffer is not empty now
	end
	
	always@(posedge(rxc))
	begin
		uart_reg[2]<=rx_data;
	end
	
	// transmitter module 
	always@(posedge(baud_clk))
	begin
		if( tx_en == 1 && tx_start == 1'b1 && tx_buff_empty == 0 && rst_n == 1 ) 
		begin
			if( tx_count != 9 )
			begin
				tx<=tx_data_buff[tx_count];
				tx_count<=tx_count+1;
				txc<=0;//uart_reg[0][3]<=0; // TXC bit of UARTCON register is 0	
			end
	
			else // If all the 8 bits are transmitted
			begin
				tx_buff_empty<=1; // Set the buffer as empty since all data has gone out
				tx_count<=0;	  // Reset the transmittion bit count
				tx<=1;			  // Pull the transmitter pin high
				txc<=1;//uart_reg[0][3]<= 1;// TXC bit set high
				tx_start <= 1'b0;
			end
		end
		else if( tx_en == 0 && rst_n == 0 ) // if rst_n signal is on, rst_n all variables and pull tx pin high
		begin
			tx_buff_empty<=0;
			tx_count<=0;
			tx<=1;
			txc<=0;//uart_reg[0][3]<= 0;// TXC bit set low
			tx_start <= 1'b0;
		end
	
	//end
	/**********************************************************************/
	
	
	
	//always@(posedge(baud_clk) )
	//begin
	
		if( rx == 0 && rx_start == 0 && rst_n == 1 )  // if rx pin is pulled low and start of reception hasn't commenced yet
		begin
			rx_start<=1;     // trigger reception start
		end
	
		else if( rx_en == 1 && rx_buff_empty == 1 && rx_start == 1 ) // when reception enabled and receive buffer is empty still and reception started
		begin
			if( rx_count != 8 ) // if reception is incomplete
			begin
				//uart_reg[2][rx_count]<=rx;
				rx_data[rx_data]<=rx;
				rx_count<=rx_count+1;
			end
			else			// if reception is complete
			begin
				rx_start<=0; 	  // reception start flag rst_n to zero
				rx_buff_empty<=0; // buff is not empty because it has the latest received value
				rx_count<=0;	  // number of bits received count rst_n to zero
				rxc<=1;//uart_reg[0][2]<=1;// RXC flag to one
			end
		end
		else if( rx_en == 0 || rst_n == 0 )
		begin
			rx_buff_empty<=1;
			rx_count<=0;
			rx_start<=0;
			rxc<=0;
		end
	end

endmodule

