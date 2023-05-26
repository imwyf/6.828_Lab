
obj/user/divzero:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 46 00 00 00       	call   800077 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 34 00 00 00       	call   800073 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	zero = 0;
  800045:	c7 c0 2c 20 80 00    	mov    $0x80202c,%eax
  80004b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	cprintf("1/0 is %08x!\n", 1/zero);
  800051:	b8 01 00 00 00       	mov    $0x1,%eax
  800056:	b9 00 00 00 00       	mov    $0x0,%ecx
  80005b:	99                   	cltd   
  80005c:	f7 f9                	idiv   %ecx
  80005e:	50                   	push   %eax
  80005f:	8d 83 7c ee ff ff    	lea    -0x1184(%ebx),%eax
  800065:	50                   	push   %eax
  800066:	e8 25 01 00 00       	call   800190 <cprintf>
}
  80006b:	83 c4 10             	add    $0x10,%esp
  80006e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800071:	c9                   	leave  
  800072:	c3                   	ret    

00800073 <__x86.get_pc_thunk.bx>:
  800073:	8b 1c 24             	mov    (%esp),%ebx
  800076:	c3                   	ret    

00800077 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800077:	55                   	push   %ebp
  800078:	89 e5                	mov    %esp,%ebp
  80007a:	53                   	push   %ebx
  80007b:	83 ec 04             	sub    $0x4,%esp
  80007e:	e8 f0 ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800083:	81 c3 7d 1f 00 00    	add    $0x1f7d,%ebx
  800089:	8b 45 08             	mov    0x8(%ebp),%eax
  80008c:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80008f:	c7 c1 30 20 80 00    	mov    $0x802030,%ecx
  800095:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009b:	85 c0                	test   %eax,%eax
  80009d:	7e 08                	jle    8000a7 <libmain+0x30>
		binaryname = argv[0];
  80009f:	8b 0a                	mov    (%edx),%ecx
  8000a1:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000a7:	83 ec 08             	sub    $0x8,%esp
  8000aa:	52                   	push   %edx
  8000ab:	50                   	push   %eax
  8000ac:	e8 82 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b1:	e8 08 00 00 00       	call   8000be <exit>
}
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	53                   	push   %ebx
  8000c2:	83 ec 10             	sub    $0x10,%esp
  8000c5:	e8 a9 ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  8000ca:	81 c3 36 1f 00 00    	add    $0x1f36,%ebx
	sys_env_destroy(0);
  8000d0:	6a 00                	push   $0x0
  8000d2:	e8 92 0a 00 00       	call   800b69 <sys_env_destroy>
}
  8000d7:	83 c4 10             	add    $0x10,%esp
  8000da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000dd:	c9                   	leave  
  8000de:	c3                   	ret    

008000df <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
  8000e4:	e8 8a ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  8000e9:	81 c3 17 1f 00 00    	add    $0x1f17,%ebx
  8000ef:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8000f2:	8b 16                	mov    (%esi),%edx
  8000f4:	8d 42 01             	lea    0x1(%edx),%eax
  8000f7:	89 06                	mov    %eax,(%esi)
  8000f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000fc:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800100:	3d ff 00 00 00       	cmp    $0xff,%eax
  800105:	74 0b                	je     800112 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800107:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80010b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5d                   	pop    %ebp
  800111:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800112:	83 ec 08             	sub    $0x8,%esp
  800115:	68 ff 00 00 00       	push   $0xff
  80011a:	8d 46 08             	lea    0x8(%esi),%eax
  80011d:	50                   	push   %eax
  80011e:	e8 09 0a 00 00       	call   800b2c <sys_cputs>
		b->idx = 0;
  800123:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	eb d9                	jmp    800107 <putch+0x28>

0080012e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	53                   	push   %ebx
  800132:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800138:	e8 36 ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  80013d:	81 c3 c3 1e 00 00    	add    $0x1ec3,%ebx
	struct printbuf b;

	b.idx = 0;
  800143:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014a:	00 00 00 
	b.cnt = 0;
  80014d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800154:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800157:	ff 75 0c             	pushl  0xc(%ebp)
  80015a:	ff 75 08             	pushl  0x8(%ebp)
  80015d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800163:	50                   	push   %eax
  800164:	8d 83 df e0 ff ff    	lea    -0x1f21(%ebx),%eax
  80016a:	50                   	push   %eax
  80016b:	e8 38 01 00 00       	call   8002a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800170:	83 c4 08             	add    $0x8,%esp
  800173:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800179:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017f:	50                   	push   %eax
  800180:	e8 a7 09 00 00       	call   800b2c <sys_cputs>

	return b.cnt;
}
  800185:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800196:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800199:	50                   	push   %eax
  80019a:	ff 75 08             	pushl  0x8(%ebp)
  80019d:	e8 8c ff ff ff       	call   80012e <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	57                   	push   %edi
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	83 ec 2c             	sub    $0x2c,%esp
  8001ad:	e8 02 06 00 00       	call   8007b4 <__x86.get_pc_thunk.cx>
  8001b2:	81 c1 4e 1e 00 00    	add    $0x1e4e,%ecx
  8001b8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001bb:	89 c7                	mov    %eax,%edi
  8001bd:	89 d6                	mov    %edx,%esi
  8001bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001c8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  8001cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d3:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8001d6:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8001d9:	39 d3                	cmp    %edx,%ebx
  8001db:	72 09                	jb     8001e6 <printnum+0x42>
  8001dd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e0:	0f 87 83 00 00 00    	ja     800269 <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e6:	83 ec 0c             	sub    $0xc,%esp
  8001e9:	ff 75 18             	pushl  0x18(%ebp)
  8001ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ef:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f2:	53                   	push   %ebx
  8001f3:	ff 75 10             	pushl  0x10(%ebp)
  8001f6:	83 ec 08             	sub    $0x8,%esp
  8001f9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fc:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ff:	ff 75 d4             	pushl  -0x2c(%ebp)
  800202:	ff 75 d0             	pushl  -0x30(%ebp)
  800205:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800208:	e8 33 0a 00 00       	call   800c40 <__udivdi3>
  80020d:	83 c4 18             	add    $0x18,%esp
  800210:	52                   	push   %edx
  800211:	50                   	push   %eax
  800212:	89 f2                	mov    %esi,%edx
  800214:	89 f8                	mov    %edi,%eax
  800216:	e8 89 ff ff ff       	call   8001a4 <printnum>
  80021b:	83 c4 20             	add    $0x20,%esp
  80021e:	eb 13                	jmp    800233 <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	56                   	push   %esi
  800224:	ff 75 18             	pushl  0x18(%ebp)
  800227:	ff d7                	call   *%edi
  800229:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80022c:	83 eb 01             	sub    $0x1,%ebx
  80022f:	85 db                	test   %ebx,%ebx
  800231:	7f ed                	jg     800220 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800233:	83 ec 08             	sub    $0x8,%esp
  800236:	56                   	push   %esi
  800237:	83 ec 04             	sub    $0x4,%esp
  80023a:	ff 75 dc             	pushl  -0x24(%ebp)
  80023d:	ff 75 d8             	pushl  -0x28(%ebp)
  800240:	ff 75 d4             	pushl  -0x2c(%ebp)
  800243:	ff 75 d0             	pushl  -0x30(%ebp)
  800246:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800249:	89 f3                	mov    %esi,%ebx
  80024b:	e8 10 0b 00 00       	call   800d60 <__umoddi3>
  800250:	83 c4 14             	add    $0x14,%esp
  800253:	0f be 84 06 94 ee ff 	movsbl -0x116c(%esi,%eax,1),%eax
  80025a:	ff 
  80025b:	50                   	push   %eax
  80025c:	ff d7                	call   *%edi
}
  80025e:	83 c4 10             	add    $0x10,%esp
  800261:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800264:	5b                   	pop    %ebx
  800265:	5e                   	pop    %esi
  800266:	5f                   	pop    %edi
  800267:	5d                   	pop    %ebp
  800268:	c3                   	ret    
  800269:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80026c:	eb be                	jmp    80022c <printnum+0x88>

