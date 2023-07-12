
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
f010004b:	83 3d 80 0e 23 f0 00 	cmpl   $0x0,0xf0230e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 0e 23 f0    	mov    %esi,0xf0230e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 d5 63 00 00       	call   f0106439 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 20 6b 10 f0 	movl   $0xf0106b20,(%esp)
f010007d:	e8 a3 3e 00 00       	call   f0103f25 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 64 3e 00 00       	call   f0103ef2 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 22 7d 10 f0 	movl   $0xf0107d22,(%esp)
f0100095:	e8 8b 3e 00 00       	call   f0103f25 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 0b 09 00 00       	call   f01009b1 <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <i386_init>:
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	53                   	push   %ebx
f01000ac:	83 ec 14             	sub    $0x14,%esp
	memset(edata, 0, end - edata);
f01000af:	b8 08 20 27 f0       	mov    $0xf0272008,%eax
f01000b4:	2d 00 00 23 f0       	sub    $0xf0230000,%eax
f01000b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000c4:	00 
f01000c5:	c7 04 24 00 00 23 f0 	movl   $0xf0230000,(%esp)
f01000cc:	e8 16 5d 00 00       	call   f0105de7 <memset>
	cons_init();
f01000d1:	e8 b9 05 00 00       	call   f010068f <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d6:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000dd:	00 
f01000de:	c7 04 24 8c 6b 10 f0 	movl   $0xf0106b8c,(%esp)
f01000e5:	e8 3b 3e 00 00       	call   f0103f25 <cprintf>
	mem_init();
f01000ea:	e8 1a 14 00 00       	call   f0101509 <mem_init>
	env_init();
f01000ef:	e8 02 36 00 00       	call   f01036f6 <env_init>
	trap_init();
f01000f4:	e8 d2 3e 00 00       	call   f0103fcb <trap_init>
	mp_init();
f01000f9:	e8 2c 60 00 00       	call   f010612a <mp_init>
	lapic_init();
f01000fe:	66 90                	xchg   %ax,%ax
f0100100:	e8 4f 63 00 00       	call   f0106454 <lapic_init>
	pic_init();
f0100105:	e8 4b 3d 00 00       	call   f0103e55 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010010a:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100111:	e8 a1 65 00 00       	call   f01066b7 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100116:	83 3d 88 0e 23 f0 07 	cmpl   $0x7,0xf0230e88
f010011d:	77 24                	ja     f0100143 <i386_init+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011f:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100126:	00 
f0100127:	c7 44 24 08 44 6b 10 	movl   $0xf0106b44,0x8(%esp)
f010012e:	f0 
f010012f:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f0100136:	00 
f0100137:	c7 04 24 a7 6b 10 f0 	movl   $0xf0106ba7,(%esp)
f010013e:	e8 fd fe ff ff       	call   f0100040 <_panic>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100143:	b8 62 60 10 f0       	mov    $0xf0106062,%eax
f0100148:	2d e8 5f 10 f0       	sub    $0xf0105fe8,%eax
f010014d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100151:	c7 44 24 04 e8 5f 10 	movl   $0xf0105fe8,0x4(%esp)
f0100158:	f0 
f0100159:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100160:	e8 cf 5c 00 00       	call   f0105e34 <memmove>
	for (c = cpus; c < cpus + ncpu; c++)
f0100165:	bb 20 10 23 f0       	mov    $0xf0231020,%ebx
f010016a:	eb 4d                	jmp    f01001b9 <i386_init+0x111>
		if (c == cpus + cpunum()) // We've started already.
f010016c:	e8 c8 62 00 00       	call   f0106439 <cpunum>
f0100171:	6b c0 74             	imul   $0x74,%eax,%eax
f0100174:	05 20 10 23 f0       	add    $0xf0231020,%eax
f0100179:	39 c3                	cmp    %eax,%ebx
f010017b:	74 39                	je     f01001b6 <i386_init+0x10e>
f010017d:	89 d8                	mov    %ebx,%eax
f010017f:	2d 20 10 23 f0       	sub    $0xf0231020,%eax
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100184:	c1 f8 02             	sar    $0x2,%eax
f0100187:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010018d:	c1 e0 0f             	shl    $0xf,%eax
f0100190:	8d 80 00 a0 23 f0    	lea    -0xfdc6000(%eax),%eax
f0100196:	a3 84 0e 23 f0       	mov    %eax,0xf0230e84
		lapic_startap(c->cpu_id, PADDR(code));
f010019b:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f01001a2:	00 
f01001a3:	0f b6 03             	movzbl (%ebx),%eax
f01001a6:	89 04 24             	mov    %eax,(%esp)
f01001a9:	e8 f6 63 00 00       	call   f01065a4 <lapic_startap>
		while (c->cpu_status != CPU_STARTED)
f01001ae:	8b 43 04             	mov    0x4(%ebx),%eax
f01001b1:	83 f8 01             	cmp    $0x1,%eax
f01001b4:	75 f8                	jne    f01001ae <i386_init+0x106>
	for (c = cpus; c < cpus + ncpu; c++)
f01001b6:	83 c3 74             	add    $0x74,%ebx
f01001b9:	6b 05 c4 13 23 f0 74 	imul   $0x74,0xf02313c4,%eax
f01001c0:	05 20 10 23 f0       	add    $0xf0231020,%eax
f01001c5:	39 c3                	cmp    %eax,%ebx
f01001c7:	72 a3                	jb     f010016c <i386_init+0xc4>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01001d0:	00 
f01001d1:	c7 04 24 cc 5e 22 f0 	movl   $0xf0225ecc,(%esp)
f01001d8:	e8 17 37 00 00       	call   f01038f4 <env_create>
	sched_yield();
f01001dd:	e8 5d 49 00 00       	call   f0104b3f <sched_yield>

f01001e2 <mp_main>:
{
f01001e2:	55                   	push   %ebp
f01001e3:	89 e5                	mov    %esp,%ebp
f01001e5:	83 ec 18             	sub    $0x18,%esp
	lcr3(PADDR(kern_pgdir));
f01001e8:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01001ed:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001f2:	77 20                	ja     f0100214 <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01001f8:	c7 44 24 08 68 6b 10 	movl   $0xf0106b68,0x8(%esp)
f01001ff:	f0 
f0100200:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
f0100207:	00 
f0100208:	c7 04 24 a7 6b 10 f0 	movl   $0xf0106ba7,(%esp)
f010020f:	e8 2c fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100214:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0100219:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010021c:	e8 18 62 00 00       	call   f0106439 <cpunum>
f0100221:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100225:	c7 04 24 b3 6b 10 f0 	movl   $0xf0106bb3,(%esp)
f010022c:	e8 f4 3c 00 00       	call   f0103f25 <cprintf>
	lapic_init();
f0100231:	e8 1e 62 00 00       	call   f0106454 <lapic_init>
	env_init_percpu();
f0100236:	e8 91 34 00 00       	call   f01036cc <env_init_percpu>
	trap_init_percpu();
f010023b:	90                   	nop
f010023c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100240:	e8 fb 3c 00 00       	call   f0103f40 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100245:	e8 ef 61 00 00       	call   f0106439 <cpunum>
f010024a:	6b d0 74             	imul   $0x74,%eax,%edx
f010024d:	81 c2 20 10 23 f0    	add    $0xf0231020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100253:	b8 01 00 00 00       	mov    $0x1,%eax
f0100258:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010025c:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100263:	e8 4f 64 00 00       	call   f01066b7 <spin_lock>
	sched_yield();
f0100268:	e8 d2 48 00 00       	call   f0104b3f <sched_yield>

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
f0100285:	c7 04 24 c9 6b 10 f0 	movl   $0xf0106bc9,(%esp)
f010028c:	e8 94 3c 00 00       	call   f0103f25 <cprintf>
	vcprintf(fmt, ap);
f0100291:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100295:	8b 45 10             	mov    0x10(%ebp),%eax
f0100298:	89 04 24             	mov    %eax,(%esp)
f010029b:	e8 52 3c 00 00       	call   f0103ef2 <vcprintf>
	cprintf("\n");
f01002a0:	c7 04 24 22 7d 10 f0 	movl   $0xf0107d22,(%esp)
f01002a7:	e8 79 3c 00 00       	call   f0103f25 <cprintf>
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
f01002eb:	a1 24 02 23 f0       	mov    0xf0230224,%eax
f01002f0:	8d 48 01             	lea    0x1(%eax),%ecx
f01002f3:	89 0d 24 02 23 f0    	mov    %ecx,0xf0230224
f01002f9:	88 90 20 00 23 f0    	mov    %dl,-0xfdcffe0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f01002ff:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100305:	75 0a                	jne    f0100311 <cons_intr+0x35>
			cons.wpos = 0;
f0100307:	c7 05 24 02 23 f0 00 	movl   $0x0,0xf0230224
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
f010033f:	83 0d 00 00 23 f0 40 	orl    $0x40,0xf0230000
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
f0100357:	8b 0d 00 00 23 f0    	mov    0xf0230000,%ecx
f010035d:	89 cb                	mov    %ecx,%ebx
f010035f:	83 e3 40             	and    $0x40,%ebx
f0100362:	83 e0 7f             	and    $0x7f,%eax
f0100365:	85 db                	test   %ebx,%ebx
f0100367:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010036a:	0f b6 d2             	movzbl %dl,%edx
f010036d:	0f b6 82 40 6d 10 f0 	movzbl -0xfef92c0(%edx),%eax
f0100374:	83 c8 40             	or     $0x40,%eax
f0100377:	0f b6 c0             	movzbl %al,%eax
f010037a:	f7 d0                	not    %eax
f010037c:	21 c1                	and    %eax,%ecx
f010037e:	89 0d 00 00 23 f0    	mov    %ecx,0xf0230000
		return 0;
f0100384:	b8 00 00 00 00       	mov    $0x0,%eax
f0100389:	e9 a3 00 00 00       	jmp    f0100431 <kbd_proc_data+0x111>
	else if (shift & E0ESC)
f010038e:	8b 0d 00 00 23 f0    	mov    0xf0230000,%ecx
f0100394:	f6 c1 40             	test   $0x40,%cl
f0100397:	74 0e                	je     f01003a7 <kbd_proc_data+0x87>
		data |= 0x80;
f0100399:	83 c8 80             	or     $0xffffff80,%eax
f010039c:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010039e:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003a1:	89 0d 00 00 23 f0    	mov    %ecx,0xf0230000
	shift |= shiftcode[data];
f01003a7:	0f b6 d2             	movzbl %dl,%edx
f01003aa:	0f b6 82 40 6d 10 f0 	movzbl -0xfef92c0(%edx),%eax
f01003b1:	0b 05 00 00 23 f0    	or     0xf0230000,%eax
	shift ^= togglecode[data];
f01003b7:	0f b6 8a 40 6c 10 f0 	movzbl -0xfef93c0(%edx),%ecx
f01003be:	31 c8                	xor    %ecx,%eax
f01003c0:	a3 00 00 23 f0       	mov    %eax,0xf0230000
	c = charcode[shift & (CTL | SHIFT)][data];
f01003c5:	89 c1                	mov    %eax,%ecx
f01003c7:	83 e1 03             	and    $0x3,%ecx
f01003ca:	8b 0c 8d 20 6c 10 f0 	mov    -0xfef93e0(,%ecx,4),%ecx
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
f010040a:	c7 04 24 e3 6b 10 f0 	movl   $0xf0106be3,(%esp)
f0100411:	e8 0f 3b 00 00       	call   f0103f25 <cprintf>
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
f01004ec:	0f b7 05 28 02 23 f0 	movzwl 0xf0230228,%eax
f01004f3:	66 85 c0             	test   %ax,%ax
f01004f6:	0f 84 e5 00 00 00    	je     f01005e1 <cons_putc+0x1aa>
			crt_pos--;
f01004fc:	83 e8 01             	sub    $0x1,%eax
f01004ff:	66 a3 28 02 23 f0    	mov    %ax,0xf0230228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100505:	0f b7 c0             	movzwl %ax,%eax
f0100508:	66 81 e7 00 ff       	and    $0xff00,%di
f010050d:	83 cf 20             	or     $0x20,%edi
f0100510:	8b 15 2c 02 23 f0    	mov    0xf023022c,%edx
f0100516:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010051a:	eb 78                	jmp    f0100594 <cons_putc+0x15d>
		crt_pos += CRT_COLS;
f010051c:	66 83 05 28 02 23 f0 	addw   $0x50,0xf0230228
f0100523:	50 
		crt_pos -= (crt_pos % CRT_COLS);
f0100524:	0f b7 05 28 02 23 f0 	movzwl 0xf0230228,%eax
f010052b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100531:	c1 e8 16             	shr    $0x16,%eax
f0100534:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100537:	c1 e0 04             	shl    $0x4,%eax
f010053a:	66 a3 28 02 23 f0    	mov    %ax,0xf0230228
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
f0100576:	0f b7 05 28 02 23 f0 	movzwl 0xf0230228,%eax
f010057d:	8d 50 01             	lea    0x1(%eax),%edx
f0100580:	66 89 15 28 02 23 f0 	mov    %dx,0xf0230228
f0100587:	0f b7 c0             	movzwl %ax,%eax
f010058a:	8b 15 2c 02 23 f0    	mov    0xf023022c,%edx
f0100590:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
	if (crt_pos >= CRT_SIZE) // 当输出字符超过终端范围
f0100594:	66 81 3d 28 02 23 f0 	cmpw   $0x7cf,0xf0230228
f010059b:	cf 07 
f010059d:	76 42                	jbe    f01005e1 <cons_putc+0x1aa>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t)); // 已有字符往上移动一行
f010059f:	a1 2c 02 23 f0       	mov    0xf023022c,%eax
f01005a4:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01005ab:	00 
f01005ac:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005b2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005b6:	89 04 24             	mov    %eax,(%esp)
f01005b9:	e8 76 58 00 00       	call   f0105e34 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01005be:	8b 15 2c 02 23 f0    	mov    0xf023022c,%edx
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)								// 清零最后一行
f01005c4:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01005c9:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)								// 清零最后一行
f01005cf:	83 c0 01             	add    $0x1,%eax
f01005d2:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005d7:	75 f0                	jne    f01005c9 <cons_putc+0x192>
		crt_pos -= CRT_COLS; // 索引向前移动，即从最后一行的开头写入
f01005d9:	66 83 2d 28 02 23 f0 	subw   $0x50,0xf0230228
f01005e0:	50 
	outb(addr_6845, 14);
f01005e1:	8b 0d 30 02 23 f0    	mov    0xf0230230,%ecx
f01005e7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005ec:	89 ca                	mov    %ecx,%edx
f01005ee:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005ef:	0f b7 1d 28 02 23 f0 	movzwl 0xf0230228,%ebx
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
f0100617:	80 3d 34 02 23 f0 00 	cmpb   $0x0,0xf0230234
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
f0100655:	a1 20 02 23 f0       	mov    0xf0230220,%eax
f010065a:	3b 05 24 02 23 f0    	cmp    0xf0230224,%eax
f0100660:	74 26                	je     f0100688 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100662:	8d 50 01             	lea    0x1(%eax),%edx
f0100665:	89 15 20 02 23 f0    	mov    %edx,0xf0230220
f010066b:	0f b6 88 20 00 23 f0 	movzbl -0xfdcffe0(%eax),%ecx
		return c;
f0100672:	89 c8                	mov    %ecx,%eax
		if (cons.rpos == CONSBUFSIZE)
f0100674:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010067a:	75 11                	jne    f010068d <cons_getc+0x48>
			cons.rpos = 0;
f010067c:	c7 05 20 02 23 f0 00 	movl   $0x0,0xf0230220
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
f01006b5:	c7 05 30 02 23 f0 b4 	movl   $0x3b4,0xf0230230
f01006bc:	03 00 00 
		cp = (uint16_t *)(KERNBASE + MONO_BUF);
f01006bf:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f01006c4:	eb 16                	jmp    f01006dc <cons_init+0x4d>
		*cp = was;
f01006c6:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006cd:	c7 05 30 02 23 f0 d4 	movl   $0x3d4,0xf0230230
f01006d4:	03 00 00 
	cp = (uint16_t *)(KERNBASE + CGA_BUF);
f01006d7:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
	outb(addr_6845, 14);
f01006dc:	8b 0d 30 02 23 f0    	mov    0xf0230230,%ecx
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
f0100701:	89 3d 2c 02 23 f0    	mov    %edi,0xf023022c
	pos |= inb(addr_6845 + 1);
f0100707:	0f b6 d8             	movzbl %al,%ebx
f010070a:	09 de                	or     %ebx,%esi
	crt_pos = pos;
f010070c:	66 89 35 28 02 23 f0 	mov    %si,0xf0230228
	kbd_intr();
f0100713:	e8 1b ff ff ff       	call   f0100633 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f0100718:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f010071f:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100724:	89 04 24             	mov    %eax,(%esp)
f0100727:	e8 ba 36 00 00       	call   f0103de6 <irq_setmask_8259A>
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
f0100776:	88 0d 34 02 23 f0    	mov    %cl,0xf0230234
f010077c:	89 f2                	mov    %esi,%edx
f010077e:	ec                   	in     (%dx),%al
f010077f:	89 da                	mov    %ebx,%edx
f0100781:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100782:	84 c9                	test   %cl,%cl
f0100784:	75 0c                	jne    f0100792 <cons_init+0x103>
		cprintf("Serial port does not exist!\n");
f0100786:	c7 04 24 ef 6b 10 f0 	movl   $0xf0106bef,(%esp)
f010078d:	e8 93 37 00 00       	call   f0103f25 <cprintf>
}
f0100792:	83 c4 1c             	add    $0x1c,%esp
f0100795:	5b                   	pop    %ebx
f0100796:	5e                   	pop    %esi
f0100797:	5f                   	pop    %edi
f0100798:	5d                   	pop    %ebp
f0100799:	c3                   	ret    

f010079a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void cputchar(int c)
{
f010079a:	55                   	push   %ebp
f010079b:	89 e5                	mov    %esp,%ebp
f010079d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01007a3:	e8 8f fc ff ff       	call   f0100437 <cons_putc>
}
f01007a8:	c9                   	leave  
f01007a9:	c3                   	ret    

f01007aa <getchar>:

int getchar(void)
{
f01007aa:	55                   	push   %ebp
f01007ab:	89 e5                	mov    %esp,%ebp
f01007ad:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007b0:	e8 90 fe ff ff       	call   f0100645 <cons_getc>
f01007b5:	85 c0                	test   %eax,%eax
f01007b7:	74 f7                	je     f01007b0 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007b9:	c9                   	leave  
f01007ba:	c3                   	ret    

f01007bb <iscons>:

int iscons(int fdnum)
{
f01007bb:	55                   	push   %ebp
f01007bc:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007be:	b8 01 00 00 00       	mov    $0x1,%eax
f01007c3:	5d                   	pop    %ebp
f01007c4:	c3                   	ret    
f01007c5:	66 90                	xchg   %ax,%ax
f01007c7:	66 90                	xchg   %ax,%ax
f01007c9:	66 90                	xchg   %ax,%ax
f01007cb:	66 90                	xchg   %ax,%ax
f01007cd:	66 90                	xchg   %ax,%ax
f01007cf:	90                   	nop

f01007d0 <mon_help>:
};

/***** Implementations of basic kernel monitor commands *****/

int mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007d0:	55                   	push   %ebp
f01007d1:	89 e5                	mov    %esp,%ebp
f01007d3:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007d6:	c7 44 24 08 40 6e 10 	movl   $0xf0106e40,0x8(%esp)
f01007dd:	f0 
f01007de:	c7 44 24 04 5e 6e 10 	movl   $0xf0106e5e,0x4(%esp)
f01007e5:	f0 
f01007e6:	c7 04 24 63 6e 10 f0 	movl   $0xf0106e63,(%esp)
f01007ed:	e8 33 37 00 00       	call   f0103f25 <cprintf>
f01007f2:	c7 44 24 08 08 6f 10 	movl   $0xf0106f08,0x8(%esp)
f01007f9:	f0 
f01007fa:	c7 44 24 04 6c 6e 10 	movl   $0xf0106e6c,0x4(%esp)
f0100801:	f0 
f0100802:	c7 04 24 63 6e 10 f0 	movl   $0xf0106e63,(%esp)
f0100809:	e8 17 37 00 00       	call   f0103f25 <cprintf>
f010080e:	c7 44 24 08 75 6e 10 	movl   $0xf0106e75,0x8(%esp)
f0100815:	f0 
f0100816:	c7 44 24 04 7b 6e 10 	movl   $0xf0106e7b,0x4(%esp)
f010081d:	f0 
f010081e:	c7 04 24 63 6e 10 f0 	movl   $0xf0106e63,(%esp)
f0100825:	e8 fb 36 00 00       	call   f0103f25 <cprintf>
	return 0;
}
f010082a:	b8 00 00 00 00       	mov    $0x0,%eax
f010082f:	c9                   	leave  
f0100830:	c3                   	ret    

f0100831 <mon_kerninfo>:

int mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100831:	55                   	push   %ebp
f0100832:	89 e5                	mov    %esp,%ebp
f0100834:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100837:	c7 04 24 85 6e 10 f0 	movl   $0xf0106e85,(%esp)
f010083e:	e8 e2 36 00 00       	call   f0103f25 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100843:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010084a:	00 
f010084b:	c7 04 24 30 6f 10 f0 	movl   $0xf0106f30,(%esp)
f0100852:	e8 ce 36 00 00       	call   f0103f25 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100857:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010085e:	00 
f010085f:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100866:	f0 
f0100867:	c7 04 24 58 6f 10 f0 	movl   $0xf0106f58,(%esp)
f010086e:	e8 b2 36 00 00       	call   f0103f25 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100873:	c7 44 24 08 07 6b 10 	movl   $0x106b07,0x8(%esp)
f010087a:	00 
f010087b:	c7 44 24 04 07 6b 10 	movl   $0xf0106b07,0x4(%esp)
f0100882:	f0 
f0100883:	c7 04 24 7c 6f 10 f0 	movl   $0xf0106f7c,(%esp)
f010088a:	e8 96 36 00 00       	call   f0103f25 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010088f:	c7 44 24 08 00 00 23 	movl   $0x230000,0x8(%esp)
f0100896:	00 
f0100897:	c7 44 24 04 00 00 23 	movl   $0xf0230000,0x4(%esp)
f010089e:	f0 
f010089f:	c7 04 24 a0 6f 10 f0 	movl   $0xf0106fa0,(%esp)
f01008a6:	e8 7a 36 00 00       	call   f0103f25 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008ab:	c7 44 24 08 08 20 27 	movl   $0x272008,0x8(%esp)
f01008b2:	00 
f01008b3:	c7 44 24 04 08 20 27 	movl   $0xf0272008,0x4(%esp)
f01008ba:	f0 
f01008bb:	c7 04 24 c4 6f 10 f0 	movl   $0xf0106fc4,(%esp)
f01008c2:	e8 5e 36 00 00       	call   f0103f25 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
			ROUNDUP(end - entry, 1024) / 1024);
f01008c7:	b8 07 24 27 f0       	mov    $0xf0272407,%eax
f01008cc:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01008d1:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008d6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008dc:	85 c0                	test   %eax,%eax
f01008de:	0f 48 c2             	cmovs  %edx,%eax
f01008e1:	c1 f8 0a             	sar    $0xa,%eax
f01008e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008e8:	c7 04 24 e8 6f 10 f0 	movl   $0xf0106fe8,(%esp)
f01008ef:	e8 31 36 00 00       	call   f0103f25 <cprintf>
	return 0;
}
f01008f4:	b8 00 00 00 00       	mov    $0x0,%eax
f01008f9:	c9                   	leave  
f01008fa:	c3                   	ret    

f01008fb <mon_backtrace>:

int mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008fb:	55                   	push   %ebp
f01008fc:	89 e5                	mov    %esp,%ebp
f01008fe:	57                   	push   %edi
f01008ff:	56                   	push   %esi
f0100900:	53                   	push   %ebx
f0100901:	83 ec 4c             	sub    $0x4c,%esp
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100904:	89 e8                	mov    %ebp,%eax
	// 被调用的函数(mon_backtrace)开始时，首先完成了push %ebp，mov %esp, %ebp
	// 注1：push时，先减%esp在存储内容
	// 注2：栈向下生长，用+1来访问前面的内容
	// Your code here.

	int *ebp = (int *)read_ebp(); // 读取本函数%ebp的值，转化为指针，作为地址使用
f0100906:	89 c7                	mov    %eax,%edi
	int eip = ebp[1];			  // 堆栈上存储的第一个东西就是返回地址，因此用偏移量1来访问
f0100908:	8b 40 04             	mov    0x4(%eax),%eax
f010090b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	while (1)					  // trace整个stack
	{
		// 打印%ebp和%eip
		cprintf("ebp %x, eip %x, args ", ebp, eip);
f010090e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100911:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100915:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100919:	c7 04 24 9e 6e 10 f0 	movl   $0xf0106e9e,(%esp)
f0100920:	e8 00 36 00 00       	call   f0103f25 <cprintf>
		int *args = ebp + 2;		 // 从偏移量2开始存储的是上个函数的参数
f0100925:	8d 5f 08             	lea    0x8(%edi),%ebx
f0100928:	8d 77 1c             	lea    0x1c(%edi),%esi
		for (int i = 0; i < 5; ++i)	 // 练习要求打印5个参数
			cprintf("%x ", args[i]); // 输出参数，注：args[i]和args+i是一样的效果
f010092b:	8b 03                	mov    (%ebx),%eax
f010092d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100931:	c7 04 24 b4 6e 10 f0 	movl   $0xf0106eb4,(%esp)
f0100938:	e8 e8 35 00 00       	call   f0103f25 <cprintf>
f010093d:	83 c3 04             	add    $0x4,%ebx
		for (int i = 0; i < 5; ++i)	 // 练习要求打印5个参数
f0100940:	39 f3                	cmp    %esi,%ebx
f0100942:	75 e7                	jne    f010092b <mon_backtrace+0x30>
		cprintf("\n");
f0100944:	c7 04 24 22 7d 10 f0 	movl   $0xf0107d22,(%esp)
f010094b:	e8 d5 35 00 00       	call   f0103f25 <cprintf>

		// 显示每个%eip对应的函数名、源文件名和行号
		struct Eipdebuginfo info;
		if (!debuginfo_eip(eip, &info)) // 读取debug信息，找到信息，则debuginfo_eip返回0
f0100950:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100953:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100957:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010095a:	89 34 24             	mov    %esi,(%esp)
f010095d:	e8 38 49 00 00       	call   f010529a <debuginfo_eip>
f0100962:	85 c0                	test   %eax,%eax
f0100964:	75 3e                	jne    f01009a4 <mon_backtrace+0xa9>
			cprintf("%s: %d: %.*s+%d\n",
f0100966:	89 f0                	mov    %esi,%eax
f0100968:	2b 45 e0             	sub    -0x20(%ebp),%eax
f010096b:	89 44 24 14          	mov    %eax,0x14(%esp)
f010096f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100972:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100976:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100979:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010097d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100980:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100984:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100987:	89 44 24 04          	mov    %eax,0x4(%esp)
f010098b:	c7 04 24 b8 6e 10 f0 	movl   $0xf0106eb8,(%esp)
f0100992:	e8 8e 35 00 00       	call   f0103f25 <cprintf>
					info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, eip - info.eip_fn_addr);
		else // 找不到信息，即到达stack的顶部
			break;

		// 更新指针
		ebp = (int *)*ebp; // *ebp得到压进堆栈的上一个函数的%ebp
f0100997:	8b 3f                	mov    (%edi),%edi
		eip = ebp[1];
f0100999:	8b 47 04             	mov    0x4(%edi),%eax
f010099c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	}
f010099f:	e9 6a ff ff ff       	jmp    f010090e <mon_backtrace+0x13>
	return 0;
}
f01009a4:	b8 00 00 00 00       	mov    $0x0,%eax
f01009a9:	83 c4 4c             	add    $0x4c,%esp
f01009ac:	5b                   	pop    %ebx
f01009ad:	5e                   	pop    %esi
f01009ae:	5f                   	pop    %edi
f01009af:	5d                   	pop    %ebp
f01009b0:	c3                   	ret    

f01009b1 <monitor>:
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void monitor(struct Trapframe *tf)
{
f01009b1:	55                   	push   %ebp
f01009b2:	89 e5                	mov    %esp,%ebp
f01009b4:	57                   	push   %edi
f01009b5:	56                   	push   %esi
f01009b6:	53                   	push   %ebx
f01009b7:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009ba:	c7 04 24 14 70 10 f0 	movl   $0xf0107014,(%esp)
f01009c1:	e8 5f 35 00 00       	call   f0103f25 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009c6:	c7 04 24 38 70 10 f0 	movl   $0xf0107038,(%esp)
f01009cd:	e8 53 35 00 00       	call   f0103f25 <cprintf>

	if (tf != NULL)
f01009d2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01009d6:	74 0b                	je     f01009e3 <monitor+0x32>
		print_trapframe(tf);
f01009d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01009db:	89 04 24             	mov    %eax,(%esp)
f01009de:	e8 d1 3a 00 00       	call   f01044b4 <print_trapframe>
	while (1)
	{
		buf = readline("K> ");
f01009e3:	c7 04 24 c9 6e 10 f0 	movl   $0xf0106ec9,(%esp)
f01009ea:	e8 a1 51 00 00       	call   f0105b90 <readline>
f01009ef:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009f1:	85 c0                	test   %eax,%eax
f01009f3:	74 ee                	je     f01009e3 <monitor+0x32>
	argv[argc] = 0;
f01009f5:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009fc:	be 00 00 00 00       	mov    $0x0,%esi
f0100a01:	eb 0a                	jmp    f0100a0d <monitor+0x5c>
			*buf++ = 0;
f0100a03:	c6 03 00             	movb   $0x0,(%ebx)
f0100a06:	89 f7                	mov    %esi,%edi
f0100a08:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a0b:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100a0d:	0f b6 03             	movzbl (%ebx),%eax
f0100a10:	84 c0                	test   %al,%al
f0100a12:	74 63                	je     f0100a77 <monitor+0xc6>
f0100a14:	0f be c0             	movsbl %al,%eax
f0100a17:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a1b:	c7 04 24 cd 6e 10 f0 	movl   $0xf0106ecd,(%esp)
f0100a22:	e8 83 53 00 00       	call   f0105daa <strchr>
f0100a27:	85 c0                	test   %eax,%eax
f0100a29:	75 d8                	jne    f0100a03 <monitor+0x52>
		if (*buf == 0)
f0100a2b:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a2e:	74 47                	je     f0100a77 <monitor+0xc6>
		if (argc == MAXARGS - 1)
f0100a30:	83 fe 0f             	cmp    $0xf,%esi
f0100a33:	75 16                	jne    f0100a4b <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a35:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100a3c:	00 
f0100a3d:	c7 04 24 d2 6e 10 f0 	movl   $0xf0106ed2,(%esp)
f0100a44:	e8 dc 34 00 00       	call   f0103f25 <cprintf>
f0100a49:	eb 98                	jmp    f01009e3 <monitor+0x32>
		argv[argc++] = buf;
f0100a4b:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a4e:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a52:	eb 03                	jmp    f0100a57 <monitor+0xa6>
			buf++;
f0100a54:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a57:	0f b6 03             	movzbl (%ebx),%eax
f0100a5a:	84 c0                	test   %al,%al
f0100a5c:	74 ad                	je     f0100a0b <monitor+0x5a>
f0100a5e:	0f be c0             	movsbl %al,%eax
f0100a61:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a65:	c7 04 24 cd 6e 10 f0 	movl   $0xf0106ecd,(%esp)
f0100a6c:	e8 39 53 00 00       	call   f0105daa <strchr>
f0100a71:	85 c0                	test   %eax,%eax
f0100a73:	74 df                	je     f0100a54 <monitor+0xa3>
f0100a75:	eb 94                	jmp    f0100a0b <monitor+0x5a>
	argv[argc] = 0;
f0100a77:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a7e:	00 
	if (argc == 0)
f0100a7f:	85 f6                	test   %esi,%esi
f0100a81:	0f 84 5c ff ff ff    	je     f01009e3 <monitor+0x32>
f0100a87:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100a8c:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a8f:	8b 04 85 60 70 10 f0 	mov    -0xfef8fa0(,%eax,4),%eax
f0100a96:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a9a:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a9d:	89 04 24             	mov    %eax,(%esp)
f0100aa0:	e8 a7 52 00 00       	call   f0105d4c <strcmp>
f0100aa5:	85 c0                	test   %eax,%eax
f0100aa7:	75 24                	jne    f0100acd <monitor+0x11c>
			return commands[i].func(argc, argv, tf);
f0100aa9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100aac:	8b 55 08             	mov    0x8(%ebp),%edx
f0100aaf:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100ab3:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100ab6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100aba:	89 34 24             	mov    %esi,(%esp)
f0100abd:	ff 14 85 68 70 10 f0 	call   *-0xfef8f98(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100ac4:	85 c0                	test   %eax,%eax
f0100ac6:	78 25                	js     f0100aed <monitor+0x13c>
f0100ac8:	e9 16 ff ff ff       	jmp    f01009e3 <monitor+0x32>
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f0100acd:	83 c3 01             	add    $0x1,%ebx
f0100ad0:	83 fb 03             	cmp    $0x3,%ebx
f0100ad3:	75 b7                	jne    f0100a8c <monitor+0xdb>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100ad5:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100ad8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100adc:	c7 04 24 ef 6e 10 f0 	movl   $0xf0106eef,(%esp)
f0100ae3:	e8 3d 34 00 00       	call   f0103f25 <cprintf>
f0100ae8:	e9 f6 fe ff ff       	jmp    f01009e3 <monitor+0x32>
				break;
	}
}
f0100aed:	83 c4 5c             	add    $0x5c,%esp
f0100af0:	5b                   	pop    %ebx
f0100af1:	5e                   	pop    %esi
f0100af2:	5f                   	pop    %edi
f0100af3:	5d                   	pop    %ebp
f0100af4:	c3                   	ret    
f0100af5:	66 90                	xchg   %ax,%ax
f0100af7:	66 90                	xchg   %ax,%ax
f0100af9:	66 90                	xchg   %ax,%ax
f0100afb:	66 90                	xchg   %ax,%ax
f0100afd:	66 90                	xchg   %ax,%ax
f0100aff:	90                   	nop

f0100b00 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100b00:	55                   	push   %ebp
f0100b01:	89 e5                	mov    %esp,%ebp
f0100b03:	56                   	push   %esi
f0100b04:	53                   	push   %ebx
f0100b05:	83 ec 10             	sub    $0x10,%esp
f0100b08:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b0a:	89 04 24             	mov    %eax,(%esp)
f0100b0d:	e8 aa 32 00 00       	call   f0103dbc <mc146818_read>
f0100b12:	89 c6                	mov    %eax,%esi
f0100b14:	83 c3 01             	add    $0x1,%ebx
f0100b17:	89 1c 24             	mov    %ebx,(%esp)
f0100b1a:	e8 9d 32 00 00       	call   f0103dbc <mc146818_read>
f0100b1f:	c1 e0 08             	shl    $0x8,%eax
f0100b22:	09 f0                	or     %esi,%eax
}
f0100b24:	83 c4 10             	add    $0x10,%esp
f0100b27:	5b                   	pop    %ebx
f0100b28:	5e                   	pop    %esi
f0100b29:	5d                   	pop    %ebp
f0100b2a:	c3                   	ret    

f0100b2b <boot_alloc>:
boot_alloc(uint32_t n)
{
	static char *nextfree; // virtual address of next byte of free memory，static意味着nextfree不会随着函数返回被重置，是全局变量
	char *result;

	if (!nextfree) // nextfree初始化，只有第一次运行会执行
f0100b2b:	83 3d 38 02 23 f0 00 	cmpl   $0x0,0xf0230238
f0100b32:	75 11                	jne    f0100b45 <boot_alloc+0x1a>
	{
		extern char end[]; // linker会获取内核代码的最后一个字节的位置，将end指向这个地址，因此end指向内核代码结尾

		nextfree = ROUNDUP((char *)end, PGSIZE); // 内核使用的第一块内存必须远离内核代码结尾
f0100b34:	ba 07 30 27 f0       	mov    $0xf0273007,%edx
f0100b39:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b3f:	89 15 38 02 23 f0    	mov    %edx,0xf0230238
		 * 假设end是4097，ROUNDUP(end, PGSIZE)得到end=4096*2，这样才能容纳4097
		 */
	}

	// LAB 2: Your code here.
	if (n == 0) // 不分配内存，直接返回
f0100b45:	85 c0                	test   %eax,%eax
f0100b47:	75 06                	jne    f0100b4f <boot_alloc+0x24>
	{
		return nextfree;
f0100b49:	a1 38 02 23 f0       	mov    0xf0230238,%eax
f0100b4e:	c3                   	ret    
	}

	// n是无符号数，不考虑<0情形
	result = nextfree;				// 将更新前的nextfree赋给result
f0100b4f:	8b 0d 38 02 23 f0    	mov    0xf0230238,%ecx
	nextfree += ROUNDUP(n, PGSIZE); // +=:在原来的基础上再分配
f0100b55:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100b5b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b61:	01 ca                	add    %ecx,%edx
f0100b63:	89 15 38 02 23 f0    	mov    %edx,0xf0230238

	// 如果内存不足，boot_alloc应该会死机
	if (nextfree > (char *)0xf0400000) // >4MB
f0100b69:	81 fa 00 00 40 f0    	cmp    $0xf0400000,%edx
f0100b6f:	76 22                	jbe    f0100b93 <boot_alloc+0x68>
{
f0100b71:	55                   	push   %ebp
f0100b72:	89 e5                	mov    %esp,%ebp
f0100b74:	83 ec 18             	sub    $0x18,%esp
	{
		panic("out of memory(4MB) : boot_alloc() in pmap.c \n"); // 调用预先定义的assert
f0100b77:	c7 44 24 08 84 70 10 	movl   $0xf0107084,0x8(%esp)
f0100b7e:	f0 
f0100b7f:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
f0100b86:	00 
f0100b87:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0100b8e:	e8 ad f4 ff ff       	call   f0100040 <_panic>
		nextfree = result;										 // 分配失败，回调nextfree
		return NULL;
	}
	return result;
f0100b93:	89 c8                	mov    %ecx,%eax
}
f0100b95:	c3                   	ret    

f0100b96 <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b96:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f0100b9c:	c1 f8 03             	sar    $0x3,%eax
f0100b9f:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100ba2:	89 c2                	mov    %eax,%edx
f0100ba4:	c1 ea 0c             	shr    $0xc,%edx
f0100ba7:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f0100bad:	72 26                	jb     f0100bd5 <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100baf:	55                   	push   %ebp
f0100bb0:	89 e5                	mov    %esp,%ebp
f0100bb2:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bb5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bb9:	c7 44 24 08 44 6b 10 	movl   $0xf0106b44,0x8(%esp)
f0100bc0:	f0 
f0100bc1:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100bc8:	00 
f0100bc9:	c7 04 24 a5 7a 10 f0 	movl   $0xf0107aa5,(%esp)
f0100bd0:	e8 6b f4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100bd5:	2d 00 00 00 10       	sub    $0x10000000,%eax
	return KADDR(page2pa(pp));
}
f0100bda:	c3                   	ret    

f0100bdb <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100bdb:	89 d1                	mov    %edx,%ecx
f0100bdd:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100be0:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100be3:	a8 01                	test   $0x1,%al
f0100be5:	74 5d                	je     f0100c44 <check_va2pa+0x69>
		return ~0;
	p = (pte_t *)KADDR(PTE_ADDR(*pgdir));
f0100be7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100bec:	89 c1                	mov    %eax,%ecx
f0100bee:	c1 e9 0c             	shr    $0xc,%ecx
f0100bf1:	3b 0d 88 0e 23 f0    	cmp    0xf0230e88,%ecx
f0100bf7:	72 26                	jb     f0100c1f <check_va2pa+0x44>
{
f0100bf9:	55                   	push   %ebp
f0100bfa:	89 e5                	mov    %esp,%ebp
f0100bfc:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bff:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c03:	c7 44 24 08 44 6b 10 	movl   $0xf0106b44,0x8(%esp)
f0100c0a:	f0 
f0100c0b:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0100c12:	00 
f0100c13:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0100c1a:	e8 21 f4 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100c1f:	c1 ea 0c             	shr    $0xc,%edx
f0100c22:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100c28:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100c2f:	89 c2                	mov    %eax,%edx
f0100c31:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100c34:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c39:	85 d2                	test   %edx,%edx
f0100c3b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100c40:	0f 44 c2             	cmove  %edx,%eax
f0100c43:	c3                   	ret    
		return ~0;
f0100c44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100c49:	c3                   	ret    

f0100c4a <check_page_free_list>:
{
f0100c4a:	55                   	push   %ebp
f0100c4b:	89 e5                	mov    %esp,%ebp
f0100c4d:	57                   	push   %edi
f0100c4e:	56                   	push   %esi
f0100c4f:	53                   	push   %ebx
f0100c50:	83 ec 4c             	sub    $0x4c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c53:	84 c0                	test   %al,%al
f0100c55:	0f 85 3f 03 00 00    	jne    f0100f9a <check_page_free_list+0x350>
f0100c5b:	e9 4c 03 00 00       	jmp    f0100fac <check_page_free_list+0x362>
		panic("'page_free_list' is a null pointer!");
f0100c60:	c7 44 24 08 b4 70 10 	movl   $0xf01070b4,0x8(%esp)
f0100c67:	f0 
f0100c68:	c7 44 24 04 4e 02 00 	movl   $0x24e,0x4(%esp)
f0100c6f:	00 
f0100c70:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0100c77:	e8 c4 f3 ff ff       	call   f0100040 <_panic>
		struct PageInfo **tp[2] = {&pp1, &pp2};
f0100c7c:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100c7f:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100c82:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100c85:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100c88:	89 c2                	mov    %eax,%edx
f0100c8a:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100c90:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100c96:	0f 95 c2             	setne  %dl
f0100c99:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100c9c:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100ca0:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100ca2:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ca6:	8b 00                	mov    (%eax),%eax
f0100ca8:	85 c0                	test   %eax,%eax
f0100caa:	75 dc                	jne    f0100c88 <check_page_free_list+0x3e>
		*tp[1] = 0;
f0100cac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100caf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100cb5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cb8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100cbb:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100cbd:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100cc0:	a3 40 02 23 f0       	mov    %eax,0xf0230240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cc5:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100cca:	8b 1d 40 02 23 f0    	mov    0xf0230240,%ebx
f0100cd0:	eb 63                	jmp    f0100d35 <check_page_free_list+0xeb>
f0100cd2:	89 d8                	mov    %ebx,%eax
f0100cd4:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f0100cda:	c1 f8 03             	sar    $0x3,%eax
f0100cdd:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100ce0:	89 c2                	mov    %eax,%edx
f0100ce2:	c1 ea 16             	shr    $0x16,%edx
f0100ce5:	39 f2                	cmp    %esi,%edx
f0100ce7:	73 4a                	jae    f0100d33 <check_page_free_list+0xe9>
	if (PGNUM(pa) >= npages)
f0100ce9:	89 c2                	mov    %eax,%edx
f0100ceb:	c1 ea 0c             	shr    $0xc,%edx
f0100cee:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f0100cf4:	72 20                	jb     f0100d16 <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cf6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100cfa:	c7 44 24 08 44 6b 10 	movl   $0xf0106b44,0x8(%esp)
f0100d01:	f0 
f0100d02:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100d09:	00 
f0100d0a:	c7 04 24 a5 7a 10 f0 	movl   $0xf0107aa5,(%esp)
f0100d11:	e8 2a f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100d16:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100d1d:	00 
f0100d1e:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100d25:	00 
	return (void *)(pa + KERNBASE);
f0100d26:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d2b:	89 04 24             	mov    %eax,(%esp)
f0100d2e:	e8 b4 50 00 00       	call   f0105de7 <memset>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d33:	8b 1b                	mov    (%ebx),%ebx
f0100d35:	85 db                	test   %ebx,%ebx
f0100d37:	75 99                	jne    f0100cd2 <check_page_free_list+0x88>
	first_free_page = (char *)boot_alloc(0);
f0100d39:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d3e:	e8 e8 fd ff ff       	call   f0100b2b <boot_alloc>
f0100d43:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d46:	8b 15 40 02 23 f0    	mov    0xf0230240,%edx
		assert(pp >= pages);
f0100d4c:	8b 0d 90 0e 23 f0    	mov    0xf0230e90,%ecx
		assert(pp < pages + npages);
f0100d52:	a1 88 0e 23 f0       	mov    0xf0230e88,%eax
f0100d57:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100d5a:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100d5d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0100d60:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100d63:	bf 00 00 00 00       	mov    $0x0,%edi
f0100d68:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d6b:	e9 c4 01 00 00       	jmp    f0100f34 <check_page_free_list+0x2ea>
		assert(pp >= pages);
f0100d70:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100d73:	73 24                	jae    f0100d99 <check_page_free_list+0x14f>
f0100d75:	c7 44 24 0c b3 7a 10 	movl   $0xf0107ab3,0xc(%esp)
f0100d7c:	f0 
f0100d7d:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0100d84:	f0 
f0100d85:	c7 44 24 04 6b 02 00 	movl   $0x26b,0x4(%esp)
f0100d8c:	00 
f0100d8d:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0100d94:	e8 a7 f2 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100d99:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100d9c:	72 24                	jb     f0100dc2 <check_page_free_list+0x178>
f0100d9e:	c7 44 24 0c d4 7a 10 	movl   $0xf0107ad4,0xc(%esp)
f0100da5:	f0 
f0100da6:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0100dad:	f0 
f0100dae:	c7 44 24 04 6c 02 00 	movl   $0x26c,0x4(%esp)
f0100db5:	00 
f0100db6:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0100dbd:	e8 7e f2 ff ff       	call   f0100040 <_panic>
		assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0100dc2:	89 d0                	mov    %edx,%eax
f0100dc4:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0100dc7:	a8 07                	test   $0x7,%al
f0100dc9:	74 24                	je     f0100def <check_page_free_list+0x1a5>
f0100dcb:	c7 44 24 0c d8 70 10 	movl   $0xf01070d8,0xc(%esp)
f0100dd2:	f0 
f0100dd3:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0100dda:	f0 
f0100ddb:	c7 44 24 04 6d 02 00 	movl   $0x26d,0x4(%esp)
f0100de2:	00 
f0100de3:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0100dea:	e8 51 f2 ff ff       	call   f0100040 <_panic>
	return (pp - pages) << PGSHIFT;
f0100def:	c1 f8 03             	sar    $0x3,%eax
f0100df2:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100df5:	85 c0                	test   %eax,%eax
f0100df7:	75 24                	jne    f0100e1d <check_page_free_list+0x1d3>
f0100df9:	c7 44 24 0c e8 7a 10 	movl   $0xf0107ae8,0xc(%esp)
f0100e00:	f0 
f0100e01:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0100e08:	f0 
f0100e09:	c7 44 24 04 70 02 00 	movl   $0x270,0x4(%esp)
f0100e10:	00 
f0100e11:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0100e18:	e8 23 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e1d:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e22:	75 24                	jne    f0100e48 <check_page_free_list+0x1fe>
f0100e24:	c7 44 24 0c f9 7a 10 	movl   $0xf0107af9,0xc(%esp)
f0100e2b:	f0 
f0100e2c:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0100e33:	f0 
f0100e34:	c7 44 24 04 71 02 00 	movl   $0x271,0x4(%esp)
f0100e3b:	00 
f0100e3c:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0100e43:	e8 f8 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e48:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100e4d:	75 24                	jne    f0100e73 <check_page_free_list+0x229>
f0100e4f:	c7 44 24 0c 08 71 10 	movl   $0xf0107108,0xc(%esp)
f0100e56:	f0 
f0100e57:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0100e5e:	f0 
f0100e5f:	c7 44 24 04 72 02 00 	movl   $0x272,0x4(%esp)
f0100e66:	00 
f0100e67:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0100e6e:	e8 cd f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e73:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e78:	75 24                	jne    f0100e9e <check_page_free_list+0x254>
f0100e7a:	c7 44 24 0c 12 7b 10 	movl   $0xf0107b12,0xc(%esp)
f0100e81:	f0 
f0100e82:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0100e89:	f0 
f0100e8a:	c7 44 24 04 73 02 00 	movl   $0x273,0x4(%esp)
f0100e91:	00 
f0100e92:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0100e99:	e8 a2 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f0100e9e:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ea3:	0f 86 2a 01 00 00    	jbe    f0100fd3 <check_page_free_list+0x389>
	if (PGNUM(pa) >= npages)
f0100ea9:	89 c1                	mov    %eax,%ecx
f0100eab:	c1 e9 0c             	shr    $0xc,%ecx
f0100eae:	39 4d c4             	cmp    %ecx,-0x3c(%ebp)
f0100eb1:	77 20                	ja     f0100ed3 <check_page_free_list+0x289>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100eb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100eb7:	c7 44 24 08 44 6b 10 	movl   $0xf0106b44,0x8(%esp)
f0100ebe:	f0 
f0100ebf:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100ec6:	00 
f0100ec7:	c7 04 24 a5 7a 10 f0 	movl   $0xf0107aa5,(%esp)
f0100ece:	e8 6d f1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100ed3:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f0100ed9:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100edc:	0f 86 e1 00 00 00    	jbe    f0100fc3 <check_page_free_list+0x379>
f0100ee2:	c7 44 24 0c 2c 71 10 	movl   $0xf010712c,0xc(%esp)
f0100ee9:	f0 
f0100eea:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0100ef1:	f0 
f0100ef2:	c7 44 24 04 74 02 00 	movl   $0x274,0x4(%esp)
f0100ef9:	00 
f0100efa:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0100f01:	e8 3a f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100f06:	c7 44 24 0c 2c 7b 10 	movl   $0xf0107b2c,0xc(%esp)
f0100f0d:	f0 
f0100f0e:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0100f15:	f0 
f0100f16:	c7 44 24 04 76 02 00 	movl   $0x276,0x4(%esp)
f0100f1d:	00 
f0100f1e:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0100f25:	e8 16 f1 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100f2a:	83 c3 01             	add    $0x1,%ebx
f0100f2d:	eb 03                	jmp    f0100f32 <check_page_free_list+0x2e8>
			++nfree_extmem;
f0100f2f:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f32:	8b 12                	mov    (%edx),%edx
f0100f34:	85 d2                	test   %edx,%edx
f0100f36:	0f 85 34 fe ff ff    	jne    f0100d70 <check_page_free_list+0x126>
	assert(nfree_basemem > 0);
f0100f3c:	85 db                	test   %ebx,%ebx
f0100f3e:	7f 24                	jg     f0100f64 <check_page_free_list+0x31a>
f0100f40:	c7 44 24 0c 49 7b 10 	movl   $0xf0107b49,0xc(%esp)
f0100f47:	f0 
f0100f48:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0100f4f:	f0 
f0100f50:	c7 44 24 04 7e 02 00 	movl   $0x27e,0x4(%esp)
f0100f57:	00 
f0100f58:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0100f5f:	e8 dc f0 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100f64:	85 ff                	test   %edi,%edi
f0100f66:	7f 24                	jg     f0100f8c <check_page_free_list+0x342>
f0100f68:	c7 44 24 0c 5b 7b 10 	movl   $0xf0107b5b,0xc(%esp)
f0100f6f:	f0 
f0100f70:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0100f77:	f0 
f0100f78:	c7 44 24 04 7f 02 00 	movl   $0x27f,0x4(%esp)
f0100f7f:	00 
f0100f80:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0100f87:	e8 b4 f0 ff ff       	call   f0100040 <_panic>
	cprintf("check_page_free_list() succeeded!\n");
f0100f8c:	c7 04 24 70 71 10 f0 	movl   $0xf0107170,(%esp)
f0100f93:	e8 8d 2f 00 00       	call   f0103f25 <cprintf>
f0100f98:	eb 4b                	jmp    f0100fe5 <check_page_free_list+0x39b>
	if (!page_free_list)
f0100f9a:	a1 40 02 23 f0       	mov    0xf0230240,%eax
f0100f9f:	85 c0                	test   %eax,%eax
f0100fa1:	0f 85 d5 fc ff ff    	jne    f0100c7c <check_page_free_list+0x32>
f0100fa7:	e9 b4 fc ff ff       	jmp    f0100c60 <check_page_free_list+0x16>
f0100fac:	83 3d 40 02 23 f0 00 	cmpl   $0x0,0xf0230240
f0100fb3:	0f 84 a7 fc ff ff    	je     f0100c60 <check_page_free_list+0x16>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100fb9:	be 00 04 00 00       	mov    $0x400,%esi
f0100fbe:	e9 07 fd ff ff       	jmp    f0100cca <check_page_free_list+0x80>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100fc3:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100fc8:	0f 85 61 ff ff ff    	jne    f0100f2f <check_page_free_list+0x2e5>
f0100fce:	e9 33 ff ff ff       	jmp    f0100f06 <check_page_free_list+0x2bc>
f0100fd3:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100fd8:	0f 85 4c ff ff ff    	jne    f0100f2a <check_page_free_list+0x2e0>
f0100fde:	66 90                	xchg   %ax,%ax
f0100fe0:	e9 21 ff ff ff       	jmp    f0100f06 <check_page_free_list+0x2bc>
}
f0100fe5:	83 c4 4c             	add    $0x4c,%esp
f0100fe8:	5b                   	pop    %ebx
f0100fe9:	5e                   	pop    %esi
f0100fea:	5f                   	pop    %edi
f0100feb:	5d                   	pop    %ebp
f0100fec:	c3                   	ret    

f0100fed <page_init>:
{
f0100fed:	55                   	push   %ebp
f0100fee:	89 e5                	mov    %esp,%ebp
f0100ff0:	57                   	push   %edi
f0100ff1:	56                   	push   %esi
f0100ff2:	53                   	push   %ebx
f0100ff3:	83 ec 1c             	sub    $0x1c,%esp
	page_free_list = NULL; // page_free_list是static的，不会被初始化，必须给一个初始值
f0100ff6:	c7 05 40 02 23 f0 00 	movl   $0x0,0xf0230240
f0100ffd:	00 00 00 
	if (PGNUM(pa) >= npages)
f0101000:	83 3d 88 0e 23 f0 07 	cmpl   $0x7,0xf0230e88
f0101007:	77 1c                	ja     f0101025 <page_init+0x38>
		panic("pa2page called with invalid pa");
f0101009:	c7 44 24 08 94 71 10 	movl   $0xf0107194,0x8(%esp)
f0101010:	f0 
f0101011:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101018:	00 
f0101019:	c7 04 24 a5 7a 10 f0 	movl   $0xf0107aa5,(%esp)
f0101020:	e8 1b f0 ff ff       	call   f0100040 <_panic>
	struct PageInfo *mp_entry_page = pa2page(MPENTRY_PADDR); // mp的入口程序只需要一页
f0101025:	a1 90 0e 23 f0       	mov    0xf0230e90,%eax
f010102a:	8d 78 38             	lea    0x38(%eax),%edi
	for (int i = 1; i < npages_basemem; i++) // 将内存中的pages数组初始化为链表，头指针是page_free_list
f010102d:	8b 35 44 02 23 f0    	mov    0xf0230244,%esi
f0101033:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101038:	b8 01 00 00 00       	mov    $0x1,%eax
f010103d:	eb 2d                	jmp    f010106c <page_init+0x7f>
f010103f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		if (pages + i == mp_entry_page)
f0101046:	89 d1                	mov    %edx,%ecx
f0101048:	03 0d 90 0e 23 f0    	add    0xf0230e90,%ecx
f010104e:	39 f9                	cmp    %edi,%ecx
f0101050:	74 17                	je     f0101069 <page_init+0x7c>
		pages[i].pp_ref = 0;
f0101052:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0101058:	8b 0d 90 0e 23 f0    	mov    0xf0230e90,%ecx
f010105e:	89 1c c1             	mov    %ebx,(%ecx,%eax,8)
		page_free_list = &pages[i]; // pages中包含了整个内存中的页，page_free_list指向其中空闲的页组成的链表的头部
f0101061:	03 15 90 0e 23 f0    	add    0xf0230e90,%edx
f0101067:	89 d3                	mov    %edx,%ebx
	for (int i = 1; i < npages_basemem; i++) // 将内存中的pages数组初始化为链表，头指针是page_free_list
f0101069:	83 c0 01             	add    $0x1,%eax
f010106c:	39 c6                	cmp    %eax,%esi
f010106e:	77 cf                	ja     f010103f <page_init+0x52>
f0101070:	89 1d 40 02 23 f0    	mov    %ebx,0xf0230240
	for (int i = PGNUM(PADDR(boot_alloc(0))); i < npages; i++) // PADDR()将虚拟地址转化为物理地址，boot_alloc(0)得到nextfree的位置(即pages end),PGNUM()求出需要几页才能到达该地址
f0101076:	b8 00 00 00 00       	mov    $0x0,%eax
f010107b:	e8 ab fa ff ff       	call   f0100b2b <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0101080:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101085:	77 20                	ja     f01010a7 <page_init+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101087:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010108b:	c7 44 24 08 68 6b 10 	movl   $0xf0106b68,0x8(%esp)
f0101092:	f0 
f0101093:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
f010109a:	00 
f010109b:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01010a2:	e8 99 ef ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01010a7:	05 00 00 00 10       	add    $0x10000000,%eax
f01010ac:	c1 e8 0c             	shr    $0xc,%eax
f01010af:	89 c2                	mov    %eax,%edx
f01010b1:	8b 1d 40 02 23 f0    	mov    0xf0230240,%ebx
f01010b7:	c1 e0 03             	shl    $0x3,%eax
f01010ba:	eb 1e                	jmp    f01010da <page_init+0xed>
		pages[i].pp_ref = 0;
f01010bc:	89 c1                	mov    %eax,%ecx
f01010be:	03 0d 90 0e 23 f0    	add    0xf0230e90,%ecx
f01010c4:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f01010ca:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f01010cc:	89 c3                	mov    %eax,%ebx
f01010ce:	03 1d 90 0e 23 f0    	add    0xf0230e90,%ebx
	for (int i = PGNUM(PADDR(boot_alloc(0))); i < npages; i++) // PADDR()将虚拟地址转化为物理地址，boot_alloc(0)得到nextfree的位置(即pages end),PGNUM()求出需要几页才能到达该地址
f01010d4:	83 c2 01             	add    $0x1,%edx
f01010d7:	83 c0 08             	add    $0x8,%eax
f01010da:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f01010e0:	72 da                	jb     f01010bc <page_init+0xcf>
f01010e2:	89 1d 40 02 23 f0    	mov    %ebx,0xf0230240
}
f01010e8:	83 c4 1c             	add    $0x1c,%esp
f01010eb:	5b                   	pop    %ebx
f01010ec:	5e                   	pop    %esi
f01010ed:	5f                   	pop    %edi
f01010ee:	5d                   	pop    %ebp
f01010ef:	c3                   	ret    

f01010f0 <page_alloc>:
{
f01010f0:	55                   	push   %ebp
f01010f1:	89 e5                	mov    %esp,%ebp
f01010f3:	53                   	push   %ebx
f01010f4:	83 ec 14             	sub    $0x14,%esp
	if (page_free_list) // page_free_list指向空闲页组成的链表的头部
f01010f7:	8b 1d 40 02 23 f0    	mov    0xf0230240,%ebx
f01010fd:	85 db                	test   %ebx,%ebx
f01010ff:	74 75                	je     f0101176 <page_alloc+0x86>
		page_free_list = page_free_list->pp_link; // 链表next行进
f0101101:	8b 03                	mov    (%ebx),%eax
f0101103:	a3 40 02 23 f0       	mov    %eax,0xf0230240
		if (alloc_flags & ALLOC_ZERO)
f0101108:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010110c:	74 58                	je     f0101166 <page_alloc+0x76>
	return (pp - pages) << PGSHIFT;
f010110e:	89 d8                	mov    %ebx,%eax
f0101110:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f0101116:	c1 f8 03             	sar    $0x3,%eax
f0101119:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010111c:	89 c2                	mov    %eax,%edx
f010111e:	c1 ea 0c             	shr    $0xc,%edx
f0101121:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f0101127:	72 20                	jb     f0101149 <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101129:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010112d:	c7 44 24 08 44 6b 10 	movl   $0xf0106b44,0x8(%esp)
f0101134:	f0 
f0101135:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010113c:	00 
f010113d:	c7 04 24 a5 7a 10 f0 	movl   $0xf0107aa5,(%esp)
f0101144:	e8 f7 ee ff ff       	call   f0100040 <_panic>
			memset(page2kva(result), 0, PGSIZE); // page2kva(p)：求得页p的地址，方法就是先求出p的索引i，用i*4096得到地址
f0101149:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101150:	00 
f0101151:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101158:	00 
	return (void *)(pa + KERNBASE);
f0101159:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010115e:	89 04 24             	mov    %eax,(%esp)
f0101161:	e8 81 4c 00 00       	call   f0105de7 <memset>
		result->pp_ref = 0;
f0101166:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
		result->pp_link = NULL; // 确保page_free就可以检查错误
f010116c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return result;
f0101172:	89 d8                	mov    %ebx,%eax
f0101174:	eb 05                	jmp    f010117b <page_alloc+0x8b>
		return NULL;
f0101176:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010117b:	83 c4 14             	add    $0x14,%esp
f010117e:	5b                   	pop    %ebx
f010117f:	5d                   	pop    %ebp
f0101180:	c3                   	ret    

f0101181 <page_free>:
{
f0101181:	55                   	push   %ebp
f0101182:	89 e5                	mov    %esp,%ebp
f0101184:	83 ec 18             	sub    $0x18,%esp
f0101187:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref != 0 || pp->pp_link != NULL) // 还有人在使用这个page时，调用了释放函数
f010118a:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010118f:	75 05                	jne    f0101196 <page_free+0x15>
f0101191:	83 38 00             	cmpl   $0x0,(%eax)
f0101194:	74 1c                	je     f01011b2 <page_free+0x31>
		panic("can't free this page, this page is in used: page_free() in pmap.c \n");
f0101196:	c7 44 24 08 b4 71 10 	movl   $0xf01071b4,0x8(%esp)
f010119d:	f0 
f010119e:	c7 44 24 04 65 01 00 	movl   $0x165,0x4(%esp)
f01011a5:	00 
f01011a6:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01011ad:	e8 8e ee ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f01011b2:	8b 15 40 02 23 f0    	mov    0xf0230240,%edx
f01011b8:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f01011ba:	a3 40 02 23 f0       	mov    %eax,0xf0230240
}
f01011bf:	c9                   	leave  
f01011c0:	c3                   	ret    

f01011c1 <page_decref>:
{
f01011c1:	55                   	push   %ebp
f01011c2:	89 e5                	mov    %esp,%ebp
f01011c4:	83 ec 18             	sub    $0x18,%esp
f01011c7:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01011ca:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f01011ce:	8d 51 ff             	lea    -0x1(%ecx),%edx
f01011d1:	66 89 50 04          	mov    %dx,0x4(%eax)
f01011d5:	66 85 d2             	test   %dx,%dx
f01011d8:	75 08                	jne    f01011e2 <page_decref+0x21>
		page_free(pp);
f01011da:	89 04 24             	mov    %eax,(%esp)
f01011dd:	e8 9f ff ff ff       	call   f0101181 <page_free>
}
f01011e2:	c9                   	leave  
f01011e3:	c3                   	ret    

f01011e4 <pgdir_walk>:
{
f01011e4:	55                   	push   %ebp
f01011e5:	89 e5                	mov    %esp,%ebp
f01011e7:	56                   	push   %esi
f01011e8:	53                   	push   %ebx
f01011e9:	83 ec 10             	sub    $0x10,%esp
f01011ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pde_t *pde = &pgdir[PDX(va)]; // 先由PDX(va)得到该地址对应的目录索引，并在目录中索引得到对应条目(一个32位地址),解引用pde即可得到对应条目
f01011ef:	89 de                	mov    %ebx,%esi
f01011f1:	c1 ee 16             	shr    $0x16,%esi
f01011f4:	c1 e6 02             	shl    $0x2,%esi
f01011f7:	03 75 08             	add    0x8(%ebp),%esi
	if (*pde & PTE_P) // 当“va”的PTE所在的页存在，该页对应的条目在目录中的值就!=0
f01011fa:	8b 06                	mov    (%esi),%eax
f01011fc:	a8 01                	test   $0x1,%al
f01011fe:	74 47                	je     f0101247 <pgdir_walk+0x63>
		pte_tab = (pte_t *)KADDR(PTE_ADDR(*pde)); // PTE_ADDR()获得该条目对应的页的物理地址，KADDR()把物理地址转为虚拟地址
f0101200:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101205:	89 c2                	mov    %eax,%edx
f0101207:	c1 ea 0c             	shr    $0xc,%edx
f010120a:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f0101210:	72 20                	jb     f0101232 <pgdir_walk+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101212:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101216:	c7 44 24 08 44 6b 10 	movl   $0xf0106b44,0x8(%esp)
f010121d:	f0 
f010121e:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
f0101225:	00 
f0101226:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f010122d:	e8 0e ee ff ff       	call   f0100040 <_panic>
		result = &pte_tab[PTX(va)];				  // 页里存的就是PTE表，用PTX(va)得到页索引，索引到对应的pte的地址
f0101232:	c1 eb 0a             	shr    $0xa,%ebx
f0101235:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f010123b:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0101242:	e9 85 00 00 00       	jmp    f01012cc <pgdir_walk+0xe8>
		if (!create)
f0101247:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010124b:	74 73                	je     f01012c0 <pgdir_walk+0xdc>
		struct PageInfo *pp = page_alloc(ALLOC_ZERO); // 分配新的一页来存储PTE表
f010124d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101254:	e8 97 fe ff ff       	call   f01010f0 <page_alloc>
		if (!pp) // 如果pp == NULL，分配失败
f0101259:	85 c0                	test   %eax,%eax
f010125b:	74 6a                	je     f01012c7 <pgdir_walk+0xe3>
	return (pp - pages) << PGSHIFT;
f010125d:	89 c2                	mov    %eax,%edx
f010125f:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f0101265:	c1 fa 03             	sar    $0x3,%edx
f0101268:	c1 e2 0c             	shl    $0xc,%edx
		*pde = page2pa(pp) | PTE_P | PTE_W | PTE_U; // 更新目录的条目，以指向新分配的页
f010126b:	83 ca 07             	or     $0x7,%edx
f010126e:	89 16                	mov    %edx,(%esi)
		pp->pp_ref++;
f0101270:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0101275:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f010127b:	c1 f8 03             	sar    $0x3,%eax
f010127e:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101281:	89 c2                	mov    %eax,%edx
f0101283:	c1 ea 0c             	shr    $0xc,%edx
f0101286:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f010128c:	72 20                	jb     f01012ae <pgdir_walk+0xca>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010128e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101292:	c7 44 24 08 44 6b 10 	movl   $0xf0106b44,0x8(%esp)
f0101299:	f0 
f010129a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01012a1:	00 
f01012a2:	c7 04 24 a5 7a 10 f0 	movl   $0xf0107aa5,(%esp)
f01012a9:	e8 92 ed ff ff       	call   f0100040 <_panic>
		result = &pte_tab[PTX(va)];
f01012ae:	c1 eb 0a             	shr    $0xa,%ebx
f01012b1:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f01012b7:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f01012be:	eb 0c                	jmp    f01012cc <pgdir_walk+0xe8>
			return NULL;
f01012c0:	b8 00 00 00 00       	mov    $0x0,%eax
f01012c5:	eb 05                	jmp    f01012cc <pgdir_walk+0xe8>
			return NULL;
f01012c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01012cc:	83 c4 10             	add    $0x10,%esp
f01012cf:	5b                   	pop    %ebx
f01012d0:	5e                   	pop    %esi
f01012d1:	5d                   	pop    %ebp
f01012d2:	c3                   	ret    

f01012d3 <page_lookup>:
{
f01012d3:	55                   	push   %ebp
f01012d4:	89 e5                	mov    %esp,%ebp
f01012d6:	53                   	push   %ebx
f01012d7:	83 ec 14             	sub    $0x14,%esp
f01012da:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0); // 得到“va”的PTE的指针
f01012dd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01012e4:	00 
f01012e5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012e8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01012ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01012ef:	89 04 24             	mov    %eax,(%esp)
f01012f2:	e8 ed fe ff ff       	call   f01011e4 <pgdir_walk>
	if (pte == NULL)					   // 若PTE不存在，则“va”没有映射到对应的物理地址
f01012f7:	85 c0                	test   %eax,%eax
f01012f9:	74 3a                	je     f0101335 <page_lookup+0x62>
	if (pte_store)
f01012fb:	85 db                	test   %ebx,%ebx
f01012fd:	74 02                	je     f0101301 <page_lookup+0x2e>
		*pte_store = pte;
f01012ff:	89 03                	mov    %eax,(%ebx)
	return pa2page(PTE_ADDR(*pte)); // PTE_ADDR(*pte)：根据pte得到物理地址，pa2page()：根据物理地址得到页面
f0101301:	8b 00                	mov    (%eax),%eax
	if (PGNUM(pa) >= npages)
f0101303:	c1 e8 0c             	shr    $0xc,%eax
f0101306:	3b 05 88 0e 23 f0    	cmp    0xf0230e88,%eax
f010130c:	72 1c                	jb     f010132a <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f010130e:	c7 44 24 08 94 71 10 	movl   $0xf0107194,0x8(%esp)
f0101315:	f0 
f0101316:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f010131d:	00 
f010131e:	c7 04 24 a5 7a 10 f0 	movl   $0xf0107aa5,(%esp)
f0101325:	e8 16 ed ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010132a:	8b 15 90 0e 23 f0    	mov    0xf0230e90,%edx
f0101330:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0101333:	eb 05                	jmp    f010133a <page_lookup+0x67>
		return NULL;
f0101335:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010133a:	83 c4 14             	add    $0x14,%esp
f010133d:	5b                   	pop    %ebx
f010133e:	5d                   	pop    %ebp
f010133f:	c3                   	ret    

f0101340 <tlb_invalidate>:
{
f0101340:	55                   	push   %ebp
f0101341:	89 e5                	mov    %esp,%ebp
f0101343:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f0101346:	e8 ee 50 00 00       	call   f0106439 <cpunum>
f010134b:	6b c0 74             	imul   $0x74,%eax,%eax
f010134e:	83 b8 28 10 23 f0 00 	cmpl   $0x0,-0xfdcefd8(%eax)
f0101355:	74 16                	je     f010136d <tlb_invalidate+0x2d>
f0101357:	e8 dd 50 00 00       	call   f0106439 <cpunum>
f010135c:	6b c0 74             	imul   $0x74,%eax,%eax
f010135f:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0101365:	8b 55 08             	mov    0x8(%ebp),%edx
f0101368:	39 50 60             	cmp    %edx,0x60(%eax)
f010136b:	75 06                	jne    f0101373 <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010136d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101370:	0f 01 38             	invlpg (%eax)
}
f0101373:	c9                   	leave  
f0101374:	c3                   	ret    

f0101375 <boot_map_region>:
{
f0101375:	55                   	push   %ebp
f0101376:	89 e5                	mov    %esp,%ebp
f0101378:	57                   	push   %edi
f0101379:	56                   	push   %esi
f010137a:	53                   	push   %ebx
f010137b:	83 ec 2c             	sub    $0x2c,%esp
f010137e:	89 c7                	mov    %eax,%edi
f0101380:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101383:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (int i = 0; i < size; i += PGSIZE) // 以页为单位操作映射
f0101386:	bb 00 00 00 00       	mov    $0x0,%ebx
		*pte = (pa + i) | PTE_P | perm;							 // 物理地址写入PTE,完成映射
f010138b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010138e:	83 c8 01             	or     $0x1,%eax
f0101391:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (int i = 0; i < size; i += PGSIZE) // 以页为单位操作映射
f0101394:	eb 36                	jmp    f01013cc <boot_map_region+0x57>
f0101396:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101399:	8d 34 18             	lea    (%eax,%ebx,1),%esi
		tlb_invalidate(pgdir, (void *)va + i);					 // 使TLB无效
f010139c:	89 74 24 04          	mov    %esi,0x4(%esp)
f01013a0:	89 3c 24             	mov    %edi,(%esp)
f01013a3:	e8 98 ff ff ff       	call   f0101340 <tlb_invalidate>
		pte_t *pte = pgdir_walk(pgdir, (const void *)va + i, 1); // 得到虚拟地址对应的pte
f01013a8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01013af:	00 
f01013b0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01013b4:	89 3c 24             	mov    %edi,(%esp)
f01013b7:	e8 28 fe ff ff       	call   f01011e4 <pgdir_walk>
f01013bc:	89 da                	mov    %ebx,%edx
f01013be:	03 55 08             	add    0x8(%ebp),%edx
		*pte = (pa + i) | PTE_P | perm;							 // 物理地址写入PTE,完成映射
f01013c1:	0b 55 dc             	or     -0x24(%ebp),%edx
f01013c4:	89 10                	mov    %edx,(%eax)
	for (int i = 0; i < size; i += PGSIZE) // 以页为单位操作映射
f01013c6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01013cc:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f01013cf:	77 c5                	ja     f0101396 <boot_map_region+0x21>
}
f01013d1:	83 c4 2c             	add    $0x2c,%esp
f01013d4:	5b                   	pop    %ebx
f01013d5:	5e                   	pop    %esi
f01013d6:	5f                   	pop    %edi
f01013d7:	5d                   	pop    %ebp
f01013d8:	c3                   	ret    

f01013d9 <page_remove>:
{
f01013d9:	55                   	push   %ebp
f01013da:	89 e5                	mov    %esp,%ebp
f01013dc:	56                   	push   %esi
f01013dd:	53                   	push   %ebx
f01013de:	83 ec 20             	sub    $0x20,%esp
f01013e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01013e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store); // 得到“va”对应的页面，和指向对应的pte的指针pte_store
f01013e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01013ea:	89 44 24 08          	mov    %eax,0x8(%esp)
f01013ee:	89 74 24 04          	mov    %esi,0x4(%esp)
f01013f2:	89 1c 24             	mov    %ebx,(%esp)
f01013f5:	e8 d9 fe ff ff       	call   f01012d3 <page_lookup>
	if (pp)
f01013fa:	85 c0                	test   %eax,%eax
f01013fc:	74 1d                	je     f010141b <page_remove+0x42>
		page_decref(pp);
f01013fe:	89 04 24             	mov    %eax,(%esp)
f0101401:	e8 bb fd ff ff       	call   f01011c1 <page_decref>
		tlb_invalidate(pgdir, va); // 如果从页表中删除条目，则TLB必须无效
f0101406:	89 74 24 04          	mov    %esi,0x4(%esp)
f010140a:	89 1c 24             	mov    %ebx,(%esp)
f010140d:	e8 2e ff ff ff       	call   f0101340 <tlb_invalidate>
		*pte_store = 0;
f0101412:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101415:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
f010141b:	83 c4 20             	add    $0x20,%esp
f010141e:	5b                   	pop    %ebx
f010141f:	5e                   	pop    %esi
f0101420:	5d                   	pop    %ebp
f0101421:	c3                   	ret    

f0101422 <page_insert>:
{
f0101422:	55                   	push   %ebp
f0101423:	89 e5                	mov    %esp,%ebp
f0101425:	57                   	push   %edi
f0101426:	56                   	push   %esi
f0101427:	53                   	push   %ebx
f0101428:	83 ec 1c             	sub    $0x1c,%esp
f010142b:	8b 75 08             	mov    0x8(%ebp),%esi
f010142e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101431:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1); // 得到pte的指针，create=1,代表有必要会创建新的页
f0101434:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010143b:	00 
f010143c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101440:	89 34 24             	mov    %esi,(%esp)
f0101443:	e8 9c fd ff ff       	call   f01011e4 <pgdir_walk>
	if (pte == NULL)
f0101448:	85 c0                	test   %eax,%eax
f010144a:	74 41                	je     f010148d <page_insert+0x6b>
	pp->pp_ref++;
f010144c:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P)
f0101451:	f6 00 01             	testb  $0x1,(%eax)
f0101454:	74 0c                	je     f0101462 <page_insert+0x40>
		page_remove(pgdir, va);
f0101456:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010145a:	89 34 24             	mov    %esi,(%esp)
f010145d:	e8 77 ff ff ff       	call   f01013d9 <page_remove>
	boot_map_region(pgdir, (uintptr_t)va, PGSIZE, page2pa(pp), perm);
f0101462:	8b 45 14             	mov    0x14(%ebp),%eax
f0101465:	89 44 24 04          	mov    %eax,0x4(%esp)
	return (pp - pages) << PGSHIFT;
f0101469:	2b 1d 90 0e 23 f0    	sub    0xf0230e90,%ebx
f010146f:	c1 fb 03             	sar    $0x3,%ebx
f0101472:	c1 e3 0c             	shl    $0xc,%ebx
f0101475:	89 1c 24             	mov    %ebx,(%esp)
f0101478:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010147d:	89 fa                	mov    %edi,%edx
f010147f:	89 f0                	mov    %esi,%eax
f0101481:	e8 ef fe ff ff       	call   f0101375 <boot_map_region>
	return 0;
f0101486:	b8 00 00 00 00       	mov    $0x0,%eax
f010148b:	eb 05                	jmp    f0101492 <page_insert+0x70>
		return -E_NO_MEM;
f010148d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
f0101492:	83 c4 1c             	add    $0x1c,%esp
f0101495:	5b                   	pop    %ebx
f0101496:	5e                   	pop    %esi
f0101497:	5f                   	pop    %edi
f0101498:	5d                   	pop    %ebp
f0101499:	c3                   	ret    

f010149a <mmio_map_region>:
{
f010149a:	55                   	push   %ebp
f010149b:	89 e5                	mov    %esp,%ebp
f010149d:	53                   	push   %ebx
f010149e:	83 ec 14             	sub    $0x14,%esp
	size = ROUNDUP(size, PGSIZE);
f01014a1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014a4:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01014aa:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base + size > MMIOLIM)
f01014b0:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f01014b6:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f01014b9:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f01014be:	76 1c                	jbe    f01014dc <mmio_map_region+0x42>
		panic("mmio_map_region: out of MMIOLIM!");
f01014c0:	c7 44 24 08 f8 71 10 	movl   $0xf01071f8,0x8(%esp)
f01014c7:	f0 
f01014c8:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
f01014cf:	00 
f01014d0:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01014d7:	e8 64 eb ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD | PTE_PWT | PTE_W);
f01014dc:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f01014e3:	00 
f01014e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01014e7:	89 04 24             	mov    %eax,(%esp)
f01014ea:	89 d9                	mov    %ebx,%ecx
f01014ec:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01014f1:	e8 7f fe ff ff       	call   f0101375 <boot_map_region>
	base += size;
f01014f6:	a1 00 13 12 f0       	mov    0xf0121300,%eax
f01014fb:	01 c3                	add    %eax,%ebx
f01014fd:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300
}
f0101503:	83 c4 14             	add    $0x14,%esp
f0101506:	5b                   	pop    %ebx
f0101507:	5d                   	pop    %ebp
f0101508:	c3                   	ret    

f0101509 <mem_init>:
{
f0101509:	55                   	push   %ebp
f010150a:	89 e5                	mov    %esp,%ebp
f010150c:	57                   	push   %edi
f010150d:	56                   	push   %esi
f010150e:	53                   	push   %ebx
f010150f:	83 ec 4c             	sub    $0x4c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101512:	b8 15 00 00 00       	mov    $0x15,%eax
f0101517:	e8 e4 f5 ff ff       	call   f0100b00 <nvram_read>
f010151c:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010151e:	b8 17 00 00 00       	mov    $0x17,%eax
f0101523:	e8 d8 f5 ff ff       	call   f0100b00 <nvram_read>
f0101528:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010152a:	b8 34 00 00 00       	mov    $0x34,%eax
f010152f:	e8 cc f5 ff ff       	call   f0100b00 <nvram_read>
f0101534:	c1 e0 06             	shl    $0x6,%eax
f0101537:	89 c2                	mov    %eax,%edx
		totalmem = 16 * 1024 + ext16mem;
f0101539:	8d 80 00 40 00 00    	lea    0x4000(%eax),%eax
	if (ext16mem)
f010153f:	85 d2                	test   %edx,%edx
f0101541:	75 0b                	jne    f010154e <mem_init+0x45>
		totalmem = 1 * 1024 + extmem;
f0101543:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101549:	85 f6                	test   %esi,%esi
f010154b:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f010154e:	89 c2                	mov    %eax,%edx
f0101550:	c1 ea 02             	shr    $0x2,%edx
f0101553:	89 15 88 0e 23 f0    	mov    %edx,0xf0230e88
	npages_basemem = basemem / (PGSIZE / 1024);
f0101559:	89 da                	mov    %ebx,%edx
f010155b:	c1 ea 02             	shr    $0x2,%edx
f010155e:	89 15 44 02 23 f0    	mov    %edx,0xf0230244
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101564:	89 c2                	mov    %eax,%edx
f0101566:	29 da                	sub    %ebx,%edx
f0101568:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010156c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101570:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101574:	c7 04 24 1c 72 10 f0 	movl   $0xf010721c,(%esp)
f010157b:	e8 a5 29 00 00       	call   f0103f25 <cprintf>
	kern_pgdir = (pde_t *)boot_alloc(PGSIZE); // 第一次运行，会舍入一部分
f0101580:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101585:	e8 a1 f5 ff ff       	call   f0100b2b <boot_alloc>
f010158a:	a3 8c 0e 23 f0       	mov    %eax,0xf0230e8c
	memset(kern_pgdir, 0, PGSIZE);			  // 内存初始化为0
f010158f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101596:	00 
f0101597:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010159e:	00 
f010159f:	89 04 24             	mov    %eax,(%esp)
f01015a2:	e8 40 48 00 00       	call   f0105de7 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P; // 暂时不需要理解，只需要知道kern_pgdir处有一个页表目录
f01015a7:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01015ac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01015b1:	77 20                	ja     f01015d3 <mem_init+0xca>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01015b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015b7:	c7 44 24 08 68 6b 10 	movl   $0xf0106b68,0x8(%esp)
f01015be:	f0 
f01015bf:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
f01015c6:	00 
f01015c7:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01015ce:	e8 6d ea ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01015d3:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01015d9:	83 ca 05             	or     $0x5,%edx
f01015dc:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *)boot_alloc(npages * sizeof(struct PageInfo)); // sizeof求得PageInfo占多少字节，返回结果记得强转成pages对应的类型
f01015e2:	a1 88 0e 23 f0       	mov    0xf0230e88,%eax
f01015e7:	c1 e0 03             	shl    $0x3,%eax
f01015ea:	e8 3c f5 ff ff       	call   f0100b2b <boot_alloc>
f01015ef:	a3 90 0e 23 f0       	mov    %eax,0xf0230e90
	memset(pages, 0, npages * sizeof(struct PageInfo));						 // memset(d,c,l):从指针d开始，用字符c填充l个长度的内存
f01015f4:	8b 0d 88 0e 23 f0    	mov    0xf0230e88,%ecx
f01015fa:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101601:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101605:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010160c:	00 
f010160d:	89 04 24             	mov    %eax,(%esp)
f0101610:	e8 d2 47 00 00       	call   f0105de7 <memset>
	envs = (struct Env *)boot_alloc(NENV * sizeof(struct Env));
f0101615:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010161a:	e8 0c f5 ff ff       	call   f0100b2b <boot_alloc>
f010161f:	a3 48 02 23 f0       	mov    %eax,0xf0230248
	page_init(); // 初始化之后，所有的内存管理都将通过page_*函数进行
f0101624:	e8 c4 f9 ff ff       	call   f0100fed <page_init>
	check_page_free_list(1);
f0101629:	b8 01 00 00 00       	mov    $0x1,%eax
f010162e:	e8 17 f6 ff ff       	call   f0100c4a <check_page_free_list>
	if (!pages)
f0101633:	83 3d 90 0e 23 f0 00 	cmpl   $0x0,0xf0230e90
f010163a:	75 1c                	jne    f0101658 <mem_init+0x14f>
		panic("'pages' is a null pointer!");
f010163c:	c7 44 24 08 6c 7b 10 	movl   $0xf0107b6c,0x8(%esp)
f0101643:	f0 
f0101644:	c7 44 24 04 91 02 00 	movl   $0x291,0x4(%esp)
f010164b:	00 
f010164c:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101653:	e8 e8 e9 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101658:	a1 40 02 23 f0       	mov    0xf0230240,%eax
f010165d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101662:	eb 05                	jmp    f0101669 <mem_init+0x160>
		++nfree;
f0101664:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101667:	8b 00                	mov    (%eax),%eax
f0101669:	85 c0                	test   %eax,%eax
f010166b:	75 f7                	jne    f0101664 <mem_init+0x15b>
	assert((pp0 = page_alloc(0)));
f010166d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101674:	e8 77 fa ff ff       	call   f01010f0 <page_alloc>
f0101679:	89 c7                	mov    %eax,%edi
f010167b:	85 c0                	test   %eax,%eax
f010167d:	75 24                	jne    f01016a3 <mem_init+0x19a>
f010167f:	c7 44 24 0c 87 7b 10 	movl   $0xf0107b87,0xc(%esp)
f0101686:	f0 
f0101687:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f010168e:	f0 
f010168f:	c7 44 24 04 99 02 00 	movl   $0x299,0x4(%esp)
f0101696:	00 
f0101697:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f010169e:	e8 9d e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01016a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016aa:	e8 41 fa ff ff       	call   f01010f0 <page_alloc>
f01016af:	89 c6                	mov    %eax,%esi
f01016b1:	85 c0                	test   %eax,%eax
f01016b3:	75 24                	jne    f01016d9 <mem_init+0x1d0>
f01016b5:	c7 44 24 0c 9d 7b 10 	movl   $0xf0107b9d,0xc(%esp)
f01016bc:	f0 
f01016bd:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01016c4:	f0 
f01016c5:	c7 44 24 04 9a 02 00 	movl   $0x29a,0x4(%esp)
f01016cc:	00 
f01016cd:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01016d4:	e8 67 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01016d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016e0:	e8 0b fa ff ff       	call   f01010f0 <page_alloc>
f01016e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01016e8:	85 c0                	test   %eax,%eax
f01016ea:	75 24                	jne    f0101710 <mem_init+0x207>
f01016ec:	c7 44 24 0c b3 7b 10 	movl   $0xf0107bb3,0xc(%esp)
f01016f3:	f0 
f01016f4:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01016fb:	f0 
f01016fc:	c7 44 24 04 9b 02 00 	movl   $0x29b,0x4(%esp)
f0101703:	00 
f0101704:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f010170b:	e8 30 e9 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101710:	39 f7                	cmp    %esi,%edi
f0101712:	75 24                	jne    f0101738 <mem_init+0x22f>
f0101714:	c7 44 24 0c c9 7b 10 	movl   $0xf0107bc9,0xc(%esp)
f010171b:	f0 
f010171c:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101723:	f0 
f0101724:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
f010172b:	00 
f010172c:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101733:	e8 08 e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101738:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010173b:	39 c6                	cmp    %eax,%esi
f010173d:	74 04                	je     f0101743 <mem_init+0x23a>
f010173f:	39 c7                	cmp    %eax,%edi
f0101741:	75 24                	jne    f0101767 <mem_init+0x25e>
f0101743:	c7 44 24 0c 58 72 10 	movl   $0xf0107258,0xc(%esp)
f010174a:	f0 
f010174b:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101752:	f0 
f0101753:	c7 44 24 04 9f 02 00 	movl   $0x29f,0x4(%esp)
f010175a:	00 
f010175b:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101762:	e8 d9 e8 ff ff       	call   f0100040 <_panic>
	return (pp - pages) << PGSHIFT;
f0101767:	8b 15 90 0e 23 f0    	mov    0xf0230e90,%edx
	assert(page2pa(pp0) < npages * PGSIZE);
f010176d:	a1 88 0e 23 f0       	mov    0xf0230e88,%eax
f0101772:	c1 e0 0c             	shl    $0xc,%eax
f0101775:	89 f9                	mov    %edi,%ecx
f0101777:	29 d1                	sub    %edx,%ecx
f0101779:	c1 f9 03             	sar    $0x3,%ecx
f010177c:	c1 e1 0c             	shl    $0xc,%ecx
f010177f:	39 c1                	cmp    %eax,%ecx
f0101781:	72 24                	jb     f01017a7 <mem_init+0x29e>
f0101783:	c7 44 24 0c 78 72 10 	movl   $0xf0107278,0xc(%esp)
f010178a:	f0 
f010178b:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101792:	f0 
f0101793:	c7 44 24 04 a0 02 00 	movl   $0x2a0,0x4(%esp)
f010179a:	00 
f010179b:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01017a2:	e8 99 e8 ff ff       	call   f0100040 <_panic>
f01017a7:	89 f1                	mov    %esi,%ecx
f01017a9:	29 d1                	sub    %edx,%ecx
f01017ab:	c1 f9 03             	sar    $0x3,%ecx
f01017ae:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages * PGSIZE);
f01017b1:	39 c8                	cmp    %ecx,%eax
f01017b3:	77 24                	ja     f01017d9 <mem_init+0x2d0>
f01017b5:	c7 44 24 0c 98 72 10 	movl   $0xf0107298,0xc(%esp)
f01017bc:	f0 
f01017bd:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01017c4:	f0 
f01017c5:	c7 44 24 04 a1 02 00 	movl   $0x2a1,0x4(%esp)
f01017cc:	00 
f01017cd:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01017d4:	e8 67 e8 ff ff       	call   f0100040 <_panic>
f01017d9:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01017dc:	29 d1                	sub    %edx,%ecx
f01017de:	89 ca                	mov    %ecx,%edx
f01017e0:	c1 fa 03             	sar    $0x3,%edx
f01017e3:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages * PGSIZE);
f01017e6:	39 d0                	cmp    %edx,%eax
f01017e8:	77 24                	ja     f010180e <mem_init+0x305>
f01017ea:	c7 44 24 0c b8 72 10 	movl   $0xf01072b8,0xc(%esp)
f01017f1:	f0 
f01017f2:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01017f9:	f0 
f01017fa:	c7 44 24 04 a2 02 00 	movl   $0x2a2,0x4(%esp)
f0101801:	00 
f0101802:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101809:	e8 32 e8 ff ff       	call   f0100040 <_panic>
	fl = page_free_list;
f010180e:	a1 40 02 23 f0       	mov    0xf0230240,%eax
f0101813:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101816:	c7 05 40 02 23 f0 00 	movl   $0x0,0xf0230240
f010181d:	00 00 00 
	assert(!page_alloc(0));
f0101820:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101827:	e8 c4 f8 ff ff       	call   f01010f0 <page_alloc>
f010182c:	85 c0                	test   %eax,%eax
f010182e:	74 24                	je     f0101854 <mem_init+0x34b>
f0101830:	c7 44 24 0c db 7b 10 	movl   $0xf0107bdb,0xc(%esp)
f0101837:	f0 
f0101838:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f010183f:	f0 
f0101840:	c7 44 24 04 a9 02 00 	movl   $0x2a9,0x4(%esp)
f0101847:	00 
f0101848:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f010184f:	e8 ec e7 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0101854:	89 3c 24             	mov    %edi,(%esp)
f0101857:	e8 25 f9 ff ff       	call   f0101181 <page_free>
	page_free(pp1);
f010185c:	89 34 24             	mov    %esi,(%esp)
f010185f:	e8 1d f9 ff ff       	call   f0101181 <page_free>
	page_free(pp2);
f0101864:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101867:	89 04 24             	mov    %eax,(%esp)
f010186a:	e8 12 f9 ff ff       	call   f0101181 <page_free>
	assert((pp0 = page_alloc(0)));
f010186f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101876:	e8 75 f8 ff ff       	call   f01010f0 <page_alloc>
f010187b:	89 c6                	mov    %eax,%esi
f010187d:	85 c0                	test   %eax,%eax
f010187f:	75 24                	jne    f01018a5 <mem_init+0x39c>
f0101881:	c7 44 24 0c 87 7b 10 	movl   $0xf0107b87,0xc(%esp)
f0101888:	f0 
f0101889:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101890:	f0 
f0101891:	c7 44 24 04 b0 02 00 	movl   $0x2b0,0x4(%esp)
f0101898:	00 
f0101899:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01018a0:	e8 9b e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01018a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018ac:	e8 3f f8 ff ff       	call   f01010f0 <page_alloc>
f01018b1:	89 c7                	mov    %eax,%edi
f01018b3:	85 c0                	test   %eax,%eax
f01018b5:	75 24                	jne    f01018db <mem_init+0x3d2>
f01018b7:	c7 44 24 0c 9d 7b 10 	movl   $0xf0107b9d,0xc(%esp)
f01018be:	f0 
f01018bf:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01018c6:	f0 
f01018c7:	c7 44 24 04 b1 02 00 	movl   $0x2b1,0x4(%esp)
f01018ce:	00 
f01018cf:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01018d6:	e8 65 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01018db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018e2:	e8 09 f8 ff ff       	call   f01010f0 <page_alloc>
f01018e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01018ea:	85 c0                	test   %eax,%eax
f01018ec:	75 24                	jne    f0101912 <mem_init+0x409>
f01018ee:	c7 44 24 0c b3 7b 10 	movl   $0xf0107bb3,0xc(%esp)
f01018f5:	f0 
f01018f6:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01018fd:	f0 
f01018fe:	c7 44 24 04 b2 02 00 	movl   $0x2b2,0x4(%esp)
f0101905:	00 
f0101906:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f010190d:	e8 2e e7 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101912:	39 fe                	cmp    %edi,%esi
f0101914:	75 24                	jne    f010193a <mem_init+0x431>
f0101916:	c7 44 24 0c c9 7b 10 	movl   $0xf0107bc9,0xc(%esp)
f010191d:	f0 
f010191e:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101925:	f0 
f0101926:	c7 44 24 04 b4 02 00 	movl   $0x2b4,0x4(%esp)
f010192d:	00 
f010192e:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101935:	e8 06 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010193a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010193d:	39 c7                	cmp    %eax,%edi
f010193f:	74 04                	je     f0101945 <mem_init+0x43c>
f0101941:	39 c6                	cmp    %eax,%esi
f0101943:	75 24                	jne    f0101969 <mem_init+0x460>
f0101945:	c7 44 24 0c 58 72 10 	movl   $0xf0107258,0xc(%esp)
f010194c:	f0 
f010194d:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101954:	f0 
f0101955:	c7 44 24 04 b5 02 00 	movl   $0x2b5,0x4(%esp)
f010195c:	00 
f010195d:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101964:	e8 d7 e6 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101969:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101970:	e8 7b f7 ff ff       	call   f01010f0 <page_alloc>
f0101975:	85 c0                	test   %eax,%eax
f0101977:	74 24                	je     f010199d <mem_init+0x494>
f0101979:	c7 44 24 0c db 7b 10 	movl   $0xf0107bdb,0xc(%esp)
f0101980:	f0 
f0101981:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101988:	f0 
f0101989:	c7 44 24 04 b6 02 00 	movl   $0x2b6,0x4(%esp)
f0101990:	00 
f0101991:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101998:	e8 a3 e6 ff ff       	call   f0100040 <_panic>
f010199d:	89 f0                	mov    %esi,%eax
f010199f:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f01019a5:	c1 f8 03             	sar    $0x3,%eax
f01019a8:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01019ab:	89 c2                	mov    %eax,%edx
f01019ad:	c1 ea 0c             	shr    $0xc,%edx
f01019b0:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f01019b6:	72 20                	jb     f01019d8 <mem_init+0x4cf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01019bc:	c7 44 24 08 44 6b 10 	movl   $0xf0106b44,0x8(%esp)
f01019c3:	f0 
f01019c4:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01019cb:	00 
f01019cc:	c7 04 24 a5 7a 10 f0 	movl   $0xf0107aa5,(%esp)
f01019d3:	e8 68 e6 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp0), 1, PGSIZE);
f01019d8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01019df:	00 
f01019e0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01019e7:	00 
	return (void *)(pa + KERNBASE);
f01019e8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01019ed:	89 04 24             	mov    %eax,(%esp)
f01019f0:	e8 f2 43 00 00       	call   f0105de7 <memset>
	page_free(pp0);
f01019f5:	89 34 24             	mov    %esi,(%esp)
f01019f8:	e8 84 f7 ff ff       	call   f0101181 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01019fd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101a04:	e8 e7 f6 ff ff       	call   f01010f0 <page_alloc>
f0101a09:	85 c0                	test   %eax,%eax
f0101a0b:	75 24                	jne    f0101a31 <mem_init+0x528>
f0101a0d:	c7 44 24 0c ea 7b 10 	movl   $0xf0107bea,0xc(%esp)
f0101a14:	f0 
f0101a15:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101a1c:	f0 
f0101a1d:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
f0101a24:	00 
f0101a25:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101a2c:	e8 0f e6 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101a31:	39 c6                	cmp    %eax,%esi
f0101a33:	74 24                	je     f0101a59 <mem_init+0x550>
f0101a35:	c7 44 24 0c 08 7c 10 	movl   $0xf0107c08,0xc(%esp)
f0101a3c:	f0 
f0101a3d:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101a44:	f0 
f0101a45:	c7 44 24 04 bc 02 00 	movl   $0x2bc,0x4(%esp)
f0101a4c:	00 
f0101a4d:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101a54:	e8 e7 e5 ff ff       	call   f0100040 <_panic>
	return (pp - pages) << PGSHIFT;
f0101a59:	89 f0                	mov    %esi,%eax
f0101a5b:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f0101a61:	c1 f8 03             	sar    $0x3,%eax
f0101a64:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101a67:	89 c2                	mov    %eax,%edx
f0101a69:	c1 ea 0c             	shr    $0xc,%edx
f0101a6c:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f0101a72:	72 20                	jb     f0101a94 <mem_init+0x58b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a74:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101a78:	c7 44 24 08 44 6b 10 	movl   $0xf0106b44,0x8(%esp)
f0101a7f:	f0 
f0101a80:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101a87:	00 
f0101a88:	c7 04 24 a5 7a 10 f0 	movl   $0xf0107aa5,(%esp)
f0101a8f:	e8 ac e5 ff ff       	call   f0100040 <_panic>
f0101a94:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101a9a:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
		assert(c[i] == 0);
f0101aa0:	80 38 00             	cmpb   $0x0,(%eax)
f0101aa3:	74 24                	je     f0101ac9 <mem_init+0x5c0>
f0101aa5:	c7 44 24 0c 18 7c 10 	movl   $0xf0107c18,0xc(%esp)
f0101aac:	f0 
f0101aad:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101ab4:	f0 
f0101ab5:	c7 44 24 04 bf 02 00 	movl   $0x2bf,0x4(%esp)
f0101abc:	00 
f0101abd:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101ac4:	e8 77 e5 ff ff       	call   f0100040 <_panic>
f0101ac9:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101acc:	39 d0                	cmp    %edx,%eax
f0101ace:	75 d0                	jne    f0101aa0 <mem_init+0x597>
	page_free_list = fl;
f0101ad0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101ad3:	a3 40 02 23 f0       	mov    %eax,0xf0230240
	page_free(pp0);
f0101ad8:	89 34 24             	mov    %esi,(%esp)
f0101adb:	e8 a1 f6 ff ff       	call   f0101181 <page_free>
	page_free(pp1);
f0101ae0:	89 3c 24             	mov    %edi,(%esp)
f0101ae3:	e8 99 f6 ff ff       	call   f0101181 <page_free>
	page_free(pp2);
f0101ae8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101aeb:	89 04 24             	mov    %eax,(%esp)
f0101aee:	e8 8e f6 ff ff       	call   f0101181 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101af3:	a1 40 02 23 f0       	mov    0xf0230240,%eax
f0101af8:	eb 05                	jmp    f0101aff <mem_init+0x5f6>
		--nfree;
f0101afa:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101afd:	8b 00                	mov    (%eax),%eax
f0101aff:	85 c0                	test   %eax,%eax
f0101b01:	75 f7                	jne    f0101afa <mem_init+0x5f1>
	assert(nfree == 0);
f0101b03:	85 db                	test   %ebx,%ebx
f0101b05:	74 24                	je     f0101b2b <mem_init+0x622>
f0101b07:	c7 44 24 0c 22 7c 10 	movl   $0xf0107c22,0xc(%esp)
f0101b0e:	f0 
f0101b0f:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101b16:	f0 
f0101b17:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
f0101b1e:	00 
f0101b1f:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101b26:	e8 15 e5 ff ff       	call   f0100040 <_panic>
	cprintf("check_page_alloc() succeeded!\n");
f0101b2b:	c7 04 24 d8 72 10 f0 	movl   $0xf01072d8,(%esp)
f0101b32:	e8 ee 23 00 00       	call   f0103f25 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101b37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b3e:	e8 ad f5 ff ff       	call   f01010f0 <page_alloc>
f0101b43:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101b46:	85 c0                	test   %eax,%eax
f0101b48:	75 24                	jne    f0101b6e <mem_init+0x665>
f0101b4a:	c7 44 24 0c 87 7b 10 	movl   $0xf0107b87,0xc(%esp)
f0101b51:	f0 
f0101b52:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101b59:	f0 
f0101b5a:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f0101b61:	00 
f0101b62:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101b69:	e8 d2 e4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b6e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b75:	e8 76 f5 ff ff       	call   f01010f0 <page_alloc>
f0101b7a:	89 c3                	mov    %eax,%ebx
f0101b7c:	85 c0                	test   %eax,%eax
f0101b7e:	75 24                	jne    f0101ba4 <mem_init+0x69b>
f0101b80:	c7 44 24 0c 9d 7b 10 	movl   $0xf0107b9d,0xc(%esp)
f0101b87:	f0 
f0101b88:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101b8f:	f0 
f0101b90:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f0101b97:	00 
f0101b98:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101b9f:	e8 9c e4 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101ba4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bab:	e8 40 f5 ff ff       	call   f01010f0 <page_alloc>
f0101bb0:	89 c6                	mov    %eax,%esi
f0101bb2:	85 c0                	test   %eax,%eax
f0101bb4:	75 24                	jne    f0101bda <mem_init+0x6d1>
f0101bb6:	c7 44 24 0c b3 7b 10 	movl   $0xf0107bb3,0xc(%esp)
f0101bbd:	f0 
f0101bbe:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101bc5:	f0 
f0101bc6:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0101bcd:	00 
f0101bce:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101bd5:	e8 66 e4 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101bda:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101bdd:	75 24                	jne    f0101c03 <mem_init+0x6fa>
f0101bdf:	c7 44 24 0c c9 7b 10 	movl   $0xf0107bc9,0xc(%esp)
f0101be6:	f0 
f0101be7:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101bee:	f0 
f0101bef:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f0101bf6:	00 
f0101bf7:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101bfe:	e8 3d e4 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c03:	39 c3                	cmp    %eax,%ebx
f0101c05:	74 05                	je     f0101c0c <mem_init+0x703>
f0101c07:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101c0a:	75 24                	jne    f0101c30 <mem_init+0x727>
f0101c0c:	c7 44 24 0c 58 72 10 	movl   $0xf0107258,0xc(%esp)
f0101c13:	f0 
f0101c14:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101c1b:	f0 
f0101c1c:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
f0101c23:	00 
f0101c24:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101c2b:	e8 10 e4 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101c30:	a1 40 02 23 f0       	mov    0xf0230240,%eax
f0101c35:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101c38:	c7 05 40 02 23 f0 00 	movl   $0x0,0xf0230240
f0101c3f:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101c42:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c49:	e8 a2 f4 ff ff       	call   f01010f0 <page_alloc>
f0101c4e:	85 c0                	test   %eax,%eax
f0101c50:	74 24                	je     f0101c76 <mem_init+0x76d>
f0101c52:	c7 44 24 0c db 7b 10 	movl   $0xf0107bdb,0xc(%esp)
f0101c59:	f0 
f0101c5a:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101c61:	f0 
f0101c62:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f0101c69:	00 
f0101c6a:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101c71:	e8 ca e3 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *)0x0, &ptep) == NULL);
f0101c76:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101c79:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101c7d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101c84:	00 
f0101c85:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0101c8a:	89 04 24             	mov    %eax,(%esp)
f0101c8d:	e8 41 f6 ff ff       	call   f01012d3 <page_lookup>
f0101c92:	85 c0                	test   %eax,%eax
f0101c94:	74 24                	je     f0101cba <mem_init+0x7b1>
f0101c96:	c7 44 24 0c f8 72 10 	movl   $0xf01072f8,0xc(%esp)
f0101c9d:	f0 
f0101c9e:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101ca5:	f0 
f0101ca6:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f0101cad:	00 
f0101cae:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101cb5:	e8 86 e3 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101cba:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101cc1:	00 
f0101cc2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101cc9:	00 
f0101cca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101cce:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0101cd3:	89 04 24             	mov    %eax,(%esp)
f0101cd6:	e8 47 f7 ff ff       	call   f0101422 <page_insert>
f0101cdb:	85 c0                	test   %eax,%eax
f0101cdd:	78 24                	js     f0101d03 <mem_init+0x7fa>
f0101cdf:	c7 44 24 0c 2c 73 10 	movl   $0xf010732c,0xc(%esp)
f0101ce6:	f0 
f0101ce7:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101cee:	f0 
f0101cef:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f0101cf6:	00 
f0101cf7:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101cfe:	e8 3d e3 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101d03:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d06:	89 04 24             	mov    %eax,(%esp)
f0101d09:	e8 73 f4 ff ff       	call   f0101181 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101d0e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d15:	00 
f0101d16:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d1d:	00 
f0101d1e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d22:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0101d27:	89 04 24             	mov    %eax,(%esp)
f0101d2a:	e8 f3 f6 ff ff       	call   f0101422 <page_insert>
f0101d2f:	85 c0                	test   %eax,%eax
f0101d31:	74 24                	je     f0101d57 <mem_init+0x84e>
f0101d33:	c7 44 24 0c 5c 73 10 	movl   $0xf010735c,0xc(%esp)
f0101d3a:	f0 
f0101d3b:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101d42:	f0 
f0101d43:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f0101d4a:	00 
f0101d4b:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101d52:	e8 e9 e2 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d57:	8b 3d 8c 0e 23 f0    	mov    0xf0230e8c,%edi
	return (pp - pages) << PGSHIFT;
f0101d5d:	a1 90 0e 23 f0       	mov    0xf0230e90,%eax
f0101d62:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101d65:	8b 17                	mov    (%edi),%edx
f0101d67:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101d6d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101d70:	29 c1                	sub    %eax,%ecx
f0101d72:	89 c8                	mov    %ecx,%eax
f0101d74:	c1 f8 03             	sar    $0x3,%eax
f0101d77:	c1 e0 0c             	shl    $0xc,%eax
f0101d7a:	39 c2                	cmp    %eax,%edx
f0101d7c:	74 24                	je     f0101da2 <mem_init+0x899>
f0101d7e:	c7 44 24 0c 8c 73 10 	movl   $0xf010738c,0xc(%esp)
f0101d85:	f0 
f0101d86:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101d8d:	f0 
f0101d8e:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f0101d95:	00 
f0101d96:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101d9d:	e8 9e e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101da2:	ba 00 00 00 00       	mov    $0x0,%edx
f0101da7:	89 f8                	mov    %edi,%eax
f0101da9:	e8 2d ee ff ff       	call   f0100bdb <check_va2pa>
f0101dae:	89 da                	mov    %ebx,%edx
f0101db0:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101db3:	c1 fa 03             	sar    $0x3,%edx
f0101db6:	c1 e2 0c             	shl    $0xc,%edx
f0101db9:	39 d0                	cmp    %edx,%eax
f0101dbb:	74 24                	je     f0101de1 <mem_init+0x8d8>
f0101dbd:	c7 44 24 0c b4 73 10 	movl   $0xf01073b4,0xc(%esp)
f0101dc4:	f0 
f0101dc5:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101dcc:	f0 
f0101dcd:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f0101dd4:	00 
f0101dd5:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101ddc:	e8 5f e2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101de1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101de6:	74 24                	je     f0101e0c <mem_init+0x903>
f0101de8:	c7 44 24 0c 2d 7c 10 	movl   $0xf0107c2d,0xc(%esp)
f0101def:	f0 
f0101df0:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101df7:	f0 
f0101df8:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f0101dff:	00 
f0101e00:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101e07:	e8 34 e2 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101e0c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e0f:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e14:	74 24                	je     f0101e3a <mem_init+0x931>
f0101e16:	c7 44 24 0c 3e 7c 10 	movl   $0xf0107c3e,0xc(%esp)
f0101e1d:	f0 
f0101e1e:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101e25:	f0 
f0101e26:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f0101e2d:	00 
f0101e2e:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101e35:	e8 06 e2 ff ff       	call   f0100040 <_panic>
	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101e3a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e41:	00 
f0101e42:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e49:	00 
f0101e4a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101e4e:	89 3c 24             	mov    %edi,(%esp)
f0101e51:	e8 cc f5 ff ff       	call   f0101422 <page_insert>
f0101e56:	85 c0                	test   %eax,%eax
f0101e58:	74 24                	je     f0101e7e <mem_init+0x975>
f0101e5a:	c7 44 24 0c e4 73 10 	movl   $0xf01073e4,0xc(%esp)
f0101e61:	f0 
f0101e62:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101e69:	f0 
f0101e6a:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f0101e71:	00 
f0101e72:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101e79:	e8 c2 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e7e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e83:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0101e88:	e8 4e ed ff ff       	call   f0100bdb <check_va2pa>
f0101e8d:	89 f2                	mov    %esi,%edx
f0101e8f:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f0101e95:	c1 fa 03             	sar    $0x3,%edx
f0101e98:	c1 e2 0c             	shl    $0xc,%edx
f0101e9b:	39 d0                	cmp    %edx,%eax
f0101e9d:	74 24                	je     f0101ec3 <mem_init+0x9ba>
f0101e9f:	c7 44 24 0c 20 74 10 	movl   $0xf0107420,0xc(%esp)
f0101ea6:	f0 
f0101ea7:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101eae:	f0 
f0101eaf:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f0101eb6:	00 
f0101eb7:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101ebe:	e8 7d e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ec3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ec8:	74 24                	je     f0101eee <mem_init+0x9e5>
f0101eca:	c7 44 24 0c 4f 7c 10 	movl   $0xf0107c4f,0xc(%esp)
f0101ed1:	f0 
f0101ed2:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101ed9:	f0 
f0101eda:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0101ee1:	00 
f0101ee2:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101ee9:	e8 52 e1 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101eee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ef5:	e8 f6 f1 ff ff       	call   f01010f0 <page_alloc>
f0101efa:	85 c0                	test   %eax,%eax
f0101efc:	74 24                	je     f0101f22 <mem_init+0xa19>
f0101efe:	c7 44 24 0c db 7b 10 	movl   $0xf0107bdb,0xc(%esp)
f0101f05:	f0 
f0101f06:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101f0d:	f0 
f0101f0e:	c7 44 24 04 56 03 00 	movl   $0x356,0x4(%esp)
f0101f15:	00 
f0101f16:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101f1d:	e8 1e e1 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101f22:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f29:	00 
f0101f2a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f31:	00 
f0101f32:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101f36:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0101f3b:	89 04 24             	mov    %eax,(%esp)
f0101f3e:	e8 df f4 ff ff       	call   f0101422 <page_insert>
f0101f43:	85 c0                	test   %eax,%eax
f0101f45:	74 24                	je     f0101f6b <mem_init+0xa62>
f0101f47:	c7 44 24 0c e4 73 10 	movl   $0xf01073e4,0xc(%esp)
f0101f4e:	f0 
f0101f4f:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101f56:	f0 
f0101f57:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f0101f5e:	00 
f0101f5f:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101f66:	e8 d5 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f6b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f70:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0101f75:	e8 61 ec ff ff       	call   f0100bdb <check_va2pa>
f0101f7a:	89 f2                	mov    %esi,%edx
f0101f7c:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f0101f82:	c1 fa 03             	sar    $0x3,%edx
f0101f85:	c1 e2 0c             	shl    $0xc,%edx
f0101f88:	39 d0                	cmp    %edx,%eax
f0101f8a:	74 24                	je     f0101fb0 <mem_init+0xaa7>
f0101f8c:	c7 44 24 0c 20 74 10 	movl   $0xf0107420,0xc(%esp)
f0101f93:	f0 
f0101f94:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101f9b:	f0 
f0101f9c:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f0101fa3:	00 
f0101fa4:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101fab:	e8 90 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101fb0:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101fb5:	74 24                	je     f0101fdb <mem_init+0xad2>
f0101fb7:	c7 44 24 0c 4f 7c 10 	movl   $0xf0107c4f,0xc(%esp)
f0101fbe:	f0 
f0101fbf:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101fc6:	f0 
f0101fc7:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f0101fce:	00 
f0101fcf:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0101fd6:	e8 65 e0 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101fdb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fe2:	e8 09 f1 ff ff       	call   f01010f0 <page_alloc>
f0101fe7:	85 c0                	test   %eax,%eax
f0101fe9:	74 24                	je     f010200f <mem_init+0xb06>
f0101feb:	c7 44 24 0c db 7b 10 	movl   $0xf0107bdb,0xc(%esp)
f0101ff2:	f0 
f0101ff3:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0101ffa:	f0 
f0101ffb:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0102002:	00 
f0102003:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f010200a:	e8 31 e0 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010200f:	8b 15 8c 0e 23 f0    	mov    0xf0230e8c,%edx
f0102015:	8b 02                	mov    (%edx),%eax
f0102017:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010201c:	89 c1                	mov    %eax,%ecx
f010201e:	c1 e9 0c             	shr    $0xc,%ecx
f0102021:	3b 0d 88 0e 23 f0    	cmp    0xf0230e88,%ecx
f0102027:	72 20                	jb     f0102049 <mem_init+0xb40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102029:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010202d:	c7 44 24 08 44 6b 10 	movl   $0xf0106b44,0x8(%esp)
f0102034:	f0 
f0102035:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
f010203c:	00 
f010203d:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102044:	e8 f7 df ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102049:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010204e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
f0102051:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102058:	00 
f0102059:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102060:	00 
f0102061:	89 14 24             	mov    %edx,(%esp)
f0102064:	e8 7b f1 ff ff       	call   f01011e4 <pgdir_walk>
f0102069:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010206c:	8d 51 04             	lea    0x4(%ecx),%edx
f010206f:	39 d0                	cmp    %edx,%eax
f0102071:	74 24                	je     f0102097 <mem_init+0xb8e>
f0102073:	c7 44 24 0c 50 74 10 	movl   $0xf0107450,0xc(%esp)
f010207a:	f0 
f010207b:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102082:	f0 
f0102083:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f010208a:	00 
f010208b:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102092:	e8 a9 df ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W | PTE_U) == 0);
f0102097:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010209e:	00 
f010209f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01020a6:	00 
f01020a7:	89 74 24 04          	mov    %esi,0x4(%esp)
f01020ab:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01020b0:	89 04 24             	mov    %eax,(%esp)
f01020b3:	e8 6a f3 ff ff       	call   f0101422 <page_insert>
f01020b8:	85 c0                	test   %eax,%eax
f01020ba:	74 24                	je     f01020e0 <mem_init+0xbd7>
f01020bc:	c7 44 24 0c 90 74 10 	movl   $0xf0107490,0xc(%esp)
f01020c3:	f0 
f01020c4:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01020cb:	f0 
f01020cc:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f01020d3:	00 
f01020d4:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01020db:	e8 60 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01020e0:	8b 3d 8c 0e 23 f0    	mov    0xf0230e8c,%edi
f01020e6:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020eb:	89 f8                	mov    %edi,%eax
f01020ed:	e8 e9 ea ff ff       	call   f0100bdb <check_va2pa>
	return (pp - pages) << PGSHIFT;
f01020f2:	89 f2                	mov    %esi,%edx
f01020f4:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f01020fa:	c1 fa 03             	sar    $0x3,%edx
f01020fd:	c1 e2 0c             	shl    $0xc,%edx
f0102100:	39 d0                	cmp    %edx,%eax
f0102102:	74 24                	je     f0102128 <mem_init+0xc1f>
f0102104:	c7 44 24 0c 20 74 10 	movl   $0xf0107420,0xc(%esp)
f010210b:	f0 
f010210c:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102113:	f0 
f0102114:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f010211b:	00 
f010211c:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102123:	e8 18 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102128:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010212d:	74 24                	je     f0102153 <mem_init+0xc4a>
f010212f:	c7 44 24 0c 4f 7c 10 	movl   $0xf0107c4f,0xc(%esp)
f0102136:	f0 
f0102137:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f010213e:	f0 
f010213f:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102146:	00 
f0102147:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f010214e:	e8 ed de ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U);
f0102153:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010215a:	00 
f010215b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102162:	00 
f0102163:	89 3c 24             	mov    %edi,(%esp)
f0102166:	e8 79 f0 ff ff       	call   f01011e4 <pgdir_walk>
f010216b:	f6 00 04             	testb  $0x4,(%eax)
f010216e:	75 24                	jne    f0102194 <mem_init+0xc8b>
f0102170:	c7 44 24 0c d4 74 10 	movl   $0xf01074d4,0xc(%esp)
f0102177:	f0 
f0102178:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f010217f:	f0 
f0102180:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f0102187:	00 
f0102188:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f010218f:	e8 ac de ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102194:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102199:	f6 00 04             	testb  $0x4,(%eax)
f010219c:	75 24                	jne    f01021c2 <mem_init+0xcb9>
f010219e:	c7 44 24 0c 60 7c 10 	movl   $0xf0107c60,0xc(%esp)
f01021a5:	f0 
f01021a6:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01021ad:	f0 
f01021ae:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f01021b5:	00 
f01021b6:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01021bd:	e8 7e de ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f01021c2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01021c9:	00 
f01021ca:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01021d1:	00 
f01021d2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01021d6:	89 04 24             	mov    %eax,(%esp)
f01021d9:	e8 44 f2 ff ff       	call   f0101422 <page_insert>
f01021de:	85 c0                	test   %eax,%eax
f01021e0:	74 24                	je     f0102206 <mem_init+0xcfd>
f01021e2:	c7 44 24 0c e4 73 10 	movl   $0xf01073e4,0xc(%esp)
f01021e9:	f0 
f01021ea:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01021f1:	f0 
f01021f2:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f01021f9:	00 
f01021fa:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102201:	e8 3a de ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_W);
f0102206:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010220d:	00 
f010220e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102215:	00 
f0102216:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f010221b:	89 04 24             	mov    %eax,(%esp)
f010221e:	e8 c1 ef ff ff       	call   f01011e4 <pgdir_walk>
f0102223:	f6 00 02             	testb  $0x2,(%eax)
f0102226:	75 24                	jne    f010224c <mem_init+0xd43>
f0102228:	c7 44 24 0c 08 75 10 	movl   $0xf0107508,0xc(%esp)
f010222f:	f0 
f0102230:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102237:	f0 
f0102238:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f010223f:	00 
f0102240:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102247:	e8 f4 dd ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f010224c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102253:	00 
f0102254:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010225b:	00 
f010225c:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102261:	89 04 24             	mov    %eax,(%esp)
f0102264:	e8 7b ef ff ff       	call   f01011e4 <pgdir_walk>
f0102269:	f6 00 04             	testb  $0x4,(%eax)
f010226c:	74 24                	je     f0102292 <mem_init+0xd89>
f010226e:	c7 44 24 0c 3c 75 10 	movl   $0xf010753c,0xc(%esp)
f0102275:	f0 
f0102276:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f010227d:	f0 
f010227e:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f0102285:	00 
f0102286:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f010228d:	e8 ae dd ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void *)PTSIZE, PTE_W) < 0);
f0102292:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102299:	00 
f010229a:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01022a1:	00 
f01022a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022a5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022a9:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01022ae:	89 04 24             	mov    %eax,(%esp)
f01022b1:	e8 6c f1 ff ff       	call   f0101422 <page_insert>
f01022b6:	85 c0                	test   %eax,%eax
f01022b8:	78 24                	js     f01022de <mem_init+0xdd5>
f01022ba:	c7 44 24 0c 74 75 10 	movl   $0xf0107574,0xc(%esp)
f01022c1:	f0 
f01022c2:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01022c9:	f0 
f01022ca:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f01022d1:	00 
f01022d2:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01022d9:	e8 62 dd ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W) == 0);
f01022de:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01022e5:	00 
f01022e6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01022ed:	00 
f01022ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01022f2:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01022f7:	89 04 24             	mov    %eax,(%esp)
f01022fa:	e8 23 f1 ff ff       	call   f0101422 <page_insert>
f01022ff:	85 c0                	test   %eax,%eax
f0102301:	74 24                	je     f0102327 <mem_init+0xe1e>
f0102303:	c7 44 24 0c ac 75 10 	movl   $0xf01075ac,0xc(%esp)
f010230a:	f0 
f010230b:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102312:	f0 
f0102313:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f010231a:	00 
f010231b:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102322:	e8 19 dd ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0102327:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010232e:	00 
f010232f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102336:	00 
f0102337:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f010233c:	89 04 24             	mov    %eax,(%esp)
f010233f:	e8 a0 ee ff ff       	call   f01011e4 <pgdir_walk>
f0102344:	f6 00 04             	testb  $0x4,(%eax)
f0102347:	74 24                	je     f010236d <mem_init+0xe64>
f0102349:	c7 44 24 0c 3c 75 10 	movl   $0xf010753c,0xc(%esp)
f0102350:	f0 
f0102351:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102358:	f0 
f0102359:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f0102360:	00 
f0102361:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102368:	e8 d3 dc ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010236d:	8b 3d 8c 0e 23 f0    	mov    0xf0230e8c,%edi
f0102373:	ba 00 00 00 00       	mov    $0x0,%edx
f0102378:	89 f8                	mov    %edi,%eax
f010237a:	e8 5c e8 ff ff       	call   f0100bdb <check_va2pa>
f010237f:	89 c1                	mov    %eax,%ecx
f0102381:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102384:	89 d8                	mov    %ebx,%eax
f0102386:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f010238c:	c1 f8 03             	sar    $0x3,%eax
f010238f:	c1 e0 0c             	shl    $0xc,%eax
f0102392:	39 c1                	cmp    %eax,%ecx
f0102394:	74 24                	je     f01023ba <mem_init+0xeb1>
f0102396:	c7 44 24 0c e8 75 10 	movl   $0xf01075e8,0xc(%esp)
f010239d:	f0 
f010239e:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01023a5:	f0 
f01023a6:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f01023ad:	00 
f01023ae:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01023b5:	e8 86 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01023ba:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023bf:	89 f8                	mov    %edi,%eax
f01023c1:	e8 15 e8 ff ff       	call   f0100bdb <check_va2pa>
f01023c6:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01023c9:	74 24                	je     f01023ef <mem_init+0xee6>
f01023cb:	c7 44 24 0c 14 76 10 	movl   $0xf0107614,0xc(%esp)
f01023d2:	f0 
f01023d3:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01023da:	f0 
f01023db:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f01023e2:	00 
f01023e3:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01023ea:	e8 51 dc ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01023ef:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f01023f4:	74 24                	je     f010241a <mem_init+0xf11>
f01023f6:	c7 44 24 0c 76 7c 10 	movl   $0xf0107c76,0xc(%esp)
f01023fd:	f0 
f01023fe:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102405:	f0 
f0102406:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f010240d:	00 
f010240e:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102415:	e8 26 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010241a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010241f:	74 24                	je     f0102445 <mem_init+0xf3c>
f0102421:	c7 44 24 0c 87 7c 10 	movl   $0xf0107c87,0xc(%esp)
f0102428:	f0 
f0102429:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102430:	f0 
f0102431:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0102438:	00 
f0102439:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102440:	e8 fb db ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102445:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010244c:	e8 9f ec ff ff       	call   f01010f0 <page_alloc>
f0102451:	85 c0                	test   %eax,%eax
f0102453:	74 04                	je     f0102459 <mem_init+0xf50>
f0102455:	39 c6                	cmp    %eax,%esi
f0102457:	74 24                	je     f010247d <mem_init+0xf74>
f0102459:	c7 44 24 0c 44 76 10 	movl   $0xf0107644,0xc(%esp)
f0102460:	f0 
f0102461:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102468:	f0 
f0102469:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f0102470:	00 
f0102471:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102478:	e8 c3 db ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010247d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102484:	00 
f0102485:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f010248a:	89 04 24             	mov    %eax,(%esp)
f010248d:	e8 47 ef ff ff       	call   f01013d9 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102492:	8b 3d 8c 0e 23 f0    	mov    0xf0230e8c,%edi
f0102498:	ba 00 00 00 00       	mov    $0x0,%edx
f010249d:	89 f8                	mov    %edi,%eax
f010249f:	e8 37 e7 ff ff       	call   f0100bdb <check_va2pa>
f01024a4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024a7:	74 24                	je     f01024cd <mem_init+0xfc4>
f01024a9:	c7 44 24 0c 68 76 10 	movl   $0xf0107668,0xc(%esp)
f01024b0:	f0 
f01024b1:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01024b8:	f0 
f01024b9:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f01024c0:	00 
f01024c1:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01024c8:	e8 73 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01024cd:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024d2:	89 f8                	mov    %edi,%eax
f01024d4:	e8 02 e7 ff ff       	call   f0100bdb <check_va2pa>
f01024d9:	89 da                	mov    %ebx,%edx
f01024db:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f01024e1:	c1 fa 03             	sar    $0x3,%edx
f01024e4:	c1 e2 0c             	shl    $0xc,%edx
f01024e7:	39 d0                	cmp    %edx,%eax
f01024e9:	74 24                	je     f010250f <mem_init+0x1006>
f01024eb:	c7 44 24 0c 14 76 10 	movl   $0xf0107614,0xc(%esp)
f01024f2:	f0 
f01024f3:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01024fa:	f0 
f01024fb:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0102502:	00 
f0102503:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f010250a:	e8 31 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010250f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102514:	74 24                	je     f010253a <mem_init+0x1031>
f0102516:	c7 44 24 0c 2d 7c 10 	movl   $0xf0107c2d,0xc(%esp)
f010251d:	f0 
f010251e:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102525:	f0 
f0102526:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f010252d:	00 
f010252e:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102535:	e8 06 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010253a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010253f:	74 24                	je     f0102565 <mem_init+0x105c>
f0102541:	c7 44 24 0c 87 7c 10 	movl   $0xf0107c87,0xc(%esp)
f0102548:	f0 
f0102549:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102550:	f0 
f0102551:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0102558:	00 
f0102559:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102560:	e8 db da ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, 0) == 0);
f0102565:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010256c:	00 
f010256d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102574:	00 
f0102575:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102579:	89 3c 24             	mov    %edi,(%esp)
f010257c:	e8 a1 ee ff ff       	call   f0101422 <page_insert>
f0102581:	85 c0                	test   %eax,%eax
f0102583:	74 24                	je     f01025a9 <mem_init+0x10a0>
f0102585:	c7 44 24 0c 8c 76 10 	movl   $0xf010768c,0xc(%esp)
f010258c:	f0 
f010258d:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102594:	f0 
f0102595:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
f010259c:	00 
f010259d:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01025a4:	e8 97 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01025a9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01025ae:	75 24                	jne    f01025d4 <mem_init+0x10cb>
f01025b0:	c7 44 24 0c 98 7c 10 	movl   $0xf0107c98,0xc(%esp)
f01025b7:	f0 
f01025b8:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01025bf:	f0 
f01025c0:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f01025c7:	00 
f01025c8:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01025cf:	e8 6c da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01025d4:	83 3b 00             	cmpl   $0x0,(%ebx)
f01025d7:	74 24                	je     f01025fd <mem_init+0x10f4>
f01025d9:	c7 44 24 0c a4 7c 10 	movl   $0xf0107ca4,0xc(%esp)
f01025e0:	f0 
f01025e1:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01025e8:	f0 
f01025e9:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f01025f0:	00 
f01025f1:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01025f8:	e8 43 da ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void *)PGSIZE);
f01025fd:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102604:	00 
f0102605:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f010260a:	89 04 24             	mov    %eax,(%esp)
f010260d:	e8 c7 ed ff ff       	call   f01013d9 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102612:	8b 3d 8c 0e 23 f0    	mov    0xf0230e8c,%edi
f0102618:	ba 00 00 00 00       	mov    $0x0,%edx
f010261d:	89 f8                	mov    %edi,%eax
f010261f:	e8 b7 e5 ff ff       	call   f0100bdb <check_va2pa>
f0102624:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102627:	74 24                	je     f010264d <mem_init+0x1144>
f0102629:	c7 44 24 0c 68 76 10 	movl   $0xf0107668,0xc(%esp)
f0102630:	f0 
f0102631:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102638:	f0 
f0102639:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0102640:	00 
f0102641:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102648:	e8 f3 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010264d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102652:	89 f8                	mov    %edi,%eax
f0102654:	e8 82 e5 ff ff       	call   f0100bdb <check_va2pa>
f0102659:	83 f8 ff             	cmp    $0xffffffff,%eax
f010265c:	74 24                	je     f0102682 <mem_init+0x1179>
f010265e:	c7 44 24 0c c4 76 10 	movl   $0xf01076c4,0xc(%esp)
f0102665:	f0 
f0102666:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f010266d:	f0 
f010266e:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0102675:	00 
f0102676:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f010267d:	e8 be d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102682:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102687:	74 24                	je     f01026ad <mem_init+0x11a4>
f0102689:	c7 44 24 0c b9 7c 10 	movl   $0xf0107cb9,0xc(%esp)
f0102690:	f0 
f0102691:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102698:	f0 
f0102699:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f01026a0:	00 
f01026a1:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01026a8:	e8 93 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01026ad:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01026b2:	74 24                	je     f01026d8 <mem_init+0x11cf>
f01026b4:	c7 44 24 0c 87 7c 10 	movl   $0xf0107c87,0xc(%esp)
f01026bb:	f0 
f01026bc:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01026c3:	f0 
f01026c4:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f01026cb:	00 
f01026cc:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01026d3:	e8 68 d9 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01026d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01026df:	e8 0c ea ff ff       	call   f01010f0 <page_alloc>
f01026e4:	85 c0                	test   %eax,%eax
f01026e6:	74 04                	je     f01026ec <mem_init+0x11e3>
f01026e8:	39 c3                	cmp    %eax,%ebx
f01026ea:	74 24                	je     f0102710 <mem_init+0x1207>
f01026ec:	c7 44 24 0c ec 76 10 	movl   $0xf01076ec,0xc(%esp)
f01026f3:	f0 
f01026f4:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01026fb:	f0 
f01026fc:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0102703:	00 
f0102704:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f010270b:	e8 30 d9 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102710:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102717:	e8 d4 e9 ff ff       	call   f01010f0 <page_alloc>
f010271c:	85 c0                	test   %eax,%eax
f010271e:	74 24                	je     f0102744 <mem_init+0x123b>
f0102720:	c7 44 24 0c db 7b 10 	movl   $0xf0107bdb,0xc(%esp)
f0102727:	f0 
f0102728:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f010272f:	f0 
f0102730:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f0102737:	00 
f0102738:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f010273f:	e8 fc d8 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102744:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102749:	8b 08                	mov    (%eax),%ecx
f010274b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102751:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102754:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f010275a:	c1 fa 03             	sar    $0x3,%edx
f010275d:	c1 e2 0c             	shl    $0xc,%edx
f0102760:	39 d1                	cmp    %edx,%ecx
f0102762:	74 24                	je     f0102788 <mem_init+0x127f>
f0102764:	c7 44 24 0c 8c 73 10 	movl   $0xf010738c,0xc(%esp)
f010276b:	f0 
f010276c:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102773:	f0 
f0102774:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f010277b:	00 
f010277c:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102783:	e8 b8 d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102788:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010278e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102791:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102796:	74 24                	je     f01027bc <mem_init+0x12b3>
f0102798:	c7 44 24 0c 3e 7c 10 	movl   $0xf0107c3e,0xc(%esp)
f010279f:	f0 
f01027a0:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01027a7:	f0 
f01027a8:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f01027af:	00 
f01027b0:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01027b7:	e8 84 d8 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01027bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01027bf:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01027c5:	89 04 24             	mov    %eax,(%esp)
f01027c8:	e8 b4 e9 ff ff       	call   f0101181 <page_free>
	va = (void *)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01027cd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01027d4:	00 
f01027d5:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01027dc:	00 
f01027dd:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01027e2:	89 04 24             	mov    %eax,(%esp)
f01027e5:	e8 fa e9 ff ff       	call   f01011e4 <pgdir_walk>
f01027ea:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01027ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01027f0:	8b 15 8c 0e 23 f0    	mov    0xf0230e8c,%edx
f01027f6:	8b 7a 04             	mov    0x4(%edx),%edi
f01027f9:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f01027ff:	8b 0d 88 0e 23 f0    	mov    0xf0230e88,%ecx
f0102805:	89 f8                	mov    %edi,%eax
f0102807:	c1 e8 0c             	shr    $0xc,%eax
f010280a:	39 c8                	cmp    %ecx,%eax
f010280c:	72 20                	jb     f010282e <mem_init+0x1325>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010280e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102812:	c7 44 24 08 44 6b 10 	movl   $0xf0106b44,0x8(%esp)
f0102819:	f0 
f010281a:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f0102821:	00 
f0102822:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102829:	e8 12 d8 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010282e:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0102834:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0102837:	74 24                	je     f010285d <mem_init+0x1354>
f0102839:	c7 44 24 0c ca 7c 10 	movl   $0xf0107cca,0xc(%esp)
f0102840:	f0 
f0102841:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102848:	f0 
f0102849:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0102850:	00 
f0102851:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102858:	e8 e3 d7 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010285d:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f0102864:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102867:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f010286d:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f0102873:	c1 f8 03             	sar    $0x3,%eax
f0102876:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102879:	89 c2                	mov    %eax,%edx
f010287b:	c1 ea 0c             	shr    $0xc,%edx
f010287e:	39 d1                	cmp    %edx,%ecx
f0102880:	77 20                	ja     f01028a2 <mem_init+0x1399>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102882:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102886:	c7 44 24 08 44 6b 10 	movl   $0xf0106b44,0x8(%esp)
f010288d:	f0 
f010288e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102895:	00 
f0102896:	c7 04 24 a5 7a 10 f0 	movl   $0xf0107aa5,(%esp)
f010289d:	e8 9e d7 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01028a2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01028a9:	00 
f01028aa:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01028b1:	00 
	return (void *)(pa + KERNBASE);
f01028b2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01028b7:	89 04 24             	mov    %eax,(%esp)
f01028ba:	e8 28 35 00 00       	call   f0105de7 <memset>
	page_free(pp0);
f01028bf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01028c2:	89 3c 24             	mov    %edi,(%esp)
f01028c5:	e8 b7 e8 ff ff       	call   f0101181 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01028ca:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01028d1:	00 
f01028d2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01028d9:	00 
f01028da:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01028df:	89 04 24             	mov    %eax,(%esp)
f01028e2:	e8 fd e8 ff ff       	call   f01011e4 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f01028e7:	89 fa                	mov    %edi,%edx
f01028e9:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f01028ef:	c1 fa 03             	sar    $0x3,%edx
f01028f2:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01028f5:	89 d0                	mov    %edx,%eax
f01028f7:	c1 e8 0c             	shr    $0xc,%eax
f01028fa:	3b 05 88 0e 23 f0    	cmp    0xf0230e88,%eax
f0102900:	72 20                	jb     f0102922 <mem_init+0x1419>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102902:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102906:	c7 44 24 08 44 6b 10 	movl   $0xf0106b44,0x8(%esp)
f010290d:	f0 
f010290e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102915:	00 
f0102916:	c7 04 24 a5 7a 10 f0 	movl   $0xf0107aa5,(%esp)
f010291d:	e8 1e d7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102922:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *)page2kva(pp0);
f0102928:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010292b:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for (i = 0; i < NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102931:	f6 00 01             	testb  $0x1,(%eax)
f0102934:	74 24                	je     f010295a <mem_init+0x1451>
f0102936:	c7 44 24 0c e2 7c 10 	movl   $0xf0107ce2,0xc(%esp)
f010293d:	f0 
f010293e:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102945:	f0 
f0102946:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f010294d:	00 
f010294e:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102955:	e8 e6 d6 ff ff       	call   f0100040 <_panic>
f010295a:	83 c0 04             	add    $0x4,%eax
	for (i = 0; i < NPTENTRIES; i++)
f010295d:	39 d0                	cmp    %edx,%eax
f010295f:	75 d0                	jne    f0102931 <mem_init+0x1428>
	kern_pgdir[0] = 0;
f0102961:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102966:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010296c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010296f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102975:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102978:	89 0d 40 02 23 f0    	mov    %ecx,0xf0230240

	// free the pages we took
	page_free(pp0);
f010297e:	89 04 24             	mov    %eax,(%esp)
f0102981:	e8 fb e7 ff ff       	call   f0101181 <page_free>
	page_free(pp1);
f0102986:	89 1c 24             	mov    %ebx,(%esp)
f0102989:	e8 f3 e7 ff ff       	call   f0101181 <page_free>
	page_free(pp2);
f010298e:	89 34 24             	mov    %esi,(%esp)
f0102991:	e8 eb e7 ff ff       	call   f0101181 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t)mmio_map_region(0, 4097);
f0102996:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f010299d:	00 
f010299e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029a5:	e8 f0 ea ff ff       	call   f010149a <mmio_map_region>
f01029aa:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t)mmio_map_region(0, 4096);
f01029ac:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01029b3:	00 
f01029b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029bb:	e8 da ea ff ff       	call   f010149a <mmio_map_region>
f01029c0:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01029c2:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01029c8:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01029cd:	77 08                	ja     f01029d7 <mem_init+0x14ce>
f01029cf:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01029d5:	77 24                	ja     f01029fb <mem_init+0x14f2>
f01029d7:	c7 44 24 0c 10 77 10 	movl   $0xf0107710,0xc(%esp)
f01029de:	f0 
f01029df:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01029e6:	f0 
f01029e7:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f01029ee:	00 
f01029ef:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01029f6:	e8 45 d6 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01029fb:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102a01:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102a07:	77 08                	ja     f0102a11 <mem_init+0x1508>
f0102a09:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102a0f:	77 24                	ja     f0102a35 <mem_init+0x152c>
f0102a11:	c7 44 24 0c 38 77 10 	movl   $0xf0107738,0xc(%esp)
f0102a18:	f0 
f0102a19:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102a20:	f0 
f0102a21:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f0102a28:	00 
f0102a29:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102a30:	e8 0b d6 ff ff       	call   f0100040 <_panic>
f0102a35:	89 da                	mov    %ebx,%edx
f0102a37:	09 f2                	or     %esi,%edx
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102a39:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102a3f:	74 24                	je     f0102a65 <mem_init+0x155c>
f0102a41:	c7 44 24 0c 60 77 10 	movl   $0xf0107760,0xc(%esp)
f0102a48:	f0 
f0102a49:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102a50:	f0 
f0102a51:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0102a58:	00 
f0102a59:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102a60:	e8 db d5 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102a65:	39 c6                	cmp    %eax,%esi
f0102a67:	73 24                	jae    f0102a8d <mem_init+0x1584>
f0102a69:	c7 44 24 0c f9 7c 10 	movl   $0xf0107cf9,0xc(%esp)
f0102a70:	f0 
f0102a71:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102a78:	f0 
f0102a79:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f0102a80:	00 
f0102a81:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102a88:	e8 b3 d5 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102a8d:	8b 3d 8c 0e 23 f0    	mov    0xf0230e8c,%edi
f0102a93:	89 da                	mov    %ebx,%edx
f0102a95:	89 f8                	mov    %edi,%eax
f0102a97:	e8 3f e1 ff ff       	call   f0100bdb <check_va2pa>
f0102a9c:	85 c0                	test   %eax,%eax
f0102a9e:	74 24                	je     f0102ac4 <mem_init+0x15bb>
f0102aa0:	c7 44 24 0c 88 77 10 	movl   $0xf0107788,0xc(%esp)
f0102aa7:	f0 
f0102aa8:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102aaf:	f0 
f0102ab0:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0102ab7:	00 
f0102ab8:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102abf:	e8 7c d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1 + PGSIZE) == PGSIZE);
f0102ac4:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102aca:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102acd:	89 c2                	mov    %eax,%edx
f0102acf:	89 f8                	mov    %edi,%eax
f0102ad1:	e8 05 e1 ff ff       	call   f0100bdb <check_va2pa>
f0102ad6:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102adb:	74 24                	je     f0102b01 <mem_init+0x15f8>
f0102add:	c7 44 24 0c ac 77 10 	movl   $0xf01077ac,0xc(%esp)
f0102ae4:	f0 
f0102ae5:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102aec:	f0 
f0102aed:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0102af4:	00 
f0102af5:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102afc:	e8 3f d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102b01:	89 f2                	mov    %esi,%edx
f0102b03:	89 f8                	mov    %edi,%eax
f0102b05:	e8 d1 e0 ff ff       	call   f0100bdb <check_va2pa>
f0102b0a:	85 c0                	test   %eax,%eax
f0102b0c:	74 24                	je     f0102b32 <mem_init+0x1629>
f0102b0e:	c7 44 24 0c dc 77 10 	movl   $0xf01077dc,0xc(%esp)
f0102b15:	f0 
f0102b16:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102b1d:	f0 
f0102b1e:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f0102b25:	00 
f0102b26:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102b2d:	e8 0e d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2 + PGSIZE) == ~0);
f0102b32:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102b38:	89 f8                	mov    %edi,%eax
f0102b3a:	e8 9c e0 ff ff       	call   f0100bdb <check_va2pa>
f0102b3f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b42:	74 24                	je     f0102b68 <mem_init+0x165f>
f0102b44:	c7 44 24 0c 00 78 10 	movl   $0xf0107800,0xc(%esp)
f0102b4b:	f0 
f0102b4c:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102b53:	f0 
f0102b54:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f0102b5b:	00 
f0102b5c:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102b63:	e8 d8 d4 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void *)mm1, 0) & (PTE_W | PTE_PWT | PTE_PCD));
f0102b68:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b6f:	00 
f0102b70:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b74:	89 3c 24             	mov    %edi,(%esp)
f0102b77:	e8 68 e6 ff ff       	call   f01011e4 <pgdir_walk>
f0102b7c:	f6 00 1a             	testb  $0x1a,(%eax)
f0102b7f:	75 24                	jne    f0102ba5 <mem_init+0x169c>
f0102b81:	c7 44 24 0c 2c 78 10 	movl   $0xf010782c,0xc(%esp)
f0102b88:	f0 
f0102b89:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102b90:	f0 
f0102b91:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0102b98:	00 
f0102b99:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102ba0:	e8 9b d4 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *)mm1, 0) & PTE_U));
f0102ba5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102bac:	00 
f0102bad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102bb1:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102bb6:	89 04 24             	mov    %eax,(%esp)
f0102bb9:	e8 26 e6 ff ff       	call   f01011e4 <pgdir_walk>
f0102bbe:	f6 00 04             	testb  $0x4,(%eax)
f0102bc1:	74 24                	je     f0102be7 <mem_init+0x16de>
f0102bc3:	c7 44 24 0c 74 78 10 	movl   $0xf0107874,0xc(%esp)
f0102bca:	f0 
f0102bcb:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102bd2:	f0 
f0102bd3:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f0102bda:	00 
f0102bdb:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102be2:	e8 59 d4 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void *)mm1, 0) = 0;
f0102be7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102bee:	00 
f0102bef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102bf3:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102bf8:	89 04 24             	mov    %eax,(%esp)
f0102bfb:	e8 e4 e5 ff ff       	call   f01011e4 <pgdir_walk>
f0102c00:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void *)mm1 + PGSIZE, 0) = 0;
f0102c06:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102c0d:	00 
f0102c0e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c11:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102c15:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102c1a:	89 04 24             	mov    %eax,(%esp)
f0102c1d:	e8 c2 e5 ff ff       	call   f01011e4 <pgdir_walk>
f0102c22:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void *)mm2, 0) = 0;
f0102c28:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102c2f:	00 
f0102c30:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102c34:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102c39:	89 04 24             	mov    %eax,(%esp)
f0102c3c:	e8 a3 e5 ff ff       	call   f01011e4 <pgdir_walk>
f0102c41:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102c47:	c7 04 24 0b 7d 10 f0 	movl   $0xf0107d0b,(%esp)
f0102c4e:	e8 d2 12 00 00       	call   f0103f25 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, npages * sizeof(struct PageInfo), PADDR(pages), PTE_U);
f0102c53:	a1 90 0e 23 f0       	mov    0xf0230e90,%eax
	if ((uint32_t)kva < KERNBASE)
f0102c58:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c5d:	77 20                	ja     f0102c7f <mem_init+0x1776>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c63:	c7 44 24 08 68 6b 10 	movl   $0xf0106b68,0x8(%esp)
f0102c6a:	f0 
f0102c6b:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
f0102c72:	00 
f0102c73:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102c7a:	e8 c1 d3 ff ff       	call   f0100040 <_panic>
f0102c7f:	8b 0d 88 0e 23 f0    	mov    0xf0230e88,%ecx
f0102c85:	c1 e1 03             	shl    $0x3,%ecx
f0102c88:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102c8f:	00 
	return (physaddr_t)kva - KERNBASE;
f0102c90:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c95:	89 04 24             	mov    %eax,(%esp)
f0102c98:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102c9d:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102ca2:	e8 ce e6 ff ff       	call   f0101375 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, NENV * sizeof(struct Env), PADDR(envs), PTE_U);
f0102ca7:	a1 48 02 23 f0       	mov    0xf0230248,%eax
	if ((uint32_t)kva < KERNBASE)
f0102cac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102cb1:	77 20                	ja     f0102cd3 <mem_init+0x17ca>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cb7:	c7 44 24 08 68 6b 10 	movl   $0xf0106b68,0x8(%esp)
f0102cbe:	f0 
f0102cbf:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
f0102cc6:	00 
f0102cc7:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102cce:	e8 6d d3 ff ff       	call   f0100040 <_panic>
f0102cd3:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102cda:	00 
	return (physaddr_t)kva - KERNBASE;
f0102cdb:	05 00 00 00 10       	add    $0x10000000,%eax
f0102ce0:	89 04 24             	mov    %eax,(%esp)
f0102ce3:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102ce8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102ced:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102cf2:	e8 7e e6 ff ff       	call   f0101375 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102cf7:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0102cfc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d01:	77 20                	ja     f0102d23 <mem_init+0x181a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d03:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d07:	c7 44 24 08 68 6b 10 	movl   $0xf0106b68,0x8(%esp)
f0102d0e:	f0 
f0102d0f:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
f0102d16:	00 
f0102d17:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102d1e:	e8 1d d3 ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102d23:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102d2a:	00 
f0102d2b:	c7 04 24 00 70 11 00 	movl   $0x117000,(%esp)
f0102d32:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102d37:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102d3c:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102d41:	e8 2f e6 ff ff       	call   f0101375 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_W);
f0102d46:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102d4d:	00 
f0102d4e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d55:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102d5a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102d5f:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102d64:	e8 0c e6 ff ff       	call   f0101375 <boot_map_region>
f0102d69:	bf 00 20 27 f0       	mov    $0xf0272000,%edi
f0102d6e:	bb 00 20 23 f0       	mov    $0xf0232000,%ebx
f0102d73:	be 00 80 ff ef       	mov    $0xefff8000,%esi
	if ((uint32_t)kva < KERNBASE)
f0102d78:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102d7e:	77 20                	ja     f0102da0 <mem_init+0x1897>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d80:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102d84:	c7 44 24 08 68 6b 10 	movl   $0xf0106b68,0x8(%esp)
f0102d8b:	f0 
f0102d8c:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
f0102d93:	00 
f0102d94:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102d9b:	e8 a0 d2 ff ff       	call   f0100040 <_panic>
		boot_map_region(kern_pgdir, KSTACKTOP - i * (KSTKSIZE + KSTKGAP) - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W); // percpu_kstacks[i]指向的物理内存作为其内核堆栈映射到的地址
f0102da0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102da7:	00 
f0102da8:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102dae:	89 04 24             	mov    %eax,(%esp)
f0102db1:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102db6:	89 f2                	mov    %esi,%edx
f0102db8:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102dbd:	e8 b3 e5 ff ff       	call   f0101375 <boot_map_region>
f0102dc2:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102dc8:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	for (int i = 0; i < NCPU; i++)
f0102dce:	39 fb                	cmp    %edi,%ebx
f0102dd0:	75 a6                	jne    f0102d78 <mem_init+0x186f>
	pgdir = kern_pgdir;
f0102dd2:	8b 3d 8c 0e 23 f0    	mov    0xf0230e8c,%edi
	n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
f0102dd8:	a1 88 0e 23 f0       	mov    0xf0230e88,%eax
f0102ddd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102de0:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102de7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102dec:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102def:	8b 35 90 0e 23 f0    	mov    0xf0230e90,%esi
	if ((uint32_t)kva < KERNBASE)
f0102df5:	89 75 cc             	mov    %esi,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102df8:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0102dfe:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0102e01:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102e06:	eb 6a                	jmp    f0102e72 <mem_init+0x1969>
f0102e08:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e0e:	89 f8                	mov    %edi,%eax
f0102e10:	e8 c6 dd ff ff       	call   f0100bdb <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102e15:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102e1c:	77 20                	ja     f0102e3e <mem_init+0x1935>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e1e:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102e22:	c7 44 24 08 68 6b 10 	movl   $0xf0106b68,0x8(%esp)
f0102e29:	f0 
f0102e2a:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f0102e31:	00 
f0102e32:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102e39:	e8 02 d2 ff ff       	call   f0100040 <_panic>
f0102e3e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102e41:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102e44:	39 d0                	cmp    %edx,%eax
f0102e46:	74 24                	je     f0102e6c <mem_init+0x1963>
f0102e48:	c7 44 24 0c a8 78 10 	movl   $0xf01078a8,0xc(%esp)
f0102e4f:	f0 
f0102e50:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102e57:	f0 
f0102e58:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f0102e5f:	00 
f0102e60:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102e67:	e8 d4 d1 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f0102e6c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e72:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0102e75:	77 91                	ja     f0102e08 <mem_init+0x18ff>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e77:	8b 1d 48 02 23 f0    	mov    0xf0230248,%ebx
	if ((uint32_t)kva < KERNBASE)
f0102e7d:	89 de                	mov    %ebx,%esi
f0102e7f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102e84:	89 f8                	mov    %edi,%eax
f0102e86:	e8 50 dd ff ff       	call   f0100bdb <check_va2pa>
f0102e8b:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102e91:	77 20                	ja     f0102eb3 <mem_init+0x19aa>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e93:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102e97:	c7 44 24 08 68 6b 10 	movl   $0xf0106b68,0x8(%esp)
f0102e9e:	f0 
f0102e9f:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0102ea6:	00 
f0102ea7:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102eae:	e8 8d d1 ff ff       	call   f0100040 <_panic>
	if ((uint32_t)kva < KERNBASE)
f0102eb3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102eb8:	81 c6 00 00 40 21    	add    $0x21400000,%esi
f0102ebe:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102ec1:	39 d0                	cmp    %edx,%eax
f0102ec3:	74 24                	je     f0102ee9 <mem_init+0x19e0>
f0102ec5:	c7 44 24 0c dc 78 10 	movl   $0xf01078dc,0xc(%esp)
f0102ecc:	f0 
f0102ecd:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102ed4:	f0 
f0102ed5:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0102edc:	00 
f0102edd:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102ee4:	e8 57 d1 ff ff       	call   f0100040 <_panic>
f0102ee9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f0102eef:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102ef5:	0f 85 aa 05 00 00    	jne    f01034a5 <mem_init+0x1f9c>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102efb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102efe:	c1 e6 0c             	shl    $0xc,%esi
f0102f01:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102f06:	eb 3b                	jmp    f0102f43 <mem_init+0x1a3a>
f0102f08:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102f0e:	89 f8                	mov    %edi,%eax
f0102f10:	e8 c6 dc ff ff       	call   f0100bdb <check_va2pa>
f0102f15:	39 c3                	cmp    %eax,%ebx
f0102f17:	74 24                	je     f0102f3d <mem_init+0x1a34>
f0102f19:	c7 44 24 0c 10 79 10 	movl   $0xf0107910,0xc(%esp)
f0102f20:	f0 
f0102f21:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102f28:	f0 
f0102f29:	c7 44 24 04 ec 02 00 	movl   $0x2ec,0x4(%esp)
f0102f30:	00 
f0102f31:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102f38:	e8 03 d1 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102f3d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f43:	39 f3                	cmp    %esi,%ebx
f0102f45:	72 c1                	jb     f0102f08 <mem_init+0x19ff>
f0102f47:	c7 45 d0 00 20 23 f0 	movl   $0xf0232000,-0x30(%ebp)
f0102f4e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0102f55:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102f5a:	b8 00 20 23 f0       	mov    $0xf0232000,%eax
f0102f5f:	05 00 80 00 20       	add    $0x20008000,%eax
f0102f64:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102f67:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0102f6d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i) == PADDR(percpu_kstacks[n]) + i);
f0102f70:	89 f2                	mov    %esi,%edx
f0102f72:	89 f8                	mov    %edi,%eax
f0102f74:	e8 62 dc ff ff       	call   f0100bdb <check_va2pa>
f0102f79:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102f7c:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0102f82:	77 20                	ja     f0102fa4 <mem_init+0x1a9b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f84:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102f88:	c7 44 24 08 68 6b 10 	movl   $0xf0106b68,0x8(%esp)
f0102f8f:	f0 
f0102f90:	c7 44 24 04 f4 02 00 	movl   $0x2f4,0x4(%esp)
f0102f97:	00 
f0102f98:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102f9f:	e8 9c d0 ff ff       	call   f0100040 <_panic>
	if ((uint32_t)kva < KERNBASE)
f0102fa4:	89 f3                	mov    %esi,%ebx
f0102fa6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0102fa9:	03 4d d4             	add    -0x2c(%ebp),%ecx
f0102fac:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0102faf:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102fb2:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102fb5:	39 c2                	cmp    %eax,%edx
f0102fb7:	74 24                	je     f0102fdd <mem_init+0x1ad4>
f0102fb9:	c7 44 24 0c 38 79 10 	movl   $0xf0107938,0xc(%esp)
f0102fc0:	f0 
f0102fc1:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0102fc8:	f0 
f0102fc9:	c7 44 24 04 f4 02 00 	movl   $0x2f4,0x4(%esp)
f0102fd0:	00 
f0102fd1:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0102fd8:	e8 63 d0 ff ff       	call   f0100040 <_panic>
f0102fdd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102fe3:	3b 5d cc             	cmp    -0x34(%ebp),%ebx
f0102fe6:	0f 85 a9 04 00 00    	jne    f0103495 <mem_init+0x1f8c>
f0102fec:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102ff2:	89 da                	mov    %ebx,%edx
f0102ff4:	89 f8                	mov    %edi,%eax
f0102ff6:	e8 e0 db ff ff       	call   f0100bdb <check_va2pa>
f0102ffb:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102ffe:	74 24                	je     f0103024 <mem_init+0x1b1b>
f0103000:	c7 44 24 0c 80 79 10 	movl   $0xf0107980,0xc(%esp)
f0103007:	f0 
f0103008:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f010300f:	f0 
f0103010:	c7 44 24 04 f6 02 00 	movl   $0x2f6,0x4(%esp)
f0103017:	00 
f0103018:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f010301f:	e8 1c d0 ff ff       	call   f0100040 <_panic>
f0103024:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f010302a:	39 de                	cmp    %ebx,%esi
f010302c:	75 c4                	jne    f0102ff2 <mem_init+0x1ae9>
f010302e:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0103034:	81 45 d4 00 80 01 00 	addl   $0x18000,-0x2c(%ebp)
f010303b:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
	for (n = 0; n < NCPU; n++)
f0103042:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0103048:	0f 85 19 ff ff ff    	jne    f0102f67 <mem_init+0x1a5e>
f010304e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103053:	e9 c2 00 00 00       	jmp    f010311a <mem_init+0x1c11>
		switch (i)
f0103058:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f010305e:	83 fa 04             	cmp    $0x4,%edx
f0103061:	77 2e                	ja     f0103091 <mem_init+0x1b88>
			assert(pgdir[i] & PTE_P);
f0103063:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0103067:	0f 85 aa 00 00 00    	jne    f0103117 <mem_init+0x1c0e>
f010306d:	c7 44 24 0c 24 7d 10 	movl   $0xf0107d24,0xc(%esp)
f0103074:	f0 
f0103075:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f010307c:	f0 
f010307d:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f0103084:	00 
f0103085:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f010308c:	e8 af cf ff ff       	call   f0100040 <_panic>
			if (i >= PDX(KERNBASE))
f0103091:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103096:	76 55                	jbe    f01030ed <mem_init+0x1be4>
				assert(pgdir[i] & PTE_P);
f0103098:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010309b:	f6 c2 01             	test   $0x1,%dl
f010309e:	75 24                	jne    f01030c4 <mem_init+0x1bbb>
f01030a0:	c7 44 24 0c 24 7d 10 	movl   $0xf0107d24,0xc(%esp)
f01030a7:	f0 
f01030a8:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01030af:	f0 
f01030b0:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f01030b7:	00 
f01030b8:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01030bf:	e8 7c cf ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01030c4:	f6 c2 02             	test   $0x2,%dl
f01030c7:	75 4e                	jne    f0103117 <mem_init+0x1c0e>
f01030c9:	c7 44 24 0c 35 7d 10 	movl   $0xf0107d35,0xc(%esp)
f01030d0:	f0 
f01030d1:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01030d8:	f0 
f01030d9:	c7 44 24 04 09 03 00 	movl   $0x309,0x4(%esp)
f01030e0:	00 
f01030e1:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01030e8:	e8 53 cf ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f01030ed:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f01030f1:	74 24                	je     f0103117 <mem_init+0x1c0e>
f01030f3:	c7 44 24 0c 46 7d 10 	movl   $0xf0107d46,0xc(%esp)
f01030fa:	f0 
f01030fb:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0103102:	f0 
f0103103:	c7 44 24 04 0c 03 00 	movl   $0x30c,0x4(%esp)
f010310a:	00 
f010310b:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0103112:	e8 29 cf ff ff       	call   f0100040 <_panic>
	for (i = 0; i < NPDENTRIES; i++)
f0103117:	83 c0 01             	add    $0x1,%eax
f010311a:	3d 00 04 00 00       	cmp    $0x400,%eax
f010311f:	0f 85 33 ff ff ff    	jne    f0103058 <mem_init+0x1b4f>
	cprintf("check_kern_pgdir() succeeded!\n");
f0103125:	c7 04 24 a4 79 10 f0 	movl   $0xf01079a4,(%esp)
f010312c:	e8 f4 0d 00 00       	call   f0103f25 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0103131:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0103136:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010313b:	77 20                	ja     f010315d <mem_init+0x1c54>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010313d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103141:	c7 44 24 08 68 6b 10 	movl   $0xf0106b68,0x8(%esp)
f0103148:	f0 
f0103149:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f0103150:	00 
f0103151:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0103158:	e8 e3 ce ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010315d:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103162:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0103165:	b8 00 00 00 00       	mov    $0x0,%eax
f010316a:	e8 db da ff ff       	call   f0100c4a <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f010316f:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS | CR0_EM);
f0103172:	83 e0 f3             	and    $0xfffffff3,%eax
f0103175:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f010317a:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010317d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103184:	e8 67 df ff ff       	call   f01010f0 <page_alloc>
f0103189:	89 c3                	mov    %eax,%ebx
f010318b:	85 c0                	test   %eax,%eax
f010318d:	75 24                	jne    f01031b3 <mem_init+0x1caa>
f010318f:	c7 44 24 0c 87 7b 10 	movl   $0xf0107b87,0xc(%esp)
f0103196:	f0 
f0103197:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f010319e:	f0 
f010319f:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f01031a6:	00 
f01031a7:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01031ae:	e8 8d ce ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01031b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031ba:	e8 31 df ff ff       	call   f01010f0 <page_alloc>
f01031bf:	89 c7                	mov    %eax,%edi
f01031c1:	85 c0                	test   %eax,%eax
f01031c3:	75 24                	jne    f01031e9 <mem_init+0x1ce0>
f01031c5:	c7 44 24 0c 9d 7b 10 	movl   $0xf0107b9d,0xc(%esp)
f01031cc:	f0 
f01031cd:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01031d4:	f0 
f01031d5:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f01031dc:	00 
f01031dd:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01031e4:	e8 57 ce ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01031e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031f0:	e8 fb de ff ff       	call   f01010f0 <page_alloc>
f01031f5:	89 c6                	mov    %eax,%esi
f01031f7:	85 c0                	test   %eax,%eax
f01031f9:	75 24                	jne    f010321f <mem_init+0x1d16>
f01031fb:	c7 44 24 0c b3 7b 10 	movl   $0xf0107bb3,0xc(%esp)
f0103202:	f0 
f0103203:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f010320a:	f0 
f010320b:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0103212:	00 
f0103213:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f010321a:	e8 21 ce ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f010321f:	89 1c 24             	mov    %ebx,(%esp)
f0103222:	e8 5a df ff ff       	call   f0101181 <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0103227:	89 f8                	mov    %edi,%eax
f0103229:	e8 68 d9 ff ff       	call   f0100b96 <page2kva>
f010322e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103235:	00 
f0103236:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010323d:	00 
f010323e:	89 04 24             	mov    %eax,(%esp)
f0103241:	e8 a1 2b 00 00       	call   f0105de7 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0103246:	89 f0                	mov    %esi,%eax
f0103248:	e8 49 d9 ff ff       	call   f0100b96 <page2kva>
f010324d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103254:	00 
f0103255:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010325c:	00 
f010325d:	89 04 24             	mov    %eax,(%esp)
f0103260:	e8 82 2b 00 00       	call   f0105de7 <memset>
	page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W);
f0103265:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010326c:	00 
f010326d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103274:	00 
f0103275:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103279:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f010327e:	89 04 24             	mov    %eax,(%esp)
f0103281:	e8 9c e1 ff ff       	call   f0101422 <page_insert>
	assert(pp1->pp_ref == 1);
f0103286:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010328b:	74 24                	je     f01032b1 <mem_init+0x1da8>
f010328d:	c7 44 24 0c 2d 7c 10 	movl   $0xf0107c2d,0xc(%esp)
f0103294:	f0 
f0103295:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f010329c:	f0 
f010329d:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f01032a4:	00 
f01032a5:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01032ac:	e8 8f cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01032b1:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01032b8:	01 01 01 
f01032bb:	74 24                	je     f01032e1 <mem_init+0x1dd8>
f01032bd:	c7 44 24 0c c4 79 10 	movl   $0xf01079c4,0xc(%esp)
f01032c4:	f0 
f01032c5:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01032cc:	f0 
f01032cd:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f01032d4:	00 
f01032d5:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01032dc:	e8 5f cd ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W);
f01032e1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01032e8:	00 
f01032e9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01032f0:	00 
f01032f1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01032f5:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01032fa:	89 04 24             	mov    %eax,(%esp)
f01032fd:	e8 20 e1 ff ff       	call   f0101422 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103302:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103309:	02 02 02 
f010330c:	74 24                	je     f0103332 <mem_init+0x1e29>
f010330e:	c7 44 24 0c e8 79 10 	movl   $0xf01079e8,0xc(%esp)
f0103315:	f0 
f0103316:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f010331d:	f0 
f010331e:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0103325:	00 
f0103326:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f010332d:	e8 0e cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0103332:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103337:	74 24                	je     f010335d <mem_init+0x1e54>
f0103339:	c7 44 24 0c 4f 7c 10 	movl   $0xf0107c4f,0xc(%esp)
f0103340:	f0 
f0103341:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0103348:	f0 
f0103349:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f0103350:	00 
f0103351:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0103358:	e8 e3 cc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010335d:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103362:	74 24                	je     f0103388 <mem_init+0x1e7f>
f0103364:	c7 44 24 0c b9 7c 10 	movl   $0xf0107cb9,0xc(%esp)
f010336b:	f0 
f010336c:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0103373:	f0 
f0103374:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f010337b:	00 
f010337c:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0103383:	e8 b8 cc ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103388:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010338f:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103392:	89 f0                	mov    %esi,%eax
f0103394:	e8 fd d7 ff ff       	call   f0100b96 <page2kva>
f0103399:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f010339f:	74 24                	je     f01033c5 <mem_init+0x1ebc>
f01033a1:	c7 44 24 0c 0c 7a 10 	movl   $0xf0107a0c,0xc(%esp)
f01033a8:	f0 
f01033a9:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01033b0:	f0 
f01033b1:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f01033b8:	00 
f01033b9:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f01033c0:	e8 7b cc ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void *)PGSIZE);
f01033c5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01033cc:	00 
f01033cd:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01033d2:	89 04 24             	mov    %eax,(%esp)
f01033d5:	e8 ff df ff ff       	call   f01013d9 <page_remove>
	assert(pp2->pp_ref == 0);
f01033da:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01033df:	74 24                	je     f0103405 <mem_init+0x1efc>
f01033e1:	c7 44 24 0c 87 7c 10 	movl   $0xf0107c87,0xc(%esp)
f01033e8:	f0 
f01033e9:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f01033f0:	f0 
f01033f1:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f01033f8:	00 
f01033f9:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0103400:	e8 3b cc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103405:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f010340a:	8b 08                	mov    (%eax),%ecx
f010340c:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	return (pp - pages) << PGSHIFT;
f0103412:	89 da                	mov    %ebx,%edx
f0103414:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f010341a:	c1 fa 03             	sar    $0x3,%edx
f010341d:	c1 e2 0c             	shl    $0xc,%edx
f0103420:	39 d1                	cmp    %edx,%ecx
f0103422:	74 24                	je     f0103448 <mem_init+0x1f3f>
f0103424:	c7 44 24 0c 8c 73 10 	movl   $0xf010738c,0xc(%esp)
f010342b:	f0 
f010342c:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0103433:	f0 
f0103434:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f010343b:	00 
f010343c:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0103443:	e8 f8 cb ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103448:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010344e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103453:	74 24                	je     f0103479 <mem_init+0x1f70>
f0103455:	c7 44 24 0c 3e 7c 10 	movl   $0xf0107c3e,0xc(%esp)
f010345c:	f0 
f010345d:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f0103464:	f0 
f0103465:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f010346c:	00 
f010346d:	c7 04 24 99 7a 10 f0 	movl   $0xf0107a99,(%esp)
f0103474:	e8 c7 cb ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103479:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010347f:	89 1c 24             	mov    %ebx,(%esp)
f0103482:	e8 fa dc ff ff       	call   f0101181 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103487:	c7 04 24 38 7a 10 f0 	movl   $0xf0107a38,(%esp)
f010348e:	e8 92 0a 00 00       	call   f0103f25 <cprintf>
f0103493:	eb 20                	jmp    f01034b5 <mem_init+0x1fac>
			assert(check_va2pa(pgdir, base + KSTKGAP + i) == PADDR(percpu_kstacks[n]) + i);
f0103495:	89 da                	mov    %ebx,%edx
f0103497:	89 f8                	mov    %edi,%eax
f0103499:	e8 3d d7 ff ff       	call   f0100bdb <check_va2pa>
f010349e:	66 90                	xchg   %ax,%ax
f01034a0:	e9 0a fb ff ff       	jmp    f0102faf <mem_init+0x1aa6>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01034a5:	89 da                	mov    %ebx,%edx
f01034a7:	89 f8                	mov    %edi,%eax
f01034a9:	e8 2d d7 ff ff       	call   f0100bdb <check_va2pa>
f01034ae:	66 90                	xchg   %ax,%ax
f01034b0:	e9 09 fa ff ff       	jmp    f0102ebe <mem_init+0x19b5>
}
f01034b5:	83 c4 4c             	add    $0x4c,%esp
f01034b8:	5b                   	pop    %ebx
f01034b9:	5e                   	pop    %esi
f01034ba:	5f                   	pop    %edi
f01034bb:	5d                   	pop    %ebp
f01034bc:	c3                   	ret    

f01034bd <user_mem_check>:
{
f01034bd:	55                   	push   %ebp
f01034be:	89 e5                	mov    %esp,%ebp
f01034c0:	57                   	push   %edi
f01034c1:	56                   	push   %esi
f01034c2:	53                   	push   %ebx
f01034c3:	83 ec 1c             	sub    $0x1c,%esp
f01034c6:	8b 7d 08             	mov    0x8(%ebp),%edi
	const void *start = ROUNDDOWN(va, PGSIZE);
f01034c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01034cc:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	const void *end = ROUNDUP(va + len, PGSIZE);
f01034d2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034d5:	03 45 10             	add    0x10(%ebp),%eax
f01034d8:	05 ff 0f 00 00       	add    $0xfff,%eax
f01034dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01034e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (!pte || (*pte & (perm | PTE_P)) != (perm | PTE_P)) // 确认权限，&操作可以得到那几个权限位来判断
f01034e5:	8b 75 14             	mov    0x14(%ebp),%esi
f01034e8:	83 ce 01             	or     $0x1,%esi
	for (; start < end; start += PGSIZE) // 遍历每一页
f01034eb:	eb 3d                	jmp    f010352a <user_mem_check+0x6d>
		pte_t *pte = pgdir_walk(env->env_pgdir, start, 0);	   // 找到pte,pte只能在ULIM下方，因此若pte存在，则地址存在
f01034ed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01034f4:	00 
f01034f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01034f9:	8b 47 60             	mov    0x60(%edi),%eax
f01034fc:	89 04 24             	mov    %eax,(%esp)
f01034ff:	e8 e0 dc ff ff       	call   f01011e4 <pgdir_walk>
		if (!pte || (*pte & (perm | PTE_P)) != (perm | PTE_P)) // 确认权限，&操作可以得到那几个权限位来判断
f0103504:	85 c0                	test   %eax,%eax
f0103506:	74 08                	je     f0103510 <user_mem_check+0x53>
f0103508:	89 f2                	mov    %esi,%edx
f010350a:	23 10                	and    (%eax),%edx
f010350c:	39 d6                	cmp    %edx,%esi
f010350e:	74 14                	je     f0103524 <user_mem_check+0x67>
			user_mem_check_addr = (uintptr_t)MAX(start, va); // 第一个错误的虚拟地址
f0103510:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0103513:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0103517:	89 1d 3c 02 23 f0    	mov    %ebx,0xf023023c
			return -E_FAULT;								 // 提前返回
f010351d:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103522:	eb 10                	jmp    f0103534 <user_mem_check+0x77>
	for (; start < end; start += PGSIZE) // 遍历每一页
f0103524:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010352a:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010352d:	72 be                	jb     f01034ed <user_mem_check+0x30>
	return 0;
f010352f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103534:	83 c4 1c             	add    $0x1c,%esp
f0103537:	5b                   	pop    %ebx
f0103538:	5e                   	pop    %esi
f0103539:	5f                   	pop    %edi
f010353a:	5d                   	pop    %ebp
f010353b:	c3                   	ret    

f010353c <user_mem_assert>:
{
f010353c:	55                   	push   %ebp
f010353d:	89 e5                	mov    %esp,%ebp
f010353f:	53                   	push   %ebx
f0103540:	83 ec 14             	sub    $0x14,%esp
f0103543:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0)
f0103546:	8b 45 14             	mov    0x14(%ebp),%eax
f0103549:	83 c8 04             	or     $0x4,%eax
f010354c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103550:	8b 45 10             	mov    0x10(%ebp),%eax
f0103553:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103557:	8b 45 0c             	mov    0xc(%ebp),%eax
f010355a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010355e:	89 1c 24             	mov    %ebx,(%esp)
f0103561:	e8 57 ff ff ff       	call   f01034bd <user_mem_check>
f0103566:	85 c0                	test   %eax,%eax
f0103568:	79 24                	jns    f010358e <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f010356a:	a1 3c 02 23 f0       	mov    0xf023023c,%eax
f010356f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103573:	8b 43 48             	mov    0x48(%ebx),%eax
f0103576:	89 44 24 04          	mov    %eax,0x4(%esp)
f010357a:	c7 04 24 64 7a 10 f0 	movl   $0xf0107a64,(%esp)
f0103581:	e8 9f 09 00 00       	call   f0103f25 <cprintf>
		env_destroy(env); // may not return
f0103586:	89 1c 24             	mov    %ebx,(%esp)
f0103589:	e8 d2 06 00 00       	call   f0103c60 <env_destroy>
}
f010358e:	83 c4 14             	add    $0x14,%esp
f0103591:	5b                   	pop    %ebx
f0103592:	5d                   	pop    %ebp
f0103593:	c3                   	ret    

f0103594 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
// 为环境 env 分配 len 字节的物理内存，并将其映射到环境地址空间中的虚拟地址 va。
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103594:	55                   	push   %ebp
f0103595:	89 e5                	mov    %esp,%ebp
f0103597:	57                   	push   %edi
f0103598:	56                   	push   %esi
f0103599:	53                   	push   %ebx
f010359a:	83 ec 1c             	sub    $0x1c,%esp
f010359d:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *start = ROUNDDOWN(va, PGSIZE);
f010359f:	89 d3                	mov    %edx,%ebx
f01035a1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	void *end = ROUNDUP(va + len, PGSIZE);
f01035a7:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f01035ae:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (; start < end; start += PGSIZE)
f01035b4:	eb 6d                	jmp    f0103623 <region_alloc+0x8f>
	{
		struct PageInfo *p = page_alloc(0);
f01035b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035bd:	e8 2e db ff ff       	call   f01010f0 <page_alloc>
		if (p == NULL)
f01035c2:	85 c0                	test   %eax,%eax
f01035c4:	75 1c                	jne    f01035e2 <region_alloc+0x4e>
		{
			panic("region_alloc: error in page_alloc()\n"); // 分配失败
f01035c6:	c7 44 24 08 54 7d 10 	movl   $0xf0107d54,0x8(%esp)
f01035cd:	f0 
f01035ce:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
f01035d5:	00 
f01035d6:	c7 04 24 ed 7d 10 f0 	movl   $0xf0107ded,(%esp)
f01035dd:	e8 5e ca ff ff       	call   f0100040 <_panic>
		}
		if (page_insert(e->env_pgdir, p, start, PTE_W | PTE_U))
f01035e2:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01035e9:	00 
f01035ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01035ee:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035f2:	8b 47 60             	mov    0x60(%edi),%eax
f01035f5:	89 04 24             	mov    %eax,(%esp)
f01035f8:	e8 25 de ff ff       	call   f0101422 <page_insert>
f01035fd:	85 c0                	test   %eax,%eax
f01035ff:	74 1c                	je     f010361d <region_alloc+0x89>
		{
			panic("region_alloc: error in page_insert()\n"); // 插入失败
f0103601:	c7 44 24 08 7c 7d 10 	movl   $0xf0107d7c,0x8(%esp)
f0103608:	f0 
f0103609:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
f0103610:	00 
f0103611:	c7 04 24 ed 7d 10 f0 	movl   $0xf0107ded,(%esp)
f0103618:	e8 23 ca ff ff       	call   f0100040 <_panic>
	for (; start < end; start += PGSIZE)
f010361d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103623:	39 f3                	cmp    %esi,%ebx
f0103625:	72 8f                	jb     f01035b6 <region_alloc+0x22>
		}
	}
}
f0103627:	83 c4 1c             	add    $0x1c,%esp
f010362a:	5b                   	pop    %ebx
f010362b:	5e                   	pop    %esi
f010362c:	5f                   	pop    %edi
f010362d:	5d                   	pop    %ebp
f010362e:	c3                   	ret    

f010362f <envid2env>:
{
f010362f:	55                   	push   %ebp
f0103630:	89 e5                	mov    %esp,%ebp
f0103632:	56                   	push   %esi
f0103633:	53                   	push   %ebx
f0103634:	8b 45 08             	mov    0x8(%ebp),%eax
f0103637:	8b 55 10             	mov    0x10(%ebp),%edx
	if (envid == 0)
f010363a:	85 c0                	test   %eax,%eax
f010363c:	75 1a                	jne    f0103658 <envid2env+0x29>
		*env_store = curenv;
f010363e:	e8 f6 2d 00 00       	call   f0106439 <cpunum>
f0103643:	6b c0 74             	imul   $0x74,%eax,%eax
f0103646:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f010364c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010364f:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103651:	b8 00 00 00 00       	mov    $0x0,%eax
f0103656:	eb 70                	jmp    f01036c8 <envid2env+0x99>
	e = &envs[ENVX(envid)];
f0103658:	89 c3                	mov    %eax,%ebx
f010365a:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103660:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103663:	03 1d 48 02 23 f0    	add    0xf0230248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid)
f0103669:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010366d:	74 05                	je     f0103674 <envid2env+0x45>
f010366f:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103672:	74 10                	je     f0103684 <envid2env+0x55>
		*env_store = 0;
f0103674:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103677:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010367d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103682:	eb 44                	jmp    f01036c8 <envid2env+0x99>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id)
f0103684:	84 d2                	test   %dl,%dl
f0103686:	74 36                	je     f01036be <envid2env+0x8f>
f0103688:	e8 ac 2d 00 00       	call   f0106439 <cpunum>
f010368d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103690:	39 98 28 10 23 f0    	cmp    %ebx,-0xfdcefd8(%eax)
f0103696:	74 26                	je     f01036be <envid2env+0x8f>
f0103698:	8b 73 4c             	mov    0x4c(%ebx),%esi
f010369b:	e8 99 2d 00 00       	call   f0106439 <cpunum>
f01036a0:	6b c0 74             	imul   $0x74,%eax,%eax
f01036a3:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f01036a9:	3b 70 48             	cmp    0x48(%eax),%esi
f01036ac:	74 10                	je     f01036be <envid2env+0x8f>
		*env_store = 0;
f01036ae:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036b1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01036b7:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01036bc:	eb 0a                	jmp    f01036c8 <envid2env+0x99>
	*env_store = e;
f01036be:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036c1:	89 18                	mov    %ebx,(%eax)
	return 0;
f01036c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01036c8:	5b                   	pop    %ebx
f01036c9:	5e                   	pop    %esi
f01036ca:	5d                   	pop    %ebp
f01036cb:	c3                   	ret    

f01036cc <env_init_percpu>:
{
f01036cc:	55                   	push   %ebp
f01036cd:	89 e5                	mov    %esp,%ebp
	asm volatile("lgdt (%0)" : : "r" (p));
f01036cf:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f01036d4:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs"
f01036d7:	b8 23 00 00 00       	mov    $0x23,%eax
f01036dc:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs"
f01036de:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es"
f01036e0:	b0 10                	mov    $0x10,%al
f01036e2:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds"
f01036e4:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss"
f01036e6:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n"
f01036e8:	ea ef 36 10 f0 08 00 	ljmp   $0x8,$0xf01036ef
	asm volatile("lldt %0" : : "r" (sel));
f01036ef:	b0 00                	mov    $0x0,%al
f01036f1:	0f 00 d0             	lldt   %ax
}
f01036f4:	5d                   	pop    %ebp
f01036f5:	c3                   	ret    

f01036f6 <env_init>:
{
f01036f6:	55                   	push   %ebp
f01036f7:	89 e5                	mov    %esp,%ebp
f01036f9:	56                   	push   %esi
f01036fa:	53                   	push   %ebx
		envs[i].env_id = 0;
f01036fb:	8b 35 48 02 23 f0    	mov    0xf0230248,%esi
f0103701:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103707:	ba 00 04 00 00       	mov    $0x400,%edx
f010370c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103711:	89 c3                	mov    %eax,%ebx
f0103713:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status = ENV_FREE;
f010371a:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link = env_free_list;
f0103721:	89 48 44             	mov    %ecx,0x44(%eax)
f0103724:	83 e8 7c             	sub    $0x7c,%eax
	for (int i = NENV - 1; i >= 0; i--) // 倒着遍历数组，让最后的元素出现在链表底部
f0103727:	83 ea 01             	sub    $0x1,%edx
f010372a:	74 04                	je     f0103730 <env_init+0x3a>
		env_free_list = &envs[i];
f010372c:	89 d9                	mov    %ebx,%ecx
f010372e:	eb e1                	jmp    f0103711 <env_init+0x1b>
f0103730:	89 35 4c 02 23 f0    	mov    %esi,0xf023024c
	env_init_percpu();
f0103736:	e8 91 ff ff ff       	call   f01036cc <env_init_percpu>
}
f010373b:	5b                   	pop    %ebx
f010373c:	5e                   	pop    %esi
f010373d:	5d                   	pop    %ebp
f010373e:	c3                   	ret    

f010373f <env_alloc>:
{
f010373f:	55                   	push   %ebp
f0103740:	89 e5                	mov    %esp,%ebp
f0103742:	53                   	push   %ebx
f0103743:	83 ec 14             	sub    $0x14,%esp
	if (!(e = env_free_list)) // 如果env_free_list==null就会在这
f0103746:	8b 1d 4c 02 23 f0    	mov    0xf023024c,%ebx
f010374c:	85 db                	test   %ebx,%ebx
f010374e:	0f 84 8e 01 00 00    	je     f01038e2 <env_alloc+0x1a3>
	if (!(p = page_alloc(ALLOC_ZERO))) // 分配一页给页表目录
f0103754:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010375b:	e8 90 d9 ff ff       	call   f01010f0 <page_alloc>
f0103760:	85 c0                	test   %eax,%eax
f0103762:	0f 84 81 01 00 00    	je     f01038e9 <env_alloc+0x1aa>
	p->pp_ref++;
f0103768:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f010376d:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f0103773:	c1 f8 03             	sar    $0x3,%eax
f0103776:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103779:	89 c2                	mov    %eax,%edx
f010377b:	c1 ea 0c             	shr    $0xc,%edx
f010377e:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f0103784:	72 20                	jb     f01037a6 <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103786:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010378a:	c7 44 24 08 44 6b 10 	movl   $0xf0106b44,0x8(%esp)
f0103791:	f0 
f0103792:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103799:	00 
f010379a:	c7 04 24 a5 7a 10 f0 	movl   $0xf0107aa5,(%esp)
f01037a1:	e8 9a c8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01037a6:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = page2kva(p);
f01037ab:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE); // 把内核页表复制一份放在用户能访问的用户空间里(即env_pgdir处)
f01037ae:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01037b5:	00 
f01037b6:	8b 15 8c 0e 23 f0    	mov    0xf0230e8c,%edx
f01037bc:	89 54 24 04          	mov    %edx,0x4(%esp)
f01037c0:	89 04 24             	mov    %eax,(%esp)
f01037c3:	e8 d4 26 00 00       	call   f0105e9c <memcpy>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01037c8:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01037cb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037d0:	77 20                	ja     f01037f2 <env_alloc+0xb3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037d6:	c7 44 24 08 68 6b 10 	movl   $0xf0106b68,0x8(%esp)
f01037dd:	f0 
f01037de:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
f01037e5:	00 
f01037e6:	c7 04 24 ed 7d 10 f0 	movl   $0xf0107ded,(%esp)
f01037ed:	e8 4e c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01037f2:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01037f8:	83 ca 05             	or     $0x5,%edx
f01037fb:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103801:	8b 43 48             	mov    0x48(%ebx),%eax
f0103804:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0) // Don't create a negative env_id.
f0103809:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f010380e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103813:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103816:	89 da                	mov    %ebx,%edx
f0103818:	2b 15 48 02 23 f0    	sub    0xf0230248,%edx
f010381e:	c1 fa 02             	sar    $0x2,%edx
f0103821:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103827:	09 d0                	or     %edx,%eax
f0103829:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f010382c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010382f:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103832:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103839:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103840:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103847:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f010384e:	00 
f010384f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103856:	00 
f0103857:	89 1c 24             	mov    %ebx,(%esp)
f010385a:	e8 88 25 00 00       	call   f0105de7 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f010385f:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103865:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010386b:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103871:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103878:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_tf.tf_eflags |= FL_IF;
f010387e:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f0103885:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f010388c:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f0103890:	8b 43 44             	mov    0x44(%ebx),%eax
f0103893:	a3 4c 02 23 f0       	mov    %eax,0xf023024c
	*newenv_store = e;
f0103898:	8b 45 08             	mov    0x8(%ebp),%eax
f010389b:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010389d:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01038a0:	e8 94 2b 00 00       	call   f0106439 <cpunum>
f01038a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01038a8:	ba 00 00 00 00       	mov    $0x0,%edx
f01038ad:	83 b8 28 10 23 f0 00 	cmpl   $0x0,-0xfdcefd8(%eax)
f01038b4:	74 11                	je     f01038c7 <env_alloc+0x188>
f01038b6:	e8 7e 2b 00 00       	call   f0106439 <cpunum>
f01038bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01038be:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f01038c4:	8b 50 48             	mov    0x48(%eax),%edx
f01038c7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01038cb:	89 54 24 04          	mov    %edx,0x4(%esp)
f01038cf:	c7 04 24 f8 7d 10 f0 	movl   $0xf0107df8,(%esp)
f01038d6:	e8 4a 06 00 00       	call   f0103f25 <cprintf>
	return 0;
f01038db:	b8 00 00 00 00       	mov    $0x0,%eax
f01038e0:	eb 0c                	jmp    f01038ee <env_alloc+0x1af>
		return -E_NO_FREE_ENV;
f01038e2:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01038e7:	eb 05                	jmp    f01038ee <env_alloc+0x1af>
		return -E_NO_MEM;
f01038e9:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
f01038ee:	83 c4 14             	add    $0x14,%esp
f01038f1:	5b                   	pop    %ebx
f01038f2:	5d                   	pop    %ebp
f01038f3:	c3                   	ret    

f01038f4 <env_create>:
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
// 使用 env_alloc 分配一个新环境，使用 load_icode 将命名的 elf 二进制文件加载到其中，并设置其 env_type
void env_create(uint8_t *binary, enum EnvType type)
{
f01038f4:	55                   	push   %ebp
f01038f5:	89 e5                	mov    %esp,%ebp
f01038f7:	57                   	push   %edi
f01038f8:	56                   	push   %esi
f01038f9:	53                   	push   %ebx
f01038fa:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 3: Your code here.
	struct Env *e;
	if (env_alloc(&e, 0))
f01038fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103904:	00 
f0103905:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103908:	89 04 24             	mov    %eax,(%esp)
f010390b:	e8 2f fe ff ff       	call   f010373f <env_alloc>
f0103910:	85 c0                	test   %eax,%eax
f0103912:	74 1c                	je     f0103930 <env_create+0x3c>
	{
		panic("env_create: error in env_alloc()");
f0103914:	c7 44 24 08 a4 7d 10 	movl   $0xf0107da4,0x8(%esp)
f010391b:	f0 
f010391c:	c7 44 24 04 a1 01 00 	movl   $0x1a1,0x4(%esp)
f0103923:	00 
f0103924:	c7 04 24 ed 7d 10 f0 	movl   $0xf0107ded,(%esp)
f010392b:	e8 10 c7 ff ff       	call   f0100040 <_panic>
	}
	load_icode(e, binary);
f0103930:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	if (ELFHDR->e_magic != ELF_MAGIC)
f0103933:	8b 45 08             	mov    0x8(%ebp),%eax
f0103936:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f010393c:	74 1c                	je     f010395a <env_create+0x66>
		panic("load_icode: ELFHDR is not ELF_MAGIC\n");
f010393e:	c7 44 24 08 c8 7d 10 	movl   $0xf0107dc8,0x8(%esp)
f0103945:	f0 
f0103946:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
f010394d:	00 
f010394e:	c7 04 24 ed 7d 10 f0 	movl   $0xf0107ded,(%esp)
f0103955:	e8 e6 c6 ff ff       	call   f0100040 <_panic>
	ph = (struct Proghdr *)((uint8_t *)ELFHDR + ELFHDR->e_phoff); // ELFHDR+offset是段的起始地址
f010395a:	8b 45 08             	mov    0x8(%ebp),%eax
f010395d:	89 c3                	mov    %eax,%ebx
f010395f:	03 58 1c             	add    0x1c(%eax),%ebx
	eph = ph + ELFHDR->e_phnum;									  // end地址
f0103962:	0f b7 70 2c          	movzwl 0x2c(%eax),%esi
f0103966:	c1 e6 05             	shl    $0x5,%esi
f0103969:	01 de                	add    %ebx,%esi
	lcr3(PADDR(e->env_pgdir));									  // 切换到用户空间
f010396b:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f010396e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103973:	77 20                	ja     f0103995 <env_create+0xa1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103975:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103979:	c7 44 24 08 68 6b 10 	movl   $0xf0106b68,0x8(%esp)
f0103980:	f0 
f0103981:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f0103988:	00 
f0103989:	c7 04 24 ed 7d 10 f0 	movl   $0xf0107ded,(%esp)
f0103990:	e8 ab c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103995:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010399a:	0f 22 d8             	mov    %eax,%cr3
f010399d:	eb 4b                	jmp    f01039ea <env_create+0xf6>
		if (ph->p_type == ELF_PROG_LOAD)
f010399f:	83 3b 01             	cmpl   $0x1,(%ebx)
f01039a2:	75 43                	jne    f01039e7 <env_create+0xf3>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);						   // 先分配内存空间
f01039a4:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01039a7:	8b 53 08             	mov    0x8(%ebx),%edx
f01039aa:	89 f8                	mov    %edi,%eax
f01039ac:	e8 e3 fb ff ff       	call   f0103594 <region_alloc>
			memset((void *)ph->p_va, 0, ph->p_memsz);							   // 将内存空间初始化为0
f01039b1:	8b 43 14             	mov    0x14(%ebx),%eax
f01039b4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01039bf:	00 
f01039c0:	8b 43 08             	mov    0x8(%ebx),%eax
f01039c3:	89 04 24             	mov    %eax,(%esp)
f01039c6:	e8 1c 24 00 00       	call   f0105de7 <memset>
			memcpy((void *)ph->p_va, (void *)ELFHDR + ph->p_offset, ph->p_filesz); // 复制内容到刚刚分配的空间
f01039cb:	8b 43 10             	mov    0x10(%ebx),%eax
f01039ce:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01039d5:	03 43 04             	add    0x4(%ebx),%eax
f01039d8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039dc:	8b 43 08             	mov    0x8(%ebx),%eax
f01039df:	89 04 24             	mov    %eax,(%esp)
f01039e2:	e8 b5 24 00 00       	call   f0105e9c <memcpy>
	for (; ph < eph; ph++)										  // 依次读取所有段
f01039e7:	83 c3 20             	add    $0x20,%ebx
f01039ea:	39 de                	cmp    %ebx,%esi
f01039ec:	77 b1                	ja     f010399f <env_create+0xab>
	lcr3(PADDR(kern_pgdir));							 // 切换到内核空间
f01039ee:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01039f3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039f8:	77 20                	ja     f0103a1a <env_create+0x126>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039fe:	c7 44 24 08 68 6b 10 	movl   $0xf0106b68,0x8(%esp)
f0103a05:	f0 
f0103a06:	c7 44 24 04 8d 01 00 	movl   $0x18d,0x4(%esp)
f0103a0d:	00 
f0103a0e:	c7 04 24 ed 7d 10 f0 	movl   $0xf0107ded,(%esp)
f0103a15:	e8 26 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a1a:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a1f:	0f 22 d8             	mov    %eax,%cr3
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE); // 为程序的初始堆栈(地址:USTACKTOP - PGSIZE)映射一页
f0103a22:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103a27:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103a2c:	89 f8                	mov    %edi,%eax
f0103a2e:	e8 61 fb ff ff       	call   f0103594 <region_alloc>
	e->env_status = ENV_RUNNABLE;						 // 设置程序状态
f0103a33:	c7 47 54 02 00 00 00 	movl   $0x2,0x54(%edi)
	e->env_tf.tf_esp = USTACKTOP;						 // 设置程序堆栈
f0103a3a:	c7 47 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%edi)
	e->env_tf.tf_eip = ELFHDR->e_entry;					 // 设置程序入口
f0103a41:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a44:	8b 40 18             	mov    0x18(%eax),%eax
f0103a47:	89 47 30             	mov    %eax,0x30(%edi)
	e->env_type = type;
f0103a4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a4d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103a50:	89 50 50             	mov    %edx,0x50(%eax)
}
f0103a53:	83 c4 2c             	add    $0x2c,%esp
f0103a56:	5b                   	pop    %ebx
f0103a57:	5e                   	pop    %esi
f0103a58:	5f                   	pop    %edi
f0103a59:	5d                   	pop    %ebp
f0103a5a:	c3                   	ret    

f0103a5b <env_free>:

//
// Frees env e and all memory it uses.
//
void env_free(struct Env *e)
{
f0103a5b:	55                   	push   %ebp
f0103a5c:	89 e5                	mov    %esp,%ebp
f0103a5e:	57                   	push   %edi
f0103a5f:	56                   	push   %esi
f0103a60:	53                   	push   %ebx
f0103a61:	83 ec 2c             	sub    $0x2c,%esp
f0103a64:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103a67:	e8 cd 29 00 00       	call   f0106439 <cpunum>
f0103a6c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a6f:	39 b8 28 10 23 f0    	cmp    %edi,-0xfdcefd8(%eax)
f0103a75:	75 34                	jne    f0103aab <env_free+0x50>
		lcr3(PADDR(kern_pgdir));
f0103a77:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103a7c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a81:	77 20                	ja     f0103aa3 <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a83:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a87:	c7 44 24 08 68 6b 10 	movl   $0xf0106b68,0x8(%esp)
f0103a8e:	f0 
f0103a8f:	c7 44 24 04 b4 01 00 	movl   $0x1b4,0x4(%esp)
f0103a96:	00 
f0103a97:	c7 04 24 ed 7d 10 f0 	movl   $0xf0107ded,(%esp)
f0103a9e:	e8 9d c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103aa3:	05 00 00 00 10       	add    $0x10000000,%eax
f0103aa8:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103aab:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103aae:	e8 86 29 00 00       	call   f0106439 <cpunum>
f0103ab3:	6b d0 74             	imul   $0x74,%eax,%edx
f0103ab6:	b8 00 00 00 00       	mov    $0x0,%eax
f0103abb:	83 ba 28 10 23 f0 00 	cmpl   $0x0,-0xfdcefd8(%edx)
f0103ac2:	74 11                	je     f0103ad5 <env_free+0x7a>
f0103ac4:	e8 70 29 00 00       	call   f0106439 <cpunum>
f0103ac9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103acc:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103ad2:	8b 40 48             	mov    0x48(%eax),%eax
f0103ad5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103ad9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103add:	c7 04 24 0d 7e 10 f0 	movl   $0xf0107e0d,(%esp)
f0103ae4:	e8 3c 04 00 00       	call   f0103f25 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++)
f0103ae9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103af0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103af3:	89 c8                	mov    %ecx,%eax
f0103af5:	c1 e0 02             	shl    $0x2,%eax
f0103af8:	89 45 dc             	mov    %eax,-0x24(%ebp)
	{

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103afb:	8b 47 60             	mov    0x60(%edi),%eax
f0103afe:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f0103b01:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103b07:	0f 84 b7 00 00 00    	je     f0103bc4 <env_free+0x169>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b0d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0103b13:	89 f0                	mov    %esi,%eax
f0103b15:	c1 e8 0c             	shr    $0xc,%eax
f0103b18:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103b1b:	3b 05 88 0e 23 f0    	cmp    0xf0230e88,%eax
f0103b21:	72 20                	jb     f0103b43 <env_free+0xe8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b23:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103b27:	c7 44 24 08 44 6b 10 	movl   $0xf0106b44,0x8(%esp)
f0103b2e:	f0 
f0103b2f:	c7 44 24 04 c4 01 00 	movl   $0x1c4,0x4(%esp)
f0103b36:	00 
f0103b37:	c7 04 24 ed 7d 10 f0 	movl   $0xf0107ded,(%esp)
f0103b3e:	e8 fd c4 ff ff       	call   f0100040 <_panic>

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++)
		{
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b43:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b46:	c1 e0 16             	shl    $0x16,%eax
f0103b49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++)
f0103b4c:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103b51:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103b58:	01 
f0103b59:	74 17                	je     f0103b72 <env_free+0x117>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b5b:	89 d8                	mov    %ebx,%eax
f0103b5d:	c1 e0 0c             	shl    $0xc,%eax
f0103b60:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103b63:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b67:	8b 47 60             	mov    0x60(%edi),%eax
f0103b6a:	89 04 24             	mov    %eax,(%esp)
f0103b6d:	e8 67 d8 ff ff       	call   f01013d9 <page_remove>
		for (pteno = 0; pteno <= PTX(~0); pteno++)
f0103b72:	83 c3 01             	add    $0x1,%ebx
f0103b75:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103b7b:	75 d4                	jne    f0103b51 <env_free+0xf6>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103b7d:	8b 47 60             	mov    0x60(%edi),%eax
f0103b80:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b83:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103b8a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103b8d:	3b 05 88 0e 23 f0    	cmp    0xf0230e88,%eax
f0103b93:	72 1c                	jb     f0103bb1 <env_free+0x156>
		panic("pa2page called with invalid pa");
f0103b95:	c7 44 24 08 94 71 10 	movl   $0xf0107194,0x8(%esp)
f0103b9c:	f0 
f0103b9d:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103ba4:	00 
f0103ba5:	c7 04 24 a5 7a 10 f0 	movl   $0xf0107aa5,(%esp)
f0103bac:	e8 8f c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103bb1:	a1 90 0e 23 f0       	mov    0xf0230e90,%eax
f0103bb6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103bb9:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0103bbc:	89 04 24             	mov    %eax,(%esp)
f0103bbf:	e8 fd d5 ff ff       	call   f01011c1 <page_decref>
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++)
f0103bc4:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103bc8:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103bcf:	0f 85 1b ff ff ff    	jne    f0103af0 <env_free+0x95>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103bd5:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103bd8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bdd:	77 20                	ja     f0103bff <env_free+0x1a4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103bdf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103be3:	c7 44 24 08 68 6b 10 	movl   $0xf0106b68,0x8(%esp)
f0103bea:	f0 
f0103beb:	c7 44 24 04 d3 01 00 	movl   $0x1d3,0x4(%esp)
f0103bf2:	00 
f0103bf3:	c7 04 24 ed 7d 10 f0 	movl   $0xf0107ded,(%esp)
f0103bfa:	e8 41 c4 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103bff:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103c06:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103c0b:	c1 e8 0c             	shr    $0xc,%eax
f0103c0e:	3b 05 88 0e 23 f0    	cmp    0xf0230e88,%eax
f0103c14:	72 1c                	jb     f0103c32 <env_free+0x1d7>
		panic("pa2page called with invalid pa");
f0103c16:	c7 44 24 08 94 71 10 	movl   $0xf0107194,0x8(%esp)
f0103c1d:	f0 
f0103c1e:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c25:	00 
f0103c26:	c7 04 24 a5 7a 10 f0 	movl   $0xf0107aa5,(%esp)
f0103c2d:	e8 0e c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103c32:	8b 15 90 0e 23 f0    	mov    0xf0230e90,%edx
f0103c38:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0103c3b:	89 04 24             	mov    %eax,(%esp)
f0103c3e:	e8 7e d5 ff ff       	call   f01011c1 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103c43:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103c4a:	a1 4c 02 23 f0       	mov    0xf023024c,%eax
f0103c4f:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103c52:	89 3d 4c 02 23 f0    	mov    %edi,0xf023024c
}
f0103c58:	83 c4 2c             	add    $0x2c,%esp
f0103c5b:	5b                   	pop    %ebx
f0103c5c:	5e                   	pop    %esi
f0103c5d:	5f                   	pop    %edi
f0103c5e:	5d                   	pop    %ebp
f0103c5f:	c3                   	ret    

f0103c60 <env_destroy>:
// Frees environment e.
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void env_destroy(struct Env *e)
{
f0103c60:	55                   	push   %ebp
f0103c61:	89 e5                	mov    %esp,%ebp
f0103c63:	53                   	push   %ebx
f0103c64:	83 ec 14             	sub    $0x14,%esp
f0103c67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c6a:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103c6e:	75 19                	jne    f0103c89 <env_destroy+0x29>
f0103c70:	e8 c4 27 00 00       	call   f0106439 <cpunum>
f0103c75:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c78:	39 98 28 10 23 f0    	cmp    %ebx,-0xfdcefd8(%eax)
f0103c7e:	74 09                	je     f0103c89 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103c80:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103c87:	eb 2f                	jmp    f0103cb8 <env_destroy+0x58>
	}

	env_free(e);
f0103c89:	89 1c 24             	mov    %ebx,(%esp)
f0103c8c:	e8 ca fd ff ff       	call   f0103a5b <env_free>

	if (curenv == e) {
f0103c91:	e8 a3 27 00 00       	call   f0106439 <cpunum>
f0103c96:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c99:	39 98 28 10 23 f0    	cmp    %ebx,-0xfdcefd8(%eax)
f0103c9f:	75 17                	jne    f0103cb8 <env_destroy+0x58>
		curenv = NULL;
f0103ca1:	e8 93 27 00 00       	call   f0106439 <cpunum>
f0103ca6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ca9:	c7 80 28 10 23 f0 00 	movl   $0x0,-0xfdcefd8(%eax)
f0103cb0:	00 00 00 
		sched_yield();
f0103cb3:	e8 87 0e 00 00       	call   f0104b3f <sched_yield>
	}
}
f0103cb8:	83 c4 14             	add    $0x14,%esp
f0103cbb:	5b                   	pop    %ebx
f0103cbc:	5d                   	pop    %ebp
f0103cbd:	c3                   	ret    

f0103cbe <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
//
// This function does not return.
//
void env_pop_tf(struct Trapframe *tf)
{
f0103cbe:	55                   	push   %ebp
f0103cbf:	89 e5                	mov    %esp,%ebp
f0103cc1:	53                   	push   %ebx
f0103cc2:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103cc5:	e8 6f 27 00 00       	call   f0106439 <cpunum>
f0103cca:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ccd:	8b 98 28 10 23 f0    	mov    -0xfdcefd8(%eax),%ebx
f0103cd3:	e8 61 27 00 00       	call   f0106439 <cpunum>
f0103cd8:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103cdb:	8b 65 08             	mov    0x8(%ebp),%esp
f0103cde:	61                   	popa   
f0103cdf:	07                   	pop    %es
f0103ce0:	1f                   	pop    %ds
f0103ce1:	83 c4 08             	add    $0x8,%esp
f0103ce4:	cf                   	iret   
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		:
		: "g"(tf)
		: "memory");
	panic("iret failed"); /* mostly to placate the compiler */
f0103ce5:	c7 44 24 08 23 7e 10 	movl   $0xf0107e23,0x8(%esp)
f0103cec:	f0 
f0103ced:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
f0103cf4:	00 
f0103cf5:	c7 04 24 ed 7d 10 f0 	movl   $0xf0107ded,(%esp)
f0103cfc:	e8 3f c3 ff ff       	call   f0100040 <_panic>

f0103d01 <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//
// This function does not return.
// 把环境从curenv 切换到 e
void env_run(struct Env *e)
{
f0103d01:	55                   	push   %ebp
f0103d02:	89 e5                	mov    %esp,%ebp
f0103d04:	53                   	push   %ebx
f0103d05:	83 ec 14             	sub    $0x14,%esp
f0103d08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	if (curenv) // 如果当前有环境
f0103d0b:	e8 29 27 00 00       	call   f0106439 <cpunum>
f0103d10:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d13:	83 b8 28 10 23 f0 00 	cmpl   $0x0,-0xfdcefd8(%eax)
f0103d1a:	74 15                	je     f0103d31 <env_run+0x30>
	{
		curenv->env_status = ENV_RUNNABLE; // 设置回 ENV_RUNNABLE
f0103d1c:	e8 18 27 00 00       	call   f0106439 <cpunum>
f0103d21:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d24:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103d2a:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
	curenv = e;						  // 将“curenv”设置为新环境
f0103d31:	e8 03 27 00 00       	call   f0106439 <cpunum>
f0103d36:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d39:	89 98 28 10 23 f0    	mov    %ebx,-0xfdcefd8(%eax)
	curenv->env_status = ENV_RUNNING; // 将其状态设置为 ENV_RUNNING
f0103d3f:	e8 f5 26 00 00       	call   f0106439 <cpunum>
f0103d44:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d47:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103d4d:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;				  // 更新其“env_runs”计数器
f0103d54:	e8 e0 26 00 00       	call   f0106439 <cpunum>
f0103d59:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d5c:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103d62:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));	  // 切换到用户空间
f0103d66:	e8 ce 26 00 00       	call   f0106439 <cpunum>
f0103d6b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d6e:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103d74:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103d77:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103d7c:	77 20                	ja     f0103d9e <env_run+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d82:	c7 44 24 08 68 6b 10 	movl   $0xf0106b68,0x8(%esp)
f0103d89:	f0 
f0103d8a:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
f0103d91:	00 
f0103d92:	c7 04 24 ed 7d 10 f0 	movl   $0xf0107ded,(%esp)
f0103d99:	e8 a2 c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103d9e:	05 00 00 00 10       	add    $0x10000000,%eax
f0103da3:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103da6:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0103dad:	e8 b1 29 00 00       	call   f0106763 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103db2:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(&e->env_tf); // 恢复环境的寄存器来进入环境中的用户模式，设置%eip为可执行程序的第一条指令
f0103db4:	89 1c 24             	mov    %ebx,(%esp)
f0103db7:	e8 02 ff ff ff       	call   f0103cbe <env_pop_tf>

f0103dbc <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103dbc:	55                   	push   %ebp
f0103dbd:	89 e5                	mov    %esp,%ebp
f0103dbf:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103dc3:	ba 70 00 00 00       	mov    $0x70,%edx
f0103dc8:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103dc9:	b2 71                	mov    $0x71,%dl
f0103dcb:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103dcc:	0f b6 c0             	movzbl %al,%eax
}
f0103dcf:	5d                   	pop    %ebp
f0103dd0:	c3                   	ret    

f0103dd1 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103dd1:	55                   	push   %ebp
f0103dd2:	89 e5                	mov    %esp,%ebp
f0103dd4:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103dd8:	ba 70 00 00 00       	mov    $0x70,%edx
f0103ddd:	ee                   	out    %al,(%dx)
f0103dde:	b2 71                	mov    $0x71,%dl
f0103de0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103de3:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103de4:	5d                   	pop    %ebp
f0103de5:	c3                   	ret    

f0103de6 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103de6:	55                   	push   %ebp
f0103de7:	89 e5                	mov    %esp,%ebp
f0103de9:	56                   	push   %esi
f0103dea:	53                   	push   %ebx
f0103deb:	83 ec 10             	sub    $0x10,%esp
f0103dee:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103df1:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f0103df7:	80 3d 50 02 23 f0 00 	cmpb   $0x0,0xf0230250
f0103dfe:	74 4e                	je     f0103e4e <irq_setmask_8259A+0x68>
f0103e00:	89 c6                	mov    %eax,%esi
f0103e02:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e07:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103e08:	66 c1 e8 08          	shr    $0x8,%ax
f0103e0c:	b2 a1                	mov    $0xa1,%dl
f0103e0e:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103e0f:	c7 04 24 2f 7e 10 f0 	movl   $0xf0107e2f,(%esp)
f0103e16:	e8 0a 01 00 00       	call   f0103f25 <cprintf>
	for (i = 0; i < 16; i++)
f0103e1b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103e20:	0f b7 f6             	movzwl %si,%esi
f0103e23:	f7 d6                	not    %esi
f0103e25:	0f a3 de             	bt     %ebx,%esi
f0103e28:	73 10                	jae    f0103e3a <irq_setmask_8259A+0x54>
			cprintf(" %d", i);
f0103e2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e2e:	c7 04 24 fb 82 10 f0 	movl   $0xf01082fb,(%esp)
f0103e35:	e8 eb 00 00 00       	call   f0103f25 <cprintf>
	for (i = 0; i < 16; i++)
f0103e3a:	83 c3 01             	add    $0x1,%ebx
f0103e3d:	83 fb 10             	cmp    $0x10,%ebx
f0103e40:	75 e3                	jne    f0103e25 <irq_setmask_8259A+0x3f>
	cprintf("\n");
f0103e42:	c7 04 24 22 7d 10 f0 	movl   $0xf0107d22,(%esp)
f0103e49:	e8 d7 00 00 00       	call   f0103f25 <cprintf>
}
f0103e4e:	83 c4 10             	add    $0x10,%esp
f0103e51:	5b                   	pop    %ebx
f0103e52:	5e                   	pop    %esi
f0103e53:	5d                   	pop    %ebp
f0103e54:	c3                   	ret    

f0103e55 <pic_init>:
	didinit = 1;
f0103e55:	c6 05 50 02 23 f0 01 	movb   $0x1,0xf0230250
f0103e5c:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103e66:	ee                   	out    %al,(%dx)
f0103e67:	b2 a1                	mov    $0xa1,%dl
f0103e69:	ee                   	out    %al,(%dx)
f0103e6a:	b2 20                	mov    $0x20,%dl
f0103e6c:	b8 11 00 00 00       	mov    $0x11,%eax
f0103e71:	ee                   	out    %al,(%dx)
f0103e72:	b2 21                	mov    $0x21,%dl
f0103e74:	b8 20 00 00 00       	mov    $0x20,%eax
f0103e79:	ee                   	out    %al,(%dx)
f0103e7a:	b8 04 00 00 00       	mov    $0x4,%eax
f0103e7f:	ee                   	out    %al,(%dx)
f0103e80:	b8 03 00 00 00       	mov    $0x3,%eax
f0103e85:	ee                   	out    %al,(%dx)
f0103e86:	b2 a0                	mov    $0xa0,%dl
f0103e88:	b8 11 00 00 00       	mov    $0x11,%eax
f0103e8d:	ee                   	out    %al,(%dx)
f0103e8e:	b2 a1                	mov    $0xa1,%dl
f0103e90:	b8 28 00 00 00       	mov    $0x28,%eax
f0103e95:	ee                   	out    %al,(%dx)
f0103e96:	b8 02 00 00 00       	mov    $0x2,%eax
f0103e9b:	ee                   	out    %al,(%dx)
f0103e9c:	b8 01 00 00 00       	mov    $0x1,%eax
f0103ea1:	ee                   	out    %al,(%dx)
f0103ea2:	b2 20                	mov    $0x20,%dl
f0103ea4:	b8 68 00 00 00       	mov    $0x68,%eax
f0103ea9:	ee                   	out    %al,(%dx)
f0103eaa:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103eaf:	ee                   	out    %al,(%dx)
f0103eb0:	b2 a0                	mov    $0xa0,%dl
f0103eb2:	b8 68 00 00 00       	mov    $0x68,%eax
f0103eb7:	ee                   	out    %al,(%dx)
f0103eb8:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103ebd:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103ebe:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0103ec5:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103ec9:	74 12                	je     f0103edd <pic_init+0x88>
{
f0103ecb:	55                   	push   %ebp
f0103ecc:	89 e5                	mov    %esp,%ebp
f0103ece:	83 ec 18             	sub    $0x18,%esp
		irq_setmask_8259A(irq_mask_8259A);
f0103ed1:	0f b7 c0             	movzwl %ax,%eax
f0103ed4:	89 04 24             	mov    %eax,(%esp)
f0103ed7:	e8 0a ff ff ff       	call   f0103de6 <irq_setmask_8259A>
}
f0103edc:	c9                   	leave  
f0103edd:	f3 c3                	repz ret 

f0103edf <putch>:
#include <inc/stdio.h>
#include <inc/stdarg.h>

// putch通过调用console.c中的cputchar来实现输出字符串到控制台。
static void putch(int ch, int *cnt)
{
f0103edf:	55                   	push   %ebp
f0103ee0:	89 e5                	mov    %esp,%ebp
f0103ee2:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103ee5:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ee8:	89 04 24             	mov    %eax,(%esp)
f0103eeb:	e8 aa c8 ff ff       	call   f010079a <cputchar>
	*cnt++;
}
f0103ef0:	c9                   	leave  
f0103ef1:	c3                   	ret    

f0103ef2 <vcprintf>:

// 将格式fmt和可变参数列表ap一起传给printfmt.c中的vprintfmt处理
int vcprintf(const char *fmt, va_list ap)
{
f0103ef2:	55                   	push   %ebp
f0103ef3:	89 e5                	mov    %esp,%ebp
f0103ef5:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103ef8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	vprintfmt((void *)putch, &cnt, fmt, ap); // 用一个指向putch的函数指针来告诉vprintfmt，处理后的数据应该交给putch来输出
f0103eff:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f02:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f06:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f09:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f10:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f14:	c7 04 24 df 3e 10 f0 	movl   $0xf0103edf,(%esp)
f0103f1b:	e8 0e 18 00 00       	call   f010572e <vprintfmt>
	return cnt;
}
f0103f20:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f23:	c9                   	leave  
f0103f24:	c3                   	ret    

f0103f25 <cprintf>:

// 这个函数作为实现打印功能的主要函数，暴露给其他程序。其第一个参数是包含输出格式的字符串，后面是可变参数列表。
int cprintf(const char *fmt, ...)
{
f0103f25:	55                   	push   %ebp
f0103f26:	89 e5                	mov    %esp,%ebp
f0103f28:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);		 // 获取可变参数列表ap
f0103f2b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap); // 传参
f0103f2e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f32:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f35:	89 04 24             	mov    %eax,(%esp)
f0103f38:	e8 b5 ff ff ff       	call   f0103ef2 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103f3d:	c9                   	leave  
f0103f3e:	c3                   	ret    
f0103f3f:	90                   	nop

f0103f40 <trap_init_percpu>:
	// Per-CPU setup
	trap_init_percpu();
}

void trap_init_percpu(void) // 初始化TSS和IDT
{
f0103f40:	55                   	push   %ebp
f0103f41:	89 e5                	mov    %esp,%ebp
f0103f43:	53                   	push   %ebx
f0103f44:	83 ec 04             	sub    $0x4,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	size_t i = cpunum();								   // 拿到现在运行的cpuid
f0103f47:	e8 ed 24 00 00       	call   f0106439 <cpunum>
	struct Taskstate *ts = &cpus[i].cpu_ts;				   // 这里这样取cpuinfo，因为直接用thiscpu会爆出triple fault
f0103f4c:	6b c8 74             	imul   $0x74,%eax,%ecx
	ts->ts_esp0 = (uintptr_t)percpu_kstacks[i] + KSTKSIZE; // esp0: 指代当前 CPU 的 stack 的起始位置
f0103f4f:	89 c2                	mov    %eax,%edx
f0103f51:	c1 e2 0f             	shl    $0xf,%edx
f0103f54:	81 c2 00 a0 23 f0    	add    $0xf023a000,%edx
f0103f5a:	89 91 30 10 23 f0    	mov    %edx,-0xfdcefd0(%ecx)
	ts->ts_ss0 = GD_KD;									   // 表示 esp0 这个位置存储的是 kernel 的 data
f0103f60:	66 c7 81 34 10 23 f0 	movw   $0x10,-0xfdcefcc(%ecx)
f0103f67:	10 00 
	ts->ts_iomb = sizeof(struct Taskstate);
f0103f69:	66 c7 81 92 10 23 f0 	movw   $0x68,-0xfdcef6e(%ecx)
f0103f70:	68 00 
	struct Taskstate *ts = &cpus[i].cpu_ts;				   // 这里这样取cpuinfo，因为直接用thiscpu会爆出triple fault
f0103f72:	81 c1 2c 10 23 f0    	add    $0xf023102c,%ecx

	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t)ts, sizeof(struct Taskstate) - 1, 0);
f0103f78:	8d 50 05             	lea    0x5(%eax),%edx
f0103f7b:	66 c7 04 d5 40 13 12 	movw   $0x67,-0xfedecc0(,%edx,8)
f0103f82:	f0 67 00 
f0103f85:	66 89 0c d5 42 13 12 	mov    %cx,-0xfedecbe(,%edx,8)
f0103f8c:	f0 
f0103f8d:	89 cb                	mov    %ecx,%ebx
f0103f8f:	c1 eb 10             	shr    $0x10,%ebx
f0103f92:	88 1c d5 44 13 12 f0 	mov    %bl,-0xfedecbc(,%edx,8)
f0103f99:	c6 04 d5 46 13 12 f0 	movb   $0x40,-0xfedecba(,%edx,8)
f0103fa0:	40 
f0103fa1:	c1 e9 18             	shr    $0x18,%ecx
f0103fa4:	88 0c d5 47 13 12 f0 	mov    %cl,-0xfedecb9(,%edx,8)
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f0103fab:	c6 04 d5 45 13 12 f0 	movb   $0x89,-0xfedecbb(,%edx,8)
f0103fb2:	89 

	ltr(GD_TSS0 + (i << 3));
f0103fb3:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
	asm volatile("ltr %0" : : "r" (sel));
f0103fba:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0103fbd:	b8 aa 13 12 f0       	mov    $0xf01213aa,%eax
f0103fc2:	0f 01 18             	lidtl  (%eax)

	lidt(&idt_pd);
}
f0103fc5:	83 c4 04             	add    $0x4,%esp
f0103fc8:	5b                   	pop    %ebx
f0103fc9:	5d                   	pop    %ebp
f0103fca:	c3                   	ret    

f0103fcb <trap_init>:
{
f0103fcb:	55                   	push   %ebp
f0103fcc:	89 e5                	mov    %esp,%ebp
f0103fce:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], 1, GD_KT, DIVIDE_Handler, 0); // SETGATE设置一个idt条目
f0103fd1:	b8 d6 49 10 f0       	mov    $0xf01049d6,%eax
f0103fd6:	66 a3 60 02 23 f0    	mov    %ax,0xf0230260
f0103fdc:	66 c7 05 62 02 23 f0 	movw   $0x8,0xf0230262
f0103fe3:	08 00 
f0103fe5:	c6 05 64 02 23 f0 00 	movb   $0x0,0xf0230264
f0103fec:	c6 05 65 02 23 f0 8f 	movb   $0x8f,0xf0230265
f0103ff3:	c1 e8 10             	shr    $0x10,%eax
f0103ff6:	66 a3 66 02 23 f0    	mov    %ax,0xf0230266
	SETGATE(idt[T_DEBUG], 1, GD_KT, DEBUG_Handler, 3);
f0103ffc:	b8 dc 49 10 f0       	mov    $0xf01049dc,%eax
f0104001:	66 a3 68 02 23 f0    	mov    %ax,0xf0230268
f0104007:	66 c7 05 6a 02 23 f0 	movw   $0x8,0xf023026a
f010400e:	08 00 
f0104010:	c6 05 6c 02 23 f0 00 	movb   $0x0,0xf023026c
f0104017:	c6 05 6d 02 23 f0 ef 	movb   $0xef,0xf023026d
f010401e:	c1 e8 10             	shr    $0x10,%eax
f0104021:	66 a3 6e 02 23 f0    	mov    %ax,0xf023026e
	SETGATE(idt[T_NMI], 1, GD_KT, NMI_Handler, 0);
f0104027:	b8 e2 49 10 f0       	mov    $0xf01049e2,%eax
f010402c:	66 a3 70 02 23 f0    	mov    %ax,0xf0230270
f0104032:	66 c7 05 72 02 23 f0 	movw   $0x8,0xf0230272
f0104039:	08 00 
f010403b:	c6 05 74 02 23 f0 00 	movb   $0x0,0xf0230274
f0104042:	c6 05 75 02 23 f0 8f 	movb   $0x8f,0xf0230275
f0104049:	c1 e8 10             	shr    $0x10,%eax
f010404c:	66 a3 76 02 23 f0    	mov    %ax,0xf0230276
	SETGATE(idt[T_BRKPT], 1, GD_KT, BRKPT_Handler, 3);
f0104052:	b8 e8 49 10 f0       	mov    $0xf01049e8,%eax
f0104057:	66 a3 78 02 23 f0    	mov    %ax,0xf0230278
f010405d:	66 c7 05 7a 02 23 f0 	movw   $0x8,0xf023027a
f0104064:	08 00 
f0104066:	c6 05 7c 02 23 f0 00 	movb   $0x0,0xf023027c
f010406d:	c6 05 7d 02 23 f0 ef 	movb   $0xef,0xf023027d
f0104074:	c1 e8 10             	shr    $0x10,%eax
f0104077:	66 a3 7e 02 23 f0    	mov    %ax,0xf023027e
	SETGATE(idt[T_OFLOW], 1, GD_KT, OFLOW_Handler, 0);
f010407d:	b8 ee 49 10 f0       	mov    $0xf01049ee,%eax
f0104082:	66 a3 80 02 23 f0    	mov    %ax,0xf0230280
f0104088:	66 c7 05 82 02 23 f0 	movw   $0x8,0xf0230282
f010408f:	08 00 
f0104091:	c6 05 84 02 23 f0 00 	movb   $0x0,0xf0230284
f0104098:	c6 05 85 02 23 f0 8f 	movb   $0x8f,0xf0230285
f010409f:	c1 e8 10             	shr    $0x10,%eax
f01040a2:	66 a3 86 02 23 f0    	mov    %ax,0xf0230286
	SETGATE(idt[T_BOUND], 1, GD_KT, BOUND_Handler, 0);
f01040a8:	b8 f4 49 10 f0       	mov    $0xf01049f4,%eax
f01040ad:	66 a3 88 02 23 f0    	mov    %ax,0xf0230288
f01040b3:	66 c7 05 8a 02 23 f0 	movw   $0x8,0xf023028a
f01040ba:	08 00 
f01040bc:	c6 05 8c 02 23 f0 00 	movb   $0x0,0xf023028c
f01040c3:	c6 05 8d 02 23 f0 8f 	movb   $0x8f,0xf023028d
f01040ca:	c1 e8 10             	shr    $0x10,%eax
f01040cd:	66 a3 8e 02 23 f0    	mov    %ax,0xf023028e
	SETGATE(idt[T_ILLOP], 1, GD_KT, ILLOP_Handler, 0);
f01040d3:	b8 fa 49 10 f0       	mov    $0xf01049fa,%eax
f01040d8:	66 a3 90 02 23 f0    	mov    %ax,0xf0230290
f01040de:	66 c7 05 92 02 23 f0 	movw   $0x8,0xf0230292
f01040e5:	08 00 
f01040e7:	c6 05 94 02 23 f0 00 	movb   $0x0,0xf0230294
f01040ee:	c6 05 95 02 23 f0 8f 	movb   $0x8f,0xf0230295
f01040f5:	c1 e8 10             	shr    $0x10,%eax
f01040f8:	66 a3 96 02 23 f0    	mov    %ax,0xf0230296
	SETGATE(idt[T_DEVICE], 1, GD_KT, DEVICE_Handler, 0);
f01040fe:	b8 00 4a 10 f0       	mov    $0xf0104a00,%eax
f0104103:	66 a3 98 02 23 f0    	mov    %ax,0xf0230298
f0104109:	66 c7 05 9a 02 23 f0 	movw   $0x8,0xf023029a
f0104110:	08 00 
f0104112:	c6 05 9c 02 23 f0 00 	movb   $0x0,0xf023029c
f0104119:	c6 05 9d 02 23 f0 8f 	movb   $0x8f,0xf023029d
f0104120:	c1 e8 10             	shr    $0x10,%eax
f0104123:	66 a3 9e 02 23 f0    	mov    %ax,0xf023029e
	SETGATE(idt[T_DBLFLT], 1, GD_KT, DBLFLT_Handler, 0);
f0104129:	b8 06 4a 10 f0       	mov    $0xf0104a06,%eax
f010412e:	66 a3 a0 02 23 f0    	mov    %ax,0xf02302a0
f0104134:	66 c7 05 a2 02 23 f0 	movw   $0x8,0xf02302a2
f010413b:	08 00 
f010413d:	c6 05 a4 02 23 f0 00 	movb   $0x0,0xf02302a4
f0104144:	c6 05 a5 02 23 f0 8f 	movb   $0x8f,0xf02302a5
f010414b:	c1 e8 10             	shr    $0x10,%eax
f010414e:	66 a3 a6 02 23 f0    	mov    %ax,0xf02302a6
	SETGATE(idt[T_TSS], 1, GD_KT, TSS_Handler, 0);
f0104154:	b8 0a 4a 10 f0       	mov    $0xf0104a0a,%eax
f0104159:	66 a3 b0 02 23 f0    	mov    %ax,0xf02302b0
f010415f:	66 c7 05 b2 02 23 f0 	movw   $0x8,0xf02302b2
f0104166:	08 00 
f0104168:	c6 05 b4 02 23 f0 00 	movb   $0x0,0xf02302b4
f010416f:	c6 05 b5 02 23 f0 8f 	movb   $0x8f,0xf02302b5
f0104176:	c1 e8 10             	shr    $0x10,%eax
f0104179:	66 a3 b6 02 23 f0    	mov    %ax,0xf02302b6
	SETGATE(idt[T_SEGNP], 1, GD_KT, SEGNP_Handler, 0);
f010417f:	b8 0e 4a 10 f0       	mov    $0xf0104a0e,%eax
f0104184:	66 a3 b8 02 23 f0    	mov    %ax,0xf02302b8
f010418a:	66 c7 05 ba 02 23 f0 	movw   $0x8,0xf02302ba
f0104191:	08 00 
f0104193:	c6 05 bc 02 23 f0 00 	movb   $0x0,0xf02302bc
f010419a:	c6 05 bd 02 23 f0 8f 	movb   $0x8f,0xf02302bd
f01041a1:	c1 e8 10             	shr    $0x10,%eax
f01041a4:	66 a3 be 02 23 f0    	mov    %ax,0xf02302be
	SETGATE(idt[T_STACK], 1, GD_KT, STACK_Handler, 0);
f01041aa:	b8 12 4a 10 f0       	mov    $0xf0104a12,%eax
f01041af:	66 a3 c0 02 23 f0    	mov    %ax,0xf02302c0
f01041b5:	66 c7 05 c2 02 23 f0 	movw   $0x8,0xf02302c2
f01041bc:	08 00 
f01041be:	c6 05 c4 02 23 f0 00 	movb   $0x0,0xf02302c4
f01041c5:	c6 05 c5 02 23 f0 8f 	movb   $0x8f,0xf02302c5
f01041cc:	c1 e8 10             	shr    $0x10,%eax
f01041cf:	66 a3 c6 02 23 f0    	mov    %ax,0xf02302c6
	SETGATE(idt[T_GPFLT], 1, GD_KT, GPFLT_Handler, 0);
f01041d5:	b8 16 4a 10 f0       	mov    $0xf0104a16,%eax
f01041da:	66 a3 c8 02 23 f0    	mov    %ax,0xf02302c8
f01041e0:	66 c7 05 ca 02 23 f0 	movw   $0x8,0xf02302ca
f01041e7:	08 00 
f01041e9:	c6 05 cc 02 23 f0 00 	movb   $0x0,0xf02302cc
f01041f0:	c6 05 cd 02 23 f0 8f 	movb   $0x8f,0xf02302cd
f01041f7:	c1 e8 10             	shr    $0x10,%eax
f01041fa:	66 a3 ce 02 23 f0    	mov    %ax,0xf02302ce
	SETGATE(idt[T_PGFLT], 1, GD_KT, PGFLT_Handler, 0);
f0104200:	b8 1a 4a 10 f0       	mov    $0xf0104a1a,%eax
f0104205:	66 a3 d0 02 23 f0    	mov    %ax,0xf02302d0
f010420b:	66 c7 05 d2 02 23 f0 	movw   $0x8,0xf02302d2
f0104212:	08 00 
f0104214:	c6 05 d4 02 23 f0 00 	movb   $0x0,0xf02302d4
f010421b:	c6 05 d5 02 23 f0 8f 	movb   $0x8f,0xf02302d5
f0104222:	89 c2                	mov    %eax,%edx
f0104224:	c1 ea 10             	shr    $0x10,%edx
f0104227:	66 89 15 d6 02 23 f0 	mov    %dx,0xf02302d6
	SETGATE(idt[T_FPERR], 1, GD_KT, FPERR_Handler, 0);
f010422e:	b9 1e 4a 10 f0       	mov    $0xf0104a1e,%ecx
f0104233:	66 89 0d e0 02 23 f0 	mov    %cx,0xf02302e0
f010423a:	66 c7 05 e2 02 23 f0 	movw   $0x8,0xf02302e2
f0104241:	08 00 
f0104243:	c6 05 e4 02 23 f0 00 	movb   $0x0,0xf02302e4
f010424a:	c6 05 e5 02 23 f0 8f 	movb   $0x8f,0xf02302e5
f0104251:	c1 e9 10             	shr    $0x10,%ecx
f0104254:	66 89 0d e6 02 23 f0 	mov    %cx,0xf02302e6
	SETGATE(idt[T_ALIGN], 1, GD_KT, ALIGN_Handler, 0);
f010425b:	b9 22 4a 10 f0       	mov    $0xf0104a22,%ecx
f0104260:	66 89 0d e8 02 23 f0 	mov    %cx,0xf02302e8
f0104267:	66 c7 05 ea 02 23 f0 	movw   $0x8,0xf02302ea
f010426e:	08 00 
f0104270:	c6 05 ec 02 23 f0 00 	movb   $0x0,0xf02302ec
f0104277:	c6 05 ed 02 23 f0 8f 	movb   $0x8f,0xf02302ed
f010427e:	c1 e9 10             	shr    $0x10,%ecx
f0104281:	66 89 0d ee 02 23 f0 	mov    %cx,0xf02302ee
	SETGATE(idt[T_MCHK], 1, GD_KT, MCHK_Handler, 0);
f0104288:	b9 26 4a 10 f0       	mov    $0xf0104a26,%ecx
f010428d:	66 89 0d f0 02 23 f0 	mov    %cx,0xf02302f0
f0104294:	66 c7 05 f2 02 23 f0 	movw   $0x8,0xf02302f2
f010429b:	08 00 
f010429d:	c6 05 f4 02 23 f0 00 	movb   $0x0,0xf02302f4
f01042a4:	c6 05 f5 02 23 f0 8f 	movb   $0x8f,0xf02302f5
f01042ab:	c1 e9 10             	shr    $0x10,%ecx
f01042ae:	66 89 0d f6 02 23 f0 	mov    %cx,0xf02302f6
	SETGATE(idt[T_SIMDERR], 1, GD_KT, PGFLT_Handler, 0);
f01042b5:	66 a3 f8 02 23 f0    	mov    %ax,0xf02302f8
f01042bb:	66 c7 05 fa 02 23 f0 	movw   $0x8,0xf02302fa
f01042c2:	08 00 
f01042c4:	c6 05 fc 02 23 f0 00 	movb   $0x0,0xf02302fc
f01042cb:	c6 05 fd 02 23 f0 8f 	movb   $0x8f,0xf02302fd
f01042d2:	66 89 15 fe 02 23 f0 	mov    %dx,0xf02302fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, SYSCALL_Handler, 3);
f01042d9:	b8 2e 4a 10 f0       	mov    $0xf0104a2e,%eax
f01042de:	66 a3 e0 03 23 f0    	mov    %ax,0xf02303e0
f01042e4:	66 c7 05 e2 03 23 f0 	movw   $0x8,0xf02303e2
f01042eb:	08 00 
f01042ed:	c6 05 e4 03 23 f0 00 	movb   $0x0,0xf02303e4
f01042f4:	c6 05 e5 03 23 f0 ee 	movb   $0xee,0xf02303e5
f01042fb:	c1 e8 10             	shr    $0x10,%eax
f01042fe:	66 a3 e6 03 23 f0    	mov    %ax,0xf02303e6
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 1, GD_KT, IRQ_TIMER_Handler, 0);
f0104304:	b8 34 4a 10 f0       	mov    $0xf0104a34,%eax
f0104309:	66 a3 60 03 23 f0    	mov    %ax,0xf0230360
f010430f:	66 c7 05 62 03 23 f0 	movw   $0x8,0xf0230362
f0104316:	08 00 
f0104318:	c6 05 64 03 23 f0 00 	movb   $0x0,0xf0230364
f010431f:	c6 05 65 03 23 f0 8f 	movb   $0x8f,0xf0230365
f0104326:	c1 e8 10             	shr    $0x10,%eax
f0104329:	66 a3 66 03 23 f0    	mov    %ax,0xf0230366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 1, GD_KT, IRQ_KBD_Handler, 0);
f010432f:	b8 3a 4a 10 f0       	mov    $0xf0104a3a,%eax
f0104334:	66 a3 68 03 23 f0    	mov    %ax,0xf0230368
f010433a:	66 c7 05 6a 03 23 f0 	movw   $0x8,0xf023036a
f0104341:	08 00 
f0104343:	c6 05 6c 03 23 f0 00 	movb   $0x0,0xf023036c
f010434a:	c6 05 6d 03 23 f0 8f 	movb   $0x8f,0xf023036d
f0104351:	c1 e8 10             	shr    $0x10,%eax
f0104354:	66 a3 6e 03 23 f0    	mov    %ax,0xf023036e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 1, GD_KT, IRQ_SERIAL_Handler, 0);
f010435a:	b8 40 4a 10 f0       	mov    $0xf0104a40,%eax
f010435f:	66 a3 80 03 23 f0    	mov    %ax,0xf0230380
f0104365:	66 c7 05 82 03 23 f0 	movw   $0x8,0xf0230382
f010436c:	08 00 
f010436e:	c6 05 84 03 23 f0 00 	movb   $0x0,0xf0230384
f0104375:	c6 05 85 03 23 f0 8f 	movb   $0x8f,0xf0230385
f010437c:	c1 e8 10             	shr    $0x10,%eax
f010437f:	66 a3 86 03 23 f0    	mov    %ax,0xf0230386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 1, GD_KT, IRQ_SPURIOUS_Handler, 0);
f0104385:	b8 46 4a 10 f0       	mov    $0xf0104a46,%eax
f010438a:	66 a3 98 03 23 f0    	mov    %ax,0xf0230398
f0104390:	66 c7 05 9a 03 23 f0 	movw   $0x8,0xf023039a
f0104397:	08 00 
f0104399:	c6 05 9c 03 23 f0 00 	movb   $0x0,0xf023039c
f01043a0:	c6 05 9d 03 23 f0 8f 	movb   $0x8f,0xf023039d
f01043a7:	c1 e8 10             	shr    $0x10,%eax
f01043aa:	66 a3 9e 03 23 f0    	mov    %ax,0xf023039e
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 1, GD_KT, IRQ_IDE_Handler, 0);
f01043b0:	b8 4c 4a 10 f0       	mov    $0xf0104a4c,%eax
f01043b5:	66 a3 d0 03 23 f0    	mov    %ax,0xf02303d0
f01043bb:	66 c7 05 d2 03 23 f0 	movw   $0x8,0xf02303d2
f01043c2:	08 00 
f01043c4:	c6 05 d4 03 23 f0 00 	movb   $0x0,0xf02303d4
f01043cb:	c6 05 d5 03 23 f0 8f 	movb   $0x8f,0xf02303d5
f01043d2:	c1 e8 10             	shr    $0x10,%eax
f01043d5:	66 a3 d6 03 23 f0    	mov    %ax,0xf02303d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 1, GD_KT, IRQ_ERROR_Handler, 0);
f01043db:	b8 52 4a 10 f0       	mov    $0xf0104a52,%eax
f01043e0:	66 a3 f8 03 23 f0    	mov    %ax,0xf02303f8
f01043e6:	66 c7 05 fa 03 23 f0 	movw   $0x8,0xf02303fa
f01043ed:	08 00 
f01043ef:	c6 05 fc 03 23 f0 00 	movb   $0x0,0xf02303fc
f01043f6:	c6 05 fd 03 23 f0 8f 	movb   $0x8f,0xf02303fd
f01043fd:	c1 e8 10             	shr    $0x10,%eax
f0104400:	66 a3 fe 03 23 f0    	mov    %ax,0xf02303fe
	trap_init_percpu();
f0104406:	e8 35 fb ff ff       	call   f0103f40 <trap_init_percpu>
}
f010440b:	c9                   	leave  
f010440c:	c3                   	ret    

f010440d <print_regs>:
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
	}
}

void print_regs(struct PushRegs *regs) // 打印寄存器的值，print_trapframe()的辅助函数
{
f010440d:	55                   	push   %ebp
f010440e:	89 e5                	mov    %esp,%ebp
f0104410:	53                   	push   %ebx
f0104411:	83 ec 14             	sub    $0x14,%esp
f0104414:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104417:	8b 03                	mov    (%ebx),%eax
f0104419:	89 44 24 04          	mov    %eax,0x4(%esp)
f010441d:	c7 04 24 43 7e 10 f0 	movl   $0xf0107e43,(%esp)
f0104424:	e8 fc fa ff ff       	call   f0103f25 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104429:	8b 43 04             	mov    0x4(%ebx),%eax
f010442c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104430:	c7 04 24 52 7e 10 f0 	movl   $0xf0107e52,(%esp)
f0104437:	e8 e9 fa ff ff       	call   f0103f25 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010443c:	8b 43 08             	mov    0x8(%ebx),%eax
f010443f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104443:	c7 04 24 61 7e 10 f0 	movl   $0xf0107e61,(%esp)
f010444a:	e8 d6 fa ff ff       	call   f0103f25 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010444f:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104452:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104456:	c7 04 24 70 7e 10 f0 	movl   $0xf0107e70,(%esp)
f010445d:	e8 c3 fa ff ff       	call   f0103f25 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104462:	8b 43 10             	mov    0x10(%ebx),%eax
f0104465:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104469:	c7 04 24 7f 7e 10 f0 	movl   $0xf0107e7f,(%esp)
f0104470:	e8 b0 fa ff ff       	call   f0103f25 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104475:	8b 43 14             	mov    0x14(%ebx),%eax
f0104478:	89 44 24 04          	mov    %eax,0x4(%esp)
f010447c:	c7 04 24 8e 7e 10 f0 	movl   $0xf0107e8e,(%esp)
f0104483:	e8 9d fa ff ff       	call   f0103f25 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104488:	8b 43 18             	mov    0x18(%ebx),%eax
f010448b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010448f:	c7 04 24 9d 7e 10 f0 	movl   $0xf0107e9d,(%esp)
f0104496:	e8 8a fa ff ff       	call   f0103f25 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010449b:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010449e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044a2:	c7 04 24 ac 7e 10 f0 	movl   $0xf0107eac,(%esp)
f01044a9:	e8 77 fa ff ff       	call   f0103f25 <cprintf>
}
f01044ae:	83 c4 14             	add    $0x14,%esp
f01044b1:	5b                   	pop    %ebx
f01044b2:	5d                   	pop    %ebp
f01044b3:	c3                   	ret    

f01044b4 <print_trapframe>:
{
f01044b4:	55                   	push   %ebp
f01044b5:	89 e5                	mov    %esp,%ebp
f01044b7:	56                   	push   %esi
f01044b8:	53                   	push   %ebx
f01044b9:	83 ec 10             	sub    $0x10,%esp
f01044bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01044bf:	e8 75 1f 00 00       	call   f0106439 <cpunum>
f01044c4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01044c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01044cc:	c7 04 24 10 7f 10 f0 	movl   $0xf0107f10,(%esp)
f01044d3:	e8 4d fa ff ff       	call   f0103f25 <cprintf>
	print_regs(&tf->tf_regs);
f01044d8:	89 1c 24             	mov    %ebx,(%esp)
f01044db:	e8 2d ff ff ff       	call   f010440d <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01044e0:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01044e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044e8:	c7 04 24 2e 7f 10 f0 	movl   $0xf0107f2e,(%esp)
f01044ef:	e8 31 fa ff ff       	call   f0103f25 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01044f4:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01044f8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044fc:	c7 04 24 41 7f 10 f0 	movl   $0xf0107f41,(%esp)
f0104503:	e8 1d fa ff ff       	call   f0103f25 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104508:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f010450b:	83 f8 13             	cmp    $0x13,%eax
f010450e:	77 09                	ja     f0104519 <print_trapframe+0x65>
		return excnames[trapno];
f0104510:	8b 14 85 e0 81 10 f0 	mov    -0xfef7e20(,%eax,4),%edx
f0104517:	eb 1f                	jmp    f0104538 <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f0104519:	83 f8 30             	cmp    $0x30,%eax
f010451c:	74 15                	je     f0104533 <print_trapframe+0x7f>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f010451e:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0104521:	83 fa 0f             	cmp    $0xf,%edx
f0104524:	ba c7 7e 10 f0       	mov    $0xf0107ec7,%edx
f0104529:	b9 da 7e 10 f0       	mov    $0xf0107eda,%ecx
f010452e:	0f 47 d1             	cmova  %ecx,%edx
f0104531:	eb 05                	jmp    f0104538 <print_trapframe+0x84>
		return "System call";
f0104533:	ba bb 7e 10 f0       	mov    $0xf0107ebb,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104538:	89 54 24 08          	mov    %edx,0x8(%esp)
f010453c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104540:	c7 04 24 54 7f 10 f0 	movl   $0xf0107f54,(%esp)
f0104547:	e8 d9 f9 ff ff       	call   f0103f25 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010454c:	3b 1d 60 0a 23 f0    	cmp    0xf0230a60,%ebx
f0104552:	75 19                	jne    f010456d <print_trapframe+0xb9>
f0104554:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104558:	75 13                	jne    f010456d <print_trapframe+0xb9>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010455a:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010455d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104561:	c7 04 24 66 7f 10 f0 	movl   $0xf0107f66,(%esp)
f0104568:	e8 b8 f9 ff ff       	call   f0103f25 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f010456d:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104570:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104574:	c7 04 24 75 7f 10 f0 	movl   $0xf0107f75,(%esp)
f010457b:	e8 a5 f9 ff ff       	call   f0103f25 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0104580:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104584:	75 51                	jne    f01045d7 <print_trapframe+0x123>
				tf->tf_err & 1 ? "protection" : "not-present");
f0104586:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0104589:	89 c2                	mov    %eax,%edx
f010458b:	83 e2 01             	and    $0x1,%edx
f010458e:	ba e9 7e 10 f0       	mov    $0xf0107ee9,%edx
f0104593:	b9 f4 7e 10 f0       	mov    $0xf0107ef4,%ecx
f0104598:	0f 45 ca             	cmovne %edx,%ecx
f010459b:	89 c2                	mov    %eax,%edx
f010459d:	83 e2 02             	and    $0x2,%edx
f01045a0:	ba 00 7f 10 f0       	mov    $0xf0107f00,%edx
f01045a5:	be 06 7f 10 f0       	mov    $0xf0107f06,%esi
f01045aa:	0f 44 d6             	cmove  %esi,%edx
f01045ad:	83 e0 04             	and    $0x4,%eax
f01045b0:	b8 0b 7f 10 f0       	mov    $0xf0107f0b,%eax
f01045b5:	be 27 80 10 f0       	mov    $0xf0108027,%esi
f01045ba:	0f 44 c6             	cmove  %esi,%eax
f01045bd:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01045c1:	89 54 24 08          	mov    %edx,0x8(%esp)
f01045c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045c9:	c7 04 24 83 7f 10 f0 	movl   $0xf0107f83,(%esp)
f01045d0:	e8 50 f9 ff ff       	call   f0103f25 <cprintf>
f01045d5:	eb 0c                	jmp    f01045e3 <print_trapframe+0x12f>
		cprintf("\n");
f01045d7:	c7 04 24 22 7d 10 f0 	movl   $0xf0107d22,(%esp)
f01045de:	e8 42 f9 ff ff       	call   f0103f25 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01045e3:	8b 43 30             	mov    0x30(%ebx),%eax
f01045e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045ea:	c7 04 24 92 7f 10 f0 	movl   $0xf0107f92,(%esp)
f01045f1:	e8 2f f9 ff ff       	call   f0103f25 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01045f6:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01045fa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045fe:	c7 04 24 a1 7f 10 f0 	movl   $0xf0107fa1,(%esp)
f0104605:	e8 1b f9 ff ff       	call   f0103f25 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010460a:	8b 43 38             	mov    0x38(%ebx),%eax
f010460d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104611:	c7 04 24 b4 7f 10 f0 	movl   $0xf0107fb4,(%esp)
f0104618:	e8 08 f9 ff ff       	call   f0103f25 <cprintf>
	if ((tf->tf_cs & 3) != 0)
f010461d:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104621:	74 27                	je     f010464a <print_trapframe+0x196>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104623:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104626:	89 44 24 04          	mov    %eax,0x4(%esp)
f010462a:	c7 04 24 c3 7f 10 f0 	movl   $0xf0107fc3,(%esp)
f0104631:	e8 ef f8 ff ff       	call   f0103f25 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104636:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010463a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010463e:	c7 04 24 d2 7f 10 f0 	movl   $0xf0107fd2,(%esp)
f0104645:	e8 db f8 ff ff       	call   f0103f25 <cprintf>
}
f010464a:	83 c4 10             	add    $0x10,%esp
f010464d:	5b                   	pop    %ebx
f010464e:	5e                   	pop    %esi
f010464f:	5d                   	pop    %ebp
f0104650:	c3                   	ret    

f0104651 <page_fault_handler>:
	else
		sched_yield();
}

void page_fault_handler(struct Trapframe *tf) // 特殊处理页错误中断
{
f0104651:	55                   	push   %ebp
f0104652:	89 e5                	mov    %esp,%ebp
f0104654:	57                   	push   %edi
f0104655:	56                   	push   %esi
f0104656:	53                   	push   %ebx
f0104657:	83 ec 2c             	sub    $0x2c,%esp
f010465a:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010465d:	0f 20 d6             	mov    %cr2,%esi
	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0) // 处于内核模式
f0104660:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104664:	75 1c                	jne    f0104682 <page_fault_handler+0x31>
	{
		panic("page_fault_handler(): kernel-mode page faults");
f0104666:	c7 44 24 08 74 81 10 	movl   $0xf0108174,0x8(%esp)
f010466d:	f0 
f010466e:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
f0104675:	00 
f0104676:	c7 04 24 e5 7f 10 f0 	movl   $0xf0107fe5,(%esp)
f010467d:	e8 be b9 ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	// 现在处于用户模式
	if (curenv->env_pgfault_upcall != NULL) // 用户模式下的页面错误处理程序如果有设置
f0104682:	e8 b2 1d 00 00       	call   f0106439 <cpunum>
f0104687:	6b c0 74             	imul   $0x74,%eax,%eax
f010468a:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104690:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104694:	0f 84 d8 00 00 00    	je     f0104772 <page_fault_handler+0x121>
	{
		uintptr_t addr;

		if (tf->tf_esp >= UXSTACKTOP - PGSIZE && tf->tf_esp < UXSTACKTOP) // 如果发生异常时用户环境已经在用户异常堆栈上运行
f010469a:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010469d:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			addr = tf->tf_esp - sizeof(struct UTrapframe) - sizeof(int);  // 在tf->tf_esp处设置页面错误堆栈帧UTrapframe
f01046a3:	83 e8 38             	sub    $0x38,%eax
f01046a6:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01046ac:	ba c8 ff bf ee       	mov    $0xeebfffc8,%edx
f01046b1:	0f 46 d0             	cmovbe %eax,%edx
f01046b4:	89 d7                	mov    %edx,%edi
f01046b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		else
			addr = UXSTACKTOP - sizeof(struct UTrapframe) - sizeof(int); // 栈帧的区间[UXSTACKTOP - sizeof(struct UTrapframe) - sizeof(int),UXSTACKTOP]
		user_mem_assert(curenv, (void *)addr, sizeof(struct UTrapframe) + sizeof(int), PTE_P | PTE_U | PTE_W);
f01046b9:	e8 7b 1d 00 00       	call   f0106439 <cpunum>
f01046be:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f01046c5:	00 
f01046c6:	c7 44 24 08 38 00 00 	movl   $0x38,0x8(%esp)
f01046cd:	00 
f01046ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01046d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01046d5:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f01046db:	89 04 24             	mov    %eax,(%esp)
f01046de:	e8 59 ee ff ff       	call   f010353c <user_mem_assert>

		// 在UXSTACKTOP设置一个用户模式下的页面错误堆栈帧UTrapframe，为了可以从页面错误处理程序中返回到引发错误的程序
		struct UTrapframe *utf = (struct UTrapframe *)addr;
f01046e3:	89 fa                	mov    %edi,%edx
		utf->utf_fault_va = fault_va;
f01046e5:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f01046e7:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01046ea:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f01046ed:	8d 7f 08             	lea    0x8(%edi),%edi
f01046f0:	89 de                	mov    %ebx,%esi
f01046f2:	b8 20 00 00 00       	mov    $0x20,%eax
f01046f7:	f7 c7 01 00 00 00    	test   $0x1,%edi
f01046fd:	74 03                	je     f0104702 <page_fault_handler+0xb1>
f01046ff:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0104700:	b0 1f                	mov    $0x1f,%al
f0104702:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104708:	74 05                	je     f010470f <page_fault_handler+0xbe>
f010470a:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f010470c:	83 e8 02             	sub    $0x2,%eax
f010470f:	89 c1                	mov    %eax,%ecx
f0104711:	c1 e9 02             	shr    $0x2,%ecx
f0104714:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104716:	a8 02                	test   $0x2,%al
f0104718:	74 0b                	je     f0104725 <page_fault_handler+0xd4>
f010471a:	0f b7 0e             	movzwl (%esi),%ecx
f010471d:	66 89 0f             	mov    %cx,(%edi)
f0104720:	b9 02 00 00 00       	mov    $0x2,%ecx
f0104725:	a8 01                	test   $0x1,%al
f0104727:	74 07                	je     f0104730 <page_fault_handler+0xdf>
f0104729:	0f b6 04 0e          	movzbl (%esi,%ecx,1),%eax
f010472d:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		utf->utf_eip = tf->tf_eip;
f0104730:	8b 43 30             	mov    0x30(%ebx),%eax
f0104733:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f0104736:	8b 43 38             	mov    0x38(%ebx),%eax
f0104739:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f010473c:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010473f:	89 42 30             	mov    %eax,0x30(%edx)

		tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall; // 设置页面错误处理程序入口
f0104742:	e8 f2 1c 00 00       	call   f0106439 <cpunum>
f0104747:	6b c0 74             	imul   $0x74,%eax,%eax
f010474a:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104750:	8b 40 64             	mov    0x64(%eax),%eax
f0104753:	89 43 30             	mov    %eax,0x30(%ebx)
		tf->tf_esp = (uintptr_t)utf;						// 修改esp移动到设置好的用户异常堆栈
f0104756:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104759:	89 43 3c             	mov    %eax,0x3c(%ebx)
		env_run(curenv);									// 重新运行本进程，env_run会pop出tf，来运行页面错误处理程序
f010475c:	e8 d8 1c 00 00       	call   f0106439 <cpunum>
f0104761:	6b c0 74             	imul   $0x74,%eax,%eax
f0104764:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f010476a:	89 04 24             	mov    %eax,(%esp)
f010476d:	e8 8f f5 ff ff       	call   f0103d01 <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104772:	8b 7b 30             	mov    0x30(%ebx),%edi
			curenv->env_id, fault_va, tf->tf_eip);
f0104775:	e8 bf 1c 00 00       	call   f0106439 <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010477a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010477e:	89 74 24 08          	mov    %esi,0x8(%esp)
			curenv->env_id, fault_va, tf->tf_eip);
f0104782:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104785:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f010478b:	8b 40 48             	mov    0x48(%eax),%eax
f010478e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104792:	c7 04 24 a4 81 10 f0 	movl   $0xf01081a4,(%esp)
f0104799:	e8 87 f7 ff ff       	call   f0103f25 <cprintf>
	print_trapframe(tf);
f010479e:	89 1c 24             	mov    %ebx,(%esp)
f01047a1:	e8 0e fd ff ff       	call   f01044b4 <print_trapframe>
	env_destroy(curenv);
f01047a6:	e8 8e 1c 00 00       	call   f0106439 <cpunum>
f01047ab:	6b c0 74             	imul   $0x74,%eax,%eax
f01047ae:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f01047b4:	89 04 24             	mov    %eax,(%esp)
f01047b7:	e8 a4 f4 ff ff       	call   f0103c60 <env_destroy>
}
f01047bc:	83 c4 2c             	add    $0x2c,%esp
f01047bf:	5b                   	pop    %ebx
f01047c0:	5e                   	pop    %esi
f01047c1:	5f                   	pop    %edi
f01047c2:	5d                   	pop    %ebp
f01047c3:	c3                   	ret    

f01047c4 <trap>:
{
f01047c4:	55                   	push   %ebp
f01047c5:	89 e5                	mov    %esp,%ebp
f01047c7:	57                   	push   %edi
f01047c8:	56                   	push   %esi
f01047c9:	83 ec 20             	sub    $0x20,%esp
f01047cc:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::
f01047cf:	fc                   	cld    
	if (panicstr)
f01047d0:	83 3d 80 0e 23 f0 00 	cmpl   $0x0,0xf0230e80
f01047d7:	74 01                	je     f01047da <trap+0x16>
		asm volatile("hlt");
f01047d9:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01047da:	e8 5a 1c 00 00       	call   f0106439 <cpunum>
f01047df:	6b d0 74             	imul   $0x74,%eax,%edx
f01047e2:	81 c2 20 10 23 f0    	add    $0xf0231020,%edx
	asm volatile("lock; xchgl %0, %1"
f01047e8:	b8 01 00 00 00       	mov    $0x1,%eax
f01047ed:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01047f1:	83 f8 02             	cmp    $0x2,%eax
f01047f4:	75 0c                	jne    f0104802 <trap+0x3e>
	spin_lock(&kernel_lock);
f01047f6:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f01047fd:	e8 b5 1e 00 00       	call   f01066b7 <spin_lock>
	if ((tf->tf_cs & 3) == 3)
f0104802:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104806:	83 e0 03             	and    $0x3,%eax
f0104809:	66 83 f8 03          	cmp    $0x3,%ax
f010480d:	0f 85 a7 00 00 00    	jne    f01048ba <trap+0xf6>
f0104813:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f010481a:	e8 98 1e 00 00       	call   f01066b7 <spin_lock>
		assert(curenv);
f010481f:	e8 15 1c 00 00       	call   f0106439 <cpunum>
f0104824:	6b c0 74             	imul   $0x74,%eax,%eax
f0104827:	83 b8 28 10 23 f0 00 	cmpl   $0x0,-0xfdcefd8(%eax)
f010482e:	75 24                	jne    f0104854 <trap+0x90>
f0104830:	c7 44 24 0c f1 7f 10 	movl   $0xf0107ff1,0xc(%esp)
f0104837:	f0 
f0104838:	c7 44 24 08 bf 7a 10 	movl   $0xf0107abf,0x8(%esp)
f010483f:	f0 
f0104840:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
f0104847:	00 
f0104848:	c7 04 24 e5 7f 10 f0 	movl   $0xf0107fe5,(%esp)
f010484f:	e8 ec b7 ff ff       	call   f0100040 <_panic>
		if (curenv->env_status == ENV_DYING)
f0104854:	e8 e0 1b 00 00       	call   f0106439 <cpunum>
f0104859:	6b c0 74             	imul   $0x74,%eax,%eax
f010485c:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104862:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104866:	75 2d                	jne    f0104895 <trap+0xd1>
			env_free(curenv);
f0104868:	e8 cc 1b 00 00       	call   f0106439 <cpunum>
f010486d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104870:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104876:	89 04 24             	mov    %eax,(%esp)
f0104879:	e8 dd f1 ff ff       	call   f0103a5b <env_free>
			curenv = NULL;
f010487e:	e8 b6 1b 00 00       	call   f0106439 <cpunum>
f0104883:	6b c0 74             	imul   $0x74,%eax,%eax
f0104886:	c7 80 28 10 23 f0 00 	movl   $0x0,-0xfdcefd8(%eax)
f010488d:	00 00 00 
			sched_yield();
f0104890:	e8 aa 02 00 00       	call   f0104b3f <sched_yield>
		curenv->env_tf = *tf;
f0104895:	e8 9f 1b 00 00       	call   f0106439 <cpunum>
f010489a:	6b c0 74             	imul   $0x74,%eax,%eax
f010489d:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f01048a3:	b9 11 00 00 00       	mov    $0x11,%ecx
f01048a8:	89 c7                	mov    %eax,%edi
f01048aa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01048ac:	e8 88 1b 00 00       	call   f0106439 <cpunum>
f01048b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01048b4:	8b b0 28 10 23 f0    	mov    -0xfdcefd8(%eax),%esi
	last_tf = tf;
f01048ba:	89 35 60 0a 23 f0    	mov    %esi,0xf0230a60
	switch (tf->tf_trapno)
f01048c0:	8b 46 28             	mov    0x28(%esi),%eax
f01048c3:	83 f8 0e             	cmp    $0xe,%eax
f01048c6:	74 0c                	je     f01048d4 <trap+0x110>
f01048c8:	83 f8 30             	cmp    $0x30,%eax
f01048cb:	74 28                	je     f01048f5 <trap+0x131>
f01048cd:	83 f8 03             	cmp    $0x3,%eax
f01048d0:	75 55                	jne    f0104927 <trap+0x163>
f01048d2:	eb 11                	jmp    f01048e5 <trap+0x121>
		page_fault_handler(tf);
f01048d4:	89 34 24             	mov    %esi,(%esp)
f01048d7:	e8 75 fd ff ff       	call   f0104651 <page_fault_handler>
f01048dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01048e0:	e9 b1 00 00 00       	jmp    f0104996 <trap+0x1d2>
		monitor(tf);
f01048e5:	89 34 24             	mov    %esi,(%esp)
f01048e8:	e8 c4 c0 ff ff       	call   f01009b1 <monitor>
f01048ed:	8d 76 00             	lea    0x0(%esi),%esi
f01048f0:	e9 a1 00 00 00       	jmp    f0104996 <trap+0x1d2>
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx,
f01048f5:	8b 46 04             	mov    0x4(%esi),%eax
f01048f8:	89 44 24 14          	mov    %eax,0x14(%esp)
f01048fc:	8b 06                	mov    (%esi),%eax
f01048fe:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104902:	8b 46 10             	mov    0x10(%esi),%eax
f0104905:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104909:	8b 46 18             	mov    0x18(%esi),%eax
f010490c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104910:	8b 46 14             	mov    0x14(%esi),%eax
f0104913:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104917:	8b 46 1c             	mov    0x1c(%esi),%eax
f010491a:	89 04 24             	mov    %eax,(%esp)
f010491d:	e8 ce 02 00 00       	call   f0104bf0 <syscall>
f0104922:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104925:	eb 6f                	jmp    f0104996 <trap+0x1d2>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS)
f0104927:	83 f8 27             	cmp    $0x27,%eax
f010492a:	75 16                	jne    f0104942 <trap+0x17e>
		cprintf("Spurious interrupt on irq 7\n");
f010492c:	c7 04 24 f8 7f 10 f0 	movl   $0xf0107ff8,(%esp)
f0104933:	e8 ed f5 ff ff       	call   f0103f25 <cprintf>
		print_trapframe(tf);
f0104938:	89 34 24             	mov    %esi,(%esp)
f010493b:	e8 74 fb ff ff       	call   f01044b4 <print_trapframe>
f0104940:	eb 54                	jmp    f0104996 <trap+0x1d2>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER)
f0104942:	83 f8 20             	cmp    $0x20,%eax
f0104945:	75 0e                	jne    f0104955 <trap+0x191>
		lapic_eoi();
f0104947:	e8 3a 1c 00 00       	call   f0106586 <lapic_eoi>
		sched_yield();
f010494c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104950:	e8 ea 01 00 00       	call   f0104b3f <sched_yield>
	print_trapframe(tf);
f0104955:	89 34 24             	mov    %esi,(%esp)
f0104958:	e8 57 fb ff ff       	call   f01044b4 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010495d:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104962:	75 1c                	jne    f0104980 <trap+0x1bc>
		panic("unhandled trap in kernel");
f0104964:	c7 44 24 08 15 80 10 	movl   $0xf0108015,0x8(%esp)
f010496b:	f0 
f010496c:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
f0104973:	00 
f0104974:	c7 04 24 e5 7f 10 f0 	movl   $0xf0107fe5,(%esp)
f010497b:	e8 c0 b6 ff ff       	call   f0100040 <_panic>
		env_destroy(curenv);
f0104980:	e8 b4 1a 00 00       	call   f0106439 <cpunum>
f0104985:	6b c0 74             	imul   $0x74,%eax,%eax
f0104988:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f010498e:	89 04 24             	mov    %eax,(%esp)
f0104991:	e8 ca f2 ff ff       	call   f0103c60 <env_destroy>
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104996:	e8 9e 1a 00 00       	call   f0106439 <cpunum>
f010499b:	6b c0 74             	imul   $0x74,%eax,%eax
f010499e:	83 b8 28 10 23 f0 00 	cmpl   $0x0,-0xfdcefd8(%eax)
f01049a5:	74 2a                	je     f01049d1 <trap+0x20d>
f01049a7:	e8 8d 1a 00 00       	call   f0106439 <cpunum>
f01049ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01049af:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f01049b5:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01049b9:	75 16                	jne    f01049d1 <trap+0x20d>
		env_run(curenv); // 返回用户态
f01049bb:	e8 79 1a 00 00       	call   f0106439 <cpunum>
f01049c0:	6b c0 74             	imul   $0x74,%eax,%eax
f01049c3:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f01049c9:	89 04 24             	mov    %eax,(%esp)
f01049cc:	e8 30 f3 ff ff       	call   f0103d01 <env_run>
		sched_yield();
f01049d1:	e8 69 01 00 00       	call   f0104b3f <sched_yield>

f01049d6 <DIVIDE_Handler>:
 * TRAPHANDLER(name, num):是一个宏，等效于一个从name标记的地址开始的几行指令
 * name是你为这个num的中断设置的中断处理程序的函数名，num由inc\trap.h定义
 * 经过下面的设置，这个汇编文件里存在很多个以handler为名的函数，可以在C中使用void XXX_Hander()去声明函数，
 * 这时，这个hander函数的地址将被链接到下面对应hander的行。
 */
TRAPHANDLER_NOEC(DIVIDE_Handler, T_DIVIDE)
f01049d6:	6a 00                	push   $0x0
f01049d8:	6a 00                	push   $0x0
f01049da:	eb 7c                	jmp    f0104a58 <_alltraps>

f01049dc <DEBUG_Handler>:
TRAPHANDLER_NOEC(DEBUG_Handler, T_DEBUG)
f01049dc:	6a 00                	push   $0x0
f01049de:	6a 01                	push   $0x1
f01049e0:	eb 76                	jmp    f0104a58 <_alltraps>

f01049e2 <NMI_Handler>:
TRAPHANDLER_NOEC(NMI_Handler, T_NMI)
f01049e2:	6a 00                	push   $0x0
f01049e4:	6a 02                	push   $0x2
f01049e6:	eb 70                	jmp    f0104a58 <_alltraps>

f01049e8 <BRKPT_Handler>:
TRAPHANDLER_NOEC(BRKPT_Handler, T_BRKPT)
f01049e8:	6a 00                	push   $0x0
f01049ea:	6a 03                	push   $0x3
f01049ec:	eb 6a                	jmp    f0104a58 <_alltraps>

f01049ee <OFLOW_Handler>:
TRAPHANDLER_NOEC(OFLOW_Handler, T_OFLOW)
f01049ee:	6a 00                	push   $0x0
f01049f0:	6a 04                	push   $0x4
f01049f2:	eb 64                	jmp    f0104a58 <_alltraps>

f01049f4 <BOUND_Handler>:
TRAPHANDLER_NOEC(BOUND_Handler, T_BOUND)
f01049f4:	6a 00                	push   $0x0
f01049f6:	6a 05                	push   $0x5
f01049f8:	eb 5e                	jmp    f0104a58 <_alltraps>

f01049fa <ILLOP_Handler>:
TRAPHANDLER_NOEC(ILLOP_Handler, T_ILLOP)
f01049fa:	6a 00                	push   $0x0
f01049fc:	6a 06                	push   $0x6
f01049fe:	eb 58                	jmp    f0104a58 <_alltraps>

f0104a00 <DEVICE_Handler>:
TRAPHANDLER_NOEC(DEVICE_Handler, T_DEVICE)
f0104a00:	6a 00                	push   $0x0
f0104a02:	6a 07                	push   $0x7
f0104a04:	eb 52                	jmp    f0104a58 <_alltraps>

f0104a06 <DBLFLT_Handler>:
TRAPHANDLER(DBLFLT_Handler, T_DBLFLT)
f0104a06:	6a 08                	push   $0x8
f0104a08:	eb 4e                	jmp    f0104a58 <_alltraps>

f0104a0a <TSS_Handler>:

TRAPHANDLER(TSS_Handler, T_TSS)
f0104a0a:	6a 0a                	push   $0xa
f0104a0c:	eb 4a                	jmp    f0104a58 <_alltraps>

f0104a0e <SEGNP_Handler>:
TRAPHANDLER(SEGNP_Handler, T_SEGNP)
f0104a0e:	6a 0b                	push   $0xb
f0104a10:	eb 46                	jmp    f0104a58 <_alltraps>

f0104a12 <STACK_Handler>:
TRAPHANDLER(STACK_Handler, T_STACK)
f0104a12:	6a 0c                	push   $0xc
f0104a14:	eb 42                	jmp    f0104a58 <_alltraps>

f0104a16 <GPFLT_Handler>:
TRAPHANDLER(GPFLT_Handler, T_GPFLT)
f0104a16:	6a 0d                	push   $0xd
f0104a18:	eb 3e                	jmp    f0104a58 <_alltraps>

f0104a1a <PGFLT_Handler>:
TRAPHANDLER(PGFLT_Handler, T_PGFLT)
f0104a1a:	6a 0e                	push   $0xe
f0104a1c:	eb 3a                	jmp    f0104a58 <_alltraps>

f0104a1e <FPERR_Handler>:

TRAPHANDLER(FPERR_Handler, T_FPERR)
f0104a1e:	6a 10                	push   $0x10
f0104a20:	eb 36                	jmp    f0104a58 <_alltraps>

f0104a22 <ALIGN_Handler>:
TRAPHANDLER(ALIGN_Handler, T_ALIGN)
f0104a22:	6a 11                	push   $0x11
f0104a24:	eb 32                	jmp    f0104a58 <_alltraps>

f0104a26 <MCHK_Handler>:
TRAPHANDLER(MCHK_Handler, T_MCHK)
f0104a26:	6a 12                	push   $0x12
f0104a28:	eb 2e                	jmp    f0104a58 <_alltraps>

f0104a2a <SIMDERR_Handler>:
TRAPHANDLER(SIMDERR_Handler, T_SIMDERR)
f0104a2a:	6a 13                	push   $0x13
f0104a2c:	eb 2a                	jmp    f0104a58 <_alltraps>

f0104a2e <SYSCALL_Handler>:

TRAPHANDLER_NOEC(SYSCALL_Handler, T_SYSCALL)
f0104a2e:	6a 00                	push   $0x0
f0104a30:	6a 30                	push   $0x30
f0104a32:	eb 24                	jmp    f0104a58 <_alltraps>

f0104a34 <IRQ_TIMER_Handler>:

# IRQs
TRAPHANDLER_NOEC(IRQ_TIMER_Handler, IRQ_OFFSET+IRQ_TIMER)
f0104a34:	6a 00                	push   $0x0
f0104a36:	6a 20                	push   $0x20
f0104a38:	eb 1e                	jmp    f0104a58 <_alltraps>

f0104a3a <IRQ_KBD_Handler>:
TRAPHANDLER_NOEC(IRQ_KBD_Handler, IRQ_OFFSET+IRQ_KBD)
f0104a3a:	6a 00                	push   $0x0
f0104a3c:	6a 21                	push   $0x21
f0104a3e:	eb 18                	jmp    f0104a58 <_alltraps>

f0104a40 <IRQ_SERIAL_Handler>:
TRAPHANDLER_NOEC(IRQ_SERIAL_Handler, IRQ_OFFSET+IRQ_SERIAL)
f0104a40:	6a 00                	push   $0x0
f0104a42:	6a 24                	push   $0x24
f0104a44:	eb 12                	jmp    f0104a58 <_alltraps>

f0104a46 <IRQ_SPURIOUS_Handler>:
TRAPHANDLER_NOEC(IRQ_SPURIOUS_Handler, IRQ_OFFSET+IRQ_SPURIOUS)
f0104a46:	6a 00                	push   $0x0
f0104a48:	6a 27                	push   $0x27
f0104a4a:	eb 0c                	jmp    f0104a58 <_alltraps>

f0104a4c <IRQ_IDE_Handler>:
TRAPHANDLER_NOEC(IRQ_IDE_Handler, IRQ_OFFSET+IRQ_IDE)
f0104a4c:	6a 00                	push   $0x0
f0104a4e:	6a 2e                	push   $0x2e
f0104a50:	eb 06                	jmp    f0104a58 <_alltraps>

f0104a52 <IRQ_ERROR_Handler>:
TRAPHANDLER_NOEC(IRQ_ERROR_Handler, IRQ_OFFSET+IRQ_ERROR)
f0104a52:	6a 00                	push   $0x0
f0104a54:	6a 33                	push   $0x33
f0104a56:	eb 00                	jmp    f0104a58 <_alltraps>

f0104a58 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
.globl		_start
_alltraps:
	pushl	%ds		/* 后面要将GD_KD加载到%ds和%es，先保存旧的 */
f0104a58:	1e                   	push   %ds
	pushl	%es
f0104a59:	06                   	push   %es
	pushal			/* 直接推送整个TrapFrame */
f0104a5a:	60                   	pusha  
	movw 	$GD_KD, %ax /* 不能直接设置，因此先复制到%ax */
f0104a5b:	66 b8 10 00          	mov    $0x10,%ax
  	movw 	%ax, %ds
f0104a5f:	8e d8                	mov    %eax,%ds
  	movw 	%ax, %es
f0104a61:	8e c0                	mov    %eax,%es
	pushl 	%esp	/* %esp指向Trapframe顶部，作为参数传递给trap */
f0104a63:	54                   	push   %esp
	call	trap	/* 调用c程序trap，执行中断处理程序 */
f0104a64:	e8 5b fd ff ff       	call   f01047c4 <trap>

f0104a69 <sched_halt>:

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void sched_halt(void)
{
f0104a69:	55                   	push   %ebp
f0104a6a:	89 e5                	mov    %esp,%ebp
f0104a6c:	83 ec 18             	sub    $0x18,%esp
f0104a6f:	8b 15 48 02 23 f0    	mov    0xf0230248,%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++)
f0104a75:	b8 00 00 00 00       	mov    $0x0,%eax
	{
		if ((envs[i].env_status == ENV_RUNNABLE ||
			 envs[i].env_status == ENV_RUNNING ||
f0104a7a:	8b 4a 54             	mov    0x54(%edx),%ecx
f0104a7d:	83 e9 01             	sub    $0x1,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104a80:	83 f9 02             	cmp    $0x2,%ecx
f0104a83:	76 0f                	jbe    f0104a94 <sched_halt+0x2b>
	for (i = 0; i < NENV; i++)
f0104a85:	83 c0 01             	add    $0x1,%eax
f0104a88:	83 c2 7c             	add    $0x7c,%edx
f0104a8b:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104a90:	75 e8                	jne    f0104a7a <sched_halt+0x11>
f0104a92:	eb 07                	jmp    f0104a9b <sched_halt+0x32>
			 envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV)
f0104a94:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104a99:	75 1a                	jne    f0104ab5 <sched_halt+0x4c>
	{
		cprintf("No runnable environments in the system!\n");
f0104a9b:	c7 04 24 30 82 10 f0 	movl   $0xf0108230,(%esp)
f0104aa2:	e8 7e f4 ff ff       	call   f0103f25 <cprintf>
		while (1)
			monitor(NULL);
f0104aa7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104aae:	e8 fe be ff ff       	call   f01009b1 <monitor>
f0104ab3:	eb f2                	jmp    f0104aa7 <sched_halt+0x3e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104ab5:	e8 7f 19 00 00       	call   f0106439 <cpunum>
f0104aba:	6b c0 74             	imul   $0x74,%eax,%eax
f0104abd:	c7 80 28 10 23 f0 00 	movl   $0x0,-0xfdcefd8(%eax)
f0104ac4:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104ac7:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0104acc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104ad1:	77 20                	ja     f0104af3 <sched_halt+0x8a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104ad3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104ad7:	c7 44 24 08 68 6b 10 	movl   $0xf0106b68,0x8(%esp)
f0104ade:	f0 
f0104adf:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0104ae6:	00 
f0104ae7:	c7 04 24 59 82 10 f0 	movl   $0xf0108259,(%esp)
f0104aee:	e8 4d b5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104af3:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104af8:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104afb:	e8 39 19 00 00       	call   f0106439 <cpunum>
f0104b00:	6b d0 74             	imul   $0x74,%eax,%edx
f0104b03:	81 c2 20 10 23 f0    	add    $0xf0231020,%edx
	asm volatile("lock; xchgl %0, %1"
f0104b09:	b8 02 00 00 00       	mov    $0x2,%eax
f0104b0e:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
	spin_unlock(&kernel_lock);
f0104b12:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104b19:	e8 45 1c 00 00       	call   f0106763 <spin_unlock>
	asm volatile("pause");
f0104b1e:	f3 90                	pause  
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
		:
		: "a"(thiscpu->cpu_ts.ts_esp0));
f0104b20:	e8 14 19 00 00       	call   f0106439 <cpunum>
f0104b25:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile(
f0104b28:	8b 80 30 10 23 f0    	mov    -0xfdcefd0(%eax),%eax
f0104b2e:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104b33:	89 c4                	mov    %eax,%esp
f0104b35:	6a 00                	push   $0x0
f0104b37:	6a 00                	push   $0x0
f0104b39:	fb                   	sti    
f0104b3a:	f4                   	hlt    
f0104b3b:	eb fd                	jmp    f0104b3a <sched_halt+0xd1>
}
f0104b3d:	c9                   	leave  
f0104b3e:	c3                   	ret    

f0104b3f <sched_yield>:
{
f0104b3f:	55                   	push   %ebp
f0104b40:	89 e5                	mov    %esp,%ebp
f0104b42:	56                   	push   %esi
f0104b43:	53                   	push   %ebx
f0104b44:	83 ec 10             	sub    $0x10,%esp
	idle = &envs[0]; // 第一个环境
f0104b47:	8b 1d 48 02 23 f0    	mov    0xf0230248,%ebx
	if (curenv)
f0104b4d:	e8 e7 18 00 00       	call   f0106439 <cpunum>
f0104b52:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b55:	83 b8 28 10 23 f0 00 	cmpl   $0x0,-0xfdcefd8(%eax)
f0104b5c:	74 11                	je     f0104b6f <sched_yield+0x30>
		idle = curenv + 1; // 如果现在有在运行的环境，从现在这个的下一个开始遍历
f0104b5e:	e8 d6 18 00 00       	call   f0106439 <cpunum>
f0104b63:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b66:	8b 98 28 10 23 f0    	mov    -0xfdcefd8(%eax),%ebx
f0104b6c:	83 c3 7c             	add    $0x7c,%ebx
		if (idle == &envs[NENV - 1]) // 最后一个环境
f0104b6f:	8b 0d 48 02 23 f0    	mov    0xf0230248,%ecx
f0104b75:	8d b1 84 ef 01 00    	lea    0x1ef84(%ecx),%esi
f0104b7b:	b8 ff 03 00 00       	mov    $0x3ff,%eax
		if (idle->env_status == ENV_RUNNABLE) // 检查是否可以运行
f0104b80:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0104b84:	75 08                	jne    f0104b8e <sched_yield+0x4f>
			env_run(idle);
f0104b86:	89 1c 24             	mov    %ebx,(%esp)
f0104b89:	e8 73 f1 ff ff       	call   f0103d01 <env_run>
			idle++;
f0104b8e:	8d 53 7c             	lea    0x7c(%ebx),%edx
f0104b91:	39 de                	cmp    %ebx,%esi
f0104b93:	0f 44 d1             	cmove  %ecx,%edx
f0104b96:	89 d3                	mov    %edx,%ebx
	for (int i = 0; i < NENV - 1; i++)
f0104b98:	83 e8 01             	sub    $0x1,%eax
f0104b9b:	75 e3                	jne    f0104b80 <sched_yield+0x41>
	if (idle == curenv && curenv->env_status == ENV_RUNNING) // 转一圈又回到自己
f0104b9d:	e8 97 18 00 00       	call   f0106439 <cpunum>
f0104ba2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ba5:	3b 98 28 10 23 f0    	cmp    -0xfdcefd8(%eax),%ebx
f0104bab:	75 2a                	jne    f0104bd7 <sched_yield+0x98>
f0104bad:	e8 87 18 00 00       	call   f0106439 <cpunum>
f0104bb2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bb5:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104bbb:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104bbf:	75 16                	jne    f0104bd7 <sched_yield+0x98>
		env_run(curenv);
f0104bc1:	e8 73 18 00 00       	call   f0106439 <cpunum>
f0104bc6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bc9:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104bcf:	89 04 24             	mov    %eax,(%esp)
f0104bd2:	e8 2a f1 ff ff       	call   f0103d01 <env_run>
	sched_halt();
f0104bd7:	e8 8d fe ff ff       	call   f0104a69 <sched_halt>
}
f0104bdc:	83 c4 10             	add    $0x10,%esp
f0104bdf:	5b                   	pop    %ebx
f0104be0:	5e                   	pop    %esi
f0104be1:	5d                   	pop    %ebp
f0104be2:	c3                   	ret    
f0104be3:	66 90                	xchg   %ax,%ax
f0104be5:	66 90                	xchg   %ax,%ax
f0104be7:	66 90                	xchg   %ax,%ax
f0104be9:	66 90                	xchg   %ax,%ax
f0104beb:	66 90                	xchg   %ax,%ax
f0104bed:	66 90                	xchg   %ax,%ax
f0104bef:	90                   	nop

f0104bf0 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104bf0:	55                   	push   %ebp
f0104bf1:	89 e5                	mov    %esp,%ebp
f0104bf3:	57                   	push   %edi
f0104bf4:	56                   	push   %esi
f0104bf5:	53                   	push   %ebx
f0104bf6:	83 ec 2c             	sub    $0x2c,%esp
f0104bf9:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) // 根据系统调用编号，调用相应的处理函数，枚举值即为inc\syscall.h中定义的值
f0104bfc:	83 f8 0c             	cmp    $0xc,%eax
f0104bff:	0f 87 7f 05 00 00    	ja     f0105184 <syscall+0x594>
f0104c05:	ff 24 85 a0 82 10 f0 	jmp    *-0xfef7d60(,%eax,4)
	user_mem_assert(curenv, s, len, PTE_U);
f0104c0c:	e8 28 18 00 00       	call   f0106439 <cpunum>
f0104c11:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104c18:	00 
f0104c19:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104c1c:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104c20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104c23:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104c27:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c2a:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104c30:	89 04 24             	mov    %eax,(%esp)
f0104c33:	e8 04 e9 ff ff       	call   f010353c <user_mem_assert>
	cprintf("%.*s", len, s);
f0104c38:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c3b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104c3f:	8b 45 10             	mov    0x10(%ebp),%eax
f0104c42:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c46:	c7 04 24 66 82 10 f0 	movl   $0xf0108266,(%esp)
f0104c4d:	e8 d3 f2 ff ff       	call   f0103f25 <cprintf>
	{
	case SYS_cputs:
		sys_cputs((char *)a1, (size_t)a2);
		return 0;
f0104c52:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c57:	e9 34 05 00 00       	jmp    f0105190 <syscall+0x5a0>
	return cons_getc();
f0104c5c:	e8 e4 b9 ff ff       	call   f0100645 <cons_getc>
	case SYS_cgetc:
		return sys_cgetc();
f0104c61:	e9 2a 05 00 00       	jmp    f0105190 <syscall+0x5a0>
	return curenv->env_id;
f0104c66:	e8 ce 17 00 00       	call   f0106439 <cpunum>
f0104c6b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c6e:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104c74:	8b 40 48             	mov    0x48(%eax),%eax
	case SYS_getenvid:
		return sys_getenvid();
f0104c77:	e9 14 05 00 00       	jmp    f0105190 <syscall+0x5a0>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104c7c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104c83:	00 
f0104c84:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104c87:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c8e:	89 04 24             	mov    %eax,(%esp)
f0104c91:	e8 99 e9 ff ff       	call   f010362f <envid2env>
		return r;
f0104c96:	89 c2                	mov    %eax,%edx
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104c98:	85 c0                	test   %eax,%eax
f0104c9a:	78 6e                	js     f0104d0a <syscall+0x11a>
	if (e == curenv)
f0104c9c:	e8 98 17 00 00       	call   f0106439 <cpunum>
f0104ca1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ca4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ca7:	39 90 28 10 23 f0    	cmp    %edx,-0xfdcefd8(%eax)
f0104cad:	75 23                	jne    f0104cd2 <syscall+0xe2>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104caf:	e8 85 17 00 00       	call   f0106439 <cpunum>
f0104cb4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cb7:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104cbd:	8b 40 48             	mov    0x48(%eax),%eax
f0104cc0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104cc4:	c7 04 24 6b 82 10 f0 	movl   $0xf010826b,(%esp)
f0104ccb:	e8 55 f2 ff ff       	call   f0103f25 <cprintf>
f0104cd0:	eb 28                	jmp    f0104cfa <syscall+0x10a>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104cd2:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104cd5:	e8 5f 17 00 00       	call   f0106439 <cpunum>
f0104cda:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104cde:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ce1:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104ce7:	8b 40 48             	mov    0x48(%eax),%eax
f0104cea:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104cee:	c7 04 24 86 82 10 f0 	movl   $0xf0108286,(%esp)
f0104cf5:	e8 2b f2 ff ff       	call   f0103f25 <cprintf>
	env_destroy(e);
f0104cfa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104cfd:	89 04 24             	mov    %eax,(%esp)
f0104d00:	e8 5b ef ff ff       	call   f0103c60 <env_destroy>
	return 0;
f0104d05:	ba 00 00 00 00       	mov    $0x0,%edx
	case SYS_env_destroy:
		return sys_env_destroy((envid_t)a1);
f0104d0a:	89 d0                	mov    %edx,%eax
f0104d0c:	e9 7f 04 00 00       	jmp    f0105190 <syscall+0x5a0>
	sched_yield();
f0104d11:	e8 29 fe ff ff       	call   f0104b3f <sched_yield>
	int Ecode = env_alloc(&new_env, curenv->env_id);
f0104d16:	e8 1e 17 00 00       	call   f0106439 <cpunum>
f0104d1b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d1e:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104d24:	8b 40 48             	mov    0x48(%eax),%eax
f0104d27:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d2b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d2e:	89 04 24             	mov    %eax,(%esp)
f0104d31:	e8 09 ea ff ff       	call   f010373f <env_alloc>
		return Ecode;
f0104d36:	89 c2                	mov    %eax,%edx
	if (Ecode) // 如果发生错误就返回error code
f0104d38:	85 c0                	test   %eax,%eax
f0104d3a:	75 2e                	jne    f0104d6a <syscall+0x17a>
	new_env->env_status = ENV_NOT_RUNNABLE;
f0104d3c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104d3f:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	new_env->env_tf = curenv->env_tf; // 拷贝父进程的trapframe
f0104d46:	e8 ee 16 00 00       	call   f0106439 <cpunum>
f0104d4b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d4e:	8b b0 28 10 23 f0    	mov    -0xfdcefd8(%eax),%esi
f0104d54:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104d59:	89 df                	mov    %ebx,%edi
f0104d5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	new_env->env_tf.tf_regs.reg_eax = 0;
f0104d5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d60:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return new_env->env_id; // 返回子进程的id
f0104d67:	8b 50 48             	mov    0x48(%eax),%edx
	case SYS_yield:
		sys_yield();
		return 0;
	case SYS_exofork:
		return sys_exofork();
f0104d6a:	89 d0                	mov    %edx,%eax
f0104d6c:	e9 1f 04 00 00       	jmp    f0105190 <syscall+0x5a0>
	int Ecode = envid2env(envid, &e, 1);
f0104d71:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104d78:	00 
f0104d79:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d7c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d80:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d83:	89 04 24             	mov    %eax,(%esp)
f0104d86:	e8 a4 e8 ff ff       	call   f010362f <envid2env>
		return Ecode;
f0104d8b:	89 c2                	mov    %eax,%edx
	if (Ecode)
f0104d8d:	85 c0                	test   %eax,%eax
f0104d8f:	75 21                	jne    f0104db2 <syscall+0x1c2>
	if ((status != ENV_RUNNABLE) && (status != ENV_NOT_RUNNABLE)) // 检查status是合法的
f0104d91:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f0104d95:	74 06                	je     f0104d9d <syscall+0x1ad>
f0104d97:	83 7d 10 02          	cmpl   $0x2,0x10(%ebp)
f0104d9b:	75 10                	jne    f0104dad <syscall+0x1bd>
	e->env_status = status; // 设置状态
f0104d9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104da0:	8b 75 10             	mov    0x10(%ebp),%esi
f0104da3:	89 70 54             	mov    %esi,0x54(%eax)
	return 0;
f0104da6:	ba 00 00 00 00       	mov    $0x0,%edx
f0104dab:	eb 05                	jmp    f0104db2 <syscall+0x1c2>
		return -E_INVAL;
f0104dad:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
	case SYS_env_set_status:
		return sys_env_set_status((envid_t)a1, (int)a2);
f0104db2:	89 d0                	mov    %edx,%eax
f0104db4:	e9 d7 03 00 00       	jmp    f0105190 <syscall+0x5a0>
	if ((Ecode = envid2env(envid, &e, 1))) // 得到Env结构
f0104db9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104dc0:	00 
f0104dc1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104dc4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104dcb:	89 04 24             	mov    %eax,(%esp)
f0104dce:	e8 5c e8 ff ff       	call   f010362f <envid2env>
		return Ecode;
f0104dd3:	89 c2                	mov    %eax,%edx
	if ((Ecode = envid2env(envid, &e, 1))) // 得到Env结构
f0104dd5:	85 c0                	test   %eax,%eax
f0104dd7:	75 7f                	jne    f0104e58 <syscall+0x268>
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || perm & ~PTE_SYSCALL) // 检查perm
f0104dd9:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ddc:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0104de1:	83 f8 05             	cmp    $0x5,%eax
f0104de4:	75 58                	jne    f0104e3e <syscall+0x24e>
	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE != 0) // 检查va
f0104de6:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104ded:	77 56                	ja     f0104e45 <syscall+0x255>
f0104def:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104df6:	75 54                	jne    f0104e4c <syscall+0x25c>
	struct PageInfo *p = page_alloc(ALLOC_ZERO);
f0104df8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104dff:	e8 ec c2 ff ff       	call   f01010f0 <page_alloc>
f0104e04:	89 c3                	mov    %eax,%ebx
	if (!p) // 没有内存，分配页面失败
f0104e06:	85 c0                	test   %eax,%eax
f0104e08:	74 49                	je     f0104e53 <syscall+0x263>
	Ecode = page_insert(e->env_pgdir, p, va, perm);
f0104e0a:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e0d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104e11:	8b 45 10             	mov    0x10(%ebp),%eax
f0104e14:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104e18:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104e1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e1f:	8b 40 60             	mov    0x60(%eax),%eax
f0104e22:	89 04 24             	mov    %eax,(%esp)
f0104e25:	e8 f8 c5 ff ff       	call   f0101422 <page_insert>
f0104e2a:	89 c6                	mov    %eax,%esi
	return 0;
f0104e2c:	89 c2                	mov    %eax,%edx
	if (Ecode)
f0104e2e:	85 c0                	test   %eax,%eax
f0104e30:	74 26                	je     f0104e58 <syscall+0x268>
		page_decref(p); // 释放p
f0104e32:	89 1c 24             	mov    %ebx,(%esp)
f0104e35:	e8 87 c3 ff ff       	call   f01011c1 <page_decref>
		return Ecode;
f0104e3a:	89 f2                	mov    %esi,%edx
f0104e3c:	eb 1a                	jmp    f0104e58 <syscall+0x268>
		return -E_INVAL;
f0104e3e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104e43:	eb 13                	jmp    f0104e58 <syscall+0x268>
		return -E_INVAL;
f0104e45:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104e4a:	eb 0c                	jmp    f0104e58 <syscall+0x268>
f0104e4c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104e51:	eb 05                	jmp    f0104e58 <syscall+0x268>
		return -E_NO_MEM;
f0104e53:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
	case SYS_page_alloc:
		return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
f0104e58:	89 d0                	mov    %edx,%eax
f0104e5a:	e9 31 03 00 00       	jmp    f0105190 <syscall+0x5a0>
	if ((Ecode = envid2env(srcenvid, &src, 1))) // 得到Env结构
f0104e5f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e66:	00 
f0104e67:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104e6a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104e71:	89 04 24             	mov    %eax,(%esp)
f0104e74:	e8 b6 e7 ff ff       	call   f010362f <envid2env>
		return Ecode;
f0104e79:	89 c2                	mov    %eax,%edx
	if ((Ecode = envid2env(srcenvid, &src, 1))) // 得到Env结构
f0104e7b:	85 c0                	test   %eax,%eax
f0104e7d:	0f 85 c1 00 00 00    	jne    f0104f44 <syscall+0x354>
	if ((Ecode = envid2env(dstenvid, &dst, 1)))
f0104e83:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e8a:	00 
f0104e8b:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104e8e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e92:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e95:	89 04 24             	mov    %eax,(%esp)
f0104e98:	e8 92 e7 ff ff       	call   f010362f <envid2env>
		return Ecode;
f0104e9d:	89 c2                	mov    %eax,%edx
	if ((Ecode = envid2env(dstenvid, &dst, 1)))
f0104e9f:	85 c0                	test   %eax,%eax
f0104ea1:	0f 85 9d 00 00 00    	jne    f0104f44 <syscall+0x354>
	if (((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)) || (perm & ~PTE_SYSCALL)) // 检查perm
f0104ea7:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104eaa:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0104eaf:	83 f8 05             	cmp    $0x5,%eax
f0104eb2:	75 68                	jne    f0104f1c <syscall+0x32c>
	if ((uintptr_t)srcva >= UTOP || (uintptr_t)srcva % PGSIZE != 0 // 检查va
f0104eb4:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104ebb:	77 66                	ja     f0104f23 <syscall+0x333>
f0104ebd:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104ec4:	75 64                	jne    f0104f2a <syscall+0x33a>
		|| (uintptr_t)dstva >= UTOP || (uintptr_t)dstva % PGSIZE != 0)
f0104ec6:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104ecd:	77 62                	ja     f0104f31 <syscall+0x341>
f0104ecf:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104ed6:	75 60                	jne    f0104f38 <syscall+0x348>
	struct PageInfo *p = page_lookup(src->env_pgdir, srcva, &pte); // 找到src对应的页面
f0104ed8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104edb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104edf:	8b 45 10             	mov    0x10(%ebp),%eax
f0104ee2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ee6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ee9:	8b 40 60             	mov    0x60(%eax),%eax
f0104eec:	89 04 24             	mov    %eax,(%esp)
f0104eef:	e8 df c3 ff ff       	call   f01012d3 <page_lookup>
	if (!p)														   // 没有权限
f0104ef4:	85 c0                	test   %eax,%eax
f0104ef6:	74 47                	je     f0104f3f <syscall+0x34f>
	Ecode = page_insert(dst->env_pgdir, p, dstva, perm); // 把src对应的页面也映射到dst上，这样两者都映射到同一个页面
f0104ef8:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f0104efb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104eff:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104f02:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104f06:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f0d:	8b 40 60             	mov    0x60(%eax),%eax
f0104f10:	89 04 24             	mov    %eax,(%esp)
f0104f13:	e8 0a c5 ff ff       	call   f0101422 <page_insert>
f0104f18:	89 c2                	mov    %eax,%edx
f0104f1a:	eb 28                	jmp    f0104f44 <syscall+0x354>
		return -E_INVAL;
f0104f1c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104f21:	eb 21                	jmp    f0104f44 <syscall+0x354>
		return -E_INVAL;
f0104f23:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104f28:	eb 1a                	jmp    f0104f44 <syscall+0x354>
f0104f2a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104f2f:	eb 13                	jmp    f0104f44 <syscall+0x354>
f0104f31:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104f36:	eb 0c                	jmp    f0104f44 <syscall+0x354>
f0104f38:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104f3d:	eb 05                	jmp    f0104f44 <syscall+0x354>
		return -E_INVAL;
f0104f3f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
	case SYS_page_map:
		return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
f0104f44:	89 d0                	mov    %edx,%eax
f0104f46:	e9 45 02 00 00       	jmp    f0105190 <syscall+0x5a0>
	if ((Ecode = envid2env(envid, &e, 1))) // 得到Env结构
f0104f4b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f52:	00 
f0104f53:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f56:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f5a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f5d:	89 04 24             	mov    %eax,(%esp)
f0104f60:	e8 ca e6 ff ff       	call   f010362f <envid2env>
		return Ecode;
f0104f65:	89 c2                	mov    %eax,%edx
	if ((Ecode = envid2env(envid, &e, 1))) // 得到Env结构
f0104f67:	85 c0                	test   %eax,%eax
f0104f69:	75 3a                	jne    f0104fa5 <syscall+0x3b5>
	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE != 0)
f0104f6b:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104f72:	77 25                	ja     f0104f99 <syscall+0x3a9>
f0104f74:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104f7b:	75 23                	jne    f0104fa0 <syscall+0x3b0>
	page_remove(e->env_pgdir, va);
f0104f7d:	8b 45 10             	mov    0x10(%ebp),%eax
f0104f80:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f87:	8b 40 60             	mov    0x60(%eax),%eax
f0104f8a:	89 04 24             	mov    %eax,(%esp)
f0104f8d:	e8 47 c4 ff ff       	call   f01013d9 <page_remove>
	return 0;
f0104f92:	ba 00 00 00 00       	mov    $0x0,%edx
f0104f97:	eb 0c                	jmp    f0104fa5 <syscall+0x3b5>
		return -E_INVAL;
f0104f99:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104f9e:	eb 05                	jmp    f0104fa5 <syscall+0x3b5>
f0104fa0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
	case SYS_page_unmap:
		return sys_page_unmap((envid_t)a1, (void *)a2);
f0104fa5:	89 d0                	mov    %edx,%eax
f0104fa7:	e9 e4 01 00 00       	jmp    f0105190 <syscall+0x5a0>
	int Ecode = envid2env(envid, &e, 1);
f0104fac:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104fb3:	00 
f0104fb4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104fb7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fbb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104fbe:	89 04 24             	mov    %eax,(%esp)
f0104fc1:	e8 69 e6 ff ff       	call   f010362f <envid2env>
	if (Ecode)
f0104fc6:	85 c0                	test   %eax,%eax
f0104fc8:	0f 85 c2 01 00 00    	jne    f0105190 <syscall+0x5a0>
	e->env_pgfault_upcall = func;
f0104fce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104fd1:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104fd4:	89 4a 64             	mov    %ecx,0x64(%edx)
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f0104fd7:	e9 b4 01 00 00       	jmp    f0105190 <syscall+0x5a0>
	if ((Ecode = envid2env(envid, &dst, 0)) < 0)
f0104fdc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104fe3:	00 
f0104fe4:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104fe7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104feb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104fee:	89 04 24             	mov    %eax,(%esp)
f0104ff1:	e8 39 e6 ff ff       	call   f010362f <envid2env>
f0104ff6:	85 c0                	test   %eax,%eax
f0104ff8:	0f 88 92 01 00 00    	js     f0105190 <syscall+0x5a0>
	if (!dst->env_ipc_recving)
f0104ffe:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105001:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0105005:	0f 84 fa 00 00 00    	je     f0105105 <syscall+0x515>
	if ((uintptr_t)srcva >= UTOP)
f010500b:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0105012:	0f 87 9b 00 00 00    	ja     f01050b3 <syscall+0x4c3>
		if ((uintptr_t)srcva % PGSIZE != 0)
f0105018:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f010501f:	0f 85 ea 00 00 00    	jne    f010510f <syscall+0x51f>
		if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U))
f0105025:	8b 45 18             	mov    0x18(%ebp),%eax
f0105028:	83 e0 05             	and    $0x5,%eax
f010502b:	83 f8 05             	cmp    $0x5,%eax
f010502e:	0f 85 e2 00 00 00    	jne    f0105116 <syscall+0x526>
		if (perm & ~PTE_SYSCALL)
f0105034:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f010503b:	0f 85 dc 00 00 00    	jne    f010511d <syscall+0x52d>
		if (!(pp = page_lookup(curenv->env_pgdir, srcva, &pte)))
f0105041:	e8 f3 13 00 00       	call   f0106439 <cpunum>
f0105046:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105049:	89 54 24 08          	mov    %edx,0x8(%esp)
f010504d:	8b 7d 14             	mov    0x14(%ebp),%edi
f0105050:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105054:	6b c0 74             	imul   $0x74,%eax,%eax
f0105057:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f010505d:	8b 40 60             	mov    0x60(%eax),%eax
f0105060:	89 04 24             	mov    %eax,(%esp)
f0105063:	e8 6b c2 ff ff       	call   f01012d3 <page_lookup>
f0105068:	85 c0                	test   %eax,%eax
f010506a:	0f 84 b4 00 00 00    	je     f0105124 <syscall+0x534>
		if ((perm & PTE_W) && !(*pte & PTE_W))
f0105070:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0105074:	74 0c                	je     f0105082 <syscall+0x492>
f0105076:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105079:	f6 02 02             	testb  $0x2,(%edx)
f010507c:	0f 84 a9 00 00 00    	je     f010512b <syscall+0x53b>
		if ((uintptr_t)dst->env_ipc_dstva < UTOP)
f0105082:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105085:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0105088:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f010508e:	77 2c                	ja     f01050bc <syscall+0x4cc>
			if ((Ecode = page_insert(dst->env_pgdir, pp, dst->env_ipc_dstva, perm)) < 0)
f0105090:	8b 7d 18             	mov    0x18(%ebp),%edi
f0105093:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105097:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010509b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010509f:	8b 42 60             	mov    0x60(%edx),%eax
f01050a2:	89 04 24             	mov    %eax,(%esp)
f01050a5:	e8 78 c3 ff ff       	call   f0101422 <page_insert>
f01050aa:	85 c0                	test   %eax,%eax
f01050ac:	79 15                	jns    f01050c3 <syscall+0x4d3>
f01050ae:	e9 dd 00 00 00       	jmp    f0105190 <syscall+0x5a0>
		perm = 0;
f01050b3:	c7 45 18 00 00 00 00 	movl   $0x0,0x18(%ebp)
f01050ba:	eb 07                	jmp    f01050c3 <syscall+0x4d3>
			perm = 0;
f01050bc:	c7 45 18 00 00 00 00 	movl   $0x0,0x18(%ebp)
	dst->env_ipc_recving = false;
f01050c3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01050c6:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	dst->env_ipc_from = curenv->env_id;
f01050ca:	e8 6a 13 00 00       	call   f0106439 <cpunum>
f01050cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01050d2:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f01050d8:	8b 40 48             	mov    0x48(%eax),%eax
f01050db:	89 43 74             	mov    %eax,0x74(%ebx)
	dst->env_ipc_value = value;
f01050de:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01050e1:	8b 75 10             	mov    0x10(%ebp),%esi
f01050e4:	89 70 70             	mov    %esi,0x70(%eax)
	dst->env_ipc_perm = perm;
f01050e7:	8b 7d 18             	mov    0x18(%ebp),%edi
f01050ea:	89 78 78             	mov    %edi,0x78(%eax)
	dst->env_status = ENV_RUNNABLE;
f01050ed:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	dst->env_tf.tf_regs.reg_eax = 0;
f01050f4:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f01050fb:	b8 00 00 00 00       	mov    $0x0,%eax
f0105100:	e9 8b 00 00 00       	jmp    f0105190 <syscall+0x5a0>
		return -E_IPC_NOT_RECV;
f0105105:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f010510a:	e9 81 00 00 00       	jmp    f0105190 <syscall+0x5a0>
			return -E_INVAL;
f010510f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105114:	eb 7a                	jmp    f0105190 <syscall+0x5a0>
			return -E_INVAL;
f0105116:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010511b:	eb 73                	jmp    f0105190 <syscall+0x5a0>
			return -E_INVAL;
f010511d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105122:	eb 6c                	jmp    f0105190 <syscall+0x5a0>
			return -E_INVAL;
f0105124:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105129:	eb 65                	jmp    f0105190 <syscall+0x5a0>
			return -E_INVAL;
f010512b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105130:	eb 5e                	jmp    f0105190 <syscall+0x5a0>
	if ((uintptr_t)dstva < UTOP && (uintptr_t)dstva % PGSIZE != 0)
f0105132:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0105139:	77 09                	ja     f0105144 <syscall+0x554>
f010513b:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0105142:	75 47                	jne    f010518b <syscall+0x59b>
	curenv->env_ipc_recving = true;
f0105144:	e8 f0 12 00 00       	call   f0106439 <cpunum>
f0105149:	6b c0 74             	imul   $0x74,%eax,%eax
f010514c:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0105152:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0105156:	e8 de 12 00 00       	call   f0106439 <cpunum>
f010515b:	6b c0 74             	imul   $0x74,%eax,%eax
f010515e:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0105164:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105167:	89 48 6c             	mov    %ecx,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f010516a:	e8 ca 12 00 00       	call   f0106439 <cpunum>
f010516f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105172:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0105178:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f010517f:	e8 bb f9 ff ff       	call   f0104b3f <sched_yield>
		return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned int)a4);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *)a1);
	case NSYSCALLS:
	default:
		return -E_INVAL;
f0105184:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105189:	eb 05                	jmp    f0105190 <syscall+0x5a0>
		return sys_ipc_recv((void *)a1);
f010518b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f0105190:	83 c4 2c             	add    $0x2c,%esp
f0105193:	5b                   	pop    %ebx
f0105194:	5e                   	pop    %esi
f0105195:	5f                   	pop    %edi
f0105196:	5d                   	pop    %ebp
f0105197:	c3                   	ret    

f0105198 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
			   int type, uintptr_t addr)
{
f0105198:	55                   	push   %ebp
f0105199:	89 e5                	mov    %esp,%ebp
f010519b:	57                   	push   %edi
f010519c:	56                   	push   %esi
f010519d:	53                   	push   %ebx
f010519e:	83 ec 14             	sub    $0x14,%esp
f01051a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01051a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01051a7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01051aa:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01051ad:	8b 1a                	mov    (%edx),%ebx
f01051af:	8b 01                	mov    (%ecx),%eax
f01051b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01051b4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r)
f01051bb:	e9 88 00 00 00       	jmp    f0105248 <stab_binsearch+0xb0>
	{
		int true_m = (l + r) / 2, m = true_m;
f01051c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01051c3:	01 d8                	add    %ebx,%eax
f01051c5:	89 c7                	mov    %eax,%edi
f01051c7:	c1 ef 1f             	shr    $0x1f,%edi
f01051ca:	01 c7                	add    %eax,%edi
f01051cc:	d1 ff                	sar    %edi
f01051ce:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01051d1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01051d4:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01051d7:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01051d9:	eb 03                	jmp    f01051de <stab_binsearch+0x46>
			m--;
f01051db:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f01051de:	39 c3                	cmp    %eax,%ebx
f01051e0:	7f 1f                	jg     f0105201 <stab_binsearch+0x69>
f01051e2:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01051e6:	83 ea 0c             	sub    $0xc,%edx
f01051e9:	39 f1                	cmp    %esi,%ecx
f01051eb:	75 ee                	jne    f01051db <stab_binsearch+0x43>
f01051ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr)
f01051f0:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01051f3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01051f6:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01051fa:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01051fd:	76 18                	jbe    f0105217 <stab_binsearch+0x7f>
f01051ff:	eb 05                	jmp    f0105206 <stab_binsearch+0x6e>
			l = true_m + 1;
f0105201:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0105204:	eb 42                	jmp    f0105248 <stab_binsearch+0xb0>
		{
			*region_left = m;
f0105206:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105209:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010520b:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f010520e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105215:	eb 31                	jmp    f0105248 <stab_binsearch+0xb0>
		}
		else if (stabs[m].n_value > addr)
f0105217:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010521a:	73 17                	jae    f0105233 <stab_binsearch+0x9b>
		{
			*region_right = m - 1;
f010521c:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010521f:	83 e8 01             	sub    $0x1,%eax
f0105222:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105225:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105228:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f010522a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105231:	eb 15                	jmp    f0105248 <stab_binsearch+0xb0>
		}
		else
		{
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105233:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105236:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0105239:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f010523b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010523f:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0105241:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r)
f0105248:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010524b:	0f 8e 6f ff ff ff    	jle    f01051c0 <stab_binsearch+0x28>
		}
	}

	if (!any_matches)
f0105251:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0105255:	75 0f                	jne    f0105266 <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f0105257:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010525a:	8b 00                	mov    (%eax),%eax
f010525c:	83 e8 01             	sub    $0x1,%eax
f010525f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105262:	89 07                	mov    %eax,(%edi)
f0105264:	eb 2c                	jmp    f0105292 <stab_binsearch+0xfa>
	else
	{
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105266:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105269:	8b 00                	mov    (%eax),%eax
			 l > *region_left && stabs[l].n_type != type;
f010526b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010526e:	8b 0f                	mov    (%edi),%ecx
f0105270:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105273:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0105276:	8d 14 97             	lea    (%edi,%edx,4),%edx
		for (l = *region_right;
f0105279:	eb 03                	jmp    f010527e <stab_binsearch+0xe6>
			 l--)
f010527b:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f010527e:	39 c8                	cmp    %ecx,%eax
f0105280:	7e 0b                	jle    f010528d <stab_binsearch+0xf5>
			 l > *region_left && stabs[l].n_type != type;
f0105282:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0105286:	83 ea 0c             	sub    $0xc,%edx
f0105289:	39 f3                	cmp    %esi,%ebx
f010528b:	75 ee                	jne    f010527b <stab_binsearch+0xe3>
			/* do nothing */;
		*region_left = l;
f010528d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105290:	89 07                	mov    %eax,(%edi)
	}
}
f0105292:	83 c4 14             	add    $0x14,%esp
f0105295:	5b                   	pop    %ebx
f0105296:	5e                   	pop    %esi
f0105297:	5f                   	pop    %edi
f0105298:	5d                   	pop    %ebp
f0105299:	c3                   	ret    

f010529a <debuginfo_eip>:
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010529a:	55                   	push   %ebp
f010529b:	89 e5                	mov    %esp,%ebp
f010529d:	57                   	push   %edi
f010529e:	56                   	push   %esi
f010529f:	53                   	push   %ebx
f01052a0:	83 ec 4c             	sub    $0x4c,%esp
f01052a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01052a6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01052a9:	c7 07 d4 82 10 f0    	movl   $0xf01082d4,(%edi)
	info->eip_line = 0;
f01052af:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f01052b6:	c7 47 08 d4 82 10 f0 	movl   $0xf01082d4,0x8(%edi)
	info->eip_fn_namelen = 9;
f01052bd:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f01052c4:	89 5f 10             	mov    %ebx,0x10(%edi)
	info->eip_fn_narg = 0;
f01052c7:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM)
f01052ce:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01052d4:	0f 87 cf 00 00 00    	ja     f01053a9 <debuginfo_eip+0x10f>
		const struct UserStabData *usd = (const struct UserStabData *)USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0)
f01052da:	e8 5a 11 00 00       	call   f0106439 <cpunum>
f01052df:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01052e6:	00 
f01052e7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01052ee:	00 
f01052ef:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f01052f6:	00 
f01052f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01052fa:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0105300:	89 04 24             	mov    %eax,(%esp)
f0105303:	e8 b5 e1 ff ff       	call   f01034bd <user_mem_check>
f0105308:	85 c0                	test   %eax,%eax
f010530a:	0f 88 6c 02 00 00    	js     f010557c <debuginfo_eip+0x2e2>
			return -1;

		stabs = usd->stabs;
f0105310:	a1 00 00 20 00       	mov    0x200000,%eax
		stab_end = usd->stab_end;
f0105315:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f010531b:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f0105321:	89 4d c0             	mov    %ecx,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0105324:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f010532a:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, PTE_U) < 0 ||
f010532d:	89 f2                	mov    %esi,%edx
f010532f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0105332:	29 c2                	sub    %eax,%edx
f0105334:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0105337:	e8 fd 10 00 00       	call   f0106439 <cpunum>
f010533c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105343:	00 
f0105344:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0105347:	89 54 24 08          	mov    %edx,0x8(%esp)
f010534b:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010534e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105352:	6b c0 74             	imul   $0x74,%eax,%eax
f0105355:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f010535b:	89 04 24             	mov    %eax,(%esp)
f010535e:	e8 5a e1 ff ff       	call   f01034bd <user_mem_check>
f0105363:	85 c0                	test   %eax,%eax
f0105365:	0f 88 18 02 00 00    	js     f0105583 <debuginfo_eip+0x2e9>
			user_mem_check(curenv, (void *)stabstr, (uintptr_t)stabstr_end - (uintptr_t)stabstr, PTE_U) < 0)
f010536b:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010536e:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0105371:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0105374:	e8 c0 10 00 00       	call   f0106439 <cpunum>
f0105379:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105380:	00 
f0105381:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0105384:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105388:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f010538b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010538f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105392:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0105398:	89 04 24             	mov    %eax,(%esp)
f010539b:	e8 1d e1 ff ff       	call   f01034bd <user_mem_check>
		if (user_mem_check(curenv, (void *)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, PTE_U) < 0 ||
f01053a0:	85 c0                	test   %eax,%eax
f01053a2:	79 1f                	jns    f01053c3 <debuginfo_eip+0x129>
f01053a4:	e9 e1 01 00 00       	jmp    f010558a <debuginfo_eip+0x2f0>
		stabstr_end = __STABSTR_END__;
f01053a9:	c7 45 bc b8 63 11 f0 	movl   $0xf01163b8,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f01053b0:	c7 45 c0 21 2d 11 f0 	movl   $0xf0112d21,-0x40(%ebp)
		stab_end = __STAB_END__;
f01053b7:	be 20 2d 11 f0       	mov    $0xf0112d20,%esi
		stabs = __STAB_BEGIN__;
f01053bc:	c7 45 c4 b4 87 10 f0 	movl   $0xf01087b4,-0x3c(%ebp)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01053c3:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01053c6:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f01053c9:	0f 83 c2 01 00 00    	jae    f0105591 <debuginfo_eip+0x2f7>
f01053cf:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01053d3:	0f 85 bf 01 00 00    	jne    f0105598 <debuginfo_eip+0x2fe>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01053d9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01053e0:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f01053e3:	c1 fe 02             	sar    $0x2,%esi
f01053e6:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f01053ec:	83 e8 01             	sub    $0x1,%eax
f01053ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01053f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01053f6:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01053fd:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105400:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105403:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105406:	89 f0                	mov    %esi,%eax
f0105408:	e8 8b fd ff ff       	call   f0105198 <stab_binsearch>
	if (lfile == 0)
f010540d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105410:	85 c0                	test   %eax,%eax
f0105412:	0f 84 87 01 00 00    	je     f010559f <debuginfo_eip+0x305>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105418:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010541b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010541e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105421:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105425:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f010542c:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010542f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105432:	89 f0                	mov    %esi,%eax
f0105434:	e8 5f fd ff ff       	call   f0105198 <stab_binsearch>

	if (lfun <= rfun)
f0105439:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010543c:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010543f:	39 f0                	cmp    %esi,%eax
f0105441:	7f 32                	jg     f0105475 <debuginfo_eip+0x1db>
	{
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105443:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105446:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0105449:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f010544c:	8b 0a                	mov    (%edx),%ecx
f010544e:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f0105451:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0105454:	2b 4d c0             	sub    -0x40(%ebp),%ecx
f0105457:	39 4d b8             	cmp    %ecx,-0x48(%ebp)
f010545a:	73 09                	jae    f0105465 <debuginfo_eip+0x1cb>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010545c:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f010545f:	03 4d c0             	add    -0x40(%ebp),%ecx
f0105462:	89 4f 08             	mov    %ecx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105465:	8b 52 08             	mov    0x8(%edx),%edx
f0105468:	89 57 10             	mov    %edx,0x10(%edi)
		addr -= info->eip_fn_addr;
f010546b:	29 d3                	sub    %edx,%ebx
		// Search within the function definition for the line number.
		lline = lfun;
f010546d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0105470:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0105473:	eb 0f                	jmp    f0105484 <debuginfo_eip+0x1ea>
	}
	else
	{
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105475:	89 5f 10             	mov    %ebx,0x10(%edi)
		lline = lfile;
f0105478:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010547b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010547e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105481:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105484:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f010548b:	00 
f010548c:	8b 47 08             	mov    0x8(%edi),%eax
f010548f:	89 04 24             	mov    %eax,(%esp)
f0105492:	e8 34 09 00 00       	call   f0105dcb <strfind>
f0105497:	2b 47 08             	sub    0x8(%edi),%eax
f010549a:	89 47 0c             	mov    %eax,0xc(%edi)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr); // 根据%eip的值作为地址查找
f010549d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01054a1:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01054a8:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01054ab:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01054ae:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01054b1:	89 f0                	mov    %esi,%eax
f01054b3:	e8 e0 fc ff ff       	call   f0105198 <stab_binsearch>
	if (lline <= rline)									  // 二分查找，left<=right即终止
f01054b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01054bb:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01054be:	7f 20                	jg     f01054e0 <debuginfo_eip+0x246>
	{
		info->eip_line = stabs[lline].n_desc;
f01054c0:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01054c3:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f01054c8:	89 47 04             	mov    %eax,0x4(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile && stabs[lline].n_type != N_SOL && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01054cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054ce:	89 c3                	mov    %eax,%ebx
f01054d0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01054d3:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01054d6:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01054d9:	89 7d 0c             	mov    %edi,0xc(%ebp)
f01054dc:	89 df                	mov    %ebx,%edi
f01054de:	eb 17                	jmp    f01054f7 <debuginfo_eip+0x25d>
		info->eip_line = 0;
f01054e0:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
		return -1;
f01054e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01054ec:	e9 ba 00 00 00       	jmp    f01055ab <debuginfo_eip+0x311>
f01054f1:	83 e8 01             	sub    $0x1,%eax
f01054f4:	83 ea 0c             	sub    $0xc,%edx
f01054f7:	89 c6                	mov    %eax,%esi
	while (lline >= lfile && stabs[lline].n_type != N_SOL && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01054f9:	39 c7                	cmp    %eax,%edi
f01054fb:	7f 3c                	jg     f0105539 <debuginfo_eip+0x29f>
f01054fd:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105501:	80 f9 84             	cmp    $0x84,%cl
f0105504:	75 08                	jne    f010550e <debuginfo_eip+0x274>
f0105506:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105509:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010550c:	eb 11                	jmp    f010551f <debuginfo_eip+0x285>
f010550e:	80 f9 64             	cmp    $0x64,%cl
f0105511:	75 de                	jne    f01054f1 <debuginfo_eip+0x257>
f0105513:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0105517:	74 d8                	je     f01054f1 <debuginfo_eip+0x257>
f0105519:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010551c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010551f:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0105522:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0105525:	8b 04 83             	mov    (%ebx,%eax,4),%eax
f0105528:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010552b:	2b 55 c0             	sub    -0x40(%ebp),%edx
f010552e:	39 d0                	cmp    %edx,%eax
f0105530:	73 0a                	jae    f010553c <debuginfo_eip+0x2a2>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105532:	03 45 c0             	add    -0x40(%ebp),%eax
f0105535:	89 07                	mov    %eax,(%edi)
f0105537:	eb 03                	jmp    f010553c <debuginfo_eip+0x2a2>
f0105539:	8b 7d 0c             	mov    0xc(%ebp),%edi

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010553c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010553f:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
			 lline < rfun && stabs[lline].n_type == N_PSYM;
			 lline++)
			info->eip_fn_narg++;

	return 0;
f0105542:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0105547:	39 da                	cmp    %ebx,%edx
f0105549:	7d 60                	jge    f01055ab <debuginfo_eip+0x311>
		for (lline = lfun + 1;
f010554b:	83 c2 01             	add    $0x1,%edx
f010554e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105551:	89 d0                	mov    %edx,%eax
f0105553:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105556:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105559:	8d 14 96             	lea    (%esi,%edx,4),%edx
f010555c:	eb 04                	jmp    f0105562 <debuginfo_eip+0x2c8>
			info->eip_fn_narg++;
f010555e:	83 47 14 01          	addl   $0x1,0x14(%edi)
		for (lline = lfun + 1;
f0105562:	39 c3                	cmp    %eax,%ebx
f0105564:	7e 40                	jle    f01055a6 <debuginfo_eip+0x30c>
			 lline < rfun && stabs[lline].n_type == N_PSYM;
f0105566:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010556a:	83 c0 01             	add    $0x1,%eax
f010556d:	83 c2 0c             	add    $0xc,%edx
f0105570:	80 f9 a0             	cmp    $0xa0,%cl
f0105573:	74 e9                	je     f010555e <debuginfo_eip+0x2c4>
	return 0;
f0105575:	b8 00 00 00 00       	mov    $0x0,%eax
f010557a:	eb 2f                	jmp    f01055ab <debuginfo_eip+0x311>
			return -1;
f010557c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105581:	eb 28                	jmp    f01055ab <debuginfo_eip+0x311>
			return -1;
f0105583:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105588:	eb 21                	jmp    f01055ab <debuginfo_eip+0x311>
f010558a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010558f:	eb 1a                	jmp    f01055ab <debuginfo_eip+0x311>
		return -1;
f0105591:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105596:	eb 13                	jmp    f01055ab <debuginfo_eip+0x311>
f0105598:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010559d:	eb 0c                	jmp    f01055ab <debuginfo_eip+0x311>
		return -1;
f010559f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01055a4:	eb 05                	jmp    f01055ab <debuginfo_eip+0x311>
	return 0;
f01055a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01055ab:	83 c4 4c             	add    $0x4c,%esp
f01055ae:	5b                   	pop    %ebx
f01055af:	5e                   	pop    %esi
f01055b0:	5f                   	pop    %edi
f01055b1:	5d                   	pop    %ebp
f01055b2:	c3                   	ret    
f01055b3:	66 90                	xchg   %ax,%ax
f01055b5:	66 90                	xchg   %ax,%ax
f01055b7:	66 90                	xchg   %ax,%ax
f01055b9:	66 90                	xchg   %ax,%ax
f01055bb:	66 90                	xchg   %ax,%ax
f01055bd:	66 90                	xchg   %ax,%ax
f01055bf:	90                   	nop

f01055c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
f01055c0:	55                   	push   %ebp
f01055c1:	89 e5                	mov    %esp,%ebp
f01055c3:	57                   	push   %edi
f01055c4:	56                   	push   %esi
f01055c5:	53                   	push   %ebx
f01055c6:	83 ec 3c             	sub    $0x3c,%esp
f01055c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01055cc:	89 d7                	mov    %edx,%edi
f01055ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01055d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01055d4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01055d7:	89 c3                	mov    %eax,%ebx
f01055d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01055dc:	8b 45 10             	mov    0x10(%ebp),%eax
f01055df:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base)
f01055e2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01055e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01055ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01055ed:	39 d9                	cmp    %ebx,%ecx
f01055ef:	72 05                	jb     f01055f6 <printnum+0x36>
f01055f1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f01055f4:	77 69                	ja     f010565f <printnum+0x9f>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01055f6:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01055f9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01055fd:	83 ee 01             	sub    $0x1,%esi
f0105600:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105604:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105608:	8b 44 24 08          	mov    0x8(%esp),%eax
f010560c:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105610:	89 c3                	mov    %eax,%ebx
f0105612:	89 d6                	mov    %edx,%esi
f0105614:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105617:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010561a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010561e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105622:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105625:	89 04 24             	mov    %eax,(%esp)
f0105628:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010562b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010562f:	e8 4c 12 00 00       	call   f0106880 <__udivdi3>
f0105634:	89 d9                	mov    %ebx,%ecx
f0105636:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010563a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010563e:	89 04 24             	mov    %eax,(%esp)
f0105641:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105645:	89 fa                	mov    %edi,%edx
f0105647:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010564a:	e8 71 ff ff ff       	call   f01055c0 <printnum>
f010564f:	eb 1b                	jmp    f010566c <printnum+0xac>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105651:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105655:	8b 45 18             	mov    0x18(%ebp),%eax
f0105658:	89 04 24             	mov    %eax,(%esp)
f010565b:	ff d3                	call   *%ebx
f010565d:	eb 03                	jmp    f0105662 <printnum+0xa2>
f010565f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
f0105662:	83 ee 01             	sub    $0x1,%esi
f0105665:	85 f6                	test   %esi,%esi
f0105667:	7f e8                	jg     f0105651 <printnum+0x91>
f0105669:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010566c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105670:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105674:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105677:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010567a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010567e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105682:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105685:	89 04 24             	mov    %eax,(%esp)
f0105688:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010568b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010568f:	e8 1c 13 00 00       	call   f01069b0 <__umoddi3>
f0105694:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105698:	0f be 80 de 82 10 f0 	movsbl -0xfef7d22(%eax),%eax
f010569f:	89 04 24             	mov    %eax,(%esp)
f01056a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01056a5:	ff d0                	call   *%eax
}
f01056a7:	83 c4 3c             	add    $0x3c,%esp
f01056aa:	5b                   	pop    %ebx
f01056ab:	5e                   	pop    %esi
f01056ac:	5f                   	pop    %edi
f01056ad:	5d                   	pop    %ebp
f01056ae:	c3                   	ret    

f01056af <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01056af:	55                   	push   %ebp
f01056b0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01056b2:	83 fa 01             	cmp    $0x1,%edx
f01056b5:	7e 0e                	jle    f01056c5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01056b7:	8b 10                	mov    (%eax),%edx
f01056b9:	8d 4a 08             	lea    0x8(%edx),%ecx
f01056bc:	89 08                	mov    %ecx,(%eax)
f01056be:	8b 02                	mov    (%edx),%eax
f01056c0:	8b 52 04             	mov    0x4(%edx),%edx
f01056c3:	eb 22                	jmp    f01056e7 <getuint+0x38>
	else if (lflag)
f01056c5:	85 d2                	test   %edx,%edx
f01056c7:	74 10                	je     f01056d9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01056c9:	8b 10                	mov    (%eax),%edx
f01056cb:	8d 4a 04             	lea    0x4(%edx),%ecx
f01056ce:	89 08                	mov    %ecx,(%eax)
f01056d0:	8b 02                	mov    (%edx),%eax
f01056d2:	ba 00 00 00 00       	mov    $0x0,%edx
f01056d7:	eb 0e                	jmp    f01056e7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01056d9:	8b 10                	mov    (%eax),%edx
f01056db:	8d 4a 04             	lea    0x4(%edx),%ecx
f01056de:	89 08                	mov    %ecx,(%eax)
f01056e0:	8b 02                	mov    (%edx),%eax
f01056e2:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01056e7:	5d                   	pop    %ebp
f01056e8:	c3                   	ret    

f01056e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01056e9:	55                   	push   %ebp
f01056ea:	89 e5                	mov    %esp,%ebp
f01056ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01056ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01056f3:	8b 10                	mov    (%eax),%edx
f01056f5:	3b 50 04             	cmp    0x4(%eax),%edx
f01056f8:	73 0a                	jae    f0105704 <sprintputch+0x1b>
		*b->buf++ = ch;
f01056fa:	8d 4a 01             	lea    0x1(%edx),%ecx
f01056fd:	89 08                	mov    %ecx,(%eax)
f01056ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0105702:	88 02                	mov    %al,(%edx)
}
f0105704:	5d                   	pop    %ebp
f0105705:	c3                   	ret    

f0105706 <printfmt>:
{
f0105706:	55                   	push   %ebp
f0105707:	89 e5                	mov    %esp,%ebp
f0105709:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
f010570c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010570f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105713:	8b 45 10             	mov    0x10(%ebp),%eax
f0105716:	89 44 24 08          	mov    %eax,0x8(%esp)
f010571a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010571d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105721:	8b 45 08             	mov    0x8(%ebp),%eax
f0105724:	89 04 24             	mov    %eax,(%esp)
f0105727:	e8 02 00 00 00       	call   f010572e <vprintfmt>
}
f010572c:	c9                   	leave  
f010572d:	c3                   	ret    

f010572e <vprintfmt>:
{
f010572e:	55                   	push   %ebp
f010572f:	89 e5                	mov    %esp,%ebp
f0105731:	57                   	push   %edi
f0105732:	56                   	push   %esi
f0105733:	53                   	push   %ebx
f0105734:	83 ec 3c             	sub    $0x3c,%esp
f0105737:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010573a:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010573d:	eb 14                	jmp    f0105753 <vprintfmt+0x25>
			if (ch == '\0')
f010573f:	85 c0                	test   %eax,%eax
f0105741:	0f 84 b3 03 00 00    	je     f0105afa <vprintfmt+0x3cc>
			putch(ch, putdat);
f0105747:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010574b:	89 04 24             	mov    %eax,(%esp)
f010574e:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
f0105751:	89 f3                	mov    %esi,%ebx
f0105753:	8d 73 01             	lea    0x1(%ebx),%esi
f0105756:	0f b6 03             	movzbl (%ebx),%eax
f0105759:	83 f8 25             	cmp    $0x25,%eax
f010575c:	75 e1                	jne    f010573f <vprintfmt+0x11>
f010575e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0105762:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0105769:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0105770:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0105777:	ba 00 00 00 00       	mov    $0x0,%edx
f010577c:	eb 1d                	jmp    f010579b <vprintfmt+0x6d>
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f010577e:	89 de                	mov    %ebx,%esi
			padc = '-';
f0105780:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0105784:	eb 15                	jmp    f010579b <vprintfmt+0x6d>
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f0105786:	89 de                	mov    %ebx,%esi
			padc = '0';
f0105788:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f010578c:	eb 0d                	jmp    f010579b <vprintfmt+0x6d>
				width = precision, precision = -1;
f010578e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105791:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105794:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f010579b:	8d 5e 01             	lea    0x1(%esi),%ebx
f010579e:	0f b6 0e             	movzbl (%esi),%ecx
f01057a1:	0f b6 c1             	movzbl %cl,%eax
f01057a4:	83 e9 23             	sub    $0x23,%ecx
f01057a7:	80 f9 55             	cmp    $0x55,%cl
f01057aa:	0f 87 2a 03 00 00    	ja     f0105ada <vprintfmt+0x3ac>
f01057b0:	0f b6 c9             	movzbl %cl,%ecx
f01057b3:	ff 24 8d a0 83 10 f0 	jmp    *-0xfef7c60(,%ecx,4)
f01057ba:	89 de                	mov    %ebx,%esi
f01057bc:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
f01057c1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f01057c4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f01057c8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01057cb:	8d 58 d0             	lea    -0x30(%eax),%ebx
f01057ce:	83 fb 09             	cmp    $0x9,%ebx
f01057d1:	77 36                	ja     f0105809 <vprintfmt+0xdb>
			for (precision = 0;; ++fmt)
f01057d3:	83 c6 01             	add    $0x1,%esi
			}
f01057d6:	eb e9                	jmp    f01057c1 <vprintfmt+0x93>
			precision = va_arg(ap, int);
f01057d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01057db:	8d 48 04             	lea    0x4(%eax),%ecx
f01057de:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01057e1:	8b 00                	mov    (%eax),%eax
f01057e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f01057e6:	89 de                	mov    %ebx,%esi
			goto process_precision;
f01057e8:	eb 22                	jmp    f010580c <vprintfmt+0xde>
f01057ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01057ed:	85 c9                	test   %ecx,%ecx
f01057ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01057f4:	0f 49 c1             	cmovns %ecx,%eax
f01057f7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f01057fa:	89 de                	mov    %ebx,%esi
f01057fc:	eb 9d                	jmp    f010579b <vprintfmt+0x6d>
f01057fe:	89 de                	mov    %ebx,%esi
			altflag = 1;
f0105800:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0105807:	eb 92                	jmp    f010579b <vprintfmt+0x6d>
f0105809:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
f010580c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105810:	79 89                	jns    f010579b <vprintfmt+0x6d>
f0105812:	e9 77 ff ff ff       	jmp    f010578e <vprintfmt+0x60>
			lflag++;
f0105817:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f010581a:	89 de                	mov    %ebx,%esi
			goto reswitch;
f010581c:	e9 7a ff ff ff       	jmp    f010579b <vprintfmt+0x6d>
			putch(va_arg(ap, int), putdat);
f0105821:	8b 45 14             	mov    0x14(%ebp),%eax
f0105824:	8d 50 04             	lea    0x4(%eax),%edx
f0105827:	89 55 14             	mov    %edx,0x14(%ebp)
f010582a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010582e:	8b 00                	mov    (%eax),%eax
f0105830:	89 04 24             	mov    %eax,(%esp)
f0105833:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105836:	e9 18 ff ff ff       	jmp    f0105753 <vprintfmt+0x25>
			err = va_arg(ap, int);
f010583b:	8b 45 14             	mov    0x14(%ebp),%eax
f010583e:	8d 50 04             	lea    0x4(%eax),%edx
f0105841:	89 55 14             	mov    %edx,0x14(%ebp)
f0105844:	8b 00                	mov    (%eax),%eax
f0105846:	99                   	cltd   
f0105847:	31 d0                	xor    %edx,%eax
f0105849:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010584b:	83 f8 08             	cmp    $0x8,%eax
f010584e:	7f 0b                	jg     f010585b <vprintfmt+0x12d>
f0105850:	8b 14 85 00 85 10 f0 	mov    -0xfef7b00(,%eax,4),%edx
f0105857:	85 d2                	test   %edx,%edx
f0105859:	75 20                	jne    f010587b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
f010585b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010585f:	c7 44 24 08 f6 82 10 	movl   $0xf01082f6,0x8(%esp)
f0105866:	f0 
f0105867:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010586b:	8b 45 08             	mov    0x8(%ebp),%eax
f010586e:	89 04 24             	mov    %eax,(%esp)
f0105871:	e8 90 fe ff ff       	call   f0105706 <printfmt>
f0105876:	e9 d8 fe ff ff       	jmp    f0105753 <vprintfmt+0x25>
				printfmt(putch, putdat, "%s", p);
f010587b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010587f:	c7 44 24 08 d1 7a 10 	movl   $0xf0107ad1,0x8(%esp)
f0105886:	f0 
f0105887:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010588b:	8b 45 08             	mov    0x8(%ebp),%eax
f010588e:	89 04 24             	mov    %eax,(%esp)
f0105891:	e8 70 fe ff ff       	call   f0105706 <printfmt>
f0105896:	e9 b8 fe ff ff       	jmp    f0105753 <vprintfmt+0x25>
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f010589b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010589e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01058a1:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
f01058a4:	8b 45 14             	mov    0x14(%ebp),%eax
f01058a7:	8d 50 04             	lea    0x4(%eax),%edx
f01058aa:	89 55 14             	mov    %edx,0x14(%ebp)
f01058ad:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f01058af:	85 f6                	test   %esi,%esi
f01058b1:	b8 ef 82 10 f0       	mov    $0xf01082ef,%eax
f01058b6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f01058b9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f01058bd:	0f 84 97 00 00 00    	je     f010595a <vprintfmt+0x22c>
f01058c3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01058c7:	0f 8e 9b 00 00 00    	jle    f0105968 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
f01058cd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01058d1:	89 34 24             	mov    %esi,(%esp)
f01058d4:	e8 9f 03 00 00       	call   f0105c78 <strnlen>
f01058d9:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01058dc:	29 c2                	sub    %eax,%edx
f01058de:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
f01058e1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f01058e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01058e8:	89 75 d8             	mov    %esi,-0x28(%ebp)
f01058eb:	8b 75 08             	mov    0x8(%ebp),%esi
f01058ee:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01058f1:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
f01058f3:	eb 0f                	jmp    f0105904 <vprintfmt+0x1d6>
					putch(padc, putdat);
f01058f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01058f9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01058fc:	89 04 24             	mov    %eax,(%esp)
f01058ff:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105901:	83 eb 01             	sub    $0x1,%ebx
f0105904:	85 db                	test   %ebx,%ebx
f0105906:	7f ed                	jg     f01058f5 <vprintfmt+0x1c7>
f0105908:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010590b:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010590e:	85 d2                	test   %edx,%edx
f0105910:	b8 00 00 00 00       	mov    $0x0,%eax
f0105915:	0f 49 c2             	cmovns %edx,%eax
f0105918:	29 c2                	sub    %eax,%edx
f010591a:	89 7d 0c             	mov    %edi,0xc(%ebp)
f010591d:	89 d7                	mov    %edx,%edi
f010591f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105922:	eb 50                	jmp    f0105974 <vprintfmt+0x246>
				if (altflag && (ch < ' ' || ch > '~'))
f0105924:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105928:	74 1e                	je     f0105948 <vprintfmt+0x21a>
f010592a:	0f be d2             	movsbl %dl,%edx
f010592d:	83 ea 20             	sub    $0x20,%edx
f0105930:	83 fa 5e             	cmp    $0x5e,%edx
f0105933:	76 13                	jbe    f0105948 <vprintfmt+0x21a>
					putch('?', putdat);
f0105935:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105938:	89 44 24 04          	mov    %eax,0x4(%esp)
f010593c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105943:	ff 55 08             	call   *0x8(%ebp)
f0105946:	eb 0d                	jmp    f0105955 <vprintfmt+0x227>
					putch(ch, putdat);
f0105948:	8b 55 0c             	mov    0xc(%ebp),%edx
f010594b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010594f:	89 04 24             	mov    %eax,(%esp)
f0105952:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105955:	83 ef 01             	sub    $0x1,%edi
f0105958:	eb 1a                	jmp    f0105974 <vprintfmt+0x246>
f010595a:	89 7d 0c             	mov    %edi,0xc(%ebp)
f010595d:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0105960:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105963:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105966:	eb 0c                	jmp    f0105974 <vprintfmt+0x246>
f0105968:	89 7d 0c             	mov    %edi,0xc(%ebp)
f010596b:	8b 7d dc             	mov    -0x24(%ebp),%edi
f010596e:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105971:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105974:	83 c6 01             	add    $0x1,%esi
f0105977:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f010597b:	0f be c2             	movsbl %dl,%eax
f010597e:	85 c0                	test   %eax,%eax
f0105980:	74 27                	je     f01059a9 <vprintfmt+0x27b>
f0105982:	85 db                	test   %ebx,%ebx
f0105984:	78 9e                	js     f0105924 <vprintfmt+0x1f6>
f0105986:	83 eb 01             	sub    $0x1,%ebx
f0105989:	79 99                	jns    f0105924 <vprintfmt+0x1f6>
f010598b:	89 f8                	mov    %edi,%eax
f010598d:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105990:	8b 75 08             	mov    0x8(%ebp),%esi
f0105993:	89 c3                	mov    %eax,%ebx
f0105995:	eb 1a                	jmp    f01059b1 <vprintfmt+0x283>
				putch(' ', putdat);
f0105997:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010599b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01059a2:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01059a4:	83 eb 01             	sub    $0x1,%ebx
f01059a7:	eb 08                	jmp    f01059b1 <vprintfmt+0x283>
f01059a9:	89 fb                	mov    %edi,%ebx
f01059ab:	8b 75 08             	mov    0x8(%ebp),%esi
f01059ae:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01059b1:	85 db                	test   %ebx,%ebx
f01059b3:	7f e2                	jg     f0105997 <vprintfmt+0x269>
f01059b5:	89 75 08             	mov    %esi,0x8(%ebp)
f01059b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01059bb:	e9 93 fd ff ff       	jmp    f0105753 <vprintfmt+0x25>
	if (lflag >= 2)
f01059c0:	83 fa 01             	cmp    $0x1,%edx
f01059c3:	7e 16                	jle    f01059db <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
f01059c5:	8b 45 14             	mov    0x14(%ebp),%eax
f01059c8:	8d 50 08             	lea    0x8(%eax),%edx
f01059cb:	89 55 14             	mov    %edx,0x14(%ebp)
f01059ce:	8b 50 04             	mov    0x4(%eax),%edx
f01059d1:	8b 00                	mov    (%eax),%eax
f01059d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01059d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01059d9:	eb 32                	jmp    f0105a0d <vprintfmt+0x2df>
	else if (lflag)
f01059db:	85 d2                	test   %edx,%edx
f01059dd:	74 18                	je     f01059f7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
f01059df:	8b 45 14             	mov    0x14(%ebp),%eax
f01059e2:	8d 50 04             	lea    0x4(%eax),%edx
f01059e5:	89 55 14             	mov    %edx,0x14(%ebp)
f01059e8:	8b 30                	mov    (%eax),%esi
f01059ea:	89 75 e0             	mov    %esi,-0x20(%ebp)
f01059ed:	89 f0                	mov    %esi,%eax
f01059ef:	c1 f8 1f             	sar    $0x1f,%eax
f01059f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01059f5:	eb 16                	jmp    f0105a0d <vprintfmt+0x2df>
		return va_arg(*ap, int);
f01059f7:	8b 45 14             	mov    0x14(%ebp),%eax
f01059fa:	8d 50 04             	lea    0x4(%eax),%edx
f01059fd:	89 55 14             	mov    %edx,0x14(%ebp)
f0105a00:	8b 30                	mov    (%eax),%esi
f0105a02:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0105a05:	89 f0                	mov    %esi,%eax
f0105a07:	c1 f8 1f             	sar    $0x1f,%eax
f0105a0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
f0105a0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105a10:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10; // base代表进制数
f0105a13:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long)num < 0)
f0105a18:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105a1c:	0f 89 80 00 00 00    	jns    f0105aa2 <vprintfmt+0x374>
				putch('-', putdat);
f0105a22:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a26:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105a2d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
f0105a30:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105a33:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105a36:	f7 d8                	neg    %eax
f0105a38:	83 d2 00             	adc    $0x0,%edx
f0105a3b:	f7 da                	neg    %edx
			base = 10; // base代表进制数
f0105a3d:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105a42:	eb 5e                	jmp    f0105aa2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
f0105a44:	8d 45 14             	lea    0x14(%ebp),%eax
f0105a47:	e8 63 fc ff ff       	call   f01056af <getuint>
			base = 10;
f0105a4c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105a51:	eb 4f                	jmp    f0105aa2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
f0105a53:	8d 45 14             	lea    0x14(%ebp),%eax
f0105a56:	e8 54 fc ff ff       	call   f01056af <getuint>
			base = 8;
f0105a5b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105a60:	eb 40                	jmp    f0105aa2 <vprintfmt+0x374>
			putch('0', putdat);
f0105a62:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a66:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105a6d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105a70:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a74:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105a7b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
f0105a7e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a81:	8d 50 04             	lea    0x4(%eax),%edx
f0105a84:	89 55 14             	mov    %edx,0x14(%ebp)
f0105a87:	8b 00                	mov    (%eax),%eax
f0105a89:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
f0105a8e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105a93:	eb 0d                	jmp    f0105aa2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
f0105a95:	8d 45 14             	lea    0x14(%ebp),%eax
f0105a98:	e8 12 fc ff ff       	call   f01056af <getuint>
			base = 16;
f0105a9d:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
f0105aa2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
f0105aa6:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105aaa:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0105aad:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105ab1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105ab5:	89 04 24             	mov    %eax,(%esp)
f0105ab8:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105abc:	89 fa                	mov    %edi,%edx
f0105abe:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ac1:	e8 fa fa ff ff       	call   f01055c0 <printnum>
			break;
f0105ac6:	e9 88 fc ff ff       	jmp    f0105753 <vprintfmt+0x25>
			putch(ch, putdat);
f0105acb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105acf:	89 04 24             	mov    %eax,(%esp)
f0105ad2:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105ad5:	e9 79 fc ff ff       	jmp    f0105753 <vprintfmt+0x25>
			putch('%', putdat);
f0105ada:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105ade:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105ae5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105ae8:	89 f3                	mov    %esi,%ebx
f0105aea:	eb 03                	jmp    f0105aef <vprintfmt+0x3c1>
f0105aec:	83 eb 01             	sub    $0x1,%ebx
f0105aef:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0105af3:	75 f7                	jne    f0105aec <vprintfmt+0x3be>
f0105af5:	e9 59 fc ff ff       	jmp    f0105753 <vprintfmt+0x25>
}
f0105afa:	83 c4 3c             	add    $0x3c,%esp
f0105afd:	5b                   	pop    %ebx
f0105afe:	5e                   	pop    %esi
f0105aff:	5f                   	pop    %edi
f0105b00:	5d                   	pop    %ebp
f0105b01:	c3                   	ret    

f0105b02 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105b02:	55                   	push   %ebp
f0105b03:	89 e5                	mov    %esp,%ebp
f0105b05:	83 ec 28             	sub    $0x28,%esp
f0105b08:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b0b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
f0105b0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105b11:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105b15:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105b18:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105b1f:	85 c0                	test   %eax,%eax
f0105b21:	74 30                	je     f0105b53 <vsnprintf+0x51>
f0105b23:	85 d2                	test   %edx,%edx
f0105b25:	7e 2c                	jle    f0105b53 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
f0105b27:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b2a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105b2e:	8b 45 10             	mov    0x10(%ebp),%eax
f0105b31:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105b35:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105b38:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b3c:	c7 04 24 e9 56 10 f0 	movl   $0xf01056e9,(%esp)
f0105b43:	e8 e6 fb ff ff       	call   f010572e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105b48:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105b4b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105b51:	eb 05                	jmp    f0105b58 <vsnprintf+0x56>
		return -E_INVAL;
f0105b53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
f0105b58:	c9                   	leave  
f0105b59:	c3                   	ret    

f0105b5a <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
f0105b5a:	55                   	push   %ebp
f0105b5b:	89 e5                	mov    %esp,%ebp
f0105b5d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105b60:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105b63:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105b67:	8b 45 10             	mov    0x10(%ebp),%eax
f0105b6a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105b6e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b71:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b75:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b78:	89 04 24             	mov    %eax,(%esp)
f0105b7b:	e8 82 ff ff ff       	call   f0105b02 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105b80:	c9                   	leave  
f0105b81:	c3                   	ret    
f0105b82:	66 90                	xchg   %ax,%ax
f0105b84:	66 90                	xchg   %ax,%ax
f0105b86:	66 90                	xchg   %ax,%ax
f0105b88:	66 90                	xchg   %ax,%ax
f0105b8a:	66 90                	xchg   %ax,%ax
f0105b8c:	66 90                	xchg   %ax,%ax
f0105b8e:	66 90                	xchg   %ax,%ax

f0105b90 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105b90:	55                   	push   %ebp
f0105b91:	89 e5                	mov    %esp,%ebp
f0105b93:	57                   	push   %edi
f0105b94:	56                   	push   %esi
f0105b95:	53                   	push   %ebx
f0105b96:	83 ec 1c             	sub    $0x1c,%esp
f0105b99:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105b9c:	85 c0                	test   %eax,%eax
f0105b9e:	74 10                	je     f0105bb0 <readline+0x20>
		cprintf("%s", prompt);
f0105ba0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ba4:	c7 04 24 d1 7a 10 f0 	movl   $0xf0107ad1,(%esp)
f0105bab:	e8 75 e3 ff ff       	call   f0103f25 <cprintf>

	i = 0;
	echoing = iscons(0);
f0105bb0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105bb7:	e8 ff ab ff ff       	call   f01007bb <iscons>
f0105bbc:	89 c7                	mov    %eax,%edi
	i = 0;
f0105bbe:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0105bc3:	e8 e2 ab ff ff       	call   f01007aa <getchar>
f0105bc8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105bca:	85 c0                	test   %eax,%eax
f0105bcc:	79 17                	jns    f0105be5 <readline+0x55>
			cprintf("read error: %e\n", c);
f0105bce:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105bd2:	c7 04 24 24 85 10 f0 	movl   $0xf0108524,(%esp)
f0105bd9:	e8 47 e3 ff ff       	call   f0103f25 <cprintf>
			return NULL;
f0105bde:	b8 00 00 00 00       	mov    $0x0,%eax
f0105be3:	eb 6d                	jmp    f0105c52 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105be5:	83 f8 7f             	cmp    $0x7f,%eax
f0105be8:	74 05                	je     f0105bef <readline+0x5f>
f0105bea:	83 f8 08             	cmp    $0x8,%eax
f0105bed:	75 19                	jne    f0105c08 <readline+0x78>
f0105bef:	85 f6                	test   %esi,%esi
f0105bf1:	7e 15                	jle    f0105c08 <readline+0x78>
			if (echoing)
f0105bf3:	85 ff                	test   %edi,%edi
f0105bf5:	74 0c                	je     f0105c03 <readline+0x73>
				cputchar('\b');
f0105bf7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105bfe:	e8 97 ab ff ff       	call   f010079a <cputchar>
			i--;
f0105c03:	83 ee 01             	sub    $0x1,%esi
f0105c06:	eb bb                	jmp    f0105bc3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105c08:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105c0e:	7f 1c                	jg     f0105c2c <readline+0x9c>
f0105c10:	83 fb 1f             	cmp    $0x1f,%ebx
f0105c13:	7e 17                	jle    f0105c2c <readline+0x9c>
			if (echoing)
f0105c15:	85 ff                	test   %edi,%edi
f0105c17:	74 08                	je     f0105c21 <readline+0x91>
				cputchar(c);
f0105c19:	89 1c 24             	mov    %ebx,(%esp)
f0105c1c:	e8 79 ab ff ff       	call   f010079a <cputchar>
			buf[i++] = c;
f0105c21:	88 9e 80 0a 23 f0    	mov    %bl,-0xfdcf580(%esi)
f0105c27:	8d 76 01             	lea    0x1(%esi),%esi
f0105c2a:	eb 97                	jmp    f0105bc3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105c2c:	83 fb 0d             	cmp    $0xd,%ebx
f0105c2f:	74 05                	je     f0105c36 <readline+0xa6>
f0105c31:	83 fb 0a             	cmp    $0xa,%ebx
f0105c34:	75 8d                	jne    f0105bc3 <readline+0x33>
			if (echoing)
f0105c36:	85 ff                	test   %edi,%edi
f0105c38:	74 0c                	je     f0105c46 <readline+0xb6>
				cputchar('\n');
f0105c3a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105c41:	e8 54 ab ff ff       	call   f010079a <cputchar>
			buf[i] = 0;
f0105c46:	c6 86 80 0a 23 f0 00 	movb   $0x0,-0xfdcf580(%esi)
			return buf;
f0105c4d:	b8 80 0a 23 f0       	mov    $0xf0230a80,%eax
		}
	}
}
f0105c52:	83 c4 1c             	add    $0x1c,%esp
f0105c55:	5b                   	pop    %ebx
f0105c56:	5e                   	pop    %esi
f0105c57:	5f                   	pop    %edi
f0105c58:	5d                   	pop    %ebp
f0105c59:	c3                   	ret    
f0105c5a:	66 90                	xchg   %ax,%ax
f0105c5c:	66 90                	xchg   %ax,%ax
f0105c5e:	66 90                	xchg   %ax,%ax

f0105c60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105c60:	55                   	push   %ebp
f0105c61:	89 e5                	mov    %esp,%ebp
f0105c63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105c66:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c6b:	eb 03                	jmp    f0105c70 <strlen+0x10>
		n++;
f0105c6d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0105c70:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105c74:	75 f7                	jne    f0105c6d <strlen+0xd>
	return n;
}
f0105c76:	5d                   	pop    %ebp
f0105c77:	c3                   	ret    

f0105c78 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105c78:	55                   	push   %ebp
f0105c79:	89 e5                	mov    %esp,%ebp
f0105c7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105c7e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105c81:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c86:	eb 03                	jmp    f0105c8b <strnlen+0x13>
		n++;
f0105c88:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105c8b:	39 d0                	cmp    %edx,%eax
f0105c8d:	74 06                	je     f0105c95 <strnlen+0x1d>
f0105c8f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105c93:	75 f3                	jne    f0105c88 <strnlen+0x10>
	return n;
}
f0105c95:	5d                   	pop    %ebp
f0105c96:	c3                   	ret    

f0105c97 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105c97:	55                   	push   %ebp
f0105c98:	89 e5                	mov    %esp,%ebp
f0105c9a:	53                   	push   %ebx
f0105c9b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105ca1:	89 c2                	mov    %eax,%edx
f0105ca3:	83 c2 01             	add    $0x1,%edx
f0105ca6:	83 c1 01             	add    $0x1,%ecx
f0105ca9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105cad:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105cb0:	84 db                	test   %bl,%bl
f0105cb2:	75 ef                	jne    f0105ca3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105cb4:	5b                   	pop    %ebx
f0105cb5:	5d                   	pop    %ebp
f0105cb6:	c3                   	ret    

f0105cb7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105cb7:	55                   	push   %ebp
f0105cb8:	89 e5                	mov    %esp,%ebp
f0105cba:	53                   	push   %ebx
f0105cbb:	83 ec 08             	sub    $0x8,%esp
f0105cbe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105cc1:	89 1c 24             	mov    %ebx,(%esp)
f0105cc4:	e8 97 ff ff ff       	call   f0105c60 <strlen>
	strcpy(dst + len, src);
f0105cc9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105ccc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105cd0:	01 d8                	add    %ebx,%eax
f0105cd2:	89 04 24             	mov    %eax,(%esp)
f0105cd5:	e8 bd ff ff ff       	call   f0105c97 <strcpy>
	return dst;
}
f0105cda:	89 d8                	mov    %ebx,%eax
f0105cdc:	83 c4 08             	add    $0x8,%esp
f0105cdf:	5b                   	pop    %ebx
f0105ce0:	5d                   	pop    %ebp
f0105ce1:	c3                   	ret    

f0105ce2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105ce2:	55                   	push   %ebp
f0105ce3:	89 e5                	mov    %esp,%ebp
f0105ce5:	56                   	push   %esi
f0105ce6:	53                   	push   %ebx
f0105ce7:	8b 75 08             	mov    0x8(%ebp),%esi
f0105cea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105ced:	89 f3                	mov    %esi,%ebx
f0105cef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105cf2:	89 f2                	mov    %esi,%edx
f0105cf4:	eb 0f                	jmp    f0105d05 <strncpy+0x23>
		*dst++ = *src;
f0105cf6:	83 c2 01             	add    $0x1,%edx
f0105cf9:	0f b6 01             	movzbl (%ecx),%eax
f0105cfc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105cff:	80 39 01             	cmpb   $0x1,(%ecx)
f0105d02:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0105d05:	39 da                	cmp    %ebx,%edx
f0105d07:	75 ed                	jne    f0105cf6 <strncpy+0x14>
	}
	return ret;
}
f0105d09:	89 f0                	mov    %esi,%eax
f0105d0b:	5b                   	pop    %ebx
f0105d0c:	5e                   	pop    %esi
f0105d0d:	5d                   	pop    %ebp
f0105d0e:	c3                   	ret    

f0105d0f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105d0f:	55                   	push   %ebp
f0105d10:	89 e5                	mov    %esp,%ebp
f0105d12:	56                   	push   %esi
f0105d13:	53                   	push   %ebx
f0105d14:	8b 75 08             	mov    0x8(%ebp),%esi
f0105d17:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105d1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105d1d:	89 f0                	mov    %esi,%eax
f0105d1f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105d23:	85 c9                	test   %ecx,%ecx
f0105d25:	75 0b                	jne    f0105d32 <strlcpy+0x23>
f0105d27:	eb 1d                	jmp    f0105d46 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105d29:	83 c0 01             	add    $0x1,%eax
f0105d2c:	83 c2 01             	add    $0x1,%edx
f0105d2f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0105d32:	39 d8                	cmp    %ebx,%eax
f0105d34:	74 0b                	je     f0105d41 <strlcpy+0x32>
f0105d36:	0f b6 0a             	movzbl (%edx),%ecx
f0105d39:	84 c9                	test   %cl,%cl
f0105d3b:	75 ec                	jne    f0105d29 <strlcpy+0x1a>
f0105d3d:	89 c2                	mov    %eax,%edx
f0105d3f:	eb 02                	jmp    f0105d43 <strlcpy+0x34>
f0105d41:	89 c2                	mov    %eax,%edx
		*dst = '\0';
f0105d43:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0105d46:	29 f0                	sub    %esi,%eax
}
f0105d48:	5b                   	pop    %ebx
f0105d49:	5e                   	pop    %esi
f0105d4a:	5d                   	pop    %ebp
f0105d4b:	c3                   	ret    

f0105d4c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105d4c:	55                   	push   %ebp
f0105d4d:	89 e5                	mov    %esp,%ebp
f0105d4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105d52:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105d55:	eb 06                	jmp    f0105d5d <strcmp+0x11>
		p++, q++;
f0105d57:	83 c1 01             	add    $0x1,%ecx
f0105d5a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0105d5d:	0f b6 01             	movzbl (%ecx),%eax
f0105d60:	84 c0                	test   %al,%al
f0105d62:	74 04                	je     f0105d68 <strcmp+0x1c>
f0105d64:	3a 02                	cmp    (%edx),%al
f0105d66:	74 ef                	je     f0105d57 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105d68:	0f b6 c0             	movzbl %al,%eax
f0105d6b:	0f b6 12             	movzbl (%edx),%edx
f0105d6e:	29 d0                	sub    %edx,%eax
}
f0105d70:	5d                   	pop    %ebp
f0105d71:	c3                   	ret    

f0105d72 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105d72:	55                   	push   %ebp
f0105d73:	89 e5                	mov    %esp,%ebp
f0105d75:	53                   	push   %ebx
f0105d76:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d79:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105d7c:	89 c3                	mov    %eax,%ebx
f0105d7e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105d81:	eb 06                	jmp    f0105d89 <strncmp+0x17>
		n--, p++, q++;
f0105d83:	83 c0 01             	add    $0x1,%eax
f0105d86:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105d89:	39 d8                	cmp    %ebx,%eax
f0105d8b:	74 15                	je     f0105da2 <strncmp+0x30>
f0105d8d:	0f b6 08             	movzbl (%eax),%ecx
f0105d90:	84 c9                	test   %cl,%cl
f0105d92:	74 04                	je     f0105d98 <strncmp+0x26>
f0105d94:	3a 0a                	cmp    (%edx),%cl
f0105d96:	74 eb                	je     f0105d83 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105d98:	0f b6 00             	movzbl (%eax),%eax
f0105d9b:	0f b6 12             	movzbl (%edx),%edx
f0105d9e:	29 d0                	sub    %edx,%eax
f0105da0:	eb 05                	jmp    f0105da7 <strncmp+0x35>
		return 0;
f0105da2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105da7:	5b                   	pop    %ebx
f0105da8:	5d                   	pop    %ebp
f0105da9:	c3                   	ret    

f0105daa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105daa:	55                   	push   %ebp
f0105dab:	89 e5                	mov    %esp,%ebp
f0105dad:	8b 45 08             	mov    0x8(%ebp),%eax
f0105db0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105db4:	eb 07                	jmp    f0105dbd <strchr+0x13>
		if (*s == c)
f0105db6:	38 ca                	cmp    %cl,%dl
f0105db8:	74 0f                	je     f0105dc9 <strchr+0x1f>
	for (; *s; s++)
f0105dba:	83 c0 01             	add    $0x1,%eax
f0105dbd:	0f b6 10             	movzbl (%eax),%edx
f0105dc0:	84 d2                	test   %dl,%dl
f0105dc2:	75 f2                	jne    f0105db6 <strchr+0xc>
			return (char *) s;
	return 0;
f0105dc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105dc9:	5d                   	pop    %ebp
f0105dca:	c3                   	ret    

f0105dcb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105dcb:	55                   	push   %ebp
f0105dcc:	89 e5                	mov    %esp,%ebp
f0105dce:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dd1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105dd5:	eb 07                	jmp    f0105dde <strfind+0x13>
		if (*s == c)
f0105dd7:	38 ca                	cmp    %cl,%dl
f0105dd9:	74 0a                	je     f0105de5 <strfind+0x1a>
	for (; *s; s++)
f0105ddb:	83 c0 01             	add    $0x1,%eax
f0105dde:	0f b6 10             	movzbl (%eax),%edx
f0105de1:	84 d2                	test   %dl,%dl
f0105de3:	75 f2                	jne    f0105dd7 <strfind+0xc>
			break;
	return (char *) s;
}
f0105de5:	5d                   	pop    %ebp
f0105de6:	c3                   	ret    

f0105de7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105de7:	55                   	push   %ebp
f0105de8:	89 e5                	mov    %esp,%ebp
f0105dea:	57                   	push   %edi
f0105deb:	56                   	push   %esi
f0105dec:	53                   	push   %ebx
f0105ded:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105df0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105df3:	85 c9                	test   %ecx,%ecx
f0105df5:	74 36                	je     f0105e2d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105df7:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105dfd:	75 28                	jne    f0105e27 <memset+0x40>
f0105dff:	f6 c1 03             	test   $0x3,%cl
f0105e02:	75 23                	jne    f0105e27 <memset+0x40>
		c &= 0xFF;
f0105e04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105e08:	89 d3                	mov    %edx,%ebx
f0105e0a:	c1 e3 08             	shl    $0x8,%ebx
f0105e0d:	89 d6                	mov    %edx,%esi
f0105e0f:	c1 e6 18             	shl    $0x18,%esi
f0105e12:	89 d0                	mov    %edx,%eax
f0105e14:	c1 e0 10             	shl    $0x10,%eax
f0105e17:	09 f0                	or     %esi,%eax
f0105e19:	09 c2                	or     %eax,%edx
f0105e1b:	89 d0                	mov    %edx,%eax
f0105e1d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105e1f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105e22:	fc                   	cld    
f0105e23:	f3 ab                	rep stos %eax,%es:(%edi)
f0105e25:	eb 06                	jmp    f0105e2d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105e27:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105e2a:	fc                   	cld    
f0105e2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105e2d:	89 f8                	mov    %edi,%eax
f0105e2f:	5b                   	pop    %ebx
f0105e30:	5e                   	pop    %esi
f0105e31:	5f                   	pop    %edi
f0105e32:	5d                   	pop    %ebp
f0105e33:	c3                   	ret    

f0105e34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105e34:	55                   	push   %ebp
f0105e35:	89 e5                	mov    %esp,%ebp
f0105e37:	57                   	push   %edi
f0105e38:	56                   	push   %esi
f0105e39:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e3c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105e3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105e42:	39 c6                	cmp    %eax,%esi
f0105e44:	73 35                	jae    f0105e7b <memmove+0x47>
f0105e46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105e49:	39 d0                	cmp    %edx,%eax
f0105e4b:	73 2e                	jae    f0105e7b <memmove+0x47>
		s += n;
		d += n;
f0105e4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0105e50:	89 d6                	mov    %edx,%esi
f0105e52:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105e54:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105e5a:	75 13                	jne    f0105e6f <memmove+0x3b>
f0105e5c:	f6 c1 03             	test   $0x3,%cl
f0105e5f:	75 0e                	jne    f0105e6f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105e61:	83 ef 04             	sub    $0x4,%edi
f0105e64:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105e67:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105e6a:	fd                   	std    
f0105e6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105e6d:	eb 09                	jmp    f0105e78 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105e6f:	83 ef 01             	sub    $0x1,%edi
f0105e72:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105e75:	fd                   	std    
f0105e76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105e78:	fc                   	cld    
f0105e79:	eb 1d                	jmp    f0105e98 <memmove+0x64>
f0105e7b:	89 f2                	mov    %esi,%edx
f0105e7d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105e7f:	f6 c2 03             	test   $0x3,%dl
f0105e82:	75 0f                	jne    f0105e93 <memmove+0x5f>
f0105e84:	f6 c1 03             	test   $0x3,%cl
f0105e87:	75 0a                	jne    f0105e93 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105e89:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105e8c:	89 c7                	mov    %eax,%edi
f0105e8e:	fc                   	cld    
f0105e8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105e91:	eb 05                	jmp    f0105e98 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
f0105e93:	89 c7                	mov    %eax,%edi
f0105e95:	fc                   	cld    
f0105e96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105e98:	5e                   	pop    %esi
f0105e99:	5f                   	pop    %edi
f0105e9a:	5d                   	pop    %ebp
f0105e9b:	c3                   	ret    

f0105e9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105e9c:	55                   	push   %ebp
f0105e9d:	89 e5                	mov    %esp,%ebp
f0105e9f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105ea2:	8b 45 10             	mov    0x10(%ebp),%eax
f0105ea5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105ea9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105eac:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105eb0:	8b 45 08             	mov    0x8(%ebp),%eax
f0105eb3:	89 04 24             	mov    %eax,(%esp)
f0105eb6:	e8 79 ff ff ff       	call   f0105e34 <memmove>
}
f0105ebb:	c9                   	leave  
f0105ebc:	c3                   	ret    

f0105ebd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105ebd:	55                   	push   %ebp
f0105ebe:	89 e5                	mov    %esp,%ebp
f0105ec0:	56                   	push   %esi
f0105ec1:	53                   	push   %ebx
f0105ec2:	8b 55 08             	mov    0x8(%ebp),%edx
f0105ec5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105ec8:	89 d6                	mov    %edx,%esi
f0105eca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105ecd:	eb 1a                	jmp    f0105ee9 <memcmp+0x2c>
		if (*s1 != *s2)
f0105ecf:	0f b6 02             	movzbl (%edx),%eax
f0105ed2:	0f b6 19             	movzbl (%ecx),%ebx
f0105ed5:	38 d8                	cmp    %bl,%al
f0105ed7:	74 0a                	je     f0105ee3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105ed9:	0f b6 c0             	movzbl %al,%eax
f0105edc:	0f b6 db             	movzbl %bl,%ebx
f0105edf:	29 d8                	sub    %ebx,%eax
f0105ee1:	eb 0f                	jmp    f0105ef2 <memcmp+0x35>
		s1++, s2++;
f0105ee3:	83 c2 01             	add    $0x1,%edx
f0105ee6:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
f0105ee9:	39 f2                	cmp    %esi,%edx
f0105eeb:	75 e2                	jne    f0105ecf <memcmp+0x12>
	}

	return 0;
f0105eed:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105ef2:	5b                   	pop    %ebx
f0105ef3:	5e                   	pop    %esi
f0105ef4:	5d                   	pop    %ebp
f0105ef5:	c3                   	ret    

f0105ef6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105ef6:	55                   	push   %ebp
f0105ef7:	89 e5                	mov    %esp,%ebp
f0105ef9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105efc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105eff:	89 c2                	mov    %eax,%edx
f0105f01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105f04:	eb 07                	jmp    f0105f0d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105f06:	38 08                	cmp    %cl,(%eax)
f0105f08:	74 07                	je     f0105f11 <memfind+0x1b>
	for (; s < ends; s++)
f0105f0a:	83 c0 01             	add    $0x1,%eax
f0105f0d:	39 d0                	cmp    %edx,%eax
f0105f0f:	72 f5                	jb     f0105f06 <memfind+0x10>
			break;
	return (void *) s;
}
f0105f11:	5d                   	pop    %ebp
f0105f12:	c3                   	ret    

f0105f13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105f13:	55                   	push   %ebp
f0105f14:	89 e5                	mov    %esp,%ebp
f0105f16:	57                   	push   %edi
f0105f17:	56                   	push   %esi
f0105f18:	53                   	push   %ebx
f0105f19:	8b 55 08             	mov    0x8(%ebp),%edx
f0105f1c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105f1f:	eb 03                	jmp    f0105f24 <strtol+0x11>
		s++;
f0105f21:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f0105f24:	0f b6 0a             	movzbl (%edx),%ecx
f0105f27:	80 f9 09             	cmp    $0x9,%cl
f0105f2a:	74 f5                	je     f0105f21 <strtol+0xe>
f0105f2c:	80 f9 20             	cmp    $0x20,%cl
f0105f2f:	74 f0                	je     f0105f21 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0105f31:	80 f9 2b             	cmp    $0x2b,%cl
f0105f34:	75 0a                	jne    f0105f40 <strtol+0x2d>
		s++;
f0105f36:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0105f39:	bf 00 00 00 00       	mov    $0x0,%edi
f0105f3e:	eb 11                	jmp    f0105f51 <strtol+0x3e>
f0105f40:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
f0105f45:	80 f9 2d             	cmp    $0x2d,%cl
f0105f48:	75 07                	jne    f0105f51 <strtol+0x3e>
		s++, neg = 1;
f0105f4a:	8d 52 01             	lea    0x1(%edx),%edx
f0105f4d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105f51:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0105f56:	75 15                	jne    f0105f6d <strtol+0x5a>
f0105f58:	80 3a 30             	cmpb   $0x30,(%edx)
f0105f5b:	75 10                	jne    f0105f6d <strtol+0x5a>
f0105f5d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105f61:	75 0a                	jne    f0105f6d <strtol+0x5a>
		s += 2, base = 16;
f0105f63:	83 c2 02             	add    $0x2,%edx
f0105f66:	b8 10 00 00 00       	mov    $0x10,%eax
f0105f6b:	eb 10                	jmp    f0105f7d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f0105f6d:	85 c0                	test   %eax,%eax
f0105f6f:	75 0c                	jne    f0105f7d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105f71:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
f0105f73:	80 3a 30             	cmpb   $0x30,(%edx)
f0105f76:	75 05                	jne    f0105f7d <strtol+0x6a>
		s++, base = 8;
f0105f78:	83 c2 01             	add    $0x1,%edx
f0105f7b:	b0 08                	mov    $0x8,%al
		base = 10;
f0105f7d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105f82:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105f85:	0f b6 0a             	movzbl (%edx),%ecx
f0105f88:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0105f8b:	89 f0                	mov    %esi,%eax
f0105f8d:	3c 09                	cmp    $0x9,%al
f0105f8f:	77 08                	ja     f0105f99 <strtol+0x86>
			dig = *s - '0';
f0105f91:	0f be c9             	movsbl %cl,%ecx
f0105f94:	83 e9 30             	sub    $0x30,%ecx
f0105f97:	eb 20                	jmp    f0105fb9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0105f99:	8d 71 9f             	lea    -0x61(%ecx),%esi
f0105f9c:	89 f0                	mov    %esi,%eax
f0105f9e:	3c 19                	cmp    $0x19,%al
f0105fa0:	77 08                	ja     f0105faa <strtol+0x97>
			dig = *s - 'a' + 10;
f0105fa2:	0f be c9             	movsbl %cl,%ecx
f0105fa5:	83 e9 57             	sub    $0x57,%ecx
f0105fa8:	eb 0f                	jmp    f0105fb9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f0105faa:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0105fad:	89 f0                	mov    %esi,%eax
f0105faf:	3c 19                	cmp    $0x19,%al
f0105fb1:	77 16                	ja     f0105fc9 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0105fb3:	0f be c9             	movsbl %cl,%ecx
f0105fb6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0105fb9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0105fbc:	7d 0f                	jge    f0105fcd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f0105fbe:	83 c2 01             	add    $0x1,%edx
f0105fc1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0105fc5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0105fc7:	eb bc                	jmp    f0105f85 <strtol+0x72>
f0105fc9:	89 d8                	mov    %ebx,%eax
f0105fcb:	eb 02                	jmp    f0105fcf <strtol+0xbc>
f0105fcd:	89 d8                	mov    %ebx,%eax

	if (endptr)
f0105fcf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105fd3:	74 05                	je     f0105fda <strtol+0xc7>
		*endptr = (char *) s;
f0105fd5:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105fd8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0105fda:	f7 d8                	neg    %eax
f0105fdc:	85 ff                	test   %edi,%edi
f0105fde:	0f 44 c3             	cmove  %ebx,%eax
}
f0105fe1:	5b                   	pop    %ebx
f0105fe2:	5e                   	pop    %esi
f0105fe3:	5f                   	pop    %edi
f0105fe4:	5d                   	pop    %ebp
f0105fe5:	c3                   	ret    
f0105fe6:	66 90                	xchg   %ax,%ax

f0105fe8 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105fe8:	fa                   	cli    

	xorw    %ax, %ax
f0105fe9:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105feb:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105fed:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105fef:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105ff1:	0f 01 16             	lgdtl  (%esi)
f0105ff4:	74 70                	je     f0106066 <mpentry_end+0x4>
	movl    %cr0, %eax
f0105ff6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105ff9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105ffd:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106000:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0106006:	08 00                	or     %al,(%eax)

f0106008 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106008:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f010600c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010600e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106010:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0106012:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0106016:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106018:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010601a:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f010601f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0106022:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106025:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010602a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f010602d:	8b 25 84 0e 23 f0    	mov    0xf0230e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106033:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106038:	b8 e2 01 10 f0       	mov    $0xf01001e2,%eax
	call    *%eax
f010603d:	ff d0                	call   *%eax

f010603f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010603f:	eb fe                	jmp    f010603f <spin>
f0106041:	8d 76 00             	lea    0x0(%esi),%esi

f0106044 <gdt>:
	...
f010604c:	ff                   	(bad)  
f010604d:	ff 00                	incl   (%eax)
f010604f:	00 00                	add    %al,(%eax)
f0106051:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106058:	00                   	.byte 0x0
f0106059:	92                   	xchg   %eax,%edx
f010605a:	cf                   	iret   
	...

f010605c <gdtdesc>:
f010605c:	17                   	pop    %ss
f010605d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106062 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106062:	90                   	nop
f0106063:	66 90                	xchg   %ax,%ax
f0106065:	66 90                	xchg   %ax,%ax
f0106067:	66 90                	xchg   %ax,%ax
f0106069:	66 90                	xchg   %ax,%ax
f010606b:	66 90                	xchg   %ax,%ax
f010606d:	66 90                	xchg   %ax,%ax
f010606f:	90                   	nop

f0106070 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106070:	55                   	push   %ebp
f0106071:	89 e5                	mov    %esp,%ebp
f0106073:	56                   	push   %esi
f0106074:	53                   	push   %ebx
f0106075:	83 ec 10             	sub    $0x10,%esp
	if (PGNUM(pa) >= npages)
f0106078:	8b 0d 88 0e 23 f0    	mov    0xf0230e88,%ecx
f010607e:	89 c3                	mov    %eax,%ebx
f0106080:	c1 eb 0c             	shr    $0xc,%ebx
f0106083:	39 cb                	cmp    %ecx,%ebx
f0106085:	72 20                	jb     f01060a7 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106087:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010608b:	c7 44 24 08 44 6b 10 	movl   $0xf0106b44,0x8(%esp)
f0106092:	f0 
f0106093:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010609a:	00 
f010609b:	c7 04 24 c1 86 10 f0 	movl   $0xf01086c1,(%esp)
f01060a2:	e8 99 9f ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01060a7:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01060ad:	01 d0                	add    %edx,%eax
	if (PGNUM(pa) >= npages)
f01060af:	89 c2                	mov    %eax,%edx
f01060b1:	c1 ea 0c             	shr    $0xc,%edx
f01060b4:	39 d1                	cmp    %edx,%ecx
f01060b6:	77 20                	ja     f01060d8 <mpsearch1+0x68>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01060b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01060bc:	c7 44 24 08 44 6b 10 	movl   $0xf0106b44,0x8(%esp)
f01060c3:	f0 
f01060c4:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01060cb:	00 
f01060cc:	c7 04 24 c1 86 10 f0 	movl   $0xf01086c1,(%esp)
f01060d3:	e8 68 9f ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01060d8:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f01060de:	eb 36                	jmp    f0106116 <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01060e0:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01060e7:	00 
f01060e8:	c7 44 24 04 d1 86 10 	movl   $0xf01086d1,0x4(%esp)
f01060ef:	f0 
f01060f0:	89 1c 24             	mov    %ebx,(%esp)
f01060f3:	e8 c5 fd ff ff       	call   f0105ebd <memcmp>
f01060f8:	85 c0                	test   %eax,%eax
f01060fa:	75 17                	jne    f0106113 <mpsearch1+0xa3>
	for (i = 0; i < len; i++)
f01060fc:	ba 00 00 00 00       	mov    $0x0,%edx
		sum += ((uint8_t *)addr)[i];
f0106101:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0106105:	01 c8                	add    %ecx,%eax
	for (i = 0; i < len; i++)
f0106107:	83 c2 01             	add    $0x1,%edx
f010610a:	83 fa 10             	cmp    $0x10,%edx
f010610d:	75 f2                	jne    f0106101 <mpsearch1+0x91>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010610f:	84 c0                	test   %al,%al
f0106111:	74 0e                	je     f0106121 <mpsearch1+0xb1>
	for (; mp < end; mp++)
f0106113:	83 c3 10             	add    $0x10,%ebx
f0106116:	39 f3                	cmp    %esi,%ebx
f0106118:	72 c6                	jb     f01060e0 <mpsearch1+0x70>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010611a:	b8 00 00 00 00       	mov    $0x0,%eax
f010611f:	eb 02                	jmp    f0106123 <mpsearch1+0xb3>
f0106121:	89 d8                	mov    %ebx,%eax
}
f0106123:	83 c4 10             	add    $0x10,%esp
f0106126:	5b                   	pop    %ebx
f0106127:	5e                   	pop    %esi
f0106128:	5d                   	pop    %ebp
f0106129:	c3                   	ret    

f010612a <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010612a:	55                   	push   %ebp
f010612b:	89 e5                	mov    %esp,%ebp
f010612d:	57                   	push   %edi
f010612e:	56                   	push   %esi
f010612f:	53                   	push   %ebx
f0106130:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106133:	c7 05 c0 13 23 f0 20 	movl   $0xf0231020,0xf02313c0
f010613a:	10 23 f0 
	if (PGNUM(pa) >= npages)
f010613d:	83 3d 88 0e 23 f0 00 	cmpl   $0x0,0xf0230e88
f0106144:	75 24                	jne    f010616a <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106146:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f010614d:	00 
f010614e:	c7 44 24 08 44 6b 10 	movl   $0xf0106b44,0x8(%esp)
f0106155:	f0 
f0106156:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f010615d:	00 
f010615e:	c7 04 24 c1 86 10 f0 	movl   $0xf01086c1,(%esp)
f0106165:	e8 d6 9e ff ff       	call   f0100040 <_panic>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010616a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106171:	85 c0                	test   %eax,%eax
f0106173:	74 16                	je     f010618b <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f0106175:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0106178:	ba 00 04 00 00       	mov    $0x400,%edx
f010617d:	e8 ee fe ff ff       	call   f0106070 <mpsearch1>
f0106182:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106185:	85 c0                	test   %eax,%eax
f0106187:	75 3c                	jne    f01061c5 <mp_init+0x9b>
f0106189:	eb 20                	jmp    f01061ab <mp_init+0x81>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f010618b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106192:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106195:	2d 00 04 00 00       	sub    $0x400,%eax
f010619a:	ba 00 04 00 00       	mov    $0x400,%edx
f010619f:	e8 cc fe ff ff       	call   f0106070 <mpsearch1>
f01061a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01061a7:	85 c0                	test   %eax,%eax
f01061a9:	75 1a                	jne    f01061c5 <mp_init+0x9b>
	return mpsearch1(0xF0000, 0x10000);
f01061ab:	ba 00 00 01 00       	mov    $0x10000,%edx
f01061b0:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01061b5:	e8 b6 fe ff ff       	call   f0106070 <mpsearch1>
f01061ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f01061bd:	85 c0                	test   %eax,%eax
f01061bf:	0f 84 54 02 00 00    	je     f0106419 <mp_init+0x2ef>
	if (mp->physaddr == 0 || mp->type != 0) {
f01061c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01061c8:	8b 70 04             	mov    0x4(%eax),%esi
f01061cb:	85 f6                	test   %esi,%esi
f01061cd:	74 06                	je     f01061d5 <mp_init+0xab>
f01061cf:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01061d3:	74 11                	je     f01061e6 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f01061d5:	c7 04 24 34 85 10 f0 	movl   $0xf0108534,(%esp)
f01061dc:	e8 44 dd ff ff       	call   f0103f25 <cprintf>
f01061e1:	e9 33 02 00 00       	jmp    f0106419 <mp_init+0x2ef>
	if (PGNUM(pa) >= npages)
f01061e6:	89 f0                	mov    %esi,%eax
f01061e8:	c1 e8 0c             	shr    $0xc,%eax
f01061eb:	3b 05 88 0e 23 f0    	cmp    0xf0230e88,%eax
f01061f1:	72 20                	jb     f0106213 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01061f3:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01061f7:	c7 44 24 08 44 6b 10 	movl   $0xf0106b44,0x8(%esp)
f01061fe:	f0 
f01061ff:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106206:	00 
f0106207:	c7 04 24 c1 86 10 f0 	movl   $0xf01086c1,(%esp)
f010620e:	e8 2d 9e ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106213:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106219:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106220:	00 
f0106221:	c7 44 24 04 d6 86 10 	movl   $0xf01086d6,0x4(%esp)
f0106228:	f0 
f0106229:	89 1c 24             	mov    %ebx,(%esp)
f010622c:	e8 8c fc ff ff       	call   f0105ebd <memcmp>
f0106231:	85 c0                	test   %eax,%eax
f0106233:	74 11                	je     f0106246 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106235:	c7 04 24 64 85 10 f0 	movl   $0xf0108564,(%esp)
f010623c:	e8 e4 dc ff ff       	call   f0103f25 <cprintf>
f0106241:	e9 d3 01 00 00       	jmp    f0106419 <mp_init+0x2ef>
	if (sum(conf, conf->length) != 0) {
f0106246:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f010624a:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f010624e:	0f b7 f8             	movzwl %ax,%edi
	sum = 0;
f0106251:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106256:	b8 00 00 00 00       	mov    $0x0,%eax
f010625b:	eb 0d                	jmp    f010626a <mp_init+0x140>
		sum += ((uint8_t *)addr)[i];
f010625d:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0106264:	f0 
f0106265:	01 ca                	add    %ecx,%edx
	for (i = 0; i < len; i++)
f0106267:	83 c0 01             	add    $0x1,%eax
f010626a:	39 c7                	cmp    %eax,%edi
f010626c:	7f ef                	jg     f010625d <mp_init+0x133>
	if (sum(conf, conf->length) != 0) {
f010626e:	84 d2                	test   %dl,%dl
f0106270:	74 11                	je     f0106283 <mp_init+0x159>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106272:	c7 04 24 98 85 10 f0 	movl   $0xf0108598,(%esp)
f0106279:	e8 a7 dc ff ff       	call   f0103f25 <cprintf>
f010627e:	e9 96 01 00 00       	jmp    f0106419 <mp_init+0x2ef>
	if (conf->version != 1 && conf->version != 4) {
f0106283:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0106287:	3c 04                	cmp    $0x4,%al
f0106289:	74 1f                	je     f01062aa <mp_init+0x180>
f010628b:	3c 01                	cmp    $0x1,%al
f010628d:	8d 76 00             	lea    0x0(%esi),%esi
f0106290:	74 18                	je     f01062aa <mp_init+0x180>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106292:	0f b6 c0             	movzbl %al,%eax
f0106295:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106299:	c7 04 24 bc 85 10 f0 	movl   $0xf01085bc,(%esp)
f01062a0:	e8 80 dc ff ff       	call   f0103f25 <cprintf>
f01062a5:	e9 6f 01 00 00       	jmp    f0106419 <mp_init+0x2ef>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01062aa:	0f b7 73 28          	movzwl 0x28(%ebx),%esi
f01062ae:	0f b7 7d e2          	movzwl -0x1e(%ebp),%edi
f01062b2:	01 df                	add    %ebx,%edi
	sum = 0;
f01062b4:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01062b9:	b8 00 00 00 00       	mov    $0x0,%eax
f01062be:	eb 09                	jmp    f01062c9 <mp_init+0x19f>
		sum += ((uint8_t *)addr)[i];
f01062c0:	0f b6 0c 07          	movzbl (%edi,%eax,1),%ecx
f01062c4:	01 ca                	add    %ecx,%edx
	for (i = 0; i < len; i++)
f01062c6:	83 c0 01             	add    $0x1,%eax
f01062c9:	39 c6                	cmp    %eax,%esi
f01062cb:	7f f3                	jg     f01062c0 <mp_init+0x196>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01062cd:	02 53 2a             	add    0x2a(%ebx),%dl
f01062d0:	84 d2                	test   %dl,%dl
f01062d2:	74 11                	je     f01062e5 <mp_init+0x1bb>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01062d4:	c7 04 24 dc 85 10 f0 	movl   $0xf01085dc,(%esp)
f01062db:	e8 45 dc ff ff       	call   f0103f25 <cprintf>
f01062e0:	e9 34 01 00 00       	jmp    f0106419 <mp_init+0x2ef>
	if ((conf = mpconfig(&mp)) == 0)
f01062e5:	85 db                	test   %ebx,%ebx
f01062e7:	0f 84 2c 01 00 00    	je     f0106419 <mp_init+0x2ef>
		return;
	ismp = 1;
f01062ed:	c7 05 00 10 23 f0 01 	movl   $0x1,0xf0231000
f01062f4:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01062f7:	8b 43 24             	mov    0x24(%ebx),%eax
f01062fa:	a3 00 20 27 f0       	mov    %eax,0xf0272000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01062ff:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0106302:	be 00 00 00 00       	mov    $0x0,%esi
f0106307:	e9 86 00 00 00       	jmp    f0106392 <mp_init+0x268>
		switch (*p) {
f010630c:	0f b6 07             	movzbl (%edi),%eax
f010630f:	84 c0                	test   %al,%al
f0106311:	74 06                	je     f0106319 <mp_init+0x1ef>
f0106313:	3c 04                	cmp    $0x4,%al
f0106315:	77 57                	ja     f010636e <mp_init+0x244>
f0106317:	eb 50                	jmp    f0106369 <mp_init+0x23f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106319:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f010631d:	8d 76 00             	lea    0x0(%esi),%esi
f0106320:	74 11                	je     f0106333 <mp_init+0x209>
				bootcpu = &cpus[ncpu];
f0106322:	6b 05 c4 13 23 f0 74 	imul   $0x74,0xf02313c4,%eax
f0106329:	05 20 10 23 f0       	add    $0xf0231020,%eax
f010632e:	a3 c0 13 23 f0       	mov    %eax,0xf02313c0
			if (ncpu < NCPU) {
f0106333:	a1 c4 13 23 f0       	mov    0xf02313c4,%eax
f0106338:	83 f8 07             	cmp    $0x7,%eax
f010633b:	7f 13                	jg     f0106350 <mp_init+0x226>
				cpus[ncpu].cpu_id = ncpu;
f010633d:	6b d0 74             	imul   $0x74,%eax,%edx
f0106340:	88 82 20 10 23 f0    	mov    %al,-0xfdcefe0(%edx)
				ncpu++;
f0106346:	83 c0 01             	add    $0x1,%eax
f0106349:	a3 c4 13 23 f0       	mov    %eax,0xf02313c4
f010634e:	eb 14                	jmp    f0106364 <mp_init+0x23a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106350:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0106354:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106358:	c7 04 24 0c 86 10 f0 	movl   $0xf010860c,(%esp)
f010635f:	e8 c1 db ff ff       	call   f0103f25 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106364:	83 c7 14             	add    $0x14,%edi
			continue;
f0106367:	eb 26                	jmp    f010638f <mp_init+0x265>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106369:	83 c7 08             	add    $0x8,%edi
			continue;
f010636c:	eb 21                	jmp    f010638f <mp_init+0x265>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010636e:	0f b6 c0             	movzbl %al,%eax
f0106371:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106375:	c7 04 24 34 86 10 f0 	movl   $0xf0108634,(%esp)
f010637c:	e8 a4 db ff ff       	call   f0103f25 <cprintf>
			ismp = 0;
f0106381:	c7 05 00 10 23 f0 00 	movl   $0x0,0xf0231000
f0106388:	00 00 00 
			i = conf->entry;
f010638b:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010638f:	83 c6 01             	add    $0x1,%esi
f0106392:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0106396:	39 c6                	cmp    %eax,%esi
f0106398:	0f 82 6e ff ff ff    	jb     f010630c <mp_init+0x1e2>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010639e:	a1 c0 13 23 f0       	mov    0xf02313c0,%eax
f01063a3:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01063aa:	83 3d 00 10 23 f0 00 	cmpl   $0x0,0xf0231000
f01063b1:	75 22                	jne    f01063d5 <mp_init+0x2ab>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01063b3:	c7 05 c4 13 23 f0 01 	movl   $0x1,0xf02313c4
f01063ba:	00 00 00 
		lapicaddr = 0;
f01063bd:	c7 05 00 20 27 f0 00 	movl   $0x0,0xf0272000
f01063c4:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01063c7:	c7 04 24 54 86 10 f0 	movl   $0xf0108654,(%esp)
f01063ce:	e8 52 db ff ff       	call   f0103f25 <cprintf>
		return;
f01063d3:	eb 44                	jmp    f0106419 <mp_init+0x2ef>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01063d5:	8b 15 c4 13 23 f0    	mov    0xf02313c4,%edx
f01063db:	89 54 24 08          	mov    %edx,0x8(%esp)
f01063df:	0f b6 00             	movzbl (%eax),%eax
f01063e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01063e6:	c7 04 24 db 86 10 f0 	movl   $0xf01086db,(%esp)
f01063ed:	e8 33 db ff ff       	call   f0103f25 <cprintf>

	if (mp->imcrp) {
f01063f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01063f5:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01063f9:	74 1e                	je     f0106419 <mp_init+0x2ef>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01063fb:	c7 04 24 80 86 10 f0 	movl   $0xf0108680,(%esp)
f0106402:	e8 1e db ff ff       	call   f0103f25 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106407:	ba 22 00 00 00       	mov    $0x22,%edx
f010640c:	b8 70 00 00 00       	mov    $0x70,%eax
f0106411:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106412:	b2 23                	mov    $0x23,%dl
f0106414:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106415:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106418:	ee                   	out    %al,(%dx)
	}
}
f0106419:	83 c4 2c             	add    $0x2c,%esp
f010641c:	5b                   	pop    %ebx
f010641d:	5e                   	pop    %esi
f010641e:	5f                   	pop    %edi
f010641f:	5d                   	pop    %ebp
f0106420:	c3                   	ret    

f0106421 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106421:	55                   	push   %ebp
f0106422:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106424:	8b 0d 04 20 27 f0    	mov    0xf0272004,%ecx
f010642a:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010642d:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010642f:	a1 04 20 27 f0       	mov    0xf0272004,%eax
f0106434:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106437:	5d                   	pop    %ebp
f0106438:	c3                   	ret    

f0106439 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106439:	55                   	push   %ebp
f010643a:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010643c:	a1 04 20 27 f0       	mov    0xf0272004,%eax
f0106441:	85 c0                	test   %eax,%eax
f0106443:	74 08                	je     f010644d <cpunum+0x14>
		return lapic[ID] >> 24;
f0106445:	8b 40 20             	mov    0x20(%eax),%eax
f0106448:	c1 e8 18             	shr    $0x18,%eax
f010644b:	eb 05                	jmp    f0106452 <cpunum+0x19>
	return 0;
f010644d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106452:	5d                   	pop    %ebp
f0106453:	c3                   	ret    

f0106454 <lapic_init>:
	if (!lapicaddr)
f0106454:	a1 00 20 27 f0       	mov    0xf0272000,%eax
f0106459:	85 c0                	test   %eax,%eax
f010645b:	0f 84 23 01 00 00    	je     f0106584 <lapic_init+0x130>
{
f0106461:	55                   	push   %ebp
f0106462:	89 e5                	mov    %esp,%ebp
f0106464:	83 ec 18             	sub    $0x18,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0106467:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010646e:	00 
f010646f:	89 04 24             	mov    %eax,(%esp)
f0106472:	e8 23 b0 ff ff       	call   f010149a <mmio_map_region>
f0106477:	a3 04 20 27 f0       	mov    %eax,0xf0272004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010647c:	ba 27 01 00 00       	mov    $0x127,%edx
f0106481:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106486:	e8 96 ff ff ff       	call   f0106421 <lapicw>
	lapicw(TDCR, X1);
f010648b:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106490:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106495:	e8 87 ff ff ff       	call   f0106421 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010649a:	ba 20 00 02 00       	mov    $0x20020,%edx
f010649f:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01064a4:	e8 78 ff ff ff       	call   f0106421 <lapicw>
	lapicw(TICR, 10000000); 
f01064a9:	ba 80 96 98 00       	mov    $0x989680,%edx
f01064ae:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01064b3:	e8 69 ff ff ff       	call   f0106421 <lapicw>
	if (thiscpu != bootcpu)
f01064b8:	e8 7c ff ff ff       	call   f0106439 <cpunum>
f01064bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01064c0:	05 20 10 23 f0       	add    $0xf0231020,%eax
f01064c5:	39 05 c0 13 23 f0    	cmp    %eax,0xf02313c0
f01064cb:	74 0f                	je     f01064dc <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f01064cd:	ba 00 00 01 00       	mov    $0x10000,%edx
f01064d2:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01064d7:	e8 45 ff ff ff       	call   f0106421 <lapicw>
	lapicw(LINT1, MASKED);
f01064dc:	ba 00 00 01 00       	mov    $0x10000,%edx
f01064e1:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01064e6:	e8 36 ff ff ff       	call   f0106421 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01064eb:	a1 04 20 27 f0       	mov    0xf0272004,%eax
f01064f0:	8b 40 30             	mov    0x30(%eax),%eax
f01064f3:	c1 e8 10             	shr    $0x10,%eax
f01064f6:	3c 03                	cmp    $0x3,%al
f01064f8:	76 0f                	jbe    f0106509 <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f01064fa:	ba 00 00 01 00       	mov    $0x10000,%edx
f01064ff:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106504:	e8 18 ff ff ff       	call   f0106421 <lapicw>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106509:	ba 33 00 00 00       	mov    $0x33,%edx
f010650e:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106513:	e8 09 ff ff ff       	call   f0106421 <lapicw>
	lapicw(ESR, 0);
f0106518:	ba 00 00 00 00       	mov    $0x0,%edx
f010651d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106522:	e8 fa fe ff ff       	call   f0106421 <lapicw>
	lapicw(ESR, 0);
f0106527:	ba 00 00 00 00       	mov    $0x0,%edx
f010652c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106531:	e8 eb fe ff ff       	call   f0106421 <lapicw>
	lapicw(EOI, 0);
f0106536:	ba 00 00 00 00       	mov    $0x0,%edx
f010653b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106540:	e8 dc fe ff ff       	call   f0106421 <lapicw>
	lapicw(ICRHI, 0);
f0106545:	ba 00 00 00 00       	mov    $0x0,%edx
f010654a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010654f:	e8 cd fe ff ff       	call   f0106421 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106554:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106559:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010655e:	e8 be fe ff ff       	call   f0106421 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106563:	8b 15 04 20 27 f0    	mov    0xf0272004,%edx
f0106569:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010656f:	f6 c4 10             	test   $0x10,%ah
f0106572:	75 f5                	jne    f0106569 <lapic_init+0x115>
	lapicw(TPR, 0);
f0106574:	ba 00 00 00 00       	mov    $0x0,%edx
f0106579:	b8 20 00 00 00       	mov    $0x20,%eax
f010657e:	e8 9e fe ff ff       	call   f0106421 <lapicw>
}
f0106583:	c9                   	leave  
f0106584:	f3 c3                	repz ret 

f0106586 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106586:	83 3d 04 20 27 f0 00 	cmpl   $0x0,0xf0272004
f010658d:	74 13                	je     f01065a2 <lapic_eoi+0x1c>
{
f010658f:	55                   	push   %ebp
f0106590:	89 e5                	mov    %esp,%ebp
		lapicw(EOI, 0);
f0106592:	ba 00 00 00 00       	mov    $0x0,%edx
f0106597:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010659c:	e8 80 fe ff ff       	call   f0106421 <lapicw>
}
f01065a1:	5d                   	pop    %ebp
f01065a2:	f3 c3                	repz ret 

f01065a4 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01065a4:	55                   	push   %ebp
f01065a5:	89 e5                	mov    %esp,%ebp
f01065a7:	56                   	push   %esi
f01065a8:	53                   	push   %ebx
f01065a9:	83 ec 10             	sub    $0x10,%esp
f01065ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01065af:	8b 75 0c             	mov    0xc(%ebp),%esi
f01065b2:	ba 70 00 00 00       	mov    $0x70,%edx
f01065b7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01065bc:	ee                   	out    %al,(%dx)
f01065bd:	b2 71                	mov    $0x71,%dl
f01065bf:	b8 0a 00 00 00       	mov    $0xa,%eax
f01065c4:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f01065c5:	83 3d 88 0e 23 f0 00 	cmpl   $0x0,0xf0230e88
f01065cc:	75 24                	jne    f01065f2 <lapic_startap+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01065ce:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f01065d5:	00 
f01065d6:	c7 44 24 08 44 6b 10 	movl   $0xf0106b44,0x8(%esp)
f01065dd:	f0 
f01065de:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f01065e5:	00 
f01065e6:	c7 04 24 f8 86 10 f0 	movl   $0xf01086f8,(%esp)
f01065ed:	e8 4e 9a ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01065f2:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01065f9:	00 00 
	wrv[1] = addr >> 4;
f01065fb:	89 f0                	mov    %esi,%eax
f01065fd:	c1 e8 04             	shr    $0x4,%eax
f0106600:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106606:	c1 e3 18             	shl    $0x18,%ebx
f0106609:	89 da                	mov    %ebx,%edx
f010660b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106610:	e8 0c fe ff ff       	call   f0106421 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106615:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010661a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010661f:	e8 fd fd ff ff       	call   f0106421 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106624:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106629:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010662e:	e8 ee fd ff ff       	call   f0106421 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106633:	c1 ee 0c             	shr    $0xc,%esi
f0106636:	81 ce 00 06 00 00    	or     $0x600,%esi
		lapicw(ICRHI, apicid << 24);
f010663c:	89 da                	mov    %ebx,%edx
f010663e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106643:	e8 d9 fd ff ff       	call   f0106421 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106648:	89 f2                	mov    %esi,%edx
f010664a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010664f:	e8 cd fd ff ff       	call   f0106421 <lapicw>
		lapicw(ICRHI, apicid << 24);
f0106654:	89 da                	mov    %ebx,%edx
f0106656:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010665b:	e8 c1 fd ff ff       	call   f0106421 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106660:	89 f2                	mov    %esi,%edx
f0106662:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106667:	e8 b5 fd ff ff       	call   f0106421 <lapicw>
		microdelay(200);
	}
}
f010666c:	83 c4 10             	add    $0x10,%esp
f010666f:	5b                   	pop    %ebx
f0106670:	5e                   	pop    %esi
f0106671:	5d                   	pop    %ebp
f0106672:	c3                   	ret    

f0106673 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106673:	55                   	push   %ebp
f0106674:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106676:	8b 55 08             	mov    0x8(%ebp),%edx
f0106679:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f010667f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106684:	e8 98 fd ff ff       	call   f0106421 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106689:	8b 15 04 20 27 f0    	mov    0xf0272004,%edx
f010668f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106695:	f6 c4 10             	test   $0x10,%ah
f0106698:	75 f5                	jne    f010668f <lapic_ipi+0x1c>
		;
}
f010669a:	5d                   	pop    %ebp
f010669b:	c3                   	ret    

f010669c <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010669c:	55                   	push   %ebp
f010669d:	89 e5                	mov    %esp,%ebp
f010669f:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01066a2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01066a8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01066ab:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01066ae:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01066b5:	5d                   	pop    %ebp
f01066b6:	c3                   	ret    

f01066b7 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01066b7:	55                   	push   %ebp
f01066b8:	89 e5                	mov    %esp,%ebp
f01066ba:	56                   	push   %esi
f01066bb:	53                   	push   %ebx
f01066bc:	83 ec 20             	sub    $0x20,%esp
f01066bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f01066c2:	83 3b 00             	cmpl   $0x0,(%ebx)
f01066c5:	75 07                	jne    f01066ce <spin_lock+0x17>
	asm volatile("lock; xchgl %0, %1"
f01066c7:	ba 01 00 00 00       	mov    $0x1,%edx
f01066cc:	eb 42                	jmp    f0106710 <spin_lock+0x59>
f01066ce:	8b 73 08             	mov    0x8(%ebx),%esi
f01066d1:	e8 63 fd ff ff       	call   f0106439 <cpunum>
f01066d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01066d9:	05 20 10 23 f0       	add    $0xf0231020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01066de:	39 c6                	cmp    %eax,%esi
f01066e0:	75 e5                	jne    f01066c7 <spin_lock+0x10>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01066e2:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01066e5:	e8 4f fd ff ff       	call   f0106439 <cpunum>
f01066ea:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f01066ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01066f2:	c7 44 24 08 08 87 10 	movl   $0xf0108708,0x8(%esp)
f01066f9:	f0 
f01066fa:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106701:	00 
f0106702:	c7 04 24 6c 87 10 f0 	movl   $0xf010876c,(%esp)
f0106709:	e8 32 99 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010670e:	f3 90                	pause  
f0106710:	89 d0                	mov    %edx,%eax
f0106712:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0106715:	85 c0                	test   %eax,%eax
f0106717:	75 f5                	jne    f010670e <spin_lock+0x57>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106719:	e8 1b fd ff ff       	call   f0106439 <cpunum>
f010671e:	6b c0 74             	imul   $0x74,%eax,%eax
f0106721:	05 20 10 23 f0       	add    $0xf0231020,%eax
f0106726:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106729:	83 c3 0c             	add    $0xc,%ebx
	ebp = (uint32_t *)read_ebp();
f010672c:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f010672e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106733:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106739:	76 12                	jbe    f010674d <spin_lock+0x96>
		pcs[i] = ebp[1];          // saved %eip
f010673b:	8b 4a 04             	mov    0x4(%edx),%ecx
f010673e:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106741:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0106743:	83 c0 01             	add    $0x1,%eax
f0106746:	83 f8 0a             	cmp    $0xa,%eax
f0106749:	75 e8                	jne    f0106733 <spin_lock+0x7c>
f010674b:	eb 0f                	jmp    f010675c <spin_lock+0xa5>
		pcs[i] = 0;
f010674d:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
	for (; i < 10; i++)
f0106754:	83 c0 01             	add    $0x1,%eax
f0106757:	83 f8 09             	cmp    $0x9,%eax
f010675a:	7e f1                	jle    f010674d <spin_lock+0x96>
#endif
}
f010675c:	83 c4 20             	add    $0x20,%esp
f010675f:	5b                   	pop    %ebx
f0106760:	5e                   	pop    %esi
f0106761:	5d                   	pop    %ebp
f0106762:	c3                   	ret    

f0106763 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106763:	55                   	push   %ebp
f0106764:	89 e5                	mov    %esp,%ebp
f0106766:	57                   	push   %edi
f0106767:	56                   	push   %esi
f0106768:	53                   	push   %ebx
f0106769:	83 ec 6c             	sub    $0x6c,%esp
f010676c:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f010676f:	83 3e 00             	cmpl   $0x0,(%esi)
f0106772:	74 18                	je     f010678c <spin_unlock+0x29>
f0106774:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106777:	e8 bd fc ff ff       	call   f0106439 <cpunum>
f010677c:	6b c0 74             	imul   $0x74,%eax,%eax
f010677f:	05 20 10 23 f0       	add    $0xf0231020,%eax
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106784:	39 c3                	cmp    %eax,%ebx
f0106786:	0f 84 ce 00 00 00    	je     f010685a <spin_unlock+0xf7>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010678c:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106793:	00 
f0106794:	8d 46 0c             	lea    0xc(%esi),%eax
f0106797:	89 44 24 04          	mov    %eax,0x4(%esp)
f010679b:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f010679e:	89 1c 24             	mov    %ebx,(%esp)
f01067a1:	e8 8e f6 ff ff       	call   f0105e34 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01067a6:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01067a9:	0f b6 38             	movzbl (%eax),%edi
f01067ac:	8b 76 04             	mov    0x4(%esi),%esi
f01067af:	e8 85 fc ff ff       	call   f0106439 <cpunum>
f01067b4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01067b8:	89 74 24 08          	mov    %esi,0x8(%esp)
f01067bc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01067c0:	c7 04 24 34 87 10 f0 	movl   $0xf0108734,(%esp)
f01067c7:	e8 59 d7 ff ff       	call   f0103f25 <cprintf>
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01067cc:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01067cf:	eb 65                	jmp    f0106836 <spin_unlock+0xd3>
f01067d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01067d5:	89 04 24             	mov    %eax,(%esp)
f01067d8:	e8 bd ea ff ff       	call   f010529a <debuginfo_eip>
f01067dd:	85 c0                	test   %eax,%eax
f01067df:	78 39                	js     f010681a <spin_unlock+0xb7>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01067e1:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01067e3:	89 c2                	mov    %eax,%edx
f01067e5:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01067e8:	89 54 24 18          	mov    %edx,0x18(%esp)
f01067ec:	8b 55 b0             	mov    -0x50(%ebp),%edx
f01067ef:	89 54 24 14          	mov    %edx,0x14(%esp)
f01067f3:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f01067f6:	89 54 24 10          	mov    %edx,0x10(%esp)
f01067fa:	8b 55 ac             	mov    -0x54(%ebp),%edx
f01067fd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106801:	8b 55 a8             	mov    -0x58(%ebp),%edx
f0106804:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106808:	89 44 24 04          	mov    %eax,0x4(%esp)
f010680c:	c7 04 24 7c 87 10 f0 	movl   $0xf010877c,(%esp)
f0106813:	e8 0d d7 ff ff       	call   f0103f25 <cprintf>
f0106818:	eb 12                	jmp    f010682c <spin_unlock+0xc9>
			else
				cprintf("  %08x\n", pcs[i]);
f010681a:	8b 06                	mov    (%esi),%eax
f010681c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106820:	c7 04 24 93 87 10 f0 	movl   $0xf0108793,(%esp)
f0106827:	e8 f9 d6 ff ff       	call   f0103f25 <cprintf>
f010682c:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f010682f:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106832:	39 c3                	cmp    %eax,%ebx
f0106834:	74 08                	je     f010683e <spin_unlock+0xdb>
f0106836:	89 de                	mov    %ebx,%esi
f0106838:	8b 03                	mov    (%ebx),%eax
f010683a:	85 c0                	test   %eax,%eax
f010683c:	75 93                	jne    f01067d1 <spin_unlock+0x6e>
		}
		panic("spin_unlock");
f010683e:	c7 44 24 08 9b 87 10 	movl   $0xf010879b,0x8(%esp)
f0106845:	f0 
f0106846:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f010684d:	00 
f010684e:	c7 04 24 6c 87 10 f0 	movl   $0xf010876c,(%esp)
f0106855:	e8 e6 97 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f010685a:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106861:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
f0106868:	b8 00 00 00 00       	mov    $0x0,%eax
f010686d:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106870:	83 c4 6c             	add    $0x6c,%esp
f0106873:	5b                   	pop    %ebx
f0106874:	5e                   	pop    %esi
f0106875:	5f                   	pop    %edi
f0106876:	5d                   	pop    %ebp
f0106877:	c3                   	ret    
f0106878:	66 90                	xchg   %ax,%ax
f010687a:	66 90                	xchg   %ax,%ax
f010687c:	66 90                	xchg   %ax,%ax
f010687e:	66 90                	xchg   %ax,%ax

f0106880 <__udivdi3>:
f0106880:	55                   	push   %ebp
f0106881:	57                   	push   %edi
f0106882:	56                   	push   %esi
f0106883:	83 ec 0c             	sub    $0xc,%esp
f0106886:	8b 44 24 28          	mov    0x28(%esp),%eax
f010688a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f010688e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0106892:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0106896:	85 c0                	test   %eax,%eax
f0106898:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010689c:	89 ea                	mov    %ebp,%edx
f010689e:	89 0c 24             	mov    %ecx,(%esp)
f01068a1:	75 2d                	jne    f01068d0 <__udivdi3+0x50>
f01068a3:	39 e9                	cmp    %ebp,%ecx
f01068a5:	77 61                	ja     f0106908 <__udivdi3+0x88>
f01068a7:	85 c9                	test   %ecx,%ecx
f01068a9:	89 ce                	mov    %ecx,%esi
f01068ab:	75 0b                	jne    f01068b8 <__udivdi3+0x38>
f01068ad:	b8 01 00 00 00       	mov    $0x1,%eax
f01068b2:	31 d2                	xor    %edx,%edx
f01068b4:	f7 f1                	div    %ecx
f01068b6:	89 c6                	mov    %eax,%esi
f01068b8:	31 d2                	xor    %edx,%edx
f01068ba:	89 e8                	mov    %ebp,%eax
f01068bc:	f7 f6                	div    %esi
f01068be:	89 c5                	mov    %eax,%ebp
f01068c0:	89 f8                	mov    %edi,%eax
f01068c2:	f7 f6                	div    %esi
f01068c4:	89 ea                	mov    %ebp,%edx
f01068c6:	83 c4 0c             	add    $0xc,%esp
f01068c9:	5e                   	pop    %esi
f01068ca:	5f                   	pop    %edi
f01068cb:	5d                   	pop    %ebp
f01068cc:	c3                   	ret    
f01068cd:	8d 76 00             	lea    0x0(%esi),%esi
f01068d0:	39 e8                	cmp    %ebp,%eax
f01068d2:	77 24                	ja     f01068f8 <__udivdi3+0x78>
f01068d4:	0f bd e8             	bsr    %eax,%ebp
f01068d7:	83 f5 1f             	xor    $0x1f,%ebp
f01068da:	75 3c                	jne    f0106918 <__udivdi3+0x98>
f01068dc:	8b 74 24 04          	mov    0x4(%esp),%esi
f01068e0:	39 34 24             	cmp    %esi,(%esp)
f01068e3:	0f 86 9f 00 00 00    	jbe    f0106988 <__udivdi3+0x108>
f01068e9:	39 d0                	cmp    %edx,%eax
f01068eb:	0f 82 97 00 00 00    	jb     f0106988 <__udivdi3+0x108>
f01068f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01068f8:	31 d2                	xor    %edx,%edx
f01068fa:	31 c0                	xor    %eax,%eax
f01068fc:	83 c4 0c             	add    $0xc,%esp
f01068ff:	5e                   	pop    %esi
f0106900:	5f                   	pop    %edi
f0106901:	5d                   	pop    %ebp
f0106902:	c3                   	ret    
f0106903:	90                   	nop
f0106904:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106908:	89 f8                	mov    %edi,%eax
f010690a:	f7 f1                	div    %ecx
f010690c:	31 d2                	xor    %edx,%edx
f010690e:	83 c4 0c             	add    $0xc,%esp
f0106911:	5e                   	pop    %esi
f0106912:	5f                   	pop    %edi
f0106913:	5d                   	pop    %ebp
f0106914:	c3                   	ret    
f0106915:	8d 76 00             	lea    0x0(%esi),%esi
f0106918:	89 e9                	mov    %ebp,%ecx
f010691a:	8b 3c 24             	mov    (%esp),%edi
f010691d:	d3 e0                	shl    %cl,%eax
f010691f:	89 c6                	mov    %eax,%esi
f0106921:	b8 20 00 00 00       	mov    $0x20,%eax
f0106926:	29 e8                	sub    %ebp,%eax
f0106928:	89 c1                	mov    %eax,%ecx
f010692a:	d3 ef                	shr    %cl,%edi
f010692c:	89 e9                	mov    %ebp,%ecx
f010692e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106932:	8b 3c 24             	mov    (%esp),%edi
f0106935:	09 74 24 08          	or     %esi,0x8(%esp)
f0106939:	89 d6                	mov    %edx,%esi
f010693b:	d3 e7                	shl    %cl,%edi
f010693d:	89 c1                	mov    %eax,%ecx
f010693f:	89 3c 24             	mov    %edi,(%esp)
f0106942:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106946:	d3 ee                	shr    %cl,%esi
f0106948:	89 e9                	mov    %ebp,%ecx
f010694a:	d3 e2                	shl    %cl,%edx
f010694c:	89 c1                	mov    %eax,%ecx
f010694e:	d3 ef                	shr    %cl,%edi
f0106950:	09 d7                	or     %edx,%edi
f0106952:	89 f2                	mov    %esi,%edx
f0106954:	89 f8                	mov    %edi,%eax
f0106956:	f7 74 24 08          	divl   0x8(%esp)
f010695a:	89 d6                	mov    %edx,%esi
f010695c:	89 c7                	mov    %eax,%edi
f010695e:	f7 24 24             	mull   (%esp)
f0106961:	39 d6                	cmp    %edx,%esi
f0106963:	89 14 24             	mov    %edx,(%esp)
f0106966:	72 30                	jb     f0106998 <__udivdi3+0x118>
f0106968:	8b 54 24 04          	mov    0x4(%esp),%edx
f010696c:	89 e9                	mov    %ebp,%ecx
f010696e:	d3 e2                	shl    %cl,%edx
f0106970:	39 c2                	cmp    %eax,%edx
f0106972:	73 05                	jae    f0106979 <__udivdi3+0xf9>
f0106974:	3b 34 24             	cmp    (%esp),%esi
f0106977:	74 1f                	je     f0106998 <__udivdi3+0x118>
f0106979:	89 f8                	mov    %edi,%eax
f010697b:	31 d2                	xor    %edx,%edx
f010697d:	e9 7a ff ff ff       	jmp    f01068fc <__udivdi3+0x7c>
f0106982:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106988:	31 d2                	xor    %edx,%edx
f010698a:	b8 01 00 00 00       	mov    $0x1,%eax
f010698f:	e9 68 ff ff ff       	jmp    f01068fc <__udivdi3+0x7c>
f0106994:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106998:	8d 47 ff             	lea    -0x1(%edi),%eax
f010699b:	31 d2                	xor    %edx,%edx
f010699d:	83 c4 0c             	add    $0xc,%esp
f01069a0:	5e                   	pop    %esi
f01069a1:	5f                   	pop    %edi
f01069a2:	5d                   	pop    %ebp
f01069a3:	c3                   	ret    
f01069a4:	66 90                	xchg   %ax,%ax
f01069a6:	66 90                	xchg   %ax,%ax
f01069a8:	66 90                	xchg   %ax,%ax
f01069aa:	66 90                	xchg   %ax,%ax
f01069ac:	66 90                	xchg   %ax,%ax
f01069ae:	66 90                	xchg   %ax,%ax

f01069b0 <__umoddi3>:
f01069b0:	55                   	push   %ebp
f01069b1:	57                   	push   %edi
f01069b2:	56                   	push   %esi
f01069b3:	83 ec 14             	sub    $0x14,%esp
f01069b6:	8b 44 24 28          	mov    0x28(%esp),%eax
f01069ba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f01069be:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f01069c2:	89 c7                	mov    %eax,%edi
f01069c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069c8:	8b 44 24 30          	mov    0x30(%esp),%eax
f01069cc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01069d0:	89 34 24             	mov    %esi,(%esp)
f01069d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01069d7:	85 c0                	test   %eax,%eax
f01069d9:	89 c2                	mov    %eax,%edx
f01069db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01069df:	75 17                	jne    f01069f8 <__umoddi3+0x48>
f01069e1:	39 fe                	cmp    %edi,%esi
f01069e3:	76 4b                	jbe    f0106a30 <__umoddi3+0x80>
f01069e5:	89 c8                	mov    %ecx,%eax
f01069e7:	89 fa                	mov    %edi,%edx
f01069e9:	f7 f6                	div    %esi
f01069eb:	89 d0                	mov    %edx,%eax
f01069ed:	31 d2                	xor    %edx,%edx
f01069ef:	83 c4 14             	add    $0x14,%esp
f01069f2:	5e                   	pop    %esi
f01069f3:	5f                   	pop    %edi
f01069f4:	5d                   	pop    %ebp
f01069f5:	c3                   	ret    
f01069f6:	66 90                	xchg   %ax,%ax
f01069f8:	39 f8                	cmp    %edi,%eax
f01069fa:	77 54                	ja     f0106a50 <__umoddi3+0xa0>
f01069fc:	0f bd e8             	bsr    %eax,%ebp
f01069ff:	83 f5 1f             	xor    $0x1f,%ebp
f0106a02:	75 5c                	jne    f0106a60 <__umoddi3+0xb0>
f0106a04:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0106a08:	39 3c 24             	cmp    %edi,(%esp)
f0106a0b:	0f 87 e7 00 00 00    	ja     f0106af8 <__umoddi3+0x148>
f0106a11:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106a15:	29 f1                	sub    %esi,%ecx
f0106a17:	19 c7                	sbb    %eax,%edi
f0106a19:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106a1d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106a21:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106a25:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106a29:	83 c4 14             	add    $0x14,%esp
f0106a2c:	5e                   	pop    %esi
f0106a2d:	5f                   	pop    %edi
f0106a2e:	5d                   	pop    %ebp
f0106a2f:	c3                   	ret    
f0106a30:	85 f6                	test   %esi,%esi
f0106a32:	89 f5                	mov    %esi,%ebp
f0106a34:	75 0b                	jne    f0106a41 <__umoddi3+0x91>
f0106a36:	b8 01 00 00 00       	mov    $0x1,%eax
f0106a3b:	31 d2                	xor    %edx,%edx
f0106a3d:	f7 f6                	div    %esi
f0106a3f:	89 c5                	mov    %eax,%ebp
f0106a41:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106a45:	31 d2                	xor    %edx,%edx
f0106a47:	f7 f5                	div    %ebp
f0106a49:	89 c8                	mov    %ecx,%eax
f0106a4b:	f7 f5                	div    %ebp
f0106a4d:	eb 9c                	jmp    f01069eb <__umoddi3+0x3b>
f0106a4f:	90                   	nop
f0106a50:	89 c8                	mov    %ecx,%eax
f0106a52:	89 fa                	mov    %edi,%edx
f0106a54:	83 c4 14             	add    $0x14,%esp
f0106a57:	5e                   	pop    %esi
f0106a58:	5f                   	pop    %edi
f0106a59:	5d                   	pop    %ebp
f0106a5a:	c3                   	ret    
f0106a5b:	90                   	nop
f0106a5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106a60:	8b 04 24             	mov    (%esp),%eax
f0106a63:	be 20 00 00 00       	mov    $0x20,%esi
f0106a68:	89 e9                	mov    %ebp,%ecx
f0106a6a:	29 ee                	sub    %ebp,%esi
f0106a6c:	d3 e2                	shl    %cl,%edx
f0106a6e:	89 f1                	mov    %esi,%ecx
f0106a70:	d3 e8                	shr    %cl,%eax
f0106a72:	89 e9                	mov    %ebp,%ecx
f0106a74:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a78:	8b 04 24             	mov    (%esp),%eax
f0106a7b:	09 54 24 04          	or     %edx,0x4(%esp)
f0106a7f:	89 fa                	mov    %edi,%edx
f0106a81:	d3 e0                	shl    %cl,%eax
f0106a83:	89 f1                	mov    %esi,%ecx
f0106a85:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106a89:	8b 44 24 10          	mov    0x10(%esp),%eax
f0106a8d:	d3 ea                	shr    %cl,%edx
f0106a8f:	89 e9                	mov    %ebp,%ecx
f0106a91:	d3 e7                	shl    %cl,%edi
f0106a93:	89 f1                	mov    %esi,%ecx
f0106a95:	d3 e8                	shr    %cl,%eax
f0106a97:	89 e9                	mov    %ebp,%ecx
f0106a99:	09 f8                	or     %edi,%eax
f0106a9b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0106a9f:	f7 74 24 04          	divl   0x4(%esp)
f0106aa3:	d3 e7                	shl    %cl,%edi
f0106aa5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106aa9:	89 d7                	mov    %edx,%edi
f0106aab:	f7 64 24 08          	mull   0x8(%esp)
f0106aaf:	39 d7                	cmp    %edx,%edi
f0106ab1:	89 c1                	mov    %eax,%ecx
f0106ab3:	89 14 24             	mov    %edx,(%esp)
f0106ab6:	72 2c                	jb     f0106ae4 <__umoddi3+0x134>
f0106ab8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0106abc:	72 22                	jb     f0106ae0 <__umoddi3+0x130>
f0106abe:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106ac2:	29 c8                	sub    %ecx,%eax
f0106ac4:	19 d7                	sbb    %edx,%edi
f0106ac6:	89 e9                	mov    %ebp,%ecx
f0106ac8:	89 fa                	mov    %edi,%edx
f0106aca:	d3 e8                	shr    %cl,%eax
f0106acc:	89 f1                	mov    %esi,%ecx
f0106ace:	d3 e2                	shl    %cl,%edx
f0106ad0:	89 e9                	mov    %ebp,%ecx
f0106ad2:	d3 ef                	shr    %cl,%edi
f0106ad4:	09 d0                	or     %edx,%eax
f0106ad6:	89 fa                	mov    %edi,%edx
f0106ad8:	83 c4 14             	add    $0x14,%esp
f0106adb:	5e                   	pop    %esi
f0106adc:	5f                   	pop    %edi
f0106add:	5d                   	pop    %ebp
f0106ade:	c3                   	ret    
f0106adf:	90                   	nop
f0106ae0:	39 d7                	cmp    %edx,%edi
f0106ae2:	75 da                	jne    f0106abe <__umoddi3+0x10e>
f0106ae4:	8b 14 24             	mov    (%esp),%edx
f0106ae7:	89 c1                	mov    %eax,%ecx
f0106ae9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0106aed:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0106af1:	eb cb                	jmp    f0106abe <__umoddi3+0x10e>
f0106af3:	90                   	nop
f0106af4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106af8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0106afc:	0f 82 0f ff ff ff    	jb     f0106a11 <__umoddi3+0x61>
f0106b02:	e9 1a ff ff ff       	jmp    f0106a21 <__umoddi3+0x71>
