
#ifndef __HW_TIMER_H__
#define __HW_TIMER_H__

#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/signal.h>

#define  HW_TIMER_MAX_TIMEOUT        255 

#define  HW_TIMER_MIN_TIMEOUT        1

#define  hw_timer_interrupt()        SIGNAL(SIG_OUTPUT_COMPARE0)

#define  hw_timer_set_interval(val)   \
	do{ while ((ASSR & (_BV(OCR0UB) | _BV(TCN0UB))) != 0); TCNT0 = 0; OCR0 = (val) - 1; } while(0)

#define  hw_timer_get_interval()      (OCR0 + 1)

#define  hw_timer_get_counter()        (TCNT0)

#define  hw_timer_interrupt_pending() (TIFR & (1 << OCF0))

void     hw_timer_init                ( void );


#endif

