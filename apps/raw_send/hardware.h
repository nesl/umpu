
#ifndef __HARDWARE_H__
#define __HARDWARE_H__

#include <avr/io.h>
#define DISABLE_GLOBAL_INTERRUPTS()   asm volatile("cli")
#define ENABLE_GLOBAL_INTERRUPTS()    asm volatile("sei")
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

#define SLEEP()                     \
do {                                \
	MCUCR |= (1 <<(SE));            \
		asm volatile ("sei");           \
		asm volatile ("sleep");         \
		asm volatile ("nop");           \
		asm volatile ("nop");           \
} while(0)

typedef struct Message{
	uint8_t  did;                          //!< module destination id
	uint8_t  sid;                          //!< module source id
	uint16_t daddr;                          //!< node destination address
	uint16_t saddr;                          //!< node source address
	uint8_t  type;                           //!< module specific message type
	uint8_t  len;                            //!< payload length 
	uint8_t  *data;                          //!< actual payload
	uint16_t flag;                           //!< flag to indicate the status of message, see below
	uint8_t payload[4]; //!< statically allocated payload
	struct Message *next;                    //!< link list for the Message
} __attribute__ ((packed))
Message;

void sched_post( void (*tp) () );
void sched_init();
void sched_loop();

#endif


