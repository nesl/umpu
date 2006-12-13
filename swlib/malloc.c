/******************************************************************************

  NAME:         DoubleLinkPool
  
  DESCRIPTION:  An implementation in C of a heap memory controller using a
                doubly-linked list to manage the free list. The basis for the 
                design is the DoublyLinkedPool C++ class of Bruno Preiss
                (http://www.bpreiss.com). This version provides for acquiring 
                an area in O(n) time, and releasing an area in O(1) time.
                
  LICENSE:      This program is free software. you can redistribute it and/or
                modify it under the terms of the GNU General Public License
                as published by the Free Software Foundation; either version 2
                of the License, or any later version. This program is 
                distributed in the hope that it will be useful, but WITHOUT 
                ANY WARRANTY; without even the implied warranty of 
                MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
                GNU General Public License for more details.

  REVISION:     12-6-2005 - version for AVR
                  
  AUTHOR:       Ron Kreymborg
                Jennaron Research                
                
******************************************************************************/
//-----------------------------------------------------------------------------
// INCLUDE
//-----------------------------------------------------------------------------
#include <string.h>
#include <stdlib.h>
#include <avrdefs.h>
#include <malloc.h>
#include <memmap.h>          // Memmory Map API

//-----------------------------------------------------------------------------
// CONSTANTS
//-----------------------------------------------------------------------------
#define RESERVED            0x8000                // Must set the msb of BlockSizeType
#define BLOCKOVERHEAD (sizeof(BlockHeaderType)) 



//-----------------------------------------------------------------------------
// MACROS
//-----------------------------------------------------------------------------
#define TO_BLOCK_PTR(p)     (Block*)((BlockHeaderType*)p - 1)
#define BLOCKS_TO_BYTES(n)  (((n & ~RESERVED) << SHIFT_VALUE) - sizeof(BlockHeaderType))

//-----------------------------------------------------------------------------
// DATA STRUCTURES
//-----------------------------------------------------------------------------
// A memory block is made up of a header and either a user data part or a pair
// of pointers to the previous and next free area. A memory area is made up
// of one or more of these blocks. Only the first block will have the header.
// The header contains the number of blocks contained within the area.
//
typedef struct _BlockHeaderType
{
  uint16_t blocks;
} BlockHeaderType;


typedef struct _Block
{
  BlockHeaderType blockhdr;
  union
  {
    uint8_t userPart[BLOCK_SIZE - sizeof(BlockHeaderType)];
    struct 
    {
      struct _Block *prev;
      struct _Block *next;
    };
  };
} Block;

//-----------------------------------------------------------------------------
// LOCAL FUNCTIONS
//-----------------------------------------------------------------------------
static void InsertAfter(Block*);
static void Unlink(Block*);
static Block* MergeBlocks(Block* block);
static void SplitBlock(Block* block, uint16_t reqBlocks);
static int8_t mmc_panic();
//-----------------------------------------------------------------------------
// LOCAL GLOBAL VARIABLES
//-----------------------------------------------------------------------------
static Block*           mPool;
static Block*           mSentinel;
static uint16_t         mNumberOfBlocks;
static Block            malloc_heap[(MALLOC_HEAP_SIZE + (BLOCK_SIZE - 1))/BLOCK_SIZE] __attribute__((section(".mmcheap")));


//-----------------------------------------------------------------------------
// Malloc Function
// SFI Mode: Allocate domain ID based upon requestor pid
//-----------------------------------------------------------------------------
void* mmc_int_malloc(uint16_t size, uint8_t calleedomid)
{
  HAS_CRITICAL_SECTION;
  uint16_t reqBlocks;
  Block* block;

  
  // Check for errors.
  if (size == 0) return NULL;

  // Compute the number of blocks to satisfy the request.
  reqBlocks = (size + BLOCKOVERHEAD + sizeof(Block) - 1) >> SHIFT_VALUE;

  ENTER_CRITICAL_SECTION();
  for (block = mSentinel->next; block != mSentinel; block = block->next)
    {
      block = MergeBlocks(block);
      if (block->blockhdr.blocks >= reqBlocks)
        {
	  break;
        }
    }

  // If we are pointing at the sentinel then all blocks are allocated.
  //
  if (block == mSentinel)
    {
      LEAVE_CRITICAL_SECTION();
      return NULL;
    }

  // If this free area is larger than required, it is split in two. The
  // size of the first area is set to that required and the second area
  // to the blocks remaining. The second area is then inserted into 
  // the free list.
  //
  if (block->blockhdr.blocks > reqBlocks)
    {
      SplitBlock(block, reqBlocks);
    }

  // Unlink the now correctly sized area from the free list and mark it 
  // as reserved.
  //
  Unlink(block);
  block->blockhdr.blocks |= RESERVED;


  memmap_set_perms((void*) block, sizeof(Block), DOM_SEG_START(calleedomid));
  memmap_set_perms((void*) ((Block*)(block + 1)), sizeof(Block) * (reqBlocks - 1), DOM_SEG_LATER(calleedomid));
  LEAVE_CRITICAL_SECTION();

  return block->userPart;
}

