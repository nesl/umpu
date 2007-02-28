#ifndef _UMPU_EVAL_H_
#define _UMPU_EVAL_H_

#define SET_BIT(x) PORTB |= (1<<(x))
#define CLEAR_BIT(x) PORTB &= ~(1<<(x))

#ifdef UMPU_EVAL 
#define EVAL_START() {\
PORTB = 0xFF; \
PORTB = 0x00; \
}

#define EVAL_STOP()  PORTB = 0x5A

#define UART_RECV_ISR_BEGIN() SET_BIT(0)
#define UART_RECV_ISR_DONE()  CLEAR_BIT(0)

#define UART_SEND_ISR_BEGIN() SET_BIT(1)
#define UART_SEND_ISR_DONE()  CLEAR_BIT(1)

#define UART_MSG_RECV() CLEAR_BIT(2)
#define UART_MSG_SENT() SET_BIT(2)

#define UART_MSG_INIT() SET_BIT(3)

#define MALLOC_START() SET_BIT(4)
#define MALLOC_DONE() CLEAR_BIT(4)

#define FREE_START() SET_BIT(5)
#define FREE_DONE() CLEAR_BIT(5)

#define CHANGE_OWN_START() SET_BIT(6)
#define CHANGE_OWN_DONE() CLEAR_BIT(6)

#else
#define EVAL_START()
#define EVAL_STOP()

#define UART_RECV_ISR_BEGIN() 
#define UART_RECV_ISR_DONE() 

#define UART_SEND_ISR_BEGIN()
#define UART_SEND_ISR_DONE() 

#define UART_MSG_RECV() 
#define UART_MSG_SENT() 

#define UART_MSG_INIT()

#define MALLOC_START() 
#define MALLOC_DONE() 

#define FREE_START()
#define FREE_DONE() 

#define CHANGE_OWN_START() 
#define CHANGE_OWN_DONE() 
#endif


#endif // _UMPU_EVAL_H_
