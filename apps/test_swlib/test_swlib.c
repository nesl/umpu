/**
 * \file test_swlib.c
 */

#include <inttypes.h>
#include <malloc.h>
#include <memmap.h>

#include <dom0.h>

#define BUFF_SIZE 32

int main(){
  // Initializing the Safe Stack Pointer
  SSPL = 0x68;
  SSPH = 0x09;

  // Initialize memory
  mem_init();
  dom0_main();
  while(1);
  return 0;
}

void dom0_realmain()
{
  uint8_t i;
  uint8_t* buffer;
  buffer = mmc_malloc(BUFF_SIZE);
  for (i = 0; i < BUFF_SIZE; i++)
    buffer[i] = i;

  DDRA = 0xFF;
  PORTA = *(buffer + 1);

  // This will cause a panic
  buffer = buffer + 2*BUFF_SIZE;
  *buffer = 10;
  PORTA = 0xFF;

  return;
}
