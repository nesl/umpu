PROJ  = raw_send
SRCS  = port_avr.c sp_timer.c hw_timer.c sched.c
OBJS += $(SRCS:.c=.o)
INSTALLER = uisp -dpart=atmega103 -dprog=mib510 -dserial=$(PORT)

%.o : %.c
	avr-gcc -c $(DEFS) -g -Os -Wa,-mmcu=atmega103,-Wa,-gstabs,-adhlmsn=$(notdir $(<:.c=.lst)) -mmcu=atmega103 -I. -Wall $< -o $@

%.elf: $(OBJS)
	avr-gcc -g $(OBJS) -lm -mmcu=atmega103 -o $@

%.elf.lst: %.elf
	avr-objdump -h -S $< > $@

%.od: %.elf
	avr-objdump -zhD $< > $@

%.srec : %.elf
	avr-objcopy -O srec -R .eeprom $< $@

%.ihex : %.elf
	avr-objcopy -j .text -O ihex -R .eeprom $< $@

%.vhd: %.ihex
	../../swlib/hex2vhd.exe $<
	mv programToLoad.vhd ../../vhd/

all: $(PROJ).od $(PROJ).elf $(PROJ).elf.lst $(OBJS) $(PROJ).ihex $(PROJ).vhd
	avr-size -A $(PROJ).elf

install: $(PROJ).srec
	$(INSTALLER) --erase						    
	sleep 2
	$(INSTALLER) --upload if=$(PROJ).srec
	sleep 2
	$(INSTALLER) --verify if=$(PROJ).srec

clean:
	rm -rf *.o *.lst *.elf *.elf.lst *~ *.ihex *.od