0080026e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800274:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800278:	8b 10                	mov    (%eax),%edx
  80027a:	3b 50 04             	cmp    0x4(%eax),%edx
  80027d:	73 0a                	jae    800289 <sprintputch+0x1b>
		*b->buf++ = ch;
  80027f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800282:	89 08                	mov    %ecx,(%eax)
  800284:	8b 45 08             	mov    0x8(%ebp),%eax
  800287:	88 02                	mov    %al,(%edx)
}
  800289:	5d                   	pop    %ebp
  80028a:	c3                   	ret    

0080028b <printfmt>:
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800291:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800294:	50                   	push   %eax
  800295:	ff 75 10             	pushl  0x10(%ebp)
  800298:	ff 75 0c             	pushl  0xc(%ebp)
  80029b:	ff 75 08             	pushl  0x8(%ebp)
  80029e:	e8 05 00 00 00       	call   8002a8 <vprintfmt>
}
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <vprintfmt>:
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	57                   	push   %edi
  8002ac:	56                   	push   %esi
  8002ad:	53                   	push   %ebx
  8002ae:	83 ec 2c             	sub    $0x2c,%esp
  8002b1:	e8 bd fd ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  8002b6:	81 c3 4a 1d 00 00    	add    $0x1d4a,%ebx
  8002bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002bf:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c2:	e9 c3 03 00 00       	jmp    80068a <.L35+0x48>
		padc = ' ';
  8002c7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002cb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002d2:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8002d9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e5:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8002e8:	8d 47 01             	lea    0x1(%edi),%eax
  8002eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ee:	0f b6 17             	movzbl (%edi),%edx
  8002f1:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002f4:	3c 55                	cmp    $0x55,%al
  8002f6:	0f 87 16 04 00 00    	ja     800712 <.L22>
  8002fc:	0f b6 c0             	movzbl %al,%eax
  8002ff:	89 d9                	mov    %ebx,%ecx
  800301:	03 8c 83 24 ef ff ff 	add    -0x10dc(%ebx,%eax,4),%ecx
  800308:	ff e1                	jmp    *%ecx

0080030a <.L69>:
  80030a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80030d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800311:	eb d5                	jmp    8002e8 <vprintfmt+0x40>

00800313 <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800313:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800316:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80031a:	eb cc                	jmp    8002e8 <vprintfmt+0x40>

0080031c <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80031c:	0f b6 d2             	movzbl %dl,%edx
  80031f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
  800322:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800327:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80032a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80032e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800331:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800334:	83 f9 09             	cmp    $0x9,%ecx
  800337:	77 55                	ja     80038e <.L23+0xf>
			for (precision = 0;; ++fmt)
  800339:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80033c:	eb e9                	jmp    800327 <.L29+0xb>

0080033e <.L26>:
			precision = va_arg(ap, int);
  80033e:	8b 45 14             	mov    0x14(%ebp),%eax
  800341:	8b 00                	mov    (%eax),%eax
  800343:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800346:	8b 45 14             	mov    0x14(%ebp),%eax
  800349:	8d 40 04             	lea    0x4(%eax),%eax
  80034c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80034f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800352:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800356:	79 90                	jns    8002e8 <vprintfmt+0x40>
				width = precision, precision = -1;
  800358:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80035b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035e:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800365:	eb 81                	jmp    8002e8 <vprintfmt+0x40>

00800367 <.L27>:
  800367:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036a:	85 c0                	test   %eax,%eax
  80036c:	ba 00 00 00 00       	mov    $0x0,%edx
  800371:	0f 49 d0             	cmovns %eax,%edx
  800374:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037a:	e9 69 ff ff ff       	jmp    8002e8 <vprintfmt+0x40>

0080037f <.L23>:
  80037f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800382:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800389:	e9 5a ff ff ff       	jmp    8002e8 <vprintfmt+0x40>
  80038e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800391:	eb bf                	jmp    800352 <.L26+0x14>

00800393 <.L33>:
			lflag++;
  800393:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800397:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80039a:	e9 49 ff ff ff       	jmp    8002e8 <vprintfmt+0x40>

0080039f <.L30>:
			putch(va_arg(ap, int), putdat);
  80039f:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a2:	8d 78 04             	lea    0x4(%eax),%edi
  8003a5:	83 ec 08             	sub    $0x8,%esp
  8003a8:	56                   	push   %esi
  8003a9:	ff 30                	pushl  (%eax)
  8003ab:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003ae:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003b1:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003b4:	e9 ce 02 00 00       	jmp    800687 <.L35+0x45>

008003b9 <.L32>:
			err = va_arg(ap, int);
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8d 78 04             	lea    0x4(%eax),%edi
  8003bf:	8b 00                	mov    (%eax),%eax
  8003c1:	99                   	cltd   
  8003c2:	31 d0                	xor    %edx,%eax
  8003c4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c6:	83 f8 06             	cmp    $0x6,%eax
  8003c9:	7f 27                	jg     8003f2 <.L32+0x39>
  8003cb:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8003d2:	85 d2                	test   %edx,%edx
  8003d4:	74 1c                	je     8003f2 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8003d6:	52                   	push   %edx
  8003d7:	8d 83 b5 ee ff ff    	lea    -0x114b(%ebx),%eax
  8003dd:	50                   	push   %eax
  8003de:	56                   	push   %esi
  8003df:	ff 75 08             	pushl  0x8(%ebp)
  8003e2:	e8 a4 fe ff ff       	call   80028b <printfmt>
  8003e7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ea:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003ed:	e9 95 02 00 00       	jmp    800687 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8003f2:	50                   	push   %eax
  8003f3:	8d 83 ac ee ff ff    	lea    -0x1154(%ebx),%eax
  8003f9:	50                   	push   %eax
  8003fa:	56                   	push   %esi
  8003fb:	ff 75 08             	pushl  0x8(%ebp)
  8003fe:	e8 88 fe ff ff       	call   80028b <printfmt>
  800403:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800406:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800409:	e9 79 02 00 00       	jmp    800687 <.L35+0x45>

