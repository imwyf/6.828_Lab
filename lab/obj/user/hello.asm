
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
  80003a:	e8 35 00 00 00       	call   800074 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	cprintf("hello, world\n");
  800045:	8d 83 7c ee ff ff    	lea    -0x1184(%ebx),%eax
  80004b:	50                   	push   %eax
  80004c:	e8 40 01 00 00       	call   800191 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800051:	c7 c0 2c 20 80 00    	mov    $0x80202c,%eax
  800057:	8b 00                	mov    (%eax),%eax
  800059:	8b 40 48             	mov    0x48(%eax),%eax
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	50                   	push   %eax
  800060:	8d 83 8a ee ff ff    	lea    -0x1176(%ebx),%eax
  800066:	50                   	push   %eax
  800067:	e8 25 01 00 00       	call   800191 <cprintf>
}
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <__x86.get_pc_thunk.bx>:
  800074:	8b 1c 24             	mov    (%esp),%ebx
  800077:	c3                   	ret    

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	53                   	push   %ebx
  80007c:	83 ec 04             	sub    $0x4,%esp
  80007f:	e8 f0 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800084:	81 c3 7c 1f 00 00    	add    $0x1f7c,%ebx
  80008a:	8b 45 08             	mov    0x8(%ebp),%eax
  80008d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800090:	c7 c1 2c 20 80 00    	mov    $0x80202c,%ecx
  800096:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009c:	85 c0                	test   %eax,%eax
  80009e:	7e 08                	jle    8000a8 <libmain+0x30>
		binaryname = argv[0];
  8000a0:	8b 0a                	mov    (%edx),%ecx
  8000a2:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	52                   	push   %edx
  8000ac:	50                   	push   %eax
  8000ad:	e8 81 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 08 00 00 00       	call   8000bf <exit>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000bd:	c9                   	leave  
  8000be:	c3                   	ret    

008000bf <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	53                   	push   %ebx
  8000c3:	83 ec 10             	sub    $0x10,%esp
  8000c6:	e8 a9 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8000cb:	81 c3 35 1f 00 00    	add    $0x1f35,%ebx
	sys_env_destroy(0);
  8000d1:	6a 00                	push   $0x0
  8000d3:	e8 92 0a 00 00       	call   800b6a <sys_env_destroy>
}
  8000d8:	83 c4 10             	add    $0x10,%esp
  8000db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	e8 8a ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8000ea:	81 c3 16 1f 00 00    	add    $0x1f16,%ebx
  8000f0:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8000f3:	8b 16                	mov    (%esi),%edx
  8000f5:	8d 42 01             	lea    0x1(%edx),%eax
  8000f8:	89 06                	mov    %eax,(%esi)
  8000fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000fd:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800101:	3d ff 00 00 00       	cmp    $0xff,%eax
  800106:	74 0b                	je     800113 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800108:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80010c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800113:	83 ec 08             	sub    $0x8,%esp
  800116:	68 ff 00 00 00       	push   $0xff
  80011b:	8d 46 08             	lea    0x8(%esi),%eax
  80011e:	50                   	push   %eax
  80011f:	e8 09 0a 00 00       	call   800b2d <sys_cputs>
		b->idx = 0;
  800124:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	eb d9                	jmp    800108 <putch+0x28>

0080012f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	53                   	push   %ebx
  800133:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800139:	e8 36 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  80013e:	81 c3 c2 1e 00 00    	add    $0x1ec2,%ebx
	struct printbuf b;

	b.idx = 0;
  800144:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014b:	00 00 00 
	b.cnt = 0;
  80014e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800155:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800158:	ff 75 0c             	pushl  0xc(%ebp)
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800164:	50                   	push   %eax
  800165:	8d 83 e0 e0 ff ff    	lea    -0x1f20(%ebx),%eax
  80016b:	50                   	push   %eax
  80016c:	e8 38 01 00 00       	call   8002a9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800171:	83 c4 08             	add    $0x8,%esp
  800174:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80017a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	e8 a7 09 00 00       	call   800b2d <sys_cputs>

	return b.cnt;
}
  800186:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800197:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019a:	50                   	push   %eax
  80019b:	ff 75 08             	pushl  0x8(%ebp)
  80019e:	e8 8c ff ff ff       	call   80012f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a3:	c9                   	leave  
  8001a4:	c3                   	ret    

