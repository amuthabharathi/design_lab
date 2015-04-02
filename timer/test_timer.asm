;; Test to verify the proper functionality of the timer peripheral
;; Timer is first configured by writing into MAXREG to reduce the range of timer to alter the duty cycle and also the OCMP register to get the proper pwm output
;; Then 7th bit of TMRCON is set which enables the timer
;; hlt instruction stops the CPU from fetching next instructions and till we issue $finish in testbench, the clocks will be running freely and the timer will also be running providing proper overflow and pwm outputs on pins specified

mvi TMRCON 0x01
mvi r2 0x22
mvi MAXREG 0x10
mov r1 MAXREG
mvi OCMP 0x07
mov r1 OCMP
mov r0 TMR
mov r1 TMR
bs TMRCON 7
hlt
