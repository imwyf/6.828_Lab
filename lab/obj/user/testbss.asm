
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
  800045:	8d 83 6c f1 ff ff    	lea    -0xe94(%ebx),%eax
  80004b:	50                   	push   %eax
  80004c:	e8 3f 02 00 00       	call   800290 <cprintf>
  800051:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800054:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  800059:	c7 c2 60 20 80 00    	mov    $0x802060,%edx
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
  800074:	c7 c2 60 20 80 00    	mov    $0x802060,%edx
  80007a:	89 04 82             	mov    %eax,(%edx,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	83 c0 01             	add    $0x1,%eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 f3                	jne    80007a <umain+0x47>
	for (i = 0; i < ARRAYSIZE; i++)
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  80008c:	c7 c2 60 20 80 00    	mov    $0x802060,%edx
  800092:	39 04 82             	cmp    %eax,(%edx,%eax,4)
  800095:	75 57                	jne    8000ee <umain+0xbb>
	for (i = 0; i < ARRAYSIZE; i++)
  800097:	83 c0 01             	add    $0x1,%eax
  80009a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80009f:	75 f1                	jne    800092 <umain+0x5f>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000a1:	83 ec 0c             	sub    $0xc,%esp
  8000a4:	8d 83 b4 f1 ff ff    	lea    -0xe4c(%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	e8 e0 01 00 00       	call   800290 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000b0:	c7 c0 60 20 80 00    	mov    $0x802060,%eax
  8000b6:	c7 80 00 10 40 00 00 	movl   $0x0,0x401000(%eax)
  8000bd:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c0:	83 c4 0c             	add    $0xc,%esp
  8000c3:	8d 83 13 f2 ff ff    	lea    -0xded(%ebx),%eax
  8000c9:	50                   	push   %eax
  8000ca:	6a 1a                	push   $0x1a
  8000cc:	8d 83 04 f2 ff ff    	lea    -0xdfc(%ebx),%eax
  8000d2:	50                   	push   %eax
  8000d3:	e8 ac 00 00 00       	call   800184 <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000d8:	50                   	push   %eax
  8000d9:	8d 83 e7 f1 ff ff    	lea    -0xe19(%ebx),%eax
  8000df:	50                   	push   %eax
  8000e0:	6a 11                	push   $0x11
  8000e2:	8d 83 04 f2 ff ff    	lea    -0xdfc(%ebx),%eax
  8000e8:	50                   	push   %eax
  8000e9:	e8 96 00 00 00       	call   800184 <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ee:	50                   	push   %eax
  8000ef:	8d 83 8c f1 ff ff    	lea    -0xe74(%ebx),%eax
  8000f5:	50                   	push   %eax
  8000f6:	6a 16                	push   $0x16
  8000f8:	8d 83 04 f2 ff ff    	lea    -0xdfc(%ebx),%eax
  8000fe:	50                   	push   %eax
  8000ff:	e8 80 00 00 00       	call   800184 <_panic>

00800104 <__x86.get_pc_thunk.bx>:
  800104:	8b 1c 24             	mov    (%esp),%ebx
  800107:	c3                   	ret    

00800108 <libmain>:

const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void libmain(int argc, char **argv)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	57                   	push   %edi
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	e8 ee ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800116:	81 c3 ea 1e 00 00    	add    $0x1eea,%ebx
  80011c:	8b 75 08             	mov    0x8(%ebp),%esi
  80011f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())]; // ENVX()得到id在Env[]数组中对应的下标
  800122:	e8 97 0b 00 00       	call   800cbe <sys_getenvid>
  800127:	25 ff 03 00 00       	and    $0x3ff,%eax
  80012c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80012f:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800135:	c7 c2 60 20 c0 00    	mov    $0xc02060,%edx
  80013b:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80013d:	85 f6                	test   %esi,%esi
  80013f:	7e 08                	jle    800149 <libmain+0x41>
		binaryname = argv[0];
  800141:	8b 07                	mov    (%edi),%eax
  800143:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800149:	83 ec 08             	sub    $0x8,%esp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	e8 e0 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800153:	e8 0b 00 00 00       	call   800163 <exit>
}
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	53                   	push   %ebx
  800167:	83 ec 10             	sub    $0x10,%esp
  80016a:	e8 95 ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  80016f:	81 c3 91 1e 00 00    	add    $0x1e91,%ebx
	sys_env_destroy(0);
  800175:	6a 00                	push   $0x0
  800177:	e8 ed 0a 00 00       	call   800c69 <sys_env_destroy>
}
  80017c:	83 c4 10             	add    $0x10,%esp
  80017f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800182:	c9                   	leave  
  800183:	c3                   	ret    

00800184 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	57                   	push   %edi
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	e8 72 ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800192:	81 c3 6e 1e 00 00    	add    $0x1e6e,%ebx
	va_list ap;

	va_start(ap, fmt);
  800198:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019b:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  8001a1:	8b 38                	mov    (%eax),%edi
  8001a3:	e8 16 0b 00 00       	call   800cbe <sys_getenvid>
  8001a8:	83 ec 0c             	sub    $0xc,%esp
  8001ab:	ff 75 0c             	pushl  0xc(%ebp)
  8001ae:	ff 75 08             	pushl  0x8(%ebp)
  8001b1:	57                   	push   %edi
  8001b2:	50                   	push   %eax
  8001b3:	8d 83 34 f2 ff ff    	lea    -0xdcc(%ebx),%eax
  8001b9:	50                   	push   %eax
  8001ba:	e8 d1 00 00 00       	call   800290 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bf:	83 c4 18             	add    $0x18,%esp
  8001c2:	56                   	push   %esi
  8001c3:	ff 75 10             	pushl  0x10(%ebp)
  8001c6:	e8 63 00 00 00       	call   80022e <vcprintf>
	cprintf("\n");
  8001cb:	8d 83 02 f2 ff ff    	lea    -0xdfe(%ebx),%eax
  8001d1:	89 04 24             	mov    %eax,(%esp)
  8001d4:	e8 b7 00 00 00       	call   800290 <cprintf>
  8001d9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001dc:	cc                   	int3   
  8001dd:	eb fd                	jmp    8001dc <_panic+0x58>

008001df <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	56                   	push   %esi
  8001e3:	53                   	push   %ebx
  8001e4:	e8 1b ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  8001e9:	81 c3 17 1e 00 00    	add    $0x1e17,%ebx
  8001ef:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001f2:	8b 16                	mov    (%esi),%edx
  8001f4:	8d 42 01             	lea    0x1(%edx),%eax
  8001f7:	89 06                	mov    %eax,(%esi)
  8001f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001fc:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800200:	3d ff 00 00 00       	cmp    $0xff,%eax
  800205:	74 0b                	je     800212 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800207:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80020b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80020e:	5b                   	pop    %ebx
  80020f:	5e                   	pop    %esi
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800212:	83 ec 08             	sub    $0x8,%esp
  800215:	68 ff 00 00 00       	push   $0xff
  80021a:	8d 46 08             	lea    0x8(%esi),%eax
  80021d:	50                   	push   %eax
  80021e:	e8 09 0a 00 00       	call   800c2c <sys_cputs>
		b->idx = 0;
  800223:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800229:	83 c4 10             	add    $0x10,%esp
  80022c:	eb d9                	jmp    800207 <putch+0x28>