008001a5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	57                   	push   %edi
  8001a9:	56                   	push   %esi
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 2c             	sub    $0x2c,%esp
  8001ae:	e8 02 06 00 00       	call   8007b5 <__x86.get_pc_thunk.cx>
  8001b3:	81 c1 4d 1e 00 00    	add    $0x1e4d,%ecx
  8001b9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001bc:	89 c7                	mov    %eax,%edi
  8001be:	89 d6                	mov    %edx,%esi
  8001c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001c9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  8001cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8001d7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8001da:	39 d3                	cmp    %edx,%ebx
  8001dc:	72 09                	jb     8001e7 <printnum+0x42>
  8001de:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e1:	0f 87 83 00 00 00    	ja     80026a <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	ff 75 18             	pushl  0x18(%ebp)
  8001ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f3:	53                   	push   %ebx
  8001f4:	ff 75 10             	pushl  0x10(%ebp)
  8001f7:	83 ec 08             	sub    $0x8,%esp
  8001fa:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fd:	ff 75 d8             	pushl  -0x28(%ebp)
  800200:	ff 75 d4             	pushl  -0x2c(%ebp)
  800203:	ff 75 d0             	pushl  -0x30(%ebp)
  800206:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800209:	e8 32 0a 00 00       	call   800c40 <__udivdi3>
  80020e:	83 c4 18             	add    $0x18,%esp
  800211:	52                   	push   %edx
  800212:	50                   	push   %eax
  800213:	89 f2                	mov    %esi,%edx
  800215:	89 f8                	mov    %edi,%eax
  800217:	e8 89 ff ff ff       	call   8001a5 <printnum>
  80021c:	83 c4 20             	add    $0x20,%esp
  80021f:	eb 13                	jmp    800234 <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800221:	83 ec 08             	sub    $0x8,%esp
  800224:	56                   	push   %esi
  800225:	ff 75 18             	pushl  0x18(%ebp)
  800228:	ff d7                	call   *%edi
  80022a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80022d:	83 eb 01             	sub    $0x1,%ebx
  800230:	85 db                	test   %ebx,%ebx
  800232:	7f ed                	jg     800221 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800234:	83 ec 08             	sub    $0x8,%esp
  800237:	56                   	push   %esi
  800238:	83 ec 04             	sub    $0x4,%esp
  80023b:	ff 75 dc             	pushl  -0x24(%ebp)
  80023e:	ff 75 d8             	pushl  -0x28(%ebp)
  800241:	ff 75 d4             	pushl  -0x2c(%ebp)
  800244:	ff 75 d0             	pushl  -0x30(%ebp)
  800247:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80024a:	89 f3                	mov    %esi,%ebx
  80024c:	e8 0f 0b 00 00       	call   800d60 <__umoddi3>
  800251:	83 c4 14             	add    $0x14,%esp
  800254:	0f be 84 06 ab ee ff 	movsbl -0x1155(%esi,%eax,1),%eax
  80025b:	ff 
  80025c:	50                   	push   %eax
  80025d:	ff d7                	call   *%edi
}
  80025f:	83 c4 10             	add    $0x10,%esp
  800262:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800265:	5b                   	pop    %ebx
  800266:	5e                   	pop    %esi
  800267:	5f                   	pop    %edi
  800268:	5d                   	pop    %ebp
  800269:	c3                   	ret    
  80026a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80026d:	eb be                	jmp    80022d <printnum+0x88>

0080026f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800275:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800279:	8b 10                	mov    (%eax),%edx
  80027b:	3b 50 04             	cmp    0x4(%eax),%edx
  80027e:	73 0a                	jae    80028a <sprintputch+0x1b>
		*b->buf++ = ch;
  800280:	8d 4a 01             	lea    0x1(%edx),%ecx
  800283:	89 08                	mov    %ecx,(%eax)
  800285:	8b 45 08             	mov    0x8(%ebp),%eax
  800288:	88 02                	mov    %al,(%edx)
}
  80028a:	5d                   	pop    %ebp
  80028b:	c3                   	ret    

0080028c <printfmt>:
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800292:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 10             	pushl  0x10(%ebp)
  800299:	ff 75 0c             	pushl  0xc(%ebp)
  80029c:	ff 75 08             	pushl  0x8(%ebp)
  80029f:	e8 05 00 00 00       	call   8002a9 <vprintfmt>
}
  8002a4:	83 c4 10             	add    $0x10,%esp
  8002a7:	c9                   	leave  
  8002a8:	c3                   	ret    

008002a9 <vprintfmt>:
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 2c             	sub    $0x2c,%esp
  8002b2:	e8 bd fd ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8002b7:	81 c3 49 1d 00 00    	add    $0x1d49,%ebx
  8002bd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002c0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c3:	e9 c3 03 00 00       	jmp    80068b <.L35+0x48>
		padc = ' ';
  8002c8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002cc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002d3:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8002da:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8002e9:	8d 47 01             	lea    0x1(%edi),%eax
  8002ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ef:	0f b6 17             	movzbl (%edi),%edx
  8002f2:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002f5:	3c 55                	cmp    $0x55,%al
  8002f7:	0f 87 16 04 00 00    	ja     800713 <.L22>
  8002fd:	0f b6 c0             	movzbl %al,%eax
  800300:	89 d9                	mov    %ebx,%ecx
  800302:	03 8c 83 38 ef ff ff 	add    -0x10c8(%ebx,%eax,4),%ecx
  800309:	ff e1                	jmp    *%ecx

0080030b <.L69>:
  80030b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80030e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800312:	eb d5                	jmp    8002e9 <vprintfmt+0x40>

00800314 <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800317:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80031b:	eb cc                	jmp    8002e9 <vprintfmt+0x40>

0080031d <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80031d:	0f b6 d2             	movzbl %dl,%edx
  800320:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
  800323:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800328:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80032b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80032f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800332:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800335:	83 f9 09             	cmp    $0x9,%ecx
  800338:	77 55                	ja     80038f <.L23+0xf>
			for (precision = 0;; ++fmt)
  80033a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80033d:	eb e9                	jmp    800328 <.L29+0xb>

0080033f <.L26>:
			precision = va_arg(ap, int);
  80033f:	8b 45 14             	mov    0x14(%ebp),%eax
  800342:	8b 00                	mov    (%eax),%eax
  800344:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800347:	8b 45 14             	mov    0x14(%ebp),%eax
  80034a:	8d 40 04             	lea    0x4(%eax),%eax
  80034d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800353:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800357:	79 90                	jns    8002e9 <vprintfmt+0x40>
				width = precision, precision = -1;
  800359:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80035c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800366:	eb 81                	jmp    8002e9 <vprintfmt+0x40>

00800368 <.L27>:
  800368:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036b:	85 c0                	test   %eax,%eax
  80036d:	ba 00 00 00 00       	mov    $0x0,%edx
  800372:	0f 49 d0             	cmovns %eax,%edx
  800375:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037b:	e9 69 ff ff ff       	jmp    8002e9 <vprintfmt+0x40>

00800380 <.L23>:
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800383:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80038a:	e9 5a ff ff ff       	jmp    8002e9 <vprintfmt+0x40>
  80038f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800392:	eb bf                	jmp    800353 <.L26+0x14>

00800394 <.L33>:
			lflag++;
  800394:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80039b:	e9 49 ff ff ff       	jmp    8002e9 <vprintfmt+0x40>

008003a0 <.L30>:
			putch(va_arg(ap, int), putdat);
  8003a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a3:	8d 78 04             	lea    0x4(%eax),%edi
  8003a6:	83 ec 08             	sub    $0x8,%esp
  8003a9:	56                   	push   %esi
  8003aa:	ff 30                	pushl  (%eax)
  8003ac:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003af:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003b2:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003b5:	e9 ce 02 00 00       	jmp    800688 <.L35+0x45>

