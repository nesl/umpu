# -*-Makefile-*-

PROJ = uartTxTest_app
ROOTDIR = ../..

ifeq ($(MODE), sfi)
KER_ASM_SRCS += uartTxTest_dom.S
endif

KER_SRCS += uartTxTest.c 

include ../Makerules

vpath uartTxTest.c ../../modules/demos/uartTxTest/
vpath uartTxTest_dom.S ../../modules/demos/uartTxTest/