0080040e <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  80040e:	8b 45 14             	mov    0x14(%ebp),%eax
  800411:	83 c0 04             	add    $0x4,%eax
  800414:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800417:	8b 45 14             	mov    0x14(%ebp),%eax
  80041a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80041c:	85 ff                	test   %edi,%edi
  80041e:	8d 83 a5 ee ff ff    	lea    -0x115b(%ebx),%eax
  800424:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800427:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042b:	0f 8e b5 00 00 00    	jle    8004e6 <.L36+0xd8>
  800431:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800435:	75 08                	jne    80043f <.L36+0x31>
  800437:	89 75 0c             	mov    %esi,0xc(%ebp)
  80043a:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80043d:	eb 6d                	jmp    8004ac <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	ff 75 cc             	pushl  -0x34(%ebp)
  800445:	57                   	push   %edi
  800446:	e8 85 03 00 00       	call   8007d0 <strnlen>
  80044b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80044e:	29 c2                	sub    %eax,%edx
  800450:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800453:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800456:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80045a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800460:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800462:	eb 10                	jmp    800474 <.L36+0x66>
					putch(padc, putdat);
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	56                   	push   %esi
  800468:	ff 75 e0             	pushl  -0x20(%ebp)
  80046b:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80046e:	83 ef 01             	sub    $0x1,%edi
  800471:	83 c4 10             	add    $0x10,%esp
  800474:	85 ff                	test   %edi,%edi
  800476:	7f ec                	jg     800464 <.L36+0x56>
  800478:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80047b:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80047e:	85 d2                	test   %edx,%edx
  800480:	b8 00 00 00 00       	mov    $0x0,%eax
  800485:	0f 49 c2             	cmovns %edx,%eax
  800488:	29 c2                	sub    %eax,%edx
  80048a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80048d:	89 75 0c             	mov    %esi,0xc(%ebp)
  800490:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800493:	eb 17                	jmp    8004ac <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  800495:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800499:	75 30                	jne    8004cb <.L36+0xbd>
					putch(ch, putdat);
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	ff 75 0c             	pushl  0xc(%ebp)
  8004a1:	50                   	push   %eax
  8004a2:	ff 55 08             	call   *0x8(%ebp)
  8004a5:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a8:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8004ac:	83 c7 01             	add    $0x1,%edi
  8004af:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004b3:	0f be c2             	movsbl %dl,%eax
  8004b6:	85 c0                	test   %eax,%eax
  8004b8:	74 52                	je     80050c <.L36+0xfe>
  8004ba:	85 f6                	test   %esi,%esi
  8004bc:	78 d7                	js     800495 <.L36+0x87>
  8004be:	83 ee 01             	sub    $0x1,%esi
  8004c1:	79 d2                	jns    800495 <.L36+0x87>
  8004c3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004c6:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004c9:	eb 32                	jmp    8004fd <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8004cb:	0f be d2             	movsbl %dl,%edx
  8004ce:	83 ea 20             	sub    $0x20,%edx
  8004d1:	83 fa 5e             	cmp    $0x5e,%edx
  8004d4:	76 c5                	jbe    80049b <.L36+0x8d>
					putch('?', putdat);
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	ff 75 0c             	pushl  0xc(%ebp)
  8004dc:	6a 3f                	push   $0x3f
  8004de:	ff 55 08             	call   *0x8(%ebp)
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	eb c2                	jmp    8004a8 <.L36+0x9a>
  8004e6:	89 75 0c             	mov    %esi,0xc(%ebp)
  8004e9:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004ec:	eb be                	jmp    8004ac <.L36+0x9e>
				putch(' ', putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	56                   	push   %esi
  8004f2:	6a 20                	push   $0x20
  8004f4:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8004f7:	83 ef 01             	sub    $0x1,%edi
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	85 ff                	test   %edi,%edi
  8004ff:	7f ed                	jg     8004ee <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800501:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800504:	89 45 14             	mov    %eax,0x14(%ebp)
  800507:	e9 7b 01 00 00       	jmp    800687 <.L35+0x45>
  80050c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80050f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800512:	eb e9                	jmp    8004fd <.L36+0xef>

00800514 <.L31>:
  800514:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800517:	83 f9 01             	cmp    $0x1,%ecx
  80051a:	7e 40                	jle    80055c <.L31+0x48>
		return va_arg(*ap, long long);
  80051c:	8b 45 14             	mov    0x14(%ebp),%eax
  80051f:	8b 50 04             	mov    0x4(%eax),%edx
  800522:	8b 00                	mov    (%eax),%eax
  800524:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800527:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052a:	8b 45 14             	mov    0x14(%ebp),%eax
  80052d:	8d 40 08             	lea    0x8(%eax),%eax
  800530:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
  800533:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800537:	79 55                	jns    80058e <.L31+0x7a>
				putch('-', putdat);
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	56                   	push   %esi
  80053d:	6a 2d                	push   $0x2d
  80053f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  800542:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800545:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800548:	f7 da                	neg    %edx
  80054a:	83 d1 00             	adc    $0x0,%ecx
  80054d:	f7 d9                	neg    %ecx
  80054f:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
  800552:	b8 0a 00 00 00       	mov    $0xa,%eax
  800557:	e9 10 01 00 00       	jmp    80066c <.L35+0x2a>
	else if (lflag)
  80055c:	85 c9                	test   %ecx,%ecx
  80055e:	75 17                	jne    800577 <.L31+0x63>
		return va_arg(*ap, int);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8b 00                	mov    (%eax),%eax
  800565:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800568:	99                   	cltd   
  800569:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8d 40 04             	lea    0x4(%eax),%eax
  800572:	89 45 14             	mov    %eax,0x14(%ebp)
  800575:	eb bc                	jmp    800533 <.L31+0x1f>
		return va_arg(*ap, long);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057f:	99                   	cltd   
  800580:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 40 04             	lea    0x4(%eax),%eax
  800589:	89 45 14             	mov    %eax,0x14(%ebp)
  80058c:	eb a5                	jmp    800533 <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  80058e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800591:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
  800594:	b8 0a 00 00 00       	mov    $0xa,%eax
  800599:	e9 ce 00 00 00       	jmp    80066c <.L35+0x2a>

0080059e <.L37>:
  80059e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8005a1:	83 f9 01             	cmp    $0x1,%ecx
  8005a4:	7e 18                	jle    8005be <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8b 10                	mov    (%eax),%edx
  8005ab:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ae:	8d 40 08             	lea    0x8(%eax),%eax
  8005b1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b9:	e9 ae 00 00 00       	jmp    80066c <.L35+0x2a>
	else if (lflag)
  8005be:	85 c9                	test   %ecx,%ecx
  8005c0:	75 1a                	jne    8005dc <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8b 10                	mov    (%eax),%edx
  8005c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cc:	8d 40 04             	lea    0x4(%eax),%eax
  8005cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d7:	e9 90 00 00 00       	jmp    80066c <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8b 10                	mov    (%eax),%edx
  8005e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e6:	8d 40 04             	lea    0x4(%eax),%eax
  8005e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ec:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f1:	eb 79                	jmp    80066c <.L35+0x2a>

008005f3 <.L34>:
  8005f3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8005f6:	83 f9 01             	cmp    $0x1,%ecx
  8005f9:	7e 15                	jle    800610 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8b 10                	mov    (%eax),%edx
  800600:	8b 48 04             	mov    0x4(%eax),%ecx
  800603:	8d 40 08             	lea    0x8(%eax),%eax
  800606:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800609:	b8 08 00 00 00       	mov    $0x8,%eax
  80060e:	eb 5c                	jmp    80066c <.L35+0x2a>
	else if (lflag)
  800610:	85 c9                	test   %ecx,%ecx
  800612:	75 17                	jne    80062b <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8b 10                	mov    (%eax),%edx
  800619:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061e:	8d 40 04             	lea    0x4(%eax),%eax
  800621:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800624:	b8 08 00 00 00       	mov    $0x8,%eax
  800629:	eb 41                	jmp    80066c <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8b 10                	mov    (%eax),%edx
  800630:	b9 00 00 00 00       	mov    $0x0,%ecx
  800635:	8d 40 04             	lea    0x4(%eax),%eax
  800638:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80063b:	b8 08 00 00 00       	mov    $0x8,%eax
  800640:	eb 2a                	jmp    80066c <.L35+0x2a>

00800642 <.L35>:
			putch('0', putdat);
  800642:	83 ec 08             	sub    $0x8,%esp
  800645:	56                   	push   %esi
  800646:	6a 30                	push   $0x30
  800648:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80064b:	83 c4 08             	add    $0x8,%esp
  80064e:	56                   	push   %esi
  80064f:	6a 78                	push   $0x78
  800651:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8b 10                	mov    (%eax),%edx
  800659:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80065e:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800661:	8d 40 04             	lea    0x4(%eax),%eax
  800664:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800667:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  80066c:	83 ec 0c             	sub    $0xc,%esp
  80066f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800673:	57                   	push   %edi
  800674:	ff 75 e0             	pushl  -0x20(%ebp)
  800677:	50                   	push   %eax
  800678:	51                   	push   %ecx
  800679:	52                   	push   %edx
  80067a:	89 f2                	mov    %esi,%edx
  80067c:	8b 45 08             	mov    0x8(%ebp),%eax
  80067f:	e8 20 fb ff ff       	call   8001a4 <printnum>
			break;
  800684:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800687:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  80068a:	83 c7 01             	add    $0x1,%edi
  80068d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800691:	83 f8 25             	cmp    $0x25,%eax
  800694:	0f 84 2d fc ff ff    	je     8002c7 <vprintfmt+0x1f>
			if (ch == '\0')
  80069a:	85 c0                	test   %eax,%eax
  80069c:	0f 84 91 00 00 00    	je     800733 <.L22+0x21>
			putch(ch, putdat);
  8006a2:	83 ec 08             	sub    $0x8,%esp
  8006a5:	56                   	push   %esi
  8006a6:	50                   	push   %eax
  8006a7:	ff 55 08             	call   *0x8(%ebp)
  8006aa:	83 c4 10             	add    $0x10,%esp
  8006ad:	eb db                	jmp    80068a <.L35+0x48>

008006af <.L38>:
  8006af:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006b2:	83 f9 01             	cmp    $0x1,%ecx
  8006b5:	7e 15                	jle    8006cc <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8b 10                	mov    (%eax),%edx
  8006bc:	8b 48 04             	mov    0x4(%eax),%ecx
  8006bf:	8d 40 08             	lea    0x8(%eax),%eax
  8006c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c5:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ca:	eb a0                	jmp    80066c <.L35+0x2a>
	else if (lflag)
  8006cc:	85 c9                	test   %ecx,%ecx
  8006ce:	75 17                	jne    8006e7 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8b 10                	mov    (%eax),%edx
  8006d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006da:	8d 40 04             	lea    0x4(%eax),%eax
  8006dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e0:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e5:	eb 85                	jmp    80066c <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8b 10                	mov    (%eax),%edx
  8006ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f1:	8d 40 04             	lea    0x4(%eax),%eax
  8006f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f7:	b8 10 00 00 00       	mov    $0x10,%eax
  8006fc:	e9 6b ff ff ff       	jmp    80066c <.L35+0x2a>

00800701 <.L25>:
			putch(ch, putdat);
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	56                   	push   %esi
  800705:	6a 25                	push   $0x25
  800707:	ff 55 08             	call   *0x8(%ebp)
			break;
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	e9 75 ff ff ff       	jmp    800687 <.L35+0x45>

00800712 <.L22>:
			putch('%', putdat);
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	56                   	push   %esi
  800716:	6a 25                	push   $0x25
  800718:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071b:	83 c4 10             	add    $0x10,%esp
  80071e:	89 f8                	mov    %edi,%eax
  800720:	eb 03                	jmp    800725 <.L22+0x13>
  800722:	83 e8 01             	sub    $0x1,%eax
  800725:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800729:	75 f7                	jne    800722 <.L22+0x10>
  80072b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80072e:	e9 54 ff ff ff       	jmp    800687 <.L35+0x45>
}
  800733:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800736:	5b                   	pop    %ebx
  800737:	5e                   	pop    %esi
  800738:	5f                   	pop    %edi
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	53                   	push   %ebx
  80073f:	83 ec 14             	sub    $0x14,%esp
  800742:	e8 2c f9 ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800747:	81 c3 b9 18 00 00    	add    $0x18b9,%ebx
  80074d:	8b 45 08             	mov    0x8(%ebp),%eax
  800750:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  800753:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800756:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80075a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80075d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800764:	85 c0                	test   %eax,%eax
  800766:	74 2b                	je     800793 <vsnprintf+0x58>
  800768:	85 d2                	test   %edx,%edx
  80076a:	7e 27                	jle    800793 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  80076c:	ff 75 14             	pushl  0x14(%ebp)
  80076f:	ff 75 10             	pushl  0x10(%ebp)
  800772:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800775:	50                   	push   %eax
  800776:	8d 83 6e e2 ff ff    	lea    -0x1d92(%ebx),%eax
  80077c:	50                   	push   %eax
  80077d:	e8 26 fb ff ff       	call   8002a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800782:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800785:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800788:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078b:	83 c4 10             	add    $0x10,%esp
}
  80078e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800791:	c9                   	leave  
  800792:	c3                   	ret    
		return -E_INVAL;
  800793:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800798:	eb f4                	jmp    80078e <vsnprintf+0x53>

