
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
  800045:	c7 c0 44 20 80 00    	mov    $0x802044,%eax
  80004b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	cprintf("1/0 is %08x!\n", 1/zero);
  800051:	b8 01 00 00 00       	mov    $0x1,%eax
  800056:	b9 00 00 00 00       	mov    $0x0,%ecx
  80005b:	99                   	cltd   
  80005c:	f7 f9                	idiv   %ecx
  80005e:	50                   	push   %eax
  80005f:	8d 83 dc f0 ff ff    	lea    -0xf24(%ebx),%eax
  800065:	50                   	push   %eax
  800066:	e8 39 01 00 00       	call   8001a4 <cprintf>
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

void libmain(int argc, char **argv)
{
  800077:	55                   	push   %ebp
  800078:	89 e5                	mov    %esp,%ebp
  80007a:	57                   	push   %edi
  80007b:	56                   	push   %esi
  80007c:	53                   	push   %ebx
  80007d:	83 ec 0c             	sub    $0xc,%esp
  800080:	e8 ee ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800085:	81 c3 7b 1f 00 00    	add    $0x1f7b,%ebx
  80008b:	8b 75 08             	mov    0x8(%ebp),%esi
  80008e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())]; // ENVX()得到id在Env[]数组中对应的下标
  800091:	e8 3c 0b 00 00       	call   800bd2 <sys_getenvid>
  800096:	25 ff 03 00 00       	and    $0x3ff,%eax
  80009b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80009e:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  8000a4:	c7 c2 48 20 80 00    	mov    $0x802048,%edx
  8000aa:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ac:	85 f6                	test   %esi,%esi
  8000ae:	7e 08                	jle    8000b8 <libmain+0x41>
		binaryname = argv[0];
  8000b0:	8b 07                	mov    (%edi),%eax
  8000b2:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000b8:	83 ec 08             	sub    $0x8,%esp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	e8 71 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000c2:	e8 0b 00 00 00       	call   8000d2 <exit>
}
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
  8000d9:	e8 95 ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  8000de:	81 c3 22 1f 00 00    	add    $0x1f22,%ebx
	sys_env_destroy(0);
  8000e4:	6a 00                	push   $0x0
  8000e6:	e8 92 0a 00 00       	call   800b7d <sys_env_destroy>
}
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f1:	c9                   	leave  
  8000f2:	c3                   	ret    

008000f3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
  8000f8:	e8 76 ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  8000fd:	81 c3 03 1f 00 00    	add    $0x1f03,%ebx
  800103:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  800106:	8b 16                	mov    (%esi),%edx
  800108:	8d 42 01             	lea    0x1(%edx),%eax
  80010b:	89 06                	mov    %eax,(%esi)
  80010d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800110:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800114:	3d ff 00 00 00       	cmp    $0xff,%eax
  800119:	74 0b                	je     800126 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80011b:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80011f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800126:	83 ec 08             	sub    $0x8,%esp
  800129:	68 ff 00 00 00       	push   $0xff
  80012e:	8d 46 08             	lea    0x8(%esi),%eax
  800131:	50                   	push   %eax
  800132:	e8 09 0a 00 00       	call   800b40 <sys_cputs>
		b->idx = 0;
  800137:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80013d:	83 c4 10             	add    $0x10,%esp
  800140:	eb d9                	jmp    80011b <putch+0x28>

00800142 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800142:	55                   	push   %ebp
  800143:	89 e5                	mov    %esp,%ebp
  800145:	53                   	push   %ebx
  800146:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80014c:	e8 22 ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800151:	81 c3 af 1e 00 00    	add    $0x1eaf,%ebx
	struct printbuf b;

	b.idx = 0;
  800157:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015e:	00 00 00 
	b.cnt = 0;
  800161:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800168:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016b:	ff 75 0c             	pushl  0xc(%ebp)
  80016e:	ff 75 08             	pushl  0x8(%ebp)
  800171:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800177:	50                   	push   %eax
  800178:	8d 83 f3 e0 ff ff    	lea    -0x1f0d(%ebx),%eax
  80017e:	50                   	push   %eax
  80017f:	e8 38 01 00 00       	call   8002bc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800184:	83 c4 08             	add    $0x8,%esp
  800187:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80018d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800193:	50                   	push   %eax
  800194:	e8 a7 09 00 00       	call   800b40 <sys_cputs>

	return b.cnt;
}
  800199:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80019f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001aa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ad:	50                   	push   %eax
  8001ae:	ff 75 08             	pushl  0x8(%ebp)
  8001b1:	e8 8c ff ff ff       	call   800142 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b6:	c9                   	leave  
  8001b7:	c3                   	ret    

008001b8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	57                   	push   %edi
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	83 ec 2c             	sub    $0x2c,%esp
  8001c1:	e8 02 06 00 00       	call   8007c8 <__x86.get_pc_thunk.cx>
  8001c6:	81 c1 3a 1e 00 00    	add    $0x1e3a,%ecx
  8001cc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001cf:	89 c7                	mov    %eax,%edi
  8001d1:	89 d6                	mov    %edx,%esi
  8001d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001dc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  8001df:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e7:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8001ea:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8001ed:	39 d3                	cmp    %edx,%ebx
  8001ef:	72 09                	jb     8001fa <printnum+0x42>
  8001f1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f4:	0f 87 83 00 00 00    	ja     80027d <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fa:	83 ec 0c             	sub    $0xc,%esp
  8001fd:	ff 75 18             	pushl  0x18(%ebp)
  800200:	8b 45 14             	mov    0x14(%ebp),%eax
  800203:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800206:	53                   	push   %ebx
  800207:	ff 75 10             	pushl  0x10(%ebp)
  80020a:	83 ec 08             	sub    $0x8,%esp
  80020d:	ff 75 dc             	pushl  -0x24(%ebp)
  800210:	ff 75 d8             	pushl  -0x28(%ebp)
  800213:	ff 75 d4             	pushl  -0x2c(%ebp)
  800216:	ff 75 d0             	pushl  -0x30(%ebp)
  800219:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80021c:	e8 7f 0c 00 00       	call   800ea0 <__udivdi3>
  800221:	83 c4 18             	add    $0x18,%esp
  800224:	52                   	push   %edx
  800225:	50                   	push   %eax
  800226:	89 f2                	mov    %esi,%edx
  800228:	89 f8                	mov    %edi,%eax
  80022a:	e8 89 ff ff ff       	call   8001b8 <printnum>
  80022f:	83 c4 20             	add    $0x20,%esp
  800232:	eb 13                	jmp    800247 <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800234:	83 ec 08             	sub    $0x8,%esp
  800237:	56                   	push   %esi
  800238:	ff 75 18             	pushl  0x18(%ebp)
  80023b:	ff d7                	call   *%edi
  80023d:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800240:	83 eb 01             	sub    $0x1,%ebx
  800243:	85 db                	test   %ebx,%ebx
  800245:	7f ed                	jg     800234 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	83 ec 04             	sub    $0x4,%esp
  80024e:	ff 75 dc             	pushl  -0x24(%ebp)
  800251:	ff 75 d8             	pushl  -0x28(%ebp)
  800254:	ff 75 d4             	pushl  -0x2c(%ebp)
  800257:	ff 75 d0             	pushl  -0x30(%ebp)
  80025a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80025d:	89 f3                	mov    %esi,%ebx
  80025f:	e8 5c 0d 00 00       	call   800fc0 <__umoddi3>
  800264:	83 c4 14             	add    $0x14,%esp
  800267:	0f be 84 06 f4 f0 ff 	movsbl -0xf0c(%esi,%eax,1),%eax
  80026e:	ff 
  80026f:	50                   	push   %eax
  800270:	ff d7                	call   *%edi
}
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800278:	5b                   	pop    %ebx
  800279:	5e                   	pop    %esi
  80027a:	5f                   	pop    %edi
  80027b:	5d                   	pop    %ebp
  80027c:	c3                   	ret    
  80027d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800280:	eb be                	jmp    800240 <printnum+0x88>

00800282 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800288:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80028c:	8b 10                	mov    (%eax),%edx
  80028e:	3b 50 04             	cmp    0x4(%eax),%edx
  800291:	73 0a                	jae    80029d <sprintputch+0x1b>
		*b->buf++ = ch;
  800293:	8d 4a 01             	lea    0x1(%edx),%ecx
  800296:	89 08                	mov    %ecx,(%eax)
  800298:	8b 45 08             	mov    0x8(%ebp),%eax
  80029b:	88 02                	mov    %al,(%edx)
}
  80029d:	5d                   	pop    %ebp
  80029e:	c3                   	ret    

