
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <start_of_kernel-0xc>:
.long MULTIBOOT_HEADER_FLAGS
.long CHECKSUM

.globl		start_of_kernel
start_of_kernel:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 03 00    	add    0x31bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fb                   	sti    
f0100009:	4f                   	dec    %edi
f010000a:	52                   	push   %edx
f010000b:	e4                   	.byte 0xe4

f010000c <start_of_kernel>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 

	# Establish our own GDT in place of the boot loader's temporary GDT.
	lgdt	RELOC(mygdtdesc)		# load descriptor table
f0100015:	0f 01 15 18 b0 11 00 	lgdtl  0x11b018

	# Immediately reload all segment registers (including CS!)
	# with segment selectors from the new GDT.
	movl	$DATA_SEL, %eax			# Data segment selector
f010001c:	b8 10 00 00 00       	mov    $0x10,%eax
	movw	%ax,%ds				# -> DS: Data Segment
f0100021:	8e d8                	mov    %eax,%ds
	movw	%ax,%es				# -> ES: Extra Segment
f0100023:	8e c0                	mov    %eax,%es
	movw	%ax,%ss				# -> SS: Stack Segment
f0100025:	8e d0                	mov    %eax,%ss
	ljmp	$CODE_SEL,$relocated		# reload CS by jumping
f0100027:	ea 2e 00 10 f0 08 00 	ljmp   $0x8,$0xf010002e

f010002e <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002e:	bd 00 00 00 00       	mov    $0x0,%ebp

        # Leave a few words on the stack for the user trap frame
	movl	$(ptr_stack_top-SIZEOF_STRUCT_TRAPFRAME),%esp
f0100033:	bc bc af 11 f0       	mov    $0xf011afbc,%esp

	# now to C code
	call	FOS_initialize
f0100038:	e8 02 00 00 00       	call   f010003f <FOS_initialize>

f010003d <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003d:	eb fe                	jmp    f010003d <spin>

f010003f <FOS_initialize>:



//First ever function called in FOS kernel
void FOS_initialize()
{
f010003f:	55                   	push   %ebp
f0100040:	89 e5                	mov    %esp,%ebp
f0100042:	83 ec 08             	sub    $0x8,%esp
	extern char start_of_uninitialized_data_section[], end_of_kernel[];

	// Before doing anything else,
	// clear the uninitialized global data (BSS) section of our program, from start_of_uninitialized_data_section to end_of_kernel 
	// This ensures that all static/global variables start with zero value.
	memset(start_of_uninitialized_data_section, 0, end_of_kernel - start_of_uninitialized_data_section);
f0100045:	ba 8c e7 14 f0       	mov    $0xf014e78c,%edx
f010004a:	b8 92 dc 14 f0       	mov    $0xf014dc92,%eax
f010004f:	29 c2                	sub    %eax,%edx
f0100051:	89 d0                	mov    %edx,%eax
f0100053:	83 ec 04             	sub    $0x4,%esp
f0100056:	50                   	push   %eax
f0100057:	6a 00                	push   $0x0
f0100059:	68 92 dc 14 f0       	push   $0xf014dc92
f010005e:	e8 57 46 00 00       	call   f01046ba <memset>
f0100063:	83 c4 10             	add    $0x10,%esp

	// Initialize the console.
	// Can't call cprintf until after we do this!
	console_initialize();
f0100066:	e8 7b 08 00 00       	call   f01008e6 <console_initialize>

	//print welcome message
	print_welcome_message();
f010006b:	e8 45 00 00 00       	call   f01000b5 <print_welcome_message>

	// Lab 2 memory management initialization functions
	detect_memory();
f0100070:	e8 a4 0d 00 00       	call   f0100e19 <detect_memory>
	initialize_kernel_VM();
f0100075:	e8 2a 1c 00 00       	call   f0101ca4 <initialize_kernel_VM>
	initialize_paging();
f010007a:	e8 e9 1f 00 00       	call   f0102068 <initialize_paging>
	page_check();
f010007f:	e8 61 11 00 00       	call   f01011e5 <page_check>

	
	// Lab 3 user environment initialization functions
	env_init();
f0100084:	e8 d6 27 00 00       	call   f010285f <env_init>
	idt_init();
f0100089:	e8 6a 2f 00 00       	call   f0102ff8 <idt_init>

	
	// start the kernel command prompt.
	while (1==1)
	{
		cprintf("\nWelcome to the FOS kernel command prompt!\n");
f010008e:	83 ec 0c             	sub    $0xc,%esp
f0100091:	68 c0 4c 10 f0       	push   $0xf0104cc0
f0100096:	e8 0c 2f 00 00       	call   f0102fa7 <cprintf>
f010009b:	83 c4 10             	add    $0x10,%esp
		cprintf("Type 'help' for a list of commands.\n");	
f010009e:	83 ec 0c             	sub    $0xc,%esp
f01000a1:	68 ec 4c 10 f0       	push   $0xf0104cec
f01000a6:	e8 fc 2e 00 00       	call   f0102fa7 <cprintf>
f01000ab:	83 c4 10             	add    $0x10,%esp
		run_command_prompt();
f01000ae:	e8 9e 08 00 00       	call   f0100951 <run_command_prompt>
	}
f01000b3:	eb d9                	jmp    f010008e <FOS_initialize+0x4f>

f01000b5 <print_welcome_message>:
}


void print_welcome_message()
{
f01000b5:	55                   	push   %ebp
f01000b6:	89 e5                	mov    %esp,%ebp
f01000b8:	83 ec 08             	sub    $0x8,%esp
	cprintf("\n\n\n");
f01000bb:	83 ec 0c             	sub    $0xc,%esp
f01000be:	68 11 4d 10 f0       	push   $0xf0104d11
f01000c3:	e8 df 2e 00 00       	call   f0102fa7 <cprintf>
f01000c8:	83 c4 10             	add    $0x10,%esp
	cprintf("\t\t!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
f01000cb:	83 ec 0c             	sub    $0xc,%esp
f01000ce:	68 18 4d 10 f0       	push   $0xf0104d18
f01000d3:	e8 cf 2e 00 00       	call   f0102fa7 <cprintf>
f01000d8:	83 c4 10             	add    $0x10,%esp
	cprintf("\t\t!!                                                             !!\n");
f01000db:	83 ec 0c             	sub    $0xc,%esp
f01000de:	68 60 4d 10 f0       	push   $0xf0104d60
f01000e3:	e8 bf 2e 00 00       	call   f0102fa7 <cprintf>
f01000e8:	83 c4 10             	add    $0x10,%esp
	cprintf("\t\t!!                   !! FCIS says HELLO !!                     !!\n");
f01000eb:	83 ec 0c             	sub    $0xc,%esp
f01000ee:	68 a8 4d 10 f0       	push   $0xf0104da8
f01000f3:	e8 af 2e 00 00       	call   f0102fa7 <cprintf>
f01000f8:	83 c4 10             	add    $0x10,%esp
	cprintf("\t\t!!                                                             !!\n");
f01000fb:	83 ec 0c             	sub    $0xc,%esp
f01000fe:	68 60 4d 10 f0       	push   $0xf0104d60
f0100103:	e8 9f 2e 00 00       	call   f0102fa7 <cprintf>
f0100108:	83 c4 10             	add    $0x10,%esp
	cprintf("\t\t!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
f010010b:	83 ec 0c             	sub    $0xc,%esp
f010010e:	68 18 4d 10 f0       	push   $0xf0104d18
f0100113:	e8 8f 2e 00 00       	call   f0102fa7 <cprintf>
f0100118:	83 c4 10             	add    $0x10,%esp
	cprintf("\n\n\n\n");	
f010011b:	83 ec 0c             	sub    $0xc,%esp
f010011e:	68 ed 4d 10 f0       	push   $0xf0104ded
f0100123:	e8 7f 2e 00 00       	call   f0102fa7 <cprintf>
f0100128:	83 c4 10             	add    $0x10,%esp
}
f010012b:	90                   	nop
f010012c:	c9                   	leave  
f010012d:	c3                   	ret    

f010012e <_panic>:
/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel command prompt.
 */
void _panic(const char *file, int line, const char *fmt,...)
{
f010012e:	55                   	push   %ebp
f010012f:	89 e5                	mov    %esp,%ebp
f0100131:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	if (panicstr)
f0100134:	a1 a0 dc 14 f0       	mov    0xf014dca0,%eax
f0100139:	85 c0                	test   %eax,%eax
f010013b:	74 02                	je     f010013f <_panic+0x11>
		goto dead;
f010013d:	eb 49                	jmp    f0100188 <_panic+0x5a>
	panicstr = fmt;
f010013f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100142:	a3 a0 dc 14 f0       	mov    %eax,0xf014dca0

	va_start(ap, fmt);
f0100147:	8d 45 10             	lea    0x10(%ebp),%eax
f010014a:	83 c0 04             	add    $0x4,%eax
f010014d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("kernel panic at %s:%d: ", file, line);
f0100150:	83 ec 04             	sub    $0x4,%esp
f0100153:	ff 75 0c             	pushl  0xc(%ebp)
f0100156:	ff 75 08             	pushl  0x8(%ebp)
f0100159:	68 f2 4d 10 f0       	push   $0xf0104df2
f010015e:	e8 44 2e 00 00       	call   f0102fa7 <cprintf>
f0100163:	83 c4 10             	add    $0x10,%esp
	vcprintf(fmt, ap);
f0100166:	8b 45 10             	mov    0x10(%ebp),%eax
f0100169:	83 ec 08             	sub    $0x8,%esp
f010016c:	ff 75 f4             	pushl  -0xc(%ebp)
f010016f:	50                   	push   %eax
f0100170:	e8 09 2e 00 00       	call   f0102f7e <vcprintf>
f0100175:	83 c4 10             	add    $0x10,%esp
	cprintf("\n");
f0100178:	83 ec 0c             	sub    $0xc,%esp
f010017b:	68 0a 4e 10 f0       	push   $0xf0104e0a
f0100180:	e8 22 2e 00 00       	call   f0102fa7 <cprintf>
f0100185:	83 c4 10             	add    $0x10,%esp
	va_end(ap);

dead:
	/* break into the kernel command prompt */
	while (1==1)
		run_command_prompt();
f0100188:	e8 c4 07 00 00       	call   f0100951 <run_command_prompt>
f010018d:	eb f9                	jmp    f0100188 <_panic+0x5a>

f010018f <_warn>:
}

/* like panic, but don't enters the kernel command prompt*/
void _warn(const char *file, int line, const char *fmt,...)
{
f010018f:	55                   	push   %ebp
f0100190:	89 e5                	mov    %esp,%ebp
f0100192:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0100195:	8d 45 10             	lea    0x10(%ebp),%eax
f0100198:	83 c0 04             	add    $0x4,%eax
f010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("kernel warning at %s:%d: ", file, line);
f010019e:	83 ec 04             	sub    $0x4,%esp
f01001a1:	ff 75 0c             	pushl  0xc(%ebp)
f01001a4:	ff 75 08             	pushl  0x8(%ebp)
f01001a7:	68 0c 4e 10 f0       	push   $0xf0104e0c
f01001ac:	e8 f6 2d 00 00       	call   f0102fa7 <cprintf>
f01001b1:	83 c4 10             	add    $0x10,%esp
	vcprintf(fmt, ap);
f01001b4:	8b 45 10             	mov    0x10(%ebp),%eax
f01001b7:	83 ec 08             	sub    $0x8,%esp
f01001ba:	ff 75 f4             	pushl  -0xc(%ebp)
f01001bd:	50                   	push   %eax
f01001be:	e8 bb 2d 00 00       	call   f0102f7e <vcprintf>
f01001c3:	83 c4 10             	add    $0x10,%esp
	cprintf("\n");
f01001c6:	83 ec 0c             	sub    $0xc,%esp
f01001c9:	68 0a 4e 10 f0       	push   $0xf0104e0a
f01001ce:	e8 d4 2d 00 00       	call   f0102fa7 <cprintf>
f01001d3:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
f01001d6:	90                   	nop
f01001d7:	c9                   	leave  
f01001d8:	c3                   	ret    

f01001d9 <serial_proc_data>:

static bool serial_exists;

int
serial_proc_data(void)
{
f01001d9:	55                   	push   %ebp
f01001da:	89 e5                	mov    %esp,%ebp
f01001dc:	83 ec 10             	sub    $0x10,%esp
f01001df:	c7 45 f8 fd 03 00 00 	movl   $0x3fd,-0x8(%ebp)

static __inline uint8
inb(int port)
{
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01001e9:	89 c2                	mov    %eax,%edx
f01001eb:	ec                   	in     (%dx),%al
f01001ec:	88 45 f7             	mov    %al,-0x9(%ebp)
	return data;
f01001ef:	8a 45 f7             	mov    -0x9(%ebp),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001f2:	0f b6 c0             	movzbl %al,%eax
f01001f5:	83 e0 01             	and    $0x1,%eax
f01001f8:	85 c0                	test   %eax,%eax
f01001fa:	75 07                	jne    f0100203 <serial_proc_data+0x2a>
		return -1;
f01001fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100201:	eb 16                	jmp    f0100219 <serial_proc_data+0x40>
f0100203:	c7 45 fc f8 03 00 00 	movl   $0x3f8,-0x4(%ebp)

static __inline uint8
inb(int port)
{
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010020a:	8b 45 fc             	mov    -0x4(%ebp),%eax
f010020d:	89 c2                	mov    %eax,%edx
f010020f:	ec                   	in     (%dx),%al
f0100210:	88 45 f6             	mov    %al,-0xa(%ebp)
	return data;
f0100213:	8a 45 f6             	mov    -0xa(%ebp),%al
	return inb(COM1+COM_RX);
f0100216:	0f b6 c0             	movzbl %al,%eax
}
f0100219:	c9                   	leave  
f010021a:	c3                   	ret    

f010021b <serial_intr>:

void
serial_intr(void)
{
f010021b:	55                   	push   %ebp
f010021c:	89 e5                	mov    %esp,%ebp
f010021e:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100221:	a1 c0 dc 14 f0       	mov    0xf014dcc0,%eax
f0100226:	85 c0                	test   %eax,%eax
f0100228:	74 10                	je     f010023a <serial_intr+0x1f>
		cons_intr(serial_proc_data);
f010022a:	83 ec 0c             	sub    $0xc,%esp
f010022d:	68 d9 01 10 f0       	push   $0xf01001d9
f0100232:	e8 e4 05 00 00       	call   f010081b <cons_intr>
f0100237:	83 c4 10             	add    $0x10,%esp
}
f010023a:	90                   	nop
f010023b:	c9                   	leave  
f010023c:	c3                   	ret    

f010023d <serial_init>:

void
serial_init(void)
{
f010023d:	55                   	push   %ebp
f010023e:	89 e5                	mov    %esp,%ebp
f0100240:	83 ec 40             	sub    $0x40,%esp
f0100243:	c7 45 fc fa 03 00 00 	movl   $0x3fa,-0x4(%ebp)
f010024a:	c6 45 ce 00          	movb   $0x0,-0x32(%ebp)
}

static __inline void
outb(int port, uint8 data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010024e:	8a 45 ce             	mov    -0x32(%ebp),%al
f0100251:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0100254:	ee                   	out    %al,(%dx)
f0100255:	c7 45 f8 fb 03 00 00 	movl   $0x3fb,-0x8(%ebp)
f010025c:	c6 45 cf 80          	movb   $0x80,-0x31(%ebp)
f0100260:	8a 45 cf             	mov    -0x31(%ebp),%al
f0100263:	8b 55 f8             	mov    -0x8(%ebp),%edx
f0100266:	ee                   	out    %al,(%dx)
f0100267:	c7 45 f4 f8 03 00 00 	movl   $0x3f8,-0xc(%ebp)
f010026e:	c6 45 d0 0c          	movb   $0xc,-0x30(%ebp)
f0100272:	8a 45 d0             	mov    -0x30(%ebp),%al
f0100275:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100278:	ee                   	out    %al,(%dx)
f0100279:	c7 45 f0 f9 03 00 00 	movl   $0x3f9,-0x10(%ebp)
f0100280:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
f0100284:	8a 45 d1             	mov    -0x2f(%ebp),%al
f0100287:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010028a:	ee                   	out    %al,(%dx)
f010028b:	c7 45 ec fb 03 00 00 	movl   $0x3fb,-0x14(%ebp)
f0100292:	c6 45 d2 03          	movb   $0x3,-0x2e(%ebp)
f0100296:	8a 45 d2             	mov    -0x2e(%ebp),%al
f0100299:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010029c:	ee                   	out    %al,(%dx)
f010029d:	c7 45 e8 fc 03 00 00 	movl   $0x3fc,-0x18(%ebp)
f01002a4:	c6 45 d3 00          	movb   $0x0,-0x2d(%ebp)
f01002a8:	8a 45 d3             	mov    -0x2d(%ebp),%al
f01002ab:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01002ae:	ee                   	out    %al,(%dx)
f01002af:	c7 45 e4 f9 03 00 00 	movl   $0x3f9,-0x1c(%ebp)
f01002b6:	c6 45 d4 01          	movb   $0x1,-0x2c(%ebp)
f01002ba:	8a 45 d4             	mov    -0x2c(%ebp),%al
f01002bd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01002c0:	ee                   	out    %al,(%dx)
f01002c1:	c7 45 e0 fd 03 00 00 	movl   $0x3fd,-0x20(%ebp)

static __inline uint8
inb(int port)
{
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01002cb:	89 c2                	mov    %eax,%edx
f01002cd:	ec                   	in     (%dx),%al
f01002ce:	88 45 d5             	mov    %al,-0x2b(%ebp)
	return data;
f01002d1:	8a 45 d5             	mov    -0x2b(%ebp),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01002d4:	3c ff                	cmp    $0xff,%al
f01002d6:	0f 95 c0             	setne  %al
f01002d9:	0f b6 c0             	movzbl %al,%eax
f01002dc:	a3 c0 dc 14 f0       	mov    %eax,0xf014dcc0
f01002e1:	c7 45 dc fa 03 00 00 	movl   $0x3fa,-0x24(%ebp)

static __inline uint8
inb(int port)
{
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01002eb:	89 c2                	mov    %eax,%edx
f01002ed:	ec                   	in     (%dx),%al
f01002ee:	88 45 d6             	mov    %al,-0x2a(%ebp)
f01002f1:	c7 45 d8 f8 03 00 00 	movl   $0x3f8,-0x28(%ebp)
f01002f8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01002fb:	89 c2                	mov    %eax,%edx
f01002fd:	ec                   	in     (%dx),%al
f01002fe:	88 45 d7             	mov    %al,-0x29(%ebp)
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
f0100301:	90                   	nop
f0100302:	c9                   	leave  
f0100303:	c3                   	ret    

f0100304 <delay>:
// page.

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100304:	55                   	push   %ebp
f0100305:	89 e5                	mov    %esp,%ebp
f0100307:	83 ec 20             	sub    $0x20,%esp
f010030a:	c7 45 fc 84 00 00 00 	movl   $0x84,-0x4(%ebp)
f0100311:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0100314:	89 c2                	mov    %eax,%edx
f0100316:	ec                   	in     (%dx),%al
f0100317:	88 45 ec             	mov    %al,-0x14(%ebp)
f010031a:	c7 45 f8 84 00 00 00 	movl   $0x84,-0x8(%ebp)
f0100321:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0100324:	89 c2                	mov    %eax,%edx
f0100326:	ec                   	in     (%dx),%al
f0100327:	88 45 ed             	mov    %al,-0x13(%ebp)
f010032a:	c7 45 f4 84 00 00 00 	movl   $0x84,-0xc(%ebp)
f0100331:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100334:	89 c2                	mov    %eax,%edx
f0100336:	ec                   	in     (%dx),%al
f0100337:	88 45 ee             	mov    %al,-0x12(%ebp)
f010033a:	c7 45 f0 84 00 00 00 	movl   $0x84,-0x10(%ebp)
f0100341:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100344:	89 c2                	mov    %eax,%edx
f0100346:	ec                   	in     (%dx),%al
f0100347:	88 45 ef             	mov    %al,-0x11(%ebp)
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010034a:	90                   	nop
f010034b:	c9                   	leave  
f010034c:	c3                   	ret    

f010034d <lpt_putc>:

static void
lpt_putc(int c)
{
f010034d:	55                   	push   %ebp
f010034e:	89 e5                	mov    %esp,%ebp
f0100350:	83 ec 20             	sub    $0x20,%esp
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 2800; i++) //12800
f0100353:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f010035a:	eb 08                	jmp    f0100364 <lpt_putc+0x17>
		delay();
f010035c:	e8 a3 ff ff ff       	call   f0100304 <delay>
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 2800; i++) //12800
f0100361:	ff 45 fc             	incl   -0x4(%ebp)
f0100364:	c7 45 ec 79 03 00 00 	movl   $0x379,-0x14(%ebp)
f010036b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010036e:	89 c2                	mov    %eax,%edx
f0100370:	ec                   	in     (%dx),%al
f0100371:	88 45 eb             	mov    %al,-0x15(%ebp)
	return data;
f0100374:	8a 45 eb             	mov    -0x15(%ebp),%al
f0100377:	84 c0                	test   %al,%al
f0100379:	78 09                	js     f0100384 <lpt_putc+0x37>
f010037b:	81 7d fc ef 0a 00 00 	cmpl   $0xaef,-0x4(%ebp)
f0100382:	7e d8                	jle    f010035c <lpt_putc+0xf>
		delay();
	outb(0x378+0, c);
f0100384:	8b 45 08             	mov    0x8(%ebp),%eax
f0100387:	0f b6 c0             	movzbl %al,%eax
f010038a:	c7 45 f4 78 03 00 00 	movl   $0x378,-0xc(%ebp)
f0100391:	88 45 e8             	mov    %al,-0x18(%ebp)
}

static __inline void
outb(int port, uint8 data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100394:	8a 45 e8             	mov    -0x18(%ebp),%al
f0100397:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010039a:	ee                   	out    %al,(%dx)
f010039b:	c7 45 f0 7a 03 00 00 	movl   $0x37a,-0x10(%ebp)
f01003a2:	c6 45 e9 0d          	movb   $0xd,-0x17(%ebp)
f01003a6:	8a 45 e9             	mov    -0x17(%ebp),%al
f01003a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01003ac:	ee                   	out    %al,(%dx)
f01003ad:	c7 45 f8 7a 03 00 00 	movl   $0x37a,-0x8(%ebp)
f01003b4:	c6 45 ea 08          	movb   $0x8,-0x16(%ebp)
f01003b8:	8a 45 ea             	mov    -0x16(%ebp),%al
f01003bb:	8b 55 f8             	mov    -0x8(%ebp),%edx
f01003be:	ee                   	out    %al,(%dx)
	outb(0x378+2, 0x08|0x04|0x01);
	outb(0x378+2, 0x08);
}
f01003bf:	90                   	nop
f01003c0:	c9                   	leave  
f01003c1:	c3                   	ret    

f01003c2 <cga_init>:
static uint16 *crt_buf;
static uint16 crt_pos;

void
cga_init(void)
{
f01003c2:	55                   	push   %ebp
f01003c3:	89 e5                	mov    %esp,%ebp
f01003c5:	83 ec 20             	sub    $0x20,%esp
	volatile uint16 *cp;
	uint16 was;
	unsigned pos;

	cp = (uint16*) (KERNEL_BASE + CGA_BUF);
f01003c8:	c7 45 fc 00 80 0b f0 	movl   $0xf00b8000,-0x4(%ebp)
	was = *cp;
f01003cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01003d2:	66 8b 00             	mov    (%eax),%ax
f01003d5:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
	*cp = (uint16) 0xA55A;
f01003d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01003dc:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f01003e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01003e4:	66 8b 00             	mov    (%eax),%ax
f01003e7:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01003eb:	74 13                	je     f0100400 <cga_init+0x3e>
		cp = (uint16*) (KERNEL_BASE + MONO_BUF);
f01003ed:	c7 45 fc 00 00 0b f0 	movl   $0xf00b0000,-0x4(%ebp)
		addr_6845 = MONO_BASE;
f01003f4:	c7 05 c4 dc 14 f0 b4 	movl   $0x3b4,0xf014dcc4
f01003fb:	03 00 00 
f01003fe:	eb 14                	jmp    f0100414 <cga_init+0x52>
	} else {
		*cp = was;
f0100400:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0100403:	66 8b 45 fa          	mov    -0x6(%ebp),%ax
f0100407:	66 89 02             	mov    %ax,(%edx)
		addr_6845 = CGA_BASE;
f010040a:	c7 05 c4 dc 14 f0 d4 	movl   $0x3d4,0xf014dcc4
f0100411:	03 00 00 
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f0100414:	a1 c4 dc 14 f0       	mov    0xf014dcc4,%eax
f0100419:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010041c:	c6 45 e0 0e          	movb   $0xe,-0x20(%ebp)
f0100420:	8a 45 e0             	mov    -0x20(%ebp),%al
f0100423:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100426:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100427:	a1 c4 dc 14 f0       	mov    0xf014dcc4,%eax
f010042c:	40                   	inc    %eax
f010042d:	89 45 ec             	mov    %eax,-0x14(%ebp)

static __inline uint8
inb(int port)
{
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100430:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100433:	89 c2                	mov    %eax,%edx
f0100435:	ec                   	in     (%dx),%al
f0100436:	88 45 e1             	mov    %al,-0x1f(%ebp)
	return data;
f0100439:	8a 45 e1             	mov    -0x1f(%ebp),%al
f010043c:	0f b6 c0             	movzbl %al,%eax
f010043f:	c1 e0 08             	shl    $0x8,%eax
f0100442:	89 45 f0             	mov    %eax,-0x10(%ebp)
	outb(addr_6845, 15);
f0100445:	a1 c4 dc 14 f0       	mov    0xf014dcc4,%eax
f010044a:	89 45 e8             	mov    %eax,-0x18(%ebp)
f010044d:	c6 45 e2 0f          	movb   $0xf,-0x1e(%ebp)
}

static __inline void
outb(int port, uint8 data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100451:	8a 45 e2             	mov    -0x1e(%ebp),%al
f0100454:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100457:	ee                   	out    %al,(%dx)
	pos |= inb(addr_6845 + 1);
f0100458:	a1 c4 dc 14 f0       	mov    0xf014dcc4,%eax
f010045d:	40                   	inc    %eax
f010045e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

static __inline uint8
inb(int port)
{
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100461:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100464:	89 c2                	mov    %eax,%edx
f0100466:	ec                   	in     (%dx),%al
f0100467:	88 45 e3             	mov    %al,-0x1d(%ebp)
	return data;
f010046a:	8a 45 e3             	mov    -0x1d(%ebp),%al
f010046d:	0f b6 c0             	movzbl %al,%eax
f0100470:	09 45 f0             	or     %eax,-0x10(%ebp)

	crt_buf = (uint16*) cp;
f0100473:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0100476:	a3 c8 dc 14 f0       	mov    %eax,0xf014dcc8
	crt_pos = pos;
f010047b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010047e:	66 a3 cc dc 14 f0    	mov    %ax,0xf014dccc
}
f0100484:	90                   	nop
f0100485:	c9                   	leave  
f0100486:	c3                   	ret    

f0100487 <cga_putc>:



void
cga_putc(int c)
{
f0100487:	55                   	push   %ebp
f0100488:	89 e5                	mov    %esp,%ebp
f010048a:	53                   	push   %ebx
f010048b:	83 ec 24             	sub    $0x24,%esp
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010048e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100491:	b0 00                	mov    $0x0,%al
f0100493:	85 c0                	test   %eax,%eax
f0100495:	75 07                	jne    f010049e <cga_putc+0x17>
		c |= 0x0700;
f0100497:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)

	switch (c & 0xff) {
f010049e:	8b 45 08             	mov    0x8(%ebp),%eax
f01004a1:	0f b6 c0             	movzbl %al,%eax
f01004a4:	83 f8 09             	cmp    $0x9,%eax
f01004a7:	0f 84 94 00 00 00    	je     f0100541 <cga_putc+0xba>
f01004ad:	83 f8 09             	cmp    $0x9,%eax
f01004b0:	7f 0a                	jg     f01004bc <cga_putc+0x35>
f01004b2:	83 f8 08             	cmp    $0x8,%eax
f01004b5:	74 14                	je     f01004cb <cga_putc+0x44>
f01004b7:	e9 c8 00 00 00       	jmp    f0100584 <cga_putc+0xfd>
f01004bc:	83 f8 0a             	cmp    $0xa,%eax
f01004bf:	74 49                	je     f010050a <cga_putc+0x83>
f01004c1:	83 f8 0d             	cmp    $0xd,%eax
f01004c4:	74 53                	je     f0100519 <cga_putc+0x92>
f01004c6:	e9 b9 00 00 00       	jmp    f0100584 <cga_putc+0xfd>
	case '\b':
		if (crt_pos > 0) {
f01004cb:	66 a1 cc dc 14 f0    	mov    0xf014dccc,%ax
f01004d1:	66 85 c0             	test   %ax,%ax
f01004d4:	0f 84 d0 00 00 00    	je     f01005aa <cga_putc+0x123>
			crt_pos--;
f01004da:	66 a1 cc dc 14 f0    	mov    0xf014dccc,%ax
f01004e0:	48                   	dec    %eax
f01004e1:	66 a3 cc dc 14 f0    	mov    %ax,0xf014dccc
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004e7:	8b 15 c8 dc 14 f0    	mov    0xf014dcc8,%edx
f01004ed:	66 a1 cc dc 14 f0    	mov    0xf014dccc,%ax
f01004f3:	0f b7 c0             	movzwl %ax,%eax
f01004f6:	01 c0                	add    %eax,%eax
f01004f8:	01 c2                	add    %eax,%edx
f01004fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01004fd:	b0 00                	mov    $0x0,%al
f01004ff:	83 c8 20             	or     $0x20,%eax
f0100502:	66 89 02             	mov    %ax,(%edx)
		}
		break;
f0100505:	e9 a0 00 00 00       	jmp    f01005aa <cga_putc+0x123>
	case '\n':
		crt_pos += CRT_COLS;
f010050a:	66 a1 cc dc 14 f0    	mov    0xf014dccc,%ax
f0100510:	83 c0 50             	add    $0x50,%eax
f0100513:	66 a3 cc dc 14 f0    	mov    %ax,0xf014dccc
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100519:	66 8b 0d cc dc 14 f0 	mov    0xf014dccc,%cx
f0100520:	66 a1 cc dc 14 f0    	mov    0xf014dccc,%ax
f0100526:	bb 50 00 00 00       	mov    $0x50,%ebx
f010052b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100530:	66 f7 f3             	div    %bx
f0100533:	89 d0                	mov    %edx,%eax
f0100535:	29 c1                	sub    %eax,%ecx
f0100537:	89 c8                	mov    %ecx,%eax
f0100539:	66 a3 cc dc 14 f0    	mov    %ax,0xf014dccc
		break;
f010053f:	eb 6a                	jmp    f01005ab <cga_putc+0x124>
	case '\t':
		cons_putc(' ');
f0100541:	83 ec 0c             	sub    $0xc,%esp
f0100544:	6a 20                	push   $0x20
f0100546:	e8 79 03 00 00       	call   f01008c4 <cons_putc>
f010054b:	83 c4 10             	add    $0x10,%esp
		cons_putc(' ');
f010054e:	83 ec 0c             	sub    $0xc,%esp
f0100551:	6a 20                	push   $0x20
f0100553:	e8 6c 03 00 00       	call   f01008c4 <cons_putc>
f0100558:	83 c4 10             	add    $0x10,%esp
		cons_putc(' ');
f010055b:	83 ec 0c             	sub    $0xc,%esp
f010055e:	6a 20                	push   $0x20
f0100560:	e8 5f 03 00 00       	call   f01008c4 <cons_putc>
f0100565:	83 c4 10             	add    $0x10,%esp
		cons_putc(' ');
f0100568:	83 ec 0c             	sub    $0xc,%esp
f010056b:	6a 20                	push   $0x20
f010056d:	e8 52 03 00 00       	call   f01008c4 <cons_putc>
f0100572:	83 c4 10             	add    $0x10,%esp
		cons_putc(' ');
f0100575:	83 ec 0c             	sub    $0xc,%esp
f0100578:	6a 20                	push   $0x20
f010057a:	e8 45 03 00 00       	call   f01008c4 <cons_putc>
f010057f:	83 c4 10             	add    $0x10,%esp
		break;
f0100582:	eb 27                	jmp    f01005ab <cga_putc+0x124>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100584:	8b 0d c8 dc 14 f0    	mov    0xf014dcc8,%ecx
f010058a:	66 a1 cc dc 14 f0    	mov    0xf014dccc,%ax
f0100590:	8d 50 01             	lea    0x1(%eax),%edx
f0100593:	66 89 15 cc dc 14 f0 	mov    %dx,0xf014dccc
f010059a:	0f b7 c0             	movzwl %ax,%eax
f010059d:	01 c0                	add    %eax,%eax
f010059f:	8d 14 01             	lea    (%ecx,%eax,1),%edx
f01005a2:	8b 45 08             	mov    0x8(%ebp),%eax
f01005a5:	66 89 02             	mov    %ax,(%edx)
		break;
f01005a8:	eb 01                	jmp    f01005ab <cga_putc+0x124>
	case '\b':
		if (crt_pos > 0) {
			crt_pos--;
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
		}
		break;
f01005aa:	90                   	nop
		crt_buf[crt_pos++] = c;		/* write the character */
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01005ab:	66 a1 cc dc 14 f0    	mov    0xf014dccc,%ax
f01005b1:	66 3d cf 07          	cmp    $0x7cf,%ax
f01005b5:	76 58                	jbe    f010060f <cga_putc+0x188>
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16));
f01005b7:	a1 c8 dc 14 f0       	mov    0xf014dcc8,%eax
f01005bc:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005c2:	a1 c8 dc 14 f0       	mov    0xf014dcc8,%eax
f01005c7:	83 ec 04             	sub    $0x4,%esp
f01005ca:	68 00 0f 00 00       	push   $0xf00
f01005cf:	52                   	push   %edx
f01005d0:	50                   	push   %eax
f01005d1:	e8 14 41 00 00       	call   f01046ea <memcpy>
f01005d6:	83 c4 10             	add    $0x10,%esp
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005d9:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
f01005e0:	eb 15                	jmp    f01005f7 <cga_putc+0x170>
			crt_buf[i] = 0x0700 | ' ';
f01005e2:	8b 15 c8 dc 14 f0    	mov    0xf014dcc8,%edx
f01005e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01005eb:	01 c0                	add    %eax,%eax
f01005ed:	01 d0                	add    %edx,%eax
f01005ef:	66 c7 00 20 07       	movw   $0x720,(%eax)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005f4:	ff 45 f4             	incl   -0xc(%ebp)
f01005f7:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
f01005fe:	7e e2                	jle    f01005e2 <cga_putc+0x15b>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100600:	66 a1 cc dc 14 f0    	mov    0xf014dccc,%ax
f0100606:	83 e8 50             	sub    $0x50,%eax
f0100609:	66 a3 cc dc 14 f0    	mov    %ax,0xf014dccc
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010060f:	a1 c4 dc 14 f0       	mov    0xf014dcc4,%eax
f0100614:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100617:	c6 45 e0 0e          	movb   $0xe,-0x20(%ebp)
}

static __inline void
outb(int port, uint8 data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010061b:	8a 45 e0             	mov    -0x20(%ebp),%al
f010061e:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100621:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100622:	66 a1 cc dc 14 f0    	mov    0xf014dccc,%ax
f0100628:	66 c1 e8 08          	shr    $0x8,%ax
f010062c:	0f b6 c0             	movzbl %al,%eax
f010062f:	8b 15 c4 dc 14 f0    	mov    0xf014dcc4,%edx
f0100635:	42                   	inc    %edx
f0100636:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0100639:	88 45 e1             	mov    %al,-0x1f(%ebp)
f010063c:	8a 45 e1             	mov    -0x1f(%ebp),%al
f010063f:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0100642:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
f0100643:	a1 c4 dc 14 f0       	mov    0xf014dcc4,%eax
f0100648:	89 45 e8             	mov    %eax,-0x18(%ebp)
f010064b:	c6 45 e2 0f          	movb   $0xf,-0x1e(%ebp)
f010064f:	8a 45 e2             	mov    -0x1e(%ebp),%al
f0100652:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100655:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos);
f0100656:	66 a1 cc dc 14 f0    	mov    0xf014dccc,%ax
f010065c:	0f b6 c0             	movzbl %al,%eax
f010065f:	8b 15 c4 dc 14 f0    	mov    0xf014dcc4,%edx
f0100665:	42                   	inc    %edx
f0100666:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100669:	88 45 e3             	mov    %al,-0x1d(%ebp)
f010066c:	8a 45 e3             	mov    -0x1d(%ebp),%al
f010066f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100672:	ee                   	out    %al,(%dx)
}
f0100673:	90                   	nop
f0100674:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100677:	c9                   	leave  
f0100678:	c3                   	ret    

f0100679 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100679:	55                   	push   %ebp
f010067a:	89 e5                	mov    %esp,%ebp
f010067c:	83 ec 28             	sub    $0x28,%esp
f010067f:	c7 45 e4 64 00 00 00 	movl   $0x64,-0x1c(%ebp)

static __inline uint8
inb(int port)
{
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100686:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100689:	89 c2                	mov    %eax,%edx
f010068b:	ec                   	in     (%dx),%al
f010068c:	88 45 e3             	mov    %al,-0x1d(%ebp)
	return data;
f010068f:	8a 45 e3             	mov    -0x1d(%ebp),%al
	int c;
	uint8 data;
	static uint32 shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100692:	0f b6 c0             	movzbl %al,%eax
f0100695:	83 e0 01             	and    $0x1,%eax
f0100698:	85 c0                	test   %eax,%eax
f010069a:	75 0a                	jne    f01006a6 <kbd_proc_data+0x2d>
		return -1;
f010069c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01006a1:	e9 54 01 00 00       	jmp    f01007fa <kbd_proc_data+0x181>
f01006a6:	c7 45 ec 60 00 00 00 	movl   $0x60,-0x14(%ebp)

static __inline uint8
inb(int port)
{
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01006b0:	89 c2                	mov    %eax,%edx
f01006b2:	ec                   	in     (%dx),%al
f01006b3:	88 45 e2             	mov    %al,-0x1e(%ebp)
	return data;
f01006b6:	8a 45 e2             	mov    -0x1e(%ebp),%al

	data = inb(KBDATAP);
f01006b9:	88 45 f3             	mov    %al,-0xd(%ebp)

	if (data == 0xE0) {
f01006bc:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
f01006c0:	75 17                	jne    f01006d9 <kbd_proc_data+0x60>
		// E0 escape character
		shift |= E0ESC;
f01006c2:	a1 e8 de 14 f0       	mov    0xf014dee8,%eax
f01006c7:	83 c8 40             	or     $0x40,%eax
f01006ca:	a3 e8 de 14 f0       	mov    %eax,0xf014dee8
		return 0;
f01006cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01006d4:	e9 21 01 00 00       	jmp    f01007fa <kbd_proc_data+0x181>
	} else if (data & 0x80) {
f01006d9:	8a 45 f3             	mov    -0xd(%ebp),%al
f01006dc:	84 c0                	test   %al,%al
f01006de:	79 44                	jns    f0100724 <kbd_proc_data+0xab>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01006e0:	a1 e8 de 14 f0       	mov    0xf014dee8,%eax
f01006e5:	83 e0 40             	and    $0x40,%eax
f01006e8:	85 c0                	test   %eax,%eax
f01006ea:	75 08                	jne    f01006f4 <kbd_proc_data+0x7b>
f01006ec:	8a 45 f3             	mov    -0xd(%ebp),%al
f01006ef:	83 e0 7f             	and    $0x7f,%eax
f01006f2:	eb 03                	jmp    f01006f7 <kbd_proc_data+0x7e>
f01006f4:	8a 45 f3             	mov    -0xd(%ebp),%al
f01006f7:	88 45 f3             	mov    %al,-0xd(%ebp)
		shift &= ~(shiftcode[data] | E0ESC);
f01006fa:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f01006fe:	8a 80 20 b0 11 f0    	mov    -0xfee4fe0(%eax),%al
f0100704:	83 c8 40             	or     $0x40,%eax
f0100707:	0f b6 c0             	movzbl %al,%eax
f010070a:	f7 d0                	not    %eax
f010070c:	89 c2                	mov    %eax,%edx
f010070e:	a1 e8 de 14 f0       	mov    0xf014dee8,%eax
f0100713:	21 d0                	and    %edx,%eax
f0100715:	a3 e8 de 14 f0       	mov    %eax,0xf014dee8
		return 0;
f010071a:	b8 00 00 00 00       	mov    $0x0,%eax
f010071f:	e9 d6 00 00 00       	jmp    f01007fa <kbd_proc_data+0x181>
	} else if (shift & E0ESC) {
f0100724:	a1 e8 de 14 f0       	mov    0xf014dee8,%eax
f0100729:	83 e0 40             	and    $0x40,%eax
f010072c:	85 c0                	test   %eax,%eax
f010072e:	74 11                	je     f0100741 <kbd_proc_data+0xc8>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100730:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
		shift &= ~E0ESC;
f0100734:	a1 e8 de 14 f0       	mov    0xf014dee8,%eax
f0100739:	83 e0 bf             	and    $0xffffffbf,%eax
f010073c:	a3 e8 de 14 f0       	mov    %eax,0xf014dee8
	}

	shift |= shiftcode[data];
f0100741:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0100745:	8a 80 20 b0 11 f0    	mov    -0xfee4fe0(%eax),%al
f010074b:	0f b6 d0             	movzbl %al,%edx
f010074e:	a1 e8 de 14 f0       	mov    0xf014dee8,%eax
f0100753:	09 d0                	or     %edx,%eax
f0100755:	a3 e8 de 14 f0       	mov    %eax,0xf014dee8
	shift ^= togglecode[data];
f010075a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f010075e:	8a 80 20 b1 11 f0    	mov    -0xfee4ee0(%eax),%al
f0100764:	0f b6 d0             	movzbl %al,%edx
f0100767:	a1 e8 de 14 f0       	mov    0xf014dee8,%eax
f010076c:	31 d0                	xor    %edx,%eax
f010076e:	a3 e8 de 14 f0       	mov    %eax,0xf014dee8

	c = charcode[shift & (CTL | SHIFT)][data];
f0100773:	a1 e8 de 14 f0       	mov    0xf014dee8,%eax
f0100778:	83 e0 03             	and    $0x3,%eax
f010077b:	8b 14 85 20 b5 11 f0 	mov    -0xfee4ae0(,%eax,4),%edx
f0100782:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0100786:	01 d0                	add    %edx,%eax
f0100788:	8a 00                	mov    (%eax),%al
f010078a:	0f b6 c0             	movzbl %al,%eax
f010078d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (shift & CAPSLOCK) {
f0100790:	a1 e8 de 14 f0       	mov    0xf014dee8,%eax
f0100795:	83 e0 08             	and    $0x8,%eax
f0100798:	85 c0                	test   %eax,%eax
f010079a:	74 22                	je     f01007be <kbd_proc_data+0x145>
		if ('a' <= c && c <= 'z')
f010079c:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
f01007a0:	7e 0c                	jle    f01007ae <kbd_proc_data+0x135>
f01007a2:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
f01007a6:	7f 06                	jg     f01007ae <kbd_proc_data+0x135>
			c += 'A' - 'a';
f01007a8:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
f01007ac:	eb 10                	jmp    f01007be <kbd_proc_data+0x145>
		else if ('A' <= c && c <= 'Z')
f01007ae:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
f01007b2:	7e 0a                	jle    f01007be <kbd_proc_data+0x145>
f01007b4:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
f01007b8:	7f 04                	jg     f01007be <kbd_proc_data+0x145>
			c += 'a' - 'A';
f01007ba:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01007be:	a1 e8 de 14 f0       	mov    0xf014dee8,%eax
f01007c3:	f7 d0                	not    %eax
f01007c5:	83 e0 06             	and    $0x6,%eax
f01007c8:	85 c0                	test   %eax,%eax
f01007ca:	75 2b                	jne    f01007f7 <kbd_proc_data+0x17e>
f01007cc:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
f01007d3:	75 22                	jne    f01007f7 <kbd_proc_data+0x17e>
		cprintf("Rebooting!\n");
f01007d5:	83 ec 0c             	sub    $0xc,%esp
f01007d8:	68 26 4e 10 f0       	push   $0xf0104e26
f01007dd:	e8 c5 27 00 00       	call   f0102fa7 <cprintf>
f01007e2:	83 c4 10             	add    $0x10,%esp
f01007e5:	c7 45 e8 92 00 00 00 	movl   $0x92,-0x18(%ebp)
f01007ec:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
}

static __inline void
outb(int port, uint8 data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01007f0:	8a 45 e1             	mov    -0x1f(%ebp),%al
f01007f3:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01007f6:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01007f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f01007fa:	c9                   	leave  
f01007fb:	c3                   	ret    

f01007fc <kbd_intr>:

void
kbd_intr(void)
{
f01007fc:	55                   	push   %ebp
f01007fd:	89 e5                	mov    %esp,%ebp
f01007ff:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100802:	83 ec 0c             	sub    $0xc,%esp
f0100805:	68 79 06 10 f0       	push   $0xf0100679
f010080a:	e8 0c 00 00 00       	call   f010081b <cons_intr>
f010080f:	83 c4 10             	add    $0x10,%esp
}
f0100812:	90                   	nop
f0100813:	c9                   	leave  
f0100814:	c3                   	ret    

f0100815 <kbd_init>:

void
kbd_init(void)
{
f0100815:	55                   	push   %ebp
f0100816:	89 e5                	mov    %esp,%ebp
}
f0100818:	90                   	nop
f0100819:	5d                   	pop    %ebp
f010081a:	c3                   	ret    

f010081b <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
f010081b:	55                   	push   %ebp
f010081c:	89 e5                	mov    %esp,%ebp
f010081e:	83 ec 18             	sub    $0x18,%esp
	int c;

	while ((c = (*proc)()) != -1) {
f0100821:	eb 35                	jmp    f0100858 <cons_intr+0x3d>
		if (c == 0)
f0100823:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0100827:	75 02                	jne    f010082b <cons_intr+0x10>
			continue;
f0100829:	eb 2d                	jmp    f0100858 <cons_intr+0x3d>
		cons.buf[cons.wpos++] = c;
f010082b:	a1 e4 de 14 f0       	mov    0xf014dee4,%eax
f0100830:	8d 50 01             	lea    0x1(%eax),%edx
f0100833:	89 15 e4 de 14 f0    	mov    %edx,0xf014dee4
f0100839:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010083c:	88 90 e0 dc 14 f0    	mov    %dl,-0xfeb2320(%eax)
		if (cons.wpos == CONSBUFSIZE)
f0100842:	a1 e4 de 14 f0       	mov    0xf014dee4,%eax
f0100847:	3d 00 02 00 00       	cmp    $0x200,%eax
f010084c:	75 0a                	jne    f0100858 <cons_intr+0x3d>
			cons.wpos = 0;
f010084e:	c7 05 e4 de 14 f0 00 	movl   $0x0,0xf014dee4
f0100855:	00 00 00 
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100858:	8b 45 08             	mov    0x8(%ebp),%eax
f010085b:	ff d0                	call   *%eax
f010085d:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0100860:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
f0100864:	75 bd                	jne    f0100823 <cons_intr+0x8>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100866:	90                   	nop
f0100867:	c9                   	leave  
f0100868:	c3                   	ret    

f0100869 <cons_getc>:

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100869:	55                   	push   %ebp
f010086a:	89 e5                	mov    %esp,%ebp
f010086c:	83 ec 18             	sub    $0x18,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010086f:	e8 a7 f9 ff ff       	call   f010021b <serial_intr>
	kbd_intr();
f0100874:	e8 83 ff ff ff       	call   f01007fc <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100879:	8b 15 e0 de 14 f0    	mov    0xf014dee0,%edx
f010087f:	a1 e4 de 14 f0       	mov    0xf014dee4,%eax
f0100884:	39 c2                	cmp    %eax,%edx
f0100886:	74 35                	je     f01008bd <cons_getc+0x54>
		c = cons.buf[cons.rpos++];
f0100888:	a1 e0 de 14 f0       	mov    0xf014dee0,%eax
f010088d:	8d 50 01             	lea    0x1(%eax),%edx
f0100890:	89 15 e0 de 14 f0    	mov    %edx,0xf014dee0
f0100896:	8a 80 e0 dc 14 f0    	mov    -0xfeb2320(%eax),%al
f010089c:	0f b6 c0             	movzbl %al,%eax
f010089f:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if (cons.rpos == CONSBUFSIZE)
f01008a2:	a1 e0 de 14 f0       	mov    0xf014dee0,%eax
f01008a7:	3d 00 02 00 00       	cmp    $0x200,%eax
f01008ac:	75 0a                	jne    f01008b8 <cons_getc+0x4f>
			cons.rpos = 0;
f01008ae:	c7 05 e0 de 14 f0 00 	movl   $0x0,0xf014dee0
f01008b5:	00 00 00 
		return c;
f01008b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01008bb:	eb 05                	jmp    f01008c2 <cons_getc+0x59>
	}
	return 0;
f01008bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01008c2:	c9                   	leave  
f01008c3:	c3                   	ret    

f01008c4 <cons_putc>:

// output a character to the console
void
cons_putc(int c)
{
f01008c4:	55                   	push   %ebp
f01008c5:	89 e5                	mov    %esp,%ebp
f01008c7:	83 ec 08             	sub    $0x8,%esp
	lpt_putc(c);
f01008ca:	ff 75 08             	pushl  0x8(%ebp)
f01008cd:	e8 7b fa ff ff       	call   f010034d <lpt_putc>
f01008d2:	83 c4 04             	add    $0x4,%esp
	cga_putc(c);
f01008d5:	83 ec 0c             	sub    $0xc,%esp
f01008d8:	ff 75 08             	pushl  0x8(%ebp)
f01008db:	e8 a7 fb ff ff       	call   f0100487 <cga_putc>
f01008e0:	83 c4 10             	add    $0x10,%esp
}
f01008e3:	90                   	nop
f01008e4:	c9                   	leave  
f01008e5:	c3                   	ret    

f01008e6 <console_initialize>:

// initialize the console devices
void
console_initialize(void)
{
f01008e6:	55                   	push   %ebp
f01008e7:	89 e5                	mov    %esp,%ebp
f01008e9:	83 ec 08             	sub    $0x8,%esp
	cga_init();
f01008ec:	e8 d1 fa ff ff       	call   f01003c2 <cga_init>
	kbd_init();
f01008f1:	e8 1f ff ff ff       	call   f0100815 <kbd_init>
	serial_init();
f01008f6:	e8 42 f9 ff ff       	call   f010023d <serial_init>

	if (!serial_exists)
f01008fb:	a1 c0 dc 14 f0       	mov    0xf014dcc0,%eax
f0100900:	85 c0                	test   %eax,%eax
f0100902:	75 10                	jne    f0100914 <console_initialize+0x2e>
		cprintf("Serial port does not exist!\n");
f0100904:	83 ec 0c             	sub    $0xc,%esp
f0100907:	68 32 4e 10 f0       	push   $0xf0104e32
f010090c:	e8 96 26 00 00       	call   f0102fa7 <cprintf>
f0100911:	83 c4 10             	add    $0x10,%esp
}
f0100914:	90                   	nop
f0100915:	c9                   	leave  
f0100916:	c3                   	ret    

f0100917 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100917:	55                   	push   %ebp
f0100918:	89 e5                	mov    %esp,%ebp
f010091a:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010091d:	83 ec 0c             	sub    $0xc,%esp
f0100920:	ff 75 08             	pushl  0x8(%ebp)
f0100923:	e8 9c ff ff ff       	call   f01008c4 <cons_putc>
f0100928:	83 c4 10             	add    $0x10,%esp
}
f010092b:	90                   	nop
f010092c:	c9                   	leave  
f010092d:	c3                   	ret    

f010092e <getchar>:

int
getchar(void)
{
f010092e:	55                   	push   %ebp
f010092f:	89 e5                	mov    %esp,%ebp
f0100931:	83 ec 18             	sub    $0x18,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100934:	e8 30 ff ff ff       	call   f0100869 <cons_getc>
f0100939:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010093c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0100940:	74 f2                	je     f0100934 <getchar+0x6>
		/* do nothing */;
	return c;
f0100942:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0100945:	c9                   	leave  
f0100946:	c3                   	ret    

f0100947 <iscons>:

int
iscons(int fdnum)
{
f0100947:	55                   	push   %ebp
f0100948:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
f010094a:	b8 01 00 00 00       	mov    $0x1,%eax
}
f010094f:	5d                   	pop    %ebp
f0100950:	c3                   	ret    

f0100951 <run_command_prompt>:
#define NUM_OF_COMMANDS (sizeof(commands)/sizeof(commands[0]))


//invoke the command prompt
void run_command_prompt()
{
f0100951:	55                   	push   %ebp
f0100952:	89 e5                	mov    %esp,%ebp
f0100954:	81 ec 08 04 00 00    	sub    $0x408,%esp
	char command_line[1024];

	while (1==1)
	{
		//get command line
		readline("FOS> ", command_line);
f010095a:	83 ec 08             	sub    $0x8,%esp
f010095d:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
f0100963:	50                   	push   %eax
f0100964:	68 f4 51 10 f0       	push   $0xf01051f4
f0100969:	e8 2f 3a 00 00       	call   f010439d <readline>
f010096e:	83 c4 10             	add    $0x10,%esp

		//parse and execute the command
		if (command_line != NULL)
			if (execute_command(command_line) < 0)
f0100971:	83 ec 0c             	sub    $0xc,%esp
f0100974:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
f010097a:	50                   	push   %eax
f010097b:	e8 0d 00 00 00       	call   f010098d <execute_command>
f0100980:	83 c4 10             	add    $0x10,%esp
f0100983:	85 c0                	test   %eax,%eax
f0100985:	78 02                	js     f0100989 <run_command_prompt+0x38>
				break;
	}
f0100987:	eb d1                	jmp    f010095a <run_command_prompt+0x9>
		readline("FOS> ", command_line);

		//parse and execute the command
		if (command_line != NULL)
			if (execute_command(command_line) < 0)
				break;
f0100989:	90                   	nop
	}
}
f010098a:	90                   	nop
f010098b:	c9                   	leave  
f010098c:	c3                   	ret    

f010098d <execute_command>:
#define WHITESPACE "\t\r\n "

//Function to parse any command and execute it
//(simply by calling its corresponding function)
int execute_command(char *command_string)
{
f010098d:	55                   	push   %ebp
f010098e:	89 e5                	mov    %esp,%ebp
f0100990:	83 ec 58             	sub    $0x58,%esp
	int number_of_arguments;
	//allocate array of char * of size MAX_ARGUMENTS = 16 found in string.h
	char *arguments[MAX_ARGUMENTS];


	strsplit(command_string, WHITESPACE, arguments, &number_of_arguments) ;
f0100993:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0100996:	50                   	push   %eax
f0100997:	8d 45 a8             	lea    -0x58(%ebp),%eax
f010099a:	50                   	push   %eax
f010099b:	68 fa 51 10 f0       	push   $0xf01051fa
f01009a0:	ff 75 08             	pushl  0x8(%ebp)
f01009a3:	e8 ca 3f 00 00       	call   f0104972 <strsplit>
f01009a8:	83 c4 10             	add    $0x10,%esp
	if (number_of_arguments == 0)
f01009ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01009ae:	85 c0                	test   %eax,%eax
f01009b0:	75 0a                	jne    f01009bc <execute_command+0x2f>
		return 0;
f01009b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01009b7:	e9 95 00 00 00       	jmp    f0100a51 <execute_command+0xc4>

	// Lookup in the commands array and execute the command
	int command_found = 0;
f01009bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int i ;
	for (i = 0; i < NUM_OF_COMMANDS; i++)
f01009c3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01009ca:	eb 33                	jmp    f01009ff <execute_command+0x72>
	{
		if (strcmp(arguments[0], commands[i].name) == 0)
f01009cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01009cf:	89 d0                	mov    %edx,%eax
f01009d1:	01 c0                	add    %eax,%eax
f01009d3:	01 d0                	add    %edx,%eax
f01009d5:	c1 e0 02             	shl    $0x2,%eax
f01009d8:	05 40 b5 11 f0       	add    $0xf011b540,%eax
f01009dd:	8b 10                	mov    (%eax),%edx
f01009df:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009e2:	83 ec 08             	sub    $0x8,%esp
f01009e5:	52                   	push   %edx
f01009e6:	50                   	push   %eax
f01009e7:	e8 ec 3b 00 00       	call   f01045d8 <strcmp>
f01009ec:	83 c4 10             	add    $0x10,%esp
f01009ef:	85 c0                	test   %eax,%eax
f01009f1:	75 09                	jne    f01009fc <execute_command+0x6f>
		{
			command_found = 1;
f01009f3:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
			break;
f01009fa:	eb 0b                	jmp    f0100a07 <execute_command+0x7a>
		return 0;

	// Lookup in the commands array and execute the command
	int command_found = 0;
	int i ;
	for (i = 0; i < NUM_OF_COMMANDS; i++)
f01009fc:	ff 45 f0             	incl   -0x10(%ebp)
f01009ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100a02:	83 f8 0e             	cmp    $0xe,%eax
f0100a05:	76 c5                	jbe    f01009cc <execute_command+0x3f>
			command_found = 1;
			break;
		}
	}

	if(command_found)
f0100a07:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0100a0b:	74 2b                	je     f0100a38 <execute_command+0xab>
	{
		int return_value;
		return_value = commands[i].function_to_execute(number_of_arguments, arguments);
f0100a0d:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100a10:	89 d0                	mov    %edx,%eax
f0100a12:	01 c0                	add    %eax,%eax
f0100a14:	01 d0                	add    %edx,%eax
f0100a16:	c1 e0 02             	shl    $0x2,%eax
f0100a19:	05 48 b5 11 f0       	add    $0xf011b548,%eax
f0100a1e:	8b 00                	mov    (%eax),%eax
f0100a20:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100a23:	83 ec 08             	sub    $0x8,%esp
f0100a26:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100a29:	51                   	push   %ecx
f0100a2a:	52                   	push   %edx
f0100a2b:	ff d0                	call   *%eax
f0100a2d:	83 c4 10             	add    $0x10,%esp
f0100a30:	89 45 ec             	mov    %eax,-0x14(%ebp)
		return return_value;
f0100a33:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100a36:	eb 19                	jmp    f0100a51 <execute_command+0xc4>
	}
	else
	{
		//if not found, then it's unknown command
		cprintf("Unknown command '%s'\n", arguments[0]);
f0100a38:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a3b:	83 ec 08             	sub    $0x8,%esp
f0100a3e:	50                   	push   %eax
f0100a3f:	68 ff 51 10 f0       	push   $0xf01051ff
f0100a44:	e8 5e 25 00 00       	call   f0102fa7 <cprintf>
f0100a49:	83 c4 10             	add    $0x10,%esp
		return 0;
f0100a4c:	b8 00 00 00 00       	mov    $0x0,%eax
	}
}
f0100a51:	c9                   	leave  
f0100a52:	c3                   	ret    

f0100a53 <command_help>:

/***** Implementations of basic kernel command prompt commands *****/

//print name and description of each command
int command_help(int number_of_arguments, char **arguments)
{
f0100a53:	55                   	push   %ebp
f0100a54:	89 e5                	mov    %esp,%ebp
f0100a56:	83 ec 18             	sub    $0x18,%esp
	int i;
	for (i = 0; i < NUM_OF_COMMANDS; i++)
f0100a59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0100a60:	eb 3b                	jmp    f0100a9d <command_help+0x4a>
		cprintf("%s - %s\n", commands[i].name, commands[i].description);
f0100a62:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100a65:	89 d0                	mov    %edx,%eax
f0100a67:	01 c0                	add    %eax,%eax
f0100a69:	01 d0                	add    %edx,%eax
f0100a6b:	c1 e0 02             	shl    $0x2,%eax
f0100a6e:	05 44 b5 11 f0       	add    $0xf011b544,%eax
f0100a73:	8b 10                	mov    (%eax),%edx
f0100a75:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f0100a78:	89 c8                	mov    %ecx,%eax
f0100a7a:	01 c0                	add    %eax,%eax
f0100a7c:	01 c8                	add    %ecx,%eax
f0100a7e:	c1 e0 02             	shl    $0x2,%eax
f0100a81:	05 40 b5 11 f0       	add    $0xf011b540,%eax
f0100a86:	8b 00                	mov    (%eax),%eax
f0100a88:	83 ec 04             	sub    $0x4,%esp
f0100a8b:	52                   	push   %edx
f0100a8c:	50                   	push   %eax
f0100a8d:	68 15 52 10 f0       	push   $0xf0105215
f0100a92:	e8 10 25 00 00       	call   f0102fa7 <cprintf>
f0100a97:	83 c4 10             	add    $0x10,%esp

//print name and description of each command
int command_help(int number_of_arguments, char **arguments)
{
	int i;
	for (i = 0; i < NUM_OF_COMMANDS; i++)
f0100a9a:	ff 45 f4             	incl   -0xc(%ebp)
f0100a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100aa0:	83 f8 0e             	cmp    $0xe,%eax
f0100aa3:	76 bd                	jbe    f0100a62 <command_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].description);

	cprintf("-------------------\n");
f0100aa5:	83 ec 0c             	sub    $0xc,%esp
f0100aa8:	68 1e 52 10 f0       	push   $0xf010521e
f0100aad:	e8 f5 24 00 00       	call   f0102fa7 <cprintf>
f0100ab2:	83 c4 10             	add    $0x10,%esp

	return 0;
f0100ab5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100aba:	c9                   	leave  
f0100abb:	c3                   	ret    

f0100abc <command_kernel_info>:

//print information about kernel addresses and kernel size
int command_kernel_info(int number_of_arguments, char **arguments )
{
f0100abc:	55                   	push   %ebp
f0100abd:	89 e5                	mov    %esp,%ebp
f0100abf:	83 ec 08             	sub    $0x8,%esp
	extern char start_of_kernel[], end_of_kernel_code_section[], start_of_uninitialized_data_section[], end_of_kernel[];

	cprintf("Special kernel symbols:\n");
f0100ac2:	83 ec 0c             	sub    $0xc,%esp
f0100ac5:	68 33 52 10 f0       	push   $0xf0105233
f0100aca:	e8 d8 24 00 00       	call   f0102fa7 <cprintf>
f0100acf:	83 c4 10             	add    $0x10,%esp
	cprintf("  Start Address of the kernel 			%08x (virt)  %08x (phys)\n", start_of_kernel, start_of_kernel - KERNEL_BASE);
f0100ad2:	b8 0c 00 10 00       	mov    $0x10000c,%eax
f0100ad7:	83 ec 04             	sub    $0x4,%esp
f0100ada:	50                   	push   %eax
f0100adb:	68 0c 00 10 f0       	push   $0xf010000c
f0100ae0:	68 4c 52 10 f0       	push   $0xf010524c
f0100ae5:	e8 bd 24 00 00       	call   f0102fa7 <cprintf>
f0100aea:	83 c4 10             	add    $0x10,%esp
	cprintf("  End address of kernel code  			%08x (virt)  %08x (phys)\n", end_of_kernel_code_section, end_of_kernel_code_section - KERNEL_BASE);
f0100aed:	b8 a9 4c 10 00       	mov    $0x104ca9,%eax
f0100af2:	83 ec 04             	sub    $0x4,%esp
f0100af5:	50                   	push   %eax
f0100af6:	68 a9 4c 10 f0       	push   $0xf0104ca9
f0100afb:	68 88 52 10 f0       	push   $0xf0105288
f0100b00:	e8 a2 24 00 00       	call   f0102fa7 <cprintf>
f0100b05:	83 c4 10             	add    $0x10,%esp
	cprintf("  Start addr. of uninitialized data section 	%08x (virt)  %08x (phys)\n", start_of_uninitialized_data_section, start_of_uninitialized_data_section - KERNEL_BASE);
f0100b08:	b8 92 dc 14 00       	mov    $0x14dc92,%eax
f0100b0d:	83 ec 04             	sub    $0x4,%esp
f0100b10:	50                   	push   %eax
f0100b11:	68 92 dc 14 f0       	push   $0xf014dc92
f0100b16:	68 c4 52 10 f0       	push   $0xf01052c4
f0100b1b:	e8 87 24 00 00       	call   f0102fa7 <cprintf>
f0100b20:	83 c4 10             	add    $0x10,%esp
	cprintf("  End address of the kernel   			%08x (virt)  %08x (phys)\n", end_of_kernel, end_of_kernel - KERNEL_BASE);
f0100b23:	b8 8c e7 14 00       	mov    $0x14e78c,%eax
f0100b28:	83 ec 04             	sub    $0x4,%esp
f0100b2b:	50                   	push   %eax
f0100b2c:	68 8c e7 14 f0       	push   $0xf014e78c
f0100b31:	68 0c 53 10 f0       	push   $0xf010530c
f0100b36:	e8 6c 24 00 00       	call   f0102fa7 <cprintf>
f0100b3b:	83 c4 10             	add    $0x10,%esp
	cprintf("Kernel executable memory footprint: %d KB\n",
			(end_of_kernel-start_of_kernel+1023)/1024);
f0100b3e:	b8 8c e7 14 f0       	mov    $0xf014e78c,%eax
f0100b43:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100b49:	b8 0c 00 10 f0       	mov    $0xf010000c,%eax
f0100b4e:	29 c2                	sub    %eax,%edx
f0100b50:	89 d0                	mov    %edx,%eax
	cprintf("Special kernel symbols:\n");
	cprintf("  Start Address of the kernel 			%08x (virt)  %08x (phys)\n", start_of_kernel, start_of_kernel - KERNEL_BASE);
	cprintf("  End address of kernel code  			%08x (virt)  %08x (phys)\n", end_of_kernel_code_section, end_of_kernel_code_section - KERNEL_BASE);
	cprintf("  Start addr. of uninitialized data section 	%08x (virt)  %08x (phys)\n", start_of_uninitialized_data_section, start_of_uninitialized_data_section - KERNEL_BASE);
	cprintf("  End address of the kernel   			%08x (virt)  %08x (phys)\n", end_of_kernel, end_of_kernel - KERNEL_BASE);
	cprintf("Kernel executable memory footprint: %d KB\n",
f0100b52:	85 c0                	test   %eax,%eax
f0100b54:	79 05                	jns    f0100b5b <command_kernel_info+0x9f>
f0100b56:	05 ff 03 00 00       	add    $0x3ff,%eax
f0100b5b:	c1 f8 0a             	sar    $0xa,%eax
f0100b5e:	83 ec 08             	sub    $0x8,%esp
f0100b61:	50                   	push   %eax
f0100b62:	68 48 53 10 f0       	push   $0xf0105348
f0100b67:	e8 3b 24 00 00       	call   f0102fa7 <cprintf>
f0100b6c:	83 c4 10             	add    $0x10,%esp
			(end_of_kernel-start_of_kernel+1023)/1024);
	return 0;
f0100b6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100b74:	c9                   	leave  
f0100b75:	c3                   	ret    

f0100b76 <command_readmem>:


int command_readmem(int number_of_arguments, char **arguments)
{
f0100b76:	55                   	push   %ebp
f0100b77:	89 e5                	mov    %esp,%ebp
f0100b79:	83 ec 18             	sub    $0x18,%esp
	unsigned int address = strtol(arguments[1], NULL, 16);
f0100b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100b7f:	83 c0 04             	add    $0x4,%eax
f0100b82:	8b 00                	mov    (%eax),%eax
f0100b84:	83 ec 04             	sub    $0x4,%esp
f0100b87:	6a 10                	push   $0x10
f0100b89:	6a 00                	push   $0x0
f0100b8b:	50                   	push   %eax
f0100b8c:	e8 9b 3c 00 00       	call   f010482c <strtol>
f0100b91:	83 c4 10             	add    $0x10,%esp
f0100b94:	89 45 f4             	mov    %eax,-0xc(%ebp)
	unsigned char *ptr = (unsigned char *)(address ) ;
f0100b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b9a:	89 45 f0             	mov    %eax,-0x10(%ebp)

	cprintf("value at address %x = %c\n", ptr, *ptr);
f0100b9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100ba0:	8a 00                	mov    (%eax),%al
f0100ba2:	0f b6 c0             	movzbl %al,%eax
f0100ba5:	83 ec 04             	sub    $0x4,%esp
f0100ba8:	50                   	push   %eax
f0100ba9:	ff 75 f0             	pushl  -0x10(%ebp)
f0100bac:	68 73 53 10 f0       	push   $0xf0105373
f0100bb1:	e8 f1 23 00 00       	call   f0102fa7 <cprintf>
f0100bb6:	83 c4 10             	add    $0x10,%esp

	return 0;
f0100bb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100bbe:	c9                   	leave  
f0100bbf:	c3                   	ret    

f0100bc0 <command_writemem>:

int command_writemem(int number_of_arguments, char **arguments)
{
f0100bc0:	55                   	push   %ebp
f0100bc1:	89 e5                	mov    %esp,%ebp
f0100bc3:	83 ec 18             	sub    $0x18,%esp
	unsigned int address = strtol(arguments[1], NULL, 16);
f0100bc6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bc9:	83 c0 04             	add    $0x4,%eax
f0100bcc:	8b 00                	mov    (%eax),%eax
f0100bce:	83 ec 04             	sub    $0x4,%esp
f0100bd1:	6a 10                	push   $0x10
f0100bd3:	6a 00                	push   $0x0
f0100bd5:	50                   	push   %eax
f0100bd6:	e8 51 3c 00 00       	call   f010482c <strtol>
f0100bdb:	83 c4 10             	add    $0x10,%esp
f0100bde:	89 45 f4             	mov    %eax,-0xc(%ebp)
	unsigned char *ptr = (unsigned char *)(address) ;
f0100be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100be4:	89 45 f0             	mov    %eax,-0x10(%ebp)

	*ptr = arguments[2][0];
f0100be7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bea:	83 c0 08             	add    $0x8,%eax
f0100bed:	8b 00                	mov    (%eax),%eax
f0100bef:	8a 00                	mov    (%eax),%al
f0100bf1:	88 c2                	mov    %al,%dl
f0100bf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100bf6:	88 10                	mov    %dl,(%eax)

	return 0;
f0100bf8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100bfd:	c9                   	leave  
f0100bfe:	c3                   	ret    

f0100bff <command_meminfo>:

int command_meminfo(int number_of_arguments, char **arguments)
{
f0100bff:	55                   	push   %ebp
f0100c00:	89 e5                	mov    %esp,%ebp
f0100c02:	83 ec 08             	sub    $0x8,%esp
	cprintf("Free frames = %d\n", calculate_free_frames());
f0100c05:	e8 ad 1a 00 00       	call   f01026b7 <calculate_free_frames>
f0100c0a:	83 ec 08             	sub    $0x8,%esp
f0100c0d:	50                   	push   %eax
f0100c0e:	68 8d 53 10 f0       	push   $0xf010538d
f0100c13:	e8 8f 23 00 00       	call   f0102fa7 <cprintf>
f0100c18:	83 c4 10             	add    $0x10,%esp
	return 0;
f0100c1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100c20:	c9                   	leave  
f0100c21:	c3                   	ret    

f0100c22 <command_show_mapping>:

//===========================================================================
//Lab4.Hands.On
//=============
int command_show_mapping(int number_of_arguments, char **arguments)
{
f0100c22:	55                   	push   %ebp
f0100c23:	89 e5                	mov    %esp,%ebp
f0100c25:	83 ec 08             	sub    $0x8,%esp
	//TODO: LAB4 Hands-on: fill this function. corresponding command name is "sm"
	//Comment the following line
	panic("Function is not implemented yet!");
f0100c28:	83 ec 04             	sub    $0x4,%esp
f0100c2b:	68 a0 53 10 f0       	push   $0xf01053a0
f0100c30:	68 f3 00 00 00       	push   $0xf3
f0100c35:	68 c1 53 10 f0       	push   $0xf01053c1
f0100c3a:	e8 ef f4 ff ff       	call   f010012e <_panic>

f0100c3f <command_set_permission>:

	return 0 ;
}

int command_set_permission(int number_of_arguments, char **arguments)
{
f0100c3f:	55                   	push   %ebp
f0100c40:	89 e5                	mov    %esp,%ebp
f0100c42:	83 ec 08             	sub    $0x8,%esp
	//TODO: LAB4 Hands-on: fill this function. corresponding command name is "sp"
	//Comment the following line
	panic("Function is not implemented yet!");
f0100c45:	83 ec 04             	sub    $0x4,%esp
f0100c48:	68 a0 53 10 f0       	push   $0xf01053a0
f0100c4d:	68 fc 00 00 00       	push   $0xfc
f0100c52:	68 c1 53 10 f0       	push   $0xf01053c1
f0100c57:	e8 d2 f4 ff ff       	call   f010012e <_panic>

f0100c5c <command_share_range>:

	return 0 ;
}

int command_share_range(int number_of_arguments, char **arguments)
{
f0100c5c:	55                   	push   %ebp
f0100c5d:	89 e5                	mov    %esp,%ebp
f0100c5f:	83 ec 08             	sub    $0x8,%esp
	//TODO: LAB4 Hands-on: fill this function. corresponding command name is "sr"
	//Comment the following line
	panic("Function is not implemented yet!");
f0100c62:	83 ec 04             	sub    $0x4,%esp
f0100c65:	68 a0 53 10 f0       	push   $0xf01053a0
f0100c6a:	68 05 01 00 00       	push   $0x105
f0100c6f:	68 c1 53 10 f0       	push   $0xf01053c1
f0100c74:	e8 b5 f4 ff ff       	call   f010012e <_panic>

f0100c79 <command_nr>:
//===========================================================================
//Lab5.Examples
//==============
//[1] Number of references on the given physical address
int command_nr(int number_of_arguments, char **arguments)
{
f0100c79:	55                   	push   %ebp
f0100c7a:	89 e5                	mov    %esp,%ebp
f0100c7c:	83 ec 08             	sub    $0x8,%esp
	//TODO: LAB5 Example: fill this function. corresponding command name is "nr"
	//Comment the following line
	panic("Function is not implemented yet!");
f0100c7f:	83 ec 04             	sub    $0x4,%esp
f0100c82:	68 a0 53 10 f0       	push   $0xf01053a0
f0100c87:	68 12 01 00 00       	push   $0x112
f0100c8c:	68 c1 53 10 f0       	push   $0xf01053c1
f0100c91:	e8 98 f4 ff ff       	call   f010012e <_panic>

f0100c96 <command_ap>:
	return 0;
}

//[2] Allocate Page: If the given user virtual address is mapped, do nothing. Else, allocate a single frame and map it to a given virtual address in the user space
int command_ap(int number_of_arguments, char **arguments)
{
f0100c96:	55                   	push   %ebp
f0100c97:	89 e5                	mov    %esp,%ebp
f0100c99:	83 ec 08             	sub    $0x8,%esp
	//TODO: LAB5 Example: fill this function. corresponding command name is "ap"
	//Comment the following line
	panic("Function is not implemented yet!");
f0100c9c:	83 ec 04             	sub    $0x4,%esp
f0100c9f:	68 a0 53 10 f0       	push   $0xf01053a0
f0100ca4:	68 1c 01 00 00       	push   $0x11c
f0100ca9:	68 c1 53 10 f0       	push   $0xf01053c1
f0100cae:	e8 7b f4 ff ff       	call   f010012e <_panic>

f0100cb3 <command_fp>:
	return 0 ;
}

//[3] Free Page: Un-map a single page at the given virtual address in the user space
int command_fp(int number_of_arguments, char **arguments)
{
f0100cb3:	55                   	push   %ebp
f0100cb4:	89 e5                	mov    %esp,%ebp
f0100cb6:	83 ec 08             	sub    $0x8,%esp
	//TODO: LAB5 Example: fill this function. corresponding command name is "fp"
	//Comment the following line
	panic("Function is not implemented yet!");
f0100cb9:	83 ec 04             	sub    $0x4,%esp
f0100cbc:	68 a0 53 10 f0       	push   $0xf01053a0
f0100cc1:	68 26 01 00 00       	push   $0x126
f0100cc6:	68 c1 53 10 f0       	push   $0xf01053c1
f0100ccb:	e8 5e f4 ff ff       	call   f010012e <_panic>

f0100cd0 <command_asp>:
//===========================================================================
//Lab5.Hands-on
//==============
//[1] Allocate Shared Pages
int command_asp(int number_of_arguments, char **arguments)
{
f0100cd0:	55                   	push   %ebp
f0100cd1:	89 e5                	mov    %esp,%ebp
f0100cd3:	83 ec 08             	sub    $0x8,%esp
	//TODO: LAB5 Hands-on: fill this function. corresponding command name is "asp"
	//Comment the following line
	panic("Function is not implemented yet!");
f0100cd6:	83 ec 04             	sub    $0x4,%esp
f0100cd9:	68 a0 53 10 f0       	push   $0xf01053a0
f0100cde:	68 33 01 00 00       	push   $0x133
f0100ce3:	68 c1 53 10 f0       	push   $0xf01053c1
f0100ce8:	e8 41 f4 ff ff       	call   f010012e <_panic>

f0100ced <command_cfp>:
}


//[2] Count Free Pages in Range
int command_cfp(int number_of_arguments, char **arguments)
{
f0100ced:	55                   	push   %ebp
f0100cee:	89 e5                	mov    %esp,%ebp
f0100cf0:	83 ec 08             	sub    $0x8,%esp
	//TODO: LAB5 Hands-on: fill this function. corresponding command name is "cfp"
	//Comment the following line
	panic("Function is not implemented yet!");
f0100cf3:	83 ec 04             	sub    $0x4,%esp
f0100cf6:	68 a0 53 10 f0       	push   $0xf01053a0
f0100cfb:	68 3e 01 00 00       	push   $0x13e
f0100d00:	68 c1 53 10 f0       	push   $0xf01053c1
f0100d05:	e8 24 f4 ff ff       	call   f010012e <_panic>

f0100d0a <command_run>:

//===========================================================================
//Lab6.Examples
//=============
int command_run(int number_of_arguments, char **arguments)
{
f0100d0a:	55                   	push   %ebp
f0100d0b:	89 e5                	mov    %esp,%ebp
f0100d0d:	83 ec 18             	sub    $0x18,%esp
	//[1] Create and initialize a new environment for the program to be run
	struct UserProgramInfo* ptr_program_info = env_create(arguments[1]);
f0100d10:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100d13:	83 c0 04             	add    $0x4,%eax
f0100d16:	8b 00                	mov    (%eax),%eax
f0100d18:	83 ec 0c             	sub    $0xc,%esp
f0100d1b:	50                   	push   %eax
f0100d1c:	e8 6f 1a 00 00       	call   f0102790 <env_create>
f0100d21:	83 c4 10             	add    $0x10,%esp
f0100d24:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(ptr_program_info == 0) return 0;
f0100d27:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0100d2b:	75 07                	jne    f0100d34 <command_run+0x2a>
f0100d2d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d32:	eb 0f                	jmp    f0100d43 <command_run+0x39>

	//[2] Run the created environment using "env_run" function
	env_run(ptr_program_info->environment);
f0100d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100d37:	8b 40 0c             	mov    0xc(%eax),%eax
f0100d3a:	83 ec 0c             	sub    $0xc,%esp
f0100d3d:	50                   	push   %eax
f0100d3e:	e8 bc 1a 00 00       	call   f01027ff <env_run>
	return 0;
}
f0100d43:	c9                   	leave  
f0100d44:	c3                   	ret    

f0100d45 <command_kill>:

int command_kill(int number_of_arguments, char **arguments)
{
f0100d45:	55                   	push   %ebp
f0100d46:	89 e5                	mov    %esp,%ebp
f0100d48:	83 ec 18             	sub    $0x18,%esp
	//[1] Get the user program info of the program (by searching in the "userPrograms" array
	struct UserProgramInfo* ptr_program_info = get_user_program_info(arguments[1]) ;
f0100d4b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100d4e:	83 c0 04             	add    $0x4,%eax
f0100d51:	8b 00                	mov    (%eax),%eax
f0100d53:	83 ec 0c             	sub    $0xc,%esp
f0100d56:	50                   	push   %eax
f0100d57:	e8 74 1f 00 00       	call   f0102cd0 <get_user_program_info>
f0100d5c:	83 c4 10             	add    $0x10,%esp
f0100d5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if(ptr_program_info == 0) return 0;
f0100d62:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0100d66:	75 07                	jne    f0100d6f <command_kill+0x2a>
f0100d68:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d6d:	eb 21                	jmp    f0100d90 <command_kill+0x4b>

	//[2] Kill its environment using "env_free" function
	env_free(ptr_program_info->environment);
f0100d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100d72:	8b 40 0c             	mov    0xc(%eax),%eax
f0100d75:	83 ec 0c             	sub    $0xc,%esp
f0100d78:	50                   	push   %eax
f0100d79:	e8 c4 1a 00 00       	call   f0102842 <env_free>
f0100d7e:	83 c4 10             	add    $0x10,%esp
	ptr_program_info->environment = NULL;
f0100d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100d84:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	return 0;
f0100d8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100d90:	c9                   	leave  
f0100d91:	c3                   	ret    

f0100d92 <command_ft>:

int command_ft(int number_of_arguments, char **arguments)
{
f0100d92:	55                   	push   %ebp
f0100d93:	89 e5                	mov    %esp,%ebp
	//TODO: LAB6 Example: fill this function. corresponding command name is "ft"
	//Comment the following line

	return 0;
f0100d95:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100d9a:	5d                   	pop    %ebp
f0100d9b:	c3                   	ret    

f0100d9c <to_frame_number>:
void	unmap_frame(uint32 *pgdir, void *va);
struct Frame_Info *get_frame_info(uint32 *ptr_page_directory, void *virtual_address, uint32 **ptr_page_table);
void decrement_references(struct Frame_Info* ptr_frame_info);

static inline uint32 to_frame_number(struct Frame_Info *ptr_frame_info)
{
f0100d9c:	55                   	push   %ebp
f0100d9d:	89 e5                	mov    %esp,%ebp
	return ptr_frame_info - frames_info;
f0100d9f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100da2:	8b 15 7c e7 14 f0    	mov    0xf014e77c,%edx
f0100da8:	29 d0                	sub    %edx,%eax
f0100daa:	c1 f8 02             	sar    $0x2,%eax
f0100dad:	89 c2                	mov    %eax,%edx
f0100daf:	89 d0                	mov    %edx,%eax
f0100db1:	c1 e0 02             	shl    $0x2,%eax
f0100db4:	01 d0                	add    %edx,%eax
f0100db6:	c1 e0 02             	shl    $0x2,%eax
f0100db9:	01 d0                	add    %edx,%eax
f0100dbb:	c1 e0 02             	shl    $0x2,%eax
f0100dbe:	01 d0                	add    %edx,%eax
f0100dc0:	89 c1                	mov    %eax,%ecx
f0100dc2:	c1 e1 08             	shl    $0x8,%ecx
f0100dc5:	01 c8                	add    %ecx,%eax
f0100dc7:	89 c1                	mov    %eax,%ecx
f0100dc9:	c1 e1 10             	shl    $0x10,%ecx
f0100dcc:	01 c8                	add    %ecx,%eax
f0100dce:	01 c0                	add    %eax,%eax
f0100dd0:	01 d0                	add    %edx,%eax
}
f0100dd2:	5d                   	pop    %ebp
f0100dd3:	c3                   	ret    

f0100dd4 <to_physical_address>:

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0100dd4:	55                   	push   %ebp
f0100dd5:	89 e5                	mov    %esp,%ebp
	return to_frame_number(ptr_frame_info) << PGSHIFT;
f0100dd7:	ff 75 08             	pushl  0x8(%ebp)
f0100dda:	e8 bd ff ff ff       	call   f0100d9c <to_frame_number>
f0100ddf:	83 c4 04             	add    $0x4,%esp
f0100de2:	c1 e0 0c             	shl    $0xc,%eax
}
f0100de5:	c9                   	leave  
f0100de6:	c3                   	ret    

f0100de7 <nvram_read>:
{
	sizeof(gdt) - 1, (unsigned long) gdt
};

int nvram_read(int r)
{	
f0100de7:	55                   	push   %ebp
f0100de8:	89 e5                	mov    %esp,%ebp
f0100dea:	53                   	push   %ebx
f0100deb:	83 ec 04             	sub    $0x4,%esp
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100dee:	8b 45 08             	mov    0x8(%ebp),%eax
f0100df1:	83 ec 0c             	sub    $0xc,%esp
f0100df4:	50                   	push   %eax
f0100df5:	e8 f8 20 00 00       	call   f0102ef2 <mc146818_read>
f0100dfa:	83 c4 10             	add    $0x10,%esp
f0100dfd:	89 c3                	mov    %eax,%ebx
f0100dff:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e02:	40                   	inc    %eax
f0100e03:	83 ec 0c             	sub    $0xc,%esp
f0100e06:	50                   	push   %eax
f0100e07:	e8 e6 20 00 00       	call   f0102ef2 <mc146818_read>
f0100e0c:	83 c4 10             	add    $0x10,%esp
f0100e0f:	c1 e0 08             	shl    $0x8,%eax
f0100e12:	09 d8                	or     %ebx,%eax
}
f0100e14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100e17:	c9                   	leave  
f0100e18:	c3                   	ret    

f0100e19 <detect_memory>:
	
void detect_memory()
{
f0100e19:	55                   	push   %ebp
f0100e1a:	89 e5                	mov    %esp,%ebp
f0100e1c:	83 ec 18             	sub    $0x18,%esp
	// CMOS tells us how many kilobytes there are
	size_of_base_mem = ROUNDDOWN(nvram_read(NVRAM_BASELO)*1024, PAGE_SIZE);
f0100e1f:	83 ec 0c             	sub    $0xc,%esp
f0100e22:	6a 15                	push   $0x15
f0100e24:	e8 be ff ff ff       	call   f0100de7 <nvram_read>
f0100e29:	83 c4 10             	add    $0x10,%esp
f0100e2c:	c1 e0 0a             	shl    $0xa,%eax
f0100e2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0100e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100e35:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100e3a:	a3 74 e7 14 f0       	mov    %eax,0xf014e774
	size_of_extended_mem = ROUNDDOWN(nvram_read(NVRAM_EXTLO)*1024, PAGE_SIZE);
f0100e3f:	83 ec 0c             	sub    $0xc,%esp
f0100e42:	6a 17                	push   $0x17
f0100e44:	e8 9e ff ff ff       	call   f0100de7 <nvram_read>
f0100e49:	83 c4 10             	add    $0x10,%esp
f0100e4c:	c1 e0 0a             	shl    $0xa,%eax
f0100e4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100e52:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100e55:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100e5a:	a3 6c e7 14 f0       	mov    %eax,0xf014e76c

	// Calculate the maxmium physical address based on whether
	// or not there is any extended memory.  See comment in ../inc/mmu.h.
	if (size_of_extended_mem)
f0100e5f:	a1 6c e7 14 f0       	mov    0xf014e76c,%eax
f0100e64:	85 c0                	test   %eax,%eax
f0100e66:	74 11                	je     f0100e79 <detect_memory+0x60>
		maxpa = PHYS_EXTENDED_MEM + size_of_extended_mem;
f0100e68:	a1 6c e7 14 f0       	mov    0xf014e76c,%eax
f0100e6d:	05 00 00 10 00       	add    $0x100000,%eax
f0100e72:	a3 70 e7 14 f0       	mov    %eax,0xf014e770
f0100e77:	eb 0a                	jmp    f0100e83 <detect_memory+0x6a>
	else
		maxpa = size_of_extended_mem;
f0100e79:	a1 6c e7 14 f0       	mov    0xf014e76c,%eax
f0100e7e:	a3 70 e7 14 f0       	mov    %eax,0xf014e770

	number_of_frames = maxpa / PAGE_SIZE;
f0100e83:	a1 70 e7 14 f0       	mov    0xf014e770,%eax
f0100e88:	c1 e8 0c             	shr    $0xc,%eax
f0100e8b:	a3 68 e7 14 f0       	mov    %eax,0xf014e768

	cprintf("Physical memory: %dK available, ", (int)(maxpa/1024));
f0100e90:	a1 70 e7 14 f0       	mov    0xf014e770,%eax
f0100e95:	c1 e8 0a             	shr    $0xa,%eax
f0100e98:	83 ec 08             	sub    $0x8,%esp
f0100e9b:	50                   	push   %eax
f0100e9c:	68 d8 53 10 f0       	push   $0xf01053d8
f0100ea1:	e8 01 21 00 00       	call   f0102fa7 <cprintf>
f0100ea6:	83 c4 10             	add    $0x10,%esp
	cprintf("base = %dK, extended = %dK\n", (int)(size_of_base_mem/1024), (int)(size_of_extended_mem/1024));
f0100ea9:	a1 6c e7 14 f0       	mov    0xf014e76c,%eax
f0100eae:	c1 e8 0a             	shr    $0xa,%eax
f0100eb1:	89 c2                	mov    %eax,%edx
f0100eb3:	a1 74 e7 14 f0       	mov    0xf014e774,%eax
f0100eb8:	c1 e8 0a             	shr    $0xa,%eax
f0100ebb:	83 ec 04             	sub    $0x4,%esp
f0100ebe:	52                   	push   %edx
f0100ebf:	50                   	push   %eax
f0100ec0:	68 f9 53 10 f0       	push   $0xf01053f9
f0100ec5:	e8 dd 20 00 00       	call   f0102fa7 <cprintf>
f0100eca:	83 c4 10             	add    $0x10,%esp
}
f0100ecd:	90                   	nop
f0100ece:	c9                   	leave  
f0100ecf:	c3                   	ret    

f0100ed0 <check_boot_pgdir>:
// but it is a pretty good check.
//
uint32 check_va2pa(uint32 *ptr_page_directory, uint32 va);

void check_boot_pgdir()
{
f0100ed0:	55                   	push   %ebp
f0100ed1:	89 e5                	mov    %esp,%ebp
f0100ed3:	83 ec 28             	sub    $0x28,%esp
	uint32 i, n;

	// check frames_info array
	n = ROUNDUP(number_of_frames*sizeof(struct Frame_Info), PAGE_SIZE);
f0100ed6:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
f0100edd:	8b 15 68 e7 14 f0    	mov    0xf014e768,%edx
f0100ee3:	89 d0                	mov    %edx,%eax
f0100ee5:	01 c0                	add    %eax,%eax
f0100ee7:	01 d0                	add    %edx,%eax
f0100ee9:	c1 e0 02             	shl    $0x2,%eax
f0100eec:	89 c2                	mov    %eax,%edx
f0100eee:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100ef1:	01 d0                	add    %edx,%eax
f0100ef3:	48                   	dec    %eax
f0100ef4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100ef7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100efa:	ba 00 00 00 00       	mov    $0x0,%edx
f0100eff:	f7 75 f0             	divl   -0x10(%ebp)
f0100f02:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100f05:	29 d0                	sub    %edx,%eax
f0100f07:	89 45 e8             	mov    %eax,-0x18(%ebp)
	for (i = 0; i < n; i += PAGE_SIZE)
f0100f0a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0100f11:	eb 71                	jmp    f0100f84 <check_boot_pgdir+0xb4>
		assert(check_va2pa(ptr_page_directory, READ_ONLY_FRAMES_INFO + i) == K_PHYSICAL_ADDRESS(frames_info) + i);
f0100f13:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100f16:	8d 90 00 00 00 ef    	lea    -0x11000000(%eax),%edx
f0100f1c:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0100f21:	83 ec 08             	sub    $0x8,%esp
f0100f24:	52                   	push   %edx
f0100f25:	50                   	push   %eax
f0100f26:	e8 f4 01 00 00       	call   f010111f <check_va2pa>
f0100f2b:	83 c4 10             	add    $0x10,%esp
f0100f2e:	89 c2                	mov    %eax,%edx
f0100f30:	a1 7c e7 14 f0       	mov    0xf014e77c,%eax
f0100f35:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100f38:	81 7d e4 ff ff ff ef 	cmpl   $0xefffffff,-0x1c(%ebp)
f0100f3f:	77 14                	ja     f0100f55 <check_boot_pgdir+0x85>
f0100f41:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100f44:	68 18 54 10 f0       	push   $0xf0105418
f0100f49:	6a 5e                	push   $0x5e
f0100f4b:	68 49 54 10 f0       	push   $0xf0105449
f0100f50:	e8 d9 f1 ff ff       	call   f010012e <_panic>
f0100f55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f58:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f0100f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100f61:	01 c8                	add    %ecx,%eax
f0100f63:	39 c2                	cmp    %eax,%edx
f0100f65:	74 16                	je     f0100f7d <check_boot_pgdir+0xad>
f0100f67:	68 58 54 10 f0       	push   $0xf0105458
f0100f6c:	68 ba 54 10 f0       	push   $0xf01054ba
f0100f71:	6a 5e                	push   $0x5e
f0100f73:	68 49 54 10 f0       	push   $0xf0105449
f0100f78:	e8 b1 f1 ff ff       	call   f010012e <_panic>
{
	uint32 i, n;

	// check frames_info array
	n = ROUNDUP(number_of_frames*sizeof(struct Frame_Info), PAGE_SIZE);
	for (i = 0; i < n; i += PAGE_SIZE)
f0100f7d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f0100f84:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100f87:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0100f8a:	72 87                	jb     f0100f13 <check_boot_pgdir+0x43>
		assert(check_va2pa(ptr_page_directory, READ_ONLY_FRAMES_INFO + i) == K_PHYSICAL_ADDRESS(frames_info) + i);

	// check phys mem
	for (i = 0; KERNEL_BASE + i != 0; i += PAGE_SIZE)
f0100f8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0100f93:	eb 3d                	jmp    f0100fd2 <check_boot_pgdir+0x102>
		assert(check_va2pa(ptr_page_directory, KERNEL_BASE + i) == i);
f0100f95:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100f98:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0100f9e:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0100fa3:	83 ec 08             	sub    $0x8,%esp
f0100fa6:	52                   	push   %edx
f0100fa7:	50                   	push   %eax
f0100fa8:	e8 72 01 00 00       	call   f010111f <check_va2pa>
f0100fad:	83 c4 10             	add    $0x10,%esp
f0100fb0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0100fb3:	74 16                	je     f0100fcb <check_boot_pgdir+0xfb>
f0100fb5:	68 d0 54 10 f0       	push   $0xf01054d0
f0100fba:	68 ba 54 10 f0       	push   $0xf01054ba
f0100fbf:	6a 62                	push   $0x62
f0100fc1:	68 49 54 10 f0       	push   $0xf0105449
f0100fc6:	e8 63 f1 ff ff       	call   f010012e <_panic>
	n = ROUNDUP(number_of_frames*sizeof(struct Frame_Info), PAGE_SIZE);
	for (i = 0; i < n; i += PAGE_SIZE)
		assert(check_va2pa(ptr_page_directory, READ_ONLY_FRAMES_INFO + i) == K_PHYSICAL_ADDRESS(frames_info) + i);

	// check phys mem
	for (i = 0; KERNEL_BASE + i != 0; i += PAGE_SIZE)
f0100fcb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f0100fd2:	81 7d f4 00 00 00 10 	cmpl   $0x10000000,-0xc(%ebp)
f0100fd9:	75 ba                	jne    f0100f95 <check_boot_pgdir+0xc5>
		assert(check_va2pa(ptr_page_directory, KERNEL_BASE + i) == i);

	// check kernel stack
	for (i = 0; i < KERNEL_STACK_SIZE; i += PAGE_SIZE)
f0100fdb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0100fe2:	eb 6e                	jmp    f0101052 <check_boot_pgdir+0x182>
		assert(check_va2pa(ptr_page_directory, KERNEL_STACK_TOP - KERNEL_STACK_SIZE + i) == K_PHYSICAL_ADDRESS(ptr_stack_bottom) + i);
f0100fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100fe7:	8d 90 00 80 bf ef    	lea    -0x10408000(%eax),%edx
f0100fed:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0100ff2:	83 ec 08             	sub    $0x8,%esp
f0100ff5:	52                   	push   %edx
f0100ff6:	50                   	push   %eax
f0100ff7:	e8 23 01 00 00       	call   f010111f <check_va2pa>
f0100ffc:	83 c4 10             	add    $0x10,%esp
f0100fff:	c7 45 e0 00 30 11 f0 	movl   $0xf0113000,-0x20(%ebp)
f0101006:	81 7d e0 ff ff ff ef 	cmpl   $0xefffffff,-0x20(%ebp)
f010100d:	77 14                	ja     f0101023 <check_boot_pgdir+0x153>
f010100f:	ff 75 e0             	pushl  -0x20(%ebp)
f0101012:	68 18 54 10 f0       	push   $0xf0105418
f0101017:	6a 66                	push   $0x66
f0101019:	68 49 54 10 f0       	push   $0xf0105449
f010101e:	e8 0b f1 ff ff       	call   f010012e <_panic>
f0101023:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101026:	8d 8a 00 00 00 10    	lea    0x10000000(%edx),%ecx
f010102c:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010102f:	01 ca                	add    %ecx,%edx
f0101031:	39 d0                	cmp    %edx,%eax
f0101033:	74 16                	je     f010104b <check_boot_pgdir+0x17b>
f0101035:	68 08 55 10 f0       	push   $0xf0105508
f010103a:	68 ba 54 10 f0       	push   $0xf01054ba
f010103f:	6a 66                	push   $0x66
f0101041:	68 49 54 10 f0       	push   $0xf0105449
f0101046:	e8 e3 f0 ff ff       	call   f010012e <_panic>
	// check phys mem
	for (i = 0; KERNEL_BASE + i != 0; i += PAGE_SIZE)
		assert(check_va2pa(ptr_page_directory, KERNEL_BASE + i) == i);

	// check kernel stack
	for (i = 0; i < KERNEL_STACK_SIZE; i += PAGE_SIZE)
f010104b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f0101052:	81 7d f4 ff 7f 00 00 	cmpl   $0x7fff,-0xc(%ebp)
f0101059:	76 89                	jbe    f0100fe4 <check_boot_pgdir+0x114>
		assert(check_va2pa(ptr_page_directory, KERNEL_STACK_TOP - KERNEL_STACK_SIZE + i) == K_PHYSICAL_ADDRESS(ptr_stack_bottom) + i);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
f010105b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0101062:	e9 98 00 00 00       	jmp    f01010ff <check_boot_pgdir+0x22f>
		switch (i) {
f0101067:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010106a:	2d bb 03 00 00       	sub    $0x3bb,%eax
f010106f:	83 f8 04             	cmp    $0x4,%eax
f0101072:	77 29                	ja     f010109d <check_boot_pgdir+0x1cd>
		case PDX(VPT):
		case PDX(UVPT):
		case PDX(KERNEL_STACK_TOP-1):
		case PDX(UENVS):
		case PDX(READ_ONLY_FRAMES_INFO):			
			assert(ptr_page_directory[i]);
f0101074:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0101079:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010107c:	c1 e2 02             	shl    $0x2,%edx
f010107f:	01 d0                	add    %edx,%eax
f0101081:	8b 00                	mov    (%eax),%eax
f0101083:	85 c0                	test   %eax,%eax
f0101085:	75 71                	jne    f01010f8 <check_boot_pgdir+0x228>
f0101087:	68 7e 55 10 f0       	push   $0xf010557e
f010108c:	68 ba 54 10 f0       	push   $0xf01054ba
f0101091:	6a 70                	push   $0x70
f0101093:	68 49 54 10 f0       	push   $0xf0105449
f0101098:	e8 91 f0 ff ff       	call   f010012e <_panic>
			break;
		default:
			if (i >= PDX(KERNEL_BASE))
f010109d:	81 7d f4 bf 03 00 00 	cmpl   $0x3bf,-0xc(%ebp)
f01010a4:	76 29                	jbe    f01010cf <check_boot_pgdir+0x1ff>
				assert(ptr_page_directory[i]);
f01010a6:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f01010ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01010ae:	c1 e2 02             	shl    $0x2,%edx
f01010b1:	01 d0                	add    %edx,%eax
f01010b3:	8b 00                	mov    (%eax),%eax
f01010b5:	85 c0                	test   %eax,%eax
f01010b7:	75 42                	jne    f01010fb <check_boot_pgdir+0x22b>
f01010b9:	68 7e 55 10 f0       	push   $0xf010557e
f01010be:	68 ba 54 10 f0       	push   $0xf01054ba
f01010c3:	6a 74                	push   $0x74
f01010c5:	68 49 54 10 f0       	push   $0xf0105449
f01010ca:	e8 5f f0 ff ff       	call   f010012e <_panic>
			else				
				assert(ptr_page_directory[i] == 0);
f01010cf:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f01010d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01010d7:	c1 e2 02             	shl    $0x2,%edx
f01010da:	01 d0                	add    %edx,%eax
f01010dc:	8b 00                	mov    (%eax),%eax
f01010de:	85 c0                	test   %eax,%eax
f01010e0:	74 19                	je     f01010fb <check_boot_pgdir+0x22b>
f01010e2:	68 94 55 10 f0       	push   $0xf0105594
f01010e7:	68 ba 54 10 f0       	push   $0xf01054ba
f01010ec:	6a 76                	push   $0x76
f01010ee:	68 49 54 10 f0       	push   $0xf0105449
f01010f3:	e8 36 f0 ff ff       	call   f010012e <_panic>
		case PDX(UVPT):
		case PDX(KERNEL_STACK_TOP-1):
		case PDX(UENVS):
		case PDX(READ_ONLY_FRAMES_INFO):			
			assert(ptr_page_directory[i]);
			break;
f01010f8:	90                   	nop
f01010f9:	eb 01                	jmp    f01010fc <check_boot_pgdir+0x22c>
		default:
			if (i >= PDX(KERNEL_BASE))
				assert(ptr_page_directory[i]);
			else				
				assert(ptr_page_directory[i] == 0);
			break;
f01010fb:	90                   	nop
	// check kernel stack
	for (i = 0; i < KERNEL_STACK_SIZE; i += PAGE_SIZE)
		assert(check_va2pa(ptr_page_directory, KERNEL_STACK_TOP - KERNEL_STACK_SIZE + i) == K_PHYSICAL_ADDRESS(ptr_stack_bottom) + i);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
f01010fc:	ff 45 f4             	incl   -0xc(%ebp)
f01010ff:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
f0101106:	0f 86 5b ff ff ff    	jbe    f0101067 <check_boot_pgdir+0x197>
			else				
				assert(ptr_page_directory[i] == 0);
			break;
		}
	}
	cprintf("check_boot_pgdir() succeeded!\n");
f010110c:	83 ec 0c             	sub    $0xc,%esp
f010110f:	68 b0 55 10 f0       	push   $0xf01055b0
f0101114:	e8 8e 1e 00 00       	call   f0102fa7 <cprintf>
f0101119:	83 c4 10             	add    $0x10,%esp
}
f010111c:	90                   	nop
f010111d:	c9                   	leave  
f010111e:	c3                   	ret    

f010111f <check_va2pa>:
// defined by the page directory 'ptr_page_directory'.  The hardware normally performs
// this functionality for us!  We define our own version to help check
// the check_boot_pgdir() function; it shouldn't be used elsewhere.

uint32 check_va2pa(uint32 *ptr_page_directory, uint32 va)
{
f010111f:	55                   	push   %ebp
f0101120:	89 e5                	mov    %esp,%ebp
f0101122:	83 ec 18             	sub    $0x18,%esp
	uint32 *p;

	ptr_page_directory = &ptr_page_directory[PDX(va)];
f0101125:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101128:	c1 e8 16             	shr    $0x16,%eax
f010112b:	c1 e0 02             	shl    $0x2,%eax
f010112e:	01 45 08             	add    %eax,0x8(%ebp)
	if (!(*ptr_page_directory & PERM_PRESENT))
f0101131:	8b 45 08             	mov    0x8(%ebp),%eax
f0101134:	8b 00                	mov    (%eax),%eax
f0101136:	83 e0 01             	and    $0x1,%eax
f0101139:	85 c0                	test   %eax,%eax
f010113b:	75 0a                	jne    f0101147 <check_va2pa+0x28>
		return ~0;
f010113d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101142:	e9 87 00 00 00       	jmp    f01011ce <check_va2pa+0xaf>
	p = (uint32*) K_VIRTUAL_ADDRESS(EXTRACT_ADDRESS(*ptr_page_directory));
f0101147:	8b 45 08             	mov    0x8(%ebp),%eax
f010114a:	8b 00                	mov    (%eax),%eax
f010114c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101151:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101154:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101157:	c1 e8 0c             	shr    $0xc,%eax
f010115a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010115d:	a1 68 e7 14 f0       	mov    0xf014e768,%eax
f0101162:	39 45 f0             	cmp    %eax,-0x10(%ebp)
f0101165:	72 17                	jb     f010117e <check_va2pa+0x5f>
f0101167:	ff 75 f4             	pushl  -0xc(%ebp)
f010116a:	68 d0 55 10 f0       	push   $0xf01055d0
f010116f:	68 89 00 00 00       	push   $0x89
f0101174:	68 49 54 10 f0       	push   $0xf0105449
f0101179:	e8 b0 ef ff ff       	call   f010012e <_panic>
f010117e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101181:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101186:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (!(p[PTX(va)] & PERM_PRESENT))
f0101189:	8b 45 0c             	mov    0xc(%ebp),%eax
f010118c:	c1 e8 0c             	shr    $0xc,%eax
f010118f:	25 ff 03 00 00       	and    $0x3ff,%eax
f0101194:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f010119b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010119e:	01 d0                	add    %edx,%eax
f01011a0:	8b 00                	mov    (%eax),%eax
f01011a2:	83 e0 01             	and    $0x1,%eax
f01011a5:	85 c0                	test   %eax,%eax
f01011a7:	75 07                	jne    f01011b0 <check_va2pa+0x91>
		return ~0;
f01011a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01011ae:	eb 1e                	jmp    f01011ce <check_va2pa+0xaf>
	return EXTRACT_ADDRESS(p[PTX(va)]);
f01011b0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011b3:	c1 e8 0c             	shr    $0xc,%eax
f01011b6:	25 ff 03 00 00       	and    $0x3ff,%eax
f01011bb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01011c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01011c5:	01 d0                	add    %edx,%eax
f01011c7:	8b 00                	mov    (%eax),%eax
f01011c9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
}
f01011ce:	c9                   	leave  
f01011cf:	c3                   	ret    

f01011d0 <tlb_invalidate>:
		
void tlb_invalidate(uint32 *ptr_page_directory, void *virtual_address)
{
f01011d0:	55                   	push   %ebp
f01011d1:	89 e5                	mov    %esp,%ebp
f01011d3:	83 ec 10             	sub    $0x10,%esp
f01011d6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01011df:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(virtual_address);
}
f01011e2:	90                   	nop
f01011e3:	c9                   	leave  
f01011e4:	c3                   	ret    

f01011e5 <page_check>:

void page_check()
{
f01011e5:	55                   	push   %ebp
f01011e6:	89 e5                	mov    %esp,%ebp
f01011e8:	53                   	push   %ebx
f01011e9:	83 ec 24             	sub    $0x24,%esp
	struct Frame_Info *pp, *pp0, *pp1, *pp2;
	struct Linked_List fl;

	// should be able to allocate three frames_info
	pp0 = pp1 = pp2 = 0;
f01011ec:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f01011f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01011f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01011f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01011fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
	assert(allocate_frame(&pp0) == 0);
f01011ff:	83 ec 0c             	sub    $0xc,%esp
f0101202:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0101205:	50                   	push   %eax
f0101206:	e8 e7 10 00 00       	call   f01022f2 <allocate_frame>
f010120b:	83 c4 10             	add    $0x10,%esp
f010120e:	85 c0                	test   %eax,%eax
f0101210:	74 19                	je     f010122b <page_check+0x46>
f0101212:	68 ff 55 10 f0       	push   $0xf01055ff
f0101217:	68 ba 54 10 f0       	push   $0xf01054ba
f010121c:	68 9d 00 00 00       	push   $0x9d
f0101221:	68 49 54 10 f0       	push   $0xf0105449
f0101226:	e8 03 ef ff ff       	call   f010012e <_panic>
	assert(allocate_frame(&pp1) == 0);
f010122b:	83 ec 0c             	sub    $0xc,%esp
f010122e:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101231:	50                   	push   %eax
f0101232:	e8 bb 10 00 00       	call   f01022f2 <allocate_frame>
f0101237:	83 c4 10             	add    $0x10,%esp
f010123a:	85 c0                	test   %eax,%eax
f010123c:	74 19                	je     f0101257 <page_check+0x72>
f010123e:	68 19 56 10 f0       	push   $0xf0105619
f0101243:	68 ba 54 10 f0       	push   $0xf01054ba
f0101248:	68 9e 00 00 00       	push   $0x9e
f010124d:	68 49 54 10 f0       	push   $0xf0105449
f0101252:	e8 d7 ee ff ff       	call   f010012e <_panic>
	assert(allocate_frame(&pp2) == 0);
f0101257:	83 ec 0c             	sub    $0xc,%esp
f010125a:	8d 45 e8             	lea    -0x18(%ebp),%eax
f010125d:	50                   	push   %eax
f010125e:	e8 8f 10 00 00       	call   f01022f2 <allocate_frame>
f0101263:	83 c4 10             	add    $0x10,%esp
f0101266:	85 c0                	test   %eax,%eax
f0101268:	74 19                	je     f0101283 <page_check+0x9e>
f010126a:	68 33 56 10 f0       	push   $0xf0105633
f010126f:	68 ba 54 10 f0       	push   $0xf01054ba
f0101274:	68 9f 00 00 00       	push   $0x9f
f0101279:	68 49 54 10 f0       	push   $0xf0105449
f010127e:	e8 ab ee ff ff       	call   f010012e <_panic>

	assert(pp0);
f0101283:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101286:	85 c0                	test   %eax,%eax
f0101288:	75 19                	jne    f01012a3 <page_check+0xbe>
f010128a:	68 4d 56 10 f0       	push   $0xf010564d
f010128f:	68 ba 54 10 f0       	push   $0xf01054ba
f0101294:	68 a1 00 00 00       	push   $0xa1
f0101299:	68 49 54 10 f0       	push   $0xf0105449
f010129e:	e8 8b ee ff ff       	call   f010012e <_panic>
	assert(pp1 && pp1 != pp0);
f01012a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01012a6:	85 c0                	test   %eax,%eax
f01012a8:	74 0a                	je     f01012b4 <page_check+0xcf>
f01012aa:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01012ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01012b0:	39 c2                	cmp    %eax,%edx
f01012b2:	75 19                	jne    f01012cd <page_check+0xe8>
f01012b4:	68 51 56 10 f0       	push   $0xf0105651
f01012b9:	68 ba 54 10 f0       	push   $0xf01054ba
f01012be:	68 a2 00 00 00       	push   $0xa2
f01012c3:	68 49 54 10 f0       	push   $0xf0105449
f01012c8:	e8 61 ee ff ff       	call   f010012e <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01012cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01012d0:	85 c0                	test   %eax,%eax
f01012d2:	74 14                	je     f01012e8 <page_check+0x103>
f01012d4:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01012d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01012da:	39 c2                	cmp    %eax,%edx
f01012dc:	74 0a                	je     f01012e8 <page_check+0x103>
f01012de:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01012e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01012e4:	39 c2                	cmp    %eax,%edx
f01012e6:	75 19                	jne    f0101301 <page_check+0x11c>
f01012e8:	68 64 56 10 f0       	push   $0xf0105664
f01012ed:	68 ba 54 10 f0       	push   $0xf01054ba
f01012f2:	68 a3 00 00 00       	push   $0xa3
f01012f7:	68 49 54 10 f0       	push   $0xf0105449
f01012fc:	e8 2d ee ff ff       	call   f010012e <_panic>

	// temporarily steal the rest of the free frames_info
	fl = free_frame_list;
f0101301:	a1 78 e7 14 f0       	mov    0xf014e778,%eax
f0101306:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	LIST_INIT(&free_frame_list);
f0101309:	c7 05 78 e7 14 f0 00 	movl   $0x0,0xf014e778
f0101310:	00 00 00 

	// should be no free memory
	assert(allocate_frame(&pp) == E_NO_MEM);
f0101313:	83 ec 0c             	sub    $0xc,%esp
f0101316:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101319:	50                   	push   %eax
f010131a:	e8 d3 0f 00 00       	call   f01022f2 <allocate_frame>
f010131f:	83 c4 10             	add    $0x10,%esp
f0101322:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101325:	74 19                	je     f0101340 <page_check+0x15b>
f0101327:	68 84 56 10 f0       	push   $0xf0105684
f010132c:	68 ba 54 10 f0       	push   $0xf01054ba
f0101331:	68 aa 00 00 00       	push   $0xaa
f0101336:	68 49 54 10 f0       	push   $0xf0105449
f010133b:	e8 ee ed ff ff       	call   f010012e <_panic>

	// there is no free memory, so we can't allocate a page table 
	assert(map_frame(ptr_page_directory, pp1, 0x0, 0) < 0);
f0101340:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0101343:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0101348:	6a 00                	push   $0x0
f010134a:	6a 00                	push   $0x0
f010134c:	52                   	push   %edx
f010134d:	50                   	push   %eax
f010134e:	e8 ac 11 00 00       	call   f01024ff <map_frame>
f0101353:	83 c4 10             	add    $0x10,%esp
f0101356:	85 c0                	test   %eax,%eax
f0101358:	78 19                	js     f0101373 <page_check+0x18e>
f010135a:	68 a4 56 10 f0       	push   $0xf01056a4
f010135f:	68 ba 54 10 f0       	push   $0xf01054ba
f0101364:	68 ad 00 00 00       	push   $0xad
f0101369:	68 49 54 10 f0       	push   $0xf0105449
f010136e:	e8 bb ed ff ff       	call   f010012e <_panic>

	// free pp0 and try again: pp0 should be used for page table
	free_frame(pp0);
f0101373:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101376:	83 ec 0c             	sub    $0xc,%esp
f0101379:	50                   	push   %eax
f010137a:	e8 da 0f 00 00       	call   f0102359 <free_frame>
f010137f:	83 c4 10             	add    $0x10,%esp
	assert(map_frame(ptr_page_directory, pp1, 0x0, 0) == 0);
f0101382:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0101385:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f010138a:	6a 00                	push   $0x0
f010138c:	6a 00                	push   $0x0
f010138e:	52                   	push   %edx
f010138f:	50                   	push   %eax
f0101390:	e8 6a 11 00 00       	call   f01024ff <map_frame>
f0101395:	83 c4 10             	add    $0x10,%esp
f0101398:	85 c0                	test   %eax,%eax
f010139a:	74 19                	je     f01013b5 <page_check+0x1d0>
f010139c:	68 d4 56 10 f0       	push   $0xf01056d4
f01013a1:	68 ba 54 10 f0       	push   $0xf01054ba
f01013a6:	68 b1 00 00 00       	push   $0xb1
f01013ab:	68 49 54 10 f0       	push   $0xf0105449
f01013b0:	e8 79 ed ff ff       	call   f010012e <_panic>
	assert(EXTRACT_ADDRESS(ptr_page_directory[0]) == to_physical_address(pp0));
f01013b5:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f01013ba:	8b 00                	mov    (%eax),%eax
f01013bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01013c1:	89 c3                	mov    %eax,%ebx
f01013c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01013c6:	83 ec 0c             	sub    $0xc,%esp
f01013c9:	50                   	push   %eax
f01013ca:	e8 05 fa ff ff       	call   f0100dd4 <to_physical_address>
f01013cf:	83 c4 10             	add    $0x10,%esp
f01013d2:	39 c3                	cmp    %eax,%ebx
f01013d4:	74 19                	je     f01013ef <page_check+0x20a>
f01013d6:	68 04 57 10 f0       	push   $0xf0105704
f01013db:	68 ba 54 10 f0       	push   $0xf01054ba
f01013e0:	68 b2 00 00 00       	push   $0xb2
f01013e5:	68 49 54 10 f0       	push   $0xf0105449
f01013ea:	e8 3f ed ff ff       	call   f010012e <_panic>
	assert(check_va2pa(ptr_page_directory, 0x0) == to_physical_address(pp1));
f01013ef:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f01013f4:	83 ec 08             	sub    $0x8,%esp
f01013f7:	6a 00                	push   $0x0
f01013f9:	50                   	push   %eax
f01013fa:	e8 20 fd ff ff       	call   f010111f <check_va2pa>
f01013ff:	83 c4 10             	add    $0x10,%esp
f0101402:	89 c3                	mov    %eax,%ebx
f0101404:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101407:	83 ec 0c             	sub    $0xc,%esp
f010140a:	50                   	push   %eax
f010140b:	e8 c4 f9 ff ff       	call   f0100dd4 <to_physical_address>
f0101410:	83 c4 10             	add    $0x10,%esp
f0101413:	39 c3                	cmp    %eax,%ebx
f0101415:	74 19                	je     f0101430 <page_check+0x24b>
f0101417:	68 48 57 10 f0       	push   $0xf0105748
f010141c:	68 ba 54 10 f0       	push   $0xf01054ba
f0101421:	68 b3 00 00 00       	push   $0xb3
f0101426:	68 49 54 10 f0       	push   $0xf0105449
f010142b:	e8 fe ec ff ff       	call   f010012e <_panic>
	assert(pp1->references == 1);
f0101430:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101433:	8b 40 08             	mov    0x8(%eax),%eax
f0101436:	66 83 f8 01          	cmp    $0x1,%ax
f010143a:	74 19                	je     f0101455 <page_check+0x270>
f010143c:	68 89 57 10 f0       	push   $0xf0105789
f0101441:	68 ba 54 10 f0       	push   $0xf01054ba
f0101446:	68 b4 00 00 00       	push   $0xb4
f010144b:	68 49 54 10 f0       	push   $0xf0105449
f0101450:	e8 d9 ec ff ff       	call   f010012e <_panic>
	assert(pp0->references == 1);
f0101455:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101458:	8b 40 08             	mov    0x8(%eax),%eax
f010145b:	66 83 f8 01          	cmp    $0x1,%ax
f010145f:	74 19                	je     f010147a <page_check+0x295>
f0101461:	68 9e 57 10 f0       	push   $0xf010579e
f0101466:	68 ba 54 10 f0       	push   $0xf01054ba
f010146b:	68 b5 00 00 00       	push   $0xb5
f0101470:	68 49 54 10 f0       	push   $0xf0105449
f0101475:	e8 b4 ec ff ff       	call   f010012e <_panic>

	// should be able to map pp2 at PAGE_SIZE because pp0 is already allocated for page table
	assert(map_frame(ptr_page_directory, pp2, (void*) PAGE_SIZE, 0) == 0);
f010147a:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010147d:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0101482:	6a 00                	push   $0x0
f0101484:	68 00 10 00 00       	push   $0x1000
f0101489:	52                   	push   %edx
f010148a:	50                   	push   %eax
f010148b:	e8 6f 10 00 00       	call   f01024ff <map_frame>
f0101490:	83 c4 10             	add    $0x10,%esp
f0101493:	85 c0                	test   %eax,%eax
f0101495:	74 19                	je     f01014b0 <page_check+0x2cb>
f0101497:	68 b4 57 10 f0       	push   $0xf01057b4
f010149c:	68 ba 54 10 f0       	push   $0xf01054ba
f01014a1:	68 b8 00 00 00       	push   $0xb8
f01014a6:	68 49 54 10 f0       	push   $0xf0105449
f01014ab:	e8 7e ec ff ff       	call   f010012e <_panic>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == to_physical_address(pp2));
f01014b0:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f01014b5:	83 ec 08             	sub    $0x8,%esp
f01014b8:	68 00 10 00 00       	push   $0x1000
f01014bd:	50                   	push   %eax
f01014be:	e8 5c fc ff ff       	call   f010111f <check_va2pa>
f01014c3:	83 c4 10             	add    $0x10,%esp
f01014c6:	89 c3                	mov    %eax,%ebx
f01014c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01014cb:	83 ec 0c             	sub    $0xc,%esp
f01014ce:	50                   	push   %eax
f01014cf:	e8 00 f9 ff ff       	call   f0100dd4 <to_physical_address>
f01014d4:	83 c4 10             	add    $0x10,%esp
f01014d7:	39 c3                	cmp    %eax,%ebx
f01014d9:	74 19                	je     f01014f4 <page_check+0x30f>
f01014db:	68 f4 57 10 f0       	push   $0xf01057f4
f01014e0:	68 ba 54 10 f0       	push   $0xf01054ba
f01014e5:	68 b9 00 00 00       	push   $0xb9
f01014ea:	68 49 54 10 f0       	push   $0xf0105449
f01014ef:	e8 3a ec ff ff       	call   f010012e <_panic>
	assert(pp2->references == 1);
f01014f4:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01014f7:	8b 40 08             	mov    0x8(%eax),%eax
f01014fa:	66 83 f8 01          	cmp    $0x1,%ax
f01014fe:	74 19                	je     f0101519 <page_check+0x334>
f0101500:	68 3b 58 10 f0       	push   $0xf010583b
f0101505:	68 ba 54 10 f0       	push   $0xf01054ba
f010150a:	68 ba 00 00 00       	push   $0xba
f010150f:	68 49 54 10 f0       	push   $0xf0105449
f0101514:	e8 15 ec ff ff       	call   f010012e <_panic>

	// should be no free memory
	assert(allocate_frame(&pp) == E_NO_MEM);
f0101519:	83 ec 0c             	sub    $0xc,%esp
f010151c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010151f:	50                   	push   %eax
f0101520:	e8 cd 0d 00 00       	call   f01022f2 <allocate_frame>
f0101525:	83 c4 10             	add    $0x10,%esp
f0101528:	83 f8 fc             	cmp    $0xfffffffc,%eax
f010152b:	74 19                	je     f0101546 <page_check+0x361>
f010152d:	68 84 56 10 f0       	push   $0xf0105684
f0101532:	68 ba 54 10 f0       	push   $0xf01054ba
f0101537:	68 bd 00 00 00       	push   $0xbd
f010153c:	68 49 54 10 f0       	push   $0xf0105449
f0101541:	e8 e8 eb ff ff       	call   f010012e <_panic>

	// should be able to map pp2 at PAGE_SIZE because it's already there
	assert(map_frame(ptr_page_directory, pp2, (void*) PAGE_SIZE, 0) == 0);
f0101546:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101549:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f010154e:	6a 00                	push   $0x0
f0101550:	68 00 10 00 00       	push   $0x1000
f0101555:	52                   	push   %edx
f0101556:	50                   	push   %eax
f0101557:	e8 a3 0f 00 00       	call   f01024ff <map_frame>
f010155c:	83 c4 10             	add    $0x10,%esp
f010155f:	85 c0                	test   %eax,%eax
f0101561:	74 19                	je     f010157c <page_check+0x397>
f0101563:	68 b4 57 10 f0       	push   $0xf01057b4
f0101568:	68 ba 54 10 f0       	push   $0xf01054ba
f010156d:	68 c0 00 00 00       	push   $0xc0
f0101572:	68 49 54 10 f0       	push   $0xf0105449
f0101577:	e8 b2 eb ff ff       	call   f010012e <_panic>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == to_physical_address(pp2));
f010157c:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0101581:	83 ec 08             	sub    $0x8,%esp
f0101584:	68 00 10 00 00       	push   $0x1000
f0101589:	50                   	push   %eax
f010158a:	e8 90 fb ff ff       	call   f010111f <check_va2pa>
f010158f:	83 c4 10             	add    $0x10,%esp
f0101592:	89 c3                	mov    %eax,%ebx
f0101594:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101597:	83 ec 0c             	sub    $0xc,%esp
f010159a:	50                   	push   %eax
f010159b:	e8 34 f8 ff ff       	call   f0100dd4 <to_physical_address>
f01015a0:	83 c4 10             	add    $0x10,%esp
f01015a3:	39 c3                	cmp    %eax,%ebx
f01015a5:	74 19                	je     f01015c0 <page_check+0x3db>
f01015a7:	68 f4 57 10 f0       	push   $0xf01057f4
f01015ac:	68 ba 54 10 f0       	push   $0xf01054ba
f01015b1:	68 c1 00 00 00       	push   $0xc1
f01015b6:	68 49 54 10 f0       	push   $0xf0105449
f01015bb:	e8 6e eb ff ff       	call   f010012e <_panic>
	assert(pp2->references == 1);
f01015c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01015c3:	8b 40 08             	mov    0x8(%eax),%eax
f01015c6:	66 83 f8 01          	cmp    $0x1,%ax
f01015ca:	74 19                	je     f01015e5 <page_check+0x400>
f01015cc:	68 3b 58 10 f0       	push   $0xf010583b
f01015d1:	68 ba 54 10 f0       	push   $0xf01054ba
f01015d6:	68 c2 00 00 00       	push   $0xc2
f01015db:	68 49 54 10 f0       	push   $0xf0105449
f01015e0:	e8 49 eb ff ff       	call   f010012e <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in map_frame
	assert(allocate_frame(&pp) == E_NO_MEM);
f01015e5:	83 ec 0c             	sub    $0xc,%esp
f01015e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01015eb:	50                   	push   %eax
f01015ec:	e8 01 0d 00 00       	call   f01022f2 <allocate_frame>
f01015f1:	83 c4 10             	add    $0x10,%esp
f01015f4:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01015f7:	74 19                	je     f0101612 <page_check+0x42d>
f01015f9:	68 84 56 10 f0       	push   $0xf0105684
f01015fe:	68 ba 54 10 f0       	push   $0xf01054ba
f0101603:	68 c6 00 00 00       	push   $0xc6
f0101608:	68 49 54 10 f0       	push   $0xf0105449
f010160d:	e8 1c eb ff ff       	call   f010012e <_panic>

	// should not be able to map at PTSIZE because need free frame for page table
	assert(map_frame(ptr_page_directory, pp0, (void*) PTSIZE, 0) < 0);
f0101612:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101615:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f010161a:	6a 00                	push   $0x0
f010161c:	68 00 00 40 00       	push   $0x400000
f0101621:	52                   	push   %edx
f0101622:	50                   	push   %eax
f0101623:	e8 d7 0e 00 00       	call   f01024ff <map_frame>
f0101628:	83 c4 10             	add    $0x10,%esp
f010162b:	85 c0                	test   %eax,%eax
f010162d:	78 19                	js     f0101648 <page_check+0x463>
f010162f:	68 50 58 10 f0       	push   $0xf0105850
f0101634:	68 ba 54 10 f0       	push   $0xf01054ba
f0101639:	68 c9 00 00 00       	push   $0xc9
f010163e:	68 49 54 10 f0       	push   $0xf0105449
f0101643:	e8 e6 ea ff ff       	call   f010012e <_panic>

	// insert pp1 at PAGE_SIZE (replacing pp2)
	assert(map_frame(ptr_page_directory, pp1, (void*) PAGE_SIZE, 0) == 0);
f0101648:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010164b:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0101650:	6a 00                	push   $0x0
f0101652:	68 00 10 00 00       	push   $0x1000
f0101657:	52                   	push   %edx
f0101658:	50                   	push   %eax
f0101659:	e8 a1 0e 00 00       	call   f01024ff <map_frame>
f010165e:	83 c4 10             	add    $0x10,%esp
f0101661:	85 c0                	test   %eax,%eax
f0101663:	74 19                	je     f010167e <page_check+0x499>
f0101665:	68 8c 58 10 f0       	push   $0xf010588c
f010166a:	68 ba 54 10 f0       	push   $0xf01054ba
f010166f:	68 cc 00 00 00       	push   $0xcc
f0101674:	68 49 54 10 f0       	push   $0xf0105449
f0101679:	e8 b0 ea ff ff       	call   f010012e <_panic>

	// should have pp1 at both 0 and PAGE_SIZE, pp2 nowhere, ...
	assert(check_va2pa(ptr_page_directory, 0) == to_physical_address(pp1));
f010167e:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0101683:	83 ec 08             	sub    $0x8,%esp
f0101686:	6a 00                	push   $0x0
f0101688:	50                   	push   %eax
f0101689:	e8 91 fa ff ff       	call   f010111f <check_va2pa>
f010168e:	83 c4 10             	add    $0x10,%esp
f0101691:	89 c3                	mov    %eax,%ebx
f0101693:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101696:	83 ec 0c             	sub    $0xc,%esp
f0101699:	50                   	push   %eax
f010169a:	e8 35 f7 ff ff       	call   f0100dd4 <to_physical_address>
f010169f:	83 c4 10             	add    $0x10,%esp
f01016a2:	39 c3                	cmp    %eax,%ebx
f01016a4:	74 19                	je     f01016bf <page_check+0x4da>
f01016a6:	68 cc 58 10 f0       	push   $0xf01058cc
f01016ab:	68 ba 54 10 f0       	push   $0xf01054ba
f01016b0:	68 cf 00 00 00       	push   $0xcf
f01016b5:	68 49 54 10 f0       	push   $0xf0105449
f01016ba:	e8 6f ea ff ff       	call   f010012e <_panic>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == to_physical_address(pp1));
f01016bf:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f01016c4:	83 ec 08             	sub    $0x8,%esp
f01016c7:	68 00 10 00 00       	push   $0x1000
f01016cc:	50                   	push   %eax
f01016cd:	e8 4d fa ff ff       	call   f010111f <check_va2pa>
f01016d2:	83 c4 10             	add    $0x10,%esp
f01016d5:	89 c3                	mov    %eax,%ebx
f01016d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01016da:	83 ec 0c             	sub    $0xc,%esp
f01016dd:	50                   	push   %eax
f01016de:	e8 f1 f6 ff ff       	call   f0100dd4 <to_physical_address>
f01016e3:	83 c4 10             	add    $0x10,%esp
f01016e6:	39 c3                	cmp    %eax,%ebx
f01016e8:	74 19                	je     f0101703 <page_check+0x51e>
f01016ea:	68 0c 59 10 f0       	push   $0xf010590c
f01016ef:	68 ba 54 10 f0       	push   $0xf01054ba
f01016f4:	68 d0 00 00 00       	push   $0xd0
f01016f9:	68 49 54 10 f0       	push   $0xf0105449
f01016fe:	e8 2b ea ff ff       	call   f010012e <_panic>
	// ... and ref counts should reflect this
	assert(pp1->references == 2);
f0101703:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101706:	8b 40 08             	mov    0x8(%eax),%eax
f0101709:	66 83 f8 02          	cmp    $0x2,%ax
f010170d:	74 19                	je     f0101728 <page_check+0x543>
f010170f:	68 53 59 10 f0       	push   $0xf0105953
f0101714:	68 ba 54 10 f0       	push   $0xf01054ba
f0101719:	68 d2 00 00 00       	push   $0xd2
f010171e:	68 49 54 10 f0       	push   $0xf0105449
f0101723:	e8 06 ea ff ff       	call   f010012e <_panic>
	assert(pp2->references == 0);
f0101728:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010172b:	8b 40 08             	mov    0x8(%eax),%eax
f010172e:	66 85 c0             	test   %ax,%ax
f0101731:	74 19                	je     f010174c <page_check+0x567>
f0101733:	68 68 59 10 f0       	push   $0xf0105968
f0101738:	68 ba 54 10 f0       	push   $0xf01054ba
f010173d:	68 d3 00 00 00       	push   $0xd3
f0101742:	68 49 54 10 f0       	push   $0xf0105449
f0101747:	e8 e2 e9 ff ff       	call   f010012e <_panic>

	// pp2 should be returned by allocate_frame
	assert(allocate_frame(&pp) == 0 && pp == pp2);
f010174c:	83 ec 0c             	sub    $0xc,%esp
f010174f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101752:	50                   	push   %eax
f0101753:	e8 9a 0b 00 00       	call   f01022f2 <allocate_frame>
f0101758:	83 c4 10             	add    $0x10,%esp
f010175b:	85 c0                	test   %eax,%eax
f010175d:	75 0a                	jne    f0101769 <page_check+0x584>
f010175f:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101762:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101765:	39 c2                	cmp    %eax,%edx
f0101767:	74 19                	je     f0101782 <page_check+0x59d>
f0101769:	68 80 59 10 f0       	push   $0xf0105980
f010176e:	68 ba 54 10 f0       	push   $0xf01054ba
f0101773:	68 d6 00 00 00       	push   $0xd6
f0101778:	68 49 54 10 f0       	push   $0xf0105449
f010177d:	e8 ac e9 ff ff       	call   f010012e <_panic>

	// unmapping pp1 at 0 should keep pp1 at PAGE_SIZE
	unmap_frame(ptr_page_directory, 0x0);
f0101782:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0101787:	83 ec 08             	sub    $0x8,%esp
f010178a:	6a 00                	push   $0x0
f010178c:	50                   	push   %eax
f010178d:	e8 8b 0e 00 00       	call   f010261d <unmap_frame>
f0101792:	83 c4 10             	add    $0x10,%esp
	assert(check_va2pa(ptr_page_directory, 0x0) == ~0);
f0101795:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f010179a:	83 ec 08             	sub    $0x8,%esp
f010179d:	6a 00                	push   $0x0
f010179f:	50                   	push   %eax
f01017a0:	e8 7a f9 ff ff       	call   f010111f <check_va2pa>
f01017a5:	83 c4 10             	add    $0x10,%esp
f01017a8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01017ab:	74 19                	je     f01017c6 <page_check+0x5e1>
f01017ad:	68 a8 59 10 f0       	push   $0xf01059a8
f01017b2:	68 ba 54 10 f0       	push   $0xf01054ba
f01017b7:	68 da 00 00 00       	push   $0xda
f01017bc:	68 49 54 10 f0       	push   $0xf0105449
f01017c1:	e8 68 e9 ff ff       	call   f010012e <_panic>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == to_physical_address(pp1));
f01017c6:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f01017cb:	83 ec 08             	sub    $0x8,%esp
f01017ce:	68 00 10 00 00       	push   $0x1000
f01017d3:	50                   	push   %eax
f01017d4:	e8 46 f9 ff ff       	call   f010111f <check_va2pa>
f01017d9:	83 c4 10             	add    $0x10,%esp
f01017dc:	89 c3                	mov    %eax,%ebx
f01017de:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01017e1:	83 ec 0c             	sub    $0xc,%esp
f01017e4:	50                   	push   %eax
f01017e5:	e8 ea f5 ff ff       	call   f0100dd4 <to_physical_address>
f01017ea:	83 c4 10             	add    $0x10,%esp
f01017ed:	39 c3                	cmp    %eax,%ebx
f01017ef:	74 19                	je     f010180a <page_check+0x625>
f01017f1:	68 0c 59 10 f0       	push   $0xf010590c
f01017f6:	68 ba 54 10 f0       	push   $0xf01054ba
f01017fb:	68 db 00 00 00       	push   $0xdb
f0101800:	68 49 54 10 f0       	push   $0xf0105449
f0101805:	e8 24 e9 ff ff       	call   f010012e <_panic>
	assert(pp1->references == 1);
f010180a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010180d:	8b 40 08             	mov    0x8(%eax),%eax
f0101810:	66 83 f8 01          	cmp    $0x1,%ax
f0101814:	74 19                	je     f010182f <page_check+0x64a>
f0101816:	68 89 57 10 f0       	push   $0xf0105789
f010181b:	68 ba 54 10 f0       	push   $0xf01054ba
f0101820:	68 dc 00 00 00       	push   $0xdc
f0101825:	68 49 54 10 f0       	push   $0xf0105449
f010182a:	e8 ff e8 ff ff       	call   f010012e <_panic>
	assert(pp2->references == 0);
f010182f:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101832:	8b 40 08             	mov    0x8(%eax),%eax
f0101835:	66 85 c0             	test   %ax,%ax
f0101838:	74 19                	je     f0101853 <page_check+0x66e>
f010183a:	68 68 59 10 f0       	push   $0xf0105968
f010183f:	68 ba 54 10 f0       	push   $0xf01054ba
f0101844:	68 dd 00 00 00       	push   $0xdd
f0101849:	68 49 54 10 f0       	push   $0xf0105449
f010184e:	e8 db e8 ff ff       	call   f010012e <_panic>

	// unmapping pp1 at PAGE_SIZE should free it
	unmap_frame(ptr_page_directory, (void*) PAGE_SIZE);
f0101853:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0101858:	83 ec 08             	sub    $0x8,%esp
f010185b:	68 00 10 00 00       	push   $0x1000
f0101860:	50                   	push   %eax
f0101861:	e8 b7 0d 00 00       	call   f010261d <unmap_frame>
f0101866:	83 c4 10             	add    $0x10,%esp
	assert(check_va2pa(ptr_page_directory, 0x0) == ~0);
f0101869:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f010186e:	83 ec 08             	sub    $0x8,%esp
f0101871:	6a 00                	push   $0x0
f0101873:	50                   	push   %eax
f0101874:	e8 a6 f8 ff ff       	call   f010111f <check_va2pa>
f0101879:	83 c4 10             	add    $0x10,%esp
f010187c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010187f:	74 19                	je     f010189a <page_check+0x6b5>
f0101881:	68 a8 59 10 f0       	push   $0xf01059a8
f0101886:	68 ba 54 10 f0       	push   $0xf01054ba
f010188b:	68 e1 00 00 00       	push   $0xe1
f0101890:	68 49 54 10 f0       	push   $0xf0105449
f0101895:	e8 94 e8 ff ff       	call   f010012e <_panic>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == ~0);
f010189a:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f010189f:	83 ec 08             	sub    $0x8,%esp
f01018a2:	68 00 10 00 00       	push   $0x1000
f01018a7:	50                   	push   %eax
f01018a8:	e8 72 f8 ff ff       	call   f010111f <check_va2pa>
f01018ad:	83 c4 10             	add    $0x10,%esp
f01018b0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01018b3:	74 19                	je     f01018ce <page_check+0x6e9>
f01018b5:	68 d4 59 10 f0       	push   $0xf01059d4
f01018ba:	68 ba 54 10 f0       	push   $0xf01054ba
f01018bf:	68 e2 00 00 00       	push   $0xe2
f01018c4:	68 49 54 10 f0       	push   $0xf0105449
f01018c9:	e8 60 e8 ff ff       	call   f010012e <_panic>
	assert(pp1->references == 0);
f01018ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01018d1:	8b 40 08             	mov    0x8(%eax),%eax
f01018d4:	66 85 c0             	test   %ax,%ax
f01018d7:	74 19                	je     f01018f2 <page_check+0x70d>
f01018d9:	68 05 5a 10 f0       	push   $0xf0105a05
f01018de:	68 ba 54 10 f0       	push   $0xf01054ba
f01018e3:	68 e3 00 00 00       	push   $0xe3
f01018e8:	68 49 54 10 f0       	push   $0xf0105449
f01018ed:	e8 3c e8 ff ff       	call   f010012e <_panic>
	assert(pp2->references == 0);
f01018f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01018f5:	8b 40 08             	mov    0x8(%eax),%eax
f01018f8:	66 85 c0             	test   %ax,%ax
f01018fb:	74 19                	je     f0101916 <page_check+0x731>
f01018fd:	68 68 59 10 f0       	push   $0xf0105968
f0101902:	68 ba 54 10 f0       	push   $0xf01054ba
f0101907:	68 e4 00 00 00       	push   $0xe4
f010190c:	68 49 54 10 f0       	push   $0xf0105449
f0101911:	e8 18 e8 ff ff       	call   f010012e <_panic>

	// so it should be returned by allocate_frame
	assert(allocate_frame(&pp) == 0 && pp == pp1);
f0101916:	83 ec 0c             	sub    $0xc,%esp
f0101919:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010191c:	50                   	push   %eax
f010191d:	e8 d0 09 00 00       	call   f01022f2 <allocate_frame>
f0101922:	83 c4 10             	add    $0x10,%esp
f0101925:	85 c0                	test   %eax,%eax
f0101927:	75 0a                	jne    f0101933 <page_check+0x74e>
f0101929:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010192c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010192f:	39 c2                	cmp    %eax,%edx
f0101931:	74 19                	je     f010194c <page_check+0x767>
f0101933:	68 1c 5a 10 f0       	push   $0xf0105a1c
f0101938:	68 ba 54 10 f0       	push   $0xf01054ba
f010193d:	68 e7 00 00 00       	push   $0xe7
f0101942:	68 49 54 10 f0       	push   $0xf0105449
f0101947:	e8 e2 e7 ff ff       	call   f010012e <_panic>

	// should be no free memory
	assert(allocate_frame(&pp) == E_NO_MEM);
f010194c:	83 ec 0c             	sub    $0xc,%esp
f010194f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101952:	50                   	push   %eax
f0101953:	e8 9a 09 00 00       	call   f01022f2 <allocate_frame>
f0101958:	83 c4 10             	add    $0x10,%esp
f010195b:	83 f8 fc             	cmp    $0xfffffffc,%eax
f010195e:	74 19                	je     f0101979 <page_check+0x794>
f0101960:	68 84 56 10 f0       	push   $0xf0105684
f0101965:	68 ba 54 10 f0       	push   $0xf01054ba
f010196a:	68 ea 00 00 00       	push   $0xea
f010196f:	68 49 54 10 f0       	push   $0xf0105449
f0101974:	e8 b5 e7 ff ff       	call   f010012e <_panic>

	// forcibly take pp0 back
	assert(EXTRACT_ADDRESS(ptr_page_directory[0]) == to_physical_address(pp0));
f0101979:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f010197e:	8b 00                	mov    (%eax),%eax
f0101980:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101985:	89 c3                	mov    %eax,%ebx
f0101987:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010198a:	83 ec 0c             	sub    $0xc,%esp
f010198d:	50                   	push   %eax
f010198e:	e8 41 f4 ff ff       	call   f0100dd4 <to_physical_address>
f0101993:	83 c4 10             	add    $0x10,%esp
f0101996:	39 c3                	cmp    %eax,%ebx
f0101998:	74 19                	je     f01019b3 <page_check+0x7ce>
f010199a:	68 04 57 10 f0       	push   $0xf0105704
f010199f:	68 ba 54 10 f0       	push   $0xf01054ba
f01019a4:	68 ed 00 00 00       	push   $0xed
f01019a9:	68 49 54 10 f0       	push   $0xf0105449
f01019ae:	e8 7b e7 ff ff       	call   f010012e <_panic>
	ptr_page_directory[0] = 0;
f01019b3:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f01019b8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->references == 1);
f01019be:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01019c1:	8b 40 08             	mov    0x8(%eax),%eax
f01019c4:	66 83 f8 01          	cmp    $0x1,%ax
f01019c8:	74 19                	je     f01019e3 <page_check+0x7fe>
f01019ca:	68 9e 57 10 f0       	push   $0xf010579e
f01019cf:	68 ba 54 10 f0       	push   $0xf01054ba
f01019d4:	68 ef 00 00 00       	push   $0xef
f01019d9:	68 49 54 10 f0       	push   $0xf0105449
f01019de:	e8 4b e7 ff ff       	call   f010012e <_panic>
	pp0->references = 0;
f01019e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01019e6:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)

	// give free list back
	free_frame_list = fl;
f01019ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01019ef:	a3 78 e7 14 f0       	mov    %eax,0xf014e778

	// free the frames_info we took
	free_frame(pp0);
f01019f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01019f7:	83 ec 0c             	sub    $0xc,%esp
f01019fa:	50                   	push   %eax
f01019fb:	e8 59 09 00 00       	call   f0102359 <free_frame>
f0101a00:	83 c4 10             	add    $0x10,%esp
	free_frame(pp1);
f0101a03:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101a06:	83 ec 0c             	sub    $0xc,%esp
f0101a09:	50                   	push   %eax
f0101a0a:	e8 4a 09 00 00       	call   f0102359 <free_frame>
f0101a0f:	83 c4 10             	add    $0x10,%esp
	free_frame(pp2);
f0101a12:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101a15:	83 ec 0c             	sub    $0xc,%esp
f0101a18:	50                   	push   %eax
f0101a19:	e8 3b 09 00 00       	call   f0102359 <free_frame>
f0101a1e:	83 c4 10             	add    $0x10,%esp

	cprintf("page_check() succeeded!\n");
f0101a21:	83 ec 0c             	sub    $0xc,%esp
f0101a24:	68 42 5a 10 f0       	push   $0xf0105a42
f0101a29:	e8 79 15 00 00       	call   f0102fa7 <cprintf>
f0101a2e:	83 c4 10             	add    $0x10,%esp
}
f0101a31:	90                   	nop
f0101a32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101a35:	c9                   	leave  
f0101a36:	c3                   	ret    

f0101a37 <turn_on_paging>:

void turn_on_paging()
{
f0101a37:	55                   	push   %ebp
f0101a38:	89 e5                	mov    %esp,%ebp
f0101a3a:	83 ec 20             	sub    $0x20,%esp
	// mapping, even though we are turning on paging and reconfiguring
	// segmentation.

	// Map VA 0:4MB same as VA (KERNEL_BASE), i.e. to PA 0:4MB.
	// (Limits our kernel to <4MB)
	ptr_page_directory[0] = ptr_page_directory[PDX(KERNEL_BASE)];
f0101a3d:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0101a42:	8b 15 84 e7 14 f0    	mov    0xf014e784,%edx
f0101a48:	8b 92 00 0f 00 00    	mov    0xf00(%edx),%edx
f0101a4e:	89 10                	mov    %edx,(%eax)

	// Install page table.
	lcr3(phys_page_directory);
f0101a50:	a1 88 e7 14 f0       	mov    0xf014e788,%eax
f0101a55:	89 45 fc             	mov    %eax,-0x4(%ebp)
}

static __inline void
lcr3(uint32 val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0101a58:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0101a5b:	0f 22 d8             	mov    %eax,%cr3

static __inline uint32
rcr0(void)
{
	uint32 val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0101a5e:	0f 20 c0             	mov    %cr0,%eax
f0101a61:	89 45 f4             	mov    %eax,-0xc(%ebp)
	return val;
f0101a64:	8b 45 f4             	mov    -0xc(%ebp),%eax

	// Turn on paging.
	uint32 cr0;
	cr0 = rcr0();
f0101a67:	89 45 f8             	mov    %eax,-0x8(%ebp)
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_TS|CR0_EM|CR0_MP;
f0101a6a:	81 4d f8 2f 00 05 80 	orl    $0x8005002f,-0x8(%ebp)
	cr0 &= ~(CR0_TS|CR0_EM);
f0101a71:	83 65 f8 f3          	andl   $0xfffffff3,-0x8(%ebp)
f0101a75:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0101a78:	89 45 f0             	mov    %eax,-0x10(%ebp)
}

static __inline void
lcr0(uint32 val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0101a7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101a7e:	0f 22 c0             	mov    %eax,%cr0

	// Current mapping: KERNEL_BASE+x => x => x.
	// (x < 4MB so uses paging ptr_page_directory[0])

	// Reload all segment registers.
	asm volatile("lgdt gdt_pd");
f0101a81:	0f 01 15 30 b6 11 f0 	lgdtl  0xf011b630
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0101a88:	b8 23 00 00 00       	mov    $0x23,%eax
f0101a8d:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0101a8f:	b8 23 00 00 00       	mov    $0x23,%eax
f0101a94:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0101a96:	b8 10 00 00 00       	mov    $0x10,%eax
f0101a9b:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0101a9d:	b8 10 00 00 00       	mov    $0x10,%eax
f0101aa2:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0101aa4:	b8 10 00 00 00       	mov    $0x10,%eax
f0101aa9:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));  // reload cs
f0101aab:	ea b2 1a 10 f0 08 00 	ljmp   $0x8,$0xf0101ab2
	asm volatile("lldt %%ax" :: "a" (0));
f0101ab2:	b8 00 00 00 00       	mov    $0x0,%eax
f0101ab7:	0f 00 d0             	lldt   %ax

	// Final mapping: KERNEL_BASE + x => KERNEL_BASE + x => x.

	// This mapping was only used after paging was turned on but
	// before the segment registers were reloaded.
	ptr_page_directory[0] = 0;
f0101aba:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0101abf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// Flush the TLB for good measure, to kill the ptr_page_directory[0] mapping.
	lcr3(phys_page_directory);
f0101ac5:	a1 88 e7 14 f0       	mov    0xf014e788,%eax
f0101aca:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static __inline void
lcr3(uint32 val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0101acd:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101ad0:	0f 22 d8             	mov    %eax,%cr3
}
f0101ad3:	90                   	nop
f0101ad4:	c9                   	leave  
f0101ad5:	c3                   	ret    

f0101ad6 <setup_listing_to_all_page_tables_entries>:

void setup_listing_to_all_page_tables_entries()
{
f0101ad6:	55                   	push   %ebp
f0101ad7:	89 e5                	mov    %esp,%ebp
f0101ad9:	83 ec 18             	sub    $0x18,%esp
	//////////////////////////////////////////////////////////////////////
	// Recursively insert PD in itself as a page table, to form
	// a virtual page table at virtual address VPT.

	// Permissions: kernel RW, user NONE
	uint32 phys_frame_address = K_PHYSICAL_ADDRESS(ptr_page_directory);
f0101adc:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0101ae1:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101ae4:	81 7d f4 ff ff ff ef 	cmpl   $0xefffffff,-0xc(%ebp)
f0101aeb:	77 17                	ja     f0101b04 <setup_listing_to_all_page_tables_entries+0x2e>
f0101aed:	ff 75 f4             	pushl  -0xc(%ebp)
f0101af0:	68 18 54 10 f0       	push   $0xf0105418
f0101af5:	68 39 01 00 00       	push   $0x139
f0101afa:	68 49 54 10 f0       	push   $0xf0105449
f0101aff:	e8 2a e6 ff ff       	call   f010012e <_panic>
f0101b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101b07:	05 00 00 00 10       	add    $0x10000000,%eax
f0101b0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	ptr_page_directory[PDX(VPT)] = CONSTRUCT_ENTRY(phys_frame_address , PERM_PRESENT | PERM_WRITEABLE);
f0101b0f:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0101b14:	05 fc 0e 00 00       	add    $0xefc,%eax
f0101b19:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101b1c:	83 ca 03             	or     $0x3,%edx
f0101b1f:	89 10                	mov    %edx,(%eax)

	// same for UVPT
	//Permissions: kernel R, user R
	ptr_page_directory[PDX(UVPT)] = K_PHYSICAL_ADDRESS(ptr_page_directory)|PERM_USER|PERM_PRESENT;
f0101b21:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0101b26:	8d 90 f4 0e 00 00    	lea    0xef4(%eax),%edx
f0101b2c:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0101b31:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101b34:	81 7d ec ff ff ff ef 	cmpl   $0xefffffff,-0x14(%ebp)
f0101b3b:	77 17                	ja     f0101b54 <setup_listing_to_all_page_tables_entries+0x7e>
f0101b3d:	ff 75 ec             	pushl  -0x14(%ebp)
f0101b40:	68 18 54 10 f0       	push   $0xf0105418
f0101b45:	68 3e 01 00 00       	push   $0x13e
f0101b4a:	68 49 54 10 f0       	push   $0xf0105449
f0101b4f:	e8 da e5 ff ff       	call   f010012e <_panic>
f0101b54:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101b57:	05 00 00 00 10       	add    $0x10000000,%eax
f0101b5c:	83 c8 05             	or     $0x5,%eax
f0101b5f:	89 02                	mov    %eax,(%edx)

}
f0101b61:	90                   	nop
f0101b62:	c9                   	leave  
f0101b63:	c3                   	ret    

f0101b64 <envid2env>:
//   0 on success, -E_BAD_ENV on error.
//   On success, sets *penv to the environment.
//   On error, sets *penv to NULL.
//
int envid2env(int32  envid, struct Env **env_store, bool checkperm)
{
f0101b64:	55                   	push   %ebp
f0101b65:	89 e5                	mov    %esp,%ebp
f0101b67:	83 ec 10             	sub    $0x10,%esp
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0101b6a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0101b6e:	75 15                	jne    f0101b85 <envid2env+0x21>
		*env_store = curenv;
f0101b70:	8b 15 f0 de 14 f0    	mov    0xf014def0,%edx
f0101b76:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101b79:	89 10                	mov    %edx,(%eax)
		return 0;
f0101b7b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101b80:	e9 8c 00 00 00       	jmp    f0101c11 <envid2env+0xad>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0101b85:	8b 15 ec de 14 f0    	mov    0xf014deec,%edx
f0101b8b:	8b 45 08             	mov    0x8(%ebp),%eax
f0101b8e:	25 ff 03 00 00       	and    $0x3ff,%eax
f0101b93:	89 c1                	mov    %eax,%ecx
f0101b95:	89 c8                	mov    %ecx,%eax
f0101b97:	c1 e0 02             	shl    $0x2,%eax
f0101b9a:	01 c8                	add    %ecx,%eax
f0101b9c:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
f0101ba3:	01 c8                	add    %ecx,%eax
f0101ba5:	c1 e0 02             	shl    $0x2,%eax
f0101ba8:	01 d0                	add    %edx,%eax
f0101baa:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0101bad:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0101bb0:	8b 40 54             	mov    0x54(%eax),%eax
f0101bb3:	85 c0                	test   %eax,%eax
f0101bb5:	74 0b                	je     f0101bc2 <envid2env+0x5e>
f0101bb7:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0101bba:	8b 40 4c             	mov    0x4c(%eax),%eax
f0101bbd:	3b 45 08             	cmp    0x8(%ebp),%eax
f0101bc0:	74 10                	je     f0101bd2 <envid2env+0x6e>
		*env_store = 0;
f0101bc2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101bc5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0101bcb:	b8 02 00 00 00       	mov    $0x2,%eax
f0101bd0:	eb 3f                	jmp    f0101c11 <envid2env+0xad>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0101bd2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101bd6:	74 2c                	je     f0101c04 <envid2env+0xa0>
f0101bd8:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f0101bdd:	39 45 fc             	cmp    %eax,-0x4(%ebp)
f0101be0:	74 22                	je     f0101c04 <envid2env+0xa0>
f0101be2:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0101be5:	8b 50 50             	mov    0x50(%eax),%edx
f0101be8:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f0101bed:	8b 40 4c             	mov    0x4c(%eax),%eax
f0101bf0:	39 c2                	cmp    %eax,%edx
f0101bf2:	74 10                	je     f0101c04 <envid2env+0xa0>
		*env_store = 0;
f0101bf4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101bf7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0101bfd:	b8 02 00 00 00       	mov    $0x2,%eax
f0101c02:	eb 0d                	jmp    f0101c11 <envid2env+0xad>
	}

	*env_store = e;
f0101c04:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101c07:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0101c0a:	89 10                	mov    %edx,(%eax)
	return 0;
f0101c0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101c11:	c9                   	leave  
f0101c12:	c3                   	ret    

f0101c13 <to_frame_number>:
void	unmap_frame(uint32 *pgdir, void *va);
struct Frame_Info *get_frame_info(uint32 *ptr_page_directory, void *virtual_address, uint32 **ptr_page_table);
void decrement_references(struct Frame_Info* ptr_frame_info);

static inline uint32 to_frame_number(struct Frame_Info *ptr_frame_info)
{
f0101c13:	55                   	push   %ebp
f0101c14:	89 e5                	mov    %esp,%ebp
	return ptr_frame_info - frames_info;
f0101c16:	8b 45 08             	mov    0x8(%ebp),%eax
f0101c19:	8b 15 7c e7 14 f0    	mov    0xf014e77c,%edx
f0101c1f:	29 d0                	sub    %edx,%eax
f0101c21:	c1 f8 02             	sar    $0x2,%eax
f0101c24:	89 c2                	mov    %eax,%edx
f0101c26:	89 d0                	mov    %edx,%eax
f0101c28:	c1 e0 02             	shl    $0x2,%eax
f0101c2b:	01 d0                	add    %edx,%eax
f0101c2d:	c1 e0 02             	shl    $0x2,%eax
f0101c30:	01 d0                	add    %edx,%eax
f0101c32:	c1 e0 02             	shl    $0x2,%eax
f0101c35:	01 d0                	add    %edx,%eax
f0101c37:	89 c1                	mov    %eax,%ecx
f0101c39:	c1 e1 08             	shl    $0x8,%ecx
f0101c3c:	01 c8                	add    %ecx,%eax
f0101c3e:	89 c1                	mov    %eax,%ecx
f0101c40:	c1 e1 10             	shl    $0x10,%ecx
f0101c43:	01 c8                	add    %ecx,%eax
f0101c45:	01 c0                	add    %eax,%eax
f0101c47:	01 d0                	add    %edx,%eax
}
f0101c49:	5d                   	pop    %ebp
f0101c4a:	c3                   	ret    

f0101c4b <to_physical_address>:

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0101c4b:	55                   	push   %ebp
f0101c4c:	89 e5                	mov    %esp,%ebp
	return to_frame_number(ptr_frame_info) << PGSHIFT;
f0101c4e:	ff 75 08             	pushl  0x8(%ebp)
f0101c51:	e8 bd ff ff ff       	call   f0101c13 <to_frame_number>
f0101c56:	83 c4 04             	add    $0x4,%esp
f0101c59:	c1 e0 0c             	shl    $0xc,%eax
}
f0101c5c:	c9                   	leave  
f0101c5d:	c3                   	ret    

f0101c5e <to_frame_info>:

static inline struct Frame_Info* to_frame_info(uint32 physical_address)
{
f0101c5e:	55                   	push   %ebp
f0101c5f:	89 e5                	mov    %esp,%ebp
f0101c61:	83 ec 08             	sub    $0x8,%esp
	if (PPN(physical_address) >= number_of_frames)
f0101c64:	8b 45 08             	mov    0x8(%ebp),%eax
f0101c67:	c1 e8 0c             	shr    $0xc,%eax
f0101c6a:	89 c2                	mov    %eax,%edx
f0101c6c:	a1 68 e7 14 f0       	mov    0xf014e768,%eax
f0101c71:	39 c2                	cmp    %eax,%edx
f0101c73:	72 14                	jb     f0101c89 <to_frame_info+0x2b>
		panic("to_frame_info called with invalid pa");
f0101c75:	83 ec 04             	sub    $0x4,%esp
f0101c78:	68 5c 5a 10 f0       	push   $0xf0105a5c
f0101c7d:	6a 39                	push   $0x39
f0101c7f:	68 81 5a 10 f0       	push   $0xf0105a81
f0101c84:	e8 a5 e4 ff ff       	call   f010012e <_panic>
	return &frames_info[PPN(physical_address)];
f0101c89:	8b 15 7c e7 14 f0    	mov    0xf014e77c,%edx
f0101c8f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101c92:	c1 e8 0c             	shr    $0xc,%eax
f0101c95:	89 c1                	mov    %eax,%ecx
f0101c97:	89 c8                	mov    %ecx,%eax
f0101c99:	01 c0                	add    %eax,%eax
f0101c9b:	01 c8                	add    %ecx,%eax
f0101c9d:	c1 e0 02             	shl    $0x2,%eax
f0101ca0:	01 d0                	add    %edx,%eax
}
f0101ca2:	c9                   	leave  
f0101ca3:	c3                   	ret    

f0101ca4 <initialize_kernel_VM>:
//
// From USER_TOP to USER_LIMIT, the user is allowed to read but not write.
// Above USER_LIMIT the user cannot read (or write).

void initialize_kernel_VM()
{
f0101ca4:	55                   	push   %ebp
f0101ca5:	89 e5                	mov    %esp,%ebp
f0101ca7:	83 ec 28             	sub    $0x28,%esp
	//panic("initialize_kernel_VM: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.

	ptr_page_directory = boot_allocate_space(PAGE_SIZE, PAGE_SIZE);
f0101caa:	83 ec 08             	sub    $0x8,%esp
f0101cad:	68 00 10 00 00       	push   $0x1000
f0101cb2:	68 00 10 00 00       	push   $0x1000
f0101cb7:	e8 ca 01 00 00       	call   f0101e86 <boot_allocate_space>
f0101cbc:	83 c4 10             	add    $0x10,%esp
f0101cbf:	a3 84 e7 14 f0       	mov    %eax,0xf014e784
	memset(ptr_page_directory, 0, PAGE_SIZE);
f0101cc4:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0101cc9:	83 ec 04             	sub    $0x4,%esp
f0101ccc:	68 00 10 00 00       	push   $0x1000
f0101cd1:	6a 00                	push   $0x0
f0101cd3:	50                   	push   %eax
f0101cd4:	e8 e1 29 00 00       	call   f01046ba <memset>
f0101cd9:	83 c4 10             	add    $0x10,%esp
	phys_page_directory = K_PHYSICAL_ADDRESS(ptr_page_directory);
f0101cdc:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0101ce1:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101ce4:	81 7d f4 ff ff ff ef 	cmpl   $0xefffffff,-0xc(%ebp)
f0101ceb:	77 14                	ja     f0101d01 <initialize_kernel_VM+0x5d>
f0101ced:	ff 75 f4             	pushl  -0xc(%ebp)
f0101cf0:	68 9c 5a 10 f0       	push   $0xf0105a9c
f0101cf5:	6a 3c                	push   $0x3c
f0101cf7:	68 cd 5a 10 f0       	push   $0xf0105acd
f0101cfc:	e8 2d e4 ff ff       	call   f010012e <_panic>
f0101d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101d04:	05 00 00 00 10       	add    $0x10000000,%eax
f0101d09:	a3 88 e7 14 f0       	mov    %eax,0xf014e788
	// Map the kernel stack with VA range :
	//  [KERNEL_STACK_TOP-KERNEL_STACK_SIZE, KERNEL_STACK_TOP), 
	// to physical address : "phys_stack_bottom".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_range(ptr_page_directory, KERNEL_STACK_TOP - KERNEL_STACK_SIZE, KERNEL_STACK_SIZE, K_PHYSICAL_ADDRESS(ptr_stack_bottom), PERM_WRITEABLE) ;
f0101d0e:	c7 45 f0 00 30 11 f0 	movl   $0xf0113000,-0x10(%ebp)
f0101d15:	81 7d f0 ff ff ff ef 	cmpl   $0xefffffff,-0x10(%ebp)
f0101d1c:	77 14                	ja     f0101d32 <initialize_kernel_VM+0x8e>
f0101d1e:	ff 75 f0             	pushl  -0x10(%ebp)
f0101d21:	68 9c 5a 10 f0       	push   $0xf0105a9c
f0101d26:	6a 44                	push   $0x44
f0101d28:	68 cd 5a 10 f0       	push   $0xf0105acd
f0101d2d:	e8 fc e3 ff ff       	call   f010012e <_panic>
f0101d32:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101d35:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101d3b:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0101d40:	83 ec 0c             	sub    $0xc,%esp
f0101d43:	6a 02                	push   $0x2
f0101d45:	52                   	push   %edx
f0101d46:	68 00 80 00 00       	push   $0x8000
f0101d4b:	68 00 80 bf ef       	push   $0xefbf8000
f0101d50:	50                   	push   %eax
f0101d51:	e8 92 01 00 00       	call   f0101ee8 <boot_map_range>
f0101d56:	83 c4 20             	add    $0x20,%esp
	//      the PA range [0, 2^32 - KERNEL_BASE)
	// We might not have 2^32 - KERNEL_BASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here: 
	boot_map_range(ptr_page_directory, KERNEL_BASE, 0xFFFFFFFF - KERNEL_BASE, 0, PERM_WRITEABLE) ;
f0101d59:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0101d5e:	83 ec 0c             	sub    $0xc,%esp
f0101d61:	6a 02                	push   $0x2
f0101d63:	6a 00                	push   $0x0
f0101d65:	68 ff ff ff 0f       	push   $0xfffffff
f0101d6a:	68 00 00 00 f0       	push   $0xf0000000
f0101d6f:	50                   	push   %eax
f0101d70:	e8 73 01 00 00       	call   f0101ee8 <boot_map_range>
f0101d75:	83 c4 20             	add    $0x20,%esp
	// Permissions:
	//    - frames_info -- kernel RW, user NONE
	//    - the image mapped at READ_ONLY_FRAMES_INFO  -- kernel R, user R
	// Your code goes here:
	uint32 array_size;
	array_size = number_of_frames * sizeof(struct Frame_Info) ;
f0101d78:	8b 15 68 e7 14 f0    	mov    0xf014e768,%edx
f0101d7e:	89 d0                	mov    %edx,%eax
f0101d80:	01 c0                	add    %eax,%eax
f0101d82:	01 d0                	add    %edx,%eax
f0101d84:	c1 e0 02             	shl    $0x2,%eax
f0101d87:	89 45 ec             	mov    %eax,-0x14(%ebp)
	frames_info = boot_allocate_space(array_size, PAGE_SIZE);
f0101d8a:	83 ec 08             	sub    $0x8,%esp
f0101d8d:	68 00 10 00 00       	push   $0x1000
f0101d92:	ff 75 ec             	pushl  -0x14(%ebp)
f0101d95:	e8 ec 00 00 00       	call   f0101e86 <boot_allocate_space>
f0101d9a:	83 c4 10             	add    $0x10,%esp
f0101d9d:	a3 7c e7 14 f0       	mov    %eax,0xf014e77c
	boot_map_range(ptr_page_directory, READ_ONLY_FRAMES_INFO, array_size, K_PHYSICAL_ADDRESS(frames_info), PERM_USER) ;
f0101da2:	a1 7c e7 14 f0       	mov    0xf014e77c,%eax
f0101da7:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0101daa:	81 7d e8 ff ff ff ef 	cmpl   $0xefffffff,-0x18(%ebp)
f0101db1:	77 14                	ja     f0101dc7 <initialize_kernel_VM+0x123>
f0101db3:	ff 75 e8             	pushl  -0x18(%ebp)
f0101db6:	68 9c 5a 10 f0       	push   $0xf0105a9c
f0101dbb:	6a 5f                	push   $0x5f
f0101dbd:	68 cd 5a 10 f0       	push   $0xf0105acd
f0101dc2:	e8 67 e3 ff ff       	call   f010012e <_panic>
f0101dc7:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101dca:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101dd0:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0101dd5:	83 ec 0c             	sub    $0xc,%esp
f0101dd8:	6a 04                	push   $0x4
f0101dda:	52                   	push   %edx
f0101ddb:	ff 75 ec             	pushl  -0x14(%ebp)
f0101dde:	68 00 00 00 ef       	push   $0xef000000
f0101de3:	50                   	push   %eax
f0101de4:	e8 ff 00 00 00       	call   f0101ee8 <boot_map_range>
f0101de9:	83 c4 20             	add    $0x20,%esp


	// This allows the kernel & user to access any page table entry using a
	// specified VA for each: VPT for kernel and UVPT for User.
	setup_listing_to_all_page_tables_entries();
f0101dec:	e8 e5 fc ff ff       	call   f0101ad6 <setup_listing_to_all_page_tables_entries>
	// Permissions:
	//    - envs itself -- kernel RW, user NONE
	//    - the image of envs mapped at UENVS  -- kernel R, user R

	// LAB 3: Your code here.
	int envs_size = NENV * sizeof(struct Env) ;
f0101df1:	c7 45 e4 00 90 01 00 	movl   $0x19000,-0x1c(%ebp)

	//allocate space for "envs" array aligned on 4KB boundary
	envs = boot_allocate_space(envs_size, PAGE_SIZE);
f0101df8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101dfb:	83 ec 08             	sub    $0x8,%esp
f0101dfe:	68 00 10 00 00       	push   $0x1000
f0101e03:	50                   	push   %eax
f0101e04:	e8 7d 00 00 00       	call   f0101e86 <boot_allocate_space>
f0101e09:	83 c4 10             	add    $0x10,%esp
f0101e0c:	a3 ec de 14 f0       	mov    %eax,0xf014deec

	//make the user to access this array by mapping it to UPAGES linear address (UPAGES is in User/Kernel space)
	boot_map_range(ptr_page_directory, UENVS, envs_size, K_PHYSICAL_ADDRESS(envs), PERM_USER) ;
f0101e11:	a1 ec de 14 f0       	mov    0xf014deec,%eax
f0101e16:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101e19:	81 7d e0 ff ff ff ef 	cmpl   $0xefffffff,-0x20(%ebp)
f0101e20:	77 14                	ja     f0101e36 <initialize_kernel_VM+0x192>
f0101e22:	ff 75 e0             	pushl  -0x20(%ebp)
f0101e25:	68 9c 5a 10 f0       	push   $0xf0105a9c
f0101e2a:	6a 75                	push   $0x75
f0101e2c:	68 cd 5a 10 f0       	push   $0xf0105acd
f0101e31:	e8 f8 e2 ff ff       	call   f010012e <_panic>
f0101e36:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101e39:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f0101e3f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101e42:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0101e47:	83 ec 0c             	sub    $0xc,%esp
f0101e4a:	6a 04                	push   $0x4
f0101e4c:	51                   	push   %ecx
f0101e4d:	52                   	push   %edx
f0101e4e:	68 00 00 c0 ee       	push   $0xeec00000
f0101e53:	50                   	push   %eax
f0101e54:	e8 8f 00 00 00       	call   f0101ee8 <boot_map_range>
f0101e59:	83 c4 20             	add    $0x20,%esp

	//update permissions of the corresponding entry in page directory to make it USER with PERMISSION read only
	ptr_page_directory[PDX(UENVS)] = ptr_page_directory[PDX(UENVS)]|(PERM_USER|(PERM_PRESENT & (~PERM_WRITEABLE)));
f0101e5c:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0101e61:	05 ec 0e 00 00       	add    $0xeec,%eax
f0101e66:	8b 15 84 e7 14 f0    	mov    0xf014e784,%edx
f0101e6c:	81 c2 ec 0e 00 00    	add    $0xeec,%edx
f0101e72:	8b 12                	mov    (%edx),%edx
f0101e74:	83 ca 05             	or     $0x5,%edx
f0101e77:	89 10                	mov    %edx,(%eax)


	// Check that the initial page directory has been set up correctly.
	check_boot_pgdir();
f0101e79:	e8 52 f0 ff ff       	call   f0100ed0 <check_boot_pgdir>

	// NOW: Turn off the segmentation by setting the segments' base to 0, and
	// turn on the paging by setting the corresponding flags in control register 0 (cr0)
	turn_on_paging() ;
f0101e7e:	e8 b4 fb ff ff       	call   f0101a37 <turn_on_paging>
}
f0101e83:	90                   	nop
f0101e84:	c9                   	leave  
f0101e85:	c3                   	ret    

f0101e86 <boot_allocate_space>:
// It's too early to run out of memory.
// This function may ONLY be used during boot time,
// before the free_frame_list has been set up.
// 
void* boot_allocate_space(uint32 size, uint32 align)
		{
f0101e86:	55                   	push   %ebp
f0101e87:	89 e5                	mov    %esp,%ebp
f0101e89:	83 ec 10             	sub    $0x10,%esp
	// Initialize ptr_free_mem if this is the first time.
	// 'end_of_kernel' is a symbol automatically generated by the linker,
	// which points to the end of the kernel-
	// i.e., the first virtual address that the linker
	// did not assign to any kernel code or global variables.
	if (ptr_free_mem == 0)
f0101e8c:	a1 80 e7 14 f0       	mov    0xf014e780,%eax
f0101e91:	85 c0                	test   %eax,%eax
f0101e93:	75 0a                	jne    f0101e9f <boot_allocate_space+0x19>
		ptr_free_mem = end_of_kernel;
f0101e95:	c7 05 80 e7 14 f0 8c 	movl   $0xf014e78c,0xf014e780
f0101e9c:	e7 14 f0 

	// Your code here:
	//	Step 1: round ptr_free_mem up to be aligned properly
	ptr_free_mem = ROUNDUP(ptr_free_mem, PAGE_SIZE) ;
f0101e9f:	c7 45 fc 00 10 00 00 	movl   $0x1000,-0x4(%ebp)
f0101ea6:	a1 80 e7 14 f0       	mov    0xf014e780,%eax
f0101eab:	89 c2                	mov    %eax,%edx
f0101ead:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0101eb0:	01 d0                	add    %edx,%eax
f0101eb2:	48                   	dec    %eax
f0101eb3:	89 45 f8             	mov    %eax,-0x8(%ebp)
f0101eb6:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0101eb9:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ebe:	f7 75 fc             	divl   -0x4(%ebp)
f0101ec1:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0101ec4:	29 d0                	sub    %edx,%eax
f0101ec6:	a3 80 e7 14 f0       	mov    %eax,0xf014e780

	//	Step 2: save current value of ptr_free_mem as allocated space
	void *ptr_allocated_mem;
	ptr_allocated_mem = ptr_free_mem ;
f0101ecb:	a1 80 e7 14 f0       	mov    0xf014e780,%eax
f0101ed0:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//	Step 3: increase ptr_free_mem to record allocation
	ptr_free_mem += size ;
f0101ed3:	8b 15 80 e7 14 f0    	mov    0xf014e780,%edx
f0101ed9:	8b 45 08             	mov    0x8(%ebp),%eax
f0101edc:	01 d0                	add    %edx,%eax
f0101ede:	a3 80 e7 14 f0       	mov    %eax,0xf014e780

	//	Step 4: return allocated space
	return ptr_allocated_mem ;
f0101ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax

		}
f0101ee6:	c9                   	leave  
f0101ee7:	c3                   	ret    

f0101ee8 <boot_map_range>:
//
// This function may ONLY be used during boot time,
// before the free_frame_list has been set up.
//
void boot_map_range(uint32 *ptr_page_directory, uint32 virtual_address, uint32 size, uint32 physical_address, int perm)
{
f0101ee8:	55                   	push   %ebp
f0101ee9:	89 e5                	mov    %esp,%ebp
f0101eeb:	83 ec 28             	sub    $0x28,%esp
	int i = 0 ;
f0101eee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	physical_address = ROUNDUP(physical_address, PAGE_SIZE) ;
f0101ef5:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
f0101efc:	8b 55 14             	mov    0x14(%ebp),%edx
f0101eff:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101f02:	01 d0                	add    %edx,%eax
f0101f04:	48                   	dec    %eax
f0101f05:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101f08:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101f0b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f10:	f7 75 f0             	divl   -0x10(%ebp)
f0101f13:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101f16:	29 d0                	sub    %edx,%eax
f0101f18:	89 45 14             	mov    %eax,0x14(%ebp)
	for (i = 0 ; i < size ; i += PAGE_SIZE)
f0101f1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0101f22:	eb 53                	jmp    f0101f77 <boot_map_range+0x8f>
	{
		uint32 *ptr_page_table = boot_get_page_table(ptr_page_directory, virtual_address, 1) ;
f0101f24:	83 ec 04             	sub    $0x4,%esp
f0101f27:	6a 01                	push   $0x1
f0101f29:	ff 75 0c             	pushl  0xc(%ebp)
f0101f2c:	ff 75 08             	pushl  0x8(%ebp)
f0101f2f:	e8 4e 00 00 00       	call   f0101f82 <boot_get_page_table>
f0101f34:	83 c4 10             	add    $0x10,%esp
f0101f37:	89 45 e8             	mov    %eax,-0x18(%ebp)
		uint32 index_page_table = PTX(virtual_address);
f0101f3a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101f3d:	c1 e8 0c             	shr    $0xc,%eax
f0101f40:	25 ff 03 00 00       	and    $0x3ff,%eax
f0101f45:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		ptr_page_table[index_page_table] = CONSTRUCT_ENTRY(physical_address, perm | PERM_PRESENT) ;
f0101f48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101f4b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0101f52:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101f55:	01 c2                	add    %eax,%edx
f0101f57:	8b 45 18             	mov    0x18(%ebp),%eax
f0101f5a:	0b 45 14             	or     0x14(%ebp),%eax
f0101f5d:	83 c8 01             	or     $0x1,%eax
f0101f60:	89 02                	mov    %eax,(%edx)
		physical_address += PAGE_SIZE ;
f0101f62:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
		virtual_address += PAGE_SIZE ;
f0101f69:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
//
void boot_map_range(uint32 *ptr_page_directory, uint32 virtual_address, uint32 size, uint32 physical_address, int perm)
{
	int i = 0 ;
	physical_address = ROUNDUP(physical_address, PAGE_SIZE) ;
	for (i = 0 ; i < size ; i += PAGE_SIZE)
f0101f70:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f0101f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101f7a:	3b 45 10             	cmp    0x10(%ebp),%eax
f0101f7d:	72 a5                	jb     f0101f24 <boot_map_range+0x3c>
		uint32 index_page_table = PTX(virtual_address);
		ptr_page_table[index_page_table] = CONSTRUCT_ENTRY(physical_address, perm | PERM_PRESENT) ;
		physical_address += PAGE_SIZE ;
		virtual_address += PAGE_SIZE ;
	}
}
f0101f7f:	90                   	nop
f0101f80:	c9                   	leave  
f0101f81:	c3                   	ret    

f0101f82 <boot_get_page_table>:
// boot_get_page_table cannot fail.  It's too early to fail.
// This function may ONLY be used during boot time,
// before the free_frame_list has been set up.
//
uint32* boot_get_page_table(uint32 *ptr_page_directory, uint32 virtual_address, int create)
		{
f0101f82:	55                   	push   %ebp
f0101f83:	89 e5                	mov    %esp,%ebp
f0101f85:	83 ec 28             	sub    $0x28,%esp
	uint32 index_page_directory = PDX(virtual_address);
f0101f88:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101f8b:	c1 e8 16             	shr    $0x16,%eax
f0101f8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32 page_directory_entry = ptr_page_directory[index_page_directory];
f0101f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101f94:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0101f9b:	8b 45 08             	mov    0x8(%ebp),%eax
f0101f9e:	01 d0                	add    %edx,%eax
f0101fa0:	8b 00                	mov    (%eax),%eax
f0101fa2:	89 45 f0             	mov    %eax,-0x10(%ebp)

	uint32 phys_page_table = EXTRACT_ADDRESS(page_directory_entry);
f0101fa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101fa8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101fad:	89 45 ec             	mov    %eax,-0x14(%ebp)
	uint32 *ptr_page_table = K_VIRTUAL_ADDRESS(phys_page_table);
f0101fb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101fb3:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0101fb6:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101fb9:	c1 e8 0c             	shr    $0xc,%eax
f0101fbc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101fbf:	a1 68 e7 14 f0       	mov    0xf014e768,%eax
f0101fc4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0101fc7:	72 17                	jb     f0101fe0 <boot_get_page_table+0x5e>
f0101fc9:	ff 75 e8             	pushl  -0x18(%ebp)
f0101fcc:	68 e4 5a 10 f0       	push   $0xf0105ae4
f0101fd1:	68 db 00 00 00       	push   $0xdb
f0101fd6:	68 cd 5a 10 f0       	push   $0xf0105acd
f0101fdb:	e8 4e e1 ff ff       	call   f010012e <_panic>
f0101fe0:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101fe3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101fe8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	if (phys_page_table == 0)
f0101feb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0101fef:	75 72                	jne    f0102063 <boot_get_page_table+0xe1>
	{
		if (create)
f0101ff1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101ff5:	74 65                	je     f010205c <boot_get_page_table+0xda>
		{
			ptr_page_table = boot_allocate_space(PAGE_SIZE, PAGE_SIZE) ;
f0101ff7:	83 ec 08             	sub    $0x8,%esp
f0101ffa:	68 00 10 00 00       	push   $0x1000
f0101fff:	68 00 10 00 00       	push   $0x1000
f0102004:	e8 7d fe ff ff       	call   f0101e86 <boot_allocate_space>
f0102009:	83 c4 10             	add    $0x10,%esp
f010200c:	89 45 e0             	mov    %eax,-0x20(%ebp)
			phys_page_table = K_PHYSICAL_ADDRESS(ptr_page_table);
f010200f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102012:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102015:	81 7d dc ff ff ff ef 	cmpl   $0xefffffff,-0x24(%ebp)
f010201c:	77 17                	ja     f0102035 <boot_get_page_table+0xb3>
f010201e:	ff 75 dc             	pushl  -0x24(%ebp)
f0102021:	68 9c 5a 10 f0       	push   $0xf0105a9c
f0102026:	68 e1 00 00 00       	push   $0xe1
f010202b:	68 cd 5a 10 f0       	push   $0xf0105acd
f0102030:	e8 f9 e0 ff ff       	call   f010012e <_panic>
f0102035:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102038:	05 00 00 00 10       	add    $0x10000000,%eax
f010203d:	89 45 ec             	mov    %eax,-0x14(%ebp)
			ptr_page_directory[index_page_directory] = CONSTRUCT_ENTRY(phys_page_table, PERM_PRESENT | PERM_WRITEABLE);
f0102040:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102043:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f010204a:	8b 45 08             	mov    0x8(%ebp),%eax
f010204d:	01 d0                	add    %edx,%eax
f010204f:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0102052:	83 ca 03             	or     $0x3,%edx
f0102055:	89 10                	mov    %edx,(%eax)
			return ptr_page_table ;
f0102057:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010205a:	eb 0a                	jmp    f0102066 <boot_get_page_table+0xe4>
		}
		else
			return 0 ;
f010205c:	b8 00 00 00 00       	mov    $0x0,%eax
f0102061:	eb 03                	jmp    f0102066 <boot_get_page_table+0xe4>
	}
	return ptr_page_table ;
f0102063:	8b 45 e0             	mov    -0x20(%ebp),%eax
		}
f0102066:	c9                   	leave  
f0102067:	c3                   	ret    

f0102068 <initialize_paging>:
// After this point, ONLY use the functions below
// to allocate and deallocate physical memory via the free_frame_list,
// and NEVER use boot_allocate_space() or the related boot-time functions above.
//
void initialize_paging()
{
f0102068:	55                   	push   %ebp
f0102069:	89 e5                	mov    %esp,%ebp
f010206b:	53                   	push   %ebx
f010206c:	83 ec 24             	sub    $0x24,%esp
	//     Some of it is in use, some is free. Where is the kernel?
	//     Which frames are used for page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&free_frame_list);
f010206f:	c7 05 78 e7 14 f0 00 	movl   $0x0,0xf014e778
f0102076:	00 00 00 

	frames_info[0].references = 1;
f0102079:	a1 7c e7 14 f0       	mov    0xf014e77c,%eax
f010207e:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)

	int range_end = ROUNDUP(PHYS_IO_MEM,PAGE_SIZE);
f0102084:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
f010208b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010208e:	05 ff ff 09 00       	add    $0x9ffff,%eax
f0102093:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102096:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102099:	ba 00 00 00 00       	mov    $0x0,%edx
f010209e:	f7 75 f0             	divl   -0x10(%ebp)
f01020a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01020a4:	29 d0                	sub    %edx,%eax
f01020a6:	89 45 e8             	mov    %eax,-0x18(%ebp)

	for (i = 1; i < range_end/PAGE_SIZE; i++)
f01020a9:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
f01020b0:	e9 90 00 00 00       	jmp    f0102145 <initialize_paging+0xdd>
	{
		frames_info[i].references = 0;
f01020b5:	8b 0d 7c e7 14 f0    	mov    0xf014e77c,%ecx
f01020bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01020be:	89 d0                	mov    %edx,%eax
f01020c0:	01 c0                	add    %eax,%eax
f01020c2:	01 d0                	add    %edx,%eax
f01020c4:	c1 e0 02             	shl    $0x2,%eax
f01020c7:	01 c8                	add    %ecx,%eax
f01020c9:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
		LIST_INSERT_HEAD(&free_frame_list, &frames_info[i]);
f01020cf:	8b 0d 7c e7 14 f0    	mov    0xf014e77c,%ecx
f01020d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01020d8:	89 d0                	mov    %edx,%eax
f01020da:	01 c0                	add    %eax,%eax
f01020dc:	01 d0                	add    %edx,%eax
f01020de:	c1 e0 02             	shl    $0x2,%eax
f01020e1:	01 c8                	add    %ecx,%eax
f01020e3:	8b 15 78 e7 14 f0    	mov    0xf014e778,%edx
f01020e9:	89 10                	mov    %edx,(%eax)
f01020eb:	8b 00                	mov    (%eax),%eax
f01020ed:	85 c0                	test   %eax,%eax
f01020ef:	74 1d                	je     f010210e <initialize_paging+0xa6>
f01020f1:	8b 15 78 e7 14 f0    	mov    0xf014e778,%edx
f01020f7:	8b 1d 7c e7 14 f0    	mov    0xf014e77c,%ebx
f01020fd:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f0102100:	89 c8                	mov    %ecx,%eax
f0102102:	01 c0                	add    %eax,%eax
f0102104:	01 c8                	add    %ecx,%eax
f0102106:	c1 e0 02             	shl    $0x2,%eax
f0102109:	01 d8                	add    %ebx,%eax
f010210b:	89 42 04             	mov    %eax,0x4(%edx)
f010210e:	8b 0d 7c e7 14 f0    	mov    0xf014e77c,%ecx
f0102114:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102117:	89 d0                	mov    %edx,%eax
f0102119:	01 c0                	add    %eax,%eax
f010211b:	01 d0                	add    %edx,%eax
f010211d:	c1 e0 02             	shl    $0x2,%eax
f0102120:	01 c8                	add    %ecx,%eax
f0102122:	a3 78 e7 14 f0       	mov    %eax,0xf014e778
f0102127:	8b 0d 7c e7 14 f0    	mov    0xf014e77c,%ecx
f010212d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102130:	89 d0                	mov    %edx,%eax
f0102132:	01 c0                	add    %eax,%eax
f0102134:	01 d0                	add    %edx,%eax
f0102136:	c1 e0 02             	shl    $0x2,%eax
f0102139:	01 c8                	add    %ecx,%eax
f010213b:	c7 40 04 78 e7 14 f0 	movl   $0xf014e778,0x4(%eax)

	frames_info[0].references = 1;

	int range_end = ROUNDUP(PHYS_IO_MEM,PAGE_SIZE);

	for (i = 1; i < range_end/PAGE_SIZE; i++)
f0102142:	ff 45 f4             	incl   -0xc(%ebp)
f0102145:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102148:	85 c0                	test   %eax,%eax
f010214a:	79 05                	jns    f0102151 <initialize_paging+0xe9>
f010214c:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102151:	c1 f8 0c             	sar    $0xc,%eax
f0102154:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0102157:	0f 8f 58 ff ff ff    	jg     f01020b5 <initialize_paging+0x4d>
	{
		frames_info[i].references = 0;
		LIST_INSERT_HEAD(&free_frame_list, &frames_info[i]);
	}

	for (i = PHYS_IO_MEM/PAGE_SIZE ; i < PHYS_EXTENDED_MEM/PAGE_SIZE; i++)
f010215d:	c7 45 f4 a0 00 00 00 	movl   $0xa0,-0xc(%ebp)
f0102164:	eb 1d                	jmp    f0102183 <initialize_paging+0x11b>
	{
		frames_info[i].references = 1;
f0102166:	8b 0d 7c e7 14 f0    	mov    0xf014e77c,%ecx
f010216c:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010216f:	89 d0                	mov    %edx,%eax
f0102171:	01 c0                	add    %eax,%eax
f0102173:	01 d0                	add    %edx,%eax
f0102175:	c1 e0 02             	shl    $0x2,%eax
f0102178:	01 c8                	add    %ecx,%eax
f010217a:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
	{
		frames_info[i].references = 0;
		LIST_INSERT_HEAD(&free_frame_list, &frames_info[i]);
	}

	for (i = PHYS_IO_MEM/PAGE_SIZE ; i < PHYS_EXTENDED_MEM/PAGE_SIZE; i++)
f0102180:	ff 45 f4             	incl   -0xc(%ebp)
f0102183:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
f010218a:	7e da                	jle    f0102166 <initialize_paging+0xfe>
	{
		frames_info[i].references = 1;
	}

	range_end = ROUNDUP(K_PHYSICAL_ADDRESS(ptr_free_mem), PAGE_SIZE);
f010218c:	c7 45 e4 00 10 00 00 	movl   $0x1000,-0x1c(%ebp)
f0102193:	a1 80 e7 14 f0       	mov    0xf014e780,%eax
f0102198:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010219b:	81 7d e0 ff ff ff ef 	cmpl   $0xefffffff,-0x20(%ebp)
f01021a2:	77 17                	ja     f01021bb <initialize_paging+0x153>
f01021a4:	ff 75 e0             	pushl  -0x20(%ebp)
f01021a7:	68 9c 5a 10 f0       	push   $0xf0105a9c
f01021ac:	68 1e 01 00 00       	push   $0x11e
f01021b1:	68 cd 5a 10 f0       	push   $0xf0105acd
f01021b6:	e8 73 df ff ff       	call   f010012e <_panic>
f01021bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01021be:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01021c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01021c7:	01 d0                	add    %edx,%eax
f01021c9:	48                   	dec    %eax
f01021ca:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01021cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01021d0:	ba 00 00 00 00       	mov    $0x0,%edx
f01021d5:	f7 75 e4             	divl   -0x1c(%ebp)
f01021d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01021db:	29 d0                	sub    %edx,%eax
f01021dd:	89 45 e8             	mov    %eax,-0x18(%ebp)

	for (i = PHYS_EXTENDED_MEM/PAGE_SIZE ; i < range_end/PAGE_SIZE; i++)
f01021e0:	c7 45 f4 00 01 00 00 	movl   $0x100,-0xc(%ebp)
f01021e7:	eb 1d                	jmp    f0102206 <initialize_paging+0x19e>
	{
		frames_info[i].references = 1;
f01021e9:	8b 0d 7c e7 14 f0    	mov    0xf014e77c,%ecx
f01021ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01021f2:	89 d0                	mov    %edx,%eax
f01021f4:	01 c0                	add    %eax,%eax
f01021f6:	01 d0                	add    %edx,%eax
f01021f8:	c1 e0 02             	shl    $0x2,%eax
f01021fb:	01 c8                	add    %ecx,%eax
f01021fd:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
		frames_info[i].references = 1;
	}

	range_end = ROUNDUP(K_PHYSICAL_ADDRESS(ptr_free_mem), PAGE_SIZE);

	for (i = PHYS_EXTENDED_MEM/PAGE_SIZE ; i < range_end/PAGE_SIZE; i++)
f0102203:	ff 45 f4             	incl   -0xc(%ebp)
f0102206:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102209:	85 c0                	test   %eax,%eax
f010220b:	79 05                	jns    f0102212 <initialize_paging+0x1aa>
f010220d:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102212:	c1 f8 0c             	sar    $0xc,%eax
f0102215:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0102218:	7f cf                	jg     f01021e9 <initialize_paging+0x181>
	{
		frames_info[i].references = 1;
	}

	for (i = range_end/PAGE_SIZE ; i < number_of_frames; i++)
f010221a:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010221d:	85 c0                	test   %eax,%eax
f010221f:	79 05                	jns    f0102226 <initialize_paging+0x1be>
f0102221:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102226:	c1 f8 0c             	sar    $0xc,%eax
f0102229:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010222c:	e9 90 00 00 00       	jmp    f01022c1 <initialize_paging+0x259>
	{
		frames_info[i].references = 0;
f0102231:	8b 0d 7c e7 14 f0    	mov    0xf014e77c,%ecx
f0102237:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010223a:	89 d0                	mov    %edx,%eax
f010223c:	01 c0                	add    %eax,%eax
f010223e:	01 d0                	add    %edx,%eax
f0102240:	c1 e0 02             	shl    $0x2,%eax
f0102243:	01 c8                	add    %ecx,%eax
f0102245:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
		LIST_INSERT_HEAD(&free_frame_list, &frames_info[i]);
f010224b:	8b 0d 7c e7 14 f0    	mov    0xf014e77c,%ecx
f0102251:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102254:	89 d0                	mov    %edx,%eax
f0102256:	01 c0                	add    %eax,%eax
f0102258:	01 d0                	add    %edx,%eax
f010225a:	c1 e0 02             	shl    $0x2,%eax
f010225d:	01 c8                	add    %ecx,%eax
f010225f:	8b 15 78 e7 14 f0    	mov    0xf014e778,%edx
f0102265:	89 10                	mov    %edx,(%eax)
f0102267:	8b 00                	mov    (%eax),%eax
f0102269:	85 c0                	test   %eax,%eax
f010226b:	74 1d                	je     f010228a <initialize_paging+0x222>
f010226d:	8b 15 78 e7 14 f0    	mov    0xf014e778,%edx
f0102273:	8b 1d 7c e7 14 f0    	mov    0xf014e77c,%ebx
f0102279:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f010227c:	89 c8                	mov    %ecx,%eax
f010227e:	01 c0                	add    %eax,%eax
f0102280:	01 c8                	add    %ecx,%eax
f0102282:	c1 e0 02             	shl    $0x2,%eax
f0102285:	01 d8                	add    %ebx,%eax
f0102287:	89 42 04             	mov    %eax,0x4(%edx)
f010228a:	8b 0d 7c e7 14 f0    	mov    0xf014e77c,%ecx
f0102290:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102293:	89 d0                	mov    %edx,%eax
f0102295:	01 c0                	add    %eax,%eax
f0102297:	01 d0                	add    %edx,%eax
f0102299:	c1 e0 02             	shl    $0x2,%eax
f010229c:	01 c8                	add    %ecx,%eax
f010229e:	a3 78 e7 14 f0       	mov    %eax,0xf014e778
f01022a3:	8b 0d 7c e7 14 f0    	mov    0xf014e77c,%ecx
f01022a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01022ac:	89 d0                	mov    %edx,%eax
f01022ae:	01 c0                	add    %eax,%eax
f01022b0:	01 d0                	add    %edx,%eax
f01022b2:	c1 e0 02             	shl    $0x2,%eax
f01022b5:	01 c8                	add    %ecx,%eax
f01022b7:	c7 40 04 78 e7 14 f0 	movl   $0xf014e778,0x4(%eax)
	for (i = PHYS_EXTENDED_MEM/PAGE_SIZE ; i < range_end/PAGE_SIZE; i++)
	{
		frames_info[i].references = 1;
	}

	for (i = range_end/PAGE_SIZE ; i < number_of_frames; i++)
f01022be:	ff 45 f4             	incl   -0xc(%ebp)
f01022c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01022c4:	a1 68 e7 14 f0       	mov    0xf014e768,%eax
f01022c9:	39 c2                	cmp    %eax,%edx
f01022cb:	0f 82 60 ff ff ff    	jb     f0102231 <initialize_paging+0x1c9>
	{
		frames_info[i].references = 0;
		LIST_INSERT_HEAD(&free_frame_list, &frames_info[i]);
	}
}
f01022d1:	90                   	nop
f01022d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01022d5:	c9                   	leave  
f01022d6:	c3                   	ret    

f01022d7 <initialize_frame_info>:
// Initialize a Frame_Info structure.
// The result has null links and 0 references.
// Note that the corresponding physical frame is NOT initialized!
//
void initialize_frame_info(struct Frame_Info *ptr_frame_info)
{
f01022d7:	55                   	push   %ebp
f01022d8:	89 e5                	mov    %esp,%ebp
f01022da:	83 ec 08             	sub    $0x8,%esp
	memset(ptr_frame_info, 0, sizeof(*ptr_frame_info));
f01022dd:	83 ec 04             	sub    $0x4,%esp
f01022e0:	6a 0c                	push   $0xc
f01022e2:	6a 00                	push   $0x0
f01022e4:	ff 75 08             	pushl  0x8(%ebp)
f01022e7:	e8 ce 23 00 00       	call   f01046ba <memset>
f01022ec:	83 c4 10             	add    $0x10,%esp
}
f01022ef:	90                   	nop
f01022f0:	c9                   	leave  
f01022f1:	c3                   	ret    

f01022f2 <allocate_frame>:
//   E_NO_MEM -- otherwise
//
// Hint: use LIST_FIRST, LIST_REMOVE, and initialize_frame_info
// Hint: references should not be incremented
int allocate_frame(struct Frame_Info **ptr_frame_info)
{
f01022f2:	55                   	push   %ebp
f01022f3:	89 e5                	mov    %esp,%ebp
f01022f5:	83 ec 08             	sub    $0x8,%esp
	// Fill this function in	
	*ptr_frame_info = LIST_FIRST(&free_frame_list);
f01022f8:	8b 15 78 e7 14 f0    	mov    0xf014e778,%edx
f01022fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0102301:	89 10                	mov    %edx,(%eax)
	if(*ptr_frame_info == NULL)
f0102303:	8b 45 08             	mov    0x8(%ebp),%eax
f0102306:	8b 00                	mov    (%eax),%eax
f0102308:	85 c0                	test   %eax,%eax
f010230a:	75 07                	jne    f0102313 <allocate_frame+0x21>
		return E_NO_MEM;
f010230c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0102311:	eb 44                	jmp    f0102357 <allocate_frame+0x65>

	LIST_REMOVE(*ptr_frame_info);
f0102313:	8b 45 08             	mov    0x8(%ebp),%eax
f0102316:	8b 00                	mov    (%eax),%eax
f0102318:	8b 00                	mov    (%eax),%eax
f010231a:	85 c0                	test   %eax,%eax
f010231c:	74 12                	je     f0102330 <allocate_frame+0x3e>
f010231e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102321:	8b 00                	mov    (%eax),%eax
f0102323:	8b 00                	mov    (%eax),%eax
f0102325:	8b 55 08             	mov    0x8(%ebp),%edx
f0102328:	8b 12                	mov    (%edx),%edx
f010232a:	8b 52 04             	mov    0x4(%edx),%edx
f010232d:	89 50 04             	mov    %edx,0x4(%eax)
f0102330:	8b 45 08             	mov    0x8(%ebp),%eax
f0102333:	8b 00                	mov    (%eax),%eax
f0102335:	8b 40 04             	mov    0x4(%eax),%eax
f0102338:	8b 55 08             	mov    0x8(%ebp),%edx
f010233b:	8b 12                	mov    (%edx),%edx
f010233d:	8b 12                	mov    (%edx),%edx
f010233f:	89 10                	mov    %edx,(%eax)
	initialize_frame_info(*ptr_frame_info);
f0102341:	8b 45 08             	mov    0x8(%ebp),%eax
f0102344:	8b 00                	mov    (%eax),%eax
f0102346:	83 ec 0c             	sub    $0xc,%esp
f0102349:	50                   	push   %eax
f010234a:	e8 88 ff ff ff       	call   f01022d7 <initialize_frame_info>
f010234f:	83 c4 10             	add    $0x10,%esp
	return 0;
f0102352:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102357:	c9                   	leave  
f0102358:	c3                   	ret    

f0102359 <free_frame>:
//
// Return a frame to the free_frame_list.
// (This function should only be called when ptr_frame_info->references reaches 0.)
//
void free_frame(struct Frame_Info *ptr_frame_info)
{
f0102359:	55                   	push   %ebp
f010235a:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	LIST_INSERT_HEAD(&free_frame_list, ptr_frame_info);
f010235c:	8b 15 78 e7 14 f0    	mov    0xf014e778,%edx
f0102362:	8b 45 08             	mov    0x8(%ebp),%eax
f0102365:	89 10                	mov    %edx,(%eax)
f0102367:	8b 45 08             	mov    0x8(%ebp),%eax
f010236a:	8b 00                	mov    (%eax),%eax
f010236c:	85 c0                	test   %eax,%eax
f010236e:	74 0b                	je     f010237b <free_frame+0x22>
f0102370:	a1 78 e7 14 f0       	mov    0xf014e778,%eax
f0102375:	8b 55 08             	mov    0x8(%ebp),%edx
f0102378:	89 50 04             	mov    %edx,0x4(%eax)
f010237b:	8b 45 08             	mov    0x8(%ebp),%eax
f010237e:	a3 78 e7 14 f0       	mov    %eax,0xf014e778
f0102383:	8b 45 08             	mov    0x8(%ebp),%eax
f0102386:	c7 40 04 78 e7 14 f0 	movl   $0xf014e778,0x4(%eax)
}
f010238d:	90                   	nop
f010238e:	5d                   	pop    %ebp
f010238f:	c3                   	ret    

f0102390 <decrement_references>:
//
// Decrement the reference count on a frame
// freeing it if there are no more references.
//
void decrement_references(struct Frame_Info* ptr_frame_info)
{
f0102390:	55                   	push   %ebp
f0102391:	89 e5                	mov    %esp,%ebp
	if (--(ptr_frame_info->references) == 0)
f0102393:	8b 45 08             	mov    0x8(%ebp),%eax
f0102396:	8b 40 08             	mov    0x8(%eax),%eax
f0102399:	48                   	dec    %eax
f010239a:	8b 55 08             	mov    0x8(%ebp),%edx
f010239d:	66 89 42 08          	mov    %ax,0x8(%edx)
f01023a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01023a4:	8b 40 08             	mov    0x8(%eax),%eax
f01023a7:	66 85 c0             	test   %ax,%ax
f01023aa:	75 0b                	jne    f01023b7 <decrement_references+0x27>
		free_frame(ptr_frame_info);
f01023ac:	ff 75 08             	pushl  0x8(%ebp)
f01023af:	e8 a5 ff ff ff       	call   f0102359 <free_frame>
f01023b4:	83 c4 04             	add    $0x4,%esp
}
f01023b7:	90                   	nop
f01023b8:	c9                   	leave  
f01023b9:	c3                   	ret    

f01023ba <get_page_table>:
//
// Hint: you can use "to_physical_address()" to turn a Frame_Info*
// into the physical address of the frame it refers to. 

int get_page_table(uint32 *ptr_page_directory, const void *virtual_address, int create, uint32 **ptr_page_table)
{
f01023ba:	55                   	push   %ebp
f01023bb:	89 e5                	mov    %esp,%ebp
f01023bd:	83 ec 28             	sub    $0x28,%esp
	// Fill this function in
	uint32 page_directory_entry = ptr_page_directory[PDX(virtual_address)];
f01023c0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01023c3:	c1 e8 16             	shr    $0x16,%eax
f01023c6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01023cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01023d0:	01 d0                	add    %edx,%eax
f01023d2:	8b 00                	mov    (%eax),%eax
f01023d4:	89 45 f4             	mov    %eax,-0xc(%ebp)

	*ptr_page_table = K_VIRTUAL_ADDRESS(EXTRACT_ADDRESS(page_directory_entry)) ;
f01023d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01023da:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01023df:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01023e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01023e5:	c1 e8 0c             	shr    $0xc,%eax
f01023e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01023eb:	a1 68 e7 14 f0       	mov    0xf014e768,%eax
f01023f0:	39 45 ec             	cmp    %eax,-0x14(%ebp)
f01023f3:	72 17                	jb     f010240c <get_page_table+0x52>
f01023f5:	ff 75 f0             	pushl  -0x10(%ebp)
f01023f8:	68 e4 5a 10 f0       	push   $0xf0105ae4
f01023fd:	68 79 01 00 00       	push   $0x179
f0102402:	68 cd 5a 10 f0       	push   $0xf0105acd
f0102407:	e8 22 dd ff ff       	call   f010012e <_panic>
f010240c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010240f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102414:	89 c2                	mov    %eax,%edx
f0102416:	8b 45 14             	mov    0x14(%ebp),%eax
f0102419:	89 10                	mov    %edx,(%eax)

	if (page_directory_entry == 0)
f010241b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010241f:	0f 85 d3 00 00 00    	jne    f01024f8 <get_page_table+0x13e>
	{
		if (create)
f0102425:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0102429:	0f 84 b9 00 00 00    	je     f01024e8 <get_page_table+0x12e>
		{
			struct Frame_Info* ptr_frame_info;
			int err = allocate_frame(&ptr_frame_info) ;
f010242f:	83 ec 0c             	sub    $0xc,%esp
f0102432:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0102435:	50                   	push   %eax
f0102436:	e8 b7 fe ff ff       	call   f01022f2 <allocate_frame>
f010243b:	83 c4 10             	add    $0x10,%esp
f010243e:	89 45 e8             	mov    %eax,-0x18(%ebp)
			if(err == E_NO_MEM)
f0102441:	83 7d e8 fc          	cmpl   $0xfffffffc,-0x18(%ebp)
f0102445:	75 13                	jne    f010245a <get_page_table+0xa0>
			{
				*ptr_page_table = 0;
f0102447:	8b 45 14             	mov    0x14(%ebp),%eax
f010244a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
				return E_NO_MEM;
f0102450:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0102455:	e9 a3 00 00 00       	jmp    f01024fd <get_page_table+0x143>
			}

			uint32 phys_page_table = to_physical_address(ptr_frame_info);
f010245a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010245d:	83 ec 0c             	sub    $0xc,%esp
f0102460:	50                   	push   %eax
f0102461:	e8 e5 f7 ff ff       	call   f0101c4b <to_physical_address>
f0102466:	83 c4 10             	add    $0x10,%esp
f0102469:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			*ptr_page_table = K_VIRTUAL_ADDRESS(phys_page_table) ;
f010246c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010246f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102472:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102475:	c1 e8 0c             	shr    $0xc,%eax
f0102478:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010247b:	a1 68 e7 14 f0       	mov    0xf014e768,%eax
f0102480:	39 45 dc             	cmp    %eax,-0x24(%ebp)
f0102483:	72 17                	jb     f010249c <get_page_table+0xe2>
f0102485:	ff 75 e0             	pushl  -0x20(%ebp)
f0102488:	68 e4 5a 10 f0       	push   $0xf0105ae4
f010248d:	68 88 01 00 00       	push   $0x188
f0102492:	68 cd 5a 10 f0       	push   $0xf0105acd
f0102497:	e8 92 dc ff ff       	call   f010012e <_panic>
f010249c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010249f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024a4:	89 c2                	mov    %eax,%edx
f01024a6:	8b 45 14             	mov    0x14(%ebp),%eax
f01024a9:	89 10                	mov    %edx,(%eax)

			//initialize new page table by 0's
			memset(*ptr_page_table , 0, PAGE_SIZE);
f01024ab:	8b 45 14             	mov    0x14(%ebp),%eax
f01024ae:	8b 00                	mov    (%eax),%eax
f01024b0:	83 ec 04             	sub    $0x4,%esp
f01024b3:	68 00 10 00 00       	push   $0x1000
f01024b8:	6a 00                	push   $0x0
f01024ba:	50                   	push   %eax
f01024bb:	e8 fa 21 00 00       	call   f01046ba <memset>
f01024c0:	83 c4 10             	add    $0x10,%esp

			ptr_frame_info->references = 1;
f01024c3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01024c6:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
			ptr_page_directory[PDX(virtual_address)] = CONSTRUCT_ENTRY(phys_page_table, PERM_PRESENT | PERM_USER | PERM_WRITEABLE);
f01024cc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01024cf:	c1 e8 16             	shr    $0x16,%eax
f01024d2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01024d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01024dc:	01 d0                	add    %edx,%eax
f01024de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01024e1:	83 ca 07             	or     $0x7,%edx
f01024e4:	89 10                	mov    %edx,(%eax)
f01024e6:	eb 10                	jmp    f01024f8 <get_page_table+0x13e>
		}
		else
		{
			*ptr_page_table = 0;
f01024e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01024eb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			return 0;
f01024f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01024f6:	eb 05                	jmp    f01024fd <get_page_table+0x143>
		}
	}	
	return 0;
f01024f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01024fd:	c9                   	leave  
f01024fe:	c3                   	ret    

f01024ff <map_frame>:
//   E_NO_MEM, if page table couldn't be allocated
//
// Hint: implement using get_page_table() and unmap_frame().
//
int map_frame(uint32 *ptr_page_directory, struct Frame_Info *ptr_frame_info, void *virtual_address, int perm)
{
f01024ff:	55                   	push   %ebp
f0102500:	89 e5                	mov    %esp,%ebp
f0102502:	83 ec 18             	sub    $0x18,%esp
	// Fill this function in
	uint32 physical_address = to_physical_address(ptr_frame_info);
f0102505:	ff 75 0c             	pushl  0xc(%ebp)
f0102508:	e8 3e f7 ff ff       	call   f0101c4b <to_physical_address>
f010250d:	83 c4 04             	add    $0x4,%esp
f0102510:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32 *ptr_page_table;
	if( get_page_table(ptr_page_directory, virtual_address, 1, &ptr_page_table) == 0)
f0102513:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0102516:	50                   	push   %eax
f0102517:	6a 01                	push   $0x1
f0102519:	ff 75 10             	pushl  0x10(%ebp)
f010251c:	ff 75 08             	pushl  0x8(%ebp)
f010251f:	e8 96 fe ff ff       	call   f01023ba <get_page_table>
f0102524:	83 c4 10             	add    $0x10,%esp
f0102527:	85 c0                	test   %eax,%eax
f0102529:	75 7c                	jne    f01025a7 <map_frame+0xa8>
	{
		uint32 page_table_entry = ptr_page_table[PTX(virtual_address)];
f010252b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010252e:	8b 55 10             	mov    0x10(%ebp),%edx
f0102531:	c1 ea 0c             	shr    $0xc,%edx
f0102534:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010253a:	c1 e2 02             	shl    $0x2,%edx
f010253d:	01 d0                	add    %edx,%eax
f010253f:	8b 00                	mov    (%eax),%eax
f0102541:	89 45 f0             	mov    %eax,-0x10(%ebp)

		//If already mapped
		if ((page_table_entry & PERM_PRESENT) == PERM_PRESENT)
f0102544:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102547:	83 e0 01             	and    $0x1,%eax
f010254a:	85 c0                	test   %eax,%eax
f010254c:	74 25                	je     f0102573 <map_frame+0x74>
		{
			//on this pa, then do nothing
			if (EXTRACT_ADDRESS(page_table_entry) == physical_address)
f010254e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102551:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102556:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0102559:	75 07                	jne    f0102562 <map_frame+0x63>
				return 0;
f010255b:	b8 00 00 00 00       	mov    $0x0,%eax
f0102560:	eb 4a                	jmp    f01025ac <map_frame+0xad>
			//on another pa, then unmap it
			else
				unmap_frame(ptr_page_directory , virtual_address);
f0102562:	83 ec 08             	sub    $0x8,%esp
f0102565:	ff 75 10             	pushl  0x10(%ebp)
f0102568:	ff 75 08             	pushl  0x8(%ebp)
f010256b:	e8 ad 00 00 00       	call   f010261d <unmap_frame>
f0102570:	83 c4 10             	add    $0x10,%esp
		}
		ptr_frame_info->references++;
f0102573:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102576:	8b 40 08             	mov    0x8(%eax),%eax
f0102579:	40                   	inc    %eax
f010257a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010257d:	66 89 42 08          	mov    %ax,0x8(%edx)
		ptr_page_table[PTX(virtual_address)] = CONSTRUCT_ENTRY(physical_address , perm | PERM_PRESENT);
f0102581:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102584:	8b 55 10             	mov    0x10(%ebp),%edx
f0102587:	c1 ea 0c             	shr    $0xc,%edx
f010258a:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102590:	c1 e2 02             	shl    $0x2,%edx
f0102593:	01 c2                	add    %eax,%edx
f0102595:	8b 45 14             	mov    0x14(%ebp),%eax
f0102598:	0b 45 f4             	or     -0xc(%ebp),%eax
f010259b:	83 c8 01             	or     $0x1,%eax
f010259e:	89 02                	mov    %eax,(%edx)

		return 0;
f01025a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01025a5:	eb 05                	jmp    f01025ac <map_frame+0xad>
	}	
	return E_NO_MEM;
f01025a7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
f01025ac:	c9                   	leave  
f01025ad:	c3                   	ret    

f01025ae <get_frame_info>:
// Return 0 if there is no frame mapped at virtual_address.
//
// Hint: implement using get_page_table() and get_frame_info().
//
struct Frame_Info * get_frame_info(uint32 *ptr_page_directory, void *virtual_address, uint32 **ptr_page_table)
		{
f01025ae:	55                   	push   %ebp
f01025af:	89 e5                	mov    %esp,%ebp
f01025b1:	83 ec 18             	sub    $0x18,%esp
	// Fill this function in	
	uint32 ret =  get_page_table(ptr_page_directory, virtual_address, 0, ptr_page_table) ;
f01025b4:	ff 75 10             	pushl  0x10(%ebp)
f01025b7:	6a 00                	push   $0x0
f01025b9:	ff 75 0c             	pushl  0xc(%ebp)
f01025bc:	ff 75 08             	pushl  0x8(%ebp)
f01025bf:	e8 f6 fd ff ff       	call   f01023ba <get_page_table>
f01025c4:	83 c4 10             	add    $0x10,%esp
f01025c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if((*ptr_page_table) != 0)
f01025ca:	8b 45 10             	mov    0x10(%ebp),%eax
f01025cd:	8b 00                	mov    (%eax),%eax
f01025cf:	85 c0                	test   %eax,%eax
f01025d1:	74 43                	je     f0102616 <get_frame_info+0x68>
	{	
		uint32 index_page_table = PTX(virtual_address);
f01025d3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01025d6:	c1 e8 0c             	shr    $0xc,%eax
f01025d9:	25 ff 03 00 00       	and    $0x3ff,%eax
f01025de:	89 45 f0             	mov    %eax,-0x10(%ebp)
		uint32 page_table_entry = (*ptr_page_table)[index_page_table];
f01025e1:	8b 45 10             	mov    0x10(%ebp),%eax
f01025e4:	8b 00                	mov    (%eax),%eax
f01025e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01025e9:	c1 e2 02             	shl    $0x2,%edx
f01025ec:	01 d0                	add    %edx,%eax
f01025ee:	8b 00                	mov    (%eax),%eax
f01025f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if( page_table_entry != 0)	
f01025f3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01025f7:	74 16                	je     f010260f <get_frame_info+0x61>
			return to_frame_info( EXTRACT_ADDRESS ( page_table_entry ) );
f01025f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01025fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102601:	83 ec 0c             	sub    $0xc,%esp
f0102604:	50                   	push   %eax
f0102605:	e8 54 f6 ff ff       	call   f0101c5e <to_frame_info>
f010260a:	83 c4 10             	add    $0x10,%esp
f010260d:	eb 0c                	jmp    f010261b <get_frame_info+0x6d>
		return 0;
f010260f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102614:	eb 05                	jmp    f010261b <get_frame_info+0x6d>
	}
	return 0;
f0102616:	b8 00 00 00 00       	mov    $0x0,%eax
		}
f010261b:	c9                   	leave  
f010261c:	c3                   	ret    

f010261d <unmap_frame>:
//
// Hint: implement using get_frame_info(),
// 	tlb_invalidate(), and decrement_references().
//
void unmap_frame(uint32 *ptr_page_directory, void *virtual_address)
{
f010261d:	55                   	push   %ebp
f010261e:	89 e5                	mov    %esp,%ebp
f0102620:	83 ec 18             	sub    $0x18,%esp
	// Fill this function in
	uint32 *ptr_page_table;
	struct Frame_Info* ptr_frame_info = get_frame_info(ptr_page_directory, virtual_address, &ptr_page_table);
f0102623:	83 ec 04             	sub    $0x4,%esp
f0102626:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0102629:	50                   	push   %eax
f010262a:	ff 75 0c             	pushl  0xc(%ebp)
f010262d:	ff 75 08             	pushl  0x8(%ebp)
f0102630:	e8 79 ff ff ff       	call   f01025ae <get_frame_info>
f0102635:	83 c4 10             	add    $0x10,%esp
f0102638:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if( ptr_frame_info != 0 )
f010263b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010263f:	74 39                	je     f010267a <unmap_frame+0x5d>
	{
		decrement_references(ptr_frame_info);
f0102641:	83 ec 0c             	sub    $0xc,%esp
f0102644:	ff 75 f4             	pushl  -0xc(%ebp)
f0102647:	e8 44 fd ff ff       	call   f0102390 <decrement_references>
f010264c:	83 c4 10             	add    $0x10,%esp
		ptr_page_table[PTX(virtual_address)] = 0;
f010264f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102652:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102655:	c1 ea 0c             	shr    $0xc,%edx
f0102658:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010265e:	c1 e2 02             	shl    $0x2,%edx
f0102661:	01 d0                	add    %edx,%eax
f0102663:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(ptr_page_directory, virtual_address);
f0102669:	83 ec 08             	sub    $0x8,%esp
f010266c:	ff 75 0c             	pushl  0xc(%ebp)
f010266f:	ff 75 08             	pushl  0x8(%ebp)
f0102672:	e8 59 eb ff ff       	call   f01011d0 <tlb_invalidate>
f0102677:	83 c4 10             	add    $0x10,%esp
	}	
}
f010267a:	90                   	nop
f010267b:	c9                   	leave  
f010267c:	c3                   	ret    

f010267d <get_page>:
//		or to allocate any necessary page tables.
// 	HINT: 	remember to free the allocated frame if there is no space 
//		for the necessary page tables

int get_page(uint32* ptr_page_directory, void *virtual_address, int perm)
{
f010267d:	55                   	push   %ebp
f010267e:	89 e5                	mov    %esp,%ebp
f0102680:	83 ec 08             	sub    $0x8,%esp
	// PROJECT 2008: Your code here.
	panic("get_page function is not completed yet") ;
f0102683:	83 ec 04             	sub    $0x4,%esp
f0102686:	68 14 5b 10 f0       	push   $0xf0105b14
f010268b:	68 14 02 00 00       	push   $0x214
f0102690:	68 cd 5a 10 f0       	push   $0xf0105acd
f0102695:	e8 94 da ff ff       	call   f010012e <_panic>

f010269a <calculate_required_frames>:
	return 0 ;
}

//[2] calculate_required_frames: 
uint32 calculate_required_frames(uint32* ptr_page_directory, uint32 start_virtual_address, uint32 size)
{
f010269a:	55                   	push   %ebp
f010269b:	89 e5                	mov    %esp,%ebp
f010269d:	83 ec 08             	sub    $0x8,%esp
	// PROJECT 2008: Your code here.
	panic("calculate_required_frames function is not completed yet") ;
f01026a0:	83 ec 04             	sub    $0x4,%esp
f01026a3:	68 3c 5b 10 f0       	push   $0xf0105b3c
f01026a8:	68 2b 02 00 00       	push   $0x22b
f01026ad:	68 cd 5a 10 f0       	push   $0xf0105acd
f01026b2:	e8 77 da ff ff       	call   f010012e <_panic>

f01026b7 <calculate_free_frames>:


//[3] calculate_free_frames:

uint32 calculate_free_frames()
{
f01026b7:	55                   	push   %ebp
f01026b8:	89 e5                	mov    %esp,%ebp
f01026ba:	83 ec 10             	sub    $0x10,%esp
	// PROJECT 2008: Your code here.
	//panic("calculate_free_frames function is not completed yet") ;

	//calculate the free frames from the free frame list
	struct Frame_Info *ptr;
	uint32 cnt = 0 ; 
f01026bd:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	LIST_FOREACH(ptr, &free_frame_list)
f01026c4:	a1 78 e7 14 f0       	mov    0xf014e778,%eax
f01026c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
f01026cc:	eb 0b                	jmp    f01026d9 <calculate_free_frames+0x22>
	{
		cnt++ ;
f01026ce:	ff 45 f8             	incl   -0x8(%ebp)
	//panic("calculate_free_frames function is not completed yet") ;

	//calculate the free frames from the free frame list
	struct Frame_Info *ptr;
	uint32 cnt = 0 ; 
	LIST_FOREACH(ptr, &free_frame_list)
f01026d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01026d4:	8b 00                	mov    (%eax),%eax
f01026d6:	89 45 fc             	mov    %eax,-0x4(%ebp)
f01026d9:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
f01026dd:	75 ef                	jne    f01026ce <calculate_free_frames+0x17>
	{
		cnt++ ;
	}
	return cnt;
f01026df:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
f01026e2:	c9                   	leave  
f01026e3:	c3                   	ret    

f01026e4 <freeMem>:
//	Steps:
//		1) Unmap all mapped pages in the range [virtual_address, virtual_address + size ]
//		2) Free all mapped page tables in this range

void freeMem(uint32* ptr_page_directory, void *virtual_address, uint32 size)
{
f01026e4:	55                   	push   %ebp
f01026e5:	89 e5                	mov    %esp,%ebp
f01026e7:	83 ec 08             	sub    $0x8,%esp
	// PROJECT 2008: Your code here.
	panic("freeMem function is not completed yet") ;
f01026ea:	83 ec 04             	sub    $0x4,%esp
f01026ed:	68 74 5b 10 f0       	push   $0xf0105b74
f01026f2:	68 52 02 00 00       	push   $0x252
f01026f7:	68 cd 5a 10 f0       	push   $0xf0105acd
f01026fc:	e8 2d da ff ff       	call   f010012e <_panic>

f0102701 <allocate_environment>:
//
// Returns 0 on success, < 0 on failure.  Errors include:
//	E_NO_FREE_ENV if all NENVS environments are allocated
//
int allocate_environment(struct Env** e)
{	
f0102701:	55                   	push   %ebp
f0102702:	89 e5                	mov    %esp,%ebp
	if (!(*e = LIST_FIRST(&env_free_list)))
f0102704:	8b 15 f4 de 14 f0    	mov    0xf014def4,%edx
f010270a:	8b 45 08             	mov    0x8(%ebp),%eax
f010270d:	89 10                	mov    %edx,(%eax)
f010270f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102712:	8b 00                	mov    (%eax),%eax
f0102714:	85 c0                	test   %eax,%eax
f0102716:	75 07                	jne    f010271f <allocate_environment+0x1e>
		return E_NO_FREE_ENV;
f0102718:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010271d:	eb 05                	jmp    f0102724 <allocate_environment+0x23>
	return 0;
f010271f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102724:	5d                   	pop    %ebp
f0102725:	c3                   	ret    

f0102726 <free_environment>:

// Free the given environment "e", simply by adding it to the free environment list.
void free_environment(struct Env* e)
{
f0102726:	55                   	push   %ebp
f0102727:	89 e5                	mov    %esp,%ebp
	curenv = NULL;	
f0102729:	c7 05 f0 de 14 f0 00 	movl   $0x0,0xf014def0
f0102730:	00 00 00 
	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102733:	8b 45 08             	mov    0x8(%ebp),%eax
f0102736:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	LIST_INSERT_HEAD(&env_free_list, e);
f010273d:	8b 15 f4 de 14 f0    	mov    0xf014def4,%edx
f0102743:	8b 45 08             	mov    0x8(%ebp),%eax
f0102746:	89 50 44             	mov    %edx,0x44(%eax)
f0102749:	8b 45 08             	mov    0x8(%ebp),%eax
f010274c:	8b 40 44             	mov    0x44(%eax),%eax
f010274f:	85 c0                	test   %eax,%eax
f0102751:	74 0e                	je     f0102761 <free_environment+0x3b>
f0102753:	a1 f4 de 14 f0       	mov    0xf014def4,%eax
f0102758:	8b 55 08             	mov    0x8(%ebp),%edx
f010275b:	83 c2 44             	add    $0x44,%edx
f010275e:	89 50 48             	mov    %edx,0x48(%eax)
f0102761:	8b 45 08             	mov    0x8(%ebp),%eax
f0102764:	a3 f4 de 14 f0       	mov    %eax,0xf014def4
f0102769:	8b 45 08             	mov    0x8(%ebp),%eax
f010276c:	c7 40 48 f4 de 14 f0 	movl   $0xf014def4,0x48(%eax)
}
f0102773:	90                   	nop
f0102774:	5d                   	pop    %ebp
f0102775:	c3                   	ret    

f0102776 <program_segment_alloc_map>:
//
// if the allocation failed, return E_NO_MEM 
// otherwise return 0
//
static int program_segment_alloc_map(struct Env *e, void *va, uint32 length)
{
f0102776:	55                   	push   %ebp
f0102777:	89 e5                	mov    %esp,%ebp
f0102779:	83 ec 08             	sub    $0x8,%esp
	//TODO: LAB6 Hands-on: fill this function. 
	//Comment the following line
	panic("Function is not implemented yet!");
f010277c:	83 ec 04             	sub    $0x4,%esp
f010277f:	68 f8 5b 10 f0       	push   $0xf0105bf8
f0102784:	6a 7b                	push   $0x7b
f0102786:	68 19 5c 10 f0       	push   $0xf0105c19
f010278b:	e8 9e d9 ff ff       	call   f010012e <_panic>

f0102790 <env_create>:
}

//
// Allocates a new env and loads the named user program into it.
struct UserProgramInfo* env_create(char* user_program_name)
{
f0102790:	55                   	push   %ebp
f0102791:	89 e5                	mov    %esp,%ebp
f0102793:	83 ec 38             	sub    $0x38,%esp
	//[1] get pointer to the start of the "user_program_name" program in memory
	// Hint: use "get_user_program_info" function, 
	// you should set the following "ptr_program_start" by the start address of the user program 
	uint8* ptr_program_start = 0; 
f0102796:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	struct UserProgramInfo* ptr_user_program_info =get_user_program_info(user_program_name);
f010279d:	83 ec 0c             	sub    $0xc,%esp
f01027a0:	ff 75 08             	pushl  0x8(%ebp)
f01027a3:	e8 28 05 00 00       	call   f0102cd0 <get_user_program_info>
f01027a8:	83 c4 10             	add    $0x10,%esp
f01027ab:	89 45 f0             	mov    %eax,-0x10(%ebp)

	if (ptr_user_program_info == 0)
f01027ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f01027b2:	75 07                	jne    f01027bb <env_create+0x2b>
		return NULL ;
f01027b4:	b8 00 00 00 00       	mov    $0x0,%eax
f01027b9:	eb 42                	jmp    f01027fd <env_create+0x6d>

	ptr_program_start = ptr_user_program_info->ptr_start ;
f01027bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01027be:	8b 40 08             	mov    0x8(%eax),%eax
f01027c1:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//[2] allocate new environment, (from the free environment list)
	//if there's no one, return NULL
	// Hint: use "allocate_environment" function
	struct Env* e = NULL;
f01027c4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
	if(allocate_environment(&e) == E_NO_FREE_ENV)
f01027cb:	83 ec 0c             	sub    $0xc,%esp
f01027ce:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01027d1:	50                   	push   %eax
f01027d2:	e8 2a ff ff ff       	call   f0102701 <allocate_environment>
f01027d7:	83 c4 10             	add    $0x10,%esp
f01027da:	83 f8 fb             	cmp    $0xfffffffb,%eax
f01027dd:	75 07                	jne    f01027e6 <env_create+0x56>
	{
		return 0;
f01027df:	b8 00 00 00 00       	mov    $0x0,%eax
f01027e4:	eb 17                	jmp    f01027fd <env_create+0x6d>
	}

	//=========================================================
	//TODO: LAB6 Hands-on: fill this part. 
	//Comment the following line
	panic("env_create: directory creation is not implemented yet!");
f01027e6:	83 ec 04             	sub    $0x4,%esp
f01027e9:	68 34 5c 10 f0       	push   $0xf0105c34
f01027ee:	68 9f 00 00 00       	push   $0x9f
f01027f3:	68 19 5c 10 f0       	push   $0xf0105c19
f01027f8:	e8 31 d9 ff ff       	call   f010012e <_panic>

	//[11] switch back to the page directory exists before segment loading
	lcr3(kern_phys_pgdir) ;

	return ptr_user_program_info;
}
f01027fd:	c9                   	leave  
f01027fe:	c3                   	ret    

f01027ff <env_run>:
// Used to run the given environment "e", simply by 
// context switch from curenv to env e.
//  (This function does not return.)
//
void env_run(struct Env *e)
{
f01027ff:	55                   	push   %ebp
f0102800:	89 e5                	mov    %esp,%ebp
f0102802:	83 ec 18             	sub    $0x18,%esp
	if(curenv != e)
f0102805:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f010280a:	3b 45 08             	cmp    0x8(%ebp),%eax
f010280d:	74 25                	je     f0102834 <env_run+0x35>
	{		
		curenv = e ;
f010280f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102812:	a3 f0 de 14 f0       	mov    %eax,0xf014def0
		curenv->env_runs++ ;
f0102817:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f010281c:	8b 50 58             	mov    0x58(%eax),%edx
f010281f:	42                   	inc    %edx
f0102820:	89 50 58             	mov    %edx,0x58(%eax)
		lcr3(curenv->env_cr3) ;	
f0102823:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f0102828:	8b 40 60             	mov    0x60(%eax),%eax
f010282b:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010282e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102831:	0f 22 d8             	mov    %eax,%cr3
	}	
	env_pop_tf(&(curenv->env_tf));
f0102834:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f0102839:	83 ec 0c             	sub    $0xc,%esp
f010283c:	50                   	push   %eax
f010283d:	e8 89 06 00 00       	call   f0102ecb <env_pop_tf>

f0102842 <env_free>:

//
// Frees environment "e" and all memory it uses.
// 
void env_free(struct Env *e)
{
f0102842:	55                   	push   %ebp
f0102843:	89 e5                	mov    %esp,%ebp
f0102845:	83 ec 08             	sub    $0x8,%esp
	panic("env_free function is not completed yet") ;
f0102848:	83 ec 04             	sub    $0x4,%esp
f010284b:	68 6c 5c 10 f0       	push   $0xf0105c6c
f0102850:	68 2f 01 00 00       	push   $0x12f
f0102855:	68 19 5c 10 f0       	push   $0xf0105c19
f010285a:	e8 cf d8 ff ff       	call   f010012e <_panic>

f010285f <env_init>:
// Insert in reverse order, so that the first call to allocate_environment()
// returns envs[0].
//
void
env_init(void)
{	
f010285f:	55                   	push   %ebp
f0102860:	89 e5                	mov    %esp,%ebp
f0102862:	53                   	push   %ebx
f0102863:	83 ec 10             	sub    $0x10,%esp
	int iEnv = NENV-1;
f0102866:	c7 45 f8 ff 03 00 00 	movl   $0x3ff,-0x8(%ebp)
	for(; iEnv >= 0; iEnv--)
f010286d:	e9 ed 00 00 00       	jmp    f010295f <env_init+0x100>
	{
		envs[iEnv].env_status = ENV_FREE;
f0102872:	8b 0d ec de 14 f0    	mov    0xf014deec,%ecx
f0102878:	8b 55 f8             	mov    -0x8(%ebp),%edx
f010287b:	89 d0                	mov    %edx,%eax
f010287d:	c1 e0 02             	shl    $0x2,%eax
f0102880:	01 d0                	add    %edx,%eax
f0102882:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102889:	01 d0                	add    %edx,%eax
f010288b:	c1 e0 02             	shl    $0x2,%eax
f010288e:	01 c8                	add    %ecx,%eax
f0102890:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[iEnv].env_id = 0;
f0102897:	8b 0d ec de 14 f0    	mov    0xf014deec,%ecx
f010289d:	8b 55 f8             	mov    -0x8(%ebp),%edx
f01028a0:	89 d0                	mov    %edx,%eax
f01028a2:	c1 e0 02             	shl    $0x2,%eax
f01028a5:	01 d0                	add    %edx,%eax
f01028a7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01028ae:	01 d0                	add    %edx,%eax
f01028b0:	c1 e0 02             	shl    $0x2,%eax
f01028b3:	01 c8                	add    %ecx,%eax
f01028b5:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
		LIST_INSERT_HEAD(&env_free_list, &envs[iEnv]);	
f01028bc:	8b 0d ec de 14 f0    	mov    0xf014deec,%ecx
f01028c2:	8b 55 f8             	mov    -0x8(%ebp),%edx
f01028c5:	89 d0                	mov    %edx,%eax
f01028c7:	c1 e0 02             	shl    $0x2,%eax
f01028ca:	01 d0                	add    %edx,%eax
f01028cc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01028d3:	01 d0                	add    %edx,%eax
f01028d5:	c1 e0 02             	shl    $0x2,%eax
f01028d8:	01 c8                	add    %ecx,%eax
f01028da:	8b 15 f4 de 14 f0    	mov    0xf014def4,%edx
f01028e0:	89 50 44             	mov    %edx,0x44(%eax)
f01028e3:	8b 40 44             	mov    0x44(%eax),%eax
f01028e6:	85 c0                	test   %eax,%eax
f01028e8:	74 2a                	je     f0102914 <env_init+0xb5>
f01028ea:	8b 15 f4 de 14 f0    	mov    0xf014def4,%edx
f01028f0:	8b 1d ec de 14 f0    	mov    0xf014deec,%ebx
f01028f6:	8b 4d f8             	mov    -0x8(%ebp),%ecx
f01028f9:	89 c8                	mov    %ecx,%eax
f01028fb:	c1 e0 02             	shl    $0x2,%eax
f01028fe:	01 c8                	add    %ecx,%eax
f0102900:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
f0102907:	01 c8                	add    %ecx,%eax
f0102909:	c1 e0 02             	shl    $0x2,%eax
f010290c:	01 d8                	add    %ebx,%eax
f010290e:	83 c0 44             	add    $0x44,%eax
f0102911:	89 42 48             	mov    %eax,0x48(%edx)
f0102914:	8b 0d ec de 14 f0    	mov    0xf014deec,%ecx
f010291a:	8b 55 f8             	mov    -0x8(%ebp),%edx
f010291d:	89 d0                	mov    %edx,%eax
f010291f:	c1 e0 02             	shl    $0x2,%eax
f0102922:	01 d0                	add    %edx,%eax
f0102924:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f010292b:	01 d0                	add    %edx,%eax
f010292d:	c1 e0 02             	shl    $0x2,%eax
f0102930:	01 c8                	add    %ecx,%eax
f0102932:	a3 f4 de 14 f0       	mov    %eax,0xf014def4
f0102937:	8b 0d ec de 14 f0    	mov    0xf014deec,%ecx
f010293d:	8b 55 f8             	mov    -0x8(%ebp),%edx
f0102940:	89 d0                	mov    %edx,%eax
f0102942:	c1 e0 02             	shl    $0x2,%eax
f0102945:	01 d0                	add    %edx,%eax
f0102947:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f010294e:	01 d0                	add    %edx,%eax
f0102950:	c1 e0 02             	shl    $0x2,%eax
f0102953:	01 c8                	add    %ecx,%eax
f0102955:	c7 40 48 f4 de 14 f0 	movl   $0xf014def4,0x48(%eax)
//
void
env_init(void)
{	
	int iEnv = NENV-1;
	for(; iEnv >= 0; iEnv--)
f010295c:	ff 4d f8             	decl   -0x8(%ebp)
f010295f:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
f0102963:	0f 89 09 ff ff ff    	jns    f0102872 <env_init+0x13>
	{
		envs[iEnv].env_status = ENV_FREE;
		envs[iEnv].env_id = 0;
		LIST_INSERT_HEAD(&env_free_list, &envs[iEnv]);	
	}
}
f0102969:	90                   	nop
f010296a:	83 c4 10             	add    $0x10,%esp
f010296d:	5b                   	pop    %ebx
f010296e:	5d                   	pop    %ebp
f010296f:	c3                   	ret    

f0102970 <complete_environment_initialization>:

void complete_environment_initialization(struct Env* e)
{	
f0102970:	55                   	push   %ebp
f0102971:	89 e5                	mov    %esp,%ebp
f0102973:	83 ec 18             	sub    $0x18,%esp
	//VPT and UVPT map the env's own page table, with
	//different permissions.
	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PERM_PRESENT | PERM_WRITEABLE;
f0102976:	8b 45 08             	mov    0x8(%ebp),%eax
f0102979:	8b 40 5c             	mov    0x5c(%eax),%eax
f010297c:	8d 90 fc 0e 00 00    	lea    0xefc(%eax),%edx
f0102982:	8b 45 08             	mov    0x8(%ebp),%eax
f0102985:	8b 40 60             	mov    0x60(%eax),%eax
f0102988:	83 c8 03             	or     $0x3,%eax
f010298b:	89 02                	mov    %eax,(%edx)
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PERM_PRESENT | PERM_USER;
f010298d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102990:	8b 40 5c             	mov    0x5c(%eax),%eax
f0102993:	8d 90 f4 0e 00 00    	lea    0xef4(%eax),%edx
f0102999:	8b 45 08             	mov    0x8(%ebp),%eax
f010299c:	8b 40 60             	mov    0x60(%eax),%eax
f010299f:	83 c8 05             	or     $0x5,%eax
f01029a2:	89 02                	mov    %eax,(%edx)

	int32 generation;	
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01029a4:	8b 45 08             	mov    0x8(%ebp),%eax
f01029a7:	8b 40 4c             	mov    0x4c(%eax),%eax
f01029aa:	05 00 10 00 00       	add    $0x1000,%eax
f01029af:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01029b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (generation <= 0)	// Don't create a negative env_id.
f01029b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f01029bb:	7f 07                	jg     f01029c4 <complete_environment_initialization+0x54>
		generation = 1 << ENVGENSHIFT;
f01029bd:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
	e->env_id = generation | (e - envs);
f01029c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01029c7:	8b 15 ec de 14 f0    	mov    0xf014deec,%edx
f01029cd:	29 d0                	sub    %edx,%eax
f01029cf:	c1 f8 02             	sar    $0x2,%eax
f01029d2:	89 c1                	mov    %eax,%ecx
f01029d4:	89 c8                	mov    %ecx,%eax
f01029d6:	c1 e0 02             	shl    $0x2,%eax
f01029d9:	01 c8                	add    %ecx,%eax
f01029db:	c1 e0 07             	shl    $0x7,%eax
f01029de:	29 c8                	sub    %ecx,%eax
f01029e0:	c1 e0 03             	shl    $0x3,%eax
f01029e3:	01 c8                	add    %ecx,%eax
f01029e5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01029ec:	01 d0                	add    %edx,%eax
f01029ee:	c1 e0 02             	shl    $0x2,%eax
f01029f1:	01 c8                	add    %ecx,%eax
f01029f3:	c1 e0 03             	shl    $0x3,%eax
f01029f6:	01 c8                	add    %ecx,%eax
f01029f8:	89 c2                	mov    %eax,%edx
f01029fa:	c1 e2 06             	shl    $0x6,%edx
f01029fd:	29 c2                	sub    %eax,%edx
f01029ff:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0102a02:	8d 14 08             	lea    (%eax,%ecx,1),%edx
f0102a05:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
f0102a0c:	01 c2                	add    %eax,%edx
f0102a0e:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0102a11:	8d 14 08             	lea    (%eax,%ecx,1),%edx
f0102a14:	89 d0                	mov    %edx,%eax
f0102a16:	f7 d8                	neg    %eax
f0102a18:	0b 45 f4             	or     -0xc(%ebp),%eax
f0102a1b:	89 c2                	mov    %eax,%edx
f0102a1d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a20:	89 50 4c             	mov    %edx,0x4c(%eax)

	// Set the basic status variables.
	e->env_parent_id = 0;//parent_id;
f0102a23:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a26:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)
	e->env_status = ENV_RUNNABLE;
f0102a2d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a30:	c7 40 54 01 00 00 00 	movl   $0x1,0x54(%eax)
	e->env_runs = 0;
f0102a37:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a3a:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102a41:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a44:	83 ec 04             	sub    $0x4,%esp
f0102a47:	6a 44                	push   $0x44
f0102a49:	6a 00                	push   $0x0
f0102a4b:	50                   	push   %eax
f0102a4c:	e8 69 1c 00 00       	call   f01046ba <memset>
f0102a51:	83 c4 10             	add    $0x10,%esp
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.

	e->env_tf.tf_ds = GD_UD | 3;
f0102a54:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a57:	66 c7 40 24 23 00    	movw   $0x23,0x24(%eax)
	e->env_tf.tf_es = GD_UD | 3;
f0102a5d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a60:	66 c7 40 20 23 00    	movw   $0x23,0x20(%eax)
	e->env_tf.tf_ss = GD_UD | 3;
f0102a66:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a69:	66 c7 40 40 23 00    	movw   $0x23,0x40(%eax)
	e->env_tf.tf_esp = (uint32*)USTACKTOP;
f0102a6f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a72:	c7 40 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%eax)
	e->env_tf.tf_cs = GD_UT | 3;
f0102a79:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a7c:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	LIST_REMOVE(e);	
f0102a82:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a85:	8b 40 44             	mov    0x44(%eax),%eax
f0102a88:	85 c0                	test   %eax,%eax
f0102a8a:	74 0f                	je     f0102a9b <complete_environment_initialization+0x12b>
f0102a8c:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a8f:	8b 40 44             	mov    0x44(%eax),%eax
f0102a92:	8b 55 08             	mov    0x8(%ebp),%edx
f0102a95:	8b 52 48             	mov    0x48(%edx),%edx
f0102a98:	89 50 48             	mov    %edx,0x48(%eax)
f0102a9b:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a9e:	8b 40 48             	mov    0x48(%eax),%eax
f0102aa1:	8b 55 08             	mov    0x8(%ebp),%edx
f0102aa4:	8b 52 44             	mov    0x44(%edx),%edx
f0102aa7:	89 10                	mov    %edx,(%eax)
	return ;
f0102aa9:	90                   	nop
}
f0102aaa:	c9                   	leave  
f0102aab:	c3                   	ret    

f0102aac <PROGRAM_SEGMENT_NEXT>:

struct ProgramSegment* PROGRAM_SEGMENT_NEXT(struct ProgramSegment* seg, uint8* ptr_program_start)
				{
f0102aac:	55                   	push   %ebp
f0102aad:	89 e5                	mov    %esp,%ebp
f0102aaf:	83 ec 18             	sub    $0x18,%esp
	int index = (*seg).segment_id++;
f0102ab2:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ab5:	8b 40 10             	mov    0x10(%eax),%eax
f0102ab8:	8d 48 01             	lea    0x1(%eax),%ecx
f0102abb:	8b 55 08             	mov    0x8(%ebp),%edx
f0102abe:	89 4a 10             	mov    %ecx,0x10(%edx)
f0102ac1:	89 45 f4             	mov    %eax,-0xc(%ebp)

	struct Proghdr *ph, *eph; 
	struct Elf * pELFHDR = (struct Elf *)ptr_program_start ; 
f0102ac4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ac7:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (pELFHDR->e_magic != ELF_MAGIC) 
f0102aca:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102acd:	8b 00                	mov    (%eax),%eax
f0102acf:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
f0102ad4:	74 17                	je     f0102aed <PROGRAM_SEGMENT_NEXT+0x41>
		panic("Matafa2nash 3ala Keda"); 
f0102ad6:	83 ec 04             	sub    $0x4,%esp
f0102ad9:	68 93 5c 10 f0       	push   $0xf0105c93
f0102ade:	68 88 01 00 00       	push   $0x188
f0102ae3:	68 19 5c 10 f0       	push   $0xf0105c19
f0102ae8:	e8 41 d6 ff ff       	call   f010012e <_panic>
	ph = (struct Proghdr *) ( ((uint8 *) ptr_program_start) + pELFHDR->e_phoff);
f0102aed:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102af0:	8b 50 1c             	mov    0x1c(%eax),%edx
f0102af3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102af6:	01 d0                	add    %edx,%eax
f0102af8:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (ph[(*seg).segment_id].p_type != ELF_PROG_LOAD && ((*seg).segment_id < pELFHDR->e_phnum)) (*seg).segment_id++;	
f0102afb:	eb 0f                	jmp    f0102b0c <PROGRAM_SEGMENT_NEXT+0x60>
f0102afd:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b00:	8b 40 10             	mov    0x10(%eax),%eax
f0102b03:	8d 50 01             	lea    0x1(%eax),%edx
f0102b06:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b09:	89 50 10             	mov    %edx,0x10(%eax)
f0102b0c:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b0f:	8b 40 10             	mov    0x10(%eax),%eax
f0102b12:	c1 e0 05             	shl    $0x5,%eax
f0102b15:	89 c2                	mov    %eax,%edx
f0102b17:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102b1a:	01 d0                	add    %edx,%eax
f0102b1c:	8b 00                	mov    (%eax),%eax
f0102b1e:	83 f8 01             	cmp    $0x1,%eax
f0102b21:	74 13                	je     f0102b36 <PROGRAM_SEGMENT_NEXT+0x8a>
f0102b23:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b26:	8b 50 10             	mov    0x10(%eax),%edx
f0102b29:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102b2c:	8b 40 2c             	mov    0x2c(%eax),%eax
f0102b2f:	0f b7 c0             	movzwl %ax,%eax
f0102b32:	39 c2                	cmp    %eax,%edx
f0102b34:	72 c7                	jb     f0102afd <PROGRAM_SEGMENT_NEXT+0x51>
	index = (*seg).segment_id;
f0102b36:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b39:	8b 40 10             	mov    0x10(%eax),%eax
f0102b3c:	89 45 f4             	mov    %eax,-0xc(%ebp)

	if(index < pELFHDR->e_phnum)
f0102b3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102b42:	8b 40 2c             	mov    0x2c(%eax),%eax
f0102b45:	0f b7 c0             	movzwl %ax,%eax
f0102b48:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0102b4b:	7e 63                	jle    f0102bb0 <PROGRAM_SEGMENT_NEXT+0x104>
	{
		(*seg).ptr_start = (uint8 *) ptr_program_start + ph[index].p_offset;
f0102b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102b50:	c1 e0 05             	shl    $0x5,%eax
f0102b53:	89 c2                	mov    %eax,%edx
f0102b55:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102b58:	01 d0                	add    %edx,%eax
f0102b5a:	8b 50 04             	mov    0x4(%eax),%edx
f0102b5d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b60:	01 c2                	add    %eax,%edx
f0102b62:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b65:	89 10                	mov    %edx,(%eax)
		(*seg).size_in_memory =  ph[index].p_memsz;
f0102b67:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102b6a:	c1 e0 05             	shl    $0x5,%eax
f0102b6d:	89 c2                	mov    %eax,%edx
f0102b6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102b72:	01 d0                	add    %edx,%eax
f0102b74:	8b 50 14             	mov    0x14(%eax),%edx
f0102b77:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b7a:	89 50 08             	mov    %edx,0x8(%eax)
		(*seg).size_in_file = ph[index].p_filesz;
f0102b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102b80:	c1 e0 05             	shl    $0x5,%eax
f0102b83:	89 c2                	mov    %eax,%edx
f0102b85:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102b88:	01 d0                	add    %edx,%eax
f0102b8a:	8b 50 10             	mov    0x10(%eax),%edx
f0102b8d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b90:	89 50 04             	mov    %edx,0x4(%eax)
		(*seg).virtual_address = (uint8*)ph[index].p_va;
f0102b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102b96:	c1 e0 05             	shl    $0x5,%eax
f0102b99:	89 c2                	mov    %eax,%edx
f0102b9b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102b9e:	01 d0                	add    %edx,%eax
f0102ba0:	8b 40 08             	mov    0x8(%eax),%eax
f0102ba3:	89 c2                	mov    %eax,%edx
f0102ba5:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ba8:	89 50 0c             	mov    %edx,0xc(%eax)
		return seg;
f0102bab:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bae:	eb 05                	jmp    f0102bb5 <PROGRAM_SEGMENT_NEXT+0x109>
	}
	return 0;
f0102bb0:	b8 00 00 00 00       	mov    $0x0,%eax
				}
f0102bb5:	c9                   	leave  
f0102bb6:	c3                   	ret    

f0102bb7 <PROGRAM_SEGMENT_FIRST>:

struct ProgramSegment PROGRAM_SEGMENT_FIRST( uint8* ptr_program_start)
{
f0102bb7:	55                   	push   %ebp
f0102bb8:	89 e5                	mov    %esp,%ebp
f0102bba:	57                   	push   %edi
f0102bbb:	56                   	push   %esi
f0102bbc:	53                   	push   %ebx
f0102bbd:	83 ec 2c             	sub    $0x2c,%esp
	struct ProgramSegment seg;
	seg.segment_id = 0;
f0102bc0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

	struct Proghdr *ph, *eph; 
	struct Elf * pELFHDR = (struct Elf *)ptr_program_start ; 
f0102bc7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102bca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (pELFHDR->e_magic != ELF_MAGIC) 
f0102bcd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102bd0:	8b 00                	mov    (%eax),%eax
f0102bd2:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
f0102bd7:	74 17                	je     f0102bf0 <PROGRAM_SEGMENT_FIRST+0x39>
		panic("Matafa2nash 3ala Keda"); 
f0102bd9:	83 ec 04             	sub    $0x4,%esp
f0102bdc:	68 93 5c 10 f0       	push   $0xf0105c93
f0102be1:	68 a1 01 00 00       	push   $0x1a1
f0102be6:	68 19 5c 10 f0       	push   $0xf0105c19
f0102beb:	e8 3e d5 ff ff       	call   f010012e <_panic>
	ph = (struct Proghdr *) ( ((uint8 *) ptr_program_start) + pELFHDR->e_phoff);
f0102bf0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102bf3:	8b 50 1c             	mov    0x1c(%eax),%edx
f0102bf6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102bf9:	01 d0                	add    %edx,%eax
f0102bfb:	89 45 e0             	mov    %eax,-0x20(%ebp)
	while (ph[(seg).segment_id].p_type != ELF_PROG_LOAD && ((seg).segment_id < pELFHDR->e_phnum)) (seg).segment_id++;
f0102bfe:	eb 07                	jmp    f0102c07 <PROGRAM_SEGMENT_FIRST+0x50>
f0102c00:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102c03:	40                   	inc    %eax
f0102c04:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102c07:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102c0a:	c1 e0 05             	shl    $0x5,%eax
f0102c0d:	89 c2                	mov    %eax,%edx
f0102c0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102c12:	01 d0                	add    %edx,%eax
f0102c14:	8b 00                	mov    (%eax),%eax
f0102c16:	83 f8 01             	cmp    $0x1,%eax
f0102c19:	74 10                	je     f0102c2b <PROGRAM_SEGMENT_FIRST+0x74>
f0102c1b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102c1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102c21:	8b 40 2c             	mov    0x2c(%eax),%eax
f0102c24:	0f b7 c0             	movzwl %ax,%eax
f0102c27:	39 c2                	cmp    %eax,%edx
f0102c29:	72 d5                	jb     f0102c00 <PROGRAM_SEGMENT_FIRST+0x49>
	int index = (seg).segment_id;
f0102c2b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102c2e:	89 45 dc             	mov    %eax,-0x24(%ebp)

	if(index < pELFHDR->e_phnum)
f0102c31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102c34:	8b 40 2c             	mov    0x2c(%eax),%eax
f0102c37:	0f b7 c0             	movzwl %ax,%eax
f0102c3a:	3b 45 dc             	cmp    -0x24(%ebp),%eax
f0102c3d:	7e 68                	jle    f0102ca7 <PROGRAM_SEGMENT_FIRST+0xf0>
	{	
		(seg).ptr_start = (uint8 *) ptr_program_start + ph[index].p_offset;
f0102c3f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102c42:	c1 e0 05             	shl    $0x5,%eax
f0102c45:	89 c2                	mov    %eax,%edx
f0102c47:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102c4a:	01 d0                	add    %edx,%eax
f0102c4c:	8b 50 04             	mov    0x4(%eax),%edx
f0102c4f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c52:	01 d0                	add    %edx,%eax
f0102c54:	89 45 c8             	mov    %eax,-0x38(%ebp)
		(seg).size_in_memory =  ph[index].p_memsz;
f0102c57:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102c5a:	c1 e0 05             	shl    $0x5,%eax
f0102c5d:	89 c2                	mov    %eax,%edx
f0102c5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102c62:	01 d0                	add    %edx,%eax
f0102c64:	8b 40 14             	mov    0x14(%eax),%eax
f0102c67:	89 45 d0             	mov    %eax,-0x30(%ebp)
		(seg).size_in_file = ph[index].p_filesz;
f0102c6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102c6d:	c1 e0 05             	shl    $0x5,%eax
f0102c70:	89 c2                	mov    %eax,%edx
f0102c72:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102c75:	01 d0                	add    %edx,%eax
f0102c77:	8b 40 10             	mov    0x10(%eax),%eax
f0102c7a:	89 45 cc             	mov    %eax,-0x34(%ebp)
		(seg).virtual_address = (uint8*)ph[index].p_va;
f0102c7d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102c80:	c1 e0 05             	shl    $0x5,%eax
f0102c83:	89 c2                	mov    %eax,%edx
f0102c85:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102c88:	01 d0                	add    %edx,%eax
f0102c8a:	8b 40 08             	mov    0x8(%eax),%eax
f0102c8d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		return seg;
f0102c90:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c93:	89 c3                	mov    %eax,%ebx
f0102c95:	8d 45 c8             	lea    -0x38(%ebp),%eax
f0102c98:	ba 05 00 00 00       	mov    $0x5,%edx
f0102c9d:	89 df                	mov    %ebx,%edi
f0102c9f:	89 c6                	mov    %eax,%esi
f0102ca1:	89 d1                	mov    %edx,%ecx
f0102ca3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0102ca5:	eb 1c                	jmp    f0102cc3 <PROGRAM_SEGMENT_FIRST+0x10c>
	}
	seg.segment_id = -1;
f0102ca7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
	return seg;
f0102cae:	8b 45 08             	mov    0x8(%ebp),%eax
f0102cb1:	89 c3                	mov    %eax,%ebx
f0102cb3:	8d 45 c8             	lea    -0x38(%ebp),%eax
f0102cb6:	ba 05 00 00 00       	mov    $0x5,%edx
f0102cbb:	89 df                	mov    %ebx,%edi
f0102cbd:	89 c6                	mov    %eax,%esi
f0102cbf:	89 d1                	mov    %edx,%ecx
f0102cc1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
}
f0102cc3:	8b 45 08             	mov    0x8(%ebp),%eax
f0102cc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102cc9:	5b                   	pop    %ebx
f0102cca:	5e                   	pop    %esi
f0102ccb:	5f                   	pop    %edi
f0102ccc:	5d                   	pop    %ebp
f0102ccd:	c2 04 00             	ret    $0x4

f0102cd0 <get_user_program_info>:

struct UserProgramInfo* get_user_program_info(char* user_program_name)
				{
f0102cd0:	55                   	push   %ebp
f0102cd1:	89 e5                	mov    %esp,%ebp
f0102cd3:	83 ec 18             	sub    $0x18,%esp
	int i;
	for (i = 0; i < NUM_USER_PROGS; i++) {
f0102cd6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0102cdd:	eb 23                	jmp    f0102d02 <get_user_program_info+0x32>
		if (strcmp(user_program_name, userPrograms[i].name) == 0)
f0102cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102ce2:	c1 e0 04             	shl    $0x4,%eax
f0102ce5:	05 40 b6 11 f0       	add    $0xf011b640,%eax
f0102cea:	8b 00                	mov    (%eax),%eax
f0102cec:	83 ec 08             	sub    $0x8,%esp
f0102cef:	50                   	push   %eax
f0102cf0:	ff 75 08             	pushl  0x8(%ebp)
f0102cf3:	e8 e0 18 00 00       	call   f01045d8 <strcmp>
f0102cf8:	83 c4 10             	add    $0x10,%esp
f0102cfb:	85 c0                	test   %eax,%eax
f0102cfd:	74 0f                	je     f0102d0e <get_user_program_info+0x3e>
}

struct UserProgramInfo* get_user_program_info(char* user_program_name)
				{
	int i;
	for (i = 0; i < NUM_USER_PROGS; i++) {
f0102cff:	ff 45 f4             	incl   -0xc(%ebp)
f0102d02:	a1 94 b6 11 f0       	mov    0xf011b694,%eax
f0102d07:	39 45 f4             	cmp    %eax,-0xc(%ebp)
f0102d0a:	7c d3                	jl     f0102cdf <get_user_program_info+0xf>
f0102d0c:	eb 01                	jmp    f0102d0f <get_user_program_info+0x3f>
		if (strcmp(user_program_name, userPrograms[i].name) == 0)
			break;
f0102d0e:	90                   	nop
	}
	if(i==NUM_USER_PROGS) 
f0102d0f:	a1 94 b6 11 f0       	mov    0xf011b694,%eax
f0102d14:	39 45 f4             	cmp    %eax,-0xc(%ebp)
f0102d17:	75 1a                	jne    f0102d33 <get_user_program_info+0x63>
	{
		cprintf("Unknown user program '%s'\n", user_program_name);
f0102d19:	83 ec 08             	sub    $0x8,%esp
f0102d1c:	ff 75 08             	pushl  0x8(%ebp)
f0102d1f:	68 a9 5c 10 f0       	push   $0xf0105ca9
f0102d24:	e8 7e 02 00 00       	call   f0102fa7 <cprintf>
f0102d29:	83 c4 10             	add    $0x10,%esp
		return 0;
f0102d2c:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d31:	eb 0b                	jmp    f0102d3e <get_user_program_info+0x6e>
	}

	return &userPrograms[i];
f0102d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102d36:	c1 e0 04             	shl    $0x4,%eax
f0102d39:	05 40 b6 11 f0       	add    $0xf011b640,%eax
				}
f0102d3e:	c9                   	leave  
f0102d3f:	c3                   	ret    

f0102d40 <get_user_program_info_by_env>:

struct UserProgramInfo* get_user_program_info_by_env(struct Env* e)
				{
f0102d40:	55                   	push   %ebp
f0102d41:	89 e5                	mov    %esp,%ebp
f0102d43:	83 ec 18             	sub    $0x18,%esp
	int i;
	for (i = 0; i < NUM_USER_PROGS; i++) {
f0102d46:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0102d4d:	eb 15                	jmp    f0102d64 <get_user_program_info_by_env+0x24>
		if (e== userPrograms[i].environment)
f0102d4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102d52:	c1 e0 04             	shl    $0x4,%eax
f0102d55:	05 4c b6 11 f0       	add    $0xf011b64c,%eax
f0102d5a:	8b 00                	mov    (%eax),%eax
f0102d5c:	3b 45 08             	cmp    0x8(%ebp),%eax
f0102d5f:	74 0f                	je     f0102d70 <get_user_program_info_by_env+0x30>
				}

struct UserProgramInfo* get_user_program_info_by_env(struct Env* e)
				{
	int i;
	for (i = 0; i < NUM_USER_PROGS; i++) {
f0102d61:	ff 45 f4             	incl   -0xc(%ebp)
f0102d64:	a1 94 b6 11 f0       	mov    0xf011b694,%eax
f0102d69:	39 45 f4             	cmp    %eax,-0xc(%ebp)
f0102d6c:	7c e1                	jl     f0102d4f <get_user_program_info_by_env+0xf>
f0102d6e:	eb 01                	jmp    f0102d71 <get_user_program_info_by_env+0x31>
		if (e== userPrograms[i].environment)
			break;
f0102d70:	90                   	nop
	}
	if(i==NUM_USER_PROGS) 
f0102d71:	a1 94 b6 11 f0       	mov    0xf011b694,%eax
f0102d76:	39 45 f4             	cmp    %eax,-0xc(%ebp)
f0102d79:	75 17                	jne    f0102d92 <get_user_program_info_by_env+0x52>
	{
		cprintf("Unknown user program \n");
f0102d7b:	83 ec 0c             	sub    $0xc,%esp
f0102d7e:	68 c4 5c 10 f0       	push   $0xf0105cc4
f0102d83:	e8 1f 02 00 00       	call   f0102fa7 <cprintf>
f0102d88:	83 c4 10             	add    $0x10,%esp
		return 0;
f0102d8b:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d90:	eb 0b                	jmp    f0102d9d <get_user_program_info_by_env+0x5d>
	}

	return &userPrograms[i];
f0102d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102d95:	c1 e0 04             	shl    $0x4,%eax
f0102d98:	05 40 b6 11 f0       	add    $0xf011b640,%eax
				}
f0102d9d:	c9                   	leave  
f0102d9e:	c3                   	ret    

f0102d9f <set_environment_entry_point>:

void set_environment_entry_point(struct UserProgramInfo* ptr_user_program)
{
f0102d9f:	55                   	push   %ebp
f0102da0:	89 e5                	mov    %esp,%ebp
f0102da2:	83 ec 18             	sub    $0x18,%esp
	uint8* ptr_program_start=ptr_user_program->ptr_start;
f0102da5:	8b 45 08             	mov    0x8(%ebp),%eax
f0102da8:	8b 40 08             	mov    0x8(%eax),%eax
f0102dab:	89 45 f4             	mov    %eax,-0xc(%ebp)
	struct Env* e = ptr_user_program->environment;
f0102dae:	8b 45 08             	mov    0x8(%ebp),%eax
f0102db1:	8b 40 0c             	mov    0xc(%eax),%eax
f0102db4:	89 45 f0             	mov    %eax,-0x10(%ebp)

	struct Elf * pELFHDR = (struct Elf *)ptr_program_start ; 
f0102db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102dba:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (pELFHDR->e_magic != ELF_MAGIC) 
f0102dbd:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102dc0:	8b 00                	mov    (%eax),%eax
f0102dc2:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
f0102dc7:	74 17                	je     f0102de0 <set_environment_entry_point+0x41>
		panic("Matafa2nash 3ala Keda"); 
f0102dc9:	83 ec 04             	sub    $0x4,%esp
f0102dcc:	68 93 5c 10 f0       	push   $0xf0105c93
f0102dd1:	68 d9 01 00 00       	push   $0x1d9
f0102dd6:	68 19 5c 10 f0       	push   $0xf0105c19
f0102ddb:	e8 4e d3 ff ff       	call   f010012e <_panic>
	e->env_tf.tf_eip = (uint32*)pELFHDR->e_entry ;
f0102de0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102de3:	8b 40 18             	mov    0x18(%eax),%eax
f0102de6:	89 c2                	mov    %eax,%edx
f0102de8:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102deb:	89 50 30             	mov    %edx,0x30(%eax)
}
f0102dee:	90                   	nop
f0102def:	c9                   	leave  
f0102df0:	c3                   	ret    

f0102df1 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
f0102df1:	55                   	push   %ebp
f0102df2:	89 e5                	mov    %esp,%ebp
f0102df4:	83 ec 08             	sub    $0x8,%esp
	env_free(e);
f0102df7:	83 ec 0c             	sub    $0xc,%esp
f0102dfa:	ff 75 08             	pushl  0x8(%ebp)
f0102dfd:	e8 40 fa ff ff       	call   f0102842 <env_free>
f0102e02:	83 c4 10             	add    $0x10,%esp

	//cprintf("Destroyed the only environment - nothing more to do!\n");
	while (1)
		run_command_prompt();
f0102e05:	e8 47 db ff ff       	call   f0100951 <run_command_prompt>
f0102e0a:	eb f9                	jmp    f0102e05 <env_destroy+0x14>

f0102e0c <env_run_cmd_prmpt>:
}

void env_run_cmd_prmpt()
{
f0102e0c:	55                   	push   %ebp
f0102e0d:	89 e5                	mov    %esp,%ebp
f0102e0f:	83 ec 18             	sub    $0x18,%esp
	struct UserProgramInfo* upi= get_user_program_info_by_env(curenv);	
f0102e12:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f0102e17:	83 ec 0c             	sub    $0xc,%esp
f0102e1a:	50                   	push   %eax
f0102e1b:	e8 20 ff ff ff       	call   f0102d40 <get_user_program_info_by_env>
f0102e20:	83 c4 10             	add    $0x10,%esp
f0102e23:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&curenv->env_tf, 0, sizeof(curenv->env_tf));
f0102e26:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f0102e2b:	83 ec 04             	sub    $0x4,%esp
f0102e2e:	6a 44                	push   $0x44
f0102e30:	6a 00                	push   $0x0
f0102e32:	50                   	push   %eax
f0102e33:	e8 82 18 00 00       	call   f01046ba <memset>
f0102e38:	83 c4 10             	add    $0x10,%esp
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.

	curenv->env_tf.tf_ds = GD_UD | 3;
f0102e3b:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f0102e40:	66 c7 40 24 23 00    	movw   $0x23,0x24(%eax)
	curenv->env_tf.tf_es = GD_UD | 3;
f0102e46:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f0102e4b:	66 c7 40 20 23 00    	movw   $0x23,0x20(%eax)
	curenv->env_tf.tf_ss = GD_UD | 3;
f0102e51:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f0102e56:	66 c7 40 40 23 00    	movw   $0x23,0x40(%eax)
	curenv->env_tf.tf_esp = (uint32*)USTACKTOP;
f0102e5c:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f0102e61:	c7 40 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%eax)
	curenv->env_tf.tf_cs = GD_UT | 3;
f0102e68:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f0102e6d:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
	set_environment_entry_point(upi);
f0102e73:	83 ec 0c             	sub    $0xc,%esp
f0102e76:	ff 75 f4             	pushl  -0xc(%ebp)
f0102e79:	e8 21 ff ff ff       	call   f0102d9f <set_environment_entry_point>
f0102e7e:	83 c4 10             	add    $0x10,%esp

	lcr3(K_PHYSICAL_ADDRESS(ptr_page_directory));
f0102e81:	a1 84 e7 14 f0       	mov    0xf014e784,%eax
f0102e86:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102e89:	81 7d f0 ff ff ff ef 	cmpl   $0xefffffff,-0x10(%ebp)
f0102e90:	77 17                	ja     f0102ea9 <env_run_cmd_prmpt+0x9d>
f0102e92:	ff 75 f0             	pushl  -0x10(%ebp)
f0102e95:	68 dc 5c 10 f0       	push   $0xf0105cdc
f0102e9a:	68 04 02 00 00       	push   $0x204
f0102e9f:	68 19 5c 10 f0       	push   $0xf0105c19
f0102ea4:	e8 85 d2 ff ff       	call   f010012e <_panic>
f0102ea9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102eac:	05 00 00 00 10       	add    $0x10000000,%eax
f0102eb1:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102eb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102eb7:	0f 22 d8             	mov    %eax,%cr3

	curenv = NULL;
f0102eba:	c7 05 f0 de 14 f0 00 	movl   $0x0,0xf014def0
f0102ec1:	00 00 00 

	while (1)
		run_command_prompt();
f0102ec4:	e8 88 da ff ff       	call   f0100951 <run_command_prompt>
f0102ec9:	eb f9                	jmp    f0102ec4 <env_run_cmd_prmpt+0xb8>

f0102ecb <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102ecb:	55                   	push   %ebp
f0102ecc:	89 e5                	mov    %esp,%ebp
f0102ece:	83 ec 08             	sub    $0x8,%esp
	__asm __volatile("movl %0,%%esp\n"
f0102ed1:	8b 65 08             	mov    0x8(%ebp),%esp
f0102ed4:	61                   	popa   
f0102ed5:	07                   	pop    %es
f0102ed6:	1f                   	pop    %ds
f0102ed7:	83 c4 08             	add    $0x8,%esp
f0102eda:	cf                   	iret   
			"\tpopl %%es\n"
			"\tpopl %%ds\n"
			"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
			"\tiret"
			: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102edb:	83 ec 04             	sub    $0x4,%esp
f0102ede:	68 0d 5d 10 f0       	push   $0xf0105d0d
f0102ee3:	68 1b 02 00 00       	push   $0x21b
f0102ee8:	68 19 5c 10 f0       	push   $0xf0105c19
f0102eed:	e8 3c d2 ff ff       	call   f010012e <_panic>

f0102ef2 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102ef2:	55                   	push   %ebp
f0102ef3:	89 e5                	mov    %esp,%ebp
f0102ef5:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
f0102ef8:	8b 45 08             	mov    0x8(%ebp),%eax
f0102efb:	0f b6 c0             	movzbl %al,%eax
f0102efe:	c7 45 fc 70 00 00 00 	movl   $0x70,-0x4(%ebp)
f0102f05:	88 45 f6             	mov    %al,-0xa(%ebp)
}

static __inline void
outb(int port, uint8 data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102f08:	8a 45 f6             	mov    -0xa(%ebp),%al
f0102f0b:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0102f0e:	ee                   	out    %al,(%dx)
f0102f0f:	c7 45 f8 71 00 00 00 	movl   $0x71,-0x8(%ebp)

static __inline uint8
inb(int port)
{
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102f16:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0102f19:	89 c2                	mov    %eax,%edx
f0102f1b:	ec                   	in     (%dx),%al
f0102f1c:	88 45 f7             	mov    %al,-0x9(%ebp)
	return data;
f0102f1f:	8a 45 f7             	mov    -0x9(%ebp),%al
	return inb(IO_RTC+1);
f0102f22:	0f b6 c0             	movzbl %al,%eax
}
f0102f25:	c9                   	leave  
f0102f26:	c3                   	ret    

f0102f27 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102f27:	55                   	push   %ebp
f0102f28:	89 e5                	mov    %esp,%ebp
f0102f2a:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
f0102f2d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f30:	0f b6 c0             	movzbl %al,%eax
f0102f33:	c7 45 fc 70 00 00 00 	movl   $0x70,-0x4(%ebp)
f0102f3a:	88 45 f6             	mov    %al,-0xa(%ebp)
}

static __inline void
outb(int port, uint8 data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102f3d:	8a 45 f6             	mov    -0xa(%ebp),%al
f0102f40:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0102f43:	ee                   	out    %al,(%dx)
	outb(IO_RTC+1, datum);
f0102f44:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f47:	0f b6 c0             	movzbl %al,%eax
f0102f4a:	c7 45 f8 71 00 00 00 	movl   $0x71,-0x8(%ebp)
f0102f51:	88 45 f7             	mov    %al,-0x9(%ebp)
f0102f54:	8a 45 f7             	mov    -0x9(%ebp),%al
f0102f57:	8b 55 f8             	mov    -0x8(%ebp),%edx
f0102f5a:	ee                   	out    %al,(%dx)
}
f0102f5b:	90                   	nop
f0102f5c:	c9                   	leave  
f0102f5d:	c3                   	ret    

f0102f5e <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102f5e:	55                   	push   %ebp
f0102f5f:	89 e5                	mov    %esp,%ebp
f0102f61:	83 ec 08             	sub    $0x8,%esp
	cputchar(ch);
f0102f64:	83 ec 0c             	sub    $0xc,%esp
f0102f67:	ff 75 08             	pushl  0x8(%ebp)
f0102f6a:	e8 a8 d9 ff ff       	call   f0100917 <cputchar>
f0102f6f:	83 c4 10             	add    $0x10,%esp
	*cnt++;
f0102f72:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f75:	83 c0 04             	add    $0x4,%eax
f0102f78:	89 45 0c             	mov    %eax,0xc(%ebp)
}
f0102f7b:	90                   	nop
f0102f7c:	c9                   	leave  
f0102f7d:	c3                   	ret    

f0102f7e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102f7e:	55                   	push   %ebp
f0102f7f:	89 e5                	mov    %esp,%ebp
f0102f81:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102f84:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102f8b:	ff 75 0c             	pushl  0xc(%ebp)
f0102f8e:	ff 75 08             	pushl  0x8(%ebp)
f0102f91:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102f94:	50                   	push   %eax
f0102f95:	68 5e 2f 10 f0       	push   $0xf0102f5e
f0102f9a:	e8 56 0f 00 00       	call   f0103ef5 <vprintfmt>
f0102f9f:	83 c4 10             	add    $0x10,%esp
	return cnt;
f0102fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0102fa5:	c9                   	leave  
f0102fa6:	c3                   	ret    

f0102fa7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102fa7:	55                   	push   %ebp
f0102fa8:	89 e5                	mov    %esp,%ebp
f0102faa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102fad:	8d 45 0c             	lea    0xc(%ebp),%eax
f0102fb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
f0102fb3:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fb6:	83 ec 08             	sub    $0x8,%esp
f0102fb9:	ff 75 f4             	pushl  -0xc(%ebp)
f0102fbc:	50                   	push   %eax
f0102fbd:	e8 bc ff ff ff       	call   f0102f7e <vcprintf>
f0102fc2:	83 c4 10             	add    $0x10,%esp
f0102fc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
f0102fc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
f0102fcb:	c9                   	leave  
f0102fcc:	c3                   	ret    

f0102fcd <trapname>:
};
extern  void (*PAGE_FAULT)();
extern  void (*SYSCALL_HANDLER)();

static const char *trapname(int trapno)
{
f0102fcd:	55                   	push   %ebp
f0102fce:	89 e5                	mov    %esp,%ebp
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0102fd0:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fd3:	83 f8 13             	cmp    $0x13,%eax
f0102fd6:	77 0c                	ja     f0102fe4 <trapname+0x17>
		return excnames[trapno];
f0102fd8:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fdb:	8b 04 85 40 60 10 f0 	mov    -0xfef9fc0(,%eax,4),%eax
f0102fe2:	eb 12                	jmp    f0102ff6 <trapname+0x29>
	if (trapno == T_SYSCALL)
f0102fe4:	83 7d 08 30          	cmpl   $0x30,0x8(%ebp)
f0102fe8:	75 07                	jne    f0102ff1 <trapname+0x24>
		return "System call";
f0102fea:	b8 20 5d 10 f0       	mov    $0xf0105d20,%eax
f0102fef:	eb 05                	jmp    f0102ff6 <trapname+0x29>
	return "(unknown trap)";
f0102ff1:	b8 2c 5d 10 f0       	mov    $0xf0105d2c,%eax
}
f0102ff6:	5d                   	pop    %ebp
f0102ff7:	c3                   	ret    

f0102ff8 <idt_init>:


void
idt_init(void)
{
f0102ff8:	55                   	push   %ebp
f0102ff9:	89 e5                	mov    %esp,%ebp
f0102ffb:	83 ec 10             	sub    $0x10,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	//initialize idt
	SETGATE(idt[T_PGFLT], 0, GD_KT , &PAGE_FAULT, 0) ;
f0102ffe:	b8 56 35 10 f0       	mov    $0xf0103556,%eax
f0103003:	66 a3 70 df 14 f0    	mov    %ax,0xf014df70
f0103009:	66 c7 05 72 df 14 f0 	movw   $0x8,0xf014df72
f0103010:	08 00 
f0103012:	a0 74 df 14 f0       	mov    0xf014df74,%al
f0103017:	83 e0 e0             	and    $0xffffffe0,%eax
f010301a:	a2 74 df 14 f0       	mov    %al,0xf014df74
f010301f:	a0 74 df 14 f0       	mov    0xf014df74,%al
f0103024:	83 e0 1f             	and    $0x1f,%eax
f0103027:	a2 74 df 14 f0       	mov    %al,0xf014df74
f010302c:	a0 75 df 14 f0       	mov    0xf014df75,%al
f0103031:	83 e0 f0             	and    $0xfffffff0,%eax
f0103034:	83 c8 0e             	or     $0xe,%eax
f0103037:	a2 75 df 14 f0       	mov    %al,0xf014df75
f010303c:	a0 75 df 14 f0       	mov    0xf014df75,%al
f0103041:	83 e0 ef             	and    $0xffffffef,%eax
f0103044:	a2 75 df 14 f0       	mov    %al,0xf014df75
f0103049:	a0 75 df 14 f0       	mov    0xf014df75,%al
f010304e:	83 e0 9f             	and    $0xffffff9f,%eax
f0103051:	a2 75 df 14 f0       	mov    %al,0xf014df75
f0103056:	a0 75 df 14 f0       	mov    0xf014df75,%al
f010305b:	83 c8 80             	or     $0xffffff80,%eax
f010305e:	a2 75 df 14 f0       	mov    %al,0xf014df75
f0103063:	b8 56 35 10 f0       	mov    $0xf0103556,%eax
f0103068:	c1 e8 10             	shr    $0x10,%eax
f010306b:	66 a3 76 df 14 f0    	mov    %ax,0xf014df76
	SETGATE(idt[T_SYSCALL], 0, GD_KT , &SYSCALL_HANDLER, 3) ;
f0103071:	b8 5a 35 10 f0       	mov    $0xf010355a,%eax
f0103076:	66 a3 80 e0 14 f0    	mov    %ax,0xf014e080
f010307c:	66 c7 05 82 e0 14 f0 	movw   $0x8,0xf014e082
f0103083:	08 00 
f0103085:	a0 84 e0 14 f0       	mov    0xf014e084,%al
f010308a:	83 e0 e0             	and    $0xffffffe0,%eax
f010308d:	a2 84 e0 14 f0       	mov    %al,0xf014e084
f0103092:	a0 84 e0 14 f0       	mov    0xf014e084,%al
f0103097:	83 e0 1f             	and    $0x1f,%eax
f010309a:	a2 84 e0 14 f0       	mov    %al,0xf014e084
f010309f:	a0 85 e0 14 f0       	mov    0xf014e085,%al
f01030a4:	83 e0 f0             	and    $0xfffffff0,%eax
f01030a7:	83 c8 0e             	or     $0xe,%eax
f01030aa:	a2 85 e0 14 f0       	mov    %al,0xf014e085
f01030af:	a0 85 e0 14 f0       	mov    0xf014e085,%al
f01030b4:	83 e0 ef             	and    $0xffffffef,%eax
f01030b7:	a2 85 e0 14 f0       	mov    %al,0xf014e085
f01030bc:	a0 85 e0 14 f0       	mov    0xf014e085,%al
f01030c1:	83 c8 60             	or     $0x60,%eax
f01030c4:	a2 85 e0 14 f0       	mov    %al,0xf014e085
f01030c9:	a0 85 e0 14 f0       	mov    0xf014e085,%al
f01030ce:	83 c8 80             	or     $0xffffff80,%eax
f01030d1:	a2 85 e0 14 f0       	mov    %al,0xf014e085
f01030d6:	b8 5a 35 10 f0       	mov    $0xf010355a,%eax
f01030db:	c1 e8 10             	shr    $0x10,%eax
f01030de:	66 a3 86 e0 14 f0    	mov    %ax,0xf014e086

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KERNEL_STACK_TOP;
f01030e4:	c7 05 04 e7 14 f0 00 	movl   $0xefc00000,0xf014e704
f01030eb:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f01030ee:	66 c7 05 08 e7 14 f0 	movw   $0x10,0xf014e708
f01030f5:	10 00 

	// Initialize the TSS field of the gdt.
	gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32) (&ts),
f01030f7:	66 c7 05 28 b6 11 f0 	movw   $0x68,0xf011b628
f01030fe:	68 00 
f0103100:	b8 00 e7 14 f0       	mov    $0xf014e700,%eax
f0103105:	66 a3 2a b6 11 f0    	mov    %ax,0xf011b62a
f010310b:	b8 00 e7 14 f0       	mov    $0xf014e700,%eax
f0103110:	c1 e8 10             	shr    $0x10,%eax
f0103113:	a2 2c b6 11 f0       	mov    %al,0xf011b62c
f0103118:	a0 2d b6 11 f0       	mov    0xf011b62d,%al
f010311d:	83 e0 f0             	and    $0xfffffff0,%eax
f0103120:	83 c8 09             	or     $0x9,%eax
f0103123:	a2 2d b6 11 f0       	mov    %al,0xf011b62d
f0103128:	a0 2d b6 11 f0       	mov    0xf011b62d,%al
f010312d:	83 c8 10             	or     $0x10,%eax
f0103130:	a2 2d b6 11 f0       	mov    %al,0xf011b62d
f0103135:	a0 2d b6 11 f0       	mov    0xf011b62d,%al
f010313a:	83 e0 9f             	and    $0xffffff9f,%eax
f010313d:	a2 2d b6 11 f0       	mov    %al,0xf011b62d
f0103142:	a0 2d b6 11 f0       	mov    0xf011b62d,%al
f0103147:	83 c8 80             	or     $0xffffff80,%eax
f010314a:	a2 2d b6 11 f0       	mov    %al,0xf011b62d
f010314f:	a0 2e b6 11 f0       	mov    0xf011b62e,%al
f0103154:	83 e0 f0             	and    $0xfffffff0,%eax
f0103157:	a2 2e b6 11 f0       	mov    %al,0xf011b62e
f010315c:	a0 2e b6 11 f0       	mov    0xf011b62e,%al
f0103161:	83 e0 ef             	and    $0xffffffef,%eax
f0103164:	a2 2e b6 11 f0       	mov    %al,0xf011b62e
f0103169:	a0 2e b6 11 f0       	mov    0xf011b62e,%al
f010316e:	83 e0 df             	and    $0xffffffdf,%eax
f0103171:	a2 2e b6 11 f0       	mov    %al,0xf011b62e
f0103176:	a0 2e b6 11 f0       	mov    0xf011b62e,%al
f010317b:	83 c8 40             	or     $0x40,%eax
f010317e:	a2 2e b6 11 f0       	mov    %al,0xf011b62e
f0103183:	a0 2e b6 11 f0       	mov    0xf011b62e,%al
f0103188:	83 e0 7f             	and    $0x7f,%eax
f010318b:	a2 2e b6 11 f0       	mov    %al,0xf011b62e
f0103190:	b8 00 e7 14 f0       	mov    $0xf014e700,%eax
f0103195:	c1 e8 18             	shr    $0x18,%eax
f0103198:	a2 2f b6 11 f0       	mov    %al,0xf011b62f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS >> 3].sd_s = 0;
f010319d:	a0 2d b6 11 f0       	mov    0xf011b62d,%al
f01031a2:	83 e0 ef             	and    $0xffffffef,%eax
f01031a5:	a2 2d b6 11 f0       	mov    %al,0xf011b62d
f01031aa:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
}

static __inline void
ltr(uint16 sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01031b0:	66 8b 45 fe          	mov    -0x2(%ebp),%ax
f01031b4:	0f 00 d8             	ltr    %ax

	// Load the TSS
	ltr(GD_TSS);

	// Load the IDT
	asm volatile("lidt idt_pd");
f01031b7:	0f 01 1d 98 b6 11 f0 	lidtl  0xf011b698
}
f01031be:	90                   	nop
f01031bf:	c9                   	leave  
f01031c0:	c3                   	ret    

f01031c1 <print_trapframe>:

void
print_trapframe(struct Trapframe *tf)
{
f01031c1:	55                   	push   %ebp
f01031c2:	89 e5                	mov    %esp,%ebp
f01031c4:	83 ec 08             	sub    $0x8,%esp
	cprintf("TRAP frame at %p\n", tf);
f01031c7:	83 ec 08             	sub    $0x8,%esp
f01031ca:	ff 75 08             	pushl  0x8(%ebp)
f01031cd:	68 3b 5d 10 f0       	push   $0xf0105d3b
f01031d2:	e8 d0 fd ff ff       	call   f0102fa7 <cprintf>
f01031d7:	83 c4 10             	add    $0x10,%esp
	print_regs(&tf->tf_regs);
f01031da:	8b 45 08             	mov    0x8(%ebp),%eax
f01031dd:	83 ec 0c             	sub    $0xc,%esp
f01031e0:	50                   	push   %eax
f01031e1:	e8 f6 00 00 00       	call   f01032dc <print_regs>
f01031e6:	83 c4 10             	add    $0x10,%esp
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01031e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01031ec:	8b 40 20             	mov    0x20(%eax),%eax
f01031ef:	0f b7 c0             	movzwl %ax,%eax
f01031f2:	83 ec 08             	sub    $0x8,%esp
f01031f5:	50                   	push   %eax
f01031f6:	68 4d 5d 10 f0       	push   $0xf0105d4d
f01031fb:	e8 a7 fd ff ff       	call   f0102fa7 <cprintf>
f0103200:	83 c4 10             	add    $0x10,%esp
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103203:	8b 45 08             	mov    0x8(%ebp),%eax
f0103206:	8b 40 24             	mov    0x24(%eax),%eax
f0103209:	0f b7 c0             	movzwl %ax,%eax
f010320c:	83 ec 08             	sub    $0x8,%esp
f010320f:	50                   	push   %eax
f0103210:	68 60 5d 10 f0       	push   $0xf0105d60
f0103215:	e8 8d fd ff ff       	call   f0102fa7 <cprintf>
f010321a:	83 c4 10             	add    $0x10,%esp
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010321d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103220:	8b 40 28             	mov    0x28(%eax),%eax
f0103223:	83 ec 0c             	sub    $0xc,%esp
f0103226:	50                   	push   %eax
f0103227:	e8 a1 fd ff ff       	call   f0102fcd <trapname>
f010322c:	83 c4 10             	add    $0x10,%esp
f010322f:	89 c2                	mov    %eax,%edx
f0103231:	8b 45 08             	mov    0x8(%ebp),%eax
f0103234:	8b 40 28             	mov    0x28(%eax),%eax
f0103237:	83 ec 04             	sub    $0x4,%esp
f010323a:	52                   	push   %edx
f010323b:	50                   	push   %eax
f010323c:	68 73 5d 10 f0       	push   $0xf0105d73
f0103241:	e8 61 fd ff ff       	call   f0102fa7 <cprintf>
f0103246:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x\n", tf->tf_err);
f0103249:	8b 45 08             	mov    0x8(%ebp),%eax
f010324c:	8b 40 2c             	mov    0x2c(%eax),%eax
f010324f:	83 ec 08             	sub    $0x8,%esp
f0103252:	50                   	push   %eax
f0103253:	68 85 5d 10 f0       	push   $0xf0105d85
f0103258:	e8 4a fd ff ff       	call   f0102fa7 <cprintf>
f010325d:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103260:	8b 45 08             	mov    0x8(%ebp),%eax
f0103263:	8b 40 30             	mov    0x30(%eax),%eax
f0103266:	83 ec 08             	sub    $0x8,%esp
f0103269:	50                   	push   %eax
f010326a:	68 94 5d 10 f0       	push   $0xf0105d94
f010326f:	e8 33 fd ff ff       	call   f0102fa7 <cprintf>
f0103274:	83 c4 10             	add    $0x10,%esp
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103277:	8b 45 08             	mov    0x8(%ebp),%eax
f010327a:	8b 40 34             	mov    0x34(%eax),%eax
f010327d:	0f b7 c0             	movzwl %ax,%eax
f0103280:	83 ec 08             	sub    $0x8,%esp
f0103283:	50                   	push   %eax
f0103284:	68 a3 5d 10 f0       	push   $0xf0105da3
f0103289:	e8 19 fd ff ff       	call   f0102fa7 <cprintf>
f010328e:	83 c4 10             	add    $0x10,%esp
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103291:	8b 45 08             	mov    0x8(%ebp),%eax
f0103294:	8b 40 38             	mov    0x38(%eax),%eax
f0103297:	83 ec 08             	sub    $0x8,%esp
f010329a:	50                   	push   %eax
f010329b:	68 b6 5d 10 f0       	push   $0xf0105db6
f01032a0:	e8 02 fd ff ff       	call   f0102fa7 <cprintf>
f01032a5:	83 c4 10             	add    $0x10,%esp
	cprintf("  esp  0x%08x\n", tf->tf_esp);
f01032a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01032ab:	8b 40 3c             	mov    0x3c(%eax),%eax
f01032ae:	83 ec 08             	sub    $0x8,%esp
f01032b1:	50                   	push   %eax
f01032b2:	68 c5 5d 10 f0       	push   $0xf0105dc5
f01032b7:	e8 eb fc ff ff       	call   f0102fa7 <cprintf>
f01032bc:	83 c4 10             	add    $0x10,%esp
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01032bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01032c2:	8b 40 40             	mov    0x40(%eax),%eax
f01032c5:	0f b7 c0             	movzwl %ax,%eax
f01032c8:	83 ec 08             	sub    $0x8,%esp
f01032cb:	50                   	push   %eax
f01032cc:	68 d4 5d 10 f0       	push   $0xf0105dd4
f01032d1:	e8 d1 fc ff ff       	call   f0102fa7 <cprintf>
f01032d6:	83 c4 10             	add    $0x10,%esp
}
f01032d9:	90                   	nop
f01032da:	c9                   	leave  
f01032db:	c3                   	ret    

f01032dc <print_regs>:

void
print_regs(struct PushRegs *regs)
{
f01032dc:	55                   	push   %ebp
f01032dd:	89 e5                	mov    %esp,%ebp
f01032df:	83 ec 08             	sub    $0x8,%esp
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01032e2:	8b 45 08             	mov    0x8(%ebp),%eax
f01032e5:	8b 00                	mov    (%eax),%eax
f01032e7:	83 ec 08             	sub    $0x8,%esp
f01032ea:	50                   	push   %eax
f01032eb:	68 e7 5d 10 f0       	push   $0xf0105de7
f01032f0:	e8 b2 fc ff ff       	call   f0102fa7 <cprintf>
f01032f5:	83 c4 10             	add    $0x10,%esp
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01032f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01032fb:	8b 40 04             	mov    0x4(%eax),%eax
f01032fe:	83 ec 08             	sub    $0x8,%esp
f0103301:	50                   	push   %eax
f0103302:	68 f6 5d 10 f0       	push   $0xf0105df6
f0103307:	e8 9b fc ff ff       	call   f0102fa7 <cprintf>
f010330c:	83 c4 10             	add    $0x10,%esp
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010330f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103312:	8b 40 08             	mov    0x8(%eax),%eax
f0103315:	83 ec 08             	sub    $0x8,%esp
f0103318:	50                   	push   %eax
f0103319:	68 05 5e 10 f0       	push   $0xf0105e05
f010331e:	e8 84 fc ff ff       	call   f0102fa7 <cprintf>
f0103323:	83 c4 10             	add    $0x10,%esp
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103326:	8b 45 08             	mov    0x8(%ebp),%eax
f0103329:	8b 40 0c             	mov    0xc(%eax),%eax
f010332c:	83 ec 08             	sub    $0x8,%esp
f010332f:	50                   	push   %eax
f0103330:	68 14 5e 10 f0       	push   $0xf0105e14
f0103335:	e8 6d fc ff ff       	call   f0102fa7 <cprintf>
f010333a:	83 c4 10             	add    $0x10,%esp
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010333d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103340:	8b 40 10             	mov    0x10(%eax),%eax
f0103343:	83 ec 08             	sub    $0x8,%esp
f0103346:	50                   	push   %eax
f0103347:	68 23 5e 10 f0       	push   $0xf0105e23
f010334c:	e8 56 fc ff ff       	call   f0102fa7 <cprintf>
f0103351:	83 c4 10             	add    $0x10,%esp
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103354:	8b 45 08             	mov    0x8(%ebp),%eax
f0103357:	8b 40 14             	mov    0x14(%eax),%eax
f010335a:	83 ec 08             	sub    $0x8,%esp
f010335d:	50                   	push   %eax
f010335e:	68 32 5e 10 f0       	push   $0xf0105e32
f0103363:	e8 3f fc ff ff       	call   f0102fa7 <cprintf>
f0103368:	83 c4 10             	add    $0x10,%esp
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010336b:	8b 45 08             	mov    0x8(%ebp),%eax
f010336e:	8b 40 18             	mov    0x18(%eax),%eax
f0103371:	83 ec 08             	sub    $0x8,%esp
f0103374:	50                   	push   %eax
f0103375:	68 41 5e 10 f0       	push   $0xf0105e41
f010337a:	e8 28 fc ff ff       	call   f0102fa7 <cprintf>
f010337f:	83 c4 10             	add    $0x10,%esp
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103382:	8b 45 08             	mov    0x8(%ebp),%eax
f0103385:	8b 40 1c             	mov    0x1c(%eax),%eax
f0103388:	83 ec 08             	sub    $0x8,%esp
f010338b:	50                   	push   %eax
f010338c:	68 50 5e 10 f0       	push   $0xf0105e50
f0103391:	e8 11 fc ff ff       	call   f0102fa7 <cprintf>
f0103396:	83 c4 10             	add    $0x10,%esp
}
f0103399:	90                   	nop
f010339a:	c9                   	leave  
f010339b:	c3                   	ret    

f010339c <trap_dispatch>:

static void
trap_dispatch(struct Trapframe *tf)
{
f010339c:	55                   	push   %ebp
f010339d:	89 e5                	mov    %esp,%ebp
f010339f:	57                   	push   %edi
f01033a0:	56                   	push   %esi
f01033a1:	53                   	push   %ebx
f01033a2:	83 ec 1c             	sub    $0x1c,%esp
	// Handle processor exceptions.
	// LAB 3: Your code here.

	if(tf->tf_trapno == T_PGFLT)
f01033a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01033a8:	8b 40 28             	mov    0x28(%eax),%eax
f01033ab:	83 f8 0e             	cmp    $0xe,%eax
f01033ae:	75 13                	jne    f01033c3 <trap_dispatch+0x27>
	{
		page_fault_handler(tf);
f01033b0:	83 ec 0c             	sub    $0xc,%esp
f01033b3:	ff 75 08             	pushl  0x8(%ebp)
f01033b6:	e8 47 01 00 00       	call   f0103502 <page_fault_handler>
f01033bb:	83 c4 10             	add    $0x10,%esp
		else {
			env_destroy(curenv);
			return;
		}
	}
	return;
f01033be:	e9 90 00 00 00       	jmp    f0103453 <trap_dispatch+0xb7>

	if(tf->tf_trapno == T_PGFLT)
	{
		page_fault_handler(tf);
	}
	else if (tf->tf_trapno == T_SYSCALL)
f01033c3:	8b 45 08             	mov    0x8(%ebp),%eax
f01033c6:	8b 40 28             	mov    0x28(%eax),%eax
f01033c9:	83 f8 30             	cmp    $0x30,%eax
f01033cc:	75 42                	jne    f0103410 <trap_dispatch+0x74>
	{
		uint32 ret = syscall(tf->tf_regs.reg_eax
f01033ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01033d1:	8b 78 04             	mov    0x4(%eax),%edi
f01033d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01033d7:	8b 30                	mov    (%eax),%esi
f01033d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01033dc:	8b 58 10             	mov    0x10(%eax),%ebx
f01033df:	8b 45 08             	mov    0x8(%ebp),%eax
f01033e2:	8b 48 18             	mov    0x18(%eax),%ecx
f01033e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01033e8:	8b 50 14             	mov    0x14(%eax),%edx
f01033eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01033ee:	8b 40 1c             	mov    0x1c(%eax),%eax
f01033f1:	83 ec 08             	sub    $0x8,%esp
f01033f4:	57                   	push   %edi
f01033f5:	56                   	push   %esi
f01033f6:	53                   	push   %ebx
f01033f7:	51                   	push   %ecx
f01033f8:	52                   	push   %edx
f01033f9:	50                   	push   %eax
f01033fa:	e8 47 04 00 00       	call   f0103846 <syscall>
f01033ff:	83 c4 20             	add    $0x20,%esp
f0103402:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			,tf->tf_regs.reg_edx
			,tf->tf_regs.reg_ecx
			,tf->tf_regs.reg_ebx
			,tf->tf_regs.reg_edi
					,tf->tf_regs.reg_esi);
		tf->tf_regs.reg_eax = ret;
f0103405:	8b 45 08             	mov    0x8(%ebp),%eax
f0103408:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010340b:	89 50 1c             	mov    %edx,0x1c(%eax)
		else {
			env_destroy(curenv);
			return;
		}
	}
	return;
f010340e:	eb 43                	jmp    f0103453 <trap_dispatch+0xb7>
		tf->tf_regs.reg_eax = ret;
	}
	else
	{
		// Unexpected trap: The user process or the kernel has a bug.
		print_trapframe(tf);
f0103410:	83 ec 0c             	sub    $0xc,%esp
f0103413:	ff 75 08             	pushl  0x8(%ebp)
f0103416:	e8 a6 fd ff ff       	call   f01031c1 <print_trapframe>
f010341b:	83 c4 10             	add    $0x10,%esp
		if (tf->tf_cs == GD_KT)
f010341e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103421:	8b 40 34             	mov    0x34(%eax),%eax
f0103424:	66 83 f8 08          	cmp    $0x8,%ax
f0103428:	75 17                	jne    f0103441 <trap_dispatch+0xa5>
			panic("unhandled trap in kernel");
f010342a:	83 ec 04             	sub    $0x4,%esp
f010342d:	68 5f 5e 10 f0       	push   $0xf0105e5f
f0103432:	68 8a 00 00 00       	push   $0x8a
f0103437:	68 78 5e 10 f0       	push   $0xf0105e78
f010343c:	e8 ed cc ff ff       	call   f010012e <_panic>
		else {
			env_destroy(curenv);
f0103441:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f0103446:	83 ec 0c             	sub    $0xc,%esp
f0103449:	50                   	push   %eax
f010344a:	e8 a2 f9 ff ff       	call   f0102df1 <env_destroy>
f010344f:	83 c4 10             	add    $0x10,%esp
			return;
f0103452:	90                   	nop
		}
	}
	return;
}
f0103453:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103456:	5b                   	pop    %ebx
f0103457:	5e                   	pop    %esi
f0103458:	5f                   	pop    %edi
f0103459:	5d                   	pop    %ebp
f010345a:	c3                   	ret    

f010345b <trap>:

void
trap(struct Trapframe *tf)
{
f010345b:	55                   	push   %ebp
f010345c:	89 e5                	mov    %esp,%ebp
f010345e:	57                   	push   %edi
f010345f:	56                   	push   %esi
f0103460:	53                   	push   %ebx
f0103461:	83 ec 0c             	sub    $0xc,%esp
	//cprintf("Incoming TRAP frame at %p\n", tf);

	if ((tf->tf_cs & 3) == 3) {
f0103464:	8b 45 08             	mov    0x8(%ebp),%eax
f0103467:	8b 40 34             	mov    0x34(%eax),%eax
f010346a:	0f b7 c0             	movzwl %ax,%eax
f010346d:	83 e0 03             	and    $0x3,%eax
f0103470:	83 f8 03             	cmp    $0x3,%eax
f0103473:	75 42                	jne    f01034b7 <trap+0x5c>
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
f0103475:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f010347a:	85 c0                	test   %eax,%eax
f010347c:	75 19                	jne    f0103497 <trap+0x3c>
f010347e:	68 84 5e 10 f0       	push   $0xf0105e84
f0103483:	68 8b 5e 10 f0       	push   $0xf0105e8b
f0103488:	68 9d 00 00 00       	push   $0x9d
f010348d:	68 78 5e 10 f0       	push   $0xf0105e78
f0103492:	e8 97 cc ff ff       	call   f010012e <_panic>
		curenv->env_tf = *tf;
f0103497:	8b 15 f0 de 14 f0    	mov    0xf014def0,%edx
f010349d:	8b 45 08             	mov    0x8(%ebp),%eax
f01034a0:	89 c3                	mov    %eax,%ebx
f01034a2:	b8 11 00 00 00       	mov    $0x11,%eax
f01034a7:	89 d7                	mov    %edx,%edi
f01034a9:	89 de                	mov    %ebx,%esi
f01034ab:	89 c1                	mov    %eax,%ecx
f01034ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01034af:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f01034b4:	89 45 08             	mov    %eax,0x8(%ebp)
	}

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
f01034b7:	83 ec 0c             	sub    $0xc,%esp
f01034ba:	ff 75 08             	pushl  0x8(%ebp)
f01034bd:	e8 da fe ff ff       	call   f010339c <trap_dispatch>
f01034c2:	83 c4 10             	add    $0x10,%esp

        // Return to the current environment, which should be runnable.
        assert(curenv && curenv->env_status == ENV_RUNNABLE);
f01034c5:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f01034ca:	85 c0                	test   %eax,%eax
f01034cc:	74 0d                	je     f01034db <trap+0x80>
f01034ce:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f01034d3:	8b 40 54             	mov    0x54(%eax),%eax
f01034d6:	83 f8 01             	cmp    $0x1,%eax
f01034d9:	74 19                	je     f01034f4 <trap+0x99>
f01034db:	68 a0 5e 10 f0       	push   $0xf0105ea0
f01034e0:	68 8b 5e 10 f0       	push   $0xf0105e8b
f01034e5:	68 a7 00 00 00       	push   $0xa7
f01034ea:	68 78 5e 10 f0       	push   $0xf0105e78
f01034ef:	e8 3a cc ff ff       	call   f010012e <_panic>
        env_run(curenv);
f01034f4:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f01034f9:	83 ec 0c             	sub    $0xc,%esp
f01034fc:	50                   	push   %eax
f01034fd:	e8 fd f2 ff ff       	call   f01027ff <env_run>

f0103502 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103502:	55                   	push   %ebp
f0103503:	89 e5                	mov    %esp,%ebp
f0103505:	83 ec 18             	sub    $0x18,%esp

static __inline uint32
rcr2(void)
{
	uint32 val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103508:	0f 20 d0             	mov    %cr2,%eax
f010350b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	return val;
f010350e:	8b 45 f0             	mov    -0x10(%ebp),%eax
	uint32 fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();
f0103511:	89 45 f4             	mov    %eax,-0xc(%ebp)
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103514:	8b 45 08             	mov    0x8(%ebp),%eax
f0103517:	8b 50 30             	mov    0x30(%eax),%edx
	curenv->env_id, fault_va, tf->tf_eip);
f010351a:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010351f:	8b 40 4c             	mov    0x4c(%eax),%eax
f0103522:	52                   	push   %edx
f0103523:	ff 75 f4             	pushl  -0xc(%ebp)
f0103526:	50                   	push   %eax
f0103527:	68 d0 5e 10 f0       	push   $0xf0105ed0
f010352c:	e8 76 fa ff ff       	call   f0102fa7 <cprintf>
f0103531:	83 c4 10             	add    $0x10,%esp
	curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103534:	83 ec 0c             	sub    $0xc,%esp
f0103537:	ff 75 08             	pushl  0x8(%ebp)
f010353a:	e8 82 fc ff ff       	call   f01031c1 <print_trapframe>
f010353f:	83 c4 10             	add    $0x10,%esp
	env_destroy(curenv);
f0103542:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f0103547:	83 ec 0c             	sub    $0xc,%esp
f010354a:	50                   	push   %eax
f010354b:	e8 a1 f8 ff ff       	call   f0102df1 <env_destroy>
f0103550:	83 c4 10             	add    $0x10,%esp

}
f0103553:	90                   	nop
f0103554:	c9                   	leave  
f0103555:	c3                   	ret    

f0103556 <PAGE_FAULT>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER(PAGE_FAULT, T_PGFLT)		
f0103556:	6a 0e                	push   $0xe
f0103558:	eb 06                	jmp    f0103560 <_alltraps>

f010355a <SYSCALL_HANDLER>:

TRAPHANDLER_NOEC(SYSCALL_HANDLER, T_SYSCALL)
f010355a:	6a 00                	push   $0x0
f010355c:	6a 30                	push   $0x30
f010355e:	eb 00                	jmp    f0103560 <_alltraps>

f0103560 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:

push %ds 
f0103560:	1e                   	push   %ds
push %es 
f0103561:	06                   	push   %es
pushal 	
f0103562:	60                   	pusha  

mov $(GD_KD), %ax 
f0103563:	66 b8 10 00          	mov    $0x10,%ax
mov %ax,%ds
f0103567:	8e d8                	mov    %eax,%ds
mov %ax,%es
f0103569:	8e c0                	mov    %eax,%es

push %esp
f010356b:	54                   	push   %esp

call trap
f010356c:	e8 ea fe ff ff       	call   f010345b <trap>

pop %ecx /* poping the pointer to the tf from the stack so that the stack top is at the values of the registers posuhed by pusha*/
f0103571:	59                   	pop    %ecx
popal 	
f0103572:	61                   	popa   
pop %es 
f0103573:	07                   	pop    %es
pop %ds    
f0103574:	1f                   	pop    %ds

/*skipping the trap_no and the error code so that the stack top is at the old eip value*/
add $(8),%esp
f0103575:	83 c4 08             	add    $0x8,%esp

iret
f0103578:	cf                   	iret   

f0103579 <to_frame_number>:
void	unmap_frame(uint32 *pgdir, void *va);
struct Frame_Info *get_frame_info(uint32 *ptr_page_directory, void *virtual_address, uint32 **ptr_page_table);
void decrement_references(struct Frame_Info* ptr_frame_info);

static inline uint32 to_frame_number(struct Frame_Info *ptr_frame_info)
{
f0103579:	55                   	push   %ebp
f010357a:	89 e5                	mov    %esp,%ebp
	return ptr_frame_info - frames_info;
f010357c:	8b 45 08             	mov    0x8(%ebp),%eax
f010357f:	8b 15 7c e7 14 f0    	mov    0xf014e77c,%edx
f0103585:	29 d0                	sub    %edx,%eax
f0103587:	c1 f8 02             	sar    $0x2,%eax
f010358a:	89 c2                	mov    %eax,%edx
f010358c:	89 d0                	mov    %edx,%eax
f010358e:	c1 e0 02             	shl    $0x2,%eax
f0103591:	01 d0                	add    %edx,%eax
f0103593:	c1 e0 02             	shl    $0x2,%eax
f0103596:	01 d0                	add    %edx,%eax
f0103598:	c1 e0 02             	shl    $0x2,%eax
f010359b:	01 d0                	add    %edx,%eax
f010359d:	89 c1                	mov    %eax,%ecx
f010359f:	c1 e1 08             	shl    $0x8,%ecx
f01035a2:	01 c8                	add    %ecx,%eax
f01035a4:	89 c1                	mov    %eax,%ecx
f01035a6:	c1 e1 10             	shl    $0x10,%ecx
f01035a9:	01 c8                	add    %ecx,%eax
f01035ab:	01 c0                	add    %eax,%eax
f01035ad:	01 d0                	add    %edx,%eax
}
f01035af:	5d                   	pop    %ebp
f01035b0:	c3                   	ret    

f01035b1 <to_physical_address>:

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f01035b1:	55                   	push   %ebp
f01035b2:	89 e5                	mov    %esp,%ebp
	return to_frame_number(ptr_frame_info) << PGSHIFT;
f01035b4:	ff 75 08             	pushl  0x8(%ebp)
f01035b7:	e8 bd ff ff ff       	call   f0103579 <to_frame_number>
f01035bc:	83 c4 04             	add    $0x4,%esp
f01035bf:	c1 e0 0c             	shl    $0xc,%eax
}
f01035c2:	c9                   	leave  
f01035c3:	c3                   	ret    

f01035c4 <sys_cputs>:

// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void sys_cputs(const char *s, uint32 len)
{
f01035c4:	55                   	push   %ebp
f01035c5:	89 e5                	mov    %esp,%ebp
f01035c7:	83 ec 08             	sub    $0x8,%esp
	// Destroy the environment if not.
	
	// LAB 3: Your code here.

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01035ca:	83 ec 04             	sub    $0x4,%esp
f01035cd:	ff 75 08             	pushl  0x8(%ebp)
f01035d0:	ff 75 0c             	pushl  0xc(%ebp)
f01035d3:	68 90 60 10 f0       	push   $0xf0106090
f01035d8:	e8 ca f9 ff ff       	call   f0102fa7 <cprintf>
f01035dd:	83 c4 10             	add    $0x10,%esp
}
f01035e0:	90                   	nop
f01035e1:	c9                   	leave  
f01035e2:	c3                   	ret    

f01035e3 <sys_cgetc>:

// Read a character from the system console.
// Returns the character.
static int
sys_cgetc(void)
{
f01035e3:	55                   	push   %ebp
f01035e4:	89 e5                	mov    %esp,%ebp
f01035e6:	83 ec 18             	sub    $0x18,%esp
	int c;

	// The cons_getc() primitive doesn't wait for a character,
	// but the sys_cgetc() system call does.
	while ((c = cons_getc()) == 0)
f01035e9:	e8 7b d2 ff ff       	call   f0100869 <cons_getc>
f01035ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01035f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f01035f5:	74 f2                	je     f01035e9 <sys_cgetc+0x6>
		/* do nothing */;

	return c;
f01035f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f01035fa:	c9                   	leave  
f01035fb:	c3                   	ret    

f01035fc <sys_getenvid>:

// Returns the current environment's envid.
static int32 sys_getenvid(void)
{
f01035fc:	55                   	push   %ebp
f01035fd:	89 e5                	mov    %esp,%ebp
	return curenv->env_id;
f01035ff:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f0103604:	8b 40 4c             	mov    0x4c(%eax),%eax
}
f0103607:	5d                   	pop    %ebp
f0103608:	c3                   	ret    

f0103609 <sys_env_destroy>:
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int sys_env_destroy(int32  envid)
{
f0103609:	55                   	push   %ebp
f010360a:	89 e5                	mov    %esp,%ebp
f010360c:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010360f:	83 ec 04             	sub    $0x4,%esp
f0103612:	6a 01                	push   $0x1
f0103614:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0103617:	50                   	push   %eax
f0103618:	ff 75 08             	pushl  0x8(%ebp)
f010361b:	e8 44 e5 ff ff       	call   f0101b64 <envid2env>
f0103620:	83 c4 10             	add    $0x10,%esp
f0103623:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0103626:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010362a:	79 05                	jns    f0103631 <sys_env_destroy+0x28>
		return r;
f010362c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010362f:	eb 5b                	jmp    f010368c <sys_env_destroy+0x83>
	if (e == curenv)
f0103631:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103634:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f0103639:	39 c2                	cmp    %eax,%edx
f010363b:	75 1b                	jne    f0103658 <sys_env_destroy+0x4f>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010363d:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f0103642:	8b 40 4c             	mov    0x4c(%eax),%eax
f0103645:	83 ec 08             	sub    $0x8,%esp
f0103648:	50                   	push   %eax
f0103649:	68 95 60 10 f0       	push   $0xf0106095
f010364e:	e8 54 f9 ff ff       	call   f0102fa7 <cprintf>
f0103653:	83 c4 10             	add    $0x10,%esp
f0103656:	eb 20                	jmp    f0103678 <sys_env_destroy+0x6f>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103658:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010365b:	8b 50 4c             	mov    0x4c(%eax),%edx
f010365e:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f0103663:	8b 40 4c             	mov    0x4c(%eax),%eax
f0103666:	83 ec 04             	sub    $0x4,%esp
f0103669:	52                   	push   %edx
f010366a:	50                   	push   %eax
f010366b:	68 b0 60 10 f0       	push   $0xf01060b0
f0103670:	e8 32 f9 ff ff       	call   f0102fa7 <cprintf>
f0103675:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0103678:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010367b:	83 ec 0c             	sub    $0xc,%esp
f010367e:	50                   	push   %eax
f010367f:	e8 6d f7 ff ff       	call   f0102df1 <env_destroy>
f0103684:	83 c4 10             	add    $0x10,%esp
	return 0;
f0103687:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010368c:	c9                   	leave  
f010368d:	c3                   	ret    

f010368e <sys_env_sleep>:

static void sys_env_sleep()
{
f010368e:	55                   	push   %ebp
f010368f:	89 e5                	mov    %esp,%ebp
f0103691:	83 ec 08             	sub    $0x8,%esp
	env_run_cmd_prmpt();
f0103694:	e8 73 f7 ff ff       	call   f0102e0c <env_run_cmd_prmpt>
}
f0103699:	90                   	nop
f010369a:	c9                   	leave  
f010369b:	c3                   	ret    

f010369c <sys_allocate_page>:
//	E_INVAL if va >= UTOP, or va is not page-aligned.
//	E_INVAL if perm is inappropriate (see above).
//	E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int sys_allocate_page(void *va, int perm)
{
f010369c:	55                   	push   %ebp
f010369d:	89 e5                	mov    %esp,%ebp
f010369f:	83 ec 28             	sub    $0x28,%esp
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!
	
	int r;
	struct Env *e = curenv;
f01036a2:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f01036a7:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//if ((r = envid2env(envid, &e, 1)) < 0)
		//return r;
	
	struct Frame_Info *ptr_frame_info ;
	r = allocate_frame(&ptr_frame_info) ;
f01036aa:	83 ec 0c             	sub    $0xc,%esp
f01036ad:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01036b0:	50                   	push   %eax
f01036b1:	e8 3c ec ff ff       	call   f01022f2 <allocate_frame>
f01036b6:	83 c4 10             	add    $0x10,%esp
f01036b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (r == E_NO_MEM)
f01036bc:	83 7d f0 fc          	cmpl   $0xfffffffc,-0x10(%ebp)
f01036c0:	75 08                	jne    f01036ca <sys_allocate_page+0x2e>
		return r ;
f01036c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01036c5:	e9 cc 00 00 00       	jmp    f0103796 <sys_allocate_page+0xfa>
	
	//check virtual address to be paged_aligned and < USER_TOP
	if ((uint32)va >= USER_TOP || (uint32)va % PAGE_SIZE != 0)
f01036ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01036cd:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f01036d2:	77 0c                	ja     f01036e0 <sys_allocate_page+0x44>
f01036d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01036d7:	25 ff 0f 00 00       	and    $0xfff,%eax
f01036dc:	85 c0                	test   %eax,%eax
f01036de:	74 0a                	je     f01036ea <sys_allocate_page+0x4e>
		return E_INVAL;
f01036e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01036e5:	e9 ac 00 00 00       	jmp    f0103796 <sys_allocate_page+0xfa>
	
	//check permissions to be appropriatess
	if ((perm & (~PERM_AVAILABLE & ~PERM_WRITEABLE)) != (PERM_USER))
f01036ea:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036ed:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01036f2:	83 f8 04             	cmp    $0x4,%eax
f01036f5:	74 0a                	je     f0103701 <sys_allocate_page+0x65>
		return E_INVAL;
f01036f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01036fc:	e9 95 00 00 00       	jmp    f0103796 <sys_allocate_page+0xfa>
	
			
	uint32 physical_address = to_physical_address(ptr_frame_info) ;
f0103701:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103704:	83 ec 0c             	sub    $0xc,%esp
f0103707:	50                   	push   %eax
f0103708:	e8 a4 fe ff ff       	call   f01035b1 <to_physical_address>
f010370d:	83 c4 10             	add    $0x10,%esp
f0103710:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	memset(K_VIRTUAL_ADDRESS(physical_address), 0, PAGE_SIZE);
f0103713:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103716:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0103719:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010371c:	c1 e8 0c             	shr    $0xc,%eax
f010371f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103722:	a1 68 e7 14 f0       	mov    0xf014e768,%eax
f0103727:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f010372a:	72 14                	jb     f0103740 <sys_allocate_page+0xa4>
f010372c:	ff 75 e8             	pushl  -0x18(%ebp)
f010372f:	68 c8 60 10 f0       	push   $0xf01060c8
f0103734:	6a 7a                	push   $0x7a
f0103736:	68 f7 60 10 f0       	push   $0xf01060f7
f010373b:	e8 ee c9 ff ff       	call   f010012e <_panic>
f0103740:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103743:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103748:	83 ec 04             	sub    $0x4,%esp
f010374b:	68 00 10 00 00       	push   $0x1000
f0103750:	6a 00                	push   $0x0
f0103752:	50                   	push   %eax
f0103753:	e8 62 0f 00 00       	call   f01046ba <memset>
f0103758:	83 c4 10             	add    $0x10,%esp
		
	r = map_frame(e->env_pgdir, ptr_frame_info, va, perm) ;
f010375b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010375e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103761:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103764:	ff 75 0c             	pushl  0xc(%ebp)
f0103767:	ff 75 08             	pushl  0x8(%ebp)
f010376a:	52                   	push   %edx
f010376b:	50                   	push   %eax
f010376c:	e8 8e ed ff ff       	call   f01024ff <map_frame>
f0103771:	83 c4 10             	add    $0x10,%esp
f0103774:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (r == E_NO_MEM)
f0103777:	83 7d f0 fc          	cmpl   $0xfffffffc,-0x10(%ebp)
f010377b:	75 14                	jne    f0103791 <sys_allocate_page+0xf5>
	{
		decrement_references(ptr_frame_info);
f010377d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103780:	83 ec 0c             	sub    $0xc,%esp
f0103783:	50                   	push   %eax
f0103784:	e8 07 ec ff ff       	call   f0102390 <decrement_references>
f0103789:	83 c4 10             	add    $0x10,%esp
		return r;
f010378c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010378f:	eb 05                	jmp    f0103796 <sys_allocate_page+0xfa>
	}
	return 0 ;
f0103791:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103796:	c9                   	leave  
f0103797:	c3                   	ret    

f0103798 <sys_get_page>:
//	E_INVAL if va >= UTOP, or va is not page-aligned.
//	E_INVAL if perm is inappropriate (see above).
//	E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int sys_get_page(void *va, int perm)
{
f0103798:	55                   	push   %ebp
f0103799:	89 e5                	mov    %esp,%ebp
f010379b:	83 ec 08             	sub    $0x8,%esp
	return get_page(curenv->env_pgdir, va, perm) ;
f010379e:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f01037a3:	8b 40 5c             	mov    0x5c(%eax),%eax
f01037a6:	83 ec 04             	sub    $0x4,%esp
f01037a9:	ff 75 0c             	pushl  0xc(%ebp)
f01037ac:	ff 75 08             	pushl  0x8(%ebp)
f01037af:	50                   	push   %eax
f01037b0:	e8 c8 ee ff ff       	call   f010267d <get_page>
f01037b5:	83 c4 10             	add    $0x10,%esp
}
f01037b8:	c9                   	leave  
f01037b9:	c3                   	ret    

f01037ba <sys_map_frame>:
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
//		address space.
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int sys_map_frame(int32 srcenvid, void *srcva, int32 dstenvid, void *dstva, int perm)
{
f01037ba:	55                   	push   %ebp
f01037bb:	89 e5                	mov    %esp,%ebp
f01037bd:	83 ec 08             	sub    $0x8,%esp
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	panic("sys_map_frame not implemented");
f01037c0:	83 ec 04             	sub    $0x4,%esp
f01037c3:	68 06 61 10 f0       	push   $0xf0106106
f01037c8:	68 b1 00 00 00       	push   $0xb1
f01037cd:	68 f7 60 10 f0       	push   $0xf01060f7
f01037d2:	e8 57 c9 ff ff       	call   f010012e <_panic>

f01037d7 <sys_unmap_frame>:
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int sys_unmap_frame(int32 envid, void *va)
{
f01037d7:	55                   	push   %ebp
f01037d8:	89 e5                	mov    %esp,%ebp
f01037da:	83 ec 08             	sub    $0x8,%esp
	// Hint: This function is a wrapper around page_remove().
	
	// LAB 4: Your code here.
	panic("sys_page_unmap not implemented");
f01037dd:	83 ec 04             	sub    $0x4,%esp
f01037e0:	68 24 61 10 f0       	push   $0xf0106124
f01037e5:	68 c0 00 00 00       	push   $0xc0
f01037ea:	68 f7 60 10 f0       	push   $0xf01060f7
f01037ef:	e8 3a c9 ff ff       	call   f010012e <_panic>

f01037f4 <sys_calculate_required_frames>:
}

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
f01037f4:	55                   	push   %ebp
f01037f5:	89 e5                	mov    %esp,%ebp
f01037f7:	83 ec 08             	sub    $0x8,%esp
	return calculate_required_frames(curenv->env_pgdir, start_virtual_address, size); 
f01037fa:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f01037ff:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103802:	83 ec 04             	sub    $0x4,%esp
f0103805:	ff 75 0c             	pushl  0xc(%ebp)
f0103808:	ff 75 08             	pushl  0x8(%ebp)
f010380b:	50                   	push   %eax
f010380c:	e8 89 ee ff ff       	call   f010269a <calculate_required_frames>
f0103811:	83 c4 10             	add    $0x10,%esp
}
f0103814:	c9                   	leave  
f0103815:	c3                   	ret    

f0103816 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
f0103816:	55                   	push   %ebp
f0103817:	89 e5                	mov    %esp,%ebp
f0103819:	83 ec 08             	sub    $0x8,%esp
	return calculate_free_frames();
f010381c:	e8 96 ee ff ff       	call   f01026b7 <calculate_free_frames>
}
f0103821:	c9                   	leave  
f0103822:	c3                   	ret    

f0103823 <sys_freeMem>:
void sys_freeMem(void* start_virtual_address, uint32 size)
{
f0103823:	55                   	push   %ebp
f0103824:	89 e5                	mov    %esp,%ebp
f0103826:	83 ec 08             	sub    $0x8,%esp
	freeMem((uint32*)curenv->env_pgdir, (void*)start_virtual_address, size);
f0103829:	a1 f0 de 14 f0       	mov    0xf014def0,%eax
f010382e:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103831:	83 ec 04             	sub    $0x4,%esp
f0103834:	ff 75 0c             	pushl  0xc(%ebp)
f0103837:	ff 75 08             	pushl  0x8(%ebp)
f010383a:	50                   	push   %eax
f010383b:	e8 a4 ee ff ff       	call   f01026e4 <freeMem>
f0103840:	83 c4 10             	add    $0x10,%esp
	return;
f0103843:	90                   	nop
}
f0103844:	c9                   	leave  
f0103845:	c3                   	ret    

f0103846 <syscall>:
// Dispatches to the correct kernel function, passing the arguments.
uint32
syscall(uint32 syscallno, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
f0103846:	55                   	push   %ebp
f0103847:	89 e5                	mov    %esp,%ebp
f0103849:	56                   	push   %esi
f010384a:	53                   	push   %ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch(syscallno)
f010384b:	83 7d 08 0c          	cmpl   $0xc,0x8(%ebp)
f010384f:	0f 87 19 01 00 00    	ja     f010396e <syscall+0x128>
f0103855:	8b 45 08             	mov    0x8(%ebp),%eax
f0103858:	c1 e0 02             	shl    $0x2,%eax
f010385b:	05 44 61 10 f0       	add    $0xf0106144,%eax
f0103860:	8b 00                	mov    (%eax),%eax
f0103862:	ff e0                	jmp    *%eax
	{
		case SYS_cputs:
			sys_cputs((const char*)a1,a2);
f0103864:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103867:	83 ec 08             	sub    $0x8,%esp
f010386a:	ff 75 10             	pushl  0x10(%ebp)
f010386d:	50                   	push   %eax
f010386e:	e8 51 fd ff ff       	call   f01035c4 <sys_cputs>
f0103873:	83 c4 10             	add    $0x10,%esp
			return 0;
f0103876:	b8 00 00 00 00       	mov    $0x0,%eax
f010387b:	e9 f3 00 00 00       	jmp    f0103973 <syscall+0x12d>
			break;
		case SYS_cgetc:
			return sys_cgetc();
f0103880:	e8 5e fd ff ff       	call   f01035e3 <sys_cgetc>
f0103885:	e9 e9 00 00 00       	jmp    f0103973 <syscall+0x12d>
			break;
		case SYS_getenvid:
			return sys_getenvid();
f010388a:	e8 6d fd ff ff       	call   f01035fc <sys_getenvid>
f010388f:	e9 df 00 00 00       	jmp    f0103973 <syscall+0x12d>
			break;
		case SYS_env_destroy:
			return sys_env_destroy(a1);
f0103894:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103897:	83 ec 0c             	sub    $0xc,%esp
f010389a:	50                   	push   %eax
f010389b:	e8 69 fd ff ff       	call   f0103609 <sys_env_destroy>
f01038a0:	83 c4 10             	add    $0x10,%esp
f01038a3:	e9 cb 00 00 00       	jmp    f0103973 <syscall+0x12d>
			break;
		case SYS_env_sleep:
			sys_env_sleep();
f01038a8:	e8 e1 fd ff ff       	call   f010368e <sys_env_sleep>
			return 0;
f01038ad:	b8 00 00 00 00       	mov    $0x0,%eax
f01038b2:	e9 bc 00 00 00       	jmp    f0103973 <syscall+0x12d>
			break;
		case SYS_calc_req_frames:
			return sys_calculate_required_frames(a1, a2);			
f01038b7:	83 ec 08             	sub    $0x8,%esp
f01038ba:	ff 75 10             	pushl  0x10(%ebp)
f01038bd:	ff 75 0c             	pushl  0xc(%ebp)
f01038c0:	e8 2f ff ff ff       	call   f01037f4 <sys_calculate_required_frames>
f01038c5:	83 c4 10             	add    $0x10,%esp
f01038c8:	e9 a6 00 00 00       	jmp    f0103973 <syscall+0x12d>
			break;
		case SYS_calc_free_frames:
			return sys_calculate_free_frames();			
f01038cd:	e8 44 ff ff ff       	call   f0103816 <sys_calculate_free_frames>
f01038d2:	e9 9c 00 00 00       	jmp    f0103973 <syscall+0x12d>
			break;
		case SYS_freeMem:
			sys_freeMem((void*)a1, a2);
f01038d7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01038da:	83 ec 08             	sub    $0x8,%esp
f01038dd:	ff 75 10             	pushl  0x10(%ebp)
f01038e0:	50                   	push   %eax
f01038e1:	e8 3d ff ff ff       	call   f0103823 <sys_freeMem>
f01038e6:	83 c4 10             	add    $0x10,%esp
			return 0;			
f01038e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01038ee:	e9 80 00 00 00       	jmp    f0103973 <syscall+0x12d>
			break;
		//======================
		
		case SYS_allocate_page:
			sys_allocate_page((void*)a1, a2);
f01038f3:	8b 55 10             	mov    0x10(%ebp),%edx
f01038f6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01038f9:	83 ec 08             	sub    $0x8,%esp
f01038fc:	52                   	push   %edx
f01038fd:	50                   	push   %eax
f01038fe:	e8 99 fd ff ff       	call   f010369c <sys_allocate_page>
f0103903:	83 c4 10             	add    $0x10,%esp
			return 0;
f0103906:	b8 00 00 00 00       	mov    $0x0,%eax
f010390b:	eb 66                	jmp    f0103973 <syscall+0x12d>
			break;
		case SYS_get_page:
			sys_get_page((void*)a1, a2);
f010390d:	8b 55 10             	mov    0x10(%ebp),%edx
f0103910:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103913:	83 ec 08             	sub    $0x8,%esp
f0103916:	52                   	push   %edx
f0103917:	50                   	push   %eax
f0103918:	e8 7b fe ff ff       	call   f0103798 <sys_get_page>
f010391d:	83 c4 10             	add    $0x10,%esp
			return 0;
f0103920:	b8 00 00 00 00       	mov    $0x0,%eax
f0103925:	eb 4c                	jmp    f0103973 <syscall+0x12d>
		break;case SYS_map_frame:
			sys_map_frame(a1, (void*)a2, a3, (void*)a4, a5);
f0103927:	8b 75 1c             	mov    0x1c(%ebp),%esi
f010392a:	8b 5d 18             	mov    0x18(%ebp),%ebx
f010392d:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0103930:	8b 55 10             	mov    0x10(%ebp),%edx
f0103933:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103936:	83 ec 0c             	sub    $0xc,%esp
f0103939:	56                   	push   %esi
f010393a:	53                   	push   %ebx
f010393b:	51                   	push   %ecx
f010393c:	52                   	push   %edx
f010393d:	50                   	push   %eax
f010393e:	e8 77 fe ff ff       	call   f01037ba <sys_map_frame>
f0103943:	83 c4 20             	add    $0x20,%esp
			return 0;
f0103946:	b8 00 00 00 00       	mov    $0x0,%eax
f010394b:	eb 26                	jmp    f0103973 <syscall+0x12d>
			break;
		case SYS_unmap_frame:
			sys_unmap_frame(a1, (void*)a2);
f010394d:	8b 55 10             	mov    0x10(%ebp),%edx
f0103950:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103953:	83 ec 08             	sub    $0x8,%esp
f0103956:	52                   	push   %edx
f0103957:	50                   	push   %eax
f0103958:	e8 7a fe ff ff       	call   f01037d7 <sys_unmap_frame>
f010395d:	83 c4 10             	add    $0x10,%esp
			return 0;
f0103960:	b8 00 00 00 00       	mov    $0x0,%eax
f0103965:	eb 0c                	jmp    f0103973 <syscall+0x12d>
			break;
		case NSYSCALLS:	
			return 	-E_INVAL;
f0103967:	b8 03 00 00 00       	mov    $0x3,%eax
f010396c:	eb 05                	jmp    f0103973 <syscall+0x12d>
			break;
	}
	//panic("syscall not implemented");
	return -E_INVAL;
f010396e:	b8 03 00 00 00       	mov    $0x3,%eax
}
f0103973:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103976:	5b                   	pop    %ebx
f0103977:	5e                   	pop    %esi
f0103978:	5d                   	pop    %ebp
f0103979:	c3                   	ret    

f010397a <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uint32*  addr)
{
f010397a:	55                   	push   %ebp
f010397b:	89 e5                	mov    %esp,%ebp
f010397d:	83 ec 20             	sub    $0x20,%esp
	int l = *region_left, r = *region_right, any_matches = 0;
f0103980:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103983:	8b 00                	mov    (%eax),%eax
f0103985:	89 45 fc             	mov    %eax,-0x4(%ebp)
f0103988:	8b 45 10             	mov    0x10(%ebp),%eax
f010398b:	8b 00                	mov    (%eax),%eax
f010398d:	89 45 f8             	mov    %eax,-0x8(%ebp)
f0103990:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	
	while (l <= r) {
f0103997:	e9 ca 00 00 00       	jmp    f0103a66 <stab_binsearch+0xec>
		int true_m = (l + r) / 2, m = true_m;
f010399c:	8b 55 fc             	mov    -0x4(%ebp),%edx
f010399f:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01039a2:	01 d0                	add    %edx,%eax
f01039a4:	89 c2                	mov    %eax,%edx
f01039a6:	c1 ea 1f             	shr    $0x1f,%edx
f01039a9:	01 d0                	add    %edx,%eax
f01039ab:	d1 f8                	sar    %eax
f01039ad:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01039b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01039b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01039b6:	eb 03                	jmp    f01039bb <stab_binsearch+0x41>
			m--;
f01039b8:	ff 4d f0             	decl   -0x10(%ebp)
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01039bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01039be:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f01039c1:	7c 1e                	jl     f01039e1 <stab_binsearch+0x67>
f01039c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01039c6:	89 d0                	mov    %edx,%eax
f01039c8:	01 c0                	add    %eax,%eax
f01039ca:	01 d0                	add    %edx,%eax
f01039cc:	c1 e0 02             	shl    $0x2,%eax
f01039cf:	89 c2                	mov    %eax,%edx
f01039d1:	8b 45 08             	mov    0x8(%ebp),%eax
f01039d4:	01 d0                	add    %edx,%eax
f01039d6:	8a 40 04             	mov    0x4(%eax),%al
f01039d9:	0f b6 c0             	movzbl %al,%eax
f01039dc:	3b 45 14             	cmp    0x14(%ebp),%eax
f01039df:	75 d7                	jne    f01039b8 <stab_binsearch+0x3e>
			m--;
		if (m < l) {	// no match in [l, m]
f01039e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01039e4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f01039e7:	7d 09                	jge    f01039f2 <stab_binsearch+0x78>
			l = true_m + 1;
f01039e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01039ec:	40                   	inc    %eax
f01039ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
			continue;
f01039f0:	eb 74                	jmp    f0103a66 <stab_binsearch+0xec>
		}

		// actual binary search
		any_matches = 1;
f01039f2:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
		if (stabs[m].n_value < addr) {
f01039f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01039fc:	89 d0                	mov    %edx,%eax
f01039fe:	01 c0                	add    %eax,%eax
f0103a00:	01 d0                	add    %edx,%eax
f0103a02:	c1 e0 02             	shl    $0x2,%eax
f0103a05:	89 c2                	mov    %eax,%edx
f0103a07:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a0a:	01 d0                	add    %edx,%eax
f0103a0c:	8b 40 08             	mov    0x8(%eax),%eax
f0103a0f:	3b 45 18             	cmp    0x18(%ebp),%eax
f0103a12:	73 11                	jae    f0103a25 <stab_binsearch+0xab>
			*region_left = m;
f0103a14:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a17:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103a1a:	89 10                	mov    %edx,(%eax)
			l = true_m + 1;
f0103a1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103a1f:	40                   	inc    %eax
f0103a20:	89 45 fc             	mov    %eax,-0x4(%ebp)
f0103a23:	eb 41                	jmp    f0103a66 <stab_binsearch+0xec>
		} else if (stabs[m].n_value > addr) {
f0103a25:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103a28:	89 d0                	mov    %edx,%eax
f0103a2a:	01 c0                	add    %eax,%eax
f0103a2c:	01 d0                	add    %edx,%eax
f0103a2e:	c1 e0 02             	shl    $0x2,%eax
f0103a31:	89 c2                	mov    %eax,%edx
f0103a33:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a36:	01 d0                	add    %edx,%eax
f0103a38:	8b 40 08             	mov    0x8(%eax),%eax
f0103a3b:	3b 45 18             	cmp    0x18(%ebp),%eax
f0103a3e:	76 14                	jbe    f0103a54 <stab_binsearch+0xda>
			*region_right = m - 1;
f0103a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103a43:	8d 50 ff             	lea    -0x1(%eax),%edx
f0103a46:	8b 45 10             	mov    0x10(%ebp),%eax
f0103a49:	89 10                	mov    %edx,(%eax)
			r = m - 1;
f0103a4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103a4e:	48                   	dec    %eax
f0103a4f:	89 45 f8             	mov    %eax,-0x8(%ebp)
f0103a52:	eb 12                	jmp    f0103a66 <stab_binsearch+0xec>
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103a54:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a57:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103a5a:	89 10                	mov    %edx,(%eax)
			l = m;
f0103a5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103a5f:	89 45 fc             	mov    %eax,-0x4(%ebp)
			addr++;
f0103a62:	83 45 18 04          	addl   $0x4,0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uint32*  addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0103a66:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0103a69:	3b 45 f8             	cmp    -0x8(%ebp),%eax
f0103a6c:	0f 8e 2a ff ff ff    	jle    f010399c <stab_binsearch+0x22>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103a72:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0103a76:	75 0f                	jne    f0103a87 <stab_binsearch+0x10d>
		*region_right = *region_left - 1;
f0103a78:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a7b:	8b 00                	mov    (%eax),%eax
f0103a7d:	8d 50 ff             	lea    -0x1(%eax),%edx
f0103a80:	8b 45 10             	mov    0x10(%ebp),%eax
f0103a83:	89 10                	mov    %edx,(%eax)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103a85:	eb 3d                	jmp    f0103ac4 <stab_binsearch+0x14a>

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103a87:	8b 45 10             	mov    0x10(%ebp),%eax
f0103a8a:	8b 00                	mov    (%eax),%eax
f0103a8c:	89 45 fc             	mov    %eax,-0x4(%ebp)
f0103a8f:	eb 03                	jmp    f0103a94 <stab_binsearch+0x11a>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103a91:	ff 4d fc             	decl   -0x4(%ebp)
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0103a94:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a97:	8b 00                	mov    (%eax),%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103a99:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f0103a9c:	7d 1e                	jge    f0103abc <stab_binsearch+0x142>
		     l > *region_left && stabs[l].n_type != type;
f0103a9e:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0103aa1:	89 d0                	mov    %edx,%eax
f0103aa3:	01 c0                	add    %eax,%eax
f0103aa5:	01 d0                	add    %edx,%eax
f0103aa7:	c1 e0 02             	shl    $0x2,%eax
f0103aaa:	89 c2                	mov    %eax,%edx
f0103aac:	8b 45 08             	mov    0x8(%ebp),%eax
f0103aaf:	01 d0                	add    %edx,%eax
f0103ab1:	8a 40 04             	mov    0x4(%eax),%al
f0103ab4:	0f b6 c0             	movzbl %al,%eax
f0103ab7:	3b 45 14             	cmp    0x14(%ebp),%eax
f0103aba:	75 d5                	jne    f0103a91 <stab_binsearch+0x117>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103abc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103abf:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0103ac2:	89 10                	mov    %edx,(%eax)
	}
}
f0103ac4:	90                   	nop
f0103ac5:	c9                   	leave  
f0103ac6:	c3                   	ret    

f0103ac7 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uint32*  addr, struct Eipdebuginfo *info)
{
f0103ac7:	55                   	push   %ebp
f0103ac8:	89 e5                	mov    %esp,%ebp
f0103aca:	83 ec 38             	sub    $0x38,%esp
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103acd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ad0:	c7 00 78 61 10 f0    	movl   $0xf0106178,(%eax)
	info->eip_line = 0;
f0103ad6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ad9:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	info->eip_fn_name = "<unknown>";
f0103ae0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ae3:	c7 40 08 78 61 10 f0 	movl   $0xf0106178,0x8(%eax)
	info->eip_fn_namelen = 9;
f0103aea:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103aed:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
	info->eip_fn_addr = addr;
f0103af4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103af7:	8b 55 08             	mov    0x8(%ebp),%edx
f0103afa:	89 50 10             	mov    %edx,0x10(%eax)
	info->eip_fn_narg = 0;
f0103afd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b00:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

	// Find the relevant set of stabs
	if ((uint32)addr >= USER_LIMIT) {
f0103b07:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b0a:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0103b0f:	76 1e                	jbe    f0103b2f <debuginfo_eip+0x68>
		stabs = __STAB_BEGIN__;
f0103b11:	c7 45 f4 d8 63 10 f0 	movl   $0xf01063d8,-0xc(%ebp)
		stab_end = __STAB_END__;
f0103b18:	c7 45 f0 c0 ea 10 f0 	movl   $0xf010eac0,-0x10(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0103b1f:	c7 45 ec c1 ea 10 f0 	movl   $0xf010eac1,-0x14(%ebp)
		stabstr_end = __STABSTR_END__;
f0103b26:	c7 45 e8 e3 22 11 f0 	movl   $0xf01122e3,-0x18(%ebp)
f0103b2d:	eb 2a                	jmp    f0103b59 <debuginfo_eip+0x92>
		// The user-application linker script, user/user.ld,
		// puts information about the application's stabs (equivalent
		// to __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__, and
		// __STABSTR_END__) in a structure located at virtual address
		// USTABDATA.
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;
f0103b2f:	c7 45 e0 00 00 20 00 	movl   $0x200000,-0x20(%ebp)

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		
		stabs = usd->stabs;
f0103b36:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b39:	8b 00                	mov    (%eax),%eax
f0103b3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
		stab_end = usd->stab_end;
f0103b3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b41:	8b 40 04             	mov    0x4(%eax),%eax
f0103b44:	89 45 f0             	mov    %eax,-0x10(%ebp)
		stabstr = usd->stabstr;
f0103b47:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b4a:	8b 40 08             	mov    0x8(%eax),%eax
f0103b4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
		stabstr_end = usd->stabstr_end;
f0103b50:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b53:	8b 40 0c             	mov    0xc(%eax),%eax
f0103b56:	89 45 e8             	mov    %eax,-0x18(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103b59:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103b5c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f0103b5f:	76 0a                	jbe    f0103b6b <debuginfo_eip+0xa4>
f0103b61:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103b64:	48                   	dec    %eax
f0103b65:	8a 00                	mov    (%eax),%al
f0103b67:	84 c0                	test   %al,%al
f0103b69:	74 0a                	je     f0103b75 <debuginfo_eip+0xae>
		return -1;
f0103b6b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103b70:	e9 01 02 00 00       	jmp    f0103d76 <debuginfo_eip+0x2af>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103b75:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103b7c:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b82:	29 c2                	sub    %eax,%edx
f0103b84:	89 d0                	mov    %edx,%eax
f0103b86:	c1 f8 02             	sar    $0x2,%eax
f0103b89:	89 c2                	mov    %eax,%edx
f0103b8b:	89 d0                	mov    %edx,%eax
f0103b8d:	c1 e0 02             	shl    $0x2,%eax
f0103b90:	01 d0                	add    %edx,%eax
f0103b92:	c1 e0 02             	shl    $0x2,%eax
f0103b95:	01 d0                	add    %edx,%eax
f0103b97:	c1 e0 02             	shl    $0x2,%eax
f0103b9a:	01 d0                	add    %edx,%eax
f0103b9c:	89 c1                	mov    %eax,%ecx
f0103b9e:	c1 e1 08             	shl    $0x8,%ecx
f0103ba1:	01 c8                	add    %ecx,%eax
f0103ba3:	89 c1                	mov    %eax,%ecx
f0103ba5:	c1 e1 10             	shl    $0x10,%ecx
f0103ba8:	01 c8                	add    %ecx,%eax
f0103baa:	01 c0                	add    %eax,%eax
f0103bac:	01 d0                	add    %edx,%eax
f0103bae:	48                   	dec    %eax
f0103baf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103bb2:	ff 75 08             	pushl  0x8(%ebp)
f0103bb5:	6a 64                	push   $0x64
f0103bb7:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f0103bba:	50                   	push   %eax
f0103bbb:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0103bbe:	50                   	push   %eax
f0103bbf:	ff 75 f4             	pushl  -0xc(%ebp)
f0103bc2:	e8 b3 fd ff ff       	call   f010397a <stab_binsearch>
f0103bc7:	83 c4 14             	add    $0x14,%esp
	if (lfile == 0)
f0103bca:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103bcd:	85 c0                	test   %eax,%eax
f0103bcf:	75 0a                	jne    f0103bdb <debuginfo_eip+0x114>
		return -1;
f0103bd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103bd6:	e9 9b 01 00 00       	jmp    f0103d76 <debuginfo_eip+0x2af>

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103bdb:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103bde:	89 45 d0             	mov    %eax,-0x30(%ebp)
	rfun = rfile;
f0103be1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103be4:	89 45 cc             	mov    %eax,-0x34(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103be7:	ff 75 08             	pushl  0x8(%ebp)
f0103bea:	6a 24                	push   $0x24
f0103bec:	8d 45 cc             	lea    -0x34(%ebp),%eax
f0103bef:	50                   	push   %eax
f0103bf0:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0103bf3:	50                   	push   %eax
f0103bf4:	ff 75 f4             	pushl  -0xc(%ebp)
f0103bf7:	e8 7e fd ff ff       	call   f010397a <stab_binsearch>
f0103bfc:	83 c4 14             	add    $0x14,%esp

	if (lfun <= rfun) {
f0103bff:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103c02:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103c05:	39 c2                	cmp    %eax,%edx
f0103c07:	0f 8f 86 00 00 00    	jg     f0103c93 <debuginfo_eip+0x1cc>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103c0d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103c10:	89 c2                	mov    %eax,%edx
f0103c12:	89 d0                	mov    %edx,%eax
f0103c14:	01 c0                	add    %eax,%eax
f0103c16:	01 d0                	add    %edx,%eax
f0103c18:	c1 e0 02             	shl    $0x2,%eax
f0103c1b:	89 c2                	mov    %eax,%edx
f0103c1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103c20:	01 d0                	add    %edx,%eax
f0103c22:	8b 00                	mov    (%eax),%eax
f0103c24:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103c27:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0103c2a:	29 d1                	sub    %edx,%ecx
f0103c2c:	89 ca                	mov    %ecx,%edx
f0103c2e:	39 d0                	cmp    %edx,%eax
f0103c30:	73 22                	jae    f0103c54 <debuginfo_eip+0x18d>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103c32:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103c35:	89 c2                	mov    %eax,%edx
f0103c37:	89 d0                	mov    %edx,%eax
f0103c39:	01 c0                	add    %eax,%eax
f0103c3b:	01 d0                	add    %edx,%eax
f0103c3d:	c1 e0 02             	shl    $0x2,%eax
f0103c40:	89 c2                	mov    %eax,%edx
f0103c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103c45:	01 d0                	add    %edx,%eax
f0103c47:	8b 10                	mov    (%eax),%edx
f0103c49:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103c4c:	01 c2                	add    %eax,%edx
f0103c4e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c51:	89 50 08             	mov    %edx,0x8(%eax)
		info->eip_fn_addr = (uint32*) stabs[lfun].n_value;
f0103c54:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103c57:	89 c2                	mov    %eax,%edx
f0103c59:	89 d0                	mov    %edx,%eax
f0103c5b:	01 c0                	add    %eax,%eax
f0103c5d:	01 d0                	add    %edx,%eax
f0103c5f:	c1 e0 02             	shl    $0x2,%eax
f0103c62:	89 c2                	mov    %eax,%edx
f0103c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103c67:	01 d0                	add    %edx,%eax
f0103c69:	8b 50 08             	mov    0x8(%eax),%edx
f0103c6c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c6f:	89 50 10             	mov    %edx,0x10(%eax)
		addr = (uint32*)(addr - (info->eip_fn_addr));
f0103c72:	8b 55 08             	mov    0x8(%ebp),%edx
f0103c75:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c78:	8b 40 10             	mov    0x10(%eax),%eax
f0103c7b:	29 c2                	sub    %eax,%edx
f0103c7d:	89 d0                	mov    %edx,%eax
f0103c7f:	c1 f8 02             	sar    $0x2,%eax
f0103c82:	89 45 08             	mov    %eax,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0103c85:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103c88:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		rline = rfun;
f0103c8b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103c8e:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103c91:	eb 15                	jmp    f0103ca8 <debuginfo_eip+0x1e1>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103c93:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c96:	8b 55 08             	mov    0x8(%ebp),%edx
f0103c99:	89 50 10             	mov    %edx,0x10(%eax)
		lline = lfile;
f0103c9c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103c9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		rline = rfile;
f0103ca2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103ca5:	89 45 dc             	mov    %eax,-0x24(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103ca8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103cab:	8b 40 08             	mov    0x8(%eax),%eax
f0103cae:	83 ec 08             	sub    $0x8,%esp
f0103cb1:	6a 3a                	push   $0x3a
f0103cb3:	50                   	push   %eax
f0103cb4:	e8 d5 09 00 00       	call   f010468e <strfind>
f0103cb9:	83 c4 10             	add    $0x10,%esp
f0103cbc:	89 c2                	mov    %eax,%edx
f0103cbe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103cc1:	8b 40 08             	mov    0x8(%eax),%eax
f0103cc4:	29 c2                	sub    %eax,%edx
f0103cc6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103cc9:	89 50 0c             	mov    %edx,0xc(%eax)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103ccc:	eb 03                	jmp    f0103cd1 <debuginfo_eip+0x20a>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103cce:	ff 4d e4             	decl   -0x1c(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103cd1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103cd4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0103cd7:	7c 4e                	jl     f0103d27 <debuginfo_eip+0x260>
	       && stabs[lline].n_type != N_SOL
f0103cd9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103cdc:	89 d0                	mov    %edx,%eax
f0103cde:	01 c0                	add    %eax,%eax
f0103ce0:	01 d0                	add    %edx,%eax
f0103ce2:	c1 e0 02             	shl    $0x2,%eax
f0103ce5:	89 c2                	mov    %eax,%edx
f0103ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103cea:	01 d0                	add    %edx,%eax
f0103cec:	8a 40 04             	mov    0x4(%eax),%al
f0103cef:	3c 84                	cmp    $0x84,%al
f0103cf1:	74 34                	je     f0103d27 <debuginfo_eip+0x260>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103cf3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103cf6:	89 d0                	mov    %edx,%eax
f0103cf8:	01 c0                	add    %eax,%eax
f0103cfa:	01 d0                	add    %edx,%eax
f0103cfc:	c1 e0 02             	shl    $0x2,%eax
f0103cff:	89 c2                	mov    %eax,%edx
f0103d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103d04:	01 d0                	add    %edx,%eax
f0103d06:	8a 40 04             	mov    0x4(%eax),%al
f0103d09:	3c 64                	cmp    $0x64,%al
f0103d0b:	75 c1                	jne    f0103cce <debuginfo_eip+0x207>
f0103d0d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103d10:	89 d0                	mov    %edx,%eax
f0103d12:	01 c0                	add    %eax,%eax
f0103d14:	01 d0                	add    %edx,%eax
f0103d16:	c1 e0 02             	shl    $0x2,%eax
f0103d19:	89 c2                	mov    %eax,%edx
f0103d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103d1e:	01 d0                	add    %edx,%eax
f0103d20:	8b 40 08             	mov    0x8(%eax),%eax
f0103d23:	85 c0                	test   %eax,%eax
f0103d25:	74 a7                	je     f0103cce <debuginfo_eip+0x207>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103d27:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103d2a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0103d2d:	7c 42                	jl     f0103d71 <debuginfo_eip+0x2aa>
f0103d2f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103d32:	89 d0                	mov    %edx,%eax
f0103d34:	01 c0                	add    %eax,%eax
f0103d36:	01 d0                	add    %edx,%eax
f0103d38:	c1 e0 02             	shl    $0x2,%eax
f0103d3b:	89 c2                	mov    %eax,%edx
f0103d3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103d40:	01 d0                	add    %edx,%eax
f0103d42:	8b 00                	mov    (%eax),%eax
f0103d44:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103d47:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0103d4a:	29 d1                	sub    %edx,%ecx
f0103d4c:	89 ca                	mov    %ecx,%edx
f0103d4e:	39 d0                	cmp    %edx,%eax
f0103d50:	73 1f                	jae    f0103d71 <debuginfo_eip+0x2aa>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103d52:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103d55:	89 d0                	mov    %edx,%eax
f0103d57:	01 c0                	add    %eax,%eax
f0103d59:	01 d0                	add    %edx,%eax
f0103d5b:	c1 e0 02             	shl    $0x2,%eax
f0103d5e:	89 c2                	mov    %eax,%edx
f0103d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103d63:	01 d0                	add    %edx,%eax
f0103d65:	8b 10                	mov    (%eax),%edx
f0103d67:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103d6a:	01 c2                	add    %eax,%edx
f0103d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103d6f:	89 10                	mov    %edx,(%eax)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.

	
	return 0;
f0103d71:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103d76:	c9                   	leave  
f0103d77:	c3                   	ret    

f0103d78 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103d78:	55                   	push   %ebp
f0103d79:	89 e5                	mov    %esp,%ebp
f0103d7b:	53                   	push   %ebx
f0103d7c:	83 ec 14             	sub    $0x14,%esp
f0103d7f:	8b 45 10             	mov    0x10(%ebp),%eax
f0103d82:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103d85:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d88:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103d8b:	8b 45 18             	mov    0x18(%ebp),%eax
f0103d8e:	ba 00 00 00 00       	mov    $0x0,%edx
f0103d93:	3b 55 f4             	cmp    -0xc(%ebp),%edx
f0103d96:	77 55                	ja     f0103ded <printnum+0x75>
f0103d98:	3b 55 f4             	cmp    -0xc(%ebp),%edx
f0103d9b:	72 05                	jb     f0103da2 <printnum+0x2a>
f0103d9d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f0103da0:	77 4b                	ja     f0103ded <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103da2:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0103da5:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0103da8:	8b 45 18             	mov    0x18(%ebp),%eax
f0103dab:	ba 00 00 00 00       	mov    $0x0,%edx
f0103db0:	52                   	push   %edx
f0103db1:	50                   	push   %eax
f0103db2:	ff 75 f4             	pushl  -0xc(%ebp)
f0103db5:	ff 75 f0             	pushl  -0x10(%ebp)
f0103db8:	e8 8b 0c 00 00       	call   f0104a48 <__udivdi3>
f0103dbd:	83 c4 10             	add    $0x10,%esp
f0103dc0:	83 ec 04             	sub    $0x4,%esp
f0103dc3:	ff 75 20             	pushl  0x20(%ebp)
f0103dc6:	53                   	push   %ebx
f0103dc7:	ff 75 18             	pushl  0x18(%ebp)
f0103dca:	52                   	push   %edx
f0103dcb:	50                   	push   %eax
f0103dcc:	ff 75 0c             	pushl  0xc(%ebp)
f0103dcf:	ff 75 08             	pushl  0x8(%ebp)
f0103dd2:	e8 a1 ff ff ff       	call   f0103d78 <printnum>
f0103dd7:	83 c4 20             	add    $0x20,%esp
f0103dda:	eb 1a                	jmp    f0103df6 <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103ddc:	83 ec 08             	sub    $0x8,%esp
f0103ddf:	ff 75 0c             	pushl  0xc(%ebp)
f0103de2:	ff 75 20             	pushl  0x20(%ebp)
f0103de5:	8b 45 08             	mov    0x8(%ebp),%eax
f0103de8:	ff d0                	call   *%eax
f0103dea:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103ded:	ff 4d 1c             	decl   0x1c(%ebp)
f0103df0:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
f0103df4:	7f e6                	jg     f0103ddc <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103df6:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0103df9:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103dfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103e01:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103e04:	53                   	push   %ebx
f0103e05:	51                   	push   %ecx
f0103e06:	52                   	push   %edx
f0103e07:	50                   	push   %eax
f0103e08:	e8 4b 0d 00 00       	call   f0104b58 <__umoddi3>
f0103e0d:	83 c4 10             	add    $0x10,%esp
f0103e10:	05 40 62 10 f0       	add    $0xf0106240,%eax
f0103e15:	8a 00                	mov    (%eax),%al
f0103e17:	0f be c0             	movsbl %al,%eax
f0103e1a:	83 ec 08             	sub    $0x8,%esp
f0103e1d:	ff 75 0c             	pushl  0xc(%ebp)
f0103e20:	50                   	push   %eax
f0103e21:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e24:	ff d0                	call   *%eax
f0103e26:	83 c4 10             	add    $0x10,%esp
}
f0103e29:	90                   	nop
f0103e2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103e2d:	c9                   	leave  
f0103e2e:	c3                   	ret    

f0103e2f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103e2f:	55                   	push   %ebp
f0103e30:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103e32:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f0103e36:	7e 1c                	jle    f0103e54 <getuint+0x25>
		return va_arg(*ap, unsigned long long);
f0103e38:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e3b:	8b 00                	mov    (%eax),%eax
f0103e3d:	8d 50 08             	lea    0x8(%eax),%edx
f0103e40:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e43:	89 10                	mov    %edx,(%eax)
f0103e45:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e48:	8b 00                	mov    (%eax),%eax
f0103e4a:	83 e8 08             	sub    $0x8,%eax
f0103e4d:	8b 50 04             	mov    0x4(%eax),%edx
f0103e50:	8b 00                	mov    (%eax),%eax
f0103e52:	eb 40                	jmp    f0103e94 <getuint+0x65>
	else if (lflag)
f0103e54:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103e58:	74 1e                	je     f0103e78 <getuint+0x49>
		return va_arg(*ap, unsigned long);
f0103e5a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e5d:	8b 00                	mov    (%eax),%eax
f0103e5f:	8d 50 04             	lea    0x4(%eax),%edx
f0103e62:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e65:	89 10                	mov    %edx,(%eax)
f0103e67:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e6a:	8b 00                	mov    (%eax),%eax
f0103e6c:	83 e8 04             	sub    $0x4,%eax
f0103e6f:	8b 00                	mov    (%eax),%eax
f0103e71:	ba 00 00 00 00       	mov    $0x0,%edx
f0103e76:	eb 1c                	jmp    f0103e94 <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
f0103e78:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e7b:	8b 00                	mov    (%eax),%eax
f0103e7d:	8d 50 04             	lea    0x4(%eax),%edx
f0103e80:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e83:	89 10                	mov    %edx,(%eax)
f0103e85:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e88:	8b 00                	mov    (%eax),%eax
f0103e8a:	83 e8 04             	sub    $0x4,%eax
f0103e8d:	8b 00                	mov    (%eax),%eax
f0103e8f:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103e94:	5d                   	pop    %ebp
f0103e95:	c3                   	ret    

f0103e96 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0103e96:	55                   	push   %ebp
f0103e97:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103e99:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f0103e9d:	7e 1c                	jle    f0103ebb <getint+0x25>
		return va_arg(*ap, long long);
f0103e9f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ea2:	8b 00                	mov    (%eax),%eax
f0103ea4:	8d 50 08             	lea    0x8(%eax),%edx
f0103ea7:	8b 45 08             	mov    0x8(%ebp),%eax
f0103eaa:	89 10                	mov    %edx,(%eax)
f0103eac:	8b 45 08             	mov    0x8(%ebp),%eax
f0103eaf:	8b 00                	mov    (%eax),%eax
f0103eb1:	83 e8 08             	sub    $0x8,%eax
f0103eb4:	8b 50 04             	mov    0x4(%eax),%edx
f0103eb7:	8b 00                	mov    (%eax),%eax
f0103eb9:	eb 38                	jmp    f0103ef3 <getint+0x5d>
	else if (lflag)
f0103ebb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103ebf:	74 1a                	je     f0103edb <getint+0x45>
		return va_arg(*ap, long);
f0103ec1:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ec4:	8b 00                	mov    (%eax),%eax
f0103ec6:	8d 50 04             	lea    0x4(%eax),%edx
f0103ec9:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ecc:	89 10                	mov    %edx,(%eax)
f0103ece:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ed1:	8b 00                	mov    (%eax),%eax
f0103ed3:	83 e8 04             	sub    $0x4,%eax
f0103ed6:	8b 00                	mov    (%eax),%eax
f0103ed8:	99                   	cltd   
f0103ed9:	eb 18                	jmp    f0103ef3 <getint+0x5d>
	else
		return va_arg(*ap, int);
f0103edb:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ede:	8b 00                	mov    (%eax),%eax
f0103ee0:	8d 50 04             	lea    0x4(%eax),%edx
f0103ee3:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ee6:	89 10                	mov    %edx,(%eax)
f0103ee8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103eeb:	8b 00                	mov    (%eax),%eax
f0103eed:	83 e8 04             	sub    $0x4,%eax
f0103ef0:	8b 00                	mov    (%eax),%eax
f0103ef2:	99                   	cltd   
}
f0103ef3:	5d                   	pop    %ebp
f0103ef4:	c3                   	ret    

f0103ef5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103ef5:	55                   	push   %ebp
f0103ef6:	89 e5                	mov    %esp,%ebp
f0103ef8:	56                   	push   %esi
f0103ef9:	53                   	push   %ebx
f0103efa:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103efd:	eb 17                	jmp    f0103f16 <vprintfmt+0x21>
			if (ch == '\0')
f0103eff:	85 db                	test   %ebx,%ebx
f0103f01:	0f 84 af 03 00 00    	je     f01042b6 <vprintfmt+0x3c1>
				return;
			putch(ch, putdat);
f0103f07:	83 ec 08             	sub    $0x8,%esp
f0103f0a:	ff 75 0c             	pushl  0xc(%ebp)
f0103f0d:	53                   	push   %ebx
f0103f0e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f11:	ff d0                	call   *%eax
f0103f13:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103f16:	8b 45 10             	mov    0x10(%ebp),%eax
f0103f19:	8d 50 01             	lea    0x1(%eax),%edx
f0103f1c:	89 55 10             	mov    %edx,0x10(%ebp)
f0103f1f:	8a 00                	mov    (%eax),%al
f0103f21:	0f b6 d8             	movzbl %al,%ebx
f0103f24:	83 fb 25             	cmp    $0x25,%ebx
f0103f27:	75 d6                	jne    f0103eff <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
f0103f29:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
f0103f2d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
f0103f34:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0103f3b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
f0103f42:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f49:	8b 45 10             	mov    0x10(%ebp),%eax
f0103f4c:	8d 50 01             	lea    0x1(%eax),%edx
f0103f4f:	89 55 10             	mov    %edx,0x10(%ebp)
f0103f52:	8a 00                	mov    (%eax),%al
f0103f54:	0f b6 d8             	movzbl %al,%ebx
f0103f57:	8d 43 dd             	lea    -0x23(%ebx),%eax
f0103f5a:	83 f8 55             	cmp    $0x55,%eax
f0103f5d:	0f 87 2b 03 00 00    	ja     f010428e <vprintfmt+0x399>
f0103f63:	8b 04 85 64 62 10 f0 	mov    -0xfef9d9c(,%eax,4),%eax
f0103f6a:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
f0103f6c:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
f0103f70:	eb d7                	jmp    f0103f49 <vprintfmt+0x54>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103f72:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
f0103f76:	eb d1                	jmp    f0103f49 <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103f78:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
f0103f7f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103f82:	89 d0                	mov    %edx,%eax
f0103f84:	c1 e0 02             	shl    $0x2,%eax
f0103f87:	01 d0                	add    %edx,%eax
f0103f89:	01 c0                	add    %eax,%eax
f0103f8b:	01 d8                	add    %ebx,%eax
f0103f8d:	83 e8 30             	sub    $0x30,%eax
f0103f90:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
f0103f93:	8b 45 10             	mov    0x10(%ebp),%eax
f0103f96:	8a 00                	mov    (%eax),%al
f0103f98:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
f0103f9b:	83 fb 2f             	cmp    $0x2f,%ebx
f0103f9e:	7e 3e                	jle    f0103fde <vprintfmt+0xe9>
f0103fa0:	83 fb 39             	cmp    $0x39,%ebx
f0103fa3:	7f 39                	jg     f0103fde <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103fa5:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103fa8:	eb d5                	jmp    f0103f7f <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103faa:	8b 45 14             	mov    0x14(%ebp),%eax
f0103fad:	83 c0 04             	add    $0x4,%eax
f0103fb0:	89 45 14             	mov    %eax,0x14(%ebp)
f0103fb3:	8b 45 14             	mov    0x14(%ebp),%eax
f0103fb6:	83 e8 04             	sub    $0x4,%eax
f0103fb9:	8b 00                	mov    (%eax),%eax
f0103fbb:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
f0103fbe:	eb 1f                	jmp    f0103fdf <vprintfmt+0xea>

		case '.':
			if (width < 0)
f0103fc0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103fc4:	79 83                	jns    f0103f49 <vprintfmt+0x54>
				width = 0;
f0103fc6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
f0103fcd:	e9 77 ff ff ff       	jmp    f0103f49 <vprintfmt+0x54>

		case '#':
			altflag = 1;
f0103fd2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0103fd9:	e9 6b ff ff ff       	jmp    f0103f49 <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
f0103fde:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0103fdf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103fe3:	0f 89 60 ff ff ff    	jns    f0103f49 <vprintfmt+0x54>
				width = precision, precision = -1;
f0103fe9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103fec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103fef:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
f0103ff6:	e9 4e ff ff ff       	jmp    f0103f49 <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103ffb:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
f0103ffe:	e9 46 ff ff ff       	jmp    f0103f49 <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104003:	8b 45 14             	mov    0x14(%ebp),%eax
f0104006:	83 c0 04             	add    $0x4,%eax
f0104009:	89 45 14             	mov    %eax,0x14(%ebp)
f010400c:	8b 45 14             	mov    0x14(%ebp),%eax
f010400f:	83 e8 04             	sub    $0x4,%eax
f0104012:	8b 00                	mov    (%eax),%eax
f0104014:	83 ec 08             	sub    $0x8,%esp
f0104017:	ff 75 0c             	pushl  0xc(%ebp)
f010401a:	50                   	push   %eax
f010401b:	8b 45 08             	mov    0x8(%ebp),%eax
f010401e:	ff d0                	call   *%eax
f0104020:	83 c4 10             	add    $0x10,%esp
			break;
f0104023:	e9 89 02 00 00       	jmp    f01042b1 <vprintfmt+0x3bc>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104028:	8b 45 14             	mov    0x14(%ebp),%eax
f010402b:	83 c0 04             	add    $0x4,%eax
f010402e:	89 45 14             	mov    %eax,0x14(%ebp)
f0104031:	8b 45 14             	mov    0x14(%ebp),%eax
f0104034:	83 e8 04             	sub    $0x4,%eax
f0104037:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
f0104039:	85 db                	test   %ebx,%ebx
f010403b:	79 02                	jns    f010403f <vprintfmt+0x14a>
				err = -err;
f010403d:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f010403f:	83 fb 07             	cmp    $0x7,%ebx
f0104042:	7f 0b                	jg     f010404f <vprintfmt+0x15a>
f0104044:	8b 34 9d 20 62 10 f0 	mov    -0xfef9de0(,%ebx,4),%esi
f010404b:	85 f6                	test   %esi,%esi
f010404d:	75 19                	jne    f0104068 <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
f010404f:	53                   	push   %ebx
f0104050:	68 51 62 10 f0       	push   $0xf0106251
f0104055:	ff 75 0c             	pushl  0xc(%ebp)
f0104058:	ff 75 08             	pushl  0x8(%ebp)
f010405b:	e8 5e 02 00 00       	call   f01042be <printfmt>
f0104060:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
f0104063:	e9 49 02 00 00       	jmp    f01042b1 <vprintfmt+0x3bc>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0104068:	56                   	push   %esi
f0104069:	68 5a 62 10 f0       	push   $0xf010625a
f010406e:	ff 75 0c             	pushl  0xc(%ebp)
f0104071:	ff 75 08             	pushl  0x8(%ebp)
f0104074:	e8 45 02 00 00       	call   f01042be <printfmt>
f0104079:	83 c4 10             	add    $0x10,%esp
			break;
f010407c:	e9 30 02 00 00       	jmp    f01042b1 <vprintfmt+0x3bc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104081:	8b 45 14             	mov    0x14(%ebp),%eax
f0104084:	83 c0 04             	add    $0x4,%eax
f0104087:	89 45 14             	mov    %eax,0x14(%ebp)
f010408a:	8b 45 14             	mov    0x14(%ebp),%eax
f010408d:	83 e8 04             	sub    $0x4,%eax
f0104090:	8b 30                	mov    (%eax),%esi
f0104092:	85 f6                	test   %esi,%esi
f0104094:	75 05                	jne    f010409b <vprintfmt+0x1a6>
				p = "(null)";
f0104096:	be 5d 62 10 f0       	mov    $0xf010625d,%esi
			if (width > 0 && padc != '-')
f010409b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010409f:	7e 6d                	jle    f010410e <vprintfmt+0x219>
f01040a1:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
f01040a5:	74 67                	je     f010410e <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
f01040a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01040aa:	83 ec 08             	sub    $0x8,%esp
f01040ad:	50                   	push   %eax
f01040ae:	56                   	push   %esi
f01040af:	e8 3b 04 00 00       	call   f01044ef <strnlen>
f01040b4:	83 c4 10             	add    $0x10,%esp
f01040b7:	29 45 e4             	sub    %eax,-0x1c(%ebp)
f01040ba:	eb 16                	jmp    f01040d2 <vprintfmt+0x1dd>
					putch(padc, putdat);
f01040bc:	0f be 45 db          	movsbl -0x25(%ebp),%eax
f01040c0:	83 ec 08             	sub    $0x8,%esp
f01040c3:	ff 75 0c             	pushl  0xc(%ebp)
f01040c6:	50                   	push   %eax
f01040c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01040ca:	ff d0                	call   *%eax
f01040cc:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01040cf:	ff 4d e4             	decl   -0x1c(%ebp)
f01040d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01040d6:	7f e4                	jg     f01040bc <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01040d8:	eb 34                	jmp    f010410e <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
f01040da:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01040de:	74 1c                	je     f01040fc <vprintfmt+0x207>
f01040e0:	83 fb 1f             	cmp    $0x1f,%ebx
f01040e3:	7e 05                	jle    f01040ea <vprintfmt+0x1f5>
f01040e5:	83 fb 7e             	cmp    $0x7e,%ebx
f01040e8:	7e 12                	jle    f01040fc <vprintfmt+0x207>
					putch('?', putdat);
f01040ea:	83 ec 08             	sub    $0x8,%esp
f01040ed:	ff 75 0c             	pushl  0xc(%ebp)
f01040f0:	6a 3f                	push   $0x3f
f01040f2:	8b 45 08             	mov    0x8(%ebp),%eax
f01040f5:	ff d0                	call   *%eax
f01040f7:	83 c4 10             	add    $0x10,%esp
f01040fa:	eb 0f                	jmp    f010410b <vprintfmt+0x216>
				else
					putch(ch, putdat);
f01040fc:	83 ec 08             	sub    $0x8,%esp
f01040ff:	ff 75 0c             	pushl  0xc(%ebp)
f0104102:	53                   	push   %ebx
f0104103:	8b 45 08             	mov    0x8(%ebp),%eax
f0104106:	ff d0                	call   *%eax
f0104108:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010410b:	ff 4d e4             	decl   -0x1c(%ebp)
f010410e:	89 f0                	mov    %esi,%eax
f0104110:	8d 70 01             	lea    0x1(%eax),%esi
f0104113:	8a 00                	mov    (%eax),%al
f0104115:	0f be d8             	movsbl %al,%ebx
f0104118:	85 db                	test   %ebx,%ebx
f010411a:	74 24                	je     f0104140 <vprintfmt+0x24b>
f010411c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104120:	78 b8                	js     f01040da <vprintfmt+0x1e5>
f0104122:	ff 4d e0             	decl   -0x20(%ebp)
f0104125:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104129:	79 af                	jns    f01040da <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010412b:	eb 13                	jmp    f0104140 <vprintfmt+0x24b>
				putch(' ', putdat);
f010412d:	83 ec 08             	sub    $0x8,%esp
f0104130:	ff 75 0c             	pushl  0xc(%ebp)
f0104133:	6a 20                	push   $0x20
f0104135:	8b 45 08             	mov    0x8(%ebp),%eax
f0104138:	ff d0                	call   *%eax
f010413a:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010413d:	ff 4d e4             	decl   -0x1c(%ebp)
f0104140:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104144:	7f e7                	jg     f010412d <vprintfmt+0x238>
				putch(' ', putdat);
			break;
f0104146:	e9 66 01 00 00       	jmp    f01042b1 <vprintfmt+0x3bc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010414b:	83 ec 08             	sub    $0x8,%esp
f010414e:	ff 75 e8             	pushl  -0x18(%ebp)
f0104151:	8d 45 14             	lea    0x14(%ebp),%eax
f0104154:	50                   	push   %eax
f0104155:	e8 3c fd ff ff       	call   f0103e96 <getint>
f010415a:	83 c4 10             	add    $0x10,%esp
f010415d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104160:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
f0104163:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104166:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104169:	85 d2                	test   %edx,%edx
f010416b:	79 23                	jns    f0104190 <vprintfmt+0x29b>
				putch('-', putdat);
f010416d:	83 ec 08             	sub    $0x8,%esp
f0104170:	ff 75 0c             	pushl  0xc(%ebp)
f0104173:	6a 2d                	push   $0x2d
f0104175:	8b 45 08             	mov    0x8(%ebp),%eax
f0104178:	ff d0                	call   *%eax
f010417a:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
f010417d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104180:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104183:	f7 d8                	neg    %eax
f0104185:	83 d2 00             	adc    $0x0,%edx
f0104188:	f7 da                	neg    %edx
f010418a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010418d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
f0104190:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
f0104197:	e9 bc 00 00 00       	jmp    f0104258 <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010419c:	83 ec 08             	sub    $0x8,%esp
f010419f:	ff 75 e8             	pushl  -0x18(%ebp)
f01041a2:	8d 45 14             	lea    0x14(%ebp),%eax
f01041a5:	50                   	push   %eax
f01041a6:	e8 84 fc ff ff       	call   f0103e2f <getuint>
f01041ab:	83 c4 10             	add    $0x10,%esp
f01041ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01041b1:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
f01041b4:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
f01041bb:	e9 98 00 00 00       	jmp    f0104258 <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f01041c0:	83 ec 08             	sub    $0x8,%esp
f01041c3:	ff 75 0c             	pushl  0xc(%ebp)
f01041c6:	6a 58                	push   $0x58
f01041c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01041cb:	ff d0                	call   *%eax
f01041cd:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
f01041d0:	83 ec 08             	sub    $0x8,%esp
f01041d3:	ff 75 0c             	pushl  0xc(%ebp)
f01041d6:	6a 58                	push   $0x58
f01041d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01041db:	ff d0                	call   *%eax
f01041dd:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
f01041e0:	83 ec 08             	sub    $0x8,%esp
f01041e3:	ff 75 0c             	pushl  0xc(%ebp)
f01041e6:	6a 58                	push   $0x58
f01041e8:	8b 45 08             	mov    0x8(%ebp),%eax
f01041eb:	ff d0                	call   *%eax
f01041ed:	83 c4 10             	add    $0x10,%esp
			break;
f01041f0:	e9 bc 00 00 00       	jmp    f01042b1 <vprintfmt+0x3bc>

		// pointer
		case 'p':
			putch('0', putdat);
f01041f5:	83 ec 08             	sub    $0x8,%esp
f01041f8:	ff 75 0c             	pushl  0xc(%ebp)
f01041fb:	6a 30                	push   $0x30
f01041fd:	8b 45 08             	mov    0x8(%ebp),%eax
f0104200:	ff d0                	call   *%eax
f0104202:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
f0104205:	83 ec 08             	sub    $0x8,%esp
f0104208:	ff 75 0c             	pushl  0xc(%ebp)
f010420b:	6a 78                	push   $0x78
f010420d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104210:	ff d0                	call   *%eax
f0104212:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
f0104215:	8b 45 14             	mov    0x14(%ebp),%eax
f0104218:	83 c0 04             	add    $0x4,%eax
f010421b:	89 45 14             	mov    %eax,0x14(%ebp)
f010421e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104221:	83 e8 04             	sub    $0x4,%eax
f0104224:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104226:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104229:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
f0104230:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
f0104237:	eb 1f                	jmp    f0104258 <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104239:	83 ec 08             	sub    $0x8,%esp
f010423c:	ff 75 e8             	pushl  -0x18(%ebp)
f010423f:	8d 45 14             	lea    0x14(%ebp),%eax
f0104242:	50                   	push   %eax
f0104243:	e8 e7 fb ff ff       	call   f0103e2f <getuint>
f0104248:	83 c4 10             	add    $0x10,%esp
f010424b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010424e:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
f0104251:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104258:	0f be 55 db          	movsbl -0x25(%ebp),%edx
f010425c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010425f:	83 ec 04             	sub    $0x4,%esp
f0104262:	52                   	push   %edx
f0104263:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104266:	50                   	push   %eax
f0104267:	ff 75 f4             	pushl  -0xc(%ebp)
f010426a:	ff 75 f0             	pushl  -0x10(%ebp)
f010426d:	ff 75 0c             	pushl  0xc(%ebp)
f0104270:	ff 75 08             	pushl  0x8(%ebp)
f0104273:	e8 00 fb ff ff       	call   f0103d78 <printnum>
f0104278:	83 c4 20             	add    $0x20,%esp
			break;
f010427b:	eb 34                	jmp    f01042b1 <vprintfmt+0x3bc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010427d:	83 ec 08             	sub    $0x8,%esp
f0104280:	ff 75 0c             	pushl  0xc(%ebp)
f0104283:	53                   	push   %ebx
f0104284:	8b 45 08             	mov    0x8(%ebp),%eax
f0104287:	ff d0                	call   *%eax
f0104289:	83 c4 10             	add    $0x10,%esp
			break;
f010428c:	eb 23                	jmp    f01042b1 <vprintfmt+0x3bc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010428e:	83 ec 08             	sub    $0x8,%esp
f0104291:	ff 75 0c             	pushl  0xc(%ebp)
f0104294:	6a 25                	push   $0x25
f0104296:	8b 45 08             	mov    0x8(%ebp),%eax
f0104299:	ff d0                	call   *%eax
f010429b:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
f010429e:	ff 4d 10             	decl   0x10(%ebp)
f01042a1:	eb 03                	jmp    f01042a6 <vprintfmt+0x3b1>
f01042a3:	ff 4d 10             	decl   0x10(%ebp)
f01042a6:	8b 45 10             	mov    0x10(%ebp),%eax
f01042a9:	48                   	dec    %eax
f01042aa:	8a 00                	mov    (%eax),%al
f01042ac:	3c 25                	cmp    $0x25,%al
f01042ae:	75 f3                	jne    f01042a3 <vprintfmt+0x3ae>
				/* do nothing */;
			break;
f01042b0:	90                   	nop
		}
	}
f01042b1:	e9 47 fc ff ff       	jmp    f0103efd <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
f01042b6:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f01042b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01042ba:	5b                   	pop    %ebx
f01042bb:	5e                   	pop    %esi
f01042bc:	5d                   	pop    %ebp
f01042bd:	c3                   	ret    

f01042be <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01042be:	55                   	push   %ebp
f01042bf:	89 e5                	mov    %esp,%ebp
f01042c1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01042c4:	8d 45 10             	lea    0x10(%ebp),%eax
f01042c7:	83 c0 04             	add    $0x4,%eax
f01042ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
f01042cd:	8b 45 10             	mov    0x10(%ebp),%eax
f01042d0:	ff 75 f4             	pushl  -0xc(%ebp)
f01042d3:	50                   	push   %eax
f01042d4:	ff 75 0c             	pushl  0xc(%ebp)
f01042d7:	ff 75 08             	pushl  0x8(%ebp)
f01042da:	e8 16 fc ff ff       	call   f0103ef5 <vprintfmt>
f01042df:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
f01042e2:	90                   	nop
f01042e3:	c9                   	leave  
f01042e4:	c3                   	ret    

f01042e5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01042e5:	55                   	push   %ebp
f01042e6:	89 e5                	mov    %esp,%ebp
	b->cnt++;
f01042e8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01042eb:	8b 40 08             	mov    0x8(%eax),%eax
f01042ee:	8d 50 01             	lea    0x1(%eax),%edx
f01042f1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01042f4:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
f01042f7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01042fa:	8b 10                	mov    (%eax),%edx
f01042fc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01042ff:	8b 40 04             	mov    0x4(%eax),%eax
f0104302:	39 c2                	cmp    %eax,%edx
f0104304:	73 12                	jae    f0104318 <sprintputch+0x33>
		*b->buf++ = ch;
f0104306:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104309:	8b 00                	mov    (%eax),%eax
f010430b:	8d 48 01             	lea    0x1(%eax),%ecx
f010430e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104311:	89 0a                	mov    %ecx,(%edx)
f0104313:	8b 55 08             	mov    0x8(%ebp),%edx
f0104316:	88 10                	mov    %dl,(%eax)
}
f0104318:	90                   	nop
f0104319:	5d                   	pop    %ebp
f010431a:	c3                   	ret    

f010431b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010431b:	55                   	push   %ebp
f010431c:	89 e5                	mov    %esp,%ebp
f010431e:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104321:	8b 45 08             	mov    0x8(%ebp),%eax
f0104324:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104327:	8b 45 0c             	mov    0xc(%ebp),%eax
f010432a:	8d 50 ff             	lea    -0x1(%eax),%edx
f010432d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104330:	01 d0                	add    %edx,%eax
f0104332:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104335:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010433c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0104340:	74 06                	je     f0104348 <vsnprintf+0x2d>
f0104342:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104346:	7f 07                	jg     f010434f <vsnprintf+0x34>
		return -E_INVAL;
f0104348:	b8 03 00 00 00       	mov    $0x3,%eax
f010434d:	eb 20                	jmp    f010436f <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010434f:	ff 75 14             	pushl  0x14(%ebp)
f0104352:	ff 75 10             	pushl  0x10(%ebp)
f0104355:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104358:	50                   	push   %eax
f0104359:	68 e5 42 10 f0       	push   $0xf01042e5
f010435e:	e8 92 fb ff ff       	call   f0103ef5 <vprintfmt>
f0104363:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
f0104366:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104369:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010436c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f010436f:	c9                   	leave  
f0104370:	c3                   	ret    

f0104371 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104371:	55                   	push   %ebp
f0104372:	89 e5                	mov    %esp,%ebp
f0104374:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104377:	8d 45 10             	lea    0x10(%ebp),%eax
f010437a:	83 c0 04             	add    $0x4,%eax
f010437d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
f0104380:	8b 45 10             	mov    0x10(%ebp),%eax
f0104383:	ff 75 f4             	pushl  -0xc(%ebp)
f0104386:	50                   	push   %eax
f0104387:	ff 75 0c             	pushl  0xc(%ebp)
f010438a:	ff 75 08             	pushl  0x8(%ebp)
f010438d:	e8 89 ff ff ff       	call   f010431b <vsnprintf>
f0104392:	83 c4 10             	add    $0x10,%esp
f0104395:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
f0104398:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
f010439b:	c9                   	leave  
f010439c:	c3                   	ret    

f010439d <readline>:

#define BUFLEN 1024
//static char buf[BUFLEN];

void readline(const char *prompt, char* buf)
{
f010439d:	55                   	push   %ebp
f010439e:	89 e5                	mov    %esp,%ebp
f01043a0:	83 ec 18             	sub    $0x18,%esp
	int i, c, echoing,mx;

	if (prompt != NULL)
f01043a3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01043a7:	74 13                	je     f01043bc <readline+0x1f>
		cprintf("%s", prompt);
f01043a9:	83 ec 08             	sub    $0x8,%esp
f01043ac:	ff 75 08             	pushl  0x8(%ebp)
f01043af:	68 bc 63 10 f0       	push   $0xf01063bc
f01043b4:	e8 ee eb ff ff       	call   f0102fa7 <cprintf>
f01043b9:	83 c4 10             	add    $0x10,%esp


	i = mx = 0;
f01043bc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01043c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01043c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	echoing = iscons(0);
f01043c9:	83 ec 0c             	sub    $0xc,%esp
f01043cc:	6a 00                	push   $0x0
f01043ce:	e8 74 c5 ff ff       	call   f0100947 <iscons>
f01043d3:	83 c4 10             	add    $0x10,%esp
f01043d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
	while (1) {
		c = getchar();
f01043d9:	e8 50 c5 ff ff       	call   f010092e <getchar>
f01043de:	89 45 e8             	mov    %eax,-0x18(%ebp)
		//cprintf("%d\n",c);
		if (c < 0) {
f01043e1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01043e5:	79 22                	jns    f0104409 <readline+0x6c>
			if (c != -E_EOF)
f01043e7:	83 7d e8 07          	cmpl   $0x7,-0x18(%ebp)
f01043eb:	0f 84 d8 00 00 00    	je     f01044c9 <readline+0x12c>
				cprintf("read error: %e\n", c);
f01043f1:	83 ec 08             	sub    $0x8,%esp
f01043f4:	ff 75 e8             	pushl  -0x18(%ebp)
f01043f7:	68 bf 63 10 f0       	push   $0xf01063bf
f01043fc:	e8 a6 eb ff ff       	call   f0102fa7 <cprintf>
f0104401:	83 c4 10             	add    $0x10,%esp
			return;
f0104404:	e9 c0 00 00 00       	jmp    f01044c9 <readline+0x12c>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104409:	83 7d e8 1f          	cmpl   $0x1f,-0x18(%ebp)
f010440d:	7e 44                	jle    f0104453 <readline+0xb6>
f010440f:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
f0104416:	7f 3b                	jg     f0104453 <readline+0xb6>
			if (echoing)
f0104418:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f010441c:	74 0e                	je     f010442c <readline+0x8f>
				cputchar(c);
f010441e:	83 ec 0c             	sub    $0xc,%esp
f0104421:	ff 75 e8             	pushl  -0x18(%ebp)
f0104424:	e8 ee c4 ff ff       	call   f0100917 <cputchar>
f0104429:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010442c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010442f:	8d 50 01             	lea    0x1(%eax),%edx
f0104432:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0104435:	89 c2                	mov    %eax,%edx
f0104437:	8b 45 0c             	mov    0xc(%ebp),%eax
f010443a:	01 d0                	add    %edx,%eax
f010443c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010443f:	88 10                	mov    %dl,(%eax)
			cprintf("f1");
f0104441:	83 ec 0c             	sub    $0xc,%esp
f0104444:	68 cf 63 10 f0       	push   $0xf01063cf
f0104449:	e8 59 eb ff ff       	call   f0102fa7 <cprintf>
f010444e:	83 c4 10             	add    $0x10,%esp
f0104451:	eb 62                	jmp    f01044b5 <readline+0x118>
		} else if (c == '\b' && i > 0) {
f0104453:	83 7d e8 08          	cmpl   $0x8,-0x18(%ebp)
f0104457:	75 2f                	jne    f0104488 <readline+0xeb>
f0104459:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010445d:	7e 29                	jle    f0104488 <readline+0xeb>
			if (echoing)
f010445f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0104463:	74 0e                	je     f0104473 <readline+0xd6>
				cputchar(c);
f0104465:	83 ec 0c             	sub    $0xc,%esp
f0104468:	ff 75 e8             	pushl  -0x18(%ebp)
f010446b:	e8 a7 c4 ff ff       	call   f0100917 <cputchar>
f0104470:	83 c4 10             	add    $0x10,%esp
			i--;
f0104473:	ff 4d f4             	decl   -0xc(%ebp)
			cprintf("f2");
f0104476:	83 ec 0c             	sub    $0xc,%esp
f0104479:	68 d2 63 10 f0       	push   $0xf01063d2
f010447e:	e8 24 eb ff ff       	call   f0102fa7 <cprintf>
f0104483:	83 c4 10             	add    $0x10,%esp
f0104486:	eb 2d                	jmp    f01044b5 <readline+0x118>
		} else if (c == '\n' || c == '\r') {
f0104488:	83 7d e8 0a          	cmpl   $0xa,-0x18(%ebp)
f010448c:	74 06                	je     f0104494 <readline+0xf7>
f010448e:	83 7d e8 0d          	cmpl   $0xd,-0x18(%ebp)
f0104492:	75 21                	jne    f01044b5 <readline+0x118>
			if (echoing)
f0104494:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0104498:	74 0e                	je     f01044a8 <readline+0x10b>
				cputchar(c);
f010449a:	83 ec 0c             	sub    $0xc,%esp
f010449d:	ff 75 e8             	pushl  -0x18(%ebp)
f01044a0:	e8 72 c4 ff ff       	call   f0100917 <cputchar>
f01044a5:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01044a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01044ab:	8b 45 0c             	mov    0xc(%ebp),%eax
f01044ae:	01 d0                	add    %edx,%eax
f01044b0:	c6 00 00             	movb   $0x0,(%eax)
			return;
f01044b3:	eb 15                	jmp    f01044ca <readline+0x12d>
		}
		mx = (i>mx?i:mx);
f01044b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01044b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01044bb:	39 d0                	cmp    %edx,%eax
f01044bd:	7d 02                	jge    f01044c1 <readline+0x124>
f01044bf:	89 d0                	mov    %edx,%eax
f01044c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	}
f01044c4:	e9 10 ff ff ff       	jmp    f01043d9 <readline+0x3c>
		c = getchar();
		//cprintf("%d\n",c);
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return;
f01044c9:	90                   	nop
			buf[i] = 0;
			return;
		}
		mx = (i>mx?i:mx);
	}
}
f01044ca:	c9                   	leave  
f01044cb:	c3                   	ret    

f01044cc <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f01044cc:	55                   	push   %ebp
f01044cd:	89 e5                	mov    %esp,%ebp
f01044cf:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
f01044d2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f01044d9:	eb 06                	jmp    f01044e1 <strlen+0x15>
		n++;
f01044db:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01044de:	ff 45 08             	incl   0x8(%ebp)
f01044e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01044e4:	8a 00                	mov    (%eax),%al
f01044e6:	84 c0                	test   %al,%al
f01044e8:	75 f1                	jne    f01044db <strlen+0xf>
		n++;
	return n;
f01044ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f01044ed:	c9                   	leave  
f01044ee:	c3                   	ret    

f01044ef <strnlen>:

int
strnlen(const char *s, uint32 size)
{
f01044ef:	55                   	push   %ebp
f01044f0:	89 e5                	mov    %esp,%ebp
f01044f2:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01044f5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f01044fc:	eb 09                	jmp    f0104507 <strnlen+0x18>
		n++;
f01044fe:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104501:	ff 45 08             	incl   0x8(%ebp)
f0104504:	ff 4d 0c             	decl   0xc(%ebp)
f0104507:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010450b:	74 09                	je     f0104516 <strnlen+0x27>
f010450d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104510:	8a 00                	mov    (%eax),%al
f0104512:	84 c0                	test   %al,%al
f0104514:	75 e8                	jne    f01044fe <strnlen+0xf>
		n++;
	return n;
f0104516:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0104519:	c9                   	leave  
f010451a:	c3                   	ret    

f010451b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010451b:	55                   	push   %ebp
f010451c:	89 e5                	mov    %esp,%ebp
f010451e:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
f0104521:	8b 45 08             	mov    0x8(%ebp),%eax
f0104524:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
f0104527:	90                   	nop
f0104528:	8b 45 08             	mov    0x8(%ebp),%eax
f010452b:	8d 50 01             	lea    0x1(%eax),%edx
f010452e:	89 55 08             	mov    %edx,0x8(%ebp)
f0104531:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104534:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104537:	89 4d 0c             	mov    %ecx,0xc(%ebp)
f010453a:	8a 12                	mov    (%edx),%dl
f010453c:	88 10                	mov    %dl,(%eax)
f010453e:	8a 00                	mov    (%eax),%al
f0104540:	84 c0                	test   %al,%al
f0104542:	75 e4                	jne    f0104528 <strcpy+0xd>
		/* do nothing */;
	return ret;
f0104544:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0104547:	c9                   	leave  
f0104548:	c3                   	ret    

f0104549 <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
f0104549:	55                   	push   %ebp
f010454a:	89 e5                	mov    %esp,%ebp
f010454c:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
f010454f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104552:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
f0104555:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f010455c:	eb 1f                	jmp    f010457d <strncpy+0x34>
		*dst++ = *src;
f010455e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104561:	8d 50 01             	lea    0x1(%eax),%edx
f0104564:	89 55 08             	mov    %edx,0x8(%ebp)
f0104567:	8b 55 0c             	mov    0xc(%ebp),%edx
f010456a:	8a 12                	mov    (%edx),%dl
f010456c:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f010456e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104571:	8a 00                	mov    (%eax),%al
f0104573:	84 c0                	test   %al,%al
f0104575:	74 03                	je     f010457a <strncpy+0x31>
			src++;
f0104577:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010457a:	ff 45 fc             	incl   -0x4(%ebp)
f010457d:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0104580:	3b 45 10             	cmp    0x10(%ebp),%eax
f0104583:	72 d9                	jb     f010455e <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
f0104585:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
f0104588:	c9                   	leave  
f0104589:	c3                   	ret    

f010458a <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
f010458a:	55                   	push   %ebp
f010458b:	89 e5                	mov    %esp,%ebp
f010458d:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
f0104590:	8b 45 08             	mov    0x8(%ebp),%eax
f0104593:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
f0104596:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010459a:	74 30                	je     f01045cc <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
f010459c:	eb 16                	jmp    f01045b4 <strlcpy+0x2a>
			*dst++ = *src++;
f010459e:	8b 45 08             	mov    0x8(%ebp),%eax
f01045a1:	8d 50 01             	lea    0x1(%eax),%edx
f01045a4:	89 55 08             	mov    %edx,0x8(%ebp)
f01045a7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01045aa:	8d 4a 01             	lea    0x1(%edx),%ecx
f01045ad:	89 4d 0c             	mov    %ecx,0xc(%ebp)
f01045b0:	8a 12                	mov    (%edx),%dl
f01045b2:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01045b4:	ff 4d 10             	decl   0x10(%ebp)
f01045b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01045bb:	74 09                	je     f01045c6 <strlcpy+0x3c>
f01045bd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01045c0:	8a 00                	mov    (%eax),%al
f01045c2:	84 c0                	test   %al,%al
f01045c4:	75 d8                	jne    f010459e <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
f01045c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01045c9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01045cc:	8b 55 08             	mov    0x8(%ebp),%edx
f01045cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01045d2:	29 c2                	sub    %eax,%edx
f01045d4:	89 d0                	mov    %edx,%eax
}
f01045d6:	c9                   	leave  
f01045d7:	c3                   	ret    

f01045d8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01045d8:	55                   	push   %ebp
f01045d9:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
f01045db:	eb 06                	jmp    f01045e3 <strcmp+0xb>
		p++, q++;
f01045dd:	ff 45 08             	incl   0x8(%ebp)
f01045e0:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01045e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01045e6:	8a 00                	mov    (%eax),%al
f01045e8:	84 c0                	test   %al,%al
f01045ea:	74 0e                	je     f01045fa <strcmp+0x22>
f01045ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01045ef:	8a 10                	mov    (%eax),%dl
f01045f1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01045f4:	8a 00                	mov    (%eax),%al
f01045f6:	38 c2                	cmp    %al,%dl
f01045f8:	74 e3                	je     f01045dd <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01045fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01045fd:	8a 00                	mov    (%eax),%al
f01045ff:	0f b6 d0             	movzbl %al,%edx
f0104602:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104605:	8a 00                	mov    (%eax),%al
f0104607:	0f b6 c0             	movzbl %al,%eax
f010460a:	29 c2                	sub    %eax,%edx
f010460c:	89 d0                	mov    %edx,%eax
}
f010460e:	5d                   	pop    %ebp
f010460f:	c3                   	ret    

f0104610 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
f0104610:	55                   	push   %ebp
f0104611:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
f0104613:	eb 09                	jmp    f010461e <strncmp+0xe>
		n--, p++, q++;
f0104615:	ff 4d 10             	decl   0x10(%ebp)
f0104618:	ff 45 08             	incl   0x8(%ebp)
f010461b:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
f010461e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0104622:	74 17                	je     f010463b <strncmp+0x2b>
f0104624:	8b 45 08             	mov    0x8(%ebp),%eax
f0104627:	8a 00                	mov    (%eax),%al
f0104629:	84 c0                	test   %al,%al
f010462b:	74 0e                	je     f010463b <strncmp+0x2b>
f010462d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104630:	8a 10                	mov    (%eax),%dl
f0104632:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104635:	8a 00                	mov    (%eax),%al
f0104637:	38 c2                	cmp    %al,%dl
f0104639:	74 da                	je     f0104615 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
f010463b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010463f:	75 07                	jne    f0104648 <strncmp+0x38>
		return 0;
f0104641:	b8 00 00 00 00       	mov    $0x0,%eax
f0104646:	eb 14                	jmp    f010465c <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104648:	8b 45 08             	mov    0x8(%ebp),%eax
f010464b:	8a 00                	mov    (%eax),%al
f010464d:	0f b6 d0             	movzbl %al,%edx
f0104650:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104653:	8a 00                	mov    (%eax),%al
f0104655:	0f b6 c0             	movzbl %al,%eax
f0104658:	29 c2                	sub    %eax,%edx
f010465a:	89 d0                	mov    %edx,%eax
}
f010465c:	5d                   	pop    %ebp
f010465d:	c3                   	ret    

f010465e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010465e:	55                   	push   %ebp
f010465f:	89 e5                	mov    %esp,%ebp
f0104661:	83 ec 04             	sub    $0x4,%esp
f0104664:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104667:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
f010466a:	eb 12                	jmp    f010467e <strchr+0x20>
		if (*s == c)
f010466c:	8b 45 08             	mov    0x8(%ebp),%eax
f010466f:	8a 00                	mov    (%eax),%al
f0104671:	3a 45 fc             	cmp    -0x4(%ebp),%al
f0104674:	75 05                	jne    f010467b <strchr+0x1d>
			return (char *) s;
f0104676:	8b 45 08             	mov    0x8(%ebp),%eax
f0104679:	eb 11                	jmp    f010468c <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010467b:	ff 45 08             	incl   0x8(%ebp)
f010467e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104681:	8a 00                	mov    (%eax),%al
f0104683:	84 c0                	test   %al,%al
f0104685:	75 e5                	jne    f010466c <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
f0104687:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010468c:	c9                   	leave  
f010468d:	c3                   	ret    

f010468e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010468e:	55                   	push   %ebp
f010468f:	89 e5                	mov    %esp,%ebp
f0104691:	83 ec 04             	sub    $0x4,%esp
f0104694:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104697:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
f010469a:	eb 0d                	jmp    f01046a9 <strfind+0x1b>
		if (*s == c)
f010469c:	8b 45 08             	mov    0x8(%ebp),%eax
f010469f:	8a 00                	mov    (%eax),%al
f01046a1:	3a 45 fc             	cmp    -0x4(%ebp),%al
f01046a4:	74 0e                	je     f01046b4 <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01046a6:	ff 45 08             	incl   0x8(%ebp)
f01046a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01046ac:	8a 00                	mov    (%eax),%al
f01046ae:	84 c0                	test   %al,%al
f01046b0:	75 ea                	jne    f010469c <strfind+0xe>
f01046b2:	eb 01                	jmp    f01046b5 <strfind+0x27>
		if (*s == c)
			break;
f01046b4:	90                   	nop
	return (char *) s;
f01046b5:	8b 45 08             	mov    0x8(%ebp),%eax
}
f01046b8:	c9                   	leave  
f01046b9:	c3                   	ret    

f01046ba <memset>:


void *
memset(void *v, int c, uint32 n)
{
f01046ba:	55                   	push   %ebp
f01046bb:	89 e5                	mov    %esp,%ebp
f01046bd:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
f01046c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01046c3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
f01046c6:	8b 45 10             	mov    0x10(%ebp),%eax
f01046c9:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
f01046cc:	eb 0e                	jmp    f01046dc <memset+0x22>
		*p++ = c;
f01046ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01046d1:	8d 50 01             	lea    0x1(%eax),%edx
f01046d4:	89 55 fc             	mov    %edx,-0x4(%ebp)
f01046d7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01046da:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f01046dc:	ff 4d f8             	decl   -0x8(%ebp)
f01046df:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
f01046e3:	79 e9                	jns    f01046ce <memset+0x14>
		*p++ = c;

	return v;
f01046e5:	8b 45 08             	mov    0x8(%ebp),%eax
}
f01046e8:	c9                   	leave  
f01046e9:	c3                   	ret    

f01046ea <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
f01046ea:	55                   	push   %ebp
f01046eb:	89 e5                	mov    %esp,%ebp
f01046ed:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
f01046f0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01046f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
f01046f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01046f9:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
f01046fc:	eb 16                	jmp    f0104714 <memcpy+0x2a>
		*d++ = *s++;
f01046fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0104701:	8d 50 01             	lea    0x1(%eax),%edx
f0104704:	89 55 f8             	mov    %edx,-0x8(%ebp)
f0104707:	8b 55 fc             	mov    -0x4(%ebp),%edx
f010470a:	8d 4a 01             	lea    0x1(%edx),%ecx
f010470d:	89 4d fc             	mov    %ecx,-0x4(%ebp)
f0104710:	8a 12                	mov    (%edx),%dl
f0104712:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f0104714:	8b 45 10             	mov    0x10(%ebp),%eax
f0104717:	8d 50 ff             	lea    -0x1(%eax),%edx
f010471a:	89 55 10             	mov    %edx,0x10(%ebp)
f010471d:	85 c0                	test   %eax,%eax
f010471f:	75 dd                	jne    f01046fe <memcpy+0x14>
		*d++ = *s++;

	return dst;
f0104721:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0104724:	c9                   	leave  
f0104725:	c3                   	ret    

f0104726 <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
f0104726:	55                   	push   %ebp
f0104727:	89 e5                	mov    %esp,%ebp
f0104729:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;
	
	s = src;
f010472c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010472f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
f0104732:	8b 45 08             	mov    0x8(%ebp),%eax
f0104735:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
f0104738:	8b 45 fc             	mov    -0x4(%ebp),%eax
f010473b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
f010473e:	73 50                	jae    f0104790 <memmove+0x6a>
f0104740:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0104743:	8b 45 10             	mov    0x10(%ebp),%eax
f0104746:	01 d0                	add    %edx,%eax
f0104748:	3b 45 f8             	cmp    -0x8(%ebp),%eax
f010474b:	76 43                	jbe    f0104790 <memmove+0x6a>
		s += n;
f010474d:	8b 45 10             	mov    0x10(%ebp),%eax
f0104750:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
f0104753:	8b 45 10             	mov    0x10(%ebp),%eax
f0104756:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
f0104759:	eb 10                	jmp    f010476b <memmove+0x45>
			*--d = *--s;
f010475b:	ff 4d f8             	decl   -0x8(%ebp)
f010475e:	ff 4d fc             	decl   -0x4(%ebp)
f0104761:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0104764:	8a 10                	mov    (%eax),%dl
f0104766:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0104769:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f010476b:	8b 45 10             	mov    0x10(%ebp),%eax
f010476e:	8d 50 ff             	lea    -0x1(%eax),%edx
f0104771:	89 55 10             	mov    %edx,0x10(%ebp)
f0104774:	85 c0                	test   %eax,%eax
f0104776:	75 e3                	jne    f010475b <memmove+0x35>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104778:	eb 23                	jmp    f010479d <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f010477a:	8b 45 f8             	mov    -0x8(%ebp),%eax
f010477d:	8d 50 01             	lea    0x1(%eax),%edx
f0104780:	89 55 f8             	mov    %edx,-0x8(%ebp)
f0104783:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0104786:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104789:	89 4d fc             	mov    %ecx,-0x4(%ebp)
f010478c:	8a 12                	mov    (%edx),%dl
f010478e:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0104790:	8b 45 10             	mov    0x10(%ebp),%eax
f0104793:	8d 50 ff             	lea    -0x1(%eax),%edx
f0104796:	89 55 10             	mov    %edx,0x10(%ebp)
f0104799:	85 c0                	test   %eax,%eax
f010479b:	75 dd                	jne    f010477a <memmove+0x54>
			*d++ = *s++;

	return dst;
f010479d:	8b 45 08             	mov    0x8(%ebp),%eax
}
f01047a0:	c9                   	leave  
f01047a1:	c3                   	ret    

f01047a2 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
f01047a2:	55                   	push   %ebp
f01047a3:	89 e5                	mov    %esp,%ebp
f01047a5:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
f01047a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01047ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
f01047ae:	8b 45 0c             	mov    0xc(%ebp),%eax
f01047b1:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
f01047b4:	eb 2a                	jmp    f01047e0 <memcmp+0x3e>
		if (*s1 != *s2)
f01047b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01047b9:	8a 10                	mov    (%eax),%dl
f01047bb:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01047be:	8a 00                	mov    (%eax),%al
f01047c0:	38 c2                	cmp    %al,%dl
f01047c2:	74 16                	je     f01047da <memcmp+0x38>
			return (int) *s1 - (int) *s2;
f01047c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01047c7:	8a 00                	mov    (%eax),%al
f01047c9:	0f b6 d0             	movzbl %al,%edx
f01047cc:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01047cf:	8a 00                	mov    (%eax),%al
f01047d1:	0f b6 c0             	movzbl %al,%eax
f01047d4:	29 c2                	sub    %eax,%edx
f01047d6:	89 d0                	mov    %edx,%eax
f01047d8:	eb 18                	jmp    f01047f2 <memcmp+0x50>
		s1++, s2++;
f01047da:	ff 45 fc             	incl   -0x4(%ebp)
f01047dd:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
f01047e0:	8b 45 10             	mov    0x10(%ebp),%eax
f01047e3:	8d 50 ff             	lea    -0x1(%eax),%edx
f01047e6:	89 55 10             	mov    %edx,0x10(%ebp)
f01047e9:	85 c0                	test   %eax,%eax
f01047eb:	75 c9                	jne    f01047b6 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01047ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01047f2:	c9                   	leave  
f01047f3:	c3                   	ret    

f01047f4 <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
f01047f4:	55                   	push   %ebp
f01047f5:	89 e5                	mov    %esp,%ebp
f01047f7:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
f01047fa:	8b 55 08             	mov    0x8(%ebp),%edx
f01047fd:	8b 45 10             	mov    0x10(%ebp),%eax
f0104800:	01 d0                	add    %edx,%eax
f0104802:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
f0104805:	eb 15                	jmp    f010481c <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104807:	8b 45 08             	mov    0x8(%ebp),%eax
f010480a:	8a 00                	mov    (%eax),%al
f010480c:	0f b6 d0             	movzbl %al,%edx
f010480f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104812:	0f b6 c0             	movzbl %al,%eax
f0104815:	39 c2                	cmp    %eax,%edx
f0104817:	74 0d                	je     f0104826 <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104819:	ff 45 08             	incl   0x8(%ebp)
f010481c:	8b 45 08             	mov    0x8(%ebp),%eax
f010481f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f0104822:	72 e3                	jb     f0104807 <memfind+0x13>
f0104824:	eb 01                	jmp    f0104827 <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
f0104826:	90                   	nop
	return (void *) s;
f0104827:	8b 45 08             	mov    0x8(%ebp),%eax
}
f010482a:	c9                   	leave  
f010482b:	c3                   	ret    

f010482c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010482c:	55                   	push   %ebp
f010482d:	89 e5                	mov    %esp,%ebp
f010482f:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
f0104832:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
f0104839:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104840:	eb 03                	jmp    f0104845 <strtol+0x19>
		s++;
f0104842:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104845:	8b 45 08             	mov    0x8(%ebp),%eax
f0104848:	8a 00                	mov    (%eax),%al
f010484a:	3c 20                	cmp    $0x20,%al
f010484c:	74 f4                	je     f0104842 <strtol+0x16>
f010484e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104851:	8a 00                	mov    (%eax),%al
f0104853:	3c 09                	cmp    $0x9,%al
f0104855:	74 eb                	je     f0104842 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104857:	8b 45 08             	mov    0x8(%ebp),%eax
f010485a:	8a 00                	mov    (%eax),%al
f010485c:	3c 2b                	cmp    $0x2b,%al
f010485e:	75 05                	jne    f0104865 <strtol+0x39>
		s++;
f0104860:	ff 45 08             	incl   0x8(%ebp)
f0104863:	eb 13                	jmp    f0104878 <strtol+0x4c>
	else if (*s == '-')
f0104865:	8b 45 08             	mov    0x8(%ebp),%eax
f0104868:	8a 00                	mov    (%eax),%al
f010486a:	3c 2d                	cmp    $0x2d,%al
f010486c:	75 0a                	jne    f0104878 <strtol+0x4c>
		s++, neg = 1;
f010486e:	ff 45 08             	incl   0x8(%ebp)
f0104871:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104878:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010487c:	74 06                	je     f0104884 <strtol+0x58>
f010487e:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
f0104882:	75 20                	jne    f01048a4 <strtol+0x78>
f0104884:	8b 45 08             	mov    0x8(%ebp),%eax
f0104887:	8a 00                	mov    (%eax),%al
f0104889:	3c 30                	cmp    $0x30,%al
f010488b:	75 17                	jne    f01048a4 <strtol+0x78>
f010488d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104890:	40                   	inc    %eax
f0104891:	8a 00                	mov    (%eax),%al
f0104893:	3c 78                	cmp    $0x78,%al
f0104895:	75 0d                	jne    f01048a4 <strtol+0x78>
		s += 2, base = 16;
f0104897:	83 45 08 02          	addl   $0x2,0x8(%ebp)
f010489b:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f01048a2:	eb 28                	jmp    f01048cc <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
f01048a4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01048a8:	75 15                	jne    f01048bf <strtol+0x93>
f01048aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01048ad:	8a 00                	mov    (%eax),%al
f01048af:	3c 30                	cmp    $0x30,%al
f01048b1:	75 0c                	jne    f01048bf <strtol+0x93>
		s++, base = 8;
f01048b3:	ff 45 08             	incl   0x8(%ebp)
f01048b6:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f01048bd:	eb 0d                	jmp    f01048cc <strtol+0xa0>
	else if (base == 0)
f01048bf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01048c3:	75 07                	jne    f01048cc <strtol+0xa0>
		base = 10;
f01048c5:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01048cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01048cf:	8a 00                	mov    (%eax),%al
f01048d1:	3c 2f                	cmp    $0x2f,%al
f01048d3:	7e 19                	jle    f01048ee <strtol+0xc2>
f01048d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01048d8:	8a 00                	mov    (%eax),%al
f01048da:	3c 39                	cmp    $0x39,%al
f01048dc:	7f 10                	jg     f01048ee <strtol+0xc2>
			dig = *s - '0';
f01048de:	8b 45 08             	mov    0x8(%ebp),%eax
f01048e1:	8a 00                	mov    (%eax),%al
f01048e3:	0f be c0             	movsbl %al,%eax
f01048e6:	83 e8 30             	sub    $0x30,%eax
f01048e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01048ec:	eb 42                	jmp    f0104930 <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
f01048ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01048f1:	8a 00                	mov    (%eax),%al
f01048f3:	3c 60                	cmp    $0x60,%al
f01048f5:	7e 19                	jle    f0104910 <strtol+0xe4>
f01048f7:	8b 45 08             	mov    0x8(%ebp),%eax
f01048fa:	8a 00                	mov    (%eax),%al
f01048fc:	3c 7a                	cmp    $0x7a,%al
f01048fe:	7f 10                	jg     f0104910 <strtol+0xe4>
			dig = *s - 'a' + 10;
f0104900:	8b 45 08             	mov    0x8(%ebp),%eax
f0104903:	8a 00                	mov    (%eax),%al
f0104905:	0f be c0             	movsbl %al,%eax
f0104908:	83 e8 57             	sub    $0x57,%eax
f010490b:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010490e:	eb 20                	jmp    f0104930 <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
f0104910:	8b 45 08             	mov    0x8(%ebp),%eax
f0104913:	8a 00                	mov    (%eax),%al
f0104915:	3c 40                	cmp    $0x40,%al
f0104917:	7e 39                	jle    f0104952 <strtol+0x126>
f0104919:	8b 45 08             	mov    0x8(%ebp),%eax
f010491c:	8a 00                	mov    (%eax),%al
f010491e:	3c 5a                	cmp    $0x5a,%al
f0104920:	7f 30                	jg     f0104952 <strtol+0x126>
			dig = *s - 'A' + 10;
f0104922:	8b 45 08             	mov    0x8(%ebp),%eax
f0104925:	8a 00                	mov    (%eax),%al
f0104927:	0f be c0             	movsbl %al,%eax
f010492a:	83 e8 37             	sub    $0x37,%eax
f010492d:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
f0104930:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104933:	3b 45 10             	cmp    0x10(%ebp),%eax
f0104936:	7d 19                	jge    f0104951 <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
f0104938:	ff 45 08             	incl   0x8(%ebp)
f010493b:	8b 45 f8             	mov    -0x8(%ebp),%eax
f010493e:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104942:	89 c2                	mov    %eax,%edx
f0104944:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104947:	01 d0                	add    %edx,%eax
f0104949:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
f010494c:	e9 7b ff ff ff       	jmp    f01048cc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
f0104951:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0104952:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104956:	74 08                	je     f0104960 <strtol+0x134>
		*endptr = (char *) s;
f0104958:	8b 45 0c             	mov    0xc(%ebp),%eax
f010495b:	8b 55 08             	mov    0x8(%ebp),%edx
f010495e:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0104960:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
f0104964:	74 07                	je     f010496d <strtol+0x141>
f0104966:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0104969:	f7 d8                	neg    %eax
f010496b:	eb 03                	jmp    f0104970 <strtol+0x144>
f010496d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
f0104970:	c9                   	leave  
f0104971:	c3                   	ret    

f0104972 <strsplit>:

int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
f0104972:	55                   	push   %ebp
f0104973:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
f0104975:	8b 45 14             	mov    0x14(%ebp),%eax
f0104978:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
f010497e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104981:	8b 00                	mov    (%eax),%eax
f0104983:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f010498a:	8b 45 10             	mov    0x10(%ebp),%eax
f010498d:	01 d0                	add    %edx,%eax
f010498f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
f0104995:	eb 0c                	jmp    f01049a3 <strsplit+0x31>
			*string++ = 0;
f0104997:	8b 45 08             	mov    0x8(%ebp),%eax
f010499a:	8d 50 01             	lea    0x1(%eax),%edx
f010499d:	89 55 08             	mov    %edx,0x8(%ebp)
f01049a0:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
f01049a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01049a6:	8a 00                	mov    (%eax),%al
f01049a8:	84 c0                	test   %al,%al
f01049aa:	74 18                	je     f01049c4 <strsplit+0x52>
f01049ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01049af:	8a 00                	mov    (%eax),%al
f01049b1:	0f be c0             	movsbl %al,%eax
f01049b4:	50                   	push   %eax
f01049b5:	ff 75 0c             	pushl  0xc(%ebp)
f01049b8:	e8 a1 fc ff ff       	call   f010465e <strchr>
f01049bd:	83 c4 08             	add    $0x8,%esp
f01049c0:	85 c0                	test   %eax,%eax
f01049c2:	75 d3                	jne    f0104997 <strsplit+0x25>
			*string++ = 0;
		
		//if the command string is finished, then break the loop
		if (*string == 0)
f01049c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01049c7:	8a 00                	mov    (%eax),%al
f01049c9:	84 c0                	test   %al,%al
f01049cb:	74 5a                	je     f0104a27 <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1) 
f01049cd:	8b 45 14             	mov    0x14(%ebp),%eax
f01049d0:	8b 00                	mov    (%eax),%eax
f01049d2:	83 f8 0f             	cmp    $0xf,%eax
f01049d5:	75 07                	jne    f01049de <strsplit+0x6c>
		{
			return 0;
f01049d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01049dc:	eb 66                	jmp    f0104a44 <strsplit+0xd2>
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
f01049de:	8b 45 14             	mov    0x14(%ebp),%eax
f01049e1:	8b 00                	mov    (%eax),%eax
f01049e3:	8d 48 01             	lea    0x1(%eax),%ecx
f01049e6:	8b 55 14             	mov    0x14(%ebp),%edx
f01049e9:	89 0a                	mov    %ecx,(%edx)
f01049eb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01049f2:	8b 45 10             	mov    0x10(%ebp),%eax
f01049f5:	01 c2                	add    %eax,%edx
f01049f7:	8b 45 08             	mov    0x8(%ebp),%eax
f01049fa:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
f01049fc:	eb 03                	jmp    f0104a01 <strsplit+0x8f>
			string++;
f01049fe:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
f0104a01:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a04:	8a 00                	mov    (%eax),%al
f0104a06:	84 c0                	test   %al,%al
f0104a08:	74 8b                	je     f0104995 <strsplit+0x23>
f0104a0a:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a0d:	8a 00                	mov    (%eax),%al
f0104a0f:	0f be c0             	movsbl %al,%eax
f0104a12:	50                   	push   %eax
f0104a13:	ff 75 0c             	pushl  0xc(%ebp)
f0104a16:	e8 43 fc ff ff       	call   f010465e <strchr>
f0104a1b:	83 c4 08             	add    $0x8,%esp
f0104a1e:	85 c0                	test   %eax,%eax
f0104a20:	74 dc                	je     f01049fe <strsplit+0x8c>
			string++;
	}
f0104a22:	e9 6e ff ff ff       	jmp    f0104995 <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;
		
		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
f0104a27:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
f0104a28:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a2b:	8b 00                	mov    (%eax),%eax
f0104a2d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0104a34:	8b 45 10             	mov    0x10(%ebp),%eax
f0104a37:	01 d0                	add    %edx,%eax
f0104a39:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
f0104a3f:	b8 01 00 00 00       	mov    $0x1,%eax
}
f0104a44:	c9                   	leave  
f0104a45:	c3                   	ret    
f0104a46:	66 90                	xchg   %ax,%ax

f0104a48 <__udivdi3>:
f0104a48:	55                   	push   %ebp
f0104a49:	57                   	push   %edi
f0104a4a:	56                   	push   %esi
f0104a4b:	53                   	push   %ebx
f0104a4c:	83 ec 1c             	sub    $0x1c,%esp
f0104a4f:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0104a53:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0104a57:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104a5b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104a5f:	89 ca                	mov    %ecx,%edx
f0104a61:	89 f8                	mov    %edi,%eax
f0104a63:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0104a67:	85 f6                	test   %esi,%esi
f0104a69:	75 2d                	jne    f0104a98 <__udivdi3+0x50>
f0104a6b:	39 cf                	cmp    %ecx,%edi
f0104a6d:	77 65                	ja     f0104ad4 <__udivdi3+0x8c>
f0104a6f:	89 fd                	mov    %edi,%ebp
f0104a71:	85 ff                	test   %edi,%edi
f0104a73:	75 0b                	jne    f0104a80 <__udivdi3+0x38>
f0104a75:	b8 01 00 00 00       	mov    $0x1,%eax
f0104a7a:	31 d2                	xor    %edx,%edx
f0104a7c:	f7 f7                	div    %edi
f0104a7e:	89 c5                	mov    %eax,%ebp
f0104a80:	31 d2                	xor    %edx,%edx
f0104a82:	89 c8                	mov    %ecx,%eax
f0104a84:	f7 f5                	div    %ebp
f0104a86:	89 c1                	mov    %eax,%ecx
f0104a88:	89 d8                	mov    %ebx,%eax
f0104a8a:	f7 f5                	div    %ebp
f0104a8c:	89 cf                	mov    %ecx,%edi
f0104a8e:	89 fa                	mov    %edi,%edx
f0104a90:	83 c4 1c             	add    $0x1c,%esp
f0104a93:	5b                   	pop    %ebx
f0104a94:	5e                   	pop    %esi
f0104a95:	5f                   	pop    %edi
f0104a96:	5d                   	pop    %ebp
f0104a97:	c3                   	ret    
f0104a98:	39 ce                	cmp    %ecx,%esi
f0104a9a:	77 28                	ja     f0104ac4 <__udivdi3+0x7c>
f0104a9c:	0f bd fe             	bsr    %esi,%edi
f0104a9f:	83 f7 1f             	xor    $0x1f,%edi
f0104aa2:	75 40                	jne    f0104ae4 <__udivdi3+0x9c>
f0104aa4:	39 ce                	cmp    %ecx,%esi
f0104aa6:	72 0a                	jb     f0104ab2 <__udivdi3+0x6a>
f0104aa8:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0104aac:	0f 87 9e 00 00 00    	ja     f0104b50 <__udivdi3+0x108>
f0104ab2:	b8 01 00 00 00       	mov    $0x1,%eax
f0104ab7:	89 fa                	mov    %edi,%edx
f0104ab9:	83 c4 1c             	add    $0x1c,%esp
f0104abc:	5b                   	pop    %ebx
f0104abd:	5e                   	pop    %esi
f0104abe:	5f                   	pop    %edi
f0104abf:	5d                   	pop    %ebp
f0104ac0:	c3                   	ret    
f0104ac1:	8d 76 00             	lea    0x0(%esi),%esi
f0104ac4:	31 ff                	xor    %edi,%edi
f0104ac6:	31 c0                	xor    %eax,%eax
f0104ac8:	89 fa                	mov    %edi,%edx
f0104aca:	83 c4 1c             	add    $0x1c,%esp
f0104acd:	5b                   	pop    %ebx
f0104ace:	5e                   	pop    %esi
f0104acf:	5f                   	pop    %edi
f0104ad0:	5d                   	pop    %ebp
f0104ad1:	c3                   	ret    
f0104ad2:	66 90                	xchg   %ax,%ax
f0104ad4:	89 d8                	mov    %ebx,%eax
f0104ad6:	f7 f7                	div    %edi
f0104ad8:	31 ff                	xor    %edi,%edi
f0104ada:	89 fa                	mov    %edi,%edx
f0104adc:	83 c4 1c             	add    $0x1c,%esp
f0104adf:	5b                   	pop    %ebx
f0104ae0:	5e                   	pop    %esi
f0104ae1:	5f                   	pop    %edi
f0104ae2:	5d                   	pop    %ebp
f0104ae3:	c3                   	ret    
f0104ae4:	bd 20 00 00 00       	mov    $0x20,%ebp
f0104ae9:	89 eb                	mov    %ebp,%ebx
f0104aeb:	29 fb                	sub    %edi,%ebx
f0104aed:	89 f9                	mov    %edi,%ecx
f0104aef:	d3 e6                	shl    %cl,%esi
f0104af1:	89 c5                	mov    %eax,%ebp
f0104af3:	88 d9                	mov    %bl,%cl
f0104af5:	d3 ed                	shr    %cl,%ebp
f0104af7:	89 e9                	mov    %ebp,%ecx
f0104af9:	09 f1                	or     %esi,%ecx
f0104afb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104aff:	89 f9                	mov    %edi,%ecx
f0104b01:	d3 e0                	shl    %cl,%eax
f0104b03:	89 c5                	mov    %eax,%ebp
f0104b05:	89 d6                	mov    %edx,%esi
f0104b07:	88 d9                	mov    %bl,%cl
f0104b09:	d3 ee                	shr    %cl,%esi
f0104b0b:	89 f9                	mov    %edi,%ecx
f0104b0d:	d3 e2                	shl    %cl,%edx
f0104b0f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104b13:	88 d9                	mov    %bl,%cl
f0104b15:	d3 e8                	shr    %cl,%eax
f0104b17:	09 c2                	or     %eax,%edx
f0104b19:	89 d0                	mov    %edx,%eax
f0104b1b:	89 f2                	mov    %esi,%edx
f0104b1d:	f7 74 24 0c          	divl   0xc(%esp)
f0104b21:	89 d6                	mov    %edx,%esi
f0104b23:	89 c3                	mov    %eax,%ebx
f0104b25:	f7 e5                	mul    %ebp
f0104b27:	39 d6                	cmp    %edx,%esi
f0104b29:	72 19                	jb     f0104b44 <__udivdi3+0xfc>
f0104b2b:	74 0b                	je     f0104b38 <__udivdi3+0xf0>
f0104b2d:	89 d8                	mov    %ebx,%eax
f0104b2f:	31 ff                	xor    %edi,%edi
f0104b31:	e9 58 ff ff ff       	jmp    f0104a8e <__udivdi3+0x46>
f0104b36:	66 90                	xchg   %ax,%ax
f0104b38:	8b 54 24 08          	mov    0x8(%esp),%edx
f0104b3c:	89 f9                	mov    %edi,%ecx
f0104b3e:	d3 e2                	shl    %cl,%edx
f0104b40:	39 c2                	cmp    %eax,%edx
f0104b42:	73 e9                	jae    f0104b2d <__udivdi3+0xe5>
f0104b44:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0104b47:	31 ff                	xor    %edi,%edi
f0104b49:	e9 40 ff ff ff       	jmp    f0104a8e <__udivdi3+0x46>
f0104b4e:	66 90                	xchg   %ax,%ax
f0104b50:	31 c0                	xor    %eax,%eax
f0104b52:	e9 37 ff ff ff       	jmp    f0104a8e <__udivdi3+0x46>
f0104b57:	90                   	nop

f0104b58 <__umoddi3>:
f0104b58:	55                   	push   %ebp
f0104b59:	57                   	push   %edi
f0104b5a:	56                   	push   %esi
f0104b5b:	53                   	push   %ebx
f0104b5c:	83 ec 1c             	sub    $0x1c,%esp
f0104b5f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0104b63:	8b 74 24 34          	mov    0x34(%esp),%esi
f0104b67:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104b6b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0104b6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104b73:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104b77:	89 f3                	mov    %esi,%ebx
f0104b79:	89 fa                	mov    %edi,%edx
f0104b7b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104b7f:	89 34 24             	mov    %esi,(%esp)
f0104b82:	85 c0                	test   %eax,%eax
f0104b84:	75 1a                	jne    f0104ba0 <__umoddi3+0x48>
f0104b86:	39 f7                	cmp    %esi,%edi
f0104b88:	0f 86 a2 00 00 00    	jbe    f0104c30 <__umoddi3+0xd8>
f0104b8e:	89 c8                	mov    %ecx,%eax
f0104b90:	89 f2                	mov    %esi,%edx
f0104b92:	f7 f7                	div    %edi
f0104b94:	89 d0                	mov    %edx,%eax
f0104b96:	31 d2                	xor    %edx,%edx
f0104b98:	83 c4 1c             	add    $0x1c,%esp
f0104b9b:	5b                   	pop    %ebx
f0104b9c:	5e                   	pop    %esi
f0104b9d:	5f                   	pop    %edi
f0104b9e:	5d                   	pop    %ebp
f0104b9f:	c3                   	ret    
f0104ba0:	39 f0                	cmp    %esi,%eax
f0104ba2:	0f 87 ac 00 00 00    	ja     f0104c54 <__umoddi3+0xfc>
f0104ba8:	0f bd e8             	bsr    %eax,%ebp
f0104bab:	83 f5 1f             	xor    $0x1f,%ebp
f0104bae:	0f 84 ac 00 00 00    	je     f0104c60 <__umoddi3+0x108>
f0104bb4:	bf 20 00 00 00       	mov    $0x20,%edi
f0104bb9:	29 ef                	sub    %ebp,%edi
f0104bbb:	89 fe                	mov    %edi,%esi
f0104bbd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104bc1:	89 e9                	mov    %ebp,%ecx
f0104bc3:	d3 e0                	shl    %cl,%eax
f0104bc5:	89 d7                	mov    %edx,%edi
f0104bc7:	89 f1                	mov    %esi,%ecx
f0104bc9:	d3 ef                	shr    %cl,%edi
f0104bcb:	09 c7                	or     %eax,%edi
f0104bcd:	89 e9                	mov    %ebp,%ecx
f0104bcf:	d3 e2                	shl    %cl,%edx
f0104bd1:	89 14 24             	mov    %edx,(%esp)
f0104bd4:	89 d8                	mov    %ebx,%eax
f0104bd6:	d3 e0                	shl    %cl,%eax
f0104bd8:	89 c2                	mov    %eax,%edx
f0104bda:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104bde:	d3 e0                	shl    %cl,%eax
f0104be0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104be4:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104be8:	89 f1                	mov    %esi,%ecx
f0104bea:	d3 e8                	shr    %cl,%eax
f0104bec:	09 d0                	or     %edx,%eax
f0104bee:	d3 eb                	shr    %cl,%ebx
f0104bf0:	89 da                	mov    %ebx,%edx
f0104bf2:	f7 f7                	div    %edi
f0104bf4:	89 d3                	mov    %edx,%ebx
f0104bf6:	f7 24 24             	mull   (%esp)
f0104bf9:	89 c6                	mov    %eax,%esi
f0104bfb:	89 d1                	mov    %edx,%ecx
f0104bfd:	39 d3                	cmp    %edx,%ebx
f0104bff:	0f 82 87 00 00 00    	jb     f0104c8c <__umoddi3+0x134>
f0104c05:	0f 84 91 00 00 00    	je     f0104c9c <__umoddi3+0x144>
f0104c0b:	8b 54 24 04          	mov    0x4(%esp),%edx
f0104c0f:	29 f2                	sub    %esi,%edx
f0104c11:	19 cb                	sbb    %ecx,%ebx
f0104c13:	89 d8                	mov    %ebx,%eax
f0104c15:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f0104c19:	d3 e0                	shl    %cl,%eax
f0104c1b:	89 e9                	mov    %ebp,%ecx
f0104c1d:	d3 ea                	shr    %cl,%edx
f0104c1f:	09 d0                	or     %edx,%eax
f0104c21:	89 e9                	mov    %ebp,%ecx
f0104c23:	d3 eb                	shr    %cl,%ebx
f0104c25:	89 da                	mov    %ebx,%edx
f0104c27:	83 c4 1c             	add    $0x1c,%esp
f0104c2a:	5b                   	pop    %ebx
f0104c2b:	5e                   	pop    %esi
f0104c2c:	5f                   	pop    %edi
f0104c2d:	5d                   	pop    %ebp
f0104c2e:	c3                   	ret    
f0104c2f:	90                   	nop
f0104c30:	89 fd                	mov    %edi,%ebp
f0104c32:	85 ff                	test   %edi,%edi
f0104c34:	75 0b                	jne    f0104c41 <__umoddi3+0xe9>
f0104c36:	b8 01 00 00 00       	mov    $0x1,%eax
f0104c3b:	31 d2                	xor    %edx,%edx
f0104c3d:	f7 f7                	div    %edi
f0104c3f:	89 c5                	mov    %eax,%ebp
f0104c41:	89 f0                	mov    %esi,%eax
f0104c43:	31 d2                	xor    %edx,%edx
f0104c45:	f7 f5                	div    %ebp
f0104c47:	89 c8                	mov    %ecx,%eax
f0104c49:	f7 f5                	div    %ebp
f0104c4b:	89 d0                	mov    %edx,%eax
f0104c4d:	e9 44 ff ff ff       	jmp    f0104b96 <__umoddi3+0x3e>
f0104c52:	66 90                	xchg   %ax,%ax
f0104c54:	89 c8                	mov    %ecx,%eax
f0104c56:	89 f2                	mov    %esi,%edx
f0104c58:	83 c4 1c             	add    $0x1c,%esp
f0104c5b:	5b                   	pop    %ebx
f0104c5c:	5e                   	pop    %esi
f0104c5d:	5f                   	pop    %edi
f0104c5e:	5d                   	pop    %ebp
f0104c5f:	c3                   	ret    
f0104c60:	3b 04 24             	cmp    (%esp),%eax
f0104c63:	72 06                	jb     f0104c6b <__umoddi3+0x113>
f0104c65:	3b 7c 24 04          	cmp    0x4(%esp),%edi
f0104c69:	77 0f                	ja     f0104c7a <__umoddi3+0x122>
f0104c6b:	89 f2                	mov    %esi,%edx
f0104c6d:	29 f9                	sub    %edi,%ecx
f0104c6f:	1b 54 24 0c          	sbb    0xc(%esp),%edx
f0104c73:	89 14 24             	mov    %edx,(%esp)
f0104c76:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104c7a:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104c7e:	8b 14 24             	mov    (%esp),%edx
f0104c81:	83 c4 1c             	add    $0x1c,%esp
f0104c84:	5b                   	pop    %ebx
f0104c85:	5e                   	pop    %esi
f0104c86:	5f                   	pop    %edi
f0104c87:	5d                   	pop    %ebp
f0104c88:	c3                   	ret    
f0104c89:	8d 76 00             	lea    0x0(%esi),%esi
f0104c8c:	2b 04 24             	sub    (%esp),%eax
f0104c8f:	19 fa                	sbb    %edi,%edx
f0104c91:	89 d1                	mov    %edx,%ecx
f0104c93:	89 c6                	mov    %eax,%esi
f0104c95:	e9 71 ff ff ff       	jmp    f0104c0b <__umoddi3+0xb3>
f0104c9a:	66 90                	xchg   %ax,%ax
f0104c9c:	39 44 24 04          	cmp    %eax,0x4(%esp)
f0104ca0:	72 ea                	jb     f0104c8c <__umoddi3+0x134>
f0104ca2:	89 d9                	mov    %ebx,%ecx
f0104ca4:	e9 62 ff ff ff       	jmp    f0104c0b <__umoddi3+0xb3>