0080079a <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a3:	50                   	push   %eax
  8007a4:	ff 75 10             	pushl  0x10(%ebp)
  8007a7:	ff 75 0c             	pushl  0xc(%ebp)
  8007aa:	ff 75 08             	pushl  0x8(%ebp)
  8007ad:	e8 89 ff ff ff       	call   80073b <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <__x86.get_pc_thunk.cx>:
  8007b4:	8b 0c 24             	mov    (%esp),%ecx
  8007b7:	c3                   	ret    

008007b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007be:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c3:	eb 03                	jmp    8007c8 <strlen+0x10>
		n++;
  8007c5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007c8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cc:	75 f7                	jne    8007c5 <strlen+0xd>
	return n;
}
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007de:	eb 03                	jmp    8007e3 <strnlen+0x13>
		n++;
  8007e0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e3:	39 d0                	cmp    %edx,%eax
  8007e5:	74 06                	je     8007ed <strnlen+0x1d>
  8007e7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007eb:	75 f3                	jne    8007e0 <strnlen+0x10>
	return n;
}
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	53                   	push   %ebx
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f9:	89 c2                	mov    %eax,%edx
  8007fb:	83 c1 01             	add    $0x1,%ecx
  8007fe:	83 c2 01             	add    $0x1,%edx
  800801:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800805:	88 5a ff             	mov    %bl,-0x1(%edx)
  800808:	84 db                	test   %bl,%bl
  80080a:	75 ef                	jne    8007fb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80080c:	5b                   	pop    %ebx
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800816:	53                   	push   %ebx
  800817:	e8 9c ff ff ff       	call   8007b8 <strlen>
  80081c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80081f:	ff 75 0c             	pushl  0xc(%ebp)
  800822:	01 d8                	add    %ebx,%eax
  800824:	50                   	push   %eax
  800825:	e8 c5 ff ff ff       	call   8007ef <strcpy>
	return dst;
}
  80082a:	89 d8                	mov    %ebx,%eax
  80082c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082f:	c9                   	leave  
  800830:	c3                   	ret    

