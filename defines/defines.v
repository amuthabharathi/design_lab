// These are the general defines referenced by all the modules of the SoC
`timescale 1ns / 1ps

// Opcodes for the instructions
`define NOP   4'b0000
`define ADD   4'b0001
`define ADDI  4'b0010
`define SUB   4'b0011
`define SUBI  4'b0100
`define AND   4'b0101
`define OR    4'b0110
`define NOT   4'b0111
`define MOV   4'b1000
`define MVI   4'b1001
`define BC    4'b1010
`define BS    4'b1011
`define HLT   4'b1111

// Peripheral register addresses
`define TMR 	4'h8
`define OCMP 	4'h9
`define TMRCON 	4'hA
`define MAXREG 	4'hB
`define UARTCON 4'hC
`define UARTTX	4'hD
`define UARTRX	4'hE
`define UARTPIN	4'hF
// Address bus dimensions
`define INSTR_WIDTH 16
`define INSTR_DEPTH 128

// Data bus dimensions
`define GPR_WIDTH 8
`define GPR_DEPTH 8

// Module hierarchy defines
`define SOC_TOP soc
`define TIMER `SOC_TOP.timer
`define CPU `SOC_TOP.cpu
`define GPR `CPU.gpr
