
obj/user/faultreadkernel:     file format elf32-i386


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
  80002c:	e8 32 00 00 00       	call   800063 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 20 00 00 00       	call   80005f <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800045:	ff 35 00 00 10 f0    	pushl  0xf0100000
  80004b:	8d 83 6c ee ff ff    	lea    -0x1194(%ebx),%eax
  800051:	50                   	push   %eax
  800052:	e8 25 01 00 00       	call   80017c <cprintf>
}
  800057:	83 c4 10             	add    $0x10,%esp
  80005a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    

0080005f <__x86.get_pc_thunk.bx>:
  80005f:	8b 1c 24             	mov    (%esp),%ebx
  800062:	c3                   	ret    

00800063 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800063:	55                   	push   %ebp
  800064:	89 e5                	mov    %esp,%ebp
  800066:	53                   	push   %ebx
  800067:	83 ec 04             	sub    $0x4,%esp
  80006a:	e8 f0 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  80006f:	81 c3 91 1f 00 00    	add    $0x1f91,%ebx
  800075:	8b 45 08             	mov    0x8(%ebp),%eax
  800078:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80007b:	c7 c1 2c 20 80 00    	mov    $0x80202c,%ecx
  800081:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 c0                	test   %eax,%eax
  800089:	7e 08                	jle    800093 <libmain+0x30>
		binaryname = argv[0];
  80008b:	8b 0a                	mov    (%edx),%ecx
  80008d:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800093:	83 ec 08             	sub    $0x8,%esp
  800096:	52                   	push   %edx
  800097:	50                   	push   %eax
  800098:	e8 96 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009d:	e8 08 00 00 00       	call   8000aa <exit>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	53                   	push   %ebx
  8000ae:	83 ec 10             	sub    $0x10,%esp
  8000b1:	e8 a9 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8000b6:	81 c3 4a 1f 00 00    	add    $0x1f4a,%ebx
	sys_env_destroy(0);
  8000bc:	6a 00                	push   $0x0
  8000be:	e8 92 0a 00 00       	call   800b55 <sys_env_destroy>
}
  8000c3:	83 c4 10             	add    $0x10,%esp
  8000c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c9:	c9                   	leave  
  8000ca:	c3                   	ret    

008000cb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
  8000d0:	e8 8a ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8000d5:	81 c3 2b 1f 00 00    	add    $0x1f2b,%ebx
  8000db:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8000de:	8b 16                	mov    (%esi),%edx
  8000e0:	8d 42 01             	lea    0x1(%edx),%eax
  8000e3:	89 06                	mov    %eax,(%esi)
  8000e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e8:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8000ec:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f1:	74 0b                	je     8000fe <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000f3:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8000f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000fe:	83 ec 08             	sub    $0x8,%esp
  800101:	68 ff 00 00 00       	push   $0xff
  800106:	8d 46 08             	lea    0x8(%esi),%eax
  800109:	50                   	push   %eax
  80010a:	e8 09 0a 00 00       	call   800b18 <sys_cputs>
		b->idx = 0;
  80010f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800115:	83 c4 10             	add    $0x10,%esp
  800118:	eb d9                	jmp    8000f3 <putch+0x28>

0080011a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	53                   	push   %ebx
  80011e:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800124:	e8 36 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800129:	81 c3 d7 1e 00 00    	add    $0x1ed7,%ebx
	struct printbuf b;

	b.idx = 0;
  80012f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800136:	00 00 00 
	b.cnt = 0;
  800139:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800140:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800143:	ff 75 0c             	pushl  0xc(%ebp)
  800146:	ff 75 08             	pushl  0x8(%ebp)
  800149:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014f:	50                   	push   %eax
  800150:	8d 83 cb e0 ff ff    	lea    -0x1f35(%ebx),%eax
  800156:	50                   	push   %eax
  800157:	e8 38 01 00 00       	call   800294 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015c:	83 c4 08             	add    $0x8,%esp
  80015f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800165:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80016b:	50                   	push   %eax
  80016c:	e8 a7 09 00 00       	call   800b18 <sys_cputs>

	return b.cnt;
}
  800171:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800177:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80017a:	c9                   	leave  
  80017b:	c3                   	ret    

0080017c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800182:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800185:	50                   	push   %eax
  800186:	ff 75 08             	pushl  0x8(%ebp)
  800189:	e8 8c ff ff ff       	call   80011a <vcprintf>
	va_end(ap);

	return cnt;
}
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 2c             	sub    $0x2c,%esp
  800199:	e8 02 06 00 00       	call   8007a0 <__x86.get_pc_thunk.cx>
  80019e:	81 c1 62 1e 00 00    	add    $0x1e62,%ecx
  8001a4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001a7:	89 c7                	mov    %eax,%edi
  8001a9:	89 d6                	mov    %edx,%esi
  8001ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001b4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  8001b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001bf:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8001c2:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8001c5:	39 d3                	cmp    %edx,%ebx
  8001c7:	72 09                	jb     8001d2 <printnum+0x42>
  8001c9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001cc:	0f 87 83 00 00 00    	ja     800255 <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d2:	83 ec 0c             	sub    $0xc,%esp
  8001d5:	ff 75 18             	pushl  0x18(%ebp)
  8001d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8001db:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001de:	53                   	push   %ebx
  8001df:	ff 75 10             	pushl  0x10(%ebp)
  8001e2:	83 ec 08             	sub    $0x8,%esp
  8001e5:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e8:	ff 75 d8             	pushl  -0x28(%ebp)
  8001eb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001ee:	ff 75 d0             	pushl  -0x30(%ebp)
  8001f1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8001f4:	e8 37 0a 00 00       	call   800c30 <__udivdi3>
  8001f9:	83 c4 18             	add    $0x18,%esp
  8001fc:	52                   	push   %edx
  8001fd:	50                   	push   %eax
  8001fe:	89 f2                	mov    %esi,%edx
  800200:	89 f8                	mov    %edi,%eax
  800202:	e8 89 ff ff ff       	call   800190 <printnum>
  800207:	83 c4 20             	add    $0x20,%esp
  80020a:	eb 13                	jmp    80021f <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020c:	83 ec 08             	sub    $0x8,%esp
  80020f:	56                   	push   %esi
  800210:	ff 75 18             	pushl  0x18(%ebp)
  800213:	ff d7                	call   *%edi
  800215:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800218:	83 eb 01             	sub    $0x1,%ebx
  80021b:	85 db                	test   %ebx,%ebx
  80021d:	7f ed                	jg     80020c <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021f:	83 ec 08             	sub    $0x8,%esp
  800222:	56                   	push   %esi
  800223:	83 ec 04             	sub    $0x4,%esp
  800226:	ff 75 dc             	pushl  -0x24(%ebp)
  800229:	ff 75 d8             	pushl  -0x28(%ebp)
  80022c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80022f:	ff 75 d0             	pushl  -0x30(%ebp)
  800232:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800235:	89 f3                	mov    %esi,%ebx
  800237:	e8 14 0b 00 00       	call   800d50 <__umoddi3>
  80023c:	83 c4 14             	add    $0x14,%esp
  80023f:	0f be 84 06 9d ee ff 	movsbl -0x1163(%esi,%eax,1),%eax
  800246:	ff 
  800247:	50                   	push   %eax
  800248:	ff d7                	call   *%edi
}
  80024a:	83 c4 10             	add    $0x10,%esp
  80024d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800250:	5b                   	pop    %ebx
  800251:	5e                   	pop    %esi
  800252:	5f                   	pop    %edi
  800253:	5d                   	pop    %ebp
  800254:	c3                   	ret    
  800255:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800258:	eb be                	jmp    800218 <printnum+0x88>