0080022e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	53                   	push   %ebx
  800232:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800238:	e8 c7 fe ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  80023d:	81 c3 c3 1d 00 00    	add    $0x1dc3,%ebx
	struct printbuf b;

	b.idx = 0;
  800243:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024a:	00 00 00 
	b.cnt = 0;
  80024d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800254:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800257:	ff 75 0c             	pushl  0xc(%ebp)
  80025a:	ff 75 08             	pushl  0x8(%ebp)
  80025d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	8d 83 df e1 ff ff    	lea    -0x1e21(%ebx),%eax
  80026a:	50                   	push   %eax
  80026b:	e8 38 01 00 00       	call   8003a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800270:	83 c4 08             	add    $0x8,%esp
  800273:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800279:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027f:	50                   	push   %eax
  800280:	e8 a7 09 00 00       	call   800c2c <sys_cputs>

	return b.cnt;
}
  800285:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800296:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800299:	50                   	push   %eax
  80029a:	ff 75 08             	pushl  0x8(%ebp)
  80029d:	e8 8c ff ff ff       	call   80022e <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	57                   	push   %edi
  8002a8:	56                   	push   %esi
  8002a9:	53                   	push   %ebx
  8002aa:	83 ec 2c             	sub    $0x2c,%esp
  8002ad:	e8 02 06 00 00       	call   8008b4 <__x86.get_pc_thunk.cx>
  8002b2:	81 c1 4e 1d 00 00    	add    $0x1d4e,%ecx
  8002b8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002bb:	89 c7                	mov    %eax,%edi
  8002bd:	89 d6                	mov    %edx,%esi
  8002bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002c8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  8002cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d3:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002d6:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002d9:	39 d3                	cmp    %edx,%ebx
  8002db:	72 09                	jb     8002e6 <printnum+0x42>
  8002dd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002e0:	0f 87 83 00 00 00    	ja     800369 <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e6:	83 ec 0c             	sub    $0xc,%esp
  8002e9:	ff 75 18             	pushl  0x18(%ebp)
  8002ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ef:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002f2:	53                   	push   %ebx
  8002f3:	ff 75 10             	pushl  0x10(%ebp)
  8002f6:	83 ec 08             	sub    $0x8,%esp
  8002f9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002fc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ff:	ff 75 d4             	pushl  -0x2c(%ebp)
  800302:	ff 75 d0             	pushl  -0x30(%ebp)
  800305:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800308:	e8 23 0c 00 00       	call   800f30 <__udivdi3>
  80030d:	83 c4 18             	add    $0x18,%esp
  800310:	52                   	push   %edx
  800311:	50                   	push   %eax
  800312:	89 f2                	mov    %esi,%edx
  800314:	89 f8                	mov    %edi,%eax
  800316:	e8 89 ff ff ff       	call   8002a4 <printnum>
  80031b:	83 c4 20             	add    $0x20,%esp
  80031e:	eb 13                	jmp    800333 <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800320:	83 ec 08             	sub    $0x8,%esp
  800323:	56                   	push   %esi
  800324:	ff 75 18             	pushl  0x18(%ebp)
  800327:	ff d7                	call   *%edi
  800329:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80032c:	83 eb 01             	sub    $0x1,%ebx
  80032f:	85 db                	test   %ebx,%ebx
  800331:	7f ed                	jg     800320 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800333:	83 ec 08             	sub    $0x8,%esp
  800336:	56                   	push   %esi
  800337:	83 ec 04             	sub    $0x4,%esp
  80033a:	ff 75 dc             	pushl  -0x24(%ebp)
  80033d:	ff 75 d8             	pushl  -0x28(%ebp)
  800340:	ff 75 d4             	pushl  -0x2c(%ebp)
  800343:	ff 75 d0             	pushl  -0x30(%ebp)
  800346:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800349:	89 f3                	mov    %esi,%ebx
  80034b:	e8 00 0d 00 00       	call   801050 <__umoddi3>
  800350:	83 c4 14             	add    $0x14,%esp
  800353:	0f be 84 06 58 f2 ff 	movsbl -0xda8(%esi,%eax,1),%eax
  80035a:	ff 
  80035b:	50                   	push   %eax
  80035c:	ff d7                	call   *%edi
}
  80035e:	83 c4 10             	add    $0x10,%esp
  800361:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800364:	5b                   	pop    %ebx
  800365:	5e                   	pop    %esi
  800366:	5f                   	pop    %edi
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    
  800369:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80036c:	eb be                	jmp    80032c <printnum+0x88>

0080036e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800374:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800378:	8b 10                	mov    (%eax),%edx
  80037a:	3b 50 04             	cmp    0x4(%eax),%edx
  80037d:	73 0a                	jae    800389 <sprintputch+0x1b>
		*b->buf++ = ch;
  80037f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800382:	89 08                	mov    %ecx,(%eax)
  800384:	8b 45 08             	mov    0x8(%ebp),%eax
  800387:	88 02                	mov    %al,(%edx)
}
  800389:	5d                   	pop    %ebp
  80038a:	c3                   	ret    

0080038b <printfmt>:
{
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
  80038e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800391:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800394:	50                   	push   %eax
  800395:	ff 75 10             	pushl  0x10(%ebp)
  800398:	ff 75 0c             	pushl  0xc(%ebp)
  80039b:	ff 75 08             	pushl  0x8(%ebp)
  80039e:	e8 05 00 00 00       	call   8003a8 <vprintfmt>
}
  8003a3:	83 c4 10             	add    $0x10,%esp
  8003a6:	c9                   	leave  
  8003a7:	c3                   	ret    

008003a8 <vprintfmt>:
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	57                   	push   %edi
  8003ac:	56                   	push   %esi
  8003ad:	53                   	push   %ebx
  8003ae:	83 ec 2c             	sub    $0x2c,%esp
  8003b1:	e8 4e fd ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  8003b6:	81 c3 4a 1c 00 00    	add    $0x1c4a,%ebx
  8003bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003bf:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003c2:	e9 c3 03 00 00       	jmp    80078a <.L35+0x48>
		padc = ' ';
  8003c7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003cb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003d2:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003d9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e5:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8003e8:	8d 47 01             	lea    0x1(%edi),%eax
  8003eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ee:	0f b6 17             	movzbl (%edi),%edx
  8003f1:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003f4:	3c 55                	cmp    $0x55,%al
  8003f6:	0f 87 16 04 00 00    	ja     800812 <.L22>
  8003fc:	0f b6 c0             	movzbl %al,%eax
  8003ff:	89 d9                	mov    %ebx,%ecx
  800401:	03 8c 83 10 f3 ff ff 	add    -0xcf0(%ebx,%eax,4),%ecx
  800408:	ff e1                	jmp    *%ecx

0080040a <.L69>:
  80040a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80040d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800411:	eb d5                	jmp    8003e8 <vprintfmt+0x40>

00800413 <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800413:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800416:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80041a:	eb cc                	jmp    8003e8 <vprintfmt+0x40>

0080041c <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80041c:	0f b6 d2             	movzbl %dl,%edx
  80041f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
  800422:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800427:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80042a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80042e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800431:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800434:	83 f9 09             	cmp    $0x9,%ecx
  800437:	77 55                	ja     80048e <.L23+0xf>
			for (precision = 0;; ++fmt)
  800439:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80043c:	eb e9                	jmp    800427 <.L29+0xb>

0080043e <.L26>:
			precision = va_arg(ap, int);
  80043e:	8b 45 14             	mov    0x14(%ebp),%eax
  800441:	8b 00                	mov    (%eax),%eax
  800443:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800446:	8b 45 14             	mov    0x14(%ebp),%eax
  800449:	8d 40 04             	lea    0x4(%eax),%eax
  80044c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80044f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800452:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800456:	79 90                	jns    8003e8 <vprintfmt+0x40>
				width = precision, precision = -1;
  800458:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80045b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045e:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800465:	eb 81                	jmp    8003e8 <vprintfmt+0x40>

00800467 <.L27>:
  800467:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80046a:	85 c0                	test   %eax,%eax
  80046c:	ba 00 00 00 00       	mov    $0x0,%edx
  800471:	0f 49 d0             	cmovns %eax,%edx
  800474:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800477:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047a:	e9 69 ff ff ff       	jmp    8003e8 <vprintfmt+0x40>

0080047f <.L23>:
  80047f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800482:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800489:	e9 5a ff ff ff       	jmp    8003e8 <vprintfmt+0x40>
  80048e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800491:	eb bf                	jmp    800452 <.L26+0x14>

00800493 <.L33>:
			lflag++;
  800493:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800497:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80049a:	e9 49 ff ff ff       	jmp    8003e8 <vprintfmt+0x40>

0080049f <.L30>:
			putch(va_arg(ap, int), putdat);
  80049f:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a2:	8d 78 04             	lea    0x4(%eax),%edi
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	56                   	push   %esi
  8004a9:	ff 30                	pushl  (%eax)
  8004ab:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004ae:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004b1:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004b4:	e9 ce 02 00 00       	jmp    800787 <.L35+0x45>

008004b9 <.L32>:
			err = va_arg(ap, int);
  8004b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bc:	8d 78 04             	lea    0x4(%eax),%edi
  8004bf:	8b 00                	mov    (%eax),%eax
  8004c1:	99                   	cltd   
  8004c2:	31 d0                	xor    %edx,%eax
  8004c4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c6:	83 f8 08             	cmp    $0x8,%eax
  8004c9:	7f 27                	jg     8004f2 <.L32+0x39>
  8004cb:	8b 94 83 20 00 00 00 	mov    0x20(%ebx,%eax,4),%edx
  8004d2:	85 d2                	test   %edx,%edx
  8004d4:	74 1c                	je     8004f2 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004d6:	52                   	push   %edx
  8004d7:	8d 83 79 f2 ff ff    	lea    -0xd87(%ebx),%eax
  8004dd:	50                   	push   %eax
  8004de:	56                   	push   %esi
  8004df:	ff 75 08             	pushl  0x8(%ebp)
  8004e2:	e8 a4 fe ff ff       	call   80038b <printfmt>
  8004e7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004ea:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004ed:	e9 95 02 00 00       	jmp    800787 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004f2:	50                   	push   %eax
  8004f3:	8d 83 70 f2 ff ff    	lea    -0xd90(%ebx),%eax
  8004f9:	50                   	push   %eax
  8004fa:	56                   	push   %esi
  8004fb:	ff 75 08             	pushl  0x8(%ebp)
  8004fe:	e8 88 fe ff ff       	call   80038b <printfmt>
  800503:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800506:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800509:	e9 79 02 00 00       	jmp    800787 <.L35+0x45>

