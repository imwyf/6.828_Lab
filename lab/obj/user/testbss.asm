
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 d7 00 00 00       	call   800108 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
  80003a:	e8 c5 00 00 00       	call   800104 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	int i;

	cprintf("Making sure bss works right...\n");
  800045:	8d 83 0c ef ff ff    	lea    -0x10f4(%ebx),%eax
  80004b:	50                   	push   %eax
  80004c:	e8 2b 02 00 00       	call   80027c <cprintf>
  800051:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800054:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  800059:	c7 c2 40 20 80 00    	mov    $0x802040,%edx
  80005f:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  800063:	75 73                	jne    8000d8 <umain+0xa5>
	for (i = 0; i < ARRAYSIZE; i++)
  800065:	83 c0 01             	add    $0x1,%eax
  800068:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006d:	75 f0                	jne    80005f <umain+0x2c>
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80006f:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800074:	c7 c2 40 20 80 00    	mov    $0x802040,%edx
  80007a:	89 04 82             	mov    %eax,(%edx,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	83 c0 01             	add    $0x1,%eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 f3                	jne    80007a <umain+0x47>
	for (i = 0; i < ARRAYSIZE; i++)
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  80008c:	c7 c2 40 20 80 00    	mov    $0x802040,%edx
  800092:	39 04 82             	cmp    %eax,(%edx,%eax,4)
  800095:	75 57                	jne    8000ee <umain+0xbb>
	for (i = 0; i < ARRAYSIZE; i++)
  800097:	83 c0 01             	add    $0x1,%eax
  80009a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80009f:	75 f1                	jne    800092 <umain+0x5f>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000a1:	83 ec 0c             	sub    $0xc,%esp
  8000a4:	8d 83 54 ef ff ff    	lea    -0x10ac(%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	e8 cc 01 00 00       	call   80027c <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000b0:	c7 c0 40 20 80 00    	mov    $0x802040,%eax
  8000b6:	c7 80 00 10 40 00 00 	movl   $0x0,0x401000(%eax)
  8000bd:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c0:	83 c4 0c             	add    $0xc,%esp
  8000c3:	8d 83 b3 ef ff ff    	lea    -0x104d(%ebx),%eax
  8000c9:	50                   	push   %eax
  8000ca:	6a 1a                	push   $0x1a
  8000cc:	8d 83 a4 ef ff ff    	lea    -0x105c(%ebx),%eax
  8000d2:	50                   	push   %eax
  8000d3:	e8 98 00 00 00       	call   800170 <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000d8:	50                   	push   %eax
  8000d9:	8d 83 87 ef ff ff    	lea    -0x1079(%ebx),%eax
  8000df:	50                   	push   %eax
  8000e0:	6a 11                	push   $0x11
  8000e2:	8d 83 a4 ef ff ff    	lea    -0x105c(%ebx),%eax
  8000e8:	50                   	push   %eax
  8000e9:	e8 82 00 00 00       	call   800170 <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ee:	50                   	push   %eax
  8000ef:	8d 83 2c ef ff ff    	lea    -0x10d4(%ebx),%eax
  8000f5:	50                   	push   %eax
  8000f6:	6a 16                	push   $0x16
  8000f8:	8d 83 a4 ef ff ff    	lea    -0x105c(%ebx),%eax
  8000fe:	50                   	push   %eax
  8000ff:	e8 6c 00 00 00       	call   800170 <_panic>

00800104 <__x86.get_pc_thunk.bx>:
  800104:	8b 1c 24             	mov    (%esp),%ebx
  800107:	c3                   	ret    

00800108 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	53                   	push   %ebx
  80010c:	83 ec 04             	sub    $0x4,%esp
  80010f:	e8 f0 ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800114:	81 c3 ec 1e 00 00    	add    $0x1eec,%ebx
  80011a:	8b 45 08             	mov    0x8(%ebp),%eax
  80011d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800120:	c7 c1 40 20 c0 00    	mov    $0xc02040,%ecx
  800126:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012c:	85 c0                	test   %eax,%eax
  80012e:	7e 08                	jle    800138 <libmain+0x30>
		binaryname = argv[0];
  800130:	8b 0a                	mov    (%edx),%ecx
  800132:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800138:	83 ec 08             	sub    $0x8,%esp
  80013b:	52                   	push   %edx
  80013c:	50                   	push   %eax
  80013d:	e8 f1 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800142:	e8 08 00 00 00       	call   80014f <exit>
}
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	53                   	push   %ebx
  800153:	83 ec 10             	sub    $0x10,%esp
  800156:	e8 a9 ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  80015b:	81 c3 a5 1e 00 00    	add    $0x1ea5,%ebx
	sys_env_destroy(0);
  800161:	6a 00                	push   $0x0
  800163:	e8 ed 0a 00 00       	call   800c55 <sys_env_destroy>
}
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80016e:	c9                   	leave  
  80016f:	c3                   	ret    

00800170 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	e8 86 ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  80017e:	81 c3 82 1e 00 00    	add    $0x1e82,%ebx
	va_list ap;

	va_start(ap, fmt);
  800184:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800187:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  80018d:	8b 38                	mov    (%eax),%edi
  80018f:	e8 16 0b 00 00       	call   800caa <sys_getenvid>
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	ff 75 0c             	pushl  0xc(%ebp)
  80019a:	ff 75 08             	pushl  0x8(%ebp)
  80019d:	57                   	push   %edi
  80019e:	50                   	push   %eax
  80019f:	8d 83 d4 ef ff ff    	lea    -0x102c(%ebx),%eax
  8001a5:	50                   	push   %eax
  8001a6:	e8 d1 00 00 00       	call   80027c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ab:	83 c4 18             	add    $0x18,%esp
  8001ae:	56                   	push   %esi
  8001af:	ff 75 10             	pushl  0x10(%ebp)
  8001b2:	e8 63 00 00 00       	call   80021a <vcprintf>
	cprintf("\n");
  8001b7:	8d 83 a2 ef ff ff    	lea    -0x105e(%ebx),%eax
  8001bd:	89 04 24             	mov    %eax,(%esp)
  8001c0:	e8 b7 00 00 00       	call   80027c <cprintf>
  8001c5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c8:	cc                   	int3   
  8001c9:	eb fd                	jmp    8001c8 <_panic+0x58>

008001cb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	56                   	push   %esi
  8001cf:	53                   	push   %ebx
  8001d0:	e8 2f ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  8001d5:	81 c3 2b 1e 00 00    	add    $0x1e2b,%ebx
  8001db:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001de:	8b 16                	mov    (%esi),%edx
  8001e0:	8d 42 01             	lea    0x1(%edx),%eax
  8001e3:	89 06                	mov    %eax,(%esi)
  8001e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e8:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001ec:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f1:	74 0b                	je     8001fe <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001f3:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001fe:	83 ec 08             	sub    $0x8,%esp
  800201:	68 ff 00 00 00       	push   $0xff
  800206:	8d 46 08             	lea    0x8(%esi),%eax
  800209:	50                   	push   %eax
  80020a:	e8 09 0a 00 00       	call   800c18 <sys_cputs>
		b->idx = 0;
  80020f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800215:	83 c4 10             	add    $0x10,%esp
  800218:	eb d9                	jmp    8001f3 <putch+0x28>

