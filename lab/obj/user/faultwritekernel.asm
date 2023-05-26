
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	53                   	push   %ebx
  800046:	83 ec 04             	sub    $0x4,%esp
  800049:	e8 3b 00 00 00       	call   800089 <__x86.get_pc_thunk.bx>
  80004e:	81 c3 b2 1f 00 00    	add    $0x1fb2,%ebx
  800054:	8b 45 08             	mov    0x8(%ebp),%eax
  800057:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005a:	c7 c1 2c 20 80 00    	mov    $0x80202c,%ecx
  800060:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800066:	85 c0                	test   %eax,%eax
  800068:	7e 08                	jle    800072 <libmain+0x30>
		binaryname = argv[0];
  80006a:	8b 0a                	mov    (%edx),%ecx
  80006c:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800072:	83 ec 08             	sub    $0x8,%esp
  800075:	52                   	push   %edx
  800076:	50                   	push   %eax
  800077:	e8 b7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007c:	e8 0c 00 00 00       	call   80008d <exit>
}
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800087:	c9                   	leave  
  800088:	c3                   	ret    

00800089 <__x86.get_pc_thunk.bx>:
  800089:	8b 1c 24             	mov    (%esp),%ebx
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	53                   	push   %ebx
  800091:	83 ec 10             	sub    $0x10,%esp
  800094:	e8 f0 ff ff ff       	call   800089 <__x86.get_pc_thunk.bx>
  800099:	81 c3 67 1f 00 00    	add    $0x1f67,%ebx
	sys_env_destroy(0);
  80009f:	6a 00                	push   $0x0
  8000a1:	e8 45 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 1c             	sub    $0x1c,%esp
  8000f4:	e8 66 00 00 00       	call   80015f <__x86.get_pc_thunk.ax>
  8000f9:	05 07 1f 00 00       	add    $0x1f07,%eax
  8000fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800101:	b9 00 00 00 00       	mov    $0x0,%ecx
  800106:	8b 55 08             	mov    0x8(%ebp),%edx
  800109:	b8 03 00 00 00       	mov    $0x3,%eax
  80010e:	89 cb                	mov    %ecx,%ebx
  800110:	89 cf                	mov    %ecx,%edi
  800112:	89 ce                	mov    %ecx,%esi
  800114:	cd 30                	int    $0x30
	if(check && ret > 0)
  800116:	85 c0                	test   %eax,%eax
  800118:	7f 08                	jg     800122 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011d:	5b                   	pop    %ebx
  80011e:	5e                   	pop    %esi
  80011f:	5f                   	pop    %edi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800122:	83 ec 0c             	sub    $0xc,%esp
  800125:	50                   	push   %eax
  800126:	6a 03                	push   $0x3
  800128:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80012b:	8d 83 56 ee ff ff    	lea    -0x11aa(%ebx),%eax
  800131:	50                   	push   %eax
  800132:	6a 23                	push   $0x23
  800134:	8d 83 73 ee ff ff    	lea    -0x118d(%ebx),%eax
  80013a:	50                   	push   %eax
  80013b:	e8 23 00 00 00       	call   800163 <_panic>

00800140 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	57                   	push   %edi
  800144:	56                   	push   %esi
  800145:	53                   	push   %ebx
	asm volatile("int %1\n"
  800146:	ba 00 00 00 00       	mov    $0x0,%edx
  80014b:	b8 02 00 00 00       	mov    $0x2,%eax
  800150:	89 d1                	mov    %edx,%ecx
  800152:	89 d3                	mov    %edx,%ebx
  800154:	89 d7                	mov    %edx,%edi
  800156:	89 d6                	mov    %edx,%esi
  800158:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015a:	5b                   	pop    %ebx
  80015b:	5e                   	pop    %esi
  80015c:	5f                   	pop    %edi
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <__x86.get_pc_thunk.ax>:
  80015f:	8b 04 24             	mov    (%esp),%eax
  800162:	c3                   	ret    

00800163 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
  80016c:	e8 18 ff ff ff       	call   800089 <__x86.get_pc_thunk.bx>
  800171:	81 c3 8f 1e 00 00    	add    $0x1e8f,%ebx
	va_list ap;

	va_start(ap, fmt);
  800177:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80017a:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800180:	8b 38                	mov    (%eax),%edi
  800182:	e8 b9 ff ff ff       	call   800140 <sys_getenvid>
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	ff 75 0c             	pushl  0xc(%ebp)
  80018d:	ff 75 08             	pushl  0x8(%ebp)
  800190:	57                   	push   %edi
  800191:	50                   	push   %eax
  800192:	8d 83 84 ee ff ff    	lea    -0x117c(%ebx),%eax
  800198:	50                   	push   %eax
  800199:	e8 d1 00 00 00       	call   80026f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019e:	83 c4 18             	add    $0x18,%esp
  8001a1:	56                   	push   %esi
  8001a2:	ff 75 10             	pushl  0x10(%ebp)
  8001a5:	e8 63 00 00 00       	call   80020d <vcprintf>
	cprintf("\n");
  8001aa:	8d 83 a8 ee ff ff    	lea    -0x1158(%ebx),%eax
  8001b0:	89 04 24             	mov    %eax,(%esp)
  8001b3:	e8 b7 00 00 00       	call   80026f <cprintf>
  8001b8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001bb:	cc                   	int3   
  8001bc:	eb fd                	jmp    8001bb <_panic+0x58>

008001be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	56                   	push   %esi
  8001c2:	53                   	push   %ebx
  8001c3:	e8 c1 fe ff ff       	call   800089 <__x86.get_pc_thunk.bx>
  8001c8:	81 c3 38 1e 00 00    	add    $0x1e38,%ebx
  8001ce:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001d1:	8b 16                	mov    (%esi),%edx
  8001d3:	8d 42 01             	lea    0x1(%edx),%eax
  8001d6:	89 06                	mov    %eax,(%esi)
  8001d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001db:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001df:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e4:	74 0b                	je     8001f1 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001e6:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ed:	5b                   	pop    %ebx
  8001ee:	5e                   	pop    %esi
  8001ef:	5d                   	pop    %ebp
  8001f0:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001f1:	83 ec 08             	sub    $0x8,%esp
  8001f4:	68 ff 00 00 00       	push   $0xff
  8001f9:	8d 46 08             	lea    0x8(%esi),%eax
  8001fc:	50                   	push   %eax
  8001fd:	e8 ac fe ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  800202:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800208:	83 c4 10             	add    $0x10,%esp
  80020b:	eb d9                	jmp    8001e6 <putch+0x28>

0080020d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80020d:	55                   	push   %ebp
  80020e:	89 e5                	mov    %esp,%ebp
  800210:	53                   	push   %ebx
  800211:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800217:	e8 6d fe ff ff       	call   800089 <__x86.get_pc_thunk.bx>
  80021c:	81 c3 e4 1d 00 00    	add    $0x1de4,%ebx
	struct printbuf b;

	b.idx = 0;
  800222:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800229:	00 00 00 
	b.cnt = 0;
  80022c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800233:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800236:	ff 75 0c             	pushl  0xc(%ebp)
  800239:	ff 75 08             	pushl  0x8(%ebp)
  80023c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800242:	50                   	push   %eax
  800243:	8d 83 be e1 ff ff    	lea    -0x1e42(%ebx),%eax
  800249:	50                   	push   %eax
  80024a:	e8 38 01 00 00       	call   800387 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024f:	83 c4 08             	add    $0x8,%esp
  800252:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800258:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025e:	50                   	push   %eax
  80025f:	e8 4a fe ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  800264:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80026d:	c9                   	leave  
  80026e:	c3                   	ret    

0080026f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800275:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800278:	50                   	push   %eax
  800279:	ff 75 08             	pushl  0x8(%ebp)
  80027c:	e8 8c ff ff ff       	call   80020d <vcprintf>
	va_end(ap);

	return cnt;
}
  800281:	c9                   	leave  
  800282:	c3                   	ret    

