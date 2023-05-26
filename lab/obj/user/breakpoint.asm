
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	53                   	push   %ebx
  80003d:	83 ec 04             	sub    $0x4,%esp
  800040:	e8 3b 00 00 00       	call   800080 <__x86.get_pc_thunk.bx>
  800045:	81 c3 bb 1f 00 00    	add    $0x1fbb,%ebx
  80004b:	8b 45 08             	mov    0x8(%ebp),%eax
  80004e:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800051:	c7 c1 2c 20 80 00    	mov    $0x80202c,%ecx
  800057:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005d:	85 c0                	test   %eax,%eax
  80005f:	7e 08                	jle    800069 <libmain+0x30>
		binaryname = argv[0];
  800061:	8b 0a                	mov    (%edx),%ecx
  800063:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800069:	83 ec 08             	sub    $0x8,%esp
  80006c:	52                   	push   %edx
  80006d:	50                   	push   %eax
  80006e:	e8 c0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800073:	e8 0c 00 00 00       	call   800084 <exit>
}
  800078:	83 c4 10             	add    $0x10,%esp
  80007b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <__x86.get_pc_thunk.bx>:
  800080:	8b 1c 24             	mov    (%esp),%ebx
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	53                   	push   %ebx
  800088:	83 ec 10             	sub    $0x10,%esp
  80008b:	e8 f0 ff ff ff       	call   800080 <__x86.get_pc_thunk.bx>
  800090:	81 c3 70 1f 00 00    	add    $0x1f70,%ebx
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 45 00 00 00       	call   8000e2 <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a3:	c9                   	leave  
  8000a4:	c3                   	ret    

008000a5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a5:	55                   	push   %ebp
  8000a6:	89 e5                	mov    %esp,%ebp
  8000a8:	57                   	push   %edi
  8000a9:	56                   	push   %esi
  8000aa:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b6:	89 c3                	mov    %eax,%ebx
  8000b8:	89 c7                	mov    %eax,%edi
  8000ba:	89 c6                	mov    %eax,%esi
  8000bc:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000be:	5b                   	pop    %ebx
  8000bf:	5e                   	pop    %esi
  8000c0:	5f                   	pop    %edi
  8000c1:	5d                   	pop    %ebp
  8000c2:	c3                   	ret    

008000c3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	57                   	push   %edi
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d3:	89 d1                	mov    %edx,%ecx
  8000d5:	89 d3                	mov    %edx,%ebx
  8000d7:	89 d7                	mov    %edx,%edi
  8000d9:	89 d6                	mov    %edx,%esi
  8000db:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000dd:	5b                   	pop    %ebx
  8000de:	5e                   	pop    %esi
  8000df:	5f                   	pop    %edi
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    

008000e2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	57                   	push   %edi
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
  8000e8:	83 ec 1c             	sub    $0x1c,%esp
  8000eb:	e8 66 00 00 00       	call   800156 <__x86.get_pc_thunk.ax>
  8000f0:	05 10 1f 00 00       	add    $0x1f10,%eax
  8000f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8000f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800100:	b8 03 00 00 00       	mov    $0x3,%eax
  800105:	89 cb                	mov    %ecx,%ebx
  800107:	89 cf                	mov    %ecx,%edi
  800109:	89 ce                	mov    %ecx,%esi
  80010b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010d:	85 c0                	test   %eax,%eax
  80010f:	7f 08                	jg     800119 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800111:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800114:	5b                   	pop    %ebx
  800115:	5e                   	pop    %esi
  800116:	5f                   	pop    %edi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800119:	83 ec 0c             	sub    $0xc,%esp
  80011c:	50                   	push   %eax
  80011d:	6a 03                	push   $0x3
  80011f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800122:	8d 83 56 ee ff ff    	lea    -0x11aa(%ebx),%eax
  800128:	50                   	push   %eax
  800129:	6a 23                	push   $0x23
  80012b:	8d 83 73 ee ff ff    	lea    -0x118d(%ebx),%eax
  800131:	50                   	push   %eax
  800132:	e8 23 00 00 00       	call   80015a <_panic>

00800137 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 02 00 00 00       	mov    $0x2,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <__x86.get_pc_thunk.ax>:
  800156:	8b 04 24             	mov    (%esp),%eax
  800159:	c3                   	ret    

0080015a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	e8 18 ff ff ff       	call   800080 <__x86.get_pc_thunk.bx>
  800168:	81 c3 98 1e 00 00    	add    $0x1e98,%ebx
	va_list ap;

	va_start(ap, fmt);
  80016e:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800171:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800177:	8b 38                	mov    (%eax),%edi
  800179:	e8 b9 ff ff ff       	call   800137 <sys_getenvid>
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	ff 75 0c             	pushl  0xc(%ebp)
  800184:	ff 75 08             	pushl  0x8(%ebp)
  800187:	57                   	push   %edi
  800188:	50                   	push   %eax
  800189:	8d 83 84 ee ff ff    	lea    -0x117c(%ebx),%eax
  80018f:	50                   	push   %eax
  800190:	e8 d1 00 00 00       	call   800266 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800195:	83 c4 18             	add    $0x18,%esp
  800198:	56                   	push   %esi
  800199:	ff 75 10             	pushl  0x10(%ebp)
  80019c:	e8 63 00 00 00       	call   800204 <vcprintf>
	cprintf("\n");
  8001a1:	8d 83 a8 ee ff ff    	lea    -0x1158(%ebx),%eax
  8001a7:	89 04 24             	mov    %eax,(%esp)
  8001aa:	e8 b7 00 00 00       	call   800266 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b2:	cc                   	int3   
  8001b3:	eb fd                	jmp    8001b2 <_panic+0x58>

