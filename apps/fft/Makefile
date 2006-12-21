
PROJ = test_fix_fft
SRCS += $(PROJ).c

ROOTDIR = ../..
INCDIR += -I$(ROOTDIR)/swlib -I.
VPATH  += $(ROOTDIR)/swlib

SRCS += malloc.c memmap.c fix_fft.c
ASMSRCS += dom_trusted_proc.S dom_0_proc.S dom_1_proc.S

OBJS += $(SRCS:.c=.o) $(ASMSRCS:.S=.o)

TRG = avr-

CC  = $(TRG)gcc

AS     = $(TRG)gcc 

OBJCOPY = $(TRG)objcopy

OBJDUMP = $(TRG)objdump

SIZE = $(TRG)size -A

MCU = atmega103

MCUFLAG += -mmcu=$(MCU)

COMMONFLAGS += $(MCUFLAG) -Werror $(DEFS) -Os -Wall
CFLAGS += $(COMMONFLAGS) -Wa,-adhlmsn=$(notdir $(<:.c=.lst))
SFLAGS += $(COMMONFLAGS)

LDFLAGS += $(MCUFLAG) -Wl,-Map=$(PROJ).map,--cref -Wl,-T $(ROOTDIR)/swlib/sos_sfi_avr5.x
LDFLAGS += -Wl,--section-start=.dom0jmptbl=0x2000 -Wl,--section-start=.dom1jmptbl=0x2100 -Wl,--section-start=.domtrustjmptbl=0x2700

###################################################
# PROTOTYPES
###################################################
%.elf: $(OBJS)
	$(CC) $(OBJS) $(LIBS) $(LDFLAGS) -o $@
	$(SIZE) -A $@

%.elf.lst: %.elf
	$(OBJDUMP)  -h -S $< > $@

%.bin : %.elf
	$(OBJCOPY) -O binary -R .eeprom $< $@

%.o : %.S
	$(CC) $(INCDIR) $(SFLAGS) -c $< -o $@

%.o : %.c
	$(CC) $(INCDIR) $(CFLAGS) -c $< -o $@

%.ihex : %.elf
	$(OBJCOPY) -j .text -j .dom0jmptbl -j .dom1jmptbl -j .domtrustjmptbl -O ihex -R .eeprom $< $@

%.vhd: %.ihex
	../../swlib/hex2vhd.exe $<
	mv programToLoad.vhd ../../vhd/

all:	$(PROJ).elf $(PROJ).elf.lst $(PROJ).bin $(PROJ).ihex $(PROJ).vhd $(OBJS)


clean:
	rm -f *.elf *.elf.lst *.bin *.lst *.o *.map *~ *.ihex rm*.vhd
