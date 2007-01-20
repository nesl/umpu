# 1 "blink.c"
# 1 "<built-in>"
# 1 "<command line>"
# 1 "blink.c"
# 13 "blink.c"
# 1 "../../../kernel/include/sys_module.h" 1







# 1 "../../../kernel/include/sos_info.h" 1
# 10 "../../../kernel/include/sos_info.h"
# 1 "../../../kernel/include/sos_types.h" 1
# 47 "../../../kernel/include/sos_types.h"
# 1 "../../../platform/mica2/include/hardware_types.h" 1





# 1 "../../../processor/avr/include/hardware_proc.h" 1






# 1 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/avr/io.h" 1 3
# 86 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/avr/io.h" 3
# 1 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/avr/sfr_defs.h" 1 3
# 123 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/avr/sfr_defs.h" 3
# 1 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/inttypes.h" 1 3
# 36 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/inttypes.h" 3
# 1 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/stdint.h" 1 3
# 65 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/stdint.h" 3
typedef signed char int8_t;




typedef unsigned char uint8_t;
# 104 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/stdint.h" 3
typedef int int16_t;




typedef unsigned int uint16_t;
# 120 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/stdint.h" 3
typedef long int32_t;




typedef unsigned long uint32_t;
# 136 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/stdint.h" 3
typedef long long int64_t;




typedef unsigned long long uint64_t;
# 155 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/stdint.h" 3
typedef int16_t intptr_t;




typedef uint16_t uintptr_t;
# 37 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/inttypes.h" 2 3
# 124 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/avr/sfr_defs.h" 2 3
# 87 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/avr/io.h" 2 3
# 168 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/avr/io.h" 3
# 1 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/avr/iom128.h" 1 3
# 169 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/avr/io.h" 2 3
# 256 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/avr/io.h" 3
# 1 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/avr/portpins.h" 1 3
# 257 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/avr/io.h" 2 3
# 8 "../../../processor/avr/include/hardware_proc.h" 2
# 1 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/avr/interrupt.h" 1 3
# 134 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/avr/interrupt.h" 3
static __inline__ void timer_enable_int (unsigned char ints)
{

    (*(volatile uint8_t *)((0x37) + 0x20)) = ints;

}
# 9 "../../../processor/avr/include/hardware_proc.h" 2




# 1 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/avr/pgmspace.h" 1 3
# 69 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/avr/pgmspace.h" 3
# 1 "/usr/local/lib/gcc/avr/3.4.3/include/stddef.h" 1 3 4
# 213 "/usr/local/lib/gcc/avr/3.4.3/include/stddef.h" 3 4
typedef unsigned int size_t;
# 70 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/avr/pgmspace.h" 2 3
# 90 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/avr/pgmspace.h" 3
typedef void prog_void __attribute__((__progmem__));
typedef char prog_char __attribute__((__progmem__));
typedef unsigned char prog_uchar __attribute__((__progmem__));

typedef int8_t prog_int8_t __attribute__((__progmem__));
typedef uint8_t prog_uint8_t __attribute__((__progmem__));
typedef int16_t prog_int16_t __attribute__((__progmem__));
typedef uint16_t prog_uint16_t __attribute__((__progmem__));

typedef int32_t prog_int32_t __attribute__((__progmem__));
typedef uint32_t prog_uint32_t __attribute__((__progmem__));


typedef int64_t prog_int64_t __attribute__((__progmem__));
typedef uint64_t prog_uint64_t __attribute__((__progmem__));
# 490 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/avr/pgmspace.h" 3
extern void *memcpy_P(void *, const prog_void *, size_t);
extern char *strcat_P(char *, const prog_char *);
extern int strcmp_P(const char *, const prog_char *) __attribute__((__pure__));
extern char *strcpy_P(char *, const prog_char *);
extern int strcasecmp_P(const char *, const prog_char *) __attribute__((__pure__));
extern size_t strlcat_P (char *, const prog_char *, size_t );
extern size_t strlcpy_P (char *, const prog_char *, size_t );
extern size_t strlen_P(const prog_char *) __attribute__((__const__));
extern size_t strnlen_P(const prog_char *, size_t) __attribute__((__const__));
extern int strncmp_P(const char *, const prog_char *, size_t) __attribute__((__pure__));
extern int strncasecmp_P(const char *, const prog_char *, size_t) __attribute__((__pure__));
extern char *strncat_P(char *, const prog_char *, size_t);
extern char *strncpy_P(char *, const prog_char *, size_t);
# 14 "../../../processor/avr/include/hardware_proc.h" 2
# 1 "/usr/local/lib/gcc/avr/3.4.3/../../../../avr/include/avr/wdt.h" 1 3
# 15 "../../../processor/avr/include/hardware_proc.h" 2

