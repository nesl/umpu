/**
 * \file fft_module.h
 * \brief FFT module definitions
 * \author Ram Kumar {ram@ee.ucla.edu}
 */

#ifndef _FFT_MODULE_H_
#define _FFT_MODULE_H_

#define FFT_SIZE  32
#define log2FFT   5
#define N         (2 * FFT_SIZE)
#define log2N     (log2FFT + 1)

#define FFT_FIX_PID DFLT_APP_ID0
#define TEST_FFT_FIX_PID DFLT_APP_ID1


#define MSG_DO_FFT    (MOD_MSG_START + 0)
#define MSG_FFT_DONE  (MOD_MSG_START + 1)

int fix_fft(short fr[], short fi[], short m, short inverse);
int fix_fftr(short f[], int m, int inverse);

#endif//_FFT_MODULE_H_