0080025a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80025a:	55                   	push   %ebp
  80025b:	89 e5                	mov    %esp,%ebp
  80025d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800260:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800264:	8b 10                	mov    (%eax),%edx
  800266:	3b 50 04             	cmp    0x4(%eax),%edx
  800269:	73 0a                	jae    800275 <sprintputch+0x1b>
		*b->buf++ = ch;
  80026b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80026e:	89 08                	mov    %ecx,(%eax)
  800270:	8b 45 08             	mov    0x8(%ebp),%eax
  800273:	88 02                	mov    %al,(%edx)
}
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <printfmt>:
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80027d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800280:	50                   	push   %eax
  800281:	ff 75 10             	pushl  0x10(%ebp)
  800284:	ff 75 0c             	pushl  0xc(%ebp)
  800287:	ff 75 08             	pushl  0x8(%ebp)
  80028a:	e8 05 00 00 00       	call   800294 <vprintfmt>
}
  80028f:	83 c4 10             	add    $0x10,%esp
  800292:	c9                   	leave  
  800293:	c3                   	ret    

00800294 <vprintfmt>:
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	57                   	push   %edi
  800298:	56                   	push   %esi
  800299:	53                   	push   %ebx
  80029a:	83 ec 2c             	sub    $0x2c,%esp
  80029d:	e8 bd fd ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8002a2:	81 c3 5e 1d 00 00    	add    $0x1d5e,%ebx
  8002a8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002ab:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002ae:	e9 c3 03 00 00       	jmp    800676 <.L35+0x48>
		padc = ' ';
  8002b3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002b7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002be:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8002c5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d1:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8002d4:	8d 47 01             	lea    0x1(%edi),%eax
  8002d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002da:	0f b6 17             	movzbl (%edi),%edx
  8002dd:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002e0:	3c 55                	cmp    $0x55,%al
  8002e2:	0f 87 16 04 00 00    	ja     8006fe <.L22>
  8002e8:	0f b6 c0             	movzbl %al,%eax
  8002eb:	89 d9                	mov    %ebx,%ecx
  8002ed:	03 8c 83 2c ef ff ff 	add    -0x10d4(%ebx,%eax,4),%ecx
  8002f4:	ff e1                	jmp    *%ecx

008002f6 <.L69>:
  8002f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002f9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002fd:	eb d5                	jmp    8002d4 <vprintfmt+0x40>

008002ff <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8002ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800302:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800306:	eb cc                	jmp    8002d4 <vprintfmt+0x40>

00800308 <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800308:	0f b6 d2             	movzbl %dl,%edx
  80030b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
  80030e:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800313:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800316:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80031a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80031d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800320:	83 f9 09             	cmp    $0x9,%ecx
  800323:	77 55                	ja     80037a <.L23+0xf>
			for (precision = 0;; ++fmt)
  800325:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800328:	eb e9                	jmp    800313 <.L29+0xb>

0080032a <.L26>:
			precision = va_arg(ap, int);
  80032a:	8b 45 14             	mov    0x14(%ebp),%eax
  80032d:	8b 00                	mov    (%eax),%eax
  80032f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800332:	8b 45 14             	mov    0x14(%ebp),%eax
  800335:	8d 40 04             	lea    0x4(%eax),%eax
  800338:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80033b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80033e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800342:	79 90                	jns    8002d4 <vprintfmt+0x40>
				width = precision, precision = -1;
  800344:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800347:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80034a:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800351:	eb 81                	jmp    8002d4 <vprintfmt+0x40>

00800353 <.L27>:
  800353:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800356:	85 c0                	test   %eax,%eax
  800358:	ba 00 00 00 00       	mov    $0x0,%edx
  80035d:	0f 49 d0             	cmovns %eax,%edx
  800360:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800363:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800366:	e9 69 ff ff ff       	jmp    8002d4 <vprintfmt+0x40>

0080036b <.L23>:
  80036b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80036e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800375:	e9 5a ff ff ff       	jmp    8002d4 <vprintfmt+0x40>
  80037a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80037d:	eb bf                	jmp    80033e <.L26+0x14>

0080037f <.L33>:
			lflag++;
  80037f:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800386:	e9 49 ff ff ff       	jmp    8002d4 <vprintfmt+0x40>

0080038b <.L30>:
			putch(va_arg(ap, int), putdat);
  80038b:	8b 45 14             	mov    0x14(%ebp),%eax
  80038e:	8d 78 04             	lea    0x4(%eax),%edi
  800391:	83 ec 08             	sub    $0x8,%esp
  800394:	56                   	push   %esi
  800395:	ff 30                	pushl  (%eax)
  800397:	ff 55 08             	call   *0x8(%ebp)
			break;
  80039a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80039d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003a0:	e9 ce 02 00 00       	jmp    800673 <.L35+0x45>

008003a5 <.L32>:
			err = va_arg(ap, int);
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	8d 78 04             	lea    0x4(%eax),%edi
  8003ab:	8b 00                	mov    (%eax),%eax
  8003ad:	99                   	cltd   
  8003ae:	31 d0                	xor    %edx,%eax
  8003b0:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b2:	83 f8 06             	cmp    $0x6,%eax
  8003b5:	7f 27                	jg     8003de <.L32+0x39>
  8003b7:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8003be:	85 d2                	test   %edx,%edx
  8003c0:	74 1c                	je     8003de <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8003c2:	52                   	push   %edx
  8003c3:	8d 83 be ee ff ff    	lea    -0x1142(%ebx),%eax
  8003c9:	50                   	push   %eax
  8003ca:	56                   	push   %esi
  8003cb:	ff 75 08             	pushl  0x8(%ebp)
  8003ce:	e8 a4 fe ff ff       	call   800277 <printfmt>
  8003d3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003d6:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003d9:	e9 95 02 00 00       	jmp    800673 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8003de:	50                   	push   %eax
  8003df:	8d 83 b5 ee ff ff    	lea    -0x114b(%ebx),%eax
  8003e5:	50                   	push   %eax
  8003e6:	56                   	push   %esi
  8003e7:	ff 75 08             	pushl  0x8(%ebp)
  8003ea:	e8 88 fe ff ff       	call   800277 <printfmt>
  8003ef:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003f5:	e9 79 02 00 00       	jmp    800673 <.L35+0x45>