008001b5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	56                   	push   %esi
  8001b9:	53                   	push   %ebx
  8001ba:	e8 c1 fe ff ff       	call   800080 <__x86.get_pc_thunk.bx>
  8001bf:	81 c3 41 1e 00 00    	add    $0x1e41,%ebx
  8001c5:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001c8:	8b 16                	mov    (%esi),%edx
  8001ca:	8d 42 01             	lea    0x1(%edx),%eax
  8001cd:	89 06                	mov    %eax,(%esi)
  8001cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d2:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001db:	74 0b                	je     8001e8 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001dd:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e4:	5b                   	pop    %ebx
  8001e5:	5e                   	pop    %esi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	68 ff 00 00 00       	push   $0xff
  8001f0:	8d 46 08             	lea    0x8(%esi),%eax
  8001f3:	50                   	push   %eax
  8001f4:	e8 ac fe ff ff       	call   8000a5 <sys_cputs>
		b->idx = 0;
  8001f9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8001ff:	83 c4 10             	add    $0x10,%esp
  800202:	eb d9                	jmp    8001dd <putch+0x28>

00800204 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	53                   	push   %ebx
  800208:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80020e:	e8 6d fe ff ff       	call   800080 <__x86.get_pc_thunk.bx>
  800213:	81 c3 ed 1d 00 00    	add    $0x1ded,%ebx
	struct printbuf b;

	b.idx = 0;
  800219:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800220:	00 00 00 
	b.cnt = 0;
  800223:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022d:	ff 75 0c             	pushl  0xc(%ebp)
  800230:	ff 75 08             	pushl  0x8(%ebp)
  800233:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800239:	50                   	push   %eax
  80023a:	8d 83 b5 e1 ff ff    	lea    -0x1e4b(%ebx),%eax
  800240:	50                   	push   %eax
  800241:	e8 38 01 00 00       	call   80037e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800246:	83 c4 08             	add    $0x8,%esp
  800249:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80024f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800255:	50                   	push   %eax
  800256:	e8 4a fe ff ff       	call   8000a5 <sys_cputs>

	return b.cnt;
}
  80025b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800261:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800264:	c9                   	leave  
  800265:	c3                   	ret    

00800266 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
  800269:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80026f:	50                   	push   %eax
  800270:	ff 75 08             	pushl  0x8(%ebp)
  800273:	e8 8c ff ff ff       	call   800204 <vcprintf>
	va_end(ap);

	return cnt;
}
  800278:	c9                   	leave  
  800279:	c3                   	ret    

0080027a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	57                   	push   %edi
  80027e:	56                   	push   %esi
  80027f:	53                   	push   %ebx
  800280:	83 ec 2c             	sub    $0x2c,%esp
  800283:	e8 02 06 00 00       	call   80088a <__x86.get_pc_thunk.cx>
  800288:	81 c1 78 1d 00 00    	add    $0x1d78,%ecx
  80028e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800291:	89 c7                	mov    %eax,%edi
  800293:	89 d6                	mov    %edx,%esi
  800295:	8b 45 08             	mov    0x8(%ebp),%eax
  800298:	8b 55 0c             	mov    0xc(%ebp),%edx
  80029b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80029e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  8002a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a9:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002ac:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002af:	39 d3                	cmp    %edx,%ebx
  8002b1:	72 09                	jb     8002bc <printnum+0x42>
  8002b3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002b6:	0f 87 83 00 00 00    	ja     80033f <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002bc:	83 ec 0c             	sub    $0xc,%esp
  8002bf:	ff 75 18             	pushl  0x18(%ebp)
  8002c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8002c5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002c8:	53                   	push   %ebx
  8002c9:	ff 75 10             	pushl  0x10(%ebp)
  8002cc:	83 ec 08             	sub    $0x8,%esp
  8002cf:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002d8:	ff 75 d0             	pushl  -0x30(%ebp)
  8002db:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002de:	e8 2d 09 00 00       	call   800c10 <__udivdi3>
  8002e3:	83 c4 18             	add    $0x18,%esp
  8002e6:	52                   	push   %edx
  8002e7:	50                   	push   %eax
  8002e8:	89 f2                	mov    %esi,%edx
  8002ea:	89 f8                	mov    %edi,%eax
  8002ec:	e8 89 ff ff ff       	call   80027a <printnum>
  8002f1:	83 c4 20             	add    $0x20,%esp
  8002f4:	eb 13                	jmp    800309 <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f6:	83 ec 08             	sub    $0x8,%esp
  8002f9:	56                   	push   %esi
  8002fa:	ff 75 18             	pushl  0x18(%ebp)
  8002fd:	ff d7                	call   *%edi
  8002ff:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800302:	83 eb 01             	sub    $0x1,%ebx
  800305:	85 db                	test   %ebx,%ebx
  800307:	7f ed                	jg     8002f6 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800309:	83 ec 08             	sub    $0x8,%esp
  80030c:	56                   	push   %esi
  80030d:	83 ec 04             	sub    $0x4,%esp
  800310:	ff 75 dc             	pushl  -0x24(%ebp)
  800313:	ff 75 d8             	pushl  -0x28(%ebp)
  800316:	ff 75 d4             	pushl  -0x2c(%ebp)
  800319:	ff 75 d0             	pushl  -0x30(%ebp)
  80031c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80031f:	89 f3                	mov    %esi,%ebx
  800321:	e8 0a 0a 00 00       	call   800d30 <__umoddi3>
  800326:	83 c4 14             	add    $0x14,%esp
  800329:	0f be 84 06 aa ee ff 	movsbl -0x1156(%esi,%eax,1),%eax
  800330:	ff 
  800331:	50                   	push   %eax
  800332:	ff d7                	call   *%edi
}
  800334:	83 c4 10             	add    $0x10,%esp
  800337:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033a:	5b                   	pop    %ebx
  80033b:	5e                   	pop    %esi
  80033c:	5f                   	pop    %edi
  80033d:	5d                   	pop    %ebp
  80033e:	c3                   	ret    
  80033f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800342:	eb be                	jmp    800302 <printnum+0x88>

