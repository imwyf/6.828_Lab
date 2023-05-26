
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	53                   	push   %ebx
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	e8 3b 00 00 00       	call   800081 <__x86.get_pc_thunk.bx>
  800046:	81 c3 ba 1f 00 00    	add    $0x1fba,%ebx
  80004c:	8b 45 08             	mov    0x8(%ebp),%eax
  80004f:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800052:	c7 c1 2c 20 80 00    	mov    $0x80202c,%ecx
  800058:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005e:	85 c0                	test   %eax,%eax
  800060:	7e 08                	jle    80006a <libmain+0x30>
		binaryname = argv[0];
  800062:	8b 0a                	mov    (%edx),%ecx
  800064:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80006a:	83 ec 08             	sub    $0x8,%esp
  80006d:	52                   	push   %edx
  80006e:	50                   	push   %eax
  80006f:	e8 bf ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800074:	e8 0c 00 00 00       	call   800085 <exit>
}
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007f:	c9                   	leave  
  800080:	c3                   	ret    

00800081 <__x86.get_pc_thunk.bx>:
  800081:	8b 1c 24             	mov    (%esp),%ebx
  800084:	c3                   	ret    

00800085 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800085:	55                   	push   %ebp
  800086:	89 e5                	mov    %esp,%ebp
  800088:	53                   	push   %ebx
  800089:	83 ec 10             	sub    $0x10,%esp
  80008c:	e8 f0 ff ff ff       	call   800081 <__x86.get_pc_thunk.bx>
  800091:	81 c3 6f 1f 00 00    	add    $0x1f6f,%ebx
	sys_env_destroy(0);
  800097:	6a 00                	push   $0x0
  800099:	e8 45 00 00 00       	call   8000e3 <sys_env_destroy>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b7:	89 c3                	mov    %eax,%ebx
  8000b9:	89 c7                	mov    %eax,%edi
  8000bb:	89 c6                	mov    %eax,%esi
  8000bd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bf:	5b                   	pop    %ebx
  8000c0:	5e                   	pop    %esi
  8000c1:	5f                   	pop    %edi
  8000c2:	5d                   	pop    %ebp
  8000c3:	c3                   	ret    

008000c4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d4:	89 d1                	mov    %edx,%ecx
  8000d6:	89 d3                	mov    %edx,%ebx
  8000d8:	89 d7                	mov    %edx,%edi
  8000da:	89 d6                	mov    %edx,%esi
  8000dc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 1c             	sub    $0x1c,%esp
  8000ec:	e8 66 00 00 00       	call   800157 <__x86.get_pc_thunk.ax>
  8000f1:	05 0f 1f 00 00       	add    $0x1f0f,%eax
  8000f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8000f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800101:	b8 03 00 00 00       	mov    $0x3,%eax
  800106:	89 cb                	mov    %ecx,%ebx
  800108:	89 cf                	mov    %ecx,%edi
  80010a:	89 ce                	mov    %ecx,%esi
  80010c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010e:	85 c0                	test   %eax,%eax
  800110:	7f 08                	jg     80011a <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800112:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5f                   	pop    %edi
  800118:	5d                   	pop    %ebp
  800119:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80011a:	83 ec 0c             	sub    $0xc,%esp
  80011d:	50                   	push   %eax
  80011e:	6a 03                	push   $0x3
  800120:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800123:	8d 83 56 ee ff ff    	lea    -0x11aa(%ebx),%eax
  800129:	50                   	push   %eax
  80012a:	6a 23                	push   $0x23
  80012c:	8d 83 73 ee ff ff    	lea    -0x118d(%ebx),%eax
  800132:	50                   	push   %eax
  800133:	e8 23 00 00 00       	call   80015b <_panic>

00800138 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	57                   	push   %edi
  80013c:	56                   	push   %esi
  80013d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013e:	ba 00 00 00 00       	mov    $0x0,%edx
  800143:	b8 02 00 00 00       	mov    $0x2,%eax
  800148:	89 d1                	mov    %edx,%ecx
  80014a:	89 d3                	mov    %edx,%ebx
  80014c:	89 d7                	mov    %edx,%edi
  80014e:	89 d6                	mov    %edx,%esi
  800150:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800152:	5b                   	pop    %ebx
  800153:	5e                   	pop    %esi
  800154:	5f                   	pop    %edi
  800155:	5d                   	pop    %ebp
  800156:	c3                   	ret    

00800157 <__x86.get_pc_thunk.ax>:
  800157:	8b 04 24             	mov    (%esp),%eax
  80015a:	c3                   	ret    

0080015b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	57                   	push   %edi
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 0c             	sub    $0xc,%esp
  800164:	e8 18 ff ff ff       	call   800081 <__x86.get_pc_thunk.bx>
  800169:	81 c3 97 1e 00 00    	add    $0x1e97,%ebx
	va_list ap;

	va_start(ap, fmt);
  80016f:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800172:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800178:	8b 38                	mov    (%eax),%edi
  80017a:	e8 b9 ff ff ff       	call   800138 <sys_getenvid>
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	ff 75 0c             	pushl  0xc(%ebp)
  800185:	ff 75 08             	pushl  0x8(%ebp)
  800188:	57                   	push   %edi
  800189:	50                   	push   %eax
  80018a:	8d 83 84 ee ff ff    	lea    -0x117c(%ebx),%eax
  800190:	50                   	push   %eax
  800191:	e8 d1 00 00 00       	call   800267 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800196:	83 c4 18             	add    $0x18,%esp
  800199:	56                   	push   %esi
  80019a:	ff 75 10             	pushl  0x10(%ebp)
  80019d:	e8 63 00 00 00       	call   800205 <vcprintf>
	cprintf("\n");
  8001a2:	8d 83 a8 ee ff ff    	lea    -0x1158(%ebx),%eax
  8001a8:	89 04 24             	mov    %eax,(%esp)
  8001ab:	e8 b7 00 00 00       	call   800267 <cprintf>
  8001b0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b3:	cc                   	int3   
  8001b4:	eb fd                	jmp    8001b3 <_panic+0x58>