0080021a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	53                   	push   %ebx
  80021e:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800224:	e8 db fe ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800229:	81 c3 d7 1d 00 00    	add    $0x1dd7,%ebx
	struct printbuf b;

	b.idx = 0;
  80022f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800236:	00 00 00 
	b.cnt = 0;
  800239:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800240:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800243:	ff 75 0c             	pushl  0xc(%ebp)
  800246:	ff 75 08             	pushl  0x8(%ebp)
  800249:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024f:	50                   	push   %eax
  800250:	8d 83 cb e1 ff ff    	lea    -0x1e35(%ebx),%eax
  800256:	50                   	push   %eax
  800257:	e8 38 01 00 00       	call   800394 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025c:	83 c4 08             	add    $0x8,%esp
  80025f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800265:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026b:	50                   	push   %eax
  80026c:	e8 a7 09 00 00       	call   800c18 <sys_cputs>

	return b.cnt;
}
  800271:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800277:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80027a:	c9                   	leave  
  80027b:	c3                   	ret    

0080027c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800282:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800285:	50                   	push   %eax
  800286:	ff 75 08             	pushl  0x8(%ebp)
  800289:	e8 8c ff ff ff       	call   80021a <vcprintf>
	va_end(ap);

	return cnt;
}
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 2c             	sub    $0x2c,%esp
  800299:	e8 02 06 00 00       	call   8008a0 <__x86.get_pc_thunk.cx>
  80029e:	81 c1 62 1d 00 00    	add    $0x1d62,%ecx
  8002a4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002a7:	89 c7                	mov    %eax,%edi
  8002a9:	89 d6                	mov    %edx,%esi
  8002ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002b4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  8002b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002c2:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002c5:	39 d3                	cmp    %edx,%ebx
  8002c7:	72 09                	jb     8002d2 <printnum+0x42>
  8002c9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002cc:	0f 87 83 00 00 00    	ja     800355 <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d2:	83 ec 0c             	sub    $0xc,%esp
  8002d5:	ff 75 18             	pushl  0x18(%ebp)
  8002d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8002db:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002de:	53                   	push   %ebx
  8002df:	ff 75 10             	pushl  0x10(%ebp)
  8002e2:	83 ec 08             	sub    $0x8,%esp
  8002e5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002eb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ee:	ff 75 d0             	pushl  -0x30(%ebp)
  8002f1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002f4:	e8 d7 09 00 00       	call   800cd0 <__udivdi3>
  8002f9:	83 c4 18             	add    $0x18,%esp
  8002fc:	52                   	push   %edx
  8002fd:	50                   	push   %eax
  8002fe:	89 f2                	mov    %esi,%edx
  800300:	89 f8                	mov    %edi,%eax
  800302:	e8 89 ff ff ff       	call   800290 <printnum>
  800307:	83 c4 20             	add    $0x20,%esp
  80030a:	eb 13                	jmp    80031f <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030c:	83 ec 08             	sub    $0x8,%esp
  80030f:	56                   	push   %esi
  800310:	ff 75 18             	pushl  0x18(%ebp)
  800313:	ff d7                	call   *%edi
  800315:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	85 db                	test   %ebx,%ebx
  80031d:	7f ed                	jg     80030c <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	56                   	push   %esi
  800323:	83 ec 04             	sub    $0x4,%esp
  800326:	ff 75 dc             	pushl  -0x24(%ebp)
  800329:	ff 75 d8             	pushl  -0x28(%ebp)
  80032c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80032f:	ff 75 d0             	pushl  -0x30(%ebp)
  800332:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800335:	89 f3                	mov    %esi,%ebx
  800337:	e8 b4 0a 00 00       	call   800df0 <__umoddi3>
  80033c:	83 c4 14             	add    $0x14,%esp
  80033f:	0f be 84 06 f8 ef ff 	movsbl -0x1008(%esi,%eax,1),%eax
  800346:	ff 
  800347:	50                   	push   %eax
  800348:	ff d7                	call   *%edi
}
  80034a:	83 c4 10             	add    $0x10,%esp
  80034d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800350:	5b                   	pop    %ebx
  800351:	5e                   	pop    %esi
  800352:	5f                   	pop    %edi
  800353:	5d                   	pop    %ebp
  800354:	c3                   	ret    
  800355:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800358:	eb be                	jmp    800318 <printnum+0x88>

0080035a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800360:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800364:	8b 10                	mov    (%eax),%edx
  800366:	3b 50 04             	cmp    0x4(%eax),%edx
  800369:	73 0a                	jae    800375 <sprintputch+0x1b>
		*b->buf++ = ch;
  80036b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80036e:	89 08                	mov    %ecx,(%eax)
  800370:	8b 45 08             	mov    0x8(%ebp),%eax
  800373:	88 02                	mov    %al,(%edx)
}
  800375:	5d                   	pop    %ebp
  800376:	c3                   	ret    

00800377 <printfmt>:
{
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
  80037a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80037d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800380:	50                   	push   %eax
  800381:	ff 75 10             	pushl  0x10(%ebp)
  800384:	ff 75 0c             	pushl  0xc(%ebp)
  800387:	ff 75 08             	pushl  0x8(%ebp)
  80038a:	e8 05 00 00 00       	call   800394 <vprintfmt>
}
  80038f:	83 c4 10             	add    $0x10,%esp
  800392:	c9                   	leave  
  800393:	c3                   	ret    

00800394 <vprintfmt>:
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	57                   	push   %edi
  800398:	56                   	push   %esi
  800399:	53                   	push   %ebx
  80039a:	83 ec 2c             	sub    $0x2c,%esp
  80039d:	e8 62 fd ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  8003a2:	81 c3 5e 1c 00 00    	add    $0x1c5e,%ebx
  8003a8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003ab:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003ae:	e9 c3 03 00 00       	jmp    800776 <.L35+0x48>
		padc = ' ';
  8003b3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003b7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003be:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003c5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d1:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8003d4:	8d 47 01             	lea    0x1(%edi),%eax
  8003d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003da:	0f b6 17             	movzbl (%edi),%edx
  8003dd:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003e0:	3c 55                	cmp    $0x55,%al
  8003e2:	0f 87 16 04 00 00    	ja     8007fe <.L22>
  8003e8:	0f b6 c0             	movzbl %al,%eax
  8003eb:	89 d9                	mov    %ebx,%ecx
  8003ed:	03 8c 83 88 f0 ff ff 	add    -0xf78(%ebx,%eax,4),%ecx
  8003f4:	ff e1                	jmp    *%ecx

008003f6 <.L69>:
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003f9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003fd:	eb d5                	jmp    8003d4 <vprintfmt+0x40>

008003ff <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800402:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800406:	eb cc                	jmp    8003d4 <vprintfmt+0x40>

00800408 <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800408:	0f b6 d2             	movzbl %dl,%edx
  80040b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
  80040e:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800413:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800416:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80041a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80041d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800420:	83 f9 09             	cmp    $0x9,%ecx
  800423:	77 55                	ja     80047a <.L23+0xf>
			for (precision = 0;; ++fmt)
  800425:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800428:	eb e9                	jmp    800413 <.L29+0xb>

0080042a <.L26>:
			precision = va_arg(ap, int);
  80042a:	8b 45 14             	mov    0x14(%ebp),%eax
  80042d:	8b 00                	mov    (%eax),%eax
  80042f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800432:	8b 45 14             	mov    0x14(%ebp),%eax
  800435:	8d 40 04             	lea    0x4(%eax),%eax
  800438:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80043b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80043e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800442:	79 90                	jns    8003d4 <vprintfmt+0x40>
				width = precision, precision = -1;
  800444:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800447:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044a:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800451:	eb 81                	jmp    8003d4 <vprintfmt+0x40>

00800453 <.L27>:
  800453:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800456:	85 c0                	test   %eax,%eax
  800458:	ba 00 00 00 00       	mov    $0x0,%edx
  80045d:	0f 49 d0             	cmovns %eax,%edx
  800460:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800463:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800466:	e9 69 ff ff ff       	jmp    8003d4 <vprintfmt+0x40>

