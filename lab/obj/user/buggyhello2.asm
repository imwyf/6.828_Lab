
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 30 00 00 00       	call   800061 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 1e 00 00 00       	call   80005d <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	sys_cputs(hello, 1024*1024);
  800045:	68 00 00 10 00       	push   $0x100000
  80004a:	ff b3 0c 00 00 00    	pushl  0xc(%ebx)
  800050:	e8 74 00 00 00       	call   8000c9 <sys_cputs>
}
  800055:	83 c4 10             	add    $0x10,%esp
  800058:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80005b:	c9                   	leave  
  80005c:	c3                   	ret    

0080005d <__x86.get_pc_thunk.bx>:
  80005d:	8b 1c 24             	mov    (%esp),%ebx
  800060:	c3                   	ret    

00800061 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	53                   	push   %ebx
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	e8 f0 ff ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80006d:	81 c3 93 1f 00 00    	add    $0x1f93,%ebx
  800073:	8b 45 08             	mov    0x8(%ebp),%eax
  800076:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800079:	c7 c1 30 20 80 00    	mov    $0x802030,%ecx
  80007f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	7e 08                	jle    800091 <libmain+0x30>
		binaryname = argv[0];
  800089:	8b 0a                	mov    (%edx),%ecx
  80008b:	89 8b 10 00 00 00    	mov    %ecx,0x10(%ebx)

	// call user main routine
	umain(argc, argv);
  800091:	83 ec 08             	sub    $0x8,%esp
  800094:	52                   	push   %edx
  800095:	50                   	push   %eax
  800096:	e8 98 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009b:	e8 08 00 00 00       	call   8000a8 <exit>
}
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	53                   	push   %ebx
  8000ac:	83 ec 10             	sub    $0x10,%esp
  8000af:	e8 a9 ff ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8000b4:	81 c3 4c 1f 00 00    	add    $0x1f4c,%ebx
	sys_env_destroy(0);
  8000ba:	6a 00                	push   $0x0
  8000bc:	e8 45 00 00 00       	call   800106 <sys_env_destroy>
}
  8000c1:	83 c4 10             	add    $0x10,%esp
  8000c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    

008000c9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	57                   	push   %edi
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000da:	89 c3                	mov    %eax,%ebx
  8000dc:	89 c7                	mov    %eax,%edi
  8000de:	89 c6                	mov    %eax,%esi
  8000e0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f7:	89 d1                	mov    %edx,%ecx
  8000f9:	89 d3                	mov    %edx,%ebx
  8000fb:	89 d7                	mov    %edx,%edi
  8000fd:	89 d6                	mov    %edx,%esi
  8000ff:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800101:	5b                   	pop    %ebx
  800102:	5e                   	pop    %esi
  800103:	5f                   	pop    %edi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    

00800106 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	57                   	push   %edi
  80010a:	56                   	push   %esi
  80010b:	53                   	push   %ebx
  80010c:	83 ec 1c             	sub    $0x1c,%esp
  80010f:	e8 66 00 00 00       	call   80017a <__x86.get_pc_thunk.ax>
  800114:	05 ec 1e 00 00       	add    $0x1eec,%eax
  800119:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80011c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800121:	8b 55 08             	mov    0x8(%ebp),%edx
  800124:	b8 03 00 00 00       	mov    $0x3,%eax
  800129:	89 cb                	mov    %ecx,%ebx
  80012b:	89 cf                	mov    %ecx,%edi
  80012d:	89 ce                	mov    %ecx,%esi
  80012f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800131:	85 c0                	test   %eax,%eax
  800133:	7f 08                	jg     80013d <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800135:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800138:	5b                   	pop    %ebx
  800139:	5e                   	pop    %esi
  80013a:	5f                   	pop    %edi
  80013b:	5d                   	pop    %ebp
  80013c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	50                   	push   %eax
  800141:	6a 03                	push   $0x3
  800143:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800146:	8d 83 84 ee ff ff    	lea    -0x117c(%ebx),%eax
  80014c:	50                   	push   %eax
  80014d:	6a 23                	push   $0x23
  80014f:	8d 83 a1 ee ff ff    	lea    -0x115f(%ebx),%eax
  800155:	50                   	push   %eax
  800156:	e8 23 00 00 00       	call   80017e <_panic>

