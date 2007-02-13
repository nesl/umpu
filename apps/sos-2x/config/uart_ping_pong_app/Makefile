# -*-Makefile-*-

PROJ = uart_ping_pong_app
ROOTDIR = ../..

ifeq ($(MODE), sfi)
KER_ASM_SRCS += uart_ping_pong_dom.S
endif

KER_SRCS += uart_ping_pong.c 

include ../Makerules

vpath uart_ping_pong.c ../../modules/demos/uart_ping_pong/
vpath uart_ping_pong_dom.S ../../modules/demos/uart_ping_pong/