008001b6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	56                   	push   %esi
  8001ba:	53                   	push   %ebx
  8001bb:	e8 c1 fe ff ff       	call   800081 <__x86.get_pc_thunk.bx>
  8001c0:	81 c3 40 1e 00 00    	add    $0x1e40,%ebx
  8001c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001c9:	8b 16                	mov    (%esi),%edx
  8001cb:	8d 42 01             	lea    0x1(%edx),%eax
  8001ce:	89 06                	mov    %eax,(%esi)
  8001d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d3:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001d7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001dc:	74 0b                	je     8001e9 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001de:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e5:	5b                   	pop    %ebx
  8001e6:	5e                   	pop    %esi
  8001e7:	5d                   	pop    %ebp
  8001e8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001e9:	83 ec 08             	sub    $0x8,%esp
  8001ec:	68 ff 00 00 00       	push   $0xff
  8001f1:	8d 46 08             	lea    0x8(%esi),%eax
  8001f4:	50                   	push   %eax
  8001f5:	e8 ac fe ff ff       	call   8000a6 <sys_cputs>
		b->idx = 0;
  8001fa:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	eb d9                	jmp    8001de <putch+0x28>

00800205 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	53                   	push   %ebx
  800209:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80020f:	e8 6d fe ff ff       	call   800081 <__x86.get_pc_thunk.bx>
  800214:	81 c3 ec 1d 00 00    	add    $0x1dec,%ebx
	struct printbuf b;

	b.idx = 0;
  80021a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800221:	00 00 00 
	b.cnt = 0;
  800224:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023a:	50                   	push   %eax
  80023b:	8d 83 b6 e1 ff ff    	lea    -0x1e4a(%ebx),%eax
  800241:	50                   	push   %eax
  800242:	e8 38 01 00 00       	call   80037f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800247:	83 c4 08             	add    $0x8,%esp
  80024a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800250:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800256:	50                   	push   %eax
  800257:	e8 4a fe ff ff       	call   8000a6 <sys_cputs>

	return b.cnt;
}
  80025c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800262:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800265:	c9                   	leave  
  800266:	c3                   	ret    

00800267 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800270:	50                   	push   %eax
  800271:	ff 75 08             	pushl  0x8(%ebp)
  800274:	e8 8c ff ff ff       	call   800205 <vcprintf>
	va_end(ap);

	return cnt;
}
  800279:	c9                   	leave  
  80027a:	c3                   	ret    

0080027b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	57                   	push   %edi
  80027f:	56                   	push   %esi
  800280:	53                   	push   %ebx
  800281:	83 ec 2c             	sub    $0x2c,%esp
  800284:	e8 02 06 00 00       	call   80088b <__x86.get_pc_thunk.cx>
  800289:	81 c1 77 1d 00 00    	add    $0x1d77,%ecx
  80028f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800292:	89 c7                	mov    %eax,%edi
  800294:	89 d6                	mov    %edx,%esi
  800296:	8b 45 08             	mov    0x8(%ebp),%eax
  800299:	8b 55 0c             	mov    0xc(%ebp),%edx
  80029c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80029f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  8002a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002aa:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002ad:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002b0:	39 d3                	cmp    %edx,%ebx
  8002b2:	72 09                	jb     8002bd <printnum+0x42>
  8002b4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002b7:	0f 87 83 00 00 00    	ja     800340 <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	ff 75 18             	pushl  0x18(%ebp)
  8002c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8002c6:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002c9:	53                   	push   %ebx
  8002ca:	ff 75 10             	pushl  0x10(%ebp)
  8002cd:	83 ec 08             	sub    $0x8,%esp
  8002d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002d9:	ff 75 d0             	pushl  -0x30(%ebp)
  8002dc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002df:	e8 2c 09 00 00       	call   800c10 <__udivdi3>
  8002e4:	83 c4 18             	add    $0x18,%esp
  8002e7:	52                   	push   %edx
  8002e8:	50                   	push   %eax
  8002e9:	89 f2                	mov    %esi,%edx
  8002eb:	89 f8                	mov    %edi,%eax
  8002ed:	e8 89 ff ff ff       	call   80027b <printnum>
  8002f2:	83 c4 20             	add    $0x20,%esp
  8002f5:	eb 13                	jmp    80030a <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f7:	83 ec 08             	sub    $0x8,%esp
  8002fa:	56                   	push   %esi
  8002fb:	ff 75 18             	pushl  0x18(%ebp)
  8002fe:	ff d7                	call   *%edi
  800300:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800303:	83 eb 01             	sub    $0x1,%ebx
  800306:	85 db                	test   %ebx,%ebx
  800308:	7f ed                	jg     8002f7 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030a:	83 ec 08             	sub    $0x8,%esp
  80030d:	56                   	push   %esi
  80030e:	83 ec 04             	sub    $0x4,%esp
  800311:	ff 75 dc             	pushl  -0x24(%ebp)
  800314:	ff 75 d8             	pushl  -0x28(%ebp)
  800317:	ff 75 d4             	pushl  -0x2c(%ebp)
  80031a:	ff 75 d0             	pushl  -0x30(%ebp)
  80031d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800320:	89 f3                	mov    %esi,%ebx
  800322:	e8 09 0a 00 00       	call   800d30 <__umoddi3>
  800327:	83 c4 14             	add    $0x14,%esp
  80032a:	0f be 84 06 aa ee ff 	movsbl -0x1156(%esi,%eax,1),%eax
  800331:	ff 
  800332:	50                   	push   %eax
  800333:	ff d7                	call   *%edi
}
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033b:	5b                   	pop    %ebx
  80033c:	5e                   	pop    %esi
  80033d:	5f                   	pop    %edi
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    
  800340:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800343:	eb be                	jmp    800303 <printnum+0x88>

