
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	53                   	push   %ebx
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	e8 3b 00 00 00       	call   800085 <__x86.get_pc_thunk.bx>
  80004a:	81 c3 b6 1f 00 00    	add    $0x1fb6,%ebx
  800050:	8b 45 08             	mov    0x8(%ebp),%eax
  800053:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800056:	c7 c1 2c 20 80 00    	mov    $0x80202c,%ecx
  80005c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800062:	85 c0                	test   %eax,%eax
  800064:	7e 08                	jle    80006e <libmain+0x30>
		binaryname = argv[0];
  800066:	8b 0a                	mov    (%edx),%ecx
  800068:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80006e:	83 ec 08             	sub    $0x8,%esp
  800071:	52                   	push   %edx
  800072:	50                   	push   %eax
  800073:	e8 bb ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800078:	e8 0c 00 00 00       	call   800089 <exit>
}
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800083:	c9                   	leave  
  800084:	c3                   	ret    

00800085 <__x86.get_pc_thunk.bx>:
  800085:	8b 1c 24             	mov    (%esp),%ebx
  800088:	c3                   	ret    

00800089 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800089:	55                   	push   %ebp
  80008a:	89 e5                	mov    %esp,%ebp
  80008c:	53                   	push   %ebx
  80008d:	83 ec 10             	sub    $0x10,%esp
  800090:	e8 f0 ff ff ff       	call   800085 <__x86.get_pc_thunk.bx>
  800095:	81 c3 6b 1f 00 00    	add    $0x1f6b,%ebx
	sys_env_destroy(0);
  80009b:	6a 00                	push   $0x0
  80009d:	e8 45 00 00 00       	call   8000e7 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 1c             	sub    $0x1c,%esp
  8000f0:	e8 66 00 00 00       	call   80015b <__x86.get_pc_thunk.ax>
  8000f5:	05 0b 1f 00 00       	add    $0x1f0b,%eax
  8000fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8000fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800102:	8b 55 08             	mov    0x8(%ebp),%edx
  800105:	b8 03 00 00 00       	mov    $0x3,%eax
  80010a:	89 cb                	mov    %ecx,%ebx
  80010c:	89 cf                	mov    %ecx,%edi
  80010e:	89 ce                	mov    %ecx,%esi
  800110:	cd 30                	int    $0x30
	if(check && ret > 0)
  800112:	85 c0                	test   %eax,%eax
  800114:	7f 08                	jg     80011e <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800116:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800119:	5b                   	pop    %ebx
  80011a:	5e                   	pop    %esi
  80011b:	5f                   	pop    %edi
  80011c:	5d                   	pop    %ebp
  80011d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	50                   	push   %eax
  800122:	6a 03                	push   $0x3
  800124:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800127:	8d 83 56 ee ff ff    	lea    -0x11aa(%ebx),%eax
  80012d:	50                   	push   %eax
  80012e:	6a 23                	push   $0x23
  800130:	8d 83 73 ee ff ff    	lea    -0x118d(%ebx),%eax
  800136:	50                   	push   %eax
  800137:	e8 23 00 00 00       	call   80015f <_panic>

0080013c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	57                   	push   %edi
  800140:	56                   	push   %esi
  800141:	53                   	push   %ebx
	asm volatile("int %1\n"
  800142:	ba 00 00 00 00       	mov    $0x0,%edx
  800147:	b8 02 00 00 00       	mov    $0x2,%eax
  80014c:	89 d1                	mov    %edx,%ecx
  80014e:	89 d3                	mov    %edx,%ebx
  800150:	89 d7                	mov    %edx,%edi
  800152:	89 d6                	mov    %edx,%esi
  800154:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <__x86.get_pc_thunk.ax>:
  80015b:	8b 04 24             	mov    (%esp),%eax
  80015e:	c3                   	ret    

0080015f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	83 ec 0c             	sub    $0xc,%esp
  800168:	e8 18 ff ff ff       	call   800085 <__x86.get_pc_thunk.bx>
  80016d:	81 c3 93 1e 00 00    	add    $0x1e93,%ebx
	va_list ap;

	va_start(ap, fmt);
  800173:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800176:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  80017c:	8b 38                	mov    (%eax),%edi
  80017e:	e8 b9 ff ff ff       	call   80013c <sys_getenvid>
  800183:	83 ec 0c             	sub    $0xc,%esp
  800186:	ff 75 0c             	pushl  0xc(%ebp)
  800189:	ff 75 08             	pushl  0x8(%ebp)
  80018c:	57                   	push   %edi
  80018d:	50                   	push   %eax
  80018e:	8d 83 84 ee ff ff    	lea    -0x117c(%ebx),%eax
  800194:	50                   	push   %eax
  800195:	e8 d1 00 00 00       	call   80026b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019a:	83 c4 18             	add    $0x18,%esp
  80019d:	56                   	push   %esi
  80019e:	ff 75 10             	pushl  0x10(%ebp)
  8001a1:	e8 63 00 00 00       	call   800209 <vcprintf>
	cprintf("\n");
  8001a6:	8d 83 a8 ee ff ff    	lea    -0x1158(%ebx),%eax
  8001ac:	89 04 24             	mov    %eax,(%esp)
  8001af:	e8 b7 00 00 00       	call   80026b <cprintf>
  8001b4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b7:	cc                   	int3   
  8001b8:	eb fd                	jmp    8001b7 <_panic+0x58>

008001ba <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ba:	55                   	push   %ebp
  8001bb:	89 e5                	mov    %esp,%ebp
  8001bd:	56                   	push   %esi
  8001be:	53                   	push   %ebx
  8001bf:	e8 c1 fe ff ff       	call   800085 <__x86.get_pc_thunk.bx>
  8001c4:	81 c3 3c 1e 00 00    	add    $0x1e3c,%ebx
  8001ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001cd:	8b 16                	mov    (%esi),%edx
  8001cf:	8d 42 01             	lea    0x1(%edx),%eax
  8001d2:	89 06                	mov    %eax,(%esi)
  8001d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d7:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001db:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e0:	74 0b                	je     8001ed <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001e2:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e9:	5b                   	pop    %ebx
  8001ea:	5e                   	pop    %esi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	68 ff 00 00 00       	push   $0xff
  8001f5:	8d 46 08             	lea    0x8(%esi),%eax
  8001f8:	50                   	push   %eax
  8001f9:	e8 ac fe ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  8001fe:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800204:	83 c4 10             	add    $0x10,%esp
  800207:	eb d9                	jmp    8001e2 <putch+0x28>

00800209 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	53                   	push   %ebx
  80020d:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800213:	e8 6d fe ff ff       	call   800085 <__x86.get_pc_thunk.bx>
  800218:	81 c3 e8 1d 00 00    	add    $0x1de8,%ebx
	struct printbuf b;

	b.idx = 0;
  80021e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800225:	00 00 00 
	b.cnt = 0;
  800228:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800232:	ff 75 0c             	pushl  0xc(%ebp)
  800235:	ff 75 08             	pushl  0x8(%ebp)
  800238:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023e:	50                   	push   %eax
  80023f:	8d 83 ba e1 ff ff    	lea    -0x1e46(%ebx),%eax
  800245:	50                   	push   %eax
  800246:	e8 38 01 00 00       	call   800383 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024b:	83 c4 08             	add    $0x8,%esp
  80024e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800254:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025a:	50                   	push   %eax
  80025b:	e8 4a fe ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  800260:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800266:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800271:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800274:	50                   	push   %eax
  800275:	ff 75 08             	pushl  0x8(%ebp)
  800278:	e8 8c ff ff ff       	call   800209 <vcprintf>
	va_end(ap);

	return cnt;
}
  80027d:	c9                   	leave  
  80027e:	c3                   	ret    

