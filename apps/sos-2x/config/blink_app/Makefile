# -*-Makefile-*-

PROJ = blink_app
ROOTDIR = ../..

ifeq ($(MODE), sfi)
KER_ASM_SRCS += blink_dom.S
endif

KER_SRCS += blink.c 


include ../Makerules

vpath blink.c ../../modules/demos/blink/
vpath blink_dom.S ../../modules/demos/blink/

