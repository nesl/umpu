#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/signal.h>
#include <stdlib.h>

void hw_timer_init()
{
  /*
  unsigned char scale = 3;
  
  scale &= 0x7;
  scale |= (1<<WGM1); // reset on match
  */

  TIMSK &= ((unsigned char)~(1 << (TOIE0)));
  TIMSK &= ((unsigned char)~(1 << (OCIE0)));
  //!< Disable TC0 interrupt
  
  /** 
   *  set Timer/Counter0 to be asynchronous 
   *  from the CPU clock with a second external 
   *  clock(32,768kHz)driving it
   */
  ASSR |= (1 << (AS0)); //!< us external oscillator
  //TCCR0 = scale;
  TCCR0 = (1 << CS00)|(1 << CTC0);  // No-prescaling
  TCNT0 = 0;
  OCR0 = 255;
  TIMSK |= (1 << (OCIE0));
}