0080046b <.L23>:
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80046e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800475:	e9 5a ff ff ff       	jmp    8003d4 <vprintfmt+0x40>
  80047a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80047d:	eb bf                	jmp    80043e <.L26+0x14>

0080047f <.L33>:
			lflag++;
  80047f:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800483:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800486:	e9 49 ff ff ff       	jmp    8003d4 <vprintfmt+0x40>

0080048b <.L30>:
			putch(va_arg(ap, int), putdat);
  80048b:	8b 45 14             	mov    0x14(%ebp),%eax
  80048e:	8d 78 04             	lea    0x4(%eax),%edi
  800491:	83 ec 08             	sub    $0x8,%esp
  800494:	56                   	push   %esi
  800495:	ff 30                	pushl  (%eax)
  800497:	ff 55 08             	call   *0x8(%ebp)
			break;
  80049a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80049d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004a0:	e9 ce 02 00 00       	jmp    800773 <.L35+0x45>

008004a5 <.L32>:
			err = va_arg(ap, int);
  8004a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a8:	8d 78 04             	lea    0x4(%eax),%edi
  8004ab:	8b 00                	mov    (%eax),%eax
  8004ad:	99                   	cltd   
  8004ae:	31 d0                	xor    %edx,%eax
  8004b0:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b2:	83 f8 06             	cmp    $0x6,%eax
  8004b5:	7f 27                	jg     8004de <.L32+0x39>
  8004b7:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004be:	85 d2                	test   %edx,%edx
  8004c0:	74 1c                	je     8004de <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004c2:	52                   	push   %edx
  8004c3:	8d 83 19 f0 ff ff    	lea    -0xfe7(%ebx),%eax
  8004c9:	50                   	push   %eax
  8004ca:	56                   	push   %esi
  8004cb:	ff 75 08             	pushl  0x8(%ebp)
  8004ce:	e8 a4 fe ff ff       	call   800377 <printfmt>
  8004d3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004d6:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004d9:	e9 95 02 00 00       	jmp    800773 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004de:	50                   	push   %eax
  8004df:	8d 83 10 f0 ff ff    	lea    -0xff0(%ebx),%eax
  8004e5:	50                   	push   %eax
  8004e6:	56                   	push   %esi
  8004e7:	ff 75 08             	pushl  0x8(%ebp)
  8004ea:	e8 88 fe ff ff       	call   800377 <printfmt>
  8004ef:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004f2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004f5:	e9 79 02 00 00       	jmp    800773 <.L35+0x45>

008004fa <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	83 c0 04             	add    $0x4,%eax
  800500:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800508:	85 ff                	test   %edi,%edi
  80050a:	8d 83 09 f0 ff ff    	lea    -0xff7(%ebx),%eax
  800510:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800513:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800517:	0f 8e b5 00 00 00    	jle    8005d2 <.L36+0xd8>
  80051d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800521:	75 08                	jne    80052b <.L36+0x31>
  800523:	89 75 0c             	mov    %esi,0xc(%ebp)
  800526:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800529:	eb 6d                	jmp    800598 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	ff 75 cc             	pushl  -0x34(%ebp)
  800531:	57                   	push   %edi
  800532:	e8 85 03 00 00       	call   8008bc <strnlen>
  800537:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80053a:	29 c2                	sub    %eax,%edx
  80053c:	89 55 c8             	mov    %edx,-0x38(%ebp)
  80053f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800542:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800546:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800549:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80054c:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80054e:	eb 10                	jmp    800560 <.L36+0x66>
					putch(padc, putdat);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	56                   	push   %esi
  800554:	ff 75 e0             	pushl  -0x20(%ebp)
  800557:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80055a:	83 ef 01             	sub    $0x1,%edi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 ff                	test   %edi,%edi
  800562:	7f ec                	jg     800550 <.L36+0x56>
  800564:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800567:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80056a:	85 d2                	test   %edx,%edx
  80056c:	b8 00 00 00 00       	mov    $0x0,%eax
  800571:	0f 49 c2             	cmovns %edx,%eax
  800574:	29 c2                	sub    %eax,%edx
  800576:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800579:	89 75 0c             	mov    %esi,0xc(%ebp)
  80057c:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80057f:	eb 17                	jmp    800598 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  800581:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800585:	75 30                	jne    8005b7 <.L36+0xbd>
					putch(ch, putdat);
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	ff 75 0c             	pushl  0xc(%ebp)
  80058d:	50                   	push   %eax
  80058e:	ff 55 08             	call   *0x8(%ebp)
  800591:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800594:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800598:	83 c7 01             	add    $0x1,%edi
  80059b:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80059f:	0f be c2             	movsbl %dl,%eax
  8005a2:	85 c0                	test   %eax,%eax
  8005a4:	74 52                	je     8005f8 <.L36+0xfe>
  8005a6:	85 f6                	test   %esi,%esi
  8005a8:	78 d7                	js     800581 <.L36+0x87>
  8005aa:	83 ee 01             	sub    $0x1,%esi
  8005ad:	79 d2                	jns    800581 <.L36+0x87>
  8005af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005b2:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005b5:	eb 32                	jmp    8005e9 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005b7:	0f be d2             	movsbl %dl,%edx
  8005ba:	83 ea 20             	sub    $0x20,%edx
  8005bd:	83 fa 5e             	cmp    $0x5e,%edx
  8005c0:	76 c5                	jbe    800587 <.L36+0x8d>
					putch('?', putdat);
  8005c2:	83 ec 08             	sub    $0x8,%esp
  8005c5:	ff 75 0c             	pushl  0xc(%ebp)
  8005c8:	6a 3f                	push   $0x3f
  8005ca:	ff 55 08             	call   *0x8(%ebp)
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	eb c2                	jmp    800594 <.L36+0x9a>
  8005d2:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005d5:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005d8:	eb be                	jmp    800598 <.L36+0x9e>
				putch(' ', putdat);
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	56                   	push   %esi
  8005de:	6a 20                	push   $0x20
  8005e0:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8005e3:	83 ef 01             	sub    $0x1,%edi
  8005e6:	83 c4 10             	add    $0x10,%esp
  8005e9:	85 ff                	test   %edi,%edi
  8005eb:	7f ed                	jg     8005da <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  8005ed:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005f0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f3:	e9 7b 01 00 00       	jmp    800773 <.L35+0x45>
  8005f8:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005fe:	eb e9                	jmp    8005e9 <.L36+0xef>

00800600 <.L31>:
  800600:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800603:	83 f9 01             	cmp    $0x1,%ecx
  800606:	7e 40                	jle    800648 <.L31+0x48>
		return va_arg(*ap, long long);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8b 50 04             	mov    0x4(%eax),%edx
  80060e:	8b 00                	mov    (%eax),%eax
  800610:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800613:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8d 40 08             	lea    0x8(%eax),%eax
  80061c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
  80061f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800623:	79 55                	jns    80067a <.L31+0x7a>
				putch('-', putdat);
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	56                   	push   %esi
  800629:	6a 2d                	push   $0x2d
  80062b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  80062e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800631:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800634:	f7 da                	neg    %edx
  800636:	83 d1 00             	adc    $0x0,%ecx
  800639:	f7 d9                	neg    %ecx
  80063b:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
  80063e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800643:	e9 10 01 00 00       	jmp    800758 <.L35+0x2a>
	else if (lflag)
  800648:	85 c9                	test   %ecx,%ecx
  80064a:	75 17                	jne    800663 <.L31+0x63>
		return va_arg(*ap, int);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8b 00                	mov    (%eax),%eax
  800651:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800654:	99                   	cltd   
  800655:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8d 40 04             	lea    0x4(%eax),%eax
  80065e:	89 45 14             	mov    %eax,0x14(%ebp)
  800661:	eb bc                	jmp    80061f <.L31+0x1f>
		return va_arg(*ap, long);
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8b 00                	mov    (%eax),%eax
  800668:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066b:	99                   	cltd   
  80066c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8d 40 04             	lea    0x4(%eax),%eax
  800675:	89 45 14             	mov    %eax,0x14(%ebp)
  800678:	eb a5                	jmp    80061f <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  80067a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80067d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
  800680:	b8 0a 00 00 00       	mov    $0xa,%eax
  800685:	e9 ce 00 00 00       	jmp    800758 <.L35+0x2a>