00800344 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80034a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80034e:	8b 10                	mov    (%eax),%edx
  800350:	3b 50 04             	cmp    0x4(%eax),%edx
  800353:	73 0a                	jae    80035f <sprintputch+0x1b>
		*b->buf++ = ch;
  800355:	8d 4a 01             	lea    0x1(%edx),%ecx
  800358:	89 08                	mov    %ecx,(%eax)
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	88 02                	mov    %al,(%edx)
}
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <printfmt>:
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800367:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80036a:	50                   	push   %eax
  80036b:	ff 75 10             	pushl  0x10(%ebp)
  80036e:	ff 75 0c             	pushl  0xc(%ebp)
  800371:	ff 75 08             	pushl  0x8(%ebp)
  800374:	e8 05 00 00 00       	call   80037e <vprintfmt>
}
  800379:	83 c4 10             	add    $0x10,%esp
  80037c:	c9                   	leave  
  80037d:	c3                   	ret    

0080037e <vprintfmt>:
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	57                   	push   %edi
  800382:	56                   	push   %esi
  800383:	53                   	push   %ebx
  800384:	83 ec 2c             	sub    $0x2c,%esp
  800387:	e8 f4 fc ff ff       	call   800080 <__x86.get_pc_thunk.bx>
  80038c:	81 c3 74 1c 00 00    	add    $0x1c74,%ebx
  800392:	8b 75 0c             	mov    0xc(%ebp),%esi
  800395:	8b 7d 10             	mov    0x10(%ebp),%edi
  800398:	e9 c3 03 00 00       	jmp    800760 <.L35+0x48>
		padc = ' ';
  80039d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003a1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003a8:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003af:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003bb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8003be:	8d 47 01             	lea    0x1(%edi),%eax
  8003c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c4:	0f b6 17             	movzbl (%edi),%edx
  8003c7:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003ca:	3c 55                	cmp    $0x55,%al
  8003cc:	0f 87 16 04 00 00    	ja     8007e8 <.L22>
  8003d2:	0f b6 c0             	movzbl %al,%eax
  8003d5:	89 d9                	mov    %ebx,%ecx
  8003d7:	03 8c 83 38 ef ff ff 	add    -0x10c8(%ebx,%eax,4),%ecx
  8003de:	ff e1                	jmp    *%ecx

008003e0 <.L69>:
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003e3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003e7:	eb d5                	jmp    8003be <vprintfmt+0x40>

008003e9 <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8003ec:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f0:	eb cc                	jmp    8003be <vprintfmt+0x40>

008003f2 <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8003f2:	0f b6 d2             	movzbl %dl,%edx
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
  8003f8:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  8003fd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800400:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800404:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800407:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80040a:	83 f9 09             	cmp    $0x9,%ecx
  80040d:	77 55                	ja     800464 <.L23+0xf>
			for (precision = 0;; ++fmt)
  80040f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800412:	eb e9                	jmp    8003fd <.L29+0xb>

00800414 <.L26>:
			precision = va_arg(ap, int);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8b 00                	mov    (%eax),%eax
  800419:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80041c:	8b 45 14             	mov    0x14(%ebp),%eax
  80041f:	8d 40 04             	lea    0x4(%eax),%eax
  800422:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800428:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042c:	79 90                	jns    8003be <vprintfmt+0x40>
				width = precision, precision = -1;
  80042e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800431:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800434:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80043b:	eb 81                	jmp    8003be <vprintfmt+0x40>

0080043d <.L27>:
  80043d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800440:	85 c0                	test   %eax,%eax
  800442:	ba 00 00 00 00       	mov    $0x0,%edx
  800447:	0f 49 d0             	cmovns %eax,%edx
  80044a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80044d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800450:	e9 69 ff ff ff       	jmp    8003be <vprintfmt+0x40>

00800455 <.L23>:
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800458:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80045f:	e9 5a ff ff ff       	jmp    8003be <vprintfmt+0x40>
  800464:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800467:	eb bf                	jmp    800428 <.L26+0x14>

00800469 <.L33>:
			lflag++;
  800469:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800470:	e9 49 ff ff ff       	jmp    8003be <vprintfmt+0x40>

00800475 <.L30>:
			putch(va_arg(ap, int), putdat);
  800475:	8b 45 14             	mov    0x14(%ebp),%eax
  800478:	8d 78 04             	lea    0x4(%eax),%edi
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	56                   	push   %esi
  80047f:	ff 30                	pushl  (%eax)
  800481:	ff 55 08             	call   *0x8(%ebp)
			break;
  800484:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800487:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80048a:	e9 ce 02 00 00       	jmp    80075d <.L35+0x45>

0080048f <.L32>:
			err = va_arg(ap, int);
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
  800492:	8d 78 04             	lea    0x4(%eax),%edi
  800495:	8b 00                	mov    (%eax),%eax
  800497:	99                   	cltd   
  800498:	31 d0                	xor    %edx,%eax
  80049a:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049c:	83 f8 06             	cmp    $0x6,%eax
  80049f:	7f 27                	jg     8004c8 <.L32+0x39>
  8004a1:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004a8:	85 d2                	test   %edx,%edx
  8004aa:	74 1c                	je     8004c8 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004ac:	52                   	push   %edx
  8004ad:	8d 83 cb ee ff ff    	lea    -0x1135(%ebx),%eax
  8004b3:	50                   	push   %eax
  8004b4:	56                   	push   %esi
  8004b5:	ff 75 08             	pushl  0x8(%ebp)
  8004b8:	e8 a4 fe ff ff       	call   800361 <printfmt>
  8004bd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004c0:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004c3:	e9 95 02 00 00       	jmp    80075d <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004c8:	50                   	push   %eax
  8004c9:	8d 83 c2 ee ff ff    	lea    -0x113e(%ebx),%eax
  8004cf:	50                   	push   %eax
  8004d0:	56                   	push   %esi
  8004d1:	ff 75 08             	pushl  0x8(%ebp)
  8004d4:	e8 88 fe ff ff       	call   800361 <printfmt>
  8004d9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004dc:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004df:	e9 79 02 00 00       	jmp    80075d <.L35+0x45>

