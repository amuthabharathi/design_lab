;; Test to verify the proper functionality of the UART adn TIMER peripheral
;; Timer is first configured by writing into MAXREG to reduce the range of timer to alter the duty cycle and also the OCMP register to get the proper pwm output
;; Then 7th bit of TMRCON is set which enables the timer
;; UARTTX register is written a value 01110111 (0x77) to be transmitted
;; 7th bit (TXEN) of UARTCON is set which enables Transmitter
;; hlt instruction stops the CPU from fetching next instructions and till we issue $finish in testbench, the clocks will be running freely and the timer will also be running providing proper overflow and pwm outputs on pins specified

mvi TMRCON 0x01
mvi r2 0x22
mvi MAXREG 0x10
mov r1 MAXREG
mvi OCMP 0x07
mov r1 OCMP
mov r0 TMR
mov r1 TMR
mvi UARTTX 0x77
bs UARTCON 7
hlt