008003fa <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	83 c0 04             	add    $0x4,%eax
  800400:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800403:	8b 45 14             	mov    0x14(%ebp),%eax
  800406:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800408:	85 ff                	test   %edi,%edi
  80040a:	8d 83 ae ee ff ff    	lea    -0x1152(%ebx),%eax
  800410:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800413:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800417:	0f 8e b5 00 00 00    	jle    8004d2 <.L36+0xd8>
  80041d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800421:	75 08                	jne    80042b <.L36+0x31>
  800423:	89 75 0c             	mov    %esi,0xc(%ebp)
  800426:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800429:	eb 6d                	jmp    800498 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  80042b:	83 ec 08             	sub    $0x8,%esp
  80042e:	ff 75 cc             	pushl  -0x34(%ebp)
  800431:	57                   	push   %edi
  800432:	e8 85 03 00 00       	call   8007bc <strnlen>
  800437:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80043a:	29 c2                	sub    %eax,%edx
  80043c:	89 55 c8             	mov    %edx,-0x38(%ebp)
  80043f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800442:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800446:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800449:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80044c:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80044e:	eb 10                	jmp    800460 <.L36+0x66>
					putch(padc, putdat);
  800450:	83 ec 08             	sub    $0x8,%esp
  800453:	56                   	push   %esi
  800454:	ff 75 e0             	pushl  -0x20(%ebp)
  800457:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80045a:	83 ef 01             	sub    $0x1,%edi
  80045d:	83 c4 10             	add    $0x10,%esp
  800460:	85 ff                	test   %edi,%edi
  800462:	7f ec                	jg     800450 <.L36+0x56>
  800464:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800467:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80046a:	85 d2                	test   %edx,%edx
  80046c:	b8 00 00 00 00       	mov    $0x0,%eax
  800471:	0f 49 c2             	cmovns %edx,%eax
  800474:	29 c2                	sub    %eax,%edx
  800476:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800479:	89 75 0c             	mov    %esi,0xc(%ebp)
  80047c:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80047f:	eb 17                	jmp    800498 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  800481:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800485:	75 30                	jne    8004b7 <.L36+0xbd>
					putch(ch, putdat);
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	ff 75 0c             	pushl  0xc(%ebp)
  80048d:	50                   	push   %eax
  80048e:	ff 55 08             	call   *0x8(%ebp)
  800491:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800494:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800498:	83 c7 01             	add    $0x1,%edi
  80049b:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80049f:	0f be c2             	movsbl %dl,%eax
  8004a2:	85 c0                	test   %eax,%eax
  8004a4:	74 52                	je     8004f8 <.L36+0xfe>
  8004a6:	85 f6                	test   %esi,%esi
  8004a8:	78 d7                	js     800481 <.L36+0x87>
  8004aa:	83 ee 01             	sub    $0x1,%esi
  8004ad:	79 d2                	jns    800481 <.L36+0x87>
  8004af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004b2:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004b5:	eb 32                	jmp    8004e9 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8004b7:	0f be d2             	movsbl %dl,%edx
  8004ba:	83 ea 20             	sub    $0x20,%edx
  8004bd:	83 fa 5e             	cmp    $0x5e,%edx
  8004c0:	76 c5                	jbe    800487 <.L36+0x8d>
					putch('?', putdat);
  8004c2:	83 ec 08             	sub    $0x8,%esp
  8004c5:	ff 75 0c             	pushl  0xc(%ebp)
  8004c8:	6a 3f                	push   $0x3f
  8004ca:	ff 55 08             	call   *0x8(%ebp)
  8004cd:	83 c4 10             	add    $0x10,%esp
  8004d0:	eb c2                	jmp    800494 <.L36+0x9a>
  8004d2:	89 75 0c             	mov    %esi,0xc(%ebp)
  8004d5:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004d8:	eb be                	jmp    800498 <.L36+0x9e>
				putch(' ', putdat);
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	56                   	push   %esi
  8004de:	6a 20                	push   $0x20
  8004e0:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8004e3:	83 ef 01             	sub    $0x1,%edi
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	85 ff                	test   %edi,%edi
  8004eb:	7f ed                	jg     8004da <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  8004ed:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004f0:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f3:	e9 7b 01 00 00       	jmp    800673 <.L35+0x45>
  8004f8:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004fe:	eb e9                	jmp    8004e9 <.L36+0xef>

00800500 <.L31>:
  800500:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800503:	83 f9 01             	cmp    $0x1,%ecx
  800506:	7e 40                	jle    800548 <.L31+0x48>
		return va_arg(*ap, long long);
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8b 50 04             	mov    0x4(%eax),%edx
  80050e:	8b 00                	mov    (%eax),%eax
  800510:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800513:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 40 08             	lea    0x8(%eax),%eax
  80051c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
  80051f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800523:	79 55                	jns    80057a <.L31+0x7a>
				putch('-', putdat);
  800525:	83 ec 08             	sub    $0x8,%esp
  800528:	56                   	push   %esi
  800529:	6a 2d                	push   $0x2d
  80052b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  80052e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800531:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800534:	f7 da                	neg    %edx
  800536:	83 d1 00             	adc    $0x0,%ecx
  800539:	f7 d9                	neg    %ecx
  80053b:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
  80053e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800543:	e9 10 01 00 00       	jmp    800658 <.L35+0x2a>
	else if (lflag)
  800548:	85 c9                	test   %ecx,%ecx
  80054a:	75 17                	jne    800563 <.L31+0x63>
		return va_arg(*ap, int);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8b 00                	mov    (%eax),%eax
  800551:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800554:	99                   	cltd   
  800555:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 40 04             	lea    0x4(%eax),%eax
  80055e:	89 45 14             	mov    %eax,0x14(%ebp)
  800561:	eb bc                	jmp    80051f <.L31+0x1f>
		return va_arg(*ap, long);
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8b 00                	mov    (%eax),%eax
  800568:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056b:	99                   	cltd   
  80056c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8d 40 04             	lea    0x4(%eax),%eax
  800575:	89 45 14             	mov    %eax,0x14(%ebp)
  800578:	eb a5                	jmp    80051f <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  80057a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80057d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
  800580:	b8 0a 00 00 00       	mov    $0xa,%eax
  800585:	e9 ce 00 00 00       	jmp    800658 <.L35+0x2a>

0080058a <.L37>:
  80058a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80058d:	83 f9 01             	cmp    $0x1,%ecx
  800590:	7e 18                	jle    8005aa <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8b 10                	mov    (%eax),%edx
  800597:	8b 48 04             	mov    0x4(%eax),%ecx
  80059a:	8d 40 08             	lea    0x8(%eax),%eax
  80059d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005a0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a5:	e9 ae 00 00 00       	jmp    800658 <.L35+0x2a>
	else if (lflag)
  8005aa:	85 c9                	test   %ecx,%ecx
  8005ac:	75 1a                	jne    8005c8 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8b 10                	mov    (%eax),%edx
  8005b3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b8:	8d 40 04             	lea    0x4(%eax),%eax
  8005bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c3:	e9 90 00 00 00       	jmp    800658 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8b 10                	mov    (%eax),%edx
  8005cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d2:	8d 40 04             	lea    0x4(%eax),%eax
  8005d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005dd:	eb 79                	jmp    800658 <.L35+0x2a>

008005df <.L34>:
  8005df:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8005e2:	83 f9 01             	cmp    $0x1,%ecx
  8005e5:	7e 15                	jle    8005fc <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8b 10                	mov    (%eax),%edx
  8005ec:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ef:	8d 40 08             	lea    0x8(%eax),%eax
  8005f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005f5:	b8 08 00 00 00       	mov    $0x8,%eax
  8005fa:	eb 5c                	jmp    800658 <.L35+0x2a>
	else if (lflag)
  8005fc:	85 c9                	test   %ecx,%ecx
  8005fe:	75 17                	jne    800617 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8b 10                	mov    (%eax),%edx
  800605:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060a:	8d 40 04             	lea    0x4(%eax),%eax
  80060d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800610:	b8 08 00 00 00       	mov    $0x8,%eax
  800615:	eb 41                	jmp    800658 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8b 10                	mov    (%eax),%edx
  80061c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800621:	8d 40 04             	lea    0x4(%eax),%eax
  800624:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800627:	b8 08 00 00 00       	mov    $0x8,%eax
  80062c:	eb 2a                	jmp    800658 <.L35+0x2a>

