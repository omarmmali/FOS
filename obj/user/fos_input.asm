
obj/user/fos_input:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	mov $0, %eax
  800020:	b8 00 00 00 00       	mov    $0x0,%eax
	cmpl $USTACKTOP, %esp
  800025:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  80002b:	75 04                	jne    800031 <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  80002d:	6a 00                	push   $0x0
	pushl $0
  80002f:	6a 00                	push   $0x0

00800031 <args_exist>:

args_exist:
	call libmain
  800031:	e8 95 00 00 00       	call   8000cb <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <_main>:

#include <inc/lib.h>

void
_main(void)
{	
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	81 ec 18 02 00 00    	sub    $0x218,%esp
	int i1=0;
  800041:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int i2=0;
  800048:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	char buff1[256];
	char buff2[256];	
	
	readline("Please enter first number :", buff1);	
  80004f:	83 ec 08             	sub    $0x8,%esp
  800052:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800058:	50                   	push   %eax
  800059:	68 00 13 80 00       	push   $0x801300
  80005e:	e8 cb 07 00 00       	call   80082e <readline>
  800063:	83 c4 10             	add    $0x10,%esp
	i1 = strtol(buff1, NULL, 10);
  800066:	83 ec 04             	sub    $0x4,%esp
  800069:	6a 0a                	push   $0xa
  80006b:	6a 00                	push   $0x0
  80006d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800073:	50                   	push   %eax
  800074:	e8 44 0c 00 00       	call   800cbd <strtol>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	readline("Please enter second number :", buff2);
  80007f:	83 ec 08             	sub    $0x8,%esp
  800082:	8d 85 f0 fd ff ff    	lea    -0x210(%ebp),%eax
  800088:	50                   	push   %eax
  800089:	68 1c 13 80 00       	push   $0x80131c
  80008e:	e8 9b 07 00 00       	call   80082e <readline>
  800093:	83 c4 10             	add    $0x10,%esp
	
	i2 = strtol(buff2, NULL, 10);
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	6a 0a                	push   $0xa
  80009b:	6a 00                	push   $0x0
  80009d:	8d 85 f0 fd ff ff    	lea    -0x210(%ebp),%eax
  8000a3:	50                   	push   %eax
  8000a4:	e8 14 0c 00 00       	call   800cbd <strtol>
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	89 45 f0             	mov    %eax,-0x10(%ebp)

	cprintf("number 1 + number 2 = %d\n",i1+i2);
  8000af:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8000b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000b5:	01 d0                	add    %edx,%eax
  8000b7:	83 ec 08             	sub    $0x8,%esp
  8000ba:	50                   	push   %eax
  8000bb:	68 39 13 80 00       	push   $0x801339
  8000c0:	e8 1e 01 00 00       	call   8001e3 <cprintf>
  8000c5:	83 c4 10             	add    $0x10,%esp
	return;	
  8000c8:	90                   	nop
}
  8000c9:	c9                   	leave  
  8000ca:	c3                   	ret    

008000cb <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	83 ec 08             	sub    $0x8,%esp
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = envs;
  8000d1:	c7 05 04 20 80 00 00 	movl   $0xeec00000,0x802004
  8000d8:	00 c0 ee 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000db:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000df:	7e 0a                	jle    8000eb <libmain+0x20>
		binaryname = argv[0];
  8000e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e4:	8b 00                	mov    (%eax),%eax
  8000e6:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	_main(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	ff 75 0c             	pushl  0xc(%ebp)
  8000f1:	ff 75 08             	pushl  0x8(%ebp)
  8000f4:	e8 3f ff ff ff       	call   800038 <_main>
  8000f9:	83 c4 10             	add    $0x10,%esp

	// exit gracefully
	//exit();
	sleep();
  8000fc:	e8 19 00 00 00       	call   80011a <sleep>
}
  800101:	90                   	nop
  800102:	c9                   	leave  
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	sys_env_destroy(0);	
  80010a:	83 ec 0c             	sub    $0xc,%esp
  80010d:	6a 00                	push   $0x0
  80010f:	e8 24 0e 00 00       	call   800f38 <sys_env_destroy>
  800114:	83 c4 10             	add    $0x10,%esp
}
  800117:	90                   	nop
  800118:	c9                   	leave  
  800119:	c3                   	ret    

0080011a <sleep>:

void
sleep(void)
{	
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	83 ec 08             	sub    $0x8,%esp
	sys_env_sleep();
  800120:	e8 47 0e 00 00       	call   800f6c <sys_env_sleep>
}
  800125:	90                   	nop
  800126:	c9                   	leave  
  800127:	c3                   	ret    

00800128 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 08             	sub    $0x8,%esp
	b->buf[b->idx++] = ch;
  80012e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800131:	8b 00                	mov    (%eax),%eax
  800133:	8d 48 01             	lea    0x1(%eax),%ecx
  800136:	8b 55 0c             	mov    0xc(%ebp),%edx
  800139:	89 0a                	mov    %ecx,(%edx)
  80013b:	8b 55 08             	mov    0x8(%ebp),%edx
  80013e:	88 d1                	mov    %dl,%cl
  800140:	8b 55 0c             	mov    0xc(%ebp),%edx
  800143:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800147:	8b 45 0c             	mov    0xc(%ebp),%eax
  80014a:	8b 00                	mov    (%eax),%eax
  80014c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800151:	75 23                	jne    800176 <putch+0x4e>
		sys_cputs(b->buf, b->idx);
  800153:	8b 45 0c             	mov    0xc(%ebp),%eax
  800156:	8b 00                	mov    (%eax),%eax
  800158:	89 c2                	mov    %eax,%edx
  80015a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015d:	83 c0 08             	add    $0x8,%eax
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	52                   	push   %edx
  800164:	50                   	push   %eax
  800165:	e8 98 0d 00 00       	call   800f02 <sys_cputs>
  80016a:	83 c4 10             	add    $0x10,%esp
		b->idx = 0;
  80016d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800170:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800176:	8b 45 0c             	mov    0xc(%ebp),%eax
  800179:	8b 40 04             	mov    0x4(%eax),%eax
  80017c:	8d 50 01             	lea    0x1(%eax),%edx
  80017f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800182:	89 50 04             	mov    %edx,0x4(%eax)
}
  800185:	90                   	nop
  800186:	c9                   	leave  
  800187:	c3                   	ret    

00800188 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800191:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800198:	00 00 00 
	b.cnt = 0;
  80019b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a5:	ff 75 0c             	pushl  0xc(%ebp)
  8001a8:	ff 75 08             	pushl  0x8(%ebp)
  8001ab:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b1:	50                   	push   %eax
  8001b2:	68 28 01 80 00       	push   $0x800128
  8001b7:	e8 ca 01 00 00       	call   800386 <vprintfmt>
  8001bc:	83 c4 10             	add    $0x10,%esp
	sys_cputs(b.buf, b.idx);
  8001bf:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001c5:	83 ec 08             	sub    $0x8,%esp
  8001c8:	50                   	push   %eax
  8001c9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cf:	83 c0 08             	add    $0x8,%eax
  8001d2:	50                   	push   %eax
  8001d3:	e8 2a 0d 00 00       	call   800f02 <sys_cputs>
  8001d8:	83 c4 10             	add    $0x10,%esp

	return b.cnt;
  8001db:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8001e1:	c9                   	leave  
  8001e2:	c3                   	ret    

008001e3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001e9:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  8001ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f2:	83 ec 08             	sub    $0x8,%esp
  8001f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8001f8:	50                   	push   %eax
  8001f9:	e8 8a ff ff ff       	call   800188 <vcprintf>
  8001fe:	83 c4 10             	add    $0x10,%esp
  800201:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
  800204:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	53                   	push   %ebx
  80020d:	83 ec 14             	sub    $0x14,%esp
  800210:	8b 45 10             	mov    0x10(%ebp),%eax
  800213:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800216:	8b 45 14             	mov    0x14(%ebp),%eax
  800219:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021c:	8b 45 18             	mov    0x18(%ebp),%eax
  80021f:	ba 00 00 00 00       	mov    $0x0,%edx
  800224:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800227:	77 55                	ja     80027e <printnum+0x75>
  800229:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80022c:	72 05                	jb     800233 <printnum+0x2a>
  80022e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800231:	77 4b                	ja     80027e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800233:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800236:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800239:	8b 45 18             	mov    0x18(%ebp),%eax
  80023c:	ba 00 00 00 00       	mov    $0x0,%edx
  800241:	52                   	push   %edx
  800242:	50                   	push   %eax
  800243:	ff 75 f4             	pushl  -0xc(%ebp)
  800246:	ff 75 f0             	pushl  -0x10(%ebp)
  800249:	e8 42 0e 00 00       	call   801090 <__udivdi3>
  80024e:	83 c4 10             	add    $0x10,%esp
  800251:	83 ec 04             	sub    $0x4,%esp
  800254:	ff 75 20             	pushl  0x20(%ebp)
  800257:	53                   	push   %ebx
  800258:	ff 75 18             	pushl  0x18(%ebp)
  80025b:	52                   	push   %edx
  80025c:	50                   	push   %eax
  80025d:	ff 75 0c             	pushl  0xc(%ebp)
  800260:	ff 75 08             	pushl  0x8(%ebp)
  800263:	e8 a1 ff ff ff       	call   800209 <printnum>
  800268:	83 c4 20             	add    $0x20,%esp
  80026b:	eb 1a                	jmp    800287 <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026d:	83 ec 08             	sub    $0x8,%esp
  800270:	ff 75 0c             	pushl  0xc(%ebp)
  800273:	ff 75 20             	pushl  0x20(%ebp)
  800276:	8b 45 08             	mov    0x8(%ebp),%eax
  800279:	ff d0                	call   *%eax
  80027b:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027e:	ff 4d 1c             	decl   0x1c(%ebp)
  800281:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800285:	7f e6                	jg     80026d <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800287:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80028a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800292:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800295:	53                   	push   %ebx
  800296:	51                   	push   %ecx
  800297:	52                   	push   %edx
  800298:	50                   	push   %eax
  800299:	e8 02 0f 00 00       	call   8011a0 <__umoddi3>
  80029e:	83 c4 10             	add    $0x10,%esp
  8002a1:	05 20 14 80 00       	add    $0x801420,%eax
  8002a6:	8a 00                	mov    (%eax),%al
  8002a8:	0f be c0             	movsbl %al,%eax
  8002ab:	83 ec 08             	sub    $0x8,%esp
  8002ae:	ff 75 0c             	pushl  0xc(%ebp)
  8002b1:	50                   	push   %eax
  8002b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b5:	ff d0                	call   *%eax
  8002b7:	83 c4 10             	add    $0x10,%esp
}
  8002ba:	90                   	nop
  8002bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002be:	c9                   	leave  
  8002bf:	c3                   	ret    