//-----------------------------------------------------------------------------
// Return this memory block to the free list.
// SFI Mode: 1. If call comes from un-trusted domain, then free only if current domain is owner
//           2. Block being freed should be start of segment
//-----------------------------------------------------------------------------
void mmc_int_free(void* pntr, uint8_t calleedomid)
{
  uint16_t block_num;
  uint8_t perms;
  HAS_CRITICAL_SECTION;
  // Check for errors.
  //
  Block* top;
  Block* baseArea;   // convert to a block address

  if( pntr == NULL ) {
    return;
  }
  top = mPool + mNumberOfBlocks;
  baseArea = TO_BLOCK_PTR(pntr);   // convert to a block address

  if ( (baseArea < malloc_heap) || (baseArea >= (malloc_heap + mNumberOfBlocks)) ) {
    return;
  }
  
  ENTER_CRITICAL_SECTION();
  // Get the permission of the first block
  block_num = MEMMAP_GET_BLK_NUM(baseArea);
  MEMMAP_GET_PERMS(block_num, perms);
  // Check - Not a start of segment
  if ((perms & MEMMAP_SEG_MASK) == MEMMAP_SEG_LATER) {
    LEAVE_CRITICAL_SECTION();
    mmc_panic();
    return; 
  }
  // Check - Untrusted domain trying to free memory that it does not own or that is free.
#ifdef SFI_DOMS_8
  if ((perms & MEMMAP_DOM_MASK) != calleedomid)
#endif
#ifdef SFI_DOMS_2
  if ((perms & MEMMAP_DOM_MASK) == KER_DOM_ID))
#endif
    {
      LEAVE_CRITICAL_SECTION();
      mmc_panic();
      return; 
    }

  
  // Very simple - we insert the area to be freed at the start
  // of the free list. This runs in constant time. Since the free
  // list is not kept sorted, there is less of a tendency for small
  // areas to accumulate at the head of the free list.
  //
  ENTER_CRITICAL_SECTION();
  baseArea->blockhdr.blocks &= ~RESERVED;
  MEMMAP_SET_PERMS(block_num, BLOCK_FREE);
  memmap_change_perms((void*)((Block*)(baseArea + 1)), 
		      MEMMAP_SEG_MASK|MEMMAP_DOM_MASK, 
		      DOM_SEG_LATER(perms), 
		      BLOCK_FREE);
  InsertAfter(baseArea);
  LEAVE_CRITICAL_SECTION();
  return;
}

//-----------------------------------------------------------------------------
// Change ownership of memory
// SFI Mode: 1. If call from un-trusted domain. change permissions only if current domain is block owner
//           2. If call from trusted domain, everything is fair !!
//-----------------------------------------------------------------------------
int8_t mmc_int_change_own(void* ptr, uint8_t calleedomid, uint8_t newdomid) 
{
  HAS_CRITICAL_SECTION;
  uint8_t perms;
  uint16_t block_num;


  Block* blockptr = TO_BLOCK_PTR(ptr); // Convert to a block address         
  // Check for errors                                          
  if (NULL == ptr) return -1;           


  ENTER_CRITICAL_SECTION();
  //Get the permission for the first block
  block_num = MEMMAP_GET_BLK_NUM(blockptr);
  MEMMAP_GET_PERMS(block_num, perms);

  // Check - Not a start of segment
  if ((perms & MEMMAP_SEG_MASK) == MEMMAP_SEG_LATER) {
    LEAVE_CRITICAL_SECTION();
    mmc_panic();
  }

#ifdef SFI_DOMS_8 
  if ((perms & MEMMAP_DOM_MASK) == calleedomid)
#endif
#ifdef SFI_DOMS_2
  if ((perms & MEMMAP_DOM_MASK) != KER_DOM_ID)
#endif
    {
      // Call has come from block owner
      
      
      // Change Permissions Only if it is required
      if (newdomid != (perms & MEMMAP_DOM_MASK)){
	MEMMAP_SET_PERMS(block_num, DOM_SEG_START(newdomid));
	memmap_change_perms((void*)((Block*)(blockptr + 1)),
			    MEMMAP_SEG_MASK | MEMMAP_DOM_MASK,
			    DOM_SEG_LATER(perms),
			    DOM_SEG_LATER(newdomid));
      }
      LEAVE_CRITICAL_SECTION();
    }
  else{
    // Non-owner trying to change ownership of the block
    LEAVE_CRITICAL_SECTION();
    mmc_panic();
    return -1;
  }

  // Set the new block ID                                      
  return 0;
}

