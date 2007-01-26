
/**
 * @brief header file for UART0
 * @auther Simon Han
 * 
 */

#ifndef _SOS_UART_H_
#define _SOS_UART_H_


#ifndef _MODULE_
#include <message_types.h>
#include <sos_types.h>

/**
 * init function
 */

#ifndef DISABLE_UART
#ifndef NO_SOS_UART
extern void sos_uart_init(void);
#else
#define sos_uart_init()
#endif
#else
#define sos_uart_init()
#endif


/**
 * @brief allocate uart message
 * @return Message poiner or NULL for failure
 */
#ifndef DISABLE_UART
#ifndef NO_SOS_UART
extern void uart_msg_alloc(Message *e);
#else
#define uart_msg_alloc(e) 
#endif
#else
#define uart_msg_alloc(e) 
#endif

#endif /* _MODULE_ */

#endif