008002c0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c3:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002c7:	7e 1c                	jle    8002e5 <getuint+0x25>
		return va_arg(*ap, unsigned long long);
  8002c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cc:	8b 00                	mov    (%eax),%eax
  8002ce:	8d 50 08             	lea    0x8(%eax),%edx
  8002d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d4:	89 10                	mov    %edx,(%eax)
  8002d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d9:	8b 00                	mov    (%eax),%eax
  8002db:	83 e8 08             	sub    $0x8,%eax
  8002de:	8b 50 04             	mov    0x4(%eax),%edx
  8002e1:	8b 00                	mov    (%eax),%eax
  8002e3:	eb 40                	jmp    800325 <getuint+0x65>
	else if (lflag)
  8002e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002e9:	74 1e                	je     800309 <getuint+0x49>
		return va_arg(*ap, unsigned long);
  8002eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ee:	8b 00                	mov    (%eax),%eax
  8002f0:	8d 50 04             	lea    0x4(%eax),%edx
  8002f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f6:	89 10                	mov    %edx,(%eax)
  8002f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fb:	8b 00                	mov    (%eax),%eax
  8002fd:	83 e8 04             	sub    $0x4,%eax
  800300:	8b 00                	mov    (%eax),%eax
  800302:	ba 00 00 00 00       	mov    $0x0,%edx
  800307:	eb 1c                	jmp    800325 <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
  800309:	8b 45 08             	mov    0x8(%ebp),%eax
  80030c:	8b 00                	mov    (%eax),%eax
  80030e:	8d 50 04             	lea    0x4(%eax),%edx
  800311:	8b 45 08             	mov    0x8(%ebp),%eax
  800314:	89 10                	mov    %edx,(%eax)
  800316:	8b 45 08             	mov    0x8(%ebp),%eax
  800319:	8b 00                	mov    (%eax),%eax
  80031b:	83 e8 04             	sub    $0x4,%eax
  80031e:	8b 00                	mov    (%eax),%eax
  800320:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800325:	5d                   	pop    %ebp
  800326:	c3                   	ret    

