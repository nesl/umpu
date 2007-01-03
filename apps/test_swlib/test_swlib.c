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
  //memmap[0] = 0x08;
  //memmap[1] = 0x00;
  dom0_main();
  while(1);
  return 0;
}

// Function to send things over UART
//void send_uart(uint8_t* buffer);

void dom0_realmain()
{
  uint8_t i;
  uint8_t* buffer;
  buffer = mmc_malloc(BUFF_SIZE);
  for (i = 0; i < BUFF_SIZE; i++)
    buffer[i] = i;

  DDRA = 0xFF;
  PORTA = *(buffer + 1);

  //send_uart(buffer);

  // This will cause a panic
  buffer = buffer + 2*BUFF_SIZE;
  *buffer = 10;
  PORTA = 0xFF;

  return;
}
/*
void send_uart(uint8_t* buffer) {
  uint8_t index;
  UBRR = 51;
  UCR = 0x00;
  UCR = (1 << TXEN);
  
  DDRA = 0xFF;
  PORTA = 0x02;
  
  while(1) {
    for(index = 0; index < BUFF_SIZE; index++){
      //Transmit
      while (!(USR & (1<<UDRE)));
      PORTA = PORTA ^ 0xFC;
      UDR = (unsigned char)'U';
      //UDR = buffer[index];
    }
  } 
}
*/
