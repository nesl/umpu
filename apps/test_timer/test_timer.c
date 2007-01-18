#include <avr/io.h>
#include <inttypes.h>
#include <avr/signal.h>
#include <avr/sleep.h>
#include <avr/interrupt.h>

/*
SIGNAL (SIG_OVERFLOW0){

  PORTA = PORTA ^ 0xFF;

}
*/
SIGNAL (SIG_OUTPUT_COMPARE0){

  PORTA = PORTA ^ 0xFF;

}

void init_timer( void ) {

  /*
  TIMSK = 1<<TOIE0;
  TCCR0 = 0x01;
  */
 
  ASSR = 1 << AS0 ;
  TIMSK = (1 << OCIE0); // Output compare match interrupt enable for Timer 0
  TCNT0 = 0x00;
  TCCR0 = (1 << CS00)|(1 << CTC0);  // No-prescaling
  OCR0 = 0xA0;
  
}

int main (void) {

  DDRA = 0xFF;
  PORTA = 0xFF;
  init_timer ();
  sei();

  while (1);
  return 0;
}