00800327 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80032a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80032e:	7e 1c                	jle    80034c <getint+0x25>
		return va_arg(*ap, long long);
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	8b 00                	mov    (%eax),%eax
  800335:	8d 50 08             	lea    0x8(%eax),%edx
  800338:	8b 45 08             	mov    0x8(%ebp),%eax
  80033b:	89 10                	mov    %edx,(%eax)
  80033d:	8b 45 08             	mov    0x8(%ebp),%eax
  800340:	8b 00                	mov    (%eax),%eax
  800342:	83 e8 08             	sub    $0x8,%eax
  800345:	8b 50 04             	mov    0x4(%eax),%edx
  800348:	8b 00                	mov    (%eax),%eax
  80034a:	eb 38                	jmp    800384 <getint+0x5d>
	else if (lflag)
  80034c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800350:	74 1a                	je     80036c <getint+0x45>
		return va_arg(*ap, long);
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	8b 00                	mov    (%eax),%eax
  800357:	8d 50 04             	lea    0x4(%eax),%edx
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	89 10                	mov    %edx,(%eax)
  80035f:	8b 45 08             	mov    0x8(%ebp),%eax
  800362:	8b 00                	mov    (%eax),%eax
  800364:	83 e8 04             	sub    $0x4,%eax
  800367:	8b 00                	mov    (%eax),%eax
  800369:	99                   	cltd   
  80036a:	eb 18                	jmp    800384 <getint+0x5d>
	else
		return va_arg(*ap, int);
  80036c:	8b 45 08             	mov    0x8(%ebp),%eax
  80036f:	8b 00                	mov    (%eax),%eax
  800371:	8d 50 04             	lea    0x4(%eax),%edx
  800374:	8b 45 08             	mov    0x8(%ebp),%eax
  800377:	89 10                	mov    %edx,(%eax)
  800379:	8b 45 08             	mov    0x8(%ebp),%eax
  80037c:	8b 00                	mov    (%eax),%eax
  80037e:	83 e8 04             	sub    $0x4,%eax
  800381:	8b 00                	mov    (%eax),%eax
  800383:	99                   	cltd   
}
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
  80038b:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038e:	eb 17                	jmp    8003a7 <vprintfmt+0x21>
			if (ch == '\0')
  800390:	85 db                	test   %ebx,%ebx
  800392:	0f 84 af 03 00 00    	je     800747 <vprintfmt+0x3c1>
				return;
			putch(ch, putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	ff 75 0c             	pushl  0xc(%ebp)
  80039e:	53                   	push   %ebx
  80039f:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a2:	ff d0                	call   *%eax
  8003a4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003aa:	8d 50 01             	lea    0x1(%eax),%edx
  8003ad:	89 55 10             	mov    %edx,0x10(%ebp)
  8003b0:	8a 00                	mov    (%eax),%al
  8003b2:	0f b6 d8             	movzbl %al,%ebx
  8003b5:	83 fb 25             	cmp    $0x25,%ebx
  8003b8:	75 d6                	jne    800390 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8003ba:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8003be:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8003c5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003cc:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8003d3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 45 10             	mov    0x10(%ebp),%eax
  8003dd:	8d 50 01             	lea    0x1(%eax),%edx
  8003e0:	89 55 10             	mov    %edx,0x10(%ebp)
  8003e3:	8a 00                	mov    (%eax),%al
  8003e5:	0f b6 d8             	movzbl %al,%ebx
  8003e8:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8003eb:	83 f8 55             	cmp    $0x55,%eax
  8003ee:	0f 87 2b 03 00 00    	ja     80071f <vprintfmt+0x399>
  8003f4:	8b 04 85 44 14 80 00 	mov    0x801444(,%eax,4),%eax
  8003fb:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8003fd:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800401:	eb d7                	jmp    8003da <vprintfmt+0x54>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800403:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800407:	eb d1                	jmp    8003da <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800409:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800410:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800413:	89 d0                	mov    %edx,%eax
  800415:	c1 e0 02             	shl    $0x2,%eax
  800418:	01 d0                	add    %edx,%eax
  80041a:	01 c0                	add    %eax,%eax
  80041c:	01 d8                	add    %ebx,%eax
  80041e:	83 e8 30             	sub    $0x30,%eax
  800421:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800424:	8b 45 10             	mov    0x10(%ebp),%eax
  800427:	8a 00                	mov    (%eax),%al
  800429:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80042c:	83 fb 2f             	cmp    $0x2f,%ebx
  80042f:	7e 3e                	jle    80046f <vprintfmt+0xe9>
  800431:	83 fb 39             	cmp    $0x39,%ebx
  800434:	7f 39                	jg     80046f <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800436:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800439:	eb d5                	jmp    800410 <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80043b:	8b 45 14             	mov    0x14(%ebp),%eax
  80043e:	83 c0 04             	add    $0x4,%eax
  800441:	89 45 14             	mov    %eax,0x14(%ebp)
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	83 e8 04             	sub    $0x4,%eax
  80044a:	8b 00                	mov    (%eax),%eax
  80044c:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80044f:	eb 1f                	jmp    800470 <vprintfmt+0xea>

		case '.':
			if (width < 0)
  800451:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800455:	79 83                	jns    8003da <vprintfmt+0x54>
				width = 0;
  800457:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80045e:	e9 77 ff ff ff       	jmp    8003da <vprintfmt+0x54>

		case '#':
			altflag = 1;
  800463:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80046a:	e9 6b ff ff ff       	jmp    8003da <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
  80046f:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800470:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800474:	0f 89 60 ff ff ff    	jns    8003da <vprintfmt+0x54>
				width = precision, precision = -1;
  80047a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80047d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800480:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800487:	e9 4e ff ff ff       	jmp    8003da <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048c:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
  80048f:	e9 46 ff ff ff       	jmp    8003da <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	83 c0 04             	add    $0x4,%eax
  80049a:	89 45 14             	mov    %eax,0x14(%ebp)
  80049d:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a0:	83 e8 04             	sub    $0x4,%eax
  8004a3:	8b 00                	mov    (%eax),%eax
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	ff 75 0c             	pushl  0xc(%ebp)
  8004ab:	50                   	push   %eax
  8004ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8004af:	ff d0                	call   *%eax
  8004b1:	83 c4 10             	add    $0x10,%esp
			break;
  8004b4:	e9 89 02 00 00       	jmp    800742 <vprintfmt+0x3bc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bc:	83 c0 04             	add    $0x4,%eax
  8004bf:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c5:	83 e8 04             	sub    $0x4,%eax
  8004c8:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8004ca:	85 db                	test   %ebx,%ebx
  8004cc:	79 02                	jns    8004d0 <vprintfmt+0x14a>
				err = -err;
  8004ce:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8004d0:	83 fb 07             	cmp    $0x7,%ebx
  8004d3:	7f 0b                	jg     8004e0 <vprintfmt+0x15a>
  8004d5:	8b 34 9d 00 14 80 00 	mov    0x801400(,%ebx,4),%esi
  8004dc:	85 f6                	test   %esi,%esi
  8004de:	75 19                	jne    8004f9 <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  8004e0:	53                   	push   %ebx
  8004e1:	68 31 14 80 00       	push   $0x801431
  8004e6:	ff 75 0c             	pushl  0xc(%ebp)
  8004e9:	ff 75 08             	pushl  0x8(%ebp)
  8004ec:	e8 5e 02 00 00       	call   80074f <printfmt>
  8004f1:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8004f4:	e9 49 02 00 00       	jmp    800742 <vprintfmt+0x3bc>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004f9:	56                   	push   %esi
  8004fa:	68 3a 14 80 00       	push   $0x80143a
  8004ff:	ff 75 0c             	pushl  0xc(%ebp)
  800502:	ff 75 08             	pushl  0x8(%ebp)
  800505:	e8 45 02 00 00       	call   80074f <printfmt>
  80050a:	83 c4 10             	add    $0x10,%esp
			break;
  80050d:	e9 30 02 00 00       	jmp    800742 <vprintfmt+0x3bc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	83 c0 04             	add    $0x4,%eax
  800518:	89 45 14             	mov    %eax,0x14(%ebp)
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	83 e8 04             	sub    $0x4,%eax
  800521:	8b 30                	mov    (%eax),%esi
  800523:	85 f6                	test   %esi,%esi
  800525:	75 05                	jne    80052c <vprintfmt+0x1a6>
				p = "(null)";
  800527:	be 3d 14 80 00       	mov    $0x80143d,%esi
			if (width > 0 && padc != '-')
  80052c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800530:	7e 6d                	jle    80059f <vprintfmt+0x219>
  800532:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800536:	74 67                	je     80059f <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
  800538:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	50                   	push   %eax
  80053f:	56                   	push   %esi
  800540:	e8 3b 04 00 00       	call   800980 <strnlen>
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80054b:	eb 16                	jmp    800563 <vprintfmt+0x1dd>
					putch(padc, putdat);
  80054d:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800551:	83 ec 08             	sub    $0x8,%esp
  800554:	ff 75 0c             	pushl  0xc(%ebp)
  800557:	50                   	push   %eax
  800558:	8b 45 08             	mov    0x8(%ebp),%eax
  80055b:	ff d0                	call   *%eax
  80055d:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800560:	ff 4d e4             	decl   -0x1c(%ebp)
  800563:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800567:	7f e4                	jg     80054d <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800569:	eb 34                	jmp    80059f <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
  80056b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80056f:	74 1c                	je     80058d <vprintfmt+0x207>
  800571:	83 fb 1f             	cmp    $0x1f,%ebx
  800574:	7e 05                	jle    80057b <vprintfmt+0x1f5>
  800576:	83 fb 7e             	cmp    $0x7e,%ebx
  800579:	7e 12                	jle    80058d <vprintfmt+0x207>
					putch('?', putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	ff 75 0c             	pushl  0xc(%ebp)
  800581:	6a 3f                	push   $0x3f
  800583:	8b 45 08             	mov    0x8(%ebp),%eax
  800586:	ff d0                	call   *%eax
  800588:	83 c4 10             	add    $0x10,%esp
  80058b:	eb 0f                	jmp    80059c <vprintfmt+0x216>
				else
					putch(ch, putdat);
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	ff 75 0c             	pushl  0xc(%ebp)
  800593:	53                   	push   %ebx
  800594:	8b 45 08             	mov    0x8(%ebp),%eax
  800597:	ff d0                	call   *%eax
  800599:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059c:	ff 4d e4             	decl   -0x1c(%ebp)
  80059f:	89 f0                	mov    %esi,%eax
  8005a1:	8d 70 01             	lea    0x1(%eax),%esi
  8005a4:	8a 00                	mov    (%eax),%al
  8005a6:	0f be d8             	movsbl %al,%ebx
  8005a9:	85 db                	test   %ebx,%ebx
  8005ab:	74 24                	je     8005d1 <vprintfmt+0x24b>
  8005ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b1:	78 b8                	js     80056b <vprintfmt+0x1e5>
  8005b3:	ff 4d e0             	decl   -0x20(%ebp)
  8005b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ba:	79 af                	jns    80056b <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005bc:	eb 13                	jmp    8005d1 <vprintfmt+0x24b>
				putch(' ', putdat);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	ff 75 0c             	pushl  0xc(%ebp)
  8005c4:	6a 20                	push   $0x20
  8005c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c9:	ff d0                	call   *%eax
  8005cb:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ce:	ff 4d e4             	decl   -0x1c(%ebp)
  8005d1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d5:	7f e7                	jg     8005be <vprintfmt+0x238>
				putch(' ', putdat);
			break;
  8005d7:	e9 66 01 00 00       	jmp    800742 <vprintfmt+0x3bc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005dc:	83 ec 08             	sub    $0x8,%esp
  8005df:	ff 75 e8             	pushl  -0x18(%ebp)
  8005e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e5:	50                   	push   %eax
  8005e6:	e8 3c fd ff ff       	call   800327 <getint>
  8005eb:	83 c4 10             	add    $0x10,%esp
  8005ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005f1:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8005f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005fa:	85 d2                	test   %edx,%edx
  8005fc:	79 23                	jns    800621 <vprintfmt+0x29b>
				putch('-', putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	ff 75 0c             	pushl  0xc(%ebp)
  800604:	6a 2d                	push   $0x2d
  800606:	8b 45 08             	mov    0x8(%ebp),%eax
  800609:	ff d0                	call   *%eax
  80060b:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
  80060e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800611:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800614:	f7 d8                	neg    %eax
  800616:	83 d2 00             	adc    $0x0,%edx
  800619:	f7 da                	neg    %edx
  80061b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80061e:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800621:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800628:	e9 bc 00 00 00       	jmp    8006e9 <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	ff 75 e8             	pushl  -0x18(%ebp)
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	50                   	push   %eax
  800637:	e8 84 fc ff ff       	call   8002c0 <getuint>
  80063c:	83 c4 10             	add    $0x10,%esp
  80063f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800642:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800645:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80064c:	e9 98 00 00 00       	jmp    8006e9 <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	ff 75 0c             	pushl  0xc(%ebp)
  800657:	6a 58                	push   $0x58
  800659:	8b 45 08             	mov    0x8(%ebp),%eax
  80065c:	ff d0                	call   *%eax
  80065e:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	ff 75 0c             	pushl  0xc(%ebp)
  800667:	6a 58                	push   $0x58
  800669:	8b 45 08             	mov    0x8(%ebp),%eax
  80066c:	ff d0                	call   *%eax
  80066e:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800671:	83 ec 08             	sub    $0x8,%esp
  800674:	ff 75 0c             	pushl  0xc(%ebp)
  800677:	6a 58                	push   $0x58
  800679:	8b 45 08             	mov    0x8(%ebp),%eax
  80067c:	ff d0                	call   *%eax
  80067e:	83 c4 10             	add    $0x10,%esp
			break;
  800681:	e9 bc 00 00 00       	jmp    800742 <vprintfmt+0x3bc>

		// pointer
		case 'p':
			putch('0', putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	ff 75 0c             	pushl  0xc(%ebp)
  80068c:	6a 30                	push   $0x30
  80068e:	8b 45 08             	mov    0x8(%ebp),%eax
  800691:	ff d0                	call   *%eax
  800693:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	ff 75 0c             	pushl  0xc(%ebp)
  80069c:	6a 78                	push   $0x78
  80069e:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a1:	ff d0                	call   *%eax
  8006a3:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	83 c0 04             	add    $0x4,%eax
  8006ac:	89 45 14             	mov    %eax,0x14(%ebp)
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	83 e8 04             	sub    $0x4,%eax
  8006b5:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
  8006c1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8006c8:	eb 1f                	jmp    8006e9 <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ca:	83 ec 08             	sub    $0x8,%esp
  8006cd:	ff 75 e8             	pushl  -0x18(%ebp)
  8006d0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d3:	50                   	push   %eax
  8006d4:	e8 e7 fb ff ff       	call   8002c0 <getuint>
  8006d9:	83 c4 10             	add    $0x10,%esp
  8006dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006df:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8006e2:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e9:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8006ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f0:	83 ec 04             	sub    $0x4,%esp
  8006f3:	52                   	push   %edx
  8006f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006f7:	50                   	push   %eax
  8006f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8006fb:	ff 75 f0             	pushl  -0x10(%ebp)
  8006fe:	ff 75 0c             	pushl  0xc(%ebp)
  800701:	ff 75 08             	pushl  0x8(%ebp)
  800704:	e8 00 fb ff ff       	call   800209 <printnum>
  800709:	83 c4 20             	add    $0x20,%esp
			break;
  80070c:	eb 34                	jmp    800742 <vprintfmt+0x3bc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80070e:	83 ec 08             	sub    $0x8,%esp
  800711:	ff 75 0c             	pushl  0xc(%ebp)
  800714:	53                   	push   %ebx
  800715:	8b 45 08             	mov    0x8(%ebp),%eax
  800718:	ff d0                	call   *%eax
  80071a:	83 c4 10             	add    $0x10,%esp
			break;
  80071d:	eb 23                	jmp    800742 <vprintfmt+0x3bc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	ff 75 0c             	pushl  0xc(%ebp)
  800725:	6a 25                	push   $0x25
  800727:	8b 45 08             	mov    0x8(%ebp),%eax
  80072a:	ff d0                	call   *%eax
  80072c:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  80072f:	ff 4d 10             	decl   0x10(%ebp)
  800732:	eb 03                	jmp    800737 <vprintfmt+0x3b1>
  800734:	ff 4d 10             	decl   0x10(%ebp)
  800737:	8b 45 10             	mov    0x10(%ebp),%eax
  80073a:	48                   	dec    %eax
  80073b:	8a 00                	mov    (%eax),%al
  80073d:	3c 25                	cmp    $0x25,%al
  80073f:	75 f3                	jne    800734 <vprintfmt+0x3ae>
				/* do nothing */;
			break;
  800741:	90                   	nop
		}
	}
  800742:	e9 47 fc ff ff       	jmp    80038e <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
  800747:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800748:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80074b:	5b                   	pop    %ebx
  80074c:	5e                   	pop    %esi
  80074d:	5d                   	pop    %ebp
  80074e:	c3                   	ret    

0080074f <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800755:	8d 45 10             	lea    0x10(%ebp),%eax
  800758:	83 c0 04             	add    $0x4,%eax
  80075b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80075e:	8b 45 10             	mov    0x10(%ebp),%eax
  800761:	ff 75 f4             	pushl  -0xc(%ebp)
  800764:	50                   	push   %eax
  800765:	ff 75 0c             	pushl  0xc(%ebp)
  800768:	ff 75 08             	pushl  0x8(%ebp)
  80076b:	e8 16 fc ff ff       	call   800386 <vprintfmt>
  800770:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
  800773:	90                   	nop
  800774:	c9                   	leave  
  800775:	c3                   	ret    

00800776 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800779:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077c:	8b 40 08             	mov    0x8(%eax),%eax
  80077f:	8d 50 01             	lea    0x1(%eax),%edx
  800782:	8b 45 0c             	mov    0xc(%ebp),%eax
  800785:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800788:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078b:	8b 10                	mov    (%eax),%edx
  80078d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800790:	8b 40 04             	mov    0x4(%eax),%eax
  800793:	39 c2                	cmp    %eax,%edx
  800795:	73 12                	jae    8007a9 <sprintputch+0x33>
		*b->buf++ = ch;
  800797:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079a:	8b 00                	mov    (%eax),%eax
  80079c:	8d 48 01             	lea    0x1(%eax),%ecx
  80079f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a2:	89 0a                	mov    %ecx,(%edx)
  8007a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a7:	88 10                	mov    %dl,(%eax)
}
  8007a9:	90                   	nop
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007bb:	8d 50 ff             	lea    -0x1(%eax),%edx
  8007be:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c1:	01 d0                	add    %edx,%eax
  8007c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007cd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8007d1:	74 06                	je     8007d9 <vsnprintf+0x2d>
  8007d3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007d7:	7f 07                	jg     8007e0 <vsnprintf+0x34>
		return -E_INVAL;
  8007d9:	b8 03 00 00 00       	mov    $0x3,%eax
  8007de:	eb 20                	jmp    800800 <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007e0:	ff 75 14             	pushl  0x14(%ebp)
  8007e3:	ff 75 10             	pushl  0x10(%ebp)
  8007e6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e9:	50                   	push   %eax
  8007ea:	68 76 07 80 00       	push   $0x800776
  8007ef:	e8 92 fb ff ff       	call   800386 <vprintfmt>
  8007f4:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
  8007f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007fa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800800:	c9                   	leave  
  800801:	c3                   	ret    

00800802 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800808:	8d 45 10             	lea    0x10(%ebp),%eax
  80080b:	83 c0 04             	add    $0x4,%eax
  80080e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800811:	8b 45 10             	mov    0x10(%ebp),%eax
  800814:	ff 75 f4             	pushl  -0xc(%ebp)
  800817:	50                   	push   %eax
  800818:	ff 75 0c             	pushl  0xc(%ebp)
  80081b:	ff 75 08             	pushl  0x8(%ebp)
  80081e:	e8 89 ff ff ff       	call   8007ac <vsnprintf>
  800823:	83 c4 10             	add    $0x10,%esp
  800826:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
  800829:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  80082c:	c9                   	leave  
  80082d:	c3                   	ret    

0080082e <readline>:

#define BUFLEN 1024
//static char buf[BUFLEN];

void readline(const char *prompt, char* buf)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	83 ec 18             	sub    $0x18,%esp
	int i, c, echoing,mx;

	if (prompt != NULL)
  800834:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800838:	74 13                	je     80084d <readline+0x1f>
		cprintf("%s", prompt);
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	ff 75 08             	pushl  0x8(%ebp)
  800840:	68 9c 15 80 00       	push   $0x80159c
  800845:	e8 99 f9 ff ff       	call   8001e3 <cprintf>
  80084a:	83 c4 10             	add    $0x10,%esp


	i = mx = 0;
  80084d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800854:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800857:	89 45 f4             	mov    %eax,-0xc(%ebp)
	echoing = iscons(0);
  80085a:	83 ec 0c             	sub    $0xc,%esp
  80085d:	6a 00                	push   $0x0
  80085f:	e8 21 08 00 00       	call   801085 <iscons>
  800864:	83 c4 10             	add    $0x10,%esp
  800867:	89 45 ec             	mov    %eax,-0x14(%ebp)
	while (1) {
		c = getchar();
  80086a:	e8 09 08 00 00       	call   801078 <getchar>
  80086f:	89 45 e8             	mov    %eax,-0x18(%ebp)
		//cprintf("%d\n",c);
		if (c < 0) {
  800872:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  800876:	79 22                	jns    80089a <readline+0x6c>
			if (c != -E_EOF)
  800878:	83 7d e8 07          	cmpl   $0x7,-0x18(%ebp)
  80087c:	0f 84 d8 00 00 00    	je     80095a <readline+0x12c>
				cprintf("read error: %e\n", c);
  800882:	83 ec 08             	sub    $0x8,%esp
  800885:	ff 75 e8             	pushl  -0x18(%ebp)
  800888:	68 9f 15 80 00       	push   $0x80159f
  80088d:	e8 51 f9 ff ff       	call   8001e3 <cprintf>
  800892:	83 c4 10             	add    $0x10,%esp
			return;
  800895:	e9 c0 00 00 00       	jmp    80095a <readline+0x12c>
		} else if (c >= ' ' && i < BUFLEN-1) {
  80089a:	83 7d e8 1f          	cmpl   $0x1f,-0x18(%ebp)
  80089e:	7e 44                	jle    8008e4 <readline+0xb6>
  8008a0:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  8008a7:	7f 3b                	jg     8008e4 <readline+0xb6>
			if (echoing)
  8008a9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8008ad:	74 0e                	je     8008bd <readline+0x8f>
				cputchar(c);
  8008af:	83 ec 0c             	sub    $0xc,%esp
  8008b2:	ff 75 e8             	pushl  -0x18(%ebp)
  8008b5:	e8 9e 07 00 00       	call   801058 <cputchar>
  8008ba:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8008bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c0:	8d 50 01             	lea    0x1(%eax),%edx
  8008c3:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8008c6:	89 c2                	mov    %eax,%edx
  8008c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cb:	01 d0                	add    %edx,%eax
  8008cd:	8b 55 e8             	mov    -0x18(%ebp),%edx
  8008d0:	88 10                	mov    %dl,(%eax)
			cprintf("f1");
  8008d2:	83 ec 0c             	sub    $0xc,%esp
  8008d5:	68 af 15 80 00       	push   $0x8015af
  8008da:	e8 04 f9 ff ff       	call   8001e3 <cprintf>
  8008df:	83 c4 10             	add    $0x10,%esp
  8008e2:	eb 62                	jmp    800946 <readline+0x118>
		} else if (c == '\b' && i > 0) {
  8008e4:	83 7d e8 08          	cmpl   $0x8,-0x18(%ebp)
  8008e8:	75 2f                	jne    800919 <readline+0xeb>
  8008ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8008ee:	7e 29                	jle    800919 <readline+0xeb>
			if (echoing)
  8008f0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  8008f4:	74 0e                	je     800904 <readline+0xd6>
				cputchar(c);
  8008f6:	83 ec 0c             	sub    $0xc,%esp
  8008f9:	ff 75 e8             	pushl  -0x18(%ebp)
  8008fc:	e8 57 07 00 00       	call   801058 <cputchar>
  800901:	83 c4 10             	add    $0x10,%esp
			i--;
  800904:	ff 4d f4             	decl   -0xc(%ebp)
			cprintf("f2");
  800907:	83 ec 0c             	sub    $0xc,%esp
  80090a:	68 b2 15 80 00       	push   $0x8015b2
  80090f:	e8 cf f8 ff ff       	call   8001e3 <cprintf>
  800914:	83 c4 10             	add    $0x10,%esp
  800917:	eb 2d                	jmp    800946 <readline+0x118>
		} else if (c == '\n' || c == '\r') {
  800919:	83 7d e8 0a          	cmpl   $0xa,-0x18(%ebp)
  80091d:	74 06                	je     800925 <readline+0xf7>
  80091f:	83 7d e8 0d          	cmpl   $0xd,-0x18(%ebp)
  800923:	75 21                	jne    800946 <readline+0x118>
			if (echoing)
  800925:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800929:	74 0e                	je     800939 <readline+0x10b>
				cputchar(c);
  80092b:	83 ec 0c             	sub    $0xc,%esp
  80092e:	ff 75 e8             	pushl  -0x18(%ebp)
  800931:	e8 22 07 00 00       	call   801058 <cputchar>
  800936:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  800939:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80093c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093f:	01 d0                	add    %edx,%eax
  800941:	c6 00 00             	movb   $0x0,(%eax)
			return;
  800944:	eb 15                	jmp    80095b <readline+0x12d>
		}
		mx = (i>mx?i:mx);
  800946:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800949:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80094c:	39 d0                	cmp    %edx,%eax
  80094e:	7d 02                	jge    800952 <readline+0x124>
  800950:	89 d0                	mov    %edx,%eax
  800952:	89 45 f0             	mov    %eax,-0x10(%ebp)
	}
  800955:	e9 10 ff ff ff       	jmp    80086a <readline+0x3c>
		c = getchar();
		//cprintf("%d\n",c);
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return;
  80095a:	90                   	nop
			buf[i] = 0;
			return;
		}
		mx = (i>mx?i:mx);
	}
}
  80095b:	c9                   	leave  
  80095c:	c3                   	ret    

