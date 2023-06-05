
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
  800045:	8d 83 dc f0 ff ff    	lea    -0xf24(%ebx),%eax
  80004b:	50                   	push   %eax
  80004c:	e8 54 01 00 00       	call   8001a5 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800051:	c7 c0 44 20 80 00    	mov    $0x802044,%eax
  800057:	8b 00                	mov    (%eax),%eax
  800059:	8b 40 48             	mov    0x48(%eax),%eax
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	50                   	push   %eax
  800060:	8d 83 ea f0 ff ff    	lea    -0xf16(%ebx),%eax
  800066:	50                   	push   %eax
  800067:	e8 39 01 00 00       	call   8001a5 <cprintf>
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

void libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	57                   	push   %edi
  80007c:	56                   	push   %esi
  80007d:	53                   	push   %ebx
  80007e:	83 ec 0c             	sub    $0xc,%esp
  800081:	e8 ee ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800086:	81 c3 7a 1f 00 00    	add    $0x1f7a,%ebx
  80008c:	8b 75 08             	mov    0x8(%ebp),%esi
  80008f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())]; // ENVX()得到id在Env[]数组中对应的下标
  800092:	e8 3c 0b 00 00       	call   800bd3 <sys_getenvid>
  800097:	25 ff 03 00 00       	and    $0x3ff,%eax
  80009c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80009f:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  8000a5:	c7 c2 44 20 80 00    	mov    $0x802044,%edx
  8000ab:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ad:	85 f6                	test   %esi,%esi
  8000af:	7e 08                	jle    8000b9 <libmain+0x41>
		binaryname = argv[0];
  8000b1:	8b 07                	mov    (%edi),%eax
  8000b3:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000b9:	83 ec 08             	sub    $0x8,%esp
  8000bc:	57                   	push   %edi
  8000bd:	56                   	push   %esi
  8000be:	e8 70 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000c3:	e8 0b 00 00 00       	call   8000d3 <exit>
}
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	53                   	push   %ebx
  8000d7:	83 ec 10             	sub    $0x10,%esp
  8000da:	e8 95 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8000df:	81 c3 21 1f 00 00    	add    $0x1f21,%ebx
	sys_env_destroy(0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	e8 92 0a 00 00       	call   800b7e <sys_env_destroy>
}
  8000ec:	83 c4 10             	add    $0x10,%esp
  8000ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	e8 76 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8000fe:	81 c3 02 1f 00 00    	add    $0x1f02,%ebx
  800104:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  800107:	8b 16                	mov    (%esi),%edx
  800109:	8d 42 01             	lea    0x1(%edx),%eax
  80010c:	89 06                	mov    %eax,(%esi)
  80010e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800111:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800115:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011a:	74 0b                	je     800127 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80011c:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800127:	83 ec 08             	sub    $0x8,%esp
  80012a:	68 ff 00 00 00       	push   $0xff
  80012f:	8d 46 08             	lea    0x8(%esi),%eax
  800132:	50                   	push   %eax
  800133:	e8 09 0a 00 00       	call   800b41 <sys_cputs>
		b->idx = 0;
  800138:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	eb d9                	jmp    80011c <putch+0x28>

00800143 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	53                   	push   %ebx
  800147:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80014d:	e8 22 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800152:	81 c3 ae 1e 00 00    	add    $0x1eae,%ebx
	struct printbuf b;

	b.idx = 0;
  800158:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015f:	00 00 00 
	b.cnt = 0;
  800162:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800169:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016c:	ff 75 0c             	pushl  0xc(%ebp)
  80016f:	ff 75 08             	pushl  0x8(%ebp)
  800172:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800178:	50                   	push   %eax
  800179:	8d 83 f4 e0 ff ff    	lea    -0x1f0c(%ebx),%eax
  80017f:	50                   	push   %eax
  800180:	e8 38 01 00 00       	call   8002bd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800185:	83 c4 08             	add    $0x8,%esp
  800188:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80018e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800194:	50                   	push   %eax
  800195:	e8 a7 09 00 00       	call   800b41 <sys_cputs>

	return b.cnt;
}
  80019a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a3:	c9                   	leave  
  8001a4:	c3                   	ret    

008001a5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ab:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ae:	50                   	push   %eax
  8001af:	ff 75 08             	pushl  0x8(%ebp)
  8001b2:	e8 8c ff ff ff       	call   800143 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    

008001b9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	57                   	push   %edi
  8001bd:	56                   	push   %esi
  8001be:	53                   	push   %ebx
  8001bf:	83 ec 2c             	sub    $0x2c,%esp
  8001c2:	e8 02 06 00 00       	call   8007c9 <__x86.get_pc_thunk.cx>
  8001c7:	81 c1 39 1e 00 00    	add    $0x1e39,%ecx
  8001cd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001d0:	89 c7                	mov    %eax,%edi
  8001d2:	89 d6                	mov    %edx,%esi
  8001d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001da:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001dd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  8001e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8001eb:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8001ee:	39 d3                	cmp    %edx,%ebx
  8001f0:	72 09                	jb     8001fb <printnum+0x42>
  8001f2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f5:	0f 87 83 00 00 00    	ja     80027e <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fb:	83 ec 0c             	sub    $0xc,%esp
  8001fe:	ff 75 18             	pushl  0x18(%ebp)
  800201:	8b 45 14             	mov    0x14(%ebp),%eax
  800204:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800207:	53                   	push   %ebx
  800208:	ff 75 10             	pushl  0x10(%ebp)
  80020b:	83 ec 08             	sub    $0x8,%esp
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	ff 75 d4             	pushl  -0x2c(%ebp)
  800217:	ff 75 d0             	pushl  -0x30(%ebp)
  80021a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80021d:	e8 7e 0c 00 00       	call   800ea0 <__udivdi3>
  800222:	83 c4 18             	add    $0x18,%esp
  800225:	52                   	push   %edx
  800226:	50                   	push   %eax
  800227:	89 f2                	mov    %esi,%edx
  800229:	89 f8                	mov    %edi,%eax
  80022b:	e8 89 ff ff ff       	call   8001b9 <printnum>
  800230:	83 c4 20             	add    $0x20,%esp
  800233:	eb 13                	jmp    800248 <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800235:	83 ec 08             	sub    $0x8,%esp
  800238:	56                   	push   %esi
  800239:	ff 75 18             	pushl  0x18(%ebp)
  80023c:	ff d7                	call   *%edi
  80023e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800241:	83 eb 01             	sub    $0x1,%ebx
  800244:	85 db                	test   %ebx,%ebx
  800246:	7f ed                	jg     800235 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800248:	83 ec 08             	sub    $0x8,%esp
  80024b:	56                   	push   %esi
  80024c:	83 ec 04             	sub    $0x4,%esp
  80024f:	ff 75 dc             	pushl  -0x24(%ebp)
  800252:	ff 75 d8             	pushl  -0x28(%ebp)
  800255:	ff 75 d4             	pushl  -0x2c(%ebp)
  800258:	ff 75 d0             	pushl  -0x30(%ebp)
  80025b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80025e:	89 f3                	mov    %esi,%ebx
  800260:	e8 5b 0d 00 00       	call   800fc0 <__umoddi3>
  800265:	83 c4 14             	add    $0x14,%esp
  800268:	0f be 84 06 0b f1 ff 	movsbl -0xef5(%esi,%eax,1),%eax
  80026f:	ff 
  800270:	50                   	push   %eax
  800271:	ff d7                	call   *%edi
}
  800273:	83 c4 10             	add    $0x10,%esp
  800276:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800279:	5b                   	pop    %ebx
  80027a:	5e                   	pop    %esi
  80027b:	5f                   	pop    %edi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    
  80027e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800281:	eb be                	jmp    800241 <printnum+0x88>