008003ba <.L32>:
			err = va_arg(ap, int);
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8d 78 04             	lea    0x4(%eax),%edi
  8003c0:	8b 00                	mov    (%eax),%eax
  8003c2:	99                   	cltd   
  8003c3:	31 d0                	xor    %edx,%eax
  8003c5:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c7:	83 f8 06             	cmp    $0x6,%eax
  8003ca:	7f 27                	jg     8003f3 <.L32+0x39>
  8003cc:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8003d3:	85 d2                	test   %edx,%edx
  8003d5:	74 1c                	je     8003f3 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8003d7:	52                   	push   %edx
  8003d8:	8d 83 cc ee ff ff    	lea    -0x1134(%ebx),%eax
  8003de:	50                   	push   %eax
  8003df:	56                   	push   %esi
  8003e0:	ff 75 08             	pushl  0x8(%ebp)
  8003e3:	e8 a4 fe ff ff       	call   80028c <printfmt>
  8003e8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003eb:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003ee:	e9 95 02 00 00       	jmp    800688 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8003f3:	50                   	push   %eax
  8003f4:	8d 83 c3 ee ff ff    	lea    -0x113d(%ebx),%eax
  8003fa:	50                   	push   %eax
  8003fb:	56                   	push   %esi
  8003fc:	ff 75 08             	pushl  0x8(%ebp)
  8003ff:	e8 88 fe ff ff       	call   80028c <printfmt>
  800404:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800407:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80040a:	e9 79 02 00 00       	jmp    800688 <.L35+0x45>

0080040f <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  80040f:	8b 45 14             	mov    0x14(%ebp),%eax
  800412:	83 c0 04             	add    $0x4,%eax
  800415:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800418:	8b 45 14             	mov    0x14(%ebp),%eax
  80041b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80041d:	85 ff                	test   %edi,%edi
  80041f:	8d 83 bc ee ff ff    	lea    -0x1144(%ebx),%eax
  800425:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800428:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042c:	0f 8e b5 00 00 00    	jle    8004e7 <.L36+0xd8>
  800432:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800436:	75 08                	jne    800440 <.L36+0x31>
  800438:	89 75 0c             	mov    %esi,0xc(%ebp)
  80043b:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80043e:	eb 6d                	jmp    8004ad <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800440:	83 ec 08             	sub    $0x8,%esp
  800443:	ff 75 cc             	pushl  -0x34(%ebp)
  800446:	57                   	push   %edi
  800447:	e8 85 03 00 00       	call   8007d1 <strnlen>
  80044c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80044f:	29 c2                	sub    %eax,%edx
  800451:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800454:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800457:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80045b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800461:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800463:	eb 10                	jmp    800475 <.L36+0x66>
					putch(padc, putdat);
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	56                   	push   %esi
  800469:	ff 75 e0             	pushl  -0x20(%ebp)
  80046c:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80046f:	83 ef 01             	sub    $0x1,%edi
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	85 ff                	test   %edi,%edi
  800477:	7f ec                	jg     800465 <.L36+0x56>
  800479:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80047c:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80047f:	85 d2                	test   %edx,%edx
  800481:	b8 00 00 00 00       	mov    $0x0,%eax
  800486:	0f 49 c2             	cmovns %edx,%eax
  800489:	29 c2                	sub    %eax,%edx
  80048b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80048e:	89 75 0c             	mov    %esi,0xc(%ebp)
  800491:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800494:	eb 17                	jmp    8004ad <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  800496:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80049a:	75 30                	jne    8004cc <.L36+0xbd>
					putch(ch, putdat);
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	ff 75 0c             	pushl  0xc(%ebp)
  8004a2:	50                   	push   %eax
  8004a3:	ff 55 08             	call   *0x8(%ebp)
  8004a6:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a9:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8004ad:	83 c7 01             	add    $0x1,%edi
  8004b0:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004b4:	0f be c2             	movsbl %dl,%eax
  8004b7:	85 c0                	test   %eax,%eax
  8004b9:	74 52                	je     80050d <.L36+0xfe>
  8004bb:	85 f6                	test   %esi,%esi
  8004bd:	78 d7                	js     800496 <.L36+0x87>
  8004bf:	83 ee 01             	sub    $0x1,%esi
  8004c2:	79 d2                	jns    800496 <.L36+0x87>
  8004c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004c7:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004ca:	eb 32                	jmp    8004fe <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8004cc:	0f be d2             	movsbl %dl,%edx
  8004cf:	83 ea 20             	sub    $0x20,%edx
  8004d2:	83 fa 5e             	cmp    $0x5e,%edx
  8004d5:	76 c5                	jbe    80049c <.L36+0x8d>
					putch('?', putdat);
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	ff 75 0c             	pushl  0xc(%ebp)
  8004dd:	6a 3f                	push   $0x3f
  8004df:	ff 55 08             	call   *0x8(%ebp)
  8004e2:	83 c4 10             	add    $0x10,%esp
  8004e5:	eb c2                	jmp    8004a9 <.L36+0x9a>
  8004e7:	89 75 0c             	mov    %esi,0xc(%ebp)
  8004ea:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004ed:	eb be                	jmp    8004ad <.L36+0x9e>
				putch(' ', putdat);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	56                   	push   %esi
  8004f3:	6a 20                	push   $0x20
  8004f5:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8004f8:	83 ef 01             	sub    $0x1,%edi
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	85 ff                	test   %edi,%edi
  800500:	7f ed                	jg     8004ef <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800502:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800505:	89 45 14             	mov    %eax,0x14(%ebp)
  800508:	e9 7b 01 00 00       	jmp    800688 <.L35+0x45>
  80050d:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800510:	8b 75 0c             	mov    0xc(%ebp),%esi
  800513:	eb e9                	jmp    8004fe <.L36+0xef>