0080095d <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800963:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80096a:	eb 06                	jmp    800972 <strlen+0x15>
		n++;
  80096c:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80096f:	ff 45 08             	incl   0x8(%ebp)
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8a 00                	mov    (%eax),%al
  800977:	84 c0                	test   %al,%al
  800979:	75 f1                	jne    80096c <strlen+0xf>
		n++;
	return n;
  80097b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800986:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80098d:	eb 09                	jmp    800998 <strnlen+0x18>
		n++;
  80098f:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800992:	ff 45 08             	incl   0x8(%ebp)
  800995:	ff 4d 0c             	decl   0xc(%ebp)
  800998:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80099c:	74 09                	je     8009a7 <strnlen+0x27>
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	8a 00                	mov    (%eax),%al
  8009a3:	84 c0                	test   %al,%al
  8009a5:	75 e8                	jne    80098f <strnlen+0xf>
		n++;
	return n;
  8009a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009aa:	c9                   	leave  
  8009ab:	c3                   	ret    

008009ac <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  8009b8:	90                   	nop
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bc:	8d 50 01             	lea    0x1(%eax),%edx
  8009bf:	89 55 08             	mov    %edx,0x8(%ebp)
  8009c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009c8:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009cb:	8a 12                	mov    (%edx),%dl
  8009cd:	88 10                	mov    %dl,(%eax)
  8009cf:	8a 00                	mov    (%eax),%al
  8009d1:	84 c0                	test   %al,%al
  8009d3:	75 e4                	jne    8009b9 <strcpy+0xd>
		/* do nothing */;
	return ret;
  8009d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009d8:	c9                   	leave  
  8009d9:	c3                   	ret    

008009da <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8009e6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009ed:	eb 1f                	jmp    800a0e <strncpy+0x34>
		*dst++ = *src;
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	8d 50 01             	lea    0x1(%eax),%edx
  8009f5:	89 55 08             	mov    %edx,0x8(%ebp)
  8009f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fb:	8a 12                	mov    (%edx),%dl
  8009fd:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8009ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a02:	8a 00                	mov    (%eax),%al
  800a04:	84 c0                	test   %al,%al
  800a06:	74 03                	je     800a0b <strncpy+0x31>
			src++;
  800a08:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a0b:	ff 45 fc             	incl   -0x4(%ebp)
  800a0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a11:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a14:	72 d9                	jb     8009ef <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800a16:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800a19:	c9                   	leave  
  800a1a:	c3                   	ret    

00800a1b <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800a27:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a2b:	74 30                	je     800a5d <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
  800a2d:	eb 16                	jmp    800a45 <strlcpy+0x2a>
			*dst++ = *src++;
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	8d 50 01             	lea    0x1(%eax),%edx
  800a35:	89 55 08             	mov    %edx,0x8(%ebp)
  800a38:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3b:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a3e:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a41:	8a 12                	mov    (%edx),%dl
  800a43:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a45:	ff 4d 10             	decl   0x10(%ebp)
  800a48:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a4c:	74 09                	je     800a57 <strlcpy+0x3c>
  800a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a51:	8a 00                	mov    (%eax),%al
  800a53:	84 c0                	test   %al,%al
  800a55:	75 d8                	jne    800a2f <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a57:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a60:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a63:	29 c2                	sub    %eax,%edx
  800a65:	89 d0                	mov    %edx,%eax
}
  800a67:	c9                   	leave  
  800a68:	c3                   	ret    

