
PROJ = test_timer
SRCS += $(PROJ).c
OBJS += $(SRCS:.c=.o)


TRG = avr-

CC  = $(TRG)gcc

AS     = $(TRG)gcc 

OBJCOPY = $(TRG)objcopy

OBJDUMP = $(TRG)objdump

SIZE = $(TRG)size -A

MCU = atmega103

MCUFLAG += -mmcu=$(MCU)

CFLAGS += $(MCUFLAG) -Werror $(DEFS) -O0 -Wall -Wa,-adhlmsn=$(notdir $(<:.c=.lst))

LDFLAGS += $(MCUFLAG) -Wl,-Map=$(PROJ).map,--cref

###################################################
# PROTOTYPES
###################################################
%.elf: $(OBJS)
	$(CC) $(OBJS) $(LIBS) $(LDFLAGS) -o $@
	$(SIZE) -A $@

%.elf.lst: %.elf
	$(OBJDUMP) -j .text -h -S $< > $@

%.bin : %.elf
	$(OBJCOPY) -j .text -O binary -R .eeprom $< $@

%.o : %.c
	$(CC) $(INCDIR) $(CFLAGS) -c $< -o $@

%.ihex : %.elf
	$(OBJCOPY) -j .text -O ihex -R .eeprom $< $@

%.vhd: %.ihex
	../../swlib/hex2vhd.exe $<
	mv programToLoad.vhd ../../vhd/

all:	$(PROJ).elf $(PROJ).elf.lst $(PROJ).bin $(PROJ).ihex $(PROJ).vhd


clean:
	rm -f *.elf *.elf.lst *.bin *.lst *.o *.map *~ *.ihex
