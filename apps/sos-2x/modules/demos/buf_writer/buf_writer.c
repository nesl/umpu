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
      sys_post_value(TEST_FFT_FIX_PID, MSG_FFT_DONE, 0, 0);
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


