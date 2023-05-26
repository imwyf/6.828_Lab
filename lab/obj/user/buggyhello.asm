
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 29 00 00 00       	call   80005a <libmain>
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
  80003a:	e8 17 00 00 00       	call   800056 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	sys_cputs((char*)1, 1);
  800045:	6a 01                	push   $0x1
  800047:	6a 01                	push   $0x1
  800049:	e8 74 00 00 00       	call   8000c2 <sys_cputs>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800054:	c9                   	leave  
  800055:	c3                   	ret    

00800056 <__x86.get_pc_thunk.bx>:
  800056:	8b 1c 24             	mov    (%esp),%ebx
  800059:	c3                   	ret    

0080005a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005a:	55                   	push   %ebp
  80005b:	89 e5                	mov    %esp,%ebp
  80005d:	53                   	push   %ebx
  80005e:	83 ec 04             	sub    $0x4,%esp
  800061:	e8 f0 ff ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800066:	81 c3 9a 1f 00 00    	add    $0x1f9a,%ebx
  80006c:	8b 45 08             	mov    0x8(%ebp),%eax
  80006f:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800072:	c7 c1 2c 20 80 00    	mov    $0x80202c,%ecx
  800078:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 c0                	test   %eax,%eax
  800080:	7e 08                	jle    80008a <libmain+0x30>
		binaryname = argv[0];
  800082:	8b 0a                	mov    (%edx),%ecx
  800084:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80008a:	83 ec 08             	sub    $0x8,%esp
  80008d:	52                   	push   %edx
  80008e:	50                   	push   %eax
  80008f:	e8 9f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800094:	e8 08 00 00 00       	call   8000a1 <exit>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80009f:	c9                   	leave  
  8000a0:	c3                   	ret    

008000a1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	53                   	push   %ebx
  8000a5:	83 ec 10             	sub    $0x10,%esp
  8000a8:	e8 a9 ff ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8000ad:	81 c3 53 1f 00 00    	add    $0x1f53,%ebx
	sys_env_destroy(0);
  8000b3:	6a 00                	push   $0x0
  8000b5:	e8 45 00 00 00       	call   8000ff <sys_env_destroy>
}
  8000ba:	83 c4 10             	add    $0x10,%esp
  8000bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c0:	c9                   	leave  
  8000c1:	c3                   	ret    

008000c2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	57                   	push   %edi
  8000c6:	56                   	push   %esi
  8000c7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d3:	89 c3                	mov    %eax,%ebx
  8000d5:	89 c7                	mov    %eax,%edi
  8000d7:	89 c6                	mov    %eax,%esi
  8000d9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000db:	5b                   	pop    %ebx
  8000dc:	5e                   	pop    %esi
  8000dd:	5f                   	pop    %edi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	57                   	push   %edi
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f0:	89 d1                	mov    %edx,%ecx
  8000f2:	89 d3                	mov    %edx,%ebx
  8000f4:	89 d7                	mov    %edx,%edi
  8000f6:	89 d6                	mov    %edx,%esi
  8000f8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	5f                   	pop    %edi
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	57                   	push   %edi
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
  800105:	83 ec 1c             	sub    $0x1c,%esp
  800108:	e8 66 00 00 00       	call   800173 <__x86.get_pc_thunk.ax>
  80010d:	05 f3 1e 00 00       	add    $0x1ef3,%eax
  800112:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800115:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011a:	8b 55 08             	mov    0x8(%ebp),%edx
  80011d:	b8 03 00 00 00       	mov    $0x3,%eax
  800122:	89 cb                	mov    %ecx,%ebx
  800124:	89 cf                	mov    %ecx,%edi
  800126:	89 ce                	mov    %ecx,%esi
  800128:	cd 30                	int    $0x30
	if(check && ret > 0)
  80012a:	85 c0                	test   %eax,%eax
  80012c:	7f 08                	jg     800136 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	6a 03                	push   $0x3
  80013c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80013f:	8d 83 66 ee ff ff    	lea    -0x119a(%ebx),%eax
  800145:	50                   	push   %eax
  800146:	6a 23                	push   $0x23
  800148:	8d 83 83 ee ff ff    	lea    -0x117d(%ebx),%eax
  80014e:	50                   	push   %eax
  80014f:	e8 23 00 00 00       	call   800177 <_panic>

00800154 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	57                   	push   %edi
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015a:	ba 00 00 00 00       	mov    $0x0,%edx
  80015f:	b8 02 00 00 00       	mov    $0x2,%eax
  800164:	89 d1                	mov    %edx,%ecx
  800166:	89 d3                	mov    %edx,%ebx
  800168:	89 d7                	mov    %edx,%edi
  80016a:	89 d6                	mov    %edx,%esi
  80016c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016e:	5b                   	pop    %ebx
  80016f:	5e                   	pop    %esi
  800170:	5f                   	pop    %edi
  800171:	5d                   	pop    %ebp
  800172:	c3                   	ret    

00800173 <__x86.get_pc_thunk.ax>:
  800173:	8b 04 24             	mov    (%esp),%eax
  800176:	c3                   	ret    

00800177 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	57                   	push   %edi
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	e8 d1 fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800185:	81 c3 7b 1e 00 00    	add    $0x1e7b,%ebx
	va_list ap;

	va_start(ap, fmt);
  80018b:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018e:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800194:	8b 38                	mov    (%eax),%edi
  800196:	e8 b9 ff ff ff       	call   800154 <sys_getenvid>
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 0c             	pushl  0xc(%ebp)
  8001a1:	ff 75 08             	pushl  0x8(%ebp)
  8001a4:	57                   	push   %edi
  8001a5:	50                   	push   %eax
  8001a6:	8d 83 94 ee ff ff    	lea    -0x116c(%ebx),%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 d1 00 00 00       	call   800283 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b2:	83 c4 18             	add    $0x18,%esp
  8001b5:	56                   	push   %esi
  8001b6:	ff 75 10             	pushl  0x10(%ebp)
  8001b9:	e8 63 00 00 00       	call   800221 <vcprintf>
	cprintf("\n");
  8001be:	8d 83 b8 ee ff ff    	lea    -0x1148(%ebx),%eax
  8001c4:	89 04 24             	mov    %eax,(%esp)
  8001c7:	e8 b7 00 00 00       	call   800283 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001cf:	cc                   	int3   
  8001d0:	eb fd                	jmp    8001cf <_panic+0x58>

008001d2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	56                   	push   %esi
  8001d6:	53                   	push   %ebx
  8001d7:	e8 7a fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8001dc:	81 c3 24 1e 00 00    	add    $0x1e24,%ebx
  8001e2:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001e5:	8b 16                	mov    (%esi),%edx
  8001e7:	8d 42 01             	lea    0x1(%edx),%eax
  8001ea:	89 06                	mov    %eax,(%esi)
  8001ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ef:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001f3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f8:	74 0b                	je     800205 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001fa:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5d                   	pop    %ebp
  800204:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	68 ff 00 00 00       	push   $0xff
  80020d:	8d 46 08             	lea    0x8(%esi),%eax
  800210:	50                   	push   %eax
  800211:	e8 ac fe ff ff       	call   8000c2 <sys_cputs>
		b->idx = 0;
  800216:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80021c:	83 c4 10             	add    $0x10,%esp
  80021f:	eb d9                	jmp    8001fa <putch+0x28>

