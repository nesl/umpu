/* -*- Mode: C; tab-width:4 -*- */
/* ex: set ts=4 shiftwidth=4 softtabstop=4 cindent: */
/**
 * @brief    uart hdlc driver
 * @author	 Naim Busek <ndbusek@gmail.com>
 *
 */

#include <hardware.h>
#include <net_stack.h>
#include <sos_info.h>
#include <crc.h>
#include <measurement.h>
#include <malloc.h>

#include <uart_hal.h>

static bool uart_initialized = false;

int8_t uart_hardware_init(void){
	HAS_CRITICAL_SECTION;

	if(uart_initialized == false) {
	  ENTER_CRITICAL_SECTION();
#ifndef DISABLE_UART
	  
	  //! UART will run at: 9.6kbps, N-8-1
	  UBRR = (uint8_t) (BAUD_9600);

	  /**
	   * Enable reciever and transmitter and their interrupts
	   * transmit interrupt will be disabled until there is 
	   * packet to send.
	   */
	  UCR = ((1 << RXCIE) | (1 << RXEN) | (1 << TXEN));


#ifdef SOS_USE_PRINTF
		fdevopen(uart_putchar, NULL, 0);
#endif
#else
		uart_disable();
#endif

		LEAVE_CRITICAL_SECTION();
		uart_initialized = true;
	}
	return SOS_OK;
}

