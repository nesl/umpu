/**
 * @file memmap.h
 * @author Ram Kumar {ram@ee.ucla.edu}
 * @brief Memory Map Implementation for SOS Kernel (Currently AVR targets only)
 */

#include <sos_inttypes.h>
#ifndef _MEMMAP_H_
#define _MEMMAP_H_

#include <malloc_conf.h>
#include <memmap_conf.h>

extern uint8_t* mem_prot_bottom;

// Macro to generate log2 of a number that is 2^n
#define LOG2BASE(x) ((((x & 0xF0)!=0)<<2) + (((x & 0xCC)!=0)<<1) + ((x & 0xAA)!=0))

//-----------------------------------------------------------------------
// FUNCTION PROTOTYPES
//-----------------------------------------------------------------------

/**
 * \addtogroup memorymap
 * Memory Map Manager tracks ownership and layout of memory blocks in the system.<BR>
 * Information in memory map is used to validate write accesses made by modules.
 * @{
 */


/**
 * Initialize the memory map
 */
void memmap_init();

/**
 * Set the permissions for a memory segment
 * \param baseaddr Starting address of a segment
 * \param length Length of the segment in number of bytes
 * \param seg_perms Permissions to be set for this segment
 */
void memmap_set_perms(void* baseaddr, uint16_t length, uint8_t seg_perms);

/**
 * Modify the permissions for a memory segment
 * \param baseaddr Starting address of a segment
 * \param perm_mask Bit-mask for the changing permission
 * \param perm_check_val Original permissions for the segment
 * \param perm_set_val New permissions for the segment
 */
uint16_t memmap_change_perms(void* baseaddr, uint8_t perm_mask, uint8_t perm_check_val, uint8_t perm_set_val);


//-----------------------------------------------------------------------
// MEMORY MAP RECORD CONSTANTS
//-----------------------------------------------------------------------
#ifdef SFI_DOMS_8
#define NUM_DOMAINS 8
#else
#define NUM_DOMAINS 2
#endif



/**
 * Memory Map Record Layout
 */
enum mmap_rec_t
  {
    // Record Layout Definitions
    LOG_NUM_DOMS            = (uint8_t)LOG2BASE(NUM_DOMAINS),                //!< Number of bits required to represent domain ID
    MEMMAP_DOM_MASK         = (uint8_t)(~(0xFF << LOG_NUM_DOMS)),            //!< Mask for domain ID
    MEMMAP_SEG_MASK         = (uint8_t)(1 << LOG_NUM_DOMS),                  //!< Mask for segment bit
    MEMMAP_REC_BITS         = (uint8_t)(LOG_NUM_DOMS + 1),                   //!< Number of bits required for memory map record
    MEMMAP_REC_PER_BYTE     = (uint8_t)(8/MEMMAP_REC_BITS),                  //!< Number of records per byte
    LOG_MEMMAP_REC_PER_BYTE = (uint8_t)LOG2BASE(MEMMAP_REC_PER_BYTE),        //!< Number of bits required to index a record in a byte
    MEMMAP_BYTE_OFFSET_MASK = (uint8_t)(~(0xFF << LOG_MEMMAP_REC_PER_BYTE)), //!< Use this mask with block number
    MEMMAP_REC_MASK         = (uint8_t)(~(0xFF << MEMMAP_REC_BITS)),         //!< Use this mask on memory map byte retreived

    // Memory Map Table Size
    MEMMAP_TABLE_SIZE = ((MEMMAP_REGION_SIZE/MEMMAP_BLOCK_SIZE)/MEMMAP_REC_PER_BYTE), //!< Memory Map Table Size
    
    // Block Number
    MEMMAP_BLK_NUM_LSB = LOG2BASE(MEMMAP_BLOCK_SIZE),
    MEMMAP_BLK_OFFSET  = ~(0xFF << MEMMAP_BLK_NUM_LSB),

    // Start of segment indicator
    MEMMAP_SEG_START = MEMMAP_SEG_MASK,            //!< Seg bit is set for first segment
    MEMMAP_SEG_LATER = ~(MEMMAP_SEG_MASK),         //!< Seg bit is cleared for later segment

    // Kernel domain id
    KER_DOM_ID     = MEMMAP_DOM_MASK,            //!< Kernel is largest domain ID
#ifdef SFI_DOMS_2
    MOD_DOM_ID     = 0,
#endif

    // Block Definitions
    BLOCK_FREE     = (MEMMAP_SEG_START)|(KER_DOM_ID),      //!< Free Block (Mark all free blocks as kernel)
    BLOCK_KER_SEG_START = (MEMMAP_SEG_START)|(KER_DOM_ID), //!< First Block of Kernel Segment
    BLOCK_KER_SEG_LATER = (MEMMAP_SEG_LATER)&(KER_DOM_ID), //!< Later Block of Kernel Segment
    BLOCK_FREE_VEC = 0xFF,
  };

