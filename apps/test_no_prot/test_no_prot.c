/**
 * \file test_no_prot.c
 */

#include <inttypes.h>
#include <avr/io.h>
#include <avr/sleep.h>
#include <avr/interrupt.h>

#define BUFF_SIZE 20

uint8_t global_buffer[BUFF_SIZE];

void dom1_realmain(uint8_t* stack_buffer, uint8_t* global_buffer)
{
  uint8_t i;
  for(i = 0; i < BUFF_SIZE; i++){
    stack_buffer[i] = stack_buffer[i] * 2;
    PORTA = stack_buffer[i];
  }
  for(i = 0; i < BUFF_SIZE; i++){
    global_buffer[i] = global_buffer[i] * 2;
    PORTA = global_buffer[i];
  }
}

void dom0_realmain()
{
  uint8_t i;
  uint8_t stack_buffer[BUFF_SIZE];
  DDRA = 0xFF;
  PORTA = 0x55;
  PORTA = 0xAA;

  // Initialize and display the value of the memory
  for (i = 0; i < BUFF_SIZE; i++){
    stack_buffer[i] = i;
    PORTA = stack_buffer[i];
  }
  for (i = 0; i < BUFF_SIZE; i++){
    global_buffer[i] = i;
    PORTA = global_buffer[i];
  }

  dom1_realmain(stack_buffer,global_buffer);

  return;
}

int main(){
  dom0_realmain();
  while(1);
  return 0;
}