00800221 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	53                   	push   %ebx
  800225:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80022b:	e8 26 fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800230:	81 c3 d0 1d 00 00    	add    $0x1dd0,%ebx
	struct printbuf b;

	b.idx = 0;
  800236:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023d:	00 00 00 
	b.cnt = 0;
  800240:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800247:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024a:	ff 75 0c             	pushl  0xc(%ebp)
  80024d:	ff 75 08             	pushl  0x8(%ebp)
  800250:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800256:	50                   	push   %eax
  800257:	8d 83 d2 e1 ff ff    	lea    -0x1e2e(%ebx),%eax
  80025d:	50                   	push   %eax
  80025e:	e8 38 01 00 00       	call   80039b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800263:	83 c4 08             	add    $0x8,%esp
  800266:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80026c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800272:	50                   	push   %eax
  800273:	e8 4a fe ff ff       	call   8000c2 <sys_cputs>

	return b.cnt;
}
  800278:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800281:	c9                   	leave  
  800282:	c3                   	ret    

00800283 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800289:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028c:	50                   	push   %eax
  80028d:	ff 75 08             	pushl  0x8(%ebp)
  800290:	e8 8c ff ff ff       	call   800221 <vcprintf>
	va_end(ap);

	return cnt;
}
  800295:	c9                   	leave  
  800296:	c3                   	ret    

00800297 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	57                   	push   %edi
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
  80029d:	83 ec 2c             	sub    $0x2c,%esp
  8002a0:	e8 02 06 00 00       	call   8008a7 <__x86.get_pc_thunk.cx>
  8002a5:	81 c1 5b 1d 00 00    	add    $0x1d5b,%ecx
  8002ab:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002ae:	89 c7                	mov    %eax,%edi
  8002b0:	89 d6                	mov    %edx,%esi
  8002b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002bb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  8002be:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c6:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002c9:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002cc:	39 d3                	cmp    %edx,%ebx
  8002ce:	72 09                	jb     8002d9 <printnum+0x42>
  8002d0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d3:	0f 87 83 00 00 00    	ja     80035c <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d9:	83 ec 0c             	sub    $0xc,%esp
  8002dc:	ff 75 18             	pushl  0x18(%ebp)
  8002df:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e5:	53                   	push   %ebx
  8002e6:	ff 75 10             	pushl  0x10(%ebp)
  8002e9:	83 ec 08             	sub    $0x8,%esp
  8002ec:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ef:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002f5:	ff 75 d0             	pushl  -0x30(%ebp)
  8002f8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002fb:	e8 20 09 00 00       	call   800c20 <__udivdi3>
  800300:	83 c4 18             	add    $0x18,%esp
  800303:	52                   	push   %edx
  800304:	50                   	push   %eax
  800305:	89 f2                	mov    %esi,%edx
  800307:	89 f8                	mov    %edi,%eax
  800309:	e8 89 ff ff ff       	call   800297 <printnum>
  80030e:	83 c4 20             	add    $0x20,%esp
  800311:	eb 13                	jmp    800326 <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800313:	83 ec 08             	sub    $0x8,%esp
  800316:	56                   	push   %esi
  800317:	ff 75 18             	pushl  0x18(%ebp)
  80031a:	ff d7                	call   *%edi
  80031c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80031f:	83 eb 01             	sub    $0x1,%ebx
  800322:	85 db                	test   %ebx,%ebx
  800324:	7f ed                	jg     800313 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800326:	83 ec 08             	sub    $0x8,%esp
  800329:	56                   	push   %esi
  80032a:	83 ec 04             	sub    $0x4,%esp
  80032d:	ff 75 dc             	pushl  -0x24(%ebp)
  800330:	ff 75 d8             	pushl  -0x28(%ebp)
  800333:	ff 75 d4             	pushl  -0x2c(%ebp)
  800336:	ff 75 d0             	pushl  -0x30(%ebp)
  800339:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80033c:	89 f3                	mov    %esi,%ebx
  80033e:	e8 fd 09 00 00       	call   800d40 <__umoddi3>
  800343:	83 c4 14             	add    $0x14,%esp
  800346:	0f be 84 06 ba ee ff 	movsbl -0x1146(%esi,%eax,1),%eax
  80034d:	ff 
  80034e:	50                   	push   %eax
  80034f:	ff d7                	call   *%edi
}
  800351:	83 c4 10             	add    $0x10,%esp
  800354:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800357:	5b                   	pop    %ebx
  800358:	5e                   	pop    %esi
  800359:	5f                   	pop    %edi
  80035a:	5d                   	pop    %ebp
  80035b:	c3                   	ret    
  80035c:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80035f:	eb be                	jmp    80031f <printnum+0x88>

00800361 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800367:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80036b:	8b 10                	mov    (%eax),%edx
  80036d:	3b 50 04             	cmp    0x4(%eax),%edx
  800370:	73 0a                	jae    80037c <sprintputch+0x1b>
		*b->buf++ = ch;
  800372:	8d 4a 01             	lea    0x1(%edx),%ecx
  800375:	89 08                	mov    %ecx,(%eax)
  800377:	8b 45 08             	mov    0x8(%ebp),%eax
  80037a:	88 02                	mov    %al,(%edx)
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <printfmt>:
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800384:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800387:	50                   	push   %eax
  800388:	ff 75 10             	pushl  0x10(%ebp)
  80038b:	ff 75 0c             	pushl  0xc(%ebp)
  80038e:	ff 75 08             	pushl  0x8(%ebp)
  800391:	e8 05 00 00 00       	call   80039b <vprintfmt>
}
  800396:	83 c4 10             	add    $0x10,%esp
  800399:	c9                   	leave  
  80039a:	c3                   	ret    

0080039b <vprintfmt>:
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	57                   	push   %edi
  80039f:	56                   	push   %esi
  8003a0:	53                   	push   %ebx
  8003a1:	83 ec 2c             	sub    $0x2c,%esp
  8003a4:	e8 ad fc ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8003a9:	81 c3 57 1c 00 00    	add    $0x1c57,%ebx
  8003af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003b2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b5:	e9 c3 03 00 00       	jmp    80077d <.L35+0x48>
		padc = ' ';
  8003ba:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003be:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003c5:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003cc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d8:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8003db:	8d 47 01             	lea    0x1(%edi),%eax
  8003de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e1:	0f b6 17             	movzbl (%edi),%edx
  8003e4:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003e7:	3c 55                	cmp    $0x55,%al
  8003e9:	0f 87 16 04 00 00    	ja     800805 <.L22>
  8003ef:	0f b6 c0             	movzbl %al,%eax
  8003f2:	89 d9                	mov    %ebx,%ecx
  8003f4:	03 8c 83 48 ef ff ff 	add    -0x10b8(%ebx,%eax,4),%ecx
  8003fb:	ff e1                	jmp    *%ecx

008003fd <.L69>:
  8003fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800400:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800404:	eb d5                	jmp    8003db <vprintfmt+0x40>

00800406 <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800409:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80040d:	eb cc                	jmp    8003db <vprintfmt+0x40>

0080040f <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80040f:	0f b6 d2             	movzbl %dl,%edx
  800412:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
  800415:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  80041a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80041d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800421:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800424:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800427:	83 f9 09             	cmp    $0x9,%ecx
  80042a:	77 55                	ja     800481 <.L23+0xf>
			for (precision = 0;; ++fmt)
  80042c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80042f:	eb e9                	jmp    80041a <.L29+0xb>

