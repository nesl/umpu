/* -*- Mode: C; tab-width:2 -*- */
/* ex: set ts=2 shiftwidth=2 softtabstop=2 cindent: */
/*
 * Copyright (c) 2003 The Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials provided
 *    with the distribution.
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgement:
 *       This product includes software developed by Networked &
 *       Embedded Systems Lab at UCLA
 * 4. Neither the name of the University nor that of the Laboratory
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 */
/**
 * @brief    System scheduler
 * @author   Simon Han (simonhan@ee.ucla.edu)
 * @brief    Fault tolerant features
 * @author   Ram Kumar (ram@ee.ucla.edu)
 *
 */
#include <sos_types.h>
#include <sos_sched.h>
#include <message_queue.h>
#include <monitor.h>
#include <hardware_types.h>
#include <sensor.h>
#include <sos_info.h>
#include <malloc.h>
#include <message.h>
#include <sos_timer.h>
#include <measurement.h>
#include <timestamp.h>
#include <fntable.h>
#include <sos_module_fetcher.h>
#include <sos_logging.h>
#ifdef FAULT_TOLERANT_SOS
#define LED_DEBUG
#include <led_dbg.h>
#endif
#ifdef SOS_SFI
#include <sfi_jumptable.h>
#endif


#ifndef SOS_DEBUG_SCHED
#undef  DEBUG
#define DEBUG(...)
//#define DEBUG(args...) DEBUG_PID(KER_SCHED_PID, ##args)
#endif


//----------------------------------------------------------------------------
//  TYPEDEFS, ENUMS
//----------------------------------------------------------------------------
enum
  {
	MSG_SCHED_CRASH_REPORT = (MOD_MSG_START + 0),
	SOS_PID_STACK_SIZE     = 16,
  };

//----------------------------------------------------------------------------
//  STATIC FUNCTION DECLARATIONS
//----------------------------------------------------------------------------
#ifndef QUALNET_PLATFORM
static inline bool sched_message_filtered(sos_module_t *h, Message *m);
static int8_t sched_handler(void *state, Message *msg);
static int8_t sched_register_module(sos_module_t *h, mod_header_ptr p,
		void *init, uint8_t init_size);
static int8_t do_register_module(mod_header_ptr h,
		sos_module_t *handle, void *init, uint8_t init_size,
		uint8_t flag);
static sos_pid_t sched_get_pid_from_pool();
#ifdef FAULT_TOLERANT_SOS
static int8_t ker_micro_reboot_module(sos_module_t* handle);
#endif //FAULT_TOLERANT_SOS
#endif //QUALNET_PLATFORM

//----------------------------------------------------------------------------
//  GLOBAL DATA DECLARATIONS
//----------------------------------------------------------------------------
static mod_header_t mod_header SOS_MODULE_HEADER =
  {
	.mod_id = KER_SCHED_PID,
	.state_size = 0,
	.num_sub_func = 0,
	.num_prov_func = 0,
	.module_handler = sched_handler, 	
  };

//! priority queue
static mq_t schedpq NOINIT_VAR;

//! module data structure
static sos_module_t sched_module;

/*
 * NOTE: all three variables below are used by the assembly routine 
 * to optimize the performance
 * The C version that uses these variables are in fntable.c
 */
sos_pid_t    curr_pid;                      //!< current executing pid
static sos_pid_t    pid_stack[SOS_PID_STACK_SIZE]; //!< pid stack
sos_pid_t*   pid_sp;                        //!< pid stack pointer


static uint8_t int_ready = 0;
static sched_int_t  int_array[SCHED_NUM_INTS];

// this is for dispatch short message directly
static Message short_msg;

/**
 * @brief module bins
 * we hash pid into particular bin, and store the handle of next module
 * the handle is defined as the array index to module_list
 */
static sos_module_t* mod_bin[SCHED_NUMBER_BINS] NOINIT_VAR;

/**
 * @brief pid pool
 *
 * Use for spwaning private module
 */
#define SCHED_MIN_THREAD_PID   (APP_MOD_MAX_PID + 1)
#define SCHED_NUM_THREAD_PIDS  (SOS_MAX_PID - APP_MOD_MAX_PID)
#define SCHED_PID_SLOTS        ((SCHED_NUM_THREAD_PIDS + 7) / 8)
static uint8_t pid_pool[SCHED_PID_SLOTS];