//-----------------------------------------------------------------------
// GLOBAL VARIABLE
//-----------------------------------------------------------------------

/**
 * Memory map to store the access permissions
 */
extern uint8_t memmap[MEMMAP_TABLE_SIZE];


//-----------------------------------------------------------------------
// MEMMAP ACCESS MACROS
//-----------------------------------------------------------------------

/**
 * Start of segment memmap record
 */
#define DOM_SEG_START(domid) (MEMMAP_SEG_START|(domid & MEMMAP_DOM_MASK))

/**
 * Later part of segment memmap record
 */
#define DOM_SEG_LATER(domid) (MEMMAP_SEG_LATER & (domid & MEMMAP_DOM_MASK))

/**
 * Get block number for a given address
 */
#define MEMMAP_GET_BLK_NUM(addr)  (blk_num_t)((data_addr_t)((uint8_t*)addr - mem_prot_bottom) >> MEMMAP_BLK_NUM_LSB)	

/**
 * Get memory map table index
 */
#define MEMMAP_GET_TABLE_NDX(blk_num) (blk_num >> LOG_MEMMAP_REC_PER_BYTE)
  
/**
 * Get memory map byte offset
 */
#define MEMMAP_GET_BYTE_OFFSET(blk_num) ((blk_num & MEMMAP_BYTE_OFFSET_MASK) * MEMMAP_REC_BITS)

/**
 * Retreive permissions for the given block number
 */
#define MEMMAP_GET_PERMS(blk_num, perms)				\
  {									\
    uint16_t __memmap_table_index;					\
    uint8_t __memmap_byte_offset;					\
    __memmap_table_index = MEMMAP_GET_TABLE_NDX(blk_num);		\
    __memmap_byte_offset = MEMMAP_GET_BYTE_OFFSET(blk_num);		\
    perms = memmap[__memmap_table_index];				\
    perms >>= __memmap_byte_offset;					\
    perms &= MEMMAP_REC_MASK;						\
  }

/**
 * Set the permissions for the given block number
 */
#define MEMMAP_SET_PERMS(blk_num, perms)				\
  {									\
    uint16_t __memmap_table_index;					\
    uint8_t __memmap_byte_offset;					\
    uint8_t __curr_perms;						\
    __memmap_table_index = MEMMAP_GET_TABLE_NDX(blk_num);		\
    __memmap_byte_offset = MEMMAP_GET_BYTE_OFFSET(blk_num);		\
    __curr_perms = memmap[__memmap_table_index];			\
    __curr_perms &= ~(MEMMAP_REC_MASK << __memmap_byte_offset);		\
    __curr_perms |= (perms << __memmap_byte_offset);			\
    PORTA = 0xCC; \
    PORTA = __curr_perms; \
    PORTA = (uint8_t)__memmap_table_index; \
    PORTA = (uint8_t)(__memmap_table_index >> 8); \
    memmap[__memmap_table_index] = __curr_perms;			\
  }

/* @} */

#endif//_MEMMAP_H_