0080029f <printfmt>:
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002a5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a8:	50                   	push   %eax
  8002a9:	ff 75 10             	pushl  0x10(%ebp)
  8002ac:	ff 75 0c             	pushl  0xc(%ebp)
  8002af:	ff 75 08             	pushl  0x8(%ebp)
  8002b2:	e8 05 00 00 00       	call   8002bc <vprintfmt>
}
  8002b7:	83 c4 10             	add    $0x10,%esp
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    

008002bc <vprintfmt>:
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 2c             	sub    $0x2c,%esp
  8002c5:	e8 a9 fd ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  8002ca:	81 c3 36 1d 00 00    	add    $0x1d36,%ebx
  8002d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002d3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d6:	e9 c3 03 00 00       	jmp    80069e <.L35+0x48>
		padc = ' ';
  8002db:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002df:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002e6:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8002ed:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f9:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8002fc:	8d 47 01             	lea    0x1(%edi),%eax
  8002ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800302:	0f b6 17             	movzbl (%edi),%edx
  800305:	8d 42 dd             	lea    -0x23(%edx),%eax
  800308:	3c 55                	cmp    $0x55,%al
  80030a:	0f 87 16 04 00 00    	ja     800726 <.L22>
  800310:	0f b6 c0             	movzbl %al,%eax
  800313:	89 d9                	mov    %ebx,%ecx
  800315:	03 8c 83 ac f1 ff ff 	add    -0xe54(%ebx,%eax,4),%ecx
  80031c:	ff e1                	jmp    *%ecx

0080031e <.L69>:
  80031e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800321:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800325:	eb d5                	jmp    8002fc <vprintfmt+0x40>

00800327 <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800327:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80032a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80032e:	eb cc                	jmp    8002fc <vprintfmt+0x40>

00800330 <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800330:	0f b6 d2             	movzbl %dl,%edx
  800333:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
  800336:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  80033b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800342:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800345:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800348:	83 f9 09             	cmp    $0x9,%ecx
  80034b:	77 55                	ja     8003a2 <.L23+0xf>
			for (precision = 0;; ++fmt)
  80034d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800350:	eb e9                	jmp    80033b <.L29+0xb>

00800352 <.L26>:
			precision = va_arg(ap, int);
  800352:	8b 45 14             	mov    0x14(%ebp),%eax
  800355:	8b 00                	mov    (%eax),%eax
  800357:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80035a:	8b 45 14             	mov    0x14(%ebp),%eax
  80035d:	8d 40 04             	lea    0x4(%eax),%eax
  800360:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800363:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800366:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036a:	79 90                	jns    8002fc <vprintfmt+0x40>
				width = precision, precision = -1;
  80036c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80036f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800372:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800379:	eb 81                	jmp    8002fc <vprintfmt+0x40>

0080037b <.L27>:
  80037b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037e:	85 c0                	test   %eax,%eax
  800380:	ba 00 00 00 00       	mov    $0x0,%edx
  800385:	0f 49 d0             	cmovns %eax,%edx
  800388:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80038b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038e:	e9 69 ff ff ff       	jmp    8002fc <vprintfmt+0x40>

00800393 <.L23>:
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800396:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80039d:	e9 5a ff ff ff       	jmp    8002fc <vprintfmt+0x40>
  8003a2:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003a5:	eb bf                	jmp    800366 <.L26+0x14>

008003a7 <.L33>:
			lflag++;
  8003a7:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8003ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ae:	e9 49 ff ff ff       	jmp    8002fc <vprintfmt+0x40>

008003b3 <.L30>:
			putch(va_arg(ap, int), putdat);
  8003b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b6:	8d 78 04             	lea    0x4(%eax),%edi
  8003b9:	83 ec 08             	sub    $0x8,%esp
  8003bc:	56                   	push   %esi
  8003bd:	ff 30                	pushl  (%eax)
  8003bf:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003c2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003c5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003c8:	e9 ce 02 00 00       	jmp    80069b <.L35+0x45>

008003cd <.L32>:
			err = va_arg(ap, int);
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8d 78 04             	lea    0x4(%eax),%edi
  8003d3:	8b 00                	mov    (%eax),%eax
  8003d5:	99                   	cltd   
  8003d6:	31 d0                	xor    %edx,%eax
  8003d8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003da:	83 f8 08             	cmp    $0x8,%eax
  8003dd:	7f 27                	jg     800406 <.L32+0x39>
  8003df:	8b 94 83 20 00 00 00 	mov    0x20(%ebx,%eax,4),%edx
  8003e6:	85 d2                	test   %edx,%edx
  8003e8:	74 1c                	je     800406 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8003ea:	52                   	push   %edx
  8003eb:	8d 83 15 f1 ff ff    	lea    -0xeeb(%ebx),%eax
  8003f1:	50                   	push   %eax
  8003f2:	56                   	push   %esi
  8003f3:	ff 75 08             	pushl  0x8(%ebp)
  8003f6:	e8 a4 fe ff ff       	call   80029f <printfmt>
  8003fb:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003fe:	89 7d 14             	mov    %edi,0x14(%ebp)
  800401:	e9 95 02 00 00       	jmp    80069b <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  800406:	50                   	push   %eax
  800407:	8d 83 0c f1 ff ff    	lea    -0xef4(%ebx),%eax
  80040d:	50                   	push   %eax
  80040e:	56                   	push   %esi
  80040f:	ff 75 08             	pushl  0x8(%ebp)
  800412:	e8 88 fe ff ff       	call   80029f <printfmt>
  800417:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80041a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80041d:	e9 79 02 00 00       	jmp    80069b <.L35+0x45>

