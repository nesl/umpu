/* -*- Mode: C; tab-width:4 -*- */
/* ex: set ts=4 shiftwidth=4 softtabstop=4 cindent: */
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

#ifndef _UART_HAL_H
#define _UART_HAL_H

/**
 * @brief UART_HAL config options
 */
// Assuming 8 MHz System Clock
#define BAUD_9600  51
#define BAUD_19_2k 25


/**
 * @brief check uart frame error and data overrun error
 * @return masked errors
 */
#define uart_checkError()        (USR & ((1<<FE)|(1<<DOR)))

#define uart_checkFramingError() (USR & (1<<FE))
#define uart_checkOverrunError() (USR & (1<<DOR))
//#define uart_checkParityError()  (UCSR0A & (1<<UPE))

#define uart_getByte()          (UDR)
#define uart_setByte(b)         (UDR = (b))

#ifdef SOS_SFI
extern void uart_recv_interrupt(void);
extern void uart_send_interrupt(void);
#else
#define uart_recv_interrupt()   SIGNAL(SIG_UART_RECV)
#define uart_send_interrupt()   SIGNAL(SIG_UART_TRANS)
#endif

#define uart_disable()			UCR &= ((unsigned char)~((1<<(RXCIE))|(1<<(TXCIE))))

#define uart_disable_tx()       UCR &= ((unsigned char)~(1<<(TXCIE)))
#define uart_enable_tx()        UCR |= (1<<(TXCIE))

#define uart_disable_rx()       UCR &= ((unsigned char)~(1<<(RXCIE)))
#define uart_enable_rx()        UCR |= (1<<(RXCIE))

#define uart_is_disabled()      ((UCR & (1 << TXCIE)) ? 0 : 1)

/**
 * @brief UART_HAL init
 */
int8_t uart_hardware_init(void);

#endif // _UART_HAL_H