00800a69 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a6c:	eb 06                	jmp    800a74 <strcmp+0xb>
		p++, q++;
  800a6e:	ff 45 08             	incl   0x8(%ebp)
  800a71:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
  800a77:	8a 00                	mov    (%eax),%al
  800a79:	84 c0                	test   %al,%al
  800a7b:	74 0e                	je     800a8b <strcmp+0x22>
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	8a 10                	mov    (%eax),%dl
  800a82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a85:	8a 00                	mov    (%eax),%al
  800a87:	38 c2                	cmp    %al,%dl
  800a89:	74 e3                	je     800a6e <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8e:	8a 00                	mov    (%eax),%al
  800a90:	0f b6 d0             	movzbl %al,%edx
  800a93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a96:	8a 00                	mov    (%eax),%al
  800a98:	0f b6 c0             	movzbl %al,%eax
  800a9b:	29 c2                	sub    %eax,%edx
  800a9d:	89 d0                	mov    %edx,%eax
}
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800aa4:	eb 09                	jmp    800aaf <strncmp+0xe>
		n--, p++, q++;
  800aa6:	ff 4d 10             	decl   0x10(%ebp)
  800aa9:	ff 45 08             	incl   0x8(%ebp)
  800aac:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
  800aaf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ab3:	74 17                	je     800acc <strncmp+0x2b>
  800ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab8:	8a 00                	mov    (%eax),%al
  800aba:	84 c0                	test   %al,%al
  800abc:	74 0e                	je     800acc <strncmp+0x2b>
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	8a 10                	mov    (%eax),%dl
  800ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac6:	8a 00                	mov    (%eax),%al
  800ac8:	38 c2                	cmp    %al,%dl
  800aca:	74 da                	je     800aa6 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800acc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ad0:	75 07                	jne    800ad9 <strncmp+0x38>
		return 0;
  800ad2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad7:	eb 14                	jmp    800aed <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	8a 00                	mov    (%eax),%al
  800ade:	0f b6 d0             	movzbl %al,%edx
  800ae1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae4:	8a 00                	mov    (%eax),%al
  800ae6:	0f b6 c0             	movzbl %al,%eax
  800ae9:	29 c2                	sub    %eax,%edx
  800aeb:	89 d0                	mov    %edx,%eax
}
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	83 ec 04             	sub    $0x4,%esp
  800af5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af8:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800afb:	eb 12                	jmp    800b0f <strchr+0x20>
		if (*s == c)
  800afd:	8b 45 08             	mov    0x8(%ebp),%eax
  800b00:	8a 00                	mov    (%eax),%al
  800b02:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b05:	75 05                	jne    800b0c <strchr+0x1d>
			return (char *) s;
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	eb 11                	jmp    800b1d <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b0c:	ff 45 08             	incl   0x8(%ebp)
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	8a 00                	mov    (%eax),%al
  800b14:	84 c0                	test   %al,%al
  800b16:	75 e5                	jne    800afd <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800b18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1d:	c9                   	leave  
  800b1e:	c3                   	ret    

00800b1f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	83 ec 04             	sub    $0x4,%esp
  800b25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b28:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b2b:	eb 0d                	jmp    800b3a <strfind+0x1b>
		if (*s == c)
  800b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b30:	8a 00                	mov    (%eax),%al
  800b32:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b35:	74 0e                	je     800b45 <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b37:	ff 45 08             	incl   0x8(%ebp)
  800b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3d:	8a 00                	mov    (%eax),%al
  800b3f:	84 c0                	test   %al,%al
  800b41:	75 ea                	jne    800b2d <strfind+0xe>
  800b43:	eb 01                	jmp    800b46 <strfind+0x27>
		if (*s == c)
			break;
  800b45:	90                   	nop
	return (char *) s;
  800b46:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b49:	c9                   	leave  
  800b4a:	c3                   	ret    

00800b4b <memset>:


void *
memset(void *v, int c, uint32 n)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
  800b51:	8b 45 08             	mov    0x8(%ebp),%eax
  800b54:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
  800b57:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5a:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
  800b5d:	eb 0e                	jmp    800b6d <memset+0x22>
		*p++ = c;
  800b5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b62:	8d 50 01             	lea    0x1(%eax),%edx
  800b65:	89 55 fc             	mov    %edx,-0x4(%ebp)
  800b68:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6b:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800b6d:	ff 4d f8             	decl   -0x8(%ebp)
  800b70:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  800b74:	79 e9                	jns    800b5f <memset+0x14>
		*p++ = c;

	return v;
  800b76:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b79:	c9                   	leave  
  800b7a:	c3                   	ret    

00800b7b <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b81:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b84:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800b87:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8a:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
  800b8d:	eb 16                	jmp    800ba5 <memcpy+0x2a>
		*d++ = *s++;
  800b8f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800b92:	8d 50 01             	lea    0x1(%eax),%edx
  800b95:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800b98:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800b9b:	8d 4a 01             	lea    0x1(%edx),%ecx
  800b9e:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800ba1:	8a 12                	mov    (%edx),%dl
  800ba3:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800ba5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba8:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bab:	89 55 10             	mov    %edx,0x10(%ebp)
  800bae:	85 c0                	test   %eax,%eax
  800bb0:	75 dd                	jne    800b8f <memcpy+0x14>
		*d++ = *s++;

	return dst;
  800bb2:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bb5:	c9                   	leave  
  800bb6:	c3                   	ret    

00800bb7 <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;
	
	s = src;
  800bbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc6:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
  800bc9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bcc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800bcf:	73 50                	jae    800c21 <memmove+0x6a>
  800bd1:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800bd4:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd7:	01 d0                	add    %edx,%eax
  800bd9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800bdc:	76 43                	jbe    800c21 <memmove+0x6a>
		s += n;
  800bde:	8b 45 10             	mov    0x10(%ebp),%eax
  800be1:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
  800be4:	8b 45 10             	mov    0x10(%ebp),%eax
  800be7:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
  800bea:	eb 10                	jmp    800bfc <memmove+0x45>
			*--d = *--s;
  800bec:	ff 4d f8             	decl   -0x8(%ebp)
  800bef:	ff 4d fc             	decl   -0x4(%ebp)
  800bf2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bf5:	8a 10                	mov    (%eax),%dl
  800bf7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bfa:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800bfc:	8b 45 10             	mov    0x10(%ebp),%eax
  800bff:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c02:	89 55 10             	mov    %edx,0x10(%ebp)
  800c05:	85 c0                	test   %eax,%eax
  800c07:	75 e3                	jne    800bec <memmove+0x35>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c09:	eb 23                	jmp    800c2e <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800c0b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c0e:	8d 50 01             	lea    0x1(%eax),%edx
  800c11:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800c14:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800c17:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c1a:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800c1d:	8a 12                	mov    (%edx),%dl
  800c1f:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800c21:	8b 45 10             	mov    0x10(%ebp),%eax
  800c24:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c27:	89 55 10             	mov    %edx,0x10(%ebp)
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	75 dd                	jne    800c0b <memmove+0x54>
			*d++ = *s++;

	return dst;
  800c2e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c31:	c9                   	leave  
  800c32:	c3                   	ret    

00800c33 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
  800c3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c42:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800c45:	eb 2a                	jmp    800c71 <memcmp+0x3e>
		if (*s1 != *s2)
  800c47:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c4a:	8a 10                	mov    (%eax),%dl
  800c4c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c4f:	8a 00                	mov    (%eax),%al
  800c51:	38 c2                	cmp    %al,%dl
  800c53:	74 16                	je     800c6b <memcmp+0x38>
			return (int) *s1 - (int) *s2;
  800c55:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c58:	8a 00                	mov    (%eax),%al
  800c5a:	0f b6 d0             	movzbl %al,%edx
  800c5d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c60:	8a 00                	mov    (%eax),%al
  800c62:	0f b6 c0             	movzbl %al,%eax
  800c65:	29 c2                	sub    %eax,%edx
  800c67:	89 d0                	mov    %edx,%eax
  800c69:	eb 18                	jmp    800c83 <memcmp+0x50>
		s1++, s2++;
  800c6b:	ff 45 fc             	incl   -0x4(%ebp)
  800c6e:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
  800c71:	8b 45 10             	mov    0x10(%ebp),%eax
  800c74:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c77:	89 55 10             	mov    %edx,0x10(%ebp)
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	75 c9                	jne    800c47 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c83:	c9                   	leave  
  800c84:	c3                   	ret    

00800c85 <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c91:	01 d0                	add    %edx,%eax
  800c93:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c96:	eb 15                	jmp    800cad <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c98:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9b:	8a 00                	mov    (%eax),%al
  800c9d:	0f b6 d0             	movzbl %al,%edx
  800ca0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca3:	0f b6 c0             	movzbl %al,%eax
  800ca6:	39 c2                	cmp    %eax,%edx
  800ca8:	74 0d                	je     800cb7 <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800caa:	ff 45 08             	incl   0x8(%ebp)
  800cad:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800cb3:	72 e3                	jb     800c98 <memfind+0x13>
  800cb5:	eb 01                	jmp    800cb8 <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
  800cb7:	90                   	nop
	return (void *) s;
  800cb8:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cbb:	c9                   	leave  
  800cbc:	c3                   	ret    

