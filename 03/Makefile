IMG=os.img
IPL=ipl.bin
HEAD=head.bin

all : ipl.s
	make ipl
	make head
	make img
	make run

os.img : $(IPL)
	mformat -f 1440 -C -B $(IPL) -i $(IMG) ::
	mcopy ./head.bin -i $(IMG) ::

ipl.bin : ipl.s ipl.ls
	gcc ipl.s -nostdlib -Tipl.ls -o $(IPL)

head.bin : head.s head.ls
	gcc head.s -nostdlib -Thead.ls -o $(HEAD)

run : $(IMG)
	qemu-system-i386 -localtime -vga std -fda $(IMG)

ipl :; make ipl.bin
head:; make head.bin
img :; make os.img