00800345 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80034b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80034f:	8b 10                	mov    (%eax),%edx
  800351:	3b 50 04             	cmp    0x4(%eax),%edx
  800354:	73 0a                	jae    800360 <sprintputch+0x1b>
		*b->buf++ = ch;
  800356:	8d 4a 01             	lea    0x1(%edx),%ecx
  800359:	89 08                	mov    %ecx,(%eax)
  80035b:	8b 45 08             	mov    0x8(%ebp),%eax
  80035e:	88 02                	mov    %al,(%edx)
}
  800360:	5d                   	pop    %ebp
  800361:	c3                   	ret    

00800362 <printfmt>:
{
  800362:	55                   	push   %ebp
  800363:	89 e5                	mov    %esp,%ebp
  800365:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800368:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80036b:	50                   	push   %eax
  80036c:	ff 75 10             	pushl  0x10(%ebp)
  80036f:	ff 75 0c             	pushl  0xc(%ebp)
  800372:	ff 75 08             	pushl  0x8(%ebp)
  800375:	e8 05 00 00 00       	call   80037f <vprintfmt>
}
  80037a:	83 c4 10             	add    $0x10,%esp
  80037d:	c9                   	leave  
  80037e:	c3                   	ret    

0080037f <vprintfmt>:
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
  800382:	57                   	push   %edi
  800383:	56                   	push   %esi
  800384:	53                   	push   %ebx
  800385:	83 ec 2c             	sub    $0x2c,%esp
  800388:	e8 f4 fc ff ff       	call   800081 <__x86.get_pc_thunk.bx>
  80038d:	81 c3 73 1c 00 00    	add    $0x1c73,%ebx
  800393:	8b 75 0c             	mov    0xc(%ebp),%esi
  800396:	8b 7d 10             	mov    0x10(%ebp),%edi
  800399:	e9 c3 03 00 00       	jmp    800761 <.L35+0x48>
		padc = ' ';
  80039e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003a2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003a9:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003b0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003bc:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8003bf:	8d 47 01             	lea    0x1(%edi),%eax
  8003c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c5:	0f b6 17             	movzbl (%edi),%edx
  8003c8:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003cb:	3c 55                	cmp    $0x55,%al
  8003cd:	0f 87 16 04 00 00    	ja     8007e9 <.L22>
  8003d3:	0f b6 c0             	movzbl %al,%eax
  8003d6:	89 d9                	mov    %ebx,%ecx
  8003d8:	03 8c 83 38 ef ff ff 	add    -0x10c8(%ebx,%eax,4),%ecx
  8003df:	ff e1                	jmp    *%ecx

008003e1 <.L69>:
  8003e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003e4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003e8:	eb d5                	jmp    8003bf <vprintfmt+0x40>

008003ea <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8003ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8003ed:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f1:	eb cc                	jmp    8003bf <vprintfmt+0x40>

008003f3 <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8003f3:	0f b6 d2             	movzbl %dl,%edx
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
  8003f9:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  8003fe:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800401:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800405:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800408:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80040b:	83 f9 09             	cmp    $0x9,%ecx
  80040e:	77 55                	ja     800465 <.L23+0xf>
			for (precision = 0;; ++fmt)
  800410:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800413:	eb e9                	jmp    8003fe <.L29+0xb>

00800415 <.L26>:
			precision = va_arg(ap, int);
  800415:	8b 45 14             	mov    0x14(%ebp),%eax
  800418:	8b 00                	mov    (%eax),%eax
  80041a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80041d:	8b 45 14             	mov    0x14(%ebp),%eax
  800420:	8d 40 04             	lea    0x4(%eax),%eax
  800423:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800429:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042d:	79 90                	jns    8003bf <vprintfmt+0x40>
				width = precision, precision = -1;
  80042f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800432:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800435:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80043c:	eb 81                	jmp    8003bf <vprintfmt+0x40>

0080043e <.L27>:
  80043e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800441:	85 c0                	test   %eax,%eax
  800443:	ba 00 00 00 00       	mov    $0x0,%edx
  800448:	0f 49 d0             	cmovns %eax,%edx
  80044b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80044e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800451:	e9 69 ff ff ff       	jmp    8003bf <vprintfmt+0x40>

00800456 <.L23>:
  800456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800459:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800460:	e9 5a ff ff ff       	jmp    8003bf <vprintfmt+0x40>
  800465:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800468:	eb bf                	jmp    800429 <.L26+0x14>

0080046a <.L33>:
			lflag++;
  80046a:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80046e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800471:	e9 49 ff ff ff       	jmp    8003bf <vprintfmt+0x40>

00800476 <.L30>:
			putch(va_arg(ap, int), putdat);
  800476:	8b 45 14             	mov    0x14(%ebp),%eax
  800479:	8d 78 04             	lea    0x4(%eax),%edi
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	56                   	push   %esi
  800480:	ff 30                	pushl  (%eax)
  800482:	ff 55 08             	call   *0x8(%ebp)
			break;
  800485:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800488:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80048b:	e9 ce 02 00 00       	jmp    80075e <.L35+0x45>

00800490 <.L32>:
			err = va_arg(ap, int);
  800490:	8b 45 14             	mov    0x14(%ebp),%eax
  800493:	8d 78 04             	lea    0x4(%eax),%edi
  800496:	8b 00                	mov    (%eax),%eax
  800498:	99                   	cltd   
  800499:	31 d0                	xor    %edx,%eax
  80049b:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049d:	83 f8 06             	cmp    $0x6,%eax
  8004a0:	7f 27                	jg     8004c9 <.L32+0x39>
  8004a2:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  8004a9:	85 d2                	test   %edx,%edx
  8004ab:	74 1c                	je     8004c9 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  8004ad:	52                   	push   %edx
  8004ae:	8d 83 cb ee ff ff    	lea    -0x1135(%ebx),%eax
  8004b4:	50                   	push   %eax
  8004b5:	56                   	push   %esi
  8004b6:	ff 75 08             	pushl  0x8(%ebp)
  8004b9:	e8 a4 fe ff ff       	call   800362 <printfmt>
  8004be:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004c1:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004c4:	e9 95 02 00 00       	jmp    80075e <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004c9:	50                   	push   %eax
  8004ca:	8d 83 c2 ee ff ff    	lea    -0x113e(%ebx),%eax
  8004d0:	50                   	push   %eax
  8004d1:	56                   	push   %esi
  8004d2:	ff 75 08             	pushl  0x8(%ebp)
  8004d5:	e8 88 fe ff ff       	call   800362 <printfmt>
  8004da:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004dd:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004e0:	e9 79 02 00 00       	jmp    80075e <.L35+0x45>