00800283 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	57                   	push   %edi
  800287:	56                   	push   %esi
  800288:	53                   	push   %ebx
  800289:	83 ec 2c             	sub    $0x2c,%esp
  80028c:	e8 02 06 00 00       	call   800893 <__x86.get_pc_thunk.cx>
  800291:	81 c1 6f 1d 00 00    	add    $0x1d6f,%ecx
  800297:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80029a:	89 c7                	mov    %eax,%edi
  80029c:	89 d6                	mov    %edx,%esi
  80029e:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002a7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  8002aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002b5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002b8:	39 d3                	cmp    %edx,%ebx
  8002ba:	72 09                	jb     8002c5 <printnum+0x42>
  8002bc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002bf:	0f 87 83 00 00 00    	ja     800348 <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c5:	83 ec 0c             	sub    $0xc,%esp
  8002c8:	ff 75 18             	pushl  0x18(%ebp)
  8002cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ce:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002d1:	53                   	push   %ebx
  8002d2:	ff 75 10             	pushl  0x10(%ebp)
  8002d5:	83 ec 08             	sub    $0x8,%esp
  8002d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002db:	ff 75 d8             	pushl  -0x28(%ebp)
  8002de:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002e1:	ff 75 d0             	pushl  -0x30(%ebp)
  8002e4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002e7:	e8 24 09 00 00       	call   800c10 <__udivdi3>
  8002ec:	83 c4 18             	add    $0x18,%esp
  8002ef:	52                   	push   %edx
  8002f0:	50                   	push   %eax
  8002f1:	89 f2                	mov    %esi,%edx
  8002f3:	89 f8                	mov    %edi,%eax
  8002f5:	e8 89 ff ff ff       	call   800283 <printnum>
  8002fa:	83 c4 20             	add    $0x20,%esp
  8002fd:	eb 13                	jmp    800312 <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	ff 75 18             	pushl  0x18(%ebp)
  800306:	ff d7                	call   *%edi
  800308:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80030b:	83 eb 01             	sub    $0x1,%ebx
  80030e:	85 db                	test   %ebx,%ebx
  800310:	7f ed                	jg     8002ff <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800312:	83 ec 08             	sub    $0x8,%esp
  800315:	56                   	push   %esi
  800316:	83 ec 04             	sub    $0x4,%esp
  800319:	ff 75 dc             	pushl  -0x24(%ebp)
  80031c:	ff 75 d8             	pushl  -0x28(%ebp)
  80031f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800322:	ff 75 d0             	pushl  -0x30(%ebp)
  800325:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800328:	89 f3                	mov    %esi,%ebx
  80032a:	e8 01 0a 00 00       	call   800d30 <__umoddi3>
  80032f:	83 c4 14             	add    $0x14,%esp
  800332:	0f be 84 06 aa ee ff 	movsbl -0x1156(%esi,%eax,1),%eax
  800339:	ff 
  80033a:	50                   	push   %eax
  80033b:	ff d7                	call   *%edi
}
  80033d:	83 c4 10             	add    $0x10,%esp
  800340:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800343:	5b                   	pop    %ebx
  800344:	5e                   	pop    %esi
  800345:	5f                   	pop    %edi
  800346:	5d                   	pop    %ebp
  800347:	c3                   	ret    
  800348:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80034b:	eb be                	jmp    80030b <printnum+0x88>

0080034d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800353:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800357:	8b 10                	mov    (%eax),%edx
  800359:	3b 50 04             	cmp    0x4(%eax),%edx
  80035c:	73 0a                	jae    800368 <sprintputch+0x1b>
		*b->buf++ = ch;
  80035e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800361:	89 08                	mov    %ecx,(%eax)
  800363:	8b 45 08             	mov    0x8(%ebp),%eax
  800366:	88 02                	mov    %al,(%edx)
}
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <printfmt>:
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800370:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800373:	50                   	push   %eax
  800374:	ff 75 10             	pushl  0x10(%ebp)
  800377:	ff 75 0c             	pushl  0xc(%ebp)
  80037a:	ff 75 08             	pushl  0x8(%ebp)
  80037d:	e8 05 00 00 00       	call   800387 <vprintfmt>
}
  800382:	83 c4 10             	add    $0x10,%esp
  800385:	c9                   	leave  
  800386:	c3                   	ret    

