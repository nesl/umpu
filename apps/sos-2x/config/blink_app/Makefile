# -*-Makefile-*-

PROJ = blink_app
ROOTDIR = ../..

ifeq ($(MODE), sfi)
ASMSRCS += blink_dom.S
endif

SRCS += blink.c 

include ../Makerules

vpath blink.c ../../modules/demos/blink/
vpath blink_dom.S ../../modules/demos/blink/

