; hello-os
	CYLS EQU	10
	org	0x7c00

	;; 	db	0xeb, 0x4e, 0x90
	jmp	short entry
	db	0x90

	db	"helloipl"
	dw	512
	db	1
	dw	1
	db	2
	dw	224
	dw	2880
	db	0xf0
	dw	9
	dw	18
	dw	2
	dd	0
	dd	2880
	db	0,0,0x29
	dd	0xffffffff
	db	"hello-os   "
	db	"fat12   "
	times	18 db 0

entry:
	xor	ax,ax
	mov	ss,ax
	mov	sp,0x7c00
	mov	ds,ax

	;; disk read setting
	mov	ax,0x0820
	mov	es,ax 		
	xor	ch,ch		;silinder
	xor	dh,dh		;head
	mov	cl,2		;sector

	mov	ax, msg_start
	call	print

	mov 	ax, msg_read
	call	print
	
readloop:
	xor	si,si
retry:
	mov	ah,0x02
	mov	al,1
	xor	bx,bx 		;load data on 0x0820
	xor	dl,dl		;drive number
	int 	0x13
	jnc	next
	;; handling errors below
	inc	si
	cmp	si,500
	jae	error

	xor	ah,ah
	xor	dl,dl
	int	0x13		;
	jmp	retry
next:
	mov	ax,es		
	add	ax,0x20
	mov	es,ax
	inc	cl
	cmp	cl,18
	jbe	readloop	; if cl <= 18, goto readloop

	mov	cl,1		;
	add	dh,1
	cmp 	dh,2
	jb	readloop

	xor	dh,dh
	add	ch,1
	cmp	ch,CYLS
	jb	readloop

	mov	ax, msg_ok
	call	print


	mov	ax, msg_exec
	call	print

	mov	[0x0ff0],ch 	;record by where ipl read
	jmp	0xc200

print:
	pusha
	mov	si,ax
putloop:
	mov	al,[si]
	cmp	al,0
	je	putfin
	mov	ah,0x0e 	;set to display one char
	mov	bx,15
	int	0x10
	inc	si
	jmp	putloop
putfin:
	popa
	ret

msg_start:	DB	0x0a, "ipl10.nas", 0x0a, 0
msg_read:	DB	"  reading disk to memory ... ", 0
msg_exec:	DB	"  jump to reading data", 0
msg_ok:		DB	"ok!", 0x0a, 0
msg_error:	DB	"error!", 0x0a, 0

error:
	mov	ax, msg_error
	call	print

	xor	ax,ax
	mov	es,ax
fin:
	hlt
	jmp	fin

	times 	0x1fe-($-$$) db 0
	db	0x55,0xaa