008004e4 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  8004e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e7:	83 c0 04             	add    $0x4,%eax
  8004ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004f2:	85 ff                	test   %edi,%edi
  8004f4:	8d 83 bb ee ff ff    	lea    -0x1145(%ebx),%eax
  8004fa:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004fd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800501:	0f 8e b5 00 00 00    	jle    8005bc <.L36+0xd8>
  800507:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80050b:	75 08                	jne    800515 <.L36+0x31>
  80050d:	89 75 0c             	mov    %esi,0xc(%ebp)
  800510:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800513:	eb 6d                	jmp    800582 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	ff 75 cc             	pushl  -0x34(%ebp)
  80051b:	57                   	push   %edi
  80051c:	e8 85 03 00 00       	call   8008a6 <strnlen>
  800521:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800524:	29 c2                	sub    %eax,%edx
  800526:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800529:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80052c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800530:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800533:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800536:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800538:	eb 10                	jmp    80054a <.L36+0x66>
					putch(padc, putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	56                   	push   %esi
  80053e:	ff 75 e0             	pushl  -0x20(%ebp)
  800541:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800544:	83 ef 01             	sub    $0x1,%edi
  800547:	83 c4 10             	add    $0x10,%esp
  80054a:	85 ff                	test   %edi,%edi
  80054c:	7f ec                	jg     80053a <.L36+0x56>
  80054e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800551:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800554:	85 d2                	test   %edx,%edx
  800556:	b8 00 00 00 00       	mov    $0x0,%eax
  80055b:	0f 49 c2             	cmovns %edx,%eax
  80055e:	29 c2                	sub    %eax,%edx
  800560:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800563:	89 75 0c             	mov    %esi,0xc(%ebp)
  800566:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800569:	eb 17                	jmp    800582 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  80056b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80056f:	75 30                	jne    8005a1 <.L36+0xbd>
					putch(ch, putdat);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	ff 75 0c             	pushl  0xc(%ebp)
  800577:	50                   	push   %eax
  800578:	ff 55 08             	call   *0x8(%ebp)
  80057b:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057e:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800582:	83 c7 01             	add    $0x1,%edi
  800585:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800589:	0f be c2             	movsbl %dl,%eax
  80058c:	85 c0                	test   %eax,%eax
  80058e:	74 52                	je     8005e2 <.L36+0xfe>
  800590:	85 f6                	test   %esi,%esi
  800592:	78 d7                	js     80056b <.L36+0x87>
  800594:	83 ee 01             	sub    $0x1,%esi
  800597:	79 d2                	jns    80056b <.L36+0x87>
  800599:	8b 75 0c             	mov    0xc(%ebp),%esi
  80059c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80059f:	eb 32                	jmp    8005d3 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005a1:	0f be d2             	movsbl %dl,%edx
  8005a4:	83 ea 20             	sub    $0x20,%edx
  8005a7:	83 fa 5e             	cmp    $0x5e,%edx
  8005aa:	76 c5                	jbe    800571 <.L36+0x8d>
					putch('?', putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	ff 75 0c             	pushl  0xc(%ebp)
  8005b2:	6a 3f                	push   $0x3f
  8005b4:	ff 55 08             	call   *0x8(%ebp)
  8005b7:	83 c4 10             	add    $0x10,%esp
  8005ba:	eb c2                	jmp    80057e <.L36+0x9a>
  8005bc:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005bf:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005c2:	eb be                	jmp    800582 <.L36+0x9e>
				putch(' ', putdat);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	56                   	push   %esi
  8005c8:	6a 20                	push   $0x20
  8005ca:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8005cd:	83 ef 01             	sub    $0x1,%edi
  8005d0:	83 c4 10             	add    $0x10,%esp
  8005d3:	85 ff                	test   %edi,%edi
  8005d5:	7f ed                	jg     8005c4 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  8005d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005da:	89 45 14             	mov    %eax,0x14(%ebp)
  8005dd:	e9 7b 01 00 00       	jmp    80075d <.L35+0x45>
  8005e2:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005e5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005e8:	eb e9                	jmp    8005d3 <.L36+0xef>

008005ea <.L31>:
  8005ea:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8005ed:	83 f9 01             	cmp    $0x1,%ecx
  8005f0:	7e 40                	jle    800632 <.L31+0x48>
		return va_arg(*ap, long long);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8b 50 04             	mov    0x4(%eax),%edx
  8005f8:	8b 00                	mov    (%eax),%eax
  8005fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 40 08             	lea    0x8(%eax),%eax
  800606:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
  800609:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80060d:	79 55                	jns    800664 <.L31+0x7a>
				putch('-', putdat);
  80060f:	83 ec 08             	sub    $0x8,%esp
  800612:	56                   	push   %esi
  800613:	6a 2d                	push   $0x2d
  800615:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  800618:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80061b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80061e:	f7 da                	neg    %edx
  800620:	83 d1 00             	adc    $0x0,%ecx
  800623:	f7 d9                	neg    %ecx
  800625:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
  800628:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062d:	e9 10 01 00 00       	jmp    800742 <.L35+0x2a>
	else if (lflag)
  800632:	85 c9                	test   %ecx,%ecx
  800634:	75 17                	jne    80064d <.L31+0x63>
		return va_arg(*ap, int);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8b 00                	mov    (%eax),%eax
  80063b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063e:	99                   	cltd   
  80063f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 40 04             	lea    0x4(%eax),%eax
  800648:	89 45 14             	mov    %eax,0x14(%ebp)
  80064b:	eb bc                	jmp    800609 <.L31+0x1f>
		return va_arg(*ap, long);
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8b 00                	mov    (%eax),%eax
  800652:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800655:	99                   	cltd   
  800656:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8d 40 04             	lea    0x4(%eax),%eax
  80065f:	89 45 14             	mov    %eax,0x14(%ebp)
  800662:	eb a5                	jmp    800609 <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  800664:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800667:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
  80066a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066f:	e9 ce 00 00 00       	jmp    800742 <.L35+0x2a>

00800674 <.L37>:
  800674:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800677:	83 f9 01             	cmp    $0x1,%ecx
  80067a:	7e 18                	jle    800694 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8b 10                	mov    (%eax),%edx
  800681:	8b 48 04             	mov    0x4(%eax),%ecx
  800684:	8d 40 08             	lea    0x8(%eax),%eax
  800687:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80068a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068f:	e9 ae 00 00 00       	jmp    800742 <.L35+0x2a>
	else if (lflag)
  800694:	85 c9                	test   %ecx,%ecx
  800696:	75 1a                	jne    8006b2 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8b 10                	mov    (%eax),%edx
  80069d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a2:	8d 40 04             	lea    0x4(%eax),%eax
  8006a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006a8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ad:	e9 90 00 00 00       	jmp    800742 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8b 10                	mov    (%eax),%edx
  8006b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bc:	8d 40 04             	lea    0x4(%eax),%eax
  8006bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c7:	eb 79                	jmp    800742 <.L35+0x2a>

008006c9 <.L34>:
  8006c9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006cc:	83 f9 01             	cmp    $0x1,%ecx
  8006cf:	7e 15                	jle    8006e6 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8b 10                	mov    (%eax),%edx
  8006d6:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d9:	8d 40 08             	lea    0x8(%eax),%eax
  8006dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006df:	b8 08 00 00 00       	mov    $0x8,%eax
  8006e4:	eb 5c                	jmp    800742 <.L35+0x2a>
	else if (lflag)
  8006e6:	85 c9                	test   %ecx,%ecx
  8006e8:	75 17                	jne    800701 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  8006ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ed:	8b 10                	mov    (%eax),%edx
  8006ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f4:	8d 40 04             	lea    0x4(%eax),%eax
  8006f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006fa:	b8 08 00 00 00       	mov    $0x8,%eax
  8006ff:	eb 41                	jmp    800742 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8b 10                	mov    (%eax),%edx
  800706:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070b:	8d 40 04             	lea    0x4(%eax),%eax
  80070e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800711:	b8 08 00 00 00       	mov    $0x8,%eax
  800716:	eb 2a                	jmp    800742 <.L35+0x2a>

00800718 <.L35>:
			putch('0', putdat);
  800718:	83 ec 08             	sub    $0x8,%esp
  80071b:	56                   	push   %esi
  80071c:	6a 30                	push   $0x30
  80071e:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800721:	83 c4 08             	add    $0x8,%esp
  800724:	56                   	push   %esi
  800725:	6a 78                	push   $0x78
  800727:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80072a:	8b 45 14             	mov    0x14(%ebp),%eax
  80072d:	8b 10                	mov    (%eax),%edx
  80072f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800734:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800737:	8d 40 04             	lea    0x4(%eax),%eax
  80073a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073d:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  800742:	83 ec 0c             	sub    $0xc,%esp
  800745:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800749:	57                   	push   %edi
  80074a:	ff 75 e0             	pushl  -0x20(%ebp)
  80074d:	50                   	push   %eax
  80074e:	51                   	push   %ecx
  80074f:	52                   	push   %edx
  800750:	89 f2                	mov    %esi,%edx
  800752:	8b 45 08             	mov    0x8(%ebp),%eax
  800755:	e8 20 fb ff ff       	call   80027a <printnum>
			break;
  80075a:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80075d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  800760:	83 c7 01             	add    $0x1,%edi
  800763:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800767:	83 f8 25             	cmp    $0x25,%eax
  80076a:	0f 84 2d fc ff ff    	je     80039d <vprintfmt+0x1f>
			if (ch == '\0')
  800770:	85 c0                	test   %eax,%eax
  800772:	0f 84 91 00 00 00    	je     800809 <.L22+0x21>
			putch(ch, putdat);
  800778:	83 ec 08             	sub    $0x8,%esp
  80077b:	56                   	push   %esi
  80077c:	50                   	push   %eax
  80077d:	ff 55 08             	call   *0x8(%ebp)
  800780:	83 c4 10             	add    $0x10,%esp
  800783:	eb db                	jmp    800760 <.L35+0x48>

00800785 <.L38>:
  800785:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800788:	83 f9 01             	cmp    $0x1,%ecx
  80078b:	7e 15                	jle    8007a2 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  80078d:	8b 45 14             	mov    0x14(%ebp),%eax
  800790:	8b 10                	mov    (%eax),%edx
  800792:	8b 48 04             	mov    0x4(%eax),%ecx
  800795:	8d 40 08             	lea    0x8(%eax),%eax
  800798:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80079b:	b8 10 00 00 00       	mov    $0x10,%eax
  8007a0:	eb a0                	jmp    800742 <.L35+0x2a>
	else if (lflag)
  8007a2:	85 c9                	test   %ecx,%ecx
  8007a4:	75 17                	jne    8007bd <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	8b 10                	mov    (%eax),%edx
  8007ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b0:	8d 40 04             	lea    0x4(%eax),%eax
  8007b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b6:	b8 10 00 00 00       	mov    $0x10,%eax
  8007bb:	eb 85                	jmp    800742 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8b 10                	mov    (%eax),%edx
  8007c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c7:	8d 40 04             	lea    0x4(%eax),%eax
  8007ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007cd:	b8 10 00 00 00       	mov    $0x10,%eax
  8007d2:	e9 6b ff ff ff       	jmp    800742 <.L35+0x2a>

008007d7 <.L25>:
			putch(ch, putdat);
  8007d7:	83 ec 08             	sub    $0x8,%esp
  8007da:	56                   	push   %esi
  8007db:	6a 25                	push   $0x25
  8007dd:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	e9 75 ff ff ff       	jmp    80075d <.L35+0x45>

008007e8 <.L22>:
			putch('%', putdat);
  8007e8:	83 ec 08             	sub    $0x8,%esp
  8007eb:	56                   	push   %esi
  8007ec:	6a 25                	push   $0x25
  8007ee:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f1:	83 c4 10             	add    $0x10,%esp
  8007f4:	89 f8                	mov    %edi,%eax
  8007f6:	eb 03                	jmp    8007fb <.L22+0x13>
  8007f8:	83 e8 01             	sub    $0x1,%eax
  8007fb:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007ff:	75 f7                	jne    8007f8 <.L22+0x10>
  800801:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800804:	e9 54 ff ff ff       	jmp    80075d <.L35+0x45>
}
  800809:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80080c:	5b                   	pop    %ebx
  80080d:	5e                   	pop    %esi
  80080e:	5f                   	pop    %edi
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	53                   	push   %ebx
  800815:	83 ec 14             	sub    $0x14,%esp
  800818:	e8 63 f8 ff ff       	call   800080 <__x86.get_pc_thunk.bx>
  80081d:	81 c3 e3 17 00 00    	add    $0x17e3,%ebx
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  800829:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80082c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800830:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800833:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083a:	85 c0                	test   %eax,%eax
  80083c:	74 2b                	je     800869 <vsnprintf+0x58>
  80083e:	85 d2                	test   %edx,%edx
  800840:	7e 27                	jle    800869 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  800842:	ff 75 14             	pushl  0x14(%ebp)
  800845:	ff 75 10             	pushl  0x10(%ebp)
  800848:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084b:	50                   	push   %eax
  80084c:	8d 83 44 e3 ff ff    	lea    -0x1cbc(%ebx),%eax
  800852:	50                   	push   %eax
  800853:	e8 26 fb ff ff       	call   80037e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800858:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80085e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800861:	83 c4 10             	add    $0x10,%esp
}
  800864:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800867:	c9                   	leave  
  800868:	c3                   	ret    
		return -E_INVAL;
  800869:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80086e:	eb f4                	jmp    800864 <vsnprintf+0x53>