0080068a <.L37>:
  80068a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80068d:	83 f9 01             	cmp    $0x1,%ecx
  800690:	7e 18                	jle    8006aa <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8b 10                	mov    (%eax),%edx
  800697:	8b 48 04             	mov    0x4(%eax),%ecx
  80069a:	8d 40 08             	lea    0x8(%eax),%eax
  80069d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006a0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a5:	e9 ae 00 00 00       	jmp    800758 <.L35+0x2a>
	else if (lflag)
  8006aa:	85 c9                	test   %ecx,%ecx
  8006ac:	75 1a                	jne    8006c8 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8b 10                	mov    (%eax),%edx
  8006b3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b8:	8d 40 04             	lea    0x4(%eax),%eax
  8006bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c3:	e9 90 00 00 00       	jmp    800758 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 10                	mov    (%eax),%edx
  8006cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d2:	8d 40 04             	lea    0x4(%eax),%eax
  8006d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006dd:	eb 79                	jmp    800758 <.L35+0x2a>

008006df <.L34>:
  8006df:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006e2:	83 f9 01             	cmp    $0x1,%ecx
  8006e5:	7e 15                	jle    8006fc <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8b 10                	mov    (%eax),%edx
  8006ec:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ef:	8d 40 08             	lea    0x8(%eax),%eax
  8006f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006f5:	b8 08 00 00 00       	mov    $0x8,%eax
  8006fa:	eb 5c                	jmp    800758 <.L35+0x2a>
	else if (lflag)
  8006fc:	85 c9                	test   %ecx,%ecx
  8006fe:	75 17                	jne    800717 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800700:	8b 45 14             	mov    0x14(%ebp),%eax
  800703:	8b 10                	mov    (%eax),%edx
  800705:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070a:	8d 40 04             	lea    0x4(%eax),%eax
  80070d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800710:	b8 08 00 00 00       	mov    $0x8,%eax
  800715:	eb 41                	jmp    800758 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	8b 10                	mov    (%eax),%edx
  80071c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800721:	8d 40 04             	lea    0x4(%eax),%eax
  800724:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800727:	b8 08 00 00 00       	mov    $0x8,%eax
  80072c:	eb 2a                	jmp    800758 <.L35+0x2a>

0080072e <.L35>:
			putch('0', putdat);
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	56                   	push   %esi
  800732:	6a 30                	push   $0x30
  800734:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800737:	83 c4 08             	add    $0x8,%esp
  80073a:	56                   	push   %esi
  80073b:	6a 78                	push   $0x78
  80073d:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800740:	8b 45 14             	mov    0x14(%ebp),%eax
  800743:	8b 10                	mov    (%eax),%edx
  800745:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80074a:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80074d:	8d 40 04             	lea    0x4(%eax),%eax
  800750:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800753:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  800758:	83 ec 0c             	sub    $0xc,%esp
  80075b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80075f:	57                   	push   %edi
  800760:	ff 75 e0             	pushl  -0x20(%ebp)
  800763:	50                   	push   %eax
  800764:	51                   	push   %ecx
  800765:	52                   	push   %edx
  800766:	89 f2                	mov    %esi,%edx
  800768:	8b 45 08             	mov    0x8(%ebp),%eax
  80076b:	e8 20 fb ff ff       	call   800290 <printnum>
			break;
  800770:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800773:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  800776:	83 c7 01             	add    $0x1,%edi
  800779:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80077d:	83 f8 25             	cmp    $0x25,%eax
  800780:	0f 84 2d fc ff ff    	je     8003b3 <vprintfmt+0x1f>
			if (ch == '\0')
  800786:	85 c0                	test   %eax,%eax
  800788:	0f 84 91 00 00 00    	je     80081f <.L22+0x21>
			putch(ch, putdat);
  80078e:	83 ec 08             	sub    $0x8,%esp
  800791:	56                   	push   %esi
  800792:	50                   	push   %eax
  800793:	ff 55 08             	call   *0x8(%ebp)
  800796:	83 c4 10             	add    $0x10,%esp
  800799:	eb db                	jmp    800776 <.L35+0x48>

0080079b <.L38>:
  80079b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80079e:	83 f9 01             	cmp    $0x1,%ecx
  8007a1:	7e 15                	jle    8007b8 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8b 10                	mov    (%eax),%edx
  8007a8:	8b 48 04             	mov    0x4(%eax),%ecx
  8007ab:	8d 40 08             	lea    0x8(%eax),%eax
  8007ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b1:	b8 10 00 00 00       	mov    $0x10,%eax
  8007b6:	eb a0                	jmp    800758 <.L35+0x2a>
	else if (lflag)
  8007b8:	85 c9                	test   %ecx,%ecx
  8007ba:	75 17                	jne    8007d3 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bf:	8b 10                	mov    (%eax),%edx
  8007c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c6:	8d 40 04             	lea    0x4(%eax),%eax
  8007c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007cc:	b8 10 00 00 00       	mov    $0x10,%eax
  8007d1:	eb 85                	jmp    800758 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	8b 10                	mov    (%eax),%edx
  8007d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007dd:	8d 40 04             	lea    0x4(%eax),%eax
  8007e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007e3:	b8 10 00 00 00       	mov    $0x10,%eax
  8007e8:	e9 6b ff ff ff       	jmp    800758 <.L35+0x2a>

008007ed <.L25>:
			putch(ch, putdat);
  8007ed:	83 ec 08             	sub    $0x8,%esp
  8007f0:	56                   	push   %esi
  8007f1:	6a 25                	push   $0x25
  8007f3:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007f6:	83 c4 10             	add    $0x10,%esp
  8007f9:	e9 75 ff ff ff       	jmp    800773 <.L35+0x45>

008007fe <.L22>:
			putch('%', putdat);
  8007fe:	83 ec 08             	sub    $0x8,%esp
  800801:	56                   	push   %esi
  800802:	6a 25                	push   $0x25
  800804:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800807:	83 c4 10             	add    $0x10,%esp
  80080a:	89 f8                	mov    %edi,%eax
  80080c:	eb 03                	jmp    800811 <.L22+0x13>
  80080e:	83 e8 01             	sub    $0x1,%eax
  800811:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800815:	75 f7                	jne    80080e <.L22+0x10>
  800817:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80081a:	e9 54 ff ff ff       	jmp    800773 <.L35+0x45>
}
  80081f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800822:	5b                   	pop    %ebx
  800823:	5e                   	pop    %esi
  800824:	5f                   	pop    %edi
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	83 ec 14             	sub    $0x14,%esp
  80082e:	e8 d1 f8 ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800833:	81 c3 cd 17 00 00    	add    $0x17cd,%ebx
  800839:	8b 45 08             	mov    0x8(%ebp),%eax
  80083c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  80083f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800842:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800846:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800849:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800850:	85 c0                	test   %eax,%eax
  800852:	74 2b                	je     80087f <vsnprintf+0x58>
  800854:	85 d2                	test   %edx,%edx
  800856:	7e 27                	jle    80087f <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  800858:	ff 75 14             	pushl  0x14(%ebp)
  80085b:	ff 75 10             	pushl  0x10(%ebp)
  80085e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800861:	50                   	push   %eax
  800862:	8d 83 5a e3 ff ff    	lea    -0x1ca6(%ebx),%eax
  800868:	50                   	push   %eax
  800869:	e8 26 fb ff ff       	call   800394 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80086e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800871:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800874:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800877:	83 c4 10             	add    $0x10,%esp
}
  80087a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087d:	c9                   	leave  
  80087e:	c3                   	ret    
		return -E_INVAL;
  80087f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800884:	eb f4                	jmp    80087a <vsnprintf+0x53>

