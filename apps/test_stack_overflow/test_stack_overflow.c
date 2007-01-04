/**
 * \file test_mul_dom.c
 */

#include <inttypes.h>
#include <malloc.h>
#include <memmap.h>

#include <dom0.h>

#define BUFF_SIZE 10

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

uint16_t recursion(uint16_t var)
{
  uint16_t ans;
  PORTA = var >> 8;
  PORTA = var;
  while(1)
    ans = recursion(var + 1);
  return ans;
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

  recursion(1);

  PORTA = 0xEE;
  // This will cause a panic
  buffer = buffer + 2*BUFF_SIZE;
  *buffer = 10;
  PORTA = 0xFF;

  return;
}