008004e5 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  8004e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e8:	83 c0 04             	add    $0x4,%eax
  8004eb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004f3:	85 ff                	test   %edi,%edi
  8004f5:	8d 83 bb ee ff ff    	lea    -0x1145(%ebx),%eax
  8004fb:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004fe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800502:	0f 8e b5 00 00 00    	jle    8005bd <.L36+0xd8>
  800508:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80050c:	75 08                	jne    800516 <.L36+0x31>
  80050e:	89 75 0c             	mov    %esi,0xc(%ebp)
  800511:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800514:	eb 6d                	jmp    800583 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	ff 75 cc             	pushl  -0x34(%ebp)
  80051c:	57                   	push   %edi
  80051d:	e8 85 03 00 00       	call   8008a7 <strnlen>
  800522:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800525:	29 c2                	sub    %eax,%edx
  800527:	89 55 c8             	mov    %edx,-0x38(%ebp)
  80052a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80052d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800531:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800534:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800537:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800539:	eb 10                	jmp    80054b <.L36+0x66>
					putch(padc, putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	56                   	push   %esi
  80053f:	ff 75 e0             	pushl  -0x20(%ebp)
  800542:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800545:	83 ef 01             	sub    $0x1,%edi
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	85 ff                	test   %edi,%edi
  80054d:	7f ec                	jg     80053b <.L36+0x56>
  80054f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800552:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800555:	85 d2                	test   %edx,%edx
  800557:	b8 00 00 00 00       	mov    $0x0,%eax
  80055c:	0f 49 c2             	cmovns %edx,%eax
  80055f:	29 c2                	sub    %eax,%edx
  800561:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800564:	89 75 0c             	mov    %esi,0xc(%ebp)
  800567:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80056a:	eb 17                	jmp    800583 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  80056c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800570:	75 30                	jne    8005a2 <.L36+0xbd>
					putch(ch, putdat);
  800572:	83 ec 08             	sub    $0x8,%esp
  800575:	ff 75 0c             	pushl  0xc(%ebp)
  800578:	50                   	push   %eax
  800579:	ff 55 08             	call   *0x8(%ebp)
  80057c:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057f:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800583:	83 c7 01             	add    $0x1,%edi
  800586:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80058a:	0f be c2             	movsbl %dl,%eax
  80058d:	85 c0                	test   %eax,%eax
  80058f:	74 52                	je     8005e3 <.L36+0xfe>
  800591:	85 f6                	test   %esi,%esi
  800593:	78 d7                	js     80056c <.L36+0x87>
  800595:	83 ee 01             	sub    $0x1,%esi
  800598:	79 d2                	jns    80056c <.L36+0x87>
  80059a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80059d:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005a0:	eb 32                	jmp    8005d4 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8005a2:	0f be d2             	movsbl %dl,%edx
  8005a5:	83 ea 20             	sub    $0x20,%edx
  8005a8:	83 fa 5e             	cmp    $0x5e,%edx
  8005ab:	76 c5                	jbe    800572 <.L36+0x8d>
					putch('?', putdat);
  8005ad:	83 ec 08             	sub    $0x8,%esp
  8005b0:	ff 75 0c             	pushl  0xc(%ebp)
  8005b3:	6a 3f                	push   $0x3f
  8005b5:	ff 55 08             	call   *0x8(%ebp)
  8005b8:	83 c4 10             	add    $0x10,%esp
  8005bb:	eb c2                	jmp    80057f <.L36+0x9a>
  8005bd:	89 75 0c             	mov    %esi,0xc(%ebp)
  8005c0:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005c3:	eb be                	jmp    800583 <.L36+0x9e>
				putch(' ', putdat);
  8005c5:	83 ec 08             	sub    $0x8,%esp
  8005c8:	56                   	push   %esi
  8005c9:	6a 20                	push   $0x20
  8005cb:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  8005ce:	83 ef 01             	sub    $0x1,%edi
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	85 ff                	test   %edi,%edi
  8005d6:	7f ed                	jg     8005c5 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  8005d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005db:	89 45 14             	mov    %eax,0x14(%ebp)
  8005de:	e9 7b 01 00 00       	jmp    80075e <.L35+0x45>
  8005e3:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005e6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005e9:	eb e9                	jmp    8005d4 <.L36+0xef>

008005eb <.L31>:
  8005eb:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8005ee:	83 f9 01             	cmp    $0x1,%ecx
  8005f1:	7e 40                	jle    800633 <.L31+0x48>
		return va_arg(*ap, long long);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8b 50 04             	mov    0x4(%eax),%edx
  8005f9:	8b 00                	mov    (%eax),%eax
  8005fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8d 40 08             	lea    0x8(%eax),%eax
  800607:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
  80060a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80060e:	79 55                	jns    800665 <.L31+0x7a>
				putch('-', putdat);
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	56                   	push   %esi
  800614:	6a 2d                	push   $0x2d
  800616:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  800619:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80061c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80061f:	f7 da                	neg    %edx
  800621:	83 d1 00             	adc    $0x0,%ecx
  800624:	f7 d9                	neg    %ecx
  800626:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
  800629:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062e:	e9 10 01 00 00       	jmp    800743 <.L35+0x2a>
	else if (lflag)
  800633:	85 c9                	test   %ecx,%ecx
  800635:	75 17                	jne    80064e <.L31+0x63>
		return va_arg(*ap, int);
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8b 00                	mov    (%eax),%eax
  80063c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063f:	99                   	cltd   
  800640:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8d 40 04             	lea    0x4(%eax),%eax
  800649:	89 45 14             	mov    %eax,0x14(%ebp)
  80064c:	eb bc                	jmp    80060a <.L31+0x1f>
		return va_arg(*ap, long);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8b 00                	mov    (%eax),%eax
  800653:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800656:	99                   	cltd   
  800657:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8d 40 04             	lea    0x4(%eax),%eax
  800660:	89 45 14             	mov    %eax,0x14(%ebp)
  800663:	eb a5                	jmp    80060a <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  800665:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800668:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
  80066b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800670:	e9 ce 00 00 00       	jmp    800743 <.L35+0x2a>

00800675 <.L37>:
  800675:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800678:	83 f9 01             	cmp    $0x1,%ecx
  80067b:	7e 18                	jle    800695 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8b 10                	mov    (%eax),%edx
  800682:	8b 48 04             	mov    0x4(%eax),%ecx
  800685:	8d 40 08             	lea    0x8(%eax),%eax
  800688:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80068b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800690:	e9 ae 00 00 00       	jmp    800743 <.L35+0x2a>
	else if (lflag)
  800695:	85 c9                	test   %ecx,%ecx
  800697:	75 1a                	jne    8006b3 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8b 10                	mov    (%eax),%edx
  80069e:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a3:	8d 40 04             	lea    0x4(%eax),%eax
  8006a6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006a9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ae:	e9 90 00 00 00       	jmp    800743 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 10                	mov    (%eax),%edx
  8006b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bd:	8d 40 04             	lea    0x4(%eax),%eax
  8006c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c8:	eb 79                	jmp    800743 <.L35+0x2a>

008006ca <.L34>:
  8006ca:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8006cd:	83 f9 01             	cmp    $0x1,%ecx
  8006d0:	7e 15                	jle    8006e7 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8b 10                	mov    (%eax),%edx
  8006d7:	8b 48 04             	mov    0x4(%eax),%ecx
  8006da:	8d 40 08             	lea    0x8(%eax),%eax
  8006dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006e0:	b8 08 00 00 00       	mov    $0x8,%eax
  8006e5:	eb 5c                	jmp    800743 <.L35+0x2a>
	else if (lflag)
  8006e7:	85 c9                	test   %ecx,%ecx
  8006e9:	75 17                	jne    800702 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  8006eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ee:	8b 10                	mov    (%eax),%edx
  8006f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f5:	8d 40 04             	lea    0x4(%eax),%eax
  8006f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006fb:	b8 08 00 00 00       	mov    $0x8,%eax
  800700:	eb 41                	jmp    800743 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	8b 10                	mov    (%eax),%edx
  800707:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070c:	8d 40 04             	lea    0x4(%eax),%eax
  80070f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800712:	b8 08 00 00 00       	mov    $0x8,%eax
  800717:	eb 2a                	jmp    800743 <.L35+0x2a>

00800719 <.L35>:
			putch('0', putdat);
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	56                   	push   %esi
  80071d:	6a 30                	push   $0x30
  80071f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800722:	83 c4 08             	add    $0x8,%esp
  800725:	56                   	push   %esi
  800726:	6a 78                	push   $0x78
  800728:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80072b:	8b 45 14             	mov    0x14(%ebp),%eax
  80072e:	8b 10                	mov    (%eax),%edx
  800730:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800735:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800738:	8d 40 04             	lea    0x4(%eax),%eax
  80073b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073e:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  800743:	83 ec 0c             	sub    $0xc,%esp
  800746:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80074a:	57                   	push   %edi
  80074b:	ff 75 e0             	pushl  -0x20(%ebp)
  80074e:	50                   	push   %eax
  80074f:	51                   	push   %ecx
  800750:	52                   	push   %edx
  800751:	89 f2                	mov    %esi,%edx
  800753:	8b 45 08             	mov    0x8(%ebp),%eax
  800756:	e8 20 fb ff ff       	call   80027b <printnum>
			break;
  80075b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80075e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  800761:	83 c7 01             	add    $0x1,%edi
  800764:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800768:	83 f8 25             	cmp    $0x25,%eax
  80076b:	0f 84 2d fc ff ff    	je     80039e <vprintfmt+0x1f>
			if (ch == '\0')
  800771:	85 c0                	test   %eax,%eax
  800773:	0f 84 91 00 00 00    	je     80080a <.L22+0x21>
			putch(ch, putdat);
  800779:	83 ec 08             	sub    $0x8,%esp
  80077c:	56                   	push   %esi
  80077d:	50                   	push   %eax
  80077e:	ff 55 08             	call   *0x8(%ebp)
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	eb db                	jmp    800761 <.L35+0x48>

00800786 <.L38>:
  800786:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800789:	83 f9 01             	cmp    $0x1,%ecx
  80078c:	7e 15                	jle    8007a3 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  80078e:	8b 45 14             	mov    0x14(%ebp),%eax
  800791:	8b 10                	mov    (%eax),%edx
  800793:	8b 48 04             	mov    0x4(%eax),%ecx
  800796:	8d 40 08             	lea    0x8(%eax),%eax
  800799:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80079c:	b8 10 00 00 00       	mov    $0x10,%eax
  8007a1:	eb a0                	jmp    800743 <.L35+0x2a>
	else if (lflag)
  8007a3:	85 c9                	test   %ecx,%ecx
  8007a5:	75 17                	jne    8007be <.L38+0x38>
		return va_arg(*ap, unsigned int);
  8007a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007aa:	8b 10                	mov    (%eax),%edx
  8007ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b1:	8d 40 04             	lea    0x4(%eax),%eax
  8007b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b7:	b8 10 00 00 00       	mov    $0x10,%eax
  8007bc:	eb 85                	jmp    800743 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  8007be:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c1:	8b 10                	mov    (%eax),%edx
  8007c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c8:	8d 40 04             	lea    0x4(%eax),%eax
  8007cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ce:	b8 10 00 00 00       	mov    $0x10,%eax
  8007d3:	e9 6b ff ff ff       	jmp    800743 <.L35+0x2a>

008007d8 <.L25>:
			putch(ch, putdat);
  8007d8:	83 ec 08             	sub    $0x8,%esp
  8007db:	56                   	push   %esi
  8007dc:	6a 25                	push   $0x25
  8007de:	ff 55 08             	call   *0x8(%ebp)
			break;
  8007e1:	83 c4 10             	add    $0x10,%esp
  8007e4:	e9 75 ff ff ff       	jmp    80075e <.L35+0x45>

008007e9 <.L22>:
			putch('%', putdat);
  8007e9:	83 ec 08             	sub    $0x8,%esp
  8007ec:	56                   	push   %esi
  8007ed:	6a 25                	push   $0x25
  8007ef:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f2:	83 c4 10             	add    $0x10,%esp
  8007f5:	89 f8                	mov    %edi,%eax
  8007f7:	eb 03                	jmp    8007fc <.L22+0x13>
  8007f9:	83 e8 01             	sub    $0x1,%eax
  8007fc:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800800:	75 f7                	jne    8007f9 <.L22+0x10>
  800802:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800805:	e9 54 ff ff ff       	jmp    80075e <.L35+0x45>
}
  80080a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80080d:	5b                   	pop    %ebx
  80080e:	5e                   	pop    %esi
  80080f:	5f                   	pop    %edi
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	83 ec 14             	sub    $0x14,%esp
  800819:	e8 63 f8 ff ff       	call   800081 <__x86.get_pc_thunk.bx>
  80081e:	81 c3 e2 17 00 00    	add    $0x17e2,%ebx
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  80082a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80082d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800831:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800834:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083b:	85 c0                	test   %eax,%eax
  80083d:	74 2b                	je     80086a <vsnprintf+0x58>
  80083f:	85 d2                	test   %edx,%edx
  800841:	7e 27                	jle    80086a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  800843:	ff 75 14             	pushl  0x14(%ebp)
  800846:	ff 75 10             	pushl  0x10(%ebp)
  800849:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084c:	50                   	push   %eax
  80084d:	8d 83 45 e3 ff ff    	lea    -0x1cbb(%ebx),%eax
  800853:	50                   	push   %eax
  800854:	e8 26 fb ff ff       	call   80037f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800859:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80085f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800862:	83 c4 10             	add    $0x10,%esp
}
  800865:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800868:	c9                   	leave  
  800869:	c3                   	ret    
		return -E_INVAL;
  80086a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80086f:	eb f4                	jmp    800865 <vsnprintf+0x53>