0080015b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	57                   	push   %edi
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
	asm volatile("int %1\n"
  800161:	ba 00 00 00 00       	mov    $0x0,%edx
  800166:	b8 02 00 00 00       	mov    $0x2,%eax
  80016b:	89 d1                	mov    %edx,%ecx
  80016d:	89 d3                	mov    %edx,%ebx
  80016f:	89 d7                	mov    %edx,%edi
  800171:	89 d6                	mov    %edx,%esi
  800173:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5f                   	pop    %edi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <__x86.get_pc_thunk.ax>:
  80017a:	8b 04 24             	mov    (%esp),%eax
  80017d:	c3                   	ret    

0080017e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	57                   	push   %edi
  800182:	56                   	push   %esi
  800183:	53                   	push   %ebx
  800184:	83 ec 0c             	sub    $0xc,%esp
  800187:	e8 d1 fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80018c:	81 c3 74 1e 00 00    	add    $0x1e74,%ebx
	va_list ap;

	va_start(ap, fmt);
  800192:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800195:	c7 c0 10 20 80 00    	mov    $0x802010,%eax
  80019b:	8b 38                	mov    (%eax),%edi
  80019d:	e8 b9 ff ff ff       	call   80015b <sys_getenvid>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	ff 75 0c             	pushl  0xc(%ebp)
  8001a8:	ff 75 08             	pushl  0x8(%ebp)
  8001ab:	57                   	push   %edi
  8001ac:	50                   	push   %eax
  8001ad:	8d 83 b0 ee ff ff    	lea    -0x1150(%ebx),%eax
  8001b3:	50                   	push   %eax
  8001b4:	e8 d1 00 00 00       	call   80028a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b9:	83 c4 18             	add    $0x18,%esp
  8001bc:	56                   	push   %esi
  8001bd:	ff 75 10             	pushl  0x10(%ebp)
  8001c0:	e8 63 00 00 00       	call   800228 <vcprintf>
	cprintf("\n");
  8001c5:	8d 83 78 ee ff ff    	lea    -0x1188(%ebx),%eax
  8001cb:	89 04 24             	mov    %eax,(%esp)
  8001ce:	e8 b7 00 00 00       	call   80028a <cprintf>
  8001d3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d6:	cc                   	int3   
  8001d7:	eb fd                	jmp    8001d6 <_panic+0x58>

008001d9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	56                   	push   %esi
  8001dd:	53                   	push   %ebx
  8001de:	e8 7a fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8001e3:	81 c3 1d 1e 00 00    	add    $0x1e1d,%ebx
  8001e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001ec:	8b 16                	mov    (%esi),%edx
  8001ee:	8d 42 01             	lea    0x1(%edx),%eax
  8001f1:	89 06                	mov    %eax,(%esi)
  8001f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f6:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ff:	74 0b                	je     80020c <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800201:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800205:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800208:	5b                   	pop    %ebx
  800209:	5e                   	pop    %esi
  80020a:	5d                   	pop    %ebp
  80020b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80020c:	83 ec 08             	sub    $0x8,%esp
  80020f:	68 ff 00 00 00       	push   $0xff
  800214:	8d 46 08             	lea    0x8(%esi),%eax
  800217:	50                   	push   %eax
  800218:	e8 ac fe ff ff       	call   8000c9 <sys_cputs>
		b->idx = 0;
  80021d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800223:	83 c4 10             	add    $0x10,%esp
  800226:	eb d9                	jmp    800201 <putch+0x28>

00800228 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	53                   	push   %ebx
  80022c:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800232:	e8 26 fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  800237:	81 c3 c9 1d 00 00    	add    $0x1dc9,%ebx
	struct printbuf b;

	b.idx = 0;
  80023d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800244:	00 00 00 
	b.cnt = 0;
  800247:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80024e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800251:	ff 75 0c             	pushl  0xc(%ebp)
  800254:	ff 75 08             	pushl  0x8(%ebp)
  800257:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025d:	50                   	push   %eax
  80025e:	8d 83 d9 e1 ff ff    	lea    -0x1e27(%ebx),%eax
  800264:	50                   	push   %eax
  800265:	e8 38 01 00 00       	call   8003a2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026a:	83 c4 08             	add    $0x8,%esp
  80026d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800273:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800279:	50                   	push   %eax
  80027a:	e8 4a fe ff ff       	call   8000c9 <sys_cputs>

	return b.cnt;
}
  80027f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800285:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800290:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800293:	50                   	push   %eax
  800294:	ff 75 08             	pushl  0x8(%ebp)
  800297:	e8 8c ff ff ff       	call   800228 <vcprintf>
	va_end(ap);

	return cnt;
}
  80029c:	c9                   	leave  
  80029d:	c3                   	ret    

0080029e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
  8002a1:	57                   	push   %edi
  8002a2:	56                   	push   %esi
  8002a3:	53                   	push   %ebx
  8002a4:	83 ec 2c             	sub    $0x2c,%esp
  8002a7:	e8 02 06 00 00       	call   8008ae <__x86.get_pc_thunk.cx>
  8002ac:	81 c1 54 1d 00 00    	add    $0x1d54,%ecx
  8002b2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002b5:	89 c7                	mov    %eax,%edi
  8002b7:	89 d6                	mov    %edx,%esi
  8002b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002c2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  8002c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002cd:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002d0:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002d3:	39 d3                	cmp    %edx,%ebx
  8002d5:	72 09                	jb     8002e0 <printnum+0x42>
  8002d7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002da:	0f 87 83 00 00 00    	ja     800363 <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e0:	83 ec 0c             	sub    $0xc,%esp
  8002e3:	ff 75 18             	pushl  0x18(%ebp)
  8002e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002ec:	53                   	push   %ebx
  8002ed:	ff 75 10             	pushl  0x10(%ebp)
  8002f0:	83 ec 08             	sub    $0x8,%esp
  8002f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002fc:	ff 75 d0             	pushl  -0x30(%ebp)
  8002ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800302:	e8 29 09 00 00       	call   800c30 <__udivdi3>
  800307:	83 c4 18             	add    $0x18,%esp
  80030a:	52                   	push   %edx
  80030b:	50                   	push   %eax
  80030c:	89 f2                	mov    %esi,%edx
  80030e:	89 f8                	mov    %edi,%eax
  800310:	e8 89 ff ff ff       	call   80029e <printnum>
  800315:	83 c4 20             	add    $0x20,%esp
  800318:	eb 13                	jmp    80032d <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80031a:	83 ec 08             	sub    $0x8,%esp
  80031d:	56                   	push   %esi
  80031e:	ff 75 18             	pushl  0x18(%ebp)
  800321:	ff d7                	call   *%edi
  800323:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800326:	83 eb 01             	sub    $0x1,%ebx
  800329:	85 db                	test   %ebx,%ebx
  80032b:	7f ed                	jg     80031a <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80032d:	83 ec 08             	sub    $0x8,%esp
  800330:	56                   	push   %esi
  800331:	83 ec 04             	sub    $0x4,%esp
  800334:	ff 75 dc             	pushl  -0x24(%ebp)
  800337:	ff 75 d8             	pushl  -0x28(%ebp)
  80033a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80033d:	ff 75 d0             	pushl  -0x30(%ebp)
  800340:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800343:	89 f3                	mov    %esi,%ebx
  800345:	e8 06 0a 00 00       	call   800d50 <__umoddi3>
  80034a:	83 c4 14             	add    $0x14,%esp
  80034d:	0f be 84 06 d4 ee ff 	movsbl -0x112c(%esi,%eax,1),%eax
  800354:	ff 
  800355:	50                   	push   %eax
  800356:	ff d7                	call   *%edi
}
  800358:	83 c4 10             	add    $0x10,%esp
  80035b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035e:	5b                   	pop    %ebx
  80035f:	5e                   	pop    %esi
  800360:	5f                   	pop    %edi
  800361:	5d                   	pop    %ebp
  800362:	c3                   	ret    
  800363:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800366:	eb be                	jmp    800326 <printnum+0x88>

