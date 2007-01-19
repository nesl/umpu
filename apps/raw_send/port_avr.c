#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <stdlib.h>
#include <inttypes.h>
#include "hardware.h"
#include "systime.h"
#include "sp_timer.h"

static sp_timer_t app_timer;

//
// Setup routines
//

void app_timeout(void)
{
  PORTA = PORTA ^ 0xFF;
}

int main()
{
  sched_init();
  sp_timer_init();

  sei();
  
  sp_timer_start( &app_timer, 30L, 100L, app_timeout);
  //sp_timer_start( &app_timer, 1024L, 1024L, insort_timeout);

  DDRA = 0xFF;
  PORTA = 0xFF;

  sched_loop();
  while(1);
}

