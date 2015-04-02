;; Test to verify the proper functionality of the peripheral port muxing
;; The corresponding port bits of each of the peripherals are present in the control registers of the peripherals
;; Timer has two outputs ov_int and pwm_out
;; Here are the control register configurations for the peripheral outputs
;; tmr->ov_int ----> TMRCON[1:0]
;; tmr->ocmp_out ---> TMRCON[3:2]
;; uart->rx ---> UARTCON[1:0]
;; uart->tx ---> UARTCON[3:2]

mvi TMRCON 0x01
mvi r2 0x22
mvi MAXREG 0x10
mov r1 MAXREG
mvi OCMP 0x7
mov r1 OCMP
mov r0 TMR
mov r1 TMR
bs TMRCON 7
hlt
