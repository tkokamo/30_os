.code32
.globl	io_hlt
.globl  write_mem8
	
.text
io_hlt:
	hlt
	ret

write_mem8:
	# void write_mem8(int addr, int data) 
	movl	4(%esp), %ecx  # substitute addr to ecx
	movb	8(%esp), %al # data into al
	movb	%al, (%ecx) # data int addr
	ret
