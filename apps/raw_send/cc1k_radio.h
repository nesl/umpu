
#ifndef __CC1K_RADIO_H__
#define __CC1K_RADIO_H__

void cc1k_radio_start_send( void* data, uint8_t size );

void cc1k_radio_start_recv( void* data, uint8_t size );

int8_t cc1k_radio_init( void );

int8_t cc1k_radio_start();

int8_t cc1k_radio_spi_interrupt(uint8_t data_in);

void radio_send(Message *m, void (*callback)());

void radio_recv(Message *m);

int8_t radio_init();
#endif


