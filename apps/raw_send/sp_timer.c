
#include <stdlib.h>
#include "inttypes.h"
#include "hardware.h"
#include "sp_timer.h"
#include "hw_timer.h"

static sp_timer_t*            sp_timer_list;


//-----------------------------------------------------------------------------
// Forward function declarations
//
static void        sp_timer_deltaq_insert     ( sp_timer_t *cb );
static sp_timer_t* sp_timer_take_cb           ( sp_timer_t *cb );
static void        sp_timer_set_interval      ( void );
static void        sp_timer_decrement_delta   ( sp_timer_t* cb, sp_timeval_t cnt );

hw_timer_interrupt( )
{

	asm volatile("hard_interrupt_begin:");
	if( sp_timer_list == NULL ) {
		return;
	}
		
	sp_timer_decrement_delta(sp_timer_list, hw_timer_get_interval());
	
	while(sp_timer_list != NULL && sp_timer_list->ival == 0 ) {
		sp_timer_t *tmp = sp_timer_list;
		sp_timer_list = tmp->next;

		sched_post(tmp->callback);
		
		if( tmp->rval != 0 ) {
			tmp->ival = tmp->rval;
			sp_timer_deltaq_insert( tmp );
		}
	}
	
	sp_timer_set_interval();
	asm volatile("hard_interrupt_end:");
	asm volatile("nop");
}

void sp_timer_start( sp_timer_t *cb, sp_timeval_t ival, sp_timeval_t rval, void (*callback)(void) )
{
	HAS_CRITICAL_SECTION;

	ENTER_CRITICAL_SECTION();

	//
	// remove timer request from delta list if it already exists 
	//
	sp_timer_take_cb( cb );
	
	cb->ival       = ival;
	cb->rval       = rval;
	cb->callback   = callback;
	cb->next       = NULL;
	
	cb->ival += hw_timer_get_counter();
	

	sp_timer_deltaq_insert( cb );

	LEAVE_CRITICAL_SECTION();


	ENTER_CRITICAL_SECTION();
	sp_timer_set_interval();
	LEAVE_CRITICAL_SECTION();
}

void sp_timer_close( sp_timer_t* cb )
{
	HAS_CRITICAL_SECTION;

	ENTER_CRITICAL_SECTION();

	cb = sp_timer_take_cb( cb );
	
	if( cb != NULL ) {
		LEAVE_CRITICAL_SECTION();

		
		ENTER_CRITICAL_SECTION();
		sp_timer_set_interval();
		LEAVE_CRITICAL_SECTION();
		return;
	}
	LEAVE_CRITICAL_SECTION();
}


static void sp_timer_deltaq_insert( sp_timer_t *cb )
{
	sp_timer_t *prev = NULL;
	sp_timer_t *itr  = sp_timer_list;

	while( itr ) {
		if( itr->ival > cb->ival ) {
			itr->ival -= cb->ival;
			break;
		}
		cb->ival -= itr->ival;
		prev = itr;
		itr = itr->next;
	}

	if( prev == NULL ) {
		//
		// Insert the timer to the head
		//
		cb->next = sp_timer_list;
		sp_timer_list = cb;
	} else {
		//
		// Insert into the middle of the list or the end
		//
		prev->next = cb;
		cb->next = itr;
	}
}

static sp_timer_t* sp_timer_take_cb( sp_timer_t* cb )
{
	sp_timer_t *prev = NULL;
	sp_timer_t *itr  = sp_timer_list;

	while( itr != NULL ) {
		if( itr == cb ) {
			//
			// Note that we are modifying delta list,
			// but we don't update hardware timer as 
			// it will be updated by the caller.
			//
			if( itr->next != NULL ) {
				//
				// Add the delta value to the next guy
				//
				itr->next->ival += itr->ival;
			}
			if( prev != NULL ) {
				prev->next = itr->next;
			} else {
				sp_timer_list = itr->next;
			}
			return itr;
		}

		prev = itr;
		itr = itr->next;
	}

	return itr;
}

static void sp_timer_set_interval( void )
{
	sp_timer_t* cb = sp_timer_list;
	uint16_t hw_cnt;
	
	if( cb == NULL ) {
		hw_timer_set_interval( HW_TIMER_MAX_TIMEOUT );
		return;
	}

	//
	// If the hardware interrupt is pending,
	// let it fire instead of handing here
	//
	
	if( hw_timer_interrupt_pending() ) {
		return;
	}

	hw_cnt = hw_timer_get_counter();
	
	//
	// Subtract the delta from hardware counter
	// because setting new interval will reset 
	// hardware counter.
	//
	
	if( cb->ival < hw_cnt || cb->ival < HW_TIMER_MIN_TIMEOUT) {
		//
		// there will be draft ...
		//
		cb->ival = HW_TIMER_MIN_TIMEOUT;
	} else {
		cb->ival -= hw_cnt;
	}

	//
	// This should never be negative
	// because if it were negative, 
	// hardware interrupt would have fired.
	//
	if( cb->ival > HW_TIMER_MAX_TIMEOUT ) {
		hw_timer_set_interval( HW_TIMER_MAX_TIMEOUT );
	} else {
		hw_timer_set_interval( (uint16_t)cb->ival );
	}
}

static void sp_timer_decrement_delta( sp_timer_t* cb, sp_timeval_t cnt )
{
	while( cb != NULL ) {
		if( cb->ival >= cnt ) {
			//
			// We have used all the ticks
			//
			cb->ival -= cnt;
			return;
		}
		cnt -= cb->ival;
		cb->ival = 0;
		cb = cb->next;
	}
}

void sp_timer_init( void )
{
	sp_timer_list = NULL;

	hw_timer_init();
	//
	// Starting the hardware
	//
	hw_timer_set_interval( HW_TIMER_MAX_TIMEOUT );
}
