#ifndef _FIX_FFT_H_
#define _FIX_FFT_H_

#include <inttypes.h>
#include <avr/pgmspace.h>
#include <malloc.h>
#include <memmap.h>
#include <dom0.h>
#include <dom1.h>

#define FFT_SIZE  128
#define log2FFT   7
#define N         (2 * FFT_SIZE)
#define log2N     (log2FFT + 1)
#define FREQUENCY 5
#define AMPLITUDE 12288

#define N_WAVE      1024    /* full length of Sinewave[] */
#define LOG2_N_WAVE 10      /* log2(N_WAVE) */

int absolute(int number);

int fix_fft_real(short f[], int m, int inverse);

#endif//_FIX_FFT_H_
