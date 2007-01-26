/* -*- Mode: C; tab-width:4 -*- */
/* ex: set ts=4: */
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
 * @brief    Allocte and free dynamic memory 
 * @author   Roy Shea (roy@cs.ucla.edu) 
 */
#ifndef _MALLOC_H_
#define _MALLOC_H_

#include <sos_types.h>
#include <pid.h>
#include <malloc_conf.h>
#include <sos_module_types.h>
#ifdef SOS_SFI
#include <umpu.h>
#endif

/**
 * @brief Init function for memory manager
 */
extern void mem_init(void);

/**
 * @brief Starting memory module interface
 */
extern void mem_start(void);

/**
 * @brief Allocate a chunk of blocks from the heap
 */
#ifdef SOS_SFI
extern void* sos_blk_mem_alloc(uint16_t size, sos_pid_t id, uint8_t calleedomid);
#else
extern void* sos_blk_mem_alloc(uint16_t size, sos_pid_t id);
#endif

/**
 * @brief Free a block back into the heap
 */
#ifdef SOS_SFI
extern void sos_blk_mem_free(void* pntr, uint8_t calleedomid);
#else
extern void sos_blk_mem_free(void* ptr);
#endif


/**
 * @brief Change memory ownership of a segment of memory
 */
#ifdef SOS_SFI
extern int8_t sos_blk_mem_change_own(void* ptr, sos_pid_t id, uint8_t calleedomid) ;
#else
extern int8_t sos_blk_mem_change_own(void* ptr, sos_pid_t id); 
#endif

/**
 * @brief Allocate a block of memory for long term usage
 */
#ifdef SOS_SFI
extern void* sos_blk_mem_longterm_alloc(uint16_t size, sos_pid_t id, uint8_t calleedomid);
#else
extern void* sos_blk_mem_longterm_alloc(uint16_t size, sos_pid_t id);
#endif

/**
 * @brief Allocate dynamic memory
 * @param size Number of bytes to allocate
 * @param id Node responsible for the memory
 * @return Returns a pointer to the allocated memory.
 * Will return a NULL pointer if the call to sys_malloc fails.
 */
static inline void *ker_malloc(uint16_t size, sos_pid_t id)
{
#ifdef SOS_SFI
  return sos_blk_mem_alloc(size, id, GET_MSR_DOM_ID());
#else
  return sos_blk_mem_alloc(size, id);
#endif
}

/**
 * @brief Free memory pointed to by ptr
 * @param ptr Pointer to the memory that should be released
 * @return void
 */
static inline void ker_free(void* ptr)
{
#ifdef SOS_SFI
  sos_blk_mem_free(ptr, GET_MSR_DOM_ID());
#else
  sos_blk_mem_free(ptr);
#endif
  return;
}

/**
 * @brief Change the ownership of memory
 * @param ptr Pointer to the memory whose ownership is being transferred
 * @param id New owner of the memeory
 * @return SOS_OK or error code upon fail
 * Add check to prevent a change of ownership to the 'null' user.
 */
static inline int8_t ker_change_own(void* ptr, sos_pid_t id)
{
#ifdef SOS_SFI
  return sos_blk_mem_change_own(ptr, id, GET_MSR_DOM_ID());
#else
  return sos_blk_mem_change_own(ptr, id);
#endif
}


/**
 * @brief Free up all memory held by id 
 * @param id Process that is having its memory returned
 */
extern int8_t mem_remove_all(sos_pid_t id);

/**
 * @brief malloc for long term usage
 * @warning this is used to allocate the memory for long time usage
 */
static inline void* malloc_longterm(uint16_t size, sos_pid_t id)
{
#ifdef SOS_SFI
  return sos_blk_mem_longterm_alloc(size, id, GET_MSR_DOM_ID());
#else
  return sos_blk_mem_longterm_alloc(size, id);
#endif
}


/**
 * force kernel enters panic mode
 * 
 * @note used by SOS kernel ONLY
 * @note ker_panic is weak symbol: appplication can redefine it.
 * ker_panic focrce kernel enters panic mode
 * In panic mode, kernel disables all modules and does folowing task.
 * 1. Toggling all LEDs (if available) sequentially and repeat
 * 2. Sending out memory dump periodically
 * 
 */
int8_t ker_panic(void);

/**
 * Notify a particular module is in panic.
 * 
 * @note used by SYS API to notify possible module failure. 
 * @note ker_mod_panic is a weak symbol: application can redefine it.
 * 
 * In module panic mode: it will call ker_panic() until we define 
 * further semantic
 */
int8_t ker_mod_panic(sos_pid_t pid);

#endif