0080050e <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  80050e:	8b 45 14             	mov    0x14(%ebp),%eax
  800511:	83 c0 04             	add    $0x4,%eax
  800514:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80051c:	85 ff                	test   %edi,%edi
  80051e:	8d 83 69 f2 ff ff    	lea    -0xd97(%ebx),%eax
  800524:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800527:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052b:	0f 8e b5 00 00 00    	jle    8005e6 <.L36+0xd8>
  800531:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800535:	75 08                	jne    80053f <.L36+0x31>
  800537:	89 75 0c             	mov    %esi,0xc(%ebp)
  80053a:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80053d:	eb 6d                	jmp    8005ac <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	ff 75 cc             	pushl  -0x34(%ebp)
  800545:	57                   	push   %edi
  800546:	e8 85 03 00 00       	call   8008d0 <strnlen>
  80054b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80054e:	29 c2                	sub    %eax,%edx
  800550:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800553:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800556:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80055a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800560:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800562:	eb 10                	jmp    800574 <.L36+0x66>
					putch(padc, putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	56                   	push   %esi
  800568:	ff 75 e0             	pushl  -0x20(%ebp)
  80056b:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80056e:	83 ef 01             	sub    $0x1,%edi
  800571:	83 c4 10             	add    $0x10,%esp
  800574:	85 ff                	test   %edi,%edi
  800576:	7f ec                	jg     800564 <.L36+0x56>
  800578:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80057b:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80057e:	85 d2                	test   %edx,%edx
  800580:	b8 00 00 00 00       	mov    $0x0,%eax
  800585:	0f 49 c2             	cmovns %edx,%eax
  800588:	29 c2                	sub    %eax,%edx
  80058a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80058d:	89 75 0c             	mov    %esi,0xc(%ebp)
  800590:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800593:	eb 17                	jmp    8005ac <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  800595:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800599:	75 30                	jne    8005cb <.L36+0xbd>
					putch(ch, putdat);
  80059b:	83 ec 08             	sub    $0x8,%esp
  80059e:	ff 75 0c             	pushl  0xc(%ebp)
  8005a1:	50                   	push   %eax
  8005a2:	ff 55 08             	call   *0x8(%ebp)
  8005a5:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a8:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005ac:	83 c7 01             	add    $0x1,%edi
  8005af:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005b3:	0f be c2             	movsbl %dl,%eax
  8005b6:	85 c0                	test   %eax,%eax
  8005b8:	74 52                	je     80060c <.L36+0xfe>
  8005ba:	85 f6                	test   %esi,%esi
  8005bc:	78 d7                	js     800595 <.L36+0x87>
  8005be:	83 ee 01             	sub    $0x1,%esi
  8005c1:	79 d2                	jns    800595 <.L36+0x87>
  8005c3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005c6:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005c9:	eb 32                	jmp    8005fd <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005cb:	0f be d2             	movsbl %dl,%edx
  8005ce:	83 ea 20             	sub    $0x20,%edx
  8005d1:	83 fa 5e             	cmp    $0x5e,%edx
  8005d4:	76 c5                	jbe    80059b <.L36+0x8d>
					putch('?', putdat);
  8005d6:	83 ec 08             	sub    $0x8,%esp
  8005d9:	ff 75 0c             	pushl  0xc(%ebp)
  8005dc:	6a 3f                	push   $0x3f
  8005de:	ff 55 08             	call   *0x8(%ebp)
  8005e1:	83 c4 10             	add    $0x10,%esp
  8005e4:	eb c2                	jmp    8005a8 <.L36+0x9a>
  8005e6:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005e9:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005ec:	eb be                	jmp    8005ac <.L36+0x9e>
				putch(' ', putdat);
  8005ee:	83 ec 08             	sub    $0x8,%esp
  8005f1:	56                   	push   %esi
  8005f2:	6a 20                	push   $0x20
  8005f4:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8005f7:	83 ef 01             	sub    $0x1,%edi
  8005fa:	83 c4 10             	add    $0x10,%esp
  8005fd:	85 ff                	test   %edi,%edi
  8005ff:	7f ed                	jg     8005ee <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800601:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800604:	89 45 14             	mov    %eax,0x14(%ebp)
  800607:	e9 7b 01 00 00       	jmp    800787 <.L35+0x45>
  80060c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80060f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800612:	eb e9                	jmp    8005fd <.L36+0xef>

00800614 <.L31>:
  800614:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800617:	83 f9 01             	cmp    $0x1,%ecx
  80061a:	7e 40                	jle    80065c <.L31+0x48>
		return va_arg(*ap, long long);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8b 50 04             	mov    0x4(%eax),%edx
  800622:	8b 00                	mov    (%eax),%eax
  800624:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800627:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8d 40 08             	lea    0x8(%eax),%eax
  800630:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
  800633:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800637:	79 55                	jns    80068e <.L31+0x7a>
				putch('-', putdat);
  800639:	83 ec 08             	sub    $0x8,%esp
  80063c:	56                   	push   %esi
  80063d:	6a 2d                	push   $0x2d
  80063f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  800642:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800645:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800648:	f7 da                	neg    %edx
  80064a:	83 d1 00             	adc    $0x0,%ecx
  80064d:	f7 d9                	neg    %ecx
  80064f:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
  800652:	b8 0a 00 00 00       	mov    $0xa,%eax
  800657:	e9 10 01 00 00       	jmp    80076c <.L35+0x2a>
	else if (lflag)
  80065c:	85 c9                	test   %ecx,%ecx
  80065e:	75 17                	jne    800677 <.L31+0x63>
		return va_arg(*ap, int);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8b 00                	mov    (%eax),%eax
  800665:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800668:	99                   	cltd   
  800669:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8d 40 04             	lea    0x4(%eax),%eax
  800672:	89 45 14             	mov    %eax,0x14(%ebp)
  800675:	eb bc                	jmp    800633 <.L31+0x1f>
		return va_arg(*ap, long);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8b 00                	mov    (%eax),%eax
  80067c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067f:	99                   	cltd   
  800680:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8d 40 04             	lea    0x4(%eax),%eax
  800689:	89 45 14             	mov    %eax,0x14(%ebp)
  80068c:	eb a5                	jmp    800633 <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  80068e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800691:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
  800694:	b8 0a 00 00 00       	mov    $0xa,%eax
  800699:	e9 ce 00 00 00       	jmp    80076c <.L35+0x2a>

0080069e <.L37>:
  80069e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006a1:	83 f9 01             	cmp    $0x1,%ecx
  8006a4:	7e 18                	jle    8006be <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8b 10                	mov    (%eax),%edx
  8006ab:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ae:	8d 40 08             	lea    0x8(%eax),%eax
  8006b1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006b4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b9:	e9 ae 00 00 00       	jmp    80076c <.L35+0x2a>
	else if (lflag)
  8006be:	85 c9                	test   %ecx,%ecx
  8006c0:	75 1a                	jne    8006dc <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8b 10                	mov    (%eax),%edx
  8006c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cc:	8d 40 04             	lea    0x4(%eax),%eax
  8006cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d7:	e9 90 00 00 00       	jmp    80076c <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8b 10                	mov    (%eax),%edx
  8006e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e6:	8d 40 04             	lea    0x4(%eax),%eax
  8006e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ec:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f1:	eb 79                	jmp    80076c <.L35+0x2a>

008006f3 <.L34>:
  8006f3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006f6:	83 f9 01             	cmp    $0x1,%ecx
  8006f9:	7e 15                	jle    800710 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  8006fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fe:	8b 10                	mov    (%eax),%edx
  800700:	8b 48 04             	mov    0x4(%eax),%ecx
  800703:	8d 40 08             	lea    0x8(%eax),%eax
  800706:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800709:	b8 08 00 00 00       	mov    $0x8,%eax
  80070e:	eb 5c                	jmp    80076c <.L35+0x2a>
	else if (lflag)
  800710:	85 c9                	test   %ecx,%ecx
  800712:	75 17                	jne    80072b <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8b 10                	mov    (%eax),%edx
  800719:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071e:	8d 40 04             	lea    0x4(%eax),%eax
  800721:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800724:	b8 08 00 00 00       	mov    $0x8,%eax
  800729:	eb 41                	jmp    80076c <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  80072b:	8b 45 14             	mov    0x14(%ebp),%eax
  80072e:	8b 10                	mov    (%eax),%edx
  800730:	b9 00 00 00 00       	mov    $0x0,%ecx
  800735:	8d 40 04             	lea    0x4(%eax),%eax
  800738:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80073b:	b8 08 00 00 00       	mov    $0x8,%eax
  800740:	eb 2a                	jmp    80076c <.L35+0x2a>

00800742 <.L35>:
			putch('0', putdat);
  800742:	83 ec 08             	sub    $0x8,%esp
  800745:	56                   	push   %esi
  800746:	6a 30                	push   $0x30
  800748:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80074b:	83 c4 08             	add    $0x8,%esp
  80074e:	56                   	push   %esi
  80074f:	6a 78                	push   $0x78
  800751:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8b 10                	mov    (%eax),%edx
  800759:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80075e:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800761:	8d 40 04             	lea    0x4(%eax),%eax
  800764:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800767:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  80076c:	83 ec 0c             	sub    $0xc,%esp
  80076f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800773:	57                   	push   %edi
  800774:	ff 75 e0             	pushl  -0x20(%ebp)
  800777:	50                   	push   %eax
  800778:	51                   	push   %ecx
  800779:	52                   	push   %edx
  80077a:	89 f2                	mov    %esi,%edx
  80077c:	8b 45 08             	mov    0x8(%ebp),%eax
  80077f:	e8 20 fb ff ff       	call   8002a4 <printnum>
			break;
  800784:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800787:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  80078a:	83 c7 01             	add    $0x1,%edi
  80078d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800791:	83 f8 25             	cmp    $0x25,%eax
  800794:	0f 84 2d fc ff ff    	je     8003c7 <vprintfmt+0x1f>
			if (ch == '\0')
  80079a:	85 c0                	test   %eax,%eax
  80079c:	0f 84 91 00 00 00    	je     800833 <.L22+0x21>
			putch(ch, putdat);
  8007a2:	83 ec 08             	sub    $0x8,%esp
  8007a5:	56                   	push   %esi
  8007a6:	50                   	push   %eax
  8007a7:	ff 55 08             	call   *0x8(%ebp)
  8007aa:	83 c4 10             	add    $0x10,%esp
  8007ad:	eb db                	jmp    80078a <.L35+0x48>

008007af <.L38>:
  8007af:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8007b2:	83 f9 01             	cmp    $0x1,%ecx
  8007b5:	7e 15                	jle    8007cc <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8007b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ba:	8b 10                	mov    (%eax),%edx
  8007bc:	8b 48 04             	mov    0x4(%eax),%ecx
  8007bf:	8d 40 08             	lea    0x8(%eax),%eax
  8007c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c5:	b8 10 00 00 00       	mov    $0x10,%eax
  8007ca:	eb a0                	jmp    80076c <.L35+0x2a>
	else if (lflag)
  8007cc:	85 c9                	test   %ecx,%ecx
  8007ce:	75 17                	jne    8007e7 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d3:	8b 10                	mov    (%eax),%edx
  8007d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007da:	8d 40 04             	lea    0x4(%eax),%eax
  8007dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007e0:	b8 10 00 00 00       	mov    $0x10,%eax
  8007e5:	eb 85                	jmp    80076c <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ea:	8b 10                	mov    (%eax),%edx
  8007ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f1:	8d 40 04             	lea    0x4(%eax),%eax
  8007f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f7:	b8 10 00 00 00       	mov    $0x10,%eax
  8007fc:	e9 6b ff ff ff       	jmp    80076c <.L35+0x2a>

00800801 <.L25>:
			putch(ch, putdat);
  800801:	83 ec 08             	sub    $0x8,%esp
  800804:	56                   	push   %esi
  800805:	6a 25                	push   $0x25
  800807:	ff 55 08             	call   *0x8(%ebp)
			break;
  80080a:	83 c4 10             	add    $0x10,%esp
  80080d:	e9 75 ff ff ff       	jmp    800787 <.L35+0x45>

00800812 <.L22>:
			putch('%', putdat);
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	56                   	push   %esi
  800816:	6a 25                	push   $0x25
  800818:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80081b:	83 c4 10             	add    $0x10,%esp
  80081e:	89 f8                	mov    %edi,%eax
  800820:	eb 03                	jmp    800825 <.L22+0x13>
  800822:	83 e8 01             	sub    $0x1,%eax
  800825:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800829:	75 f7                	jne    800822 <.L22+0x10>
  80082b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80082e:	e9 54 ff ff ff       	jmp    800787 <.L35+0x45>
}
  800833:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800836:	5b                   	pop    %ebx
  800837:	5e                   	pop    %esi
  800838:	5f                   	pop    %edi
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	83 ec 14             	sub    $0x14,%esp
  800842:	e8 bd f8 ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800847:	81 c3 b9 17 00 00    	add    $0x17b9,%ebx
  80084d:	8b 45 08             	mov    0x8(%ebp),%eax
  800850:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  800853:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800856:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80085a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80085d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800864:	85 c0                	test   %eax,%eax
  800866:	74 2b                	je     800893 <vsnprintf+0x58>
  800868:	85 d2                	test   %edx,%edx
  80086a:	7e 27                	jle    800893 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  80086c:	ff 75 14             	pushl  0x14(%ebp)
  80086f:	ff 75 10             	pushl  0x10(%ebp)
  800872:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800875:	50                   	push   %eax
  800876:	8d 83 6e e3 ff ff    	lea    -0x1c92(%ebx),%eax
  80087c:	50                   	push   %eax
  80087d:	e8 26 fb ff ff       	call   8003a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800882:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800885:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800888:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80088b:	83 c4 10             	add    $0x10,%esp
}
  80088e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800891:	c9                   	leave  
  800892:	c3                   	ret    
		return -E_INVAL;
  800893:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800898:	eb f4                	jmp    80088e <vsnprintf+0x53>

