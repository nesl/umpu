/* -*- Mode: C; tab-width:4 -*- */
/* ex: set ts=4 shiftwidth=4 softtabstop=4 cindent: */

#ifndef __RADIO_SPI_H__
#define __RADIO_SPI_H__


/**
 * @brief SPI related functions
 */
#define spi_isBufBusy()  bit_is_clear(SPSR,SPIF)
void spi_init();

#define spi_enableIntr() do{ SPCR = 0xC0; DDRB &= ~(1);} while(0)
#define spi_disableIntr() do{ SPCR &= ~(0xC0); DDRB |= (1); PORTB &= ~(1);}while(0)
#define spi_txmode() do{ SET_MISO_DD_OUT(); SET_MOSI_DD_OUT(); }while(0)
#define spi_rxmode() do{ SET_MISO_DD_IN(); SET_MOSI_DD_IN(); }while(0)

void spi_writeByte(uint8_t data);

#endif // _SOS_SPI_H