0080027f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	57                   	push   %edi
  800283:	56                   	push   %esi
  800284:	53                   	push   %ebx
  800285:	83 ec 2c             	sub    $0x2c,%esp
  800288:	e8 02 06 00 00       	call   80088f <__x86.get_pc_thunk.cx>
  80028d:	81 c1 73 1d 00 00    	add    $0x1d73,%ecx
  800293:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800296:	89 c7                	mov    %eax,%edi
  800298:	89 d6                	mov    %edx,%esi
  80029a:	8b 45 08             	mov    0x8(%ebp),%eax
  80029d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002a3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  8002a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002b1:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002b4:	39 d3                	cmp    %edx,%ebx
  8002b6:	72 09                	jb     8002c1 <printnum+0x42>
  8002b8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002bb:	0f 87 83 00 00 00    	ja     800344 <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c1:	83 ec 0c             	sub    $0xc,%esp
  8002c4:	ff 75 18             	pushl  0x18(%ebp)
  8002c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ca:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002cd:	53                   	push   %ebx
  8002ce:	ff 75 10             	pushl  0x10(%ebp)
  8002d1:	83 ec 08             	sub    $0x8,%esp
  8002d4:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d7:	ff 75 d8             	pushl  -0x28(%ebp)
  8002da:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002dd:	ff 75 d0             	pushl  -0x30(%ebp)
  8002e0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002e3:	e8 28 09 00 00       	call   800c10 <__udivdi3>
  8002e8:	83 c4 18             	add    $0x18,%esp
  8002eb:	52                   	push   %edx
  8002ec:	50                   	push   %eax
  8002ed:	89 f2                	mov    %esi,%edx
  8002ef:	89 f8                	mov    %edi,%eax
  8002f1:	e8 89 ff ff ff       	call   80027f <printnum>
  8002f6:	83 c4 20             	add    $0x20,%esp
  8002f9:	eb 13                	jmp    80030e <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002fb:	83 ec 08             	sub    $0x8,%esp
  8002fe:	56                   	push   %esi
  8002ff:	ff 75 18             	pushl  0x18(%ebp)
  800302:	ff d7                	call   *%edi
  800304:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800307:	83 eb 01             	sub    $0x1,%ebx
  80030a:	85 db                	test   %ebx,%ebx
  80030c:	7f ed                	jg     8002fb <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030e:	83 ec 08             	sub    $0x8,%esp
  800311:	56                   	push   %esi
  800312:	83 ec 04             	sub    $0x4,%esp
  800315:	ff 75 dc             	pushl  -0x24(%ebp)
  800318:	ff 75 d8             	pushl  -0x28(%ebp)
  80031b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80031e:	ff 75 d0             	pushl  -0x30(%ebp)
  800321:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800324:	89 f3                	mov    %esi,%ebx
  800326:	e8 05 0a 00 00       	call   800d30 <__umoddi3>
  80032b:	83 c4 14             	add    $0x14,%esp
  80032e:	0f be 84 06 aa ee ff 	movsbl -0x1156(%esi,%eax,1),%eax
  800335:	ff 
  800336:	50                   	push   %eax
  800337:	ff d7                	call   *%edi
}
  800339:	83 c4 10             	add    $0x10,%esp
  80033c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033f:	5b                   	pop    %ebx
  800340:	5e                   	pop    %esi
  800341:	5f                   	pop    %edi
  800342:	5d                   	pop    %ebp
  800343:	c3                   	ret    
  800344:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800347:	eb be                	jmp    800307 <printnum+0x88>

00800349 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80034f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800353:	8b 10                	mov    (%eax),%edx
  800355:	3b 50 04             	cmp    0x4(%eax),%edx
  800358:	73 0a                	jae    800364 <sprintputch+0x1b>
		*b->buf++ = ch;
  80035a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80035d:	89 08                	mov    %ecx,(%eax)
  80035f:	8b 45 08             	mov    0x8(%ebp),%eax
  800362:	88 02                	mov    %al,(%edx)
}
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <printfmt>:
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80036c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80036f:	50                   	push   %eax
  800370:	ff 75 10             	pushl  0x10(%ebp)
  800373:	ff 75 0c             	pushl  0xc(%ebp)
  800376:	ff 75 08             	pushl  0x8(%ebp)
  800379:	e8 05 00 00 00       	call   800383 <vprintfmt>
}
  80037e:	83 c4 10             	add    $0x10,%esp
  800381:	c9                   	leave  
  800382:	c3                   	ret    

00800383 <vprintfmt>:
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	57                   	push   %edi
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	83 ec 2c             	sub    $0x2c,%esp
  80038c:	e8 f4 fc ff ff       	call   800085 <__x86.get_pc_thunk.bx>
  800391:	81 c3 6f 1c 00 00    	add    $0x1c6f,%ebx
  800397:	8b 75 0c             	mov    0xc(%ebp),%esi
  80039a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80039d:	e9 c3 03 00 00       	jmp    800765 <.L35+0x48>
		padc = ' ';
  8003a2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003a6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003ad:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003b4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8003c3:	8d 47 01             	lea    0x1(%edi),%eax
  8003c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c9:	0f b6 17             	movzbl (%edi),%edx
  8003cc:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003cf:	3c 55                	cmp    $0x55,%al
  8003d1:	0f 87 16 04 00 00    	ja     8007ed <.L22>
  8003d7:	0f b6 c0             	movzbl %al,%eax
  8003da:	89 d9                	mov    %ebx,%ecx
  8003dc:	03 8c 83 38 ef ff ff 	add    -0x10c8(%ebx,%eax,4),%ecx
  8003e3:	ff e1                	jmp    *%ecx

008003e5 <.L69>:
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003e8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003ec:	eb d5                	jmp    8003c3 <vprintfmt+0x40>

008003ee <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8003f1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f5:	eb cc                	jmp    8003c3 <vprintfmt+0x40>

008003f7 <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8003f7:	0f b6 d2             	movzbl %dl,%edx
  8003fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
  8003fd:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800402:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800405:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800409:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80040c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80040f:	83 f9 09             	cmp    $0x9,%ecx
  800412:	77 55                	ja     800469 <.L23+0xf>
			for (precision = 0;; ++fmt)
  800414:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800417:	eb e9                	jmp    800402 <.L29+0xb>

00800419 <.L26>:
			precision = va_arg(ap, int);
  800419:	8b 45 14             	mov    0x14(%ebp),%eax
  80041c:	8b 00                	mov    (%eax),%eax
  80041e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800421:	8b 45 14             	mov    0x14(%ebp),%eax
  800424:	8d 40 04             	lea    0x4(%eax),%eax
  800427:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80042d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800431:	79 90                	jns    8003c3 <vprintfmt+0x40>
				width = precision, precision = -1;
  800433:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800436:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800439:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800440:	eb 81                	jmp    8003c3 <vprintfmt+0x40>

