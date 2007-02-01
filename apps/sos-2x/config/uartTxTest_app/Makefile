# -*-Makefile-*-

PROJ = uartTxTest_app
ROOTDIR = ../..

ifeq ($(MODE), sfi)
ASMSRCS += uartTxTest_dom.S
endif

SRCS += uartTxTest.c 

include ../Makerules

vpath uartTxTest.c ../../modules/demos/uartTxTest/
vpath uartTxTest_dom.S ../../modules/demos/uartTxTest/