00800387 <vprintfmt>:
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	57                   	push   %edi
  80038b:	56                   	push   %esi
  80038c:	53                   	push   %ebx
  80038d:	83 ec 2c             	sub    $0x2c,%esp
  800390:	e8 f4 fc ff ff       	call   800089 <__x86.get_pc_thunk.bx>
  800395:	81 c3 6b 1c 00 00    	add    $0x1c6b,%ebx
  80039b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80039e:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003a1:	e9 c3 03 00 00       	jmp    800769 <.L35+0x48>
		padc = ' ';
  8003a6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003aa:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003b1:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003b8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8003c7:	8d 47 01             	lea    0x1(%edi),%eax
  8003ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003cd:	0f b6 17             	movzbl (%edi),%edx
  8003d0:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003d3:	3c 55                	cmp    $0x55,%al
  8003d5:	0f 87 16 04 00 00    	ja     8007f1 <.L22>
  8003db:	0f b6 c0             	movzbl %al,%eax
  8003de:	89 d9                	mov    %ebx,%ecx
  8003e0:	03 8c 83 38 ef ff ff 	add    -0x10c8(%ebx,%eax,4),%ecx
  8003e7:	ff e1                	jmp    *%ecx

008003e9 <.L69>:
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003ec:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003f0:	eb d5                	jmp    8003c7 <vprintfmt+0x40>

008003f2 <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8003f5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f9:	eb cc                	jmp    8003c7 <vprintfmt+0x40>

008003fb <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8003fb:	0f b6 d2             	movzbl %dl,%edx
  8003fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
  800401:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800406:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800409:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80040d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800410:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800413:	83 f9 09             	cmp    $0x9,%ecx
  800416:	77 55                	ja     80046d <.L23+0xf>
			for (precision = 0;; ++fmt)
  800418:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80041b:	eb e9                	jmp    800406 <.L29+0xb>

0080041d <.L26>:
			precision = va_arg(ap, int);
  80041d:	8b 45 14             	mov    0x14(%ebp),%eax
  800420:	8b 00                	mov    (%eax),%eax
  800422:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800425:	8b 45 14             	mov    0x14(%ebp),%eax
  800428:	8d 40 04             	lea    0x4(%eax),%eax
  80042b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80042e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800431:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800435:	79 90                	jns    8003c7 <vprintfmt+0x40>
				width = precision, precision = -1;
  800437:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80043a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800444:	eb 81                	jmp    8003c7 <vprintfmt+0x40>

00800446 <.L27>:
  800446:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800449:	85 c0                	test   %eax,%eax
  80044b:	ba 00 00 00 00       	mov    $0x0,%edx
  800450:	0f 49 d0             	cmovns %eax,%edx
  800453:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800459:	e9 69 ff ff ff       	jmp    8003c7 <vprintfmt+0x40>

0080045e <.L23>:
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800461:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800468:	e9 5a ff ff ff       	jmp    8003c7 <vprintfmt+0x40>
  80046d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800470:	eb bf                	jmp    800431 <.L26+0x14>

00800472 <.L33>:
			lflag++;
  800472:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800479:	e9 49 ff ff ff       	jmp    8003c7 <vprintfmt+0x40>

0080047e <.L30>:
			putch(va_arg(ap, int), putdat);
  80047e:	8b 45 14             	mov    0x14(%ebp),%eax
  800481:	8d 78 04             	lea    0x4(%eax),%edi
  800484:	83 ec 08             	sub    $0x8,%esp
  800487:	56                   	push   %esi
  800488:	ff 30                	pushl  (%eax)
  80048a:	ff 55 08             	call   *0x8(%ebp)
			break;
  80048d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800490:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800493:	e9 ce 02 00 00       	jmp    800766 <.L35+0x45>

00800498 <.L32>:
			err = va_arg(ap, int);
  800498:	8b 45 14             	mov    0x14(%ebp),%eax
  80049b:	8d 78 04             	lea    0x4(%eax),%edi
  80049e:	8b 00                	mov    (%eax),%eax
  8004a0:	99                   	cltd   
  8004a1:	31 d0                	xor    %edx,%eax
  8004a3:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a5:	83 f8 06             	cmp    $0x6,%eax
  8004a8:	7f 27                	jg     8004d1 <.L32+0x39>
  8004aa:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004b1:	85 d2                	test   %edx,%edx
  8004b3:	74 1c                	je     8004d1 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004b5:	52                   	push   %edx
  8004b6:	8d 83 cb ee ff ff    	lea    -0x1135(%ebx),%eax
  8004bc:	50                   	push   %eax
  8004bd:	56                   	push   %esi
  8004be:	ff 75 08             	pushl  0x8(%ebp)
  8004c1:	e8 a4 fe ff ff       	call   80036a <printfmt>
  8004c6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004c9:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004cc:	e9 95 02 00 00       	jmp    800766 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004d1:	50                   	push   %eax
  8004d2:	8d 83 c2 ee ff ff    	lea    -0x113e(%ebx),%eax
  8004d8:	50                   	push   %eax
  8004d9:	56                   	push   %esi
  8004da:	ff 75 08             	pushl  0x8(%ebp)
  8004dd:	e8 88 fe ff ff       	call   80036a <printfmt>
  8004e2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004e5:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004e8:	e9 79 02 00 00       	jmp    800766 <.L35+0x45>

