
#ifndef __SP_TIMER_H__
#define __SP_TIMER_H__

/**
 * Usage:
 * #include <sp_task.h>
 * #include <sp_semaphore.h>
 * #include <sp_timer.h>
 */

typedef uint16_t sp_timeval_t;
/**
 * Timer Control Block
 */
typedef struct sp_timer_t {
	sp_timeval_t         ival; 
	sp_timeval_t         rval;
	void (*callback)(void);
	struct sp_timer_t*   next;
} sp_timer_t;

void sp_timer_init( void );

void sp_timer_close( sp_timer_t* f );

void sp_timer_start( sp_timer_t *cb, sp_timeval_t ival, sp_timeval_t rval, void (*callback)(void) );

#endif

