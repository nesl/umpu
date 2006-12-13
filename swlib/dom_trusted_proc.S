.section .domtrustjmptbl,"ax"
.global domtrust_jmptbl_init
domtrust_jmptbl_init:
jmp mmc_int_malloc
jmp mmc_int_free
jmp mmc_int_change_own


