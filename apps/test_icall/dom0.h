/**
 * \file dom0.h
 * \brief Domain 0 jumptable wrapper
 */


#ifndef _DOM0_H_
#define _DOM0_H_

#define DOM0_JMP_TBL_START 0x2000

PGM_VOID_P my_jumptable[1] PROGMEM = {(void*)(DOM0_JMP_TBL_START / 2)};

typedef void (*dom0_main_func_t)(void);
static inline void dom0_main(void)
{
  dom0_main_func_t my_func;
  my_func = (dom0_main_func_t)pgm_read_word(my_jumptable);
  return my_func();
  //return ((dom0_main_func_t)(DOM0_JMP_TBL_START + 0))(var);
}


#endif//_DOM0_H_