0080089a <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a3:	50                   	push   %eax
  8008a4:	ff 75 10             	pushl  0x10(%ebp)
  8008a7:	ff 75 0c             	pushl  0xc(%ebp)
  8008aa:	ff 75 08             	pushl  0x8(%ebp)
  8008ad:	e8 89 ff ff ff       	call   80083b <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b2:	c9                   	leave  
  8008b3:	c3                   	ret    

008008b4 <__x86.get_pc_thunk.cx>:
  8008b4:	8b 0c 24             	mov    (%esp),%ecx
  8008b7:	c3                   	ret    

008008b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008be:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c3:	eb 03                	jmp    8008c8 <strlen+0x10>
		n++;
  8008c5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008c8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008cc:	75 f7                	jne    8008c5 <strlen+0xd>
	return n;
}
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008de:	eb 03                	jmp    8008e3 <strnlen+0x13>
		n++;
  8008e0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e3:	39 d0                	cmp    %edx,%eax
  8008e5:	74 06                	je     8008ed <strnlen+0x1d>
  8008e7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008eb:	75 f3                	jne    8008e0 <strnlen+0x10>
	return n;
}
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	53                   	push   %ebx
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f9:	89 c2                	mov    %eax,%edx
  8008fb:	83 c1 01             	add    $0x1,%ecx
  8008fe:	83 c2 01             	add    $0x1,%edx
  800901:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800905:	88 5a ff             	mov    %bl,-0x1(%edx)
  800908:	84 db                	test   %bl,%bl
  80090a:	75 ef                	jne    8008fb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80090c:	5b                   	pop    %ebx
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	53                   	push   %ebx
  800913:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800916:	53                   	push   %ebx
  800917:	e8 9c ff ff ff       	call   8008b8 <strlen>
  80091c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80091f:	ff 75 0c             	pushl  0xc(%ebp)
  800922:	01 d8                	add    %ebx,%eax
  800924:	50                   	push   %eax
  800925:	e8 c5 ff ff ff       	call   8008ef <strcpy>
	return dst;
}
  80092a:	89 d8                	mov    %ebx,%eax
  80092c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80092f:	c9                   	leave  
  800930:	c3                   	ret    

