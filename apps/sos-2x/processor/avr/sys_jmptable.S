.section .sos_sysjmptbl,"ax"
.global  sos_sysjmptbl
sos_sysjmptbl:
;;; ==========================
;;; MALLOC
;;; ==========================	
jmp ker_sys_malloc         ; 0
jmp ker_sys_free           ; 1
jmp ker_sys_change_own     ; 2
;;; ==========================	
;;; MESSAGING
;;; ==========================	
jmp ker_sys_msg_take_data  ; 3
jmp sos_msg_create         ; 4
jmp sos_msg_dispose    	   ; 5
jmp msg_send_senddone 	   ; 6
jmp ker_sys_post           ; 7
jmp ker_sys_post_link      ; 8
jmp ker_sys_post_value     ; 9
;;; jmp ker_sys_handle_incoming_msg ;10
jmp sched_msg_alloc 	   ; 10
;;; ==========================
;;; MODULE STATE
;;; ==========================
jmp ker_sys_get_module_state ; 11
jmp ker_set_state_pointer  ; 12
jmp ker_register_module    ; 13
;;; ==========================
;;; FUNCTION PTR PTR
;;; ==========================	
jmp ker_sys_fnptr_call     ; 14
jmp ker_sys_fntable_subscribe 	; 15
;;; ==========================
;;; TIMER
;;; ==========================
jmp ker_sys_timer_init     ; 16
jmp ker_sys_timer_start    ; 17
jmp ker_sys_timer_restart  ; 18
jmp ker_sys_timer_stop     ; 19
;;; ==========================
;;; MISC.
;;; ==========================
jmp ker_hw_type            ; 20
jmp ker_id                 ; 21
jmp ker_rand               ; 22
jmp ker_led                ; 23
jmp set_uart_address       ; 24
;;; ==========================
;;; UNUSED
;;; ==========================	
jmp 0			   ; 25
jmp 0			   ; 26
jmp 0			   ; 27
jmp 0			   ; 28
jmp 0			   ; 29
jmp 0			   ; 30
jmp 0			   ; 31

;;; End of file

	