00800283 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800289:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80028d:	8b 10                	mov    (%eax),%edx
  80028f:	3b 50 04             	cmp    0x4(%eax),%edx
  800292:	73 0a                	jae    80029e <sprintputch+0x1b>
		*b->buf++ = ch;
  800294:	8d 4a 01             	lea    0x1(%edx),%ecx
  800297:	89 08                	mov    %ecx,(%eax)
  800299:	8b 45 08             	mov    0x8(%ebp),%eax
  80029c:	88 02                	mov    %al,(%edx)
}
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <printfmt>:
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002a6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a9:	50                   	push   %eax
  8002aa:	ff 75 10             	pushl  0x10(%ebp)
  8002ad:	ff 75 0c             	pushl  0xc(%ebp)
  8002b0:	ff 75 08             	pushl  0x8(%ebp)
  8002b3:	e8 05 00 00 00       	call   8002bd <vprintfmt>
}
  8002b8:	83 c4 10             	add    $0x10,%esp
  8002bb:	c9                   	leave  
  8002bc:	c3                   	ret    

008002bd <vprintfmt>:
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	57                   	push   %edi
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
  8002c3:	83 ec 2c             	sub    $0x2c,%esp
  8002c6:	e8 a9 fd ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8002cb:	81 c3 35 1d 00 00    	add    $0x1d35,%ebx
  8002d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002d4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d7:	e9 c3 03 00 00       	jmp    80069f <.L35+0x48>
		padc = ' ';
  8002dc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8002e0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002e7:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8002ee:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002fa:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8002fd:	8d 47 01             	lea    0x1(%edi),%eax
  800300:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800303:	0f b6 17             	movzbl (%edi),%edx
  800306:	8d 42 dd             	lea    -0x23(%edx),%eax
  800309:	3c 55                	cmp    $0x55,%al
  80030b:	0f 87 16 04 00 00    	ja     800727 <.L22>
  800311:	0f b6 c0             	movzbl %al,%eax
  800314:	89 d9                	mov    %ebx,%ecx
  800316:	03 8c 83 c4 f1 ff ff 	add    -0xe3c(%ebx,%eax,4),%ecx
  80031d:	ff e1                	jmp    *%ecx

0080031f <.L69>:
  80031f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800322:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800326:	eb d5                	jmp    8002fd <vprintfmt+0x40>

00800328 <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80032b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80032f:	eb cc                	jmp    8002fd <vprintfmt+0x40>

00800331 <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800331:	0f b6 d2             	movzbl %dl,%edx
  800334:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
  800337:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  80033c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800343:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800346:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800349:	83 f9 09             	cmp    $0x9,%ecx
  80034c:	77 55                	ja     8003a3 <.L23+0xf>
			for (precision = 0;; ++fmt)
  80034e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800351:	eb e9                	jmp    80033c <.L29+0xb>

00800353 <.L26>:
			precision = va_arg(ap, int);
  800353:	8b 45 14             	mov    0x14(%ebp),%eax
  800356:	8b 00                	mov    (%eax),%eax
  800358:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80035b:	8b 45 14             	mov    0x14(%ebp),%eax
  80035e:	8d 40 04             	lea    0x4(%eax),%eax
  800361:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800367:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036b:	79 90                	jns    8002fd <vprintfmt+0x40>
				width = precision, precision = -1;
  80036d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800370:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800373:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80037a:	eb 81                	jmp    8002fd <vprintfmt+0x40>

0080037c <.L27>:
  80037c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037f:	85 c0                	test   %eax,%eax
  800381:	ba 00 00 00 00       	mov    $0x0,%edx
  800386:	0f 49 d0             	cmovns %eax,%edx
  800389:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038f:	e9 69 ff ff ff       	jmp    8002fd <vprintfmt+0x40>

00800394 <.L23>:
  800394:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800397:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80039e:	e9 5a ff ff ff       	jmp    8002fd <vprintfmt+0x40>
  8003a3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003a6:	eb bf                	jmp    800367 <.L26+0x14>

008003a8 <.L33>:
			lflag++;
  8003a8:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003af:	e9 49 ff ff ff       	jmp    8002fd <vprintfmt+0x40>

008003b4 <.L30>:
			putch(va_arg(ap, int), putdat);
  8003b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b7:	8d 78 04             	lea    0x4(%eax),%edi
  8003ba:	83 ec 08             	sub    $0x8,%esp
  8003bd:	56                   	push   %esi
  8003be:	ff 30                	pushl  (%eax)
  8003c0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8003c3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003c6:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003c9:	e9 ce 02 00 00       	jmp    80069c <.L35+0x45>

008003ce <.L32>:
			err = va_arg(ap, int);
  8003ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d1:	8d 78 04             	lea    0x4(%eax),%edi
  8003d4:	8b 00                	mov    (%eax),%eax
  8003d6:	99                   	cltd   
  8003d7:	31 d0                	xor    %edx,%eax
  8003d9:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003db:	83 f8 08             	cmp    $0x8,%eax
  8003de:	7f 27                	jg     800407 <.L32+0x39>
  8003e0:	8b 94 83 20 00 00 00 	mov    0x20(%ebx,%eax,4),%edx
  8003e7:	85 d2                	test   %edx,%edx
  8003e9:	74 1c                	je     800407 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8003eb:	52                   	push   %edx
  8003ec:	8d 83 2c f1 ff ff    	lea    -0xed4(%ebx),%eax
  8003f2:	50                   	push   %eax
  8003f3:	56                   	push   %esi
  8003f4:	ff 75 08             	pushl  0x8(%ebp)
  8003f7:	e8 a4 fe ff ff       	call   8002a0 <printfmt>
  8003fc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ff:	89 7d 14             	mov    %edi,0x14(%ebp)
  800402:	e9 95 02 00 00       	jmp    80069c <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  800407:	50                   	push   %eax
  800408:	8d 83 23 f1 ff ff    	lea    -0xedd(%ebx),%eax
  80040e:	50                   	push   %eax
  80040f:	56                   	push   %esi
  800410:	ff 75 08             	pushl  0x8(%ebp)
  800413:	e8 88 fe ff ff       	call   8002a0 <printfmt>
  800418:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80041b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80041e:	e9 79 02 00 00       	jmp    80069c <.L35+0x45>