00800442 <.L27>:
  800442:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800445:	85 c0                	test   %eax,%eax
  800447:	ba 00 00 00 00       	mov    $0x0,%edx
  80044c:	0f 49 d0             	cmovns %eax,%edx
  80044f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800452:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800455:	e9 69 ff ff ff       	jmp    8003c3 <vprintfmt+0x40>

0080045a <.L23>:
  80045a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80045d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800464:	e9 5a ff ff ff       	jmp    8003c3 <vprintfmt+0x40>
  800469:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80046c:	eb bf                	jmp    80042d <.L26+0x14>

0080046e <.L33>:
			lflag++;
  80046e:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800472:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800475:	e9 49 ff ff ff       	jmp    8003c3 <vprintfmt+0x40>

0080047a <.L30>:
			putch(va_arg(ap, int), putdat);
  80047a:	8b 45 14             	mov    0x14(%ebp),%eax
  80047d:	8d 78 04             	lea    0x4(%eax),%edi
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	56                   	push   %esi
  800484:	ff 30                	pushl  (%eax)
  800486:	ff 55 08             	call   *0x8(%ebp)
			break;
  800489:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80048c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80048f:	e9 ce 02 00 00       	jmp    800762 <.L35+0x45>

00800494 <.L32>:
			err = va_arg(ap, int);
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	8d 78 04             	lea    0x4(%eax),%edi
  80049a:	8b 00                	mov    (%eax),%eax
  80049c:	99                   	cltd   
  80049d:	31 d0                	xor    %edx,%eax
  80049f:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a1:	83 f8 06             	cmp    $0x6,%eax
  8004a4:	7f 27                	jg     8004cd <.L32+0x39>
  8004a6:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004ad:	85 d2                	test   %edx,%edx
  8004af:	74 1c                	je     8004cd <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004b1:	52                   	push   %edx
  8004b2:	8d 83 cb ee ff ff    	lea    -0x1135(%ebx),%eax
  8004b8:	50                   	push   %eax
  8004b9:	56                   	push   %esi
  8004ba:	ff 75 08             	pushl  0x8(%ebp)
  8004bd:	e8 a4 fe ff ff       	call   800366 <printfmt>
  8004c2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004c5:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004c8:	e9 95 02 00 00       	jmp    800762 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004cd:	50                   	push   %eax
  8004ce:	8d 83 c2 ee ff ff    	lea    -0x113e(%ebx),%eax
  8004d4:	50                   	push   %eax
  8004d5:	56                   	push   %esi
  8004d6:	ff 75 08             	pushl  0x8(%ebp)
  8004d9:	e8 88 fe ff ff       	call   800366 <printfmt>
  8004de:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004e1:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004e4:	e9 79 02 00 00       	jmp    800762 <.L35+0x45>

