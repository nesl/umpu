/**
 * \file test_fft_fix_module.c
 * \brief Test the FFT Fix Module
 * \author Ram Kumar {ram@ee.ucla.edu}
 */

#include <sys_module.h>
#ifdef SOS_SFI
#include <sfi_jumptable.h>
#endif
#include <umpu_eval.h>

#include <demos/fft_module/fft_module.h>
#include <led.h>

//-------------------------------------------------------------
// CONSTANTS
//-------------------------------------------------------------
#ifdef SOS_SFI
#define TEST_FFT_DOM_ID SFI_DOM3
#endif


//-------------------------------------------------------------
// MODULE STATIC FUNCTIONS
//-------------------------------------------------------------
static int8_t test_fft_fix_module(void* state, Message *msg);

//-------------------------------------------------------------
// MODULE HEADER
//-------------------------------------------------------------
static const mod_header_t mod_header SOS_MODULE_HEADER = {
  .mod_id         =  TEST_FFT_FIX_PID,
  .state_size     =  0,
  .num_timers     =  0,
  .num_sub_func   =  0,
  .num_prov_func  =  0,
  .code_id        =  ehtons(TEST_FFT_FIX_PID),
  .platform_type  = HW_TYPE /* or PLATFORM_ANY */,
  .processor_type = MCU_TYPE,
#ifdef SOS_SFI
  .dom_id         = TEST_FFT_DOM_ID
  .module_hander  = (msg_handler_t)SFI_FUNC_WORD_ADDR(TEST_FFT_DOM_ID, 0),
#else
  .module_handler =  test_fft_fix_module,
#endif
  .funct = {},
};

static int8_t test_fft_fix_module(void* state, Message* msg)
{
  switch (msg->type){
  case MSG_FFT_DONE:
    {
      uint8_t i;
      short* fx;
      short temp[N] = {
	48, -23827, 4318, 22572, 0, -22317, -4063, 24082, 
	208, 24082, -4063, -22317, 0, 22572, 4318, -23827, 
	-21990, -4656, 23817, -5849, 6104, -23562, 4911, 22245, 
	22245, 4911, -23562, 6104, -5849, 23817, -4656, -21990};

	/* 64 samples
	48, -21990, -23827, -4656, 4318, 23817, 22572, -5849, 
	0, 6104, -22317, -23562, -4063, 4911, 24082, 22245, 
	208, 22245, 24082, 4911, -4063, -23562, -22317, 6104, 
	0, -5849, 22572, 23817, 4318, -4656, -23827, -21990, 
	21802, -19452, -6438, 4818, 4594, 29470, -15313, -24554, 
	24809, 15568, -29215, -4339, -4563, 6693, 19707, -21547, 
	-21547, 19707, 6693, -4563, -4339, -29215, 15568, 24809, 
	-24554, -15313, 29470, 4594, 4818, -6438, -19452, 21802};
	*/
      fx = sys_malloc(sizeof(short)*N);
      for (i = 0; i < N; i++) {
	fx[i] = temp[i];
      }
      sys_post(FFT_FIX_PID, MSG_DO_FFT, sizeof(short)*N, fx,
	       SOS_MSG_RELEASE);
      sys_led(LED_GREEN_TOGGLE);
      break;
    }
  default:
    break;
  }
  return SOS_OK;
}


#ifndef _MODULE_
mod_header_ptr test_fft_module_get_header()
{
  return sos_get_header_address(mod_header);
}
#endif

