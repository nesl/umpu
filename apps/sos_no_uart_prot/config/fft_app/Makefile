
PROJ = fft_app

ROOTDIR = ../..

ifeq ($(MODE), sfi)
KER_ASM_SRCS += fft_module_dom.S test_fft_fix_module_dom.S
endif

SRCS += fft_module.c fix_fft.c  test_fft_fix_module.c

include ../Makerules

vpath test_fft_fix_module.c  $(ROOTDIR)/modules/demos/fft_module/test_fix_fft/
vpath fft_module.c  $(ROOTDIR)/modules/demos/fft_module/
vpath fix_fft.c  $(ROOTDIR)/modules/demos/fft_module/
vpath fft_module_dom.S  $(ROOTDIR)/modules/demos/fft_module/
vpath test_fft_fix_module_dom.S  $(ROOTDIR)/modules/demos/fft_module/test_fix_fft/
