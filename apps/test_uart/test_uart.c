#include <avr/io.h>
#include <inttypes.h>
#include <avr/signal.h>
#include <avr/sleep.h>
#include <avr/interrupt.h>

#include <avr/io.h>
#include <inttypes.h>

uint8_t counter = 0;
uint8_t state = 0;

int main () {
  //Initialize
  //This sets it to a baud rate of 9600  
  UBRR = 51;

  sei();
  UCR = 0x00;
  UCR = (1 << TXEN) | (1 << TXCIE) | (1 << RXCIE) | (1 << RXEN);
  
  DDRA = 0xFF;
  PORTA = 0x02;

  while (!(USR & (1<<UDRE)));
  UDR = counter++;
  while(1);
  return 0;

  /*
  while(1) {
    while(state == 0);
    while (!(USR & (1<<UDRE)));
    UDR = counter;
    state = 0;
  }
  while(1);
  return 0;
  */
  
}

/*
SIGNAL(SIG_UART_RECV) {
  counter = UDR;
  if(state != 1)
    state = 1;
}
*/
SIGNAL(SIG_UART_TRANS) {
  UDR = counter++;
}