//----------------------------------------------------------------------------
//  FUNCTION IMPLEMENTATIONS
//----------------------------------------------------------------------------
static int8_t sched_handler(void *state, Message *msg)
{
  if(msg->type == MSG_INIT) {
	return SOS_OK;
  }
  return -EINVAL;
}

// Initialize the scheduler
void sched_init(uint8_t cond)
{
  register uint8_t i = 0;
  if(cond != SOS_BOOT_NORMAL) {
	//! iterate through module_list and check for memory bug
  }
  mq_init(&schedpq);
  //! initialize all bins to be empty
  for(i = 0; i < SCHED_NUMBER_BINS; i++) {
		mod_bin[i] = NULL;
  }
  for(i = 0; i < SCHED_PID_SLOTS; i++) {
		pid_pool[i] = 0;
  }
  sched_register_kernel_module(&sched_module, sos_get_header_address(mod_header), mod_bin);

	for(i = 0; i < SCHED_NUM_INTS; i++) {
		int_array[i] = NULL;
	}
	//
	// Initialize PID stack
	//
	pid_sp = pid_stack;
	// initialize short message
	short_msg.data = short_msg.payload;
	short_msg.daddr = node_address;
	short_msg.saddr = node_address;
	short_msg.len = 3;
}

void sched_add_interrupt(uint8_t id, sched_int_t f)
{
	if( id >= SCHED_NUM_INTS ) return;

	int_array[id] = f;
	int_ready = 1;
}

static void handle_callback( void )
{
	uint8_t i;
	int_ready = 0;
	for(i = 0; i < SCHED_NUM_INTS; i++) {
		if( int_array[i] != NULL ) {
			sched_int_t f = int_array[i];
			int_array[i] = NULL;
			f();
		}
	}
}


/**
 * @brief get handle from pid
 * @return handle if successful, -ESRCH otherwise
 */
#define hash_pid(id)           ((id) % SCHED_NUMBER_BINS)

// Get pointer to module control block
sos_module_t* ker_get_module(sos_pid_t pid)
{
  //! first hash pid into bins
  uint8_t bins = hash_pid(pid);
  sos_module_t *handle;

  handle = mod_bin[bins];
  while(handle != NULL) {
		if(handle->pid == pid) {
			return handle;
		} else {
			handle = handle->next;
		}
  }
  return NULL;
}

void* ker_get_module_state(sos_pid_t pid)
{
	sos_module_t *m = ker_get_module(pid);
	if(m == NULL) return NULL;
	
	return m->handler_state;
}

void* ker_sys_get_module_state( void )
{
	sos_module_t *m = ker_get_module(curr_pid);
	
	if(m == NULL) return NULL;
	return m->handler_state;
}

sos_pid_t ker_set_current_pid( sos_pid_t pid )
{
	sos_pid_t ret = curr_pid;
	if( pid != RUNTIME_PID ) {
		curr_pid = pid;
	}
	return ret;
}

sos_pid_t ker_get_current_pid( void )
{
	return curr_pid;
}

void ker_killall(sos_code_id_t code_id)
{
	bool found = false;
	uint8_t i;

	do {
		found = false;
		for(i=0;i<SCHED_NUMBER_BINS;i++){
			sos_module_t *handle;
			handle = mod_bin[i];
			while( handle != NULL ) {
				sos_code_id_t cid;
				cid = sos_read_header_word(handle->header,
						offsetof(mod_header_t, code_id));
				cid = entohs(cid);
				if( cid == code_id ) {
					ker_deregister_module(handle->pid);
					found = true;	
					break;
				}
				handle = handle->next;
			}
			if( found == true ) {
				break;
			}
		}
	} while( found == true );
}

// Get handle to the hash table
sos_module_t **sched_get_all_module()
{
	return mod_bin;
}

static sos_pid_t sched_get_pid_from_pool()
{
	sos_pid_t p = 0;
	uint8_t i, j;

	for(i = 0; i < SCHED_PID_SLOTS; i++) {
		uint8_t mask = 1;
		for(j = 0; j < 8; j++, p++, mask <<= 1) {
			if(p == SCHED_NUM_THREAD_PIDS) {
				return NULL_PID;
			}
			if((mask & (pid_pool[i])) == 0) {
				pid_pool[i] |= mask;
				return p+SCHED_MIN_THREAD_PID;
			}
		}
	}
	return NULL_PID;
}