00800422 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800422:	8b 45 14             	mov    0x14(%ebp),%eax
  800425:	83 c0 04             	add    $0x4,%eax
  800428:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80042b:	8b 45 14             	mov    0x14(%ebp),%eax
  80042e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800430:	85 ff                	test   %edi,%edi
  800432:	8d 83 05 f1 ff ff    	lea    -0xefb(%ebx),%eax
  800438:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80043b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043f:	0f 8e b5 00 00 00    	jle    8004fa <.L36+0xd8>
  800445:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800449:	75 08                	jne    800453 <.L36+0x31>
  80044b:	89 75 0c             	mov    %esi,0xc(%ebp)
  80044e:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800451:	eb 6d                	jmp    8004c0 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800453:	83 ec 08             	sub    $0x8,%esp
  800456:	ff 75 cc             	pushl  -0x34(%ebp)
  800459:	57                   	push   %edi
  80045a:	e8 85 03 00 00       	call   8007e4 <strnlen>
  80045f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800462:	29 c2                	sub    %eax,%edx
  800464:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800467:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80046a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80046e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800471:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800474:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800476:	eb 10                	jmp    800488 <.L36+0x66>
					putch(padc, putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	56                   	push   %esi
  80047c:	ff 75 e0             	pushl  -0x20(%ebp)
  80047f:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800482:	83 ef 01             	sub    $0x1,%edi
  800485:	83 c4 10             	add    $0x10,%esp
  800488:	85 ff                	test   %edi,%edi
  80048a:	7f ec                	jg     800478 <.L36+0x56>
  80048c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80048f:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800492:	85 d2                	test   %edx,%edx
  800494:	b8 00 00 00 00       	mov    $0x0,%eax
  800499:	0f 49 c2             	cmovns %edx,%eax
  80049c:	29 c2                	sub    %eax,%edx
  80049e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004a1:	89 75 0c             	mov    %esi,0xc(%ebp)
  8004a4:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004a7:	eb 17                	jmp    8004c0 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004a9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ad:	75 30                	jne    8004df <.L36+0xbd>
					putch(ch, putdat);
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	ff 75 0c             	pushl  0xc(%ebp)
  8004b5:	50                   	push   %eax
  8004b6:	ff 55 08             	call   *0x8(%ebp)
  8004b9:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004bc:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8004c0:	83 c7 01             	add    $0x1,%edi
  8004c3:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004c7:	0f be c2             	movsbl %dl,%eax
  8004ca:	85 c0                	test   %eax,%eax
  8004cc:	74 52                	je     800520 <.L36+0xfe>
  8004ce:	85 f6                	test   %esi,%esi
  8004d0:	78 d7                	js     8004a9 <.L36+0x87>
  8004d2:	83 ee 01             	sub    $0x1,%esi
  8004d5:	79 d2                	jns    8004a9 <.L36+0x87>
  8004d7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004da:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004dd:	eb 32                	jmp    800511 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8004df:	0f be d2             	movsbl %dl,%edx
  8004e2:	83 ea 20             	sub    $0x20,%edx
  8004e5:	83 fa 5e             	cmp    $0x5e,%edx
  8004e8:	76 c5                	jbe    8004af <.L36+0x8d>
					putch('?', putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	ff 75 0c             	pushl  0xc(%ebp)
  8004f0:	6a 3f                	push   $0x3f
  8004f2:	ff 55 08             	call   *0x8(%ebp)
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	eb c2                	jmp    8004bc <.L36+0x9a>
  8004fa:	89 75 0c             	mov    %esi,0xc(%ebp)
  8004fd:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800500:	eb be                	jmp    8004c0 <.L36+0x9e>
				putch(' ', putdat);
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	56                   	push   %esi
  800506:	6a 20                	push   $0x20
  800508:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  80050b:	83 ef 01             	sub    $0x1,%edi
  80050e:	83 c4 10             	add    $0x10,%esp
  800511:	85 ff                	test   %edi,%edi
  800513:	7f ed                	jg     800502 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800515:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800518:	89 45 14             	mov    %eax,0x14(%ebp)
  80051b:	e9 7b 01 00 00       	jmp    80069b <.L35+0x45>
  800520:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800523:	8b 75 0c             	mov    0xc(%ebp),%esi
  800526:	eb e9                	jmp    800511 <.L36+0xef>

00800528 <.L31>:
  800528:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80052b:	83 f9 01             	cmp    $0x1,%ecx
  80052e:	7e 40                	jle    800570 <.L31+0x48>
		return va_arg(*ap, long long);
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8b 50 04             	mov    0x4(%eax),%edx
  800536:	8b 00                	mov    (%eax),%eax
  800538:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053e:	8b 45 14             	mov    0x14(%ebp),%eax
  800541:	8d 40 08             	lea    0x8(%eax),%eax
  800544:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
  800547:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80054b:	79 55                	jns    8005a2 <.L31+0x7a>
				putch('-', putdat);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	56                   	push   %esi
  800551:	6a 2d                	push   $0x2d
  800553:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  800556:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800559:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80055c:	f7 da                	neg    %edx
  80055e:	83 d1 00             	adc    $0x0,%ecx
  800561:	f7 d9                	neg    %ecx
  800563:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
  800566:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056b:	e9 10 01 00 00       	jmp    800680 <.L35+0x2a>
	else if (lflag)
  800570:	85 c9                	test   %ecx,%ecx
  800572:	75 17                	jne    80058b <.L31+0x63>
		return va_arg(*ap, int);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8b 00                	mov    (%eax),%eax
  800579:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057c:	99                   	cltd   
  80057d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8d 40 04             	lea    0x4(%eax),%eax
  800586:	89 45 14             	mov    %eax,0x14(%ebp)
  800589:	eb bc                	jmp    800547 <.L31+0x1f>
		return va_arg(*ap, long);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8b 00                	mov    (%eax),%eax
  800590:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800593:	99                   	cltd   
  800594:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8d 40 04             	lea    0x4(%eax),%eax
  80059d:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a0:	eb a5                	jmp    800547 <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  8005a2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
  8005a8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ad:	e9 ce 00 00 00       	jmp    800680 <.L35+0x2a>

008005b2 <.L37>:
  8005b2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8005b5:	83 f9 01             	cmp    $0x1,%ecx
  8005b8:	7e 18                	jle    8005d2 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8005ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bd:	8b 10                	mov    (%eax),%edx
  8005bf:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c2:	8d 40 08             	lea    0x8(%eax),%eax
  8005c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cd:	e9 ae 00 00 00       	jmp    800680 <.L35+0x2a>
	else if (lflag)
  8005d2:	85 c9                	test   %ecx,%ecx
  8005d4:	75 1a                	jne    8005f0 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8b 10                	mov    (%eax),%edx
  8005db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e0:	8d 40 04             	lea    0x4(%eax),%eax
  8005e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005eb:	e9 90 00 00 00       	jmp    800680 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	8b 10                	mov    (%eax),%edx
  8005f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fa:	8d 40 04             	lea    0x4(%eax),%eax
  8005fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800600:	b8 0a 00 00 00       	mov    $0xa,%eax
  800605:	eb 79                	jmp    800680 <.L35+0x2a>

00800607 <.L34>:
  800607:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80060a:	83 f9 01             	cmp    $0x1,%ecx
  80060d:	7e 15                	jle    800624 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8b 10                	mov    (%eax),%edx
  800614:	8b 48 04             	mov    0x4(%eax),%ecx
  800617:	8d 40 08             	lea    0x8(%eax),%eax
  80061a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80061d:	b8 08 00 00 00       	mov    $0x8,%eax
  800622:	eb 5c                	jmp    800680 <.L35+0x2a>
	else if (lflag)
  800624:	85 c9                	test   %ecx,%ecx
  800626:	75 17                	jne    80063f <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8b 10                	mov    (%eax),%edx
  80062d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800632:	8d 40 04             	lea    0x4(%eax),%eax
  800635:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800638:	b8 08 00 00 00       	mov    $0x8,%eax
  80063d:	eb 41                	jmp    800680 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8b 10                	mov    (%eax),%edx
  800644:	b9 00 00 00 00       	mov    $0x0,%ecx
  800649:	8d 40 04             	lea    0x4(%eax),%eax
  80064c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80064f:	b8 08 00 00 00       	mov    $0x8,%eax
  800654:	eb 2a                	jmp    800680 <.L35+0x2a>

00800656 <.L35>:
			putch('0', putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	56                   	push   %esi
  80065a:	6a 30                	push   $0x30
  80065c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80065f:	83 c4 08             	add    $0x8,%esp
  800662:	56                   	push   %esi
  800663:	6a 78                	push   $0x78
  800665:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8b 10                	mov    (%eax),%edx
  80066d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800672:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800675:	8d 40 04             	lea    0x4(%eax),%eax
  800678:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067b:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  800680:	83 ec 0c             	sub    $0xc,%esp
  800683:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800687:	57                   	push   %edi
  800688:	ff 75 e0             	pushl  -0x20(%ebp)
  80068b:	50                   	push   %eax
  80068c:	51                   	push   %ecx
  80068d:	52                   	push   %edx
  80068e:	89 f2                	mov    %esi,%edx
  800690:	8b 45 08             	mov    0x8(%ebp),%eax
  800693:	e8 20 fb ff ff       	call   8001b8 <printnum>
			break;
  800698:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80069b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  80069e:	83 c7 01             	add    $0x1,%edi
  8006a1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006a5:	83 f8 25             	cmp    $0x25,%eax
  8006a8:	0f 84 2d fc ff ff    	je     8002db <vprintfmt+0x1f>
			if (ch == '\0')
  8006ae:	85 c0                	test   %eax,%eax
  8006b0:	0f 84 91 00 00 00    	je     800747 <.L22+0x21>
			putch(ch, putdat);
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	56                   	push   %esi
  8006ba:	50                   	push   %eax
  8006bb:	ff 55 08             	call   *0x8(%ebp)
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	eb db                	jmp    80069e <.L35+0x48>

008006c3 <.L38>:
  8006c3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006c6:	83 f9 01             	cmp    $0x1,%ecx
  8006c9:	7e 15                	jle    8006e0 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8b 10                	mov    (%eax),%edx
  8006d0:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d3:	8d 40 08             	lea    0x8(%eax),%eax
  8006d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d9:	b8 10 00 00 00       	mov    $0x10,%eax
  8006de:	eb a0                	jmp    800680 <.L35+0x2a>
	else if (lflag)
  8006e0:	85 c9                	test   %ecx,%ecx
  8006e2:	75 17                	jne    8006fb <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8b 10                	mov    (%eax),%edx
  8006e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ee:	8d 40 04             	lea    0x4(%eax),%eax
  8006f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f9:	eb 85                	jmp    800680 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fe:	8b 10                	mov    (%eax),%edx
  800700:	b9 00 00 00 00       	mov    $0x0,%ecx
  800705:	8d 40 04             	lea    0x4(%eax),%eax
  800708:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070b:	b8 10 00 00 00       	mov    $0x10,%eax
  800710:	e9 6b ff ff ff       	jmp    800680 <.L35+0x2a>

00800715 <.L25>:
			putch(ch, putdat);
  800715:	83 ec 08             	sub    $0x8,%esp
  800718:	56                   	push   %esi
  800719:	6a 25                	push   $0x25
  80071b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80071e:	83 c4 10             	add    $0x10,%esp
  800721:	e9 75 ff ff ff       	jmp    80069b <.L35+0x45>

00800726 <.L22>:
			putch('%', putdat);
  800726:	83 ec 08             	sub    $0x8,%esp
  800729:	56                   	push   %esi
  80072a:	6a 25                	push   $0x25
  80072c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	89 f8                	mov    %edi,%eax
  800734:	eb 03                	jmp    800739 <.L22+0x13>
  800736:	83 e8 01             	sub    $0x1,%eax
  800739:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80073d:	75 f7                	jne    800736 <.L22+0x10>
  80073f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800742:	e9 54 ff ff ff       	jmp    80069b <.L35+0x45>
}
  800747:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074a:	5b                   	pop    %ebx
  80074b:	5e                   	pop    %esi
  80074c:	5f                   	pop    %edi
  80074d:	5d                   	pop    %ebp
  80074e:	c3                   	ret    

0080074f <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	53                   	push   %ebx
  800753:	83 ec 14             	sub    $0x14,%esp
  800756:	e8 18 f9 ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  80075b:	81 c3 a5 18 00 00    	add    $0x18a5,%ebx
  800761:	8b 45 08             	mov    0x8(%ebp),%eax
  800764:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  800767:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800771:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800778:	85 c0                	test   %eax,%eax
  80077a:	74 2b                	je     8007a7 <vsnprintf+0x58>
  80077c:	85 d2                	test   %edx,%edx
  80077e:	7e 27                	jle    8007a7 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  800780:	ff 75 14             	pushl  0x14(%ebp)
  800783:	ff 75 10             	pushl  0x10(%ebp)
  800786:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800789:	50                   	push   %eax
  80078a:	8d 83 82 e2 ff ff    	lea    -0x1d7e(%ebx),%eax
  800790:	50                   	push   %eax
  800791:	e8 26 fb ff ff       	call   8002bc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800796:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800799:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079f:	83 c4 10             	add    $0x10,%esp
}
  8007a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a5:	c9                   	leave  
  8007a6:	c3                   	ret    
		return -E_INVAL;
  8007a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ac:	eb f4                	jmp    8007a2 <vsnprintf+0x53>

008007ae <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b7:	50                   	push   %eax
  8007b8:	ff 75 10             	pushl  0x10(%ebp)
  8007bb:	ff 75 0c             	pushl  0xc(%ebp)
  8007be:	ff 75 08             	pushl  0x8(%ebp)
  8007c1:	e8 89 ff ff ff       	call   80074f <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c6:	c9                   	leave  
  8007c7:	c3                   	ret    

008007c8 <__x86.get_pc_thunk.cx>:
  8007c8:	8b 0c 24             	mov    (%esp),%ecx
  8007cb:	c3                   	ret    

008007cc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d7:	eb 03                	jmp    8007dc <strlen+0x10>
		n++;
  8007d9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007dc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e0:	75 f7                	jne    8007d9 <strlen+0xd>
	return n;
}
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f2:	eb 03                	jmp    8007f7 <strnlen+0x13>
		n++;
  8007f4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f7:	39 d0                	cmp    %edx,%eax
  8007f9:	74 06                	je     800801 <strnlen+0x1d>
  8007fb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ff:	75 f3                	jne    8007f4 <strnlen+0x10>
	return n;
}
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	53                   	push   %ebx
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80080d:	89 c2                	mov    %eax,%edx
  80080f:	83 c1 01             	add    $0x1,%ecx
  800812:	83 c2 01             	add    $0x1,%edx
  800815:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800819:	88 5a ff             	mov    %bl,-0x1(%edx)
  80081c:	84 db                	test   %bl,%bl
  80081e:	75 ef                	jne    80080f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800820:	5b                   	pop    %ebx
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	53                   	push   %ebx
  800827:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082a:	53                   	push   %ebx
  80082b:	e8 9c ff ff ff       	call   8007cc <strlen>
  800830:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800833:	ff 75 0c             	pushl  0xc(%ebp)
  800836:	01 d8                	add    %ebx,%eax
  800838:	50                   	push   %eax
  800839:	e8 c5 ff ff ff       	call   800803 <strcpy>
	return dst;
}
  80083e:	89 d8                	mov    %ebx,%eax
  800840:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800843:	c9                   	leave  
  800844:	c3                   	ret    

