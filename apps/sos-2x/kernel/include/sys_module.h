/**
 * \file sys_module.h
 * \brief System Jump Table
 * \author Ram Kumar {ram@ee.ucla.edu}
 */
#ifndef __SYS_MODULE_H__
#define __SYS_MODULE_H__

/*
#ifndef _MODULE_
#include <sos.h>
#endif

#include <sos_info.h>
#include <sos_types.h>
#include <sos_module_types.h>
#include <sos_timer.h>
#include <pid.h>
#include <stddef.h>
#include <sos_error_types.h>
#ifdef SOS_SFI
#include <sfi_jumptable.h>
#endif
*/

#ifdef SOS_SFI
#define FLASH_PAGE_SIZE 256L // For AVR only
#define SYS_JUMP_TBL_START (SFI_SYS_TABLE * FLASH_PAGE_SIZE)
#define SYS_JUMP_TBL_SIZE 4 // Jump Instruction takes 4 bytes
#endif

//===============================================================================
// MALLOC
//===============================================================================
//--------------------------------------------------------------------------------
// 0: ker_sys_malloc
//--------------------------------------------------------------------------------
#ifdef SOS_SFI
typedef void *  (* sys_malloc_ker_func_t)(uint16_t size, uint8_t callerdomid);
#else
typedef void *  (* sys_malloc_ker_func_t)( uint16_t size );
#endif

static inline void * sys_malloc( uint16_t size)
{
#ifdef SOS_SFI
  return ((sys_malloc_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*0))(size, GET_MSR_DOM_ID());
#else 
  return ((sys_malloc_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*0))(size);
#endif 
}
//--------------------------------------------------------------------------------
// 1: ker_sys_free
//--------------------------------------------------------------------------------
#ifdef SOS_SFI
typedef void (* sys_free_ker_func_t)(void * ptr, uint8_t callerdomid);
#else                                             
typedef void (* sys_free_ker_func_t)(void * ptr);
#endif            

static inline void sys_free( void *  ptr )                      
{                                          
#ifdef SOS_SFI
  ((sys_free_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*1))(ptr, GET_MSR_DOM_ID());
#else
  ((sys_free_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*1))( ptr );
#endif  
}   
//--------------------------------------------------------------------------------
// 2: ker_sys_change_own
//--------------------------------------------------------------------------------
#ifdef SOS_SFI
typedef int8_t (* sys_change_own_func_t)( void* ptr, sos_pid_t id, uint8_t callerdomid);
#else
typedef int8_t (* sys_change_own_func_t)( void* ptr, sos_pid_t id);
#endif

static inline int8_t sys_change_own(void* ptr, sos_pid_t id)
{
#ifdef SOS_SFI
  return ((sys_change_own_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*2))(ptr, id, GET_MSR_DOM_ID());
#else
  return ((sys_change_own_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*2))(ptr, id);
#endif
}
//===============================================================================
// MESSAGING
//===============================================================================
//--------------------------------------------------------------------------------
// 3: ker_sys_msg_take_data
//--------------------------------------------------------------------------------
typedef void *  (* sys_msg_take_data_ker_func_t)(Message *msg);

static inline void *  sys_msg_take_data(Message *  msg)       
{
  return ((sys_msg_take_data_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*3))( msg );                                         
}        
//--------------------------------------------------------------------------------
// 4: ker_sys_msg_create
//--------------------------------------------------------------------------------
#ifdef SOS_SFI
typedef Message* (*sys_msg_create_func_t)(uint8_t callerdomid);
#else
typedef Message* (*sys_msg_create_func_t)(void);
#endif

static inline Message* sys_msg_create(void)
{
#ifdef SOS_SFI
  return ((sys_msg_create_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*4))(GET_MSR_DOM_ID());
#else
  return ((sys_msg_create_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*4))();
#endif  
}
//--------------------------------------------------------------------------------
// 5: ker_sys_msg_dispose
//--------------------------------------------------------------------------------
#ifdef SOS_SFI
typedef void (*sos_msg_dispose_func_t)(Message* m, uint8_t callerdomid);
#else
typedef void (*sos_msg_dispose_func_t)(Message* m);
#endif