008004ed <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  8004ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f0:	83 c0 04             	add    $0x4,%eax
  8004f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004fb:	85 ff                	test   %edi,%edi
  8004fd:	8d 83 bb ee ff ff    	lea    -0x1145(%ebx),%eax
  800503:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800506:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80050a:	0f 8e b5 00 00 00    	jle    8005c5 <.L36+0xd8>
  800510:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800514:	75 08                	jne    80051e <.L36+0x31>
  800516:	89 75 0c             	mov    %esi,0xc(%ebp)
  800519:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80051c:	eb 6d                	jmp    80058b <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	ff 75 cc             	pushl  -0x34(%ebp)
  800524:	57                   	push   %edi
  800525:	e8 85 03 00 00       	call   8008af <strnlen>
  80052a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80052d:	29 c2                	sub    %eax,%edx
  80052f:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800532:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800535:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800539:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80053c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80053f:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800541:	eb 10                	jmp    800553 <.L36+0x66>
					putch(padc, putdat);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	56                   	push   %esi
  800547:	ff 75 e0             	pushl  -0x20(%ebp)
  80054a:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80054d:	83 ef 01             	sub    $0x1,%edi
  800550:	83 c4 10             	add    $0x10,%esp
  800553:	85 ff                	test   %edi,%edi
  800555:	7f ec                	jg     800543 <.L36+0x56>
  800557:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80055a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80055d:	85 d2                	test   %edx,%edx
  80055f:	b8 00 00 00 00       	mov    $0x0,%eax
  800564:	0f 49 c2             	cmovns %edx,%eax
  800567:	29 c2                	sub    %eax,%edx
  800569:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80056c:	89 75 0c             	mov    %esi,0xc(%ebp)
  80056f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800572:	eb 17                	jmp    80058b <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  800574:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800578:	75 30                	jne    8005aa <.L36+0xbd>
					putch(ch, putdat);
  80057a:	83 ec 08             	sub    $0x8,%esp
  80057d:	ff 75 0c             	pushl  0xc(%ebp)
  800580:	50                   	push   %eax
  800581:	ff 55 08             	call   *0x8(%ebp)
  800584:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800587:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80058b:	83 c7 01             	add    $0x1,%edi
  80058e:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800592:	0f be c2             	movsbl %dl,%eax
  800595:	85 c0                	test   %eax,%eax
  800597:	74 52                	je     8005eb <.L36+0xfe>
  800599:	85 f6                	test   %esi,%esi
  80059b:	78 d7                	js     800574 <.L36+0x87>
  80059d:	83 ee 01             	sub    $0x1,%esi
  8005a0:	79 d2                	jns    800574 <.L36+0x87>
  8005a2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005a5:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005a8:	eb 32                	jmp    8005dc <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005aa:	0f be d2             	movsbl %dl,%edx
  8005ad:	83 ea 20             	sub    $0x20,%edx
  8005b0:	83 fa 5e             	cmp    $0x5e,%edx
  8005b3:	76 c5                	jbe    80057a <.L36+0x8d>
					putch('?', putdat);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	ff 75 0c             	pushl  0xc(%ebp)
  8005bb:	6a 3f                	push   $0x3f
  8005bd:	ff 55 08             	call   *0x8(%ebp)
  8005c0:	83 c4 10             	add    $0x10,%esp
  8005c3:	eb c2                	jmp    800587 <.L36+0x9a>
  8005c5:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005c8:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005cb:	eb be                	jmp    80058b <.L36+0x9e>
				putch(' ', putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	56                   	push   %esi
  8005d1:	6a 20                	push   $0x20
  8005d3:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8005d6:	83 ef 01             	sub    $0x1,%edi
  8005d9:	83 c4 10             	add    $0x10,%esp
  8005dc:	85 ff                	test   %edi,%edi
  8005de:	7f ed                	jg     8005cd <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  8005e0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005e3:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e6:	e9 7b 01 00 00       	jmp    800766 <.L35+0x45>
  8005eb:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005f1:	eb e9                	jmp    8005dc <.L36+0xef>

008005f3 <.L31>:
  8005f3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8005f6:	83 f9 01             	cmp    $0x1,%ecx
  8005f9:	7e 40                	jle    80063b <.L31+0x48>
		return va_arg(*ap, long long);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8b 50 04             	mov    0x4(%eax),%edx
  800601:	8b 00                	mov    (%eax),%eax
  800603:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800606:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
  80060c:	8d 40 08             	lea    0x8(%eax),%eax
  80060f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
  800612:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800616:	79 55                	jns    80066d <.L31+0x7a>
				putch('-', putdat);
  800618:	83 ec 08             	sub    $0x8,%esp
  80061b:	56                   	push   %esi
  80061c:	6a 2d                	push   $0x2d
  80061e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  800621:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800624:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800627:	f7 da                	neg    %edx
  800629:	83 d1 00             	adc    $0x0,%ecx
  80062c:	f7 d9                	neg    %ecx
  80062e:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
  800631:	b8 0a 00 00 00       	mov    $0xa,%eax
  800636:	e9 10 01 00 00       	jmp    80074b <.L35+0x2a>
	else if (lflag)
  80063b:	85 c9                	test   %ecx,%ecx
  80063d:	75 17                	jne    800656 <.L31+0x63>
		return va_arg(*ap, int);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8b 00                	mov    (%eax),%eax
  800644:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800647:	99                   	cltd   
  800648:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8d 40 04             	lea    0x4(%eax),%eax
  800651:	89 45 14             	mov    %eax,0x14(%ebp)
  800654:	eb bc                	jmp    800612 <.L31+0x1f>
		return va_arg(*ap, long);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 00                	mov    (%eax),%eax
  80065b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065e:	99                   	cltd   
  80065f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8d 40 04             	lea    0x4(%eax),%eax
  800668:	89 45 14             	mov    %eax,0x14(%ebp)
  80066b:	eb a5                	jmp    800612 <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  80066d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800670:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
  800673:	b8 0a 00 00 00       	mov    $0xa,%eax
  800678:	e9 ce 00 00 00       	jmp    80074b <.L35+0x2a>

0080067d <.L37>:
  80067d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800680:	83 f9 01             	cmp    $0x1,%ecx
  800683:	7e 18                	jle    80069d <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  800685:	8b 45 14             	mov    0x14(%ebp),%eax
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	8b 48 04             	mov    0x4(%eax),%ecx
  80068d:	8d 40 08             	lea    0x8(%eax),%eax
  800690:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800693:	b8 0a 00 00 00       	mov    $0xa,%eax
  800698:	e9 ae 00 00 00       	jmp    80074b <.L35+0x2a>
	else if (lflag)
  80069d:	85 c9                	test   %ecx,%ecx
  80069f:	75 1a                	jne    8006bb <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8006a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a4:	8b 10                	mov    (%eax),%edx
  8006a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ab:	8d 40 04             	lea    0x4(%eax),%eax
  8006ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b6:	e9 90 00 00 00       	jmp    80074b <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8b 10                	mov    (%eax),%edx
  8006c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c5:	8d 40 04             	lea    0x4(%eax),%eax
  8006c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d0:	eb 79                	jmp    80074b <.L35+0x2a>

008006d2 <.L34>:
  8006d2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006d5:	83 f9 01             	cmp    $0x1,%ecx
  8006d8:	7e 15                	jle    8006ef <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  8006da:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dd:	8b 10                	mov    (%eax),%edx
  8006df:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e2:	8d 40 08             	lea    0x8(%eax),%eax
  8006e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006e8:	b8 08 00 00 00       	mov    $0x8,%eax
  8006ed:	eb 5c                	jmp    80074b <.L35+0x2a>
	else if (lflag)
  8006ef:	85 c9                	test   %ecx,%ecx
  8006f1:	75 17                	jne    80070a <.L34+0x38>
		return va_arg(*ap, unsigned int);
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8b 10                	mov    (%eax),%edx
  8006f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fd:	8d 40 04             	lea    0x4(%eax),%eax
  800700:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800703:	b8 08 00 00 00       	mov    $0x8,%eax
  800708:	eb 41                	jmp    80074b <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8b 10                	mov    (%eax),%edx
  80070f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800714:	8d 40 04             	lea    0x4(%eax),%eax
  800717:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80071a:	b8 08 00 00 00       	mov    $0x8,%eax
  80071f:	eb 2a                	jmp    80074b <.L35+0x2a>

00800721 <.L35>:
			putch('0', putdat);
  800721:	83 ec 08             	sub    $0x8,%esp
  800724:	56                   	push   %esi
  800725:	6a 30                	push   $0x30
  800727:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80072a:	83 c4 08             	add    $0x8,%esp
  80072d:	56                   	push   %esi
  80072e:	6a 78                	push   $0x78
  800730:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800733:	8b 45 14             	mov    0x14(%ebp),%eax
  800736:	8b 10                	mov    (%eax),%edx
  800738:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80073d:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800740:	8d 40 04             	lea    0x4(%eax),%eax
  800743:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800746:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  80074b:	83 ec 0c             	sub    $0xc,%esp
  80074e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800752:	57                   	push   %edi
  800753:	ff 75 e0             	pushl  -0x20(%ebp)
  800756:	50                   	push   %eax
  800757:	51                   	push   %ecx
  800758:	52                   	push   %edx
  800759:	89 f2                	mov    %esi,%edx
  80075b:	8b 45 08             	mov    0x8(%ebp),%eax
  80075e:	e8 20 fb ff ff       	call   800283 <printnum>
			break;
  800763:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800766:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  800769:	83 c7 01             	add    $0x1,%edi
  80076c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800770:	83 f8 25             	cmp    $0x25,%eax
  800773:	0f 84 2d fc ff ff    	je     8003a6 <vprintfmt+0x1f>
			if (ch == '\0')
  800779:	85 c0                	test   %eax,%eax
  80077b:	0f 84 91 00 00 00    	je     800812 <.L22+0x21>
			putch(ch, putdat);
  800781:	83 ec 08             	sub    $0x8,%esp
  800784:	56                   	push   %esi
  800785:	50                   	push   %eax
  800786:	ff 55 08             	call   *0x8(%ebp)
  800789:	83 c4 10             	add    $0x10,%esp
  80078c:	eb db                	jmp    800769 <.L35+0x48>

0080078e <.L38>:
  80078e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800791:	83 f9 01             	cmp    $0x1,%ecx
  800794:	7e 15                	jle    8007ab <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  800796:	8b 45 14             	mov    0x14(%ebp),%eax
  800799:	8b 10                	mov    (%eax),%edx
  80079b:	8b 48 04             	mov    0x4(%eax),%ecx
  80079e:	8d 40 08             	lea    0x8(%eax),%eax
  8007a1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a4:	b8 10 00 00 00       	mov    $0x10,%eax
  8007a9:	eb a0                	jmp    80074b <.L35+0x2a>
	else if (lflag)
  8007ab:	85 c9                	test   %ecx,%ecx
  8007ad:	75 17                	jne    8007c6 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007af:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b2:	8b 10                	mov    (%eax),%edx
  8007b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b9:	8d 40 04             	lea    0x4(%eax),%eax
  8007bc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007bf:	b8 10 00 00 00       	mov    $0x10,%eax
  8007c4:	eb 85                	jmp    80074b <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	8b 10                	mov    (%eax),%edx
  8007cb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d0:	8d 40 04             	lea    0x4(%eax),%eax
  8007d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d6:	b8 10 00 00 00       	mov    $0x10,%eax
  8007db:	e9 6b ff ff ff       	jmp    80074b <.L35+0x2a>

008007e0 <.L25>:
			putch(ch, putdat);
  8007e0:	83 ec 08             	sub    $0x8,%esp
  8007e3:	56                   	push   %esi
  8007e4:	6a 25                	push   $0x25
  8007e6:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007e9:	83 c4 10             	add    $0x10,%esp
  8007ec:	e9 75 ff ff ff       	jmp    800766 <.L35+0x45>

008007f1 <.L22>:
			putch('%', putdat);
  8007f1:	83 ec 08             	sub    $0x8,%esp
  8007f4:	56                   	push   %esi
  8007f5:	6a 25                	push   $0x25
  8007f7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007fa:	83 c4 10             	add    $0x10,%esp
  8007fd:	89 f8                	mov    %edi,%eax
  8007ff:	eb 03                	jmp    800804 <.L22+0x13>
  800801:	83 e8 01             	sub    $0x1,%eax
  800804:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800808:	75 f7                	jne    800801 <.L22+0x10>
  80080a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80080d:	e9 54 ff ff ff       	jmp    800766 <.L35+0x45>
}
  800812:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800815:	5b                   	pop    %ebx
  800816:	5e                   	pop    %esi
  800817:	5f                   	pop    %edi
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	53                   	push   %ebx
  80081e:	83 ec 14             	sub    $0x14,%esp
  800821:	e8 63 f8 ff ff       	call   800089 <__x86.get_pc_thunk.bx>
  800826:	81 c3 da 17 00 00    	add    $0x17da,%ebx
  80082c:	8b 45 08             	mov    0x8(%ebp),%eax
  80082f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  800832:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800835:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800839:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80083c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800843:	85 c0                	test   %eax,%eax
  800845:	74 2b                	je     800872 <vsnprintf+0x58>
  800847:	85 d2                	test   %edx,%edx
  800849:	7e 27                	jle    800872 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  80084b:	ff 75 14             	pushl  0x14(%ebp)
  80084e:	ff 75 10             	pushl  0x10(%ebp)
  800851:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800854:	50                   	push   %eax
  800855:	8d 83 4d e3 ff ff    	lea    -0x1cb3(%ebx),%eax
  80085b:	50                   	push   %eax
  80085c:	e8 26 fb ff ff       	call   800387 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800861:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800864:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800867:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086a:	83 c4 10             	add    $0x10,%esp
}
  80086d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800870:	c9                   	leave  
  800871:	c3                   	ret    
		return -E_INVAL;
  800872:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800877:	eb f4                	jmp    80086d <vsnprintf+0x53>