0080062e <.L35>:
			putch('0', putdat);
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	56                   	push   %esi
  800632:	6a 30                	push   $0x30
  800634:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800637:	83 c4 08             	add    $0x8,%esp
  80063a:	56                   	push   %esi
  80063b:	6a 78                	push   $0x78
  80063d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8b 10                	mov    (%eax),%edx
  800645:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80064a:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80064d:	8d 40 04             	lea    0x4(%eax),%eax
  800650:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800653:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  800658:	83 ec 0c             	sub    $0xc,%esp
  80065b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80065f:	57                   	push   %edi
  800660:	ff 75 e0             	pushl  -0x20(%ebp)
  800663:	50                   	push   %eax
  800664:	51                   	push   %ecx
  800665:	52                   	push   %edx
  800666:	89 f2                	mov    %esi,%edx
  800668:	8b 45 08             	mov    0x8(%ebp),%eax
  80066b:	e8 20 fb ff ff       	call   800190 <printnum>
			break;
  800670:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800673:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  800676:	83 c7 01             	add    $0x1,%edi
  800679:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80067d:	83 f8 25             	cmp    $0x25,%eax
  800680:	0f 84 2d fc ff ff    	je     8002b3 <vprintfmt+0x1f>
			if (ch == '\0')
  800686:	85 c0                	test   %eax,%eax
  800688:	0f 84 91 00 00 00    	je     80071f <.L22+0x21>
			putch(ch, putdat);
  80068e:	83 ec 08             	sub    $0x8,%esp
  800691:	56                   	push   %esi
  800692:	50                   	push   %eax
  800693:	ff 55 08             	call   *0x8(%ebp)
  800696:	83 c4 10             	add    $0x10,%esp
  800699:	eb db                	jmp    800676 <.L35+0x48>

0080069b <.L38>:
  80069b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80069e:	83 f9 01             	cmp    $0x1,%ecx
  8006a1:	7e 15                	jle    8006b8 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8b 10                	mov    (%eax),%edx
  8006a8:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ab:	8d 40 08             	lea    0x8(%eax),%eax
  8006ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b1:	b8 10 00 00 00       	mov    $0x10,%eax
  8006b6:	eb a0                	jmp    800658 <.L35+0x2a>
	else if (lflag)
  8006b8:	85 c9                	test   %ecx,%ecx
  8006ba:	75 17                	jne    8006d3 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8006bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bf:	8b 10                	mov    (%eax),%edx
  8006c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c6:	8d 40 04             	lea    0x4(%eax),%eax
  8006c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006cc:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d1:	eb 85                	jmp    800658 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8b 10                	mov    (%eax),%edx
  8006d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006dd:	8d 40 04             	lea    0x4(%eax),%eax
  8006e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e3:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e8:	e9 6b ff ff ff       	jmp    800658 <.L35+0x2a>

008006ed <.L25>:
			putch(ch, putdat);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	56                   	push   %esi
  8006f1:	6a 25                	push   $0x25
  8006f3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006f6:	83 c4 10             	add    $0x10,%esp
  8006f9:	e9 75 ff ff ff       	jmp    800673 <.L35+0x45>

008006fe <.L22>:
			putch('%', putdat);
  8006fe:	83 ec 08             	sub    $0x8,%esp
  800701:	56                   	push   %esi
  800702:	6a 25                	push   $0x25
  800704:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800707:	83 c4 10             	add    $0x10,%esp
  80070a:	89 f8                	mov    %edi,%eax
  80070c:	eb 03                	jmp    800711 <.L22+0x13>
  80070e:	83 e8 01             	sub    $0x1,%eax
  800711:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800715:	75 f7                	jne    80070e <.L22+0x10>
  800717:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80071a:	e9 54 ff ff ff       	jmp    800673 <.L35+0x45>
}
  80071f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800722:	5b                   	pop    %ebx
  800723:	5e                   	pop    %esi
  800724:	5f                   	pop    %edi
  800725:	5d                   	pop    %ebp
  800726:	c3                   	ret    

00800727 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	53                   	push   %ebx
  80072b:	83 ec 14             	sub    $0x14,%esp
  80072e:	e8 2c f9 ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800733:	81 c3 cd 18 00 00    	add    $0x18cd,%ebx
  800739:	8b 45 08             	mov    0x8(%ebp),%eax
  80073c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  80073f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800742:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800746:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800749:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800750:	85 c0                	test   %eax,%eax
  800752:	74 2b                	je     80077f <vsnprintf+0x58>
  800754:	85 d2                	test   %edx,%edx
  800756:	7e 27                	jle    80077f <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  800758:	ff 75 14             	pushl  0x14(%ebp)
  80075b:	ff 75 10             	pushl  0x10(%ebp)
  80075e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800761:	50                   	push   %eax
  800762:	8d 83 5a e2 ff ff    	lea    -0x1da6(%ebx),%eax
  800768:	50                   	push   %eax
  800769:	e8 26 fb ff ff       	call   800294 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800771:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800774:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800777:	83 c4 10             	add    $0x10,%esp
}
  80077a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80077d:	c9                   	leave  
  80077e:	c3                   	ret    
		return -E_INVAL;
  80077f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800784:	eb f4                	jmp    80077a <vsnprintf+0x53>

00800786 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078f:	50                   	push   %eax
  800790:	ff 75 10             	pushl  0x10(%ebp)
  800793:	ff 75 0c             	pushl  0xc(%ebp)
  800796:	ff 75 08             	pushl  0x8(%ebp)
  800799:	e8 89 ff ff ff       	call   800727 <vsnprintf>
	va_end(ap);

	return rc;
}
  80079e:	c9                   	leave  
  80079f:	c3                   	ret    

008007a0 <__x86.get_pc_thunk.cx>:
  8007a0:	8b 0c 24             	mov    (%esp),%ecx
  8007a3:	c3                   	ret    

008007a4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8007af:	eb 03                	jmp    8007b4 <strlen+0x10>
		n++;
  8007b1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007b4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b8:	75 f7                	jne    8007b1 <strlen+0xd>
	return n;
}
  8007ba:	5d                   	pop    %ebp
  8007bb:	c3                   	ret    

008007bc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ca:	eb 03                	jmp    8007cf <strnlen+0x13>
		n++;
  8007cc:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cf:	39 d0                	cmp    %edx,%eax
  8007d1:	74 06                	je     8007d9 <strnlen+0x1d>
  8007d3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d7:	75 f3                	jne    8007cc <strnlen+0x10>
	return n;
}
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e5:	89 c2                	mov    %eax,%edx
  8007e7:	83 c1 01             	add    $0x1,%ecx
  8007ea:	83 c2 01             	add    $0x1,%edx
  8007ed:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007f1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007f4:	84 db                	test   %bl,%bl
  8007f6:	75 ef                	jne    8007e7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f8:	5b                   	pop    %ebx
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800802:	53                   	push   %ebx
  800803:	e8 9c ff ff ff       	call   8007a4 <strlen>
  800808:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80080b:	ff 75 0c             	pushl  0xc(%ebp)
  80080e:	01 d8                	add    %ebx,%eax
  800810:	50                   	push   %eax
  800811:	e8 c5 ff ff ff       	call   8007db <strcpy>
	return dst;
}
  800816:	89 d8                	mov    %ebx,%eax
  800818:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081b:	c9                   	leave  
  80081c:	c3                   	ret    