00800368 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800372:	8b 10                	mov    (%eax),%edx
  800374:	3b 50 04             	cmp    0x4(%eax),%edx
  800377:	73 0a                	jae    800383 <sprintputch+0x1b>
		*b->buf++ = ch;
  800379:	8d 4a 01             	lea    0x1(%edx),%ecx
  80037c:	89 08                	mov    %ecx,(%eax)
  80037e:	8b 45 08             	mov    0x8(%ebp),%eax
  800381:	88 02                	mov    %al,(%edx)
}
  800383:	5d                   	pop    %ebp
  800384:	c3                   	ret    

00800385 <printfmt>:
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80038b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038e:	50                   	push   %eax
  80038f:	ff 75 10             	pushl  0x10(%ebp)
  800392:	ff 75 0c             	pushl  0xc(%ebp)
  800395:	ff 75 08             	pushl  0x8(%ebp)
  800398:	e8 05 00 00 00       	call   8003a2 <vprintfmt>
}
  80039d:	83 c4 10             	add    $0x10,%esp
  8003a0:	c9                   	leave  
  8003a1:	c3                   	ret    

008003a2 <vprintfmt>:
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
  8003a5:	57                   	push   %edi
  8003a6:	56                   	push   %esi
  8003a7:	53                   	push   %ebx
  8003a8:	83 ec 2c             	sub    $0x2c,%esp
  8003ab:	e8 ad fc ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8003b0:	81 c3 50 1c 00 00    	add    $0x1c50,%ebx
  8003b6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003b9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003bc:	e9 c3 03 00 00       	jmp    800784 <.L35+0x48>
		padc = ' ';
  8003c1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003c5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003cc:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003d3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003df:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8003e2:	8d 47 01             	lea    0x1(%edi),%eax
  8003e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e8:	0f b6 17             	movzbl (%edi),%edx
  8003eb:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003ee:	3c 55                	cmp    $0x55,%al
  8003f0:	0f 87 16 04 00 00    	ja     80080c <.L22>
  8003f6:	0f b6 c0             	movzbl %al,%eax
  8003f9:	89 d9                	mov    %ebx,%ecx
  8003fb:	03 8c 83 64 ef ff ff 	add    -0x109c(%ebx,%eax,4),%ecx
  800402:	ff e1                	jmp    *%ecx

00800404 <.L69>:
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800407:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80040b:	eb d5                	jmp    8003e2 <vprintfmt+0x40>

0080040d <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80040d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800410:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800414:	eb cc                	jmp    8003e2 <vprintfmt+0x40>

00800416 <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800416:	0f b6 d2             	movzbl %dl,%edx
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
  80041c:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800421:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800424:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800428:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80042b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80042e:	83 f9 09             	cmp    $0x9,%ecx
  800431:	77 55                	ja     800488 <.L23+0xf>
			for (precision = 0;; ++fmt)
  800433:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800436:	eb e9                	jmp    800421 <.L29+0xb>

00800438 <.L26>:
			precision = va_arg(ap, int);
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8b 00                	mov    (%eax),%eax
  80043d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 40 04             	lea    0x4(%eax),%eax
  800446:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80044c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800450:	79 90                	jns    8003e2 <vprintfmt+0x40>
				width = precision, precision = -1;
  800452:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800455:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800458:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80045f:	eb 81                	jmp    8003e2 <vprintfmt+0x40>

00800461 <.L27>:
  800461:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800464:	85 c0                	test   %eax,%eax
  800466:	ba 00 00 00 00       	mov    $0x0,%edx
  80046b:	0f 49 d0             	cmovns %eax,%edx
  80046e:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800474:	e9 69 ff ff ff       	jmp    8003e2 <vprintfmt+0x40>

00800479 <.L23>:
  800479:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80047c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800483:	e9 5a ff ff ff       	jmp    8003e2 <vprintfmt+0x40>
  800488:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80048b:	eb bf                	jmp    80044c <.L26+0x14>

0080048d <.L33>:
			lflag++;
  80048d:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800491:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800494:	e9 49 ff ff ff       	jmp    8003e2 <vprintfmt+0x40>

00800499 <.L30>:
			putch(va_arg(ap, int), putdat);
  800499:	8b 45 14             	mov    0x14(%ebp),%eax
  80049c:	8d 78 04             	lea    0x4(%eax),%edi
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	56                   	push   %esi
  8004a3:	ff 30                	pushl  (%eax)
  8004a5:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004a8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004ab:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004ae:	e9 ce 02 00 00       	jmp    800781 <.L35+0x45>

008004b3 <.L32>:
			err = va_arg(ap, int);
  8004b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b6:	8d 78 04             	lea    0x4(%eax),%edi
  8004b9:	8b 00                	mov    (%eax),%eax
  8004bb:	99                   	cltd   
  8004bc:	31 d0                	xor    %edx,%eax
  8004be:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c0:	83 f8 06             	cmp    $0x6,%eax
  8004c3:	7f 27                	jg     8004ec <.L32+0x39>
  8004c5:	8b 94 83 14 00 00 00 	mov    0x14(%ebx,%eax,4),%edx
  8004cc:	85 d2                	test   %edx,%edx
  8004ce:	74 1c                	je     8004ec <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004d0:	52                   	push   %edx
  8004d1:	8d 83 f5 ee ff ff    	lea    -0x110b(%ebx),%eax
  8004d7:	50                   	push   %eax
  8004d8:	56                   	push   %esi
  8004d9:	ff 75 08             	pushl  0x8(%ebp)
  8004dc:	e8 a4 fe ff ff       	call   800385 <printfmt>
  8004e1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004e4:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004e7:	e9 95 02 00 00       	jmp    800781 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004ec:	50                   	push   %eax
  8004ed:	8d 83 ec ee ff ff    	lea    -0x1114(%ebx),%eax
  8004f3:	50                   	push   %eax
  8004f4:	56                   	push   %esi
  8004f5:	ff 75 08             	pushl  0x8(%ebp)
  8004f8:	e8 88 fe ff ff       	call   800385 <printfmt>
  8004fd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800500:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800503:	e9 79 02 00 00       	jmp    800781 <.L35+0x45>