/**
 * @brief register task with handle
 * Here we assume the state has been initialized.
 * We just need to link to the bin
 */
static int8_t sched_register_module(sos_module_t *h, mod_header_ptr p,
		void *init, uint8_t init_size)
{
  HAS_CRITICAL_SECTION;
  uint8_t num_timers;
  uint8_t bins = hash_pid(h->pid);

  if(ker_get_module(h->pid) != NULL) {
		return -EEXIST;
	//ker_deregister_module(h->pid);
	DEBUG("Module %d is already registered\n", h->pid);
  }

  //! Read the number of timers to be pre-allocated
  num_timers = sos_read_header_byte(p, offsetof(mod_header_t, num_timers));
  if (num_timers > 0){
	//! If there is no memory to pre-allocate the requested timers
	if (timer_preallocate(h->pid, num_timers) < 0){
		return -ENOMEM;
	}
  }

  // link the functions
  fntable_link(h);
  ENTER_CRITICAL_SECTION();
  /**
   * here is critical section.
   * We need to prevent others to search this module
   */
  // add to the bin
  h->next = mod_bin[bins];
  mod_bin[bins] = h;
  LEAVE_CRITICAL_SECTION();
  DEBUG("Register %d, Code ID %d,  Handle = %x\n", h->pid,
		  sos_read_header_byte(h, offsetof(mod_header_t, mod_id)),
		  (unsigned int)h);

#ifdef FAULT_TOLERANT_SOS
  //! Set the checksum of the state of the module before invoking its init method
  if ((((h->flag) & SOS_KER_STATIC_MODULE) == 0) &&
      (h->handler_state != NULL))
	mem_block_set_checksum(h->handler_state);
#endif

  // send an init message to application
  // XXX : need to check the failure
  if(post_long(h->pid, KER_SCHED_PID, MSG_INIT, init_size, init, SOS_MSG_RELEASE | SOS_MSG_SYSTEM_PRIORITY) != SOS_OK) {
	  timer_remove_all(h->pid);
	  return -ENOMEM;
  }
  return SOS_OK;
}


sos_pid_t ker_spawn_module(mod_header_ptr h, void *init, uint8_t init_size, uint8_t flag)
{
	sos_module_t *handle;
	if(h == 0) return NULL_PID;
	// Allocate a memory block to hold the module list entry
	//handle = (sos_module_t*)ker_malloc(sizeof(sos_module_t), KER_SCHED_PID);
	handle = (sos_module_t*)malloc_longterm(sizeof(sos_module_t), KER_SCHED_PID);
	if (handle == NULL) {
		return NULL_PID;
	}
	if( do_register_module(h, handle, init, init_size, flag) != SOS_OK) {
		ker_free(handle);
		return NULL_PID;	
	}
	return handle->pid;
}


/**
 * @brief register new module
 * NOTE: this function cannot be called in the interrupt handler
 * That is, the function is not thread safe
 * NOTE: h is stored in program memory, which can be different from RAM
 * special access function is needed.
 */
int8_t ker_register_module(mod_header_ptr h)
{
	sos_module_t *handle;
	int8_t ret;
	if(h == 0) return -EINVAL;
	//handle = (sos_module_t*)ker_malloc(sizeof(sos_module_t), KER_SCHED_PID);
	handle = (sos_module_t*)malloc_longterm(sizeof(sos_module_t), KER_SCHED_PID);
	if (handle == NULL) {
		return -ENOMEM;
	}
	ret = do_register_module(h, handle, NULL, 0, 0);
	if(ret != SOS_OK) {
		ker_free(handle);
	}
	return ret;
}

int8_t sched_register_kernel_module(sos_module_t *handle, mod_header_ptr h, void *state_ptr)
{
  sos_pid_t pid;

  if(h == 0) return -EINVAL;

  pid = sos_read_header_byte(h, offsetof(mod_header_t, mod_id));


  /*
   * Disallow the usage of thread ID
   */
  if(pid > APP_MOD_MAX_PID) return -EINVAL;

  handle->handler_state = state_ptr;
  handle->pid = pid;
  handle->header = h;
  handle->flag = SOS_KER_STATIC_MODULE;
	handle->next = NULL;

  return sched_register_module(handle, h, NULL, 0);
}


