
PROJ = fft_app

ROOTDIR = ../..

DEFS += -D'UART_ADDR=0x8000'

SRCS += fft_module.c fix_fft.c  test_fft_fix_module.c
#loader.c


include ../Makerules


vpath test_fft_fix_module.c  $(ROOTDIR)/modules/demos/fft_module/test_fix_fft/
vpath fft_module.c  $(ROOTDIR)/modules/demos/fft_module/
vpath fix_fft.c  $(ROOTDIR)/modules/demos/fft_module/
vpath loader.c   $(ROOTDIR)/extensions/loader/