# 1 "../../../kernel/include/sos_inttypes.h" 1
# 17 "../../../processor/avr/include/hardware_proc.h" 2
# 110 "../../../processor/avr/include/hardware_proc.h"
typedef uint16_t mod_header_ptr;

typedef uint16_t func_cb_ptr;
# 7 "../../../platform/mica2/include/hardware_types.h" 2
# 48 "../../../kernel/include/sos_types.h" 2

# 1 "../../../kernel/include/sos_endian.h" 1
# 50 "../../../kernel/include/sos_types.h" 2
# 60 "../../../kernel/include/sos_types.h"
enum
{
  FALSE = 0,
  TRUE = 1,
};



typedef enum { false=0, true=1, } bool;
# 83 "../../../kernel/include/sos_types.h"
enum
  {
 SOS_SPLIT = 1,
 SOS_OK = 0,
  };




enum
{
  SOS_BOOT_NORMAL = 0,
  SOS_BOOT_CRASHED = 1,
  SOS_BOOT_WDOGED = 3,
};
# 11 "../../../kernel/include/sos_info.h" 2


# 1 "../../../drivers/uart/include/uart.h" 1
# 14 "../../../kernel/include/sos_info.h" 2







enum {
 UNKNOWN = 0,
 MICA2 = 1,
 MICAZ = 2,
 XYZ = 3,
 CRICKET = 4,
 PROTOSB = 5,
 TMOTE = 6,
 CYCLOPS = 7,
 GW = 200,
 SIM = 201,
 PLATFORM_ANY = 255,
};


enum {
 MCU_UNKNOWN = 0,
 MCU_AVR = 1,
 MCU_ARM7 = 2,
 MCU_MSP430 = 3,
};
# 101 "../../../kernel/include/sos_info.h"
enum { UNIT_CENTIMETERS=0, UNIT_METERS=1, UNIT_KILOMETERS=2, UNIT_INCHES=3, UNIT_FEET=4, UNIT_MILES=5 };

enum { NORTH, SOUTH, WEST, EAST };

typedef struct gps_xy_type{
    int8_t dir;
    int8_t deg;
    int8_t min;
    int8_t sec;
} __attribute__ ((packed))
gps_xy_t;


typedef struct gps_type {
    gps_xy_t x;
    gps_xy_t y;
    int16_t unit;
    int16_t z;
} __attribute__ ((packed))
gps_t;


typedef struct node_loc_type {
 int16_t unit;
 int16_t x;
 int16_t y;
 int16_t z;
} __attribute__ ((packed))
node_loc_t;
# 9 "../../../kernel/include/sys_module.h" 2

# 1 "../../../kernel/include/sos_module_types.h" 1



# 1 "../../../kernel/include/fntable_types.h" 1
# 34 "../../../kernel/include/fntable_types.h"
typedef struct func_cb {
 void *ptr;
 uint8_t proto[4];
 uint8_t pid;
 uint8_t fid;
} func_cb_t;
# 60 "../../../kernel/include/fntable_types.h"
typedef void (*dummy_func)(void);
typedef int8_t (*fn_ptr_t)(void);

dummy_func ker_sys_enter_func( func_cb_ptr p );
void ker_sys_leave_func( void );
# 5 "../../../kernel/include/sos_module_types.h" 2
# 1 "../../../kernel/include/message_types.h" 1
# 45 "../../../kernel/include/message_types.h"
# 1 "../../../kernel/include/pid.h" 1
# 12 "../../../kernel/include/pid.h"
typedef uint8_t sos_pid_t;
# 22 "../../../kernel/include/pid.h"
enum {
          RSVD_0_PID=0,
          RSVD_1_PID,
          KER_SCHED_PID,
          KER_MEM_PID,
          TIMER_PID,
          ADC_PID,
          KER_SENSOR_PID,
          USER_PID,
          KER_LOG_PID,
          RADIO_PID,
          MONITOR_PID,
          MSG_QUEUE_PID,
          FNTABLE_PID,
          SOSBASE_PID,
          KER_TS_PID,
          KER_CODEMEM_PID,
          KER_FETCHER_PID,
          KER_DFT_LOADER_PID,
             KER_SPAWNER_PID,
             KER_CAM_PID,
           NULL_PID = 255,
};