00800886 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80088c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80088f:	50                   	push   %eax
  800890:	ff 75 10             	pushl  0x10(%ebp)
  800893:	ff 75 0c             	pushl  0xc(%ebp)
  800896:	ff 75 08             	pushl  0x8(%ebp)
  800899:	e8 89 ff ff ff       	call   800827 <vsnprintf>
	va_end(ap);

	return rc;
}
  80089e:	c9                   	leave  
  80089f:	c3                   	ret    

008008a0 <__x86.get_pc_thunk.cx>:
  8008a0:	8b 0c 24             	mov    (%esp),%ecx
  8008a3:	c3                   	ret    

008008a4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8008af:	eb 03                	jmp    8008b4 <strlen+0x10>
		n++;
  8008b1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008b4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b8:	75 f7                	jne    8008b1 <strlen+0xd>
	return n;
}
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ca:	eb 03                	jmp    8008cf <strnlen+0x13>
		n++;
  8008cc:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cf:	39 d0                	cmp    %edx,%eax
  8008d1:	74 06                	je     8008d9 <strnlen+0x1d>
  8008d3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008d7:	75 f3                	jne    8008cc <strnlen+0x10>
	return n;
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	53                   	push   %ebx
  8008df:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e5:	89 c2                	mov    %eax,%edx
  8008e7:	83 c1 01             	add    $0x1,%ecx
  8008ea:	83 c2 01             	add    $0x1,%edx
  8008ed:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008f1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008f4:	84 db                	test   %bl,%bl
  8008f6:	75 ef                	jne    8008e7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008f8:	5b                   	pop    %ebx
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	53                   	push   %ebx
  8008ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800902:	53                   	push   %ebx
  800903:	e8 9c ff ff ff       	call   8008a4 <strlen>
  800908:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80090b:	ff 75 0c             	pushl  0xc(%ebp)
  80090e:	01 d8                	add    %ebx,%eax
  800910:	50                   	push   %eax
  800911:	e8 c5 ff ff ff       	call   8008db <strcpy>
	return dst;
}
  800916:	89 d8                	mov    %ebx,%eax
  800918:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80091b:	c9                   	leave  
  80091c:	c3                   	ret    

0080091d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	56                   	push   %esi
  800921:	53                   	push   %ebx
  800922:	8b 75 08             	mov    0x8(%ebp),%esi
  800925:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800928:	89 f3                	mov    %esi,%ebx
  80092a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80092d:	89 f2                	mov    %esi,%edx
  80092f:	eb 0f                	jmp    800940 <strncpy+0x23>
		*dst++ = *src;
  800931:	83 c2 01             	add    $0x1,%edx
  800934:	0f b6 01             	movzbl (%ecx),%eax
  800937:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80093a:	80 39 01             	cmpb   $0x1,(%ecx)
  80093d:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800940:	39 da                	cmp    %ebx,%edx
  800942:	75 ed                	jne    800931 <strncpy+0x14>
	}
	return ret;
}
  800944:	89 f0                	mov    %esi,%eax
  800946:	5b                   	pop    %ebx
  800947:	5e                   	pop    %esi
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	56                   	push   %esi
  80094e:	53                   	push   %ebx
  80094f:	8b 75 08             	mov    0x8(%ebp),%esi
  800952:	8b 55 0c             	mov    0xc(%ebp),%edx
  800955:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800958:	89 f0                	mov    %esi,%eax
  80095a:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80095e:	85 c9                	test   %ecx,%ecx
  800960:	75 0b                	jne    80096d <strlcpy+0x23>
  800962:	eb 17                	jmp    80097b <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800964:	83 c2 01             	add    $0x1,%edx
  800967:	83 c0 01             	add    $0x1,%eax
  80096a:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80096d:	39 d8                	cmp    %ebx,%eax
  80096f:	74 07                	je     800978 <strlcpy+0x2e>
  800971:	0f b6 0a             	movzbl (%edx),%ecx
  800974:	84 c9                	test   %cl,%cl
  800976:	75 ec                	jne    800964 <strlcpy+0x1a>
		*dst = '\0';
  800978:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80097b:	29 f0                	sub    %esi,%eax
}
  80097d:	5b                   	pop    %ebx
  80097e:	5e                   	pop    %esi
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800987:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80098a:	eb 06                	jmp    800992 <strcmp+0x11>
		p++, q++;
  80098c:	83 c1 01             	add    $0x1,%ecx
  80098f:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800992:	0f b6 01             	movzbl (%ecx),%eax
  800995:	84 c0                	test   %al,%al
  800997:	74 04                	je     80099d <strcmp+0x1c>
  800999:	3a 02                	cmp    (%edx),%al
  80099b:	74 ef                	je     80098c <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80099d:	0f b6 c0             	movzbl %al,%eax
  8009a0:	0f b6 12             	movzbl (%edx),%edx
  8009a3:	29 d0                	sub    %edx,%eax
}
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    

008009a7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	53                   	push   %ebx
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b1:	89 c3                	mov    %eax,%ebx
  8009b3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009b6:	eb 06                	jmp    8009be <strncmp+0x17>
		n--, p++, q++;
  8009b8:	83 c0 01             	add    $0x1,%eax
  8009bb:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009be:	39 d8                	cmp    %ebx,%eax
  8009c0:	74 16                	je     8009d8 <strncmp+0x31>
  8009c2:	0f b6 08             	movzbl (%eax),%ecx
  8009c5:	84 c9                	test   %cl,%cl
  8009c7:	74 04                	je     8009cd <strncmp+0x26>
  8009c9:	3a 0a                	cmp    (%edx),%cl
  8009cb:	74 eb                	je     8009b8 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009cd:	0f b6 00             	movzbl (%eax),%eax
  8009d0:	0f b6 12             	movzbl (%edx),%edx
  8009d3:	29 d0                	sub    %edx,%eax
}
  8009d5:	5b                   	pop    %ebx
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    
		return 0;
  8009d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8009dd:	eb f6                	jmp    8009d5 <strncmp+0x2e>

