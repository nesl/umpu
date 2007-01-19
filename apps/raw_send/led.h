
#ifndef _LED_H_
#define _LED_H_

#define led_init()          DDRA |= 0x07
#define led_red_on()        PORTA &= ~(1<<(2))
#define led_green_on()      PORTA &= ~(1<<(1))
#define led_yellow_on()     PORTA &= ~(1)
#define led_red_off()       PORTA |= (1<<(2))
#define led_green_off()     PORTA |= (1<<(1))
#define led_yellow_off()    PORTA |= 1
#define led_red_toggle()    PORTA ^= (1 << 2)
#define led_green_toggle()  PORTA ^= (1 << 1)
#define led_yellow_toggle() PORTA ^= 1


#endif