enum {
 KER_MOD_MAX_PID = 63,
 DEV_MOD_MIN_PID = 64,
 APP_MOD_MIN_PID = 128,
 APP_MOD_MAX_PID = 223,
 SOS_MAX_PID = 254,
};






# 1 "../../../modules/include/mod_pid.h" 1
# 17 "../../../modules/include/mod_pid.h"
enum {

  DFLT_APP_ID0 = (APP_MOD_MIN_PID + 0),


  DFLT_APP_ID1 = (APP_MOD_MIN_PID + 1),


  DFLT_APP_ID2 = (APP_MOD_MIN_PID + 2),


  DFLT_APP_ID3 = (APP_MOD_MIN_PID + 3),


  MAG_SENSOR_PID = (APP_MOD_MIN_PID + 4),


  NBHOOD_PID = (APP_MOD_MIN_PID + 5),


  TD_PROTO_PID = (APP_MOD_MIN_PID + 6),


  TD_ENGINE_PID = (APP_MOD_MIN_PID + 7),


  MOD_D_PC_PID = (APP_MOD_MIN_PID + 8),


  MOD_FN_S_PID = (APP_MOD_MIN_PID + 9),


  MOD_FN_C_PID = (APP_MOD_MIN_PID + 10),


  MOD_AGG_TREE_PID = (APP_MOD_MIN_PID + 11),


  MOD_FLOODING_PID = (APP_MOD_MIN_PID + 12),


  TREE_ROUTING_PID = (APP_MOD_MIN_PID + 13),


  SURGE_MOD_PID = (APP_MOD_MIN_PID + 14),


  BEEF_MOD_PID = (APP_MOD_MIN_PID + 15),


  LITEPOT_PID = (APP_MOD_MIN_PID + 16),


  PHOTOTEMP_SENSOR_PID = (APP_MOD_MIN_PID + 17),


  SOUNDER_PID = (APP_MOD_MIN_PID + 18),



  ACK_MOD_PID = (APP_MOD_MIN_PID + 19),


  AODV_PID = (APP_MOD_MIN_PID + 20),


  AODV2_PID = (APP_MOD_MIN_PID + 21),


  GPSR_MOD_PID = (APP_MOD_MIN_PID + 22),


  CLIENT_MOD_PID = (APP_MOD_MIN_PID + 23),


  I2CPACKET_PID = (APP_MOD_MIN_PID + 24),


  VIZ_PID_0 = (APP_MOD_MIN_PID + 25),


  VIZ_PID_1 = (APP_MOD_MIN_PID + 26),


  ACCEL_SENSOR_PID = (APP_MOD_MIN_PID + 27),


  CAMERA_PID = (APP_MOD_MIN_PID + 28),


  BLINK_PID = (APP_MOD_MIN_PID + 29),


  SERIAL_SWITCH_PID = (APP_MOD_MIN_PID + 30),


  TPSN_TIMESYNC_PID = (APP_MOD_MIN_PID + 31),


  RATS_TIMESYNC_PID = (APP_MOD_MIN_PID + 32),


  CRYPTO_SYMMETRIC_PID = (APP_MOD_MIN_PID + 33),


  RFSN_PID = (APP_MOD_MIN_PID + 34),


  OUTLIER_PID = (APP_MOD_MIN_PID + 35),


  PHOTO_SENSOR_PID = (APP_MOD_MIN_PID + 36),

};
# 63 "../../../kernel/include/pid.h" 2



# 1 "../../../processor/avr/include/pid_proc.h" 1
# 19 "../../../processor/avr/include/pid_proc.h"
enum{
            I2C_PID = (DEV_MOD_MIN_PID + 1),
            UART_PID = (DEV_MOD_MIN_PID + 2),
            ADC_PROC_PID = (DEV_MOD_MIN_PID + 3),
};
# 67 "../../../kernel/include/pid.h" 2



