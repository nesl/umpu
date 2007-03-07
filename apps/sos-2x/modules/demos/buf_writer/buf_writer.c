/**
 * \file fft_module.c
 * \brief Compute the fixed point FFT of an input buffer
 * \author Ram Kumar {ram@ee.ucla.edu}
 */

#include <sys_module.h>
#ifdef SOS_SFI
#include <sfi_jumptable.h>
#endif

#include <umpu_eval.h>

#include "buf_writer.h"
#include <led.h>

//-------------------------------------------------------------
// CONSTANTS
//-------------------------------------------------------------
#ifdef SOS_SFI
#define BW_DOM_ID  SFI_DOM2
#endif

//-------------------------------------------------------------
// MODULE STATIC FUNCTIONS
//-------------------------------------------------------------
int8_t buf_writer(void* state, Message *msg);

//-------------------------------------------------------------
// MODULE HEADER
//-------------------------------------------------------------
static const mod_header_t mod_header SOS_MODULE_HEADER = {
  .mod_id         =  BUF_WRITER_PID,
  .state_size     =  0,
  .num_timers     =  0,
  .num_sub_func   =  0,
  .num_prov_func  =  0,
  .code_id        =  ehtons(BUF_WRITER_PID),
  .platform_type  = HW_TYPE /* or PLATFORM_ANY */,
  .processor_type = MCU_TYPE,
#ifdef SOS_SFI
	.dom_id         = BW_DOM_ID,
	.module_handler = (msg_handler_t)SFI_FUNC_WORD_ADDR(BW_DOM_ID, 0),
#else
  .module_handler =  buf_writer,
#endif
  .funct = {},
};

int8_t buf_writer(void* state, Message* msg)
{
  switch (msg->type){
  case MSG_INIT:
    {
      uint8_t i;
      unit8_t* buffer;

      buffer = sys_malloc(96);

      DDRB = 0xFF;
      PORTB = 0x50;
      for (i = 0; i < 16; i++) {
	buffer[i] = 1;
      }
      PORTB = 0x51;
      PORTB = 0x60;
      for (i = 0; i < 32; i++) {
	buffer[i] = 2;
      }
      PORTB = 0x61;
      PORTB = 0x70;
      for (i = 0; i < 48; i++) {
	buffer[i] = 3;
      }
      PORTB = 0x71;
      PORTB = 0x80;
      for (i = 0; i < 64; i++) {
	buffer[i] = 4;
      }
      PORTB = 0x81;
      PORTB = 0x90;
      for (i = 0; i < 80; i++) {
	buffer[i] = 5;
      }
      PORTB = 0x91;
      PORTB = 0xa0;
      for (i = 0; i < 96; i++) {
	buffer[i] = 6;
      }
      PORTB = 0xa1;

      break;
    }

  case MSG_FINAL:
    break;

  default:
    {
      sys_led(LED_RED_TOGGLE);
      return -EINVAL;
    }
  }
  return SOS_OK;
}


#ifndef _MODULE_
mod_header_ptr buf_writer_get_header()
{
  return sos_get_header_address(mod_header);
}
#endif