00800515 <.L31>:
  800515:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800518:	83 f9 01             	cmp    $0x1,%ecx
  80051b:	7e 40                	jle    80055d <.L31+0x48>
		return va_arg(*ap, long long);
  80051d:	8b 45 14             	mov    0x14(%ebp),%eax
  800520:	8b 50 04             	mov    0x4(%eax),%edx
  800523:	8b 00                	mov    (%eax),%eax
  800525:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800528:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8d 40 08             	lea    0x8(%eax),%eax
  800531:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
  800534:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800538:	79 55                	jns    80058f <.L31+0x7a>
				putch('-', putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	56                   	push   %esi
  80053e:	6a 2d                	push   $0x2d
  800540:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  800543:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800546:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800549:	f7 da                	neg    %edx
  80054b:	83 d1 00             	adc    $0x0,%ecx
  80054e:	f7 d9                	neg    %ecx
  800550:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
  800553:	b8 0a 00 00 00       	mov    $0xa,%eax
  800558:	e9 10 01 00 00       	jmp    80066d <.L35+0x2a>
	else if (lflag)
  80055d:	85 c9                	test   %ecx,%ecx
  80055f:	75 17                	jne    800578 <.L31+0x63>
		return va_arg(*ap, int);
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8b 00                	mov    (%eax),%eax
  800566:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800569:	99                   	cltd   
  80056a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 40 04             	lea    0x4(%eax),%eax
  800573:	89 45 14             	mov    %eax,0x14(%ebp)
  800576:	eb bc                	jmp    800534 <.L31+0x1f>
		return va_arg(*ap, long);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8b 00                	mov    (%eax),%eax
  80057d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800580:	99                   	cltd   
  800581:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8d 40 04             	lea    0x4(%eax),%eax
  80058a:	89 45 14             	mov    %eax,0x14(%ebp)
  80058d:	eb a5                	jmp    800534 <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  80058f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800592:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
  800595:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059a:	e9 ce 00 00 00       	jmp    80066d <.L35+0x2a>

0080059f <.L37>:
  80059f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8005a2:	83 f9 01             	cmp    $0x1,%ecx
  8005a5:	7e 18                	jle    8005bf <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8b 10                	mov    (%eax),%edx
  8005ac:	8b 48 04             	mov    0x4(%eax),%ecx
  8005af:	8d 40 08             	lea    0x8(%eax),%eax
  8005b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ba:	e9 ae 00 00 00       	jmp    80066d <.L35+0x2a>
	else if (lflag)
  8005bf:	85 c9                	test   %ecx,%ecx
  8005c1:	75 1a                	jne    8005dd <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8b 10                	mov    (%eax),%edx
  8005c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cd:	8d 40 04             	lea    0x4(%eax),%eax
  8005d0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d8:	e9 90 00 00 00       	jmp    80066d <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8b 10                	mov    (%eax),%edx
  8005e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ed:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f2:	eb 79                	jmp    80066d <.L35+0x2a>

008005f4 <.L34>:
  8005f4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8005f7:	83 f9 01             	cmp    $0x1,%ecx
  8005fa:	7e 15                	jle    800611 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8b 10                	mov    (%eax),%edx
  800601:	8b 48 04             	mov    0x4(%eax),%ecx
  800604:	8d 40 08             	lea    0x8(%eax),%eax
  800607:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80060a:	b8 08 00 00 00       	mov    $0x8,%eax
  80060f:	eb 5c                	jmp    80066d <.L35+0x2a>
	else if (lflag)
  800611:	85 c9                	test   %ecx,%ecx
  800613:	75 17                	jne    80062c <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8b 10                	mov    (%eax),%edx
  80061a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061f:	8d 40 04             	lea    0x4(%eax),%eax
  800622:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800625:	b8 08 00 00 00       	mov    $0x8,%eax
  80062a:	eb 41                	jmp    80066d <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8b 10                	mov    (%eax),%edx
  800631:	b9 00 00 00 00       	mov    $0x0,%ecx
  800636:	8d 40 04             	lea    0x4(%eax),%eax
  800639:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80063c:	b8 08 00 00 00       	mov    $0x8,%eax
  800641:	eb 2a                	jmp    80066d <.L35+0x2a>

00800643 <.L35>:
			putch('0', putdat);
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	56                   	push   %esi
  800647:	6a 30                	push   $0x30
  800649:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80064c:	83 c4 08             	add    $0x8,%esp
  80064f:	56                   	push   %esi
  800650:	6a 78                	push   $0x78
  800652:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8b 10                	mov    (%eax),%edx
  80065a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80065f:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800662:	8d 40 04             	lea    0x4(%eax),%eax
  800665:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800668:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  80066d:	83 ec 0c             	sub    $0xc,%esp
  800670:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800674:	57                   	push   %edi
  800675:	ff 75 e0             	pushl  -0x20(%ebp)
  800678:	50                   	push   %eax
  800679:	51                   	push   %ecx
  80067a:	52                   	push   %edx
  80067b:	89 f2                	mov    %esi,%edx
  80067d:	8b 45 08             	mov    0x8(%ebp),%eax
  800680:	e8 20 fb ff ff       	call   8001a5 <printnum>
			break;
  800685:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800688:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  80068b:	83 c7 01             	add    $0x1,%edi
  80068e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800692:	83 f8 25             	cmp    $0x25,%eax
  800695:	0f 84 2d fc ff ff    	je     8002c8 <vprintfmt+0x1f>
			if (ch == '\0')
  80069b:	85 c0                	test   %eax,%eax
  80069d:	0f 84 91 00 00 00    	je     800734 <.L22+0x21>
			putch(ch, putdat);
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	56                   	push   %esi
  8006a7:	50                   	push   %eax
  8006a8:	ff 55 08             	call   *0x8(%ebp)
  8006ab:	83 c4 10             	add    $0x10,%esp
  8006ae:	eb db                	jmp    80068b <.L35+0x48>

008006b0 <.L38>:
  8006b0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006b3:	83 f9 01             	cmp    $0x1,%ecx
  8006b6:	7e 15                	jle    8006cd <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8b 10                	mov    (%eax),%edx
  8006bd:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c0:	8d 40 08             	lea    0x8(%eax),%eax
  8006c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c6:	b8 10 00 00 00       	mov    $0x10,%eax
  8006cb:	eb a0                	jmp    80066d <.L35+0x2a>
	else if (lflag)
  8006cd:	85 c9                	test   %ecx,%ecx
  8006cf:	75 17                	jne    8006e8 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8b 10                	mov    (%eax),%edx
  8006d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006db:	8d 40 04             	lea    0x4(%eax),%eax
  8006de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e1:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e6:	eb 85                	jmp    80066d <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8b 10                	mov    (%eax),%edx
  8006ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f2:	8d 40 04             	lea    0x4(%eax),%eax
  8006f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f8:	b8 10 00 00 00       	mov    $0x10,%eax
  8006fd:	e9 6b ff ff ff       	jmp    80066d <.L35+0x2a>

00800702 <.L25>:
			putch(ch, putdat);
  800702:	83 ec 08             	sub    $0x8,%esp
  800705:	56                   	push   %esi
  800706:	6a 25                	push   $0x25
  800708:	ff 55 08             	call   *0x8(%ebp)
			break;
  80070b:	83 c4 10             	add    $0x10,%esp
  80070e:	e9 75 ff ff ff       	jmp    800688 <.L35+0x45>

00800713 <.L22>:
			putch('%', putdat);
  800713:	83 ec 08             	sub    $0x8,%esp
  800716:	56                   	push   %esi
  800717:	6a 25                	push   $0x25
  800719:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	89 f8                	mov    %edi,%eax
  800721:	eb 03                	jmp    800726 <.L22+0x13>
  800723:	83 e8 01             	sub    $0x1,%eax
  800726:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80072a:	75 f7                	jne    800723 <.L22+0x10>
  80072c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80072f:	e9 54 ff ff ff       	jmp    800688 <.L35+0x45>
}
  800734:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800737:	5b                   	pop    %ebx
  800738:	5e                   	pop    %esi
  800739:	5f                   	pop    %edi
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	53                   	push   %ebx
  800740:	83 ec 14             	sub    $0x14,%esp
  800743:	e8 2c f9 ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800748:	81 c3 b8 18 00 00    	add    $0x18b8,%ebx
  80074e:	8b 45 08             	mov    0x8(%ebp),%eax
  800751:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  800754:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800757:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80075b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80075e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800765:	85 c0                	test   %eax,%eax
  800767:	74 2b                	je     800794 <vsnprintf+0x58>
  800769:	85 d2                	test   %edx,%edx
  80076b:	7e 27                	jle    800794 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  80076d:	ff 75 14             	pushl  0x14(%ebp)
  800770:	ff 75 10             	pushl  0x10(%ebp)
  800773:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800776:	50                   	push   %eax
  800777:	8d 83 6f e2 ff ff    	lea    -0x1d91(%ebx),%eax
  80077d:	50                   	push   %eax
  80077e:	e8 26 fb ff ff       	call   8002a9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800783:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800786:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800789:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078c:	83 c4 10             	add    $0x10,%esp
}
  80078f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800792:	c9                   	leave  
  800793:	c3                   	ret    
		return -E_INVAL;
  800794:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800799:	eb f4                	jmp    80078f <vsnprintf+0x53>

