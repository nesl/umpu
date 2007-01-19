/* -*- Mode: C; tab-width:4 -*- */
/* ex: set ts=4: */

#include <pin_map.h>
#include <avr/io.h>
#include <avr/interrupt.h>
//#include <avr/signal.h>
#include <stdlib.h>
#include "hardware.h"
#include "cc1k_radio.h"
#include "radio_spi.h"
#include "cc1k.h"
#include "led.h"

static uint8_t OutgoingByte;

SIGNAL (SIG_SPI) {
    register uint8_t temp;
    temp = SPDR;
    SPDR = OutgoingByte;
	asm volatile("spi_begin:");
    cc1k_radio_spi_interrupt(temp);
	asm volatile("spi_end:");
	asm volatile("nop");
}

void spi_writeByte(uint8_t data)
{
    HAS_CRITICAL_SECTION;
    ENTER_CRITICAL_SECTION();
    OutgoingByte = data;
    LEAVE_CRITICAL_SECTION();
}

void spi_init()
{
	SET_SCK_DD_IN();
    SET_MISO_DD_IN(); // miso
    SET_MOSI_DD_IN(); // mosi
    SPCR &= ~(1<<(CPOL));    // Set proper polarity...
    SPCR &= ~(1<<(CPHA));    // ...and phase
    SPCR |= (1<<(SPIE));  // enable spi port
    SPCR |= (1<<(SPE));
}