008009df <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e9:	0f b6 10             	movzbl (%eax),%edx
  8009ec:	84 d2                	test   %dl,%dl
  8009ee:	74 09                	je     8009f9 <strchr+0x1a>
		if (*s == c)
  8009f0:	38 ca                	cmp    %cl,%dl
  8009f2:	74 0a                	je     8009fe <strchr+0x1f>
	for (; *s; s++)
  8009f4:	83 c0 01             	add    $0x1,%eax
  8009f7:	eb f0                	jmp    8009e9 <strchr+0xa>
			return (char *) s;
	return 0;
  8009f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	8b 45 08             	mov    0x8(%ebp),%eax
  800a06:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a0a:	eb 03                	jmp    800a0f <strfind+0xf>
  800a0c:	83 c0 01             	add    $0x1,%eax
  800a0f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a12:	38 ca                	cmp    %cl,%dl
  800a14:	74 04                	je     800a1a <strfind+0x1a>
  800a16:	84 d2                	test   %dl,%dl
  800a18:	75 f2                	jne    800a0c <strfind+0xc>
			break;
	return (char *) s;
}
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	57                   	push   %edi
  800a20:	56                   	push   %esi
  800a21:	53                   	push   %ebx
  800a22:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a25:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a28:	85 c9                	test   %ecx,%ecx
  800a2a:	74 13                	je     800a3f <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a2c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a32:	75 05                	jne    800a39 <memset+0x1d>
  800a34:	f6 c1 03             	test   $0x3,%cl
  800a37:	74 0d                	je     800a46 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3c:	fc                   	cld    
  800a3d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a3f:	89 f8                	mov    %edi,%eax
  800a41:	5b                   	pop    %ebx
  800a42:	5e                   	pop    %esi
  800a43:	5f                   	pop    %edi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    
		c &= 0xFF;
  800a46:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a4a:	89 d3                	mov    %edx,%ebx
  800a4c:	c1 e3 08             	shl    $0x8,%ebx
  800a4f:	89 d0                	mov    %edx,%eax
  800a51:	c1 e0 18             	shl    $0x18,%eax
  800a54:	89 d6                	mov    %edx,%esi
  800a56:	c1 e6 10             	shl    $0x10,%esi
  800a59:	09 f0                	or     %esi,%eax
  800a5b:	09 c2                	or     %eax,%edx
  800a5d:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a5f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a62:	89 d0                	mov    %edx,%eax
  800a64:	fc                   	cld    
  800a65:	f3 ab                	rep stos %eax,%es:(%edi)
  800a67:	eb d6                	jmp    800a3f <memset+0x23>

00800a69 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	57                   	push   %edi
  800a6d:	56                   	push   %esi
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a74:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a77:	39 c6                	cmp    %eax,%esi
  800a79:	73 35                	jae    800ab0 <memmove+0x47>
  800a7b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a7e:	39 c2                	cmp    %eax,%edx
  800a80:	76 2e                	jbe    800ab0 <memmove+0x47>
		s += n;
		d += n;
  800a82:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a85:	89 d6                	mov    %edx,%esi
  800a87:	09 fe                	or     %edi,%esi
  800a89:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a8f:	74 0c                	je     800a9d <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a91:	83 ef 01             	sub    $0x1,%edi
  800a94:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a97:	fd                   	std    
  800a98:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a9a:	fc                   	cld    
  800a9b:	eb 21                	jmp    800abe <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9d:	f6 c1 03             	test   $0x3,%cl
  800aa0:	75 ef                	jne    800a91 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aa2:	83 ef 04             	sub    $0x4,%edi
  800aa5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800aab:	fd                   	std    
  800aac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aae:	eb ea                	jmp    800a9a <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab0:	89 f2                	mov    %esi,%edx
  800ab2:	09 c2                	or     %eax,%edx
  800ab4:	f6 c2 03             	test   $0x3,%dl
  800ab7:	74 09                	je     800ac2 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ab9:	89 c7                	mov    %eax,%edi
  800abb:	fc                   	cld    
  800abc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800abe:	5e                   	pop    %esi
  800abf:	5f                   	pop    %edi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac2:	f6 c1 03             	test   $0x3,%cl
  800ac5:	75 f2                	jne    800ab9 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ac7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800aca:	89 c7                	mov    %eax,%edi
  800acc:	fc                   	cld    
  800acd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acf:	eb ed                	jmp    800abe <memmove+0x55>

00800ad1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ad4:	ff 75 10             	pushl  0x10(%ebp)
  800ad7:	ff 75 0c             	pushl  0xc(%ebp)
  800ada:	ff 75 08             	pushl  0x8(%ebp)
  800add:	e8 87 ff ff ff       	call   800a69 <memmove>
}
  800ae2:	c9                   	leave  
  800ae3:	c3                   	ret    

00800ae4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
  800ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aef:	89 c6                	mov    %eax,%esi
  800af1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af4:	39 f0                	cmp    %esi,%eax
  800af6:	74 1c                	je     800b14 <memcmp+0x30>
		if (*s1 != *s2)
  800af8:	0f b6 08             	movzbl (%eax),%ecx
  800afb:	0f b6 1a             	movzbl (%edx),%ebx
  800afe:	38 d9                	cmp    %bl,%cl
  800b00:	75 08                	jne    800b0a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b02:	83 c0 01             	add    $0x1,%eax
  800b05:	83 c2 01             	add    $0x1,%edx
  800b08:	eb ea                	jmp    800af4 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b0a:	0f b6 c1             	movzbl %cl,%eax
  800b0d:	0f b6 db             	movzbl %bl,%ebx
  800b10:	29 d8                	sub    %ebx,%eax
  800b12:	eb 05                	jmp    800b19 <memcmp+0x35>
	}

	return 0;
  800b14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	8b 45 08             	mov    0x8(%ebp),%eax
  800b23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b26:	89 c2                	mov    %eax,%edx
  800b28:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b2b:	39 d0                	cmp    %edx,%eax
  800b2d:	73 09                	jae    800b38 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b2f:	38 08                	cmp    %cl,(%eax)
  800b31:	74 05                	je     800b38 <memfind+0x1b>
	for (; s < ends; s++)
  800b33:	83 c0 01             	add    $0x1,%eax
  800b36:	eb f3                	jmp    800b2b <memfind+0xe>
			break;
	return (void *) s;
}
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
  800b40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b46:	eb 03                	jmp    800b4b <strtol+0x11>
		s++;
  800b48:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b4b:	0f b6 01             	movzbl (%ecx),%eax
  800b4e:	3c 20                	cmp    $0x20,%al
  800b50:	74 f6                	je     800b48 <strtol+0xe>
  800b52:	3c 09                	cmp    $0x9,%al
  800b54:	74 f2                	je     800b48 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b56:	3c 2b                	cmp    $0x2b,%al
  800b58:	74 2e                	je     800b88 <strtol+0x4e>
	int neg = 0;
  800b5a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b5f:	3c 2d                	cmp    $0x2d,%al
  800b61:	74 2f                	je     800b92 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b63:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b69:	75 05                	jne    800b70 <strtol+0x36>
  800b6b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6e:	74 2c                	je     800b9c <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b70:	85 db                	test   %ebx,%ebx
  800b72:	75 0a                	jne    800b7e <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b74:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b79:	80 39 30             	cmpb   $0x30,(%ecx)
  800b7c:	74 28                	je     800ba6 <strtol+0x6c>
		base = 10;
  800b7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b83:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b86:	eb 50                	jmp    800bd8 <strtol+0x9e>
		s++;
  800b88:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b8b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b90:	eb d1                	jmp    800b63 <strtol+0x29>
		s++, neg = 1;
  800b92:	83 c1 01             	add    $0x1,%ecx
  800b95:	bf 01 00 00 00       	mov    $0x1,%edi
  800b9a:	eb c7                	jmp    800b63 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b9c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ba0:	74 0e                	je     800bb0 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ba2:	85 db                	test   %ebx,%ebx
  800ba4:	75 d8                	jne    800b7e <strtol+0x44>
		s++, base = 8;
  800ba6:	83 c1 01             	add    $0x1,%ecx
  800ba9:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bae:	eb ce                	jmp    800b7e <strtol+0x44>
		s += 2, base = 16;
  800bb0:	83 c1 02             	add    $0x2,%ecx
  800bb3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb8:	eb c4                	jmp    800b7e <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bba:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bbd:	89 f3                	mov    %esi,%ebx
  800bbf:	80 fb 19             	cmp    $0x19,%bl
  800bc2:	77 29                	ja     800bed <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bc4:	0f be d2             	movsbl %dl,%edx
  800bc7:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bca:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bcd:	7d 30                	jge    800bff <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bcf:	83 c1 01             	add    $0x1,%ecx
  800bd2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bd6:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bd8:	0f b6 11             	movzbl (%ecx),%edx
  800bdb:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bde:	89 f3                	mov    %esi,%ebx
  800be0:	80 fb 09             	cmp    $0x9,%bl
  800be3:	77 d5                	ja     800bba <strtol+0x80>
			dig = *s - '0';
  800be5:	0f be d2             	movsbl %dl,%edx
  800be8:	83 ea 30             	sub    $0x30,%edx
  800beb:	eb dd                	jmp    800bca <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bed:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bf0:	89 f3                	mov    %esi,%ebx
  800bf2:	80 fb 19             	cmp    $0x19,%bl
  800bf5:	77 08                	ja     800bff <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bf7:	0f be d2             	movsbl %dl,%edx
  800bfa:	83 ea 37             	sub    $0x37,%edx
  800bfd:	eb cb                	jmp    800bca <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c03:	74 05                	je     800c0a <strtol+0xd0>
		*endptr = (char *) s;
  800c05:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c08:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c0a:	89 c2                	mov    %eax,%edx
  800c0c:	f7 da                	neg    %edx
  800c0e:	85 ff                	test   %edi,%edi
  800c10:	0f 45 c2             	cmovne %edx,%eax
}
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c23:	8b 55 08             	mov    0x8(%ebp),%edx
  800c26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c29:	89 c3                	mov    %eax,%ebx
  800c2b:	89 c7                	mov    %eax,%edi
  800c2d:	89 c6                	mov    %eax,%esi
  800c2f:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c41:	b8 01 00 00 00       	mov    $0x1,%eax
  800c46:	89 d1                	mov    %edx,%ecx
  800c48:	89 d3                	mov    %edx,%ebx
  800c4a:	89 d7                	mov    %edx,%edi
  800c4c:	89 d6                	mov    %edx,%esi
  800c4e:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 1c             	sub    $0x1c,%esp
  800c5e:	e8 66 00 00 00       	call   800cc9 <__x86.get_pc_thunk.ax>
  800c63:	05 9d 13 00 00       	add    $0x139d,%eax
  800c68:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800c6b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c70:	8b 55 08             	mov    0x8(%ebp),%edx
  800c73:	b8 03 00 00 00       	mov    $0x3,%eax
  800c78:	89 cb                	mov    %ecx,%ebx
  800c7a:	89 cf                	mov    %ecx,%edi
  800c7c:	89 ce                	mov    %ecx,%esi
  800c7e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7f 08                	jg     800c8c <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8c:	83 ec 0c             	sub    $0xc,%esp
  800c8f:	50                   	push   %eax
  800c90:	6a 03                	push   $0x3
  800c92:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c95:	8d 83 e0 f1 ff ff    	lea    -0xe20(%ebx),%eax
  800c9b:	50                   	push   %eax
  800c9c:	6a 23                	push   $0x23
  800c9e:	8d 83 fd f1 ff ff    	lea    -0xe03(%ebx),%eax
  800ca4:	50                   	push   %eax
  800ca5:	e8 c6 f4 ff ff       	call   800170 <_panic>