# 1 "../../../platform/mica2/include/pid_plat.h" 1
# 55 "../../../platform/mica2/include/pid_plat.h"
enum
  {
 PWR_MGMT_PID = ((DEV_MOD_MIN_PID + 3) + 1),
 MICASB_PID = ((DEV_MOD_MIN_PID + 3) + 2),
 TIMER3_PID = ((DEV_MOD_MIN_PID + 3) + 3),
 EXFLASH_PID = ((DEV_MOD_MIN_PID + 3) + 4),
 KER_UART_PID = ((DEV_MOD_MIN_PID + 3) + 5),
 KER_I2C_PID = ((DEV_MOD_MIN_PID + 3) + 6),
 KER_I2C_MGR_PID = ((DEV_MOD_MIN_PID + 3) + 7),
};
# 71 "../../../kernel/include/pid.h" 2
# 46 "../../../kernel/include/message_types.h" 2
# 1 "/usr/local/lib/gcc/avr/3.4.3/include/stddef.h" 1 3 4
# 151 "/usr/local/lib/gcc/avr/3.4.3/include/stddef.h" 3 4
typedef int ptrdiff_t;
# 325 "/usr/local/lib/gcc/avr/3.4.3/include/stddef.h" 3 4
typedef int wchar_t;
# 47 "../../../kernel/include/message_types.h" 2
# 61 "../../../kernel/include/message_types.h"
typedef struct Message{
 sos_pid_t did;
 sos_pid_t sid;
 uint16_t daddr;
 uint16_t saddr;
 uint8_t type;
 uint8_t len;
 uint8_t *data;
 uint16_t flag;
 uint8_t payload[4];
 struct Message *next;
} __attribute__ ((packed))
Message;


typedef int8_t (*msg_handler_t)(void *state, Message *m);
# 110 "../../../kernel/include/message_types.h"
enum {
 SOS_MSG_NO_STATE,
 SOS_MSG_WAIT,

 SOS_MSG_TX_RAW,
 SOS_MSG_RX_RAW,

 SOS_MSG_TX_CRC_ONLY,
 SOS_MSG_RX_CRC_ONLY,

 SOS_MSG_TX_START,
 SOS_MSG_TX_HDR,
 SOS_MSG_TX_DATA,
 SOS_MSG_TX_CRC_LOW,
 SOS_MSG_TX_CRC_HIGH,
 SOS_MSG_TX_END,

 SOS_MSG_RX_START,
 SOS_MSG_RX_HDR,
 SOS_MSG_RX_DATA,
 SOS_MSG_RX_CRC_LOW,
 SOS_MSG_RX_CRC_HIGH,
 SOS_MSG_RX_END,
};





typedef struct {
 uint8_t byte;
 uint16_t word;
} __attribute__ ((packed))
MsgParam;







enum {



  SOS_MSG_FROM_NETWORK = 0x0100,
  SOS_MSG_RADIO_IO = 0x0200,
  SOS_MSG_I2C_IO = 0x0400,
  SOS_MSG_UART_IO = 0x0800,
  SOS_MSG_SPI_IO = 0x1000,
  SOS_MSG_ALL_LINK_IO = 0x1E00,
  SOS_MSG_LINK_AUTO = 0x2000,

  SOS_MSG_SYSTEM_PRIORITY = 0x0080,
  SOS_MSG_HIGH_PRIORITY = 0x0040,

  SOS_MSG_RELIABLE = 0x0008,
  SOS_MSG_RELEASE = 0x0004,
  SOS_MSG_SEND_FAIL = 0x0002,

  SOS_MSG_USE_UBMAC = 0x0020,
};







enum{
  SOS_RADIO_LINK_ID = 0,
  SOS_I2C_LINK_ID,
  SOS_UART_LINK_ID,
  SOS_SPI_LINK_ID,
};
# 213 "../../../kernel/include/message_types.h"
typedef uint8_t sos_ker_flag_t;
enum {

 SOS_MSG_RULES_PROMISCUOUS = 0x40,

 SOS_KER_STATIC_MODULE = 0x02,

 SOS_KER_MEM_FAILED = 0x01,
};







enum {
 KER_MSG_START = 0,
};