00800845 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	56                   	push   %esi
  800849:	53                   	push   %ebx
  80084a:	8b 75 08             	mov    0x8(%ebp),%esi
  80084d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800850:	89 f3                	mov    %esi,%ebx
  800852:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800855:	89 f2                	mov    %esi,%edx
  800857:	eb 0f                	jmp    800868 <strncpy+0x23>
		*dst++ = *src;
  800859:	83 c2 01             	add    $0x1,%edx
  80085c:	0f b6 01             	movzbl (%ecx),%eax
  80085f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800862:	80 39 01             	cmpb   $0x1,(%ecx)
  800865:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800868:	39 da                	cmp    %ebx,%edx
  80086a:	75 ed                	jne    800859 <strncpy+0x14>
	}
	return ret;
}
  80086c:	89 f0                	mov    %esi,%eax
  80086e:	5b                   	pop    %ebx
  80086f:	5e                   	pop    %esi
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	56                   	push   %esi
  800876:	53                   	push   %ebx
  800877:	8b 75 08             	mov    0x8(%ebp),%esi
  80087a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800880:	89 f0                	mov    %esi,%eax
  800882:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800886:	85 c9                	test   %ecx,%ecx
  800888:	75 0b                	jne    800895 <strlcpy+0x23>
  80088a:	eb 17                	jmp    8008a3 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80088c:	83 c2 01             	add    $0x1,%edx
  80088f:	83 c0 01             	add    $0x1,%eax
  800892:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800895:	39 d8                	cmp    %ebx,%eax
  800897:	74 07                	je     8008a0 <strlcpy+0x2e>
  800899:	0f b6 0a             	movzbl (%edx),%ecx
  80089c:	84 c9                	test   %cl,%cl
  80089e:	75 ec                	jne    80088c <strlcpy+0x1a>
		*dst = '\0';
  8008a0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a3:	29 f0                	sub    %esi,%eax
}
  8008a5:	5b                   	pop    %ebx
  8008a6:	5e                   	pop    %esi
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b2:	eb 06                	jmp    8008ba <strcmp+0x11>
		p++, q++;
  8008b4:	83 c1 01             	add    $0x1,%ecx
  8008b7:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008ba:	0f b6 01             	movzbl (%ecx),%eax
  8008bd:	84 c0                	test   %al,%al
  8008bf:	74 04                	je     8008c5 <strcmp+0x1c>
  8008c1:	3a 02                	cmp    (%edx),%al
  8008c3:	74 ef                	je     8008b4 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c5:	0f b6 c0             	movzbl %al,%eax
  8008c8:	0f b6 12             	movzbl (%edx),%edx
  8008cb:	29 d0                	sub    %edx,%eax
}
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	53                   	push   %ebx
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d9:	89 c3                	mov    %eax,%ebx
  8008db:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008de:	eb 06                	jmp    8008e6 <strncmp+0x17>
		n--, p++, q++;
  8008e0:	83 c0 01             	add    $0x1,%eax
  8008e3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008e6:	39 d8                	cmp    %ebx,%eax
  8008e8:	74 16                	je     800900 <strncmp+0x31>
  8008ea:	0f b6 08             	movzbl (%eax),%ecx
  8008ed:	84 c9                	test   %cl,%cl
  8008ef:	74 04                	je     8008f5 <strncmp+0x26>
  8008f1:	3a 0a                	cmp    (%edx),%cl
  8008f3:	74 eb                	je     8008e0 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f5:	0f b6 00             	movzbl (%eax),%eax
  8008f8:	0f b6 12             	movzbl (%edx),%edx
  8008fb:	29 d0                	sub    %edx,%eax
}
  8008fd:	5b                   	pop    %ebx
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    
		return 0;
  800900:	b8 00 00 00 00       	mov    $0x0,%eax
  800905:	eb f6                	jmp    8008fd <strncmp+0x2e>