0080079b <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a4:	50                   	push   %eax
  8007a5:	ff 75 10             	pushl  0x10(%ebp)
  8007a8:	ff 75 0c             	pushl  0xc(%ebp)
  8007ab:	ff 75 08             	pushl  0x8(%ebp)
  8007ae:	e8 89 ff ff ff       	call   80073c <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b3:	c9                   	leave  
  8007b4:	c3                   	ret    

008007b5 <__x86.get_pc_thunk.cx>:
  8007b5:	8b 0c 24             	mov    (%esp),%ecx
  8007b8:	c3                   	ret    

008007b9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c4:	eb 03                	jmp    8007c9 <strlen+0x10>
		n++;
  8007c6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007c9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cd:	75 f7                	jne    8007c6 <strlen+0xd>
	return n;
}
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007da:	b8 00 00 00 00       	mov    $0x0,%eax
  8007df:	eb 03                	jmp    8007e4 <strnlen+0x13>
		n++;
  8007e1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e4:	39 d0                	cmp    %edx,%eax
  8007e6:	74 06                	je     8007ee <strnlen+0x1d>
  8007e8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ec:	75 f3                	jne    8007e1 <strnlen+0x10>
	return n;
}
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	53                   	push   %ebx
  8007f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fa:	89 c2                	mov    %eax,%edx
  8007fc:	83 c1 01             	add    $0x1,%ecx
  8007ff:	83 c2 01             	add    $0x1,%edx
  800802:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800806:	88 5a ff             	mov    %bl,-0x1(%edx)
  800809:	84 db                	test   %bl,%bl
  80080b:	75 ef                	jne    8007fc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80080d:	5b                   	pop    %ebx
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	53                   	push   %ebx
  800814:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800817:	53                   	push   %ebx
  800818:	e8 9c ff ff ff       	call   8007b9 <strlen>
  80081d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800820:	ff 75 0c             	pushl  0xc(%ebp)
  800823:	01 d8                	add    %ebx,%eax
  800825:	50                   	push   %eax
  800826:	e8 c5 ff ff ff       	call   8007f0 <strcpy>
	return dst;
}
  80082b:	89 d8                	mov    %ebx,%eax
  80082d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800830:	c9                   	leave  
  800831:	c3                   	ret    

