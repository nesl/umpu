/**
 * \file test_int.c
 */

#include <inttypes.h>
#include <malloc.h>
#include <memmap.h>

#include <dom0.h>

int main(){
  // Initializing the Safe Stack Pointer
  SSPL = 0x68;
  SSPH = 0x09;

  sei();
  // Initialize memory
  mem_init();
  dom0_main();
  while(1);
  return 0;
}

void dom0_realmain()
{
  //Initialize
  //This sets it to a baud rate of 9600  
  UBRR = 51;

  sei();
  UCR = 0x00;
  UCR = (1 << TXEN) | (1 << TXCIE) | (1 << RXCIE) | (1 << RXEN);
  
  DDRA = 0xFF;
  PORTA = 0xBB;

  while (!(USR & (1<<UDRE)));
  UDR = 0x55;

  while(1);

  return;
}

SIGNAL(SIG_UART_TRANS) {
  PORTA = 0xAA;
  UDR = 0x44;
}


SIGNAL(SIG_ADC) {
  PORTA = 0x33;
  uint8_t x = 0x22;
  UMPU_PANIC = 0xF0;
  PORTA = x;
  while(1);
}