00800431 <.L26>:
			precision = va_arg(ap, int);
  800431:	8b 45 14             	mov    0x14(%ebp),%eax
  800434:	8b 00                	mov    (%eax),%eax
  800436:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800439:	8b 45 14             	mov    0x14(%ebp),%eax
  80043c:	8d 40 04             	lea    0x4(%eax),%eax
  80043f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800442:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800445:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800449:	79 90                	jns    8003db <vprintfmt+0x40>
				width = precision, precision = -1;
  80044b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80044e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800451:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800458:	eb 81                	jmp    8003db <vprintfmt+0x40>

0080045a <.L27>:
  80045a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80045d:	85 c0                	test   %eax,%eax
  80045f:	ba 00 00 00 00       	mov    $0x0,%edx
  800464:	0f 49 d0             	cmovns %eax,%edx
  800467:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80046a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80046d:	e9 69 ff ff ff       	jmp    8003db <vprintfmt+0x40>

00800472 <.L23>:
  800472:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800475:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80047c:	e9 5a ff ff ff       	jmp    8003db <vprintfmt+0x40>
  800481:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800484:	eb bf                	jmp    800445 <.L26+0x14>

00800486 <.L33>:
			lflag++;
  800486:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80048a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80048d:	e9 49 ff ff ff       	jmp    8003db <vprintfmt+0x40>

00800492 <.L30>:
			putch(va_arg(ap, int), putdat);
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	8d 78 04             	lea    0x4(%eax),%edi
  800498:	83 ec 08             	sub    $0x8,%esp
  80049b:	56                   	push   %esi
  80049c:	ff 30                	pushl  (%eax)
  80049e:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004a1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004a4:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004a7:	e9 ce 02 00 00       	jmp    80077a <.L35+0x45>

008004ac <.L32>:
			err = va_arg(ap, int);
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8d 78 04             	lea    0x4(%eax),%edi
  8004b2:	8b 00                	mov    (%eax),%eax
  8004b4:	99                   	cltd   
  8004b5:	31 d0                	xor    %edx,%eax
  8004b7:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b9:	83 f8 06             	cmp    $0x6,%eax
  8004bc:	7f 27                	jg     8004e5 <.L32+0x39>
  8004be:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004c5:	85 d2                	test   %edx,%edx
  8004c7:	74 1c                	je     8004e5 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004c9:	52                   	push   %edx
  8004ca:	8d 83 db ee ff ff    	lea    -0x1125(%ebx),%eax
  8004d0:	50                   	push   %eax
  8004d1:	56                   	push   %esi
  8004d2:	ff 75 08             	pushl  0x8(%ebp)
  8004d5:	e8 a4 fe ff ff       	call   80037e <printfmt>
  8004da:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004dd:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004e0:	e9 95 02 00 00       	jmp    80077a <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004e5:	50                   	push   %eax
  8004e6:	8d 83 d2 ee ff ff    	lea    -0x112e(%ebx),%eax
  8004ec:	50                   	push   %eax
  8004ed:	56                   	push   %esi
  8004ee:	ff 75 08             	pushl  0x8(%ebp)
  8004f1:	e8 88 fe ff ff       	call   80037e <printfmt>
  8004f6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004f9:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004fc:	e9 79 02 00 00       	jmp    80077a <.L35+0x45>