00800423 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800423:	8b 45 14             	mov    0x14(%ebp),%eax
  800426:	83 c0 04             	add    $0x4,%eax
  800429:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80042c:	8b 45 14             	mov    0x14(%ebp),%eax
  80042f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800431:	85 ff                	test   %edi,%edi
  800433:	8d 83 1c f1 ff ff    	lea    -0xee4(%ebx),%eax
  800439:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80043c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800440:	0f 8e b5 00 00 00    	jle    8004fb <.L36+0xd8>
  800446:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80044a:	75 08                	jne    800454 <.L36+0x31>
  80044c:	89 75 0c             	mov    %esi,0xc(%ebp)
  80044f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800452:	eb 6d                	jmp    8004c1 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800454:	83 ec 08             	sub    $0x8,%esp
  800457:	ff 75 cc             	pushl  -0x34(%ebp)
  80045a:	57                   	push   %edi
  80045b:	e8 85 03 00 00       	call   8007e5 <strnlen>
  800460:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800463:	29 c2                	sub    %eax,%edx
  800465:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800468:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80046b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80046f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800472:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800475:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800477:	eb 10                	jmp    800489 <.L36+0x66>
					putch(padc, putdat);
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	56                   	push   %esi
  80047d:	ff 75 e0             	pushl  -0x20(%ebp)
  800480:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	83 ef 01             	sub    $0x1,%edi
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	85 ff                	test   %edi,%edi
  80048b:	7f ec                	jg     800479 <.L36+0x56>
  80048d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800490:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800493:	85 d2                	test   %edx,%edx
  800495:	b8 00 00 00 00       	mov    $0x0,%eax
  80049a:	0f 49 c2             	cmovns %edx,%eax
  80049d:	29 c2                	sub    %eax,%edx
  80049f:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004a2:	89 75 0c             	mov    %esi,0xc(%ebp)
  8004a5:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004a8:	eb 17                	jmp    8004c1 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004aa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ae:	75 30                	jne    8004e0 <.L36+0xbd>
					putch(ch, putdat);
  8004b0:	83 ec 08             	sub    $0x8,%esp
  8004b3:	ff 75 0c             	pushl  0xc(%ebp)
  8004b6:	50                   	push   %eax
  8004b7:	ff 55 08             	call   *0x8(%ebp)
  8004ba:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004bd:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8004c1:	83 c7 01             	add    $0x1,%edi
  8004c4:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004c8:	0f be c2             	movsbl %dl,%eax
  8004cb:	85 c0                	test   %eax,%eax
  8004cd:	74 52                	je     800521 <.L36+0xfe>
  8004cf:	85 f6                	test   %esi,%esi
  8004d1:	78 d7                	js     8004aa <.L36+0x87>
  8004d3:	83 ee 01             	sub    $0x1,%esi
  8004d6:	79 d2                	jns    8004aa <.L36+0x87>
  8004d8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004db:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004de:	eb 32                	jmp    800512 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e0:	0f be d2             	movsbl %dl,%edx
  8004e3:	83 ea 20             	sub    $0x20,%edx
  8004e6:	83 fa 5e             	cmp    $0x5e,%edx
  8004e9:	76 c5                	jbe    8004b0 <.L36+0x8d>
					putch('?', putdat);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	ff 75 0c             	pushl  0xc(%ebp)
  8004f1:	6a 3f                	push   $0x3f
  8004f3:	ff 55 08             	call   *0x8(%ebp)
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	eb c2                	jmp    8004bd <.L36+0x9a>
  8004fb:	89 75 0c             	mov    %esi,0xc(%ebp)
  8004fe:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800501:	eb be                	jmp    8004c1 <.L36+0x9e>
				putch(' ', putdat);
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	56                   	push   %esi
  800507:	6a 20                	push   $0x20
  800509:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  80050c:	83 ef 01             	sub    $0x1,%edi
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	85 ff                	test   %edi,%edi
  800514:	7f ed                	jg     800503 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800516:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800519:	89 45 14             	mov    %eax,0x14(%ebp)
  80051c:	e9 7b 01 00 00       	jmp    80069c <.L35+0x45>
  800521:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800524:	8b 75 0c             	mov    0xc(%ebp),%esi
  800527:	eb e9                	jmp    800512 <.L36+0xef>

00800529 <.L31>:
  800529:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80052c:	83 f9 01             	cmp    $0x1,%ecx
  80052f:	7e 40                	jle    800571 <.L31+0x48>
		return va_arg(*ap, long long);
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8b 50 04             	mov    0x4(%eax),%edx
  800537:	8b 00                	mov    (%eax),%eax
  800539:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 40 08             	lea    0x8(%eax),%eax
  800545:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
  800548:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80054c:	79 55                	jns    8005a3 <.L31+0x7a>
				putch('-', putdat);
  80054e:	83 ec 08             	sub    $0x8,%esp
  800551:	56                   	push   %esi
  800552:	6a 2d                	push   $0x2d
  800554:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  800557:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80055a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80055d:	f7 da                	neg    %edx
  80055f:	83 d1 00             	adc    $0x0,%ecx
  800562:	f7 d9                	neg    %ecx
  800564:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
  800567:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056c:	e9 10 01 00 00       	jmp    800681 <.L35+0x2a>
	else if (lflag)
  800571:	85 c9                	test   %ecx,%ecx
  800573:	75 17                	jne    80058c <.L31+0x63>
		return va_arg(*ap, int);
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8b 00                	mov    (%eax),%eax
  80057a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057d:	99                   	cltd   
  80057e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8d 40 04             	lea    0x4(%eax),%eax
  800587:	89 45 14             	mov    %eax,0x14(%ebp)
  80058a:	eb bc                	jmp    800548 <.L31+0x1f>
		return va_arg(*ap, long);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800594:	99                   	cltd   
  800595:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8d 40 04             	lea    0x4(%eax),%eax
  80059e:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a1:	eb a5                	jmp    800548 <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  8005a3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
  8005a9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ae:	e9 ce 00 00 00       	jmp    800681 <.L35+0x2a>

008005b3 <.L37>:
  8005b3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8005b6:	83 f9 01             	cmp    $0x1,%ecx
  8005b9:	7e 18                	jle    8005d3 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8b 10                	mov    (%eax),%edx
  8005c0:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c3:	8d 40 08             	lea    0x8(%eax),%eax
  8005c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ce:	e9 ae 00 00 00       	jmp    800681 <.L35+0x2a>
	else if (lflag)
  8005d3:	85 c9                	test   %ecx,%ecx
  8005d5:	75 1a                	jne    8005f1 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8b 10                	mov    (%eax),%edx
  8005dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e1:	8d 40 04             	lea    0x4(%eax),%eax
  8005e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ec:	e9 90 00 00 00       	jmp    800681 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8b 10                	mov    (%eax),%edx
  8005f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fb:	8d 40 04             	lea    0x4(%eax),%eax
  8005fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800601:	b8 0a 00 00 00       	mov    $0xa,%eax
  800606:	eb 79                	jmp    800681 <.L35+0x2a>

