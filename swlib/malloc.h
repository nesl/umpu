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

#include <inttypes.h>
#include <memmap.h>
#include <avrdefs.h>
#include <malloc_conf.h>




/**
 * @brief Init function for memory manager
 */
extern void mem_init(void);


/**
 * @brief Allocate a chunk of blocks from the heap
 */
extern void *mmc_int_alloc(uint16_t size, uint8_t calleedomid);

/**
 * @brief Free a block back into the heap
 */
extern void mmc_int_free(void* ptr, uint8_t calleedomid);


/**
 * @brief Change memory ownership of a segment of memory
 */
extern int8_t mmc_int_change_own(void* ptr, uint8_t calleedomid, uint8_t newdomid);


#define DOMTRUST_JMP_TBL_START 0x2700

/**
 * @brief Allocate dynamic memory
 * @param size Number of bytes to allocate
 * @return Returns a pointer to the allocated memory.
 * Will return a NULL pointer if the call to sys_malloc fails.
 */
typedef void* (*malloc_func_t)(uint16_t size, uint8_t calleedomid);
static inline void *mmc_malloc(uint16_t size)
{
  return ((malloc_func_t)(DOMTRUST_JMP_TBL_START + 0))(size, GET_MSR_DOM_ID());
}



/**
 * @brief Free memory pointed to by ptr
 * @param ptr Pointer to the memory that should be released
 * @return void
 */
typedef void (*free_func_t)(void* ptr, uint8_t calleedomid);
static inline void mmc_free(void* ptr)
{
  return ((free_func_t)(DOMTRUST_JMP_TBL_START + JMP_TBL_ENTRY_SIZE*1))(ptr, GET_MSR_DOM_ID());
}

/**
 * @brief Change the ownership of memory
 * @param ptr Pointer to the memory whose ownership is being transferred
 * @param newdomid New owner of the memeory
 * @return SOS_OK or error code upon fail
 */
typedef int8_t (*change_own_func_t)(void* ptr, uint8_t calleedomid, uint8_t newdomid);
static inline int8_t mmc_change_own(void* ptr, uint8_t newdomid)
{
  return ((change_own_func_t)(DOMTRUST_JMP_TBL_START + JMP_TBL_ENTRY_SIZE*2))(ptr, GET_MSR_DOM_ID(), newdomid);
}


#endif

