/**
 * @file memmap.h
 * @author Ram Kumar {ram@ee.ucla.edu}
 * @brief Memory Map Implementation for SOS Kernel (Currently AVR targets only)
 */

#include <avr/io.h>
#include <avr/signal.h>
#include <avr/sleep.h>
#include <avr/interrupt.h>
#include <inttypes.h>

#ifndef _MEMMAP_H_
#define _MEMMAP_H_

//--------------------------------------------------
// MACROS and DEFINES
//--------------------------------------------------
// Macro to generate log2 of a number that is 2^n
#define LOG2BASE(x) ((((x & 0xF0)!=0)<<2) + (((x & 0xCC)!=0)<<1) + ((x & 0xAA)!=0))
#define MEMMAP_TABLE_SIZE 256
#define MEMMAP_TABLE_SECTION __attribute__((section(".mmptbl")))
// Need to put this somewhere else
#define MEMMAP_REGION_SIZE 2048
#define MEMMAP_BLOCK_SIZE  8
//--------------------------------------------------
// MEMORY MAP REGISTERS
//--------------------------------------------------
#define MMBL _SFR_IO8(0x08)
#define MMBH _SFR_IO8(0x07)
#define MMTL _SFR_IO8(0x06)
#define MMTH _SFR_IO8(0x05)
#define MMPL _SFR_IO8(0x1D)
#define MMPH _SFR_IO8(0x1E)
#define MSR _SFR_IO8(0x04)
#define JTL _SFR_IO8(0x1C)
#define JTH _SFR_IO8(0x1F)
#define SSPL _SFR_IO8(0x03)
#define SSPH _SFR_IO8(0x02)
#define DBCTL _SFR_IO8(0x15)
#define DBDATA _SFR_IO8(0x12)

//---------------------------------------------------
// MEMORY MAP STATUS REGISTER
//---------------------------------------------------
// Block Size Setup
#define SET_MSR_BLK_SIZE(size) {MSR &= 0x1F; MSR |= ((0x7 & LOG2BASE(size)) << 5);}
// Set Number of Domains
#define SET_MSR_DOMS_2() {MSR |= 0x02;}
#define SET_MSR_DOMS_8() {MSR &= ~0x02;}
// Enable MSR
#define MSR_ENABLE() {MSR |= 0x01;}
#define MSR_DISABLE() {MSR &= ~0x01;}
// Get Current Domain ID
#define GET_MSR_DOM_ID() ((MSR & 0x1E) >> 2)

//---------------------------------------------------
// DOMAIN BOUND SETUP IN PROM
// |UNUSED|DOMAIN ID (2:0)|UPPER OR LOWER BOUND|HIGH OR LOW BYTE BIT|UPDATE BIT|
//---------------------------------------------------
#define SET_DOM_UPBND(dom_id, addr) { \
    DBDATA = (uint8_t)addr; \
    DBCTL = ((dom_id & 0x7) << 3) | (1 << 2) | 1; \
    DBDATA = (uint8_t)(addr >> 8); \
    DBCTL = ((dom_id & 0x7) << 3) | (1 << 2) | (1 << 1) | 1; \
}
#define SET_DOM_LWBND(dom_id, addr) { \
    DBDATA = (uint8_t)addr; \
    DBCTL = ((dom_id & 0x7) << 3) | 1; \
    DBDATA = (uint8_t)(addr >> 8); \
    DBCTL = ((dom_id & 0x7) << 3) | (1 << 1) | 1; \
}

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
#define SFI_DOMS_8
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
    //    MEMMAP_TABLE_SIZE = ((MEMMAP_REGION_SIZE/MEMMAP_BLOCK_SIZE)/MEMMAP_REC_PER_BYTE), //!< Memory Map Table Size
    
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
extern uint8_t memmap[MEMMAP_TABLE_SIZE] MEMMAP_TABLE_SECTION;


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
 * Get the the lower bound of protected address space
 */
#define MEM_PROT_LOW (uint16_t)(((uint16_t)MMBH << 8)|((uint16_t)MMBL))

/**
 * Get block number for a given address
 */
#define MEMMAP_GET_BLK_NUM(addr)  (uint16_t)(((uint16_t)addr - MEM_PROT_LOW)  >> MEMMAP_BLK_NUM_LSB)

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
    memmap[__memmap_table_index] = __curr_perms;			\
  }

/* @} */


#endif//_MEMMAP_H_
