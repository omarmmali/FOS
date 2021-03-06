
obj/boot/boot.out:     file format elf32-i386


Disassembly of section .text:

00007c00 <start>:
# memory can accessed, then calls into C.
###############################################################################
	
.globl start					# Entry point	
start:		.code16				# This runs in real mode
		cli				# Disable interrupts
    7c00:	fa                   	cli    
		cld				# String operations increment
    7c01:	fc                   	cld    

		# Set up the important data segment registers (DS, ES, SS).
		xorw	%ax,%ax			# Segment number zero
    7c02:	31 c0                	xor    %eax,%eax
		movw	%ax,%ds			# -> Data Segment
    7c04:	8e d8                	mov    %eax,%ds
		movw	%ax,%es			# -> Extra Segment
    7c06:	8e c0                	mov    %eax,%es
		movw	%ax,%ss			# -> Stack Segment
    7c08:	8e d0                	mov    %eax,%ss

		# Set up the stack pointer, growing downward from 0x7c00.
		movw	$start,%sp         	# Stack Pointer
    7c0a:	bc                   	.byte 0xbc
    7c0b:	00                   	.byte 0x0
    7c0c:	7c                   	.byte 0x7c

00007c0d <seta20.1>:
#   and subsequent 80286-based PCs wanted to retain maximum compatibility),
#   physical address line 20 is tied to low when the machine boots.
#   Obviously this a bit of a drag for us, especially when trying to
#   address memory above 1MB.  This code undoes this.
	
seta20.1:	inb	$0x64,%al		# Get status
    7c0d:	e4 64                	in     $0x64,%al
		testb	$0x2,%al		# Busy?
    7c0f:	a8 02                	test   $0x2,%al
		jnz	seta20.1		# Yes
    7c11:	75 fa                	jne    7c0d <seta20.1>
		movb	$0xd1,%al		# Command: Write
    7c13:	b0 d1                	mov    $0xd1,%al
		outb	%al,$0x64		#  output port
    7c15:	e6 64                	out    %al,$0x64

00007c17 <seta20.2>:
seta20.2:	inb	$0x64,%al		# Get status
    7c17:	e4 64                	in     $0x64,%al
		testb	$0x2,%al		# Busy?
    7c19:	a8 02                	test   $0x2,%al
		jnz	seta20.2		# Yes
    7c1b:	75 fa                	jne    7c17 <seta20.2>
		movb	$0xdf,%al		# Enable
    7c1d:	b0 df                	mov    $0xdf,%al
		outb	%al,$0x60		#  A20
    7c1f:	e6 60                	out    %al,$0x60

00007c21 <real_to_prot>:
#   OK to run code at any address, or write to any address.
#   The 'gdt' and 'gdtdesc' tables below define these segments.
#   This code loads them into the processor.
#   We need this setup to ensure the transition to protected mode is smooth.

real_to_prot:	cli			# Don't allow interrupts: mandatory,
    7c21:	fa                   	cli    
					# since we didn't set up an interrupt
					# descriptor table for handling them
		lgdt	gdtdesc		# load GDT: mandatory in protected mode
    7c22:	0f 01 16             	lgdtl  (%esi)
    7c25:	64 7c 0f             	fs jl  7c37 <protcseg+0x1>
		movl	%cr0, %eax	# Turn on protected mode
    7c28:	20 c0                	and    %al,%al
		orl	$CR0_PE_ON, %eax
    7c2a:	66 83 c8 01          	or     $0x1,%ax
		movl	%eax, %cr0
    7c2e:	0f 22 c0             	mov    %eax,%cr0

	        # CPU magic: jump to relocation, flush prefetch queue, and
		# reload %cs.  Has the effect of just jmp to the next
		# instruction, but simultaneously loads CS with
		# $PROT_MODE_CSEG.
		ljmp	$PROT_MODE_CSEG, $protcseg
    7c31:	ea                   	.byte 0xea
    7c32:	36 7c 08             	ss jl  7c3d <protcseg+0x7>
	...

00007c36 <protcseg>:
	
		# we've switched to 32-bit protected mode; tell the assembler
		# to generate code for that mode
protcseg:	.code32
		# Set up the protected-mode data segment registers
		movw	$PROT_MODE_DSEG, %ax	# Our data segment selector
    7c36:	66 b8 10 00          	mov    $0x10,%ax
		movw	%ax, %ds		# -> DS: Data Segment
    7c3a:	8e d8                	mov    %eax,%ds
		movw	%ax, %es		# -> ES: Extra Segment
    7c3c:	8e c0                	mov    %eax,%es
		movw	%ax, %fs		# -> FS
    7c3e:	8e e0                	mov    %eax,%fs
		movw	%ax, %gs		# -> GS
    7c40:	8e e8                	mov    %eax,%gs
		movw	%ax, %ss		# -> SS: Stack Segment
    7c42:	8e d0                	mov    %eax,%ss
	
		call cmain			# finish the boot load from C.
    7c44:	e8 d2 00 00 00       	call   7d1b <cmain>