00800831 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	56                   	push   %esi
  800835:	53                   	push   %ebx
  800836:	8b 75 08             	mov    0x8(%ebp),%esi
  800839:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083c:	89 f3                	mov    %esi,%ebx
  80083e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800841:	89 f2                	mov    %esi,%edx
  800843:	eb 0f                	jmp    800854 <strncpy+0x23>
		*dst++ = *src;
  800845:	83 c2 01             	add    $0x1,%edx
  800848:	0f b6 01             	movzbl (%ecx),%eax
  80084b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084e:	80 39 01             	cmpb   $0x1,(%ecx)
  800851:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800854:	39 da                	cmp    %ebx,%edx
  800856:	75 ed                	jne    800845 <strncpy+0x14>
	}
	return ret;
}
  800858:	89 f0                	mov    %esi,%eax
  80085a:	5b                   	pop    %ebx
  80085b:	5e                   	pop    %esi
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	56                   	push   %esi
  800862:	53                   	push   %ebx
  800863:	8b 75 08             	mov    0x8(%ebp),%esi
  800866:	8b 55 0c             	mov    0xc(%ebp),%edx
  800869:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80086c:	89 f0                	mov    %esi,%eax
  80086e:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800872:	85 c9                	test   %ecx,%ecx
  800874:	75 0b                	jne    800881 <strlcpy+0x23>
  800876:	eb 17                	jmp    80088f <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800878:	83 c2 01             	add    $0x1,%edx
  80087b:	83 c0 01             	add    $0x1,%eax
  80087e:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800881:	39 d8                	cmp    %ebx,%eax
  800883:	74 07                	je     80088c <strlcpy+0x2e>
  800885:	0f b6 0a             	movzbl (%edx),%ecx
  800888:	84 c9                	test   %cl,%cl
  80088a:	75 ec                	jne    800878 <strlcpy+0x1a>
		*dst = '\0';
  80088c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80088f:	29 f0                	sub    %esi,%eax
}
  800891:	5b                   	pop    %ebx
  800892:	5e                   	pop    %esi
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089e:	eb 06                	jmp    8008a6 <strcmp+0x11>
		p++, q++;
  8008a0:	83 c1 01             	add    $0x1,%ecx
  8008a3:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008a6:	0f b6 01             	movzbl (%ecx),%eax
  8008a9:	84 c0                	test   %al,%al
  8008ab:	74 04                	je     8008b1 <strcmp+0x1c>
  8008ad:	3a 02                	cmp    (%edx),%al
  8008af:	74 ef                	je     8008a0 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b1:	0f b6 c0             	movzbl %al,%eax
  8008b4:	0f b6 12             	movzbl (%edx),%edx
  8008b7:	29 d0                	sub    %edx,%eax
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c5:	89 c3                	mov    %eax,%ebx
  8008c7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ca:	eb 06                	jmp    8008d2 <strncmp+0x17>
		n--, p++, q++;
  8008cc:	83 c0 01             	add    $0x1,%eax
  8008cf:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008d2:	39 d8                	cmp    %ebx,%eax
  8008d4:	74 16                	je     8008ec <strncmp+0x31>
  8008d6:	0f b6 08             	movzbl (%eax),%ecx
  8008d9:	84 c9                	test   %cl,%cl
  8008db:	74 04                	je     8008e1 <strncmp+0x26>
  8008dd:	3a 0a                	cmp    (%edx),%cl
  8008df:	74 eb                	je     8008cc <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e1:	0f b6 00             	movzbl (%eax),%eax
  8008e4:	0f b6 12             	movzbl (%edx),%edx
  8008e7:	29 d0                	sub    %edx,%eax
}
  8008e9:	5b                   	pop    %ebx
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    
		return 0;
  8008ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f1:	eb f6                	jmp    8008e9 <strncmp+0x2e>

008008f3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fd:	0f b6 10             	movzbl (%eax),%edx
  800900:	84 d2                	test   %dl,%dl
  800902:	74 09                	je     80090d <strchr+0x1a>
		if (*s == c)
  800904:	38 ca                	cmp    %cl,%dl
  800906:	74 0a                	je     800912 <strchr+0x1f>
	for (; *s; s++)
  800908:	83 c0 01             	add    $0x1,%eax
  80090b:	eb f0                	jmp    8008fd <strchr+0xa>
			return (char *) s;
	return 0;
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091e:	eb 03                	jmp    800923 <strfind+0xf>
  800920:	83 c0 01             	add    $0x1,%eax
  800923:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800926:	38 ca                	cmp    %cl,%dl
  800928:	74 04                	je     80092e <strfind+0x1a>
  80092a:	84 d2                	test   %dl,%dl
  80092c:	75 f2                	jne    800920 <strfind+0xc>
			break;
	return (char *) s;
}
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	57                   	push   %edi
  800934:	56                   	push   %esi
  800935:	53                   	push   %ebx
  800936:	8b 7d 08             	mov    0x8(%ebp),%edi
  800939:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093c:	85 c9                	test   %ecx,%ecx
  80093e:	74 13                	je     800953 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800940:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800946:	75 05                	jne    80094d <memset+0x1d>
  800948:	f6 c1 03             	test   $0x3,%cl
  80094b:	74 0d                	je     80095a <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800950:	fc                   	cld    
  800951:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800953:	89 f8                	mov    %edi,%eax
  800955:	5b                   	pop    %ebx
  800956:	5e                   	pop    %esi
  800957:	5f                   	pop    %edi
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    
		c &= 0xFF;
  80095a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095e:	89 d3                	mov    %edx,%ebx
  800960:	c1 e3 08             	shl    $0x8,%ebx
  800963:	89 d0                	mov    %edx,%eax
  800965:	c1 e0 18             	shl    $0x18,%eax
  800968:	89 d6                	mov    %edx,%esi
  80096a:	c1 e6 10             	shl    $0x10,%esi
  80096d:	09 f0                	or     %esi,%eax
  80096f:	09 c2                	or     %eax,%edx
  800971:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800973:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800976:	89 d0                	mov    %edx,%eax
  800978:	fc                   	cld    
  800979:	f3 ab                	rep stos %eax,%es:(%edi)
  80097b:	eb d6                	jmp    800953 <memset+0x23>

0080097d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	57                   	push   %edi
  800981:	56                   	push   %esi
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	8b 75 0c             	mov    0xc(%ebp),%esi
  800988:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098b:	39 c6                	cmp    %eax,%esi
  80098d:	73 35                	jae    8009c4 <memmove+0x47>
  80098f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800992:	39 c2                	cmp    %eax,%edx
  800994:	76 2e                	jbe    8009c4 <memmove+0x47>
		s += n;
		d += n;
  800996:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800999:	89 d6                	mov    %edx,%esi
  80099b:	09 fe                	or     %edi,%esi
  80099d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a3:	74 0c                	je     8009b1 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a5:	83 ef 01             	sub    $0x1,%edi
  8009a8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009ab:	fd                   	std    
  8009ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ae:	fc                   	cld    
  8009af:	eb 21                	jmp    8009d2 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b1:	f6 c1 03             	test   $0x3,%cl
  8009b4:	75 ef                	jne    8009a5 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b6:	83 ef 04             	sub    $0x4,%edi
  8009b9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009bf:	fd                   	std    
  8009c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c2:	eb ea                	jmp    8009ae <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c4:	89 f2                	mov    %esi,%edx
  8009c6:	09 c2                	or     %eax,%edx
  8009c8:	f6 c2 03             	test   $0x3,%dl
  8009cb:	74 09                	je     8009d6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009cd:	89 c7                	mov    %eax,%edi
  8009cf:	fc                   	cld    
  8009d0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d2:	5e                   	pop    %esi
  8009d3:	5f                   	pop    %edi
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d6:	f6 c1 03             	test   $0x3,%cl
  8009d9:	75 f2                	jne    8009cd <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009db:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009de:	89 c7                	mov    %eax,%edi
  8009e0:	fc                   	cld    
  8009e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e3:	eb ed                	jmp    8009d2 <memmove+0x55>