00800832 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	56                   	push   %esi
  800836:	53                   	push   %ebx
  800837:	8b 75 08             	mov    0x8(%ebp),%esi
  80083a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083d:	89 f3                	mov    %esi,%ebx
  80083f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800842:	89 f2                	mov    %esi,%edx
  800844:	eb 0f                	jmp    800855 <strncpy+0x23>
		*dst++ = *src;
  800846:	83 c2 01             	add    $0x1,%edx
  800849:	0f b6 01             	movzbl (%ecx),%eax
  80084c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084f:	80 39 01             	cmpb   $0x1,(%ecx)
  800852:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800855:	39 da                	cmp    %ebx,%edx
  800857:	75 ed                	jne    800846 <strncpy+0x14>
	}
	return ret;
}
  800859:	89 f0                	mov    %esi,%eax
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	8b 75 08             	mov    0x8(%ebp),%esi
  800867:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80086d:	89 f0                	mov    %esi,%eax
  80086f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800873:	85 c9                	test   %ecx,%ecx
  800875:	75 0b                	jne    800882 <strlcpy+0x23>
  800877:	eb 17                	jmp    800890 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800879:	83 c2 01             	add    $0x1,%edx
  80087c:	83 c0 01             	add    $0x1,%eax
  80087f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800882:	39 d8                	cmp    %ebx,%eax
  800884:	74 07                	je     80088d <strlcpy+0x2e>
  800886:	0f b6 0a             	movzbl (%edx),%ecx
  800889:	84 c9                	test   %cl,%cl
  80088b:	75 ec                	jne    800879 <strlcpy+0x1a>
		*dst = '\0';
  80088d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800890:	29 f0                	sub    %esi,%eax
}
  800892:	5b                   	pop    %ebx
  800893:	5e                   	pop    %esi
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089f:	eb 06                	jmp    8008a7 <strcmp+0x11>
		p++, q++;
  8008a1:	83 c1 01             	add    $0x1,%ecx
  8008a4:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008a7:	0f b6 01             	movzbl (%ecx),%eax
  8008aa:	84 c0                	test   %al,%al
  8008ac:	74 04                	je     8008b2 <strcmp+0x1c>
  8008ae:	3a 02                	cmp    (%edx),%al
  8008b0:	74 ef                	je     8008a1 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b2:	0f b6 c0             	movzbl %al,%eax
  8008b5:	0f b6 12             	movzbl (%edx),%edx
  8008b8:	29 d0                	sub    %edx,%eax
}
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	53                   	push   %ebx
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c6:	89 c3                	mov    %eax,%ebx
  8008c8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008cb:	eb 06                	jmp    8008d3 <strncmp+0x17>
		n--, p++, q++;
  8008cd:	83 c0 01             	add    $0x1,%eax
  8008d0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008d3:	39 d8                	cmp    %ebx,%eax
  8008d5:	74 16                	je     8008ed <strncmp+0x31>
  8008d7:	0f b6 08             	movzbl (%eax),%ecx
  8008da:	84 c9                	test   %cl,%cl
  8008dc:	74 04                	je     8008e2 <strncmp+0x26>
  8008de:	3a 0a                	cmp    (%edx),%cl
  8008e0:	74 eb                	je     8008cd <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e2:	0f b6 00             	movzbl (%eax),%eax
  8008e5:	0f b6 12             	movzbl (%edx),%edx
  8008e8:	29 d0                	sub    %edx,%eax
}
  8008ea:	5b                   	pop    %ebx
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    
		return 0;
  8008ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f2:	eb f6                	jmp    8008ea <strncmp+0x2e>

008008f4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fe:	0f b6 10             	movzbl (%eax),%edx
  800901:	84 d2                	test   %dl,%dl
  800903:	74 09                	je     80090e <strchr+0x1a>
		if (*s == c)
  800905:	38 ca                	cmp    %cl,%dl
  800907:	74 0a                	je     800913 <strchr+0x1f>
	for (; *s; s++)
  800909:	83 c0 01             	add    $0x1,%eax
  80090c:	eb f0                	jmp    8008fe <strchr+0xa>
			return (char *) s;
	return 0;
  80090e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091f:	eb 03                	jmp    800924 <strfind+0xf>
  800921:	83 c0 01             	add    $0x1,%eax
  800924:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800927:	38 ca                	cmp    %cl,%dl
  800929:	74 04                	je     80092f <strfind+0x1a>
  80092b:	84 d2                	test   %dl,%dl
  80092d:	75 f2                	jne    800921 <strfind+0xc>
			break;
	return (char *) s;
}
  80092f:	5d                   	pop    %ebp
  800930:	c3                   	ret    

00800931 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	57                   	push   %edi
  800935:	56                   	push   %esi
  800936:	53                   	push   %ebx
  800937:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093d:	85 c9                	test   %ecx,%ecx
  80093f:	74 13                	je     800954 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800941:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800947:	75 05                	jne    80094e <memset+0x1d>
  800949:	f6 c1 03             	test   $0x3,%cl
  80094c:	74 0d                	je     80095b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800951:	fc                   	cld    
  800952:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800954:	89 f8                	mov    %edi,%eax
  800956:	5b                   	pop    %ebx
  800957:	5e                   	pop    %esi
  800958:	5f                   	pop    %edi
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    
		c &= 0xFF;
  80095b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095f:	89 d3                	mov    %edx,%ebx
  800961:	c1 e3 08             	shl    $0x8,%ebx
  800964:	89 d0                	mov    %edx,%eax
  800966:	c1 e0 18             	shl    $0x18,%eax
  800969:	89 d6                	mov    %edx,%esi
  80096b:	c1 e6 10             	shl    $0x10,%esi
  80096e:	09 f0                	or     %esi,%eax
  800970:	09 c2                	or     %eax,%edx
  800972:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800974:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800977:	89 d0                	mov    %edx,%eax
  800979:	fc                   	cld    
  80097a:	f3 ab                	rep stos %eax,%es:(%edi)
  80097c:	eb d6                	jmp    800954 <memset+0x23>