00800931 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	56                   	push   %esi
  800935:	53                   	push   %ebx
  800936:	8b 75 08             	mov    0x8(%ebp),%esi
  800939:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093c:	89 f3                	mov    %esi,%ebx
  80093e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800941:	89 f2                	mov    %esi,%edx
  800943:	eb 0f                	jmp    800954 <strncpy+0x23>
		*dst++ = *src;
  800945:	83 c2 01             	add    $0x1,%edx
  800948:	0f b6 01             	movzbl (%ecx),%eax
  80094b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80094e:	80 39 01             	cmpb   $0x1,(%ecx)
  800951:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800954:	39 da                	cmp    %ebx,%edx
  800956:	75 ed                	jne    800945 <strncpy+0x14>
	}
	return ret;
}
  800958:	89 f0                	mov    %esi,%eax
  80095a:	5b                   	pop    %ebx
  80095b:	5e                   	pop    %esi
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	56                   	push   %esi
  800962:	53                   	push   %ebx
  800963:	8b 75 08             	mov    0x8(%ebp),%esi
  800966:	8b 55 0c             	mov    0xc(%ebp),%edx
  800969:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80096c:	89 f0                	mov    %esi,%eax
  80096e:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800972:	85 c9                	test   %ecx,%ecx
  800974:	75 0b                	jne    800981 <strlcpy+0x23>
  800976:	eb 17                	jmp    80098f <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800978:	83 c2 01             	add    $0x1,%edx
  80097b:	83 c0 01             	add    $0x1,%eax
  80097e:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800981:	39 d8                	cmp    %ebx,%eax
  800983:	74 07                	je     80098c <strlcpy+0x2e>
  800985:	0f b6 0a             	movzbl (%edx),%ecx
  800988:	84 c9                	test   %cl,%cl
  80098a:	75 ec                	jne    800978 <strlcpy+0x1a>
		*dst = '\0';
  80098c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80098f:	29 f0                	sub    %esi,%eax
}
  800991:	5b                   	pop    %ebx
  800992:	5e                   	pop    %esi
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80099e:	eb 06                	jmp    8009a6 <strcmp+0x11>
		p++, q++;
  8009a0:	83 c1 01             	add    $0x1,%ecx
  8009a3:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009a6:	0f b6 01             	movzbl (%ecx),%eax
  8009a9:	84 c0                	test   %al,%al
  8009ab:	74 04                	je     8009b1 <strcmp+0x1c>
  8009ad:	3a 02                	cmp    (%edx),%al
  8009af:	74 ef                	je     8009a0 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b1:	0f b6 c0             	movzbl %al,%eax
  8009b4:	0f b6 12             	movzbl (%edx),%edx
  8009b7:	29 d0                	sub    %edx,%eax
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	53                   	push   %ebx
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c5:	89 c3                	mov    %eax,%ebx
  8009c7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009ca:	eb 06                	jmp    8009d2 <strncmp+0x17>
		n--, p++, q++;
  8009cc:	83 c0 01             	add    $0x1,%eax
  8009cf:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009d2:	39 d8                	cmp    %ebx,%eax
  8009d4:	74 16                	je     8009ec <strncmp+0x31>
  8009d6:	0f b6 08             	movzbl (%eax),%ecx
  8009d9:	84 c9                	test   %cl,%cl
  8009db:	74 04                	je     8009e1 <strncmp+0x26>
  8009dd:	3a 0a                	cmp    (%edx),%cl
  8009df:	74 eb                	je     8009cc <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e1:	0f b6 00             	movzbl (%eax),%eax
  8009e4:	0f b6 12             	movzbl (%edx),%edx
  8009e7:	29 d0                	sub    %edx,%eax
}
  8009e9:	5b                   	pop    %ebx
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    
		return 0;
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f1:	eb f6                	jmp    8009e9 <strncmp+0x2e>

008009f3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009fd:	0f b6 10             	movzbl (%eax),%edx
  800a00:	84 d2                	test   %dl,%dl
  800a02:	74 09                	je     800a0d <strchr+0x1a>
		if (*s == c)
  800a04:	38 ca                	cmp    %cl,%dl
  800a06:	74 0a                	je     800a12 <strchr+0x1f>
	for (; *s; s++)
  800a08:	83 c0 01             	add    $0x1,%eax
  800a0b:	eb f0                	jmp    8009fd <strchr+0xa>
			return (char *) s;
	return 0;
  800a0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a1e:	eb 03                	jmp    800a23 <strfind+0xf>
  800a20:	83 c0 01             	add    $0x1,%eax
  800a23:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a26:	38 ca                	cmp    %cl,%dl
  800a28:	74 04                	je     800a2e <strfind+0x1a>
  800a2a:	84 d2                	test   %dl,%dl
  800a2c:	75 f2                	jne    800a20 <strfind+0xc>
			break;
	return (char *) s;
}
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	57                   	push   %edi
  800a34:	56                   	push   %esi
  800a35:	53                   	push   %ebx
  800a36:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a39:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a3c:	85 c9                	test   %ecx,%ecx
  800a3e:	74 13                	je     800a53 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a40:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a46:	75 05                	jne    800a4d <memset+0x1d>
  800a48:	f6 c1 03             	test   $0x3,%cl
  800a4b:	74 0d                	je     800a5a <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a50:	fc                   	cld    
  800a51:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a53:	89 f8                	mov    %edi,%eax
  800a55:	5b                   	pop    %ebx
  800a56:	5e                   	pop    %esi
  800a57:	5f                   	pop    %edi
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    
		c &= 0xFF;
  800a5a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5e:	89 d3                	mov    %edx,%ebx
  800a60:	c1 e3 08             	shl    $0x8,%ebx
  800a63:	89 d0                	mov    %edx,%eax
  800a65:	c1 e0 18             	shl    $0x18,%eax
  800a68:	89 d6                	mov    %edx,%esi
  800a6a:	c1 e6 10             	shl    $0x10,%esi
  800a6d:	09 f0                	or     %esi,%eax
  800a6f:	09 c2                	or     %eax,%edx
  800a71:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a73:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a76:	89 d0                	mov    %edx,%eax
  800a78:	fc                   	cld    
  800a79:	f3 ab                	rep stos %eax,%es:(%edi)
  800a7b:	eb d6                	jmp    800a53 <memset+0x23>

00800a7d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	57                   	push   %edi
  800a81:	56                   	push   %esi
  800a82:	8b 45 08             	mov    0x8(%ebp),%eax
  800a85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a88:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a8b:	39 c6                	cmp    %eax,%esi
  800a8d:	73 35                	jae    800ac4 <memmove+0x47>
  800a8f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a92:	39 c2                	cmp    %eax,%edx
  800a94:	76 2e                	jbe    800ac4 <memmove+0x47>
		s += n;
		d += n;
  800a96:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a99:	89 d6                	mov    %edx,%esi
  800a9b:	09 fe                	or     %edi,%esi
  800a9d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aa3:	74 0c                	je     800ab1 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aa5:	83 ef 01             	sub    $0x1,%edi
  800aa8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aab:	fd                   	std    
  800aac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aae:	fc                   	cld    
  800aaf:	eb 21                	jmp    800ad2 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab1:	f6 c1 03             	test   $0x3,%cl
  800ab4:	75 ef                	jne    800aa5 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ab6:	83 ef 04             	sub    $0x4,%edi
  800ab9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800abc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800abf:	fd                   	std    
  800ac0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac2:	eb ea                	jmp    800aae <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac4:	89 f2                	mov    %esi,%edx
  800ac6:	09 c2                	or     %eax,%edx
  800ac8:	f6 c2 03             	test   $0x3,%dl
  800acb:	74 09                	je     800ad6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800acd:	89 c7                	mov    %eax,%edi
  800acf:	fc                   	cld    
  800ad0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad6:	f6 c1 03             	test   $0x3,%cl
  800ad9:	75 f2                	jne    800acd <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800adb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ade:	89 c7                	mov    %eax,%edi
  800ae0:	fc                   	cld    
  800ae1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae3:	eb ed                	jmp    800ad2 <memmove+0x55>

00800ae5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ae8:	ff 75 10             	pushl  0x10(%ebp)
  800aeb:	ff 75 0c             	pushl  0xc(%ebp)
  800aee:	ff 75 08             	pushl  0x8(%ebp)
  800af1:	e8 87 ff ff ff       	call   800a7d <memmove>
}
  800af6:	c9                   	leave  
  800af7:	c3                   	ret    

