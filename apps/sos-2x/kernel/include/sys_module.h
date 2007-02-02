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
typedef int8_t (* sys_change_own_func_t)( void* ptr, uint8_t callerdomid);
#else
typedef int8_t (* sys_change_own_func_t)( void* ptr );
#endif

static inline int8_t sys_change_own( void* ptr )
{
#ifdef SOS_SFI
  return ((sys_change_own_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*2))(ptr, GET_MSR_DOM_ID());
#else
  return ((sys_change_own_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*2))(ptr);
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

static inline sys_msg_create(void)
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
typedef Message* (*sos_msg_dispose_func_t)(Message* m, uint8_t callerdomid);
#else
typedef Message* (*sos_msg_dispose_func_t)(Message* m);
#endif

static inline sys_msg_dispose(Message* m)
{
#ifdef SOS_SFI
  return ((sos_msg_dispose_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*5)(m, GET_MSR_DOM_ID()));
#else
  return ((sos_msg_dispose_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*5)(m));	  
#endif
}
//--------------------------------------------------------------------------------
// 6: ker_sys_msg_send_senddone
//--------------------------------------------------------------------------------


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
//===============================================================================
// MODULE STATE
//===============================================================================
//--------------------------------------------------------------------------------
// 10: ker_sys_get_module_state
//--------------------------------------------------------------------------------
typedef void* (* sys_get_module_state_func_t)( void );

static inline void* sys_get_state( void )
{
  return ((sys_get_module_state_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*10))( );
}
//--------------------------------------------------------------------------------
// 11: sys_set_state_pointer
//--------------------------------------------------------------------------------
typedef void (*sys_set_state_pointer_func_t)(sos_pid_t pid, void** hdl_state);

static inline void sys_set_state_pointer(sos_pid_t pid, void** hdl_state)
{
  return ((sys_set_state_pointer_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*11))(pid, hdl_state);
}
//--------------------------------------------------------------------------------
// 12: sys_register_module
//--------------------------------------------------------------------------------
typedef int8_t (*sys_register_module_func_t)(mod_header_ptr h);

static inline int8_t sys_register_module(mod_header_ptr h)
{
  return ((sys_register_module_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*12))(h);
}
//===============================================================================
// FUNCTION PTR PTR
//===============================================================================
//--------------------------------------------------------------------------------
// 13: ker_sys_fnptr_call - Implemented in assembly (sys_fnptr_call.S)
//--------------------------------------------------------------------------------
// 14: ker_sys_fntable_subscribe
//--------------------------------------------------------------------------------
typedef int8_t (* sys_fntable_subscribe_func_t)( sos_pid_t pub_pid, uint8_t fid, uint8_t table_index );

static inline int8_t sys_fntable_subscribe( sos_pid_t pub_pid, uint8_t fid, uint8_t table_index )
{
  return ((sys_fntable_subscribe_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*14))(pub_pid, fid, table_index);
}
//--------------------------------------------------------------------------------
// 15: ker_sys_timer_start
//--------------------------------------------------------------------------------
typedef int8_t (*sys_timer_start_ker_func_t)( uint8_t tid, int32_t interval, uint8_t type );

static inline int8_t sys_timer_start( uint8_t tid, int32_t interval, uint8_t type )
{
  return ((sys_timer_start_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*15))( tid, interval, type );
}
//--------------------------------------------------------------------------------
// 16: ker_sys_timer_restart
//--------------------------------------------------------------------------------
typedef int8_t (* sys_timer_restart_ker_func_t)( uint8_t tid, int32_t interval );

static inline int8_t sys_timer_restart( uint8_t tid, int32_t interval )
{    
  return ((sys_timer_restart_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*16))( tid, interval );
}
//--------------------------------------------------------------------------------
// 17: ker_sys_timer_stop
//--------------------------------------------------------------------------------
typedef int8_t (* sys_timer_stop_ker_func_t)( uint8_t tid );    

static inline int8_t sys_timer_stop( uint8_t tid ) 
{
  return ((sys_timer_stop_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*17))( tid );
}
//===============================================================================
// MISC.
//===============================================================================
//--------------------------------------------------------------------------------   
// 18: ker_hw_type
//--------------------------------------------------------------------------------   
typedef uint16_t (* sys_hw_type_ker_func_t)( void );             

static inline uint16_t sys_hw_type( void )                       
{
  return ((sys_hw_type_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*18))( );                                             
}     
//--------------------------------------------------------------------------------   
// 19: ker_id
//--------------------------------------------------------------------------------   
typedef uint16_t (* sys_id_ker_func_t)( void );                  

static inline uint16_t sys_id( void )
{
  return ((sys_id_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*19))( );
}
//--------------------------------------------------------------------------------   
// 20: ker_rand
//--------------------------------------------------------------------------------   
typedef uint16_t (* sys_rand_ker_func_t)( void );

static inline uint16_t sys_rand( void )
{
  return ((sys_rand_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*20))();
}
//--------------------------------------------------------------------------------   
// 21: ker_led
//--------------------------------------------------------------------------------   
typedef void (* sys_led_ker_func_t)( uint8_t op );

static inline void sys_led( uint8_t op )
{
  ((sys_led_ker_func_t)(SYS_JUMP_TBL_START+SYS_JUMP_TBL_SIZE*21))( op );
}

#endif//__SYS_MODULE_H__