static inline void sys_msg_dispose(Message* m)
{
#ifdef SOS_SFI
  return ((sos_msg_dispose_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*5))(m, GET_MSR_DOM_ID());
#else
  return ((sos_msg_dispose_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*5))(m);	  
#endif
}
//--------------------------------------------------------------------------------
// 6: ker_sys_msg_send_senddone
//--------------------------------------------------------------------------------
typedef void (*msg_send_senddone_func_t)(Message* msg_sent, bool succ, sos_pid_t msg_owner);

static inline void sys_msg_send_senddone(Message *msg_sent, bool succ, sos_pid_t msg_owner)
{
  return ((msg_send_senddone_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*6))(msg_sent, succ, msg_owner);
}

//--------------------------------------------------------------------------------
// 7: ker_sys_post
//--------------------------------------------------------------------------------
typedef int8_t (* sys_post_ker_func_t)( sos_pid_t dst_mod_id, uint8_t type, uint8_t size, void *  data, uint16_t flag );

static inline int8_t sys_post( sos_pid_t dst_mod_id, uint8_t type, uint8_t size, void *  data, uint16_t flag )
{                 
  return ((sys_post_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*7))( dst_mod_id, type, size, data, flag );          
}             
//--------------------------------------------------------------------------------
// 8: ker_sys_post_link
//--------------------------------------------------------------------------------
typedef int8_t (* sys_post_link_ker_func_t)( sos_pid_t dst_mod_id, uint8_t type, uint8_t size, void *  data, uint16_t flag, uint16_t dst_node_addr );

static inline int8_t sys_post_link( sos_pid_t dst_mod_id, uint8_t type, uint8_t size, void *  data, uint16_t flag, uint16_t dst_node_addr )
{
  return ((sys_post_link_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*8))( dst_mod_id, type, size, data, flag, dst_node_addr );
}

#define sys_post_net(dst_mod_id, type, size, data, flag, dst_node_addr)   sys_post_link((dst_mod_id), (type), (size), (data), ((flag) | SOS_MSG_RADIO_IO), (dst_node_addr))

#define sys_post_uart(dst_mod_id, type, size, data, flag, dst_node_addr)   sys_post_link((dst_mod_id), (type), (size), (data), ((flag) | SOS_MSG_UART_IO), (dst_node_addr))

#define sys_post_i2c(dst_mod_id, type, size, data, flag, dst_node_addr)   sys_post_link((dst_mod_id), (type), (size), (data), ((flag) | SOS_MSG_I2C_IO), (dst_node_addr))
//--------------------------------------------------------------------------------
// 9: ker_sys_post_value
//--------------------------------------------------------------------------------
typedef int8_t (* sys_post_value_ker_func_t)( sos_pid_t dst_mod_id, uint8_t type, uint32_t data, uint16_t flag );

static inline int8_t sys_post_value( sos_pid_t dst_mod_id, uint8_t type, uint32_t data, uint16_t flag )
{
  return ((sys_post_value_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*9))( dst_mod_id, type, data, flag );
}
//--------------------------------------------------------------------------------
// 10: sys_sched_msg_alloc
//--------------------------------------------------------------------------------
typedef void (*ker_sys_sched_msg_alloc_func_t)(Message* msg);

static inline void sys_sched_msg_alloc(Message* msg)
{
  return ((ker_sys_sched_msg_alloc_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*10))(msg);
}
// Ram - Probably do not need this function
/*
typedef void (*ker_sys_handle_incoming_msg_func_t)(Message* msg, uint16_t channel);

static inline void sys_handle_incoming_msg(Message* msg, uint16_t channel)
{
  return ((ker_sys_handle_incoming_msg_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*10))(msg, channel);
}
*/
//===============================================================================
// MODULE STATE
//===============================================================================
//--------------------------------------------------------------------------------
// 11: ker_sys_get_module_state
//--------------------------------------------------------------------------------
typedef void* (* sys_get_module_state_func_t)( void );

static inline void* sys_get_state( void )
{
  return ((sys_get_module_state_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*11))( );
}
//--------------------------------------------------------------------------------
// 12: sys_set_state_pointer
//--------------------------------------------------------------------------------
typedef void (*sys_set_state_pointer_func_t)(void* state, void** hdl_state);

