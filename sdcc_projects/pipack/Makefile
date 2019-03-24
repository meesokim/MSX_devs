CC = sdcc
ASM = sdasz80
PLATFORM = -mz80
EMULATOR = openmsx -carta
HEXBIN = makebin -s 65536
BIN2C = xxd -i

STARTUPDIR = startups
INCLUDEDIR = includes
LIBDIR = libs
SRCDIR = src
TITLE = pipack

ROMSIZE ?= 32k

ifeq ($(ROMSIZE), 16k)
CRT0 = crt0msx.16k.4000.s
else ifeq ($(ROMSIZE), 32k) 
CRT0 = crt0msx.32k.4000.s
endif 
ADDR_CODE = 0x4020
ADDR_DATA = 0xC000
ODIR=out
DIR_GUARD=@mkdir -p $(ODIR)

#VERBOSE = -V
CCFLAGS = $(VERBOSE) $(PLATFORM) --code-loc $(ADDR_CODE) --data-loc $(ADDR_DATA) \
			--no-std-crt0 --out-fmt-ihx --opt-code-size
LDFLAGS = $(VERBOSE) $(PLATFORM) --code-loc $(ADDR_CODE) --data-loc $(ADDR_DATA) \
			--no-std-crt0 --out-fmt-ihx --opt-code-size			
SOURCES1 = $(TITLE).c
SOURCES2 = $(CRT0) vdp_tms9918.s 
SOURCES3 = msx.alf
OBJECTS1 = $(SOURCES1:%.c=out/%.rel)
OBJECTS2 = $(SOURCES2:%.s=out/%.rel)
OBJECTS3 = $(SOURCES3:%.alf=out/%.rel)


OUTFILE = test.rom
.PHONY: all compile build clean emulator

all: compile build

compile: $(SOURCES2) $(SOURCES1) $(SOURCES3)
	@echo "Linking ... " $(OBJECTS2) $(OBJECTS1) $(OBJECTS3)
	
build: main.ihx 
	@echo "Building $(OUTFILE)..."
	@$(HEXBIN) main.ihx $(OUTFILE).tmp
	@dd skip=16384 count=$(ROMSIZE) if=$(OUTFILE).tmp of=$(OUTFILE) bs=1 status=none
	@rm $(OUTFILE).tmp
	@bin2c $(OUTFILE) > $(TITLE).data
	@echo "Done."
#yazd --addr:0x4000 -lst $(OUTFILE) > $(TITLE).lst	

main.ihx: $(OBJECTS2) $(OBJECTS1) $(OBJECTS3)
	@$(CC) $^ $(LDFLAGS) -o $@

clean:
	@echo "Cleaning..."
	@rm -f $(OUTFILE) *.asm *.bin *.cdb *.ihx *.lk *.lst *.map *.mem *.omf *.rst */*.rel *.sym *.noi *.hex *.lnk *.dep
	@rm -rf $(ODIR)

emulator: $(OUTFILE)
	$(EMULATOR) $(OUTFILE) &

%.s:
	@echo "Compiling $@"
	$(DIR_GUARD)
	@[ -f $(STARTUPDIR)/$@ ] && [ ! -f $(ODIR)/$(@:.s=rel) ] && $(ASM) -j -l -s -o $(ODIR)/$(notdir $(@:.s=.rel)) $(STARTUPDIR)/$@ || true
	@[ -f $(LIBDIR)/$@ ] && $(ASM) -j -l -s -o $(ODIR)/$(notdir $(@:.s=.rel)) $(LIBDIR)/$@ || true
	@[ -f $(SRCDIR)/$@ ] && $(ASM) -j -l -s -o $(ODIR)/$(notdir $(@:.s=.rel)) $(SRCDIR)/$@ || true
	
%.c:
	@echo "Compiling $@"
	$(DIR_GUARD)
	@[ -f $(LIBDIR)/$@ ] && $(CC) $(VERBOSE) $(PLATFORM) -I$(INCLUDEDIR) -c -o $(ODIR)/$(notdir $(@:.c=.rel)) $(LIBDIR)/$@ || true
	@[ -f $(SRCDIR)/$@ ] && $(CC) $(VERBOSE) $(PLATFORM) -I$(INCLUDEDIR) -c -o $(ODIR)/$(notdir $(@:.c=.rel)) $(SRCDIR)/$@ || true 
	
%.alf:
	@echo "Converting $@"
	@$(BIN2C) $(SRCDIR)/$@ > $(SRCDIR)/$@.c
	@sed -i s/unsigned/const\ unsigned/ -i $(SRCDIR)/$@.c
	@[ -f $(SRCDIR)/$@.c ] &&  $(CC) $(VERBOSE) $(PLATFORM) -I$(INCLUDEDIR) -c -o $(ODIR)/$(notdir $(@:.alf=.rel)) $(SRCDIR)/$@.c || true 
	
		
#%.rel: %.s
#	@echo "Compiling ..$@"
#	@$(ASM) -o $<

#%.rel: %.c
#	@echo "Compiling $@"
#	$(CC) -I$(INCLUDEDIR) $(PLATFORM) -c $<  -o $@
	