0080097e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	57                   	push   %edi
  800982:	56                   	push   %esi
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	8b 75 0c             	mov    0xc(%ebp),%esi
  800989:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098c:	39 c6                	cmp    %eax,%esi
  80098e:	73 35                	jae    8009c5 <memmove+0x47>
  800990:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800993:	39 c2                	cmp    %eax,%edx
  800995:	76 2e                	jbe    8009c5 <memmove+0x47>
		s += n;
		d += n;
  800997:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099a:	89 d6                	mov    %edx,%esi
  80099c:	09 fe                	or     %edi,%esi
  80099e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a4:	74 0c                	je     8009b2 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a6:	83 ef 01             	sub    $0x1,%edi
  8009a9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009ac:	fd                   	std    
  8009ad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009af:	fc                   	cld    
  8009b0:	eb 21                	jmp    8009d3 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b2:	f6 c1 03             	test   $0x3,%cl
  8009b5:	75 ef                	jne    8009a6 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b7:	83 ef 04             	sub    $0x4,%edi
  8009ba:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009c0:	fd                   	std    
  8009c1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c3:	eb ea                	jmp    8009af <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c5:	89 f2                	mov    %esi,%edx
  8009c7:	09 c2                	or     %eax,%edx
  8009c9:	f6 c2 03             	test   $0x3,%dl
  8009cc:	74 09                	je     8009d7 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ce:	89 c7                	mov    %eax,%edi
  8009d0:	fc                   	cld    
  8009d1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d3:	5e                   	pop    %esi
  8009d4:	5f                   	pop    %edi
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d7:	f6 c1 03             	test   $0x3,%cl
  8009da:	75 f2                	jne    8009ce <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009dc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009df:	89 c7                	mov    %eax,%edi
  8009e1:	fc                   	cld    
  8009e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e4:	eb ed                	jmp    8009d3 <memmove+0x55>

008009e6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009e9:	ff 75 10             	pushl  0x10(%ebp)
  8009ec:	ff 75 0c             	pushl  0xc(%ebp)
  8009ef:	ff 75 08             	pushl  0x8(%ebp)
  8009f2:	e8 87 ff ff ff       	call   80097e <memmove>
}
  8009f7:	c9                   	leave  
  8009f8:	c3                   	ret    

008009f9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	56                   	push   %esi
  8009fd:	53                   	push   %ebx
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a04:	89 c6                	mov    %eax,%esi
  800a06:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a09:	39 f0                	cmp    %esi,%eax
  800a0b:	74 1c                	je     800a29 <memcmp+0x30>
		if (*s1 != *s2)
  800a0d:	0f b6 08             	movzbl (%eax),%ecx
  800a10:	0f b6 1a             	movzbl (%edx),%ebx
  800a13:	38 d9                	cmp    %bl,%cl
  800a15:	75 08                	jne    800a1f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a17:	83 c0 01             	add    $0x1,%eax
  800a1a:	83 c2 01             	add    $0x1,%edx
  800a1d:	eb ea                	jmp    800a09 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a1f:	0f b6 c1             	movzbl %cl,%eax
  800a22:	0f b6 db             	movzbl %bl,%ebx
  800a25:	29 d8                	sub    %ebx,%eax
  800a27:	eb 05                	jmp    800a2e <memcmp+0x35>
	}

	return 0;
  800a29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2e:	5b                   	pop    %ebx
  800a2f:	5e                   	pop    %esi
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	8b 45 08             	mov    0x8(%ebp),%eax
  800a38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a3b:	89 c2                	mov    %eax,%edx
  800a3d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a40:	39 d0                	cmp    %edx,%eax
  800a42:	73 09                	jae    800a4d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a44:	38 08                	cmp    %cl,(%eax)
  800a46:	74 05                	je     800a4d <memfind+0x1b>
	for (; s < ends; s++)
  800a48:	83 c0 01             	add    $0x1,%eax
  800a4b:	eb f3                	jmp    800a40 <memfind+0xe>
			break;
	return (void *) s;
}
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	57                   	push   %edi
  800a53:	56                   	push   %esi
  800a54:	53                   	push   %ebx
  800a55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5b:	eb 03                	jmp    800a60 <strtol+0x11>
		s++;
  800a5d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a60:	0f b6 01             	movzbl (%ecx),%eax
  800a63:	3c 20                	cmp    $0x20,%al
  800a65:	74 f6                	je     800a5d <strtol+0xe>
  800a67:	3c 09                	cmp    $0x9,%al
  800a69:	74 f2                	je     800a5d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a6b:	3c 2b                	cmp    $0x2b,%al
  800a6d:	74 2e                	je     800a9d <strtol+0x4e>
	int neg = 0;
  800a6f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a74:	3c 2d                	cmp    $0x2d,%al
  800a76:	74 2f                	je     800aa7 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a78:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a7e:	75 05                	jne    800a85 <strtol+0x36>
  800a80:	80 39 30             	cmpb   $0x30,(%ecx)
  800a83:	74 2c                	je     800ab1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a85:	85 db                	test   %ebx,%ebx
  800a87:	75 0a                	jne    800a93 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a89:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a8e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a91:	74 28                	je     800abb <strtol+0x6c>
		base = 10;
  800a93:	b8 00 00 00 00       	mov    $0x0,%eax
  800a98:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a9b:	eb 50                	jmp    800aed <strtol+0x9e>
		s++;
  800a9d:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800aa0:	bf 00 00 00 00       	mov    $0x0,%edi
  800aa5:	eb d1                	jmp    800a78 <strtol+0x29>
		s++, neg = 1;
  800aa7:	83 c1 01             	add    $0x1,%ecx
  800aaa:	bf 01 00 00 00       	mov    $0x1,%edi
  800aaf:	eb c7                	jmp    800a78 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab5:	74 0e                	je     800ac5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ab7:	85 db                	test   %ebx,%ebx
  800ab9:	75 d8                	jne    800a93 <strtol+0x44>
		s++, base = 8;
  800abb:	83 c1 01             	add    $0x1,%ecx
  800abe:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ac3:	eb ce                	jmp    800a93 <strtol+0x44>
		s += 2, base = 16;
  800ac5:	83 c1 02             	add    $0x2,%ecx
  800ac8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800acd:	eb c4                	jmp    800a93 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800acf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad2:	89 f3                	mov    %esi,%ebx
  800ad4:	80 fb 19             	cmp    $0x19,%bl
  800ad7:	77 29                	ja     800b02 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ad9:	0f be d2             	movsbl %dl,%edx
  800adc:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800adf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ae2:	7d 30                	jge    800b14 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ae4:	83 c1 01             	add    $0x1,%ecx
  800ae7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aeb:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800aed:	0f b6 11             	movzbl (%ecx),%edx
  800af0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af3:	89 f3                	mov    %esi,%ebx
  800af5:	80 fb 09             	cmp    $0x9,%bl
  800af8:	77 d5                	ja     800acf <strtol+0x80>
			dig = *s - '0';
  800afa:	0f be d2             	movsbl %dl,%edx
  800afd:	83 ea 30             	sub    $0x30,%edx
  800b00:	eb dd                	jmp    800adf <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b02:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b05:	89 f3                	mov    %esi,%ebx
  800b07:	80 fb 19             	cmp    $0x19,%bl
  800b0a:	77 08                	ja     800b14 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b0c:	0f be d2             	movsbl %dl,%edx
  800b0f:	83 ea 37             	sub    $0x37,%edx
  800b12:	eb cb                	jmp    800adf <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b14:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b18:	74 05                	je     800b1f <strtol+0xd0>
		*endptr = (char *) s;
  800b1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b1f:	89 c2                	mov    %eax,%edx
  800b21:	f7 da                	neg    %edx
  800b23:	85 ff                	test   %edi,%edi
  800b25:	0f 45 c2             	cmovne %edx,%eax
}
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b33:	b8 00 00 00 00       	mov    $0x0,%eax
  800b38:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3e:	89 c3                	mov    %eax,%ebx
  800b40:	89 c7                	mov    %eax,%edi
  800b42:	89 c6                	mov    %eax,%esi
  800b44:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5f                   	pop    %edi
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	57                   	push   %edi
  800b4f:	56                   	push   %esi
  800b50:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b51:	ba 00 00 00 00       	mov    $0x0,%edx
  800b56:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5b:	89 d1                	mov    %edx,%ecx
  800b5d:	89 d3                	mov    %edx,%ebx
  800b5f:	89 d7                	mov    %edx,%edi
  800b61:	89 d6                	mov    %edx,%esi
  800b63:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b65:	5b                   	pop    %ebx
  800b66:	5e                   	pop    %esi
  800b67:	5f                   	pop    %edi
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	57                   	push   %edi
  800b6e:	56                   	push   %esi
  800b6f:	53                   	push   %ebx
  800b70:	83 ec 1c             	sub    $0x1c,%esp
  800b73:	e8 66 00 00 00       	call   800bde <__x86.get_pc_thunk.ax>
  800b78:	05 88 14 00 00       	add    $0x1488,%eax
  800b7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b80:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b85:	8b 55 08             	mov    0x8(%ebp),%edx
  800b88:	b8 03 00 00 00       	mov    $0x3,%eax
  800b8d:	89 cb                	mov    %ecx,%ebx
  800b8f:	89 cf                	mov    %ecx,%edi
  800b91:	89 ce                	mov    %ecx,%esi
  800b93:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b95:	85 c0                	test   %eax,%eax
  800b97:	7f 08                	jg     800ba1 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba1:	83 ec 0c             	sub    $0xc,%esp
  800ba4:	50                   	push   %eax
  800ba5:	6a 03                	push   $0x3
  800ba7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800baa:	8d 83 90 f0 ff ff    	lea    -0xf70(%ebx),%eax
  800bb0:	50                   	push   %eax
  800bb1:	6a 23                	push   $0x23
  800bb3:	8d 83 ad f0 ff ff    	lea    -0xf53(%ebx),%eax
  800bb9:	50                   	push   %eax
  800bba:	e8 23 00 00 00       	call   800be2 <_panic>

