.section .sfidomtable0,"ax"
.global	sfidomtable0
sfidomtable0:
jmp sos_uart_msg_handler 	; 0
jmp sos_uart_init_real		; 1
jmp sos_uart_msg_alloc_real	; 2
jmp uart_recv_interrupt		; 3
jmp uart_send_interrupt		; 4
jmp uart_system_init_real	; 5
	
;;; End of file