008009e5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009e8:	ff 75 10             	pushl  0x10(%ebp)
  8009eb:	ff 75 0c             	pushl  0xc(%ebp)
  8009ee:	ff 75 08             	pushl  0x8(%ebp)
  8009f1:	e8 87 ff ff ff       	call   80097d <memmove>
}
  8009f6:	c9                   	leave  
  8009f7:	c3                   	ret    

008009f8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	56                   	push   %esi
  8009fc:	53                   	push   %ebx
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a03:	89 c6                	mov    %eax,%esi
  800a05:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a08:	39 f0                	cmp    %esi,%eax
  800a0a:	74 1c                	je     800a28 <memcmp+0x30>
		if (*s1 != *s2)
  800a0c:	0f b6 08             	movzbl (%eax),%ecx
  800a0f:	0f b6 1a             	movzbl (%edx),%ebx
  800a12:	38 d9                	cmp    %bl,%cl
  800a14:	75 08                	jne    800a1e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a16:	83 c0 01             	add    $0x1,%eax
  800a19:	83 c2 01             	add    $0x1,%edx
  800a1c:	eb ea                	jmp    800a08 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a1e:	0f b6 c1             	movzbl %cl,%eax
  800a21:	0f b6 db             	movzbl %bl,%ebx
  800a24:	29 d8                	sub    %ebx,%eax
  800a26:	eb 05                	jmp    800a2d <memcmp+0x35>
	}

	return 0;
  800a28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2d:	5b                   	pop    %ebx
  800a2e:	5e                   	pop    %esi
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a3a:	89 c2                	mov    %eax,%edx
  800a3c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a3f:	39 d0                	cmp    %edx,%eax
  800a41:	73 09                	jae    800a4c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a43:	38 08                	cmp    %cl,(%eax)
  800a45:	74 05                	je     800a4c <memfind+0x1b>
	for (; s < ends; s++)
  800a47:	83 c0 01             	add    $0x1,%eax
  800a4a:	eb f3                	jmp    800a3f <memfind+0xe>
			break;
	return (void *) s;
}
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	57                   	push   %edi
  800a52:	56                   	push   %esi
  800a53:	53                   	push   %ebx
  800a54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5a:	eb 03                	jmp    800a5f <strtol+0x11>
		s++;
  800a5c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a5f:	0f b6 01             	movzbl (%ecx),%eax
  800a62:	3c 20                	cmp    $0x20,%al
  800a64:	74 f6                	je     800a5c <strtol+0xe>
  800a66:	3c 09                	cmp    $0x9,%al
  800a68:	74 f2                	je     800a5c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a6a:	3c 2b                	cmp    $0x2b,%al
  800a6c:	74 2e                	je     800a9c <strtol+0x4e>
	int neg = 0;
  800a6e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a73:	3c 2d                	cmp    $0x2d,%al
  800a75:	74 2f                	je     800aa6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a77:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a7d:	75 05                	jne    800a84 <strtol+0x36>
  800a7f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a82:	74 2c                	je     800ab0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a84:	85 db                	test   %ebx,%ebx
  800a86:	75 0a                	jne    800a92 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a88:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a8d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a90:	74 28                	je     800aba <strtol+0x6c>
		base = 10;
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
  800a97:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a9a:	eb 50                	jmp    800aec <strtol+0x9e>
		s++;
  800a9c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a9f:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa4:	eb d1                	jmp    800a77 <strtol+0x29>
		s++, neg = 1;
  800aa6:	83 c1 01             	add    $0x1,%ecx
  800aa9:	bf 01 00 00 00       	mov    $0x1,%edi
  800aae:	eb c7                	jmp    800a77 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab4:	74 0e                	je     800ac4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ab6:	85 db                	test   %ebx,%ebx
  800ab8:	75 d8                	jne    800a92 <strtol+0x44>
		s++, base = 8;
  800aba:	83 c1 01             	add    $0x1,%ecx
  800abd:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ac2:	eb ce                	jmp    800a92 <strtol+0x44>
		s += 2, base = 16;
  800ac4:	83 c1 02             	add    $0x2,%ecx
  800ac7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800acc:	eb c4                	jmp    800a92 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ace:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad1:	89 f3                	mov    %esi,%ebx
  800ad3:	80 fb 19             	cmp    $0x19,%bl
  800ad6:	77 29                	ja     800b01 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ad8:	0f be d2             	movsbl %dl,%edx
  800adb:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ade:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ae1:	7d 30                	jge    800b13 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ae3:	83 c1 01             	add    $0x1,%ecx
  800ae6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aea:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800aec:	0f b6 11             	movzbl (%ecx),%edx
  800aef:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af2:	89 f3                	mov    %esi,%ebx
  800af4:	80 fb 09             	cmp    $0x9,%bl
  800af7:	77 d5                	ja     800ace <strtol+0x80>
			dig = *s - '0';
  800af9:	0f be d2             	movsbl %dl,%edx
  800afc:	83 ea 30             	sub    $0x30,%edx
  800aff:	eb dd                	jmp    800ade <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b01:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b04:	89 f3                	mov    %esi,%ebx
  800b06:	80 fb 19             	cmp    $0x19,%bl
  800b09:	77 08                	ja     800b13 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b0b:	0f be d2             	movsbl %dl,%edx
  800b0e:	83 ea 37             	sub    $0x37,%edx
  800b11:	eb cb                	jmp    800ade <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b13:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b17:	74 05                	je     800b1e <strtol+0xd0>
		*endptr = (char *) s;
  800b19:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b1e:	89 c2                	mov    %eax,%edx
  800b20:	f7 da                	neg    %edx
  800b22:	85 ff                	test   %edi,%edi
  800b24:	0f 45 c2             	cmovne %edx,%eax
}
  800b27:	5b                   	pop    %ebx
  800b28:	5e                   	pop    %esi
  800b29:	5f                   	pop    %edi
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b32:	b8 00 00 00 00       	mov    $0x0,%eax
  800b37:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3d:	89 c3                	mov    %eax,%ebx
  800b3f:	89 c7                	mov    %eax,%edi
  800b41:	89 c6                	mov    %eax,%esi
  800b43:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b50:	ba 00 00 00 00       	mov    $0x0,%edx
  800b55:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5a:	89 d1                	mov    %edx,%ecx
  800b5c:	89 d3                	mov    %edx,%ebx
  800b5e:	89 d7                	mov    %edx,%edi
  800b60:	89 d6                	mov    %edx,%esi
  800b62:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
  800b6f:	83 ec 1c             	sub    $0x1c,%esp
  800b72:	e8 66 00 00 00       	call   800bdd <__x86.get_pc_thunk.ax>
  800b77:	05 89 14 00 00       	add    $0x1489,%eax
  800b7c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b7f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	b8 03 00 00 00       	mov    $0x3,%eax
  800b8c:	89 cb                	mov    %ecx,%ebx
  800b8e:	89 cf                	mov    %ecx,%edi
  800b90:	89 ce                	mov    %ecx,%esi
  800b92:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b94:	85 c0                	test   %eax,%eax
  800b96:	7f 08                	jg     800ba0 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5f                   	pop    %edi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba0:	83 ec 0c             	sub    $0xc,%esp
  800ba3:	50                   	push   %eax
  800ba4:	6a 03                	push   $0x3
  800ba6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800ba9:	8d 83 7c f0 ff ff    	lea    -0xf84(%ebx),%eax
  800baf:	50                   	push   %eax
  800bb0:	6a 23                	push   $0x23
  800bb2:	8d 83 99 f0 ff ff    	lea    -0xf67(%ebx),%eax
  800bb8:	50                   	push   %eax
  800bb9:	e8 23 00 00 00       	call   800be1 <_panic>

