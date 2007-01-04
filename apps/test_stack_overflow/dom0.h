/**
 * \file dom0.h
 * \brief Domain 0 jumptable wrapper
 */


#ifndef _DOM0_H_
#define _DOM0_H_

#define DOM0_JMP_TBL_START 0x2000

typedef void (*dom0_main_func_t)(void);
static inline void dom0_main()
{
  return ((dom0_main_func_t)(DOM0_JMP_TBL_START + 0))();
}


#endif//_DOM0_H_
