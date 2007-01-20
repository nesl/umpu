#ifndef _KERTABLE_PLAT_H_
#define _KERTABLE_PLAT_H_

#include <kertable_proc.h>

#define PLAT_KER_TABLE				\
NULL, \
NULL, \
(void*) ker_led, \
    
#define PLAT_KERTABLE_LEN 3
#define PLAT_KERTABLE_END (PROC_KERTABLE_END+PLAT_KERTABLE_LEN)

#endif