00800508 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	83 c0 04             	add    $0x4,%eax
  80050e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800516:	85 ff                	test   %edi,%edi
  800518:	8d 83 e5 ee ff ff    	lea    -0x111b(%ebx),%eax
  80051e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800521:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800525:	0f 8e b5 00 00 00    	jle    8005e0 <.L36+0xd8>
  80052b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80052f:	75 08                	jne    800539 <.L36+0x31>
  800531:	89 75 0c             	mov    %esi,0xc(%ebp)
  800534:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800537:	eb 6d                	jmp    8005a6 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	ff 75 cc             	pushl  -0x34(%ebp)
  80053f:	57                   	push   %edi
  800540:	e8 85 03 00 00       	call   8008ca <strnlen>
  800545:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800548:	29 c2                	sub    %eax,%edx
  80054a:	89 55 c8             	mov    %edx,-0x38(%ebp)
  80054d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800550:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800554:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800557:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80055a:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80055c:	eb 10                	jmp    80056e <.L36+0x66>
					putch(padc, putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	56                   	push   %esi
  800562:	ff 75 e0             	pushl  -0x20(%ebp)
  800565:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800568:	83 ef 01             	sub    $0x1,%edi
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	85 ff                	test   %edi,%edi
  800570:	7f ec                	jg     80055e <.L36+0x56>
  800572:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800575:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800578:	85 d2                	test   %edx,%edx
  80057a:	b8 00 00 00 00       	mov    $0x0,%eax
  80057f:	0f 49 c2             	cmovns %edx,%eax
  800582:	29 c2                	sub    %eax,%edx
  800584:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800587:	89 75 0c             	mov    %esi,0xc(%ebp)
  80058a:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80058d:	eb 17                	jmp    8005a6 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  80058f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800593:	75 30                	jne    8005c5 <.L36+0xbd>
					putch(ch, putdat);
  800595:	83 ec 08             	sub    $0x8,%esp
  800598:	ff 75 0c             	pushl  0xc(%ebp)
  80059b:	50                   	push   %eax
  80059c:	ff 55 08             	call   *0x8(%ebp)
  80059f:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a2:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005a6:	83 c7 01             	add    $0x1,%edi
  8005a9:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005ad:	0f be c2             	movsbl %dl,%eax
  8005b0:	85 c0                	test   %eax,%eax
  8005b2:	74 52                	je     800606 <.L36+0xfe>
  8005b4:	85 f6                	test   %esi,%esi
  8005b6:	78 d7                	js     80058f <.L36+0x87>
  8005b8:	83 ee 01             	sub    $0x1,%esi
  8005bb:	79 d2                	jns    80058f <.L36+0x87>
  8005bd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005c0:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005c3:	eb 32                	jmp    8005f7 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005c5:	0f be d2             	movsbl %dl,%edx
  8005c8:	83 ea 20             	sub    $0x20,%edx
  8005cb:	83 fa 5e             	cmp    $0x5e,%edx
  8005ce:	76 c5                	jbe    800595 <.L36+0x8d>
					putch('?', putdat);
  8005d0:	83 ec 08             	sub    $0x8,%esp
  8005d3:	ff 75 0c             	pushl  0xc(%ebp)
  8005d6:	6a 3f                	push   $0x3f
  8005d8:	ff 55 08             	call   *0x8(%ebp)
  8005db:	83 c4 10             	add    $0x10,%esp
  8005de:	eb c2                	jmp    8005a2 <.L36+0x9a>
  8005e0:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005e3:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005e6:	eb be                	jmp    8005a6 <.L36+0x9e>
				putch(' ', putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	56                   	push   %esi
  8005ec:	6a 20                	push   $0x20
  8005ee:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8005f1:	83 ef 01             	sub    $0x1,%edi
  8005f4:	83 c4 10             	add    $0x10,%esp
  8005f7:	85 ff                	test   %edi,%edi
  8005f9:	7f ed                	jg     8005e8 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  8005fb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005fe:	89 45 14             	mov    %eax,0x14(%ebp)
  800601:	e9 7b 01 00 00       	jmp    800781 <.L35+0x45>
  800606:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800609:	8b 75 0c             	mov    0xc(%ebp),%esi
  80060c:	eb e9                	jmp    8005f7 <.L36+0xef>

0080060e <.L31>:
  80060e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800611:	83 f9 01             	cmp    $0x1,%ecx
  800614:	7e 40                	jle    800656 <.L31+0x48>
		return va_arg(*ap, long long);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8b 50 04             	mov    0x4(%eax),%edx
  80061c:	8b 00                	mov    (%eax),%eax
  80061e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800621:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8d 40 08             	lea    0x8(%eax),%eax
  80062a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
  80062d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800631:	79 55                	jns    800688 <.L31+0x7a>
				putch('-', putdat);
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	56                   	push   %esi
  800637:	6a 2d                	push   $0x2d
  800639:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  80063c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80063f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800642:	f7 da                	neg    %edx
  800644:	83 d1 00             	adc    $0x0,%ecx
  800647:	f7 d9                	neg    %ecx
  800649:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
  80064c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800651:	e9 10 01 00 00       	jmp    800766 <.L35+0x2a>
	else if (lflag)
  800656:	85 c9                	test   %ecx,%ecx
  800658:	75 17                	jne    800671 <.L31+0x63>
		return va_arg(*ap, int);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8b 00                	mov    (%eax),%eax
  80065f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800662:	99                   	cltd   
  800663:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8d 40 04             	lea    0x4(%eax),%eax
  80066c:	89 45 14             	mov    %eax,0x14(%ebp)
  80066f:	eb bc                	jmp    80062d <.L31+0x1f>
		return va_arg(*ap, long);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8b 00                	mov    (%eax),%eax
  800676:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800679:	99                   	cltd   
  80067a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8d 40 04             	lea    0x4(%eax),%eax
  800683:	89 45 14             	mov    %eax,0x14(%ebp)
  800686:	eb a5                	jmp    80062d <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  800688:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80068b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
  80068e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800693:	e9 ce 00 00 00       	jmp    800766 <.L35+0x2a>

00800698 <.L37>:
  800698:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80069b:	83 f9 01             	cmp    $0x1,%ecx
  80069e:	7e 18                	jle    8006b8 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8b 10                	mov    (%eax),%edx
  8006a5:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a8:	8d 40 08             	lea    0x8(%eax),%eax
  8006ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b3:	e9 ae 00 00 00       	jmp    800766 <.L35+0x2a>
	else if (lflag)
  8006b8:	85 c9                	test   %ecx,%ecx
  8006ba:	75 1a                	jne    8006d6 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8006bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bf:	8b 10                	mov    (%eax),%edx
  8006c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c6:	8d 40 04             	lea    0x4(%eax),%eax
  8006c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006cc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d1:	e9 90 00 00 00       	jmp    800766 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8b 10                	mov    (%eax),%edx
  8006db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e0:	8d 40 04             	lea    0x4(%eax),%eax
  8006e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006eb:	eb 79                	jmp    800766 <.L35+0x2a>

008006ed <.L34>:
  8006ed:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006f0:	83 f9 01             	cmp    $0x1,%ecx
  8006f3:	7e 15                	jle    80070a <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  8006f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f8:	8b 10                	mov    (%eax),%edx
  8006fa:	8b 48 04             	mov    0x4(%eax),%ecx
  8006fd:	8d 40 08             	lea    0x8(%eax),%eax
  800700:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800703:	b8 08 00 00 00       	mov    $0x8,%eax
  800708:	eb 5c                	jmp    800766 <.L35+0x2a>
	else if (lflag)
  80070a:	85 c9                	test   %ecx,%ecx
  80070c:	75 17                	jne    800725 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  80070e:	8b 45 14             	mov    0x14(%ebp),%eax
  800711:	8b 10                	mov    (%eax),%edx
  800713:	b9 00 00 00 00       	mov    $0x0,%ecx
  800718:	8d 40 04             	lea    0x4(%eax),%eax
  80071b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80071e:	b8 08 00 00 00       	mov    $0x8,%eax
  800723:	eb 41                	jmp    800766 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800725:	8b 45 14             	mov    0x14(%ebp),%eax
  800728:	8b 10                	mov    (%eax),%edx
  80072a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072f:	8d 40 04             	lea    0x4(%eax),%eax
  800732:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800735:	b8 08 00 00 00       	mov    $0x8,%eax
  80073a:	eb 2a                	jmp    800766 <.L35+0x2a>

0080073c <.L35>:
			putch('0', putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	56                   	push   %esi
  800740:	6a 30                	push   $0x30
  800742:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800745:	83 c4 08             	add    $0x8,%esp
  800748:	56                   	push   %esi
  800749:	6a 78                	push   $0x78
  80074b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80074e:	8b 45 14             	mov    0x14(%ebp),%eax
  800751:	8b 10                	mov    (%eax),%edx
  800753:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800758:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80075b:	8d 40 04             	lea    0x4(%eax),%eax
  80075e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800761:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  800766:	83 ec 0c             	sub    $0xc,%esp
  800769:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80076d:	57                   	push   %edi
  80076e:	ff 75 e0             	pushl  -0x20(%ebp)
  800771:	50                   	push   %eax
  800772:	51                   	push   %ecx
  800773:	52                   	push   %edx
  800774:	89 f2                	mov    %esi,%edx
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	e8 20 fb ff ff       	call   80029e <printnum>
			break;
  80077e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800781:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  800784:	83 c7 01             	add    $0x1,%edi
  800787:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80078b:	83 f8 25             	cmp    $0x25,%eax
  80078e:	0f 84 2d fc ff ff    	je     8003c1 <vprintfmt+0x1f>
			if (ch == '\0')
  800794:	85 c0                	test   %eax,%eax
  800796:	0f 84 91 00 00 00    	je     80082d <.L22+0x21>
			putch(ch, putdat);
  80079c:	83 ec 08             	sub    $0x8,%esp
  80079f:	56                   	push   %esi
  8007a0:	50                   	push   %eax
  8007a1:	ff 55 08             	call   *0x8(%ebp)
  8007a4:	83 c4 10             	add    $0x10,%esp
  8007a7:	eb db                	jmp    800784 <.L35+0x48>

008007a9 <.L38>:
  8007a9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8007ac:	83 f9 01             	cmp    $0x1,%ecx
  8007af:	7e 15                	jle    8007c6 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8007b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b4:	8b 10                	mov    (%eax),%edx
  8007b6:	8b 48 04             	mov    0x4(%eax),%ecx
  8007b9:	8d 40 08             	lea    0x8(%eax),%eax
  8007bc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007bf:	b8 10 00 00 00       	mov    $0x10,%eax
  8007c4:	eb a0                	jmp    800766 <.L35+0x2a>
	else if (lflag)
  8007c6:	85 c9                	test   %ecx,%ecx
  8007c8:	75 17                	jne    8007e1 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cd:	8b 10                	mov    (%eax),%edx
  8007cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d4:	8d 40 04             	lea    0x4(%eax),%eax
  8007d7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007da:	b8 10 00 00 00       	mov    $0x10,%eax
  8007df:	eb 85                	jmp    800766 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e4:	8b 10                	mov    (%eax),%edx
  8007e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007eb:	8d 40 04             	lea    0x4(%eax),%eax
  8007ee:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f1:	b8 10 00 00 00       	mov    $0x10,%eax
  8007f6:	e9 6b ff ff ff       	jmp    800766 <.L35+0x2a>

008007fb <.L25>:
			putch(ch, putdat);
  8007fb:	83 ec 08             	sub    $0x8,%esp
  8007fe:	56                   	push   %esi
  8007ff:	6a 25                	push   $0x25
  800801:	ff 55 08             	call   *0x8(%ebp)
			break;
  800804:	83 c4 10             	add    $0x10,%esp
  800807:	e9 75 ff ff ff       	jmp    800781 <.L35+0x45>

0080080c <.L22>:
			putch('%', putdat);
  80080c:	83 ec 08             	sub    $0x8,%esp
  80080f:	56                   	push   %esi
  800810:	6a 25                	push   $0x25
  800812:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800815:	83 c4 10             	add    $0x10,%esp
  800818:	89 f8                	mov    %edi,%eax
  80081a:	eb 03                	jmp    80081f <.L22+0x13>
  80081c:	83 e8 01             	sub    $0x1,%eax
  80081f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800823:	75 f7                	jne    80081c <.L22+0x10>
  800825:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800828:	e9 54 ff ff ff       	jmp    800781 <.L35+0x45>
}
  80082d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800830:	5b                   	pop    %ebx
  800831:	5e                   	pop    %esi
  800832:	5f                   	pop    %edi
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	53                   	push   %ebx
  800839:	83 ec 14             	sub    $0x14,%esp
  80083c:	e8 1c f8 ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  800841:	81 c3 bf 17 00 00    	add    $0x17bf,%ebx
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  80084d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800850:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800854:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800857:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80085e:	85 c0                	test   %eax,%eax
  800860:	74 2b                	je     80088d <vsnprintf+0x58>
  800862:	85 d2                	test   %edx,%edx
  800864:	7e 27                	jle    80088d <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  800866:	ff 75 14             	pushl  0x14(%ebp)
  800869:	ff 75 10             	pushl  0x10(%ebp)
  80086c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086f:	50                   	push   %eax
  800870:	8d 83 68 e3 ff ff    	lea    -0x1c98(%ebx),%eax
  800876:	50                   	push   %eax
  800877:	e8 26 fb ff ff       	call   8003a2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80087c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800885:	83 c4 10             	add    $0x10,%esp
}
  800888:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088b:	c9                   	leave  
  80088c:	c3                   	ret    
		return -E_INVAL;
  80088d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800892:	eb f4                	jmp    800888 <vsnprintf+0x53>

00800894 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80089a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80089d:	50                   	push   %eax
  80089e:	ff 75 10             	pushl  0x10(%ebp)
  8008a1:	ff 75 0c             	pushl  0xc(%ebp)
  8008a4:	ff 75 08             	pushl  0x8(%ebp)
  8008a7:	e8 89 ff ff ff       	call   800835 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ac:	c9                   	leave  
  8008ad:	c3                   	ret    

008008ae <__x86.get_pc_thunk.cx>:
  8008ae:	8b 0c 24             	mov    (%esp),%ecx
  8008b1:	c3                   	ret    

008008b2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bd:	eb 03                	jmp    8008c2 <strlen+0x10>
		n++;
  8008bf:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008c2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c6:	75 f7                	jne    8008bf <strlen+0xd>
	return n;
}
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d8:	eb 03                	jmp    8008dd <strnlen+0x13>
		n++;
  8008da:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008dd:	39 d0                	cmp    %edx,%eax
  8008df:	74 06                	je     8008e7 <strnlen+0x1d>
  8008e1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008e5:	75 f3                	jne    8008da <strnlen+0x10>
	return n;
}
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	53                   	push   %ebx
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f3:	89 c2                	mov    %eax,%edx
  8008f5:	83 c1 01             	add    $0x1,%ecx
  8008f8:	83 c2 01             	add    $0x1,%edx
  8008fb:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008ff:	88 5a ff             	mov    %bl,-0x1(%edx)
  800902:	84 db                	test   %bl,%bl
  800904:	75 ef                	jne    8008f5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800906:	5b                   	pop    %ebx
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	53                   	push   %ebx
  80090d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800910:	53                   	push   %ebx
  800911:	e8 9c ff ff ff       	call   8008b2 <strlen>
  800916:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800919:	ff 75 0c             	pushl  0xc(%ebp)
  80091c:	01 d8                	add    %ebx,%eax
  80091e:	50                   	push   %eax
  80091f:	e8 c5 ff ff ff       	call   8008e9 <strcpy>
	return dst;
}
  800924:	89 d8                	mov    %ebx,%eax
  800926:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800929:	c9                   	leave  
  80092a:	c3                   	ret    