00800879 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80087f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800882:	50                   	push   %eax
  800883:	ff 75 10             	pushl  0x10(%ebp)
  800886:	ff 75 0c             	pushl  0xc(%ebp)
  800889:	ff 75 08             	pushl  0x8(%ebp)
  80088c:	e8 89 ff ff ff       	call   80081a <vsnprintf>
	va_end(ap);

	return rc;
}
  800891:	c9                   	leave  
  800892:	c3                   	ret    

00800893 <__x86.get_pc_thunk.cx>:
  800893:	8b 0c 24             	mov    (%esp),%ecx
  800896:	c3                   	ret    

00800897 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a2:	eb 03                	jmp    8008a7 <strlen+0x10>
		n++;
  8008a4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008a7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008ab:	75 f7                	jne    8008a4 <strlen+0xd>
	return n;
}
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    

008008af <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bd:	eb 03                	jmp    8008c2 <strnlen+0x13>
		n++;
  8008bf:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c2:	39 d0                	cmp    %edx,%eax
  8008c4:	74 06                	je     8008cc <strnlen+0x1d>
  8008c6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008ca:	75 f3                	jne    8008bf <strnlen+0x10>
	return n;
}
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	53                   	push   %ebx
  8008d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d8:	89 c2                	mov    %eax,%edx
  8008da:	83 c1 01             	add    $0x1,%ecx
  8008dd:	83 c2 01             	add    $0x1,%edx
  8008e0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008e4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008e7:	84 db                	test   %bl,%bl
  8008e9:	75 ef                	jne    8008da <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008eb:	5b                   	pop    %ebx
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	53                   	push   %ebx
  8008f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008f5:	53                   	push   %ebx
  8008f6:	e8 9c ff ff ff       	call   800897 <strlen>
  8008fb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008fe:	ff 75 0c             	pushl  0xc(%ebp)
  800901:	01 d8                	add    %ebx,%eax
  800903:	50                   	push   %eax
  800904:	e8 c5 ff ff ff       	call   8008ce <strcpy>
	return dst;
}
  800909:	89 d8                	mov    %ebx,%eax
  80090b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80090e:	c9                   	leave  
  80090f:	c3                   	ret    