enum {
 MSG_INIT = (KER_MSG_START + 0),
 MSG_DEBUG = (KER_MSG_START + 1),
 MSG_TIMER_TIMEOUT = (KER_MSG_START + 2),
 MSG_PKT_SENDDONE = (KER_MSG_START + 3),
 MSG_DATA_READY = (KER_MSG_START + 4),
 MSG_TIMER3_TIMEOUT = (KER_MSG_START + 5),
 MSG_FINAL = (KER_MSG_START + 6),
 MSG_FROM_USER = (KER_MSG_START + 7),
 MSG_GET_DATA = (KER_MSG_START + 8),
 MSG_SEND_PACKET = (KER_MSG_START + 9),
 MSG_DFUNC_REMOVED = (KER_MSG_START + 10),
 MSG_FUNC_USER_REMOVED = (KER_MSG_START + 11),
 MSG_FETCHER_DONE = (KER_MSG_START + 12),
 MSG_MODULE_OP = (KER_MSG_START + 13),
 MSG_CAL_DATA_READY = (KER_MSG_START + 14),
 MSG_ERROR = (KER_MSG_START + 15),
 MSG_TIMESTAMP = (KER_MSG_START + 16),
 MSG_DISCOVERY = (KER_MSG_START + 17),
 MSG_COMM_TEST = (KER_MSG_START + 21),
 MSG_KER_UNKNOWN = (KER_MSG_START + 31),

 MOD_MSG_START = (KER_MSG_START + 32),
};





enum {
 PROC_MSG_START = 0x40,
 PLAT_MSG_START = 0x80,
 MOD_CMD_START = 0xc0,
};
# 6 "../../../kernel/include/sos_module_types.h" 2


typedef uint16_t sos_code_id_t;
# 23 "../../../kernel/include/sos_module_types.h"
typedef struct mod_header {
  sos_pid_t mod_id;
  uint8_t state_size;
  uint8_t num_timers;
  uint8_t num_sub_func;
  uint8_t num_prov_func;
  uint8_t version;
  uint8_t processor_type;
  uint8_t platform_type;
  sos_code_id_t code_id;
  uint8_t padding;
  uint8_t padding2;
  msg_handler_t module_handler;
  func_cb_t funct[];
} mod_header_t;




typedef struct Module {

  struct Module *next;

  mod_header_ptr header;

  sos_pid_t pid;

  sos_ker_flag_t flag;

  void *handler_state;
} sos_module_t;




enum {
 SOS_CREATE_THREAD = 1,
};







enum {
  MODULE_OP_INSMOD = 1,
  MODULE_OP_RMMOD = 2,
  MODULE_OP_LOAD = 3,
  MODULE_OP_ACTIVATE = 4,
  MODULE_OP_DEACTIVATE = 5,
};






typedef struct {
  sos_pid_t mod_id;
  uint8_t version;

  uint16_t size;
  uint8_t op;
} __attribute__ ((packed))
sos_module_op_t;
# 11 "../../../kernel/include/sys_module.h" 2
# 1 "../../../kernel/include/sos_timer.h" 1
# 21 "../../../kernel/include/sos_timer.h"
# 1 "../../../kernel/include/sos_list.h" 1
# 89 "../../../kernel/include/sos_list.h"
typedef struct list {
 struct list *l_next;
 struct list *l_prev;
} list_t, list_link_t;
# 22 "../../../kernel/include/sos_timer.h" 2
# 1 "../../../processor/avr/include/timer_conf.h" 1
# 23 "../../../kernel/include/sos_timer.h" 2



enum
  {
    TIMER_REPEAT = 0,
    TIMER_ONE_SHOT = 1,
    SLOW_TIMER_REPEAT = 2,
    SLOW_TIMER_ONE_SHOT = 3,
  };
# 41 "../../../kernel/include/sos_timer.h"
enum
  {
    TIMER_PRE_ALLOCATED = 0x02,
  };
# 56 "../../../kernel/include/sos_timer.h"
typedef struct {
  uint8_t tid;
  uint16_t pad;
} __attribute__ ((packed))
sos_timeout_t;





typedef struct {
  list_t list;
  uint8_t type;
  sos_pid_t pid;
  uint8_t tid;
  int32_t ticks;
  int32_t delta;
  uint8_t flag;
} sos_timer_t;





static inline uint8_t timer_get_tid( Message *msg )
{
 MsgParam* params = (MsgParam*)(msg->data);

 return params->byte;
}
# 12 "../../../kernel/include/sys_module.h" 2

