#ifndef _KERTABLE_PROC_H_
#define _KERTABLE_PROC_H_

#include <kertable.h> // for SYS_KERTABLE_END

// NOTE - If you add a function to the PROC_KERTABLE, make sure to change
// PROC_KERTABLE_LEN
#define PROC_KER_TABLE                                          \
NULL, \
NULL, \
NULL, \
NULL, \
NULL, \
NULL, \
NULL, \
NULL, \
NULL, \
    /* 10 */ (void*)ker_uart_reserve_bus,			\
    /* 11 */ (void*)ker_uart_release_bus,			\
    /* 12 */ (void*)ker_uart_send_data,				\
    /* 13 */ (void*)ker_uart_read_data,				\
    
// NOTE - Make sure to change the length if you add new functions to the
// PROC_KERTABLE
#define PROC_KERTABLE_LEN 13

#define PROC_KERTABLE_END (SYS_KERTABLE_END+PROC_KERTABLE_LEN)

#endif