00800501 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	83 c0 04             	add    $0x4,%eax
  800507:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80050a:	8b 45 14             	mov    0x14(%ebp),%eax
  80050d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80050f:	85 ff                	test   %edi,%edi
  800511:	8d 83 cb ee ff ff    	lea    -0x1135(%ebx),%eax
  800517:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80051a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80051e:	0f 8e b5 00 00 00    	jle    8005d9 <.L36+0xd8>
  800524:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800528:	75 08                	jne    800532 <.L36+0x31>
  80052a:	89 75 0c             	mov    %esi,0xc(%ebp)
  80052d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800530:	eb 6d                	jmp    80059f <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	ff 75 cc             	pushl  -0x34(%ebp)
  800538:	57                   	push   %edi
  800539:	e8 85 03 00 00       	call   8008c3 <strnlen>
  80053e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800541:	29 c2                	sub    %eax,%edx
  800543:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800546:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800549:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80054d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800550:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800553:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800555:	eb 10                	jmp    800567 <.L36+0x66>
					putch(padc, putdat);
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	56                   	push   %esi
  80055b:	ff 75 e0             	pushl  -0x20(%ebp)
  80055e:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800561:	83 ef 01             	sub    $0x1,%edi
  800564:	83 c4 10             	add    $0x10,%esp
  800567:	85 ff                	test   %edi,%edi
  800569:	7f ec                	jg     800557 <.L36+0x56>
  80056b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80056e:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800571:	85 d2                	test   %edx,%edx
  800573:	b8 00 00 00 00       	mov    $0x0,%eax
  800578:	0f 49 c2             	cmovns %edx,%eax
  80057b:	29 c2                	sub    %eax,%edx
  80057d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800580:	89 75 0c             	mov    %esi,0xc(%ebp)
  800583:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800586:	eb 17                	jmp    80059f <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  800588:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058c:	75 30                	jne    8005be <.L36+0xbd>
					putch(ch, putdat);
  80058e:	83 ec 08             	sub    $0x8,%esp
  800591:	ff 75 0c             	pushl  0xc(%ebp)
  800594:	50                   	push   %eax
  800595:	ff 55 08             	call   *0x8(%ebp)
  800598:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059b:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80059f:	83 c7 01             	add    $0x1,%edi
  8005a2:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005a6:	0f be c2             	movsbl %dl,%eax
  8005a9:	85 c0                	test   %eax,%eax
  8005ab:	74 52                	je     8005ff <.L36+0xfe>
  8005ad:	85 f6                	test   %esi,%esi
  8005af:	78 d7                	js     800588 <.L36+0x87>
  8005b1:	83 ee 01             	sub    $0x1,%esi
  8005b4:	79 d2                	jns    800588 <.L36+0x87>
  8005b6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005b9:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005bc:	eb 32                	jmp    8005f0 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005be:	0f be d2             	movsbl %dl,%edx
  8005c1:	83 ea 20             	sub    $0x20,%edx
  8005c4:	83 fa 5e             	cmp    $0x5e,%edx
  8005c7:	76 c5                	jbe    80058e <.L36+0x8d>
					putch('?', putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	ff 75 0c             	pushl  0xc(%ebp)
  8005cf:	6a 3f                	push   $0x3f
  8005d1:	ff 55 08             	call   *0x8(%ebp)
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	eb c2                	jmp    80059b <.L36+0x9a>
  8005d9:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005dc:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005df:	eb be                	jmp    80059f <.L36+0x9e>
				putch(' ', putdat);
  8005e1:	83 ec 08             	sub    $0x8,%esp
  8005e4:	56                   	push   %esi
  8005e5:	6a 20                	push   $0x20
  8005e7:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8005ea:	83 ef 01             	sub    $0x1,%edi
  8005ed:	83 c4 10             	add    $0x10,%esp
  8005f0:	85 ff                	test   %edi,%edi
  8005f2:	7f ed                	jg     8005e1 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  8005f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005f7:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fa:	e9 7b 01 00 00       	jmp    80077a <.L35+0x45>
  8005ff:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800602:	8b 75 0c             	mov    0xc(%ebp),%esi
  800605:	eb e9                	jmp    8005f0 <.L36+0xef>

00800607 <.L31>:
  800607:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80060a:	83 f9 01             	cmp    $0x1,%ecx
  80060d:	7e 40                	jle    80064f <.L31+0x48>
		return va_arg(*ap, long long);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8b 50 04             	mov    0x4(%eax),%edx
  800615:	8b 00                	mov    (%eax),%eax
  800617:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8d 40 08             	lea    0x8(%eax),%eax
  800623:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
  800626:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80062a:	79 55                	jns    800681 <.L31+0x7a>
				putch('-', putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	56                   	push   %esi
  800630:	6a 2d                	push   $0x2d
  800632:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  800635:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800638:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80063b:	f7 da                	neg    %edx
  80063d:	83 d1 00             	adc    $0x0,%ecx
  800640:	f7 d9                	neg    %ecx
  800642:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
  800645:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064a:	e9 10 01 00 00       	jmp    80075f <.L35+0x2a>
	else if (lflag)
  80064f:	85 c9                	test   %ecx,%ecx
  800651:	75 17                	jne    80066a <.L31+0x63>
		return va_arg(*ap, int);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8b 00                	mov    (%eax),%eax
  800658:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065b:	99                   	cltd   
  80065c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8d 40 04             	lea    0x4(%eax),%eax
  800665:	89 45 14             	mov    %eax,0x14(%ebp)
  800668:	eb bc                	jmp    800626 <.L31+0x1f>
		return va_arg(*ap, long);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8b 00                	mov    (%eax),%eax
  80066f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800672:	99                   	cltd   
  800673:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8d 40 04             	lea    0x4(%eax),%eax
  80067c:	89 45 14             	mov    %eax,0x14(%ebp)
  80067f:	eb a5                	jmp    800626 <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  800681:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800684:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
  800687:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068c:	e9 ce 00 00 00       	jmp    80075f <.L35+0x2a>

00800691 <.L37>:
  800691:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800694:	83 f9 01             	cmp    $0x1,%ecx
  800697:	7e 18                	jle    8006b1 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8b 10                	mov    (%eax),%edx
  80069e:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a1:	8d 40 08             	lea    0x8(%eax),%eax
  8006a4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006a7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ac:	e9 ae 00 00 00       	jmp    80075f <.L35+0x2a>
	else if (lflag)
  8006b1:	85 c9                	test   %ecx,%ecx
  8006b3:	75 1a                	jne    8006cf <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8b 10                	mov    (%eax),%edx
  8006ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bf:	8d 40 04             	lea    0x4(%eax),%eax
  8006c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ca:	e9 90 00 00 00       	jmp    80075f <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8b 10                	mov    (%eax),%edx
  8006d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d9:	8d 40 04             	lea    0x4(%eax),%eax
  8006dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006df:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e4:	eb 79                	jmp    80075f <.L35+0x2a>

008006e6 <.L34>:
  8006e6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006e9:	83 f9 01             	cmp    $0x1,%ecx
  8006ec:	7e 15                	jle    800703 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8b 10                	mov    (%eax),%edx
  8006f3:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f6:	8d 40 08             	lea    0x8(%eax),%eax
  8006f9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006fc:	b8 08 00 00 00       	mov    $0x8,%eax
  800701:	eb 5c                	jmp    80075f <.L35+0x2a>
	else if (lflag)
  800703:	85 c9                	test   %ecx,%ecx
  800705:	75 17                	jne    80071e <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800707:	8b 45 14             	mov    0x14(%ebp),%eax
  80070a:	8b 10                	mov    (%eax),%edx
  80070c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800711:	8d 40 04             	lea    0x4(%eax),%eax
  800714:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800717:	b8 08 00 00 00       	mov    $0x8,%eax
  80071c:	eb 41                	jmp    80075f <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  80071e:	8b 45 14             	mov    0x14(%ebp),%eax
  800721:	8b 10                	mov    (%eax),%edx
  800723:	b9 00 00 00 00       	mov    $0x0,%ecx
  800728:	8d 40 04             	lea    0x4(%eax),%eax
  80072b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80072e:	b8 08 00 00 00       	mov    $0x8,%eax
  800733:	eb 2a                	jmp    80075f <.L35+0x2a>

00800735 <.L35>:
			putch('0', putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	56                   	push   %esi
  800739:	6a 30                	push   $0x30
  80073b:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80073e:	83 c4 08             	add    $0x8,%esp
  800741:	56                   	push   %esi
  800742:	6a 78                	push   $0x78
  800744:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	8b 10                	mov    (%eax),%edx
  80074c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800751:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800754:	8d 40 04             	lea    0x4(%eax),%eax
  800757:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80075a:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  80075f:	83 ec 0c             	sub    $0xc,%esp
  800762:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800766:	57                   	push   %edi
  800767:	ff 75 e0             	pushl  -0x20(%ebp)
  80076a:	50                   	push   %eax
  80076b:	51                   	push   %ecx
  80076c:	52                   	push   %edx
  80076d:	89 f2                	mov    %esi,%edx
  80076f:	8b 45 08             	mov    0x8(%ebp),%eax
  800772:	e8 20 fb ff ff       	call   800297 <printnum>
			break;
  800777:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80077a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  80077d:	83 c7 01             	add    $0x1,%edi
  800780:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800784:	83 f8 25             	cmp    $0x25,%eax
  800787:	0f 84 2d fc ff ff    	je     8003ba <vprintfmt+0x1f>
			if (ch == '\0')
  80078d:	85 c0                	test   %eax,%eax
  80078f:	0f 84 91 00 00 00    	je     800826 <.L22+0x21>
			putch(ch, putdat);
  800795:	83 ec 08             	sub    $0x8,%esp
  800798:	56                   	push   %esi
  800799:	50                   	push   %eax
  80079a:	ff 55 08             	call   *0x8(%ebp)
  80079d:	83 c4 10             	add    $0x10,%esp
  8007a0:	eb db                	jmp    80077d <.L35+0x48>

008007a2 <.L38>:
  8007a2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8007a5:	83 f9 01             	cmp    $0x1,%ecx
  8007a8:	7e 15                	jle    8007bf <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	8b 10                	mov    (%eax),%edx
  8007af:	8b 48 04             	mov    0x4(%eax),%ecx
  8007b2:	8d 40 08             	lea    0x8(%eax),%eax
  8007b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b8:	b8 10 00 00 00       	mov    $0x10,%eax
  8007bd:	eb a0                	jmp    80075f <.L35+0x2a>
	else if (lflag)
  8007bf:	85 c9                	test   %ecx,%ecx
  8007c1:	75 17                	jne    8007da <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8b 10                	mov    (%eax),%edx
  8007c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007cd:	8d 40 04             	lea    0x4(%eax),%eax
  8007d0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d3:	b8 10 00 00 00       	mov    $0x10,%eax
  8007d8:	eb 85                	jmp    80075f <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007da:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dd:	8b 10                	mov    (%eax),%edx
  8007df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e4:	8d 40 04             	lea    0x4(%eax),%eax
  8007e7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ea:	b8 10 00 00 00       	mov    $0x10,%eax
  8007ef:	e9 6b ff ff ff       	jmp    80075f <.L35+0x2a>

008007f4 <.L25>:
			putch(ch, putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	56                   	push   %esi
  8007f8:	6a 25                	push   $0x25
  8007fa:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007fd:	83 c4 10             	add    $0x10,%esp
  800800:	e9 75 ff ff ff       	jmp    80077a <.L35+0x45>

00800805 <.L22>:
			putch('%', putdat);
  800805:	83 ec 08             	sub    $0x8,%esp
  800808:	56                   	push   %esi
  800809:	6a 25                	push   $0x25
  80080b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80080e:	83 c4 10             	add    $0x10,%esp
  800811:	89 f8                	mov    %edi,%eax
  800813:	eb 03                	jmp    800818 <.L22+0x13>
  800815:	83 e8 01             	sub    $0x1,%eax
  800818:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80081c:	75 f7                	jne    800815 <.L22+0x10>
  80081e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800821:	e9 54 ff ff ff       	jmp    80077a <.L35+0x45>
}
  800826:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800829:	5b                   	pop    %ebx
  80082a:	5e                   	pop    %esi
  80082b:	5f                   	pop    %edi
  80082c:	5d                   	pop    %ebp
  80082d:	c3                   	ret    

0080082e <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	53                   	push   %ebx
  800832:	83 ec 14             	sub    $0x14,%esp
  800835:	e8 1c f8 ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  80083a:	81 c3 c6 17 00 00    	add    $0x17c6,%ebx
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  800846:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800849:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80084d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800850:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800857:	85 c0                	test   %eax,%eax
  800859:	74 2b                	je     800886 <vsnprintf+0x58>
  80085b:	85 d2                	test   %edx,%edx
  80085d:	7e 27                	jle    800886 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  80085f:	ff 75 14             	pushl  0x14(%ebp)
  800862:	ff 75 10             	pushl  0x10(%ebp)
  800865:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800868:	50                   	push   %eax
  800869:	8d 83 61 e3 ff ff    	lea    -0x1c9f(%ebx),%eax
  80086f:	50                   	push   %eax
  800870:	e8 26 fb ff ff       	call   80039b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800875:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800878:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087e:	83 c4 10             	add    $0x10,%esp
}
  800881:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800884:	c9                   	leave  
  800885:	c3                   	ret    
		return -E_INVAL;
  800886:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088b:	eb f4                	jmp    800881 <vsnprintf+0x53>

0080088d <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800893:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800896:	50                   	push   %eax
  800897:	ff 75 10             	pushl  0x10(%ebp)
  80089a:	ff 75 0c             	pushl  0xc(%ebp)
  80089d:	ff 75 08             	pushl  0x8(%ebp)
  8008a0:	e8 89 ff ff ff       	call   80082e <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a5:	c9                   	leave  
  8008a6:	c3                   	ret    

008008a7 <__x86.get_pc_thunk.cx>:
  8008a7:	8b 0c 24             	mov    (%esp),%ecx
  8008aa:	c3                   	ret    

008008ab <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b6:	eb 03                	jmp    8008bb <strlen+0x10>
		n++;
  8008b8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008bb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008bf:	75 f7                	jne    8008b8 <strlen+0xd>
	return n;
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d1:	eb 03                	jmp    8008d6 <strnlen+0x13>
		n++;
  8008d3:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d6:	39 d0                	cmp    %edx,%eax
  8008d8:	74 06                	je     8008e0 <strnlen+0x1d>
  8008da:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008de:	75 f3                	jne    8008d3 <strnlen+0x10>
	return n;
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	53                   	push   %ebx
  8008e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ec:	89 c2                	mov    %eax,%edx
  8008ee:	83 c1 01             	add    $0x1,%ecx
  8008f1:	83 c2 01             	add    $0x1,%edx
  8008f4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008f8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008fb:	84 db                	test   %bl,%bl
  8008fd:	75 ef                	jne    8008ee <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008ff:	5b                   	pop    %ebx
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	53                   	push   %ebx
  800906:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800909:	53                   	push   %ebx
  80090a:	e8 9c ff ff ff       	call   8008ab <strlen>
  80090f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800912:	ff 75 0c             	pushl  0xc(%ebp)
  800915:	01 d8                	add    %ebx,%eax
  800917:	50                   	push   %eax
  800918:	e8 c5 ff ff ff       	call   8008e2 <strcpy>
	return dst;
}
  80091d:	89 d8                	mov    %ebx,%eax
  80091f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800922:	c9                   	leave  
  800923:	c3                   	ret    

00800924 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	56                   	push   %esi
  800928:	53                   	push   %ebx
  800929:	8b 75 08             	mov    0x8(%ebp),%esi
  80092c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092f:	89 f3                	mov    %esi,%ebx
  800931:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800934:	89 f2                	mov    %esi,%edx
  800936:	eb 0f                	jmp    800947 <strncpy+0x23>
		*dst++ = *src;
  800938:	83 c2 01             	add    $0x1,%edx
  80093b:	0f b6 01             	movzbl (%ecx),%eax
  80093e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800941:	80 39 01             	cmpb   $0x1,(%ecx)
  800944:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800947:	39 da                	cmp    %ebx,%edx
  800949:	75 ed                	jne    800938 <strncpy+0x14>
	}
	return ret;
}
  80094b:	89 f0                	mov    %esi,%eax
  80094d:	5b                   	pop    %ebx
  80094e:	5e                   	pop    %esi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	56                   	push   %esi
  800955:	53                   	push   %ebx
  800956:	8b 75 08             	mov    0x8(%ebp),%esi
  800959:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80095f:	89 f0                	mov    %esi,%eax
  800961:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800965:	85 c9                	test   %ecx,%ecx
  800967:	75 0b                	jne    800974 <strlcpy+0x23>
  800969:	eb 17                	jmp    800982 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80096b:	83 c2 01             	add    $0x1,%edx
  80096e:	83 c0 01             	add    $0x1,%eax
  800971:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800974:	39 d8                	cmp    %ebx,%eax
  800976:	74 07                	je     80097f <strlcpy+0x2e>
  800978:	0f b6 0a             	movzbl (%edx),%ecx
  80097b:	84 c9                	test   %cl,%cl
  80097d:	75 ec                	jne    80096b <strlcpy+0x1a>
		*dst = '\0';
  80097f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800982:	29 f0                	sub    %esi,%eax
}
  800984:	5b                   	pop    %ebx
  800985:	5e                   	pop    %esi
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800991:	eb 06                	jmp    800999 <strcmp+0x11>
		p++, q++;
  800993:	83 c1 01             	add    $0x1,%ecx
  800996:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800999:	0f b6 01             	movzbl (%ecx),%eax
  80099c:	84 c0                	test   %al,%al
  80099e:	74 04                	je     8009a4 <strcmp+0x1c>
  8009a0:	3a 02                	cmp    (%edx),%al
  8009a2:	74 ef                	je     800993 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a4:	0f b6 c0             	movzbl %al,%eax
  8009a7:	0f b6 12             	movzbl (%edx),%edx
  8009aa:	29 d0                	sub    %edx,%eax
}
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	53                   	push   %ebx
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b8:	89 c3                	mov    %eax,%ebx
  8009ba:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009bd:	eb 06                	jmp    8009c5 <strncmp+0x17>
		n--, p++, q++;
  8009bf:	83 c0 01             	add    $0x1,%eax
  8009c2:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009c5:	39 d8                	cmp    %ebx,%eax
  8009c7:	74 16                	je     8009df <strncmp+0x31>
  8009c9:	0f b6 08             	movzbl (%eax),%ecx
  8009cc:	84 c9                	test   %cl,%cl
  8009ce:	74 04                	je     8009d4 <strncmp+0x26>
  8009d0:	3a 0a                	cmp    (%edx),%cl
  8009d2:	74 eb                	je     8009bf <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d4:	0f b6 00             	movzbl (%eax),%eax
  8009d7:	0f b6 12             	movzbl (%edx),%edx
  8009da:	29 d0                	sub    %edx,%eax
}
  8009dc:	5b                   	pop    %ebx
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    
		return 0;
  8009df:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e4:	eb f6                	jmp    8009dc <strncmp+0x2e>