00800af8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	56                   	push   %esi
  800afc:	53                   	push   %ebx
  800afd:	8b 45 08             	mov    0x8(%ebp),%eax
  800b00:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b03:	89 c6                	mov    %eax,%esi
  800b05:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b08:	39 f0                	cmp    %esi,%eax
  800b0a:	74 1c                	je     800b28 <memcmp+0x30>
		if (*s1 != *s2)
  800b0c:	0f b6 08             	movzbl (%eax),%ecx
  800b0f:	0f b6 1a             	movzbl (%edx),%ebx
  800b12:	38 d9                	cmp    %bl,%cl
  800b14:	75 08                	jne    800b1e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b16:	83 c0 01             	add    $0x1,%eax
  800b19:	83 c2 01             	add    $0x1,%edx
  800b1c:	eb ea                	jmp    800b08 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b1e:	0f b6 c1             	movzbl %cl,%eax
  800b21:	0f b6 db             	movzbl %bl,%ebx
  800b24:	29 d8                	sub    %ebx,%eax
  800b26:	eb 05                	jmp    800b2d <memcmp+0x35>
	}

	return 0;
  800b28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	8b 45 08             	mov    0x8(%ebp),%eax
  800b37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b3a:	89 c2                	mov    %eax,%edx
  800b3c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b3f:	39 d0                	cmp    %edx,%eax
  800b41:	73 09                	jae    800b4c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b43:	38 08                	cmp    %cl,(%eax)
  800b45:	74 05                	je     800b4c <memfind+0x1b>
	for (; s < ends; s++)
  800b47:	83 c0 01             	add    $0x1,%eax
  800b4a:	eb f3                	jmp    800b3f <memfind+0xe>
			break;
	return (void *) s;
}
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5a:	eb 03                	jmp    800b5f <strtol+0x11>
		s++;
  800b5c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b5f:	0f b6 01             	movzbl (%ecx),%eax
  800b62:	3c 20                	cmp    $0x20,%al
  800b64:	74 f6                	je     800b5c <strtol+0xe>
  800b66:	3c 09                	cmp    $0x9,%al
  800b68:	74 f2                	je     800b5c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b6a:	3c 2b                	cmp    $0x2b,%al
  800b6c:	74 2e                	je     800b9c <strtol+0x4e>
	int neg = 0;
  800b6e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b73:	3c 2d                	cmp    $0x2d,%al
  800b75:	74 2f                	je     800ba6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b77:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b7d:	75 05                	jne    800b84 <strtol+0x36>
  800b7f:	80 39 30             	cmpb   $0x30,(%ecx)
  800b82:	74 2c                	je     800bb0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b84:	85 db                	test   %ebx,%ebx
  800b86:	75 0a                	jne    800b92 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b88:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b8d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b90:	74 28                	je     800bba <strtol+0x6c>
		base = 10;
  800b92:	b8 00 00 00 00       	mov    $0x0,%eax
  800b97:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b9a:	eb 50                	jmp    800bec <strtol+0x9e>
		s++;
  800b9c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b9f:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba4:	eb d1                	jmp    800b77 <strtol+0x29>
		s++, neg = 1;
  800ba6:	83 c1 01             	add    $0x1,%ecx
  800ba9:	bf 01 00 00 00       	mov    $0x1,%edi
  800bae:	eb c7                	jmp    800b77 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bb4:	74 0e                	je     800bc4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bb6:	85 db                	test   %ebx,%ebx
  800bb8:	75 d8                	jne    800b92 <strtol+0x44>
		s++, base = 8;
  800bba:	83 c1 01             	add    $0x1,%ecx
  800bbd:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bc2:	eb ce                	jmp    800b92 <strtol+0x44>
		s += 2, base = 16;
  800bc4:	83 c1 02             	add    $0x2,%ecx
  800bc7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bcc:	eb c4                	jmp    800b92 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bce:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bd1:	89 f3                	mov    %esi,%ebx
  800bd3:	80 fb 19             	cmp    $0x19,%bl
  800bd6:	77 29                	ja     800c01 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bd8:	0f be d2             	movsbl %dl,%edx
  800bdb:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bde:	3b 55 10             	cmp    0x10(%ebp),%edx
  800be1:	7d 30                	jge    800c13 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800be3:	83 c1 01             	add    $0x1,%ecx
  800be6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bea:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bec:	0f b6 11             	movzbl (%ecx),%edx
  800bef:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bf2:	89 f3                	mov    %esi,%ebx
  800bf4:	80 fb 09             	cmp    $0x9,%bl
  800bf7:	77 d5                	ja     800bce <strtol+0x80>
			dig = *s - '0';
  800bf9:	0f be d2             	movsbl %dl,%edx
  800bfc:	83 ea 30             	sub    $0x30,%edx
  800bff:	eb dd                	jmp    800bde <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c01:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c04:	89 f3                	mov    %esi,%ebx
  800c06:	80 fb 19             	cmp    $0x19,%bl
  800c09:	77 08                	ja     800c13 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c0b:	0f be d2             	movsbl %dl,%edx
  800c0e:	83 ea 37             	sub    $0x37,%edx
  800c11:	eb cb                	jmp    800bde <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c13:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c17:	74 05                	je     800c1e <strtol+0xd0>
		*endptr = (char *) s;
  800c19:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c1c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c1e:	89 c2                	mov    %eax,%edx
  800c20:	f7 da                	neg    %edx
  800c22:	85 ff                	test   %edi,%edi
  800c24:	0f 45 c2             	cmovne %edx,%eax
}
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c32:	b8 00 00 00 00       	mov    $0x0,%eax
  800c37:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3d:	89 c3                	mov    %eax,%ebx
  800c3f:	89 c7                	mov    %eax,%edi
  800c41:	89 c6                	mov    %eax,%esi
  800c43:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c50:	ba 00 00 00 00       	mov    $0x0,%edx
  800c55:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5a:	89 d1                	mov    %edx,%ecx
  800c5c:	89 d3                	mov    %edx,%ebx
  800c5e:	89 d7                	mov    %edx,%edi
  800c60:	89 d6                	mov    %edx,%esi
  800c62:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	83 ec 1c             	sub    $0x1c,%esp
  800c72:	e8 ac 02 00 00       	call   800f23 <__x86.get_pc_thunk.ax>
  800c77:	05 89 13 00 00       	add    $0x1389,%eax
  800c7c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800c7f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c84:	8b 55 08             	mov    0x8(%ebp),%edx
  800c87:	b8 03 00 00 00       	mov    $0x3,%eax
  800c8c:	89 cb                	mov    %ecx,%ebx
  800c8e:	89 cf                	mov    %ecx,%edi
  800c90:	89 ce                	mov    %ecx,%esi
  800c92:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7f 08                	jg     800ca0 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
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
  800ca4:	6a 03                	push   $0x3
  800ca6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800ca9:	8d 83 68 f4 ff ff    	lea    -0xb98(%ebx),%eax
  800caf:	50                   	push   %eax
  800cb0:	6a 23                	push   $0x23
  800cb2:	8d 83 85 f4 ff ff    	lea    -0xb7b(%ebx),%eax
  800cb8:	50                   	push   %eax
  800cb9:	e8 c6 f4 ff ff       	call   800184 <_panic>

00800cbe <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc9:	b8 02 00 00 00       	mov    $0x2,%eax
  800cce:	89 d1                	mov    %edx,%ecx
  800cd0:	89 d3                	mov    %edx,%ebx
  800cd2:	89 d7                	mov    %edx,%edi
  800cd4:	89 d6                	mov    %edx,%esi
  800cd6:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5f                   	pop    %edi
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    

00800cdd <sys_yield>:

void
sys_yield(void)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	57                   	push   %edi
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ce3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ced:	89 d1                	mov    %edx,%ecx
  800cef:	89 d3                	mov    %edx,%ebx
  800cf1:	89 d7                	mov    %edx,%edi
  800cf3:	89 d6                	mov    %edx,%esi
  800cf5:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	57                   	push   %edi
  800d00:	56                   	push   %esi
  800d01:	53                   	push   %ebx
  800d02:	83 ec 1c             	sub    $0x1c,%esp
  800d05:	e8 19 02 00 00       	call   800f23 <__x86.get_pc_thunk.ax>
  800d0a:	05 f6 12 00 00       	add    $0x12f6,%eax
  800d0f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800d12:	be 00 00 00 00       	mov    $0x0,%esi
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	b8 04 00 00 00       	mov    $0x4,%eax
  800d22:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d25:	89 f7                	mov    %esi,%edi
  800d27:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	7f 08                	jg     800d35 <sys_page_alloc+0x39>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d35:	83 ec 0c             	sub    $0xc,%esp
  800d38:	50                   	push   %eax
  800d39:	6a 04                	push   $0x4
  800d3b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800d3e:	8d 83 68 f4 ff ff    	lea    -0xb98(%ebx),%eax
  800d44:	50                   	push   %eax
  800d45:	6a 23                	push   $0x23
  800d47:	8d 83 85 f4 ff ff    	lea    -0xb7b(%ebx),%eax
  800d4d:	50                   	push   %eax
  800d4e:	e8 31 f4 ff ff       	call   800184 <_panic>

00800d53 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	57                   	push   %edi
  800d57:	56                   	push   %esi
  800d58:	53                   	push   %ebx
  800d59:	83 ec 1c             	sub    $0x1c,%esp
  800d5c:	e8 c2 01 00 00       	call   800f23 <__x86.get_pc_thunk.ax>
  800d61:	05 9f 12 00 00       	add    $0x129f,%eax
  800d66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6f:	b8 05 00 00 00       	mov    $0x5,%eax
  800d74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d77:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7a:	8b 75 18             	mov    0x18(%ebp),%esi
  800d7d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	7f 08                	jg     800d8b <sys_page_map+0x38>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8b:	83 ec 0c             	sub    $0xc,%esp
  800d8e:	50                   	push   %eax
  800d8f:	6a 05                	push   $0x5
  800d91:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800d94:	8d 83 68 f4 ff ff    	lea    -0xb98(%ebx),%eax
  800d9a:	50                   	push   %eax
  800d9b:	6a 23                	push   $0x23
  800d9d:	8d 83 85 f4 ff ff    	lea    -0xb7b(%ebx),%eax
  800da3:	50                   	push   %eax
  800da4:	e8 db f3 ff ff       	call   800184 <_panic>

00800da9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	57                   	push   %edi
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
  800daf:	83 ec 1c             	sub    $0x1c,%esp
  800db2:	e8 6c 01 00 00       	call   800f23 <__x86.get_pc_thunk.ax>
  800db7:	05 49 12 00 00       	add    $0x1249,%eax
  800dbc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800dbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dca:	b8 06 00 00 00       	mov    $0x6,%eax
  800dcf:	89 df                	mov    %ebx,%edi
  800dd1:	89 de                	mov    %ebx,%esi
  800dd3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	7f 08                	jg     800de1 <sys_page_unmap+0x38>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de1:	83 ec 0c             	sub    $0xc,%esp
  800de4:	50                   	push   %eax
  800de5:	6a 06                	push   $0x6
  800de7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800dea:	8d 83 68 f4 ff ff    	lea    -0xb98(%ebx),%eax
  800df0:	50                   	push   %eax
  800df1:	6a 23                	push   $0x23
  800df3:	8d 83 85 f4 ff ff    	lea    -0xb7b(%ebx),%eax
  800df9:	50                   	push   %eax
  800dfa:	e8 85 f3 ff ff       	call   800184 <_panic>