00800870 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800876:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800879:	50                   	push   %eax
  80087a:	ff 75 10             	pushl  0x10(%ebp)
  80087d:	ff 75 0c             	pushl  0xc(%ebp)
  800880:	ff 75 08             	pushl  0x8(%ebp)
  800883:	e8 89 ff ff ff       	call   800811 <vsnprintf>
	va_end(ap);

	return rc;
}
  800888:	c9                   	leave  
  800889:	c3                   	ret    

0080088a <__x86.get_pc_thunk.cx>:
  80088a:	8b 0c 24             	mov    (%esp),%ecx
  80088d:	c3                   	ret    

0080088e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800894:	b8 00 00 00 00       	mov    $0x0,%eax
  800899:	eb 03                	jmp    80089e <strlen+0x10>
		n++;
  80089b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80089e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a2:	75 f7                	jne    80089b <strlen+0xd>
	return n;
}
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ac:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008af:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b4:	eb 03                	jmp    8008b9 <strnlen+0x13>
		n++;
  8008b6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b9:	39 d0                	cmp    %edx,%eax
  8008bb:	74 06                	je     8008c3 <strnlen+0x1d>
  8008bd:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008c1:	75 f3                	jne    8008b6 <strnlen+0x10>
	return n;
}
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	53                   	push   %ebx
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008cf:	89 c2                	mov    %eax,%edx
  8008d1:	83 c1 01             	add    $0x1,%ecx
  8008d4:	83 c2 01             	add    $0x1,%edx
  8008d7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008db:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008de:	84 db                	test   %bl,%bl
  8008e0:	75 ef                	jne    8008d1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008e2:	5b                   	pop    %ebx
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	53                   	push   %ebx
  8008e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008ec:	53                   	push   %ebx
  8008ed:	e8 9c ff ff ff       	call   80088e <strlen>
  8008f2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008f5:	ff 75 0c             	pushl  0xc(%ebp)
  8008f8:	01 d8                	add    %ebx,%eax
  8008fa:	50                   	push   %eax
  8008fb:	e8 c5 ff ff ff       	call   8008c5 <strcpy>
	return dst;
}
  800900:	89 d8                	mov    %ebx,%eax
  800902:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800905:	c9                   	leave  
  800906:	c3                   	ret    

