/*******************************************************************************************************
 *                                                                                                     *
 *        **********                                                                                   *
 *       ************                                                                                  *
 *      ***        ***                                                                                 *
 *      ***   +++   ***                                                                                *
 *      ***   + +   ***                                                                                *
 *      ***   +                        CHIPCON HARDWARE ABSTRACTION LIBRARY FOR THE CC2420             *
 *      ***   + +   ***                CC2420DK + STK500 + STK501 platform defintion file              *
 *      ***   +++   ***                                                                                *
 *      ***        ***                                                                                 *
 *       ************                                                                                  *
 *        **********                                                                                   *
 *                                                                                                     *
 *******************************************************************************************************
 * The Chipcon Hardware Abstraction Library is a collection of functions, macros and constants, which  *
 * can be used to ease access to the hardware on the CC2420 and the target microcontroller.            *
 *                                                                                                     *
 * This file contains all definitions that are specific for the CC2420DK + STK500 + STK501 development *
 * platform.                                                                                           *
 *******************************************************************************************************
 * Compiler: AVR-GCC                                                                                   *
 * Target platform: CC2420DK + STK500 + STK501                                                         *
 *******************************************************************************************************
 * Revision history:                                                                                   *
 *******************************************************************************************************/
#ifndef HAL_STK501_H
#define HAL_STK501_H




/*******************************************************************************************************
 *******************************************************************************************************
 **************************                   AVR I/O PORTS                   **************************
 *******************************************************************************************************
 *******************************************************************************************************/


//-------------------------------------------------------------------------------------------------------
// Port B:
#define CSN			0  // PB.0 - Output: SPI Chip Select (CS_N)
#define SCK			1  // PB.1 - Output: SPI Serial Clock (SCLK)
#define MOSI		2  // PB.2 - Output: SPI Master out - slave in (MOSI)
#define MISO		3  // PB.3 - Input:  SPI Master in - slave out (MISO)
#define CCA			4  // PB.4 - Input:  CCA from CC2420
#define FIFO		5  // PB.5 - Input:  FIFO from CC2420
#define RESET_N		6  // PB.6 - Output: RESET_N to CC2420
#define VREG_EN 	7  // PB.7 - Output: VREG_EN to CC2420
//-------------------------------------------------------------------------------------------------------


//-------------------------------------------------------------------------------------------------------
// Port D:
#define FIFOP		0  // PD.0 - Input:  FIFOP from CC2420
#define SFD			4  // PD.4 - Input:  SFD from CC2420
//-------------------------------------------------------------------------------------------------------


//-------------------------------------------------------------------------------------------------------
// Port setup macros

// Port initialization
// Debug signals on PORTD 1-3
// Disables pull-up on all inputs!!!
#define PORT_INIT() \
	do { \
    	SFIOR |= BM(PUD); \
    	DDRB  = BM(RESET_N) | BM(VREG_EN) | BM(MOSI) | BM(SCK) | BM(CSN); \
    	PORTB = BM(RESET_N) | BM(MOSI) | BM(SCK) | BM(CSN); \
    	DDRD  = 0x0E; \
    	SW_INIT(); \
    	LED_INIT(); \
	} while (0) 
	
// Enables/disables the SPI interface
#define SPI_ENABLE()                (PORTB = PINB & ~BM(CSN))
#define SPI_DISABLE()               (PORTB = PINB | BM(CSN))
//-------------------------------------------------------------------------------------------------------
 



/*******************************************************************************************************
 *******************************************************************************************************
 **************************                 CC2420 PIN ACCESS                 **************************
 *******************************************************************************************************
 *******************************************************************************************************/


//-------------------------------------------------------------------------------------------------------
// CC2420 pin access
#define FIFO_IS_1		(!!(PINB & BM(FIFO)))
#define CCA_IS_1		(!!(PINB & BM(CCA)))
#define RESET_IS_1		(!!(PINB & BM(RESET_N)))
#define VREG_IS_1		(!!(PINB & BM(VREG_EN)))
#define FIFOP_IS_1		(!!(PIND & BM(FIFOP)))
#define SFD_IS_1		(!!(PIND & BM(SFD)))