00800608 <.L34>:
  800608:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80060b:	83 f9 01             	cmp    $0x1,%ecx
  80060e:	7e 15                	jle    800625 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8b 10                	mov    (%eax),%edx
  800615:	8b 48 04             	mov    0x4(%eax),%ecx
  800618:	8d 40 08             	lea    0x8(%eax),%eax
  80061b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80061e:	b8 08 00 00 00       	mov    $0x8,%eax
  800623:	eb 5c                	jmp    800681 <.L35+0x2a>
	else if (lflag)
  800625:	85 c9                	test   %ecx,%ecx
  800627:	75 17                	jne    800640 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8b 10                	mov    (%eax),%edx
  80062e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800633:	8d 40 04             	lea    0x4(%eax),%eax
  800636:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800639:	b8 08 00 00 00       	mov    $0x8,%eax
  80063e:	eb 41                	jmp    800681 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8b 10                	mov    (%eax),%edx
  800645:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064a:	8d 40 04             	lea    0x4(%eax),%eax
  80064d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800650:	b8 08 00 00 00       	mov    $0x8,%eax
  800655:	eb 2a                	jmp    800681 <.L35+0x2a>

00800657 <.L35>:
			putch('0', putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	56                   	push   %esi
  80065b:	6a 30                	push   $0x30
  80065d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800660:	83 c4 08             	add    $0x8,%esp
  800663:	56                   	push   %esi
  800664:	6a 78                	push   $0x78
  800666:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8b 10                	mov    (%eax),%edx
  80066e:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800673:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800676:	8d 40 04             	lea    0x4(%eax),%eax
  800679:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067c:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  800681:	83 ec 0c             	sub    $0xc,%esp
  800684:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800688:	57                   	push   %edi
  800689:	ff 75 e0             	pushl  -0x20(%ebp)
  80068c:	50                   	push   %eax
  80068d:	51                   	push   %ecx
  80068e:	52                   	push   %edx
  80068f:	89 f2                	mov    %esi,%edx
  800691:	8b 45 08             	mov    0x8(%ebp),%eax
  800694:	e8 20 fb ff ff       	call   8001b9 <printnum>
			break;
  800699:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80069c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  80069f:	83 c7 01             	add    $0x1,%edi
  8006a2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006a6:	83 f8 25             	cmp    $0x25,%eax
  8006a9:	0f 84 2d fc ff ff    	je     8002dc <vprintfmt+0x1f>
			if (ch == '\0')
  8006af:	85 c0                	test   %eax,%eax
  8006b1:	0f 84 91 00 00 00    	je     800748 <.L22+0x21>
			putch(ch, putdat);
  8006b7:	83 ec 08             	sub    $0x8,%esp
  8006ba:	56                   	push   %esi
  8006bb:	50                   	push   %eax
  8006bc:	ff 55 08             	call   *0x8(%ebp)
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	eb db                	jmp    80069f <.L35+0x48>

008006c4 <.L38>:
  8006c4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006c7:	83 f9 01             	cmp    $0x1,%ecx
  8006ca:	7e 15                	jle    8006e1 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8b 10                	mov    (%eax),%edx
  8006d1:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d4:	8d 40 08             	lea    0x8(%eax),%eax
  8006d7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006da:	b8 10 00 00 00       	mov    $0x10,%eax
  8006df:	eb a0                	jmp    800681 <.L35+0x2a>
	else if (lflag)
  8006e1:	85 c9                	test   %ecx,%ecx
  8006e3:	75 17                	jne    8006fc <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	8b 10                	mov    (%eax),%edx
  8006ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ef:	8d 40 04             	lea    0x4(%eax),%eax
  8006f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f5:	b8 10 00 00 00       	mov    $0x10,%eax
  8006fa:	eb 85                	jmp    800681 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8b 10                	mov    (%eax),%edx
  800701:	b9 00 00 00 00       	mov    $0x0,%ecx
  800706:	8d 40 04             	lea    0x4(%eax),%eax
  800709:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070c:	b8 10 00 00 00       	mov    $0x10,%eax
  800711:	e9 6b ff ff ff       	jmp    800681 <.L35+0x2a>

00800716 <.L25>:
			putch(ch, putdat);
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	56                   	push   %esi
  80071a:	6a 25                	push   $0x25
  80071c:	ff 55 08             	call   *0x8(%ebp)
			break;
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	e9 75 ff ff ff       	jmp    80069c <.L35+0x45>

00800727 <.L22>:
			putch('%', putdat);
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	56                   	push   %esi
  80072b:	6a 25                	push   $0x25
  80072d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800730:	83 c4 10             	add    $0x10,%esp
  800733:	89 f8                	mov    %edi,%eax
  800735:	eb 03                	jmp    80073a <.L22+0x13>
  800737:	83 e8 01             	sub    $0x1,%eax
  80073a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80073e:	75 f7                	jne    800737 <.L22+0x10>
  800740:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800743:	e9 54 ff ff ff       	jmp    80069c <.L35+0x45>
}
  800748:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074b:	5b                   	pop    %ebx
  80074c:	5e                   	pop    %esi
  80074d:	5f                   	pop    %edi
  80074e:	5d                   	pop    %ebp
  80074f:	c3                   	ret    

00800750 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	53                   	push   %ebx
  800754:	83 ec 14             	sub    $0x14,%esp
  800757:	e8 18 f9 ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  80075c:	81 c3 a4 18 00 00    	add    $0x18a4,%ebx
  800762:	8b 45 08             	mov    0x8(%ebp),%eax
  800765:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  800768:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800772:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800779:	85 c0                	test   %eax,%eax
  80077b:	74 2b                	je     8007a8 <vsnprintf+0x58>
  80077d:	85 d2                	test   %edx,%edx
  80077f:	7e 27                	jle    8007a8 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  800781:	ff 75 14             	pushl  0x14(%ebp)
  800784:	ff 75 10             	pushl  0x10(%ebp)
  800787:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078a:	50                   	push   %eax
  80078b:	8d 83 83 e2 ff ff    	lea    -0x1d7d(%ebx),%eax
  800791:	50                   	push   %eax
  800792:	e8 26 fb ff ff       	call   8002bd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800797:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a0:	83 c4 10             	add    $0x10,%esp
}
  8007a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    
		return -E_INVAL;
  8007a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ad:	eb f4                	jmp    8007a3 <vsnprintf+0x53>