008004e9 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  8004e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ec:	83 c0 04             	add    $0x4,%eax
  8004ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004f7:	85 ff                	test   %edi,%edi
  8004f9:	8d 83 bb ee ff ff    	lea    -0x1145(%ebx),%eax
  8004ff:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800502:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800506:	0f 8e b5 00 00 00    	jle    8005c1 <.L36+0xd8>
  80050c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800510:	75 08                	jne    80051a <.L36+0x31>
  800512:	89 75 0c             	mov    %esi,0xc(%ebp)
  800515:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800518:	eb 6d                	jmp    800587 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	ff 75 cc             	pushl  -0x34(%ebp)
  800520:	57                   	push   %edi
  800521:	e8 85 03 00 00       	call   8008ab <strnlen>
  800526:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800529:	29 c2                	sub    %eax,%edx
  80052b:	89 55 c8             	mov    %edx,-0x38(%ebp)
  80052e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800531:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800535:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800538:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80053b:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80053d:	eb 10                	jmp    80054f <.L36+0x66>
					putch(padc, putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	56                   	push   %esi
  800543:	ff 75 e0             	pushl  -0x20(%ebp)
  800546:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800549:	83 ef 01             	sub    $0x1,%edi
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	85 ff                	test   %edi,%edi
  800551:	7f ec                	jg     80053f <.L36+0x56>
  800553:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800556:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800559:	85 d2                	test   %edx,%edx
  80055b:	b8 00 00 00 00       	mov    $0x0,%eax
  800560:	0f 49 c2             	cmovns %edx,%eax
  800563:	29 c2                	sub    %eax,%edx
  800565:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800568:	89 75 0c             	mov    %esi,0xc(%ebp)
  80056b:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80056e:	eb 17                	jmp    800587 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  800570:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800574:	75 30                	jne    8005a6 <.L36+0xbd>
					putch(ch, putdat);
  800576:	83 ec 08             	sub    $0x8,%esp
  800579:	ff 75 0c             	pushl  0xc(%ebp)
  80057c:	50                   	push   %eax
  80057d:	ff 55 08             	call   *0x8(%ebp)
  800580:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800583:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800587:	83 c7 01             	add    $0x1,%edi
  80058a:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80058e:	0f be c2             	movsbl %dl,%eax
  800591:	85 c0                	test   %eax,%eax
  800593:	74 52                	je     8005e7 <.L36+0xfe>
  800595:	85 f6                	test   %esi,%esi
  800597:	78 d7                	js     800570 <.L36+0x87>
  800599:	83 ee 01             	sub    $0x1,%esi
  80059c:	79 d2                	jns    800570 <.L36+0x87>
  80059e:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005a1:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005a4:	eb 32                	jmp    8005d8 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005a6:	0f be d2             	movsbl %dl,%edx
  8005a9:	83 ea 20             	sub    $0x20,%edx
  8005ac:	83 fa 5e             	cmp    $0x5e,%edx
  8005af:	76 c5                	jbe    800576 <.L36+0x8d>
					putch('?', putdat);
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	ff 75 0c             	pushl  0xc(%ebp)
  8005b7:	6a 3f                	push   $0x3f
  8005b9:	ff 55 08             	call   *0x8(%ebp)
  8005bc:	83 c4 10             	add    $0x10,%esp
  8005bf:	eb c2                	jmp    800583 <.L36+0x9a>
  8005c1:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005c4:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005c7:	eb be                	jmp    800587 <.L36+0x9e>
				putch(' ', putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	56                   	push   %esi
  8005cd:	6a 20                	push   $0x20
  8005cf:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8005d2:	83 ef 01             	sub    $0x1,%edi
  8005d5:	83 c4 10             	add    $0x10,%esp
  8005d8:	85 ff                	test   %edi,%edi
  8005da:	7f ed                	jg     8005c9 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  8005dc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005df:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e2:	e9 7b 01 00 00       	jmp    800762 <.L35+0x45>
  8005e7:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005ea:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005ed:	eb e9                	jmp    8005d8 <.L36+0xef>

008005ef <.L31>:
  8005ef:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8005f2:	83 f9 01             	cmp    $0x1,%ecx
  8005f5:	7e 40                	jle    800637 <.L31+0x48>
		return va_arg(*ap, long long);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8b 50 04             	mov    0x4(%eax),%edx
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800602:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8d 40 08             	lea    0x8(%eax),%eax
  80060b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
  80060e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800612:	79 55                	jns    800669 <.L31+0x7a>
				putch('-', putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	56                   	push   %esi
  800618:	6a 2d                	push   $0x2d
  80061a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  80061d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800620:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800623:	f7 da                	neg    %edx
  800625:	83 d1 00             	adc    $0x0,%ecx
  800628:	f7 d9                	neg    %ecx
  80062a:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
  80062d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800632:	e9 10 01 00 00       	jmp    800747 <.L35+0x2a>
	else if (lflag)
  800637:	85 c9                	test   %ecx,%ecx
  800639:	75 17                	jne    800652 <.L31+0x63>
		return va_arg(*ap, int);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8b 00                	mov    (%eax),%eax
  800640:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800643:	99                   	cltd   
  800644:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8d 40 04             	lea    0x4(%eax),%eax
  80064d:	89 45 14             	mov    %eax,0x14(%ebp)
  800650:	eb bc                	jmp    80060e <.L31+0x1f>
		return va_arg(*ap, long);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8b 00                	mov    (%eax),%eax
  800657:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065a:	99                   	cltd   
  80065b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 40 04             	lea    0x4(%eax),%eax
  800664:	89 45 14             	mov    %eax,0x14(%ebp)
  800667:	eb a5                	jmp    80060e <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  800669:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80066c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
  80066f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800674:	e9 ce 00 00 00       	jmp    800747 <.L35+0x2a>

00800679 <.L37>:
  800679:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80067c:	83 f9 01             	cmp    $0x1,%ecx
  80067f:	7e 18                	jle    800699 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 10                	mov    (%eax),%edx
  800686:	8b 48 04             	mov    0x4(%eax),%ecx
  800689:	8d 40 08             	lea    0x8(%eax),%eax
  80068c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80068f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800694:	e9 ae 00 00 00       	jmp    800747 <.L35+0x2a>
	else if (lflag)
  800699:	85 c9                	test   %ecx,%ecx
  80069b:	75 1a                	jne    8006b7 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8b 10                	mov    (%eax),%edx
  8006a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a7:	8d 40 04             	lea    0x4(%eax),%eax
  8006aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b2:	e9 90 00 00 00       	jmp    800747 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8b 10                	mov    (%eax),%edx
  8006bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c1:	8d 40 04             	lea    0x4(%eax),%eax
  8006c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006cc:	eb 79                	jmp    800747 <.L35+0x2a>

008006ce <.L34>:
  8006ce:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006d1:	83 f9 01             	cmp    $0x1,%ecx
  8006d4:	7e 15                	jle    8006eb <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8b 10                	mov    (%eax),%edx
  8006db:	8b 48 04             	mov    0x4(%eax),%ecx
  8006de:	8d 40 08             	lea    0x8(%eax),%eax
  8006e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006e4:	b8 08 00 00 00       	mov    $0x8,%eax
  8006e9:	eb 5c                	jmp    800747 <.L35+0x2a>
	else if (lflag)
  8006eb:	85 c9                	test   %ecx,%ecx
  8006ed:	75 17                	jne    800706 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8b 10                	mov    (%eax),%edx
  8006f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f9:	8d 40 04             	lea    0x4(%eax),%eax
  8006fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006ff:	b8 08 00 00 00       	mov    $0x8,%eax
  800704:	eb 41                	jmp    800747 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8b 10                	mov    (%eax),%edx
  80070b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800710:	8d 40 04             	lea    0x4(%eax),%eax
  800713:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800716:	b8 08 00 00 00       	mov    $0x8,%eax
  80071b:	eb 2a                	jmp    800747 <.L35+0x2a>

0080071d <.L35>:
			putch('0', putdat);
  80071d:	83 ec 08             	sub    $0x8,%esp
  800720:	56                   	push   %esi
  800721:	6a 30                	push   $0x30
  800723:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800726:	83 c4 08             	add    $0x8,%esp
  800729:	56                   	push   %esi
  80072a:	6a 78                	push   $0x78
  80072c:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80072f:	8b 45 14             	mov    0x14(%ebp),%eax
  800732:	8b 10                	mov    (%eax),%edx
  800734:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800739:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80073c:	8d 40 04             	lea    0x4(%eax),%eax
  80073f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800742:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  800747:	83 ec 0c             	sub    $0xc,%esp
  80074a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80074e:	57                   	push   %edi
  80074f:	ff 75 e0             	pushl  -0x20(%ebp)
  800752:	50                   	push   %eax
  800753:	51                   	push   %ecx
  800754:	52                   	push   %edx
  800755:	89 f2                	mov    %esi,%edx
  800757:	8b 45 08             	mov    0x8(%ebp),%eax
  80075a:	e8 20 fb ff ff       	call   80027f <printnum>
			break;
  80075f:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800762:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  800765:	83 c7 01             	add    $0x1,%edi
  800768:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80076c:	83 f8 25             	cmp    $0x25,%eax
  80076f:	0f 84 2d fc ff ff    	je     8003a2 <vprintfmt+0x1f>
			if (ch == '\0')
  800775:	85 c0                	test   %eax,%eax
  800777:	0f 84 91 00 00 00    	je     80080e <.L22+0x21>
			putch(ch, putdat);
  80077d:	83 ec 08             	sub    $0x8,%esp
  800780:	56                   	push   %esi
  800781:	50                   	push   %eax
  800782:	ff 55 08             	call   *0x8(%ebp)
  800785:	83 c4 10             	add    $0x10,%esp
  800788:	eb db                	jmp    800765 <.L35+0x48>

0080078a <.L38>:
  80078a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80078d:	83 f9 01             	cmp    $0x1,%ecx
  800790:	7e 15                	jle    8007a7 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	8b 10                	mov    (%eax),%edx
  800797:	8b 48 04             	mov    0x4(%eax),%ecx
  80079a:	8d 40 08             	lea    0x8(%eax),%eax
  80079d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a0:	b8 10 00 00 00       	mov    $0x10,%eax
  8007a5:	eb a0                	jmp    800747 <.L35+0x2a>
	else if (lflag)
  8007a7:	85 c9                	test   %ecx,%ecx
  8007a9:	75 17                	jne    8007c2 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8b 10                	mov    (%eax),%edx
  8007b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b5:	8d 40 04             	lea    0x4(%eax),%eax
  8007b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007bb:	b8 10 00 00 00       	mov    $0x10,%eax
  8007c0:	eb 85                	jmp    800747 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c5:	8b 10                	mov    (%eax),%edx
  8007c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007cc:	8d 40 04             	lea    0x4(%eax),%eax
  8007cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d2:	b8 10 00 00 00       	mov    $0x10,%eax
  8007d7:	e9 6b ff ff ff       	jmp    800747 <.L35+0x2a>

008007dc <.L25>:
			putch(ch, putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	56                   	push   %esi
  8007e0:	6a 25                	push   $0x25
  8007e2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	e9 75 ff ff ff       	jmp    800762 <.L35+0x45>

008007ed <.L22>:
			putch('%', putdat);
  8007ed:	83 ec 08             	sub    $0x8,%esp
  8007f0:	56                   	push   %esi
  8007f1:	6a 25                	push   $0x25
  8007f3:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f6:	83 c4 10             	add    $0x10,%esp
  8007f9:	89 f8                	mov    %edi,%eax
  8007fb:	eb 03                	jmp    800800 <.L22+0x13>
  8007fd:	83 e8 01             	sub    $0x1,%eax
  800800:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800804:	75 f7                	jne    8007fd <.L22+0x10>
  800806:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800809:	e9 54 ff ff ff       	jmp    800762 <.L35+0x45>
}
  80080e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800811:	5b                   	pop    %ebx
  800812:	5e                   	pop    %esi
  800813:	5f                   	pop    %edi
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	53                   	push   %ebx
  80081a:	83 ec 14             	sub    $0x14,%esp
  80081d:	e8 63 f8 ff ff       	call   800085 <__x86.get_pc_thunk.bx>
  800822:	81 c3 de 17 00 00    	add    $0x17de,%ebx
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  80082e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800831:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800835:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800838:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083f:	85 c0                	test   %eax,%eax
  800841:	74 2b                	je     80086e <vsnprintf+0x58>
  800843:	85 d2                	test   %edx,%edx
  800845:	7e 27                	jle    80086e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  800847:	ff 75 14             	pushl  0x14(%ebp)
  80084a:	ff 75 10             	pushl  0x10(%ebp)
  80084d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800850:	50                   	push   %eax
  800851:	8d 83 49 e3 ff ff    	lea    -0x1cb7(%ebx),%eax
  800857:	50                   	push   %eax
  800858:	e8 26 fb ff ff       	call   800383 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80085d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800860:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800863:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800866:	83 c4 10             	add    $0x10,%esp
}
  800869:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086c:	c9                   	leave  
  80086d:	c3                   	ret    
		return -E_INVAL;
  80086e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800873:	eb f4                	jmp    800869 <vsnprintf+0x53>

00800875 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80087b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80087e:	50                   	push   %eax
  80087f:	ff 75 10             	pushl  0x10(%ebp)
  800882:	ff 75 0c             	pushl  0xc(%ebp)
  800885:	ff 75 08             	pushl  0x8(%ebp)
  800888:	e8 89 ff ff ff       	call   800816 <vsnprintf>
	va_end(ap);

	return rc;
}
  80088d:	c9                   	leave  
  80088e:	c3                   	ret    

0080088f <__x86.get_pc_thunk.cx>:
  80088f:	8b 0c 24             	mov    (%esp),%ecx
  800892:	c3                   	ret    

00800893 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
  80089e:	eb 03                	jmp    8008a3 <strlen+0x10>
		n++;
  8008a0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a7:	75 f7                	jne    8008a0 <strlen+0xd>
	return n;
}
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b9:	eb 03                	jmp    8008be <strnlen+0x13>
		n++;
  8008bb:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008be:	39 d0                	cmp    %edx,%eax
  8008c0:	74 06                	je     8008c8 <strnlen+0x1d>
  8008c2:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008c6:	75 f3                	jne    8008bb <strnlen+0x10>
	return n;
}
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	53                   	push   %ebx
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d4:	89 c2                	mov    %eax,%edx
  8008d6:	83 c1 01             	add    $0x1,%ecx
  8008d9:	83 c2 01             	add    $0x1,%edx
  8008dc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008e0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008e3:	84 db                	test   %bl,%bl
  8008e5:	75 ef                	jne    8008d6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008e7:	5b                   	pop    %ebx
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	53                   	push   %ebx
  8008ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008f1:	53                   	push   %ebx
  8008f2:	e8 9c ff ff ff       	call   800893 <strlen>
  8008f7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008fa:	ff 75 0c             	pushl  0xc(%ebp)
  8008fd:	01 d8                	add    %ebx,%eax
  8008ff:	50                   	push   %eax
  800900:	e8 c5 ff ff ff       	call   8008ca <strcpy>
	return dst;
}
  800905:	89 d8                	mov    %ebx,%eax
  800907:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80090a:	c9                   	leave  
  80090b:	c3                   	ret    

