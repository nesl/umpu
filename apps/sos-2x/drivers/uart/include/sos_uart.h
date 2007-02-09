/**
 * @brief header file for UART0
 * @auther Simon Han
 * 
 */

#ifndef _SOS_UART_H_
#define _SOS_UART_H_

#include <message_types.h>
#include <sos_types.h>
#ifdef SOS_SFI
#include <sfi_jumptable.h>
#include <malloc.h>
#endif

#if ((!defined DISABLE_UART) && (!defined NO_SOS_UART))
//------------------------------------
// UART ENABLED
//------------------------------------
#ifdef SOS_SFI
#define UART_DOM_ID SFI_DOM0
#endif

// Prototypes of the acutal function implementations
void sos_uart_init_real();
void uart_msg_alloc_real(Message *m);

/**
 * @brief Init function
 */
#ifdef SOS_SFI
typedef void (*sos_uart_init_func_t)(void);
static inline void sos_uart_init(void){
  return ((sos_uart_init_func_t)(SFI_JMP_TABLE_FUNC(UART_DOM_ID, 1)))();
}
#else
#define sos_uart_init()  sos_uart_init_real()
#endif//SOS_SFI

/**
 * @brief allocate uart message
 * @return Message poiner or NULL for failure
 */
#ifdef SOS_SFI
typedef void (*uart_msg_alloc_func_t)(Message *e);
static inline void uart_msg_alloc(Message *e){
  ker_change_own((void*)e, KER_UART_PID);
  return ((uart_msg_alloc_func_t)(SFI_JMP_TABLE_FUNC(UART_DOM_ID, 2)))(e);
}
#else
#define uart_msg_alloc(e) uart_msg_alloc_real(e)
#endif//SOS_SFI


#ifdef SOS_SFI
typedef void (*uart_recv_interrupt_func_t)(void);
static inline void uart_driver_recv_interrupt(void){
  return ((uart_recv_interrupt_func_t)(SFI_JMP_TABLE_FUNC(UART_DOM_ID, 3)))();
}

typedef void (*uart_send_interrupt_func_t)(void);
static inline void uart_driver_send_interrupt(void){
  return ((uart_send_interrupt_func_t)(SFI_JMP_TABLE_FUNC(UART_DOM_ID, 4)))();
}
#endif//SOS_SFI


#else
//------------------------------------
// UART DISABLED
//------------------------------------
#define sos_uart_init()
#define uart_msg_alloc(e) 

#endif//((!defined DISABLE_UART) && (!defined NO_SOS_UART))


#endif//_SOS_UART_H_