008007af <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b8:	50                   	push   %eax
  8007b9:	ff 75 10             	pushl  0x10(%ebp)
  8007bc:	ff 75 0c             	pushl  0xc(%ebp)
  8007bf:	ff 75 08             	pushl  0x8(%ebp)
  8007c2:	e8 89 ff ff ff       	call   800750 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <__x86.get_pc_thunk.cx>:
  8007c9:	8b 0c 24             	mov    (%esp),%ecx
  8007cc:	c3                   	ret    

008007cd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d8:	eb 03                	jmp    8007dd <strlen+0x10>
		n++;
  8007da:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007dd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e1:	75 f7                	jne    8007da <strlen+0xd>
	return n;
}
  8007e3:	5d                   	pop    %ebp
  8007e4:	c3                   	ret    

008007e5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f3:	eb 03                	jmp    8007f8 <strnlen+0x13>
		n++;
  8007f5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f8:	39 d0                	cmp    %edx,%eax
  8007fa:	74 06                	je     800802 <strnlen+0x1d>
  8007fc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800800:	75 f3                	jne    8007f5 <strnlen+0x10>
	return n;
}
  800802:	5d                   	pop    %ebp
  800803:	c3                   	ret    

00800804 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	53                   	push   %ebx
  800808:	8b 45 08             	mov    0x8(%ebp),%eax
  80080b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80080e:	89 c2                	mov    %eax,%edx
  800810:	83 c1 01             	add    $0x1,%ecx
  800813:	83 c2 01             	add    $0x1,%edx
  800816:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80081a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80081d:	84 db                	test   %bl,%bl
  80081f:	75 ef                	jne    800810 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800821:	5b                   	pop    %ebx
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	53                   	push   %ebx
  800828:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082b:	53                   	push   %ebx
  80082c:	e8 9c ff ff ff       	call   8007cd <strlen>
  800831:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800834:	ff 75 0c             	pushl  0xc(%ebp)
  800837:	01 d8                	add    %ebx,%eax
  800839:	50                   	push   %eax
  80083a:	e8 c5 ff ff ff       	call   800804 <strcpy>
	return dst;
}
  80083f:	89 d8                	mov    %ebx,%eax
  800841:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800844:	c9                   	leave  
  800845:	c3                   	ret    

00800846 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	56                   	push   %esi
  80084a:	53                   	push   %ebx
  80084b:	8b 75 08             	mov    0x8(%ebp),%esi
  80084e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800851:	89 f3                	mov    %esi,%ebx
  800853:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800856:	89 f2                	mov    %esi,%edx
  800858:	eb 0f                	jmp    800869 <strncpy+0x23>
		*dst++ = *src;
  80085a:	83 c2 01             	add    $0x1,%edx
  80085d:	0f b6 01             	movzbl (%ecx),%eax
  800860:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800863:	80 39 01             	cmpb   $0x1,(%ecx)
  800866:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800869:	39 da                	cmp    %ebx,%edx
  80086b:	75 ed                	jne    80085a <strncpy+0x14>
	}
	return ret;
}
  80086d:	89 f0                	mov    %esi,%eax
  80086f:	5b                   	pop    %ebx
  800870:	5e                   	pop    %esi
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	56                   	push   %esi
  800877:	53                   	push   %ebx
  800878:	8b 75 08             	mov    0x8(%ebp),%esi
  80087b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800881:	89 f0                	mov    %esi,%eax
  800883:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800887:	85 c9                	test   %ecx,%ecx
  800889:	75 0b                	jne    800896 <strlcpy+0x23>
  80088b:	eb 17                	jmp    8008a4 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80088d:	83 c2 01             	add    $0x1,%edx
  800890:	83 c0 01             	add    $0x1,%eax
  800893:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800896:	39 d8                	cmp    %ebx,%eax
  800898:	74 07                	je     8008a1 <strlcpy+0x2e>
  80089a:	0f b6 0a             	movzbl (%edx),%ecx
  80089d:	84 c9                	test   %cl,%cl
  80089f:	75 ec                	jne    80088d <strlcpy+0x1a>
		*dst = '\0';
  8008a1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a4:	29 f0                	sub    %esi,%eax
}
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b3:	eb 06                	jmp    8008bb <strcmp+0x11>
		p++, q++;
  8008b5:	83 c1 01             	add    $0x1,%ecx
  8008b8:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008bb:	0f b6 01             	movzbl (%ecx),%eax
  8008be:	84 c0                	test   %al,%al
  8008c0:	74 04                	je     8008c6 <strcmp+0x1c>
  8008c2:	3a 02                	cmp    (%edx),%al
  8008c4:	74 ef                	je     8008b5 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c6:	0f b6 c0             	movzbl %al,%eax
  8008c9:	0f b6 12             	movzbl (%edx),%edx
  8008cc:	29 d0                	sub    %edx,%eax
}
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	53                   	push   %ebx
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008da:	89 c3                	mov    %eax,%ebx
  8008dc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008df:	eb 06                	jmp    8008e7 <strncmp+0x17>
		n--, p++, q++;
  8008e1:	83 c0 01             	add    $0x1,%eax
  8008e4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008e7:	39 d8                	cmp    %ebx,%eax
  8008e9:	74 16                	je     800901 <strncmp+0x31>
  8008eb:	0f b6 08             	movzbl (%eax),%ecx
  8008ee:	84 c9                	test   %cl,%cl
  8008f0:	74 04                	je     8008f6 <strncmp+0x26>
  8008f2:	3a 0a                	cmp    (%edx),%cl
  8008f4:	74 eb                	je     8008e1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f6:	0f b6 00             	movzbl (%eax),%eax
  8008f9:	0f b6 12             	movzbl (%edx),%edx
  8008fc:	29 d0                	sub    %edx,%eax
}
  8008fe:	5b                   	pop    %ebx
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    
		return 0;
  800901:	b8 00 00 00 00       	mov    $0x0,%eax
  800906:	eb f6                	jmp    8008fe <strncmp+0x2e>

