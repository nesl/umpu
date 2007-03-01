
/*
  Short test program to accompany fix_fft.c
*/

#define DBG_TEST_FIX_FFT 1
#define SPECTRUM 0

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <unistd.h>
#include <string.h>
#include <sys/time.h>
#include <inttypes.h>

#include <sossrv_client.h>
#include <sossrv.h>
#include <sos_endian.h>

#include <demos/fft_module/fft_module.h>

//#include "fix_fft.c"
/*
#define FFT_SIZE  32
#define log2FFT   5
#define N         (2 * FFT_SIZE)
#define log2N     (log2FFT + 1)
*/

#define FREQUENCY 5
#define AMPLITUDE 12288

int fftdone;
short rx_fx[N];

int test_fix_fft_rx_msg(Message* rxsosmsg);
static int test_fix_fft();
static void printusage();

int main(int argc, char** argv)
{
  char* networkport;
  char *sossrvipaddr;
  char *sossrvportnum;
  int ch;  
  char DEFAULT_SOS_PORT[] = "127.0.0.1:7915";
  networkport = DEFAULT_SOS_PORT;
  while ((ch = getopt(argc, argv, "hn:")) != -1){
    switch(ch) {
    case 'n': networkport = optarg; break;
    case '?': case 'h':
      printusage();
      exit(EXIT_FAILURE);
      break;
    }
  };
  
  // Parse the IP Address and Port
  sossrvipaddr = (char*)strsep(&networkport,":");
  sossrvportnum = networkport;
  
  if (sossrv_connect(sossrvipaddr, sossrvportnum) != 0){
    fprintf(stderr, "test_fix_fft: sossrv_connect - Failed to connect to SOS Server.\n");
    exit(EXIT_FAILURE);
  }

  sossrv_recv_msg(test_fix_fft_rx_msg);

  test_fix_fft();
  return 0;
}

static int test_fix_fft()
{
  int i, scale;
  unsigned diff;
  short x[N], fx[N];


  for (i=0; i<N; i++){
    x[i] = AMPLITUDE*cos(i*FREQUENCY*(2*3.1415926535)/N);
    if (i & 0x01)
      fx[(N+i)>>1] = ehtons(x[i]);
    else
      fx[i>>1] = ehtons(x[i]);
#if DBG_TEST_FIX_FFT
    printf("%d %d\n", i, x[i]);
#endif
  }
  puts("");


  //  for (i=0; i<N/2; i++) printf("%d %d\n", i, fx[i]);
  for (i=0; i<N; i++){
    printf("%d, ", fx[i]);
    if (((i+1)%8) == 0)
      printf("\n");
  }
  printf("\n");
  //  return 0;


  sossrv_post_msg(FFT_FIX_PID, FFT_FIX_PID, MSG_DO_FFT, 
		  sizeof(int16_t)*N, (void*)fx, 124, 0);
  printf("Sent a buffer of size : %d\n", (int)(sizeof(int16_t)*N));
  //  fix_fftr(fx, log2N, 0);
  fftdone = 0;
  while (!fftdone);
 


  scale = fix_fftr(rx_fx, log2N, 1);
  fprintf(stderr, "scale = %d\n", scale);

  for (i=0,diff=0; i<N; i++) {
    int sample;
    if (i & 0x01)
      sample = rx_fx[(N+i)>>1] << scale;
    else
      sample = rx_fx[i>>1] << scale;
#if DBG_TEST_FIX_FFT
    printf("%d %d\n", i, sample);
#endif
    diff += abs(x[i]-sample);
  }
  fprintf(stderr, "sum(abs(diffs)))/N = %g\n", diff/(double)N);

  return 0;
}
//---------------------------------------------------------------------------------
int test_fix_fft_rx_msg(Message* rxsosmsg)
{
  printf("Received a message\n");
  if ((rxsosmsg->did == FFT_FIX_PID) && 
      (rxsosmsg->type == MSG_FFT_DONE)){
    int i;
    short* rxdata;
    printf("Message from FFT Module\n");
    rxdata = (short*)rxsosmsg->data;
    for (i = 0; i < N; i++)
      rx_fx[i] = entohs(rxdata[i]);
    fftdone = 1;
  }
  return 0;
}
//---------------------------------------------------------------------------------
// ERROR EXIT FUNCTION
static void printusage()
{
  printf("test_fix_fft [-n <TCP Port>]\n");
  printf(" -n <TCP Port>: TCP Port is <IP Addr:Port Num> e.g. 127.0.0.1:7915\n");
}