00800bbe <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc9:	b8 02 00 00 00       	mov    $0x2,%eax
  800bce:	89 d1                	mov    %edx,%ecx
  800bd0:	89 d3                	mov    %edx,%ebx
  800bd2:	89 d7                	mov    %edx,%edi
  800bd4:	89 d6                	mov    %edx,%esi
  800bd6:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <__x86.get_pc_thunk.ax>:
  800bdd:	8b 04 24             	mov    (%esp),%eax
  800be0:	c3                   	ret    

00800be1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	83 ec 0c             	sub    $0xc,%esp
  800bea:	e8 84 f4 ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800bef:	81 c3 11 14 00 00    	add    $0x1411,%ebx
	va_list ap;

	va_start(ap, fmt);
  800bf5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800bf8:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800bfe:	8b 38                	mov    (%eax),%edi
  800c00:	e8 b9 ff ff ff       	call   800bbe <sys_getenvid>
  800c05:	83 ec 0c             	sub    $0xc,%esp
  800c08:	ff 75 0c             	pushl  0xc(%ebp)
  800c0b:	ff 75 08             	pushl  0x8(%ebp)
  800c0e:	57                   	push   %edi
  800c0f:	50                   	push   %eax
  800c10:	8d 83 a8 f0 ff ff    	lea    -0xf58(%ebx),%eax
  800c16:	50                   	push   %eax
  800c17:	e8 74 f5 ff ff       	call   800190 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c1c:	83 c4 18             	add    $0x18,%esp
  800c1f:	56                   	push   %esi
  800c20:	ff 75 10             	pushl  0x10(%ebp)
  800c23:	e8 06 f5 ff ff       	call   80012e <vcprintf>
	cprintf("\n");
  800c28:	8d 83 88 ee ff ff    	lea    -0x1178(%ebx),%eax
  800c2e:	89 04 24             	mov    %eax,(%esp)
  800c31:	e8 5a f5 ff ff       	call   800190 <cprintf>
  800c36:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c39:	cc                   	int3   
  800c3a:	eb fd                	jmp    800c39 <_panic+0x58>
  800c3c:	66 90                	xchg   %ax,%ax
  800c3e:	66 90                	xchg   %ax,%ax

00800c40 <__udivdi3>:
  800c40:	55                   	push   %ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 1c             	sub    $0x1c,%esp
  800c47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c4b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c53:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c57:	85 d2                	test   %edx,%edx
  800c59:	75 35                	jne    800c90 <__udivdi3+0x50>
  800c5b:	39 f3                	cmp    %esi,%ebx
  800c5d:	0f 87 bd 00 00 00    	ja     800d20 <__udivdi3+0xe0>
  800c63:	85 db                	test   %ebx,%ebx
  800c65:	89 d9                	mov    %ebx,%ecx
  800c67:	75 0b                	jne    800c74 <__udivdi3+0x34>
  800c69:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6e:	31 d2                	xor    %edx,%edx
  800c70:	f7 f3                	div    %ebx
  800c72:	89 c1                	mov    %eax,%ecx
  800c74:	31 d2                	xor    %edx,%edx
  800c76:	89 f0                	mov    %esi,%eax
  800c78:	f7 f1                	div    %ecx
  800c7a:	89 c6                	mov    %eax,%esi
  800c7c:	89 e8                	mov    %ebp,%eax
  800c7e:	89 f7                	mov    %esi,%edi
  800c80:	f7 f1                	div    %ecx
  800c82:	89 fa                	mov    %edi,%edx
  800c84:	83 c4 1c             	add    $0x1c,%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    
  800c8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c90:	39 f2                	cmp    %esi,%edx
  800c92:	77 7c                	ja     800d10 <__udivdi3+0xd0>
  800c94:	0f bd fa             	bsr    %edx,%edi
  800c97:	83 f7 1f             	xor    $0x1f,%edi
  800c9a:	0f 84 98 00 00 00    	je     800d38 <__udivdi3+0xf8>
  800ca0:	89 f9                	mov    %edi,%ecx
  800ca2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ca7:	29 f8                	sub    %edi,%eax
  800ca9:	d3 e2                	shl    %cl,%edx
  800cab:	89 54 24 08          	mov    %edx,0x8(%esp)
  800caf:	89 c1                	mov    %eax,%ecx
  800cb1:	89 da                	mov    %ebx,%edx
  800cb3:	d3 ea                	shr    %cl,%edx
  800cb5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cb9:	09 d1                	or     %edx,%ecx
  800cbb:	89 f2                	mov    %esi,%edx
  800cbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cc1:	89 f9                	mov    %edi,%ecx
  800cc3:	d3 e3                	shl    %cl,%ebx
  800cc5:	89 c1                	mov    %eax,%ecx
  800cc7:	d3 ea                	shr    %cl,%edx
  800cc9:	89 f9                	mov    %edi,%ecx
  800ccb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ccf:	d3 e6                	shl    %cl,%esi
  800cd1:	89 eb                	mov    %ebp,%ebx
  800cd3:	89 c1                	mov    %eax,%ecx
  800cd5:	d3 eb                	shr    %cl,%ebx
  800cd7:	09 de                	or     %ebx,%esi
  800cd9:	89 f0                	mov    %esi,%eax
  800cdb:	f7 74 24 08          	divl   0x8(%esp)
  800cdf:	89 d6                	mov    %edx,%esi
  800ce1:	89 c3                	mov    %eax,%ebx
  800ce3:	f7 64 24 0c          	mull   0xc(%esp)
  800ce7:	39 d6                	cmp    %edx,%esi
  800ce9:	72 0c                	jb     800cf7 <__udivdi3+0xb7>
  800ceb:	89 f9                	mov    %edi,%ecx
  800ced:	d3 e5                	shl    %cl,%ebp
  800cef:	39 c5                	cmp    %eax,%ebp
  800cf1:	73 5d                	jae    800d50 <__udivdi3+0x110>
  800cf3:	39 d6                	cmp    %edx,%esi
  800cf5:	75 59                	jne    800d50 <__udivdi3+0x110>
  800cf7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cfa:	31 ff                	xor    %edi,%edi
  800cfc:	89 fa                	mov    %edi,%edx
  800cfe:	83 c4 1c             	add    $0x1c,%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    
  800d06:	8d 76 00             	lea    0x0(%esi),%esi
  800d09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d10:	31 ff                	xor    %edi,%edi
  800d12:	31 c0                	xor    %eax,%eax
  800d14:	89 fa                	mov    %edi,%edx
  800d16:	83 c4 1c             	add    $0x1c,%esp
  800d19:	5b                   	pop    %ebx
  800d1a:	5e                   	pop    %esi
  800d1b:	5f                   	pop    %edi
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    
  800d1e:	66 90                	xchg   %ax,%ax
  800d20:	31 ff                	xor    %edi,%edi
  800d22:	89 e8                	mov    %ebp,%eax
  800d24:	89 f2                	mov    %esi,%edx
  800d26:	f7 f3                	div    %ebx
  800d28:	89 fa                	mov    %edi,%edx
  800d2a:	83 c4 1c             	add    $0x1c,%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    
  800d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d38:	39 f2                	cmp    %esi,%edx
  800d3a:	72 06                	jb     800d42 <__udivdi3+0x102>
  800d3c:	31 c0                	xor    %eax,%eax
  800d3e:	39 eb                	cmp    %ebp,%ebx
  800d40:	77 d2                	ja     800d14 <__udivdi3+0xd4>
  800d42:	b8 01 00 00 00       	mov    $0x1,%eax
  800d47:	eb cb                	jmp    800d14 <__udivdi3+0xd4>
  800d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d50:	89 d8                	mov    %ebx,%eax
  800d52:	31 ff                	xor    %edi,%edi
  800d54:	eb be                	jmp    800d14 <__udivdi3+0xd4>
  800d56:	66 90                	xchg   %ax,%ax
  800d58:	66 90                	xchg   %ax,%ax
  800d5a:	66 90                	xchg   %ax,%ax
  800d5c:	66 90                	xchg   %ax,%ax
  800d5e:	66 90                	xchg   %ax,%ax