0080090c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	56                   	push   %esi
  800910:	53                   	push   %ebx
  800911:	8b 75 08             	mov    0x8(%ebp),%esi
  800914:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800917:	89 f3                	mov    %esi,%ebx
  800919:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80091c:	89 f2                	mov    %esi,%edx
  80091e:	eb 0f                	jmp    80092f <strncpy+0x23>
		*dst++ = *src;
  800920:	83 c2 01             	add    $0x1,%edx
  800923:	0f b6 01             	movzbl (%ecx),%eax
  800926:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800929:	80 39 01             	cmpb   $0x1,(%ecx)
  80092c:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80092f:	39 da                	cmp    %ebx,%edx
  800931:	75 ed                	jne    800920 <strncpy+0x14>
	}
	return ret;
}
  800933:	89 f0                	mov    %esi,%eax
  800935:	5b                   	pop    %ebx
  800936:	5e                   	pop    %esi
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	56                   	push   %esi
  80093d:	53                   	push   %ebx
  80093e:	8b 75 08             	mov    0x8(%ebp),%esi
  800941:	8b 55 0c             	mov    0xc(%ebp),%edx
  800944:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800947:	89 f0                	mov    %esi,%eax
  800949:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80094d:	85 c9                	test   %ecx,%ecx
  80094f:	75 0b                	jne    80095c <strlcpy+0x23>
  800951:	eb 17                	jmp    80096a <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800953:	83 c2 01             	add    $0x1,%edx
  800956:	83 c0 01             	add    $0x1,%eax
  800959:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80095c:	39 d8                	cmp    %ebx,%eax
  80095e:	74 07                	je     800967 <strlcpy+0x2e>
  800960:	0f b6 0a             	movzbl (%edx),%ecx
  800963:	84 c9                	test   %cl,%cl
  800965:	75 ec                	jne    800953 <strlcpy+0x1a>
		*dst = '\0';
  800967:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80096a:	29 f0                	sub    %esi,%eax
}
  80096c:	5b                   	pop    %ebx
  80096d:	5e                   	pop    %esi
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800976:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800979:	eb 06                	jmp    800981 <strcmp+0x11>
		p++, q++;
  80097b:	83 c1 01             	add    $0x1,%ecx
  80097e:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800981:	0f b6 01             	movzbl (%ecx),%eax
  800984:	84 c0                	test   %al,%al
  800986:	74 04                	je     80098c <strcmp+0x1c>
  800988:	3a 02                	cmp    (%edx),%al
  80098a:	74 ef                	je     80097b <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80098c:	0f b6 c0             	movzbl %al,%eax
  80098f:	0f b6 12             	movzbl (%edx),%edx
  800992:	29 d0                	sub    %edx,%eax
}
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	53                   	push   %ebx
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a0:	89 c3                	mov    %eax,%ebx
  8009a2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009a5:	eb 06                	jmp    8009ad <strncmp+0x17>
		n--, p++, q++;
  8009a7:	83 c0 01             	add    $0x1,%eax
  8009aa:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009ad:	39 d8                	cmp    %ebx,%eax
  8009af:	74 16                	je     8009c7 <strncmp+0x31>
  8009b1:	0f b6 08             	movzbl (%eax),%ecx
  8009b4:	84 c9                	test   %cl,%cl
  8009b6:	74 04                	je     8009bc <strncmp+0x26>
  8009b8:	3a 0a                	cmp    (%edx),%cl
  8009ba:	74 eb                	je     8009a7 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009bc:	0f b6 00             	movzbl (%eax),%eax
  8009bf:	0f b6 12             	movzbl (%edx),%edx
  8009c2:	29 d0                	sub    %edx,%eax
}
  8009c4:	5b                   	pop    %ebx
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    
		return 0;
  8009c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cc:	eb f6                	jmp    8009c4 <strncmp+0x2e>

