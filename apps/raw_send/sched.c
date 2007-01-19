#include <stdlib.h>
#include "hardware.h"

#define MAX_TASKS  16
#define TASK_BITMASK (MAX_TASKS - 1)

typedef void (*task_t)(void);

static volatile  task_t sched_queue[MAX_TASKS] = {NULL};
static volatile uint8_t  sched_full;
static volatile uint8_t sched_free;
static volatile uint8_t num_tasks;

void sched_init()
{
	uint8_t i;
	
	sched_full = 0;
	sched_free = 0;
	num_tasks = 0;
	for(i = 0; i < MAX_TASKS; i++) {
		sched_queue[i] = NULL;
	}
}

void sched_post( void (*tp) () )
{
	HAS_CRITICAL_SECTION;
	uint8_t tmp;

	ENTER_CRITICAL_SECTION();
	tmp = sched_free;
	
	if( sched_queue[tmp] == NULL ) {
		sched_free = (tmp + 1) & TASK_BITMASK;
		sched_queue[tmp] = tp;
		num_tasks++;
	}
	LEAVE_CRITICAL_SECTION();
}

static void sched_dispatch()
{
	void (*func)(void);

	func = sched_queue[sched_full];
	
	sched_queue[sched_full] = NULL;
	sched_full = (sched_full + 1) & TASK_BITMASK;
	num_tasks--;
	ENABLE_GLOBAL_INTERRUPTS();
	func();
}

void sched_loop()
{
	
	for(;;) {
		DISABLE_GLOBAL_INTERRUPTS();
		if( num_tasks != 0 ) {
			ENABLE_GLOBAL_INTERRUPTS();
			sched_dispatch();
		} else {
			SLEEP();
		}
	}
}
