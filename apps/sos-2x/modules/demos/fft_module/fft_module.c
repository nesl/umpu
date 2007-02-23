/**
 * \file fft_module.c
 * \brief Compute the fixed point FFT of an input buffer
 * \author Ram Kumar {ram@ee.ucla.edu}
 */

#include <sys_module.h>
#include "fft_module.h"
#include <led.h>

//-------------------------------------------------------------
// CONSTANTS
//-------------------------------------------------------------



//-------------------------------------------------------------
// MODULE STATIC FUNCTIONS
//-------------------------------------------------------------
static int8_t fft_fix_module(void* state, Message *msg);

//-------------------------------------------------------------
// MODULE HEADER
//-------------------------------------------------------------
static const mod_header_t mod_header SOS_MODULE_HEADER = {
  .mod_id         =  FFT_FIX_PID,
  .state_size     =  0,
  .num_timers     =  0,
  .num_sub_func   =  0,
  .num_prov_func  =  0,
  .code_id        =  ehtons(FFT_FIX_PID),
  .platform_type  = HW_TYPE /* or PLATFORM_ANY */,
  .processor_type = MCU_TYPE,
  .module_handler =  fft_fix_module,
  .funct = {},
};

static int8_t fft_fix_module(void* state, Message* msg)
{
  switch (msg->type){
  case MSG_INIT:
    sys_post_value(TEST_FFT_FIX_PID, MSG_FFT_DONE, 0, 0);
    break;

  case MSG_FINAL:
    break;

  case MSG_DO_FFT:
    {
      short* fx;
      DEBUG("Received buffer for FFT\n");
      fx = (short*)sys_msg_take_data(msg);
      sys_led(LED_YELLOW_TOGGLE);
      fix_fftr(fx, log2N, 0);
      sys_led(LED_YELLOW_TOGGLE);
      //      sys_post_uart(FFT_FIX_PID, MSG_FFT_DONE, sizeof(short)*N, fx, 
      //	    SOS_MSG_RELEASE, UART_ADDRESS);
      DEBUG("Finished FFT\n");
      break;
    }

  default:
    sys_led(LED_YELLOW_TOGGLE);
    return -EINVAL;
  }
  return SOS_OK;
}


#ifndef _MODULE_
mod_header_ptr fft_module_get_header()
{
  return sos_get_header_address(mod_header);
}
#endif