00800907 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	56                   	push   %esi
  80090b:	53                   	push   %ebx
  80090c:	8b 75 08             	mov    0x8(%ebp),%esi
  80090f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800912:	89 f3                	mov    %esi,%ebx
  800914:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800917:	89 f2                	mov    %esi,%edx
  800919:	eb 0f                	jmp    80092a <strncpy+0x23>
		*dst++ = *src;
  80091b:	83 c2 01             	add    $0x1,%edx
  80091e:	0f b6 01             	movzbl (%ecx),%eax
  800921:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800924:	80 39 01             	cmpb   $0x1,(%ecx)
  800927:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80092a:	39 da                	cmp    %ebx,%edx
  80092c:	75 ed                	jne    80091b <strncpy+0x14>
	}
	return ret;
}
  80092e:	89 f0                	mov    %esi,%eax
  800930:	5b                   	pop    %ebx
  800931:	5e                   	pop    %esi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	8b 75 08             	mov    0x8(%ebp),%esi
  80093c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800942:	89 f0                	mov    %esi,%eax
  800944:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800948:	85 c9                	test   %ecx,%ecx
  80094a:	75 0b                	jne    800957 <strlcpy+0x23>
  80094c:	eb 17                	jmp    800965 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80094e:	83 c2 01             	add    $0x1,%edx
  800951:	83 c0 01             	add    $0x1,%eax
  800954:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800957:	39 d8                	cmp    %ebx,%eax
  800959:	74 07                	je     800962 <strlcpy+0x2e>
  80095b:	0f b6 0a             	movzbl (%edx),%ecx
  80095e:	84 c9                	test   %cl,%cl
  800960:	75 ec                	jne    80094e <strlcpy+0x1a>
		*dst = '\0';
  800962:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800965:	29 f0                	sub    %esi,%eax
}
  800967:	5b                   	pop    %ebx
  800968:	5e                   	pop    %esi
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800971:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800974:	eb 06                	jmp    80097c <strcmp+0x11>
		p++, q++;
  800976:	83 c1 01             	add    $0x1,%ecx
  800979:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80097c:	0f b6 01             	movzbl (%ecx),%eax
  80097f:	84 c0                	test   %al,%al
  800981:	74 04                	je     800987 <strcmp+0x1c>
  800983:	3a 02                	cmp    (%edx),%al
  800985:	74 ef                	je     800976 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800987:	0f b6 c0             	movzbl %al,%eax
  80098a:	0f b6 12             	movzbl (%edx),%edx
  80098d:	29 d0                	sub    %edx,%eax
}
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	53                   	push   %ebx
  800995:	8b 45 08             	mov    0x8(%ebp),%eax
  800998:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099b:	89 c3                	mov    %eax,%ebx
  80099d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009a0:	eb 06                	jmp    8009a8 <strncmp+0x17>
		n--, p++, q++;
  8009a2:	83 c0 01             	add    $0x1,%eax
  8009a5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009a8:	39 d8                	cmp    %ebx,%eax
  8009aa:	74 16                	je     8009c2 <strncmp+0x31>
  8009ac:	0f b6 08             	movzbl (%eax),%ecx
  8009af:	84 c9                	test   %cl,%cl
  8009b1:	74 04                	je     8009b7 <strncmp+0x26>
  8009b3:	3a 0a                	cmp    (%edx),%cl
  8009b5:	74 eb                	je     8009a2 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b7:	0f b6 00             	movzbl (%eax),%eax
  8009ba:	0f b6 12             	movzbl (%edx),%edx
  8009bd:	29 d0                	sub    %edx,%eax
}
  8009bf:	5b                   	pop    %ebx
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    
		return 0;
  8009c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c7:	eb f6                	jmp    8009bf <strncmp+0x2e>