00800d60 <__umoddi3>:
  800d60:	55                   	push   %ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 1c             	sub    $0x1c,%esp
  800d67:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d6b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d6f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d77:	85 ed                	test   %ebp,%ebp
  800d79:	89 f0                	mov    %esi,%eax
  800d7b:	89 da                	mov    %ebx,%edx
  800d7d:	75 19                	jne    800d98 <__umoddi3+0x38>
  800d7f:	39 df                	cmp    %ebx,%edi
  800d81:	0f 86 b1 00 00 00    	jbe    800e38 <__umoddi3+0xd8>
  800d87:	f7 f7                	div    %edi
  800d89:	89 d0                	mov    %edx,%eax
  800d8b:	31 d2                	xor    %edx,%edx
  800d8d:	83 c4 1c             	add    $0x1c,%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    
  800d95:	8d 76 00             	lea    0x0(%esi),%esi
  800d98:	39 dd                	cmp    %ebx,%ebp
  800d9a:	77 f1                	ja     800d8d <__umoddi3+0x2d>
  800d9c:	0f bd cd             	bsr    %ebp,%ecx
  800d9f:	83 f1 1f             	xor    $0x1f,%ecx
  800da2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800da6:	0f 84 b4 00 00 00    	je     800e60 <__umoddi3+0x100>
  800dac:	b8 20 00 00 00       	mov    $0x20,%eax
  800db1:	89 c2                	mov    %eax,%edx
  800db3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800db7:	29 c2                	sub    %eax,%edx
  800db9:	89 c1                	mov    %eax,%ecx
  800dbb:	89 f8                	mov    %edi,%eax
  800dbd:	d3 e5                	shl    %cl,%ebp
  800dbf:	89 d1                	mov    %edx,%ecx
  800dc1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800dc5:	d3 e8                	shr    %cl,%eax
  800dc7:	09 c5                	or     %eax,%ebp
  800dc9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dcd:	89 c1                	mov    %eax,%ecx
  800dcf:	d3 e7                	shl    %cl,%edi
  800dd1:	89 d1                	mov    %edx,%ecx
  800dd3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dd7:	89 df                	mov    %ebx,%edi
  800dd9:	d3 ef                	shr    %cl,%edi
  800ddb:	89 c1                	mov    %eax,%ecx
  800ddd:	89 f0                	mov    %esi,%eax
  800ddf:	d3 e3                	shl    %cl,%ebx
  800de1:	89 d1                	mov    %edx,%ecx
  800de3:	89 fa                	mov    %edi,%edx
  800de5:	d3 e8                	shr    %cl,%eax
  800de7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800dec:	09 d8                	or     %ebx,%eax
  800dee:	f7 f5                	div    %ebp
  800df0:	d3 e6                	shl    %cl,%esi
  800df2:	89 d1                	mov    %edx,%ecx
  800df4:	f7 64 24 08          	mull   0x8(%esp)
  800df8:	39 d1                	cmp    %edx,%ecx
  800dfa:	89 c3                	mov    %eax,%ebx
  800dfc:	89 d7                	mov    %edx,%edi
  800dfe:	72 06                	jb     800e06 <__umoddi3+0xa6>
  800e00:	75 0e                	jne    800e10 <__umoddi3+0xb0>
  800e02:	39 c6                	cmp    %eax,%esi
  800e04:	73 0a                	jae    800e10 <__umoddi3+0xb0>
  800e06:	2b 44 24 08          	sub    0x8(%esp),%eax
  800e0a:	19 ea                	sbb    %ebp,%edx
  800e0c:	89 d7                	mov    %edx,%edi
  800e0e:	89 c3                	mov    %eax,%ebx
  800e10:	89 ca                	mov    %ecx,%edx
  800e12:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e17:	29 de                	sub    %ebx,%esi
  800e19:	19 fa                	sbb    %edi,%edx
  800e1b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e1f:	89 d0                	mov    %edx,%eax
  800e21:	d3 e0                	shl    %cl,%eax
  800e23:	89 d9                	mov    %ebx,%ecx
  800e25:	d3 ee                	shr    %cl,%esi
  800e27:	d3 ea                	shr    %cl,%edx
  800e29:	09 f0                	or     %esi,%eax
  800e2b:	83 c4 1c             	add    $0x1c,%esp
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    
  800e33:	90                   	nop
  800e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e38:	85 ff                	test   %edi,%edi
  800e3a:	89 f9                	mov    %edi,%ecx
  800e3c:	75 0b                	jne    800e49 <__umoddi3+0xe9>
  800e3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e43:	31 d2                	xor    %edx,%edx
  800e45:	f7 f7                	div    %edi
  800e47:	89 c1                	mov    %eax,%ecx
  800e49:	89 d8                	mov    %ebx,%eax
  800e4b:	31 d2                	xor    %edx,%edx
  800e4d:	f7 f1                	div    %ecx
  800e4f:	89 f0                	mov    %esi,%eax
  800e51:	f7 f1                	div    %ecx
  800e53:	e9 31 ff ff ff       	jmp    800d89 <__umoddi3+0x29>
  800e58:	90                   	nop
  800e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e60:	39 dd                	cmp    %ebx,%ebp
  800e62:	72 08                	jb     800e6c <__umoddi3+0x10c>
  800e64:	39 f7                	cmp    %esi,%edi
  800e66:	0f 87 21 ff ff ff    	ja     800d8d <__umoddi3+0x2d>
  800e6c:	89 da                	mov    %ebx,%edx
  800e6e:	89 f0                	mov    %esi,%eax
  800e70:	29 f8                	sub    %edi,%eax
  800e72:	19 ea                	sbb    %ebp,%edx
  800e74:	e9 14 ff ff ff       	jmp    800d8d <__umoddi3+0x2d>
