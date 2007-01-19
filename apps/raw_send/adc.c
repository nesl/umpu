#include <avr/io.h>
#include <avr/interrupt.h>
//#include <avr/signal.h>
#include <stdlib.h>
#include "hardware.h"
#include "cc1k.h"

//
// We don't need to use SP_INT_BEGIN block as we only signal 
// just one task.  there is no need to worry about wrong priority order.
//
SIGNAL(SIG_ADC)
{
	asm volatile("nop");
	asm volatile("sig_adc_begin:");
	ADCSRA &= ~_BV(ADEN);

	// TODO: call Radio
	RSSIADC_dataReady(ADC); 
	asm volatile("sig_adc_end:");
	asm volatile("nop");
}

void adc_start( uint8_t channel )
{
	//uint8_t tmp;
	HAS_CRITICAL_SECTION;
	
	ENTER_CRITICAL_SECTION();
	//
	// First conversion
	//
	ADMUX   = channel;
	ADCSRA |= _BV(ADEN);
	ADCSRA |= _BV(ADSC);  // start conversion 
	LEAVE_CRITICAL_SECTION();
}

void adc_init()
{
	//uint8_t i;
	ADMUX = (0 | 0x1F);
	// disable ADC, clear any pending interrupts and enable ADC
	ADCSRA &= ~_BV(ADEN);
	ADCSRA |= (_BV(ADPS2)|_BV(ADPS1)); // 6
	ADCSRA |= _BV(ADIE);
}