00800908 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	8b 45 08             	mov    0x8(%ebp),%eax
  80090e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800912:	0f b6 10             	movzbl (%eax),%edx
  800915:	84 d2                	test   %dl,%dl
  800917:	74 09                	je     800922 <strchr+0x1a>
		if (*s == c)
  800919:	38 ca                	cmp    %cl,%dl
  80091b:	74 0a                	je     800927 <strchr+0x1f>
	for (; *s; s++)
  80091d:	83 c0 01             	add    $0x1,%eax
  800920:	eb f0                	jmp    800912 <strchr+0xa>
			return (char *) s;
	return 0;
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800933:	eb 03                	jmp    800938 <strfind+0xf>
  800935:	83 c0 01             	add    $0x1,%eax
  800938:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80093b:	38 ca                	cmp    %cl,%dl
  80093d:	74 04                	je     800943 <strfind+0x1a>
  80093f:	84 d2                	test   %dl,%dl
  800941:	75 f2                	jne    800935 <strfind+0xc>
			break;
	return (char *) s;
}
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	57                   	push   %edi
  800949:	56                   	push   %esi
  80094a:	53                   	push   %ebx
  80094b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800951:	85 c9                	test   %ecx,%ecx
  800953:	74 13                	je     800968 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800955:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095b:	75 05                	jne    800962 <memset+0x1d>
  80095d:	f6 c1 03             	test   $0x3,%cl
  800960:	74 0d                	je     80096f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	fc                   	cld    
  800966:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800968:	89 f8                	mov    %edi,%eax
  80096a:	5b                   	pop    %ebx
  80096b:	5e                   	pop    %esi
  80096c:	5f                   	pop    %edi
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    
		c &= 0xFF;
  80096f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800973:	89 d3                	mov    %edx,%ebx
  800975:	c1 e3 08             	shl    $0x8,%ebx
  800978:	89 d0                	mov    %edx,%eax
  80097a:	c1 e0 18             	shl    $0x18,%eax
  80097d:	89 d6                	mov    %edx,%esi
  80097f:	c1 e6 10             	shl    $0x10,%esi
  800982:	09 f0                	or     %esi,%eax
  800984:	09 c2                	or     %eax,%edx
  800986:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800988:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80098b:	89 d0                	mov    %edx,%eax
  80098d:	fc                   	cld    
  80098e:	f3 ab                	rep stos %eax,%es:(%edi)
  800990:	eb d6                	jmp    800968 <memset+0x23>

00800992 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	57                   	push   %edi
  800996:	56                   	push   %esi
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a0:	39 c6                	cmp    %eax,%esi
  8009a2:	73 35                	jae    8009d9 <memmove+0x47>
  8009a4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a7:	39 c2                	cmp    %eax,%edx
  8009a9:	76 2e                	jbe    8009d9 <memmove+0x47>
		s += n;
		d += n;
  8009ab:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ae:	89 d6                	mov    %edx,%esi
  8009b0:	09 fe                	or     %edi,%esi
  8009b2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b8:	74 0c                	je     8009c6 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ba:	83 ef 01             	sub    $0x1,%edi
  8009bd:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009c0:	fd                   	std    
  8009c1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c3:	fc                   	cld    
  8009c4:	eb 21                	jmp    8009e7 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c6:	f6 c1 03             	test   $0x3,%cl
  8009c9:	75 ef                	jne    8009ba <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009cb:	83 ef 04             	sub    $0x4,%edi
  8009ce:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009d4:	fd                   	std    
  8009d5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d7:	eb ea                	jmp    8009c3 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d9:	89 f2                	mov    %esi,%edx
  8009db:	09 c2                	or     %eax,%edx
  8009dd:	f6 c2 03             	test   $0x3,%dl
  8009e0:	74 09                	je     8009eb <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e2:	89 c7                	mov    %eax,%edi
  8009e4:	fc                   	cld    
  8009e5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e7:	5e                   	pop    %esi
  8009e8:	5f                   	pop    %edi
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009eb:	f6 c1 03             	test   $0x3,%cl
  8009ee:	75 f2                	jne    8009e2 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009f0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009f3:	89 c7                	mov    %eax,%edi
  8009f5:	fc                   	cld    
  8009f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f8:	eb ed                	jmp    8009e7 <memmove+0x55>

008009fa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009fd:	ff 75 10             	pushl  0x10(%ebp)
  800a00:	ff 75 0c             	pushl  0xc(%ebp)
  800a03:	ff 75 08             	pushl  0x8(%ebp)
  800a06:	e8 87 ff ff ff       	call   800992 <memmove>
}
  800a0b:	c9                   	leave  
  800a0c:	c3                   	ret    