00800caa <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb5:	b8 02 00 00 00       	mov    $0x2,%eax
  800cba:	89 d1                	mov    %edx,%ecx
  800cbc:	89 d3                	mov    %edx,%ebx
  800cbe:	89 d7                	mov    %edx,%edi
  800cc0:	89 d6                	mov    %edx,%esi
  800cc2:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <__x86.get_pc_thunk.ax>:
  800cc9:	8b 04 24             	mov    (%esp),%eax
  800ccc:	c3                   	ret    
  800ccd:	66 90                	xchg   %ax,%ax
  800ccf:	90                   	nop

00800cd0 <__udivdi3>:
  800cd0:	55                   	push   %ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
  800cd4:	83 ec 1c             	sub    $0x1c,%esp
  800cd7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800cdb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800cdf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ce3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800ce7:	85 d2                	test   %edx,%edx
  800ce9:	75 35                	jne    800d20 <__udivdi3+0x50>
  800ceb:	39 f3                	cmp    %esi,%ebx
  800ced:	0f 87 bd 00 00 00    	ja     800db0 <__udivdi3+0xe0>
  800cf3:	85 db                	test   %ebx,%ebx
  800cf5:	89 d9                	mov    %ebx,%ecx
  800cf7:	75 0b                	jne    800d04 <__udivdi3+0x34>
  800cf9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfe:	31 d2                	xor    %edx,%edx
  800d00:	f7 f3                	div    %ebx
  800d02:	89 c1                	mov    %eax,%ecx
  800d04:	31 d2                	xor    %edx,%edx
  800d06:	89 f0                	mov    %esi,%eax
  800d08:	f7 f1                	div    %ecx
  800d0a:	89 c6                	mov    %eax,%esi
  800d0c:	89 e8                	mov    %ebp,%eax
  800d0e:	89 f7                	mov    %esi,%edi
  800d10:	f7 f1                	div    %ecx
  800d12:	89 fa                	mov    %edi,%edx
  800d14:	83 c4 1c             	add    $0x1c,%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    
  800d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d20:	39 f2                	cmp    %esi,%edx
  800d22:	77 7c                	ja     800da0 <__udivdi3+0xd0>
  800d24:	0f bd fa             	bsr    %edx,%edi
  800d27:	83 f7 1f             	xor    $0x1f,%edi
  800d2a:	0f 84 98 00 00 00    	je     800dc8 <__udivdi3+0xf8>
  800d30:	89 f9                	mov    %edi,%ecx
  800d32:	b8 20 00 00 00       	mov    $0x20,%eax
  800d37:	29 f8                	sub    %edi,%eax
  800d39:	d3 e2                	shl    %cl,%edx
  800d3b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d3f:	89 c1                	mov    %eax,%ecx
  800d41:	89 da                	mov    %ebx,%edx
  800d43:	d3 ea                	shr    %cl,%edx
  800d45:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d49:	09 d1                	or     %edx,%ecx
  800d4b:	89 f2                	mov    %esi,%edx
  800d4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d51:	89 f9                	mov    %edi,%ecx
  800d53:	d3 e3                	shl    %cl,%ebx
  800d55:	89 c1                	mov    %eax,%ecx
  800d57:	d3 ea                	shr    %cl,%edx
  800d59:	89 f9                	mov    %edi,%ecx
  800d5b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d5f:	d3 e6                	shl    %cl,%esi
  800d61:	89 eb                	mov    %ebp,%ebx
  800d63:	89 c1                	mov    %eax,%ecx
  800d65:	d3 eb                	shr    %cl,%ebx
  800d67:	09 de                	or     %ebx,%esi
  800d69:	89 f0                	mov    %esi,%eax
  800d6b:	f7 74 24 08          	divl   0x8(%esp)
  800d6f:	89 d6                	mov    %edx,%esi
  800d71:	89 c3                	mov    %eax,%ebx
  800d73:	f7 64 24 0c          	mull   0xc(%esp)
  800d77:	39 d6                	cmp    %edx,%esi
  800d79:	72 0c                	jb     800d87 <__udivdi3+0xb7>
  800d7b:	89 f9                	mov    %edi,%ecx
  800d7d:	d3 e5                	shl    %cl,%ebp
  800d7f:	39 c5                	cmp    %eax,%ebp
  800d81:	73 5d                	jae    800de0 <__udivdi3+0x110>
  800d83:	39 d6                	cmp    %edx,%esi
  800d85:	75 59                	jne    800de0 <__udivdi3+0x110>
  800d87:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d8a:	31 ff                	xor    %edi,%edi
  800d8c:	89 fa                	mov    %edi,%edx
  800d8e:	83 c4 1c             	add    $0x1c,%esp
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    
  800d96:	8d 76 00             	lea    0x0(%esi),%esi
  800d99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800da0:	31 ff                	xor    %edi,%edi
  800da2:	31 c0                	xor    %eax,%eax
  800da4:	89 fa                	mov    %edi,%edx
  800da6:	83 c4 1c             	add    $0x1c,%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    
  800dae:	66 90                	xchg   %ax,%ax
  800db0:	31 ff                	xor    %edi,%edi
  800db2:	89 e8                	mov    %ebp,%eax
  800db4:	89 f2                	mov    %esi,%edx
  800db6:	f7 f3                	div    %ebx
  800db8:	89 fa                	mov    %edi,%edx
  800dba:	83 c4 1c             	add    $0x1c,%esp
  800dbd:	5b                   	pop    %ebx
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    
  800dc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800dc8:	39 f2                	cmp    %esi,%edx
  800dca:	72 06                	jb     800dd2 <__udivdi3+0x102>
  800dcc:	31 c0                	xor    %eax,%eax
  800dce:	39 eb                	cmp    %ebp,%ebx
  800dd0:	77 d2                	ja     800da4 <__udivdi3+0xd4>
  800dd2:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd7:	eb cb                	jmp    800da4 <__udivdi3+0xd4>
  800dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800de0:	89 d8                	mov    %ebx,%eax
  800de2:	31 ff                	xor    %edi,%edi
  800de4:	eb be                	jmp    800da4 <__udivdi3+0xd4>
  800de6:	66 90                	xchg   %ax,%ax
  800de8:	66 90                	xchg   %ax,%ax
  800dea:	66 90                	xchg   %ax,%ax
  800dec:	66 90                	xchg   %ax,%ax
  800dee:	66 90                	xchg   %ax,%ax