008009c9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d3:	0f b6 10             	movzbl (%eax),%edx
  8009d6:	84 d2                	test   %dl,%dl
  8009d8:	74 09                	je     8009e3 <strchr+0x1a>
		if (*s == c)
  8009da:	38 ca                	cmp    %cl,%dl
  8009dc:	74 0a                	je     8009e8 <strchr+0x1f>
	for (; *s; s++)
  8009de:	83 c0 01             	add    $0x1,%eax
  8009e1:	eb f0                	jmp    8009d3 <strchr+0xa>
			return (char *) s;
	return 0;
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f4:	eb 03                	jmp    8009f9 <strfind+0xf>
  8009f6:	83 c0 01             	add    $0x1,%eax
  8009f9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009fc:	38 ca                	cmp    %cl,%dl
  8009fe:	74 04                	je     800a04 <strfind+0x1a>
  800a00:	84 d2                	test   %dl,%dl
  800a02:	75 f2                	jne    8009f6 <strfind+0xc>
			break;
	return (char *) s;
}
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	57                   	push   %edi
  800a0a:	56                   	push   %esi
  800a0b:	53                   	push   %ebx
  800a0c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a12:	85 c9                	test   %ecx,%ecx
  800a14:	74 13                	je     800a29 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a16:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1c:	75 05                	jne    800a23 <memset+0x1d>
  800a1e:	f6 c1 03             	test   $0x3,%cl
  800a21:	74 0d                	je     800a30 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a26:	fc                   	cld    
  800a27:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a29:	89 f8                	mov    %edi,%eax
  800a2b:	5b                   	pop    %ebx
  800a2c:	5e                   	pop    %esi
  800a2d:	5f                   	pop    %edi
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    
		c &= 0xFF;
  800a30:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a34:	89 d3                	mov    %edx,%ebx
  800a36:	c1 e3 08             	shl    $0x8,%ebx
  800a39:	89 d0                	mov    %edx,%eax
  800a3b:	c1 e0 18             	shl    $0x18,%eax
  800a3e:	89 d6                	mov    %edx,%esi
  800a40:	c1 e6 10             	shl    $0x10,%esi
  800a43:	09 f0                	or     %esi,%eax
  800a45:	09 c2                	or     %eax,%edx
  800a47:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a49:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a4c:	89 d0                	mov    %edx,%eax
  800a4e:	fc                   	cld    
  800a4f:	f3 ab                	rep stos %eax,%es:(%edi)
  800a51:	eb d6                	jmp    800a29 <memset+0x23>

00800a53 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	57                   	push   %edi
  800a57:	56                   	push   %esi
  800a58:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a61:	39 c6                	cmp    %eax,%esi
  800a63:	73 35                	jae    800a9a <memmove+0x47>
  800a65:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a68:	39 c2                	cmp    %eax,%edx
  800a6a:	76 2e                	jbe    800a9a <memmove+0x47>
		s += n;
		d += n;
  800a6c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6f:	89 d6                	mov    %edx,%esi
  800a71:	09 fe                	or     %edi,%esi
  800a73:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a79:	74 0c                	je     800a87 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a7b:	83 ef 01             	sub    $0x1,%edi
  800a7e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a81:	fd                   	std    
  800a82:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a84:	fc                   	cld    
  800a85:	eb 21                	jmp    800aa8 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a87:	f6 c1 03             	test   $0x3,%cl
  800a8a:	75 ef                	jne    800a7b <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a8c:	83 ef 04             	sub    $0x4,%edi
  800a8f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a92:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a95:	fd                   	std    
  800a96:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a98:	eb ea                	jmp    800a84 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9a:	89 f2                	mov    %esi,%edx
  800a9c:	09 c2                	or     %eax,%edx
  800a9e:	f6 c2 03             	test   $0x3,%dl
  800aa1:	74 09                	je     800aac <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa3:	89 c7                	mov    %eax,%edi
  800aa5:	fc                   	cld    
  800aa6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa8:	5e                   	pop    %esi
  800aa9:	5f                   	pop    %edi
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aac:	f6 c1 03             	test   $0x3,%cl
  800aaf:	75 f2                	jne    800aa3 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ab1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ab4:	89 c7                	mov    %eax,%edi
  800ab6:	fc                   	cld    
  800ab7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab9:	eb ed                	jmp    800aa8 <memmove+0x55>

00800abb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800abe:	ff 75 10             	pushl  0x10(%ebp)
  800ac1:	ff 75 0c             	pushl  0xc(%ebp)
  800ac4:	ff 75 08             	pushl  0x8(%ebp)
  800ac7:	e8 87 ff ff ff       	call   800a53 <memmove>
}
  800acc:	c9                   	leave  
  800acd:	c3                   	ret    