//-----------------------------------------------------------------------------
// Compute the number of blocks that will fit in the memory area defined.
// Allocate the pool of blocks. Note this includes the sentinel area that is 
// attached to the end and is always only one block. The first entry in the 
// free list pool is set to include all available blocks. The sentinel is 
// initialised to point back to the start of the pool.
//
void mem_init(void)
{
  Block* head;
  char* heapStart = (char*)malloc_heap; //&__heap_start;
  char* heapEnd = (char*)(((char*)malloc_heap) + MALLOC_HEAP_SIZE);//&__heap_end;

  mPool = (Block*)heapStart;
  mNumberOfBlocks = (uint16_t)(((heapEnd - (char*)mPool) >> SHIFT_VALUE) - 1L);
  mSentinel = mPool + mNumberOfBlocks;

  mSentinel->blockhdr.blocks = RESERVED;           // now cannot be used
  mSentinel->prev = mSentinel;
  mSentinel->next = mSentinel;

  // Entire pool is initially a single unallocated area.
  //
  head = &mPool[0];
  head->blockhdr.blocks = mNumberOfBlocks;         // initially all of free memeory
  InsertAfter(head);                      // link the sentinel

  memmap_init(); // Initialize all the memory to be owned by trusted domain
  memmap_set_perms((void*) mPool, mNumberOfBlocks * sizeof(Block), MEMMAP_SEG_START|BLOCK_FREE); // Init heap to unallocated
  SET_MSR_BLK_SIZE(8);
  SET_MSR_DOMS_8();
  MMBL = (uint8_t)((uint16_t)heapStart & 0x00FF);
  MMBH = (uint8_t)((uint16_t)heapStart >> 8);
  MMTL = (uint8_t)((uint16_t)heapEnd & 0x00FF);
  MMTH = (uint8_t)((uint16_t)heapEnd >> 8);
  MMPL = (uint8_t)((uint16_t)memmap & 0x00FF);
  MMPH = (uint8_t)((uint16_t)memmap >> 8);
  JTL = 0x00; // Setup jumptable
  JTH = 0x10; // to start at 0x2000
  MSR_ENABLE();
}




//-----------------------------------------------------------------------------
// As each area is examined for a fit, we also examine the following area. 
// If it is free then it must also be on the Free list. Being a doubly-linked 
// list, we can combine these two areas in constant time. If an area is 
// combined, the procedure then looks again at the following area, thus 
// repeatedly combining areas until a reserved area is found. In terminal 
// cases this will be the sentinel block.
//
static Block* MergeBlocks(Block* block)
{
  while (1)
    {
      Block* successor = block + block->blockhdr.blocks;   // point to next area
      if (successor->blockhdr.blocks & RESERVED)           // done if reserved
        {
	  return block;
        }
      Unlink(successor);
      block->blockhdr.blocks += successor->blockhdr.blocks;         // add in its blocks
    }
}

//-----------------------------------------------------------------------------
//
static void SplitBlock(Block* block, uint16_t reqBlocks)  
{
  Block* newBlock = block + reqBlocks;            // create a remainder area
  newBlock->blockhdr.blocks = block->blockhdr.blocks - reqBlocks;   // set its size and mark as free
  block->blockhdr.blocks = reqBlocks;                      // set us to requested size
  InsertAfter(newBlock);                          // stitch remainder into free list
}
    
//-----------------------------------------------------------------------------
//
static void InsertAfter(Block* block)
{
  Block* p = mSentinel->next;
  mSentinel->next = block;
  block->prev = mSentinel;
  block->next = p;
  p->prev = block;
}

//-----------------------------------------------------------------------------
//
static void Unlink(Block* block)
{
  block->prev->next = block->next;
  block->next->prev = block->prev;
}


/**
 * Used by the kernel to notify kernel component panic
 */
int8_t mmc_panic(void)
{
  PORTA = 0xFF;
  while(1){
    PORTA ^= 0xFF;
  }
}

