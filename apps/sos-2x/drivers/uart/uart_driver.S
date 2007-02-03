.section .sfidomtable0,"ax"
.global	sfidomtable0
sfidomtable0:
jmp sos_uart_msg_handler 	; 0
jmp sos_uart_init_real		; 1
jmp sos_uart_msg_alloc_real	; 2