# 1 "/usr/local/lib/gcc/avr/3.4.3/include/stddef.h" 1 3 4
# 14 "../../../kernel/include/sys_module.h" 2
# 1 "../../../processor/avr/include/kertable_conf.h" 1
# 15 "../../../kernel/include/sys_module.h" 2
# 1 "../../../kernel/include/sos_error_types.h" 1
# 12 "../../../kernel/include/sos_error_types.h"
enum {
    READ_ERROR = 0,
 SEND_ERROR,
    SENSOR_ERROR,
    MALLOC_ERROR,
  };
# 16 "../../../kernel/include/sys_module.h" 2
# 52 "../../../kernel/include/sys_module.h"
typedef void * (* sys_malloc_ker_func_t)( uint16_t size );
# 72 "../../../kernel/include/sys_module.h"
static inline void * sys_malloc( uint16_t size )
{

 return ((sys_malloc_ker_func_t)(0x8c +4*1))(size);



}


typedef void * (* sys_realloc_ker_func_t)( void * ptr, uint16_t newSize );
# 105 "../../../kernel/include/sys_module.h"
static inline void * sys_realloc( void * ptr, uint16_t newSize )
{

 return ((sys_realloc_ker_func_t)(0x8c +4*2))( ptr, newSize );



}



typedef void (* sys_free_ker_func_t)( void * ptr );
# 125 "../../../kernel/include/sys_module.h"
static inline void sys_free( void * ptr )
{

 ((sys_free_ker_func_t)(0x8c +4*3))( ptr );



}


typedef void * (* sys_msg_take_data_ker_func_t)( Message * msg );
# 171 "../../../kernel/include/sys_module.h"
static inline void * sys_msg_take_data( Message * msg )
{

 return ((sys_msg_take_data_ker_func_t)(0x8c +4*4))( msg );



}
# 192 "../../../kernel/include/sys_module.h"
typedef int8_t (* sys_timer_start_ker_func_t)( uint8_t tid, int32_t interval, uint8_t type );
# 209 "../../../kernel/include/sys_module.h"
static inline int8_t sys_timer_start( uint8_t tid, int32_t interval, uint8_t type )
{

 return ((sys_timer_start_ker_func_t)(0x8c +4*5))( tid, interval, type );



}



typedef int8_t (* sys_timer_restart_ker_func_t)( uint8_t tid, int32_t interval );
# 243 "../../../kernel/include/sys_module.h"
static inline int8_t sys_timer_restart( uint8_t tid, int32_t interval )
{

 return ((sys_timer_restart_ker_func_t)(0x8c +4*6))( tid, interval );



}



typedef int8_t (* sys_timer_stop_ker_func_t)( uint8_t tid );
# 267 "../../../kernel/include/sys_module.h"
static inline int8_t sys_timer_stop( uint8_t tid )
{

 return ((sys_timer_stop_ker_func_t)(0x8c +4*7))( tid );



}
# 284 "../../../kernel/include/sys_module.h"
typedef int8_t (* sys_post_ker_func_t)( sos_pid_t dst_mod_id, uint8_t type, uint8_t size, void * data, uint16_t flag );
# 325 "../../../kernel/include/sys_module.h"
static inline int8_t sys_post( sos_pid_t dst_mod_id, uint8_t type, uint8_t size, void * data, uint16_t flag )
{

 return ((sys_post_ker_func_t)(0x8c +4*8))( dst_mod_id, type, size, data, flag );



}


typedef int8_t (* sys_post_link_ker_func_t)( sos_pid_t dst_mod_id, uint8_t type, uint8_t size, void * data, uint16_t flag, uint16_t dst_node_addr );
# 345 "../../../kernel/include/sys_module.h"
static inline int8_t sys_post_link( sos_pid_t dst_mod_id, uint8_t type, uint8_t size, void * data, uint16_t flag, uint16_t dst_node_addr )
{

 return ((sys_post_link_ker_func_t)(0x8c +4*9))( dst_mod_id, type, size, data, flag, dst_node_addr );



}
# 438 "../../../kernel/include/sys_module.h"
typedef int8_t (* sys_post_value_ker_func_t)( sos_pid_t dst_mod_id, uint8_t type, uint32_t data, uint16_t flag );
# 461 "../../../kernel/include/sys_module.h"
static inline int8_t sys_post_value( sos_pid_t dst_mod_id, uint8_t type, uint32_t data, uint16_t flag )
{

 return ((sys_post_value_ker_func_t)(0x8c +4*10))( dst_mod_id, type, data, flag );



}
# 478 "../../../kernel/include/sys_module.h"
typedef uint16_t (* sys_hw_type_ker_func_t)( void );
# 499 "../../../kernel/include/sys_module.h"
static inline uint16_t sys_hw_type( void )
{

 return ((sys_hw_type_ker_func_t)(0x8c +4*11))( );



}


