/** -*-C-*- **/
/**
 * @file memmap.c
 * @author Ram Kumar {ram@ee.ucla.edu}
 * @brief Memory Map Implementation for SOS Kernel (Currently POSIX and AVR targets only)
 */

#include <memmap.h>

//----------------------------------------------------------
// GLOBAL VARIABLE
//----------------------------------------------------------
uint8_t memmap[MEMMAP_TABLE_SIZE] SOS_MEMMAP_SECTION;

//----------------------------------------------------------
// INITIALIZE MEMORY MAP
//----------------------------------------------------------
void memmap_init()
{
  uint16_t i;
  // Initialize all memory to be owned by the kernel
  for (i = 0; i < MEMMAP_TABLE_SIZE; i++){
    memmap[i] = BLOCK_FREE_VEC;
  }
}

//----------------------------------------------------------
// SET PERMISSIONS FOR A SET OF BLOCKS
//----------------------------------------------------------
void memmap_set_perms(void* baseaddr, uint16_t length, uint8_t seg_perms)
{
  blk_num_t blknum, blocksleft;
  uint16_t memmap_table_index;
  uint8_t memmap_byte_offset;
  uint8_t lperms_bm, lperms_set_val;
  uint8_t perms;

  if (0 == length) {
    return;
  }              

  if ((length & MEMMAP_BLK_OFFSET) != 0){
    return; // Length should be a multiple of block size
  }

  blocksleft = length >> MEMMAP_BLK_NUM_LSB;
  blknum = MEMMAP_GET_BLK_NUM(baseaddr);
  memmap_table_index = MEMMAP_GET_TABLE_NDX(blknum);
  memmap_byte_offset = MEMMAP_GET_BYTE_OFFSET(blknum);

  
  perms = memmap[memmap_table_index];

  lperms_bm = (MEMMAP_REC_MASK << memmap_byte_offset);
  lperms_set_val = (seg_perms << memmap_byte_offset);

  while (blocksleft > 0){
    perms &= ~(lperms_bm);
    perms |= lperms_set_val;
    blocksleft--;
    lperms_bm <<= MEMMAP_REC_BITS;
    lperms_set_val <<= MEMMAP_REC_BITS;
    if (0 == lperms_bm){
      memmap[memmap_table_index] = perms;
      memmap_table_index++;
      perms = memmap[memmap_table_index];
      lperms_bm = MEMMAP_REC_MASK;
      lperms_set_val = seg_perms;
    }
  }
  memmap[memmap_table_index] = perms;
}

//----------------------------------------------------------
// CHANGE PERMISSIONS FOR CURRENT SEGMENT
//----------------------------------------------------------
uint16_t memmap_change_perms(void* baseaddr, uint8_t perm_mask, uint8_t perm_check_val, uint8_t perm_set_val)
{
  blk_num_t blknum, nblocks;
  uint16_t memmap_table_index;
  uint8_t memmap_byte_offset;
  uint8_t lperm_mask, lperm_check_val, lperm_set_val, perm_bm;
  uint8_t perms;

  nblocks = 0;
  blknum = MEMMAP_GET_BLK_NUM(baseaddr);
  memmap_table_index = MEMMAP_GET_TABLE_NDX(blknum);
  memmap_byte_offset = MEMMAP_GET_BYTE_OFFSET(blknum);

  perms = memmap[memmap_table_index];

  lperm_mask = (perm_mask << memmap_byte_offset);
  lperm_check_val = (perm_check_val << memmap_byte_offset);
  lperm_set_val = (perm_set_val << memmap_byte_offset);
  perm_bm = (MEMMAP_REC_MASK << memmap_byte_offset);

  while ((perms & lperm_mask) == lperm_check_val){
    perms &= ~perm_bm;
    perms |= lperm_set_val;
    nblocks++;

    lperm_mask <<= MEMMAP_REC_BITS;
    lperm_check_val <<= MEMMAP_REC_BITS;
    lperm_set_val <<= MEMMAP_REC_BITS;
    perm_bm <<= MEMMAP_REC_BITS;

    if (0 == perm_bm){
      memmap[memmap_table_index] = perms;
      memmap_table_index++;
      perms = memmap[memmap_table_index];
      lperm_mask = perm_mask;
      lperm_check_val = perm_check_val;
      lperm_set_val = perm_set_val;
      perm_bm = MEMMAP_REC_MASK;
    }
  }
  memmap[memmap_table_index] = perms;
  return nblocks;
}