00800907 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800911:	0f b6 10             	movzbl (%eax),%edx
  800914:	84 d2                	test   %dl,%dl
  800916:	74 09                	je     800921 <strchr+0x1a>
		if (*s == c)
  800918:	38 ca                	cmp    %cl,%dl
  80091a:	74 0a                	je     800926 <strchr+0x1f>
	for (; *s; s++)
  80091c:	83 c0 01             	add    $0x1,%eax
  80091f:	eb f0                	jmp    800911 <strchr+0xa>
			return (char *) s;
	return 0;
  800921:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800932:	eb 03                	jmp    800937 <strfind+0xf>
  800934:	83 c0 01             	add    $0x1,%eax
  800937:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80093a:	38 ca                	cmp    %cl,%dl
  80093c:	74 04                	je     800942 <strfind+0x1a>
  80093e:	84 d2                	test   %dl,%dl
  800940:	75 f2                	jne    800934 <strfind+0xc>
			break;
	return (char *) s;
}
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	57                   	push   %edi
  800948:	56                   	push   %esi
  800949:	53                   	push   %ebx
  80094a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800950:	85 c9                	test   %ecx,%ecx
  800952:	74 13                	je     800967 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800954:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095a:	75 05                	jne    800961 <memset+0x1d>
  80095c:	f6 c1 03             	test   $0x3,%cl
  80095f:	74 0d                	je     80096e <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800961:	8b 45 0c             	mov    0xc(%ebp),%eax
  800964:	fc                   	cld    
  800965:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800967:	89 f8                	mov    %edi,%eax
  800969:	5b                   	pop    %ebx
  80096a:	5e                   	pop    %esi
  80096b:	5f                   	pop    %edi
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    
		c &= 0xFF;
  80096e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800972:	89 d3                	mov    %edx,%ebx
  800974:	c1 e3 08             	shl    $0x8,%ebx
  800977:	89 d0                	mov    %edx,%eax
  800979:	c1 e0 18             	shl    $0x18,%eax
  80097c:	89 d6                	mov    %edx,%esi
  80097e:	c1 e6 10             	shl    $0x10,%esi
  800981:	09 f0                	or     %esi,%eax
  800983:	09 c2                	or     %eax,%edx
  800985:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800987:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80098a:	89 d0                	mov    %edx,%eax
  80098c:	fc                   	cld    
  80098d:	f3 ab                	rep stos %eax,%es:(%edi)
  80098f:	eb d6                	jmp    800967 <memset+0x23>

00800991 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	57                   	push   %edi
  800995:	56                   	push   %esi
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099f:	39 c6                	cmp    %eax,%esi
  8009a1:	73 35                	jae    8009d8 <memmove+0x47>
  8009a3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a6:	39 c2                	cmp    %eax,%edx
  8009a8:	76 2e                	jbe    8009d8 <memmove+0x47>
		s += n;
		d += n;
  8009aa:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ad:	89 d6                	mov    %edx,%esi
  8009af:	09 fe                	or     %edi,%esi
  8009b1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b7:	74 0c                	je     8009c5 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b9:	83 ef 01             	sub    $0x1,%edi
  8009bc:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009bf:	fd                   	std    
  8009c0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c2:	fc                   	cld    
  8009c3:	eb 21                	jmp    8009e6 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c5:	f6 c1 03             	test   $0x3,%cl
  8009c8:	75 ef                	jne    8009b9 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ca:	83 ef 04             	sub    $0x4,%edi
  8009cd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009d3:	fd                   	std    
  8009d4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d6:	eb ea                	jmp    8009c2 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d8:	89 f2                	mov    %esi,%edx
  8009da:	09 c2                	or     %eax,%edx
  8009dc:	f6 c2 03             	test   $0x3,%dl
  8009df:	74 09                	je     8009ea <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e1:	89 c7                	mov    %eax,%edi
  8009e3:	fc                   	cld    
  8009e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e6:	5e                   	pop    %esi
  8009e7:	5f                   	pop    %edi
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ea:	f6 c1 03             	test   $0x3,%cl
  8009ed:	75 f2                	jne    8009e1 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ef:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009f2:	89 c7                	mov    %eax,%edi
  8009f4:	fc                   	cld    
  8009f5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f7:	eb ed                	jmp    8009e6 <memmove+0x55>

008009f9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009fc:	ff 75 10             	pushl  0x10(%ebp)
  8009ff:	ff 75 0c             	pushl  0xc(%ebp)
  800a02:	ff 75 08             	pushl  0x8(%ebp)
  800a05:	e8 87 ff ff ff       	call   800991 <memmove>
}
  800a0a:	c9                   	leave  
  800a0b:	c3                   	ret    

00800a0c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	56                   	push   %esi
  800a10:	53                   	push   %ebx
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a17:	89 c6                	mov    %eax,%esi
  800a19:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1c:	39 f0                	cmp    %esi,%eax
  800a1e:	74 1c                	je     800a3c <memcmp+0x30>
		if (*s1 != *s2)
  800a20:	0f b6 08             	movzbl (%eax),%ecx
  800a23:	0f b6 1a             	movzbl (%edx),%ebx
  800a26:	38 d9                	cmp    %bl,%cl
  800a28:	75 08                	jne    800a32 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a2a:	83 c0 01             	add    $0x1,%eax
  800a2d:	83 c2 01             	add    $0x1,%edx
  800a30:	eb ea                	jmp    800a1c <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a32:	0f b6 c1             	movzbl %cl,%eax
  800a35:	0f b6 db             	movzbl %bl,%ebx
  800a38:	29 d8                	sub    %ebx,%eax
  800a3a:	eb 05                	jmp    800a41 <memcmp+0x35>
	}

	return 0;
  800a3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a41:	5b                   	pop    %ebx
  800a42:	5e                   	pop    %esi
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a4e:	89 c2                	mov    %eax,%edx
  800a50:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a53:	39 d0                	cmp    %edx,%eax
  800a55:	73 09                	jae    800a60 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a57:	38 08                	cmp    %cl,(%eax)
  800a59:	74 05                	je     800a60 <memfind+0x1b>
	for (; s < ends; s++)
  800a5b:	83 c0 01             	add    $0x1,%eax
  800a5e:	eb f3                	jmp    800a53 <memfind+0xe>
			break;
	return (void *) s;
}
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	57                   	push   %edi
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
  800a68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6e:	eb 03                	jmp    800a73 <strtol+0x11>
		s++;
  800a70:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a73:	0f b6 01             	movzbl (%ecx),%eax
  800a76:	3c 20                	cmp    $0x20,%al
  800a78:	74 f6                	je     800a70 <strtol+0xe>
  800a7a:	3c 09                	cmp    $0x9,%al
  800a7c:	74 f2                	je     800a70 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a7e:	3c 2b                	cmp    $0x2b,%al
  800a80:	74 2e                	je     800ab0 <strtol+0x4e>
	int neg = 0;
  800a82:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a87:	3c 2d                	cmp    $0x2d,%al
  800a89:	74 2f                	je     800aba <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a91:	75 05                	jne    800a98 <strtol+0x36>
  800a93:	80 39 30             	cmpb   $0x30,(%ecx)
  800a96:	74 2c                	je     800ac4 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a98:	85 db                	test   %ebx,%ebx
  800a9a:	75 0a                	jne    800aa6 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a9c:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800aa1:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa4:	74 28                	je     800ace <strtol+0x6c>
		base = 10;
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aab:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aae:	eb 50                	jmp    800b00 <strtol+0x9e>
		s++;
  800ab0:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ab3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab8:	eb d1                	jmp    800a8b <strtol+0x29>
		s++, neg = 1;
  800aba:	83 c1 01             	add    $0x1,%ecx
  800abd:	bf 01 00 00 00       	mov    $0x1,%edi
  800ac2:	eb c7                	jmp    800a8b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac8:	74 0e                	je     800ad8 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800aca:	85 db                	test   %ebx,%ebx
  800acc:	75 d8                	jne    800aa6 <strtol+0x44>
		s++, base = 8;
  800ace:	83 c1 01             	add    $0x1,%ecx
  800ad1:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ad6:	eb ce                	jmp    800aa6 <strtol+0x44>
		s += 2, base = 16;
  800ad8:	83 c1 02             	add    $0x2,%ecx
  800adb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae0:	eb c4                	jmp    800aa6 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ae2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae5:	89 f3                	mov    %esi,%ebx
  800ae7:	80 fb 19             	cmp    $0x19,%bl
  800aea:	77 29                	ja     800b15 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800aec:	0f be d2             	movsbl %dl,%edx
  800aef:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800af2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af5:	7d 30                	jge    800b27 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800af7:	83 c1 01             	add    $0x1,%ecx
  800afa:	0f af 45 10          	imul   0x10(%ebp),%eax
  800afe:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b00:	0f b6 11             	movzbl (%ecx),%edx
  800b03:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b06:	89 f3                	mov    %esi,%ebx
  800b08:	80 fb 09             	cmp    $0x9,%bl
  800b0b:	77 d5                	ja     800ae2 <strtol+0x80>
			dig = *s - '0';
  800b0d:	0f be d2             	movsbl %dl,%edx
  800b10:	83 ea 30             	sub    $0x30,%edx
  800b13:	eb dd                	jmp    800af2 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b15:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b18:	89 f3                	mov    %esi,%ebx
  800b1a:	80 fb 19             	cmp    $0x19,%bl
  800b1d:	77 08                	ja     800b27 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b1f:	0f be d2             	movsbl %dl,%edx
  800b22:	83 ea 37             	sub    $0x37,%edx
  800b25:	eb cb                	jmp    800af2 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b27:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2b:	74 05                	je     800b32 <strtol+0xd0>
		*endptr = (char *) s;
  800b2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b30:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b32:	89 c2                	mov    %eax,%edx
  800b34:	f7 da                	neg    %edx
  800b36:	85 ff                	test   %edi,%edi
  800b38:	0f 45 c2             	cmovne %edx,%eax
}
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b46:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b51:	89 c3                	mov    %eax,%ebx
  800b53:	89 c7                	mov    %eax,%edi
  800b55:	89 c6                	mov    %eax,%esi
  800b57:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b64:	ba 00 00 00 00       	mov    $0x0,%edx
  800b69:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6e:	89 d1                	mov    %edx,%ecx
  800b70:	89 d3                	mov    %edx,%ebx
  800b72:	89 d7                	mov    %edx,%edi
  800b74:	89 d6                	mov    %edx,%esi
  800b76:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	83 ec 1c             	sub    $0x1c,%esp
  800b86:	e8 ac 02 00 00       	call   800e37 <__x86.get_pc_thunk.ax>
  800b8b:	05 75 14 00 00       	add    $0x1475,%eax
  800b90:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b93:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b98:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9b:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba0:	89 cb                	mov    %ecx,%ebx
  800ba2:	89 cf                	mov    %ecx,%edi
  800ba4:	89 ce                	mov    %ecx,%esi
  800ba6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ba8:	85 c0                	test   %eax,%eax
  800baa:	7f 08                	jg     800bb4 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb4:	83 ec 0c             	sub    $0xc,%esp
  800bb7:	50                   	push   %eax
  800bb8:	6a 03                	push   $0x3
  800bba:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800bbd:	8d 83 04 f3 ff ff    	lea    -0xcfc(%ebx),%eax
  800bc3:	50                   	push   %eax
  800bc4:	6a 23                	push   $0x23
  800bc6:	8d 83 21 f3 ff ff    	lea    -0xcdf(%ebx),%eax
  800bcc:	50                   	push   %eax
  800bcd:	e8 69 02 00 00       	call   800e3b <_panic>