0080081d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	56                   	push   %esi
  800821:	53                   	push   %ebx
  800822:	8b 75 08             	mov    0x8(%ebp),%esi
  800825:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800828:	89 f3                	mov    %esi,%ebx
  80082a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082d:	89 f2                	mov    %esi,%edx
  80082f:	eb 0f                	jmp    800840 <strncpy+0x23>
		*dst++ = *src;
  800831:	83 c2 01             	add    $0x1,%edx
  800834:	0f b6 01             	movzbl (%ecx),%eax
  800837:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083a:	80 39 01             	cmpb   $0x1,(%ecx)
  80083d:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800840:	39 da                	cmp    %ebx,%edx
  800842:	75 ed                	jne    800831 <strncpy+0x14>
	}
	return ret;
}
  800844:	89 f0                	mov    %esi,%eax
  800846:	5b                   	pop    %ebx
  800847:	5e                   	pop    %esi
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	56                   	push   %esi
  80084e:	53                   	push   %ebx
  80084f:	8b 75 08             	mov    0x8(%ebp),%esi
  800852:	8b 55 0c             	mov    0xc(%ebp),%edx
  800855:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800858:	89 f0                	mov    %esi,%eax
  80085a:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085e:	85 c9                	test   %ecx,%ecx
  800860:	75 0b                	jne    80086d <strlcpy+0x23>
  800862:	eb 17                	jmp    80087b <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800864:	83 c2 01             	add    $0x1,%edx
  800867:	83 c0 01             	add    $0x1,%eax
  80086a:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80086d:	39 d8                	cmp    %ebx,%eax
  80086f:	74 07                	je     800878 <strlcpy+0x2e>
  800871:	0f b6 0a             	movzbl (%edx),%ecx
  800874:	84 c9                	test   %cl,%cl
  800876:	75 ec                	jne    800864 <strlcpy+0x1a>
		*dst = '\0';
  800878:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80087b:	29 f0                	sub    %esi,%eax
}
  80087d:	5b                   	pop    %ebx
  80087e:	5e                   	pop    %esi
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800887:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088a:	eb 06                	jmp    800892 <strcmp+0x11>
		p++, q++;
  80088c:	83 c1 01             	add    $0x1,%ecx
  80088f:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800892:	0f b6 01             	movzbl (%ecx),%eax
  800895:	84 c0                	test   %al,%al
  800897:	74 04                	je     80089d <strcmp+0x1c>
  800899:	3a 02                	cmp    (%edx),%al
  80089b:	74 ef                	je     80088c <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089d:	0f b6 c0             	movzbl %al,%eax
  8008a0:	0f b6 12             	movzbl (%edx),%edx
  8008a3:	29 d0                	sub    %edx,%eax
}
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	53                   	push   %ebx
  8008ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b1:	89 c3                	mov    %eax,%ebx
  8008b3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b6:	eb 06                	jmp    8008be <strncmp+0x17>
		n--, p++, q++;
  8008b8:	83 c0 01             	add    $0x1,%eax
  8008bb:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008be:	39 d8                	cmp    %ebx,%eax
  8008c0:	74 16                	je     8008d8 <strncmp+0x31>
  8008c2:	0f b6 08             	movzbl (%eax),%ecx
  8008c5:	84 c9                	test   %cl,%cl
  8008c7:	74 04                	je     8008cd <strncmp+0x26>
  8008c9:	3a 0a                	cmp    (%edx),%cl
  8008cb:	74 eb                	je     8008b8 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cd:	0f b6 00             	movzbl (%eax),%eax
  8008d0:	0f b6 12             	movzbl (%edx),%edx
  8008d3:	29 d0                	sub    %edx,%eax
}
  8008d5:	5b                   	pop    %ebx
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    
		return 0;
  8008d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008dd:	eb f6                	jmp    8008d5 <strncmp+0x2e>

008008df <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e9:	0f b6 10             	movzbl (%eax),%edx
  8008ec:	84 d2                	test   %dl,%dl
  8008ee:	74 09                	je     8008f9 <strchr+0x1a>
		if (*s == c)
  8008f0:	38 ca                	cmp    %cl,%dl
  8008f2:	74 0a                	je     8008fe <strchr+0x1f>
	for (; *s; s++)
  8008f4:	83 c0 01             	add    $0x1,%eax
  8008f7:	eb f0                	jmp    8008e9 <strchr+0xa>
			return (char *) s;
	return 0;
  8008f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 45 08             	mov    0x8(%ebp),%eax
  800906:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090a:	eb 03                	jmp    80090f <strfind+0xf>
  80090c:	83 c0 01             	add    $0x1,%eax
  80090f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800912:	38 ca                	cmp    %cl,%dl
  800914:	74 04                	je     80091a <strfind+0x1a>
  800916:	84 d2                	test   %dl,%dl
  800918:	75 f2                	jne    80090c <strfind+0xc>
			break;
	return (char *) s;
}
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	57                   	push   %edi
  800920:	56                   	push   %esi
  800921:	53                   	push   %ebx
  800922:	8b 7d 08             	mov    0x8(%ebp),%edi
  800925:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800928:	85 c9                	test   %ecx,%ecx
  80092a:	74 13                	je     80093f <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800932:	75 05                	jne    800939 <memset+0x1d>
  800934:	f6 c1 03             	test   $0x3,%cl
  800937:	74 0d                	je     800946 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800939:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093c:	fc                   	cld    
  80093d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80093f:	89 f8                	mov    %edi,%eax
  800941:	5b                   	pop    %ebx
  800942:	5e                   	pop    %esi
  800943:	5f                   	pop    %edi
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    
		c &= 0xFF;
  800946:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094a:	89 d3                	mov    %edx,%ebx
  80094c:	c1 e3 08             	shl    $0x8,%ebx
  80094f:	89 d0                	mov    %edx,%eax
  800951:	c1 e0 18             	shl    $0x18,%eax
  800954:	89 d6                	mov    %edx,%esi
  800956:	c1 e6 10             	shl    $0x10,%esi
  800959:	09 f0                	or     %esi,%eax
  80095b:	09 c2                	or     %eax,%edx
  80095d:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80095f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800962:	89 d0                	mov    %edx,%eax
  800964:	fc                   	cld    
  800965:	f3 ab                	rep stos %eax,%es:(%edi)
  800967:	eb d6                	jmp    80093f <memset+0x23>

00800969 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	57                   	push   %edi
  80096d:	56                   	push   %esi
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8b 75 0c             	mov    0xc(%ebp),%esi
  800974:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800977:	39 c6                	cmp    %eax,%esi
  800979:	73 35                	jae    8009b0 <memmove+0x47>
  80097b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097e:	39 c2                	cmp    %eax,%edx
  800980:	76 2e                	jbe    8009b0 <memmove+0x47>
		s += n;
		d += n;
  800982:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800985:	89 d6                	mov    %edx,%esi
  800987:	09 fe                	or     %edi,%esi
  800989:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098f:	74 0c                	je     80099d <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800991:	83 ef 01             	sub    $0x1,%edi
  800994:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800997:	fd                   	std    
  800998:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80099a:	fc                   	cld    
  80099b:	eb 21                	jmp    8009be <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099d:	f6 c1 03             	test   $0x3,%cl
  8009a0:	75 ef                	jne    800991 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a2:	83 ef 04             	sub    $0x4,%edi
  8009a5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009ab:	fd                   	std    
  8009ac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ae:	eb ea                	jmp    80099a <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b0:	89 f2                	mov    %esi,%edx
  8009b2:	09 c2                	or     %eax,%edx
  8009b4:	f6 c2 03             	test   $0x3,%dl
  8009b7:	74 09                	je     8009c2 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b9:	89 c7                	mov    %eax,%edi
  8009bb:	fc                   	cld    
  8009bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009be:	5e                   	pop    %esi
  8009bf:	5f                   	pop    %edi
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c2:	f6 c1 03             	test   $0x3,%cl
  8009c5:	75 f2                	jne    8009b9 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009ca:	89 c7                	mov    %eax,%edi
  8009cc:	fc                   	cld    
  8009cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cf:	eb ed                	jmp    8009be <memmove+0x55>