00800871 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800877:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80087a:	50                   	push   %eax
  80087b:	ff 75 10             	pushl  0x10(%ebp)
  80087e:	ff 75 0c             	pushl  0xc(%ebp)
  800881:	ff 75 08             	pushl  0x8(%ebp)
  800884:	e8 89 ff ff ff       	call   800812 <vsnprintf>
	va_end(ap);

	return rc;
}
  800889:	c9                   	leave  
  80088a:	c3                   	ret    

0080088b <__x86.get_pc_thunk.cx>:
  80088b:	8b 0c 24             	mov    (%esp),%ecx
  80088e:	c3                   	ret    

0080088f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800895:	b8 00 00 00 00       	mov    $0x0,%eax
  80089a:	eb 03                	jmp    80089f <strlen+0x10>
		n++;
  80089c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80089f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a3:	75 f7                	jne    80089c <strlen+0xd>
	return n;
}
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b5:	eb 03                	jmp    8008ba <strnlen+0x13>
		n++;
  8008b7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ba:	39 d0                	cmp    %edx,%eax
  8008bc:	74 06                	je     8008c4 <strnlen+0x1d>
  8008be:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008c2:	75 f3                	jne    8008b7 <strnlen+0x10>
	return n;
}
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	53                   	push   %ebx
  8008ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d0:	89 c2                	mov    %eax,%edx
  8008d2:	83 c1 01             	add    $0x1,%ecx
  8008d5:	83 c2 01             	add    $0x1,%edx
  8008d8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008dc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008df:	84 db                	test   %bl,%bl
  8008e1:	75 ef                	jne    8008d2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008e3:	5b                   	pop    %ebx
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	53                   	push   %ebx
  8008ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008ed:	53                   	push   %ebx
  8008ee:	e8 9c ff ff ff       	call   80088f <strlen>
  8008f3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008f6:	ff 75 0c             	pushl  0xc(%ebp)
  8008f9:	01 d8                	add    %ebx,%eax
  8008fb:	50                   	push   %eax
  8008fc:	e8 c5 ff ff ff       	call   8008c6 <strcpy>
	return dst;
}
  800901:	89 d8                	mov    %ebx,%eax
  800903:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800906:	c9                   	leave  
  800907:	c3                   	ret    