00800910 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	56                   	push   %esi
  800914:	53                   	push   %ebx
  800915:	8b 75 08             	mov    0x8(%ebp),%esi
  800918:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091b:	89 f3                	mov    %esi,%ebx
  80091d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800920:	89 f2                	mov    %esi,%edx
  800922:	eb 0f                	jmp    800933 <strncpy+0x23>
		*dst++ = *src;
  800924:	83 c2 01             	add    $0x1,%edx
  800927:	0f b6 01             	movzbl (%ecx),%eax
  80092a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80092d:	80 39 01             	cmpb   $0x1,(%ecx)
  800930:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800933:	39 da                	cmp    %ebx,%edx
  800935:	75 ed                	jne    800924 <strncpy+0x14>
	}
	return ret;
}
  800937:	89 f0                	mov    %esi,%eax
  800939:	5b                   	pop    %ebx
  80093a:	5e                   	pop    %esi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	56                   	push   %esi
  800941:	53                   	push   %ebx
  800942:	8b 75 08             	mov    0x8(%ebp),%esi
  800945:	8b 55 0c             	mov    0xc(%ebp),%edx
  800948:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80094b:	89 f0                	mov    %esi,%eax
  80094d:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800951:	85 c9                	test   %ecx,%ecx
  800953:	75 0b                	jne    800960 <strlcpy+0x23>
  800955:	eb 17                	jmp    80096e <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800957:	83 c2 01             	add    $0x1,%edx
  80095a:	83 c0 01             	add    $0x1,%eax
  80095d:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800960:	39 d8                	cmp    %ebx,%eax
  800962:	74 07                	je     80096b <strlcpy+0x2e>
  800964:	0f b6 0a             	movzbl (%edx),%ecx
  800967:	84 c9                	test   %cl,%cl
  800969:	75 ec                	jne    800957 <strlcpy+0x1a>
		*dst = '\0';
  80096b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80096e:	29 f0                	sub    %esi,%eax
}
  800970:	5b                   	pop    %ebx
  800971:	5e                   	pop    %esi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80097d:	eb 06                	jmp    800985 <strcmp+0x11>
		p++, q++;
  80097f:	83 c1 01             	add    $0x1,%ecx
  800982:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800985:	0f b6 01             	movzbl (%ecx),%eax
  800988:	84 c0                	test   %al,%al
  80098a:	74 04                	je     800990 <strcmp+0x1c>
  80098c:	3a 02                	cmp    (%edx),%al
  80098e:	74 ef                	je     80097f <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800990:	0f b6 c0             	movzbl %al,%eax
  800993:	0f b6 12             	movzbl (%edx),%edx
  800996:	29 d0                	sub    %edx,%eax
}
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	53                   	push   %ebx
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a4:	89 c3                	mov    %eax,%ebx
  8009a6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009a9:	eb 06                	jmp    8009b1 <strncmp+0x17>
		n--, p++, q++;
  8009ab:	83 c0 01             	add    $0x1,%eax
  8009ae:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009b1:	39 d8                	cmp    %ebx,%eax
  8009b3:	74 16                	je     8009cb <strncmp+0x31>
  8009b5:	0f b6 08             	movzbl (%eax),%ecx
  8009b8:	84 c9                	test   %cl,%cl
  8009ba:	74 04                	je     8009c0 <strncmp+0x26>
  8009bc:	3a 0a                	cmp    (%edx),%cl
  8009be:	74 eb                	je     8009ab <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c0:	0f b6 00             	movzbl (%eax),%eax
  8009c3:	0f b6 12             	movzbl (%edx),%edx
  8009c6:	29 d0                	sub    %edx,%eax
}
  8009c8:	5b                   	pop    %ebx
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    
		return 0;
  8009cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d0:	eb f6                	jmp    8009c8 <strncmp+0x2e>

