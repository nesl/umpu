/**
 * \file dom1.h
 * \brief Domain 1 jumptable wrapper
 */


#ifndef _DOM1_H_
#define _DOM1_H_

#define DOM1_JMP_TBL_START 0x2100

typedef void (*dom1_main_func_t)(uint8_t*);
static inline void dom1_main(uint8_t* buffer)
{
  return ((dom1_main_func_t)(DOM1_JMP_TBL_START + 0))(buffer);
}


#endif//_DOM1_H_