0080092b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	56                   	push   %esi
  80092f:	53                   	push   %ebx
  800930:	8b 75 08             	mov    0x8(%ebp),%esi
  800933:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800936:	89 f3                	mov    %esi,%ebx
  800938:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80093b:	89 f2                	mov    %esi,%edx
  80093d:	eb 0f                	jmp    80094e <strncpy+0x23>
		*dst++ = *src;
  80093f:	83 c2 01             	add    $0x1,%edx
  800942:	0f b6 01             	movzbl (%ecx),%eax
  800945:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800948:	80 39 01             	cmpb   $0x1,(%ecx)
  80094b:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80094e:	39 da                	cmp    %ebx,%edx
  800950:	75 ed                	jne    80093f <strncpy+0x14>
	}
	return ret;
}
  800952:	89 f0                	mov    %esi,%eax
  800954:	5b                   	pop    %ebx
  800955:	5e                   	pop    %esi
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	56                   	push   %esi
  80095c:	53                   	push   %ebx
  80095d:	8b 75 08             	mov    0x8(%ebp),%esi
  800960:	8b 55 0c             	mov    0xc(%ebp),%edx
  800963:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800966:	89 f0                	mov    %esi,%eax
  800968:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80096c:	85 c9                	test   %ecx,%ecx
  80096e:	75 0b                	jne    80097b <strlcpy+0x23>
  800970:	eb 17                	jmp    800989 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800972:	83 c2 01             	add    $0x1,%edx
  800975:	83 c0 01             	add    $0x1,%eax
  800978:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80097b:	39 d8                	cmp    %ebx,%eax
  80097d:	74 07                	je     800986 <strlcpy+0x2e>
  80097f:	0f b6 0a             	movzbl (%edx),%ecx
  800982:	84 c9                	test   %cl,%cl
  800984:	75 ec                	jne    800972 <strlcpy+0x1a>
		*dst = '\0';
  800986:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800989:	29 f0                	sub    %esi,%eax
}
  80098b:	5b                   	pop    %ebx
  80098c:	5e                   	pop    %esi
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800995:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800998:	eb 06                	jmp    8009a0 <strcmp+0x11>
		p++, q++;
  80099a:	83 c1 01             	add    $0x1,%ecx
  80099d:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009a0:	0f b6 01             	movzbl (%ecx),%eax
  8009a3:	84 c0                	test   %al,%al
  8009a5:	74 04                	je     8009ab <strcmp+0x1c>
  8009a7:	3a 02                	cmp    (%edx),%al
  8009a9:	74 ef                	je     80099a <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ab:	0f b6 c0             	movzbl %al,%eax
  8009ae:	0f b6 12             	movzbl (%edx),%edx
  8009b1:	29 d0                	sub    %edx,%eax
}
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	53                   	push   %ebx
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bf:	89 c3                	mov    %eax,%ebx
  8009c1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009c4:	eb 06                	jmp    8009cc <strncmp+0x17>
		n--, p++, q++;
  8009c6:	83 c0 01             	add    $0x1,%eax
  8009c9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009cc:	39 d8                	cmp    %ebx,%eax
  8009ce:	74 16                	je     8009e6 <strncmp+0x31>
  8009d0:	0f b6 08             	movzbl (%eax),%ecx
  8009d3:	84 c9                	test   %cl,%cl
  8009d5:	74 04                	je     8009db <strncmp+0x26>
  8009d7:	3a 0a                	cmp    (%edx),%cl
  8009d9:	74 eb                	je     8009c6 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009db:	0f b6 00             	movzbl (%eax),%eax
  8009de:	0f b6 12             	movzbl (%edx),%edx
  8009e1:	29 d0                	sub    %edx,%eax
}
  8009e3:	5b                   	pop    %ebx
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    
		return 0;
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009eb:	eb f6                	jmp    8009e3 <strncmp+0x2e>

