/**
 * \file dom1.h
 * \brief Domain 1 jumptable wrapper
 */


#ifndef _DOM1_H_
#define _DOM1_H_

#define DOM1_JMP_TBL_START 0x2100

typedef int (*fix_fft_func_t)(short*, int, int);
static inline int fix_fftr(short f[], int m, int inverse)
{
  return ((fix_fft_func_t)(DOM1_JMP_TBL_START + 0))(f,m,inverse);
}


#endif//_DOM1_H_