static int8_t do_register_module(mod_header_ptr h,
		sos_module_t *handle, void *init, uint8_t init_size,
		uint8_t flag)
{
  sos_pid_t pid;
  uint8_t st_size;
  int8_t ret;

  // Disallow usage of NULL_PID
  if(flag == SOS_CREATE_THREAD) {
	  pid = sched_get_pid_from_pool();
	  if(pid == NULL_PID) return -ENOMEM;
  } else {
	  pid = sos_read_header_byte(h, offsetof(mod_header_t, mod_id));
	  /*
	   * Disallow the usage of thread ID
	   */
	  if(pid > APP_MOD_MAX_PID) return -EINVAL;
  }


  // Read the state size and allocate a separate memory block for it
  st_size = sos_read_header_byte(h, offsetof(mod_header_t, state_size));
	//DEBUG("registering module pid %d with size %d\n", pid, st_size);
  if (st_size){
		//handle->handler_state = (uint8_t*)ker_malloc(st_size, pid);
		handle->handler_state = (uint8_t*)malloc_longterm(st_size, pid);
	// If there is no memory to store the state of the module
		if (handle->handler_state == NULL){
			return -ENOMEM;
		}
	} else {
		handle->handler_state = NULL;
	}

	// Initialize the data structure
	handle->header = h;
	handle->pid = pid;
  handle->flag = 0;
	handle->next = NULL;

  // add to the bin
  ret = sched_register_module(handle, h, init, init_size);
  if(ret != SOS_OK) {
	 ker_free(handle->handler_state); //! Free the memory block to hold module state
	return ret;
  }
  return SOS_OK;
}

/**
 * @brief de-register a task (module)
 * @param pid task id to be removed
 * Note that this function cannot be used inside interrupt handler
 */
int8_t ker_deregister_module(sos_pid_t pid)
{
  HAS_CRITICAL_SECTION;
  uint8_t bins = hash_pid(pid);
  sos_module_t *handle;
  sos_module_t *prev_handle = NULL;
  msg_handler_t handler;

  /**
   * Search the bins while save previous node
   * Once found the module, connect next module to previous one
   * put module back to freelist
   */
  handle = mod_bin[bins];
  while(handle != NULL) {
		if(handle->pid == pid) {
			break;
		} else {
			prev_handle = handle;
			handle = handle->next;
		}
	}
	if(handle == NULL) {
		// unable to find the module
		return -EINVAL;
	}
	handler = (msg_handler_t)sos_read_header_ptr(handle->header,
			offsetof(mod_header_t,
				module_handler));

	if(handler != NULL) {
		void *handler_state = handle->handler_state;
		Message msg;
		sos_pid_t prev_pid = curr_pid;

		curr_pid = handle->pid;
		msg.did = handle->pid;
		msg.sid = KER_SCHED_PID;
		msg.type = MSG_FINAL;
		msg.len = 0;
		msg.data = NULL;
		msg.flag = 0;
		handler(handler_state, &msg);
		curr_pid = prev_pid;
	}

	// First remove handler from the list.
	// link the bin back
	ENTER_CRITICAL_SECTION();
	if(prev_handle == NULL) {
		mod_bin[bins] = handle->next;
	} else {
		prev_handle->next = handle->next;
	}
	LEAVE_CRITICAL_SECTION();

	// remove the thread pid allocation
	if(handle->pid >= SCHED_MIN_THREAD_PID) {
		uint8_t i = handle->pid - SCHED_MIN_THREAD_PID;
		pid_pool[i/8] &= ~(1 << (i % 8));
  }


  // remove system services
  timer_remove_all(pid);
  sensor_remove_all(pid);
	//  ker_timestamp_deregister(pid);
  fntable_remove_all(handle);

  // free up memory
  // NOTE: we can only free up memory at the last step
  // because fntable is using the state
  if((SOS_KER_STATIC_MODULE & (handle->flag)) == 0) {
		ker_free(handle);
  }
  mem_remove_all(pid);

  return 0;
}


