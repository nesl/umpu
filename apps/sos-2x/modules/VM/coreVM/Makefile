# -*-Makefile-*-
#######################
# Makefile for DVM
# Builds a single module for the entire Virtual machine
# VM allows extension points
######################

PROJ = dvm
ROOTDIR = ../../..
VPATH += $(ROOTDIR)/modules/VM/coreVM
INCDIR += -I$(ROOTDIR)/modules/include/VM

SUPPORTLIST = cyclops mica2 micaz xyz avrora cricket tmote

SRCS += DVMScheduler.c DVMConcurrencyMngr.c DVMResourceManager.c DVMEventHandler.c
SRCS += DVMBasiclib.c DVMStacks.c DVMqueue.c

include ../../Makerules