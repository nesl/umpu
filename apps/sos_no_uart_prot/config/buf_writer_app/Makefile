
PROJ = buf_writer_app

ROOTDIR = ../..

ifeq ($(MODE), sfi)
KER_ASM_SRCS += buf_writer_dom.S
endif

SRCS += buf_writer.c

include ../Makerules

vpath buf_writer.c  $(ROOTDIR)/modules/demos/buf_writer/
vpath buf_writer_dom.S  $(ROOTDIR)/modules/demos/buf_writer/