008009ce <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d8:	0f b6 10             	movzbl (%eax),%edx
  8009db:	84 d2                	test   %dl,%dl
  8009dd:	74 09                	je     8009e8 <strchr+0x1a>
		if (*s == c)
  8009df:	38 ca                	cmp    %cl,%dl
  8009e1:	74 0a                	je     8009ed <strchr+0x1f>
	for (; *s; s++)
  8009e3:	83 c0 01             	add    $0x1,%eax
  8009e6:	eb f0                	jmp    8009d8 <strchr+0xa>
			return (char *) s;
	return 0;
  8009e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f9:	eb 03                	jmp    8009fe <strfind+0xf>
  8009fb:	83 c0 01             	add    $0x1,%eax
  8009fe:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a01:	38 ca                	cmp    %cl,%dl
  800a03:	74 04                	je     800a09 <strfind+0x1a>
  800a05:	84 d2                	test   %dl,%dl
  800a07:	75 f2                	jne    8009fb <strfind+0xc>
			break;
	return (char *) s;
}
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	57                   	push   %edi
  800a0f:	56                   	push   %esi
  800a10:	53                   	push   %ebx
  800a11:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a14:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a17:	85 c9                	test   %ecx,%ecx
  800a19:	74 13                	je     800a2e <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a1b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a21:	75 05                	jne    800a28 <memset+0x1d>
  800a23:	f6 c1 03             	test   $0x3,%cl
  800a26:	74 0d                	je     800a35 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2b:	fc                   	cld    
  800a2c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2e:	89 f8                	mov    %edi,%eax
  800a30:	5b                   	pop    %ebx
  800a31:	5e                   	pop    %esi
  800a32:	5f                   	pop    %edi
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    
		c &= 0xFF;
  800a35:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a39:	89 d3                	mov    %edx,%ebx
  800a3b:	c1 e3 08             	shl    $0x8,%ebx
  800a3e:	89 d0                	mov    %edx,%eax
  800a40:	c1 e0 18             	shl    $0x18,%eax
  800a43:	89 d6                	mov    %edx,%esi
  800a45:	c1 e6 10             	shl    $0x10,%esi
  800a48:	09 f0                	or     %esi,%eax
  800a4a:	09 c2                	or     %eax,%edx
  800a4c:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a4e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a51:	89 d0                	mov    %edx,%eax
  800a53:	fc                   	cld    
  800a54:	f3 ab                	rep stos %eax,%es:(%edi)
  800a56:	eb d6                	jmp    800a2e <memset+0x23>

00800a58 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	57                   	push   %edi
  800a5c:	56                   	push   %esi
  800a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a60:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a63:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a66:	39 c6                	cmp    %eax,%esi
  800a68:	73 35                	jae    800a9f <memmove+0x47>
  800a6a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a6d:	39 c2                	cmp    %eax,%edx
  800a6f:	76 2e                	jbe    800a9f <memmove+0x47>
		s += n;
		d += n;
  800a71:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a74:	89 d6                	mov    %edx,%esi
  800a76:	09 fe                	or     %edi,%esi
  800a78:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a7e:	74 0c                	je     800a8c <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a80:	83 ef 01             	sub    $0x1,%edi
  800a83:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a86:	fd                   	std    
  800a87:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a89:	fc                   	cld    
  800a8a:	eb 21                	jmp    800aad <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8c:	f6 c1 03             	test   $0x3,%cl
  800a8f:	75 ef                	jne    800a80 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a91:	83 ef 04             	sub    $0x4,%edi
  800a94:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a97:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a9a:	fd                   	std    
  800a9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9d:	eb ea                	jmp    800a89 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9f:	89 f2                	mov    %esi,%edx
  800aa1:	09 c2                	or     %eax,%edx
  800aa3:	f6 c2 03             	test   $0x3,%dl
  800aa6:	74 09                	je     800ab1 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa8:	89 c7                	mov    %eax,%edi
  800aaa:	fc                   	cld    
  800aab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab1:	f6 c1 03             	test   $0x3,%cl
  800ab4:	75 f2                	jne    800aa8 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ab6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ab9:	89 c7                	mov    %eax,%edi
  800abb:	fc                   	cld    
  800abc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abe:	eb ed                	jmp    800aad <memmove+0x55>

00800ac0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ac3:	ff 75 10             	pushl  0x10(%ebp)
  800ac6:	ff 75 0c             	pushl  0xc(%ebp)
  800ac9:	ff 75 08             	pushl  0x8(%ebp)
  800acc:	e8 87 ff ff ff       	call   800a58 <memmove>
}
  800ad1:	c9                   	leave  
  800ad2:	c3                   	ret    