typedef uint16_t (* sys_id_ker_func_t)( void );
# 528 "../../../kernel/include/sys_module.h"
static inline uint16_t sys_id( void )
{

 return ((sys_id_ker_func_t)(0x8c +4*12))( );



}
# 546 "../../../kernel/include/sys_module.h"
typedef uint16_t (* sys_rand_ker_func_t)( void );
# 558 "../../../kernel/include/sys_module.h"
static inline uint16_t sys_rand( void )
{

 return ((sys_rand_ker_func_t)(0x8c +4*13))();



}
# 575 "../../../kernel/include/sys_module.h"
typedef uint32_t (* sys_time32_ker_func_t)( void );
# 584 "../../../kernel/include/sys_module.h"
static inline uint32_t sys_time32( void )
{

 return ((sys_time32_ker_func_t)(0x8c +4*14))( );



}
# 602 "../../../kernel/include/sys_module.h"
typedef int8_t (* sys_sensor_get_data_ker_func_t)( uint8_t sensor_id );





static inline int8_t sys_sensor_get_data( uint8_t sensor_id )
{

 return ((sys_sensor_get_data_ker_func_t)(0x8c +4*15))( sensor_id );



}
# 628 "../../../kernel/include/sys_module.h"
typedef void (* sys_led_ker_func_t)( uint8_t op );

static inline void sys_led( uint8_t op )
{

 ((sys_led_ker_func_t)(0x8c +4*16))( op );



}
# 647 "../../../kernel/include/sys_module.h"
typedef void* (* sys_get_module_state_func_t)( void );





static inline void* sys_get_state( void )
{

 return ((sys_get_module_state_func_t)(0x8c +4*17))( );



}
# 669 "../../../kernel/include/sys_module.h"
typedef int8_t (* sys_fntable_subscribe_func_t)( sos_pid_t pub_pid, uint8_t fid, uint8_t table_index );


static inline int8_t sys_fntable_subscribe( sos_pid_t pub_pid, uint8_t fid, uint8_t table_index )
{

 return ((sys_fntable_subscribe_func_t)(0x8c +4*18))(pub_pid, fid, table_index);



}


typedef int8_t (* sys_change_own_func_t)( void* ptr );

static inline int8_t sys_change_own( void* ptr )
{

 return ((sys_change_own_func_t)(0x8c +4*19))(ptr);



}
# 14 "blink.c" 2


# 1 "../../../kernel/include/led_dbg.h" 1
# 52 "../../../kernel/include/led_dbg.h"
# 1 "../../../platform/mica2/include/led.h" 1
# 53 "../../../kernel/include/led_dbg.h" 2
# 17 "blink.c" 2

# 1 "blink.h" 1
# 19 "blink.c" 2






typedef struct {
  uint8_t pid;
  uint8_t state;
} app_state_t;
# 44 "blink.c"
static int8_t blink_msg_handler(void *start, Message *e);




static mod_header_t mod_header __attribute__ ((__progmem__)) = {
 .mod_id = DFLT_APP_ID0,
 .state_size = sizeof(app_state_t),
 .num_sub_func = 0,
 .num_prov_func = 0,
 .platform_type = MICA2 ,
 .processor_type = MCU_AVR,
 .code_id = (DFLT_APP_ID0),
 .module_handler = blink_msg_handler,
};


static int8_t blink_msg_handler(void *state, Message *msg)
{







  app_state_t *s = (app_state_t*)state;




  switch (msg->type){





  case MSG_INIT:
  {
   s->pid = msg->did;
   s->state = 0;
   sys_led(7);







   ;
   sys_timer_start(0, 1024L, TIMER_REPEAT);
   break;
 }







  case MSG_FINAL:
 {



   sys_timer_stop(0);
   ;
   break;
 }
# 121 "blink.c"
  case MSG_TIMER_TIMEOUT:
 {
   sys_led(8);
   break;
 }





 default:
 return -22;
  }




  return SOS_OK;
}