008009e6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f0:	0f b6 10             	movzbl (%eax),%edx
  8009f3:	84 d2                	test   %dl,%dl
  8009f5:	74 09                	je     800a00 <strchr+0x1a>
		if (*s == c)
  8009f7:	38 ca                	cmp    %cl,%dl
  8009f9:	74 0a                	je     800a05 <strchr+0x1f>
	for (; *s; s++)
  8009fb:	83 c0 01             	add    $0x1,%eax
  8009fe:	eb f0                	jmp    8009f0 <strchr+0xa>
			return (char *) s;
	return 0;
  800a00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a11:	eb 03                	jmp    800a16 <strfind+0xf>
  800a13:	83 c0 01             	add    $0x1,%eax
  800a16:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a19:	38 ca                	cmp    %cl,%dl
  800a1b:	74 04                	je     800a21 <strfind+0x1a>
  800a1d:	84 d2                	test   %dl,%dl
  800a1f:	75 f2                	jne    800a13 <strfind+0xc>
			break;
	return (char *) s;
}
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	57                   	push   %edi
  800a27:	56                   	push   %esi
  800a28:	53                   	push   %ebx
  800a29:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a2c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a2f:	85 c9                	test   %ecx,%ecx
  800a31:	74 13                	je     800a46 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a33:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a39:	75 05                	jne    800a40 <memset+0x1d>
  800a3b:	f6 c1 03             	test   $0x3,%cl
  800a3e:	74 0d                	je     800a4d <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a43:	fc                   	cld    
  800a44:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a46:	89 f8                	mov    %edi,%eax
  800a48:	5b                   	pop    %ebx
  800a49:	5e                   	pop    %esi
  800a4a:	5f                   	pop    %edi
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    
		c &= 0xFF;
  800a4d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a51:	89 d3                	mov    %edx,%ebx
  800a53:	c1 e3 08             	shl    $0x8,%ebx
  800a56:	89 d0                	mov    %edx,%eax
  800a58:	c1 e0 18             	shl    $0x18,%eax
  800a5b:	89 d6                	mov    %edx,%esi
  800a5d:	c1 e6 10             	shl    $0x10,%esi
  800a60:	09 f0                	or     %esi,%eax
  800a62:	09 c2                	or     %eax,%edx
  800a64:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a66:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a69:	89 d0                	mov    %edx,%eax
  800a6b:	fc                   	cld    
  800a6c:	f3 ab                	rep stos %eax,%es:(%edi)
  800a6e:	eb d6                	jmp    800a46 <memset+0x23>

