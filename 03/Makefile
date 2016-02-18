OSNAME=takos

ASRC=./src/asm
CSRC=./src/c
OBJ=./obj
LS=./ls

IMG=$(OSNAME).img
OSSYS=$(OBJ)/$(OSNAME).sys
IPL=$(OBJ)/ipl.bin

HEAD=head.bin

BINOPT=-nostdlib -Wl,--oformat=binary

$(IMG) : $(OSSYS) $(IPL)
	mformat -f 1440 -C -B $(IPL) -i $(IMG) ::
	mcopy $(OSSYS) -i $(IMG) ::

$(IPL) : $(ASRC)/ipl.s
	gcc $(ASRC)/ipl.s -nostdlib -T$(LS)/ipl.ls -o $(IPL)

$(OSSYS) : $(ASRC)/head.s $(ASRC)/func.s $(CSRC)/bootpack.c
	gcc $(ASRC)/head.s -nostdlib -T$(LS)/head.ls -o $(OBJ)/head.bin
	gcc $(CSRC)/*.c $(BINOPT) -c -o $(OBJ)/boot.o
	as $(ASRC)/func.s -o $(OBJ)/func.o
	ld -o $(OBJ)/boot.bin -e Main --oformat=binary $(OBJ)/boot.o $(OBJ)/func.o
	cat $(OBJ)/head.bin $(OBJ)/boot.bin > $(OSSYS)

run : $(IMG)
	qemu-system-i386 -localtime -vga std -fda $(IMG)
debug : $(IMG)
	qemu-system-i386 -s -S  -m 32 -localtime -vga std -fda $(IMG) -redir tcp:5555:127.0.0.1:1234 & 

ipl :; make ipl.bin
head:; make head.bin
img :; make os.img
