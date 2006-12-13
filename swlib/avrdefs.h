/**
 * \file avrdefs.h
 * \brief AVR Specific Definitions
 */

#ifndef _AVRDEFS_H_
#define _AVRDEFS_H_


//--------------------------------------------------
// CRITICAL SECTION MACROS
//--------------------------------------------------
#define HAS_CRITICAL_SECTION       register uint8_t _prev_

#define ENTER_CRITICAL_SECTION()  \
asm volatile ( \
	"in %0, __SREG__"   "\n\t" \
	"cli"               "\n\t" \
	: "=r" (_prev_) \
	: )

#define LEAVE_CRITICAL_SECTION() \
asm volatile ( \
	"out __SREG__, %0"   "\n\t" \
	: \
	: "r" (_prev_) )


#define JMP_TBL_ENTRY_SIZE 4


#endif//_AVRDEFS_H_