00800908 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	56                   	push   %esi
  80090c:	53                   	push   %ebx
  80090d:	8b 75 08             	mov    0x8(%ebp),%esi
  800910:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800913:	89 f3                	mov    %esi,%ebx
  800915:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800918:	89 f2                	mov    %esi,%edx
  80091a:	eb 0f                	jmp    80092b <strncpy+0x23>
		*dst++ = *src;
  80091c:	83 c2 01             	add    $0x1,%edx
  80091f:	0f b6 01             	movzbl (%ecx),%eax
  800922:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800925:	80 39 01             	cmpb   $0x1,(%ecx)
  800928:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80092b:	39 da                	cmp    %ebx,%edx
  80092d:	75 ed                	jne    80091c <strncpy+0x14>
	}
	return ret;
}
  80092f:	89 f0                	mov    %esi,%eax
  800931:	5b                   	pop    %ebx
  800932:	5e                   	pop    %esi
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	56                   	push   %esi
  800939:	53                   	push   %ebx
  80093a:	8b 75 08             	mov    0x8(%ebp),%esi
  80093d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800940:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800943:	89 f0                	mov    %esi,%eax
  800945:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800949:	85 c9                	test   %ecx,%ecx
  80094b:	75 0b                	jne    800958 <strlcpy+0x23>
  80094d:	eb 17                	jmp    800966 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80094f:	83 c2 01             	add    $0x1,%edx
  800952:	83 c0 01             	add    $0x1,%eax
  800955:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800958:	39 d8                	cmp    %ebx,%eax
  80095a:	74 07                	je     800963 <strlcpy+0x2e>
  80095c:	0f b6 0a             	movzbl (%edx),%ecx
  80095f:	84 c9                	test   %cl,%cl
  800961:	75 ec                	jne    80094f <strlcpy+0x1a>
		*dst = '\0';
  800963:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800966:	29 f0                	sub    %esi,%eax
}
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800972:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800975:	eb 06                	jmp    80097d <strcmp+0x11>
		p++, q++;
  800977:	83 c1 01             	add    $0x1,%ecx
  80097a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80097d:	0f b6 01             	movzbl (%ecx),%eax
  800980:	84 c0                	test   %al,%al
  800982:	74 04                	je     800988 <strcmp+0x1c>
  800984:	3a 02                	cmp    (%edx),%al
  800986:	74 ef                	je     800977 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800988:	0f b6 c0             	movzbl %al,%eax
  80098b:	0f b6 12             	movzbl (%edx),%edx
  80098e:	29 d0                	sub    %edx,%eax
}
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	53                   	push   %ebx
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099c:	89 c3                	mov    %eax,%ebx
  80099e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009a1:	eb 06                	jmp    8009a9 <strncmp+0x17>
		n--, p++, q++;
  8009a3:	83 c0 01             	add    $0x1,%eax
  8009a6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009a9:	39 d8                	cmp    %ebx,%eax
  8009ab:	74 16                	je     8009c3 <strncmp+0x31>
  8009ad:	0f b6 08             	movzbl (%eax),%ecx
  8009b0:	84 c9                	test   %cl,%cl
  8009b2:	74 04                	je     8009b8 <strncmp+0x26>
  8009b4:	3a 0a                	cmp    (%edx),%cl
  8009b6:	74 eb                	je     8009a3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b8:	0f b6 00             	movzbl (%eax),%eax
  8009bb:	0f b6 12             	movzbl (%edx),%edx
  8009be:	29 d0                	sub    %edx,%eax
}
  8009c0:	5b                   	pop    %ebx
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    
		return 0;
  8009c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c8:	eb f6                	jmp    8009c0 <strncmp+0x2e>

