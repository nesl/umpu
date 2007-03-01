/**
 * \file sfi_jumptable.c
 * \brief Managing the SFI Jumptable for the modules
 * \author Ram Kumar {ram@ee.ucla.edu}
 */

#include <sfi_jumptable.h>
#include <sfi_exception.h>
#include <sos_module_types.h>
#include <sos_sched.h>
#include <malloc.h>
#include <led.h>
#include <memmap.h>
#include <umpu.h>

extern char __heap_start;

static void sfi_err_code_led_display(uint8_t errcode);

//----------------------------------------------------------
void sfi_modtable_init()
{
  void* safe_stack_ptr;
  uint16_t sfi_jump_table_start_word_addr;
  safe_stack_ptr = &__heap_start;
  SSPL = (uint8_t)((uint16_t)safe_stack_ptr & 0x00FF);
  SSPH = (uint8_t)((uint16_t)safe_stack_ptr >> 8);
  sfi_jump_table_start_word_addr = SFI_JUMP_TABLE_START * WORDS_PER_PAGE;
  JTL = (uint8_t)(sfi_jump_table_start_word_addr & 0x00FF);
  JTH = (uint8_t)(sfi_jump_table_start_word_addr >> 8);
  return;
}
//----------------------------------------------------------
int8_t sfi_get_domain_id(sos_pid_t pid)
{
#ifdef SFI_DOMS_2
  return MOD_DOM_ID;
#endif
#ifdef SFI_DOMS_8
  int8_t retdomid;
  // Ram - For the time being assign all kernel PIDs to be
  // KER_DOM_ID
  sos_module_t* handle;
  if (pid < APP_MOD_MIN_PID){
    retdomid = KER_DOM_ID;
  }
  else{
    handle = ker_get_module(pid);
    if (NULL == handle)
      return -EINVAL;
    retdomid = sos_read_header_byte(handle->header, offsetof(mod_header_t, dom_id));
  }
  return retdomid;
#endif
}

//----------------------------------------------------------
// SFI EXCEPTION HANDLER
//----------------------------------------------------------
void sfi_jmptbl_exception()
{
  uint16_t val;
  uint8_t ledcnt;
  ker_led(LED_RED_ON);
  ker_led(LED_GREEN_OFF);
  ker_led(LED_YELLOW_OFF);
  val = 0xffff;
  ledcnt = 0;
  while (1){
#ifndef DISABLE_WDT
    watchdog_reset();
#endif
    if (val == 0){
      switch (ledcnt){
      case 0: ker_led(LED_RED_TOGGLE); ker_led(LED_GREEN_TOGGLE); break;
      case 1: ker_led(LED_GREEN_TOGGLE); ker_led(LED_YELLOW_TOGGLE); break;
      case 2: ker_led(LED_YELLOW_TOGGLE); ker_led(LED_RED_TOGGLE); break;
      default: break;
      }
      ledcnt++;
      if (ledcnt == 3) 
	ledcnt = 0;
    }
    val--;
  }
  return;
}

static void sfi_err_code_led_display(uint8_t errcode)
{
  uint8_t _led_display;				
  _led_display = errcode;				
  if (_led_display & 0x01)			
    led_yellow_on();				
  else					
    led_yellow_off();				
  _led_display >>= 1;				
  if (_led_display & 0x01)			
    led_green_on();				
  else					
    led_green_off();				
  _led_display >>= 1;				
  if (_led_display & 0x01)			
    led_red_on();				
  else					
    led_red_off();
  return;
}

void sfi_exception(uint8_t errcode)
{
  uint8_t clrdisp;
  uint16_t val;
  val = 0xffff;

  sfi_err_code_led_display(errcode);
  clrdisp = 0;

  while (1){
#ifndef DISABLE_WDT
    watchdog_reset();
#endif
    if (val == 0){
      if (clrdisp){
	sfi_err_code_led_display(errcode);
	clrdisp = 0;
      }
      else {
	sfi_err_code_led_display(0);
	clrdisp = 1;
      }
    }
    val--;
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