00800bbf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bca:	b8 02 00 00 00       	mov    $0x2,%eax
  800bcf:	89 d1                	mov    %edx,%ecx
  800bd1:	89 d3                	mov    %edx,%ebx
  800bd3:	89 d7                	mov    %edx,%edi
  800bd5:	89 d6                	mov    %edx,%esi
  800bd7:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <__x86.get_pc_thunk.ax>:
  800bde:	8b 04 24             	mov    (%esp),%eax
  800be1:	c3                   	ret    

00800be2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	83 ec 0c             	sub    $0xc,%esp
  800beb:	e8 84 f4 ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800bf0:	81 c3 10 14 00 00    	add    $0x1410,%ebx
	va_list ap;

	va_start(ap, fmt);
  800bf6:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800bf9:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800bff:	8b 38                	mov    (%eax),%edi
  800c01:	e8 b9 ff ff ff       	call   800bbf <sys_getenvid>
  800c06:	83 ec 0c             	sub    $0xc,%esp
  800c09:	ff 75 0c             	pushl  0xc(%ebp)
  800c0c:	ff 75 08             	pushl  0x8(%ebp)
  800c0f:	57                   	push   %edi
  800c10:	50                   	push   %eax
  800c11:	8d 83 bc f0 ff ff    	lea    -0xf44(%ebx),%eax
  800c17:	50                   	push   %eax
  800c18:	e8 74 f5 ff ff       	call   800191 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c1d:	83 c4 18             	add    $0x18,%esp
  800c20:	56                   	push   %esi
  800c21:	ff 75 10             	pushl  0x10(%ebp)
  800c24:	e8 06 f5 ff ff       	call   80012f <vcprintf>
	cprintf("\n");
  800c29:	8d 83 88 ee ff ff    	lea    -0x1178(%ebx),%eax
  800c2f:	89 04 24             	mov    %eax,(%esp)
  800c32:	e8 5a f5 ff ff       	call   800191 <cprintf>
  800c37:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c3a:	cc                   	int3   
  800c3b:	eb fd                	jmp    800c3a <_panic+0x58>
  800c3d:	66 90                	xchg   %ax,%ax
  800c3f:	90                   	nop

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
