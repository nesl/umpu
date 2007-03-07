PROJ = outlier_avg_app

ROOTDIR = ../..

ifeq ($(MODE), sfi)
KER_ASM_SRCS += outlier_avg_dom.S
endif


KER_SRCS += outlier_avg.c

include ../Makerules


vpath outlier_avg.c $(ROOTDIR)/modules/demos/outlier_avg
vpath outlier_avg_dom.S $(ROOTDIR)/modules/demos/outlier_avg