00800cbd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800cc3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800cca:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd1:	eb 03                	jmp    800cd6 <strtol+0x19>
		s++;
  800cd3:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd9:	8a 00                	mov    (%eax),%al
  800cdb:	3c 20                	cmp    $0x20,%al
  800cdd:	74 f4                	je     800cd3 <strtol+0x16>
  800cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce2:	8a 00                	mov    (%eax),%al
  800ce4:	3c 09                	cmp    $0x9,%al
  800ce6:	74 eb                	je     800cd3 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ceb:	8a 00                	mov    (%eax),%al
  800ced:	3c 2b                	cmp    $0x2b,%al
  800cef:	75 05                	jne    800cf6 <strtol+0x39>
		s++;
  800cf1:	ff 45 08             	incl   0x8(%ebp)
  800cf4:	eb 13                	jmp    800d09 <strtol+0x4c>
	else if (*s == '-')
  800cf6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf9:	8a 00                	mov    (%eax),%al
  800cfb:	3c 2d                	cmp    $0x2d,%al
  800cfd:	75 0a                	jne    800d09 <strtol+0x4c>
		s++, neg = 1;
  800cff:	ff 45 08             	incl   0x8(%ebp)
  800d02:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d09:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d0d:	74 06                	je     800d15 <strtol+0x58>
  800d0f:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d13:	75 20                	jne    800d35 <strtol+0x78>
  800d15:	8b 45 08             	mov    0x8(%ebp),%eax
  800d18:	8a 00                	mov    (%eax),%al
  800d1a:	3c 30                	cmp    $0x30,%al
  800d1c:	75 17                	jne    800d35 <strtol+0x78>
  800d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d21:	40                   	inc    %eax
  800d22:	8a 00                	mov    (%eax),%al
  800d24:	3c 78                	cmp    $0x78,%al
  800d26:	75 0d                	jne    800d35 <strtol+0x78>
		s += 2, base = 16;
  800d28:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d2c:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800d33:	eb 28                	jmp    800d5d <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
  800d35:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d39:	75 15                	jne    800d50 <strtol+0x93>
  800d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3e:	8a 00                	mov    (%eax),%al
  800d40:	3c 30                	cmp    $0x30,%al
  800d42:	75 0c                	jne    800d50 <strtol+0x93>
		s++, base = 8;
  800d44:	ff 45 08             	incl   0x8(%ebp)
  800d47:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d4e:	eb 0d                	jmp    800d5d <strtol+0xa0>
	else if (base == 0)
  800d50:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d54:	75 07                	jne    800d5d <strtol+0xa0>
		base = 10;
  800d56:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d60:	8a 00                	mov    (%eax),%al
  800d62:	3c 2f                	cmp    $0x2f,%al
  800d64:	7e 19                	jle    800d7f <strtol+0xc2>
  800d66:	8b 45 08             	mov    0x8(%ebp),%eax
  800d69:	8a 00                	mov    (%eax),%al
  800d6b:	3c 39                	cmp    $0x39,%al
  800d6d:	7f 10                	jg     800d7f <strtol+0xc2>
			dig = *s - '0';
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d72:	8a 00                	mov    (%eax),%al
  800d74:	0f be c0             	movsbl %al,%eax
  800d77:	83 e8 30             	sub    $0x30,%eax
  800d7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d7d:	eb 42                	jmp    800dc1 <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
  800d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d82:	8a 00                	mov    (%eax),%al
  800d84:	3c 60                	cmp    $0x60,%al
  800d86:	7e 19                	jle    800da1 <strtol+0xe4>
  800d88:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8b:	8a 00                	mov    (%eax),%al
  800d8d:	3c 7a                	cmp    $0x7a,%al
  800d8f:	7f 10                	jg     800da1 <strtol+0xe4>
			dig = *s - 'a' + 10;
  800d91:	8b 45 08             	mov    0x8(%ebp),%eax
  800d94:	8a 00                	mov    (%eax),%al
  800d96:	0f be c0             	movsbl %al,%eax
  800d99:	83 e8 57             	sub    $0x57,%eax
  800d9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d9f:	eb 20                	jmp    800dc1 <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
  800da1:	8b 45 08             	mov    0x8(%ebp),%eax
  800da4:	8a 00                	mov    (%eax),%al
  800da6:	3c 40                	cmp    $0x40,%al
  800da8:	7e 39                	jle    800de3 <strtol+0x126>
  800daa:	8b 45 08             	mov    0x8(%ebp),%eax
  800dad:	8a 00                	mov    (%eax),%al
  800daf:	3c 5a                	cmp    $0x5a,%al
  800db1:	7f 30                	jg     800de3 <strtol+0x126>
			dig = *s - 'A' + 10;
  800db3:	8b 45 08             	mov    0x8(%ebp),%eax
  800db6:	8a 00                	mov    (%eax),%al
  800db8:	0f be c0             	movsbl %al,%eax
  800dbb:	83 e8 37             	sub    $0x37,%eax
  800dbe:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800dc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dc4:	3b 45 10             	cmp    0x10(%ebp),%eax
  800dc7:	7d 19                	jge    800de2 <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
  800dc9:	ff 45 08             	incl   0x8(%ebp)
  800dcc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800dcf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800dd3:	89 c2                	mov    %eax,%edx
  800dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dd8:	01 d0                	add    %edx,%eax
  800dda:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800ddd:	e9 7b ff ff ff       	jmp    800d5d <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
  800de2:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800de3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800de7:	74 08                	je     800df1 <strtol+0x134>
		*endptr = (char *) s;
  800de9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dec:	8b 55 08             	mov    0x8(%ebp),%edx
  800def:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800df1:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800df5:	74 07                	je     800dfe <strtol+0x141>
  800df7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800dfa:	f7 d8                	neg    %eax
  800dfc:	eb 03                	jmp    800e01 <strtol+0x144>
  800dfe:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800e01:	c9                   	leave  
  800e02:	c3                   	ret    

00800e03 <strsplit>:

int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  800e06:	8b 45 14             	mov    0x14(%ebp),%eax
  800e09:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
  800e0f:	8b 45 14             	mov    0x14(%ebp),%eax
  800e12:	8b 00                	mov    (%eax),%eax
  800e14:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800e1b:	8b 45 10             	mov    0x10(%ebp),%eax
  800e1e:	01 d0                	add    %edx,%eax
  800e20:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800e26:	eb 0c                	jmp    800e34 <strsplit+0x31>
			*string++ = 0;
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2b:	8d 50 01             	lea    0x1(%eax),%edx
  800e2e:	89 55 08             	mov    %edx,0x8(%ebp)
  800e31:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800e34:	8b 45 08             	mov    0x8(%ebp),%eax
  800e37:	8a 00                	mov    (%eax),%al
  800e39:	84 c0                	test   %al,%al
  800e3b:	74 18                	je     800e55 <strsplit+0x52>
  800e3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e40:	8a 00                	mov    (%eax),%al
  800e42:	0f be c0             	movsbl %al,%eax
  800e45:	50                   	push   %eax
  800e46:	ff 75 0c             	pushl  0xc(%ebp)
  800e49:	e8 a1 fc ff ff       	call   800aef <strchr>
  800e4e:	83 c4 08             	add    $0x8,%esp
  800e51:	85 c0                	test   %eax,%eax
  800e53:	75 d3                	jne    800e28 <strsplit+0x25>
			*string++ = 0;
		
		//if the command string is finished, then break the loop
		if (*string == 0)
  800e55:	8b 45 08             	mov    0x8(%ebp),%eax
  800e58:	8a 00                	mov    (%eax),%al
  800e5a:	84 c0                	test   %al,%al
  800e5c:	74 5a                	je     800eb8 <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1) 
  800e5e:	8b 45 14             	mov    0x14(%ebp),%eax
  800e61:	8b 00                	mov    (%eax),%eax
  800e63:	83 f8 0f             	cmp    $0xf,%eax
  800e66:	75 07                	jne    800e6f <strsplit+0x6c>
		{
			return 0;
  800e68:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6d:	eb 66                	jmp    800ed5 <strsplit+0xd2>
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  800e6f:	8b 45 14             	mov    0x14(%ebp),%eax
  800e72:	8b 00                	mov    (%eax),%eax
  800e74:	8d 48 01             	lea    0x1(%eax),%ecx
  800e77:	8b 55 14             	mov    0x14(%ebp),%edx
  800e7a:	89 0a                	mov    %ecx,(%edx)
  800e7c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800e83:	8b 45 10             	mov    0x10(%ebp),%eax
  800e86:	01 c2                	add    %eax,%edx
  800e88:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8b:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
  800e8d:	eb 03                	jmp    800e92 <strsplit+0x8f>
			string++;
  800e8f:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
  800e92:	8b 45 08             	mov    0x8(%ebp),%eax
  800e95:	8a 00                	mov    (%eax),%al
  800e97:	84 c0                	test   %al,%al
  800e99:	74 8b                	je     800e26 <strsplit+0x23>
  800e9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9e:	8a 00                	mov    (%eax),%al
  800ea0:	0f be c0             	movsbl %al,%eax
  800ea3:	50                   	push   %eax
  800ea4:	ff 75 0c             	pushl  0xc(%ebp)
  800ea7:	e8 43 fc ff ff       	call   800aef <strchr>
  800eac:	83 c4 08             	add    $0x8,%esp
  800eaf:	85 c0                	test   %eax,%eax
  800eb1:	74 dc                	je     800e8f <strsplit+0x8c>
			string++;
	}
  800eb3:	e9 6e ff ff ff       	jmp    800e26 <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;
		
		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
  800eb8:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
  800eb9:	8b 45 14             	mov    0x14(%ebp),%eax
  800ebc:	8b 00                	mov    (%eax),%eax
  800ebe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800ec5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec8:	01 d0                	add    %edx,%eax
  800eca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
  800ed0:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800ed5:	c9                   	leave  
  800ed6:	c3                   	ret    

00800ed7 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline uint32
syscall(int num, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	57                   	push   %edi
  800edb:	56                   	push   %esi
  800edc:	53                   	push   %ebx
  800edd:	83 ec 10             	sub    $0x10,%esp
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ee9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800eec:	8b 7d 18             	mov    0x18(%ebp),%edi
  800eef:	8b 75 1c             	mov    0x1c(%ebp),%esi
  800ef2:	cd 30                	int    $0x30
  800ef4:	89 45 f0             	mov    %eax,-0x10(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	return ret;
  800ef7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800efa:	83 c4 10             	add    $0x10,%esp
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5f                   	pop    %edi
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    

00800f02 <sys_cputs>:

void
sys_cputs(const char *s, uint32 len)
{
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
	syscall(SYS_cputs, (uint32) s, len, 0, 0, 0);
  800f05:	8b 45 08             	mov    0x8(%ebp),%eax
  800f08:	6a 00                	push   $0x0
  800f0a:	6a 00                	push   $0x0
  800f0c:	6a 00                	push   $0x0
  800f0e:	ff 75 0c             	pushl  0xc(%ebp)
  800f11:	50                   	push   %eax
  800f12:	6a 00                	push   $0x0
  800f14:	e8 be ff ff ff       	call   800ed7 <syscall>
  800f19:	83 c4 18             	add    $0x18,%esp
}
  800f1c:	90                   	nop
  800f1d:	c9                   	leave  
  800f1e:	c3                   	ret    

00800f1f <sys_cgetc>:

int
sys_cgetc(void)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
  800f22:	6a 00                	push   $0x0
  800f24:	6a 00                	push   $0x0
  800f26:	6a 00                	push   $0x0
  800f28:	6a 00                	push   $0x0
  800f2a:	6a 00                	push   $0x0
  800f2c:	6a 01                	push   $0x1
  800f2e:	e8 a4 ff ff ff       	call   800ed7 <syscall>
  800f33:	83 c4 18             	add    $0x18,%esp
}
  800f36:	c9                   	leave  
  800f37:	c3                   	ret    

00800f38 <sys_env_destroy>:

int	sys_env_destroy(int32  envid)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
  800f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3e:	6a 00                	push   $0x0
  800f40:	6a 00                	push   $0x0
  800f42:	6a 00                	push   $0x0
  800f44:	6a 00                	push   $0x0
  800f46:	50                   	push   %eax
  800f47:	6a 03                	push   $0x3
  800f49:	e8 89 ff ff ff       	call   800ed7 <syscall>
  800f4e:	83 c4 18             	add    $0x18,%esp
}
  800f51:	c9                   	leave  
  800f52:	c3                   	ret    