00800bd2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdd:	b8 02 00 00 00       	mov    $0x2,%eax
  800be2:	89 d1                	mov    %edx,%ecx
  800be4:	89 d3                	mov    %edx,%ebx
  800be6:	89 d7                	mov    %edx,%edi
  800be8:	89 d6                	mov    %edx,%esi
  800bea:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_yield>:

void
sys_yield(void)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c01:	89 d1                	mov    %edx,%ecx
  800c03:	89 d3                	mov    %edx,%ebx
  800c05:	89 d7                	mov    %edx,%edi
  800c07:	89 d6                	mov    %edx,%esi
  800c09:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	83 ec 1c             	sub    $0x1c,%esp
  800c19:	e8 19 02 00 00       	call   800e37 <__x86.get_pc_thunk.ax>
  800c1e:	05 e2 13 00 00       	add    $0x13e2,%eax
  800c23:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800c26:	be 00 00 00 00       	mov    $0x0,%esi
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c31:	b8 04 00 00 00       	mov    $0x4,%eax
  800c36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c39:	89 f7                	mov    %esi,%edi
  800c3b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7f 08                	jg     800c49 <sys_page_alloc+0x39>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c44:	5b                   	pop    %ebx
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c49:	83 ec 0c             	sub    $0xc,%esp
  800c4c:	50                   	push   %eax
  800c4d:	6a 04                	push   $0x4
  800c4f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c52:	8d 83 04 f3 ff ff    	lea    -0xcfc(%ebx),%eax
  800c58:	50                   	push   %eax
  800c59:	6a 23                	push   $0x23
  800c5b:	8d 83 21 f3 ff ff    	lea    -0xcdf(%ebx),%eax
  800c61:	50                   	push   %eax
  800c62:	e8 d4 01 00 00       	call   800e3b <_panic>

00800c67 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	83 ec 1c             	sub    $0x1c,%esp
  800c70:	e8 c2 01 00 00       	call   800e37 <__x86.get_pc_thunk.ax>
  800c75:	05 8b 13 00 00       	add    $0x138b,%eax
  800c7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800c7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c83:	b8 05 00 00 00       	mov    $0x5,%eax
  800c88:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8e:	8b 75 18             	mov    0x18(%ebp),%esi
  800c91:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c93:	85 c0                	test   %eax,%eax
  800c95:	7f 08                	jg     800c9f <sys_page_map+0x38>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9a:	5b                   	pop    %ebx
  800c9b:	5e                   	pop    %esi
  800c9c:	5f                   	pop    %edi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9f:	83 ec 0c             	sub    $0xc,%esp
  800ca2:	50                   	push   %eax
  800ca3:	6a 05                	push   $0x5
  800ca5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800ca8:	8d 83 04 f3 ff ff    	lea    -0xcfc(%ebx),%eax
  800cae:	50                   	push   %eax
  800caf:	6a 23                	push   $0x23
  800cb1:	8d 83 21 f3 ff ff    	lea    -0xcdf(%ebx),%eax
  800cb7:	50                   	push   %eax
  800cb8:	e8 7e 01 00 00       	call   800e3b <_panic>

00800cbd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
  800cc3:	83 ec 1c             	sub    $0x1c,%esp
  800cc6:	e8 6c 01 00 00       	call   800e37 <__x86.get_pc_thunk.ax>
  800ccb:	05 35 13 00 00       	add    $0x1335,%eax
  800cd0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800cd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cde:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce3:	89 df                	mov    %ebx,%edi
  800ce5:	89 de                	mov    %ebx,%esi
  800ce7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	7f 08                	jg     800cf5 <sys_page_unmap+0x38>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ced:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf5:	83 ec 0c             	sub    $0xc,%esp
  800cf8:	50                   	push   %eax
  800cf9:	6a 06                	push   $0x6
  800cfb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800cfe:	8d 83 04 f3 ff ff    	lea    -0xcfc(%ebx),%eax
  800d04:	50                   	push   %eax
  800d05:	6a 23                	push   $0x23
  800d07:	8d 83 21 f3 ff ff    	lea    -0xcdf(%ebx),%eax
  800d0d:	50                   	push   %eax
  800d0e:	e8 28 01 00 00       	call   800e3b <_panic>

00800d13 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	83 ec 1c             	sub    $0x1c,%esp
  800d1c:	e8 16 01 00 00       	call   800e37 <__x86.get_pc_thunk.ax>
  800d21:	05 df 12 00 00       	add    $0x12df,%eax
  800d26:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800d29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	b8 08 00 00 00       	mov    $0x8,%eax
  800d39:	89 df                	mov    %ebx,%edi
  800d3b:	89 de                	mov    %ebx,%esi
  800d3d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	7f 08                	jg     800d4b <sys_env_set_status+0x38>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	50                   	push   %eax
  800d4f:	6a 08                	push   $0x8
  800d51:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800d54:	8d 83 04 f3 ff ff    	lea    -0xcfc(%ebx),%eax
  800d5a:	50                   	push   %eax
  800d5b:	6a 23                	push   $0x23
  800d5d:	8d 83 21 f3 ff ff    	lea    -0xcdf(%ebx),%eax
  800d63:	50                   	push   %eax
  800d64:	e8 d2 00 00 00       	call   800e3b <_panic>