008009d1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d4:	ff 75 10             	pushl  0x10(%ebp)
  8009d7:	ff 75 0c             	pushl  0xc(%ebp)
  8009da:	ff 75 08             	pushl  0x8(%ebp)
  8009dd:	e8 87 ff ff ff       	call   800969 <memmove>
}
  8009e2:	c9                   	leave  
  8009e3:	c3                   	ret    

008009e4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ef:	89 c6                	mov    %eax,%esi
  8009f1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f4:	39 f0                	cmp    %esi,%eax
  8009f6:	74 1c                	je     800a14 <memcmp+0x30>
		if (*s1 != *s2)
  8009f8:	0f b6 08             	movzbl (%eax),%ecx
  8009fb:	0f b6 1a             	movzbl (%edx),%ebx
  8009fe:	38 d9                	cmp    %bl,%cl
  800a00:	75 08                	jne    800a0a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	83 c2 01             	add    $0x1,%edx
  800a08:	eb ea                	jmp    8009f4 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a0a:	0f b6 c1             	movzbl %cl,%eax
  800a0d:	0f b6 db             	movzbl %bl,%ebx
  800a10:	29 d8                	sub    %ebx,%eax
  800a12:	eb 05                	jmp    800a19 <memcmp+0x35>
	}

	return 0;
  800a14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a19:	5b                   	pop    %ebx
  800a1a:	5e                   	pop    %esi
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a26:	89 c2                	mov    %eax,%edx
  800a28:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a2b:	39 d0                	cmp    %edx,%eax
  800a2d:	73 09                	jae    800a38 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2f:	38 08                	cmp    %cl,(%eax)
  800a31:	74 05                	je     800a38 <memfind+0x1b>
	for (; s < ends; s++)
  800a33:	83 c0 01             	add    $0x1,%eax
  800a36:	eb f3                	jmp    800a2b <memfind+0xe>
			break;
	return (void *) s;
}
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	57                   	push   %edi
  800a3e:	56                   	push   %esi
  800a3f:	53                   	push   %ebx
  800a40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a46:	eb 03                	jmp    800a4b <strtol+0x11>
		s++;
  800a48:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a4b:	0f b6 01             	movzbl (%ecx),%eax
  800a4e:	3c 20                	cmp    $0x20,%al
  800a50:	74 f6                	je     800a48 <strtol+0xe>
  800a52:	3c 09                	cmp    $0x9,%al
  800a54:	74 f2                	je     800a48 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a56:	3c 2b                	cmp    $0x2b,%al
  800a58:	74 2e                	je     800a88 <strtol+0x4e>
	int neg = 0;
  800a5a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a5f:	3c 2d                	cmp    $0x2d,%al
  800a61:	74 2f                	je     800a92 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a63:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a69:	75 05                	jne    800a70 <strtol+0x36>
  800a6b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6e:	74 2c                	je     800a9c <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a70:	85 db                	test   %ebx,%ebx
  800a72:	75 0a                	jne    800a7e <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a74:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a79:	80 39 30             	cmpb   $0x30,(%ecx)
  800a7c:	74 28                	je     800aa6 <strtol+0x6c>
		base = 10;
  800a7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a83:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a86:	eb 50                	jmp    800ad8 <strtol+0x9e>
		s++;
  800a88:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a8b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a90:	eb d1                	jmp    800a63 <strtol+0x29>
		s++, neg = 1;
  800a92:	83 c1 01             	add    $0x1,%ecx
  800a95:	bf 01 00 00 00       	mov    $0x1,%edi
  800a9a:	eb c7                	jmp    800a63 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa0:	74 0e                	je     800ab0 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800aa2:	85 db                	test   %ebx,%ebx
  800aa4:	75 d8                	jne    800a7e <strtol+0x44>
		s++, base = 8;
  800aa6:	83 c1 01             	add    $0x1,%ecx
  800aa9:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aae:	eb ce                	jmp    800a7e <strtol+0x44>
		s += 2, base = 16;
  800ab0:	83 c1 02             	add    $0x2,%ecx
  800ab3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab8:	eb c4                	jmp    800a7e <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800aba:	8d 72 9f             	lea    -0x61(%edx),%esi
  800abd:	89 f3                	mov    %esi,%ebx
  800abf:	80 fb 19             	cmp    $0x19,%bl
  800ac2:	77 29                	ja     800aed <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ac4:	0f be d2             	movsbl %dl,%edx
  800ac7:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aca:	3b 55 10             	cmp    0x10(%ebp),%edx
  800acd:	7d 30                	jge    800aff <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800acf:	83 c1 01             	add    $0x1,%ecx
  800ad2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad6:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ad8:	0f b6 11             	movzbl (%ecx),%edx
  800adb:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ade:	89 f3                	mov    %esi,%ebx
  800ae0:	80 fb 09             	cmp    $0x9,%bl
  800ae3:	77 d5                	ja     800aba <strtol+0x80>
			dig = *s - '0';
  800ae5:	0f be d2             	movsbl %dl,%edx
  800ae8:	83 ea 30             	sub    $0x30,%edx
  800aeb:	eb dd                	jmp    800aca <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800aed:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af0:	89 f3                	mov    %esi,%ebx
  800af2:	80 fb 19             	cmp    $0x19,%bl
  800af5:	77 08                	ja     800aff <strtol+0xc5>
			dig = *s - 'A' + 10;
  800af7:	0f be d2             	movsbl %dl,%edx
  800afa:	83 ea 37             	sub    $0x37,%edx
  800afd:	eb cb                	jmp    800aca <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b03:	74 05                	je     800b0a <strtol+0xd0>
		*endptr = (char *) s;
  800b05:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b08:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b0a:	89 c2                	mov    %eax,%edx
  800b0c:	f7 da                	neg    %edx
  800b0e:	85 ff                	test   %edi,%edi
  800b10:	0f 45 c2             	cmovne %edx,%eax
}
  800b13:	5b                   	pop    %ebx
  800b14:	5e                   	pop    %esi
  800b15:	5f                   	pop    %edi
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	57                   	push   %edi
  800b1c:	56                   	push   %esi
  800b1d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b23:	8b 55 08             	mov    0x8(%ebp),%edx
  800b26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b29:	89 c3                	mov    %eax,%ebx
  800b2b:	89 c7                	mov    %eax,%edi
  800b2d:	89 c6                	mov    %eax,%esi
  800b2f:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	57                   	push   %edi
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b41:	b8 01 00 00 00       	mov    $0x1,%eax
  800b46:	89 d1                	mov    %edx,%ecx
  800b48:	89 d3                	mov    %edx,%ebx
  800b4a:	89 d7                	mov    %edx,%edi
  800b4c:	89 d6                	mov    %edx,%esi
  800b4e:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	83 ec 1c             	sub    $0x1c,%esp
  800b5e:	e8 66 00 00 00       	call   800bc9 <__x86.get_pc_thunk.ax>
  800b63:	05 9d 14 00 00       	add    $0x149d,%eax
  800b68:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b6b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b70:	8b 55 08             	mov    0x8(%ebp),%edx
  800b73:	b8 03 00 00 00       	mov    $0x3,%eax
  800b78:	89 cb                	mov    %ecx,%ebx
  800b7a:	89 cf                	mov    %ecx,%edi
  800b7c:	89 ce                	mov    %ecx,%esi
  800b7e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b80:	85 c0                	test   %eax,%eax
  800b82:	7f 08                	jg     800b8c <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b87:	5b                   	pop    %ebx
  800b88:	5e                   	pop    %esi
  800b89:	5f                   	pop    %edi
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8c:	83 ec 0c             	sub    $0xc,%esp
  800b8f:	50                   	push   %eax
  800b90:	6a 03                	push   $0x3
  800b92:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800b95:	8d 83 84 f0 ff ff    	lea    -0xf7c(%ebx),%eax
  800b9b:	50                   	push   %eax
  800b9c:	6a 23                	push   $0x23
  800b9e:	8d 83 a1 f0 ff ff    	lea    -0xf5f(%ebx),%eax
  800ba4:	50                   	push   %eax
  800ba5:	e8 23 00 00 00       	call   800bcd <_panic>