00800df0 <__umoddi3>:
  800df0:	55                   	push   %ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
  800df4:	83 ec 1c             	sub    $0x1c,%esp
  800df7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800dfb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800dff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e07:	85 ed                	test   %ebp,%ebp
  800e09:	89 f0                	mov    %esi,%eax
  800e0b:	89 da                	mov    %ebx,%edx
  800e0d:	75 19                	jne    800e28 <__umoddi3+0x38>
  800e0f:	39 df                	cmp    %ebx,%edi
  800e11:	0f 86 b1 00 00 00    	jbe    800ec8 <__umoddi3+0xd8>
  800e17:	f7 f7                	div    %edi
  800e19:	89 d0                	mov    %edx,%eax
  800e1b:	31 d2                	xor    %edx,%edx
  800e1d:	83 c4 1c             	add    $0x1c,%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    
  800e25:	8d 76 00             	lea    0x0(%esi),%esi
  800e28:	39 dd                	cmp    %ebx,%ebp
  800e2a:	77 f1                	ja     800e1d <__umoddi3+0x2d>
  800e2c:	0f bd cd             	bsr    %ebp,%ecx
  800e2f:	83 f1 1f             	xor    $0x1f,%ecx
  800e32:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e36:	0f 84 b4 00 00 00    	je     800ef0 <__umoddi3+0x100>
  800e3c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e41:	89 c2                	mov    %eax,%edx
  800e43:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e47:	29 c2                	sub    %eax,%edx
  800e49:	89 c1                	mov    %eax,%ecx
  800e4b:	89 f8                	mov    %edi,%eax
  800e4d:	d3 e5                	shl    %cl,%ebp
  800e4f:	89 d1                	mov    %edx,%ecx
  800e51:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e55:	d3 e8                	shr    %cl,%eax
  800e57:	09 c5                	or     %eax,%ebp
  800e59:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e5d:	89 c1                	mov    %eax,%ecx
  800e5f:	d3 e7                	shl    %cl,%edi
  800e61:	89 d1                	mov    %edx,%ecx
  800e63:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e67:	89 df                	mov    %ebx,%edi
  800e69:	d3 ef                	shr    %cl,%edi
  800e6b:	89 c1                	mov    %eax,%ecx
  800e6d:	89 f0                	mov    %esi,%eax
  800e6f:	d3 e3                	shl    %cl,%ebx
  800e71:	89 d1                	mov    %edx,%ecx
  800e73:	89 fa                	mov    %edi,%edx
  800e75:	d3 e8                	shr    %cl,%eax
  800e77:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e7c:	09 d8                	or     %ebx,%eax
  800e7e:	f7 f5                	div    %ebp
  800e80:	d3 e6                	shl    %cl,%esi
  800e82:	89 d1                	mov    %edx,%ecx
  800e84:	f7 64 24 08          	mull   0x8(%esp)
  800e88:	39 d1                	cmp    %edx,%ecx
  800e8a:	89 c3                	mov    %eax,%ebx
  800e8c:	89 d7                	mov    %edx,%edi
  800e8e:	72 06                	jb     800e96 <__umoddi3+0xa6>
  800e90:	75 0e                	jne    800ea0 <__umoddi3+0xb0>
  800e92:	39 c6                	cmp    %eax,%esi
  800e94:	73 0a                	jae    800ea0 <__umoddi3+0xb0>
  800e96:	2b 44 24 08          	sub    0x8(%esp),%eax
  800e9a:	19 ea                	sbb    %ebp,%edx
  800e9c:	89 d7                	mov    %edx,%edi
  800e9e:	89 c3                	mov    %eax,%ebx
  800ea0:	89 ca                	mov    %ecx,%edx
  800ea2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800ea7:	29 de                	sub    %ebx,%esi
  800ea9:	19 fa                	sbb    %edi,%edx
  800eab:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800eaf:	89 d0                	mov    %edx,%eax
  800eb1:	d3 e0                	shl    %cl,%eax
  800eb3:	89 d9                	mov    %ebx,%ecx
  800eb5:	d3 ee                	shr    %cl,%esi
  800eb7:	d3 ea                	shr    %cl,%edx
  800eb9:	09 f0                	or     %esi,%eax
  800ebb:	83 c4 1c             	add    $0x1c,%esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    
  800ec3:	90                   	nop
  800ec4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ec8:	85 ff                	test   %edi,%edi
  800eca:	89 f9                	mov    %edi,%ecx
  800ecc:	75 0b                	jne    800ed9 <__umoddi3+0xe9>
  800ece:	b8 01 00 00 00       	mov    $0x1,%eax
  800ed3:	31 d2                	xor    %edx,%edx
  800ed5:	f7 f7                	div    %edi
  800ed7:	89 c1                	mov    %eax,%ecx
  800ed9:	89 d8                	mov    %ebx,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	f7 f1                	div    %ecx
  800edf:	89 f0                	mov    %esi,%eax
  800ee1:	f7 f1                	div    %ecx
  800ee3:	e9 31 ff ff ff       	jmp    800e19 <__umoddi3+0x29>
  800ee8:	90                   	nop
  800ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	39 dd                	cmp    %ebx,%ebp
  800ef2:	72 08                	jb     800efc <__umoddi3+0x10c>
  800ef4:	39 f7                	cmp    %esi,%edi
  800ef6:	0f 87 21 ff ff ff    	ja     800e1d <__umoddi3+0x2d>
  800efc:	89 da                	mov    %ebx,%edx
  800efe:	89 f0                	mov    %esi,%eax
  800f00:	29 f8                	sub    %edi,%eax
  800f02:	19 ea                	sbb    %ebp,%edx
  800f04:	e9 14 ff ff ff       	jmp    800e1d <__umoddi3+0x2d>