00800a0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
  800a15:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a18:	89 c6                	mov    %eax,%esi
  800a1a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1d:	39 f0                	cmp    %esi,%eax
  800a1f:	74 1c                	je     800a3d <memcmp+0x30>
		if (*s1 != *s2)
  800a21:	0f b6 08             	movzbl (%eax),%ecx
  800a24:	0f b6 1a             	movzbl (%edx),%ebx
  800a27:	38 d9                	cmp    %bl,%cl
  800a29:	75 08                	jne    800a33 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a2b:	83 c0 01             	add    $0x1,%eax
  800a2e:	83 c2 01             	add    $0x1,%edx
  800a31:	eb ea                	jmp    800a1d <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a33:	0f b6 c1             	movzbl %cl,%eax
  800a36:	0f b6 db             	movzbl %bl,%ebx
  800a39:	29 d8                	sub    %ebx,%eax
  800a3b:	eb 05                	jmp    800a42 <memcmp+0x35>
	}

	return 0;
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a4f:	89 c2                	mov    %eax,%edx
  800a51:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a54:	39 d0                	cmp    %edx,%eax
  800a56:	73 09                	jae    800a61 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a58:	38 08                	cmp    %cl,(%eax)
  800a5a:	74 05                	je     800a61 <memfind+0x1b>
	for (; s < ends; s++)
  800a5c:	83 c0 01             	add    $0x1,%eax
  800a5f:	eb f3                	jmp    800a54 <memfind+0xe>
			break;
	return (void *) s;
}
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	57                   	push   %edi
  800a67:	56                   	push   %esi
  800a68:	53                   	push   %ebx
  800a69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6f:	eb 03                	jmp    800a74 <strtol+0x11>
		s++;
  800a71:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a74:	0f b6 01             	movzbl (%ecx),%eax
  800a77:	3c 20                	cmp    $0x20,%al
  800a79:	74 f6                	je     800a71 <strtol+0xe>
  800a7b:	3c 09                	cmp    $0x9,%al
  800a7d:	74 f2                	je     800a71 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a7f:	3c 2b                	cmp    $0x2b,%al
  800a81:	74 2e                	je     800ab1 <strtol+0x4e>
	int neg = 0;
  800a83:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a88:	3c 2d                	cmp    $0x2d,%al
  800a8a:	74 2f                	je     800abb <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a92:	75 05                	jne    800a99 <strtol+0x36>
  800a94:	80 39 30             	cmpb   $0x30,(%ecx)
  800a97:	74 2c                	je     800ac5 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a99:	85 db                	test   %ebx,%ebx
  800a9b:	75 0a                	jne    800aa7 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a9d:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800aa2:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa5:	74 28                	je     800acf <strtol+0x6c>
		base = 10;
  800aa7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aac:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aaf:	eb 50                	jmp    800b01 <strtol+0x9e>
		s++;
  800ab1:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ab4:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab9:	eb d1                	jmp    800a8c <strtol+0x29>
		s++, neg = 1;
  800abb:	83 c1 01             	add    $0x1,%ecx
  800abe:	bf 01 00 00 00       	mov    $0x1,%edi
  800ac3:	eb c7                	jmp    800a8c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac9:	74 0e                	je     800ad9 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800acb:	85 db                	test   %ebx,%ebx
  800acd:	75 d8                	jne    800aa7 <strtol+0x44>
		s++, base = 8;
  800acf:	83 c1 01             	add    $0x1,%ecx
  800ad2:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ad7:	eb ce                	jmp    800aa7 <strtol+0x44>
		s += 2, base = 16;
  800ad9:	83 c1 02             	add    $0x2,%ecx
  800adc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae1:	eb c4                	jmp    800aa7 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ae3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae6:	89 f3                	mov    %esi,%ebx
  800ae8:	80 fb 19             	cmp    $0x19,%bl
  800aeb:	77 29                	ja     800b16 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800aed:	0f be d2             	movsbl %dl,%edx
  800af0:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800af3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af6:	7d 30                	jge    800b28 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800af8:	83 c1 01             	add    $0x1,%ecx
  800afb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aff:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b01:	0f b6 11             	movzbl (%ecx),%edx
  800b04:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b07:	89 f3                	mov    %esi,%ebx
  800b09:	80 fb 09             	cmp    $0x9,%bl
  800b0c:	77 d5                	ja     800ae3 <strtol+0x80>
			dig = *s - '0';
  800b0e:	0f be d2             	movsbl %dl,%edx
  800b11:	83 ea 30             	sub    $0x30,%edx
  800b14:	eb dd                	jmp    800af3 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b16:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b19:	89 f3                	mov    %esi,%ebx
  800b1b:	80 fb 19             	cmp    $0x19,%bl
  800b1e:	77 08                	ja     800b28 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b20:	0f be d2             	movsbl %dl,%edx
  800b23:	83 ea 37             	sub    $0x37,%edx
  800b26:	eb cb                	jmp    800af3 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b28:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2c:	74 05                	je     800b33 <strtol+0xd0>
		*endptr = (char *) s;
  800b2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b31:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b33:	89 c2                	mov    %eax,%edx
  800b35:	f7 da                	neg    %edx
  800b37:	85 ff                	test   %edi,%edi
  800b39:	0f 45 c2             	cmovne %edx,%eax
}
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b47:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b52:	89 c3                	mov    %eax,%ebx
  800b54:	89 c7                	mov    %eax,%edi
  800b56:	89 c6                	mov    %eax,%esi
  800b58:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b65:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6f:	89 d1                	mov    %edx,%ecx
  800b71:	89 d3                	mov    %edx,%ebx
  800b73:	89 d7                	mov    %edx,%edi
  800b75:	89 d6                	mov    %edx,%esi
  800b77:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	83 ec 1c             	sub    $0x1c,%esp
  800b87:	e8 ac 02 00 00       	call   800e38 <__x86.get_pc_thunk.ax>
  800b8c:	05 74 14 00 00       	add    $0x1474,%eax
  800b91:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800b94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b99:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9c:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba1:	89 cb                	mov    %ecx,%ebx
  800ba3:	89 cf                	mov    %ecx,%edi
  800ba5:	89 ce                	mov    %ecx,%esi
  800ba7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ba9:	85 c0                	test   %eax,%eax
  800bab:	7f 08                	jg     800bb5 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb5:	83 ec 0c             	sub    $0xc,%esp
  800bb8:	50                   	push   %eax
  800bb9:	6a 03                	push   $0x3
  800bbb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800bbe:	8d 83 1c f3 ff ff    	lea    -0xce4(%ebx),%eax
  800bc4:	50                   	push   %eax
  800bc5:	6a 23                	push   $0x23
  800bc7:	8d 83 39 f3 ff ff    	lea    -0xcc7(%ebx),%eax
  800bcd:	50                   	push   %eax
  800bce:	e8 69 02 00 00       	call   800e3c <_panic>

00800bd3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	57                   	push   %edi
  800bd7:	56                   	push   %esi
  800bd8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bd9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bde:	b8 02 00 00 00       	mov    $0x2,%eax
  800be3:	89 d1                	mov    %edx,%ecx
  800be5:	89 d3                	mov    %edx,%ebx
  800be7:	89 d7                	mov    %edx,%edi
  800be9:	89 d6                	mov    %edx,%esi
  800beb:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <sys_yield>:

void
sys_yield(void)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c02:	89 d1                	mov    %edx,%ecx
  800c04:	89 d3                	mov    %edx,%ebx
  800c06:	89 d7                	mov    %edx,%edi
  800c08:	89 d6                	mov    %edx,%esi
  800c0a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5f                   	pop    %edi
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	57                   	push   %edi
  800c15:	56                   	push   %esi
  800c16:	53                   	push   %ebx
  800c17:	83 ec 1c             	sub    $0x1c,%esp
  800c1a:	e8 19 02 00 00       	call   800e38 <__x86.get_pc_thunk.ax>
  800c1f:	05 e1 13 00 00       	add    $0x13e1,%eax
  800c24:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800c27:	be 00 00 00 00       	mov    $0x0,%esi
  800c2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c32:	b8 04 00 00 00       	mov    $0x4,%eax
  800c37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3a:	89 f7                	mov    %esi,%edi
  800c3c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	7f 08                	jg     800c4a <sys_page_alloc+0x39>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4a:	83 ec 0c             	sub    $0xc,%esp
  800c4d:	50                   	push   %eax
  800c4e:	6a 04                	push   $0x4
  800c50:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c53:	8d 83 1c f3 ff ff    	lea    -0xce4(%ebx),%eax
  800c59:	50                   	push   %eax
  800c5a:	6a 23                	push   $0x23
  800c5c:	8d 83 39 f3 ff ff    	lea    -0xcc7(%ebx),%eax
  800c62:	50                   	push   %eax
  800c63:	e8 d4 01 00 00       	call   800e3c <_panic>

00800c68 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	57                   	push   %edi
  800c6c:	56                   	push   %esi
  800c6d:	53                   	push   %ebx
  800c6e:	83 ec 1c             	sub    $0x1c,%esp
  800c71:	e8 c2 01 00 00       	call   800e38 <__x86.get_pc_thunk.ax>
  800c76:	05 8a 13 00 00       	add    $0x138a,%eax
  800c7b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800c7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c84:	b8 05 00 00 00       	mov    $0x5,%eax
  800c89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c92:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7f 08                	jg     800ca0 <sys_page_map+0x38>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	6a 05                	push   $0x5
  800ca6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800ca9:	8d 83 1c f3 ff ff    	lea    -0xce4(%ebx),%eax
  800caf:	50                   	push   %eax
  800cb0:	6a 23                	push   $0x23
  800cb2:	8d 83 39 f3 ff ff    	lea    -0xcc7(%ebx),%eax
  800cb8:	50                   	push   %eax
  800cb9:	e8 7e 01 00 00       	call   800e3c <_panic>