00800baa <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bba:	89 d1                	mov    %edx,%ecx
  800bbc:	89 d3                	mov    %edx,%ebx
  800bbe:	89 d7                	mov    %edx,%edi
  800bc0:	89 d6                	mov    %edx,%esi
  800bc2:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <__x86.get_pc_thunk.ax>:
  800bc9:	8b 04 24             	mov    (%esp),%eax
  800bcc:	c3                   	ret    

00800bcd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 0c             	sub    $0xc,%esp
  800bd6:	e8 84 f4 ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800bdb:	81 c3 25 14 00 00    	add    $0x1425,%ebx
	va_list ap;

	va_start(ap, fmt);
  800be1:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800be4:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800bea:	8b 38                	mov    (%eax),%edi
  800bec:	e8 b9 ff ff ff       	call   800baa <sys_getenvid>
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	ff 75 0c             	pushl  0xc(%ebp)
  800bf7:	ff 75 08             	pushl  0x8(%ebp)
  800bfa:	57                   	push   %edi
  800bfb:	50                   	push   %eax
  800bfc:	8d 83 b0 f0 ff ff    	lea    -0xf50(%ebx),%eax
  800c02:	50                   	push   %eax
  800c03:	e8 74 f5 ff ff       	call   80017c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c08:	83 c4 18             	add    $0x18,%esp
  800c0b:	56                   	push   %esi
  800c0c:	ff 75 10             	pushl  0x10(%ebp)
  800c0f:	e8 06 f5 ff ff       	call   80011a <vcprintf>
	cprintf("\n");
  800c14:	8d 83 d4 f0 ff ff    	lea    -0xf2c(%ebx),%eax
  800c1a:	89 04 24             	mov    %eax,(%esp)
  800c1d:	e8 5a f5 ff ff       	call   80017c <cprintf>
  800c22:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c25:	cc                   	int3   
  800c26:	eb fd                	jmp    800c25 <_panic+0x58>
  800c28:	66 90                	xchg   %ax,%ax
  800c2a:	66 90                	xchg   %ax,%ax
  800c2c:	66 90                	xchg   %ax,%ax
  800c2e:	66 90                	xchg   %ax,%ax

00800c30 <__udivdi3>:
  800c30:	55                   	push   %ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 1c             	sub    $0x1c,%esp
  800c37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c3b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c43:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c47:	85 d2                	test   %edx,%edx
  800c49:	75 35                	jne    800c80 <__udivdi3+0x50>
  800c4b:	39 f3                	cmp    %esi,%ebx
  800c4d:	0f 87 bd 00 00 00    	ja     800d10 <__udivdi3+0xe0>
  800c53:	85 db                	test   %ebx,%ebx
  800c55:	89 d9                	mov    %ebx,%ecx
  800c57:	75 0b                	jne    800c64 <__udivdi3+0x34>
  800c59:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5e:	31 d2                	xor    %edx,%edx
  800c60:	f7 f3                	div    %ebx
  800c62:	89 c1                	mov    %eax,%ecx
  800c64:	31 d2                	xor    %edx,%edx
  800c66:	89 f0                	mov    %esi,%eax
  800c68:	f7 f1                	div    %ecx
  800c6a:	89 c6                	mov    %eax,%esi
  800c6c:	89 e8                	mov    %ebp,%eax
  800c6e:	89 f7                	mov    %esi,%edi
  800c70:	f7 f1                	div    %ecx
  800c72:	89 fa                	mov    %edi,%edx
  800c74:	83 c4 1c             	add    $0x1c,%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    
  800c7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c80:	39 f2                	cmp    %esi,%edx
  800c82:	77 7c                	ja     800d00 <__udivdi3+0xd0>
  800c84:	0f bd fa             	bsr    %edx,%edi
  800c87:	83 f7 1f             	xor    $0x1f,%edi
  800c8a:	0f 84 98 00 00 00    	je     800d28 <__udivdi3+0xf8>
  800c90:	89 f9                	mov    %edi,%ecx
  800c92:	b8 20 00 00 00       	mov    $0x20,%eax
  800c97:	29 f8                	sub    %edi,%eax
  800c99:	d3 e2                	shl    %cl,%edx
  800c9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c9f:	89 c1                	mov    %eax,%ecx
  800ca1:	89 da                	mov    %ebx,%edx
  800ca3:	d3 ea                	shr    %cl,%edx
  800ca5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ca9:	09 d1                	or     %edx,%ecx
  800cab:	89 f2                	mov    %esi,%edx
  800cad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cb1:	89 f9                	mov    %edi,%ecx
  800cb3:	d3 e3                	shl    %cl,%ebx
  800cb5:	89 c1                	mov    %eax,%ecx
  800cb7:	d3 ea                	shr    %cl,%edx
  800cb9:	89 f9                	mov    %edi,%ecx
  800cbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cbf:	d3 e6                	shl    %cl,%esi
  800cc1:	89 eb                	mov    %ebp,%ebx
  800cc3:	89 c1                	mov    %eax,%ecx
  800cc5:	d3 eb                	shr    %cl,%ebx
  800cc7:	09 de                	or     %ebx,%esi
  800cc9:	89 f0                	mov    %esi,%eax
  800ccb:	f7 74 24 08          	divl   0x8(%esp)
  800ccf:	89 d6                	mov    %edx,%esi
  800cd1:	89 c3                	mov    %eax,%ebx
  800cd3:	f7 64 24 0c          	mull   0xc(%esp)
  800cd7:	39 d6                	cmp    %edx,%esi
  800cd9:	72 0c                	jb     800ce7 <__udivdi3+0xb7>
  800cdb:	89 f9                	mov    %edi,%ecx
  800cdd:	d3 e5                	shl    %cl,%ebp
  800cdf:	39 c5                	cmp    %eax,%ebp
  800ce1:	73 5d                	jae    800d40 <__udivdi3+0x110>
  800ce3:	39 d6                	cmp    %edx,%esi
  800ce5:	75 59                	jne    800d40 <__udivdi3+0x110>
  800ce7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cea:	31 ff                	xor    %edi,%edi
  800cec:	89 fa                	mov    %edi,%edx
  800cee:	83 c4 1c             	add    $0x1c,%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    
  800cf6:	8d 76 00             	lea    0x0(%esi),%esi
  800cf9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d00:	31 ff                	xor    %edi,%edi
  800d02:	31 c0                	xor    %eax,%eax
  800d04:	89 fa                	mov    %edi,%edx
  800d06:	83 c4 1c             	add    $0x1c,%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    
  800d0e:	66 90                	xchg   %ax,%ax
  800d10:	31 ff                	xor    %edi,%edi
  800d12:	89 e8                	mov    %ebp,%eax
  800d14:	89 f2                	mov    %esi,%edx
  800d16:	f7 f3                	div    %ebx
  800d18:	89 fa                	mov    %edi,%edx
  800d1a:	83 c4 1c             	add    $0x1c,%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    
  800d22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d28:	39 f2                	cmp    %esi,%edx
  800d2a:	72 06                	jb     800d32 <__udivdi3+0x102>
  800d2c:	31 c0                	xor    %eax,%eax
  800d2e:	39 eb                	cmp    %ebp,%ebx
  800d30:	77 d2                	ja     800d04 <__udivdi3+0xd4>
  800d32:	b8 01 00 00 00       	mov    $0x1,%eax
  800d37:	eb cb                	jmp    800d04 <__udivdi3+0xd4>
  800d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d40:	89 d8                	mov    %ebx,%eax
  800d42:	31 ff                	xor    %edi,%edi
  800d44:	eb be                	jmp    800d04 <__udivdi3+0xd4>
  800d46:	66 90                	xchg   %ax,%ax
  800d48:	66 90                	xchg   %ax,%ax
  800d4a:	66 90                	xchg   %ax,%ax
  800d4c:	66 90                	xchg   %ax,%ax
  800d4e:	66 90                	xchg   %ax,%ax

