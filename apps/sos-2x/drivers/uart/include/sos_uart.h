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

#if ((!defined DISABLE_UART) && (!defined NO_SOS_UART))

/**
 * @brief Init function
 */
extern void sos_uart_init(void);

/**
 * @brief allocate uart message
 * @return Message poiner or NULL for failure
 */
extern void uart_msg_alloc(Message *e);
#else
#define sos_uart_init()
#define uart_msg_alloc(e) 
#endif

#endif /* _MODULE_ */
#endif
