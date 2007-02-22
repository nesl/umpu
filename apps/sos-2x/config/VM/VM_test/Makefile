# -*-Makefile-*-
###############################################
# Makefile for Virtual Machine
###############################################
PROJ = vm_config
ROOTDIR = ../../..

ifeq ($(MODE), sfi)
KER_ASM_SRCS += dvm_dom.S
endif

VPATH += $(ROOTDIR)/modules/VM/coreVM
VPATH += $(ROOTDIR)/modules/VM/script_loader
VPATH += $(ROOTDIR)/extensions/loader


DEFS += -DINCL_VM 


################################################
# LOADER
################################################
SRCS += loader.c

################################################
# PHOTOSENSOR DRIVER
################################################
#INCDIR += -I$(ROOTDIR)/modules/sensordrivers/mts310/include/
#SRCS += phototemp_sensor.c


KER_SRCS += script_loader.c
KER_SRCS += dvm.c DVMScheduler.c DVMResourceManager.c DVMEventHandler.c
KER_SRCS += DVMConcurrencyMngr.c DVMBasiclib.c DVMStacks.c DVMqueue.c

include ../../Makerules

vpath phototemp_sensor.c $(ROOTDIR)/modules/sensordrivers/mts310/photo_temp