#ifdef FAULT_TOLERANT_SOS
static int8_t ker_micro_reboot_module(sos_module_t* handle)
{
  sos_pid_t pid;
  uint8_t st_size;
  uint8_t micro_reboot_fail = 0;
  mod_header_ptr hdr;
  Message msg_init;
  msg_handler_t handler;

  pid = handle->pid;
  DEBUG("!!!-----> INITIATING MICRO REBOOT OF MODULE %d\n", pid);

  // Micro-reboot can fail if we are unable to pre-allocate requested timers
  if (timer_micro_reboot(handle) != SOS_OK){
	DEBUG("Timers...FAIL...\n");
	micro_reboot_fail = 1;
  }
  else
	DEBUG("Timers ...OK...\n");


  // Deal with any pending clients
  sensor_micro_reboot(pid);



  // Purge all state owned by the module
  mem_remove_all(pid);


  // Read the state size and allocate a separate memory block for it
  hdr = handle->header;
  st_size = sos_read_header_byte(hdr, offsetof(mod_header_t, state_size));
  if (st_size){
		//handle->handler_state = (uint8_t*)ker_malloc(st_size, pid);
		handle->handler_state = (uint8_t*)malloc_longterm(st_size, pid);
	// This check is not required as we just freed all memory
		if (handle->handler_state == NULL)
			micro_reboot_fail = 1;
	}
	else
		handle->handler_state = NULL;

	// Micro-reboot the dynamic linking
	fntable_link_subscribed_functions(handle);

	if ((((handle->flag) & SOS_KER_STATIC_MODULE) == 0) &&
	  (handle->handler_state != NULL))
	mem_block_set_checksum(handle->handler_state);

  // Send INIT message to the recovered module
  handler = (msg_handler_t)sos_read_header_ptr(handle->header,
											   offsetof(mod_header_t,
														module_handler));
  msg_init.did = handle->pid;
  msg_init.sid = KER_SCHED_PID;
  msg_init.type = MSG_INIT;
  msg_init.len = 0;
  msg_init.data = NULL;
  msg_init.flag = 0;
  handler(handle->handler_state, &msg_init);

  return SOS_OK;
}
#endif//FAULT_TOLERANT_SOS

/**
 * @brief dispatch short message
 * This is used by the callback that was register by interrupt handler
 */
void sched_dispatch_short_message(sos_pid_t dst, sos_pid_t src,
		uint8_t type, uint8_t byte,
		uint16_t word, uint16_t flag)
{
	sos_module_t *handle;
	msg_handler_t handler;
	void *handler_state;

	MsgParam *p;

	handle = ker_get_module(dst);
	if( handle == NULL ) { return; }

	handler = (msg_handler_t)sos_read_header_ptr(handle->header,
			offsetof(mod_header_t,
				module_handler));
	handler_state = handle->handler_state;

	p = (MsgParam*)(short_msg.data);	

	short_msg.did = dst;
	short_msg.sid = src;
	short_msg.type = type;
	p->byte = byte;
	p->word = word;
	short_msg.flag = flag;

	/*
	 * Update current pid
	 */
	curr_pid = dst;
	ker_log( SOS_LOG_HANDLE_MSG, curr_pid, type );
		handler(handler_state, &short_msg);
		ker_log( SOS_LOG_HANDLE_MSG_END, curr_pid, type );
}


/**
 * @brief    real dispatch function
 * We have to handle MSG_PKT_SENDDONE specially
 * In SENDDONE message, msg->data is pointing to the message just sent.
 */

