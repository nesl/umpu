/* -*- Mode: C; tab-width:4 -*- */
/* ex: set ts=4: */
/** 
 * port/pin naming scheme from the atmega128 datasheet.
 * if using avr-libc all names are declared in iom128.h which is included from io.h
 * 
 * Port names:
 * PORTx:	Data Register
 * DDRx:	Data Direction Register
 * PINx:	Port Input Pins
 *
 * Pin names:
 * DDxn:	Data Direction Bit
 * PORTxn:	Data Bit
 * Pxn:		Pin Input Bit
 */

#ifndef _PIN_ALT_FUNC_H_
#define _PIN_ALT_FUNC_H_

#include <pin_defs.h>
		
/**
 * PORTA: external memory address/data
 */
/* addr[7:0]/data[7:0] */
ALIAS_IO_PIN( AD7, PINA7);
ALIAS_IO_PIN( AD6, PINA6);
ALIAS_IO_PIN( AD5, PINA5);
ALIAS_IO_PIN( AD4, PINA4);
ALIAS_IO_PIN( AD3, PINA3);
ALIAS_IO_PIN( AD2, PINA2);
ALIAS_IO_PIN( AD1, PINA1);
ALIAS_IO_PIN( AD0, PINA0);


/**
 * PORTB: clock match register signals and SPI interface
 */
#define DDR_SPI DDRB //! alias for readiblity

/** Output Compare and PWM Output for Timer/Counter2
 * Output Compare and PWM Output C for Timer/Counter1 */
ALIAS_IO_PIN( OC2, PINB7);
/** Output Compare and PWM Output B for Timer/Counter1 */
ALIAS_IO_PIN( OC1B, PINB6);
/** Output Compare and PWM Output A for Timer/Counter1 */
ALIAS_IO_PIN( OC1A, PINB5);
/** Output Compare and PWM Output for Timer/Counter0 */
ALIAS_IO_PIN( OC0, PINB4);
/** SPI bus */
ALIAS_IO_PIN( MISO, PINB3);		//! Master Input/Slave Output
ALIAS_IO_PIN( MOSI, PINB2);		//! Master Output/Slave Input
ALIAS_IO_PIN( SCK, PINB1);		//! Serial Clock
ALIAS_IO_PIN( SS, PINB0);		//! /Slave Select input

/**
 * PORTC: high byte of memmory address
 */
/** addr[15:8] */
/* ALIAS_IO_PIN( A15, PINC7); */
/* ALIAS_IO_PIN( A14, PINC6); */
/* ALIAS_IO_PIN( A13, PINC5); */
/* ALIAS_IO_PIN( A12, PINC4); */
/* ALIAS_IO_PIN( A11, PINC3); */
/* ALIAS_IO_PIN( A10, PINC2); */
/* ALIAS_IO_PIN( A9, PINC1); */
/* ALIAS_IO_PIN( A8, PINC0); */


/**
 * PORTD: clock I/O, interrupt, USART1 and TWI
 */
/** Timer/Counter2 Clock Input */
ALIAS_IO_PIN( T2, PIND7);
/** Timer/Counter1 Clock Input */
ALIAS_IO_PIN( T1, PIND6);
/** Timer/Counter1 Input Capture Pin */
ALIAS_IO_PIN( ICP1, PIND4);
/** External Interrupt[3:0] Inputs */
ALIAS_IO_PIN( INT3, PIND3);
ALIAS_IO_PIN( INT2, PIND2);
ALIAS_IO_PIN( INT1, PIND1);
ALIAS_IO_PIN( INT0, PIND0);

/**
 * PORTE: interrupts, analog comparator, programming, clock I/O and usart0
 */
/** External Interrupt[7:4] Inputs */
ALIAS_IO_PIN( INT7, PINE7);
ALIAS_IO_PIN( INT6, PINE6);
ALIAS_IO_PIN( INT5, PINE5);
ALIAS_IO_PIN( INT4, PINE4);

/** Analog Comparator Inputs */
ALIAS_IO_PIN( AIN1, PINE3);	//! Negative Input
ALIAS_IO_PIN( AIN0, PINE2);	//! Positive Input

/** Programming Data Output */
ALIAS_IO_PIN( PDO, PINE1);
/** Programming Data Input */
ALIAS_IO_PIN( PDI, PINE0);

/** UART */
ALIAS_IO_PIN( TXD, PINE1);	//! UART0 Transmit Pin
ALIAS_IO_PIN( RXD, PINE1);	//! UART0 Recieve Pin

/**
 * PORTF: adc and jtag
 */
/* #define DDR_ADC DDRF	//! Alias for DDR */

/* /\** adc[7:0] *\/ */
/* ALIAS_IO_PIN( ADC7, PINF7); */
/* ALIAS_IO_PIN( ADC6, PINF6); */
/* ALIAS_IO_PIN( ADC5, PINF5); */
/* ALIAS_IO_PIN( ADC4, PINF4); */
/* ALIAS_IO_PIN( ADC3, PINF3); */
/* ALIAS_IO_PIN( ADC2, PINF2); */
/* ALIAS_IO_PIN( ADC1, PINF1); */
/* ALIAS_IO_PIN( ADC0, PINF0); */

#endif // _ARV_PIN_ALT_FUNC_H_