008009ed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f7:	0f b6 10             	movzbl (%eax),%edx
  8009fa:	84 d2                	test   %dl,%dl
  8009fc:	74 09                	je     800a07 <strchr+0x1a>
		if (*s == c)
  8009fe:	38 ca                	cmp    %cl,%dl
  800a00:	74 0a                	je     800a0c <strchr+0x1f>
	for (; *s; s++)
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	eb f0                	jmp    8009f7 <strchr+0xa>
			return (char *) s;
	return 0;
  800a07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a18:	eb 03                	jmp    800a1d <strfind+0xf>
  800a1a:	83 c0 01             	add    $0x1,%eax
  800a1d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a20:	38 ca                	cmp    %cl,%dl
  800a22:	74 04                	je     800a28 <strfind+0x1a>
  800a24:	84 d2                	test   %dl,%dl
  800a26:	75 f2                	jne    800a1a <strfind+0xc>
			break;
	return (char *) s;
}
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	57                   	push   %edi
  800a2e:	56                   	push   %esi
  800a2f:	53                   	push   %ebx
  800a30:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a33:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a36:	85 c9                	test   %ecx,%ecx
  800a38:	74 13                	je     800a4d <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a3a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a40:	75 05                	jne    800a47 <memset+0x1d>
  800a42:	f6 c1 03             	test   $0x3,%cl
  800a45:	74 0d                	je     800a54 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4a:	fc                   	cld    
  800a4b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a4d:	89 f8                	mov    %edi,%eax
  800a4f:	5b                   	pop    %ebx
  800a50:	5e                   	pop    %esi
  800a51:	5f                   	pop    %edi
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    
		c &= 0xFF;
  800a54:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a58:	89 d3                	mov    %edx,%ebx
  800a5a:	c1 e3 08             	shl    $0x8,%ebx
  800a5d:	89 d0                	mov    %edx,%eax
  800a5f:	c1 e0 18             	shl    $0x18,%eax
  800a62:	89 d6                	mov    %edx,%esi
  800a64:	c1 e6 10             	shl    $0x10,%esi
  800a67:	09 f0                	or     %esi,%eax
  800a69:	09 c2                	or     %eax,%edx
  800a6b:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a6d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a70:	89 d0                	mov    %edx,%eax
  800a72:	fc                   	cld    
  800a73:	f3 ab                	rep stos %eax,%es:(%edi)
  800a75:	eb d6                	jmp    800a4d <memset+0x23>