static void do_dispatch()
{
  Message *e;                                // Current message being dispatched
  sos_module_t *handle;                      // Pointer to the control block of the destination module
  Message *inner_msg = NULL;                 // Message sent as a payload in MSG_PKT_SENDDONE
  sos_pid_t senddone_dst_pid = NULL_PID;     // Destination module ID for the MSG_PKT_SENDDONE
  uint8_t senddone_flag = SOS_MSG_SEND_FAIL; // Status information for the MSG_PKT_SENDDONE

  SOS_MEASUREMENT_DEQUEUE_START();
  e = mq_dequeue(&schedpq);
  SOS_MEASUREMENT_DEQUEUE_END();
  handle = ker_get_module(e->did);
  // Destination module might muck around with the
  // type field. So we check type before dispatch
	if(e->type == MSG_PKT_SENDDONE) {
		inner_msg = (Message*)(e->data);
	}
	// Check for reliable message delivery
	if(flag_msg_reliable(e->flag)) {
		senddone_dst_pid = e->sid;	
	}
	// Deliver message to the monitor
	// Ram - Modules might access kernel domain here
	monitor_deliver_incoming_msg_to_monitor(e);

	if(handle != NULL) {
		if(sched_message_filtered(handle, e) == false) {
			int8_t ret;
			msg_handler_t handler;
			void *handler_state;

			DEBUG("###################################################################\n");
			DEBUG("MESSAGE FROM %d TO %d OF TYPE %d\n", e->sid, e->did, e->type);
			DEBUG("###################################################################\n");


			// Get the function pointer to the message handler
			handler = (msg_handler_t)sos_read_header_ptr(handle->header,
					offsetof(mod_header_t,
						module_handler));
			// Get the pointer to the module state
			handler_state = handle->handler_state;
			// Change ownership if the release flag is set
			// Ram - How to deal with memory blocks that are not released ?
			if(flag_msg_release(e->flag)){
				ker_change_own(e->data, e->did);
			}

#ifdef FAULT_TOLERANT_SOS		
			// Check for memory corruption in dynamic modules
			if (((handle->flag) & SOS_KER_STATIC_MODULE) == 0){
				int8_t mem_verify_status;
				// Check the integrity of all memory owned by the module
				mem_verify_status = mod_mem_verify_checksum(handle);
				// Check the integrity of the message payload being delivered to the module
				if (!flag_msg_release(e->flag)){
					if (mem_check_module_domain(e->data) == true){
						DEBUG("Checking CRC of the incoming message payload\n");
						if (mem_block_verify_checksum(e->data) != SOS_OK){
							// We cannot deliver corrupt message
							DEBUG("Message payload is corrupted\n");
							// We simply skip handling of this message for the time being
							ret = -EINVAL;
							goto skip_handler;
						}
					}
				}
				DEBUG("Message payload is verified corrent\n");
				// Micro-reboot the module if the memory integrity check failed
				if (mem_verify_status != SOS_OK){
					// XXX - Not checking if micro-reboot was a success or a failure
					LED_DBG(LED_RED_ON);
					ker_micro_reboot_module(handle);
					LED_DBG(LED_GREEN_ON);
					ret = -EINVAL;
					goto skip_handler;
				}
			}
			DEBUG("Memory integrity for the destination module is verified\n");
			// Everything is fine !! Ready to rock n roll
#endif

	  DEBUG("RUNNING HANDLER OF MODULE %d \n", handle->pid);
		curr_pid = handle->pid;
		ker_log( SOS_LOG_HANDLE_MSG, curr_pid, e->type );
	  ret = handler(handler_state, e);
		ker_log( SOS_LOG_HANDLE_MSG_END, curr_pid, e->type );
	  DEBUG("FINISHED HANDLER OF MODULE %d \n", handle->pid);

#ifdef FAULT_TOLERANT_SOS
	  //! Set new checksum value for dynamic modules
	  if (((handle->flag) & SOS_KER_STATIC_MODULE) == 0)
		mod_mem_set_checksum(handle);
skip_handler:
#endif
		if (ret == SOS_OK) senddone_flag = 0;
		}
	} else {
#if 0
		// TODO...
		//! take care MSG_FETCHER_DONE
		//! need to make sure that fetcher has completed its request
		if(e->type == MSG_FETCHER_DONE) {
			fetcher_state_t *fstat = (fetcher_state_t*)e->data;
			fetcher_commit(fstat, false);
		}
#endif
		//XXX no error notification for now.
		DEBUG("Scheduler: Unable to find module\n");
	}
	if(inner_msg != NULL) {
		//! this is SENDDONE message
		msg_dispose(inner_msg);
		msg_dispose(e);
	} else {
		if(senddone_dst_pid != NULL_PID) {
			if(post_long(senddone_dst_pid,
						KER_SCHED_PID,
						MSG_PKT_SENDDONE,
						sizeof(Message), e,
						senddone_flag) < 0) {
				msg_dispose(e);
			}
		} else {
			//! return message back to the pool
			msg_dispose(e);
		}
	}
}