008009d2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009dc:	0f b6 10             	movzbl (%eax),%edx
  8009df:	84 d2                	test   %dl,%dl
  8009e1:	74 09                	je     8009ec <strchr+0x1a>
		if (*s == c)
  8009e3:	38 ca                	cmp    %cl,%dl
  8009e5:	74 0a                	je     8009f1 <strchr+0x1f>
	for (; *s; s++)
  8009e7:	83 c0 01             	add    $0x1,%eax
  8009ea:	eb f0                	jmp    8009dc <strchr+0xa>
			return (char *) s;
	return 0;
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009fd:	eb 03                	jmp    800a02 <strfind+0xf>
  8009ff:	83 c0 01             	add    $0x1,%eax
  800a02:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a05:	38 ca                	cmp    %cl,%dl
  800a07:	74 04                	je     800a0d <strfind+0x1a>
  800a09:	84 d2                	test   %dl,%dl
  800a0b:	75 f2                	jne    8009ff <strfind+0xc>
			break;
	return (char *) s;
}
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	57                   	push   %edi
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a18:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a1b:	85 c9                	test   %ecx,%ecx
  800a1d:	74 13                	je     800a32 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a25:	75 05                	jne    800a2c <memset+0x1d>
  800a27:	f6 c1 03             	test   $0x3,%cl
  800a2a:	74 0d                	je     800a39 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2f:	fc                   	cld    
  800a30:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a32:	89 f8                	mov    %edi,%eax
  800a34:	5b                   	pop    %ebx
  800a35:	5e                   	pop    %esi
  800a36:	5f                   	pop    %edi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    
		c &= 0xFF;
  800a39:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a3d:	89 d3                	mov    %edx,%ebx
  800a3f:	c1 e3 08             	shl    $0x8,%ebx
  800a42:	89 d0                	mov    %edx,%eax
  800a44:	c1 e0 18             	shl    $0x18,%eax
  800a47:	89 d6                	mov    %edx,%esi
  800a49:	c1 e6 10             	shl    $0x10,%esi
  800a4c:	09 f0                	or     %esi,%eax
  800a4e:	09 c2                	or     %eax,%edx
  800a50:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a52:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a55:	89 d0                	mov    %edx,%eax
  800a57:	fc                   	cld    
  800a58:	f3 ab                	rep stos %eax,%es:(%edi)
  800a5a:	eb d6                	jmp    800a32 <memset+0x23>

00800a5c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	57                   	push   %edi
  800a60:	56                   	push   %esi
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
  800a64:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a67:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a6a:	39 c6                	cmp    %eax,%esi
  800a6c:	73 35                	jae    800aa3 <memmove+0x47>
  800a6e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a71:	39 c2                	cmp    %eax,%edx
  800a73:	76 2e                	jbe    800aa3 <memmove+0x47>
		s += n;
		d += n;
  800a75:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a78:	89 d6                	mov    %edx,%esi
  800a7a:	09 fe                	or     %edi,%esi
  800a7c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a82:	74 0c                	je     800a90 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a84:	83 ef 01             	sub    $0x1,%edi
  800a87:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a8a:	fd                   	std    
  800a8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8d:	fc                   	cld    
  800a8e:	eb 21                	jmp    800ab1 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a90:	f6 c1 03             	test   $0x3,%cl
  800a93:	75 ef                	jne    800a84 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a95:	83 ef 04             	sub    $0x4,%edi
  800a98:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a9b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a9e:	fd                   	std    
  800a9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa1:	eb ea                	jmp    800a8d <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa3:	89 f2                	mov    %esi,%edx
  800aa5:	09 c2                	or     %eax,%edx
  800aa7:	f6 c2 03             	test   $0x3,%dl
  800aaa:	74 09                	je     800ab5 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aac:	89 c7                	mov    %eax,%edi
  800aae:	fc                   	cld    
  800aaf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab1:	5e                   	pop    %esi
  800ab2:	5f                   	pop    %edi
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab5:	f6 c1 03             	test   $0x3,%cl
  800ab8:	75 f2                	jne    800aac <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aba:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800abd:	89 c7                	mov    %eax,%edi
  800abf:	fc                   	cld    
  800ac0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac2:	eb ed                	jmp    800ab1 <memmove+0x55>