00007c49 <spin>:
						# cmain() should not return
spin:		jmp spin			# ..but in case it does, spin
    7c49:	eb fe                	jmp    7c49 <spin>
    7c4b:	90                   	nop

00007c4c <gdt>:
	...
    7c54:	ff                   	(bad)  
    7c55:	ff 00                	incl   (%eax)
    7c57:	00 00                	add    %al,(%eax)
    7c59:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c60:	00                   	.byte 0x0
    7c61:	92                   	xchg   %eax,%edx
    7c62:	cf                   	iret   
	...

00007c64 <gdtdesc>:
    7c64:	17                   	pop    %ss
    7c65:	00 4c 7c 00          	add    %cl,0x0(%esp,%edi,2)
	...

00007c6a <waitdisk>:
	}
}

void
waitdisk(void)
{
    7c6a:	55                   	push   %ebp
    7c6b:	89 e5                	mov    %esp,%ebp

static __inline uint8
inb(int port)
{
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
    7c6d:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7c72:	ec                   	in     (%dx),%al
	// wait for disk reaady
	while ((inb(0x1F7) & 0xC0) != 0x40)
    7c73:	83 e0 c0             	and    $0xffffffc0,%eax
    7c76:	3c 40                	cmp    $0x40,%al
    7c78:	75 f8                	jne    7c72 <waitdisk+0x8>
		/* do nothing */;
}
    7c7a:	5d                   	pop    %ebp
    7c7b:	c3                   	ret    

00007c7c <readsect>:

void
readsect(void *dst, uint32 offset)
{
    7c7c:	55                   	push   %ebp
    7c7d:	89 e5                	mov    %esp,%ebp
    7c7f:	57                   	push   %edi
    7c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	// wait for disk to be ready
	waitdisk();
    7c83:	e8 e2 ff ff ff       	call   7c6a <waitdisk>
}

static __inline void
outb(int port, uint8 data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
    7c88:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7c8d:	b0 01                	mov    $0x1,%al
    7c8f:	ee                   	out    %al,(%dx)
    7c90:	ba f3 01 00 00       	mov    $0x1f3,%edx
    7c95:	88 c8                	mov    %cl,%al
    7c97:	ee                   	out    %al,(%dx)
    7c98:	89 c8                	mov    %ecx,%eax
    7c9a:	c1 e8 08             	shr    $0x8,%eax
    7c9d:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7ca2:	ee                   	out    %al,(%dx)
    7ca3:	89 c8                	mov    %ecx,%eax
    7ca5:	c1 e8 10             	shr    $0x10,%eax
    7ca8:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7cad:	ee                   	out    %al,(%dx)
    7cae:	89 c8                	mov    %ecx,%eax
    7cb0:	c1 e8 18             	shr    $0x18,%eax
    7cb3:	83 c8 e0             	or     $0xffffffe0,%eax
    7cb6:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7cbb:	ee                   	out    %al,(%dx)
    7cbc:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7cc1:	b0 20                	mov    $0x20,%al
    7cc3:	ee                   	out    %al,(%dx)
	outb(0x1F5, offset >> 16);
	outb(0x1F6, (offset >> 24) | 0xE0);
	outb(0x1F7, 0x20);	// cmd 0x20 - read sectors

	// wait for disk to be ready
	waitdisk();
    7cc4:	e8 a1 ff ff ff       	call   7c6a <waitdisk>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
    7cc9:	8b 7d 08             	mov    0x8(%ebp),%edi
    7ccc:	b9 80 00 00 00       	mov    $0x80,%ecx
    7cd1:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7cd6:	fc                   	cld    
    7cd7:	f2 6d                	repnz insl (%dx),%es:(%edi)

	// read a sector
	insl(0x1F0, dst, SECTSIZE/4);
}
    7cd9:	5f                   	pop    %edi
    7cda:	5d                   	pop    %ebp
    7cdb:	c3                   	ret    

00007cdc <readseg>:

// Read 'count' bytes at 'offset' from kernel into virtual address 'va'.
// Might copy more than asked
void
readseg(uint32 va, uint32 count, uint32 offset)
{
    7cdc:	55                   	push   %ebp
    7cdd:	89 e5                	mov    %esp,%ebp
    7cdf:	57                   	push   %edi
    7ce0:	56                   	push   %esi
    7ce1:	53                   	push   %ebx
    7ce2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32 end_va;

	va &= 0xFFFFFF;
	end_va = va + count;
    7ce5:	89 de                	mov    %ebx,%esi
    7ce7:	81 e6 ff ff ff 00    	and    $0xffffff,%esi
    7ced:	03 75 0c             	add    0xc(%ebp),%esi
	
	// round down to sector boundary
	va &= ~(SECTSIZE - 1);
    7cf0:	81 e3 00 fe ff 00    	and    $0xfffe00,%ebx

	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;
    7cf6:	8b 7d 10             	mov    0x10(%ebp),%edi
    7cf9:	c1 ef 09             	shr    $0x9,%edi
    7cfc:	47                   	inc    %edi

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (va < end_va) {
    7cfd:	39 f3                	cmp    %esi,%ebx
    7cff:	73 12                	jae    7d13 <readseg+0x37>
		readsect((uint8*) va, offset);
    7d01:	57                   	push   %edi
    7d02:	53                   	push   %ebx
    7d03:	e8 74 ff ff ff       	call   7c7c <readsect>
		va += SECTSIZE;
    7d08:	81 c3 00 02 00 00    	add    $0x200,%ebx
		offset++;
    7d0e:	47                   	inc    %edi
    7d0f:	58                   	pop    %eax
    7d10:	5a                   	pop    %edx
    7d11:	eb ea                	jmp    7cfd <readseg+0x21>
	}
}
    7d13:	8d 65 f4             	lea    -0xc(%ebp),%esp
    7d16:	5b                   	pop    %ebx
    7d17:	5e                   	pop    %esi
    7d18:	5f                   	pop    %edi
    7d19:	5d                   	pop    %ebp
    7d1a:	c3                   	ret    

00007d1b <cmain>:
void readsect(void*, uint32);
void readseg(uint32, uint32, uint32);

void
cmain(void)
{
    7d1b:	55                   	push   %ebp
    7d1c:	89 e5                	mov    %esp,%ebp
    7d1e:	56                   	push   %esi
    7d1f:	53                   	push   %ebx
	struct Proghdr *ph, *eph;

	// read 1st page off disk
	readseg((uint32) ELFHDR, SECTSIZE*8, 0);
    7d20:	6a 00                	push   $0x0
    7d22:	68 00 10 00 00       	push   $0x1000
    7d27:	68 00 00 01 00       	push   $0x10000
    7d2c:	e8 ab ff ff ff       	call   7cdc <readseg>

	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
    7d31:	83 c4 0c             	add    $0xc,%esp
    7d34:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d3b:	45 4c 46 
    7d3e:	75 3d                	jne    7d7d <cmain+0x62>
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8 *) ELFHDR + ELFHDR->e_phoff);
    7d40:	a1 1c 00 01 00       	mov    0x1001c,%eax
    7d45:	8d 98 00 00 01 00    	lea    0x10000(%eax),%ebx
	eph = ph + ELFHDR->e_phnum;
    7d4b:	0f b7 35 2c 00 01 00 	movzwl 0x1002c,%esi
    7d52:	c1 e6 05             	shl    $0x5,%esi
    7d55:	01 de                	add    %ebx,%esi
	for (; ph < eph; ph++)
    7d57:	39 f3                	cmp    %esi,%ebx
    7d59:	73 16                	jae    7d71 <cmain+0x56>
		readseg(ph->p_va, ph->p_memsz, ph->p_offset);
    7d5b:	ff 73 04             	pushl  0x4(%ebx)
    7d5e:	ff 73 14             	pushl  0x14(%ebx)
    7d61:	ff 73 08             	pushl  0x8(%ebx)
    7d64:	e8 73 ff ff ff       	call   7cdc <readseg>
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8 *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	for (; ph < eph; ph++)
    7d69:	83 c3 20             	add    $0x20,%ebx
    7d6c:	83 c4 0c             	add    $0xc,%esp
    7d6f:	eb e6                	jmp    7d57 <cmain+0x3c>
		readseg(ph->p_va, ph->p_memsz, ph->p_offset);

	// call the entry point from the ELF header
	// note: does not return!
	((void (*)(void)) (ELFHDR->e_entry & 0xFFFFFF))();
    7d71:	a1 18 00 01 00       	mov    0x10018,%eax
    7d76:	25 ff ff ff 00       	and    $0xffffff,%eax
    7d7b:	ff d0                	call   *%eax
}

static __inline void
outw(int port, uint16 data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
    7d7d:	ba 00 8a 00 00       	mov    $0x8a00,%edx
    7d82:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
    7d87:	66 ef                	out    %ax,(%dx)
    7d89:	b8 00 8e ff ff       	mov    $0xffff8e00,%eax
    7d8e:	66 ef                	out    %ax,(%dx)
    7d90:	eb fe                	jmp    7d90 <cmain+0x75>