00800d69 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 1c             	sub    $0x1c,%esp
  800d72:	e8 c0 00 00 00       	call   800e37 <__x86.get_pc_thunk.ax>
  800d77:	05 89 12 00 00       	add    $0x1289,%eax
  800d7c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800d7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d84:	8b 55 08             	mov    0x8(%ebp),%edx
  800d87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d8f:	89 df                	mov    %ebx,%edi
  800d91:	89 de                	mov    %ebx,%esi
  800d93:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d95:	85 c0                	test   %eax,%eax
  800d97:	7f 08                	jg     800da1 <sys_env_set_pgfault_upcall+0x38>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da1:	83 ec 0c             	sub    $0xc,%esp
  800da4:	50                   	push   %eax
  800da5:	6a 09                	push   $0x9
  800da7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800daa:	8d 83 04 f3 ff ff    	lea    -0xcfc(%ebx),%eax
  800db0:	50                   	push   %eax
  800db1:	6a 23                	push   $0x23
  800db3:	8d 83 21 f3 ff ff    	lea    -0xcdf(%ebx),%eax
  800db9:	50                   	push   %eax
  800dba:	e8 7c 00 00 00       	call   800e3b <_panic>

00800dbf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dd0:	be 00 00 00 00       	mov    $0x0,%esi
  800dd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ddb:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	83 ec 1c             	sub    $0x1c,%esp
  800deb:	e8 47 00 00 00       	call   800e37 <__x86.get_pc_thunk.ax>
  800df0:	05 10 12 00 00       	add    $0x1210,%eax
  800df5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800df8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800e00:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e05:	89 cb                	mov    %ecx,%ebx
  800e07:	89 cf                	mov    %ecx,%edi
  800e09:	89 ce                	mov    %ecx,%esi
  800e0b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e0d:	85 c0                	test   %eax,%eax
  800e0f:	7f 08                	jg     800e19 <sys_ipc_recv+0x37>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e14:	5b                   	pop    %ebx
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e19:	83 ec 0c             	sub    $0xc,%esp
  800e1c:	50                   	push   %eax
  800e1d:	6a 0c                	push   $0xc
  800e1f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800e22:	8d 83 04 f3 ff ff    	lea    -0xcfc(%ebx),%eax
  800e28:	50                   	push   %eax
  800e29:	6a 23                	push   $0x23
  800e2b:	8d 83 21 f3 ff ff    	lea    -0xcdf(%ebx),%eax
  800e31:	50                   	push   %eax
  800e32:	e8 04 00 00 00       	call   800e3b <_panic>

00800e37 <__x86.get_pc_thunk.ax>:
  800e37:	8b 04 24             	mov    (%esp),%eax
  800e3a:	c3                   	ret    

00800e3b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	57                   	push   %edi
  800e3f:	56                   	push   %esi
  800e40:	53                   	push   %ebx
  800e41:	83 ec 0c             	sub    $0xc,%esp
  800e44:	e8 2a f2 ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800e49:	81 c3 b7 11 00 00    	add    $0x11b7,%ebx
	va_list ap;

	va_start(ap, fmt);
  800e4f:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e52:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800e58:	8b 38                	mov    (%eax),%edi
  800e5a:	e8 73 fd ff ff       	call   800bd2 <sys_getenvid>
  800e5f:	83 ec 0c             	sub    $0xc,%esp
  800e62:	ff 75 0c             	pushl  0xc(%ebp)
  800e65:	ff 75 08             	pushl  0x8(%ebp)
  800e68:	57                   	push   %edi
  800e69:	50                   	push   %eax
  800e6a:	8d 83 30 f3 ff ff    	lea    -0xcd0(%ebx),%eax
  800e70:	50                   	push   %eax
  800e71:	e8 2e f3 ff ff       	call   8001a4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e76:	83 c4 18             	add    $0x18,%esp
  800e79:	56                   	push   %esi
  800e7a:	ff 75 10             	pushl  0x10(%ebp)
  800e7d:	e8 c0 f2 ff ff       	call   800142 <vcprintf>
	cprintf("\n");
  800e82:	8d 83 e8 f0 ff ff    	lea    -0xf18(%ebx),%eax
  800e88:	89 04 24             	mov    %eax,(%esp)
  800e8b:	e8 14 f3 ff ff       	call   8001a4 <cprintf>
  800e90:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e93:	cc                   	int3   
  800e94:	eb fd                	jmp    800e93 <_panic+0x58>
  800e96:	66 90                	xchg   %ax,%ax
  800e98:	66 90                	xchg   %ax,%ax
  800e9a:	66 90                	xchg   %ax,%ax
  800e9c:	66 90                	xchg   %ax,%ax
  800e9e:	66 90                	xchg   %ax,%ax

00800ea0 <__udivdi3>:
  800ea0:	55                   	push   %ebp
  800ea1:	57                   	push   %edi
  800ea2:	56                   	push   %esi
  800ea3:	53                   	push   %ebx
  800ea4:	83 ec 1c             	sub    $0x1c,%esp
  800ea7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800eab:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800eaf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800eb3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800eb7:	85 d2                	test   %edx,%edx
  800eb9:	75 35                	jne    800ef0 <__udivdi3+0x50>
  800ebb:	39 f3                	cmp    %esi,%ebx
  800ebd:	0f 87 bd 00 00 00    	ja     800f80 <__udivdi3+0xe0>
  800ec3:	85 db                	test   %ebx,%ebx
  800ec5:	89 d9                	mov    %ebx,%ecx
  800ec7:	75 0b                	jne    800ed4 <__udivdi3+0x34>
  800ec9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ece:	31 d2                	xor    %edx,%edx
  800ed0:	f7 f3                	div    %ebx
  800ed2:	89 c1                	mov    %eax,%ecx
  800ed4:	31 d2                	xor    %edx,%edx
  800ed6:	89 f0                	mov    %esi,%eax
  800ed8:	f7 f1                	div    %ecx
  800eda:	89 c6                	mov    %eax,%esi
  800edc:	89 e8                	mov    %ebp,%eax
  800ede:	89 f7                	mov    %esi,%edi
  800ee0:	f7 f1                	div    %ecx
  800ee2:	89 fa                	mov    %edi,%edx
  800ee4:	83 c4 1c             	add    $0x1c,%esp
  800ee7:	5b                   	pop    %ebx
  800ee8:	5e                   	pop    %esi
  800ee9:	5f                   	pop    %edi
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    
  800eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	39 f2                	cmp    %esi,%edx
  800ef2:	77 7c                	ja     800f70 <__udivdi3+0xd0>
  800ef4:	0f bd fa             	bsr    %edx,%edi
  800ef7:	83 f7 1f             	xor    $0x1f,%edi
  800efa:	0f 84 98 00 00 00    	je     800f98 <__udivdi3+0xf8>
  800f00:	89 f9                	mov    %edi,%ecx
  800f02:	b8 20 00 00 00       	mov    $0x20,%eax
  800f07:	29 f8                	sub    %edi,%eax
  800f09:	d3 e2                	shl    %cl,%edx
  800f0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f0f:	89 c1                	mov    %eax,%ecx
  800f11:	89 da                	mov    %ebx,%edx
  800f13:	d3 ea                	shr    %cl,%edx
  800f15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f19:	09 d1                	or     %edx,%ecx
  800f1b:	89 f2                	mov    %esi,%edx
  800f1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f21:	89 f9                	mov    %edi,%ecx
  800f23:	d3 e3                	shl    %cl,%ebx
  800f25:	89 c1                	mov    %eax,%ecx
  800f27:	d3 ea                	shr    %cl,%edx
  800f29:	89 f9                	mov    %edi,%ecx
  800f2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f2f:	d3 e6                	shl    %cl,%esi
  800f31:	89 eb                	mov    %ebp,%ebx
  800f33:	89 c1                	mov    %eax,%ecx
  800f35:	d3 eb                	shr    %cl,%ebx
  800f37:	09 de                	or     %ebx,%esi
  800f39:	89 f0                	mov    %esi,%eax
  800f3b:	f7 74 24 08          	divl   0x8(%esp)
  800f3f:	89 d6                	mov    %edx,%esi
  800f41:	89 c3                	mov    %eax,%ebx
  800f43:	f7 64 24 0c          	mull   0xc(%esp)
  800f47:	39 d6                	cmp    %edx,%esi
  800f49:	72 0c                	jb     800f57 <__udivdi3+0xb7>
  800f4b:	89 f9                	mov    %edi,%ecx
  800f4d:	d3 e5                	shl    %cl,%ebp
  800f4f:	39 c5                	cmp    %eax,%ebp
  800f51:	73 5d                	jae    800fb0 <__udivdi3+0x110>
  800f53:	39 d6                	cmp    %edx,%esi
  800f55:	75 59                	jne    800fb0 <__udivdi3+0x110>
  800f57:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f5a:	31 ff                	xor    %edi,%edi
  800f5c:	89 fa                	mov    %edi,%edx
  800f5e:	83 c4 1c             	add    $0x1c,%esp
  800f61:	5b                   	pop    %ebx
  800f62:	5e                   	pop    %esi
  800f63:	5f                   	pop    %edi
  800f64:	5d                   	pop    %ebp
  800f65:	c3                   	ret    
  800f66:	8d 76 00             	lea    0x0(%esi),%esi
  800f69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800f70:	31 ff                	xor    %edi,%edi
  800f72:	31 c0                	xor    %eax,%eax
  800f74:	89 fa                	mov    %edi,%edx
  800f76:	83 c4 1c             	add    $0x1c,%esp
  800f79:	5b                   	pop    %ebx
  800f7a:	5e                   	pop    %esi
  800f7b:	5f                   	pop    %edi
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    
  800f7e:	66 90                	xchg   %ax,%ax
  800f80:	31 ff                	xor    %edi,%edi
  800f82:	89 e8                	mov    %ebp,%eax
  800f84:	89 f2                	mov    %esi,%edx
  800f86:	f7 f3                	div    %ebx
  800f88:	89 fa                	mov    %edi,%edx
  800f8a:	83 c4 1c             	add    $0x1c,%esp
  800f8d:	5b                   	pop    %ebx
  800f8e:	5e                   	pop    %esi
  800f8f:	5f                   	pop    %edi
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    
  800f92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f98:	39 f2                	cmp    %esi,%edx
  800f9a:	72 06                	jb     800fa2 <__udivdi3+0x102>
  800f9c:	31 c0                	xor    %eax,%eax
  800f9e:	39 eb                	cmp    %ebp,%ebx
  800fa0:	77 d2                	ja     800f74 <__udivdi3+0xd4>
  800fa2:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa7:	eb cb                	jmp    800f74 <__udivdi3+0xd4>
  800fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fb0:	89 d8                	mov    %ebx,%eax
  800fb2:	31 ff                	xor    %edi,%edi
  800fb4:	eb be                	jmp    800f74 <__udivdi3+0xd4>
  800fb6:	66 90                	xchg   %ax,%ax
  800fb8:	66 90                	xchg   %ax,%ax
  800fba:	66 90                	xchg   %ax,%ax
  800fbc:	66 90                	xchg   %ax,%ax
  800fbe:	66 90                	xchg   %ax,%ax