00800a77 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	57                   	push   %edi
  800a7b:	56                   	push   %esi
  800a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a82:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a85:	39 c6                	cmp    %eax,%esi
  800a87:	73 35                	jae    800abe <memmove+0x47>
  800a89:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a8c:	39 c2                	cmp    %eax,%edx
  800a8e:	76 2e                	jbe    800abe <memmove+0x47>
		s += n;
		d += n;
  800a90:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a93:	89 d6                	mov    %edx,%esi
  800a95:	09 fe                	or     %edi,%esi
  800a97:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a9d:	74 0c                	je     800aab <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a9f:	83 ef 01             	sub    $0x1,%edi
  800aa2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aa5:	fd                   	std    
  800aa6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa8:	fc                   	cld    
  800aa9:	eb 21                	jmp    800acc <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aab:	f6 c1 03             	test   $0x3,%cl
  800aae:	75 ef                	jne    800a9f <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ab0:	83 ef 04             	sub    $0x4,%edi
  800ab3:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ab6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ab9:	fd                   	std    
  800aba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abc:	eb ea                	jmp    800aa8 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abe:	89 f2                	mov    %esi,%edx
  800ac0:	09 c2                	or     %eax,%edx
  800ac2:	f6 c2 03             	test   $0x3,%dl
  800ac5:	74 09                	je     800ad0 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ac7:	89 c7                	mov    %eax,%edi
  800ac9:	fc                   	cld    
  800aca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800acc:	5e                   	pop    %esi
  800acd:	5f                   	pop    %edi
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad0:	f6 c1 03             	test   $0x3,%cl
  800ad3:	75 f2                	jne    800ac7 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ad5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ad8:	89 c7                	mov    %eax,%edi
  800ada:	fc                   	cld    
  800adb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800add:	eb ed                	jmp    800acc <memmove+0x55>