00800ad3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	56                   	push   %esi
  800ad7:	53                   	push   %ebx
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  800adb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ade:	89 c6                	mov    %eax,%esi
  800ae0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae3:	39 f0                	cmp    %esi,%eax
  800ae5:	74 1c                	je     800b03 <memcmp+0x30>
		if (*s1 != *s2)
  800ae7:	0f b6 08             	movzbl (%eax),%ecx
  800aea:	0f b6 1a             	movzbl (%edx),%ebx
  800aed:	38 d9                	cmp    %bl,%cl
  800aef:	75 08                	jne    800af9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800af1:	83 c0 01             	add    $0x1,%eax
  800af4:	83 c2 01             	add    $0x1,%edx
  800af7:	eb ea                	jmp    800ae3 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800af9:	0f b6 c1             	movzbl %cl,%eax
  800afc:	0f b6 db             	movzbl %bl,%ebx
  800aff:	29 d8                	sub    %ebx,%eax
  800b01:	eb 05                	jmp    800b08 <memcmp+0x35>
	}

	return 0;
  800b03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b15:	89 c2                	mov    %eax,%edx
  800b17:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b1a:	39 d0                	cmp    %edx,%eax
  800b1c:	73 09                	jae    800b27 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b1e:	38 08                	cmp    %cl,(%eax)
  800b20:	74 05                	je     800b27 <memfind+0x1b>
	for (; s < ends; s++)
  800b22:	83 c0 01             	add    $0x1,%eax
  800b25:	eb f3                	jmp    800b1a <memfind+0xe>
			break;
	return (void *) s;
}
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	57                   	push   %edi
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
  800b2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b35:	eb 03                	jmp    800b3a <strtol+0x11>
		s++;
  800b37:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b3a:	0f b6 01             	movzbl (%ecx),%eax
  800b3d:	3c 20                	cmp    $0x20,%al
  800b3f:	74 f6                	je     800b37 <strtol+0xe>
  800b41:	3c 09                	cmp    $0x9,%al
  800b43:	74 f2                	je     800b37 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b45:	3c 2b                	cmp    $0x2b,%al
  800b47:	74 2e                	je     800b77 <strtol+0x4e>
	int neg = 0;
  800b49:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b4e:	3c 2d                	cmp    $0x2d,%al
  800b50:	74 2f                	je     800b81 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b52:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b58:	75 05                	jne    800b5f <strtol+0x36>
  800b5a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b5d:	74 2c                	je     800b8b <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5f:	85 db                	test   %ebx,%ebx
  800b61:	75 0a                	jne    800b6d <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b63:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b68:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6b:	74 28                	je     800b95 <strtol+0x6c>
		base = 10;
  800b6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b72:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b75:	eb 50                	jmp    800bc7 <strtol+0x9e>
		s++;
  800b77:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b7a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b7f:	eb d1                	jmp    800b52 <strtol+0x29>
		s++, neg = 1;
  800b81:	83 c1 01             	add    $0x1,%ecx
  800b84:	bf 01 00 00 00       	mov    $0x1,%edi
  800b89:	eb c7                	jmp    800b52 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b8b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b8f:	74 0e                	je     800b9f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b91:	85 db                	test   %ebx,%ebx
  800b93:	75 d8                	jne    800b6d <strtol+0x44>
		s++, base = 8;
  800b95:	83 c1 01             	add    $0x1,%ecx
  800b98:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b9d:	eb ce                	jmp    800b6d <strtol+0x44>
		s += 2, base = 16;
  800b9f:	83 c1 02             	add    $0x2,%ecx
  800ba2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ba7:	eb c4                	jmp    800b6d <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ba9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bac:	89 f3                	mov    %esi,%ebx
  800bae:	80 fb 19             	cmp    $0x19,%bl
  800bb1:	77 29                	ja     800bdc <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bb3:	0f be d2             	movsbl %dl,%edx
  800bb6:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bb9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bbc:	7d 30                	jge    800bee <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bbe:	83 c1 01             	add    $0x1,%ecx
  800bc1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bc5:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bc7:	0f b6 11             	movzbl (%ecx),%edx
  800bca:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bcd:	89 f3                	mov    %esi,%ebx
  800bcf:	80 fb 09             	cmp    $0x9,%bl
  800bd2:	77 d5                	ja     800ba9 <strtol+0x80>
			dig = *s - '0';
  800bd4:	0f be d2             	movsbl %dl,%edx
  800bd7:	83 ea 30             	sub    $0x30,%edx
  800bda:	eb dd                	jmp    800bb9 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bdc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bdf:	89 f3                	mov    %esi,%ebx
  800be1:	80 fb 19             	cmp    $0x19,%bl
  800be4:	77 08                	ja     800bee <strtol+0xc5>
			dig = *s - 'A' + 10;
  800be6:	0f be d2             	movsbl %dl,%edx
  800be9:	83 ea 37             	sub    $0x37,%edx
  800bec:	eb cb                	jmp    800bb9 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf2:	74 05                	je     800bf9 <strtol+0xd0>
		*endptr = (char *) s;
  800bf4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf7:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bf9:	89 c2                	mov    %eax,%edx
  800bfb:	f7 da                	neg    %edx
  800bfd:	85 ff                	test   %edi,%edi
  800bff:	0f 45 c2             	cmovne %edx,%eax
}
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    
  800c07:	66 90                	xchg   %ax,%ax
  800c09:	66 90                	xchg   %ax,%ax
  800c0b:	66 90                	xchg   %ax,%ax
  800c0d:	66 90                	xchg   %ax,%ax
  800c0f:	90                   	nop

00800c10 <__udivdi3>:
  800c10:	55                   	push   %ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
  800c14:	83 ec 1c             	sub    $0x1c,%esp
  800c17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c1b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c23:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c27:	85 d2                	test   %edx,%edx
  800c29:	75 35                	jne    800c60 <__udivdi3+0x50>
  800c2b:	39 f3                	cmp    %esi,%ebx
  800c2d:	0f 87 bd 00 00 00    	ja     800cf0 <__udivdi3+0xe0>
  800c33:	85 db                	test   %ebx,%ebx
  800c35:	89 d9                	mov    %ebx,%ecx
  800c37:	75 0b                	jne    800c44 <__udivdi3+0x34>
  800c39:	b8 01 00 00 00       	mov    $0x1,%eax
  800c3e:	31 d2                	xor    %edx,%edx
  800c40:	f7 f3                	div    %ebx
  800c42:	89 c1                	mov    %eax,%ecx
  800c44:	31 d2                	xor    %edx,%edx
  800c46:	89 f0                	mov    %esi,%eax
  800c48:	f7 f1                	div    %ecx
  800c4a:	89 c6                	mov    %eax,%esi
  800c4c:	89 e8                	mov    %ebp,%eax
  800c4e:	89 f7                	mov    %esi,%edi
  800c50:	f7 f1                	div    %ecx
  800c52:	89 fa                	mov    %edi,%edx
  800c54:	83 c4 1c             	add    $0x1c,%esp
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    
  800c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c60:	39 f2                	cmp    %esi,%edx
  800c62:	77 7c                	ja     800ce0 <__udivdi3+0xd0>
  800c64:	0f bd fa             	bsr    %edx,%edi
  800c67:	83 f7 1f             	xor    $0x1f,%edi
  800c6a:	0f 84 98 00 00 00    	je     800d08 <__udivdi3+0xf8>
  800c70:	89 f9                	mov    %edi,%ecx
  800c72:	b8 20 00 00 00       	mov    $0x20,%eax
  800c77:	29 f8                	sub    %edi,%eax
  800c79:	d3 e2                	shl    %cl,%edx
  800c7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800c7f:	89 c1                	mov    %eax,%ecx
  800c81:	89 da                	mov    %ebx,%edx
  800c83:	d3 ea                	shr    %cl,%edx
  800c85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800c89:	09 d1                	or     %edx,%ecx
  800c8b:	89 f2                	mov    %esi,%edx
  800c8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c91:	89 f9                	mov    %edi,%ecx
  800c93:	d3 e3                	shl    %cl,%ebx
  800c95:	89 c1                	mov    %eax,%ecx
  800c97:	d3 ea                	shr    %cl,%edx
  800c99:	89 f9                	mov    %edi,%ecx
  800c9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800c9f:	d3 e6                	shl    %cl,%esi
  800ca1:	89 eb                	mov    %ebp,%ebx
  800ca3:	89 c1                	mov    %eax,%ecx
  800ca5:	d3 eb                	shr    %cl,%ebx
  800ca7:	09 de                	or     %ebx,%esi
  800ca9:	89 f0                	mov    %esi,%eax
  800cab:	f7 74 24 08          	divl   0x8(%esp)
  800caf:	89 d6                	mov    %edx,%esi
  800cb1:	89 c3                	mov    %eax,%ebx
  800cb3:	f7 64 24 0c          	mull   0xc(%esp)
  800cb7:	39 d6                	cmp    %edx,%esi
  800cb9:	72 0c                	jb     800cc7 <__udivdi3+0xb7>
  800cbb:	89 f9                	mov    %edi,%ecx
  800cbd:	d3 e5                	shl    %cl,%ebp
  800cbf:	39 c5                	cmp    %eax,%ebp
  800cc1:	73 5d                	jae    800d20 <__udivdi3+0x110>
  800cc3:	39 d6                	cmp    %edx,%esi
  800cc5:	75 59                	jne    800d20 <__udivdi3+0x110>
  800cc7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cca:	31 ff                	xor    %edi,%edi
  800ccc:	89 fa                	mov    %edi,%edx
  800cce:	83 c4 1c             	add    $0x1c,%esp
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    
  800cd6:	8d 76 00             	lea    0x0(%esi),%esi
  800cd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800ce0:	31 ff                	xor    %edi,%edi
  800ce2:	31 c0                	xor    %eax,%eax
  800ce4:	89 fa                	mov    %edi,%edx
  800ce6:	83 c4 1c             	add    $0x1c,%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    
  800cee:	66 90                	xchg   %ax,%ax
  800cf0:	31 ff                	xor    %edi,%edi
  800cf2:	89 e8                	mov    %ebp,%eax
  800cf4:	89 f2                	mov    %esi,%edx
  800cf6:	f7 f3                	div    %ebx
  800cf8:	89 fa                	mov    %edi,%edx
  800cfa:	83 c4 1c             	add    $0x1c,%esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    
  800d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d08:	39 f2                	cmp    %esi,%edx
  800d0a:	72 06                	jb     800d12 <__udivdi3+0x102>
  800d0c:	31 c0                	xor    %eax,%eax
  800d0e:	39 eb                	cmp    %ebp,%ebx
  800d10:	77 d2                	ja     800ce4 <__udivdi3+0xd4>
  800d12:	b8 01 00 00 00       	mov    $0x1,%eax
  800d17:	eb cb                	jmp    800ce4 <__udivdi3+0xd4>
  800d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d20:	89 d8                	mov    %ebx,%eax
  800d22:	31 ff                	xor    %edi,%edi
  800d24:	eb be                	jmp    800ce4 <__udivdi3+0xd4>
  800d26:	66 90                	xchg   %ax,%ax
  800d28:	66 90                	xchg   %ax,%ax
  800d2a:	66 90                	xchg   %ax,%ax
  800d2c:	66 90                	xchg   %ax,%ax
  800d2e:	66 90                	xchg   %ax,%ax