00800fc0 <__umoddi3>:
  800fc0:	55                   	push   %ebp
  800fc1:	57                   	push   %edi
  800fc2:	56                   	push   %esi
  800fc3:	53                   	push   %ebx
  800fc4:	83 ec 1c             	sub    $0x1c,%esp
  800fc7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800fcb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800fcf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800fd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800fd7:	85 ed                	test   %ebp,%ebp
  800fd9:	89 f0                	mov    %esi,%eax
  800fdb:	89 da                	mov    %ebx,%edx
  800fdd:	75 19                	jne    800ff8 <__umoddi3+0x38>
  800fdf:	39 df                	cmp    %ebx,%edi
  800fe1:	0f 86 b1 00 00 00    	jbe    801098 <__umoddi3+0xd8>
  800fe7:	f7 f7                	div    %edi
  800fe9:	89 d0                	mov    %edx,%eax
  800feb:	31 d2                	xor    %edx,%edx
  800fed:	83 c4 1c             	add    $0x1c,%esp
  800ff0:	5b                   	pop    %ebx
  800ff1:	5e                   	pop    %esi
  800ff2:	5f                   	pop    %edi
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    
  800ff5:	8d 76 00             	lea    0x0(%esi),%esi
  800ff8:	39 dd                	cmp    %ebx,%ebp
  800ffa:	77 f1                	ja     800fed <__umoddi3+0x2d>
  800ffc:	0f bd cd             	bsr    %ebp,%ecx
  800fff:	83 f1 1f             	xor    $0x1f,%ecx
  801002:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801006:	0f 84 b4 00 00 00    	je     8010c0 <__umoddi3+0x100>
  80100c:	b8 20 00 00 00       	mov    $0x20,%eax
  801011:	89 c2                	mov    %eax,%edx
  801013:	8b 44 24 04          	mov    0x4(%esp),%eax
  801017:	29 c2                	sub    %eax,%edx
  801019:	89 c1                	mov    %eax,%ecx
  80101b:	89 f8                	mov    %edi,%eax
  80101d:	d3 e5                	shl    %cl,%ebp
  80101f:	89 d1                	mov    %edx,%ecx
  801021:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801025:	d3 e8                	shr    %cl,%eax
  801027:	09 c5                	or     %eax,%ebp
  801029:	8b 44 24 04          	mov    0x4(%esp),%eax
  80102d:	89 c1                	mov    %eax,%ecx
  80102f:	d3 e7                	shl    %cl,%edi
  801031:	89 d1                	mov    %edx,%ecx
  801033:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801037:	89 df                	mov    %ebx,%edi
  801039:	d3 ef                	shr    %cl,%edi
  80103b:	89 c1                	mov    %eax,%ecx
  80103d:	89 f0                	mov    %esi,%eax
  80103f:	d3 e3                	shl    %cl,%ebx
  801041:	89 d1                	mov    %edx,%ecx
  801043:	89 fa                	mov    %edi,%edx
  801045:	d3 e8                	shr    %cl,%eax
  801047:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80104c:	09 d8                	or     %ebx,%eax
  80104e:	f7 f5                	div    %ebp
  801050:	d3 e6                	shl    %cl,%esi
  801052:	89 d1                	mov    %edx,%ecx
  801054:	f7 64 24 08          	mull   0x8(%esp)
  801058:	39 d1                	cmp    %edx,%ecx
  80105a:	89 c3                	mov    %eax,%ebx
  80105c:	89 d7                	mov    %edx,%edi
  80105e:	72 06                	jb     801066 <__umoddi3+0xa6>
  801060:	75 0e                	jne    801070 <__umoddi3+0xb0>
  801062:	39 c6                	cmp    %eax,%esi
  801064:	73 0a                	jae    801070 <__umoddi3+0xb0>
  801066:	2b 44 24 08          	sub    0x8(%esp),%eax
  80106a:	19 ea                	sbb    %ebp,%edx
  80106c:	89 d7                	mov    %edx,%edi
  80106e:	89 c3                	mov    %eax,%ebx
  801070:	89 ca                	mov    %ecx,%edx
  801072:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801077:	29 de                	sub    %ebx,%esi
  801079:	19 fa                	sbb    %edi,%edx
  80107b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80107f:	89 d0                	mov    %edx,%eax
  801081:	d3 e0                	shl    %cl,%eax
  801083:	89 d9                	mov    %ebx,%ecx
  801085:	d3 ee                	shr    %cl,%esi
  801087:	d3 ea                	shr    %cl,%edx
  801089:	09 f0                	or     %esi,%eax
  80108b:	83 c4 1c             	add    $0x1c,%esp
  80108e:	5b                   	pop    %ebx
  80108f:	5e                   	pop    %esi
  801090:	5f                   	pop    %edi
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    
  801093:	90                   	nop
  801094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801098:	85 ff                	test   %edi,%edi
  80109a:	89 f9                	mov    %edi,%ecx
  80109c:	75 0b                	jne    8010a9 <__umoddi3+0xe9>
  80109e:	b8 01 00 00 00       	mov    $0x1,%eax
  8010a3:	31 d2                	xor    %edx,%edx
  8010a5:	f7 f7                	div    %edi
  8010a7:	89 c1                	mov    %eax,%ecx
  8010a9:	89 d8                	mov    %ebx,%eax
  8010ab:	31 d2                	xor    %edx,%edx
  8010ad:	f7 f1                	div    %ecx
  8010af:	89 f0                	mov    %esi,%eax
  8010b1:	f7 f1                	div    %ecx
  8010b3:	e9 31 ff ff ff       	jmp    800fe9 <__umoddi3+0x29>
  8010b8:	90                   	nop
  8010b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010c0:	39 dd                	cmp    %ebx,%ebp
  8010c2:	72 08                	jb     8010cc <__umoddi3+0x10c>
  8010c4:	39 f7                	cmp    %esi,%edi
  8010c6:	0f 87 21 ff ff ff    	ja     800fed <__umoddi3+0x2d>
  8010cc:	89 da                	mov    %ebx,%edx
  8010ce:	89 f0                	mov    %esi,%eax
  8010d0:	29 f8                	sub    %edi,%eax
  8010d2:	19 ea                	sbb    %ebp,%edx
  8010d4:	e9 14 ff ff ff       	jmp    800fed <__umoddi3+0x2d>
