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

  // This will cause a panic
  buffer = buffer + 2*BUFF_SIZE;
  *buffer = 10;
  PORTA = 0xFF;
}

void dom0_realmain()
{
  uint8_t i;
  uint8_t* buffer;
  DDRA = 0xFF;
  // Request for memory
  buffer = mmc_malloc(BUFF_SIZE);

  // Initialize and display the value of the memory
  for (i = 0; i < BUFF_SIZE; i++){
    buffer[i] = i;
    PORTA = buffer[i];
  }

  mmc_change_own((void*)buffer, 1);
  dom1_main(buffer);

  // This will cause a panic
  buffer = buffer + 2*BUFF_SIZE;
  *buffer = 10;
  PORTA = 0xFF;

  return;
}

SIGNAL(SIG_ADC) {
  PORTA = 0x33;
  UMPU_PANIC = 0xF0;
  while(1);
}
