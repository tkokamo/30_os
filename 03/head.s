.equ	CYLS, 0x0ff0
.equ	LEDS, 0x0ff1
.equ	VMODE, 0x0ff2
.equ	SCRNX, 0x0ff4
.equ	SCRNY, 0x0ff6
.equ	VRAM, 0x0ff8
	
.code16
.text
	movb	$0x13, %al
	movb	$0x00, %ah
	int	$0x10
	movb	$8, (VMODE)
	movw	$320, (SCRNX)
	movw	$200, (SCRNY)
	movl	$0x000a0000, (VRAM)

	movb	$0x02, %ah
	int	$0x16
	movb	%al, (LEDS)

# move to 32 bit mode
	#forbid int to pic
	movb	$0xff, &al
	outb	%al, $0x21
	nop
	outb	%al, $0xa1
	cli

	# enable A20
	call	waitkdbout
	movb	$0xd1, %al
	outb	%al, $0x64 # what is this number?
	call	waitkdbout
	movb	$0xdf, $0x60 #enable A20
	call	waitkdbout

.arch i486 #32bit native code
	lgdtl 	(GDTR0)
	movl	%cr0, %eax
	andl	$0x7fffffff, %eax  #set 0 on bit31 (disable paging)
	orl	$0x00000000, %eax  #set 1 on bit0 (move to protected mode)
	movl	%eax, %cr0
	jmp	pipelineflash
pipelineflash:
	movw	$1*8, %ax
	movw	%ax, %ds
	movw	%ax, %es
	movw	%ax, %fs
	movw	%ax, %gs
	movw	%ax, %ss

	#transfer bootpack
	movl	$bootpack, %esi
	movl	$BOTPAK, %edi
	movl	$512*1024/4, %ecx
	call	memcpy

	#transfer bootsector
	movl	$0x7c00, %esi
	movl	$DSKCAC, %edi
	movl	$512/4, %ecx
	call 	memcpy

	#rest
	movl	$DSKCAC0+512, %esi
	movl	$DSKCAC0+512, %edi
	movl	$0x00,
	
fin:
	hlt
	jmp	fin
	