00800a70 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	8b 45 08             	mov    0x8(%ebp),%eax
  800a78:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a7e:	39 c6                	cmp    %eax,%esi
  800a80:	73 35                	jae    800ab7 <memmove+0x47>
  800a82:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a85:	39 c2                	cmp    %eax,%edx
  800a87:	76 2e                	jbe    800ab7 <memmove+0x47>
		s += n;
		d += n;
  800a89:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8c:	89 d6                	mov    %edx,%esi
  800a8e:	09 fe                	or     %edi,%esi
  800a90:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a96:	74 0c                	je     800aa4 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a98:	83 ef 01             	sub    $0x1,%edi
  800a9b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a9e:	fd                   	std    
  800a9f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa1:	fc                   	cld    
  800aa2:	eb 21                	jmp    800ac5 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa4:	f6 c1 03             	test   $0x3,%cl
  800aa7:	75 ef                	jne    800a98 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aa9:	83 ef 04             	sub    $0x4,%edi
  800aac:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aaf:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ab2:	fd                   	std    
  800ab3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab5:	eb ea                	jmp    800aa1 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab7:	89 f2                	mov    %esi,%edx
  800ab9:	09 c2                	or     %eax,%edx
  800abb:	f6 c2 03             	test   $0x3,%dl
  800abe:	74 09                	je     800ac9 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ac0:	89 c7                	mov    %eax,%edi
  800ac2:	fc                   	cld    
  800ac3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac5:	5e                   	pop    %esi
  800ac6:	5f                   	pop    %edi
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac9:	f6 c1 03             	test   $0x3,%cl
  800acc:	75 f2                	jne    800ac0 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ace:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ad1:	89 c7                	mov    %eax,%edi
  800ad3:	fc                   	cld    
  800ad4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad6:	eb ed                	jmp    800ac5 <memmove+0x55>

00800ad8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800adb:	ff 75 10             	pushl  0x10(%ebp)
  800ade:	ff 75 0c             	pushl  0xc(%ebp)
  800ae1:	ff 75 08             	pushl  0x8(%ebp)
  800ae4:	e8 87 ff ff ff       	call   800a70 <memmove>
}
  800ae9:	c9                   	leave  
  800aea:	c3                   	ret    