00800ac4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ac7:	ff 75 10             	pushl  0x10(%ebp)
  800aca:	ff 75 0c             	pushl  0xc(%ebp)
  800acd:	ff 75 08             	pushl  0x8(%ebp)
  800ad0:	e8 87 ff ff ff       	call   800a5c <memmove>
}
  800ad5:	c9                   	leave  
  800ad6:	c3                   	ret    

00800ad7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae2:	89 c6                	mov    %eax,%esi
  800ae4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae7:	39 f0                	cmp    %esi,%eax
  800ae9:	74 1c                	je     800b07 <memcmp+0x30>
		if (*s1 != *s2)
  800aeb:	0f b6 08             	movzbl (%eax),%ecx
  800aee:	0f b6 1a             	movzbl (%edx),%ebx
  800af1:	38 d9                	cmp    %bl,%cl
  800af3:	75 08                	jne    800afd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800af5:	83 c0 01             	add    $0x1,%eax
  800af8:	83 c2 01             	add    $0x1,%edx
  800afb:	eb ea                	jmp    800ae7 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800afd:	0f b6 c1             	movzbl %cl,%eax
  800b00:	0f b6 db             	movzbl %bl,%ebx
  800b03:	29 d8                	sub    %ebx,%eax
  800b05:	eb 05                	jmp    800b0c <memcmp+0x35>
	}

	return 0;
  800b07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	8b 45 08             	mov    0x8(%ebp),%eax
  800b16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b19:	89 c2                	mov    %eax,%edx
  800b1b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b1e:	39 d0                	cmp    %edx,%eax
  800b20:	73 09                	jae    800b2b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b22:	38 08                	cmp    %cl,(%eax)
  800b24:	74 05                	je     800b2b <memfind+0x1b>
	for (; s < ends; s++)
  800b26:	83 c0 01             	add    $0x1,%eax
  800b29:	eb f3                	jmp    800b1e <memfind+0xe>
			break;
	return (void *) s;
}
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b39:	eb 03                	jmp    800b3e <strtol+0x11>
		s++;
  800b3b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b3e:	0f b6 01             	movzbl (%ecx),%eax
  800b41:	3c 20                	cmp    $0x20,%al
  800b43:	74 f6                	je     800b3b <strtol+0xe>
  800b45:	3c 09                	cmp    $0x9,%al
  800b47:	74 f2                	je     800b3b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b49:	3c 2b                	cmp    $0x2b,%al
  800b4b:	74 2e                	je     800b7b <strtol+0x4e>
	int neg = 0;
  800b4d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b52:	3c 2d                	cmp    $0x2d,%al
  800b54:	74 2f                	je     800b85 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b56:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b5c:	75 05                	jne    800b63 <strtol+0x36>
  800b5e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b61:	74 2c                	je     800b8f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b63:	85 db                	test   %ebx,%ebx
  800b65:	75 0a                	jne    800b71 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b67:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b6c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6f:	74 28                	je     800b99 <strtol+0x6c>
		base = 10;
  800b71:	b8 00 00 00 00       	mov    $0x0,%eax
  800b76:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b79:	eb 50                	jmp    800bcb <strtol+0x9e>
		s++;
  800b7b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b83:	eb d1                	jmp    800b56 <strtol+0x29>
		s++, neg = 1;
  800b85:	83 c1 01             	add    $0x1,%ecx
  800b88:	bf 01 00 00 00       	mov    $0x1,%edi
  800b8d:	eb c7                	jmp    800b56 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b8f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b93:	74 0e                	je     800ba3 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b95:	85 db                	test   %ebx,%ebx
  800b97:	75 d8                	jne    800b71 <strtol+0x44>
		s++, base = 8;
  800b99:	83 c1 01             	add    $0x1,%ecx
  800b9c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ba1:	eb ce                	jmp    800b71 <strtol+0x44>
		s += 2, base = 16;
  800ba3:	83 c1 02             	add    $0x2,%ecx
  800ba6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bab:	eb c4                	jmp    800b71 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bad:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bb0:	89 f3                	mov    %esi,%ebx
  800bb2:	80 fb 19             	cmp    $0x19,%bl
  800bb5:	77 29                	ja     800be0 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bb7:	0f be d2             	movsbl %dl,%edx
  800bba:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bbd:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bc0:	7d 30                	jge    800bf2 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bc2:	83 c1 01             	add    $0x1,%ecx
  800bc5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bc9:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bcb:	0f b6 11             	movzbl (%ecx),%edx
  800bce:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bd1:	89 f3                	mov    %esi,%ebx
  800bd3:	80 fb 09             	cmp    $0x9,%bl
  800bd6:	77 d5                	ja     800bad <strtol+0x80>
			dig = *s - '0';
  800bd8:	0f be d2             	movsbl %dl,%edx
  800bdb:	83 ea 30             	sub    $0x30,%edx
  800bde:	eb dd                	jmp    800bbd <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800be0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800be3:	89 f3                	mov    %esi,%ebx
  800be5:	80 fb 19             	cmp    $0x19,%bl
  800be8:	77 08                	ja     800bf2 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bea:	0f be d2             	movsbl %dl,%edx
  800bed:	83 ea 37             	sub    $0x37,%edx
  800bf0:	eb cb                	jmp    800bbd <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bf2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf6:	74 05                	je     800bfd <strtol+0xd0>
		*endptr = (char *) s;
  800bf8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bfb:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bfd:	89 c2                	mov    %eax,%edx
  800bff:	f7 da                	neg    %edx
  800c01:	85 ff                	test   %edi,%edi
  800c03:	0f 45 c2             	cmovne %edx,%eax
}
  800c06:	5b                   	pop    %ebx
  800c07:	5e                   	pop    %esi
  800c08:	5f                   	pop    %edi
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    
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