008009ca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d4:	0f b6 10             	movzbl (%eax),%edx
  8009d7:	84 d2                	test   %dl,%dl
  8009d9:	74 09                	je     8009e4 <strchr+0x1a>
		if (*s == c)
  8009db:	38 ca                	cmp    %cl,%dl
  8009dd:	74 0a                	je     8009e9 <strchr+0x1f>
	for (; *s; s++)
  8009df:	83 c0 01             	add    $0x1,%eax
  8009e2:	eb f0                	jmp    8009d4 <strchr+0xa>
			return (char *) s;
	return 0;
  8009e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f5:	eb 03                	jmp    8009fa <strfind+0xf>
  8009f7:	83 c0 01             	add    $0x1,%eax
  8009fa:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009fd:	38 ca                	cmp    %cl,%dl
  8009ff:	74 04                	je     800a05 <strfind+0x1a>
  800a01:	84 d2                	test   %dl,%dl
  800a03:	75 f2                	jne    8009f7 <strfind+0xc>
			break;
	return (char *) s;
}
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	57                   	push   %edi
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a10:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a13:	85 c9                	test   %ecx,%ecx
  800a15:	74 13                	je     800a2a <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a17:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1d:	75 05                	jne    800a24 <memset+0x1d>
  800a1f:	f6 c1 03             	test   $0x3,%cl
  800a22:	74 0d                	je     800a31 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a27:	fc                   	cld    
  800a28:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2a:	89 f8                	mov    %edi,%eax
  800a2c:	5b                   	pop    %ebx
  800a2d:	5e                   	pop    %esi
  800a2e:	5f                   	pop    %edi
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    
		c &= 0xFF;
  800a31:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a35:	89 d3                	mov    %edx,%ebx
  800a37:	c1 e3 08             	shl    $0x8,%ebx
  800a3a:	89 d0                	mov    %edx,%eax
  800a3c:	c1 e0 18             	shl    $0x18,%eax
  800a3f:	89 d6                	mov    %edx,%esi
  800a41:	c1 e6 10             	shl    $0x10,%esi
  800a44:	09 f0                	or     %esi,%eax
  800a46:	09 c2                	or     %eax,%edx
  800a48:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a4a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a4d:	89 d0                	mov    %edx,%eax
  800a4f:	fc                   	cld    
  800a50:	f3 ab                	rep stos %eax,%es:(%edi)
  800a52:	eb d6                	jmp    800a2a <memset+0x23>

00800a54 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a62:	39 c6                	cmp    %eax,%esi
  800a64:	73 35                	jae    800a9b <memmove+0x47>
  800a66:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a69:	39 c2                	cmp    %eax,%edx
  800a6b:	76 2e                	jbe    800a9b <memmove+0x47>
		s += n;
		d += n;
  800a6d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a70:	89 d6                	mov    %edx,%esi
  800a72:	09 fe                	or     %edi,%esi
  800a74:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a7a:	74 0c                	je     800a88 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a7c:	83 ef 01             	sub    $0x1,%edi
  800a7f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a82:	fd                   	std    
  800a83:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a85:	fc                   	cld    
  800a86:	eb 21                	jmp    800aa9 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a88:	f6 c1 03             	test   $0x3,%cl
  800a8b:	75 ef                	jne    800a7c <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a8d:	83 ef 04             	sub    $0x4,%edi
  800a90:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a93:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a96:	fd                   	std    
  800a97:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a99:	eb ea                	jmp    800a85 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9b:	89 f2                	mov    %esi,%edx
  800a9d:	09 c2                	or     %eax,%edx
  800a9f:	f6 c2 03             	test   $0x3,%dl
  800aa2:	74 09                	je     800aad <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa4:	89 c7                	mov    %eax,%edi
  800aa6:	fc                   	cld    
  800aa7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa9:	5e                   	pop    %esi
  800aaa:	5f                   	pop    %edi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aad:	f6 c1 03             	test   $0x3,%cl
  800ab0:	75 f2                	jne    800aa4 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ab2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ab5:	89 c7                	mov    %eax,%edi
  800ab7:	fc                   	cld    
  800ab8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aba:	eb ed                	jmp    800aa9 <memmove+0x55>