00800dff <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	57                   	push   %edi
  800e03:	56                   	push   %esi
  800e04:	53                   	push   %ebx
  800e05:	83 ec 1c             	sub    $0x1c,%esp
  800e08:	e8 16 01 00 00       	call   800f23 <__x86.get_pc_thunk.ax>
  800e0d:	05 f3 11 00 00       	add    $0x11f3,%eax
  800e12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800e15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e20:	b8 08 00 00 00       	mov    $0x8,%eax
  800e25:	89 df                	mov    %ebx,%edi
  800e27:	89 de                	mov    %ebx,%esi
  800e29:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	7f 08                	jg     800e37 <sys_env_set_status+0x38>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e32:	5b                   	pop    %ebx
  800e33:	5e                   	pop    %esi
  800e34:	5f                   	pop    %edi
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e37:	83 ec 0c             	sub    $0xc,%esp
  800e3a:	50                   	push   %eax
  800e3b:	6a 08                	push   $0x8
  800e3d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800e40:	8d 83 68 f4 ff ff    	lea    -0xb98(%ebx),%eax
  800e46:	50                   	push   %eax
  800e47:	6a 23                	push   $0x23
  800e49:	8d 83 85 f4 ff ff    	lea    -0xb7b(%ebx),%eax
  800e4f:	50                   	push   %eax
  800e50:	e8 2f f3 ff ff       	call   800184 <_panic>

00800e55 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	57                   	push   %edi
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
  800e5b:	83 ec 1c             	sub    $0x1c,%esp
  800e5e:	e8 c0 00 00 00       	call   800f23 <__x86.get_pc_thunk.ax>
  800e63:	05 9d 11 00 00       	add    $0x119d,%eax
  800e68:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800e6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e70:	8b 55 08             	mov    0x8(%ebp),%edx
  800e73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e76:	b8 09 00 00 00       	mov    $0x9,%eax
  800e7b:	89 df                	mov    %ebx,%edi
  800e7d:	89 de                	mov    %ebx,%esi
  800e7f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e81:	85 c0                	test   %eax,%eax
  800e83:	7f 08                	jg     800e8d <sys_env_set_pgfault_upcall+0x38>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e88:	5b                   	pop    %ebx
  800e89:	5e                   	pop    %esi
  800e8a:	5f                   	pop    %edi
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8d:	83 ec 0c             	sub    $0xc,%esp
  800e90:	50                   	push   %eax
  800e91:	6a 09                	push   $0x9
  800e93:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800e96:	8d 83 68 f4 ff ff    	lea    -0xb98(%ebx),%eax
  800e9c:	50                   	push   %eax
  800e9d:	6a 23                	push   $0x23
  800e9f:	8d 83 85 f4 ff ff    	lea    -0xb7b(%ebx),%eax
  800ea5:	50                   	push   %eax
  800ea6:	e8 d9 f2 ff ff       	call   800184 <_panic>

00800eab <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	57                   	push   %edi
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ebc:	be 00 00 00 00       	mov    $0x0,%esi
  800ec1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec7:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ec9:	5b                   	pop    %ebx
  800eca:	5e                   	pop    %esi
  800ecb:	5f                   	pop    %edi
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    

00800ece <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	57                   	push   %edi
  800ed2:	56                   	push   %esi
  800ed3:	53                   	push   %ebx
  800ed4:	83 ec 1c             	sub    $0x1c,%esp
  800ed7:	e8 47 00 00 00       	call   800f23 <__x86.get_pc_thunk.ax>
  800edc:	05 24 11 00 00       	add    $0x1124,%eax
  800ee1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800ee4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee9:	8b 55 08             	mov    0x8(%ebp),%edx
  800eec:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ef1:	89 cb                	mov    %ecx,%ebx
  800ef3:	89 cf                	mov    %ecx,%edi
  800ef5:	89 ce                	mov    %ecx,%esi
  800ef7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ef9:	85 c0                	test   %eax,%eax
  800efb:	7f 08                	jg     800f05 <sys_ipc_recv+0x37>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800efd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f00:	5b                   	pop    %ebx
  800f01:	5e                   	pop    %esi
  800f02:	5f                   	pop    %edi
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f05:	83 ec 0c             	sub    $0xc,%esp
  800f08:	50                   	push   %eax
  800f09:	6a 0c                	push   $0xc
  800f0b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800f0e:	8d 83 68 f4 ff ff    	lea    -0xb98(%ebx),%eax
  800f14:	50                   	push   %eax
  800f15:	6a 23                	push   $0x23
  800f17:	8d 83 85 f4 ff ff    	lea    -0xb7b(%ebx),%eax
  800f1d:	50                   	push   %eax
  800f1e:	e8 61 f2 ff ff       	call   800184 <_panic>

00800f23 <__x86.get_pc_thunk.ax>:
  800f23:	8b 04 24             	mov    (%esp),%eax
  800f26:	c3                   	ret    
  800f27:	66 90                	xchg   %ax,%ax
  800f29:	66 90                	xchg   %ax,%ax
  800f2b:	66 90                	xchg   %ax,%ax
  800f2d:	66 90                	xchg   %ax,%ax
  800f2f:	90                   	nop

00800f30 <__udivdi3>:
  800f30:	55                   	push   %ebp
  800f31:	57                   	push   %edi
  800f32:	56                   	push   %esi
  800f33:	53                   	push   %ebx
  800f34:	83 ec 1c             	sub    $0x1c,%esp
  800f37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f3b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800f3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f43:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800f47:	85 d2                	test   %edx,%edx
  800f49:	75 35                	jne    800f80 <__udivdi3+0x50>
  800f4b:	39 f3                	cmp    %esi,%ebx
  800f4d:	0f 87 bd 00 00 00    	ja     801010 <__udivdi3+0xe0>
  800f53:	85 db                	test   %ebx,%ebx
  800f55:	89 d9                	mov    %ebx,%ecx
  800f57:	75 0b                	jne    800f64 <__udivdi3+0x34>
  800f59:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5e:	31 d2                	xor    %edx,%edx
  800f60:	f7 f3                	div    %ebx
  800f62:	89 c1                	mov    %eax,%ecx
  800f64:	31 d2                	xor    %edx,%edx
  800f66:	89 f0                	mov    %esi,%eax
  800f68:	f7 f1                	div    %ecx
  800f6a:	89 c6                	mov    %eax,%esi
  800f6c:	89 e8                	mov    %ebp,%eax
  800f6e:	89 f7                	mov    %esi,%edi
  800f70:	f7 f1                	div    %ecx
  800f72:	89 fa                	mov    %edi,%edx
  800f74:	83 c4 1c             	add    $0x1c,%esp
  800f77:	5b                   	pop    %ebx
  800f78:	5e                   	pop    %esi
  800f79:	5f                   	pop    %edi
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    
  800f7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f80:	39 f2                	cmp    %esi,%edx
  800f82:	77 7c                	ja     801000 <__udivdi3+0xd0>
  800f84:	0f bd fa             	bsr    %edx,%edi
  800f87:	83 f7 1f             	xor    $0x1f,%edi
  800f8a:	0f 84 98 00 00 00    	je     801028 <__udivdi3+0xf8>
  800f90:	89 f9                	mov    %edi,%ecx
  800f92:	b8 20 00 00 00       	mov    $0x20,%eax
  800f97:	29 f8                	sub    %edi,%eax
  800f99:	d3 e2                	shl    %cl,%edx
  800f9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f9f:	89 c1                	mov    %eax,%ecx
  800fa1:	89 da                	mov    %ebx,%edx
  800fa3:	d3 ea                	shr    %cl,%edx
  800fa5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fa9:	09 d1                	or     %edx,%ecx
  800fab:	89 f2                	mov    %esi,%edx
  800fad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fb1:	89 f9                	mov    %edi,%ecx
  800fb3:	d3 e3                	shl    %cl,%ebx
  800fb5:	89 c1                	mov    %eax,%ecx
  800fb7:	d3 ea                	shr    %cl,%edx
  800fb9:	89 f9                	mov    %edi,%ecx
  800fbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fbf:	d3 e6                	shl    %cl,%esi
  800fc1:	89 eb                	mov    %ebp,%ebx
  800fc3:	89 c1                	mov    %eax,%ecx
  800fc5:	d3 eb                	shr    %cl,%ebx
  800fc7:	09 de                	or     %ebx,%esi
  800fc9:	89 f0                	mov    %esi,%eax
  800fcb:	f7 74 24 08          	divl   0x8(%esp)
  800fcf:	89 d6                	mov    %edx,%esi
  800fd1:	89 c3                	mov    %eax,%ebx
  800fd3:	f7 64 24 0c          	mull   0xc(%esp)
  800fd7:	39 d6                	cmp    %edx,%esi
  800fd9:	72 0c                	jb     800fe7 <__udivdi3+0xb7>
  800fdb:	89 f9                	mov    %edi,%ecx
  800fdd:	d3 e5                	shl    %cl,%ebp
  800fdf:	39 c5                	cmp    %eax,%ebp
  800fe1:	73 5d                	jae    801040 <__udivdi3+0x110>
  800fe3:	39 d6                	cmp    %edx,%esi
  800fe5:	75 59                	jne    801040 <__udivdi3+0x110>
  800fe7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800fea:	31 ff                	xor    %edi,%edi
  800fec:	89 fa                	mov    %edi,%edx
  800fee:	83 c4 1c             	add    $0x1c,%esp
  800ff1:	5b                   	pop    %ebx
  800ff2:	5e                   	pop    %esi
  800ff3:	5f                   	pop    %edi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    
  800ff6:	8d 76 00             	lea    0x0(%esi),%esi
  800ff9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801000:	31 ff                	xor    %edi,%edi
  801002:	31 c0                	xor    %eax,%eax
  801004:	89 fa                	mov    %edi,%edx
  801006:	83 c4 1c             	add    $0x1c,%esp
  801009:	5b                   	pop    %ebx
  80100a:	5e                   	pop    %esi
  80100b:	5f                   	pop    %edi
  80100c:	5d                   	pop    %ebp
  80100d:	c3                   	ret    
  80100e:	66 90                	xchg   %ax,%ax
  801010:	31 ff                	xor    %edi,%edi
  801012:	89 e8                	mov    %ebp,%eax
  801014:	89 f2                	mov    %esi,%edx
  801016:	f7 f3                	div    %ebx
  801018:	89 fa                	mov    %edi,%edx
  80101a:	83 c4 1c             	add    $0x1c,%esp
  80101d:	5b                   	pop    %ebx
  80101e:	5e                   	pop    %esi
  80101f:	5f                   	pop    %edi
  801020:	5d                   	pop    %ebp
  801021:	c3                   	ret    
  801022:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801028:	39 f2                	cmp    %esi,%edx
  80102a:	72 06                	jb     801032 <__udivdi3+0x102>
  80102c:	31 c0                	xor    %eax,%eax
  80102e:	39 eb                	cmp    %ebp,%ebx
  801030:	77 d2                	ja     801004 <__udivdi3+0xd4>
  801032:	b8 01 00 00 00       	mov    $0x1,%eax
  801037:	eb cb                	jmp    801004 <__udivdi3+0xd4>
  801039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801040:	89 d8                	mov    %ebx,%eax
  801042:	31 ff                	xor    %edi,%edi
  801044:	eb be                	jmp    801004 <__udivdi3+0xd4>
  801046:	66 90                	xchg   %ax,%ax
  801048:	66 90                	xchg   %ax,%ax
  80104a:	66 90                	xchg   %ax,%ax
  80104c:	66 90                	xchg   %ax,%ax
  80104e:	66 90                	xchg   %ax,%ax

