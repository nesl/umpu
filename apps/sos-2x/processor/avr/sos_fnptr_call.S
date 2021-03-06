__SREG__ = 0x3f
__SP_H__ = 0x3e
__SP_L__ = 0x3d
xptr_l = 26
xptr_h = 27
zptr_l = 30
zptr_h = 31
word_l = 24
word_h = 25
temp_reg0 = 0
temp_reg1 = 1
RAMPZ  = 59

.section .text
.global ker_sys_fnptr_call
ker_sys_fnptr_call:
	clr  xptr_l         ;
	mov zptr_l, word_l
	mov zptr_h, word_h
	lsl  zptr_l         ; shift left
	rol  zptr_h         ;
	rol  xptr_l         ; get the carry bit
	out  RAMPZ, xptr_l  ; set to RAMPZ
	lpm
	mov xptr_l, temp_reg0
	adiw zptr_l, 1
	lpm
	mov xptr_h, temp_reg0;
	push xptr_l         ; push xptr into stack so that we can reuse xptr
	push xptr_h         ;
	adiw zptr_l, 5      ; move Z pointer to the location of pid
	in   temp_reg0, __SREG__ ; save Status register for critical section
	cli          
	push temp_reg0 
	lds  temp_reg1, (curr_pid); Get current executing PID from variable
	lds  xptr_l, (pid_sp)   ;  load the stack pointer for pid
	lds  xptr_h, (pid_sp+1) ;
	st   X+, temp_reg1  ;  save curr_pid to pid stack
	sts  pid_sp, xptr_l ;
	sts  (pid_sp+1), xptr_h ;
	lpm
	mov xptr_l, temp_reg0
	cpi  xptr_l, 255 ; check whether this is RUNTIME_PID
	brne label_store_curr_pid;
	lds  xptr_l, (curr_pid);
label_store_curr_pid:
	sts  (curr_pid), xptr_l ;  update curr_pid to destination PID
	pop temp_reg0
	out  __SREG__, temp_reg0 ;  leave critical section
	pop  zptr_h         ; get the function location from the stack
	pop  zptr_l         ;
	clr  temp_reg1      ; clear R1 for gcc
	icall               ;
	in   temp_reg0, __SREG__ ; save Status register for critical section
	cli                 ;
	lds  xptr_l, (pid_sp)   ;  load the stack pointer for pid
	lds  xptr_h, (pid_sp+1) ;
	ld   temp_reg1, -X  ;
	sts  pid_sp, xptr_l ;
	sts  (pid_sp+1), xptr_h ;
	sts  (curr_pid), temp_reg1;
	out  __SREG__, temp_reg0 ;  leave critical section
	clr  temp_reg1      ; clear R1 for gcc 
	ret
	
;;; End of file