static inline void sys_set_state_pointer(void* state, void** hdl_state)
{
  return ((sys_set_state_pointer_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*12))(state, hdl_state);
}
//--------------------------------------------------------------------------------
// 13: sys_register_module
//--------------------------------------------------------------------------------
typedef int8_t (*sys_register_module_func_t)(mod_header_ptr h);

static inline int8_t sys_register_module(mod_header_ptr h)
{
  return ((sys_register_module_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*13))(h);
}
//===============================================================================
// FUNCTION PTR PTR
//===============================================================================
//--------------------------------------------------------------------------------
// 14: ker_sys_fnptr_call - Implemented in assembly (sys_fnptr_call.S)
//--------------------------------------------------------------------------------
// 15: ker_sys_fntable_subscribe
//--------------------------------------------------------------------------------
typedef int8_t (* sys_fntable_subscribe_func_t)( sos_pid_t pub_pid, uint8_t fid, uint8_t table_index );

static inline int8_t sys_fntable_subscribe( sos_pid_t pub_pid, uint8_t fid, uint8_t table_index )
{
  return ((sys_fntable_subscribe_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*15))(pub_pid, fid, table_index);
}
//===============================================================================
// TIMER
//===============================================================================
//--------------------------------------------------------------------------------
// 16: ker_sys_timer_init
//--------------------------------------------------------------------------------
typedef int8_t (*sys_timer_init_func_t)(uint8_t tid, uint8_t type);

static inline int8_t sys_timer_init(uint8_t tid, uint8_t type)
{
  return ((sys_timer_init_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*16))(tid, type);
}
//--------------------------------------------------------------------------------
// 17: ker_sys_timer_start
//--------------------------------------------------------------------------------
typedef int8_t (*sys_timer_start_ker_func_t)( uint8_t tid, int32_t interval, uint8_t type );

static inline int8_t sys_timer_start( uint8_t tid, int32_t interval, uint8_t type )
{
  return ((sys_timer_start_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*17))( tid, interval, type );
}
//--------------------------------------------------------------------------------
// 18: ker_sys_timer_restart
//--------------------------------------------------------------------------------
typedef int8_t (* sys_timer_restart_ker_func_t)( uint8_t tid, int32_t interval );

static inline int8_t sys_timer_restart( uint8_t tid, int32_t interval )
{    
  return ((sys_timer_restart_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*18))( tid, interval );
}
//--------------------------------------------------------------------------------
// 19: ker_sys_timer_stop
//--------------------------------------------------------------------------------
typedef int8_t (* sys_timer_stop_ker_func_t)( uint8_t tid );    

static inline int8_t sys_timer_stop( uint8_t tid ) 
{
  return ((sys_timer_stop_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*19))( tid );
}
//===============================================================================
// MISC.
//===============================================================================
//--------------------------------------------------------------------------------   
// 20: ker_hw_type
//--------------------------------------------------------------------------------   
typedef uint16_t (* sys_hw_type_ker_func_t)( void );             

static inline uint16_t sys_hw_type( void )                       
{
  return ((sys_hw_type_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*20))( );                                             
}     
//--------------------------------------------------------------------------------   
// 21: ker_id
//--------------------------------------------------------------------------------   
typedef uint16_t (* sys_id_ker_func_t)( void );                  

static inline uint16_t sys_id( void )
{
  return ((sys_id_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*21))( );
}
//--------------------------------------------------------------------------------   
// 22: ker_rand
//--------------------------------------------------------------------------------   
typedef uint16_t (* sys_rand_ker_func_t)( void );

static inline uint16_t sys_rand( void )
{
  return ((sys_rand_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*22))();
}
//--------------------------------------------------------------------------------   
// 23: ker_led
//--------------------------------------------------------------------------------   
typedef void (* sys_led_ker_func_t)( uint8_t op );

static inline void sys_led( uint8_t op )
{
  ((sys_led_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*23))( op );
}
//--------------------------------------------------------------------------------   
// 24: set_uart_address
//--------------------------------------------------------------------------------   
typedef void (*set_uart_address_func_t)(uint16_t addr);

static inline void sys_set_uart_address(uint16_t addr)
{
 ((set_uart_address_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*24))(addr);
}
#endif//__SYS_MODULE_H__