// CC2420 reset_n pin
#define SET_RESET_ACTIVE()    PORTB = PINB & ~BM(RESET_N)
#define SET_RESET_INACTIVE()  PORTB = PINB | BM(RESET_N)

// CC2420 voltage regulator enable pin
#define SET_VREG_ACTIVE()     PORTB = PINB | BM(VREG_EN)
#define SET_VREG_INACTIVE()   PORTB = PINB & ~BM(VREG_EN)
//-------------------------------------------------------------------------------------------------------




/*******************************************************************************************************
 *******************************************************************************************************
 **************************               EXTERNAL INTERRUPTS                 **************************
 *******************************************************************************************************
 *******************************************************************************************************/


//-------------------------------------------------------------------------------------------------------
// Rising edge trigger for external interrupt 0 (FIFOP)
#define FIFOP_INT_INIT()            do { EICRA |= 0x03; CLEAR_FIFOP_INT(); } while (0)

// FIFOP on external interrupt 0
#define ENABLE_FIFOP_INT()          do { EIMSK |= 0x01; } while (0)
#define DISABLE_FIFOP_INT()         do { EIMSK &= ~0x01; } while (0)
#define CLEAR_FIFOP_INT()           do { EIFR = 0x01; } while (0)
//-------------------------------------------------------------------------------------------------------


//-------------------------------------------------------------------------------------------------------
// SFD interrupt on timer 1 capture pin
#define ENABLE_SFD_CAPTURE_INT()    do { TIMSK |= BM(TICIE1); } while (0)
#define DISABLE_SFD_CAPTURE_INT()   do { TIMSK &= ~BM(TICIE1); } while (0)
#define CLEAR_SFD_CAPTURE_INT()     do { TIFR = BM(ICF1); } while (0)
//-------------------------------------------------------------------------------------------------------




/*******************************************************************************************************
 *******************************************************************************************************
 **************************                      BUTTONS                      **************************
 *******************************************************************************************************
 *******************************************************************************************************/


//-------------------------------------------------------------------------------------------------------
// Buttons
#define SW_PRESSED(n)               !(PINA & BM(n))
#define SW_MASK()                   (~PINA)

// Initialization macro
#define SW_INIT() \
    do { \
    	DDRA  = 0x00; \
    	PORTA = 0xFF; \
    } while (0)
//-------------------------------------------------------------------------------------------------------




/*******************************************************************************************************
 *******************************************************************************************************
 **************************                        LEDS                       **************************
 *******************************************************************************************************
 *******************************************************************************************************/


//-------------------------------------------------------------------------------------------------------
// LEDs
#define TOGGLE_LED(n)               (PORTC = PINC ^ BM(n))
#define SET_LED(n)	            	(PORTC = PINC & ~BM(n))
#define CLR_LED(n)		            (PORTC = PINC | BM(n))
#define INCR_LED()  	        	(PORTC = PINC - 1)
#define DECR_LED()  	        	(PORTC = PINC + 1)
#define SET_LED_MASK(n)	            (PORTC = (BYTE) ~(n))

// Initialization macro
#define LED_INIT() \
    do { \
    	DDRC  = 0xFF; \
    	PORTC = 0xFF; \
    } while (0)
//-------------------------------------------------------------------------------------------------------




/*******************************************************************************************************
 *******************************************************************************************************
 **************************               APPLICATION DEBUGGING               **************************
 *******************************************************************************************************
 *******************************************************************************************************/


//-------------------------------------------------------------------------------------------------------
// Debug pins on port D(3-1). Use values 0-7 (the outputs are available on the CC2400EB test port 2)
#define DEBUG(n) (PORTD = (PIND & 0xF1) | (n << 1))

// Controlled application crash (flashes the LEDs forever to indicate an error code)
#define EXCEPTION(n) \
    do { \
        DISABLE_GLOBAL_INT(); \
        SET_LED_MASK(0x00); \
        halWait(65535); \
        SET_LED_MASK(n); \
        halWait(65535); \
    } while (TRUE)
//-------------------------------------------------------------------------------------------------------


#endif