00800aeb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
  800af0:	8b 45 08             	mov    0x8(%ebp),%eax
  800af3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af6:	89 c6                	mov    %eax,%esi
  800af8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afb:	39 f0                	cmp    %esi,%eax
  800afd:	74 1c                	je     800b1b <memcmp+0x30>
		if (*s1 != *s2)
  800aff:	0f b6 08             	movzbl (%eax),%ecx
  800b02:	0f b6 1a             	movzbl (%edx),%ebx
  800b05:	38 d9                	cmp    %bl,%cl
  800b07:	75 08                	jne    800b11 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b09:	83 c0 01             	add    $0x1,%eax
  800b0c:	83 c2 01             	add    $0x1,%edx
  800b0f:	eb ea                	jmp    800afb <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b11:	0f b6 c1             	movzbl %cl,%eax
  800b14:	0f b6 db             	movzbl %bl,%ebx
  800b17:	29 d8                	sub    %ebx,%eax
  800b19:	eb 05                	jmp    800b20 <memcmp+0x35>
	}

	return 0;
  800b1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b2d:	89 c2                	mov    %eax,%edx
  800b2f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b32:	39 d0                	cmp    %edx,%eax
  800b34:	73 09                	jae    800b3f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b36:	38 08                	cmp    %cl,(%eax)
  800b38:	74 05                	je     800b3f <memfind+0x1b>
	for (; s < ends; s++)
  800b3a:	83 c0 01             	add    $0x1,%eax
  800b3d:	eb f3                	jmp    800b32 <memfind+0xe>
			break;
	return (void *) s;
}
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
  800b47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b4d:	eb 03                	jmp    800b52 <strtol+0x11>
		s++;
  800b4f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b52:	0f b6 01             	movzbl (%ecx),%eax
  800b55:	3c 20                	cmp    $0x20,%al
  800b57:	74 f6                	je     800b4f <strtol+0xe>
  800b59:	3c 09                	cmp    $0x9,%al
  800b5b:	74 f2                	je     800b4f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b5d:	3c 2b                	cmp    $0x2b,%al
  800b5f:	74 2e                	je     800b8f <strtol+0x4e>
	int neg = 0;
  800b61:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b66:	3c 2d                	cmp    $0x2d,%al
  800b68:	74 2f                	je     800b99 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b70:	75 05                	jne    800b77 <strtol+0x36>
  800b72:	80 39 30             	cmpb   $0x30,(%ecx)
  800b75:	74 2c                	je     800ba3 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b77:	85 db                	test   %ebx,%ebx
  800b79:	75 0a                	jne    800b85 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b7b:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b80:	80 39 30             	cmpb   $0x30,(%ecx)
  800b83:	74 28                	je     800bad <strtol+0x6c>
		base = 10;
  800b85:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b8d:	eb 50                	jmp    800bdf <strtol+0x9e>
		s++;
  800b8f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b92:	bf 00 00 00 00       	mov    $0x0,%edi
  800b97:	eb d1                	jmp    800b6a <strtol+0x29>
		s++, neg = 1;
  800b99:	83 c1 01             	add    $0x1,%ecx
  800b9c:	bf 01 00 00 00       	mov    $0x1,%edi
  800ba1:	eb c7                	jmp    800b6a <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ba7:	74 0e                	je     800bb7 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ba9:	85 db                	test   %ebx,%ebx
  800bab:	75 d8                	jne    800b85 <strtol+0x44>
		s++, base = 8;
  800bad:	83 c1 01             	add    $0x1,%ecx
  800bb0:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bb5:	eb ce                	jmp    800b85 <strtol+0x44>
		s += 2, base = 16;
  800bb7:	83 c1 02             	add    $0x2,%ecx
  800bba:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bbf:	eb c4                	jmp    800b85 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bc1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bc4:	89 f3                	mov    %esi,%ebx
  800bc6:	80 fb 19             	cmp    $0x19,%bl
  800bc9:	77 29                	ja     800bf4 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bcb:	0f be d2             	movsbl %dl,%edx
  800bce:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bd1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bd4:	7d 30                	jge    800c06 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bd6:	83 c1 01             	add    $0x1,%ecx
  800bd9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bdd:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bdf:	0f b6 11             	movzbl (%ecx),%edx
  800be2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800be5:	89 f3                	mov    %esi,%ebx
  800be7:	80 fb 09             	cmp    $0x9,%bl
  800bea:	77 d5                	ja     800bc1 <strtol+0x80>
			dig = *s - '0';
  800bec:	0f be d2             	movsbl %dl,%edx
  800bef:	83 ea 30             	sub    $0x30,%edx
  800bf2:	eb dd                	jmp    800bd1 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bf4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bf7:	89 f3                	mov    %esi,%ebx
  800bf9:	80 fb 19             	cmp    $0x19,%bl
  800bfc:	77 08                	ja     800c06 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bfe:	0f be d2             	movsbl %dl,%edx
  800c01:	83 ea 37             	sub    $0x37,%edx
  800c04:	eb cb                	jmp    800bd1 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c06:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c0a:	74 05                	je     800c11 <strtol+0xd0>
		*endptr = (char *) s;
  800c0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c0f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c11:	89 c2                	mov    %eax,%edx
  800c13:	f7 da                	neg    %edx
  800c15:	85 ff                	test   %edi,%edi
  800c17:	0f 45 c2             	cmovne %edx,%eax
}
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5f                   	pop    %edi
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    
  800c1f:	90                   	nop

00800c20 <__udivdi3>:
  800c20:	55                   	push   %ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 1c             	sub    $0x1c,%esp
  800c27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c2b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c33:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c37:	85 d2                	test   %edx,%edx
  800c39:	75 35                	jne    800c70 <__udivdi3+0x50>
  800c3b:	39 f3                	cmp    %esi,%ebx
  800c3d:	0f 87 bd 00 00 00    	ja     800d00 <__udivdi3+0xe0>
  800c43:	85 db                	test   %ebx,%ebx
  800c45:	89 d9                	mov    %ebx,%ecx
  800c47:	75 0b                	jne    800c54 <__udivdi3+0x34>
  800c49:	b8 01 00 00 00       	mov    $0x1,%eax
  800c4e:	31 d2                	xor    %edx,%edx
  800c50:	f7 f3                	div    %ebx
  800c52:	89 c1                	mov    %eax,%ecx
  800c54:	31 d2                	xor    %edx,%edx
  800c56:	89 f0                	mov    %esi,%eax
  800c58:	f7 f1                	div    %ecx
  800c5a:	89 c6                	mov    %eax,%esi
  800c5c:	89 e8                	mov    %ebp,%eax
  800c5e:	89 f7                	mov    %esi,%edi
  800c60:	f7 f1                	div    %ecx
  800c62:	89 fa                	mov    %edi,%edx
  800c64:	83 c4 1c             	add    $0x1c,%esp
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    
  800c6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c70:	39 f2                	cmp    %esi,%edx
  800c72:	77 7c                	ja     800cf0 <__udivdi3+0xd0>
  800c74:	0f bd fa             	bsr    %edx,%edi
  800c77:	83 f7 1f             	xor    $0x1f,%edi
  800c7a:	0f 84 98 00 00 00    	je     800d18 <__udivdi3+0xf8>
  800c80:	89 f9                	mov    %edi,%ecx
  800c82:	b8 20 00 00 00       	mov    $0x20,%eax
  800c87:	29 f8                	sub    %edi,%eax
  800c89:	d3 e2                	shl    %cl,%edx
  800c8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c8f:	89 c1                	mov    %eax,%ecx
  800c91:	89 da                	mov    %ebx,%edx
  800c93:	d3 ea                	shr    %cl,%edx
  800c95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c99:	09 d1                	or     %edx,%ecx
  800c9b:	89 f2                	mov    %esi,%edx
  800c9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ca1:	89 f9                	mov    %edi,%ecx
  800ca3:	d3 e3                	shl    %cl,%ebx
  800ca5:	89 c1                	mov    %eax,%ecx
  800ca7:	d3 ea                	shr    %cl,%edx
  800ca9:	89 f9                	mov    %edi,%ecx
  800cab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800caf:	d3 e6                	shl    %cl,%esi
  800cb1:	89 eb                	mov    %ebp,%ebx
  800cb3:	89 c1                	mov    %eax,%ecx
  800cb5:	d3 eb                	shr    %cl,%ebx
  800cb7:	09 de                	or     %ebx,%esi
  800cb9:	89 f0                	mov    %esi,%eax
  800cbb:	f7 74 24 08          	divl   0x8(%esp)
  800cbf:	89 d6                	mov    %edx,%esi
  800cc1:	89 c3                	mov    %eax,%ebx
  800cc3:	f7 64 24 0c          	mull   0xc(%esp)
  800cc7:	39 d6                	cmp    %edx,%esi
  800cc9:	72 0c                	jb     800cd7 <__udivdi3+0xb7>
  800ccb:	89 f9                	mov    %edi,%ecx
  800ccd:	d3 e5                	shl    %cl,%ebp
  800ccf:	39 c5                	cmp    %eax,%ebp
  800cd1:	73 5d                	jae    800d30 <__udivdi3+0x110>
  800cd3:	39 d6                	cmp    %edx,%esi
  800cd5:	75 59                	jne    800d30 <__udivdi3+0x110>
  800cd7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cda:	31 ff                	xor    %edi,%edi
  800cdc:	89 fa                	mov    %edi,%edx
  800cde:	83 c4 1c             	add    $0x1c,%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    
  800ce6:	8d 76 00             	lea    0x0(%esi),%esi
  800ce9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800cf0:	31 ff                	xor    %edi,%edi
  800cf2:	31 c0                	xor    %eax,%eax
  800cf4:	89 fa                	mov    %edi,%edx
  800cf6:	83 c4 1c             	add    $0x1c,%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    
  800cfe:	66 90                	xchg   %ax,%ax
  800d00:	31 ff                	xor    %edi,%edi
  800d02:	89 e8                	mov    %ebp,%eax
  800d04:	89 f2                	mov    %esi,%edx
  800d06:	f7 f3                	div    %ebx
  800d08:	89 fa                	mov    %edi,%edx
  800d0a:	83 c4 1c             	add    $0x1c,%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    
  800d12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d18:	39 f2                	cmp    %esi,%edx
  800d1a:	72 06                	jb     800d22 <__udivdi3+0x102>
  800d1c:	31 c0                	xor    %eax,%eax
  800d1e:	39 eb                	cmp    %ebp,%ebx
  800d20:	77 d2                	ja     800cf4 <__udivdi3+0xd4>
  800d22:	b8 01 00 00 00       	mov    $0x1,%eax
  800d27:	eb cb                	jmp    800cf4 <__udivdi3+0xd4>
  800d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d30:	89 d8                	mov    %ebx,%eax
  800d32:	31 ff                	xor    %edi,%edi
  800d34:	eb be                	jmp    800cf4 <__udivdi3+0xd4>
  800d36:	66 90                	xchg   %ax,%ax
  800d38:	66 90                	xchg   %ax,%ax
  800d3a:	66 90                	xchg   %ax,%ax
  800d3c:	66 90                	xchg   %ax,%ax
  800d3e:	66 90                	xchg   %ax,%ax

