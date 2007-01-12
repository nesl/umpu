/**
 * \file test_mul_dom.c
 */

#include <inttypes.h>
#include <malloc.h>
#include <memmap.h>

#include <dom0.h>
#include <dom1.h>

#define BUFF_SIZE 10

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

void dom1_realmain(uint8_t* buffer)
{
  uint8_t i;
  for(i = 0; i < BUFF_SIZE; i++){
    buffer[i] = buffer[i] * 2;
    PORTA = buffer[i];
  }
}

void dom0_realmain()
{
  uint8_t *buffer;
  uint8_t var;
  uint8_t i;
  DDRA = 0xFF;
  PORTA = 0xFF;

  buffer = &var;
  for(i = 0; i < BUFF_SIZE; i++){
    buffer[i] = (i + 5);
    PORTA = buffer[i];
  }

  return;
}

SIGNAL(SIG_ADC) {
  PORTA = 0x33;
  uint8_t x = 0x22;
  UMPU_PANIC = 0xF0;
  PORTA = x;
  while(1);
}
