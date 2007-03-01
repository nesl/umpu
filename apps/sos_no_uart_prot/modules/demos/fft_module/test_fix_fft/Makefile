# -*-Makefile-*-
##################################
# PROJECT
##################################
PROJ = test_fix_fft
ROOTDIR = ../../../..


SRCS += $(PROJ).c fix_fft.c
OBJS += $(SRCS:.c=.o)

VPATH += $(ROOTDIR)/modules/demos/fft_module

INCDIR += -I$(ROOTDIR)/kernel/include 
INCDIR += -I$(ROOTDIR)/modules/include 
INCDIR += -I$(ROOTDIR)/processor/posix/include 
INCDIR += -I$(ROOTDIR)/platform/emu/include 
INCDIR += -I$(ROOTDIR)/modules
INCDIR += -I$(ROOTDIR)/drivers/include
INCDIR += -I$(ROOTDIR)/drivers/uart/include 

DEFS += -DNO_PID_PROC -DNO_PID_PLAT
CFLAGS += -Wall -Werror

HOST = $(shell uname -s)
ifeq ($(HOST), Darwin)
CFLAGS += -DBBIG_ENDIAN
else
CFLAGS += -DLLITTLE_ENDIAN
endif

CC = gcc

include $(ROOTDIR)/tools/sos_server/lib/Makesossrvlib

%.o : %.c
	$(CC) -c $(CFLAGS) $(DEFS) $(INCDIR) $< -o $@

%.exe: $(OBJS)
	$(CC) $(OBJS) $(LIBS) -o $@

all: $(PROJ).exe


clean:
	rm -fr *~ *.o $(PROJ).exe
