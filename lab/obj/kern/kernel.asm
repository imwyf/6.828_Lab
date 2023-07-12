
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
f0100015:	b8 00 f0 11 00       	mov    $0x11f000,%eax
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
f0100034:	bc 00 f0 11 f0       	mov    $0xf011f000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 6a 00 00 00       	call   f01000a8 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void _panic(const char *file, int line, const char *fmt, ...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	83 ec 10             	sub    $0x10,%esp
f0100048:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004b:	83 3d 80 7e 1e f0 00 	cmpl   $0x0,0xf01e7e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 7e 1e f0    	mov    %esi,0xf01e7e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 35 63 00 00       	call   f0106399 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 80 6a 10 f0 	movl   $0xf0106a80,(%esp)
f010007d:	e8 4b 3e 00 00       	call   f0103ecd <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 0c 3e 00 00       	call   f0103e9a <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 82 7c 10 f0 	movl   $0xf0107c82,(%esp)
f0100095:	e8 33 3e 00 00       	call   f0103ecd <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 2b 09 00 00       	call   f01009d1 <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <i386_init>:
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	53                   	push   %ebx
f01000ac:	83 ec 14             	sub    $0x14,%esp
	memset(edata, 0, end - edata);
f01000af:	b8 08 90 22 f0       	mov    $0xf0229008,%eax
f01000b4:	2d 00 70 1e f0       	sub    $0xf01e7000,%eax
f01000b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000c4:	00 
f01000c5:	c7 04 24 00 70 1e f0 	movl   $0xf01e7000,(%esp)
f01000cc:	e8 76 5c 00 00       	call   f0105d47 <memset>
	cons_init();
f01000d1:	e8 b9 05 00 00       	call   f010068f <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d6:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000dd:	00 
f01000de:	c7 04 24 ec 6a 10 f0 	movl   $0xf0106aec,(%esp)
f01000e5:	e8 e3 3d 00 00       	call   f0103ecd <cprintf>
	mem_init();
f01000ea:	e8 3a 14 00 00       	call   f0101529 <mem_init>
	env_init();
f01000ef:	e8 22 36 00 00       	call   f0103716 <env_init>
	trap_init();
f01000f4:	e8 82 3e 00 00       	call   f0103f7b <trap_init>
	mp_init();
f01000f9:	e8 8c 5f 00 00       	call   f010608a <mp_init>
	lapic_init();
f01000fe:	66 90                	xchg   %ax,%ax
f0100100:	e8 af 62 00 00       	call   f01063b4 <lapic_init>
	pic_init();
f0100105:	e8 f3 3c 00 00       	call   f0103dfd <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010010a:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100111:	e8 01 65 00 00       	call   f0106617 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100116:	83 3d 88 7e 1e f0 07 	cmpl   $0x7,0xf01e7e88
f010011d:	77 24                	ja     f0100143 <i386_init+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011f:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100126:	00 
f0100127:	c7 44 24 08 a4 6a 10 	movl   $0xf0106aa4,0x8(%esp)
f010012e:	f0 
f010012f:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
f0100136:	00 
f0100137:	c7 04 24 07 6b 10 f0 	movl   $0xf0106b07,(%esp)
f010013e:	e8 fd fe ff ff       	call   f0100040 <_panic>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100143:	b8 c2 5f 10 f0       	mov    $0xf0105fc2,%eax
f0100148:	2d 48 5f 10 f0       	sub    $0xf0105f48,%eax
f010014d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100151:	c7 44 24 04 48 5f 10 	movl   $0xf0105f48,0x4(%esp)
f0100158:	f0 
f0100159:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100160:	e8 2f 5c 00 00       	call   f0105d94 <memmove>
	for (c = cpus; c < cpus + ncpu; c++)
f0100165:	bb 20 80 1e f0       	mov    $0xf01e8020,%ebx
f010016a:	eb 4d                	jmp    f01001b9 <i386_init+0x111>
		if (c == cpus + cpunum()) // We've started already.
f010016c:	e8 28 62 00 00       	call   f0106399 <cpunum>
f0100171:	6b c0 74             	imul   $0x74,%eax,%eax
f0100174:	05 20 80 1e f0       	add    $0xf01e8020,%eax
f0100179:	39 c3                	cmp    %eax,%ebx
f010017b:	74 39                	je     f01001b6 <i386_init+0x10e>
f010017d:	89 d8                	mov    %ebx,%eax
f010017f:	2d 20 80 1e f0       	sub    $0xf01e8020,%eax
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100184:	c1 f8 02             	sar    $0x2,%eax
f0100187:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010018d:	c1 e0 0f             	shl    $0xf,%eax
f0100190:	8d 80 00 10 1f f0    	lea    -0xfe0f000(%eax),%eax
f0100196:	a3 84 7e 1e f0       	mov    %eax,0xf01e7e84
		lapic_startap(c->cpu_id, PADDR(code));
f010019b:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f01001a2:	00 
f01001a3:	0f b6 03             	movzbl (%ebx),%eax
f01001a6:	89 04 24             	mov    %eax,(%esp)
f01001a9:	e8 56 63 00 00       	call   f0106504 <lapic_startap>
		while (c->cpu_status != CPU_STARTED)
f01001ae:	8b 43 04             	mov    0x4(%ebx),%eax
f01001b1:	83 f8 01             	cmp    $0x1,%eax
f01001b4:	75 f8                	jne    f01001ae <i386_init+0x106>
	for (c = cpus; c < cpus + ncpu; c++)
f01001b6:	83 c3 74             	add    $0x74,%ebx
f01001b9:	6b 05 c4 83 1e f0 74 	imul   $0x74,0xf01e83c4,%eax
f01001c0:	05 20 80 1e f0       	add    $0xf01e8020,%eax
f01001c5:	39 c3                	cmp    %eax,%ebx
f01001c7:	72 a3                	jb     f010016c <i386_init+0xc4>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01001d0:	00 
f01001d1:	c7 04 24 d0 bf 18 f0 	movl   $0xf018bfd0,(%esp)
f01001d8:	e8 f9 36 00 00       	call   f01038d6 <env_create>
	kbd_intr();
f01001dd:	e8 51 04 00 00       	call   f0100633 <kbd_intr>
	sched_yield();
f01001e2:	e8 08 49 00 00       	call   f0104aef <sched_yield>

f01001e7 <mp_main>:
{
f01001e7:	55                   	push   %ebp
f01001e8:	89 e5                	mov    %esp,%ebp
f01001ea:	83 ec 18             	sub    $0x18,%esp
	lcr3(PADDR(kern_pgdir));
f01001ed:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01001f2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001f7:	77 20                	ja     f0100219 <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01001fd:	c7 44 24 08 c8 6a 10 	movl   $0xf0106ac8,0x8(%esp)
f0100204:	f0 
f0100205:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
f010020c:	00 
f010020d:	c7 04 24 07 6b 10 f0 	movl   $0xf0106b07,(%esp)
f0100214:	e8 27 fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100219:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010021e:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100221:	e8 73 61 00 00       	call   f0106399 <cpunum>
f0100226:	89 44 24 04          	mov    %eax,0x4(%esp)
f010022a:	c7 04 24 13 6b 10 f0 	movl   $0xf0106b13,(%esp)
f0100231:	e8 97 3c 00 00       	call   f0103ecd <cprintf>
	lapic_init();
f0100236:	e8 79 61 00 00       	call   f01063b4 <lapic_init>
	env_init_percpu();
f010023b:	e8 ac 34 00 00       	call   f01036ec <env_init_percpu>
	trap_init_percpu();
f0100240:	e8 ab 3c 00 00       	call   f0103ef0 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100245:	e8 4f 61 00 00       	call   f0106399 <cpunum>
f010024a:	6b d0 74             	imul   $0x74,%eax,%edx
f010024d:	81 c2 20 80 1e f0    	add    $0xf01e8020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100253:	b8 01 00 00 00       	mov    $0x1,%eax
f0100258:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010025c:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100263:	e8 af 63 00 00       	call   f0106617 <spin_lock>
	sched_yield();
f0100268:	e8 82 48 00 00       	call   f0104aef <sched_yield>

f010026d <_warn>:
}

/* like panic, but don't */
void _warn(const char *file, int line, const char *fmt, ...)
{
f010026d:	55                   	push   %ebp
f010026e:	89 e5                	mov    %esp,%ebp
f0100270:	53                   	push   %ebx
f0100271:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100274:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100277:	8b 45 0c             	mov    0xc(%ebp),%eax
f010027a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010027e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100281:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100285:	c7 04 24 29 6b 10 f0 	movl   $0xf0106b29,(%esp)
f010028c:	e8 3c 3c 00 00       	call   f0103ecd <cprintf>
	vcprintf(fmt, ap);
f0100291:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100295:	8b 45 10             	mov    0x10(%ebp),%eax
f0100298:	89 04 24             	mov    %eax,(%esp)
f010029b:	e8 fa 3b 00 00       	call   f0103e9a <vcprintf>
	cprintf("\n");
f01002a0:	c7 04 24 82 7c 10 f0 	movl   $0xf0107c82,(%esp)
f01002a7:	e8 21 3c 00 00       	call   f0103ecd <cprintf>
	va_end(ap);
}
f01002ac:	83 c4 14             	add    $0x14,%esp
f01002af:	5b                   	pop    %ebx
f01002b0:	5d                   	pop    %ebp
f01002b1:	c3                   	ret    
f01002b2:	66 90                	xchg   %ax,%ax
f01002b4:	66 90                	xchg   %ax,%ax
f01002b6:	66 90                	xchg   %ax,%ax
f01002b8:	66 90                	xchg   %ax,%ax
f01002ba:	66 90                	xchg   %ax,%ax
f01002bc:	66 90                	xchg   %ax,%ax
f01002be:	66 90                	xchg   %ax,%ax

f01002c0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002c0:	55                   	push   %ebp
f01002c1:	89 e5                	mov    %esp,%ebp
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002c3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002c8:	ec                   	in     (%dx),%al
	if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA))
f01002c9:	a8 01                	test   $0x1,%al
f01002cb:	74 08                	je     f01002d5 <serial_proc_data+0x15>
f01002cd:	b2 f8                	mov    $0xf8,%dl
f01002cf:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1 + COM_RX);
f01002d0:	0f b6 c0             	movzbl %al,%eax
f01002d3:	eb 05                	jmp    f01002da <serial_proc_data+0x1a>
		return -1;
f01002d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01002da:	5d                   	pop    %ebp
f01002db:	c3                   	ret    

f01002dc <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002dc:	55                   	push   %ebp
f01002dd:	89 e5                	mov    %esp,%ebp
f01002df:	53                   	push   %ebx
f01002e0:	83 ec 04             	sub    $0x4,%esp
f01002e3:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1)
f01002e5:	eb 2a                	jmp    f0100311 <cons_intr+0x35>
	{
		if (c == 0)
f01002e7:	85 d2                	test   %edx,%edx
f01002e9:	74 26                	je     f0100311 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01002eb:	a1 24 72 1e f0       	mov    0xf01e7224,%eax
f01002f0:	8d 48 01             	lea    0x1(%eax),%ecx
f01002f3:	89 0d 24 72 1e f0    	mov    %ecx,0xf01e7224
f01002f9:	88 90 20 70 1e f0    	mov    %dl,-0xfe18fe0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f01002ff:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100305:	75 0a                	jne    f0100311 <cons_intr+0x35>
			cons.wpos = 0;
f0100307:	c7 05 24 72 1e f0 00 	movl   $0x0,0xf01e7224
f010030e:	00 00 00 
	while ((c = (*proc)()) != -1)
f0100311:	ff d3                	call   *%ebx
f0100313:	89 c2                	mov    %eax,%edx
f0100315:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100318:	75 cd                	jne    f01002e7 <cons_intr+0xb>
	}
}
f010031a:	83 c4 04             	add    $0x4,%esp
f010031d:	5b                   	pop    %ebx
f010031e:	5d                   	pop    %ebp
f010031f:	c3                   	ret    

f0100320 <kbd_proc_data>:
f0100320:	ba 64 00 00 00       	mov    $0x64,%edx
f0100325:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100326:	a8 01                	test   $0x1,%al
f0100328:	0f 84 f7 00 00 00    	je     f0100425 <kbd_proc_data+0x105>
	if (stat & KBS_TERR)
f010032e:	a8 20                	test   $0x20,%al
f0100330:	0f 85 f5 00 00 00    	jne    f010042b <kbd_proc_data+0x10b>
f0100336:	b2 60                	mov    $0x60,%dl
f0100338:	ec                   	in     (%dx),%al
f0100339:	89 c2                	mov    %eax,%edx
	if (data == 0xE0)
f010033b:	3c e0                	cmp    $0xe0,%al
f010033d:	75 0d                	jne    f010034c <kbd_proc_data+0x2c>
		shift |= E0ESC;
f010033f:	83 0d 00 70 1e f0 40 	orl    $0x40,0xf01e7000
		return 0;
f0100346:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010034b:	c3                   	ret    
{
f010034c:	55                   	push   %ebp
f010034d:	89 e5                	mov    %esp,%ebp
f010034f:	53                   	push   %ebx
f0100350:	83 ec 14             	sub    $0x14,%esp
	else if (data & 0x80)
f0100353:	84 c0                	test   %al,%al
f0100355:	79 37                	jns    f010038e <kbd_proc_data+0x6e>
		data = (shift & E0ESC ? data : data & 0x7F);
f0100357:	8b 0d 00 70 1e f0    	mov    0xf01e7000,%ecx
f010035d:	89 cb                	mov    %ecx,%ebx
f010035f:	83 e3 40             	and    $0x40,%ebx
f0100362:	83 e0 7f             	and    $0x7f,%eax
f0100365:	85 db                	test   %ebx,%ebx
f0100367:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010036a:	0f b6 d2             	movzbl %dl,%edx
f010036d:	0f b6 82 a0 6c 10 f0 	movzbl -0xfef9360(%edx),%eax
f0100374:	83 c8 40             	or     $0x40,%eax
f0100377:	0f b6 c0             	movzbl %al,%eax
f010037a:	f7 d0                	not    %eax
f010037c:	21 c1                	and    %eax,%ecx
f010037e:	89 0d 00 70 1e f0    	mov    %ecx,0xf01e7000
		return 0;
f0100384:	b8 00 00 00 00       	mov    $0x0,%eax
f0100389:	e9 a3 00 00 00       	jmp    f0100431 <kbd_proc_data+0x111>
	else if (shift & E0ESC)
f010038e:	8b 0d 00 70 1e f0    	mov    0xf01e7000,%ecx
f0100394:	f6 c1 40             	test   $0x40,%cl
f0100397:	74 0e                	je     f01003a7 <kbd_proc_data+0x87>
		data |= 0x80;
f0100399:	83 c8 80             	or     $0xffffff80,%eax
f010039c:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010039e:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003a1:	89 0d 00 70 1e f0    	mov    %ecx,0xf01e7000
	shift |= shiftcode[data];
f01003a7:	0f b6 d2             	movzbl %dl,%edx
f01003aa:	0f b6 82 a0 6c 10 f0 	movzbl -0xfef9360(%edx),%eax
f01003b1:	0b 05 00 70 1e f0    	or     0xf01e7000,%eax
	shift ^= togglecode[data];
f01003b7:	0f b6 8a a0 6b 10 f0 	movzbl -0xfef9460(%edx),%ecx
f01003be:	31 c8                	xor    %ecx,%eax
f01003c0:	a3 00 70 1e f0       	mov    %eax,0xf01e7000
	c = charcode[shift & (CTL | SHIFT)][data];
f01003c5:	89 c1                	mov    %eax,%ecx
f01003c7:	83 e1 03             	and    $0x3,%ecx
f01003ca:	8b 0c 8d 80 6b 10 f0 	mov    -0xfef9480(,%ecx,4),%ecx
f01003d1:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003d5:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK)
f01003d8:	a8 08                	test   $0x8,%al
f01003da:	74 1b                	je     f01003f7 <kbd_proc_data+0xd7>
		if ('a' <= c && c <= 'z')
f01003dc:	89 da                	mov    %ebx,%edx
f01003de:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003e1:	83 f9 19             	cmp    $0x19,%ecx
f01003e4:	77 05                	ja     f01003eb <kbd_proc_data+0xcb>
			c += 'A' - 'a';
f01003e6:	83 eb 20             	sub    $0x20,%ebx
f01003e9:	eb 0c                	jmp    f01003f7 <kbd_proc_data+0xd7>
		else if ('A' <= c && c <= 'Z')
f01003eb:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003ee:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003f1:	83 fa 19             	cmp    $0x19,%edx
f01003f4:	0f 46 d9             	cmovbe %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL)
f01003f7:	f7 d0                	not    %eax
f01003f9:	89 c2                	mov    %eax,%edx
	return c;
f01003fb:	89 d8                	mov    %ebx,%eax
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL)
f01003fd:	f6 c2 06             	test   $0x6,%dl
f0100400:	75 2f                	jne    f0100431 <kbd_proc_data+0x111>
f0100402:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100408:	75 27                	jne    f0100431 <kbd_proc_data+0x111>
		cprintf("Rebooting!\n");
f010040a:	c7 04 24 43 6b 10 f0 	movl   $0xf0106b43,(%esp)
f0100411:	e8 b7 3a 00 00       	call   f0103ecd <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100416:	ba 92 00 00 00       	mov    $0x92,%edx
f010041b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100420:	ee                   	out    %al,(%dx)
	return c;
f0100421:	89 d8                	mov    %ebx,%eax
f0100423:	eb 0c                	jmp    f0100431 <kbd_proc_data+0x111>
		return -1;
f0100425:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010042a:	c3                   	ret    
		return -1;
f010042b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100430:	c3                   	ret    
}
f0100431:	83 c4 14             	add    $0x14,%esp
f0100434:	5b                   	pop    %ebx
f0100435:	5d                   	pop    %ebp
f0100436:	c3                   	ret    

f0100437 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100437:	55                   	push   %ebp
f0100438:	89 e5                	mov    %esp,%ebp
f010043a:	57                   	push   %edi
f010043b:	56                   	push   %esi
f010043c:	53                   	push   %ebx
f010043d:	83 ec 1c             	sub    $0x1c,%esp
f0100440:	89 c7                	mov    %eax,%edi
f0100442:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100447:	be fd 03 00 00       	mov    $0x3fd,%esi
f010044c:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100451:	eb 06                	jmp    f0100459 <cons_putc+0x22>
f0100453:	89 ca                	mov    %ecx,%edx
f0100455:	ec                   	in     (%dx),%al
f0100456:	ec                   	in     (%dx),%al
f0100457:	ec                   	in     (%dx),%al
f0100458:	ec                   	in     (%dx),%al
f0100459:	89 f2                	mov    %esi,%edx
f010045b:	ec                   	in     (%dx),%al
	for (i = 0;
f010045c:	a8 20                	test   $0x20,%al
f010045e:	75 05                	jne    f0100465 <cons_putc+0x2e>
		 !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100460:	83 eb 01             	sub    $0x1,%ebx
f0100463:	75 ee                	jne    f0100453 <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f0100465:	89 f8                	mov    %edi,%eax
f0100467:	0f b6 c0             	movzbl %al,%eax
f010046a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010046d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100472:	ee                   	out    %al,(%dx)
f0100473:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100478:	be 79 03 00 00       	mov    $0x379,%esi
f010047d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100482:	eb 06                	jmp    f010048a <cons_putc+0x53>
f0100484:	89 ca                	mov    %ecx,%edx
f0100486:	ec                   	in     (%dx),%al
f0100487:	ec                   	in     (%dx),%al
f0100488:	ec                   	in     (%dx),%al
f0100489:	ec                   	in     (%dx),%al
f010048a:	89 f2                	mov    %esi,%edx
f010048c:	ec                   	in     (%dx),%al
	for (i = 0; !(inb(0x378 + 1) & 0x80) && i < 12800; i++)
f010048d:	84 c0                	test   %al,%al
f010048f:	78 05                	js     f0100496 <cons_putc+0x5f>
f0100491:	83 eb 01             	sub    $0x1,%ebx
f0100494:	75 ee                	jne    f0100484 <cons_putc+0x4d>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100496:	ba 78 03 00 00       	mov    $0x378,%edx
f010049b:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f010049f:	ee                   	out    %al,(%dx)
f01004a0:	b2 7a                	mov    $0x7a,%dl
f01004a2:	b8 0d 00 00 00       	mov    $0xd,%eax
f01004a7:	ee                   	out    %al,(%dx)
f01004a8:	b8 08 00 00 00       	mov    $0x8,%eax
f01004ad:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01004ae:	89 fa                	mov    %edi,%edx
f01004b0:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01004b6:	89 f8                	mov    %edi,%eax
f01004b8:	80 cc 07             	or     $0x7,%ah
f01004bb:	85 d2                	test   %edx,%edx
f01004bd:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff)
f01004c0:	89 f8                	mov    %edi,%eax
f01004c2:	0f b6 c0             	movzbl %al,%eax
f01004c5:	83 f8 09             	cmp    $0x9,%eax
f01004c8:	74 78                	je     f0100542 <cons_putc+0x10b>
f01004ca:	83 f8 09             	cmp    $0x9,%eax
f01004cd:	7f 0a                	jg     f01004d9 <cons_putc+0xa2>
f01004cf:	83 f8 08             	cmp    $0x8,%eax
f01004d2:	74 18                	je     f01004ec <cons_putc+0xb5>
f01004d4:	e9 9d 00 00 00       	jmp    f0100576 <cons_putc+0x13f>
f01004d9:	83 f8 0a             	cmp    $0xa,%eax
f01004dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01004e0:	74 3a                	je     f010051c <cons_putc+0xe5>
f01004e2:	83 f8 0d             	cmp    $0xd,%eax
f01004e5:	74 3d                	je     f0100524 <cons_putc+0xed>
f01004e7:	e9 8a 00 00 00       	jmp    f0100576 <cons_putc+0x13f>
		if (crt_pos > 0)
f01004ec:	0f b7 05 28 72 1e f0 	movzwl 0xf01e7228,%eax
f01004f3:	66 85 c0             	test   %ax,%ax
f01004f6:	0f 84 e5 00 00 00    	je     f01005e1 <cons_putc+0x1aa>
			crt_pos--;
f01004fc:	83 e8 01             	sub    $0x1,%eax
f01004ff:	66 a3 28 72 1e f0    	mov    %ax,0xf01e7228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100505:	0f b7 c0             	movzwl %ax,%eax
f0100508:	66 81 e7 00 ff       	and    $0xff00,%di
f010050d:	83 cf 20             	or     $0x20,%edi
f0100510:	8b 15 2c 72 1e f0    	mov    0xf01e722c,%edx
f0100516:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010051a:	eb 78                	jmp    f0100594 <cons_putc+0x15d>
		crt_pos += CRT_COLS;
f010051c:	66 83 05 28 72 1e f0 	addw   $0x50,0xf01e7228
f0100523:	50 
		crt_pos -= (crt_pos % CRT_COLS);
f0100524:	0f b7 05 28 72 1e f0 	movzwl 0xf01e7228,%eax
f010052b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100531:	c1 e8 16             	shr    $0x16,%eax
f0100534:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100537:	c1 e0 04             	shl    $0x4,%eax
f010053a:	66 a3 28 72 1e f0    	mov    %ax,0xf01e7228
f0100540:	eb 52                	jmp    f0100594 <cons_putc+0x15d>
		cons_putc(' ');
f0100542:	b8 20 00 00 00       	mov    $0x20,%eax
f0100547:	e8 eb fe ff ff       	call   f0100437 <cons_putc>
		cons_putc(' ');
f010054c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100551:	e8 e1 fe ff ff       	call   f0100437 <cons_putc>
		cons_putc(' ');
f0100556:	b8 20 00 00 00       	mov    $0x20,%eax
f010055b:	e8 d7 fe ff ff       	call   f0100437 <cons_putc>
		cons_putc(' ');
f0100560:	b8 20 00 00 00       	mov    $0x20,%eax
f0100565:	e8 cd fe ff ff       	call   f0100437 <cons_putc>
		cons_putc(' ');
f010056a:	b8 20 00 00 00       	mov    $0x20,%eax
f010056f:	e8 c3 fe ff ff       	call   f0100437 <cons_putc>
f0100574:	eb 1e                	jmp    f0100594 <cons_putc+0x15d>
		crt_buf[crt_pos++] = c; /* write the character */
f0100576:	0f b7 05 28 72 1e f0 	movzwl 0xf01e7228,%eax
f010057d:	8d 50 01             	lea    0x1(%eax),%edx
f0100580:	66 89 15 28 72 1e f0 	mov    %dx,0xf01e7228
f0100587:	0f b7 c0             	movzwl %ax,%eax
f010058a:	8b 15 2c 72 1e f0    	mov    0xf01e722c,%edx
f0100590:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
	if (crt_pos >= CRT_SIZE) // 当输出字符超过终端范围
f0100594:	66 81 3d 28 72 1e f0 	cmpw   $0x7cf,0xf01e7228
f010059b:	cf 07 
f010059d:	76 42                	jbe    f01005e1 <cons_putc+0x1aa>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t)); // 已有字符往上移动一行
f010059f:	a1 2c 72 1e f0       	mov    0xf01e722c,%eax
f01005a4:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01005ab:	00 
f01005ac:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005b2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005b6:	89 04 24             	mov    %eax,(%esp)
f01005b9:	e8 d6 57 00 00       	call   f0105d94 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01005be:	8b 15 2c 72 1e f0    	mov    0xf01e722c,%edx
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)								// 清零最后一行
f01005c4:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01005c9:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)								// 清零最后一行
f01005cf:	83 c0 01             	add    $0x1,%eax
f01005d2:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005d7:	75 f0                	jne    f01005c9 <cons_putc+0x192>
		crt_pos -= CRT_COLS; // 索引向前移动，即从最后一行的开头写入
f01005d9:	66 83 2d 28 72 1e f0 	subw   $0x50,0xf01e7228
f01005e0:	50 
	outb(addr_6845, 14);
f01005e1:	8b 0d 30 72 1e f0    	mov    0xf01e7230,%ecx
f01005e7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005ec:	89 ca                	mov    %ecx,%edx
f01005ee:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005ef:	0f b7 1d 28 72 1e f0 	movzwl 0xf01e7228,%ebx
f01005f6:	8d 71 01             	lea    0x1(%ecx),%esi
f01005f9:	89 d8                	mov    %ebx,%eax
f01005fb:	66 c1 e8 08          	shr    $0x8,%ax
f01005ff:	89 f2                	mov    %esi,%edx
f0100601:	ee                   	out    %al,(%dx)
f0100602:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100607:	89 ca                	mov    %ecx,%edx
f0100609:	ee                   	out    %al,(%dx)
f010060a:	89 d8                	mov    %ebx,%eax
f010060c:	89 f2                	mov    %esi,%edx
f010060e:	ee                   	out    %al,(%dx)
	serial_putc(c); // 向串口输出
	lpt_putc(c);
	cga_putc(c); // 向控制台输出字符
}
f010060f:	83 c4 1c             	add    $0x1c,%esp
f0100612:	5b                   	pop    %ebx
f0100613:	5e                   	pop    %esi
f0100614:	5f                   	pop    %edi
f0100615:	5d                   	pop    %ebp
f0100616:	c3                   	ret    

f0100617 <serial_intr>:
	if (serial_exists)
f0100617:	80 3d 34 72 1e f0 00 	cmpb   $0x0,0xf01e7234
f010061e:	74 11                	je     f0100631 <serial_intr+0x1a>
{
f0100620:	55                   	push   %ebp
f0100621:	89 e5                	mov    %esp,%ebp
f0100623:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100626:	b8 c0 02 10 f0       	mov    $0xf01002c0,%eax
f010062b:	e8 ac fc ff ff       	call   f01002dc <cons_intr>
}
f0100630:	c9                   	leave  
f0100631:	f3 c3                	repz ret 

f0100633 <kbd_intr>:
{
f0100633:	55                   	push   %ebp
f0100634:	89 e5                	mov    %esp,%ebp
f0100636:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100639:	b8 20 03 10 f0       	mov    $0xf0100320,%eax
f010063e:	e8 99 fc ff ff       	call   f01002dc <cons_intr>
}
f0100643:	c9                   	leave  
f0100644:	c3                   	ret    

f0100645 <cons_getc>:
{
f0100645:	55                   	push   %ebp
f0100646:	89 e5                	mov    %esp,%ebp
f0100648:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f010064b:	e8 c7 ff ff ff       	call   f0100617 <serial_intr>
	kbd_intr();
f0100650:	e8 de ff ff ff       	call   f0100633 <kbd_intr>
	if (cons.rpos != cons.wpos)
f0100655:	a1 20 72 1e f0       	mov    0xf01e7220,%eax
f010065a:	3b 05 24 72 1e f0    	cmp    0xf01e7224,%eax
f0100660:	74 26                	je     f0100688 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100662:	8d 50 01             	lea    0x1(%eax),%edx
f0100665:	89 15 20 72 1e f0    	mov    %edx,0xf01e7220
f010066b:	0f b6 88 20 70 1e f0 	movzbl -0xfe18fe0(%eax),%ecx
		return c;
f0100672:	89 c8                	mov    %ecx,%eax
		if (cons.rpos == CONSBUFSIZE)
f0100674:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010067a:	75 11                	jne    f010068d <cons_getc+0x48>
			cons.rpos = 0;
f010067c:	c7 05 20 72 1e f0 00 	movl   $0x0,0xf01e7220
f0100683:	00 00 00 
f0100686:	eb 05                	jmp    f010068d <cons_getc+0x48>
	return 0;
f0100688:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010068d:	c9                   	leave  
f010068e:	c3                   	ret    

f010068f <cons_init>:

// initialize the console devices
void cons_init(void)
{
f010068f:	55                   	push   %ebp
f0100690:	89 e5                	mov    %esp,%ebp
f0100692:	57                   	push   %edi
f0100693:	56                   	push   %esi
f0100694:	53                   	push   %ebx
f0100695:	83 ec 1c             	sub    $0x1c,%esp
	was = *cp;
f0100698:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t)0xA55A;
f010069f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006a6:	5a a5 
	if (*cp != 0xA55A)
f01006a8:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006af:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006b3:	74 11                	je     f01006c6 <cons_init+0x37>
		addr_6845 = MONO_BASE;
f01006b5:	c7 05 30 72 1e f0 b4 	movl   $0x3b4,0xf01e7230
f01006bc:	03 00 00 
		cp = (uint16_t *)(KERNBASE + MONO_BUF);
f01006bf:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f01006c4:	eb 16                	jmp    f01006dc <cons_init+0x4d>
		*cp = was;
f01006c6:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006cd:	c7 05 30 72 1e f0 d4 	movl   $0x3d4,0xf01e7230
f01006d4:	03 00 00 
	cp = (uint16_t *)(KERNBASE + CGA_BUF);
f01006d7:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
	outb(addr_6845, 14);
f01006dc:	8b 0d 30 72 1e f0    	mov    0xf01e7230,%ecx
f01006e2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006e7:	89 ca                	mov    %ecx,%edx
f01006e9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006ea:	8d 59 01             	lea    0x1(%ecx),%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ed:	89 da                	mov    %ebx,%edx
f01006ef:	ec                   	in     (%dx),%al
f01006f0:	0f b6 f0             	movzbl %al,%esi
f01006f3:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006f6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006fb:	89 ca                	mov    %ecx,%edx
f01006fd:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006fe:	89 da                	mov    %ebx,%edx
f0100700:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t *)cp;
f0100701:	89 3d 2c 72 1e f0    	mov    %edi,0xf01e722c
	pos |= inb(addr_6845 + 1);
f0100707:	0f b6 d8             	movzbl %al,%ebx
f010070a:	09 de                	or     %ebx,%esi
	crt_pos = pos;
f010070c:	66 89 35 28 72 1e f0 	mov    %si,0xf01e7228
	kbd_intr();
f0100713:	e8 1b ff ff ff       	call   f0100633 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_KBD));
f0100718:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f010071f:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100724:	89 04 24             	mov    %eax,(%esp)
f0100727:	e8 62 36 00 00       	call   f0103d8e <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010072c:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100731:	b8 00 00 00 00       	mov    $0x0,%eax
f0100736:	89 f2                	mov    %esi,%edx
f0100738:	ee                   	out    %al,(%dx)
f0100739:	b2 fb                	mov    $0xfb,%dl
f010073b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100740:	ee                   	out    %al,(%dx)
f0100741:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100746:	b8 0c 00 00 00       	mov    $0xc,%eax
f010074b:	89 da                	mov    %ebx,%edx
f010074d:	ee                   	out    %al,(%dx)
f010074e:	b2 f9                	mov    $0xf9,%dl
f0100750:	b8 00 00 00 00       	mov    $0x0,%eax
f0100755:	ee                   	out    %al,(%dx)
f0100756:	b2 fb                	mov    $0xfb,%dl
f0100758:	b8 03 00 00 00       	mov    $0x3,%eax
f010075d:	ee                   	out    %al,(%dx)
f010075e:	b2 fc                	mov    $0xfc,%dl
f0100760:	b8 00 00 00 00       	mov    $0x0,%eax
f0100765:	ee                   	out    %al,(%dx)
f0100766:	b2 f9                	mov    $0xf9,%dl
f0100768:	b8 01 00 00 00       	mov    $0x1,%eax
f010076d:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010076e:	b2 fd                	mov    $0xfd,%dl
f0100770:	ec                   	in     (%dx),%al
	serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
f0100771:	3c ff                	cmp    $0xff,%al
f0100773:	0f 95 c1             	setne  %cl
f0100776:	88 0d 34 72 1e f0    	mov    %cl,0xf01e7234
f010077c:	89 f2                	mov    %esi,%edx
f010077e:	ec                   	in     (%dx),%al
f010077f:	89 da                	mov    %ebx,%edx
f0100781:	ec                   	in     (%dx),%al
	if (serial_exists)
f0100782:	84 c9                	test   %cl,%cl
f0100784:	74 1d                	je     f01007a3 <cons_init+0x114>
		irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_SERIAL));
f0100786:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f010078d:	25 ef ff 00 00       	and    $0xffef,%eax
f0100792:	89 04 24             	mov    %eax,(%esp)
f0100795:	e8 f4 35 00 00       	call   f0103d8e <irq_setmask_8259A>
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010079a:	80 3d 34 72 1e f0 00 	cmpb   $0x0,0xf01e7234
f01007a1:	75 0c                	jne    f01007af <cons_init+0x120>
		cprintf("Serial port does not exist!\n");
f01007a3:	c7 04 24 4f 6b 10 f0 	movl   $0xf0106b4f,(%esp)
f01007aa:	e8 1e 37 00 00       	call   f0103ecd <cprintf>
}
f01007af:	83 c4 1c             	add    $0x1c,%esp
f01007b2:	5b                   	pop    %ebx
f01007b3:	5e                   	pop    %esi
f01007b4:	5f                   	pop    %edi
f01007b5:	5d                   	pop    %ebp
f01007b6:	c3                   	ret    

f01007b7 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void cputchar(int c)
{
f01007b7:	55                   	push   %ebp
f01007b8:	89 e5                	mov    %esp,%ebp
f01007ba:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01007c0:	e8 72 fc ff ff       	call   f0100437 <cons_putc>
}
f01007c5:	c9                   	leave  
f01007c6:	c3                   	ret    

f01007c7 <getchar>:

int getchar(void)
{
f01007c7:	55                   	push   %ebp
f01007c8:	89 e5                	mov    %esp,%ebp
f01007ca:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007cd:	e8 73 fe ff ff       	call   f0100645 <cons_getc>
f01007d2:	85 c0                	test   %eax,%eax
f01007d4:	74 f7                	je     f01007cd <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007d6:	c9                   	leave  
f01007d7:	c3                   	ret    

f01007d8 <iscons>:

int iscons(int fdnum)
{
f01007d8:	55                   	push   %ebp
f01007d9:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007db:	b8 01 00 00 00       	mov    $0x1,%eax
f01007e0:	5d                   	pop    %ebp
f01007e1:	c3                   	ret    
f01007e2:	66 90                	xchg   %ax,%ax
f01007e4:	66 90                	xchg   %ax,%ax
f01007e6:	66 90                	xchg   %ax,%ax
f01007e8:	66 90                	xchg   %ax,%ax
f01007ea:	66 90                	xchg   %ax,%ax
f01007ec:	66 90                	xchg   %ax,%ax
f01007ee:	66 90                	xchg   %ax,%ax

f01007f0 <mon_help>:
};

/***** Implementations of basic kernel monitor commands *****/

int mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007f0:	55                   	push   %ebp
f01007f1:	89 e5                	mov    %esp,%ebp
f01007f3:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007f6:	c7 44 24 08 a0 6d 10 	movl   $0xf0106da0,0x8(%esp)
f01007fd:	f0 
f01007fe:	c7 44 24 04 be 6d 10 	movl   $0xf0106dbe,0x4(%esp)
f0100805:	f0 
f0100806:	c7 04 24 c3 6d 10 f0 	movl   $0xf0106dc3,(%esp)
f010080d:	e8 bb 36 00 00       	call   f0103ecd <cprintf>
f0100812:	c7 44 24 08 68 6e 10 	movl   $0xf0106e68,0x8(%esp)
f0100819:	f0 
f010081a:	c7 44 24 04 cc 6d 10 	movl   $0xf0106dcc,0x4(%esp)
f0100821:	f0 
f0100822:	c7 04 24 c3 6d 10 f0 	movl   $0xf0106dc3,(%esp)
f0100829:	e8 9f 36 00 00       	call   f0103ecd <cprintf>
f010082e:	c7 44 24 08 d5 6d 10 	movl   $0xf0106dd5,0x8(%esp)
f0100835:	f0 
f0100836:	c7 44 24 04 db 6d 10 	movl   $0xf0106ddb,0x4(%esp)
f010083d:	f0 
f010083e:	c7 04 24 c3 6d 10 f0 	movl   $0xf0106dc3,(%esp)
f0100845:	e8 83 36 00 00       	call   f0103ecd <cprintf>
	return 0;
}
f010084a:	b8 00 00 00 00       	mov    $0x0,%eax
f010084f:	c9                   	leave  
f0100850:	c3                   	ret    

f0100851 <mon_kerninfo>:

int mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100851:	55                   	push   %ebp
f0100852:	89 e5                	mov    %esp,%ebp
f0100854:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100857:	c7 04 24 e5 6d 10 f0 	movl   $0xf0106de5,(%esp)
f010085e:	e8 6a 36 00 00       	call   f0103ecd <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100863:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010086a:	00 
f010086b:	c7 04 24 90 6e 10 f0 	movl   $0xf0106e90,(%esp)
f0100872:	e8 56 36 00 00       	call   f0103ecd <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100877:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010087e:	00 
f010087f:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100886:	f0 
f0100887:	c7 04 24 b8 6e 10 f0 	movl   $0xf0106eb8,(%esp)
f010088e:	e8 3a 36 00 00       	call   f0103ecd <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100893:	c7 44 24 08 67 6a 10 	movl   $0x106a67,0x8(%esp)
f010089a:	00 
f010089b:	c7 44 24 04 67 6a 10 	movl   $0xf0106a67,0x4(%esp)
f01008a2:	f0 
f01008a3:	c7 04 24 dc 6e 10 f0 	movl   $0xf0106edc,(%esp)
f01008aa:	e8 1e 36 00 00       	call   f0103ecd <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01008af:	c7 44 24 08 00 70 1e 	movl   $0x1e7000,0x8(%esp)
f01008b6:	00 
f01008b7:	c7 44 24 04 00 70 1e 	movl   $0xf01e7000,0x4(%esp)
f01008be:	f0 
f01008bf:	c7 04 24 00 6f 10 f0 	movl   $0xf0106f00,(%esp)
f01008c6:	e8 02 36 00 00       	call   f0103ecd <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008cb:	c7 44 24 08 08 90 22 	movl   $0x229008,0x8(%esp)
f01008d2:	00 
f01008d3:	c7 44 24 04 08 90 22 	movl   $0xf0229008,0x4(%esp)
f01008da:	f0 
f01008db:	c7 04 24 24 6f 10 f0 	movl   $0xf0106f24,(%esp)
f01008e2:	e8 e6 35 00 00       	call   f0103ecd <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
			ROUNDUP(end - entry, 1024) / 1024);
f01008e7:	b8 07 94 22 f0       	mov    $0xf0229407,%eax
f01008ec:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01008f1:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008f6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008fc:	85 c0                	test   %eax,%eax
f01008fe:	0f 48 c2             	cmovs  %edx,%eax
f0100901:	c1 f8 0a             	sar    $0xa,%eax
f0100904:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100908:	c7 04 24 48 6f 10 f0 	movl   $0xf0106f48,(%esp)
f010090f:	e8 b9 35 00 00       	call   f0103ecd <cprintf>
	return 0;
}
f0100914:	b8 00 00 00 00       	mov    $0x0,%eax
f0100919:	c9                   	leave  
f010091a:	c3                   	ret    

f010091b <mon_backtrace>:

int mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010091b:	55                   	push   %ebp
f010091c:	89 e5                	mov    %esp,%ebp
f010091e:	57                   	push   %edi
f010091f:	56                   	push   %esi
f0100920:	53                   	push   %ebx
f0100921:	83 ec 4c             	sub    $0x4c,%esp
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100924:	89 e8                	mov    %ebp,%eax
	// 被调用的函数(mon_backtrace)开始时，首先完成了push %ebp，mov %esp, %ebp
	// 注1：push时，先减%esp在存储内容
	// 注2：栈向下生长，用+1来访问前面的内容
	// Your code here.

	int *ebp = (int *)read_ebp(); // 读取本函数%ebp的值，转化为指针，作为地址使用
f0100926:	89 c7                	mov    %eax,%edi
	int eip = ebp[1];			  // 堆栈上存储的第一个东西就是返回地址，因此用偏移量1来访问
f0100928:	8b 40 04             	mov    0x4(%eax),%eax
f010092b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	while (1)					  // trace整个stack
	{
		// 打印%ebp和%eip
		cprintf("ebp %x, eip %x, args ", ebp, eip);
f010092e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100931:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100935:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100939:	c7 04 24 fe 6d 10 f0 	movl   $0xf0106dfe,(%esp)
f0100940:	e8 88 35 00 00       	call   f0103ecd <cprintf>
		int *args = ebp + 2;		 // 从偏移量2开始存储的是上个函数的参数
f0100945:	8d 5f 08             	lea    0x8(%edi),%ebx
f0100948:	8d 77 1c             	lea    0x1c(%edi),%esi
		for (int i = 0; i < 5; ++i)	 // 练习要求打印5个参数
			cprintf("%x ", args[i]); // 输出参数，注：args[i]和args+i是一样的效果
f010094b:	8b 03                	mov    (%ebx),%eax
f010094d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100951:	c7 04 24 14 6e 10 f0 	movl   $0xf0106e14,(%esp)
f0100958:	e8 70 35 00 00       	call   f0103ecd <cprintf>
f010095d:	83 c3 04             	add    $0x4,%ebx
		for (int i = 0; i < 5; ++i)	 // 练习要求打印5个参数
f0100960:	39 f3                	cmp    %esi,%ebx
f0100962:	75 e7                	jne    f010094b <mon_backtrace+0x30>
		cprintf("\n");
f0100964:	c7 04 24 82 7c 10 f0 	movl   $0xf0107c82,(%esp)
f010096b:	e8 5d 35 00 00       	call   f0103ecd <cprintf>

		// 显示每个%eip对应的函数名、源文件名和行号
		struct Eipdebuginfo info;
		if (!debuginfo_eip(eip, &info)) // 读取debug信息，找到信息，则debuginfo_eip返回0
f0100970:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100973:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100977:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010097a:	89 34 24             	mov    %esi,(%esp)
f010097d:	e8 6a 48 00 00       	call   f01051ec <debuginfo_eip>
f0100982:	85 c0                	test   %eax,%eax
f0100984:	75 3e                	jne    f01009c4 <mon_backtrace+0xa9>
			cprintf("%s: %d: %.*s+%d\n",
f0100986:	89 f0                	mov    %esi,%eax
f0100988:	2b 45 e0             	sub    -0x20(%ebp),%eax
f010098b:	89 44 24 14          	mov    %eax,0x14(%esp)
f010098f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100992:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100996:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100999:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010099d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01009a0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009a4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01009a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009ab:	c7 04 24 18 6e 10 f0 	movl   $0xf0106e18,(%esp)
f01009b2:	e8 16 35 00 00       	call   f0103ecd <cprintf>
					info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, eip - info.eip_fn_addr);
		else // 找不到信息，即到达stack的顶部
			break;

		// 更新指针
		ebp = (int *)*ebp; // *ebp得到压进堆栈的上一个函数的%ebp
f01009b7:	8b 3f                	mov    (%edi),%edi
		eip = ebp[1];
f01009b9:	8b 47 04             	mov    0x4(%edi),%eax
f01009bc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	}
f01009bf:	e9 6a ff ff ff       	jmp    f010092e <mon_backtrace+0x13>
	return 0;
}
f01009c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01009c9:	83 c4 4c             	add    $0x4c,%esp
f01009cc:	5b                   	pop    %ebx
f01009cd:	5e                   	pop    %esi
f01009ce:	5f                   	pop    %edi
f01009cf:	5d                   	pop    %ebp
f01009d0:	c3                   	ret    

f01009d1 <monitor>:
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void monitor(struct Trapframe *tf)
{
f01009d1:	55                   	push   %ebp
f01009d2:	89 e5                	mov    %esp,%ebp
f01009d4:	57                   	push   %edi
f01009d5:	56                   	push   %esi
f01009d6:	53                   	push   %ebx
f01009d7:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009da:	c7 04 24 74 6f 10 f0 	movl   $0xf0106f74,(%esp)
f01009e1:	e8 e7 34 00 00       	call   f0103ecd <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009e6:	c7 04 24 98 6f 10 f0 	movl   $0xf0106f98,(%esp)
f01009ed:	e8 db 34 00 00       	call   f0103ecd <cprintf>

	if (tf != NULL)
f01009f2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009f6:	74 0b                	je     f0100a03 <monitor+0x32>
		print_trapframe(tf);
f01009f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01009fb:	89 04 24             	mov    %eax,(%esp)
f01009fe:	e8 61 3a 00 00       	call   f0104464 <print_trapframe>
	while (1)
	{
		buf = readline("K> ");
f0100a03:	c7 04 24 29 6e 10 f0 	movl   $0xf0106e29,(%esp)
f0100a0a:	e8 d1 50 00 00       	call   f0105ae0 <readline>
f0100a0f:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100a11:	85 c0                	test   %eax,%eax
f0100a13:	74 ee                	je     f0100a03 <monitor+0x32>
	argv[argc] = 0;
f0100a15:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a1c:	be 00 00 00 00       	mov    $0x0,%esi
f0100a21:	eb 0a                	jmp    f0100a2d <monitor+0x5c>
			*buf++ = 0;
f0100a23:	c6 03 00             	movb   $0x0,(%ebx)
f0100a26:	89 f7                	mov    %esi,%edi
f0100a28:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a2b:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100a2d:	0f b6 03             	movzbl (%ebx),%eax
f0100a30:	84 c0                	test   %al,%al
f0100a32:	74 63                	je     f0100a97 <monitor+0xc6>
f0100a34:	0f be c0             	movsbl %al,%eax
f0100a37:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a3b:	c7 04 24 2d 6e 10 f0 	movl   $0xf0106e2d,(%esp)
f0100a42:	e8 c3 52 00 00       	call   f0105d0a <strchr>
f0100a47:	85 c0                	test   %eax,%eax
f0100a49:	75 d8                	jne    f0100a23 <monitor+0x52>
		if (*buf == 0)
f0100a4b:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a4e:	74 47                	je     f0100a97 <monitor+0xc6>
		if (argc == MAXARGS - 1)
f0100a50:	83 fe 0f             	cmp    $0xf,%esi
f0100a53:	75 16                	jne    f0100a6b <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a55:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100a5c:	00 
f0100a5d:	c7 04 24 32 6e 10 f0 	movl   $0xf0106e32,(%esp)
f0100a64:	e8 64 34 00 00       	call   f0103ecd <cprintf>
f0100a69:	eb 98                	jmp    f0100a03 <monitor+0x32>
		argv[argc++] = buf;
f0100a6b:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a6e:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a72:	eb 03                	jmp    f0100a77 <monitor+0xa6>
			buf++;
f0100a74:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a77:	0f b6 03             	movzbl (%ebx),%eax
f0100a7a:	84 c0                	test   %al,%al
f0100a7c:	74 ad                	je     f0100a2b <monitor+0x5a>
f0100a7e:	0f be c0             	movsbl %al,%eax
f0100a81:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a85:	c7 04 24 2d 6e 10 f0 	movl   $0xf0106e2d,(%esp)
f0100a8c:	e8 79 52 00 00       	call   f0105d0a <strchr>
f0100a91:	85 c0                	test   %eax,%eax
f0100a93:	74 df                	je     f0100a74 <monitor+0xa3>
f0100a95:	eb 94                	jmp    f0100a2b <monitor+0x5a>
	argv[argc] = 0;
f0100a97:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a9e:	00 
	if (argc == 0)
f0100a9f:	85 f6                	test   %esi,%esi
f0100aa1:	0f 84 5c ff ff ff    	je     f0100a03 <monitor+0x32>
f0100aa7:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100aac:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		if (strcmp(argv[0], commands[i].name) == 0)
f0100aaf:	8b 04 85 c0 6f 10 f0 	mov    -0xfef9040(,%eax,4),%eax
f0100ab6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aba:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100abd:	89 04 24             	mov    %eax,(%esp)
f0100ac0:	e8 e7 51 00 00       	call   f0105cac <strcmp>
f0100ac5:	85 c0                	test   %eax,%eax
f0100ac7:	75 24                	jne    f0100aed <monitor+0x11c>
			return commands[i].func(argc, argv, tf);
f0100ac9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100acc:	8b 55 08             	mov    0x8(%ebp),%edx
f0100acf:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100ad3:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100ad6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100ada:	89 34 24             	mov    %esi,(%esp)
f0100add:	ff 14 85 c8 6f 10 f0 	call   *-0xfef9038(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100ae4:	85 c0                	test   %eax,%eax
f0100ae6:	78 25                	js     f0100b0d <monitor+0x13c>
f0100ae8:	e9 16 ff ff ff       	jmp    f0100a03 <monitor+0x32>
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f0100aed:	83 c3 01             	add    $0x1,%ebx
f0100af0:	83 fb 03             	cmp    $0x3,%ebx
f0100af3:	75 b7                	jne    f0100aac <monitor+0xdb>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100af5:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100af8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100afc:	c7 04 24 4f 6e 10 f0 	movl   $0xf0106e4f,(%esp)
f0100b03:	e8 c5 33 00 00       	call   f0103ecd <cprintf>
f0100b08:	e9 f6 fe ff ff       	jmp    f0100a03 <monitor+0x32>
				break;
	}
}
f0100b0d:	83 c4 5c             	add    $0x5c,%esp
f0100b10:	5b                   	pop    %ebx
f0100b11:	5e                   	pop    %esi
f0100b12:	5f                   	pop    %edi
f0100b13:	5d                   	pop    %ebp
f0100b14:	c3                   	ret    
f0100b15:	66 90                	xchg   %ax,%ax
f0100b17:	66 90                	xchg   %ax,%ax
f0100b19:	66 90                	xchg   %ax,%ax
f0100b1b:	66 90                	xchg   %ax,%ax
f0100b1d:	66 90                	xchg   %ax,%ax
f0100b1f:	90                   	nop

f0100b20 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100b20:	55                   	push   %ebp
f0100b21:	89 e5                	mov    %esp,%ebp
f0100b23:	56                   	push   %esi
f0100b24:	53                   	push   %ebx
f0100b25:	83 ec 10             	sub    $0x10,%esp
f0100b28:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b2a:	89 04 24             	mov    %eax,(%esp)
f0100b2d:	e8 32 32 00 00       	call   f0103d64 <mc146818_read>
f0100b32:	89 c6                	mov    %eax,%esi
f0100b34:	83 c3 01             	add    $0x1,%ebx
f0100b37:	89 1c 24             	mov    %ebx,(%esp)
f0100b3a:	e8 25 32 00 00       	call   f0103d64 <mc146818_read>
f0100b3f:	c1 e0 08             	shl    $0x8,%eax
f0100b42:	09 f0                	or     %esi,%eax
}
f0100b44:	83 c4 10             	add    $0x10,%esp
f0100b47:	5b                   	pop    %ebx
f0100b48:	5e                   	pop    %esi
f0100b49:	5d                   	pop    %ebp
f0100b4a:	c3                   	ret    

f0100b4b <boot_alloc>:
boot_alloc(uint32_t n)
{
	static char *nextfree; // virtual address of next byte of free memory，static意味着nextfree不会随着函数返回被重置，是全局变量
	char *result;

	if (!nextfree) // nextfree初始化，只有第一次运行会执行
f0100b4b:	83 3d 38 72 1e f0 00 	cmpl   $0x0,0xf01e7238
f0100b52:	75 11                	jne    f0100b65 <boot_alloc+0x1a>
	{
		extern char end[]; // linker会获取内核代码的最后一个字节的位置，将end指向这个地址，因此end指向内核代码结尾

		nextfree = ROUNDUP((char *)end, PGSIZE); // 内核使用的第一块内存必须远离内核代码结尾
f0100b54:	ba 07 a0 22 f0       	mov    $0xf022a007,%edx
f0100b59:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b5f:	89 15 38 72 1e f0    	mov    %edx,0xf01e7238
		 * 假设end是4097，ROUNDUP(end, PGSIZE)得到end=4096*2，这样才能容纳4097
		 */
	}

	// LAB 2: Your code here.
	if (n == 0) // 不分配内存，直接返回
f0100b65:	85 c0                	test   %eax,%eax
f0100b67:	75 06                	jne    f0100b6f <boot_alloc+0x24>
	{
		return nextfree;
f0100b69:	a1 38 72 1e f0       	mov    0xf01e7238,%eax
f0100b6e:	c3                   	ret    
	}

	// n是无符号数，不考虑<0情形
	result = nextfree;				// 将更新前的nextfree赋给result
f0100b6f:	8b 0d 38 72 1e f0    	mov    0xf01e7238,%ecx
	nextfree += ROUNDUP(n, PGSIZE); // +=:在原来的基础上再分配
f0100b75:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100b7b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b81:	01 ca                	add    %ecx,%edx
f0100b83:	89 15 38 72 1e f0    	mov    %edx,0xf01e7238

	// 如果内存不足，boot_alloc应该会死机
	if (nextfree > (char *)0xf0400000) // >4MB
f0100b89:	81 fa 00 00 40 f0    	cmp    $0xf0400000,%edx
f0100b8f:	76 22                	jbe    f0100bb3 <boot_alloc+0x68>
{
f0100b91:	55                   	push   %ebp
f0100b92:	89 e5                	mov    %esp,%ebp
f0100b94:	83 ec 18             	sub    $0x18,%esp
	{
		panic("out of memory(4MB) : boot_alloc() in pmap.c \n"); // 调用预先定义的assert
f0100b97:	c7 44 24 08 e4 6f 10 	movl   $0xf0106fe4,0x8(%esp)
f0100b9e:	f0 
f0100b9f:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
f0100ba6:	00 
f0100ba7:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0100bae:	e8 8d f4 ff ff       	call   f0100040 <_panic>
		nextfree = result;										 // 分配失败，回调nextfree
		return NULL;
	}
	return result;
f0100bb3:	89 c8                	mov    %ecx,%eax
}
f0100bb5:	c3                   	ret    

f0100bb6 <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bb6:	2b 05 90 7e 1e f0    	sub    0xf01e7e90,%eax
f0100bbc:	c1 f8 03             	sar    $0x3,%eax
f0100bbf:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100bc2:	89 c2                	mov    %eax,%edx
f0100bc4:	c1 ea 0c             	shr    $0xc,%edx
f0100bc7:	3b 15 88 7e 1e f0    	cmp    0xf01e7e88,%edx
f0100bcd:	72 26                	jb     f0100bf5 <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100bcf:	55                   	push   %ebp
f0100bd0:	89 e5                	mov    %esp,%ebp
f0100bd2:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bd5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bd9:	c7 44 24 08 a4 6a 10 	movl   $0xf0106aa4,0x8(%esp)
f0100be0:	f0 
f0100be1:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100be8:	00 
f0100be9:	c7 04 24 05 7a 10 f0 	movl   $0xf0107a05,(%esp)
f0100bf0:	e8 4b f4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100bf5:	2d 00 00 00 10       	sub    $0x10000000,%eax
	return KADDR(page2pa(pp));
}
f0100bfa:	c3                   	ret    

f0100bfb <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100bfb:	89 d1                	mov    %edx,%ecx
f0100bfd:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100c00:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100c03:	a8 01                	test   $0x1,%al
f0100c05:	74 5d                	je     f0100c64 <check_va2pa+0x69>
		return ~0;
	p = (pte_t *)KADDR(PTE_ADDR(*pgdir));
f0100c07:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100c0c:	89 c1                	mov    %eax,%ecx
f0100c0e:	c1 e9 0c             	shr    $0xc,%ecx
f0100c11:	3b 0d 88 7e 1e f0    	cmp    0xf01e7e88,%ecx
f0100c17:	72 26                	jb     f0100c3f <check_va2pa+0x44>
{
f0100c19:	55                   	push   %ebp
f0100c1a:	89 e5                	mov    %esp,%ebp
f0100c1c:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c23:	c7 44 24 08 a4 6a 10 	movl   $0xf0106aa4,0x8(%esp)
f0100c2a:	f0 
f0100c2b:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0100c32:	00 
f0100c33:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0100c3a:	e8 01 f4 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100c3f:	c1 ea 0c             	shr    $0xc,%edx
f0100c42:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100c48:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100c4f:	89 c2                	mov    %eax,%edx
f0100c51:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100c54:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c59:	85 d2                	test   %edx,%edx
f0100c5b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100c60:	0f 44 c2             	cmove  %edx,%eax
f0100c63:	c3                   	ret    
		return ~0;
f0100c64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100c69:	c3                   	ret    

f0100c6a <check_page_free_list>:
{
f0100c6a:	55                   	push   %ebp
f0100c6b:	89 e5                	mov    %esp,%ebp
f0100c6d:	57                   	push   %edi
f0100c6e:	56                   	push   %esi
f0100c6f:	53                   	push   %ebx
f0100c70:	83 ec 4c             	sub    $0x4c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c73:	84 c0                	test   %al,%al
f0100c75:	0f 85 3f 03 00 00    	jne    f0100fba <check_page_free_list+0x350>
f0100c7b:	e9 4c 03 00 00       	jmp    f0100fcc <check_page_free_list+0x362>
		panic("'page_free_list' is a null pointer!");
f0100c80:	c7 44 24 08 14 70 10 	movl   $0xf0107014,0x8(%esp)
f0100c87:	f0 
f0100c88:	c7 44 24 04 4e 02 00 	movl   $0x24e,0x4(%esp)
f0100c8f:	00 
f0100c90:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0100c97:	e8 a4 f3 ff ff       	call   f0100040 <_panic>
		struct PageInfo **tp[2] = {&pp1, &pp2};
f0100c9c:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100c9f:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100ca2:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ca5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100ca8:	89 c2                	mov    %eax,%edx
f0100caa:	2b 15 90 7e 1e f0    	sub    0xf01e7e90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100cb0:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100cb6:	0f 95 c2             	setne  %dl
f0100cb9:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100cbc:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100cc0:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100cc2:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link)
f0100cc6:	8b 00                	mov    (%eax),%eax
f0100cc8:	85 c0                	test   %eax,%eax
f0100cca:	75 dc                	jne    f0100ca8 <check_page_free_list+0x3e>
		*tp[1] = 0;
f0100ccc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ccf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100cd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cd8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100cdb:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100cdd:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ce0:	a3 40 72 1e f0       	mov    %eax,0xf01e7240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ce5:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100cea:	8b 1d 40 72 1e f0    	mov    0xf01e7240,%ebx
f0100cf0:	eb 63                	jmp    f0100d55 <check_page_free_list+0xeb>
f0100cf2:	89 d8                	mov    %ebx,%eax
f0100cf4:	2b 05 90 7e 1e f0    	sub    0xf01e7e90,%eax
f0100cfa:	c1 f8 03             	sar    $0x3,%eax
f0100cfd:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100d00:	89 c2                	mov    %eax,%edx
f0100d02:	c1 ea 16             	shr    $0x16,%edx
f0100d05:	39 f2                	cmp    %esi,%edx
f0100d07:	73 4a                	jae    f0100d53 <check_page_free_list+0xe9>
	if (PGNUM(pa) >= npages)
f0100d09:	89 c2                	mov    %eax,%edx
f0100d0b:	c1 ea 0c             	shr    $0xc,%edx
f0100d0e:	3b 15 88 7e 1e f0    	cmp    0xf01e7e88,%edx
f0100d14:	72 20                	jb     f0100d36 <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d16:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d1a:	c7 44 24 08 a4 6a 10 	movl   $0xf0106aa4,0x8(%esp)
f0100d21:	f0 
f0100d22:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100d29:	00 
f0100d2a:	c7 04 24 05 7a 10 f0 	movl   $0xf0107a05,(%esp)
f0100d31:	e8 0a f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100d36:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100d3d:	00 
f0100d3e:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100d45:	00 
	return (void *)(pa + KERNBASE);
f0100d46:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d4b:	89 04 24             	mov    %eax,(%esp)
f0100d4e:	e8 f4 4f 00 00       	call   f0105d47 <memset>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d53:	8b 1b                	mov    (%ebx),%ebx
f0100d55:	85 db                	test   %ebx,%ebx
f0100d57:	75 99                	jne    f0100cf2 <check_page_free_list+0x88>
	first_free_page = (char *)boot_alloc(0);
f0100d59:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d5e:	e8 e8 fd ff ff       	call   f0100b4b <boot_alloc>
f0100d63:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d66:	8b 15 40 72 1e f0    	mov    0xf01e7240,%edx
		assert(pp >= pages);
f0100d6c:	8b 0d 90 7e 1e f0    	mov    0xf01e7e90,%ecx
		assert(pp < pages + npages);
f0100d72:	a1 88 7e 1e f0       	mov    0xf01e7e88,%eax
f0100d77:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100d7a:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100d7d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0100d80:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100d83:	bf 00 00 00 00       	mov    $0x0,%edi
f0100d88:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d8b:	e9 c4 01 00 00       	jmp    f0100f54 <check_page_free_list+0x2ea>
		assert(pp >= pages);
f0100d90:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100d93:	73 24                	jae    f0100db9 <check_page_free_list+0x14f>
f0100d95:	c7 44 24 0c 13 7a 10 	movl   $0xf0107a13,0xc(%esp)
f0100d9c:	f0 
f0100d9d:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0100da4:	f0 
f0100da5:	c7 44 24 04 6b 02 00 	movl   $0x26b,0x4(%esp)
f0100dac:	00 
f0100dad:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0100db4:	e8 87 f2 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100db9:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100dbc:	72 24                	jb     f0100de2 <check_page_free_list+0x178>
f0100dbe:	c7 44 24 0c 34 7a 10 	movl   $0xf0107a34,0xc(%esp)
f0100dc5:	f0 
f0100dc6:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0100dcd:	f0 
f0100dce:	c7 44 24 04 6c 02 00 	movl   $0x26c,0x4(%esp)
f0100dd5:	00 
f0100dd6:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0100ddd:	e8 5e f2 ff ff       	call   f0100040 <_panic>
		assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0100de2:	89 d0                	mov    %edx,%eax
f0100de4:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0100de7:	a8 07                	test   $0x7,%al
f0100de9:	74 24                	je     f0100e0f <check_page_free_list+0x1a5>
f0100deb:	c7 44 24 0c 38 70 10 	movl   $0xf0107038,0xc(%esp)
f0100df2:	f0 
f0100df3:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0100dfa:	f0 
f0100dfb:	c7 44 24 04 6d 02 00 	movl   $0x26d,0x4(%esp)
f0100e02:	00 
f0100e03:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0100e0a:	e8 31 f2 ff ff       	call   f0100040 <_panic>
	return (pp - pages) << PGSHIFT;
f0100e0f:	c1 f8 03             	sar    $0x3,%eax
f0100e12:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100e15:	85 c0                	test   %eax,%eax
f0100e17:	75 24                	jne    f0100e3d <check_page_free_list+0x1d3>
f0100e19:	c7 44 24 0c 48 7a 10 	movl   $0xf0107a48,0xc(%esp)
f0100e20:	f0 
f0100e21:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0100e28:	f0 
f0100e29:	c7 44 24 04 70 02 00 	movl   $0x270,0x4(%esp)
f0100e30:	00 
f0100e31:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0100e38:	e8 03 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e3d:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e42:	75 24                	jne    f0100e68 <check_page_free_list+0x1fe>
f0100e44:	c7 44 24 0c 59 7a 10 	movl   $0xf0107a59,0xc(%esp)
f0100e4b:	f0 
f0100e4c:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0100e53:	f0 
f0100e54:	c7 44 24 04 71 02 00 	movl   $0x271,0x4(%esp)
f0100e5b:	00 
f0100e5c:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0100e63:	e8 d8 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e68:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100e6d:	75 24                	jne    f0100e93 <check_page_free_list+0x229>
f0100e6f:	c7 44 24 0c 68 70 10 	movl   $0xf0107068,0xc(%esp)
f0100e76:	f0 
f0100e77:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0100e7e:	f0 
f0100e7f:	c7 44 24 04 72 02 00 	movl   $0x272,0x4(%esp)
f0100e86:	00 
f0100e87:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0100e8e:	e8 ad f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e93:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e98:	75 24                	jne    f0100ebe <check_page_free_list+0x254>
f0100e9a:	c7 44 24 0c 72 7a 10 	movl   $0xf0107a72,0xc(%esp)
f0100ea1:	f0 
f0100ea2:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0100ea9:	f0 
f0100eaa:	c7 44 24 04 73 02 00 	movl   $0x273,0x4(%esp)
f0100eb1:	00 
f0100eb2:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0100eb9:	e8 82 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f0100ebe:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ec3:	0f 86 2a 01 00 00    	jbe    f0100ff3 <check_page_free_list+0x389>
	if (PGNUM(pa) >= npages)
f0100ec9:	89 c1                	mov    %eax,%ecx
f0100ecb:	c1 e9 0c             	shr    $0xc,%ecx
f0100ece:	39 4d c4             	cmp    %ecx,-0x3c(%ebp)
f0100ed1:	77 20                	ja     f0100ef3 <check_page_free_list+0x289>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ed3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ed7:	c7 44 24 08 a4 6a 10 	movl   $0xf0106aa4,0x8(%esp)
f0100ede:	f0 
f0100edf:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100ee6:	00 
f0100ee7:	c7 04 24 05 7a 10 f0 	movl   $0xf0107a05,(%esp)
f0100eee:	e8 4d f1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100ef3:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f0100ef9:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100efc:	0f 86 e1 00 00 00    	jbe    f0100fe3 <check_page_free_list+0x379>
f0100f02:	c7 44 24 0c 8c 70 10 	movl   $0xf010708c,0xc(%esp)
f0100f09:	f0 
f0100f0a:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0100f11:	f0 
f0100f12:	c7 44 24 04 74 02 00 	movl   $0x274,0x4(%esp)
f0100f19:	00 
f0100f1a:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0100f21:	e8 1a f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100f26:	c7 44 24 0c 8c 7a 10 	movl   $0xf0107a8c,0xc(%esp)
f0100f2d:	f0 
f0100f2e:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0100f35:	f0 
f0100f36:	c7 44 24 04 76 02 00 	movl   $0x276,0x4(%esp)
f0100f3d:	00 
f0100f3e:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0100f45:	e8 f6 f0 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100f4a:	83 c3 01             	add    $0x1,%ebx
f0100f4d:	eb 03                	jmp    f0100f52 <check_page_free_list+0x2e8>
			++nfree_extmem;
f0100f4f:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f52:	8b 12                	mov    (%edx),%edx
f0100f54:	85 d2                	test   %edx,%edx
f0100f56:	0f 85 34 fe ff ff    	jne    f0100d90 <check_page_free_list+0x126>
	assert(nfree_basemem > 0);
f0100f5c:	85 db                	test   %ebx,%ebx
f0100f5e:	7f 24                	jg     f0100f84 <check_page_free_list+0x31a>
f0100f60:	c7 44 24 0c a9 7a 10 	movl   $0xf0107aa9,0xc(%esp)
f0100f67:	f0 
f0100f68:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0100f6f:	f0 
f0100f70:	c7 44 24 04 7e 02 00 	movl   $0x27e,0x4(%esp)
f0100f77:	00 
f0100f78:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0100f7f:	e8 bc f0 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100f84:	85 ff                	test   %edi,%edi
f0100f86:	7f 24                	jg     f0100fac <check_page_free_list+0x342>
f0100f88:	c7 44 24 0c bb 7a 10 	movl   $0xf0107abb,0xc(%esp)
f0100f8f:	f0 
f0100f90:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0100f97:	f0 
f0100f98:	c7 44 24 04 7f 02 00 	movl   $0x27f,0x4(%esp)
f0100f9f:	00 
f0100fa0:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0100fa7:	e8 94 f0 ff ff       	call   f0100040 <_panic>
	cprintf("check_page_free_list() succeeded!\n");
f0100fac:	c7 04 24 d0 70 10 f0 	movl   $0xf01070d0,(%esp)
f0100fb3:	e8 15 2f 00 00       	call   f0103ecd <cprintf>
f0100fb8:	eb 4b                	jmp    f0101005 <check_page_free_list+0x39b>
	if (!page_free_list)
f0100fba:	a1 40 72 1e f0       	mov    0xf01e7240,%eax
f0100fbf:	85 c0                	test   %eax,%eax
f0100fc1:	0f 85 d5 fc ff ff    	jne    f0100c9c <check_page_free_list+0x32>
f0100fc7:	e9 b4 fc ff ff       	jmp    f0100c80 <check_page_free_list+0x16>
f0100fcc:	83 3d 40 72 1e f0 00 	cmpl   $0x0,0xf01e7240
f0100fd3:	0f 84 a7 fc ff ff    	je     f0100c80 <check_page_free_list+0x16>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100fd9:	be 00 04 00 00       	mov    $0x400,%esi
f0100fde:	e9 07 fd ff ff       	jmp    f0100cea <check_page_free_list+0x80>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100fe3:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100fe8:	0f 85 61 ff ff ff    	jne    f0100f4f <check_page_free_list+0x2e5>
f0100fee:	e9 33 ff ff ff       	jmp    f0100f26 <check_page_free_list+0x2bc>
f0100ff3:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100ff8:	0f 85 4c ff ff ff    	jne    f0100f4a <check_page_free_list+0x2e0>
f0100ffe:	66 90                	xchg   %ax,%ax
f0101000:	e9 21 ff ff ff       	jmp    f0100f26 <check_page_free_list+0x2bc>
}
f0101005:	83 c4 4c             	add    $0x4c,%esp
f0101008:	5b                   	pop    %ebx
f0101009:	5e                   	pop    %esi
f010100a:	5f                   	pop    %edi
f010100b:	5d                   	pop    %ebp
f010100c:	c3                   	ret    

f010100d <page_init>:
{
f010100d:	55                   	push   %ebp
f010100e:	89 e5                	mov    %esp,%ebp
f0101010:	57                   	push   %edi
f0101011:	56                   	push   %esi
f0101012:	53                   	push   %ebx
f0101013:	83 ec 1c             	sub    $0x1c,%esp
	page_free_list = NULL; // page_free_list是static的，不会被初始化，必须给一个初始值
f0101016:	c7 05 40 72 1e f0 00 	movl   $0x0,0xf01e7240
f010101d:	00 00 00 
	if (PGNUM(pa) >= npages)
f0101020:	83 3d 88 7e 1e f0 07 	cmpl   $0x7,0xf01e7e88
f0101027:	77 1c                	ja     f0101045 <page_init+0x38>
		panic("pa2page called with invalid pa");
f0101029:	c7 44 24 08 f4 70 10 	movl   $0xf01070f4,0x8(%esp)
f0101030:	f0 
f0101031:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101038:	00 
f0101039:	c7 04 24 05 7a 10 f0 	movl   $0xf0107a05,(%esp)
f0101040:	e8 fb ef ff ff       	call   f0100040 <_panic>
	struct PageInfo *mp_entry_page = pa2page(MPENTRY_PADDR); // mp的入口程序只需要一页
f0101045:	a1 90 7e 1e f0       	mov    0xf01e7e90,%eax
f010104a:	8d 78 38             	lea    0x38(%eax),%edi
	for (int i = 1; i < npages_basemem; i++) // 将内存中的pages数组初始化为链表，头指针是page_free_list
f010104d:	8b 35 44 72 1e f0    	mov    0xf01e7244,%esi
f0101053:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101058:	b8 01 00 00 00       	mov    $0x1,%eax
f010105d:	eb 2d                	jmp    f010108c <page_init+0x7f>
f010105f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		if (pages + i == mp_entry_page)
f0101066:	89 d1                	mov    %edx,%ecx
f0101068:	03 0d 90 7e 1e f0    	add    0xf01e7e90,%ecx
f010106e:	39 f9                	cmp    %edi,%ecx
f0101070:	74 17                	je     f0101089 <page_init+0x7c>
		pages[i].pp_ref = 0;
f0101072:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0101078:	8b 0d 90 7e 1e f0    	mov    0xf01e7e90,%ecx
f010107e:	89 1c c1             	mov    %ebx,(%ecx,%eax,8)
		page_free_list = &pages[i]; // pages中包含了整个内存中的页，page_free_list指向其中空闲的页组成的链表的头部
f0101081:	03 15 90 7e 1e f0    	add    0xf01e7e90,%edx
f0101087:	89 d3                	mov    %edx,%ebx
	for (int i = 1; i < npages_basemem; i++) // 将内存中的pages数组初始化为链表，头指针是page_free_list
f0101089:	83 c0 01             	add    $0x1,%eax
f010108c:	39 c6                	cmp    %eax,%esi
f010108e:	77 cf                	ja     f010105f <page_init+0x52>
f0101090:	89 1d 40 72 1e f0    	mov    %ebx,0xf01e7240
	for (int i = PGNUM(PADDR(boot_alloc(0))); i < npages; i++) // PADDR()将虚拟地址转化为物理地址，boot_alloc(0)得到nextfree的位置(即pages end),PGNUM()求出需要几页才能到达该地址
f0101096:	b8 00 00 00 00       	mov    $0x0,%eax
f010109b:	e8 ab fa ff ff       	call   f0100b4b <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f01010a0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01010a5:	77 20                	ja     f01010c7 <page_init+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01010a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01010ab:	c7 44 24 08 c8 6a 10 	movl   $0xf0106ac8,0x8(%esp)
f01010b2:	f0 
f01010b3:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
f01010ba:	00 
f01010bb:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01010c2:	e8 79 ef ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01010c7:	05 00 00 00 10       	add    $0x10000000,%eax
f01010cc:	c1 e8 0c             	shr    $0xc,%eax
f01010cf:	89 c2                	mov    %eax,%edx
f01010d1:	8b 1d 40 72 1e f0    	mov    0xf01e7240,%ebx
f01010d7:	c1 e0 03             	shl    $0x3,%eax
f01010da:	eb 1e                	jmp    f01010fa <page_init+0xed>
		pages[i].pp_ref = 0;
f01010dc:	89 c1                	mov    %eax,%ecx
f01010de:	03 0d 90 7e 1e f0    	add    0xf01e7e90,%ecx
f01010e4:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f01010ea:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f01010ec:	89 c3                	mov    %eax,%ebx
f01010ee:	03 1d 90 7e 1e f0    	add    0xf01e7e90,%ebx
	for (int i = PGNUM(PADDR(boot_alloc(0))); i < npages; i++) // PADDR()将虚拟地址转化为物理地址，boot_alloc(0)得到nextfree的位置(即pages end),PGNUM()求出需要几页才能到达该地址
f01010f4:	83 c2 01             	add    $0x1,%edx
f01010f7:	83 c0 08             	add    $0x8,%eax
f01010fa:	3b 15 88 7e 1e f0    	cmp    0xf01e7e88,%edx
f0101100:	72 da                	jb     f01010dc <page_init+0xcf>
f0101102:	89 1d 40 72 1e f0    	mov    %ebx,0xf01e7240
}
f0101108:	83 c4 1c             	add    $0x1c,%esp
f010110b:	5b                   	pop    %ebx
f010110c:	5e                   	pop    %esi
f010110d:	5f                   	pop    %edi
f010110e:	5d                   	pop    %ebp
f010110f:	c3                   	ret    

f0101110 <page_alloc>:
{
f0101110:	55                   	push   %ebp
f0101111:	89 e5                	mov    %esp,%ebp
f0101113:	53                   	push   %ebx
f0101114:	83 ec 14             	sub    $0x14,%esp
	if (page_free_list) // page_free_list指向空闲页组成的链表的头部
f0101117:	8b 1d 40 72 1e f0    	mov    0xf01e7240,%ebx
f010111d:	85 db                	test   %ebx,%ebx
f010111f:	74 75                	je     f0101196 <page_alloc+0x86>
		page_free_list = page_free_list->pp_link; // 链表next行进
f0101121:	8b 03                	mov    (%ebx),%eax
f0101123:	a3 40 72 1e f0       	mov    %eax,0xf01e7240
		if (alloc_flags & ALLOC_ZERO)
f0101128:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010112c:	74 58                	je     f0101186 <page_alloc+0x76>
	return (pp - pages) << PGSHIFT;
f010112e:	89 d8                	mov    %ebx,%eax
f0101130:	2b 05 90 7e 1e f0    	sub    0xf01e7e90,%eax
f0101136:	c1 f8 03             	sar    $0x3,%eax
f0101139:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010113c:	89 c2                	mov    %eax,%edx
f010113e:	c1 ea 0c             	shr    $0xc,%edx
f0101141:	3b 15 88 7e 1e f0    	cmp    0xf01e7e88,%edx
f0101147:	72 20                	jb     f0101169 <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101149:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010114d:	c7 44 24 08 a4 6a 10 	movl   $0xf0106aa4,0x8(%esp)
f0101154:	f0 
f0101155:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010115c:	00 
f010115d:	c7 04 24 05 7a 10 f0 	movl   $0xf0107a05,(%esp)
f0101164:	e8 d7 ee ff ff       	call   f0100040 <_panic>
			memset(page2kva(result), 0, PGSIZE); // page2kva(p)：求得页p的地址，方法就是先求出p的索引i，用i*4096得到地址
f0101169:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101170:	00 
f0101171:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101178:	00 
	return (void *)(pa + KERNBASE);
f0101179:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010117e:	89 04 24             	mov    %eax,(%esp)
f0101181:	e8 c1 4b 00 00       	call   f0105d47 <memset>
		result->pp_ref = 0;
f0101186:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
		result->pp_link = NULL; // 确保page_free就可以检查错误
f010118c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return result;
f0101192:	89 d8                	mov    %ebx,%eax
f0101194:	eb 05                	jmp    f010119b <page_alloc+0x8b>
		return NULL;
f0101196:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010119b:	83 c4 14             	add    $0x14,%esp
f010119e:	5b                   	pop    %ebx
f010119f:	5d                   	pop    %ebp
f01011a0:	c3                   	ret    

f01011a1 <page_free>:
{
f01011a1:	55                   	push   %ebp
f01011a2:	89 e5                	mov    %esp,%ebp
f01011a4:	83 ec 18             	sub    $0x18,%esp
f01011a7:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref != 0 || pp->pp_link != NULL) // 还有人在使用这个page时，调用了释放函数
f01011aa:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01011af:	75 05                	jne    f01011b6 <page_free+0x15>
f01011b1:	83 38 00             	cmpl   $0x0,(%eax)
f01011b4:	74 1c                	je     f01011d2 <page_free+0x31>
		panic("can't free this page, this page is in used: page_free() in pmap.c \n");
f01011b6:	c7 44 24 08 14 71 10 	movl   $0xf0107114,0x8(%esp)
f01011bd:	f0 
f01011be:	c7 44 24 04 65 01 00 	movl   $0x165,0x4(%esp)
f01011c5:	00 
f01011c6:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01011cd:	e8 6e ee ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f01011d2:	8b 15 40 72 1e f0    	mov    0xf01e7240,%edx
f01011d8:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f01011da:	a3 40 72 1e f0       	mov    %eax,0xf01e7240
}
f01011df:	c9                   	leave  
f01011e0:	c3                   	ret    

f01011e1 <page_decref>:
{
f01011e1:	55                   	push   %ebp
f01011e2:	89 e5                	mov    %esp,%ebp
f01011e4:	83 ec 18             	sub    $0x18,%esp
f01011e7:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01011ea:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f01011ee:	8d 51 ff             	lea    -0x1(%ecx),%edx
f01011f1:	66 89 50 04          	mov    %dx,0x4(%eax)
f01011f5:	66 85 d2             	test   %dx,%dx
f01011f8:	75 08                	jne    f0101202 <page_decref+0x21>
		page_free(pp);
f01011fa:	89 04 24             	mov    %eax,(%esp)
f01011fd:	e8 9f ff ff ff       	call   f01011a1 <page_free>
}
f0101202:	c9                   	leave  
f0101203:	c3                   	ret    

f0101204 <pgdir_walk>:
{
f0101204:	55                   	push   %ebp
f0101205:	89 e5                	mov    %esp,%ebp
f0101207:	56                   	push   %esi
f0101208:	53                   	push   %ebx
f0101209:	83 ec 10             	sub    $0x10,%esp
f010120c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pde_t *pde = &pgdir[PDX(va)]; // 先由PDX(va)得到该地址对应的目录索引，并在目录中索引得到对应条目(一个32位地址),解引用pde即可得到对应条目
f010120f:	89 de                	mov    %ebx,%esi
f0101211:	c1 ee 16             	shr    $0x16,%esi
f0101214:	c1 e6 02             	shl    $0x2,%esi
f0101217:	03 75 08             	add    0x8(%ebp),%esi
	if (*pde & PTE_P) // 当“va”的PTE所在的页存在，该页对应的条目在目录中的值就!=0
f010121a:	8b 06                	mov    (%esi),%eax
f010121c:	a8 01                	test   $0x1,%al
f010121e:	74 47                	je     f0101267 <pgdir_walk+0x63>
		pte_tab = (pte_t *)KADDR(PTE_ADDR(*pde)); // PTE_ADDR()获得该条目对应的页的物理地址，KADDR()把物理地址转为虚拟地址
f0101220:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101225:	89 c2                	mov    %eax,%edx
f0101227:	c1 ea 0c             	shr    $0xc,%edx
f010122a:	3b 15 88 7e 1e f0    	cmp    0xf01e7e88,%edx
f0101230:	72 20                	jb     f0101252 <pgdir_walk+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101232:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101236:	c7 44 24 08 a4 6a 10 	movl   $0xf0106aa4,0x8(%esp)
f010123d:	f0 
f010123e:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
f0101245:	00 
f0101246:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f010124d:	e8 ee ed ff ff       	call   f0100040 <_panic>
		result = &pte_tab[PTX(va)];				  // 页里存的就是PTE表，用PTX(va)得到页索引，索引到对应的pte的地址
f0101252:	c1 eb 0a             	shr    $0xa,%ebx
f0101255:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f010125b:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0101262:	e9 85 00 00 00       	jmp    f01012ec <pgdir_walk+0xe8>
		if (!create)
f0101267:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010126b:	74 73                	je     f01012e0 <pgdir_walk+0xdc>
		struct PageInfo *pp = page_alloc(ALLOC_ZERO); // 分配新的一页来存储PTE表
f010126d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101274:	e8 97 fe ff ff       	call   f0101110 <page_alloc>
		if (!pp) // 如果pp == NULL，分配失败
f0101279:	85 c0                	test   %eax,%eax
f010127b:	74 6a                	je     f01012e7 <pgdir_walk+0xe3>
	return (pp - pages) << PGSHIFT;
f010127d:	89 c2                	mov    %eax,%edx
f010127f:	2b 15 90 7e 1e f0    	sub    0xf01e7e90,%edx
f0101285:	c1 fa 03             	sar    $0x3,%edx
f0101288:	c1 e2 0c             	shl    $0xc,%edx
		*pde = page2pa(pp) | PTE_P | PTE_W | PTE_U; // 更新目录的条目，以指向新分配的页
f010128b:	83 ca 07             	or     $0x7,%edx
f010128e:	89 16                	mov    %edx,(%esi)
		pp->pp_ref++;
f0101290:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0101295:	2b 05 90 7e 1e f0    	sub    0xf01e7e90,%eax
f010129b:	c1 f8 03             	sar    $0x3,%eax
f010129e:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01012a1:	89 c2                	mov    %eax,%edx
f01012a3:	c1 ea 0c             	shr    $0xc,%edx
f01012a6:	3b 15 88 7e 1e f0    	cmp    0xf01e7e88,%edx
f01012ac:	72 20                	jb     f01012ce <pgdir_walk+0xca>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01012b2:	c7 44 24 08 a4 6a 10 	movl   $0xf0106aa4,0x8(%esp)
f01012b9:	f0 
f01012ba:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01012c1:	00 
f01012c2:	c7 04 24 05 7a 10 f0 	movl   $0xf0107a05,(%esp)
f01012c9:	e8 72 ed ff ff       	call   f0100040 <_panic>
		result = &pte_tab[PTX(va)];
f01012ce:	c1 eb 0a             	shr    $0xa,%ebx
f01012d1:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f01012d7:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f01012de:	eb 0c                	jmp    f01012ec <pgdir_walk+0xe8>
			return NULL;
f01012e0:	b8 00 00 00 00       	mov    $0x0,%eax
f01012e5:	eb 05                	jmp    f01012ec <pgdir_walk+0xe8>
			return NULL;
f01012e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01012ec:	83 c4 10             	add    $0x10,%esp
f01012ef:	5b                   	pop    %ebx
f01012f0:	5e                   	pop    %esi
f01012f1:	5d                   	pop    %ebp
f01012f2:	c3                   	ret    

f01012f3 <page_lookup>:
{
f01012f3:	55                   	push   %ebp
f01012f4:	89 e5                	mov    %esp,%ebp
f01012f6:	53                   	push   %ebx
f01012f7:	83 ec 14             	sub    $0x14,%esp
f01012fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0); // 得到“va”的PTE的指针
f01012fd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101304:	00 
f0101305:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101308:	89 44 24 04          	mov    %eax,0x4(%esp)
f010130c:	8b 45 08             	mov    0x8(%ebp),%eax
f010130f:	89 04 24             	mov    %eax,(%esp)
f0101312:	e8 ed fe ff ff       	call   f0101204 <pgdir_walk>
	if (pte == NULL)					   // 若PTE不存在，则“va”没有映射到对应的物理地址
f0101317:	85 c0                	test   %eax,%eax
f0101319:	74 3a                	je     f0101355 <page_lookup+0x62>
	if (pte_store)
f010131b:	85 db                	test   %ebx,%ebx
f010131d:	74 02                	je     f0101321 <page_lookup+0x2e>
		*pte_store = pte;
f010131f:	89 03                	mov    %eax,(%ebx)
	return pa2page(PTE_ADDR(*pte)); // PTE_ADDR(*pte)：根据pte得到物理地址，pa2page()：根据物理地址得到页面
f0101321:	8b 00                	mov    (%eax),%eax
	if (PGNUM(pa) >= npages)
f0101323:	c1 e8 0c             	shr    $0xc,%eax
f0101326:	3b 05 88 7e 1e f0    	cmp    0xf01e7e88,%eax
f010132c:	72 1c                	jb     f010134a <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f010132e:	c7 44 24 08 f4 70 10 	movl   $0xf01070f4,0x8(%esp)
f0101335:	f0 
f0101336:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f010133d:	00 
f010133e:	c7 04 24 05 7a 10 f0 	movl   $0xf0107a05,(%esp)
f0101345:	e8 f6 ec ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010134a:	8b 15 90 7e 1e f0    	mov    0xf01e7e90,%edx
f0101350:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0101353:	eb 05                	jmp    f010135a <page_lookup+0x67>
		return NULL;
f0101355:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010135a:	83 c4 14             	add    $0x14,%esp
f010135d:	5b                   	pop    %ebx
f010135e:	5d                   	pop    %ebp
f010135f:	c3                   	ret    

f0101360 <tlb_invalidate>:
{
f0101360:	55                   	push   %ebp
f0101361:	89 e5                	mov    %esp,%ebp
f0101363:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f0101366:	e8 2e 50 00 00       	call   f0106399 <cpunum>
f010136b:	6b c0 74             	imul   $0x74,%eax,%eax
f010136e:	83 b8 28 80 1e f0 00 	cmpl   $0x0,-0xfe17fd8(%eax)
f0101375:	74 16                	je     f010138d <tlb_invalidate+0x2d>
f0101377:	e8 1d 50 00 00       	call   f0106399 <cpunum>
f010137c:	6b c0 74             	imul   $0x74,%eax,%eax
f010137f:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f0101385:	8b 55 08             	mov    0x8(%ebp),%edx
f0101388:	39 50 60             	cmp    %edx,0x60(%eax)
f010138b:	75 06                	jne    f0101393 <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010138d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101390:	0f 01 38             	invlpg (%eax)
}
f0101393:	c9                   	leave  
f0101394:	c3                   	ret    

f0101395 <boot_map_region>:
{
f0101395:	55                   	push   %ebp
f0101396:	89 e5                	mov    %esp,%ebp
f0101398:	57                   	push   %edi
f0101399:	56                   	push   %esi
f010139a:	53                   	push   %ebx
f010139b:	83 ec 2c             	sub    $0x2c,%esp
f010139e:	89 c7                	mov    %eax,%edi
f01013a0:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01013a3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (int i = 0; i < size; i += PGSIZE) // 以页为单位操作映射
f01013a6:	bb 00 00 00 00       	mov    $0x0,%ebx
		*pte = (pa + i) | PTE_P | perm;							 // 物理地址写入PTE,完成映射
f01013ab:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013ae:	83 c8 01             	or     $0x1,%eax
f01013b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (int i = 0; i < size; i += PGSIZE) // 以页为单位操作映射
f01013b4:	eb 36                	jmp    f01013ec <boot_map_region+0x57>
f01013b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01013b9:	8d 34 18             	lea    (%eax,%ebx,1),%esi
		tlb_invalidate(pgdir, (void *)va + i);					 // 使TLB无效
f01013bc:	89 74 24 04          	mov    %esi,0x4(%esp)
f01013c0:	89 3c 24             	mov    %edi,(%esp)
f01013c3:	e8 98 ff ff ff       	call   f0101360 <tlb_invalidate>
		pte_t *pte = pgdir_walk(pgdir, (const void *)va + i, 1); // 得到虚拟地址对应的pte
f01013c8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01013cf:	00 
f01013d0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01013d4:	89 3c 24             	mov    %edi,(%esp)
f01013d7:	e8 28 fe ff ff       	call   f0101204 <pgdir_walk>
f01013dc:	89 da                	mov    %ebx,%edx
f01013de:	03 55 08             	add    0x8(%ebp),%edx
		*pte = (pa + i) | PTE_P | perm;							 // 物理地址写入PTE,完成映射
f01013e1:	0b 55 dc             	or     -0x24(%ebp),%edx
f01013e4:	89 10                	mov    %edx,(%eax)
	for (int i = 0; i < size; i += PGSIZE) // 以页为单位操作映射
f01013e6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01013ec:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f01013ef:	77 c5                	ja     f01013b6 <boot_map_region+0x21>
}
f01013f1:	83 c4 2c             	add    $0x2c,%esp
f01013f4:	5b                   	pop    %ebx
f01013f5:	5e                   	pop    %esi
f01013f6:	5f                   	pop    %edi
f01013f7:	5d                   	pop    %ebp
f01013f8:	c3                   	ret    

f01013f9 <page_remove>:
{
f01013f9:	55                   	push   %ebp
f01013fa:	89 e5                	mov    %esp,%ebp
f01013fc:	56                   	push   %esi
f01013fd:	53                   	push   %ebx
f01013fe:	83 ec 20             	sub    $0x20,%esp
f0101401:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101404:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store); // 得到“va”对应的页面，和指向对应的pte的指针pte_store
f0101407:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010140a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010140e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101412:	89 1c 24             	mov    %ebx,(%esp)
f0101415:	e8 d9 fe ff ff       	call   f01012f3 <page_lookup>
	if (pp)
f010141a:	85 c0                	test   %eax,%eax
f010141c:	74 1d                	je     f010143b <page_remove+0x42>
		page_decref(pp);
f010141e:	89 04 24             	mov    %eax,(%esp)
f0101421:	e8 bb fd ff ff       	call   f01011e1 <page_decref>
		tlb_invalidate(pgdir, va); // 如果从页表中删除条目，则TLB必须无效
f0101426:	89 74 24 04          	mov    %esi,0x4(%esp)
f010142a:	89 1c 24             	mov    %ebx,(%esp)
f010142d:	e8 2e ff ff ff       	call   f0101360 <tlb_invalidate>
		*pte_store = 0;
f0101432:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101435:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
f010143b:	83 c4 20             	add    $0x20,%esp
f010143e:	5b                   	pop    %ebx
f010143f:	5e                   	pop    %esi
f0101440:	5d                   	pop    %ebp
f0101441:	c3                   	ret    

f0101442 <page_insert>:
{
f0101442:	55                   	push   %ebp
f0101443:	89 e5                	mov    %esp,%ebp
f0101445:	57                   	push   %edi
f0101446:	56                   	push   %esi
f0101447:	53                   	push   %ebx
f0101448:	83 ec 1c             	sub    $0x1c,%esp
f010144b:	8b 75 08             	mov    0x8(%ebp),%esi
f010144e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101451:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1); // 得到pte的指针，create=1,代表有必要会创建新的页
f0101454:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010145b:	00 
f010145c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101460:	89 34 24             	mov    %esi,(%esp)
f0101463:	e8 9c fd ff ff       	call   f0101204 <pgdir_walk>
	if (pte == NULL)
f0101468:	85 c0                	test   %eax,%eax
f010146a:	74 41                	je     f01014ad <page_insert+0x6b>
	pp->pp_ref++;
f010146c:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P)
f0101471:	f6 00 01             	testb  $0x1,(%eax)
f0101474:	74 0c                	je     f0101482 <page_insert+0x40>
		page_remove(pgdir, va);
f0101476:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010147a:	89 34 24             	mov    %esi,(%esp)
f010147d:	e8 77 ff ff ff       	call   f01013f9 <page_remove>
	boot_map_region(pgdir, (uintptr_t)va, PGSIZE, page2pa(pp), perm);
f0101482:	8b 45 14             	mov    0x14(%ebp),%eax
f0101485:	89 44 24 04          	mov    %eax,0x4(%esp)
	return (pp - pages) << PGSHIFT;
f0101489:	2b 1d 90 7e 1e f0    	sub    0xf01e7e90,%ebx
f010148f:	c1 fb 03             	sar    $0x3,%ebx
f0101492:	c1 e3 0c             	shl    $0xc,%ebx
f0101495:	89 1c 24             	mov    %ebx,(%esp)
f0101498:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010149d:	89 fa                	mov    %edi,%edx
f010149f:	89 f0                	mov    %esi,%eax
f01014a1:	e8 ef fe ff ff       	call   f0101395 <boot_map_region>
	return 0;
f01014a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01014ab:	eb 05                	jmp    f01014b2 <page_insert+0x70>
		return -E_NO_MEM;
f01014ad:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
f01014b2:	83 c4 1c             	add    $0x1c,%esp
f01014b5:	5b                   	pop    %ebx
f01014b6:	5e                   	pop    %esi
f01014b7:	5f                   	pop    %edi
f01014b8:	5d                   	pop    %ebp
f01014b9:	c3                   	ret    

f01014ba <mmio_map_region>:
{
f01014ba:	55                   	push   %ebp
f01014bb:	89 e5                	mov    %esp,%ebp
f01014bd:	53                   	push   %ebx
f01014be:	83 ec 14             	sub    $0x14,%esp
	size = ROUNDUP(size, PGSIZE);
f01014c1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014c4:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01014ca:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base + size > MMIOLIM)
f01014d0:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f01014d6:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f01014d9:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f01014de:	76 1c                	jbe    f01014fc <mmio_map_region+0x42>
		panic("mmio_map_region: out of MMIOLIM!");
f01014e0:	c7 44 24 08 58 71 10 	movl   $0xf0107158,0x8(%esp)
f01014e7:	f0 
f01014e8:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
f01014ef:	00 
f01014f0:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01014f7:	e8 44 eb ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD | PTE_PWT | PTE_W);
f01014fc:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101503:	00 
f0101504:	8b 45 08             	mov    0x8(%ebp),%eax
f0101507:	89 04 24             	mov    %eax,(%esp)
f010150a:	89 d9                	mov    %ebx,%ecx
f010150c:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0101511:	e8 7f fe ff ff       	call   f0101395 <boot_map_region>
	base += size;
f0101516:	a1 00 13 12 f0       	mov    0xf0121300,%eax
f010151b:	01 c3                	add    %eax,%ebx
f010151d:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300
}
f0101523:	83 c4 14             	add    $0x14,%esp
f0101526:	5b                   	pop    %ebx
f0101527:	5d                   	pop    %ebp
f0101528:	c3                   	ret    

f0101529 <mem_init>:
{
f0101529:	55                   	push   %ebp
f010152a:	89 e5                	mov    %esp,%ebp
f010152c:	57                   	push   %edi
f010152d:	56                   	push   %esi
f010152e:	53                   	push   %ebx
f010152f:	83 ec 4c             	sub    $0x4c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101532:	b8 15 00 00 00       	mov    $0x15,%eax
f0101537:	e8 e4 f5 ff ff       	call   f0100b20 <nvram_read>
f010153c:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010153e:	b8 17 00 00 00       	mov    $0x17,%eax
f0101543:	e8 d8 f5 ff ff       	call   f0100b20 <nvram_read>
f0101548:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010154a:	b8 34 00 00 00       	mov    $0x34,%eax
f010154f:	e8 cc f5 ff ff       	call   f0100b20 <nvram_read>
f0101554:	c1 e0 06             	shl    $0x6,%eax
f0101557:	89 c2                	mov    %eax,%edx
		totalmem = 16 * 1024 + ext16mem;
f0101559:	8d 80 00 40 00 00    	lea    0x4000(%eax),%eax
	if (ext16mem)
f010155f:	85 d2                	test   %edx,%edx
f0101561:	75 0b                	jne    f010156e <mem_init+0x45>
		totalmem = 1 * 1024 + extmem;
f0101563:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101569:	85 f6                	test   %esi,%esi
f010156b:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f010156e:	89 c2                	mov    %eax,%edx
f0101570:	c1 ea 02             	shr    $0x2,%edx
f0101573:	89 15 88 7e 1e f0    	mov    %edx,0xf01e7e88
	npages_basemem = basemem / (PGSIZE / 1024);
f0101579:	89 da                	mov    %ebx,%edx
f010157b:	c1 ea 02             	shr    $0x2,%edx
f010157e:	89 15 44 72 1e f0    	mov    %edx,0xf01e7244
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101584:	89 c2                	mov    %eax,%edx
f0101586:	29 da                	sub    %ebx,%edx
f0101588:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010158c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101590:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101594:	c7 04 24 7c 71 10 f0 	movl   $0xf010717c,(%esp)
f010159b:	e8 2d 29 00 00       	call   f0103ecd <cprintf>
	kern_pgdir = (pde_t *)boot_alloc(PGSIZE); // 第一次运行，会舍入一部分
f01015a0:	b8 00 10 00 00       	mov    $0x1000,%eax
f01015a5:	e8 a1 f5 ff ff       	call   f0100b4b <boot_alloc>
f01015aa:	a3 8c 7e 1e f0       	mov    %eax,0xf01e7e8c
	memset(kern_pgdir, 0, PGSIZE);			  // 内存初始化为0
f01015af:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01015b6:	00 
f01015b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01015be:	00 
f01015bf:	89 04 24             	mov    %eax,(%esp)
f01015c2:	e8 80 47 00 00       	call   f0105d47 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P; // 暂时不需要理解，只需要知道kern_pgdir处有一个页表目录
f01015c7:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01015cc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01015d1:	77 20                	ja     f01015f3 <mem_init+0xca>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01015d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015d7:	c7 44 24 08 c8 6a 10 	movl   $0xf0106ac8,0x8(%esp)
f01015de:	f0 
f01015df:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
f01015e6:	00 
f01015e7:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01015ee:	e8 4d ea ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01015f3:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01015f9:	83 ca 05             	or     $0x5,%edx
f01015fc:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *)boot_alloc(npages * sizeof(struct PageInfo)); // sizeof求得PageInfo占多少字节，返回结果记得强转成pages对应的类型
f0101602:	a1 88 7e 1e f0       	mov    0xf01e7e88,%eax
f0101607:	c1 e0 03             	shl    $0x3,%eax
f010160a:	e8 3c f5 ff ff       	call   f0100b4b <boot_alloc>
f010160f:	a3 90 7e 1e f0       	mov    %eax,0xf01e7e90
	memset(pages, 0, npages * sizeof(struct PageInfo));						 // memset(d,c,l):从指针d开始，用字符c填充l个长度的内存
f0101614:	8b 0d 88 7e 1e f0    	mov    0xf01e7e88,%ecx
f010161a:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101621:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101625:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010162c:	00 
f010162d:	89 04 24             	mov    %eax,(%esp)
f0101630:	e8 12 47 00 00       	call   f0105d47 <memset>
	envs = (struct Env *)boot_alloc(NENV * sizeof(struct Env));
f0101635:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010163a:	e8 0c f5 ff ff       	call   f0100b4b <boot_alloc>
f010163f:	a3 48 72 1e f0       	mov    %eax,0xf01e7248
	page_init(); // 初始化之后，所有的内存管理都将通过page_*函数进行
f0101644:	e8 c4 f9 ff ff       	call   f010100d <page_init>
	check_page_free_list(1);
f0101649:	b8 01 00 00 00       	mov    $0x1,%eax
f010164e:	e8 17 f6 ff ff       	call   f0100c6a <check_page_free_list>
	if (!pages)
f0101653:	83 3d 90 7e 1e f0 00 	cmpl   $0x0,0xf01e7e90
f010165a:	75 1c                	jne    f0101678 <mem_init+0x14f>
		panic("'pages' is a null pointer!");
f010165c:	c7 44 24 08 cc 7a 10 	movl   $0xf0107acc,0x8(%esp)
f0101663:	f0 
f0101664:	c7 44 24 04 91 02 00 	movl   $0x291,0x4(%esp)
f010166b:	00 
f010166c:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101673:	e8 c8 e9 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101678:	a1 40 72 1e f0       	mov    0xf01e7240,%eax
f010167d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101682:	eb 05                	jmp    f0101689 <mem_init+0x160>
		++nfree;
f0101684:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101687:	8b 00                	mov    (%eax),%eax
f0101689:	85 c0                	test   %eax,%eax
f010168b:	75 f7                	jne    f0101684 <mem_init+0x15b>
	assert((pp0 = page_alloc(0)));
f010168d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101694:	e8 77 fa ff ff       	call   f0101110 <page_alloc>
f0101699:	89 c7                	mov    %eax,%edi
f010169b:	85 c0                	test   %eax,%eax
f010169d:	75 24                	jne    f01016c3 <mem_init+0x19a>
f010169f:	c7 44 24 0c e7 7a 10 	movl   $0xf0107ae7,0xc(%esp)
f01016a6:	f0 
f01016a7:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01016ae:	f0 
f01016af:	c7 44 24 04 99 02 00 	movl   $0x299,0x4(%esp)
f01016b6:	00 
f01016b7:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01016be:	e8 7d e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01016c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016ca:	e8 41 fa ff ff       	call   f0101110 <page_alloc>
f01016cf:	89 c6                	mov    %eax,%esi
f01016d1:	85 c0                	test   %eax,%eax
f01016d3:	75 24                	jne    f01016f9 <mem_init+0x1d0>
f01016d5:	c7 44 24 0c fd 7a 10 	movl   $0xf0107afd,0xc(%esp)
f01016dc:	f0 
f01016dd:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01016e4:	f0 
f01016e5:	c7 44 24 04 9a 02 00 	movl   $0x29a,0x4(%esp)
f01016ec:	00 
f01016ed:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01016f4:	e8 47 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01016f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101700:	e8 0b fa ff ff       	call   f0101110 <page_alloc>
f0101705:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101708:	85 c0                	test   %eax,%eax
f010170a:	75 24                	jne    f0101730 <mem_init+0x207>
f010170c:	c7 44 24 0c 13 7b 10 	movl   $0xf0107b13,0xc(%esp)
f0101713:	f0 
f0101714:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f010171b:	f0 
f010171c:	c7 44 24 04 9b 02 00 	movl   $0x29b,0x4(%esp)
f0101723:	00 
f0101724:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f010172b:	e8 10 e9 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101730:	39 f7                	cmp    %esi,%edi
f0101732:	75 24                	jne    f0101758 <mem_init+0x22f>
f0101734:	c7 44 24 0c 29 7b 10 	movl   $0xf0107b29,0xc(%esp)
f010173b:	f0 
f010173c:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101743:	f0 
f0101744:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
f010174b:	00 
f010174c:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101753:	e8 e8 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101758:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010175b:	39 c6                	cmp    %eax,%esi
f010175d:	74 04                	je     f0101763 <mem_init+0x23a>
f010175f:	39 c7                	cmp    %eax,%edi
f0101761:	75 24                	jne    f0101787 <mem_init+0x25e>
f0101763:	c7 44 24 0c b8 71 10 	movl   $0xf01071b8,0xc(%esp)
f010176a:	f0 
f010176b:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101772:	f0 
f0101773:	c7 44 24 04 9f 02 00 	movl   $0x29f,0x4(%esp)
f010177a:	00 
f010177b:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101782:	e8 b9 e8 ff ff       	call   f0100040 <_panic>
	return (pp - pages) << PGSHIFT;
f0101787:	8b 15 90 7e 1e f0    	mov    0xf01e7e90,%edx
	assert(page2pa(pp0) < npages * PGSIZE);
f010178d:	a1 88 7e 1e f0       	mov    0xf01e7e88,%eax
f0101792:	c1 e0 0c             	shl    $0xc,%eax
f0101795:	89 f9                	mov    %edi,%ecx
f0101797:	29 d1                	sub    %edx,%ecx
f0101799:	c1 f9 03             	sar    $0x3,%ecx
f010179c:	c1 e1 0c             	shl    $0xc,%ecx
f010179f:	39 c1                	cmp    %eax,%ecx
f01017a1:	72 24                	jb     f01017c7 <mem_init+0x29e>
f01017a3:	c7 44 24 0c d8 71 10 	movl   $0xf01071d8,0xc(%esp)
f01017aa:	f0 
f01017ab:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01017b2:	f0 
f01017b3:	c7 44 24 04 a0 02 00 	movl   $0x2a0,0x4(%esp)
f01017ba:	00 
f01017bb:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01017c2:	e8 79 e8 ff ff       	call   f0100040 <_panic>
f01017c7:	89 f1                	mov    %esi,%ecx
f01017c9:	29 d1                	sub    %edx,%ecx
f01017cb:	c1 f9 03             	sar    $0x3,%ecx
f01017ce:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages * PGSIZE);
f01017d1:	39 c8                	cmp    %ecx,%eax
f01017d3:	77 24                	ja     f01017f9 <mem_init+0x2d0>
f01017d5:	c7 44 24 0c f8 71 10 	movl   $0xf01071f8,0xc(%esp)
f01017dc:	f0 
f01017dd:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01017e4:	f0 
f01017e5:	c7 44 24 04 a1 02 00 	movl   $0x2a1,0x4(%esp)
f01017ec:	00 
f01017ed:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01017f4:	e8 47 e8 ff ff       	call   f0100040 <_panic>
f01017f9:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01017fc:	29 d1                	sub    %edx,%ecx
f01017fe:	89 ca                	mov    %ecx,%edx
f0101800:	c1 fa 03             	sar    $0x3,%edx
f0101803:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages * PGSIZE);
f0101806:	39 d0                	cmp    %edx,%eax
f0101808:	77 24                	ja     f010182e <mem_init+0x305>
f010180a:	c7 44 24 0c 18 72 10 	movl   $0xf0107218,0xc(%esp)
f0101811:	f0 
f0101812:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101819:	f0 
f010181a:	c7 44 24 04 a2 02 00 	movl   $0x2a2,0x4(%esp)
f0101821:	00 
f0101822:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101829:	e8 12 e8 ff ff       	call   f0100040 <_panic>
	fl = page_free_list;
f010182e:	a1 40 72 1e f0       	mov    0xf01e7240,%eax
f0101833:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101836:	c7 05 40 72 1e f0 00 	movl   $0x0,0xf01e7240
f010183d:	00 00 00 
	assert(!page_alloc(0));
f0101840:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101847:	e8 c4 f8 ff ff       	call   f0101110 <page_alloc>
f010184c:	85 c0                	test   %eax,%eax
f010184e:	74 24                	je     f0101874 <mem_init+0x34b>
f0101850:	c7 44 24 0c 3b 7b 10 	movl   $0xf0107b3b,0xc(%esp)
f0101857:	f0 
f0101858:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f010185f:	f0 
f0101860:	c7 44 24 04 a9 02 00 	movl   $0x2a9,0x4(%esp)
f0101867:	00 
f0101868:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f010186f:	e8 cc e7 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0101874:	89 3c 24             	mov    %edi,(%esp)
f0101877:	e8 25 f9 ff ff       	call   f01011a1 <page_free>
	page_free(pp1);
f010187c:	89 34 24             	mov    %esi,(%esp)
f010187f:	e8 1d f9 ff ff       	call   f01011a1 <page_free>
	page_free(pp2);
f0101884:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101887:	89 04 24             	mov    %eax,(%esp)
f010188a:	e8 12 f9 ff ff       	call   f01011a1 <page_free>
	assert((pp0 = page_alloc(0)));
f010188f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101896:	e8 75 f8 ff ff       	call   f0101110 <page_alloc>
f010189b:	89 c6                	mov    %eax,%esi
f010189d:	85 c0                	test   %eax,%eax
f010189f:	75 24                	jne    f01018c5 <mem_init+0x39c>
f01018a1:	c7 44 24 0c e7 7a 10 	movl   $0xf0107ae7,0xc(%esp)
f01018a8:	f0 
f01018a9:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01018b0:	f0 
f01018b1:	c7 44 24 04 b0 02 00 	movl   $0x2b0,0x4(%esp)
f01018b8:	00 
f01018b9:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01018c0:	e8 7b e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01018c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018cc:	e8 3f f8 ff ff       	call   f0101110 <page_alloc>
f01018d1:	89 c7                	mov    %eax,%edi
f01018d3:	85 c0                	test   %eax,%eax
f01018d5:	75 24                	jne    f01018fb <mem_init+0x3d2>
f01018d7:	c7 44 24 0c fd 7a 10 	movl   $0xf0107afd,0xc(%esp)
f01018de:	f0 
f01018df:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01018e6:	f0 
f01018e7:	c7 44 24 04 b1 02 00 	movl   $0x2b1,0x4(%esp)
f01018ee:	00 
f01018ef:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01018f6:	e8 45 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01018fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101902:	e8 09 f8 ff ff       	call   f0101110 <page_alloc>
f0101907:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010190a:	85 c0                	test   %eax,%eax
f010190c:	75 24                	jne    f0101932 <mem_init+0x409>
f010190e:	c7 44 24 0c 13 7b 10 	movl   $0xf0107b13,0xc(%esp)
f0101915:	f0 
f0101916:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f010191d:	f0 
f010191e:	c7 44 24 04 b2 02 00 	movl   $0x2b2,0x4(%esp)
f0101925:	00 
f0101926:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f010192d:	e8 0e e7 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101932:	39 fe                	cmp    %edi,%esi
f0101934:	75 24                	jne    f010195a <mem_init+0x431>
f0101936:	c7 44 24 0c 29 7b 10 	movl   $0xf0107b29,0xc(%esp)
f010193d:	f0 
f010193e:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101945:	f0 
f0101946:	c7 44 24 04 b4 02 00 	movl   $0x2b4,0x4(%esp)
f010194d:	00 
f010194e:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101955:	e8 e6 e6 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010195a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010195d:	39 c7                	cmp    %eax,%edi
f010195f:	74 04                	je     f0101965 <mem_init+0x43c>
f0101961:	39 c6                	cmp    %eax,%esi
f0101963:	75 24                	jne    f0101989 <mem_init+0x460>
f0101965:	c7 44 24 0c b8 71 10 	movl   $0xf01071b8,0xc(%esp)
f010196c:	f0 
f010196d:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101974:	f0 
f0101975:	c7 44 24 04 b5 02 00 	movl   $0x2b5,0x4(%esp)
f010197c:	00 
f010197d:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101984:	e8 b7 e6 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101989:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101990:	e8 7b f7 ff ff       	call   f0101110 <page_alloc>
f0101995:	85 c0                	test   %eax,%eax
f0101997:	74 24                	je     f01019bd <mem_init+0x494>
f0101999:	c7 44 24 0c 3b 7b 10 	movl   $0xf0107b3b,0xc(%esp)
f01019a0:	f0 
f01019a1:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01019a8:	f0 
f01019a9:	c7 44 24 04 b6 02 00 	movl   $0x2b6,0x4(%esp)
f01019b0:	00 
f01019b1:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01019b8:	e8 83 e6 ff ff       	call   f0100040 <_panic>
f01019bd:	89 f0                	mov    %esi,%eax
f01019bf:	2b 05 90 7e 1e f0    	sub    0xf01e7e90,%eax
f01019c5:	c1 f8 03             	sar    $0x3,%eax
f01019c8:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01019cb:	89 c2                	mov    %eax,%edx
f01019cd:	c1 ea 0c             	shr    $0xc,%edx
f01019d0:	3b 15 88 7e 1e f0    	cmp    0xf01e7e88,%edx
f01019d6:	72 20                	jb     f01019f8 <mem_init+0x4cf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01019dc:	c7 44 24 08 a4 6a 10 	movl   $0xf0106aa4,0x8(%esp)
f01019e3:	f0 
f01019e4:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01019eb:	00 
f01019ec:	c7 04 24 05 7a 10 f0 	movl   $0xf0107a05,(%esp)
f01019f3:	e8 48 e6 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp0), 1, PGSIZE);
f01019f8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01019ff:	00 
f0101a00:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101a07:	00 
	return (void *)(pa + KERNBASE);
f0101a08:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a0d:	89 04 24             	mov    %eax,(%esp)
f0101a10:	e8 32 43 00 00       	call   f0105d47 <memset>
	page_free(pp0);
f0101a15:	89 34 24             	mov    %esi,(%esp)
f0101a18:	e8 84 f7 ff ff       	call   f01011a1 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101a1d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101a24:	e8 e7 f6 ff ff       	call   f0101110 <page_alloc>
f0101a29:	85 c0                	test   %eax,%eax
f0101a2b:	75 24                	jne    f0101a51 <mem_init+0x528>
f0101a2d:	c7 44 24 0c 4a 7b 10 	movl   $0xf0107b4a,0xc(%esp)
f0101a34:	f0 
f0101a35:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101a3c:	f0 
f0101a3d:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
f0101a44:	00 
f0101a45:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101a4c:	e8 ef e5 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101a51:	39 c6                	cmp    %eax,%esi
f0101a53:	74 24                	je     f0101a79 <mem_init+0x550>
f0101a55:	c7 44 24 0c 68 7b 10 	movl   $0xf0107b68,0xc(%esp)
f0101a5c:	f0 
f0101a5d:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101a64:	f0 
f0101a65:	c7 44 24 04 bc 02 00 	movl   $0x2bc,0x4(%esp)
f0101a6c:	00 
f0101a6d:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101a74:	e8 c7 e5 ff ff       	call   f0100040 <_panic>
	return (pp - pages) << PGSHIFT;
f0101a79:	89 f0                	mov    %esi,%eax
f0101a7b:	2b 05 90 7e 1e f0    	sub    0xf01e7e90,%eax
f0101a81:	c1 f8 03             	sar    $0x3,%eax
f0101a84:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101a87:	89 c2                	mov    %eax,%edx
f0101a89:	c1 ea 0c             	shr    $0xc,%edx
f0101a8c:	3b 15 88 7e 1e f0    	cmp    0xf01e7e88,%edx
f0101a92:	72 20                	jb     f0101ab4 <mem_init+0x58b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a94:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101a98:	c7 44 24 08 a4 6a 10 	movl   $0xf0106aa4,0x8(%esp)
f0101a9f:	f0 
f0101aa0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101aa7:	00 
f0101aa8:	c7 04 24 05 7a 10 f0 	movl   $0xf0107a05,(%esp)
f0101aaf:	e8 8c e5 ff ff       	call   f0100040 <_panic>
f0101ab4:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101aba:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
		assert(c[i] == 0);
f0101ac0:	80 38 00             	cmpb   $0x0,(%eax)
f0101ac3:	74 24                	je     f0101ae9 <mem_init+0x5c0>
f0101ac5:	c7 44 24 0c 78 7b 10 	movl   $0xf0107b78,0xc(%esp)
f0101acc:	f0 
f0101acd:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101ad4:	f0 
f0101ad5:	c7 44 24 04 bf 02 00 	movl   $0x2bf,0x4(%esp)
f0101adc:	00 
f0101add:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101ae4:	e8 57 e5 ff ff       	call   f0100040 <_panic>
f0101ae9:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101aec:	39 d0                	cmp    %edx,%eax
f0101aee:	75 d0                	jne    f0101ac0 <mem_init+0x597>
	page_free_list = fl;
f0101af0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101af3:	a3 40 72 1e f0       	mov    %eax,0xf01e7240
	page_free(pp0);
f0101af8:	89 34 24             	mov    %esi,(%esp)
f0101afb:	e8 a1 f6 ff ff       	call   f01011a1 <page_free>
	page_free(pp1);
f0101b00:	89 3c 24             	mov    %edi,(%esp)
f0101b03:	e8 99 f6 ff ff       	call   f01011a1 <page_free>
	page_free(pp2);
f0101b08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b0b:	89 04 24             	mov    %eax,(%esp)
f0101b0e:	e8 8e f6 ff ff       	call   f01011a1 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b13:	a1 40 72 1e f0       	mov    0xf01e7240,%eax
f0101b18:	eb 05                	jmp    f0101b1f <mem_init+0x5f6>
		--nfree;
f0101b1a:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b1d:	8b 00                	mov    (%eax),%eax
f0101b1f:	85 c0                	test   %eax,%eax
f0101b21:	75 f7                	jne    f0101b1a <mem_init+0x5f1>
	assert(nfree == 0);
f0101b23:	85 db                	test   %ebx,%ebx
f0101b25:	74 24                	je     f0101b4b <mem_init+0x622>
f0101b27:	c7 44 24 0c 82 7b 10 	movl   $0xf0107b82,0xc(%esp)
f0101b2e:	f0 
f0101b2f:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101b36:	f0 
f0101b37:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
f0101b3e:	00 
f0101b3f:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101b46:	e8 f5 e4 ff ff       	call   f0100040 <_panic>
	cprintf("check_page_alloc() succeeded!\n");
f0101b4b:	c7 04 24 38 72 10 f0 	movl   $0xf0107238,(%esp)
f0101b52:	e8 76 23 00 00       	call   f0103ecd <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101b57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b5e:	e8 ad f5 ff ff       	call   f0101110 <page_alloc>
f0101b63:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101b66:	85 c0                	test   %eax,%eax
f0101b68:	75 24                	jne    f0101b8e <mem_init+0x665>
f0101b6a:	c7 44 24 0c e7 7a 10 	movl   $0xf0107ae7,0xc(%esp)
f0101b71:	f0 
f0101b72:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101b79:	f0 
f0101b7a:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f0101b81:	00 
f0101b82:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101b89:	e8 b2 e4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b8e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b95:	e8 76 f5 ff ff       	call   f0101110 <page_alloc>
f0101b9a:	89 c3                	mov    %eax,%ebx
f0101b9c:	85 c0                	test   %eax,%eax
f0101b9e:	75 24                	jne    f0101bc4 <mem_init+0x69b>
f0101ba0:	c7 44 24 0c fd 7a 10 	movl   $0xf0107afd,0xc(%esp)
f0101ba7:	f0 
f0101ba8:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101baf:	f0 
f0101bb0:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f0101bb7:	00 
f0101bb8:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101bbf:	e8 7c e4 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101bc4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bcb:	e8 40 f5 ff ff       	call   f0101110 <page_alloc>
f0101bd0:	89 c6                	mov    %eax,%esi
f0101bd2:	85 c0                	test   %eax,%eax
f0101bd4:	75 24                	jne    f0101bfa <mem_init+0x6d1>
f0101bd6:	c7 44 24 0c 13 7b 10 	movl   $0xf0107b13,0xc(%esp)
f0101bdd:	f0 
f0101bde:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101be5:	f0 
f0101be6:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0101bed:	00 
f0101bee:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101bf5:	e8 46 e4 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101bfa:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101bfd:	75 24                	jne    f0101c23 <mem_init+0x6fa>
f0101bff:	c7 44 24 0c 29 7b 10 	movl   $0xf0107b29,0xc(%esp)
f0101c06:	f0 
f0101c07:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101c0e:	f0 
f0101c0f:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f0101c16:	00 
f0101c17:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101c1e:	e8 1d e4 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c23:	39 c3                	cmp    %eax,%ebx
f0101c25:	74 05                	je     f0101c2c <mem_init+0x703>
f0101c27:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101c2a:	75 24                	jne    f0101c50 <mem_init+0x727>
f0101c2c:	c7 44 24 0c b8 71 10 	movl   $0xf01071b8,0xc(%esp)
f0101c33:	f0 
f0101c34:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101c3b:	f0 
f0101c3c:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
f0101c43:	00 
f0101c44:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101c4b:	e8 f0 e3 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101c50:	a1 40 72 1e f0       	mov    0xf01e7240,%eax
f0101c55:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101c58:	c7 05 40 72 1e f0 00 	movl   $0x0,0xf01e7240
f0101c5f:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101c62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c69:	e8 a2 f4 ff ff       	call   f0101110 <page_alloc>
f0101c6e:	85 c0                	test   %eax,%eax
f0101c70:	74 24                	je     f0101c96 <mem_init+0x76d>
f0101c72:	c7 44 24 0c 3b 7b 10 	movl   $0xf0107b3b,0xc(%esp)
f0101c79:	f0 
f0101c7a:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101c81:	f0 
f0101c82:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f0101c89:	00 
f0101c8a:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101c91:	e8 aa e3 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *)0x0, &ptep) == NULL);
f0101c96:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101c99:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101c9d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101ca4:	00 
f0101ca5:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0101caa:	89 04 24             	mov    %eax,(%esp)
f0101cad:	e8 41 f6 ff ff       	call   f01012f3 <page_lookup>
f0101cb2:	85 c0                	test   %eax,%eax
f0101cb4:	74 24                	je     f0101cda <mem_init+0x7b1>
f0101cb6:	c7 44 24 0c 58 72 10 	movl   $0xf0107258,0xc(%esp)
f0101cbd:	f0 
f0101cbe:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101cc5:	f0 
f0101cc6:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f0101ccd:	00 
f0101cce:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101cd5:	e8 66 e3 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101cda:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ce1:	00 
f0101ce2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ce9:	00 
f0101cea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101cee:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0101cf3:	89 04 24             	mov    %eax,(%esp)
f0101cf6:	e8 47 f7 ff ff       	call   f0101442 <page_insert>
f0101cfb:	85 c0                	test   %eax,%eax
f0101cfd:	78 24                	js     f0101d23 <mem_init+0x7fa>
f0101cff:	c7 44 24 0c 8c 72 10 	movl   $0xf010728c,0xc(%esp)
f0101d06:	f0 
f0101d07:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101d0e:	f0 
f0101d0f:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f0101d16:	00 
f0101d17:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101d1e:	e8 1d e3 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101d23:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d26:	89 04 24             	mov    %eax,(%esp)
f0101d29:	e8 73 f4 ff ff       	call   f01011a1 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101d2e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d35:	00 
f0101d36:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d3d:	00 
f0101d3e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d42:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0101d47:	89 04 24             	mov    %eax,(%esp)
f0101d4a:	e8 f3 f6 ff ff       	call   f0101442 <page_insert>
f0101d4f:	85 c0                	test   %eax,%eax
f0101d51:	74 24                	je     f0101d77 <mem_init+0x84e>
f0101d53:	c7 44 24 0c bc 72 10 	movl   $0xf01072bc,0xc(%esp)
f0101d5a:	f0 
f0101d5b:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101d62:	f0 
f0101d63:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f0101d6a:	00 
f0101d6b:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101d72:	e8 c9 e2 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d77:	8b 3d 8c 7e 1e f0    	mov    0xf01e7e8c,%edi
	return (pp - pages) << PGSHIFT;
f0101d7d:	a1 90 7e 1e f0       	mov    0xf01e7e90,%eax
f0101d82:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101d85:	8b 17                	mov    (%edi),%edx
f0101d87:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101d8d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101d90:	29 c1                	sub    %eax,%ecx
f0101d92:	89 c8                	mov    %ecx,%eax
f0101d94:	c1 f8 03             	sar    $0x3,%eax
f0101d97:	c1 e0 0c             	shl    $0xc,%eax
f0101d9a:	39 c2                	cmp    %eax,%edx
f0101d9c:	74 24                	je     f0101dc2 <mem_init+0x899>
f0101d9e:	c7 44 24 0c ec 72 10 	movl   $0xf01072ec,0xc(%esp)
f0101da5:	f0 
f0101da6:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101dad:	f0 
f0101dae:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f0101db5:	00 
f0101db6:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101dbd:	e8 7e e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101dc2:	ba 00 00 00 00       	mov    $0x0,%edx
f0101dc7:	89 f8                	mov    %edi,%eax
f0101dc9:	e8 2d ee ff ff       	call   f0100bfb <check_va2pa>
f0101dce:	89 da                	mov    %ebx,%edx
f0101dd0:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101dd3:	c1 fa 03             	sar    $0x3,%edx
f0101dd6:	c1 e2 0c             	shl    $0xc,%edx
f0101dd9:	39 d0                	cmp    %edx,%eax
f0101ddb:	74 24                	je     f0101e01 <mem_init+0x8d8>
f0101ddd:	c7 44 24 0c 14 73 10 	movl   $0xf0107314,0xc(%esp)
f0101de4:	f0 
f0101de5:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101dec:	f0 
f0101ded:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f0101df4:	00 
f0101df5:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101dfc:	e8 3f e2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101e01:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e06:	74 24                	je     f0101e2c <mem_init+0x903>
f0101e08:	c7 44 24 0c 8d 7b 10 	movl   $0xf0107b8d,0xc(%esp)
f0101e0f:	f0 
f0101e10:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101e17:	f0 
f0101e18:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f0101e1f:	00 
f0101e20:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101e27:	e8 14 e2 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101e2c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e2f:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e34:	74 24                	je     f0101e5a <mem_init+0x931>
f0101e36:	c7 44 24 0c 9e 7b 10 	movl   $0xf0107b9e,0xc(%esp)
f0101e3d:	f0 
f0101e3e:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101e45:	f0 
f0101e46:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f0101e4d:	00 
f0101e4e:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101e55:	e8 e6 e1 ff ff       	call   f0100040 <_panic>
	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101e5a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e61:	00 
f0101e62:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e69:	00 
f0101e6a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101e6e:	89 3c 24             	mov    %edi,(%esp)
f0101e71:	e8 cc f5 ff ff       	call   f0101442 <page_insert>
f0101e76:	85 c0                	test   %eax,%eax
f0101e78:	74 24                	je     f0101e9e <mem_init+0x975>
f0101e7a:	c7 44 24 0c 44 73 10 	movl   $0xf0107344,0xc(%esp)
f0101e81:	f0 
f0101e82:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101e89:	f0 
f0101e8a:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f0101e91:	00 
f0101e92:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101e99:	e8 a2 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e9e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ea3:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0101ea8:	e8 4e ed ff ff       	call   f0100bfb <check_va2pa>
f0101ead:	89 f2                	mov    %esi,%edx
f0101eaf:	2b 15 90 7e 1e f0    	sub    0xf01e7e90,%edx
f0101eb5:	c1 fa 03             	sar    $0x3,%edx
f0101eb8:	c1 e2 0c             	shl    $0xc,%edx
f0101ebb:	39 d0                	cmp    %edx,%eax
f0101ebd:	74 24                	je     f0101ee3 <mem_init+0x9ba>
f0101ebf:	c7 44 24 0c 80 73 10 	movl   $0xf0107380,0xc(%esp)
f0101ec6:	f0 
f0101ec7:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101ece:	f0 
f0101ecf:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f0101ed6:	00 
f0101ed7:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101ede:	e8 5d e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ee3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ee8:	74 24                	je     f0101f0e <mem_init+0x9e5>
f0101eea:	c7 44 24 0c af 7b 10 	movl   $0xf0107baf,0xc(%esp)
f0101ef1:	f0 
f0101ef2:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101ef9:	f0 
f0101efa:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0101f01:	00 
f0101f02:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101f09:	e8 32 e1 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f0e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f15:	e8 f6 f1 ff ff       	call   f0101110 <page_alloc>
f0101f1a:	85 c0                	test   %eax,%eax
f0101f1c:	74 24                	je     f0101f42 <mem_init+0xa19>
f0101f1e:	c7 44 24 0c 3b 7b 10 	movl   $0xf0107b3b,0xc(%esp)
f0101f25:	f0 
f0101f26:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101f2d:	f0 
f0101f2e:	c7 44 24 04 56 03 00 	movl   $0x356,0x4(%esp)
f0101f35:	00 
f0101f36:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101f3d:	e8 fe e0 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101f42:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f49:	00 
f0101f4a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f51:	00 
f0101f52:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101f56:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0101f5b:	89 04 24             	mov    %eax,(%esp)
f0101f5e:	e8 df f4 ff ff       	call   f0101442 <page_insert>
f0101f63:	85 c0                	test   %eax,%eax
f0101f65:	74 24                	je     f0101f8b <mem_init+0xa62>
f0101f67:	c7 44 24 0c 44 73 10 	movl   $0xf0107344,0xc(%esp)
f0101f6e:	f0 
f0101f6f:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101f76:	f0 
f0101f77:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f0101f7e:	00 
f0101f7f:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101f86:	e8 b5 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f8b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f90:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0101f95:	e8 61 ec ff ff       	call   f0100bfb <check_va2pa>
f0101f9a:	89 f2                	mov    %esi,%edx
f0101f9c:	2b 15 90 7e 1e f0    	sub    0xf01e7e90,%edx
f0101fa2:	c1 fa 03             	sar    $0x3,%edx
f0101fa5:	c1 e2 0c             	shl    $0xc,%edx
f0101fa8:	39 d0                	cmp    %edx,%eax
f0101faa:	74 24                	je     f0101fd0 <mem_init+0xaa7>
f0101fac:	c7 44 24 0c 80 73 10 	movl   $0xf0107380,0xc(%esp)
f0101fb3:	f0 
f0101fb4:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101fbb:	f0 
f0101fbc:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f0101fc3:	00 
f0101fc4:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101fcb:	e8 70 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101fd0:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101fd5:	74 24                	je     f0101ffb <mem_init+0xad2>
f0101fd7:	c7 44 24 0c af 7b 10 	movl   $0xf0107baf,0xc(%esp)
f0101fde:	f0 
f0101fdf:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0101fe6:	f0 
f0101fe7:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f0101fee:	00 
f0101fef:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0101ff6:	e8 45 e0 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ffb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102002:	e8 09 f1 ff ff       	call   f0101110 <page_alloc>
f0102007:	85 c0                	test   %eax,%eax
f0102009:	74 24                	je     f010202f <mem_init+0xb06>
f010200b:	c7 44 24 0c 3b 7b 10 	movl   $0xf0107b3b,0xc(%esp)
f0102012:	f0 
f0102013:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f010201a:	f0 
f010201b:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0102022:	00 
f0102023:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f010202a:	e8 11 e0 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010202f:	8b 15 8c 7e 1e f0    	mov    0xf01e7e8c,%edx
f0102035:	8b 02                	mov    (%edx),%eax
f0102037:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010203c:	89 c1                	mov    %eax,%ecx
f010203e:	c1 e9 0c             	shr    $0xc,%ecx
f0102041:	3b 0d 88 7e 1e f0    	cmp    0xf01e7e88,%ecx
f0102047:	72 20                	jb     f0102069 <mem_init+0xb40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102049:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010204d:	c7 44 24 08 a4 6a 10 	movl   $0xf0106aa4,0x8(%esp)
f0102054:	f0 
f0102055:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
f010205c:	00 
f010205d:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102064:	e8 d7 df ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102069:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010206e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
f0102071:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102078:	00 
f0102079:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102080:	00 
f0102081:	89 14 24             	mov    %edx,(%esp)
f0102084:	e8 7b f1 ff ff       	call   f0101204 <pgdir_walk>
f0102089:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010208c:	8d 51 04             	lea    0x4(%ecx),%edx
f010208f:	39 d0                	cmp    %edx,%eax
f0102091:	74 24                	je     f01020b7 <mem_init+0xb8e>
f0102093:	c7 44 24 0c b0 73 10 	movl   $0xf01073b0,0xc(%esp)
f010209a:	f0 
f010209b:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01020a2:	f0 
f01020a3:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f01020aa:	00 
f01020ab:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01020b2:	e8 89 df ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W | PTE_U) == 0);
f01020b7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01020be:	00 
f01020bf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01020c6:	00 
f01020c7:	89 74 24 04          	mov    %esi,0x4(%esp)
f01020cb:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f01020d0:	89 04 24             	mov    %eax,(%esp)
f01020d3:	e8 6a f3 ff ff       	call   f0101442 <page_insert>
f01020d8:	85 c0                	test   %eax,%eax
f01020da:	74 24                	je     f0102100 <mem_init+0xbd7>
f01020dc:	c7 44 24 0c f0 73 10 	movl   $0xf01073f0,0xc(%esp)
f01020e3:	f0 
f01020e4:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01020eb:	f0 
f01020ec:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f01020f3:	00 
f01020f4:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01020fb:	e8 40 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102100:	8b 3d 8c 7e 1e f0    	mov    0xf01e7e8c,%edi
f0102106:	ba 00 10 00 00       	mov    $0x1000,%edx
f010210b:	89 f8                	mov    %edi,%eax
f010210d:	e8 e9 ea ff ff       	call   f0100bfb <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0102112:	89 f2                	mov    %esi,%edx
f0102114:	2b 15 90 7e 1e f0    	sub    0xf01e7e90,%edx
f010211a:	c1 fa 03             	sar    $0x3,%edx
f010211d:	c1 e2 0c             	shl    $0xc,%edx
f0102120:	39 d0                	cmp    %edx,%eax
f0102122:	74 24                	je     f0102148 <mem_init+0xc1f>
f0102124:	c7 44 24 0c 80 73 10 	movl   $0xf0107380,0xc(%esp)
f010212b:	f0 
f010212c:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102133:	f0 
f0102134:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f010213b:	00 
f010213c:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102143:	e8 f8 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102148:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010214d:	74 24                	je     f0102173 <mem_init+0xc4a>
f010214f:	c7 44 24 0c af 7b 10 	movl   $0xf0107baf,0xc(%esp)
f0102156:	f0 
f0102157:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f010215e:	f0 
f010215f:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102166:	00 
f0102167:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f010216e:	e8 cd de ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U);
f0102173:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010217a:	00 
f010217b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102182:	00 
f0102183:	89 3c 24             	mov    %edi,(%esp)
f0102186:	e8 79 f0 ff ff       	call   f0101204 <pgdir_walk>
f010218b:	f6 00 04             	testb  $0x4,(%eax)
f010218e:	75 24                	jne    f01021b4 <mem_init+0xc8b>
f0102190:	c7 44 24 0c 34 74 10 	movl   $0xf0107434,0xc(%esp)
f0102197:	f0 
f0102198:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f010219f:	f0 
f01021a0:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f01021a7:	00 
f01021a8:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01021af:	e8 8c de ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01021b4:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f01021b9:	f6 00 04             	testb  $0x4,(%eax)
f01021bc:	75 24                	jne    f01021e2 <mem_init+0xcb9>
f01021be:	c7 44 24 0c c0 7b 10 	movl   $0xf0107bc0,0xc(%esp)
f01021c5:	f0 
f01021c6:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01021cd:	f0 
f01021ce:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f01021d5:	00 
f01021d6:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01021dd:	e8 5e de ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f01021e2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01021e9:	00 
f01021ea:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01021f1:	00 
f01021f2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01021f6:	89 04 24             	mov    %eax,(%esp)
f01021f9:	e8 44 f2 ff ff       	call   f0101442 <page_insert>
f01021fe:	85 c0                	test   %eax,%eax
f0102200:	74 24                	je     f0102226 <mem_init+0xcfd>
f0102202:	c7 44 24 0c 44 73 10 	movl   $0xf0107344,0xc(%esp)
f0102209:	f0 
f010220a:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102211:	f0 
f0102212:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0102219:	00 
f010221a:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102221:	e8 1a de ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_W);
f0102226:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010222d:	00 
f010222e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102235:	00 
f0102236:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f010223b:	89 04 24             	mov    %eax,(%esp)
f010223e:	e8 c1 ef ff ff       	call   f0101204 <pgdir_walk>
f0102243:	f6 00 02             	testb  $0x2,(%eax)
f0102246:	75 24                	jne    f010226c <mem_init+0xd43>
f0102248:	c7 44 24 0c 68 74 10 	movl   $0xf0107468,0xc(%esp)
f010224f:	f0 
f0102250:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102257:	f0 
f0102258:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f010225f:	00 
f0102260:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102267:	e8 d4 dd ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f010226c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102273:	00 
f0102274:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010227b:	00 
f010227c:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0102281:	89 04 24             	mov    %eax,(%esp)
f0102284:	e8 7b ef ff ff       	call   f0101204 <pgdir_walk>
f0102289:	f6 00 04             	testb  $0x4,(%eax)
f010228c:	74 24                	je     f01022b2 <mem_init+0xd89>
f010228e:	c7 44 24 0c 9c 74 10 	movl   $0xf010749c,0xc(%esp)
f0102295:	f0 
f0102296:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f010229d:	f0 
f010229e:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f01022a5:	00 
f01022a6:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01022ad:	e8 8e dd ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void *)PTSIZE, PTE_W) < 0);
f01022b2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01022b9:	00 
f01022ba:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01022c1:	00 
f01022c2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022c9:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f01022ce:	89 04 24             	mov    %eax,(%esp)
f01022d1:	e8 6c f1 ff ff       	call   f0101442 <page_insert>
f01022d6:	85 c0                	test   %eax,%eax
f01022d8:	78 24                	js     f01022fe <mem_init+0xdd5>
f01022da:	c7 44 24 0c d4 74 10 	movl   $0xf01074d4,0xc(%esp)
f01022e1:	f0 
f01022e2:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01022e9:	f0 
f01022ea:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f01022f1:	00 
f01022f2:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01022f9:	e8 42 dd ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W) == 0);
f01022fe:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102305:	00 
f0102306:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010230d:	00 
f010230e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102312:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0102317:	89 04 24             	mov    %eax,(%esp)
f010231a:	e8 23 f1 ff ff       	call   f0101442 <page_insert>
f010231f:	85 c0                	test   %eax,%eax
f0102321:	74 24                	je     f0102347 <mem_init+0xe1e>
f0102323:	c7 44 24 0c 0c 75 10 	movl   $0xf010750c,0xc(%esp)
f010232a:	f0 
f010232b:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102332:	f0 
f0102333:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f010233a:	00 
f010233b:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102342:	e8 f9 dc ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0102347:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010234e:	00 
f010234f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102356:	00 
f0102357:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f010235c:	89 04 24             	mov    %eax,(%esp)
f010235f:	e8 a0 ee ff ff       	call   f0101204 <pgdir_walk>
f0102364:	f6 00 04             	testb  $0x4,(%eax)
f0102367:	74 24                	je     f010238d <mem_init+0xe64>
f0102369:	c7 44 24 0c 9c 74 10 	movl   $0xf010749c,0xc(%esp)
f0102370:	f0 
f0102371:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102378:	f0 
f0102379:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f0102380:	00 
f0102381:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102388:	e8 b3 dc ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010238d:	8b 3d 8c 7e 1e f0    	mov    0xf01e7e8c,%edi
f0102393:	ba 00 00 00 00       	mov    $0x0,%edx
f0102398:	89 f8                	mov    %edi,%eax
f010239a:	e8 5c e8 ff ff       	call   f0100bfb <check_va2pa>
f010239f:	89 c1                	mov    %eax,%ecx
f01023a1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01023a4:	89 d8                	mov    %ebx,%eax
f01023a6:	2b 05 90 7e 1e f0    	sub    0xf01e7e90,%eax
f01023ac:	c1 f8 03             	sar    $0x3,%eax
f01023af:	c1 e0 0c             	shl    $0xc,%eax
f01023b2:	39 c1                	cmp    %eax,%ecx
f01023b4:	74 24                	je     f01023da <mem_init+0xeb1>
f01023b6:	c7 44 24 0c 48 75 10 	movl   $0xf0107548,0xc(%esp)
f01023bd:	f0 
f01023be:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01023c5:	f0 
f01023c6:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f01023cd:	00 
f01023ce:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01023d5:	e8 66 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01023da:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023df:	89 f8                	mov    %edi,%eax
f01023e1:	e8 15 e8 ff ff       	call   f0100bfb <check_va2pa>
f01023e6:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01023e9:	74 24                	je     f010240f <mem_init+0xee6>
f01023eb:	c7 44 24 0c 74 75 10 	movl   $0xf0107574,0xc(%esp)
f01023f2:	f0 
f01023f3:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01023fa:	f0 
f01023fb:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0102402:	00 
f0102403:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f010240a:	e8 31 dc ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010240f:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0102414:	74 24                	je     f010243a <mem_init+0xf11>
f0102416:	c7 44 24 0c d6 7b 10 	movl   $0xf0107bd6,0xc(%esp)
f010241d:	f0 
f010241e:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102425:	f0 
f0102426:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f010242d:	00 
f010242e:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102435:	e8 06 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010243a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010243f:	74 24                	je     f0102465 <mem_init+0xf3c>
f0102441:	c7 44 24 0c e7 7b 10 	movl   $0xf0107be7,0xc(%esp)
f0102448:	f0 
f0102449:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102450:	f0 
f0102451:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0102458:	00 
f0102459:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102460:	e8 db db ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102465:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010246c:	e8 9f ec ff ff       	call   f0101110 <page_alloc>
f0102471:	85 c0                	test   %eax,%eax
f0102473:	74 04                	je     f0102479 <mem_init+0xf50>
f0102475:	39 c6                	cmp    %eax,%esi
f0102477:	74 24                	je     f010249d <mem_init+0xf74>
f0102479:	c7 44 24 0c a4 75 10 	movl   $0xf01075a4,0xc(%esp)
f0102480:	f0 
f0102481:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102488:	f0 
f0102489:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0102490:	00 
f0102491:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102498:	e8 a3 db ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010249d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01024a4:	00 
f01024a5:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f01024aa:	89 04 24             	mov    %eax,(%esp)
f01024ad:	e8 47 ef ff ff       	call   f01013f9 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01024b2:	8b 3d 8c 7e 1e f0    	mov    0xf01e7e8c,%edi
f01024b8:	ba 00 00 00 00       	mov    $0x0,%edx
f01024bd:	89 f8                	mov    %edi,%eax
f01024bf:	e8 37 e7 ff ff       	call   f0100bfb <check_va2pa>
f01024c4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024c7:	74 24                	je     f01024ed <mem_init+0xfc4>
f01024c9:	c7 44 24 0c c8 75 10 	movl   $0xf01075c8,0xc(%esp)
f01024d0:	f0 
f01024d1:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01024d8:	f0 
f01024d9:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f01024e0:	00 
f01024e1:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01024e8:	e8 53 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01024ed:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024f2:	89 f8                	mov    %edi,%eax
f01024f4:	e8 02 e7 ff ff       	call   f0100bfb <check_va2pa>
f01024f9:	89 da                	mov    %ebx,%edx
f01024fb:	2b 15 90 7e 1e f0    	sub    0xf01e7e90,%edx
f0102501:	c1 fa 03             	sar    $0x3,%edx
f0102504:	c1 e2 0c             	shl    $0xc,%edx
f0102507:	39 d0                	cmp    %edx,%eax
f0102509:	74 24                	je     f010252f <mem_init+0x1006>
f010250b:	c7 44 24 0c 74 75 10 	movl   $0xf0107574,0xc(%esp)
f0102512:	f0 
f0102513:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f010251a:	f0 
f010251b:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0102522:	00 
f0102523:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f010252a:	e8 11 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010252f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102534:	74 24                	je     f010255a <mem_init+0x1031>
f0102536:	c7 44 24 0c 8d 7b 10 	movl   $0xf0107b8d,0xc(%esp)
f010253d:	f0 
f010253e:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102545:	f0 
f0102546:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f010254d:	00 
f010254e:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102555:	e8 e6 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010255a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010255f:	74 24                	je     f0102585 <mem_init+0x105c>
f0102561:	c7 44 24 0c e7 7b 10 	movl   $0xf0107be7,0xc(%esp)
f0102568:	f0 
f0102569:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102570:	f0 
f0102571:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0102578:	00 
f0102579:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102580:	e8 bb da ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, 0) == 0);
f0102585:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010258c:	00 
f010258d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102594:	00 
f0102595:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102599:	89 3c 24             	mov    %edi,(%esp)
f010259c:	e8 a1 ee ff ff       	call   f0101442 <page_insert>
f01025a1:	85 c0                	test   %eax,%eax
f01025a3:	74 24                	je     f01025c9 <mem_init+0x10a0>
f01025a5:	c7 44 24 0c ec 75 10 	movl   $0xf01075ec,0xc(%esp)
f01025ac:	f0 
f01025ad:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01025b4:	f0 
f01025b5:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
f01025bc:	00 
f01025bd:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01025c4:	e8 77 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01025c9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01025ce:	75 24                	jne    f01025f4 <mem_init+0x10cb>
f01025d0:	c7 44 24 0c f8 7b 10 	movl   $0xf0107bf8,0xc(%esp)
f01025d7:	f0 
f01025d8:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01025df:	f0 
f01025e0:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f01025e7:	00 
f01025e8:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01025ef:	e8 4c da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01025f4:	83 3b 00             	cmpl   $0x0,(%ebx)
f01025f7:	74 24                	je     f010261d <mem_init+0x10f4>
f01025f9:	c7 44 24 0c 04 7c 10 	movl   $0xf0107c04,0xc(%esp)
f0102600:	f0 
f0102601:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102608:	f0 
f0102609:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f0102610:	00 
f0102611:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102618:	e8 23 da ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void *)PGSIZE);
f010261d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102624:	00 
f0102625:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f010262a:	89 04 24             	mov    %eax,(%esp)
f010262d:	e8 c7 ed ff ff       	call   f01013f9 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102632:	8b 3d 8c 7e 1e f0    	mov    0xf01e7e8c,%edi
f0102638:	ba 00 00 00 00       	mov    $0x0,%edx
f010263d:	89 f8                	mov    %edi,%eax
f010263f:	e8 b7 e5 ff ff       	call   f0100bfb <check_va2pa>
f0102644:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102647:	74 24                	je     f010266d <mem_init+0x1144>
f0102649:	c7 44 24 0c c8 75 10 	movl   $0xf01075c8,0xc(%esp)
f0102650:	f0 
f0102651:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102658:	f0 
f0102659:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0102660:	00 
f0102661:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102668:	e8 d3 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010266d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102672:	89 f8                	mov    %edi,%eax
f0102674:	e8 82 e5 ff ff       	call   f0100bfb <check_va2pa>
f0102679:	83 f8 ff             	cmp    $0xffffffff,%eax
f010267c:	74 24                	je     f01026a2 <mem_init+0x1179>
f010267e:	c7 44 24 0c 24 76 10 	movl   $0xf0107624,0xc(%esp)
f0102685:	f0 
f0102686:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f010268d:	f0 
f010268e:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0102695:	00 
f0102696:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f010269d:	e8 9e d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01026a2:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01026a7:	74 24                	je     f01026cd <mem_init+0x11a4>
f01026a9:	c7 44 24 0c 19 7c 10 	movl   $0xf0107c19,0xc(%esp)
f01026b0:	f0 
f01026b1:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01026b8:	f0 
f01026b9:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f01026c0:	00 
f01026c1:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01026c8:	e8 73 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01026cd:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01026d2:	74 24                	je     f01026f8 <mem_init+0x11cf>
f01026d4:	c7 44 24 0c e7 7b 10 	movl   $0xf0107be7,0xc(%esp)
f01026db:	f0 
f01026dc:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01026e3:	f0 
f01026e4:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f01026eb:	00 
f01026ec:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01026f3:	e8 48 d9 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01026f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01026ff:	e8 0c ea ff ff       	call   f0101110 <page_alloc>
f0102704:	85 c0                	test   %eax,%eax
f0102706:	74 04                	je     f010270c <mem_init+0x11e3>
f0102708:	39 c3                	cmp    %eax,%ebx
f010270a:	74 24                	je     f0102730 <mem_init+0x1207>
f010270c:	c7 44 24 0c 4c 76 10 	movl   $0xf010764c,0xc(%esp)
f0102713:	f0 
f0102714:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f010271b:	f0 
f010271c:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0102723:	00 
f0102724:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f010272b:	e8 10 d9 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102730:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102737:	e8 d4 e9 ff ff       	call   f0101110 <page_alloc>
f010273c:	85 c0                	test   %eax,%eax
f010273e:	74 24                	je     f0102764 <mem_init+0x123b>
f0102740:	c7 44 24 0c 3b 7b 10 	movl   $0xf0107b3b,0xc(%esp)
f0102747:	f0 
f0102748:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f010274f:	f0 
f0102750:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f0102757:	00 
f0102758:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f010275f:	e8 dc d8 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102764:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0102769:	8b 08                	mov    (%eax),%ecx
f010276b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102771:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102774:	2b 15 90 7e 1e f0    	sub    0xf01e7e90,%edx
f010277a:	c1 fa 03             	sar    $0x3,%edx
f010277d:	c1 e2 0c             	shl    $0xc,%edx
f0102780:	39 d1                	cmp    %edx,%ecx
f0102782:	74 24                	je     f01027a8 <mem_init+0x127f>
f0102784:	c7 44 24 0c ec 72 10 	movl   $0xf01072ec,0xc(%esp)
f010278b:	f0 
f010278c:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102793:	f0 
f0102794:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f010279b:	00 
f010279c:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01027a3:	e8 98 d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01027a8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01027ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01027b1:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01027b6:	74 24                	je     f01027dc <mem_init+0x12b3>
f01027b8:	c7 44 24 0c 9e 7b 10 	movl   $0xf0107b9e,0xc(%esp)
f01027bf:	f0 
f01027c0:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01027c7:	f0 
f01027c8:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f01027cf:	00 
f01027d0:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01027d7:	e8 64 d8 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01027dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01027df:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01027e5:	89 04 24             	mov    %eax,(%esp)
f01027e8:	e8 b4 e9 ff ff       	call   f01011a1 <page_free>
	va = (void *)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01027ed:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01027f4:	00 
f01027f5:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01027fc:	00 
f01027fd:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0102802:	89 04 24             	mov    %eax,(%esp)
f0102805:	e8 fa e9 ff ff       	call   f0101204 <pgdir_walk>
f010280a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010280d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102810:	8b 15 8c 7e 1e f0    	mov    0xf01e7e8c,%edx
f0102816:	8b 7a 04             	mov    0x4(%edx),%edi
f0102819:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f010281f:	8b 0d 88 7e 1e f0    	mov    0xf01e7e88,%ecx
f0102825:	89 f8                	mov    %edi,%eax
f0102827:	c1 e8 0c             	shr    $0xc,%eax
f010282a:	39 c8                	cmp    %ecx,%eax
f010282c:	72 20                	jb     f010284e <mem_init+0x1325>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010282e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102832:	c7 44 24 08 a4 6a 10 	movl   $0xf0106aa4,0x8(%esp)
f0102839:	f0 
f010283a:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f0102841:	00 
f0102842:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102849:	e8 f2 d7 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010284e:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0102854:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0102857:	74 24                	je     f010287d <mem_init+0x1354>
f0102859:	c7 44 24 0c 2a 7c 10 	movl   $0xf0107c2a,0xc(%esp)
f0102860:	f0 
f0102861:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102868:	f0 
f0102869:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0102870:	00 
f0102871:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102878:	e8 c3 d7 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010287d:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f0102884:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102887:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f010288d:	2b 05 90 7e 1e f0    	sub    0xf01e7e90,%eax
f0102893:	c1 f8 03             	sar    $0x3,%eax
f0102896:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102899:	89 c2                	mov    %eax,%edx
f010289b:	c1 ea 0c             	shr    $0xc,%edx
f010289e:	39 d1                	cmp    %edx,%ecx
f01028a0:	77 20                	ja     f01028c2 <mem_init+0x1399>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01028a6:	c7 44 24 08 a4 6a 10 	movl   $0xf0106aa4,0x8(%esp)
f01028ad:	f0 
f01028ae:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01028b5:	00 
f01028b6:	c7 04 24 05 7a 10 f0 	movl   $0xf0107a05,(%esp)
f01028bd:	e8 7e d7 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01028c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01028c9:	00 
f01028ca:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01028d1:	00 
	return (void *)(pa + KERNBASE);
f01028d2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01028d7:	89 04 24             	mov    %eax,(%esp)
f01028da:	e8 68 34 00 00       	call   f0105d47 <memset>
	page_free(pp0);
f01028df:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01028e2:	89 3c 24             	mov    %edi,(%esp)
f01028e5:	e8 b7 e8 ff ff       	call   f01011a1 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01028ea:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01028f1:	00 
f01028f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01028f9:	00 
f01028fa:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f01028ff:	89 04 24             	mov    %eax,(%esp)
f0102902:	e8 fd e8 ff ff       	call   f0101204 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0102907:	89 fa                	mov    %edi,%edx
f0102909:	2b 15 90 7e 1e f0    	sub    0xf01e7e90,%edx
f010290f:	c1 fa 03             	sar    $0x3,%edx
f0102912:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102915:	89 d0                	mov    %edx,%eax
f0102917:	c1 e8 0c             	shr    $0xc,%eax
f010291a:	3b 05 88 7e 1e f0    	cmp    0xf01e7e88,%eax
f0102920:	72 20                	jb     f0102942 <mem_init+0x1419>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102922:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102926:	c7 44 24 08 a4 6a 10 	movl   $0xf0106aa4,0x8(%esp)
f010292d:	f0 
f010292e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102935:	00 
f0102936:	c7 04 24 05 7a 10 f0 	movl   $0xf0107a05,(%esp)
f010293d:	e8 fe d6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102942:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *)page2kva(pp0);
f0102948:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010294b:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for (i = 0; i < NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102951:	f6 00 01             	testb  $0x1,(%eax)
f0102954:	74 24                	je     f010297a <mem_init+0x1451>
f0102956:	c7 44 24 0c 42 7c 10 	movl   $0xf0107c42,0xc(%esp)
f010295d:	f0 
f010295e:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102965:	f0 
f0102966:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f010296d:	00 
f010296e:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102975:	e8 c6 d6 ff ff       	call   f0100040 <_panic>
f010297a:	83 c0 04             	add    $0x4,%eax
	for (i = 0; i < NPTENTRIES; i++)
f010297d:	39 d0                	cmp    %edx,%eax
f010297f:	75 d0                	jne    f0102951 <mem_init+0x1428>
	kern_pgdir[0] = 0;
f0102981:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0102986:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010298c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010298f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102995:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102998:	89 0d 40 72 1e f0    	mov    %ecx,0xf01e7240

	// free the pages we took
	page_free(pp0);
f010299e:	89 04 24             	mov    %eax,(%esp)
f01029a1:	e8 fb e7 ff ff       	call   f01011a1 <page_free>
	page_free(pp1);
f01029a6:	89 1c 24             	mov    %ebx,(%esp)
f01029a9:	e8 f3 e7 ff ff       	call   f01011a1 <page_free>
	page_free(pp2);
f01029ae:	89 34 24             	mov    %esi,(%esp)
f01029b1:	e8 eb e7 ff ff       	call   f01011a1 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t)mmio_map_region(0, 4097);
f01029b6:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f01029bd:	00 
f01029be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029c5:	e8 f0 ea ff ff       	call   f01014ba <mmio_map_region>
f01029ca:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t)mmio_map_region(0, 4096);
f01029cc:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01029d3:	00 
f01029d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029db:	e8 da ea ff ff       	call   f01014ba <mmio_map_region>
f01029e0:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01029e2:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01029e8:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01029ed:	77 08                	ja     f01029f7 <mem_init+0x14ce>
f01029ef:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01029f5:	77 24                	ja     f0102a1b <mem_init+0x14f2>
f01029f7:	c7 44 24 0c 70 76 10 	movl   $0xf0107670,0xc(%esp)
f01029fe:	f0 
f01029ff:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102a06:	f0 
f0102a07:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0102a0e:	00 
f0102a0f:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102a16:	e8 25 d6 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102a1b:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102a21:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102a27:	77 08                	ja     f0102a31 <mem_init+0x1508>
f0102a29:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102a2f:	77 24                	ja     f0102a55 <mem_init+0x152c>
f0102a31:	c7 44 24 0c 98 76 10 	movl   $0xf0107698,0xc(%esp)
f0102a38:	f0 
f0102a39:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102a40:	f0 
f0102a41:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f0102a48:	00 
f0102a49:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102a50:	e8 eb d5 ff ff       	call   f0100040 <_panic>
f0102a55:	89 da                	mov    %ebx,%edx
f0102a57:	09 f2                	or     %esi,%edx
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102a59:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102a5f:	74 24                	je     f0102a85 <mem_init+0x155c>
f0102a61:	c7 44 24 0c c0 76 10 	movl   $0xf01076c0,0xc(%esp)
f0102a68:	f0 
f0102a69:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102a70:	f0 
f0102a71:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0102a78:	00 
f0102a79:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102a80:	e8 bb d5 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102a85:	39 c6                	cmp    %eax,%esi
f0102a87:	73 24                	jae    f0102aad <mem_init+0x1584>
f0102a89:	c7 44 24 0c 59 7c 10 	movl   $0xf0107c59,0xc(%esp)
f0102a90:	f0 
f0102a91:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102a98:	f0 
f0102a99:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f0102aa0:	00 
f0102aa1:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102aa8:	e8 93 d5 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102aad:	8b 3d 8c 7e 1e f0    	mov    0xf01e7e8c,%edi
f0102ab3:	89 da                	mov    %ebx,%edx
f0102ab5:	89 f8                	mov    %edi,%eax
f0102ab7:	e8 3f e1 ff ff       	call   f0100bfb <check_va2pa>
f0102abc:	85 c0                	test   %eax,%eax
f0102abe:	74 24                	je     f0102ae4 <mem_init+0x15bb>
f0102ac0:	c7 44 24 0c e8 76 10 	movl   $0xf01076e8,0xc(%esp)
f0102ac7:	f0 
f0102ac8:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102acf:	f0 
f0102ad0:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0102ad7:	00 
f0102ad8:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102adf:	e8 5c d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1 + PGSIZE) == PGSIZE);
f0102ae4:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102aea:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102aed:	89 c2                	mov    %eax,%edx
f0102aef:	89 f8                	mov    %edi,%eax
f0102af1:	e8 05 e1 ff ff       	call   f0100bfb <check_va2pa>
f0102af6:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102afb:	74 24                	je     f0102b21 <mem_init+0x15f8>
f0102afd:	c7 44 24 0c 0c 77 10 	movl   $0xf010770c,0xc(%esp)
f0102b04:	f0 
f0102b05:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102b0c:	f0 
f0102b0d:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0102b14:	00 
f0102b15:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102b1c:	e8 1f d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102b21:	89 f2                	mov    %esi,%edx
f0102b23:	89 f8                	mov    %edi,%eax
f0102b25:	e8 d1 e0 ff ff       	call   f0100bfb <check_va2pa>
f0102b2a:	85 c0                	test   %eax,%eax
f0102b2c:	74 24                	je     f0102b52 <mem_init+0x1629>
f0102b2e:	c7 44 24 0c 3c 77 10 	movl   $0xf010773c,0xc(%esp)
f0102b35:	f0 
f0102b36:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102b3d:	f0 
f0102b3e:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f0102b45:	00 
f0102b46:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102b4d:	e8 ee d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2 + PGSIZE) == ~0);
f0102b52:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102b58:	89 f8                	mov    %edi,%eax
f0102b5a:	e8 9c e0 ff ff       	call   f0100bfb <check_va2pa>
f0102b5f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b62:	74 24                	je     f0102b88 <mem_init+0x165f>
f0102b64:	c7 44 24 0c 60 77 10 	movl   $0xf0107760,0xc(%esp)
f0102b6b:	f0 
f0102b6c:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102b73:	f0 
f0102b74:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f0102b7b:	00 
f0102b7c:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102b83:	e8 b8 d4 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void *)mm1, 0) & (PTE_W | PTE_PWT | PTE_PCD));
f0102b88:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b8f:	00 
f0102b90:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b94:	89 3c 24             	mov    %edi,(%esp)
f0102b97:	e8 68 e6 ff ff       	call   f0101204 <pgdir_walk>
f0102b9c:	f6 00 1a             	testb  $0x1a,(%eax)
f0102b9f:	75 24                	jne    f0102bc5 <mem_init+0x169c>
f0102ba1:	c7 44 24 0c 8c 77 10 	movl   $0xf010778c,0xc(%esp)
f0102ba8:	f0 
f0102ba9:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102bb0:	f0 
f0102bb1:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0102bb8:	00 
f0102bb9:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102bc0:	e8 7b d4 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *)mm1, 0) & PTE_U));
f0102bc5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102bcc:	00 
f0102bcd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102bd1:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0102bd6:	89 04 24             	mov    %eax,(%esp)
f0102bd9:	e8 26 e6 ff ff       	call   f0101204 <pgdir_walk>
f0102bde:	f6 00 04             	testb  $0x4,(%eax)
f0102be1:	74 24                	je     f0102c07 <mem_init+0x16de>
f0102be3:	c7 44 24 0c d4 77 10 	movl   $0xf01077d4,0xc(%esp)
f0102bea:	f0 
f0102beb:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102bf2:	f0 
f0102bf3:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f0102bfa:	00 
f0102bfb:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102c02:	e8 39 d4 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void *)mm1, 0) = 0;
f0102c07:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102c0e:	00 
f0102c0f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102c13:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0102c18:	89 04 24             	mov    %eax,(%esp)
f0102c1b:	e8 e4 e5 ff ff       	call   f0101204 <pgdir_walk>
f0102c20:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void *)mm1 + PGSIZE, 0) = 0;
f0102c26:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102c2d:	00 
f0102c2e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c31:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102c35:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0102c3a:	89 04 24             	mov    %eax,(%esp)
f0102c3d:	e8 c2 e5 ff ff       	call   f0101204 <pgdir_walk>
f0102c42:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void *)mm2, 0) = 0;
f0102c48:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102c4f:	00 
f0102c50:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102c54:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0102c59:	89 04 24             	mov    %eax,(%esp)
f0102c5c:	e8 a3 e5 ff ff       	call   f0101204 <pgdir_walk>
f0102c61:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102c67:	c7 04 24 6b 7c 10 f0 	movl   $0xf0107c6b,(%esp)
f0102c6e:	e8 5a 12 00 00       	call   f0103ecd <cprintf>
	boot_map_region(kern_pgdir, UPAGES, npages * sizeof(struct PageInfo), PADDR(pages), PTE_U);
f0102c73:	a1 90 7e 1e f0       	mov    0xf01e7e90,%eax
	if ((uint32_t)kva < KERNBASE)
f0102c78:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c7d:	77 20                	ja     f0102c9f <mem_init+0x1776>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c7f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c83:	c7 44 24 08 c8 6a 10 	movl   $0xf0106ac8,0x8(%esp)
f0102c8a:	f0 
f0102c8b:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
f0102c92:	00 
f0102c93:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102c9a:	e8 a1 d3 ff ff       	call   f0100040 <_panic>
f0102c9f:	8b 0d 88 7e 1e f0    	mov    0xf01e7e88,%ecx
f0102ca5:	c1 e1 03             	shl    $0x3,%ecx
f0102ca8:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102caf:	00 
	return (physaddr_t)kva - KERNBASE;
f0102cb0:	05 00 00 00 10       	add    $0x10000000,%eax
f0102cb5:	89 04 24             	mov    %eax,(%esp)
f0102cb8:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102cbd:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0102cc2:	e8 ce e6 ff ff       	call   f0101395 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, NENV * sizeof(struct Env), PADDR(envs), PTE_U);
f0102cc7:	a1 48 72 1e f0       	mov    0xf01e7248,%eax
	if ((uint32_t)kva < KERNBASE)
f0102ccc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102cd1:	77 20                	ja     f0102cf3 <mem_init+0x17ca>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cd3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cd7:	c7 44 24 08 c8 6a 10 	movl   $0xf0106ac8,0x8(%esp)
f0102cde:	f0 
f0102cdf:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
f0102ce6:	00 
f0102ce7:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102cee:	e8 4d d3 ff ff       	call   f0100040 <_panic>
f0102cf3:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102cfa:	00 
	return (physaddr_t)kva - KERNBASE;
f0102cfb:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d00:	89 04 24             	mov    %eax,(%esp)
f0102d03:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102d08:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102d0d:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0102d12:	e8 7e e6 ff ff       	call   f0101395 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102d17:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0102d1c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d21:	77 20                	ja     f0102d43 <mem_init+0x181a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d23:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d27:	c7 44 24 08 c8 6a 10 	movl   $0xf0106ac8,0x8(%esp)
f0102d2e:	f0 
f0102d2f:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
f0102d36:	00 
f0102d37:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102d3e:	e8 fd d2 ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102d43:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102d4a:	00 
f0102d4b:	c7 04 24 00 70 11 00 	movl   $0x117000,(%esp)
f0102d52:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102d57:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102d5c:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0102d61:	e8 2f e6 ff ff       	call   f0101395 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_W);
f0102d66:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102d6d:	00 
f0102d6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d75:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102d7a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102d7f:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0102d84:	e8 0c e6 ff ff       	call   f0101395 <boot_map_region>
f0102d89:	bf 00 90 22 f0       	mov    $0xf0229000,%edi
f0102d8e:	bb 00 90 1e f0       	mov    $0xf01e9000,%ebx
f0102d93:	be 00 80 ff ef       	mov    $0xefff8000,%esi
	if ((uint32_t)kva < KERNBASE)
f0102d98:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102d9e:	77 20                	ja     f0102dc0 <mem_init+0x1897>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102da0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102da4:	c7 44 24 08 c8 6a 10 	movl   $0xf0106ac8,0x8(%esp)
f0102dab:	f0 
f0102dac:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
f0102db3:	00 
f0102db4:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102dbb:	e8 80 d2 ff ff       	call   f0100040 <_panic>
		boot_map_region(kern_pgdir, KSTACKTOP - i * (KSTKSIZE + KSTKGAP) - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W); // percpu_kstacks[i]指向的物理内存作为其内核堆栈映射到的地址
f0102dc0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102dc7:	00 
f0102dc8:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102dce:	89 04 24             	mov    %eax,(%esp)
f0102dd1:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102dd6:	89 f2                	mov    %esi,%edx
f0102dd8:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0102ddd:	e8 b3 e5 ff ff       	call   f0101395 <boot_map_region>
f0102de2:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102de8:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	for (int i = 0; i < NCPU; i++)
f0102dee:	39 fb                	cmp    %edi,%ebx
f0102df0:	75 a6                	jne    f0102d98 <mem_init+0x186f>
	pgdir = kern_pgdir;
f0102df2:	8b 3d 8c 7e 1e f0    	mov    0xf01e7e8c,%edi
	n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
f0102df8:	a1 88 7e 1e f0       	mov    0xf01e7e88,%eax
f0102dfd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102e00:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102e07:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e0c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e0f:	8b 35 90 7e 1e f0    	mov    0xf01e7e90,%esi
	if ((uint32_t)kva < KERNBASE)
f0102e15:	89 75 cc             	mov    %esi,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102e18:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0102e1e:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0102e21:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102e26:	eb 6a                	jmp    f0102e92 <mem_init+0x1969>
f0102e28:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e2e:	89 f8                	mov    %edi,%eax
f0102e30:	e8 c6 dd ff ff       	call   f0100bfb <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102e35:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102e3c:	77 20                	ja     f0102e5e <mem_init+0x1935>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e3e:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102e42:	c7 44 24 08 c8 6a 10 	movl   $0xf0106ac8,0x8(%esp)
f0102e49:	f0 
f0102e4a:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f0102e51:	00 
f0102e52:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102e59:	e8 e2 d1 ff ff       	call   f0100040 <_panic>
f0102e5e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102e61:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102e64:	39 d0                	cmp    %edx,%eax
f0102e66:	74 24                	je     f0102e8c <mem_init+0x1963>
f0102e68:	c7 44 24 0c 08 78 10 	movl   $0xf0107808,0xc(%esp)
f0102e6f:	f0 
f0102e70:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102e77:	f0 
f0102e78:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f0102e7f:	00 
f0102e80:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102e87:	e8 b4 d1 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f0102e8c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e92:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0102e95:	77 91                	ja     f0102e28 <mem_init+0x18ff>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e97:	8b 1d 48 72 1e f0    	mov    0xf01e7248,%ebx
	if ((uint32_t)kva < KERNBASE)
f0102e9d:	89 de                	mov    %ebx,%esi
f0102e9f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102ea4:	89 f8                	mov    %edi,%eax
f0102ea6:	e8 50 dd ff ff       	call   f0100bfb <check_va2pa>
f0102eab:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102eb1:	77 20                	ja     f0102ed3 <mem_init+0x19aa>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102eb3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102eb7:	c7 44 24 08 c8 6a 10 	movl   $0xf0106ac8,0x8(%esp)
f0102ebe:	f0 
f0102ebf:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0102ec6:	00 
f0102ec7:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102ece:	e8 6d d1 ff ff       	call   f0100040 <_panic>
	if ((uint32_t)kva < KERNBASE)
f0102ed3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102ed8:	81 c6 00 00 40 21    	add    $0x21400000,%esi
f0102ede:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102ee1:	39 d0                	cmp    %edx,%eax
f0102ee3:	74 24                	je     f0102f09 <mem_init+0x19e0>
f0102ee5:	c7 44 24 0c 3c 78 10 	movl   $0xf010783c,0xc(%esp)
f0102eec:	f0 
f0102eed:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102ef4:	f0 
f0102ef5:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0102efc:	00 
f0102efd:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102f04:	e8 37 d1 ff ff       	call   f0100040 <_panic>
f0102f09:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f0102f0f:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102f15:	0f 85 aa 05 00 00    	jne    f01034c5 <mem_init+0x1f9c>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102f1b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102f1e:	c1 e6 0c             	shl    $0xc,%esi
f0102f21:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102f26:	eb 3b                	jmp    f0102f63 <mem_init+0x1a3a>
f0102f28:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102f2e:	89 f8                	mov    %edi,%eax
f0102f30:	e8 c6 dc ff ff       	call   f0100bfb <check_va2pa>
f0102f35:	39 c3                	cmp    %eax,%ebx
f0102f37:	74 24                	je     f0102f5d <mem_init+0x1a34>
f0102f39:	c7 44 24 0c 70 78 10 	movl   $0xf0107870,0xc(%esp)
f0102f40:	f0 
f0102f41:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102f48:	f0 
f0102f49:	c7 44 24 04 ec 02 00 	movl   $0x2ec,0x4(%esp)
f0102f50:	00 
f0102f51:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102f58:	e8 e3 d0 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102f5d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f63:	39 f3                	cmp    %esi,%ebx
f0102f65:	72 c1                	jb     f0102f28 <mem_init+0x19ff>
f0102f67:	c7 45 d0 00 90 1e f0 	movl   $0xf01e9000,-0x30(%ebp)
f0102f6e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0102f75:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102f7a:	b8 00 90 1e f0       	mov    $0xf01e9000,%eax
f0102f7f:	05 00 80 00 20       	add    $0x20008000,%eax
f0102f84:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102f87:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0102f8d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i) == PADDR(percpu_kstacks[n]) + i);
f0102f90:	89 f2                	mov    %esi,%edx
f0102f92:	89 f8                	mov    %edi,%eax
f0102f94:	e8 62 dc ff ff       	call   f0100bfb <check_va2pa>
f0102f99:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102f9c:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0102fa2:	77 20                	ja     f0102fc4 <mem_init+0x1a9b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fa4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102fa8:	c7 44 24 08 c8 6a 10 	movl   $0xf0106ac8,0x8(%esp)
f0102faf:	f0 
f0102fb0:	c7 44 24 04 f4 02 00 	movl   $0x2f4,0x4(%esp)
f0102fb7:	00 
f0102fb8:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102fbf:	e8 7c d0 ff ff       	call   f0100040 <_panic>
	if ((uint32_t)kva < KERNBASE)
f0102fc4:	89 f3                	mov    %esi,%ebx
f0102fc6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0102fc9:	03 4d d4             	add    -0x2c(%ebp),%ecx
f0102fcc:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0102fcf:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102fd2:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102fd5:	39 c2                	cmp    %eax,%edx
f0102fd7:	74 24                	je     f0102ffd <mem_init+0x1ad4>
f0102fd9:	c7 44 24 0c 98 78 10 	movl   $0xf0107898,0xc(%esp)
f0102fe0:	f0 
f0102fe1:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0102fe8:	f0 
f0102fe9:	c7 44 24 04 f4 02 00 	movl   $0x2f4,0x4(%esp)
f0102ff0:	00 
f0102ff1:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0102ff8:	e8 43 d0 ff ff       	call   f0100040 <_panic>
f0102ffd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0103003:	3b 5d cc             	cmp    -0x34(%ebp),%ebx
f0103006:	0f 85 a9 04 00 00    	jne    f01034b5 <mem_init+0x1f8c>
f010300c:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0103012:	89 da                	mov    %ebx,%edx
f0103014:	89 f8                	mov    %edi,%eax
f0103016:	e8 e0 db ff ff       	call   f0100bfb <check_va2pa>
f010301b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010301e:	74 24                	je     f0103044 <mem_init+0x1b1b>
f0103020:	c7 44 24 0c e0 78 10 	movl   $0xf01078e0,0xc(%esp)
f0103027:	f0 
f0103028:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f010302f:	f0 
f0103030:	c7 44 24 04 f6 02 00 	movl   $0x2f6,0x4(%esp)
f0103037:	00 
f0103038:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f010303f:	e8 fc cf ff ff       	call   f0100040 <_panic>
f0103044:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f010304a:	39 de                	cmp    %ebx,%esi
f010304c:	75 c4                	jne    f0103012 <mem_init+0x1ae9>
f010304e:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0103054:	81 45 d4 00 80 01 00 	addl   $0x18000,-0x2c(%ebp)
f010305b:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
	for (n = 0; n < NCPU; n++)
f0103062:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0103068:	0f 85 19 ff ff ff    	jne    f0102f87 <mem_init+0x1a5e>
f010306e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103073:	e9 c2 00 00 00       	jmp    f010313a <mem_init+0x1c11>
		switch (i)
f0103078:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f010307e:	83 fa 04             	cmp    $0x4,%edx
f0103081:	77 2e                	ja     f01030b1 <mem_init+0x1b88>
			assert(pgdir[i] & PTE_P);
f0103083:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0103087:	0f 85 aa 00 00 00    	jne    f0103137 <mem_init+0x1c0e>
f010308d:	c7 44 24 0c 84 7c 10 	movl   $0xf0107c84,0xc(%esp)
f0103094:	f0 
f0103095:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f010309c:	f0 
f010309d:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f01030a4:	00 
f01030a5:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01030ac:	e8 8f cf ff ff       	call   f0100040 <_panic>
			if (i >= PDX(KERNBASE))
f01030b1:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01030b6:	76 55                	jbe    f010310d <mem_init+0x1be4>
				assert(pgdir[i] & PTE_P);
f01030b8:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01030bb:	f6 c2 01             	test   $0x1,%dl
f01030be:	75 24                	jne    f01030e4 <mem_init+0x1bbb>
f01030c0:	c7 44 24 0c 84 7c 10 	movl   $0xf0107c84,0xc(%esp)
f01030c7:	f0 
f01030c8:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01030cf:	f0 
f01030d0:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f01030d7:	00 
f01030d8:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01030df:	e8 5c cf ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01030e4:	f6 c2 02             	test   $0x2,%dl
f01030e7:	75 4e                	jne    f0103137 <mem_init+0x1c0e>
f01030e9:	c7 44 24 0c 95 7c 10 	movl   $0xf0107c95,0xc(%esp)
f01030f0:	f0 
f01030f1:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01030f8:	f0 
f01030f9:	c7 44 24 04 09 03 00 	movl   $0x309,0x4(%esp)
f0103100:	00 
f0103101:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0103108:	e8 33 cf ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f010310d:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0103111:	74 24                	je     f0103137 <mem_init+0x1c0e>
f0103113:	c7 44 24 0c a6 7c 10 	movl   $0xf0107ca6,0xc(%esp)
f010311a:	f0 
f010311b:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0103122:	f0 
f0103123:	c7 44 24 04 0c 03 00 	movl   $0x30c,0x4(%esp)
f010312a:	00 
f010312b:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0103132:	e8 09 cf ff ff       	call   f0100040 <_panic>
	for (i = 0; i < NPDENTRIES; i++)
f0103137:	83 c0 01             	add    $0x1,%eax
f010313a:	3d 00 04 00 00       	cmp    $0x400,%eax
f010313f:	0f 85 33 ff ff ff    	jne    f0103078 <mem_init+0x1b4f>
	cprintf("check_kern_pgdir() succeeded!\n");
f0103145:	c7 04 24 04 79 10 f0 	movl   $0xf0107904,(%esp)
f010314c:	e8 7c 0d 00 00       	call   f0103ecd <cprintf>
	lcr3(PADDR(kern_pgdir));
f0103151:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f0103156:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010315b:	77 20                	ja     f010317d <mem_init+0x1c54>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010315d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103161:	c7 44 24 08 c8 6a 10 	movl   $0xf0106ac8,0x8(%esp)
f0103168:	f0 
f0103169:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f0103170:	00 
f0103171:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0103178:	e8 c3 ce ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010317d:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103182:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0103185:	b8 00 00 00 00       	mov    $0x0,%eax
f010318a:	e8 db da ff ff       	call   f0100c6a <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f010318f:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS | CR0_EM);
f0103192:	83 e0 f3             	and    $0xfffffff3,%eax
f0103195:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f010319a:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010319d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031a4:	e8 67 df ff ff       	call   f0101110 <page_alloc>
f01031a9:	89 c3                	mov    %eax,%ebx
f01031ab:	85 c0                	test   %eax,%eax
f01031ad:	75 24                	jne    f01031d3 <mem_init+0x1caa>
f01031af:	c7 44 24 0c e7 7a 10 	movl   $0xf0107ae7,0xc(%esp)
f01031b6:	f0 
f01031b7:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01031be:	f0 
f01031bf:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f01031c6:	00 
f01031c7:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01031ce:	e8 6d ce ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01031d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031da:	e8 31 df ff ff       	call   f0101110 <page_alloc>
f01031df:	89 c7                	mov    %eax,%edi
f01031e1:	85 c0                	test   %eax,%eax
f01031e3:	75 24                	jne    f0103209 <mem_init+0x1ce0>
f01031e5:	c7 44 24 0c fd 7a 10 	movl   $0xf0107afd,0xc(%esp)
f01031ec:	f0 
f01031ed:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01031f4:	f0 
f01031f5:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f01031fc:	00 
f01031fd:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0103204:	e8 37 ce ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0103209:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103210:	e8 fb de ff ff       	call   f0101110 <page_alloc>
f0103215:	89 c6                	mov    %eax,%esi
f0103217:	85 c0                	test   %eax,%eax
f0103219:	75 24                	jne    f010323f <mem_init+0x1d16>
f010321b:	c7 44 24 0c 13 7b 10 	movl   $0xf0107b13,0xc(%esp)
f0103222:	f0 
f0103223:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f010322a:	f0 
f010322b:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0103232:	00 
f0103233:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f010323a:	e8 01 ce ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f010323f:	89 1c 24             	mov    %ebx,(%esp)
f0103242:	e8 5a df ff ff       	call   f01011a1 <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0103247:	89 f8                	mov    %edi,%eax
f0103249:	e8 68 d9 ff ff       	call   f0100bb6 <page2kva>
f010324e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103255:	00 
f0103256:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010325d:	00 
f010325e:	89 04 24             	mov    %eax,(%esp)
f0103261:	e8 e1 2a 00 00       	call   f0105d47 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0103266:	89 f0                	mov    %esi,%eax
f0103268:	e8 49 d9 ff ff       	call   f0100bb6 <page2kva>
f010326d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103274:	00 
f0103275:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010327c:	00 
f010327d:	89 04 24             	mov    %eax,(%esp)
f0103280:	e8 c2 2a 00 00       	call   f0105d47 <memset>
	page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W);
f0103285:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010328c:	00 
f010328d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103294:	00 
f0103295:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103299:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f010329e:	89 04 24             	mov    %eax,(%esp)
f01032a1:	e8 9c e1 ff ff       	call   f0101442 <page_insert>
	assert(pp1->pp_ref == 1);
f01032a6:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01032ab:	74 24                	je     f01032d1 <mem_init+0x1da8>
f01032ad:	c7 44 24 0c 8d 7b 10 	movl   $0xf0107b8d,0xc(%esp)
f01032b4:	f0 
f01032b5:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01032bc:	f0 
f01032bd:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f01032c4:	00 
f01032c5:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01032cc:	e8 6f cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01032d1:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01032d8:	01 01 01 
f01032db:	74 24                	je     f0103301 <mem_init+0x1dd8>
f01032dd:	c7 44 24 0c 24 79 10 	movl   $0xf0107924,0xc(%esp)
f01032e4:	f0 
f01032e5:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01032ec:	f0 
f01032ed:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f01032f4:	00 
f01032f5:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01032fc:	e8 3f cd ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W);
f0103301:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103308:	00 
f0103309:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103310:	00 
f0103311:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103315:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f010331a:	89 04 24             	mov    %eax,(%esp)
f010331d:	e8 20 e1 ff ff       	call   f0101442 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103322:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103329:	02 02 02 
f010332c:	74 24                	je     f0103352 <mem_init+0x1e29>
f010332e:	c7 44 24 0c 48 79 10 	movl   $0xf0107948,0xc(%esp)
f0103335:	f0 
f0103336:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f010333d:	f0 
f010333e:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0103345:	00 
f0103346:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f010334d:	e8 ee cc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0103352:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103357:	74 24                	je     f010337d <mem_init+0x1e54>
f0103359:	c7 44 24 0c af 7b 10 	movl   $0xf0107baf,0xc(%esp)
f0103360:	f0 
f0103361:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0103368:	f0 
f0103369:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f0103370:	00 
f0103371:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0103378:	e8 c3 cc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010337d:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103382:	74 24                	je     f01033a8 <mem_init+0x1e7f>
f0103384:	c7 44 24 0c 19 7c 10 	movl   $0xf0107c19,0xc(%esp)
f010338b:	f0 
f010338c:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0103393:	f0 
f0103394:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f010339b:	00 
f010339c:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01033a3:	e8 98 cc ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01033a8:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01033af:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01033b2:	89 f0                	mov    %esi,%eax
f01033b4:	e8 fd d7 ff ff       	call   f0100bb6 <page2kva>
f01033b9:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f01033bf:	74 24                	je     f01033e5 <mem_init+0x1ebc>
f01033c1:	c7 44 24 0c 6c 79 10 	movl   $0xf010796c,0xc(%esp)
f01033c8:	f0 
f01033c9:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01033d0:	f0 
f01033d1:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f01033d8:	00 
f01033d9:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f01033e0:	e8 5b cc ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void *)PGSIZE);
f01033e5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01033ec:	00 
f01033ed:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f01033f2:	89 04 24             	mov    %eax,(%esp)
f01033f5:	e8 ff df ff ff       	call   f01013f9 <page_remove>
	assert(pp2->pp_ref == 0);
f01033fa:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01033ff:	74 24                	je     f0103425 <mem_init+0x1efc>
f0103401:	c7 44 24 0c e7 7b 10 	movl   $0xf0107be7,0xc(%esp)
f0103408:	f0 
f0103409:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0103410:	f0 
f0103411:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0103418:	00 
f0103419:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0103420:	e8 1b cc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103425:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
f010342a:	8b 08                	mov    (%eax),%ecx
f010342c:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	return (pp - pages) << PGSHIFT;
f0103432:	89 da                	mov    %ebx,%edx
f0103434:	2b 15 90 7e 1e f0    	sub    0xf01e7e90,%edx
f010343a:	c1 fa 03             	sar    $0x3,%edx
f010343d:	c1 e2 0c             	shl    $0xc,%edx
f0103440:	39 d1                	cmp    %edx,%ecx
f0103442:	74 24                	je     f0103468 <mem_init+0x1f3f>
f0103444:	c7 44 24 0c ec 72 10 	movl   $0xf01072ec,0xc(%esp)
f010344b:	f0 
f010344c:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0103453:	f0 
f0103454:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f010345b:	00 
f010345c:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0103463:	e8 d8 cb ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103468:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010346e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103473:	74 24                	je     f0103499 <mem_init+0x1f70>
f0103475:	c7 44 24 0c 9e 7b 10 	movl   $0xf0107b9e,0xc(%esp)
f010347c:	f0 
f010347d:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f0103484:	f0 
f0103485:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f010348c:	00 
f010348d:	c7 04 24 f9 79 10 f0 	movl   $0xf01079f9,(%esp)
f0103494:	e8 a7 cb ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103499:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010349f:	89 1c 24             	mov    %ebx,(%esp)
f01034a2:	e8 fa dc ff ff       	call   f01011a1 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01034a7:	c7 04 24 98 79 10 f0 	movl   $0xf0107998,(%esp)
f01034ae:	e8 1a 0a 00 00       	call   f0103ecd <cprintf>
f01034b3:	eb 20                	jmp    f01034d5 <mem_init+0x1fac>
			assert(check_va2pa(pgdir, base + KSTKGAP + i) == PADDR(percpu_kstacks[n]) + i);
f01034b5:	89 da                	mov    %ebx,%edx
f01034b7:	89 f8                	mov    %edi,%eax
f01034b9:	e8 3d d7 ff ff       	call   f0100bfb <check_va2pa>
f01034be:	66 90                	xchg   %ax,%ax
f01034c0:	e9 0a fb ff ff       	jmp    f0102fcf <mem_init+0x1aa6>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01034c5:	89 da                	mov    %ebx,%edx
f01034c7:	89 f8                	mov    %edi,%eax
f01034c9:	e8 2d d7 ff ff       	call   f0100bfb <check_va2pa>
f01034ce:	66 90                	xchg   %ax,%ax
f01034d0:	e9 09 fa ff ff       	jmp    f0102ede <mem_init+0x19b5>
}
f01034d5:	83 c4 4c             	add    $0x4c,%esp
f01034d8:	5b                   	pop    %ebx
f01034d9:	5e                   	pop    %esi
f01034da:	5f                   	pop    %edi
f01034db:	5d                   	pop    %ebp
f01034dc:	c3                   	ret    

f01034dd <user_mem_check>:
{
f01034dd:	55                   	push   %ebp
f01034de:	89 e5                	mov    %esp,%ebp
f01034e0:	57                   	push   %edi
f01034e1:	56                   	push   %esi
f01034e2:	53                   	push   %ebx
f01034e3:	83 ec 1c             	sub    $0x1c,%esp
f01034e6:	8b 7d 08             	mov    0x8(%ebp),%edi
	const void *start = ROUNDDOWN(va, PGSIZE);
f01034e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01034ec:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	const void *end = ROUNDUP(va + len, PGSIZE);
f01034f2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034f5:	03 45 10             	add    0x10(%ebp),%eax
f01034f8:	05 ff 0f 00 00       	add    $0xfff,%eax
f01034fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103502:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (!pte || (*pte & (perm | PTE_P)) != (perm | PTE_P)) // 确认权限，&操作可以得到那几个权限位来判断
f0103505:	8b 75 14             	mov    0x14(%ebp),%esi
f0103508:	83 ce 01             	or     $0x1,%esi
	for (; start < end; start += PGSIZE) // 遍历每一页
f010350b:	eb 3d                	jmp    f010354a <user_mem_check+0x6d>
		pte_t *pte = pgdir_walk(env->env_pgdir, start, 0);	   // 找到pte,pte只能在ULIM下方，因此若pte存在，则地址存在
f010350d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103514:	00 
f0103515:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103519:	8b 47 60             	mov    0x60(%edi),%eax
f010351c:	89 04 24             	mov    %eax,(%esp)
f010351f:	e8 e0 dc ff ff       	call   f0101204 <pgdir_walk>
		if (!pte || (*pte & (perm | PTE_P)) != (perm | PTE_P)) // 确认权限，&操作可以得到那几个权限位来判断
f0103524:	85 c0                	test   %eax,%eax
f0103526:	74 08                	je     f0103530 <user_mem_check+0x53>
f0103528:	89 f2                	mov    %esi,%edx
f010352a:	23 10                	and    (%eax),%edx
f010352c:	39 d6                	cmp    %edx,%esi
f010352e:	74 14                	je     f0103544 <user_mem_check+0x67>
			user_mem_check_addr = (uintptr_t)MAX(start, va); // 第一个错误的虚拟地址
f0103530:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0103533:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0103537:	89 1d 3c 72 1e f0    	mov    %ebx,0xf01e723c
			return -E_FAULT;								 // 提前返回
f010353d:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103542:	eb 10                	jmp    f0103554 <user_mem_check+0x77>
	for (; start < end; start += PGSIZE) // 遍历每一页
f0103544:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010354a:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010354d:	72 be                	jb     f010350d <user_mem_check+0x30>
	return 0;
f010354f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103554:	83 c4 1c             	add    $0x1c,%esp
f0103557:	5b                   	pop    %ebx
f0103558:	5e                   	pop    %esi
f0103559:	5f                   	pop    %edi
f010355a:	5d                   	pop    %ebp
f010355b:	c3                   	ret    

f010355c <user_mem_assert>:
{
f010355c:	55                   	push   %ebp
f010355d:	89 e5                	mov    %esp,%ebp
f010355f:	53                   	push   %ebx
f0103560:	83 ec 14             	sub    $0x14,%esp
f0103563:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0)
f0103566:	8b 45 14             	mov    0x14(%ebp),%eax
f0103569:	83 c8 04             	or     $0x4,%eax
f010356c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103570:	8b 45 10             	mov    0x10(%ebp),%eax
f0103573:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103577:	8b 45 0c             	mov    0xc(%ebp),%eax
f010357a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010357e:	89 1c 24             	mov    %ebx,(%esp)
f0103581:	e8 57 ff ff ff       	call   f01034dd <user_mem_check>
f0103586:	85 c0                	test   %eax,%eax
f0103588:	79 24                	jns    f01035ae <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f010358a:	a1 3c 72 1e f0       	mov    0xf01e723c,%eax
f010358f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103593:	8b 43 48             	mov    0x48(%ebx),%eax
f0103596:	89 44 24 04          	mov    %eax,0x4(%esp)
f010359a:	c7 04 24 c4 79 10 f0 	movl   $0xf01079c4,(%esp)
f01035a1:	e8 27 09 00 00       	call   f0103ecd <cprintf>
		env_destroy(env); // may not return
f01035a6:	89 1c 24             	mov    %ebx,(%esp)
f01035a9:	e8 5a 06 00 00       	call   f0103c08 <env_destroy>
}
f01035ae:	83 c4 14             	add    $0x14,%esp
f01035b1:	5b                   	pop    %ebx
f01035b2:	5d                   	pop    %ebp
f01035b3:	c3                   	ret    

f01035b4 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
// 为环境 env 分配 len 字节的物理内存，并将其映射到环境地址空间中的虚拟地址 va。
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01035b4:	55                   	push   %ebp
f01035b5:	89 e5                	mov    %esp,%ebp
f01035b7:	57                   	push   %edi
f01035b8:	56                   	push   %esi
f01035b9:	53                   	push   %ebx
f01035ba:	83 ec 1c             	sub    $0x1c,%esp
f01035bd:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *start = ROUNDDOWN(va, PGSIZE);
f01035bf:	89 d3                	mov    %edx,%ebx
f01035c1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	void *end = ROUNDUP(va + len, PGSIZE);
f01035c7:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f01035ce:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (; start < end; start += PGSIZE)
f01035d4:	eb 6d                	jmp    f0103643 <region_alloc+0x8f>
	{
		struct PageInfo *p = page_alloc(0);
f01035d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035dd:	e8 2e db ff ff       	call   f0101110 <page_alloc>
		if (p == NULL)
f01035e2:	85 c0                	test   %eax,%eax
f01035e4:	75 1c                	jne    f0103602 <region_alloc+0x4e>
		{
			panic("region_alloc: error in page_alloc()\n"); // 分配失败
f01035e6:	c7 44 24 08 b4 7c 10 	movl   $0xf0107cb4,0x8(%esp)
f01035ed:	f0 
f01035ee:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
f01035f5:	00 
f01035f6:	c7 04 24 4d 7d 10 f0 	movl   $0xf0107d4d,(%esp)
f01035fd:	e8 3e ca ff ff       	call   f0100040 <_panic>
		}
		if (page_insert(e->env_pgdir, p, start, PTE_W | PTE_U))
f0103602:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103609:	00 
f010360a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010360e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103612:	8b 47 60             	mov    0x60(%edi),%eax
f0103615:	89 04 24             	mov    %eax,(%esp)
f0103618:	e8 25 de ff ff       	call   f0101442 <page_insert>
f010361d:	85 c0                	test   %eax,%eax
f010361f:	74 1c                	je     f010363d <region_alloc+0x89>
		{
			panic("region_alloc: error in page_insert()\n"); // 插入失败
f0103621:	c7 44 24 08 dc 7c 10 	movl   $0xf0107cdc,0x8(%esp)
f0103628:	f0 
f0103629:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
f0103630:	00 
f0103631:	c7 04 24 4d 7d 10 f0 	movl   $0xf0107d4d,(%esp)
f0103638:	e8 03 ca ff ff       	call   f0100040 <_panic>
	for (; start < end; start += PGSIZE)
f010363d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103643:	39 f3                	cmp    %esi,%ebx
f0103645:	72 8f                	jb     f01035d6 <region_alloc+0x22>
		}
	}
}
f0103647:	83 c4 1c             	add    $0x1c,%esp
f010364a:	5b                   	pop    %ebx
f010364b:	5e                   	pop    %esi
f010364c:	5f                   	pop    %edi
f010364d:	5d                   	pop    %ebp
f010364e:	c3                   	ret    

f010364f <envid2env>:
{
f010364f:	55                   	push   %ebp
f0103650:	89 e5                	mov    %esp,%ebp
f0103652:	56                   	push   %esi
f0103653:	53                   	push   %ebx
f0103654:	8b 45 08             	mov    0x8(%ebp),%eax
f0103657:	8b 55 10             	mov    0x10(%ebp),%edx
	if (envid == 0)
f010365a:	85 c0                	test   %eax,%eax
f010365c:	75 1a                	jne    f0103678 <envid2env+0x29>
		*env_store = curenv;
f010365e:	e8 36 2d 00 00       	call   f0106399 <cpunum>
f0103663:	6b c0 74             	imul   $0x74,%eax,%eax
f0103666:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f010366c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010366f:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103671:	b8 00 00 00 00       	mov    $0x0,%eax
f0103676:	eb 70                	jmp    f01036e8 <envid2env+0x99>
	e = &envs[ENVX(envid)];
f0103678:	89 c3                	mov    %eax,%ebx
f010367a:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103680:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103683:	03 1d 48 72 1e f0    	add    0xf01e7248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid)
f0103689:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010368d:	74 05                	je     f0103694 <envid2env+0x45>
f010368f:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103692:	74 10                	je     f01036a4 <envid2env+0x55>
		*env_store = 0;
f0103694:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103697:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010369d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01036a2:	eb 44                	jmp    f01036e8 <envid2env+0x99>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id)
f01036a4:	84 d2                	test   %dl,%dl
f01036a6:	74 36                	je     f01036de <envid2env+0x8f>
f01036a8:	e8 ec 2c 00 00       	call   f0106399 <cpunum>
f01036ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01036b0:	39 98 28 80 1e f0    	cmp    %ebx,-0xfe17fd8(%eax)
f01036b6:	74 26                	je     f01036de <envid2env+0x8f>
f01036b8:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01036bb:	e8 d9 2c 00 00       	call   f0106399 <cpunum>
f01036c0:	6b c0 74             	imul   $0x74,%eax,%eax
f01036c3:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f01036c9:	3b 70 48             	cmp    0x48(%eax),%esi
f01036cc:	74 10                	je     f01036de <envid2env+0x8f>
		*env_store = 0;
f01036ce:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036d1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01036d7:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01036dc:	eb 0a                	jmp    f01036e8 <envid2env+0x99>
	*env_store = e;
f01036de:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036e1:	89 18                	mov    %ebx,(%eax)
	return 0;
f01036e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01036e8:	5b                   	pop    %ebx
f01036e9:	5e                   	pop    %esi
f01036ea:	5d                   	pop    %ebp
f01036eb:	c3                   	ret    

f01036ec <env_init_percpu>:
{
f01036ec:	55                   	push   %ebp
f01036ed:	89 e5                	mov    %esp,%ebp
	asm volatile("lgdt (%0)" : : "r" (p));
f01036ef:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f01036f4:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs"
f01036f7:	b8 23 00 00 00       	mov    $0x23,%eax
f01036fc:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs"
f01036fe:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es"
f0103700:	b0 10                	mov    $0x10,%al
f0103702:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds"
f0103704:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss"
f0103706:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n"
f0103708:	ea 0f 37 10 f0 08 00 	ljmp   $0x8,$0xf010370f
	asm volatile("lldt %0" : : "r" (sel));
f010370f:	b0 00                	mov    $0x0,%al
f0103711:	0f 00 d0             	lldt   %ax
}
f0103714:	5d                   	pop    %ebp
f0103715:	c3                   	ret    

f0103716 <env_init>:
{
f0103716:	55                   	push   %ebp
f0103717:	89 e5                	mov    %esp,%ebp
f0103719:	56                   	push   %esi
f010371a:	53                   	push   %ebx
		envs[i].env_id = 0;
f010371b:	8b 35 48 72 1e f0    	mov    0xf01e7248,%esi
f0103721:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103727:	ba 00 04 00 00       	mov    $0x400,%edx
f010372c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103731:	89 c3                	mov    %eax,%ebx
f0103733:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status = ENV_FREE;
f010373a:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link = env_free_list;
f0103741:	89 48 44             	mov    %ecx,0x44(%eax)
f0103744:	83 e8 7c             	sub    $0x7c,%eax
	for (int i = NENV - 1; i >= 0; i--) // 倒着遍历数组，让最后的元素出现在链表底部
f0103747:	83 ea 01             	sub    $0x1,%edx
f010374a:	74 04                	je     f0103750 <env_init+0x3a>
		env_free_list = &envs[i];
f010374c:	89 d9                	mov    %ebx,%ecx
f010374e:	eb e1                	jmp    f0103731 <env_init+0x1b>
f0103750:	89 35 4c 72 1e f0    	mov    %esi,0xf01e724c
	env_init_percpu();
f0103756:	e8 91 ff ff ff       	call   f01036ec <env_init_percpu>
}
f010375b:	5b                   	pop    %ebx
f010375c:	5e                   	pop    %esi
f010375d:	5d                   	pop    %ebp
f010375e:	c3                   	ret    

f010375f <env_alloc>:
{
f010375f:	55                   	push   %ebp
f0103760:	89 e5                	mov    %esp,%ebp
f0103762:	53                   	push   %ebx
f0103763:	83 ec 14             	sub    $0x14,%esp
	if (!(e = env_free_list)) // 如果env_free_list==null就会在这
f0103766:	8b 1d 4c 72 1e f0    	mov    0xf01e724c,%ebx
f010376c:	85 db                	test   %ebx,%ebx
f010376e:	0f 84 50 01 00 00    	je     f01038c4 <env_alloc+0x165>
	if (!(p = page_alloc(ALLOC_ZERO))) // 分配一页给页表目录
f0103774:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010377b:	e8 90 d9 ff ff       	call   f0101110 <page_alloc>
f0103780:	85 c0                	test   %eax,%eax
f0103782:	0f 84 43 01 00 00    	je     f01038cb <env_alloc+0x16c>
	p->pp_ref++;
f0103788:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f010378d:	2b 05 90 7e 1e f0    	sub    0xf01e7e90,%eax
f0103793:	c1 f8 03             	sar    $0x3,%eax
f0103796:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103799:	89 c2                	mov    %eax,%edx
f010379b:	c1 ea 0c             	shr    $0xc,%edx
f010379e:	3b 15 88 7e 1e f0    	cmp    0xf01e7e88,%edx
f01037a4:	72 20                	jb     f01037c6 <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01037a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037aa:	c7 44 24 08 a4 6a 10 	movl   $0xf0106aa4,0x8(%esp)
f01037b1:	f0 
f01037b2:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01037b9:	00 
f01037ba:	c7 04 24 05 7a 10 f0 	movl   $0xf0107a05,(%esp)
f01037c1:	e8 7a c8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01037c6:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = page2kva(p);
f01037cb:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE); // 把内核页表复制一份放在用户能访问的用户空间里(即env_pgdir处)
f01037ce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01037d5:	00 
f01037d6:	8b 15 8c 7e 1e f0    	mov    0xf01e7e8c,%edx
f01037dc:	89 54 24 04          	mov    %edx,0x4(%esp)
f01037e0:	89 04 24             	mov    %eax,(%esp)
f01037e3:	e8 14 26 00 00       	call   f0105dfc <memcpy>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01037e8:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01037eb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037f0:	77 20                	ja     f0103812 <env_alloc+0xb3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037f6:	c7 44 24 08 c8 6a 10 	movl   $0xf0106ac8,0x8(%esp)
f01037fd:	f0 
f01037fe:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
f0103805:	00 
f0103806:	c7 04 24 4d 7d 10 f0 	movl   $0xf0107d4d,(%esp)
f010380d:	e8 2e c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103812:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103818:	83 ca 05             	or     $0x5,%edx
f010381b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103821:	8b 43 48             	mov    0x48(%ebx),%eax
f0103824:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0) // Don't create a negative env_id.
f0103829:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f010382e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103833:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103836:	89 da                	mov    %ebx,%edx
f0103838:	2b 15 48 72 1e f0    	sub    0xf01e7248,%edx
f010383e:	c1 fa 02             	sar    $0x2,%edx
f0103841:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103847:	09 d0                	or     %edx,%eax
f0103849:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f010384c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010384f:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103852:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103859:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103860:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103867:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f010386e:	00 
f010386f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103876:	00 
f0103877:	89 1c 24             	mov    %ebx,(%esp)
f010387a:	e8 c8 24 00 00       	call   f0105d47 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f010387f:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103885:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010388b:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103891:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103898:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_tf.tf_eflags |= FL_IF;
f010389e:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f01038a5:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f01038ac:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f01038b0:	8b 43 44             	mov    0x44(%ebx),%eax
f01038b3:	a3 4c 72 1e f0       	mov    %eax,0xf01e724c
	*newenv_store = e;
f01038b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01038bb:	89 18                	mov    %ebx,(%eax)
	return 0;
f01038bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01038c2:	eb 0c                	jmp    f01038d0 <env_alloc+0x171>
		return -E_NO_FREE_ENV;
f01038c4:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01038c9:	eb 05                	jmp    f01038d0 <env_alloc+0x171>
		return -E_NO_MEM;
f01038cb:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
f01038d0:	83 c4 14             	add    $0x14,%esp
f01038d3:	5b                   	pop    %ebx
f01038d4:	5d                   	pop    %ebp
f01038d5:	c3                   	ret    

f01038d6 <env_create>:
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
// 使用 env_alloc 分配一个新环境，使用 load_icode 将命名的 elf 二进制文件加载到其中，并设置其 env_type
void env_create(uint8_t *binary, enum EnvType type)
{
f01038d6:	55                   	push   %ebp
f01038d7:	89 e5                	mov    %esp,%ebp
f01038d9:	57                   	push   %edi
f01038da:	56                   	push   %esi
f01038db:	53                   	push   %ebx
f01038dc:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 3: Your code here.
	struct Env *e;
	if (env_alloc(&e, 0))
f01038df:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01038e6:	00 
f01038e7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01038ea:	89 04 24             	mov    %eax,(%esp)
f01038ed:	e8 6d fe ff ff       	call   f010375f <env_alloc>
f01038f2:	85 c0                	test   %eax,%eax
f01038f4:	74 1c                	je     f0103912 <env_create+0x3c>
	{
		panic("env_create: error in env_alloc()");
f01038f6:	c7 44 24 08 04 7d 10 	movl   $0xf0107d04,0x8(%esp)
f01038fd:	f0 
f01038fe:	c7 44 24 04 a1 01 00 	movl   $0x1a1,0x4(%esp)
f0103905:	00 
f0103906:	c7 04 24 4d 7d 10 f0 	movl   $0xf0107d4d,(%esp)
f010390d:	e8 2e c7 ff ff       	call   f0100040 <_panic>
	}
	load_icode(e, binary);
f0103912:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	if (ELFHDR->e_magic != ELF_MAGIC)
f0103915:	8b 45 08             	mov    0x8(%ebp),%eax
f0103918:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f010391e:	74 1c                	je     f010393c <env_create+0x66>
		panic("load_icode: ELFHDR is not ELF_MAGIC\n");
f0103920:	c7 44 24 08 28 7d 10 	movl   $0xf0107d28,0x8(%esp)
f0103927:	f0 
f0103928:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
f010392f:	00 
f0103930:	c7 04 24 4d 7d 10 f0 	movl   $0xf0107d4d,(%esp)
f0103937:	e8 04 c7 ff ff       	call   f0100040 <_panic>
	ph = (struct Proghdr *)((uint8_t *)ELFHDR + ELFHDR->e_phoff); // ELFHDR+offset是段的起始地址
f010393c:	8b 45 08             	mov    0x8(%ebp),%eax
f010393f:	89 c3                	mov    %eax,%ebx
f0103941:	03 58 1c             	add    0x1c(%eax),%ebx
	eph = ph + ELFHDR->e_phnum;									  // end地址
f0103944:	0f b7 70 2c          	movzwl 0x2c(%eax),%esi
f0103948:	c1 e6 05             	shl    $0x5,%esi
f010394b:	01 de                	add    %ebx,%esi
	lcr3(PADDR(e->env_pgdir));									  // 切换到用户空间
f010394d:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103950:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103955:	77 20                	ja     f0103977 <env_create+0xa1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103957:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010395b:	c7 44 24 08 c8 6a 10 	movl   $0xf0106ac8,0x8(%esp)
f0103962:	f0 
f0103963:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f010396a:	00 
f010396b:	c7 04 24 4d 7d 10 f0 	movl   $0xf0107d4d,(%esp)
f0103972:	e8 c9 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103977:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010397c:	0f 22 d8             	mov    %eax,%cr3
f010397f:	eb 4b                	jmp    f01039cc <env_create+0xf6>
		if (ph->p_type == ELF_PROG_LOAD)
f0103981:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103984:	75 43                	jne    f01039c9 <env_create+0xf3>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);						   // 先分配内存空间
f0103986:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103989:	8b 53 08             	mov    0x8(%ebx),%edx
f010398c:	89 f8                	mov    %edi,%eax
f010398e:	e8 21 fc ff ff       	call   f01035b4 <region_alloc>
			memset((void *)ph->p_va, 0, ph->p_memsz);							   // 将内存空间初始化为0
f0103993:	8b 43 14             	mov    0x14(%ebx),%eax
f0103996:	89 44 24 08          	mov    %eax,0x8(%esp)
f010399a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01039a1:	00 
f01039a2:	8b 43 08             	mov    0x8(%ebx),%eax
f01039a5:	89 04 24             	mov    %eax,(%esp)
f01039a8:	e8 9a 23 00 00       	call   f0105d47 <memset>
			memcpy((void *)ph->p_va, (void *)ELFHDR + ph->p_offset, ph->p_filesz); // 复制内容到刚刚分配的空间
f01039ad:	8b 43 10             	mov    0x10(%ebx),%eax
f01039b0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01039b7:	03 43 04             	add    0x4(%ebx),%eax
f01039ba:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039be:	8b 43 08             	mov    0x8(%ebx),%eax
f01039c1:	89 04 24             	mov    %eax,(%esp)
f01039c4:	e8 33 24 00 00       	call   f0105dfc <memcpy>
	for (; ph < eph; ph++)										  // 依次读取所有段
f01039c9:	83 c3 20             	add    $0x20,%ebx
f01039cc:	39 de                	cmp    %ebx,%esi
f01039ce:	77 b1                	ja     f0103981 <env_create+0xab>
	lcr3(PADDR(kern_pgdir));							 // 切换到内核空间
f01039d0:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01039d5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039da:	77 20                	ja     f01039fc <env_create+0x126>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039e0:	c7 44 24 08 c8 6a 10 	movl   $0xf0106ac8,0x8(%esp)
f01039e7:	f0 
f01039e8:	c7 44 24 04 8d 01 00 	movl   $0x18d,0x4(%esp)
f01039ef:	00 
f01039f0:	c7 04 24 4d 7d 10 f0 	movl   $0xf0107d4d,(%esp)
f01039f7:	e8 44 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01039fc:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a01:	0f 22 d8             	mov    %eax,%cr3
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE); // 为程序的初始堆栈(地址:USTACKTOP - PGSIZE)映射一页
f0103a04:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103a09:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103a0e:	89 f8                	mov    %edi,%eax
f0103a10:	e8 9f fb ff ff       	call   f01035b4 <region_alloc>
	e->env_status = ENV_RUNNABLE;						 // 设置程序状态
f0103a15:	c7 47 54 02 00 00 00 	movl   $0x2,0x54(%edi)
	e->env_tf.tf_esp = USTACKTOP;						 // 设置程序堆栈
f0103a1c:	c7 47 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%edi)
	e->env_tf.tf_eip = ELFHDR->e_entry;					 // 设置程序入口
f0103a23:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a26:	8b 40 18             	mov    0x18(%eax),%eax
f0103a29:	89 47 30             	mov    %eax,0x30(%edi)
	e->env_type = type;
f0103a2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a2f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103a32:	89 50 50             	mov    %edx,0x50(%eax)

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
}
f0103a35:	83 c4 2c             	add    $0x2c,%esp
f0103a38:	5b                   	pop    %ebx
f0103a39:	5e                   	pop    %esi
f0103a3a:	5f                   	pop    %edi
f0103a3b:	5d                   	pop    %ebp
f0103a3c:	c3                   	ret    

f0103a3d <env_free>:

//
// Frees env e and all memory it uses.
//
void env_free(struct Env *e)
{
f0103a3d:	55                   	push   %ebp
f0103a3e:	89 e5                	mov    %esp,%ebp
f0103a40:	57                   	push   %edi
f0103a41:	56                   	push   %esi
f0103a42:	53                   	push   %ebx
f0103a43:	83 ec 2c             	sub    $0x2c,%esp
f0103a46:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103a49:	e8 4b 29 00 00       	call   f0106399 <cpunum>
f0103a4e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a51:	39 b8 28 80 1e f0    	cmp    %edi,-0xfe17fd8(%eax)
f0103a57:	74 09                	je     f0103a62 <env_free+0x25>
{
f0103a59:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103a60:	eb 36                	jmp    f0103a98 <env_free+0x5b>
		lcr3(PADDR(kern_pgdir));
f0103a62:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103a67:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a6c:	77 20                	ja     f0103a8e <env_free+0x51>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a72:	c7 44 24 08 c8 6a 10 	movl   $0xf0106ac8,0x8(%esp)
f0103a79:	f0 
f0103a7a:	c7 44 24 04 b7 01 00 	movl   $0x1b7,0x4(%esp)
f0103a81:	00 
f0103a82:	c7 04 24 4d 7d 10 f0 	movl   $0xf0107d4d,(%esp)
f0103a89:	e8 b2 c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a8e:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a93:	0f 22 d8             	mov    %eax,%cr3
f0103a96:	eb c1                	jmp    f0103a59 <env_free+0x1c>
f0103a98:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103a9b:	89 c8                	mov    %ecx,%eax
f0103a9d:	c1 e0 02             	shl    $0x2,%eax
f0103aa0:	89 45 dc             	mov    %eax,-0x24(%ebp)
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++)
	{

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103aa3:	8b 47 60             	mov    0x60(%edi),%eax
f0103aa6:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f0103aa9:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103aaf:	0f 84 b7 00 00 00    	je     f0103b6c <env_free+0x12f>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103ab5:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0103abb:	89 f0                	mov    %esi,%eax
f0103abd:	c1 e8 0c             	shr    $0xc,%eax
f0103ac0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103ac3:	3b 05 88 7e 1e f0    	cmp    0xf01e7e88,%eax
f0103ac9:	72 20                	jb     f0103aeb <env_free+0xae>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103acb:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103acf:	c7 44 24 08 a4 6a 10 	movl   $0xf0106aa4,0x8(%esp)
f0103ad6:	f0 
f0103ad7:	c7 44 24 04 c7 01 00 	movl   $0x1c7,0x4(%esp)
f0103ade:	00 
f0103adf:	c7 04 24 4d 7d 10 f0 	movl   $0xf0107d4d,(%esp)
f0103ae6:	e8 55 c5 ff ff       	call   f0100040 <_panic>

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++)
		{
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103aeb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103aee:	c1 e0 16             	shl    $0x16,%eax
f0103af1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++)
f0103af4:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103af9:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103b00:	01 
f0103b01:	74 17                	je     f0103b1a <env_free+0xdd>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b03:	89 d8                	mov    %ebx,%eax
f0103b05:	c1 e0 0c             	shl    $0xc,%eax
f0103b08:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103b0b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b0f:	8b 47 60             	mov    0x60(%edi),%eax
f0103b12:	89 04 24             	mov    %eax,(%esp)
f0103b15:	e8 df d8 ff ff       	call   f01013f9 <page_remove>
		for (pteno = 0; pteno <= PTX(~0); pteno++)
f0103b1a:	83 c3 01             	add    $0x1,%ebx
f0103b1d:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103b23:	75 d4                	jne    f0103af9 <env_free+0xbc>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103b25:	8b 47 60             	mov    0x60(%edi),%eax
f0103b28:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b2b:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103b32:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103b35:	3b 05 88 7e 1e f0    	cmp    0xf01e7e88,%eax
f0103b3b:	72 1c                	jb     f0103b59 <env_free+0x11c>
		panic("pa2page called with invalid pa");
f0103b3d:	c7 44 24 08 f4 70 10 	movl   $0xf01070f4,0x8(%esp)
f0103b44:	f0 
f0103b45:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103b4c:	00 
f0103b4d:	c7 04 24 05 7a 10 f0 	movl   $0xf0107a05,(%esp)
f0103b54:	e8 e7 c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103b59:	a1 90 7e 1e f0       	mov    0xf01e7e90,%eax
f0103b5e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103b61:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0103b64:	89 04 24             	mov    %eax,(%esp)
f0103b67:	e8 75 d6 ff ff       	call   f01011e1 <page_decref>
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++)
f0103b6c:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103b70:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103b77:	0f 85 1b ff ff ff    	jne    f0103a98 <env_free+0x5b>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103b7d:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103b80:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103b85:	77 20                	ja     f0103ba7 <env_free+0x16a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103b87:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b8b:	c7 44 24 08 c8 6a 10 	movl   $0xf0106ac8,0x8(%esp)
f0103b92:	f0 
f0103b93:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
f0103b9a:	00 
f0103b9b:	c7 04 24 4d 7d 10 f0 	movl   $0xf0107d4d,(%esp)
f0103ba2:	e8 99 c4 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103ba7:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103bae:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103bb3:	c1 e8 0c             	shr    $0xc,%eax
f0103bb6:	3b 05 88 7e 1e f0    	cmp    0xf01e7e88,%eax
f0103bbc:	72 1c                	jb     f0103bda <env_free+0x19d>
		panic("pa2page called with invalid pa");
f0103bbe:	c7 44 24 08 f4 70 10 	movl   $0xf01070f4,0x8(%esp)
f0103bc5:	f0 
f0103bc6:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103bcd:	00 
f0103bce:	c7 04 24 05 7a 10 f0 	movl   $0xf0107a05,(%esp)
f0103bd5:	e8 66 c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103bda:	8b 15 90 7e 1e f0    	mov    0xf01e7e90,%edx
f0103be0:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0103be3:	89 04 24             	mov    %eax,(%esp)
f0103be6:	e8 f6 d5 ff ff       	call   f01011e1 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103beb:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103bf2:	a1 4c 72 1e f0       	mov    0xf01e724c,%eax
f0103bf7:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103bfa:	89 3d 4c 72 1e f0    	mov    %edi,0xf01e724c
}
f0103c00:	83 c4 2c             	add    $0x2c,%esp
f0103c03:	5b                   	pop    %ebx
f0103c04:	5e                   	pop    %esi
f0103c05:	5f                   	pop    %edi
f0103c06:	5d                   	pop    %ebp
f0103c07:	c3                   	ret    

f0103c08 <env_destroy>:
// Frees environment e.
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void env_destroy(struct Env *e)
{
f0103c08:	55                   	push   %ebp
f0103c09:	89 e5                	mov    %esp,%ebp
f0103c0b:	53                   	push   %ebx
f0103c0c:	83 ec 14             	sub    $0x14,%esp
f0103c0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c12:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103c16:	75 19                	jne    f0103c31 <env_destroy+0x29>
f0103c18:	e8 7c 27 00 00       	call   f0106399 <cpunum>
f0103c1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c20:	39 98 28 80 1e f0    	cmp    %ebx,-0xfe17fd8(%eax)
f0103c26:	74 09                	je     f0103c31 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103c28:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103c2f:	eb 2f                	jmp    f0103c60 <env_destroy+0x58>
	}

	env_free(e);
f0103c31:	89 1c 24             	mov    %ebx,(%esp)
f0103c34:	e8 04 fe ff ff       	call   f0103a3d <env_free>

	if (curenv == e) {
f0103c39:	e8 5b 27 00 00       	call   f0106399 <cpunum>
f0103c3e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c41:	39 98 28 80 1e f0    	cmp    %ebx,-0xfe17fd8(%eax)
f0103c47:	75 17                	jne    f0103c60 <env_destroy+0x58>
		curenv = NULL;
f0103c49:	e8 4b 27 00 00       	call   f0106399 <cpunum>
f0103c4e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c51:	c7 80 28 80 1e f0 00 	movl   $0x0,-0xfe17fd8(%eax)
f0103c58:	00 00 00 
		sched_yield();
f0103c5b:	e8 8f 0e 00 00       	call   f0104aef <sched_yield>
	}
}
f0103c60:	83 c4 14             	add    $0x14,%esp
f0103c63:	5b                   	pop    %ebx
f0103c64:	5d                   	pop    %ebp
f0103c65:	c3                   	ret    

f0103c66 <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
//
// This function does not return.
//
void env_pop_tf(struct Trapframe *tf)
{
f0103c66:	55                   	push   %ebp
f0103c67:	89 e5                	mov    %esp,%ebp
f0103c69:	53                   	push   %ebx
f0103c6a:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103c6d:	e8 27 27 00 00       	call   f0106399 <cpunum>
f0103c72:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c75:	8b 98 28 80 1e f0    	mov    -0xfe17fd8(%eax),%ebx
f0103c7b:	e8 19 27 00 00       	call   f0106399 <cpunum>
f0103c80:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103c83:	8b 65 08             	mov    0x8(%ebp),%esp
f0103c86:	61                   	popa   
f0103c87:	07                   	pop    %es
f0103c88:	1f                   	pop    %ds
f0103c89:	83 c4 08             	add    $0x8,%esp
f0103c8c:	cf                   	iret   
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		:
		: "g"(tf)
		: "memory");
	panic("iret failed"); /* mostly to placate the compiler */
f0103c8d:	c7 44 24 08 58 7d 10 	movl   $0xf0107d58,0x8(%esp)
f0103c94:	f0 
f0103c95:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
f0103c9c:	00 
f0103c9d:	c7 04 24 4d 7d 10 f0 	movl   $0xf0107d4d,(%esp)
f0103ca4:	e8 97 c3 ff ff       	call   f0100040 <_panic>

f0103ca9 <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//
// This function does not return.
// 把环境从curenv 切换到 e
void env_run(struct Env *e)
{
f0103ca9:	55                   	push   %ebp
f0103caa:	89 e5                	mov    %esp,%ebp
f0103cac:	53                   	push   %ebx
f0103cad:	83 ec 14             	sub    $0x14,%esp
f0103cb0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	if (curenv) // 如果当前有环境
f0103cb3:	e8 e1 26 00 00       	call   f0106399 <cpunum>
f0103cb8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cbb:	83 b8 28 80 1e f0 00 	cmpl   $0x0,-0xfe17fd8(%eax)
f0103cc2:	74 15                	je     f0103cd9 <env_run+0x30>
	{
		curenv->env_status = ENV_RUNNABLE; // 设置回 ENV_RUNNABLE
f0103cc4:	e8 d0 26 00 00       	call   f0106399 <cpunum>
f0103cc9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ccc:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f0103cd2:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
	curenv = e;						  // 将“curenv”设置为新环境
f0103cd9:	e8 bb 26 00 00       	call   f0106399 <cpunum>
f0103cde:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ce1:	89 98 28 80 1e f0    	mov    %ebx,-0xfe17fd8(%eax)
	curenv->env_status = ENV_RUNNING; // 将其状态设置为 ENV_RUNNING
f0103ce7:	e8 ad 26 00 00       	call   f0106399 <cpunum>
f0103cec:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cef:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f0103cf5:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;				  // 更新其“env_runs”计数器
f0103cfc:	e8 98 26 00 00       	call   f0106399 <cpunum>
f0103d01:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d04:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f0103d0a:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));	  // 切换到用户空间
f0103d0e:	e8 86 26 00 00       	call   f0106399 <cpunum>
f0103d13:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d16:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f0103d1c:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103d1f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103d24:	77 20                	ja     f0103d46 <env_run+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d26:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d2a:	c7 44 24 08 c8 6a 10 	movl   $0xf0106ac8,0x8(%esp)
f0103d31:	f0 
f0103d32:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
f0103d39:	00 
f0103d3a:	c7 04 24 4d 7d 10 f0 	movl   $0xf0107d4d,(%esp)
f0103d41:	e8 fa c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103d46:	05 00 00 00 10       	add    $0x10000000,%eax
f0103d4b:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103d4e:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0103d55:	e8 69 29 00 00       	call   f01066c3 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103d5a:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(&e->env_tf); // 恢复环境的寄存器来进入环境中的用户模式，设置%eip为可执行程序的第一条指令
f0103d5c:	89 1c 24             	mov    %ebx,(%esp)
f0103d5f:	e8 02 ff ff ff       	call   f0103c66 <env_pop_tf>

f0103d64 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103d64:	55                   	push   %ebp
f0103d65:	89 e5                	mov    %esp,%ebp
f0103d67:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103d6b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103d70:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103d71:	b2 71                	mov    $0x71,%dl
f0103d73:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103d74:	0f b6 c0             	movzbl %al,%eax
}
f0103d77:	5d                   	pop    %ebp
f0103d78:	c3                   	ret    

f0103d79 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103d79:	55                   	push   %ebp
f0103d7a:	89 e5                	mov    %esp,%ebp
f0103d7c:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103d80:	ba 70 00 00 00       	mov    $0x70,%edx
f0103d85:	ee                   	out    %al,(%dx)
f0103d86:	b2 71                	mov    $0x71,%dl
f0103d88:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103d8b:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103d8c:	5d                   	pop    %ebp
f0103d8d:	c3                   	ret    

f0103d8e <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103d8e:	55                   	push   %ebp
f0103d8f:	89 e5                	mov    %esp,%ebp
f0103d91:	56                   	push   %esi
f0103d92:	53                   	push   %ebx
f0103d93:	83 ec 10             	sub    $0x10,%esp
f0103d96:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103d99:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f0103d9f:	80 3d 50 72 1e f0 00 	cmpb   $0x0,0xf01e7250
f0103da6:	74 4e                	je     f0103df6 <irq_setmask_8259A+0x68>
f0103da8:	89 c6                	mov    %eax,%esi
f0103daa:	ba 21 00 00 00       	mov    $0x21,%edx
f0103daf:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103db0:	66 c1 e8 08          	shr    $0x8,%ax
f0103db4:	b2 a1                	mov    $0xa1,%dl
f0103db6:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103db7:	c7 04 24 64 7d 10 f0 	movl   $0xf0107d64,(%esp)
f0103dbe:	e8 0a 01 00 00       	call   f0103ecd <cprintf>
	for (i = 0; i < 16; i++)
f0103dc3:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103dc8:	0f b7 f6             	movzwl %si,%esi
f0103dcb:	f7 d6                	not    %esi
f0103dcd:	0f a3 de             	bt     %ebx,%esi
f0103dd0:	73 10                	jae    f0103de2 <irq_setmask_8259A+0x54>
			cprintf(" %d", i);
f0103dd2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103dd6:	c7 04 24 eb 81 10 f0 	movl   $0xf01081eb,(%esp)
f0103ddd:	e8 eb 00 00 00       	call   f0103ecd <cprintf>
	for (i = 0; i < 16; i++)
f0103de2:	83 c3 01             	add    $0x1,%ebx
f0103de5:	83 fb 10             	cmp    $0x10,%ebx
f0103de8:	75 e3                	jne    f0103dcd <irq_setmask_8259A+0x3f>
	cprintf("\n");
f0103dea:	c7 04 24 82 7c 10 f0 	movl   $0xf0107c82,(%esp)
f0103df1:	e8 d7 00 00 00       	call   f0103ecd <cprintf>
}
f0103df6:	83 c4 10             	add    $0x10,%esp
f0103df9:	5b                   	pop    %ebx
f0103dfa:	5e                   	pop    %esi
f0103dfb:	5d                   	pop    %ebp
f0103dfc:	c3                   	ret    

f0103dfd <pic_init>:
	didinit = 1;
f0103dfd:	c6 05 50 72 1e f0 01 	movb   $0x1,0xf01e7250
f0103e04:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103e0e:	ee                   	out    %al,(%dx)
f0103e0f:	b2 a1                	mov    $0xa1,%dl
f0103e11:	ee                   	out    %al,(%dx)
f0103e12:	b2 20                	mov    $0x20,%dl
f0103e14:	b8 11 00 00 00       	mov    $0x11,%eax
f0103e19:	ee                   	out    %al,(%dx)
f0103e1a:	b2 21                	mov    $0x21,%dl
f0103e1c:	b8 20 00 00 00       	mov    $0x20,%eax
f0103e21:	ee                   	out    %al,(%dx)
f0103e22:	b8 04 00 00 00       	mov    $0x4,%eax
f0103e27:	ee                   	out    %al,(%dx)
f0103e28:	b8 03 00 00 00       	mov    $0x3,%eax
f0103e2d:	ee                   	out    %al,(%dx)
f0103e2e:	b2 a0                	mov    $0xa0,%dl
f0103e30:	b8 11 00 00 00       	mov    $0x11,%eax
f0103e35:	ee                   	out    %al,(%dx)
f0103e36:	b2 a1                	mov    $0xa1,%dl
f0103e38:	b8 28 00 00 00       	mov    $0x28,%eax
f0103e3d:	ee                   	out    %al,(%dx)
f0103e3e:	b8 02 00 00 00       	mov    $0x2,%eax
f0103e43:	ee                   	out    %al,(%dx)
f0103e44:	b8 01 00 00 00       	mov    $0x1,%eax
f0103e49:	ee                   	out    %al,(%dx)
f0103e4a:	b2 20                	mov    $0x20,%dl
f0103e4c:	b8 68 00 00 00       	mov    $0x68,%eax
f0103e51:	ee                   	out    %al,(%dx)
f0103e52:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103e57:	ee                   	out    %al,(%dx)
f0103e58:	b2 a0                	mov    $0xa0,%dl
f0103e5a:	b8 68 00 00 00       	mov    $0x68,%eax
f0103e5f:	ee                   	out    %al,(%dx)
f0103e60:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103e65:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103e66:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0103e6d:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103e71:	74 12                	je     f0103e85 <pic_init+0x88>
{
f0103e73:	55                   	push   %ebp
f0103e74:	89 e5                	mov    %esp,%ebp
f0103e76:	83 ec 18             	sub    $0x18,%esp
		irq_setmask_8259A(irq_mask_8259A);
f0103e79:	0f b7 c0             	movzwl %ax,%eax
f0103e7c:	89 04 24             	mov    %eax,(%esp)
f0103e7f:	e8 0a ff ff ff       	call   f0103d8e <irq_setmask_8259A>
}
f0103e84:	c9                   	leave  
f0103e85:	f3 c3                	repz ret 

f0103e87 <putch>:
#include <inc/stdio.h>
#include <inc/stdarg.h>

// putch通过调用console.c中的cputchar来实现输出字符串到控制台。
static void putch(int ch, int *cnt)
{
f0103e87:	55                   	push   %ebp
f0103e88:	89 e5                	mov    %esp,%ebp
f0103e8a:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103e8d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e90:	89 04 24             	mov    %eax,(%esp)
f0103e93:	e8 1f c9 ff ff       	call   f01007b7 <cputchar>
	*cnt++;
}
f0103e98:	c9                   	leave  
f0103e99:	c3                   	ret    

f0103e9a <vcprintf>:

// 将格式fmt和可变参数列表ap一起传给printfmt.c中的vprintfmt处理
int vcprintf(const char *fmt, va_list ap)
{
f0103e9a:	55                   	push   %ebp
f0103e9b:	89 e5                	mov    %esp,%ebp
f0103e9d:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103ea0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	vprintfmt((void *)putch, &cnt, fmt, ap); // 用一个指向putch的函数指针来告诉vprintfmt，处理后的数据应该交给putch来输出
f0103ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103eaa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103eae:	8b 45 08             	mov    0x8(%ebp),%eax
f0103eb1:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103eb5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103eb8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ebc:	c7 04 24 87 3e 10 f0 	movl   $0xf0103e87,(%esp)
f0103ec3:	e8 b6 17 00 00       	call   f010567e <vprintfmt>
	return cnt;
}
f0103ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103ecb:	c9                   	leave  
f0103ecc:	c3                   	ret    

f0103ecd <cprintf>:

// 这个函数作为实现打印功能的主要函数，暴露给其他程序。其第一个参数是包含输出格式的字符串，后面是可变参数列表。
int cprintf(const char *fmt, ...)
{
f0103ecd:	55                   	push   %ebp
f0103ece:	89 e5                	mov    %esp,%ebp
f0103ed0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);		 // 获取可变参数列表ap
f0103ed3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap); // 传参
f0103ed6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103eda:	8b 45 08             	mov    0x8(%ebp),%eax
f0103edd:	89 04 24             	mov    %eax,(%esp)
f0103ee0:	e8 b5 ff ff ff       	call   f0103e9a <vcprintf>
	va_end(ap);

	return cnt;
}
f0103ee5:	c9                   	leave  
f0103ee6:	c3                   	ret    
f0103ee7:	66 90                	xchg   %ax,%ax
f0103ee9:	66 90                	xchg   %ax,%ax
f0103eeb:	66 90                	xchg   %ax,%ax
f0103eed:	66 90                	xchg   %ax,%ax
f0103eef:	90                   	nop

f0103ef0 <trap_init_percpu>:
	// Per-CPU setup
	trap_init_percpu();
}

void trap_init_percpu(void) // 初始化TSS和IDT
{
f0103ef0:	55                   	push   %ebp
f0103ef1:	89 e5                	mov    %esp,%ebp
f0103ef3:	53                   	push   %ebx
f0103ef4:	83 ec 04             	sub    $0x4,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	size_t i = cpunum();								   // 拿到现在运行的cpuid
f0103ef7:	e8 9d 24 00 00       	call   f0106399 <cpunum>
	struct Taskstate *ts = &cpus[i].cpu_ts;				   // 这里这样取cpuinfo，因为直接用thiscpu会爆出triple fault
f0103efc:	6b c8 74             	imul   $0x74,%eax,%ecx
	ts->ts_esp0 = (uintptr_t)percpu_kstacks[i] + KSTKSIZE; // esp0: 指代当前 CPU 的 stack 的起始位置
f0103eff:	89 c2                	mov    %eax,%edx
f0103f01:	c1 e2 0f             	shl    $0xf,%edx
f0103f04:	81 c2 00 10 1f f0    	add    $0xf01f1000,%edx
f0103f0a:	89 91 30 80 1e f0    	mov    %edx,-0xfe17fd0(%ecx)
	ts->ts_ss0 = GD_KD;									   // 表示 esp0 这个位置存储的是 kernel 的 data
f0103f10:	66 c7 81 34 80 1e f0 	movw   $0x10,-0xfe17fcc(%ecx)
f0103f17:	10 00 
	ts->ts_iomb = sizeof(struct Taskstate);
f0103f19:	66 c7 81 92 80 1e f0 	movw   $0x68,-0xfe17f6e(%ecx)
f0103f20:	68 00 
	struct Taskstate *ts = &cpus[i].cpu_ts;				   // 这里这样取cpuinfo，因为直接用thiscpu会爆出triple fault
f0103f22:	81 c1 2c 80 1e f0    	add    $0xf01e802c,%ecx

	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t)ts, sizeof(struct Taskstate) - 1, 0);
f0103f28:	8d 50 05             	lea    0x5(%eax),%edx
f0103f2b:	66 c7 04 d5 40 13 12 	movw   $0x67,-0xfedecc0(,%edx,8)
f0103f32:	f0 67 00 
f0103f35:	66 89 0c d5 42 13 12 	mov    %cx,-0xfedecbe(,%edx,8)
f0103f3c:	f0 
f0103f3d:	89 cb                	mov    %ecx,%ebx
f0103f3f:	c1 eb 10             	shr    $0x10,%ebx
f0103f42:	88 1c d5 44 13 12 f0 	mov    %bl,-0xfedecbc(,%edx,8)
f0103f49:	c6 04 d5 46 13 12 f0 	movb   $0x40,-0xfedecba(,%edx,8)
f0103f50:	40 
f0103f51:	c1 e9 18             	shr    $0x18,%ecx
f0103f54:	88 0c d5 47 13 12 f0 	mov    %cl,-0xfedecb9(,%edx,8)
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f0103f5b:	c6 04 d5 45 13 12 f0 	movb   $0x89,-0xfedecbb(,%edx,8)
f0103f62:	89 

	ltr(GD_TSS0 + (i << 3));
f0103f63:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
	asm volatile("ltr %0" : : "r" (sel));
f0103f6a:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0103f6d:	b8 aa 13 12 f0       	mov    $0xf01213aa,%eax
f0103f72:	0f 01 18             	lidtl  (%eax)

	lidt(&idt_pd);
}
f0103f75:	83 c4 04             	add    $0x4,%esp
f0103f78:	5b                   	pop    %ebx
f0103f79:	5d                   	pop    %ebp
f0103f7a:	c3                   	ret    

f0103f7b <trap_init>:
{
f0103f7b:	55                   	push   %ebp
f0103f7c:	89 e5                	mov    %esp,%ebp
f0103f7e:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], 1, GD_KT, DIVIDE_Handler, 0); // SETGATE设置一个idt条目
f0103f81:	b8 86 49 10 f0       	mov    $0xf0104986,%eax
f0103f86:	66 a3 60 72 1e f0    	mov    %ax,0xf01e7260
f0103f8c:	66 c7 05 62 72 1e f0 	movw   $0x8,0xf01e7262
f0103f93:	08 00 
f0103f95:	c6 05 64 72 1e f0 00 	movb   $0x0,0xf01e7264
f0103f9c:	c6 05 65 72 1e f0 8f 	movb   $0x8f,0xf01e7265
f0103fa3:	c1 e8 10             	shr    $0x10,%eax
f0103fa6:	66 a3 66 72 1e f0    	mov    %ax,0xf01e7266
	SETGATE(idt[T_DEBUG], 1, GD_KT, DEBUG_Handler, 3);
f0103fac:	b8 8c 49 10 f0       	mov    $0xf010498c,%eax
f0103fb1:	66 a3 68 72 1e f0    	mov    %ax,0xf01e7268
f0103fb7:	66 c7 05 6a 72 1e f0 	movw   $0x8,0xf01e726a
f0103fbe:	08 00 
f0103fc0:	c6 05 6c 72 1e f0 00 	movb   $0x0,0xf01e726c
f0103fc7:	c6 05 6d 72 1e f0 ef 	movb   $0xef,0xf01e726d
f0103fce:	c1 e8 10             	shr    $0x10,%eax
f0103fd1:	66 a3 6e 72 1e f0    	mov    %ax,0xf01e726e
	SETGATE(idt[T_NMI], 1, GD_KT, NMI_Handler, 0);
f0103fd7:	b8 92 49 10 f0       	mov    $0xf0104992,%eax
f0103fdc:	66 a3 70 72 1e f0    	mov    %ax,0xf01e7270
f0103fe2:	66 c7 05 72 72 1e f0 	movw   $0x8,0xf01e7272
f0103fe9:	08 00 
f0103feb:	c6 05 74 72 1e f0 00 	movb   $0x0,0xf01e7274
f0103ff2:	c6 05 75 72 1e f0 8f 	movb   $0x8f,0xf01e7275
f0103ff9:	c1 e8 10             	shr    $0x10,%eax
f0103ffc:	66 a3 76 72 1e f0    	mov    %ax,0xf01e7276
	SETGATE(idt[T_BRKPT], 1, GD_KT, BRKPT_Handler, 3);
f0104002:	b8 98 49 10 f0       	mov    $0xf0104998,%eax
f0104007:	66 a3 78 72 1e f0    	mov    %ax,0xf01e7278
f010400d:	66 c7 05 7a 72 1e f0 	movw   $0x8,0xf01e727a
f0104014:	08 00 
f0104016:	c6 05 7c 72 1e f0 00 	movb   $0x0,0xf01e727c
f010401d:	c6 05 7d 72 1e f0 ef 	movb   $0xef,0xf01e727d
f0104024:	c1 e8 10             	shr    $0x10,%eax
f0104027:	66 a3 7e 72 1e f0    	mov    %ax,0xf01e727e
	SETGATE(idt[T_OFLOW], 1, GD_KT, OFLOW_Handler, 0);
f010402d:	b8 9e 49 10 f0       	mov    $0xf010499e,%eax
f0104032:	66 a3 80 72 1e f0    	mov    %ax,0xf01e7280
f0104038:	66 c7 05 82 72 1e f0 	movw   $0x8,0xf01e7282
f010403f:	08 00 
f0104041:	c6 05 84 72 1e f0 00 	movb   $0x0,0xf01e7284
f0104048:	c6 05 85 72 1e f0 8f 	movb   $0x8f,0xf01e7285
f010404f:	c1 e8 10             	shr    $0x10,%eax
f0104052:	66 a3 86 72 1e f0    	mov    %ax,0xf01e7286
	SETGATE(idt[T_BOUND], 1, GD_KT, BOUND_Handler, 0);
f0104058:	b8 a4 49 10 f0       	mov    $0xf01049a4,%eax
f010405d:	66 a3 88 72 1e f0    	mov    %ax,0xf01e7288
f0104063:	66 c7 05 8a 72 1e f0 	movw   $0x8,0xf01e728a
f010406a:	08 00 
f010406c:	c6 05 8c 72 1e f0 00 	movb   $0x0,0xf01e728c
f0104073:	c6 05 8d 72 1e f0 8f 	movb   $0x8f,0xf01e728d
f010407a:	c1 e8 10             	shr    $0x10,%eax
f010407d:	66 a3 8e 72 1e f0    	mov    %ax,0xf01e728e
	SETGATE(idt[T_ILLOP], 1, GD_KT, ILLOP_Handler, 0);
f0104083:	b8 aa 49 10 f0       	mov    $0xf01049aa,%eax
f0104088:	66 a3 90 72 1e f0    	mov    %ax,0xf01e7290
f010408e:	66 c7 05 92 72 1e f0 	movw   $0x8,0xf01e7292
f0104095:	08 00 
f0104097:	c6 05 94 72 1e f0 00 	movb   $0x0,0xf01e7294
f010409e:	c6 05 95 72 1e f0 8f 	movb   $0x8f,0xf01e7295
f01040a5:	c1 e8 10             	shr    $0x10,%eax
f01040a8:	66 a3 96 72 1e f0    	mov    %ax,0xf01e7296
	SETGATE(idt[T_DEVICE], 1, GD_KT, DEVICE_Handler, 0);
f01040ae:	b8 b0 49 10 f0       	mov    $0xf01049b0,%eax
f01040b3:	66 a3 98 72 1e f0    	mov    %ax,0xf01e7298
f01040b9:	66 c7 05 9a 72 1e f0 	movw   $0x8,0xf01e729a
f01040c0:	08 00 
f01040c2:	c6 05 9c 72 1e f0 00 	movb   $0x0,0xf01e729c
f01040c9:	c6 05 9d 72 1e f0 8f 	movb   $0x8f,0xf01e729d
f01040d0:	c1 e8 10             	shr    $0x10,%eax
f01040d3:	66 a3 9e 72 1e f0    	mov    %ax,0xf01e729e
	SETGATE(idt[T_DBLFLT], 1, GD_KT, DBLFLT_Handler, 0);
f01040d9:	b8 b6 49 10 f0       	mov    $0xf01049b6,%eax
f01040de:	66 a3 a0 72 1e f0    	mov    %ax,0xf01e72a0
f01040e4:	66 c7 05 a2 72 1e f0 	movw   $0x8,0xf01e72a2
f01040eb:	08 00 
f01040ed:	c6 05 a4 72 1e f0 00 	movb   $0x0,0xf01e72a4
f01040f4:	c6 05 a5 72 1e f0 8f 	movb   $0x8f,0xf01e72a5
f01040fb:	c1 e8 10             	shr    $0x10,%eax
f01040fe:	66 a3 a6 72 1e f0    	mov    %ax,0xf01e72a6
	SETGATE(idt[T_TSS], 1, GD_KT, TSS_Handler, 0);
f0104104:	b8 ba 49 10 f0       	mov    $0xf01049ba,%eax
f0104109:	66 a3 b0 72 1e f0    	mov    %ax,0xf01e72b0
f010410f:	66 c7 05 b2 72 1e f0 	movw   $0x8,0xf01e72b2
f0104116:	08 00 
f0104118:	c6 05 b4 72 1e f0 00 	movb   $0x0,0xf01e72b4
f010411f:	c6 05 b5 72 1e f0 8f 	movb   $0x8f,0xf01e72b5
f0104126:	c1 e8 10             	shr    $0x10,%eax
f0104129:	66 a3 b6 72 1e f0    	mov    %ax,0xf01e72b6
	SETGATE(idt[T_SEGNP], 1, GD_KT, SEGNP_Handler, 0);
f010412f:	b8 be 49 10 f0       	mov    $0xf01049be,%eax
f0104134:	66 a3 b8 72 1e f0    	mov    %ax,0xf01e72b8
f010413a:	66 c7 05 ba 72 1e f0 	movw   $0x8,0xf01e72ba
f0104141:	08 00 
f0104143:	c6 05 bc 72 1e f0 00 	movb   $0x0,0xf01e72bc
f010414a:	c6 05 bd 72 1e f0 8f 	movb   $0x8f,0xf01e72bd
f0104151:	c1 e8 10             	shr    $0x10,%eax
f0104154:	66 a3 be 72 1e f0    	mov    %ax,0xf01e72be
	SETGATE(idt[T_STACK], 1, GD_KT, STACK_Handler, 0);
f010415a:	b8 c2 49 10 f0       	mov    $0xf01049c2,%eax
f010415f:	66 a3 c0 72 1e f0    	mov    %ax,0xf01e72c0
f0104165:	66 c7 05 c2 72 1e f0 	movw   $0x8,0xf01e72c2
f010416c:	08 00 
f010416e:	c6 05 c4 72 1e f0 00 	movb   $0x0,0xf01e72c4
f0104175:	c6 05 c5 72 1e f0 8f 	movb   $0x8f,0xf01e72c5
f010417c:	c1 e8 10             	shr    $0x10,%eax
f010417f:	66 a3 c6 72 1e f0    	mov    %ax,0xf01e72c6
	SETGATE(idt[T_GPFLT], 1, GD_KT, GPFLT_Handler, 0);
f0104185:	b8 c6 49 10 f0       	mov    $0xf01049c6,%eax
f010418a:	66 a3 c8 72 1e f0    	mov    %ax,0xf01e72c8
f0104190:	66 c7 05 ca 72 1e f0 	movw   $0x8,0xf01e72ca
f0104197:	08 00 
f0104199:	c6 05 cc 72 1e f0 00 	movb   $0x0,0xf01e72cc
f01041a0:	c6 05 cd 72 1e f0 8f 	movb   $0x8f,0xf01e72cd
f01041a7:	c1 e8 10             	shr    $0x10,%eax
f01041aa:	66 a3 ce 72 1e f0    	mov    %ax,0xf01e72ce
	SETGATE(idt[T_PGFLT], 1, GD_KT, PGFLT_Handler, 0);
f01041b0:	b8 ca 49 10 f0       	mov    $0xf01049ca,%eax
f01041b5:	66 a3 d0 72 1e f0    	mov    %ax,0xf01e72d0
f01041bb:	66 c7 05 d2 72 1e f0 	movw   $0x8,0xf01e72d2
f01041c2:	08 00 
f01041c4:	c6 05 d4 72 1e f0 00 	movb   $0x0,0xf01e72d4
f01041cb:	c6 05 d5 72 1e f0 8f 	movb   $0x8f,0xf01e72d5
f01041d2:	89 c2                	mov    %eax,%edx
f01041d4:	c1 ea 10             	shr    $0x10,%edx
f01041d7:	66 89 15 d6 72 1e f0 	mov    %dx,0xf01e72d6
	SETGATE(idt[T_FPERR], 1, GD_KT, FPERR_Handler, 0);
f01041de:	b9 ce 49 10 f0       	mov    $0xf01049ce,%ecx
f01041e3:	66 89 0d e0 72 1e f0 	mov    %cx,0xf01e72e0
f01041ea:	66 c7 05 e2 72 1e f0 	movw   $0x8,0xf01e72e2
f01041f1:	08 00 
f01041f3:	c6 05 e4 72 1e f0 00 	movb   $0x0,0xf01e72e4
f01041fa:	c6 05 e5 72 1e f0 8f 	movb   $0x8f,0xf01e72e5
f0104201:	c1 e9 10             	shr    $0x10,%ecx
f0104204:	66 89 0d e6 72 1e f0 	mov    %cx,0xf01e72e6
	SETGATE(idt[T_ALIGN], 1, GD_KT, ALIGN_Handler, 0);
f010420b:	b9 d2 49 10 f0       	mov    $0xf01049d2,%ecx
f0104210:	66 89 0d e8 72 1e f0 	mov    %cx,0xf01e72e8
f0104217:	66 c7 05 ea 72 1e f0 	movw   $0x8,0xf01e72ea
f010421e:	08 00 
f0104220:	c6 05 ec 72 1e f0 00 	movb   $0x0,0xf01e72ec
f0104227:	c6 05 ed 72 1e f0 8f 	movb   $0x8f,0xf01e72ed
f010422e:	c1 e9 10             	shr    $0x10,%ecx
f0104231:	66 89 0d ee 72 1e f0 	mov    %cx,0xf01e72ee
	SETGATE(idt[T_MCHK], 1, GD_KT, MCHK_Handler, 0);
f0104238:	b9 d6 49 10 f0       	mov    $0xf01049d6,%ecx
f010423d:	66 89 0d f0 72 1e f0 	mov    %cx,0xf01e72f0
f0104244:	66 c7 05 f2 72 1e f0 	movw   $0x8,0xf01e72f2
f010424b:	08 00 
f010424d:	c6 05 f4 72 1e f0 00 	movb   $0x0,0xf01e72f4
f0104254:	c6 05 f5 72 1e f0 8f 	movb   $0x8f,0xf01e72f5
f010425b:	c1 e9 10             	shr    $0x10,%ecx
f010425e:	66 89 0d f6 72 1e f0 	mov    %cx,0xf01e72f6
	SETGATE(idt[T_SIMDERR], 1, GD_KT, PGFLT_Handler, 0);
f0104265:	66 a3 f8 72 1e f0    	mov    %ax,0xf01e72f8
f010426b:	66 c7 05 fa 72 1e f0 	movw   $0x8,0xf01e72fa
f0104272:	08 00 
f0104274:	c6 05 fc 72 1e f0 00 	movb   $0x0,0xf01e72fc
f010427b:	c6 05 fd 72 1e f0 8f 	movb   $0x8f,0xf01e72fd
f0104282:	66 89 15 fe 72 1e f0 	mov    %dx,0xf01e72fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, SYSCALL_Handler, 3);
f0104289:	b8 de 49 10 f0       	mov    $0xf01049de,%eax
f010428e:	66 a3 e0 73 1e f0    	mov    %ax,0xf01e73e0
f0104294:	66 c7 05 e2 73 1e f0 	movw   $0x8,0xf01e73e2
f010429b:	08 00 
f010429d:	c6 05 e4 73 1e f0 00 	movb   $0x0,0xf01e73e4
f01042a4:	c6 05 e5 73 1e f0 ee 	movb   $0xee,0xf01e73e5
f01042ab:	c1 e8 10             	shr    $0x10,%eax
f01042ae:	66 a3 e6 73 1e f0    	mov    %ax,0xf01e73e6
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 1, GD_KT, IRQ_TIMER_Handler, 0);
f01042b4:	b8 e4 49 10 f0       	mov    $0xf01049e4,%eax
f01042b9:	66 a3 60 73 1e f0    	mov    %ax,0xf01e7360
f01042bf:	66 c7 05 62 73 1e f0 	movw   $0x8,0xf01e7362
f01042c6:	08 00 
f01042c8:	c6 05 64 73 1e f0 00 	movb   $0x0,0xf01e7364
f01042cf:	c6 05 65 73 1e f0 8f 	movb   $0x8f,0xf01e7365
f01042d6:	c1 e8 10             	shr    $0x10,%eax
f01042d9:	66 a3 66 73 1e f0    	mov    %ax,0xf01e7366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 1, GD_KT, IRQ_KBD_Handler, 0);
f01042df:	b8 ea 49 10 f0       	mov    $0xf01049ea,%eax
f01042e4:	66 a3 68 73 1e f0    	mov    %ax,0xf01e7368
f01042ea:	66 c7 05 6a 73 1e f0 	movw   $0x8,0xf01e736a
f01042f1:	08 00 
f01042f3:	c6 05 6c 73 1e f0 00 	movb   $0x0,0xf01e736c
f01042fa:	c6 05 6d 73 1e f0 8f 	movb   $0x8f,0xf01e736d
f0104301:	c1 e8 10             	shr    $0x10,%eax
f0104304:	66 a3 6e 73 1e f0    	mov    %ax,0xf01e736e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 1, GD_KT, IRQ_SERIAL_Handler, 0);
f010430a:	b8 f0 49 10 f0       	mov    $0xf01049f0,%eax
f010430f:	66 a3 80 73 1e f0    	mov    %ax,0xf01e7380
f0104315:	66 c7 05 82 73 1e f0 	movw   $0x8,0xf01e7382
f010431c:	08 00 
f010431e:	c6 05 84 73 1e f0 00 	movb   $0x0,0xf01e7384
f0104325:	c6 05 85 73 1e f0 8f 	movb   $0x8f,0xf01e7385
f010432c:	c1 e8 10             	shr    $0x10,%eax
f010432f:	66 a3 86 73 1e f0    	mov    %ax,0xf01e7386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 1, GD_KT, IRQ_SPURIOUS_Handler, 0);
f0104335:	b8 f6 49 10 f0       	mov    $0xf01049f6,%eax
f010433a:	66 a3 98 73 1e f0    	mov    %ax,0xf01e7398
f0104340:	66 c7 05 9a 73 1e f0 	movw   $0x8,0xf01e739a
f0104347:	08 00 
f0104349:	c6 05 9c 73 1e f0 00 	movb   $0x0,0xf01e739c
f0104350:	c6 05 9d 73 1e f0 8f 	movb   $0x8f,0xf01e739d
f0104357:	c1 e8 10             	shr    $0x10,%eax
f010435a:	66 a3 9e 73 1e f0    	mov    %ax,0xf01e739e
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 1, GD_KT, IRQ_IDE_Handler, 0);
f0104360:	b8 fc 49 10 f0       	mov    $0xf01049fc,%eax
f0104365:	66 a3 d0 73 1e f0    	mov    %ax,0xf01e73d0
f010436b:	66 c7 05 d2 73 1e f0 	movw   $0x8,0xf01e73d2
f0104372:	08 00 
f0104374:	c6 05 d4 73 1e f0 00 	movb   $0x0,0xf01e73d4
f010437b:	c6 05 d5 73 1e f0 8f 	movb   $0x8f,0xf01e73d5
f0104382:	c1 e8 10             	shr    $0x10,%eax
f0104385:	66 a3 d6 73 1e f0    	mov    %ax,0xf01e73d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 1, GD_KT, IRQ_ERROR_Handler, 0);
f010438b:	b8 02 4a 10 f0       	mov    $0xf0104a02,%eax
f0104390:	66 a3 f8 73 1e f0    	mov    %ax,0xf01e73f8
f0104396:	66 c7 05 fa 73 1e f0 	movw   $0x8,0xf01e73fa
f010439d:	08 00 
f010439f:	c6 05 fc 73 1e f0 00 	movb   $0x0,0xf01e73fc
f01043a6:	c6 05 fd 73 1e f0 8f 	movb   $0x8f,0xf01e73fd
f01043ad:	c1 e8 10             	shr    $0x10,%eax
f01043b0:	66 a3 fe 73 1e f0    	mov    %ax,0xf01e73fe
	trap_init_percpu();
f01043b6:	e8 35 fb ff ff       	call   f0103ef0 <trap_init_percpu>
}
f01043bb:	c9                   	leave  
f01043bc:	c3                   	ret    

f01043bd <print_regs>:
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
	}
}

void print_regs(struct PushRegs *regs) // 打印寄存器的值，print_trapframe()的辅助函数
{
f01043bd:	55                   	push   %ebp
f01043be:	89 e5                	mov    %esp,%ebp
f01043c0:	53                   	push   %ebx
f01043c1:	83 ec 14             	sub    $0x14,%esp
f01043c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01043c7:	8b 03                	mov    (%ebx),%eax
f01043c9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043cd:	c7 04 24 78 7d 10 f0 	movl   $0xf0107d78,(%esp)
f01043d4:	e8 f4 fa ff ff       	call   f0103ecd <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01043d9:	8b 43 04             	mov    0x4(%ebx),%eax
f01043dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043e0:	c7 04 24 87 7d 10 f0 	movl   $0xf0107d87,(%esp)
f01043e7:	e8 e1 fa ff ff       	call   f0103ecd <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01043ec:	8b 43 08             	mov    0x8(%ebx),%eax
f01043ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043f3:	c7 04 24 96 7d 10 f0 	movl   $0xf0107d96,(%esp)
f01043fa:	e8 ce fa ff ff       	call   f0103ecd <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01043ff:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104402:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104406:	c7 04 24 a5 7d 10 f0 	movl   $0xf0107da5,(%esp)
f010440d:	e8 bb fa ff ff       	call   f0103ecd <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104412:	8b 43 10             	mov    0x10(%ebx),%eax
f0104415:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104419:	c7 04 24 b4 7d 10 f0 	movl   $0xf0107db4,(%esp)
f0104420:	e8 a8 fa ff ff       	call   f0103ecd <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104425:	8b 43 14             	mov    0x14(%ebx),%eax
f0104428:	89 44 24 04          	mov    %eax,0x4(%esp)
f010442c:	c7 04 24 c3 7d 10 f0 	movl   $0xf0107dc3,(%esp)
f0104433:	e8 95 fa ff ff       	call   f0103ecd <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104438:	8b 43 18             	mov    0x18(%ebx),%eax
f010443b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010443f:	c7 04 24 d2 7d 10 f0 	movl   $0xf0107dd2,(%esp)
f0104446:	e8 82 fa ff ff       	call   f0103ecd <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010444b:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010444e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104452:	c7 04 24 e1 7d 10 f0 	movl   $0xf0107de1,(%esp)
f0104459:	e8 6f fa ff ff       	call   f0103ecd <cprintf>
}
f010445e:	83 c4 14             	add    $0x14,%esp
f0104461:	5b                   	pop    %ebx
f0104462:	5d                   	pop    %ebp
f0104463:	c3                   	ret    

f0104464 <print_trapframe>:
{
f0104464:	55                   	push   %ebp
f0104465:	89 e5                	mov    %esp,%ebp
f0104467:	56                   	push   %esi
f0104468:	53                   	push   %ebx
f0104469:	83 ec 10             	sub    $0x10,%esp
f010446c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f010446f:	e8 25 1f 00 00       	call   f0106399 <cpunum>
f0104474:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104478:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010447c:	c7 04 24 45 7e 10 f0 	movl   $0xf0107e45,(%esp)
f0104483:	e8 45 fa ff ff       	call   f0103ecd <cprintf>
	print_regs(&tf->tf_regs);
f0104488:	89 1c 24             	mov    %ebx,(%esp)
f010448b:	e8 2d ff ff ff       	call   f01043bd <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104490:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104494:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104498:	c7 04 24 63 7e 10 f0 	movl   $0xf0107e63,(%esp)
f010449f:	e8 29 fa ff ff       	call   f0103ecd <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01044a4:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01044a8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044ac:	c7 04 24 76 7e 10 f0 	movl   $0xf0107e76,(%esp)
f01044b3:	e8 15 fa ff ff       	call   f0103ecd <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01044b8:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f01044bb:	83 f8 13             	cmp    $0x13,%eax
f01044be:	77 09                	ja     f01044c9 <print_trapframe+0x65>
		return excnames[trapno];
f01044c0:	8b 14 85 00 81 10 f0 	mov    -0xfef7f00(,%eax,4),%edx
f01044c7:	eb 1f                	jmp    f01044e8 <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f01044c9:	83 f8 30             	cmp    $0x30,%eax
f01044cc:	74 15                	je     f01044e3 <print_trapframe+0x7f>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01044ce:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f01044d1:	83 fa 0f             	cmp    $0xf,%edx
f01044d4:	ba fc 7d 10 f0       	mov    $0xf0107dfc,%edx
f01044d9:	b9 0f 7e 10 f0       	mov    $0xf0107e0f,%ecx
f01044de:	0f 47 d1             	cmova  %ecx,%edx
f01044e1:	eb 05                	jmp    f01044e8 <print_trapframe+0x84>
		return "System call";
f01044e3:	ba f0 7d 10 f0       	mov    $0xf0107df0,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01044e8:	89 54 24 08          	mov    %edx,0x8(%esp)
f01044ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044f0:	c7 04 24 89 7e 10 f0 	movl   $0xf0107e89,(%esp)
f01044f7:	e8 d1 f9 ff ff       	call   f0103ecd <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01044fc:	3b 1d 60 7a 1e f0    	cmp    0xf01e7a60,%ebx
f0104502:	75 19                	jne    f010451d <print_trapframe+0xb9>
f0104504:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104508:	75 13                	jne    f010451d <print_trapframe+0xb9>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010450a:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010450d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104511:	c7 04 24 9b 7e 10 f0 	movl   $0xf0107e9b,(%esp)
f0104518:	e8 b0 f9 ff ff       	call   f0103ecd <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f010451d:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104520:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104524:	c7 04 24 aa 7e 10 f0 	movl   $0xf0107eaa,(%esp)
f010452b:	e8 9d f9 ff ff       	call   f0103ecd <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0104530:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104534:	75 51                	jne    f0104587 <print_trapframe+0x123>
				tf->tf_err & 1 ? "protection" : "not-present");
f0104536:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0104539:	89 c2                	mov    %eax,%edx
f010453b:	83 e2 01             	and    $0x1,%edx
f010453e:	ba 1e 7e 10 f0       	mov    $0xf0107e1e,%edx
f0104543:	b9 29 7e 10 f0       	mov    $0xf0107e29,%ecx
f0104548:	0f 45 ca             	cmovne %edx,%ecx
f010454b:	89 c2                	mov    %eax,%edx
f010454d:	83 e2 02             	and    $0x2,%edx
f0104550:	ba 35 7e 10 f0       	mov    $0xf0107e35,%edx
f0104555:	be 3b 7e 10 f0       	mov    $0xf0107e3b,%esi
f010455a:	0f 44 d6             	cmove  %esi,%edx
f010455d:	83 e0 04             	and    $0x4,%eax
f0104560:	b8 40 7e 10 f0       	mov    $0xf0107e40,%eax
f0104565:	be 5c 7f 10 f0       	mov    $0xf0107f5c,%esi
f010456a:	0f 44 c6             	cmove  %esi,%eax
f010456d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104571:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104575:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104579:	c7 04 24 b8 7e 10 f0 	movl   $0xf0107eb8,(%esp)
f0104580:	e8 48 f9 ff ff       	call   f0103ecd <cprintf>
f0104585:	eb 0c                	jmp    f0104593 <print_trapframe+0x12f>
		cprintf("\n");
f0104587:	c7 04 24 82 7c 10 f0 	movl   $0xf0107c82,(%esp)
f010458e:	e8 3a f9 ff ff       	call   f0103ecd <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104593:	8b 43 30             	mov    0x30(%ebx),%eax
f0104596:	89 44 24 04          	mov    %eax,0x4(%esp)
f010459a:	c7 04 24 c7 7e 10 f0 	movl   $0xf0107ec7,(%esp)
f01045a1:	e8 27 f9 ff ff       	call   f0103ecd <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01045a6:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01045aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045ae:	c7 04 24 d6 7e 10 f0 	movl   $0xf0107ed6,(%esp)
f01045b5:	e8 13 f9 ff ff       	call   f0103ecd <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01045ba:	8b 43 38             	mov    0x38(%ebx),%eax
f01045bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045c1:	c7 04 24 e9 7e 10 f0 	movl   $0xf0107ee9,(%esp)
f01045c8:	e8 00 f9 ff ff       	call   f0103ecd <cprintf>
	if ((tf->tf_cs & 3) != 0)
f01045cd:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01045d1:	74 27                	je     f01045fa <print_trapframe+0x196>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01045d3:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01045d6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045da:	c7 04 24 f8 7e 10 f0 	movl   $0xf0107ef8,(%esp)
f01045e1:	e8 e7 f8 ff ff       	call   f0103ecd <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01045e6:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01045ea:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045ee:	c7 04 24 07 7f 10 f0 	movl   $0xf0107f07,(%esp)
f01045f5:	e8 d3 f8 ff ff       	call   f0103ecd <cprintf>
}
f01045fa:	83 c4 10             	add    $0x10,%esp
f01045fd:	5b                   	pop    %ebx
f01045fe:	5e                   	pop    %esi
f01045ff:	5d                   	pop    %ebp
f0104600:	c3                   	ret    

f0104601 <page_fault_handler>:
	else
		sched_yield();
}

void page_fault_handler(struct Trapframe *tf) // 特殊处理页错误中断
{
f0104601:	55                   	push   %ebp
f0104602:	89 e5                	mov    %esp,%ebp
f0104604:	57                   	push   %edi
f0104605:	56                   	push   %esi
f0104606:	53                   	push   %ebx
f0104607:	83 ec 2c             	sub    $0x2c,%esp
f010460a:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010460d:	0f 20 d6             	mov    %cr2,%esi
	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0) // 处于内核模式
f0104610:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104614:	75 1c                	jne    f0104632 <page_fault_handler+0x31>
	{
		panic("page_fault_handler(): kernel-mode page faults");
f0104616:	c7 44 24 08 a8 80 10 	movl   $0xf01080a8,0x8(%esp)
f010461d:	f0 
f010461e:	c7 44 24 04 65 01 00 	movl   $0x165,0x4(%esp)
f0104625:	00 
f0104626:	c7 04 24 1a 7f 10 f0 	movl   $0xf0107f1a,(%esp)
f010462d:	e8 0e ba ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	// 现在处于用户模式
	if (curenv->env_pgfault_upcall != NULL) // 用户模式下的页面错误处理程序如果有设置
f0104632:	e8 62 1d 00 00       	call   f0106399 <cpunum>
f0104637:	6b c0 74             	imul   $0x74,%eax,%eax
f010463a:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f0104640:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104644:	0f 84 d8 00 00 00    	je     f0104722 <page_fault_handler+0x121>
	{
		uintptr_t addr;

		if (tf->tf_esp >= UXSTACKTOP - PGSIZE && tf->tf_esp < UXSTACKTOP) // 如果发生异常时用户环境已经在用户异常堆栈上运行
f010464a:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010464d:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			addr = tf->tf_esp - sizeof(struct UTrapframe) - sizeof(int);  // 在tf->tf_esp处设置页面错误堆栈帧UTrapframe
f0104653:	83 e8 38             	sub    $0x38,%eax
f0104656:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010465c:	ba c8 ff bf ee       	mov    $0xeebfffc8,%edx
f0104661:	0f 46 d0             	cmovbe %eax,%edx
f0104664:	89 d7                	mov    %edx,%edi
f0104666:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		else
			addr = UXSTACKTOP - sizeof(struct UTrapframe) - sizeof(int); // 栈帧的区间[UXSTACKTOP - sizeof(struct UTrapframe) - sizeof(int),UXSTACKTOP]
		user_mem_assert(curenv, (void *)addr, sizeof(struct UTrapframe) + sizeof(int), PTE_P | PTE_U | PTE_W);
f0104669:	e8 2b 1d 00 00       	call   f0106399 <cpunum>
f010466e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0104675:	00 
f0104676:	c7 44 24 08 38 00 00 	movl   $0x38,0x8(%esp)
f010467d:	00 
f010467e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104682:	6b c0 74             	imul   $0x74,%eax,%eax
f0104685:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f010468b:	89 04 24             	mov    %eax,(%esp)
f010468e:	e8 c9 ee ff ff       	call   f010355c <user_mem_assert>

		// 在UXSTACKTOP设置一个用户模式下的页面错误堆栈帧UTrapframe，为了可以从页面错误处理程序中返回到引发错误的程序
		struct UTrapframe *utf = (struct UTrapframe *)addr;
f0104693:	89 fa                	mov    %edi,%edx
		utf->utf_fault_va = fault_va;
f0104695:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f0104697:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010469a:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f010469d:	8d 7f 08             	lea    0x8(%edi),%edi
f01046a0:	89 de                	mov    %ebx,%esi
f01046a2:	b8 20 00 00 00       	mov    $0x20,%eax
f01046a7:	f7 c7 01 00 00 00    	test   $0x1,%edi
f01046ad:	74 03                	je     f01046b2 <page_fault_handler+0xb1>
f01046af:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f01046b0:	b0 1f                	mov    $0x1f,%al
f01046b2:	f7 c7 02 00 00 00    	test   $0x2,%edi
f01046b8:	74 05                	je     f01046bf <page_fault_handler+0xbe>
f01046ba:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01046bc:	83 e8 02             	sub    $0x2,%eax
f01046bf:	89 c1                	mov    %eax,%ecx
f01046c1:	c1 e9 02             	shr    $0x2,%ecx
f01046c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01046c6:	a8 02                	test   $0x2,%al
f01046c8:	74 0b                	je     f01046d5 <page_fault_handler+0xd4>
f01046ca:	0f b7 0e             	movzwl (%esi),%ecx
f01046cd:	66 89 0f             	mov    %cx,(%edi)
f01046d0:	b9 02 00 00 00       	mov    $0x2,%ecx
f01046d5:	a8 01                	test   $0x1,%al
f01046d7:	74 07                	je     f01046e0 <page_fault_handler+0xdf>
f01046d9:	0f b6 04 0e          	movzbl (%esi,%ecx,1),%eax
f01046dd:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		utf->utf_eip = tf->tf_eip;
f01046e0:	8b 43 30             	mov    0x30(%ebx),%eax
f01046e3:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f01046e6:	8b 43 38             	mov    0x38(%ebx),%eax
f01046e9:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f01046ec:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01046ef:	89 42 30             	mov    %eax,0x30(%edx)

		tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall; // 设置页面错误处理程序入口
f01046f2:	e8 a2 1c 00 00       	call   f0106399 <cpunum>
f01046f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01046fa:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f0104700:	8b 40 64             	mov    0x64(%eax),%eax
f0104703:	89 43 30             	mov    %eax,0x30(%ebx)
		tf->tf_esp = (uintptr_t)utf;						// 修改esp移动到设置好的用户异常堆栈
f0104706:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104709:	89 43 3c             	mov    %eax,0x3c(%ebx)
		env_run(curenv);									// 重新运行本进程，env_run会pop出tf，来运行页面错误处理程序
f010470c:	e8 88 1c 00 00       	call   f0106399 <cpunum>
f0104711:	6b c0 74             	imul   $0x74,%eax,%eax
f0104714:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f010471a:	89 04 24             	mov    %eax,(%esp)
f010471d:	e8 87 f5 ff ff       	call   f0103ca9 <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104722:	8b 7b 30             	mov    0x30(%ebx),%edi
			curenv->env_id, fault_va, tf->tf_eip);
f0104725:	e8 6f 1c 00 00       	call   f0106399 <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010472a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010472e:	89 74 24 08          	mov    %esi,0x8(%esp)
			curenv->env_id, fault_va, tf->tf_eip);
f0104732:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104735:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f010473b:	8b 40 48             	mov    0x48(%eax),%eax
f010473e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104742:	c7 04 24 d8 80 10 f0 	movl   $0xf01080d8,(%esp)
f0104749:	e8 7f f7 ff ff       	call   f0103ecd <cprintf>
	print_trapframe(tf);
f010474e:	89 1c 24             	mov    %ebx,(%esp)
f0104751:	e8 0e fd ff ff       	call   f0104464 <print_trapframe>
	env_destroy(curenv);
f0104756:	e8 3e 1c 00 00       	call   f0106399 <cpunum>
f010475b:	6b c0 74             	imul   $0x74,%eax,%eax
f010475e:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f0104764:	89 04 24             	mov    %eax,(%esp)
f0104767:	e8 9c f4 ff ff       	call   f0103c08 <env_destroy>
}
f010476c:	83 c4 2c             	add    $0x2c,%esp
f010476f:	5b                   	pop    %ebx
f0104770:	5e                   	pop    %esi
f0104771:	5f                   	pop    %edi
f0104772:	5d                   	pop    %ebp
f0104773:	c3                   	ret    

f0104774 <trap>:
{
f0104774:	55                   	push   %ebp
f0104775:	89 e5                	mov    %esp,%ebp
f0104777:	57                   	push   %edi
f0104778:	56                   	push   %esi
f0104779:	83 ec 20             	sub    $0x20,%esp
f010477c:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::
f010477f:	fc                   	cld    
	if (panicstr)
f0104780:	83 3d 80 7e 1e f0 00 	cmpl   $0x0,0xf01e7e80
f0104787:	74 01                	je     f010478a <trap+0x16>
		asm volatile("hlt");
f0104789:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010478a:	e8 0a 1c 00 00       	call   f0106399 <cpunum>
f010478f:	6b d0 74             	imul   $0x74,%eax,%edx
f0104792:	81 c2 20 80 1e f0    	add    $0xf01e8020,%edx
	asm volatile("lock; xchgl %0, %1"
f0104798:	b8 01 00 00 00       	mov    $0x1,%eax
f010479d:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01047a1:	83 f8 02             	cmp    $0x2,%eax
f01047a4:	75 0c                	jne    f01047b2 <trap+0x3e>
	spin_lock(&kernel_lock);
f01047a6:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f01047ad:	e8 65 1e 00 00       	call   f0106617 <spin_lock>
	if ((tf->tf_cs & 3) == 3)
f01047b2:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01047b6:	83 e0 03             	and    $0x3,%eax
f01047b9:	66 83 f8 03          	cmp    $0x3,%ax
f01047bd:	0f 85 a7 00 00 00    	jne    f010486a <trap+0xf6>
f01047c3:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f01047ca:	e8 48 1e 00 00       	call   f0106617 <spin_lock>
		assert(curenv);
f01047cf:	e8 c5 1b 00 00       	call   f0106399 <cpunum>
f01047d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01047d7:	83 b8 28 80 1e f0 00 	cmpl   $0x0,-0xfe17fd8(%eax)
f01047de:	75 24                	jne    f0104804 <trap+0x90>
f01047e0:	c7 44 24 0c 26 7f 10 	movl   $0xf0107f26,0xc(%esp)
f01047e7:	f0 
f01047e8:	c7 44 24 08 1f 7a 10 	movl   $0xf0107a1f,0x8(%esp)
f01047ef:	f0 
f01047f0:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
f01047f7:	00 
f01047f8:	c7 04 24 1a 7f 10 f0 	movl   $0xf0107f1a,(%esp)
f01047ff:	e8 3c b8 ff ff       	call   f0100040 <_panic>
		if (curenv->env_status == ENV_DYING)
f0104804:	e8 90 1b 00 00       	call   f0106399 <cpunum>
f0104809:	6b c0 74             	imul   $0x74,%eax,%eax
f010480c:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f0104812:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104816:	75 2d                	jne    f0104845 <trap+0xd1>
			env_free(curenv);
f0104818:	e8 7c 1b 00 00       	call   f0106399 <cpunum>
f010481d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104820:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f0104826:	89 04 24             	mov    %eax,(%esp)
f0104829:	e8 0f f2 ff ff       	call   f0103a3d <env_free>
			curenv = NULL;
f010482e:	e8 66 1b 00 00       	call   f0106399 <cpunum>
f0104833:	6b c0 74             	imul   $0x74,%eax,%eax
f0104836:	c7 80 28 80 1e f0 00 	movl   $0x0,-0xfe17fd8(%eax)
f010483d:	00 00 00 
			sched_yield();
f0104840:	e8 aa 02 00 00       	call   f0104aef <sched_yield>
		curenv->env_tf = *tf;
f0104845:	e8 4f 1b 00 00       	call   f0106399 <cpunum>
f010484a:	6b c0 74             	imul   $0x74,%eax,%eax
f010484d:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f0104853:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104858:	89 c7                	mov    %eax,%edi
f010485a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f010485c:	e8 38 1b 00 00       	call   f0106399 <cpunum>
f0104861:	6b c0 74             	imul   $0x74,%eax,%eax
f0104864:	8b b0 28 80 1e f0    	mov    -0xfe17fd8(%eax),%esi
	last_tf = tf;
f010486a:	89 35 60 7a 1e f0    	mov    %esi,0xf01e7a60
	switch (tf->tf_trapno)
f0104870:	8b 46 28             	mov    0x28(%esi),%eax
f0104873:	83 f8 0e             	cmp    $0xe,%eax
f0104876:	74 0c                	je     f0104884 <trap+0x110>
f0104878:	83 f8 30             	cmp    $0x30,%eax
f010487b:	74 28                	je     f01048a5 <trap+0x131>
f010487d:	83 f8 03             	cmp    $0x3,%eax
f0104880:	75 55                	jne    f01048d7 <trap+0x163>
f0104882:	eb 11                	jmp    f0104895 <trap+0x121>
		page_fault_handler(tf);
f0104884:	89 34 24             	mov    %esi,(%esp)
f0104887:	e8 75 fd ff ff       	call   f0104601 <page_fault_handler>
f010488c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104890:	e9 b1 00 00 00       	jmp    f0104946 <trap+0x1d2>
		monitor(tf);
f0104895:	89 34 24             	mov    %esi,(%esp)
f0104898:	e8 34 c1 ff ff       	call   f01009d1 <monitor>
f010489d:	8d 76 00             	lea    0x0(%esi),%esi
f01048a0:	e9 a1 00 00 00       	jmp    f0104946 <trap+0x1d2>
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx,
f01048a5:	8b 46 04             	mov    0x4(%esi),%eax
f01048a8:	89 44 24 14          	mov    %eax,0x14(%esp)
f01048ac:	8b 06                	mov    (%esi),%eax
f01048ae:	89 44 24 10          	mov    %eax,0x10(%esp)
f01048b2:	8b 46 10             	mov    0x10(%esi),%eax
f01048b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01048b9:	8b 46 18             	mov    0x18(%esi),%eax
f01048bc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01048c0:	8b 46 14             	mov    0x14(%esi),%eax
f01048c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048c7:	8b 46 1c             	mov    0x1c(%esi),%eax
f01048ca:	89 04 24             	mov    %eax,(%esp)
f01048cd:	e8 ce 02 00 00       	call   f0104ba0 <syscall>
f01048d2:	89 46 1c             	mov    %eax,0x1c(%esi)
f01048d5:	eb 6f                	jmp    f0104946 <trap+0x1d2>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS)
f01048d7:	83 f8 27             	cmp    $0x27,%eax
f01048da:	75 16                	jne    f01048f2 <trap+0x17e>
		cprintf("Spurious interrupt on irq 7\n");
f01048dc:	c7 04 24 2d 7f 10 f0 	movl   $0xf0107f2d,(%esp)
f01048e3:	e8 e5 f5 ff ff       	call   f0103ecd <cprintf>
		print_trapframe(tf);
f01048e8:	89 34 24             	mov    %esi,(%esp)
f01048eb:	e8 74 fb ff ff       	call   f0104464 <print_trapframe>
f01048f0:	eb 54                	jmp    f0104946 <trap+0x1d2>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER)
f01048f2:	83 f8 20             	cmp    $0x20,%eax
f01048f5:	75 0e                	jne    f0104905 <trap+0x191>
		lapic_eoi();
f01048f7:	e8 ea 1b 00 00       	call   f01064e6 <lapic_eoi>
		sched_yield();
f01048fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104900:	e8 ea 01 00 00       	call   f0104aef <sched_yield>
	print_trapframe(tf);
f0104905:	89 34 24             	mov    %esi,(%esp)
f0104908:	e8 57 fb ff ff       	call   f0104464 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010490d:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104912:	75 1c                	jne    f0104930 <trap+0x1bc>
		panic("unhandled trap in kernel");
f0104914:	c7 44 24 08 4a 7f 10 	movl   $0xf0107f4a,0x8(%esp)
f010491b:	f0 
f010491c:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
f0104923:	00 
f0104924:	c7 04 24 1a 7f 10 f0 	movl   $0xf0107f1a,(%esp)
f010492b:	e8 10 b7 ff ff       	call   f0100040 <_panic>
		env_destroy(curenv);
f0104930:	e8 64 1a 00 00       	call   f0106399 <cpunum>
f0104935:	6b c0 74             	imul   $0x74,%eax,%eax
f0104938:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f010493e:	89 04 24             	mov    %eax,(%esp)
f0104941:	e8 c2 f2 ff ff       	call   f0103c08 <env_destroy>
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104946:	e8 4e 1a 00 00       	call   f0106399 <cpunum>
f010494b:	6b c0 74             	imul   $0x74,%eax,%eax
f010494e:	83 b8 28 80 1e f0 00 	cmpl   $0x0,-0xfe17fd8(%eax)
f0104955:	74 2a                	je     f0104981 <trap+0x20d>
f0104957:	e8 3d 1a 00 00       	call   f0106399 <cpunum>
f010495c:	6b c0 74             	imul   $0x74,%eax,%eax
f010495f:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f0104965:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104969:	75 16                	jne    f0104981 <trap+0x20d>
		env_run(curenv); // 返回用户态
f010496b:	e8 29 1a 00 00       	call   f0106399 <cpunum>
f0104970:	6b c0 74             	imul   $0x74,%eax,%eax
f0104973:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f0104979:	89 04 24             	mov    %eax,(%esp)
f010497c:	e8 28 f3 ff ff       	call   f0103ca9 <env_run>
		sched_yield();
f0104981:	e8 69 01 00 00       	call   f0104aef <sched_yield>

f0104986 <DIVIDE_Handler>:
 * TRAPHANDLER(name, num):是一个宏，等效于一个从name标记的地址开始的几行指令
 * name是你为这个num的中断设置的中断处理程序的函数名，num由inc\trap.h定义
 * 经过下面的设置，这个汇编文件里存在很多个以handler为名的函数，可以在C中使用void XXX_Hander()去声明函数，
 * 这时，这个hander函数的地址将被链接到下面对应hander的行。
 */
TRAPHANDLER_NOEC(DIVIDE_Handler, T_DIVIDE)
f0104986:	6a 00                	push   $0x0
f0104988:	6a 00                	push   $0x0
f010498a:	eb 7c                	jmp    f0104a08 <_alltraps>

f010498c <DEBUG_Handler>:
TRAPHANDLER_NOEC(DEBUG_Handler, T_DEBUG)
f010498c:	6a 00                	push   $0x0
f010498e:	6a 01                	push   $0x1
f0104990:	eb 76                	jmp    f0104a08 <_alltraps>

f0104992 <NMI_Handler>:
TRAPHANDLER_NOEC(NMI_Handler, T_NMI)
f0104992:	6a 00                	push   $0x0
f0104994:	6a 02                	push   $0x2
f0104996:	eb 70                	jmp    f0104a08 <_alltraps>

f0104998 <BRKPT_Handler>:
TRAPHANDLER_NOEC(BRKPT_Handler, T_BRKPT)
f0104998:	6a 00                	push   $0x0
f010499a:	6a 03                	push   $0x3
f010499c:	eb 6a                	jmp    f0104a08 <_alltraps>

f010499e <OFLOW_Handler>:
TRAPHANDLER_NOEC(OFLOW_Handler, T_OFLOW)
f010499e:	6a 00                	push   $0x0
f01049a0:	6a 04                	push   $0x4
f01049a2:	eb 64                	jmp    f0104a08 <_alltraps>

f01049a4 <BOUND_Handler>:
TRAPHANDLER_NOEC(BOUND_Handler, T_BOUND)
f01049a4:	6a 00                	push   $0x0
f01049a6:	6a 05                	push   $0x5
f01049a8:	eb 5e                	jmp    f0104a08 <_alltraps>

f01049aa <ILLOP_Handler>:
TRAPHANDLER_NOEC(ILLOP_Handler, T_ILLOP)
f01049aa:	6a 00                	push   $0x0
f01049ac:	6a 06                	push   $0x6
f01049ae:	eb 58                	jmp    f0104a08 <_alltraps>

f01049b0 <DEVICE_Handler>:
TRAPHANDLER_NOEC(DEVICE_Handler, T_DEVICE)
f01049b0:	6a 00                	push   $0x0
f01049b2:	6a 07                	push   $0x7
f01049b4:	eb 52                	jmp    f0104a08 <_alltraps>

f01049b6 <DBLFLT_Handler>:
TRAPHANDLER(DBLFLT_Handler, T_DBLFLT)
f01049b6:	6a 08                	push   $0x8
f01049b8:	eb 4e                	jmp    f0104a08 <_alltraps>

f01049ba <TSS_Handler>:

TRAPHANDLER(TSS_Handler, T_TSS)
f01049ba:	6a 0a                	push   $0xa
f01049bc:	eb 4a                	jmp    f0104a08 <_alltraps>

f01049be <SEGNP_Handler>:
TRAPHANDLER(SEGNP_Handler, T_SEGNP)
f01049be:	6a 0b                	push   $0xb
f01049c0:	eb 46                	jmp    f0104a08 <_alltraps>

f01049c2 <STACK_Handler>:
TRAPHANDLER(STACK_Handler, T_STACK)
f01049c2:	6a 0c                	push   $0xc
f01049c4:	eb 42                	jmp    f0104a08 <_alltraps>

f01049c6 <GPFLT_Handler>:
TRAPHANDLER(GPFLT_Handler, T_GPFLT)
f01049c6:	6a 0d                	push   $0xd
f01049c8:	eb 3e                	jmp    f0104a08 <_alltraps>

f01049ca <PGFLT_Handler>:
TRAPHANDLER(PGFLT_Handler, T_PGFLT)
f01049ca:	6a 0e                	push   $0xe
f01049cc:	eb 3a                	jmp    f0104a08 <_alltraps>

f01049ce <FPERR_Handler>:

TRAPHANDLER(FPERR_Handler, T_FPERR)
f01049ce:	6a 10                	push   $0x10
f01049d0:	eb 36                	jmp    f0104a08 <_alltraps>

f01049d2 <ALIGN_Handler>:
TRAPHANDLER(ALIGN_Handler, T_ALIGN)
f01049d2:	6a 11                	push   $0x11
f01049d4:	eb 32                	jmp    f0104a08 <_alltraps>

f01049d6 <MCHK_Handler>:
TRAPHANDLER(MCHK_Handler, T_MCHK)
f01049d6:	6a 12                	push   $0x12
f01049d8:	eb 2e                	jmp    f0104a08 <_alltraps>

f01049da <SIMDERR_Handler>:
TRAPHANDLER(SIMDERR_Handler, T_SIMDERR)
f01049da:	6a 13                	push   $0x13
f01049dc:	eb 2a                	jmp    f0104a08 <_alltraps>

f01049de <SYSCALL_Handler>:

TRAPHANDLER_NOEC(SYSCALL_Handler, T_SYSCALL)
f01049de:	6a 00                	push   $0x0
f01049e0:	6a 30                	push   $0x30
f01049e2:	eb 24                	jmp    f0104a08 <_alltraps>

f01049e4 <IRQ_TIMER_Handler>:

# IRQs
TRAPHANDLER_NOEC(IRQ_TIMER_Handler, IRQ_OFFSET+IRQ_TIMER)
f01049e4:	6a 00                	push   $0x0
f01049e6:	6a 20                	push   $0x20
f01049e8:	eb 1e                	jmp    f0104a08 <_alltraps>

f01049ea <IRQ_KBD_Handler>:
TRAPHANDLER_NOEC(IRQ_KBD_Handler, IRQ_OFFSET+IRQ_KBD)
f01049ea:	6a 00                	push   $0x0
f01049ec:	6a 21                	push   $0x21
f01049ee:	eb 18                	jmp    f0104a08 <_alltraps>

f01049f0 <IRQ_SERIAL_Handler>:
TRAPHANDLER_NOEC(IRQ_SERIAL_Handler, IRQ_OFFSET+IRQ_SERIAL)
f01049f0:	6a 00                	push   $0x0
f01049f2:	6a 24                	push   $0x24
f01049f4:	eb 12                	jmp    f0104a08 <_alltraps>

f01049f6 <IRQ_SPURIOUS_Handler>:
TRAPHANDLER_NOEC(IRQ_SPURIOUS_Handler, IRQ_OFFSET+IRQ_SPURIOUS)
f01049f6:	6a 00                	push   $0x0
f01049f8:	6a 27                	push   $0x27
f01049fa:	eb 0c                	jmp    f0104a08 <_alltraps>

f01049fc <IRQ_IDE_Handler>:
TRAPHANDLER_NOEC(IRQ_IDE_Handler, IRQ_OFFSET+IRQ_IDE)
f01049fc:	6a 00                	push   $0x0
f01049fe:	6a 2e                	push   $0x2e
f0104a00:	eb 06                	jmp    f0104a08 <_alltraps>

f0104a02 <IRQ_ERROR_Handler>:
TRAPHANDLER_NOEC(IRQ_ERROR_Handler, IRQ_OFFSET+IRQ_ERROR)
f0104a02:	6a 00                	push   $0x0
f0104a04:	6a 33                	push   $0x33
f0104a06:	eb 00                	jmp    f0104a08 <_alltraps>

f0104a08 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
.globl		_start
_alltraps:
	pushl	%ds		/* 后面要将GD_KD加载到%ds和%es，先保存旧的 */
f0104a08:	1e                   	push   %ds
	pushl	%es
f0104a09:	06                   	push   %es
	pushal			/* 直接推送整个TrapFrame */
f0104a0a:	60                   	pusha  
	movw 	$GD_KD, %ax /* 不能直接设置，因此先复制到%ax */
f0104a0b:	66 b8 10 00          	mov    $0x10,%ax
  	movw 	%ax, %ds
f0104a0f:	8e d8                	mov    %eax,%ds
  	movw 	%ax, %es
f0104a11:	8e c0                	mov    %eax,%es
	pushl 	%esp	/* %esp指向Trapframe顶部，作为参数传递给trap */
f0104a13:	54                   	push   %esp
	call	trap	/* 调用c程序trap，执行中断处理程序 */
f0104a14:	e8 5b fd ff ff       	call   f0104774 <trap>

f0104a19 <sched_halt>:

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void sched_halt(void)
{
f0104a19:	55                   	push   %ebp
f0104a1a:	89 e5                	mov    %esp,%ebp
f0104a1c:	83 ec 18             	sub    $0x18,%esp
f0104a1f:	8b 15 48 72 1e f0    	mov    0xf01e7248,%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++)
f0104a25:	b8 00 00 00 00       	mov    $0x0,%eax
	{
		if ((envs[i].env_status == ENV_RUNNABLE ||
			 envs[i].env_status == ENV_RUNNING ||
f0104a2a:	8b 4a 54             	mov    0x54(%edx),%ecx
f0104a2d:	83 e9 01             	sub    $0x1,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104a30:	83 f9 02             	cmp    $0x2,%ecx
f0104a33:	76 0f                	jbe    f0104a44 <sched_halt+0x2b>
	for (i = 0; i < NENV; i++)
f0104a35:	83 c0 01             	add    $0x1,%eax
f0104a38:	83 c2 7c             	add    $0x7c,%edx
f0104a3b:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104a40:	75 e8                	jne    f0104a2a <sched_halt+0x11>
f0104a42:	eb 07                	jmp    f0104a4b <sched_halt+0x32>
			 envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV)
f0104a44:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104a49:	75 1a                	jne    f0104a65 <sched_halt+0x4c>
	{
		cprintf("No runnable environments in the system!\n");
f0104a4b:	c7 04 24 50 81 10 f0 	movl   $0xf0108150,(%esp)
f0104a52:	e8 76 f4 ff ff       	call   f0103ecd <cprintf>
		while (1)
			monitor(NULL);
f0104a57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104a5e:	e8 6e bf ff ff       	call   f01009d1 <monitor>
f0104a63:	eb f2                	jmp    f0104a57 <sched_halt+0x3e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104a65:	e8 2f 19 00 00       	call   f0106399 <cpunum>
f0104a6a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a6d:	c7 80 28 80 1e f0 00 	movl   $0x0,-0xfe17fd8(%eax)
f0104a74:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104a77:	a1 8c 7e 1e f0       	mov    0xf01e7e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0104a7c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104a81:	77 20                	ja     f0104aa3 <sched_halt+0x8a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104a83:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104a87:	c7 44 24 08 c8 6a 10 	movl   $0xf0106ac8,0x8(%esp)
f0104a8e:	f0 
f0104a8f:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0104a96:	00 
f0104a97:	c7 04 24 79 81 10 f0 	movl   $0xf0108179,(%esp)
f0104a9e:	e8 9d b5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104aa3:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104aa8:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104aab:	e8 e9 18 00 00       	call   f0106399 <cpunum>
f0104ab0:	6b d0 74             	imul   $0x74,%eax,%edx
f0104ab3:	81 c2 20 80 1e f0    	add    $0xf01e8020,%edx
	asm volatile("lock; xchgl %0, %1"
f0104ab9:	b8 02 00 00 00       	mov    $0x2,%eax
f0104abe:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
	spin_unlock(&kernel_lock);
f0104ac2:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104ac9:	e8 f5 1b 00 00       	call   f01066c3 <spin_unlock>
	asm volatile("pause");
f0104ace:	f3 90                	pause  
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
		:
		: "a"(thiscpu->cpu_ts.ts_esp0));
f0104ad0:	e8 c4 18 00 00       	call   f0106399 <cpunum>
f0104ad5:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile(
f0104ad8:	8b 80 30 80 1e f0    	mov    -0xfe17fd0(%eax),%eax
f0104ade:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104ae3:	89 c4                	mov    %eax,%esp
f0104ae5:	6a 00                	push   $0x0
f0104ae7:	6a 00                	push   $0x0
f0104ae9:	fb                   	sti    
f0104aea:	f4                   	hlt    
f0104aeb:	eb fd                	jmp    f0104aea <sched_halt+0xd1>
}
f0104aed:	c9                   	leave  
f0104aee:	c3                   	ret    

f0104aef <sched_yield>:
{
f0104aef:	55                   	push   %ebp
f0104af0:	89 e5                	mov    %esp,%ebp
f0104af2:	56                   	push   %esi
f0104af3:	53                   	push   %ebx
f0104af4:	83 ec 10             	sub    $0x10,%esp
	idle = &envs[0]; // 第一个环境
f0104af7:	8b 1d 48 72 1e f0    	mov    0xf01e7248,%ebx
	if (curenv)
f0104afd:	e8 97 18 00 00       	call   f0106399 <cpunum>
f0104b02:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b05:	83 b8 28 80 1e f0 00 	cmpl   $0x0,-0xfe17fd8(%eax)
f0104b0c:	74 11                	je     f0104b1f <sched_yield+0x30>
		idle = curenv + 1; // 如果现在有在运行的环境，从现在这个的下一个开始遍历
f0104b0e:	e8 86 18 00 00       	call   f0106399 <cpunum>
f0104b13:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b16:	8b 98 28 80 1e f0    	mov    -0xfe17fd8(%eax),%ebx
f0104b1c:	83 c3 7c             	add    $0x7c,%ebx
		if (idle == &envs[NENV - 1]) // 最后一个环境
f0104b1f:	8b 0d 48 72 1e f0    	mov    0xf01e7248,%ecx
f0104b25:	8d b1 84 ef 01 00    	lea    0x1ef84(%ecx),%esi
f0104b2b:	b8 ff 03 00 00       	mov    $0x3ff,%eax
		if (idle->env_status == ENV_RUNNABLE) // 检查是否可以运行
f0104b30:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0104b34:	75 08                	jne    f0104b3e <sched_yield+0x4f>
			env_run(idle);
f0104b36:	89 1c 24             	mov    %ebx,(%esp)
f0104b39:	e8 6b f1 ff ff       	call   f0103ca9 <env_run>
			idle++;
f0104b3e:	8d 53 7c             	lea    0x7c(%ebx),%edx
f0104b41:	39 de                	cmp    %ebx,%esi
f0104b43:	0f 44 d1             	cmove  %ecx,%edx
f0104b46:	89 d3                	mov    %edx,%ebx
	for (int i = 0; i < NENV - 1; i++)
f0104b48:	83 e8 01             	sub    $0x1,%eax
f0104b4b:	75 e3                	jne    f0104b30 <sched_yield+0x41>
	if (idle == curenv && curenv->env_status == ENV_RUNNING) // 转一圈又回到自己
f0104b4d:	e8 47 18 00 00       	call   f0106399 <cpunum>
f0104b52:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b55:	3b 98 28 80 1e f0    	cmp    -0xfe17fd8(%eax),%ebx
f0104b5b:	75 2a                	jne    f0104b87 <sched_yield+0x98>
f0104b5d:	e8 37 18 00 00       	call   f0106399 <cpunum>
f0104b62:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b65:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f0104b6b:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104b6f:	75 16                	jne    f0104b87 <sched_yield+0x98>
		env_run(curenv);
f0104b71:	e8 23 18 00 00       	call   f0106399 <cpunum>
f0104b76:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b79:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f0104b7f:	89 04 24             	mov    %eax,(%esp)
f0104b82:	e8 22 f1 ff ff       	call   f0103ca9 <env_run>
	sched_halt();
f0104b87:	e8 8d fe ff ff       	call   f0104a19 <sched_halt>
}
f0104b8c:	83 c4 10             	add    $0x10,%esp
f0104b8f:	5b                   	pop    %ebx
f0104b90:	5e                   	pop    %esi
f0104b91:	5d                   	pop    %ebp
f0104b92:	c3                   	ret    
f0104b93:	66 90                	xchg   %ax,%ax
f0104b95:	66 90                	xchg   %ax,%ax
f0104b97:	66 90                	xchg   %ax,%ax
f0104b99:	66 90                	xchg   %ax,%ax
f0104b9b:	66 90                	xchg   %ax,%ax
f0104b9d:	66 90                	xchg   %ax,%ax
f0104b9f:	90                   	nop

f0104ba0 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104ba0:	55                   	push   %ebp
f0104ba1:	89 e5                	mov    %esp,%ebp
f0104ba3:	57                   	push   %edi
f0104ba4:	56                   	push   %esi
f0104ba5:	53                   	push   %ebx
f0104ba6:	83 ec 2c             	sub    $0x2c,%esp
f0104ba9:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) // 根据系统调用编号，调用相应的处理函数，枚举值即为inc\syscall.h中定义的值
f0104bac:	83 f8 0d             	cmp    $0xd,%eax
f0104baf:	0f 87 21 05 00 00    	ja     f01050d6 <syscall+0x536>
f0104bb5:	ff 24 85 8c 81 10 f0 	jmp    *-0xfef7e74(,%eax,4)
	user_mem_assert(curenv, s, len, PTE_U);
f0104bbc:	e8 d8 17 00 00       	call   f0106399 <cpunum>
f0104bc1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104bc8:	00 
f0104bc9:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104bcc:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104bd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104bd3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104bd7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bda:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f0104be0:	89 04 24             	mov    %eax,(%esp)
f0104be3:	e8 74 e9 ff ff       	call   f010355c <user_mem_assert>
	cprintf("%.*s", len, s);
f0104be8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104beb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104bef:	8b 45 10             	mov    0x10(%ebp),%eax
f0104bf2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104bf6:	c7 04 24 86 81 10 f0 	movl   $0xf0108186,(%esp)
f0104bfd:	e8 cb f2 ff ff       	call   f0103ecd <cprintf>
	{
	case SYS_cputs:
		sys_cputs((char *)a1, (size_t)a2);
		return 0;
f0104c02:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c07:	e9 d6 04 00 00       	jmp    f01050e2 <syscall+0x542>
	return cons_getc();
f0104c0c:	e8 34 ba ff ff       	call   f0100645 <cons_getc>
	case SYS_cgetc:
		return sys_cgetc();
f0104c11:	e9 cc 04 00 00       	jmp    f01050e2 <syscall+0x542>
	return curenv->env_id;
f0104c16:	e8 7e 17 00 00       	call   f0106399 <cpunum>
f0104c1b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c1e:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f0104c24:	8b 40 48             	mov    0x48(%eax),%eax
	case SYS_getenvid:
		return sys_getenvid();
f0104c27:	e9 b6 04 00 00       	jmp    f01050e2 <syscall+0x542>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104c2c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104c33:	00 
f0104c34:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104c37:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c3b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c3e:	89 04 24             	mov    %eax,(%esp)
f0104c41:	e8 09 ea ff ff       	call   f010364f <envid2env>
		return r;
f0104c46:	89 c2                	mov    %eax,%edx
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104c48:	85 c0                	test   %eax,%eax
f0104c4a:	78 10                	js     f0104c5c <syscall+0xbc>
	env_destroy(e);
f0104c4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c4f:	89 04 24             	mov    %eax,(%esp)
f0104c52:	e8 b1 ef ff ff       	call   f0103c08 <env_destroy>
	return 0;
f0104c57:	ba 00 00 00 00       	mov    $0x0,%edx
	case SYS_env_destroy:
		return sys_env_destroy((envid_t)a1);
f0104c5c:	89 d0                	mov    %edx,%eax
f0104c5e:	e9 7f 04 00 00       	jmp    f01050e2 <syscall+0x542>
	sched_yield();
f0104c63:	e8 87 fe ff ff       	call   f0104aef <sched_yield>
	int Ecode = env_alloc(&new_env, curenv->env_id);
f0104c68:	e8 2c 17 00 00       	call   f0106399 <cpunum>
f0104c6d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c70:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f0104c76:	8b 40 48             	mov    0x48(%eax),%eax
f0104c79:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c7d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104c80:	89 04 24             	mov    %eax,(%esp)
f0104c83:	e8 d7 ea ff ff       	call   f010375f <env_alloc>
		return Ecode;
f0104c88:	89 c2                	mov    %eax,%edx
	if (Ecode) // 如果发生错误就返回error code
f0104c8a:	85 c0                	test   %eax,%eax
f0104c8c:	75 2e                	jne    f0104cbc <syscall+0x11c>
	new_env->env_status = ENV_NOT_RUNNABLE;
f0104c8e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104c91:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	new_env->env_tf = curenv->env_tf; // 拷贝父进程的trapframe
f0104c98:	e8 fc 16 00 00       	call   f0106399 <cpunum>
f0104c9d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ca0:	8b b0 28 80 1e f0    	mov    -0xfe17fd8(%eax),%esi
f0104ca6:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104cab:	89 df                	mov    %ebx,%edi
f0104cad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	new_env->env_tf.tf_regs.reg_eax = 0;
f0104caf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104cb2:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return new_env->env_id; // 返回子进程的id
f0104cb9:	8b 50 48             	mov    0x48(%eax),%edx
	case SYS_yield:
		sys_yield();
		return 0;
	case SYS_exofork:
		return sys_exofork();
f0104cbc:	89 d0                	mov    %edx,%eax
f0104cbe:	e9 1f 04 00 00       	jmp    f01050e2 <syscall+0x542>
	int Ecode = envid2env(envid, &e, 1);
f0104cc3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104cca:	00 
f0104ccb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104cce:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104cd2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104cd5:	89 04 24             	mov    %eax,(%esp)
f0104cd8:	e8 72 e9 ff ff       	call   f010364f <envid2env>
		return Ecode;
f0104cdd:	89 c2                	mov    %eax,%edx
	if (Ecode)
f0104cdf:	85 c0                	test   %eax,%eax
f0104ce1:	75 21                	jne    f0104d04 <syscall+0x164>
	if ((status != ENV_RUNNABLE) && (status != ENV_NOT_RUNNABLE)) // 检查status是合法的
f0104ce3:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f0104ce7:	74 06                	je     f0104cef <syscall+0x14f>
f0104ce9:	83 7d 10 02          	cmpl   $0x2,0x10(%ebp)
f0104ced:	75 10                	jne    f0104cff <syscall+0x15f>
	e->env_status = status; // 设置状态
f0104cef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104cf2:	8b 75 10             	mov    0x10(%ebp),%esi
f0104cf5:	89 70 54             	mov    %esi,0x54(%eax)
	return 0;
f0104cf8:	ba 00 00 00 00       	mov    $0x0,%edx
f0104cfd:	eb 05                	jmp    f0104d04 <syscall+0x164>
		return -E_INVAL;
f0104cff:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
	case SYS_env_set_status:
		return sys_env_set_status((envid_t)a1, (int)a2);
f0104d04:	89 d0                	mov    %edx,%eax
f0104d06:	e9 d7 03 00 00       	jmp    f01050e2 <syscall+0x542>
	if ((Ecode = envid2env(envid, &e, 1))) // 得到Env结构
f0104d0b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104d12:	00 
f0104d13:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d16:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d1a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d1d:	89 04 24             	mov    %eax,(%esp)
f0104d20:	e8 2a e9 ff ff       	call   f010364f <envid2env>
		return Ecode;
f0104d25:	89 c2                	mov    %eax,%edx
	if ((Ecode = envid2env(envid, &e, 1))) // 得到Env结构
f0104d27:	85 c0                	test   %eax,%eax
f0104d29:	75 7f                	jne    f0104daa <syscall+0x20a>
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || perm & ~PTE_SYSCALL) // 检查perm
f0104d2b:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d2e:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0104d33:	83 f8 05             	cmp    $0x5,%eax
f0104d36:	75 58                	jne    f0104d90 <syscall+0x1f0>
	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE != 0) // 检查va
f0104d38:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104d3f:	77 56                	ja     f0104d97 <syscall+0x1f7>
f0104d41:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104d48:	75 54                	jne    f0104d9e <syscall+0x1fe>
	struct PageInfo *p = page_alloc(ALLOC_ZERO);
f0104d4a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104d51:	e8 ba c3 ff ff       	call   f0101110 <page_alloc>
f0104d56:	89 c3                	mov    %eax,%ebx
	if (!p) // 没有内存，分配页面失败
f0104d58:	85 c0                	test   %eax,%eax
f0104d5a:	74 49                	je     f0104da5 <syscall+0x205>
	Ecode = page_insert(e->env_pgdir, p, va, perm);
f0104d5c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104d63:	8b 45 10             	mov    0x10(%ebp),%eax
f0104d66:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104d6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104d6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d71:	8b 40 60             	mov    0x60(%eax),%eax
f0104d74:	89 04 24             	mov    %eax,(%esp)
f0104d77:	e8 c6 c6 ff ff       	call   f0101442 <page_insert>
f0104d7c:	89 c6                	mov    %eax,%esi
	return 0;
f0104d7e:	89 c2                	mov    %eax,%edx
	if (Ecode)
f0104d80:	85 c0                	test   %eax,%eax
f0104d82:	74 26                	je     f0104daa <syscall+0x20a>
		page_decref(p); // 释放p
f0104d84:	89 1c 24             	mov    %ebx,(%esp)
f0104d87:	e8 55 c4 ff ff       	call   f01011e1 <page_decref>
		return Ecode;
f0104d8c:	89 f2                	mov    %esi,%edx
f0104d8e:	eb 1a                	jmp    f0104daa <syscall+0x20a>
		return -E_INVAL;
f0104d90:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104d95:	eb 13                	jmp    f0104daa <syscall+0x20a>
		return -E_INVAL;
f0104d97:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104d9c:	eb 0c                	jmp    f0104daa <syscall+0x20a>
f0104d9e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104da3:	eb 05                	jmp    f0104daa <syscall+0x20a>
		return -E_NO_MEM;
f0104da5:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
	case SYS_page_alloc:
		return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
f0104daa:	89 d0                	mov    %edx,%eax
f0104dac:	e9 31 03 00 00       	jmp    f01050e2 <syscall+0x542>
	if ((Ecode = envid2env(srcenvid, &src, 1))) // 得到Env结构
f0104db1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104db8:	00 
f0104db9:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104dbc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104dc0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104dc3:	89 04 24             	mov    %eax,(%esp)
f0104dc6:	e8 84 e8 ff ff       	call   f010364f <envid2env>
		return Ecode;
f0104dcb:	89 c2                	mov    %eax,%edx
	if ((Ecode = envid2env(srcenvid, &src, 1))) // 得到Env结构
f0104dcd:	85 c0                	test   %eax,%eax
f0104dcf:	0f 85 c1 00 00 00    	jne    f0104e96 <syscall+0x2f6>
	if ((Ecode = envid2env(dstenvid, &dst, 1)))
f0104dd5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104ddc:	00 
f0104ddd:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104de0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104de4:	8b 45 14             	mov    0x14(%ebp),%eax
f0104de7:	89 04 24             	mov    %eax,(%esp)
f0104dea:	e8 60 e8 ff ff       	call   f010364f <envid2env>
		return Ecode;
f0104def:	89 c2                	mov    %eax,%edx
	if ((Ecode = envid2env(dstenvid, &dst, 1)))
f0104df1:	85 c0                	test   %eax,%eax
f0104df3:	0f 85 9d 00 00 00    	jne    f0104e96 <syscall+0x2f6>
	if (((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)) || (perm & ~PTE_SYSCALL)) // 检查perm
f0104df9:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104dfc:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0104e01:	83 f8 05             	cmp    $0x5,%eax
f0104e04:	75 68                	jne    f0104e6e <syscall+0x2ce>
	if ((uintptr_t)srcva >= UTOP || (uintptr_t)srcva % PGSIZE != 0 // 检查va
f0104e06:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104e0d:	77 66                	ja     f0104e75 <syscall+0x2d5>
f0104e0f:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104e16:	75 64                	jne    f0104e7c <syscall+0x2dc>
		|| (uintptr_t)dstva >= UTOP || (uintptr_t)dstva % PGSIZE != 0)
f0104e18:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104e1f:	77 62                	ja     f0104e83 <syscall+0x2e3>
f0104e21:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104e28:	75 60                	jne    f0104e8a <syscall+0x2ea>
	struct PageInfo *p = page_lookup(src->env_pgdir, srcva, &pte); // 找到src对应的页面
f0104e2a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e2d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104e31:	8b 45 10             	mov    0x10(%ebp),%eax
f0104e34:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e38:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e3b:	8b 40 60             	mov    0x60(%eax),%eax
f0104e3e:	89 04 24             	mov    %eax,(%esp)
f0104e41:	e8 ad c4 ff ff       	call   f01012f3 <page_lookup>
	if (!p)														   // 没有权限
f0104e46:	85 c0                	test   %eax,%eax
f0104e48:	74 47                	je     f0104e91 <syscall+0x2f1>
	Ecode = page_insert(dst->env_pgdir, p, dstva, perm); // 把src对应的页面也映射到dst上，这样两者都映射到同一个页面
f0104e4a:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f0104e4d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104e51:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104e54:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104e58:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e5f:	8b 40 60             	mov    0x60(%eax),%eax
f0104e62:	89 04 24             	mov    %eax,(%esp)
f0104e65:	e8 d8 c5 ff ff       	call   f0101442 <page_insert>
f0104e6a:	89 c2                	mov    %eax,%edx
f0104e6c:	eb 28                	jmp    f0104e96 <syscall+0x2f6>
		return -E_INVAL;
f0104e6e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104e73:	eb 21                	jmp    f0104e96 <syscall+0x2f6>
		return -E_INVAL;
f0104e75:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104e7a:	eb 1a                	jmp    f0104e96 <syscall+0x2f6>
f0104e7c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104e81:	eb 13                	jmp    f0104e96 <syscall+0x2f6>
f0104e83:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104e88:	eb 0c                	jmp    f0104e96 <syscall+0x2f6>
f0104e8a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104e8f:	eb 05                	jmp    f0104e96 <syscall+0x2f6>
		return -E_INVAL;
f0104e91:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
	case SYS_page_map:
		return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
f0104e96:	89 d0                	mov    %edx,%eax
f0104e98:	e9 45 02 00 00       	jmp    f01050e2 <syscall+0x542>
	if ((Ecode = envid2env(envid, &e, 1))) // 得到Env结构
f0104e9d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104ea4:	00 
f0104ea5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ea8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104eac:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104eaf:	89 04 24             	mov    %eax,(%esp)
f0104eb2:	e8 98 e7 ff ff       	call   f010364f <envid2env>
		return Ecode;
f0104eb7:	89 c2                	mov    %eax,%edx
	if ((Ecode = envid2env(envid, &e, 1))) // 得到Env结构
f0104eb9:	85 c0                	test   %eax,%eax
f0104ebb:	75 3a                	jne    f0104ef7 <syscall+0x357>
	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE != 0)
f0104ebd:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104ec4:	77 25                	ja     f0104eeb <syscall+0x34b>
f0104ec6:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104ecd:	75 23                	jne    f0104ef2 <syscall+0x352>
	page_remove(e->env_pgdir, va);
f0104ecf:	8b 45 10             	mov    0x10(%ebp),%eax
f0104ed2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ed6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ed9:	8b 40 60             	mov    0x60(%eax),%eax
f0104edc:	89 04 24             	mov    %eax,(%esp)
f0104edf:	e8 15 c5 ff ff       	call   f01013f9 <page_remove>
	return 0;
f0104ee4:	ba 00 00 00 00       	mov    $0x0,%edx
f0104ee9:	eb 0c                	jmp    f0104ef7 <syscall+0x357>
		return -E_INVAL;
f0104eeb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104ef0:	eb 05                	jmp    f0104ef7 <syscall+0x357>
f0104ef2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
	case SYS_page_unmap:
		return sys_page_unmap((envid_t)a1, (void *)a2);
f0104ef7:	89 d0                	mov    %edx,%eax
f0104ef9:	e9 e4 01 00 00       	jmp    f01050e2 <syscall+0x542>
	int Ecode = envid2env(envid, &e, 1);
f0104efe:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f05:	00 
f0104f06:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f09:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f0d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f10:	89 04 24             	mov    %eax,(%esp)
f0104f13:	e8 37 e7 ff ff       	call   f010364f <envid2env>
	if (Ecode)
f0104f18:	85 c0                	test   %eax,%eax
f0104f1a:	0f 85 c2 01 00 00    	jne    f01050e2 <syscall+0x542>
	e->env_pgfault_upcall = func;
f0104f20:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104f23:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104f26:	89 4a 64             	mov    %ecx,0x64(%edx)
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f0104f29:	e9 b4 01 00 00       	jmp    f01050e2 <syscall+0x542>
	if ((Ecode = envid2env(envid, &dst, 0)) < 0)
f0104f2e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104f35:	00 
f0104f36:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104f39:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f3d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f40:	89 04 24             	mov    %eax,(%esp)
f0104f43:	e8 07 e7 ff ff       	call   f010364f <envid2env>
f0104f48:	85 c0                	test   %eax,%eax
f0104f4a:	0f 88 92 01 00 00    	js     f01050e2 <syscall+0x542>
	if (!dst->env_ipc_recving)
f0104f50:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f53:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104f57:	0f 84 fa 00 00 00    	je     f0105057 <syscall+0x4b7>
	if ((uintptr_t)srcva >= UTOP)
f0104f5d:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104f64:	0f 87 9b 00 00 00    	ja     f0105005 <syscall+0x465>
		if ((uintptr_t)srcva % PGSIZE != 0)
f0104f6a:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104f71:	0f 85 ea 00 00 00    	jne    f0105061 <syscall+0x4c1>
		if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U))
f0104f77:	8b 45 18             	mov    0x18(%ebp),%eax
f0104f7a:	83 e0 05             	and    $0x5,%eax
f0104f7d:	83 f8 05             	cmp    $0x5,%eax
f0104f80:	0f 85 e2 00 00 00    	jne    f0105068 <syscall+0x4c8>
		if (perm & ~PTE_SYSCALL)
f0104f86:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f0104f8d:	0f 85 dc 00 00 00    	jne    f010506f <syscall+0x4cf>
		if (!(pp = page_lookup(curenv->env_pgdir, srcva, &pte)))
f0104f93:	e8 01 14 00 00       	call   f0106399 <cpunum>
f0104f98:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104f9b:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104f9f:	8b 7d 14             	mov    0x14(%ebp),%edi
f0104fa2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104fa6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fa9:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f0104faf:	8b 40 60             	mov    0x60(%eax),%eax
f0104fb2:	89 04 24             	mov    %eax,(%esp)
f0104fb5:	e8 39 c3 ff ff       	call   f01012f3 <page_lookup>
f0104fba:	85 c0                	test   %eax,%eax
f0104fbc:	0f 84 b4 00 00 00    	je     f0105076 <syscall+0x4d6>
		if ((perm & PTE_W) && !(*pte & PTE_W))
f0104fc2:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104fc6:	74 0c                	je     f0104fd4 <syscall+0x434>
f0104fc8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104fcb:	f6 02 02             	testb  $0x2,(%edx)
f0104fce:	0f 84 a9 00 00 00    	je     f010507d <syscall+0x4dd>
		if ((uintptr_t)dst->env_ipc_dstva < UTOP)
f0104fd4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104fd7:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0104fda:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f0104fe0:	77 2c                	ja     f010500e <syscall+0x46e>
			if ((Ecode = page_insert(dst->env_pgdir, pp, dst->env_ipc_dstva, perm)) < 0)
f0104fe2:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0104fe5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104fe9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104fed:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ff1:	8b 42 60             	mov    0x60(%edx),%eax
f0104ff4:	89 04 24             	mov    %eax,(%esp)
f0104ff7:	e8 46 c4 ff ff       	call   f0101442 <page_insert>
f0104ffc:	85 c0                	test   %eax,%eax
f0104ffe:	79 15                	jns    f0105015 <syscall+0x475>
f0105000:	e9 dd 00 00 00       	jmp    f01050e2 <syscall+0x542>
		perm = 0;
f0105005:	c7 45 18 00 00 00 00 	movl   $0x0,0x18(%ebp)
f010500c:	eb 07                	jmp    f0105015 <syscall+0x475>
			perm = 0;
f010500e:	c7 45 18 00 00 00 00 	movl   $0x0,0x18(%ebp)
	dst->env_ipc_recving = false;
f0105015:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105018:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	dst->env_ipc_from = curenv->env_id;
f010501c:	e8 78 13 00 00       	call   f0106399 <cpunum>
f0105021:	6b c0 74             	imul   $0x74,%eax,%eax
f0105024:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f010502a:	8b 40 48             	mov    0x48(%eax),%eax
f010502d:	89 43 74             	mov    %eax,0x74(%ebx)
	dst->env_ipc_value = value;
f0105030:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105033:	8b 75 10             	mov    0x10(%ebp),%esi
f0105036:	89 70 70             	mov    %esi,0x70(%eax)
	dst->env_ipc_perm = perm;
f0105039:	8b 7d 18             	mov    0x18(%ebp),%edi
f010503c:	89 78 78             	mov    %edi,0x78(%eax)
	dst->env_status = ENV_RUNNABLE;
f010503f:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	dst->env_tf.tf_regs.reg_eax = 0;
f0105046:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f010504d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105052:	e9 8b 00 00 00       	jmp    f01050e2 <syscall+0x542>
		return -E_IPC_NOT_RECV;
f0105057:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f010505c:	e9 81 00 00 00       	jmp    f01050e2 <syscall+0x542>
			return -E_INVAL;
f0105061:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105066:	eb 7a                	jmp    f01050e2 <syscall+0x542>
			return -E_INVAL;
f0105068:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010506d:	eb 73                	jmp    f01050e2 <syscall+0x542>
			return -E_INVAL;
f010506f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105074:	eb 6c                	jmp    f01050e2 <syscall+0x542>
			return -E_INVAL;
f0105076:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010507b:	eb 65                	jmp    f01050e2 <syscall+0x542>
			return -E_INVAL;
f010507d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105082:	eb 5e                	jmp    f01050e2 <syscall+0x542>
	if ((uintptr_t)dstva < UTOP && (uintptr_t)dstva % PGSIZE != 0)
f0105084:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f010508b:	77 09                	ja     f0105096 <syscall+0x4f6>
f010508d:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0105094:	75 47                	jne    f01050dd <syscall+0x53d>
	curenv->env_ipc_recving = true;
f0105096:	e8 fe 12 00 00       	call   f0106399 <cpunum>
f010509b:	6b c0 74             	imul   $0x74,%eax,%eax
f010509e:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f01050a4:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f01050a8:	e8 ec 12 00 00       	call   f0106399 <cpunum>
f01050ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01050b0:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f01050b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01050b9:	89 48 6c             	mov    %ecx,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f01050bc:	e8 d8 12 00 00       	call   f0106399 <cpunum>
f01050c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01050c4:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f01050ca:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f01050d1:	e8 19 fa ff ff       	call   f0104aef <sched_yield>
		return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned int)a4);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *)a1);
	case NSYSCALLS:
	default:
		return -E_INVAL;
f01050d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050db:	eb 05                	jmp    f01050e2 <syscall+0x542>
		return sys_ipc_recv((void *)a1);
f01050dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f01050e2:	83 c4 2c             	add    $0x2c,%esp
f01050e5:	5b                   	pop    %ebx
f01050e6:	5e                   	pop    %esi
f01050e7:	5f                   	pop    %edi
f01050e8:	5d                   	pop    %ebp
f01050e9:	c3                   	ret    

f01050ea <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
			   int type, uintptr_t addr)
{
f01050ea:	55                   	push   %ebp
f01050eb:	89 e5                	mov    %esp,%ebp
f01050ed:	57                   	push   %edi
f01050ee:	56                   	push   %esi
f01050ef:	53                   	push   %ebx
f01050f0:	83 ec 14             	sub    $0x14,%esp
f01050f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01050f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01050f9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01050fc:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01050ff:	8b 1a                	mov    (%edx),%ebx
f0105101:	8b 01                	mov    (%ecx),%eax
f0105103:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105106:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r)
f010510d:	e9 88 00 00 00       	jmp    f010519a <stab_binsearch+0xb0>
	{
		int true_m = (l + r) / 2, m = true_m;
f0105112:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105115:	01 d8                	add    %ebx,%eax
f0105117:	89 c7                	mov    %eax,%edi
f0105119:	c1 ef 1f             	shr    $0x1f,%edi
f010511c:	01 c7                	add    %eax,%edi
f010511e:	d1 ff                	sar    %edi
f0105120:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0105123:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105126:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0105129:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010512b:	eb 03                	jmp    f0105130 <stab_binsearch+0x46>
			m--;
f010512d:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0105130:	39 c3                	cmp    %eax,%ebx
f0105132:	7f 1f                	jg     f0105153 <stab_binsearch+0x69>
f0105134:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105138:	83 ea 0c             	sub    $0xc,%edx
f010513b:	39 f1                	cmp    %esi,%ecx
f010513d:	75 ee                	jne    f010512d <stab_binsearch+0x43>
f010513f:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr)
f0105142:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105145:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105148:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010514c:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010514f:	76 18                	jbe    f0105169 <stab_binsearch+0x7f>
f0105151:	eb 05                	jmp    f0105158 <stab_binsearch+0x6e>
			l = true_m + 1;
f0105153:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0105156:	eb 42                	jmp    f010519a <stab_binsearch+0xb0>
		{
			*region_left = m;
f0105158:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010515b:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010515d:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0105160:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105167:	eb 31                	jmp    f010519a <stab_binsearch+0xb0>
		}
		else if (stabs[m].n_value > addr)
f0105169:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010516c:	73 17                	jae    f0105185 <stab_binsearch+0x9b>
		{
			*region_right = m - 1;
f010516e:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0105171:	83 e8 01             	sub    $0x1,%eax
f0105174:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105177:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010517a:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f010517c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105183:	eb 15                	jmp    f010519a <stab_binsearch+0xb0>
		}
		else
		{
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105185:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105188:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f010518b:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f010518d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105191:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0105193:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r)
f010519a:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010519d:	0f 8e 6f ff ff ff    	jle    f0105112 <stab_binsearch+0x28>
		}
	}

	if (!any_matches)
f01051a3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01051a7:	75 0f                	jne    f01051b8 <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f01051a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01051ac:	8b 00                	mov    (%eax),%eax
f01051ae:	83 e8 01             	sub    $0x1,%eax
f01051b1:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01051b4:	89 07                	mov    %eax,(%edi)
f01051b6:	eb 2c                	jmp    f01051e4 <stab_binsearch+0xfa>
	else
	{
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01051b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01051bb:	8b 00                	mov    (%eax),%eax
			 l > *region_left && stabs[l].n_type != type;
f01051bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051c0:	8b 0f                	mov    (%edi),%ecx
f01051c2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01051c5:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01051c8:	8d 14 97             	lea    (%edi,%edx,4),%edx
		for (l = *region_right;
f01051cb:	eb 03                	jmp    f01051d0 <stab_binsearch+0xe6>
			 l--)
f01051cd:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f01051d0:	39 c8                	cmp    %ecx,%eax
f01051d2:	7e 0b                	jle    f01051df <stab_binsearch+0xf5>
			 l > *region_left && stabs[l].n_type != type;
f01051d4:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01051d8:	83 ea 0c             	sub    $0xc,%edx
f01051db:	39 f3                	cmp    %esi,%ebx
f01051dd:	75 ee                	jne    f01051cd <stab_binsearch+0xe3>
			/* do nothing */;
		*region_left = l;
f01051df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051e2:	89 07                	mov    %eax,(%edi)
	}
}
f01051e4:	83 c4 14             	add    $0x14,%esp
f01051e7:	5b                   	pop    %ebx
f01051e8:	5e                   	pop    %esi
f01051e9:	5f                   	pop    %edi
f01051ea:	5d                   	pop    %ebp
f01051eb:	c3                   	ret    

f01051ec <debuginfo_eip>:
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01051ec:	55                   	push   %ebp
f01051ed:	89 e5                	mov    %esp,%ebp
f01051ef:	57                   	push   %edi
f01051f0:	56                   	push   %esi
f01051f1:	53                   	push   %ebx
f01051f2:	83 ec 4c             	sub    $0x4c,%esp
f01051f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01051f8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01051fb:	c7 07 c4 81 10 f0    	movl   $0xf01081c4,(%edi)
	info->eip_line = 0;
f0105201:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0105208:	c7 47 08 c4 81 10 f0 	movl   $0xf01081c4,0x8(%edi)
	info->eip_fn_namelen = 9;
f010520f:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0105216:	89 5f 10             	mov    %ebx,0x10(%edi)
	info->eip_fn_narg = 0;
f0105219:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM)
f0105220:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0105226:	0f 87 cf 00 00 00    	ja     f01052fb <debuginfo_eip+0x10f>
		const struct UserStabData *usd = (const struct UserStabData *)USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0)
f010522c:	e8 68 11 00 00       	call   f0106399 <cpunum>
f0105231:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105238:	00 
f0105239:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0105240:	00 
f0105241:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0105248:	00 
f0105249:	6b c0 74             	imul   $0x74,%eax,%eax
f010524c:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f0105252:	89 04 24             	mov    %eax,(%esp)
f0105255:	e8 83 e2 ff ff       	call   f01034dd <user_mem_check>
f010525a:	85 c0                	test   %eax,%eax
f010525c:	0f 88 6c 02 00 00    	js     f01054ce <debuginfo_eip+0x2e2>
			return -1;

		stabs = usd->stabs;
f0105262:	a1 00 00 20 00       	mov    0x200000,%eax
		stab_end = usd->stab_end;
f0105267:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f010526d:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0105273:	89 4d c0             	mov    %ecx,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0105276:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f010527c:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, PTE_U) < 0 ||
f010527f:	89 f2                	mov    %esi,%edx
f0105281:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0105284:	29 c2                	sub    %eax,%edx
f0105286:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0105289:	e8 0b 11 00 00       	call   f0106399 <cpunum>
f010528e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105295:	00 
f0105296:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0105299:	89 54 24 08          	mov    %edx,0x8(%esp)
f010529d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01052a0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01052a4:	6b c0 74             	imul   $0x74,%eax,%eax
f01052a7:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f01052ad:	89 04 24             	mov    %eax,(%esp)
f01052b0:	e8 28 e2 ff ff       	call   f01034dd <user_mem_check>
f01052b5:	85 c0                	test   %eax,%eax
f01052b7:	0f 88 18 02 00 00    	js     f01054d5 <debuginfo_eip+0x2e9>
			user_mem_check(curenv, (void *)stabstr, (uintptr_t)stabstr_end - (uintptr_t)stabstr, PTE_U) < 0)
f01052bd:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01052c0:	2b 55 c0             	sub    -0x40(%ebp),%edx
f01052c3:	89 55 b8             	mov    %edx,-0x48(%ebp)
f01052c6:	e8 ce 10 00 00       	call   f0106399 <cpunum>
f01052cb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01052d2:	00 
f01052d3:	8b 55 b8             	mov    -0x48(%ebp),%edx
f01052d6:	89 54 24 08          	mov    %edx,0x8(%esp)
f01052da:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01052dd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01052e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01052e4:	8b 80 28 80 1e f0    	mov    -0xfe17fd8(%eax),%eax
f01052ea:	89 04 24             	mov    %eax,(%esp)
f01052ed:	e8 eb e1 ff ff       	call   f01034dd <user_mem_check>
		if (user_mem_check(curenv, (void *)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, PTE_U) < 0 ||
f01052f2:	85 c0                	test   %eax,%eax
f01052f4:	79 1f                	jns    f0105315 <debuginfo_eip+0x129>
f01052f6:	e9 e1 01 00 00       	jmp    f01054dc <debuginfo_eip+0x2f0>
		stabstr_end = __STABSTR_END__;
f01052fb:	c7 45 bc d1 63 11 f0 	movl   $0xf01163d1,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0105302:	c7 45 c0 ad 2c 11 f0 	movl   $0xf0112cad,-0x40(%ebp)
		stab_end = __STAB_END__;
f0105309:	be ac 2c 11 f0       	mov    $0xf0112cac,%esi
		stabs = __STAB_BEGIN__;
f010530e:	c7 45 c4 70 87 10 f0 	movl   $0xf0108770,-0x3c(%ebp)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105315:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105318:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f010531b:	0f 83 c2 01 00 00    	jae    f01054e3 <debuginfo_eip+0x2f7>
f0105321:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0105325:	0f 85 bf 01 00 00    	jne    f01054ea <debuginfo_eip+0x2fe>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010532b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105332:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f0105335:	c1 fe 02             	sar    $0x2,%esi
f0105338:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f010533e:	83 e8 01             	sub    $0x1,%eax
f0105341:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105344:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105348:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f010534f:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105352:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105355:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105358:	89 f0                	mov    %esi,%eax
f010535a:	e8 8b fd ff ff       	call   f01050ea <stab_binsearch>
	if (lfile == 0)
f010535f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105362:	85 c0                	test   %eax,%eax
f0105364:	0f 84 87 01 00 00    	je     f01054f1 <debuginfo_eip+0x305>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010536a:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010536d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105370:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105373:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105377:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f010537e:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105381:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105384:	89 f0                	mov    %esi,%eax
f0105386:	e8 5f fd ff ff       	call   f01050ea <stab_binsearch>

	if (lfun <= rfun)
f010538b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010538e:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0105391:	39 f0                	cmp    %esi,%eax
f0105393:	7f 32                	jg     f01053c7 <debuginfo_eip+0x1db>
	{
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105395:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105398:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010539b:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f010539e:	8b 0a                	mov    (%edx),%ecx
f01053a0:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f01053a3:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f01053a6:	2b 4d c0             	sub    -0x40(%ebp),%ecx
f01053a9:	39 4d b8             	cmp    %ecx,-0x48(%ebp)
f01053ac:	73 09                	jae    f01053b7 <debuginfo_eip+0x1cb>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01053ae:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f01053b1:	03 4d c0             	add    -0x40(%ebp),%ecx
f01053b4:	89 4f 08             	mov    %ecx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01053b7:	8b 52 08             	mov    0x8(%edx),%edx
f01053ba:	89 57 10             	mov    %edx,0x10(%edi)
		addr -= info->eip_fn_addr;
f01053bd:	29 d3                	sub    %edx,%ebx
		// Search within the function definition for the line number.
		lline = lfun;
f01053bf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01053c2:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01053c5:	eb 0f                	jmp    f01053d6 <debuginfo_eip+0x1ea>
	}
	else
	{
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01053c7:	89 5f 10             	mov    %ebx,0x10(%edi)
		lline = lfile;
f01053ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01053cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01053d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01053d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01053d6:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01053dd:	00 
f01053de:	8b 47 08             	mov    0x8(%edi),%eax
f01053e1:	89 04 24             	mov    %eax,(%esp)
f01053e4:	e8 42 09 00 00       	call   f0105d2b <strfind>
f01053e9:	2b 47 08             	sub    0x8(%edi),%eax
f01053ec:	89 47 0c             	mov    %eax,0xc(%edi)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr); // 根据%eip的值作为地址查找
f01053ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01053f3:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01053fa:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01053fd:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105400:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105403:	89 f0                	mov    %esi,%eax
f0105405:	e8 e0 fc ff ff       	call   f01050ea <stab_binsearch>
	if (lline <= rline)									  // 二分查找，left<=right即终止
f010540a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010540d:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0105410:	7f 20                	jg     f0105432 <debuginfo_eip+0x246>
	{
		info->eip_line = stabs[lline].n_desc;
f0105412:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105415:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f010541a:	89 47 04             	mov    %eax,0x4(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile && stabs[lline].n_type != N_SOL && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010541d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105420:	89 c3                	mov    %eax,%ebx
f0105422:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105425:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105428:	8d 14 96             	lea    (%esi,%edx,4),%edx
f010542b:	89 7d 0c             	mov    %edi,0xc(%ebp)
f010542e:	89 df                	mov    %ebx,%edi
f0105430:	eb 17                	jmp    f0105449 <debuginfo_eip+0x25d>
		info->eip_line = 0;
f0105432:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
		return -1;
f0105439:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010543e:	e9 ba 00 00 00       	jmp    f01054fd <debuginfo_eip+0x311>
f0105443:	83 e8 01             	sub    $0x1,%eax
f0105446:	83 ea 0c             	sub    $0xc,%edx
f0105449:	89 c6                	mov    %eax,%esi
	while (lline >= lfile && stabs[lline].n_type != N_SOL && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010544b:	39 c7                	cmp    %eax,%edi
f010544d:	7f 3c                	jg     f010548b <debuginfo_eip+0x29f>
f010544f:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105453:	80 f9 84             	cmp    $0x84,%cl
f0105456:	75 08                	jne    f0105460 <debuginfo_eip+0x274>
f0105458:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010545b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010545e:	eb 11                	jmp    f0105471 <debuginfo_eip+0x285>
f0105460:	80 f9 64             	cmp    $0x64,%cl
f0105463:	75 de                	jne    f0105443 <debuginfo_eip+0x257>
f0105465:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0105469:	74 d8                	je     f0105443 <debuginfo_eip+0x257>
f010546b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010546e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105471:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0105474:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0105477:	8b 04 83             	mov    (%ebx,%eax,4),%eax
f010547a:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010547d:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0105480:	39 d0                	cmp    %edx,%eax
f0105482:	73 0a                	jae    f010548e <debuginfo_eip+0x2a2>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105484:	03 45 c0             	add    -0x40(%ebp),%eax
f0105487:	89 07                	mov    %eax,(%edi)
f0105489:	eb 03                	jmp    f010548e <debuginfo_eip+0x2a2>
f010548b:	8b 7d 0c             	mov    0xc(%ebp),%edi

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010548e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105491:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
			 lline < rfun && stabs[lline].n_type == N_PSYM;
			 lline++)
			info->eip_fn_narg++;

	return 0;
f0105494:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0105499:	39 da                	cmp    %ebx,%edx
f010549b:	7d 60                	jge    f01054fd <debuginfo_eip+0x311>
		for (lline = lfun + 1;
f010549d:	83 c2 01             	add    $0x1,%edx
f01054a0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01054a3:	89 d0                	mov    %edx,%eax
f01054a5:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01054a8:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01054ab:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01054ae:	eb 04                	jmp    f01054b4 <debuginfo_eip+0x2c8>
			info->eip_fn_narg++;
f01054b0:	83 47 14 01          	addl   $0x1,0x14(%edi)
		for (lline = lfun + 1;
f01054b4:	39 c3                	cmp    %eax,%ebx
f01054b6:	7e 40                	jle    f01054f8 <debuginfo_eip+0x30c>
			 lline < rfun && stabs[lline].n_type == N_PSYM;
f01054b8:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01054bc:	83 c0 01             	add    $0x1,%eax
f01054bf:	83 c2 0c             	add    $0xc,%edx
f01054c2:	80 f9 a0             	cmp    $0xa0,%cl
f01054c5:	74 e9                	je     f01054b0 <debuginfo_eip+0x2c4>
	return 0;
f01054c7:	b8 00 00 00 00       	mov    $0x0,%eax
f01054cc:	eb 2f                	jmp    f01054fd <debuginfo_eip+0x311>
			return -1;
f01054ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01054d3:	eb 28                	jmp    f01054fd <debuginfo_eip+0x311>
			return -1;
f01054d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01054da:	eb 21                	jmp    f01054fd <debuginfo_eip+0x311>
f01054dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01054e1:	eb 1a                	jmp    f01054fd <debuginfo_eip+0x311>
		return -1;
f01054e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01054e8:	eb 13                	jmp    f01054fd <debuginfo_eip+0x311>
f01054ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01054ef:	eb 0c                	jmp    f01054fd <debuginfo_eip+0x311>
		return -1;
f01054f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01054f6:	eb 05                	jmp    f01054fd <debuginfo_eip+0x311>
	return 0;
f01054f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01054fd:	83 c4 4c             	add    $0x4c,%esp
f0105500:	5b                   	pop    %ebx
f0105501:	5e                   	pop    %esi
f0105502:	5f                   	pop    %edi
f0105503:	5d                   	pop    %ebp
f0105504:	c3                   	ret    
f0105505:	66 90                	xchg   %ax,%ax
f0105507:	66 90                	xchg   %ax,%ax
f0105509:	66 90                	xchg   %ax,%ax
f010550b:	66 90                	xchg   %ax,%ax
f010550d:	66 90                	xchg   %ax,%ax
f010550f:	90                   	nop

f0105510 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
f0105510:	55                   	push   %ebp
f0105511:	89 e5                	mov    %esp,%ebp
f0105513:	57                   	push   %edi
f0105514:	56                   	push   %esi
f0105515:	53                   	push   %ebx
f0105516:	83 ec 3c             	sub    $0x3c,%esp
f0105519:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010551c:	89 d7                	mov    %edx,%edi
f010551e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105521:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105524:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105527:	89 c3                	mov    %eax,%ebx
f0105529:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010552c:	8b 45 10             	mov    0x10(%ebp),%eax
f010552f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base)
f0105532:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105537:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010553a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010553d:	39 d9                	cmp    %ebx,%ecx
f010553f:	72 05                	jb     f0105546 <printnum+0x36>
f0105541:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0105544:	77 69                	ja     f01055af <printnum+0x9f>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105546:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105549:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f010554d:	83 ee 01             	sub    $0x1,%esi
f0105550:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105554:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105558:	8b 44 24 08          	mov    0x8(%esp),%eax
f010555c:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105560:	89 c3                	mov    %eax,%ebx
f0105562:	89 d6                	mov    %edx,%esi
f0105564:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105567:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010556a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010556e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105572:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105575:	89 04 24             	mov    %eax,(%esp)
f0105578:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010557b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010557f:	e8 5c 12 00 00       	call   f01067e0 <__udivdi3>
f0105584:	89 d9                	mov    %ebx,%ecx
f0105586:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010558a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010558e:	89 04 24             	mov    %eax,(%esp)
f0105591:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105595:	89 fa                	mov    %edi,%edx
f0105597:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010559a:	e8 71 ff ff ff       	call   f0105510 <printnum>
f010559f:	eb 1b                	jmp    f01055bc <printnum+0xac>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01055a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01055a5:	8b 45 18             	mov    0x18(%ebp),%eax
f01055a8:	89 04 24             	mov    %eax,(%esp)
f01055ab:	ff d3                	call   *%ebx
f01055ad:	eb 03                	jmp    f01055b2 <printnum+0xa2>
f01055af:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
f01055b2:	83 ee 01             	sub    $0x1,%esi
f01055b5:	85 f6                	test   %esi,%esi
f01055b7:	7f e8                	jg     f01055a1 <printnum+0x91>
f01055b9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01055bc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01055c0:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01055c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01055c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01055ca:	89 44 24 08          	mov    %eax,0x8(%esp)
f01055ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01055d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01055d5:	89 04 24             	mov    %eax,(%esp)
f01055d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01055db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055df:	e8 2c 13 00 00       	call   f0106910 <__umoddi3>
f01055e4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01055e8:	0f be 80 ce 81 10 f0 	movsbl -0xfef7e32(%eax),%eax
f01055ef:	89 04 24             	mov    %eax,(%esp)
f01055f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01055f5:	ff d0                	call   *%eax
}
f01055f7:	83 c4 3c             	add    $0x3c,%esp
f01055fa:	5b                   	pop    %ebx
f01055fb:	5e                   	pop    %esi
f01055fc:	5f                   	pop    %edi
f01055fd:	5d                   	pop    %ebp
f01055fe:	c3                   	ret    

f01055ff <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01055ff:	55                   	push   %ebp
f0105600:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105602:	83 fa 01             	cmp    $0x1,%edx
f0105605:	7e 0e                	jle    f0105615 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105607:	8b 10                	mov    (%eax),%edx
f0105609:	8d 4a 08             	lea    0x8(%edx),%ecx
f010560c:	89 08                	mov    %ecx,(%eax)
f010560e:	8b 02                	mov    (%edx),%eax
f0105610:	8b 52 04             	mov    0x4(%edx),%edx
f0105613:	eb 22                	jmp    f0105637 <getuint+0x38>
	else if (lflag)
f0105615:	85 d2                	test   %edx,%edx
f0105617:	74 10                	je     f0105629 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105619:	8b 10                	mov    (%eax),%edx
f010561b:	8d 4a 04             	lea    0x4(%edx),%ecx
f010561e:	89 08                	mov    %ecx,(%eax)
f0105620:	8b 02                	mov    (%edx),%eax
f0105622:	ba 00 00 00 00       	mov    $0x0,%edx
f0105627:	eb 0e                	jmp    f0105637 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105629:	8b 10                	mov    (%eax),%edx
f010562b:	8d 4a 04             	lea    0x4(%edx),%ecx
f010562e:	89 08                	mov    %ecx,(%eax)
f0105630:	8b 02                	mov    (%edx),%eax
f0105632:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105637:	5d                   	pop    %ebp
f0105638:	c3                   	ret    

f0105639 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105639:	55                   	push   %ebp
f010563a:	89 e5                	mov    %esp,%ebp
f010563c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010563f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105643:	8b 10                	mov    (%eax),%edx
f0105645:	3b 50 04             	cmp    0x4(%eax),%edx
f0105648:	73 0a                	jae    f0105654 <sprintputch+0x1b>
		*b->buf++ = ch;
f010564a:	8d 4a 01             	lea    0x1(%edx),%ecx
f010564d:	89 08                	mov    %ecx,(%eax)
f010564f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105652:	88 02                	mov    %al,(%edx)
}
f0105654:	5d                   	pop    %ebp
f0105655:	c3                   	ret    

f0105656 <printfmt>:
{
f0105656:	55                   	push   %ebp
f0105657:	89 e5                	mov    %esp,%ebp
f0105659:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
f010565c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010565f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105663:	8b 45 10             	mov    0x10(%ebp),%eax
f0105666:	89 44 24 08          	mov    %eax,0x8(%esp)
f010566a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010566d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105671:	8b 45 08             	mov    0x8(%ebp),%eax
f0105674:	89 04 24             	mov    %eax,(%esp)
f0105677:	e8 02 00 00 00       	call   f010567e <vprintfmt>
}
f010567c:	c9                   	leave  
f010567d:	c3                   	ret    

f010567e <vprintfmt>:
{
f010567e:	55                   	push   %ebp
f010567f:	89 e5                	mov    %esp,%ebp
f0105681:	57                   	push   %edi
f0105682:	56                   	push   %esi
f0105683:	53                   	push   %ebx
f0105684:	83 ec 3c             	sub    $0x3c,%esp
f0105687:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010568a:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010568d:	eb 14                	jmp    f01056a3 <vprintfmt+0x25>
			if (ch == '\0')
f010568f:	85 c0                	test   %eax,%eax
f0105691:	0f 84 b3 03 00 00    	je     f0105a4a <vprintfmt+0x3cc>
			putch(ch, putdat);
f0105697:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010569b:	89 04 24             	mov    %eax,(%esp)
f010569e:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
f01056a1:	89 f3                	mov    %esi,%ebx
f01056a3:	8d 73 01             	lea    0x1(%ebx),%esi
f01056a6:	0f b6 03             	movzbl (%ebx),%eax
f01056a9:	83 f8 25             	cmp    $0x25,%eax
f01056ac:	75 e1                	jne    f010568f <vprintfmt+0x11>
f01056ae:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f01056b2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01056b9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f01056c0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f01056c7:	ba 00 00 00 00       	mov    $0x0,%edx
f01056cc:	eb 1d                	jmp    f01056eb <vprintfmt+0x6d>
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f01056ce:	89 de                	mov    %ebx,%esi
			padc = '-';
f01056d0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f01056d4:	eb 15                	jmp    f01056eb <vprintfmt+0x6d>
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f01056d6:	89 de                	mov    %ebx,%esi
			padc = '0';
f01056d8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f01056dc:	eb 0d                	jmp    f01056eb <vprintfmt+0x6d>
				width = precision, precision = -1;
f01056de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01056e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01056e4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f01056eb:	8d 5e 01             	lea    0x1(%esi),%ebx
f01056ee:	0f b6 0e             	movzbl (%esi),%ecx
f01056f1:	0f b6 c1             	movzbl %cl,%eax
f01056f4:	83 e9 23             	sub    $0x23,%ecx
f01056f7:	80 f9 55             	cmp    $0x55,%cl
f01056fa:	0f 87 2a 03 00 00    	ja     f0105a2a <vprintfmt+0x3ac>
f0105700:	0f b6 c9             	movzbl %cl,%ecx
f0105703:	ff 24 8d 20 83 10 f0 	jmp    *-0xfef7ce0(,%ecx,4)
f010570a:	89 de                	mov    %ebx,%esi
f010570c:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
f0105711:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0105714:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f0105718:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f010571b:	8d 58 d0             	lea    -0x30(%eax),%ebx
f010571e:	83 fb 09             	cmp    $0x9,%ebx
f0105721:	77 36                	ja     f0105759 <vprintfmt+0xdb>
			for (precision = 0;; ++fmt)
f0105723:	83 c6 01             	add    $0x1,%esi
			}
f0105726:	eb e9                	jmp    f0105711 <vprintfmt+0x93>
			precision = va_arg(ap, int);
f0105728:	8b 45 14             	mov    0x14(%ebp),%eax
f010572b:	8d 48 04             	lea    0x4(%eax),%ecx
f010572e:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105731:	8b 00                	mov    (%eax),%eax
f0105733:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f0105736:	89 de                	mov    %ebx,%esi
			goto process_precision;
f0105738:	eb 22                	jmp    f010575c <vprintfmt+0xde>
f010573a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010573d:	85 c9                	test   %ecx,%ecx
f010573f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105744:	0f 49 c1             	cmovns %ecx,%eax
f0105747:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f010574a:	89 de                	mov    %ebx,%esi
f010574c:	eb 9d                	jmp    f01056eb <vprintfmt+0x6d>
f010574e:	89 de                	mov    %ebx,%esi
			altflag = 1;
f0105750:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0105757:	eb 92                	jmp    f01056eb <vprintfmt+0x6d>
f0105759:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
f010575c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105760:	79 89                	jns    f01056eb <vprintfmt+0x6d>
f0105762:	e9 77 ff ff ff       	jmp    f01056de <vprintfmt+0x60>
			lflag++;
f0105767:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f010576a:	89 de                	mov    %ebx,%esi
			goto reswitch;
f010576c:	e9 7a ff ff ff       	jmp    f01056eb <vprintfmt+0x6d>
			putch(va_arg(ap, int), putdat);
f0105771:	8b 45 14             	mov    0x14(%ebp),%eax
f0105774:	8d 50 04             	lea    0x4(%eax),%edx
f0105777:	89 55 14             	mov    %edx,0x14(%ebp)
f010577a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010577e:	8b 00                	mov    (%eax),%eax
f0105780:	89 04 24             	mov    %eax,(%esp)
f0105783:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105786:	e9 18 ff ff ff       	jmp    f01056a3 <vprintfmt+0x25>
			err = va_arg(ap, int);
f010578b:	8b 45 14             	mov    0x14(%ebp),%eax
f010578e:	8d 50 04             	lea    0x4(%eax),%edx
f0105791:	89 55 14             	mov    %edx,0x14(%ebp)
f0105794:	8b 00                	mov    (%eax),%eax
f0105796:	99                   	cltd   
f0105797:	31 d0                	xor    %edx,%eax
f0105799:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010579b:	83 f8 0f             	cmp    $0xf,%eax
f010579e:	7f 0b                	jg     f01057ab <vprintfmt+0x12d>
f01057a0:	8b 14 85 80 84 10 f0 	mov    -0xfef7b80(,%eax,4),%edx
f01057a7:	85 d2                	test   %edx,%edx
f01057a9:	75 20                	jne    f01057cb <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
f01057ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01057af:	c7 44 24 08 e6 81 10 	movl   $0xf01081e6,0x8(%esp)
f01057b6:	f0 
f01057b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01057bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01057be:	89 04 24             	mov    %eax,(%esp)
f01057c1:	e8 90 fe ff ff       	call   f0105656 <printfmt>
f01057c6:	e9 d8 fe ff ff       	jmp    f01056a3 <vprintfmt+0x25>
				printfmt(putch, putdat, "%s", p);
f01057cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01057cf:	c7 44 24 08 31 7a 10 	movl   $0xf0107a31,0x8(%esp)
f01057d6:	f0 
f01057d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01057db:	8b 45 08             	mov    0x8(%ebp),%eax
f01057de:	89 04 24             	mov    %eax,(%esp)
f01057e1:	e8 70 fe ff ff       	call   f0105656 <printfmt>
f01057e6:	e9 b8 fe ff ff       	jmp    f01056a3 <vprintfmt+0x25>
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f01057eb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01057ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01057f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
f01057f4:	8b 45 14             	mov    0x14(%ebp),%eax
f01057f7:	8d 50 04             	lea    0x4(%eax),%edx
f01057fa:	89 55 14             	mov    %edx,0x14(%ebp)
f01057fd:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f01057ff:	85 f6                	test   %esi,%esi
f0105801:	b8 df 81 10 f0       	mov    $0xf01081df,%eax
f0105806:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0105809:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f010580d:	0f 84 97 00 00 00    	je     f01058aa <vprintfmt+0x22c>
f0105813:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0105817:	0f 8e 9b 00 00 00    	jle    f01058b8 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
f010581d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105821:	89 34 24             	mov    %esi,(%esp)
f0105824:	e8 af 03 00 00       	call   f0105bd8 <strnlen>
f0105829:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010582c:	29 c2                	sub    %eax,%edx
f010582e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
f0105831:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0105835:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105838:	89 75 d8             	mov    %esi,-0x28(%ebp)
f010583b:	8b 75 08             	mov    0x8(%ebp),%esi
f010583e:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105841:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
f0105843:	eb 0f                	jmp    f0105854 <vprintfmt+0x1d6>
					putch(padc, putdat);
f0105845:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105849:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010584c:	89 04 24             	mov    %eax,(%esp)
f010584f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105851:	83 eb 01             	sub    $0x1,%ebx
f0105854:	85 db                	test   %ebx,%ebx
f0105856:	7f ed                	jg     f0105845 <vprintfmt+0x1c7>
f0105858:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010585b:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010585e:	85 d2                	test   %edx,%edx
f0105860:	b8 00 00 00 00       	mov    $0x0,%eax
f0105865:	0f 49 c2             	cmovns %edx,%eax
f0105868:	29 c2                	sub    %eax,%edx
f010586a:	89 7d 0c             	mov    %edi,0xc(%ebp)
f010586d:	89 d7                	mov    %edx,%edi
f010586f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105872:	eb 50                	jmp    f01058c4 <vprintfmt+0x246>
				if (altflag && (ch < ' ' || ch > '~'))
f0105874:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105878:	74 1e                	je     f0105898 <vprintfmt+0x21a>
f010587a:	0f be d2             	movsbl %dl,%edx
f010587d:	83 ea 20             	sub    $0x20,%edx
f0105880:	83 fa 5e             	cmp    $0x5e,%edx
f0105883:	76 13                	jbe    f0105898 <vprintfmt+0x21a>
					putch('?', putdat);
f0105885:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105888:	89 44 24 04          	mov    %eax,0x4(%esp)
f010588c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105893:	ff 55 08             	call   *0x8(%ebp)
f0105896:	eb 0d                	jmp    f01058a5 <vprintfmt+0x227>
					putch(ch, putdat);
f0105898:	8b 55 0c             	mov    0xc(%ebp),%edx
f010589b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010589f:	89 04 24             	mov    %eax,(%esp)
f01058a2:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01058a5:	83 ef 01             	sub    $0x1,%edi
f01058a8:	eb 1a                	jmp    f01058c4 <vprintfmt+0x246>
f01058aa:	89 7d 0c             	mov    %edi,0xc(%ebp)
f01058ad:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01058b0:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01058b3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01058b6:	eb 0c                	jmp    f01058c4 <vprintfmt+0x246>
f01058b8:	89 7d 0c             	mov    %edi,0xc(%ebp)
f01058bb:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01058be:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01058c1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01058c4:	83 c6 01             	add    $0x1,%esi
f01058c7:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f01058cb:	0f be c2             	movsbl %dl,%eax
f01058ce:	85 c0                	test   %eax,%eax
f01058d0:	74 27                	je     f01058f9 <vprintfmt+0x27b>
f01058d2:	85 db                	test   %ebx,%ebx
f01058d4:	78 9e                	js     f0105874 <vprintfmt+0x1f6>
f01058d6:	83 eb 01             	sub    $0x1,%ebx
f01058d9:	79 99                	jns    f0105874 <vprintfmt+0x1f6>
f01058db:	89 f8                	mov    %edi,%eax
f01058dd:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01058e0:	8b 75 08             	mov    0x8(%ebp),%esi
f01058e3:	89 c3                	mov    %eax,%ebx
f01058e5:	eb 1a                	jmp    f0105901 <vprintfmt+0x283>
				putch(' ', putdat);
f01058e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01058eb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01058f2:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01058f4:	83 eb 01             	sub    $0x1,%ebx
f01058f7:	eb 08                	jmp    f0105901 <vprintfmt+0x283>
f01058f9:	89 fb                	mov    %edi,%ebx
f01058fb:	8b 75 08             	mov    0x8(%ebp),%esi
f01058fe:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105901:	85 db                	test   %ebx,%ebx
f0105903:	7f e2                	jg     f01058e7 <vprintfmt+0x269>
f0105905:	89 75 08             	mov    %esi,0x8(%ebp)
f0105908:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010590b:	e9 93 fd ff ff       	jmp    f01056a3 <vprintfmt+0x25>
	if (lflag >= 2)
f0105910:	83 fa 01             	cmp    $0x1,%edx
f0105913:	7e 16                	jle    f010592b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
f0105915:	8b 45 14             	mov    0x14(%ebp),%eax
f0105918:	8d 50 08             	lea    0x8(%eax),%edx
f010591b:	89 55 14             	mov    %edx,0x14(%ebp)
f010591e:	8b 50 04             	mov    0x4(%eax),%edx
f0105921:	8b 00                	mov    (%eax),%eax
f0105923:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105926:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105929:	eb 32                	jmp    f010595d <vprintfmt+0x2df>
	else if (lflag)
f010592b:	85 d2                	test   %edx,%edx
f010592d:	74 18                	je     f0105947 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
f010592f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105932:	8d 50 04             	lea    0x4(%eax),%edx
f0105935:	89 55 14             	mov    %edx,0x14(%ebp)
f0105938:	8b 30                	mov    (%eax),%esi
f010593a:	89 75 e0             	mov    %esi,-0x20(%ebp)
f010593d:	89 f0                	mov    %esi,%eax
f010593f:	c1 f8 1f             	sar    $0x1f,%eax
f0105942:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105945:	eb 16                	jmp    f010595d <vprintfmt+0x2df>
		return va_arg(*ap, int);
f0105947:	8b 45 14             	mov    0x14(%ebp),%eax
f010594a:	8d 50 04             	lea    0x4(%eax),%edx
f010594d:	89 55 14             	mov    %edx,0x14(%ebp)
f0105950:	8b 30                	mov    (%eax),%esi
f0105952:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0105955:	89 f0                	mov    %esi,%eax
f0105957:	c1 f8 1f             	sar    $0x1f,%eax
f010595a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
f010595d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105960:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10; // base代表进制数
f0105963:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long)num < 0)
f0105968:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010596c:	0f 89 80 00 00 00    	jns    f01059f2 <vprintfmt+0x374>
				putch('-', putdat);
f0105972:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105976:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010597d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
f0105980:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105983:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105986:	f7 d8                	neg    %eax
f0105988:	83 d2 00             	adc    $0x0,%edx
f010598b:	f7 da                	neg    %edx
			base = 10; // base代表进制数
f010598d:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105992:	eb 5e                	jmp    f01059f2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
f0105994:	8d 45 14             	lea    0x14(%ebp),%eax
f0105997:	e8 63 fc ff ff       	call   f01055ff <getuint>
			base = 10;
f010599c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01059a1:	eb 4f                	jmp    f01059f2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
f01059a3:	8d 45 14             	lea    0x14(%ebp),%eax
f01059a6:	e8 54 fc ff ff       	call   f01055ff <getuint>
			base = 8;
f01059ab:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f01059b0:	eb 40                	jmp    f01059f2 <vprintfmt+0x374>
			putch('0', putdat);
f01059b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01059b6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01059bd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01059c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01059c4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01059cb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
f01059ce:	8b 45 14             	mov    0x14(%ebp),%eax
f01059d1:	8d 50 04             	lea    0x4(%eax),%edx
f01059d4:	89 55 14             	mov    %edx,0x14(%ebp)
f01059d7:	8b 00                	mov    (%eax),%eax
f01059d9:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
f01059de:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01059e3:	eb 0d                	jmp    f01059f2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
f01059e5:	8d 45 14             	lea    0x14(%ebp),%eax
f01059e8:	e8 12 fc ff ff       	call   f01055ff <getuint>
			base = 16;
f01059ed:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
f01059f2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
f01059f6:	89 74 24 10          	mov    %esi,0x10(%esp)
f01059fa:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01059fd:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105a01:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105a05:	89 04 24             	mov    %eax,(%esp)
f0105a08:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105a0c:	89 fa                	mov    %edi,%edx
f0105a0e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a11:	e8 fa fa ff ff       	call   f0105510 <printnum>
			break;
f0105a16:	e9 88 fc ff ff       	jmp    f01056a3 <vprintfmt+0x25>
			putch(ch, putdat);
f0105a1b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a1f:	89 04 24             	mov    %eax,(%esp)
f0105a22:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105a25:	e9 79 fc ff ff       	jmp    f01056a3 <vprintfmt+0x25>
			putch('%', putdat);
f0105a2a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a2e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105a35:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105a38:	89 f3                	mov    %esi,%ebx
f0105a3a:	eb 03                	jmp    f0105a3f <vprintfmt+0x3c1>
f0105a3c:	83 eb 01             	sub    $0x1,%ebx
f0105a3f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0105a43:	75 f7                	jne    f0105a3c <vprintfmt+0x3be>
f0105a45:	e9 59 fc ff ff       	jmp    f01056a3 <vprintfmt+0x25>
}
f0105a4a:	83 c4 3c             	add    $0x3c,%esp
f0105a4d:	5b                   	pop    %ebx
f0105a4e:	5e                   	pop    %esi
f0105a4f:	5f                   	pop    %edi
f0105a50:	5d                   	pop    %ebp
f0105a51:	c3                   	ret    

f0105a52 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105a52:	55                   	push   %ebp
f0105a53:	89 e5                	mov    %esp,%ebp
f0105a55:	83 ec 28             	sub    $0x28,%esp
f0105a58:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a5b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
f0105a5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105a61:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105a65:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105a68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105a6f:	85 c0                	test   %eax,%eax
f0105a71:	74 30                	je     f0105aa3 <vsnprintf+0x51>
f0105a73:	85 d2                	test   %edx,%edx
f0105a75:	7e 2c                	jle    f0105aa3 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
f0105a77:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a7a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105a7e:	8b 45 10             	mov    0x10(%ebp),%eax
f0105a81:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105a85:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105a88:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a8c:	c7 04 24 39 56 10 f0 	movl   $0xf0105639,(%esp)
f0105a93:	e8 e6 fb ff ff       	call   f010567e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105a98:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105a9b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105aa1:	eb 05                	jmp    f0105aa8 <vsnprintf+0x56>
		return -E_INVAL;
f0105aa3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
f0105aa8:	c9                   	leave  
f0105aa9:	c3                   	ret    

f0105aaa <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
f0105aaa:	55                   	push   %ebp
f0105aab:	89 e5                	mov    %esp,%ebp
f0105aad:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105ab0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105ab3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105ab7:	8b 45 10             	mov    0x10(%ebp),%eax
f0105aba:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105abe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105ac1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ac5:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ac8:	89 04 24             	mov    %eax,(%esp)
f0105acb:	e8 82 ff ff ff       	call   f0105a52 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105ad0:	c9                   	leave  
f0105ad1:	c3                   	ret    
f0105ad2:	66 90                	xchg   %ax,%ax
f0105ad4:	66 90                	xchg   %ax,%ax
f0105ad6:	66 90                	xchg   %ax,%ax
f0105ad8:	66 90                	xchg   %ax,%ax
f0105ada:	66 90                	xchg   %ax,%ax
f0105adc:	66 90                	xchg   %ax,%ax
f0105ade:	66 90                	xchg   %ax,%ax

f0105ae0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105ae0:	55                   	push   %ebp
f0105ae1:	89 e5                	mov    %esp,%ebp
f0105ae3:	57                   	push   %edi
f0105ae4:	56                   	push   %esi
f0105ae5:	53                   	push   %ebx
f0105ae6:	83 ec 1c             	sub    $0x1c,%esp
f0105ae9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105aec:	85 c0                	test   %eax,%eax
f0105aee:	74 10                	je     f0105b00 <readline+0x20>
		cprintf("%s", prompt);
f0105af0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105af4:	c7 04 24 31 7a 10 f0 	movl   $0xf0107a31,(%esp)
f0105afb:	e8 cd e3 ff ff       	call   f0103ecd <cprintf>
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105b00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105b07:	e8 cc ac ff ff       	call   f01007d8 <iscons>
f0105b0c:	89 c7                	mov    %eax,%edi
	i = 0;
f0105b0e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0105b13:	e8 af ac ff ff       	call   f01007c7 <getchar>
f0105b18:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105b1a:	85 c0                	test   %eax,%eax
f0105b1c:	79 25                	jns    f0105b43 <readline+0x63>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105b1e:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
f0105b23:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105b26:	0f 84 89 00 00 00    	je     f0105bb5 <readline+0xd5>
				cprintf("read error: %e\n", c);
f0105b2c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b30:	c7 04 24 df 84 10 f0 	movl   $0xf01084df,(%esp)
f0105b37:	e8 91 e3 ff ff       	call   f0103ecd <cprintf>
			return NULL;
f0105b3c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b41:	eb 72                	jmp    f0105bb5 <readline+0xd5>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105b43:	83 f8 7f             	cmp    $0x7f,%eax
f0105b46:	74 05                	je     f0105b4d <readline+0x6d>
f0105b48:	83 f8 08             	cmp    $0x8,%eax
f0105b4b:	75 1a                	jne    f0105b67 <readline+0x87>
f0105b4d:	85 f6                	test   %esi,%esi
f0105b4f:	90                   	nop
f0105b50:	7e 15                	jle    f0105b67 <readline+0x87>
			if (echoing)
f0105b52:	85 ff                	test   %edi,%edi
f0105b54:	74 0c                	je     f0105b62 <readline+0x82>
				cputchar('\b');
f0105b56:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105b5d:	e8 55 ac ff ff       	call   f01007b7 <cputchar>
			i--;
f0105b62:	83 ee 01             	sub    $0x1,%esi
f0105b65:	eb ac                	jmp    f0105b13 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105b67:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105b6d:	7f 1c                	jg     f0105b8b <readline+0xab>
f0105b6f:	83 fb 1f             	cmp    $0x1f,%ebx
f0105b72:	7e 17                	jle    f0105b8b <readline+0xab>
			if (echoing)
f0105b74:	85 ff                	test   %edi,%edi
f0105b76:	74 08                	je     f0105b80 <readline+0xa0>
				cputchar(c);
f0105b78:	89 1c 24             	mov    %ebx,(%esp)
f0105b7b:	e8 37 ac ff ff       	call   f01007b7 <cputchar>
			buf[i++] = c;
f0105b80:	88 9e 80 7a 1e f0    	mov    %bl,-0xfe18580(%esi)
f0105b86:	8d 76 01             	lea    0x1(%esi),%esi
f0105b89:	eb 88                	jmp    f0105b13 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105b8b:	83 fb 0d             	cmp    $0xd,%ebx
f0105b8e:	74 09                	je     f0105b99 <readline+0xb9>
f0105b90:	83 fb 0a             	cmp    $0xa,%ebx
f0105b93:	0f 85 7a ff ff ff    	jne    f0105b13 <readline+0x33>
			if (echoing)
f0105b99:	85 ff                	test   %edi,%edi
f0105b9b:	74 0c                	je     f0105ba9 <readline+0xc9>
				cputchar('\n');
f0105b9d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105ba4:	e8 0e ac ff ff       	call   f01007b7 <cputchar>
			buf[i] = 0;
f0105ba9:	c6 86 80 7a 1e f0 00 	movb   $0x0,-0xfe18580(%esi)
			return buf;
f0105bb0:	b8 80 7a 1e f0       	mov    $0xf01e7a80,%eax
		}
	}
}
f0105bb5:	83 c4 1c             	add    $0x1c,%esp
f0105bb8:	5b                   	pop    %ebx
f0105bb9:	5e                   	pop    %esi
f0105bba:	5f                   	pop    %edi
f0105bbb:	5d                   	pop    %ebp
f0105bbc:	c3                   	ret    
f0105bbd:	66 90                	xchg   %ax,%ax
f0105bbf:	90                   	nop

f0105bc0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105bc0:	55                   	push   %ebp
f0105bc1:	89 e5                	mov    %esp,%ebp
f0105bc3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105bc6:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bcb:	eb 03                	jmp    f0105bd0 <strlen+0x10>
		n++;
f0105bcd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0105bd0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105bd4:	75 f7                	jne    f0105bcd <strlen+0xd>
	return n;
}
f0105bd6:	5d                   	pop    %ebp
f0105bd7:	c3                   	ret    

f0105bd8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105bd8:	55                   	push   %ebp
f0105bd9:	89 e5                	mov    %esp,%ebp
f0105bdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105bde:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105be1:	b8 00 00 00 00       	mov    $0x0,%eax
f0105be6:	eb 03                	jmp    f0105beb <strnlen+0x13>
		n++;
f0105be8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105beb:	39 d0                	cmp    %edx,%eax
f0105bed:	74 06                	je     f0105bf5 <strnlen+0x1d>
f0105bef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105bf3:	75 f3                	jne    f0105be8 <strnlen+0x10>
	return n;
}
f0105bf5:	5d                   	pop    %ebp
f0105bf6:	c3                   	ret    

f0105bf7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105bf7:	55                   	push   %ebp
f0105bf8:	89 e5                	mov    %esp,%ebp
f0105bfa:	53                   	push   %ebx
f0105bfb:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105c01:	89 c2                	mov    %eax,%edx
f0105c03:	83 c2 01             	add    $0x1,%edx
f0105c06:	83 c1 01             	add    $0x1,%ecx
f0105c09:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105c0d:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105c10:	84 db                	test   %bl,%bl
f0105c12:	75 ef                	jne    f0105c03 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105c14:	5b                   	pop    %ebx
f0105c15:	5d                   	pop    %ebp
f0105c16:	c3                   	ret    

f0105c17 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105c17:	55                   	push   %ebp
f0105c18:	89 e5                	mov    %esp,%ebp
f0105c1a:	53                   	push   %ebx
f0105c1b:	83 ec 08             	sub    $0x8,%esp
f0105c1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105c21:	89 1c 24             	mov    %ebx,(%esp)
f0105c24:	e8 97 ff ff ff       	call   f0105bc0 <strlen>
	strcpy(dst + len, src);
f0105c29:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105c2c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105c30:	01 d8                	add    %ebx,%eax
f0105c32:	89 04 24             	mov    %eax,(%esp)
f0105c35:	e8 bd ff ff ff       	call   f0105bf7 <strcpy>
	return dst;
}
f0105c3a:	89 d8                	mov    %ebx,%eax
f0105c3c:	83 c4 08             	add    $0x8,%esp
f0105c3f:	5b                   	pop    %ebx
f0105c40:	5d                   	pop    %ebp
f0105c41:	c3                   	ret    

f0105c42 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105c42:	55                   	push   %ebp
f0105c43:	89 e5                	mov    %esp,%ebp
f0105c45:	56                   	push   %esi
f0105c46:	53                   	push   %ebx
f0105c47:	8b 75 08             	mov    0x8(%ebp),%esi
f0105c4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105c4d:	89 f3                	mov    %esi,%ebx
f0105c4f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105c52:	89 f2                	mov    %esi,%edx
f0105c54:	eb 0f                	jmp    f0105c65 <strncpy+0x23>
		*dst++ = *src;
f0105c56:	83 c2 01             	add    $0x1,%edx
f0105c59:	0f b6 01             	movzbl (%ecx),%eax
f0105c5c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105c5f:	80 39 01             	cmpb   $0x1,(%ecx)
f0105c62:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0105c65:	39 da                	cmp    %ebx,%edx
f0105c67:	75 ed                	jne    f0105c56 <strncpy+0x14>
	}
	return ret;
}
f0105c69:	89 f0                	mov    %esi,%eax
f0105c6b:	5b                   	pop    %ebx
f0105c6c:	5e                   	pop    %esi
f0105c6d:	5d                   	pop    %ebp
f0105c6e:	c3                   	ret    

f0105c6f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105c6f:	55                   	push   %ebp
f0105c70:	89 e5                	mov    %esp,%ebp
f0105c72:	56                   	push   %esi
f0105c73:	53                   	push   %ebx
f0105c74:	8b 75 08             	mov    0x8(%ebp),%esi
f0105c77:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105c7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105c7d:	89 f0                	mov    %esi,%eax
f0105c7f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105c83:	85 c9                	test   %ecx,%ecx
f0105c85:	75 0b                	jne    f0105c92 <strlcpy+0x23>
f0105c87:	eb 1d                	jmp    f0105ca6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105c89:	83 c0 01             	add    $0x1,%eax
f0105c8c:	83 c2 01             	add    $0x1,%edx
f0105c8f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0105c92:	39 d8                	cmp    %ebx,%eax
f0105c94:	74 0b                	je     f0105ca1 <strlcpy+0x32>
f0105c96:	0f b6 0a             	movzbl (%edx),%ecx
f0105c99:	84 c9                	test   %cl,%cl
f0105c9b:	75 ec                	jne    f0105c89 <strlcpy+0x1a>
f0105c9d:	89 c2                	mov    %eax,%edx
f0105c9f:	eb 02                	jmp    f0105ca3 <strlcpy+0x34>
f0105ca1:	89 c2                	mov    %eax,%edx
		*dst = '\0';
f0105ca3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0105ca6:	29 f0                	sub    %esi,%eax
}
f0105ca8:	5b                   	pop    %ebx
f0105ca9:	5e                   	pop    %esi
f0105caa:	5d                   	pop    %ebp
f0105cab:	c3                   	ret    

f0105cac <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105cac:	55                   	push   %ebp
f0105cad:	89 e5                	mov    %esp,%ebp
f0105caf:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105cb2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105cb5:	eb 06                	jmp    f0105cbd <strcmp+0x11>
		p++, q++;
f0105cb7:	83 c1 01             	add    $0x1,%ecx
f0105cba:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0105cbd:	0f b6 01             	movzbl (%ecx),%eax
f0105cc0:	84 c0                	test   %al,%al
f0105cc2:	74 04                	je     f0105cc8 <strcmp+0x1c>
f0105cc4:	3a 02                	cmp    (%edx),%al
f0105cc6:	74 ef                	je     f0105cb7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105cc8:	0f b6 c0             	movzbl %al,%eax
f0105ccb:	0f b6 12             	movzbl (%edx),%edx
f0105cce:	29 d0                	sub    %edx,%eax
}
f0105cd0:	5d                   	pop    %ebp
f0105cd1:	c3                   	ret    

f0105cd2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105cd2:	55                   	push   %ebp
f0105cd3:	89 e5                	mov    %esp,%ebp
f0105cd5:	53                   	push   %ebx
f0105cd6:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cd9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105cdc:	89 c3                	mov    %eax,%ebx
f0105cde:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105ce1:	eb 06                	jmp    f0105ce9 <strncmp+0x17>
		n--, p++, q++;
f0105ce3:	83 c0 01             	add    $0x1,%eax
f0105ce6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105ce9:	39 d8                	cmp    %ebx,%eax
f0105ceb:	74 15                	je     f0105d02 <strncmp+0x30>
f0105ced:	0f b6 08             	movzbl (%eax),%ecx
f0105cf0:	84 c9                	test   %cl,%cl
f0105cf2:	74 04                	je     f0105cf8 <strncmp+0x26>
f0105cf4:	3a 0a                	cmp    (%edx),%cl
f0105cf6:	74 eb                	je     f0105ce3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105cf8:	0f b6 00             	movzbl (%eax),%eax
f0105cfb:	0f b6 12             	movzbl (%edx),%edx
f0105cfe:	29 d0                	sub    %edx,%eax
f0105d00:	eb 05                	jmp    f0105d07 <strncmp+0x35>
		return 0;
f0105d02:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105d07:	5b                   	pop    %ebx
f0105d08:	5d                   	pop    %ebp
f0105d09:	c3                   	ret    

f0105d0a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105d0a:	55                   	push   %ebp
f0105d0b:	89 e5                	mov    %esp,%ebp
f0105d0d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105d14:	eb 07                	jmp    f0105d1d <strchr+0x13>
		if (*s == c)
f0105d16:	38 ca                	cmp    %cl,%dl
f0105d18:	74 0f                	je     f0105d29 <strchr+0x1f>
	for (; *s; s++)
f0105d1a:	83 c0 01             	add    $0x1,%eax
f0105d1d:	0f b6 10             	movzbl (%eax),%edx
f0105d20:	84 d2                	test   %dl,%dl
f0105d22:	75 f2                	jne    f0105d16 <strchr+0xc>
			return (char *) s;
	return 0;
f0105d24:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105d29:	5d                   	pop    %ebp
f0105d2a:	c3                   	ret    

f0105d2b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105d2b:	55                   	push   %ebp
f0105d2c:	89 e5                	mov    %esp,%ebp
f0105d2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105d35:	eb 07                	jmp    f0105d3e <strfind+0x13>
		if (*s == c)
f0105d37:	38 ca                	cmp    %cl,%dl
f0105d39:	74 0a                	je     f0105d45 <strfind+0x1a>
	for (; *s; s++)
f0105d3b:	83 c0 01             	add    $0x1,%eax
f0105d3e:	0f b6 10             	movzbl (%eax),%edx
f0105d41:	84 d2                	test   %dl,%dl
f0105d43:	75 f2                	jne    f0105d37 <strfind+0xc>
			break;
	return (char *) s;
}
f0105d45:	5d                   	pop    %ebp
f0105d46:	c3                   	ret    

f0105d47 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105d47:	55                   	push   %ebp
f0105d48:	89 e5                	mov    %esp,%ebp
f0105d4a:	57                   	push   %edi
f0105d4b:	56                   	push   %esi
f0105d4c:	53                   	push   %ebx
f0105d4d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105d50:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105d53:	85 c9                	test   %ecx,%ecx
f0105d55:	74 36                	je     f0105d8d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105d57:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105d5d:	75 28                	jne    f0105d87 <memset+0x40>
f0105d5f:	f6 c1 03             	test   $0x3,%cl
f0105d62:	75 23                	jne    f0105d87 <memset+0x40>
		c &= 0xFF;
f0105d64:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105d68:	89 d3                	mov    %edx,%ebx
f0105d6a:	c1 e3 08             	shl    $0x8,%ebx
f0105d6d:	89 d6                	mov    %edx,%esi
f0105d6f:	c1 e6 18             	shl    $0x18,%esi
f0105d72:	89 d0                	mov    %edx,%eax
f0105d74:	c1 e0 10             	shl    $0x10,%eax
f0105d77:	09 f0                	or     %esi,%eax
f0105d79:	09 c2                	or     %eax,%edx
f0105d7b:	89 d0                	mov    %edx,%eax
f0105d7d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105d7f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105d82:	fc                   	cld    
f0105d83:	f3 ab                	rep stos %eax,%es:(%edi)
f0105d85:	eb 06                	jmp    f0105d8d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105d87:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105d8a:	fc                   	cld    
f0105d8b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105d8d:	89 f8                	mov    %edi,%eax
f0105d8f:	5b                   	pop    %ebx
f0105d90:	5e                   	pop    %esi
f0105d91:	5f                   	pop    %edi
f0105d92:	5d                   	pop    %ebp
f0105d93:	c3                   	ret    

f0105d94 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105d94:	55                   	push   %ebp
f0105d95:	89 e5                	mov    %esp,%ebp
f0105d97:	57                   	push   %edi
f0105d98:	56                   	push   %esi
f0105d99:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d9c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105d9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105da2:	39 c6                	cmp    %eax,%esi
f0105da4:	73 35                	jae    f0105ddb <memmove+0x47>
f0105da6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105da9:	39 d0                	cmp    %edx,%eax
f0105dab:	73 2e                	jae    f0105ddb <memmove+0x47>
		s += n;
		d += n;
f0105dad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0105db0:	89 d6                	mov    %edx,%esi
f0105db2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105db4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105dba:	75 13                	jne    f0105dcf <memmove+0x3b>
f0105dbc:	f6 c1 03             	test   $0x3,%cl
f0105dbf:	75 0e                	jne    f0105dcf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105dc1:	83 ef 04             	sub    $0x4,%edi
f0105dc4:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105dc7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105dca:	fd                   	std    
f0105dcb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105dcd:	eb 09                	jmp    f0105dd8 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105dcf:	83 ef 01             	sub    $0x1,%edi
f0105dd2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105dd5:	fd                   	std    
f0105dd6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105dd8:	fc                   	cld    
f0105dd9:	eb 1d                	jmp    f0105df8 <memmove+0x64>
f0105ddb:	89 f2                	mov    %esi,%edx
f0105ddd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105ddf:	f6 c2 03             	test   $0x3,%dl
f0105de2:	75 0f                	jne    f0105df3 <memmove+0x5f>
f0105de4:	f6 c1 03             	test   $0x3,%cl
f0105de7:	75 0a                	jne    f0105df3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105de9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105dec:	89 c7                	mov    %eax,%edi
f0105dee:	fc                   	cld    
f0105def:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105df1:	eb 05                	jmp    f0105df8 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
f0105df3:	89 c7                	mov    %eax,%edi
f0105df5:	fc                   	cld    
f0105df6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105df8:	5e                   	pop    %esi
f0105df9:	5f                   	pop    %edi
f0105dfa:	5d                   	pop    %ebp
f0105dfb:	c3                   	ret    

f0105dfc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105dfc:	55                   	push   %ebp
f0105dfd:	89 e5                	mov    %esp,%ebp
f0105dff:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105e02:	8b 45 10             	mov    0x10(%ebp),%eax
f0105e05:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105e09:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105e0c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105e10:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e13:	89 04 24             	mov    %eax,(%esp)
f0105e16:	e8 79 ff ff ff       	call   f0105d94 <memmove>
}
f0105e1b:	c9                   	leave  
f0105e1c:	c3                   	ret    

f0105e1d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105e1d:	55                   	push   %ebp
f0105e1e:	89 e5                	mov    %esp,%ebp
f0105e20:	56                   	push   %esi
f0105e21:	53                   	push   %ebx
f0105e22:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105e28:	89 d6                	mov    %edx,%esi
f0105e2a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105e2d:	eb 1a                	jmp    f0105e49 <memcmp+0x2c>
		if (*s1 != *s2)
f0105e2f:	0f b6 02             	movzbl (%edx),%eax
f0105e32:	0f b6 19             	movzbl (%ecx),%ebx
f0105e35:	38 d8                	cmp    %bl,%al
f0105e37:	74 0a                	je     f0105e43 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105e39:	0f b6 c0             	movzbl %al,%eax
f0105e3c:	0f b6 db             	movzbl %bl,%ebx
f0105e3f:	29 d8                	sub    %ebx,%eax
f0105e41:	eb 0f                	jmp    f0105e52 <memcmp+0x35>
		s1++, s2++;
f0105e43:	83 c2 01             	add    $0x1,%edx
f0105e46:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
f0105e49:	39 f2                	cmp    %esi,%edx
f0105e4b:	75 e2                	jne    f0105e2f <memcmp+0x12>
	}

	return 0;
f0105e4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105e52:	5b                   	pop    %ebx
f0105e53:	5e                   	pop    %esi
f0105e54:	5d                   	pop    %ebp
f0105e55:	c3                   	ret    

f0105e56 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105e56:	55                   	push   %ebp
f0105e57:	89 e5                	mov    %esp,%ebp
f0105e59:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105e5f:	89 c2                	mov    %eax,%edx
f0105e61:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105e64:	eb 07                	jmp    f0105e6d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105e66:	38 08                	cmp    %cl,(%eax)
f0105e68:	74 07                	je     f0105e71 <memfind+0x1b>
	for (; s < ends; s++)
f0105e6a:	83 c0 01             	add    $0x1,%eax
f0105e6d:	39 d0                	cmp    %edx,%eax
f0105e6f:	72 f5                	jb     f0105e66 <memfind+0x10>
			break;
	return (void *) s;
}
f0105e71:	5d                   	pop    %ebp
f0105e72:	c3                   	ret    

f0105e73 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105e73:	55                   	push   %ebp
f0105e74:	89 e5                	mov    %esp,%ebp
f0105e76:	57                   	push   %edi
f0105e77:	56                   	push   %esi
f0105e78:	53                   	push   %ebx
f0105e79:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e7c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105e7f:	eb 03                	jmp    f0105e84 <strtol+0x11>
		s++;
f0105e81:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f0105e84:	0f b6 0a             	movzbl (%edx),%ecx
f0105e87:	80 f9 09             	cmp    $0x9,%cl
f0105e8a:	74 f5                	je     f0105e81 <strtol+0xe>
f0105e8c:	80 f9 20             	cmp    $0x20,%cl
f0105e8f:	74 f0                	je     f0105e81 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0105e91:	80 f9 2b             	cmp    $0x2b,%cl
f0105e94:	75 0a                	jne    f0105ea0 <strtol+0x2d>
		s++;
f0105e96:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0105e99:	bf 00 00 00 00       	mov    $0x0,%edi
f0105e9e:	eb 11                	jmp    f0105eb1 <strtol+0x3e>
f0105ea0:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
f0105ea5:	80 f9 2d             	cmp    $0x2d,%cl
f0105ea8:	75 07                	jne    f0105eb1 <strtol+0x3e>
		s++, neg = 1;
f0105eaa:	8d 52 01             	lea    0x1(%edx),%edx
f0105ead:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105eb1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0105eb6:	75 15                	jne    f0105ecd <strtol+0x5a>
f0105eb8:	80 3a 30             	cmpb   $0x30,(%edx)
f0105ebb:	75 10                	jne    f0105ecd <strtol+0x5a>
f0105ebd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105ec1:	75 0a                	jne    f0105ecd <strtol+0x5a>
		s += 2, base = 16;
f0105ec3:	83 c2 02             	add    $0x2,%edx
f0105ec6:	b8 10 00 00 00       	mov    $0x10,%eax
f0105ecb:	eb 10                	jmp    f0105edd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f0105ecd:	85 c0                	test   %eax,%eax
f0105ecf:	75 0c                	jne    f0105edd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105ed1:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
f0105ed3:	80 3a 30             	cmpb   $0x30,(%edx)
f0105ed6:	75 05                	jne    f0105edd <strtol+0x6a>
		s++, base = 8;
f0105ed8:	83 c2 01             	add    $0x1,%edx
f0105edb:	b0 08                	mov    $0x8,%al
		base = 10;
f0105edd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105ee2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105ee5:	0f b6 0a             	movzbl (%edx),%ecx
f0105ee8:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0105eeb:	89 f0                	mov    %esi,%eax
f0105eed:	3c 09                	cmp    $0x9,%al
f0105eef:	77 08                	ja     f0105ef9 <strtol+0x86>
			dig = *s - '0';
f0105ef1:	0f be c9             	movsbl %cl,%ecx
f0105ef4:	83 e9 30             	sub    $0x30,%ecx
f0105ef7:	eb 20                	jmp    f0105f19 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0105ef9:	8d 71 9f             	lea    -0x61(%ecx),%esi
f0105efc:	89 f0                	mov    %esi,%eax
f0105efe:	3c 19                	cmp    $0x19,%al
f0105f00:	77 08                	ja     f0105f0a <strtol+0x97>
			dig = *s - 'a' + 10;
f0105f02:	0f be c9             	movsbl %cl,%ecx
f0105f05:	83 e9 57             	sub    $0x57,%ecx
f0105f08:	eb 0f                	jmp    f0105f19 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f0105f0a:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0105f0d:	89 f0                	mov    %esi,%eax
f0105f0f:	3c 19                	cmp    $0x19,%al
f0105f11:	77 16                	ja     f0105f29 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0105f13:	0f be c9             	movsbl %cl,%ecx
f0105f16:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0105f19:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0105f1c:	7d 0f                	jge    f0105f2d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f0105f1e:	83 c2 01             	add    $0x1,%edx
f0105f21:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0105f25:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0105f27:	eb bc                	jmp    f0105ee5 <strtol+0x72>
f0105f29:	89 d8                	mov    %ebx,%eax
f0105f2b:	eb 02                	jmp    f0105f2f <strtol+0xbc>
f0105f2d:	89 d8                	mov    %ebx,%eax

	if (endptr)
f0105f2f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105f33:	74 05                	je     f0105f3a <strtol+0xc7>
		*endptr = (char *) s;
f0105f35:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105f38:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0105f3a:	f7 d8                	neg    %eax
f0105f3c:	85 ff                	test   %edi,%edi
f0105f3e:	0f 44 c3             	cmove  %ebx,%eax
}
f0105f41:	5b                   	pop    %ebx
f0105f42:	5e                   	pop    %esi
f0105f43:	5f                   	pop    %edi
f0105f44:	5d                   	pop    %ebp
f0105f45:	c3                   	ret    
f0105f46:	66 90                	xchg   %ax,%ax

f0105f48 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105f48:	fa                   	cli    

	xorw    %ax, %ax
f0105f49:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105f4b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105f4d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105f4f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105f51:	0f 01 16             	lgdtl  (%esi)
f0105f54:	74 70                	je     f0105fc6 <mpentry_end+0x4>
	movl    %cr0, %eax
f0105f56:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105f59:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105f5d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105f60:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105f66:	08 00                	or     %al,(%eax)

f0105f68 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105f68:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105f6c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105f6e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105f70:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105f72:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105f76:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105f78:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105f7a:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f0105f7f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105f82:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105f85:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105f8a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105f8d:	8b 25 84 7e 1e f0    	mov    0xf01e7e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105f93:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105f98:	b8 e7 01 10 f0       	mov    $0xf01001e7,%eax
	call    *%eax
f0105f9d:	ff d0                	call   *%eax

f0105f9f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105f9f:	eb fe                	jmp    f0105f9f <spin>
f0105fa1:	8d 76 00             	lea    0x0(%esi),%esi

f0105fa4 <gdt>:
	...
f0105fac:	ff                   	(bad)  
f0105fad:	ff 00                	incl   (%eax)
f0105faf:	00 00                	add    %al,(%eax)
f0105fb1:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105fb8:	00                   	.byte 0x0
f0105fb9:	92                   	xchg   %eax,%edx
f0105fba:	cf                   	iret   
	...

f0105fbc <gdtdesc>:
f0105fbc:	17                   	pop    %ss
f0105fbd:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105fc2 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105fc2:	90                   	nop
f0105fc3:	66 90                	xchg   %ax,%ax
f0105fc5:	66 90                	xchg   %ax,%ax
f0105fc7:	66 90                	xchg   %ax,%ax
f0105fc9:	66 90                	xchg   %ax,%ax
f0105fcb:	66 90                	xchg   %ax,%ax
f0105fcd:	66 90                	xchg   %ax,%ax
f0105fcf:	90                   	nop

f0105fd0 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105fd0:	55                   	push   %ebp
f0105fd1:	89 e5                	mov    %esp,%ebp
f0105fd3:	56                   	push   %esi
f0105fd4:	53                   	push   %ebx
f0105fd5:	83 ec 10             	sub    $0x10,%esp
	if (PGNUM(pa) >= npages)
f0105fd8:	8b 0d 88 7e 1e f0    	mov    0xf01e7e88,%ecx
f0105fde:	89 c3                	mov    %eax,%ebx
f0105fe0:	c1 eb 0c             	shr    $0xc,%ebx
f0105fe3:	39 cb                	cmp    %ecx,%ebx
f0105fe5:	72 20                	jb     f0106007 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105fe7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105feb:	c7 44 24 08 a4 6a 10 	movl   $0xf0106aa4,0x8(%esp)
f0105ff2:	f0 
f0105ff3:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0105ffa:	00 
f0105ffb:	c7 04 24 7d 86 10 f0 	movl   $0xf010867d,(%esp)
f0106002:	e8 39 a0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106007:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010600d:	01 d0                	add    %edx,%eax
	if (PGNUM(pa) >= npages)
f010600f:	89 c2                	mov    %eax,%edx
f0106011:	c1 ea 0c             	shr    $0xc,%edx
f0106014:	39 d1                	cmp    %edx,%ecx
f0106016:	77 20                	ja     f0106038 <mpsearch1+0x68>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106018:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010601c:	c7 44 24 08 a4 6a 10 	movl   $0xf0106aa4,0x8(%esp)
f0106023:	f0 
f0106024:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010602b:	00 
f010602c:	c7 04 24 7d 86 10 f0 	movl   $0xf010867d,(%esp)
f0106033:	e8 08 a0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106038:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f010603e:	eb 36                	jmp    f0106076 <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106040:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106047:	00 
f0106048:	c7 44 24 04 8d 86 10 	movl   $0xf010868d,0x4(%esp)
f010604f:	f0 
f0106050:	89 1c 24             	mov    %ebx,(%esp)
f0106053:	e8 c5 fd ff ff       	call   f0105e1d <memcmp>
f0106058:	85 c0                	test   %eax,%eax
f010605a:	75 17                	jne    f0106073 <mpsearch1+0xa3>
	for (i = 0; i < len; i++)
f010605c:	ba 00 00 00 00       	mov    $0x0,%edx
		sum += ((uint8_t *)addr)[i];
f0106061:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0106065:	01 c8                	add    %ecx,%eax
	for (i = 0; i < len; i++)
f0106067:	83 c2 01             	add    $0x1,%edx
f010606a:	83 fa 10             	cmp    $0x10,%edx
f010606d:	75 f2                	jne    f0106061 <mpsearch1+0x91>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010606f:	84 c0                	test   %al,%al
f0106071:	74 0e                	je     f0106081 <mpsearch1+0xb1>
	for (; mp < end; mp++)
f0106073:	83 c3 10             	add    $0x10,%ebx
f0106076:	39 f3                	cmp    %esi,%ebx
f0106078:	72 c6                	jb     f0106040 <mpsearch1+0x70>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010607a:	b8 00 00 00 00       	mov    $0x0,%eax
f010607f:	eb 02                	jmp    f0106083 <mpsearch1+0xb3>
f0106081:	89 d8                	mov    %ebx,%eax
}
f0106083:	83 c4 10             	add    $0x10,%esp
f0106086:	5b                   	pop    %ebx
f0106087:	5e                   	pop    %esi
f0106088:	5d                   	pop    %ebp
f0106089:	c3                   	ret    

f010608a <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010608a:	55                   	push   %ebp
f010608b:	89 e5                	mov    %esp,%ebp
f010608d:	57                   	push   %edi
f010608e:	56                   	push   %esi
f010608f:	53                   	push   %ebx
f0106090:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106093:	c7 05 c0 83 1e f0 20 	movl   $0xf01e8020,0xf01e83c0
f010609a:	80 1e f0 
	if (PGNUM(pa) >= npages)
f010609d:	83 3d 88 7e 1e f0 00 	cmpl   $0x0,0xf01e7e88
f01060a4:	75 24                	jne    f01060ca <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01060a6:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f01060ad:	00 
f01060ae:	c7 44 24 08 a4 6a 10 	movl   $0xf0106aa4,0x8(%esp)
f01060b5:	f0 
f01060b6:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f01060bd:	00 
f01060be:	c7 04 24 7d 86 10 f0 	movl   $0xf010867d,(%esp)
f01060c5:	e8 76 9f ff ff       	call   f0100040 <_panic>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01060ca:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01060d1:	85 c0                	test   %eax,%eax
f01060d3:	74 16                	je     f01060eb <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f01060d5:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f01060d8:	ba 00 04 00 00       	mov    $0x400,%edx
f01060dd:	e8 ee fe ff ff       	call   f0105fd0 <mpsearch1>
f01060e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01060e5:	85 c0                	test   %eax,%eax
f01060e7:	75 3c                	jne    f0106125 <mp_init+0x9b>
f01060e9:	eb 20                	jmp    f010610b <mp_init+0x81>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f01060eb:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01060f2:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01060f5:	2d 00 04 00 00       	sub    $0x400,%eax
f01060fa:	ba 00 04 00 00       	mov    $0x400,%edx
f01060ff:	e8 cc fe ff ff       	call   f0105fd0 <mpsearch1>
f0106104:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106107:	85 c0                	test   %eax,%eax
f0106109:	75 1a                	jne    f0106125 <mp_init+0x9b>
	return mpsearch1(0xF0000, 0x10000);
f010610b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106110:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0106115:	e8 b6 fe ff ff       	call   f0105fd0 <mpsearch1>
f010611a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f010611d:	85 c0                	test   %eax,%eax
f010611f:	0f 84 54 02 00 00    	je     f0106379 <mp_init+0x2ef>
	if (mp->physaddr == 0 || mp->type != 0) {
f0106125:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106128:	8b 70 04             	mov    0x4(%eax),%esi
f010612b:	85 f6                	test   %esi,%esi
f010612d:	74 06                	je     f0106135 <mp_init+0xab>
f010612f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106133:	74 11                	je     f0106146 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0106135:	c7 04 24 f0 84 10 f0 	movl   $0xf01084f0,(%esp)
f010613c:	e8 8c dd ff ff       	call   f0103ecd <cprintf>
f0106141:	e9 33 02 00 00       	jmp    f0106379 <mp_init+0x2ef>
	if (PGNUM(pa) >= npages)
f0106146:	89 f0                	mov    %esi,%eax
f0106148:	c1 e8 0c             	shr    $0xc,%eax
f010614b:	3b 05 88 7e 1e f0    	cmp    0xf01e7e88,%eax
f0106151:	72 20                	jb     f0106173 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106153:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106157:	c7 44 24 08 a4 6a 10 	movl   $0xf0106aa4,0x8(%esp)
f010615e:	f0 
f010615f:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106166:	00 
f0106167:	c7 04 24 7d 86 10 f0 	movl   $0xf010867d,(%esp)
f010616e:	e8 cd 9e ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106173:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106179:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106180:	00 
f0106181:	c7 44 24 04 92 86 10 	movl   $0xf0108692,0x4(%esp)
f0106188:	f0 
f0106189:	89 1c 24             	mov    %ebx,(%esp)
f010618c:	e8 8c fc ff ff       	call   f0105e1d <memcmp>
f0106191:	85 c0                	test   %eax,%eax
f0106193:	74 11                	je     f01061a6 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106195:	c7 04 24 20 85 10 f0 	movl   $0xf0108520,(%esp)
f010619c:	e8 2c dd ff ff       	call   f0103ecd <cprintf>
f01061a1:	e9 d3 01 00 00       	jmp    f0106379 <mp_init+0x2ef>
	if (sum(conf, conf->length) != 0) {
f01061a6:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f01061aa:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f01061ae:	0f b7 f8             	movzwl %ax,%edi
	sum = 0;
f01061b1:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01061b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01061bb:	eb 0d                	jmp    f01061ca <mp_init+0x140>
		sum += ((uint8_t *)addr)[i];
f01061bd:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f01061c4:	f0 
f01061c5:	01 ca                	add    %ecx,%edx
	for (i = 0; i < len; i++)
f01061c7:	83 c0 01             	add    $0x1,%eax
f01061ca:	39 c7                	cmp    %eax,%edi
f01061cc:	7f ef                	jg     f01061bd <mp_init+0x133>
	if (sum(conf, conf->length) != 0) {
f01061ce:	84 d2                	test   %dl,%dl
f01061d0:	74 11                	je     f01061e3 <mp_init+0x159>
		cprintf("SMP: Bad MP configuration checksum\n");
f01061d2:	c7 04 24 54 85 10 f0 	movl   $0xf0108554,(%esp)
f01061d9:	e8 ef dc ff ff       	call   f0103ecd <cprintf>
f01061de:	e9 96 01 00 00       	jmp    f0106379 <mp_init+0x2ef>
	if (conf->version != 1 && conf->version != 4) {
f01061e3:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f01061e7:	3c 04                	cmp    $0x4,%al
f01061e9:	74 1f                	je     f010620a <mp_init+0x180>
f01061eb:	3c 01                	cmp    $0x1,%al
f01061ed:	8d 76 00             	lea    0x0(%esi),%esi
f01061f0:	74 18                	je     f010620a <mp_init+0x180>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01061f2:	0f b6 c0             	movzbl %al,%eax
f01061f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061f9:	c7 04 24 78 85 10 f0 	movl   $0xf0108578,(%esp)
f0106200:	e8 c8 dc ff ff       	call   f0103ecd <cprintf>
f0106205:	e9 6f 01 00 00       	jmp    f0106379 <mp_init+0x2ef>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010620a:	0f b7 73 28          	movzwl 0x28(%ebx),%esi
f010620e:	0f b7 7d e2          	movzwl -0x1e(%ebp),%edi
f0106212:	01 df                	add    %ebx,%edi
	sum = 0;
f0106214:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106219:	b8 00 00 00 00       	mov    $0x0,%eax
f010621e:	eb 09                	jmp    f0106229 <mp_init+0x19f>
		sum += ((uint8_t *)addr)[i];
f0106220:	0f b6 0c 07          	movzbl (%edi,%eax,1),%ecx
f0106224:	01 ca                	add    %ecx,%edx
	for (i = 0; i < len; i++)
f0106226:	83 c0 01             	add    $0x1,%eax
f0106229:	39 c6                	cmp    %eax,%esi
f010622b:	7f f3                	jg     f0106220 <mp_init+0x196>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010622d:	02 53 2a             	add    0x2a(%ebx),%dl
f0106230:	84 d2                	test   %dl,%dl
f0106232:	74 11                	je     f0106245 <mp_init+0x1bb>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106234:	c7 04 24 98 85 10 f0 	movl   $0xf0108598,(%esp)
f010623b:	e8 8d dc ff ff       	call   f0103ecd <cprintf>
f0106240:	e9 34 01 00 00       	jmp    f0106379 <mp_init+0x2ef>
	if ((conf = mpconfig(&mp)) == 0)
f0106245:	85 db                	test   %ebx,%ebx
f0106247:	0f 84 2c 01 00 00    	je     f0106379 <mp_init+0x2ef>
		return;
	ismp = 1;
f010624d:	c7 05 00 80 1e f0 01 	movl   $0x1,0xf01e8000
f0106254:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106257:	8b 43 24             	mov    0x24(%ebx),%eax
f010625a:	a3 00 90 22 f0       	mov    %eax,0xf0229000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010625f:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0106262:	be 00 00 00 00       	mov    $0x0,%esi
f0106267:	e9 86 00 00 00       	jmp    f01062f2 <mp_init+0x268>
		switch (*p) {
f010626c:	0f b6 07             	movzbl (%edi),%eax
f010626f:	84 c0                	test   %al,%al
f0106271:	74 06                	je     f0106279 <mp_init+0x1ef>
f0106273:	3c 04                	cmp    $0x4,%al
f0106275:	77 57                	ja     f01062ce <mp_init+0x244>
f0106277:	eb 50                	jmp    f01062c9 <mp_init+0x23f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106279:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f010627d:	8d 76 00             	lea    0x0(%esi),%esi
f0106280:	74 11                	je     f0106293 <mp_init+0x209>
				bootcpu = &cpus[ncpu];
f0106282:	6b 05 c4 83 1e f0 74 	imul   $0x74,0xf01e83c4,%eax
f0106289:	05 20 80 1e f0       	add    $0xf01e8020,%eax
f010628e:	a3 c0 83 1e f0       	mov    %eax,0xf01e83c0
			if (ncpu < NCPU) {
f0106293:	a1 c4 83 1e f0       	mov    0xf01e83c4,%eax
f0106298:	83 f8 07             	cmp    $0x7,%eax
f010629b:	7f 13                	jg     f01062b0 <mp_init+0x226>
				cpus[ncpu].cpu_id = ncpu;
f010629d:	6b d0 74             	imul   $0x74,%eax,%edx
f01062a0:	88 82 20 80 1e f0    	mov    %al,-0xfe17fe0(%edx)
				ncpu++;
f01062a6:	83 c0 01             	add    $0x1,%eax
f01062a9:	a3 c4 83 1e f0       	mov    %eax,0xf01e83c4
f01062ae:	eb 14                	jmp    f01062c4 <mp_init+0x23a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01062b0:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f01062b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01062b8:	c7 04 24 c8 85 10 f0 	movl   $0xf01085c8,(%esp)
f01062bf:	e8 09 dc ff ff       	call   f0103ecd <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01062c4:	83 c7 14             	add    $0x14,%edi
			continue;
f01062c7:	eb 26                	jmp    f01062ef <mp_init+0x265>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01062c9:	83 c7 08             	add    $0x8,%edi
			continue;
f01062cc:	eb 21                	jmp    f01062ef <mp_init+0x265>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01062ce:	0f b6 c0             	movzbl %al,%eax
f01062d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01062d5:	c7 04 24 f0 85 10 f0 	movl   $0xf01085f0,(%esp)
f01062dc:	e8 ec db ff ff       	call   f0103ecd <cprintf>
			ismp = 0;
f01062e1:	c7 05 00 80 1e f0 00 	movl   $0x0,0xf01e8000
f01062e8:	00 00 00 
			i = conf->entry;
f01062eb:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01062ef:	83 c6 01             	add    $0x1,%esi
f01062f2:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01062f6:	39 c6                	cmp    %eax,%esi
f01062f8:	0f 82 6e ff ff ff    	jb     f010626c <mp_init+0x1e2>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01062fe:	a1 c0 83 1e f0       	mov    0xf01e83c0,%eax
f0106303:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010630a:	83 3d 00 80 1e f0 00 	cmpl   $0x0,0xf01e8000
f0106311:	75 22                	jne    f0106335 <mp_init+0x2ab>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106313:	c7 05 c4 83 1e f0 01 	movl   $0x1,0xf01e83c4
f010631a:	00 00 00 
		lapicaddr = 0;
f010631d:	c7 05 00 90 22 f0 00 	movl   $0x0,0xf0229000
f0106324:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106327:	c7 04 24 10 86 10 f0 	movl   $0xf0108610,(%esp)
f010632e:	e8 9a db ff ff       	call   f0103ecd <cprintf>
		return;
f0106333:	eb 44                	jmp    f0106379 <mp_init+0x2ef>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106335:	8b 15 c4 83 1e f0    	mov    0xf01e83c4,%edx
f010633b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010633f:	0f b6 00             	movzbl (%eax),%eax
f0106342:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106346:	c7 04 24 97 86 10 f0 	movl   $0xf0108697,(%esp)
f010634d:	e8 7b db ff ff       	call   f0103ecd <cprintf>

	if (mp->imcrp) {
f0106352:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106355:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106359:	74 1e                	je     f0106379 <mp_init+0x2ef>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010635b:	c7 04 24 3c 86 10 f0 	movl   $0xf010863c,(%esp)
f0106362:	e8 66 db ff ff       	call   f0103ecd <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106367:	ba 22 00 00 00       	mov    $0x22,%edx
f010636c:	b8 70 00 00 00       	mov    $0x70,%eax
f0106371:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106372:	b2 23                	mov    $0x23,%dl
f0106374:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106375:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106378:	ee                   	out    %al,(%dx)
	}
}
f0106379:	83 c4 2c             	add    $0x2c,%esp
f010637c:	5b                   	pop    %ebx
f010637d:	5e                   	pop    %esi
f010637e:	5f                   	pop    %edi
f010637f:	5d                   	pop    %ebp
f0106380:	c3                   	ret    

f0106381 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106381:	55                   	push   %ebp
f0106382:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106384:	8b 0d 04 90 22 f0    	mov    0xf0229004,%ecx
f010638a:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010638d:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010638f:	a1 04 90 22 f0       	mov    0xf0229004,%eax
f0106394:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106397:	5d                   	pop    %ebp
f0106398:	c3                   	ret    

f0106399 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106399:	55                   	push   %ebp
f010639a:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010639c:	a1 04 90 22 f0       	mov    0xf0229004,%eax
f01063a1:	85 c0                	test   %eax,%eax
f01063a3:	74 08                	je     f01063ad <cpunum+0x14>
		return lapic[ID] >> 24;
f01063a5:	8b 40 20             	mov    0x20(%eax),%eax
f01063a8:	c1 e8 18             	shr    $0x18,%eax
f01063ab:	eb 05                	jmp    f01063b2 <cpunum+0x19>
	return 0;
f01063ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01063b2:	5d                   	pop    %ebp
f01063b3:	c3                   	ret    

f01063b4 <lapic_init>:
	if (!lapicaddr)
f01063b4:	a1 00 90 22 f0       	mov    0xf0229000,%eax
f01063b9:	85 c0                	test   %eax,%eax
f01063bb:	0f 84 23 01 00 00    	je     f01064e4 <lapic_init+0x130>
{
f01063c1:	55                   	push   %ebp
f01063c2:	89 e5                	mov    %esp,%ebp
f01063c4:	83 ec 18             	sub    $0x18,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f01063c7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01063ce:	00 
f01063cf:	89 04 24             	mov    %eax,(%esp)
f01063d2:	e8 e3 b0 ff ff       	call   f01014ba <mmio_map_region>
f01063d7:	a3 04 90 22 f0       	mov    %eax,0xf0229004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01063dc:	ba 27 01 00 00       	mov    $0x127,%edx
f01063e1:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01063e6:	e8 96 ff ff ff       	call   f0106381 <lapicw>
	lapicw(TDCR, X1);
f01063eb:	ba 0b 00 00 00       	mov    $0xb,%edx
f01063f0:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01063f5:	e8 87 ff ff ff       	call   f0106381 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01063fa:	ba 20 00 02 00       	mov    $0x20020,%edx
f01063ff:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106404:	e8 78 ff ff ff       	call   f0106381 <lapicw>
	lapicw(TICR, 10000000); 
f0106409:	ba 80 96 98 00       	mov    $0x989680,%edx
f010640e:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106413:	e8 69 ff ff ff       	call   f0106381 <lapicw>
	if (thiscpu != bootcpu)
f0106418:	e8 7c ff ff ff       	call   f0106399 <cpunum>
f010641d:	6b c0 74             	imul   $0x74,%eax,%eax
f0106420:	05 20 80 1e f0       	add    $0xf01e8020,%eax
f0106425:	39 05 c0 83 1e f0    	cmp    %eax,0xf01e83c0
f010642b:	74 0f                	je     f010643c <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f010642d:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106432:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106437:	e8 45 ff ff ff       	call   f0106381 <lapicw>
	lapicw(LINT1, MASKED);
f010643c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106441:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106446:	e8 36 ff ff ff       	call   f0106381 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010644b:	a1 04 90 22 f0       	mov    0xf0229004,%eax
f0106450:	8b 40 30             	mov    0x30(%eax),%eax
f0106453:	c1 e8 10             	shr    $0x10,%eax
f0106456:	3c 03                	cmp    $0x3,%al
f0106458:	76 0f                	jbe    f0106469 <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f010645a:	ba 00 00 01 00       	mov    $0x10000,%edx
f010645f:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106464:	e8 18 ff ff ff       	call   f0106381 <lapicw>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106469:	ba 33 00 00 00       	mov    $0x33,%edx
f010646e:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106473:	e8 09 ff ff ff       	call   f0106381 <lapicw>
	lapicw(ESR, 0);
f0106478:	ba 00 00 00 00       	mov    $0x0,%edx
f010647d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106482:	e8 fa fe ff ff       	call   f0106381 <lapicw>
	lapicw(ESR, 0);
f0106487:	ba 00 00 00 00       	mov    $0x0,%edx
f010648c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106491:	e8 eb fe ff ff       	call   f0106381 <lapicw>
	lapicw(EOI, 0);
f0106496:	ba 00 00 00 00       	mov    $0x0,%edx
f010649b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01064a0:	e8 dc fe ff ff       	call   f0106381 <lapicw>
	lapicw(ICRHI, 0);
f01064a5:	ba 00 00 00 00       	mov    $0x0,%edx
f01064aa:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01064af:	e8 cd fe ff ff       	call   f0106381 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01064b4:	ba 00 85 08 00       	mov    $0x88500,%edx
f01064b9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01064be:	e8 be fe ff ff       	call   f0106381 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01064c3:	8b 15 04 90 22 f0    	mov    0xf0229004,%edx
f01064c9:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01064cf:	f6 c4 10             	test   $0x10,%ah
f01064d2:	75 f5                	jne    f01064c9 <lapic_init+0x115>
	lapicw(TPR, 0);
f01064d4:	ba 00 00 00 00       	mov    $0x0,%edx
f01064d9:	b8 20 00 00 00       	mov    $0x20,%eax
f01064de:	e8 9e fe ff ff       	call   f0106381 <lapicw>
}
f01064e3:	c9                   	leave  
f01064e4:	f3 c3                	repz ret 

f01064e6 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f01064e6:	83 3d 04 90 22 f0 00 	cmpl   $0x0,0xf0229004
f01064ed:	74 13                	je     f0106502 <lapic_eoi+0x1c>
{
f01064ef:	55                   	push   %ebp
f01064f0:	89 e5                	mov    %esp,%ebp
		lapicw(EOI, 0);
f01064f2:	ba 00 00 00 00       	mov    $0x0,%edx
f01064f7:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01064fc:	e8 80 fe ff ff       	call   f0106381 <lapicw>
}
f0106501:	5d                   	pop    %ebp
f0106502:	f3 c3                	repz ret 

f0106504 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106504:	55                   	push   %ebp
f0106505:	89 e5                	mov    %esp,%ebp
f0106507:	56                   	push   %esi
f0106508:	53                   	push   %ebx
f0106509:	83 ec 10             	sub    $0x10,%esp
f010650c:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010650f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106512:	ba 70 00 00 00       	mov    $0x70,%edx
f0106517:	b8 0f 00 00 00       	mov    $0xf,%eax
f010651c:	ee                   	out    %al,(%dx)
f010651d:	b2 71                	mov    $0x71,%dl
f010651f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106524:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0106525:	83 3d 88 7e 1e f0 00 	cmpl   $0x0,0xf01e7e88
f010652c:	75 24                	jne    f0106552 <lapic_startap+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010652e:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0106535:	00 
f0106536:	c7 44 24 08 a4 6a 10 	movl   $0xf0106aa4,0x8(%esp)
f010653d:	f0 
f010653e:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0106545:	00 
f0106546:	c7 04 24 b4 86 10 f0 	movl   $0xf01086b4,(%esp)
f010654d:	e8 ee 9a ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106552:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106559:	00 00 
	wrv[1] = addr >> 4;
f010655b:	89 f0                	mov    %esi,%eax
f010655d:	c1 e8 04             	shr    $0x4,%eax
f0106560:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106566:	c1 e3 18             	shl    $0x18,%ebx
f0106569:	89 da                	mov    %ebx,%edx
f010656b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106570:	e8 0c fe ff ff       	call   f0106381 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106575:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010657a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010657f:	e8 fd fd ff ff       	call   f0106381 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106584:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106589:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010658e:	e8 ee fd ff ff       	call   f0106381 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106593:	c1 ee 0c             	shr    $0xc,%esi
f0106596:	81 ce 00 06 00 00    	or     $0x600,%esi
		lapicw(ICRHI, apicid << 24);
f010659c:	89 da                	mov    %ebx,%edx
f010659e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01065a3:	e8 d9 fd ff ff       	call   f0106381 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01065a8:	89 f2                	mov    %esi,%edx
f01065aa:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01065af:	e8 cd fd ff ff       	call   f0106381 <lapicw>
		lapicw(ICRHI, apicid << 24);
f01065b4:	89 da                	mov    %ebx,%edx
f01065b6:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01065bb:	e8 c1 fd ff ff       	call   f0106381 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01065c0:	89 f2                	mov    %esi,%edx
f01065c2:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01065c7:	e8 b5 fd ff ff       	call   f0106381 <lapicw>
		microdelay(200);
	}
}
f01065cc:	83 c4 10             	add    $0x10,%esp
f01065cf:	5b                   	pop    %ebx
f01065d0:	5e                   	pop    %esi
f01065d1:	5d                   	pop    %ebp
f01065d2:	c3                   	ret    

f01065d3 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01065d3:	55                   	push   %ebp
f01065d4:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01065d6:	8b 55 08             	mov    0x8(%ebp),%edx
f01065d9:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01065df:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01065e4:	e8 98 fd ff ff       	call   f0106381 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01065e9:	8b 15 04 90 22 f0    	mov    0xf0229004,%edx
f01065ef:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01065f5:	f6 c4 10             	test   $0x10,%ah
f01065f8:	75 f5                	jne    f01065ef <lapic_ipi+0x1c>
		;
}
f01065fa:	5d                   	pop    %ebp
f01065fb:	c3                   	ret    

f01065fc <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01065fc:	55                   	push   %ebp
f01065fd:	89 e5                	mov    %esp,%ebp
f01065ff:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106602:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106608:	8b 55 0c             	mov    0xc(%ebp),%edx
f010660b:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010660e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106615:	5d                   	pop    %ebp
f0106616:	c3                   	ret    

f0106617 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106617:	55                   	push   %ebp
f0106618:	89 e5                	mov    %esp,%ebp
f010661a:	56                   	push   %esi
f010661b:	53                   	push   %ebx
f010661c:	83 ec 20             	sub    $0x20,%esp
f010661f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0106622:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106625:	75 07                	jne    f010662e <spin_lock+0x17>
	asm volatile("lock; xchgl %0, %1"
f0106627:	ba 01 00 00 00       	mov    $0x1,%edx
f010662c:	eb 42                	jmp    f0106670 <spin_lock+0x59>
f010662e:	8b 73 08             	mov    0x8(%ebx),%esi
f0106631:	e8 63 fd ff ff       	call   f0106399 <cpunum>
f0106636:	6b c0 74             	imul   $0x74,%eax,%eax
f0106639:	05 20 80 1e f0       	add    $0xf01e8020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010663e:	39 c6                	cmp    %eax,%esi
f0106640:	75 e5                	jne    f0106627 <spin_lock+0x10>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106642:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106645:	e8 4f fd ff ff       	call   f0106399 <cpunum>
f010664a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f010664e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106652:	c7 44 24 08 c4 86 10 	movl   $0xf01086c4,0x8(%esp)
f0106659:	f0 
f010665a:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106661:	00 
f0106662:	c7 04 24 28 87 10 f0 	movl   $0xf0108728,(%esp)
f0106669:	e8 d2 99 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010666e:	f3 90                	pause  
f0106670:	89 d0                	mov    %edx,%eax
f0106672:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0106675:	85 c0                	test   %eax,%eax
f0106677:	75 f5                	jne    f010666e <spin_lock+0x57>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106679:	e8 1b fd ff ff       	call   f0106399 <cpunum>
f010667e:	6b c0 74             	imul   $0x74,%eax,%eax
f0106681:	05 20 80 1e f0       	add    $0xf01e8020,%eax
f0106686:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106689:	83 c3 0c             	add    $0xc,%ebx
	ebp = (uint32_t *)read_ebp();
f010668c:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f010668e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106693:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106699:	76 12                	jbe    f01066ad <spin_lock+0x96>
		pcs[i] = ebp[1];          // saved %eip
f010669b:	8b 4a 04             	mov    0x4(%edx),%ecx
f010669e:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01066a1:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f01066a3:	83 c0 01             	add    $0x1,%eax
f01066a6:	83 f8 0a             	cmp    $0xa,%eax
f01066a9:	75 e8                	jne    f0106693 <spin_lock+0x7c>
f01066ab:	eb 0f                	jmp    f01066bc <spin_lock+0xa5>
		pcs[i] = 0;
f01066ad:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
	for (; i < 10; i++)
f01066b4:	83 c0 01             	add    $0x1,%eax
f01066b7:	83 f8 09             	cmp    $0x9,%eax
f01066ba:	7e f1                	jle    f01066ad <spin_lock+0x96>
#endif
}
f01066bc:	83 c4 20             	add    $0x20,%esp
f01066bf:	5b                   	pop    %ebx
f01066c0:	5e                   	pop    %esi
f01066c1:	5d                   	pop    %ebp
f01066c2:	c3                   	ret    

f01066c3 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01066c3:	55                   	push   %ebp
f01066c4:	89 e5                	mov    %esp,%ebp
f01066c6:	57                   	push   %edi
f01066c7:	56                   	push   %esi
f01066c8:	53                   	push   %ebx
f01066c9:	83 ec 6c             	sub    $0x6c,%esp
f01066cc:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f01066cf:	83 3e 00             	cmpl   $0x0,(%esi)
f01066d2:	74 18                	je     f01066ec <spin_unlock+0x29>
f01066d4:	8b 5e 08             	mov    0x8(%esi),%ebx
f01066d7:	e8 bd fc ff ff       	call   f0106399 <cpunum>
f01066dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01066df:	05 20 80 1e f0       	add    $0xf01e8020,%eax
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01066e4:	39 c3                	cmp    %eax,%ebx
f01066e6:	0f 84 ce 00 00 00    	je     f01067ba <spin_unlock+0xf7>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01066ec:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f01066f3:	00 
f01066f4:	8d 46 0c             	lea    0xc(%esi),%eax
f01066f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066fb:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01066fe:	89 1c 24             	mov    %ebx,(%esp)
f0106701:	e8 8e f6 ff ff       	call   f0105d94 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106706:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106709:	0f b6 38             	movzbl (%eax),%edi
f010670c:	8b 76 04             	mov    0x4(%esi),%esi
f010670f:	e8 85 fc ff ff       	call   f0106399 <cpunum>
f0106714:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106718:	89 74 24 08          	mov    %esi,0x8(%esp)
f010671c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106720:	c7 04 24 f0 86 10 f0 	movl   $0xf01086f0,(%esp)
f0106727:	e8 a1 d7 ff ff       	call   f0103ecd <cprintf>
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010672c:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010672f:	eb 65                	jmp    f0106796 <spin_unlock+0xd3>
f0106731:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106735:	89 04 24             	mov    %eax,(%esp)
f0106738:	e8 af ea ff ff       	call   f01051ec <debuginfo_eip>
f010673d:	85 c0                	test   %eax,%eax
f010673f:	78 39                	js     f010677a <spin_unlock+0xb7>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106741:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106743:	89 c2                	mov    %eax,%edx
f0106745:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106748:	89 54 24 18          	mov    %edx,0x18(%esp)
f010674c:	8b 55 b0             	mov    -0x50(%ebp),%edx
f010674f:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106753:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0106756:	89 54 24 10          	mov    %edx,0x10(%esp)
f010675a:	8b 55 ac             	mov    -0x54(%ebp),%edx
f010675d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106761:	8b 55 a8             	mov    -0x58(%ebp),%edx
f0106764:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106768:	89 44 24 04          	mov    %eax,0x4(%esp)
f010676c:	c7 04 24 38 87 10 f0 	movl   $0xf0108738,(%esp)
f0106773:	e8 55 d7 ff ff       	call   f0103ecd <cprintf>
f0106778:	eb 12                	jmp    f010678c <spin_unlock+0xc9>
			else
				cprintf("  %08x\n", pcs[i]);
f010677a:	8b 06                	mov    (%esi),%eax
f010677c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106780:	c7 04 24 4f 87 10 f0 	movl   $0xf010874f,(%esp)
f0106787:	e8 41 d7 ff ff       	call   f0103ecd <cprintf>
f010678c:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f010678f:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106792:	39 c3                	cmp    %eax,%ebx
f0106794:	74 08                	je     f010679e <spin_unlock+0xdb>
f0106796:	89 de                	mov    %ebx,%esi
f0106798:	8b 03                	mov    (%ebx),%eax
f010679a:	85 c0                	test   %eax,%eax
f010679c:	75 93                	jne    f0106731 <spin_unlock+0x6e>
		}
		panic("spin_unlock");
f010679e:	c7 44 24 08 57 87 10 	movl   $0xf0108757,0x8(%esp)
f01067a5:	f0 
f01067a6:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f01067ad:	00 
f01067ae:	c7 04 24 28 87 10 f0 	movl   $0xf0108728,(%esp)
f01067b5:	e8 86 98 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01067ba:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01067c1:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
f01067c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01067cd:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f01067d0:	83 c4 6c             	add    $0x6c,%esp
f01067d3:	5b                   	pop    %ebx
f01067d4:	5e                   	pop    %esi
f01067d5:	5f                   	pop    %edi
f01067d6:	5d                   	pop    %ebp
f01067d7:	c3                   	ret    
f01067d8:	66 90                	xchg   %ax,%ax
f01067da:	66 90                	xchg   %ax,%ax
f01067dc:	66 90                	xchg   %ax,%ax
f01067de:	66 90                	xchg   %ax,%ax

f01067e0 <__udivdi3>:
f01067e0:	55                   	push   %ebp
f01067e1:	57                   	push   %edi
f01067e2:	56                   	push   %esi
f01067e3:	83 ec 0c             	sub    $0xc,%esp
f01067e6:	8b 44 24 28          	mov    0x28(%esp),%eax
f01067ea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f01067ee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f01067f2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f01067f6:	85 c0                	test   %eax,%eax
f01067f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01067fc:	89 ea                	mov    %ebp,%edx
f01067fe:	89 0c 24             	mov    %ecx,(%esp)
f0106801:	75 2d                	jne    f0106830 <__udivdi3+0x50>
f0106803:	39 e9                	cmp    %ebp,%ecx
f0106805:	77 61                	ja     f0106868 <__udivdi3+0x88>
f0106807:	85 c9                	test   %ecx,%ecx
f0106809:	89 ce                	mov    %ecx,%esi
f010680b:	75 0b                	jne    f0106818 <__udivdi3+0x38>
f010680d:	b8 01 00 00 00       	mov    $0x1,%eax
f0106812:	31 d2                	xor    %edx,%edx
f0106814:	f7 f1                	div    %ecx
f0106816:	89 c6                	mov    %eax,%esi
f0106818:	31 d2                	xor    %edx,%edx
f010681a:	89 e8                	mov    %ebp,%eax
f010681c:	f7 f6                	div    %esi
f010681e:	89 c5                	mov    %eax,%ebp
f0106820:	89 f8                	mov    %edi,%eax
f0106822:	f7 f6                	div    %esi
f0106824:	89 ea                	mov    %ebp,%edx
f0106826:	83 c4 0c             	add    $0xc,%esp
f0106829:	5e                   	pop    %esi
f010682a:	5f                   	pop    %edi
f010682b:	5d                   	pop    %ebp
f010682c:	c3                   	ret    
f010682d:	8d 76 00             	lea    0x0(%esi),%esi
f0106830:	39 e8                	cmp    %ebp,%eax
f0106832:	77 24                	ja     f0106858 <__udivdi3+0x78>
f0106834:	0f bd e8             	bsr    %eax,%ebp
f0106837:	83 f5 1f             	xor    $0x1f,%ebp
f010683a:	75 3c                	jne    f0106878 <__udivdi3+0x98>
f010683c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106840:	39 34 24             	cmp    %esi,(%esp)
f0106843:	0f 86 9f 00 00 00    	jbe    f01068e8 <__udivdi3+0x108>
f0106849:	39 d0                	cmp    %edx,%eax
f010684b:	0f 82 97 00 00 00    	jb     f01068e8 <__udivdi3+0x108>
f0106851:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106858:	31 d2                	xor    %edx,%edx
f010685a:	31 c0                	xor    %eax,%eax
f010685c:	83 c4 0c             	add    $0xc,%esp
f010685f:	5e                   	pop    %esi
f0106860:	5f                   	pop    %edi
f0106861:	5d                   	pop    %ebp
f0106862:	c3                   	ret    
f0106863:	90                   	nop
f0106864:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106868:	89 f8                	mov    %edi,%eax
f010686a:	f7 f1                	div    %ecx
f010686c:	31 d2                	xor    %edx,%edx
f010686e:	83 c4 0c             	add    $0xc,%esp
f0106871:	5e                   	pop    %esi
f0106872:	5f                   	pop    %edi
f0106873:	5d                   	pop    %ebp
f0106874:	c3                   	ret    
f0106875:	8d 76 00             	lea    0x0(%esi),%esi
f0106878:	89 e9                	mov    %ebp,%ecx
f010687a:	8b 3c 24             	mov    (%esp),%edi
f010687d:	d3 e0                	shl    %cl,%eax
f010687f:	89 c6                	mov    %eax,%esi
f0106881:	b8 20 00 00 00       	mov    $0x20,%eax
f0106886:	29 e8                	sub    %ebp,%eax
f0106888:	89 c1                	mov    %eax,%ecx
f010688a:	d3 ef                	shr    %cl,%edi
f010688c:	89 e9                	mov    %ebp,%ecx
f010688e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106892:	8b 3c 24             	mov    (%esp),%edi
f0106895:	09 74 24 08          	or     %esi,0x8(%esp)
f0106899:	89 d6                	mov    %edx,%esi
f010689b:	d3 e7                	shl    %cl,%edi
f010689d:	89 c1                	mov    %eax,%ecx
f010689f:	89 3c 24             	mov    %edi,(%esp)
f01068a2:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01068a6:	d3 ee                	shr    %cl,%esi
f01068a8:	89 e9                	mov    %ebp,%ecx
f01068aa:	d3 e2                	shl    %cl,%edx
f01068ac:	89 c1                	mov    %eax,%ecx
f01068ae:	d3 ef                	shr    %cl,%edi
f01068b0:	09 d7                	or     %edx,%edi
f01068b2:	89 f2                	mov    %esi,%edx
f01068b4:	89 f8                	mov    %edi,%eax
f01068b6:	f7 74 24 08          	divl   0x8(%esp)
f01068ba:	89 d6                	mov    %edx,%esi
f01068bc:	89 c7                	mov    %eax,%edi
f01068be:	f7 24 24             	mull   (%esp)
f01068c1:	39 d6                	cmp    %edx,%esi
f01068c3:	89 14 24             	mov    %edx,(%esp)
f01068c6:	72 30                	jb     f01068f8 <__udivdi3+0x118>
f01068c8:	8b 54 24 04          	mov    0x4(%esp),%edx
f01068cc:	89 e9                	mov    %ebp,%ecx
f01068ce:	d3 e2                	shl    %cl,%edx
f01068d0:	39 c2                	cmp    %eax,%edx
f01068d2:	73 05                	jae    f01068d9 <__udivdi3+0xf9>
f01068d4:	3b 34 24             	cmp    (%esp),%esi
f01068d7:	74 1f                	je     f01068f8 <__udivdi3+0x118>
f01068d9:	89 f8                	mov    %edi,%eax
f01068db:	31 d2                	xor    %edx,%edx
f01068dd:	e9 7a ff ff ff       	jmp    f010685c <__udivdi3+0x7c>
f01068e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01068e8:	31 d2                	xor    %edx,%edx
f01068ea:	b8 01 00 00 00       	mov    $0x1,%eax
f01068ef:	e9 68 ff ff ff       	jmp    f010685c <__udivdi3+0x7c>
f01068f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01068f8:	8d 47 ff             	lea    -0x1(%edi),%eax
f01068fb:	31 d2                	xor    %edx,%edx
f01068fd:	83 c4 0c             	add    $0xc,%esp
f0106900:	5e                   	pop    %esi
f0106901:	5f                   	pop    %edi
f0106902:	5d                   	pop    %ebp
f0106903:	c3                   	ret    
f0106904:	66 90                	xchg   %ax,%ax
f0106906:	66 90                	xchg   %ax,%ax
f0106908:	66 90                	xchg   %ax,%ax
f010690a:	66 90                	xchg   %ax,%ax
f010690c:	66 90                	xchg   %ax,%ax
f010690e:	66 90                	xchg   %ax,%ax

f0106910 <__umoddi3>:
f0106910:	55                   	push   %ebp
f0106911:	57                   	push   %edi
f0106912:	56                   	push   %esi
f0106913:	83 ec 14             	sub    $0x14,%esp
f0106916:	8b 44 24 28          	mov    0x28(%esp),%eax
f010691a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f010691e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0106922:	89 c7                	mov    %eax,%edi
f0106924:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106928:	8b 44 24 30          	mov    0x30(%esp),%eax
f010692c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0106930:	89 34 24             	mov    %esi,(%esp)
f0106933:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106937:	85 c0                	test   %eax,%eax
f0106939:	89 c2                	mov    %eax,%edx
f010693b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010693f:	75 17                	jne    f0106958 <__umoddi3+0x48>
f0106941:	39 fe                	cmp    %edi,%esi
f0106943:	76 4b                	jbe    f0106990 <__umoddi3+0x80>
f0106945:	89 c8                	mov    %ecx,%eax
f0106947:	89 fa                	mov    %edi,%edx
f0106949:	f7 f6                	div    %esi
f010694b:	89 d0                	mov    %edx,%eax
f010694d:	31 d2                	xor    %edx,%edx
f010694f:	83 c4 14             	add    $0x14,%esp
f0106952:	5e                   	pop    %esi
f0106953:	5f                   	pop    %edi
f0106954:	5d                   	pop    %ebp
f0106955:	c3                   	ret    
f0106956:	66 90                	xchg   %ax,%ax
f0106958:	39 f8                	cmp    %edi,%eax
f010695a:	77 54                	ja     f01069b0 <__umoddi3+0xa0>
f010695c:	0f bd e8             	bsr    %eax,%ebp
f010695f:	83 f5 1f             	xor    $0x1f,%ebp
f0106962:	75 5c                	jne    f01069c0 <__umoddi3+0xb0>
f0106964:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0106968:	39 3c 24             	cmp    %edi,(%esp)
f010696b:	0f 87 e7 00 00 00    	ja     f0106a58 <__umoddi3+0x148>
f0106971:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106975:	29 f1                	sub    %esi,%ecx
f0106977:	19 c7                	sbb    %eax,%edi
f0106979:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010697d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106981:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106985:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106989:	83 c4 14             	add    $0x14,%esp
f010698c:	5e                   	pop    %esi
f010698d:	5f                   	pop    %edi
f010698e:	5d                   	pop    %ebp
f010698f:	c3                   	ret    
f0106990:	85 f6                	test   %esi,%esi
f0106992:	89 f5                	mov    %esi,%ebp
f0106994:	75 0b                	jne    f01069a1 <__umoddi3+0x91>
f0106996:	b8 01 00 00 00       	mov    $0x1,%eax
f010699b:	31 d2                	xor    %edx,%edx
f010699d:	f7 f6                	div    %esi
f010699f:	89 c5                	mov    %eax,%ebp
f01069a1:	8b 44 24 04          	mov    0x4(%esp),%eax
f01069a5:	31 d2                	xor    %edx,%edx
f01069a7:	f7 f5                	div    %ebp
f01069a9:	89 c8                	mov    %ecx,%eax
f01069ab:	f7 f5                	div    %ebp
f01069ad:	eb 9c                	jmp    f010694b <__umoddi3+0x3b>
f01069af:	90                   	nop
f01069b0:	89 c8                	mov    %ecx,%eax
f01069b2:	89 fa                	mov    %edi,%edx
f01069b4:	83 c4 14             	add    $0x14,%esp
f01069b7:	5e                   	pop    %esi
f01069b8:	5f                   	pop    %edi
f01069b9:	5d                   	pop    %ebp
f01069ba:	c3                   	ret    
f01069bb:	90                   	nop
f01069bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01069c0:	8b 04 24             	mov    (%esp),%eax
f01069c3:	be 20 00 00 00       	mov    $0x20,%esi
f01069c8:	89 e9                	mov    %ebp,%ecx
f01069ca:	29 ee                	sub    %ebp,%esi
f01069cc:	d3 e2                	shl    %cl,%edx
f01069ce:	89 f1                	mov    %esi,%ecx
f01069d0:	d3 e8                	shr    %cl,%eax
f01069d2:	89 e9                	mov    %ebp,%ecx
f01069d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069d8:	8b 04 24             	mov    (%esp),%eax
f01069db:	09 54 24 04          	or     %edx,0x4(%esp)
f01069df:	89 fa                	mov    %edi,%edx
f01069e1:	d3 e0                	shl    %cl,%eax
f01069e3:	89 f1                	mov    %esi,%ecx
f01069e5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01069e9:	8b 44 24 10          	mov    0x10(%esp),%eax
f01069ed:	d3 ea                	shr    %cl,%edx
f01069ef:	89 e9                	mov    %ebp,%ecx
f01069f1:	d3 e7                	shl    %cl,%edi
f01069f3:	89 f1                	mov    %esi,%ecx
f01069f5:	d3 e8                	shr    %cl,%eax
f01069f7:	89 e9                	mov    %ebp,%ecx
f01069f9:	09 f8                	or     %edi,%eax
f01069fb:	8b 7c 24 10          	mov    0x10(%esp),%edi
f01069ff:	f7 74 24 04          	divl   0x4(%esp)
f0106a03:	d3 e7                	shl    %cl,%edi
f0106a05:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106a09:	89 d7                	mov    %edx,%edi
f0106a0b:	f7 64 24 08          	mull   0x8(%esp)
f0106a0f:	39 d7                	cmp    %edx,%edi
f0106a11:	89 c1                	mov    %eax,%ecx
f0106a13:	89 14 24             	mov    %edx,(%esp)
f0106a16:	72 2c                	jb     f0106a44 <__umoddi3+0x134>
f0106a18:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0106a1c:	72 22                	jb     f0106a40 <__umoddi3+0x130>
f0106a1e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106a22:	29 c8                	sub    %ecx,%eax
f0106a24:	19 d7                	sbb    %edx,%edi
f0106a26:	89 e9                	mov    %ebp,%ecx
f0106a28:	89 fa                	mov    %edi,%edx
f0106a2a:	d3 e8                	shr    %cl,%eax
f0106a2c:	89 f1                	mov    %esi,%ecx
f0106a2e:	d3 e2                	shl    %cl,%edx
f0106a30:	89 e9                	mov    %ebp,%ecx
f0106a32:	d3 ef                	shr    %cl,%edi
f0106a34:	09 d0                	or     %edx,%eax
f0106a36:	89 fa                	mov    %edi,%edx
f0106a38:	83 c4 14             	add    $0x14,%esp
f0106a3b:	5e                   	pop    %esi
f0106a3c:	5f                   	pop    %edi
f0106a3d:	5d                   	pop    %ebp
f0106a3e:	c3                   	ret    
f0106a3f:	90                   	nop
f0106a40:	39 d7                	cmp    %edx,%edi
f0106a42:	75 da                	jne    f0106a1e <__umoddi3+0x10e>
f0106a44:	8b 14 24             	mov    (%esp),%edx
f0106a47:	89 c1                	mov    %eax,%ecx
f0106a49:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0106a4d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0106a51:	eb cb                	jmp    f0106a1e <__umoddi3+0x10e>
f0106a53:	90                   	nop
f0106a54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106a58:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0106a5c:	0f 82 0f ff ff ff    	jb     f0106971 <__umoddi3+0x61>
f0106a62:	e9 1a ff ff ff       	jmp    f0106981 <__umoddi3+0x71>
