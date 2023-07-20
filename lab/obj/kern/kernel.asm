
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
f010004b:	83 3d 80 9e 1e f0 00 	cmpl   $0x0,0xf01e9e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 9e 1e f0    	mov    %esi,0xf01e9e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 05 64 00 00       	call   f0106469 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 40 6b 10 f0 	movl   $0xf0106b40,(%esp)
f010007d:	e8 67 3e 00 00       	call   f0103ee9 <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 28 3e 00 00       	call   f0103eb6 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 42 7d 10 f0 	movl   $0xf0107d42,(%esp)
f0100095:	e8 4f 3e 00 00       	call   f0103ee9 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 3b 09 00 00       	call   f01009e1 <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <i386_init>:
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	53                   	push   %ebx
f01000ac:	83 ec 14             	sub    $0x14,%esp
	memset(edata, 0, end - edata);
f01000af:	b8 08 b0 22 f0       	mov    $0xf022b008,%eax
f01000b4:	2d 00 90 1e f0       	sub    $0xf01e9000,%eax
f01000b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000c4:	00 
f01000c5:	c7 04 24 00 90 1e f0 	movl   $0xf01e9000,(%esp)
f01000cc:	e8 46 5d 00 00       	call   f0105e17 <memset>
	cons_init();
f01000d1:	e8 c9 05 00 00       	call   f010069f <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d6:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000dd:	00 
f01000de:	c7 04 24 ac 6b 10 f0 	movl   $0xf0106bac,(%esp)
f01000e5:	e8 ff 3d 00 00       	call   f0103ee9 <cprintf>
	mem_init();
f01000ea:	e8 4a 14 00 00       	call   f0101539 <mem_init>
	env_init();
f01000ef:	e8 32 36 00 00       	call   f0103726 <env_init>
	trap_init();
f01000f4:	e8 a2 3e 00 00       	call   f0103f9b <trap_init>
	mp_init();
f01000f9:	e8 5c 60 00 00       	call   f010615a <mp_init>
	lapic_init();
f01000fe:	66 90                	xchg   %ax,%ax
f0100100:	e8 7f 63 00 00       	call   f0106484 <lapic_init>
	pic_init();
f0100105:	e8 0f 3d 00 00       	call   f0103e19 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010010a:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100111:	e8 d1 65 00 00       	call   f01066e7 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100116:	83 3d 88 9e 1e f0 07 	cmpl   $0x7,0xf01e9e88
f010011d:	77 24                	ja     f0100143 <i386_init+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011f:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100126:	00 
f0100127:	c7 44 24 08 64 6b 10 	movl   $0xf0106b64,0x8(%esp)
f010012e:	f0 
f010012f:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
f0100136:	00 
f0100137:	c7 04 24 c7 6b 10 f0 	movl   $0xf0106bc7,(%esp)
f010013e:	e8 fd fe ff ff       	call   f0100040 <_panic>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100143:	b8 92 60 10 f0       	mov    $0xf0106092,%eax
f0100148:	2d 18 60 10 f0       	sub    $0xf0106018,%eax
f010014d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100151:	c7 44 24 04 18 60 10 	movl   $0xf0106018,0x4(%esp)
f0100158:	f0 
f0100159:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100160:	e8 ff 5c 00 00       	call   f0105e64 <memmove>
	for (c = cpus; c < cpus + ncpu; c++)
f0100165:	bb 20 a0 1e f0       	mov    $0xf01ea020,%ebx
f010016a:	eb 4d                	jmp    f01001b9 <i386_init+0x111>
		if (c == cpus + cpunum()) // We've started already.
f010016c:	e8 f8 62 00 00       	call   f0106469 <cpunum>
f0100171:	6b c0 74             	imul   $0x74,%eax,%eax
f0100174:	05 20 a0 1e f0       	add    $0xf01ea020,%eax
f0100179:	39 c3                	cmp    %eax,%ebx
f010017b:	74 39                	je     f01001b6 <i386_init+0x10e>
f010017d:	89 d8                	mov    %ebx,%eax
f010017f:	2d 20 a0 1e f0       	sub    $0xf01ea020,%eax
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100184:	c1 f8 02             	sar    $0x2,%eax
f0100187:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010018d:	c1 e0 0f             	shl    $0xf,%eax
f0100190:	8d 80 00 30 1f f0    	lea    -0xfe0d000(%eax),%eax
f0100196:	a3 84 9e 1e f0       	mov    %eax,0xf01e9e84
		lapic_startap(c->cpu_id, PADDR(code));
f010019b:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f01001a2:	00 
f01001a3:	0f b6 03             	movzbl (%ebx),%eax
f01001a6:	89 04 24             	mov    %eax,(%esp)
f01001a9:	e8 26 64 00 00       	call   f01065d4 <lapic_startap>
		while (c->cpu_status != CPU_STARTED)
f01001ae:	8b 43 04             	mov    0x4(%ebx),%eax
f01001b1:	83 f8 01             	cmp    $0x1,%eax
f01001b4:	75 f8                	jne    f01001ae <i386_init+0x106>
	for (c = cpus; c < cpus + ncpu; c++)
f01001b6:	83 c3 74             	add    $0x74,%ebx
f01001b9:	6b 05 c4 a3 1e f0 74 	imul   $0x74,0xf01ea3c4,%eax
f01001c0:	05 20 a0 1e f0       	add    $0xf01ea020,%eax
f01001c5:	39 c3                	cmp    %eax,%ebx
f01001c7:	72 a3                	jb     f010016c <i386_init+0xc4>
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01001c9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01001d0:	00 
f01001d1:	c7 04 24 d4 6b 1a f0 	movl   $0xf01a6bd4,(%esp)
f01001d8:	e8 09 37 00 00       	call   f01038e6 <env_create>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01001e4:	00 
f01001e5:	c7 04 24 0c 8c 1d f0 	movl   $0xf01d8c0c,(%esp)
f01001ec:	e8 f5 36 00 00       	call   f01038e6 <env_create>
	kbd_intr();
f01001f1:	e8 4d 04 00 00       	call   f0100643 <kbd_intr>
	sched_yield();
f01001f6:	e8 36 49 00 00       	call   f0104b31 <sched_yield>

f01001fb <mp_main>:
{
f01001fb:	55                   	push   %ebp
f01001fc:	89 e5                	mov    %esp,%ebp
f01001fe:	83 ec 18             	sub    $0x18,%esp
	lcr3(PADDR(kern_pgdir));
f0100201:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0100206:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010020b:	77 20                	ja     f010022d <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010020d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100211:	c7 44 24 08 88 6b 10 	movl   $0xf0106b88,0x8(%esp)
f0100218:	f0 
f0100219:	c7 44 24 04 72 00 00 	movl   $0x72,0x4(%esp)
f0100220:	00 
f0100221:	c7 04 24 c7 6b 10 f0 	movl   $0xf0106bc7,(%esp)
f0100228:	e8 13 fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010022d:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0100232:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100235:	e8 2f 62 00 00       	call   f0106469 <cpunum>
f010023a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010023e:	c7 04 24 d3 6b 10 f0 	movl   $0xf0106bd3,(%esp)
f0100245:	e8 9f 3c 00 00       	call   f0103ee9 <cprintf>
	lapic_init();
f010024a:	e8 35 62 00 00       	call   f0106484 <lapic_init>
	env_init_percpu();
f010024f:	e8 a8 34 00 00       	call   f01036fc <env_init_percpu>
	trap_init_percpu();
f0100254:	e8 b7 3c 00 00       	call   f0103f10 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100259:	e8 0b 62 00 00       	call   f0106469 <cpunum>
f010025e:	6b d0 74             	imul   $0x74,%eax,%edx
f0100261:	81 c2 20 a0 1e f0    	add    $0xf01ea020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100267:	b8 01 00 00 00       	mov    $0x1,%eax
f010026c:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100270:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0100277:	e8 6b 64 00 00       	call   f01066e7 <spin_lock>
	sched_yield();
f010027c:	e8 b0 48 00 00       	call   f0104b31 <sched_yield>

f0100281 <_warn>:
}

/* like panic, but don't */
void _warn(const char *file, int line, const char *fmt, ...)
{
f0100281:	55                   	push   %ebp
f0100282:	89 e5                	mov    %esp,%ebp
f0100284:	53                   	push   %ebx
f0100285:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100288:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010028b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010028e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100292:	8b 45 08             	mov    0x8(%ebp),%eax
f0100295:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100299:	c7 04 24 e9 6b 10 f0 	movl   $0xf0106be9,(%esp)
f01002a0:	e8 44 3c 00 00       	call   f0103ee9 <cprintf>
	vcprintf(fmt, ap);
f01002a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002a9:	8b 45 10             	mov    0x10(%ebp),%eax
f01002ac:	89 04 24             	mov    %eax,(%esp)
f01002af:	e8 02 3c 00 00       	call   f0103eb6 <vcprintf>
	cprintf("\n");
f01002b4:	c7 04 24 42 7d 10 f0 	movl   $0xf0107d42,(%esp)
f01002bb:	e8 29 3c 00 00       	call   f0103ee9 <cprintf>
	va_end(ap);
}
f01002c0:	83 c4 14             	add    $0x14,%esp
f01002c3:	5b                   	pop    %ebx
f01002c4:	5d                   	pop    %ebp
f01002c5:	c3                   	ret    
f01002c6:	66 90                	xchg   %ax,%ax
f01002c8:	66 90                	xchg   %ax,%ax
f01002ca:	66 90                	xchg   %ax,%ax
f01002cc:	66 90                	xchg   %ax,%ax
f01002ce:	66 90                	xchg   %ax,%ax

f01002d0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002d0:	55                   	push   %ebp
f01002d1:	89 e5                	mov    %esp,%ebp
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002d8:	ec                   	in     (%dx),%al
	if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA))
f01002d9:	a8 01                	test   $0x1,%al
f01002db:	74 08                	je     f01002e5 <serial_proc_data+0x15>
f01002dd:	b2 f8                	mov    $0xf8,%dl
f01002df:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1 + COM_RX);
f01002e0:	0f b6 c0             	movzbl %al,%eax
f01002e3:	eb 05                	jmp    f01002ea <serial_proc_data+0x1a>
		return -1;
f01002e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01002ea:	5d                   	pop    %ebp
f01002eb:	c3                   	ret    

f01002ec <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002ec:	55                   	push   %ebp
f01002ed:	89 e5                	mov    %esp,%ebp
f01002ef:	53                   	push   %ebx
f01002f0:	83 ec 04             	sub    $0x4,%esp
f01002f3:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1)
f01002f5:	eb 2a                	jmp    f0100321 <cons_intr+0x35>
	{
		if (c == 0)
f01002f7:	85 d2                	test   %edx,%edx
f01002f9:	74 26                	je     f0100321 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01002fb:	a1 24 92 1e f0       	mov    0xf01e9224,%eax
f0100300:	8d 48 01             	lea    0x1(%eax),%ecx
f0100303:	89 0d 24 92 1e f0    	mov    %ecx,0xf01e9224
f0100309:	88 90 20 90 1e f0    	mov    %dl,-0xfe16fe0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f010030f:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100315:	75 0a                	jne    f0100321 <cons_intr+0x35>
			cons.wpos = 0;
f0100317:	c7 05 24 92 1e f0 00 	movl   $0x0,0xf01e9224
f010031e:	00 00 00 
	while ((c = (*proc)()) != -1)
f0100321:	ff d3                	call   *%ebx
f0100323:	89 c2                	mov    %eax,%edx
f0100325:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100328:	75 cd                	jne    f01002f7 <cons_intr+0xb>
	}
}
f010032a:	83 c4 04             	add    $0x4,%esp
f010032d:	5b                   	pop    %ebx
f010032e:	5d                   	pop    %ebp
f010032f:	c3                   	ret    

f0100330 <kbd_proc_data>:
f0100330:	ba 64 00 00 00       	mov    $0x64,%edx
f0100335:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100336:	a8 01                	test   $0x1,%al
f0100338:	0f 84 f7 00 00 00    	je     f0100435 <kbd_proc_data+0x105>
	if (stat & KBS_TERR)
f010033e:	a8 20                	test   $0x20,%al
f0100340:	0f 85 f5 00 00 00    	jne    f010043b <kbd_proc_data+0x10b>
f0100346:	b2 60                	mov    $0x60,%dl
f0100348:	ec                   	in     (%dx),%al
f0100349:	89 c2                	mov    %eax,%edx
	if (data == 0xE0)
f010034b:	3c e0                	cmp    $0xe0,%al
f010034d:	75 0d                	jne    f010035c <kbd_proc_data+0x2c>
		shift |= E0ESC;
f010034f:	83 0d 00 90 1e f0 40 	orl    $0x40,0xf01e9000
		return 0;
f0100356:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010035b:	c3                   	ret    
{
f010035c:	55                   	push   %ebp
f010035d:	89 e5                	mov    %esp,%ebp
f010035f:	53                   	push   %ebx
f0100360:	83 ec 14             	sub    $0x14,%esp
	else if (data & 0x80)
f0100363:	84 c0                	test   %al,%al
f0100365:	79 37                	jns    f010039e <kbd_proc_data+0x6e>
		data = (shift & E0ESC ? data : data & 0x7F);
f0100367:	8b 0d 00 90 1e f0    	mov    0xf01e9000,%ecx
f010036d:	89 cb                	mov    %ecx,%ebx
f010036f:	83 e3 40             	and    $0x40,%ebx
f0100372:	83 e0 7f             	and    $0x7f,%eax
f0100375:	85 db                	test   %ebx,%ebx
f0100377:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010037a:	0f b6 d2             	movzbl %dl,%edx
f010037d:	0f b6 82 60 6d 10 f0 	movzbl -0xfef92a0(%edx),%eax
f0100384:	83 c8 40             	or     $0x40,%eax
f0100387:	0f b6 c0             	movzbl %al,%eax
f010038a:	f7 d0                	not    %eax
f010038c:	21 c1                	and    %eax,%ecx
f010038e:	89 0d 00 90 1e f0    	mov    %ecx,0xf01e9000
		return 0;
f0100394:	b8 00 00 00 00       	mov    $0x0,%eax
f0100399:	e9 a3 00 00 00       	jmp    f0100441 <kbd_proc_data+0x111>
	else if (shift & E0ESC)
f010039e:	8b 0d 00 90 1e f0    	mov    0xf01e9000,%ecx
f01003a4:	f6 c1 40             	test   $0x40,%cl
f01003a7:	74 0e                	je     f01003b7 <kbd_proc_data+0x87>
		data |= 0x80;
f01003a9:	83 c8 80             	or     $0xffffff80,%eax
f01003ac:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01003ae:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003b1:	89 0d 00 90 1e f0    	mov    %ecx,0xf01e9000
	shift |= shiftcode[data];
f01003b7:	0f b6 d2             	movzbl %dl,%edx
f01003ba:	0f b6 82 60 6d 10 f0 	movzbl -0xfef92a0(%edx),%eax
f01003c1:	0b 05 00 90 1e f0    	or     0xf01e9000,%eax
	shift ^= togglecode[data];
f01003c7:	0f b6 8a 60 6c 10 f0 	movzbl -0xfef93a0(%edx),%ecx
f01003ce:	31 c8                	xor    %ecx,%eax
f01003d0:	a3 00 90 1e f0       	mov    %eax,0xf01e9000
	c = charcode[shift & (CTL | SHIFT)][data];
f01003d5:	89 c1                	mov    %eax,%ecx
f01003d7:	83 e1 03             	and    $0x3,%ecx
f01003da:	8b 0c 8d 40 6c 10 f0 	mov    -0xfef93c0(,%ecx,4),%ecx
f01003e1:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003e5:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK)
f01003e8:	a8 08                	test   $0x8,%al
f01003ea:	74 1b                	je     f0100407 <kbd_proc_data+0xd7>
		if ('a' <= c && c <= 'z')
f01003ec:	89 da                	mov    %ebx,%edx
f01003ee:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003f1:	83 f9 19             	cmp    $0x19,%ecx
f01003f4:	77 05                	ja     f01003fb <kbd_proc_data+0xcb>
			c += 'A' - 'a';
f01003f6:	83 eb 20             	sub    $0x20,%ebx
f01003f9:	eb 0c                	jmp    f0100407 <kbd_proc_data+0xd7>
		else if ('A' <= c && c <= 'Z')
f01003fb:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003fe:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100401:	83 fa 19             	cmp    $0x19,%edx
f0100404:	0f 46 d9             	cmovbe %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL)
f0100407:	f7 d0                	not    %eax
f0100409:	89 c2                	mov    %eax,%edx
	return c;
f010040b:	89 d8                	mov    %ebx,%eax
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL)
f010040d:	f6 c2 06             	test   $0x6,%dl
f0100410:	75 2f                	jne    f0100441 <kbd_proc_data+0x111>
f0100412:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100418:	75 27                	jne    f0100441 <kbd_proc_data+0x111>
		cprintf("Rebooting!\n");
f010041a:	c7 04 24 03 6c 10 f0 	movl   $0xf0106c03,(%esp)
f0100421:	e8 c3 3a 00 00       	call   f0103ee9 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100426:	ba 92 00 00 00       	mov    $0x92,%edx
f010042b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100430:	ee                   	out    %al,(%dx)
	return c;
f0100431:	89 d8                	mov    %ebx,%eax
f0100433:	eb 0c                	jmp    f0100441 <kbd_proc_data+0x111>
		return -1;
f0100435:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010043a:	c3                   	ret    
		return -1;
f010043b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100440:	c3                   	ret    
}
f0100441:	83 c4 14             	add    $0x14,%esp
f0100444:	5b                   	pop    %ebx
f0100445:	5d                   	pop    %ebp
f0100446:	c3                   	ret    

f0100447 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100447:	55                   	push   %ebp
f0100448:	89 e5                	mov    %esp,%ebp
f010044a:	57                   	push   %edi
f010044b:	56                   	push   %esi
f010044c:	53                   	push   %ebx
f010044d:	83 ec 1c             	sub    $0x1c,%esp
f0100450:	89 c7                	mov    %eax,%edi
f0100452:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100457:	be fd 03 00 00       	mov    $0x3fd,%esi
f010045c:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100461:	eb 06                	jmp    f0100469 <cons_putc+0x22>
f0100463:	89 ca                	mov    %ecx,%edx
f0100465:	ec                   	in     (%dx),%al
f0100466:	ec                   	in     (%dx),%al
f0100467:	ec                   	in     (%dx),%al
f0100468:	ec                   	in     (%dx),%al
f0100469:	89 f2                	mov    %esi,%edx
f010046b:	ec                   	in     (%dx),%al
	for (i = 0;
f010046c:	a8 20                	test   $0x20,%al
f010046e:	75 05                	jne    f0100475 <cons_putc+0x2e>
		 !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100470:	83 eb 01             	sub    $0x1,%ebx
f0100473:	75 ee                	jne    f0100463 <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f0100475:	89 f8                	mov    %edi,%eax
f0100477:	0f b6 c0             	movzbl %al,%eax
f010047a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010047d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100482:	ee                   	out    %al,(%dx)
f0100483:	bb 01 32 00 00       	mov    $0x3201,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100488:	be 79 03 00 00       	mov    $0x379,%esi
f010048d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100492:	eb 06                	jmp    f010049a <cons_putc+0x53>
f0100494:	89 ca                	mov    %ecx,%edx
f0100496:	ec                   	in     (%dx),%al
f0100497:	ec                   	in     (%dx),%al
f0100498:	ec                   	in     (%dx),%al
f0100499:	ec                   	in     (%dx),%al
f010049a:	89 f2                	mov    %esi,%edx
f010049c:	ec                   	in     (%dx),%al
	for (i = 0; !(inb(0x378 + 1) & 0x80) && i < 12800; i++)
f010049d:	84 c0                	test   %al,%al
f010049f:	78 05                	js     f01004a6 <cons_putc+0x5f>
f01004a1:	83 eb 01             	sub    $0x1,%ebx
f01004a4:	75 ee                	jne    f0100494 <cons_putc+0x4d>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004a6:	ba 78 03 00 00       	mov    $0x378,%edx
f01004ab:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f01004af:	ee                   	out    %al,(%dx)
f01004b0:	b2 7a                	mov    $0x7a,%dl
f01004b2:	b8 0d 00 00 00       	mov    $0xd,%eax
f01004b7:	ee                   	out    %al,(%dx)
f01004b8:	b8 08 00 00 00       	mov    $0x8,%eax
f01004bd:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01004be:	89 fa                	mov    %edi,%edx
f01004c0:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01004c6:	89 f8                	mov    %edi,%eax
f01004c8:	80 cc 07             	or     $0x7,%ah
f01004cb:	85 d2                	test   %edx,%edx
f01004cd:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff)
f01004d0:	89 f8                	mov    %edi,%eax
f01004d2:	0f b6 c0             	movzbl %al,%eax
f01004d5:	83 f8 09             	cmp    $0x9,%eax
f01004d8:	74 78                	je     f0100552 <cons_putc+0x10b>
f01004da:	83 f8 09             	cmp    $0x9,%eax
f01004dd:	7f 0a                	jg     f01004e9 <cons_putc+0xa2>
f01004df:	83 f8 08             	cmp    $0x8,%eax
f01004e2:	74 18                	je     f01004fc <cons_putc+0xb5>
f01004e4:	e9 9d 00 00 00       	jmp    f0100586 <cons_putc+0x13f>
f01004e9:	83 f8 0a             	cmp    $0xa,%eax
f01004ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01004f0:	74 3a                	je     f010052c <cons_putc+0xe5>
f01004f2:	83 f8 0d             	cmp    $0xd,%eax
f01004f5:	74 3d                	je     f0100534 <cons_putc+0xed>
f01004f7:	e9 8a 00 00 00       	jmp    f0100586 <cons_putc+0x13f>
		if (crt_pos > 0)
f01004fc:	0f b7 05 28 92 1e f0 	movzwl 0xf01e9228,%eax
f0100503:	66 85 c0             	test   %ax,%ax
f0100506:	0f 84 e5 00 00 00    	je     f01005f1 <cons_putc+0x1aa>
			crt_pos--;
f010050c:	83 e8 01             	sub    $0x1,%eax
f010050f:	66 a3 28 92 1e f0    	mov    %ax,0xf01e9228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100515:	0f b7 c0             	movzwl %ax,%eax
f0100518:	66 81 e7 00 ff       	and    $0xff00,%di
f010051d:	83 cf 20             	or     $0x20,%edi
f0100520:	8b 15 2c 92 1e f0    	mov    0xf01e922c,%edx
f0100526:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010052a:	eb 78                	jmp    f01005a4 <cons_putc+0x15d>
		crt_pos += CRT_COLS;
f010052c:	66 83 05 28 92 1e f0 	addw   $0x50,0xf01e9228
f0100533:	50 
		crt_pos -= (crt_pos % CRT_COLS);
f0100534:	0f b7 05 28 92 1e f0 	movzwl 0xf01e9228,%eax
f010053b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100541:	c1 e8 16             	shr    $0x16,%eax
f0100544:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100547:	c1 e0 04             	shl    $0x4,%eax
f010054a:	66 a3 28 92 1e f0    	mov    %ax,0xf01e9228
f0100550:	eb 52                	jmp    f01005a4 <cons_putc+0x15d>
		cons_putc(' ');
f0100552:	b8 20 00 00 00       	mov    $0x20,%eax
f0100557:	e8 eb fe ff ff       	call   f0100447 <cons_putc>
		cons_putc(' ');
f010055c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100561:	e8 e1 fe ff ff       	call   f0100447 <cons_putc>
		cons_putc(' ');
f0100566:	b8 20 00 00 00       	mov    $0x20,%eax
f010056b:	e8 d7 fe ff ff       	call   f0100447 <cons_putc>
		cons_putc(' ');
f0100570:	b8 20 00 00 00       	mov    $0x20,%eax
f0100575:	e8 cd fe ff ff       	call   f0100447 <cons_putc>
		cons_putc(' ');
f010057a:	b8 20 00 00 00       	mov    $0x20,%eax
f010057f:	e8 c3 fe ff ff       	call   f0100447 <cons_putc>
f0100584:	eb 1e                	jmp    f01005a4 <cons_putc+0x15d>
		crt_buf[crt_pos++] = c; /* write the character */
f0100586:	0f b7 05 28 92 1e f0 	movzwl 0xf01e9228,%eax
f010058d:	8d 50 01             	lea    0x1(%eax),%edx
f0100590:	66 89 15 28 92 1e f0 	mov    %dx,0xf01e9228
f0100597:	0f b7 c0             	movzwl %ax,%eax
f010059a:	8b 15 2c 92 1e f0    	mov    0xf01e922c,%edx
f01005a0:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
	if (crt_pos >= CRT_SIZE) // 当输出字符超过终端范围
f01005a4:	66 81 3d 28 92 1e f0 	cmpw   $0x7cf,0xf01e9228
f01005ab:	cf 07 
f01005ad:	76 42                	jbe    f01005f1 <cons_putc+0x1aa>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t)); // 已有字符往上移动一行
f01005af:	a1 2c 92 1e f0       	mov    0xf01e922c,%eax
f01005b4:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01005bb:	00 
f01005bc:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005c2:	89 54 24 04          	mov    %edx,0x4(%esp)
f01005c6:	89 04 24             	mov    %eax,(%esp)
f01005c9:	e8 96 58 00 00       	call   f0105e64 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01005ce:	8b 15 2c 92 1e f0    	mov    0xf01e922c,%edx
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)								// 清零最后一行
f01005d4:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01005d9:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)								// 清零最后一行
f01005df:	83 c0 01             	add    $0x1,%eax
f01005e2:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01005e7:	75 f0                	jne    f01005d9 <cons_putc+0x192>
		crt_pos -= CRT_COLS; // 索引向前移动，即从最后一行的开头写入
f01005e9:	66 83 2d 28 92 1e f0 	subw   $0x50,0xf01e9228
f01005f0:	50 
	outb(addr_6845, 14);
f01005f1:	8b 0d 30 92 1e f0    	mov    0xf01e9230,%ecx
f01005f7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005fc:	89 ca                	mov    %ecx,%edx
f01005fe:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005ff:	0f b7 1d 28 92 1e f0 	movzwl 0xf01e9228,%ebx
f0100606:	8d 71 01             	lea    0x1(%ecx),%esi
f0100609:	89 d8                	mov    %ebx,%eax
f010060b:	66 c1 e8 08          	shr    $0x8,%ax
f010060f:	89 f2                	mov    %esi,%edx
f0100611:	ee                   	out    %al,(%dx)
f0100612:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100617:	89 ca                	mov    %ecx,%edx
f0100619:	ee                   	out    %al,(%dx)
f010061a:	89 d8                	mov    %ebx,%eax
f010061c:	89 f2                	mov    %esi,%edx
f010061e:	ee                   	out    %al,(%dx)
	serial_putc(c); // 向串口输出
	lpt_putc(c);
	cga_putc(c); // 向控制台输出字符
}
f010061f:	83 c4 1c             	add    $0x1c,%esp
f0100622:	5b                   	pop    %ebx
f0100623:	5e                   	pop    %esi
f0100624:	5f                   	pop    %edi
f0100625:	5d                   	pop    %ebp
f0100626:	c3                   	ret    

f0100627 <serial_intr>:
	if (serial_exists)
f0100627:	80 3d 34 92 1e f0 00 	cmpb   $0x0,0xf01e9234
f010062e:	74 11                	je     f0100641 <serial_intr+0x1a>
{
f0100630:	55                   	push   %ebp
f0100631:	89 e5                	mov    %esp,%ebp
f0100633:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100636:	b8 d0 02 10 f0       	mov    $0xf01002d0,%eax
f010063b:	e8 ac fc ff ff       	call   f01002ec <cons_intr>
}
f0100640:	c9                   	leave  
f0100641:	f3 c3                	repz ret 

f0100643 <kbd_intr>:
{
f0100643:	55                   	push   %ebp
f0100644:	89 e5                	mov    %esp,%ebp
f0100646:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100649:	b8 30 03 10 f0       	mov    $0xf0100330,%eax
f010064e:	e8 99 fc ff ff       	call   f01002ec <cons_intr>
}
f0100653:	c9                   	leave  
f0100654:	c3                   	ret    

f0100655 <cons_getc>:
{
f0100655:	55                   	push   %ebp
f0100656:	89 e5                	mov    %esp,%ebp
f0100658:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f010065b:	e8 c7 ff ff ff       	call   f0100627 <serial_intr>
	kbd_intr();
f0100660:	e8 de ff ff ff       	call   f0100643 <kbd_intr>
	if (cons.rpos != cons.wpos)
f0100665:	a1 20 92 1e f0       	mov    0xf01e9220,%eax
f010066a:	3b 05 24 92 1e f0    	cmp    0xf01e9224,%eax
f0100670:	74 26                	je     f0100698 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100672:	8d 50 01             	lea    0x1(%eax),%edx
f0100675:	89 15 20 92 1e f0    	mov    %edx,0xf01e9220
f010067b:	0f b6 88 20 90 1e f0 	movzbl -0xfe16fe0(%eax),%ecx
		return c;
f0100682:	89 c8                	mov    %ecx,%eax
		if (cons.rpos == CONSBUFSIZE)
f0100684:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010068a:	75 11                	jne    f010069d <cons_getc+0x48>
			cons.rpos = 0;
f010068c:	c7 05 20 92 1e f0 00 	movl   $0x0,0xf01e9220
f0100693:	00 00 00 
f0100696:	eb 05                	jmp    f010069d <cons_getc+0x48>
	return 0;
f0100698:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010069d:	c9                   	leave  
f010069e:	c3                   	ret    

f010069f <cons_init>:

// initialize the console devices
void cons_init(void)
{
f010069f:	55                   	push   %ebp
f01006a0:	89 e5                	mov    %esp,%ebp
f01006a2:	57                   	push   %edi
f01006a3:	56                   	push   %esi
f01006a4:	53                   	push   %ebx
f01006a5:	83 ec 1c             	sub    $0x1c,%esp
	was = *cp;
f01006a8:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t)0xA55A;
f01006af:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01006b6:	5a a5 
	if (*cp != 0xA55A)
f01006b8:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01006bf:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006c3:	74 11                	je     f01006d6 <cons_init+0x37>
		addr_6845 = MONO_BASE;
f01006c5:	c7 05 30 92 1e f0 b4 	movl   $0x3b4,0xf01e9230
f01006cc:	03 00 00 
		cp = (uint16_t *)(KERNBASE + MONO_BUF);
f01006cf:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f01006d4:	eb 16                	jmp    f01006ec <cons_init+0x4d>
		*cp = was;
f01006d6:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006dd:	c7 05 30 92 1e f0 d4 	movl   $0x3d4,0xf01e9230
f01006e4:	03 00 00 
	cp = (uint16_t *)(KERNBASE + CGA_BUF);
f01006e7:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
	outb(addr_6845, 14);
f01006ec:	8b 0d 30 92 1e f0    	mov    0xf01e9230,%ecx
f01006f2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006f7:	89 ca                	mov    %ecx,%edx
f01006f9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006fa:	8d 59 01             	lea    0x1(%ecx),%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006fd:	89 da                	mov    %ebx,%edx
f01006ff:	ec                   	in     (%dx),%al
f0100700:	0f b6 f0             	movzbl %al,%esi
f0100703:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100706:	b8 0f 00 00 00       	mov    $0xf,%eax
f010070b:	89 ca                	mov    %ecx,%edx
f010070d:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010070e:	89 da                	mov    %ebx,%edx
f0100710:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t *)cp;
f0100711:	89 3d 2c 92 1e f0    	mov    %edi,0xf01e922c
	pos |= inb(addr_6845 + 1);
f0100717:	0f b6 d8             	movzbl %al,%ebx
f010071a:	09 de                	or     %ebx,%esi
	crt_pos = pos;
f010071c:	66 89 35 28 92 1e f0 	mov    %si,0xf01e9228
	kbd_intr();
f0100723:	e8 1b ff ff ff       	call   f0100643 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_KBD));
f0100728:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f010072f:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100734:	89 04 24             	mov    %eax,(%esp)
f0100737:	e8 6e 36 00 00       	call   f0103daa <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010073c:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100741:	b8 00 00 00 00       	mov    $0x0,%eax
f0100746:	89 f2                	mov    %esi,%edx
f0100748:	ee                   	out    %al,(%dx)
f0100749:	b2 fb                	mov    $0xfb,%dl
f010074b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100750:	ee                   	out    %al,(%dx)
f0100751:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100756:	b8 0c 00 00 00       	mov    $0xc,%eax
f010075b:	89 da                	mov    %ebx,%edx
f010075d:	ee                   	out    %al,(%dx)
f010075e:	b2 f9                	mov    $0xf9,%dl
f0100760:	b8 00 00 00 00       	mov    $0x0,%eax
f0100765:	ee                   	out    %al,(%dx)
f0100766:	b2 fb                	mov    $0xfb,%dl
f0100768:	b8 03 00 00 00       	mov    $0x3,%eax
f010076d:	ee                   	out    %al,(%dx)
f010076e:	b2 fc                	mov    $0xfc,%dl
f0100770:	b8 00 00 00 00       	mov    $0x0,%eax
f0100775:	ee                   	out    %al,(%dx)
f0100776:	b2 f9                	mov    $0xf9,%dl
f0100778:	b8 01 00 00 00       	mov    $0x1,%eax
f010077d:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010077e:	b2 fd                	mov    $0xfd,%dl
f0100780:	ec                   	in     (%dx),%al
	serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
f0100781:	3c ff                	cmp    $0xff,%al
f0100783:	0f 95 c1             	setne  %cl
f0100786:	88 0d 34 92 1e f0    	mov    %cl,0xf01e9234
f010078c:	89 f2                	mov    %esi,%edx
f010078e:	ec                   	in     (%dx),%al
f010078f:	89 da                	mov    %ebx,%edx
f0100791:	ec                   	in     (%dx),%al
	if (serial_exists)
f0100792:	84 c9                	test   %cl,%cl
f0100794:	74 1d                	je     f01007b3 <cons_init+0x114>
		irq_setmask_8259A(irq_mask_8259A & ~(1 << IRQ_SERIAL));
f0100796:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f010079d:	25 ef ff 00 00       	and    $0xffef,%eax
f01007a2:	89 04 24             	mov    %eax,(%esp)
f01007a5:	e8 00 36 00 00       	call   f0103daa <irq_setmask_8259A>
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007aa:	80 3d 34 92 1e f0 00 	cmpb   $0x0,0xf01e9234
f01007b1:	75 0c                	jne    f01007bf <cons_init+0x120>
		cprintf("Serial port does not exist!\n");
f01007b3:	c7 04 24 0f 6c 10 f0 	movl   $0xf0106c0f,(%esp)
f01007ba:	e8 2a 37 00 00       	call   f0103ee9 <cprintf>
}
f01007bf:	83 c4 1c             	add    $0x1c,%esp
f01007c2:	5b                   	pop    %ebx
f01007c3:	5e                   	pop    %esi
f01007c4:	5f                   	pop    %edi
f01007c5:	5d                   	pop    %ebp
f01007c6:	c3                   	ret    

f01007c7 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void cputchar(int c)
{
f01007c7:	55                   	push   %ebp
f01007c8:	89 e5                	mov    %esp,%ebp
f01007ca:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01007d0:	e8 72 fc ff ff       	call   f0100447 <cons_putc>
}
f01007d5:	c9                   	leave  
f01007d6:	c3                   	ret    

f01007d7 <getchar>:

int getchar(void)
{
f01007d7:	55                   	push   %ebp
f01007d8:	89 e5                	mov    %esp,%ebp
f01007da:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007dd:	e8 73 fe ff ff       	call   f0100655 <cons_getc>
f01007e2:	85 c0                	test   %eax,%eax
f01007e4:	74 f7                	je     f01007dd <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007e6:	c9                   	leave  
f01007e7:	c3                   	ret    

f01007e8 <iscons>:

int iscons(int fdnum)
{
f01007e8:	55                   	push   %ebp
f01007e9:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007eb:	b8 01 00 00 00       	mov    $0x1,%eax
f01007f0:	5d                   	pop    %ebp
f01007f1:	c3                   	ret    
f01007f2:	66 90                	xchg   %ax,%ax
f01007f4:	66 90                	xchg   %ax,%ax
f01007f6:	66 90                	xchg   %ax,%ax
f01007f8:	66 90                	xchg   %ax,%ax
f01007fa:	66 90                	xchg   %ax,%ax
f01007fc:	66 90                	xchg   %ax,%ax
f01007fe:	66 90                	xchg   %ax,%ax

f0100800 <mon_help>:
};

/***** Implementations of basic kernel monitor commands *****/

int mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100800:	55                   	push   %ebp
f0100801:	89 e5                	mov    %esp,%ebp
f0100803:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100806:	c7 44 24 08 60 6e 10 	movl   $0xf0106e60,0x8(%esp)
f010080d:	f0 
f010080e:	c7 44 24 04 7e 6e 10 	movl   $0xf0106e7e,0x4(%esp)
f0100815:	f0 
f0100816:	c7 04 24 83 6e 10 f0 	movl   $0xf0106e83,(%esp)
f010081d:	e8 c7 36 00 00       	call   f0103ee9 <cprintf>
f0100822:	c7 44 24 08 28 6f 10 	movl   $0xf0106f28,0x8(%esp)
f0100829:	f0 
f010082a:	c7 44 24 04 8c 6e 10 	movl   $0xf0106e8c,0x4(%esp)
f0100831:	f0 
f0100832:	c7 04 24 83 6e 10 f0 	movl   $0xf0106e83,(%esp)
f0100839:	e8 ab 36 00 00       	call   f0103ee9 <cprintf>
f010083e:	c7 44 24 08 95 6e 10 	movl   $0xf0106e95,0x8(%esp)
f0100845:	f0 
f0100846:	c7 44 24 04 9b 6e 10 	movl   $0xf0106e9b,0x4(%esp)
f010084d:	f0 
f010084e:	c7 04 24 83 6e 10 f0 	movl   $0xf0106e83,(%esp)
f0100855:	e8 8f 36 00 00       	call   f0103ee9 <cprintf>
	return 0;
}
f010085a:	b8 00 00 00 00       	mov    $0x0,%eax
f010085f:	c9                   	leave  
f0100860:	c3                   	ret    

f0100861 <mon_kerninfo>:

int mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100861:	55                   	push   %ebp
f0100862:	89 e5                	mov    %esp,%ebp
f0100864:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100867:	c7 04 24 a5 6e 10 f0 	movl   $0xf0106ea5,(%esp)
f010086e:	e8 76 36 00 00       	call   f0103ee9 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100873:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010087a:	00 
f010087b:	c7 04 24 50 6f 10 f0 	movl   $0xf0106f50,(%esp)
f0100882:	e8 62 36 00 00       	call   f0103ee9 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100887:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010088e:	00 
f010088f:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100896:	f0 
f0100897:	c7 04 24 78 6f 10 f0 	movl   $0xf0106f78,(%esp)
f010089e:	e8 46 36 00 00       	call   f0103ee9 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01008a3:	c7 44 24 08 37 6b 10 	movl   $0x106b37,0x8(%esp)
f01008aa:	00 
f01008ab:	c7 44 24 04 37 6b 10 	movl   $0xf0106b37,0x4(%esp)
f01008b2:	f0 
f01008b3:	c7 04 24 9c 6f 10 f0 	movl   $0xf0106f9c,(%esp)
f01008ba:	e8 2a 36 00 00       	call   f0103ee9 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01008bf:	c7 44 24 08 00 90 1e 	movl   $0x1e9000,0x8(%esp)
f01008c6:	00 
f01008c7:	c7 44 24 04 00 90 1e 	movl   $0xf01e9000,0x4(%esp)
f01008ce:	f0 
f01008cf:	c7 04 24 c0 6f 10 f0 	movl   $0xf0106fc0,(%esp)
f01008d6:	e8 0e 36 00 00       	call   f0103ee9 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008db:	c7 44 24 08 08 b0 22 	movl   $0x22b008,0x8(%esp)
f01008e2:	00 
f01008e3:	c7 44 24 04 08 b0 22 	movl   $0xf022b008,0x4(%esp)
f01008ea:	f0 
f01008eb:	c7 04 24 e4 6f 10 f0 	movl   $0xf0106fe4,(%esp)
f01008f2:	e8 f2 35 00 00       	call   f0103ee9 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
			ROUNDUP(end - entry, 1024) / 1024);
f01008f7:	b8 07 b4 22 f0       	mov    $0xf022b407,%eax
f01008fc:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100901:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100906:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010090c:	85 c0                	test   %eax,%eax
f010090e:	0f 48 c2             	cmovs  %edx,%eax
f0100911:	c1 f8 0a             	sar    $0xa,%eax
f0100914:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100918:	c7 04 24 08 70 10 f0 	movl   $0xf0107008,(%esp)
f010091f:	e8 c5 35 00 00       	call   f0103ee9 <cprintf>
	return 0;
}
f0100924:	b8 00 00 00 00       	mov    $0x0,%eax
f0100929:	c9                   	leave  
f010092a:	c3                   	ret    

f010092b <mon_backtrace>:

int mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010092b:	55                   	push   %ebp
f010092c:	89 e5                	mov    %esp,%ebp
f010092e:	57                   	push   %edi
f010092f:	56                   	push   %esi
f0100930:	53                   	push   %ebx
f0100931:	83 ec 4c             	sub    $0x4c,%esp
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100934:	89 e8                	mov    %ebp,%eax
	// 被调用的函数(mon_backtrace)开始时，首先完成了push %ebp，mov %esp, %ebp
	// 注1：push时，先减%esp在存储内容
	// 注2：栈向下生长，用+1来访问前面的内容
	// Your code here.

	int *ebp = (int *)read_ebp(); // 读取本函数%ebp的值，转化为指针，作为地址使用
f0100936:	89 c7                	mov    %eax,%edi
	int eip = ebp[1];			  // 堆栈上存储的第一个东西就是返回地址，因此用偏移量1来访问
f0100938:	8b 40 04             	mov    0x4(%eax),%eax
f010093b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	while (1)					  // trace整个stack
	{
		// 打印%ebp和%eip
		cprintf("ebp %x, eip %x, args ", ebp, eip);
f010093e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100941:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100945:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100949:	c7 04 24 be 6e 10 f0 	movl   $0xf0106ebe,(%esp)
f0100950:	e8 94 35 00 00       	call   f0103ee9 <cprintf>
		int *args = ebp + 2;		 // 从偏移量2开始存储的是上个函数的参数
f0100955:	8d 5f 08             	lea    0x8(%edi),%ebx
f0100958:	8d 77 1c             	lea    0x1c(%edi),%esi
		for (int i = 0; i < 5; ++i)	 // 练习要求打印5个参数
			cprintf("%x ", args[i]); // 输出参数，注：args[i]和args+i是一样的效果
f010095b:	8b 03                	mov    (%ebx),%eax
f010095d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100961:	c7 04 24 d4 6e 10 f0 	movl   $0xf0106ed4,(%esp)
f0100968:	e8 7c 35 00 00       	call   f0103ee9 <cprintf>
f010096d:	83 c3 04             	add    $0x4,%ebx
		for (int i = 0; i < 5; ++i)	 // 练习要求打印5个参数
f0100970:	39 f3                	cmp    %esi,%ebx
f0100972:	75 e7                	jne    f010095b <mon_backtrace+0x30>
		cprintf("\n");
f0100974:	c7 04 24 42 7d 10 f0 	movl   $0xf0107d42,(%esp)
f010097b:	e8 69 35 00 00       	call   f0103ee9 <cprintf>

		// 显示每个%eip对应的函数名、源文件名和行号
		struct Eipdebuginfo info;
		if (!debuginfo_eip(eip, &info)) // 读取debug信息，找到信息，则debuginfo_eip返回0
f0100980:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100983:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100987:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010098a:	89 34 24             	mov    %esi,(%esp)
f010098d:	e8 35 49 00 00       	call   f01052c7 <debuginfo_eip>
f0100992:	85 c0                	test   %eax,%eax
f0100994:	75 3e                	jne    f01009d4 <mon_backtrace+0xa9>
			cprintf("%s: %d: %.*s+%d\n",
f0100996:	89 f0                	mov    %esi,%eax
f0100998:	2b 45 e0             	sub    -0x20(%ebp),%eax
f010099b:	89 44 24 14          	mov    %eax,0x14(%esp)
f010099f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01009a2:	89 44 24 10          	mov    %eax,0x10(%esp)
f01009a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01009a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01009b0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009b4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01009b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009bb:	c7 04 24 d8 6e 10 f0 	movl   $0xf0106ed8,(%esp)
f01009c2:	e8 22 35 00 00       	call   f0103ee9 <cprintf>
					info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, eip - info.eip_fn_addr);
		else // 找不到信息，即到达stack的顶部
			break;

		// 更新指针
		ebp = (int *)*ebp; // *ebp得到压进堆栈的上一个函数的%ebp
f01009c7:	8b 3f                	mov    (%edi),%edi
		eip = ebp[1];
f01009c9:	8b 47 04             	mov    0x4(%edi),%eax
f01009cc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	}
f01009cf:	e9 6a ff ff ff       	jmp    f010093e <mon_backtrace+0x13>
	return 0;
}
f01009d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01009d9:	83 c4 4c             	add    $0x4c,%esp
f01009dc:	5b                   	pop    %ebx
f01009dd:	5e                   	pop    %esi
f01009de:	5f                   	pop    %edi
f01009df:	5d                   	pop    %ebp
f01009e0:	c3                   	ret    

f01009e1 <monitor>:
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void monitor(struct Trapframe *tf)
{
f01009e1:	55                   	push   %ebp
f01009e2:	89 e5                	mov    %esp,%ebp
f01009e4:	57                   	push   %edi
f01009e5:	56                   	push   %esi
f01009e6:	53                   	push   %ebx
f01009e7:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009ea:	c7 04 24 34 70 10 f0 	movl   $0xf0107034,(%esp)
f01009f1:	e8 f3 34 00 00       	call   f0103ee9 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009f6:	c7 04 24 58 70 10 f0 	movl   $0xf0107058,(%esp)
f01009fd:	e8 e7 34 00 00       	call   f0103ee9 <cprintf>

	if (tf != NULL)
f0100a02:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100a06:	74 0b                	je     f0100a13 <monitor+0x32>
		print_trapframe(tf);
f0100a08:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a0b:	89 04 24             	mov    %eax,(%esp)
f0100a0e:	e8 71 3a 00 00       	call   f0104484 <print_trapframe>
	while (1)
	{
		buf = readline("K> ");
f0100a13:	c7 04 24 e9 6e 10 f0 	movl   $0xf0106ee9,(%esp)
f0100a1a:	e8 91 51 00 00       	call   f0105bb0 <readline>
f0100a1f:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100a21:	85 c0                	test   %eax,%eax
f0100a23:	74 ee                	je     f0100a13 <monitor+0x32>
	argv[argc] = 0;
f0100a25:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a2c:	be 00 00 00 00       	mov    $0x0,%esi
f0100a31:	eb 0a                	jmp    f0100a3d <monitor+0x5c>
			*buf++ = 0;
f0100a33:	c6 03 00             	movb   $0x0,(%ebx)
f0100a36:	89 f7                	mov    %esi,%edi
f0100a38:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100a3b:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100a3d:	0f b6 03             	movzbl (%ebx),%eax
f0100a40:	84 c0                	test   %al,%al
f0100a42:	74 63                	je     f0100aa7 <monitor+0xc6>
f0100a44:	0f be c0             	movsbl %al,%eax
f0100a47:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a4b:	c7 04 24 ed 6e 10 f0 	movl   $0xf0106eed,(%esp)
f0100a52:	e8 83 53 00 00       	call   f0105dda <strchr>
f0100a57:	85 c0                	test   %eax,%eax
f0100a59:	75 d8                	jne    f0100a33 <monitor+0x52>
		if (*buf == 0)
f0100a5b:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100a5e:	74 47                	je     f0100aa7 <monitor+0xc6>
		if (argc == MAXARGS - 1)
f0100a60:	83 fe 0f             	cmp    $0xf,%esi
f0100a63:	75 16                	jne    f0100a7b <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a65:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100a6c:	00 
f0100a6d:	c7 04 24 f2 6e 10 f0 	movl   $0xf0106ef2,(%esp)
f0100a74:	e8 70 34 00 00       	call   f0103ee9 <cprintf>
f0100a79:	eb 98                	jmp    f0100a13 <monitor+0x32>
		argv[argc++] = buf;
f0100a7b:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a7e:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a82:	eb 03                	jmp    f0100a87 <monitor+0xa6>
			buf++;
f0100a84:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a87:	0f b6 03             	movzbl (%ebx),%eax
f0100a8a:	84 c0                	test   %al,%al
f0100a8c:	74 ad                	je     f0100a3b <monitor+0x5a>
f0100a8e:	0f be c0             	movsbl %al,%eax
f0100a91:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a95:	c7 04 24 ed 6e 10 f0 	movl   $0xf0106eed,(%esp)
f0100a9c:	e8 39 53 00 00       	call   f0105dda <strchr>
f0100aa1:	85 c0                	test   %eax,%eax
f0100aa3:	74 df                	je     f0100a84 <monitor+0xa3>
f0100aa5:	eb 94                	jmp    f0100a3b <monitor+0x5a>
	argv[argc] = 0;
f0100aa7:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100aae:	00 
	if (argc == 0)
f0100aaf:	85 f6                	test   %esi,%esi
f0100ab1:	0f 84 5c ff ff ff    	je     f0100a13 <monitor+0x32>
f0100ab7:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100abc:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		if (strcmp(argv[0], commands[i].name) == 0)
f0100abf:	8b 04 85 80 70 10 f0 	mov    -0xfef8f80(,%eax,4),%eax
f0100ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aca:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100acd:	89 04 24             	mov    %eax,(%esp)
f0100ad0:	e8 a7 52 00 00       	call   f0105d7c <strcmp>
f0100ad5:	85 c0                	test   %eax,%eax
f0100ad7:	75 24                	jne    f0100afd <monitor+0x11c>
			return commands[i].func(argc, argv, tf);
f0100ad9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100adc:	8b 55 08             	mov    0x8(%ebp),%edx
f0100adf:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100ae3:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100ae6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100aea:	89 34 24             	mov    %esi,(%esp)
f0100aed:	ff 14 85 88 70 10 f0 	call   *-0xfef8f78(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100af4:	85 c0                	test   %eax,%eax
f0100af6:	78 25                	js     f0100b1d <monitor+0x13c>
f0100af8:	e9 16 ff ff ff       	jmp    f0100a13 <monitor+0x32>
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f0100afd:	83 c3 01             	add    $0x1,%ebx
f0100b00:	83 fb 03             	cmp    $0x3,%ebx
f0100b03:	75 b7                	jne    f0100abc <monitor+0xdb>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100b05:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100b08:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b0c:	c7 04 24 0f 6f 10 f0 	movl   $0xf0106f0f,(%esp)
f0100b13:	e8 d1 33 00 00       	call   f0103ee9 <cprintf>
f0100b18:	e9 f6 fe ff ff       	jmp    f0100a13 <monitor+0x32>
				break;
	}
}
f0100b1d:	83 c4 5c             	add    $0x5c,%esp
f0100b20:	5b                   	pop    %ebx
f0100b21:	5e                   	pop    %esi
f0100b22:	5f                   	pop    %edi
f0100b23:	5d                   	pop    %ebp
f0100b24:	c3                   	ret    
f0100b25:	66 90                	xchg   %ax,%ax
f0100b27:	66 90                	xchg   %ax,%ax
f0100b29:	66 90                	xchg   %ax,%ax
f0100b2b:	66 90                	xchg   %ax,%ax
f0100b2d:	66 90                	xchg   %ax,%ax
f0100b2f:	90                   	nop

f0100b30 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100b30:	55                   	push   %ebp
f0100b31:	89 e5                	mov    %esp,%ebp
f0100b33:	56                   	push   %esi
f0100b34:	53                   	push   %ebx
f0100b35:	83 ec 10             	sub    $0x10,%esp
f0100b38:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b3a:	89 04 24             	mov    %eax,(%esp)
f0100b3d:	e8 3e 32 00 00       	call   f0103d80 <mc146818_read>
f0100b42:	89 c6                	mov    %eax,%esi
f0100b44:	83 c3 01             	add    $0x1,%ebx
f0100b47:	89 1c 24             	mov    %ebx,(%esp)
f0100b4a:	e8 31 32 00 00       	call   f0103d80 <mc146818_read>
f0100b4f:	c1 e0 08             	shl    $0x8,%eax
f0100b52:	09 f0                	or     %esi,%eax
}
f0100b54:	83 c4 10             	add    $0x10,%esp
f0100b57:	5b                   	pop    %ebx
f0100b58:	5e                   	pop    %esi
f0100b59:	5d                   	pop    %ebp
f0100b5a:	c3                   	ret    

f0100b5b <boot_alloc>:
boot_alloc(uint32_t n)
{
	static char *nextfree; // virtual address of next byte of free memory，static意味着nextfree不会随着函数返回被重置，是全局变量
	char *result;

	if (!nextfree) // nextfree初始化，只有第一次运行会执行
f0100b5b:	83 3d 38 92 1e f0 00 	cmpl   $0x0,0xf01e9238
f0100b62:	75 11                	jne    f0100b75 <boot_alloc+0x1a>
	{
		extern char end[]; // linker会获取内核代码的最后一个字节的位置，将end指向这个地址，因此end指向内核代码结尾

		nextfree = ROUNDUP((char *)end, PGSIZE); // 内核使用的第一块内存必须远离内核代码结尾
f0100b64:	ba 07 c0 22 f0       	mov    $0xf022c007,%edx
f0100b69:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b6f:	89 15 38 92 1e f0    	mov    %edx,0xf01e9238
		 * 假设end是4097，ROUNDUP(end, PGSIZE)得到end=4096*2，这样才能容纳4097
		 */
	}

	// LAB 2: Your code here.
	if (n == 0) // 不分配内存，直接返回
f0100b75:	85 c0                	test   %eax,%eax
f0100b77:	75 06                	jne    f0100b7f <boot_alloc+0x24>
	{
		return nextfree;
f0100b79:	a1 38 92 1e f0       	mov    0xf01e9238,%eax
f0100b7e:	c3                   	ret    
	}

	// n是无符号数，不考虑<0情形
	result = nextfree;				// 将更新前的nextfree赋给result
f0100b7f:	8b 0d 38 92 1e f0    	mov    0xf01e9238,%ecx
	nextfree += ROUNDUP(n, PGSIZE); // +=:在原来的基础上再分配
f0100b85:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100b8b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b91:	01 ca                	add    %ecx,%edx
f0100b93:	89 15 38 92 1e f0    	mov    %edx,0xf01e9238

	// 如果内存不足，boot_alloc应该会死机
	if (nextfree > (char *)0xf0400000) // >4MB
f0100b99:	81 fa 00 00 40 f0    	cmp    $0xf0400000,%edx
f0100b9f:	76 22                	jbe    f0100bc3 <boot_alloc+0x68>
{
f0100ba1:	55                   	push   %ebp
f0100ba2:	89 e5                	mov    %esp,%ebp
f0100ba4:	83 ec 18             	sub    $0x18,%esp
	{
		panic("out of memory(4MB) : boot_alloc() in pmap.c \n"); // 调用预先定义的assert
f0100ba7:	c7 44 24 08 a4 70 10 	movl   $0xf01070a4,0x8(%esp)
f0100bae:	f0 
f0100baf:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
f0100bb6:	00 
f0100bb7:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0100bbe:	e8 7d f4 ff ff       	call   f0100040 <_panic>
		nextfree = result;										 // 分配失败，回调nextfree
		return NULL;
	}
	return result;
f0100bc3:	89 c8                	mov    %ecx,%eax
}
f0100bc5:	c3                   	ret    

f0100bc6 <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bc6:	2b 05 90 9e 1e f0    	sub    0xf01e9e90,%eax
f0100bcc:	c1 f8 03             	sar    $0x3,%eax
f0100bcf:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100bd2:	89 c2                	mov    %eax,%edx
f0100bd4:	c1 ea 0c             	shr    $0xc,%edx
f0100bd7:	3b 15 88 9e 1e f0    	cmp    0xf01e9e88,%edx
f0100bdd:	72 26                	jb     f0100c05 <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f0100bdf:	55                   	push   %ebp
f0100be0:	89 e5                	mov    %esp,%ebp
f0100be2:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100be5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100be9:	c7 44 24 08 64 6b 10 	movl   $0xf0106b64,0x8(%esp)
f0100bf0:	f0 
f0100bf1:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100bf8:	00 
f0100bf9:	c7 04 24 c5 7a 10 f0 	movl   $0xf0107ac5,(%esp)
f0100c00:	e8 3b f4 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100c05:	2d 00 00 00 10       	sub    $0x10000000,%eax
	return KADDR(page2pa(pp));
}
f0100c0a:	c3                   	ret    

f0100c0b <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100c0b:	89 d1                	mov    %edx,%ecx
f0100c0d:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100c10:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100c13:	a8 01                	test   $0x1,%al
f0100c15:	74 5d                	je     f0100c74 <check_va2pa+0x69>
		return ~0;
	p = (pte_t *)KADDR(PTE_ADDR(*pgdir));
f0100c17:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100c1c:	89 c1                	mov    %eax,%ecx
f0100c1e:	c1 e9 0c             	shr    $0xc,%ecx
f0100c21:	3b 0d 88 9e 1e f0    	cmp    0xf01e9e88,%ecx
f0100c27:	72 26                	jb     f0100c4f <check_va2pa+0x44>
{
f0100c29:	55                   	push   %ebp
f0100c2a:	89 e5                	mov    %esp,%ebp
f0100c2c:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c2f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c33:	c7 44 24 08 64 6b 10 	movl   $0xf0106b64,0x8(%esp)
f0100c3a:	f0 
f0100c3b:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0100c42:	00 
f0100c43:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0100c4a:	e8 f1 f3 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100c4f:	c1 ea 0c             	shr    $0xc,%edx
f0100c52:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100c58:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100c5f:	89 c2                	mov    %eax,%edx
f0100c61:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100c64:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c69:	85 d2                	test   %edx,%edx
f0100c6b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100c70:	0f 44 c2             	cmove  %edx,%eax
f0100c73:	c3                   	ret    
		return ~0;
f0100c74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100c79:	c3                   	ret    

f0100c7a <check_page_free_list>:
{
f0100c7a:	55                   	push   %ebp
f0100c7b:	89 e5                	mov    %esp,%ebp
f0100c7d:	57                   	push   %edi
f0100c7e:	56                   	push   %esi
f0100c7f:	53                   	push   %ebx
f0100c80:	83 ec 4c             	sub    $0x4c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c83:	84 c0                	test   %al,%al
f0100c85:	0f 85 3f 03 00 00    	jne    f0100fca <check_page_free_list+0x350>
f0100c8b:	e9 4c 03 00 00       	jmp    f0100fdc <check_page_free_list+0x362>
		panic("'page_free_list' is a null pointer!");
f0100c90:	c7 44 24 08 d4 70 10 	movl   $0xf01070d4,0x8(%esp)
f0100c97:	f0 
f0100c98:	c7 44 24 04 4e 02 00 	movl   $0x24e,0x4(%esp)
f0100c9f:	00 
f0100ca0:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0100ca7:	e8 94 f3 ff ff       	call   f0100040 <_panic>
		struct PageInfo **tp[2] = {&pp1, &pp2};
f0100cac:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100caf:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100cb2:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100cb5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100cb8:	89 c2                	mov    %eax,%edx
f0100cba:	2b 15 90 9e 1e f0    	sub    0xf01e9e90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100cc0:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100cc6:	0f 95 c2             	setne  %dl
f0100cc9:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100ccc:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100cd0:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100cd2:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link)
f0100cd6:	8b 00                	mov    (%eax),%eax
f0100cd8:	85 c0                	test   %eax,%eax
f0100cda:	75 dc                	jne    f0100cb8 <check_page_free_list+0x3e>
		*tp[1] = 0;
f0100cdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cdf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ce5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ce8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ceb:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100ced:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100cf0:	a3 40 92 1e f0       	mov    %eax,0xf01e9240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cf5:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100cfa:	8b 1d 40 92 1e f0    	mov    0xf01e9240,%ebx
f0100d00:	eb 63                	jmp    f0100d65 <check_page_free_list+0xeb>
f0100d02:	89 d8                	mov    %ebx,%eax
f0100d04:	2b 05 90 9e 1e f0    	sub    0xf01e9e90,%eax
f0100d0a:	c1 f8 03             	sar    $0x3,%eax
f0100d0d:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100d10:	89 c2                	mov    %eax,%edx
f0100d12:	c1 ea 16             	shr    $0x16,%edx
f0100d15:	39 f2                	cmp    %esi,%edx
f0100d17:	73 4a                	jae    f0100d63 <check_page_free_list+0xe9>
	if (PGNUM(pa) >= npages)
f0100d19:	89 c2                	mov    %eax,%edx
f0100d1b:	c1 ea 0c             	shr    $0xc,%edx
f0100d1e:	3b 15 88 9e 1e f0    	cmp    0xf01e9e88,%edx
f0100d24:	72 20                	jb     f0100d46 <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d26:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d2a:	c7 44 24 08 64 6b 10 	movl   $0xf0106b64,0x8(%esp)
f0100d31:	f0 
f0100d32:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100d39:	00 
f0100d3a:	c7 04 24 c5 7a 10 f0 	movl   $0xf0107ac5,(%esp)
f0100d41:	e8 fa f2 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100d46:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100d4d:	00 
f0100d4e:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100d55:	00 
	return (void *)(pa + KERNBASE);
f0100d56:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d5b:	89 04 24             	mov    %eax,(%esp)
f0100d5e:	e8 b4 50 00 00       	call   f0105e17 <memset>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d63:	8b 1b                	mov    (%ebx),%ebx
f0100d65:	85 db                	test   %ebx,%ebx
f0100d67:	75 99                	jne    f0100d02 <check_page_free_list+0x88>
	first_free_page = (char *)boot_alloc(0);
f0100d69:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d6e:	e8 e8 fd ff ff       	call   f0100b5b <boot_alloc>
f0100d73:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d76:	8b 15 40 92 1e f0    	mov    0xf01e9240,%edx
		assert(pp >= pages);
f0100d7c:	8b 0d 90 9e 1e f0    	mov    0xf01e9e90,%ecx
		assert(pp < pages + npages);
f0100d82:	a1 88 9e 1e f0       	mov    0xf01e9e88,%eax
f0100d87:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100d8a:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100d8d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0100d90:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100d93:	bf 00 00 00 00       	mov    $0x0,%edi
f0100d98:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d9b:	e9 c4 01 00 00       	jmp    f0100f64 <check_page_free_list+0x2ea>
		assert(pp >= pages);
f0100da0:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100da3:	73 24                	jae    f0100dc9 <check_page_free_list+0x14f>
f0100da5:	c7 44 24 0c d3 7a 10 	movl   $0xf0107ad3,0xc(%esp)
f0100dac:	f0 
f0100dad:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0100db4:	f0 
f0100db5:	c7 44 24 04 6b 02 00 	movl   $0x26b,0x4(%esp)
f0100dbc:	00 
f0100dbd:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0100dc4:	e8 77 f2 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100dc9:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100dcc:	72 24                	jb     f0100df2 <check_page_free_list+0x178>
f0100dce:	c7 44 24 0c f4 7a 10 	movl   $0xf0107af4,0xc(%esp)
f0100dd5:	f0 
f0100dd6:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0100ddd:	f0 
f0100dde:	c7 44 24 04 6c 02 00 	movl   $0x26c,0x4(%esp)
f0100de5:	00 
f0100de6:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0100ded:	e8 4e f2 ff ff       	call   f0100040 <_panic>
		assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0100df2:	89 d0                	mov    %edx,%eax
f0100df4:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0100df7:	a8 07                	test   $0x7,%al
f0100df9:	74 24                	je     f0100e1f <check_page_free_list+0x1a5>
f0100dfb:	c7 44 24 0c f8 70 10 	movl   $0xf01070f8,0xc(%esp)
f0100e02:	f0 
f0100e03:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0100e0a:	f0 
f0100e0b:	c7 44 24 04 6d 02 00 	movl   $0x26d,0x4(%esp)
f0100e12:	00 
f0100e13:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0100e1a:	e8 21 f2 ff ff       	call   f0100040 <_panic>
	return (pp - pages) << PGSHIFT;
f0100e1f:	c1 f8 03             	sar    $0x3,%eax
f0100e22:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100e25:	85 c0                	test   %eax,%eax
f0100e27:	75 24                	jne    f0100e4d <check_page_free_list+0x1d3>
f0100e29:	c7 44 24 0c 08 7b 10 	movl   $0xf0107b08,0xc(%esp)
f0100e30:	f0 
f0100e31:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0100e38:	f0 
f0100e39:	c7 44 24 04 70 02 00 	movl   $0x270,0x4(%esp)
f0100e40:	00 
f0100e41:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0100e48:	e8 f3 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e4d:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e52:	75 24                	jne    f0100e78 <check_page_free_list+0x1fe>
f0100e54:	c7 44 24 0c 19 7b 10 	movl   $0xf0107b19,0xc(%esp)
f0100e5b:	f0 
f0100e5c:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0100e63:	f0 
f0100e64:	c7 44 24 04 71 02 00 	movl   $0x271,0x4(%esp)
f0100e6b:	00 
f0100e6c:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0100e73:	e8 c8 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e78:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100e7d:	75 24                	jne    f0100ea3 <check_page_free_list+0x229>
f0100e7f:	c7 44 24 0c 28 71 10 	movl   $0xf0107128,0xc(%esp)
f0100e86:	f0 
f0100e87:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0100e8e:	f0 
f0100e8f:	c7 44 24 04 72 02 00 	movl   $0x272,0x4(%esp)
f0100e96:	00 
f0100e97:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0100e9e:	e8 9d f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ea3:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100ea8:	75 24                	jne    f0100ece <check_page_free_list+0x254>
f0100eaa:	c7 44 24 0c 32 7b 10 	movl   $0xf0107b32,0xc(%esp)
f0100eb1:	f0 
f0100eb2:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0100eb9:	f0 
f0100eba:	c7 44 24 04 73 02 00 	movl   $0x273,0x4(%esp)
f0100ec1:	00 
f0100ec2:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0100ec9:	e8 72 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f0100ece:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ed3:	0f 86 2a 01 00 00    	jbe    f0101003 <check_page_free_list+0x389>
	if (PGNUM(pa) >= npages)
f0100ed9:	89 c1                	mov    %eax,%ecx
f0100edb:	c1 e9 0c             	shr    $0xc,%ecx
f0100ede:	39 4d c4             	cmp    %ecx,-0x3c(%ebp)
f0100ee1:	77 20                	ja     f0100f03 <check_page_free_list+0x289>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ee3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ee7:	c7 44 24 08 64 6b 10 	movl   $0xf0106b64,0x8(%esp)
f0100eee:	f0 
f0100eef:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100ef6:	00 
f0100ef7:	c7 04 24 c5 7a 10 f0 	movl   $0xf0107ac5,(%esp)
f0100efe:	e8 3d f1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100f03:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
f0100f09:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100f0c:	0f 86 e1 00 00 00    	jbe    f0100ff3 <check_page_free_list+0x379>
f0100f12:	c7 44 24 0c 4c 71 10 	movl   $0xf010714c,0xc(%esp)
f0100f19:	f0 
f0100f1a:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0100f21:	f0 
f0100f22:	c7 44 24 04 74 02 00 	movl   $0x274,0x4(%esp)
f0100f29:	00 
f0100f2a:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0100f31:	e8 0a f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100f36:	c7 44 24 0c 4c 7b 10 	movl   $0xf0107b4c,0xc(%esp)
f0100f3d:	f0 
f0100f3e:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0100f45:	f0 
f0100f46:	c7 44 24 04 76 02 00 	movl   $0x276,0x4(%esp)
f0100f4d:	00 
f0100f4e:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0100f55:	e8 e6 f0 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100f5a:	83 c3 01             	add    $0x1,%ebx
f0100f5d:	eb 03                	jmp    f0100f62 <check_page_free_list+0x2e8>
			++nfree_extmem;
f0100f5f:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f62:	8b 12                	mov    (%edx),%edx
f0100f64:	85 d2                	test   %edx,%edx
f0100f66:	0f 85 34 fe ff ff    	jne    f0100da0 <check_page_free_list+0x126>
	assert(nfree_basemem > 0);
f0100f6c:	85 db                	test   %ebx,%ebx
f0100f6e:	7f 24                	jg     f0100f94 <check_page_free_list+0x31a>
f0100f70:	c7 44 24 0c 69 7b 10 	movl   $0xf0107b69,0xc(%esp)
f0100f77:	f0 
f0100f78:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0100f7f:	f0 
f0100f80:	c7 44 24 04 7e 02 00 	movl   $0x27e,0x4(%esp)
f0100f87:	00 
f0100f88:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0100f8f:	e8 ac f0 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100f94:	85 ff                	test   %edi,%edi
f0100f96:	7f 24                	jg     f0100fbc <check_page_free_list+0x342>
f0100f98:	c7 44 24 0c 7b 7b 10 	movl   $0xf0107b7b,0xc(%esp)
f0100f9f:	f0 
f0100fa0:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0100fa7:	f0 
f0100fa8:	c7 44 24 04 7f 02 00 	movl   $0x27f,0x4(%esp)
f0100faf:	00 
f0100fb0:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0100fb7:	e8 84 f0 ff ff       	call   f0100040 <_panic>
	cprintf("check_page_free_list() succeeded!\n");
f0100fbc:	c7 04 24 90 71 10 f0 	movl   $0xf0107190,(%esp)
f0100fc3:	e8 21 2f 00 00       	call   f0103ee9 <cprintf>
f0100fc8:	eb 4b                	jmp    f0101015 <check_page_free_list+0x39b>
	if (!page_free_list)
f0100fca:	a1 40 92 1e f0       	mov    0xf01e9240,%eax
f0100fcf:	85 c0                	test   %eax,%eax
f0100fd1:	0f 85 d5 fc ff ff    	jne    f0100cac <check_page_free_list+0x32>
f0100fd7:	e9 b4 fc ff ff       	jmp    f0100c90 <check_page_free_list+0x16>
f0100fdc:	83 3d 40 92 1e f0 00 	cmpl   $0x0,0xf01e9240
f0100fe3:	0f 84 a7 fc ff ff    	je     f0100c90 <check_page_free_list+0x16>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100fe9:	be 00 04 00 00       	mov    $0x400,%esi
f0100fee:	e9 07 fd ff ff       	jmp    f0100cfa <check_page_free_list+0x80>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100ff3:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100ff8:	0f 85 61 ff ff ff    	jne    f0100f5f <check_page_free_list+0x2e5>
f0100ffe:	e9 33 ff ff ff       	jmp    f0100f36 <check_page_free_list+0x2bc>
f0101003:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101008:	0f 85 4c ff ff ff    	jne    f0100f5a <check_page_free_list+0x2e0>
f010100e:	66 90                	xchg   %ax,%ax
f0101010:	e9 21 ff ff ff       	jmp    f0100f36 <check_page_free_list+0x2bc>
}
f0101015:	83 c4 4c             	add    $0x4c,%esp
f0101018:	5b                   	pop    %ebx
f0101019:	5e                   	pop    %esi
f010101a:	5f                   	pop    %edi
f010101b:	5d                   	pop    %ebp
f010101c:	c3                   	ret    

f010101d <page_init>:
{
f010101d:	55                   	push   %ebp
f010101e:	89 e5                	mov    %esp,%ebp
f0101020:	57                   	push   %edi
f0101021:	56                   	push   %esi
f0101022:	53                   	push   %ebx
f0101023:	83 ec 1c             	sub    $0x1c,%esp
	page_free_list = NULL; // page_free_list是static的，不会被初始化，必须给一个初始值
f0101026:	c7 05 40 92 1e f0 00 	movl   $0x0,0xf01e9240
f010102d:	00 00 00 
	if (PGNUM(pa) >= npages)
f0101030:	83 3d 88 9e 1e f0 07 	cmpl   $0x7,0xf01e9e88
f0101037:	77 1c                	ja     f0101055 <page_init+0x38>
		panic("pa2page called with invalid pa");
f0101039:	c7 44 24 08 b4 71 10 	movl   $0xf01071b4,0x8(%esp)
f0101040:	f0 
f0101041:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101048:	00 
f0101049:	c7 04 24 c5 7a 10 f0 	movl   $0xf0107ac5,(%esp)
f0101050:	e8 eb ef ff ff       	call   f0100040 <_panic>
	struct PageInfo *mp_entry_page = pa2page(MPENTRY_PADDR); // mp的入口程序只需要一页
f0101055:	a1 90 9e 1e f0       	mov    0xf01e9e90,%eax
f010105a:	8d 78 38             	lea    0x38(%eax),%edi
	for (int i = 1; i < npages_basemem; i++) // 将内存中的pages数组初始化为链表，头指针是page_free_list
f010105d:	8b 35 44 92 1e f0    	mov    0xf01e9244,%esi
f0101063:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101068:	b8 01 00 00 00       	mov    $0x1,%eax
f010106d:	eb 2d                	jmp    f010109c <page_init+0x7f>
f010106f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		if (pages + i == mp_entry_page)
f0101076:	89 d1                	mov    %edx,%ecx
f0101078:	03 0d 90 9e 1e f0    	add    0xf01e9e90,%ecx
f010107e:	39 f9                	cmp    %edi,%ecx
f0101080:	74 17                	je     f0101099 <page_init+0x7c>
		pages[i].pp_ref = 0;
f0101082:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0101088:	8b 0d 90 9e 1e f0    	mov    0xf01e9e90,%ecx
f010108e:	89 1c c1             	mov    %ebx,(%ecx,%eax,8)
		page_free_list = &pages[i]; // pages中包含了整个内存中的页，page_free_list指向其中空闲的页组成的链表的头部
f0101091:	03 15 90 9e 1e f0    	add    0xf01e9e90,%edx
f0101097:	89 d3                	mov    %edx,%ebx
	for (int i = 1; i < npages_basemem; i++) // 将内存中的pages数组初始化为链表，头指针是page_free_list
f0101099:	83 c0 01             	add    $0x1,%eax
f010109c:	39 c6                	cmp    %eax,%esi
f010109e:	77 cf                	ja     f010106f <page_init+0x52>
f01010a0:	89 1d 40 92 1e f0    	mov    %ebx,0xf01e9240
	for (int i = PGNUM(PADDR(boot_alloc(0))); i < npages; i++) // PADDR()将虚拟地址转化为物理地址，boot_alloc(0)得到nextfree的位置(即pages end),PGNUM()求出需要几页才能到达该地址
f01010a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01010ab:	e8 ab fa ff ff       	call   f0100b5b <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f01010b0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01010b5:	77 20                	ja     f01010d7 <page_init+0xba>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01010b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01010bb:	c7 44 24 08 88 6b 10 	movl   $0xf0106b88,0x8(%esp)
f01010c2:	f0 
f01010c3:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
f01010ca:	00 
f01010cb:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01010d2:	e8 69 ef ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01010d7:	05 00 00 00 10       	add    $0x10000000,%eax
f01010dc:	c1 e8 0c             	shr    $0xc,%eax
f01010df:	89 c2                	mov    %eax,%edx
f01010e1:	8b 1d 40 92 1e f0    	mov    0xf01e9240,%ebx
f01010e7:	c1 e0 03             	shl    $0x3,%eax
f01010ea:	eb 1e                	jmp    f010110a <page_init+0xed>
		pages[i].pp_ref = 0;
f01010ec:	89 c1                	mov    %eax,%ecx
f01010ee:	03 0d 90 9e 1e f0    	add    0xf01e9e90,%ecx
f01010f4:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f01010fa:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f01010fc:	89 c3                	mov    %eax,%ebx
f01010fe:	03 1d 90 9e 1e f0    	add    0xf01e9e90,%ebx
	for (int i = PGNUM(PADDR(boot_alloc(0))); i < npages; i++) // PADDR()将虚拟地址转化为物理地址，boot_alloc(0)得到nextfree的位置(即pages end),PGNUM()求出需要几页才能到达该地址
f0101104:	83 c2 01             	add    $0x1,%edx
f0101107:	83 c0 08             	add    $0x8,%eax
f010110a:	3b 15 88 9e 1e f0    	cmp    0xf01e9e88,%edx
f0101110:	72 da                	jb     f01010ec <page_init+0xcf>
f0101112:	89 1d 40 92 1e f0    	mov    %ebx,0xf01e9240
}
f0101118:	83 c4 1c             	add    $0x1c,%esp
f010111b:	5b                   	pop    %ebx
f010111c:	5e                   	pop    %esi
f010111d:	5f                   	pop    %edi
f010111e:	5d                   	pop    %ebp
f010111f:	c3                   	ret    

f0101120 <page_alloc>:
{
f0101120:	55                   	push   %ebp
f0101121:	89 e5                	mov    %esp,%ebp
f0101123:	53                   	push   %ebx
f0101124:	83 ec 14             	sub    $0x14,%esp
	if (page_free_list) // page_free_list指向空闲页组成的链表的头部
f0101127:	8b 1d 40 92 1e f0    	mov    0xf01e9240,%ebx
f010112d:	85 db                	test   %ebx,%ebx
f010112f:	74 75                	je     f01011a6 <page_alloc+0x86>
		page_free_list = page_free_list->pp_link; // 链表next行进
f0101131:	8b 03                	mov    (%ebx),%eax
f0101133:	a3 40 92 1e f0       	mov    %eax,0xf01e9240
		if (alloc_flags & ALLOC_ZERO)
f0101138:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010113c:	74 58                	je     f0101196 <page_alloc+0x76>
	return (pp - pages) << PGSHIFT;
f010113e:	89 d8                	mov    %ebx,%eax
f0101140:	2b 05 90 9e 1e f0    	sub    0xf01e9e90,%eax
f0101146:	c1 f8 03             	sar    $0x3,%eax
f0101149:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010114c:	89 c2                	mov    %eax,%edx
f010114e:	c1 ea 0c             	shr    $0xc,%edx
f0101151:	3b 15 88 9e 1e f0    	cmp    0xf01e9e88,%edx
f0101157:	72 20                	jb     f0101179 <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101159:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010115d:	c7 44 24 08 64 6b 10 	movl   $0xf0106b64,0x8(%esp)
f0101164:	f0 
f0101165:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010116c:	00 
f010116d:	c7 04 24 c5 7a 10 f0 	movl   $0xf0107ac5,(%esp)
f0101174:	e8 c7 ee ff ff       	call   f0100040 <_panic>
			memset(page2kva(result), 0, PGSIZE); // page2kva(p)：求得页p的地址，方法就是先求出p的索引i，用i*4096得到地址
f0101179:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101180:	00 
f0101181:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101188:	00 
	return (void *)(pa + KERNBASE);
f0101189:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010118e:	89 04 24             	mov    %eax,(%esp)
f0101191:	e8 81 4c 00 00       	call   f0105e17 <memset>
		result->pp_ref = 0;
f0101196:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
		result->pp_link = NULL; // 确保page_free就可以检查错误
f010119c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return result;
f01011a2:	89 d8                	mov    %ebx,%eax
f01011a4:	eb 05                	jmp    f01011ab <page_alloc+0x8b>
		return NULL;
f01011a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01011ab:	83 c4 14             	add    $0x14,%esp
f01011ae:	5b                   	pop    %ebx
f01011af:	5d                   	pop    %ebp
f01011b0:	c3                   	ret    

f01011b1 <page_free>:
{
f01011b1:	55                   	push   %ebp
f01011b2:	89 e5                	mov    %esp,%ebp
f01011b4:	83 ec 18             	sub    $0x18,%esp
f01011b7:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref != 0 || pp->pp_link != NULL) // 还有人在使用这个page时，调用了释放函数
f01011ba:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01011bf:	75 05                	jne    f01011c6 <page_free+0x15>
f01011c1:	83 38 00             	cmpl   $0x0,(%eax)
f01011c4:	74 1c                	je     f01011e2 <page_free+0x31>
		panic("can't free this page, this page is in used: page_free() in pmap.c \n");
f01011c6:	c7 44 24 08 d4 71 10 	movl   $0xf01071d4,0x8(%esp)
f01011cd:	f0 
f01011ce:	c7 44 24 04 65 01 00 	movl   $0x165,0x4(%esp)
f01011d5:	00 
f01011d6:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01011dd:	e8 5e ee ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f01011e2:	8b 15 40 92 1e f0    	mov    0xf01e9240,%edx
f01011e8:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f01011ea:	a3 40 92 1e f0       	mov    %eax,0xf01e9240
}
f01011ef:	c9                   	leave  
f01011f0:	c3                   	ret    

f01011f1 <page_decref>:
{
f01011f1:	55                   	push   %ebp
f01011f2:	89 e5                	mov    %esp,%ebp
f01011f4:	83 ec 18             	sub    $0x18,%esp
f01011f7:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01011fa:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f01011fe:	8d 51 ff             	lea    -0x1(%ecx),%edx
f0101201:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101205:	66 85 d2             	test   %dx,%dx
f0101208:	75 08                	jne    f0101212 <page_decref+0x21>
		page_free(pp);
f010120a:	89 04 24             	mov    %eax,(%esp)
f010120d:	e8 9f ff ff ff       	call   f01011b1 <page_free>
}
f0101212:	c9                   	leave  
f0101213:	c3                   	ret    

f0101214 <pgdir_walk>:
{
f0101214:	55                   	push   %ebp
f0101215:	89 e5                	mov    %esp,%ebp
f0101217:	56                   	push   %esi
f0101218:	53                   	push   %ebx
f0101219:	83 ec 10             	sub    $0x10,%esp
f010121c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pde_t *pde = &pgdir[PDX(va)]; // 先由PDX(va)得到该地址对应的目录索引，并在目录中索引得到对应条目(一个32位地址),解引用pde即可得到对应条目
f010121f:	89 de                	mov    %ebx,%esi
f0101221:	c1 ee 16             	shr    $0x16,%esi
f0101224:	c1 e6 02             	shl    $0x2,%esi
f0101227:	03 75 08             	add    0x8(%ebp),%esi
	if (*pde & PTE_P) // 当“va”的PTE所在的页存在，该页对应的条目在目录中的值就!=0
f010122a:	8b 06                	mov    (%esi),%eax
f010122c:	a8 01                	test   $0x1,%al
f010122e:	74 47                	je     f0101277 <pgdir_walk+0x63>
		pte_tab = (pte_t *)KADDR(PTE_ADDR(*pde)); // PTE_ADDR()获得该条目对应的页的物理地址，KADDR()把物理地址转为虚拟地址
f0101230:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101235:	89 c2                	mov    %eax,%edx
f0101237:	c1 ea 0c             	shr    $0xc,%edx
f010123a:	3b 15 88 9e 1e f0    	cmp    0xf01e9e88,%edx
f0101240:	72 20                	jb     f0101262 <pgdir_walk+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101242:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101246:	c7 44 24 08 64 6b 10 	movl   $0xf0106b64,0x8(%esp)
f010124d:	f0 
f010124e:	c7 44 24 04 80 01 00 	movl   $0x180,0x4(%esp)
f0101255:	00 
f0101256:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f010125d:	e8 de ed ff ff       	call   f0100040 <_panic>
		result = &pte_tab[PTX(va)];				  // 页里存的就是PTE表，用PTX(va)得到页索引，索引到对应的pte的地址
f0101262:	c1 eb 0a             	shr    $0xa,%ebx
f0101265:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f010126b:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0101272:	e9 85 00 00 00       	jmp    f01012fc <pgdir_walk+0xe8>
		if (!create)
f0101277:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010127b:	74 73                	je     f01012f0 <pgdir_walk+0xdc>
		struct PageInfo *pp = page_alloc(ALLOC_ZERO); // 分配新的一页来存储PTE表
f010127d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101284:	e8 97 fe ff ff       	call   f0101120 <page_alloc>
		if (!pp) // 如果pp == NULL，分配失败
f0101289:	85 c0                	test   %eax,%eax
f010128b:	74 6a                	je     f01012f7 <pgdir_walk+0xe3>
	return (pp - pages) << PGSHIFT;
f010128d:	89 c2                	mov    %eax,%edx
f010128f:	2b 15 90 9e 1e f0    	sub    0xf01e9e90,%edx
f0101295:	c1 fa 03             	sar    $0x3,%edx
f0101298:	c1 e2 0c             	shl    $0xc,%edx
		*pde = page2pa(pp) | PTE_P | PTE_W | PTE_U; // 更新目录的条目，以指向新分配的页
f010129b:	83 ca 07             	or     $0x7,%edx
f010129e:	89 16                	mov    %edx,(%esi)
		pp->pp_ref++;
f01012a0:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f01012a5:	2b 05 90 9e 1e f0    	sub    0xf01e9e90,%eax
f01012ab:	c1 f8 03             	sar    $0x3,%eax
f01012ae:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01012b1:	89 c2                	mov    %eax,%edx
f01012b3:	c1 ea 0c             	shr    $0xc,%edx
f01012b6:	3b 15 88 9e 1e f0    	cmp    0xf01e9e88,%edx
f01012bc:	72 20                	jb     f01012de <pgdir_walk+0xca>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012be:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01012c2:	c7 44 24 08 64 6b 10 	movl   $0xf0106b64,0x8(%esp)
f01012c9:	f0 
f01012ca:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01012d1:	00 
f01012d2:	c7 04 24 c5 7a 10 f0 	movl   $0xf0107ac5,(%esp)
f01012d9:	e8 62 ed ff ff       	call   f0100040 <_panic>
		result = &pte_tab[PTX(va)];
f01012de:	c1 eb 0a             	shr    $0xa,%ebx
f01012e1:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f01012e7:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f01012ee:	eb 0c                	jmp    f01012fc <pgdir_walk+0xe8>
			return NULL;
f01012f0:	b8 00 00 00 00       	mov    $0x0,%eax
f01012f5:	eb 05                	jmp    f01012fc <pgdir_walk+0xe8>
			return NULL;
f01012f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01012fc:	83 c4 10             	add    $0x10,%esp
f01012ff:	5b                   	pop    %ebx
f0101300:	5e                   	pop    %esi
f0101301:	5d                   	pop    %ebp
f0101302:	c3                   	ret    

f0101303 <page_lookup>:
{
f0101303:	55                   	push   %ebp
f0101304:	89 e5                	mov    %esp,%ebp
f0101306:	53                   	push   %ebx
f0101307:	83 ec 14             	sub    $0x14,%esp
f010130a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0); // 得到“va”的PTE的指针
f010130d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101314:	00 
f0101315:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101318:	89 44 24 04          	mov    %eax,0x4(%esp)
f010131c:	8b 45 08             	mov    0x8(%ebp),%eax
f010131f:	89 04 24             	mov    %eax,(%esp)
f0101322:	e8 ed fe ff ff       	call   f0101214 <pgdir_walk>
	if (pte == NULL)					   // 若PTE不存在，则“va”没有映射到对应的物理地址
f0101327:	85 c0                	test   %eax,%eax
f0101329:	74 3a                	je     f0101365 <page_lookup+0x62>
	if (pte_store)
f010132b:	85 db                	test   %ebx,%ebx
f010132d:	74 02                	je     f0101331 <page_lookup+0x2e>
		*pte_store = pte;
f010132f:	89 03                	mov    %eax,(%ebx)
	return pa2page(PTE_ADDR(*pte)); // PTE_ADDR(*pte)：根据pte得到物理地址，pa2page()：根据物理地址得到页面
f0101331:	8b 00                	mov    (%eax),%eax
	if (PGNUM(pa) >= npages)
f0101333:	c1 e8 0c             	shr    $0xc,%eax
f0101336:	3b 05 88 9e 1e f0    	cmp    0xf01e9e88,%eax
f010133c:	72 1c                	jb     f010135a <page_lookup+0x57>
		panic("pa2page called with invalid pa");
f010133e:	c7 44 24 08 b4 71 10 	movl   $0xf01071b4,0x8(%esp)
f0101345:	f0 
f0101346:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f010134d:	00 
f010134e:	c7 04 24 c5 7a 10 f0 	movl   $0xf0107ac5,(%esp)
f0101355:	e8 e6 ec ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010135a:	8b 15 90 9e 1e f0    	mov    0xf01e9e90,%edx
f0101360:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0101363:	eb 05                	jmp    f010136a <page_lookup+0x67>
		return NULL;
f0101365:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010136a:	83 c4 14             	add    $0x14,%esp
f010136d:	5b                   	pop    %ebx
f010136e:	5d                   	pop    %ebp
f010136f:	c3                   	ret    

f0101370 <tlb_invalidate>:
{
f0101370:	55                   	push   %ebp
f0101371:	89 e5                	mov    %esp,%ebp
f0101373:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f0101376:	e8 ee 50 00 00       	call   f0106469 <cpunum>
f010137b:	6b c0 74             	imul   $0x74,%eax,%eax
f010137e:	83 b8 28 a0 1e f0 00 	cmpl   $0x0,-0xfe15fd8(%eax)
f0101385:	74 16                	je     f010139d <tlb_invalidate+0x2d>
f0101387:	e8 dd 50 00 00       	call   f0106469 <cpunum>
f010138c:	6b c0 74             	imul   $0x74,%eax,%eax
f010138f:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f0101395:	8b 55 08             	mov    0x8(%ebp),%edx
f0101398:	39 50 60             	cmp    %edx,0x60(%eax)
f010139b:	75 06                	jne    f01013a3 <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010139d:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013a0:	0f 01 38             	invlpg (%eax)
}
f01013a3:	c9                   	leave  
f01013a4:	c3                   	ret    

f01013a5 <boot_map_region>:
{
f01013a5:	55                   	push   %ebp
f01013a6:	89 e5                	mov    %esp,%ebp
f01013a8:	57                   	push   %edi
f01013a9:	56                   	push   %esi
f01013aa:	53                   	push   %ebx
f01013ab:	83 ec 2c             	sub    $0x2c,%esp
f01013ae:	89 c7                	mov    %eax,%edi
f01013b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01013b3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (int i = 0; i < size; i += PGSIZE) // 以页为单位操作映射
f01013b6:	bb 00 00 00 00       	mov    $0x0,%ebx
		*pte = (pa + i) | PTE_P | perm;							 // 物理地址写入PTE,完成映射
f01013bb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013be:	83 c8 01             	or     $0x1,%eax
f01013c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (int i = 0; i < size; i += PGSIZE) // 以页为单位操作映射
f01013c4:	eb 36                	jmp    f01013fc <boot_map_region+0x57>
f01013c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01013c9:	8d 34 18             	lea    (%eax,%ebx,1),%esi
		tlb_invalidate(pgdir, (void *)va + i);					 // 使TLB无效
f01013cc:	89 74 24 04          	mov    %esi,0x4(%esp)
f01013d0:	89 3c 24             	mov    %edi,(%esp)
f01013d3:	e8 98 ff ff ff       	call   f0101370 <tlb_invalidate>
		pte_t *pte = pgdir_walk(pgdir, (const void *)va + i, 1); // 得到虚拟地址对应的pte
f01013d8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01013df:	00 
f01013e0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01013e4:	89 3c 24             	mov    %edi,(%esp)
f01013e7:	e8 28 fe ff ff       	call   f0101214 <pgdir_walk>
f01013ec:	89 da                	mov    %ebx,%edx
f01013ee:	03 55 08             	add    0x8(%ebp),%edx
		*pte = (pa + i) | PTE_P | perm;							 // 物理地址写入PTE,完成映射
f01013f1:	0b 55 dc             	or     -0x24(%ebp),%edx
f01013f4:	89 10                	mov    %edx,(%eax)
	for (int i = 0; i < size; i += PGSIZE) // 以页为单位操作映射
f01013f6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01013fc:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f01013ff:	77 c5                	ja     f01013c6 <boot_map_region+0x21>
}
f0101401:	83 c4 2c             	add    $0x2c,%esp
f0101404:	5b                   	pop    %ebx
f0101405:	5e                   	pop    %esi
f0101406:	5f                   	pop    %edi
f0101407:	5d                   	pop    %ebp
f0101408:	c3                   	ret    

f0101409 <page_remove>:
{
f0101409:	55                   	push   %ebp
f010140a:	89 e5                	mov    %esp,%ebp
f010140c:	56                   	push   %esi
f010140d:	53                   	push   %ebx
f010140e:	83 ec 20             	sub    $0x20,%esp
f0101411:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101414:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store); // 得到“va”对应的页面，和指向对应的pte的指针pte_store
f0101417:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010141a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010141e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101422:	89 1c 24             	mov    %ebx,(%esp)
f0101425:	e8 d9 fe ff ff       	call   f0101303 <page_lookup>
	if (pp)
f010142a:	85 c0                	test   %eax,%eax
f010142c:	74 1d                	je     f010144b <page_remove+0x42>
		page_decref(pp);
f010142e:	89 04 24             	mov    %eax,(%esp)
f0101431:	e8 bb fd ff ff       	call   f01011f1 <page_decref>
		tlb_invalidate(pgdir, va); // 如果从页表中删除条目，则TLB必须无效
f0101436:	89 74 24 04          	mov    %esi,0x4(%esp)
f010143a:	89 1c 24             	mov    %ebx,(%esp)
f010143d:	e8 2e ff ff ff       	call   f0101370 <tlb_invalidate>
		*pte_store = 0;
f0101442:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101445:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
f010144b:	83 c4 20             	add    $0x20,%esp
f010144e:	5b                   	pop    %ebx
f010144f:	5e                   	pop    %esi
f0101450:	5d                   	pop    %ebp
f0101451:	c3                   	ret    

f0101452 <page_insert>:
{
f0101452:	55                   	push   %ebp
f0101453:	89 e5                	mov    %esp,%ebp
f0101455:	57                   	push   %edi
f0101456:	56                   	push   %esi
f0101457:	53                   	push   %ebx
f0101458:	83 ec 1c             	sub    $0x1c,%esp
f010145b:	8b 75 08             	mov    0x8(%ebp),%esi
f010145e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101461:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1); // 得到pte的指针，create=1,代表有必要会创建新的页
f0101464:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010146b:	00 
f010146c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101470:	89 34 24             	mov    %esi,(%esp)
f0101473:	e8 9c fd ff ff       	call   f0101214 <pgdir_walk>
	if (pte == NULL)
f0101478:	85 c0                	test   %eax,%eax
f010147a:	74 41                	je     f01014bd <page_insert+0x6b>
	pp->pp_ref++;
f010147c:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P)
f0101481:	f6 00 01             	testb  $0x1,(%eax)
f0101484:	74 0c                	je     f0101492 <page_insert+0x40>
		page_remove(pgdir, va);
f0101486:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010148a:	89 34 24             	mov    %esi,(%esp)
f010148d:	e8 77 ff ff ff       	call   f0101409 <page_remove>
	boot_map_region(pgdir, (uintptr_t)va, PGSIZE, page2pa(pp), perm);
f0101492:	8b 45 14             	mov    0x14(%ebp),%eax
f0101495:	89 44 24 04          	mov    %eax,0x4(%esp)
	return (pp - pages) << PGSHIFT;
f0101499:	2b 1d 90 9e 1e f0    	sub    0xf01e9e90,%ebx
f010149f:	c1 fb 03             	sar    $0x3,%ebx
f01014a2:	c1 e3 0c             	shl    $0xc,%ebx
f01014a5:	89 1c 24             	mov    %ebx,(%esp)
f01014a8:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01014ad:	89 fa                	mov    %edi,%edx
f01014af:	89 f0                	mov    %esi,%eax
f01014b1:	e8 ef fe ff ff       	call   f01013a5 <boot_map_region>
	return 0;
f01014b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01014bb:	eb 05                	jmp    f01014c2 <page_insert+0x70>
		return -E_NO_MEM;
f01014bd:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
f01014c2:	83 c4 1c             	add    $0x1c,%esp
f01014c5:	5b                   	pop    %ebx
f01014c6:	5e                   	pop    %esi
f01014c7:	5f                   	pop    %edi
f01014c8:	5d                   	pop    %ebp
f01014c9:	c3                   	ret    

f01014ca <mmio_map_region>:
{
f01014ca:	55                   	push   %ebp
f01014cb:	89 e5                	mov    %esp,%ebp
f01014cd:	53                   	push   %ebx
f01014ce:	83 ec 14             	sub    $0x14,%esp
	size = ROUNDUP(size, PGSIZE);
f01014d1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014d4:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01014da:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base + size > MMIOLIM)
f01014e0:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f01014e6:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f01014e9:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f01014ee:	76 1c                	jbe    f010150c <mmio_map_region+0x42>
		panic("mmio_map_region: out of MMIOLIM!");
f01014f0:	c7 44 24 08 18 72 10 	movl   $0xf0107218,0x8(%esp)
f01014f7:	f0 
f01014f8:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
f01014ff:	00 
f0101500:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101507:	e8 34 eb ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD | PTE_PWT | PTE_W);
f010150c:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101513:	00 
f0101514:	8b 45 08             	mov    0x8(%ebp),%eax
f0101517:	89 04 24             	mov    %eax,(%esp)
f010151a:	89 d9                	mov    %ebx,%ecx
f010151c:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0101521:	e8 7f fe ff ff       	call   f01013a5 <boot_map_region>
	base += size;
f0101526:	a1 00 13 12 f0       	mov    0xf0121300,%eax
f010152b:	01 c3                	add    %eax,%ebx
f010152d:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300
}
f0101533:	83 c4 14             	add    $0x14,%esp
f0101536:	5b                   	pop    %ebx
f0101537:	5d                   	pop    %ebp
f0101538:	c3                   	ret    

f0101539 <mem_init>:
{
f0101539:	55                   	push   %ebp
f010153a:	89 e5                	mov    %esp,%ebp
f010153c:	57                   	push   %edi
f010153d:	56                   	push   %esi
f010153e:	53                   	push   %ebx
f010153f:	83 ec 4c             	sub    $0x4c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f0101542:	b8 15 00 00 00       	mov    $0x15,%eax
f0101547:	e8 e4 f5 ff ff       	call   f0100b30 <nvram_read>
f010154c:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010154e:	b8 17 00 00 00       	mov    $0x17,%eax
f0101553:	e8 d8 f5 ff ff       	call   f0100b30 <nvram_read>
f0101558:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010155a:	b8 34 00 00 00       	mov    $0x34,%eax
f010155f:	e8 cc f5 ff ff       	call   f0100b30 <nvram_read>
f0101564:	c1 e0 06             	shl    $0x6,%eax
f0101567:	89 c2                	mov    %eax,%edx
		totalmem = 16 * 1024 + ext16mem;
f0101569:	8d 80 00 40 00 00    	lea    0x4000(%eax),%eax
	if (ext16mem)
f010156f:	85 d2                	test   %edx,%edx
f0101571:	75 0b                	jne    f010157e <mem_init+0x45>
		totalmem = 1 * 1024 + extmem;
f0101573:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101579:	85 f6                	test   %esi,%esi
f010157b:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f010157e:	89 c2                	mov    %eax,%edx
f0101580:	c1 ea 02             	shr    $0x2,%edx
f0101583:	89 15 88 9e 1e f0    	mov    %edx,0xf01e9e88
	npages_basemem = basemem / (PGSIZE / 1024);
f0101589:	89 da                	mov    %ebx,%edx
f010158b:	c1 ea 02             	shr    $0x2,%edx
f010158e:	89 15 44 92 1e f0    	mov    %edx,0xf01e9244
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101594:	89 c2                	mov    %eax,%edx
f0101596:	29 da                	sub    %ebx,%edx
f0101598:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010159c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01015a0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015a4:	c7 04 24 3c 72 10 f0 	movl   $0xf010723c,(%esp)
f01015ab:	e8 39 29 00 00       	call   f0103ee9 <cprintf>
	kern_pgdir = (pde_t *)boot_alloc(PGSIZE); // 第一次运行，会舍入一部分
f01015b0:	b8 00 10 00 00       	mov    $0x1000,%eax
f01015b5:	e8 a1 f5 ff ff       	call   f0100b5b <boot_alloc>
f01015ba:	a3 8c 9e 1e f0       	mov    %eax,0xf01e9e8c
	memset(kern_pgdir, 0, PGSIZE);			  // 内存初始化为0
f01015bf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01015c6:	00 
f01015c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01015ce:	00 
f01015cf:	89 04 24             	mov    %eax,(%esp)
f01015d2:	e8 40 48 00 00       	call   f0105e17 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P; // 暂时不需要理解，只需要知道kern_pgdir处有一个页表目录
f01015d7:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01015dc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01015e1:	77 20                	ja     f0101603 <mem_init+0xca>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01015e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015e7:	c7 44 24 08 88 6b 10 	movl   $0xf0106b88,0x8(%esp)
f01015ee:	f0 
f01015ef:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
f01015f6:	00 
f01015f7:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01015fe:	e8 3d ea ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101603:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101609:	83 ca 05             	or     $0x5,%edx
f010160c:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *)boot_alloc(npages * sizeof(struct PageInfo)); // sizeof求得PageInfo占多少字节，返回结果记得强转成pages对应的类型
f0101612:	a1 88 9e 1e f0       	mov    0xf01e9e88,%eax
f0101617:	c1 e0 03             	shl    $0x3,%eax
f010161a:	e8 3c f5 ff ff       	call   f0100b5b <boot_alloc>
f010161f:	a3 90 9e 1e f0       	mov    %eax,0xf01e9e90
	memset(pages, 0, npages * sizeof(struct PageInfo));						 // memset(d,c,l):从指针d开始，用字符c填充l个长度的内存
f0101624:	8b 0d 88 9e 1e f0    	mov    0xf01e9e88,%ecx
f010162a:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101631:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101635:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010163c:	00 
f010163d:	89 04 24             	mov    %eax,(%esp)
f0101640:	e8 d2 47 00 00       	call   f0105e17 <memset>
	envs = (struct Env *)boot_alloc(NENV * sizeof(struct Env));
f0101645:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010164a:	e8 0c f5 ff ff       	call   f0100b5b <boot_alloc>
f010164f:	a3 48 92 1e f0       	mov    %eax,0xf01e9248
	page_init(); // 初始化之后，所有的内存管理都将通过page_*函数进行
f0101654:	e8 c4 f9 ff ff       	call   f010101d <page_init>
	check_page_free_list(1);
f0101659:	b8 01 00 00 00       	mov    $0x1,%eax
f010165e:	e8 17 f6 ff ff       	call   f0100c7a <check_page_free_list>
	if (!pages)
f0101663:	83 3d 90 9e 1e f0 00 	cmpl   $0x0,0xf01e9e90
f010166a:	75 1c                	jne    f0101688 <mem_init+0x14f>
		panic("'pages' is a null pointer!");
f010166c:	c7 44 24 08 8c 7b 10 	movl   $0xf0107b8c,0x8(%esp)
f0101673:	f0 
f0101674:	c7 44 24 04 91 02 00 	movl   $0x291,0x4(%esp)
f010167b:	00 
f010167c:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101683:	e8 b8 e9 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101688:	a1 40 92 1e f0       	mov    0xf01e9240,%eax
f010168d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101692:	eb 05                	jmp    f0101699 <mem_init+0x160>
		++nfree;
f0101694:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101697:	8b 00                	mov    (%eax),%eax
f0101699:	85 c0                	test   %eax,%eax
f010169b:	75 f7                	jne    f0101694 <mem_init+0x15b>
	assert((pp0 = page_alloc(0)));
f010169d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016a4:	e8 77 fa ff ff       	call   f0101120 <page_alloc>
f01016a9:	89 c7                	mov    %eax,%edi
f01016ab:	85 c0                	test   %eax,%eax
f01016ad:	75 24                	jne    f01016d3 <mem_init+0x19a>
f01016af:	c7 44 24 0c a7 7b 10 	movl   $0xf0107ba7,0xc(%esp)
f01016b6:	f0 
f01016b7:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01016be:	f0 
f01016bf:	c7 44 24 04 99 02 00 	movl   $0x299,0x4(%esp)
f01016c6:	00 
f01016c7:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01016ce:	e8 6d e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01016d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016da:	e8 41 fa ff ff       	call   f0101120 <page_alloc>
f01016df:	89 c6                	mov    %eax,%esi
f01016e1:	85 c0                	test   %eax,%eax
f01016e3:	75 24                	jne    f0101709 <mem_init+0x1d0>
f01016e5:	c7 44 24 0c bd 7b 10 	movl   $0xf0107bbd,0xc(%esp)
f01016ec:	f0 
f01016ed:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01016f4:	f0 
f01016f5:	c7 44 24 04 9a 02 00 	movl   $0x29a,0x4(%esp)
f01016fc:	00 
f01016fd:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101704:	e8 37 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101709:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101710:	e8 0b fa ff ff       	call   f0101120 <page_alloc>
f0101715:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101718:	85 c0                	test   %eax,%eax
f010171a:	75 24                	jne    f0101740 <mem_init+0x207>
f010171c:	c7 44 24 0c d3 7b 10 	movl   $0xf0107bd3,0xc(%esp)
f0101723:	f0 
f0101724:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f010172b:	f0 
f010172c:	c7 44 24 04 9b 02 00 	movl   $0x29b,0x4(%esp)
f0101733:	00 
f0101734:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f010173b:	e8 00 e9 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101740:	39 f7                	cmp    %esi,%edi
f0101742:	75 24                	jne    f0101768 <mem_init+0x22f>
f0101744:	c7 44 24 0c e9 7b 10 	movl   $0xf0107be9,0xc(%esp)
f010174b:	f0 
f010174c:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101753:	f0 
f0101754:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
f010175b:	00 
f010175c:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101763:	e8 d8 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101768:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010176b:	39 c6                	cmp    %eax,%esi
f010176d:	74 04                	je     f0101773 <mem_init+0x23a>
f010176f:	39 c7                	cmp    %eax,%edi
f0101771:	75 24                	jne    f0101797 <mem_init+0x25e>
f0101773:	c7 44 24 0c 78 72 10 	movl   $0xf0107278,0xc(%esp)
f010177a:	f0 
f010177b:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101782:	f0 
f0101783:	c7 44 24 04 9f 02 00 	movl   $0x29f,0x4(%esp)
f010178a:	00 
f010178b:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101792:	e8 a9 e8 ff ff       	call   f0100040 <_panic>
	return (pp - pages) << PGSHIFT;
f0101797:	8b 15 90 9e 1e f0    	mov    0xf01e9e90,%edx
	assert(page2pa(pp0) < npages * PGSIZE);
f010179d:	a1 88 9e 1e f0       	mov    0xf01e9e88,%eax
f01017a2:	c1 e0 0c             	shl    $0xc,%eax
f01017a5:	89 f9                	mov    %edi,%ecx
f01017a7:	29 d1                	sub    %edx,%ecx
f01017a9:	c1 f9 03             	sar    $0x3,%ecx
f01017ac:	c1 e1 0c             	shl    $0xc,%ecx
f01017af:	39 c1                	cmp    %eax,%ecx
f01017b1:	72 24                	jb     f01017d7 <mem_init+0x29e>
f01017b3:	c7 44 24 0c 98 72 10 	movl   $0xf0107298,0xc(%esp)
f01017ba:	f0 
f01017bb:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01017c2:	f0 
f01017c3:	c7 44 24 04 a0 02 00 	movl   $0x2a0,0x4(%esp)
f01017ca:	00 
f01017cb:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01017d2:	e8 69 e8 ff ff       	call   f0100040 <_panic>
f01017d7:	89 f1                	mov    %esi,%ecx
f01017d9:	29 d1                	sub    %edx,%ecx
f01017db:	c1 f9 03             	sar    $0x3,%ecx
f01017de:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages * PGSIZE);
f01017e1:	39 c8                	cmp    %ecx,%eax
f01017e3:	77 24                	ja     f0101809 <mem_init+0x2d0>
f01017e5:	c7 44 24 0c b8 72 10 	movl   $0xf01072b8,0xc(%esp)
f01017ec:	f0 
f01017ed:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01017f4:	f0 
f01017f5:	c7 44 24 04 a1 02 00 	movl   $0x2a1,0x4(%esp)
f01017fc:	00 
f01017fd:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101804:	e8 37 e8 ff ff       	call   f0100040 <_panic>
f0101809:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010180c:	29 d1                	sub    %edx,%ecx
f010180e:	89 ca                	mov    %ecx,%edx
f0101810:	c1 fa 03             	sar    $0x3,%edx
f0101813:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages * PGSIZE);
f0101816:	39 d0                	cmp    %edx,%eax
f0101818:	77 24                	ja     f010183e <mem_init+0x305>
f010181a:	c7 44 24 0c d8 72 10 	movl   $0xf01072d8,0xc(%esp)
f0101821:	f0 
f0101822:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101829:	f0 
f010182a:	c7 44 24 04 a2 02 00 	movl   $0x2a2,0x4(%esp)
f0101831:	00 
f0101832:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101839:	e8 02 e8 ff ff       	call   f0100040 <_panic>
	fl = page_free_list;
f010183e:	a1 40 92 1e f0       	mov    0xf01e9240,%eax
f0101843:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101846:	c7 05 40 92 1e f0 00 	movl   $0x0,0xf01e9240
f010184d:	00 00 00 
	assert(!page_alloc(0));
f0101850:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101857:	e8 c4 f8 ff ff       	call   f0101120 <page_alloc>
f010185c:	85 c0                	test   %eax,%eax
f010185e:	74 24                	je     f0101884 <mem_init+0x34b>
f0101860:	c7 44 24 0c fb 7b 10 	movl   $0xf0107bfb,0xc(%esp)
f0101867:	f0 
f0101868:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f010186f:	f0 
f0101870:	c7 44 24 04 a9 02 00 	movl   $0x2a9,0x4(%esp)
f0101877:	00 
f0101878:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f010187f:	e8 bc e7 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0101884:	89 3c 24             	mov    %edi,(%esp)
f0101887:	e8 25 f9 ff ff       	call   f01011b1 <page_free>
	page_free(pp1);
f010188c:	89 34 24             	mov    %esi,(%esp)
f010188f:	e8 1d f9 ff ff       	call   f01011b1 <page_free>
	page_free(pp2);
f0101894:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101897:	89 04 24             	mov    %eax,(%esp)
f010189a:	e8 12 f9 ff ff       	call   f01011b1 <page_free>
	assert((pp0 = page_alloc(0)));
f010189f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018a6:	e8 75 f8 ff ff       	call   f0101120 <page_alloc>
f01018ab:	89 c6                	mov    %eax,%esi
f01018ad:	85 c0                	test   %eax,%eax
f01018af:	75 24                	jne    f01018d5 <mem_init+0x39c>
f01018b1:	c7 44 24 0c a7 7b 10 	movl   $0xf0107ba7,0xc(%esp)
f01018b8:	f0 
f01018b9:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01018c0:	f0 
f01018c1:	c7 44 24 04 b0 02 00 	movl   $0x2b0,0x4(%esp)
f01018c8:	00 
f01018c9:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01018d0:	e8 6b e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01018d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018dc:	e8 3f f8 ff ff       	call   f0101120 <page_alloc>
f01018e1:	89 c7                	mov    %eax,%edi
f01018e3:	85 c0                	test   %eax,%eax
f01018e5:	75 24                	jne    f010190b <mem_init+0x3d2>
f01018e7:	c7 44 24 0c bd 7b 10 	movl   $0xf0107bbd,0xc(%esp)
f01018ee:	f0 
f01018ef:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01018f6:	f0 
f01018f7:	c7 44 24 04 b1 02 00 	movl   $0x2b1,0x4(%esp)
f01018fe:	00 
f01018ff:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101906:	e8 35 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010190b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101912:	e8 09 f8 ff ff       	call   f0101120 <page_alloc>
f0101917:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010191a:	85 c0                	test   %eax,%eax
f010191c:	75 24                	jne    f0101942 <mem_init+0x409>
f010191e:	c7 44 24 0c d3 7b 10 	movl   $0xf0107bd3,0xc(%esp)
f0101925:	f0 
f0101926:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f010192d:	f0 
f010192e:	c7 44 24 04 b2 02 00 	movl   $0x2b2,0x4(%esp)
f0101935:	00 
f0101936:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f010193d:	e8 fe e6 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101942:	39 fe                	cmp    %edi,%esi
f0101944:	75 24                	jne    f010196a <mem_init+0x431>
f0101946:	c7 44 24 0c e9 7b 10 	movl   $0xf0107be9,0xc(%esp)
f010194d:	f0 
f010194e:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101955:	f0 
f0101956:	c7 44 24 04 b4 02 00 	movl   $0x2b4,0x4(%esp)
f010195d:	00 
f010195e:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101965:	e8 d6 e6 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010196a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010196d:	39 c7                	cmp    %eax,%edi
f010196f:	74 04                	je     f0101975 <mem_init+0x43c>
f0101971:	39 c6                	cmp    %eax,%esi
f0101973:	75 24                	jne    f0101999 <mem_init+0x460>
f0101975:	c7 44 24 0c 78 72 10 	movl   $0xf0107278,0xc(%esp)
f010197c:	f0 
f010197d:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101984:	f0 
f0101985:	c7 44 24 04 b5 02 00 	movl   $0x2b5,0x4(%esp)
f010198c:	00 
f010198d:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101994:	e8 a7 e6 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101999:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019a0:	e8 7b f7 ff ff       	call   f0101120 <page_alloc>
f01019a5:	85 c0                	test   %eax,%eax
f01019a7:	74 24                	je     f01019cd <mem_init+0x494>
f01019a9:	c7 44 24 0c fb 7b 10 	movl   $0xf0107bfb,0xc(%esp)
f01019b0:	f0 
f01019b1:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01019b8:	f0 
f01019b9:	c7 44 24 04 b6 02 00 	movl   $0x2b6,0x4(%esp)
f01019c0:	00 
f01019c1:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01019c8:	e8 73 e6 ff ff       	call   f0100040 <_panic>
f01019cd:	89 f0                	mov    %esi,%eax
f01019cf:	2b 05 90 9e 1e f0    	sub    0xf01e9e90,%eax
f01019d5:	c1 f8 03             	sar    $0x3,%eax
f01019d8:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01019db:	89 c2                	mov    %eax,%edx
f01019dd:	c1 ea 0c             	shr    $0xc,%edx
f01019e0:	3b 15 88 9e 1e f0    	cmp    0xf01e9e88,%edx
f01019e6:	72 20                	jb     f0101a08 <mem_init+0x4cf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01019ec:	c7 44 24 08 64 6b 10 	movl   $0xf0106b64,0x8(%esp)
f01019f3:	f0 
f01019f4:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01019fb:	00 
f01019fc:	c7 04 24 c5 7a 10 f0 	movl   $0xf0107ac5,(%esp)
f0101a03:	e8 38 e6 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp0), 1, PGSIZE);
f0101a08:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a0f:	00 
f0101a10:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101a17:	00 
	return (void *)(pa + KERNBASE);
f0101a18:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a1d:	89 04 24             	mov    %eax,(%esp)
f0101a20:	e8 f2 43 00 00       	call   f0105e17 <memset>
	page_free(pp0);
f0101a25:	89 34 24             	mov    %esi,(%esp)
f0101a28:	e8 84 f7 ff ff       	call   f01011b1 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101a2d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101a34:	e8 e7 f6 ff ff       	call   f0101120 <page_alloc>
f0101a39:	85 c0                	test   %eax,%eax
f0101a3b:	75 24                	jne    f0101a61 <mem_init+0x528>
f0101a3d:	c7 44 24 0c 0a 7c 10 	movl   $0xf0107c0a,0xc(%esp)
f0101a44:	f0 
f0101a45:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101a4c:	f0 
f0101a4d:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
f0101a54:	00 
f0101a55:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101a5c:	e8 df e5 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101a61:	39 c6                	cmp    %eax,%esi
f0101a63:	74 24                	je     f0101a89 <mem_init+0x550>
f0101a65:	c7 44 24 0c 28 7c 10 	movl   $0xf0107c28,0xc(%esp)
f0101a6c:	f0 
f0101a6d:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101a74:	f0 
f0101a75:	c7 44 24 04 bc 02 00 	movl   $0x2bc,0x4(%esp)
f0101a7c:	00 
f0101a7d:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101a84:	e8 b7 e5 ff ff       	call   f0100040 <_panic>
	return (pp - pages) << PGSHIFT;
f0101a89:	89 f0                	mov    %esi,%eax
f0101a8b:	2b 05 90 9e 1e f0    	sub    0xf01e9e90,%eax
f0101a91:	c1 f8 03             	sar    $0x3,%eax
f0101a94:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101a97:	89 c2                	mov    %eax,%edx
f0101a99:	c1 ea 0c             	shr    $0xc,%edx
f0101a9c:	3b 15 88 9e 1e f0    	cmp    0xf01e9e88,%edx
f0101aa2:	72 20                	jb     f0101ac4 <mem_init+0x58b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101aa4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101aa8:	c7 44 24 08 64 6b 10 	movl   $0xf0106b64,0x8(%esp)
f0101aaf:	f0 
f0101ab0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101ab7:	00 
f0101ab8:	c7 04 24 c5 7a 10 f0 	movl   $0xf0107ac5,(%esp)
f0101abf:	e8 7c e5 ff ff       	call   f0100040 <_panic>
f0101ac4:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101aca:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
		assert(c[i] == 0);
f0101ad0:	80 38 00             	cmpb   $0x0,(%eax)
f0101ad3:	74 24                	je     f0101af9 <mem_init+0x5c0>
f0101ad5:	c7 44 24 0c 38 7c 10 	movl   $0xf0107c38,0xc(%esp)
f0101adc:	f0 
f0101add:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101ae4:	f0 
f0101ae5:	c7 44 24 04 bf 02 00 	movl   $0x2bf,0x4(%esp)
f0101aec:	00 
f0101aed:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101af4:	e8 47 e5 ff ff       	call   f0100040 <_panic>
f0101af9:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101afc:	39 d0                	cmp    %edx,%eax
f0101afe:	75 d0                	jne    f0101ad0 <mem_init+0x597>
	page_free_list = fl;
f0101b00:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b03:	a3 40 92 1e f0       	mov    %eax,0xf01e9240
	page_free(pp0);
f0101b08:	89 34 24             	mov    %esi,(%esp)
f0101b0b:	e8 a1 f6 ff ff       	call   f01011b1 <page_free>
	page_free(pp1);
f0101b10:	89 3c 24             	mov    %edi,(%esp)
f0101b13:	e8 99 f6 ff ff       	call   f01011b1 <page_free>
	page_free(pp2);
f0101b18:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b1b:	89 04 24             	mov    %eax,(%esp)
f0101b1e:	e8 8e f6 ff ff       	call   f01011b1 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b23:	a1 40 92 1e f0       	mov    0xf01e9240,%eax
f0101b28:	eb 05                	jmp    f0101b2f <mem_init+0x5f6>
		--nfree;
f0101b2a:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b2d:	8b 00                	mov    (%eax),%eax
f0101b2f:	85 c0                	test   %eax,%eax
f0101b31:	75 f7                	jne    f0101b2a <mem_init+0x5f1>
	assert(nfree == 0);
f0101b33:	85 db                	test   %ebx,%ebx
f0101b35:	74 24                	je     f0101b5b <mem_init+0x622>
f0101b37:	c7 44 24 0c 42 7c 10 	movl   $0xf0107c42,0xc(%esp)
f0101b3e:	f0 
f0101b3f:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101b46:	f0 
f0101b47:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
f0101b4e:	00 
f0101b4f:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101b56:	e8 e5 e4 ff ff       	call   f0100040 <_panic>
	cprintf("check_page_alloc() succeeded!\n");
f0101b5b:	c7 04 24 f8 72 10 f0 	movl   $0xf01072f8,(%esp)
f0101b62:	e8 82 23 00 00       	call   f0103ee9 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101b67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b6e:	e8 ad f5 ff ff       	call   f0101120 <page_alloc>
f0101b73:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101b76:	85 c0                	test   %eax,%eax
f0101b78:	75 24                	jne    f0101b9e <mem_init+0x665>
f0101b7a:	c7 44 24 0c a7 7b 10 	movl   $0xf0107ba7,0xc(%esp)
f0101b81:	f0 
f0101b82:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101b89:	f0 
f0101b8a:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f0101b91:	00 
f0101b92:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101b99:	e8 a2 e4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ba5:	e8 76 f5 ff ff       	call   f0101120 <page_alloc>
f0101baa:	89 c3                	mov    %eax,%ebx
f0101bac:	85 c0                	test   %eax,%eax
f0101bae:	75 24                	jne    f0101bd4 <mem_init+0x69b>
f0101bb0:	c7 44 24 0c bd 7b 10 	movl   $0xf0107bbd,0xc(%esp)
f0101bb7:	f0 
f0101bb8:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101bbf:	f0 
f0101bc0:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f0101bc7:	00 
f0101bc8:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101bcf:	e8 6c e4 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101bd4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bdb:	e8 40 f5 ff ff       	call   f0101120 <page_alloc>
f0101be0:	89 c6                	mov    %eax,%esi
f0101be2:	85 c0                	test   %eax,%eax
f0101be4:	75 24                	jne    f0101c0a <mem_init+0x6d1>
f0101be6:	c7 44 24 0c d3 7b 10 	movl   $0xf0107bd3,0xc(%esp)
f0101bed:	f0 
f0101bee:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101bf5:	f0 
f0101bf6:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0101bfd:	00 
f0101bfe:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101c05:	e8 36 e4 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c0a:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101c0d:	75 24                	jne    f0101c33 <mem_init+0x6fa>
f0101c0f:	c7 44 24 0c e9 7b 10 	movl   $0xf0107be9,0xc(%esp)
f0101c16:	f0 
f0101c17:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101c1e:	f0 
f0101c1f:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f0101c26:	00 
f0101c27:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101c2e:	e8 0d e4 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c33:	39 c3                	cmp    %eax,%ebx
f0101c35:	74 05                	je     f0101c3c <mem_init+0x703>
f0101c37:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101c3a:	75 24                	jne    f0101c60 <mem_init+0x727>
f0101c3c:	c7 44 24 0c 78 72 10 	movl   $0xf0107278,0xc(%esp)
f0101c43:	f0 
f0101c44:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101c4b:	f0 
f0101c4c:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
f0101c53:	00 
f0101c54:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101c5b:	e8 e0 e3 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101c60:	a1 40 92 1e f0       	mov    0xf01e9240,%eax
f0101c65:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101c68:	c7 05 40 92 1e f0 00 	movl   $0x0,0xf01e9240
f0101c6f:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101c72:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c79:	e8 a2 f4 ff ff       	call   f0101120 <page_alloc>
f0101c7e:	85 c0                	test   %eax,%eax
f0101c80:	74 24                	je     f0101ca6 <mem_init+0x76d>
f0101c82:	c7 44 24 0c fb 7b 10 	movl   $0xf0107bfb,0xc(%esp)
f0101c89:	f0 
f0101c8a:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101c91:	f0 
f0101c92:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f0101c99:	00 
f0101c9a:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101ca1:	e8 9a e3 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *)0x0, &ptep) == NULL);
f0101ca6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ca9:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101cad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101cb4:	00 
f0101cb5:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0101cba:	89 04 24             	mov    %eax,(%esp)
f0101cbd:	e8 41 f6 ff ff       	call   f0101303 <page_lookup>
f0101cc2:	85 c0                	test   %eax,%eax
f0101cc4:	74 24                	je     f0101cea <mem_init+0x7b1>
f0101cc6:	c7 44 24 0c 18 73 10 	movl   $0xf0107318,0xc(%esp)
f0101ccd:	f0 
f0101cce:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101cd5:	f0 
f0101cd6:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f0101cdd:	00 
f0101cde:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101ce5:	e8 56 e3 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101cea:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101cf1:	00 
f0101cf2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101cf9:	00 
f0101cfa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101cfe:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0101d03:	89 04 24             	mov    %eax,(%esp)
f0101d06:	e8 47 f7 ff ff       	call   f0101452 <page_insert>
f0101d0b:	85 c0                	test   %eax,%eax
f0101d0d:	78 24                	js     f0101d33 <mem_init+0x7fa>
f0101d0f:	c7 44 24 0c 4c 73 10 	movl   $0xf010734c,0xc(%esp)
f0101d16:	f0 
f0101d17:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101d1e:	f0 
f0101d1f:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f0101d26:	00 
f0101d27:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101d2e:	e8 0d e3 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101d33:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d36:	89 04 24             	mov    %eax,(%esp)
f0101d39:	e8 73 f4 ff ff       	call   f01011b1 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101d3e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d45:	00 
f0101d46:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d4d:	00 
f0101d4e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d52:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0101d57:	89 04 24             	mov    %eax,(%esp)
f0101d5a:	e8 f3 f6 ff ff       	call   f0101452 <page_insert>
f0101d5f:	85 c0                	test   %eax,%eax
f0101d61:	74 24                	je     f0101d87 <mem_init+0x84e>
f0101d63:	c7 44 24 0c 7c 73 10 	movl   $0xf010737c,0xc(%esp)
f0101d6a:	f0 
f0101d6b:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101d72:	f0 
f0101d73:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f0101d7a:	00 
f0101d7b:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101d82:	e8 b9 e2 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d87:	8b 3d 8c 9e 1e f0    	mov    0xf01e9e8c,%edi
	return (pp - pages) << PGSHIFT;
f0101d8d:	a1 90 9e 1e f0       	mov    0xf01e9e90,%eax
f0101d92:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101d95:	8b 17                	mov    (%edi),%edx
f0101d97:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101d9d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101da0:	29 c1                	sub    %eax,%ecx
f0101da2:	89 c8                	mov    %ecx,%eax
f0101da4:	c1 f8 03             	sar    $0x3,%eax
f0101da7:	c1 e0 0c             	shl    $0xc,%eax
f0101daa:	39 c2                	cmp    %eax,%edx
f0101dac:	74 24                	je     f0101dd2 <mem_init+0x899>
f0101dae:	c7 44 24 0c ac 73 10 	movl   $0xf01073ac,0xc(%esp)
f0101db5:	f0 
f0101db6:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101dbd:	f0 
f0101dbe:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f0101dc5:	00 
f0101dc6:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101dcd:	e8 6e e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101dd2:	ba 00 00 00 00       	mov    $0x0,%edx
f0101dd7:	89 f8                	mov    %edi,%eax
f0101dd9:	e8 2d ee ff ff       	call   f0100c0b <check_va2pa>
f0101dde:	89 da                	mov    %ebx,%edx
f0101de0:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101de3:	c1 fa 03             	sar    $0x3,%edx
f0101de6:	c1 e2 0c             	shl    $0xc,%edx
f0101de9:	39 d0                	cmp    %edx,%eax
f0101deb:	74 24                	je     f0101e11 <mem_init+0x8d8>
f0101ded:	c7 44 24 0c d4 73 10 	movl   $0xf01073d4,0xc(%esp)
f0101df4:	f0 
f0101df5:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101dfc:	f0 
f0101dfd:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f0101e04:	00 
f0101e05:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101e0c:	e8 2f e2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101e11:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e16:	74 24                	je     f0101e3c <mem_init+0x903>
f0101e18:	c7 44 24 0c 4d 7c 10 	movl   $0xf0107c4d,0xc(%esp)
f0101e1f:	f0 
f0101e20:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101e27:	f0 
f0101e28:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f0101e2f:	00 
f0101e30:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101e37:	e8 04 e2 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101e3c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e3f:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e44:	74 24                	je     f0101e6a <mem_init+0x931>
f0101e46:	c7 44 24 0c 5e 7c 10 	movl   $0xf0107c5e,0xc(%esp)
f0101e4d:	f0 
f0101e4e:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101e55:	f0 
f0101e56:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f0101e5d:	00 
f0101e5e:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101e65:	e8 d6 e1 ff ff       	call   f0100040 <_panic>
	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101e6a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e71:	00 
f0101e72:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e79:	00 
f0101e7a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101e7e:	89 3c 24             	mov    %edi,(%esp)
f0101e81:	e8 cc f5 ff ff       	call   f0101452 <page_insert>
f0101e86:	85 c0                	test   %eax,%eax
f0101e88:	74 24                	je     f0101eae <mem_init+0x975>
f0101e8a:	c7 44 24 0c 04 74 10 	movl   $0xf0107404,0xc(%esp)
f0101e91:	f0 
f0101e92:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101e99:	f0 
f0101e9a:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f0101ea1:	00 
f0101ea2:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101ea9:	e8 92 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101eae:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101eb3:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0101eb8:	e8 4e ed ff ff       	call   f0100c0b <check_va2pa>
f0101ebd:	89 f2                	mov    %esi,%edx
f0101ebf:	2b 15 90 9e 1e f0    	sub    0xf01e9e90,%edx
f0101ec5:	c1 fa 03             	sar    $0x3,%edx
f0101ec8:	c1 e2 0c             	shl    $0xc,%edx
f0101ecb:	39 d0                	cmp    %edx,%eax
f0101ecd:	74 24                	je     f0101ef3 <mem_init+0x9ba>
f0101ecf:	c7 44 24 0c 40 74 10 	movl   $0xf0107440,0xc(%esp)
f0101ed6:	f0 
f0101ed7:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101ede:	f0 
f0101edf:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f0101ee6:	00 
f0101ee7:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101eee:	e8 4d e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ef3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ef8:	74 24                	je     f0101f1e <mem_init+0x9e5>
f0101efa:	c7 44 24 0c 6f 7c 10 	movl   $0xf0107c6f,0xc(%esp)
f0101f01:	f0 
f0101f02:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101f09:	f0 
f0101f0a:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0101f11:	00 
f0101f12:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101f19:	e8 22 e1 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f25:	e8 f6 f1 ff ff       	call   f0101120 <page_alloc>
f0101f2a:	85 c0                	test   %eax,%eax
f0101f2c:	74 24                	je     f0101f52 <mem_init+0xa19>
f0101f2e:	c7 44 24 0c fb 7b 10 	movl   $0xf0107bfb,0xc(%esp)
f0101f35:	f0 
f0101f36:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101f3d:	f0 
f0101f3e:	c7 44 24 04 56 03 00 	movl   $0x356,0x4(%esp)
f0101f45:	00 
f0101f46:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101f4d:	e8 ee e0 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101f52:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f59:	00 
f0101f5a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f61:	00 
f0101f62:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101f66:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0101f6b:	89 04 24             	mov    %eax,(%esp)
f0101f6e:	e8 df f4 ff ff       	call   f0101452 <page_insert>
f0101f73:	85 c0                	test   %eax,%eax
f0101f75:	74 24                	je     f0101f9b <mem_init+0xa62>
f0101f77:	c7 44 24 0c 04 74 10 	movl   $0xf0107404,0xc(%esp)
f0101f7e:	f0 
f0101f7f:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101f86:	f0 
f0101f87:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f0101f8e:	00 
f0101f8f:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101f96:	e8 a5 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f9b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fa0:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0101fa5:	e8 61 ec ff ff       	call   f0100c0b <check_va2pa>
f0101faa:	89 f2                	mov    %esi,%edx
f0101fac:	2b 15 90 9e 1e f0    	sub    0xf01e9e90,%edx
f0101fb2:	c1 fa 03             	sar    $0x3,%edx
f0101fb5:	c1 e2 0c             	shl    $0xc,%edx
f0101fb8:	39 d0                	cmp    %edx,%eax
f0101fba:	74 24                	je     f0101fe0 <mem_init+0xaa7>
f0101fbc:	c7 44 24 0c 40 74 10 	movl   $0xf0107440,0xc(%esp)
f0101fc3:	f0 
f0101fc4:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101fcb:	f0 
f0101fcc:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f0101fd3:	00 
f0101fd4:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0101fdb:	e8 60 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101fe0:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101fe5:	74 24                	je     f010200b <mem_init+0xad2>
f0101fe7:	c7 44 24 0c 6f 7c 10 	movl   $0xf0107c6f,0xc(%esp)
f0101fee:	f0 
f0101fef:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0101ff6:	f0 
f0101ff7:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f0101ffe:	00 
f0101fff:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102006:	e8 35 e0 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010200b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102012:	e8 09 f1 ff ff       	call   f0101120 <page_alloc>
f0102017:	85 c0                	test   %eax,%eax
f0102019:	74 24                	je     f010203f <mem_init+0xb06>
f010201b:	c7 44 24 0c fb 7b 10 	movl   $0xf0107bfb,0xc(%esp)
f0102022:	f0 
f0102023:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f010202a:	f0 
f010202b:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0102032:	00 
f0102033:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f010203a:	e8 01 e0 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010203f:	8b 15 8c 9e 1e f0    	mov    0xf01e9e8c,%edx
f0102045:	8b 02                	mov    (%edx),%eax
f0102047:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010204c:	89 c1                	mov    %eax,%ecx
f010204e:	c1 e9 0c             	shr    $0xc,%ecx
f0102051:	3b 0d 88 9e 1e f0    	cmp    0xf01e9e88,%ecx
f0102057:	72 20                	jb     f0102079 <mem_init+0xb40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102059:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010205d:	c7 44 24 08 64 6b 10 	movl   $0xf0106b64,0x8(%esp)
f0102064:	f0 
f0102065:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
f010206c:	00 
f010206d:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102074:	e8 c7 df ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102079:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010207e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
f0102081:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102088:	00 
f0102089:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102090:	00 
f0102091:	89 14 24             	mov    %edx,(%esp)
f0102094:	e8 7b f1 ff ff       	call   f0101214 <pgdir_walk>
f0102099:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010209c:	8d 51 04             	lea    0x4(%ecx),%edx
f010209f:	39 d0                	cmp    %edx,%eax
f01020a1:	74 24                	je     f01020c7 <mem_init+0xb8e>
f01020a3:	c7 44 24 0c 70 74 10 	movl   $0xf0107470,0xc(%esp)
f01020aa:	f0 
f01020ab:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01020b2:	f0 
f01020b3:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f01020ba:	00 
f01020bb:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01020c2:	e8 79 df ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W | PTE_U) == 0);
f01020c7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01020ce:	00 
f01020cf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01020d6:	00 
f01020d7:	89 74 24 04          	mov    %esi,0x4(%esp)
f01020db:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f01020e0:	89 04 24             	mov    %eax,(%esp)
f01020e3:	e8 6a f3 ff ff       	call   f0101452 <page_insert>
f01020e8:	85 c0                	test   %eax,%eax
f01020ea:	74 24                	je     f0102110 <mem_init+0xbd7>
f01020ec:	c7 44 24 0c b0 74 10 	movl   $0xf01074b0,0xc(%esp)
f01020f3:	f0 
f01020f4:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01020fb:	f0 
f01020fc:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0102103:	00 
f0102104:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f010210b:	e8 30 df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102110:	8b 3d 8c 9e 1e f0    	mov    0xf01e9e8c,%edi
f0102116:	ba 00 10 00 00       	mov    $0x1000,%edx
f010211b:	89 f8                	mov    %edi,%eax
f010211d:	e8 e9 ea ff ff       	call   f0100c0b <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0102122:	89 f2                	mov    %esi,%edx
f0102124:	2b 15 90 9e 1e f0    	sub    0xf01e9e90,%edx
f010212a:	c1 fa 03             	sar    $0x3,%edx
f010212d:	c1 e2 0c             	shl    $0xc,%edx
f0102130:	39 d0                	cmp    %edx,%eax
f0102132:	74 24                	je     f0102158 <mem_init+0xc1f>
f0102134:	c7 44 24 0c 40 74 10 	movl   $0xf0107440,0xc(%esp)
f010213b:	f0 
f010213c:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102143:	f0 
f0102144:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f010214b:	00 
f010214c:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102153:	e8 e8 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102158:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010215d:	74 24                	je     f0102183 <mem_init+0xc4a>
f010215f:	c7 44 24 0c 6f 7c 10 	movl   $0xf0107c6f,0xc(%esp)
f0102166:	f0 
f0102167:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f010216e:	f0 
f010216f:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102176:	00 
f0102177:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f010217e:	e8 bd de ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U);
f0102183:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010218a:	00 
f010218b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102192:	00 
f0102193:	89 3c 24             	mov    %edi,(%esp)
f0102196:	e8 79 f0 ff ff       	call   f0101214 <pgdir_walk>
f010219b:	f6 00 04             	testb  $0x4,(%eax)
f010219e:	75 24                	jne    f01021c4 <mem_init+0xc8b>
f01021a0:	c7 44 24 0c f4 74 10 	movl   $0xf01074f4,0xc(%esp)
f01021a7:	f0 
f01021a8:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01021af:	f0 
f01021b0:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f01021b7:	00 
f01021b8:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01021bf:	e8 7c de ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01021c4:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f01021c9:	f6 00 04             	testb  $0x4,(%eax)
f01021cc:	75 24                	jne    f01021f2 <mem_init+0xcb9>
f01021ce:	c7 44 24 0c 80 7c 10 	movl   $0xf0107c80,0xc(%esp)
f01021d5:	f0 
f01021d6:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01021dd:	f0 
f01021de:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f01021e5:	00 
f01021e6:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01021ed:	e8 4e de ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f01021f2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01021f9:	00 
f01021fa:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102201:	00 
f0102202:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102206:	89 04 24             	mov    %eax,(%esp)
f0102209:	e8 44 f2 ff ff       	call   f0101452 <page_insert>
f010220e:	85 c0                	test   %eax,%eax
f0102210:	74 24                	je     f0102236 <mem_init+0xcfd>
f0102212:	c7 44 24 0c 04 74 10 	movl   $0xf0107404,0xc(%esp)
f0102219:	f0 
f010221a:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102221:	f0 
f0102222:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0102229:	00 
f010222a:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102231:	e8 0a de ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_W);
f0102236:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010223d:	00 
f010223e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102245:	00 
f0102246:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f010224b:	89 04 24             	mov    %eax,(%esp)
f010224e:	e8 c1 ef ff ff       	call   f0101214 <pgdir_walk>
f0102253:	f6 00 02             	testb  $0x2,(%eax)
f0102256:	75 24                	jne    f010227c <mem_init+0xd43>
f0102258:	c7 44 24 0c 28 75 10 	movl   $0xf0107528,0xc(%esp)
f010225f:	f0 
f0102260:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102267:	f0 
f0102268:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f010226f:	00 
f0102270:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102277:	e8 c4 dd ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f010227c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102283:	00 
f0102284:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010228b:	00 
f010228c:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0102291:	89 04 24             	mov    %eax,(%esp)
f0102294:	e8 7b ef ff ff       	call   f0101214 <pgdir_walk>
f0102299:	f6 00 04             	testb  $0x4,(%eax)
f010229c:	74 24                	je     f01022c2 <mem_init+0xd89>
f010229e:	c7 44 24 0c 5c 75 10 	movl   $0xf010755c,0xc(%esp)
f01022a5:	f0 
f01022a6:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01022ad:	f0 
f01022ae:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f01022b5:	00 
f01022b6:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01022bd:	e8 7e dd ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void *)PTSIZE, PTE_W) < 0);
f01022c2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01022c9:	00 
f01022ca:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01022d1:	00 
f01022d2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022d5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01022d9:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f01022de:	89 04 24             	mov    %eax,(%esp)
f01022e1:	e8 6c f1 ff ff       	call   f0101452 <page_insert>
f01022e6:	85 c0                	test   %eax,%eax
f01022e8:	78 24                	js     f010230e <mem_init+0xdd5>
f01022ea:	c7 44 24 0c 94 75 10 	movl   $0xf0107594,0xc(%esp)
f01022f1:	f0 
f01022f2:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01022f9:	f0 
f01022fa:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f0102301:	00 
f0102302:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102309:	e8 32 dd ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W) == 0);
f010230e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102315:	00 
f0102316:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010231d:	00 
f010231e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102322:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0102327:	89 04 24             	mov    %eax,(%esp)
f010232a:	e8 23 f1 ff ff       	call   f0101452 <page_insert>
f010232f:	85 c0                	test   %eax,%eax
f0102331:	74 24                	je     f0102357 <mem_init+0xe1e>
f0102333:	c7 44 24 0c cc 75 10 	movl   $0xf01075cc,0xc(%esp)
f010233a:	f0 
f010233b:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102342:	f0 
f0102343:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f010234a:	00 
f010234b:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102352:	e8 e9 dc ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0102357:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010235e:	00 
f010235f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102366:	00 
f0102367:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f010236c:	89 04 24             	mov    %eax,(%esp)
f010236f:	e8 a0 ee ff ff       	call   f0101214 <pgdir_walk>
f0102374:	f6 00 04             	testb  $0x4,(%eax)
f0102377:	74 24                	je     f010239d <mem_init+0xe64>
f0102379:	c7 44 24 0c 5c 75 10 	movl   $0xf010755c,0xc(%esp)
f0102380:	f0 
f0102381:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102388:	f0 
f0102389:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f0102390:	00 
f0102391:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102398:	e8 a3 dc ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010239d:	8b 3d 8c 9e 1e f0    	mov    0xf01e9e8c,%edi
f01023a3:	ba 00 00 00 00       	mov    $0x0,%edx
f01023a8:	89 f8                	mov    %edi,%eax
f01023aa:	e8 5c e8 ff ff       	call   f0100c0b <check_va2pa>
f01023af:	89 c1                	mov    %eax,%ecx
f01023b1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01023b4:	89 d8                	mov    %ebx,%eax
f01023b6:	2b 05 90 9e 1e f0    	sub    0xf01e9e90,%eax
f01023bc:	c1 f8 03             	sar    $0x3,%eax
f01023bf:	c1 e0 0c             	shl    $0xc,%eax
f01023c2:	39 c1                	cmp    %eax,%ecx
f01023c4:	74 24                	je     f01023ea <mem_init+0xeb1>
f01023c6:	c7 44 24 0c 08 76 10 	movl   $0xf0107608,0xc(%esp)
f01023cd:	f0 
f01023ce:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01023d5:	f0 
f01023d6:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f01023dd:	00 
f01023de:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01023e5:	e8 56 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01023ea:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023ef:	89 f8                	mov    %edi,%eax
f01023f1:	e8 15 e8 ff ff       	call   f0100c0b <check_va2pa>
f01023f6:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01023f9:	74 24                	je     f010241f <mem_init+0xee6>
f01023fb:	c7 44 24 0c 34 76 10 	movl   $0xf0107634,0xc(%esp)
f0102402:	f0 
f0102403:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f010240a:	f0 
f010240b:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0102412:	00 
f0102413:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f010241a:	e8 21 dc ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010241f:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0102424:	74 24                	je     f010244a <mem_init+0xf11>
f0102426:	c7 44 24 0c 96 7c 10 	movl   $0xf0107c96,0xc(%esp)
f010242d:	f0 
f010242e:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102435:	f0 
f0102436:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f010243d:	00 
f010243e:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102445:	e8 f6 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010244a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010244f:	74 24                	je     f0102475 <mem_init+0xf3c>
f0102451:	c7 44 24 0c a7 7c 10 	movl   $0xf0107ca7,0xc(%esp)
f0102458:	f0 
f0102459:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102460:	f0 
f0102461:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0102468:	00 
f0102469:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102470:	e8 cb db ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102475:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010247c:	e8 9f ec ff ff       	call   f0101120 <page_alloc>
f0102481:	85 c0                	test   %eax,%eax
f0102483:	74 04                	je     f0102489 <mem_init+0xf50>
f0102485:	39 c6                	cmp    %eax,%esi
f0102487:	74 24                	je     f01024ad <mem_init+0xf74>
f0102489:	c7 44 24 0c 64 76 10 	movl   $0xf0107664,0xc(%esp)
f0102490:	f0 
f0102491:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102498:	f0 
f0102499:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f01024a0:	00 
f01024a1:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01024a8:	e8 93 db ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01024ad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01024b4:	00 
f01024b5:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f01024ba:	89 04 24             	mov    %eax,(%esp)
f01024bd:	e8 47 ef ff ff       	call   f0101409 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01024c2:	8b 3d 8c 9e 1e f0    	mov    0xf01e9e8c,%edi
f01024c8:	ba 00 00 00 00       	mov    $0x0,%edx
f01024cd:	89 f8                	mov    %edi,%eax
f01024cf:	e8 37 e7 ff ff       	call   f0100c0b <check_va2pa>
f01024d4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024d7:	74 24                	je     f01024fd <mem_init+0xfc4>
f01024d9:	c7 44 24 0c 88 76 10 	movl   $0xf0107688,0xc(%esp)
f01024e0:	f0 
f01024e1:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01024e8:	f0 
f01024e9:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f01024f0:	00 
f01024f1:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01024f8:	e8 43 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01024fd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102502:	89 f8                	mov    %edi,%eax
f0102504:	e8 02 e7 ff ff       	call   f0100c0b <check_va2pa>
f0102509:	89 da                	mov    %ebx,%edx
f010250b:	2b 15 90 9e 1e f0    	sub    0xf01e9e90,%edx
f0102511:	c1 fa 03             	sar    $0x3,%edx
f0102514:	c1 e2 0c             	shl    $0xc,%edx
f0102517:	39 d0                	cmp    %edx,%eax
f0102519:	74 24                	je     f010253f <mem_init+0x1006>
f010251b:	c7 44 24 0c 34 76 10 	movl   $0xf0107634,0xc(%esp)
f0102522:	f0 
f0102523:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f010252a:	f0 
f010252b:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0102532:	00 
f0102533:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f010253a:	e8 01 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010253f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102544:	74 24                	je     f010256a <mem_init+0x1031>
f0102546:	c7 44 24 0c 4d 7c 10 	movl   $0xf0107c4d,0xc(%esp)
f010254d:	f0 
f010254e:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102555:	f0 
f0102556:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f010255d:	00 
f010255e:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102565:	e8 d6 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010256a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010256f:	74 24                	je     f0102595 <mem_init+0x105c>
f0102571:	c7 44 24 0c a7 7c 10 	movl   $0xf0107ca7,0xc(%esp)
f0102578:	f0 
f0102579:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102580:	f0 
f0102581:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0102588:	00 
f0102589:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102590:	e8 ab da ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, 0) == 0);
f0102595:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010259c:	00 
f010259d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01025a4:	00 
f01025a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01025a9:	89 3c 24             	mov    %edi,(%esp)
f01025ac:	e8 a1 ee ff ff       	call   f0101452 <page_insert>
f01025b1:	85 c0                	test   %eax,%eax
f01025b3:	74 24                	je     f01025d9 <mem_init+0x10a0>
f01025b5:	c7 44 24 0c ac 76 10 	movl   $0xf01076ac,0xc(%esp)
f01025bc:	f0 
f01025bd:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01025c4:	f0 
f01025c5:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
f01025cc:	00 
f01025cd:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01025d4:	e8 67 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01025d9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01025de:	75 24                	jne    f0102604 <mem_init+0x10cb>
f01025e0:	c7 44 24 0c b8 7c 10 	movl   $0xf0107cb8,0xc(%esp)
f01025e7:	f0 
f01025e8:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01025ef:	f0 
f01025f0:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f01025f7:	00 
f01025f8:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01025ff:	e8 3c da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102604:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102607:	74 24                	je     f010262d <mem_init+0x10f4>
f0102609:	c7 44 24 0c c4 7c 10 	movl   $0xf0107cc4,0xc(%esp)
f0102610:	f0 
f0102611:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102618:	f0 
f0102619:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f0102620:	00 
f0102621:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102628:	e8 13 da ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void *)PGSIZE);
f010262d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102634:	00 
f0102635:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f010263a:	89 04 24             	mov    %eax,(%esp)
f010263d:	e8 c7 ed ff ff       	call   f0101409 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102642:	8b 3d 8c 9e 1e f0    	mov    0xf01e9e8c,%edi
f0102648:	ba 00 00 00 00       	mov    $0x0,%edx
f010264d:	89 f8                	mov    %edi,%eax
f010264f:	e8 b7 e5 ff ff       	call   f0100c0b <check_va2pa>
f0102654:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102657:	74 24                	je     f010267d <mem_init+0x1144>
f0102659:	c7 44 24 0c 88 76 10 	movl   $0xf0107688,0xc(%esp)
f0102660:	f0 
f0102661:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102668:	f0 
f0102669:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0102670:	00 
f0102671:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102678:	e8 c3 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010267d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102682:	89 f8                	mov    %edi,%eax
f0102684:	e8 82 e5 ff ff       	call   f0100c0b <check_va2pa>
f0102689:	83 f8 ff             	cmp    $0xffffffff,%eax
f010268c:	74 24                	je     f01026b2 <mem_init+0x1179>
f010268e:	c7 44 24 0c e4 76 10 	movl   $0xf01076e4,0xc(%esp)
f0102695:	f0 
f0102696:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f010269d:	f0 
f010269e:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f01026a5:	00 
f01026a6:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01026ad:	e8 8e d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01026b2:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01026b7:	74 24                	je     f01026dd <mem_init+0x11a4>
f01026b9:	c7 44 24 0c d9 7c 10 	movl   $0xf0107cd9,0xc(%esp)
f01026c0:	f0 
f01026c1:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01026c8:	f0 
f01026c9:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f01026d0:	00 
f01026d1:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01026d8:	e8 63 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01026dd:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01026e2:	74 24                	je     f0102708 <mem_init+0x11cf>
f01026e4:	c7 44 24 0c a7 7c 10 	movl   $0xf0107ca7,0xc(%esp)
f01026eb:	f0 
f01026ec:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01026f3:	f0 
f01026f4:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f01026fb:	00 
f01026fc:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102703:	e8 38 d9 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102708:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010270f:	e8 0c ea ff ff       	call   f0101120 <page_alloc>
f0102714:	85 c0                	test   %eax,%eax
f0102716:	74 04                	je     f010271c <mem_init+0x11e3>
f0102718:	39 c3                	cmp    %eax,%ebx
f010271a:	74 24                	je     f0102740 <mem_init+0x1207>
f010271c:	c7 44 24 0c 0c 77 10 	movl   $0xf010770c,0xc(%esp)
f0102723:	f0 
f0102724:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f010272b:	f0 
f010272c:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0102733:	00 
f0102734:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f010273b:	e8 00 d9 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102740:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102747:	e8 d4 e9 ff ff       	call   f0101120 <page_alloc>
f010274c:	85 c0                	test   %eax,%eax
f010274e:	74 24                	je     f0102774 <mem_init+0x123b>
f0102750:	c7 44 24 0c fb 7b 10 	movl   $0xf0107bfb,0xc(%esp)
f0102757:	f0 
f0102758:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f010275f:	f0 
f0102760:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f0102767:	00 
f0102768:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f010276f:	e8 cc d8 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102774:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0102779:	8b 08                	mov    (%eax),%ecx
f010277b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102781:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102784:	2b 15 90 9e 1e f0    	sub    0xf01e9e90,%edx
f010278a:	c1 fa 03             	sar    $0x3,%edx
f010278d:	c1 e2 0c             	shl    $0xc,%edx
f0102790:	39 d1                	cmp    %edx,%ecx
f0102792:	74 24                	je     f01027b8 <mem_init+0x127f>
f0102794:	c7 44 24 0c ac 73 10 	movl   $0xf01073ac,0xc(%esp)
f010279b:	f0 
f010279c:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01027a3:	f0 
f01027a4:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f01027ab:	00 
f01027ac:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01027b3:	e8 88 d8 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01027b8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01027be:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01027c1:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01027c6:	74 24                	je     f01027ec <mem_init+0x12b3>
f01027c8:	c7 44 24 0c 5e 7c 10 	movl   $0xf0107c5e,0xc(%esp)
f01027cf:	f0 
f01027d0:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01027d7:	f0 
f01027d8:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f01027df:	00 
f01027e0:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01027e7:	e8 54 d8 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01027ec:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01027ef:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01027f5:	89 04 24             	mov    %eax,(%esp)
f01027f8:	e8 b4 e9 ff ff       	call   f01011b1 <page_free>
	va = (void *)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01027fd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102804:	00 
f0102805:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f010280c:	00 
f010280d:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0102812:	89 04 24             	mov    %eax,(%esp)
f0102815:	e8 fa e9 ff ff       	call   f0101214 <pgdir_walk>
f010281a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010281d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102820:	8b 15 8c 9e 1e f0    	mov    0xf01e9e8c,%edx
f0102826:	8b 7a 04             	mov    0x4(%edx),%edi
f0102829:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f010282f:	8b 0d 88 9e 1e f0    	mov    0xf01e9e88,%ecx
f0102835:	89 f8                	mov    %edi,%eax
f0102837:	c1 e8 0c             	shr    $0xc,%eax
f010283a:	39 c8                	cmp    %ecx,%eax
f010283c:	72 20                	jb     f010285e <mem_init+0x1325>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010283e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102842:	c7 44 24 08 64 6b 10 	movl   $0xf0106b64,0x8(%esp)
f0102849:	f0 
f010284a:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f0102851:	00 
f0102852:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102859:	e8 e2 d7 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010285e:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0102864:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0102867:	74 24                	je     f010288d <mem_init+0x1354>
f0102869:	c7 44 24 0c ea 7c 10 	movl   $0xf0107cea,0xc(%esp)
f0102870:	f0 
f0102871:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102878:	f0 
f0102879:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0102880:	00 
f0102881:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102888:	e8 b3 d7 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010288d:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f0102894:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102897:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f010289d:	2b 05 90 9e 1e f0    	sub    0xf01e9e90,%eax
f01028a3:	c1 f8 03             	sar    $0x3,%eax
f01028a6:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01028a9:	89 c2                	mov    %eax,%edx
f01028ab:	c1 ea 0c             	shr    $0xc,%edx
f01028ae:	39 d1                	cmp    %edx,%ecx
f01028b0:	77 20                	ja     f01028d2 <mem_init+0x1399>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01028b6:	c7 44 24 08 64 6b 10 	movl   $0xf0106b64,0x8(%esp)
f01028bd:	f0 
f01028be:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01028c5:	00 
f01028c6:	c7 04 24 c5 7a 10 f0 	movl   $0xf0107ac5,(%esp)
f01028cd:	e8 6e d7 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01028d2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01028d9:	00 
f01028da:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01028e1:	00 
	return (void *)(pa + KERNBASE);
f01028e2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01028e7:	89 04 24             	mov    %eax,(%esp)
f01028ea:	e8 28 35 00 00       	call   f0105e17 <memset>
	page_free(pp0);
f01028ef:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01028f2:	89 3c 24             	mov    %edi,(%esp)
f01028f5:	e8 b7 e8 ff ff       	call   f01011b1 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01028fa:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102901:	00 
f0102902:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102909:	00 
f010290a:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f010290f:	89 04 24             	mov    %eax,(%esp)
f0102912:	e8 fd e8 ff ff       	call   f0101214 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0102917:	89 fa                	mov    %edi,%edx
f0102919:	2b 15 90 9e 1e f0    	sub    0xf01e9e90,%edx
f010291f:	c1 fa 03             	sar    $0x3,%edx
f0102922:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102925:	89 d0                	mov    %edx,%eax
f0102927:	c1 e8 0c             	shr    $0xc,%eax
f010292a:	3b 05 88 9e 1e f0    	cmp    0xf01e9e88,%eax
f0102930:	72 20                	jb     f0102952 <mem_init+0x1419>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102932:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102936:	c7 44 24 08 64 6b 10 	movl   $0xf0106b64,0x8(%esp)
f010293d:	f0 
f010293e:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102945:	00 
f0102946:	c7 04 24 c5 7a 10 f0 	movl   $0xf0107ac5,(%esp)
f010294d:	e8 ee d6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102952:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *)page2kva(pp0);
f0102958:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010295b:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for (i = 0; i < NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102961:	f6 00 01             	testb  $0x1,(%eax)
f0102964:	74 24                	je     f010298a <mem_init+0x1451>
f0102966:	c7 44 24 0c 02 7d 10 	movl   $0xf0107d02,0xc(%esp)
f010296d:	f0 
f010296e:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102975:	f0 
f0102976:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f010297d:	00 
f010297e:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102985:	e8 b6 d6 ff ff       	call   f0100040 <_panic>
f010298a:	83 c0 04             	add    $0x4,%eax
	for (i = 0; i < NPTENTRIES; i++)
f010298d:	39 d0                	cmp    %edx,%eax
f010298f:	75 d0                	jne    f0102961 <mem_init+0x1428>
	kern_pgdir[0] = 0;
f0102991:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0102996:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010299c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010299f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01029a5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01029a8:	89 0d 40 92 1e f0    	mov    %ecx,0xf01e9240

	// free the pages we took
	page_free(pp0);
f01029ae:	89 04 24             	mov    %eax,(%esp)
f01029b1:	e8 fb e7 ff ff       	call   f01011b1 <page_free>
	page_free(pp1);
f01029b6:	89 1c 24             	mov    %ebx,(%esp)
f01029b9:	e8 f3 e7 ff ff       	call   f01011b1 <page_free>
	page_free(pp2);
f01029be:	89 34 24             	mov    %esi,(%esp)
f01029c1:	e8 eb e7 ff ff       	call   f01011b1 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t)mmio_map_region(0, 4097);
f01029c6:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f01029cd:	00 
f01029ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029d5:	e8 f0 ea ff ff       	call   f01014ca <mmio_map_region>
f01029da:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t)mmio_map_region(0, 4096);
f01029dc:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01029e3:	00 
f01029e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029eb:	e8 da ea ff ff       	call   f01014ca <mmio_map_region>
f01029f0:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f01029f2:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01029f8:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01029fd:	77 08                	ja     f0102a07 <mem_init+0x14ce>
f01029ff:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102a05:	77 24                	ja     f0102a2b <mem_init+0x14f2>
f0102a07:	c7 44 24 0c 30 77 10 	movl   $0xf0107730,0xc(%esp)
f0102a0e:	f0 
f0102a0f:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102a16:	f0 
f0102a17:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0102a1e:	00 
f0102a1f:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102a26:	e8 15 d6 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102a2b:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102a31:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102a37:	77 08                	ja     f0102a41 <mem_init+0x1508>
f0102a39:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102a3f:	77 24                	ja     f0102a65 <mem_init+0x152c>
f0102a41:	c7 44 24 0c 58 77 10 	movl   $0xf0107758,0xc(%esp)
f0102a48:	f0 
f0102a49:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102a50:	f0 
f0102a51:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f0102a58:	00 
f0102a59:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102a60:	e8 db d5 ff ff       	call   f0100040 <_panic>
f0102a65:	89 da                	mov    %ebx,%edx
f0102a67:	09 f2                	or     %esi,%edx
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102a69:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102a6f:	74 24                	je     f0102a95 <mem_init+0x155c>
f0102a71:	c7 44 24 0c 80 77 10 	movl   $0xf0107780,0xc(%esp)
f0102a78:	f0 
f0102a79:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102a80:	f0 
f0102a81:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0102a88:	00 
f0102a89:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102a90:	e8 ab d5 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102a95:	39 c6                	cmp    %eax,%esi
f0102a97:	73 24                	jae    f0102abd <mem_init+0x1584>
f0102a99:	c7 44 24 0c 19 7d 10 	movl   $0xf0107d19,0xc(%esp)
f0102aa0:	f0 
f0102aa1:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102aa8:	f0 
f0102aa9:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f0102ab0:	00 
f0102ab1:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102ab8:	e8 83 d5 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102abd:	8b 3d 8c 9e 1e f0    	mov    0xf01e9e8c,%edi
f0102ac3:	89 da                	mov    %ebx,%edx
f0102ac5:	89 f8                	mov    %edi,%eax
f0102ac7:	e8 3f e1 ff ff       	call   f0100c0b <check_va2pa>
f0102acc:	85 c0                	test   %eax,%eax
f0102ace:	74 24                	je     f0102af4 <mem_init+0x15bb>
f0102ad0:	c7 44 24 0c a8 77 10 	movl   $0xf01077a8,0xc(%esp)
f0102ad7:	f0 
f0102ad8:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102adf:	f0 
f0102ae0:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0102ae7:	00 
f0102ae8:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102aef:	e8 4c d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1 + PGSIZE) == PGSIZE);
f0102af4:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102afa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102afd:	89 c2                	mov    %eax,%edx
f0102aff:	89 f8                	mov    %edi,%eax
f0102b01:	e8 05 e1 ff ff       	call   f0100c0b <check_va2pa>
f0102b06:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102b0b:	74 24                	je     f0102b31 <mem_init+0x15f8>
f0102b0d:	c7 44 24 0c cc 77 10 	movl   $0xf01077cc,0xc(%esp)
f0102b14:	f0 
f0102b15:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102b1c:	f0 
f0102b1d:	c7 44 24 04 c8 03 00 	movl   $0x3c8,0x4(%esp)
f0102b24:	00 
f0102b25:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102b2c:	e8 0f d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102b31:	89 f2                	mov    %esi,%edx
f0102b33:	89 f8                	mov    %edi,%eax
f0102b35:	e8 d1 e0 ff ff       	call   f0100c0b <check_va2pa>
f0102b3a:	85 c0                	test   %eax,%eax
f0102b3c:	74 24                	je     f0102b62 <mem_init+0x1629>
f0102b3e:	c7 44 24 0c fc 77 10 	movl   $0xf01077fc,0xc(%esp)
f0102b45:	f0 
f0102b46:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102b4d:	f0 
f0102b4e:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f0102b55:	00 
f0102b56:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102b5d:	e8 de d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2 + PGSIZE) == ~0);
f0102b62:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102b68:	89 f8                	mov    %edi,%eax
f0102b6a:	e8 9c e0 ff ff       	call   f0100c0b <check_va2pa>
f0102b6f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b72:	74 24                	je     f0102b98 <mem_init+0x165f>
f0102b74:	c7 44 24 0c 20 78 10 	movl   $0xf0107820,0xc(%esp)
f0102b7b:	f0 
f0102b7c:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102b83:	f0 
f0102b84:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f0102b8b:	00 
f0102b8c:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102b93:	e8 a8 d4 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void *)mm1, 0) & (PTE_W | PTE_PWT | PTE_PCD));
f0102b98:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102b9f:	00 
f0102ba0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102ba4:	89 3c 24             	mov    %edi,(%esp)
f0102ba7:	e8 68 e6 ff ff       	call   f0101214 <pgdir_walk>
f0102bac:	f6 00 1a             	testb  $0x1a,(%eax)
f0102baf:	75 24                	jne    f0102bd5 <mem_init+0x169c>
f0102bb1:	c7 44 24 0c 4c 78 10 	movl   $0xf010784c,0xc(%esp)
f0102bb8:	f0 
f0102bb9:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102bc0:	f0 
f0102bc1:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0102bc8:	00 
f0102bc9:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102bd0:	e8 6b d4 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *)mm1, 0) & PTE_U));
f0102bd5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102bdc:	00 
f0102bdd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102be1:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0102be6:	89 04 24             	mov    %eax,(%esp)
f0102be9:	e8 26 e6 ff ff       	call   f0101214 <pgdir_walk>
f0102bee:	f6 00 04             	testb  $0x4,(%eax)
f0102bf1:	74 24                	je     f0102c17 <mem_init+0x16de>
f0102bf3:	c7 44 24 0c 94 78 10 	movl   $0xf0107894,0xc(%esp)
f0102bfa:	f0 
f0102bfb:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102c02:	f0 
f0102c03:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f0102c0a:	00 
f0102c0b:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102c12:	e8 29 d4 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void *)mm1, 0) = 0;
f0102c17:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102c1e:	00 
f0102c1f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102c23:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0102c28:	89 04 24             	mov    %eax,(%esp)
f0102c2b:	e8 e4 e5 ff ff       	call   f0101214 <pgdir_walk>
f0102c30:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void *)mm1 + PGSIZE, 0) = 0;
f0102c36:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102c3d:	00 
f0102c3e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c41:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102c45:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0102c4a:	89 04 24             	mov    %eax,(%esp)
f0102c4d:	e8 c2 e5 ff ff       	call   f0101214 <pgdir_walk>
f0102c52:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void *)mm2, 0) = 0;
f0102c58:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102c5f:	00 
f0102c60:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102c64:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0102c69:	89 04 24             	mov    %eax,(%esp)
f0102c6c:	e8 a3 e5 ff ff       	call   f0101214 <pgdir_walk>
f0102c71:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102c77:	c7 04 24 2b 7d 10 f0 	movl   $0xf0107d2b,(%esp)
f0102c7e:	e8 66 12 00 00       	call   f0103ee9 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, npages * sizeof(struct PageInfo), PADDR(pages), PTE_U);
f0102c83:	a1 90 9e 1e f0       	mov    0xf01e9e90,%eax
	if ((uint32_t)kva < KERNBASE)
f0102c88:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c8d:	77 20                	ja     f0102caf <mem_init+0x1776>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c93:	c7 44 24 08 88 6b 10 	movl   $0xf0106b88,0x8(%esp)
f0102c9a:	f0 
f0102c9b:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
f0102ca2:	00 
f0102ca3:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102caa:	e8 91 d3 ff ff       	call   f0100040 <_panic>
f0102caf:	8b 0d 88 9e 1e f0    	mov    0xf01e9e88,%ecx
f0102cb5:	c1 e1 03             	shl    $0x3,%ecx
f0102cb8:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102cbf:	00 
	return (physaddr_t)kva - KERNBASE;
f0102cc0:	05 00 00 00 10       	add    $0x10000000,%eax
f0102cc5:	89 04 24             	mov    %eax,(%esp)
f0102cc8:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102ccd:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0102cd2:	e8 ce e6 ff ff       	call   f01013a5 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, NENV * sizeof(struct Env), PADDR(envs), PTE_U);
f0102cd7:	a1 48 92 1e f0       	mov    0xf01e9248,%eax
	if ((uint32_t)kva < KERNBASE)
f0102cdc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ce1:	77 20                	ja     f0102d03 <mem_init+0x17ca>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ce3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102ce7:	c7 44 24 08 88 6b 10 	movl   $0xf0106b88,0x8(%esp)
f0102cee:	f0 
f0102cef:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
f0102cf6:	00 
f0102cf7:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102cfe:	e8 3d d3 ff ff       	call   f0100040 <_panic>
f0102d03:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0102d0a:	00 
	return (physaddr_t)kva - KERNBASE;
f0102d0b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d10:	89 04 24             	mov    %eax,(%esp)
f0102d13:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102d18:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102d1d:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0102d22:	e8 7e e6 ff ff       	call   f01013a5 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102d27:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0102d2c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d31:	77 20                	ja     f0102d53 <mem_init+0x181a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d33:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d37:	c7 44 24 08 88 6b 10 	movl   $0xf0106b88,0x8(%esp)
f0102d3e:	f0 
f0102d3f:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
f0102d46:	00 
f0102d47:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102d4e:	e8 ed d2 ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102d53:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102d5a:	00 
f0102d5b:	c7 04 24 00 70 11 00 	movl   $0x117000,(%esp)
f0102d62:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102d67:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102d6c:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0102d71:	e8 2f e6 ff ff       	call   f01013a5 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_W);
f0102d76:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102d7d:	00 
f0102d7e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d85:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102d8a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102d8f:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0102d94:	e8 0c e6 ff ff       	call   f01013a5 <boot_map_region>
f0102d99:	bf 00 b0 22 f0       	mov    $0xf022b000,%edi
f0102d9e:	bb 00 b0 1e f0       	mov    $0xf01eb000,%ebx
f0102da3:	be 00 80 ff ef       	mov    $0xefff8000,%esi
	if ((uint32_t)kva < KERNBASE)
f0102da8:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102dae:	77 20                	ja     f0102dd0 <mem_init+0x1897>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102db0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102db4:	c7 44 24 08 88 6b 10 	movl   $0xf0106b88,0x8(%esp)
f0102dbb:	f0 
f0102dbc:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
f0102dc3:	00 
f0102dc4:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102dcb:	e8 70 d2 ff ff       	call   f0100040 <_panic>
		boot_map_region(kern_pgdir, KSTACKTOP - i * (KSTKSIZE + KSTKGAP) - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W); // percpu_kstacks[i]指向的物理内存作为其内核堆栈映射到的地址
f0102dd0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102dd7:	00 
f0102dd8:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102dde:	89 04 24             	mov    %eax,(%esp)
f0102de1:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102de6:	89 f2                	mov    %esi,%edx
f0102de8:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0102ded:	e8 b3 e5 ff ff       	call   f01013a5 <boot_map_region>
f0102df2:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102df8:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	for (int i = 0; i < NCPU; i++)
f0102dfe:	39 fb                	cmp    %edi,%ebx
f0102e00:	75 a6                	jne    f0102da8 <mem_init+0x186f>
	pgdir = kern_pgdir;
f0102e02:	8b 3d 8c 9e 1e f0    	mov    0xf01e9e8c,%edi
	n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
f0102e08:	a1 88 9e 1e f0       	mov    0xf01e9e88,%eax
f0102e0d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102e10:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102e17:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102e1c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e1f:	8b 35 90 9e 1e f0    	mov    0xf01e9e90,%esi
	if ((uint32_t)kva < KERNBASE)
f0102e25:	89 75 cc             	mov    %esi,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102e28:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0102e2e:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0102e31:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102e36:	eb 6a                	jmp    f0102ea2 <mem_init+0x1969>
f0102e38:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e3e:	89 f8                	mov    %edi,%eax
f0102e40:	e8 c6 dd ff ff       	call   f0100c0b <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102e45:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102e4c:	77 20                	ja     f0102e6e <mem_init+0x1935>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e4e:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102e52:	c7 44 24 08 88 6b 10 	movl   $0xf0106b88,0x8(%esp)
f0102e59:	f0 
f0102e5a:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f0102e61:	00 
f0102e62:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102e69:	e8 d2 d1 ff ff       	call   f0100040 <_panic>
f0102e6e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102e71:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102e74:	39 d0                	cmp    %edx,%eax
f0102e76:	74 24                	je     f0102e9c <mem_init+0x1963>
f0102e78:	c7 44 24 0c c8 78 10 	movl   $0xf01078c8,0xc(%esp)
f0102e7f:	f0 
f0102e80:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102e87:	f0 
f0102e88:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f0102e8f:	00 
f0102e90:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102e97:	e8 a4 d1 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f0102e9c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ea2:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0102ea5:	77 91                	ja     f0102e38 <mem_init+0x18ff>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102ea7:	8b 1d 48 92 1e f0    	mov    0xf01e9248,%ebx
	if ((uint32_t)kva < KERNBASE)
f0102ead:	89 de                	mov    %ebx,%esi
f0102eaf:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102eb4:	89 f8                	mov    %edi,%eax
f0102eb6:	e8 50 dd ff ff       	call   f0100c0b <check_va2pa>
f0102ebb:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102ec1:	77 20                	ja     f0102ee3 <mem_init+0x19aa>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ec3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102ec7:	c7 44 24 08 88 6b 10 	movl   $0xf0106b88,0x8(%esp)
f0102ece:	f0 
f0102ecf:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0102ed6:	00 
f0102ed7:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102ede:	e8 5d d1 ff ff       	call   f0100040 <_panic>
	if ((uint32_t)kva < KERNBASE)
f0102ee3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102ee8:	81 c6 00 00 40 21    	add    $0x21400000,%esi
f0102eee:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102ef1:	39 d0                	cmp    %edx,%eax
f0102ef3:	74 24                	je     f0102f19 <mem_init+0x19e0>
f0102ef5:	c7 44 24 0c fc 78 10 	movl   $0xf01078fc,0xc(%esp)
f0102efc:	f0 
f0102efd:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102f04:	f0 
f0102f05:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0102f0c:	00 
f0102f0d:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102f14:	e8 27 d1 ff ff       	call   f0100040 <_panic>
f0102f19:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f0102f1f:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102f25:	0f 85 aa 05 00 00    	jne    f01034d5 <mem_init+0x1f9c>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102f2b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102f2e:	c1 e6 0c             	shl    $0xc,%esi
f0102f31:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102f36:	eb 3b                	jmp    f0102f73 <mem_init+0x1a3a>
f0102f38:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102f3e:	89 f8                	mov    %edi,%eax
f0102f40:	e8 c6 dc ff ff       	call   f0100c0b <check_va2pa>
f0102f45:	39 c3                	cmp    %eax,%ebx
f0102f47:	74 24                	je     f0102f6d <mem_init+0x1a34>
f0102f49:	c7 44 24 0c 30 79 10 	movl   $0xf0107930,0xc(%esp)
f0102f50:	f0 
f0102f51:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102f58:	f0 
f0102f59:	c7 44 24 04 ec 02 00 	movl   $0x2ec,0x4(%esp)
f0102f60:	00 
f0102f61:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102f68:	e8 d3 d0 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102f6d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f73:	39 f3                	cmp    %esi,%ebx
f0102f75:	72 c1                	jb     f0102f38 <mem_init+0x19ff>
f0102f77:	c7 45 d0 00 b0 1e f0 	movl   $0xf01eb000,-0x30(%ebp)
f0102f7e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0102f85:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102f8a:	b8 00 b0 1e f0       	mov    $0xf01eb000,%eax
f0102f8f:	05 00 80 00 20       	add    $0x20008000,%eax
f0102f94:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102f97:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0102f9d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i) == PADDR(percpu_kstacks[n]) + i);
f0102fa0:	89 f2                	mov    %esi,%edx
f0102fa2:	89 f8                	mov    %edi,%eax
f0102fa4:	e8 62 dc ff ff       	call   f0100c0b <check_va2pa>
f0102fa9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102fac:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0102fb2:	77 20                	ja     f0102fd4 <mem_init+0x1a9b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fb4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102fb8:	c7 44 24 08 88 6b 10 	movl   $0xf0106b88,0x8(%esp)
f0102fbf:	f0 
f0102fc0:	c7 44 24 04 f4 02 00 	movl   $0x2f4,0x4(%esp)
f0102fc7:	00 
f0102fc8:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0102fcf:	e8 6c d0 ff ff       	call   f0100040 <_panic>
	if ((uint32_t)kva < KERNBASE)
f0102fd4:	89 f3                	mov    %esi,%ebx
f0102fd6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0102fd9:	03 4d d4             	add    -0x2c(%ebp),%ecx
f0102fdc:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0102fdf:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102fe2:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102fe5:	39 c2                	cmp    %eax,%edx
f0102fe7:	74 24                	je     f010300d <mem_init+0x1ad4>
f0102fe9:	c7 44 24 0c 58 79 10 	movl   $0xf0107958,0xc(%esp)
f0102ff0:	f0 
f0102ff1:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0102ff8:	f0 
f0102ff9:	c7 44 24 04 f4 02 00 	movl   $0x2f4,0x4(%esp)
f0103000:	00 
f0103001:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0103008:	e8 33 d0 ff ff       	call   f0100040 <_panic>
f010300d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0103013:	3b 5d cc             	cmp    -0x34(%ebp),%ebx
f0103016:	0f 85 a9 04 00 00    	jne    f01034c5 <mem_init+0x1f8c>
f010301c:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0103022:	89 da                	mov    %ebx,%edx
f0103024:	89 f8                	mov    %edi,%eax
f0103026:	e8 e0 db ff ff       	call   f0100c0b <check_va2pa>
f010302b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010302e:	74 24                	je     f0103054 <mem_init+0x1b1b>
f0103030:	c7 44 24 0c a0 79 10 	movl   $0xf01079a0,0xc(%esp)
f0103037:	f0 
f0103038:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f010303f:	f0 
f0103040:	c7 44 24 04 f6 02 00 	movl   $0x2f6,0x4(%esp)
f0103047:	00 
f0103048:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f010304f:	e8 ec cf ff ff       	call   f0100040 <_panic>
f0103054:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f010305a:	39 de                	cmp    %ebx,%esi
f010305c:	75 c4                	jne    f0103022 <mem_init+0x1ae9>
f010305e:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0103064:	81 45 d4 00 80 01 00 	addl   $0x18000,-0x2c(%ebp)
f010306b:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
	for (n = 0; n < NCPU; n++)
f0103072:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0103078:	0f 85 19 ff ff ff    	jne    f0102f97 <mem_init+0x1a5e>
f010307e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103083:	e9 c2 00 00 00       	jmp    f010314a <mem_init+0x1c11>
		switch (i)
f0103088:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f010308e:	83 fa 04             	cmp    $0x4,%edx
f0103091:	77 2e                	ja     f01030c1 <mem_init+0x1b88>
			assert(pgdir[i] & PTE_P);
f0103093:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0103097:	0f 85 aa 00 00 00    	jne    f0103147 <mem_init+0x1c0e>
f010309d:	c7 44 24 0c 44 7d 10 	movl   $0xf0107d44,0xc(%esp)
f01030a4:	f0 
f01030a5:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01030ac:	f0 
f01030ad:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f01030b4:	00 
f01030b5:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01030bc:	e8 7f cf ff ff       	call   f0100040 <_panic>
			if (i >= PDX(KERNBASE))
f01030c1:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01030c6:	76 55                	jbe    f010311d <mem_init+0x1be4>
				assert(pgdir[i] & PTE_P);
f01030c8:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01030cb:	f6 c2 01             	test   $0x1,%dl
f01030ce:	75 24                	jne    f01030f4 <mem_init+0x1bbb>
f01030d0:	c7 44 24 0c 44 7d 10 	movl   $0xf0107d44,0xc(%esp)
f01030d7:	f0 
f01030d8:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01030df:	f0 
f01030e0:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f01030e7:	00 
f01030e8:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01030ef:	e8 4c cf ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f01030f4:	f6 c2 02             	test   $0x2,%dl
f01030f7:	75 4e                	jne    f0103147 <mem_init+0x1c0e>
f01030f9:	c7 44 24 0c 55 7d 10 	movl   $0xf0107d55,0xc(%esp)
f0103100:	f0 
f0103101:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0103108:	f0 
f0103109:	c7 44 24 04 09 03 00 	movl   $0x309,0x4(%esp)
f0103110:	00 
f0103111:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0103118:	e8 23 cf ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f010311d:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0103121:	74 24                	je     f0103147 <mem_init+0x1c0e>
f0103123:	c7 44 24 0c 66 7d 10 	movl   $0xf0107d66,0xc(%esp)
f010312a:	f0 
f010312b:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0103132:	f0 
f0103133:	c7 44 24 04 0c 03 00 	movl   $0x30c,0x4(%esp)
f010313a:	00 
f010313b:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0103142:	e8 f9 ce ff ff       	call   f0100040 <_panic>
	for (i = 0; i < NPDENTRIES; i++)
f0103147:	83 c0 01             	add    $0x1,%eax
f010314a:	3d 00 04 00 00       	cmp    $0x400,%eax
f010314f:	0f 85 33 ff ff ff    	jne    f0103088 <mem_init+0x1b4f>
	cprintf("check_kern_pgdir() succeeded!\n");
f0103155:	c7 04 24 c4 79 10 f0 	movl   $0xf01079c4,(%esp)
f010315c:	e8 88 0d 00 00       	call   f0103ee9 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0103161:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0103166:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010316b:	77 20                	ja     f010318d <mem_init+0x1c54>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010316d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103171:	c7 44 24 08 88 6b 10 	movl   $0xf0106b88,0x8(%esp)
f0103178:	f0 
f0103179:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f0103180:	00 
f0103181:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0103188:	e8 b3 ce ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010318d:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103192:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0103195:	b8 00 00 00 00       	mov    $0x0,%eax
f010319a:	e8 db da ff ff       	call   f0100c7a <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f010319f:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS | CR0_EM);
f01031a2:	83 e0 f3             	and    $0xfffffff3,%eax
f01031a5:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01031aa:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01031ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031b4:	e8 67 df ff ff       	call   f0101120 <page_alloc>
f01031b9:	89 c3                	mov    %eax,%ebx
f01031bb:	85 c0                	test   %eax,%eax
f01031bd:	75 24                	jne    f01031e3 <mem_init+0x1caa>
f01031bf:	c7 44 24 0c a7 7b 10 	movl   $0xf0107ba7,0xc(%esp)
f01031c6:	f0 
f01031c7:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01031ce:	f0 
f01031cf:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f01031d6:	00 
f01031d7:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01031de:	e8 5d ce ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01031e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01031ea:	e8 31 df ff ff       	call   f0101120 <page_alloc>
f01031ef:	89 c7                	mov    %eax,%edi
f01031f1:	85 c0                	test   %eax,%eax
f01031f3:	75 24                	jne    f0103219 <mem_init+0x1ce0>
f01031f5:	c7 44 24 0c bd 7b 10 	movl   $0xf0107bbd,0xc(%esp)
f01031fc:	f0 
f01031fd:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0103204:	f0 
f0103205:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f010320c:	00 
f010320d:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0103214:	e8 27 ce ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0103219:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103220:	e8 fb de ff ff       	call   f0101120 <page_alloc>
f0103225:	89 c6                	mov    %eax,%esi
f0103227:	85 c0                	test   %eax,%eax
f0103229:	75 24                	jne    f010324f <mem_init+0x1d16>
f010322b:	c7 44 24 0c d3 7b 10 	movl   $0xf0107bd3,0xc(%esp)
f0103232:	f0 
f0103233:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f010323a:	f0 
f010323b:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0103242:	00 
f0103243:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f010324a:	e8 f1 cd ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f010324f:	89 1c 24             	mov    %ebx,(%esp)
f0103252:	e8 5a df ff ff       	call   f01011b1 <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0103257:	89 f8                	mov    %edi,%eax
f0103259:	e8 68 d9 ff ff       	call   f0100bc6 <page2kva>
f010325e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103265:	00 
f0103266:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010326d:	00 
f010326e:	89 04 24             	mov    %eax,(%esp)
f0103271:	e8 a1 2b 00 00       	call   f0105e17 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0103276:	89 f0                	mov    %esi,%eax
f0103278:	e8 49 d9 ff ff       	call   f0100bc6 <page2kva>
f010327d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103284:	00 
f0103285:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010328c:	00 
f010328d:	89 04 24             	mov    %eax,(%esp)
f0103290:	e8 82 2b 00 00       	call   f0105e17 <memset>
	page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W);
f0103295:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010329c:	00 
f010329d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01032a4:	00 
f01032a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01032a9:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f01032ae:	89 04 24             	mov    %eax,(%esp)
f01032b1:	e8 9c e1 ff ff       	call   f0101452 <page_insert>
	assert(pp1->pp_ref == 1);
f01032b6:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01032bb:	74 24                	je     f01032e1 <mem_init+0x1da8>
f01032bd:	c7 44 24 0c 4d 7c 10 	movl   $0xf0107c4d,0xc(%esp)
f01032c4:	f0 
f01032c5:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01032cc:	f0 
f01032cd:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f01032d4:	00 
f01032d5:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01032dc:	e8 5f cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01032e1:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01032e8:	01 01 01 
f01032eb:	74 24                	je     f0103311 <mem_init+0x1dd8>
f01032ed:	c7 44 24 0c e4 79 10 	movl   $0xf01079e4,0xc(%esp)
f01032f4:	f0 
f01032f5:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01032fc:	f0 
f01032fd:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f0103304:	00 
f0103305:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f010330c:	e8 2f cd ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W);
f0103311:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103318:	00 
f0103319:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103320:	00 
f0103321:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103325:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f010332a:	89 04 24             	mov    %eax,(%esp)
f010332d:	e8 20 e1 ff ff       	call   f0101452 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103332:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103339:	02 02 02 
f010333c:	74 24                	je     f0103362 <mem_init+0x1e29>
f010333e:	c7 44 24 0c 08 7a 10 	movl   $0xf0107a08,0xc(%esp)
f0103345:	f0 
f0103346:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f010334d:	f0 
f010334e:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0103355:	00 
f0103356:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f010335d:	e8 de cc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0103362:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103367:	74 24                	je     f010338d <mem_init+0x1e54>
f0103369:	c7 44 24 0c 6f 7c 10 	movl   $0xf0107c6f,0xc(%esp)
f0103370:	f0 
f0103371:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0103378:	f0 
f0103379:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f0103380:	00 
f0103381:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0103388:	e8 b3 cc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010338d:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103392:	74 24                	je     f01033b8 <mem_init+0x1e7f>
f0103394:	c7 44 24 0c d9 7c 10 	movl   $0xf0107cd9,0xc(%esp)
f010339b:	f0 
f010339c:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01033a3:	f0 
f01033a4:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f01033ab:	00 
f01033ac:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01033b3:	e8 88 cc ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01033b8:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01033bf:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01033c2:	89 f0                	mov    %esi,%eax
f01033c4:	e8 fd d7 ff ff       	call   f0100bc6 <page2kva>
f01033c9:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f01033cf:	74 24                	je     f01033f5 <mem_init+0x1ebc>
f01033d1:	c7 44 24 0c 2c 7a 10 	movl   $0xf0107a2c,0xc(%esp)
f01033d8:	f0 
f01033d9:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f01033e0:	f0 
f01033e1:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f01033e8:	00 
f01033e9:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01033f0:	e8 4b cc ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void *)PGSIZE);
f01033f5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01033fc:	00 
f01033fd:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f0103402:	89 04 24             	mov    %eax,(%esp)
f0103405:	e8 ff df ff ff       	call   f0101409 <page_remove>
	assert(pp2->pp_ref == 0);
f010340a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010340f:	74 24                	je     f0103435 <mem_init+0x1efc>
f0103411:	c7 44 24 0c a7 7c 10 	movl   $0xf0107ca7,0xc(%esp)
f0103418:	f0 
f0103419:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0103420:	f0 
f0103421:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0103428:	00 
f0103429:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0103430:	e8 0b cc ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103435:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
f010343a:	8b 08                	mov    (%eax),%ecx
f010343c:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	return (pp - pages) << PGSHIFT;
f0103442:	89 da                	mov    %ebx,%edx
f0103444:	2b 15 90 9e 1e f0    	sub    0xf01e9e90,%edx
f010344a:	c1 fa 03             	sar    $0x3,%edx
f010344d:	c1 e2 0c             	shl    $0xc,%edx
f0103450:	39 d1                	cmp    %edx,%ecx
f0103452:	74 24                	je     f0103478 <mem_init+0x1f3f>
f0103454:	c7 44 24 0c ac 73 10 	movl   $0xf01073ac,0xc(%esp)
f010345b:	f0 
f010345c:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0103463:	f0 
f0103464:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f010346b:	00 
f010346c:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f0103473:	e8 c8 cb ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103478:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010347e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103483:	74 24                	je     f01034a9 <mem_init+0x1f70>
f0103485:	c7 44 24 0c 5e 7c 10 	movl   $0xf0107c5e,0xc(%esp)
f010348c:	f0 
f010348d:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f0103494:	f0 
f0103495:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f010349c:	00 
f010349d:	c7 04 24 b9 7a 10 f0 	movl   $0xf0107ab9,(%esp)
f01034a4:	e8 97 cb ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01034a9:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01034af:	89 1c 24             	mov    %ebx,(%esp)
f01034b2:	e8 fa dc ff ff       	call   f01011b1 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01034b7:	c7 04 24 58 7a 10 f0 	movl   $0xf0107a58,(%esp)
f01034be:	e8 26 0a 00 00       	call   f0103ee9 <cprintf>
f01034c3:	eb 20                	jmp    f01034e5 <mem_init+0x1fac>
			assert(check_va2pa(pgdir, base + KSTKGAP + i) == PADDR(percpu_kstacks[n]) + i);
f01034c5:	89 da                	mov    %ebx,%edx
f01034c7:	89 f8                	mov    %edi,%eax
f01034c9:	e8 3d d7 ff ff       	call   f0100c0b <check_va2pa>
f01034ce:	66 90                	xchg   %ax,%ax
f01034d0:	e9 0a fb ff ff       	jmp    f0102fdf <mem_init+0x1aa6>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01034d5:	89 da                	mov    %ebx,%edx
f01034d7:	89 f8                	mov    %edi,%eax
f01034d9:	e8 2d d7 ff ff       	call   f0100c0b <check_va2pa>
f01034de:	66 90                	xchg   %ax,%ax
f01034e0:	e9 09 fa ff ff       	jmp    f0102eee <mem_init+0x19b5>
}
f01034e5:	83 c4 4c             	add    $0x4c,%esp
f01034e8:	5b                   	pop    %ebx
f01034e9:	5e                   	pop    %esi
f01034ea:	5f                   	pop    %edi
f01034eb:	5d                   	pop    %ebp
f01034ec:	c3                   	ret    

f01034ed <user_mem_check>:
{
f01034ed:	55                   	push   %ebp
f01034ee:	89 e5                	mov    %esp,%ebp
f01034f0:	57                   	push   %edi
f01034f1:	56                   	push   %esi
f01034f2:	53                   	push   %ebx
f01034f3:	83 ec 1c             	sub    $0x1c,%esp
f01034f6:	8b 7d 08             	mov    0x8(%ebp),%edi
	const void *start = ROUNDDOWN(va, PGSIZE);
f01034f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01034fc:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	const void *end = ROUNDUP(va + len, PGSIZE);
f0103502:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103505:	03 45 10             	add    0x10(%ebp),%eax
f0103508:	05 ff 0f 00 00       	add    $0xfff,%eax
f010350d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103512:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		if (!pte || (*pte & (perm | PTE_P)) != (perm | PTE_P)) // 确认权限，&操作可以得到那几个权限位来判断
f0103515:	8b 75 14             	mov    0x14(%ebp),%esi
f0103518:	83 ce 01             	or     $0x1,%esi
	for (; start < end; start += PGSIZE) // 遍历每一页
f010351b:	eb 3d                	jmp    f010355a <user_mem_check+0x6d>
		pte_t *pte = pgdir_walk(env->env_pgdir, start, 0);	   // 找到pte,pte只能在ULIM下方，因此若pte存在，则地址存在
f010351d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103524:	00 
f0103525:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103529:	8b 47 60             	mov    0x60(%edi),%eax
f010352c:	89 04 24             	mov    %eax,(%esp)
f010352f:	e8 e0 dc ff ff       	call   f0101214 <pgdir_walk>
		if (!pte || (*pte & (perm | PTE_P)) != (perm | PTE_P)) // 确认权限，&操作可以得到那几个权限位来判断
f0103534:	85 c0                	test   %eax,%eax
f0103536:	74 08                	je     f0103540 <user_mem_check+0x53>
f0103538:	89 f2                	mov    %esi,%edx
f010353a:	23 10                	and    (%eax),%edx
f010353c:	39 d6                	cmp    %edx,%esi
f010353e:	74 14                	je     f0103554 <user_mem_check+0x67>
			user_mem_check_addr = (uintptr_t)MAX(start, va); // 第一个错误的虚拟地址
f0103540:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0103543:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0103547:	89 1d 3c 92 1e f0    	mov    %ebx,0xf01e923c
			return -E_FAULT;								 // 提前返回
f010354d:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103552:	eb 10                	jmp    f0103564 <user_mem_check+0x77>
	for (; start < end; start += PGSIZE) // 遍历每一页
f0103554:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010355a:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010355d:	72 be                	jb     f010351d <user_mem_check+0x30>
	return 0;
f010355f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103564:	83 c4 1c             	add    $0x1c,%esp
f0103567:	5b                   	pop    %ebx
f0103568:	5e                   	pop    %esi
f0103569:	5f                   	pop    %edi
f010356a:	5d                   	pop    %ebp
f010356b:	c3                   	ret    

f010356c <user_mem_assert>:
{
f010356c:	55                   	push   %ebp
f010356d:	89 e5                	mov    %esp,%ebp
f010356f:	53                   	push   %ebx
f0103570:	83 ec 14             	sub    $0x14,%esp
f0103573:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0)
f0103576:	8b 45 14             	mov    0x14(%ebp),%eax
f0103579:	83 c8 04             	or     $0x4,%eax
f010357c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103580:	8b 45 10             	mov    0x10(%ebp),%eax
f0103583:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103587:	8b 45 0c             	mov    0xc(%ebp),%eax
f010358a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010358e:	89 1c 24             	mov    %ebx,(%esp)
f0103591:	e8 57 ff ff ff       	call   f01034ed <user_mem_check>
f0103596:	85 c0                	test   %eax,%eax
f0103598:	79 24                	jns    f01035be <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f010359a:	a1 3c 92 1e f0       	mov    0xf01e923c,%eax
f010359f:	89 44 24 08          	mov    %eax,0x8(%esp)
f01035a3:	8b 43 48             	mov    0x48(%ebx),%eax
f01035a6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035aa:	c7 04 24 84 7a 10 f0 	movl   $0xf0107a84,(%esp)
f01035b1:	e8 33 09 00 00       	call   f0103ee9 <cprintf>
		env_destroy(env); // may not return
f01035b6:	89 1c 24             	mov    %ebx,(%esp)
f01035b9:	e8 66 06 00 00       	call   f0103c24 <env_destroy>
}
f01035be:	83 c4 14             	add    $0x14,%esp
f01035c1:	5b                   	pop    %ebx
f01035c2:	5d                   	pop    %ebp
f01035c3:	c3                   	ret    

f01035c4 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
// 为环境 env 分配 len 字节的物理内存，并将其映射到环境地址空间中的虚拟地址 va。
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01035c4:	55                   	push   %ebp
f01035c5:	89 e5                	mov    %esp,%ebp
f01035c7:	57                   	push   %edi
f01035c8:	56                   	push   %esi
f01035c9:	53                   	push   %ebx
f01035ca:	83 ec 1c             	sub    $0x1c,%esp
f01035cd:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *start = ROUNDDOWN(va, PGSIZE);
f01035cf:	89 d3                	mov    %edx,%ebx
f01035d1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	void *end = ROUNDUP(va + len, PGSIZE);
f01035d7:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f01035de:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (; start < end; start += PGSIZE)
f01035e4:	eb 6d                	jmp    f0103653 <region_alloc+0x8f>
	{
		struct PageInfo *p = page_alloc(0);
f01035e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035ed:	e8 2e db ff ff       	call   f0101120 <page_alloc>
		if (p == NULL)
f01035f2:	85 c0                	test   %eax,%eax
f01035f4:	75 1c                	jne    f0103612 <region_alloc+0x4e>
		{
			panic("region_alloc: error in page_alloc()\n"); // 分配失败
f01035f6:	c7 44 24 08 74 7d 10 	movl   $0xf0107d74,0x8(%esp)
f01035fd:	f0 
f01035fe:	c7 44 24 04 38 01 00 	movl   $0x138,0x4(%esp)
f0103605:	00 
f0103606:	c7 04 24 0d 7e 10 f0 	movl   $0xf0107e0d,(%esp)
f010360d:	e8 2e ca ff ff       	call   f0100040 <_panic>
		}
		if (page_insert(e->env_pgdir, p, start, PTE_W | PTE_U))
f0103612:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103619:	00 
f010361a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010361e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103622:	8b 47 60             	mov    0x60(%edi),%eax
f0103625:	89 04 24             	mov    %eax,(%esp)
f0103628:	e8 25 de ff ff       	call   f0101452 <page_insert>
f010362d:	85 c0                	test   %eax,%eax
f010362f:	74 1c                	je     f010364d <region_alloc+0x89>
		{
			panic("region_alloc: error in page_insert()\n"); // 插入失败
f0103631:	c7 44 24 08 9c 7d 10 	movl   $0xf0107d9c,0x8(%esp)
f0103638:	f0 
f0103639:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
f0103640:	00 
f0103641:	c7 04 24 0d 7e 10 f0 	movl   $0xf0107e0d,(%esp)
f0103648:	e8 f3 c9 ff ff       	call   f0100040 <_panic>
	for (; start < end; start += PGSIZE)
f010364d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103653:	39 f3                	cmp    %esi,%ebx
f0103655:	72 8f                	jb     f01035e6 <region_alloc+0x22>
		}
	}
}
f0103657:	83 c4 1c             	add    $0x1c,%esp
f010365a:	5b                   	pop    %ebx
f010365b:	5e                   	pop    %esi
f010365c:	5f                   	pop    %edi
f010365d:	5d                   	pop    %ebp
f010365e:	c3                   	ret    

f010365f <envid2env>:
{
f010365f:	55                   	push   %ebp
f0103660:	89 e5                	mov    %esp,%ebp
f0103662:	56                   	push   %esi
f0103663:	53                   	push   %ebx
f0103664:	8b 45 08             	mov    0x8(%ebp),%eax
f0103667:	8b 55 10             	mov    0x10(%ebp),%edx
	if (envid == 0)
f010366a:	85 c0                	test   %eax,%eax
f010366c:	75 1a                	jne    f0103688 <envid2env+0x29>
		*env_store = curenv;
f010366e:	e8 f6 2d 00 00       	call   f0106469 <cpunum>
f0103673:	6b c0 74             	imul   $0x74,%eax,%eax
f0103676:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f010367c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010367f:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103681:	b8 00 00 00 00       	mov    $0x0,%eax
f0103686:	eb 70                	jmp    f01036f8 <envid2env+0x99>
	e = &envs[ENVX(envid)];
f0103688:	89 c3                	mov    %eax,%ebx
f010368a:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103690:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103693:	03 1d 48 92 1e f0    	add    0xf01e9248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid)
f0103699:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010369d:	74 05                	je     f01036a4 <envid2env+0x45>
f010369f:	39 43 48             	cmp    %eax,0x48(%ebx)
f01036a2:	74 10                	je     f01036b4 <envid2env+0x55>
		*env_store = 0;
f01036a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036a7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01036ad:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01036b2:	eb 44                	jmp    f01036f8 <envid2env+0x99>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id)
f01036b4:	84 d2                	test   %dl,%dl
f01036b6:	74 36                	je     f01036ee <envid2env+0x8f>
f01036b8:	e8 ac 2d 00 00       	call   f0106469 <cpunum>
f01036bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01036c0:	39 98 28 a0 1e f0    	cmp    %ebx,-0xfe15fd8(%eax)
f01036c6:	74 26                	je     f01036ee <envid2env+0x8f>
f01036c8:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01036cb:	e8 99 2d 00 00       	call   f0106469 <cpunum>
f01036d0:	6b c0 74             	imul   $0x74,%eax,%eax
f01036d3:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f01036d9:	3b 70 48             	cmp    0x48(%eax),%esi
f01036dc:	74 10                	je     f01036ee <envid2env+0x8f>
		*env_store = 0;
f01036de:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01036e7:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01036ec:	eb 0a                	jmp    f01036f8 <envid2env+0x99>
	*env_store = e;
f01036ee:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036f1:	89 18                	mov    %ebx,(%eax)
	return 0;
f01036f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01036f8:	5b                   	pop    %ebx
f01036f9:	5e                   	pop    %esi
f01036fa:	5d                   	pop    %ebp
f01036fb:	c3                   	ret    

f01036fc <env_init_percpu>:
{
f01036fc:	55                   	push   %ebp
f01036fd:	89 e5                	mov    %esp,%ebp
	asm volatile("lgdt (%0)" : : "r" (p));
f01036ff:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f0103704:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs"
f0103707:	b8 23 00 00 00       	mov    $0x23,%eax
f010370c:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs"
f010370e:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es"
f0103710:	b0 10                	mov    $0x10,%al
f0103712:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds"
f0103714:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss"
f0103716:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n"
f0103718:	ea 1f 37 10 f0 08 00 	ljmp   $0x8,$0xf010371f
	asm volatile("lldt %0" : : "r" (sel));
f010371f:	b0 00                	mov    $0x0,%al
f0103721:	0f 00 d0             	lldt   %ax
}
f0103724:	5d                   	pop    %ebp
f0103725:	c3                   	ret    

f0103726 <env_init>:
{
f0103726:	55                   	push   %ebp
f0103727:	89 e5                	mov    %esp,%ebp
f0103729:	56                   	push   %esi
f010372a:	53                   	push   %ebx
		envs[i].env_id = 0;
f010372b:	8b 35 48 92 1e f0    	mov    0xf01e9248,%esi
f0103731:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0103737:	ba 00 04 00 00       	mov    $0x400,%edx
f010373c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103741:	89 c3                	mov    %eax,%ebx
f0103743:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status = ENV_FREE;
f010374a:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link = env_free_list;
f0103751:	89 48 44             	mov    %ecx,0x44(%eax)
f0103754:	83 e8 7c             	sub    $0x7c,%eax
	for (int i = NENV - 1; i >= 0; i--) // 倒着遍历数组，让最后的元素出现在链表底部
f0103757:	83 ea 01             	sub    $0x1,%edx
f010375a:	74 04                	je     f0103760 <env_init+0x3a>
		env_free_list = &envs[i];
f010375c:	89 d9                	mov    %ebx,%ecx
f010375e:	eb e1                	jmp    f0103741 <env_init+0x1b>
f0103760:	89 35 4c 92 1e f0    	mov    %esi,0xf01e924c
	env_init_percpu();
f0103766:	e8 91 ff ff ff       	call   f01036fc <env_init_percpu>
}
f010376b:	5b                   	pop    %ebx
f010376c:	5e                   	pop    %esi
f010376d:	5d                   	pop    %ebp
f010376e:	c3                   	ret    

f010376f <env_alloc>:
{
f010376f:	55                   	push   %ebp
f0103770:	89 e5                	mov    %esp,%ebp
f0103772:	53                   	push   %ebx
f0103773:	83 ec 14             	sub    $0x14,%esp
	if (!(e = env_free_list)) // 如果env_free_list==null就会在这
f0103776:	8b 1d 4c 92 1e f0    	mov    0xf01e924c,%ebx
f010377c:	85 db                	test   %ebx,%ebx
f010377e:	0f 84 50 01 00 00    	je     f01038d4 <env_alloc+0x165>
	if (!(p = page_alloc(ALLOC_ZERO))) // 分配一页给页表目录
f0103784:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010378b:	e8 90 d9 ff ff       	call   f0101120 <page_alloc>
f0103790:	85 c0                	test   %eax,%eax
f0103792:	0f 84 43 01 00 00    	je     f01038db <env_alloc+0x16c>
	p->pp_ref++;
f0103798:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f010379d:	2b 05 90 9e 1e f0    	sub    0xf01e9e90,%eax
f01037a3:	c1 f8 03             	sar    $0x3,%eax
f01037a6:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01037a9:	89 c2                	mov    %eax,%edx
f01037ab:	c1 ea 0c             	shr    $0xc,%edx
f01037ae:	3b 15 88 9e 1e f0    	cmp    0xf01e9e88,%edx
f01037b4:	72 20                	jb     f01037d6 <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01037b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037ba:	c7 44 24 08 64 6b 10 	movl   $0xf0106b64,0x8(%esp)
f01037c1:	f0 
f01037c2:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01037c9:	00 
f01037ca:	c7 04 24 c5 7a 10 f0 	movl   $0xf0107ac5,(%esp)
f01037d1:	e8 6a c8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01037d6:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = page2kva(p);
f01037db:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE); // 把内核页表复制一份放在用户能访问的用户空间里(即env_pgdir处)
f01037de:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01037e5:	00 
f01037e6:	8b 15 8c 9e 1e f0    	mov    0xf01e9e8c,%edx
f01037ec:	89 54 24 04          	mov    %edx,0x4(%esp)
f01037f0:	89 04 24             	mov    %eax,(%esp)
f01037f3:	e8 d4 26 00 00       	call   f0105ecc <memcpy>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01037f8:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01037fb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103800:	77 20                	ja     f0103822 <env_alloc+0xb3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103802:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103806:	c7 44 24 08 88 6b 10 	movl   $0xf0106b88,0x8(%esp)
f010380d:	f0 
f010380e:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
f0103815:	00 
f0103816:	c7 04 24 0d 7e 10 f0 	movl   $0xf0107e0d,(%esp)
f010381d:	e8 1e c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103822:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103828:	83 ca 05             	or     $0x5,%edx
f010382b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103831:	8b 43 48             	mov    0x48(%ebx),%eax
f0103834:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0) // Don't create a negative env_id.
f0103839:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f010383e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103843:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103846:	89 da                	mov    %ebx,%edx
f0103848:	2b 15 48 92 1e f0    	sub    0xf01e9248,%edx
f010384e:	c1 fa 02             	sar    $0x2,%edx
f0103851:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103857:	09 d0                	or     %edx,%eax
f0103859:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f010385c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010385f:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103862:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103869:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103870:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103877:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f010387e:	00 
f010387f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103886:	00 
f0103887:	89 1c 24             	mov    %ebx,(%esp)
f010388a:	e8 88 25 00 00       	call   f0105e17 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f010388f:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103895:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010389b:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01038a1:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01038a8:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_tf.tf_eflags |= FL_IF;
f01038ae:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f01038b5:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f01038bc:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f01038c0:	8b 43 44             	mov    0x44(%ebx),%eax
f01038c3:	a3 4c 92 1e f0       	mov    %eax,0xf01e924c
	*newenv_store = e;
f01038c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01038cb:	89 18                	mov    %ebx,(%eax)
	return 0;
f01038cd:	b8 00 00 00 00       	mov    $0x0,%eax
f01038d2:	eb 0c                	jmp    f01038e0 <env_alloc+0x171>
		return -E_NO_FREE_ENV;
f01038d4:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01038d9:	eb 05                	jmp    f01038e0 <env_alloc+0x171>
		return -E_NO_MEM;
f01038db:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
f01038e0:	83 c4 14             	add    $0x14,%esp
f01038e3:	5b                   	pop    %ebx
f01038e4:	5d                   	pop    %ebp
f01038e5:	c3                   	ret    

f01038e6 <env_create>:
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
// 使用 env_alloc 分配一个新环境，使用 load_icode 将命名的 elf 二进制文件加载到其中，并设置其 env_type
void env_create(uint8_t *binary, enum EnvType type)
{
f01038e6:	55                   	push   %ebp
f01038e7:	89 e5                	mov    %esp,%ebp
f01038e9:	57                   	push   %edi
f01038ea:	56                   	push   %esi
f01038eb:	53                   	push   %ebx
f01038ec:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 3: Your code here.
	struct Env *e;
	if (env_alloc(&e, 0))
f01038ef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01038f6:	00 
f01038f7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01038fa:	89 04 24             	mov    %eax,(%esp)
f01038fd:	e8 6d fe ff ff       	call   f010376f <env_alloc>
f0103902:	85 c0                	test   %eax,%eax
f0103904:	74 1c                	je     f0103922 <env_create+0x3c>
	{
		panic("env_create: error in env_alloc()");
f0103906:	c7 44 24 08 c4 7d 10 	movl   $0xf0107dc4,0x8(%esp)
f010390d:	f0 
f010390e:	c7 44 24 04 a1 01 00 	movl   $0x1a1,0x4(%esp)
f0103915:	00 
f0103916:	c7 04 24 0d 7e 10 f0 	movl   $0xf0107e0d,(%esp)
f010391d:	e8 1e c7 ff ff       	call   f0100040 <_panic>
	}
	load_icode(e, binary);
f0103922:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	if (ELFHDR->e_magic != ELF_MAGIC)
f0103925:	8b 45 08             	mov    0x8(%ebp),%eax
f0103928:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f010392e:	74 1c                	je     f010394c <env_create+0x66>
		panic("load_icode: ELFHDR is not ELF_MAGIC\n");
f0103930:	c7 44 24 08 e8 7d 10 	movl   $0xf0107de8,0x8(%esp)
f0103937:	f0 
f0103938:	c7 44 24 04 7a 01 00 	movl   $0x17a,0x4(%esp)
f010393f:	00 
f0103940:	c7 04 24 0d 7e 10 f0 	movl   $0xf0107e0d,(%esp)
f0103947:	e8 f4 c6 ff ff       	call   f0100040 <_panic>
	ph = (struct Proghdr *)((uint8_t *)ELFHDR + ELFHDR->e_phoff); // ELFHDR+offset是段的起始地址
f010394c:	8b 45 08             	mov    0x8(%ebp),%eax
f010394f:	89 c3                	mov    %eax,%ebx
f0103951:	03 58 1c             	add    0x1c(%eax),%ebx
	eph = ph + ELFHDR->e_phnum;									  // end地址
f0103954:	0f b7 70 2c          	movzwl 0x2c(%eax),%esi
f0103958:	c1 e6 05             	shl    $0x5,%esi
f010395b:	01 de                	add    %ebx,%esi
	lcr3(PADDR(e->env_pgdir));									  // 切换到用户空间
f010395d:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103960:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103965:	77 20                	ja     f0103987 <env_create+0xa1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103967:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010396b:	c7 44 24 08 88 6b 10 	movl   $0xf0106b88,0x8(%esp)
f0103972:	f0 
f0103973:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
f010397a:	00 
f010397b:	c7 04 24 0d 7e 10 f0 	movl   $0xf0107e0d,(%esp)
f0103982:	e8 b9 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103987:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010398c:	0f 22 d8             	mov    %eax,%cr3
f010398f:	eb 4b                	jmp    f01039dc <env_create+0xf6>
		if (ph->p_type == ELF_PROG_LOAD)
f0103991:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103994:	75 43                	jne    f01039d9 <env_create+0xf3>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);						   // 先分配内存空间
f0103996:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103999:	8b 53 08             	mov    0x8(%ebx),%edx
f010399c:	89 f8                	mov    %edi,%eax
f010399e:	e8 21 fc ff ff       	call   f01035c4 <region_alloc>
			memset((void *)ph->p_va, 0, ph->p_memsz);							   // 将内存空间初始化为0
f01039a3:	8b 43 14             	mov    0x14(%ebx),%eax
f01039a6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01039b1:	00 
f01039b2:	8b 43 08             	mov    0x8(%ebx),%eax
f01039b5:	89 04 24             	mov    %eax,(%esp)
f01039b8:	e8 5a 24 00 00       	call   f0105e17 <memset>
			memcpy((void *)ph->p_va, (void *)ELFHDR + ph->p_offset, ph->p_filesz); // 复制内容到刚刚分配的空间
f01039bd:	8b 43 10             	mov    0x10(%ebx),%eax
f01039c0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01039c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01039c7:	03 43 04             	add    0x4(%ebx),%eax
f01039ca:	89 44 24 04          	mov    %eax,0x4(%esp)
f01039ce:	8b 43 08             	mov    0x8(%ebx),%eax
f01039d1:	89 04 24             	mov    %eax,(%esp)
f01039d4:	e8 f3 24 00 00       	call   f0105ecc <memcpy>
	for (; ph < eph; ph++)										  // 依次读取所有段
f01039d9:	83 c3 20             	add    $0x20,%ebx
f01039dc:	39 de                	cmp    %ebx,%esi
f01039de:	77 b1                	ja     f0103991 <env_create+0xab>
	lcr3(PADDR(kern_pgdir));							 // 切换到内核空间
f01039e0:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01039e5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039ea:	77 20                	ja     f0103a0c <env_create+0x126>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039f0:	c7 44 24 08 88 6b 10 	movl   $0xf0106b88,0x8(%esp)
f01039f7:	f0 
f01039f8:	c7 44 24 04 8d 01 00 	movl   $0x18d,0x4(%esp)
f01039ff:	00 
f0103a00:	c7 04 24 0d 7e 10 f0 	movl   $0xf0107e0d,(%esp)
f0103a07:	e8 34 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a0c:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a11:	0f 22 d8             	mov    %eax,%cr3
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE); // 为程序的初始堆栈(地址:USTACKTOP - PGSIZE)映射一页
f0103a14:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103a19:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103a1e:	89 f8                	mov    %edi,%eax
f0103a20:	e8 9f fb ff ff       	call   f01035c4 <region_alloc>
	e->env_status = ENV_RUNNABLE;						 // 设置程序状态
f0103a25:	c7 47 54 02 00 00 00 	movl   $0x2,0x54(%edi)
	e->env_tf.tf_esp = USTACKTOP;						 // 设置程序堆栈
f0103a2c:	c7 47 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%edi)
	e->env_tf.tf_eip = ELFHDR->e_entry;					 // 设置程序入口
f0103a33:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a36:	8b 40 18             	mov    0x18(%eax),%eax
f0103a39:	89 47 30             	mov    %eax,0x30(%edi)
	e->env_type = type;
f0103a3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a3f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103a42:	89 50 50             	mov    %edx,0x50(%eax)

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
	if (type == ENV_TYPE_FS)
f0103a45:	83 fa 01             	cmp    $0x1,%edx
f0103a48:	75 07                	jne    f0103a51 <env_create+0x16b>
	{
		e->env_tf.tf_eflags |= FL_IOPL_MASK;
f0103a4a:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
	}
}
f0103a51:	83 c4 2c             	add    $0x2c,%esp
f0103a54:	5b                   	pop    %ebx
f0103a55:	5e                   	pop    %esi
f0103a56:	5f                   	pop    %edi
f0103a57:	5d                   	pop    %ebp
f0103a58:	c3                   	ret    

f0103a59 <env_free>:

//
// Frees env e and all memory it uses.
//
void env_free(struct Env *e)
{
f0103a59:	55                   	push   %ebp
f0103a5a:	89 e5                	mov    %esp,%ebp
f0103a5c:	57                   	push   %edi
f0103a5d:	56                   	push   %esi
f0103a5e:	53                   	push   %ebx
f0103a5f:	83 ec 2c             	sub    $0x2c,%esp
f0103a62:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103a65:	e8 ff 29 00 00       	call   f0106469 <cpunum>
f0103a6a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a6d:	39 b8 28 a0 1e f0    	cmp    %edi,-0xfe15fd8(%eax)
f0103a73:	74 09                	je     f0103a7e <env_free+0x25>
{
f0103a75:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103a7c:	eb 36                	jmp    f0103ab4 <env_free+0x5b>
		lcr3(PADDR(kern_pgdir));
f0103a7e:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103a83:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a88:	77 20                	ja     f0103aaa <env_free+0x51>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a8a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a8e:	c7 44 24 08 88 6b 10 	movl   $0xf0106b88,0x8(%esp)
f0103a95:	f0 
f0103a96:	c7 44 24 04 bb 01 00 	movl   $0x1bb,0x4(%esp)
f0103a9d:	00 
f0103a9e:	c7 04 24 0d 7e 10 f0 	movl   $0xf0107e0d,(%esp)
f0103aa5:	e8 96 c5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103aaa:	05 00 00 00 10       	add    $0x10000000,%eax
f0103aaf:	0f 22 d8             	mov    %eax,%cr3
f0103ab2:	eb c1                	jmp    f0103a75 <env_free+0x1c>
f0103ab4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103ab7:	89 c8                	mov    %ecx,%eax
f0103ab9:	c1 e0 02             	shl    $0x2,%eax
f0103abc:	89 45 dc             	mov    %eax,-0x24(%ebp)
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++)
	{

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103abf:	8b 47 60             	mov    0x60(%edi),%eax
f0103ac2:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f0103ac5:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103acb:	0f 84 b7 00 00 00    	je     f0103b88 <env_free+0x12f>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103ad1:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0103ad7:	89 f0                	mov    %esi,%eax
f0103ad9:	c1 e8 0c             	shr    $0xc,%eax
f0103adc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103adf:	3b 05 88 9e 1e f0    	cmp    0xf01e9e88,%eax
f0103ae5:	72 20                	jb     f0103b07 <env_free+0xae>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103ae7:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103aeb:	c7 44 24 08 64 6b 10 	movl   $0xf0106b64,0x8(%esp)
f0103af2:	f0 
f0103af3:	c7 44 24 04 cb 01 00 	movl   $0x1cb,0x4(%esp)
f0103afa:	00 
f0103afb:	c7 04 24 0d 7e 10 f0 	movl   $0xf0107e0d,(%esp)
f0103b02:	e8 39 c5 ff ff       	call   f0100040 <_panic>

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++)
		{
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b07:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b0a:	c1 e0 16             	shl    $0x16,%eax
f0103b0d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++)
f0103b10:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103b15:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103b1c:	01 
f0103b1d:	74 17                	je     f0103b36 <env_free+0xdd>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b1f:	89 d8                	mov    %ebx,%eax
f0103b21:	c1 e0 0c             	shl    $0xc,%eax
f0103b24:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103b27:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b2b:	8b 47 60             	mov    0x60(%edi),%eax
f0103b2e:	89 04 24             	mov    %eax,(%esp)
f0103b31:	e8 d3 d8 ff ff       	call   f0101409 <page_remove>
		for (pteno = 0; pteno <= PTX(~0); pteno++)
f0103b36:	83 c3 01             	add    $0x1,%ebx
f0103b39:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103b3f:	75 d4                	jne    f0103b15 <env_free+0xbc>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103b41:	8b 47 60             	mov    0x60(%edi),%eax
f0103b44:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b47:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103b4e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103b51:	3b 05 88 9e 1e f0    	cmp    0xf01e9e88,%eax
f0103b57:	72 1c                	jb     f0103b75 <env_free+0x11c>
		panic("pa2page called with invalid pa");
f0103b59:	c7 44 24 08 b4 71 10 	movl   $0xf01071b4,0x8(%esp)
f0103b60:	f0 
f0103b61:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103b68:	00 
f0103b69:	c7 04 24 c5 7a 10 f0 	movl   $0xf0107ac5,(%esp)
f0103b70:	e8 cb c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103b75:	a1 90 9e 1e f0       	mov    0xf01e9e90,%eax
f0103b7a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103b7d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0103b80:	89 04 24             	mov    %eax,(%esp)
f0103b83:	e8 69 d6 ff ff       	call   f01011f1 <page_decref>
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++)
f0103b88:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103b8c:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103b93:	0f 85 1b ff ff ff    	jne    f0103ab4 <env_free+0x5b>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103b99:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103b9c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ba1:	77 20                	ja     f0103bc3 <env_free+0x16a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ba3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ba7:	c7 44 24 08 88 6b 10 	movl   $0xf0106b88,0x8(%esp)
f0103bae:	f0 
f0103baf:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
f0103bb6:	00 
f0103bb7:	c7 04 24 0d 7e 10 f0 	movl   $0xf0107e0d,(%esp)
f0103bbe:	e8 7d c4 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103bc3:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103bca:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103bcf:	c1 e8 0c             	shr    $0xc,%eax
f0103bd2:	3b 05 88 9e 1e f0    	cmp    0xf01e9e88,%eax
f0103bd8:	72 1c                	jb     f0103bf6 <env_free+0x19d>
		panic("pa2page called with invalid pa");
f0103bda:	c7 44 24 08 b4 71 10 	movl   $0xf01071b4,0x8(%esp)
f0103be1:	f0 
f0103be2:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103be9:	00 
f0103bea:	c7 04 24 c5 7a 10 f0 	movl   $0xf0107ac5,(%esp)
f0103bf1:	e8 4a c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103bf6:	8b 15 90 9e 1e f0    	mov    0xf01e9e90,%edx
f0103bfc:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f0103bff:	89 04 24             	mov    %eax,(%esp)
f0103c02:	e8 ea d5 ff ff       	call   f01011f1 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103c07:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103c0e:	a1 4c 92 1e f0       	mov    0xf01e924c,%eax
f0103c13:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103c16:	89 3d 4c 92 1e f0    	mov    %edi,0xf01e924c
}
f0103c1c:	83 c4 2c             	add    $0x2c,%esp
f0103c1f:	5b                   	pop    %ebx
f0103c20:	5e                   	pop    %esi
f0103c21:	5f                   	pop    %edi
f0103c22:	5d                   	pop    %ebp
f0103c23:	c3                   	ret    

f0103c24 <env_destroy>:
// Frees environment e.
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void env_destroy(struct Env *e)
{
f0103c24:	55                   	push   %ebp
f0103c25:	89 e5                	mov    %esp,%ebp
f0103c27:	53                   	push   %ebx
f0103c28:	83 ec 14             	sub    $0x14,%esp
f0103c2b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c2e:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103c32:	75 19                	jne    f0103c4d <env_destroy+0x29>
f0103c34:	e8 30 28 00 00       	call   f0106469 <cpunum>
f0103c39:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c3c:	39 98 28 a0 1e f0    	cmp    %ebx,-0xfe15fd8(%eax)
f0103c42:	74 09                	je     f0103c4d <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103c44:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103c4b:	eb 2f                	jmp    f0103c7c <env_destroy+0x58>
	}

	env_free(e);
f0103c4d:	89 1c 24             	mov    %ebx,(%esp)
f0103c50:	e8 04 fe ff ff       	call   f0103a59 <env_free>

	if (curenv == e) {
f0103c55:	e8 0f 28 00 00       	call   f0106469 <cpunum>
f0103c5a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c5d:	39 98 28 a0 1e f0    	cmp    %ebx,-0xfe15fd8(%eax)
f0103c63:	75 17                	jne    f0103c7c <env_destroy+0x58>
		curenv = NULL;
f0103c65:	e8 ff 27 00 00       	call   f0106469 <cpunum>
f0103c6a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c6d:	c7 80 28 a0 1e f0 00 	movl   $0x0,-0xfe15fd8(%eax)
f0103c74:	00 00 00 
		sched_yield();
f0103c77:	e8 b5 0e 00 00       	call   f0104b31 <sched_yield>
	}
}
f0103c7c:	83 c4 14             	add    $0x14,%esp
f0103c7f:	5b                   	pop    %ebx
f0103c80:	5d                   	pop    %ebp
f0103c81:	c3                   	ret    

f0103c82 <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
//
// This function does not return.
//
void env_pop_tf(struct Trapframe *tf)
{
f0103c82:	55                   	push   %ebp
f0103c83:	89 e5                	mov    %esp,%ebp
f0103c85:	53                   	push   %ebx
f0103c86:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103c89:	e8 db 27 00 00       	call   f0106469 <cpunum>
f0103c8e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c91:	8b 98 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%ebx
f0103c97:	e8 cd 27 00 00       	call   f0106469 <cpunum>
f0103c9c:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103c9f:	8b 65 08             	mov    0x8(%ebp),%esp
f0103ca2:	61                   	popa   
f0103ca3:	07                   	pop    %es
f0103ca4:	1f                   	pop    %ds
f0103ca5:	83 c4 08             	add    $0x8,%esp
f0103ca8:	cf                   	iret   
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		:
		: "g"(tf)
		: "memory");
	panic("iret failed"); /* mostly to placate the compiler */
f0103ca9:	c7 44 24 08 18 7e 10 	movl   $0xf0107e18,0x8(%esp)
f0103cb0:	f0 
f0103cb1:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
f0103cb8:	00 
f0103cb9:	c7 04 24 0d 7e 10 f0 	movl   $0xf0107e0d,(%esp)
f0103cc0:	e8 7b c3 ff ff       	call   f0100040 <_panic>

f0103cc5 <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//
// This function does not return.
// 把环境从curenv 切换到 e
void env_run(struct Env *e)
{
f0103cc5:	55                   	push   %ebp
f0103cc6:	89 e5                	mov    %esp,%ebp
f0103cc8:	53                   	push   %ebx
f0103cc9:	83 ec 14             	sub    $0x14,%esp
f0103ccc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	if (curenv) // 如果当前有环境
f0103ccf:	e8 95 27 00 00       	call   f0106469 <cpunum>
f0103cd4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cd7:	83 b8 28 a0 1e f0 00 	cmpl   $0x0,-0xfe15fd8(%eax)
f0103cde:	74 15                	je     f0103cf5 <env_run+0x30>
	{
		curenv->env_status = ENV_RUNNABLE; // 设置回 ENV_RUNNABLE
f0103ce0:	e8 84 27 00 00       	call   f0106469 <cpunum>
f0103ce5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ce8:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f0103cee:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
	curenv = e;						  // 将“curenv”设置为新环境
f0103cf5:	e8 6f 27 00 00       	call   f0106469 <cpunum>
f0103cfa:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cfd:	89 98 28 a0 1e f0    	mov    %ebx,-0xfe15fd8(%eax)
	curenv->env_status = ENV_RUNNING; // 将其状态设置为 ENV_RUNNING
f0103d03:	e8 61 27 00 00       	call   f0106469 <cpunum>
f0103d08:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d0b:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f0103d11:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;				  // 更新其“env_runs”计数器
f0103d18:	e8 4c 27 00 00       	call   f0106469 <cpunum>
f0103d1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d20:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f0103d26:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));	  // 切换到用户空间
f0103d2a:	e8 3a 27 00 00       	call   f0106469 <cpunum>
f0103d2f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d32:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f0103d38:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103d3b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103d40:	77 20                	ja     f0103d62 <env_run+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d42:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d46:	c7 44 24 08 88 6b 10 	movl   $0xf0106b88,0x8(%esp)
f0103d4d:	f0 
f0103d4e:	c7 44 24 04 35 02 00 	movl   $0x235,0x4(%esp)
f0103d55:	00 
f0103d56:	c7 04 24 0d 7e 10 f0 	movl   $0xf0107e0d,(%esp)
f0103d5d:	e8 de c2 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103d62:	05 00 00 00 10       	add    $0x10000000,%eax
f0103d67:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103d6a:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0103d71:	e8 1d 2a 00 00       	call   f0106793 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103d76:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(&e->env_tf); // 恢复环境的寄存器来进入环境中的用户模式，设置%eip为可执行程序的第一条指令
f0103d78:	89 1c 24             	mov    %ebx,(%esp)
f0103d7b:	e8 02 ff ff ff       	call   f0103c82 <env_pop_tf>

f0103d80 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103d80:	55                   	push   %ebp
f0103d81:	89 e5                	mov    %esp,%ebp
f0103d83:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103d87:	ba 70 00 00 00       	mov    $0x70,%edx
f0103d8c:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103d8d:	b2 71                	mov    $0x71,%dl
f0103d8f:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103d90:	0f b6 c0             	movzbl %al,%eax
}
f0103d93:	5d                   	pop    %ebp
f0103d94:	c3                   	ret    

f0103d95 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103d95:	55                   	push   %ebp
f0103d96:	89 e5                	mov    %esp,%ebp
f0103d98:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103d9c:	ba 70 00 00 00       	mov    $0x70,%edx
f0103da1:	ee                   	out    %al,(%dx)
f0103da2:	b2 71                	mov    $0x71,%dl
f0103da4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103da7:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103da8:	5d                   	pop    %ebp
f0103da9:	c3                   	ret    

f0103daa <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103daa:	55                   	push   %ebp
f0103dab:	89 e5                	mov    %esp,%ebp
f0103dad:	56                   	push   %esi
f0103dae:	53                   	push   %ebx
f0103daf:	83 ec 10             	sub    $0x10,%esp
f0103db2:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103db5:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f0103dbb:	80 3d 50 92 1e f0 00 	cmpb   $0x0,0xf01e9250
f0103dc2:	74 4e                	je     f0103e12 <irq_setmask_8259A+0x68>
f0103dc4:	89 c6                	mov    %eax,%esi
f0103dc6:	ba 21 00 00 00       	mov    $0x21,%edx
f0103dcb:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103dcc:	66 c1 e8 08          	shr    $0x8,%ax
f0103dd0:	b2 a1                	mov    $0xa1,%dl
f0103dd2:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103dd3:	c7 04 24 24 7e 10 f0 	movl   $0xf0107e24,(%esp)
f0103dda:	e8 0a 01 00 00       	call   f0103ee9 <cprintf>
	for (i = 0; i < 16; i++)
f0103ddf:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103de4:	0f b7 f6             	movzwl %si,%esi
f0103de7:	f7 d6                	not    %esi
f0103de9:	0f a3 de             	bt     %ebx,%esi
f0103dec:	73 10                	jae    f0103dfe <irq_setmask_8259A+0x54>
			cprintf(" %d", i);
f0103dee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103df2:	c7 04 24 ab 82 10 f0 	movl   $0xf01082ab,(%esp)
f0103df9:	e8 eb 00 00 00       	call   f0103ee9 <cprintf>
	for (i = 0; i < 16; i++)
f0103dfe:	83 c3 01             	add    $0x1,%ebx
f0103e01:	83 fb 10             	cmp    $0x10,%ebx
f0103e04:	75 e3                	jne    f0103de9 <irq_setmask_8259A+0x3f>
	cprintf("\n");
f0103e06:	c7 04 24 42 7d 10 f0 	movl   $0xf0107d42,(%esp)
f0103e0d:	e8 d7 00 00 00       	call   f0103ee9 <cprintf>
}
f0103e12:	83 c4 10             	add    $0x10,%esp
f0103e15:	5b                   	pop    %ebx
f0103e16:	5e                   	pop    %esi
f0103e17:	5d                   	pop    %ebp
f0103e18:	c3                   	ret    

f0103e19 <pic_init>:
	didinit = 1;
f0103e19:	c6 05 50 92 1e f0 01 	movb   $0x1,0xf01e9250
f0103e20:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103e2a:	ee                   	out    %al,(%dx)
f0103e2b:	b2 a1                	mov    $0xa1,%dl
f0103e2d:	ee                   	out    %al,(%dx)
f0103e2e:	b2 20                	mov    $0x20,%dl
f0103e30:	b8 11 00 00 00       	mov    $0x11,%eax
f0103e35:	ee                   	out    %al,(%dx)
f0103e36:	b2 21                	mov    $0x21,%dl
f0103e38:	b8 20 00 00 00       	mov    $0x20,%eax
f0103e3d:	ee                   	out    %al,(%dx)
f0103e3e:	b8 04 00 00 00       	mov    $0x4,%eax
f0103e43:	ee                   	out    %al,(%dx)
f0103e44:	b8 03 00 00 00       	mov    $0x3,%eax
f0103e49:	ee                   	out    %al,(%dx)
f0103e4a:	b2 a0                	mov    $0xa0,%dl
f0103e4c:	b8 11 00 00 00       	mov    $0x11,%eax
f0103e51:	ee                   	out    %al,(%dx)
f0103e52:	b2 a1                	mov    $0xa1,%dl
f0103e54:	b8 28 00 00 00       	mov    $0x28,%eax
f0103e59:	ee                   	out    %al,(%dx)
f0103e5a:	b8 02 00 00 00       	mov    $0x2,%eax
f0103e5f:	ee                   	out    %al,(%dx)
f0103e60:	b8 01 00 00 00       	mov    $0x1,%eax
f0103e65:	ee                   	out    %al,(%dx)
f0103e66:	b2 20                	mov    $0x20,%dl
f0103e68:	b8 68 00 00 00       	mov    $0x68,%eax
f0103e6d:	ee                   	out    %al,(%dx)
f0103e6e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103e73:	ee                   	out    %al,(%dx)
f0103e74:	b2 a0                	mov    $0xa0,%dl
f0103e76:	b8 68 00 00 00       	mov    $0x68,%eax
f0103e7b:	ee                   	out    %al,(%dx)
f0103e7c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103e81:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103e82:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0103e89:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103e8d:	74 12                	je     f0103ea1 <pic_init+0x88>
{
f0103e8f:	55                   	push   %ebp
f0103e90:	89 e5                	mov    %esp,%ebp
f0103e92:	83 ec 18             	sub    $0x18,%esp
		irq_setmask_8259A(irq_mask_8259A);
f0103e95:	0f b7 c0             	movzwl %ax,%eax
f0103e98:	89 04 24             	mov    %eax,(%esp)
f0103e9b:	e8 0a ff ff ff       	call   f0103daa <irq_setmask_8259A>
}
f0103ea0:	c9                   	leave  
f0103ea1:	f3 c3                	repz ret 

f0103ea3 <putch>:
#include <inc/stdio.h>
#include <inc/stdarg.h>

// putch通过调用console.c中的cputchar来实现输出字符串到控制台。
static void putch(int ch, int *cnt)
{
f0103ea3:	55                   	push   %ebp
f0103ea4:	89 e5                	mov    %esp,%ebp
f0103ea6:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103ea9:	8b 45 08             	mov    0x8(%ebp),%eax
f0103eac:	89 04 24             	mov    %eax,(%esp)
f0103eaf:	e8 13 c9 ff ff       	call   f01007c7 <cputchar>
	*cnt++;
}
f0103eb4:	c9                   	leave  
f0103eb5:	c3                   	ret    

f0103eb6 <vcprintf>:

// 将格式fmt和可变参数列表ap一起传给printfmt.c中的vprintfmt处理
int vcprintf(const char *fmt, va_list ap)
{
f0103eb6:	55                   	push   %ebp
f0103eb7:	89 e5                	mov    %esp,%ebp
f0103eb9:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103ebc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	vprintfmt((void *)putch, &cnt, fmt, ap); // 用一个指向putch的函数指针来告诉vprintfmt，处理后的数据应该交给putch来输出
f0103ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ec6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103eca:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ecd:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103ed1:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103ed4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ed8:	c7 04 24 a3 3e 10 f0 	movl   $0xf0103ea3,(%esp)
f0103edf:	e8 6a 18 00 00       	call   f010574e <vprintfmt>
	return cnt;
}
f0103ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103ee7:	c9                   	leave  
f0103ee8:	c3                   	ret    

f0103ee9 <cprintf>:

// 这个函数作为实现打印功能的主要函数，暴露给其他程序。其第一个参数是包含输出格式的字符串，后面是可变参数列表。
int cprintf(const char *fmt, ...)
{
f0103ee9:	55                   	push   %ebp
f0103eea:	89 e5                	mov    %esp,%ebp
f0103eec:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);		 // 获取可变参数列表ap
f0103eef:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap); // 传参
f0103ef2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ef6:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ef9:	89 04 24             	mov    %eax,(%esp)
f0103efc:	e8 b5 ff ff ff       	call   f0103eb6 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103f01:	c9                   	leave  
f0103f02:	c3                   	ret    
f0103f03:	66 90                	xchg   %ax,%ax
f0103f05:	66 90                	xchg   %ax,%ax
f0103f07:	66 90                	xchg   %ax,%ax
f0103f09:	66 90                	xchg   %ax,%ax
f0103f0b:	66 90                	xchg   %ax,%ax
f0103f0d:	66 90                	xchg   %ax,%ax
f0103f0f:	90                   	nop

f0103f10 <trap_init_percpu>:
	// Per-CPU setup
	trap_init_percpu();
}

void trap_init_percpu(void) // 初始化TSS和IDT
{
f0103f10:	55                   	push   %ebp
f0103f11:	89 e5                	mov    %esp,%ebp
f0103f13:	53                   	push   %ebx
f0103f14:	83 ec 04             	sub    $0x4,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	size_t i = cpunum();								   // 拿到现在运行的cpuid
f0103f17:	e8 4d 25 00 00       	call   f0106469 <cpunum>
	struct Taskstate *ts = &cpus[i].cpu_ts;				   // 这里这样取cpuinfo，因为直接用thiscpu会爆出triple fault
f0103f1c:	6b c8 74             	imul   $0x74,%eax,%ecx
	ts->ts_esp0 = (uintptr_t)percpu_kstacks[i] + KSTKSIZE; // esp0: 指代当前 CPU 的 stack 的起始位置
f0103f1f:	89 c2                	mov    %eax,%edx
f0103f21:	c1 e2 0f             	shl    $0xf,%edx
f0103f24:	81 c2 00 30 1f f0    	add    $0xf01f3000,%edx
f0103f2a:	89 91 30 a0 1e f0    	mov    %edx,-0xfe15fd0(%ecx)
	ts->ts_ss0 = GD_KD;									   // 表示 esp0 这个位置存储的是 kernel 的 data
f0103f30:	66 c7 81 34 a0 1e f0 	movw   $0x10,-0xfe15fcc(%ecx)
f0103f37:	10 00 
	ts->ts_iomb = sizeof(struct Taskstate);
f0103f39:	66 c7 81 92 a0 1e f0 	movw   $0x68,-0xfe15f6e(%ecx)
f0103f40:	68 00 
	struct Taskstate *ts = &cpus[i].cpu_ts;				   // 这里这样取cpuinfo，因为直接用thiscpu会爆出triple fault
f0103f42:	81 c1 2c a0 1e f0    	add    $0xf01ea02c,%ecx

	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t)ts, sizeof(struct Taskstate) - 1, 0);
f0103f48:	8d 50 05             	lea    0x5(%eax),%edx
f0103f4b:	66 c7 04 d5 40 13 12 	movw   $0x67,-0xfedecc0(,%edx,8)
f0103f52:	f0 67 00 
f0103f55:	66 89 0c d5 42 13 12 	mov    %cx,-0xfedecbe(,%edx,8)
f0103f5c:	f0 
f0103f5d:	89 cb                	mov    %ecx,%ebx
f0103f5f:	c1 eb 10             	shr    $0x10,%ebx
f0103f62:	88 1c d5 44 13 12 f0 	mov    %bl,-0xfedecbc(,%edx,8)
f0103f69:	c6 04 d5 46 13 12 f0 	movb   $0x40,-0xfedecba(,%edx,8)
f0103f70:	40 
f0103f71:	c1 e9 18             	shr    $0x18,%ecx
f0103f74:	88 0c d5 47 13 12 f0 	mov    %cl,-0xfedecb9(,%edx,8)
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f0103f7b:	c6 04 d5 45 13 12 f0 	movb   $0x89,-0xfedecbb(,%edx,8)
f0103f82:	89 

	ltr(GD_TSS0 + (i << 3));
f0103f83:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
	asm volatile("ltr %0" : : "r" (sel));
f0103f8a:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0103f8d:	b8 aa 13 12 f0       	mov    $0xf01213aa,%eax
f0103f92:	0f 01 18             	lidtl  (%eax)

	lidt(&idt_pd);
}
f0103f95:	83 c4 04             	add    $0x4,%esp
f0103f98:	5b                   	pop    %ebx
f0103f99:	5d                   	pop    %ebp
f0103f9a:	c3                   	ret    

f0103f9b <trap_init>:
{
f0103f9b:	55                   	push   %ebp
f0103f9c:	89 e5                	mov    %esp,%ebp
f0103f9e:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], 1, GD_KT, DIVIDE_Handler, 0); // SETGATE设置一个idt条目
f0103fa1:	b8 c8 49 10 f0       	mov    $0xf01049c8,%eax
f0103fa6:	66 a3 60 92 1e f0    	mov    %ax,0xf01e9260
f0103fac:	66 c7 05 62 92 1e f0 	movw   $0x8,0xf01e9262
f0103fb3:	08 00 
f0103fb5:	c6 05 64 92 1e f0 00 	movb   $0x0,0xf01e9264
f0103fbc:	c6 05 65 92 1e f0 8f 	movb   $0x8f,0xf01e9265
f0103fc3:	c1 e8 10             	shr    $0x10,%eax
f0103fc6:	66 a3 66 92 1e f0    	mov    %ax,0xf01e9266
	SETGATE(idt[T_DEBUG], 1, GD_KT, DEBUG_Handler, 3);
f0103fcc:	b8 ce 49 10 f0       	mov    $0xf01049ce,%eax
f0103fd1:	66 a3 68 92 1e f0    	mov    %ax,0xf01e9268
f0103fd7:	66 c7 05 6a 92 1e f0 	movw   $0x8,0xf01e926a
f0103fde:	08 00 
f0103fe0:	c6 05 6c 92 1e f0 00 	movb   $0x0,0xf01e926c
f0103fe7:	c6 05 6d 92 1e f0 ef 	movb   $0xef,0xf01e926d
f0103fee:	c1 e8 10             	shr    $0x10,%eax
f0103ff1:	66 a3 6e 92 1e f0    	mov    %ax,0xf01e926e
	SETGATE(idt[T_NMI], 1, GD_KT, NMI_Handler, 0);
f0103ff7:	b8 d4 49 10 f0       	mov    $0xf01049d4,%eax
f0103ffc:	66 a3 70 92 1e f0    	mov    %ax,0xf01e9270
f0104002:	66 c7 05 72 92 1e f0 	movw   $0x8,0xf01e9272
f0104009:	08 00 
f010400b:	c6 05 74 92 1e f0 00 	movb   $0x0,0xf01e9274
f0104012:	c6 05 75 92 1e f0 8f 	movb   $0x8f,0xf01e9275
f0104019:	c1 e8 10             	shr    $0x10,%eax
f010401c:	66 a3 76 92 1e f0    	mov    %ax,0xf01e9276
	SETGATE(idt[T_BRKPT], 1, GD_KT, BRKPT_Handler, 3);
f0104022:	b8 da 49 10 f0       	mov    $0xf01049da,%eax
f0104027:	66 a3 78 92 1e f0    	mov    %ax,0xf01e9278
f010402d:	66 c7 05 7a 92 1e f0 	movw   $0x8,0xf01e927a
f0104034:	08 00 
f0104036:	c6 05 7c 92 1e f0 00 	movb   $0x0,0xf01e927c
f010403d:	c6 05 7d 92 1e f0 ef 	movb   $0xef,0xf01e927d
f0104044:	c1 e8 10             	shr    $0x10,%eax
f0104047:	66 a3 7e 92 1e f0    	mov    %ax,0xf01e927e
	SETGATE(idt[T_OFLOW], 1, GD_KT, OFLOW_Handler, 0);
f010404d:	b8 e0 49 10 f0       	mov    $0xf01049e0,%eax
f0104052:	66 a3 80 92 1e f0    	mov    %ax,0xf01e9280
f0104058:	66 c7 05 82 92 1e f0 	movw   $0x8,0xf01e9282
f010405f:	08 00 
f0104061:	c6 05 84 92 1e f0 00 	movb   $0x0,0xf01e9284
f0104068:	c6 05 85 92 1e f0 8f 	movb   $0x8f,0xf01e9285
f010406f:	c1 e8 10             	shr    $0x10,%eax
f0104072:	66 a3 86 92 1e f0    	mov    %ax,0xf01e9286
	SETGATE(idt[T_BOUND], 1, GD_KT, BOUND_Handler, 0);
f0104078:	b8 e6 49 10 f0       	mov    $0xf01049e6,%eax
f010407d:	66 a3 88 92 1e f0    	mov    %ax,0xf01e9288
f0104083:	66 c7 05 8a 92 1e f0 	movw   $0x8,0xf01e928a
f010408a:	08 00 
f010408c:	c6 05 8c 92 1e f0 00 	movb   $0x0,0xf01e928c
f0104093:	c6 05 8d 92 1e f0 8f 	movb   $0x8f,0xf01e928d
f010409a:	c1 e8 10             	shr    $0x10,%eax
f010409d:	66 a3 8e 92 1e f0    	mov    %ax,0xf01e928e
	SETGATE(idt[T_ILLOP], 1, GD_KT, ILLOP_Handler, 0);
f01040a3:	b8 ec 49 10 f0       	mov    $0xf01049ec,%eax
f01040a8:	66 a3 90 92 1e f0    	mov    %ax,0xf01e9290
f01040ae:	66 c7 05 92 92 1e f0 	movw   $0x8,0xf01e9292
f01040b5:	08 00 
f01040b7:	c6 05 94 92 1e f0 00 	movb   $0x0,0xf01e9294
f01040be:	c6 05 95 92 1e f0 8f 	movb   $0x8f,0xf01e9295
f01040c5:	c1 e8 10             	shr    $0x10,%eax
f01040c8:	66 a3 96 92 1e f0    	mov    %ax,0xf01e9296
	SETGATE(idt[T_DEVICE], 1, GD_KT, DEVICE_Handler, 0);
f01040ce:	b8 f2 49 10 f0       	mov    $0xf01049f2,%eax
f01040d3:	66 a3 98 92 1e f0    	mov    %ax,0xf01e9298
f01040d9:	66 c7 05 9a 92 1e f0 	movw   $0x8,0xf01e929a
f01040e0:	08 00 
f01040e2:	c6 05 9c 92 1e f0 00 	movb   $0x0,0xf01e929c
f01040e9:	c6 05 9d 92 1e f0 8f 	movb   $0x8f,0xf01e929d
f01040f0:	c1 e8 10             	shr    $0x10,%eax
f01040f3:	66 a3 9e 92 1e f0    	mov    %ax,0xf01e929e
	SETGATE(idt[T_DBLFLT], 1, GD_KT, DBLFLT_Handler, 0);
f01040f9:	b8 f8 49 10 f0       	mov    $0xf01049f8,%eax
f01040fe:	66 a3 a0 92 1e f0    	mov    %ax,0xf01e92a0
f0104104:	66 c7 05 a2 92 1e f0 	movw   $0x8,0xf01e92a2
f010410b:	08 00 
f010410d:	c6 05 a4 92 1e f0 00 	movb   $0x0,0xf01e92a4
f0104114:	c6 05 a5 92 1e f0 8f 	movb   $0x8f,0xf01e92a5
f010411b:	c1 e8 10             	shr    $0x10,%eax
f010411e:	66 a3 a6 92 1e f0    	mov    %ax,0xf01e92a6
	SETGATE(idt[T_TSS], 1, GD_KT, TSS_Handler, 0);
f0104124:	b8 fc 49 10 f0       	mov    $0xf01049fc,%eax
f0104129:	66 a3 b0 92 1e f0    	mov    %ax,0xf01e92b0
f010412f:	66 c7 05 b2 92 1e f0 	movw   $0x8,0xf01e92b2
f0104136:	08 00 
f0104138:	c6 05 b4 92 1e f0 00 	movb   $0x0,0xf01e92b4
f010413f:	c6 05 b5 92 1e f0 8f 	movb   $0x8f,0xf01e92b5
f0104146:	c1 e8 10             	shr    $0x10,%eax
f0104149:	66 a3 b6 92 1e f0    	mov    %ax,0xf01e92b6
	SETGATE(idt[T_SEGNP], 1, GD_KT, SEGNP_Handler, 0);
f010414f:	b8 00 4a 10 f0       	mov    $0xf0104a00,%eax
f0104154:	66 a3 b8 92 1e f0    	mov    %ax,0xf01e92b8
f010415a:	66 c7 05 ba 92 1e f0 	movw   $0x8,0xf01e92ba
f0104161:	08 00 
f0104163:	c6 05 bc 92 1e f0 00 	movb   $0x0,0xf01e92bc
f010416a:	c6 05 bd 92 1e f0 8f 	movb   $0x8f,0xf01e92bd
f0104171:	c1 e8 10             	shr    $0x10,%eax
f0104174:	66 a3 be 92 1e f0    	mov    %ax,0xf01e92be
	SETGATE(idt[T_STACK], 1, GD_KT, STACK_Handler, 0);
f010417a:	b8 04 4a 10 f0       	mov    $0xf0104a04,%eax
f010417f:	66 a3 c0 92 1e f0    	mov    %ax,0xf01e92c0
f0104185:	66 c7 05 c2 92 1e f0 	movw   $0x8,0xf01e92c2
f010418c:	08 00 
f010418e:	c6 05 c4 92 1e f0 00 	movb   $0x0,0xf01e92c4
f0104195:	c6 05 c5 92 1e f0 8f 	movb   $0x8f,0xf01e92c5
f010419c:	c1 e8 10             	shr    $0x10,%eax
f010419f:	66 a3 c6 92 1e f0    	mov    %ax,0xf01e92c6
	SETGATE(idt[T_GPFLT], 1, GD_KT, GPFLT_Handler, 0);
f01041a5:	b8 08 4a 10 f0       	mov    $0xf0104a08,%eax
f01041aa:	66 a3 c8 92 1e f0    	mov    %ax,0xf01e92c8
f01041b0:	66 c7 05 ca 92 1e f0 	movw   $0x8,0xf01e92ca
f01041b7:	08 00 
f01041b9:	c6 05 cc 92 1e f0 00 	movb   $0x0,0xf01e92cc
f01041c0:	c6 05 cd 92 1e f0 8f 	movb   $0x8f,0xf01e92cd
f01041c7:	c1 e8 10             	shr    $0x10,%eax
f01041ca:	66 a3 ce 92 1e f0    	mov    %ax,0xf01e92ce
	SETGATE(idt[T_PGFLT], 1, GD_KT, PGFLT_Handler, 0);
f01041d0:	b8 0c 4a 10 f0       	mov    $0xf0104a0c,%eax
f01041d5:	66 a3 d0 92 1e f0    	mov    %ax,0xf01e92d0
f01041db:	66 c7 05 d2 92 1e f0 	movw   $0x8,0xf01e92d2
f01041e2:	08 00 
f01041e4:	c6 05 d4 92 1e f0 00 	movb   $0x0,0xf01e92d4
f01041eb:	c6 05 d5 92 1e f0 8f 	movb   $0x8f,0xf01e92d5
f01041f2:	89 c2                	mov    %eax,%edx
f01041f4:	c1 ea 10             	shr    $0x10,%edx
f01041f7:	66 89 15 d6 92 1e f0 	mov    %dx,0xf01e92d6
	SETGATE(idt[T_FPERR], 1, GD_KT, FPERR_Handler, 0);
f01041fe:	b9 10 4a 10 f0       	mov    $0xf0104a10,%ecx
f0104203:	66 89 0d e0 92 1e f0 	mov    %cx,0xf01e92e0
f010420a:	66 c7 05 e2 92 1e f0 	movw   $0x8,0xf01e92e2
f0104211:	08 00 
f0104213:	c6 05 e4 92 1e f0 00 	movb   $0x0,0xf01e92e4
f010421a:	c6 05 e5 92 1e f0 8f 	movb   $0x8f,0xf01e92e5
f0104221:	c1 e9 10             	shr    $0x10,%ecx
f0104224:	66 89 0d e6 92 1e f0 	mov    %cx,0xf01e92e6
	SETGATE(idt[T_ALIGN], 1, GD_KT, ALIGN_Handler, 0);
f010422b:	b9 14 4a 10 f0       	mov    $0xf0104a14,%ecx
f0104230:	66 89 0d e8 92 1e f0 	mov    %cx,0xf01e92e8
f0104237:	66 c7 05 ea 92 1e f0 	movw   $0x8,0xf01e92ea
f010423e:	08 00 
f0104240:	c6 05 ec 92 1e f0 00 	movb   $0x0,0xf01e92ec
f0104247:	c6 05 ed 92 1e f0 8f 	movb   $0x8f,0xf01e92ed
f010424e:	c1 e9 10             	shr    $0x10,%ecx
f0104251:	66 89 0d ee 92 1e f0 	mov    %cx,0xf01e92ee
	SETGATE(idt[T_MCHK], 1, GD_KT, MCHK_Handler, 0);
f0104258:	b9 18 4a 10 f0       	mov    $0xf0104a18,%ecx
f010425d:	66 89 0d f0 92 1e f0 	mov    %cx,0xf01e92f0
f0104264:	66 c7 05 f2 92 1e f0 	movw   $0x8,0xf01e92f2
f010426b:	08 00 
f010426d:	c6 05 f4 92 1e f0 00 	movb   $0x0,0xf01e92f4
f0104274:	c6 05 f5 92 1e f0 8f 	movb   $0x8f,0xf01e92f5
f010427b:	c1 e9 10             	shr    $0x10,%ecx
f010427e:	66 89 0d f6 92 1e f0 	mov    %cx,0xf01e92f6
	SETGATE(idt[T_SIMDERR], 1, GD_KT, PGFLT_Handler, 0);
f0104285:	66 a3 f8 92 1e f0    	mov    %ax,0xf01e92f8
f010428b:	66 c7 05 fa 92 1e f0 	movw   $0x8,0xf01e92fa
f0104292:	08 00 
f0104294:	c6 05 fc 92 1e f0 00 	movb   $0x0,0xf01e92fc
f010429b:	c6 05 fd 92 1e f0 8f 	movb   $0x8f,0xf01e92fd
f01042a2:	66 89 15 fe 92 1e f0 	mov    %dx,0xf01e92fe
	SETGATE(idt[T_SYSCALL], 0, GD_KT, SYSCALL_Handler, 3);
f01042a9:	b8 20 4a 10 f0       	mov    $0xf0104a20,%eax
f01042ae:	66 a3 e0 93 1e f0    	mov    %ax,0xf01e93e0
f01042b4:	66 c7 05 e2 93 1e f0 	movw   $0x8,0xf01e93e2
f01042bb:	08 00 
f01042bd:	c6 05 e4 93 1e f0 00 	movb   $0x0,0xf01e93e4
f01042c4:	c6 05 e5 93 1e f0 ee 	movb   $0xee,0xf01e93e5
f01042cb:	c1 e8 10             	shr    $0x10,%eax
f01042ce:	66 a3 e6 93 1e f0    	mov    %ax,0xf01e93e6
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 1, GD_KT, IRQ_TIMER_Handler, 0);
f01042d4:	b8 26 4a 10 f0       	mov    $0xf0104a26,%eax
f01042d9:	66 a3 60 93 1e f0    	mov    %ax,0xf01e9360
f01042df:	66 c7 05 62 93 1e f0 	movw   $0x8,0xf01e9362
f01042e6:	08 00 
f01042e8:	c6 05 64 93 1e f0 00 	movb   $0x0,0xf01e9364
f01042ef:	c6 05 65 93 1e f0 8f 	movb   $0x8f,0xf01e9365
f01042f6:	c1 e8 10             	shr    $0x10,%eax
f01042f9:	66 a3 66 93 1e f0    	mov    %ax,0xf01e9366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 1, GD_KT, IRQ_KBD_Handler, 0);
f01042ff:	b8 2c 4a 10 f0       	mov    $0xf0104a2c,%eax
f0104304:	66 a3 68 93 1e f0    	mov    %ax,0xf01e9368
f010430a:	66 c7 05 6a 93 1e f0 	movw   $0x8,0xf01e936a
f0104311:	08 00 
f0104313:	c6 05 6c 93 1e f0 00 	movb   $0x0,0xf01e936c
f010431a:	c6 05 6d 93 1e f0 8f 	movb   $0x8f,0xf01e936d
f0104321:	c1 e8 10             	shr    $0x10,%eax
f0104324:	66 a3 6e 93 1e f0    	mov    %ax,0xf01e936e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 1, GD_KT, IRQ_SERIAL_Handler, 0);
f010432a:	b8 32 4a 10 f0       	mov    $0xf0104a32,%eax
f010432f:	66 a3 80 93 1e f0    	mov    %ax,0xf01e9380
f0104335:	66 c7 05 82 93 1e f0 	movw   $0x8,0xf01e9382
f010433c:	08 00 
f010433e:	c6 05 84 93 1e f0 00 	movb   $0x0,0xf01e9384
f0104345:	c6 05 85 93 1e f0 8f 	movb   $0x8f,0xf01e9385
f010434c:	c1 e8 10             	shr    $0x10,%eax
f010434f:	66 a3 86 93 1e f0    	mov    %ax,0xf01e9386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 1, GD_KT, IRQ_SPURIOUS_Handler, 0);
f0104355:	b8 38 4a 10 f0       	mov    $0xf0104a38,%eax
f010435a:	66 a3 98 93 1e f0    	mov    %ax,0xf01e9398
f0104360:	66 c7 05 9a 93 1e f0 	movw   $0x8,0xf01e939a
f0104367:	08 00 
f0104369:	c6 05 9c 93 1e f0 00 	movb   $0x0,0xf01e939c
f0104370:	c6 05 9d 93 1e f0 8f 	movb   $0x8f,0xf01e939d
f0104377:	c1 e8 10             	shr    $0x10,%eax
f010437a:	66 a3 9e 93 1e f0    	mov    %ax,0xf01e939e
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 1, GD_KT, IRQ_IDE_Handler, 0);
f0104380:	b8 3e 4a 10 f0       	mov    $0xf0104a3e,%eax
f0104385:	66 a3 d0 93 1e f0    	mov    %ax,0xf01e93d0
f010438b:	66 c7 05 d2 93 1e f0 	movw   $0x8,0xf01e93d2
f0104392:	08 00 
f0104394:	c6 05 d4 93 1e f0 00 	movb   $0x0,0xf01e93d4
f010439b:	c6 05 d5 93 1e f0 8f 	movb   $0x8f,0xf01e93d5
f01043a2:	c1 e8 10             	shr    $0x10,%eax
f01043a5:	66 a3 d6 93 1e f0    	mov    %ax,0xf01e93d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 1, GD_KT, IRQ_ERROR_Handler, 0);
f01043ab:	b8 44 4a 10 f0       	mov    $0xf0104a44,%eax
f01043b0:	66 a3 f8 93 1e f0    	mov    %ax,0xf01e93f8
f01043b6:	66 c7 05 fa 93 1e f0 	movw   $0x8,0xf01e93fa
f01043bd:	08 00 
f01043bf:	c6 05 fc 93 1e f0 00 	movb   $0x0,0xf01e93fc
f01043c6:	c6 05 fd 93 1e f0 8f 	movb   $0x8f,0xf01e93fd
f01043cd:	c1 e8 10             	shr    $0x10,%eax
f01043d0:	66 a3 fe 93 1e f0    	mov    %ax,0xf01e93fe
	trap_init_percpu();
f01043d6:	e8 35 fb ff ff       	call   f0103f10 <trap_init_percpu>
}
f01043db:	c9                   	leave  
f01043dc:	c3                   	ret    

f01043dd <print_regs>:
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
	}
}

void print_regs(struct PushRegs *regs) // 打印寄存器的值，print_trapframe()的辅助函数
{
f01043dd:	55                   	push   %ebp
f01043de:	89 e5                	mov    %esp,%ebp
f01043e0:	53                   	push   %ebx
f01043e1:	83 ec 14             	sub    $0x14,%esp
f01043e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01043e7:	8b 03                	mov    (%ebx),%eax
f01043e9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043ed:	c7 04 24 38 7e 10 f0 	movl   $0xf0107e38,(%esp)
f01043f4:	e8 f0 fa ff ff       	call   f0103ee9 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01043f9:	8b 43 04             	mov    0x4(%ebx),%eax
f01043fc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104400:	c7 04 24 47 7e 10 f0 	movl   $0xf0107e47,(%esp)
f0104407:	e8 dd fa ff ff       	call   f0103ee9 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010440c:	8b 43 08             	mov    0x8(%ebx),%eax
f010440f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104413:	c7 04 24 56 7e 10 f0 	movl   $0xf0107e56,(%esp)
f010441a:	e8 ca fa ff ff       	call   f0103ee9 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010441f:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104422:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104426:	c7 04 24 65 7e 10 f0 	movl   $0xf0107e65,(%esp)
f010442d:	e8 b7 fa ff ff       	call   f0103ee9 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104432:	8b 43 10             	mov    0x10(%ebx),%eax
f0104435:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104439:	c7 04 24 74 7e 10 f0 	movl   $0xf0107e74,(%esp)
f0104440:	e8 a4 fa ff ff       	call   f0103ee9 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104445:	8b 43 14             	mov    0x14(%ebx),%eax
f0104448:	89 44 24 04          	mov    %eax,0x4(%esp)
f010444c:	c7 04 24 83 7e 10 f0 	movl   $0xf0107e83,(%esp)
f0104453:	e8 91 fa ff ff       	call   f0103ee9 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104458:	8b 43 18             	mov    0x18(%ebx),%eax
f010445b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010445f:	c7 04 24 92 7e 10 f0 	movl   $0xf0107e92,(%esp)
f0104466:	e8 7e fa ff ff       	call   f0103ee9 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010446b:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010446e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104472:	c7 04 24 a1 7e 10 f0 	movl   $0xf0107ea1,(%esp)
f0104479:	e8 6b fa ff ff       	call   f0103ee9 <cprintf>
}
f010447e:	83 c4 14             	add    $0x14,%esp
f0104481:	5b                   	pop    %ebx
f0104482:	5d                   	pop    %ebp
f0104483:	c3                   	ret    

f0104484 <print_trapframe>:
{
f0104484:	55                   	push   %ebp
f0104485:	89 e5                	mov    %esp,%ebp
f0104487:	56                   	push   %esi
f0104488:	53                   	push   %ebx
f0104489:	83 ec 10             	sub    $0x10,%esp
f010448c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f010448f:	e8 d5 1f 00 00       	call   f0106469 <cpunum>
f0104494:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104498:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010449c:	c7 04 24 05 7f 10 f0 	movl   $0xf0107f05,(%esp)
f01044a3:	e8 41 fa ff ff       	call   f0103ee9 <cprintf>
	print_regs(&tf->tf_regs);
f01044a8:	89 1c 24             	mov    %ebx,(%esp)
f01044ab:	e8 2d ff ff ff       	call   f01043dd <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01044b0:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01044b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044b8:	c7 04 24 23 7f 10 f0 	movl   $0xf0107f23,(%esp)
f01044bf:	e8 25 fa ff ff       	call   f0103ee9 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01044c4:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01044c8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044cc:	c7 04 24 36 7f 10 f0 	movl   $0xf0107f36,(%esp)
f01044d3:	e8 11 fa ff ff       	call   f0103ee9 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01044d8:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f01044db:	83 f8 13             	cmp    $0x13,%eax
f01044de:	77 09                	ja     f01044e9 <print_trapframe+0x65>
		return excnames[trapno];
f01044e0:	8b 14 85 c0 81 10 f0 	mov    -0xfef7e40(,%eax,4),%edx
f01044e7:	eb 1f                	jmp    f0104508 <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f01044e9:	83 f8 30             	cmp    $0x30,%eax
f01044ec:	74 15                	je     f0104503 <print_trapframe+0x7f>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01044ee:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f01044f1:	83 fa 0f             	cmp    $0xf,%edx
f01044f4:	ba bc 7e 10 f0       	mov    $0xf0107ebc,%edx
f01044f9:	b9 cf 7e 10 f0       	mov    $0xf0107ecf,%ecx
f01044fe:	0f 47 d1             	cmova  %ecx,%edx
f0104501:	eb 05                	jmp    f0104508 <print_trapframe+0x84>
		return "System call";
f0104503:	ba b0 7e 10 f0       	mov    $0xf0107eb0,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104508:	89 54 24 08          	mov    %edx,0x8(%esp)
f010450c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104510:	c7 04 24 49 7f 10 f0 	movl   $0xf0107f49,(%esp)
f0104517:	e8 cd f9 ff ff       	call   f0103ee9 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010451c:	3b 1d 60 9a 1e f0    	cmp    0xf01e9a60,%ebx
f0104522:	75 19                	jne    f010453d <print_trapframe+0xb9>
f0104524:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104528:	75 13                	jne    f010453d <print_trapframe+0xb9>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010452a:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010452d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104531:	c7 04 24 5b 7f 10 f0 	movl   $0xf0107f5b,(%esp)
f0104538:	e8 ac f9 ff ff       	call   f0103ee9 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f010453d:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104540:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104544:	c7 04 24 6a 7f 10 f0 	movl   $0xf0107f6a,(%esp)
f010454b:	e8 99 f9 ff ff       	call   f0103ee9 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0104550:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104554:	75 51                	jne    f01045a7 <print_trapframe+0x123>
				tf->tf_err & 1 ? "protection" : "not-present");
f0104556:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0104559:	89 c2                	mov    %eax,%edx
f010455b:	83 e2 01             	and    $0x1,%edx
f010455e:	ba de 7e 10 f0       	mov    $0xf0107ede,%edx
f0104563:	b9 e9 7e 10 f0       	mov    $0xf0107ee9,%ecx
f0104568:	0f 45 ca             	cmovne %edx,%ecx
f010456b:	89 c2                	mov    %eax,%edx
f010456d:	83 e2 02             	and    $0x2,%edx
f0104570:	ba f5 7e 10 f0       	mov    $0xf0107ef5,%edx
f0104575:	be fb 7e 10 f0       	mov    $0xf0107efb,%esi
f010457a:	0f 44 d6             	cmove  %esi,%edx
f010457d:	83 e0 04             	and    $0x4,%eax
f0104580:	b8 00 7f 10 f0       	mov    $0xf0107f00,%eax
f0104585:	be 1c 80 10 f0       	mov    $0xf010801c,%esi
f010458a:	0f 44 c6             	cmove  %esi,%eax
f010458d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104591:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104595:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104599:	c7 04 24 78 7f 10 f0 	movl   $0xf0107f78,(%esp)
f01045a0:	e8 44 f9 ff ff       	call   f0103ee9 <cprintf>
f01045a5:	eb 0c                	jmp    f01045b3 <print_trapframe+0x12f>
		cprintf("\n");
f01045a7:	c7 04 24 42 7d 10 f0 	movl   $0xf0107d42,(%esp)
f01045ae:	e8 36 f9 ff ff       	call   f0103ee9 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01045b3:	8b 43 30             	mov    0x30(%ebx),%eax
f01045b6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045ba:	c7 04 24 87 7f 10 f0 	movl   $0xf0107f87,(%esp)
f01045c1:	e8 23 f9 ff ff       	call   f0103ee9 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01045c6:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01045ca:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045ce:	c7 04 24 96 7f 10 f0 	movl   $0xf0107f96,(%esp)
f01045d5:	e8 0f f9 ff ff       	call   f0103ee9 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01045da:	8b 43 38             	mov    0x38(%ebx),%eax
f01045dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045e1:	c7 04 24 a9 7f 10 f0 	movl   $0xf0107fa9,(%esp)
f01045e8:	e8 fc f8 ff ff       	call   f0103ee9 <cprintf>
	if ((tf->tf_cs & 3) != 0)
f01045ed:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01045f1:	74 27                	je     f010461a <print_trapframe+0x196>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01045f3:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01045f6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045fa:	c7 04 24 b8 7f 10 f0 	movl   $0xf0107fb8,(%esp)
f0104601:	e8 e3 f8 ff ff       	call   f0103ee9 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104606:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010460a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010460e:	c7 04 24 c7 7f 10 f0 	movl   $0xf0107fc7,(%esp)
f0104615:	e8 cf f8 ff ff       	call   f0103ee9 <cprintf>
}
f010461a:	83 c4 10             	add    $0x10,%esp
f010461d:	5b                   	pop    %ebx
f010461e:	5e                   	pop    %esi
f010461f:	5d                   	pop    %ebp
f0104620:	c3                   	ret    

f0104621 <page_fault_handler>:
	else
		sched_yield();
}

void page_fault_handler(struct Trapframe *tf) // 特殊处理页错误中断
{
f0104621:	55                   	push   %ebp
f0104622:	89 e5                	mov    %esp,%ebp
f0104624:	57                   	push   %edi
f0104625:	56                   	push   %esi
f0104626:	53                   	push   %ebx
f0104627:	83 ec 2c             	sub    $0x2c,%esp
f010462a:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010462d:	0f 20 d6             	mov    %cr2,%esi
	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0) // 处于内核模式
f0104630:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104634:	75 1c                	jne    f0104652 <page_fault_handler+0x31>
	{
		panic("page_fault_handler(): kernel-mode page faults");
f0104636:	c7 44 24 08 68 81 10 	movl   $0xf0108168,0x8(%esp)
f010463d:	f0 
f010463e:	c7 44 24 04 6e 01 00 	movl   $0x16e,0x4(%esp)
f0104645:	00 
f0104646:	c7 04 24 da 7f 10 f0 	movl   $0xf0107fda,(%esp)
f010464d:	e8 ee b9 ff ff       	call   f0100040 <_panic>
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	// 现在处于用户模式
	if (curenv->env_pgfault_upcall != NULL) // 用户模式下的页面错误处理程序如果有设置
f0104652:	e8 12 1e 00 00       	call   f0106469 <cpunum>
f0104657:	6b c0 74             	imul   $0x74,%eax,%eax
f010465a:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f0104660:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104664:	0f 84 d8 00 00 00    	je     f0104742 <page_fault_handler+0x121>
	{
		uintptr_t addr;

		if (tf->tf_esp >= UXSTACKTOP - PGSIZE && tf->tf_esp < UXSTACKTOP) // 如果发生异常时用户环境已经在用户异常堆栈上运行
f010466a:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010466d:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			addr = tf->tf_esp - sizeof(struct UTrapframe) - sizeof(int);  // 在tf->tf_esp处设置页面错误堆栈帧UTrapframe
f0104673:	83 e8 38             	sub    $0x38,%eax
f0104676:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f010467c:	ba c8 ff bf ee       	mov    $0xeebfffc8,%edx
f0104681:	0f 46 d0             	cmovbe %eax,%edx
f0104684:	89 d7                	mov    %edx,%edi
f0104686:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		else
			addr = UXSTACKTOP - sizeof(struct UTrapframe) - sizeof(int); // 栈帧的区间[UXSTACKTOP - sizeof(struct UTrapframe) - sizeof(int),UXSTACKTOP]
		user_mem_assert(curenv, (void *)addr, sizeof(struct UTrapframe) + sizeof(int), PTE_P | PTE_U | PTE_W);
f0104689:	e8 db 1d 00 00       	call   f0106469 <cpunum>
f010468e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
f0104695:	00 
f0104696:	c7 44 24 08 38 00 00 	movl   $0x38,0x8(%esp)
f010469d:	00 
f010469e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01046a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01046a5:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f01046ab:	89 04 24             	mov    %eax,(%esp)
f01046ae:	e8 b9 ee ff ff       	call   f010356c <user_mem_assert>

		// 在UXSTACKTOP设置一个用户模式下的页面错误堆栈帧UTrapframe，为了可以从页面错误处理程序中返回到引发错误的程序
		struct UTrapframe *utf = (struct UTrapframe *)addr;
f01046b3:	89 fa                	mov    %edi,%edx
		utf->utf_fault_va = fault_va;
f01046b5:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f01046b7:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01046ba:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f01046bd:	8d 7f 08             	lea    0x8(%edi),%edi
f01046c0:	89 de                	mov    %ebx,%esi
f01046c2:	b8 20 00 00 00       	mov    $0x20,%eax
f01046c7:	f7 c7 01 00 00 00    	test   $0x1,%edi
f01046cd:	74 03                	je     f01046d2 <page_fault_handler+0xb1>
f01046cf:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f01046d0:	b0 1f                	mov    $0x1f,%al
f01046d2:	f7 c7 02 00 00 00    	test   $0x2,%edi
f01046d8:	74 05                	je     f01046df <page_fault_handler+0xbe>
f01046da:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f01046dc:	83 e8 02             	sub    $0x2,%eax
f01046df:	89 c1                	mov    %eax,%ecx
f01046e1:	c1 e9 02             	shr    $0x2,%ecx
f01046e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01046e6:	a8 02                	test   $0x2,%al
f01046e8:	74 0b                	je     f01046f5 <page_fault_handler+0xd4>
f01046ea:	0f b7 0e             	movzwl (%esi),%ecx
f01046ed:	66 89 0f             	mov    %cx,(%edi)
f01046f0:	b9 02 00 00 00       	mov    $0x2,%ecx
f01046f5:	a8 01                	test   $0x1,%al
f01046f7:	74 07                	je     f0104700 <page_fault_handler+0xdf>
f01046f9:	0f b6 04 0e          	movzbl (%esi,%ecx,1),%eax
f01046fd:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		utf->utf_eip = tf->tf_eip;
f0104700:	8b 43 30             	mov    0x30(%ebx),%eax
f0104703:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f0104706:	8b 43 38             	mov    0x38(%ebx),%eax
f0104709:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f010470c:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010470f:	89 42 30             	mov    %eax,0x30(%edx)

		tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall; // 设置页面错误处理程序入口
f0104712:	e8 52 1d 00 00       	call   f0106469 <cpunum>
f0104717:	6b c0 74             	imul   $0x74,%eax,%eax
f010471a:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f0104720:	8b 40 64             	mov    0x64(%eax),%eax
f0104723:	89 43 30             	mov    %eax,0x30(%ebx)
		tf->tf_esp = (uintptr_t)utf;						// 修改esp移动到设置好的用户异常堆栈
f0104726:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104729:	89 43 3c             	mov    %eax,0x3c(%ebx)
		env_run(curenv);									// 重新运行本进程，env_run会pop出tf，来运行页面错误处理程序
f010472c:	e8 38 1d 00 00       	call   f0106469 <cpunum>
f0104731:	6b c0 74             	imul   $0x74,%eax,%eax
f0104734:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f010473a:	89 04 24             	mov    %eax,(%esp)
f010473d:	e8 83 f5 ff ff       	call   f0103cc5 <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104742:	8b 7b 30             	mov    0x30(%ebx),%edi
			curenv->env_id, fault_va, tf->tf_eip);
f0104745:	e8 1f 1d 00 00       	call   f0106469 <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010474a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010474e:	89 74 24 08          	mov    %esi,0x8(%esp)
			curenv->env_id, fault_va, tf->tf_eip);
f0104752:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104755:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f010475b:	8b 40 48             	mov    0x48(%eax),%eax
f010475e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104762:	c7 04 24 98 81 10 f0 	movl   $0xf0108198,(%esp)
f0104769:	e8 7b f7 ff ff       	call   f0103ee9 <cprintf>
	print_trapframe(tf);
f010476e:	89 1c 24             	mov    %ebx,(%esp)
f0104771:	e8 0e fd ff ff       	call   f0104484 <print_trapframe>
	env_destroy(curenv);
f0104776:	e8 ee 1c 00 00       	call   f0106469 <cpunum>
f010477b:	6b c0 74             	imul   $0x74,%eax,%eax
f010477e:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f0104784:	89 04 24             	mov    %eax,(%esp)
f0104787:	e8 98 f4 ff ff       	call   f0103c24 <env_destroy>
}
f010478c:	83 c4 2c             	add    $0x2c,%esp
f010478f:	5b                   	pop    %ebx
f0104790:	5e                   	pop    %esi
f0104791:	5f                   	pop    %edi
f0104792:	5d                   	pop    %ebp
f0104793:	c3                   	ret    

f0104794 <trap>:
{
f0104794:	55                   	push   %ebp
f0104795:	89 e5                	mov    %esp,%ebp
f0104797:	57                   	push   %edi
f0104798:	56                   	push   %esi
f0104799:	83 ec 20             	sub    $0x20,%esp
f010479c:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::
f010479f:	fc                   	cld    
	if (panicstr)
f01047a0:	83 3d 80 9e 1e f0 00 	cmpl   $0x0,0xf01e9e80
f01047a7:	74 01                	je     f01047aa <trap+0x16>
		asm volatile("hlt");
f01047a9:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01047aa:	e8 ba 1c 00 00       	call   f0106469 <cpunum>
f01047af:	6b d0 74             	imul   $0x74,%eax,%edx
f01047b2:	81 c2 20 a0 1e f0    	add    $0xf01ea020,%edx
	asm volatile("lock; xchgl %0, %1"
f01047b8:	b8 01 00 00 00       	mov    $0x1,%eax
f01047bd:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01047c1:	83 f8 02             	cmp    $0x2,%eax
f01047c4:	75 0c                	jne    f01047d2 <trap+0x3e>
	spin_lock(&kernel_lock);
f01047c6:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f01047cd:	e8 15 1f 00 00       	call   f01066e7 <spin_lock>
	if ((tf->tf_cs & 3) == 3)
f01047d2:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01047d6:	83 e0 03             	and    $0x3,%eax
f01047d9:	66 83 f8 03          	cmp    $0x3,%ax
f01047dd:	0f 85 a7 00 00 00    	jne    f010488a <trap+0xf6>
f01047e3:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f01047ea:	e8 f8 1e 00 00       	call   f01066e7 <spin_lock>
		assert(curenv);
f01047ef:	e8 75 1c 00 00       	call   f0106469 <cpunum>
f01047f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01047f7:	83 b8 28 a0 1e f0 00 	cmpl   $0x0,-0xfe15fd8(%eax)
f01047fe:	75 24                	jne    f0104824 <trap+0x90>
f0104800:	c7 44 24 0c e6 7f 10 	movl   $0xf0107fe6,0xc(%esp)
f0104807:	f0 
f0104808:	c7 44 24 08 df 7a 10 	movl   $0xf0107adf,0x8(%esp)
f010480f:	f0 
f0104810:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
f0104817:	00 
f0104818:	c7 04 24 da 7f 10 f0 	movl   $0xf0107fda,(%esp)
f010481f:	e8 1c b8 ff ff       	call   f0100040 <_panic>
		if (curenv->env_status == ENV_DYING)
f0104824:	e8 40 1c 00 00       	call   f0106469 <cpunum>
f0104829:	6b c0 74             	imul   $0x74,%eax,%eax
f010482c:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f0104832:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104836:	75 2d                	jne    f0104865 <trap+0xd1>
			env_free(curenv);
f0104838:	e8 2c 1c 00 00       	call   f0106469 <cpunum>
f010483d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104840:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f0104846:	89 04 24             	mov    %eax,(%esp)
f0104849:	e8 0b f2 ff ff       	call   f0103a59 <env_free>
			curenv = NULL;
f010484e:	e8 16 1c 00 00       	call   f0106469 <cpunum>
f0104853:	6b c0 74             	imul   $0x74,%eax,%eax
f0104856:	c7 80 28 a0 1e f0 00 	movl   $0x0,-0xfe15fd8(%eax)
f010485d:	00 00 00 
			sched_yield();
f0104860:	e8 cc 02 00 00       	call   f0104b31 <sched_yield>
		curenv->env_tf = *tf;
f0104865:	e8 ff 1b 00 00       	call   f0106469 <cpunum>
f010486a:	6b c0 74             	imul   $0x74,%eax,%eax
f010486d:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f0104873:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104878:	89 c7                	mov    %eax,%edi
f010487a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f010487c:	e8 e8 1b 00 00       	call   f0106469 <cpunum>
f0104881:	6b c0 74             	imul   $0x74,%eax,%eax
f0104884:	8b b0 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%esi
	last_tf = tf;
f010488a:	89 35 60 9a 1e f0    	mov    %esi,0xf01e9a60
	switch (tf->tf_trapno)
f0104890:	8b 46 28             	mov    0x28(%esi),%eax
f0104893:	83 f8 0e             	cmp    $0xe,%eax
f0104896:	74 0c                	je     f01048a4 <trap+0x110>
f0104898:	83 f8 30             	cmp    $0x30,%eax
f010489b:	74 28                	je     f01048c5 <trap+0x131>
f010489d:	83 f8 03             	cmp    $0x3,%eax
f01048a0:	75 58                	jne    f01048fa <trap+0x166>
f01048a2:	eb 11                	jmp    f01048b5 <trap+0x121>
		page_fault_handler(tf);
f01048a4:	89 34 24             	mov    %esi,(%esp)
f01048a7:	e8 75 fd ff ff       	call   f0104621 <page_fault_handler>
f01048ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01048b0:	e9 d3 00 00 00       	jmp    f0104988 <trap+0x1f4>
		monitor(tf);
f01048b5:	89 34 24             	mov    %esi,(%esp)
f01048b8:	e8 24 c1 ff ff       	call   f01009e1 <monitor>
f01048bd:	8d 76 00             	lea    0x0(%esi),%esi
f01048c0:	e9 c3 00 00 00       	jmp    f0104988 <trap+0x1f4>
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx,
f01048c5:	8b 46 04             	mov    0x4(%esi),%eax
f01048c8:	89 44 24 14          	mov    %eax,0x14(%esp)
f01048cc:	8b 06                	mov    (%esi),%eax
f01048ce:	89 44 24 10          	mov    %eax,0x10(%esp)
f01048d2:	8b 46 10             	mov    0x10(%esi),%eax
f01048d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01048d9:	8b 46 18             	mov    0x18(%esi),%eax
f01048dc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01048e0:	8b 46 14             	mov    0x14(%esi),%eax
f01048e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048e7:	8b 46 1c             	mov    0x1c(%esi),%eax
f01048ea:	89 04 24             	mov    %eax,(%esp)
f01048ed:	e8 ee 02 00 00       	call   f0104be0 <syscall>
f01048f2:	89 46 1c             	mov    %eax,0x1c(%esi)
f01048f5:	e9 8e 00 00 00       	jmp    f0104988 <trap+0x1f4>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS)
f01048fa:	83 f8 27             	cmp    $0x27,%eax
f01048fd:	75 16                	jne    f0104915 <trap+0x181>
		cprintf("Spurious interrupt on irq 7\n");
f01048ff:	c7 04 24 ed 7f 10 f0 	movl   $0xf0107fed,(%esp)
f0104906:	e8 de f5 ff ff       	call   f0103ee9 <cprintf>
		print_trapframe(tf);
f010490b:	89 34 24             	mov    %esi,(%esp)
f010490e:	e8 71 fb ff ff       	call   f0104484 <print_trapframe>
f0104913:	eb 73                	jmp    f0104988 <trap+0x1f4>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER)
f0104915:	83 f8 20             	cmp    $0x20,%eax
f0104918:	75 10                	jne    f010492a <trap+0x196>
		lapic_eoi();
f010491a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104920:	e8 91 1c 00 00       	call   f01065b6 <lapic_eoi>
		sched_yield();
f0104925:	e8 07 02 00 00       	call   f0104b31 <sched_yield>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_KBD)
f010492a:	83 f8 21             	cmp    $0x21,%eax
f010492d:	75 08                	jne    f0104937 <trap+0x1a3>
		kbd_intr();
f010492f:	90                   	nop
f0104930:	e8 0e bd ff ff       	call   f0100643 <kbd_intr>
f0104935:	eb 51                	jmp    f0104988 <trap+0x1f4>
	else if (tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL)
f0104937:	83 f8 24             	cmp    $0x24,%eax
f010493a:	75 0b                	jne    f0104947 <trap+0x1b3>
		serial_intr();
f010493c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104940:	e8 e2 bc ff ff       	call   f0100627 <serial_intr>
f0104945:	eb 41                	jmp    f0104988 <trap+0x1f4>
	print_trapframe(tf);
f0104947:	89 34 24             	mov    %esi,(%esp)
f010494a:	e8 35 fb ff ff       	call   f0104484 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010494f:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104954:	75 1c                	jne    f0104972 <trap+0x1de>
		panic("unhandled trap in kernel");
f0104956:	c7 44 24 08 0a 80 10 	movl   $0xf010800a,0x8(%esp)
f010495d:	f0 
f010495e:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
f0104965:	00 
f0104966:	c7 04 24 da 7f 10 f0 	movl   $0xf0107fda,(%esp)
f010496d:	e8 ce b6 ff ff       	call   f0100040 <_panic>
		env_destroy(curenv);
f0104972:	e8 f2 1a 00 00       	call   f0106469 <cpunum>
f0104977:	6b c0 74             	imul   $0x74,%eax,%eax
f010497a:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f0104980:	89 04 24             	mov    %eax,(%esp)
f0104983:	e8 9c f2 ff ff       	call   f0103c24 <env_destroy>
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104988:	e8 dc 1a 00 00       	call   f0106469 <cpunum>
f010498d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104990:	83 b8 28 a0 1e f0 00 	cmpl   $0x0,-0xfe15fd8(%eax)
f0104997:	74 2a                	je     f01049c3 <trap+0x22f>
f0104999:	e8 cb 1a 00 00       	call   f0106469 <cpunum>
f010499e:	6b c0 74             	imul   $0x74,%eax,%eax
f01049a1:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f01049a7:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01049ab:	75 16                	jne    f01049c3 <trap+0x22f>
		env_run(curenv); // 返回用户态
f01049ad:	e8 b7 1a 00 00       	call   f0106469 <cpunum>
f01049b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01049b5:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f01049bb:	89 04 24             	mov    %eax,(%esp)
f01049be:	e8 02 f3 ff ff       	call   f0103cc5 <env_run>
		sched_yield();
f01049c3:	e8 69 01 00 00       	call   f0104b31 <sched_yield>

f01049c8 <DIVIDE_Handler>:
 * TRAPHANDLER(name, num):是一个宏，等效于一个从name标记的地址开始的几行指令
 * name是你为这个num的中断设置的中断处理程序的函数名，num由inc\trap.h定义
 * 经过下面的设置，这个汇编文件里存在很多个以handler为名的函数，可以在C中使用void XXX_Hander()去声明函数，
 * 这时，这个hander函数的地址将被链接到下面对应hander的行。
 */
TRAPHANDLER_NOEC(DIVIDE_Handler, T_DIVIDE)
f01049c8:	6a 00                	push   $0x0
f01049ca:	6a 00                	push   $0x0
f01049cc:	eb 7c                	jmp    f0104a4a <_alltraps>

f01049ce <DEBUG_Handler>:
TRAPHANDLER_NOEC(DEBUG_Handler, T_DEBUG)
f01049ce:	6a 00                	push   $0x0
f01049d0:	6a 01                	push   $0x1
f01049d2:	eb 76                	jmp    f0104a4a <_alltraps>

f01049d4 <NMI_Handler>:
TRAPHANDLER_NOEC(NMI_Handler, T_NMI)
f01049d4:	6a 00                	push   $0x0
f01049d6:	6a 02                	push   $0x2
f01049d8:	eb 70                	jmp    f0104a4a <_alltraps>

f01049da <BRKPT_Handler>:
TRAPHANDLER_NOEC(BRKPT_Handler, T_BRKPT)
f01049da:	6a 00                	push   $0x0
f01049dc:	6a 03                	push   $0x3
f01049de:	eb 6a                	jmp    f0104a4a <_alltraps>

f01049e0 <OFLOW_Handler>:
TRAPHANDLER_NOEC(OFLOW_Handler, T_OFLOW)
f01049e0:	6a 00                	push   $0x0
f01049e2:	6a 04                	push   $0x4
f01049e4:	eb 64                	jmp    f0104a4a <_alltraps>

f01049e6 <BOUND_Handler>:
TRAPHANDLER_NOEC(BOUND_Handler, T_BOUND)
f01049e6:	6a 00                	push   $0x0
f01049e8:	6a 05                	push   $0x5
f01049ea:	eb 5e                	jmp    f0104a4a <_alltraps>

f01049ec <ILLOP_Handler>:
TRAPHANDLER_NOEC(ILLOP_Handler, T_ILLOP)
f01049ec:	6a 00                	push   $0x0
f01049ee:	6a 06                	push   $0x6
f01049f0:	eb 58                	jmp    f0104a4a <_alltraps>

f01049f2 <DEVICE_Handler>:
TRAPHANDLER_NOEC(DEVICE_Handler, T_DEVICE)
f01049f2:	6a 00                	push   $0x0
f01049f4:	6a 07                	push   $0x7
f01049f6:	eb 52                	jmp    f0104a4a <_alltraps>

f01049f8 <DBLFLT_Handler>:
TRAPHANDLER(DBLFLT_Handler, T_DBLFLT)
f01049f8:	6a 08                	push   $0x8
f01049fa:	eb 4e                	jmp    f0104a4a <_alltraps>

f01049fc <TSS_Handler>:

TRAPHANDLER(TSS_Handler, T_TSS)
f01049fc:	6a 0a                	push   $0xa
f01049fe:	eb 4a                	jmp    f0104a4a <_alltraps>

f0104a00 <SEGNP_Handler>:
TRAPHANDLER(SEGNP_Handler, T_SEGNP)
f0104a00:	6a 0b                	push   $0xb
f0104a02:	eb 46                	jmp    f0104a4a <_alltraps>

f0104a04 <STACK_Handler>:
TRAPHANDLER(STACK_Handler, T_STACK)
f0104a04:	6a 0c                	push   $0xc
f0104a06:	eb 42                	jmp    f0104a4a <_alltraps>

f0104a08 <GPFLT_Handler>:
TRAPHANDLER(GPFLT_Handler, T_GPFLT)
f0104a08:	6a 0d                	push   $0xd
f0104a0a:	eb 3e                	jmp    f0104a4a <_alltraps>

f0104a0c <PGFLT_Handler>:
TRAPHANDLER(PGFLT_Handler, T_PGFLT)
f0104a0c:	6a 0e                	push   $0xe
f0104a0e:	eb 3a                	jmp    f0104a4a <_alltraps>

f0104a10 <FPERR_Handler>:

TRAPHANDLER(FPERR_Handler, T_FPERR)
f0104a10:	6a 10                	push   $0x10
f0104a12:	eb 36                	jmp    f0104a4a <_alltraps>

f0104a14 <ALIGN_Handler>:
TRAPHANDLER(ALIGN_Handler, T_ALIGN)
f0104a14:	6a 11                	push   $0x11
f0104a16:	eb 32                	jmp    f0104a4a <_alltraps>

f0104a18 <MCHK_Handler>:
TRAPHANDLER(MCHK_Handler, T_MCHK)
f0104a18:	6a 12                	push   $0x12
f0104a1a:	eb 2e                	jmp    f0104a4a <_alltraps>

f0104a1c <SIMDERR_Handler>:
TRAPHANDLER(SIMDERR_Handler, T_SIMDERR)
f0104a1c:	6a 13                	push   $0x13
f0104a1e:	eb 2a                	jmp    f0104a4a <_alltraps>

f0104a20 <SYSCALL_Handler>:

TRAPHANDLER_NOEC(SYSCALL_Handler, T_SYSCALL)
f0104a20:	6a 00                	push   $0x0
f0104a22:	6a 30                	push   $0x30
f0104a24:	eb 24                	jmp    f0104a4a <_alltraps>

f0104a26 <IRQ_TIMER_Handler>:

# IRQs
TRAPHANDLER_NOEC(IRQ_TIMER_Handler, IRQ_OFFSET+IRQ_TIMER)
f0104a26:	6a 00                	push   $0x0
f0104a28:	6a 20                	push   $0x20
f0104a2a:	eb 1e                	jmp    f0104a4a <_alltraps>

f0104a2c <IRQ_KBD_Handler>:
TRAPHANDLER_NOEC(IRQ_KBD_Handler, IRQ_OFFSET+IRQ_KBD)
f0104a2c:	6a 00                	push   $0x0
f0104a2e:	6a 21                	push   $0x21
f0104a30:	eb 18                	jmp    f0104a4a <_alltraps>

f0104a32 <IRQ_SERIAL_Handler>:
TRAPHANDLER_NOEC(IRQ_SERIAL_Handler, IRQ_OFFSET+IRQ_SERIAL)
f0104a32:	6a 00                	push   $0x0
f0104a34:	6a 24                	push   $0x24
f0104a36:	eb 12                	jmp    f0104a4a <_alltraps>

f0104a38 <IRQ_SPURIOUS_Handler>:
TRAPHANDLER_NOEC(IRQ_SPURIOUS_Handler, IRQ_OFFSET+IRQ_SPURIOUS)
f0104a38:	6a 00                	push   $0x0
f0104a3a:	6a 27                	push   $0x27
f0104a3c:	eb 0c                	jmp    f0104a4a <_alltraps>

f0104a3e <IRQ_IDE_Handler>:
TRAPHANDLER_NOEC(IRQ_IDE_Handler, IRQ_OFFSET+IRQ_IDE)
f0104a3e:	6a 00                	push   $0x0
f0104a40:	6a 2e                	push   $0x2e
f0104a42:	eb 06                	jmp    f0104a4a <_alltraps>

f0104a44 <IRQ_ERROR_Handler>:
TRAPHANDLER_NOEC(IRQ_ERROR_Handler, IRQ_OFFSET+IRQ_ERROR)
f0104a44:	6a 00                	push   $0x0
f0104a46:	6a 33                	push   $0x33
f0104a48:	eb 00                	jmp    f0104a4a <_alltraps>

f0104a4a <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
.globl		_start
_alltraps:
	pushl	%ds		/* 后面要将GD_KD加载到%ds和%es，先保存旧的 */
f0104a4a:	1e                   	push   %ds
	pushl	%es
f0104a4b:	06                   	push   %es
	pushal			/* 直接推送整个TrapFrame */
f0104a4c:	60                   	pusha  
	movw 	$GD_KD, %ax /* 不能直接设置，因此先复制到%ax */
f0104a4d:	66 b8 10 00          	mov    $0x10,%ax
  	movw 	%ax, %ds
f0104a51:	8e d8                	mov    %eax,%ds
  	movw 	%ax, %es
f0104a53:	8e c0                	mov    %eax,%es
	pushl 	%esp	/* %esp指向Trapframe顶部，作为参数传递给trap */
f0104a55:	54                   	push   %esp
	call	trap	/* 调用c程序trap，执行中断处理程序 */
f0104a56:	e8 39 fd ff ff       	call   f0104794 <trap>

f0104a5b <sched_halt>:

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void sched_halt(void)
{
f0104a5b:	55                   	push   %ebp
f0104a5c:	89 e5                	mov    %esp,%ebp
f0104a5e:	83 ec 18             	sub    $0x18,%esp
f0104a61:	8b 15 48 92 1e f0    	mov    0xf01e9248,%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++)
f0104a67:	b8 00 00 00 00       	mov    $0x0,%eax
	{
		if ((envs[i].env_status == ENV_RUNNABLE ||
			 envs[i].env_status == ENV_RUNNING ||
f0104a6c:	8b 4a 54             	mov    0x54(%edx),%ecx
f0104a6f:	83 e9 01             	sub    $0x1,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104a72:	83 f9 02             	cmp    $0x2,%ecx
f0104a75:	76 0f                	jbe    f0104a86 <sched_halt+0x2b>
	for (i = 0; i < NENV; i++)
f0104a77:	83 c0 01             	add    $0x1,%eax
f0104a7a:	83 c2 7c             	add    $0x7c,%edx
f0104a7d:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104a82:	75 e8                	jne    f0104a6c <sched_halt+0x11>
f0104a84:	eb 07                	jmp    f0104a8d <sched_halt+0x32>
			 envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV)
f0104a86:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104a8b:	75 1a                	jne    f0104aa7 <sched_halt+0x4c>
	{
		cprintf("No runnable environments in the system!\n");
f0104a8d:	c7 04 24 10 82 10 f0 	movl   $0xf0108210,(%esp)
f0104a94:	e8 50 f4 ff ff       	call   f0103ee9 <cprintf>
		while (1)
			monitor(NULL);
f0104a99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104aa0:	e8 3c bf ff ff       	call   f01009e1 <monitor>
f0104aa5:	eb f2                	jmp    f0104a99 <sched_halt+0x3e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104aa7:	e8 bd 19 00 00       	call   f0106469 <cpunum>
f0104aac:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aaf:	c7 80 28 a0 1e f0 00 	movl   $0x0,-0xfe15fd8(%eax)
f0104ab6:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104ab9:	a1 8c 9e 1e f0       	mov    0xf01e9e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0104abe:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104ac3:	77 20                	ja     f0104ae5 <sched_halt+0x8a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104ac5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104ac9:	c7 44 24 08 88 6b 10 	movl   $0xf0106b88,0x8(%esp)
f0104ad0:	f0 
f0104ad1:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
f0104ad8:	00 
f0104ad9:	c7 04 24 39 82 10 f0 	movl   $0xf0108239,(%esp)
f0104ae0:	e8 5b b5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104ae5:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104aea:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104aed:	e8 77 19 00 00       	call   f0106469 <cpunum>
f0104af2:	6b d0 74             	imul   $0x74,%eax,%edx
f0104af5:	81 c2 20 a0 1e f0    	add    $0xf01ea020,%edx
	asm volatile("lock; xchgl %0, %1"
f0104afb:	b8 02 00 00 00       	mov    $0x2,%eax
f0104b00:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
	spin_unlock(&kernel_lock);
f0104b04:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f0104b0b:	e8 83 1c 00 00       	call   f0106793 <spin_unlock>
	asm volatile("pause");
f0104b10:	f3 90                	pause  
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
		:
		: "a"(thiscpu->cpu_ts.ts_esp0));
f0104b12:	e8 52 19 00 00       	call   f0106469 <cpunum>
f0104b17:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile(
f0104b1a:	8b 80 30 a0 1e f0    	mov    -0xfe15fd0(%eax),%eax
f0104b20:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104b25:	89 c4                	mov    %eax,%esp
f0104b27:	6a 00                	push   $0x0
f0104b29:	6a 00                	push   $0x0
f0104b2b:	fb                   	sti    
f0104b2c:	f4                   	hlt    
f0104b2d:	eb fd                	jmp    f0104b2c <sched_halt+0xd1>
}
f0104b2f:	c9                   	leave  
f0104b30:	c3                   	ret    

f0104b31 <sched_yield>:
{
f0104b31:	55                   	push   %ebp
f0104b32:	89 e5                	mov    %esp,%ebp
f0104b34:	56                   	push   %esi
f0104b35:	53                   	push   %ebx
f0104b36:	83 ec 10             	sub    $0x10,%esp
	idle = &envs[0]; // 第一个环境
f0104b39:	8b 1d 48 92 1e f0    	mov    0xf01e9248,%ebx
	if (curenv)
f0104b3f:	e8 25 19 00 00       	call   f0106469 <cpunum>
f0104b44:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b47:	83 b8 28 a0 1e f0 00 	cmpl   $0x0,-0xfe15fd8(%eax)
f0104b4e:	74 11                	je     f0104b61 <sched_yield+0x30>
		idle = curenv + 1; // 如果现在有在运行的环境，从现在这个的下一个开始遍历
f0104b50:	e8 14 19 00 00       	call   f0106469 <cpunum>
f0104b55:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b58:	8b 98 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%ebx
f0104b5e:	83 c3 7c             	add    $0x7c,%ebx
		if (idle == &envs[NENV - 1]) // 最后一个环境
f0104b61:	8b 0d 48 92 1e f0    	mov    0xf01e9248,%ecx
f0104b67:	8d b1 84 ef 01 00    	lea    0x1ef84(%ecx),%esi
f0104b6d:	b8 ff 03 00 00       	mov    $0x3ff,%eax
		if (idle->env_status == ENV_RUNNABLE) // 检查是否可以运行
f0104b72:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f0104b76:	75 08                	jne    f0104b80 <sched_yield+0x4f>
			env_run(idle);
f0104b78:	89 1c 24             	mov    %ebx,(%esp)
f0104b7b:	e8 45 f1 ff ff       	call   f0103cc5 <env_run>
			idle++;
f0104b80:	8d 53 7c             	lea    0x7c(%ebx),%edx
f0104b83:	39 de                	cmp    %ebx,%esi
f0104b85:	0f 44 d1             	cmove  %ecx,%edx
f0104b88:	89 d3                	mov    %edx,%ebx
	for (int i = 0; i < NENV - 1; i++)
f0104b8a:	83 e8 01             	sub    $0x1,%eax
f0104b8d:	75 e3                	jne    f0104b72 <sched_yield+0x41>
	if (idle == curenv && curenv->env_status == ENV_RUNNING) // 转一圈又回到自己
f0104b8f:	e8 d5 18 00 00       	call   f0106469 <cpunum>
f0104b94:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b97:	3b 98 28 a0 1e f0    	cmp    -0xfe15fd8(%eax),%ebx
f0104b9d:	75 2a                	jne    f0104bc9 <sched_yield+0x98>
f0104b9f:	e8 c5 18 00 00       	call   f0106469 <cpunum>
f0104ba4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ba7:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f0104bad:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104bb1:	75 16                	jne    f0104bc9 <sched_yield+0x98>
		env_run(curenv);
f0104bb3:	e8 b1 18 00 00       	call   f0106469 <cpunum>
f0104bb8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bbb:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f0104bc1:	89 04 24             	mov    %eax,(%esp)
f0104bc4:	e8 fc f0 ff ff       	call   f0103cc5 <env_run>
	sched_halt();
f0104bc9:	e8 8d fe ff ff       	call   f0104a5b <sched_halt>
}
f0104bce:	83 c4 10             	add    $0x10,%esp
f0104bd1:	5b                   	pop    %ebx
f0104bd2:	5e                   	pop    %esi
f0104bd3:	5d                   	pop    %ebp
f0104bd4:	c3                   	ret    
f0104bd5:	66 90                	xchg   %ax,%ax
f0104bd7:	66 90                	xchg   %ax,%ax
f0104bd9:	66 90                	xchg   %ax,%ax
f0104bdb:	66 90                	xchg   %ax,%ax
f0104bdd:	66 90                	xchg   %ax,%ax
f0104bdf:	90                   	nop

f0104be0 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104be0:	55                   	push   %ebp
f0104be1:	89 e5                	mov    %esp,%ebp
f0104be3:	57                   	push   %edi
f0104be4:	56                   	push   %esi
f0104be5:	53                   	push   %ebx
f0104be6:	83 ec 2c             	sub    $0x2c,%esp
f0104be9:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) // 根据系统调用编号，调用相应的处理函数，枚举值即为inc\syscall.h中定义的值
f0104bec:	83 f8 0d             	cmp    $0xd,%eax
f0104bef:	0f 87 bc 05 00 00    	ja     f01051b1 <syscall+0x5d1>
f0104bf5:	ff 24 85 4c 82 10 f0 	jmp    *-0xfef7db4(,%eax,4)
	user_mem_assert(curenv, s, len, PTE_U);
f0104bfc:	e8 68 18 00 00       	call   f0106469 <cpunum>
f0104c01:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104c08:	00 
f0104c09:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104c0c:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104c10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104c13:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104c17:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c1a:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f0104c20:	89 04 24             	mov    %eax,(%esp)
f0104c23:	e8 44 e9 ff ff       	call   f010356c <user_mem_assert>
	cprintf("%.*s", len, s);
f0104c28:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c2b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104c2f:	8b 45 10             	mov    0x10(%ebp),%eax
f0104c32:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c36:	c7 04 24 46 82 10 f0 	movl   $0xf0108246,(%esp)
f0104c3d:	e8 a7 f2 ff ff       	call   f0103ee9 <cprintf>
	{
	case SYS_cputs:
		sys_cputs((char *)a1, (size_t)a2);
		return 0;
f0104c42:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c47:	e9 71 05 00 00       	jmp    f01051bd <syscall+0x5dd>
	return cons_getc();
f0104c4c:	e8 04 ba ff ff       	call   f0100655 <cons_getc>
	case SYS_cgetc:
		return sys_cgetc();
f0104c51:	e9 67 05 00 00       	jmp    f01051bd <syscall+0x5dd>
	return curenv->env_id;
f0104c56:	e8 0e 18 00 00       	call   f0106469 <cpunum>
f0104c5b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c5e:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f0104c64:	8b 40 48             	mov    0x48(%eax),%eax
	case SYS_getenvid:
		return sys_getenvid();
f0104c67:	e9 51 05 00 00       	jmp    f01051bd <syscall+0x5dd>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104c6c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104c73:	00 
f0104c74:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104c77:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c7b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c7e:	89 04 24             	mov    %eax,(%esp)
f0104c81:	e8 d9 e9 ff ff       	call   f010365f <envid2env>
		return r;
f0104c86:	89 c2                	mov    %eax,%edx
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104c88:	85 c0                	test   %eax,%eax
f0104c8a:	78 10                	js     f0104c9c <syscall+0xbc>
	env_destroy(e);
f0104c8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c8f:	89 04 24             	mov    %eax,(%esp)
f0104c92:	e8 8d ef ff ff       	call   f0103c24 <env_destroy>
	return 0;
f0104c97:	ba 00 00 00 00       	mov    $0x0,%edx
	case SYS_env_destroy:
		return sys_env_destroy((envid_t)a1);
f0104c9c:	89 d0                	mov    %edx,%eax
f0104c9e:	e9 1a 05 00 00       	jmp    f01051bd <syscall+0x5dd>
	sched_yield();
f0104ca3:	e8 89 fe ff ff       	call   f0104b31 <sched_yield>
	int Ecode = env_alloc(&new_env, curenv->env_id);
f0104ca8:	e8 bc 17 00 00       	call   f0106469 <cpunum>
f0104cad:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cb0:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f0104cb6:	8b 40 48             	mov    0x48(%eax),%eax
f0104cb9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104cbd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104cc0:	89 04 24             	mov    %eax,(%esp)
f0104cc3:	e8 a7 ea ff ff       	call   f010376f <env_alloc>
		return Ecode;
f0104cc8:	89 c2                	mov    %eax,%edx
	if (Ecode) // 如果发生错误就返回error code
f0104cca:	85 c0                	test   %eax,%eax
f0104ccc:	75 2e                	jne    f0104cfc <syscall+0x11c>
	new_env->env_status = ENV_NOT_RUNNABLE;
f0104cce:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104cd1:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	new_env->env_tf = curenv->env_tf; // 拷贝父进程的trapframe
f0104cd8:	e8 8c 17 00 00       	call   f0106469 <cpunum>
f0104cdd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ce0:	8b b0 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%esi
f0104ce6:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104ceb:	89 df                	mov    %ebx,%edi
f0104ced:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	new_env->env_tf.tf_regs.reg_eax = 0;
f0104cef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104cf2:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return new_env->env_id; // 返回子进程的id
f0104cf9:	8b 50 48             	mov    0x48(%eax),%edx
	case SYS_yield:
		sys_yield();
		return 0;
	case SYS_exofork:
		return sys_exofork();
f0104cfc:	89 d0                	mov    %edx,%eax
f0104cfe:	e9 ba 04 00 00       	jmp    f01051bd <syscall+0x5dd>
	int Ecode = envid2env(envid, &e, 1);
f0104d03:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104d0a:	00 
f0104d0b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d0e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d12:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d15:	89 04 24             	mov    %eax,(%esp)
f0104d18:	e8 42 e9 ff ff       	call   f010365f <envid2env>
		return Ecode;
f0104d1d:	89 c2                	mov    %eax,%edx
	if (Ecode)
f0104d1f:	85 c0                	test   %eax,%eax
f0104d21:	75 21                	jne    f0104d44 <syscall+0x164>
	if ((status != ENV_RUNNABLE) && (status != ENV_NOT_RUNNABLE)) // 检查status是合法的
f0104d23:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f0104d27:	74 06                	je     f0104d2f <syscall+0x14f>
f0104d29:	83 7d 10 02          	cmpl   $0x2,0x10(%ebp)
f0104d2d:	75 10                	jne    f0104d3f <syscall+0x15f>
	e->env_status = status; // 设置状态
f0104d2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d32:	8b 75 10             	mov    0x10(%ebp),%esi
f0104d35:	89 70 54             	mov    %esi,0x54(%eax)
	return 0;
f0104d38:	ba 00 00 00 00       	mov    $0x0,%edx
f0104d3d:	eb 05                	jmp    f0104d44 <syscall+0x164>
		return -E_INVAL;
f0104d3f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
	case SYS_env_set_status:
		return sys_env_set_status((envid_t)a1, (int)a2);
f0104d44:	89 d0                	mov    %edx,%eax
f0104d46:	e9 72 04 00 00       	jmp    f01051bd <syscall+0x5dd>
	if ((Ecode = envid2env(envid, &e, 1))) // 得到Env结构
f0104d4b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104d52:	00 
f0104d53:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d56:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d5a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104d5d:	89 04 24             	mov    %eax,(%esp)
f0104d60:	e8 fa e8 ff ff       	call   f010365f <envid2env>
		return Ecode;
f0104d65:	89 c2                	mov    %eax,%edx
	if ((Ecode = envid2env(envid, &e, 1))) // 得到Env结构
f0104d67:	85 c0                	test   %eax,%eax
f0104d69:	75 7f                	jne    f0104dea <syscall+0x20a>
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || perm & ~PTE_SYSCALL) // 检查perm
f0104d6b:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d6e:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0104d73:	83 f8 05             	cmp    $0x5,%eax
f0104d76:	75 58                	jne    f0104dd0 <syscall+0x1f0>
	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE != 0) // 检查va
f0104d78:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104d7f:	77 56                	ja     f0104dd7 <syscall+0x1f7>
f0104d81:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104d88:	75 54                	jne    f0104dde <syscall+0x1fe>
	struct PageInfo *p = page_alloc(ALLOC_ZERO);
f0104d8a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104d91:	e8 8a c3 ff ff       	call   f0101120 <page_alloc>
f0104d96:	89 c3                	mov    %eax,%ebx
	if (!p) // 没有内存，分配页面失败
f0104d98:	85 c0                	test   %eax,%eax
f0104d9a:	74 49                	je     f0104de5 <syscall+0x205>
	Ecode = page_insert(e->env_pgdir, p, va, perm);
f0104d9c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d9f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104da3:	8b 45 10             	mov    0x10(%ebp),%eax
f0104da6:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104daa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104dae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104db1:	8b 40 60             	mov    0x60(%eax),%eax
f0104db4:	89 04 24             	mov    %eax,(%esp)
f0104db7:	e8 96 c6 ff ff       	call   f0101452 <page_insert>
f0104dbc:	89 c6                	mov    %eax,%esi
	return 0;
f0104dbe:	89 c2                	mov    %eax,%edx
	if (Ecode)
f0104dc0:	85 c0                	test   %eax,%eax
f0104dc2:	74 26                	je     f0104dea <syscall+0x20a>
		page_decref(p); // 释放p
f0104dc4:	89 1c 24             	mov    %ebx,(%esp)
f0104dc7:	e8 25 c4 ff ff       	call   f01011f1 <page_decref>
		return Ecode;
f0104dcc:	89 f2                	mov    %esi,%edx
f0104dce:	eb 1a                	jmp    f0104dea <syscall+0x20a>
		return -E_INVAL;
f0104dd0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104dd5:	eb 13                	jmp    f0104dea <syscall+0x20a>
		return -E_INVAL;
f0104dd7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104ddc:	eb 0c                	jmp    f0104dea <syscall+0x20a>
f0104dde:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104de3:	eb 05                	jmp    f0104dea <syscall+0x20a>
		return -E_NO_MEM;
f0104de5:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
	case SYS_page_alloc:
		return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
f0104dea:	89 d0                	mov    %edx,%eax
f0104dec:	e9 cc 03 00 00       	jmp    f01051bd <syscall+0x5dd>
	if ((Ecode = envid2env(srcenvid, &src, 1))) // 得到Env结构
f0104df1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104df8:	00 
f0104df9:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104dfc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e00:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104e03:	89 04 24             	mov    %eax,(%esp)
f0104e06:	e8 54 e8 ff ff       	call   f010365f <envid2env>
		return Ecode;
f0104e0b:	89 c2                	mov    %eax,%edx
	if ((Ecode = envid2env(srcenvid, &src, 1))) // 得到Env结构
f0104e0d:	85 c0                	test   %eax,%eax
f0104e0f:	0f 85 c1 00 00 00    	jne    f0104ed6 <syscall+0x2f6>
	if ((Ecode = envid2env(dstenvid, &dst, 1)))
f0104e15:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e1c:	00 
f0104e1d:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104e20:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e24:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e27:	89 04 24             	mov    %eax,(%esp)
f0104e2a:	e8 30 e8 ff ff       	call   f010365f <envid2env>
		return Ecode;
f0104e2f:	89 c2                	mov    %eax,%edx
	if ((Ecode = envid2env(dstenvid, &dst, 1)))
f0104e31:	85 c0                	test   %eax,%eax
f0104e33:	0f 85 9d 00 00 00    	jne    f0104ed6 <syscall+0x2f6>
	if (((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)) || (perm & ~PTE_SYSCALL)) // 检查perm
f0104e39:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104e3c:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0104e41:	83 f8 05             	cmp    $0x5,%eax
f0104e44:	75 68                	jne    f0104eae <syscall+0x2ce>
	if ((uintptr_t)srcva >= UTOP || (uintptr_t)srcva % PGSIZE != 0 // 检查va
f0104e46:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104e4d:	77 66                	ja     f0104eb5 <syscall+0x2d5>
f0104e4f:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104e56:	75 64                	jne    f0104ebc <syscall+0x2dc>
		|| (uintptr_t)dstva >= UTOP || (uintptr_t)dstva % PGSIZE != 0)
f0104e58:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104e5f:	77 62                	ja     f0104ec3 <syscall+0x2e3>
f0104e61:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104e68:	75 60                	jne    f0104eca <syscall+0x2ea>
	struct PageInfo *p = page_lookup(src->env_pgdir, srcva, &pte); // 找到src对应的页面
f0104e6a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e6d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104e71:	8b 45 10             	mov    0x10(%ebp),%eax
f0104e74:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e78:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e7b:	8b 40 60             	mov    0x60(%eax),%eax
f0104e7e:	89 04 24             	mov    %eax,(%esp)
f0104e81:	e8 7d c4 ff ff       	call   f0101303 <page_lookup>
	if (!p)														   // 没有权限
f0104e86:	85 c0                	test   %eax,%eax
f0104e88:	74 47                	je     f0104ed1 <syscall+0x2f1>
	Ecode = page_insert(dst->env_pgdir, p, dstva, perm); // 把src对应的页面也映射到dst上，这样两者都映射到同一个页面
f0104e8a:	8b 4d 1c             	mov    0x1c(%ebp),%ecx
f0104e8d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104e91:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104e94:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104e98:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e9f:	8b 40 60             	mov    0x60(%eax),%eax
f0104ea2:	89 04 24             	mov    %eax,(%esp)
f0104ea5:	e8 a8 c5 ff ff       	call   f0101452 <page_insert>
f0104eaa:	89 c2                	mov    %eax,%edx
f0104eac:	eb 28                	jmp    f0104ed6 <syscall+0x2f6>
		return -E_INVAL;
f0104eae:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104eb3:	eb 21                	jmp    f0104ed6 <syscall+0x2f6>
		return -E_INVAL;
f0104eb5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104eba:	eb 1a                	jmp    f0104ed6 <syscall+0x2f6>
f0104ebc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104ec1:	eb 13                	jmp    f0104ed6 <syscall+0x2f6>
f0104ec3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104ec8:	eb 0c                	jmp    f0104ed6 <syscall+0x2f6>
f0104eca:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104ecf:	eb 05                	jmp    f0104ed6 <syscall+0x2f6>
		return -E_INVAL;
f0104ed1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
	case SYS_page_map:
		return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
f0104ed6:	89 d0                	mov    %edx,%eax
f0104ed8:	e9 e0 02 00 00       	jmp    f01051bd <syscall+0x5dd>
	if ((Ecode = envid2env(envid, &e, 1))) // 得到Env结构
f0104edd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104ee4:	00 
f0104ee5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ee8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104eec:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104eef:	89 04 24             	mov    %eax,(%esp)
f0104ef2:	e8 68 e7 ff ff       	call   f010365f <envid2env>
		return Ecode;
f0104ef7:	89 c2                	mov    %eax,%edx
	if ((Ecode = envid2env(envid, &e, 1))) // 得到Env结构
f0104ef9:	85 c0                	test   %eax,%eax
f0104efb:	75 3a                	jne    f0104f37 <syscall+0x357>
	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE != 0)
f0104efd:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104f04:	77 25                	ja     f0104f2b <syscall+0x34b>
f0104f06:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104f0d:	75 23                	jne    f0104f32 <syscall+0x352>
	page_remove(e->env_pgdir, va);
f0104f0f:	8b 45 10             	mov    0x10(%ebp),%eax
f0104f12:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f19:	8b 40 60             	mov    0x60(%eax),%eax
f0104f1c:	89 04 24             	mov    %eax,(%esp)
f0104f1f:	e8 e5 c4 ff ff       	call   f0101409 <page_remove>
	return 0;
f0104f24:	ba 00 00 00 00       	mov    $0x0,%edx
f0104f29:	eb 0c                	jmp    f0104f37 <syscall+0x357>
		return -E_INVAL;
f0104f2b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
f0104f30:	eb 05                	jmp    f0104f37 <syscall+0x357>
f0104f32:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
	case SYS_page_unmap:
		return sys_page_unmap((envid_t)a1, (void *)a2);
f0104f37:	89 d0                	mov    %edx,%eax
f0104f39:	e9 7f 02 00 00       	jmp    f01051bd <syscall+0x5dd>
	int Ecode = envid2env(envid, &e, 1);
f0104f3e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f45:	00 
f0104f46:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f49:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f4d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f50:	89 04 24             	mov    %eax,(%esp)
f0104f53:	e8 07 e7 ff ff       	call   f010365f <envid2env>
	if (Ecode)
f0104f58:	85 c0                	test   %eax,%eax
f0104f5a:	0f 85 5d 02 00 00    	jne    f01051bd <syscall+0x5dd>
	e->env_pgfault_upcall = func;
f0104f60:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104f63:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104f66:	89 4a 64             	mov    %ecx,0x64(%edx)
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f0104f69:	e9 4f 02 00 00       	jmp    f01051bd <syscall+0x5dd>
	if ((Ecode = envid2env(envid, &dst, 0)) < 0)
f0104f6e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104f75:	00 
f0104f76:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104f79:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f7d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f80:	89 04 24             	mov    %eax,(%esp)
f0104f83:	e8 d7 e6 ff ff       	call   f010365f <envid2env>
f0104f88:	85 c0                	test   %eax,%eax
f0104f8a:	0f 88 2d 02 00 00    	js     f01051bd <syscall+0x5dd>
	if (!dst->env_ipc_recving)
f0104f90:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f93:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104f97:	0f 84 fa 00 00 00    	je     f0105097 <syscall+0x4b7>
	if ((uintptr_t)srcva >= UTOP)
f0104f9d:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104fa4:	0f 87 9b 00 00 00    	ja     f0105045 <syscall+0x465>
		if ((uintptr_t)srcva % PGSIZE != 0)
f0104faa:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104fb1:	0f 85 ea 00 00 00    	jne    f01050a1 <syscall+0x4c1>
		if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U))
f0104fb7:	8b 45 18             	mov    0x18(%ebp),%eax
f0104fba:	83 e0 05             	and    $0x5,%eax
f0104fbd:	83 f8 05             	cmp    $0x5,%eax
f0104fc0:	0f 85 e5 00 00 00    	jne    f01050ab <syscall+0x4cb>
		if (perm & ~PTE_SYSCALL)
f0104fc6:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f0104fcd:	0f 85 e2 00 00 00    	jne    f01050b5 <syscall+0x4d5>
		if (!(pp = page_lookup(curenv->env_pgdir, srcva, &pte)))
f0104fd3:	e8 91 14 00 00       	call   f0106469 <cpunum>
f0104fd8:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104fdb:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104fdf:	8b 7d 14             	mov    0x14(%ebp),%edi
f0104fe2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104fe6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fe9:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f0104fef:	8b 40 60             	mov    0x60(%eax),%eax
f0104ff2:	89 04 24             	mov    %eax,(%esp)
f0104ff5:	e8 09 c3 ff ff       	call   f0101303 <page_lookup>
f0104ffa:	85 c0                	test   %eax,%eax
f0104ffc:	0f 84 bd 00 00 00    	je     f01050bf <syscall+0x4df>
		if ((perm & PTE_W) && !(*pte & PTE_W))
f0105002:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0105006:	74 0c                	je     f0105014 <syscall+0x434>
f0105008:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010500b:	f6 02 02             	testb  $0x2,(%edx)
f010500e:	0f 84 b5 00 00 00    	je     f01050c9 <syscall+0x4e9>
		if ((uintptr_t)dst->env_ipc_dstva < UTOP)
f0105014:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105017:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f010501a:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f0105020:	77 2c                	ja     f010504e <syscall+0x46e>
			if ((Ecode = page_insert(dst->env_pgdir, pp, dst->env_ipc_dstva, perm)) < 0)
f0105022:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0105025:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105029:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010502d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105031:	8b 42 60             	mov    0x60(%edx),%eax
f0105034:	89 04 24             	mov    %eax,(%esp)
f0105037:	e8 16 c4 ff ff       	call   f0101452 <page_insert>
f010503c:	85 c0                	test   %eax,%eax
f010503e:	79 15                	jns    f0105055 <syscall+0x475>
f0105040:	e9 78 01 00 00       	jmp    f01051bd <syscall+0x5dd>
		perm = 0;
f0105045:	c7 45 18 00 00 00 00 	movl   $0x0,0x18(%ebp)
f010504c:	eb 07                	jmp    f0105055 <syscall+0x475>
			perm = 0;
f010504e:	c7 45 18 00 00 00 00 	movl   $0x0,0x18(%ebp)
	dst->env_ipc_recving = false;
f0105055:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105058:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	dst->env_ipc_from = curenv->env_id;
f010505c:	e8 08 14 00 00       	call   f0106469 <cpunum>
f0105061:	6b c0 74             	imul   $0x74,%eax,%eax
f0105064:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f010506a:	8b 40 48             	mov    0x48(%eax),%eax
f010506d:	89 43 74             	mov    %eax,0x74(%ebx)
	dst->env_ipc_value = value;
f0105070:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105073:	8b 75 10             	mov    0x10(%ebp),%esi
f0105076:	89 70 70             	mov    %esi,0x70(%eax)
	dst->env_ipc_perm = perm;
f0105079:	8b 7d 18             	mov    0x18(%ebp),%edi
f010507c:	89 78 78             	mov    %edi,0x78(%eax)
	dst->env_status = ENV_RUNNABLE;
f010507f:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	dst->env_tf.tf_regs.reg_eax = 0;
f0105086:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f010508d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105092:	e9 26 01 00 00       	jmp    f01051bd <syscall+0x5dd>
		return -E_IPC_NOT_RECV;
f0105097:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f010509c:	e9 1c 01 00 00       	jmp    f01051bd <syscall+0x5dd>
			return -E_INVAL;
f01050a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050a6:	e9 12 01 00 00       	jmp    f01051bd <syscall+0x5dd>
			return -E_INVAL;
f01050ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050b0:	e9 08 01 00 00       	jmp    f01051bd <syscall+0x5dd>
			return -E_INVAL;
f01050b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050ba:	e9 fe 00 00 00       	jmp    f01051bd <syscall+0x5dd>
			return -E_INVAL;
f01050bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050c4:	e9 f4 00 00 00       	jmp    f01051bd <syscall+0x5dd>
			return -E_INVAL;
f01050c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01050ce:	e9 ea 00 00 00       	jmp    f01051bd <syscall+0x5dd>
	if ((uintptr_t)dstva < UTOP && (uintptr_t)dstva % PGSIZE != 0)
f01050d3:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f01050da:	77 0d                	ja     f01050e9 <syscall+0x509>
f01050dc:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f01050e3:	0f 85 cf 00 00 00    	jne    f01051b8 <syscall+0x5d8>
	curenv->env_ipc_recving = true;
f01050e9:	e8 7b 13 00 00       	call   f0106469 <cpunum>
f01050ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01050f1:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f01050f7:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f01050fb:	e8 69 13 00 00       	call   f0106469 <cpunum>
f0105100:	6b c0 74             	imul   $0x74,%eax,%eax
f0105103:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f0105109:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010510c:	89 48 6c             	mov    %ecx,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f010510f:	e8 55 13 00 00       	call   f0106469 <cpunum>
f0105114:	6b c0 74             	imul   $0x74,%eax,%eax
f0105117:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f010511d:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f0105124:	e8 08 fa ff ff       	call   f0104b31 <sched_yield>
	int r = envid2env(envid, &e, 1);
f0105129:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105130:	00 
f0105131:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105134:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105138:	8b 45 0c             	mov    0xc(%ebp),%eax
f010513b:	89 04 24             	mov    %eax,(%esp)
f010513e:	e8 1c e5 ff ff       	call   f010365f <envid2env>
	if (r != 0)
f0105143:	85 c0                	test   %eax,%eax
f0105145:	75 63                	jne    f01051aa <syscall+0x5ca>
	user_mem_assert(e, (const void *)tf, sizeof(struct Trapframe), PTE_U);
f0105147:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010514e:	00 
f010514f:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0105156:	00 
f0105157:	8b 45 10             	mov    0x10(%ebp),%eax
f010515a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010515e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105161:	89 04 24             	mov    %eax,(%esp)
f0105164:	e8 03 e4 ff ff       	call   f010356c <user_mem_assert>
	memmove(&e->env_tf, tf, sizeof(struct Trapframe));
f0105169:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0105170:	00 
f0105171:	8b 45 10             	mov    0x10(%ebp),%eax
f0105174:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105178:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010517b:	89 04 24             	mov    %eax,(%esp)
f010517e:	e8 e1 0c 00 00       	call   f0105e64 <memmove>
	e->env_tf.tf_ds = GD_UD | 3;
f0105183:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105186:	66 c7 40 24 23 00    	movw   $0x23,0x24(%eax)
	e->env_tf.tf_es = GD_UD | 3;
f010518c:	66 c7 40 20 23 00    	movw   $0x23,0x20(%eax)
	e->env_tf.tf_ss = GD_UD | 3;
f0105192:	66 c7 40 40 23 00    	movw   $0x23,0x40(%eax)
	e->env_tf.tf_cs = GD_UT | 3;
f0105198:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
	e->env_tf.tf_eflags &= ~FL_IOPL_MASK; // 普通进程不能有IO权限
f010519e:	8b 50 38             	mov    0x38(%eax),%edx
f01051a1:	80 e6 cf             	and    $0xcf,%dh
f01051a4:	80 ce 02             	or     $0x2,%dh
f01051a7:	89 50 38             	mov    %edx,0x38(%eax)
		return sys_ipc_recv((void *)a1);
	case SYS_env_set_trapframe:
		sys_env_set_trapframe((envid_t)a1, (void *)a2);
	case NSYSCALLS:
	default:
		return -E_INVAL;
f01051aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01051af:	eb 0c                	jmp    f01051bd <syscall+0x5dd>
f01051b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01051b6:	eb 05                	jmp    f01051bd <syscall+0x5dd>
		return sys_ipc_recv((void *)a1);
f01051b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
}
f01051bd:	83 c4 2c             	add    $0x2c,%esp
f01051c0:	5b                   	pop    %ebx
f01051c1:	5e                   	pop    %esi
f01051c2:	5f                   	pop    %edi
f01051c3:	5d                   	pop    %ebp
f01051c4:	c3                   	ret    

f01051c5 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
			   int type, uintptr_t addr)
{
f01051c5:	55                   	push   %ebp
f01051c6:	89 e5                	mov    %esp,%ebp
f01051c8:	57                   	push   %edi
f01051c9:	56                   	push   %esi
f01051ca:	53                   	push   %ebx
f01051cb:	83 ec 14             	sub    $0x14,%esp
f01051ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01051d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01051d4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01051d7:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01051da:	8b 1a                	mov    (%edx),%ebx
f01051dc:	8b 01                	mov    (%ecx),%eax
f01051de:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01051e1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r)
f01051e8:	e9 88 00 00 00       	jmp    f0105275 <stab_binsearch+0xb0>
	{
		int true_m = (l + r) / 2, m = true_m;
f01051ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01051f0:	01 d8                	add    %ebx,%eax
f01051f2:	89 c7                	mov    %eax,%edi
f01051f4:	c1 ef 1f             	shr    $0x1f,%edi
f01051f7:	01 c7                	add    %eax,%edi
f01051f9:	d1 ff                	sar    %edi
f01051fb:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01051fe:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105201:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0105204:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105206:	eb 03                	jmp    f010520b <stab_binsearch+0x46>
			m--;
f0105208:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f010520b:	39 c3                	cmp    %eax,%ebx
f010520d:	7f 1f                	jg     f010522e <stab_binsearch+0x69>
f010520f:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105213:	83 ea 0c             	sub    $0xc,%edx
f0105216:	39 f1                	cmp    %esi,%ecx
f0105218:	75 ee                	jne    f0105208 <stab_binsearch+0x43>
f010521a:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr)
f010521d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105220:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105223:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105227:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010522a:	76 18                	jbe    f0105244 <stab_binsearch+0x7f>
f010522c:	eb 05                	jmp    f0105233 <stab_binsearch+0x6e>
			l = true_m + 1;
f010522e:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0105231:	eb 42                	jmp    f0105275 <stab_binsearch+0xb0>
		{
			*region_left = m;
f0105233:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105236:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0105238:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f010523b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105242:	eb 31                	jmp    f0105275 <stab_binsearch+0xb0>
		}
		else if (stabs[m].n_value > addr)
f0105244:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0105247:	73 17                	jae    f0105260 <stab_binsearch+0x9b>
		{
			*region_right = m - 1;
f0105249:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010524c:	83 e8 01             	sub    $0x1,%eax
f010524f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105252:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105255:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0105257:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010525e:	eb 15                	jmp    f0105275 <stab_binsearch+0xb0>
		}
		else
		{
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105260:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105263:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0105266:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f0105268:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010526c:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f010526e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r)
f0105275:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0105278:	0f 8e 6f ff ff ff    	jle    f01051ed <stab_binsearch+0x28>
		}
	}

	if (!any_matches)
f010527e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0105282:	75 0f                	jne    f0105293 <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f0105284:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105287:	8b 00                	mov    (%eax),%eax
f0105289:	83 e8 01             	sub    $0x1,%eax
f010528c:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010528f:	89 07                	mov    %eax,(%edi)
f0105291:	eb 2c                	jmp    f01052bf <stab_binsearch+0xfa>
	else
	{
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105293:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105296:	8b 00                	mov    (%eax),%eax
			 l > *region_left && stabs[l].n_type != type;
f0105298:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010529b:	8b 0f                	mov    (%edi),%ecx
f010529d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01052a0:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01052a3:	8d 14 97             	lea    (%edi,%edx,4),%edx
		for (l = *region_right;
f01052a6:	eb 03                	jmp    f01052ab <stab_binsearch+0xe6>
			 l--)
f01052a8:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f01052ab:	39 c8                	cmp    %ecx,%eax
f01052ad:	7e 0b                	jle    f01052ba <stab_binsearch+0xf5>
			 l > *region_left && stabs[l].n_type != type;
f01052af:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01052b3:	83 ea 0c             	sub    $0xc,%edx
f01052b6:	39 f3                	cmp    %esi,%ebx
f01052b8:	75 ee                	jne    f01052a8 <stab_binsearch+0xe3>
			/* do nothing */;
		*region_left = l;
f01052ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01052bd:	89 07                	mov    %eax,(%edi)
	}
}
f01052bf:	83 c4 14             	add    $0x14,%esp
f01052c2:	5b                   	pop    %ebx
f01052c3:	5e                   	pop    %esi
f01052c4:	5f                   	pop    %edi
f01052c5:	5d                   	pop    %ebp
f01052c6:	c3                   	ret    

f01052c7 <debuginfo_eip>:
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01052c7:	55                   	push   %ebp
f01052c8:	89 e5                	mov    %esp,%ebp
f01052ca:	57                   	push   %edi
f01052cb:	56                   	push   %esi
f01052cc:	53                   	push   %ebx
f01052cd:	83 ec 4c             	sub    $0x4c,%esp
f01052d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01052d3:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01052d6:	c7 07 84 82 10 f0    	movl   $0xf0108284,(%edi)
	info->eip_line = 0;
f01052dc:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f01052e3:	c7 47 08 84 82 10 f0 	movl   $0xf0108284,0x8(%edi)
	info->eip_fn_namelen = 9;
f01052ea:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f01052f1:	89 5f 10             	mov    %ebx,0x10(%edi)
	info->eip_fn_narg = 0;
f01052f4:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM)
f01052fb:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0105301:	0f 87 cf 00 00 00    	ja     f01053d6 <debuginfo_eip+0x10f>
		const struct UserStabData *usd = (const struct UserStabData *)USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0)
f0105307:	e8 5d 11 00 00       	call   f0106469 <cpunum>
f010530c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105313:	00 
f0105314:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f010531b:	00 
f010531c:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0105323:	00 
f0105324:	6b c0 74             	imul   $0x74,%eax,%eax
f0105327:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f010532d:	89 04 24             	mov    %eax,(%esp)
f0105330:	e8 b8 e1 ff ff       	call   f01034ed <user_mem_check>
f0105335:	85 c0                	test   %eax,%eax
f0105337:	0f 88 6c 02 00 00    	js     f01055a9 <debuginfo_eip+0x2e2>
			return -1;

		stabs = usd->stabs;
f010533d:	a1 00 00 20 00       	mov    0x200000,%eax
		stab_end = usd->stab_end;
f0105342:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0105348:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f010534e:	89 4d c0             	mov    %ecx,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f0105351:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0105357:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, PTE_U) < 0 ||
f010535a:	89 f2                	mov    %esi,%edx
f010535c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010535f:	29 c2                	sub    %eax,%edx
f0105361:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0105364:	e8 00 11 00 00       	call   f0106469 <cpunum>
f0105369:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105370:	00 
f0105371:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0105374:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105378:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010537b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010537f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105382:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f0105388:	89 04 24             	mov    %eax,(%esp)
f010538b:	e8 5d e1 ff ff       	call   f01034ed <user_mem_check>
f0105390:	85 c0                	test   %eax,%eax
f0105392:	0f 88 18 02 00 00    	js     f01055b0 <debuginfo_eip+0x2e9>
			user_mem_check(curenv, (void *)stabstr, (uintptr_t)stabstr_end - (uintptr_t)stabstr, PTE_U) < 0)
f0105398:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010539b:	2b 55 c0             	sub    -0x40(%ebp),%edx
f010539e:	89 55 b8             	mov    %edx,-0x48(%ebp)
f01053a1:	e8 c3 10 00 00       	call   f0106469 <cpunum>
f01053a6:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01053ad:	00 
f01053ae:	8b 55 b8             	mov    -0x48(%ebp),%edx
f01053b1:	89 54 24 08          	mov    %edx,0x8(%esp)
f01053b5:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01053b8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01053bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01053bf:	8b 80 28 a0 1e f0    	mov    -0xfe15fd8(%eax),%eax
f01053c5:	89 04 24             	mov    %eax,(%esp)
f01053c8:	e8 20 e1 ff ff       	call   f01034ed <user_mem_check>
		if (user_mem_check(curenv, (void *)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, PTE_U) < 0 ||
f01053cd:	85 c0                	test   %eax,%eax
f01053cf:	79 1f                	jns    f01053f0 <debuginfo_eip+0x129>
f01053d1:	e9 e1 01 00 00       	jmp    f01055b7 <debuginfo_eip+0x2f0>
		stabstr_end = __STABSTR_END__;
f01053d6:	c7 45 bc 68 65 11 f0 	movl   $0xf0116568,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f01053dd:	c7 45 c0 51 2e 11 f0 	movl   $0xf0112e51,-0x40(%ebp)
		stab_end = __STAB_END__;
f01053e4:	be 50 2e 11 f0       	mov    $0xf0112e50,%esi
		stabs = __STAB_BEGIN__;
f01053e9:	c7 45 c4 30 88 10 f0 	movl   $0xf0108830,-0x3c(%ebp)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01053f0:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01053f3:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f01053f6:	0f 83 c2 01 00 00    	jae    f01055be <debuginfo_eip+0x2f7>
f01053fc:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0105400:	0f 85 bf 01 00 00    	jne    f01055c5 <debuginfo_eip+0x2fe>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105406:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010540d:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f0105410:	c1 fe 02             	sar    $0x2,%esi
f0105413:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0105419:	83 e8 01             	sub    $0x1,%eax
f010541c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010541f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105423:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f010542a:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010542d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105430:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105433:	89 f0                	mov    %esi,%eax
f0105435:	e8 8b fd ff ff       	call   f01051c5 <stab_binsearch>
	if (lfile == 0)
f010543a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010543d:	85 c0                	test   %eax,%eax
f010543f:	0f 84 87 01 00 00    	je     f01055cc <debuginfo_eip+0x305>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105445:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105448:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010544b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010544e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105452:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105459:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010545c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010545f:	89 f0                	mov    %esi,%eax
f0105461:	e8 5f fd ff ff       	call   f01051c5 <stab_binsearch>

	if (lfun <= rfun)
f0105466:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105469:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010546c:	39 f0                	cmp    %esi,%eax
f010546e:	7f 32                	jg     f01054a2 <debuginfo_eip+0x1db>
	{
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105470:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105473:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0105476:	8d 14 91             	lea    (%ecx,%edx,4),%edx
f0105479:	8b 0a                	mov    (%edx),%ecx
f010547b:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f010547e:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0105481:	2b 4d c0             	sub    -0x40(%ebp),%ecx
f0105484:	39 4d b8             	cmp    %ecx,-0x48(%ebp)
f0105487:	73 09                	jae    f0105492 <debuginfo_eip+0x1cb>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105489:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f010548c:	03 4d c0             	add    -0x40(%ebp),%ecx
f010548f:	89 4f 08             	mov    %ecx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105492:	8b 52 08             	mov    0x8(%edx),%edx
f0105495:	89 57 10             	mov    %edx,0x10(%edi)
		addr -= info->eip_fn_addr;
f0105498:	29 d3                	sub    %edx,%ebx
		// Search within the function definition for the line number.
		lline = lfun;
f010549a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010549d:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01054a0:	eb 0f                	jmp    f01054b1 <debuginfo_eip+0x1ea>
	}
	else
	{
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01054a2:	89 5f 10             	mov    %ebx,0x10(%edi)
		lline = lfile;
f01054a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01054ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01054ae:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01054b1:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01054b8:	00 
f01054b9:	8b 47 08             	mov    0x8(%edi),%eax
f01054bc:	89 04 24             	mov    %eax,(%esp)
f01054bf:	e8 37 09 00 00       	call   f0105dfb <strfind>
f01054c4:	2b 47 08             	sub    0x8(%edi),%eax
f01054c7:	89 47 0c             	mov    %eax,0xc(%edi)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr); // 根据%eip的值作为地址查找
f01054ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01054ce:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01054d5:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01054d8:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01054db:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01054de:	89 f0                	mov    %esi,%eax
f01054e0:	e8 e0 fc ff ff       	call   f01051c5 <stab_binsearch>
	if (lline <= rline)									  // 二分查找，left<=right即终止
f01054e5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01054e8:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01054eb:	7f 20                	jg     f010550d <debuginfo_eip+0x246>
	{
		info->eip_line = stabs[lline].n_desc;
f01054ed:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01054f0:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f01054f5:	89 47 04             	mov    %eax,0x4(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile && stabs[lline].n_type != N_SOL && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01054f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054fb:	89 c3                	mov    %eax,%ebx
f01054fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105500:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105503:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0105506:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105509:	89 df                	mov    %ebx,%edi
f010550b:	eb 17                	jmp    f0105524 <debuginfo_eip+0x25d>
		info->eip_line = 0;
f010550d:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
		return -1;
f0105514:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105519:	e9 ba 00 00 00       	jmp    f01055d8 <debuginfo_eip+0x311>
f010551e:	83 e8 01             	sub    $0x1,%eax
f0105521:	83 ea 0c             	sub    $0xc,%edx
f0105524:	89 c6                	mov    %eax,%esi
	while (lline >= lfile && stabs[lline].n_type != N_SOL && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105526:	39 c7                	cmp    %eax,%edi
f0105528:	7f 3c                	jg     f0105566 <debuginfo_eip+0x29f>
f010552a:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010552e:	80 f9 84             	cmp    $0x84,%cl
f0105531:	75 08                	jne    f010553b <debuginfo_eip+0x274>
f0105533:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105536:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105539:	eb 11                	jmp    f010554c <debuginfo_eip+0x285>
f010553b:	80 f9 64             	cmp    $0x64,%cl
f010553e:	75 de                	jne    f010551e <debuginfo_eip+0x257>
f0105540:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0105544:	74 d8                	je     f010551e <debuginfo_eip+0x257>
f0105546:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105549:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010554c:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010554f:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0105552:	8b 04 83             	mov    (%ebx,%eax,4),%eax
f0105555:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0105558:	2b 55 c0             	sub    -0x40(%ebp),%edx
f010555b:	39 d0                	cmp    %edx,%eax
f010555d:	73 0a                	jae    f0105569 <debuginfo_eip+0x2a2>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010555f:	03 45 c0             	add    -0x40(%ebp),%eax
f0105562:	89 07                	mov    %eax,(%edi)
f0105564:	eb 03                	jmp    f0105569 <debuginfo_eip+0x2a2>
f0105566:	8b 7d 0c             	mov    0xc(%ebp),%edi

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105569:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010556c:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
			 lline < rfun && stabs[lline].n_type == N_PSYM;
			 lline++)
			info->eip_fn_narg++;

	return 0;
f010556f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0105574:	39 da                	cmp    %ebx,%edx
f0105576:	7d 60                	jge    f01055d8 <debuginfo_eip+0x311>
		for (lline = lfun + 1;
f0105578:	83 c2 01             	add    $0x1,%edx
f010557b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010557e:	89 d0                	mov    %edx,%eax
f0105580:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105583:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0105586:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0105589:	eb 04                	jmp    f010558f <debuginfo_eip+0x2c8>
			info->eip_fn_narg++;
f010558b:	83 47 14 01          	addl   $0x1,0x14(%edi)
		for (lline = lfun + 1;
f010558f:	39 c3                	cmp    %eax,%ebx
f0105591:	7e 40                	jle    f01055d3 <debuginfo_eip+0x30c>
			 lline < rfun && stabs[lline].n_type == N_PSYM;
f0105593:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105597:	83 c0 01             	add    $0x1,%eax
f010559a:	83 c2 0c             	add    $0xc,%edx
f010559d:	80 f9 a0             	cmp    $0xa0,%cl
f01055a0:	74 e9                	je     f010558b <debuginfo_eip+0x2c4>
	return 0;
f01055a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01055a7:	eb 2f                	jmp    f01055d8 <debuginfo_eip+0x311>
			return -1;
f01055a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01055ae:	eb 28                	jmp    f01055d8 <debuginfo_eip+0x311>
			return -1;
f01055b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01055b5:	eb 21                	jmp    f01055d8 <debuginfo_eip+0x311>
f01055b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01055bc:	eb 1a                	jmp    f01055d8 <debuginfo_eip+0x311>
		return -1;
f01055be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01055c3:	eb 13                	jmp    f01055d8 <debuginfo_eip+0x311>
f01055c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01055ca:	eb 0c                	jmp    f01055d8 <debuginfo_eip+0x311>
		return -1;
f01055cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01055d1:	eb 05                	jmp    f01055d8 <debuginfo_eip+0x311>
	return 0;
f01055d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01055d8:	83 c4 4c             	add    $0x4c,%esp
f01055db:	5b                   	pop    %ebx
f01055dc:	5e                   	pop    %esi
f01055dd:	5f                   	pop    %edi
f01055de:	5d                   	pop    %ebp
f01055df:	c3                   	ret    

f01055e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
f01055e0:	55                   	push   %ebp
f01055e1:	89 e5                	mov    %esp,%ebp
f01055e3:	57                   	push   %edi
f01055e4:	56                   	push   %esi
f01055e5:	53                   	push   %ebx
f01055e6:	83 ec 3c             	sub    $0x3c,%esp
f01055e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01055ec:	89 d7                	mov    %edx,%edi
f01055ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01055f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01055f4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01055f7:	89 c3                	mov    %eax,%ebx
f01055f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01055fc:	8b 45 10             	mov    0x10(%ebp),%eax
f01055ff:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base)
f0105602:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105607:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010560a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010560d:	39 d9                	cmp    %ebx,%ecx
f010560f:	72 05                	jb     f0105616 <printnum+0x36>
f0105611:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0105614:	77 69                	ja     f010567f <printnum+0x9f>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105616:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105619:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f010561d:	83 ee 01             	sub    $0x1,%esi
f0105620:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105624:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105628:	8b 44 24 08          	mov    0x8(%esp),%eax
f010562c:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105630:	89 c3                	mov    %eax,%ebx
f0105632:	89 d6                	mov    %edx,%esi
f0105634:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105637:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010563a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010563e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105642:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105645:	89 04 24             	mov    %eax,(%esp)
f0105648:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010564b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010564f:	e8 5c 12 00 00       	call   f01068b0 <__udivdi3>
f0105654:	89 d9                	mov    %ebx,%ecx
f0105656:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010565a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010565e:	89 04 24             	mov    %eax,(%esp)
f0105661:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105665:	89 fa                	mov    %edi,%edx
f0105667:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010566a:	e8 71 ff ff ff       	call   f01055e0 <printnum>
f010566f:	eb 1b                	jmp    f010568c <printnum+0xac>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105671:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105675:	8b 45 18             	mov    0x18(%ebp),%eax
f0105678:	89 04 24             	mov    %eax,(%esp)
f010567b:	ff d3                	call   *%ebx
f010567d:	eb 03                	jmp    f0105682 <printnum+0xa2>
f010567f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
f0105682:	83 ee 01             	sub    $0x1,%esi
f0105685:	85 f6                	test   %esi,%esi
f0105687:	7f e8                	jg     f0105671 <printnum+0x91>
f0105689:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010568c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105690:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0105694:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105697:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010569a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010569e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01056a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01056a5:	89 04 24             	mov    %eax,(%esp)
f01056a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01056ab:	89 44 24 04          	mov    %eax,0x4(%esp)
f01056af:	e8 2c 13 00 00       	call   f01069e0 <__umoddi3>
f01056b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01056b8:	0f be 80 8e 82 10 f0 	movsbl -0xfef7d72(%eax),%eax
f01056bf:	89 04 24             	mov    %eax,(%esp)
f01056c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01056c5:	ff d0                	call   *%eax
}
f01056c7:	83 c4 3c             	add    $0x3c,%esp
f01056ca:	5b                   	pop    %ebx
f01056cb:	5e                   	pop    %esi
f01056cc:	5f                   	pop    %edi
f01056cd:	5d                   	pop    %ebp
f01056ce:	c3                   	ret    

f01056cf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01056cf:	55                   	push   %ebp
f01056d0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01056d2:	83 fa 01             	cmp    $0x1,%edx
f01056d5:	7e 0e                	jle    f01056e5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01056d7:	8b 10                	mov    (%eax),%edx
f01056d9:	8d 4a 08             	lea    0x8(%edx),%ecx
f01056dc:	89 08                	mov    %ecx,(%eax)
f01056de:	8b 02                	mov    (%edx),%eax
f01056e0:	8b 52 04             	mov    0x4(%edx),%edx
f01056e3:	eb 22                	jmp    f0105707 <getuint+0x38>
	else if (lflag)
f01056e5:	85 d2                	test   %edx,%edx
f01056e7:	74 10                	je     f01056f9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01056e9:	8b 10                	mov    (%eax),%edx
f01056eb:	8d 4a 04             	lea    0x4(%edx),%ecx
f01056ee:	89 08                	mov    %ecx,(%eax)
f01056f0:	8b 02                	mov    (%edx),%eax
f01056f2:	ba 00 00 00 00       	mov    $0x0,%edx
f01056f7:	eb 0e                	jmp    f0105707 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01056f9:	8b 10                	mov    (%eax),%edx
f01056fb:	8d 4a 04             	lea    0x4(%edx),%ecx
f01056fe:	89 08                	mov    %ecx,(%eax)
f0105700:	8b 02                	mov    (%edx),%eax
f0105702:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105707:	5d                   	pop    %ebp
f0105708:	c3                   	ret    

f0105709 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105709:	55                   	push   %ebp
f010570a:	89 e5                	mov    %esp,%ebp
f010570c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010570f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105713:	8b 10                	mov    (%eax),%edx
f0105715:	3b 50 04             	cmp    0x4(%eax),%edx
f0105718:	73 0a                	jae    f0105724 <sprintputch+0x1b>
		*b->buf++ = ch;
f010571a:	8d 4a 01             	lea    0x1(%edx),%ecx
f010571d:	89 08                	mov    %ecx,(%eax)
f010571f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105722:	88 02                	mov    %al,(%edx)
}
f0105724:	5d                   	pop    %ebp
f0105725:	c3                   	ret    

f0105726 <printfmt>:
{
f0105726:	55                   	push   %ebp
f0105727:	89 e5                	mov    %esp,%ebp
f0105729:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
f010572c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010572f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105733:	8b 45 10             	mov    0x10(%ebp),%eax
f0105736:	89 44 24 08          	mov    %eax,0x8(%esp)
f010573a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010573d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105741:	8b 45 08             	mov    0x8(%ebp),%eax
f0105744:	89 04 24             	mov    %eax,(%esp)
f0105747:	e8 02 00 00 00       	call   f010574e <vprintfmt>
}
f010574c:	c9                   	leave  
f010574d:	c3                   	ret    

f010574e <vprintfmt>:
{
f010574e:	55                   	push   %ebp
f010574f:	89 e5                	mov    %esp,%ebp
f0105751:	57                   	push   %edi
f0105752:	56                   	push   %esi
f0105753:	53                   	push   %ebx
f0105754:	83 ec 3c             	sub    $0x3c,%esp
f0105757:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010575a:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010575d:	eb 14                	jmp    f0105773 <vprintfmt+0x25>
			if (ch == '\0')
f010575f:	85 c0                	test   %eax,%eax
f0105761:	0f 84 b3 03 00 00    	je     f0105b1a <vprintfmt+0x3cc>
			putch(ch, putdat);
f0105767:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010576b:	89 04 24             	mov    %eax,(%esp)
f010576e:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
f0105771:	89 f3                	mov    %esi,%ebx
f0105773:	8d 73 01             	lea    0x1(%ebx),%esi
f0105776:	0f b6 03             	movzbl (%ebx),%eax
f0105779:	83 f8 25             	cmp    $0x25,%eax
f010577c:	75 e1                	jne    f010575f <vprintfmt+0x11>
f010577e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0105782:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0105789:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0105790:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0105797:	ba 00 00 00 00       	mov    $0x0,%edx
f010579c:	eb 1d                	jmp    f01057bb <vprintfmt+0x6d>
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f010579e:	89 de                	mov    %ebx,%esi
			padc = '-';
f01057a0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f01057a4:	eb 15                	jmp    f01057bb <vprintfmt+0x6d>
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f01057a6:	89 de                	mov    %ebx,%esi
			padc = '0';
f01057a8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f01057ac:	eb 0d                	jmp    f01057bb <vprintfmt+0x6d>
				width = precision, precision = -1;
f01057ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01057b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01057b4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f01057bb:	8d 5e 01             	lea    0x1(%esi),%ebx
f01057be:	0f b6 0e             	movzbl (%esi),%ecx
f01057c1:	0f b6 c1             	movzbl %cl,%eax
f01057c4:	83 e9 23             	sub    $0x23,%ecx
f01057c7:	80 f9 55             	cmp    $0x55,%cl
f01057ca:	0f 87 2a 03 00 00    	ja     f0105afa <vprintfmt+0x3ac>
f01057d0:	0f b6 c9             	movzbl %cl,%ecx
f01057d3:	ff 24 8d e0 83 10 f0 	jmp    *-0xfef7c20(,%ecx,4)
f01057da:	89 de                	mov    %ebx,%esi
f01057dc:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
f01057e1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f01057e4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f01057e8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01057eb:	8d 58 d0             	lea    -0x30(%eax),%ebx
f01057ee:	83 fb 09             	cmp    $0x9,%ebx
f01057f1:	77 36                	ja     f0105829 <vprintfmt+0xdb>
			for (precision = 0;; ++fmt)
f01057f3:	83 c6 01             	add    $0x1,%esi
			}
f01057f6:	eb e9                	jmp    f01057e1 <vprintfmt+0x93>
			precision = va_arg(ap, int);
f01057f8:	8b 45 14             	mov    0x14(%ebp),%eax
f01057fb:	8d 48 04             	lea    0x4(%eax),%ecx
f01057fe:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105801:	8b 00                	mov    (%eax),%eax
f0105803:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f0105806:	89 de                	mov    %ebx,%esi
			goto process_precision;
f0105808:	eb 22                	jmp    f010582c <vprintfmt+0xde>
f010580a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010580d:	85 c9                	test   %ecx,%ecx
f010580f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105814:	0f 49 c1             	cmovns %ecx,%eax
f0105817:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f010581a:	89 de                	mov    %ebx,%esi
f010581c:	eb 9d                	jmp    f01057bb <vprintfmt+0x6d>
f010581e:	89 de                	mov    %ebx,%esi
			altflag = 1;
f0105820:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0105827:	eb 92                	jmp    f01057bb <vprintfmt+0x6d>
f0105829:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
f010582c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105830:	79 89                	jns    f01057bb <vprintfmt+0x6d>
f0105832:	e9 77 ff ff ff       	jmp    f01057ae <vprintfmt+0x60>
			lflag++;
f0105837:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f010583a:	89 de                	mov    %ebx,%esi
			goto reswitch;
f010583c:	e9 7a ff ff ff       	jmp    f01057bb <vprintfmt+0x6d>
			putch(va_arg(ap, int), putdat);
f0105841:	8b 45 14             	mov    0x14(%ebp),%eax
f0105844:	8d 50 04             	lea    0x4(%eax),%edx
f0105847:	89 55 14             	mov    %edx,0x14(%ebp)
f010584a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010584e:	8b 00                	mov    (%eax),%eax
f0105850:	89 04 24             	mov    %eax,(%esp)
f0105853:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105856:	e9 18 ff ff ff       	jmp    f0105773 <vprintfmt+0x25>
			err = va_arg(ap, int);
f010585b:	8b 45 14             	mov    0x14(%ebp),%eax
f010585e:	8d 50 04             	lea    0x4(%eax),%edx
f0105861:	89 55 14             	mov    %edx,0x14(%ebp)
f0105864:	8b 00                	mov    (%eax),%eax
f0105866:	99                   	cltd   
f0105867:	31 d0                	xor    %edx,%eax
f0105869:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010586b:	83 f8 0f             	cmp    $0xf,%eax
f010586e:	7f 0b                	jg     f010587b <vprintfmt+0x12d>
f0105870:	8b 14 85 40 85 10 f0 	mov    -0xfef7ac0(,%eax,4),%edx
f0105877:	85 d2                	test   %edx,%edx
f0105879:	75 20                	jne    f010589b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
f010587b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010587f:	c7 44 24 08 a6 82 10 	movl   $0xf01082a6,0x8(%esp)
f0105886:	f0 
f0105887:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010588b:	8b 45 08             	mov    0x8(%ebp),%eax
f010588e:	89 04 24             	mov    %eax,(%esp)
f0105891:	e8 90 fe ff ff       	call   f0105726 <printfmt>
f0105896:	e9 d8 fe ff ff       	jmp    f0105773 <vprintfmt+0x25>
				printfmt(putch, putdat, "%s", p);
f010589b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010589f:	c7 44 24 08 f1 7a 10 	movl   $0xf0107af1,0x8(%esp)
f01058a6:	f0 
f01058a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01058ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01058ae:	89 04 24             	mov    %eax,(%esp)
f01058b1:	e8 70 fe ff ff       	call   f0105726 <printfmt>
f01058b6:	e9 b8 fe ff ff       	jmp    f0105773 <vprintfmt+0x25>
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f01058bb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01058be:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01058c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
f01058c4:	8b 45 14             	mov    0x14(%ebp),%eax
f01058c7:	8d 50 04             	lea    0x4(%eax),%edx
f01058ca:	89 55 14             	mov    %edx,0x14(%ebp)
f01058cd:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f01058cf:	85 f6                	test   %esi,%esi
f01058d1:	b8 9f 82 10 f0       	mov    $0xf010829f,%eax
f01058d6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f01058d9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f01058dd:	0f 84 97 00 00 00    	je     f010597a <vprintfmt+0x22c>
f01058e3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01058e7:	0f 8e 9b 00 00 00    	jle    f0105988 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
f01058ed:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01058f1:	89 34 24             	mov    %esi,(%esp)
f01058f4:	e8 af 03 00 00       	call   f0105ca8 <strnlen>
f01058f9:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01058fc:	29 c2                	sub    %eax,%edx
f01058fe:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
f0105901:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0105905:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105908:	89 75 d8             	mov    %esi,-0x28(%ebp)
f010590b:	8b 75 08             	mov    0x8(%ebp),%esi
f010590e:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105911:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
f0105913:	eb 0f                	jmp    f0105924 <vprintfmt+0x1d6>
					putch(padc, putdat);
f0105915:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105919:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010591c:	89 04 24             	mov    %eax,(%esp)
f010591f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105921:	83 eb 01             	sub    $0x1,%ebx
f0105924:	85 db                	test   %ebx,%ebx
f0105926:	7f ed                	jg     f0105915 <vprintfmt+0x1c7>
f0105928:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010592b:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010592e:	85 d2                	test   %edx,%edx
f0105930:	b8 00 00 00 00       	mov    $0x0,%eax
f0105935:	0f 49 c2             	cmovns %edx,%eax
f0105938:	29 c2                	sub    %eax,%edx
f010593a:	89 7d 0c             	mov    %edi,0xc(%ebp)
f010593d:	89 d7                	mov    %edx,%edi
f010593f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105942:	eb 50                	jmp    f0105994 <vprintfmt+0x246>
				if (altflag && (ch < ' ' || ch > '~'))
f0105944:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105948:	74 1e                	je     f0105968 <vprintfmt+0x21a>
f010594a:	0f be d2             	movsbl %dl,%edx
f010594d:	83 ea 20             	sub    $0x20,%edx
f0105950:	83 fa 5e             	cmp    $0x5e,%edx
f0105953:	76 13                	jbe    f0105968 <vprintfmt+0x21a>
					putch('?', putdat);
f0105955:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105958:	89 44 24 04          	mov    %eax,0x4(%esp)
f010595c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105963:	ff 55 08             	call   *0x8(%ebp)
f0105966:	eb 0d                	jmp    f0105975 <vprintfmt+0x227>
					putch(ch, putdat);
f0105968:	8b 55 0c             	mov    0xc(%ebp),%edx
f010596b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010596f:	89 04 24             	mov    %eax,(%esp)
f0105972:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105975:	83 ef 01             	sub    $0x1,%edi
f0105978:	eb 1a                	jmp    f0105994 <vprintfmt+0x246>
f010597a:	89 7d 0c             	mov    %edi,0xc(%ebp)
f010597d:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0105980:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105983:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105986:	eb 0c                	jmp    f0105994 <vprintfmt+0x246>
f0105988:	89 7d 0c             	mov    %edi,0xc(%ebp)
f010598b:	8b 7d dc             	mov    -0x24(%ebp),%edi
f010598e:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105991:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105994:	83 c6 01             	add    $0x1,%esi
f0105997:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f010599b:	0f be c2             	movsbl %dl,%eax
f010599e:	85 c0                	test   %eax,%eax
f01059a0:	74 27                	je     f01059c9 <vprintfmt+0x27b>
f01059a2:	85 db                	test   %ebx,%ebx
f01059a4:	78 9e                	js     f0105944 <vprintfmt+0x1f6>
f01059a6:	83 eb 01             	sub    $0x1,%ebx
f01059a9:	79 99                	jns    f0105944 <vprintfmt+0x1f6>
f01059ab:	89 f8                	mov    %edi,%eax
f01059ad:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01059b0:	8b 75 08             	mov    0x8(%ebp),%esi
f01059b3:	89 c3                	mov    %eax,%ebx
f01059b5:	eb 1a                	jmp    f01059d1 <vprintfmt+0x283>
				putch(' ', putdat);
f01059b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01059bb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01059c2:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01059c4:	83 eb 01             	sub    $0x1,%ebx
f01059c7:	eb 08                	jmp    f01059d1 <vprintfmt+0x283>
f01059c9:	89 fb                	mov    %edi,%ebx
f01059cb:	8b 75 08             	mov    0x8(%ebp),%esi
f01059ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01059d1:	85 db                	test   %ebx,%ebx
f01059d3:	7f e2                	jg     f01059b7 <vprintfmt+0x269>
f01059d5:	89 75 08             	mov    %esi,0x8(%ebp)
f01059d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01059db:	e9 93 fd ff ff       	jmp    f0105773 <vprintfmt+0x25>
	if (lflag >= 2)
f01059e0:	83 fa 01             	cmp    $0x1,%edx
f01059e3:	7e 16                	jle    f01059fb <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
f01059e5:	8b 45 14             	mov    0x14(%ebp),%eax
f01059e8:	8d 50 08             	lea    0x8(%eax),%edx
f01059eb:	89 55 14             	mov    %edx,0x14(%ebp)
f01059ee:	8b 50 04             	mov    0x4(%eax),%edx
f01059f1:	8b 00                	mov    (%eax),%eax
f01059f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01059f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01059f9:	eb 32                	jmp    f0105a2d <vprintfmt+0x2df>
	else if (lflag)
f01059fb:	85 d2                	test   %edx,%edx
f01059fd:	74 18                	je     f0105a17 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
f01059ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a02:	8d 50 04             	lea    0x4(%eax),%edx
f0105a05:	89 55 14             	mov    %edx,0x14(%ebp)
f0105a08:	8b 30                	mov    (%eax),%esi
f0105a0a:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0105a0d:	89 f0                	mov    %esi,%eax
f0105a0f:	c1 f8 1f             	sar    $0x1f,%eax
f0105a12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105a15:	eb 16                	jmp    f0105a2d <vprintfmt+0x2df>
		return va_arg(*ap, int);
f0105a17:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a1a:	8d 50 04             	lea    0x4(%eax),%edx
f0105a1d:	89 55 14             	mov    %edx,0x14(%ebp)
f0105a20:	8b 30                	mov    (%eax),%esi
f0105a22:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0105a25:	89 f0                	mov    %esi,%eax
f0105a27:	c1 f8 1f             	sar    $0x1f,%eax
f0105a2a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
f0105a2d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105a30:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10; // base代表进制数
f0105a33:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long)num < 0)
f0105a38:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105a3c:	0f 89 80 00 00 00    	jns    f0105ac2 <vprintfmt+0x374>
				putch('-', putdat);
f0105a42:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a46:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105a4d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
f0105a50:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105a53:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105a56:	f7 d8                	neg    %eax
f0105a58:	83 d2 00             	adc    $0x0,%edx
f0105a5b:	f7 da                	neg    %edx
			base = 10; // base代表进制数
f0105a5d:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0105a62:	eb 5e                	jmp    f0105ac2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
f0105a64:	8d 45 14             	lea    0x14(%ebp),%eax
f0105a67:	e8 63 fc ff ff       	call   f01056cf <getuint>
			base = 10;
f0105a6c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0105a71:	eb 4f                	jmp    f0105ac2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
f0105a73:	8d 45 14             	lea    0x14(%ebp),%eax
f0105a76:	e8 54 fc ff ff       	call   f01056cf <getuint>
			base = 8;
f0105a7b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105a80:	eb 40                	jmp    f0105ac2 <vprintfmt+0x374>
			putch('0', putdat);
f0105a82:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a86:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105a8d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105a90:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a94:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105a9b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
f0105a9e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105aa1:	8d 50 04             	lea    0x4(%eax),%edx
f0105aa4:	89 55 14             	mov    %edx,0x14(%ebp)
f0105aa7:	8b 00                	mov    (%eax),%eax
f0105aa9:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
f0105aae:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105ab3:	eb 0d                	jmp    f0105ac2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
f0105ab5:	8d 45 14             	lea    0x14(%ebp),%eax
f0105ab8:	e8 12 fc ff ff       	call   f01056cf <getuint>
			base = 16;
f0105abd:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
f0105ac2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
f0105ac6:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105aca:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0105acd:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105ad1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105ad5:	89 04 24             	mov    %eax,(%esp)
f0105ad8:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105adc:	89 fa                	mov    %edi,%edx
f0105ade:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ae1:	e8 fa fa ff ff       	call   f01055e0 <printnum>
			break;
f0105ae6:	e9 88 fc ff ff       	jmp    f0105773 <vprintfmt+0x25>
			putch(ch, putdat);
f0105aeb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105aef:	89 04 24             	mov    %eax,(%esp)
f0105af2:	ff 55 08             	call   *0x8(%ebp)
			break;
f0105af5:	e9 79 fc ff ff       	jmp    f0105773 <vprintfmt+0x25>
			putch('%', putdat);
f0105afa:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105afe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105b05:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105b08:	89 f3                	mov    %esi,%ebx
f0105b0a:	eb 03                	jmp    f0105b0f <vprintfmt+0x3c1>
f0105b0c:	83 eb 01             	sub    $0x1,%ebx
f0105b0f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0105b13:	75 f7                	jne    f0105b0c <vprintfmt+0x3be>
f0105b15:	e9 59 fc ff ff       	jmp    f0105773 <vprintfmt+0x25>
}
f0105b1a:	83 c4 3c             	add    $0x3c,%esp
f0105b1d:	5b                   	pop    %ebx
f0105b1e:	5e                   	pop    %esi
f0105b1f:	5f                   	pop    %edi
f0105b20:	5d                   	pop    %ebp
f0105b21:	c3                   	ret    

f0105b22 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105b22:	55                   	push   %ebp
f0105b23:	89 e5                	mov    %esp,%ebp
f0105b25:	83 ec 28             	sub    $0x28,%esp
f0105b28:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b2b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
f0105b2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105b31:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105b35:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105b38:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105b3f:	85 c0                	test   %eax,%eax
f0105b41:	74 30                	je     f0105b73 <vsnprintf+0x51>
f0105b43:	85 d2                	test   %edx,%edx
f0105b45:	7e 2c                	jle    f0105b73 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
f0105b47:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b4a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105b4e:	8b 45 10             	mov    0x10(%ebp),%eax
f0105b51:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105b55:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105b58:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b5c:	c7 04 24 09 57 10 f0 	movl   $0xf0105709,(%esp)
f0105b63:	e8 e6 fb ff ff       	call   f010574e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105b68:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105b6b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105b71:	eb 05                	jmp    f0105b78 <vsnprintf+0x56>
		return -E_INVAL;
f0105b73:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
f0105b78:	c9                   	leave  
f0105b79:	c3                   	ret    

f0105b7a <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
f0105b7a:	55                   	push   %ebp
f0105b7b:	89 e5                	mov    %esp,%ebp
f0105b7d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105b80:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105b83:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105b87:	8b 45 10             	mov    0x10(%ebp),%eax
f0105b8a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b91:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b95:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b98:	89 04 24             	mov    %eax,(%esp)
f0105b9b:	e8 82 ff ff ff       	call   f0105b22 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105ba0:	c9                   	leave  
f0105ba1:	c3                   	ret    
f0105ba2:	66 90                	xchg   %ax,%ax
f0105ba4:	66 90                	xchg   %ax,%ax
f0105ba6:	66 90                	xchg   %ax,%ax
f0105ba8:	66 90                	xchg   %ax,%ax
f0105baa:	66 90                	xchg   %ax,%ax
f0105bac:	66 90                	xchg   %ax,%ax
f0105bae:	66 90                	xchg   %ax,%ax

f0105bb0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105bb0:	55                   	push   %ebp
f0105bb1:	89 e5                	mov    %esp,%ebp
f0105bb3:	57                   	push   %edi
f0105bb4:	56                   	push   %esi
f0105bb5:	53                   	push   %ebx
f0105bb6:	83 ec 1c             	sub    $0x1c,%esp
f0105bb9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105bbc:	85 c0                	test   %eax,%eax
f0105bbe:	74 10                	je     f0105bd0 <readline+0x20>
		cprintf("%s", prompt);
f0105bc0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105bc4:	c7 04 24 f1 7a 10 f0 	movl   $0xf0107af1,(%esp)
f0105bcb:	e8 19 e3 ff ff       	call   f0103ee9 <cprintf>
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105bd0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105bd7:	e8 0c ac ff ff       	call   f01007e8 <iscons>
f0105bdc:	89 c7                	mov    %eax,%edi
	i = 0;
f0105bde:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0105be3:	e8 ef ab ff ff       	call   f01007d7 <getchar>
f0105be8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105bea:	85 c0                	test   %eax,%eax
f0105bec:	79 25                	jns    f0105c13 <readline+0x63>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105bee:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
f0105bf3:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105bf6:	0f 84 89 00 00 00    	je     f0105c85 <readline+0xd5>
				cprintf("read error: %e\n", c);
f0105bfc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105c00:	c7 04 24 9f 85 10 f0 	movl   $0xf010859f,(%esp)
f0105c07:	e8 dd e2 ff ff       	call   f0103ee9 <cprintf>
			return NULL;
f0105c0c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c11:	eb 72                	jmp    f0105c85 <readline+0xd5>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105c13:	83 f8 7f             	cmp    $0x7f,%eax
f0105c16:	74 05                	je     f0105c1d <readline+0x6d>
f0105c18:	83 f8 08             	cmp    $0x8,%eax
f0105c1b:	75 1a                	jne    f0105c37 <readline+0x87>
f0105c1d:	85 f6                	test   %esi,%esi
f0105c1f:	90                   	nop
f0105c20:	7e 15                	jle    f0105c37 <readline+0x87>
			if (echoing)
f0105c22:	85 ff                	test   %edi,%edi
f0105c24:	74 0c                	je     f0105c32 <readline+0x82>
				cputchar('\b');
f0105c26:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105c2d:	e8 95 ab ff ff       	call   f01007c7 <cputchar>
			i--;
f0105c32:	83 ee 01             	sub    $0x1,%esi
f0105c35:	eb ac                	jmp    f0105be3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105c37:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105c3d:	7f 1c                	jg     f0105c5b <readline+0xab>
f0105c3f:	83 fb 1f             	cmp    $0x1f,%ebx
f0105c42:	7e 17                	jle    f0105c5b <readline+0xab>
			if (echoing)
f0105c44:	85 ff                	test   %edi,%edi
f0105c46:	74 08                	je     f0105c50 <readline+0xa0>
				cputchar(c);
f0105c48:	89 1c 24             	mov    %ebx,(%esp)
f0105c4b:	e8 77 ab ff ff       	call   f01007c7 <cputchar>
			buf[i++] = c;
f0105c50:	88 9e 80 9a 1e f0    	mov    %bl,-0xfe16580(%esi)
f0105c56:	8d 76 01             	lea    0x1(%esi),%esi
f0105c59:	eb 88                	jmp    f0105be3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105c5b:	83 fb 0d             	cmp    $0xd,%ebx
f0105c5e:	74 09                	je     f0105c69 <readline+0xb9>
f0105c60:	83 fb 0a             	cmp    $0xa,%ebx
f0105c63:	0f 85 7a ff ff ff    	jne    f0105be3 <readline+0x33>
			if (echoing)
f0105c69:	85 ff                	test   %edi,%edi
f0105c6b:	74 0c                	je     f0105c79 <readline+0xc9>
				cputchar('\n');
f0105c6d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105c74:	e8 4e ab ff ff       	call   f01007c7 <cputchar>
			buf[i] = 0;
f0105c79:	c6 86 80 9a 1e f0 00 	movb   $0x0,-0xfe16580(%esi)
			return buf;
f0105c80:	b8 80 9a 1e f0       	mov    $0xf01e9a80,%eax
		}
	}
}
f0105c85:	83 c4 1c             	add    $0x1c,%esp
f0105c88:	5b                   	pop    %ebx
f0105c89:	5e                   	pop    %esi
f0105c8a:	5f                   	pop    %edi
f0105c8b:	5d                   	pop    %ebp
f0105c8c:	c3                   	ret    
f0105c8d:	66 90                	xchg   %ax,%ax
f0105c8f:	90                   	nop

f0105c90 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105c90:	55                   	push   %ebp
f0105c91:	89 e5                	mov    %esp,%ebp
f0105c93:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105c96:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c9b:	eb 03                	jmp    f0105ca0 <strlen+0x10>
		n++;
f0105c9d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0105ca0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105ca4:	75 f7                	jne    f0105c9d <strlen+0xd>
	return n;
}
f0105ca6:	5d                   	pop    %ebp
f0105ca7:	c3                   	ret    

f0105ca8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105ca8:	55                   	push   %ebp
f0105ca9:	89 e5                	mov    %esp,%ebp
f0105cab:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105cae:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105cb1:	b8 00 00 00 00       	mov    $0x0,%eax
f0105cb6:	eb 03                	jmp    f0105cbb <strnlen+0x13>
		n++;
f0105cb8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105cbb:	39 d0                	cmp    %edx,%eax
f0105cbd:	74 06                	je     f0105cc5 <strnlen+0x1d>
f0105cbf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105cc3:	75 f3                	jne    f0105cb8 <strnlen+0x10>
	return n;
}
f0105cc5:	5d                   	pop    %ebp
f0105cc6:	c3                   	ret    

f0105cc7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105cc7:	55                   	push   %ebp
f0105cc8:	89 e5                	mov    %esp,%ebp
f0105cca:	53                   	push   %ebx
f0105ccb:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105cd1:	89 c2                	mov    %eax,%edx
f0105cd3:	83 c2 01             	add    $0x1,%edx
f0105cd6:	83 c1 01             	add    $0x1,%ecx
f0105cd9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105cdd:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105ce0:	84 db                	test   %bl,%bl
f0105ce2:	75 ef                	jne    f0105cd3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105ce4:	5b                   	pop    %ebx
f0105ce5:	5d                   	pop    %ebp
f0105ce6:	c3                   	ret    

f0105ce7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105ce7:	55                   	push   %ebp
f0105ce8:	89 e5                	mov    %esp,%ebp
f0105cea:	53                   	push   %ebx
f0105ceb:	83 ec 08             	sub    $0x8,%esp
f0105cee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105cf1:	89 1c 24             	mov    %ebx,(%esp)
f0105cf4:	e8 97 ff ff ff       	call   f0105c90 <strlen>
	strcpy(dst + len, src);
f0105cf9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105cfc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105d00:	01 d8                	add    %ebx,%eax
f0105d02:	89 04 24             	mov    %eax,(%esp)
f0105d05:	e8 bd ff ff ff       	call   f0105cc7 <strcpy>
	return dst;
}
f0105d0a:	89 d8                	mov    %ebx,%eax
f0105d0c:	83 c4 08             	add    $0x8,%esp
f0105d0f:	5b                   	pop    %ebx
f0105d10:	5d                   	pop    %ebp
f0105d11:	c3                   	ret    

f0105d12 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105d12:	55                   	push   %ebp
f0105d13:	89 e5                	mov    %esp,%ebp
f0105d15:	56                   	push   %esi
f0105d16:	53                   	push   %ebx
f0105d17:	8b 75 08             	mov    0x8(%ebp),%esi
f0105d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105d1d:	89 f3                	mov    %esi,%ebx
f0105d1f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105d22:	89 f2                	mov    %esi,%edx
f0105d24:	eb 0f                	jmp    f0105d35 <strncpy+0x23>
		*dst++ = *src;
f0105d26:	83 c2 01             	add    $0x1,%edx
f0105d29:	0f b6 01             	movzbl (%ecx),%eax
f0105d2c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105d2f:	80 39 01             	cmpb   $0x1,(%ecx)
f0105d32:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0105d35:	39 da                	cmp    %ebx,%edx
f0105d37:	75 ed                	jne    f0105d26 <strncpy+0x14>
	}
	return ret;
}
f0105d39:	89 f0                	mov    %esi,%eax
f0105d3b:	5b                   	pop    %ebx
f0105d3c:	5e                   	pop    %esi
f0105d3d:	5d                   	pop    %ebp
f0105d3e:	c3                   	ret    

f0105d3f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105d3f:	55                   	push   %ebp
f0105d40:	89 e5                	mov    %esp,%ebp
f0105d42:	56                   	push   %esi
f0105d43:	53                   	push   %ebx
f0105d44:	8b 75 08             	mov    0x8(%ebp),%esi
f0105d47:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105d4a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105d4d:	89 f0                	mov    %esi,%eax
f0105d4f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105d53:	85 c9                	test   %ecx,%ecx
f0105d55:	75 0b                	jne    f0105d62 <strlcpy+0x23>
f0105d57:	eb 1d                	jmp    f0105d76 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105d59:	83 c0 01             	add    $0x1,%eax
f0105d5c:	83 c2 01             	add    $0x1,%edx
f0105d5f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0105d62:	39 d8                	cmp    %ebx,%eax
f0105d64:	74 0b                	je     f0105d71 <strlcpy+0x32>
f0105d66:	0f b6 0a             	movzbl (%edx),%ecx
f0105d69:	84 c9                	test   %cl,%cl
f0105d6b:	75 ec                	jne    f0105d59 <strlcpy+0x1a>
f0105d6d:	89 c2                	mov    %eax,%edx
f0105d6f:	eb 02                	jmp    f0105d73 <strlcpy+0x34>
f0105d71:	89 c2                	mov    %eax,%edx
		*dst = '\0';
f0105d73:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0105d76:	29 f0                	sub    %esi,%eax
}
f0105d78:	5b                   	pop    %ebx
f0105d79:	5e                   	pop    %esi
f0105d7a:	5d                   	pop    %ebp
f0105d7b:	c3                   	ret    

f0105d7c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105d7c:	55                   	push   %ebp
f0105d7d:	89 e5                	mov    %esp,%ebp
f0105d7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105d82:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105d85:	eb 06                	jmp    f0105d8d <strcmp+0x11>
		p++, q++;
f0105d87:	83 c1 01             	add    $0x1,%ecx
f0105d8a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0105d8d:	0f b6 01             	movzbl (%ecx),%eax
f0105d90:	84 c0                	test   %al,%al
f0105d92:	74 04                	je     f0105d98 <strcmp+0x1c>
f0105d94:	3a 02                	cmp    (%edx),%al
f0105d96:	74 ef                	je     f0105d87 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105d98:	0f b6 c0             	movzbl %al,%eax
f0105d9b:	0f b6 12             	movzbl (%edx),%edx
f0105d9e:	29 d0                	sub    %edx,%eax
}
f0105da0:	5d                   	pop    %ebp
f0105da1:	c3                   	ret    

f0105da2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105da2:	55                   	push   %ebp
f0105da3:	89 e5                	mov    %esp,%ebp
f0105da5:	53                   	push   %ebx
f0105da6:	8b 45 08             	mov    0x8(%ebp),%eax
f0105da9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105dac:	89 c3                	mov    %eax,%ebx
f0105dae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105db1:	eb 06                	jmp    f0105db9 <strncmp+0x17>
		n--, p++, q++;
f0105db3:	83 c0 01             	add    $0x1,%eax
f0105db6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105db9:	39 d8                	cmp    %ebx,%eax
f0105dbb:	74 15                	je     f0105dd2 <strncmp+0x30>
f0105dbd:	0f b6 08             	movzbl (%eax),%ecx
f0105dc0:	84 c9                	test   %cl,%cl
f0105dc2:	74 04                	je     f0105dc8 <strncmp+0x26>
f0105dc4:	3a 0a                	cmp    (%edx),%cl
f0105dc6:	74 eb                	je     f0105db3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105dc8:	0f b6 00             	movzbl (%eax),%eax
f0105dcb:	0f b6 12             	movzbl (%edx),%edx
f0105dce:	29 d0                	sub    %edx,%eax
f0105dd0:	eb 05                	jmp    f0105dd7 <strncmp+0x35>
		return 0;
f0105dd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105dd7:	5b                   	pop    %ebx
f0105dd8:	5d                   	pop    %ebp
f0105dd9:	c3                   	ret    

f0105dda <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105dda:	55                   	push   %ebp
f0105ddb:	89 e5                	mov    %esp,%ebp
f0105ddd:	8b 45 08             	mov    0x8(%ebp),%eax
f0105de0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105de4:	eb 07                	jmp    f0105ded <strchr+0x13>
		if (*s == c)
f0105de6:	38 ca                	cmp    %cl,%dl
f0105de8:	74 0f                	je     f0105df9 <strchr+0x1f>
	for (; *s; s++)
f0105dea:	83 c0 01             	add    $0x1,%eax
f0105ded:	0f b6 10             	movzbl (%eax),%edx
f0105df0:	84 d2                	test   %dl,%dl
f0105df2:	75 f2                	jne    f0105de6 <strchr+0xc>
			return (char *) s;
	return 0;
f0105df4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105df9:	5d                   	pop    %ebp
f0105dfa:	c3                   	ret    

f0105dfb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105dfb:	55                   	push   %ebp
f0105dfc:	89 e5                	mov    %esp,%ebp
f0105dfe:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105e05:	eb 07                	jmp    f0105e0e <strfind+0x13>
		if (*s == c)
f0105e07:	38 ca                	cmp    %cl,%dl
f0105e09:	74 0a                	je     f0105e15 <strfind+0x1a>
	for (; *s; s++)
f0105e0b:	83 c0 01             	add    $0x1,%eax
f0105e0e:	0f b6 10             	movzbl (%eax),%edx
f0105e11:	84 d2                	test   %dl,%dl
f0105e13:	75 f2                	jne    f0105e07 <strfind+0xc>
			break;
	return (char *) s;
}
f0105e15:	5d                   	pop    %ebp
f0105e16:	c3                   	ret    

f0105e17 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105e17:	55                   	push   %ebp
f0105e18:	89 e5                	mov    %esp,%ebp
f0105e1a:	57                   	push   %edi
f0105e1b:	56                   	push   %esi
f0105e1c:	53                   	push   %ebx
f0105e1d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105e20:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105e23:	85 c9                	test   %ecx,%ecx
f0105e25:	74 36                	je     f0105e5d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105e27:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105e2d:	75 28                	jne    f0105e57 <memset+0x40>
f0105e2f:	f6 c1 03             	test   $0x3,%cl
f0105e32:	75 23                	jne    f0105e57 <memset+0x40>
		c &= 0xFF;
f0105e34:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105e38:	89 d3                	mov    %edx,%ebx
f0105e3a:	c1 e3 08             	shl    $0x8,%ebx
f0105e3d:	89 d6                	mov    %edx,%esi
f0105e3f:	c1 e6 18             	shl    $0x18,%esi
f0105e42:	89 d0                	mov    %edx,%eax
f0105e44:	c1 e0 10             	shl    $0x10,%eax
f0105e47:	09 f0                	or     %esi,%eax
f0105e49:	09 c2                	or     %eax,%edx
f0105e4b:	89 d0                	mov    %edx,%eax
f0105e4d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105e4f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105e52:	fc                   	cld    
f0105e53:	f3 ab                	rep stos %eax,%es:(%edi)
f0105e55:	eb 06                	jmp    f0105e5d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105e57:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105e5a:	fc                   	cld    
f0105e5b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105e5d:	89 f8                	mov    %edi,%eax
f0105e5f:	5b                   	pop    %ebx
f0105e60:	5e                   	pop    %esi
f0105e61:	5f                   	pop    %edi
f0105e62:	5d                   	pop    %ebp
f0105e63:	c3                   	ret    

f0105e64 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105e64:	55                   	push   %ebp
f0105e65:	89 e5                	mov    %esp,%ebp
f0105e67:	57                   	push   %edi
f0105e68:	56                   	push   %esi
f0105e69:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e6c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105e6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105e72:	39 c6                	cmp    %eax,%esi
f0105e74:	73 35                	jae    f0105eab <memmove+0x47>
f0105e76:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105e79:	39 d0                	cmp    %edx,%eax
f0105e7b:	73 2e                	jae    f0105eab <memmove+0x47>
		s += n;
		d += n;
f0105e7d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0105e80:	89 d6                	mov    %edx,%esi
f0105e82:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105e84:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105e8a:	75 13                	jne    f0105e9f <memmove+0x3b>
f0105e8c:	f6 c1 03             	test   $0x3,%cl
f0105e8f:	75 0e                	jne    f0105e9f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105e91:	83 ef 04             	sub    $0x4,%edi
f0105e94:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105e97:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105e9a:	fd                   	std    
f0105e9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105e9d:	eb 09                	jmp    f0105ea8 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105e9f:	83 ef 01             	sub    $0x1,%edi
f0105ea2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105ea5:	fd                   	std    
f0105ea6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105ea8:	fc                   	cld    
f0105ea9:	eb 1d                	jmp    f0105ec8 <memmove+0x64>
f0105eab:	89 f2                	mov    %esi,%edx
f0105ead:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105eaf:	f6 c2 03             	test   $0x3,%dl
f0105eb2:	75 0f                	jne    f0105ec3 <memmove+0x5f>
f0105eb4:	f6 c1 03             	test   $0x3,%cl
f0105eb7:	75 0a                	jne    f0105ec3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105eb9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105ebc:	89 c7                	mov    %eax,%edi
f0105ebe:	fc                   	cld    
f0105ebf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105ec1:	eb 05                	jmp    f0105ec8 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
f0105ec3:	89 c7                	mov    %eax,%edi
f0105ec5:	fc                   	cld    
f0105ec6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105ec8:	5e                   	pop    %esi
f0105ec9:	5f                   	pop    %edi
f0105eca:	5d                   	pop    %ebp
f0105ecb:	c3                   	ret    

f0105ecc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105ecc:	55                   	push   %ebp
f0105ecd:	89 e5                	mov    %esp,%ebp
f0105ecf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105ed2:	8b 45 10             	mov    0x10(%ebp),%eax
f0105ed5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105edc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ee0:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ee3:	89 04 24             	mov    %eax,(%esp)
f0105ee6:	e8 79 ff ff ff       	call   f0105e64 <memmove>
}
f0105eeb:	c9                   	leave  
f0105eec:	c3                   	ret    

f0105eed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105eed:	55                   	push   %ebp
f0105eee:	89 e5                	mov    %esp,%ebp
f0105ef0:	56                   	push   %esi
f0105ef1:	53                   	push   %ebx
f0105ef2:	8b 55 08             	mov    0x8(%ebp),%edx
f0105ef5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105ef8:	89 d6                	mov    %edx,%esi
f0105efa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105efd:	eb 1a                	jmp    f0105f19 <memcmp+0x2c>
		if (*s1 != *s2)
f0105eff:	0f b6 02             	movzbl (%edx),%eax
f0105f02:	0f b6 19             	movzbl (%ecx),%ebx
f0105f05:	38 d8                	cmp    %bl,%al
f0105f07:	74 0a                	je     f0105f13 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105f09:	0f b6 c0             	movzbl %al,%eax
f0105f0c:	0f b6 db             	movzbl %bl,%ebx
f0105f0f:	29 d8                	sub    %ebx,%eax
f0105f11:	eb 0f                	jmp    f0105f22 <memcmp+0x35>
		s1++, s2++;
f0105f13:	83 c2 01             	add    $0x1,%edx
f0105f16:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
f0105f19:	39 f2                	cmp    %esi,%edx
f0105f1b:	75 e2                	jne    f0105eff <memcmp+0x12>
	}

	return 0;
f0105f1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105f22:	5b                   	pop    %ebx
f0105f23:	5e                   	pop    %esi
f0105f24:	5d                   	pop    %ebp
f0105f25:	c3                   	ret    

f0105f26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105f26:	55                   	push   %ebp
f0105f27:	89 e5                	mov    %esp,%ebp
f0105f29:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105f2f:	89 c2                	mov    %eax,%edx
f0105f31:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105f34:	eb 07                	jmp    f0105f3d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105f36:	38 08                	cmp    %cl,(%eax)
f0105f38:	74 07                	je     f0105f41 <memfind+0x1b>
	for (; s < ends; s++)
f0105f3a:	83 c0 01             	add    $0x1,%eax
f0105f3d:	39 d0                	cmp    %edx,%eax
f0105f3f:	72 f5                	jb     f0105f36 <memfind+0x10>
			break;
	return (void *) s;
}
f0105f41:	5d                   	pop    %ebp
f0105f42:	c3                   	ret    

f0105f43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105f43:	55                   	push   %ebp
f0105f44:	89 e5                	mov    %esp,%ebp
f0105f46:	57                   	push   %edi
f0105f47:	56                   	push   %esi
f0105f48:	53                   	push   %ebx
f0105f49:	8b 55 08             	mov    0x8(%ebp),%edx
f0105f4c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105f4f:	eb 03                	jmp    f0105f54 <strtol+0x11>
		s++;
f0105f51:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f0105f54:	0f b6 0a             	movzbl (%edx),%ecx
f0105f57:	80 f9 09             	cmp    $0x9,%cl
f0105f5a:	74 f5                	je     f0105f51 <strtol+0xe>
f0105f5c:	80 f9 20             	cmp    $0x20,%cl
f0105f5f:	74 f0                	je     f0105f51 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0105f61:	80 f9 2b             	cmp    $0x2b,%cl
f0105f64:	75 0a                	jne    f0105f70 <strtol+0x2d>
		s++;
f0105f66:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0105f69:	bf 00 00 00 00       	mov    $0x0,%edi
f0105f6e:	eb 11                	jmp    f0105f81 <strtol+0x3e>
f0105f70:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
f0105f75:	80 f9 2d             	cmp    $0x2d,%cl
f0105f78:	75 07                	jne    f0105f81 <strtol+0x3e>
		s++, neg = 1;
f0105f7a:	8d 52 01             	lea    0x1(%edx),%edx
f0105f7d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105f81:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0105f86:	75 15                	jne    f0105f9d <strtol+0x5a>
f0105f88:	80 3a 30             	cmpb   $0x30,(%edx)
f0105f8b:	75 10                	jne    f0105f9d <strtol+0x5a>
f0105f8d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105f91:	75 0a                	jne    f0105f9d <strtol+0x5a>
		s += 2, base = 16;
f0105f93:	83 c2 02             	add    $0x2,%edx
f0105f96:	b8 10 00 00 00       	mov    $0x10,%eax
f0105f9b:	eb 10                	jmp    f0105fad <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f0105f9d:	85 c0                	test   %eax,%eax
f0105f9f:	75 0c                	jne    f0105fad <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105fa1:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
f0105fa3:	80 3a 30             	cmpb   $0x30,(%edx)
f0105fa6:	75 05                	jne    f0105fad <strtol+0x6a>
		s++, base = 8;
f0105fa8:	83 c2 01             	add    $0x1,%edx
f0105fab:	b0 08                	mov    $0x8,%al
		base = 10;
f0105fad:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105fb2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105fb5:	0f b6 0a             	movzbl (%edx),%ecx
f0105fb8:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0105fbb:	89 f0                	mov    %esi,%eax
f0105fbd:	3c 09                	cmp    $0x9,%al
f0105fbf:	77 08                	ja     f0105fc9 <strtol+0x86>
			dig = *s - '0';
f0105fc1:	0f be c9             	movsbl %cl,%ecx
f0105fc4:	83 e9 30             	sub    $0x30,%ecx
f0105fc7:	eb 20                	jmp    f0105fe9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0105fc9:	8d 71 9f             	lea    -0x61(%ecx),%esi
f0105fcc:	89 f0                	mov    %esi,%eax
f0105fce:	3c 19                	cmp    $0x19,%al
f0105fd0:	77 08                	ja     f0105fda <strtol+0x97>
			dig = *s - 'a' + 10;
f0105fd2:	0f be c9             	movsbl %cl,%ecx
f0105fd5:	83 e9 57             	sub    $0x57,%ecx
f0105fd8:	eb 0f                	jmp    f0105fe9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f0105fda:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0105fdd:	89 f0                	mov    %esi,%eax
f0105fdf:	3c 19                	cmp    $0x19,%al
f0105fe1:	77 16                	ja     f0105ff9 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0105fe3:	0f be c9             	movsbl %cl,%ecx
f0105fe6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0105fe9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0105fec:	7d 0f                	jge    f0105ffd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f0105fee:	83 c2 01             	add    $0x1,%edx
f0105ff1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0105ff5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0105ff7:	eb bc                	jmp    f0105fb5 <strtol+0x72>
f0105ff9:	89 d8                	mov    %ebx,%eax
f0105ffb:	eb 02                	jmp    f0105fff <strtol+0xbc>
f0105ffd:	89 d8                	mov    %ebx,%eax

	if (endptr)
f0105fff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0106003:	74 05                	je     f010600a <strtol+0xc7>
		*endptr = (char *) s;
f0106005:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106008:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f010600a:	f7 d8                	neg    %eax
f010600c:	85 ff                	test   %edi,%edi
f010600e:	0f 44 c3             	cmove  %ebx,%eax
}
f0106011:	5b                   	pop    %ebx
f0106012:	5e                   	pop    %esi
f0106013:	5f                   	pop    %edi
f0106014:	5d                   	pop    %ebp
f0106015:	c3                   	ret    
f0106016:	66 90                	xchg   %ax,%ax

f0106018 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106018:	fa                   	cli    

	xorw    %ax, %ax
f0106019:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010601b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010601d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010601f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106021:	0f 01 16             	lgdtl  (%esi)
f0106024:	74 70                	je     f0106096 <mpentry_end+0x4>
	movl    %cr0, %eax
f0106026:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106029:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f010602d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106030:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0106036:	08 00                	or     %al,(%eax)

f0106038 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106038:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f010603c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010603e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106040:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0106042:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0106046:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106048:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010604a:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f010604f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0106052:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106055:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010605a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f010605d:	8b 25 84 9e 1e f0    	mov    0xf01e9e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106063:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106068:	b8 fb 01 10 f0       	mov    $0xf01001fb,%eax
	call    *%eax
f010606d:	ff d0                	call   *%eax

f010606f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f010606f:	eb fe                	jmp    f010606f <spin>
f0106071:	8d 76 00             	lea    0x0(%esi),%esi

f0106074 <gdt>:
	...
f010607c:	ff                   	(bad)  
f010607d:	ff 00                	incl   (%eax)
f010607f:	00 00                	add    %al,(%eax)
f0106081:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106088:	00                   	.byte 0x0
f0106089:	92                   	xchg   %eax,%edx
f010608a:	cf                   	iret   
	...

f010608c <gdtdesc>:
f010608c:	17                   	pop    %ss
f010608d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106092 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106092:	90                   	nop
f0106093:	66 90                	xchg   %ax,%ax
f0106095:	66 90                	xchg   %ax,%ax
f0106097:	66 90                	xchg   %ax,%ax
f0106099:	66 90                	xchg   %ax,%ax
f010609b:	66 90                	xchg   %ax,%ax
f010609d:	66 90                	xchg   %ax,%ax
f010609f:	90                   	nop

f01060a0 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01060a0:	55                   	push   %ebp
f01060a1:	89 e5                	mov    %esp,%ebp
f01060a3:	56                   	push   %esi
f01060a4:	53                   	push   %ebx
f01060a5:	83 ec 10             	sub    $0x10,%esp
	if (PGNUM(pa) >= npages)
f01060a8:	8b 0d 88 9e 1e f0    	mov    0xf01e9e88,%ecx
f01060ae:	89 c3                	mov    %eax,%ebx
f01060b0:	c1 eb 0c             	shr    $0xc,%ebx
f01060b3:	39 cb                	cmp    %ecx,%ebx
f01060b5:	72 20                	jb     f01060d7 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01060b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01060bb:	c7 44 24 08 64 6b 10 	movl   $0xf0106b64,0x8(%esp)
f01060c2:	f0 
f01060c3:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01060ca:	00 
f01060cb:	c7 04 24 3d 87 10 f0 	movl   $0xf010873d,(%esp)
f01060d2:	e8 69 9f ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01060d7:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01060dd:	01 d0                	add    %edx,%eax
	if (PGNUM(pa) >= npages)
f01060df:	89 c2                	mov    %eax,%edx
f01060e1:	c1 ea 0c             	shr    $0xc,%edx
f01060e4:	39 d1                	cmp    %edx,%ecx
f01060e6:	77 20                	ja     f0106108 <mpsearch1+0x68>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01060e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01060ec:	c7 44 24 08 64 6b 10 	movl   $0xf0106b64,0x8(%esp)
f01060f3:	f0 
f01060f4:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01060fb:	00 
f01060fc:	c7 04 24 3d 87 10 f0 	movl   $0xf010873d,(%esp)
f0106103:	e8 38 9f ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106108:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f010610e:	eb 36                	jmp    f0106146 <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106110:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106117:	00 
f0106118:	c7 44 24 04 4d 87 10 	movl   $0xf010874d,0x4(%esp)
f010611f:	f0 
f0106120:	89 1c 24             	mov    %ebx,(%esp)
f0106123:	e8 c5 fd ff ff       	call   f0105eed <memcmp>
f0106128:	85 c0                	test   %eax,%eax
f010612a:	75 17                	jne    f0106143 <mpsearch1+0xa3>
	for (i = 0; i < len; i++)
f010612c:	ba 00 00 00 00       	mov    $0x0,%edx
		sum += ((uint8_t *)addr)[i];
f0106131:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0106135:	01 c8                	add    %ecx,%eax
	for (i = 0; i < len; i++)
f0106137:	83 c2 01             	add    $0x1,%edx
f010613a:	83 fa 10             	cmp    $0x10,%edx
f010613d:	75 f2                	jne    f0106131 <mpsearch1+0x91>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010613f:	84 c0                	test   %al,%al
f0106141:	74 0e                	je     f0106151 <mpsearch1+0xb1>
	for (; mp < end; mp++)
f0106143:	83 c3 10             	add    $0x10,%ebx
f0106146:	39 f3                	cmp    %esi,%ebx
f0106148:	72 c6                	jb     f0106110 <mpsearch1+0x70>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010614a:	b8 00 00 00 00       	mov    $0x0,%eax
f010614f:	eb 02                	jmp    f0106153 <mpsearch1+0xb3>
f0106151:	89 d8                	mov    %ebx,%eax
}
f0106153:	83 c4 10             	add    $0x10,%esp
f0106156:	5b                   	pop    %ebx
f0106157:	5e                   	pop    %esi
f0106158:	5d                   	pop    %ebp
f0106159:	c3                   	ret    

f010615a <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010615a:	55                   	push   %ebp
f010615b:	89 e5                	mov    %esp,%ebp
f010615d:	57                   	push   %edi
f010615e:	56                   	push   %esi
f010615f:	53                   	push   %ebx
f0106160:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106163:	c7 05 c0 a3 1e f0 20 	movl   $0xf01ea020,0xf01ea3c0
f010616a:	a0 1e f0 
	if (PGNUM(pa) >= npages)
f010616d:	83 3d 88 9e 1e f0 00 	cmpl   $0x0,0xf01e9e88
f0106174:	75 24                	jne    f010619a <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106176:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f010617d:	00 
f010617e:	c7 44 24 08 64 6b 10 	movl   $0xf0106b64,0x8(%esp)
f0106185:	f0 
f0106186:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f010618d:	00 
f010618e:	c7 04 24 3d 87 10 f0 	movl   $0xf010873d,(%esp)
f0106195:	e8 a6 9e ff ff       	call   f0100040 <_panic>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010619a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01061a1:	85 c0                	test   %eax,%eax
f01061a3:	74 16                	je     f01061bb <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f01061a5:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f01061a8:	ba 00 04 00 00       	mov    $0x400,%edx
f01061ad:	e8 ee fe ff ff       	call   f01060a0 <mpsearch1>
f01061b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01061b5:	85 c0                	test   %eax,%eax
f01061b7:	75 3c                	jne    f01061f5 <mp_init+0x9b>
f01061b9:	eb 20                	jmp    f01061db <mp_init+0x81>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f01061bb:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01061c2:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01061c5:	2d 00 04 00 00       	sub    $0x400,%eax
f01061ca:	ba 00 04 00 00       	mov    $0x400,%edx
f01061cf:	e8 cc fe ff ff       	call   f01060a0 <mpsearch1>
f01061d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01061d7:	85 c0                	test   %eax,%eax
f01061d9:	75 1a                	jne    f01061f5 <mp_init+0x9b>
	return mpsearch1(0xF0000, 0x10000);
f01061db:	ba 00 00 01 00       	mov    $0x10000,%edx
f01061e0:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01061e5:	e8 b6 fe ff ff       	call   f01060a0 <mpsearch1>
f01061ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f01061ed:	85 c0                	test   %eax,%eax
f01061ef:	0f 84 54 02 00 00    	je     f0106449 <mp_init+0x2ef>
	if (mp->physaddr == 0 || mp->type != 0) {
f01061f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01061f8:	8b 70 04             	mov    0x4(%eax),%esi
f01061fb:	85 f6                	test   %esi,%esi
f01061fd:	74 06                	je     f0106205 <mp_init+0xab>
f01061ff:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106203:	74 11                	je     f0106216 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0106205:	c7 04 24 b0 85 10 f0 	movl   $0xf01085b0,(%esp)
f010620c:	e8 d8 dc ff ff       	call   f0103ee9 <cprintf>
f0106211:	e9 33 02 00 00       	jmp    f0106449 <mp_init+0x2ef>
	if (PGNUM(pa) >= npages)
f0106216:	89 f0                	mov    %esi,%eax
f0106218:	c1 e8 0c             	shr    $0xc,%eax
f010621b:	3b 05 88 9e 1e f0    	cmp    0xf01e9e88,%eax
f0106221:	72 20                	jb     f0106243 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106223:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106227:	c7 44 24 08 64 6b 10 	movl   $0xf0106b64,0x8(%esp)
f010622e:	f0 
f010622f:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106236:	00 
f0106237:	c7 04 24 3d 87 10 f0 	movl   $0xf010873d,(%esp)
f010623e:	e8 fd 9d ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106243:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106249:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106250:	00 
f0106251:	c7 44 24 04 52 87 10 	movl   $0xf0108752,0x4(%esp)
f0106258:	f0 
f0106259:	89 1c 24             	mov    %ebx,(%esp)
f010625c:	e8 8c fc ff ff       	call   f0105eed <memcmp>
f0106261:	85 c0                	test   %eax,%eax
f0106263:	74 11                	je     f0106276 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106265:	c7 04 24 e0 85 10 f0 	movl   $0xf01085e0,(%esp)
f010626c:	e8 78 dc ff ff       	call   f0103ee9 <cprintf>
f0106271:	e9 d3 01 00 00       	jmp    f0106449 <mp_init+0x2ef>
	if (sum(conf, conf->length) != 0) {
f0106276:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f010627a:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f010627e:	0f b7 f8             	movzwl %ax,%edi
	sum = 0;
f0106281:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0106286:	b8 00 00 00 00       	mov    $0x0,%eax
f010628b:	eb 0d                	jmp    f010629a <mp_init+0x140>
		sum += ((uint8_t *)addr)[i];
f010628d:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0106294:	f0 
f0106295:	01 ca                	add    %ecx,%edx
	for (i = 0; i < len; i++)
f0106297:	83 c0 01             	add    $0x1,%eax
f010629a:	39 c7                	cmp    %eax,%edi
f010629c:	7f ef                	jg     f010628d <mp_init+0x133>
	if (sum(conf, conf->length) != 0) {
f010629e:	84 d2                	test   %dl,%dl
f01062a0:	74 11                	je     f01062b3 <mp_init+0x159>
		cprintf("SMP: Bad MP configuration checksum\n");
f01062a2:	c7 04 24 14 86 10 f0 	movl   $0xf0108614,(%esp)
f01062a9:	e8 3b dc ff ff       	call   f0103ee9 <cprintf>
f01062ae:	e9 96 01 00 00       	jmp    f0106449 <mp_init+0x2ef>
	if (conf->version != 1 && conf->version != 4) {
f01062b3:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f01062b7:	3c 04                	cmp    $0x4,%al
f01062b9:	74 1f                	je     f01062da <mp_init+0x180>
f01062bb:	3c 01                	cmp    $0x1,%al
f01062bd:	8d 76 00             	lea    0x0(%esi),%esi
f01062c0:	74 18                	je     f01062da <mp_init+0x180>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01062c2:	0f b6 c0             	movzbl %al,%eax
f01062c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01062c9:	c7 04 24 38 86 10 f0 	movl   $0xf0108638,(%esp)
f01062d0:	e8 14 dc ff ff       	call   f0103ee9 <cprintf>
f01062d5:	e9 6f 01 00 00       	jmp    f0106449 <mp_init+0x2ef>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01062da:	0f b7 73 28          	movzwl 0x28(%ebx),%esi
f01062de:	0f b7 7d e2          	movzwl -0x1e(%ebp),%edi
f01062e2:	01 df                	add    %ebx,%edi
	sum = 0;
f01062e4:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01062e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01062ee:	eb 09                	jmp    f01062f9 <mp_init+0x19f>
		sum += ((uint8_t *)addr)[i];
f01062f0:	0f b6 0c 07          	movzbl (%edi,%eax,1),%ecx
f01062f4:	01 ca                	add    %ecx,%edx
	for (i = 0; i < len; i++)
f01062f6:	83 c0 01             	add    $0x1,%eax
f01062f9:	39 c6                	cmp    %eax,%esi
f01062fb:	7f f3                	jg     f01062f0 <mp_init+0x196>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01062fd:	02 53 2a             	add    0x2a(%ebx),%dl
f0106300:	84 d2                	test   %dl,%dl
f0106302:	74 11                	je     f0106315 <mp_init+0x1bb>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106304:	c7 04 24 58 86 10 f0 	movl   $0xf0108658,(%esp)
f010630b:	e8 d9 db ff ff       	call   f0103ee9 <cprintf>
f0106310:	e9 34 01 00 00       	jmp    f0106449 <mp_init+0x2ef>
	if ((conf = mpconfig(&mp)) == 0)
f0106315:	85 db                	test   %ebx,%ebx
f0106317:	0f 84 2c 01 00 00    	je     f0106449 <mp_init+0x2ef>
		return;
	ismp = 1;
f010631d:	c7 05 00 a0 1e f0 01 	movl   $0x1,0xf01ea000
f0106324:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106327:	8b 43 24             	mov    0x24(%ebx),%eax
f010632a:	a3 00 b0 22 f0       	mov    %eax,0xf022b000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010632f:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0106332:	be 00 00 00 00       	mov    $0x0,%esi
f0106337:	e9 86 00 00 00       	jmp    f01063c2 <mp_init+0x268>
		switch (*p) {
f010633c:	0f b6 07             	movzbl (%edi),%eax
f010633f:	84 c0                	test   %al,%al
f0106341:	74 06                	je     f0106349 <mp_init+0x1ef>
f0106343:	3c 04                	cmp    $0x4,%al
f0106345:	77 57                	ja     f010639e <mp_init+0x244>
f0106347:	eb 50                	jmp    f0106399 <mp_init+0x23f>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106349:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f010634d:	8d 76 00             	lea    0x0(%esi),%esi
f0106350:	74 11                	je     f0106363 <mp_init+0x209>
				bootcpu = &cpus[ncpu];
f0106352:	6b 05 c4 a3 1e f0 74 	imul   $0x74,0xf01ea3c4,%eax
f0106359:	05 20 a0 1e f0       	add    $0xf01ea020,%eax
f010635e:	a3 c0 a3 1e f0       	mov    %eax,0xf01ea3c0
			if (ncpu < NCPU) {
f0106363:	a1 c4 a3 1e f0       	mov    0xf01ea3c4,%eax
f0106368:	83 f8 07             	cmp    $0x7,%eax
f010636b:	7f 13                	jg     f0106380 <mp_init+0x226>
				cpus[ncpu].cpu_id = ncpu;
f010636d:	6b d0 74             	imul   $0x74,%eax,%edx
f0106370:	88 82 20 a0 1e f0    	mov    %al,-0xfe15fe0(%edx)
				ncpu++;
f0106376:	83 c0 01             	add    $0x1,%eax
f0106379:	a3 c4 a3 1e f0       	mov    %eax,0xf01ea3c4
f010637e:	eb 14                	jmp    f0106394 <mp_init+0x23a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106380:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0106384:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106388:	c7 04 24 88 86 10 f0 	movl   $0xf0108688,(%esp)
f010638f:	e8 55 db ff ff       	call   f0103ee9 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106394:	83 c7 14             	add    $0x14,%edi
			continue;
f0106397:	eb 26                	jmp    f01063bf <mp_init+0x265>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106399:	83 c7 08             	add    $0x8,%edi
			continue;
f010639c:	eb 21                	jmp    f01063bf <mp_init+0x265>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010639e:	0f b6 c0             	movzbl %al,%eax
f01063a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01063a5:	c7 04 24 b0 86 10 f0 	movl   $0xf01086b0,(%esp)
f01063ac:	e8 38 db ff ff       	call   f0103ee9 <cprintf>
			ismp = 0;
f01063b1:	c7 05 00 a0 1e f0 00 	movl   $0x0,0xf01ea000
f01063b8:	00 00 00 
			i = conf->entry;
f01063bb:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01063bf:	83 c6 01             	add    $0x1,%esi
f01063c2:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01063c6:	39 c6                	cmp    %eax,%esi
f01063c8:	0f 82 6e ff ff ff    	jb     f010633c <mp_init+0x1e2>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01063ce:	a1 c0 a3 1e f0       	mov    0xf01ea3c0,%eax
f01063d3:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01063da:	83 3d 00 a0 1e f0 00 	cmpl   $0x0,0xf01ea000
f01063e1:	75 22                	jne    f0106405 <mp_init+0x2ab>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01063e3:	c7 05 c4 a3 1e f0 01 	movl   $0x1,0xf01ea3c4
f01063ea:	00 00 00 
		lapicaddr = 0;
f01063ed:	c7 05 00 b0 22 f0 00 	movl   $0x0,0xf022b000
f01063f4:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01063f7:	c7 04 24 d0 86 10 f0 	movl   $0xf01086d0,(%esp)
f01063fe:	e8 e6 da ff ff       	call   f0103ee9 <cprintf>
		return;
f0106403:	eb 44                	jmp    f0106449 <mp_init+0x2ef>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106405:	8b 15 c4 a3 1e f0    	mov    0xf01ea3c4,%edx
f010640b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010640f:	0f b6 00             	movzbl (%eax),%eax
f0106412:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106416:	c7 04 24 57 87 10 f0 	movl   $0xf0108757,(%esp)
f010641d:	e8 c7 da ff ff       	call   f0103ee9 <cprintf>

	if (mp->imcrp) {
f0106422:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106425:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106429:	74 1e                	je     f0106449 <mp_init+0x2ef>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010642b:	c7 04 24 fc 86 10 f0 	movl   $0xf01086fc,(%esp)
f0106432:	e8 b2 da ff ff       	call   f0103ee9 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106437:	ba 22 00 00 00       	mov    $0x22,%edx
f010643c:	b8 70 00 00 00       	mov    $0x70,%eax
f0106441:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106442:	b2 23                	mov    $0x23,%dl
f0106444:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106445:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106448:	ee                   	out    %al,(%dx)
	}
}
f0106449:	83 c4 2c             	add    $0x2c,%esp
f010644c:	5b                   	pop    %ebx
f010644d:	5e                   	pop    %esi
f010644e:	5f                   	pop    %edi
f010644f:	5d                   	pop    %ebp
f0106450:	c3                   	ret    

f0106451 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106451:	55                   	push   %ebp
f0106452:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106454:	8b 0d 04 b0 22 f0    	mov    0xf022b004,%ecx
f010645a:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010645d:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010645f:	a1 04 b0 22 f0       	mov    0xf022b004,%eax
f0106464:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106467:	5d                   	pop    %ebp
f0106468:	c3                   	ret    

f0106469 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106469:	55                   	push   %ebp
f010646a:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010646c:	a1 04 b0 22 f0       	mov    0xf022b004,%eax
f0106471:	85 c0                	test   %eax,%eax
f0106473:	74 08                	je     f010647d <cpunum+0x14>
		return lapic[ID] >> 24;
f0106475:	8b 40 20             	mov    0x20(%eax),%eax
f0106478:	c1 e8 18             	shr    $0x18,%eax
f010647b:	eb 05                	jmp    f0106482 <cpunum+0x19>
	return 0;
f010647d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106482:	5d                   	pop    %ebp
f0106483:	c3                   	ret    

f0106484 <lapic_init>:
	if (!lapicaddr)
f0106484:	a1 00 b0 22 f0       	mov    0xf022b000,%eax
f0106489:	85 c0                	test   %eax,%eax
f010648b:	0f 84 23 01 00 00    	je     f01065b4 <lapic_init+0x130>
{
f0106491:	55                   	push   %ebp
f0106492:	89 e5                	mov    %esp,%ebp
f0106494:	83 ec 18             	sub    $0x18,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0106497:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010649e:	00 
f010649f:	89 04 24             	mov    %eax,(%esp)
f01064a2:	e8 23 b0 ff ff       	call   f01014ca <mmio_map_region>
f01064a7:	a3 04 b0 22 f0       	mov    %eax,0xf022b004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01064ac:	ba 27 01 00 00       	mov    $0x127,%edx
f01064b1:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01064b6:	e8 96 ff ff ff       	call   f0106451 <lapicw>
	lapicw(TDCR, X1);
f01064bb:	ba 0b 00 00 00       	mov    $0xb,%edx
f01064c0:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01064c5:	e8 87 ff ff ff       	call   f0106451 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01064ca:	ba 20 00 02 00       	mov    $0x20020,%edx
f01064cf:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01064d4:	e8 78 ff ff ff       	call   f0106451 <lapicw>
	lapicw(TICR, 10000000); 
f01064d9:	ba 80 96 98 00       	mov    $0x989680,%edx
f01064de:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01064e3:	e8 69 ff ff ff       	call   f0106451 <lapicw>
	if (thiscpu != bootcpu)
f01064e8:	e8 7c ff ff ff       	call   f0106469 <cpunum>
f01064ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01064f0:	05 20 a0 1e f0       	add    $0xf01ea020,%eax
f01064f5:	39 05 c0 a3 1e f0    	cmp    %eax,0xf01ea3c0
f01064fb:	74 0f                	je     f010650c <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f01064fd:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106502:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106507:	e8 45 ff ff ff       	call   f0106451 <lapicw>
	lapicw(LINT1, MASKED);
f010650c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106511:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106516:	e8 36 ff ff ff       	call   f0106451 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010651b:	a1 04 b0 22 f0       	mov    0xf022b004,%eax
f0106520:	8b 40 30             	mov    0x30(%eax),%eax
f0106523:	c1 e8 10             	shr    $0x10,%eax
f0106526:	3c 03                	cmp    $0x3,%al
f0106528:	76 0f                	jbe    f0106539 <lapic_init+0xb5>
		lapicw(PCINT, MASKED);
f010652a:	ba 00 00 01 00       	mov    $0x10000,%edx
f010652f:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106534:	e8 18 ff ff ff       	call   f0106451 <lapicw>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106539:	ba 33 00 00 00       	mov    $0x33,%edx
f010653e:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106543:	e8 09 ff ff ff       	call   f0106451 <lapicw>
	lapicw(ESR, 0);
f0106548:	ba 00 00 00 00       	mov    $0x0,%edx
f010654d:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106552:	e8 fa fe ff ff       	call   f0106451 <lapicw>
	lapicw(ESR, 0);
f0106557:	ba 00 00 00 00       	mov    $0x0,%edx
f010655c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106561:	e8 eb fe ff ff       	call   f0106451 <lapicw>
	lapicw(EOI, 0);
f0106566:	ba 00 00 00 00       	mov    $0x0,%edx
f010656b:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106570:	e8 dc fe ff ff       	call   f0106451 <lapicw>
	lapicw(ICRHI, 0);
f0106575:	ba 00 00 00 00       	mov    $0x0,%edx
f010657a:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010657f:	e8 cd fe ff ff       	call   f0106451 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106584:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106589:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010658e:	e8 be fe ff ff       	call   f0106451 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106593:	8b 15 04 b0 22 f0    	mov    0xf022b004,%edx
f0106599:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010659f:	f6 c4 10             	test   $0x10,%ah
f01065a2:	75 f5                	jne    f0106599 <lapic_init+0x115>
	lapicw(TPR, 0);
f01065a4:	ba 00 00 00 00       	mov    $0x0,%edx
f01065a9:	b8 20 00 00 00       	mov    $0x20,%eax
f01065ae:	e8 9e fe ff ff       	call   f0106451 <lapicw>
}
f01065b3:	c9                   	leave  
f01065b4:	f3 c3                	repz ret 

f01065b6 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f01065b6:	83 3d 04 b0 22 f0 00 	cmpl   $0x0,0xf022b004
f01065bd:	74 13                	je     f01065d2 <lapic_eoi+0x1c>
{
f01065bf:	55                   	push   %ebp
f01065c0:	89 e5                	mov    %esp,%ebp
		lapicw(EOI, 0);
f01065c2:	ba 00 00 00 00       	mov    $0x0,%edx
f01065c7:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01065cc:	e8 80 fe ff ff       	call   f0106451 <lapicw>
}
f01065d1:	5d                   	pop    %ebp
f01065d2:	f3 c3                	repz ret 

f01065d4 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01065d4:	55                   	push   %ebp
f01065d5:	89 e5                	mov    %esp,%ebp
f01065d7:	56                   	push   %esi
f01065d8:	53                   	push   %ebx
f01065d9:	83 ec 10             	sub    $0x10,%esp
f01065dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01065df:	8b 75 0c             	mov    0xc(%ebp),%esi
f01065e2:	ba 70 00 00 00       	mov    $0x70,%edx
f01065e7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01065ec:	ee                   	out    %al,(%dx)
f01065ed:	b2 71                	mov    $0x71,%dl
f01065ef:	b8 0a 00 00 00       	mov    $0xa,%eax
f01065f4:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f01065f5:	83 3d 88 9e 1e f0 00 	cmpl   $0x0,0xf01e9e88
f01065fc:	75 24                	jne    f0106622 <lapic_startap+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01065fe:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0106605:	00 
f0106606:	c7 44 24 08 64 6b 10 	movl   $0xf0106b64,0x8(%esp)
f010660d:	f0 
f010660e:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0106615:	00 
f0106616:	c7 04 24 74 87 10 f0 	movl   $0xf0108774,(%esp)
f010661d:	e8 1e 9a ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106622:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106629:	00 00 
	wrv[1] = addr >> 4;
f010662b:	89 f0                	mov    %esi,%eax
f010662d:	c1 e8 04             	shr    $0x4,%eax
f0106630:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106636:	c1 e3 18             	shl    $0x18,%ebx
f0106639:	89 da                	mov    %ebx,%edx
f010663b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106640:	e8 0c fe ff ff       	call   f0106451 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106645:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010664a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010664f:	e8 fd fd ff ff       	call   f0106451 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106654:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106659:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010665e:	e8 ee fd ff ff       	call   f0106451 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106663:	c1 ee 0c             	shr    $0xc,%esi
f0106666:	81 ce 00 06 00 00    	or     $0x600,%esi
		lapicw(ICRHI, apicid << 24);
f010666c:	89 da                	mov    %ebx,%edx
f010666e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106673:	e8 d9 fd ff ff       	call   f0106451 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106678:	89 f2                	mov    %esi,%edx
f010667a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010667f:	e8 cd fd ff ff       	call   f0106451 <lapicw>
		lapicw(ICRHI, apicid << 24);
f0106684:	89 da                	mov    %ebx,%edx
f0106686:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010668b:	e8 c1 fd ff ff       	call   f0106451 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106690:	89 f2                	mov    %esi,%edx
f0106692:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106697:	e8 b5 fd ff ff       	call   f0106451 <lapicw>
		microdelay(200);
	}
}
f010669c:	83 c4 10             	add    $0x10,%esp
f010669f:	5b                   	pop    %ebx
f01066a0:	5e                   	pop    %esi
f01066a1:	5d                   	pop    %ebp
f01066a2:	c3                   	ret    

f01066a3 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01066a3:	55                   	push   %ebp
f01066a4:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01066a6:	8b 55 08             	mov    0x8(%ebp),%edx
f01066a9:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01066af:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01066b4:	e8 98 fd ff ff       	call   f0106451 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01066b9:	8b 15 04 b0 22 f0    	mov    0xf022b004,%edx
f01066bf:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01066c5:	f6 c4 10             	test   $0x10,%ah
f01066c8:	75 f5                	jne    f01066bf <lapic_ipi+0x1c>
		;
}
f01066ca:	5d                   	pop    %ebp
f01066cb:	c3                   	ret    

f01066cc <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01066cc:	55                   	push   %ebp
f01066cd:	89 e5                	mov    %esp,%ebp
f01066cf:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01066d2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01066d8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01066db:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01066de:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01066e5:	5d                   	pop    %ebp
f01066e6:	c3                   	ret    

f01066e7 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01066e7:	55                   	push   %ebp
f01066e8:	89 e5                	mov    %esp,%ebp
f01066ea:	56                   	push   %esi
f01066eb:	53                   	push   %ebx
f01066ec:	83 ec 20             	sub    $0x20,%esp
f01066ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f01066f2:	83 3b 00             	cmpl   $0x0,(%ebx)
f01066f5:	75 07                	jne    f01066fe <spin_lock+0x17>
	asm volatile("lock; xchgl %0, %1"
f01066f7:	ba 01 00 00 00       	mov    $0x1,%edx
f01066fc:	eb 42                	jmp    f0106740 <spin_lock+0x59>
f01066fe:	8b 73 08             	mov    0x8(%ebx),%esi
f0106701:	e8 63 fd ff ff       	call   f0106469 <cpunum>
f0106706:	6b c0 74             	imul   $0x74,%eax,%eax
f0106709:	05 20 a0 1e f0       	add    $0xf01ea020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010670e:	39 c6                	cmp    %eax,%esi
f0106710:	75 e5                	jne    f01066f7 <spin_lock+0x10>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106712:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106715:	e8 4f fd ff ff       	call   f0106469 <cpunum>
f010671a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f010671e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106722:	c7 44 24 08 84 87 10 	movl   $0xf0108784,0x8(%esp)
f0106729:	f0 
f010672a:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106731:	00 
f0106732:	c7 04 24 e8 87 10 f0 	movl   $0xf01087e8,(%esp)
f0106739:	e8 02 99 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010673e:	f3 90                	pause  
f0106740:	89 d0                	mov    %edx,%eax
f0106742:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0106745:	85 c0                	test   %eax,%eax
f0106747:	75 f5                	jne    f010673e <spin_lock+0x57>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106749:	e8 1b fd ff ff       	call   f0106469 <cpunum>
f010674e:	6b c0 74             	imul   $0x74,%eax,%eax
f0106751:	05 20 a0 1e f0       	add    $0xf01ea020,%eax
f0106756:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106759:	83 c3 0c             	add    $0xc,%ebx
	ebp = (uint32_t *)read_ebp();
f010675c:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f010675e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106763:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106769:	76 12                	jbe    f010677d <spin_lock+0x96>
		pcs[i] = ebp[1];          // saved %eip
f010676b:	8b 4a 04             	mov    0x4(%edx),%ecx
f010676e:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106771:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0106773:	83 c0 01             	add    $0x1,%eax
f0106776:	83 f8 0a             	cmp    $0xa,%eax
f0106779:	75 e8                	jne    f0106763 <spin_lock+0x7c>
f010677b:	eb 0f                	jmp    f010678c <spin_lock+0xa5>
		pcs[i] = 0;
f010677d:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
	for (; i < 10; i++)
f0106784:	83 c0 01             	add    $0x1,%eax
f0106787:	83 f8 09             	cmp    $0x9,%eax
f010678a:	7e f1                	jle    f010677d <spin_lock+0x96>
#endif
}
f010678c:	83 c4 20             	add    $0x20,%esp
f010678f:	5b                   	pop    %ebx
f0106790:	5e                   	pop    %esi
f0106791:	5d                   	pop    %ebp
f0106792:	c3                   	ret    

f0106793 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106793:	55                   	push   %ebp
f0106794:	89 e5                	mov    %esp,%ebp
f0106796:	57                   	push   %edi
f0106797:	56                   	push   %esi
f0106798:	53                   	push   %ebx
f0106799:	83 ec 6c             	sub    $0x6c,%esp
f010679c:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f010679f:	83 3e 00             	cmpl   $0x0,(%esi)
f01067a2:	74 18                	je     f01067bc <spin_unlock+0x29>
f01067a4:	8b 5e 08             	mov    0x8(%esi),%ebx
f01067a7:	e8 bd fc ff ff       	call   f0106469 <cpunum>
f01067ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01067af:	05 20 a0 1e f0       	add    $0xf01ea020,%eax
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01067b4:	39 c3                	cmp    %eax,%ebx
f01067b6:	0f 84 ce 00 00 00    	je     f010688a <spin_unlock+0xf7>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01067bc:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f01067c3:	00 
f01067c4:	8d 46 0c             	lea    0xc(%esi),%eax
f01067c7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01067cb:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01067ce:	89 1c 24             	mov    %ebx,(%esp)
f01067d1:	e8 8e f6 ff ff       	call   f0105e64 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01067d6:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01067d9:	0f b6 38             	movzbl (%eax),%edi
f01067dc:	8b 76 04             	mov    0x4(%esi),%esi
f01067df:	e8 85 fc ff ff       	call   f0106469 <cpunum>
f01067e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01067e8:	89 74 24 08          	mov    %esi,0x8(%esp)
f01067ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01067f0:	c7 04 24 b0 87 10 f0 	movl   $0xf01087b0,(%esp)
f01067f7:	e8 ed d6 ff ff       	call   f0103ee9 <cprintf>
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01067fc:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01067ff:	eb 65                	jmp    f0106866 <spin_unlock+0xd3>
f0106801:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106805:	89 04 24             	mov    %eax,(%esp)
f0106808:	e8 ba ea ff ff       	call   f01052c7 <debuginfo_eip>
f010680d:	85 c0                	test   %eax,%eax
f010680f:	78 39                	js     f010684a <spin_unlock+0xb7>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106811:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106813:	89 c2                	mov    %eax,%edx
f0106815:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106818:	89 54 24 18          	mov    %edx,0x18(%esp)
f010681c:	8b 55 b0             	mov    -0x50(%ebp),%edx
f010681f:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106823:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0106826:	89 54 24 10          	mov    %edx,0x10(%esp)
f010682a:	8b 55 ac             	mov    -0x54(%ebp),%edx
f010682d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106831:	8b 55 a8             	mov    -0x58(%ebp),%edx
f0106834:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106838:	89 44 24 04          	mov    %eax,0x4(%esp)
f010683c:	c7 04 24 f8 87 10 f0 	movl   $0xf01087f8,(%esp)
f0106843:	e8 a1 d6 ff ff       	call   f0103ee9 <cprintf>
f0106848:	eb 12                	jmp    f010685c <spin_unlock+0xc9>
			else
				cprintf("  %08x\n", pcs[i]);
f010684a:	8b 06                	mov    (%esi),%eax
f010684c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106850:	c7 04 24 0f 88 10 f0 	movl   $0xf010880f,(%esp)
f0106857:	e8 8d d6 ff ff       	call   f0103ee9 <cprintf>
f010685c:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f010685f:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106862:	39 c3                	cmp    %eax,%ebx
f0106864:	74 08                	je     f010686e <spin_unlock+0xdb>
f0106866:	89 de                	mov    %ebx,%esi
f0106868:	8b 03                	mov    (%ebx),%eax
f010686a:	85 c0                	test   %eax,%eax
f010686c:	75 93                	jne    f0106801 <spin_unlock+0x6e>
		}
		panic("spin_unlock");
f010686e:	c7 44 24 08 17 88 10 	movl   $0xf0108817,0x8(%esp)
f0106875:	f0 
f0106876:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f010687d:	00 
f010687e:	c7 04 24 e8 87 10 f0 	movl   $0xf01087e8,(%esp)
f0106885:	e8 b6 97 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f010688a:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106891:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
f0106898:	b8 00 00 00 00       	mov    $0x0,%eax
f010689d:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f01068a0:	83 c4 6c             	add    $0x6c,%esp
f01068a3:	5b                   	pop    %ebx
f01068a4:	5e                   	pop    %esi
f01068a5:	5f                   	pop    %edi
f01068a6:	5d                   	pop    %ebp
f01068a7:	c3                   	ret    
f01068a8:	66 90                	xchg   %ax,%ax
f01068aa:	66 90                	xchg   %ax,%ax
f01068ac:	66 90                	xchg   %ax,%ax
f01068ae:	66 90                	xchg   %ax,%ax

f01068b0 <__udivdi3>:
f01068b0:	55                   	push   %ebp
f01068b1:	57                   	push   %edi
f01068b2:	56                   	push   %esi
f01068b3:	83 ec 0c             	sub    $0xc,%esp
f01068b6:	8b 44 24 28          	mov    0x28(%esp),%eax
f01068ba:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f01068be:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f01068c2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f01068c6:	85 c0                	test   %eax,%eax
f01068c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01068cc:	89 ea                	mov    %ebp,%edx
f01068ce:	89 0c 24             	mov    %ecx,(%esp)
f01068d1:	75 2d                	jne    f0106900 <__udivdi3+0x50>
f01068d3:	39 e9                	cmp    %ebp,%ecx
f01068d5:	77 61                	ja     f0106938 <__udivdi3+0x88>
f01068d7:	85 c9                	test   %ecx,%ecx
f01068d9:	89 ce                	mov    %ecx,%esi
f01068db:	75 0b                	jne    f01068e8 <__udivdi3+0x38>
f01068dd:	b8 01 00 00 00       	mov    $0x1,%eax
f01068e2:	31 d2                	xor    %edx,%edx
f01068e4:	f7 f1                	div    %ecx
f01068e6:	89 c6                	mov    %eax,%esi
f01068e8:	31 d2                	xor    %edx,%edx
f01068ea:	89 e8                	mov    %ebp,%eax
f01068ec:	f7 f6                	div    %esi
f01068ee:	89 c5                	mov    %eax,%ebp
f01068f0:	89 f8                	mov    %edi,%eax
f01068f2:	f7 f6                	div    %esi
f01068f4:	89 ea                	mov    %ebp,%edx
f01068f6:	83 c4 0c             	add    $0xc,%esp
f01068f9:	5e                   	pop    %esi
f01068fa:	5f                   	pop    %edi
f01068fb:	5d                   	pop    %ebp
f01068fc:	c3                   	ret    
f01068fd:	8d 76 00             	lea    0x0(%esi),%esi
f0106900:	39 e8                	cmp    %ebp,%eax
f0106902:	77 24                	ja     f0106928 <__udivdi3+0x78>
f0106904:	0f bd e8             	bsr    %eax,%ebp
f0106907:	83 f5 1f             	xor    $0x1f,%ebp
f010690a:	75 3c                	jne    f0106948 <__udivdi3+0x98>
f010690c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0106910:	39 34 24             	cmp    %esi,(%esp)
f0106913:	0f 86 9f 00 00 00    	jbe    f01069b8 <__udivdi3+0x108>
f0106919:	39 d0                	cmp    %edx,%eax
f010691b:	0f 82 97 00 00 00    	jb     f01069b8 <__udivdi3+0x108>
f0106921:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106928:	31 d2                	xor    %edx,%edx
f010692a:	31 c0                	xor    %eax,%eax
f010692c:	83 c4 0c             	add    $0xc,%esp
f010692f:	5e                   	pop    %esi
f0106930:	5f                   	pop    %edi
f0106931:	5d                   	pop    %ebp
f0106932:	c3                   	ret    
f0106933:	90                   	nop
f0106934:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106938:	89 f8                	mov    %edi,%eax
f010693a:	f7 f1                	div    %ecx
f010693c:	31 d2                	xor    %edx,%edx
f010693e:	83 c4 0c             	add    $0xc,%esp
f0106941:	5e                   	pop    %esi
f0106942:	5f                   	pop    %edi
f0106943:	5d                   	pop    %ebp
f0106944:	c3                   	ret    
f0106945:	8d 76 00             	lea    0x0(%esi),%esi
f0106948:	89 e9                	mov    %ebp,%ecx
f010694a:	8b 3c 24             	mov    (%esp),%edi
f010694d:	d3 e0                	shl    %cl,%eax
f010694f:	89 c6                	mov    %eax,%esi
f0106951:	b8 20 00 00 00       	mov    $0x20,%eax
f0106956:	29 e8                	sub    %ebp,%eax
f0106958:	89 c1                	mov    %eax,%ecx
f010695a:	d3 ef                	shr    %cl,%edi
f010695c:	89 e9                	mov    %ebp,%ecx
f010695e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106962:	8b 3c 24             	mov    (%esp),%edi
f0106965:	09 74 24 08          	or     %esi,0x8(%esp)
f0106969:	89 d6                	mov    %edx,%esi
f010696b:	d3 e7                	shl    %cl,%edi
f010696d:	89 c1                	mov    %eax,%ecx
f010696f:	89 3c 24             	mov    %edi,(%esp)
f0106972:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106976:	d3 ee                	shr    %cl,%esi
f0106978:	89 e9                	mov    %ebp,%ecx
f010697a:	d3 e2                	shl    %cl,%edx
f010697c:	89 c1                	mov    %eax,%ecx
f010697e:	d3 ef                	shr    %cl,%edi
f0106980:	09 d7                	or     %edx,%edi
f0106982:	89 f2                	mov    %esi,%edx
f0106984:	89 f8                	mov    %edi,%eax
f0106986:	f7 74 24 08          	divl   0x8(%esp)
f010698a:	89 d6                	mov    %edx,%esi
f010698c:	89 c7                	mov    %eax,%edi
f010698e:	f7 24 24             	mull   (%esp)
f0106991:	39 d6                	cmp    %edx,%esi
f0106993:	89 14 24             	mov    %edx,(%esp)
f0106996:	72 30                	jb     f01069c8 <__udivdi3+0x118>
f0106998:	8b 54 24 04          	mov    0x4(%esp),%edx
f010699c:	89 e9                	mov    %ebp,%ecx
f010699e:	d3 e2                	shl    %cl,%edx
f01069a0:	39 c2                	cmp    %eax,%edx
f01069a2:	73 05                	jae    f01069a9 <__udivdi3+0xf9>
f01069a4:	3b 34 24             	cmp    (%esp),%esi
f01069a7:	74 1f                	je     f01069c8 <__udivdi3+0x118>
f01069a9:	89 f8                	mov    %edi,%eax
f01069ab:	31 d2                	xor    %edx,%edx
f01069ad:	e9 7a ff ff ff       	jmp    f010692c <__udivdi3+0x7c>
f01069b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01069b8:	31 d2                	xor    %edx,%edx
f01069ba:	b8 01 00 00 00       	mov    $0x1,%eax
f01069bf:	e9 68 ff ff ff       	jmp    f010692c <__udivdi3+0x7c>
f01069c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01069c8:	8d 47 ff             	lea    -0x1(%edi),%eax
f01069cb:	31 d2                	xor    %edx,%edx
f01069cd:	83 c4 0c             	add    $0xc,%esp
f01069d0:	5e                   	pop    %esi
f01069d1:	5f                   	pop    %edi
f01069d2:	5d                   	pop    %ebp
f01069d3:	c3                   	ret    
f01069d4:	66 90                	xchg   %ax,%ax
f01069d6:	66 90                	xchg   %ax,%ax
f01069d8:	66 90                	xchg   %ax,%ax
f01069da:	66 90                	xchg   %ax,%ax
f01069dc:	66 90                	xchg   %ax,%ax
f01069de:	66 90                	xchg   %ax,%ax

f01069e0 <__umoddi3>:
f01069e0:	55                   	push   %ebp
f01069e1:	57                   	push   %edi
f01069e2:	56                   	push   %esi
f01069e3:	83 ec 14             	sub    $0x14,%esp
f01069e6:	8b 44 24 28          	mov    0x28(%esp),%eax
f01069ea:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f01069ee:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f01069f2:	89 c7                	mov    %eax,%edi
f01069f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069f8:	8b 44 24 30          	mov    0x30(%esp),%eax
f01069fc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0106a00:	89 34 24             	mov    %esi,(%esp)
f0106a03:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106a07:	85 c0                	test   %eax,%eax
f0106a09:	89 c2                	mov    %eax,%edx
f0106a0b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106a0f:	75 17                	jne    f0106a28 <__umoddi3+0x48>
f0106a11:	39 fe                	cmp    %edi,%esi
f0106a13:	76 4b                	jbe    f0106a60 <__umoddi3+0x80>
f0106a15:	89 c8                	mov    %ecx,%eax
f0106a17:	89 fa                	mov    %edi,%edx
f0106a19:	f7 f6                	div    %esi
f0106a1b:	89 d0                	mov    %edx,%eax
f0106a1d:	31 d2                	xor    %edx,%edx
f0106a1f:	83 c4 14             	add    $0x14,%esp
f0106a22:	5e                   	pop    %esi
f0106a23:	5f                   	pop    %edi
f0106a24:	5d                   	pop    %ebp
f0106a25:	c3                   	ret    
f0106a26:	66 90                	xchg   %ax,%ax
f0106a28:	39 f8                	cmp    %edi,%eax
f0106a2a:	77 54                	ja     f0106a80 <__umoddi3+0xa0>
f0106a2c:	0f bd e8             	bsr    %eax,%ebp
f0106a2f:	83 f5 1f             	xor    $0x1f,%ebp
f0106a32:	75 5c                	jne    f0106a90 <__umoddi3+0xb0>
f0106a34:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0106a38:	39 3c 24             	cmp    %edi,(%esp)
f0106a3b:	0f 87 e7 00 00 00    	ja     f0106b28 <__umoddi3+0x148>
f0106a41:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106a45:	29 f1                	sub    %esi,%ecx
f0106a47:	19 c7                	sbb    %eax,%edi
f0106a49:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106a4d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106a51:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106a55:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0106a59:	83 c4 14             	add    $0x14,%esp
f0106a5c:	5e                   	pop    %esi
f0106a5d:	5f                   	pop    %edi
f0106a5e:	5d                   	pop    %ebp
f0106a5f:	c3                   	ret    
f0106a60:	85 f6                	test   %esi,%esi
f0106a62:	89 f5                	mov    %esi,%ebp
f0106a64:	75 0b                	jne    f0106a71 <__umoddi3+0x91>
f0106a66:	b8 01 00 00 00       	mov    $0x1,%eax
f0106a6b:	31 d2                	xor    %edx,%edx
f0106a6d:	f7 f6                	div    %esi
f0106a6f:	89 c5                	mov    %eax,%ebp
f0106a71:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106a75:	31 d2                	xor    %edx,%edx
f0106a77:	f7 f5                	div    %ebp
f0106a79:	89 c8                	mov    %ecx,%eax
f0106a7b:	f7 f5                	div    %ebp
f0106a7d:	eb 9c                	jmp    f0106a1b <__umoddi3+0x3b>
f0106a7f:	90                   	nop
f0106a80:	89 c8                	mov    %ecx,%eax
f0106a82:	89 fa                	mov    %edi,%edx
f0106a84:	83 c4 14             	add    $0x14,%esp
f0106a87:	5e                   	pop    %esi
f0106a88:	5f                   	pop    %edi
f0106a89:	5d                   	pop    %ebp
f0106a8a:	c3                   	ret    
f0106a8b:	90                   	nop
f0106a8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106a90:	8b 04 24             	mov    (%esp),%eax
f0106a93:	be 20 00 00 00       	mov    $0x20,%esi
f0106a98:	89 e9                	mov    %ebp,%ecx
f0106a9a:	29 ee                	sub    %ebp,%esi
f0106a9c:	d3 e2                	shl    %cl,%edx
f0106a9e:	89 f1                	mov    %esi,%ecx
f0106aa0:	d3 e8                	shr    %cl,%eax
f0106aa2:	89 e9                	mov    %ebp,%ecx
f0106aa4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106aa8:	8b 04 24             	mov    (%esp),%eax
f0106aab:	09 54 24 04          	or     %edx,0x4(%esp)
f0106aaf:	89 fa                	mov    %edi,%edx
f0106ab1:	d3 e0                	shl    %cl,%eax
f0106ab3:	89 f1                	mov    %esi,%ecx
f0106ab5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106ab9:	8b 44 24 10          	mov    0x10(%esp),%eax
f0106abd:	d3 ea                	shr    %cl,%edx
f0106abf:	89 e9                	mov    %ebp,%ecx
f0106ac1:	d3 e7                	shl    %cl,%edi
f0106ac3:	89 f1                	mov    %esi,%ecx
f0106ac5:	d3 e8                	shr    %cl,%eax
f0106ac7:	89 e9                	mov    %ebp,%ecx
f0106ac9:	09 f8                	or     %edi,%eax
f0106acb:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0106acf:	f7 74 24 04          	divl   0x4(%esp)
f0106ad3:	d3 e7                	shl    %cl,%edi
f0106ad5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106ad9:	89 d7                	mov    %edx,%edi
f0106adb:	f7 64 24 08          	mull   0x8(%esp)
f0106adf:	39 d7                	cmp    %edx,%edi
f0106ae1:	89 c1                	mov    %eax,%ecx
f0106ae3:	89 14 24             	mov    %edx,(%esp)
f0106ae6:	72 2c                	jb     f0106b14 <__umoddi3+0x134>
f0106ae8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0106aec:	72 22                	jb     f0106b10 <__umoddi3+0x130>
f0106aee:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106af2:	29 c8                	sub    %ecx,%eax
f0106af4:	19 d7                	sbb    %edx,%edi
f0106af6:	89 e9                	mov    %ebp,%ecx
f0106af8:	89 fa                	mov    %edi,%edx
f0106afa:	d3 e8                	shr    %cl,%eax
f0106afc:	89 f1                	mov    %esi,%ecx
f0106afe:	d3 e2                	shl    %cl,%edx
f0106b00:	89 e9                	mov    %ebp,%ecx
f0106b02:	d3 ef                	shr    %cl,%edi
f0106b04:	09 d0                	or     %edx,%eax
f0106b06:	89 fa                	mov    %edi,%edx
f0106b08:	83 c4 14             	add    $0x14,%esp
f0106b0b:	5e                   	pop    %esi
f0106b0c:	5f                   	pop    %edi
f0106b0d:	5d                   	pop    %ebp
f0106b0e:	c3                   	ret    
f0106b0f:	90                   	nop
f0106b10:	39 d7                	cmp    %edx,%edi
f0106b12:	75 da                	jne    f0106aee <__umoddi3+0x10e>
f0106b14:	8b 14 24             	mov    (%esp),%edx
f0106b17:	89 c1                	mov    %eax,%ecx
f0106b19:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f0106b1d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0106b21:	eb cb                	jmp    f0106aee <__umoddi3+0x10e>
f0106b23:	90                   	nop
f0106b24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106b28:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f0106b2c:	0f 82 0f ff ff ff    	jb     f0106a41 <__umoddi3+0x61>
f0106b32:	e9 1a ff ff ff       	jmp    f0106a51 <__umoddi3+0x71>
