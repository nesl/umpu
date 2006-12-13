/**
 * \file malloc_conf.h
 * \brief Configure memory allocator
 */

#ifndef _MALLOC_CONF_H_
#define _MALLOC_CONF_H_

#define BLOCK_SIZE           8               // A block size (must be power of 2) (Platform specific)
#define SHIFT_VALUE          3               // Must equal log(BLOCK_SIZE)/log(2)
#define MALLOC_HEAP_SIZE   2048              // 512 * 4 bytes


#endif//_MALLOC_CONF_H_