00800ace <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ace:	55                   	push   %ebp
  800acf:	89 e5                	mov    %esp,%ebp
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
  800ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad9:	89 c6                	mov    %eax,%esi
  800adb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ade:	39 f0                	cmp    %esi,%eax
  800ae0:	74 1c                	je     800afe <memcmp+0x30>
		if (*s1 != *s2)
  800ae2:	0f b6 08             	movzbl (%eax),%ecx
  800ae5:	0f b6 1a             	movzbl (%edx),%ebx
  800ae8:	38 d9                	cmp    %bl,%cl
  800aea:	75 08                	jne    800af4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800aec:	83 c0 01             	add    $0x1,%eax
  800aef:	83 c2 01             	add    $0x1,%edx
  800af2:	eb ea                	jmp    800ade <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800af4:	0f b6 c1             	movzbl %cl,%eax
  800af7:	0f b6 db             	movzbl %bl,%ebx
  800afa:	29 d8                	sub    %ebx,%eax
  800afc:	eb 05                	jmp    800b03 <memcmp+0x35>
	}

	return 0;
  800afe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b10:	89 c2                	mov    %eax,%edx
  800b12:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b15:	39 d0                	cmp    %edx,%eax
  800b17:	73 09                	jae    800b22 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b19:	38 08                	cmp    %cl,(%eax)
  800b1b:	74 05                	je     800b22 <memfind+0x1b>
	for (; s < ends; s++)
  800b1d:	83 c0 01             	add    $0x1,%eax
  800b20:	eb f3                	jmp    800b15 <memfind+0xe>
			break;
	return (void *) s;
}
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	57                   	push   %edi
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
  800b2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b30:	eb 03                	jmp    800b35 <strtol+0x11>
		s++;
  800b32:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b35:	0f b6 01             	movzbl (%ecx),%eax
  800b38:	3c 20                	cmp    $0x20,%al
  800b3a:	74 f6                	je     800b32 <strtol+0xe>
  800b3c:	3c 09                	cmp    $0x9,%al
  800b3e:	74 f2                	je     800b32 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b40:	3c 2b                	cmp    $0x2b,%al
  800b42:	74 2e                	je     800b72 <strtol+0x4e>
	int neg = 0;
  800b44:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b49:	3c 2d                	cmp    $0x2d,%al
  800b4b:	74 2f                	je     800b7c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b4d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b53:	75 05                	jne    800b5a <strtol+0x36>
  800b55:	80 39 30             	cmpb   $0x30,(%ecx)
  800b58:	74 2c                	je     800b86 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5a:	85 db                	test   %ebx,%ebx
  800b5c:	75 0a                	jne    800b68 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b5e:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b63:	80 39 30             	cmpb   $0x30,(%ecx)
  800b66:	74 28                	je     800b90 <strtol+0x6c>
		base = 10;
  800b68:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b70:	eb 50                	jmp    800bc2 <strtol+0x9e>
		s++;
  800b72:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b75:	bf 00 00 00 00       	mov    $0x0,%edi
  800b7a:	eb d1                	jmp    800b4d <strtol+0x29>
		s++, neg = 1;
  800b7c:	83 c1 01             	add    $0x1,%ecx
  800b7f:	bf 01 00 00 00       	mov    $0x1,%edi
  800b84:	eb c7                	jmp    800b4d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b86:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b8a:	74 0e                	je     800b9a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b8c:	85 db                	test   %ebx,%ebx
  800b8e:	75 d8                	jne    800b68 <strtol+0x44>
		s++, base = 8;
  800b90:	83 c1 01             	add    $0x1,%ecx
  800b93:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b98:	eb ce                	jmp    800b68 <strtol+0x44>
		s += 2, base = 16;
  800b9a:	83 c1 02             	add    $0x2,%ecx
  800b9d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ba2:	eb c4                	jmp    800b68 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ba4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ba7:	89 f3                	mov    %esi,%ebx
  800ba9:	80 fb 19             	cmp    $0x19,%bl
  800bac:	77 29                	ja     800bd7 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bae:	0f be d2             	movsbl %dl,%edx
  800bb1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bb4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bb7:	7d 30                	jge    800be9 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bb9:	83 c1 01             	add    $0x1,%ecx
  800bbc:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bc0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bc2:	0f b6 11             	movzbl (%ecx),%edx
  800bc5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bc8:	89 f3                	mov    %esi,%ebx
  800bca:	80 fb 09             	cmp    $0x9,%bl
  800bcd:	77 d5                	ja     800ba4 <strtol+0x80>
			dig = *s - '0';
  800bcf:	0f be d2             	movsbl %dl,%edx
  800bd2:	83 ea 30             	sub    $0x30,%edx
  800bd5:	eb dd                	jmp    800bb4 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bd7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bda:	89 f3                	mov    %esi,%ebx
  800bdc:	80 fb 19             	cmp    $0x19,%bl
  800bdf:	77 08                	ja     800be9 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800be1:	0f be d2             	movsbl %dl,%edx
  800be4:	83 ea 37             	sub    $0x37,%edx
  800be7:	eb cb                	jmp    800bb4 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800be9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bed:	74 05                	je     800bf4 <strtol+0xd0>
		*endptr = (char *) s;
  800bef:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bf4:	89 c2                	mov    %eax,%edx
  800bf6:	f7 da                	neg    %edx
  800bf8:	85 ff                	test   %edi,%edi
  800bfa:	0f 45 c2             	cmovne %edx,%eax
}
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    
  800c02:	66 90                	xchg   %ax,%ax
  800c04:	66 90                	xchg   %ax,%ax
  800c06:	66 90                	xchg   %ax,%ax
  800c08:	66 90                	xchg   %ax,%ax
  800c0a:	66 90                	xchg   %ax,%ax
  800c0c:	66 90                	xchg   %ax,%ax
  800c0e:	66 90                	xchg   %ax,%ax

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