00800d50 <__umoddi3>:
  800d50:	55                   	push   %ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 1c             	sub    $0x1c,%esp
  800d57:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d5b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d67:	85 ed                	test   %ebp,%ebp
  800d69:	89 f0                	mov    %esi,%eax
  800d6b:	89 da                	mov    %ebx,%edx
  800d6d:	75 19                	jne    800d88 <__umoddi3+0x38>
  800d6f:	39 df                	cmp    %ebx,%edi
  800d71:	0f 86 b1 00 00 00    	jbe    800e28 <__umoddi3+0xd8>
  800d77:	f7 f7                	div    %edi
  800d79:	89 d0                	mov    %edx,%eax
  800d7b:	31 d2                	xor    %edx,%edx
  800d7d:	83 c4 1c             	add    $0x1c,%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    
  800d85:	8d 76 00             	lea    0x0(%esi),%esi
  800d88:	39 dd                	cmp    %ebx,%ebp
  800d8a:	77 f1                	ja     800d7d <__umoddi3+0x2d>
  800d8c:	0f bd cd             	bsr    %ebp,%ecx
  800d8f:	83 f1 1f             	xor    $0x1f,%ecx
  800d92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d96:	0f 84 b4 00 00 00    	je     800e50 <__umoddi3+0x100>
  800d9c:	b8 20 00 00 00       	mov    $0x20,%eax
  800da1:	89 c2                	mov    %eax,%edx
  800da3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800da7:	29 c2                	sub    %eax,%edx
  800da9:	89 c1                	mov    %eax,%ecx
  800dab:	89 f8                	mov    %edi,%eax
  800dad:	d3 e5                	shl    %cl,%ebp
  800daf:	89 d1                	mov    %edx,%ecx
  800db1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800db5:	d3 e8                	shr    %cl,%eax
  800db7:	09 c5                	or     %eax,%ebp
  800db9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dbd:	89 c1                	mov    %eax,%ecx
  800dbf:	d3 e7                	shl    %cl,%edi
  800dc1:	89 d1                	mov    %edx,%ecx
  800dc3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800dc7:	89 df                	mov    %ebx,%edi
  800dc9:	d3 ef                	shr    %cl,%edi
  800dcb:	89 c1                	mov    %eax,%ecx
  800dcd:	89 f0                	mov    %esi,%eax
  800dcf:	d3 e3                	shl    %cl,%ebx
  800dd1:	89 d1                	mov    %edx,%ecx
  800dd3:	89 fa                	mov    %edi,%edx
  800dd5:	d3 e8                	shr    %cl,%eax
  800dd7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ddc:	09 d8                	or     %ebx,%eax
  800dde:	f7 f5                	div    %ebp
  800de0:	d3 e6                	shl    %cl,%esi
  800de2:	89 d1                	mov    %edx,%ecx
  800de4:	f7 64 24 08          	mull   0x8(%esp)
  800de8:	39 d1                	cmp    %edx,%ecx
  800dea:	89 c3                	mov    %eax,%ebx
  800dec:	89 d7                	mov    %edx,%edi
  800dee:	72 06                	jb     800df6 <__umoddi3+0xa6>
  800df0:	75 0e                	jne    800e00 <__umoddi3+0xb0>
  800df2:	39 c6                	cmp    %eax,%esi
  800df4:	73 0a                	jae    800e00 <__umoddi3+0xb0>
  800df6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800dfa:	19 ea                	sbb    %ebp,%edx
  800dfc:	89 d7                	mov    %edx,%edi
  800dfe:	89 c3                	mov    %eax,%ebx
  800e00:	89 ca                	mov    %ecx,%edx
  800e02:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e07:	29 de                	sub    %ebx,%esi
  800e09:	19 fa                	sbb    %edi,%edx
  800e0b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e0f:	89 d0                	mov    %edx,%eax
  800e11:	d3 e0                	shl    %cl,%eax
  800e13:	89 d9                	mov    %ebx,%ecx
  800e15:	d3 ee                	shr    %cl,%esi
  800e17:	d3 ea                	shr    %cl,%edx
  800e19:	09 f0                	or     %esi,%eax
  800e1b:	83 c4 1c             	add    $0x1c,%esp
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    
  800e23:	90                   	nop
  800e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e28:	85 ff                	test   %edi,%edi
  800e2a:	89 f9                	mov    %edi,%ecx
  800e2c:	75 0b                	jne    800e39 <__umoddi3+0xe9>
  800e2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e33:	31 d2                	xor    %edx,%edx
  800e35:	f7 f7                	div    %edi
  800e37:	89 c1                	mov    %eax,%ecx
  800e39:	89 d8                	mov    %ebx,%eax
  800e3b:	31 d2                	xor    %edx,%edx
  800e3d:	f7 f1                	div    %ecx
  800e3f:	89 f0                	mov    %esi,%eax
  800e41:	f7 f1                	div    %ecx
  800e43:	e9 31 ff ff ff       	jmp    800d79 <__umoddi3+0x29>
  800e48:	90                   	nop
  800e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e50:	39 dd                	cmp    %ebx,%ebp
  800e52:	72 08                	jb     800e5c <__umoddi3+0x10c>
  800e54:	39 f7                	cmp    %esi,%edi
  800e56:	0f 87 21 ff ff ff    	ja     800d7d <__umoddi3+0x2d>
  800e5c:	89 da                	mov    %ebx,%edx
  800e5e:	89 f0                	mov    %esi,%eax
  800e60:	29 f8                	sub    %edi,%eax
  800e62:	19 ea                	sbb    %ebp,%edx
  800e64:	e9 14 ff ff ff       	jmp    800d7d <__umoddi3+0x2d>