00800f53 <sys_getenvid>:

int32 sys_getenvid(void)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
  800f56:	6a 00                	push   $0x0
  800f58:	6a 00                	push   $0x0
  800f5a:	6a 00                	push   $0x0
  800f5c:	6a 00                	push   $0x0
  800f5e:	6a 00                	push   $0x0
  800f60:	6a 02                	push   $0x2
  800f62:	e8 70 ff ff ff       	call   800ed7 <syscall>
  800f67:	83 c4 18             	add    $0x18,%esp
}
  800f6a:	c9                   	leave  
  800f6b:	c3                   	ret    

00800f6c <sys_env_sleep>:

void sys_env_sleep(void)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
	syscall(SYS_env_sleep, 0, 0, 0, 0, 0);
  800f6f:	6a 00                	push   $0x0
  800f71:	6a 00                	push   $0x0
  800f73:	6a 00                	push   $0x0
  800f75:	6a 00                	push   $0x0
  800f77:	6a 00                	push   $0x0
  800f79:	6a 04                	push   $0x4
  800f7b:	e8 57 ff ff ff       	call   800ed7 <syscall>
  800f80:	83 c4 18             	add    $0x18,%esp
}
  800f83:	90                   	nop
  800f84:	c9                   	leave  
  800f85:	c3                   	ret    

00800f86 <sys_allocate_page>:


int sys_allocate_page(void *va, int perm)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
  800f89:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8f:	6a 00                	push   $0x0
  800f91:	6a 00                	push   $0x0
  800f93:	6a 00                	push   $0x0
  800f95:	52                   	push   %edx
  800f96:	50                   	push   %eax
  800f97:	6a 05                	push   $0x5
  800f99:	e8 39 ff ff ff       	call   800ed7 <syscall>
  800f9e:	83 c4 18             	add    $0x18,%esp
}
  800fa1:	c9                   	leave  
  800fa2:	c3                   	ret    

00800fa3 <sys_get_page>:

int sys_get_page(void *va, int perm)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_page, (uint32) va, perm, 0 , 0, 0);
  800fa6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fac:	6a 00                	push   $0x0
  800fae:	6a 00                	push   $0x0
  800fb0:	6a 00                	push   $0x0
  800fb2:	52                   	push   %edx
  800fb3:	50                   	push   %eax
  800fb4:	6a 06                	push   $0x6
  800fb6:	e8 1c ff ff ff       	call   800ed7 <syscall>
  800fbb:	83 c4 18             	add    $0x18,%esp
}
  800fbe:	c9                   	leave  
  800fbf:	c3                   	ret    

00800fc0 <sys_map_frame>:
		
int sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	56                   	push   %esi
  800fc4:	53                   	push   %ebx
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
  800fc5:	8b 75 18             	mov    0x18(%ebp),%esi
  800fc8:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800fcb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fce:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd4:	56                   	push   %esi
  800fd5:	53                   	push   %ebx
  800fd6:	51                   	push   %ecx
  800fd7:	52                   	push   %edx
  800fd8:	50                   	push   %eax
  800fd9:	6a 07                	push   $0x7
  800fdb:	e8 f7 fe ff ff       	call   800ed7 <syscall>
  800fe0:	83 c4 18             	add    $0x18,%esp
}
  800fe3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fe6:	5b                   	pop    %ebx
  800fe7:	5e                   	pop    %esi
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    

00800fea <sys_unmap_frame>:

int sys_unmap_frame(int32 envid, void *va)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
  800fed:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ff0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff3:	6a 00                	push   $0x0
  800ff5:	6a 00                	push   $0x0
  800ff7:	6a 00                	push   $0x0
  800ff9:	52                   	push   %edx
  800ffa:	50                   	push   %eax
  800ffb:	6a 08                	push   $0x8
  800ffd:	e8 d5 fe ff ff       	call   800ed7 <syscall>
  801002:	83 c4 18             	add    $0x18,%esp
}
  801005:	c9                   	leave  
  801006:	c3                   	ret    

00801007 <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
  80100a:	6a 00                	push   $0x0
  80100c:	6a 00                	push   $0x0
  80100e:	6a 00                	push   $0x0
  801010:	ff 75 0c             	pushl  0xc(%ebp)
  801013:	ff 75 08             	pushl  0x8(%ebp)
  801016:	6a 09                	push   $0x9
  801018:	e8 ba fe ff ff       	call   800ed7 <syscall>
  80101d:	83 c4 18             	add    $0x18,%esp
}
  801020:	c9                   	leave  
  801021:	c3                   	ret    

00801022 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
  801025:	6a 00                	push   $0x0
  801027:	6a 00                	push   $0x0
  801029:	6a 00                	push   $0x0
  80102b:	6a 00                	push   $0x0
  80102d:	6a 00                	push   $0x0
  80102f:	6a 0a                	push   $0xa
  801031:	e8 a1 fe ff ff       	call   800ed7 <syscall>
  801036:	83 c4 18             	add    $0x18,%esp
}
  801039:	c9                   	leave  
  80103a:	c3                   	ret    

0080103b <sys_freeMem>:

void sys_freeMem(void* start_virtual_address, uint32 size)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
	syscall(SYS_freeMem, (uint32) start_virtual_address, size, 0, 0, 0);
  80103e:	8b 45 08             	mov    0x8(%ebp),%eax
  801041:	6a 00                	push   $0x0
  801043:	6a 00                	push   $0x0
  801045:	6a 00                	push   $0x0
  801047:	ff 75 0c             	pushl  0xc(%ebp)
  80104a:	50                   	push   %eax
  80104b:	6a 0b                	push   $0xb
  80104d:	e8 85 fe ff ff       	call   800ed7 <syscall>
  801052:	83 c4 18             	add    $0x18,%esp
	return;
  801055:	90                   	nop
}
  801056:	c9                   	leave  
  801057:	c3                   	ret    

00801058 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	83 ec 18             	sub    $0x18,%esp
	char c = ch;
  80105e:	8b 45 08             	mov    0x8(%ebp),%eax
  801061:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801064:	83 ec 08             	sub    $0x8,%esp
  801067:	6a 01                	push   $0x1
  801069:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80106c:	50                   	push   %eax
  80106d:	e8 90 fe ff ff       	call   800f02 <sys_cputs>
  801072:	83 c4 10             	add    $0x10,%esp
}
  801075:	90                   	nop
  801076:	c9                   	leave  
  801077:	c3                   	ret    

00801078 <getchar>:

int
getchar(void)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	83 ec 08             	sub    $0x8,%esp
	return sys_cgetc();
  80107e:	e8 9c fe ff ff       	call   800f1f <sys_cgetc>
}
  801083:	c9                   	leave  
  801084:	c3                   	ret    

00801085 <iscons>:


int iscons(int fdnum)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
  801088:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80108d:	5d                   	pop    %ebp
  80108e:	c3                   	ret    
  80108f:	90                   	nop

00801090 <__udivdi3>:
  801090:	55                   	push   %ebp
  801091:	57                   	push   %edi
  801092:	56                   	push   %esi
  801093:	53                   	push   %ebx
  801094:	83 ec 1c             	sub    $0x1c,%esp
  801097:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80109b:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  80109f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8010a3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010a7:	89 ca                	mov    %ecx,%edx
  8010a9:	89 f8                	mov    %edi,%eax
  8010ab:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8010af:	85 f6                	test   %esi,%esi
  8010b1:	75 2d                	jne    8010e0 <__udivdi3+0x50>
  8010b3:	39 cf                	cmp    %ecx,%edi
  8010b5:	77 65                	ja     80111c <__udivdi3+0x8c>
  8010b7:	89 fd                	mov    %edi,%ebp
  8010b9:	85 ff                	test   %edi,%edi
  8010bb:	75 0b                	jne    8010c8 <__udivdi3+0x38>
  8010bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8010c2:	31 d2                	xor    %edx,%edx
  8010c4:	f7 f7                	div    %edi
  8010c6:	89 c5                	mov    %eax,%ebp
  8010c8:	31 d2                	xor    %edx,%edx
  8010ca:	89 c8                	mov    %ecx,%eax
  8010cc:	f7 f5                	div    %ebp
  8010ce:	89 c1                	mov    %eax,%ecx
  8010d0:	89 d8                	mov    %ebx,%eax
  8010d2:	f7 f5                	div    %ebp
  8010d4:	89 cf                	mov    %ecx,%edi
  8010d6:	89 fa                	mov    %edi,%edx
  8010d8:	83 c4 1c             	add    $0x1c,%esp
  8010db:	5b                   	pop    %ebx
  8010dc:	5e                   	pop    %esi
  8010dd:	5f                   	pop    %edi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    
  8010e0:	39 ce                	cmp    %ecx,%esi
  8010e2:	77 28                	ja     80110c <__udivdi3+0x7c>
  8010e4:	0f bd fe             	bsr    %esi,%edi
  8010e7:	83 f7 1f             	xor    $0x1f,%edi
  8010ea:	75 40                	jne    80112c <__udivdi3+0x9c>
  8010ec:	39 ce                	cmp    %ecx,%esi
  8010ee:	72 0a                	jb     8010fa <__udivdi3+0x6a>
  8010f0:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8010f4:	0f 87 9e 00 00 00    	ja     801198 <__udivdi3+0x108>
  8010fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ff:	89 fa                	mov    %edi,%edx
  801101:	83 c4 1c             	add    $0x1c,%esp
  801104:	5b                   	pop    %ebx
  801105:	5e                   	pop    %esi
  801106:	5f                   	pop    %edi
  801107:	5d                   	pop    %ebp
  801108:	c3                   	ret    
  801109:	8d 76 00             	lea    0x0(%esi),%esi
  80110c:	31 ff                	xor    %edi,%edi
  80110e:	31 c0                	xor    %eax,%eax
  801110:	89 fa                	mov    %edi,%edx
  801112:	83 c4 1c             	add    $0x1c,%esp
  801115:	5b                   	pop    %ebx
  801116:	5e                   	pop    %esi
  801117:	5f                   	pop    %edi
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    
  80111a:	66 90                	xchg   %ax,%ax
  80111c:	89 d8                	mov    %ebx,%eax
  80111e:	f7 f7                	div    %edi
  801120:	31 ff                	xor    %edi,%edi
  801122:	89 fa                	mov    %edi,%edx
  801124:	83 c4 1c             	add    $0x1c,%esp
  801127:	5b                   	pop    %ebx
  801128:	5e                   	pop    %esi
  801129:	5f                   	pop    %edi
  80112a:	5d                   	pop    %ebp
  80112b:	c3                   	ret    
  80112c:	bd 20 00 00 00       	mov    $0x20,%ebp
  801131:	89 eb                	mov    %ebp,%ebx
  801133:	29 fb                	sub    %edi,%ebx
  801135:	89 f9                	mov    %edi,%ecx
  801137:	d3 e6                	shl    %cl,%esi
  801139:	89 c5                	mov    %eax,%ebp
  80113b:	88 d9                	mov    %bl,%cl
  80113d:	d3 ed                	shr    %cl,%ebp
  80113f:	89 e9                	mov    %ebp,%ecx
  801141:	09 f1                	or     %esi,%ecx
  801143:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801147:	89 f9                	mov    %edi,%ecx
  801149:	d3 e0                	shl    %cl,%eax
  80114b:	89 c5                	mov    %eax,%ebp
  80114d:	89 d6                	mov    %edx,%esi
  80114f:	88 d9                	mov    %bl,%cl
  801151:	d3 ee                	shr    %cl,%esi
  801153:	89 f9                	mov    %edi,%ecx
  801155:	d3 e2                	shl    %cl,%edx
  801157:	8b 44 24 08          	mov    0x8(%esp),%eax
  80115b:	88 d9                	mov    %bl,%cl
  80115d:	d3 e8                	shr    %cl,%eax
  80115f:	09 c2                	or     %eax,%edx
  801161:	89 d0                	mov    %edx,%eax
  801163:	89 f2                	mov    %esi,%edx
  801165:	f7 74 24 0c          	divl   0xc(%esp)
  801169:	89 d6                	mov    %edx,%esi
  80116b:	89 c3                	mov    %eax,%ebx
  80116d:	f7 e5                	mul    %ebp
  80116f:	39 d6                	cmp    %edx,%esi
  801171:	72 19                	jb     80118c <__udivdi3+0xfc>
  801173:	74 0b                	je     801180 <__udivdi3+0xf0>
  801175:	89 d8                	mov    %ebx,%eax
  801177:	31 ff                	xor    %edi,%edi
  801179:	e9 58 ff ff ff       	jmp    8010d6 <__udivdi3+0x46>
  80117e:	66 90                	xchg   %ax,%ax
  801180:	8b 54 24 08          	mov    0x8(%esp),%edx
  801184:	89 f9                	mov    %edi,%ecx
  801186:	d3 e2                	shl    %cl,%edx
  801188:	39 c2                	cmp    %eax,%edx
  80118a:	73 e9                	jae    801175 <__udivdi3+0xe5>
  80118c:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80118f:	31 ff                	xor    %edi,%edi
  801191:	e9 40 ff ff ff       	jmp    8010d6 <__udivdi3+0x46>
  801196:	66 90                	xchg   %ax,%ax
  801198:	31 c0                	xor    %eax,%eax
  80119a:	e9 37 ff ff ff       	jmp    8010d6 <__udivdi3+0x46>
  80119f:	90                   	nop