00800cbe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
  800cc4:	83 ec 1c             	sub    $0x1c,%esp
  800cc7:	e8 6c 01 00 00       	call   800e38 <__x86.get_pc_thunk.ax>
  800ccc:	05 34 13 00 00       	add    $0x1334,%eax
  800cd1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800cd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdf:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce4:	89 df                	mov    %ebx,%edi
  800ce6:	89 de                	mov    %ebx,%esi
  800ce8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7f 08                	jg     800cf6 <sys_page_unmap+0x38>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf6:	83 ec 0c             	sub    $0xc,%esp
  800cf9:	50                   	push   %eax
  800cfa:	6a 06                	push   $0x6
  800cfc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800cff:	8d 83 1c f3 ff ff    	lea    -0xce4(%ebx),%eax
  800d05:	50                   	push   %eax
  800d06:	6a 23                	push   $0x23
  800d08:	8d 83 39 f3 ff ff    	lea    -0xcc7(%ebx),%eax
  800d0e:	50                   	push   %eax
  800d0f:	e8 28 01 00 00       	call   800e3c <_panic>

00800d14 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	83 ec 1c             	sub    $0x1c,%esp
  800d1d:	e8 16 01 00 00       	call   800e38 <__x86.get_pc_thunk.ax>
  800d22:	05 de 12 00 00       	add    $0x12de,%eax
  800d27:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800d2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d35:	b8 08 00 00 00       	mov    $0x8,%eax
  800d3a:	89 df                	mov    %ebx,%edi
  800d3c:	89 de                	mov    %ebx,%esi
  800d3e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d40:	85 c0                	test   %eax,%eax
  800d42:	7f 08                	jg     800d4c <sys_env_set_status+0x38>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4c:	83 ec 0c             	sub    $0xc,%esp
  800d4f:	50                   	push   %eax
  800d50:	6a 08                	push   $0x8
  800d52:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800d55:	8d 83 1c f3 ff ff    	lea    -0xce4(%ebx),%eax
  800d5b:	50                   	push   %eax
  800d5c:	6a 23                	push   $0x23
  800d5e:	8d 83 39 f3 ff ff    	lea    -0xcc7(%ebx),%eax
  800d64:	50                   	push   %eax
  800d65:	e8 d2 00 00 00       	call   800e3c <_panic>

00800d6a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
  800d70:	83 ec 1c             	sub    $0x1c,%esp
  800d73:	e8 c0 00 00 00       	call   800e38 <__x86.get_pc_thunk.ax>
  800d78:	05 88 12 00 00       	add    $0x1288,%eax
  800d7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800d80:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d85:	8b 55 08             	mov    0x8(%ebp),%edx
  800d88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d90:	89 df                	mov    %ebx,%edi
  800d92:	89 de                	mov    %ebx,%esi
  800d94:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d96:	85 c0                	test   %eax,%eax
  800d98:	7f 08                	jg     800da2 <sys_env_set_pgfault_upcall+0x38>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da2:	83 ec 0c             	sub    $0xc,%esp
  800da5:	50                   	push   %eax
  800da6:	6a 09                	push   $0x9
  800da8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800dab:	8d 83 1c f3 ff ff    	lea    -0xce4(%ebx),%eax
  800db1:	50                   	push   %eax
  800db2:	6a 23                	push   $0x23
  800db4:	8d 83 39 f3 ff ff    	lea    -0xcc7(%ebx),%eax
  800dba:	50                   	push   %eax
  800dbb:	e8 7c 00 00 00       	call   800e3c <_panic>

00800dc0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	57                   	push   %edi
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dd1:	be 00 00 00 00       	mov    $0x0,%esi
  800dd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ddc:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dde:	5b                   	pop    %ebx
  800ddf:	5e                   	pop    %esi
  800de0:	5f                   	pop    %edi
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    

00800de3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	57                   	push   %edi
  800de7:	56                   	push   %esi
  800de8:	53                   	push   %ebx
  800de9:	83 ec 1c             	sub    $0x1c,%esp
  800dec:	e8 47 00 00 00       	call   800e38 <__x86.get_pc_thunk.ax>
  800df1:	05 0f 12 00 00       	add    $0x120f,%eax
  800df6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800df9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800e01:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e06:	89 cb                	mov    %ecx,%ebx
  800e08:	89 cf                	mov    %ecx,%edi
  800e0a:	89 ce                	mov    %ecx,%esi
  800e0c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e0e:	85 c0                	test   %eax,%eax
  800e10:	7f 08                	jg     800e1a <sys_ipc_recv+0x37>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1a:	83 ec 0c             	sub    $0xc,%esp
  800e1d:	50                   	push   %eax
  800e1e:	6a 0c                	push   $0xc
  800e20:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800e23:	8d 83 1c f3 ff ff    	lea    -0xce4(%ebx),%eax
  800e29:	50                   	push   %eax
  800e2a:	6a 23                	push   $0x23
  800e2c:	8d 83 39 f3 ff ff    	lea    -0xcc7(%ebx),%eax
  800e32:	50                   	push   %eax
  800e33:	e8 04 00 00 00       	call   800e3c <_panic>

00800e38 <__x86.get_pc_thunk.ax>:
  800e38:	8b 04 24             	mov    (%esp),%eax
  800e3b:	c3                   	ret    

00800e3c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	57                   	push   %edi
  800e40:	56                   	push   %esi
  800e41:	53                   	push   %ebx
  800e42:	83 ec 0c             	sub    $0xc,%esp
  800e45:	e8 2a f2 ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800e4a:	81 c3 b6 11 00 00    	add    $0x11b6,%ebx
	va_list ap;

	va_start(ap, fmt);
  800e50:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e53:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800e59:	8b 38                	mov    (%eax),%edi
  800e5b:	e8 73 fd ff ff       	call   800bd3 <sys_getenvid>
  800e60:	83 ec 0c             	sub    $0xc,%esp
  800e63:	ff 75 0c             	pushl  0xc(%ebp)
  800e66:	ff 75 08             	pushl  0x8(%ebp)
  800e69:	57                   	push   %edi
  800e6a:	50                   	push   %eax
  800e6b:	8d 83 48 f3 ff ff    	lea    -0xcb8(%ebx),%eax
  800e71:	50                   	push   %eax
  800e72:	e8 2e f3 ff ff       	call   8001a5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e77:	83 c4 18             	add    $0x18,%esp
  800e7a:	56                   	push   %esi
  800e7b:	ff 75 10             	pushl  0x10(%ebp)
  800e7e:	e8 c0 f2 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  800e83:	8d 83 e8 f0 ff ff    	lea    -0xf18(%ebx),%eax
  800e89:	89 04 24             	mov    %eax,(%esp)
  800e8c:	e8 14 f3 ff ff       	call   8001a5 <cprintf>
  800e91:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e94:	cc                   	int3   
  800e95:	eb fd                	jmp    800e94 <_panic+0x58>
  800e97:	66 90                	xchg   %ax,%ax
  800e99:	66 90                	xchg   %ax,%ax
  800e9b:	66 90                	xchg   %ax,%ax
  800e9d:	66 90                	xchg   %ax,%ax
  800e9f:	90                   	nop

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
