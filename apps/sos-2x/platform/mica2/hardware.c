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
 */
/**
 * @brief    hardware related routines
 * @author Simon Han (simonhan@ee.ucla.edu)
 *
 *
 */

#include "hardware.h"
// Timer
#include <timer.h>
#include <timer_conf.h>
// Leds
#define LED_DEBUG
#include <led_dbg.h>
// UART
#ifndef NO_SOS_UART
#include <uart_system.h>
#include <sos_uart.h>
#endif




  
//----------------------------------------------------------------------------
//  Typedefs
//----------------------------------------------------------------------------

//-------------------------------------------------------------------------
// FUNCTION DECLARATION
//-------------------------------------------------------------------------
void hardware_init(void){
  // LEDS
  led_init();

  // SYSTEM TIMER
  timer_hardware_init(DEFAULT_INTERVAL, DEFAULT_SCALE);

  // UART
  uart_system_init();
#ifndef NO_SOS_UART
  //! Initalize uart comm channel
  sos_uart_init();
#endif
}

//-------------------------------------------------------------------------
// MAIN
//-------------------------------------------------------------------------
int main(void)
{
  sos_main(SOS_BOOT_NORMAL);
  return 0;
}