008011a0 <__umoddi3>:
  8011a0:	55                   	push   %ebp
  8011a1:	57                   	push   %edi
  8011a2:	56                   	push   %esi
  8011a3:	53                   	push   %ebx
  8011a4:	83 ec 1c             	sub    $0x1c,%esp
  8011a7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8011ab:	8b 74 24 34          	mov    0x34(%esp),%esi
  8011af:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8011b3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8011b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011bb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011bf:	89 f3                	mov    %esi,%ebx
  8011c1:	89 fa                	mov    %edi,%edx
  8011c3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011c7:	89 34 24             	mov    %esi,(%esp)
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	75 1a                	jne    8011e8 <__umoddi3+0x48>
  8011ce:	39 f7                	cmp    %esi,%edi
  8011d0:	0f 86 a2 00 00 00    	jbe    801278 <__umoddi3+0xd8>
  8011d6:	89 c8                	mov    %ecx,%eax
  8011d8:	89 f2                	mov    %esi,%edx
  8011da:	f7 f7                	div    %edi
  8011dc:	89 d0                	mov    %edx,%eax
  8011de:	31 d2                	xor    %edx,%edx
  8011e0:	83 c4 1c             	add    $0x1c,%esp
  8011e3:	5b                   	pop    %ebx
  8011e4:	5e                   	pop    %esi
  8011e5:	5f                   	pop    %edi
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    
  8011e8:	39 f0                	cmp    %esi,%eax
  8011ea:	0f 87 ac 00 00 00    	ja     80129c <__umoddi3+0xfc>
  8011f0:	0f bd e8             	bsr    %eax,%ebp
  8011f3:	83 f5 1f             	xor    $0x1f,%ebp
  8011f6:	0f 84 ac 00 00 00    	je     8012a8 <__umoddi3+0x108>
  8011fc:	bf 20 00 00 00       	mov    $0x20,%edi
  801201:	29 ef                	sub    %ebp,%edi
  801203:	89 fe                	mov    %edi,%esi
  801205:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801209:	89 e9                	mov    %ebp,%ecx
  80120b:	d3 e0                	shl    %cl,%eax
  80120d:	89 d7                	mov    %edx,%edi
  80120f:	89 f1                	mov    %esi,%ecx
  801211:	d3 ef                	shr    %cl,%edi
  801213:	09 c7                	or     %eax,%edi
  801215:	89 e9                	mov    %ebp,%ecx
  801217:	d3 e2                	shl    %cl,%edx
  801219:	89 14 24             	mov    %edx,(%esp)
  80121c:	89 d8                	mov    %ebx,%eax
  80121e:	d3 e0                	shl    %cl,%eax
  801220:	89 c2                	mov    %eax,%edx
  801222:	8b 44 24 08          	mov    0x8(%esp),%eax
  801226:	d3 e0                	shl    %cl,%eax
  801228:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122c:	8b 44 24 08          	mov    0x8(%esp),%eax
  801230:	89 f1                	mov    %esi,%ecx
  801232:	d3 e8                	shr    %cl,%eax
  801234:	09 d0                	or     %edx,%eax
  801236:	d3 eb                	shr    %cl,%ebx
  801238:	89 da                	mov    %ebx,%edx
  80123a:	f7 f7                	div    %edi
  80123c:	89 d3                	mov    %edx,%ebx
  80123e:	f7 24 24             	mull   (%esp)
  801241:	89 c6                	mov    %eax,%esi
  801243:	89 d1                	mov    %edx,%ecx
  801245:	39 d3                	cmp    %edx,%ebx
  801247:	0f 82 87 00 00 00    	jb     8012d4 <__umoddi3+0x134>
  80124d:	0f 84 91 00 00 00    	je     8012e4 <__umoddi3+0x144>
  801253:	8b 54 24 04          	mov    0x4(%esp),%edx
  801257:	29 f2                	sub    %esi,%edx
  801259:	19 cb                	sbb    %ecx,%ebx
  80125b:	89 d8                	mov    %ebx,%eax
  80125d:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801261:	d3 e0                	shl    %cl,%eax
  801263:	89 e9                	mov    %ebp,%ecx
  801265:	d3 ea                	shr    %cl,%edx
  801267:	09 d0                	or     %edx,%eax
  801269:	89 e9                	mov    %ebp,%ecx
  80126b:	d3 eb                	shr    %cl,%ebx
  80126d:	89 da                	mov    %ebx,%edx
  80126f:	83 c4 1c             	add    $0x1c,%esp
  801272:	5b                   	pop    %ebx
  801273:	5e                   	pop    %esi
  801274:	5f                   	pop    %edi
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    
  801277:	90                   	nop
  801278:	89 fd                	mov    %edi,%ebp
  80127a:	85 ff                	test   %edi,%edi
  80127c:	75 0b                	jne    801289 <__umoddi3+0xe9>
  80127e:	b8 01 00 00 00       	mov    $0x1,%eax
  801283:	31 d2                	xor    %edx,%edx
  801285:	f7 f7                	div    %edi
  801287:	89 c5                	mov    %eax,%ebp
  801289:	89 f0                	mov    %esi,%eax
  80128b:	31 d2                	xor    %edx,%edx
  80128d:	f7 f5                	div    %ebp
  80128f:	89 c8                	mov    %ecx,%eax
  801291:	f7 f5                	div    %ebp
  801293:	89 d0                	mov    %edx,%eax
  801295:	e9 44 ff ff ff       	jmp    8011de <__umoddi3+0x3e>
  80129a:	66 90                	xchg   %ax,%ax
  80129c:	89 c8                	mov    %ecx,%eax
  80129e:	89 f2                	mov    %esi,%edx
  8012a0:	83 c4 1c             	add    $0x1c,%esp
  8012a3:	5b                   	pop    %ebx
  8012a4:	5e                   	pop    %esi
  8012a5:	5f                   	pop    %edi
  8012a6:	5d                   	pop    %ebp
  8012a7:	c3                   	ret    
  8012a8:	3b 04 24             	cmp    (%esp),%eax
  8012ab:	72 06                	jb     8012b3 <__umoddi3+0x113>
  8012ad:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  8012b1:	77 0f                	ja     8012c2 <__umoddi3+0x122>
  8012b3:	89 f2                	mov    %esi,%edx
  8012b5:	29 f9                	sub    %edi,%ecx
  8012b7:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  8012bb:	89 14 24             	mov    %edx,(%esp)
  8012be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012c2:	8b 44 24 04          	mov    0x4(%esp),%eax
  8012c6:	8b 14 24             	mov    (%esp),%edx
  8012c9:	83 c4 1c             	add    $0x1c,%esp
  8012cc:	5b                   	pop    %ebx
  8012cd:	5e                   	pop    %esi
  8012ce:	5f                   	pop    %edi
  8012cf:	5d                   	pop    %ebp
  8012d0:	c3                   	ret    
  8012d1:	8d 76 00             	lea    0x0(%esi),%esi
  8012d4:	2b 04 24             	sub    (%esp),%eax
  8012d7:	19 fa                	sbb    %edi,%edx
  8012d9:	89 d1                	mov    %edx,%ecx
  8012db:	89 c6                	mov    %eax,%esi
  8012dd:	e9 71 ff ff ff       	jmp    801253 <__umoddi3+0xb3>
  8012e2:	66 90                	xchg   %ax,%ax
  8012e4:	39 44 24 04          	cmp    %eax,0x4(%esp)
  8012e8:	72 ea                	jb     8012d4 <__umoddi3+0x134>
  8012ea:	89 d9                	mov    %ebx,%ecx
  8012ec:	e9 62 ff ff ff       	jmp    801253 <__umoddi3+0xb3>
