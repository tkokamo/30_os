.equ CYLS, 10
	.text
	.code16
	jmp	 entry
	.byte	0x90

	.ascii	"helloipl"
	.word	512
	.byte	1
	.word	1
	.byte	2
	.word	224
	.word	2880
	.byte	0xf0
	.word	9
	.word	18
	.word	2
	.int	0
	.int	2880
	.byte	0,0,0x29
	.int	0xffffffff
	.ascii	"hello-os   "
	.ascii	"fat12   "
	.skip	18, 0x00

entry:
	xorw	%ax, %ax
	movw	%ax, %ss
	movw	$0x7c00, %sp
	movw	%ax, %ds

	# disk read setting
	movw	$0x0820, %ax
	movw	%ax, %es 		
	xorb	%ch, %ch		#silinder
	xorb	%dh, %dh		#head
	movb	$2, %cl		#sector

	movw	$msg_start, %ax
	call	print
	
	movw 	$msg_read, %ax
	call	print


readloop:
	xorw	%si, %si
retry:
	movb	$0x02, %ah
	movb	$0x01, %al
	xorw	%bx, %bx 		#load data on 0x0820
	xorb	%dl, %dl		#drive number
	int 	$0x13
	jnc	next
	## handling errors below
	incw	%si
	cmp	$0x05, %si
	jae	error

	xorb	%ah, %ah
	xorb	%dl, %dl
	int	$0x13		#
	jmp	retry
next:
	## sector
	movw	%es, %ax		
	addw	$0x20, %ax
	movw	%ax, %es
	incb	%cl
	cmp	$18, %cl
	jbe	readloop	# if cl <= 18, goto readloop
	## header
	movb	$0x01, %cl		#
	addb	$0x01, %dh
	cmpb 	$2, %dh
	jb	readloop
	## cilinder
	xorb	%dh, %dh
	addb	$1, %ch
	cmpb	$CYLS, %ch
	jb	readloop

	movw	$msg_ok, %ax
	call	print


	movw	$msg_exec, %ax
	call	print
	hlt
	movb	%ch, (0x0ff0) 	#record by where ipl read
	hlt
	jmp	0xc200
	#jmp 	fin
print:
	pusha
	movw	%ax, %si
putloop:
	movb	(%si), %al
	cmpb	$0, %al
	je	putfin
	movb	$0x0e, %ah 	#set to display one char
	movw	$15, %bx
	int	$0x10
	incw	%si
	jmp	putloop
putfin:
	popa
	ret


error:
	movw	$msg_error, %ax
	call	print

	xorw	%ax, %ax
	movw	%ax, %es
fin:
	hlt
	#jmp	fin

.data
msg_start:	.string "ipl.s\n"
msg_read:	.string	"  reading disk to memory ... "
msg_exec:	.string	"  jump to reading data"
msg_ok:		.string	"ok!\n"
msg_error:	.string	"error!\n"