00800adf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ae2:	ff 75 10             	pushl  0x10(%ebp)
  800ae5:	ff 75 0c             	pushl  0xc(%ebp)
  800ae8:	ff 75 08             	pushl  0x8(%ebp)
  800aeb:	e8 87 ff ff ff       	call   800a77 <memmove>
}
  800af0:	c9                   	leave  
  800af1:	c3                   	ret    

00800af2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	56                   	push   %esi
  800af6:	53                   	push   %ebx
  800af7:	8b 45 08             	mov    0x8(%ebp),%eax
  800afa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800afd:	89 c6                	mov    %eax,%esi
  800aff:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b02:	39 f0                	cmp    %esi,%eax
  800b04:	74 1c                	je     800b22 <memcmp+0x30>
		if (*s1 != *s2)
  800b06:	0f b6 08             	movzbl (%eax),%ecx
  800b09:	0f b6 1a             	movzbl (%edx),%ebx
  800b0c:	38 d9                	cmp    %bl,%cl
  800b0e:	75 08                	jne    800b18 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b10:	83 c0 01             	add    $0x1,%eax
  800b13:	83 c2 01             	add    $0x1,%edx
  800b16:	eb ea                	jmp    800b02 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b18:	0f b6 c1             	movzbl %cl,%eax
  800b1b:	0f b6 db             	movzbl %bl,%ebx
  800b1e:	29 d8                	sub    %ebx,%eax
  800b20:	eb 05                	jmp    800b27 <memcmp+0x35>
	}

	return 0;
  800b22:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b27:	5b                   	pop    %ebx
  800b28:	5e                   	pop    %esi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b34:	89 c2                	mov    %eax,%edx
  800b36:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b39:	39 d0                	cmp    %edx,%eax
  800b3b:	73 09                	jae    800b46 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b3d:	38 08                	cmp    %cl,(%eax)
  800b3f:	74 05                	je     800b46 <memfind+0x1b>
	for (; s < ends; s++)
  800b41:	83 c0 01             	add    $0x1,%eax
  800b44:	eb f3                	jmp    800b39 <memfind+0xe>
			break;
	return (void *) s;
}
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b54:	eb 03                	jmp    800b59 <strtol+0x11>
		s++;
  800b56:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b59:	0f b6 01             	movzbl (%ecx),%eax
  800b5c:	3c 20                	cmp    $0x20,%al
  800b5e:	74 f6                	je     800b56 <strtol+0xe>
  800b60:	3c 09                	cmp    $0x9,%al
  800b62:	74 f2                	je     800b56 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b64:	3c 2b                	cmp    $0x2b,%al
  800b66:	74 2e                	je     800b96 <strtol+0x4e>
	int neg = 0;
  800b68:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b6d:	3c 2d                	cmp    $0x2d,%al
  800b6f:	74 2f                	je     800ba0 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b71:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b77:	75 05                	jne    800b7e <strtol+0x36>
  800b79:	80 39 30             	cmpb   $0x30,(%ecx)
  800b7c:	74 2c                	je     800baa <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b7e:	85 db                	test   %ebx,%ebx
  800b80:	75 0a                	jne    800b8c <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b82:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b87:	80 39 30             	cmpb   $0x30,(%ecx)
  800b8a:	74 28                	je     800bb4 <strtol+0x6c>
		base = 10;
  800b8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b91:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b94:	eb 50                	jmp    800be6 <strtol+0x9e>
		s++;
  800b96:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b99:	bf 00 00 00 00       	mov    $0x0,%edi
  800b9e:	eb d1                	jmp    800b71 <strtol+0x29>
		s++, neg = 1;
  800ba0:	83 c1 01             	add    $0x1,%ecx
  800ba3:	bf 01 00 00 00       	mov    $0x1,%edi
  800ba8:	eb c7                	jmp    800b71 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800baa:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bae:	74 0e                	je     800bbe <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bb0:	85 db                	test   %ebx,%ebx
  800bb2:	75 d8                	jne    800b8c <strtol+0x44>
		s++, base = 8;
  800bb4:	83 c1 01             	add    $0x1,%ecx
  800bb7:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bbc:	eb ce                	jmp    800b8c <strtol+0x44>
		s += 2, base = 16;
  800bbe:	83 c1 02             	add    $0x2,%ecx
  800bc1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bc6:	eb c4                	jmp    800b8c <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bc8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bcb:	89 f3                	mov    %esi,%ebx
  800bcd:	80 fb 19             	cmp    $0x19,%bl
  800bd0:	77 29                	ja     800bfb <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bd2:	0f be d2             	movsbl %dl,%edx
  800bd5:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bd8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bdb:	7d 30                	jge    800c0d <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bdd:	83 c1 01             	add    $0x1,%ecx
  800be0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800be4:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800be6:	0f b6 11             	movzbl (%ecx),%edx
  800be9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bec:	89 f3                	mov    %esi,%ebx
  800bee:	80 fb 09             	cmp    $0x9,%bl
  800bf1:	77 d5                	ja     800bc8 <strtol+0x80>
			dig = *s - '0';
  800bf3:	0f be d2             	movsbl %dl,%edx
  800bf6:	83 ea 30             	sub    $0x30,%edx
  800bf9:	eb dd                	jmp    800bd8 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bfb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bfe:	89 f3                	mov    %esi,%ebx
  800c00:	80 fb 19             	cmp    $0x19,%bl
  800c03:	77 08                	ja     800c0d <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c05:	0f be d2             	movsbl %dl,%edx
  800c08:	83 ea 37             	sub    $0x37,%edx
  800c0b:	eb cb                	jmp    800bd8 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c0d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c11:	74 05                	je     800c18 <strtol+0xd0>
		*endptr = (char *) s;
  800c13:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c16:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c18:	89 c2                	mov    %eax,%edx
  800c1a:	f7 da                	neg    %edx
  800c1c:	85 ff                	test   %edi,%edi
  800c1e:	0f 45 c2             	cmovne %edx,%eax
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    
  800c26:	66 90                	xchg   %ax,%ax
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