00800d30 <__umoddi3>:
  800d30:	55                   	push   %ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 1c             	sub    $0x1c,%esp
  800d37:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d3b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d47:	85 ed                	test   %ebp,%ebp
  800d49:	89 f0                	mov    %esi,%eax
  800d4b:	89 da                	mov    %ebx,%edx
  800d4d:	75 19                	jne    800d68 <__umoddi3+0x38>
  800d4f:	39 df                	cmp    %ebx,%edi
  800d51:	0f 86 b1 00 00 00    	jbe    800e08 <__umoddi3+0xd8>
  800d57:	f7 f7                	div    %edi
  800d59:	89 d0                	mov    %edx,%eax
  800d5b:	31 d2                	xor    %edx,%edx
  800d5d:	83 c4 1c             	add    $0x1c,%esp
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    
  800d65:	8d 76 00             	lea    0x0(%esi),%esi
  800d68:	39 dd                	cmp    %ebx,%ebp
  800d6a:	77 f1                	ja     800d5d <__umoddi3+0x2d>
  800d6c:	0f bd cd             	bsr    %ebp,%ecx
  800d6f:	83 f1 1f             	xor    $0x1f,%ecx
  800d72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d76:	0f 84 b4 00 00 00    	je     800e30 <__umoddi3+0x100>
  800d7c:	b8 20 00 00 00       	mov    $0x20,%eax
  800d81:	89 c2                	mov    %eax,%edx
  800d83:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d87:	29 c2                	sub    %eax,%edx
  800d89:	89 c1                	mov    %eax,%ecx
  800d8b:	89 f8                	mov    %edi,%eax
  800d8d:	d3 e5                	shl    %cl,%ebp
  800d8f:	89 d1                	mov    %edx,%ecx
  800d91:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d95:	d3 e8                	shr    %cl,%eax
  800d97:	09 c5                	or     %eax,%ebp
  800d99:	8b 44 24 04          	mov    0x4(%esp),%eax
  800d9d:	89 c1                	mov    %eax,%ecx
  800d9f:	d3 e7                	shl    %cl,%edi
  800da1:	89 d1                	mov    %edx,%ecx
  800da3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800da7:	89 df                	mov    %ebx,%edi
  800da9:	d3 ef                	shr    %cl,%edi
  800dab:	89 c1                	mov    %eax,%ecx
  800dad:	89 f0                	mov    %esi,%eax
  800daf:	d3 e3                	shl    %cl,%ebx
  800db1:	89 d1                	mov    %edx,%ecx
  800db3:	89 fa                	mov    %edi,%edx
  800db5:	d3 e8                	shr    %cl,%eax
  800db7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800dbc:	09 d8                	or     %ebx,%eax
  800dbe:	f7 f5                	div    %ebp
  800dc0:	d3 e6                	shl    %cl,%esi
  800dc2:	89 d1                	mov    %edx,%ecx
  800dc4:	f7 64 24 08          	mull   0x8(%esp)
  800dc8:	39 d1                	cmp    %edx,%ecx
  800dca:	89 c3                	mov    %eax,%ebx
  800dcc:	89 d7                	mov    %edx,%edi
  800dce:	72 06                	jb     800dd6 <__umoddi3+0xa6>
  800dd0:	75 0e                	jne    800de0 <__umoddi3+0xb0>
  800dd2:	39 c6                	cmp    %eax,%esi
  800dd4:	73 0a                	jae    800de0 <__umoddi3+0xb0>
  800dd6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800dda:	19 ea                	sbb    %ebp,%edx
  800ddc:	89 d7                	mov    %edx,%edi
  800dde:	89 c3                	mov    %eax,%ebx
  800de0:	89 ca                	mov    %ecx,%edx
  800de2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800de7:	29 de                	sub    %ebx,%esi
  800de9:	19 fa                	sbb    %edi,%edx
  800deb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800def:	89 d0                	mov    %edx,%eax
  800df1:	d3 e0                	shl    %cl,%eax
  800df3:	89 d9                	mov    %ebx,%ecx
  800df5:	d3 ee                	shr    %cl,%esi
  800df7:	d3 ea                	shr    %cl,%edx
  800df9:	09 f0                	or     %esi,%eax
  800dfb:	83 c4 1c             	add    $0x1c,%esp
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    
  800e03:	90                   	nop
  800e04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e08:	85 ff                	test   %edi,%edi
  800e0a:	89 f9                	mov    %edi,%ecx
  800e0c:	75 0b                	jne    800e19 <__umoddi3+0xe9>
  800e0e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e13:	31 d2                	xor    %edx,%edx
  800e15:	f7 f7                	div    %edi
  800e17:	89 c1                	mov    %eax,%ecx
  800e19:	89 d8                	mov    %ebx,%eax
  800e1b:	31 d2                	xor    %edx,%edx
  800e1d:	f7 f1                	div    %ecx
  800e1f:	89 f0                	mov    %esi,%eax
  800e21:	f7 f1                	div    %ecx
  800e23:	e9 31 ff ff ff       	jmp    800d59 <__umoddi3+0x29>
  800e28:	90                   	nop
  800e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e30:	39 dd                	cmp    %ebx,%ebp
  800e32:	72 08                	jb     800e3c <__umoddi3+0x10c>
  800e34:	39 f7                	cmp    %esi,%edi
  800e36:	0f 87 21 ff ff ff    	ja     800d5d <__umoddi3+0x2d>
  800e3c:	89 da                	mov    %ebx,%edx
  800e3e:	89 f0                	mov    %esi,%eax
  800e40:	29 f8                	sub    %edi,%eax
  800e42:	19 ea                	sbb    %ebp,%edx
  800e44:	e9 14 ff ff ff       	jmp    800d5d <__umoddi3+0x2d>
