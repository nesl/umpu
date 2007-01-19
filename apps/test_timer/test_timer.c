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

//uint8_t period = 0;

SIGNAL (SIG_OUTPUT_COMPARE0){

  PORTA = PORTA ^ 0xFF;
  //OCR0 = 0x23;
  OCR0 = OCR0 - 1;

}

void init_timer( void ) {

  /*
  TIMSK = 1<<TOIE0;
  TCCR0 = 0x01;
  */
 
  ASSR = 1 << AS0 ;
  TIMSK = (1 << OCIE0); // Output compare match interrupt enable for Timer 0
  TCCR0 = (1 << CS00)|(1 << CTC0);  // No-prescaling
  TCNT0 = 0x00;
  OCR0 = 0x67;
  
}

int main (void) {

  DDRA = 0xFF;
  PORTA = 0xFF;
  init_timer ();
  sei();

  while (1);
  return 0;
}

