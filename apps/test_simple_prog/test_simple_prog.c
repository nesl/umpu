#include <avr/io.h>
#include <avr/signal.h>
#include <avr/sleep.h>
#include <avr/interrupt.h>
#include <inttypes.h>

int main()
{
  DDRA = 0xFF;
  PORTA = 0x33;
  return 0;
}