00801050 <__umoddi3>:
  801050:	55                   	push   %ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
  801054:	83 ec 1c             	sub    $0x1c,%esp
  801057:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80105b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80105f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801063:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801067:	85 ed                	test   %ebp,%ebp
  801069:	89 f0                	mov    %esi,%eax
  80106b:	89 da                	mov    %ebx,%edx
  80106d:	75 19                	jne    801088 <__umoddi3+0x38>
  80106f:	39 df                	cmp    %ebx,%edi
  801071:	0f 86 b1 00 00 00    	jbe    801128 <__umoddi3+0xd8>
  801077:	f7 f7                	div    %edi
  801079:	89 d0                	mov    %edx,%eax
  80107b:	31 d2                	xor    %edx,%edx
  80107d:	83 c4 1c             	add    $0x1c,%esp
  801080:	5b                   	pop    %ebx
  801081:	5e                   	pop    %esi
  801082:	5f                   	pop    %edi
  801083:	5d                   	pop    %ebp
  801084:	c3                   	ret    
  801085:	8d 76 00             	lea    0x0(%esi),%esi
  801088:	39 dd                	cmp    %ebx,%ebp
  80108a:	77 f1                	ja     80107d <__umoddi3+0x2d>
  80108c:	0f bd cd             	bsr    %ebp,%ecx
  80108f:	83 f1 1f             	xor    $0x1f,%ecx
  801092:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801096:	0f 84 b4 00 00 00    	je     801150 <__umoddi3+0x100>
  80109c:	b8 20 00 00 00       	mov    $0x20,%eax
  8010a1:	89 c2                	mov    %eax,%edx
  8010a3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010a7:	29 c2                	sub    %eax,%edx
  8010a9:	89 c1                	mov    %eax,%ecx
  8010ab:	89 f8                	mov    %edi,%eax
  8010ad:	d3 e5                	shl    %cl,%ebp
  8010af:	89 d1                	mov    %edx,%ecx
  8010b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8010b5:	d3 e8                	shr    %cl,%eax
  8010b7:	09 c5                	or     %eax,%ebp
  8010b9:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010bd:	89 c1                	mov    %eax,%ecx
  8010bf:	d3 e7                	shl    %cl,%edi
  8010c1:	89 d1                	mov    %edx,%ecx
  8010c3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8010c7:	89 df                	mov    %ebx,%edi
  8010c9:	d3 ef                	shr    %cl,%edi
  8010cb:	89 c1                	mov    %eax,%ecx
  8010cd:	89 f0                	mov    %esi,%eax
  8010cf:	d3 e3                	shl    %cl,%ebx
  8010d1:	89 d1                	mov    %edx,%ecx
  8010d3:	89 fa                	mov    %edi,%edx
  8010d5:	d3 e8                	shr    %cl,%eax
  8010d7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010dc:	09 d8                	or     %ebx,%eax
  8010de:	f7 f5                	div    %ebp
  8010e0:	d3 e6                	shl    %cl,%esi
  8010e2:	89 d1                	mov    %edx,%ecx
  8010e4:	f7 64 24 08          	mull   0x8(%esp)
  8010e8:	39 d1                	cmp    %edx,%ecx
  8010ea:	89 c3                	mov    %eax,%ebx
  8010ec:	89 d7                	mov    %edx,%edi
  8010ee:	72 06                	jb     8010f6 <__umoddi3+0xa6>
  8010f0:	75 0e                	jne    801100 <__umoddi3+0xb0>
  8010f2:	39 c6                	cmp    %eax,%esi
  8010f4:	73 0a                	jae    801100 <__umoddi3+0xb0>
  8010f6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8010fa:	19 ea                	sbb    %ebp,%edx
  8010fc:	89 d7                	mov    %edx,%edi
  8010fe:	89 c3                	mov    %eax,%ebx
  801100:	89 ca                	mov    %ecx,%edx
  801102:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801107:	29 de                	sub    %ebx,%esi
  801109:	19 fa                	sbb    %edi,%edx
  80110b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80110f:	89 d0                	mov    %edx,%eax
  801111:	d3 e0                	shl    %cl,%eax
  801113:	89 d9                	mov    %ebx,%ecx
  801115:	d3 ee                	shr    %cl,%esi
  801117:	d3 ea                	shr    %cl,%edx
  801119:	09 f0                	or     %esi,%eax
  80111b:	83 c4 1c             	add    $0x1c,%esp
  80111e:	5b                   	pop    %ebx
  80111f:	5e                   	pop    %esi
  801120:	5f                   	pop    %edi
  801121:	5d                   	pop    %ebp
  801122:	c3                   	ret    
  801123:	90                   	nop
  801124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801128:	85 ff                	test   %edi,%edi
  80112a:	89 f9                	mov    %edi,%ecx
  80112c:	75 0b                	jne    801139 <__umoddi3+0xe9>
  80112e:	b8 01 00 00 00       	mov    $0x1,%eax
  801133:	31 d2                	xor    %edx,%edx
  801135:	f7 f7                	div    %edi
  801137:	89 c1                	mov    %eax,%ecx
  801139:	89 d8                	mov    %ebx,%eax
  80113b:	31 d2                	xor    %edx,%edx
  80113d:	f7 f1                	div    %ecx
  80113f:	89 f0                	mov    %esi,%eax
  801141:	f7 f1                	div    %ecx
  801143:	e9 31 ff ff ff       	jmp    801079 <__umoddi3+0x29>
  801148:	90                   	nop
  801149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801150:	39 dd                	cmp    %ebx,%ebp
  801152:	72 08                	jb     80115c <__umoddi3+0x10c>
  801154:	39 f7                	cmp    %esi,%edi
  801156:	0f 87 21 ff ff ff    	ja     80107d <__umoddi3+0x2d>
  80115c:	89 da                	mov    %ebx,%edx
  80115e:	89 f0                	mov    %esi,%eax
  801160:	29 f8                	sub    %edi,%eax
  801162:	19 ea                	sbb    %ebp,%edx
  801164:	e9 14 ff ff ff       	jmp    80107d <__umoddi3+0x2d>
