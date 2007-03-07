#ifndef _UMPU_EVAL_H_
#define _UMPU_EVAL_H_

#define SET_BIT(x) PORTB |= (1<<(x))
#define CLEAR_BIT(x) PORTB &= ~(1<<(x))

#ifdef UMPU_EVAL 
#define EVAL_START() {\
DDRB = 0xFF; \
PORTB = 0xFF; \
PORTB = 0x00; \
}

#define EVAL_STOP()  PORTB = 0x5A

#define AVG_BEGIN() SET_BIT(5)
#define AVG_DONE()  CLEAR_BIT(5)

#define FFT_BEGIN() SET_BIT(4)
#define FFT_DONE()  CLEAR_BIT(4)

#define UART_RECV_ISR_BEGIN() SET_BIT(0)
#define UART_RECV_ISR_DONE()  CLEAR_BIT(0)

#define UART_SEND_ISR_BEGIN() SET_BIT(1)
#define UART_SEND_ISR_DONE()  CLEAR_BIT(1)

#define UART_MSG_RECV() CLEAR_BIT(2)
#define UART_MSG_SENT() SET_BIT(2)

#define UART_MSG_INIT() SET_BIT(3)

#else
#define EVAL_START()
#define EVAL_STOP()

#define FFT_BEGIN()
#define FFT_DONE()

#define UART_RECV_ISR_BEGIN() 
#define UART_RECV_ISR_DONE() 

#define UART_SEND_ISR_BEGIN()
#define UART_SEND_ISR_DONE() 

#define UART_MSG_RECV() 
#define UART_MSG_SENT() 

#define UART_MSG_INIT()
#endif


#endif // _UMPU_EVAL_H_