/**
 * @brief query the existence of task
 * @param pid module id
 * @return 0 for exist, -EINVAL otherwise
 *
 */
int8_t ker_query_task(uint8_t pid)
{
  sos_module_t *handle = ker_get_module(pid);
  if(handle == NULL){
	return -EINVAL;
  }
  return 0;
}


void sched_msg_alloc(Message *m)
{
  if(flag_msg_release(m->flag)){
#ifdef FAULT_TOLERANT_SOS
	// Set the checksum before ownership transfer
	// Checksum will be checked only if the
	// destination module is dynamic
	if (m->did >= APP_MOD_MIN_PID){
	  DEBUG("Setting the CRC prior to posting message\n");
	  mem_block_set_checksum(m->data);
	}
#endif
	ker_change_own(m->data, KER_SCHED_PID);
  }	
	DEBUG("sched_msg_alloc\n");
  mq_enqueue(&schedpq, m);	
}

void sched_msg_remove(Message *m)
{
  Message *tmp;
  while(1) {
	tmp = mq_get(&schedpq, m);
	if(tmp) {
	  msg_dispose(tmp);
	} else {
	  break;
	}
  }
}


/**
 * @brief Message filtering rules interface
 * @param rules_in  new rule
 */
int8_t ker_msg_change_rules(sos_pid_t sid, uint8_t rules_in)
{
  sos_module_t *handle = ker_get_module(sid);
  if(handle == NULL) return -EINVAL;
  //! keep kernel state
  handle->flag &= 0x0F;

  handle->flag |= (rules_in & 0xF0);
  return 0;
}

/**
 * @brief get message rules
 */
int8_t sched_get_msg_rule(sos_pid_t pid, sos_ker_flag_t *rules)
{
  sos_module_t *handle = ker_get_module(pid);
  if(handle == NULL) return -EINVAL;
  *rules = handle->flag & 0xF0;
  return 0;
}

/**
 * @brief post crash check up
 */
#if 0
void sched_post_crash_checkup()
{
  sos_pid_t failed_pid;
  mod_handle_t h;

  while((failed_pid = mem_check_memory()) != NULL_PID) {
	// we probably need to report failure here
	h = sched_get_mod_handle(failed_pid);
	if(h >= 0) {
	  module_list[h].flag |= SOS_KER_MEM_FAILED;

	}
  }
  // Other crash testing goes here
}
#endif

#if 0
static void sched_send_crash_report()
{
  if(crash_report != NULL) {
	post_net(KER_SCHED_PID, KER_SCHED_PID, MSG_SCHED_CRASH_REPORT,
			 crash_report_len, crash_report, SOS_MSG_RELEASE, BCAST_ADDRESS);
  }
}
#endif

/**
 * @brief Message filter.
 * Check for promiscuous mode request in the destination module
 * @return true for message shoud be filtered out, false for message is valid
 */
static inline bool sched_message_filtered(sos_module_t *h, Message *m)
{
  sos_ker_flag_t rules;
  // check if it is from network
  if(flag_msg_from_network(m->flag) == 0) return false;
  rules = h->flag;

  // check for promiscuous mode
  if((rules & SOS_MSG_RULES_PROMISCUOUS) == 0){
	// module request to have no promiscuous message
	if(m->daddr != node_address && m->daddr != BCAST_ADDRESS){
	  DEBUG("filtered\n");
	  return true;
	}
  }
  return false;
}

void sched(void)
{
	ENABLE_GLOBAL_INTERRUPTS();

	ker_log_start();
	for(;;){
		SOS_MEASUREMENT_IDLE_END();
		DISABLE_GLOBAL_INTERRUPTS();

		if (int_ready != 0) {
			ENABLE_GLOBAL_INTERRUPTS();
			handle_callback();
		} else if( schedpq.msg_cnt != 0 ) {
			ENABLE_GLOBAL_INTERRUPTS();
			do_dispatch();
		} else {
			SOS_MEASUREMENT_IDLE_START();
			/**
			 * ENABLE_INTERRUPT() is done inside atomic_hardware_sleep()
			 */
			//ker_log_flush();
			//atomic_hardware_sleep();
			sei();
		}
		//watchdog_reset();
	}
}