00800abc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800abf:	ff 75 10             	pushl  0x10(%ebp)
  800ac2:	ff 75 0c             	pushl  0xc(%ebp)
  800ac5:	ff 75 08             	pushl  0x8(%ebp)
  800ac8:	e8 87 ff ff ff       	call   800a54 <memmove>
}
  800acd:	c9                   	leave  
  800ace:	c3                   	ret    

00800acf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	56                   	push   %esi
  800ad3:	53                   	push   %ebx
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ada:	89 c6                	mov    %eax,%esi
  800adc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800adf:	39 f0                	cmp    %esi,%eax
  800ae1:	74 1c                	je     800aff <memcmp+0x30>
		if (*s1 != *s2)
  800ae3:	0f b6 08             	movzbl (%eax),%ecx
  800ae6:	0f b6 1a             	movzbl (%edx),%ebx
  800ae9:	38 d9                	cmp    %bl,%cl
  800aeb:	75 08                	jne    800af5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800aed:	83 c0 01             	add    $0x1,%eax
  800af0:	83 c2 01             	add    $0x1,%edx
  800af3:	eb ea                	jmp    800adf <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800af5:	0f b6 c1             	movzbl %cl,%eax
  800af8:	0f b6 db             	movzbl %bl,%ebx
  800afb:	29 d8                	sub    %ebx,%eax
  800afd:	eb 05                	jmp    800b04 <memcmp+0x35>
	}

	return 0;
  800aff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b11:	89 c2                	mov    %eax,%edx
  800b13:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b16:	39 d0                	cmp    %edx,%eax
  800b18:	73 09                	jae    800b23 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b1a:	38 08                	cmp    %cl,(%eax)
  800b1c:	74 05                	je     800b23 <memfind+0x1b>
	for (; s < ends; s++)
  800b1e:	83 c0 01             	add    $0x1,%eax
  800b21:	eb f3                	jmp    800b16 <memfind+0xe>
			break;
	return (void *) s;
}
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
  800b2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b31:	eb 03                	jmp    800b36 <strtol+0x11>
		s++;
  800b33:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b36:	0f b6 01             	movzbl (%ecx),%eax
  800b39:	3c 20                	cmp    $0x20,%al
  800b3b:	74 f6                	je     800b33 <strtol+0xe>
  800b3d:	3c 09                	cmp    $0x9,%al
  800b3f:	74 f2                	je     800b33 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b41:	3c 2b                	cmp    $0x2b,%al
  800b43:	74 2e                	je     800b73 <strtol+0x4e>
	int neg = 0;
  800b45:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b4a:	3c 2d                	cmp    $0x2d,%al
  800b4c:	74 2f                	je     800b7d <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b4e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b54:	75 05                	jne    800b5b <strtol+0x36>
  800b56:	80 39 30             	cmpb   $0x30,(%ecx)
  800b59:	74 2c                	je     800b87 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5b:	85 db                	test   %ebx,%ebx
  800b5d:	75 0a                	jne    800b69 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b5f:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b64:	80 39 30             	cmpb   $0x30,(%ecx)
  800b67:	74 28                	je     800b91 <strtol+0x6c>
		base = 10;
  800b69:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b71:	eb 50                	jmp    800bc3 <strtol+0x9e>
		s++;
  800b73:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b76:	bf 00 00 00 00       	mov    $0x0,%edi
  800b7b:	eb d1                	jmp    800b4e <strtol+0x29>
		s++, neg = 1;
  800b7d:	83 c1 01             	add    $0x1,%ecx
  800b80:	bf 01 00 00 00       	mov    $0x1,%edi
  800b85:	eb c7                	jmp    800b4e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b87:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b8b:	74 0e                	je     800b9b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b8d:	85 db                	test   %ebx,%ebx
  800b8f:	75 d8                	jne    800b69 <strtol+0x44>
		s++, base = 8;
  800b91:	83 c1 01             	add    $0x1,%ecx
  800b94:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b99:	eb ce                	jmp    800b69 <strtol+0x44>
		s += 2, base = 16;
  800b9b:	83 c1 02             	add    $0x2,%ecx
  800b9e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ba3:	eb c4                	jmp    800b69 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ba5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ba8:	89 f3                	mov    %esi,%ebx
  800baa:	80 fb 19             	cmp    $0x19,%bl
  800bad:	77 29                	ja     800bd8 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800baf:	0f be d2             	movsbl %dl,%edx
  800bb2:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bb5:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bb8:	7d 30                	jge    800bea <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800bba:	83 c1 01             	add    $0x1,%ecx
  800bbd:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bc1:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bc3:	0f b6 11             	movzbl (%ecx),%edx
  800bc6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bc9:	89 f3                	mov    %esi,%ebx
  800bcb:	80 fb 09             	cmp    $0x9,%bl
  800bce:	77 d5                	ja     800ba5 <strtol+0x80>
			dig = *s - '0';
  800bd0:	0f be d2             	movsbl %dl,%edx
  800bd3:	83 ea 30             	sub    $0x30,%edx
  800bd6:	eb dd                	jmp    800bb5 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bd8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bdb:	89 f3                	mov    %esi,%ebx
  800bdd:	80 fb 19             	cmp    $0x19,%bl
  800be0:	77 08                	ja     800bea <strtol+0xc5>
			dig = *s - 'A' + 10;
  800be2:	0f be d2             	movsbl %dl,%edx
  800be5:	83 ea 37             	sub    $0x37,%edx
  800be8:	eb cb                	jmp    800bb5 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bee:	74 05                	je     800bf5 <strtol+0xd0>
		*endptr = (char *) s;
  800bf0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf3:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bf5:	89 c2                	mov    %eax,%edx
  800bf7:	f7 da                	neg    %edx
  800bf9:	85 ff                	test   %edi,%edi
  800bfb:	0f 45 c2             	cmovne %edx,%eax
}
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    
  800c03:	66 90                	xchg   %ax,%ax
  800c05:	66 90                	xchg   %ax,%ax
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