00800d40 <__umoddi3>:
  800d40:	55                   	push   %ebp
  800d41:	57                   	push   %edi
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	83 ec 1c             	sub    $0x1c,%esp
  800d47:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d4b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d4f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d57:	85 ed                	test   %ebp,%ebp
  800d59:	89 f0                	mov    %esi,%eax
  800d5b:	89 da                	mov    %ebx,%edx
  800d5d:	75 19                	jne    800d78 <__umoddi3+0x38>
  800d5f:	39 df                	cmp    %ebx,%edi
  800d61:	0f 86 b1 00 00 00    	jbe    800e18 <__umoddi3+0xd8>
  800d67:	f7 f7                	div    %edi
  800d69:	89 d0                	mov    %edx,%eax
  800d6b:	31 d2                	xor    %edx,%edx
  800d6d:	83 c4 1c             	add    $0x1c,%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    
  800d75:	8d 76 00             	lea    0x0(%esi),%esi
  800d78:	39 dd                	cmp    %ebx,%ebp
  800d7a:	77 f1                	ja     800d6d <__umoddi3+0x2d>
  800d7c:	0f bd cd             	bsr    %ebp,%ecx
  800d7f:	83 f1 1f             	xor    $0x1f,%ecx
  800d82:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d86:	0f 84 b4 00 00 00    	je     800e40 <__umoddi3+0x100>
  800d8c:	b8 20 00 00 00       	mov    $0x20,%eax
  800d91:	89 c2                	mov    %eax,%edx
  800d93:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d97:	29 c2                	sub    %eax,%edx
  800d99:	89 c1                	mov    %eax,%ecx
  800d9b:	89 f8                	mov    %edi,%eax
  800d9d:	d3 e5                	shl    %cl,%ebp
  800d9f:	89 d1                	mov    %edx,%ecx
  800da1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800da5:	d3 e8                	shr    %cl,%eax
  800da7:	09 c5                	or     %eax,%ebp
  800da9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dad:	89 c1                	mov    %eax,%ecx
  800daf:	d3 e7                	shl    %cl,%edi
  800db1:	89 d1                	mov    %edx,%ecx
  800db3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800db7:	89 df                	mov    %ebx,%edi
  800db9:	d3 ef                	shr    %cl,%edi
  800dbb:	89 c1                	mov    %eax,%ecx
  800dbd:	89 f0                	mov    %esi,%eax
  800dbf:	d3 e3                	shl    %cl,%ebx
  800dc1:	89 d1                	mov    %edx,%ecx
  800dc3:	89 fa                	mov    %edi,%edx
  800dc5:	d3 e8                	shr    %cl,%eax
  800dc7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800dcc:	09 d8                	or     %ebx,%eax
  800dce:	f7 f5                	div    %ebp
  800dd0:	d3 e6                	shl    %cl,%esi
  800dd2:	89 d1                	mov    %edx,%ecx
  800dd4:	f7 64 24 08          	mull   0x8(%esp)
  800dd8:	39 d1                	cmp    %edx,%ecx
  800dda:	89 c3                	mov    %eax,%ebx
  800ddc:	89 d7                	mov    %edx,%edi
  800dde:	72 06                	jb     800de6 <__umoddi3+0xa6>
  800de0:	75 0e                	jne    800df0 <__umoddi3+0xb0>
  800de2:	39 c6                	cmp    %eax,%esi
  800de4:	73 0a                	jae    800df0 <__umoddi3+0xb0>
  800de6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800dea:	19 ea                	sbb    %ebp,%edx
  800dec:	89 d7                	mov    %edx,%edi
  800dee:	89 c3                	mov    %eax,%ebx
  800df0:	89 ca                	mov    %ecx,%edx
  800df2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800df7:	29 de                	sub    %ebx,%esi
  800df9:	19 fa                	sbb    %edi,%edx
  800dfb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800dff:	89 d0                	mov    %edx,%eax
  800e01:	d3 e0                	shl    %cl,%eax
  800e03:	89 d9                	mov    %ebx,%ecx
  800e05:	d3 ee                	shr    %cl,%esi
  800e07:	d3 ea                	shr    %cl,%edx
  800e09:	09 f0                	or     %esi,%eax
  800e0b:	83 c4 1c             	add    $0x1c,%esp
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5f                   	pop    %edi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    
  800e13:	90                   	nop
  800e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e18:	85 ff                	test   %edi,%edi
  800e1a:	89 f9                	mov    %edi,%ecx
  800e1c:	75 0b                	jne    800e29 <__umoddi3+0xe9>
  800e1e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e23:	31 d2                	xor    %edx,%edx
  800e25:	f7 f7                	div    %edi
  800e27:	89 c1                	mov    %eax,%ecx
  800e29:	89 d8                	mov    %ebx,%eax
  800e2b:	31 d2                	xor    %edx,%edx
  800e2d:	f7 f1                	div    %ecx
  800e2f:	89 f0                	mov    %esi,%eax
  800e31:	f7 f1                	div    %ecx
  800e33:	e9 31 ff ff ff       	jmp    800d69 <__umoddi3+0x29>
  800e38:	90                   	nop
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	39 dd                	cmp    %ebx,%ebp
  800e42:	72 08                	jb     800e4c <__umoddi3+0x10c>
  800e44:	39 f7                	cmp    %esi,%edi
  800e46:	0f 87 21 ff ff ff    	ja     800d6d <__umoddi3+0x2d>
  800e4c:	89 da                	mov    %ebx,%edx
  800e4e:	89 f0                	mov    %esi,%eax
  800e50:	29 f8                	sub    %edi,%eax
  800e52:	19 ea                	sbb    %ebp,%edx
  800e54:	e9 14 ff ff ff       	jmp    800d6d <__umoddi3+0x2d>
