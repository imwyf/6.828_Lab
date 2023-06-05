
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 40 23 00       	mov    $0x234000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 d0 11 f0       	mov    $0xf011d000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 6f 00 00 00       	call   f01000ad <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	57                   	push   %edi
f0100044:	56                   	push   %esi
f0100045:	53                   	push   %ebx
f0100046:	83 ec 0c             	sub    $0xc,%esp
f0100049:	e8 63 02 00 00       	call   f01002b1 <__x86.get_pc_thunk.bx>
f010004e:	81 c3 8e 3b 13 00    	add    $0x133b8e,%ebx
f0100054:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f0100057:	c7 c0 00 6f 23 f0    	mov    $0xf0236f00,%eax
f010005d:	83 38 00             	cmpl   $0x0,(%eax)
f0100060:	74 0f                	je     f0100071 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100062:	83 ec 0c             	sub    $0xc,%esp
f0100065:	6a 00                	push   $0x0
f0100067:	e8 10 0a 00 00       	call   f0100a7c <monitor>
f010006c:	83 c4 10             	add    $0x10,%esp
f010006f:	eb f1                	jmp    f0100062 <_panic+0x22>
	panicstr = fmt;
f0100071:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100073:	fa                   	cli    
f0100074:	fc                   	cld    
	va_start(ap, fmt);
f0100075:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f0100078:	e8 1e 53 00 00       	call   f010539b <cpunum>
f010007d:	ff 75 0c             	pushl  0xc(%ebp)
f0100080:	ff 75 08             	pushl  0x8(%ebp)
f0100083:	50                   	push   %eax
f0100084:	8d 83 04 1f ed ff    	lea    -0x12e0fc(%ebx),%eax
f010008a:	50                   	push   %eax
f010008b:	e8 6f 33 00 00       	call   f01033ff <cprintf>
	vcprintf(fmt, ap);
f0100090:	83 c4 08             	add    $0x8,%esp
f0100093:	56                   	push   %esi
f0100094:	57                   	push   %edi
f0100095:	e8 2e 33 00 00       	call   f01033c8 <vcprintf>
	cprintf("\n");
f010009a:	8d 83 d1 1f ed ff    	lea    -0x12e02f(%ebx),%eax
f01000a0:	89 04 24             	mov    %eax,(%esp)
f01000a3:	e8 57 33 00 00       	call   f01033ff <cprintf>
f01000a8:	83 c4 10             	add    $0x10,%esp
f01000ab:	eb b5                	jmp    f0100062 <_panic+0x22>

f01000ad <i386_init>:
{
f01000ad:	55                   	push   %ebp
f01000ae:	89 e5                	mov    %esp,%ebp
f01000b0:	57                   	push   %edi
f01000b1:	56                   	push   %esi
f01000b2:	53                   	push   %ebx
f01000b3:	83 ec 20             	sub    $0x20,%esp
f01000b6:	e8 f6 01 00 00       	call   f01002b1 <__x86.get_pc_thunk.bx>
f01000bb:	81 c3 21 3b 13 00    	add    $0x133b21,%ebx
	memset(edata, 0, end - edata);
f01000c1:	c7 c2 00 60 23 f0    	mov    $0xf0236000,%edx
f01000c7:	c7 c0 08 80 27 f0    	mov    $0xf0278008,%eax
f01000cd:	29 d0                	sub    %edx,%eax
f01000cf:	50                   	push   %eax
f01000d0:	6a 00                	push   $0x0
f01000d2:	52                   	push   %edx
f01000d3:	e8 04 4c 00 00       	call   f0104cdc <memset>
	cons_init();
f01000d8:	e8 29 06 00 00       	call   f0100706 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000dd:	83 c4 08             	add    $0x8,%esp
f01000e0:	68 ac 1a 00 00       	push   $0x1aac
f01000e5:	8d 83 70 1f ed ff    	lea    -0x12e090(%ebx),%eax
f01000eb:	50                   	push   %eax
f01000ec:	e8 0e 33 00 00       	call   f01033ff <cprintf>
	mem_init();
f01000f1:	e8 26 11 00 00       	call   f010121c <mem_init>
	env_init();
f01000f6:	e8 23 2a 00 00       	call   f0102b1e <env_init>
	trap_init();
f01000fb:	e8 b2 33 00 00       	call   f01034b2 <trap_init>
	mp_init();
f0100100:	e8 07 4f 00 00       	call   f010500c <mp_init>
	lapic_init();
f0100105:	e8 b7 52 00 00       	call   f01053c1 <lapic_init>
	pic_init();
f010010a:	e8 e7 31 00 00       	call   f01032f6 <pic_init>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010010f:	83 c4 10             	add    $0x10,%esp
f0100112:	c7 c0 08 6f 23 f0    	mov    $0xf0236f08,%eax
f0100118:	83 38 07             	cmpl   $0x7,(%eax)
f010011b:	76 31                	jbe    f010014e <i386_init+0xa1>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011d:	83 ec 04             	sub    $0x4,%esp
f0100120:	c7 c2 d8 4e 10 f0    	mov    $0xf0104ed8,%edx
f0100126:	c7 c0 52 4f 10 f0    	mov    $0xf0104f52,%eax
f010012c:	29 d0                	sub    %edx,%eax
f010012e:	50                   	push   %eax
f010012f:	52                   	push   %edx
f0100130:	68 00 70 00 f0       	push   $0xf0007000
f0100135:	e8 ef 4b 00 00       	call   f0104d29 <memmove>
f010013a:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f010013d:	c7 c6 20 70 23 f0    	mov    $0xf0237020,%esi
f0100143:	c7 c7 c4 73 23 f0    	mov    $0xf02373c4,%edi
f0100149:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f010014c:	eb 1d                	jmp    f010016b <i386_init+0xbe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010014e:	68 00 70 00 00       	push   $0x7000
f0100153:	8d 83 28 1f ed ff    	lea    -0x12e0d8(%ebx),%eax
f0100159:	50                   	push   %eax
f010015a:	6a 53                	push   $0x53
f010015c:	8d 83 8b 1f ed ff    	lea    -0x12e075(%ebx),%eax
f0100162:	50                   	push   %eax
f0100163:	e8 d8 fe ff ff       	call   f0100040 <_panic>
f0100168:	83 c6 74             	add    $0x74,%esi
f010016b:	6b 07 74             	imul   $0x74,(%edi),%eax
f010016e:	03 45 e4             	add    -0x1c(%ebp),%eax
f0100171:	39 c6                	cmp    %eax,%esi
f0100173:	73 59                	jae    f01001ce <i386_init+0x121>
		if (c == cpus + cpunum())  // We've started already.
f0100175:	e8 21 52 00 00       	call   f010539b <cpunum>
f010017a:	6b c0 74             	imul   $0x74,%eax,%eax
f010017d:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0100183:	39 c6                	cmp    %eax,%esi
f0100185:	74 e1                	je     f0100168 <i386_init+0xbb>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100187:	89 f0                	mov    %esi,%eax
f0100189:	81 e8 20 70 23 f0    	sub    $0xf0237020,%eax
f010018f:	c1 f8 02             	sar    $0x2,%eax
f0100192:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100198:	c1 e0 0f             	shl    $0xf,%eax
f010019b:	c7 c2 00 80 23 f0    	mov    $0xf0238000,%edx
f01001a1:	8d 94 10 00 80 00 00 	lea    0x8000(%eax,%edx,1),%edx
f01001a8:	c7 c0 04 6f 23 f0    	mov    $0xf0236f04,%eax
f01001ae:	89 10                	mov    %edx,(%eax)
		lapic_startap(c->cpu_id, PADDR(code));
f01001b0:	83 ec 08             	sub    $0x8,%esp
f01001b3:	68 00 70 00 00       	push   $0x7000
f01001b8:	0f b6 06             	movzbl (%esi),%eax
f01001bb:	50                   	push   %eax
f01001bc:	e8 84 53 00 00       	call   f0105545 <lapic_startap>
f01001c1:	83 c4 10             	add    $0x10,%esp
		while(c->cpu_status != CPU_STARTED)
f01001c4:	8b 46 04             	mov    0x4(%esi),%eax
f01001c7:	83 f8 01             	cmp    $0x1,%eax
f01001ca:	75 f8                	jne    f01001c4 <i386_init+0x117>
f01001cc:	eb 9a                	jmp    f0100168 <i386_init+0xbb>
	ENV_CREATE(user_primes, ENV_TYPE_USER);
f01001ce:	83 ec 08             	sub    $0x8,%esp
f01001d1:	6a 00                	push   $0x0
f01001d3:	ff b3 f4 ff ff ff    	pushl  -0xc(%ebx)
f01001d9:	e8 43 2b 00 00       	call   f0102d21 <env_create>
	sched_yield();
f01001de:	e8 15 3d 00 00       	call   f0103ef8 <sched_yield>

f01001e3 <mp_main>:
{
f01001e3:	55                   	push   %ebp
f01001e4:	89 e5                	mov    %esp,%ebp
f01001e6:	53                   	push   %ebx
f01001e7:	83 ec 04             	sub    $0x4,%esp
f01001ea:	e8 c2 00 00 00       	call   f01002b1 <__x86.get_pc_thunk.bx>
f01001ef:	81 c3 ed 39 13 00    	add    $0x1339ed,%ebx
	lcr3(PADDR(kern_pgdir));
f01001f5:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f01001fb:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01001fd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100202:	77 16                	ja     f010021a <mp_main+0x37>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100204:	50                   	push   %eax
f0100205:	8d 83 4c 1f ed ff    	lea    -0x12e0b4(%ebx),%eax
f010020b:	50                   	push   %eax
f010020c:	6a 6a                	push   $0x6a
f010020e:	8d 83 8b 1f ed ff    	lea    -0x12e075(%ebx),%eax
f0100214:	50                   	push   %eax
f0100215:	e8 26 fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010021a:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010021f:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100222:	e8 74 51 00 00       	call   f010539b <cpunum>
f0100227:	83 ec 08             	sub    $0x8,%esp
f010022a:	50                   	push   %eax
f010022b:	8d 83 97 1f ed ff    	lea    -0x12e069(%ebx),%eax
f0100231:	50                   	push   %eax
f0100232:	e8 c8 31 00 00       	call   f01033ff <cprintf>
	lapic_init();
f0100237:	e8 85 51 00 00       	call   f01053c1 <lapic_init>
	env_init_percpu();
f010023c:	e8 a2 28 00 00       	call   f0102ae3 <env_init_percpu>
	trap_init_percpu();
f0100241:	e8 cd 31 00 00       	call   f0103413 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100246:	e8 50 51 00 00       	call   f010539b <cpunum>
f010024b:	6b c0 74             	imul   $0x74,%eax,%eax
f010024e:	c7 c2 20 70 23 f0    	mov    $0xf0237020,%edx
f0100254:	8d 54 10 04          	lea    0x4(%eax,%edx,1),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100258:	b8 01 00 00 00       	mov    $0x1,%eax
f010025d:	f0 87 02             	lock xchg %eax,(%edx)
f0100260:	83 c4 10             	add    $0x10,%esp
f0100263:	eb fe                	jmp    f0100263 <mp_main+0x80>

f0100265 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100265:	55                   	push   %ebp
f0100266:	89 e5                	mov    %esp,%ebp
f0100268:	56                   	push   %esi
f0100269:	53                   	push   %ebx
f010026a:	e8 42 00 00 00       	call   f01002b1 <__x86.get_pc_thunk.bx>
f010026f:	81 c3 6d 39 13 00    	add    $0x13396d,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100275:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100278:	83 ec 04             	sub    $0x4,%esp
f010027b:	ff 75 0c             	pushl  0xc(%ebp)
f010027e:	ff 75 08             	pushl  0x8(%ebp)
f0100281:	8d 83 ad 1f ed ff    	lea    -0x12e053(%ebx),%eax
f0100287:	50                   	push   %eax
f0100288:	e8 72 31 00 00       	call   f01033ff <cprintf>
	vcprintf(fmt, ap);
f010028d:	83 c4 08             	add    $0x8,%esp
f0100290:	56                   	push   %esi
f0100291:	ff 75 10             	pushl  0x10(%ebp)
f0100294:	e8 2f 31 00 00       	call   f01033c8 <vcprintf>
	cprintf("\n");
f0100299:	8d 83 d1 1f ed ff    	lea    -0x12e02f(%ebx),%eax
f010029f:	89 04 24             	mov    %eax,(%esp)
f01002a2:	e8 58 31 00 00       	call   f01033ff <cprintf>
	va_end(ap);
}
f01002a7:	83 c4 10             	add    $0x10,%esp
f01002aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002ad:	5b                   	pop    %ebx
f01002ae:	5e                   	pop    %esi
f01002af:	5d                   	pop    %ebp
f01002b0:	c3                   	ret    

f01002b1 <__x86.get_pc_thunk.bx>:
f01002b1:	8b 1c 24             	mov    (%esp),%ebx
f01002b4:	c3                   	ret    

f01002b5 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002b5:	55                   	push   %ebp
f01002b6:	89 e5                	mov    %esp,%ebp
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002b8:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002bd:	ec                   	in     (%dx),%al
	if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA))
f01002be:	a8 01                	test   $0x1,%al
f01002c0:	74 0b                	je     f01002cd <serial_proc_data+0x18>
f01002c2:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002c7:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1 + COM_RX);
f01002c8:	0f b6 c0             	movzbl %al,%eax
}
f01002cb:	5d                   	pop    %ebp
f01002cc:	c3                   	ret    
		return -1;
f01002cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002d2:	eb f7                	jmp    f01002cb <serial_proc_data+0x16>

f01002d4 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002d4:	55                   	push   %ebp
f01002d5:	89 e5                	mov    %esp,%ebp
f01002d7:	56                   	push   %esi
f01002d8:	53                   	push   %ebx
f01002d9:	e8 d3 ff ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f01002de:	81 c3 fe 38 13 00    	add    $0x1338fe,%ebx
f01002e4:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1)
f01002e6:	ff d6                	call   *%esi
f01002e8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002eb:	74 2e                	je     f010031b <cons_intr+0x47>
	{
		if (c == 0)
f01002ed:	85 c0                	test   %eax,%eax
f01002ef:	74 f5                	je     f01002e6 <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01002f1:	8b 8b 48 26 00 00    	mov    0x2648(%ebx),%ecx
f01002f7:	8d 51 01             	lea    0x1(%ecx),%edx
f01002fa:	89 93 48 26 00 00    	mov    %edx,0x2648(%ebx)
f0100300:	88 84 0b 44 24 00 00 	mov    %al,0x2444(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100307:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010030d:	75 d7                	jne    f01002e6 <cons_intr+0x12>
			cons.wpos = 0;
f010030f:	c7 83 48 26 00 00 00 	movl   $0x0,0x2648(%ebx)
f0100316:	00 00 00 
f0100319:	eb cb                	jmp    f01002e6 <cons_intr+0x12>
	}
}
f010031b:	5b                   	pop    %ebx
f010031c:	5e                   	pop    %esi
f010031d:	5d                   	pop    %ebp
f010031e:	c3                   	ret    

f010031f <kbd_proc_data>:
{
f010031f:	55                   	push   %ebp
f0100320:	89 e5                	mov    %esp,%ebp
f0100322:	56                   	push   %esi
f0100323:	53                   	push   %ebx
f0100324:	e8 88 ff ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0100329:	81 c3 b3 38 13 00    	add    $0x1338b3,%ebx
f010032f:	ba 64 00 00 00       	mov    $0x64,%edx
f0100334:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100335:	a8 01                	test   $0x1,%al
f0100337:	0f 84 06 01 00 00    	je     f0100443 <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f010033d:	a8 20                	test   $0x20,%al
f010033f:	0f 85 05 01 00 00    	jne    f010044a <kbd_proc_data+0x12b>
f0100345:	ba 60 00 00 00       	mov    $0x60,%edx
f010034a:	ec                   	in     (%dx),%al
f010034b:	89 c2                	mov    %eax,%edx
	if (data == 0xE0)
f010034d:	3c e0                	cmp    $0xe0,%al
f010034f:	0f 84 93 00 00 00    	je     f01003e8 <kbd_proc_data+0xc9>
	else if (data & 0x80)
f0100355:	84 c0                	test   %al,%al
f0100357:	0f 88 a0 00 00 00    	js     f01003fd <kbd_proc_data+0xde>
	else if (shift & E0ESC)
f010035d:	8b 8b 24 24 00 00    	mov    0x2424(%ebx),%ecx
f0100363:	f6 c1 40             	test   $0x40,%cl
f0100366:	74 0e                	je     f0100376 <kbd_proc_data+0x57>
		data |= 0x80;
f0100368:	83 c8 80             	or     $0xffffff80,%eax
f010036b:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010036d:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100370:	89 8b 24 24 00 00    	mov    %ecx,0x2424(%ebx)
	shift |= shiftcode[data];
f0100376:	0f b6 d2             	movzbl %dl,%edx
f0100379:	0f b6 84 13 04 21 ed 	movzbl -0x12defc(%ebx,%edx,1),%eax
f0100380:	ff 
f0100381:	0b 83 24 24 00 00    	or     0x2424(%ebx),%eax
	shift ^= togglecode[data];
f0100387:	0f b6 8c 13 04 20 ed 	movzbl -0x12dffc(%ebx,%edx,1),%ecx
f010038e:	ff 
f010038f:	31 c8                	xor    %ecx,%eax
f0100391:	89 83 24 24 00 00    	mov    %eax,0x2424(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f0100397:	89 c1                	mov    %eax,%ecx
f0100399:	83 e1 03             	and    $0x3,%ecx
f010039c:	8b 8c 8b 84 14 00 00 	mov    0x1484(%ebx,%ecx,4),%ecx
f01003a3:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003a7:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK)
f01003aa:	a8 08                	test   $0x8,%al
f01003ac:	74 0d                	je     f01003bb <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f01003ae:	89 f2                	mov    %esi,%edx
f01003b0:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01003b3:	83 f9 19             	cmp    $0x19,%ecx
f01003b6:	77 7a                	ja     f0100432 <kbd_proc_data+0x113>
			c += 'A' - 'a';
f01003b8:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL)
f01003bb:	f7 d0                	not    %eax
f01003bd:	a8 06                	test   $0x6,%al
f01003bf:	75 33                	jne    f01003f4 <kbd_proc_data+0xd5>
f01003c1:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01003c7:	75 2b                	jne    f01003f4 <kbd_proc_data+0xd5>
		cprintf("Rebooting!\n");
f01003c9:	83 ec 0c             	sub    $0xc,%esp
f01003cc:	8d 83 c7 1f ed ff    	lea    -0x12e039(%ebx),%eax
f01003d2:	50                   	push   %eax
f01003d3:	e8 27 30 00 00       	call   f01033ff <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003d8:	b8 03 00 00 00       	mov    $0x3,%eax
f01003dd:	ba 92 00 00 00       	mov    $0x92,%edx
f01003e2:	ee                   	out    %al,(%dx)
f01003e3:	83 c4 10             	add    $0x10,%esp
f01003e6:	eb 0c                	jmp    f01003f4 <kbd_proc_data+0xd5>
		shift |= E0ESC;
f01003e8:	83 8b 24 24 00 00 40 	orl    $0x40,0x2424(%ebx)
		return 0;
f01003ef:	be 00 00 00 00       	mov    $0x0,%esi
}
f01003f4:	89 f0                	mov    %esi,%eax
f01003f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01003f9:	5b                   	pop    %ebx
f01003fa:	5e                   	pop    %esi
f01003fb:	5d                   	pop    %ebp
f01003fc:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01003fd:	8b 8b 24 24 00 00    	mov    0x2424(%ebx),%ecx
f0100403:	89 ce                	mov    %ecx,%esi
f0100405:	83 e6 40             	and    $0x40,%esi
f0100408:	83 e0 7f             	and    $0x7f,%eax
f010040b:	85 f6                	test   %esi,%esi
f010040d:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100410:	0f b6 d2             	movzbl %dl,%edx
f0100413:	0f b6 84 13 04 21 ed 	movzbl -0x12defc(%ebx,%edx,1),%eax
f010041a:	ff 
f010041b:	83 c8 40             	or     $0x40,%eax
f010041e:	0f b6 c0             	movzbl %al,%eax
f0100421:	f7 d0                	not    %eax
f0100423:	21 c8                	and    %ecx,%eax
f0100425:	89 83 24 24 00 00    	mov    %eax,0x2424(%ebx)
		return 0;
f010042b:	be 00 00 00 00       	mov    $0x0,%esi
f0100430:	eb c2                	jmp    f01003f4 <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f0100432:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100435:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100438:	83 fa 1a             	cmp    $0x1a,%edx
f010043b:	0f 42 f1             	cmovb  %ecx,%esi
f010043e:	e9 78 ff ff ff       	jmp    f01003bb <kbd_proc_data+0x9c>
		return -1;
f0100443:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100448:	eb aa                	jmp    f01003f4 <kbd_proc_data+0xd5>
		return -1;
f010044a:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010044f:	eb a3                	jmp    f01003f4 <kbd_proc_data+0xd5>

f0100451 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100451:	55                   	push   %ebp
f0100452:	89 e5                	mov    %esp,%ebp
f0100454:	57                   	push   %edi
f0100455:	56                   	push   %esi
f0100456:	53                   	push   %ebx
f0100457:	83 ec 1c             	sub    $0x1c,%esp
f010045a:	e8 52 fe ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f010045f:	81 c3 7d 37 13 00    	add    $0x13377d,%ebx
f0100465:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100468:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010046d:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100472:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100477:	eb 09                	jmp    f0100482 <cons_putc+0x31>
f0100479:	89 ca                	mov    %ecx,%edx
f010047b:	ec                   	in     (%dx),%al
f010047c:	ec                   	in     (%dx),%al
f010047d:	ec                   	in     (%dx),%al
f010047e:	ec                   	in     (%dx),%al
		 i++)
f010047f:	83 c6 01             	add    $0x1,%esi
f0100482:	89 fa                	mov    %edi,%edx
f0100484:	ec                   	in     (%dx),%al
		 !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100485:	a8 20                	test   $0x20,%al
f0100487:	75 08                	jne    f0100491 <cons_putc+0x40>
f0100489:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010048f:	7e e8                	jle    f0100479 <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f0100491:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100494:	89 f8                	mov    %edi,%eax
f0100496:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100499:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010049e:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378 + 1) & 0x80) && i < 12800; i++)
f010049f:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004a4:	bf 79 03 00 00       	mov    $0x379,%edi
f01004a9:	b9 84 00 00 00       	mov    $0x84,%ecx
f01004ae:	eb 09                	jmp    f01004b9 <cons_putc+0x68>
f01004b0:	89 ca                	mov    %ecx,%edx
f01004b2:	ec                   	in     (%dx),%al
f01004b3:	ec                   	in     (%dx),%al
f01004b4:	ec                   	in     (%dx),%al
f01004b5:	ec                   	in     (%dx),%al
f01004b6:	83 c6 01             	add    $0x1,%esi
f01004b9:	89 fa                	mov    %edi,%edx
f01004bb:	ec                   	in     (%dx),%al
f01004bc:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01004c2:	7f 04                	jg     f01004c8 <cons_putc+0x77>
f01004c4:	84 c0                	test   %al,%al
f01004c6:	79 e8                	jns    f01004b0 <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004c8:	ba 78 03 00 00       	mov    $0x378,%edx
f01004cd:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01004d1:	ee                   	out    %al,(%dx)
f01004d2:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01004d7:	b8 0d 00 00 00       	mov    $0xd,%eax
f01004dc:	ee                   	out    %al,(%dx)
f01004dd:	b8 08 00 00 00       	mov    $0x8,%eax
f01004e2:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01004e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01004e6:	89 fa                	mov    %edi,%edx
f01004e8:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01004ee:	89 f8                	mov    %edi,%eax
f01004f0:	80 cc 07             	or     $0x7,%ah
f01004f3:	85 d2                	test   %edx,%edx
f01004f5:	0f 45 c7             	cmovne %edi,%eax
f01004f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff)
f01004fb:	0f b6 c0             	movzbl %al,%eax
f01004fe:	83 f8 09             	cmp    $0x9,%eax
f0100501:	0f 84 b9 00 00 00    	je     f01005c0 <cons_putc+0x16f>
f0100507:	83 f8 09             	cmp    $0x9,%eax
f010050a:	7e 74                	jle    f0100580 <cons_putc+0x12f>
f010050c:	83 f8 0a             	cmp    $0xa,%eax
f010050f:	0f 84 9e 00 00 00    	je     f01005b3 <cons_putc+0x162>
f0100515:	83 f8 0d             	cmp    $0xd,%eax
f0100518:	0f 85 d9 00 00 00    	jne    f01005f7 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f010051e:	0f b7 83 4c 26 00 00 	movzwl 0x264c(%ebx),%eax
f0100525:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010052b:	c1 e8 16             	shr    $0x16,%eax
f010052e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100531:	c1 e0 04             	shl    $0x4,%eax
f0100534:	66 89 83 4c 26 00 00 	mov    %ax,0x264c(%ebx)
	if (crt_pos >= CRT_SIZE) // 当输出字符超过终端范围
f010053b:	66 81 bb 4c 26 00 00 	cmpw   $0x7cf,0x264c(%ebx)
f0100542:	cf 07 
f0100544:	0f 87 d4 00 00 00    	ja     f010061e <cons_putc+0x1cd>
	outb(addr_6845, 14);
f010054a:	8b 8b 54 26 00 00    	mov    0x2654(%ebx),%ecx
f0100550:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100555:	89 ca                	mov    %ecx,%edx
f0100557:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100558:	0f b7 9b 4c 26 00 00 	movzwl 0x264c(%ebx),%ebx
f010055f:	8d 71 01             	lea    0x1(%ecx),%esi
f0100562:	89 d8                	mov    %ebx,%eax
f0100564:	66 c1 e8 08          	shr    $0x8,%ax
f0100568:	89 f2                	mov    %esi,%edx
f010056a:	ee                   	out    %al,(%dx)
f010056b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100570:	89 ca                	mov    %ecx,%edx
f0100572:	ee                   	out    %al,(%dx)
f0100573:	89 d8                	mov    %ebx,%eax
f0100575:	89 f2                	mov    %esi,%edx
f0100577:	ee                   	out    %al,(%dx)
	serial_putc(c); // 向串口输出
	lpt_putc(c);
	cga_putc(c); // 向控制台输出字符
}
f0100578:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010057b:	5b                   	pop    %ebx
f010057c:	5e                   	pop    %esi
f010057d:	5f                   	pop    %edi
f010057e:	5d                   	pop    %ebp
f010057f:	c3                   	ret    
	switch (c & 0xff)
f0100580:	83 f8 08             	cmp    $0x8,%eax
f0100583:	75 72                	jne    f01005f7 <cons_putc+0x1a6>
		if (crt_pos > 0)
f0100585:	0f b7 83 4c 26 00 00 	movzwl 0x264c(%ebx),%eax
f010058c:	66 85 c0             	test   %ax,%ax
f010058f:	74 b9                	je     f010054a <cons_putc+0xf9>
			crt_pos--;
f0100591:	83 e8 01             	sub    $0x1,%eax
f0100594:	66 89 83 4c 26 00 00 	mov    %ax,0x264c(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010059b:	0f b7 c0             	movzwl %ax,%eax
f010059e:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01005a2:	b2 00                	mov    $0x0,%dl
f01005a4:	83 ca 20             	or     $0x20,%edx
f01005a7:	8b 8b 50 26 00 00    	mov    0x2650(%ebx),%ecx
f01005ad:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01005b1:	eb 88                	jmp    f010053b <cons_putc+0xea>
		crt_pos += CRT_COLS;
f01005b3:	66 83 83 4c 26 00 00 	addw   $0x50,0x264c(%ebx)
f01005ba:	50 
f01005bb:	e9 5e ff ff ff       	jmp    f010051e <cons_putc+0xcd>
		cons_putc(' ');
f01005c0:	b8 20 00 00 00       	mov    $0x20,%eax
f01005c5:	e8 87 fe ff ff       	call   f0100451 <cons_putc>
		cons_putc(' ');
f01005ca:	b8 20 00 00 00       	mov    $0x20,%eax
f01005cf:	e8 7d fe ff ff       	call   f0100451 <cons_putc>
		cons_putc(' ');
f01005d4:	b8 20 00 00 00       	mov    $0x20,%eax
f01005d9:	e8 73 fe ff ff       	call   f0100451 <cons_putc>
		cons_putc(' ');
f01005de:	b8 20 00 00 00       	mov    $0x20,%eax
f01005e3:	e8 69 fe ff ff       	call   f0100451 <cons_putc>
		cons_putc(' ');
f01005e8:	b8 20 00 00 00       	mov    $0x20,%eax
f01005ed:	e8 5f fe ff ff       	call   f0100451 <cons_putc>
f01005f2:	e9 44 ff ff ff       	jmp    f010053b <cons_putc+0xea>
		crt_buf[crt_pos++] = c; /* write the character */
f01005f7:	0f b7 83 4c 26 00 00 	movzwl 0x264c(%ebx),%eax
f01005fe:	8d 50 01             	lea    0x1(%eax),%edx
f0100601:	66 89 93 4c 26 00 00 	mov    %dx,0x264c(%ebx)
f0100608:	0f b7 c0             	movzwl %ax,%eax
f010060b:	8b 93 50 26 00 00    	mov    0x2650(%ebx),%edx
f0100611:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100615:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100619:	e9 1d ff ff ff       	jmp    f010053b <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t)); // 已有字符往上移动一行
f010061e:	8b 83 50 26 00 00    	mov    0x2650(%ebx),%eax
f0100624:	83 ec 04             	sub    $0x4,%esp
f0100627:	68 00 0f 00 00       	push   $0xf00
f010062c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100632:	52                   	push   %edx
f0100633:	50                   	push   %eax
f0100634:	e8 f0 46 00 00       	call   f0104d29 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100639:	8b 93 50 26 00 00    	mov    0x2650(%ebx),%edx
f010063f:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100645:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010064b:	83 c4 10             	add    $0x10,%esp
f010064e:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100653:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)								// 清零最后一行
f0100656:	39 d0                	cmp    %edx,%eax
f0100658:	75 f4                	jne    f010064e <cons_putc+0x1fd>
		crt_pos -= CRT_COLS; // 索引向前移动，即从最后一行的开头写入
f010065a:	66 83 ab 4c 26 00 00 	subw   $0x50,0x264c(%ebx)
f0100661:	50 
f0100662:	e9 e3 fe ff ff       	jmp    f010054a <cons_putc+0xf9>

f0100667 <serial_intr>:
{
f0100667:	e8 06 02 00 00       	call   f0100872 <__x86.get_pc_thunk.ax>
f010066c:	05 70 35 13 00       	add    $0x133570,%eax
	if (serial_exists)
f0100671:	80 b8 58 26 00 00 00 	cmpb   $0x0,0x2658(%eax)
f0100678:	75 02                	jne    f010067c <serial_intr+0x15>
f010067a:	f3 c3                	repz ret 
{
f010067c:	55                   	push   %ebp
f010067d:	89 e5                	mov    %esp,%ebp
f010067f:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100682:	8d 80 d9 c6 ec ff    	lea    -0x133927(%eax),%eax
f0100688:	e8 47 fc ff ff       	call   f01002d4 <cons_intr>
}
f010068d:	c9                   	leave  
f010068e:	c3                   	ret    

f010068f <kbd_intr>:
{
f010068f:	55                   	push   %ebp
f0100690:	89 e5                	mov    %esp,%ebp
f0100692:	83 ec 08             	sub    $0x8,%esp
f0100695:	e8 d8 01 00 00       	call   f0100872 <__x86.get_pc_thunk.ax>
f010069a:	05 42 35 13 00       	add    $0x133542,%eax
	cons_intr(kbd_proc_data);
f010069f:	8d 80 43 c7 ec ff    	lea    -0x1338bd(%eax),%eax
f01006a5:	e8 2a fc ff ff       	call   f01002d4 <cons_intr>
}
f01006aa:	c9                   	leave  
f01006ab:	c3                   	ret    

f01006ac <cons_getc>:
{
f01006ac:	55                   	push   %ebp
f01006ad:	89 e5                	mov    %esp,%ebp
f01006af:	53                   	push   %ebx
f01006b0:	83 ec 04             	sub    $0x4,%esp
f01006b3:	e8 f9 fb ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f01006b8:	81 c3 24 35 13 00    	add    $0x133524,%ebx
	serial_intr();
f01006be:	e8 a4 ff ff ff       	call   f0100667 <serial_intr>
	kbd_intr();
f01006c3:	e8 c7 ff ff ff       	call   f010068f <kbd_intr>
	if (cons.rpos != cons.wpos)
f01006c8:	8b 93 44 26 00 00    	mov    0x2644(%ebx),%edx
	return 0;
f01006ce:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos)
f01006d3:	3b 93 48 26 00 00    	cmp    0x2648(%ebx),%edx
f01006d9:	74 19                	je     f01006f4 <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f01006db:	8d 4a 01             	lea    0x1(%edx),%ecx
f01006de:	89 8b 44 26 00 00    	mov    %ecx,0x2644(%ebx)
f01006e4:	0f b6 84 13 44 24 00 	movzbl 0x2444(%ebx,%edx,1),%eax
f01006eb:	00 
		if (cons.rpos == CONSBUFSIZE)
f01006ec:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01006f2:	74 06                	je     f01006fa <cons_getc+0x4e>
}
f01006f4:	83 c4 04             	add    $0x4,%esp
f01006f7:	5b                   	pop    %ebx
f01006f8:	5d                   	pop    %ebp
f01006f9:	c3                   	ret    
			cons.rpos = 0;
f01006fa:	c7 83 44 26 00 00 00 	movl   $0x0,0x2644(%ebx)
f0100701:	00 00 00 
f0100704:	eb ee                	jmp    f01006f4 <cons_getc+0x48>

f0100706 <cons_init>:

// initialize the console devices
void cons_init(void)
{
f0100706:	55                   	push   %ebp
f0100707:	89 e5                	mov    %esp,%ebp
f0100709:	57                   	push   %edi
f010070a:	56                   	push   %esi
f010070b:	53                   	push   %ebx
f010070c:	83 ec 1c             	sub    $0x1c,%esp
f010070f:	e8 9d fb ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0100714:	81 c3 c8 34 13 00    	add    $0x1334c8,%ebx
	was = *cp;
f010071a:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t)0xA55A;
f0100721:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100728:	5a a5 
	if (*cp != 0xA55A)
f010072a:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100731:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100735:	0f 84 db 00 00 00    	je     f0100816 <cons_init+0x110>
		addr_6845 = MONO_BASE;
f010073b:	c7 83 54 26 00 00 b4 	movl   $0x3b4,0x2654(%ebx)
f0100742:	03 00 00 
		cp = (uint16_t *)(KERNBASE + MONO_BUF);
f0100745:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f010074c:	8b bb 54 26 00 00    	mov    0x2654(%ebx),%edi
f0100752:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100757:	89 fa                	mov    %edi,%edx
f0100759:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010075a:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010075d:	89 ca                	mov    %ecx,%edx
f010075f:	ec                   	in     (%dx),%al
f0100760:	0f b6 f0             	movzbl %al,%esi
f0100763:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100766:	b8 0f 00 00 00       	mov    $0xf,%eax
f010076b:	89 fa                	mov    %edi,%edx
f010076d:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010076e:	89 ca                	mov    %ecx,%edx
f0100770:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t *)cp;
f0100771:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100774:	89 bb 50 26 00 00    	mov    %edi,0x2650(%ebx)
	pos |= inb(addr_6845 + 1);
f010077a:	0f b6 c0             	movzbl %al,%eax
f010077d:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f010077f:	66 89 b3 4c 26 00 00 	mov    %si,0x264c(%ebx)
	kbd_intr();
f0100786:	e8 04 ff ff ff       	call   f010068f <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f010078b:	83 ec 0c             	sub    $0xc,%esp
f010078e:	c7 c0 68 e3 11 f0    	mov    $0xf011e368,%eax
f0100794:	0f b7 00             	movzwl (%eax),%eax
f0100797:	25 fd ff 00 00       	and    $0xfffd,%eax
f010079c:	50                   	push   %eax
f010079d:	e8 ba 2a 00 00       	call   f010325c <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01007a2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01007a7:	89 c8                	mov    %ecx,%eax
f01007a9:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01007ae:	ee                   	out    %al,(%dx)
f01007af:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01007b4:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01007b9:	89 fa                	mov    %edi,%edx
f01007bb:	ee                   	out    %al,(%dx)
f01007bc:	b8 0c 00 00 00       	mov    $0xc,%eax
f01007c1:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01007c6:	ee                   	out    %al,(%dx)
f01007c7:	be f9 03 00 00       	mov    $0x3f9,%esi
f01007cc:	89 c8                	mov    %ecx,%eax
f01007ce:	89 f2                	mov    %esi,%edx
f01007d0:	ee                   	out    %al,(%dx)
f01007d1:	b8 03 00 00 00       	mov    $0x3,%eax
f01007d6:	89 fa                	mov    %edi,%edx
f01007d8:	ee                   	out    %al,(%dx)
f01007d9:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01007de:	89 c8                	mov    %ecx,%eax
f01007e0:	ee                   	out    %al,(%dx)
f01007e1:	b8 01 00 00 00       	mov    $0x1,%eax
f01007e6:	89 f2                	mov    %esi,%edx
f01007e8:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01007e9:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01007ee:	ec                   	in     (%dx),%al
f01007ef:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
f01007f1:	83 c4 10             	add    $0x10,%esp
f01007f4:	3c ff                	cmp    $0xff,%al
f01007f6:	0f 95 83 58 26 00 00 	setne  0x2658(%ebx)
f01007fd:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100802:	ec                   	in     (%dx),%al
f0100803:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100808:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100809:	80 f9 ff             	cmp    $0xff,%cl
f010080c:	74 25                	je     f0100833 <cons_init+0x12d>
		cprintf("Serial port does not exist!\n");
}
f010080e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100811:	5b                   	pop    %ebx
f0100812:	5e                   	pop    %esi
f0100813:	5f                   	pop    %edi
f0100814:	5d                   	pop    %ebp
f0100815:	c3                   	ret    
		*cp = was;
f0100816:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010081d:	c7 83 54 26 00 00 d4 	movl   $0x3d4,0x2654(%ebx)
f0100824:	03 00 00 
	cp = (uint16_t *)(KERNBASE + CGA_BUF);
f0100827:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f010082e:	e9 19 ff ff ff       	jmp    f010074c <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f0100833:	83 ec 0c             	sub    $0xc,%esp
f0100836:	8d 83 d3 1f ed ff    	lea    -0x12e02d(%ebx),%eax
f010083c:	50                   	push   %eax
f010083d:	e8 bd 2b 00 00       	call   f01033ff <cprintf>
f0100842:	83 c4 10             	add    $0x10,%esp
}
f0100845:	eb c7                	jmp    f010080e <cons_init+0x108>

f0100847 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void cputchar(int c)
{
f0100847:	55                   	push   %ebp
f0100848:	89 e5                	mov    %esp,%ebp
f010084a:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010084d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100850:	e8 fc fb ff ff       	call   f0100451 <cons_putc>
}
f0100855:	c9                   	leave  
f0100856:	c3                   	ret    

f0100857 <getchar>:

int getchar(void)
{
f0100857:	55                   	push   %ebp
f0100858:	89 e5                	mov    %esp,%ebp
f010085a:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010085d:	e8 4a fe ff ff       	call   f01006ac <cons_getc>
f0100862:	85 c0                	test   %eax,%eax
f0100864:	74 f7                	je     f010085d <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100866:	c9                   	leave  
f0100867:	c3                   	ret    

f0100868 <iscons>:

int iscons(int fdnum)
{
f0100868:	55                   	push   %ebp
f0100869:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010086b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100870:	5d                   	pop    %ebp
f0100871:	c3                   	ret    

f0100872 <__x86.get_pc_thunk.ax>:
f0100872:	8b 04 24             	mov    (%esp),%eax
f0100875:	c3                   	ret    

f0100876 <mon_help>:
};

/***** Implementations of basic kernel monitor commands *****/

int mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100876:	55                   	push   %ebp
f0100877:	89 e5                	mov    %esp,%ebp
f0100879:	56                   	push   %esi
f010087a:	53                   	push   %ebx
f010087b:	e8 31 fa ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0100880:	81 c3 5c 33 13 00    	add    $0x13335c,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100886:	83 ec 04             	sub    $0x4,%esp
f0100889:	8d 83 04 22 ed ff    	lea    -0x12ddfc(%ebx),%eax
f010088f:	50                   	push   %eax
f0100890:	8d 83 22 22 ed ff    	lea    -0x12ddde(%ebx),%eax
f0100896:	50                   	push   %eax
f0100897:	8d b3 27 22 ed ff    	lea    -0x12ddd9(%ebx),%esi
f010089d:	56                   	push   %esi
f010089e:	e8 5c 2b 00 00       	call   f01033ff <cprintf>
f01008a3:	83 c4 0c             	add    $0xc,%esp
f01008a6:	8d 83 cc 22 ed ff    	lea    -0x12dd34(%ebx),%eax
f01008ac:	50                   	push   %eax
f01008ad:	8d 83 30 22 ed ff    	lea    -0x12ddd0(%ebx),%eax
f01008b3:	50                   	push   %eax
f01008b4:	56                   	push   %esi
f01008b5:	e8 45 2b 00 00       	call   f01033ff <cprintf>
f01008ba:	83 c4 0c             	add    $0xc,%esp
f01008bd:	8d 83 39 22 ed ff    	lea    -0x12ddc7(%ebx),%eax
f01008c3:	50                   	push   %eax
f01008c4:	8d 83 3f 22 ed ff    	lea    -0x12ddc1(%ebx),%eax
f01008ca:	50                   	push   %eax
f01008cb:	56                   	push   %esi
f01008cc:	e8 2e 2b 00 00       	call   f01033ff <cprintf>
	return 0;
}
f01008d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01008d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01008d9:	5b                   	pop    %ebx
f01008da:	5e                   	pop    %esi
f01008db:	5d                   	pop    %ebp
f01008dc:	c3                   	ret    

f01008dd <mon_kerninfo>:

int mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01008dd:	55                   	push   %ebp
f01008de:	89 e5                	mov    %esp,%ebp
f01008e0:	57                   	push   %edi
f01008e1:	56                   	push   %esi
f01008e2:	53                   	push   %ebx
f01008e3:	83 ec 18             	sub    $0x18,%esp
f01008e6:	e8 c6 f9 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f01008eb:	81 c3 f1 32 13 00    	add    $0x1332f1,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01008f1:	8d 83 49 22 ed ff    	lea    -0x12ddb7(%ebx),%eax
f01008f7:	50                   	push   %eax
f01008f8:	e8 02 2b 00 00       	call   f01033ff <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01008fd:	83 c4 08             	add    $0x8,%esp
f0100900:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
f0100906:	8d 83 f4 22 ed ff    	lea    -0x12dd0c(%ebx),%eax
f010090c:	50                   	push   %eax
f010090d:	e8 ed 2a 00 00       	call   f01033ff <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100912:	83 c4 0c             	add    $0xc,%esp
f0100915:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f010091b:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100921:	50                   	push   %eax
f0100922:	57                   	push   %edi
f0100923:	8d 83 1c 23 ed ff    	lea    -0x12dce4(%ebx),%eax
f0100929:	50                   	push   %eax
f010092a:	e8 d0 2a 00 00       	call   f01033ff <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010092f:	83 c4 0c             	add    $0xc,%esp
f0100932:	c7 c0 c7 5a 10 f0    	mov    $0xf0105ac7,%eax
f0100938:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010093e:	52                   	push   %edx
f010093f:	50                   	push   %eax
f0100940:	8d 83 40 23 ed ff    	lea    -0x12dcc0(%ebx),%eax
f0100946:	50                   	push   %eax
f0100947:	e8 b3 2a 00 00       	call   f01033ff <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010094c:	83 c4 0c             	add    $0xc,%esp
f010094f:	c7 c0 00 60 23 f0    	mov    $0xf0236000,%eax
f0100955:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010095b:	52                   	push   %edx
f010095c:	50                   	push   %eax
f010095d:	8d 83 64 23 ed ff    	lea    -0x12dc9c(%ebx),%eax
f0100963:	50                   	push   %eax
f0100964:	e8 96 2a 00 00       	call   f01033ff <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100969:	83 c4 0c             	add    $0xc,%esp
f010096c:	c7 c6 08 80 27 f0    	mov    $0xf0278008,%esi
f0100972:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100978:	50                   	push   %eax
f0100979:	56                   	push   %esi
f010097a:	8d 83 88 23 ed ff    	lea    -0x12dc78(%ebx),%eax
f0100980:	50                   	push   %eax
f0100981:	e8 79 2a 00 00       	call   f01033ff <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100986:	83 c4 08             	add    $0x8,%esp
			ROUNDUP(end - entry, 1024) / 1024);
f0100989:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f010098f:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100991:	c1 fe 0a             	sar    $0xa,%esi
f0100994:	56                   	push   %esi
f0100995:	8d 83 ac 23 ed ff    	lea    -0x12dc54(%ebx),%eax
f010099b:	50                   	push   %eax
f010099c:	e8 5e 2a 00 00       	call   f01033ff <cprintf>
	return 0;
}
f01009a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01009a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009a9:	5b                   	pop    %ebx
f01009aa:	5e                   	pop    %esi
f01009ab:	5f                   	pop    %edi
f01009ac:	5d                   	pop    %ebp
f01009ad:	c3                   	ret    

f01009ae <mon_backtrace>:

int mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01009ae:	55                   	push   %ebp
f01009af:	89 e5                	mov    %esp,%ebp
f01009b1:	57                   	push   %edi
f01009b2:	56                   	push   %esi
f01009b3:	53                   	push   %ebx
f01009b4:	83 ec 4c             	sub    $0x4c,%esp
f01009b7:	e8 f5 f8 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f01009bc:	81 c3 20 32 13 00    	add    $0x133220,%ebx
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01009c2:	89 e8                	mov    %ebp,%eax
	// 被调用的函数(mon_backtrace)开始时，首先完成了push %ebp，mov %esp, %ebp
	// 注1：push时，先减%esp在存储内容
	// 注2：栈向下生长，用+1来访问前面的内容
	// Your code here.

	int *ebp = (int *)read_ebp(); // 读取本函数%ebp的值，转化为指针，作为地址使用
f01009c4:	89 c7                	mov    %eax,%edi
	int eip = ebp[1];			  // 堆栈上存储的第一个东西就是返回地址，因此用偏移量1来访问
f01009c6:	8b 40 04             	mov    0x4(%eax),%eax
f01009c9:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (1)					  // trace整个stack
	{
		// 打印%ebp和%eip
		cprintf("ebp %x, eip %x, args ", ebp, eip);
f01009cc:	8d 83 62 22 ed ff    	lea    -0x12dd9e(%ebx),%eax
f01009d2:	89 45 b8             	mov    %eax,-0x48(%ebp)
		int *args = ebp + 2;		 // 从偏移量2开始存储的是上个函数的参数
		for (int i = 0; i < 5; ++i)	 // 练习要求打印5个参数
			cprintf("%x ", args[i]); // 输出参数，注：args[i]和args+i是一样的效果
f01009d5:	8d 83 78 22 ed ff    	lea    -0x12dd88(%ebx),%eax
f01009db:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		cprintf("ebp %x, eip %x, args ", ebp, eip);
f01009de:	83 ec 04             	sub    $0x4,%esp
f01009e1:	ff 75 c0             	pushl  -0x40(%ebp)
f01009e4:	57                   	push   %edi
f01009e5:	ff 75 b8             	pushl  -0x48(%ebp)
f01009e8:	e8 12 2a 00 00       	call   f01033ff <cprintf>
f01009ed:	8d 77 08             	lea    0x8(%edi),%esi
f01009f0:	8d 47 1c             	lea    0x1c(%edi),%eax
f01009f3:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01009f6:	83 c4 10             	add    $0x10,%esp
f01009f9:	89 7d bc             	mov    %edi,-0x44(%ebp)
f01009fc:	8b 7d b4             	mov    -0x4c(%ebp),%edi
			cprintf("%x ", args[i]); // 输出参数，注：args[i]和args+i是一样的效果
f01009ff:	83 ec 08             	sub    $0x8,%esp
f0100a02:	ff 36                	pushl  (%esi)
f0100a04:	57                   	push   %edi
f0100a05:	e8 f5 29 00 00       	call   f01033ff <cprintf>
f0100a0a:	83 c6 04             	add    $0x4,%esi
		for (int i = 0; i < 5; ++i)	 // 练习要求打印5个参数
f0100a0d:	83 c4 10             	add    $0x10,%esp
f0100a10:	3b 75 c4             	cmp    -0x3c(%ebp),%esi
f0100a13:	75 ea                	jne    f01009ff <mon_backtrace+0x51>
f0100a15:	8b 7d bc             	mov    -0x44(%ebp),%edi
		cprintf("\n");
f0100a18:	83 ec 0c             	sub    $0xc,%esp
f0100a1b:	8d 83 d1 1f ed ff    	lea    -0x12e02f(%ebx),%eax
f0100a21:	50                   	push   %eax
f0100a22:	e8 d8 29 00 00       	call   f01033ff <cprintf>

		// 显示每个%eip对应的函数名、源文件名和行号
		struct Eipdebuginfo info;
		if (!debuginfo_eip(eip, &info)) // 读取debug信息，找到信息，则debuginfo_eip返回0
f0100a27:	83 c4 08             	add    $0x8,%esp
f0100a2a:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100a2d:	50                   	push   %eax
f0100a2e:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0100a31:	56                   	push   %esi
f0100a32:	e8 e6 36 00 00       	call   f010411d <debuginfo_eip>
f0100a37:	83 c4 10             	add    $0x10,%esp
f0100a3a:	85 c0                	test   %eax,%eax
f0100a3c:	75 31                	jne    f0100a6f <mon_backtrace+0xc1>
			cprintf("%s: %d: %.*s+%d\n",
f0100a3e:	83 ec 08             	sub    $0x8,%esp
f0100a41:	89 f0                	mov    %esi,%eax
f0100a43:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100a46:	50                   	push   %eax
f0100a47:	ff 75 d8             	pushl  -0x28(%ebp)
f0100a4a:	ff 75 dc             	pushl  -0x24(%ebp)
f0100a4d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100a50:	ff 75 d0             	pushl  -0x30(%ebp)
f0100a53:	8d 83 7c 22 ed ff    	lea    -0x12dd84(%ebx),%eax
f0100a59:	50                   	push   %eax
f0100a5a:	e8 a0 29 00 00       	call   f01033ff <cprintf>
					info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, eip - info.eip_fn_addr);
		else // 找不到信息，即到达stack的顶部
			break;

		// 更新指针
		ebp = (int *)*ebp; // *ebp得到压进堆栈的上一个函数的%ebp
f0100a5f:	8b 3f                	mov    (%edi),%edi
		eip = ebp[1];
f0100a61:	8b 47 04             	mov    0x4(%edi),%eax
f0100a64:	89 45 c0             	mov    %eax,-0x40(%ebp)
	{
f0100a67:	83 c4 20             	add    $0x20,%esp
f0100a6a:	e9 6f ff ff ff       	jmp    f01009de <mon_backtrace+0x30>
	}
	return 0;
}
f0100a6f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a74:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a77:	5b                   	pop    %ebx
f0100a78:	5e                   	pop    %esi
f0100a79:	5f                   	pop    %edi
f0100a7a:	5d                   	pop    %ebp
f0100a7b:	c3                   	ret    

f0100a7c <monitor>:
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void monitor(struct Trapframe *tf)
{
f0100a7c:	55                   	push   %ebp
f0100a7d:	89 e5                	mov    %esp,%ebp
f0100a7f:	57                   	push   %edi
f0100a80:	56                   	push   %esi
f0100a81:	53                   	push   %ebx
f0100a82:	83 ec 68             	sub    $0x68,%esp
f0100a85:	e8 27 f8 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0100a8a:	81 c3 52 31 13 00    	add    $0x133152,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100a90:	8d 83 d8 23 ed ff    	lea    -0x12dc28(%ebx),%eax
f0100a96:	50                   	push   %eax
f0100a97:	e8 63 29 00 00       	call   f01033ff <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100a9c:	8d 83 fc 23 ed ff    	lea    -0x12dc04(%ebx),%eax
f0100aa2:	89 04 24             	mov    %eax,(%esp)
f0100aa5:	e8 55 29 00 00       	call   f01033ff <cprintf>

	if (tf != NULL)
f0100aaa:	83 c4 10             	add    $0x10,%esp
f0100aad:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100ab1:	74 0e                	je     f0100ac1 <monitor+0x45>
		print_trapframe(tf);
f0100ab3:	83 ec 0c             	sub    $0xc,%esp
f0100ab6:	ff 75 08             	pushl  0x8(%ebp)
f0100ab9:	e8 19 2e 00 00       	call   f01038d7 <print_trapframe>
f0100abe:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100ac1:	8d bb 91 22 ed ff    	lea    -0x12dd6f(%ebx),%edi
f0100ac7:	eb 4a                	jmp    f0100b13 <monitor+0x97>
f0100ac9:	83 ec 08             	sub    $0x8,%esp
f0100acc:	0f be c0             	movsbl %al,%eax
f0100acf:	50                   	push   %eax
f0100ad0:	57                   	push   %edi
f0100ad1:	e8 c9 41 00 00       	call   f0104c9f <strchr>
f0100ad6:	83 c4 10             	add    $0x10,%esp
f0100ad9:	85 c0                	test   %eax,%eax
f0100adb:	74 08                	je     f0100ae5 <monitor+0x69>
			*buf++ = 0;
f0100add:	c6 06 00             	movb   $0x0,(%esi)
f0100ae0:	8d 76 01             	lea    0x1(%esi),%esi
f0100ae3:	eb 76                	jmp    f0100b5b <monitor+0xdf>
		if (*buf == 0)
f0100ae5:	80 3e 00             	cmpb   $0x0,(%esi)
f0100ae8:	74 7c                	je     f0100b66 <monitor+0xea>
		if (argc == MAXARGS - 1)
f0100aea:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f0100aee:	74 0f                	je     f0100aff <monitor+0x83>
		argv[argc++] = buf;
f0100af0:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100af3:	8d 48 01             	lea    0x1(%eax),%ecx
f0100af6:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0100af9:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f0100afd:	eb 41                	jmp    f0100b40 <monitor+0xc4>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100aff:	83 ec 08             	sub    $0x8,%esp
f0100b02:	6a 10                	push   $0x10
f0100b04:	8d 83 96 22 ed ff    	lea    -0x12dd6a(%ebx),%eax
f0100b0a:	50                   	push   %eax
f0100b0b:	e8 ef 28 00 00       	call   f01033ff <cprintf>
f0100b10:	83 c4 10             	add    $0x10,%esp
	while (1)
	{
		buf = readline("K> ");
f0100b13:	8d 83 8d 22 ed ff    	lea    -0x12dd73(%ebx),%eax
f0100b19:	89 c6                	mov    %eax,%esi
f0100b1b:	83 ec 0c             	sub    $0xc,%esp
f0100b1e:	56                   	push   %esi
f0100b1f:	e8 43 3f 00 00       	call   f0104a67 <readline>
		if (buf != NULL)
f0100b24:	83 c4 10             	add    $0x10,%esp
f0100b27:	85 c0                	test   %eax,%eax
f0100b29:	74 f0                	je     f0100b1b <monitor+0x9f>
f0100b2b:	89 c6                	mov    %eax,%esi
	argv[argc] = 0;
f0100b2d:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100b34:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100b3b:	eb 1e                	jmp    f0100b5b <monitor+0xdf>
			buf++;
f0100b3d:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100b40:	0f b6 06             	movzbl (%esi),%eax
f0100b43:	84 c0                	test   %al,%al
f0100b45:	74 14                	je     f0100b5b <monitor+0xdf>
f0100b47:	83 ec 08             	sub    $0x8,%esp
f0100b4a:	0f be c0             	movsbl %al,%eax
f0100b4d:	50                   	push   %eax
f0100b4e:	57                   	push   %edi
f0100b4f:	e8 4b 41 00 00       	call   f0104c9f <strchr>
f0100b54:	83 c4 10             	add    $0x10,%esp
f0100b57:	85 c0                	test   %eax,%eax
f0100b59:	74 e2                	je     f0100b3d <monitor+0xc1>
		while (*buf && strchr(WHITESPACE, *buf))
f0100b5b:	0f b6 06             	movzbl (%esi),%eax
f0100b5e:	84 c0                	test   %al,%al
f0100b60:	0f 85 63 ff ff ff    	jne    f0100ac9 <monitor+0x4d>
	argv[argc] = 0;
f0100b66:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100b69:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100b70:	00 
	if (argc == 0)
f0100b71:	85 c0                	test   %eax,%eax
f0100b73:	74 9e                	je     f0100b13 <monitor+0x97>
f0100b75:	8d b3 a4 14 00 00    	lea    0x14a4(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f0100b7b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b80:	89 7d a0             	mov    %edi,-0x60(%ebp)
f0100b83:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100b85:	83 ec 08             	sub    $0x8,%esp
f0100b88:	ff 36                	pushl  (%esi)
f0100b8a:	ff 75 a8             	pushl  -0x58(%ebp)
f0100b8d:	e8 af 40 00 00       	call   f0104c41 <strcmp>
f0100b92:	83 c4 10             	add    $0x10,%esp
f0100b95:	85 c0                	test   %eax,%eax
f0100b97:	74 28                	je     f0100bc1 <monitor+0x145>
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f0100b99:	83 c7 01             	add    $0x1,%edi
f0100b9c:	83 c6 0c             	add    $0xc,%esi
f0100b9f:	83 ff 03             	cmp    $0x3,%edi
f0100ba2:	75 e1                	jne    f0100b85 <monitor+0x109>
f0100ba4:	8b 7d a0             	mov    -0x60(%ebp),%edi
	cprintf("Unknown command '%s'\n", argv[0]);
f0100ba7:	83 ec 08             	sub    $0x8,%esp
f0100baa:	ff 75 a8             	pushl  -0x58(%ebp)
f0100bad:	8d 83 b3 22 ed ff    	lea    -0x12dd4d(%ebx),%eax
f0100bb3:	50                   	push   %eax
f0100bb4:	e8 46 28 00 00       	call   f01033ff <cprintf>
f0100bb9:	83 c4 10             	add    $0x10,%esp
f0100bbc:	e9 52 ff ff ff       	jmp    f0100b13 <monitor+0x97>
f0100bc1:	89 f8                	mov    %edi,%eax
f0100bc3:	8b 7d a0             	mov    -0x60(%ebp),%edi
			return commands[i].func(argc, argv, tf);
f0100bc6:	83 ec 04             	sub    $0x4,%esp
f0100bc9:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100bcc:	ff 75 08             	pushl  0x8(%ebp)
f0100bcf:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100bd2:	52                   	push   %edx
f0100bd3:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100bd6:	ff 94 83 ac 14 00 00 	call   *0x14ac(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100bdd:	83 c4 10             	add    $0x10,%esp
f0100be0:	85 c0                	test   %eax,%eax
f0100be2:	0f 89 2b ff ff ff    	jns    f0100b13 <monitor+0x97>
				break;
	}
}
f0100be8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100beb:	5b                   	pop    %ebx
f0100bec:	5e                   	pop    %esi
f0100bed:	5f                   	pop    %edi
f0100bee:	5d                   	pop    %ebp
f0100bef:	c3                   	ret    

f0100bf0 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100bf0:	55                   	push   %ebp
f0100bf1:	89 e5                	mov    %esp,%ebp
f0100bf3:	57                   	push   %edi
f0100bf4:	56                   	push   %esi
f0100bf5:	53                   	push   %ebx
f0100bf6:	83 ec 18             	sub    $0x18,%esp
f0100bf9:	e8 b3 f6 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0100bfe:	81 c3 de 2f 13 00    	add    $0x132fde,%ebx
f0100c04:	89 c7                	mov    %eax,%edi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100c06:	50                   	push   %eax
f0100c07:	e8 22 26 00 00       	call   f010322e <mc146818_read>
f0100c0c:	89 c6                	mov    %eax,%esi
f0100c0e:	83 c7 01             	add    $0x1,%edi
f0100c11:	89 3c 24             	mov    %edi,(%esp)
f0100c14:	e8 15 26 00 00       	call   f010322e <mc146818_read>
f0100c19:	c1 e0 08             	shl    $0x8,%eax
f0100c1c:	09 f0                	or     %esi,%eax
}
f0100c1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c21:	5b                   	pop    %ebx
f0100c22:	5e                   	pop    %esi
f0100c23:	5f                   	pop    %edi
f0100c24:	5d                   	pop    %ebp
f0100c25:	c3                   	ret    

f0100c26 <boot_alloc>:
// 仅在JOS设置其虚拟内存系统时使用的简单的物理内存分配器，之后使用page_alloc()分配
// 分配一个足以容纳n字节的内存区间：用一个地址nextfree来确定可以使用的内存的顶部，并且返回可以使用的内存的底部地址result
// 可使用内存区间为[result, nextfree], 且区间长度是4096的倍数
static void *
boot_alloc(uint32_t n)
{
f0100c26:	55                   	push   %ebp
f0100c27:	89 e5                	mov    %esp,%ebp
f0100c29:	53                   	push   %ebx
f0100c2a:	83 ec 04             	sub    $0x4,%esp
f0100c2d:	e8 7f f6 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0100c32:	81 c3 aa 2f 13 00    	add    $0x132faa,%ebx
f0100c38:	89 c2                	mov    %eax,%edx
	static char *nextfree; // virtual address of next byte of free memory，static意味着nextfree不会随着函数返回被重置，是全局变量
	char *result;

	if (!nextfree) // nextfree初始化，只有第一次运行会执行
f0100c3a:	83 bb 5c 26 00 00 00 	cmpl   $0x0,0x265c(%ebx)
f0100c41:	74 2b                	je     f0100c6e <boot_alloc+0x48>
		 * 假设end是4097，ROUNDUP(end, PGSIZE)得到end=4096*2，这样才能容纳4097
		 */
	}

	// LAB 2: Your code here.
	if (n == 0) // 不分配内存，直接返回
f0100c43:	85 d2                	test   %edx,%edx
f0100c45:	74 3f                	je     f0100c86 <boot_alloc+0x60>
	{
		return nextfree;
	}

	// n是无符号数，不考虑<0情形
	result = nextfree;				// 将更新前的nextfree赋给result
f0100c47:	8b 83 5c 26 00 00    	mov    0x265c(%ebx),%eax
	nextfree += ROUNDUP(n, PGSIZE); // +=:在原来的基础上再分配
f0100c4d:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100c53:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100c59:	01 c2                	add    %eax,%edx
f0100c5b:	89 93 5c 26 00 00    	mov    %edx,0x265c(%ebx)

	// 如果内存不足，boot_alloc应该会死机
	if (nextfree > (char *)0xf0400000) // >4MB
f0100c61:	81 fa 00 00 40 f0    	cmp    $0xf0400000,%edx
f0100c67:	77 25                	ja     f0100c8e <boot_alloc+0x68>
		panic("out of memory(4MB) : boot_alloc() in pmap.c \n"); // 调用预先定义的assert
		nextfree = result;										 // 分配失败，回调nextfree
		return NULL;
	}
	return result;
}
f0100c69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100c6c:	c9                   	leave  
f0100c6d:	c3                   	ret    
		nextfree = ROUNDUP((char *)end, PGSIZE); // 内核使用的第一块内存必须远离内核代码结尾
f0100c6e:	c7 c0 08 80 27 f0    	mov    $0xf0278008,%eax
f0100c74:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100c79:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c7e:	89 83 5c 26 00 00    	mov    %eax,0x265c(%ebx)
f0100c84:	eb bd                	jmp    f0100c43 <boot_alloc+0x1d>
		return nextfree;
f0100c86:	8b 83 5c 26 00 00    	mov    0x265c(%ebx),%eax
f0100c8c:	eb db                	jmp    f0100c69 <boot_alloc+0x43>
		panic("out of memory(4MB) : boot_alloc() in pmap.c \n"); // 调用预先定义的assert
f0100c8e:	83 ec 04             	sub    $0x4,%esp
f0100c91:	8d 83 24 24 ed ff    	lea    -0x12dbdc(%ebx),%eax
f0100c97:	50                   	push   %eax
f0100c98:	6a 6a                	push   $0x6a
f0100c9a:	8d 83 e1 2a ed ff    	lea    -0x12d51f(%ebx),%eax
f0100ca0:	50                   	push   %eax
f0100ca1:	e8 9a f3 ff ff       	call   f0100040 <_panic>

f0100ca6 <page2kva>:
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100ca6:	55                   	push   %ebp
f0100ca7:	89 e5                	mov    %esp,%ebp
f0100ca9:	53                   	push   %ebx
f0100caa:	83 ec 04             	sub    $0x4,%esp
f0100cad:	e8 d0 1c 00 00       	call   f0102982 <__x86.get_pc_thunk.dx>
f0100cb2:	81 c2 2a 2f 13 00    	add    $0x132f2a,%edx
	return (pp - pages) << PGSHIFT;
f0100cb8:	c7 c1 10 6f 23 f0    	mov    $0xf0236f10,%ecx
f0100cbe:	2b 01                	sub    (%ecx),%eax
f0100cc0:	c1 f8 03             	sar    $0x3,%eax
f0100cc3:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100cc6:	89 c1                	mov    %eax,%ecx
f0100cc8:	c1 e9 0c             	shr    $0xc,%ecx
f0100ccb:	c7 c3 08 6f 23 f0    	mov    $0xf0236f08,%ebx
f0100cd1:	39 0b                	cmp    %ecx,(%ebx)
f0100cd3:	76 0a                	jbe    f0100cdf <page2kva+0x39>
	return (void *)(pa + KERNBASE);
f0100cd5:	2d 00 00 00 10       	sub    $0x10000000,%eax
	return KADDR(page2pa(pp));
}
f0100cda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100cdd:	c9                   	leave  
f0100cde:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cdf:	50                   	push   %eax
f0100ce0:	8d 82 28 1f ed ff    	lea    -0x12e0d8(%edx),%eax
f0100ce6:	50                   	push   %eax
f0100ce7:	6a 58                	push   $0x58
f0100ce9:	8d 82 ed 2a ed ff    	lea    -0x12d513(%edx),%eax
f0100cef:	50                   	push   %eax
f0100cf0:	89 d3                	mov    %edx,%ebx
f0100cf2:	e8 49 f3 ff ff       	call   f0100040 <_panic>

f0100cf7 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100cf7:	55                   	push   %ebp
f0100cf8:	89 e5                	mov    %esp,%ebp
f0100cfa:	56                   	push   %esi
f0100cfb:	53                   	push   %ebx
f0100cfc:	e8 b0 f5 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0100d01:	81 c3 db 2e 13 00    	add    $0x132edb,%ebx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100d07:	89 d1                	mov    %edx,%ecx
f0100d09:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100d0c:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100d0f:	a8 01                	test   $0x1,%al
f0100d11:	74 55                	je     f0100d68 <check_va2pa+0x71>
		return ~0;
	p = (pte_t *)KADDR(PTE_ADDR(*pgdir));
f0100d13:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100d18:	89 c6                	mov    %eax,%esi
f0100d1a:	c1 ee 0c             	shr    $0xc,%esi
f0100d1d:	c7 c1 08 6f 23 f0    	mov    $0xf0236f08,%ecx
f0100d23:	3b 31                	cmp    (%ecx),%esi
f0100d25:	72 19                	jb     f0100d40 <check_va2pa+0x49>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d27:	50                   	push   %eax
f0100d28:	8d 83 28 1f ed ff    	lea    -0x12e0d8(%ebx),%eax
f0100d2e:	50                   	push   %eax
f0100d2f:	68 0c 03 00 00       	push   $0x30c
f0100d34:	8d 83 e1 2a ed ff    	lea    -0x12d51f(%ebx),%eax
f0100d3a:	50                   	push   %eax
f0100d3b:	e8 00 f3 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100d40:	c1 ea 0c             	shr    $0xc,%edx
f0100d43:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100d49:	8b 94 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%edx
		return ~0;
f0100d50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	if (!(p[PTX(va)] & PTE_P))
f0100d55:	f6 c2 01             	test   $0x1,%dl
f0100d58:	74 07                	je     f0100d61 <check_va2pa+0x6a>
	return PTE_ADDR(p[PTX(va)]);
f0100d5a:	89 d0                	mov    %edx,%eax
f0100d5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
}
f0100d61:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100d64:	5b                   	pop    %ebx
f0100d65:	5e                   	pop    %esi
f0100d66:	5d                   	pop    %ebp
f0100d67:	c3                   	ret    
		return ~0;
f0100d68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d6d:	eb f2                	jmp    f0100d61 <check_va2pa+0x6a>

f0100d6f <page_init>:
{
f0100d6f:	55                   	push   %ebp
f0100d70:	89 e5                	mov    %esp,%ebp
f0100d72:	57                   	push   %edi
f0100d73:	56                   	push   %esi
f0100d74:	53                   	push   %ebx
f0100d75:	83 ec 1c             	sub    $0x1c,%esp
f0100d78:	e8 09 1c 00 00       	call   f0102986 <__x86.get_pc_thunk.si>
f0100d7d:	81 c6 5f 2e 13 00    	add    $0x132e5f,%esi
f0100d83:	89 75 e4             	mov    %esi,-0x1c(%ebp)
	page_free_list = NULL; // page_free_list是static的，不会被初始化，必须给一个初始值
f0100d86:	c7 86 64 26 00 00 00 	movl   $0x0,0x2664(%esi)
f0100d8d:	00 00 00 
	for (int i = 1; i < npages_basemem; i++) // 将内存中的pages数组初始化为链表，头指针是page_free_list
f0100d90:	8b be 68 26 00 00    	mov    0x2668(%esi),%edi
f0100d96:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d9b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100da0:	b8 01 00 00 00       	mov    $0x1,%eax
		pages[i].pp_ref = 0;
f0100da5:	c7 c6 10 6f 23 f0    	mov    $0xf0236f10,%esi
	for (int i = 1; i < npages_basemem; i++) // 将内存中的pages数组初始化为链表，头指针是page_free_list
f0100dab:	eb 1f                	jmp    f0100dcc <page_init+0x5d>
f0100dad:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100db4:	89 d1                	mov    %edx,%ecx
f0100db6:	03 0e                	add    (%esi),%ecx
f0100db8:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100dbe:	89 19                	mov    %ebx,(%ecx)
	for (int i = 1; i < npages_basemem; i++) // 将内存中的pages数组初始化为链表，头指针是page_free_list
f0100dc0:	83 c0 01             	add    $0x1,%eax
		page_free_list = &pages[i]; // pages中包含了整个内存中的页，page_free_list指向其中空闲的页组成的链表的头部
f0100dc3:	89 d3                	mov    %edx,%ebx
f0100dc5:	03 1e                	add    (%esi),%ebx
f0100dc7:	ba 01 00 00 00       	mov    $0x1,%edx
	for (int i = 1; i < npages_basemem; i++) // 将内存中的pages数组初始化为链表，头指针是page_free_list
f0100dcc:	39 c7                	cmp    %eax,%edi
f0100dce:	77 dd                	ja     f0100dad <page_init+0x3e>
f0100dd0:	84 d2                	test   %dl,%dl
f0100dd2:	75 35                	jne    f0100e09 <page_init+0x9a>
	for (int i = PGNUM(PADDR(boot_alloc(0))); i < npages; i++) // PADDR()将虚拟地址转化为物理地址，boot_alloc(0)得到nextfree的位置(即pages end),PGNUM()求出需要几页才能到达该地址
f0100dd4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dd9:	e8 48 fe ff ff       	call   f0100c26 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100dde:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100de3:	76 2f                	jbe    f0100e14 <page_init+0xa5>
	return (physaddr_t)kva - KERNBASE;
f0100de5:	05 00 00 00 10       	add    $0x10000000,%eax
f0100dea:	c1 e8 0c             	shr    $0xc,%eax
f0100ded:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100df0:	8b 9e 64 26 00 00    	mov    0x2664(%esi),%ebx
f0100df6:	ba 00 00 00 00       	mov    $0x0,%edx
f0100dfb:	c7 c7 08 6f 23 f0    	mov    $0xf0236f08,%edi
		pages[i].pp_ref = 0;
f0100e01:	c7 c6 10 6f 23 f0    	mov    $0xf0236f10,%esi
	for (int i = PGNUM(PADDR(boot_alloc(0))); i < npages; i++) // PADDR()将虚拟地址转化为物理地址，boot_alloc(0)得到nextfree的位置(即pages end),PGNUM()求出需要几页才能到达该地址
f0100e07:	eb 46                	jmp    f0100e4f <page_init+0xe0>
f0100e09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e0c:	89 98 64 26 00 00    	mov    %ebx,0x2664(%eax)
f0100e12:	eb c0                	jmp    f0100dd4 <page_init+0x65>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e14:	50                   	push   %eax
f0100e15:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100e18:	8d 83 4c 1f ed ff    	lea    -0x12e0b4(%ebx),%eax
f0100e1e:	50                   	push   %eax
f0100e1f:	68 34 01 00 00       	push   $0x134
f0100e24:	8d 83 e1 2a ed ff    	lea    -0x12d51f(%ebx),%eax
f0100e2a:	50                   	push   %eax
f0100e2b:	e8 10 f2 ff ff       	call   f0100040 <_panic>
f0100e30:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100e37:	89 d1                	mov    %edx,%ecx
f0100e39:	03 0e                	add    (%esi),%ecx
f0100e3b:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100e41:	89 19                	mov    %ebx,(%ecx)
	for (int i = PGNUM(PADDR(boot_alloc(0))); i < npages; i++) // PADDR()将虚拟地址转化为物理地址，boot_alloc(0)得到nextfree的位置(即pages end),PGNUM()求出需要几页才能到达该地址
f0100e43:	83 c0 01             	add    $0x1,%eax
		page_free_list = &pages[i];
f0100e46:	89 d3                	mov    %edx,%ebx
f0100e48:	03 1e                	add    (%esi),%ebx
f0100e4a:	ba 01 00 00 00       	mov    $0x1,%edx
	for (int i = PGNUM(PADDR(boot_alloc(0))); i < npages; i++) // PADDR()将虚拟地址转化为物理地址，boot_alloc(0)得到nextfree的位置(即pages end),PGNUM()求出需要几页才能到达该地址
f0100e4f:	3b 07                	cmp    (%edi),%eax
f0100e51:	72 dd                	jb     f0100e30 <page_init+0xc1>
f0100e53:	84 d2                	test   %dl,%dl
f0100e55:	75 08                	jne    f0100e5f <page_init+0xf0>
}
f0100e57:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e5a:	5b                   	pop    %ebx
f0100e5b:	5e                   	pop    %esi
f0100e5c:	5f                   	pop    %edi
f0100e5d:	5d                   	pop    %ebp
f0100e5e:	c3                   	ret    
f0100e5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e62:	89 98 64 26 00 00    	mov    %ebx,0x2664(%eax)
f0100e68:	eb ed                	jmp    f0100e57 <page_init+0xe8>

f0100e6a <page_alloc>:
{
f0100e6a:	55                   	push   %ebp
f0100e6b:	89 e5                	mov    %esp,%ebp
f0100e6d:	56                   	push   %esi
f0100e6e:	53                   	push   %ebx
f0100e6f:	e8 3d f4 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0100e74:	81 c3 68 2d 13 00    	add    $0x132d68,%ebx
	if (page_free_list) // page_free_list指向空闲页组成的链表的头部
f0100e7a:	8b b3 64 26 00 00    	mov    0x2664(%ebx),%esi
f0100e80:	85 f6                	test   %esi,%esi
f0100e82:	74 1a                	je     f0100e9e <page_alloc+0x34>
		page_free_list = page_free_list->pp_link; // 链表next行进
f0100e84:	8b 06                	mov    (%esi),%eax
f0100e86:	89 83 64 26 00 00    	mov    %eax,0x2664(%ebx)
		if (alloc_flags & ALLOC_ZERO)
f0100e8c:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e90:	75 15                	jne    f0100ea7 <page_alloc+0x3d>
		result->pp_ref = 0;
f0100e92:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
		result->pp_link = NULL; // 确保page_free就可以检查错误
f0100e98:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
}
f0100e9e:	89 f0                	mov    %esi,%eax
f0100ea0:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ea3:	5b                   	pop    %ebx
f0100ea4:	5e                   	pop    %esi
f0100ea5:	5d                   	pop    %ebp
f0100ea6:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0100ea7:	c7 c0 10 6f 23 f0    	mov    $0xf0236f10,%eax
f0100ead:	89 f2                	mov    %esi,%edx
f0100eaf:	2b 10                	sub    (%eax),%edx
f0100eb1:	89 d0                	mov    %edx,%eax
f0100eb3:	c1 f8 03             	sar    $0x3,%eax
f0100eb6:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100eb9:	89 c1                	mov    %eax,%ecx
f0100ebb:	c1 e9 0c             	shr    $0xc,%ecx
f0100ebe:	c7 c2 08 6f 23 f0    	mov    $0xf0236f08,%edx
f0100ec4:	3b 0a                	cmp    (%edx),%ecx
f0100ec6:	73 1a                	jae    f0100ee2 <page_alloc+0x78>
			memset(page2kva(result), 0, PGSIZE); // page2kva(p)：求得页p的地址，方法就是先求出p的索引i，用i*4096得到地址
f0100ec8:	83 ec 04             	sub    $0x4,%esp
f0100ecb:	68 00 10 00 00       	push   $0x1000
f0100ed0:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100ed2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ed7:	50                   	push   %eax
f0100ed8:	e8 ff 3d 00 00       	call   f0104cdc <memset>
f0100edd:	83 c4 10             	add    $0x10,%esp
f0100ee0:	eb b0                	jmp    f0100e92 <page_alloc+0x28>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ee2:	50                   	push   %eax
f0100ee3:	8d 83 28 1f ed ff    	lea    -0x12e0d8(%ebx),%eax
f0100ee9:	50                   	push   %eax
f0100eea:	6a 58                	push   $0x58
f0100eec:	8d 83 ed 2a ed ff    	lea    -0x12d513(%ebx),%eax
f0100ef2:	50                   	push   %eax
f0100ef3:	e8 48 f1 ff ff       	call   f0100040 <_panic>

f0100ef8 <page_free>:
{
f0100ef8:	55                   	push   %ebp
f0100ef9:	89 e5                	mov    %esp,%ebp
f0100efb:	53                   	push   %ebx
f0100efc:	83 ec 04             	sub    $0x4,%esp
f0100eff:	e8 ad f3 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0100f04:	81 c3 d8 2c 13 00    	add    $0x132cd8,%ebx
f0100f0a:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref != 0 || pp->pp_link != NULL) // 还有人在使用这个page时，调用了释放函数
f0100f0d:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f12:	75 18                	jne    f0100f2c <page_free+0x34>
f0100f14:	83 38 00             	cmpl   $0x0,(%eax)
f0100f17:	75 13                	jne    f0100f2c <page_free+0x34>
	pp->pp_link = page_free_list;
f0100f19:	8b 8b 64 26 00 00    	mov    0x2664(%ebx),%ecx
f0100f1f:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp;
f0100f21:	89 83 64 26 00 00    	mov    %eax,0x2664(%ebx)
}
f0100f27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f2a:	c9                   	leave  
f0100f2b:	c3                   	ret    
		panic("can't free this page, this page is in used: page_free() in pmap.c \n");
f0100f2c:	83 ec 04             	sub    $0x4,%esp
f0100f2f:	8d 83 54 24 ed ff    	lea    -0x12dbac(%ebx),%eax
f0100f35:	50                   	push   %eax
f0100f36:	68 5b 01 00 00       	push   $0x15b
f0100f3b:	8d 83 e1 2a ed ff    	lea    -0x12d51f(%ebx),%eax
f0100f41:	50                   	push   %eax
f0100f42:	e8 f9 f0 ff ff       	call   f0100040 <_panic>

f0100f47 <page_decref>:
{
f0100f47:	55                   	push   %ebp
f0100f48:	89 e5                	mov    %esp,%ebp
f0100f4a:	83 ec 08             	sub    $0x8,%esp
f0100f4d:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100f50:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100f54:	83 e8 01             	sub    $0x1,%eax
f0100f57:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100f5b:	66 85 c0             	test   %ax,%ax
f0100f5e:	74 02                	je     f0100f62 <page_decref+0x1b>
}
f0100f60:	c9                   	leave  
f0100f61:	c3                   	ret    
		page_free(pp);
f0100f62:	83 ec 0c             	sub    $0xc,%esp
f0100f65:	52                   	push   %edx
f0100f66:	e8 8d ff ff ff       	call   f0100ef8 <page_free>
f0100f6b:	83 c4 10             	add    $0x10,%esp
}
f0100f6e:	eb f0                	jmp    f0100f60 <page_decref+0x19>

f0100f70 <pgdir_walk>:
{
f0100f70:	55                   	push   %ebp
f0100f71:	89 e5                	mov    %esp,%ebp
f0100f73:	57                   	push   %edi
f0100f74:	56                   	push   %esi
f0100f75:	53                   	push   %ebx
f0100f76:	83 ec 0c             	sub    $0xc,%esp
f0100f79:	e8 33 f3 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0100f7e:	81 c3 5e 2c 13 00    	add    $0x132c5e,%ebx
f0100f84:	8b 75 0c             	mov    0xc(%ebp),%esi
	pde_t *pde = &pgdir[PDX(va)]; // 先由PDX(va)得到该地址对应的目录索引，并在目录中索引得到对应条目(一个32位地址),解引用pde即可得到对应条目
f0100f87:	89 f7                	mov    %esi,%edi
f0100f89:	c1 ef 16             	shr    $0x16,%edi
f0100f8c:	c1 e7 02             	shl    $0x2,%edi
f0100f8f:	03 7d 08             	add    0x8(%ebp),%edi
	if (*pde && PTE_P) // 当“va”的PTE所在的页存在，该页对应的条目在目录中的值就!=0
f0100f92:	8b 07                	mov    (%edi),%eax
f0100f94:	85 c0                	test   %eax,%eax
f0100f96:	74 45                	je     f0100fdd <pgdir_walk+0x6d>
		pte_tab = (pte_t *)KADDR(PTE_ADDR(*pde)); // PTE_ADDR()获得该条目对应的页的物理地址，KADDR()把物理地址转为虚拟地址
f0100f98:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100f9d:	89 c2                	mov    %eax,%edx
f0100f9f:	c1 ea 0c             	shr    $0xc,%edx
f0100fa2:	c7 c1 08 6f 23 f0    	mov    $0xf0236f08,%ecx
f0100fa8:	39 11                	cmp    %edx,(%ecx)
f0100faa:	76 18                	jbe    f0100fc4 <pgdir_walk+0x54>
		result = &pte_tab[PTX(va)];				  // 页里存的就是PTE表，用PTX(va)得到页索引，索引到对应的pte的地址
f0100fac:	c1 ee 0a             	shr    $0xa,%esi
f0100faf:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0100fb5:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
}
f0100fbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fbf:	5b                   	pop    %ebx
f0100fc0:	5e                   	pop    %esi
f0100fc1:	5f                   	pop    %edi
f0100fc2:	5d                   	pop    %ebp
f0100fc3:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fc4:	50                   	push   %eax
f0100fc5:	8d 83 28 1f ed ff    	lea    -0x12e0d8(%ebx),%eax
f0100fcb:	50                   	push   %eax
f0100fcc:	68 76 01 00 00       	push   $0x176
f0100fd1:	8d 83 e1 2a ed ff    	lea    -0x12d51f(%ebx),%eax
f0100fd7:	50                   	push   %eax
f0100fd8:	e8 63 f0 ff ff       	call   f0100040 <_panic>
		if (!create)
f0100fdd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100fe1:	74 6a                	je     f010104d <pgdir_walk+0xdd>
		struct PageInfo *pp = page_alloc(ALLOC_ZERO); // 分配新的一页来存储PTE表
f0100fe3:	83 ec 0c             	sub    $0xc,%esp
f0100fe6:	6a 01                	push   $0x1
f0100fe8:	e8 7d fe ff ff       	call   f0100e6a <page_alloc>
		if (!pp) // 如果pp == NULL，分配失败
f0100fed:	83 c4 10             	add    $0x10,%esp
f0100ff0:	85 c0                	test   %eax,%eax
f0100ff2:	74 63                	je     f0101057 <pgdir_walk+0xe7>
	return (pp - pages) << PGSHIFT;
f0100ff4:	c7 c1 10 6f 23 f0    	mov    $0xf0236f10,%ecx
f0100ffa:	89 c2                	mov    %eax,%edx
f0100ffc:	2b 11                	sub    (%ecx),%edx
f0100ffe:	c1 fa 03             	sar    $0x3,%edx
f0101001:	c1 e2 0c             	shl    $0xc,%edx
		*pde = page2pa(pp) | PTE_P | PTE_W | PTE_U; // 更新目录的条目，以指向新分配的页
f0101004:	83 ca 07             	or     $0x7,%edx
f0101007:	89 17                	mov    %edx,(%edi)
		pp->pp_ref++;
f0101009:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f010100e:	2b 01                	sub    (%ecx),%eax
f0101010:	c1 f8 03             	sar    $0x3,%eax
f0101013:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101016:	89 c1                	mov    %eax,%ecx
f0101018:	c1 e9 0c             	shr    $0xc,%ecx
f010101b:	c7 c2 08 6f 23 f0    	mov    $0xf0236f08,%edx
f0101021:	3b 0a                	cmp    (%edx),%ecx
f0101023:	73 12                	jae    f0101037 <pgdir_walk+0xc7>
		result = &pte_tab[PTX(va)];
f0101025:	c1 ee 0a             	shr    $0xa,%esi
f0101028:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f010102e:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0101035:	eb 85                	jmp    f0100fbc <pgdir_walk+0x4c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101037:	50                   	push   %eax
f0101038:	8d 83 28 1f ed ff    	lea    -0x12e0d8(%ebx),%eax
f010103e:	50                   	push   %eax
f010103f:	6a 58                	push   $0x58
f0101041:	8d 83 ed 2a ed ff    	lea    -0x12d513(%ebx),%eax
f0101047:	50                   	push   %eax
f0101048:	e8 f3 ef ff ff       	call   f0100040 <_panic>
			return NULL;
f010104d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101052:	e9 65 ff ff ff       	jmp    f0100fbc <pgdir_walk+0x4c>
			return NULL;
f0101057:	b8 00 00 00 00       	mov    $0x0,%eax
f010105c:	e9 5b ff ff ff       	jmp    f0100fbc <pgdir_walk+0x4c>

f0101061 <page_lookup>:
{
f0101061:	55                   	push   %ebp
f0101062:	89 e5                	mov    %esp,%ebp
f0101064:	56                   	push   %esi
f0101065:	53                   	push   %ebx
f0101066:	e8 46 f2 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f010106b:	81 c3 71 2b 13 00    	add    $0x132b71,%ebx
f0101071:	8b 75 10             	mov    0x10(%ebp),%esi
	pte_t *pte = pgdir_walk(pgdir, va, 0); // 得到“va”的PTE的指针
f0101074:	83 ec 04             	sub    $0x4,%esp
f0101077:	6a 00                	push   $0x0
f0101079:	ff 75 0c             	pushl  0xc(%ebp)
f010107c:	ff 75 08             	pushl  0x8(%ebp)
f010107f:	e8 ec fe ff ff       	call   f0100f70 <pgdir_walk>
	if (pte == NULL)					   // 若PTE不存在，则“va”没有映射到对应的物理地址
f0101084:	83 c4 10             	add    $0x10,%esp
f0101087:	85 c0                	test   %eax,%eax
f0101089:	74 3f                	je     f01010ca <page_lookup+0x69>
	if (pte_store)
f010108b:	85 f6                	test   %esi,%esi
f010108d:	74 02                	je     f0101091 <page_lookup+0x30>
		*pte_store = pte;
f010108f:	89 06                	mov    %eax,(%esi)
f0101091:	8b 00                	mov    (%eax),%eax
f0101093:	c1 e8 0c             	shr    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101096:	c7 c2 08 6f 23 f0    	mov    $0xf0236f08,%edx
f010109c:	39 02                	cmp    %eax,(%edx)
f010109e:	76 12                	jbe    f01010b2 <page_lookup+0x51>
	return &pages[PGNUM(pa)];
f01010a0:	c7 c2 10 6f 23 f0    	mov    $0xf0236f10,%edx
f01010a6:	8b 12                	mov    (%edx),%edx
f01010a8:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01010ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010ae:	5b                   	pop    %ebx
f01010af:	5e                   	pop    %esi
f01010b0:	5d                   	pop    %ebp
f01010b1:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01010b2:	83 ec 04             	sub    $0x4,%esp
f01010b5:	8d 83 98 24 ed ff    	lea    -0x12db68(%ebx),%eax
f01010bb:	50                   	push   %eax
f01010bc:	6a 51                	push   $0x51
f01010be:	8d 83 ed 2a ed ff    	lea    -0x12d513(%ebx),%eax
f01010c4:	50                   	push   %eax
f01010c5:	e8 76 ef ff ff       	call   f0100040 <_panic>
		return NULL;
f01010ca:	b8 00 00 00 00       	mov    $0x0,%eax
f01010cf:	eb da                	jmp    f01010ab <page_lookup+0x4a>

f01010d1 <tlb_invalidate>:
{
f01010d1:	55                   	push   %ebp
f01010d2:	89 e5                	mov    %esp,%ebp
f01010d4:	53                   	push   %ebx
f01010d5:	83 ec 04             	sub    $0x4,%esp
f01010d8:	e8 d4 f1 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f01010dd:	81 c3 ff 2a 13 00    	add    $0x132aff,%ebx
	if (!curenv || curenv->env_pgdir == pgdir)
f01010e3:	e8 b3 42 00 00       	call   f010539b <cpunum>
f01010e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01010eb:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f01010f1:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f01010f5:	74 19                	je     f0101110 <tlb_invalidate+0x3f>
f01010f7:	e8 9f 42 00 00       	call   f010539b <cpunum>
f01010fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01010ff:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0101105:	8b 40 08             	mov    0x8(%eax),%eax
f0101108:	8b 55 08             	mov    0x8(%ebp),%edx
f010110b:	39 50 60             	cmp    %edx,0x60(%eax)
f010110e:	75 06                	jne    f0101116 <tlb_invalidate+0x45>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101110:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101113:	0f 01 38             	invlpg (%eax)
}
f0101116:	83 c4 04             	add    $0x4,%esp
f0101119:	5b                   	pop    %ebx
f010111a:	5d                   	pop    %ebp
f010111b:	c3                   	ret    

f010111c <page_remove>:
{
f010111c:	55                   	push   %ebp
f010111d:	89 e5                	mov    %esp,%ebp
f010111f:	56                   	push   %esi
f0101120:	53                   	push   %ebx
f0101121:	83 ec 14             	sub    $0x14,%esp
f0101124:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101127:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store); // 得到“va”对应的页面，和指向对应的pte的指针pte_store
f010112a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010112d:	50                   	push   %eax
f010112e:	56                   	push   %esi
f010112f:	53                   	push   %ebx
f0101130:	e8 2c ff ff ff       	call   f0101061 <page_lookup>
	if (pp)
f0101135:	83 c4 10             	add    $0x10,%esp
f0101138:	85 c0                	test   %eax,%eax
f010113a:	74 1f                	je     f010115b <page_remove+0x3f>
		page_decref(pp);
f010113c:	83 ec 0c             	sub    $0xc,%esp
f010113f:	50                   	push   %eax
f0101140:	e8 02 fe ff ff       	call   f0100f47 <page_decref>
		tlb_invalidate(pgdir, va); // 如果从页表中删除条目，则TLB必须无效
f0101145:	83 c4 08             	add    $0x8,%esp
f0101148:	56                   	push   %esi
f0101149:	53                   	push   %ebx
f010114a:	e8 82 ff ff ff       	call   f01010d1 <tlb_invalidate>
		*pte_store = 0;
f010114f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101152:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0101158:	83 c4 10             	add    $0x10,%esp
}
f010115b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010115e:	5b                   	pop    %ebx
f010115f:	5e                   	pop    %esi
f0101160:	5d                   	pop    %ebp
f0101161:	c3                   	ret    

f0101162 <page_insert>:
{
f0101162:	55                   	push   %ebp
f0101163:	89 e5                	mov    %esp,%ebp
f0101165:	57                   	push   %edi
f0101166:	56                   	push   %esi
f0101167:	53                   	push   %ebx
f0101168:	83 ec 20             	sub    $0x20,%esp
f010116b:	e8 02 f7 ff ff       	call   f0100872 <__x86.get_pc_thunk.ax>
f0101170:	05 6c 2a 13 00       	add    $0x132a6c,%eax
f0101175:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101178:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010117b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010117e:	8b 75 10             	mov    0x10(%ebp),%esi
	pte_t *pte = pgdir_walk(pgdir, va, 1); // 得到pte的指针，create=1,代表有必要会创建新的页
f0101181:	6a 01                	push   $0x1
f0101183:	56                   	push   %esi
f0101184:	53                   	push   %ebx
f0101185:	e8 e6 fd ff ff       	call   f0100f70 <pgdir_walk>
	if (pte == NULL)
f010118a:	83 c4 10             	add    $0x10,%esp
f010118d:	85 c0                	test   %eax,%eax
f010118f:	74 5a                	je     f01011eb <page_insert+0x89>
	pp->pp_ref++;
f0101191:	66 83 47 04 01       	addw   $0x1,0x4(%edi)
	if (*pte & PTE_P)
f0101196:	f6 00 01             	testb  $0x1,(%eax)
f0101199:	75 41                	jne    f01011dc <page_insert+0x7a>
	return (pp - pages) << PGSHIFT;
f010119b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010119e:	c7 c0 10 6f 23 f0    	mov    $0xf0236f10,%eax
f01011a4:	2b 38                	sub    (%eax),%edi
f01011a6:	c1 ff 03             	sar    $0x3,%edi
f01011a9:	c1 e7 0c             	shl    $0xc,%edi
		tlb_invalidate(pgdir, (void *)va + i);					 // 使TLB无效
f01011ac:	83 ec 08             	sub    $0x8,%esp
f01011af:	56                   	push   %esi
f01011b0:	53                   	push   %ebx
f01011b1:	e8 1b ff ff ff       	call   f01010d1 <tlb_invalidate>
		pte_t *pte = pgdir_walk(pgdir, (const void *)va + i, 1); // 得到虚拟地址对应的pte
f01011b6:	83 c4 0c             	add    $0xc,%esp
f01011b9:	6a 01                	push   $0x1
f01011bb:	56                   	push   %esi
f01011bc:	53                   	push   %ebx
f01011bd:	e8 ae fd ff ff       	call   f0100f70 <pgdir_walk>
		*pte = (pa + i) | PTE_P | perm;							 // 物理地址写入PTE,完成映射
f01011c2:	8b 55 14             	mov    0x14(%ebp),%edx
f01011c5:	83 ca 01             	or     $0x1,%edx
f01011c8:	09 d7                	or     %edx,%edi
f01011ca:	89 38                	mov    %edi,(%eax)
f01011cc:	83 c4 10             	add    $0x10,%esp
	return 0;
f01011cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01011d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011d7:	5b                   	pop    %ebx
f01011d8:	5e                   	pop    %esi
f01011d9:	5f                   	pop    %edi
f01011da:	5d                   	pop    %ebp
f01011db:	c3                   	ret    
		page_remove(pgdir, va);
f01011dc:	83 ec 08             	sub    $0x8,%esp
f01011df:	56                   	push   %esi
f01011e0:	53                   	push   %ebx
f01011e1:	e8 36 ff ff ff       	call   f010111c <page_remove>
f01011e6:	83 c4 10             	add    $0x10,%esp
f01011e9:	eb b0                	jmp    f010119b <page_insert+0x39>
		return -E_NO_MEM;
f01011eb:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01011f0:	eb e2                	jmp    f01011d4 <page_insert+0x72>

f01011f2 <mmio_map_region>:
{
f01011f2:	55                   	push   %ebp
f01011f3:	89 e5                	mov    %esp,%ebp
f01011f5:	53                   	push   %ebx
f01011f6:	83 ec 08             	sub    $0x8,%esp
f01011f9:	e8 b3 f0 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f01011fe:	81 c3 de 29 13 00    	add    $0x1329de,%ebx
	panic("mmio_map_region not implemented");
f0101204:	8d 83 b8 24 ed ff    	lea    -0x12db48(%ebx),%eax
f010120a:	50                   	push   %eax
f010120b:	68 f1 01 00 00       	push   $0x1f1
f0101210:	8d 83 e1 2a ed ff    	lea    -0x12d51f(%ebx),%eax
f0101216:	50                   	push   %eax
f0101217:	e8 24 ee ff ff       	call   f0100040 <_panic>

f010121c <mem_init>:
{
f010121c:	55                   	push   %ebp
f010121d:	89 e5                	mov    %esp,%ebp
f010121f:	57                   	push   %edi
f0101220:	56                   	push   %esi
f0101221:	53                   	push   %ebx
f0101222:	83 ec 3c             	sub    $0x3c,%esp
f0101225:	e8 60 17 00 00       	call   f010298a <__x86.get_pc_thunk.di>
f010122a:	81 c7 b2 29 13 00    	add    $0x1329b2,%edi
	basemem = nvram_read(NVRAM_BASELO);
f0101230:	b8 15 00 00 00       	mov    $0x15,%eax
f0101235:	e8 b6 f9 ff ff       	call   f0100bf0 <nvram_read>
f010123a:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010123c:	b8 17 00 00 00       	mov    $0x17,%eax
f0101241:	e8 aa f9 ff ff       	call   f0100bf0 <nvram_read>
f0101246:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101248:	b8 34 00 00 00       	mov    $0x34,%eax
f010124d:	e8 9e f9 ff ff       	call   f0100bf0 <nvram_read>
f0101252:	c1 e0 06             	shl    $0x6,%eax
	if (ext16mem)
f0101255:	85 c0                	test   %eax,%eax
f0101257:	75 0e                	jne    f0101267 <mem_init+0x4b>
		totalmem = basemem;
f0101259:	89 d8                	mov    %ebx,%eax
	else if (extmem)
f010125b:	85 f6                	test   %esi,%esi
f010125d:	74 0d                	je     f010126c <mem_init+0x50>
		totalmem = 1 * 1024 + extmem;
f010125f:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101265:	eb 05                	jmp    f010126c <mem_init+0x50>
		totalmem = 16 * 1024 + ext16mem;
f0101267:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f010126c:	89 c1                	mov    %eax,%ecx
f010126e:	c1 e9 02             	shr    $0x2,%ecx
f0101271:	c7 c2 08 6f 23 f0    	mov    $0xf0236f08,%edx
f0101277:	89 0a                	mov    %ecx,(%edx)
	npages_basemem = basemem / (PGSIZE / 1024);
f0101279:	89 da                	mov    %ebx,%edx
f010127b:	c1 ea 02             	shr    $0x2,%edx
f010127e:	89 97 68 26 00 00    	mov    %edx,0x2668(%edi)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101284:	89 c2                	mov    %eax,%edx
f0101286:	29 da                	sub    %ebx,%edx
f0101288:	52                   	push   %edx
f0101289:	53                   	push   %ebx
f010128a:	50                   	push   %eax
f010128b:	8d 87 d8 24 ed ff    	lea    -0x12db28(%edi),%eax
f0101291:	50                   	push   %eax
f0101292:	89 fb                	mov    %edi,%ebx
f0101294:	e8 66 21 00 00       	call   f01033ff <cprintf>
	kern_pgdir = (pde_t *)boot_alloc(PGSIZE); // 第一次运行，会舍入一部分
f0101299:	b8 00 10 00 00       	mov    $0x1000,%eax
f010129e:	e8 83 f9 ff ff       	call   f0100c26 <boot_alloc>
f01012a3:	c7 c6 0c 6f 23 f0    	mov    $0xf0236f0c,%esi
f01012a9:	89 06                	mov    %eax,(%esi)
	memset(kern_pgdir, 0, PGSIZE);			  // 内存初始化为0
f01012ab:	83 c4 0c             	add    $0xc,%esp
f01012ae:	68 00 10 00 00       	push   $0x1000
f01012b3:	6a 00                	push   $0x0
f01012b5:	50                   	push   %eax
f01012b6:	e8 21 3a 00 00       	call   f0104cdc <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P; // 暂时不需要理解，只需要知道kern_pgdir处有一个页表目录
f01012bb:	8b 06                	mov    (%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f01012bd:	83 c4 10             	add    $0x10,%esp
f01012c0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01012c5:	77 19                	ja     f01012e0 <mem_init+0xc4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01012c7:	50                   	push   %eax
f01012c8:	8d 87 4c 1f ed ff    	lea    -0x12e0b4(%edi),%eax
f01012ce:	50                   	push   %eax
f01012cf:	68 a4 00 00 00       	push   $0xa4
f01012d4:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01012da:	50                   	push   %eax
f01012db:	e8 60 ed ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01012e0:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01012e6:	83 ca 05             	or     $0x5,%edx
f01012e9:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *)boot_alloc(npages * sizeof(struct PageInfo)); // sizeof求得PageInfo占多少字节，返回结果记得强转成pages对应的类型
f01012ef:	c7 c3 08 6f 23 f0    	mov    $0xf0236f08,%ebx
f01012f5:	8b 03                	mov    (%ebx),%eax
f01012f7:	c1 e0 03             	shl    $0x3,%eax
f01012fa:	e8 27 f9 ff ff       	call   f0100c26 <boot_alloc>
f01012ff:	c7 c2 10 6f 23 f0    	mov    $0xf0236f10,%edx
f0101305:	89 02                	mov    %eax,(%edx)
	memset(pages, 0, npages * sizeof(struct PageInfo));						 // memset(d,c,l):从指针d开始，用字符c填充l个长度的内存
f0101307:	83 ec 04             	sub    $0x4,%esp
f010130a:	8b 13                	mov    (%ebx),%edx
f010130c:	c1 e2 03             	shl    $0x3,%edx
f010130f:	52                   	push   %edx
f0101310:	6a 00                	push   $0x0
f0101312:	50                   	push   %eax
f0101313:	89 fb                	mov    %edi,%ebx
f0101315:	e8 c2 39 00 00       	call   f0104cdc <memset>
	envs = (struct Env *)boot_alloc(NENV * sizeof(struct Env));
f010131a:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010131f:	e8 02 f9 ff ff       	call   f0100c26 <boot_alloc>
f0101324:	c7 c2 48 62 23 f0    	mov    $0xf0236248,%edx
f010132a:	89 02                	mov    %eax,(%edx)
	page_init(); // 初始化之后，所有的内存管理都将通过page_*函数进行
f010132c:	e8 3e fa ff ff       	call   f0100d6f <page_init>
	if (!page_free_list)
f0101331:	8b 87 64 26 00 00    	mov    0x2664(%edi),%eax
f0101337:	83 c4 10             	add    $0x10,%esp
f010133a:	85 c0                	test   %eax,%eax
f010133c:	74 60                	je     f010139e <mem_init+0x182>
		struct PageInfo **tp[2] = {&pp1, &pp2};
f010133e:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0101341:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101344:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101347:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f010134a:	c7 c3 10 6f 23 f0    	mov    $0xf0236f10,%ebx
f0101350:	89 c2                	mov    %eax,%edx
f0101352:	2b 13                	sub    (%ebx),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101354:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f010135a:	0f 95 c2             	setne  %dl
f010135d:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0101360:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0101364:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0101366:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link)
f010136a:	8b 00                	mov    (%eax),%eax
f010136c:	85 c0                	test   %eax,%eax
f010136e:	75 e0                	jne    f0101350 <mem_init+0x134>
		*tp[1] = 0;
f0101370:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101373:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0101379:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010137c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010137f:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101381:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0101384:	89 b7 64 26 00 00    	mov    %esi,0x2664(%edi)
f010138a:	c7 c0 10 6f 23 f0    	mov    $0xf0236f10,%eax
f0101390:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (PGNUM(pa) >= npages)
f0101393:	c7 c0 08 6f 23 f0    	mov    $0xf0236f08,%eax
f0101399:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010139c:	eb 35                	jmp    f01013d3 <mem_init+0x1b7>
		panic("'page_free_list' is a null pointer!");
f010139e:	83 ec 04             	sub    $0x4,%esp
f01013a1:	8d 87 14 25 ed ff    	lea    -0x12daec(%edi),%eax
f01013a7:	50                   	push   %eax
f01013a8:	68 3a 02 00 00       	push   $0x23a
f01013ad:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01013b3:	50                   	push   %eax
f01013b4:	e8 87 ec ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013b9:	52                   	push   %edx
f01013ba:	8d 87 28 1f ed ff    	lea    -0x12e0d8(%edi),%eax
f01013c0:	50                   	push   %eax
f01013c1:	6a 58                	push   $0x58
f01013c3:	8d 87 ed 2a ed ff    	lea    -0x12d513(%edi),%eax
f01013c9:	50                   	push   %eax
f01013ca:	89 fb                	mov    %edi,%ebx
f01013cc:	e8 6f ec ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01013d1:	8b 36                	mov    (%esi),%esi
f01013d3:	85 f6                	test   %esi,%esi
f01013d5:	74 42                	je     f0101419 <mem_init+0x1fd>
	return (pp - pages) << PGSHIFT;
f01013d7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01013da:	89 f0                	mov    %esi,%eax
f01013dc:	2b 01                	sub    (%ecx),%eax
f01013de:	c1 f8 03             	sar    $0x3,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01013e1:	89 c2                	mov    %eax,%edx
f01013e3:	c1 e2 0c             	shl    $0xc,%edx
f01013e6:	a9 00 fc 0f 00       	test   $0xffc00,%eax
f01013eb:	75 e4                	jne    f01013d1 <mem_init+0x1b5>
	if (PGNUM(pa) >= npages)
f01013ed:	89 d0                	mov    %edx,%eax
f01013ef:	c1 e8 0c             	shr    $0xc,%eax
f01013f2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01013f5:	3b 01                	cmp    (%ecx),%eax
f01013f7:	73 c0                	jae    f01013b9 <mem_init+0x19d>
			memset(page2kva(pp), 0x97, 128);
f01013f9:	83 ec 04             	sub    $0x4,%esp
f01013fc:	68 80 00 00 00       	push   $0x80
f0101401:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0101406:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010140c:	52                   	push   %edx
f010140d:	89 fb                	mov    %edi,%ebx
f010140f:	e8 c8 38 00 00       	call   f0104cdc <memset>
f0101414:	83 c4 10             	add    $0x10,%esp
f0101417:	eb b8                	jmp    f01013d1 <mem_init+0x1b5>
	first_free_page = (char *)boot_alloc(0);
f0101419:	b8 00 00 00 00       	mov    $0x0,%eax
f010141e:	e8 03 f8 ff ff       	call   f0100c26 <boot_alloc>
f0101423:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101426:	8b 97 64 26 00 00    	mov    0x2664(%edi),%edx
		assert(pp >= pages);
f010142c:	c7 c0 10 6f 23 f0    	mov    $0xf0236f10,%eax
f0101432:	8b 08                	mov    (%eax),%ecx
		assert(pp < pages + npages);
f0101434:	c7 c0 08 6f 23 f0    	mov    $0xf0236f08,%eax
f010143a:	8b 00                	mov    (%eax),%eax
f010143c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010143f:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0101442:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0101445:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0101448:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f010144f:	e9 4b 01 00 00       	jmp    f010159f <mem_init+0x383>
		assert(pp >= pages);
f0101454:	8d 87 fb 2a ed ff    	lea    -0x12d505(%edi),%eax
f010145a:	50                   	push   %eax
f010145b:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101461:	50                   	push   %eax
f0101462:	68 57 02 00 00       	push   $0x257
f0101467:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f010146d:	50                   	push   %eax
f010146e:	89 fb                	mov    %edi,%ebx
f0101470:	e8 cb eb ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0101475:	8d 87 1c 2b ed ff    	lea    -0x12d4e4(%edi),%eax
f010147b:	50                   	push   %eax
f010147c:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101482:	50                   	push   %eax
f0101483:	68 58 02 00 00       	push   $0x258
f0101488:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f010148e:	50                   	push   %eax
f010148f:	89 fb                	mov    %edi,%ebx
f0101491:	e8 aa eb ff ff       	call   f0100040 <_panic>
		assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0101496:	8d 87 38 25 ed ff    	lea    -0x12dac8(%edi),%eax
f010149c:	50                   	push   %eax
f010149d:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01014a3:	50                   	push   %eax
f01014a4:	68 59 02 00 00       	push   $0x259
f01014a9:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01014af:	50                   	push   %eax
f01014b0:	89 fb                	mov    %edi,%ebx
f01014b2:	e8 89 eb ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f01014b7:	8d 87 30 2b ed ff    	lea    -0x12d4d0(%edi),%eax
f01014bd:	50                   	push   %eax
f01014be:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01014c4:	50                   	push   %eax
f01014c5:	68 5c 02 00 00       	push   $0x25c
f01014ca:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01014d0:	50                   	push   %eax
f01014d1:	89 fb                	mov    %edi,%ebx
f01014d3:	e8 68 eb ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01014d8:	8d 87 41 2b ed ff    	lea    -0x12d4bf(%edi),%eax
f01014de:	50                   	push   %eax
f01014df:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01014e5:	50                   	push   %eax
f01014e6:	68 5d 02 00 00       	push   $0x25d
f01014eb:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01014f1:	50                   	push   %eax
f01014f2:	89 fb                	mov    %edi,%ebx
f01014f4:	e8 47 eb ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01014f9:	8d 87 68 25 ed ff    	lea    -0x12da98(%edi),%eax
f01014ff:	50                   	push   %eax
f0101500:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101506:	50                   	push   %eax
f0101507:	68 5e 02 00 00       	push   $0x25e
f010150c:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101512:	50                   	push   %eax
f0101513:	89 fb                	mov    %edi,%ebx
f0101515:	e8 26 eb ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f010151a:	8d 87 5a 2b ed ff    	lea    -0x12d4a6(%edi),%eax
f0101520:	50                   	push   %eax
f0101521:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101527:	50                   	push   %eax
f0101528:	68 5f 02 00 00       	push   $0x25f
f010152d:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101533:	50                   	push   %eax
f0101534:	89 fb                	mov    %edi,%ebx
f0101536:	e8 05 eb ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f010153b:	89 c3                	mov    %eax,%ebx
f010153d:	c1 eb 0c             	shr    $0xc,%ebx
f0101540:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0101543:	76 1b                	jbe    f0101560 <mem_init+0x344>
	return (void *)(pa + KERNBASE);
f0101545:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
		assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f010154b:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f010154e:	77 28                	ja     f0101578 <mem_init+0x35c>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101550:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101555:	0f 84 ab 00 00 00    	je     f0101606 <mem_init+0x3ea>
			++nfree_extmem;
f010155b:	83 c6 01             	add    $0x1,%esi
f010155e:	eb 3d                	jmp    f010159d <mem_init+0x381>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101560:	50                   	push   %eax
f0101561:	8d 87 28 1f ed ff    	lea    -0x12e0d8(%edi),%eax
f0101567:	50                   	push   %eax
f0101568:	6a 58                	push   $0x58
f010156a:	8d 87 ed 2a ed ff    	lea    -0x12d513(%edi),%eax
f0101570:	50                   	push   %eax
f0101571:	89 fb                	mov    %edi,%ebx
f0101573:	e8 c8 ea ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f0101578:	8d 87 8c 25 ed ff    	lea    -0x12da74(%edi),%eax
f010157e:	50                   	push   %eax
f010157f:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101585:	50                   	push   %eax
f0101586:	68 60 02 00 00       	push   $0x260
f010158b:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101591:	50                   	push   %eax
f0101592:	89 fb                	mov    %edi,%ebx
f0101594:	e8 a7 ea ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0101599:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010159d:	8b 12                	mov    (%edx),%edx
f010159f:	85 d2                	test   %edx,%edx
f01015a1:	0f 84 80 00 00 00    	je     f0101627 <mem_init+0x40b>
		assert(pp >= pages);
f01015a7:	39 d1                	cmp    %edx,%ecx
f01015a9:	0f 87 a5 fe ff ff    	ja     f0101454 <mem_init+0x238>
		assert(pp < pages + npages);
f01015af:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f01015b2:	0f 83 bd fe ff ff    	jae    f0101475 <mem_init+0x259>
		assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f01015b8:	89 d0                	mov    %edx,%eax
f01015ba:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01015bd:	a8 07                	test   $0x7,%al
f01015bf:	0f 85 d1 fe ff ff    	jne    f0101496 <mem_init+0x27a>
	return (pp - pages) << PGSHIFT;
f01015c5:	c1 f8 03             	sar    $0x3,%eax
f01015c8:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f01015cb:	85 c0                	test   %eax,%eax
f01015cd:	0f 84 e4 fe ff ff    	je     f01014b7 <mem_init+0x29b>
		assert(page2pa(pp) != IOPHYSMEM);
f01015d3:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01015d8:	0f 84 fa fe ff ff    	je     f01014d8 <mem_init+0x2bc>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01015de:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01015e3:	0f 84 10 ff ff ff    	je     f01014f9 <mem_init+0x2dd>
		assert(page2pa(pp) != EXTPHYSMEM);
f01015e9:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01015ee:	0f 84 26 ff ff ff    	je     f010151a <mem_init+0x2fe>
		assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f01015f4:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01015f9:	0f 87 3c ff ff ff    	ja     f010153b <mem_init+0x31f>
		assert(page2pa(pp) != MPENTRY_PADDR);
f01015ff:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101604:	75 93                	jne    f0101599 <mem_init+0x37d>
f0101606:	8d 87 74 2b ed ff    	lea    -0x12d48c(%edi),%eax
f010160c:	50                   	push   %eax
f010160d:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101613:	50                   	push   %eax
f0101614:	68 62 02 00 00       	push   $0x262
f0101619:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f010161f:	50                   	push   %eax
f0101620:	89 fb                	mov    %edi,%ebx
f0101622:	e8 19 ea ff ff       	call   f0100040 <_panic>
	assert(nfree_basemem > 0);
f0101627:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f010162b:	7e 30                	jle    f010165d <mem_init+0x441>
	assert(nfree_extmem > 0);
f010162d:	85 f6                	test   %esi,%esi
f010162f:	7e 4d                	jle    f010167e <mem_init+0x462>
	cprintf("check_page_free_list() succeeded!\n");
f0101631:	83 ec 0c             	sub    $0xc,%esp
f0101634:	8d 87 d0 25 ed ff    	lea    -0x12da30(%edi),%eax
f010163a:	50                   	push   %eax
f010163b:	89 fb                	mov    %edi,%ebx
f010163d:	e8 bd 1d 00 00       	call   f01033ff <cprintf>
	if (!pages)
f0101642:	83 c4 10             	add    $0x10,%esp
f0101645:	c7 c0 10 6f 23 f0    	mov    $0xf0236f10,%eax
f010164b:	83 38 00             	cmpl   $0x0,(%eax)
f010164e:	74 4f                	je     f010169f <mem_init+0x483>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101650:	8b 87 64 26 00 00    	mov    0x2664(%edi),%eax
f0101656:	be 00 00 00 00       	mov    $0x0,%esi
f010165b:	eb 62                	jmp    f01016bf <mem_init+0x4a3>
	assert(nfree_basemem > 0);
f010165d:	8d 87 91 2b ed ff    	lea    -0x12d46f(%edi),%eax
f0101663:	50                   	push   %eax
f0101664:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f010166a:	50                   	push   %eax
f010166b:	68 6a 02 00 00       	push   $0x26a
f0101670:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101676:	50                   	push   %eax
f0101677:	89 fb                	mov    %edi,%ebx
f0101679:	e8 c2 e9 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f010167e:	8d 87 a3 2b ed ff    	lea    -0x12d45d(%edi),%eax
f0101684:	50                   	push   %eax
f0101685:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f010168b:	50                   	push   %eax
f010168c:	68 6b 02 00 00       	push   $0x26b
f0101691:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101697:	50                   	push   %eax
f0101698:	89 fb                	mov    %edi,%ebx
f010169a:	e8 a1 e9 ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f010169f:	83 ec 04             	sub    $0x4,%esp
f01016a2:	8d 87 b4 2b ed ff    	lea    -0x12d44c(%edi),%eax
f01016a8:	50                   	push   %eax
f01016a9:	68 7d 02 00 00       	push   $0x27d
f01016ae:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01016b4:	50                   	push   %eax
f01016b5:	e8 86 e9 ff ff       	call   f0100040 <_panic>
		++nfree;
f01016ba:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016bd:	8b 00                	mov    (%eax),%eax
f01016bf:	85 c0                	test   %eax,%eax
f01016c1:	75 f7                	jne    f01016ba <mem_init+0x49e>
	assert((pp0 = page_alloc(0)));
f01016c3:	83 ec 0c             	sub    $0xc,%esp
f01016c6:	6a 00                	push   $0x0
f01016c8:	e8 9d f7 ff ff       	call   f0100e6a <page_alloc>
f01016cd:	89 c3                	mov    %eax,%ebx
f01016cf:	83 c4 10             	add    $0x10,%esp
f01016d2:	85 c0                	test   %eax,%eax
f01016d4:	0f 84 f7 01 00 00    	je     f01018d1 <mem_init+0x6b5>
	assert((pp1 = page_alloc(0)));
f01016da:	83 ec 0c             	sub    $0xc,%esp
f01016dd:	6a 00                	push   $0x0
f01016df:	e8 86 f7 ff ff       	call   f0100e6a <page_alloc>
f01016e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01016e7:	83 c4 10             	add    $0x10,%esp
f01016ea:	85 c0                	test   %eax,%eax
f01016ec:	0f 84 00 02 00 00    	je     f01018f2 <mem_init+0x6d6>
	assert((pp2 = page_alloc(0)));
f01016f2:	83 ec 0c             	sub    $0xc,%esp
f01016f5:	6a 00                	push   $0x0
f01016f7:	e8 6e f7 ff ff       	call   f0100e6a <page_alloc>
f01016fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01016ff:	83 c4 10             	add    $0x10,%esp
f0101702:	85 c0                	test   %eax,%eax
f0101704:	0f 84 09 02 00 00    	je     f0101913 <mem_init+0x6f7>
	assert(pp1 && pp1 != pp0);
f010170a:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f010170d:	0f 84 21 02 00 00    	je     f0101934 <mem_init+0x718>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101713:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101716:	39 c3                	cmp    %eax,%ebx
f0101718:	0f 84 37 02 00 00    	je     f0101955 <mem_init+0x739>
f010171e:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101721:	0f 84 2e 02 00 00    	je     f0101955 <mem_init+0x739>
f0101727:	c7 c0 10 6f 23 f0    	mov    $0xf0236f10,%eax
f010172d:	8b 08                	mov    (%eax),%ecx
	assert(page2pa(pp0) < npages * PGSIZE);
f010172f:	c7 c0 08 6f 23 f0    	mov    $0xf0236f08,%eax
f0101735:	8b 10                	mov    (%eax),%edx
f0101737:	c1 e2 0c             	shl    $0xc,%edx
f010173a:	89 d8                	mov    %ebx,%eax
f010173c:	29 c8                	sub    %ecx,%eax
f010173e:	c1 f8 03             	sar    $0x3,%eax
f0101741:	c1 e0 0c             	shl    $0xc,%eax
f0101744:	39 d0                	cmp    %edx,%eax
f0101746:	0f 83 2a 02 00 00    	jae    f0101976 <mem_init+0x75a>
f010174c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010174f:	29 c8                	sub    %ecx,%eax
f0101751:	c1 f8 03             	sar    $0x3,%eax
f0101754:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages * PGSIZE);
f0101757:	39 c2                	cmp    %eax,%edx
f0101759:	0f 86 38 02 00 00    	jbe    f0101997 <mem_init+0x77b>
f010175f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101762:	29 c8                	sub    %ecx,%eax
f0101764:	c1 f8 03             	sar    $0x3,%eax
f0101767:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages * PGSIZE);
f010176a:	39 c2                	cmp    %eax,%edx
f010176c:	0f 86 46 02 00 00    	jbe    f01019b8 <mem_init+0x79c>
	fl = page_free_list;
f0101772:	8b 87 64 26 00 00    	mov    0x2664(%edi),%eax
f0101778:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f010177b:	c7 87 64 26 00 00 00 	movl   $0x0,0x2664(%edi)
f0101782:	00 00 00 
	assert(!page_alloc(0));
f0101785:	83 ec 0c             	sub    $0xc,%esp
f0101788:	6a 00                	push   $0x0
f010178a:	e8 db f6 ff ff       	call   f0100e6a <page_alloc>
f010178f:	83 c4 10             	add    $0x10,%esp
f0101792:	85 c0                	test   %eax,%eax
f0101794:	0f 85 3f 02 00 00    	jne    f01019d9 <mem_init+0x7bd>
	page_free(pp0);
f010179a:	83 ec 0c             	sub    $0xc,%esp
f010179d:	53                   	push   %ebx
f010179e:	e8 55 f7 ff ff       	call   f0100ef8 <page_free>
	page_free(pp1);
f01017a3:	83 c4 04             	add    $0x4,%esp
f01017a6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017a9:	e8 4a f7 ff ff       	call   f0100ef8 <page_free>
	page_free(pp2);
f01017ae:	83 c4 04             	add    $0x4,%esp
f01017b1:	ff 75 d0             	pushl  -0x30(%ebp)
f01017b4:	e8 3f f7 ff ff       	call   f0100ef8 <page_free>
	assert((pp0 = page_alloc(0)));
f01017b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017c0:	e8 a5 f6 ff ff       	call   f0100e6a <page_alloc>
f01017c5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017c8:	83 c4 10             	add    $0x10,%esp
f01017cb:	85 c0                	test   %eax,%eax
f01017cd:	0f 84 27 02 00 00    	je     f01019fa <mem_init+0x7de>
	assert((pp1 = page_alloc(0)));
f01017d3:	83 ec 0c             	sub    $0xc,%esp
f01017d6:	6a 00                	push   $0x0
f01017d8:	e8 8d f6 ff ff       	call   f0100e6a <page_alloc>
f01017dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01017e0:	83 c4 10             	add    $0x10,%esp
f01017e3:	85 c0                	test   %eax,%eax
f01017e5:	0f 84 30 02 00 00    	je     f0101a1b <mem_init+0x7ff>
	assert((pp2 = page_alloc(0)));
f01017eb:	83 ec 0c             	sub    $0xc,%esp
f01017ee:	6a 00                	push   $0x0
f01017f0:	e8 75 f6 ff ff       	call   f0100e6a <page_alloc>
f01017f5:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01017f8:	83 c4 10             	add    $0x10,%esp
f01017fb:	85 c0                	test   %eax,%eax
f01017fd:	0f 84 39 02 00 00    	je     f0101a3c <mem_init+0x820>
	assert(pp1 && pp1 != pp0);
f0101803:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101806:	39 4d d4             	cmp    %ecx,-0x2c(%ebp)
f0101809:	0f 84 4e 02 00 00    	je     f0101a5d <mem_init+0x841>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010180f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101812:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101815:	0f 84 63 02 00 00    	je     f0101a7e <mem_init+0x862>
f010181b:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010181e:	0f 84 5a 02 00 00    	je     f0101a7e <mem_init+0x862>
	assert(!page_alloc(0));
f0101824:	83 ec 0c             	sub    $0xc,%esp
f0101827:	6a 00                	push   $0x0
f0101829:	e8 3c f6 ff ff       	call   f0100e6a <page_alloc>
f010182e:	83 c4 10             	add    $0x10,%esp
f0101831:	85 c0                	test   %eax,%eax
f0101833:	0f 85 66 02 00 00    	jne    f0101a9f <mem_init+0x883>
	memset(page2kva(pp0), 1, PGSIZE);
f0101839:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010183c:	e8 65 f4 ff ff       	call   f0100ca6 <page2kva>
f0101841:	83 ec 04             	sub    $0x4,%esp
f0101844:	68 00 10 00 00       	push   $0x1000
f0101849:	6a 01                	push   $0x1
f010184b:	50                   	push   %eax
f010184c:	89 fb                	mov    %edi,%ebx
f010184e:	e8 89 34 00 00       	call   f0104cdc <memset>
	page_free(pp0);
f0101853:	83 c4 04             	add    $0x4,%esp
f0101856:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101859:	e8 9a f6 ff ff       	call   f0100ef8 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010185e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101865:	e8 00 f6 ff ff       	call   f0100e6a <page_alloc>
f010186a:	83 c4 10             	add    $0x10,%esp
f010186d:	85 c0                	test   %eax,%eax
f010186f:	0f 84 4b 02 00 00    	je     f0101ac0 <mem_init+0x8a4>
	assert(pp && pp0 == pp);
f0101875:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101878:	0f 85 61 02 00 00    	jne    f0101adf <mem_init+0x8c3>
	c = page2kva(pp);
f010187e:	e8 23 f4 ff ff       	call   f0100ca6 <page2kva>
f0101883:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		assert(c[i] == 0);
f0101889:	80 38 00             	cmpb   $0x0,(%eax)
f010188c:	0f 85 6c 02 00 00    	jne    f0101afe <mem_init+0x8e2>
f0101892:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101895:	39 c2                	cmp    %eax,%edx
f0101897:	75 f0                	jne    f0101889 <mem_init+0x66d>
	page_free_list = fl;
f0101899:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010189c:	89 87 64 26 00 00    	mov    %eax,0x2664(%edi)
	page_free(pp0);
f01018a2:	83 ec 0c             	sub    $0xc,%esp
f01018a5:	ff 75 d4             	pushl  -0x2c(%ebp)
f01018a8:	e8 4b f6 ff ff       	call   f0100ef8 <page_free>
	page_free(pp1);
f01018ad:	83 c4 04             	add    $0x4,%esp
f01018b0:	ff 75 d0             	pushl  -0x30(%ebp)
f01018b3:	e8 40 f6 ff ff       	call   f0100ef8 <page_free>
	page_free(pp2);
f01018b8:	83 c4 04             	add    $0x4,%esp
f01018bb:	ff 75 cc             	pushl  -0x34(%ebp)
f01018be:	e8 35 f6 ff ff       	call   f0100ef8 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01018c3:	8b 87 64 26 00 00    	mov    0x2664(%edi),%eax
f01018c9:	83 c4 10             	add    $0x10,%esp
f01018cc:	e9 53 02 00 00       	jmp    f0101b24 <mem_init+0x908>
	assert((pp0 = page_alloc(0)));
f01018d1:	8d 87 cf 2b ed ff    	lea    -0x12d431(%edi),%eax
f01018d7:	50                   	push   %eax
f01018d8:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01018de:	50                   	push   %eax
f01018df:	68 85 02 00 00       	push   $0x285
f01018e4:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01018ea:	50                   	push   %eax
f01018eb:	89 fb                	mov    %edi,%ebx
f01018ed:	e8 4e e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01018f2:	8d 87 e5 2b ed ff    	lea    -0x12d41b(%edi),%eax
f01018f8:	50                   	push   %eax
f01018f9:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01018ff:	50                   	push   %eax
f0101900:	68 86 02 00 00       	push   $0x286
f0101905:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f010190b:	50                   	push   %eax
f010190c:	89 fb                	mov    %edi,%ebx
f010190e:	e8 2d e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101913:	8d 87 fb 2b ed ff    	lea    -0x12d405(%edi),%eax
f0101919:	50                   	push   %eax
f010191a:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101920:	50                   	push   %eax
f0101921:	68 87 02 00 00       	push   $0x287
f0101926:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f010192c:	50                   	push   %eax
f010192d:	89 fb                	mov    %edi,%ebx
f010192f:	e8 0c e7 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101934:	8d 87 11 2c ed ff    	lea    -0x12d3ef(%edi),%eax
f010193a:	50                   	push   %eax
f010193b:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101941:	50                   	push   %eax
f0101942:	68 8a 02 00 00       	push   $0x28a
f0101947:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f010194d:	50                   	push   %eax
f010194e:	89 fb                	mov    %edi,%ebx
f0101950:	e8 eb e6 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101955:	8d 87 f4 25 ed ff    	lea    -0x12da0c(%edi),%eax
f010195b:	50                   	push   %eax
f010195c:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101962:	50                   	push   %eax
f0101963:	68 8b 02 00 00       	push   $0x28b
f0101968:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f010196e:	50                   	push   %eax
f010196f:	89 fb                	mov    %edi,%ebx
f0101971:	e8 ca e6 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages * PGSIZE);
f0101976:	8d 87 14 26 ed ff    	lea    -0x12d9ec(%edi),%eax
f010197c:	50                   	push   %eax
f010197d:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101983:	50                   	push   %eax
f0101984:	68 8c 02 00 00       	push   $0x28c
f0101989:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f010198f:	50                   	push   %eax
f0101990:	89 fb                	mov    %edi,%ebx
f0101992:	e8 a9 e6 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages * PGSIZE);
f0101997:	8d 87 34 26 ed ff    	lea    -0x12d9cc(%edi),%eax
f010199d:	50                   	push   %eax
f010199e:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01019a4:	50                   	push   %eax
f01019a5:	68 8d 02 00 00       	push   $0x28d
f01019aa:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01019b0:	50                   	push   %eax
f01019b1:	89 fb                	mov    %edi,%ebx
f01019b3:	e8 88 e6 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages * PGSIZE);
f01019b8:	8d 87 54 26 ed ff    	lea    -0x12d9ac(%edi),%eax
f01019be:	50                   	push   %eax
f01019bf:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01019c5:	50                   	push   %eax
f01019c6:	68 8e 02 00 00       	push   $0x28e
f01019cb:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01019d1:	50                   	push   %eax
f01019d2:	89 fb                	mov    %edi,%ebx
f01019d4:	e8 67 e6 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01019d9:	8d 87 23 2c ed ff    	lea    -0x12d3dd(%edi),%eax
f01019df:	50                   	push   %eax
f01019e0:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01019e6:	50                   	push   %eax
f01019e7:	68 95 02 00 00       	push   $0x295
f01019ec:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01019f2:	50                   	push   %eax
f01019f3:	89 fb                	mov    %edi,%ebx
f01019f5:	e8 46 e6 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01019fa:	8d 87 cf 2b ed ff    	lea    -0x12d431(%edi),%eax
f0101a00:	50                   	push   %eax
f0101a01:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101a07:	50                   	push   %eax
f0101a08:	68 9c 02 00 00       	push   $0x29c
f0101a0d:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101a13:	50                   	push   %eax
f0101a14:	89 fb                	mov    %edi,%ebx
f0101a16:	e8 25 e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a1b:	8d 87 e5 2b ed ff    	lea    -0x12d41b(%edi),%eax
f0101a21:	50                   	push   %eax
f0101a22:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101a28:	50                   	push   %eax
f0101a29:	68 9d 02 00 00       	push   $0x29d
f0101a2e:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101a34:	50                   	push   %eax
f0101a35:	89 fb                	mov    %edi,%ebx
f0101a37:	e8 04 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a3c:	8d 87 fb 2b ed ff    	lea    -0x12d405(%edi),%eax
f0101a42:	50                   	push   %eax
f0101a43:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101a49:	50                   	push   %eax
f0101a4a:	68 9e 02 00 00       	push   $0x29e
f0101a4f:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101a55:	50                   	push   %eax
f0101a56:	89 fb                	mov    %edi,%ebx
f0101a58:	e8 e3 e5 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101a5d:	8d 87 11 2c ed ff    	lea    -0x12d3ef(%edi),%eax
f0101a63:	50                   	push   %eax
f0101a64:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101a6a:	50                   	push   %eax
f0101a6b:	68 a0 02 00 00       	push   $0x2a0
f0101a70:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101a76:	50                   	push   %eax
f0101a77:	89 fb                	mov    %edi,%ebx
f0101a79:	e8 c2 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a7e:	8d 87 f4 25 ed ff    	lea    -0x12da0c(%edi),%eax
f0101a84:	50                   	push   %eax
f0101a85:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101a8b:	50                   	push   %eax
f0101a8c:	68 a1 02 00 00       	push   $0x2a1
f0101a91:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101a97:	50                   	push   %eax
f0101a98:	89 fb                	mov    %edi,%ebx
f0101a9a:	e8 a1 e5 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101a9f:	8d 87 23 2c ed ff    	lea    -0x12d3dd(%edi),%eax
f0101aa5:	50                   	push   %eax
f0101aa6:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101aac:	50                   	push   %eax
f0101aad:	68 a2 02 00 00       	push   $0x2a2
f0101ab2:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101ab8:	50                   	push   %eax
f0101ab9:	89 fb                	mov    %edi,%ebx
f0101abb:	e8 80 e5 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101ac0:	8d 87 32 2c ed ff    	lea    -0x12d3ce(%edi),%eax
f0101ac6:	50                   	push   %eax
f0101ac7:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101acd:	50                   	push   %eax
f0101ace:	68 a7 02 00 00       	push   $0x2a7
f0101ad3:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101ad9:	50                   	push   %eax
f0101ada:	e8 61 e5 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101adf:	8d 87 50 2c ed ff    	lea    -0x12d3b0(%edi),%eax
f0101ae5:	50                   	push   %eax
f0101ae6:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101aec:	50                   	push   %eax
f0101aed:	68 a8 02 00 00       	push   $0x2a8
f0101af2:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101af8:	50                   	push   %eax
f0101af9:	e8 42 e5 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f0101afe:	8d 87 60 2c ed ff    	lea    -0x12d3a0(%edi),%eax
f0101b04:	50                   	push   %eax
f0101b05:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101b0b:	50                   	push   %eax
f0101b0c:	68 ab 02 00 00       	push   $0x2ab
f0101b11:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101b17:	50                   	push   %eax
f0101b18:	89 fb                	mov    %edi,%ebx
f0101b1a:	e8 21 e5 ff ff       	call   f0100040 <_panic>
		--nfree;
f0101b1f:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b22:	8b 00                	mov    (%eax),%eax
f0101b24:	85 c0                	test   %eax,%eax
f0101b26:	75 f7                	jne    f0101b1f <mem_init+0x903>
	assert(nfree == 0);
f0101b28:	85 f6                	test   %esi,%esi
f0101b2a:	0f 85 94 00 00 00    	jne    f0101bc4 <mem_init+0x9a8>
	cprintf("check_page_alloc() succeeded!\n");
f0101b30:	83 ec 0c             	sub    $0xc,%esp
f0101b33:	8d 87 74 26 ed ff    	lea    -0x12d98c(%edi),%eax
f0101b39:	50                   	push   %eax
f0101b3a:	89 fb                	mov    %edi,%ebx
f0101b3c:	e8 be 18 00 00       	call   f01033ff <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101b41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b48:	e8 1d f3 ff ff       	call   f0100e6a <page_alloc>
f0101b4d:	89 c6                	mov    %eax,%esi
f0101b4f:	83 c4 10             	add    $0x10,%esp
f0101b52:	85 c0                	test   %eax,%eax
f0101b54:	0f 84 8b 00 00 00    	je     f0101be5 <mem_init+0x9c9>
	assert((pp1 = page_alloc(0)));
f0101b5a:	83 ec 0c             	sub    $0xc,%esp
f0101b5d:	6a 00                	push   $0x0
f0101b5f:	e8 06 f3 ff ff       	call   f0100e6a <page_alloc>
f0101b64:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101b67:	83 c4 10             	add    $0x10,%esp
f0101b6a:	85 c0                	test   %eax,%eax
f0101b6c:	0f 84 92 00 00 00    	je     f0101c04 <mem_init+0x9e8>
	assert((pp2 = page_alloc(0)));
f0101b72:	83 ec 0c             	sub    $0xc,%esp
f0101b75:	6a 00                	push   $0x0
f0101b77:	e8 ee f2 ff ff       	call   f0100e6a <page_alloc>
f0101b7c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101b7f:	83 c4 10             	add    $0x10,%esp
f0101b82:	85 c0                	test   %eax,%eax
f0101b84:	0f 84 99 00 00 00    	je     f0101c23 <mem_init+0xa07>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b8a:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101b8d:	0f 84 af 00 00 00    	je     f0101c42 <mem_init+0xa26>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b93:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b96:	39 c6                	cmp    %eax,%esi
f0101b98:	74 09                	je     f0101ba3 <mem_init+0x987>
f0101b9a:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101b9d:	0f 85 be 00 00 00    	jne    f0101c61 <mem_init+0xa45>
f0101ba3:	8d 87 f4 25 ed ff    	lea    -0x12da0c(%edi),%eax
f0101ba9:	50                   	push   %eax
f0101baa:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101bb0:	50                   	push   %eax
f0101bb1:	68 26 03 00 00       	push   $0x326
f0101bb6:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101bbc:	50                   	push   %eax
f0101bbd:	89 fb                	mov    %edi,%ebx
f0101bbf:	e8 7c e4 ff ff       	call   f0100040 <_panic>
	assert(nfree == 0);
f0101bc4:	8d 87 6a 2c ed ff    	lea    -0x12d396(%edi),%eax
f0101bca:	50                   	push   %eax
f0101bcb:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101bd1:	50                   	push   %eax
f0101bd2:	68 b8 02 00 00       	push   $0x2b8
f0101bd7:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101bdd:	50                   	push   %eax
f0101bde:	89 fb                	mov    %edi,%ebx
f0101be0:	e8 5b e4 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0101be5:	8d 87 cf 2b ed ff    	lea    -0x12d431(%edi),%eax
f0101beb:	50                   	push   %eax
f0101bec:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101bf2:	50                   	push   %eax
f0101bf3:	68 20 03 00 00       	push   $0x320
f0101bf8:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101bfe:	50                   	push   %eax
f0101bff:	e8 3c e4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c04:	8d 87 e5 2b ed ff    	lea    -0x12d41b(%edi),%eax
f0101c0a:	50                   	push   %eax
f0101c0b:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101c11:	50                   	push   %eax
f0101c12:	68 21 03 00 00       	push   $0x321
f0101c17:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101c1d:	50                   	push   %eax
f0101c1e:	e8 1d e4 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c23:	8d 87 fb 2b ed ff    	lea    -0x12d405(%edi),%eax
f0101c29:	50                   	push   %eax
f0101c2a:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101c30:	50                   	push   %eax
f0101c31:	68 22 03 00 00       	push   $0x322
f0101c36:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101c3c:	50                   	push   %eax
f0101c3d:	e8 fe e3 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101c42:	8d 87 11 2c ed ff    	lea    -0x12d3ef(%edi),%eax
f0101c48:	50                   	push   %eax
f0101c49:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101c4f:	50                   	push   %eax
f0101c50:	68 25 03 00 00       	push   $0x325
f0101c55:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101c5b:	50                   	push   %eax
f0101c5c:	e8 df e3 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101c61:	8b 87 64 26 00 00    	mov    0x2664(%edi),%eax
f0101c67:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101c6a:	c7 87 64 26 00 00 00 	movl   $0x0,0x2664(%edi)
f0101c71:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101c74:	83 ec 0c             	sub    $0xc,%esp
f0101c77:	6a 00                	push   $0x0
f0101c79:	e8 ec f1 ff ff       	call   f0100e6a <page_alloc>
f0101c7e:	83 c4 10             	add    $0x10,%esp
f0101c81:	85 c0                	test   %eax,%eax
f0101c83:	74 1f                	je     f0101ca4 <mem_init+0xa88>
f0101c85:	8d 87 23 2c ed ff    	lea    -0x12d3dd(%edi),%eax
f0101c8b:	50                   	push   %eax
f0101c8c:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101c92:	50                   	push   %eax
f0101c93:	68 2d 03 00 00       	push   $0x32d
f0101c98:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101c9e:	50                   	push   %eax
f0101c9f:	e8 9c e3 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *)0x0, &ptep) == NULL);
f0101ca4:	83 ec 04             	sub    $0x4,%esp
f0101ca7:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0101caa:	50                   	push   %eax
f0101cab:	6a 00                	push   $0x0
f0101cad:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f0101cb3:	ff 30                	pushl  (%eax)
f0101cb5:	e8 a7 f3 ff ff       	call   f0101061 <page_lookup>
f0101cba:	83 c4 10             	add    $0x10,%esp
f0101cbd:	85 c0                	test   %eax,%eax
f0101cbf:	74 1f                	je     f0101ce0 <mem_init+0xac4>
f0101cc1:	8d 87 94 26 ed ff    	lea    -0x12d96c(%edi),%eax
f0101cc7:	50                   	push   %eax
f0101cc8:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101cce:	50                   	push   %eax
f0101ccf:	68 30 03 00 00       	push   $0x330
f0101cd4:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101cda:	50                   	push   %eax
f0101cdb:	e8 60 e3 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101ce0:	6a 02                	push   $0x2
f0101ce2:	6a 00                	push   $0x0
f0101ce4:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101ce7:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f0101ced:	ff 30                	pushl  (%eax)
f0101cef:	e8 6e f4 ff ff       	call   f0101162 <page_insert>
f0101cf4:	83 c4 10             	add    $0x10,%esp
f0101cf7:	85 c0                	test   %eax,%eax
f0101cf9:	78 1f                	js     f0101d1a <mem_init+0xafe>
f0101cfb:	8d 87 c8 26 ed ff    	lea    -0x12d938(%edi),%eax
f0101d01:	50                   	push   %eax
f0101d02:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101d08:	50                   	push   %eax
f0101d09:	68 33 03 00 00       	push   $0x333
f0101d0e:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101d14:	50                   	push   %eax
f0101d15:	e8 26 e3 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101d1a:	83 ec 0c             	sub    $0xc,%esp
f0101d1d:	56                   	push   %esi
f0101d1e:	e8 d5 f1 ff ff       	call   f0100ef8 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101d23:	6a 02                	push   $0x2
f0101d25:	6a 00                	push   $0x0
f0101d27:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d2a:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f0101d30:	ff 30                	pushl  (%eax)
f0101d32:	e8 2b f4 ff ff       	call   f0101162 <page_insert>
f0101d37:	83 c4 20             	add    $0x20,%esp
f0101d3a:	85 c0                	test   %eax,%eax
f0101d3c:	74 1f                	je     f0101d5d <mem_init+0xb41>
f0101d3e:	8d 87 f8 26 ed ff    	lea    -0x12d908(%edi),%eax
f0101d44:	50                   	push   %eax
f0101d45:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101d4b:	50                   	push   %eax
f0101d4c:	68 37 03 00 00       	push   $0x337
f0101d51:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101d57:	50                   	push   %eax
f0101d58:	e8 e3 e2 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d5d:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f0101d63:	8b 18                	mov    (%eax),%ebx
f0101d65:	c7 c0 10 6f 23 f0    	mov    $0xf0236f10,%eax
f0101d6b:	8b 08                	mov    (%eax),%ecx
f0101d6d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0101d70:	8b 13                	mov    (%ebx),%edx
f0101d72:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101d78:	89 f0                	mov    %esi,%eax
f0101d7a:	29 c8                	sub    %ecx,%eax
f0101d7c:	c1 f8 03             	sar    $0x3,%eax
f0101d7f:	c1 e0 0c             	shl    $0xc,%eax
f0101d82:	39 c2                	cmp    %eax,%edx
f0101d84:	74 21                	je     f0101da7 <mem_init+0xb8b>
f0101d86:	8d 87 28 27 ed ff    	lea    -0x12d8d8(%edi),%eax
f0101d8c:	50                   	push   %eax
f0101d8d:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101d93:	50                   	push   %eax
f0101d94:	68 38 03 00 00       	push   $0x338
f0101d99:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101d9f:	50                   	push   %eax
f0101da0:	89 fb                	mov    %edi,%ebx
f0101da2:	e8 99 e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101da7:	ba 00 00 00 00       	mov    $0x0,%edx
f0101dac:	89 d8                	mov    %ebx,%eax
f0101dae:	e8 44 ef ff ff       	call   f0100cf7 <check_va2pa>
f0101db3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101db6:	2b 55 c8             	sub    -0x38(%ebp),%edx
f0101db9:	c1 fa 03             	sar    $0x3,%edx
f0101dbc:	c1 e2 0c             	shl    $0xc,%edx
f0101dbf:	39 d0                	cmp    %edx,%eax
f0101dc1:	74 21                	je     f0101de4 <mem_init+0xbc8>
f0101dc3:	8d 87 50 27 ed ff    	lea    -0x12d8b0(%edi),%eax
f0101dc9:	50                   	push   %eax
f0101dca:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101dd0:	50                   	push   %eax
f0101dd1:	68 39 03 00 00       	push   $0x339
f0101dd6:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101ddc:	50                   	push   %eax
f0101ddd:	89 fb                	mov    %edi,%ebx
f0101ddf:	e8 5c e2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101de4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101de7:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101dec:	74 21                	je     f0101e0f <mem_init+0xbf3>
f0101dee:	8d 87 75 2c ed ff    	lea    -0x12d38b(%edi),%eax
f0101df4:	50                   	push   %eax
f0101df5:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101dfb:	50                   	push   %eax
f0101dfc:	68 3a 03 00 00       	push   $0x33a
f0101e01:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101e07:	50                   	push   %eax
f0101e08:	89 fb                	mov    %edi,%ebx
f0101e0a:	e8 31 e2 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101e0f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e14:	74 21                	je     f0101e37 <mem_init+0xc1b>
f0101e16:	8d 87 86 2c ed ff    	lea    -0x12d37a(%edi),%eax
f0101e1c:	50                   	push   %eax
f0101e1d:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101e23:	50                   	push   %eax
f0101e24:	68 3b 03 00 00       	push   $0x33b
f0101e29:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101e2f:	50                   	push   %eax
f0101e30:	89 fb                	mov    %edi,%ebx
f0101e32:	e8 09 e2 ff ff       	call   f0100040 <_panic>
	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101e37:	6a 02                	push   $0x2
f0101e39:	68 00 10 00 00       	push   $0x1000
f0101e3e:	ff 75 d0             	pushl  -0x30(%ebp)
f0101e41:	53                   	push   %ebx
f0101e42:	e8 1b f3 ff ff       	call   f0101162 <page_insert>
f0101e47:	83 c4 10             	add    $0x10,%esp
f0101e4a:	85 c0                	test   %eax,%eax
f0101e4c:	74 21                	je     f0101e6f <mem_init+0xc53>
f0101e4e:	8d 87 80 27 ed ff    	lea    -0x12d880(%edi),%eax
f0101e54:	50                   	push   %eax
f0101e55:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101e5b:	50                   	push   %eax
f0101e5c:	68 3d 03 00 00       	push   $0x33d
f0101e61:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101e67:	50                   	push   %eax
f0101e68:	89 fb                	mov    %edi,%ebx
f0101e6a:	e8 d1 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e6f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e74:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f0101e7a:	8b 00                	mov    (%eax),%eax
f0101e7c:	e8 76 ee ff ff       	call   f0100cf7 <check_va2pa>
f0101e81:	c7 c2 10 6f 23 f0    	mov    $0xf0236f10,%edx
f0101e87:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101e8a:	2b 0a                	sub    (%edx),%ecx
f0101e8c:	89 ca                	mov    %ecx,%edx
f0101e8e:	c1 fa 03             	sar    $0x3,%edx
f0101e91:	c1 e2 0c             	shl    $0xc,%edx
f0101e94:	39 d0                	cmp    %edx,%eax
f0101e96:	74 21                	je     f0101eb9 <mem_init+0xc9d>
f0101e98:	8d 87 bc 27 ed ff    	lea    -0x12d844(%edi),%eax
f0101e9e:	50                   	push   %eax
f0101e9f:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101ea5:	50                   	push   %eax
f0101ea6:	68 3e 03 00 00       	push   $0x33e
f0101eab:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101eb1:	50                   	push   %eax
f0101eb2:	89 fb                	mov    %edi,%ebx
f0101eb4:	e8 87 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101eb9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101ebc:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ec1:	74 21                	je     f0101ee4 <mem_init+0xcc8>
f0101ec3:	8d 87 97 2c ed ff    	lea    -0x12d369(%edi),%eax
f0101ec9:	50                   	push   %eax
f0101eca:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101ed0:	50                   	push   %eax
f0101ed1:	68 3f 03 00 00       	push   $0x33f
f0101ed6:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101edc:	50                   	push   %eax
f0101edd:	89 fb                	mov    %edi,%ebx
f0101edf:	e8 5c e1 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101ee4:	83 ec 0c             	sub    $0xc,%esp
f0101ee7:	6a 00                	push   $0x0
f0101ee9:	e8 7c ef ff ff       	call   f0100e6a <page_alloc>
f0101eee:	83 c4 10             	add    $0x10,%esp
f0101ef1:	85 c0                	test   %eax,%eax
f0101ef3:	74 21                	je     f0101f16 <mem_init+0xcfa>
f0101ef5:	8d 87 23 2c ed ff    	lea    -0x12d3dd(%edi),%eax
f0101efb:	50                   	push   %eax
f0101efc:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101f02:	50                   	push   %eax
f0101f03:	68 42 03 00 00       	push   $0x342
f0101f08:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101f0e:	50                   	push   %eax
f0101f0f:	89 fb                	mov    %edi,%ebx
f0101f11:	e8 2a e1 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101f16:	6a 02                	push   $0x2
f0101f18:	68 00 10 00 00       	push   $0x1000
f0101f1d:	ff 75 d0             	pushl  -0x30(%ebp)
f0101f20:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f0101f26:	ff 30                	pushl  (%eax)
f0101f28:	e8 35 f2 ff ff       	call   f0101162 <page_insert>
f0101f2d:	83 c4 10             	add    $0x10,%esp
f0101f30:	85 c0                	test   %eax,%eax
f0101f32:	74 21                	je     f0101f55 <mem_init+0xd39>
f0101f34:	8d 87 80 27 ed ff    	lea    -0x12d880(%edi),%eax
f0101f3a:	50                   	push   %eax
f0101f3b:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101f41:	50                   	push   %eax
f0101f42:	68 45 03 00 00       	push   $0x345
f0101f47:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101f4d:	50                   	push   %eax
f0101f4e:	89 fb                	mov    %edi,%ebx
f0101f50:	e8 eb e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f55:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f5a:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f0101f60:	8b 00                	mov    (%eax),%eax
f0101f62:	e8 90 ed ff ff       	call   f0100cf7 <check_va2pa>
f0101f67:	c7 c2 10 6f 23 f0    	mov    $0xf0236f10,%edx
f0101f6d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101f70:	2b 0a                	sub    (%edx),%ecx
f0101f72:	89 ca                	mov    %ecx,%edx
f0101f74:	c1 fa 03             	sar    $0x3,%edx
f0101f77:	c1 e2 0c             	shl    $0xc,%edx
f0101f7a:	39 d0                	cmp    %edx,%eax
f0101f7c:	74 21                	je     f0101f9f <mem_init+0xd83>
f0101f7e:	8d 87 bc 27 ed ff    	lea    -0x12d844(%edi),%eax
f0101f84:	50                   	push   %eax
f0101f85:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101f8b:	50                   	push   %eax
f0101f8c:	68 46 03 00 00       	push   $0x346
f0101f91:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101f97:	50                   	push   %eax
f0101f98:	89 fb                	mov    %edi,%ebx
f0101f9a:	e8 a1 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101f9f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101fa2:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101fa7:	74 21                	je     f0101fca <mem_init+0xdae>
f0101fa9:	8d 87 97 2c ed ff    	lea    -0x12d369(%edi),%eax
f0101faf:	50                   	push   %eax
f0101fb0:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101fb6:	50                   	push   %eax
f0101fb7:	68 47 03 00 00       	push   $0x347
f0101fbc:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101fc2:	50                   	push   %eax
f0101fc3:	89 fb                	mov    %edi,%ebx
f0101fc5:	e8 76 e0 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101fca:	83 ec 0c             	sub    $0xc,%esp
f0101fcd:	6a 00                	push   $0x0
f0101fcf:	e8 96 ee ff ff       	call   f0100e6a <page_alloc>
f0101fd4:	83 c4 10             	add    $0x10,%esp
f0101fd7:	85 c0                	test   %eax,%eax
f0101fd9:	74 21                	je     f0101ffc <mem_init+0xde0>
f0101fdb:	8d 87 23 2c ed ff    	lea    -0x12d3dd(%edi),%eax
f0101fe1:	50                   	push   %eax
f0101fe2:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0101fe8:	50                   	push   %eax
f0101fe9:	68 4b 03 00 00       	push   $0x34b
f0101fee:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0101ff4:	50                   	push   %eax
f0101ff5:	89 fb                	mov    %edi,%ebx
f0101ff7:	e8 44 e0 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ffc:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f0102002:	8b 10                	mov    (%eax),%edx
f0102004:	8b 02                	mov    (%edx),%eax
f0102006:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010200b:	89 c3                	mov    %eax,%ebx
f010200d:	c1 eb 0c             	shr    $0xc,%ebx
f0102010:	c7 c1 08 6f 23 f0    	mov    $0xf0236f08,%ecx
f0102016:	3b 19                	cmp    (%ecx),%ebx
f0102018:	72 1b                	jb     f0102035 <mem_init+0xe19>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010201a:	50                   	push   %eax
f010201b:	8d 87 28 1f ed ff    	lea    -0x12e0d8(%edi),%eax
f0102021:	50                   	push   %eax
f0102022:	68 4e 03 00 00       	push   $0x34e
f0102027:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f010202d:	50                   	push   %eax
f010202e:	89 fb                	mov    %edi,%ebx
f0102030:	e8 0b e0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102035:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010203a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	assert(pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
f010203d:	83 ec 04             	sub    $0x4,%esp
f0102040:	6a 00                	push   $0x0
f0102042:	68 00 10 00 00       	push   $0x1000
f0102047:	52                   	push   %edx
f0102048:	e8 23 ef ff ff       	call   f0100f70 <pgdir_walk>
f010204d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102050:	8d 51 04             	lea    0x4(%ecx),%edx
f0102053:	83 c4 10             	add    $0x10,%esp
f0102056:	39 d0                	cmp    %edx,%eax
f0102058:	74 21                	je     f010207b <mem_init+0xe5f>
f010205a:	8d 87 ec 27 ed ff    	lea    -0x12d814(%edi),%eax
f0102060:	50                   	push   %eax
f0102061:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0102067:	50                   	push   %eax
f0102068:	68 4f 03 00 00       	push   $0x34f
f010206d:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0102073:	50                   	push   %eax
f0102074:	89 fb                	mov    %edi,%ebx
f0102076:	e8 c5 df ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W | PTE_U) == 0);
f010207b:	6a 06                	push   $0x6
f010207d:	68 00 10 00 00       	push   $0x1000
f0102082:	ff 75 d0             	pushl  -0x30(%ebp)
f0102085:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f010208b:	ff 30                	pushl  (%eax)
f010208d:	e8 d0 f0 ff ff       	call   f0101162 <page_insert>
f0102092:	83 c4 10             	add    $0x10,%esp
f0102095:	85 c0                	test   %eax,%eax
f0102097:	74 21                	je     f01020ba <mem_init+0xe9e>
f0102099:	8d 87 2c 28 ed ff    	lea    -0x12d7d4(%edi),%eax
f010209f:	50                   	push   %eax
f01020a0:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01020a6:	50                   	push   %eax
f01020a7:	68 52 03 00 00       	push   $0x352
f01020ac:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01020b2:	50                   	push   %eax
f01020b3:	89 fb                	mov    %edi,%ebx
f01020b5:	e8 86 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01020ba:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f01020c0:	8b 18                	mov    (%eax),%ebx
f01020c2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020c7:	89 d8                	mov    %ebx,%eax
f01020c9:	e8 29 ec ff ff       	call   f0100cf7 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f01020ce:	c7 c2 10 6f 23 f0    	mov    $0xf0236f10,%edx
f01020d4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01020d7:	2b 0a                	sub    (%edx),%ecx
f01020d9:	89 ca                	mov    %ecx,%edx
f01020db:	c1 fa 03             	sar    $0x3,%edx
f01020de:	c1 e2 0c             	shl    $0xc,%edx
f01020e1:	39 d0                	cmp    %edx,%eax
f01020e3:	74 21                	je     f0102106 <mem_init+0xeea>
f01020e5:	8d 87 bc 27 ed ff    	lea    -0x12d844(%edi),%eax
f01020eb:	50                   	push   %eax
f01020ec:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01020f2:	50                   	push   %eax
f01020f3:	68 53 03 00 00       	push   $0x353
f01020f8:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01020fe:	50                   	push   %eax
f01020ff:	89 fb                	mov    %edi,%ebx
f0102101:	e8 3a df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102106:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102109:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010210e:	74 21                	je     f0102131 <mem_init+0xf15>
f0102110:	8d 87 97 2c ed ff    	lea    -0x12d369(%edi),%eax
f0102116:	50                   	push   %eax
f0102117:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f010211d:	50                   	push   %eax
f010211e:	68 54 03 00 00       	push   $0x354
f0102123:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0102129:	50                   	push   %eax
f010212a:	89 fb                	mov    %edi,%ebx
f010212c:	e8 0f df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U);
f0102131:	83 ec 04             	sub    $0x4,%esp
f0102134:	6a 00                	push   $0x0
f0102136:	68 00 10 00 00       	push   $0x1000
f010213b:	53                   	push   %ebx
f010213c:	e8 2f ee ff ff       	call   f0100f70 <pgdir_walk>
f0102141:	83 c4 10             	add    $0x10,%esp
f0102144:	f6 00 04             	testb  $0x4,(%eax)
f0102147:	75 21                	jne    f010216a <mem_init+0xf4e>
f0102149:	8d 87 70 28 ed ff    	lea    -0x12d790(%edi),%eax
f010214f:	50                   	push   %eax
f0102150:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0102156:	50                   	push   %eax
f0102157:	68 55 03 00 00       	push   $0x355
f010215c:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0102162:	50                   	push   %eax
f0102163:	89 fb                	mov    %edi,%ebx
f0102165:	e8 d6 de ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010216a:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f0102170:	8b 00                	mov    (%eax),%eax
f0102172:	f6 00 04             	testb  $0x4,(%eax)
f0102175:	75 21                	jne    f0102198 <mem_init+0xf7c>
f0102177:	8d 87 a8 2c ed ff    	lea    -0x12d358(%edi),%eax
f010217d:	50                   	push   %eax
f010217e:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0102184:	50                   	push   %eax
f0102185:	68 56 03 00 00       	push   $0x356
f010218a:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0102190:	50                   	push   %eax
f0102191:	89 fb                	mov    %edi,%ebx
f0102193:	e8 a8 de ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0102198:	6a 02                	push   $0x2
f010219a:	68 00 10 00 00       	push   $0x1000
f010219f:	ff 75 d0             	pushl  -0x30(%ebp)
f01021a2:	50                   	push   %eax
f01021a3:	e8 ba ef ff ff       	call   f0101162 <page_insert>
f01021a8:	83 c4 10             	add    $0x10,%esp
f01021ab:	85 c0                	test   %eax,%eax
f01021ad:	74 21                	je     f01021d0 <mem_init+0xfb4>
f01021af:	8d 87 80 27 ed ff    	lea    -0x12d880(%edi),%eax
f01021b5:	50                   	push   %eax
f01021b6:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01021bc:	50                   	push   %eax
f01021bd:	68 59 03 00 00       	push   $0x359
f01021c2:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01021c8:	50                   	push   %eax
f01021c9:	89 fb                	mov    %edi,%ebx
f01021cb:	e8 70 de ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_W);
f01021d0:	83 ec 04             	sub    $0x4,%esp
f01021d3:	6a 00                	push   $0x0
f01021d5:	68 00 10 00 00       	push   $0x1000
f01021da:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f01021e0:	ff 30                	pushl  (%eax)
f01021e2:	e8 89 ed ff ff       	call   f0100f70 <pgdir_walk>
f01021e7:	83 c4 10             	add    $0x10,%esp
f01021ea:	f6 00 02             	testb  $0x2,(%eax)
f01021ed:	75 21                	jne    f0102210 <mem_init+0xff4>
f01021ef:	8d 87 a4 28 ed ff    	lea    -0x12d75c(%edi),%eax
f01021f5:	50                   	push   %eax
f01021f6:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01021fc:	50                   	push   %eax
f01021fd:	68 5a 03 00 00       	push   $0x35a
f0102202:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0102208:	50                   	push   %eax
f0102209:	89 fb                	mov    %edi,%ebx
f010220b:	e8 30 de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0102210:	83 ec 04             	sub    $0x4,%esp
f0102213:	6a 00                	push   $0x0
f0102215:	68 00 10 00 00       	push   $0x1000
f010221a:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f0102220:	ff 30                	pushl  (%eax)
f0102222:	e8 49 ed ff ff       	call   f0100f70 <pgdir_walk>
f0102227:	83 c4 10             	add    $0x10,%esp
f010222a:	f6 00 04             	testb  $0x4,(%eax)
f010222d:	74 21                	je     f0102250 <mem_init+0x1034>
f010222f:	8d 87 d8 28 ed ff    	lea    -0x12d728(%edi),%eax
f0102235:	50                   	push   %eax
f0102236:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f010223c:	50                   	push   %eax
f010223d:	68 5b 03 00 00       	push   $0x35b
f0102242:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0102248:	50                   	push   %eax
f0102249:	89 fb                	mov    %edi,%ebx
f010224b:	e8 f0 dd ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void *)PTSIZE, PTE_W) < 0);
f0102250:	6a 02                	push   $0x2
f0102252:	68 00 00 40 00       	push   $0x400000
f0102257:	56                   	push   %esi
f0102258:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f010225e:	ff 30                	pushl  (%eax)
f0102260:	e8 fd ee ff ff       	call   f0101162 <page_insert>
f0102265:	83 c4 10             	add    $0x10,%esp
f0102268:	85 c0                	test   %eax,%eax
f010226a:	78 21                	js     f010228d <mem_init+0x1071>
f010226c:	8d 87 10 29 ed ff    	lea    -0x12d6f0(%edi),%eax
f0102272:	50                   	push   %eax
f0102273:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0102279:	50                   	push   %eax
f010227a:	68 5e 03 00 00       	push   $0x35e
f010227f:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0102285:	50                   	push   %eax
f0102286:	89 fb                	mov    %edi,%ebx
f0102288:	e8 b3 dd ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W) == 0);
f010228d:	6a 02                	push   $0x2
f010228f:	68 00 10 00 00       	push   $0x1000
f0102294:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102297:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f010229d:	ff 30                	pushl  (%eax)
f010229f:	e8 be ee ff ff       	call   f0101162 <page_insert>
f01022a4:	83 c4 10             	add    $0x10,%esp
f01022a7:	85 c0                	test   %eax,%eax
f01022a9:	74 21                	je     f01022cc <mem_init+0x10b0>
f01022ab:	8d 87 48 29 ed ff    	lea    -0x12d6b8(%edi),%eax
f01022b1:	50                   	push   %eax
f01022b2:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01022b8:	50                   	push   %eax
f01022b9:	68 61 03 00 00       	push   $0x361
f01022be:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01022c4:	50                   	push   %eax
f01022c5:	89 fb                	mov    %edi,%ebx
f01022c7:	e8 74 dd ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f01022cc:	83 ec 04             	sub    $0x4,%esp
f01022cf:	6a 00                	push   $0x0
f01022d1:	68 00 10 00 00       	push   $0x1000
f01022d6:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f01022dc:	ff 30                	pushl  (%eax)
f01022de:	e8 8d ec ff ff       	call   f0100f70 <pgdir_walk>
f01022e3:	83 c4 10             	add    $0x10,%esp
f01022e6:	f6 00 04             	testb  $0x4,(%eax)
f01022e9:	74 21                	je     f010230c <mem_init+0x10f0>
f01022eb:	8d 87 d8 28 ed ff    	lea    -0x12d728(%edi),%eax
f01022f1:	50                   	push   %eax
f01022f2:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01022f8:	50                   	push   %eax
f01022f9:	68 62 03 00 00       	push   $0x362
f01022fe:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0102304:	50                   	push   %eax
f0102305:	89 fb                	mov    %edi,%ebx
f0102307:	e8 34 dd ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010230c:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f0102312:	8b 18                	mov    (%eax),%ebx
f0102314:	ba 00 00 00 00       	mov    $0x0,%edx
f0102319:	89 d8                	mov    %ebx,%eax
f010231b:	e8 d7 e9 ff ff       	call   f0100cf7 <check_va2pa>
f0102320:	89 c2                	mov    %eax,%edx
f0102322:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102325:	c7 c0 10 6f 23 f0    	mov    $0xf0236f10,%eax
f010232b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010232e:	2b 08                	sub    (%eax),%ecx
f0102330:	89 c8                	mov    %ecx,%eax
f0102332:	c1 f8 03             	sar    $0x3,%eax
f0102335:	c1 e0 0c             	shl    $0xc,%eax
f0102338:	39 c2                	cmp    %eax,%edx
f010233a:	74 21                	je     f010235d <mem_init+0x1141>
f010233c:	8d 87 84 29 ed ff    	lea    -0x12d67c(%edi),%eax
f0102342:	50                   	push   %eax
f0102343:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0102349:	50                   	push   %eax
f010234a:	68 65 03 00 00       	push   $0x365
f010234f:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0102355:	50                   	push   %eax
f0102356:	89 fb                	mov    %edi,%ebx
f0102358:	e8 e3 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010235d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102362:	89 d8                	mov    %ebx,%eax
f0102364:	e8 8e e9 ff ff       	call   f0100cf7 <check_va2pa>
f0102369:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f010236c:	74 21                	je     f010238f <mem_init+0x1173>
f010236e:	8d 87 b0 29 ed ff    	lea    -0x12d650(%edi),%eax
f0102374:	50                   	push   %eax
f0102375:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f010237b:	50                   	push   %eax
f010237c:	68 66 03 00 00       	push   $0x366
f0102381:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0102387:	50                   	push   %eax
f0102388:	89 fb                	mov    %edi,%ebx
f010238a:	e8 b1 dc ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010238f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102392:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f0102397:	74 21                	je     f01023ba <mem_init+0x119e>
f0102399:	8d 87 be 2c ed ff    	lea    -0x12d342(%edi),%eax
f010239f:	50                   	push   %eax
f01023a0:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01023a6:	50                   	push   %eax
f01023a7:	68 68 03 00 00       	push   $0x368
f01023ac:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01023b2:	50                   	push   %eax
f01023b3:	89 fb                	mov    %edi,%ebx
f01023b5:	e8 86 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01023ba:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01023bd:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01023c2:	74 21                	je     f01023e5 <mem_init+0x11c9>
f01023c4:	8d 87 cf 2c ed ff    	lea    -0x12d331(%edi),%eax
f01023ca:	50                   	push   %eax
f01023cb:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01023d1:	50                   	push   %eax
f01023d2:	68 69 03 00 00       	push   $0x369
f01023d7:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01023dd:	50                   	push   %eax
f01023de:	89 fb                	mov    %edi,%ebx
f01023e0:	e8 5b dc ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01023e5:	83 ec 0c             	sub    $0xc,%esp
f01023e8:	6a 00                	push   $0x0
f01023ea:	e8 7b ea ff ff       	call   f0100e6a <page_alloc>
f01023ef:	83 c4 10             	add    $0x10,%esp
f01023f2:	85 c0                	test   %eax,%eax
f01023f4:	74 05                	je     f01023fb <mem_init+0x11df>
f01023f6:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01023f9:	74 21                	je     f010241c <mem_init+0x1200>
f01023fb:	8d 87 e0 29 ed ff    	lea    -0x12d620(%edi),%eax
f0102401:	50                   	push   %eax
f0102402:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0102408:	50                   	push   %eax
f0102409:	68 6c 03 00 00       	push   $0x36c
f010240e:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0102414:	50                   	push   %eax
f0102415:	89 fb                	mov    %edi,%ebx
f0102417:	e8 24 dc ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010241c:	83 ec 08             	sub    $0x8,%esp
f010241f:	6a 00                	push   $0x0
f0102421:	c7 c3 0c 6f 23 f0    	mov    $0xf0236f0c,%ebx
f0102427:	ff 33                	pushl  (%ebx)
f0102429:	e8 ee ec ff ff       	call   f010111c <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010242e:	8b 1b                	mov    (%ebx),%ebx
f0102430:	ba 00 00 00 00       	mov    $0x0,%edx
f0102435:	89 d8                	mov    %ebx,%eax
f0102437:	e8 bb e8 ff ff       	call   f0100cf7 <check_va2pa>
f010243c:	83 c4 10             	add    $0x10,%esp
f010243f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102442:	74 21                	je     f0102465 <mem_init+0x1249>
f0102444:	8d 87 04 2a ed ff    	lea    -0x12d5fc(%edi),%eax
f010244a:	50                   	push   %eax
f010244b:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0102451:	50                   	push   %eax
f0102452:	68 70 03 00 00       	push   $0x370
f0102457:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f010245d:	50                   	push   %eax
f010245e:	89 fb                	mov    %edi,%ebx
f0102460:	e8 db db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102465:	ba 00 10 00 00       	mov    $0x1000,%edx
f010246a:	89 d8                	mov    %ebx,%eax
f010246c:	e8 86 e8 ff ff       	call   f0100cf7 <check_va2pa>
f0102471:	c7 c2 10 6f 23 f0    	mov    $0xf0236f10,%edx
f0102477:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010247a:	2b 0a                	sub    (%edx),%ecx
f010247c:	89 ca                	mov    %ecx,%edx
f010247e:	c1 fa 03             	sar    $0x3,%edx
f0102481:	c1 e2 0c             	shl    $0xc,%edx
f0102484:	39 d0                	cmp    %edx,%eax
f0102486:	74 21                	je     f01024a9 <mem_init+0x128d>
f0102488:	8d 87 b0 29 ed ff    	lea    -0x12d650(%edi),%eax
f010248e:	50                   	push   %eax
f010248f:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0102495:	50                   	push   %eax
f0102496:	68 71 03 00 00       	push   $0x371
f010249b:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01024a1:	50                   	push   %eax
f01024a2:	89 fb                	mov    %edi,%ebx
f01024a4:	e8 97 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01024a9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024ac:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01024b1:	74 21                	je     f01024d4 <mem_init+0x12b8>
f01024b3:	8d 87 75 2c ed ff    	lea    -0x12d38b(%edi),%eax
f01024b9:	50                   	push   %eax
f01024ba:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01024c0:	50                   	push   %eax
f01024c1:	68 72 03 00 00       	push   $0x372
f01024c6:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01024cc:	50                   	push   %eax
f01024cd:	89 fb                	mov    %edi,%ebx
f01024cf:	e8 6c db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01024d4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01024d7:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01024dc:	74 21                	je     f01024ff <mem_init+0x12e3>
f01024de:	8d 87 cf 2c ed ff    	lea    -0x12d331(%edi),%eax
f01024e4:	50                   	push   %eax
f01024e5:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01024eb:	50                   	push   %eax
f01024ec:	68 73 03 00 00       	push   $0x373
f01024f1:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01024f7:	50                   	push   %eax
f01024f8:	89 fb                	mov    %edi,%ebx
f01024fa:	e8 41 db ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, 0) == 0);
f01024ff:	6a 00                	push   $0x0
f0102501:	68 00 10 00 00       	push   $0x1000
f0102506:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102509:	53                   	push   %ebx
f010250a:	e8 53 ec ff ff       	call   f0101162 <page_insert>
f010250f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102512:	83 c4 10             	add    $0x10,%esp
f0102515:	85 c0                	test   %eax,%eax
f0102517:	74 21                	je     f010253a <mem_init+0x131e>
f0102519:	8d 87 28 2a ed ff    	lea    -0x12d5d8(%edi),%eax
f010251f:	50                   	push   %eax
f0102520:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0102526:	50                   	push   %eax
f0102527:	68 76 03 00 00       	push   $0x376
f010252c:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0102532:	50                   	push   %eax
f0102533:	89 fb                	mov    %edi,%ebx
f0102535:	e8 06 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f010253a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010253d:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102542:	75 21                	jne    f0102565 <mem_init+0x1349>
f0102544:	8d 87 e0 2c ed ff    	lea    -0x12d320(%edi),%eax
f010254a:	50                   	push   %eax
f010254b:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0102551:	50                   	push   %eax
f0102552:	68 77 03 00 00       	push   $0x377
f0102557:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f010255d:	50                   	push   %eax
f010255e:	89 fb                	mov    %edi,%ebx
f0102560:	e8 db da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102565:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102568:	83 38 00             	cmpl   $0x0,(%eax)
f010256b:	74 21                	je     f010258e <mem_init+0x1372>
f010256d:	8d 87 ec 2c ed ff    	lea    -0x12d314(%edi),%eax
f0102573:	50                   	push   %eax
f0102574:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f010257a:	50                   	push   %eax
f010257b:	68 78 03 00 00       	push   $0x378
f0102580:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0102586:	50                   	push   %eax
f0102587:	89 fb                	mov    %edi,%ebx
f0102589:	e8 b2 da ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void *)PGSIZE);
f010258e:	83 ec 08             	sub    $0x8,%esp
f0102591:	68 00 10 00 00       	push   $0x1000
f0102596:	c7 c3 0c 6f 23 f0    	mov    $0xf0236f0c,%ebx
f010259c:	ff 33                	pushl  (%ebx)
f010259e:	e8 79 eb ff ff       	call   f010111c <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025a3:	8b 1b                	mov    (%ebx),%ebx
f01025a5:	ba 00 00 00 00       	mov    $0x0,%edx
f01025aa:	89 d8                	mov    %ebx,%eax
f01025ac:	e8 46 e7 ff ff       	call   f0100cf7 <check_va2pa>
f01025b1:	83 c4 10             	add    $0x10,%esp
f01025b4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025b7:	74 21                	je     f01025da <mem_init+0x13be>
f01025b9:	8d 87 04 2a ed ff    	lea    -0x12d5fc(%edi),%eax
f01025bf:	50                   	push   %eax
f01025c0:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01025c6:	50                   	push   %eax
f01025c7:	68 7c 03 00 00       	push   $0x37c
f01025cc:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01025d2:	50                   	push   %eax
f01025d3:	89 fb                	mov    %edi,%ebx
f01025d5:	e8 66 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01025da:	ba 00 10 00 00       	mov    $0x1000,%edx
f01025df:	89 d8                	mov    %ebx,%eax
f01025e1:	e8 11 e7 ff ff       	call   f0100cf7 <check_va2pa>
f01025e6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025e9:	74 21                	je     f010260c <mem_init+0x13f0>
f01025eb:	8d 87 60 2a ed ff    	lea    -0x12d5a0(%edi),%eax
f01025f1:	50                   	push   %eax
f01025f2:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01025f8:	50                   	push   %eax
f01025f9:	68 7d 03 00 00       	push   $0x37d
f01025fe:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0102604:	50                   	push   %eax
f0102605:	89 fb                	mov    %edi,%ebx
f0102607:	e8 34 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010260c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010260f:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102614:	74 21                	je     f0102637 <mem_init+0x141b>
f0102616:	8d 87 01 2d ed ff    	lea    -0x12d2ff(%edi),%eax
f010261c:	50                   	push   %eax
f010261d:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0102623:	50                   	push   %eax
f0102624:	68 7e 03 00 00       	push   $0x37e
f0102629:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f010262f:	50                   	push   %eax
f0102630:	89 fb                	mov    %edi,%ebx
f0102632:	e8 09 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102637:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010263a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010263f:	74 21                	je     f0102662 <mem_init+0x1446>
f0102641:	8d 87 cf 2c ed ff    	lea    -0x12d331(%edi),%eax
f0102647:	50                   	push   %eax
f0102648:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f010264e:	50                   	push   %eax
f010264f:	68 7f 03 00 00       	push   $0x37f
f0102654:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f010265a:	50                   	push   %eax
f010265b:	89 fb                	mov    %edi,%ebx
f010265d:	e8 de d9 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102662:	83 ec 0c             	sub    $0xc,%esp
f0102665:	6a 00                	push   $0x0
f0102667:	e8 fe e7 ff ff       	call   f0100e6a <page_alloc>
f010266c:	83 c4 10             	add    $0x10,%esp
f010266f:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0102672:	75 04                	jne    f0102678 <mem_init+0x145c>
f0102674:	85 c0                	test   %eax,%eax
f0102676:	75 21                	jne    f0102699 <mem_init+0x147d>
f0102678:	8d 87 88 2a ed ff    	lea    -0x12d578(%edi),%eax
f010267e:	50                   	push   %eax
f010267f:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0102685:	50                   	push   %eax
f0102686:	68 82 03 00 00       	push   $0x382
f010268b:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0102691:	50                   	push   %eax
f0102692:	89 fb                	mov    %edi,%ebx
f0102694:	e8 a7 d9 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102699:	83 ec 0c             	sub    $0xc,%esp
f010269c:	6a 00                	push   $0x0
f010269e:	e8 c7 e7 ff ff       	call   f0100e6a <page_alloc>
f01026a3:	83 c4 10             	add    $0x10,%esp
f01026a6:	85 c0                	test   %eax,%eax
f01026a8:	74 21                	je     f01026cb <mem_init+0x14af>
f01026aa:	8d 87 23 2c ed ff    	lea    -0x12d3dd(%edi),%eax
f01026b0:	50                   	push   %eax
f01026b1:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01026b7:	50                   	push   %eax
f01026b8:	68 85 03 00 00       	push   $0x385
f01026bd:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01026c3:	50                   	push   %eax
f01026c4:	89 fb                	mov    %edi,%ebx
f01026c6:	e8 75 d9 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026cb:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f01026d1:	8b 08                	mov    (%eax),%ecx
f01026d3:	8b 11                	mov    (%ecx),%edx
f01026d5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01026db:	c7 c0 10 6f 23 f0    	mov    $0xf0236f10,%eax
f01026e1:	89 f3                	mov    %esi,%ebx
f01026e3:	2b 18                	sub    (%eax),%ebx
f01026e5:	89 d8                	mov    %ebx,%eax
f01026e7:	c1 f8 03             	sar    $0x3,%eax
f01026ea:	c1 e0 0c             	shl    $0xc,%eax
f01026ed:	39 c2                	cmp    %eax,%edx
f01026ef:	74 21                	je     f0102712 <mem_init+0x14f6>
f01026f1:	8d 87 28 27 ed ff    	lea    -0x12d8d8(%edi),%eax
f01026f7:	50                   	push   %eax
f01026f8:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01026fe:	50                   	push   %eax
f01026ff:	68 88 03 00 00       	push   $0x388
f0102704:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f010270a:	50                   	push   %eax
f010270b:	89 fb                	mov    %edi,%ebx
f010270d:	e8 2e d9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102712:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102718:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010271d:	74 21                	je     f0102740 <mem_init+0x1524>
f010271f:	8d 87 86 2c ed ff    	lea    -0x12d37a(%edi),%eax
f0102725:	50                   	push   %eax
f0102726:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f010272c:	50                   	push   %eax
f010272d:	68 8a 03 00 00       	push   $0x38a
f0102732:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0102738:	50                   	push   %eax
f0102739:	89 fb                	mov    %edi,%ebx
f010273b:	e8 00 d9 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102740:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102746:	83 ec 0c             	sub    $0xc,%esp
f0102749:	56                   	push   %esi
f010274a:	e8 a9 e7 ff ff       	call   f0100ef8 <page_free>
	va = (void *)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010274f:	83 c4 0c             	add    $0xc,%esp
f0102752:	6a 01                	push   $0x1
f0102754:	68 00 10 40 00       	push   $0x401000
f0102759:	c7 c3 0c 6f 23 f0    	mov    $0xf0236f0c,%ebx
f010275f:	ff 33                	pushl  (%ebx)
f0102761:	e8 0a e8 ff ff       	call   f0100f70 <pgdir_walk>
f0102766:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102769:	89 45 e0             	mov    %eax,-0x20(%ebp)
	ptep1 = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010276c:	8b 1b                	mov    (%ebx),%ebx
f010276e:	8b 43 04             	mov    0x4(%ebx),%eax
f0102771:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0102776:	89 c2                	mov    %eax,%edx
f0102778:	c1 ea 0c             	shr    $0xc,%edx
f010277b:	89 d1                	mov    %edx,%ecx
f010277d:	83 c4 10             	add    $0x10,%esp
f0102780:	c7 c2 08 6f 23 f0    	mov    $0xf0236f08,%edx
f0102786:	3b 0a                	cmp    (%edx),%ecx
f0102788:	72 1b                	jb     f01027a5 <mem_init+0x1589>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010278a:	50                   	push   %eax
f010278b:	8d 87 28 1f ed ff    	lea    -0x12e0d8(%edi),%eax
f0102791:	50                   	push   %eax
f0102792:	68 91 03 00 00       	push   $0x391
f0102797:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f010279d:	50                   	push   %eax
f010279e:	89 fb                	mov    %edi,%ebx
f01027a0:	e8 9b d8 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01027a5:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01027aa:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f01027ad:	74 21                	je     f01027d0 <mem_init+0x15b4>
f01027af:	8d 87 12 2d ed ff    	lea    -0x12d2ee(%edi),%eax
f01027b5:	50                   	push   %eax
f01027b6:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f01027bc:	50                   	push   %eax
f01027bd:	68 92 03 00 00       	push   $0x392
f01027c2:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f01027c8:	50                   	push   %eax
f01027c9:	89 fb                	mov    %edi,%ebx
f01027cb:	e8 70 d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01027d0:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f01027d7:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01027dd:	89 f0                	mov    %esi,%eax
f01027df:	e8 c2 e4 ff ff       	call   f0100ca6 <page2kva>
f01027e4:	83 ec 04             	sub    $0x4,%esp
f01027e7:	68 00 10 00 00       	push   $0x1000
f01027ec:	68 ff 00 00 00       	push   $0xff
f01027f1:	50                   	push   %eax
f01027f2:	89 fb                	mov    %edi,%ebx
f01027f4:	e8 e3 24 00 00       	call   f0104cdc <memset>
	page_free(pp0);
f01027f9:	89 34 24             	mov    %esi,(%esp)
f01027fc:	e8 f7 e6 ff ff       	call   f0100ef8 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102801:	83 c4 0c             	add    $0xc,%esp
f0102804:	6a 01                	push   $0x1
f0102806:	6a 00                	push   $0x0
f0102808:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f010280e:	ff 30                	pushl  (%eax)
f0102810:	e8 5b e7 ff ff       	call   f0100f70 <pgdir_walk>
	ptep = (pte_t *)page2kva(pp0);
f0102815:	89 f0                	mov    %esi,%eax
f0102817:	e8 8a e4 ff ff       	call   f0100ca6 <page2kva>
f010281c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010281f:	83 c4 10             	add    $0x10,%esp
f0102822:	8b 55 c4             	mov    -0x3c(%ebp),%edx
	for (i = 0; i < NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102825:	f6 04 90 01          	testb  $0x1,(%eax,%edx,4)
f0102829:	74 21                	je     f010284c <mem_init+0x1630>
f010282b:	8d 87 2a 2d ed ff    	lea    -0x12d2d6(%edi),%eax
f0102831:	50                   	push   %eax
f0102832:	8d 87 07 2b ed ff    	lea    -0x12d4f9(%edi),%eax
f0102838:	50                   	push   %eax
f0102839:	68 9c 03 00 00       	push   $0x39c
f010283e:	8d 87 e1 2a ed ff    	lea    -0x12d51f(%edi),%eax
f0102844:	50                   	push   %eax
f0102845:	89 fb                	mov    %edi,%ebx
f0102847:	e8 f4 d7 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < NPTENTRIES; i++)
f010284c:	83 c2 01             	add    $0x1,%edx
f010284f:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0102855:	75 ce                	jne    f0102825 <mem_init+0x1609>
	kern_pgdir[0] = 0;
f0102857:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f010285d:	8b 00                	mov    (%eax),%eax
f010285f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102865:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f010286b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010286e:	89 87 64 26 00 00    	mov    %eax,0x2664(%edi)

	// free the pages we took
	page_free(pp0);
f0102874:	83 ec 0c             	sub    $0xc,%esp
f0102877:	56                   	push   %esi
f0102878:	e8 7b e6 ff ff       	call   f0100ef8 <page_free>
	page_free(pp1);
f010287d:	83 c4 04             	add    $0x4,%esp
f0102880:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102883:	e8 70 e6 ff ff       	call   f0100ef8 <page_free>
	page_free(pp2);
f0102888:	83 c4 04             	add    $0x4,%esp
f010288b:	ff 75 d0             	pushl  -0x30(%ebp)
f010288e:	e8 65 e6 ff ff       	call   f0100ef8 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102893:	83 c4 08             	add    $0x8,%esp
f0102896:	68 01 10 00 00       	push   $0x1001
f010289b:	6a 00                	push   $0x0
f010289d:	e8 50 e9 ff ff       	call   f01011f2 <mmio_map_region>

f01028a2 <user_mem_check>:
{
f01028a2:	55                   	push   %ebp
f01028a3:	89 e5                	mov    %esp,%ebp
f01028a5:	57                   	push   %edi
f01028a6:	56                   	push   %esi
f01028a7:	53                   	push   %ebx
f01028a8:	83 ec 1c             	sub    $0x1c,%esp
f01028ab:	e8 c2 df ff ff       	call   f0100872 <__x86.get_pc_thunk.ax>
f01028b0:	05 2c 13 13 00       	add    $0x13132c,%eax
f01028b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	const void *start = ROUNDDOWN(va, PGSIZE);
f01028b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01028bb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	const void *end = ROUNDUP(va + len, PGSIZE);
f01028c1:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01028c4:	03 7d 10             	add    0x10(%ebp),%edi
f01028c7:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f01028cd:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
		if (!pte || (*pte & (perm | PTE_P)) != (perm | PTE_P)) // 确认权限，&操作可以得到那几个权限位来判断
f01028d3:	8b 75 14             	mov    0x14(%ebp),%esi
f01028d6:	83 ce 01             	or     $0x1,%esi
	for (; start < end; start += PGSIZE) // 遍历每一页
f01028d9:	39 fb                	cmp    %edi,%ebx
f01028db:	73 45                	jae    f0102922 <user_mem_check+0x80>
		pte_t *pte = pgdir_walk(env->env_pgdir, start, 0);	   // 找到pte,pte只能在ULIM下方，因此若pte存在，则地址存在
f01028dd:	83 ec 04             	sub    $0x4,%esp
f01028e0:	6a 00                	push   $0x0
f01028e2:	53                   	push   %ebx
f01028e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01028e6:	ff 70 60             	pushl  0x60(%eax)
f01028e9:	e8 82 e6 ff ff       	call   f0100f70 <pgdir_walk>
		if (!pte || (*pte & (perm | PTE_P)) != (perm | PTE_P)) // 确认权限，&操作可以得到那几个权限位来判断
f01028ee:	83 c4 10             	add    $0x10,%esp
f01028f1:	85 c0                	test   %eax,%eax
f01028f3:	74 10                	je     f0102905 <user_mem_check+0x63>
f01028f5:	89 f2                	mov    %esi,%edx
f01028f7:	23 10                	and    (%eax),%edx
f01028f9:	39 d6                	cmp    %edx,%esi
f01028fb:	75 08                	jne    f0102905 <user_mem_check+0x63>
	for (; start < end; start += PGSIZE) // 遍历每一页
f01028fd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102903:	eb d4                	jmp    f01028d9 <user_mem_check+0x37>
			user_mem_check_addr = (uintptr_t)MAX(start, va); // 第一个错误的虚拟地址
f0102905:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102908:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f010290c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010290f:	89 98 60 26 00 00    	mov    %ebx,0x2660(%eax)
			return -E_FAULT;								 // 提前返回
f0102915:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f010291a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010291d:	5b                   	pop    %ebx
f010291e:	5e                   	pop    %esi
f010291f:	5f                   	pop    %edi
f0102920:	5d                   	pop    %ebp
f0102921:	c3                   	ret    
	return 0;
f0102922:	b8 00 00 00 00       	mov    $0x0,%eax
f0102927:	eb f1                	jmp    f010291a <user_mem_check+0x78>

f0102929 <user_mem_assert>:
{
f0102929:	55                   	push   %ebp
f010292a:	89 e5                	mov    %esp,%ebp
f010292c:	56                   	push   %esi
f010292d:	53                   	push   %ebx
f010292e:	e8 7e d9 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0102933:	81 c3 a9 12 13 00    	add    $0x1312a9,%ebx
f0102939:	8b 75 08             	mov    0x8(%ebp),%esi
	if (user_mem_check(env, va, len, perm | PTE_U) < 0)
f010293c:	8b 45 14             	mov    0x14(%ebp),%eax
f010293f:	83 c8 04             	or     $0x4,%eax
f0102942:	50                   	push   %eax
f0102943:	ff 75 10             	pushl  0x10(%ebp)
f0102946:	ff 75 0c             	pushl  0xc(%ebp)
f0102949:	56                   	push   %esi
f010294a:	e8 53 ff ff ff       	call   f01028a2 <user_mem_check>
f010294f:	83 c4 10             	add    $0x10,%esp
f0102952:	85 c0                	test   %eax,%eax
f0102954:	78 07                	js     f010295d <user_mem_assert+0x34>
}
f0102956:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0102959:	5b                   	pop    %ebx
f010295a:	5e                   	pop    %esi
f010295b:	5d                   	pop    %ebp
f010295c:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f010295d:	83 ec 04             	sub    $0x4,%esp
f0102960:	ff b3 60 26 00 00    	pushl  0x2660(%ebx)
f0102966:	ff 76 48             	pushl  0x48(%esi)
f0102969:	8d 83 ac 2a ed ff    	lea    -0x12d554(%ebx),%eax
f010296f:	50                   	push   %eax
f0102970:	e8 8a 0a 00 00       	call   f01033ff <cprintf>
		env_destroy(env); // may not return
f0102975:	89 34 24             	mov    %esi,(%esp)
f0102978:	e8 36 07 00 00       	call   f01030b3 <env_destroy>
f010297d:	83 c4 10             	add    $0x10,%esp
}
f0102980:	eb d4                	jmp    f0102956 <user_mem_assert+0x2d>

f0102982 <__x86.get_pc_thunk.dx>:
f0102982:	8b 14 24             	mov    (%esp),%edx
f0102985:	c3                   	ret    

f0102986 <__x86.get_pc_thunk.si>:
f0102986:	8b 34 24             	mov    (%esp),%esi
f0102989:	c3                   	ret    

f010298a <__x86.get_pc_thunk.di>:
f010298a:	8b 3c 24             	mov    (%esp),%edi
f010298d:	c3                   	ret    

f010298e <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
// 为环境 env 分配 len 字节的物理内存，并将其映射到环境地址空间中的虚拟地址 va。
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010298e:	55                   	push   %ebp
f010298f:	89 e5                	mov    %esp,%ebp
f0102991:	57                   	push   %edi
f0102992:	56                   	push   %esi
f0102993:	53                   	push   %ebx
f0102994:	83 ec 1c             	sub    $0x1c,%esp
f0102997:	e8 15 d9 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f010299c:	81 c3 40 12 13 00    	add    $0x131240,%ebx
f01029a2:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *start = ROUNDDOWN(va, PGSIZE);
f01029a4:	89 d6                	mov    %edx,%esi
f01029a6:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	void *end = ROUNDUP(va + len, PGSIZE);
f01029ac:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f01029b3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01029b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (; start < end; start += PGSIZE)
f01029bb:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01029be:	73 62                	jae    f0102a22 <region_alloc+0x94>
	{
		struct PageInfo *p = page_alloc(0);
f01029c0:	83 ec 0c             	sub    $0xc,%esp
f01029c3:	6a 00                	push   $0x0
f01029c5:	e8 a0 e4 ff ff       	call   f0100e6a <page_alloc>
		if (p == NULL)
f01029ca:	83 c4 10             	add    $0x10,%esp
f01029cd:	85 c0                	test   %eax,%eax
f01029cf:	74 1b                	je     f01029ec <region_alloc+0x5e>
		{
			panic("region_alloc: error in page_alloc()\n"); // 分配失败
		}
		if (page_insert(e->env_pgdir, p, start, PTE_W | PTE_U))
f01029d1:	6a 06                	push   $0x6
f01029d3:	56                   	push   %esi
f01029d4:	50                   	push   %eax
f01029d5:	ff 77 60             	pushl  0x60(%edi)
f01029d8:	e8 85 e7 ff ff       	call   f0101162 <page_insert>
f01029dd:	83 c4 10             	add    $0x10,%esp
f01029e0:	85 c0                	test   %eax,%eax
f01029e2:	75 23                	jne    f0102a07 <region_alloc+0x79>
	for (; start < end; start += PGSIZE)
f01029e4:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01029ea:	eb cf                	jmp    f01029bb <region_alloc+0x2d>
			panic("region_alloc: error in page_alloc()\n"); // 分配失败
f01029ec:	83 ec 04             	sub    $0x4,%esp
f01029ef:	8d 83 44 2d ed ff    	lea    -0x12d2bc(%ebx),%eax
f01029f5:	50                   	push   %eax
f01029f6:	68 37 01 00 00       	push   $0x137
f01029fb:	8d 83 dd 2d ed ff    	lea    -0x12d223(%ebx),%eax
f0102a01:	50                   	push   %eax
f0102a02:	e8 39 d6 ff ff       	call   f0100040 <_panic>
		{
			panic("region_alloc: error in page_insert()\n"); // 插入失败
f0102a07:	83 ec 04             	sub    $0x4,%esp
f0102a0a:	8d 83 6c 2d ed ff    	lea    -0x12d294(%ebx),%eax
f0102a10:	50                   	push   %eax
f0102a11:	68 3b 01 00 00       	push   $0x13b
f0102a16:	8d 83 dd 2d ed ff    	lea    -0x12d223(%ebx),%eax
f0102a1c:	50                   	push   %eax
f0102a1d:	e8 1e d6 ff ff       	call   f0100040 <_panic>
		}
	}
}
f0102a22:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102a25:	5b                   	pop    %ebx
f0102a26:	5e                   	pop    %esi
f0102a27:	5f                   	pop    %edi
f0102a28:	5d                   	pop    %ebp
f0102a29:	c3                   	ret    

f0102a2a <envid2env>:
{
f0102a2a:	55                   	push   %ebp
f0102a2b:	89 e5                	mov    %esp,%ebp
f0102a2d:	57                   	push   %edi
f0102a2e:	56                   	push   %esi
f0102a2f:	53                   	push   %ebx
f0102a30:	83 ec 0c             	sub    $0xc,%esp
f0102a33:	e8 79 d8 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0102a38:	81 c3 a4 11 13 00    	add    $0x1311a4,%ebx
f0102a3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a41:	8b 55 10             	mov    0x10(%ebp),%edx
	if (envid == 0)
f0102a44:	85 c0                	test   %eax,%eax
f0102a46:	74 32                	je     f0102a7a <envid2env+0x50>
	e = &envs[ENVX(envid)];
f0102a48:	89 c6                	mov    %eax,%esi
f0102a4a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0102a50:	6b f6 7c             	imul   $0x7c,%esi,%esi
f0102a53:	03 b3 6c 26 00 00    	add    0x266c(%ebx),%esi
	if (e->env_status == ENV_FREE || e->env_id != envid)
f0102a59:	83 7e 54 00          	cmpl   $0x0,0x54(%esi)
f0102a5d:	74 38                	je     f0102a97 <envid2env+0x6d>
f0102a5f:	39 46 48             	cmp    %eax,0x48(%esi)
f0102a62:	75 33                	jne    f0102a97 <envid2env+0x6d>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id)
f0102a64:	84 d2                	test   %dl,%dl
f0102a66:	75 3f                	jne    f0102aa7 <envid2env+0x7d>
	*env_store = e;
f0102a68:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102a6b:	89 30                	mov    %esi,(%eax)
	return 0;
f0102a6d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102a72:	83 c4 0c             	add    $0xc,%esp
f0102a75:	5b                   	pop    %ebx
f0102a76:	5e                   	pop    %esi
f0102a77:	5f                   	pop    %edi
f0102a78:	5d                   	pop    %ebp
f0102a79:	c3                   	ret    
		*env_store = curenv;
f0102a7a:	e8 1c 29 00 00       	call   f010539b <cpunum>
f0102a7f:	6b c0 74             	imul   $0x74,%eax,%eax
f0102a82:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0102a88:	8b 40 08             	mov    0x8(%eax),%eax
f0102a8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102a8e:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102a90:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a95:	eb db                	jmp    f0102a72 <envid2env+0x48>
		*env_store = 0;
f0102a97:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102a9a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102aa0:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102aa5:	eb cb                	jmp    f0102a72 <envid2env+0x48>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id)
f0102aa7:	e8 ef 28 00 00       	call   f010539b <cpunum>
f0102aac:	6b c0 74             	imul   $0x74,%eax,%eax
f0102aaf:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0102ab5:	39 70 08             	cmp    %esi,0x8(%eax)
f0102ab8:	74 ae                	je     f0102a68 <envid2env+0x3e>
f0102aba:	8b 7e 4c             	mov    0x4c(%esi),%edi
f0102abd:	e8 d9 28 00 00       	call   f010539b <cpunum>
f0102ac2:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ac5:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0102acb:	8b 40 08             	mov    0x8(%eax),%eax
f0102ace:	3b 78 48             	cmp    0x48(%eax),%edi
f0102ad1:	74 95                	je     f0102a68 <envid2env+0x3e>
		*env_store = 0;
f0102ad3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ad6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102adc:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102ae1:	eb 8f                	jmp    f0102a72 <envid2env+0x48>

f0102ae3 <env_init_percpu>:
{
f0102ae3:	55                   	push   %ebp
f0102ae4:	89 e5                	mov    %esp,%ebp
f0102ae6:	e8 87 dd ff ff       	call   f0100872 <__x86.get_pc_thunk.ax>
f0102aeb:	05 f1 10 13 00       	add    $0x1310f1,%eax
	asm volatile("lgdt (%0)" : : "r" (p));
f0102af0:	8d 80 24 14 00 00    	lea    0x1424(%eax),%eax
f0102af6:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs"
f0102af9:	b8 23 00 00 00       	mov    $0x23,%eax
f0102afe:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs"
f0102b00:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es"
f0102b02:	b8 10 00 00 00       	mov    $0x10,%eax
f0102b07:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds"
f0102b09:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss"
f0102b0b:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n"
f0102b0d:	ea 14 2b 10 f0 08 00 	ljmp   $0x8,$0xf0102b14
	asm volatile("lldt %0" : : "r" (sel));
f0102b14:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b19:	0f 00 d0             	lldt   %ax
}
f0102b1c:	5d                   	pop    %ebp
f0102b1d:	c3                   	ret    

f0102b1e <env_init>:
{
f0102b1e:	55                   	push   %ebp
f0102b1f:	89 e5                	mov    %esp,%ebp
f0102b21:	57                   	push   %edi
f0102b22:	56                   	push   %esi
f0102b23:	53                   	push   %ebx
f0102b24:	e8 61 fe ff ff       	call   f010298a <__x86.get_pc_thunk.di>
f0102b29:	81 c7 b3 10 13 00    	add    $0x1310b3,%edi
		envs[i].env_id = 0;
f0102b2f:	8b b7 6c 26 00 00    	mov    0x266c(%edi),%esi
f0102b35:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102b3b:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102b3e:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b43:	89 c1                	mov    %eax,%ecx
f0102b45:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status = ENV_FREE;
f0102b4c:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link = env_free_list;
f0102b53:	89 50 44             	mov    %edx,0x44(%eax)
f0102b56:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f0102b59:	89 ca                	mov    %ecx,%edx
	for (int i = NENV - 1; i >= 0; i--) // 倒着遍历数组，让最后的元素出现在链表底部
f0102b5b:	39 d8                	cmp    %ebx,%eax
f0102b5d:	75 e4                	jne    f0102b43 <env_init+0x25>
f0102b5f:	89 b7 70 26 00 00    	mov    %esi,0x2670(%edi)
	env_init_percpu();
f0102b65:	e8 79 ff ff ff       	call   f0102ae3 <env_init_percpu>
}
f0102b6a:	5b                   	pop    %ebx
f0102b6b:	5e                   	pop    %esi
f0102b6c:	5f                   	pop    %edi
f0102b6d:	5d                   	pop    %ebp
f0102b6e:	c3                   	ret    

f0102b6f <env_alloc>:
{
f0102b6f:	55                   	push   %ebp
f0102b70:	89 e5                	mov    %esp,%ebp
f0102b72:	56                   	push   %esi
f0102b73:	53                   	push   %ebx
f0102b74:	e8 38 d7 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0102b79:	81 c3 63 10 13 00    	add    $0x131063,%ebx
	if (!(e = env_free_list)) // 如果env_free_list==null就会在这
f0102b7f:	8b b3 70 26 00 00    	mov    0x2670(%ebx),%esi
f0102b85:	85 f6                	test   %esi,%esi
f0102b87:	0f 84 86 01 00 00    	je     f0102d13 <env_alloc+0x1a4>
	if (!(p = page_alloc(ALLOC_ZERO))) // 分配一页给页表目录
f0102b8d:	83 ec 0c             	sub    $0xc,%esp
f0102b90:	6a 01                	push   $0x1
f0102b92:	e8 d3 e2 ff ff       	call   f0100e6a <page_alloc>
f0102b97:	83 c4 10             	add    $0x10,%esp
f0102b9a:	85 c0                	test   %eax,%eax
f0102b9c:	0f 84 78 01 00 00    	je     f0102d1a <env_alloc+0x1ab>
	p->pp_ref++;
f0102ba2:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0102ba7:	c7 c2 10 6f 23 f0    	mov    $0xf0236f10,%edx
f0102bad:	2b 02                	sub    (%edx),%eax
f0102baf:	c1 f8 03             	sar    $0x3,%eax
f0102bb2:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102bb5:	89 c1                	mov    %eax,%ecx
f0102bb7:	c1 e9 0c             	shr    $0xc,%ecx
f0102bba:	c7 c2 08 6f 23 f0    	mov    $0xf0236f08,%edx
f0102bc0:	3b 0a                	cmp    (%edx),%ecx
f0102bc2:	0f 83 1c 01 00 00    	jae    f0102ce4 <env_alloc+0x175>
	return (void *)(pa + KERNBASE);
f0102bc8:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = page2kva(p);
f0102bcd:	89 46 60             	mov    %eax,0x60(%esi)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE); // 把内核页表复制一份放在用户能访问的用户空间里(即env_pgdir处)
f0102bd0:	83 ec 04             	sub    $0x4,%esp
f0102bd3:	68 00 10 00 00       	push   $0x1000
f0102bd8:	c7 c2 0c 6f 23 f0    	mov    $0xf0236f0c,%edx
f0102bde:	ff 32                	pushl  (%edx)
f0102be0:	50                   	push   %eax
f0102be1:	e8 ab 21 00 00       	call   f0104d91 <memcpy>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102be6:	8b 46 60             	mov    0x60(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0102be9:	83 c4 10             	add    $0x10,%esp
f0102bec:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102bf1:	0f 86 03 01 00 00    	jbe    f0102cfa <env_alloc+0x18b>
	return (physaddr_t)kva - KERNBASE;
f0102bf7:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102bfd:	83 ca 05             	or     $0x5,%edx
f0102c00:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102c06:	8b 46 48             	mov    0x48(%esi),%eax
f0102c09:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0) // Don't create a negative env_id.
f0102c0e:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102c13:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102c18:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102c1b:	89 f2                	mov    %esi,%edx
f0102c1d:	2b 93 6c 26 00 00    	sub    0x266c(%ebx),%edx
f0102c23:	c1 fa 02             	sar    $0x2,%edx
f0102c26:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0102c2c:	09 d0                	or     %edx,%eax
f0102c2e:	89 46 48             	mov    %eax,0x48(%esi)
	e->env_parent_id = parent_id;
f0102c31:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c34:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f0102c37:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f0102c3e:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f0102c45:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102c4c:	83 ec 04             	sub    $0x4,%esp
f0102c4f:	6a 44                	push   $0x44
f0102c51:	6a 00                	push   $0x0
f0102c53:	56                   	push   %esi
f0102c54:	e8 83 20 00 00       	call   f0104cdc <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0102c59:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f0102c5f:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f0102c65:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f0102c6b:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f0102c72:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	e->env_pgfault_upcall = 0;
f0102c78:	c7 46 64 00 00 00 00 	movl   $0x0,0x64(%esi)
	e->env_ipc_recving = 0;
f0102c7f:	c6 46 68 00          	movb   $0x0,0x68(%esi)
	env_free_list = e->env_link;
f0102c83:	8b 46 44             	mov    0x44(%esi),%eax
f0102c86:	89 83 70 26 00 00    	mov    %eax,0x2670(%ebx)
	*newenv_store = e;
f0102c8c:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c8f:	89 30                	mov    %esi,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102c91:	8b 76 48             	mov    0x48(%esi),%esi
f0102c94:	e8 02 27 00 00       	call   f010539b <cpunum>
f0102c99:	6b c0 74             	imul   $0x74,%eax,%eax
f0102c9c:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0102ca2:	83 c4 10             	add    $0x10,%esp
f0102ca5:	ba 00 00 00 00       	mov    $0x0,%edx
f0102caa:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0102cae:	74 14                	je     f0102cc4 <env_alloc+0x155>
f0102cb0:	e8 e6 26 00 00       	call   f010539b <cpunum>
f0102cb5:	6b c0 74             	imul   $0x74,%eax,%eax
f0102cb8:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0102cbe:	8b 40 08             	mov    0x8(%eax),%eax
f0102cc1:	8b 50 48             	mov    0x48(%eax),%edx
f0102cc4:	83 ec 04             	sub    $0x4,%esp
f0102cc7:	56                   	push   %esi
f0102cc8:	52                   	push   %edx
f0102cc9:	8d 83 e8 2d ed ff    	lea    -0x12d218(%ebx),%eax
f0102ccf:	50                   	push   %eax
f0102cd0:	e8 2a 07 00 00       	call   f01033ff <cprintf>
	return 0;
f0102cd5:	83 c4 10             	add    $0x10,%esp
f0102cd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102cdd:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0102ce0:	5b                   	pop    %ebx
f0102ce1:	5e                   	pop    %esi
f0102ce2:	5d                   	pop    %ebp
f0102ce3:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ce4:	50                   	push   %eax
f0102ce5:	8d 83 28 1f ed ff    	lea    -0x12e0d8(%ebx),%eax
f0102ceb:	50                   	push   %eax
f0102cec:	6a 58                	push   $0x58
f0102cee:	8d 83 ed 2a ed ff    	lea    -0x12d513(%ebx),%eax
f0102cf4:	50                   	push   %eax
f0102cf5:	e8 46 d3 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cfa:	50                   	push   %eax
f0102cfb:	8d 83 4c 1f ed ff    	lea    -0x12e0b4(%ebx),%eax
f0102d01:	50                   	push   %eax
f0102d02:	68 d3 00 00 00       	push   $0xd3
f0102d07:	8d 83 dd 2d ed ff    	lea    -0x12d223(%ebx),%eax
f0102d0d:	50                   	push   %eax
f0102d0e:	e8 2d d3 ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f0102d13:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102d18:	eb c3                	jmp    f0102cdd <env_alloc+0x16e>
		return -E_NO_MEM;
f0102d1a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0102d1f:	eb bc                	jmp    f0102cdd <env_alloc+0x16e>

f0102d21 <env_create>:
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
// 使用 env_alloc 分配一个新环境，使用 load_icode 将命名的 elf 二进制文件加载到其中，并设置其 env_type
void env_create(uint8_t *binary, enum EnvType type)
{
f0102d21:	55                   	push   %ebp
f0102d22:	89 e5                	mov    %esp,%ebp
f0102d24:	57                   	push   %edi
f0102d25:	56                   	push   %esi
f0102d26:	53                   	push   %ebx
f0102d27:	83 ec 34             	sub    $0x34,%esp
f0102d2a:	e8 82 d5 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0102d2f:	81 c3 ad 0e 13 00    	add    $0x130ead,%ebx
	// LAB 3: Your code here.
	struct Env *e;
	if (env_alloc(&e, 0))
f0102d35:	6a 00                	push   $0x0
f0102d37:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102d3a:	50                   	push   %eax
f0102d3b:	e8 2f fe ff ff       	call   f0102b6f <env_alloc>
f0102d40:	83 c4 10             	add    $0x10,%esp
f0102d43:	85 c0                	test   %eax,%eax
f0102d45:	75 3a                	jne    f0102d81 <env_create+0x60>
	{
		panic("env_create: error in env_alloc()");
	}
	load_icode(e, binary);
f0102d47:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	if (ELFHDR->e_magic != ELF_MAGIC)
f0102d4a:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d4d:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0102d53:	75 47                	jne    f0102d9c <env_create+0x7b>
	ph = (struct Proghdr *)((uint8_t *)ELFHDR + ELFHDR->e_phoff); // ELFHDR+offset是段的起始地址
f0102d55:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d58:	89 c6                	mov    %eax,%esi
f0102d5a:	03 70 1c             	add    0x1c(%eax),%esi
	eph = ph + ELFHDR->e_phnum;									  // end地址
f0102d5d:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f0102d61:	c1 e0 05             	shl    $0x5,%eax
f0102d64:	01 f0                	add    %esi,%eax
f0102d66:	89 c1                	mov    %eax,%ecx
	lcr3(PADDR(e->env_pgdir));									  // 切换到用户空间
f0102d68:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0102d6b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d70:	76 45                	jbe    f0102db7 <env_create+0x96>
	return (physaddr_t)kva - KERNBASE;
f0102d72:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102d77:	0f 22 d8             	mov    %eax,%cr3
f0102d7a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102d7d:	89 cf                	mov    %ecx,%edi
f0102d7f:	eb 52                	jmp    f0102dd3 <env_create+0xb2>
		panic("env_create: error in env_alloc()");
f0102d81:	83 ec 04             	sub    $0x4,%esp
f0102d84:	8d 83 94 2d ed ff    	lea    -0x12d26c(%ebx),%eax
f0102d8a:	50                   	push   %eax
f0102d8b:	68 a0 01 00 00       	push   $0x1a0
f0102d90:	8d 83 dd 2d ed ff    	lea    -0x12d223(%ebx),%eax
f0102d96:	50                   	push   %eax
f0102d97:	e8 a4 d2 ff ff       	call   f0100040 <_panic>
		panic("load_icode: ELFHDR is not ELF_MAGIC\n");
f0102d9c:	83 ec 04             	sub    $0x4,%esp
f0102d9f:	8d 83 b8 2d ed ff    	lea    -0x12d248(%ebx),%eax
f0102da5:	50                   	push   %eax
f0102da6:	68 79 01 00 00       	push   $0x179
f0102dab:	8d 83 dd 2d ed ff    	lea    -0x12d223(%ebx),%eax
f0102db1:	50                   	push   %eax
f0102db2:	e8 89 d2 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102db7:	50                   	push   %eax
f0102db8:	8d 83 4c 1f ed ff    	lea    -0x12e0b4(%ebx),%eax
f0102dbe:	50                   	push   %eax
f0102dbf:	68 7e 01 00 00       	push   $0x17e
f0102dc4:	8d 83 dd 2d ed ff    	lea    -0x12d223(%ebx),%eax
f0102dca:	50                   	push   %eax
f0102dcb:	e8 70 d2 ff ff       	call   f0100040 <_panic>
	for (; ph < eph; ph++)										  // 依次读取所有段
f0102dd0:	83 c6 20             	add    $0x20,%esi
f0102dd3:	39 f7                	cmp    %esi,%edi
f0102dd5:	76 3d                	jbe    f0102e14 <env_create+0xf3>
		if (ph->p_type == ELF_PROG_LOAD)
f0102dd7:	83 3e 01             	cmpl   $0x1,(%esi)
f0102dda:	75 f4                	jne    f0102dd0 <env_create+0xaf>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);						   // 先分配内存空间
f0102ddc:	8b 4e 14             	mov    0x14(%esi),%ecx
f0102ddf:	8b 56 08             	mov    0x8(%esi),%edx
f0102de2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102de5:	e8 a4 fb ff ff       	call   f010298e <region_alloc>
			memset((void *)ph->p_va, 0, ph->p_memsz);							   // 将内存空间初始化为0
f0102dea:	83 ec 04             	sub    $0x4,%esp
f0102ded:	ff 76 14             	pushl  0x14(%esi)
f0102df0:	6a 00                	push   $0x0
f0102df2:	ff 76 08             	pushl  0x8(%esi)
f0102df5:	e8 e2 1e 00 00       	call   f0104cdc <memset>
			memcpy((void *)ph->p_va, (void *)ELFHDR + ph->p_offset, ph->p_filesz); // 复制内容到刚刚分配的空间
f0102dfa:	83 c4 0c             	add    $0xc,%esp
f0102dfd:	ff 76 10             	pushl  0x10(%esi)
f0102e00:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e03:	03 46 04             	add    0x4(%esi),%eax
f0102e06:	50                   	push   %eax
f0102e07:	ff 76 08             	pushl  0x8(%esi)
f0102e0a:	e8 82 1f 00 00       	call   f0104d91 <memcpy>
f0102e0f:	83 c4 10             	add    $0x10,%esp
f0102e12:	eb bc                	jmp    f0102dd0 <env_create+0xaf>
f0102e14:	8b 7d d4             	mov    -0x2c(%ebp),%edi
	lcr3(PADDR(kern_pgdir));							 // 切换到内核空间
f0102e17:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f0102e1d:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102e1f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e24:	76 41                	jbe    f0102e67 <env_create+0x146>
	return (physaddr_t)kva - KERNBASE;
f0102e26:	05 00 00 00 10       	add    $0x10000000,%eax
f0102e2b:	0f 22 d8             	mov    %eax,%cr3
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE); // 为程序的初始堆栈(地址:USTACKTOP - PGSIZE)映射一页
f0102e2e:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102e33:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102e38:	89 f8                	mov    %edi,%eax
f0102e3a:	e8 4f fb ff ff       	call   f010298e <region_alloc>
	e->env_status = ENV_RUNNABLE;						 // 设置程序状态
f0102e3f:	c7 47 54 02 00 00 00 	movl   $0x2,0x54(%edi)
	e->env_tf.tf_esp = USTACKTOP;						 // 设置程序堆栈
f0102e46:	c7 47 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%edi)
	e->env_tf.tf_eip = ELFHDR->e_entry;					 // 设置程序入口
f0102e4d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e50:	8b 40 18             	mov    0x18(%eax),%eax
f0102e53:	89 47 30             	mov    %eax,0x30(%edi)
	e->env_type = type;
f0102e56:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102e59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102e5c:	89 50 50             	mov    %edx,0x50(%eax)
}
f0102e5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e62:	5b                   	pop    %ebx
f0102e63:	5e                   	pop    %esi
f0102e64:	5f                   	pop    %edi
f0102e65:	5d                   	pop    %ebp
f0102e66:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e67:	50                   	push   %eax
f0102e68:	8d 83 4c 1f ed ff    	lea    -0x12e0b4(%ebx),%eax
f0102e6e:	50                   	push   %eax
f0102e6f:	68 8c 01 00 00       	push   $0x18c
f0102e74:	8d 83 dd 2d ed ff    	lea    -0x12d223(%ebx),%eax
f0102e7a:	50                   	push   %eax
f0102e7b:	e8 c0 d1 ff ff       	call   f0100040 <_panic>

f0102e80 <env_free>:

//
// Frees env e and all memory it uses.
//
void env_free(struct Env *e)
{
f0102e80:	55                   	push   %ebp
f0102e81:	89 e5                	mov    %esp,%ebp
f0102e83:	57                   	push   %edi
f0102e84:	56                   	push   %esi
f0102e85:	53                   	push   %ebx
f0102e86:	83 ec 2c             	sub    $0x2c,%esp
f0102e89:	e8 23 d4 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0102e8e:	81 c3 4e 0d 13 00    	add    $0x130d4e,%ebx
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102e94:	e8 02 25 00 00       	call   f010539b <cpunum>
f0102e99:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e9c:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0102ea2:	8b 55 08             	mov    0x8(%ebp),%edx
f0102ea5:	39 50 08             	cmp    %edx,0x8(%eax)
f0102ea8:	75 17                	jne    f0102ec1 <env_free+0x41>
		lcr3(PADDR(kern_pgdir));
f0102eaa:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f0102eb0:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102eb2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102eb7:	76 67                	jbe    f0102f20 <env_free+0xa0>
	return (physaddr_t)kva - KERNBASE;
f0102eb9:	05 00 00 00 10       	add    $0x10000000,%eax
f0102ebe:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102ec1:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ec4:	8b 70 48             	mov    0x48(%eax),%esi
f0102ec7:	e8 cf 24 00 00       	call   f010539b <cpunum>
f0102ecc:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ecf:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0102ed5:	ba 00 00 00 00       	mov    $0x0,%edx
f0102eda:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0102ede:	74 14                	je     f0102ef4 <env_free+0x74>
f0102ee0:	e8 b6 24 00 00       	call   f010539b <cpunum>
f0102ee5:	6b c0 74             	imul   $0x74,%eax,%eax
f0102ee8:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0102eee:	8b 40 08             	mov    0x8(%eax),%eax
f0102ef1:	8b 50 48             	mov    0x48(%eax),%edx
f0102ef4:	83 ec 04             	sub    $0x4,%esp
f0102ef7:	56                   	push   %esi
f0102ef8:	52                   	push   %edx
f0102ef9:	8d 83 fd 2d ed ff    	lea    -0x12d203(%ebx),%eax
f0102eff:	50                   	push   %eax
f0102f00:	e8 fa 04 00 00       	call   f01033ff <cprintf>
f0102f05:	83 c4 10             	add    $0x10,%esp
f0102f08:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	if (PGNUM(pa) >= npages)
f0102f0f:	c7 c0 08 6f 23 f0    	mov    $0xf0236f08,%eax
f0102f15:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (PGNUM(pa) >= npages)
f0102f18:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102f1b:	e9 9f 00 00 00       	jmp    f0102fbf <env_free+0x13f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f20:	50                   	push   %eax
f0102f21:	8d 83 4c 1f ed ff    	lea    -0x12e0b4(%ebx),%eax
f0102f27:	50                   	push   %eax
f0102f28:	68 b3 01 00 00       	push   $0x1b3
f0102f2d:	8d 83 dd 2d ed ff    	lea    -0x12d223(%ebx),%eax
f0102f33:	50                   	push   %eax
f0102f34:	e8 07 d1 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f39:	50                   	push   %eax
f0102f3a:	8d 83 28 1f ed ff    	lea    -0x12e0d8(%ebx),%eax
f0102f40:	50                   	push   %eax
f0102f41:	68 c3 01 00 00       	push   $0x1c3
f0102f46:	8d 83 dd 2d ed ff    	lea    -0x12d223(%ebx),%eax
f0102f4c:	50                   	push   %eax
f0102f4d:	e8 ee d0 ff ff       	call   f0100040 <_panic>
f0102f52:	83 c6 04             	add    $0x4,%esi
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t *)KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++)
f0102f55:	39 fe                	cmp    %edi,%esi
f0102f57:	74 24                	je     f0102f7d <env_free+0xfd>
		{
			if (pt[pteno] & PTE_P)
f0102f59:	f6 06 01             	testb  $0x1,(%esi)
f0102f5c:	74 f4                	je     f0102f52 <env_free+0xd2>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102f5e:	83 ec 08             	sub    $0x8,%esp
f0102f61:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102f64:	01 f0                	add    %esi,%eax
f0102f66:	c1 e0 0a             	shl    $0xa,%eax
f0102f69:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102f6c:	50                   	push   %eax
f0102f6d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f70:	ff 70 60             	pushl  0x60(%eax)
f0102f73:	e8 a4 e1 ff ff       	call   f010111c <page_remove>
f0102f78:	83 c4 10             	add    $0x10,%esp
f0102f7b:	eb d5                	jmp    f0102f52 <env_free+0xd2>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102f7d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f80:	8b 40 60             	mov    0x60(%eax),%eax
f0102f83:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102f86:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0102f8d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102f90:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102f93:	3b 10                	cmp    (%eax),%edx
f0102f95:	73 6f                	jae    f0103006 <env_free+0x186>
		page_decref(pa2page(pa));
f0102f97:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0102f9a:	c7 c0 10 6f 23 f0    	mov    $0xf0236f10,%eax
f0102fa0:	8b 00                	mov    (%eax),%eax
f0102fa2:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102fa5:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0102fa8:	50                   	push   %eax
f0102fa9:	e8 99 df ff ff       	call   f0100f47 <page_decref>
f0102fae:	83 c4 10             	add    $0x10,%esp
f0102fb1:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f0102fb5:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++)
f0102fb8:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0102fbd:	74 5f                	je     f010301e <env_free+0x19e>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102fbf:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fc2:	8b 40 60             	mov    0x60(%eax),%eax
f0102fc5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102fc8:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0102fcb:	a8 01                	test   $0x1,%al
f0102fcd:	74 e2                	je     f0102fb1 <env_free+0x131>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102fcf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0102fd4:	89 c2                	mov    %eax,%edx
f0102fd6:	c1 ea 0c             	shr    $0xc,%edx
f0102fd9:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0102fdc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102fdf:	39 11                	cmp    %edx,(%ecx)
f0102fe1:	0f 86 52 ff ff ff    	jbe    f0102f39 <env_free+0xb9>
	return (void *)(pa + KERNBASE);
f0102fe7:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102fed:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102ff0:	c1 e2 14             	shl    $0x14,%edx
f0102ff3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0102ff6:	8d b8 00 10 00 f0    	lea    -0xffff000(%eax),%edi
f0102ffc:	f7 d8                	neg    %eax
f0102ffe:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103001:	e9 53 ff ff ff       	jmp    f0102f59 <env_free+0xd9>
		panic("pa2page called with invalid pa");
f0103006:	83 ec 04             	sub    $0x4,%esp
f0103009:	8d 83 98 24 ed ff    	lea    -0x12db68(%ebx),%eax
f010300f:	50                   	push   %eax
f0103010:	6a 51                	push   $0x51
f0103012:	8d 83 ed 2a ed ff    	lea    -0x12d513(%ebx),%eax
f0103018:	50                   	push   %eax
f0103019:	e8 22 d0 ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010301e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103021:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103024:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103029:	76 57                	jbe    f0103082 <env_free+0x202>
	e->env_pgdir = 0;
f010302b:	8b 55 08             	mov    0x8(%ebp),%edx
f010302e:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)
	return (physaddr_t)kva - KERNBASE;
f0103035:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f010303a:	c1 e8 0c             	shr    $0xc,%eax
f010303d:	c7 c2 08 6f 23 f0    	mov    $0xf0236f08,%edx
f0103043:	3b 02                	cmp    (%edx),%eax
f0103045:	73 54                	jae    f010309b <env_free+0x21b>
	page_decref(pa2page(pa));
f0103047:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010304a:	c7 c2 10 6f 23 f0    	mov    $0xf0236f10,%edx
f0103050:	8b 12                	mov    (%edx),%edx
f0103052:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103055:	50                   	push   %eax
f0103056:	e8 ec de ff ff       	call   f0100f47 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010305b:	8b 45 08             	mov    0x8(%ebp),%eax
f010305e:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0103065:	8b 83 70 26 00 00    	mov    0x2670(%ebx),%eax
f010306b:	8b 55 08             	mov    0x8(%ebp),%edx
f010306e:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f0103071:	89 93 70 26 00 00    	mov    %edx,0x2670(%ebx)
}
f0103077:	83 c4 10             	add    $0x10,%esp
f010307a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010307d:	5b                   	pop    %ebx
f010307e:	5e                   	pop    %esi
f010307f:	5f                   	pop    %edi
f0103080:	5d                   	pop    %ebp
f0103081:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103082:	50                   	push   %eax
f0103083:	8d 83 4c 1f ed ff    	lea    -0x12e0b4(%ebx),%eax
f0103089:	50                   	push   %eax
f010308a:	68 d2 01 00 00       	push   $0x1d2
f010308f:	8d 83 dd 2d ed ff    	lea    -0x12d223(%ebx),%eax
f0103095:	50                   	push   %eax
f0103096:	e8 a5 cf ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f010309b:	83 ec 04             	sub    $0x4,%esp
f010309e:	8d 83 98 24 ed ff    	lea    -0x12db68(%ebx),%eax
f01030a4:	50                   	push   %eax
f01030a5:	6a 51                	push   $0x51
f01030a7:	8d 83 ed 2a ed ff    	lea    -0x12d513(%ebx),%eax
f01030ad:	50                   	push   %eax
f01030ae:	e8 8d cf ff ff       	call   f0100040 <_panic>

f01030b3 <env_destroy>:
// Frees environment e.
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void env_destroy(struct Env *e)
{
f01030b3:	55                   	push   %ebp
f01030b4:	89 e5                	mov    %esp,%ebp
f01030b6:	56                   	push   %esi
f01030b7:	53                   	push   %ebx
f01030b8:	e8 f4 d1 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f01030bd:	81 c3 1f 0b 13 00    	add    $0x130b1f,%ebx
f01030c3:	8b 75 08             	mov    0x8(%ebp),%esi
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01030c6:	83 7e 54 03          	cmpl   $0x3,0x54(%esi)
f01030ca:	74 26                	je     f01030f2 <env_destroy+0x3f>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f01030cc:	83 ec 0c             	sub    $0xc,%esp
f01030cf:	56                   	push   %esi
f01030d0:	e8 ab fd ff ff       	call   f0102e80 <env_free>

	if (curenv == e) {
f01030d5:	e8 c1 22 00 00       	call   f010539b <cpunum>
f01030da:	6b c0 74             	imul   $0x74,%eax,%eax
f01030dd:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f01030e3:	83 c4 10             	add    $0x10,%esp
f01030e6:	39 70 08             	cmp    %esi,0x8(%eax)
f01030e9:	74 23                	je     f010310e <env_destroy+0x5b>
		curenv = NULL;
		sched_yield();
	}
}
f01030eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01030ee:	5b                   	pop    %ebx
f01030ef:	5e                   	pop    %esi
f01030f0:	5d                   	pop    %ebp
f01030f1:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01030f2:	e8 a4 22 00 00       	call   f010539b <cpunum>
f01030f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01030fa:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0103100:	39 70 08             	cmp    %esi,0x8(%eax)
f0103103:	74 c7                	je     f01030cc <env_destroy+0x19>
		e->env_status = ENV_DYING;
f0103105:	c7 46 54 01 00 00 00 	movl   $0x1,0x54(%esi)
		return;
f010310c:	eb dd                	jmp    f01030eb <env_destroy+0x38>
		curenv = NULL;
f010310e:	e8 88 22 00 00       	call   f010539b <cpunum>
f0103113:	6b c0 74             	imul   $0x74,%eax,%eax
f0103116:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f010311c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
		sched_yield();
f0103123:	e8 d0 0d 00 00       	call   f0103ef8 <sched_yield>

f0103128 <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
//
// This function does not return.
//
void env_pop_tf(struct Trapframe *tf)
{
f0103128:	55                   	push   %ebp
f0103129:	89 e5                	mov    %esp,%ebp
f010312b:	56                   	push   %esi
f010312c:	53                   	push   %ebx
f010312d:	e8 7f d1 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0103132:	81 c3 aa 0a 13 00    	add    $0x130aaa,%ebx
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103138:	e8 5e 22 00 00       	call   f010539b <cpunum>
f010313d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103140:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0103146:	8b 70 08             	mov    0x8(%eax),%esi
f0103149:	e8 4d 22 00 00       	call   f010539b <cpunum>
f010314e:	89 46 5c             	mov    %eax,0x5c(%esi)

	asm volatile(
f0103151:	8b 65 08             	mov    0x8(%ebp),%esp
f0103154:	61                   	popa   
f0103155:	07                   	pop    %es
f0103156:	1f                   	pop    %ds
f0103157:	83 c4 08             	add    $0x8,%esp
f010315a:	cf                   	iret   
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		:
		: "g"(tf)
		: "memory");
	panic("iret failed"); /* mostly to placate the compiler */
f010315b:	83 ec 04             	sub    $0x4,%esp
f010315e:	8d 83 13 2e ed ff    	lea    -0x12d1ed(%ebx),%eax
f0103164:	50                   	push   %eax
f0103165:	68 08 02 00 00       	push   $0x208
f010316a:	8d 83 dd 2d ed ff    	lea    -0x12d223(%ebx),%eax
f0103170:	50                   	push   %eax
f0103171:	e8 ca ce ff ff       	call   f0100040 <_panic>

f0103176 <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//
// This function does not return.
// 把环境从curenv 切换到 e
void env_run(struct Env *e)
{
f0103176:	55                   	push   %ebp
f0103177:	89 e5                	mov    %esp,%ebp
f0103179:	57                   	push   %edi
f010317a:	56                   	push   %esi
f010317b:	53                   	push   %ebx
f010317c:	83 ec 0c             	sub    $0xc,%esp
f010317f:	e8 2d d1 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0103184:	81 c3 58 0a 13 00    	add    $0x130a58,%ebx
f010318a:	8b 7d 08             	mov    0x8(%ebp),%edi
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	if (curenv) // 如果当前有环境
f010318d:	e8 09 22 00 00       	call   f010539b <cpunum>
f0103192:	6b c0 74             	imul   $0x74,%eax,%eax
f0103195:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f010319b:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f010319f:	74 18                	je     f01031b9 <env_run+0x43>
	{
		curenv->env_status = ENV_RUNNABLE; // 设置回 ENV_RUNNABLE
f01031a1:	e8 f5 21 00 00       	call   f010539b <cpunum>
f01031a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01031a9:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f01031af:	8b 40 08             	mov    0x8(%eax),%eax
f01031b2:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
	curenv = e;						  // 将“curenv”设置为新环境
f01031b9:	e8 dd 21 00 00       	call   f010539b <cpunum>
f01031be:	c7 c6 20 70 23 f0    	mov    $0xf0237020,%esi
f01031c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01031c7:	89 7c 06 08          	mov    %edi,0x8(%esi,%eax,1)
	curenv->env_status = ENV_RUNNING; // 将其状态设置为 ENV_RUNNING
f01031cb:	e8 cb 21 00 00       	call   f010539b <cpunum>
f01031d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01031d3:	8b 44 06 08          	mov    0x8(%esi,%eax,1),%eax
f01031d7:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;				  // 更新其“env_runs”计数器
f01031de:	e8 b8 21 00 00       	call   f010539b <cpunum>
f01031e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01031e6:	8b 44 06 08          	mov    0x8(%esi,%eax,1),%eax
f01031ea:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));	  // 切换到用户空间
f01031ee:	e8 a8 21 00 00       	call   f010539b <cpunum>
f01031f3:	6b c0 74             	imul   $0x74,%eax,%eax
f01031f6:	8b 44 06 08          	mov    0x8(%esi,%eax,1),%eax
f01031fa:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01031fd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103202:	77 19                	ja     f010321d <env_run+0xa7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103204:	50                   	push   %eax
f0103205:	8d 83 4c 1f ed ff    	lea    -0x12e0b4(%ebx),%eax
f010320b:	50                   	push   %eax
f010320c:	68 2d 02 00 00       	push   $0x22d
f0103211:	8d 83 dd 2d ed ff    	lea    -0x12d223(%ebx),%eax
f0103217:	50                   	push   %eax
f0103218:	e8 23 ce ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010321d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103222:	0f 22 d8             	mov    %eax,%cr3
	env_pop_tf(&e->env_tf); // 恢复环境的寄存器来进入环境中的用户模式，设置%eip为可执行程序的第一条指令
f0103225:	83 ec 0c             	sub    $0xc,%esp
f0103228:	57                   	push   %edi
f0103229:	e8 fa fe ff ff       	call   f0103128 <env_pop_tf>

f010322e <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010322e:	55                   	push   %ebp
f010322f:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103231:	8b 45 08             	mov    0x8(%ebp),%eax
f0103234:	ba 70 00 00 00       	mov    $0x70,%edx
f0103239:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010323a:	ba 71 00 00 00       	mov    $0x71,%edx
f010323f:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103240:	0f b6 c0             	movzbl %al,%eax
}
f0103243:	5d                   	pop    %ebp
f0103244:	c3                   	ret    

f0103245 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103245:	55                   	push   %ebp
f0103246:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103248:	8b 45 08             	mov    0x8(%ebp),%eax
f010324b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103250:	ee                   	out    %al,(%dx)
f0103251:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103254:	ba 71 00 00 00       	mov    $0x71,%edx
f0103259:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010325a:	5d                   	pop    %ebp
f010325b:	c3                   	ret    

f010325c <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010325c:	55                   	push   %ebp
f010325d:	89 e5                	mov    %esp,%ebp
f010325f:	57                   	push   %edi
f0103260:	56                   	push   %esi
f0103261:	53                   	push   %ebx
f0103262:	83 ec 1c             	sub    $0x1c,%esp
f0103265:	e8 47 d0 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f010326a:	81 c3 72 09 13 00    	add    $0x130972,%ebx
f0103270:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103273:	66 89 83 8c a7 ee ff 	mov    %ax,-0x115874(%ebx)
	if (!didinit)
f010327a:	80 bb 74 26 00 00 00 	cmpb   $0x0,0x2674(%ebx)
f0103281:	75 08                	jne    f010328b <irq_setmask_8259A+0x2f>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f0103283:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103286:	5b                   	pop    %ebx
f0103287:	5e                   	pop    %esi
f0103288:	5f                   	pop    %edi
f0103289:	5d                   	pop    %ebp
f010328a:	c3                   	ret    
f010328b:	89 c7                	mov    %eax,%edi
f010328d:	ba 21 00 00 00       	mov    $0x21,%edx
f0103292:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103293:	66 c1 e8 08          	shr    $0x8,%ax
f0103297:	ba a1 00 00 00       	mov    $0xa1,%edx
f010329c:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f010329d:	83 ec 0c             	sub    $0xc,%esp
f01032a0:	8d 83 1f 2e ed ff    	lea    -0x12d1e1(%ebx),%eax
f01032a6:	50                   	push   %eax
f01032a7:	e8 53 01 00 00       	call   f01033ff <cprintf>
f01032ac:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01032af:	be 00 00 00 00       	mov    $0x0,%esi
		if (~mask & (1<<i))
f01032b4:	0f b7 ff             	movzwl %di,%edi
f01032b7:	f7 d7                	not    %edi
			cprintf(" %d", i);
f01032b9:	8d 83 65 32 ed ff    	lea    -0x12cd9b(%ebx),%eax
f01032bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01032c2:	eb 08                	jmp    f01032cc <irq_setmask_8259A+0x70>
	for (i = 0; i < 16; i++)
f01032c4:	83 c6 01             	add    $0x1,%esi
f01032c7:	83 fe 10             	cmp    $0x10,%esi
f01032ca:	74 16                	je     f01032e2 <irq_setmask_8259A+0x86>
		if (~mask & (1<<i))
f01032cc:	0f a3 f7             	bt     %esi,%edi
f01032cf:	73 f3                	jae    f01032c4 <irq_setmask_8259A+0x68>
			cprintf(" %d", i);
f01032d1:	83 ec 08             	sub    $0x8,%esp
f01032d4:	56                   	push   %esi
f01032d5:	ff 75 e4             	pushl  -0x1c(%ebp)
f01032d8:	e8 22 01 00 00       	call   f01033ff <cprintf>
f01032dd:	83 c4 10             	add    $0x10,%esp
f01032e0:	eb e2                	jmp    f01032c4 <irq_setmask_8259A+0x68>
	cprintf("\n");
f01032e2:	83 ec 0c             	sub    $0xc,%esp
f01032e5:	8d 83 d1 1f ed ff    	lea    -0x12e02f(%ebx),%eax
f01032eb:	50                   	push   %eax
f01032ec:	e8 0e 01 00 00       	call   f01033ff <cprintf>
f01032f1:	83 c4 10             	add    $0x10,%esp
f01032f4:	eb 8d                	jmp    f0103283 <irq_setmask_8259A+0x27>

f01032f6 <pic_init>:
{
f01032f6:	55                   	push   %ebp
f01032f7:	89 e5                	mov    %esp,%ebp
f01032f9:	57                   	push   %edi
f01032fa:	56                   	push   %esi
f01032fb:	53                   	push   %ebx
f01032fc:	83 ec 0c             	sub    $0xc,%esp
f01032ff:	e8 ad cf ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0103304:	81 c3 d8 08 13 00    	add    $0x1308d8,%ebx
	didinit = 1;
f010330a:	c6 83 74 26 00 00 01 	movb   $0x1,0x2674(%ebx)
f0103311:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103316:	b9 21 00 00 00       	mov    $0x21,%ecx
f010331b:	89 ca                	mov    %ecx,%edx
f010331d:	ee                   	out    %al,(%dx)
f010331e:	be a1 00 00 00       	mov    $0xa1,%esi
f0103323:	89 f2                	mov    %esi,%edx
f0103325:	ee                   	out    %al,(%dx)
f0103326:	bf 11 00 00 00       	mov    $0x11,%edi
f010332b:	89 f8                	mov    %edi,%eax
f010332d:	ba 20 00 00 00       	mov    $0x20,%edx
f0103332:	ee                   	out    %al,(%dx)
f0103333:	b8 20 00 00 00       	mov    $0x20,%eax
f0103338:	89 ca                	mov    %ecx,%edx
f010333a:	ee                   	out    %al,(%dx)
f010333b:	b8 04 00 00 00       	mov    $0x4,%eax
f0103340:	ee                   	out    %al,(%dx)
f0103341:	b8 03 00 00 00       	mov    $0x3,%eax
f0103346:	ee                   	out    %al,(%dx)
f0103347:	b9 a0 00 00 00       	mov    $0xa0,%ecx
f010334c:	89 f8                	mov    %edi,%eax
f010334e:	89 ca                	mov    %ecx,%edx
f0103350:	ee                   	out    %al,(%dx)
f0103351:	b8 28 00 00 00       	mov    $0x28,%eax
f0103356:	89 f2                	mov    %esi,%edx
f0103358:	ee                   	out    %al,(%dx)
f0103359:	b8 02 00 00 00       	mov    $0x2,%eax
f010335e:	ee                   	out    %al,(%dx)
f010335f:	b8 01 00 00 00       	mov    $0x1,%eax
f0103364:	ee                   	out    %al,(%dx)
f0103365:	bf 68 00 00 00       	mov    $0x68,%edi
f010336a:	89 f8                	mov    %edi,%eax
f010336c:	ba 20 00 00 00       	mov    $0x20,%edx
f0103371:	ee                   	out    %al,(%dx)
f0103372:	be 0a 00 00 00       	mov    $0xa,%esi
f0103377:	89 f0                	mov    %esi,%eax
f0103379:	ee                   	out    %al,(%dx)
f010337a:	89 f8                	mov    %edi,%eax
f010337c:	89 ca                	mov    %ecx,%edx
f010337e:	ee                   	out    %al,(%dx)
f010337f:	89 f0                	mov    %esi,%eax
f0103381:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103382:	0f b7 83 8c a7 ee ff 	movzwl -0x115874(%ebx),%eax
f0103389:	66 83 f8 ff          	cmp    $0xffff,%ax
f010338d:	74 0f                	je     f010339e <pic_init+0xa8>
		irq_setmask_8259A(irq_mask_8259A);
f010338f:	83 ec 0c             	sub    $0xc,%esp
f0103392:	0f b7 c0             	movzwl %ax,%eax
f0103395:	50                   	push   %eax
f0103396:	e8 c1 fe ff ff       	call   f010325c <irq_setmask_8259A>
f010339b:	83 c4 10             	add    $0x10,%esp
}
f010339e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033a1:	5b                   	pop    %ebx
f01033a2:	5e                   	pop    %esi
f01033a3:	5f                   	pop    %edi
f01033a4:	5d                   	pop    %ebp
f01033a5:	c3                   	ret    

f01033a6 <putch>:
#include <inc/stdio.h>
#include <inc/stdarg.h>

// putch通过调用console.c中的cputchar来实现输出字符串到控制台。
static void putch(int ch, int *cnt)
{
f01033a6:	55                   	push   %ebp
f01033a7:	89 e5                	mov    %esp,%ebp
f01033a9:	53                   	push   %ebx
f01033aa:	83 ec 10             	sub    $0x10,%esp
f01033ad:	e8 ff ce ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f01033b2:	81 c3 2a 08 13 00    	add    $0x13082a,%ebx
	cputchar(ch);
f01033b8:	ff 75 08             	pushl  0x8(%ebp)
f01033bb:	e8 87 d4 ff ff       	call   f0100847 <cputchar>
	*cnt++;
}
f01033c0:	83 c4 10             	add    $0x10,%esp
f01033c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01033c6:	c9                   	leave  
f01033c7:	c3                   	ret    

f01033c8 <vcprintf>:

// 将格式fmt和可变参数列表ap一起传给printfmt.c中的vprintfmt处理
int vcprintf(const char *fmt, va_list ap)
{
f01033c8:	55                   	push   %ebp
f01033c9:	89 e5                	mov    %esp,%ebp
f01033cb:	53                   	push   %ebx
f01033cc:	83 ec 14             	sub    $0x14,%esp
f01033cf:	e8 dd ce ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f01033d4:	81 c3 08 08 13 00    	add    $0x130808,%ebx
	int cnt = 0;
f01033da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	vprintfmt((void *)putch, &cnt, fmt, ap); // 用一个指向putch的函数指针来告诉vprintfmt，处理后的数据应该交给putch来输出
f01033e1:	ff 75 0c             	pushl  0xc(%ebp)
f01033e4:	ff 75 08             	pushl  0x8(%ebp)
f01033e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01033ea:	50                   	push   %eax
f01033eb:	8d 83 ca f7 ec ff    	lea    -0x130836(%ebx),%eax
f01033f1:	50                   	push   %eax
f01033f2:	e8 60 11 00 00       	call   f0104557 <vprintfmt>
	return cnt;
}
f01033f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01033fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01033fd:	c9                   	leave  
f01033fe:	c3                   	ret    

f01033ff <cprintf>:

// 这个函数作为实现打印功能的主要函数，暴露给其他程序。其第一个参数是包含输出格式的字符串，后面是可变参数列表。
int cprintf(const char *fmt, ...)
{
f01033ff:	55                   	push   %ebp
f0103400:	89 e5                	mov    %esp,%ebp
f0103402:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);		 // 获取可变参数列表ap
f0103405:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap); // 传参
f0103408:	50                   	push   %eax
f0103409:	ff 75 08             	pushl  0x8(%ebp)
f010340c:	e8 b7 ff ff ff       	call   f01033c8 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103411:	c9                   	leave  
f0103412:	c3                   	ret    

f0103413 <trap_init_percpu>:
	// Per-CPU setup
	trap_init_percpu();
}

void trap_init_percpu(void) // 初始化TSS和IDT
{
f0103413:	55                   	push   %ebp
f0103414:	89 e5                	mov    %esp,%ebp
f0103416:	57                   	push   %edi
f0103417:	56                   	push   %esi
f0103418:	53                   	push   %ebx
f0103419:	83 ec 04             	sub    $0x4,%esp
f010341c:	e8 90 ce ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0103421:	81 c3 bb 07 13 00    	add    $0x1307bb,%ebx
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103427:	c7 83 a8 2e 00 00 00 	movl   $0xf0000000,0x2ea8(%ebx)
f010342e:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103431:	66 c7 83 ac 2e 00 00 	movw   $0x10,0x2eac(%ebx)
f0103438:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f010343a:	66 c7 83 0a 2f 00 00 	movw   $0x68,0x2f0a(%ebx)
f0103441:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t)(&ts),
f0103443:	c7 c0 00 e3 11 f0    	mov    $0xf011e300,%eax
f0103449:	66 c7 40 28 67 00    	movw   $0x67,0x28(%eax)
f010344f:	8d b3 a4 2e 00 00    	lea    0x2ea4(%ebx),%esi
f0103455:	66 89 70 2a          	mov    %si,0x2a(%eax)
f0103459:	89 f2                	mov    %esi,%edx
f010345b:	c1 ea 10             	shr    $0x10,%edx
f010345e:	88 50 2c             	mov    %dl,0x2c(%eax)
f0103461:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
f0103465:	83 e2 f0             	and    $0xfffffff0,%edx
f0103468:	83 ca 09             	or     $0x9,%edx
f010346b:	83 e2 9f             	and    $0xffffff9f,%edx
f010346e:	83 ca 80             	or     $0xffffff80,%edx
f0103471:	88 55 f3             	mov    %dl,-0xd(%ebp)
f0103474:	88 50 2d             	mov    %dl,0x2d(%eax)
f0103477:	0f b6 48 2e          	movzbl 0x2e(%eax),%ecx
f010347b:	83 e1 c0             	and    $0xffffffc0,%ecx
f010347e:	83 c9 40             	or     $0x40,%ecx
f0103481:	83 e1 7f             	and    $0x7f,%ecx
f0103484:	88 48 2e             	mov    %cl,0x2e(%eax)
f0103487:	c1 ee 18             	shr    $0x18,%esi
f010348a:	89 f1                	mov    %esi,%ecx
f010348c:	88 48 2f             	mov    %cl,0x2f(%eax)
							  sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f010348f:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
f0103493:	83 e2 ef             	and    $0xffffffef,%edx
f0103496:	88 50 2d             	mov    %dl,0x2d(%eax)
	asm volatile("ltr %0" : : "r" (sel));
f0103499:	b8 28 00 00 00       	mov    $0x28,%eax
f010349e:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f01034a1:	8d 83 2c 14 00 00    	lea    0x142c(%ebx),%eax
f01034a7:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01034aa:	83 c4 04             	add    $0x4,%esp
f01034ad:	5b                   	pop    %ebx
f01034ae:	5e                   	pop    %esi
f01034af:	5f                   	pop    %edi
f01034b0:	5d                   	pop    %ebp
f01034b1:	c3                   	ret    

f01034b2 <trap_init>:
{
f01034b2:	55                   	push   %ebp
f01034b3:	89 e5                	mov    %esp,%ebp
f01034b5:	53                   	push   %ebx
f01034b6:	e8 b7 d3 ff ff       	call   f0100872 <__x86.get_pc_thunk.ax>
f01034bb:	05 21 07 13 00       	add    $0x130721,%eax
	SETGATE(idt[T_DIVIDE], 1, GD_KT, DIVIDE_Handler, 0); // SETGATE设置一个idt条目
f01034c0:	c7 c2 98 3d 10 f0    	mov    $0xf0103d98,%edx
f01034c6:	66 89 90 84 26 00 00 	mov    %dx,0x2684(%eax)
f01034cd:	66 c7 80 86 26 00 00 	movw   $0x8,0x2686(%eax)
f01034d4:	08 00 
f01034d6:	c6 80 88 26 00 00 00 	movb   $0x0,0x2688(%eax)
f01034dd:	c6 80 89 26 00 00 8f 	movb   $0x8f,0x2689(%eax)
f01034e4:	c1 ea 10             	shr    $0x10,%edx
f01034e7:	66 89 90 8a 26 00 00 	mov    %dx,0x268a(%eax)
	SETGATE(idt[T_DEBUG], 1, GD_KT, DEBUG_Handler, 3);
f01034ee:	c7 c2 9e 3d 10 f0    	mov    $0xf0103d9e,%edx
f01034f4:	66 89 90 8c 26 00 00 	mov    %dx,0x268c(%eax)
f01034fb:	66 c7 80 8e 26 00 00 	movw   $0x8,0x268e(%eax)
f0103502:	08 00 
f0103504:	c6 80 90 26 00 00 00 	movb   $0x0,0x2690(%eax)
f010350b:	c6 80 91 26 00 00 ef 	movb   $0xef,0x2691(%eax)
f0103512:	c1 ea 10             	shr    $0x10,%edx
f0103515:	66 89 90 92 26 00 00 	mov    %dx,0x2692(%eax)
	SETGATE(idt[T_NMI], 1, GD_KT, NMI_Handler, 0);
f010351c:	c7 c2 a4 3d 10 f0    	mov    $0xf0103da4,%edx
f0103522:	66 89 90 94 26 00 00 	mov    %dx,0x2694(%eax)
f0103529:	66 c7 80 96 26 00 00 	movw   $0x8,0x2696(%eax)
f0103530:	08 00 
f0103532:	c6 80 98 26 00 00 00 	movb   $0x0,0x2698(%eax)
f0103539:	c6 80 99 26 00 00 8f 	movb   $0x8f,0x2699(%eax)
f0103540:	c1 ea 10             	shr    $0x10,%edx
f0103543:	66 89 90 9a 26 00 00 	mov    %dx,0x269a(%eax)
	SETGATE(idt[T_BRKPT], 1, GD_KT, BRKPT_Handler, 3);
f010354a:	c7 c2 aa 3d 10 f0    	mov    $0xf0103daa,%edx
f0103550:	66 89 90 9c 26 00 00 	mov    %dx,0x269c(%eax)
f0103557:	66 c7 80 9e 26 00 00 	movw   $0x8,0x269e(%eax)
f010355e:	08 00 
f0103560:	c6 80 a0 26 00 00 00 	movb   $0x0,0x26a0(%eax)
f0103567:	c6 80 a1 26 00 00 ef 	movb   $0xef,0x26a1(%eax)
f010356e:	c1 ea 10             	shr    $0x10,%edx
f0103571:	66 89 90 a2 26 00 00 	mov    %dx,0x26a2(%eax)
	SETGATE(idt[T_OFLOW], 1, GD_KT, OFLOW_Handler, 0);
f0103578:	c7 c2 b0 3d 10 f0    	mov    $0xf0103db0,%edx
f010357e:	66 89 90 a4 26 00 00 	mov    %dx,0x26a4(%eax)
f0103585:	66 c7 80 a6 26 00 00 	movw   $0x8,0x26a6(%eax)
f010358c:	08 00 
f010358e:	c6 80 a8 26 00 00 00 	movb   $0x0,0x26a8(%eax)
f0103595:	c6 80 a9 26 00 00 8f 	movb   $0x8f,0x26a9(%eax)
f010359c:	c1 ea 10             	shr    $0x10,%edx
f010359f:	66 89 90 aa 26 00 00 	mov    %dx,0x26aa(%eax)
	SETGATE(idt[T_BOUND], 1, GD_KT, BOUND_Handler, 0);
f01035a6:	c7 c2 b6 3d 10 f0    	mov    $0xf0103db6,%edx
f01035ac:	66 89 90 ac 26 00 00 	mov    %dx,0x26ac(%eax)
f01035b3:	66 c7 80 ae 26 00 00 	movw   $0x8,0x26ae(%eax)
f01035ba:	08 00 
f01035bc:	c6 80 b0 26 00 00 00 	movb   $0x0,0x26b0(%eax)
f01035c3:	c6 80 b1 26 00 00 8f 	movb   $0x8f,0x26b1(%eax)
f01035ca:	c1 ea 10             	shr    $0x10,%edx
f01035cd:	66 89 90 b2 26 00 00 	mov    %dx,0x26b2(%eax)
	SETGATE(idt[T_ILLOP], 1, GD_KT, ILLOP_Handler, 0);
f01035d4:	c7 c2 bc 3d 10 f0    	mov    $0xf0103dbc,%edx
f01035da:	66 89 90 b4 26 00 00 	mov    %dx,0x26b4(%eax)
f01035e1:	66 c7 80 b6 26 00 00 	movw   $0x8,0x26b6(%eax)
f01035e8:	08 00 
f01035ea:	c6 80 b8 26 00 00 00 	movb   $0x0,0x26b8(%eax)
f01035f1:	c6 80 b9 26 00 00 8f 	movb   $0x8f,0x26b9(%eax)
f01035f8:	c1 ea 10             	shr    $0x10,%edx
f01035fb:	66 89 90 ba 26 00 00 	mov    %dx,0x26ba(%eax)
	SETGATE(idt[T_DEVICE], 1, GD_KT, DEVICE_Handler, 0);
f0103602:	c7 c2 c2 3d 10 f0    	mov    $0xf0103dc2,%edx
f0103608:	66 89 90 bc 26 00 00 	mov    %dx,0x26bc(%eax)
f010360f:	66 c7 80 be 26 00 00 	movw   $0x8,0x26be(%eax)
f0103616:	08 00 
f0103618:	c6 80 c0 26 00 00 00 	movb   $0x0,0x26c0(%eax)
f010361f:	c6 80 c1 26 00 00 8f 	movb   $0x8f,0x26c1(%eax)
f0103626:	c1 ea 10             	shr    $0x10,%edx
f0103629:	66 89 90 c2 26 00 00 	mov    %dx,0x26c2(%eax)
	SETGATE(idt[T_DBLFLT], 1, GD_KT, DBLFLT_Handler, 0);
f0103630:	c7 c2 c8 3d 10 f0    	mov    $0xf0103dc8,%edx
f0103636:	66 89 90 c4 26 00 00 	mov    %dx,0x26c4(%eax)
f010363d:	66 c7 80 c6 26 00 00 	movw   $0x8,0x26c6(%eax)
f0103644:	08 00 
f0103646:	c6 80 c8 26 00 00 00 	movb   $0x0,0x26c8(%eax)
f010364d:	c6 80 c9 26 00 00 8f 	movb   $0x8f,0x26c9(%eax)
f0103654:	c1 ea 10             	shr    $0x10,%edx
f0103657:	66 89 90 ca 26 00 00 	mov    %dx,0x26ca(%eax)
	SETGATE(idt[T_TSS], 1, GD_KT, TSS_Handler, 0);
f010365e:	c7 c2 cc 3d 10 f0    	mov    $0xf0103dcc,%edx
f0103664:	66 89 90 d4 26 00 00 	mov    %dx,0x26d4(%eax)
f010366b:	66 c7 80 d6 26 00 00 	movw   $0x8,0x26d6(%eax)
f0103672:	08 00 
f0103674:	c6 80 d8 26 00 00 00 	movb   $0x0,0x26d8(%eax)
f010367b:	c6 80 d9 26 00 00 8f 	movb   $0x8f,0x26d9(%eax)
f0103682:	c1 ea 10             	shr    $0x10,%edx
f0103685:	66 89 90 da 26 00 00 	mov    %dx,0x26da(%eax)
	SETGATE(idt[T_SEGNP], 1, GD_KT, SEGNP_Handler, 0);
f010368c:	c7 c2 d0 3d 10 f0    	mov    $0xf0103dd0,%edx
f0103692:	66 89 90 dc 26 00 00 	mov    %dx,0x26dc(%eax)
f0103699:	66 c7 80 de 26 00 00 	movw   $0x8,0x26de(%eax)
f01036a0:	08 00 
f01036a2:	c6 80 e0 26 00 00 00 	movb   $0x0,0x26e0(%eax)
f01036a9:	c6 80 e1 26 00 00 8f 	movb   $0x8f,0x26e1(%eax)
f01036b0:	c1 ea 10             	shr    $0x10,%edx
f01036b3:	66 89 90 e2 26 00 00 	mov    %dx,0x26e2(%eax)
	SETGATE(idt[T_STACK], 1, GD_KT, STACK_Handler, 0);
f01036ba:	c7 c2 d4 3d 10 f0    	mov    $0xf0103dd4,%edx
f01036c0:	66 89 90 e4 26 00 00 	mov    %dx,0x26e4(%eax)
f01036c7:	66 c7 80 e6 26 00 00 	movw   $0x8,0x26e6(%eax)
f01036ce:	08 00 
f01036d0:	c6 80 e8 26 00 00 00 	movb   $0x0,0x26e8(%eax)
f01036d7:	c6 80 e9 26 00 00 8f 	movb   $0x8f,0x26e9(%eax)
f01036de:	c1 ea 10             	shr    $0x10,%edx
f01036e1:	66 89 90 ea 26 00 00 	mov    %dx,0x26ea(%eax)
	SETGATE(idt[T_GPFLT], 1, GD_KT, GPFLT_Handler, 0);
f01036e8:	c7 c2 d8 3d 10 f0    	mov    $0xf0103dd8,%edx
f01036ee:	66 89 90 ec 26 00 00 	mov    %dx,0x26ec(%eax)
f01036f5:	66 c7 80 ee 26 00 00 	movw   $0x8,0x26ee(%eax)
f01036fc:	08 00 
f01036fe:	c6 80 f0 26 00 00 00 	movb   $0x0,0x26f0(%eax)
f0103705:	c6 80 f1 26 00 00 8f 	movb   $0x8f,0x26f1(%eax)
f010370c:	c1 ea 10             	shr    $0x10,%edx
f010370f:	66 89 90 f2 26 00 00 	mov    %dx,0x26f2(%eax)
	SETGATE(idt[T_PGFLT], 1, GD_KT, PGFLT_Handler, 0);
f0103716:	c7 c1 dc 3d 10 f0    	mov    $0xf0103ddc,%ecx
f010371c:	66 89 88 f4 26 00 00 	mov    %cx,0x26f4(%eax)
f0103723:	66 c7 80 f6 26 00 00 	movw   $0x8,0x26f6(%eax)
f010372a:	08 00 
f010372c:	c6 80 f8 26 00 00 00 	movb   $0x0,0x26f8(%eax)
f0103733:	c6 80 f9 26 00 00 8f 	movb   $0x8f,0x26f9(%eax)
f010373a:	89 cb                	mov    %ecx,%ebx
f010373c:	c1 eb 10             	shr    $0x10,%ebx
f010373f:	66 89 98 fa 26 00 00 	mov    %bx,0x26fa(%eax)
	SETGATE(idt[T_FPERR], 1, GD_KT, FPERR_Handler, 0);
f0103746:	c7 c2 e0 3d 10 f0    	mov    $0xf0103de0,%edx
f010374c:	66 89 90 04 27 00 00 	mov    %dx,0x2704(%eax)
f0103753:	66 c7 80 06 27 00 00 	movw   $0x8,0x2706(%eax)
f010375a:	08 00 
f010375c:	c6 80 08 27 00 00 00 	movb   $0x0,0x2708(%eax)
f0103763:	c6 80 09 27 00 00 8f 	movb   $0x8f,0x2709(%eax)
f010376a:	c1 ea 10             	shr    $0x10,%edx
f010376d:	66 89 90 0a 27 00 00 	mov    %dx,0x270a(%eax)
	SETGATE(idt[T_ALIGN], 1, GD_KT, ALIGN_Handler, 0);
f0103774:	c7 c2 e4 3d 10 f0    	mov    $0xf0103de4,%edx
f010377a:	66 89 90 0c 27 00 00 	mov    %dx,0x270c(%eax)
f0103781:	66 c7 80 0e 27 00 00 	movw   $0x8,0x270e(%eax)
f0103788:	08 00 
f010378a:	c6 80 10 27 00 00 00 	movb   $0x0,0x2710(%eax)
f0103791:	c6 80 11 27 00 00 8f 	movb   $0x8f,0x2711(%eax)
f0103798:	c1 ea 10             	shr    $0x10,%edx
f010379b:	66 89 90 12 27 00 00 	mov    %dx,0x2712(%eax)
	SETGATE(idt[T_MCHK], 1, GD_KT, MCHK_Handler, 0);
f01037a2:	c7 c2 e8 3d 10 f0    	mov    $0xf0103de8,%edx
f01037a8:	66 89 90 14 27 00 00 	mov    %dx,0x2714(%eax)
f01037af:	66 c7 80 16 27 00 00 	movw   $0x8,0x2716(%eax)
f01037b6:	08 00 
f01037b8:	c6 80 18 27 00 00 00 	movb   $0x0,0x2718(%eax)
f01037bf:	c6 80 19 27 00 00 8f 	movb   $0x8f,0x2719(%eax)
f01037c6:	c1 ea 10             	shr    $0x10,%edx
f01037c9:	66 89 90 1a 27 00 00 	mov    %dx,0x271a(%eax)
	SETGATE(idt[T_SIMDERR], 1, GD_KT, PGFLT_Handler, 0);
f01037d0:	66 89 88 1c 27 00 00 	mov    %cx,0x271c(%eax)
f01037d7:	66 c7 80 1e 27 00 00 	movw   $0x8,0x271e(%eax)
f01037de:	08 00 
f01037e0:	c6 80 20 27 00 00 00 	movb   $0x0,0x2720(%eax)
f01037e7:	c6 80 21 27 00 00 8f 	movb   $0x8f,0x2721(%eax)
f01037ee:	66 89 98 22 27 00 00 	mov    %bx,0x2722(%eax)
	SETGATE(idt[T_SYSCALL], 0, GD_KT, SYSCALL_Handler, 3);
f01037f5:	c7 c2 f0 3d 10 f0    	mov    $0xf0103df0,%edx
f01037fb:	66 89 90 04 28 00 00 	mov    %dx,0x2804(%eax)
f0103802:	66 c7 80 06 28 00 00 	movw   $0x8,0x2806(%eax)
f0103809:	08 00 
f010380b:	c6 80 08 28 00 00 00 	movb   $0x0,0x2808(%eax)
f0103812:	c6 80 09 28 00 00 ee 	movb   $0xee,0x2809(%eax)
f0103819:	c1 ea 10             	shr    $0x10,%edx
f010381c:	66 89 90 0a 28 00 00 	mov    %dx,0x280a(%eax)
	trap_init_percpu();
f0103823:	e8 eb fb ff ff       	call   f0103413 <trap_init_percpu>
}
f0103828:	5b                   	pop    %ebx
f0103829:	5d                   	pop    %ebp
f010382a:	c3                   	ret    

f010382b <print_regs>:
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
	}
}

void print_regs(struct PushRegs *regs) // 打印寄存器的值，print_trapframe()的辅助函数
{
f010382b:	55                   	push   %ebp
f010382c:	89 e5                	mov    %esp,%ebp
f010382e:	56                   	push   %esi
f010382f:	53                   	push   %ebx
f0103830:	e8 7c ca ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0103835:	81 c3 a7 03 13 00    	add    $0x1303a7,%ebx
f010383b:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010383e:	83 ec 08             	sub    $0x8,%esp
f0103841:	ff 36                	pushl  (%esi)
f0103843:	8d 83 33 2e ed ff    	lea    -0x12d1cd(%ebx),%eax
f0103849:	50                   	push   %eax
f010384a:	e8 b0 fb ff ff       	call   f01033ff <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010384f:	83 c4 08             	add    $0x8,%esp
f0103852:	ff 76 04             	pushl  0x4(%esi)
f0103855:	8d 83 42 2e ed ff    	lea    -0x12d1be(%ebx),%eax
f010385b:	50                   	push   %eax
f010385c:	e8 9e fb ff ff       	call   f01033ff <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103861:	83 c4 08             	add    $0x8,%esp
f0103864:	ff 76 08             	pushl  0x8(%esi)
f0103867:	8d 83 51 2e ed ff    	lea    -0x12d1af(%ebx),%eax
f010386d:	50                   	push   %eax
f010386e:	e8 8c fb ff ff       	call   f01033ff <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103873:	83 c4 08             	add    $0x8,%esp
f0103876:	ff 76 0c             	pushl  0xc(%esi)
f0103879:	8d 83 60 2e ed ff    	lea    -0x12d1a0(%ebx),%eax
f010387f:	50                   	push   %eax
f0103880:	e8 7a fb ff ff       	call   f01033ff <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103885:	83 c4 08             	add    $0x8,%esp
f0103888:	ff 76 10             	pushl  0x10(%esi)
f010388b:	8d 83 6f 2e ed ff    	lea    -0x12d191(%ebx),%eax
f0103891:	50                   	push   %eax
f0103892:	e8 68 fb ff ff       	call   f01033ff <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103897:	83 c4 08             	add    $0x8,%esp
f010389a:	ff 76 14             	pushl  0x14(%esi)
f010389d:	8d 83 7e 2e ed ff    	lea    -0x12d182(%ebx),%eax
f01038a3:	50                   	push   %eax
f01038a4:	e8 56 fb ff ff       	call   f01033ff <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01038a9:	83 c4 08             	add    $0x8,%esp
f01038ac:	ff 76 18             	pushl  0x18(%esi)
f01038af:	8d 83 8d 2e ed ff    	lea    -0x12d173(%ebx),%eax
f01038b5:	50                   	push   %eax
f01038b6:	e8 44 fb ff ff       	call   f01033ff <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01038bb:	83 c4 08             	add    $0x8,%esp
f01038be:	ff 76 1c             	pushl  0x1c(%esi)
f01038c1:	8d 83 9c 2e ed ff    	lea    -0x12d164(%ebx),%eax
f01038c7:	50                   	push   %eax
f01038c8:	e8 32 fb ff ff       	call   f01033ff <cprintf>
}
f01038cd:	83 c4 10             	add    $0x10,%esp
f01038d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01038d3:	5b                   	pop    %ebx
f01038d4:	5e                   	pop    %esi
f01038d5:	5d                   	pop    %ebp
f01038d6:	c3                   	ret    

f01038d7 <print_trapframe>:
{
f01038d7:	55                   	push   %ebp
f01038d8:	89 e5                	mov    %esp,%ebp
f01038da:	57                   	push   %edi
f01038db:	56                   	push   %esi
f01038dc:	53                   	push   %ebx
f01038dd:	83 ec 0c             	sub    $0xc,%esp
f01038e0:	e8 cc c9 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f01038e5:	81 c3 f7 02 13 00    	add    $0x1302f7,%ebx
f01038eb:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01038ee:	e8 a8 1a 00 00       	call   f010539b <cpunum>
f01038f3:	83 ec 04             	sub    $0x4,%esp
f01038f6:	50                   	push   %eax
f01038f7:	56                   	push   %esi
f01038f8:	8d 83 00 2f ed ff    	lea    -0x12d100(%ebx),%eax
f01038fe:	50                   	push   %eax
f01038ff:	e8 fb fa ff ff       	call   f01033ff <cprintf>
	print_regs(&tf->tf_regs);
f0103904:	89 34 24             	mov    %esi,(%esp)
f0103907:	e8 1f ff ff ff       	call   f010382b <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010390c:	83 c4 08             	add    $0x8,%esp
f010390f:	0f b7 46 20          	movzwl 0x20(%esi),%eax
f0103913:	50                   	push   %eax
f0103914:	8d 83 1e 2f ed ff    	lea    -0x12d0e2(%ebx),%eax
f010391a:	50                   	push   %eax
f010391b:	e8 df fa ff ff       	call   f01033ff <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103920:	83 c4 08             	add    $0x8,%esp
f0103923:	0f b7 46 24          	movzwl 0x24(%esi),%eax
f0103927:	50                   	push   %eax
f0103928:	8d 83 31 2f ed ff    	lea    -0x12d0cf(%ebx),%eax
f010392e:	50                   	push   %eax
f010392f:	e8 cb fa ff ff       	call   f01033ff <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103934:	8b 46 28             	mov    0x28(%esi),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0103937:	83 c4 10             	add    $0x10,%esp
f010393a:	83 f8 13             	cmp    $0x13,%eax
f010393d:	76 22                	jbe    f0103961 <print_trapframe+0x8a>
		return "System call";
f010393f:	8d 93 ab 2e ed ff    	lea    -0x12d155(%ebx),%edx
	if (trapno == T_SYSCALL)
f0103945:	83 f8 30             	cmp    $0x30,%eax
f0103948:	74 1e                	je     f0103968 <print_trapframe+0x91>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f010394a:	8d 50 e0             	lea    -0x20(%eax),%edx
	return "(unknown trap)";
f010394d:	83 fa 10             	cmp    $0x10,%edx
f0103950:	8d 93 b7 2e ed ff    	lea    -0x12d149(%ebx),%edx
f0103956:	8d 8b ca 2e ed ff    	lea    -0x12d136(%ebx),%ecx
f010395c:	0f 43 d1             	cmovae %ecx,%edx
f010395f:	eb 07                	jmp    f0103968 <print_trapframe+0x91>
		return excnames[trapno];
f0103961:	8b 94 83 e4 14 00 00 	mov    0x14e4(%ebx,%eax,4),%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103968:	83 ec 04             	sub    $0x4,%esp
f010396b:	52                   	push   %edx
f010396c:	50                   	push   %eax
f010396d:	8d 83 44 2f ed ff    	lea    -0x12d0bc(%ebx),%eax
f0103973:	50                   	push   %eax
f0103974:	e8 86 fa ff ff       	call   f01033ff <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103979:	83 c4 10             	add    $0x10,%esp
f010397c:	39 b3 84 2e 00 00    	cmp    %esi,0x2e84(%ebx)
f0103982:	0f 84 b7 00 00 00    	je     f0103a3f <print_trapframe+0x168>
	cprintf("  err  0x%08x", tf->tf_err);
f0103988:	83 ec 08             	sub    $0x8,%esp
f010398b:	ff 76 2c             	pushl  0x2c(%esi)
f010398e:	8d 83 65 2f ed ff    	lea    -0x12d09b(%ebx),%eax
f0103994:	50                   	push   %eax
f0103995:	e8 65 fa ff ff       	call   f01033ff <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f010399a:	83 c4 10             	add    $0x10,%esp
f010399d:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f01039a1:	0f 85 bd 00 00 00    	jne    f0103a64 <print_trapframe+0x18d>
				tf->tf_err & 1 ? "protection" : "not-present");
f01039a7:	8b 46 2c             	mov    0x2c(%esi),%eax
		cprintf(" [%s, %s, %s]\n",
f01039aa:	89 c2                	mov    %eax,%edx
f01039ac:	83 e2 01             	and    $0x1,%edx
f01039af:	8d 8b d9 2e ed ff    	lea    -0x12d127(%ebx),%ecx
f01039b5:	8d 93 e4 2e ed ff    	lea    -0x12d11c(%ebx),%edx
f01039bb:	0f 44 ca             	cmove  %edx,%ecx
f01039be:	89 c2                	mov    %eax,%edx
f01039c0:	83 e2 02             	and    $0x2,%edx
f01039c3:	8d 93 f0 2e ed ff    	lea    -0x12d110(%ebx),%edx
f01039c9:	8d bb f6 2e ed ff    	lea    -0x12d10a(%ebx),%edi
f01039cf:	0f 44 d7             	cmove  %edi,%edx
f01039d2:	83 e0 04             	and    $0x4,%eax
f01039d5:	8d 83 fb 2e ed ff    	lea    -0x12d105(%ebx),%eax
f01039db:	8d bb 30 30 ed ff    	lea    -0x12cfd0(%ebx),%edi
f01039e1:	0f 44 c7             	cmove  %edi,%eax
f01039e4:	51                   	push   %ecx
f01039e5:	52                   	push   %edx
f01039e6:	50                   	push   %eax
f01039e7:	8d 83 73 2f ed ff    	lea    -0x12d08d(%ebx),%eax
f01039ed:	50                   	push   %eax
f01039ee:	e8 0c fa ff ff       	call   f01033ff <cprintf>
f01039f3:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01039f6:	83 ec 08             	sub    $0x8,%esp
f01039f9:	ff 76 30             	pushl  0x30(%esi)
f01039fc:	8d 83 82 2f ed ff    	lea    -0x12d07e(%ebx),%eax
f0103a02:	50                   	push   %eax
f0103a03:	e8 f7 f9 ff ff       	call   f01033ff <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103a08:	83 c4 08             	add    $0x8,%esp
f0103a0b:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103a0f:	50                   	push   %eax
f0103a10:	8d 83 91 2f ed ff    	lea    -0x12d06f(%ebx),%eax
f0103a16:	50                   	push   %eax
f0103a17:	e8 e3 f9 ff ff       	call   f01033ff <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103a1c:	83 c4 08             	add    $0x8,%esp
f0103a1f:	ff 76 38             	pushl  0x38(%esi)
f0103a22:	8d 83 a4 2f ed ff    	lea    -0x12d05c(%ebx),%eax
f0103a28:	50                   	push   %eax
f0103a29:	e8 d1 f9 ff ff       	call   f01033ff <cprintf>
	if ((tf->tf_cs & 3) != 0)
f0103a2e:	83 c4 10             	add    $0x10,%esp
f0103a31:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0103a35:	75 44                	jne    f0103a7b <print_trapframe+0x1a4>
}
f0103a37:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103a3a:	5b                   	pop    %ebx
f0103a3b:	5e                   	pop    %esi
f0103a3c:	5f                   	pop    %edi
f0103a3d:	5d                   	pop    %ebp
f0103a3e:	c3                   	ret    
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103a3f:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0103a43:	0f 85 3f ff ff ff    	jne    f0103988 <print_trapframe+0xb1>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103a49:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103a4c:	83 ec 08             	sub    $0x8,%esp
f0103a4f:	50                   	push   %eax
f0103a50:	8d 83 56 2f ed ff    	lea    -0x12d0aa(%ebx),%eax
f0103a56:	50                   	push   %eax
f0103a57:	e8 a3 f9 ff ff       	call   f01033ff <cprintf>
f0103a5c:	83 c4 10             	add    $0x10,%esp
f0103a5f:	e9 24 ff ff ff       	jmp    f0103988 <print_trapframe+0xb1>
		cprintf("\n");
f0103a64:	83 ec 0c             	sub    $0xc,%esp
f0103a67:	8d 83 d1 1f ed ff    	lea    -0x12e02f(%ebx),%eax
f0103a6d:	50                   	push   %eax
f0103a6e:	e8 8c f9 ff ff       	call   f01033ff <cprintf>
f0103a73:	83 c4 10             	add    $0x10,%esp
f0103a76:	e9 7b ff ff ff       	jmp    f01039f6 <print_trapframe+0x11f>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103a7b:	83 ec 08             	sub    $0x8,%esp
f0103a7e:	ff 76 3c             	pushl  0x3c(%esi)
f0103a81:	8d 83 b3 2f ed ff    	lea    -0x12d04d(%ebx),%eax
f0103a87:	50                   	push   %eax
f0103a88:	e8 72 f9 ff ff       	call   f01033ff <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103a8d:	83 c4 08             	add    $0x8,%esp
f0103a90:	0f b7 46 40          	movzwl 0x40(%esi),%eax
f0103a94:	50                   	push   %eax
f0103a95:	8d 83 c2 2f ed ff    	lea    -0x12d03e(%ebx),%eax
f0103a9b:	50                   	push   %eax
f0103a9c:	e8 5e f9 ff ff       	call   f01033ff <cprintf>
f0103aa1:	83 c4 10             	add    $0x10,%esp
}
f0103aa4:	eb 91                	jmp    f0103a37 <print_trapframe+0x160>

f0103aa6 <page_fault_handler>:
	else
		sched_yield();
}

void page_fault_handler(struct Trapframe *tf) // 特殊处理页错误中断
{
f0103aa6:	55                   	push   %ebp
f0103aa7:	89 e5                	mov    %esp,%ebp
f0103aa9:	57                   	push   %edi
f0103aaa:	56                   	push   %esi
f0103aab:	53                   	push   %ebx
f0103aac:	83 ec 0c             	sub    $0xc,%esp
f0103aaf:	e8 fd c7 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0103ab4:	81 c3 28 01 13 00    	add    $0x130128,%ebx
f0103aba:	0f 20 d6             	mov    %cr2,%esi
	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0) // 处于内核模式
f0103abd:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ac0:	f6 40 34 03          	testb  $0x3,0x34(%eax)
f0103ac4:	74 53                	je     f0103b19 <page_fault_handler+0x73>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ac6:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ac9:	8b 78 30             	mov    0x30(%eax),%edi
			curenv->env_id, fault_va, tf->tf_eip);
f0103acc:	e8 ca 18 00 00       	call   f010539b <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ad1:	57                   	push   %edi
f0103ad2:	56                   	push   %esi
			curenv->env_id, fault_va, tf->tf_eip);
f0103ad3:	c7 c6 20 70 23 f0    	mov    $0xf0237020,%esi
f0103ad9:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103adc:	8b 44 06 08          	mov    0x8(%esi,%eax,1),%eax
f0103ae0:	ff 70 48             	pushl  0x48(%eax)
f0103ae3:	8d 83 ac 31 ed ff    	lea    -0x12ce54(%ebx),%eax
f0103ae9:	50                   	push   %eax
f0103aea:	e8 10 f9 ff ff       	call   f01033ff <cprintf>
	print_trapframe(tf);
f0103aef:	83 c4 04             	add    $0x4,%esp
f0103af2:	ff 75 08             	pushl  0x8(%ebp)
f0103af5:	e8 dd fd ff ff       	call   f01038d7 <print_trapframe>
	env_destroy(curenv);
f0103afa:	e8 9c 18 00 00       	call   f010539b <cpunum>
f0103aff:	83 c4 04             	add    $0x4,%esp
f0103b02:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b05:	ff 74 06 08          	pushl  0x8(%esi,%eax,1)
f0103b09:	e8 a5 f5 ff ff       	call   f01030b3 <env_destroy>
}
f0103b0e:	83 c4 10             	add    $0x10,%esp
f0103b11:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103b14:	5b                   	pop    %ebx
f0103b15:	5e                   	pop    %esi
f0103b16:	5f                   	pop    %edi
f0103b17:	5d                   	pop    %ebp
f0103b18:	c3                   	ret    
		panic("page_fault_handler(): kernel-mode page faults");
f0103b19:	83 ec 04             	sub    $0x4,%esp
f0103b1c:	8d 83 7c 31 ed ff    	lea    -0x12ce84(%ebx),%eax
f0103b22:	50                   	push   %eax
f0103b23:	68 51 01 00 00       	push   $0x151
f0103b28:	8d 83 d5 2f ed ff    	lea    -0x12d02b(%ebx),%eax
f0103b2e:	50                   	push   %eax
f0103b2f:	e8 0c c5 ff ff       	call   f0100040 <_panic>

f0103b34 <trap>:
{
f0103b34:	55                   	push   %ebp
f0103b35:	89 e5                	mov    %esp,%ebp
f0103b37:	57                   	push   %edi
f0103b38:	56                   	push   %esi
f0103b39:	53                   	push   %ebx
f0103b3a:	83 ec 1c             	sub    $0x1c,%esp
f0103b3d:	e8 6f c7 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0103b42:	81 c3 9a 00 13 00    	add    $0x13009a,%ebx
f0103b48:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::
f0103b4b:	fc                   	cld    
	if (panicstr)
f0103b4c:	c7 c0 00 6f 23 f0    	mov    $0xf0236f00,%eax
f0103b52:	83 38 00             	cmpl   $0x0,(%eax)
f0103b55:	74 01                	je     f0103b58 <trap+0x24>
		asm volatile("hlt");
f0103b57:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103b58:	e8 3e 18 00 00       	call   f010539b <cpunum>
f0103b5d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b60:	c7 c2 20 70 23 f0    	mov    $0xf0237020,%edx
f0103b66:	8d 54 10 04          	lea    0x4(%eax,%edx,1),%edx
	asm volatile("lock; xchgl %0, %1"
f0103b6a:	b8 01 00 00 00       	mov    $0x1,%eax
f0103b6f:	f0 87 02             	lock xchg %eax,(%edx)
f0103b72:	83 f8 02             	cmp    $0x2,%eax
f0103b75:	0f 84 81 00 00 00    	je     f0103bfc <trap+0xc8>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103b7b:	9c                   	pushf  
f0103b7c:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0103b7d:	f6 c4 02             	test   $0x2,%ah
f0103b80:	0f 85 8c 00 00 00    	jne    f0103c12 <trap+0xde>
	if ((tf->tf_cs & 3) == 3)
f0103b86:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103b8a:	83 e0 03             	and    $0x3,%eax
f0103b8d:	66 83 f8 03          	cmp    $0x3,%ax
f0103b91:	0f 84 9a 00 00 00    	je     f0103c31 <trap+0xfd>
	last_tf = tf;
f0103b97:	89 b3 84 2e 00 00    	mov    %esi,0x2e84(%ebx)
	switch (tf->tf_trapno)
f0103b9d:	8b 46 28             	mov    0x28(%esi),%eax
f0103ba0:	83 f8 0e             	cmp    $0xe,%eax
f0103ba3:	0f 84 33 01 00 00    	je     f0103cdc <trap+0x1a8>
f0103ba9:	83 f8 30             	cmp    $0x30,%eax
f0103bac:	0f 84 74 01 00 00    	je     f0103d26 <trap+0x1f2>
f0103bb2:	83 f8 03             	cmp    $0x3,%eax
f0103bb5:	0f 84 5d 01 00 00    	je     f0103d18 <trap+0x1e4>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103bbb:	83 f8 27             	cmp    $0x27,%eax
f0103bbe:	0f 84 83 01 00 00    	je     f0103d47 <trap+0x213>
	print_trapframe(tf);
f0103bc4:	83 ec 0c             	sub    $0xc,%esp
f0103bc7:	56                   	push   %esi
f0103bc8:	e8 0a fd ff ff       	call   f01038d7 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103bcd:	83 c4 10             	add    $0x10,%esp
f0103bd0:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103bd5:	0f 84 88 01 00 00    	je     f0103d63 <trap+0x22f>
		env_destroy(curenv);
f0103bdb:	e8 bb 17 00 00       	call   f010539b <cpunum>
f0103be0:	83 ec 0c             	sub    $0xc,%esp
f0103be3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103be6:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0103bec:	ff 70 08             	pushl  0x8(%eax)
f0103bef:	e8 bf f4 ff ff       	call   f01030b3 <env_destroy>
f0103bf4:	83 c4 10             	add    $0x10,%esp
f0103bf7:	e9 ec 00 00 00       	jmp    f0103ce8 <trap+0x1b4>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0103bfc:	83 ec 0c             	sub    $0xc,%esp
f0103bff:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f0103c05:	e8 62 1a 00 00       	call   f010566c <spin_lock>
f0103c0a:	83 c4 10             	add    $0x10,%esp
f0103c0d:	e9 69 ff ff ff       	jmp    f0103b7b <trap+0x47>
	assert(!(read_eflags() & FL_IF));
f0103c12:	8d 83 e1 2f ed ff    	lea    -0x12d01f(%ebx),%eax
f0103c18:	50                   	push   %eax
f0103c19:	8d 83 07 2b ed ff    	lea    -0x12d4f9(%ebx),%eax
f0103c1f:	50                   	push   %eax
f0103c20:	68 19 01 00 00       	push   $0x119
f0103c25:	8d 83 d5 2f ed ff    	lea    -0x12d02b(%ebx),%eax
f0103c2b:	50                   	push   %eax
f0103c2c:	e8 0f c4 ff ff       	call   f0100040 <_panic>
		assert(curenv);
f0103c31:	e8 65 17 00 00       	call   f010539b <cpunum>
f0103c36:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c39:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0103c3f:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0103c43:	74 49                	je     f0103c8e <trap+0x15a>
		if (curenv->env_status == ENV_DYING) {
f0103c45:	e8 51 17 00 00       	call   f010539b <cpunum>
f0103c4a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c4d:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0103c53:	8b 40 08             	mov    0x8(%eax),%eax
f0103c56:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103c5a:	74 51                	je     f0103cad <trap+0x179>
		curenv->env_tf = *tf;
f0103c5c:	e8 3a 17 00 00       	call   f010539b <cpunum>
f0103c61:	c7 c1 20 70 23 f0    	mov    $0xf0237020,%ecx
f0103c67:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c6a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0103c6d:	8b 44 01 08          	mov    0x8(%ecx,%eax,1),%eax
f0103c71:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103c76:	89 c7                	mov    %eax,%edi
f0103c78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0103c7a:	e8 1c 17 00 00       	call   f010539b <cpunum>
f0103c7f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c82:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103c85:	8b 74 01 08          	mov    0x8(%ecx,%eax,1),%esi
f0103c89:	e9 09 ff ff ff       	jmp    f0103b97 <trap+0x63>
		assert(curenv);
f0103c8e:	8d 83 fa 2f ed ff    	lea    -0x12d006(%ebx),%eax
f0103c94:	50                   	push   %eax
f0103c95:	8d 83 07 2b ed ff    	lea    -0x12d4f9(%ebx),%eax
f0103c9b:	50                   	push   %eax
f0103c9c:	68 22 01 00 00       	push   $0x122
f0103ca1:	8d 83 d5 2f ed ff    	lea    -0x12d02b(%ebx),%eax
f0103ca7:	50                   	push   %eax
f0103ca8:	e8 93 c3 ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f0103cad:	e8 e9 16 00 00       	call   f010539b <cpunum>
f0103cb2:	83 ec 0c             	sub    $0xc,%esp
f0103cb5:	c7 c6 20 70 23 f0    	mov    $0xf0237020,%esi
f0103cbb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cbe:	ff 74 06 08          	pushl  0x8(%esi,%eax,1)
f0103cc2:	e8 b9 f1 ff ff       	call   f0102e80 <env_free>
			curenv = NULL;
f0103cc7:	e8 cf 16 00 00       	call   f010539b <cpunum>
f0103ccc:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ccf:	c7 44 06 08 00 00 00 	movl   $0x0,0x8(%esi,%eax,1)
f0103cd6:	00 
			sched_yield();
f0103cd7:	e8 1c 02 00 00       	call   f0103ef8 <sched_yield>
		page_fault_handler(tf);
f0103cdc:	83 ec 0c             	sub    $0xc,%esp
f0103cdf:	56                   	push   %esi
f0103ce0:	e8 c1 fd ff ff       	call   f0103aa6 <page_fault_handler>
f0103ce5:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103ce8:	e8 ae 16 00 00       	call   f010539b <cpunum>
f0103ced:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cf0:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0103cf6:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0103cfa:	74 17                	je     f0103d13 <trap+0x1df>
f0103cfc:	e8 9a 16 00 00       	call   f010539b <cpunum>
f0103d01:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d04:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0103d0a:	8b 40 08             	mov    0x8(%eax),%eax
f0103d0d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d11:	74 6b                	je     f0103d7e <trap+0x24a>
		sched_yield();
f0103d13:	e8 e0 01 00 00       	call   f0103ef8 <sched_yield>
		monitor(tf);
f0103d18:	83 ec 0c             	sub    $0xc,%esp
f0103d1b:	56                   	push   %esi
f0103d1c:	e8 5b cd ff ff       	call   f0100a7c <monitor>
f0103d21:	83 c4 10             	add    $0x10,%esp
f0103d24:	eb c2                	jmp    f0103ce8 <trap+0x1b4>
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx,
f0103d26:	83 ec 08             	sub    $0x8,%esp
f0103d29:	ff 76 04             	pushl  0x4(%esi)
f0103d2c:	ff 36                	pushl  (%esi)
f0103d2e:	ff 76 10             	pushl  0x10(%esi)
f0103d31:	ff 76 18             	pushl  0x18(%esi)
f0103d34:	ff 76 14             	pushl  0x14(%esi)
f0103d37:	ff 76 1c             	pushl  0x1c(%esi)
f0103d3a:	e8 c6 01 00 00       	call   f0103f05 <syscall>
f0103d3f:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103d42:	83 c4 20             	add    $0x20,%esp
f0103d45:	eb a1                	jmp    f0103ce8 <trap+0x1b4>
		cprintf("Spurious interrupt on irq 7\n");
f0103d47:	83 ec 0c             	sub    $0xc,%esp
f0103d4a:	8d 83 01 30 ed ff    	lea    -0x12cfff(%ebx),%eax
f0103d50:	50                   	push   %eax
f0103d51:	e8 a9 f6 ff ff       	call   f01033ff <cprintf>
		print_trapframe(tf);
f0103d56:	89 34 24             	mov    %esi,(%esp)
f0103d59:	e8 79 fb ff ff       	call   f01038d7 <print_trapframe>
f0103d5e:	83 c4 10             	add    $0x10,%esp
f0103d61:	eb 85                	jmp    f0103ce8 <trap+0x1b4>
		panic("unhandled trap in kernel");
f0103d63:	83 ec 04             	sub    $0x4,%esp
f0103d66:	8d 83 1e 30 ed ff    	lea    -0x12cfe2(%ebx),%eax
f0103d6c:	50                   	push   %eax
f0103d6d:	68 fe 00 00 00       	push   $0xfe
f0103d72:	8d 83 d5 2f ed ff    	lea    -0x12d02b(%ebx),%eax
f0103d78:	50                   	push   %eax
f0103d79:	e8 c2 c2 ff ff       	call   f0100040 <_panic>
		env_run(curenv); // 返回用户态
f0103d7e:	e8 18 16 00 00       	call   f010539b <cpunum>
f0103d83:	83 ec 0c             	sub    $0xc,%esp
f0103d86:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d89:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0103d8f:	ff 70 08             	pushl  0x8(%eax)
f0103d92:	e8 df f3 ff ff       	call   f0103176 <env_run>
f0103d97:	90                   	nop

f0103d98 <DIVIDE_Handler>:
 * TRAPHANDLER(name, num):是一个宏，等效于一个从name标记的地址开始的几行指令
 * name是你为这个num的中断设置的中断处理程序的函数名，num由inc\trap.h定义
 * 经过下面的设置，这个汇编文件里存在很多个以handler为名的函数，可以在C中使用void XXX_Hander()去声明函数，
 * 这时，这个hander函数的地址将被链接到下面对应hander的行。
 */
TRAPHANDLER_NOEC(DIVIDE_Handler, T_DIVIDE)
f0103d98:	6a 00                	push   $0x0
f0103d9a:	6a 00                	push   $0x0
f0103d9c:	eb 58                	jmp    f0103df6 <_alltraps>

f0103d9e <DEBUG_Handler>:
TRAPHANDLER_NOEC(DEBUG_Handler, T_DEBUG)
f0103d9e:	6a 00                	push   $0x0
f0103da0:	6a 01                	push   $0x1
f0103da2:	eb 52                	jmp    f0103df6 <_alltraps>

f0103da4 <NMI_Handler>:
TRAPHANDLER_NOEC(NMI_Handler, T_NMI)
f0103da4:	6a 00                	push   $0x0
f0103da6:	6a 02                	push   $0x2
f0103da8:	eb 4c                	jmp    f0103df6 <_alltraps>

f0103daa <BRKPT_Handler>:
TRAPHANDLER_NOEC(BRKPT_Handler, T_BRKPT)
f0103daa:	6a 00                	push   $0x0
f0103dac:	6a 03                	push   $0x3
f0103dae:	eb 46                	jmp    f0103df6 <_alltraps>

f0103db0 <OFLOW_Handler>:
TRAPHANDLER_NOEC(OFLOW_Handler, T_OFLOW)
f0103db0:	6a 00                	push   $0x0
f0103db2:	6a 04                	push   $0x4
f0103db4:	eb 40                	jmp    f0103df6 <_alltraps>

f0103db6 <BOUND_Handler>:
TRAPHANDLER_NOEC(BOUND_Handler, T_BOUND)
f0103db6:	6a 00                	push   $0x0
f0103db8:	6a 05                	push   $0x5
f0103dba:	eb 3a                	jmp    f0103df6 <_alltraps>

f0103dbc <ILLOP_Handler>:
TRAPHANDLER_NOEC(ILLOP_Handler, T_ILLOP)
f0103dbc:	6a 00                	push   $0x0
f0103dbe:	6a 06                	push   $0x6
f0103dc0:	eb 34                	jmp    f0103df6 <_alltraps>

f0103dc2 <DEVICE_Handler>:
TRAPHANDLER_NOEC(DEVICE_Handler, T_DEVICE)
f0103dc2:	6a 00                	push   $0x0
f0103dc4:	6a 07                	push   $0x7
f0103dc6:	eb 2e                	jmp    f0103df6 <_alltraps>

f0103dc8 <DBLFLT_Handler>:
TRAPHANDLER(DBLFLT_Handler, T_DBLFLT)
f0103dc8:	6a 08                	push   $0x8
f0103dca:	eb 2a                	jmp    f0103df6 <_alltraps>

f0103dcc <TSS_Handler>:

TRAPHANDLER(TSS_Handler, T_TSS)
f0103dcc:	6a 0a                	push   $0xa
f0103dce:	eb 26                	jmp    f0103df6 <_alltraps>

f0103dd0 <SEGNP_Handler>:
TRAPHANDLER(SEGNP_Handler, T_SEGNP)
f0103dd0:	6a 0b                	push   $0xb
f0103dd2:	eb 22                	jmp    f0103df6 <_alltraps>

f0103dd4 <STACK_Handler>:
TRAPHANDLER(STACK_Handler, T_STACK)
f0103dd4:	6a 0c                	push   $0xc
f0103dd6:	eb 1e                	jmp    f0103df6 <_alltraps>

f0103dd8 <GPFLT_Handler>:
TRAPHANDLER(GPFLT_Handler, T_GPFLT)
f0103dd8:	6a 0d                	push   $0xd
f0103dda:	eb 1a                	jmp    f0103df6 <_alltraps>

f0103ddc <PGFLT_Handler>:
TRAPHANDLER(PGFLT_Handler, T_PGFLT)
f0103ddc:	6a 0e                	push   $0xe
f0103dde:	eb 16                	jmp    f0103df6 <_alltraps>

f0103de0 <FPERR_Handler>:

TRAPHANDLER(FPERR_Handler, T_FPERR)
f0103de0:	6a 10                	push   $0x10
f0103de2:	eb 12                	jmp    f0103df6 <_alltraps>

f0103de4 <ALIGN_Handler>:
TRAPHANDLER(ALIGN_Handler, T_ALIGN)
f0103de4:	6a 11                	push   $0x11
f0103de6:	eb 0e                	jmp    f0103df6 <_alltraps>

f0103de8 <MCHK_Handler>:
TRAPHANDLER(MCHK_Handler, T_MCHK)
f0103de8:	6a 12                	push   $0x12
f0103dea:	eb 0a                	jmp    f0103df6 <_alltraps>

f0103dec <SIMDERR_Handler>:
TRAPHANDLER(SIMDERR_Handler, T_SIMDERR)
f0103dec:	6a 13                	push   $0x13
f0103dee:	eb 06                	jmp    f0103df6 <_alltraps>

f0103df0 <SYSCALL_Handler>:

TRAPHANDLER_NOEC(SYSCALL_Handler, T_SYSCALL)
f0103df0:	6a 00                	push   $0x0
f0103df2:	6a 30                	push   $0x30
f0103df4:	eb 00                	jmp    f0103df6 <_alltraps>

f0103df6 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
.globl		_start
_alltraps:
	pushl	%ds		/* 后面要将GD_KD加载到%ds和%es，先保存旧的 */
f0103df6:	1e                   	push   %ds
	pushl	%es
f0103df7:	06                   	push   %es
	pushal			/* 直接推送整个TrapFrame */
f0103df8:	60                   	pusha  
	movw 	$GD_KD, %ax /* 不能直接设置，因此先复制到%ax */
f0103df9:	66 b8 10 00          	mov    $0x10,%ax
  	movw 	%ax, %ds
f0103dfd:	8e d8                	mov    %eax,%ds
  	movw 	%ax, %es
f0103dff:	8e c0                	mov    %eax,%es
	pushl 	%esp	/* %esp指向Trapframe顶部，作为参数传递给trap */
f0103e01:	54                   	push   %esp
	call	trap	/* 调用c程序trap，执行中断处理程序 */
f0103e02:	e8 2d fd ff ff       	call   f0103b34 <trap>

f0103e07 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0103e07:	55                   	push   %ebp
f0103e08:	89 e5                	mov    %esp,%ebp
f0103e0a:	56                   	push   %esi
f0103e0b:	53                   	push   %ebx
f0103e0c:	e8 a0 c4 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0103e11:	81 c3 cb fd 12 00    	add    $0x12fdcb,%ebx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0103e17:	c7 c0 48 62 23 f0    	mov    $0xf0236248,%eax
f0103e1d:	8b 00                	mov    (%eax),%eax
f0103e1f:	83 c0 54             	add    $0x54,%eax
	for (i = 0; i < NENV; i++) {
f0103e22:	b9 00 00 00 00       	mov    $0x0,%ecx
		     envs[i].env_status == ENV_RUNNING ||
f0103e27:	8b 30                	mov    (%eax),%esi
f0103e29:	8d 56 ff             	lea    -0x1(%esi),%edx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0103e2c:	83 fa 02             	cmp    $0x2,%edx
f0103e2f:	76 2f                	jbe    f0103e60 <sched_halt+0x59>
	for (i = 0; i < NENV; i++) {
f0103e31:	83 c1 01             	add    $0x1,%ecx
f0103e34:	83 c0 7c             	add    $0x7c,%eax
f0103e37:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103e3d:	75 e8                	jne    f0103e27 <sched_halt+0x20>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f0103e3f:	83 ec 0c             	sub    $0xc,%esp
f0103e42:	8d 83 d0 31 ed ff    	lea    -0x12ce30(%ebx),%eax
f0103e48:	50                   	push   %eax
f0103e49:	e8 b1 f5 ff ff       	call   f01033ff <cprintf>
f0103e4e:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0103e51:	83 ec 0c             	sub    $0xc,%esp
f0103e54:	6a 00                	push   $0x0
f0103e56:	e8 21 cc ff ff       	call   f0100a7c <monitor>
f0103e5b:	83 c4 10             	add    $0x10,%esp
f0103e5e:	eb f1                	jmp    f0103e51 <sched_halt+0x4a>
	if (i == NENV) {
f0103e60:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103e66:	74 d7                	je     f0103e3f <sched_halt+0x38>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0103e68:	e8 2e 15 00 00       	call   f010539b <cpunum>
f0103e6d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e70:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0103e76:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	lcr3(PADDR(kern_pgdir));
f0103e7d:	c7 c0 0c 6f 23 f0    	mov    $0xf0236f0c,%eax
f0103e83:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103e85:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103e8a:	76 56                	jbe    f0103ee2 <sched_halt+0xdb>
	return (physaddr_t)kva - KERNBASE;
f0103e8c:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103e91:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0103e94:	e8 02 15 00 00       	call   f010539b <cpunum>
f0103e99:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e9c:	c7 c6 20 70 23 f0    	mov    $0xf0237020,%esi
f0103ea2:	8d 54 30 04          	lea    0x4(%eax,%esi,1),%edx
	asm volatile("lock; xchgl %0, %1"
f0103ea6:	b8 02 00 00 00       	mov    $0x2,%eax
f0103eab:	f0 87 02             	lock xchg %eax,(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103eae:	83 ec 0c             	sub    $0xc,%esp
f0103eb1:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f0103eb7:	e8 63 18 00 00       	call   f010571f <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103ebc:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0103ebe:	e8 d8 14 00 00       	call   f010539b <cpunum>
f0103ec3:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f0103ec6:	8b 44 06 10          	mov    0x10(%esi,%eax,1),%eax
f0103eca:	bd 00 00 00 00       	mov    $0x0,%ebp
f0103ecf:	89 c4                	mov    %eax,%esp
f0103ed1:	6a 00                	push   $0x0
f0103ed3:	6a 00                	push   $0x0
f0103ed5:	f4                   	hlt    
f0103ed6:	eb fd                	jmp    f0103ed5 <sched_halt+0xce>
}
f0103ed8:	83 c4 10             	add    $0x10,%esp
f0103edb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103ede:	5b                   	pop    %ebx
f0103edf:	5e                   	pop    %esi
f0103ee0:	5d                   	pop    %ebp
f0103ee1:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ee2:	50                   	push   %eax
f0103ee3:	8d 83 4c 1f ed ff    	lea    -0x12e0b4(%ebx),%eax
f0103ee9:	50                   	push   %eax
f0103eea:	6a 3d                	push   $0x3d
f0103eec:	8d 83 f9 31 ed ff    	lea    -0x12ce07(%ebx),%eax
f0103ef2:	50                   	push   %eax
f0103ef3:	e8 48 c1 ff ff       	call   f0100040 <_panic>

f0103ef8 <sched_yield>:
{
f0103ef8:	55                   	push   %ebp
f0103ef9:	89 e5                	mov    %esp,%ebp
f0103efb:	83 ec 08             	sub    $0x8,%esp
	sched_halt();
f0103efe:	e8 04 ff ff ff       	call   f0103e07 <sched_halt>
}
f0103f03:	c9                   	leave  
f0103f04:	c3                   	ret    

f0103f05 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103f05:	55                   	push   %ebp
f0103f06:	89 e5                	mov    %esp,%ebp
f0103f08:	56                   	push   %esi
f0103f09:	53                   	push   %ebx
f0103f0a:	83 ec 10             	sub    $0x10,%esp
f0103f0d:	e8 9f c3 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0103f12:	81 c3 ca fc 12 00    	add    $0x12fcca,%ebx
f0103f18:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) // 根据系统调用编号，调用相应的处理函数，枚举值即为inc\syscall.h中定义的值
f0103f1b:	83 f8 01             	cmp    $0x1,%eax
f0103f1e:	74 58                	je     f0103f78 <syscall+0x73>
f0103f20:	83 f8 01             	cmp    $0x1,%eax
f0103f23:	72 11                	jb     f0103f36 <syscall+0x31>
f0103f25:	83 f8 02             	cmp    $0x2,%eax
f0103f28:	74 55                	je     f0103f7f <syscall+0x7a>
f0103f2a:	83 f8 03             	cmp    $0x3,%eax
f0103f2d:	74 66                	je     f0103f95 <syscall+0x90>
		return sys_getenvid();
	case SYS_env_destroy:
		return sys_env_destroy((envid_t)a1);
	case NSYSCALLS:
	default:
		return -E_INVAL;
f0103f2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103f34:	eb 3b                	jmp    f0103f71 <syscall+0x6c>
	user_mem_assert(curenv, s, len, PTE_U);
f0103f36:	e8 60 14 00 00       	call   f010539b <cpunum>
f0103f3b:	6a 04                	push   $0x4
f0103f3d:	ff 75 10             	pushl  0x10(%ebp)
f0103f40:	ff 75 0c             	pushl  0xc(%ebp)
f0103f43:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f46:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0103f4c:	ff 70 08             	pushl  0x8(%eax)
f0103f4f:	e8 d5 e9 ff ff       	call   f0102929 <user_mem_assert>
	cprintf("%.*s", len, s);
f0103f54:	83 c4 0c             	add    $0xc,%esp
f0103f57:	ff 75 0c             	pushl  0xc(%ebp)
f0103f5a:	ff 75 10             	pushl  0x10(%ebp)
f0103f5d:	8d 83 06 32 ed ff    	lea    -0x12cdfa(%ebx),%eax
f0103f63:	50                   	push   %eax
f0103f64:	e8 96 f4 ff ff       	call   f01033ff <cprintf>
f0103f69:	83 c4 10             	add    $0x10,%esp
		return 0;
f0103f6c:	b8 00 00 00 00       	mov    $0x0,%eax
	}
}
f0103f71:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103f74:	5b                   	pop    %ebx
f0103f75:	5e                   	pop    %esi
f0103f76:	5d                   	pop    %ebp
f0103f77:	c3                   	ret    
	return cons_getc();
f0103f78:	e8 2f c7 ff ff       	call   f01006ac <cons_getc>
		return sys_cgetc();
f0103f7d:	eb f2                	jmp    f0103f71 <syscall+0x6c>
	return curenv->env_id;
f0103f7f:	e8 17 14 00 00       	call   f010539b <cpunum>
f0103f84:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f87:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0103f8d:	8b 40 08             	mov    0x8(%eax),%eax
f0103f90:	8b 40 48             	mov    0x48(%eax),%eax
		return sys_getenvid();
f0103f93:	eb dc                	jmp    f0103f71 <syscall+0x6c>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0103f95:	83 ec 04             	sub    $0x4,%esp
f0103f98:	6a 01                	push   $0x1
f0103f9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f9d:	50                   	push   %eax
f0103f9e:	ff 75 0c             	pushl  0xc(%ebp)
f0103fa1:	e8 84 ea ff ff       	call   f0102a2a <envid2env>
f0103fa6:	83 c4 10             	add    $0x10,%esp
f0103fa9:	85 c0                	test   %eax,%eax
f0103fab:	78 c4                	js     f0103f71 <syscall+0x6c>
	if (e == curenv)
f0103fad:	e8 e9 13 00 00       	call   f010539b <cpunum>
f0103fb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103fb5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fb8:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0103fbe:	39 50 08             	cmp    %edx,0x8(%eax)
f0103fc1:	74 42                	je     f0104005 <syscall+0x100>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103fc3:	8b 72 48             	mov    0x48(%edx),%esi
f0103fc6:	e8 d0 13 00 00       	call   f010539b <cpunum>
f0103fcb:	83 ec 04             	sub    $0x4,%esp
f0103fce:	56                   	push   %esi
f0103fcf:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fd2:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0103fd8:	8b 40 08             	mov    0x8(%eax),%eax
f0103fdb:	ff 70 48             	pushl  0x48(%eax)
f0103fde:	8d 83 26 32 ed ff    	lea    -0x12cdda(%ebx),%eax
f0103fe4:	50                   	push   %eax
f0103fe5:	e8 15 f4 ff ff       	call   f01033ff <cprintf>
f0103fea:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0103fed:	83 ec 0c             	sub    $0xc,%esp
f0103ff0:	ff 75 f4             	pushl  -0xc(%ebp)
f0103ff3:	e8 bb f0 ff ff       	call   f01030b3 <env_destroy>
f0103ff8:	83 c4 10             	add    $0x10,%esp
	return 0;
f0103ffb:	b8 00 00 00 00       	mov    $0x0,%eax
		return sys_env_destroy((envid_t)a1);
f0104000:	e9 6c ff ff ff       	jmp    f0103f71 <syscall+0x6c>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104005:	e8 91 13 00 00       	call   f010539b <cpunum>
f010400a:	83 ec 08             	sub    $0x8,%esp
f010400d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104010:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0104016:	8b 40 08             	mov    0x8(%eax),%eax
f0104019:	ff 70 48             	pushl  0x48(%eax)
f010401c:	8d 83 0b 32 ed ff    	lea    -0x12cdf5(%ebx),%eax
f0104022:	50                   	push   %eax
f0104023:	e8 d7 f3 ff ff       	call   f01033ff <cprintf>
f0104028:	83 c4 10             	add    $0x10,%esp
f010402b:	eb c0                	jmp    f0103fed <syscall+0xe8>

f010402d <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
			   int type, uintptr_t addr)
{
f010402d:	55                   	push   %ebp
f010402e:	89 e5                	mov    %esp,%ebp
f0104030:	57                   	push   %edi
f0104031:	56                   	push   %esi
f0104032:	53                   	push   %ebx
f0104033:	83 ec 14             	sub    $0x14,%esp
f0104036:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104039:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010403c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010403f:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104042:	8b 32                	mov    (%edx),%esi
f0104044:	8b 01                	mov    (%ecx),%eax
f0104046:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104049:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r)
f0104050:	eb 2f                	jmp    f0104081 <stab_binsearch+0x54>
	{
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104052:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0104055:	39 c6                	cmp    %eax,%esi
f0104057:	7f 49                	jg     f01040a2 <stab_binsearch+0x75>
f0104059:	0f b6 0a             	movzbl (%edx),%ecx
f010405c:	83 ea 0c             	sub    $0xc,%edx
f010405f:	39 f9                	cmp    %edi,%ecx
f0104061:	75 ef                	jne    f0104052 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr)
f0104063:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104066:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104069:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010406d:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104070:	73 35                	jae    f01040a7 <stab_binsearch+0x7a>
		{
			*region_left = m;
f0104072:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104075:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0104077:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f010407a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r)
f0104081:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0104084:	7f 4e                	jg     f01040d4 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0104086:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104089:	01 f0                	add    %esi,%eax
f010408b:	89 c3                	mov    %eax,%ebx
f010408d:	c1 eb 1f             	shr    $0x1f,%ebx
f0104090:	01 c3                	add    %eax,%ebx
f0104092:	d1 fb                	sar    %ebx
f0104094:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104097:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010409a:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f010409e:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f01040a0:	eb b3                	jmp    f0104055 <stab_binsearch+0x28>
			l = true_m + 1;
f01040a2:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f01040a5:	eb da                	jmp    f0104081 <stab_binsearch+0x54>
		}
		else if (stabs[m].n_value > addr)
f01040a7:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01040aa:	76 14                	jbe    f01040c0 <stab_binsearch+0x93>
		{
			*region_right = m - 1;
f01040ac:	83 e8 01             	sub    $0x1,%eax
f01040af:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01040b2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01040b5:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f01040b7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01040be:	eb c1                	jmp    f0104081 <stab_binsearch+0x54>
		}
		else
		{
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01040c0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01040c3:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01040c5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01040c9:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f01040cb:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01040d2:	eb ad                	jmp    f0104081 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f01040d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01040d8:	74 16                	je     f01040f0 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else
	{
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01040da:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01040dd:	8b 00                	mov    (%eax),%eax
			 l > *region_left && stabs[l].n_type != type;
f01040df:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01040e2:	8b 0e                	mov    (%esi),%ecx
f01040e4:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01040e7:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01040ea:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f01040ee:	eb 12                	jmp    f0104102 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f01040f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01040f3:	8b 00                	mov    (%eax),%eax
f01040f5:	83 e8 01             	sub    $0x1,%eax
f01040f8:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01040fb:	89 07                	mov    %eax,(%edi)
f01040fd:	eb 16                	jmp    f0104115 <stab_binsearch+0xe8>
			 l--)
f01040ff:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0104102:	39 c1                	cmp    %eax,%ecx
f0104104:	7d 0a                	jge    f0104110 <stab_binsearch+0xe3>
			 l > *region_left && stabs[l].n_type != type;
f0104106:	0f b6 1a             	movzbl (%edx),%ebx
f0104109:	83 ea 0c             	sub    $0xc,%edx
f010410c:	39 fb                	cmp    %edi,%ebx
f010410e:	75 ef                	jne    f01040ff <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0104110:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104113:	89 07                	mov    %eax,(%edi)
	}
}
f0104115:	83 c4 14             	add    $0x14,%esp
f0104118:	5b                   	pop    %ebx
f0104119:	5e                   	pop    %esi
f010411a:	5f                   	pop    %edi
f010411b:	5d                   	pop    %ebp
f010411c:	c3                   	ret    

f010411d <debuginfo_eip>:
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010411d:	55                   	push   %ebp
f010411e:	89 e5                	mov    %esp,%ebp
f0104120:	57                   	push   %edi
f0104121:	56                   	push   %esi
f0104122:	53                   	push   %ebx
f0104123:	83 ec 4c             	sub    $0x4c,%esp
f0104126:	e8 86 c1 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f010412b:	81 c3 b1 fa 12 00    	add    $0x12fab1,%ebx
f0104131:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104134:	8d 83 3e 32 ed ff    	lea    -0x12cdc2(%ebx),%eax
f010413a:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f010413c:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0104143:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0104146:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f010414d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104150:	89 46 10             	mov    %eax,0x10(%esi)
	info->eip_fn_narg = 0;
f0104153:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM)
f010415a:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f010415f:	0f 86 35 01 00 00    	jbe    f010429a <debuginfo_eip+0x17d>
	{
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104165:	c7 c0 2e 46 11 f0    	mov    $0xf011462e,%eax
f010416b:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f010416e:	c7 c0 29 10 11 f0    	mov    $0xf0111029,%eax
f0104174:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0104177:	c7 c7 28 10 11 f0    	mov    $0xf0111028,%edi
		stabs = __STAB_BEGIN__;
f010417d:	c7 c0 c0 72 10 f0    	mov    $0xf01072c0,%eax
f0104183:	89 45 b8             	mov    %eax,-0x48(%ebp)
			user_mem_check(curenv, (void *)stabstr, (uintptr_t)stabstr_end - (uintptr_t)stabstr, PTE_U) < 0)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104186:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104189:	39 4d b4             	cmp    %ecx,-0x4c(%ebp)
f010418c:	0f 83 9f 02 00 00    	jae    f0104431 <debuginfo_eip+0x314>
f0104192:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104196:	0f 85 9c 02 00 00    	jne    f0104438 <debuginfo_eip+0x31b>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010419c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01041a3:	89 f8                	mov    %edi,%eax
f01041a5:	8b 7d b8             	mov    -0x48(%ebp),%edi
f01041a8:	29 f8                	sub    %edi,%eax
f01041aa:	c1 f8 02             	sar    $0x2,%eax
f01041ad:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01041b3:	83 e8 01             	sub    $0x1,%eax
f01041b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01041b9:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01041bc:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01041bf:	83 ec 08             	sub    $0x8,%esp
f01041c2:	ff 75 08             	pushl  0x8(%ebp)
f01041c5:	6a 64                	push   $0x64
f01041c7:	89 f8                	mov    %edi,%eax
f01041c9:	e8 5f fe ff ff       	call   f010402d <stab_binsearch>
	if (lfile == 0)
f01041ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01041d1:	83 c4 10             	add    $0x10,%esp
f01041d4:	85 c0                	test   %eax,%eax
f01041d6:	0f 84 63 02 00 00    	je     f010443f <debuginfo_eip+0x322>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01041dc:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01041df:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01041e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01041e5:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01041e8:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01041eb:	83 ec 08             	sub    $0x8,%esp
f01041ee:	ff 75 08             	pushl  0x8(%ebp)
f01041f1:	6a 24                	push   $0x24
f01041f3:	89 f8                	mov    %edi,%eax
f01041f5:	e8 33 fe ff ff       	call   f010402d <stab_binsearch>

	if (lfun <= rfun)
f01041fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01041fd:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104200:	83 c4 10             	add    $0x10,%esp
f0104203:	39 d0                	cmp    %edx,%eax
f0104205:	0f 8f 45 01 00 00    	jg     f0104350 <debuginfo_eip+0x233>
	{
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010420b:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f010420e:	8d 3c 8f             	lea    (%edi,%ecx,4),%edi
f0104211:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0104214:	8b 3f                	mov    (%edi),%edi
f0104216:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104219:	2b 4d b4             	sub    -0x4c(%ebp),%ecx
f010421c:	39 cf                	cmp    %ecx,%edi
f010421e:	73 06                	jae    f0104226 <debuginfo_eip+0x109>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104220:	03 7d b4             	add    -0x4c(%ebp),%edi
f0104223:	89 7e 08             	mov    %edi,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104226:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104229:	8b 4f 08             	mov    0x8(%edi),%ecx
f010422c:	89 4e 10             	mov    %ecx,0x10(%esi)
		addr -= info->eip_fn_addr;
f010422f:	29 4d 08             	sub    %ecx,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0104232:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104235:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104238:	83 ec 08             	sub    $0x8,%esp
f010423b:	6a 3a                	push   $0x3a
f010423d:	ff 76 08             	pushl  0x8(%esi)
f0104240:	e8 7b 0a 00 00       	call   f0104cc0 <strfind>
f0104245:	2b 46 08             	sub    0x8(%esi),%eax
f0104248:	89 46 0c             	mov    %eax,0xc(%esi)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr); // 根据%eip的值作为地址查找
f010424b:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010424e:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104251:	83 c4 08             	add    $0x8,%esp
f0104254:	ff 75 08             	pushl  0x8(%ebp)
f0104257:	6a 44                	push   $0x44
f0104259:	8b 7d b8             	mov    -0x48(%ebp),%edi
f010425c:	89 f8                	mov    %edi,%eax
f010425e:	e8 ca fd ff ff       	call   f010402d <stab_binsearch>
	if (lline <= rline)									  // 二分查找，left<=right即终止
f0104263:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104266:	83 c4 10             	add    $0x10,%esp
f0104269:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f010426c:	0f 8f f5 00 00 00    	jg     f0104367 <debuginfo_eip+0x24a>
	{
		info->eip_line = stabs[lline].n_desc;
f0104272:	89 d0                	mov    %edx,%eax
f0104274:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104277:	c1 e2 02             	shl    $0x2,%edx
f010427a:	0f b7 4c 17 06       	movzwl 0x6(%edi,%edx,1),%ecx
f010427f:	89 4e 04             	mov    %ecx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile && stabs[lline].n_type != N_SOL && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104282:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104285:	8d 54 17 04          	lea    0x4(%edi,%edx,1),%edx
f0104289:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f010428d:	bf 01 00 00 00       	mov    $0x1,%edi
f0104292:	89 75 0c             	mov    %esi,0xc(%ebp)
f0104295:	e9 e9 00 00 00       	jmp    f0104383 <debuginfo_eip+0x266>
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0)
f010429a:	e8 fc 10 00 00       	call   f010539b <cpunum>
f010429f:	6a 04                	push   $0x4
f01042a1:	6a 10                	push   $0x10
f01042a3:	68 00 00 20 00       	push   $0x200000
f01042a8:	6b c0 74             	imul   $0x74,%eax,%eax
f01042ab:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f01042b1:	ff 70 08             	pushl  0x8(%eax)
f01042b4:	e8 e9 e5 ff ff       	call   f01028a2 <user_mem_check>
f01042b9:	83 c4 10             	add    $0x10,%esp
f01042bc:	85 c0                	test   %eax,%eax
f01042be:	0f 88 5f 01 00 00    	js     f0104423 <debuginfo_eip+0x306>
		stabs = usd->stabs;
f01042c4:	a1 00 00 20 00       	mov    0x200000,%eax
		stab_end = usd->stab_end;
f01042c9:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f01042cf:	8b 15 08 00 20 00    	mov    0x200008,%edx
f01042d5:	89 55 b4             	mov    %edx,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f01042d8:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f01042de:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		if (user_mem_check(curenv, (void *)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, PTE_U) < 0 ||
f01042e1:	89 f9                	mov    %edi,%ecx
f01042e3:	89 45 b8             	mov    %eax,-0x48(%ebp)
f01042e6:	29 c1                	sub    %eax,%ecx
f01042e8:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f01042eb:	e8 ab 10 00 00       	call   f010539b <cpunum>
f01042f0:	6a 04                	push   $0x4
f01042f2:	ff 75 c4             	pushl  -0x3c(%ebp)
f01042f5:	ff 75 b8             	pushl  -0x48(%ebp)
f01042f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01042fb:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0104301:	ff 70 08             	pushl  0x8(%eax)
f0104304:	e8 99 e5 ff ff       	call   f01028a2 <user_mem_check>
f0104309:	83 c4 10             	add    $0x10,%esp
f010430c:	85 c0                	test   %eax,%eax
f010430e:	0f 88 16 01 00 00    	js     f010442a <debuginfo_eip+0x30d>
			user_mem_check(curenv, (void *)stabstr, (uintptr_t)stabstr_end - (uintptr_t)stabstr, PTE_U) < 0)
f0104314:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104317:	2b 45 b4             	sub    -0x4c(%ebp),%eax
f010431a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010431d:	e8 79 10 00 00       	call   f010539b <cpunum>
f0104322:	6a 04                	push   $0x4
f0104324:	ff 75 c4             	pushl  -0x3c(%ebp)
f0104327:	ff 75 b4             	pushl  -0x4c(%ebp)
f010432a:	6b c0 74             	imul   $0x74,%eax,%eax
f010432d:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0104333:	ff 70 08             	pushl  0x8(%eax)
f0104336:	e8 67 e5 ff ff       	call   f01028a2 <user_mem_check>
		if (user_mem_check(curenv, (void *)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, PTE_U) < 0 ||
f010433b:	83 c4 10             	add    $0x10,%esp
f010433e:	85 c0                	test   %eax,%eax
f0104340:	0f 89 40 fe ff ff    	jns    f0104186 <debuginfo_eip+0x69>
			return -1;
f0104346:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010434b:	e9 fb 00 00 00       	jmp    f010444b <debuginfo_eip+0x32e>
		info->eip_fn_addr = addr;
f0104350:	8b 45 08             	mov    0x8(%ebp),%eax
f0104353:	89 46 10             	mov    %eax,0x10(%esi)
		lline = lfile;
f0104356:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104359:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010435c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010435f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104362:	e9 d1 fe ff ff       	jmp    f0104238 <debuginfo_eip+0x11b>
		info->eip_line = 0;
f0104367:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
		return -1;
f010436e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104373:	e9 d3 00 00 00       	jmp    f010444b <debuginfo_eip+0x32e>
f0104378:	83 e8 01             	sub    $0x1,%eax
f010437b:	83 ea 0c             	sub    $0xc,%edx
f010437e:	89 f9                	mov    %edi,%ecx
f0104380:	88 4d c4             	mov    %cl,-0x3c(%ebp)
f0104383:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile && stabs[lline].n_type != N_SOL && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104386:	39 c3                	cmp    %eax,%ebx
f0104388:	7f 24                	jg     f01043ae <debuginfo_eip+0x291>
f010438a:	0f b6 0a             	movzbl (%edx),%ecx
f010438d:	80 f9 84             	cmp    $0x84,%cl
f0104390:	74 46                	je     f01043d8 <debuginfo_eip+0x2bb>
f0104392:	80 f9 64             	cmp    $0x64,%cl
f0104395:	75 e1                	jne    f0104378 <debuginfo_eip+0x25b>
f0104397:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f010439b:	74 db                	je     f0104378 <debuginfo_eip+0x25b>
f010439d:	8b 75 0c             	mov    0xc(%ebp),%esi
f01043a0:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01043a4:	74 3b                	je     f01043e1 <debuginfo_eip+0x2c4>
f01043a6:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f01043a9:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f01043ac:	eb 33                	jmp    f01043e1 <debuginfo_eip+0x2c4>
f01043ae:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01043b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01043b4:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
			 lline < rfun && stabs[lline].n_type == N_PSYM;
			 lline++)
			info->eip_fn_narg++;

	return 0;
f01043b7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f01043bc:	39 da                	cmp    %ebx,%edx
f01043be:	0f 8d 87 00 00 00    	jge    f010444b <debuginfo_eip+0x32e>
		for (lline = lfun + 1;
f01043c4:	83 c2 01             	add    $0x1,%edx
f01043c7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01043ca:	89 d0                	mov    %edx,%eax
f01043cc:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01043cf:	8b 7d b8             	mov    -0x48(%ebp),%edi
f01043d2:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f01043d6:	eb 32                	jmp    f010440a <debuginfo_eip+0x2ed>
f01043d8:	8b 75 0c             	mov    0xc(%ebp),%esi
f01043db:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01043df:	75 1d                	jne    f01043fe <debuginfo_eip+0x2e1>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01043e1:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01043e4:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f01043e7:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01043ea:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01043ed:	8b 5d b4             	mov    -0x4c(%ebp),%ebx
f01043f0:	29 d8                	sub    %ebx,%eax
f01043f2:	39 c2                	cmp    %eax,%edx
f01043f4:	73 bb                	jae    f01043b1 <debuginfo_eip+0x294>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01043f6:	89 d8                	mov    %ebx,%eax
f01043f8:	01 d0                	add    %edx,%eax
f01043fa:	89 06                	mov    %eax,(%esi)
f01043fc:	eb b3                	jmp    f01043b1 <debuginfo_eip+0x294>
f01043fe:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f0104401:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0104404:	eb db                	jmp    f01043e1 <debuginfo_eip+0x2c4>
			info->eip_fn_narg++;
f0104406:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f010440a:	39 c3                	cmp    %eax,%ebx
f010440c:	7e 38                	jle    f0104446 <debuginfo_eip+0x329>
			 lline < rfun && stabs[lline].n_type == N_PSYM;
f010440e:	0f b6 0a             	movzbl (%edx),%ecx
f0104411:	83 c0 01             	add    $0x1,%eax
f0104414:	83 c2 0c             	add    $0xc,%edx
f0104417:	80 f9 a0             	cmp    $0xa0,%cl
f010441a:	74 ea                	je     f0104406 <debuginfo_eip+0x2e9>
	return 0;
f010441c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104421:	eb 28                	jmp    f010444b <debuginfo_eip+0x32e>
			return -1;
f0104423:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104428:	eb 21                	jmp    f010444b <debuginfo_eip+0x32e>
			return -1;
f010442a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010442f:	eb 1a                	jmp    f010444b <debuginfo_eip+0x32e>
		return -1;
f0104431:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104436:	eb 13                	jmp    f010444b <debuginfo_eip+0x32e>
f0104438:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010443d:	eb 0c                	jmp    f010444b <debuginfo_eip+0x32e>
		return -1;
f010443f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104444:	eb 05                	jmp    f010444b <debuginfo_eip+0x32e>
	return 0;
f0104446:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010444b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010444e:	5b                   	pop    %ebx
f010444f:	5e                   	pop    %esi
f0104450:	5f                   	pop    %edi
f0104451:	5d                   	pop    %ebp
f0104452:	c3                   	ret    

f0104453 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
f0104453:	55                   	push   %ebp
f0104454:	89 e5                	mov    %esp,%ebp
f0104456:	57                   	push   %edi
f0104457:	56                   	push   %esi
f0104458:	53                   	push   %ebx
f0104459:	83 ec 2c             	sub    $0x2c,%esp
f010445c:	e8 02 06 00 00       	call   f0104a63 <__x86.get_pc_thunk.cx>
f0104461:	81 c1 7b f7 12 00    	add    $0x12f77b,%ecx
f0104467:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f010446a:	89 c7                	mov    %eax,%edi
f010446c:	89 d6                	mov    %edx,%esi
f010446e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104471:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104474:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104477:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
f010447a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010447d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104482:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0104485:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0104488:	39 d3                	cmp    %edx,%ebx
f010448a:	72 09                	jb     f0104495 <printnum+0x42>
f010448c:	39 45 10             	cmp    %eax,0x10(%ebp)
f010448f:	0f 87 83 00 00 00    	ja     f0104518 <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104495:	83 ec 0c             	sub    $0xc,%esp
f0104498:	ff 75 18             	pushl  0x18(%ebp)
f010449b:	8b 45 14             	mov    0x14(%ebp),%eax
f010449e:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01044a1:	53                   	push   %ebx
f01044a2:	ff 75 10             	pushl  0x10(%ebp)
f01044a5:	83 ec 08             	sub    $0x8,%esp
f01044a8:	ff 75 dc             	pushl  -0x24(%ebp)
f01044ab:	ff 75 d8             	pushl  -0x28(%ebp)
f01044ae:	ff 75 d4             	pushl  -0x2c(%ebp)
f01044b1:	ff 75 d0             	pushl  -0x30(%ebp)
f01044b4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01044b7:	e8 84 13 00 00       	call   f0105840 <__udivdi3>
f01044bc:	83 c4 18             	add    $0x18,%esp
f01044bf:	52                   	push   %edx
f01044c0:	50                   	push   %eax
f01044c1:	89 f2                	mov    %esi,%edx
f01044c3:	89 f8                	mov    %edi,%eax
f01044c5:	e8 89 ff ff ff       	call   f0104453 <printnum>
f01044ca:	83 c4 20             	add    $0x20,%esp
f01044cd:	eb 13                	jmp    f01044e2 <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01044cf:	83 ec 08             	sub    $0x8,%esp
f01044d2:	56                   	push   %esi
f01044d3:	ff 75 18             	pushl  0x18(%ebp)
f01044d6:	ff d7                	call   *%edi
f01044d8:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f01044db:	83 eb 01             	sub    $0x1,%ebx
f01044de:	85 db                	test   %ebx,%ebx
f01044e0:	7f ed                	jg     f01044cf <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01044e2:	83 ec 08             	sub    $0x8,%esp
f01044e5:	56                   	push   %esi
f01044e6:	83 ec 04             	sub    $0x4,%esp
f01044e9:	ff 75 dc             	pushl  -0x24(%ebp)
f01044ec:	ff 75 d8             	pushl  -0x28(%ebp)
f01044ef:	ff 75 d4             	pushl  -0x2c(%ebp)
f01044f2:	ff 75 d0             	pushl  -0x30(%ebp)
f01044f5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01044f8:	89 f3                	mov    %esi,%ebx
f01044fa:	e8 71 14 00 00       	call   f0105970 <__umoddi3>
f01044ff:	83 c4 14             	add    $0x14,%esp
f0104502:	0f be 84 06 48 32 ed 	movsbl -0x12cdb8(%esi,%eax,1),%eax
f0104509:	ff 
f010450a:	50                   	push   %eax
f010450b:	ff d7                	call   *%edi
}
f010450d:	83 c4 10             	add    $0x10,%esp
f0104510:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104513:	5b                   	pop    %ebx
f0104514:	5e                   	pop    %esi
f0104515:	5f                   	pop    %edi
f0104516:	5d                   	pop    %ebp
f0104517:	c3                   	ret    
f0104518:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010451b:	eb be                	jmp    f01044db <printnum+0x88>

f010451d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010451d:	55                   	push   %ebp
f010451e:	89 e5                	mov    %esp,%ebp
f0104520:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104523:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104527:	8b 10                	mov    (%eax),%edx
f0104529:	3b 50 04             	cmp    0x4(%eax),%edx
f010452c:	73 0a                	jae    f0104538 <sprintputch+0x1b>
		*b->buf++ = ch;
f010452e:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104531:	89 08                	mov    %ecx,(%eax)
f0104533:	8b 45 08             	mov    0x8(%ebp),%eax
f0104536:	88 02                	mov    %al,(%edx)
}
f0104538:	5d                   	pop    %ebp
f0104539:	c3                   	ret    

f010453a <printfmt>:
{
f010453a:	55                   	push   %ebp
f010453b:	89 e5                	mov    %esp,%ebp
f010453d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0104540:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104543:	50                   	push   %eax
f0104544:	ff 75 10             	pushl  0x10(%ebp)
f0104547:	ff 75 0c             	pushl  0xc(%ebp)
f010454a:	ff 75 08             	pushl  0x8(%ebp)
f010454d:	e8 05 00 00 00       	call   f0104557 <vprintfmt>
}
f0104552:	83 c4 10             	add    $0x10,%esp
f0104555:	c9                   	leave  
f0104556:	c3                   	ret    

f0104557 <vprintfmt>:
{
f0104557:	55                   	push   %ebp
f0104558:	89 e5                	mov    %esp,%ebp
f010455a:	57                   	push   %edi
f010455b:	56                   	push   %esi
f010455c:	53                   	push   %ebx
f010455d:	83 ec 2c             	sub    $0x2c,%esp
f0104560:	e8 4c bd ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0104565:	81 c3 77 f6 12 00    	add    $0x12f677,%ebx
f010456b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010456e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104571:	e9 c3 03 00 00       	jmp    f0104939 <.L35+0x48>
		padc = ' ';
f0104576:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f010457a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0104581:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f0104588:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f010458f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104594:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f0104597:	8d 47 01             	lea    0x1(%edi),%eax
f010459a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010459d:	0f b6 17             	movzbl (%edi),%edx
f01045a0:	8d 42 dd             	lea    -0x23(%edx),%eax
f01045a3:	3c 55                	cmp    $0x55,%al
f01045a5:	0f 87 16 04 00 00    	ja     f01049c1 <.L22>
f01045ab:	0f b6 c0             	movzbl %al,%eax
f01045ae:	89 d9                	mov    %ebx,%ecx
f01045b0:	03 8c 83 fc 32 ed ff 	add    -0x12cd04(%ebx,%eax,4),%ecx
f01045b7:	ff e1                	jmp    *%ecx

f01045b9 <.L69>:
f01045b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f01045bc:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f01045c0:	eb d5                	jmp    f0104597 <vprintfmt+0x40>

f01045c2 <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f01045c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f01045c5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01045c9:	eb cc                	jmp    f0104597 <vprintfmt+0x40>

f01045cb <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f01045cb:	0f b6 d2             	movzbl %dl,%edx
f01045ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
f01045d1:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f01045d6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01045d9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01045dd:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f01045e0:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01045e3:	83 f9 09             	cmp    $0x9,%ecx
f01045e6:	77 55                	ja     f010463d <.L23+0xf>
			for (precision = 0;; ++fmt)
f01045e8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f01045eb:	eb e9                	jmp    f01045d6 <.L29+0xb>

f01045ed <.L26>:
			precision = va_arg(ap, int);
f01045ed:	8b 45 14             	mov    0x14(%ebp),%eax
f01045f0:	8b 00                	mov    (%eax),%eax
f01045f2:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01045f5:	8b 45 14             	mov    0x14(%ebp),%eax
f01045f8:	8d 40 04             	lea    0x4(%eax),%eax
f01045fb:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f01045fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0104601:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104605:	79 90                	jns    f0104597 <vprintfmt+0x40>
				width = precision, precision = -1;
f0104607:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010460a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010460d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0104614:	eb 81                	jmp    f0104597 <vprintfmt+0x40>

f0104616 <.L27>:
f0104616:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104619:	85 c0                	test   %eax,%eax
f010461b:	ba 00 00 00 00       	mov    $0x0,%edx
f0104620:	0f 49 d0             	cmovns %eax,%edx
f0104623:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f0104626:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104629:	e9 69 ff ff ff       	jmp    f0104597 <vprintfmt+0x40>

f010462e <.L23>:
f010462e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0104631:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104638:	e9 5a ff ff ff       	jmp    f0104597 <vprintfmt+0x40>
f010463d:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104640:	eb bf                	jmp    f0104601 <.L26+0x14>

f0104642 <.L33>:
			lflag++;
f0104642:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f0104646:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0104649:	e9 49 ff ff ff       	jmp    f0104597 <vprintfmt+0x40>

f010464e <.L30>:
			putch(va_arg(ap, int), putdat);
f010464e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104651:	8d 78 04             	lea    0x4(%eax),%edi
f0104654:	83 ec 08             	sub    $0x8,%esp
f0104657:	56                   	push   %esi
f0104658:	ff 30                	pushl  (%eax)
f010465a:	ff 55 08             	call   *0x8(%ebp)
			break;
f010465d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0104660:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0104663:	e9 ce 02 00 00       	jmp    f0104936 <.L35+0x45>

f0104668 <.L32>:
			err = va_arg(ap, int);
f0104668:	8b 45 14             	mov    0x14(%ebp),%eax
f010466b:	8d 78 04             	lea    0x4(%eax),%edi
f010466e:	8b 00                	mov    (%eax),%eax
f0104670:	99                   	cltd   
f0104671:	31 d0                	xor    %edx,%eax
f0104673:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104675:	83 f8 08             	cmp    $0x8,%eax
f0104678:	7f 27                	jg     f01046a1 <.L32+0x39>
f010467a:	8b 94 83 44 15 00 00 	mov    0x1544(%ebx,%eax,4),%edx
f0104681:	85 d2                	test   %edx,%edx
f0104683:	74 1c                	je     f01046a1 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f0104685:	52                   	push   %edx
f0104686:	8d 83 19 2b ed ff    	lea    -0x12d4e7(%ebx),%eax
f010468c:	50                   	push   %eax
f010468d:	56                   	push   %esi
f010468e:	ff 75 08             	pushl  0x8(%ebp)
f0104691:	e8 a4 fe ff ff       	call   f010453a <printfmt>
f0104696:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104699:	89 7d 14             	mov    %edi,0x14(%ebp)
f010469c:	e9 95 02 00 00       	jmp    f0104936 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
f01046a1:	50                   	push   %eax
f01046a2:	8d 83 60 32 ed ff    	lea    -0x12cda0(%ebx),%eax
f01046a8:	50                   	push   %eax
f01046a9:	56                   	push   %esi
f01046aa:	ff 75 08             	pushl  0x8(%ebp)
f01046ad:	e8 88 fe ff ff       	call   f010453a <printfmt>
f01046b2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01046b5:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01046b8:	e9 79 02 00 00       	jmp    f0104936 <.L35+0x45>

f01046bd <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f01046bd:	8b 45 14             	mov    0x14(%ebp),%eax
f01046c0:	83 c0 04             	add    $0x4,%eax
f01046c3:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01046c6:	8b 45 14             	mov    0x14(%ebp),%eax
f01046c9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f01046cb:	85 ff                	test   %edi,%edi
f01046cd:	8d 83 59 32 ed ff    	lea    -0x12cda7(%ebx),%eax
f01046d3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f01046d6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01046da:	0f 8e b5 00 00 00    	jle    f0104795 <.L36+0xd8>
f01046e0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01046e4:	75 08                	jne    f01046ee <.L36+0x31>
f01046e6:	89 75 0c             	mov    %esi,0xc(%ebp)
f01046e9:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01046ec:	eb 6d                	jmp    f010475b <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f01046ee:	83 ec 08             	sub    $0x8,%esp
f01046f1:	ff 75 cc             	pushl  -0x34(%ebp)
f01046f4:	57                   	push   %edi
f01046f5:	e8 82 04 00 00       	call   f0104b7c <strnlen>
f01046fa:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01046fd:	29 c2                	sub    %eax,%edx
f01046ff:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0104702:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104705:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104709:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010470c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010470f:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0104711:	eb 10                	jmp    f0104723 <.L36+0x66>
					putch(padc, putdat);
f0104713:	83 ec 08             	sub    $0x8,%esp
f0104716:	56                   	push   %esi
f0104717:	ff 75 e0             	pushl  -0x20(%ebp)
f010471a:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f010471d:	83 ef 01             	sub    $0x1,%edi
f0104720:	83 c4 10             	add    $0x10,%esp
f0104723:	85 ff                	test   %edi,%edi
f0104725:	7f ec                	jg     f0104713 <.L36+0x56>
f0104727:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010472a:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010472d:	85 d2                	test   %edx,%edx
f010472f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104734:	0f 49 c2             	cmovns %edx,%eax
f0104737:	29 c2                	sub    %eax,%edx
f0104739:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010473c:	89 75 0c             	mov    %esi,0xc(%ebp)
f010473f:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0104742:	eb 17                	jmp    f010475b <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f0104744:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104748:	75 30                	jne    f010477a <.L36+0xbd>
					putch(ch, putdat);
f010474a:	83 ec 08             	sub    $0x8,%esp
f010474d:	ff 75 0c             	pushl  0xc(%ebp)
f0104750:	50                   	push   %eax
f0104751:	ff 55 08             	call   *0x8(%ebp)
f0104754:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104757:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f010475b:	83 c7 01             	add    $0x1,%edi
f010475e:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0104762:	0f be c2             	movsbl %dl,%eax
f0104765:	85 c0                	test   %eax,%eax
f0104767:	74 52                	je     f01047bb <.L36+0xfe>
f0104769:	85 f6                	test   %esi,%esi
f010476b:	78 d7                	js     f0104744 <.L36+0x87>
f010476d:	83 ee 01             	sub    $0x1,%esi
f0104770:	79 d2                	jns    f0104744 <.L36+0x87>
f0104772:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104775:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104778:	eb 32                	jmp    f01047ac <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f010477a:	0f be d2             	movsbl %dl,%edx
f010477d:	83 ea 20             	sub    $0x20,%edx
f0104780:	83 fa 5e             	cmp    $0x5e,%edx
f0104783:	76 c5                	jbe    f010474a <.L36+0x8d>
					putch('?', putdat);
f0104785:	83 ec 08             	sub    $0x8,%esp
f0104788:	ff 75 0c             	pushl  0xc(%ebp)
f010478b:	6a 3f                	push   $0x3f
f010478d:	ff 55 08             	call   *0x8(%ebp)
f0104790:	83 c4 10             	add    $0x10,%esp
f0104793:	eb c2                	jmp    f0104757 <.L36+0x9a>
f0104795:	89 75 0c             	mov    %esi,0xc(%ebp)
f0104798:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010479b:	eb be                	jmp    f010475b <.L36+0x9e>
				putch(' ', putdat);
f010479d:	83 ec 08             	sub    $0x8,%esp
f01047a0:	56                   	push   %esi
f01047a1:	6a 20                	push   $0x20
f01047a3:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f01047a6:	83 ef 01             	sub    $0x1,%edi
f01047a9:	83 c4 10             	add    $0x10,%esp
f01047ac:	85 ff                	test   %edi,%edi
f01047ae:	7f ed                	jg     f010479d <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f01047b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01047b3:	89 45 14             	mov    %eax,0x14(%ebp)
f01047b6:	e9 7b 01 00 00       	jmp    f0104936 <.L35+0x45>
f01047bb:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01047be:	8b 75 0c             	mov    0xc(%ebp),%esi
f01047c1:	eb e9                	jmp    f01047ac <.L36+0xef>

f01047c3 <.L31>:
f01047c3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01047c6:	83 f9 01             	cmp    $0x1,%ecx
f01047c9:	7e 40                	jle    f010480b <.L31+0x48>
		return va_arg(*ap, long long);
f01047cb:	8b 45 14             	mov    0x14(%ebp),%eax
f01047ce:	8b 50 04             	mov    0x4(%eax),%edx
f01047d1:	8b 00                	mov    (%eax),%eax
f01047d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01047d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01047d9:	8b 45 14             	mov    0x14(%ebp),%eax
f01047dc:	8d 40 08             	lea    0x8(%eax),%eax
f01047df:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
f01047e2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01047e6:	79 55                	jns    f010483d <.L31+0x7a>
				putch('-', putdat);
f01047e8:	83 ec 08             	sub    $0x8,%esp
f01047eb:	56                   	push   %esi
f01047ec:	6a 2d                	push   $0x2d
f01047ee:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
f01047f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01047f4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01047f7:	f7 da                	neg    %edx
f01047f9:	83 d1 00             	adc    $0x0,%ecx
f01047fc:	f7 d9                	neg    %ecx
f01047fe:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
f0104801:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104806:	e9 10 01 00 00       	jmp    f010491b <.L35+0x2a>
	else if (lflag)
f010480b:	85 c9                	test   %ecx,%ecx
f010480d:	75 17                	jne    f0104826 <.L31+0x63>
		return va_arg(*ap, int);
f010480f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104812:	8b 00                	mov    (%eax),%eax
f0104814:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104817:	99                   	cltd   
f0104818:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010481b:	8b 45 14             	mov    0x14(%ebp),%eax
f010481e:	8d 40 04             	lea    0x4(%eax),%eax
f0104821:	89 45 14             	mov    %eax,0x14(%ebp)
f0104824:	eb bc                	jmp    f01047e2 <.L31+0x1f>
		return va_arg(*ap, long);
f0104826:	8b 45 14             	mov    0x14(%ebp),%eax
f0104829:	8b 00                	mov    (%eax),%eax
f010482b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010482e:	99                   	cltd   
f010482f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104832:	8b 45 14             	mov    0x14(%ebp),%eax
f0104835:	8d 40 04             	lea    0x4(%eax),%eax
f0104838:	89 45 14             	mov    %eax,0x14(%ebp)
f010483b:	eb a5                	jmp    f01047e2 <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
f010483d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104840:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
f0104843:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104848:	e9 ce 00 00 00       	jmp    f010491b <.L35+0x2a>

f010484d <.L37>:
f010484d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0104850:	83 f9 01             	cmp    $0x1,%ecx
f0104853:	7e 18                	jle    f010486d <.L37+0x20>
		return va_arg(*ap, unsigned long long);
f0104855:	8b 45 14             	mov    0x14(%ebp),%eax
f0104858:	8b 10                	mov    (%eax),%edx
f010485a:	8b 48 04             	mov    0x4(%eax),%ecx
f010485d:	8d 40 08             	lea    0x8(%eax),%eax
f0104860:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104863:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104868:	e9 ae 00 00 00       	jmp    f010491b <.L35+0x2a>
	else if (lflag)
f010486d:	85 c9                	test   %ecx,%ecx
f010486f:	75 1a                	jne    f010488b <.L37+0x3e>
		return va_arg(*ap, unsigned int);
f0104871:	8b 45 14             	mov    0x14(%ebp),%eax
f0104874:	8b 10                	mov    (%eax),%edx
f0104876:	b9 00 00 00 00       	mov    $0x0,%ecx
f010487b:	8d 40 04             	lea    0x4(%eax),%eax
f010487e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104881:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104886:	e9 90 00 00 00       	jmp    f010491b <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f010488b:	8b 45 14             	mov    0x14(%ebp),%eax
f010488e:	8b 10                	mov    (%eax),%edx
f0104890:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104895:	8d 40 04             	lea    0x4(%eax),%eax
f0104898:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010489b:	b8 0a 00 00 00       	mov    $0xa,%eax
f01048a0:	eb 79                	jmp    f010491b <.L35+0x2a>

f01048a2 <.L34>:
f01048a2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01048a5:	83 f9 01             	cmp    $0x1,%ecx
f01048a8:	7e 15                	jle    f01048bf <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
f01048aa:	8b 45 14             	mov    0x14(%ebp),%eax
f01048ad:	8b 10                	mov    (%eax),%edx
f01048af:	8b 48 04             	mov    0x4(%eax),%ecx
f01048b2:	8d 40 08             	lea    0x8(%eax),%eax
f01048b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01048b8:	b8 08 00 00 00       	mov    $0x8,%eax
f01048bd:	eb 5c                	jmp    f010491b <.L35+0x2a>
	else if (lflag)
f01048bf:	85 c9                	test   %ecx,%ecx
f01048c1:	75 17                	jne    f01048da <.L34+0x38>
		return va_arg(*ap, unsigned int);
f01048c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01048c6:	8b 10                	mov    (%eax),%edx
f01048c8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01048cd:	8d 40 04             	lea    0x4(%eax),%eax
f01048d0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01048d3:	b8 08 00 00 00       	mov    $0x8,%eax
f01048d8:	eb 41                	jmp    f010491b <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f01048da:	8b 45 14             	mov    0x14(%ebp),%eax
f01048dd:	8b 10                	mov    (%eax),%edx
f01048df:	b9 00 00 00 00       	mov    $0x0,%ecx
f01048e4:	8d 40 04             	lea    0x4(%eax),%eax
f01048e7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01048ea:	b8 08 00 00 00       	mov    $0x8,%eax
f01048ef:	eb 2a                	jmp    f010491b <.L35+0x2a>

f01048f1 <.L35>:
			putch('0', putdat);
f01048f1:	83 ec 08             	sub    $0x8,%esp
f01048f4:	56                   	push   %esi
f01048f5:	6a 30                	push   $0x30
f01048f7:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01048fa:	83 c4 08             	add    $0x8,%esp
f01048fd:	56                   	push   %esi
f01048fe:	6a 78                	push   $0x78
f0104900:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
f0104903:	8b 45 14             	mov    0x14(%ebp),%eax
f0104906:	8b 10                	mov    (%eax),%edx
f0104908:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010490d:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
f0104910:	8d 40 04             	lea    0x4(%eax),%eax
f0104913:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104916:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
f010491b:	83 ec 0c             	sub    $0xc,%esp
f010491e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0104922:	57                   	push   %edi
f0104923:	ff 75 e0             	pushl  -0x20(%ebp)
f0104926:	50                   	push   %eax
f0104927:	51                   	push   %ecx
f0104928:	52                   	push   %edx
f0104929:	89 f2                	mov    %esi,%edx
f010492b:	8b 45 08             	mov    0x8(%ebp),%eax
f010492e:	e8 20 fb ff ff       	call   f0104453 <printnum>
			break;
f0104933:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0104936:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
f0104939:	83 c7 01             	add    $0x1,%edi
f010493c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104940:	83 f8 25             	cmp    $0x25,%eax
f0104943:	0f 84 2d fc ff ff    	je     f0104576 <vprintfmt+0x1f>
			if (ch == '\0')
f0104949:	85 c0                	test   %eax,%eax
f010494b:	0f 84 91 00 00 00    	je     f01049e2 <.L22+0x21>
			putch(ch, putdat);
f0104951:	83 ec 08             	sub    $0x8,%esp
f0104954:	56                   	push   %esi
f0104955:	50                   	push   %eax
f0104956:	ff 55 08             	call   *0x8(%ebp)
f0104959:	83 c4 10             	add    $0x10,%esp
f010495c:	eb db                	jmp    f0104939 <.L35+0x48>

f010495e <.L38>:
f010495e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0104961:	83 f9 01             	cmp    $0x1,%ecx
f0104964:	7e 15                	jle    f010497b <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
f0104966:	8b 45 14             	mov    0x14(%ebp),%eax
f0104969:	8b 10                	mov    (%eax),%edx
f010496b:	8b 48 04             	mov    0x4(%eax),%ecx
f010496e:	8d 40 08             	lea    0x8(%eax),%eax
f0104971:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104974:	b8 10 00 00 00       	mov    $0x10,%eax
f0104979:	eb a0                	jmp    f010491b <.L35+0x2a>
	else if (lflag)
f010497b:	85 c9                	test   %ecx,%ecx
f010497d:	75 17                	jne    f0104996 <.L38+0x38>
		return va_arg(*ap, unsigned int);
f010497f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104982:	8b 10                	mov    (%eax),%edx
f0104984:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104989:	8d 40 04             	lea    0x4(%eax),%eax
f010498c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010498f:	b8 10 00 00 00       	mov    $0x10,%eax
f0104994:	eb 85                	jmp    f010491b <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0104996:	8b 45 14             	mov    0x14(%ebp),%eax
f0104999:	8b 10                	mov    (%eax),%edx
f010499b:	b9 00 00 00 00       	mov    $0x0,%ecx
f01049a0:	8d 40 04             	lea    0x4(%eax),%eax
f01049a3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01049a6:	b8 10 00 00 00       	mov    $0x10,%eax
f01049ab:	e9 6b ff ff ff       	jmp    f010491b <.L35+0x2a>

f01049b0 <.L25>:
			putch(ch, putdat);
f01049b0:	83 ec 08             	sub    $0x8,%esp
f01049b3:	56                   	push   %esi
f01049b4:	6a 25                	push   $0x25
f01049b6:	ff 55 08             	call   *0x8(%ebp)
			break;
f01049b9:	83 c4 10             	add    $0x10,%esp
f01049bc:	e9 75 ff ff ff       	jmp    f0104936 <.L35+0x45>

f01049c1 <.L22>:
			putch('%', putdat);
f01049c1:	83 ec 08             	sub    $0x8,%esp
f01049c4:	56                   	push   %esi
f01049c5:	6a 25                	push   $0x25
f01049c7:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01049ca:	83 c4 10             	add    $0x10,%esp
f01049cd:	89 f8                	mov    %edi,%eax
f01049cf:	eb 03                	jmp    f01049d4 <.L22+0x13>
f01049d1:	83 e8 01             	sub    $0x1,%eax
f01049d4:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01049d8:	75 f7                	jne    f01049d1 <.L22+0x10>
f01049da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01049dd:	e9 54 ff ff ff       	jmp    f0104936 <.L35+0x45>
}
f01049e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01049e5:	5b                   	pop    %ebx
f01049e6:	5e                   	pop    %esi
f01049e7:	5f                   	pop    %edi
f01049e8:	5d                   	pop    %ebp
f01049e9:	c3                   	ret    

f01049ea <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01049ea:	55                   	push   %ebp
f01049eb:	89 e5                	mov    %esp,%ebp
f01049ed:	53                   	push   %ebx
f01049ee:	83 ec 14             	sub    $0x14,%esp
f01049f1:	e8 bb b8 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f01049f6:	81 c3 e6 f1 12 00    	add    $0x12f1e6,%ebx
f01049fc:	8b 45 08             	mov    0x8(%ebp),%eax
f01049ff:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
f0104a02:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104a05:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104a09:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104a0c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104a13:	85 c0                	test   %eax,%eax
f0104a15:	74 2b                	je     f0104a42 <vsnprintf+0x58>
f0104a17:	85 d2                	test   %edx,%edx
f0104a19:	7e 27                	jle    f0104a42 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
f0104a1b:	ff 75 14             	pushl  0x14(%ebp)
f0104a1e:	ff 75 10             	pushl  0x10(%ebp)
f0104a21:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104a24:	50                   	push   %eax
f0104a25:	8d 83 41 09 ed ff    	lea    -0x12f6bf(%ebx),%eax
f0104a2b:	50                   	push   %eax
f0104a2c:	e8 26 fb ff ff       	call   f0104557 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104a31:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104a34:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104a3a:	83 c4 10             	add    $0x10,%esp
}
f0104a3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104a40:	c9                   	leave  
f0104a41:	c3                   	ret    
		return -E_INVAL;
f0104a42:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104a47:	eb f4                	jmp    f0104a3d <vsnprintf+0x53>

f0104a49 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
f0104a49:	55                   	push   %ebp
f0104a4a:	89 e5                	mov    %esp,%ebp
f0104a4c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104a4f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104a52:	50                   	push   %eax
f0104a53:	ff 75 10             	pushl  0x10(%ebp)
f0104a56:	ff 75 0c             	pushl  0xc(%ebp)
f0104a59:	ff 75 08             	pushl  0x8(%ebp)
f0104a5c:	e8 89 ff ff ff       	call   f01049ea <vsnprintf>
	va_end(ap);

	return rc;
}
f0104a61:	c9                   	leave  
f0104a62:	c3                   	ret    

f0104a63 <__x86.get_pc_thunk.cx>:
f0104a63:	8b 0c 24             	mov    (%esp),%ecx
f0104a66:	c3                   	ret    

f0104a67 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104a67:	55                   	push   %ebp
f0104a68:	89 e5                	mov    %esp,%ebp
f0104a6a:	57                   	push   %edi
f0104a6b:	56                   	push   %esi
f0104a6c:	53                   	push   %ebx
f0104a6d:	83 ec 1c             	sub    $0x1c,%esp
f0104a70:	e8 3c b8 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0104a75:	81 c3 67 f1 12 00    	add    $0x12f167,%ebx
f0104a7b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104a7e:	85 c0                	test   %eax,%eax
f0104a80:	74 13                	je     f0104a95 <readline+0x2e>
		cprintf("%s", prompt);
f0104a82:	83 ec 08             	sub    $0x8,%esp
f0104a85:	50                   	push   %eax
f0104a86:	8d 83 19 2b ed ff    	lea    -0x12d4e7(%ebx),%eax
f0104a8c:	50                   	push   %eax
f0104a8d:	e8 6d e9 ff ff       	call   f01033ff <cprintf>
f0104a92:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104a95:	83 ec 0c             	sub    $0xc,%esp
f0104a98:	6a 00                	push   $0x0
f0104a9a:	e8 c9 bd ff ff       	call   f0100868 <iscons>
f0104a9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104aa2:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0104aa5:	bf 00 00 00 00       	mov    $0x0,%edi
f0104aaa:	eb 46                	jmp    f0104af2 <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0104aac:	83 ec 08             	sub    $0x8,%esp
f0104aaf:	50                   	push   %eax
f0104ab0:	8d 83 54 34 ed ff    	lea    -0x12cbac(%ebx),%eax
f0104ab6:	50                   	push   %eax
f0104ab7:	e8 43 e9 ff ff       	call   f01033ff <cprintf>
			return NULL;
f0104abc:	83 c4 10             	add    $0x10,%esp
f0104abf:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0104ac4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104ac7:	5b                   	pop    %ebx
f0104ac8:	5e                   	pop    %esi
f0104ac9:	5f                   	pop    %edi
f0104aca:	5d                   	pop    %ebp
f0104acb:	c3                   	ret    
			if (echoing)
f0104acc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104ad0:	75 05                	jne    f0104ad7 <readline+0x70>
			i--;
f0104ad2:	83 ef 01             	sub    $0x1,%edi
f0104ad5:	eb 1b                	jmp    f0104af2 <readline+0x8b>
				cputchar('\b');
f0104ad7:	83 ec 0c             	sub    $0xc,%esp
f0104ada:	6a 08                	push   $0x8
f0104adc:	e8 66 bd ff ff       	call   f0100847 <cputchar>
f0104ae1:	83 c4 10             	add    $0x10,%esp
f0104ae4:	eb ec                	jmp    f0104ad2 <readline+0x6b>
			buf[i++] = c;
f0104ae6:	89 f0                	mov    %esi,%eax
f0104ae8:	88 84 3b 24 2f 00 00 	mov    %al,0x2f24(%ebx,%edi,1)
f0104aef:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0104af2:	e8 60 bd ff ff       	call   f0100857 <getchar>
f0104af7:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0104af9:	85 c0                	test   %eax,%eax
f0104afb:	78 af                	js     f0104aac <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104afd:	83 f8 08             	cmp    $0x8,%eax
f0104b00:	0f 94 c2             	sete   %dl
f0104b03:	83 f8 7f             	cmp    $0x7f,%eax
f0104b06:	0f 94 c0             	sete   %al
f0104b09:	08 c2                	or     %al,%dl
f0104b0b:	74 04                	je     f0104b11 <readline+0xaa>
f0104b0d:	85 ff                	test   %edi,%edi
f0104b0f:	7f bb                	jg     f0104acc <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104b11:	83 fe 1f             	cmp    $0x1f,%esi
f0104b14:	7e 1c                	jle    f0104b32 <readline+0xcb>
f0104b16:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0104b1c:	7f 14                	jg     f0104b32 <readline+0xcb>
			if (echoing)
f0104b1e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104b22:	74 c2                	je     f0104ae6 <readline+0x7f>
				cputchar(c);
f0104b24:	83 ec 0c             	sub    $0xc,%esp
f0104b27:	56                   	push   %esi
f0104b28:	e8 1a bd ff ff       	call   f0100847 <cputchar>
f0104b2d:	83 c4 10             	add    $0x10,%esp
f0104b30:	eb b4                	jmp    f0104ae6 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f0104b32:	83 fe 0a             	cmp    $0xa,%esi
f0104b35:	74 05                	je     f0104b3c <readline+0xd5>
f0104b37:	83 fe 0d             	cmp    $0xd,%esi
f0104b3a:	75 b6                	jne    f0104af2 <readline+0x8b>
			if (echoing)
f0104b3c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104b40:	75 13                	jne    f0104b55 <readline+0xee>
			buf[i] = 0;
f0104b42:	c6 84 3b 24 2f 00 00 	movb   $0x0,0x2f24(%ebx,%edi,1)
f0104b49:	00 
			return buf;
f0104b4a:	8d 83 24 2f 00 00    	lea    0x2f24(%ebx),%eax
f0104b50:	e9 6f ff ff ff       	jmp    f0104ac4 <readline+0x5d>
				cputchar('\n');
f0104b55:	83 ec 0c             	sub    $0xc,%esp
f0104b58:	6a 0a                	push   $0xa
f0104b5a:	e8 e8 bc ff ff       	call   f0100847 <cputchar>
f0104b5f:	83 c4 10             	add    $0x10,%esp
f0104b62:	eb de                	jmp    f0104b42 <readline+0xdb>

f0104b64 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104b64:	55                   	push   %ebp
f0104b65:	89 e5                	mov    %esp,%ebp
f0104b67:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104b6a:	b8 00 00 00 00       	mov    $0x0,%eax
f0104b6f:	eb 03                	jmp    f0104b74 <strlen+0x10>
		n++;
f0104b71:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0104b74:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104b78:	75 f7                	jne    f0104b71 <strlen+0xd>
	return n;
}
f0104b7a:	5d                   	pop    %ebp
f0104b7b:	c3                   	ret    

f0104b7c <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104b7c:	55                   	push   %ebp
f0104b7d:	89 e5                	mov    %esp,%ebp
f0104b7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104b82:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104b85:	b8 00 00 00 00       	mov    $0x0,%eax
f0104b8a:	eb 03                	jmp    f0104b8f <strnlen+0x13>
		n++;
f0104b8c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104b8f:	39 d0                	cmp    %edx,%eax
f0104b91:	74 06                	je     f0104b99 <strnlen+0x1d>
f0104b93:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104b97:	75 f3                	jne    f0104b8c <strnlen+0x10>
	return n;
}
f0104b99:	5d                   	pop    %ebp
f0104b9a:	c3                   	ret    

f0104b9b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104b9b:	55                   	push   %ebp
f0104b9c:	89 e5                	mov    %esp,%ebp
f0104b9e:	53                   	push   %ebx
f0104b9f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ba2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104ba5:	89 c2                	mov    %eax,%edx
f0104ba7:	83 c1 01             	add    $0x1,%ecx
f0104baa:	83 c2 01             	add    $0x1,%edx
f0104bad:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0104bb1:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104bb4:	84 db                	test   %bl,%bl
f0104bb6:	75 ef                	jne    f0104ba7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104bb8:	5b                   	pop    %ebx
f0104bb9:	5d                   	pop    %ebp
f0104bba:	c3                   	ret    

f0104bbb <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104bbb:	55                   	push   %ebp
f0104bbc:	89 e5                	mov    %esp,%ebp
f0104bbe:	53                   	push   %ebx
f0104bbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104bc2:	53                   	push   %ebx
f0104bc3:	e8 9c ff ff ff       	call   f0104b64 <strlen>
f0104bc8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0104bcb:	ff 75 0c             	pushl  0xc(%ebp)
f0104bce:	01 d8                	add    %ebx,%eax
f0104bd0:	50                   	push   %eax
f0104bd1:	e8 c5 ff ff ff       	call   f0104b9b <strcpy>
	return dst;
}
f0104bd6:	89 d8                	mov    %ebx,%eax
f0104bd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104bdb:	c9                   	leave  
f0104bdc:	c3                   	ret    

f0104bdd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104bdd:	55                   	push   %ebp
f0104bde:	89 e5                	mov    %esp,%ebp
f0104be0:	56                   	push   %esi
f0104be1:	53                   	push   %ebx
f0104be2:	8b 75 08             	mov    0x8(%ebp),%esi
f0104be5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104be8:	89 f3                	mov    %esi,%ebx
f0104bea:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104bed:	89 f2                	mov    %esi,%edx
f0104bef:	eb 0f                	jmp    f0104c00 <strncpy+0x23>
		*dst++ = *src;
f0104bf1:	83 c2 01             	add    $0x1,%edx
f0104bf4:	0f b6 01             	movzbl (%ecx),%eax
f0104bf7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104bfa:	80 39 01             	cmpb   $0x1,(%ecx)
f0104bfd:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0104c00:	39 da                	cmp    %ebx,%edx
f0104c02:	75 ed                	jne    f0104bf1 <strncpy+0x14>
	}
	return ret;
}
f0104c04:	89 f0                	mov    %esi,%eax
f0104c06:	5b                   	pop    %ebx
f0104c07:	5e                   	pop    %esi
f0104c08:	5d                   	pop    %ebp
f0104c09:	c3                   	ret    

f0104c0a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104c0a:	55                   	push   %ebp
f0104c0b:	89 e5                	mov    %esp,%ebp
f0104c0d:	56                   	push   %esi
f0104c0e:	53                   	push   %ebx
f0104c0f:	8b 75 08             	mov    0x8(%ebp),%esi
f0104c12:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104c15:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104c18:	89 f0                	mov    %esi,%eax
f0104c1a:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104c1e:	85 c9                	test   %ecx,%ecx
f0104c20:	75 0b                	jne    f0104c2d <strlcpy+0x23>
f0104c22:	eb 17                	jmp    f0104c3b <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104c24:	83 c2 01             	add    $0x1,%edx
f0104c27:	83 c0 01             	add    $0x1,%eax
f0104c2a:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0104c2d:	39 d8                	cmp    %ebx,%eax
f0104c2f:	74 07                	je     f0104c38 <strlcpy+0x2e>
f0104c31:	0f b6 0a             	movzbl (%edx),%ecx
f0104c34:	84 c9                	test   %cl,%cl
f0104c36:	75 ec                	jne    f0104c24 <strlcpy+0x1a>
		*dst = '\0';
f0104c38:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104c3b:	29 f0                	sub    %esi,%eax
}
f0104c3d:	5b                   	pop    %ebx
f0104c3e:	5e                   	pop    %esi
f0104c3f:	5d                   	pop    %ebp
f0104c40:	c3                   	ret    

f0104c41 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104c41:	55                   	push   %ebp
f0104c42:	89 e5                	mov    %esp,%ebp
f0104c44:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104c47:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104c4a:	eb 06                	jmp    f0104c52 <strcmp+0x11>
		p++, q++;
f0104c4c:	83 c1 01             	add    $0x1,%ecx
f0104c4f:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0104c52:	0f b6 01             	movzbl (%ecx),%eax
f0104c55:	84 c0                	test   %al,%al
f0104c57:	74 04                	je     f0104c5d <strcmp+0x1c>
f0104c59:	3a 02                	cmp    (%edx),%al
f0104c5b:	74 ef                	je     f0104c4c <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104c5d:	0f b6 c0             	movzbl %al,%eax
f0104c60:	0f b6 12             	movzbl (%edx),%edx
f0104c63:	29 d0                	sub    %edx,%eax
}
f0104c65:	5d                   	pop    %ebp
f0104c66:	c3                   	ret    

f0104c67 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104c67:	55                   	push   %ebp
f0104c68:	89 e5                	mov    %esp,%ebp
f0104c6a:	53                   	push   %ebx
f0104c6b:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c6e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104c71:	89 c3                	mov    %eax,%ebx
f0104c73:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104c76:	eb 06                	jmp    f0104c7e <strncmp+0x17>
		n--, p++, q++;
f0104c78:	83 c0 01             	add    $0x1,%eax
f0104c7b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0104c7e:	39 d8                	cmp    %ebx,%eax
f0104c80:	74 16                	je     f0104c98 <strncmp+0x31>
f0104c82:	0f b6 08             	movzbl (%eax),%ecx
f0104c85:	84 c9                	test   %cl,%cl
f0104c87:	74 04                	je     f0104c8d <strncmp+0x26>
f0104c89:	3a 0a                	cmp    (%edx),%cl
f0104c8b:	74 eb                	je     f0104c78 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104c8d:	0f b6 00             	movzbl (%eax),%eax
f0104c90:	0f b6 12             	movzbl (%edx),%edx
f0104c93:	29 d0                	sub    %edx,%eax
}
f0104c95:	5b                   	pop    %ebx
f0104c96:	5d                   	pop    %ebp
f0104c97:	c3                   	ret    
		return 0;
f0104c98:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c9d:	eb f6                	jmp    f0104c95 <strncmp+0x2e>

f0104c9f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104c9f:	55                   	push   %ebp
f0104ca0:	89 e5                	mov    %esp,%ebp
f0104ca2:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ca5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104ca9:	0f b6 10             	movzbl (%eax),%edx
f0104cac:	84 d2                	test   %dl,%dl
f0104cae:	74 09                	je     f0104cb9 <strchr+0x1a>
		if (*s == c)
f0104cb0:	38 ca                	cmp    %cl,%dl
f0104cb2:	74 0a                	je     f0104cbe <strchr+0x1f>
	for (; *s; s++)
f0104cb4:	83 c0 01             	add    $0x1,%eax
f0104cb7:	eb f0                	jmp    f0104ca9 <strchr+0xa>
			return (char *) s;
	return 0;
f0104cb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104cbe:	5d                   	pop    %ebp
f0104cbf:	c3                   	ret    

f0104cc0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104cc0:	55                   	push   %ebp
f0104cc1:	89 e5                	mov    %esp,%ebp
f0104cc3:	8b 45 08             	mov    0x8(%ebp),%eax
f0104cc6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104cca:	eb 03                	jmp    f0104ccf <strfind+0xf>
f0104ccc:	83 c0 01             	add    $0x1,%eax
f0104ccf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0104cd2:	38 ca                	cmp    %cl,%dl
f0104cd4:	74 04                	je     f0104cda <strfind+0x1a>
f0104cd6:	84 d2                	test   %dl,%dl
f0104cd8:	75 f2                	jne    f0104ccc <strfind+0xc>
			break;
	return (char *) s;
}
f0104cda:	5d                   	pop    %ebp
f0104cdb:	c3                   	ret    

f0104cdc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104cdc:	55                   	push   %ebp
f0104cdd:	89 e5                	mov    %esp,%ebp
f0104cdf:	57                   	push   %edi
f0104ce0:	56                   	push   %esi
f0104ce1:	53                   	push   %ebx
f0104ce2:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104ce5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104ce8:	85 c9                	test   %ecx,%ecx
f0104cea:	74 13                	je     f0104cff <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104cec:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104cf2:	75 05                	jne    f0104cf9 <memset+0x1d>
f0104cf4:	f6 c1 03             	test   $0x3,%cl
f0104cf7:	74 0d                	je     f0104d06 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104cf9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104cfc:	fc                   	cld    
f0104cfd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104cff:	89 f8                	mov    %edi,%eax
f0104d01:	5b                   	pop    %ebx
f0104d02:	5e                   	pop    %esi
f0104d03:	5f                   	pop    %edi
f0104d04:	5d                   	pop    %ebp
f0104d05:	c3                   	ret    
		c &= 0xFF;
f0104d06:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104d0a:	89 d3                	mov    %edx,%ebx
f0104d0c:	c1 e3 08             	shl    $0x8,%ebx
f0104d0f:	89 d0                	mov    %edx,%eax
f0104d11:	c1 e0 18             	shl    $0x18,%eax
f0104d14:	89 d6                	mov    %edx,%esi
f0104d16:	c1 e6 10             	shl    $0x10,%esi
f0104d19:	09 f0                	or     %esi,%eax
f0104d1b:	09 c2                	or     %eax,%edx
f0104d1d:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0104d1f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0104d22:	89 d0                	mov    %edx,%eax
f0104d24:	fc                   	cld    
f0104d25:	f3 ab                	rep stos %eax,%es:(%edi)
f0104d27:	eb d6                	jmp    f0104cff <memset+0x23>

f0104d29 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104d29:	55                   	push   %ebp
f0104d2a:	89 e5                	mov    %esp,%ebp
f0104d2c:	57                   	push   %edi
f0104d2d:	56                   	push   %esi
f0104d2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d31:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104d34:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104d37:	39 c6                	cmp    %eax,%esi
f0104d39:	73 35                	jae    f0104d70 <memmove+0x47>
f0104d3b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104d3e:	39 c2                	cmp    %eax,%edx
f0104d40:	76 2e                	jbe    f0104d70 <memmove+0x47>
		s += n;
		d += n;
f0104d42:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104d45:	89 d6                	mov    %edx,%esi
f0104d47:	09 fe                	or     %edi,%esi
f0104d49:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104d4f:	74 0c                	je     f0104d5d <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104d51:	83 ef 01             	sub    $0x1,%edi
f0104d54:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0104d57:	fd                   	std    
f0104d58:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104d5a:	fc                   	cld    
f0104d5b:	eb 21                	jmp    f0104d7e <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104d5d:	f6 c1 03             	test   $0x3,%cl
f0104d60:	75 ef                	jne    f0104d51 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104d62:	83 ef 04             	sub    $0x4,%edi
f0104d65:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104d68:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0104d6b:	fd                   	std    
f0104d6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104d6e:	eb ea                	jmp    f0104d5a <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104d70:	89 f2                	mov    %esi,%edx
f0104d72:	09 c2                	or     %eax,%edx
f0104d74:	f6 c2 03             	test   $0x3,%dl
f0104d77:	74 09                	je     f0104d82 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104d79:	89 c7                	mov    %eax,%edi
f0104d7b:	fc                   	cld    
f0104d7c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104d7e:	5e                   	pop    %esi
f0104d7f:	5f                   	pop    %edi
f0104d80:	5d                   	pop    %ebp
f0104d81:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104d82:	f6 c1 03             	test   $0x3,%cl
f0104d85:	75 f2                	jne    f0104d79 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104d87:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0104d8a:	89 c7                	mov    %eax,%edi
f0104d8c:	fc                   	cld    
f0104d8d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104d8f:	eb ed                	jmp    f0104d7e <memmove+0x55>

f0104d91 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104d91:	55                   	push   %ebp
f0104d92:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0104d94:	ff 75 10             	pushl  0x10(%ebp)
f0104d97:	ff 75 0c             	pushl  0xc(%ebp)
f0104d9a:	ff 75 08             	pushl  0x8(%ebp)
f0104d9d:	e8 87 ff ff ff       	call   f0104d29 <memmove>
}
f0104da2:	c9                   	leave  
f0104da3:	c3                   	ret    

f0104da4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104da4:	55                   	push   %ebp
f0104da5:	89 e5                	mov    %esp,%ebp
f0104da7:	56                   	push   %esi
f0104da8:	53                   	push   %ebx
f0104da9:	8b 45 08             	mov    0x8(%ebp),%eax
f0104dac:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104daf:	89 c6                	mov    %eax,%esi
f0104db1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104db4:	39 f0                	cmp    %esi,%eax
f0104db6:	74 1c                	je     f0104dd4 <memcmp+0x30>
		if (*s1 != *s2)
f0104db8:	0f b6 08             	movzbl (%eax),%ecx
f0104dbb:	0f b6 1a             	movzbl (%edx),%ebx
f0104dbe:	38 d9                	cmp    %bl,%cl
f0104dc0:	75 08                	jne    f0104dca <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0104dc2:	83 c0 01             	add    $0x1,%eax
f0104dc5:	83 c2 01             	add    $0x1,%edx
f0104dc8:	eb ea                	jmp    f0104db4 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0104dca:	0f b6 c1             	movzbl %cl,%eax
f0104dcd:	0f b6 db             	movzbl %bl,%ebx
f0104dd0:	29 d8                	sub    %ebx,%eax
f0104dd2:	eb 05                	jmp    f0104dd9 <memcmp+0x35>
	}

	return 0;
f0104dd4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104dd9:	5b                   	pop    %ebx
f0104dda:	5e                   	pop    %esi
f0104ddb:	5d                   	pop    %ebp
f0104ddc:	c3                   	ret    

f0104ddd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104ddd:	55                   	push   %ebp
f0104dde:	89 e5                	mov    %esp,%ebp
f0104de0:	8b 45 08             	mov    0x8(%ebp),%eax
f0104de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104de6:	89 c2                	mov    %eax,%edx
f0104de8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104deb:	39 d0                	cmp    %edx,%eax
f0104ded:	73 09                	jae    f0104df8 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104def:	38 08                	cmp    %cl,(%eax)
f0104df1:	74 05                	je     f0104df8 <memfind+0x1b>
	for (; s < ends; s++)
f0104df3:	83 c0 01             	add    $0x1,%eax
f0104df6:	eb f3                	jmp    f0104deb <memfind+0xe>
			break;
	return (void *) s;
}
f0104df8:	5d                   	pop    %ebp
f0104df9:	c3                   	ret    

f0104dfa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104dfa:	55                   	push   %ebp
f0104dfb:	89 e5                	mov    %esp,%ebp
f0104dfd:	57                   	push   %edi
f0104dfe:	56                   	push   %esi
f0104dff:	53                   	push   %ebx
f0104e00:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104e03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104e06:	eb 03                	jmp    f0104e0b <strtol+0x11>
		s++;
f0104e08:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0104e0b:	0f b6 01             	movzbl (%ecx),%eax
f0104e0e:	3c 20                	cmp    $0x20,%al
f0104e10:	74 f6                	je     f0104e08 <strtol+0xe>
f0104e12:	3c 09                	cmp    $0x9,%al
f0104e14:	74 f2                	je     f0104e08 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0104e16:	3c 2b                	cmp    $0x2b,%al
f0104e18:	74 2e                	je     f0104e48 <strtol+0x4e>
	int neg = 0;
f0104e1a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0104e1f:	3c 2d                	cmp    $0x2d,%al
f0104e21:	74 2f                	je     f0104e52 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104e23:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0104e29:	75 05                	jne    f0104e30 <strtol+0x36>
f0104e2b:	80 39 30             	cmpb   $0x30,(%ecx)
f0104e2e:	74 2c                	je     f0104e5c <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104e30:	85 db                	test   %ebx,%ebx
f0104e32:	75 0a                	jne    f0104e3e <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104e34:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f0104e39:	80 39 30             	cmpb   $0x30,(%ecx)
f0104e3c:	74 28                	je     f0104e66 <strtol+0x6c>
		base = 10;
f0104e3e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e43:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104e46:	eb 50                	jmp    f0104e98 <strtol+0x9e>
		s++;
f0104e48:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0104e4b:	bf 00 00 00 00       	mov    $0x0,%edi
f0104e50:	eb d1                	jmp    f0104e23 <strtol+0x29>
		s++, neg = 1;
f0104e52:	83 c1 01             	add    $0x1,%ecx
f0104e55:	bf 01 00 00 00       	mov    $0x1,%edi
f0104e5a:	eb c7                	jmp    f0104e23 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104e5c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0104e60:	74 0e                	je     f0104e70 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0104e62:	85 db                	test   %ebx,%ebx
f0104e64:	75 d8                	jne    f0104e3e <strtol+0x44>
		s++, base = 8;
f0104e66:	83 c1 01             	add    $0x1,%ecx
f0104e69:	bb 08 00 00 00       	mov    $0x8,%ebx
f0104e6e:	eb ce                	jmp    f0104e3e <strtol+0x44>
		s += 2, base = 16;
f0104e70:	83 c1 02             	add    $0x2,%ecx
f0104e73:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104e78:	eb c4                	jmp    f0104e3e <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0104e7a:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104e7d:	89 f3                	mov    %esi,%ebx
f0104e7f:	80 fb 19             	cmp    $0x19,%bl
f0104e82:	77 29                	ja     f0104ead <strtol+0xb3>
			dig = *s - 'a' + 10;
f0104e84:	0f be d2             	movsbl %dl,%edx
f0104e87:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104e8a:	3b 55 10             	cmp    0x10(%ebp),%edx
f0104e8d:	7d 30                	jge    f0104ebf <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0104e8f:	83 c1 01             	add    $0x1,%ecx
f0104e92:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104e96:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0104e98:	0f b6 11             	movzbl (%ecx),%edx
f0104e9b:	8d 72 d0             	lea    -0x30(%edx),%esi
f0104e9e:	89 f3                	mov    %esi,%ebx
f0104ea0:	80 fb 09             	cmp    $0x9,%bl
f0104ea3:	77 d5                	ja     f0104e7a <strtol+0x80>
			dig = *s - '0';
f0104ea5:	0f be d2             	movsbl %dl,%edx
f0104ea8:	83 ea 30             	sub    $0x30,%edx
f0104eab:	eb dd                	jmp    f0104e8a <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0104ead:	8d 72 bf             	lea    -0x41(%edx),%esi
f0104eb0:	89 f3                	mov    %esi,%ebx
f0104eb2:	80 fb 19             	cmp    $0x19,%bl
f0104eb5:	77 08                	ja     f0104ebf <strtol+0xc5>
			dig = *s - 'A' + 10;
f0104eb7:	0f be d2             	movsbl %dl,%edx
f0104eba:	83 ea 37             	sub    $0x37,%edx
f0104ebd:	eb cb                	jmp    f0104e8a <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f0104ebf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104ec3:	74 05                	je     f0104eca <strtol+0xd0>
		*endptr = (char *) s;
f0104ec5:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104ec8:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0104eca:	89 c2                	mov    %eax,%edx
f0104ecc:	f7 da                	neg    %edx
f0104ece:	85 ff                	test   %edi,%edi
f0104ed0:	0f 45 c2             	cmovne %edx,%eax
}
f0104ed3:	5b                   	pop    %ebx
f0104ed4:	5e                   	pop    %esi
f0104ed5:	5f                   	pop    %edi
f0104ed6:	5d                   	pop    %ebp
f0104ed7:	c3                   	ret    

f0104ed8 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0104ed8:	fa                   	cli    

	xorw    %ax, %ax
f0104ed9:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0104edb:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104edd:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104edf:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0104ee1:	0f 01 16             	lgdtl  (%esi)
f0104ee4:	74 70                	je     f0104f56 <mpsearch1+0x3>
	movl    %cr0, %eax
f0104ee6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0104ee9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0104eed:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0104ef0:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0104ef6:	08 00                	or     %al,(%eax)

f0104ef8 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0104ef8:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0104efc:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104efe:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104f00:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0104f02:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0104f06:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0104f08:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0104f0a:	b8 00 40 23 00       	mov    $0x234000,%eax
	movl    %eax, %cr3
f0104f0f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0104f12:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0104f15:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0104f1a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0104f1d:	8b 25 04 6f 23 f0    	mov    0xf0236f04,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0104f23:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0104f28:	b8 e3 01 10 f0       	mov    $0xf01001e3,%eax
	call    *%eax
f0104f2d:	ff d0                	call   *%eax

f0104f2f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0104f2f:	eb fe                	jmp    f0104f2f <spin>
f0104f31:	8d 76 00             	lea    0x0(%esi),%esi

f0104f34 <gdt>:
	...
f0104f3c:	ff                   	(bad)  
f0104f3d:	ff 00                	incl   (%eax)
f0104f3f:	00 00                	add    %al,(%eax)
f0104f41:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0104f48:	00                   	.byte 0x0
f0104f49:	92                   	xchg   %eax,%edx
f0104f4a:	cf                   	iret   
	...

f0104f4c <gdtdesc>:
f0104f4c:	17                   	pop    %ss
f0104f4d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0104f52 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0104f52:	90                   	nop

f0104f53 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0104f53:	55                   	push   %ebp
f0104f54:	89 e5                	mov    %esp,%ebp
f0104f56:	57                   	push   %edi
f0104f57:	56                   	push   %esi
f0104f58:	53                   	push   %ebx
f0104f59:	83 ec 1c             	sub    $0x1c,%esp
f0104f5c:	e8 50 b3 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0104f61:	81 c3 7b ec 12 00    	add    $0x12ec7b,%ebx
	if (PGNUM(pa) >= npages)
f0104f67:	c7 c1 08 6f 23 f0    	mov    $0xf0236f08,%ecx
f0104f6d:	8b 09                	mov    (%ecx),%ecx
f0104f6f:	89 c6                	mov    %eax,%esi
f0104f71:	c1 ee 0c             	shr    $0xc,%esi
f0104f74:	39 ce                	cmp    %ecx,%esi
f0104f76:	73 25                	jae    f0104f9d <mpsearch1+0x4a>
	return (void *)(pa + KERNBASE);
f0104f78:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0104f7e:	01 c2                	add    %eax,%edx
	if (PGNUM(pa) >= npages)
f0104f80:	89 d0                	mov    %edx,%eax
f0104f82:	c1 e8 0c             	shr    $0xc,%eax
f0104f85:	39 c8                	cmp    %ecx,%eax
f0104f87:	73 2a                	jae    f0104fb3 <mpsearch1+0x60>
	return (void *)(pa + KERNBASE);
f0104f89:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0104f8f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0104f92:	8d 83 01 36 ed ff    	lea    -0x12c9ff(%ebx),%eax
f0104f98:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (; mp < end; mp++)
f0104f9b:	eb 2f                	jmp    f0104fcc <mpsearch1+0x79>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104f9d:	50                   	push   %eax
f0104f9e:	8d 83 28 1f ed ff    	lea    -0x12e0d8(%ebx),%eax
f0104fa4:	50                   	push   %eax
f0104fa5:	6a 57                	push   $0x57
f0104fa7:	8d 83 f1 35 ed ff    	lea    -0x12ca0f(%ebx),%eax
f0104fad:	50                   	push   %eax
f0104fae:	e8 8d b0 ff ff       	call   f0100040 <_panic>
f0104fb3:	52                   	push   %edx
f0104fb4:	8d 83 28 1f ed ff    	lea    -0x12e0d8(%ebx),%eax
f0104fba:	50                   	push   %eax
f0104fbb:	6a 57                	push   $0x57
f0104fbd:	8d 83 f1 35 ed ff    	lea    -0x12ca0f(%ebx),%eax
f0104fc3:	50                   	push   %eax
f0104fc4:	e8 77 b0 ff ff       	call   f0100040 <_panic>
f0104fc9:	83 c6 10             	add    $0x10,%esi
f0104fcc:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0104fcf:	73 2c                	jae    f0104ffd <mpsearch1+0xaa>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0104fd1:	83 ec 04             	sub    $0x4,%esp
f0104fd4:	6a 04                	push   $0x4
f0104fd6:	ff 75 e0             	pushl  -0x20(%ebp)
f0104fd9:	56                   	push   %esi
f0104fda:	e8 c5 fd ff ff       	call   f0104da4 <memcmp>
f0104fdf:	83 c4 10             	add    $0x10,%esp
f0104fe2:	85 c0                	test   %eax,%eax
f0104fe4:	75 e3                	jne    f0104fc9 <mpsearch1+0x76>
f0104fe6:	89 f2                	mov    %esi,%edx
f0104fe8:	8d 7e 10             	lea    0x10(%esi),%edi
		sum += ((uint8_t *)addr)[i];
f0104feb:	0f b6 0a             	movzbl (%edx),%ecx
f0104fee:	01 c8                	add    %ecx,%eax
f0104ff0:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f0104ff3:	39 fa                	cmp    %edi,%edx
f0104ff5:	75 f4                	jne    f0104feb <mpsearch1+0x98>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0104ff7:	84 c0                	test   %al,%al
f0104ff9:	75 ce                	jne    f0104fc9 <mpsearch1+0x76>
f0104ffb:	eb 05                	jmp    f0105002 <mpsearch1+0xaf>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0104ffd:	be 00 00 00 00       	mov    $0x0,%esi
}
f0105002:	89 f0                	mov    %esi,%eax
f0105004:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105007:	5b                   	pop    %ebx
f0105008:	5e                   	pop    %esi
f0105009:	5f                   	pop    %edi
f010500a:	5d                   	pop    %ebp
f010500b:	c3                   	ret    

f010500c <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010500c:	55                   	push   %ebp
f010500d:	89 e5                	mov    %esp,%ebp
f010500f:	57                   	push   %edi
f0105010:	56                   	push   %esi
f0105011:	53                   	push   %ebx
f0105012:	83 ec 1c             	sub    $0x1c,%esp
f0105015:	e8 97 b2 ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f010501a:	81 c3 c2 eb 12 00    	add    $0x12ebc2,%ebx
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105020:	c7 c0 c0 73 23 f0    	mov    $0xf02373c0,%eax
f0105026:	c7 c2 20 70 23 f0    	mov    $0xf0237020,%edx
f010502c:	89 10                	mov    %edx,(%eax)
	if (PGNUM(pa) >= npages)
f010502e:	c7 c0 08 6f 23 f0    	mov    $0xf0236f08,%eax
f0105034:	83 38 00             	cmpl   $0x0,(%eax)
f0105037:	0f 84 8c 00 00 00    	je     f01050c9 <mp_init+0xbd>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010503d:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105044:	85 c0                	test   %eax,%eax
f0105046:	0f 84 97 00 00 00    	je     f01050e3 <mp_init+0xd7>
		p <<= 4;	// Translate from segment to PA
f010504c:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f010504f:	ba 00 04 00 00       	mov    $0x400,%edx
f0105054:	e8 fa fe ff ff       	call   f0104f53 <mpsearch1>
f0105059:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010505c:	85 c0                	test   %eax,%eax
f010505e:	0f 84 a3 00 00 00    	je     f0105107 <mp_init+0xfb>
	if (mp->physaddr == 0 || mp->type != 0) {
f0105064:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105067:	8b 41 04             	mov    0x4(%ecx),%eax
f010506a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010506d:	85 c0                	test   %eax,%eax
f010506f:	0f 84 b1 00 00 00    	je     f0105126 <mp_init+0x11a>
f0105075:	80 79 0b 00          	cmpb   $0x0,0xb(%ecx)
f0105079:	0f 85 a7 00 00 00    	jne    f0105126 <mp_init+0x11a>
f010507f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105082:	c1 ea 0c             	shr    $0xc,%edx
f0105085:	c7 c0 08 6f 23 f0    	mov    $0xf0236f08,%eax
f010508b:	3b 10                	cmp    (%eax),%edx
f010508d:	0f 83 aa 00 00 00    	jae    f010513d <mp_init+0x131>
	return (void *)(pa + KERNBASE);
f0105093:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105096:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
f010509c:	89 75 e4             	mov    %esi,-0x1c(%ebp)
	if (memcmp(conf, "PCMP", 4) != 0) {
f010509f:	83 ec 04             	sub    $0x4,%esp
f01050a2:	6a 04                	push   $0x4
f01050a4:	8d 83 06 36 ed ff    	lea    -0x12c9fa(%ebx),%eax
f01050aa:	50                   	push   %eax
f01050ab:	56                   	push   %esi
f01050ac:	e8 f3 fc ff ff       	call   f0104da4 <memcmp>
f01050b1:	83 c4 10             	add    $0x10,%esp
f01050b4:	85 c0                	test   %eax,%eax
f01050b6:	0f 85 9c 00 00 00    	jne    f0105158 <mp_init+0x14c>
f01050bc:	0f b7 7e 04          	movzwl 0x4(%esi),%edi
f01050c0:	01 f7                	add    %esi,%edi
	sum = 0;
f01050c2:	89 c2                	mov    %eax,%edx
f01050c4:	e9 ae 00 00 00       	jmp    f0105177 <mp_init+0x16b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01050c9:	68 00 04 00 00       	push   $0x400
f01050ce:	8d 83 28 1f ed ff    	lea    -0x12e0d8(%ebx),%eax
f01050d4:	50                   	push   %eax
f01050d5:	6a 6f                	push   $0x6f
f01050d7:	8d 83 f1 35 ed ff    	lea    -0x12ca0f(%ebx),%eax
f01050dd:	50                   	push   %eax
f01050de:	e8 5d af ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f01050e3:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01050ea:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01050ed:	2d 00 04 00 00       	sub    $0x400,%eax
f01050f2:	ba 00 04 00 00       	mov    $0x400,%edx
f01050f7:	e8 57 fe ff ff       	call   f0104f53 <mpsearch1>
f01050fc:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01050ff:	85 c0                	test   %eax,%eax
f0105101:	0f 85 5d ff ff ff    	jne    f0105064 <mp_init+0x58>
	return mpsearch1(0xF0000, 0x10000);
f0105107:	ba 00 00 01 00       	mov    $0x10000,%edx
f010510c:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105111:	e8 3d fe ff ff       	call   f0104f53 <mpsearch1>
f0105116:	89 45 dc             	mov    %eax,-0x24(%ebp)
	if ((mp = mpsearch()) == 0)
f0105119:	85 c0                	test   %eax,%eax
f010511b:	0f 85 43 ff ff ff    	jne    f0105064 <mp_init+0x58>
f0105121:	e9 f9 01 00 00       	jmp    f010531f <mp_init+0x313>
		cprintf("SMP: Default configurations not implemented\n");
f0105126:	83 ec 0c             	sub    $0xc,%esp
f0105129:	8d 83 64 34 ed ff    	lea    -0x12cb9c(%ebx),%eax
f010512f:	50                   	push   %eax
f0105130:	e8 ca e2 ff ff       	call   f01033ff <cprintf>
f0105135:	83 c4 10             	add    $0x10,%esp
f0105138:	e9 e2 01 00 00       	jmp    f010531f <mp_init+0x313>
f010513d:	ff 75 e0             	pushl  -0x20(%ebp)
f0105140:	8d 83 28 1f ed ff    	lea    -0x12e0d8(%ebx),%eax
f0105146:	50                   	push   %eax
f0105147:	68 90 00 00 00       	push   $0x90
f010514c:	8d 83 f1 35 ed ff    	lea    -0x12ca0f(%ebx),%eax
f0105152:	50                   	push   %eax
f0105153:	e8 e8 ae ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105158:	83 ec 0c             	sub    $0xc,%esp
f010515b:	8d 83 94 34 ed ff    	lea    -0x12cb6c(%ebx),%eax
f0105161:	50                   	push   %eax
f0105162:	e8 98 e2 ff ff       	call   f01033ff <cprintf>
f0105167:	83 c4 10             	add    $0x10,%esp
f010516a:	e9 b0 01 00 00       	jmp    f010531f <mp_init+0x313>
		sum += ((uint8_t *)addr)[i];
f010516f:	0f b6 0e             	movzbl (%esi),%ecx
f0105172:	01 ca                	add    %ecx,%edx
f0105174:	83 c6 01             	add    $0x1,%esi
	for (i = 0; i < len; i++)
f0105177:	39 fe                	cmp    %edi,%esi
f0105179:	75 f4                	jne    f010516f <mp_init+0x163>
	if (sum(conf, conf->length) != 0) {
f010517b:	84 d2                	test   %dl,%dl
f010517d:	75 1c                	jne    f010519b <mp_init+0x18f>
	if (conf->version != 1 && conf->version != 4) {
f010517f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105182:	0f b6 57 06          	movzbl 0x6(%edi),%edx
f0105186:	80 fa 01             	cmp    $0x1,%dl
f0105189:	74 05                	je     f0105190 <mp_init+0x184>
f010518b:	80 fa 04             	cmp    $0x4,%dl
f010518e:	75 22                	jne    f01051b2 <mp_init+0x1a6>
f0105190:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105193:	0f b7 49 28          	movzwl 0x28(%ecx),%ecx
f0105197:	01 f1                	add    %esi,%ecx
f0105199:	eb 3a                	jmp    f01051d5 <mp_init+0x1c9>
		cprintf("SMP: Bad MP configuration checksum\n");
f010519b:	83 ec 0c             	sub    $0xc,%esp
f010519e:	8d 83 c8 34 ed ff    	lea    -0x12cb38(%ebx),%eax
f01051a4:	50                   	push   %eax
f01051a5:	e8 55 e2 ff ff       	call   f01033ff <cprintf>
f01051aa:	83 c4 10             	add    $0x10,%esp
f01051ad:	e9 6d 01 00 00       	jmp    f010531f <mp_init+0x313>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01051b2:	83 ec 08             	sub    $0x8,%esp
f01051b5:	0f b6 d2             	movzbl %dl,%edx
f01051b8:	52                   	push   %edx
f01051b9:	8d 83 ec 34 ed ff    	lea    -0x12cb14(%ebx),%eax
f01051bf:	50                   	push   %eax
f01051c0:	e8 3a e2 ff ff       	call   f01033ff <cprintf>
f01051c5:	83 c4 10             	add    $0x10,%esp
f01051c8:	e9 52 01 00 00       	jmp    f010531f <mp_init+0x313>
		sum += ((uint8_t *)addr)[i];
f01051cd:	0f b6 16             	movzbl (%esi),%edx
f01051d0:	01 d0                	add    %edx,%eax
f01051d2:	83 c6 01             	add    $0x1,%esi
	for (i = 0; i < len; i++)
f01051d5:	39 f1                	cmp    %esi,%ecx
f01051d7:	75 f4                	jne    f01051cd <mp_init+0x1c1>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01051d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051dc:	02 47 2a             	add    0x2a(%edi),%al
f01051df:	75 43                	jne    f0105224 <mp_init+0x218>
	if ((conf = mpconfig(&mp)) == 0)
f01051e1:	81 7d e0 00 00 00 10 	cmpl   $0x10000000,-0x20(%ebp)
f01051e8:	0f 84 31 01 00 00    	je     f010531f <mp_init+0x313>
		return;
	ismp = 1;
f01051ee:	c7 c0 00 70 23 f0    	mov    $0xf0237000,%eax
f01051f4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
	lapicaddr = conf->lapicaddr;
f01051fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051fd:	8b 57 24             	mov    0x24(%edi),%edx
f0105200:	c7 c0 00 80 27 f0    	mov    $0xf0278000,%eax
f0105206:	89 10                	mov    %edx,(%eax)

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105208:	83 c7 2c             	add    $0x2c,%edi
f010520b:	be 00 00 00 00       	mov    $0x0,%esi
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
				bootcpu = &cpus[ncpu];
			if (ncpu < NCPU) {
f0105210:	c7 c0 c4 73 23 f0    	mov    $0xf02373c4,%eax
f0105216:	89 45 e0             	mov    %eax,-0x20(%ebp)
				cpus[ncpu].cpu_id = ncpu;
f0105219:	c7 c0 20 70 23 f0    	mov    $0xf0237020,%eax
f010521f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105222:	eb 58                	jmp    f010527c <mp_init+0x270>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105224:	83 ec 0c             	sub    $0xc,%esp
f0105227:	8d 83 0c 35 ed ff    	lea    -0x12caf4(%ebx),%eax
f010522d:	50                   	push   %eax
f010522e:	e8 cc e1 ff ff       	call   f01033ff <cprintf>
f0105233:	83 c4 10             	add    $0x10,%esp
f0105236:	e9 e4 00 00 00       	jmp    f010531f <mp_init+0x313>
			if (proc->flags & MPPROC_BOOT)
f010523b:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f010523f:	74 17                	je     f0105258 <mp_init+0x24c>
				bootcpu = &cpus[ncpu];
f0105241:	c7 c0 c4 73 23 f0    	mov    $0xf02373c4,%eax
f0105247:	6b 00 74             	imul   $0x74,(%eax),%eax
f010524a:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0105250:	c7 c2 c0 73 23 f0    	mov    $0xf02373c0,%edx
f0105256:	89 02                	mov    %eax,(%edx)
			if (ncpu < NCPU) {
f0105258:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010525b:	8b 00                	mov    (%eax),%eax
f010525d:	83 f8 07             	cmp    $0x7,%eax
f0105260:	7f 35                	jg     f0105297 <mp_init+0x28b>
				cpus[ncpu].cpu_id = ncpu;
f0105262:	6b d0 74             	imul   $0x74,%eax,%edx
f0105265:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0105268:	88 04 11             	mov    %al,(%ecx,%edx,1)
				ncpu++;
f010526b:	83 c0 01             	add    $0x1,%eax
f010526e:	c7 c2 c4 73 23 f0    	mov    $0xf02373c4,%edx
f0105274:	89 02                	mov    %eax,(%edx)
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105276:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105279:	83 c6 01             	add    $0x1,%esi
f010527c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010527f:	0f b7 40 22          	movzwl 0x22(%eax),%eax
f0105283:	39 f0                	cmp    %esi,%eax
f0105285:	76 54                	jbe    f01052db <mp_init+0x2cf>
		switch (*p) {
f0105287:	0f b6 07             	movzbl (%edi),%eax
f010528a:	84 c0                	test   %al,%al
f010528c:	74 ad                	je     f010523b <mp_init+0x22f>
f010528e:	3c 04                	cmp    $0x4,%al
f0105290:	77 1e                	ja     f01052b0 <mp_init+0x2a4>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105292:	83 c7 08             	add    $0x8,%edi
			continue;
f0105295:	eb e2                	jmp    f0105279 <mp_init+0x26d>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105297:	83 ec 08             	sub    $0x8,%esp
f010529a:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f010529e:	50                   	push   %eax
f010529f:	8d 83 3c 35 ed ff    	lea    -0x12cac4(%ebx),%eax
f01052a5:	50                   	push   %eax
f01052a6:	e8 54 e1 ff ff       	call   f01033ff <cprintf>
f01052ab:	83 c4 10             	add    $0x10,%esp
f01052ae:	eb c6                	jmp    f0105276 <mp_init+0x26a>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01052b0:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f01052b3:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f01052b6:	50                   	push   %eax
f01052b7:	8d 83 64 35 ed ff    	lea    -0x12ca9c(%ebx),%eax
f01052bd:	50                   	push   %eax
f01052be:	e8 3c e1 ff ff       	call   f01033ff <cprintf>
			ismp = 0;
f01052c3:	c7 c0 00 70 23 f0    	mov    $0xf0237000,%eax
f01052c9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			i = conf->entry;
f01052cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01052d2:	0f b7 70 22          	movzwl 0x22(%eax),%esi
f01052d6:	83 c4 10             	add    $0x10,%esp
f01052d9:	eb 9e                	jmp    f0105279 <mp_init+0x26d>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01052db:	c7 c0 c0 73 23 f0    	mov    $0xf02373c0,%eax
f01052e1:	8b 00                	mov    (%eax),%eax
f01052e3:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01052ea:	c7 c2 00 70 23 f0    	mov    $0xf0237000,%edx
f01052f0:	83 3a 00             	cmpl   $0x0,(%edx)
f01052f3:	75 32                	jne    f0105327 <mp_init+0x31b>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01052f5:	c7 c0 c4 73 23 f0    	mov    $0xf02373c4,%eax
f01052fb:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
		lapicaddr = 0;
f0105301:	c7 c0 00 80 27 f0    	mov    $0xf0278000,%eax
f0105307:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		cprintf("SMP: configuration not found, SMP disabled\n");
f010530d:	83 ec 0c             	sub    $0xc,%esp
f0105310:	8d 83 84 35 ed ff    	lea    -0x12ca7c(%ebx),%eax
f0105316:	50                   	push   %eax
f0105317:	e8 e3 e0 ff ff       	call   f01033ff <cprintf>
		return;
f010531c:	83 c4 10             	add    $0x10,%esp
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f010531f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105322:	5b                   	pop    %ebx
f0105323:	5e                   	pop    %esi
f0105324:	5f                   	pop    %edi
f0105325:	5d                   	pop    %ebp
f0105326:	c3                   	ret    
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105327:	83 ec 04             	sub    $0x4,%esp
f010532a:	c7 c2 c4 73 23 f0    	mov    $0xf02373c4,%edx
f0105330:	ff 32                	pushl  (%edx)
f0105332:	0f b6 00             	movzbl (%eax),%eax
f0105335:	50                   	push   %eax
f0105336:	8d 83 0b 36 ed ff    	lea    -0x12c9f5(%ebx),%eax
f010533c:	50                   	push   %eax
f010533d:	e8 bd e0 ff ff       	call   f01033ff <cprintf>
	if (mp->imcrp) {
f0105342:	83 c4 10             	add    $0x10,%esp
f0105345:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105348:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f010534c:	74 d1                	je     f010531f <mp_init+0x313>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010534e:	83 ec 0c             	sub    $0xc,%esp
f0105351:	8d 83 b0 35 ed ff    	lea    -0x12ca50(%ebx),%eax
f0105357:	50                   	push   %eax
f0105358:	e8 a2 e0 ff ff       	call   f01033ff <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010535d:	b8 70 00 00 00       	mov    $0x70,%eax
f0105362:	ba 22 00 00 00       	mov    $0x22,%edx
f0105367:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105368:	ba 23 00 00 00       	mov    $0x23,%edx
f010536d:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f010536e:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105371:	ee                   	out    %al,(%dx)
f0105372:	83 c4 10             	add    $0x10,%esp
f0105375:	eb a8                	jmp    f010531f <mp_init+0x313>

f0105377 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105377:	55                   	push   %ebp
f0105378:	89 e5                	mov    %esp,%ebp
f010537a:	53                   	push   %ebx
f010537b:	e8 e3 f6 ff ff       	call   f0104a63 <__x86.get_pc_thunk.cx>
f0105380:	81 c1 5c e8 12 00    	add    $0x12e85c,%ecx
	lapic[index] = value;
f0105386:	c7 c1 04 80 27 f0    	mov    $0xf0278004,%ecx
f010538c:	8b 19                	mov    (%ecx),%ebx
f010538e:	8d 04 83             	lea    (%ebx,%eax,4),%eax
f0105391:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105393:	8b 01                	mov    (%ecx),%eax
f0105395:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105398:	5b                   	pop    %ebx
f0105399:	5d                   	pop    %ebp
f010539a:	c3                   	ret    

f010539b <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f010539b:	55                   	push   %ebp
f010539c:	89 e5                	mov    %esp,%ebp
f010539e:	e8 cf b4 ff ff       	call   f0100872 <__x86.get_pc_thunk.ax>
f01053a3:	05 39 e8 12 00       	add    $0x12e839,%eax
	if (lapic)
f01053a8:	c7 c0 04 80 27 f0    	mov    $0xf0278004,%eax
f01053ae:	8b 10                	mov    (%eax),%edx
		return lapic[ID] >> 24;
	return 0;
f01053b0:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f01053b5:	85 d2                	test   %edx,%edx
f01053b7:	74 06                	je     f01053bf <cpunum+0x24>
		return lapic[ID] >> 24;
f01053b9:	8b 42 20             	mov    0x20(%edx),%eax
f01053bc:	c1 e8 18             	shr    $0x18,%eax
}
f01053bf:	5d                   	pop    %ebp
f01053c0:	c3                   	ret    

f01053c1 <lapic_init>:
{
f01053c1:	55                   	push   %ebp
f01053c2:	89 e5                	mov    %esp,%ebp
f01053c4:	53                   	push   %ebx
f01053c5:	83 ec 04             	sub    $0x4,%esp
f01053c8:	e8 e4 ae ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f01053cd:	81 c3 0f e8 12 00    	add    $0x12e80f,%ebx
	if (!lapicaddr)
f01053d3:	c7 c0 00 80 27 f0    	mov    $0xf0278000,%eax
f01053d9:	8b 00                	mov    (%eax),%eax
f01053db:	85 c0                	test   %eax,%eax
f01053dd:	75 05                	jne    f01053e4 <lapic_init+0x23>
}
f01053df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01053e2:	c9                   	leave  
f01053e3:	c3                   	ret    
	lapic = mmio_map_region(lapicaddr, 4096);
f01053e4:	83 ec 08             	sub    $0x8,%esp
f01053e7:	68 00 10 00 00       	push   $0x1000
f01053ec:	50                   	push   %eax
f01053ed:	e8 00 be ff ff       	call   f01011f2 <mmio_map_region>
f01053f2:	c7 c2 04 80 27 f0    	mov    $0xf0278004,%edx
f01053f8:	89 02                	mov    %eax,(%edx)
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01053fa:	ba 27 01 00 00       	mov    $0x127,%edx
f01053ff:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105404:	e8 6e ff ff ff       	call   f0105377 <lapicw>
	lapicw(TDCR, X1);
f0105409:	ba 0b 00 00 00       	mov    $0xb,%edx
f010540e:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105413:	e8 5f ff ff ff       	call   f0105377 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105418:	ba 20 00 02 00       	mov    $0x20020,%edx
f010541d:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105422:	e8 50 ff ff ff       	call   f0105377 <lapicw>
	lapicw(TICR, 10000000); 
f0105427:	ba 80 96 98 00       	mov    $0x989680,%edx
f010542c:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105431:	e8 41 ff ff ff       	call   f0105377 <lapicw>
	if (thiscpu != bootcpu)
f0105436:	e8 60 ff ff ff       	call   f010539b <cpunum>
f010543b:	6b c0 74             	imul   $0x74,%eax,%eax
f010543e:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f0105444:	83 c4 10             	add    $0x10,%esp
f0105447:	c7 c2 c0 73 23 f0    	mov    $0xf02373c0,%edx
f010544d:	39 02                	cmp    %eax,(%edx)
f010544f:	74 0f                	je     f0105460 <lapic_init+0x9f>
		lapicw(LINT0, MASKED);
f0105451:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105456:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010545b:	e8 17 ff ff ff       	call   f0105377 <lapicw>
	lapicw(LINT1, MASKED);
f0105460:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105465:	b8 d8 00 00 00       	mov    $0xd8,%eax
f010546a:	e8 08 ff ff ff       	call   f0105377 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010546f:	c7 c0 04 80 27 f0    	mov    $0xf0278004,%eax
f0105475:	8b 00                	mov    (%eax),%eax
f0105477:	8b 40 30             	mov    0x30(%eax),%eax
f010547a:	c1 e8 10             	shr    $0x10,%eax
f010547d:	3c 03                	cmp    $0x3,%al
f010547f:	0f 87 81 00 00 00    	ja     f0105506 <lapic_init+0x145>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105485:	ba 33 00 00 00       	mov    $0x33,%edx
f010548a:	b8 dc 00 00 00       	mov    $0xdc,%eax
f010548f:	e8 e3 fe ff ff       	call   f0105377 <lapicw>
	lapicw(ESR, 0);
f0105494:	ba 00 00 00 00       	mov    $0x0,%edx
f0105499:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010549e:	e8 d4 fe ff ff       	call   f0105377 <lapicw>
	lapicw(ESR, 0);
f01054a3:	ba 00 00 00 00       	mov    $0x0,%edx
f01054a8:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01054ad:	e8 c5 fe ff ff       	call   f0105377 <lapicw>
	lapicw(EOI, 0);
f01054b2:	ba 00 00 00 00       	mov    $0x0,%edx
f01054b7:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01054bc:	e8 b6 fe ff ff       	call   f0105377 <lapicw>
	lapicw(ICRHI, 0);
f01054c1:	ba 00 00 00 00       	mov    $0x0,%edx
f01054c6:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01054cb:	e8 a7 fe ff ff       	call   f0105377 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01054d0:	ba 00 85 08 00       	mov    $0x88500,%edx
f01054d5:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01054da:	e8 98 fe ff ff       	call   f0105377 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01054df:	c7 c0 04 80 27 f0    	mov    $0xf0278004,%eax
f01054e5:	8b 10                	mov    (%eax),%edx
f01054e7:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01054ed:	f6 c4 10             	test   $0x10,%ah
f01054f0:	75 f5                	jne    f01054e7 <lapic_init+0x126>
	lapicw(TPR, 0);
f01054f2:	ba 00 00 00 00       	mov    $0x0,%edx
f01054f7:	b8 20 00 00 00       	mov    $0x20,%eax
f01054fc:	e8 76 fe ff ff       	call   f0105377 <lapicw>
f0105501:	e9 d9 fe ff ff       	jmp    f01053df <lapic_init+0x1e>
		lapicw(PCINT, MASKED);
f0105506:	ba 00 00 01 00       	mov    $0x10000,%edx
f010550b:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105510:	e8 62 fe ff ff       	call   f0105377 <lapicw>
f0105515:	e9 6b ff ff ff       	jmp    f0105485 <lapic_init+0xc4>

f010551a <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010551a:	e8 53 b3 ff ff       	call   f0100872 <__x86.get_pc_thunk.ax>
f010551f:	05 bd e6 12 00       	add    $0x12e6bd,%eax
	if (lapic)
f0105524:	c7 c0 04 80 27 f0    	mov    $0xf0278004,%eax
f010552a:	83 38 00             	cmpl   $0x0,(%eax)
f010552d:	74 14                	je     f0105543 <lapic_eoi+0x29>
{
f010552f:	55                   	push   %ebp
f0105530:	89 e5                	mov    %esp,%ebp
		lapicw(EOI, 0);
f0105532:	ba 00 00 00 00       	mov    $0x0,%edx
f0105537:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010553c:	e8 36 fe ff ff       	call   f0105377 <lapicw>
}
f0105541:	5d                   	pop    %ebp
f0105542:	c3                   	ret    
f0105543:	f3 c3                	repz ret 

f0105545 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105545:	55                   	push   %ebp
f0105546:	89 e5                	mov    %esp,%ebp
f0105548:	56                   	push   %esi
f0105549:	53                   	push   %ebx
f010554a:	e8 14 f5 ff ff       	call   f0104a63 <__x86.get_pc_thunk.cx>
f010554f:	81 c1 8d e6 12 00    	add    $0x12e68d,%ecx
f0105555:	8b 75 08             	mov    0x8(%ebp),%esi
f0105558:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010555b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105560:	ba 70 00 00 00       	mov    $0x70,%edx
f0105565:	ee                   	out    %al,(%dx)
f0105566:	b8 0a 00 00 00       	mov    $0xa,%eax
f010556b:	ba 71 00 00 00       	mov    $0x71,%edx
f0105570:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0105571:	c7 c0 08 6f 23 f0    	mov    $0xf0236f08,%eax
f0105577:	83 38 00             	cmpl   $0x0,(%eax)
f010557a:	74 7e                	je     f01055fa <lapic_startap+0xb5>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f010557c:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105583:	00 00 
	wrv[1] = addr >> 4;
f0105585:	89 d8                	mov    %ebx,%eax
f0105587:	c1 e8 04             	shr    $0x4,%eax
f010558a:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105590:	c1 e6 18             	shl    $0x18,%esi
f0105593:	89 f2                	mov    %esi,%edx
f0105595:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010559a:	e8 d8 fd ff ff       	call   f0105377 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f010559f:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01055a4:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01055a9:	e8 c9 fd ff ff       	call   f0105377 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01055ae:	ba 00 85 00 00       	mov    $0x8500,%edx
f01055b3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01055b8:	e8 ba fd ff ff       	call   f0105377 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01055bd:	c1 eb 0c             	shr    $0xc,%ebx
f01055c0:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f01055c3:	89 f2                	mov    %esi,%edx
f01055c5:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01055ca:	e8 a8 fd ff ff       	call   f0105377 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01055cf:	89 da                	mov    %ebx,%edx
f01055d1:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01055d6:	e8 9c fd ff ff       	call   f0105377 <lapicw>
		lapicw(ICRHI, apicid << 24);
f01055db:	89 f2                	mov    %esi,%edx
f01055dd:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01055e2:	e8 90 fd ff ff       	call   f0105377 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01055e7:	89 da                	mov    %ebx,%edx
f01055e9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01055ee:	e8 84 fd ff ff       	call   f0105377 <lapicw>
		microdelay(200);
	}
}
f01055f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01055f6:	5b                   	pop    %ebx
f01055f7:	5e                   	pop    %esi
f01055f8:	5d                   	pop    %ebp
f01055f9:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01055fa:	68 67 04 00 00       	push   $0x467
f01055ff:	8d 81 28 1f ed ff    	lea    -0x12e0d8(%ecx),%eax
f0105605:	50                   	push   %eax
f0105606:	68 98 00 00 00       	push   $0x98
f010560b:	8d 81 28 36 ed ff    	lea    -0x12c9d8(%ecx),%eax
f0105611:	50                   	push   %eax
f0105612:	89 cb                	mov    %ecx,%ebx
f0105614:	e8 27 aa ff ff       	call   f0100040 <_panic>

f0105619 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105619:	55                   	push   %ebp
f010561a:	89 e5                	mov    %esp,%ebp
f010561c:	53                   	push   %ebx
f010561d:	e8 8f ac ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f0105622:	81 c3 ba e5 12 00    	add    $0x12e5ba,%ebx
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105628:	8b 55 08             	mov    0x8(%ebp),%edx
f010562b:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105631:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105636:	e8 3c fd ff ff       	call   f0105377 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010563b:	c7 c0 04 80 27 f0    	mov    $0xf0278004,%eax
f0105641:	8b 10                	mov    (%eax),%edx
f0105643:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105649:	f6 c4 10             	test   $0x10,%ah
f010564c:	75 f5                	jne    f0105643 <lapic_ipi+0x2a>
		;
}
f010564e:	5b                   	pop    %ebx
f010564f:	5d                   	pop    %ebp
f0105650:	c3                   	ret    

f0105651 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105651:	55                   	push   %ebp
f0105652:	89 e5                	mov    %esp,%ebp
f0105654:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105657:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010565d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105660:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105663:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f010566a:	5d                   	pop    %ebp
f010566b:	c3                   	ret    

f010566c <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010566c:	55                   	push   %ebp
f010566d:	89 e5                	mov    %esp,%ebp
f010566f:	57                   	push   %edi
f0105670:	56                   	push   %esi
f0105671:	53                   	push   %ebx
f0105672:	83 ec 0c             	sub    $0xc,%esp
f0105675:	e8 37 ac ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f010567a:	81 c3 62 e5 12 00    	add    $0x12e562,%ebx
f0105680:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0105683:	83 3e 00             	cmpl   $0x0,(%esi)
f0105686:	75 07                	jne    f010568f <spin_lock+0x23>
	asm volatile("lock; xchgl %0, %1"
f0105688:	ba 01 00 00 00       	mov    $0x1,%edx
f010568d:	eb 39                	jmp    f01056c8 <spin_lock+0x5c>
f010568f:	8b 7e 08             	mov    0x8(%esi),%edi
f0105692:	e8 04 fd ff ff       	call   f010539b <cpunum>
f0105697:	6b c0 74             	imul   $0x74,%eax,%eax
f010569a:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01056a0:	39 c7                	cmp    %eax,%edi
f01056a2:	75 e4                	jne    f0105688 <spin_lock+0x1c>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01056a4:	8b 76 04             	mov    0x4(%esi),%esi
f01056a7:	e8 ef fc ff ff       	call   f010539b <cpunum>
f01056ac:	83 ec 0c             	sub    $0xc,%esp
f01056af:	56                   	push   %esi
f01056b0:	50                   	push   %eax
f01056b1:	8d 83 38 36 ed ff    	lea    -0x12c9c8(%ebx),%eax
f01056b7:	50                   	push   %eax
f01056b8:	6a 41                	push   $0x41
f01056ba:	8d 83 9c 36 ed ff    	lea    -0x12c964(%ebx),%eax
f01056c0:	50                   	push   %eax
f01056c1:	e8 7a a9 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01056c6:	f3 90                	pause  
f01056c8:	89 d0                	mov    %edx,%eax
f01056ca:	f0 87 06             	lock xchg %eax,(%esi)
	while (xchg(&lk->locked, 1) != 0)
f01056cd:	85 c0                	test   %eax,%eax
f01056cf:	75 f5                	jne    f01056c6 <spin_lock+0x5a>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01056d1:	e8 c5 fc ff ff       	call   f010539b <cpunum>
f01056d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01056d9:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
f01056df:	89 46 08             	mov    %eax,0x8(%esi)
	get_caller_pcs(lk->pcs);
f01056e2:	83 c6 0c             	add    $0xc,%esi
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01056e5:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f01056e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01056ec:	eb 0b                	jmp    f01056f9 <spin_lock+0x8d>
		pcs[i] = ebp[1];          // saved %eip
f01056ee:	8b 4a 04             	mov    0x4(%edx),%ecx
f01056f1:	89 0c 86             	mov    %ecx,(%esi,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01056f4:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f01056f6:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01056f9:	83 f8 09             	cmp    $0x9,%eax
f01056fc:	7f 14                	jg     f0105712 <spin_lock+0xa6>
f01056fe:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105704:	77 e8                	ja     f01056ee <spin_lock+0x82>
f0105706:	eb 0a                	jmp    f0105712 <spin_lock+0xa6>
		pcs[i] = 0;
f0105708:	c7 04 86 00 00 00 00 	movl   $0x0,(%esi,%eax,4)
	for (; i < 10; i++)
f010570f:	83 c0 01             	add    $0x1,%eax
f0105712:	83 f8 09             	cmp    $0x9,%eax
f0105715:	7e f1                	jle    f0105708 <spin_lock+0x9c>
#endif
}
f0105717:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010571a:	5b                   	pop    %ebx
f010571b:	5e                   	pop    %esi
f010571c:	5f                   	pop    %edi
f010571d:	5d                   	pop    %ebp
f010571e:	c3                   	ret    

f010571f <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010571f:	55                   	push   %ebp
f0105720:	89 e5                	mov    %esp,%ebp
f0105722:	57                   	push   %edi
f0105723:	56                   	push   %esi
f0105724:	53                   	push   %ebx
f0105725:	83 ec 5c             	sub    $0x5c,%esp
f0105728:	e8 84 ab ff ff       	call   f01002b1 <__x86.get_pc_thunk.bx>
f010572d:	81 c3 af e4 12 00    	add    $0x12e4af,%ebx
f0105733:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0105736:	83 3e 00             	cmpl   $0x0,(%esi)
f0105739:	75 4b                	jne    f0105786 <spin_unlock+0x67>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010573b:	83 ec 04             	sub    $0x4,%esp
f010573e:	6a 28                	push   $0x28
f0105740:	8d 46 0c             	lea    0xc(%esi),%eax
f0105743:	50                   	push   %eax
f0105744:	8d 7d c0             	lea    -0x40(%ebp),%edi
f0105747:	57                   	push   %edi
f0105748:	e8 dc f5 ff ff       	call   f0104d29 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010574d:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105750:	0f b6 00             	movzbl (%eax),%eax
f0105753:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0105756:	8b 76 04             	mov    0x4(%esi),%esi
f0105759:	e8 3d fc ff ff       	call   f010539b <cpunum>
f010575e:	ff 75 a4             	pushl  -0x5c(%ebp)
f0105761:	56                   	push   %esi
f0105762:	50                   	push   %eax
f0105763:	8d 83 64 36 ed ff    	lea    -0x12c99c(%ebx),%eax
f0105769:	50                   	push   %eax
f010576a:	e8 90 dc ff ff       	call   f01033ff <cprintf>
f010576f:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105772:	89 45 a0             	mov    %eax,-0x60(%ebp)
f0105775:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105778:	8d 75 a8             	lea    -0x58(%ebp),%esi
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f010577b:	8d 83 c3 36 ed ff    	lea    -0x12c93d(%ebx),%eax
f0105781:	89 45 9c             	mov    %eax,-0x64(%ebp)
f0105784:	eb 65                	jmp    f01057eb <spin_unlock+0xcc>
	return lock->locked && lock->cpu == thiscpu;
f0105786:	8b 7e 08             	mov    0x8(%esi),%edi
f0105789:	e8 0d fc ff ff       	call   f010539b <cpunum>
f010578e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105791:	81 c0 20 70 23 f0    	add    $0xf0237020,%eax
	if (!holding(lk)) {
f0105797:	39 c7                	cmp    %eax,%edi
f0105799:	75 a0                	jne    f010573b <spin_unlock+0x1c>
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f010579b:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01057a2:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f01057a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01057ae:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f01057b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01057b4:	5b                   	pop    %ebx
f01057b5:	5e                   	pop    %esi
f01057b6:	5f                   	pop    %edi
f01057b7:	5d                   	pop    %ebp
f01057b8:	c3                   	ret    
					pcs[i] - info.eip_fn_addr);
f01057b9:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01057bc:	8b 00                	mov    (%eax),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01057be:	83 ec 04             	sub    $0x4,%esp
f01057c1:	89 c2                	mov    %eax,%edx
f01057c3:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01057c6:	52                   	push   %edx
f01057c7:	ff 75 b0             	pushl  -0x50(%ebp)
f01057ca:	ff 75 b4             	pushl  -0x4c(%ebp)
f01057cd:	ff 75 ac             	pushl  -0x54(%ebp)
f01057d0:	ff 75 a8             	pushl  -0x58(%ebp)
f01057d3:	50                   	push   %eax
f01057d4:	8d 83 ac 36 ed ff    	lea    -0x12c954(%ebx),%eax
f01057da:	50                   	push   %eax
f01057db:	e8 1f dc ff ff       	call   f01033ff <cprintf>
f01057e0:	83 c4 20             	add    $0x20,%esp
f01057e3:	83 c7 04             	add    $0x4,%edi
		for (i = 0; i < 10 && pcs[i]; i++) {
f01057e6:	3b 7d a0             	cmp    -0x60(%ebp),%edi
f01057e9:	74 2f                	je     f010581a <spin_unlock+0xfb>
f01057eb:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f01057ee:	8b 07                	mov    (%edi),%eax
f01057f0:	85 c0                	test   %eax,%eax
f01057f2:	74 26                	je     f010581a <spin_unlock+0xfb>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01057f4:	83 ec 08             	sub    $0x8,%esp
f01057f7:	56                   	push   %esi
f01057f8:	50                   	push   %eax
f01057f9:	e8 1f e9 ff ff       	call   f010411d <debuginfo_eip>
f01057fe:	83 c4 10             	add    $0x10,%esp
f0105801:	85 c0                	test   %eax,%eax
f0105803:	79 b4                	jns    f01057b9 <spin_unlock+0x9a>
				cprintf("  %08x\n", pcs[i]);
f0105805:	83 ec 08             	sub    $0x8,%esp
f0105808:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f010580b:	ff 30                	pushl  (%eax)
f010580d:	ff 75 9c             	pushl  -0x64(%ebp)
f0105810:	e8 ea db ff ff       	call   f01033ff <cprintf>
f0105815:	83 c4 10             	add    $0x10,%esp
f0105818:	eb c9                	jmp    f01057e3 <spin_unlock+0xc4>
		panic("spin_unlock");
f010581a:	83 ec 04             	sub    $0x4,%esp
f010581d:	8d 83 cb 36 ed ff    	lea    -0x12c935(%ebx),%eax
f0105823:	50                   	push   %eax
f0105824:	6a 67                	push   $0x67
f0105826:	8d 83 9c 36 ed ff    	lea    -0x12c964(%ebx),%eax
f010582c:	50                   	push   %eax
f010582d:	e8 0e a8 ff ff       	call   f0100040 <_panic>
f0105832:	66 90                	xchg   %ax,%ax
f0105834:	66 90                	xchg   %ax,%ax
f0105836:	66 90                	xchg   %ax,%ax
f0105838:	66 90                	xchg   %ax,%ax
f010583a:	66 90                	xchg   %ax,%ax
f010583c:	66 90                	xchg   %ax,%ax
f010583e:	66 90                	xchg   %ax,%ax

f0105840 <__udivdi3>:
f0105840:	55                   	push   %ebp
f0105841:	57                   	push   %edi
f0105842:	56                   	push   %esi
f0105843:	83 ec 0c             	sub    $0xc,%esp
f0105846:	8b 44 24 28          	mov    0x28(%esp),%eax
f010584a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f010584e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0105852:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0105856:	85 c0                	test   %eax,%eax
f0105858:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010585c:	89 ea                	mov    %ebp,%edx
f010585e:	89 0c 24             	mov    %ecx,(%esp)
f0105861:	75 2d                	jne    f0105890 <__udivdi3+0x50>
f0105863:	39 e9                	cmp    %ebp,%ecx
f0105865:	77 61                	ja     f01058c8 <__udivdi3+0x88>
f0105867:	85 c9                	test   %ecx,%ecx
f0105869:	89 ce                	mov    %ecx,%esi
f010586b:	75 0b                	jne    f0105878 <__udivdi3+0x38>
f010586d:	b8 01 00 00 00       	mov    $0x1,%eax
f0105872:	31 d2                	xor    %edx,%edx
f0105874:	f7 f1                	div    %ecx
f0105876:	89 c6                	mov    %eax,%esi
f0105878:	31 d2                	xor    %edx,%edx
f010587a:	89 e8                	mov    %ebp,%eax
f010587c:	f7 f6                	div    %esi
f010587e:	89 c5                	mov    %eax,%ebp
f0105880:	89 f8                	mov    %edi,%eax
f0105882:	f7 f6                	div    %esi
f0105884:	89 ea                	mov    %ebp,%edx
f0105886:	83 c4 0c             	add    $0xc,%esp
f0105889:	5e                   	pop    %esi
f010588a:	5f                   	pop    %edi
f010588b:	5d                   	pop    %ebp
f010588c:	c3                   	ret    
f010588d:	8d 76 00             	lea    0x0(%esi),%esi
f0105890:	39 e8                	cmp    %ebp,%eax
f0105892:	77 24                	ja     f01058b8 <__udivdi3+0x78>
f0105894:	0f bd e8             	bsr    %eax,%ebp
f0105897:	83 f5 1f             	xor    $0x1f,%ebp
f010589a:	75 3c                	jne    f01058d8 <__udivdi3+0x98>
f010589c:	8b 74 24 04          	mov    0x4(%esp),%esi
f01058a0:	39 34 24             	cmp    %esi,(%esp)
f01058a3:	0f 86 9f 00 00 00    	jbe    f0105948 <__udivdi3+0x108>
f01058a9:	39 d0                	cmp    %edx,%eax
f01058ab:	0f 82 97 00 00 00    	jb     f0105948 <__udivdi3+0x108>
f01058b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01058b8:	31 d2                	xor    %edx,%edx
f01058ba:	31 c0                	xor    %eax,%eax
f01058bc:	83 c4 0c             	add    $0xc,%esp
f01058bf:	5e                   	pop    %esi
f01058c0:	5f                   	pop    %edi
f01058c1:	5d                   	pop    %ebp
f01058c2:	c3                   	ret    
f01058c3:	90                   	nop
f01058c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01058c8:	89 f8                	mov    %edi,%eax
f01058ca:	f7 f1                	div    %ecx
f01058cc:	31 d2                	xor    %edx,%edx
f01058ce:	83 c4 0c             	add    $0xc,%esp
f01058d1:	5e                   	pop    %esi
f01058d2:	5f                   	pop    %edi
f01058d3:	5d                   	pop    %ebp
f01058d4:	c3                   	ret    
f01058d5:	8d 76 00             	lea    0x0(%esi),%esi
f01058d8:	89 e9                	mov    %ebp,%ecx
f01058da:	8b 3c 24             	mov    (%esp),%edi
f01058dd:	d3 e0                	shl    %cl,%eax
f01058df:	89 c6                	mov    %eax,%esi
f01058e1:	b8 20 00 00 00       	mov    $0x20,%eax
f01058e6:	29 e8                	sub    %ebp,%eax
f01058e8:	89 c1                	mov    %eax,%ecx
f01058ea:	d3 ef                	shr    %cl,%edi
f01058ec:	89 e9                	mov    %ebp,%ecx
f01058ee:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01058f2:	8b 3c 24             	mov    (%esp),%edi
f01058f5:	09 74 24 08          	or     %esi,0x8(%esp)
f01058f9:	89 d6                	mov    %edx,%esi
f01058fb:	d3 e7                	shl    %cl,%edi
f01058fd:	89 c1                	mov    %eax,%ecx
f01058ff:	89 3c 24             	mov    %edi,(%esp)
f0105902:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105906:	d3 ee                	shr    %cl,%esi
f0105908:	89 e9                	mov    %ebp,%ecx
f010590a:	d3 e2                	shl    %cl,%edx
f010590c:	89 c1                	mov    %eax,%ecx
f010590e:	d3 ef                	shr    %cl,%edi
f0105910:	09 d7                	or     %edx,%edi
f0105912:	89 f2                	mov    %esi,%edx
f0105914:	89 f8                	mov    %edi,%eax
f0105916:	f7 74 24 08          	divl   0x8(%esp)
f010591a:	89 d6                	mov    %edx,%esi
f010591c:	89 c7                	mov    %eax,%edi
f010591e:	f7 24 24             	mull   (%esp)
f0105921:	39 d6                	cmp    %edx,%esi
f0105923:	89 14 24             	mov    %edx,(%esp)
f0105926:	72 30                	jb     f0105958 <__udivdi3+0x118>
f0105928:	8b 54 24 04          	mov    0x4(%esp),%edx
f010592c:	89 e9                	mov    %ebp,%ecx
f010592e:	d3 e2                	shl    %cl,%edx
f0105930:	39 c2                	cmp    %eax,%edx
f0105932:	73 05                	jae    f0105939 <__udivdi3+0xf9>
f0105934:	3b 34 24             	cmp    (%esp),%esi
f0105937:	74 1f                	je     f0105958 <__udivdi3+0x118>
f0105939:	89 f8                	mov    %edi,%eax
f010593b:	31 d2                	xor    %edx,%edx
f010593d:	e9 7a ff ff ff       	jmp    f01058bc <__udivdi3+0x7c>
f0105942:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105948:	31 d2                	xor    %edx,%edx
f010594a:	b8 01 00 00 00       	mov    $0x1,%eax
f010594f:	e9 68 ff ff ff       	jmp    f01058bc <__udivdi3+0x7c>
f0105954:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105958:	8d 47 ff             	lea    -0x1(%edi),%eax
f010595b:	31 d2                	xor    %edx,%edx
f010595d:	83 c4 0c             	add    $0xc,%esp
f0105960:	5e                   	pop    %esi
f0105961:	5f                   	pop    %edi
f0105962:	5d                   	pop    %ebp
f0105963:	c3                   	ret    
f0105964:	66 90                	xchg   %ax,%ax
f0105966:	66 90                	xchg   %ax,%ax
f0105968:	66 90                	xchg   %ax,%ax
f010596a:	66 90                	xchg   %ax,%ax
f010596c:	66 90                	xchg   %ax,%ax
f010596e:	66 90                	xchg   %ax,%ax

f0105970 <__umoddi3>:
f0105970:	55                   	push   %ebp
f0105971:	57                   	push   %edi
f0105972:	56                   	push   %esi
f0105973:	83 ec 14             	sub    $0x14,%esp
f0105976:	8b 44 24 28          	mov    0x28(%esp),%eax
f010597a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f010597e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0105982:	89 c7                	mov    %eax,%edi
f0105984:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105988:	8b 44 24 30          	mov    0x30(%esp),%eax
f010598c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0105990:	89 34 24             	mov    %esi,(%esp)
f0105993:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105997:	85 c0                	test   %eax,%eax
f0105999:	89 c2                	mov    %eax,%edx
f010599b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010599f:	75 17                	jne    f01059b8 <__umoddi3+0x48>
f01059a1:	39 fe                	cmp    %edi,%esi
f01059a3:	76 4b                	jbe    f01059f0 <__umoddi3+0x80>
f01059a5:	89 c8                	mov    %ecx,%eax
f01059a7:	89 fa                	mov    %edi,%edx
f01059a9:	f7 f6                	div    %esi
f01059ab:	89 d0                	mov    %edx,%eax
f01059ad:	31 d2                	xor    %edx,%edx
f01059af:	83 c4 14             	add    $0x14,%esp
f01059b2:	5e                   	pop    %esi
f01059b3:	5f                   	pop    %edi
f01059b4:	5d                   	pop    %ebp
f01059b5:	c3                   	ret    
f01059b6:	66 90                	xchg   %ax,%ax
f01059b8:	39 f8                	cmp    %edi,%eax
f01059ba:	77 54                	ja     f0105a10 <__umoddi3+0xa0>
f01059bc:	0f bd e8             	bsr    %eax,%ebp
f01059bf:	83 f5 1f             	xor    $0x1f,%ebp
f01059c2:	75 5c                	jne    f0105a20 <__umoddi3+0xb0>
f01059c4:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01059c8:	39 3c 24             	cmp    %edi,(%esp)
f01059cb:	0f 87 e7 00 00 00    	ja     f0105ab8 <__umoddi3+0x148>
f01059d1:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01059d5:	29 f1                	sub    %esi,%ecx
f01059d7:	19 c7                	sbb    %eax,%edi
f01059d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01059dd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01059e1:	8b 44 24 08          	mov    0x8(%esp),%eax
f01059e5:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01059e9:	83 c4 14             	add    $0x14,%esp
f01059ec:	5e                   	pop    %esi
f01059ed:	5f                   	pop    %edi
f01059ee:	5d                   	pop    %ebp
f01059ef:	c3                   	ret    
f01059f0:	85 f6                	test   %esi,%esi
f01059f2:	89 f5                	mov    %esi,%ebp
f01059f4:	75 0b                	jne    f0105a01 <__umoddi3+0x91>
f01059f6:	b8 01 00 00 00       	mov    $0x1,%eax
f01059fb:	31 d2                	xor    %edx,%edx
f01059fd:	f7 f6                	div    %esi
f01059ff:	89 c5                	mov    %eax,%ebp
f0105a01:	8b 44 24 04          	mov    0x4(%esp),%eax
f0105a05:	31 d2                	xor    %edx,%edx
f0105a07:	f7 f5                	div    %ebp
f0105a09:	89 c8                	mov    %ecx,%eax
f0105a0b:	f7 f5                	div    %ebp
f0105a0d:	eb 9c                	jmp    f01059ab <__umoddi3+0x3b>
f0105a0f:	90                   	nop
f0105a10:	89 c8                	mov    %ecx,%eax
f0105a12:	89 fa                	mov    %edi,%edx
f0105a14:	83 c4 14             	add    $0x14,%esp
f0105a17:	5e                   	pop    %esi
f0105a18:	5f                   	pop    %edi
f0105a19:	5d                   	pop    %ebp
f0105a1a:	c3                   	ret    
f0105a1b:	90                   	nop
f0105a1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105a20:	8b 04 24             	mov    (%esp),%eax
f0105a23:	be 20 00 00 00       	mov    $0x20,%esi
f0105a28:	89 e9                	mov    %ebp,%ecx
f0105a2a:	29 ee                	sub    %ebp,%esi
f0105a2c:	d3 e2                	shl    %cl,%edx
f0105a2e:	89 f1                	mov    %esi,%ecx
f0105a30:	d3 e8                	shr    %cl,%eax
f0105a32:	89 e9                	mov    %ebp,%ecx
f0105a34:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a38:	8b 04 24             	mov    (%esp),%eax
f0105a3b:	09 54 24 04          	or     %edx,0x4(%esp)
f0105a3f:	89 fa                	mov    %edi,%edx
f0105a41:	d3 e0                	shl    %cl,%eax
f0105a43:	89 f1                	mov    %esi,%ecx
f0105a45:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105a49:	8b 44 24 10          	mov    0x10(%esp),%eax
f0105a4d:	d3 ea                	shr    %cl,%edx
f0105a4f:	89 e9                	mov    %ebp,%ecx
f0105a51:	d3 e7                	shl    %cl,%edi
f0105a53:	89 f1                	mov    %esi,%ecx
f0105a55:	d3 e8                	shr    %cl,%eax
f0105a57:	89 e9                	mov    %ebp,%ecx
f0105a59:	09 f8                	or     %edi,%eax
f0105a5b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0105a5f:	f7 74 24 04          	divl   0x4(%esp)
f0105a63:	d3 e7                	shl    %cl,%edi
f0105a65:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105a69:	89 d7                	mov    %edx,%edi
f0105a6b:	f7 64 24 08          	mull   0x8(%esp)
f0105a6f:	39 d7                	cmp    %edx,%edi
f0105a71:	89 c1                	mov    %eax,%ecx
f0105a73:	89 14 24             	mov    %edx,(%esp)
f0105a76:	72 2c                	jb     f0105aa4 <__umoddi3+0x134>
f0105a78:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0105a7c:	72 22                	jb     f0105aa0 <__umoddi3+0x130>
f0105a7e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0105a82:	29 c8                	sub    %ecx,%eax
f0105a84:	19 d7                	sbb    %edx,%edi
f0105a86:	89 e9                	mov    %ebp,%ecx
f0105a88:	89 fa                	mov    %edi,%edx
f0105a8a:	d3 e8                	shr    %cl,%eax
f0105a8c:	89 f1                	mov    %esi,%ecx
f0105a8e:	d3 e2                	shl    %cl,%edx
f0105a90:	89 e9                	mov    %ebp,%ecx
f0105a92:	d3 ef                	shr    %cl,%edi
f0105a94:	09 d0                	or     %edx,%eax
f0105a96:	89 fa                	mov    %edi,%edx
f0105a98:	83 c4 14             	add    $0x14,%esp
f0105a9b:	5e                   	pop    %esi
f0105a9c:	5f                   	pop    %edi
f0105a9d:	5d                   	pop    %ebp
f0105a9e:	c3                   	ret    
f0105a9f:	90                   	nop
f0105aa0:	39 d7                	cmp    %edx,%edi
f0105aa2:	75 da                	jne    f0105a7e <__umoddi3+0x10e>
f0105aa4:	8b 14 24             	mov    (%esp),%edx
f0105aa7:	89 c1                	mov    %eax,%ecx
f0105aa9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0105aad:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0105ab1:	eb cb                	jmp    f0105a7e <__umoddi3+0x10e>
f0105ab3:	90                   	nop
f0105ab4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105ab8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0105abc:	0f 82 0f ff ff ff    	jb     f01059d1 <__umoddi3+0x61>
f0105ac2:	e9 1a ff ff ff       	jmp    f01059e1 <__umoddi3+0x71>
