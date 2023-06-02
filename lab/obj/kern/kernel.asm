
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
f0100015:	b8 00 e0 18 00       	mov    $0x18e000,%eax
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
f0100034:	bc 00 b0 11 f0       	mov    $0xf011b000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 08             	sub    $0x8,%esp
f0100047:	e8 1b 01 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f010004c:	81 c3 d4 cf 08 00    	add    $0x8cfd4,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c0 10 00 19 f0    	mov    $0xf0190010,%eax
f0100058:	c7 c2 00 f1 18 f0    	mov    $0xf018f100,%edx
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 89 50 00 00       	call   f01050f2 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 4e 05 00 00       	call   f01005bc <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 20 85 f7 ff    	lea    -0x87ae0(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 19 3a 00 00       	call   f0103a9b <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100082:	e8 27 13 00 00       	call   f01013ae <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100087:	e8 6a 33 00 00       	call   f01033f6 <env_init>
	trap_init();
f010008c:	e8 bd 3a 00 00       	call   f0103b4e <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100091:	83 c4 08             	add    $0x8,%esp
f0100094:	6a 00                	push   $0x0
f0100096:	ff b3 f4 ff ff ff    	pushl  -0xc(%ebx)
f010009c:	e8 32 35 00 00       	call   f01035d3 <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a1:	83 c4 04             	add    $0x4,%esp
f01000a4:	c7 c0 4c f3 18 f0    	mov    $0xf018f34c,%eax
f01000aa:	ff 30                	pushl  (%eax)
f01000ac:	e8 f6 38 00 00       	call   f01039a7 <env_run>

f01000b1 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000b1:	55                   	push   %ebp
f01000b2:	89 e5                	mov    %esp,%ebp
f01000b4:	57                   	push   %edi
f01000b5:	56                   	push   %esi
f01000b6:	53                   	push   %ebx
f01000b7:	83 ec 0c             	sub    $0xc,%esp
f01000ba:	e8 a8 00 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f01000bf:	81 c3 61 cf 08 00    	add    $0x8cf61,%ebx
f01000c5:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f01000c8:	c7 c0 00 00 19 f0    	mov    $0xf0190000,%eax
f01000ce:	83 38 00             	cmpl   $0x0,(%eax)
f01000d1:	74 0f                	je     f01000e2 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 36 08 00 00       	call   f0100913 <monitor>
f01000dd:	83 c4 10             	add    $0x10,%esp
f01000e0:	eb f1                	jmp    f01000d3 <_panic+0x22>
	panicstr = fmt;
f01000e2:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f01000e4:	fa                   	cli    
f01000e5:	fc                   	cld    
	va_start(ap, fmt);
f01000e6:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f01000e9:	83 ec 04             	sub    $0x4,%esp
f01000ec:	ff 75 0c             	pushl  0xc(%ebp)
f01000ef:	ff 75 08             	pushl  0x8(%ebp)
f01000f2:	8d 83 3b 85 f7 ff    	lea    -0x87ac5(%ebx),%eax
f01000f8:	50                   	push   %eax
f01000f9:	e8 9d 39 00 00       	call   f0103a9b <cprintf>
	vcprintf(fmt, ap);
f01000fe:	83 c4 08             	add    $0x8,%esp
f0100101:	56                   	push   %esi
f0100102:	57                   	push   %edi
f0100103:	e8 5c 39 00 00       	call   f0103a64 <vcprintf>
	cprintf("\n");
f0100108:	8d 83 c7 94 f7 ff    	lea    -0x86b39(%ebx),%eax
f010010e:	89 04 24             	mov    %eax,(%esp)
f0100111:	e8 85 39 00 00       	call   f0103a9b <cprintf>
f0100116:	83 c4 10             	add    $0x10,%esp
f0100119:	eb b8                	jmp    f01000d3 <_panic+0x22>

f010011b <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010011b:	55                   	push   %ebp
f010011c:	89 e5                	mov    %esp,%ebp
f010011e:	56                   	push   %esi
f010011f:	53                   	push   %ebx
f0100120:	e8 42 00 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100125:	81 c3 fb ce 08 00    	add    $0x8cefb,%ebx
	va_list ap;

	va_start(ap, fmt);
f010012b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f010012e:	83 ec 04             	sub    $0x4,%esp
f0100131:	ff 75 0c             	pushl  0xc(%ebp)
f0100134:	ff 75 08             	pushl  0x8(%ebp)
f0100137:	8d 83 53 85 f7 ff    	lea    -0x87aad(%ebx),%eax
f010013d:	50                   	push   %eax
f010013e:	e8 58 39 00 00       	call   f0103a9b <cprintf>
	vcprintf(fmt, ap);
f0100143:	83 c4 08             	add    $0x8,%esp
f0100146:	56                   	push   %esi
f0100147:	ff 75 10             	pushl  0x10(%ebp)
f010014a:	e8 15 39 00 00       	call   f0103a64 <vcprintf>
	cprintf("\n");
f010014f:	8d 83 c7 94 f7 ff    	lea    -0x86b39(%ebx),%eax
f0100155:	89 04 24             	mov    %eax,(%esp)
f0100158:	e8 3e 39 00 00       	call   f0103a9b <cprintf>
	va_end(ap);
}
f010015d:	83 c4 10             	add    $0x10,%esp
f0100160:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100163:	5b                   	pop    %ebx
f0100164:	5e                   	pop    %esi
f0100165:	5d                   	pop    %ebp
f0100166:	c3                   	ret    

f0100167 <__x86.get_pc_thunk.bx>:
f0100167:	8b 1c 24             	mov    (%esp),%ebx
f010016a:	c3                   	ret    

f010016b <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010016b:	55                   	push   %ebp
f010016c:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010016e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100173:	ec                   	in     (%dx),%al
	if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA))
f0100174:	a8 01                	test   $0x1,%al
f0100176:	74 0b                	je     f0100183 <serial_proc_data+0x18>
f0100178:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010017d:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1 + COM_RX);
f010017e:	0f b6 c0             	movzbl %al,%eax
}
f0100181:	5d                   	pop    %ebp
f0100182:	c3                   	ret    
		return -1;
f0100183:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100188:	eb f7                	jmp    f0100181 <serial_proc_data+0x16>

f010018a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010018a:	55                   	push   %ebp
f010018b:	89 e5                	mov    %esp,%ebp
f010018d:	56                   	push   %esi
f010018e:	53                   	push   %ebx
f010018f:	e8 d3 ff ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100194:	81 c3 8c ce 08 00    	add    $0x8ce8c,%ebx
f010019a:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1)
f010019c:	ff d6                	call   *%esi
f010019e:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001a1:	74 2e                	je     f01001d1 <cons_intr+0x47>
	{
		if (c == 0)
f01001a3:	85 c0                	test   %eax,%eax
f01001a5:	74 f5                	je     f010019c <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a7:	8b 8b 04 23 00 00    	mov    0x2304(%ebx),%ecx
f01001ad:	8d 51 01             	lea    0x1(%ecx),%edx
f01001b0:	89 93 04 23 00 00    	mov    %edx,0x2304(%ebx)
f01001b6:	88 84 0b 00 21 00 00 	mov    %al,0x2100(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01001bd:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c3:	75 d7                	jne    f010019c <cons_intr+0x12>
			cons.wpos = 0;
f01001c5:	c7 83 04 23 00 00 00 	movl   $0x0,0x2304(%ebx)
f01001cc:	00 00 00 
f01001cf:	eb cb                	jmp    f010019c <cons_intr+0x12>
	}
}
f01001d1:	5b                   	pop    %ebx
f01001d2:	5e                   	pop    %esi
f01001d3:	5d                   	pop    %ebp
f01001d4:	c3                   	ret    

f01001d5 <kbd_proc_data>:
{
f01001d5:	55                   	push   %ebp
f01001d6:	89 e5                	mov    %esp,%ebp
f01001d8:	56                   	push   %esi
f01001d9:	53                   	push   %ebx
f01001da:	e8 88 ff ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01001df:	81 c3 41 ce 08 00    	add    $0x8ce41,%ebx
f01001e5:	ba 64 00 00 00       	mov    $0x64,%edx
f01001ea:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01001eb:	a8 01                	test   $0x1,%al
f01001ed:	0f 84 06 01 00 00    	je     f01002f9 <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f01001f3:	a8 20                	test   $0x20,%al
f01001f5:	0f 85 05 01 00 00    	jne    f0100300 <kbd_proc_data+0x12b>
f01001fb:	ba 60 00 00 00       	mov    $0x60,%edx
f0100200:	ec                   	in     (%dx),%al
f0100201:	89 c2                	mov    %eax,%edx
	if (data == 0xE0)
f0100203:	3c e0                	cmp    $0xe0,%al
f0100205:	0f 84 93 00 00 00    	je     f010029e <kbd_proc_data+0xc9>
	else if (data & 0x80)
f010020b:	84 c0                	test   %al,%al
f010020d:	0f 88 a0 00 00 00    	js     f01002b3 <kbd_proc_data+0xde>
	else if (shift & E0ESC)
f0100213:	8b 8b e0 20 00 00    	mov    0x20e0(%ebx),%ecx
f0100219:	f6 c1 40             	test   $0x40,%cl
f010021c:	74 0e                	je     f010022c <kbd_proc_data+0x57>
		data |= 0x80;
f010021e:	83 c8 80             	or     $0xffffff80,%eax
f0100221:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100223:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100226:	89 8b e0 20 00 00    	mov    %ecx,0x20e0(%ebx)
	shift |= shiftcode[data];
f010022c:	0f b6 d2             	movzbl %dl,%edx
f010022f:	0f b6 84 13 a0 86 f7 	movzbl -0x87960(%ebx,%edx,1),%eax
f0100236:	ff 
f0100237:	0b 83 e0 20 00 00    	or     0x20e0(%ebx),%eax
	shift ^= togglecode[data];
f010023d:	0f b6 8c 13 a0 85 f7 	movzbl -0x87a60(%ebx,%edx,1),%ecx
f0100244:	ff 
f0100245:	31 c8                	xor    %ecx,%eax
f0100247:	89 83 e0 20 00 00    	mov    %eax,0x20e0(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f010024d:	89 c1                	mov    %eax,%ecx
f010024f:	83 e1 03             	and    $0x3,%ecx
f0100252:	8b 8c 8b 00 20 00 00 	mov    0x2000(%ebx,%ecx,4),%ecx
f0100259:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010025d:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK)
f0100260:	a8 08                	test   $0x8,%al
f0100262:	74 0d                	je     f0100271 <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f0100264:	89 f2                	mov    %esi,%edx
f0100266:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f0100269:	83 f9 19             	cmp    $0x19,%ecx
f010026c:	77 7a                	ja     f01002e8 <kbd_proc_data+0x113>
			c += 'A' - 'a';
f010026e:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL)
f0100271:	f7 d0                	not    %eax
f0100273:	a8 06                	test   $0x6,%al
f0100275:	75 33                	jne    f01002aa <kbd_proc_data+0xd5>
f0100277:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f010027d:	75 2b                	jne    f01002aa <kbd_proc_data+0xd5>
		cprintf("Rebooting!\n");
f010027f:	83 ec 0c             	sub    $0xc,%esp
f0100282:	8d 83 6d 85 f7 ff    	lea    -0x87a93(%ebx),%eax
f0100288:	50                   	push   %eax
f0100289:	e8 0d 38 00 00       	call   f0103a9b <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010028e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100293:	ba 92 00 00 00       	mov    $0x92,%edx
f0100298:	ee                   	out    %al,(%dx)
f0100299:	83 c4 10             	add    $0x10,%esp
f010029c:	eb 0c                	jmp    f01002aa <kbd_proc_data+0xd5>
		shift |= E0ESC;
f010029e:	83 8b e0 20 00 00 40 	orl    $0x40,0x20e0(%ebx)
		return 0;
f01002a5:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002aa:	89 f0                	mov    %esi,%eax
f01002ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002af:	5b                   	pop    %ebx
f01002b0:	5e                   	pop    %esi
f01002b1:	5d                   	pop    %ebp
f01002b2:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002b3:	8b 8b e0 20 00 00    	mov    0x20e0(%ebx),%ecx
f01002b9:	89 ce                	mov    %ecx,%esi
f01002bb:	83 e6 40             	and    $0x40,%esi
f01002be:	83 e0 7f             	and    $0x7f,%eax
f01002c1:	85 f6                	test   %esi,%esi
f01002c3:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002c6:	0f b6 d2             	movzbl %dl,%edx
f01002c9:	0f b6 84 13 a0 86 f7 	movzbl -0x87960(%ebx,%edx,1),%eax
f01002d0:	ff 
f01002d1:	83 c8 40             	or     $0x40,%eax
f01002d4:	0f b6 c0             	movzbl %al,%eax
f01002d7:	f7 d0                	not    %eax
f01002d9:	21 c8                	and    %ecx,%eax
f01002db:	89 83 e0 20 00 00    	mov    %eax,0x20e0(%ebx)
		return 0;
f01002e1:	be 00 00 00 00       	mov    $0x0,%esi
f01002e6:	eb c2                	jmp    f01002aa <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f01002e8:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002eb:	8d 4e 20             	lea    0x20(%esi),%ecx
f01002ee:	83 fa 1a             	cmp    $0x1a,%edx
f01002f1:	0f 42 f1             	cmovb  %ecx,%esi
f01002f4:	e9 78 ff ff ff       	jmp    f0100271 <kbd_proc_data+0x9c>
		return -1;
f01002f9:	be ff ff ff ff       	mov    $0xffffffff,%esi
f01002fe:	eb aa                	jmp    f01002aa <kbd_proc_data+0xd5>
		return -1;
f0100300:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100305:	eb a3                	jmp    f01002aa <kbd_proc_data+0xd5>

f0100307 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100307:	55                   	push   %ebp
f0100308:	89 e5                	mov    %esp,%ebp
f010030a:	57                   	push   %edi
f010030b:	56                   	push   %esi
f010030c:	53                   	push   %ebx
f010030d:	83 ec 1c             	sub    $0x1c,%esp
f0100310:	e8 52 fe ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100315:	81 c3 0b cd 08 00    	add    $0x8cd0b,%ebx
f010031b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f010031e:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100323:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100328:	b9 84 00 00 00       	mov    $0x84,%ecx
f010032d:	eb 09                	jmp    f0100338 <cons_putc+0x31>
f010032f:	89 ca                	mov    %ecx,%edx
f0100331:	ec                   	in     (%dx),%al
f0100332:	ec                   	in     (%dx),%al
f0100333:	ec                   	in     (%dx),%al
f0100334:	ec                   	in     (%dx),%al
		 i++)
f0100335:	83 c6 01             	add    $0x1,%esi
f0100338:	89 fa                	mov    %edi,%edx
f010033a:	ec                   	in     (%dx),%al
		 !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010033b:	a8 20                	test   $0x20,%al
f010033d:	75 08                	jne    f0100347 <cons_putc+0x40>
f010033f:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100345:	7e e8                	jle    f010032f <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f0100347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010034a:	89 f8                	mov    %edi,%eax
f010034c:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010034f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100354:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378 + 1) & 0x80) && i < 12800; i++)
f0100355:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010035a:	bf 79 03 00 00       	mov    $0x379,%edi
f010035f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100364:	eb 09                	jmp    f010036f <cons_putc+0x68>
f0100366:	89 ca                	mov    %ecx,%edx
f0100368:	ec                   	in     (%dx),%al
f0100369:	ec                   	in     (%dx),%al
f010036a:	ec                   	in     (%dx),%al
f010036b:	ec                   	in     (%dx),%al
f010036c:	83 c6 01             	add    $0x1,%esi
f010036f:	89 fa                	mov    %edi,%edx
f0100371:	ec                   	in     (%dx),%al
f0100372:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100378:	7f 04                	jg     f010037e <cons_putc+0x77>
f010037a:	84 c0                	test   %al,%al
f010037c:	79 e8                	jns    f0100366 <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010037e:	ba 78 03 00 00       	mov    $0x378,%edx
f0100383:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f0100387:	ee                   	out    %al,(%dx)
f0100388:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010038d:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100392:	ee                   	out    %al,(%dx)
f0100393:	b8 08 00 00 00       	mov    $0x8,%eax
f0100398:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f0100399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010039c:	89 fa                	mov    %edi,%edx
f010039e:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003a4:	89 f8                	mov    %edi,%eax
f01003a6:	80 cc 07             	or     $0x7,%ah
f01003a9:	85 d2                	test   %edx,%edx
f01003ab:	0f 45 c7             	cmovne %edi,%eax
f01003ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff)
f01003b1:	0f b6 c0             	movzbl %al,%eax
f01003b4:	83 f8 09             	cmp    $0x9,%eax
f01003b7:	0f 84 b9 00 00 00    	je     f0100476 <cons_putc+0x16f>
f01003bd:	83 f8 09             	cmp    $0x9,%eax
f01003c0:	7e 74                	jle    f0100436 <cons_putc+0x12f>
f01003c2:	83 f8 0a             	cmp    $0xa,%eax
f01003c5:	0f 84 9e 00 00 00    	je     f0100469 <cons_putc+0x162>
f01003cb:	83 f8 0d             	cmp    $0xd,%eax
f01003ce:	0f 85 d9 00 00 00    	jne    f01004ad <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f01003d4:	0f b7 83 08 23 00 00 	movzwl 0x2308(%ebx),%eax
f01003db:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003e1:	c1 e8 16             	shr    $0x16,%eax
f01003e4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003e7:	c1 e0 04             	shl    $0x4,%eax
f01003ea:	66 89 83 08 23 00 00 	mov    %ax,0x2308(%ebx)
	if (crt_pos >= CRT_SIZE) // 当输出字符超过终端范围
f01003f1:	66 81 bb 08 23 00 00 	cmpw   $0x7cf,0x2308(%ebx)
f01003f8:	cf 07 
f01003fa:	0f 87 d4 00 00 00    	ja     f01004d4 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100400:	8b 8b 10 23 00 00    	mov    0x2310(%ebx),%ecx
f0100406:	b8 0e 00 00 00       	mov    $0xe,%eax
f010040b:	89 ca                	mov    %ecx,%edx
f010040d:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010040e:	0f b7 9b 08 23 00 00 	movzwl 0x2308(%ebx),%ebx
f0100415:	8d 71 01             	lea    0x1(%ecx),%esi
f0100418:	89 d8                	mov    %ebx,%eax
f010041a:	66 c1 e8 08          	shr    $0x8,%ax
f010041e:	89 f2                	mov    %esi,%edx
f0100420:	ee                   	out    %al,(%dx)
f0100421:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100426:	89 ca                	mov    %ecx,%edx
f0100428:	ee                   	out    %al,(%dx)
f0100429:	89 d8                	mov    %ebx,%eax
f010042b:	89 f2                	mov    %esi,%edx
f010042d:	ee                   	out    %al,(%dx)
	serial_putc(c); // 向串口输出
	lpt_putc(c);
	cga_putc(c); // 向控制台输出字符
}
f010042e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100431:	5b                   	pop    %ebx
f0100432:	5e                   	pop    %esi
f0100433:	5f                   	pop    %edi
f0100434:	5d                   	pop    %ebp
f0100435:	c3                   	ret    
	switch (c & 0xff)
f0100436:	83 f8 08             	cmp    $0x8,%eax
f0100439:	75 72                	jne    f01004ad <cons_putc+0x1a6>
		if (crt_pos > 0)
f010043b:	0f b7 83 08 23 00 00 	movzwl 0x2308(%ebx),%eax
f0100442:	66 85 c0             	test   %ax,%ax
f0100445:	74 b9                	je     f0100400 <cons_putc+0xf9>
			crt_pos--;
f0100447:	83 e8 01             	sub    $0x1,%eax
f010044a:	66 89 83 08 23 00 00 	mov    %ax,0x2308(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100451:	0f b7 c0             	movzwl %ax,%eax
f0100454:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f0100458:	b2 00                	mov    $0x0,%dl
f010045a:	83 ca 20             	or     $0x20,%edx
f010045d:	8b 8b 0c 23 00 00    	mov    0x230c(%ebx),%ecx
f0100463:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100467:	eb 88                	jmp    f01003f1 <cons_putc+0xea>
		crt_pos += CRT_COLS;
f0100469:	66 83 83 08 23 00 00 	addw   $0x50,0x2308(%ebx)
f0100470:	50 
f0100471:	e9 5e ff ff ff       	jmp    f01003d4 <cons_putc+0xcd>
		cons_putc(' ');
f0100476:	b8 20 00 00 00       	mov    $0x20,%eax
f010047b:	e8 87 fe ff ff       	call   f0100307 <cons_putc>
		cons_putc(' ');
f0100480:	b8 20 00 00 00       	mov    $0x20,%eax
f0100485:	e8 7d fe ff ff       	call   f0100307 <cons_putc>
		cons_putc(' ');
f010048a:	b8 20 00 00 00       	mov    $0x20,%eax
f010048f:	e8 73 fe ff ff       	call   f0100307 <cons_putc>
		cons_putc(' ');
f0100494:	b8 20 00 00 00       	mov    $0x20,%eax
f0100499:	e8 69 fe ff ff       	call   f0100307 <cons_putc>
		cons_putc(' ');
f010049e:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a3:	e8 5f fe ff ff       	call   f0100307 <cons_putc>
f01004a8:	e9 44 ff ff ff       	jmp    f01003f1 <cons_putc+0xea>
		crt_buf[crt_pos++] = c; /* write the character */
f01004ad:	0f b7 83 08 23 00 00 	movzwl 0x2308(%ebx),%eax
f01004b4:	8d 50 01             	lea    0x1(%eax),%edx
f01004b7:	66 89 93 08 23 00 00 	mov    %dx,0x2308(%ebx)
f01004be:	0f b7 c0             	movzwl %ax,%eax
f01004c1:	8b 93 0c 23 00 00    	mov    0x230c(%ebx),%edx
f01004c7:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f01004cb:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004cf:	e9 1d ff ff ff       	jmp    f01003f1 <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t)); // 已有字符往上移动一行
f01004d4:	8b 83 0c 23 00 00    	mov    0x230c(%ebx),%eax
f01004da:	83 ec 04             	sub    $0x4,%esp
f01004dd:	68 00 0f 00 00       	push   $0xf00
f01004e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004e8:	52                   	push   %edx
f01004e9:	50                   	push   %eax
f01004ea:	e8 50 4c 00 00       	call   f010513f <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004ef:	8b 93 0c 23 00 00    	mov    0x230c(%ebx),%edx
f01004f5:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004fb:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100501:	83 c4 10             	add    $0x10,%esp
f0100504:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100509:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)								// 清零最后一行
f010050c:	39 d0                	cmp    %edx,%eax
f010050e:	75 f4                	jne    f0100504 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS; // 索引向前移动，即从最后一行的开头写入
f0100510:	66 83 ab 08 23 00 00 	subw   $0x50,0x2308(%ebx)
f0100517:	50 
f0100518:	e9 e3 fe ff ff       	jmp    f0100400 <cons_putc+0xf9>

f010051d <serial_intr>:
{
f010051d:	e8 e7 01 00 00       	call   f0100709 <__x86.get_pc_thunk.ax>
f0100522:	05 fe ca 08 00       	add    $0x8cafe,%eax
	if (serial_exists)
f0100527:	80 b8 14 23 00 00 00 	cmpb   $0x0,0x2314(%eax)
f010052e:	75 02                	jne    f0100532 <serial_intr+0x15>
f0100530:	f3 c3                	repz ret 
{
f0100532:	55                   	push   %ebp
f0100533:	89 e5                	mov    %esp,%ebp
f0100535:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100538:	8d 80 4b 31 f7 ff    	lea    -0x8ceb5(%eax),%eax
f010053e:	e8 47 fc ff ff       	call   f010018a <cons_intr>
}
f0100543:	c9                   	leave  
f0100544:	c3                   	ret    

f0100545 <kbd_intr>:
{
f0100545:	55                   	push   %ebp
f0100546:	89 e5                	mov    %esp,%ebp
f0100548:	83 ec 08             	sub    $0x8,%esp
f010054b:	e8 b9 01 00 00       	call   f0100709 <__x86.get_pc_thunk.ax>
f0100550:	05 d0 ca 08 00       	add    $0x8cad0,%eax
	cons_intr(kbd_proc_data);
f0100555:	8d 80 b5 31 f7 ff    	lea    -0x8ce4b(%eax),%eax
f010055b:	e8 2a fc ff ff       	call   f010018a <cons_intr>
}
f0100560:	c9                   	leave  
f0100561:	c3                   	ret    

f0100562 <cons_getc>:
{
f0100562:	55                   	push   %ebp
f0100563:	89 e5                	mov    %esp,%ebp
f0100565:	53                   	push   %ebx
f0100566:	83 ec 04             	sub    $0x4,%esp
f0100569:	e8 f9 fb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010056e:	81 c3 b2 ca 08 00    	add    $0x8cab2,%ebx
	serial_intr();
f0100574:	e8 a4 ff ff ff       	call   f010051d <serial_intr>
	kbd_intr();
f0100579:	e8 c7 ff ff ff       	call   f0100545 <kbd_intr>
	if (cons.rpos != cons.wpos)
f010057e:	8b 93 00 23 00 00    	mov    0x2300(%ebx),%edx
	return 0;
f0100584:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos)
f0100589:	3b 93 04 23 00 00    	cmp    0x2304(%ebx),%edx
f010058f:	74 19                	je     f01005aa <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f0100591:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100594:	89 8b 00 23 00 00    	mov    %ecx,0x2300(%ebx)
f010059a:	0f b6 84 13 00 21 00 	movzbl 0x2100(%ebx,%edx,1),%eax
f01005a1:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005a2:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01005a8:	74 06                	je     f01005b0 <cons_getc+0x4e>
}
f01005aa:	83 c4 04             	add    $0x4,%esp
f01005ad:	5b                   	pop    %ebx
f01005ae:	5d                   	pop    %ebp
f01005af:	c3                   	ret    
			cons.rpos = 0;
f01005b0:	c7 83 00 23 00 00 00 	movl   $0x0,0x2300(%ebx)
f01005b7:	00 00 00 
f01005ba:	eb ee                	jmp    f01005aa <cons_getc+0x48>

f01005bc <cons_init>:

// initialize the console devices
void cons_init(void)
{
f01005bc:	55                   	push   %ebp
f01005bd:	89 e5                	mov    %esp,%ebp
f01005bf:	57                   	push   %edi
f01005c0:	56                   	push   %esi
f01005c1:	53                   	push   %ebx
f01005c2:	83 ec 1c             	sub    $0x1c,%esp
f01005c5:	e8 9d fb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01005ca:	81 c3 56 ca 08 00    	add    $0x8ca56,%ebx
	was = *cp;
f01005d0:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t)0xA55A;
f01005d7:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005de:	5a a5 
	if (*cp != 0xA55A)
f01005e0:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01005e7:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005eb:	0f 84 bc 00 00 00    	je     f01006ad <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f01005f1:	c7 83 10 23 00 00 b4 	movl   $0x3b4,0x2310(%ebx)
f01005f8:	03 00 00 
		cp = (uint16_t *)(KERNBASE + MONO_BUF);
f01005fb:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100602:	8b bb 10 23 00 00    	mov    0x2310(%ebx),%edi
f0100608:	b8 0e 00 00 00       	mov    $0xe,%eax
f010060d:	89 fa                	mov    %edi,%edx
f010060f:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100610:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100613:	89 ca                	mov    %ecx,%edx
f0100615:	ec                   	in     (%dx),%al
f0100616:	0f b6 f0             	movzbl %al,%esi
f0100619:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010061c:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100621:	89 fa                	mov    %edi,%edx
f0100623:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100624:	89 ca                	mov    %ecx,%edx
f0100626:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t *)cp;
f0100627:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010062a:	89 bb 0c 23 00 00    	mov    %edi,0x230c(%ebx)
	pos |= inb(addr_6845 + 1);
f0100630:	0f b6 c0             	movzbl %al,%eax
f0100633:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f0100635:	66 89 b3 08 23 00 00 	mov    %si,0x2308(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010063c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100641:	89 c8                	mov    %ecx,%eax
f0100643:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100648:	ee                   	out    %al,(%dx)
f0100649:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010064e:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100653:	89 fa                	mov    %edi,%edx
f0100655:	ee                   	out    %al,(%dx)
f0100656:	b8 0c 00 00 00       	mov    $0xc,%eax
f010065b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100660:	ee                   	out    %al,(%dx)
f0100661:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100666:	89 c8                	mov    %ecx,%eax
f0100668:	89 f2                	mov    %esi,%edx
f010066a:	ee                   	out    %al,(%dx)
f010066b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100670:	89 fa                	mov    %edi,%edx
f0100672:	ee                   	out    %al,(%dx)
f0100673:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100678:	89 c8                	mov    %ecx,%eax
f010067a:	ee                   	out    %al,(%dx)
f010067b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100680:	89 f2                	mov    %esi,%edx
f0100682:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100683:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100688:	ec                   	in     (%dx),%al
f0100689:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
f010068b:	3c ff                	cmp    $0xff,%al
f010068d:	0f 95 83 14 23 00 00 	setne  0x2314(%ebx)
f0100694:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100699:	ec                   	in     (%dx),%al
f010069a:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010069f:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006a0:	80 f9 ff             	cmp    $0xff,%cl
f01006a3:	74 25                	je     f01006ca <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006a8:	5b                   	pop    %ebx
f01006a9:	5e                   	pop    %esi
f01006aa:	5f                   	pop    %edi
f01006ab:	5d                   	pop    %ebp
f01006ac:	c3                   	ret    
		*cp = was;
f01006ad:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006b4:	c7 83 10 23 00 00 d4 	movl   $0x3d4,0x2310(%ebx)
f01006bb:	03 00 00 
	cp = (uint16_t *)(KERNBASE + CGA_BUF);
f01006be:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f01006c5:	e9 38 ff ff ff       	jmp    f0100602 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f01006ca:	83 ec 0c             	sub    $0xc,%esp
f01006cd:	8d 83 79 85 f7 ff    	lea    -0x87a87(%ebx),%eax
f01006d3:	50                   	push   %eax
f01006d4:	e8 c2 33 00 00       	call   f0103a9b <cprintf>
f01006d9:	83 c4 10             	add    $0x10,%esp
}
f01006dc:	eb c7                	jmp    f01006a5 <cons_init+0xe9>

f01006de <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void cputchar(int c)
{
f01006de:	55                   	push   %ebp
f01006df:	89 e5                	mov    %esp,%ebp
f01006e1:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01006e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01006e7:	e8 1b fc ff ff       	call   f0100307 <cons_putc>
}
f01006ec:	c9                   	leave  
f01006ed:	c3                   	ret    

f01006ee <getchar>:

int getchar(void)
{
f01006ee:	55                   	push   %ebp
f01006ef:	89 e5                	mov    %esp,%ebp
f01006f1:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006f4:	e8 69 fe ff ff       	call   f0100562 <cons_getc>
f01006f9:	85 c0                	test   %eax,%eax
f01006fb:	74 f7                	je     f01006f4 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006fd:	c9                   	leave  
f01006fe:	c3                   	ret    

f01006ff <iscons>:

int iscons(int fdnum)
{
f01006ff:	55                   	push   %ebp
f0100700:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100702:	b8 01 00 00 00       	mov    $0x1,%eax
f0100707:	5d                   	pop    %ebp
f0100708:	c3                   	ret    

f0100709 <__x86.get_pc_thunk.ax>:
f0100709:	8b 04 24             	mov    (%esp),%eax
f010070c:	c3                   	ret    

f010070d <mon_help>:
};

/***** Implementations of basic kernel monitor commands *****/

int mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010070d:	55                   	push   %ebp
f010070e:	89 e5                	mov    %esp,%ebp
f0100710:	56                   	push   %esi
f0100711:	53                   	push   %ebx
f0100712:	e8 50 fa ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100717:	81 c3 09 c9 08 00    	add    $0x8c909,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010071d:	83 ec 04             	sub    $0x4,%esp
f0100720:	8d 83 a0 87 f7 ff    	lea    -0x87860(%ebx),%eax
f0100726:	50                   	push   %eax
f0100727:	8d 83 be 87 f7 ff    	lea    -0x87842(%ebx),%eax
f010072d:	50                   	push   %eax
f010072e:	8d b3 c3 87 f7 ff    	lea    -0x8783d(%ebx),%esi
f0100734:	56                   	push   %esi
f0100735:	e8 61 33 00 00       	call   f0103a9b <cprintf>
f010073a:	83 c4 0c             	add    $0xc,%esp
f010073d:	8d 83 68 88 f7 ff    	lea    -0x87798(%ebx),%eax
f0100743:	50                   	push   %eax
f0100744:	8d 83 cc 87 f7 ff    	lea    -0x87834(%ebx),%eax
f010074a:	50                   	push   %eax
f010074b:	56                   	push   %esi
f010074c:	e8 4a 33 00 00       	call   f0103a9b <cprintf>
f0100751:	83 c4 0c             	add    $0xc,%esp
f0100754:	8d 83 d5 87 f7 ff    	lea    -0x8782b(%ebx),%eax
f010075a:	50                   	push   %eax
f010075b:	8d 83 db 87 f7 ff    	lea    -0x87825(%ebx),%eax
f0100761:	50                   	push   %eax
f0100762:	56                   	push   %esi
f0100763:	e8 33 33 00 00       	call   f0103a9b <cprintf>
	return 0;
}
f0100768:	b8 00 00 00 00       	mov    $0x0,%eax
f010076d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100770:	5b                   	pop    %ebx
f0100771:	5e                   	pop    %esi
f0100772:	5d                   	pop    %ebp
f0100773:	c3                   	ret    

f0100774 <mon_kerninfo>:

int mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100774:	55                   	push   %ebp
f0100775:	89 e5                	mov    %esp,%ebp
f0100777:	57                   	push   %edi
f0100778:	56                   	push   %esi
f0100779:	53                   	push   %ebx
f010077a:	83 ec 18             	sub    $0x18,%esp
f010077d:	e8 e5 f9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100782:	81 c3 9e c8 08 00    	add    $0x8c89e,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100788:	8d 83 e5 87 f7 ff    	lea    -0x8781b(%ebx),%eax
f010078e:	50                   	push   %eax
f010078f:	e8 07 33 00 00       	call   f0103a9b <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100794:	83 c4 08             	add    $0x8,%esp
f0100797:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f010079d:	8d 83 90 88 f7 ff    	lea    -0x87770(%ebx),%eax
f01007a3:	50                   	push   %eax
f01007a4:	e8 f2 32 00 00       	call   f0103a9b <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007a9:	83 c4 0c             	add    $0xc,%esp
f01007ac:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007b2:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007b8:	50                   	push   %eax
f01007b9:	57                   	push   %edi
f01007ba:	8d 83 b8 88 f7 ff    	lea    -0x87748(%ebx),%eax
f01007c0:	50                   	push   %eax
f01007c1:	e8 d5 32 00 00       	call   f0103a9b <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007c6:	83 c4 0c             	add    $0xc,%esp
f01007c9:	c7 c0 29 55 10 f0    	mov    $0xf0105529,%eax
f01007cf:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007d5:	52                   	push   %edx
f01007d6:	50                   	push   %eax
f01007d7:	8d 83 dc 88 f7 ff    	lea    -0x87724(%ebx),%eax
f01007dd:	50                   	push   %eax
f01007de:	e8 b8 32 00 00       	call   f0103a9b <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007e3:	83 c4 0c             	add    $0xc,%esp
f01007e6:	c7 c0 00 f1 18 f0    	mov    $0xf018f100,%eax
f01007ec:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007f2:	52                   	push   %edx
f01007f3:	50                   	push   %eax
f01007f4:	8d 83 00 89 f7 ff    	lea    -0x87700(%ebx),%eax
f01007fa:	50                   	push   %eax
f01007fb:	e8 9b 32 00 00       	call   f0103a9b <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100800:	83 c4 0c             	add    $0xc,%esp
f0100803:	c7 c6 10 00 19 f0    	mov    $0xf0190010,%esi
f0100809:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010080f:	50                   	push   %eax
f0100810:	56                   	push   %esi
f0100811:	8d 83 24 89 f7 ff    	lea    -0x876dc(%ebx),%eax
f0100817:	50                   	push   %eax
f0100818:	e8 7e 32 00 00       	call   f0103a9b <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010081d:	83 c4 08             	add    $0x8,%esp
			ROUNDUP(end - entry, 1024) / 1024);
f0100820:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f0100826:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100828:	c1 fe 0a             	sar    $0xa,%esi
f010082b:	56                   	push   %esi
f010082c:	8d 83 48 89 f7 ff    	lea    -0x876b8(%ebx),%eax
f0100832:	50                   	push   %eax
f0100833:	e8 63 32 00 00       	call   f0103a9b <cprintf>
	return 0;
}
f0100838:	b8 00 00 00 00       	mov    $0x0,%eax
f010083d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100840:	5b                   	pop    %ebx
f0100841:	5e                   	pop    %esi
f0100842:	5f                   	pop    %edi
f0100843:	5d                   	pop    %ebp
f0100844:	c3                   	ret    

f0100845 <mon_backtrace>:

int mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100845:	55                   	push   %ebp
f0100846:	89 e5                	mov    %esp,%ebp
f0100848:	57                   	push   %edi
f0100849:	56                   	push   %esi
f010084a:	53                   	push   %ebx
f010084b:	83 ec 4c             	sub    $0x4c,%esp
f010084e:	e8 14 f9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100853:	81 c3 cd c7 08 00    	add    $0x8c7cd,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100859:	89 e8                	mov    %ebp,%eax
	// 被调用的函数(mon_backtrace)开始时，首先完成了push %ebp，mov %esp, %ebp
	// 注1：push时，先减%esp在存储内容
	// 注2：栈向下生长，用+1来访问前面的内容
	// Your code here.

	int *ebp = (int *)read_ebp(); // 读取本函数%ebp的值，转化为指针，作为地址使用
f010085b:	89 c7                	mov    %eax,%edi
	int eip = ebp[1];			  // 堆栈上存储的第一个东西就是返回地址，因此用偏移量1来访问
f010085d:	8b 40 04             	mov    0x4(%eax),%eax
f0100860:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (1)					  // trace整个stack
	{
		// 打印%ebp和%eip
		cprintf("ebp %x, eip %x, args ", ebp, eip);
f0100863:	8d 83 fe 87 f7 ff    	lea    -0x87802(%ebx),%eax
f0100869:	89 45 b8             	mov    %eax,-0x48(%ebp)
		int *args = ebp + 2;		 // 从偏移量2开始存储的是上个函数的参数
		for (int i = 0; i < 5; ++i)	 // 练习要求打印5个参数
			cprintf("%x ", args[i]); // 输出参数，注：args[i]和args+i是一样的效果
f010086c:	8d 83 14 88 f7 ff    	lea    -0x877ec(%ebx),%eax
f0100872:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		cprintf("ebp %x, eip %x, args ", ebp, eip);
f0100875:	83 ec 04             	sub    $0x4,%esp
f0100878:	ff 75 c0             	pushl  -0x40(%ebp)
f010087b:	57                   	push   %edi
f010087c:	ff 75 b8             	pushl  -0x48(%ebp)
f010087f:	e8 17 32 00 00       	call   f0103a9b <cprintf>
f0100884:	8d 77 08             	lea    0x8(%edi),%esi
f0100887:	8d 47 1c             	lea    0x1c(%edi),%eax
f010088a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010088d:	83 c4 10             	add    $0x10,%esp
f0100890:	89 7d bc             	mov    %edi,-0x44(%ebp)
f0100893:	8b 7d b4             	mov    -0x4c(%ebp),%edi
			cprintf("%x ", args[i]); // 输出参数，注：args[i]和args+i是一样的效果
f0100896:	83 ec 08             	sub    $0x8,%esp
f0100899:	ff 36                	pushl  (%esi)
f010089b:	57                   	push   %edi
f010089c:	e8 fa 31 00 00       	call   f0103a9b <cprintf>
f01008a1:	83 c6 04             	add    $0x4,%esi
		for (int i = 0; i < 5; ++i)	 // 练习要求打印5个参数
f01008a4:	83 c4 10             	add    $0x10,%esp
f01008a7:	3b 75 c4             	cmp    -0x3c(%ebp),%esi
f01008aa:	75 ea                	jne    f0100896 <mon_backtrace+0x51>
f01008ac:	8b 7d bc             	mov    -0x44(%ebp),%edi
		cprintf("\n");
f01008af:	83 ec 0c             	sub    $0xc,%esp
f01008b2:	8d 83 c7 94 f7 ff    	lea    -0x86b39(%ebx),%eax
f01008b8:	50                   	push   %eax
f01008b9:	e8 dd 31 00 00       	call   f0103a9b <cprintf>

		// 显示每个%eip对应的函数名、源文件名和行号
		struct Eipdebuginfo info;
		if (!debuginfo_eip(eip, &info)) // 读取debug信息，找到信息，则debuginfo_eip返回0
f01008be:	83 c4 08             	add    $0x8,%esp
f01008c1:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008c4:	50                   	push   %eax
f01008c5:	8b 75 c0             	mov    -0x40(%ebp),%esi
f01008c8:	56                   	push   %esi
f01008c9:	e8 93 3c 00 00       	call   f0104561 <debuginfo_eip>
f01008ce:	83 c4 10             	add    $0x10,%esp
f01008d1:	85 c0                	test   %eax,%eax
f01008d3:	75 31                	jne    f0100906 <mon_backtrace+0xc1>
			cprintf("%s: %d: %.*s+%d\n",
f01008d5:	83 ec 08             	sub    $0x8,%esp
f01008d8:	89 f0                	mov    %esi,%eax
f01008da:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01008dd:	50                   	push   %eax
f01008de:	ff 75 d8             	pushl  -0x28(%ebp)
f01008e1:	ff 75 dc             	pushl  -0x24(%ebp)
f01008e4:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008e7:	ff 75 d0             	pushl  -0x30(%ebp)
f01008ea:	8d 83 18 88 f7 ff    	lea    -0x877e8(%ebx),%eax
f01008f0:	50                   	push   %eax
f01008f1:	e8 a5 31 00 00       	call   f0103a9b <cprintf>
					info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, eip - info.eip_fn_addr);
		else // 找不到信息，即到达stack的顶部
			break;

		// 更新指针
		ebp = (int *)*ebp; // *ebp得到压进堆栈的上一个函数的%ebp
f01008f6:	8b 3f                	mov    (%edi),%edi
		eip = ebp[1];
f01008f8:	8b 47 04             	mov    0x4(%edi),%eax
f01008fb:	89 45 c0             	mov    %eax,-0x40(%ebp)
	{
f01008fe:	83 c4 20             	add    $0x20,%esp
f0100901:	e9 6f ff ff ff       	jmp    f0100875 <mon_backtrace+0x30>
	}
	return 0;
}
f0100906:	b8 00 00 00 00       	mov    $0x0,%eax
f010090b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010090e:	5b                   	pop    %ebx
f010090f:	5e                   	pop    %esi
f0100910:	5f                   	pop    %edi
f0100911:	5d                   	pop    %ebp
f0100912:	c3                   	ret    

f0100913 <monitor>:
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void monitor(struct Trapframe *tf)
{
f0100913:	55                   	push   %ebp
f0100914:	89 e5                	mov    %esp,%ebp
f0100916:	57                   	push   %edi
f0100917:	56                   	push   %esi
f0100918:	53                   	push   %ebx
f0100919:	83 ec 68             	sub    $0x68,%esp
f010091c:	e8 46 f8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100921:	81 c3 ff c6 08 00    	add    $0x8c6ff,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100927:	8d 83 74 89 f7 ff    	lea    -0x8768c(%ebx),%eax
f010092d:	50                   	push   %eax
f010092e:	e8 68 31 00 00       	call   f0103a9b <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100933:	8d 83 98 89 f7 ff    	lea    -0x87668(%ebx),%eax
f0100939:	89 04 24             	mov    %eax,(%esp)
f010093c:	e8 5a 31 00 00       	call   f0103a9b <cprintf>

	if (tf != NULL)
f0100941:	83 c4 10             	add    $0x10,%esp
f0100944:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100948:	74 0e                	je     f0100958 <monitor+0x45>
		print_trapframe(tf);
f010094a:	83 ec 0c             	sub    $0xc,%esp
f010094d:	ff 75 08             	pushl  0x8(%ebp)
f0100950:	e8 1e 36 00 00       	call   f0103f73 <print_trapframe>
f0100955:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100958:	8d bb 2d 88 f7 ff    	lea    -0x877d3(%ebx),%edi
f010095e:	eb 4a                	jmp    f01009aa <monitor+0x97>
f0100960:	83 ec 08             	sub    $0x8,%esp
f0100963:	0f be c0             	movsbl %al,%eax
f0100966:	50                   	push   %eax
f0100967:	57                   	push   %edi
f0100968:	e8 48 47 00 00       	call   f01050b5 <strchr>
f010096d:	83 c4 10             	add    $0x10,%esp
f0100970:	85 c0                	test   %eax,%eax
f0100972:	74 08                	je     f010097c <monitor+0x69>
			*buf++ = 0;
f0100974:	c6 06 00             	movb   $0x0,(%esi)
f0100977:	8d 76 01             	lea    0x1(%esi),%esi
f010097a:	eb 76                	jmp    f01009f2 <monitor+0xdf>
		if (*buf == 0)
f010097c:	80 3e 00             	cmpb   $0x0,(%esi)
f010097f:	74 7c                	je     f01009fd <monitor+0xea>
		if (argc == MAXARGS - 1)
f0100981:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f0100985:	74 0f                	je     f0100996 <monitor+0x83>
		argv[argc++] = buf;
f0100987:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f010098a:	8d 48 01             	lea    0x1(%eax),%ecx
f010098d:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0100990:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f0100994:	eb 41                	jmp    f01009d7 <monitor+0xc4>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100996:	83 ec 08             	sub    $0x8,%esp
f0100999:	6a 10                	push   $0x10
f010099b:	8d 83 32 88 f7 ff    	lea    -0x877ce(%ebx),%eax
f01009a1:	50                   	push   %eax
f01009a2:	e8 f4 30 00 00       	call   f0103a9b <cprintf>
f01009a7:	83 c4 10             	add    $0x10,%esp
	while (1)
	{
		buf = readline("K> ");
f01009aa:	8d 83 29 88 f7 ff    	lea    -0x877d7(%ebx),%eax
f01009b0:	89 c6                	mov    %eax,%esi
f01009b2:	83 ec 0c             	sub    $0xc,%esp
f01009b5:	56                   	push   %esi
f01009b6:	e8 c2 44 00 00       	call   f0104e7d <readline>
		if (buf != NULL)
f01009bb:	83 c4 10             	add    $0x10,%esp
f01009be:	85 c0                	test   %eax,%eax
f01009c0:	74 f0                	je     f01009b2 <monitor+0x9f>
f01009c2:	89 c6                	mov    %eax,%esi
	argv[argc] = 0;
f01009c4:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009cb:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01009d2:	eb 1e                	jmp    f01009f2 <monitor+0xdf>
			buf++;
f01009d4:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01009d7:	0f b6 06             	movzbl (%esi),%eax
f01009da:	84 c0                	test   %al,%al
f01009dc:	74 14                	je     f01009f2 <monitor+0xdf>
f01009de:	83 ec 08             	sub    $0x8,%esp
f01009e1:	0f be c0             	movsbl %al,%eax
f01009e4:	50                   	push   %eax
f01009e5:	57                   	push   %edi
f01009e6:	e8 ca 46 00 00       	call   f01050b5 <strchr>
f01009eb:	83 c4 10             	add    $0x10,%esp
f01009ee:	85 c0                	test   %eax,%eax
f01009f0:	74 e2                	je     f01009d4 <monitor+0xc1>
		while (*buf && strchr(WHITESPACE, *buf))
f01009f2:	0f b6 06             	movzbl (%esi),%eax
f01009f5:	84 c0                	test   %al,%al
f01009f7:	0f 85 63 ff ff ff    	jne    f0100960 <monitor+0x4d>
	argv[argc] = 0;
f01009fd:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a00:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a07:	00 
	if (argc == 0)
f0100a08:	85 c0                	test   %eax,%eax
f0100a0a:	74 9e                	je     f01009aa <monitor+0x97>
f0100a0c:	8d b3 20 20 00 00    	lea    0x2020(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f0100a12:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a17:	89 7d a0             	mov    %edi,-0x60(%ebp)
f0100a1a:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a1c:	83 ec 08             	sub    $0x8,%esp
f0100a1f:	ff 36                	pushl  (%esi)
f0100a21:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a24:	e8 2e 46 00 00       	call   f0105057 <strcmp>
f0100a29:	83 c4 10             	add    $0x10,%esp
f0100a2c:	85 c0                	test   %eax,%eax
f0100a2e:	74 28                	je     f0100a58 <monitor+0x145>
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f0100a30:	83 c7 01             	add    $0x1,%edi
f0100a33:	83 c6 0c             	add    $0xc,%esi
f0100a36:	83 ff 03             	cmp    $0x3,%edi
f0100a39:	75 e1                	jne    f0100a1c <monitor+0x109>
f0100a3b:	8b 7d a0             	mov    -0x60(%ebp),%edi
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a3e:	83 ec 08             	sub    $0x8,%esp
f0100a41:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a44:	8d 83 4f 88 f7 ff    	lea    -0x877b1(%ebx),%eax
f0100a4a:	50                   	push   %eax
f0100a4b:	e8 4b 30 00 00       	call   f0103a9b <cprintf>
f0100a50:	83 c4 10             	add    $0x10,%esp
f0100a53:	e9 52 ff ff ff       	jmp    f01009aa <monitor+0x97>
f0100a58:	89 f8                	mov    %edi,%eax
f0100a5a:	8b 7d a0             	mov    -0x60(%ebp),%edi
			return commands[i].func(argc, argv, tf);
f0100a5d:	83 ec 04             	sub    $0x4,%esp
f0100a60:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a63:	ff 75 08             	pushl  0x8(%ebp)
f0100a66:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a69:	52                   	push   %edx
f0100a6a:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100a6d:	ff 94 83 28 20 00 00 	call   *0x2028(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a74:	83 c4 10             	add    $0x10,%esp
f0100a77:	85 c0                	test   %eax,%eax
f0100a79:	0f 89 2b ff ff ff    	jns    f01009aa <monitor+0x97>
				break;
	}
}
f0100a7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a82:	5b                   	pop    %ebx
f0100a83:	5e                   	pop    %esi
f0100a84:	5f                   	pop    %edi
f0100a85:	5d                   	pop    %ebp
f0100a86:	c3                   	ret    

f0100a87 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100a87:	55                   	push   %ebp
f0100a88:	89 e5                	mov    %esp,%ebp
f0100a8a:	57                   	push   %edi
f0100a8b:	56                   	push   %esi
f0100a8c:	53                   	push   %ebx
f0100a8d:	83 ec 18             	sub    $0x18,%esp
f0100a90:	e8 d2 f6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100a95:	81 c3 8b c5 08 00    	add    $0x8c58b,%ebx
f0100a9b:	89 c7                	mov    %eax,%edi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a9d:	50                   	push   %eax
f0100a9e:	e8 71 2f 00 00       	call   f0103a14 <mc146818_read>
f0100aa3:	89 c6                	mov    %eax,%esi
f0100aa5:	83 c7 01             	add    $0x1,%edi
f0100aa8:	89 3c 24             	mov    %edi,(%esp)
f0100aab:	e8 64 2f 00 00       	call   f0103a14 <mc146818_read>
f0100ab0:	c1 e0 08             	shl    $0x8,%eax
f0100ab3:	09 f0                	or     %esi,%eax
}
f0100ab5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ab8:	5b                   	pop    %ebx
f0100ab9:	5e                   	pop    %esi
f0100aba:	5f                   	pop    %edi
f0100abb:	5d                   	pop    %ebp
f0100abc:	c3                   	ret    

f0100abd <boot_alloc>:
// 仅在JOS设置其虚拟内存系统时使用的简单的物理内存分配器，之后使用page_alloc()分配
// 分配一个足以容纳n字节的内存区间：用一个地址nextfree来确定可以使用的内存的顶部，并且返回可以使用的内存的底部地址result
// 可使用内存区间为[result, nextfree], 且区间长度是4096的倍数
static void *
boot_alloc(uint32_t n)
{
f0100abd:	55                   	push   %ebp
f0100abe:	89 e5                	mov    %esp,%ebp
f0100ac0:	53                   	push   %ebx
f0100ac1:	83 ec 04             	sub    $0x4,%esp
f0100ac4:	e8 9e f6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100ac9:	81 c3 57 c5 08 00    	add    $0x8c557,%ebx
f0100acf:	89 c2                	mov    %eax,%edx
	static char *nextfree; // virtual address of next byte of free memory，static意味着nextfree不会随着函数返回被重置，是全局变量
	char *result;

	if (!nextfree) // nextfree初始化，只有第一次运行会执行
f0100ad1:	83 bb 18 23 00 00 00 	cmpl   $0x0,0x2318(%ebx)
f0100ad8:	74 2b                	je     f0100b05 <boot_alloc+0x48>
		 * 假设end是4097，ROUNDUP(end, PGSIZE)得到end=4096*2，这样才能容纳4097
		 */
	}

	// LAB 2: Your code here.
	if (n == 0) // 不分配内存，直接返回
f0100ada:	85 d2                	test   %edx,%edx
f0100adc:	74 3f                	je     f0100b1d <boot_alloc+0x60>
	{
		return nextfree;
	}

	// n是无符号数，不考虑<0情形
	result = nextfree;				// 将更新前的nextfree赋给result
f0100ade:	8b 83 18 23 00 00    	mov    0x2318(%ebx),%eax
	nextfree += ROUNDUP(n, PGSIZE); // +=:在原来的基础上再分配
f0100ae4:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100aea:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100af0:	01 c2                	add    %eax,%edx
f0100af2:	89 93 18 23 00 00    	mov    %edx,0x2318(%ebx)

	// 如果内存不足，boot_alloc应该会死机
	if (nextfree > (char *)0xf0400000) // >4MB
f0100af8:	81 fa 00 00 40 f0    	cmp    $0xf0400000,%edx
f0100afe:	77 25                	ja     f0100b25 <boot_alloc+0x68>
		panic("out of memory(4MB) : boot_alloc() in pmap.c \n"); // 调用预先定义的assert
		nextfree = result;										 // 分配失败，回调nextfree
		return NULL;
	}
	return result;
}
f0100b00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b03:	c9                   	leave  
f0100b04:	c3                   	ret    
		nextfree = ROUNDUP((char *)end, PGSIZE); // 内核使用的第一块内存必须远离内核代码结尾
f0100b05:	c7 c0 10 00 19 f0    	mov    $0xf0190010,%eax
f0100b0b:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100b10:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b15:	89 83 18 23 00 00    	mov    %eax,0x2318(%ebx)
f0100b1b:	eb bd                	jmp    f0100ada <boot_alloc+0x1d>
		return nextfree;
f0100b1d:	8b 83 18 23 00 00    	mov    0x2318(%ebx),%eax
f0100b23:	eb db                	jmp    f0100b00 <boot_alloc+0x43>
		panic("out of memory(4MB) : boot_alloc() in pmap.c \n"); // 调用预先定义的assert
f0100b25:	83 ec 04             	sub    $0x4,%esp
f0100b28:	8d 83 c0 89 f7 ff    	lea    -0x87640(%ebx),%eax
f0100b2e:	50                   	push   %eax
f0100b2f:	6a 68                	push   $0x68
f0100b31:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0100b37:	50                   	push   %eax
f0100b38:	e8 74 f5 ff ff       	call   f01000b1 <_panic>

f0100b3d <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b3d:	55                   	push   %ebp
f0100b3e:	89 e5                	mov    %esp,%ebp
f0100b40:	56                   	push   %esi
f0100b41:	53                   	push   %ebx
f0100b42:	e8 40 27 00 00       	call   f0103287 <__x86.get_pc_thunk.cx>
f0100b47:	81 c1 d9 c4 08 00    	add    $0x8c4d9,%ecx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b4d:	89 d3                	mov    %edx,%ebx
f0100b4f:	c1 eb 16             	shr    $0x16,%ebx
	if (!(*pgdir & PTE_P))
f0100b52:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f0100b55:	a8 01                	test   $0x1,%al
f0100b57:	74 5a                	je     f0100bb3 <check_va2pa+0x76>
		return ~0;
	p = (pte_t *)KADDR(PTE_ADDR(*pgdir));
f0100b59:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b5e:	89 c6                	mov    %eax,%esi
f0100b60:	c1 ee 0c             	shr    $0xc,%esi
f0100b63:	c7 c3 04 00 19 f0    	mov    $0xf0190004,%ebx
f0100b69:	3b 33                	cmp    (%ebx),%esi
f0100b6b:	73 2b                	jae    f0100b98 <check_va2pa+0x5b>
	if (!(p[PTX(va)] & PTE_P))
f0100b6d:	c1 ea 0c             	shr    $0xc,%edx
f0100b70:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b76:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b7d:	89 c2                	mov    %eax,%edx
f0100b7f:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b87:	85 d2                	test   %edx,%edx
f0100b89:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b8e:	0f 44 c2             	cmove  %edx,%eax
}
f0100b91:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b94:	5b                   	pop    %ebx
f0100b95:	5e                   	pop    %esi
f0100b96:	5d                   	pop    %ebp
f0100b97:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b98:	50                   	push   %eax
f0100b99:	8d 81 f0 89 f7 ff    	lea    -0x87610(%ecx),%eax
f0100b9f:	50                   	push   %eax
f0100ba0:	68 af 02 00 00       	push   $0x2af
f0100ba5:	8d 81 6d 92 f7 ff    	lea    -0x86d93(%ecx),%eax
f0100bab:	50                   	push   %eax
f0100bac:	89 cb                	mov    %ecx,%ebx
f0100bae:	e8 fe f4 ff ff       	call   f01000b1 <_panic>
		return ~0;
f0100bb3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100bb8:	eb d7                	jmp    f0100b91 <check_va2pa+0x54>

f0100bba <check_page_free_list>:
{
f0100bba:	55                   	push   %ebp
f0100bbb:	89 e5                	mov    %esp,%ebp
f0100bbd:	57                   	push   %edi
f0100bbe:	56                   	push   %esi
f0100bbf:	53                   	push   %ebx
f0100bc0:	83 ec 3c             	sub    $0x3c,%esp
f0100bc3:	e8 c7 26 00 00       	call   f010328f <__x86.get_pc_thunk.di>
f0100bc8:	81 c7 58 c4 08 00    	add    $0x8c458,%edi
f0100bce:	89 7d c4             	mov    %edi,-0x3c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bd1:	84 c0                	test   %al,%al
f0100bd3:	0f 85 dd 02 00 00    	jne    f0100eb6 <check_page_free_list+0x2fc>
	if (!page_free_list)
f0100bd9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100bdc:	83 b8 20 23 00 00 00 	cmpl   $0x0,0x2320(%eax)
f0100be3:	74 0c                	je     f0100bf1 <check_page_free_list+0x37>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100be5:	c7 45 d4 00 04 00 00 	movl   $0x400,-0x2c(%ebp)
f0100bec:	e9 2f 03 00 00       	jmp    f0100f20 <check_page_free_list+0x366>
		panic("'page_free_list' is a null pointer!");
f0100bf1:	83 ec 04             	sub    $0x4,%esp
f0100bf4:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100bf7:	8d 83 14 8a f7 ff    	lea    -0x875ec(%ebx),%eax
f0100bfd:	50                   	push   %eax
f0100bfe:	68 e6 01 00 00       	push   $0x1e6
f0100c03:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0100c09:	50                   	push   %eax
f0100c0a:	e8 a2 f4 ff ff       	call   f01000b1 <_panic>
f0100c0f:	50                   	push   %eax
f0100c10:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100c13:	8d 83 f0 89 f7 ff    	lea    -0x87610(%ebx),%eax
f0100c19:	50                   	push   %eax
f0100c1a:	6a 56                	push   $0x56
f0100c1c:	8d 83 79 92 f7 ff    	lea    -0x86d87(%ebx),%eax
f0100c22:	50                   	push   %eax
f0100c23:	e8 89 f4 ff ff       	call   f01000b1 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c28:	8b 36                	mov    (%esi),%esi
f0100c2a:	85 f6                	test   %esi,%esi
f0100c2c:	74 40                	je     f0100c6e <check_page_free_list+0xb4>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c2e:	89 f0                	mov    %esi,%eax
f0100c30:	2b 07                	sub    (%edi),%eax
f0100c32:	c1 f8 03             	sar    $0x3,%eax
f0100c35:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c38:	89 c2                	mov    %eax,%edx
f0100c3a:	c1 ea 16             	shr    $0x16,%edx
f0100c3d:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c40:	73 e6                	jae    f0100c28 <check_page_free_list+0x6e>
	if (PGNUM(pa) >= npages)
f0100c42:	89 c2                	mov    %eax,%edx
f0100c44:	c1 ea 0c             	shr    $0xc,%edx
f0100c47:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100c4a:	3b 11                	cmp    (%ecx),%edx
f0100c4c:	73 c1                	jae    f0100c0f <check_page_free_list+0x55>
			memset(page2kva(pp), 0x97, 128);
f0100c4e:	83 ec 04             	sub    $0x4,%esp
f0100c51:	68 80 00 00 00       	push   $0x80
f0100c56:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c5b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c60:	50                   	push   %eax
f0100c61:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100c64:	e8 89 44 00 00       	call   f01050f2 <memset>
f0100c69:	83 c4 10             	add    $0x10,%esp
f0100c6c:	eb ba                	jmp    f0100c28 <check_page_free_list+0x6e>
	first_free_page = (char *)boot_alloc(0);
f0100c6e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c73:	e8 45 fe ff ff       	call   f0100abd <boot_alloc>
f0100c78:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c7b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100c7e:	8b 97 20 23 00 00    	mov    0x2320(%edi),%edx
		assert(pp >= pages);
f0100c84:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0100c8a:	8b 08                	mov    (%eax),%ecx
		assert(pp < pages + npages);
f0100c8c:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f0100c92:	8b 00                	mov    (%eax),%eax
f0100c94:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100c97:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
		assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0100c9a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c9d:	bf 00 00 00 00       	mov    $0x0,%edi
f0100ca2:	89 75 d0             	mov    %esi,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ca5:	e9 08 01 00 00       	jmp    f0100db2 <check_page_free_list+0x1f8>
		assert(pp >= pages);
f0100caa:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100cad:	8d 83 87 92 f7 ff    	lea    -0x86d79(%ebx),%eax
f0100cb3:	50                   	push   %eax
f0100cb4:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0100cba:	50                   	push   %eax
f0100cbb:	68 03 02 00 00       	push   $0x203
f0100cc0:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0100cc6:	50                   	push   %eax
f0100cc7:	e8 e5 f3 ff ff       	call   f01000b1 <_panic>
		assert(pp < pages + npages);
f0100ccc:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100ccf:	8d 83 a8 92 f7 ff    	lea    -0x86d58(%ebx),%eax
f0100cd5:	50                   	push   %eax
f0100cd6:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0100cdc:	50                   	push   %eax
f0100cdd:	68 04 02 00 00       	push   $0x204
f0100ce2:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0100ce8:	50                   	push   %eax
f0100ce9:	e8 c3 f3 ff ff       	call   f01000b1 <_panic>
		assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0100cee:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100cf1:	8d 83 38 8a f7 ff    	lea    -0x875c8(%ebx),%eax
f0100cf7:	50                   	push   %eax
f0100cf8:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0100cfe:	50                   	push   %eax
f0100cff:	68 05 02 00 00       	push   $0x205
f0100d04:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0100d0a:	50                   	push   %eax
f0100d0b:	e8 a1 f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != 0);
f0100d10:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d13:	8d 83 bc 92 f7 ff    	lea    -0x86d44(%ebx),%eax
f0100d19:	50                   	push   %eax
f0100d1a:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0100d20:	50                   	push   %eax
f0100d21:	68 08 02 00 00       	push   $0x208
f0100d26:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0100d2c:	50                   	push   %eax
f0100d2d:	e8 7f f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d32:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d35:	8d 83 cd 92 f7 ff    	lea    -0x86d33(%ebx),%eax
f0100d3b:	50                   	push   %eax
f0100d3c:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0100d42:	50                   	push   %eax
f0100d43:	68 09 02 00 00       	push   $0x209
f0100d48:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0100d4e:	50                   	push   %eax
f0100d4f:	e8 5d f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d54:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d57:	8d 83 68 8a f7 ff    	lea    -0x87598(%ebx),%eax
f0100d5d:	50                   	push   %eax
f0100d5e:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0100d64:	50                   	push   %eax
f0100d65:	68 0a 02 00 00       	push   $0x20a
f0100d6a:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0100d70:	50                   	push   %eax
f0100d71:	e8 3b f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d76:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d79:	8d 83 e6 92 f7 ff    	lea    -0x86d1a(%ebx),%eax
f0100d7f:	50                   	push   %eax
f0100d80:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0100d86:	50                   	push   %eax
f0100d87:	68 0b 02 00 00       	push   $0x20b
f0100d8c:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0100d92:	50                   	push   %eax
f0100d93:	e8 19 f3 ff ff       	call   f01000b1 <_panic>
	if (PGNUM(pa) >= npages)
f0100d98:	89 c6                	mov    %eax,%esi
f0100d9a:	c1 ee 0c             	shr    $0xc,%esi
f0100d9d:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f0100da0:	76 70                	jbe    f0100e12 <check_page_free_list+0x258>
	return (void *)(pa + KERNBASE);
f0100da2:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f0100da7:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100daa:	77 7f                	ja     f0100e2b <check_page_free_list+0x271>
			++nfree_extmem;
f0100dac:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100db0:	8b 12                	mov    (%edx),%edx
f0100db2:	85 d2                	test   %edx,%edx
f0100db4:	0f 84 93 00 00 00    	je     f0100e4d <check_page_free_list+0x293>
		assert(pp >= pages);
f0100dba:	39 d1                	cmp    %edx,%ecx
f0100dbc:	0f 87 e8 fe ff ff    	ja     f0100caa <check_page_free_list+0xf0>
		assert(pp < pages + npages);
f0100dc2:	39 d3                	cmp    %edx,%ebx
f0100dc4:	0f 86 02 ff ff ff    	jbe    f0100ccc <check_page_free_list+0x112>
		assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0100dca:	89 d0                	mov    %edx,%eax
f0100dcc:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100dcf:	a8 07                	test   $0x7,%al
f0100dd1:	0f 85 17 ff ff ff    	jne    f0100cee <check_page_free_list+0x134>
	return (pp - pages) << PGSHIFT;
f0100dd7:	c1 f8 03             	sar    $0x3,%eax
f0100dda:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100ddd:	85 c0                	test   %eax,%eax
f0100ddf:	0f 84 2b ff ff ff    	je     f0100d10 <check_page_free_list+0x156>
		assert(page2pa(pp) != IOPHYSMEM);
f0100de5:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100dea:	0f 84 42 ff ff ff    	je     f0100d32 <check_page_free_list+0x178>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100df0:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100df5:	0f 84 59 ff ff ff    	je     f0100d54 <check_page_free_list+0x19a>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100dfb:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e00:	0f 84 70 ff ff ff    	je     f0100d76 <check_page_free_list+0x1bc>
		assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f0100e06:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e0b:	77 8b                	ja     f0100d98 <check_page_free_list+0x1de>
			++nfree_basemem;
f0100e0d:	83 c7 01             	add    $0x1,%edi
f0100e10:	eb 9e                	jmp    f0100db0 <check_page_free_list+0x1f6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e12:	50                   	push   %eax
f0100e13:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e16:	8d 83 f0 89 f7 ff    	lea    -0x87610(%ebx),%eax
f0100e1c:	50                   	push   %eax
f0100e1d:	6a 56                	push   $0x56
f0100e1f:	8d 83 79 92 f7 ff    	lea    -0x86d87(%ebx),%eax
f0100e25:	50                   	push   %eax
f0100e26:	e8 86 f2 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f0100e2b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e2e:	8d 83 8c 8a f7 ff    	lea    -0x87574(%ebx),%eax
f0100e34:	50                   	push   %eax
f0100e35:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0100e3b:	50                   	push   %eax
f0100e3c:	68 0c 02 00 00       	push   $0x20c
f0100e41:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0100e47:	50                   	push   %eax
f0100e48:	e8 64 f2 ff ff       	call   f01000b1 <_panic>
f0100e4d:	8b 75 d0             	mov    -0x30(%ebp),%esi
	assert(nfree_basemem > 0);
f0100e50:	85 ff                	test   %edi,%edi
f0100e52:	7e 1e                	jle    f0100e72 <check_page_free_list+0x2b8>
	assert(nfree_extmem > 0);
f0100e54:	85 f6                	test   %esi,%esi
f0100e56:	7e 3c                	jle    f0100e94 <check_page_free_list+0x2da>
	cprintf("check_page_free_list() succeeded!\n");
f0100e58:	83 ec 0c             	sub    $0xc,%esp
f0100e5b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e5e:	8d 83 d0 8a f7 ff    	lea    -0x87530(%ebx),%eax
f0100e64:	50                   	push   %eax
f0100e65:	e8 31 2c 00 00       	call   f0103a9b <cprintf>
}
f0100e6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e6d:	5b                   	pop    %ebx
f0100e6e:	5e                   	pop    %esi
f0100e6f:	5f                   	pop    %edi
f0100e70:	5d                   	pop    %ebp
f0100e71:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e72:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e75:	8d 83 00 93 f7 ff    	lea    -0x86d00(%ebx),%eax
f0100e7b:	50                   	push   %eax
f0100e7c:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0100e82:	50                   	push   %eax
f0100e83:	68 14 02 00 00       	push   $0x214
f0100e88:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0100e8e:	50                   	push   %eax
f0100e8f:	e8 1d f2 ff ff       	call   f01000b1 <_panic>
	assert(nfree_extmem > 0);
f0100e94:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e97:	8d 83 12 93 f7 ff    	lea    -0x86cee(%ebx),%eax
f0100e9d:	50                   	push   %eax
f0100e9e:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0100ea4:	50                   	push   %eax
f0100ea5:	68 15 02 00 00       	push   $0x215
f0100eaa:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0100eb0:	50                   	push   %eax
f0100eb1:	e8 fb f1 ff ff       	call   f01000b1 <_panic>
	if (!page_free_list)
f0100eb6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100eb9:	8b 80 20 23 00 00    	mov    0x2320(%eax),%eax
f0100ebf:	85 c0                	test   %eax,%eax
f0100ec1:	0f 84 2a fd ff ff    	je     f0100bf1 <check_page_free_list+0x37>
		struct PageInfo **tp[2] = {&pp1, &pp2};
f0100ec7:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100eca:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100ecd:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ed0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100ed3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100ed6:	c7 c3 0c 00 19 f0    	mov    $0xf019000c,%ebx
f0100edc:	89 c2                	mov    %eax,%edx
f0100ede:	2b 13                	sub    (%ebx),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100ee0:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100ee6:	0f 95 c2             	setne  %dl
f0100ee9:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100eec:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100ef0:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100ef2:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ef6:	8b 00                	mov    (%eax),%eax
f0100ef8:	85 c0                	test   %eax,%eax
f0100efa:	75 e0                	jne    f0100edc <check_page_free_list+0x322>
		*tp[1] = 0;
f0100efc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100eff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100f05:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100f08:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f0b:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100f0d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f10:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100f13:	89 87 20 23 00 00    	mov    %eax,0x2320(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f19:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f20:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100f23:	8b b0 20 23 00 00    	mov    0x2320(%eax),%esi
f0100f29:	c7 c7 0c 00 19 f0    	mov    $0xf019000c,%edi
	if (PGNUM(pa) >= npages)
f0100f2f:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f0100f35:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100f38:	e9 ed fc ff ff       	jmp    f0100c2a <check_page_free_list+0x70>

f0100f3d <page_init>:
{
f0100f3d:	55                   	push   %ebp
f0100f3e:	89 e5                	mov    %esp,%ebp
f0100f40:	57                   	push   %edi
f0100f41:	56                   	push   %esi
f0100f42:	53                   	push   %ebx
f0100f43:	83 ec 1c             	sub    $0x1c,%esp
f0100f46:	e8 40 23 00 00       	call   f010328b <__x86.get_pc_thunk.si>
f0100f4b:	81 c6 d5 c0 08 00    	add    $0x8c0d5,%esi
f0100f51:	89 75 e4             	mov    %esi,-0x1c(%ebp)
	page_free_list = NULL; // page_free_list是static的，不会被初始化，必须给一个初始值
f0100f54:	c7 86 20 23 00 00 00 	movl   $0x0,0x2320(%esi)
f0100f5b:	00 00 00 
	for (int i = 1; i < npages_basemem; i++) // 将内存中的pages数组初始化为链表，头指针是page_free_list
f0100f5e:	8b be 24 23 00 00    	mov    0x2324(%esi),%edi
f0100f64:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f69:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100f6e:	b8 01 00 00 00       	mov    $0x1,%eax
		pages[i].pp_ref = 0;
f0100f73:	c7 c6 0c 00 19 f0    	mov    $0xf019000c,%esi
	for (int i = 1; i < npages_basemem; i++) // 将内存中的pages数组初始化为链表，头指针是page_free_list
f0100f79:	eb 1f                	jmp    f0100f9a <page_init+0x5d>
f0100f7b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100f82:	89 d1                	mov    %edx,%ecx
f0100f84:	03 0e                	add    (%esi),%ecx
f0100f86:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100f8c:	89 19                	mov    %ebx,(%ecx)
	for (int i = 1; i < npages_basemem; i++) // 将内存中的pages数组初始化为链表，头指针是page_free_list
f0100f8e:	83 c0 01             	add    $0x1,%eax
		page_free_list = &pages[i]; // pages中包含了整个内存中的页，page_free_list指向其中空闲的页组成的链表的头部
f0100f91:	89 d3                	mov    %edx,%ebx
f0100f93:	03 1e                	add    (%esi),%ebx
f0100f95:	ba 01 00 00 00       	mov    $0x1,%edx
	for (int i = 1; i < npages_basemem; i++) // 将内存中的pages数组初始化为链表，头指针是page_free_list
f0100f9a:	39 c7                	cmp    %eax,%edi
f0100f9c:	77 dd                	ja     f0100f7b <page_init+0x3e>
f0100f9e:	84 d2                	test   %dl,%dl
f0100fa0:	75 35                	jne    f0100fd7 <page_init+0x9a>
	for (int i = PGNUM(PADDR(boot_alloc(0))); i < npages; i++) // PADDR()将虚拟地址转化为物理地址，boot_alloc(0)得到nextfree的位置(即pages end),PGNUM()求出需要几页才能到达该地址
f0100fa2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fa7:	e8 11 fb ff ff       	call   f0100abd <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100fac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100fb1:	76 2f                	jbe    f0100fe2 <page_init+0xa5>
	return (physaddr_t)kva - KERNBASE;
f0100fb3:	05 00 00 00 10       	add    $0x10000000,%eax
f0100fb8:	c1 e8 0c             	shr    $0xc,%eax
f0100fbb:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100fbe:	8b 9e 20 23 00 00    	mov    0x2320(%esi),%ebx
f0100fc4:	ba 00 00 00 00       	mov    $0x0,%edx
f0100fc9:	c7 c7 04 00 19 f0    	mov    $0xf0190004,%edi
		pages[i].pp_ref = 0;
f0100fcf:	c7 c6 0c 00 19 f0    	mov    $0xf019000c,%esi
	for (int i = PGNUM(PADDR(boot_alloc(0))); i < npages; i++) // PADDR()将虚拟地址转化为物理地址，boot_alloc(0)得到nextfree的位置(即pages end),PGNUM()求出需要几页才能到达该地址
f0100fd5:	eb 46                	jmp    f010101d <page_init+0xe0>
f0100fd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100fda:	89 98 20 23 00 00    	mov    %ebx,0x2320(%eax)
f0100fe0:	eb c0                	jmp    f0100fa2 <page_init+0x65>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100fe2:	50                   	push   %eax
f0100fe3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100fe6:	8d 83 f4 8a f7 ff    	lea    -0x8750c(%ebx),%eax
f0100fec:	50                   	push   %eax
f0100fed:	68 03 01 00 00       	push   $0x103
f0100ff2:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0100ff8:	50                   	push   %eax
f0100ff9:	e8 b3 f0 ff ff       	call   f01000b1 <_panic>
f0100ffe:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0101005:	89 d1                	mov    %edx,%ecx
f0101007:	03 0e                	add    (%esi),%ecx
f0101009:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f010100f:	89 19                	mov    %ebx,(%ecx)
	for (int i = PGNUM(PADDR(boot_alloc(0))); i < npages; i++) // PADDR()将虚拟地址转化为物理地址，boot_alloc(0)得到nextfree的位置(即pages end),PGNUM()求出需要几页才能到达该地址
f0101011:	83 c0 01             	add    $0x1,%eax
		page_free_list = &pages[i];
f0101014:	89 d3                	mov    %edx,%ebx
f0101016:	03 1e                	add    (%esi),%ebx
f0101018:	ba 01 00 00 00       	mov    $0x1,%edx
	for (int i = PGNUM(PADDR(boot_alloc(0))); i < npages; i++) // PADDR()将虚拟地址转化为物理地址，boot_alloc(0)得到nextfree的位置(即pages end),PGNUM()求出需要几页才能到达该地址
f010101d:	3b 07                	cmp    (%edi),%eax
f010101f:	72 dd                	jb     f0100ffe <page_init+0xc1>
f0101021:	84 d2                	test   %dl,%dl
f0101023:	75 08                	jne    f010102d <page_init+0xf0>
}
f0101025:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101028:	5b                   	pop    %ebx
f0101029:	5e                   	pop    %esi
f010102a:	5f                   	pop    %edi
f010102b:	5d                   	pop    %ebp
f010102c:	c3                   	ret    
f010102d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101030:	89 98 20 23 00 00    	mov    %ebx,0x2320(%eax)
f0101036:	eb ed                	jmp    f0101025 <page_init+0xe8>

f0101038 <page_alloc>:
{
f0101038:	55                   	push   %ebp
f0101039:	89 e5                	mov    %esp,%ebp
f010103b:	56                   	push   %esi
f010103c:	53                   	push   %ebx
f010103d:	e8 25 f1 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0101042:	81 c3 de bf 08 00    	add    $0x8bfde,%ebx
	if (page_free_list) // page_free_list指向空闲页组成的链表的头部
f0101048:	8b b3 20 23 00 00    	mov    0x2320(%ebx),%esi
f010104e:	85 f6                	test   %esi,%esi
f0101050:	74 1a                	je     f010106c <page_alloc+0x34>
		page_free_list = page_free_list->pp_link; // 链表next行进
f0101052:	8b 06                	mov    (%esi),%eax
f0101054:	89 83 20 23 00 00    	mov    %eax,0x2320(%ebx)
		if (alloc_flags & ALLOC_ZERO)
f010105a:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010105e:	75 15                	jne    f0101075 <page_alloc+0x3d>
		result->pp_ref = 0;
f0101060:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
		result->pp_link = NULL; // 确保page_free就可以检查错误
f0101066:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
}
f010106c:	89 f0                	mov    %esi,%eax
f010106e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101071:	5b                   	pop    %ebx
f0101072:	5e                   	pop    %esi
f0101073:	5d                   	pop    %ebp
f0101074:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0101075:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f010107b:	89 f2                	mov    %esi,%edx
f010107d:	2b 10                	sub    (%eax),%edx
f010107f:	89 d0                	mov    %edx,%eax
f0101081:	c1 f8 03             	sar    $0x3,%eax
f0101084:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101087:	89 c1                	mov    %eax,%ecx
f0101089:	c1 e9 0c             	shr    $0xc,%ecx
f010108c:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f0101092:	3b 0a                	cmp    (%edx),%ecx
f0101094:	73 1a                	jae    f01010b0 <page_alloc+0x78>
			memset(page2kva(result), 0, PGSIZE); // page2kva(p)：求得页p的地址，方法就是先求出p的索引i，用i*4096得到地址
f0101096:	83 ec 04             	sub    $0x4,%esp
f0101099:	68 00 10 00 00       	push   $0x1000
f010109e:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01010a0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010a5:	50                   	push   %eax
f01010a6:	e8 47 40 00 00       	call   f01050f2 <memset>
f01010ab:	83 c4 10             	add    $0x10,%esp
f01010ae:	eb b0                	jmp    f0101060 <page_alloc+0x28>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010b0:	50                   	push   %eax
f01010b1:	8d 83 f0 89 f7 ff    	lea    -0x87610(%ebx),%eax
f01010b7:	50                   	push   %eax
f01010b8:	6a 56                	push   $0x56
f01010ba:	8d 83 79 92 f7 ff    	lea    -0x86d87(%ebx),%eax
f01010c0:	50                   	push   %eax
f01010c1:	e8 eb ef ff ff       	call   f01000b1 <_panic>

f01010c6 <page_free>:
{
f01010c6:	55                   	push   %ebp
f01010c7:	89 e5                	mov    %esp,%ebp
f01010c9:	53                   	push   %ebx
f01010ca:	83 ec 04             	sub    $0x4,%esp
f01010cd:	e8 95 f0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01010d2:	81 c3 4e bf 08 00    	add    $0x8bf4e,%ebx
f01010d8:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref != 0 || pp->pp_link != NULL) // 还有人在使用这个page时，调用了释放函数
f01010db:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01010e0:	75 18                	jne    f01010fa <page_free+0x34>
f01010e2:	83 38 00             	cmpl   $0x0,(%eax)
f01010e5:	75 13                	jne    f01010fa <page_free+0x34>
	pp->pp_link = page_free_list;
f01010e7:	8b 8b 20 23 00 00    	mov    0x2320(%ebx),%ecx
f01010ed:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp;
f01010ef:	89 83 20 23 00 00    	mov    %eax,0x2320(%ebx)
}
f01010f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010f8:	c9                   	leave  
f01010f9:	c3                   	ret    
		panic("can't free this page, this page is in used: page_free() in pmap.c \n");
f01010fa:	83 ec 04             	sub    $0x4,%esp
f01010fd:	8d 83 18 8b f7 ff    	lea    -0x874e8(%ebx),%eax
f0101103:	50                   	push   %eax
f0101104:	68 2a 01 00 00       	push   $0x12a
f0101109:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f010110f:	50                   	push   %eax
f0101110:	e8 9c ef ff ff       	call   f01000b1 <_panic>

f0101115 <page_decref>:
{
f0101115:	55                   	push   %ebp
f0101116:	89 e5                	mov    %esp,%ebp
f0101118:	83 ec 08             	sub    $0x8,%esp
f010111b:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010111e:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101122:	83 e8 01             	sub    $0x1,%eax
f0101125:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101129:	66 85 c0             	test   %ax,%ax
f010112c:	74 02                	je     f0101130 <page_decref+0x1b>
}
f010112e:	c9                   	leave  
f010112f:	c3                   	ret    
		page_free(pp);
f0101130:	83 ec 0c             	sub    $0xc,%esp
f0101133:	52                   	push   %edx
f0101134:	e8 8d ff ff ff       	call   f01010c6 <page_free>
f0101139:	83 c4 10             	add    $0x10,%esp
}
f010113c:	eb f0                	jmp    f010112e <page_decref+0x19>

f010113e <pgdir_walk>:
{
f010113e:	55                   	push   %ebp
f010113f:	89 e5                	mov    %esp,%ebp
f0101141:	57                   	push   %edi
f0101142:	56                   	push   %esi
f0101143:	53                   	push   %ebx
f0101144:	83 ec 0c             	sub    $0xc,%esp
f0101147:	e8 1b f0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010114c:	81 c3 d4 be 08 00    	add    $0x8bed4,%ebx
f0101152:	8b 75 0c             	mov    0xc(%ebp),%esi
	pde_t *pde = &pgdir[PDX(va)]; // 先由PDX(va)得到该地址对应的目录索引，并在目录中索引得到对应条目(一个32位地址),解引用pde即可得到对应条目
f0101155:	89 f7                	mov    %esi,%edi
f0101157:	c1 ef 16             	shr    $0x16,%edi
f010115a:	c1 e7 02             	shl    $0x2,%edi
f010115d:	03 7d 08             	add    0x8(%ebp),%edi
	if (*pde && PTE_P) // 当“va”的PTE所在的页存在，该页对应的条目在目录中的值就!=0
f0101160:	8b 07                	mov    (%edi),%eax
f0101162:	85 c0                	test   %eax,%eax
f0101164:	74 45                	je     f01011ab <pgdir_walk+0x6d>
		pte_tab = (pte_t *)KADDR(PTE_ADDR(*pde)); // PTE_ADDR()获得该条目对应的页的物理地址，KADDR()把物理地址转为虚拟地址
f0101166:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010116b:	89 c2                	mov    %eax,%edx
f010116d:	c1 ea 0c             	shr    $0xc,%edx
f0101170:	c7 c1 04 00 19 f0    	mov    $0xf0190004,%ecx
f0101176:	39 11                	cmp    %edx,(%ecx)
f0101178:	76 18                	jbe    f0101192 <pgdir_walk+0x54>
		result = &pte_tab[PTX(va)];				  // 页里存的就是PTE表，用PTX(va)得到页索引，索引到对应的pte的地址
f010117a:	c1 ee 0a             	shr    $0xa,%esi
f010117d:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101183:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
}
f010118a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010118d:	5b                   	pop    %ebx
f010118e:	5e                   	pop    %esi
f010118f:	5f                   	pop    %edi
f0101190:	5d                   	pop    %ebp
f0101191:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101192:	50                   	push   %eax
f0101193:	8d 83 f0 89 f7 ff    	lea    -0x87610(%ebx),%eax
f0101199:	50                   	push   %eax
f010119a:	68 45 01 00 00       	push   $0x145
f010119f:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01011a5:	50                   	push   %eax
f01011a6:	e8 06 ef ff ff       	call   f01000b1 <_panic>
		if (!create)
f01011ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01011af:	74 6a                	je     f010121b <pgdir_walk+0xdd>
		struct PageInfo *pp = page_alloc(ALLOC_ZERO); // 分配新的一页来存储PTE表
f01011b1:	83 ec 0c             	sub    $0xc,%esp
f01011b4:	6a 01                	push   $0x1
f01011b6:	e8 7d fe ff ff       	call   f0101038 <page_alloc>
		if (!pp) // 如果pp == NULL，分配失败
f01011bb:	83 c4 10             	add    $0x10,%esp
f01011be:	85 c0                	test   %eax,%eax
f01011c0:	74 63                	je     f0101225 <pgdir_walk+0xe7>
	return (pp - pages) << PGSHIFT;
f01011c2:	c7 c1 0c 00 19 f0    	mov    $0xf019000c,%ecx
f01011c8:	89 c2                	mov    %eax,%edx
f01011ca:	2b 11                	sub    (%ecx),%edx
f01011cc:	c1 fa 03             	sar    $0x3,%edx
f01011cf:	c1 e2 0c             	shl    $0xc,%edx
		*pde = page2pa(pp) | PTE_P | PTE_W | PTE_U; // 更新目录的条目，以指向新分配的页
f01011d2:	83 ca 07             	or     $0x7,%edx
f01011d5:	89 17                	mov    %edx,(%edi)
		pp->pp_ref++;
f01011d7:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f01011dc:	2b 01                	sub    (%ecx),%eax
f01011de:	c1 f8 03             	sar    $0x3,%eax
f01011e1:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01011e4:	89 c1                	mov    %eax,%ecx
f01011e6:	c1 e9 0c             	shr    $0xc,%ecx
f01011e9:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f01011ef:	3b 0a                	cmp    (%edx),%ecx
f01011f1:	73 12                	jae    f0101205 <pgdir_walk+0xc7>
		result = &pte_tab[PTX(va)];
f01011f3:	c1 ee 0a             	shr    $0xa,%esi
f01011f6:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01011fc:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0101203:	eb 85                	jmp    f010118a <pgdir_walk+0x4c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101205:	50                   	push   %eax
f0101206:	8d 83 f0 89 f7 ff    	lea    -0x87610(%ebx),%eax
f010120c:	50                   	push   %eax
f010120d:	6a 56                	push   $0x56
f010120f:	8d 83 79 92 f7 ff    	lea    -0x86d87(%ebx),%eax
f0101215:	50                   	push   %eax
f0101216:	e8 96 ee ff ff       	call   f01000b1 <_panic>
			return NULL;
f010121b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101220:	e9 65 ff ff ff       	jmp    f010118a <pgdir_walk+0x4c>
			return NULL;
f0101225:	b8 00 00 00 00       	mov    $0x0,%eax
f010122a:	e9 5b ff ff ff       	jmp    f010118a <pgdir_walk+0x4c>

f010122f <boot_map_region>:
{
f010122f:	55                   	push   %ebp
f0101230:	89 e5                	mov    %esp,%ebp
f0101232:	57                   	push   %edi
f0101233:	56                   	push   %esi
f0101234:	53                   	push   %ebx
f0101235:	83 ec 1c             	sub    $0x1c,%esp
f0101238:	89 c7                	mov    %eax,%edi
f010123a:	89 d6                	mov    %edx,%esi
f010123c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (int i = 0; i < size; i += PGSIZE) // 以页为单位操作映射
f010123f:	bb 00 00 00 00       	mov    $0x0,%ebx
		*pte = (pa + i) | PTE_P | perm;							 // 物理地址写入PTE,完成映射
f0101244:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101247:	83 c8 01             	or     $0x1,%eax
f010124a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (int i = 0; i < size; i += PGSIZE) // 以页为单位操作映射
f010124d:	eb 25                	jmp    f0101274 <boot_map_region+0x45>
f010124f:	8d 04 33             	lea    (%ebx,%esi,1),%eax
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101252:	0f 01 38             	invlpg (%eax)
		pte_t *pte = pgdir_walk(pgdir, (const void *)va + i, 1); // 得到虚拟地址对应的pte
f0101255:	83 ec 04             	sub    $0x4,%esp
f0101258:	6a 01                	push   $0x1
f010125a:	50                   	push   %eax
f010125b:	57                   	push   %edi
f010125c:	e8 dd fe ff ff       	call   f010113e <pgdir_walk>
		*pte = (pa + i) | PTE_P | perm;							 // 物理地址写入PTE,完成映射
f0101261:	89 da                	mov    %ebx,%edx
f0101263:	03 55 08             	add    0x8(%ebp),%edx
f0101266:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101269:	89 10                	mov    %edx,(%eax)
	for (int i = 0; i < size; i += PGSIZE) // 以页为单位操作映射
f010126b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101271:	83 c4 10             	add    $0x10,%esp
f0101274:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101277:	72 d6                	jb     f010124f <boot_map_region+0x20>
}
f0101279:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010127c:	5b                   	pop    %ebx
f010127d:	5e                   	pop    %esi
f010127e:	5f                   	pop    %edi
f010127f:	5d                   	pop    %ebp
f0101280:	c3                   	ret    

f0101281 <page_lookup>:
{
f0101281:	55                   	push   %ebp
f0101282:	89 e5                	mov    %esp,%ebp
f0101284:	56                   	push   %esi
f0101285:	53                   	push   %ebx
f0101286:	e8 dc ee ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010128b:	81 c3 95 bd 08 00    	add    $0x8bd95,%ebx
f0101291:	8b 75 10             	mov    0x10(%ebp),%esi
	pte_t *pte = pgdir_walk(pgdir, va, 0); // 得到“va”的PTE的指针
f0101294:	83 ec 04             	sub    $0x4,%esp
f0101297:	6a 00                	push   $0x0
f0101299:	ff 75 0c             	pushl  0xc(%ebp)
f010129c:	ff 75 08             	pushl  0x8(%ebp)
f010129f:	e8 9a fe ff ff       	call   f010113e <pgdir_walk>
	if (pte == NULL)					   // 若PTE不存在，则“va”没有映射到对应的物理地址
f01012a4:	83 c4 10             	add    $0x10,%esp
f01012a7:	85 c0                	test   %eax,%eax
f01012a9:	74 3f                	je     f01012ea <page_lookup+0x69>
	if (pte_store)
f01012ab:	85 f6                	test   %esi,%esi
f01012ad:	74 02                	je     f01012b1 <page_lookup+0x30>
		*pte_store = pte;
f01012af:	89 06                	mov    %eax,(%esi)
f01012b1:	8b 00                	mov    (%eax),%eax
f01012b3:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012b6:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f01012bc:	39 02                	cmp    %eax,(%edx)
f01012be:	76 12                	jbe    f01012d2 <page_lookup+0x51>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01012c0:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f01012c6:	8b 12                	mov    (%edx),%edx
f01012c8:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01012cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012ce:	5b                   	pop    %ebx
f01012cf:	5e                   	pop    %esi
f01012d0:	5d                   	pop    %ebp
f01012d1:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01012d2:	83 ec 04             	sub    $0x4,%esp
f01012d5:	8d 83 5c 8b f7 ff    	lea    -0x874a4(%ebx),%eax
f01012db:	50                   	push   %eax
f01012dc:	6a 4f                	push   $0x4f
f01012de:	8d 83 79 92 f7 ff    	lea    -0x86d87(%ebx),%eax
f01012e4:	50                   	push   %eax
f01012e5:	e8 c7 ed ff ff       	call   f01000b1 <_panic>
		return NULL;
f01012ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01012ef:	eb da                	jmp    f01012cb <page_lookup+0x4a>

f01012f1 <page_remove>:
{
f01012f1:	55                   	push   %ebp
f01012f2:	89 e5                	mov    %esp,%ebp
f01012f4:	53                   	push   %ebx
f01012f5:	83 ec 18             	sub    $0x18,%esp
f01012f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store); // 得到“va”对应的页面，和指向对应的pte的指针pte_store
f01012fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01012fe:	50                   	push   %eax
f01012ff:	53                   	push   %ebx
f0101300:	ff 75 08             	pushl  0x8(%ebp)
f0101303:	e8 79 ff ff ff       	call   f0101281 <page_lookup>
	if (pp)
f0101308:	83 c4 10             	add    $0x10,%esp
f010130b:	85 c0                	test   %eax,%eax
f010130d:	74 18                	je     f0101327 <page_remove+0x36>
		page_decref(pp);
f010130f:	83 ec 0c             	sub    $0xc,%esp
f0101312:	50                   	push   %eax
f0101313:	e8 fd fd ff ff       	call   f0101115 <page_decref>
f0101318:	0f 01 3b             	invlpg (%ebx)
		*pte_store = 0;
f010131b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010131e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0101324:	83 c4 10             	add    $0x10,%esp
}
f0101327:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010132a:	c9                   	leave  
f010132b:	c3                   	ret    

f010132c <page_insert>:
{
f010132c:	55                   	push   %ebp
f010132d:	89 e5                	mov    %esp,%ebp
f010132f:	57                   	push   %edi
f0101330:	56                   	push   %esi
f0101331:	53                   	push   %ebx
f0101332:	83 ec 10             	sub    $0x10,%esp
f0101335:	e8 55 1f 00 00       	call   f010328f <__x86.get_pc_thunk.di>
f010133a:	81 c7 e6 bc 08 00    	add    $0x8bce6,%edi
f0101340:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101343:	8b 75 10             	mov    0x10(%ebp),%esi
	pte_t *pte = pgdir_walk(pgdir, va, 1); // 得到pte的指针，create=1,代表有必要会创建新的页
f0101346:	6a 01                	push   $0x1
f0101348:	56                   	push   %esi
f0101349:	ff 75 08             	pushl  0x8(%ebp)
f010134c:	e8 ed fd ff ff       	call   f010113e <pgdir_walk>
	if (pte == NULL)
f0101351:	83 c4 10             	add    $0x10,%esp
f0101354:	85 c0                	test   %eax,%eax
f0101356:	74 4f                	je     f01013a7 <page_insert+0x7b>
	pp->pp_ref++;
f0101358:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P)
f010135d:	f6 00 01             	testb  $0x1,(%eax)
f0101360:	75 34                	jne    f0101396 <page_insert+0x6a>
	boot_map_region(pgdir, (uintptr_t)va, PGSIZE, page2pa(pp), perm);
f0101362:	83 ec 08             	sub    $0x8,%esp
f0101365:	ff 75 14             	pushl  0x14(%ebp)
	return (pp - pages) << PGSHIFT;
f0101368:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f010136e:	2b 18                	sub    (%eax),%ebx
f0101370:	c1 fb 03             	sar    $0x3,%ebx
f0101373:	c1 e3 0c             	shl    $0xc,%ebx
f0101376:	53                   	push   %ebx
f0101377:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010137c:	89 f2                	mov    %esi,%edx
f010137e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101381:	e8 a9 fe ff ff       	call   f010122f <boot_map_region>
	return 0;
f0101386:	83 c4 10             	add    $0x10,%esp
f0101389:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010138e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101391:	5b                   	pop    %ebx
f0101392:	5e                   	pop    %esi
f0101393:	5f                   	pop    %edi
f0101394:	5d                   	pop    %ebp
f0101395:	c3                   	ret    
		page_remove(pgdir, va);
f0101396:	83 ec 08             	sub    $0x8,%esp
f0101399:	56                   	push   %esi
f010139a:	ff 75 08             	pushl  0x8(%ebp)
f010139d:	e8 4f ff ff ff       	call   f01012f1 <page_remove>
f01013a2:	83 c4 10             	add    $0x10,%esp
f01013a5:	eb bb                	jmp    f0101362 <page_insert+0x36>
		return -E_NO_MEM;
f01013a7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01013ac:	eb e0                	jmp    f010138e <page_insert+0x62>

f01013ae <mem_init>:
{
f01013ae:	55                   	push   %ebp
f01013af:	89 e5                	mov    %esp,%ebp
f01013b1:	57                   	push   %edi
f01013b2:	56                   	push   %esi
f01013b3:	53                   	push   %ebx
f01013b4:	83 ec 3c             	sub    $0x3c,%esp
f01013b7:	e8 4d f3 ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f01013bc:	05 64 bc 08 00       	add    $0x8bc64,%eax
f01013c1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	basemem = nvram_read(NVRAM_BASELO);
f01013c4:	b8 15 00 00 00       	mov    $0x15,%eax
f01013c9:	e8 b9 f6 ff ff       	call   f0100a87 <nvram_read>
f01013ce:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01013d0:	b8 17 00 00 00       	mov    $0x17,%eax
f01013d5:	e8 ad f6 ff ff       	call   f0100a87 <nvram_read>
f01013da:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01013dc:	b8 34 00 00 00       	mov    $0x34,%eax
f01013e1:	e8 a1 f6 ff ff       	call   f0100a87 <nvram_read>
f01013e6:	c1 e0 06             	shl    $0x6,%eax
	if (ext16mem)
f01013e9:	85 c0                	test   %eax,%eax
f01013eb:	0f 85 e3 00 00 00    	jne    f01014d4 <mem_init+0x126>
		totalmem = 1 * 1024 + extmem;
f01013f1:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01013f7:	85 f6                	test   %esi,%esi
f01013f9:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f01013fc:	89 c1                	mov    %eax,%ecx
f01013fe:	c1 e9 02             	shr    $0x2,%ecx
f0101401:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101404:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f010140a:	89 0a                	mov    %ecx,(%edx)
	npages_basemem = basemem / (PGSIZE / 1024);
f010140c:	89 da                	mov    %ebx,%edx
f010140e:	c1 ea 02             	shr    $0x2,%edx
f0101411:	89 97 24 23 00 00    	mov    %edx,0x2324(%edi)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101417:	89 c2                	mov    %eax,%edx
f0101419:	29 da                	sub    %ebx,%edx
f010141b:	52                   	push   %edx
f010141c:	53                   	push   %ebx
f010141d:	50                   	push   %eax
f010141e:	8d 87 7c 8b f7 ff    	lea    -0x87484(%edi),%eax
f0101424:	50                   	push   %eax
f0101425:	89 fb                	mov    %edi,%ebx
f0101427:	e8 6f 26 00 00       	call   f0103a9b <cprintf>
	kern_pgdir = (pde_t *)boot_alloc(PGSIZE); // 第一次运行，会舍入一部分
f010142c:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101431:	e8 87 f6 ff ff       	call   f0100abd <boot_alloc>
f0101436:	c7 c6 08 00 19 f0    	mov    $0xf0190008,%esi
f010143c:	89 06                	mov    %eax,(%esi)
	memset(kern_pgdir, 0, PGSIZE);			  // 内存初始化为0
f010143e:	83 c4 0c             	add    $0xc,%esp
f0101441:	68 00 10 00 00       	push   $0x1000
f0101446:	6a 00                	push   $0x0
f0101448:	50                   	push   %eax
f0101449:	e8 a4 3c 00 00       	call   f01050f2 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P; // 暂时不需要理解，只需要知道kern_pgdir处有一个页表目录
f010144e:	8b 06                	mov    (%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0101450:	83 c4 10             	add    $0x10,%esp
f0101453:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101458:	0f 86 80 00 00 00    	jbe    f01014de <mem_init+0x130>
	return (physaddr_t)kva - KERNBASE;
f010145e:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101464:	83 ca 05             	or     $0x5,%edx
f0101467:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *)boot_alloc(npages * sizeof(struct PageInfo)); // sizeof求得PageInfo占多少字节，返回结果记得强转成pages对应的类型
f010146d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101470:	c7 c3 04 00 19 f0    	mov    $0xf0190004,%ebx
f0101476:	8b 03                	mov    (%ebx),%eax
f0101478:	c1 e0 03             	shl    $0x3,%eax
f010147b:	e8 3d f6 ff ff       	call   f0100abd <boot_alloc>
f0101480:	c7 c6 0c 00 19 f0    	mov    $0xf019000c,%esi
f0101486:	89 06                	mov    %eax,(%esi)
	memset(pages, 0, npages * sizeof(struct PageInfo));						 // memset(d,c,l):从指针d开始，用字符c填充l个长度的内存
f0101488:	83 ec 04             	sub    $0x4,%esp
f010148b:	8b 13                	mov    (%ebx),%edx
f010148d:	c1 e2 03             	shl    $0x3,%edx
f0101490:	52                   	push   %edx
f0101491:	6a 00                	push   $0x0
f0101493:	50                   	push   %eax
f0101494:	89 fb                	mov    %edi,%ebx
f0101496:	e8 57 3c 00 00       	call   f01050f2 <memset>
	envs = (struct Env *)boot_alloc(NENV * sizeof(struct Env));
f010149b:	b8 00 80 01 00       	mov    $0x18000,%eax
f01014a0:	e8 18 f6 ff ff       	call   f0100abd <boot_alloc>
f01014a5:	c7 c2 4c f3 18 f0    	mov    $0xf018f34c,%edx
f01014ab:	89 02                	mov    %eax,(%edx)
	page_init(); // 初始化之后，所有的内存管理都将通过page_*函数进行
f01014ad:	e8 8b fa ff ff       	call   f0100f3d <page_init>
	check_page_free_list(1);
f01014b2:	b8 01 00 00 00       	mov    $0x1,%eax
f01014b7:	e8 fe f6 ff ff       	call   f0100bba <check_page_free_list>
	if (!pages)
f01014bc:	83 c4 10             	add    $0x10,%esp
f01014bf:	83 3e 00             	cmpl   $0x0,(%esi)
f01014c2:	74 36                	je     f01014fa <mem_init+0x14c>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014c4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014c7:	8b 80 20 23 00 00    	mov    0x2320(%eax),%eax
f01014cd:	be 00 00 00 00       	mov    $0x0,%esi
f01014d2:	eb 49                	jmp    f010151d <mem_init+0x16f>
		totalmem = 16 * 1024 + ext16mem;
f01014d4:	05 00 40 00 00       	add    $0x4000,%eax
f01014d9:	e9 1e ff ff ff       	jmp    f01013fc <mem_init+0x4e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01014de:	50                   	push   %eax
f01014df:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01014e2:	8d 83 f4 8a f7 ff    	lea    -0x8750c(%ebx),%eax
f01014e8:	50                   	push   %eax
f01014e9:	68 a2 00 00 00       	push   $0xa2
f01014ee:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01014f4:	50                   	push   %eax
f01014f5:	e8 b7 eb ff ff       	call   f01000b1 <_panic>
		panic("'pages' is a null pointer!");
f01014fa:	83 ec 04             	sub    $0x4,%esp
f01014fd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101500:	8d 83 23 93 f7 ff    	lea    -0x86cdd(%ebx),%eax
f0101506:	50                   	push   %eax
f0101507:	68 27 02 00 00       	push   $0x227
f010150c:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0101512:	50                   	push   %eax
f0101513:	e8 99 eb ff ff       	call   f01000b1 <_panic>
		++nfree;
f0101518:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010151b:	8b 00                	mov    (%eax),%eax
f010151d:	85 c0                	test   %eax,%eax
f010151f:	75 f7                	jne    f0101518 <mem_init+0x16a>
	assert((pp0 = page_alloc(0)));
f0101521:	83 ec 0c             	sub    $0xc,%esp
f0101524:	6a 00                	push   $0x0
f0101526:	e8 0d fb ff ff       	call   f0101038 <page_alloc>
f010152b:	89 c3                	mov    %eax,%ebx
f010152d:	83 c4 10             	add    $0x10,%esp
f0101530:	85 c0                	test   %eax,%eax
f0101532:	0f 84 3b 02 00 00    	je     f0101773 <mem_init+0x3c5>
	assert((pp1 = page_alloc(0)));
f0101538:	83 ec 0c             	sub    $0xc,%esp
f010153b:	6a 00                	push   $0x0
f010153d:	e8 f6 fa ff ff       	call   f0101038 <page_alloc>
f0101542:	89 c7                	mov    %eax,%edi
f0101544:	83 c4 10             	add    $0x10,%esp
f0101547:	85 c0                	test   %eax,%eax
f0101549:	0f 84 46 02 00 00    	je     f0101795 <mem_init+0x3e7>
	assert((pp2 = page_alloc(0)));
f010154f:	83 ec 0c             	sub    $0xc,%esp
f0101552:	6a 00                	push   $0x0
f0101554:	e8 df fa ff ff       	call   f0101038 <page_alloc>
f0101559:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010155c:	83 c4 10             	add    $0x10,%esp
f010155f:	85 c0                	test   %eax,%eax
f0101561:	0f 84 50 02 00 00    	je     f01017b7 <mem_init+0x409>
	assert(pp1 && pp1 != pp0);
f0101567:	39 fb                	cmp    %edi,%ebx
f0101569:	0f 84 6a 02 00 00    	je     f01017d9 <mem_init+0x42b>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010156f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101572:	39 c7                	cmp    %eax,%edi
f0101574:	0f 84 81 02 00 00    	je     f01017fb <mem_init+0x44d>
f010157a:	39 c3                	cmp    %eax,%ebx
f010157c:	0f 84 79 02 00 00    	je     f01017fb <mem_init+0x44d>
	return (pp - pages) << PGSHIFT;
f0101582:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101585:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f010158b:	8b 08                	mov    (%eax),%ecx
	assert(page2pa(pp0) < npages * PGSIZE);
f010158d:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f0101593:	8b 10                	mov    (%eax),%edx
f0101595:	c1 e2 0c             	shl    $0xc,%edx
f0101598:	89 d8                	mov    %ebx,%eax
f010159a:	29 c8                	sub    %ecx,%eax
f010159c:	c1 f8 03             	sar    $0x3,%eax
f010159f:	c1 e0 0c             	shl    $0xc,%eax
f01015a2:	39 d0                	cmp    %edx,%eax
f01015a4:	0f 83 73 02 00 00    	jae    f010181d <mem_init+0x46f>
f01015aa:	89 f8                	mov    %edi,%eax
f01015ac:	29 c8                	sub    %ecx,%eax
f01015ae:	c1 f8 03             	sar    $0x3,%eax
f01015b1:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages * PGSIZE);
f01015b4:	39 c2                	cmp    %eax,%edx
f01015b6:	0f 86 83 02 00 00    	jbe    f010183f <mem_init+0x491>
f01015bc:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015bf:	29 c8                	sub    %ecx,%eax
f01015c1:	c1 f8 03             	sar    $0x3,%eax
f01015c4:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages * PGSIZE);
f01015c7:	39 c2                	cmp    %eax,%edx
f01015c9:	0f 86 92 02 00 00    	jbe    f0101861 <mem_init+0x4b3>
	fl = page_free_list;
f01015cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015d2:	8b 88 20 23 00 00    	mov    0x2320(%eax),%ecx
f01015d8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f01015db:	c7 80 20 23 00 00 00 	movl   $0x0,0x2320(%eax)
f01015e2:	00 00 00 
	assert(!page_alloc(0));
f01015e5:	83 ec 0c             	sub    $0xc,%esp
f01015e8:	6a 00                	push   $0x0
f01015ea:	e8 49 fa ff ff       	call   f0101038 <page_alloc>
f01015ef:	83 c4 10             	add    $0x10,%esp
f01015f2:	85 c0                	test   %eax,%eax
f01015f4:	0f 85 89 02 00 00    	jne    f0101883 <mem_init+0x4d5>
	page_free(pp0);
f01015fa:	83 ec 0c             	sub    $0xc,%esp
f01015fd:	53                   	push   %ebx
f01015fe:	e8 c3 fa ff ff       	call   f01010c6 <page_free>
	page_free(pp1);
f0101603:	89 3c 24             	mov    %edi,(%esp)
f0101606:	e8 bb fa ff ff       	call   f01010c6 <page_free>
	page_free(pp2);
f010160b:	83 c4 04             	add    $0x4,%esp
f010160e:	ff 75 d0             	pushl  -0x30(%ebp)
f0101611:	e8 b0 fa ff ff       	call   f01010c6 <page_free>
	assert((pp0 = page_alloc(0)));
f0101616:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010161d:	e8 16 fa ff ff       	call   f0101038 <page_alloc>
f0101622:	89 c7                	mov    %eax,%edi
f0101624:	83 c4 10             	add    $0x10,%esp
f0101627:	85 c0                	test   %eax,%eax
f0101629:	0f 84 76 02 00 00    	je     f01018a5 <mem_init+0x4f7>
	assert((pp1 = page_alloc(0)));
f010162f:	83 ec 0c             	sub    $0xc,%esp
f0101632:	6a 00                	push   $0x0
f0101634:	e8 ff f9 ff ff       	call   f0101038 <page_alloc>
f0101639:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010163c:	83 c4 10             	add    $0x10,%esp
f010163f:	85 c0                	test   %eax,%eax
f0101641:	0f 84 80 02 00 00    	je     f01018c7 <mem_init+0x519>
	assert((pp2 = page_alloc(0)));
f0101647:	83 ec 0c             	sub    $0xc,%esp
f010164a:	6a 00                	push   $0x0
f010164c:	e8 e7 f9 ff ff       	call   f0101038 <page_alloc>
f0101651:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101654:	83 c4 10             	add    $0x10,%esp
f0101657:	85 c0                	test   %eax,%eax
f0101659:	0f 84 8a 02 00 00    	je     f01018e9 <mem_init+0x53b>
	assert(pp1 && pp1 != pp0);
f010165f:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f0101662:	0f 84 a3 02 00 00    	je     f010190b <mem_init+0x55d>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101668:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010166b:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010166e:	0f 84 b9 02 00 00    	je     f010192d <mem_init+0x57f>
f0101674:	39 c7                	cmp    %eax,%edi
f0101676:	0f 84 b1 02 00 00    	je     f010192d <mem_init+0x57f>
	assert(!page_alloc(0));
f010167c:	83 ec 0c             	sub    $0xc,%esp
f010167f:	6a 00                	push   $0x0
f0101681:	e8 b2 f9 ff ff       	call   f0101038 <page_alloc>
f0101686:	83 c4 10             	add    $0x10,%esp
f0101689:	85 c0                	test   %eax,%eax
f010168b:	0f 85 be 02 00 00    	jne    f010194f <mem_init+0x5a1>
f0101691:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101694:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f010169a:	89 f9                	mov    %edi,%ecx
f010169c:	2b 08                	sub    (%eax),%ecx
f010169e:	89 c8                	mov    %ecx,%eax
f01016a0:	c1 f8 03             	sar    $0x3,%eax
f01016a3:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01016a6:	89 c1                	mov    %eax,%ecx
f01016a8:	c1 e9 0c             	shr    $0xc,%ecx
f01016ab:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f01016b1:	3b 0a                	cmp    (%edx),%ecx
f01016b3:	0f 83 b8 02 00 00    	jae    f0101971 <mem_init+0x5c3>
	memset(page2kva(pp0), 1, PGSIZE);
f01016b9:	83 ec 04             	sub    $0x4,%esp
f01016bc:	68 00 10 00 00       	push   $0x1000
f01016c1:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01016c3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01016c8:	50                   	push   %eax
f01016c9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016cc:	e8 21 3a 00 00       	call   f01050f2 <memset>
	page_free(pp0);
f01016d1:	89 3c 24             	mov    %edi,(%esp)
f01016d4:	e8 ed f9 ff ff       	call   f01010c6 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01016d9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01016e0:	e8 53 f9 ff ff       	call   f0101038 <page_alloc>
f01016e5:	83 c4 10             	add    $0x10,%esp
f01016e8:	85 c0                	test   %eax,%eax
f01016ea:	0f 84 97 02 00 00    	je     f0101987 <mem_init+0x5d9>
	assert(pp && pp0 == pp);
f01016f0:	39 c7                	cmp    %eax,%edi
f01016f2:	0f 85 b1 02 00 00    	jne    f01019a9 <mem_init+0x5fb>
	return (pp - pages) << PGSHIFT;
f01016f8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016fb:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0101701:	89 fa                	mov    %edi,%edx
f0101703:	2b 10                	sub    (%eax),%edx
f0101705:	c1 fa 03             	sar    $0x3,%edx
f0101708:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010170b:	89 d1                	mov    %edx,%ecx
f010170d:	c1 e9 0c             	shr    $0xc,%ecx
f0101710:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f0101716:	3b 08                	cmp    (%eax),%ecx
f0101718:	0f 83 ad 02 00 00    	jae    f01019cb <mem_init+0x61d>
	return (void *)(pa + KERNBASE);
f010171e:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101724:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f010172a:	80 38 00             	cmpb   $0x0,(%eax)
f010172d:	0f 85 ae 02 00 00    	jne    f01019e1 <mem_init+0x633>
f0101733:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101736:	39 d0                	cmp    %edx,%eax
f0101738:	75 f0                	jne    f010172a <mem_init+0x37c>
	page_free_list = fl;
f010173a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010173d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101740:	89 8b 20 23 00 00    	mov    %ecx,0x2320(%ebx)
	page_free(pp0);
f0101746:	83 ec 0c             	sub    $0xc,%esp
f0101749:	57                   	push   %edi
f010174a:	e8 77 f9 ff ff       	call   f01010c6 <page_free>
	page_free(pp1);
f010174f:	83 c4 04             	add    $0x4,%esp
f0101752:	ff 75 d0             	pushl  -0x30(%ebp)
f0101755:	e8 6c f9 ff ff       	call   f01010c6 <page_free>
	page_free(pp2);
f010175a:	83 c4 04             	add    $0x4,%esp
f010175d:	ff 75 cc             	pushl  -0x34(%ebp)
f0101760:	e8 61 f9 ff ff       	call   f01010c6 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101765:	8b 83 20 23 00 00    	mov    0x2320(%ebx),%eax
f010176b:	83 c4 10             	add    $0x10,%esp
f010176e:	e9 95 02 00 00       	jmp    f0101a08 <mem_init+0x65a>
	assert((pp0 = page_alloc(0)));
f0101773:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101776:	8d 83 3e 93 f7 ff    	lea    -0x86cc2(%ebx),%eax
f010177c:	50                   	push   %eax
f010177d:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0101783:	50                   	push   %eax
f0101784:	68 2f 02 00 00       	push   $0x22f
f0101789:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f010178f:	50                   	push   %eax
f0101790:	e8 1c e9 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101795:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101798:	8d 83 54 93 f7 ff    	lea    -0x86cac(%ebx),%eax
f010179e:	50                   	push   %eax
f010179f:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01017a5:	50                   	push   %eax
f01017a6:	68 30 02 00 00       	push   $0x230
f01017ab:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01017b1:	50                   	push   %eax
f01017b2:	e8 fa e8 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f01017b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017ba:	8d 83 6a 93 f7 ff    	lea    -0x86c96(%ebx),%eax
f01017c0:	50                   	push   %eax
f01017c1:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01017c7:	50                   	push   %eax
f01017c8:	68 31 02 00 00       	push   $0x231
f01017cd:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01017d3:	50                   	push   %eax
f01017d4:	e8 d8 e8 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f01017d9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017dc:	8d 83 80 93 f7 ff    	lea    -0x86c80(%ebx),%eax
f01017e2:	50                   	push   %eax
f01017e3:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01017e9:	50                   	push   %eax
f01017ea:	68 34 02 00 00       	push   $0x234
f01017ef:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01017f5:	50                   	push   %eax
f01017f6:	e8 b6 e8 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017fb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017fe:	8d 83 b8 8b f7 ff    	lea    -0x87448(%ebx),%eax
f0101804:	50                   	push   %eax
f0101805:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f010180b:	50                   	push   %eax
f010180c:	68 35 02 00 00       	push   $0x235
f0101811:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0101817:	50                   	push   %eax
f0101818:	e8 94 e8 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp0) < npages * PGSIZE);
f010181d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101820:	8d 83 d8 8b f7 ff    	lea    -0x87428(%ebx),%eax
f0101826:	50                   	push   %eax
f0101827:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f010182d:	50                   	push   %eax
f010182e:	68 36 02 00 00       	push   $0x236
f0101833:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0101839:	50                   	push   %eax
f010183a:	e8 72 e8 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp1) < npages * PGSIZE);
f010183f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101842:	8d 83 f8 8b f7 ff    	lea    -0x87408(%ebx),%eax
f0101848:	50                   	push   %eax
f0101849:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f010184f:	50                   	push   %eax
f0101850:	68 37 02 00 00       	push   $0x237
f0101855:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f010185b:	50                   	push   %eax
f010185c:	e8 50 e8 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp2) < npages * PGSIZE);
f0101861:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101864:	8d 83 18 8c f7 ff    	lea    -0x873e8(%ebx),%eax
f010186a:	50                   	push   %eax
f010186b:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0101871:	50                   	push   %eax
f0101872:	68 38 02 00 00       	push   $0x238
f0101877:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f010187d:	50                   	push   %eax
f010187e:	e8 2e e8 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0101883:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101886:	8d 83 92 93 f7 ff    	lea    -0x86c6e(%ebx),%eax
f010188c:	50                   	push   %eax
f010188d:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0101893:	50                   	push   %eax
f0101894:	68 3f 02 00 00       	push   $0x23f
f0101899:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f010189f:	50                   	push   %eax
f01018a0:	e8 0c e8 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f01018a5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018a8:	8d 83 3e 93 f7 ff    	lea    -0x86cc2(%ebx),%eax
f01018ae:	50                   	push   %eax
f01018af:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01018b5:	50                   	push   %eax
f01018b6:	68 46 02 00 00       	push   $0x246
f01018bb:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01018c1:	50                   	push   %eax
f01018c2:	e8 ea e7 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f01018c7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018ca:	8d 83 54 93 f7 ff    	lea    -0x86cac(%ebx),%eax
f01018d0:	50                   	push   %eax
f01018d1:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01018d7:	50                   	push   %eax
f01018d8:	68 47 02 00 00       	push   $0x247
f01018dd:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01018e3:	50                   	push   %eax
f01018e4:	e8 c8 e7 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f01018e9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018ec:	8d 83 6a 93 f7 ff    	lea    -0x86c96(%ebx),%eax
f01018f2:	50                   	push   %eax
f01018f3:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01018f9:	50                   	push   %eax
f01018fa:	68 48 02 00 00       	push   $0x248
f01018ff:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0101905:	50                   	push   %eax
f0101906:	e8 a6 e7 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f010190b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010190e:	8d 83 80 93 f7 ff    	lea    -0x86c80(%ebx),%eax
f0101914:	50                   	push   %eax
f0101915:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f010191b:	50                   	push   %eax
f010191c:	68 4a 02 00 00       	push   $0x24a
f0101921:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0101927:	50                   	push   %eax
f0101928:	e8 84 e7 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010192d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101930:	8d 83 b8 8b f7 ff    	lea    -0x87448(%ebx),%eax
f0101936:	50                   	push   %eax
f0101937:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f010193d:	50                   	push   %eax
f010193e:	68 4b 02 00 00       	push   $0x24b
f0101943:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0101949:	50                   	push   %eax
f010194a:	e8 62 e7 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f010194f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101952:	8d 83 92 93 f7 ff    	lea    -0x86c6e(%ebx),%eax
f0101958:	50                   	push   %eax
f0101959:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f010195f:	50                   	push   %eax
f0101960:	68 4c 02 00 00       	push   $0x24c
f0101965:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f010196b:	50                   	push   %eax
f010196c:	e8 40 e7 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101971:	50                   	push   %eax
f0101972:	8d 83 f0 89 f7 ff    	lea    -0x87610(%ebx),%eax
f0101978:	50                   	push   %eax
f0101979:	6a 56                	push   $0x56
f010197b:	8d 83 79 92 f7 ff    	lea    -0x86d87(%ebx),%eax
f0101981:	50                   	push   %eax
f0101982:	e8 2a e7 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101987:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010198a:	8d 83 a1 93 f7 ff    	lea    -0x86c5f(%ebx),%eax
f0101990:	50                   	push   %eax
f0101991:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0101997:	50                   	push   %eax
f0101998:	68 51 02 00 00       	push   $0x251
f010199d:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01019a3:	50                   	push   %eax
f01019a4:	e8 08 e7 ff ff       	call   f01000b1 <_panic>
	assert(pp && pp0 == pp);
f01019a9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01019ac:	8d 83 bf 93 f7 ff    	lea    -0x86c41(%ebx),%eax
f01019b2:	50                   	push   %eax
f01019b3:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01019b9:	50                   	push   %eax
f01019ba:	68 52 02 00 00       	push   $0x252
f01019bf:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01019c5:	50                   	push   %eax
f01019c6:	e8 e6 e6 ff ff       	call   f01000b1 <_panic>
f01019cb:	52                   	push   %edx
f01019cc:	8d 83 f0 89 f7 ff    	lea    -0x87610(%ebx),%eax
f01019d2:	50                   	push   %eax
f01019d3:	6a 56                	push   $0x56
f01019d5:	8d 83 79 92 f7 ff    	lea    -0x86d87(%ebx),%eax
f01019db:	50                   	push   %eax
f01019dc:	e8 d0 e6 ff ff       	call   f01000b1 <_panic>
		assert(c[i] == 0);
f01019e1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01019e4:	8d 83 cf 93 f7 ff    	lea    -0x86c31(%ebx),%eax
f01019ea:	50                   	push   %eax
f01019eb:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01019f1:	50                   	push   %eax
f01019f2:	68 55 02 00 00       	push   $0x255
f01019f7:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01019fd:	50                   	push   %eax
f01019fe:	e8 ae e6 ff ff       	call   f01000b1 <_panic>
		--nfree;
f0101a03:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a06:	8b 00                	mov    (%eax),%eax
f0101a08:	85 c0                	test   %eax,%eax
f0101a0a:	75 f7                	jne    f0101a03 <mem_init+0x655>
	assert(nfree == 0);
f0101a0c:	85 f6                	test   %esi,%esi
f0101a0e:	0f 85 65 08 00 00    	jne    f0102279 <mem_init+0xecb>
	cprintf("check_page_alloc() succeeded!\n");
f0101a14:	83 ec 0c             	sub    $0xc,%esp
f0101a17:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a1a:	8d 83 38 8c f7 ff    	lea    -0x873c8(%ebx),%eax
f0101a20:	50                   	push   %eax
f0101a21:	e8 75 20 00 00       	call   f0103a9b <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a26:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a2d:	e8 06 f6 ff ff       	call   f0101038 <page_alloc>
f0101a32:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101a35:	83 c4 10             	add    $0x10,%esp
f0101a38:	85 c0                	test   %eax,%eax
f0101a3a:	0f 84 5b 08 00 00    	je     f010229b <mem_init+0xeed>
	assert((pp1 = page_alloc(0)));
f0101a40:	83 ec 0c             	sub    $0xc,%esp
f0101a43:	6a 00                	push   $0x0
f0101a45:	e8 ee f5 ff ff       	call   f0101038 <page_alloc>
f0101a4a:	89 c7                	mov    %eax,%edi
f0101a4c:	83 c4 10             	add    $0x10,%esp
f0101a4f:	85 c0                	test   %eax,%eax
f0101a51:	0f 84 66 08 00 00    	je     f01022bd <mem_init+0xf0f>
	assert((pp2 = page_alloc(0)));
f0101a57:	83 ec 0c             	sub    $0xc,%esp
f0101a5a:	6a 00                	push   $0x0
f0101a5c:	e8 d7 f5 ff ff       	call   f0101038 <page_alloc>
f0101a61:	89 c6                	mov    %eax,%esi
f0101a63:	83 c4 10             	add    $0x10,%esp
f0101a66:	85 c0                	test   %eax,%eax
f0101a68:	0f 84 71 08 00 00    	je     f01022df <mem_init+0xf31>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a6e:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0101a71:	0f 84 8a 08 00 00    	je     f0102301 <mem_init+0xf53>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a77:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101a7a:	0f 84 a3 08 00 00    	je     f0102323 <mem_init+0xf75>
f0101a80:	39 c7                	cmp    %eax,%edi
f0101a82:	0f 84 9b 08 00 00    	je     f0102323 <mem_init+0xf75>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a88:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a8b:	8b 88 20 23 00 00    	mov    0x2320(%eax),%ecx
f0101a91:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101a94:	c7 80 20 23 00 00 00 	movl   $0x0,0x2320(%eax)
f0101a9b:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a9e:	83 ec 0c             	sub    $0xc,%esp
f0101aa1:	6a 00                	push   $0x0
f0101aa3:	e8 90 f5 ff ff       	call   f0101038 <page_alloc>
f0101aa8:	83 c4 10             	add    $0x10,%esp
f0101aab:	85 c0                	test   %eax,%eax
f0101aad:	0f 85 92 08 00 00    	jne    f0102345 <mem_init+0xf97>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *)0x0, &ptep) == NULL);
f0101ab3:	83 ec 04             	sub    $0x4,%esp
f0101ab6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ab9:	50                   	push   %eax
f0101aba:	6a 00                	push   $0x0
f0101abc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101abf:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101ac5:	ff 30                	pushl  (%eax)
f0101ac7:	e8 b5 f7 ff ff       	call   f0101281 <page_lookup>
f0101acc:	83 c4 10             	add    $0x10,%esp
f0101acf:	85 c0                	test   %eax,%eax
f0101ad1:	0f 85 90 08 00 00    	jne    f0102367 <mem_init+0xfb9>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101ad7:	6a 02                	push   $0x2
f0101ad9:	6a 00                	push   $0x0
f0101adb:	57                   	push   %edi
f0101adc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101adf:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101ae5:	ff 30                	pushl  (%eax)
f0101ae7:	e8 40 f8 ff ff       	call   f010132c <page_insert>
f0101aec:	83 c4 10             	add    $0x10,%esp
f0101aef:	85 c0                	test   %eax,%eax
f0101af1:	0f 89 92 08 00 00    	jns    f0102389 <mem_init+0xfdb>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101af7:	83 ec 0c             	sub    $0xc,%esp
f0101afa:	ff 75 d0             	pushl  -0x30(%ebp)
f0101afd:	e8 c4 f5 ff ff       	call   f01010c6 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b02:	6a 02                	push   $0x2
f0101b04:	6a 00                	push   $0x0
f0101b06:	57                   	push   %edi
f0101b07:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b0a:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101b10:	ff 30                	pushl  (%eax)
f0101b12:	e8 15 f8 ff ff       	call   f010132c <page_insert>
f0101b17:	83 c4 20             	add    $0x20,%esp
f0101b1a:	85 c0                	test   %eax,%eax
f0101b1c:	0f 85 89 08 00 00    	jne    f01023ab <mem_init+0xffd>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b22:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101b25:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101b2b:	8b 18                	mov    (%eax),%ebx
	return (pp - pages) << PGSHIFT;
f0101b2d:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0101b33:	8b 08                	mov    (%eax),%ecx
f0101b35:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0101b38:	8b 13                	mov    (%ebx),%edx
f0101b3a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b40:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b43:	29 c8                	sub    %ecx,%eax
f0101b45:	c1 f8 03             	sar    $0x3,%eax
f0101b48:	c1 e0 0c             	shl    $0xc,%eax
f0101b4b:	39 c2                	cmp    %eax,%edx
f0101b4d:	0f 85 7a 08 00 00    	jne    f01023cd <mem_init+0x101f>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b53:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b58:	89 d8                	mov    %ebx,%eax
f0101b5a:	e8 de ef ff ff       	call   f0100b3d <check_va2pa>
f0101b5f:	89 fa                	mov    %edi,%edx
f0101b61:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101b64:	c1 fa 03             	sar    $0x3,%edx
f0101b67:	c1 e2 0c             	shl    $0xc,%edx
f0101b6a:	39 d0                	cmp    %edx,%eax
f0101b6c:	0f 85 7d 08 00 00    	jne    f01023ef <mem_init+0x1041>
	assert(pp1->pp_ref == 1);
f0101b72:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101b77:	0f 85 94 08 00 00    	jne    f0102411 <mem_init+0x1063>
	assert(pp0->pp_ref == 1);
f0101b7d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b80:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b85:	0f 85 a8 08 00 00    	jne    f0102433 <mem_init+0x1085>
	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101b8b:	6a 02                	push   $0x2
f0101b8d:	68 00 10 00 00       	push   $0x1000
f0101b92:	56                   	push   %esi
f0101b93:	53                   	push   %ebx
f0101b94:	e8 93 f7 ff ff       	call   f010132c <page_insert>
f0101b99:	83 c4 10             	add    $0x10,%esp
f0101b9c:	85 c0                	test   %eax,%eax
f0101b9e:	0f 85 b1 08 00 00    	jne    f0102455 <mem_init+0x10a7>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ba4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ba9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101bac:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101bb2:	8b 00                	mov    (%eax),%eax
f0101bb4:	e8 84 ef ff ff       	call   f0100b3d <check_va2pa>
f0101bb9:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f0101bbf:	89 f1                	mov    %esi,%ecx
f0101bc1:	2b 0a                	sub    (%edx),%ecx
f0101bc3:	89 ca                	mov    %ecx,%edx
f0101bc5:	c1 fa 03             	sar    $0x3,%edx
f0101bc8:	c1 e2 0c             	shl    $0xc,%edx
f0101bcb:	39 d0                	cmp    %edx,%eax
f0101bcd:	0f 85 a4 08 00 00    	jne    f0102477 <mem_init+0x10c9>
	assert(pp2->pp_ref == 1);
f0101bd3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101bd8:	0f 85 bb 08 00 00    	jne    f0102499 <mem_init+0x10eb>

	// should be no free memory
	assert(!page_alloc(0));
f0101bde:	83 ec 0c             	sub    $0xc,%esp
f0101be1:	6a 00                	push   $0x0
f0101be3:	e8 50 f4 ff ff       	call   f0101038 <page_alloc>
f0101be8:	83 c4 10             	add    $0x10,%esp
f0101beb:	85 c0                	test   %eax,%eax
f0101bed:	0f 85 c8 08 00 00    	jne    f01024bb <mem_init+0x110d>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101bf3:	6a 02                	push   $0x2
f0101bf5:	68 00 10 00 00       	push   $0x1000
f0101bfa:	56                   	push   %esi
f0101bfb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bfe:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101c04:	ff 30                	pushl  (%eax)
f0101c06:	e8 21 f7 ff ff       	call   f010132c <page_insert>
f0101c0b:	83 c4 10             	add    $0x10,%esp
f0101c0e:	85 c0                	test   %eax,%eax
f0101c10:	0f 85 c7 08 00 00    	jne    f01024dd <mem_init+0x112f>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c16:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c1b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101c1e:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101c24:	8b 00                	mov    (%eax),%eax
f0101c26:	e8 12 ef ff ff       	call   f0100b3d <check_va2pa>
f0101c2b:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f0101c31:	89 f1                	mov    %esi,%ecx
f0101c33:	2b 0a                	sub    (%edx),%ecx
f0101c35:	89 ca                	mov    %ecx,%edx
f0101c37:	c1 fa 03             	sar    $0x3,%edx
f0101c3a:	c1 e2 0c             	shl    $0xc,%edx
f0101c3d:	39 d0                	cmp    %edx,%eax
f0101c3f:	0f 85 ba 08 00 00    	jne    f01024ff <mem_init+0x1151>
	assert(pp2->pp_ref == 1);
f0101c45:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c4a:	0f 85 d1 08 00 00    	jne    f0102521 <mem_init+0x1173>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c50:	83 ec 0c             	sub    $0xc,%esp
f0101c53:	6a 00                	push   $0x0
f0101c55:	e8 de f3 ff ff       	call   f0101038 <page_alloc>
f0101c5a:	83 c4 10             	add    $0x10,%esp
f0101c5d:	85 c0                	test   %eax,%eax
f0101c5f:	0f 85 de 08 00 00    	jne    f0102543 <mem_init+0x1195>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c65:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101c68:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101c6e:	8b 10                	mov    (%eax),%edx
f0101c70:	8b 02                	mov    (%edx),%eax
f0101c72:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101c77:	89 c3                	mov    %eax,%ebx
f0101c79:	c1 eb 0c             	shr    $0xc,%ebx
f0101c7c:	c7 c1 04 00 19 f0    	mov    $0xf0190004,%ecx
f0101c82:	3b 19                	cmp    (%ecx),%ebx
f0101c84:	0f 83 db 08 00 00    	jae    f0102565 <mem_init+0x11b7>
	return (void *)(pa + KERNBASE);
f0101c8a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c8f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
f0101c92:	83 ec 04             	sub    $0x4,%esp
f0101c95:	6a 00                	push   $0x0
f0101c97:	68 00 10 00 00       	push   $0x1000
f0101c9c:	52                   	push   %edx
f0101c9d:	e8 9c f4 ff ff       	call   f010113e <pgdir_walk>
f0101ca2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101ca5:	8d 51 04             	lea    0x4(%ecx),%edx
f0101ca8:	83 c4 10             	add    $0x10,%esp
f0101cab:	39 d0                	cmp    %edx,%eax
f0101cad:	0f 85 ce 08 00 00    	jne    f0102581 <mem_init+0x11d3>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W | PTE_U) == 0);
f0101cb3:	6a 06                	push   $0x6
f0101cb5:	68 00 10 00 00       	push   $0x1000
f0101cba:	56                   	push   %esi
f0101cbb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cbe:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101cc4:	ff 30                	pushl  (%eax)
f0101cc6:	e8 61 f6 ff ff       	call   f010132c <page_insert>
f0101ccb:	83 c4 10             	add    $0x10,%esp
f0101cce:	85 c0                	test   %eax,%eax
f0101cd0:	0f 85 cd 08 00 00    	jne    f01025a3 <mem_init+0x11f5>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101cd6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cd9:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101cdf:	8b 18                	mov    (%eax),%ebx
f0101ce1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ce6:	89 d8                	mov    %ebx,%eax
f0101ce8:	e8 50 ee ff ff       	call   f0100b3d <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101ced:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101cf0:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f0101cf6:	89 f1                	mov    %esi,%ecx
f0101cf8:	2b 0a                	sub    (%edx),%ecx
f0101cfa:	89 ca                	mov    %ecx,%edx
f0101cfc:	c1 fa 03             	sar    $0x3,%edx
f0101cff:	c1 e2 0c             	shl    $0xc,%edx
f0101d02:	39 d0                	cmp    %edx,%eax
f0101d04:	0f 85 bb 08 00 00    	jne    f01025c5 <mem_init+0x1217>
	assert(pp2->pp_ref == 1);
f0101d0a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d0f:	0f 85 d2 08 00 00    	jne    f01025e7 <mem_init+0x1239>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U);
f0101d15:	83 ec 04             	sub    $0x4,%esp
f0101d18:	6a 00                	push   $0x0
f0101d1a:	68 00 10 00 00       	push   $0x1000
f0101d1f:	53                   	push   %ebx
f0101d20:	e8 19 f4 ff ff       	call   f010113e <pgdir_walk>
f0101d25:	83 c4 10             	add    $0x10,%esp
f0101d28:	f6 00 04             	testb  $0x4,(%eax)
f0101d2b:	0f 84 d8 08 00 00    	je     f0102609 <mem_init+0x125b>
	assert(kern_pgdir[0] & PTE_U);
f0101d31:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d34:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101d3a:	8b 00                	mov    (%eax),%eax
f0101d3c:	f6 00 04             	testb  $0x4,(%eax)
f0101d3f:	0f 84 e6 08 00 00    	je     f010262b <mem_init+0x127d>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101d45:	6a 02                	push   $0x2
f0101d47:	68 00 10 00 00       	push   $0x1000
f0101d4c:	56                   	push   %esi
f0101d4d:	50                   	push   %eax
f0101d4e:	e8 d9 f5 ff ff       	call   f010132c <page_insert>
f0101d53:	83 c4 10             	add    $0x10,%esp
f0101d56:	85 c0                	test   %eax,%eax
f0101d58:	0f 85 ef 08 00 00    	jne    f010264d <mem_init+0x129f>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_W);
f0101d5e:	83 ec 04             	sub    $0x4,%esp
f0101d61:	6a 00                	push   $0x0
f0101d63:	68 00 10 00 00       	push   $0x1000
f0101d68:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d6b:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101d71:	ff 30                	pushl  (%eax)
f0101d73:	e8 c6 f3 ff ff       	call   f010113e <pgdir_walk>
f0101d78:	83 c4 10             	add    $0x10,%esp
f0101d7b:	f6 00 02             	testb  $0x2,(%eax)
f0101d7e:	0f 84 eb 08 00 00    	je     f010266f <mem_init+0x12c1>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0101d84:	83 ec 04             	sub    $0x4,%esp
f0101d87:	6a 00                	push   $0x0
f0101d89:	68 00 10 00 00       	push   $0x1000
f0101d8e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d91:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101d97:	ff 30                	pushl  (%eax)
f0101d99:	e8 a0 f3 ff ff       	call   f010113e <pgdir_walk>
f0101d9e:	83 c4 10             	add    $0x10,%esp
f0101da1:	f6 00 04             	testb  $0x4,(%eax)
f0101da4:	0f 85 e7 08 00 00    	jne    f0102691 <mem_init+0x12e3>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void *)PTSIZE, PTE_W) < 0);
f0101daa:	6a 02                	push   $0x2
f0101dac:	68 00 00 40 00       	push   $0x400000
f0101db1:	ff 75 d0             	pushl  -0x30(%ebp)
f0101db4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101db7:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101dbd:	ff 30                	pushl  (%eax)
f0101dbf:	e8 68 f5 ff ff       	call   f010132c <page_insert>
f0101dc4:	83 c4 10             	add    $0x10,%esp
f0101dc7:	85 c0                	test   %eax,%eax
f0101dc9:	0f 89 e4 08 00 00    	jns    f01026b3 <mem_init+0x1305>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W) == 0);
f0101dcf:	6a 02                	push   $0x2
f0101dd1:	68 00 10 00 00       	push   $0x1000
f0101dd6:	57                   	push   %edi
f0101dd7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dda:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101de0:	ff 30                	pushl  (%eax)
f0101de2:	e8 45 f5 ff ff       	call   f010132c <page_insert>
f0101de7:	83 c4 10             	add    $0x10,%esp
f0101dea:	85 c0                	test   %eax,%eax
f0101dec:	0f 85 e3 08 00 00    	jne    f01026d5 <mem_init+0x1327>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0101df2:	83 ec 04             	sub    $0x4,%esp
f0101df5:	6a 00                	push   $0x0
f0101df7:	68 00 10 00 00       	push   $0x1000
f0101dfc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dff:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101e05:	ff 30                	pushl  (%eax)
f0101e07:	e8 32 f3 ff ff       	call   f010113e <pgdir_walk>
f0101e0c:	83 c4 10             	add    $0x10,%esp
f0101e0f:	f6 00 04             	testb  $0x4,(%eax)
f0101e12:	0f 85 df 08 00 00    	jne    f01026f7 <mem_init+0x1349>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e18:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e1b:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101e21:	8b 18                	mov    (%eax),%ebx
f0101e23:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e28:	89 d8                	mov    %ebx,%eax
f0101e2a:	e8 0e ed ff ff       	call   f0100b3d <check_va2pa>
f0101e2f:	89 c2                	mov    %eax,%edx
f0101e31:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e34:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e37:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0101e3d:	89 f9                	mov    %edi,%ecx
f0101e3f:	2b 08                	sub    (%eax),%ecx
f0101e41:	89 c8                	mov    %ecx,%eax
f0101e43:	c1 f8 03             	sar    $0x3,%eax
f0101e46:	c1 e0 0c             	shl    $0xc,%eax
f0101e49:	39 c2                	cmp    %eax,%edx
f0101e4b:	0f 85 c8 08 00 00    	jne    f0102719 <mem_init+0x136b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e51:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e56:	89 d8                	mov    %ebx,%eax
f0101e58:	e8 e0 ec ff ff       	call   f0100b3d <check_va2pa>
f0101e5d:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101e60:	0f 85 d5 08 00 00    	jne    f010273b <mem_init+0x138d>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101e66:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101e6b:	0f 85 ec 08 00 00    	jne    f010275d <mem_init+0x13af>
	assert(pp2->pp_ref == 0);
f0101e71:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e76:	0f 85 03 09 00 00    	jne    f010277f <mem_init+0x13d1>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101e7c:	83 ec 0c             	sub    $0xc,%esp
f0101e7f:	6a 00                	push   $0x0
f0101e81:	e8 b2 f1 ff ff       	call   f0101038 <page_alloc>
f0101e86:	83 c4 10             	add    $0x10,%esp
f0101e89:	39 c6                	cmp    %eax,%esi
f0101e8b:	0f 85 10 09 00 00    	jne    f01027a1 <mem_init+0x13f3>
f0101e91:	85 c0                	test   %eax,%eax
f0101e93:	0f 84 08 09 00 00    	je     f01027a1 <mem_init+0x13f3>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101e99:	83 ec 08             	sub    $0x8,%esp
f0101e9c:	6a 00                	push   $0x0
f0101e9e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ea1:	c7 c3 08 00 19 f0    	mov    $0xf0190008,%ebx
f0101ea7:	ff 33                	pushl  (%ebx)
f0101ea9:	e8 43 f4 ff ff       	call   f01012f1 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101eae:	8b 1b                	mov    (%ebx),%ebx
f0101eb0:	ba 00 00 00 00       	mov    $0x0,%edx
f0101eb5:	89 d8                	mov    %ebx,%eax
f0101eb7:	e8 81 ec ff ff       	call   f0100b3d <check_va2pa>
f0101ebc:	83 c4 10             	add    $0x10,%esp
f0101ebf:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ec2:	0f 85 fb 08 00 00    	jne    f01027c3 <mem_init+0x1415>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ec8:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ecd:	89 d8                	mov    %ebx,%eax
f0101ecf:	e8 69 ec ff ff       	call   f0100b3d <check_va2pa>
f0101ed4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101ed7:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f0101edd:	89 f9                	mov    %edi,%ecx
f0101edf:	2b 0a                	sub    (%edx),%ecx
f0101ee1:	89 ca                	mov    %ecx,%edx
f0101ee3:	c1 fa 03             	sar    $0x3,%edx
f0101ee6:	c1 e2 0c             	shl    $0xc,%edx
f0101ee9:	39 d0                	cmp    %edx,%eax
f0101eeb:	0f 85 f4 08 00 00    	jne    f01027e5 <mem_init+0x1437>
	assert(pp1->pp_ref == 1);
f0101ef1:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ef6:	0f 85 0b 09 00 00    	jne    f0102807 <mem_init+0x1459>
	assert(pp2->pp_ref == 0);
f0101efc:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f01:	0f 85 22 09 00 00    	jne    f0102829 <mem_init+0x147b>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, 0) == 0);
f0101f07:	6a 00                	push   $0x0
f0101f09:	68 00 10 00 00       	push   $0x1000
f0101f0e:	57                   	push   %edi
f0101f0f:	53                   	push   %ebx
f0101f10:	e8 17 f4 ff ff       	call   f010132c <page_insert>
f0101f15:	83 c4 10             	add    $0x10,%esp
f0101f18:	85 c0                	test   %eax,%eax
f0101f1a:	0f 85 2b 09 00 00    	jne    f010284b <mem_init+0x149d>
	assert(pp1->pp_ref);
f0101f20:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101f25:	0f 84 42 09 00 00    	je     f010286d <mem_init+0x14bf>
	assert(pp1->pp_link == NULL);
f0101f2b:	83 3f 00             	cmpl   $0x0,(%edi)
f0101f2e:	0f 85 5b 09 00 00    	jne    f010288f <mem_init+0x14e1>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void *)PGSIZE);
f0101f34:	83 ec 08             	sub    $0x8,%esp
f0101f37:	68 00 10 00 00       	push   $0x1000
f0101f3c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f3f:	c7 c3 08 00 19 f0    	mov    $0xf0190008,%ebx
f0101f45:	ff 33                	pushl  (%ebx)
f0101f47:	e8 a5 f3 ff ff       	call   f01012f1 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f4c:	8b 1b                	mov    (%ebx),%ebx
f0101f4e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f53:	89 d8                	mov    %ebx,%eax
f0101f55:	e8 e3 eb ff ff       	call   f0100b3d <check_va2pa>
f0101f5a:	83 c4 10             	add    $0x10,%esp
f0101f5d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f60:	0f 85 4b 09 00 00    	jne    f01028b1 <mem_init+0x1503>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101f66:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f6b:	89 d8                	mov    %ebx,%eax
f0101f6d:	e8 cb eb ff ff       	call   f0100b3d <check_va2pa>
f0101f72:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f75:	0f 85 58 09 00 00    	jne    f01028d3 <mem_init+0x1525>
	assert(pp1->pp_ref == 0);
f0101f7b:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101f80:	0f 85 6f 09 00 00    	jne    f01028f5 <mem_init+0x1547>
	assert(pp2->pp_ref == 0);
f0101f86:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f8b:	0f 85 86 09 00 00    	jne    f0102917 <mem_init+0x1569>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101f91:	83 ec 0c             	sub    $0xc,%esp
f0101f94:	6a 00                	push   $0x0
f0101f96:	e8 9d f0 ff ff       	call   f0101038 <page_alloc>
f0101f9b:	83 c4 10             	add    $0x10,%esp
f0101f9e:	85 c0                	test   %eax,%eax
f0101fa0:	0f 84 93 09 00 00    	je     f0102939 <mem_init+0x158b>
f0101fa6:	39 c7                	cmp    %eax,%edi
f0101fa8:	0f 85 8b 09 00 00    	jne    f0102939 <mem_init+0x158b>

	// should be no free memory
	assert(!page_alloc(0));
f0101fae:	83 ec 0c             	sub    $0xc,%esp
f0101fb1:	6a 00                	push   $0x0
f0101fb3:	e8 80 f0 ff ff       	call   f0101038 <page_alloc>
f0101fb8:	83 c4 10             	add    $0x10,%esp
f0101fbb:	85 c0                	test   %eax,%eax
f0101fbd:	0f 85 98 09 00 00    	jne    f010295b <mem_init+0x15ad>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101fc3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fc6:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0101fcc:	8b 08                	mov    (%eax),%ecx
f0101fce:	8b 11                	mov    (%ecx),%edx
f0101fd0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101fd6:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0101fdc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0101fdf:	2b 18                	sub    (%eax),%ebx
f0101fe1:	89 d8                	mov    %ebx,%eax
f0101fe3:	c1 f8 03             	sar    $0x3,%eax
f0101fe6:	c1 e0 0c             	shl    $0xc,%eax
f0101fe9:	39 c2                	cmp    %eax,%edx
f0101feb:	0f 85 8c 09 00 00    	jne    f010297d <mem_init+0x15cf>
	kern_pgdir[0] = 0;
f0101ff1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101ff7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101ffa:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101fff:	0f 85 9a 09 00 00    	jne    f010299f <mem_init+0x15f1>
	pp0->pp_ref = 0;
f0102005:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102008:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010200e:	83 ec 0c             	sub    $0xc,%esp
f0102011:	50                   	push   %eax
f0102012:	e8 af f0 ff ff       	call   f01010c6 <page_free>
	va = (void *)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102017:	83 c4 0c             	add    $0xc,%esp
f010201a:	6a 01                	push   $0x1
f010201c:	68 00 10 40 00       	push   $0x401000
f0102021:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102024:	c7 c3 08 00 19 f0    	mov    $0xf0190008,%ebx
f010202a:	ff 33                	pushl  (%ebx)
f010202c:	e8 0d f1 ff ff       	call   f010113e <pgdir_walk>
f0102031:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102034:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102037:	8b 1b                	mov    (%ebx),%ebx
f0102039:	8b 53 04             	mov    0x4(%ebx),%edx
f010203c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0102042:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102045:	c7 c1 04 00 19 f0    	mov    $0xf0190004,%ecx
f010204b:	8b 09                	mov    (%ecx),%ecx
f010204d:	89 d0                	mov    %edx,%eax
f010204f:	c1 e8 0c             	shr    $0xc,%eax
f0102052:	83 c4 10             	add    $0x10,%esp
f0102055:	39 c8                	cmp    %ecx,%eax
f0102057:	0f 83 64 09 00 00    	jae    f01029c1 <mem_init+0x1613>
	assert(ptep == ptep1 + PTX(va));
f010205d:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102063:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0102066:	0f 85 71 09 00 00    	jne    f01029dd <mem_init+0x162f>
	kern_pgdir[PDX(va)] = 0;
f010206c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f0102073:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102076:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	return (pp - pages) << PGSHIFT;
f010207c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010207f:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0102085:	2b 18                	sub    (%eax),%ebx
f0102087:	89 d8                	mov    %ebx,%eax
f0102089:	c1 f8 03             	sar    $0x3,%eax
f010208c:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010208f:	89 c2                	mov    %eax,%edx
f0102091:	c1 ea 0c             	shr    $0xc,%edx
f0102094:	39 d1                	cmp    %edx,%ecx
f0102096:	0f 86 63 09 00 00    	jbe    f01029ff <mem_init+0x1651>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010209c:	83 ec 04             	sub    $0x4,%esp
f010209f:	68 00 10 00 00       	push   $0x1000
f01020a4:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01020a9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01020ae:	50                   	push   %eax
f01020af:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020b2:	e8 3b 30 00 00       	call   f01050f2 <memset>
	page_free(pp0);
f01020b7:	83 c4 04             	add    $0x4,%esp
f01020ba:	ff 75 d0             	pushl  -0x30(%ebp)
f01020bd:	e8 04 f0 ff ff       	call   f01010c6 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01020c2:	83 c4 0c             	add    $0xc,%esp
f01020c5:	6a 01                	push   $0x1
f01020c7:	6a 00                	push   $0x0
f01020c9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020cc:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f01020d2:	ff 30                	pushl  (%eax)
f01020d4:	e8 65 f0 ff ff       	call   f010113e <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f01020d9:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f01020df:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01020e2:	2b 10                	sub    (%eax),%edx
f01020e4:	c1 fa 03             	sar    $0x3,%edx
f01020e7:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01020ea:	89 d1                	mov    %edx,%ecx
f01020ec:	c1 e9 0c             	shr    $0xc,%ecx
f01020ef:	83 c4 10             	add    $0x10,%esp
f01020f2:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f01020f8:	3b 08                	cmp    (%eax),%ecx
f01020fa:	0f 83 18 09 00 00    	jae    f0102a18 <mem_init+0x166a>
	return (void *)(pa + KERNBASE);
f0102100:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *)page2kva(pp0);
f0102106:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102109:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for (i = 0; i < NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010210f:	f6 00 01             	testb  $0x1,(%eax)
f0102112:	0f 85 19 09 00 00    	jne    f0102a31 <mem_init+0x1683>
f0102118:	83 c0 04             	add    $0x4,%eax
	for (i = 0; i < NPTENTRIES; i++)
f010211b:	39 d0                	cmp    %edx,%eax
f010211d:	75 f0                	jne    f010210f <mem_init+0xd61>
	kern_pgdir[0] = 0;
f010211f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102122:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0102128:	8b 00                	mov    (%eax),%eax
f010212a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102130:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102133:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102139:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010213c:	89 93 20 23 00 00    	mov    %edx,0x2320(%ebx)

	// free the pages we took
	page_free(pp0);
f0102142:	83 ec 0c             	sub    $0xc,%esp
f0102145:	50                   	push   %eax
f0102146:	e8 7b ef ff ff       	call   f01010c6 <page_free>
	page_free(pp1);
f010214b:	89 3c 24             	mov    %edi,(%esp)
f010214e:	e8 73 ef ff ff       	call   f01010c6 <page_free>
	page_free(pp2);
f0102153:	89 34 24             	mov    %esi,(%esp)
f0102156:	e8 6b ef ff ff       	call   f01010c6 <page_free>

	cprintf("check_page() succeeded!\n");
f010215b:	8d 83 b0 94 f7 ff    	lea    -0x86b50(%ebx),%eax
f0102161:	89 04 24             	mov    %eax,(%esp)
f0102164:	e8 32 19 00 00       	call   f0103a9b <cprintf>
	boot_map_region(kern_pgdir, UPAGES, npages * sizeof(struct PageInfo), PADDR(pages), PTE_U);
f0102169:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f010216f:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102171:	83 c4 10             	add    $0x10,%esp
f0102174:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102179:	0f 86 d4 08 00 00    	jbe    f0102a53 <mem_init+0x16a5>
f010217f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102182:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f0102188:	8b 0a                	mov    (%edx),%ecx
f010218a:	c1 e1 03             	shl    $0x3,%ecx
f010218d:	83 ec 08             	sub    $0x8,%esp
f0102190:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102192:	05 00 00 00 10       	add    $0x10000000,%eax
f0102197:	50                   	push   %eax
f0102198:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010219d:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f01021a3:	8b 00                	mov    (%eax),%eax
f01021a5:	e8 85 f0 ff ff       	call   f010122f <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, NENV * sizeof(struct Env), PADDR(envs), PTE_U);
f01021aa:	c7 c0 4c f3 18 f0    	mov    $0xf018f34c,%eax
f01021b0:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01021b2:	83 c4 10             	add    $0x10,%esp
f01021b5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021ba:	0f 86 af 08 00 00    	jbe    f0102a6f <mem_init+0x16c1>
f01021c0:	83 ec 08             	sub    $0x8,%esp
f01021c3:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f01021c5:	05 00 00 00 10       	add    $0x10000000,%eax
f01021ca:	50                   	push   %eax
f01021cb:	b9 00 80 01 00       	mov    $0x18000,%ecx
f01021d0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01021d5:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01021d8:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f01021de:	8b 00                	mov    (%eax),%eax
f01021e0:	e8 4a f0 ff ff       	call   f010122f <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01021e5:	c7 c0 00 30 11 f0    	mov    $0xf0113000,%eax
f01021eb:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01021ee:	83 c4 10             	add    $0x10,%esp
f01021f1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021f6:	0f 86 8f 08 00 00    	jbe    f0102a8b <mem_init+0x16dd>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01021fc:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01021ff:	c7 c3 08 00 19 f0    	mov    $0xf0190008,%ebx
f0102205:	83 ec 08             	sub    $0x8,%esp
f0102208:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f010220a:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010220d:	05 00 00 00 10       	add    $0x10000000,%eax
f0102212:	50                   	push   %eax
f0102213:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102218:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010221d:	8b 03                	mov    (%ebx),%eax
f010221f:	e8 0b f0 ff ff       	call   f010122f <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_W);
f0102224:	83 c4 08             	add    $0x8,%esp
f0102227:	6a 02                	push   $0x2
f0102229:	6a 00                	push   $0x0
f010222b:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102230:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102235:	8b 03                	mov    (%ebx),%eax
f0102237:	e8 f3 ef ff ff       	call   f010122f <boot_map_region>
	pgdir = kern_pgdir;
f010223c:	8b 33                	mov    (%ebx),%esi
	n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
f010223e:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f0102244:	8b 00                	mov    (%eax),%eax
f0102246:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102249:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102250:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102255:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102258:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f010225e:	8b 00                	mov    (%eax),%eax
f0102260:	89 45 c0             	mov    %eax,-0x40(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0102263:	89 45 cc             	mov    %eax,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102266:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f010226c:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE)
f010226f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102274:	e9 57 08 00 00       	jmp    f0102ad0 <mem_init+0x1722>
	assert(nfree == 0);
f0102279:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010227c:	8d 83 d9 93 f7 ff    	lea    -0x86c27(%ebx),%eax
f0102282:	50                   	push   %eax
f0102283:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102289:	50                   	push   %eax
f010228a:	68 62 02 00 00       	push   $0x262
f010228f:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102295:	50                   	push   %eax
f0102296:	e8 16 de ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f010229b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010229e:	8d 83 3e 93 f7 ff    	lea    -0x86cc2(%ebx),%eax
f01022a4:	50                   	push   %eax
f01022a5:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01022ab:	50                   	push   %eax
f01022ac:	68 c2 02 00 00       	push   $0x2c2
f01022b1:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01022b7:	50                   	push   %eax
f01022b8:	e8 f4 dd ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f01022bd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022c0:	8d 83 54 93 f7 ff    	lea    -0x86cac(%ebx),%eax
f01022c6:	50                   	push   %eax
f01022c7:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01022cd:	50                   	push   %eax
f01022ce:	68 c3 02 00 00       	push   $0x2c3
f01022d3:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01022d9:	50                   	push   %eax
f01022da:	e8 d2 dd ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f01022df:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022e2:	8d 83 6a 93 f7 ff    	lea    -0x86c96(%ebx),%eax
f01022e8:	50                   	push   %eax
f01022e9:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01022ef:	50                   	push   %eax
f01022f0:	68 c4 02 00 00       	push   $0x2c4
f01022f5:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01022fb:	50                   	push   %eax
f01022fc:	e8 b0 dd ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f0102301:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102304:	8d 83 80 93 f7 ff    	lea    -0x86c80(%ebx),%eax
f010230a:	50                   	push   %eax
f010230b:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102311:	50                   	push   %eax
f0102312:	68 c7 02 00 00       	push   $0x2c7
f0102317:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f010231d:	50                   	push   %eax
f010231e:	e8 8e dd ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102323:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102326:	8d 83 b8 8b f7 ff    	lea    -0x87448(%ebx),%eax
f010232c:	50                   	push   %eax
f010232d:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102333:	50                   	push   %eax
f0102334:	68 c8 02 00 00       	push   $0x2c8
f0102339:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f010233f:	50                   	push   %eax
f0102340:	e8 6c dd ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102345:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102348:	8d 83 92 93 f7 ff    	lea    -0x86c6e(%ebx),%eax
f010234e:	50                   	push   %eax
f010234f:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102355:	50                   	push   %eax
f0102356:	68 cf 02 00 00       	push   $0x2cf
f010235b:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102361:	50                   	push   %eax
f0102362:	e8 4a dd ff ff       	call   f01000b1 <_panic>
	assert(page_lookup(kern_pgdir, (void *)0x0, &ptep) == NULL);
f0102367:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010236a:	8d 83 58 8c f7 ff    	lea    -0x873a8(%ebx),%eax
f0102370:	50                   	push   %eax
f0102371:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102377:	50                   	push   %eax
f0102378:	68 d2 02 00 00       	push   $0x2d2
f010237d:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102383:	50                   	push   %eax
f0102384:	e8 28 dd ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102389:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010238c:	8d 83 8c 8c f7 ff    	lea    -0x87374(%ebx),%eax
f0102392:	50                   	push   %eax
f0102393:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102399:	50                   	push   %eax
f010239a:	68 d5 02 00 00       	push   $0x2d5
f010239f:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01023a5:	50                   	push   %eax
f01023a6:	e8 06 dd ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01023ab:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023ae:	8d 83 bc 8c f7 ff    	lea    -0x87344(%ebx),%eax
f01023b4:	50                   	push   %eax
f01023b5:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01023bb:	50                   	push   %eax
f01023bc:	68 d9 02 00 00       	push   $0x2d9
f01023c1:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01023c7:	50                   	push   %eax
f01023c8:	e8 e4 dc ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023cd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023d0:	8d 83 ec 8c f7 ff    	lea    -0x87314(%ebx),%eax
f01023d6:	50                   	push   %eax
f01023d7:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01023dd:	50                   	push   %eax
f01023de:	68 da 02 00 00       	push   $0x2da
f01023e3:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01023e9:	50                   	push   %eax
f01023ea:	e8 c2 dc ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01023ef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023f2:	8d 83 14 8d f7 ff    	lea    -0x872ec(%ebx),%eax
f01023f8:	50                   	push   %eax
f01023f9:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01023ff:	50                   	push   %eax
f0102400:	68 db 02 00 00       	push   $0x2db
f0102405:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f010240b:	50                   	push   %eax
f010240c:	e8 a0 dc ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102411:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102414:	8d 83 e4 93 f7 ff    	lea    -0x86c1c(%ebx),%eax
f010241a:	50                   	push   %eax
f010241b:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102421:	50                   	push   %eax
f0102422:	68 dc 02 00 00       	push   $0x2dc
f0102427:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f010242d:	50                   	push   %eax
f010242e:	e8 7e dc ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f0102433:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102436:	8d 83 f5 93 f7 ff    	lea    -0x86c0b(%ebx),%eax
f010243c:	50                   	push   %eax
f010243d:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102443:	50                   	push   %eax
f0102444:	68 dd 02 00 00       	push   $0x2dd
f0102449:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f010244f:	50                   	push   %eax
f0102450:	e8 5c dc ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0102455:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102458:	8d 83 44 8d f7 ff    	lea    -0x872bc(%ebx),%eax
f010245e:	50                   	push   %eax
f010245f:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102465:	50                   	push   %eax
f0102466:	68 df 02 00 00       	push   $0x2df
f010246b:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102471:	50                   	push   %eax
f0102472:	e8 3a dc ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102477:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010247a:	8d 83 80 8d f7 ff    	lea    -0x87280(%ebx),%eax
f0102480:	50                   	push   %eax
f0102481:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102487:	50                   	push   %eax
f0102488:	68 e0 02 00 00       	push   $0x2e0
f010248d:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102493:	50                   	push   %eax
f0102494:	e8 18 dc ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102499:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010249c:	8d 83 06 94 f7 ff    	lea    -0x86bfa(%ebx),%eax
f01024a2:	50                   	push   %eax
f01024a3:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01024a9:	50                   	push   %eax
f01024aa:	68 e1 02 00 00       	push   $0x2e1
f01024af:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01024b5:	50                   	push   %eax
f01024b6:	e8 f6 db ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f01024bb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024be:	8d 83 92 93 f7 ff    	lea    -0x86c6e(%ebx),%eax
f01024c4:	50                   	push   %eax
f01024c5:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01024cb:	50                   	push   %eax
f01024cc:	68 e4 02 00 00       	push   $0x2e4
f01024d1:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01024d7:	50                   	push   %eax
f01024d8:	e8 d4 db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f01024dd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024e0:	8d 83 44 8d f7 ff    	lea    -0x872bc(%ebx),%eax
f01024e6:	50                   	push   %eax
f01024e7:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01024ed:	50                   	push   %eax
f01024ee:	68 e7 02 00 00       	push   $0x2e7
f01024f3:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01024f9:	50                   	push   %eax
f01024fa:	e8 b2 db ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024ff:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102502:	8d 83 80 8d f7 ff    	lea    -0x87280(%ebx),%eax
f0102508:	50                   	push   %eax
f0102509:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f010250f:	50                   	push   %eax
f0102510:	68 e8 02 00 00       	push   $0x2e8
f0102515:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f010251b:	50                   	push   %eax
f010251c:	e8 90 db ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102521:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102524:	8d 83 06 94 f7 ff    	lea    -0x86bfa(%ebx),%eax
f010252a:	50                   	push   %eax
f010252b:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102531:	50                   	push   %eax
f0102532:	68 e9 02 00 00       	push   $0x2e9
f0102537:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f010253d:	50                   	push   %eax
f010253e:	e8 6e db ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102543:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102546:	8d 83 92 93 f7 ff    	lea    -0x86c6e(%ebx),%eax
f010254c:	50                   	push   %eax
f010254d:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102553:	50                   	push   %eax
f0102554:	68 ed 02 00 00       	push   $0x2ed
f0102559:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f010255f:	50                   	push   %eax
f0102560:	e8 4c db ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102565:	50                   	push   %eax
f0102566:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102569:	8d 83 f0 89 f7 ff    	lea    -0x87610(%ebx),%eax
f010256f:	50                   	push   %eax
f0102570:	68 f0 02 00 00       	push   $0x2f0
f0102575:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f010257b:	50                   	push   %eax
f010257c:	e8 30 db ff ff       	call   f01000b1 <_panic>
	assert(pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
f0102581:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102584:	8d 83 b0 8d f7 ff    	lea    -0x87250(%ebx),%eax
f010258a:	50                   	push   %eax
f010258b:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102591:	50                   	push   %eax
f0102592:	68 f1 02 00 00       	push   $0x2f1
f0102597:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f010259d:	50                   	push   %eax
f010259e:	e8 0e db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W | PTE_U) == 0);
f01025a3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025a6:	8d 83 f0 8d f7 ff    	lea    -0x87210(%ebx),%eax
f01025ac:	50                   	push   %eax
f01025ad:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01025b3:	50                   	push   %eax
f01025b4:	68 f4 02 00 00       	push   $0x2f4
f01025b9:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01025bf:	50                   	push   %eax
f01025c0:	e8 ec da ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01025c5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025c8:	8d 83 80 8d f7 ff    	lea    -0x87280(%ebx),%eax
f01025ce:	50                   	push   %eax
f01025cf:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01025d5:	50                   	push   %eax
f01025d6:	68 f5 02 00 00       	push   $0x2f5
f01025db:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01025e1:	50                   	push   %eax
f01025e2:	e8 ca da ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f01025e7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025ea:	8d 83 06 94 f7 ff    	lea    -0x86bfa(%ebx),%eax
f01025f0:	50                   	push   %eax
f01025f1:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01025f7:	50                   	push   %eax
f01025f8:	68 f6 02 00 00       	push   $0x2f6
f01025fd:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102603:	50                   	push   %eax
f0102604:	e8 a8 da ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U);
f0102609:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010260c:	8d 83 34 8e f7 ff    	lea    -0x871cc(%ebx),%eax
f0102612:	50                   	push   %eax
f0102613:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102619:	50                   	push   %eax
f010261a:	68 f7 02 00 00       	push   $0x2f7
f010261f:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102625:	50                   	push   %eax
f0102626:	e8 86 da ff ff       	call   f01000b1 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010262b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010262e:	8d 83 17 94 f7 ff    	lea    -0x86be9(%ebx),%eax
f0102634:	50                   	push   %eax
f0102635:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f010263b:	50                   	push   %eax
f010263c:	68 f8 02 00 00       	push   $0x2f8
f0102641:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102647:	50                   	push   %eax
f0102648:	e8 64 da ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f010264d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102650:	8d 83 44 8d f7 ff    	lea    -0x872bc(%ebx),%eax
f0102656:	50                   	push   %eax
f0102657:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f010265d:	50                   	push   %eax
f010265e:	68 fb 02 00 00       	push   $0x2fb
f0102663:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102669:	50                   	push   %eax
f010266a:	e8 42 da ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_W);
f010266f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102672:	8d 83 68 8e f7 ff    	lea    -0x87198(%ebx),%eax
f0102678:	50                   	push   %eax
f0102679:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f010267f:	50                   	push   %eax
f0102680:	68 fc 02 00 00       	push   $0x2fc
f0102685:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f010268b:	50                   	push   %eax
f010268c:	e8 20 da ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0102691:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102694:	8d 83 9c 8e f7 ff    	lea    -0x87164(%ebx),%eax
f010269a:	50                   	push   %eax
f010269b:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01026a1:	50                   	push   %eax
f01026a2:	68 fd 02 00 00       	push   $0x2fd
f01026a7:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01026ad:	50                   	push   %eax
f01026ae:	e8 fe d9 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void *)PTSIZE, PTE_W) < 0);
f01026b3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026b6:	8d 83 d4 8e f7 ff    	lea    -0x8712c(%ebx),%eax
f01026bc:	50                   	push   %eax
f01026bd:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01026c3:	50                   	push   %eax
f01026c4:	68 00 03 00 00       	push   $0x300
f01026c9:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01026cf:	50                   	push   %eax
f01026d0:	e8 dc d9 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W) == 0);
f01026d5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026d8:	8d 83 0c 8f f7 ff    	lea    -0x870f4(%ebx),%eax
f01026de:	50                   	push   %eax
f01026df:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01026e5:	50                   	push   %eax
f01026e6:	68 03 03 00 00       	push   $0x303
f01026eb:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01026f1:	50                   	push   %eax
f01026f2:	e8 ba d9 ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f01026f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026fa:	8d 83 9c 8e f7 ff    	lea    -0x87164(%ebx),%eax
f0102700:	50                   	push   %eax
f0102701:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102707:	50                   	push   %eax
f0102708:	68 04 03 00 00       	push   $0x304
f010270d:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102713:	50                   	push   %eax
f0102714:	e8 98 d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102719:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010271c:	8d 83 48 8f f7 ff    	lea    -0x870b8(%ebx),%eax
f0102722:	50                   	push   %eax
f0102723:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102729:	50                   	push   %eax
f010272a:	68 07 03 00 00       	push   $0x307
f010272f:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102735:	50                   	push   %eax
f0102736:	e8 76 d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010273b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010273e:	8d 83 74 8f f7 ff    	lea    -0x8708c(%ebx),%eax
f0102744:	50                   	push   %eax
f0102745:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f010274b:	50                   	push   %eax
f010274c:	68 08 03 00 00       	push   $0x308
f0102751:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102757:	50                   	push   %eax
f0102758:	e8 54 d9 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 2);
f010275d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102760:	8d 83 2d 94 f7 ff    	lea    -0x86bd3(%ebx),%eax
f0102766:	50                   	push   %eax
f0102767:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f010276d:	50                   	push   %eax
f010276e:	68 0a 03 00 00       	push   $0x30a
f0102773:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102779:	50                   	push   %eax
f010277a:	e8 32 d9 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f010277f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102782:	8d 83 3e 94 f7 ff    	lea    -0x86bc2(%ebx),%eax
f0102788:	50                   	push   %eax
f0102789:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f010278f:	50                   	push   %eax
f0102790:	68 0b 03 00 00       	push   $0x30b
f0102795:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f010279b:	50                   	push   %eax
f010279c:	e8 10 d9 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01027a1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027a4:	8d 83 a4 8f f7 ff    	lea    -0x8705c(%ebx),%eax
f01027aa:	50                   	push   %eax
f01027ab:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01027b1:	50                   	push   %eax
f01027b2:	68 0e 03 00 00       	push   $0x30e
f01027b7:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01027bd:	50                   	push   %eax
f01027be:	e8 ee d8 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01027c3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027c6:	8d 83 c8 8f f7 ff    	lea    -0x87038(%ebx),%eax
f01027cc:	50                   	push   %eax
f01027cd:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01027d3:	50                   	push   %eax
f01027d4:	68 12 03 00 00       	push   $0x312
f01027d9:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01027df:	50                   	push   %eax
f01027e0:	e8 cc d8 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01027e5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027e8:	8d 83 74 8f f7 ff    	lea    -0x8708c(%ebx),%eax
f01027ee:	50                   	push   %eax
f01027ef:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01027f5:	50                   	push   %eax
f01027f6:	68 13 03 00 00       	push   $0x313
f01027fb:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102801:	50                   	push   %eax
f0102802:	e8 aa d8 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102807:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010280a:	8d 83 e4 93 f7 ff    	lea    -0x86c1c(%ebx),%eax
f0102810:	50                   	push   %eax
f0102811:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102817:	50                   	push   %eax
f0102818:	68 14 03 00 00       	push   $0x314
f010281d:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102823:	50                   	push   %eax
f0102824:	e8 88 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102829:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010282c:	8d 83 3e 94 f7 ff    	lea    -0x86bc2(%ebx),%eax
f0102832:	50                   	push   %eax
f0102833:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102839:	50                   	push   %eax
f010283a:	68 15 03 00 00       	push   $0x315
f010283f:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102845:	50                   	push   %eax
f0102846:	e8 66 d8 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, 0) == 0);
f010284b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010284e:	8d 83 ec 8f f7 ff    	lea    -0x87014(%ebx),%eax
f0102854:	50                   	push   %eax
f0102855:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f010285b:	50                   	push   %eax
f010285c:	68 18 03 00 00       	push   $0x318
f0102861:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102867:	50                   	push   %eax
f0102868:	e8 44 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref);
f010286d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102870:	8d 83 4f 94 f7 ff    	lea    -0x86bb1(%ebx),%eax
f0102876:	50                   	push   %eax
f0102877:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f010287d:	50                   	push   %eax
f010287e:	68 19 03 00 00       	push   $0x319
f0102883:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102889:	50                   	push   %eax
f010288a:	e8 22 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_link == NULL);
f010288f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102892:	8d 83 5b 94 f7 ff    	lea    -0x86ba5(%ebx),%eax
f0102898:	50                   	push   %eax
f0102899:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f010289f:	50                   	push   %eax
f01028a0:	68 1a 03 00 00       	push   $0x31a
f01028a5:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01028ab:	50                   	push   %eax
f01028ac:	e8 00 d8 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01028b1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028b4:	8d 83 c8 8f f7 ff    	lea    -0x87038(%ebx),%eax
f01028ba:	50                   	push   %eax
f01028bb:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01028c1:	50                   	push   %eax
f01028c2:	68 1e 03 00 00       	push   $0x31e
f01028c7:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01028cd:	50                   	push   %eax
f01028ce:	e8 de d7 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01028d3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028d6:	8d 83 24 90 f7 ff    	lea    -0x86fdc(%ebx),%eax
f01028dc:	50                   	push   %eax
f01028dd:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01028e3:	50                   	push   %eax
f01028e4:	68 1f 03 00 00       	push   $0x31f
f01028e9:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01028ef:	50                   	push   %eax
f01028f0:	e8 bc d7 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f01028f5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028f8:	8d 83 70 94 f7 ff    	lea    -0x86b90(%ebx),%eax
f01028fe:	50                   	push   %eax
f01028ff:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102905:	50                   	push   %eax
f0102906:	68 20 03 00 00       	push   $0x320
f010290b:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102911:	50                   	push   %eax
f0102912:	e8 9a d7 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102917:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010291a:	8d 83 3e 94 f7 ff    	lea    -0x86bc2(%ebx),%eax
f0102920:	50                   	push   %eax
f0102921:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102927:	50                   	push   %eax
f0102928:	68 21 03 00 00       	push   $0x321
f010292d:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102933:	50                   	push   %eax
f0102934:	e8 78 d7 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102939:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010293c:	8d 83 4c 90 f7 ff    	lea    -0x86fb4(%ebx),%eax
f0102942:	50                   	push   %eax
f0102943:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102949:	50                   	push   %eax
f010294a:	68 24 03 00 00       	push   $0x324
f010294f:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102955:	50                   	push   %eax
f0102956:	e8 56 d7 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f010295b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010295e:	8d 83 92 93 f7 ff    	lea    -0x86c6e(%ebx),%eax
f0102964:	50                   	push   %eax
f0102965:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f010296b:	50                   	push   %eax
f010296c:	68 27 03 00 00       	push   $0x327
f0102971:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102977:	50                   	push   %eax
f0102978:	e8 34 d7 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010297d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102980:	8d 83 ec 8c f7 ff    	lea    -0x87314(%ebx),%eax
f0102986:	50                   	push   %eax
f0102987:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f010298d:	50                   	push   %eax
f010298e:	68 2a 03 00 00       	push   $0x32a
f0102993:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102999:	50                   	push   %eax
f010299a:	e8 12 d7 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f010299f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029a2:	8d 83 f5 93 f7 ff    	lea    -0x86c0b(%ebx),%eax
f01029a8:	50                   	push   %eax
f01029a9:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01029af:	50                   	push   %eax
f01029b0:	68 2c 03 00 00       	push   $0x32c
f01029b5:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01029bb:	50                   	push   %eax
f01029bc:	e8 f0 d6 ff ff       	call   f01000b1 <_panic>
f01029c1:	52                   	push   %edx
f01029c2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029c5:	8d 83 f0 89 f7 ff    	lea    -0x87610(%ebx),%eax
f01029cb:	50                   	push   %eax
f01029cc:	68 33 03 00 00       	push   $0x333
f01029d1:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01029d7:	50                   	push   %eax
f01029d8:	e8 d4 d6 ff ff       	call   f01000b1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01029dd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029e0:	8d 83 81 94 f7 ff    	lea    -0x86b7f(%ebx),%eax
f01029e6:	50                   	push   %eax
f01029e7:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01029ed:	50                   	push   %eax
f01029ee:	68 34 03 00 00       	push   $0x334
f01029f3:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01029f9:	50                   	push   %eax
f01029fa:	e8 b2 d6 ff ff       	call   f01000b1 <_panic>
f01029ff:	50                   	push   %eax
f0102a00:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a03:	8d 83 f0 89 f7 ff    	lea    -0x87610(%ebx),%eax
f0102a09:	50                   	push   %eax
f0102a0a:	6a 56                	push   $0x56
f0102a0c:	8d 83 79 92 f7 ff    	lea    -0x86d87(%ebx),%eax
f0102a12:	50                   	push   %eax
f0102a13:	e8 99 d6 ff ff       	call   f01000b1 <_panic>
f0102a18:	52                   	push   %edx
f0102a19:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a1c:	8d 83 f0 89 f7 ff    	lea    -0x87610(%ebx),%eax
f0102a22:	50                   	push   %eax
f0102a23:	6a 56                	push   $0x56
f0102a25:	8d 83 79 92 f7 ff    	lea    -0x86d87(%ebx),%eax
f0102a2b:	50                   	push   %eax
f0102a2c:	e8 80 d6 ff ff       	call   f01000b1 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102a31:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a34:	8d 83 99 94 f7 ff    	lea    -0x86b67(%ebx),%eax
f0102a3a:	50                   	push   %eax
f0102a3b:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102a41:	50                   	push   %eax
f0102a42:	68 3e 03 00 00       	push   $0x33e
f0102a47:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102a4d:	50                   	push   %eax
f0102a4e:	e8 5e d6 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a53:	50                   	push   %eax
f0102a54:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a57:	8d 83 f4 8a f7 ff    	lea    -0x8750c(%ebx),%eax
f0102a5d:	50                   	push   %eax
f0102a5e:	68 bf 00 00 00       	push   $0xbf
f0102a63:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102a69:	50                   	push   %eax
f0102a6a:	e8 42 d6 ff ff       	call   f01000b1 <_panic>
f0102a6f:	50                   	push   %eax
f0102a70:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a73:	8d 83 f4 8a f7 ff    	lea    -0x8750c(%ebx),%eax
f0102a79:	50                   	push   %eax
f0102a7a:	68 c9 00 00 00       	push   $0xc9
f0102a7f:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102a85:	50                   	push   %eax
f0102a86:	e8 26 d6 ff ff       	call   f01000b1 <_panic>
f0102a8b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a8e:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
f0102a94:	8d 83 f4 8a f7 ff    	lea    -0x8750c(%ebx),%eax
f0102a9a:	50                   	push   %eax
f0102a9b:	68 cd 00 00 00       	push   $0xcd
f0102aa0:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102aa6:	50                   	push   %eax
f0102aa7:	e8 05 d6 ff ff       	call   f01000b1 <_panic>
f0102aac:	ff 75 c0             	pushl  -0x40(%ebp)
f0102aaf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ab2:	8d 83 f4 8a f7 ff    	lea    -0x8750c(%ebx),%eax
f0102ab8:	50                   	push   %eax
f0102ab9:	68 79 02 00 00       	push   $0x279
f0102abe:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102ac4:	50                   	push   %eax
f0102ac5:	e8 e7 d5 ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f0102aca:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ad0:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0102ad3:	76 3f                	jbe    f0102b14 <mem_init+0x1766>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102ad5:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102adb:	89 f0                	mov    %esi,%eax
f0102add:	e8 5b e0 ff ff       	call   f0100b3d <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102ae2:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102ae9:	76 c1                	jbe    f0102aac <mem_init+0x16fe>
f0102aeb:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0102aee:	39 d0                	cmp    %edx,%eax
f0102af0:	74 d8                	je     f0102aca <mem_init+0x171c>
f0102af2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102af5:	8d 83 70 90 f7 ff    	lea    -0x86f90(%ebx),%eax
f0102afb:	50                   	push   %eax
f0102afc:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102b02:	50                   	push   %eax
f0102b03:	68 79 02 00 00       	push   $0x279
f0102b08:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102b0e:	50                   	push   %eax
f0102b0f:	e8 9d d5 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102b14:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102b17:	c7 c0 4c f3 18 f0    	mov    $0xf018f34c,%eax
f0102b1d:	8b 00                	mov    (%eax),%eax
f0102b1f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102b22:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102b25:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
f0102b2a:	8d 98 00 00 40 21    	lea    0x21400000(%eax),%ebx
f0102b30:	89 fa                	mov    %edi,%edx
f0102b32:	89 f0                	mov    %esi,%eax
f0102b34:	e8 04 e0 ff ff       	call   f0100b3d <check_va2pa>
f0102b39:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102b40:	76 3d                	jbe    f0102b7f <mem_init+0x17d1>
f0102b42:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0102b45:	39 d0                	cmp    %edx,%eax
f0102b47:	75 54                	jne    f0102b9d <mem_init+0x17ef>
f0102b49:	81 c7 00 10 00 00    	add    $0x1000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0102b4f:	81 ff 00 80 c1 ee    	cmp    $0xeec18000,%edi
f0102b55:	75 d9                	jne    f0102b30 <mem_init+0x1782>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102b57:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102b5a:	c1 e7 0c             	shl    $0xc,%edi
f0102b5d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102b62:	39 fb                	cmp    %edi,%ebx
f0102b64:	73 7b                	jae    f0102be1 <mem_init+0x1833>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102b66:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102b6c:	89 f0                	mov    %esi,%eax
f0102b6e:	e8 ca df ff ff       	call   f0100b3d <check_va2pa>
f0102b73:	39 c3                	cmp    %eax,%ebx
f0102b75:	75 48                	jne    f0102bbf <mem_init+0x1811>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102b77:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102b7d:	eb e3                	jmp    f0102b62 <mem_init+0x17b4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b7f:	ff 75 cc             	pushl  -0x34(%ebp)
f0102b82:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b85:	8d 83 f4 8a f7 ff    	lea    -0x8750c(%ebx),%eax
f0102b8b:	50                   	push   %eax
f0102b8c:	68 7e 02 00 00       	push   $0x27e
f0102b91:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102b97:	50                   	push   %eax
f0102b98:	e8 14 d5 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102b9d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ba0:	8d 83 a4 90 f7 ff    	lea    -0x86f5c(%ebx),%eax
f0102ba6:	50                   	push   %eax
f0102ba7:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102bad:	50                   	push   %eax
f0102bae:	68 7e 02 00 00       	push   $0x27e
f0102bb3:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102bb9:	50                   	push   %eax
f0102bba:	e8 f2 d4 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102bbf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bc2:	8d 83 d8 90 f7 ff    	lea    -0x86f28(%ebx),%eax
f0102bc8:	50                   	push   %eax
f0102bc9:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102bcf:	50                   	push   %eax
f0102bd0:	68 82 02 00 00       	push   $0x282
f0102bd5:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102bdb:	50                   	push   %eax
f0102bdc:	e8 d0 d4 ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102be1:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102be6:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102be9:	81 c7 00 80 00 20    	add    $0x20008000,%edi
f0102bef:	89 da                	mov    %ebx,%edx
f0102bf1:	89 f0                	mov    %esi,%eax
f0102bf3:	e8 45 df ff ff       	call   f0100b3d <check_va2pa>
f0102bf8:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102bfb:	39 c2                	cmp    %eax,%edx
f0102bfd:	75 26                	jne    f0102c25 <mem_init+0x1877>
f0102bff:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102c05:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102c0b:	75 e2                	jne    f0102bef <mem_init+0x1841>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102c0d:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102c12:	89 f0                	mov    %esi,%eax
f0102c14:	e8 24 df ff ff       	call   f0100b3d <check_va2pa>
f0102c19:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102c1c:	75 29                	jne    f0102c47 <mem_init+0x1899>
	for (i = 0; i < NPDENTRIES; i++)
f0102c1e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c23:	eb 6d                	jmp    f0102c92 <mem_init+0x18e4>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102c25:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c28:	8d 83 00 91 f7 ff    	lea    -0x86f00(%ebx),%eax
f0102c2e:	50                   	push   %eax
f0102c2f:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102c35:	50                   	push   %eax
f0102c36:	68 86 02 00 00       	push   $0x286
f0102c3b:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102c41:	50                   	push   %eax
f0102c42:	e8 6a d4 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102c47:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c4a:	8d 83 48 91 f7 ff    	lea    -0x86eb8(%ebx),%eax
f0102c50:	50                   	push   %eax
f0102c51:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102c57:	50                   	push   %eax
f0102c58:	68 87 02 00 00       	push   $0x287
f0102c5d:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102c63:	50                   	push   %eax
f0102c64:	e8 48 d4 ff ff       	call   f01000b1 <_panic>
			assert(pgdir[i] & PTE_P);
f0102c69:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102c6d:	74 52                	je     f0102cc1 <mem_init+0x1913>
	for (i = 0; i < NPDENTRIES; i++)
f0102c6f:	83 c0 01             	add    $0x1,%eax
f0102c72:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102c77:	0f 87 bb 00 00 00    	ja     f0102d38 <mem_init+0x198a>
		switch (i)
f0102c7d:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102c82:	72 0e                	jb     f0102c92 <mem_init+0x18e4>
f0102c84:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102c89:	76 de                	jbe    f0102c69 <mem_init+0x18bb>
f0102c8b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102c90:	74 d7                	je     f0102c69 <mem_init+0x18bb>
			if (i >= PDX(KERNBASE))
f0102c92:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102c97:	77 4a                	ja     f0102ce3 <mem_init+0x1935>
				assert(pgdir[i] == 0);
f0102c99:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102c9d:	74 d0                	je     f0102c6f <mem_init+0x18c1>
f0102c9f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ca2:	8d 83 eb 94 f7 ff    	lea    -0x86b15(%ebx),%eax
f0102ca8:	50                   	push   %eax
f0102ca9:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102caf:	50                   	push   %eax
f0102cb0:	68 9b 02 00 00       	push   $0x29b
f0102cb5:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102cbb:	50                   	push   %eax
f0102cbc:	e8 f0 d3 ff ff       	call   f01000b1 <_panic>
			assert(pgdir[i] & PTE_P);
f0102cc1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cc4:	8d 83 c9 94 f7 ff    	lea    -0x86b37(%ebx),%eax
f0102cca:	50                   	push   %eax
f0102ccb:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102cd1:	50                   	push   %eax
f0102cd2:	68 92 02 00 00       	push   $0x292
f0102cd7:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102cdd:	50                   	push   %eax
f0102cde:	e8 ce d3 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0102ce3:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102ce6:	f6 c2 01             	test   $0x1,%dl
f0102ce9:	74 2b                	je     f0102d16 <mem_init+0x1968>
				assert(pgdir[i] & PTE_W);
f0102ceb:	f6 c2 02             	test   $0x2,%dl
f0102cee:	0f 85 7b ff ff ff    	jne    f0102c6f <mem_init+0x18c1>
f0102cf4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cf7:	8d 83 da 94 f7 ff    	lea    -0x86b26(%ebx),%eax
f0102cfd:	50                   	push   %eax
f0102cfe:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102d04:	50                   	push   %eax
f0102d05:	68 98 02 00 00       	push   $0x298
f0102d0a:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102d10:	50                   	push   %eax
f0102d11:	e8 9b d3 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0102d16:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d19:	8d 83 c9 94 f7 ff    	lea    -0x86b37(%ebx),%eax
f0102d1f:	50                   	push   %eax
f0102d20:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102d26:	50                   	push   %eax
f0102d27:	68 97 02 00 00       	push   $0x297
f0102d2c:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102d32:	50                   	push   %eax
f0102d33:	e8 79 d3 ff ff       	call   f01000b1 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102d38:	83 ec 0c             	sub    $0xc,%esp
f0102d3b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102d3e:	8d 86 78 91 f7 ff    	lea    -0x86e88(%esi),%eax
f0102d44:	50                   	push   %eax
f0102d45:	89 f3                	mov    %esi,%ebx
f0102d47:	e8 4f 0d 00 00       	call   f0103a9b <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102d4c:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0102d52:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102d54:	83 c4 10             	add    $0x10,%esp
f0102d57:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d5c:	0f 86 44 02 00 00    	jbe    f0102fa6 <mem_init+0x1bf8>
	return (physaddr_t)kva - KERNBASE;
f0102d62:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102d67:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102d6a:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d6f:	e8 46 de ff ff       	call   f0100bba <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102d74:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS | CR0_EM);
f0102d77:	83 e0 f3             	and    $0xfffffff3,%eax
f0102d7a:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102d7f:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102d82:	83 ec 0c             	sub    $0xc,%esp
f0102d85:	6a 00                	push   $0x0
f0102d87:	e8 ac e2 ff ff       	call   f0101038 <page_alloc>
f0102d8c:	89 c6                	mov    %eax,%esi
f0102d8e:	83 c4 10             	add    $0x10,%esp
f0102d91:	85 c0                	test   %eax,%eax
f0102d93:	0f 84 29 02 00 00    	je     f0102fc2 <mem_init+0x1c14>
	assert((pp1 = page_alloc(0)));
f0102d99:	83 ec 0c             	sub    $0xc,%esp
f0102d9c:	6a 00                	push   $0x0
f0102d9e:	e8 95 e2 ff ff       	call   f0101038 <page_alloc>
f0102da3:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102da6:	83 c4 10             	add    $0x10,%esp
f0102da9:	85 c0                	test   %eax,%eax
f0102dab:	0f 84 33 02 00 00    	je     f0102fe4 <mem_init+0x1c36>
	assert((pp2 = page_alloc(0)));
f0102db1:	83 ec 0c             	sub    $0xc,%esp
f0102db4:	6a 00                	push   $0x0
f0102db6:	e8 7d e2 ff ff       	call   f0101038 <page_alloc>
f0102dbb:	89 c7                	mov    %eax,%edi
f0102dbd:	83 c4 10             	add    $0x10,%esp
f0102dc0:	85 c0                	test   %eax,%eax
f0102dc2:	0f 84 3e 02 00 00    	je     f0103006 <mem_init+0x1c58>
	page_free(pp0);
f0102dc8:	83 ec 0c             	sub    $0xc,%esp
f0102dcb:	56                   	push   %esi
f0102dcc:	e8 f5 e2 ff ff       	call   f01010c6 <page_free>
	return (pp - pages) << PGSHIFT;
f0102dd1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102dd4:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0102dda:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102ddd:	2b 08                	sub    (%eax),%ecx
f0102ddf:	89 c8                	mov    %ecx,%eax
f0102de1:	c1 f8 03             	sar    $0x3,%eax
f0102de4:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102de7:	89 c1                	mov    %eax,%ecx
f0102de9:	c1 e9 0c             	shr    $0xc,%ecx
f0102dec:	83 c4 10             	add    $0x10,%esp
f0102def:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f0102df5:	3b 0a                	cmp    (%edx),%ecx
f0102df7:	0f 83 2b 02 00 00    	jae    f0103028 <mem_init+0x1c7a>
	memset(page2kva(pp1), 1, PGSIZE);
f0102dfd:	83 ec 04             	sub    $0x4,%esp
f0102e00:	68 00 10 00 00       	push   $0x1000
f0102e05:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102e07:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102e0c:	50                   	push   %eax
f0102e0d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e10:	e8 dd 22 00 00       	call   f01050f2 <memset>
	return (pp - pages) << PGSHIFT;
f0102e15:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e18:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0102e1e:	89 f9                	mov    %edi,%ecx
f0102e20:	2b 08                	sub    (%eax),%ecx
f0102e22:	89 c8                	mov    %ecx,%eax
f0102e24:	c1 f8 03             	sar    $0x3,%eax
f0102e27:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102e2a:	89 c1                	mov    %eax,%ecx
f0102e2c:	c1 e9 0c             	shr    $0xc,%ecx
f0102e2f:	83 c4 10             	add    $0x10,%esp
f0102e32:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f0102e38:	3b 0a                	cmp    (%edx),%ecx
f0102e3a:	0f 83 fe 01 00 00    	jae    f010303e <mem_init+0x1c90>
	memset(page2kva(pp2), 2, PGSIZE);
f0102e40:	83 ec 04             	sub    $0x4,%esp
f0102e43:	68 00 10 00 00       	push   $0x1000
f0102e48:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102e4a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102e4f:	50                   	push   %eax
f0102e50:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e53:	e8 9a 22 00 00       	call   f01050f2 <memset>
	page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W);
f0102e58:	6a 02                	push   $0x2
f0102e5a:	68 00 10 00 00       	push   $0x1000
f0102e5f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102e62:	53                   	push   %ebx
f0102e63:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e66:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0102e6c:	ff 30                	pushl  (%eax)
f0102e6e:	e8 b9 e4 ff ff       	call   f010132c <page_insert>
	assert(pp1->pp_ref == 1);
f0102e73:	83 c4 20             	add    $0x20,%esp
f0102e76:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102e7b:	0f 85 d3 01 00 00    	jne    f0103054 <mem_init+0x1ca6>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e81:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102e88:	01 01 01 
f0102e8b:	0f 85 e5 01 00 00    	jne    f0103076 <mem_init+0x1cc8>
	page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W);
f0102e91:	6a 02                	push   $0x2
f0102e93:	68 00 10 00 00       	push   $0x1000
f0102e98:	57                   	push   %edi
f0102e99:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e9c:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0102ea2:	ff 30                	pushl  (%eax)
f0102ea4:	e8 83 e4 ff ff       	call   f010132c <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ea9:	83 c4 10             	add    $0x10,%esp
f0102eac:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102eb3:	02 02 02 
f0102eb6:	0f 85 dc 01 00 00    	jne    f0103098 <mem_init+0x1cea>
	assert(pp2->pp_ref == 1);
f0102ebc:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102ec1:	0f 85 f3 01 00 00    	jne    f01030ba <mem_init+0x1d0c>
	assert(pp1->pp_ref == 0);
f0102ec7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102eca:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102ecf:	0f 85 07 02 00 00    	jne    f01030dc <mem_init+0x1d2e>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102ed5:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102edc:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102edf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ee2:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0102ee8:	89 f9                	mov    %edi,%ecx
f0102eea:	2b 08                	sub    (%eax),%ecx
f0102eec:	89 c8                	mov    %ecx,%eax
f0102eee:	c1 f8 03             	sar    $0x3,%eax
f0102ef1:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102ef4:	89 c1                	mov    %eax,%ecx
f0102ef6:	c1 e9 0c             	shr    $0xc,%ecx
f0102ef9:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f0102eff:	3b 0a                	cmp    (%edx),%ecx
f0102f01:	0f 83 f7 01 00 00    	jae    f01030fe <mem_init+0x1d50>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102f07:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102f0e:	03 03 03 
f0102f11:	0f 85 fd 01 00 00    	jne    f0103114 <mem_init+0x1d66>
	page_remove(kern_pgdir, (void *)PGSIZE);
f0102f17:	83 ec 08             	sub    $0x8,%esp
f0102f1a:	68 00 10 00 00       	push   $0x1000
f0102f1f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f22:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0102f28:	ff 30                	pushl  (%eax)
f0102f2a:	e8 c2 e3 ff ff       	call   f01012f1 <page_remove>
	assert(pp2->pp_ref == 0);
f0102f2f:	83 c4 10             	add    $0x10,%esp
f0102f32:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102f37:	0f 85 f9 01 00 00    	jne    f0103136 <mem_init+0x1d88>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102f3d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102f40:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0102f46:	8b 08                	mov    (%eax),%ecx
f0102f48:	8b 11                	mov    (%ecx),%edx
f0102f4a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102f50:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0102f56:	89 f7                	mov    %esi,%edi
f0102f58:	2b 38                	sub    (%eax),%edi
f0102f5a:	89 f8                	mov    %edi,%eax
f0102f5c:	c1 f8 03             	sar    $0x3,%eax
f0102f5f:	c1 e0 0c             	shl    $0xc,%eax
f0102f62:	39 c2                	cmp    %eax,%edx
f0102f64:	0f 85 ee 01 00 00    	jne    f0103158 <mem_init+0x1daa>
	kern_pgdir[0] = 0;
f0102f6a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102f70:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102f75:	0f 85 ff 01 00 00    	jne    f010317a <mem_init+0x1dcc>
	pp0->pp_ref = 0;
f0102f7b:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102f81:	83 ec 0c             	sub    $0xc,%esp
f0102f84:	56                   	push   %esi
f0102f85:	e8 3c e1 ff ff       	call   f01010c6 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102f8a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f8d:	8d 83 0c 92 f7 ff    	lea    -0x86df4(%ebx),%eax
f0102f93:	89 04 24             	mov    %eax,(%esp)
f0102f96:	e8 00 0b 00 00       	call   f0103a9b <cprintf>
}
f0102f9b:	83 c4 10             	add    $0x10,%esp
f0102f9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fa1:	5b                   	pop    %ebx
f0102fa2:	5e                   	pop    %esi
f0102fa3:	5f                   	pop    %edi
f0102fa4:	5d                   	pop    %ebp
f0102fa5:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fa6:	50                   	push   %eax
f0102fa7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102faa:	8d 83 f4 8a f7 ff    	lea    -0x8750c(%ebx),%eax
f0102fb0:	50                   	push   %eax
f0102fb1:	68 de 00 00 00       	push   $0xde
f0102fb6:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102fbc:	50                   	push   %eax
f0102fbd:	e8 ef d0 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0102fc2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fc5:	8d 83 3e 93 f7 ff    	lea    -0x86cc2(%ebx),%eax
f0102fcb:	50                   	push   %eax
f0102fcc:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102fd2:	50                   	push   %eax
f0102fd3:	68 59 03 00 00       	push   $0x359
f0102fd8:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0102fde:	50                   	push   %eax
f0102fdf:	e8 cd d0 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102fe4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fe7:	8d 83 54 93 f7 ff    	lea    -0x86cac(%ebx),%eax
f0102fed:	50                   	push   %eax
f0102fee:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0102ff4:	50                   	push   %eax
f0102ff5:	68 5a 03 00 00       	push   $0x35a
f0102ffa:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0103000:	50                   	push   %eax
f0103001:	e8 ab d0 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0103006:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103009:	8d 83 6a 93 f7 ff    	lea    -0x86c96(%ebx),%eax
f010300f:	50                   	push   %eax
f0103010:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0103016:	50                   	push   %eax
f0103017:	68 5b 03 00 00       	push   $0x35b
f010301c:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0103022:	50                   	push   %eax
f0103023:	e8 89 d0 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103028:	50                   	push   %eax
f0103029:	8d 83 f0 89 f7 ff    	lea    -0x87610(%ebx),%eax
f010302f:	50                   	push   %eax
f0103030:	6a 56                	push   $0x56
f0103032:	8d 83 79 92 f7 ff    	lea    -0x86d87(%ebx),%eax
f0103038:	50                   	push   %eax
f0103039:	e8 73 d0 ff ff       	call   f01000b1 <_panic>
f010303e:	50                   	push   %eax
f010303f:	8d 83 f0 89 f7 ff    	lea    -0x87610(%ebx),%eax
f0103045:	50                   	push   %eax
f0103046:	6a 56                	push   $0x56
f0103048:	8d 83 79 92 f7 ff    	lea    -0x86d87(%ebx),%eax
f010304e:	50                   	push   %eax
f010304f:	e8 5d d0 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0103054:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103057:	8d 83 e4 93 f7 ff    	lea    -0x86c1c(%ebx),%eax
f010305d:	50                   	push   %eax
f010305e:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0103064:	50                   	push   %eax
f0103065:	68 60 03 00 00       	push   $0x360
f010306a:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0103070:	50                   	push   %eax
f0103071:	e8 3b d0 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103076:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103079:	8d 83 98 91 f7 ff    	lea    -0x86e68(%ebx),%eax
f010307f:	50                   	push   %eax
f0103080:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0103086:	50                   	push   %eax
f0103087:	68 61 03 00 00       	push   $0x361
f010308c:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0103092:	50                   	push   %eax
f0103093:	e8 19 d0 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103098:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010309b:	8d 83 bc 91 f7 ff    	lea    -0x86e44(%ebx),%eax
f01030a1:	50                   	push   %eax
f01030a2:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01030a8:	50                   	push   %eax
f01030a9:	68 63 03 00 00       	push   $0x363
f01030ae:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01030b4:	50                   	push   %eax
f01030b5:	e8 f7 cf ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f01030ba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030bd:	8d 83 06 94 f7 ff    	lea    -0x86bfa(%ebx),%eax
f01030c3:	50                   	push   %eax
f01030c4:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01030ca:	50                   	push   %eax
f01030cb:	68 64 03 00 00       	push   $0x364
f01030d0:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01030d6:	50                   	push   %eax
f01030d7:	e8 d5 cf ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f01030dc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030df:	8d 83 70 94 f7 ff    	lea    -0x86b90(%ebx),%eax
f01030e5:	50                   	push   %eax
f01030e6:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01030ec:	50                   	push   %eax
f01030ed:	68 65 03 00 00       	push   $0x365
f01030f2:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f01030f8:	50                   	push   %eax
f01030f9:	e8 b3 cf ff ff       	call   f01000b1 <_panic>
f01030fe:	50                   	push   %eax
f01030ff:	8d 83 f0 89 f7 ff    	lea    -0x87610(%ebx),%eax
f0103105:	50                   	push   %eax
f0103106:	6a 56                	push   $0x56
f0103108:	8d 83 79 92 f7 ff    	lea    -0x86d87(%ebx),%eax
f010310e:	50                   	push   %eax
f010310f:	e8 9d cf ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103114:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103117:	8d 83 e0 91 f7 ff    	lea    -0x86e20(%ebx),%eax
f010311d:	50                   	push   %eax
f010311e:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0103124:	50                   	push   %eax
f0103125:	68 67 03 00 00       	push   $0x367
f010312a:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0103130:	50                   	push   %eax
f0103131:	e8 7b cf ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0103136:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103139:	8d 83 3e 94 f7 ff    	lea    -0x86bc2(%ebx),%eax
f010313f:	50                   	push   %eax
f0103140:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0103146:	50                   	push   %eax
f0103147:	68 69 03 00 00       	push   $0x369
f010314c:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0103152:	50                   	push   %eax
f0103153:	e8 59 cf ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103158:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010315b:	8d 83 ec 8c f7 ff    	lea    -0x87314(%ebx),%eax
f0103161:	50                   	push   %eax
f0103162:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0103168:	50                   	push   %eax
f0103169:	68 6c 03 00 00       	push   $0x36c
f010316e:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0103174:	50                   	push   %eax
f0103175:	e8 37 cf ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f010317a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010317d:	8d 83 f5 93 f7 ff    	lea    -0x86c0b(%ebx),%eax
f0103183:	50                   	push   %eax
f0103184:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f010318a:	50                   	push   %eax
f010318b:	68 6e 03 00 00       	push   $0x36e
f0103190:	8d 83 6d 92 f7 ff    	lea    -0x86d93(%ebx),%eax
f0103196:	50                   	push   %eax
f0103197:	e8 15 cf ff ff       	call   f01000b1 <_panic>

f010319c <tlb_invalidate>:
{
f010319c:	55                   	push   %ebp
f010319d:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010319f:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031a2:	0f 01 38             	invlpg (%eax)
}
f01031a5:	5d                   	pop    %ebp
f01031a6:	c3                   	ret    

f01031a7 <user_mem_check>:
{
f01031a7:	55                   	push   %ebp
f01031a8:	89 e5                	mov    %esp,%ebp
f01031aa:	57                   	push   %edi
f01031ab:	56                   	push   %esi
f01031ac:	53                   	push   %ebx
f01031ad:	83 ec 1c             	sub    $0x1c,%esp
f01031b0:	e8 54 d5 ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f01031b5:	05 6b 9e 08 00       	add    $0x89e6b,%eax
f01031ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	const void *start = ROUNDDOWN(va, PGSIZE);
f01031bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01031c0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	const void *end = ROUNDUP(va + len, PGSIZE);
f01031c6:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01031c9:	03 7d 10             	add    0x10(%ebp),%edi
f01031cc:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f01031d2:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
		if (!pte || (*pte & (perm | PTE_P)) != (perm | PTE_P)) // 确认权限，&操作可以得到那几个权限位来判断
f01031d8:	8b 75 14             	mov    0x14(%ebp),%esi
f01031db:	83 ce 01             	or     $0x1,%esi
	for (; start < end; start += PGSIZE) // 遍历每一页
f01031de:	39 fb                	cmp    %edi,%ebx
f01031e0:	73 45                	jae    f0103227 <user_mem_check+0x80>
		pte_t *pte = pgdir_walk(env->env_pgdir, start, 0);	   // 找到pte,pte只能在ULIM下方，因此若pte存在，则地址存在
f01031e2:	83 ec 04             	sub    $0x4,%esp
f01031e5:	6a 00                	push   $0x0
f01031e7:	53                   	push   %ebx
f01031e8:	8b 45 08             	mov    0x8(%ebp),%eax
f01031eb:	ff 70 5c             	pushl  0x5c(%eax)
f01031ee:	e8 4b df ff ff       	call   f010113e <pgdir_walk>
		if (!pte || (*pte & (perm | PTE_P)) != (perm | PTE_P)) // 确认权限，&操作可以得到那几个权限位来判断
f01031f3:	83 c4 10             	add    $0x10,%esp
f01031f6:	85 c0                	test   %eax,%eax
f01031f8:	74 10                	je     f010320a <user_mem_check+0x63>
f01031fa:	89 f2                	mov    %esi,%edx
f01031fc:	23 10                	and    (%eax),%edx
f01031fe:	39 d6                	cmp    %edx,%esi
f0103200:	75 08                	jne    f010320a <user_mem_check+0x63>
	for (; start < end; start += PGSIZE) // 遍历每一页
f0103202:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103208:	eb d4                	jmp    f01031de <user_mem_check+0x37>
			user_mem_check_addr = (uintptr_t)MAX(start, va); // 第一个错误的虚拟地址
f010320a:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f010320d:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0103211:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103214:	89 98 1c 23 00 00    	mov    %ebx,0x231c(%eax)
			return -E_FAULT;								 // 提前返回
f010321a:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f010321f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103222:	5b                   	pop    %ebx
f0103223:	5e                   	pop    %esi
f0103224:	5f                   	pop    %edi
f0103225:	5d                   	pop    %ebp
f0103226:	c3                   	ret    
	return 0;
f0103227:	b8 00 00 00 00       	mov    $0x0,%eax
f010322c:	eb f1                	jmp    f010321f <user_mem_check+0x78>

f010322e <user_mem_assert>:
{
f010322e:	55                   	push   %ebp
f010322f:	89 e5                	mov    %esp,%ebp
f0103231:	56                   	push   %esi
f0103232:	53                   	push   %ebx
f0103233:	e8 2f cf ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103238:	81 c3 e8 9d 08 00    	add    $0x89de8,%ebx
f010323e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (user_mem_check(env, va, len, perm | PTE_U) < 0)
f0103241:	8b 45 14             	mov    0x14(%ebp),%eax
f0103244:	83 c8 04             	or     $0x4,%eax
f0103247:	50                   	push   %eax
f0103248:	ff 75 10             	pushl  0x10(%ebp)
f010324b:	ff 75 0c             	pushl  0xc(%ebp)
f010324e:	56                   	push   %esi
f010324f:	e8 53 ff ff ff       	call   f01031a7 <user_mem_check>
f0103254:	83 c4 10             	add    $0x10,%esp
f0103257:	85 c0                	test   %eax,%eax
f0103259:	78 07                	js     f0103262 <user_mem_assert+0x34>
}
f010325b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010325e:	5b                   	pop    %ebx
f010325f:	5e                   	pop    %esi
f0103260:	5d                   	pop    %ebp
f0103261:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0103262:	83 ec 04             	sub    $0x4,%esp
f0103265:	ff b3 1c 23 00 00    	pushl  0x231c(%ebx)
f010326b:	ff 76 48             	pushl  0x48(%esi)
f010326e:	8d 83 38 92 f7 ff    	lea    -0x86dc8(%ebx),%eax
f0103274:	50                   	push   %eax
f0103275:	e8 21 08 00 00       	call   f0103a9b <cprintf>
		env_destroy(env); // may not return
f010327a:	89 34 24             	mov    %esi,(%esp)
f010327d:	e8 b7 06 00 00       	call   f0103939 <env_destroy>
f0103282:	83 c4 10             	add    $0x10,%esp
}
f0103285:	eb d4                	jmp    f010325b <user_mem_assert+0x2d>

f0103287 <__x86.get_pc_thunk.cx>:
f0103287:	8b 0c 24             	mov    (%esp),%ecx
f010328a:	c3                   	ret    

f010328b <__x86.get_pc_thunk.si>:
f010328b:	8b 34 24             	mov    (%esp),%esi
f010328e:	c3                   	ret    

f010328f <__x86.get_pc_thunk.di>:
f010328f:	8b 3c 24             	mov    (%esp),%edi
f0103292:	c3                   	ret    

f0103293 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
// 为环境 env 分配 len 字节的物理内存，并将其映射到环境地址空间中的虚拟地址 va。
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103293:	55                   	push   %ebp
f0103294:	89 e5                	mov    %esp,%ebp
f0103296:	57                   	push   %edi
f0103297:	56                   	push   %esi
f0103298:	53                   	push   %ebx
f0103299:	83 ec 1c             	sub    $0x1c,%esp
f010329c:	e8 c6 ce ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01032a1:	81 c3 7f 9d 08 00    	add    $0x89d7f,%ebx
f01032a7:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *start = ROUNDDOWN(va, PGSIZE);
f01032a9:	89 d6                	mov    %edx,%esi
f01032ab:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	void *end = ROUNDUP(va + len, PGSIZE);
f01032b1:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f01032b8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01032bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (; start < end; start += PGSIZE)
f01032c0:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01032c3:	73 62                	jae    f0103327 <region_alloc+0x94>
	{
		struct PageInfo *p = page_alloc(0);
f01032c5:	83 ec 0c             	sub    $0xc,%esp
f01032c8:	6a 00                	push   $0x0
f01032ca:	e8 69 dd ff ff       	call   f0101038 <page_alloc>
		if (p == NULL)
f01032cf:	83 c4 10             	add    $0x10,%esp
f01032d2:	85 c0                	test   %eax,%eax
f01032d4:	74 1b                	je     f01032f1 <region_alloc+0x5e>
		{
			panic("region_alloc: error in page_alloc()\n"); // 分配失败
		}
		if (page_insert(e->env_pgdir, p, start, PTE_W | PTE_U))
f01032d6:	6a 06                	push   $0x6
f01032d8:	56                   	push   %esi
f01032d9:	50                   	push   %eax
f01032da:	ff 77 5c             	pushl  0x5c(%edi)
f01032dd:	e8 4a e0 ff ff       	call   f010132c <page_insert>
f01032e2:	83 c4 10             	add    $0x10,%esp
f01032e5:	85 c0                	test   %eax,%eax
f01032e7:	75 23                	jne    f010330c <region_alloc+0x79>
	for (; start < end; start += PGSIZE)
f01032e9:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01032ef:	eb cf                	jmp    f01032c0 <region_alloc+0x2d>
			panic("region_alloc: error in page_alloc()\n"); // 分配失败
f01032f1:	83 ec 04             	sub    $0x4,%esp
f01032f4:	8d 83 fc 94 f7 ff    	lea    -0x86b04(%ebx),%eax
f01032fa:	50                   	push   %eax
f01032fb:	68 29 01 00 00       	push   $0x129
f0103300:	8d 83 ce 95 f7 ff    	lea    -0x86a32(%ebx),%eax
f0103306:	50                   	push   %eax
f0103307:	e8 a5 cd ff ff       	call   f01000b1 <_panic>
		{
			panic("region_alloc: error in page_insert()\n"); // 插入失败
f010330c:	83 ec 04             	sub    $0x4,%esp
f010330f:	8d 83 24 95 f7 ff    	lea    -0x86adc(%ebx),%eax
f0103315:	50                   	push   %eax
f0103316:	68 2d 01 00 00       	push   $0x12d
f010331b:	8d 83 ce 95 f7 ff    	lea    -0x86a32(%ebx),%eax
f0103321:	50                   	push   %eax
f0103322:	e8 8a cd ff ff       	call   f01000b1 <_panic>
		}
	}
}
f0103327:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010332a:	5b                   	pop    %ebx
f010332b:	5e                   	pop    %esi
f010332c:	5f                   	pop    %edi
f010332d:	5d                   	pop    %ebp
f010332e:	c3                   	ret    

f010332f <envid2env>:
{
f010332f:	55                   	push   %ebp
f0103330:	89 e5                	mov    %esp,%ebp
f0103332:	53                   	push   %ebx
f0103333:	e8 4f ff ff ff       	call   f0103287 <__x86.get_pc_thunk.cx>
f0103338:	81 c1 e8 9c 08 00    	add    $0x89ce8,%ecx
f010333e:	8b 55 08             	mov    0x8(%ebp),%edx
f0103341:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if (envid == 0)
f0103344:	85 d2                	test   %edx,%edx
f0103346:	74 41                	je     f0103389 <envid2env+0x5a>
	e = &envs[ENVX(envid)];
f0103348:	89 d0                	mov    %edx,%eax
f010334a:	25 ff 03 00 00       	and    $0x3ff,%eax
f010334f:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103352:	c1 e0 05             	shl    $0x5,%eax
f0103355:	03 81 2c 23 00 00    	add    0x232c(%ecx),%eax
	if (e->env_status == ENV_FREE || e->env_id != envid)
f010335b:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f010335f:	74 3a                	je     f010339b <envid2env+0x6c>
f0103361:	39 50 48             	cmp    %edx,0x48(%eax)
f0103364:	75 35                	jne    f010339b <envid2env+0x6c>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id)
f0103366:	84 db                	test   %bl,%bl
f0103368:	74 12                	je     f010337c <envid2env+0x4d>
f010336a:	8b 91 28 23 00 00    	mov    0x2328(%ecx),%edx
f0103370:	39 c2                	cmp    %eax,%edx
f0103372:	74 08                	je     f010337c <envid2env+0x4d>
f0103374:	8b 5a 48             	mov    0x48(%edx),%ebx
f0103377:	39 58 4c             	cmp    %ebx,0x4c(%eax)
f010337a:	75 2f                	jne    f01033ab <envid2env+0x7c>
	*env_store = e;
f010337c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010337f:	89 03                	mov    %eax,(%ebx)
	return 0;
f0103381:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103386:	5b                   	pop    %ebx
f0103387:	5d                   	pop    %ebp
f0103388:	c3                   	ret    
		*env_store = curenv;
f0103389:	8b 81 28 23 00 00    	mov    0x2328(%ecx),%eax
f010338f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103392:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103394:	b8 00 00 00 00       	mov    $0x0,%eax
f0103399:	eb eb                	jmp    f0103386 <envid2env+0x57>
		*env_store = 0;
f010339b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010339e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01033a4:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01033a9:	eb db                	jmp    f0103386 <envid2env+0x57>
		*env_store = 0;
f01033ab:	8b 45 0c             	mov    0xc(%ebp),%eax
f01033ae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01033b4:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01033b9:	eb cb                	jmp    f0103386 <envid2env+0x57>

f01033bb <env_init_percpu>:
{
f01033bb:	55                   	push   %ebp
f01033bc:	89 e5                	mov    %esp,%ebp
f01033be:	e8 46 d3 ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f01033c3:	05 5d 9c 08 00       	add    $0x89c5d,%eax
	asm volatile("lgdt (%0)" : : "r" (p));
f01033c8:	8d 80 e0 1f 00 00    	lea    0x1fe0(%eax),%eax
f01033ce:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs"
f01033d1:	b8 23 00 00 00       	mov    $0x23,%eax
f01033d6:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs"
f01033d8:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es"
f01033da:	b8 10 00 00 00       	mov    $0x10,%eax
f01033df:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds"
f01033e1:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss"
f01033e3:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n"
f01033e5:	ea ec 33 10 f0 08 00 	ljmp   $0x8,$0xf01033ec
	asm volatile("lldt %0" : : "r" (sel));
f01033ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01033f1:	0f 00 d0             	lldt   %ax
}
f01033f4:	5d                   	pop    %ebp
f01033f5:	c3                   	ret    

f01033f6 <env_init>:
{
f01033f6:	55                   	push   %ebp
f01033f7:	89 e5                	mov    %esp,%ebp
f01033f9:	57                   	push   %edi
f01033fa:	56                   	push   %esi
f01033fb:	53                   	push   %ebx
f01033fc:	e8 8e fe ff ff       	call   f010328f <__x86.get_pc_thunk.di>
f0103401:	81 c7 1f 9c 08 00    	add    $0x89c1f,%edi
		envs[i].env_id = 0;
f0103407:	8b b7 2c 23 00 00    	mov    0x232c(%edi),%esi
f010340d:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f0103413:	8d 5e a0             	lea    -0x60(%esi),%ebx
f0103416:	ba 00 00 00 00       	mov    $0x0,%edx
f010341b:	89 c1                	mov    %eax,%ecx
f010341d:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status = ENV_FREE;
f0103424:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link = env_free_list;
f010342b:	89 50 44             	mov    %edx,0x44(%eax)
f010342e:	83 e8 60             	sub    $0x60,%eax
		env_free_list = &envs[i];
f0103431:	89 ca                	mov    %ecx,%edx
	for (int i = NENV - 1; i >= 0; i--) // 倒着遍历数组，让最后的元素出现在链表底部
f0103433:	39 d8                	cmp    %ebx,%eax
f0103435:	75 e4                	jne    f010341b <env_init+0x25>
f0103437:	89 b7 30 23 00 00    	mov    %esi,0x2330(%edi)
	env_init_percpu();
f010343d:	e8 79 ff ff ff       	call   f01033bb <env_init_percpu>
}
f0103442:	5b                   	pop    %ebx
f0103443:	5e                   	pop    %esi
f0103444:	5f                   	pop    %edi
f0103445:	5d                   	pop    %ebp
f0103446:	c3                   	ret    

f0103447 <env_alloc>:
{
f0103447:	55                   	push   %ebp
f0103448:	89 e5                	mov    %esp,%ebp
f010344a:	56                   	push   %esi
f010344b:	53                   	push   %ebx
f010344c:	e8 16 cd ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103451:	81 c3 cf 9b 08 00    	add    $0x89bcf,%ebx
	if (!(e = env_free_list)) // 如果env_free_list==null就会在这
f0103457:	8b b3 30 23 00 00    	mov    0x2330(%ebx),%esi
f010345d:	85 f6                	test   %esi,%esi
f010345f:	0f 84 60 01 00 00    	je     f01035c5 <env_alloc+0x17e>
	if (!(p = page_alloc(ALLOC_ZERO))) // 分配一页给页表目录
f0103465:	83 ec 0c             	sub    $0xc,%esp
f0103468:	6a 01                	push   $0x1
f010346a:	e8 c9 db ff ff       	call   f0101038 <page_alloc>
f010346f:	83 c4 10             	add    $0x10,%esp
f0103472:	85 c0                	test   %eax,%eax
f0103474:	0f 84 52 01 00 00    	je     f01035cc <env_alloc+0x185>
	p->pp_ref++;
f010347a:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f010347f:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f0103485:	2b 02                	sub    (%edx),%eax
f0103487:	c1 f8 03             	sar    $0x3,%eax
f010348a:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010348d:	89 c1                	mov    %eax,%ecx
f010348f:	c1 e9 0c             	shr    $0xc,%ecx
f0103492:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f0103498:	3b 0a                	cmp    (%edx),%ecx
f010349a:	0f 83 f6 00 00 00    	jae    f0103596 <env_alloc+0x14f>
	return (void *)(pa + KERNBASE);
f01034a0:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = page2kva(p);
f01034a5:	89 46 5c             	mov    %eax,0x5c(%esi)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE); // 把内核页表复制一份放在用户能访问的用户空间里(即env_pgdir处)
f01034a8:	83 ec 04             	sub    $0x4,%esp
f01034ab:	68 00 10 00 00       	push   $0x1000
f01034b0:	c7 c2 08 00 19 f0    	mov    $0xf0190008,%edx
f01034b6:	ff 32                	pushl  (%edx)
f01034b8:	50                   	push   %eax
f01034b9:	e8 e9 1c 00 00       	call   f01051a7 <memcpy>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01034be:	8b 46 5c             	mov    0x5c(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f01034c1:	83 c4 10             	add    $0x10,%esp
f01034c4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034c9:	0f 86 dd 00 00 00    	jbe    f01035ac <env_alloc+0x165>
	return (physaddr_t)kva - KERNBASE;
f01034cf:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01034d5:	83 ca 05             	or     $0x5,%edx
f01034d8:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01034de:	8b 46 48             	mov    0x48(%esi),%eax
f01034e1:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0) // Don't create a negative env_id.
f01034e6:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01034eb:	ba 00 10 00 00       	mov    $0x1000,%edx
f01034f0:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01034f3:	89 f2                	mov    %esi,%edx
f01034f5:	2b 93 2c 23 00 00    	sub    0x232c(%ebx),%edx
f01034fb:	c1 fa 05             	sar    $0x5,%edx
f01034fe:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0103504:	09 d0                	or     %edx,%eax
f0103506:	89 46 48             	mov    %eax,0x48(%esi)
	e->env_parent_id = parent_id;
f0103509:	8b 45 0c             	mov    0xc(%ebp),%eax
f010350c:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f010350f:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f0103516:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f010351d:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103524:	83 ec 04             	sub    $0x4,%esp
f0103527:	6a 44                	push   $0x44
f0103529:	6a 00                	push   $0x0
f010352b:	56                   	push   %esi
f010352c:	e8 c1 1b 00 00       	call   f01050f2 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0103531:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f0103537:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f010353d:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f0103543:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f010354a:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	env_free_list = e->env_link;
f0103550:	8b 46 44             	mov    0x44(%esi),%eax
f0103553:	89 83 30 23 00 00    	mov    %eax,0x2330(%ebx)
	*newenv_store = e;
f0103559:	8b 45 08             	mov    0x8(%ebp),%eax
f010355c:	89 30                	mov    %esi,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010355e:	8b 4e 48             	mov    0x48(%esi),%ecx
f0103561:	8b 83 28 23 00 00    	mov    0x2328(%ebx),%eax
f0103567:	83 c4 10             	add    $0x10,%esp
f010356a:	ba 00 00 00 00       	mov    $0x0,%edx
f010356f:	85 c0                	test   %eax,%eax
f0103571:	74 03                	je     f0103576 <env_alloc+0x12f>
f0103573:	8b 50 48             	mov    0x48(%eax),%edx
f0103576:	83 ec 04             	sub    $0x4,%esp
f0103579:	51                   	push   %ecx
f010357a:	52                   	push   %edx
f010357b:	8d 83 d9 95 f7 ff    	lea    -0x86a27(%ebx),%eax
f0103581:	50                   	push   %eax
f0103582:	e8 14 05 00 00       	call   f0103a9b <cprintf>
	return 0;
f0103587:	83 c4 10             	add    $0x10,%esp
f010358a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010358f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103592:	5b                   	pop    %ebx
f0103593:	5e                   	pop    %esi
f0103594:	5d                   	pop    %ebp
f0103595:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103596:	50                   	push   %eax
f0103597:	8d 83 f0 89 f7 ff    	lea    -0x87610(%ebx),%eax
f010359d:	50                   	push   %eax
f010359e:	6a 56                	push   $0x56
f01035a0:	8d 83 79 92 f7 ff    	lea    -0x86d87(%ebx),%eax
f01035a6:	50                   	push   %eax
f01035a7:	e8 05 cb ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035ac:	50                   	push   %eax
f01035ad:	8d 83 f4 8a f7 ff    	lea    -0x8750c(%ebx),%eax
f01035b3:	50                   	push   %eax
f01035b4:	68 ce 00 00 00       	push   $0xce
f01035b9:	8d 83 ce 95 f7 ff    	lea    -0x86a32(%ebx),%eax
f01035bf:	50                   	push   %eax
f01035c0:	e8 ec ca ff ff       	call   f01000b1 <_panic>
		return -E_NO_FREE_ENV;
f01035c5:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01035ca:	eb c3                	jmp    f010358f <env_alloc+0x148>
		return -E_NO_MEM;
f01035cc:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01035d1:	eb bc                	jmp    f010358f <env_alloc+0x148>

f01035d3 <env_create>:
// This function is ONLY called during kernel initialization,
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
// 使用 env_alloc 分配一个新环境，使用 load_icode 将命名的 elf 二进制文件加载到其中，并设置其 env_type
void env_create(uint8_t *binary, enum EnvType type)
{
f01035d3:	55                   	push   %ebp
f01035d4:	89 e5                	mov    %esp,%ebp
f01035d6:	57                   	push   %edi
f01035d7:	56                   	push   %esi
f01035d8:	53                   	push   %ebx
f01035d9:	83 ec 34             	sub    $0x34,%esp
f01035dc:	e8 86 cb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01035e1:	81 c3 3f 9a 08 00    	add    $0x89a3f,%ebx
	// LAB 3: Your code here.
	struct Env *e;
	if (env_alloc(&e, 0))
f01035e7:	6a 00                	push   $0x0
f01035e9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01035ec:	50                   	push   %eax
f01035ed:	e8 55 fe ff ff       	call   f0103447 <env_alloc>
f01035f2:	83 c4 10             	add    $0x10,%esp
f01035f5:	85 c0                	test   %eax,%eax
f01035f7:	75 3a                	jne    f0103633 <env_create+0x60>
	{
		panic("env_create: error in env_alloc()");
	}
	load_icode(e, binary);
f01035f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	if (ELFHDR->e_magic != ELF_MAGIC)
f01035fc:	8b 45 08             	mov    0x8(%ebp),%eax
f01035ff:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0103605:	75 47                	jne    f010364e <env_create+0x7b>
	ph = (struct Proghdr *)((uint8_t *)ELFHDR + ELFHDR->e_phoff); // ELFHDR+offset是段的起始地址
f0103607:	8b 45 08             	mov    0x8(%ebp),%eax
f010360a:	89 c6                	mov    %eax,%esi
f010360c:	03 70 1c             	add    0x1c(%eax),%esi
	eph = ph + ELFHDR->e_phnum;									  // end地址
f010360f:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
f0103613:	c1 e0 05             	shl    $0x5,%eax
f0103616:	01 f0                	add    %esi,%eax
f0103618:	89 c1                	mov    %eax,%ecx
	lcr3(PADDR(e->env_pgdir));									  // 切换到用户空间
f010361a:	8b 47 5c             	mov    0x5c(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f010361d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103622:	76 45                	jbe    f0103669 <env_create+0x96>
	return (physaddr_t)kva - KERNBASE;
f0103624:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103629:	0f 22 d8             	mov    %eax,%cr3
f010362c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010362f:	89 cf                	mov    %ecx,%edi
f0103631:	eb 52                	jmp    f0103685 <env_create+0xb2>
		panic("env_create: error in env_alloc()");
f0103633:	83 ec 04             	sub    $0x4,%esp
f0103636:	8d 83 4c 95 f7 ff    	lea    -0x86ab4(%ebx),%eax
f010363c:	50                   	push   %eax
f010363d:	68 92 01 00 00       	push   $0x192
f0103642:	8d 83 ce 95 f7 ff    	lea    -0x86a32(%ebx),%eax
f0103648:	50                   	push   %eax
f0103649:	e8 63 ca ff ff       	call   f01000b1 <_panic>
		panic("load_icode: ELFHDR is not ELF_MAGIC\n");
f010364e:	83 ec 04             	sub    $0x4,%esp
f0103651:	8d 83 70 95 f7 ff    	lea    -0x86a90(%ebx),%eax
f0103657:	50                   	push   %eax
f0103658:	68 6b 01 00 00       	push   $0x16b
f010365d:	8d 83 ce 95 f7 ff    	lea    -0x86a32(%ebx),%eax
f0103663:	50                   	push   %eax
f0103664:	e8 48 ca ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103669:	50                   	push   %eax
f010366a:	8d 83 f4 8a f7 ff    	lea    -0x8750c(%ebx),%eax
f0103670:	50                   	push   %eax
f0103671:	68 70 01 00 00       	push   $0x170
f0103676:	8d 83 ce 95 f7 ff    	lea    -0x86a32(%ebx),%eax
f010367c:	50                   	push   %eax
f010367d:	e8 2f ca ff ff       	call   f01000b1 <_panic>
	for (; ph < eph; ph++)										  // 依次读取所有段
f0103682:	83 c6 20             	add    $0x20,%esi
f0103685:	39 f7                	cmp    %esi,%edi
f0103687:	76 3d                	jbe    f01036c6 <env_create+0xf3>
		if (ph->p_type == ELF_PROG_LOAD)
f0103689:	83 3e 01             	cmpl   $0x1,(%esi)
f010368c:	75 f4                	jne    f0103682 <env_create+0xaf>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);						   // 先分配内存空间
f010368e:	8b 4e 14             	mov    0x14(%esi),%ecx
f0103691:	8b 56 08             	mov    0x8(%esi),%edx
f0103694:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103697:	e8 f7 fb ff ff       	call   f0103293 <region_alloc>
			memset((void *)ph->p_va, 0, ph->p_memsz);							   // 将内存空间初始化为0
f010369c:	83 ec 04             	sub    $0x4,%esp
f010369f:	ff 76 14             	pushl  0x14(%esi)
f01036a2:	6a 00                	push   $0x0
f01036a4:	ff 76 08             	pushl  0x8(%esi)
f01036a7:	e8 46 1a 00 00       	call   f01050f2 <memset>
			memcpy((void *)ph->p_va, (void *)ELFHDR + ph->p_offset, ph->p_filesz); // 复制内容到刚刚分配的空间
f01036ac:	83 c4 0c             	add    $0xc,%esp
f01036af:	ff 76 10             	pushl  0x10(%esi)
f01036b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01036b5:	03 46 04             	add    0x4(%esi),%eax
f01036b8:	50                   	push   %eax
f01036b9:	ff 76 08             	pushl  0x8(%esi)
f01036bc:	e8 e6 1a 00 00       	call   f01051a7 <memcpy>
f01036c1:	83 c4 10             	add    $0x10,%esp
f01036c4:	eb bc                	jmp    f0103682 <env_create+0xaf>
f01036c6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
	lcr3(PADDR(kern_pgdir));							 // 切换到内核空间
f01036c9:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f01036cf:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01036d1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036d6:	76 41                	jbe    f0103719 <env_create+0x146>
	return (physaddr_t)kva - KERNBASE;
f01036d8:	05 00 00 00 10       	add    $0x10000000,%eax
f01036dd:	0f 22 d8             	mov    %eax,%cr3
	region_alloc(e, (void *)USTACKTOP - PGSIZE, PGSIZE); // 为程序的初始堆栈(地址:USTACKTOP - PGSIZE)映射一页
f01036e0:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01036e5:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01036ea:	89 f8                	mov    %edi,%eax
f01036ec:	e8 a2 fb ff ff       	call   f0103293 <region_alloc>
	e->env_status = ENV_RUNNABLE;						 // 设置程序状态
f01036f1:	c7 47 54 02 00 00 00 	movl   $0x2,0x54(%edi)
	e->env_tf.tf_esp = USTACKTOP;						 // 设置程序堆栈
f01036f8:	c7 47 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%edi)
	e->env_tf.tf_eip = ELFHDR->e_entry;					 // 设置程序入口
f01036ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0103702:	8b 40 18             	mov    0x18(%eax),%eax
f0103705:	89 47 30             	mov    %eax,0x30(%edi)
	e->env_type = type;
f0103708:	8b 55 0c             	mov    0xc(%ebp),%edx
f010370b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010370e:	89 50 50             	mov    %edx,0x50(%eax)
}
f0103711:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103714:	5b                   	pop    %ebx
f0103715:	5e                   	pop    %esi
f0103716:	5f                   	pop    %edi
f0103717:	5d                   	pop    %ebp
f0103718:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103719:	50                   	push   %eax
f010371a:	8d 83 f4 8a f7 ff    	lea    -0x8750c(%ebx),%eax
f0103720:	50                   	push   %eax
f0103721:	68 7e 01 00 00       	push   $0x17e
f0103726:	8d 83 ce 95 f7 ff    	lea    -0x86a32(%ebx),%eax
f010372c:	50                   	push   %eax
f010372d:	e8 7f c9 ff ff       	call   f01000b1 <_panic>

f0103732 <env_free>:

//
// Frees env e and all memory it uses.
//
void env_free(struct Env *e)
{
f0103732:	55                   	push   %ebp
f0103733:	89 e5                	mov    %esp,%ebp
f0103735:	57                   	push   %edi
f0103736:	56                   	push   %esi
f0103737:	53                   	push   %ebx
f0103738:	83 ec 2c             	sub    $0x2c,%esp
f010373b:	e8 27 ca ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103740:	81 c3 e0 98 08 00    	add    $0x898e0,%ebx
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103746:	8b 93 28 23 00 00    	mov    0x2328(%ebx),%edx
f010374c:	3b 55 08             	cmp    0x8(%ebp),%edx
f010374f:	75 17                	jne    f0103768 <env_free+0x36>
		lcr3(PADDR(kern_pgdir));
f0103751:	c7 c0 08 00 19 f0    	mov    $0xf0190008,%eax
f0103757:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103759:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010375e:	76 46                	jbe    f01037a6 <env_free+0x74>
	return (physaddr_t)kva - KERNBASE;
f0103760:	05 00 00 00 10       	add    $0x10000000,%eax
f0103765:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103768:	8b 45 08             	mov    0x8(%ebp),%eax
f010376b:	8b 48 48             	mov    0x48(%eax),%ecx
f010376e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103773:	85 d2                	test   %edx,%edx
f0103775:	74 03                	je     f010377a <env_free+0x48>
f0103777:	8b 42 48             	mov    0x48(%edx),%eax
f010377a:	83 ec 04             	sub    $0x4,%esp
f010377d:	51                   	push   %ecx
f010377e:	50                   	push   %eax
f010377f:	8d 83 ee 95 f7 ff    	lea    -0x86a12(%ebx),%eax
f0103785:	50                   	push   %eax
f0103786:	e8 10 03 00 00       	call   f0103a9b <cprintf>
f010378b:	83 c4 10             	add    $0x10,%esp
f010378e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	if (PGNUM(pa) >= npages)
f0103795:	c7 c0 04 00 19 f0    	mov    $0xf0190004,%eax
f010379b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (PGNUM(pa) >= npages)
f010379e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01037a1:	e9 9f 00 00 00       	jmp    f0103845 <env_free+0x113>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037a6:	50                   	push   %eax
f01037a7:	8d 83 f4 8a f7 ff    	lea    -0x8750c(%ebx),%eax
f01037ad:	50                   	push   %eax
f01037ae:	68 a5 01 00 00       	push   $0x1a5
f01037b3:	8d 83 ce 95 f7 ff    	lea    -0x86a32(%ebx),%eax
f01037b9:	50                   	push   %eax
f01037ba:	e8 f2 c8 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01037bf:	50                   	push   %eax
f01037c0:	8d 83 f0 89 f7 ff    	lea    -0x87610(%ebx),%eax
f01037c6:	50                   	push   %eax
f01037c7:	68 b5 01 00 00       	push   $0x1b5
f01037cc:	8d 83 ce 95 f7 ff    	lea    -0x86a32(%ebx),%eax
f01037d2:	50                   	push   %eax
f01037d3:	e8 d9 c8 ff ff       	call   f01000b1 <_panic>
f01037d8:	83 c6 04             	add    $0x4,%esi
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t *)KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++)
f01037db:	39 fe                	cmp    %edi,%esi
f01037dd:	74 24                	je     f0103803 <env_free+0xd1>
		{
			if (pt[pteno] & PTE_P)
f01037df:	f6 06 01             	testb  $0x1,(%esi)
f01037e2:	74 f4                	je     f01037d8 <env_free+0xa6>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01037e4:	83 ec 08             	sub    $0x8,%esp
f01037e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01037ea:	01 f0                	add    %esi,%eax
f01037ec:	c1 e0 0a             	shl    $0xa,%eax
f01037ef:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01037f2:	50                   	push   %eax
f01037f3:	8b 45 08             	mov    0x8(%ebp),%eax
f01037f6:	ff 70 5c             	pushl  0x5c(%eax)
f01037f9:	e8 f3 da ff ff       	call   f01012f1 <page_remove>
f01037fe:	83 c4 10             	add    $0x10,%esp
f0103801:	eb d5                	jmp    f01037d8 <env_free+0xa6>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103803:	8b 45 08             	mov    0x8(%ebp),%eax
f0103806:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103809:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010380c:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103813:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103816:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103819:	3b 10                	cmp    (%eax),%edx
f010381b:	73 6f                	jae    f010388c <env_free+0x15a>
		page_decref(pa2page(pa));
f010381d:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103820:	c7 c0 0c 00 19 f0    	mov    $0xf019000c,%eax
f0103826:	8b 00                	mov    (%eax),%eax
f0103828:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010382b:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010382e:	50                   	push   %eax
f010382f:	e8 e1 d8 ff ff       	call   f0101115 <page_decref>
f0103834:	83 c4 10             	add    $0x10,%esp
f0103837:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f010383b:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++)
f010383e:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103843:	74 5f                	je     f01038a4 <env_free+0x172>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103845:	8b 45 08             	mov    0x8(%ebp),%eax
f0103848:	8b 40 5c             	mov    0x5c(%eax),%eax
f010384b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010384e:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0103851:	a8 01                	test   $0x1,%al
f0103853:	74 e2                	je     f0103837 <env_free+0x105>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103855:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010385a:	89 c2                	mov    %eax,%edx
f010385c:	c1 ea 0c             	shr    $0xc,%edx
f010385f:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0103862:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103865:	39 11                	cmp    %edx,(%ecx)
f0103867:	0f 86 52 ff ff ff    	jbe    f01037bf <env_free+0x8d>
	return (void *)(pa + KERNBASE);
f010386d:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103873:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103876:	c1 e2 14             	shl    $0x14,%edx
f0103879:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010387c:	8d b8 00 10 00 f0    	lea    -0xffff000(%eax),%edi
f0103882:	f7 d8                	neg    %eax
f0103884:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103887:	e9 53 ff ff ff       	jmp    f01037df <env_free+0xad>
		panic("pa2page called with invalid pa");
f010388c:	83 ec 04             	sub    $0x4,%esp
f010388f:	8d 83 5c 8b f7 ff    	lea    -0x874a4(%ebx),%eax
f0103895:	50                   	push   %eax
f0103896:	6a 4f                	push   $0x4f
f0103898:	8d 83 79 92 f7 ff    	lea    -0x86d87(%ebx),%eax
f010389e:	50                   	push   %eax
f010389f:	e8 0d c8 ff ff       	call   f01000b1 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01038a4:	8b 45 08             	mov    0x8(%ebp),%eax
f01038a7:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01038aa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01038af:	76 57                	jbe    f0103908 <env_free+0x1d6>
	e->env_pgdir = 0;
f01038b1:	8b 55 08             	mov    0x8(%ebp),%edx
f01038b4:	c7 42 5c 00 00 00 00 	movl   $0x0,0x5c(%edx)
	return (physaddr_t)kva - KERNBASE;
f01038bb:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f01038c0:	c1 e8 0c             	shr    $0xc,%eax
f01038c3:	c7 c2 04 00 19 f0    	mov    $0xf0190004,%edx
f01038c9:	3b 02                	cmp    (%edx),%eax
f01038cb:	73 54                	jae    f0103921 <env_free+0x1ef>
	page_decref(pa2page(pa));
f01038cd:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01038d0:	c7 c2 0c 00 19 f0    	mov    $0xf019000c,%edx
f01038d6:	8b 12                	mov    (%edx),%edx
f01038d8:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01038db:	50                   	push   %eax
f01038dc:	e8 34 d8 ff ff       	call   f0101115 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01038e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01038e4:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f01038eb:	8b 83 30 23 00 00    	mov    0x2330(%ebx),%eax
f01038f1:	8b 55 08             	mov    0x8(%ebp),%edx
f01038f4:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f01038f7:	89 93 30 23 00 00    	mov    %edx,0x2330(%ebx)
}
f01038fd:	83 c4 10             	add    $0x10,%esp
f0103900:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103903:	5b                   	pop    %ebx
f0103904:	5e                   	pop    %esi
f0103905:	5f                   	pop    %edi
f0103906:	5d                   	pop    %ebp
f0103907:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103908:	50                   	push   %eax
f0103909:	8d 83 f4 8a f7 ff    	lea    -0x8750c(%ebx),%eax
f010390f:	50                   	push   %eax
f0103910:	68 c4 01 00 00       	push   $0x1c4
f0103915:	8d 83 ce 95 f7 ff    	lea    -0x86a32(%ebx),%eax
f010391b:	50                   	push   %eax
f010391c:	e8 90 c7 ff ff       	call   f01000b1 <_panic>
		panic("pa2page called with invalid pa");
f0103921:	83 ec 04             	sub    $0x4,%esp
f0103924:	8d 83 5c 8b f7 ff    	lea    -0x874a4(%ebx),%eax
f010392a:	50                   	push   %eax
f010392b:	6a 4f                	push   $0x4f
f010392d:	8d 83 79 92 f7 ff    	lea    -0x86d87(%ebx),%eax
f0103933:	50                   	push   %eax
f0103934:	e8 78 c7 ff ff       	call   f01000b1 <_panic>

f0103939 <env_destroy>:

//
// Frees environment e.
//
void env_destroy(struct Env *e)
{
f0103939:	55                   	push   %ebp
f010393a:	89 e5                	mov    %esp,%ebp
f010393c:	53                   	push   %ebx
f010393d:	83 ec 10             	sub    $0x10,%esp
f0103940:	e8 22 c8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103945:	81 c3 db 96 08 00    	add    $0x896db,%ebx
	env_free(e);
f010394b:	ff 75 08             	pushl  0x8(%ebp)
f010394e:	e8 df fd ff ff       	call   f0103732 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0103953:	8d 83 98 95 f7 ff    	lea    -0x86a68(%ebx),%eax
f0103959:	89 04 24             	mov    %eax,(%esp)
f010395c:	e8 3a 01 00 00       	call   f0103a9b <cprintf>
f0103961:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0103964:	83 ec 0c             	sub    $0xc,%esp
f0103967:	6a 00                	push   $0x0
f0103969:	e8 a5 cf ff ff       	call   f0100913 <monitor>
f010396e:	83 c4 10             	add    $0x10,%esp
f0103971:	eb f1                	jmp    f0103964 <env_destroy+0x2b>

f0103973 <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
//
// This function does not return.
//
void env_pop_tf(struct Trapframe *tf)
{
f0103973:	55                   	push   %ebp
f0103974:	89 e5                	mov    %esp,%ebp
f0103976:	53                   	push   %ebx
f0103977:	83 ec 08             	sub    $0x8,%esp
f010397a:	e8 e8 c7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010397f:	81 c3 a1 96 08 00    	add    $0x896a1,%ebx
	asm volatile(
f0103985:	8b 65 08             	mov    0x8(%ebp),%esp
f0103988:	61                   	popa   
f0103989:	07                   	pop    %es
f010398a:	1f                   	pop    %ds
f010398b:	83 c4 08             	add    $0x8,%esp
f010398e:	cf                   	iret   
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		:
		: "g"(tf)
		: "memory");
	panic("iret failed"); /* mostly to placate the compiler */
f010398f:	8d 83 04 96 f7 ff    	lea    -0x869fc(%ebx),%eax
f0103995:	50                   	push   %eax
f0103996:	68 ec 01 00 00       	push   $0x1ec
f010399b:	8d 83 ce 95 f7 ff    	lea    -0x86a32(%ebx),%eax
f01039a1:	50                   	push   %eax
f01039a2:	e8 0a c7 ff ff       	call   f01000b1 <_panic>

f01039a7 <env_run>:
// Note: if this is the first call to env_run, curenv is NULL.
//
// This function does not return.
// 把环境从curenv 切换到 e
void env_run(struct Env *e)
{
f01039a7:	55                   	push   %ebp
f01039a8:	89 e5                	mov    %esp,%ebp
f01039aa:	53                   	push   %ebx
f01039ab:	83 ec 04             	sub    $0x4,%esp
f01039ae:	e8 b4 c7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01039b3:	81 c3 6d 96 08 00    	add    $0x8966d,%ebx
f01039b9:	8b 45 08             	mov    0x8(%ebp),%eax
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	if (curenv) // 如果当前有环境
f01039bc:	8b 93 28 23 00 00    	mov    0x2328(%ebx),%edx
f01039c2:	85 d2                	test   %edx,%edx
f01039c4:	74 07                	je     f01039cd <env_run+0x26>
	{
		curenv->env_status = ENV_RUNNABLE; // 设置回 ENV_RUNNABLE
f01039c6:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	}
	curenv = e;						  // 将“curenv”设置为新环境
f01039cd:	89 83 28 23 00 00    	mov    %eax,0x2328(%ebx)
	curenv->env_status = ENV_RUNNING; // 将其状态设置为 ENV_RUNNING
f01039d3:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;				  // 更新其“env_runs”计数器
f01039da:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));	  // 切换到用户空间
f01039de:	8b 50 5c             	mov    0x5c(%eax),%edx
	if ((uint32_t)kva < KERNBASE)
f01039e1:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01039e7:	77 19                	ja     f0103a02 <env_run+0x5b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039e9:	52                   	push   %edx
f01039ea:	8d 83 f4 8a f7 ff    	lea    -0x8750c(%ebx),%eax
f01039f0:	50                   	push   %eax
f01039f1:	68 11 02 00 00       	push   $0x211
f01039f6:	8d 83 ce 95 f7 ff    	lea    -0x86a32(%ebx),%eax
f01039fc:	50                   	push   %eax
f01039fd:	e8 af c6 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103a02:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103a08:	0f 22 da             	mov    %edx,%cr3
	env_pop_tf(&e->env_tf); // 恢复环境的寄存器来进入环境中的用户模式，设置%eip为可执行程序的第一条指令
f0103a0b:	83 ec 0c             	sub    $0xc,%esp
f0103a0e:	50                   	push   %eax
f0103a0f:	e8 5f ff ff ff       	call   f0103973 <env_pop_tf>

f0103a14 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103a14:	55                   	push   %ebp
f0103a15:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103a17:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a1a:	ba 70 00 00 00       	mov    $0x70,%edx
f0103a1f:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103a20:	ba 71 00 00 00       	mov    $0x71,%edx
f0103a25:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103a26:	0f b6 c0             	movzbl %al,%eax
}
f0103a29:	5d                   	pop    %ebp
f0103a2a:	c3                   	ret    

f0103a2b <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103a2b:	55                   	push   %ebp
f0103a2c:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103a2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a31:	ba 70 00 00 00       	mov    $0x70,%edx
f0103a36:	ee                   	out    %al,(%dx)
f0103a37:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a3a:	ba 71 00 00 00       	mov    $0x71,%edx
f0103a3f:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103a40:	5d                   	pop    %ebp
f0103a41:	c3                   	ret    

f0103a42 <putch>:
#include <inc/stdio.h>
#include <inc/stdarg.h>

// putch通过调用console.c中的cputchar来实现输出字符串到控制台。
static void putch(int ch, int *cnt)
{
f0103a42:	55                   	push   %ebp
f0103a43:	89 e5                	mov    %esp,%ebp
f0103a45:	53                   	push   %ebx
f0103a46:	83 ec 10             	sub    $0x10,%esp
f0103a49:	e8 19 c7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103a4e:	81 c3 d2 95 08 00    	add    $0x895d2,%ebx
	cputchar(ch);
f0103a54:	ff 75 08             	pushl  0x8(%ebp)
f0103a57:	e8 82 cc ff ff       	call   f01006de <cputchar>
	*cnt++;
}
f0103a5c:	83 c4 10             	add    $0x10,%esp
f0103a5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103a62:	c9                   	leave  
f0103a63:	c3                   	ret    

f0103a64 <vcprintf>:

// 将格式fmt和可变参数列表ap一起传给printfmt.c中的vprintfmt处理
int vcprintf(const char *fmt, va_list ap)
{
f0103a64:	55                   	push   %ebp
f0103a65:	89 e5                	mov    %esp,%ebp
f0103a67:	53                   	push   %ebx
f0103a68:	83 ec 14             	sub    $0x14,%esp
f0103a6b:	e8 f7 c6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103a70:	81 c3 b0 95 08 00    	add    $0x895b0,%ebx
	int cnt = 0;
f0103a76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	vprintfmt((void *)putch, &cnt, fmt, ap); // 用一个指向putch的函数指针来告诉vprintfmt，处理后的数据应该交给putch来输出
f0103a7d:	ff 75 0c             	pushl  0xc(%ebp)
f0103a80:	ff 75 08             	pushl  0x8(%ebp)
f0103a83:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103a86:	50                   	push   %eax
f0103a87:	8d 83 22 6a f7 ff    	lea    -0x895de(%ebx),%eax
f0103a8d:	50                   	push   %eax
f0103a8e:	e8 de 0e 00 00       	call   f0104971 <vprintfmt>
	return cnt;
}
f0103a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103a96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103a99:	c9                   	leave  
f0103a9a:	c3                   	ret    

f0103a9b <cprintf>:

// 这个函数作为实现打印功能的主要函数，暴露给其他程序。其第一个参数是包含输出格式的字符串，后面是可变参数列表。
int cprintf(const char *fmt, ...)
{
f0103a9b:	55                   	push   %ebp
f0103a9c:	89 e5                	mov    %esp,%ebp
f0103a9e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);		 // 获取可变参数列表ap
f0103aa1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap); // 传参
f0103aa4:	50                   	push   %eax
f0103aa5:	ff 75 08             	pushl  0x8(%ebp)
f0103aa8:	e8 b7 ff ff ff       	call   f0103a64 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103aad:	c9                   	leave  
f0103aae:	c3                   	ret    

f0103aaf <trap_init_percpu>:
	// Per-CPU setup
	trap_init_percpu();
}

void trap_init_percpu(void) // 初始化TSS和IDT
{
f0103aaf:	55                   	push   %ebp
f0103ab0:	89 e5                	mov    %esp,%ebp
f0103ab2:	57                   	push   %edi
f0103ab3:	56                   	push   %esi
f0103ab4:	53                   	push   %ebx
f0103ab5:	83 ec 04             	sub    $0x4,%esp
f0103ab8:	e8 aa c6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103abd:	81 c3 63 95 08 00    	add    $0x89563,%ebx
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103ac3:	c7 83 64 2b 00 00 00 	movl   $0xf0000000,0x2b64(%ebx)
f0103aca:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103acd:	66 c7 83 68 2b 00 00 	movw   $0x10,0x2b68(%ebx)
f0103ad4:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0103ad6:	66 c7 83 c6 2b 00 00 	movw   $0x68,0x2bc6(%ebx)
f0103add:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t)(&ts),
f0103adf:	c7 c0 00 c3 11 f0    	mov    $0xf011c300,%eax
f0103ae5:	66 c7 40 28 67 00    	movw   $0x67,0x28(%eax)
f0103aeb:	8d b3 60 2b 00 00    	lea    0x2b60(%ebx),%esi
f0103af1:	66 89 70 2a          	mov    %si,0x2a(%eax)
f0103af5:	89 f2                	mov    %esi,%edx
f0103af7:	c1 ea 10             	shr    $0x10,%edx
f0103afa:	88 50 2c             	mov    %dl,0x2c(%eax)
f0103afd:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
f0103b01:	83 e2 f0             	and    $0xfffffff0,%edx
f0103b04:	83 ca 09             	or     $0x9,%edx
f0103b07:	83 e2 9f             	and    $0xffffff9f,%edx
f0103b0a:	83 ca 80             	or     $0xffffff80,%edx
f0103b0d:	88 55 f3             	mov    %dl,-0xd(%ebp)
f0103b10:	88 50 2d             	mov    %dl,0x2d(%eax)
f0103b13:	0f b6 48 2e          	movzbl 0x2e(%eax),%ecx
f0103b17:	83 e1 c0             	and    $0xffffffc0,%ecx
f0103b1a:	83 c9 40             	or     $0x40,%ecx
f0103b1d:	83 e1 7f             	and    $0x7f,%ecx
f0103b20:	88 48 2e             	mov    %cl,0x2e(%eax)
f0103b23:	c1 ee 18             	shr    $0x18,%esi
f0103b26:	89 f1                	mov    %esi,%ecx
f0103b28:	88 48 2f             	mov    %cl,0x2f(%eax)
							  sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103b2b:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
f0103b2f:	83 e2 ef             	and    $0xffffffef,%edx
f0103b32:	88 50 2d             	mov    %dl,0x2d(%eax)
	asm volatile("ltr %0" : : "r" (sel));
f0103b35:	b8 28 00 00 00       	mov    $0x28,%eax
f0103b3a:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0103b3d:	8d 83 e8 1f 00 00    	lea    0x1fe8(%ebx),%eax
f0103b43:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103b46:	83 c4 04             	add    $0x4,%esp
f0103b49:	5b                   	pop    %ebx
f0103b4a:	5e                   	pop    %esi
f0103b4b:	5f                   	pop    %edi
f0103b4c:	5d                   	pop    %ebp
f0103b4d:	c3                   	ret    

f0103b4e <trap_init>:
{
f0103b4e:	55                   	push   %ebp
f0103b4f:	89 e5                	mov    %esp,%ebp
f0103b51:	53                   	push   %ebx
f0103b52:	e8 b2 cb ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f0103b57:	05 c9 94 08 00       	add    $0x894c9,%eax
	SETGATE(idt[T_DIVIDE], 1, GD_KT, DIVIDE_Handler, 0); // SETGATE设置一个idt条目
f0103b5c:	c7 c2 1c 43 10 f0    	mov    $0xf010431c,%edx
f0103b62:	66 89 90 40 23 00 00 	mov    %dx,0x2340(%eax)
f0103b69:	66 c7 80 42 23 00 00 	movw   $0x8,0x2342(%eax)
f0103b70:	08 00 
f0103b72:	c6 80 44 23 00 00 00 	movb   $0x0,0x2344(%eax)
f0103b79:	c6 80 45 23 00 00 8f 	movb   $0x8f,0x2345(%eax)
f0103b80:	c1 ea 10             	shr    $0x10,%edx
f0103b83:	66 89 90 46 23 00 00 	mov    %dx,0x2346(%eax)
	SETGATE(idt[T_DEBUG], 1, GD_KT, DEBUG_Handler, 3);
f0103b8a:	c7 c2 22 43 10 f0    	mov    $0xf0104322,%edx
f0103b90:	66 89 90 48 23 00 00 	mov    %dx,0x2348(%eax)
f0103b97:	66 c7 80 4a 23 00 00 	movw   $0x8,0x234a(%eax)
f0103b9e:	08 00 
f0103ba0:	c6 80 4c 23 00 00 00 	movb   $0x0,0x234c(%eax)
f0103ba7:	c6 80 4d 23 00 00 ef 	movb   $0xef,0x234d(%eax)
f0103bae:	c1 ea 10             	shr    $0x10,%edx
f0103bb1:	66 89 90 4e 23 00 00 	mov    %dx,0x234e(%eax)
	SETGATE(idt[T_NMI], 1, GD_KT, NMI_Handler, 0);
f0103bb8:	c7 c2 28 43 10 f0    	mov    $0xf0104328,%edx
f0103bbe:	66 89 90 50 23 00 00 	mov    %dx,0x2350(%eax)
f0103bc5:	66 c7 80 52 23 00 00 	movw   $0x8,0x2352(%eax)
f0103bcc:	08 00 
f0103bce:	c6 80 54 23 00 00 00 	movb   $0x0,0x2354(%eax)
f0103bd5:	c6 80 55 23 00 00 8f 	movb   $0x8f,0x2355(%eax)
f0103bdc:	c1 ea 10             	shr    $0x10,%edx
f0103bdf:	66 89 90 56 23 00 00 	mov    %dx,0x2356(%eax)
	SETGATE(idt[T_BRKPT], 1, GD_KT, BRKPT_Handler, 3);
f0103be6:	c7 c2 2e 43 10 f0    	mov    $0xf010432e,%edx
f0103bec:	66 89 90 58 23 00 00 	mov    %dx,0x2358(%eax)
f0103bf3:	66 c7 80 5a 23 00 00 	movw   $0x8,0x235a(%eax)
f0103bfa:	08 00 
f0103bfc:	c6 80 5c 23 00 00 00 	movb   $0x0,0x235c(%eax)
f0103c03:	c6 80 5d 23 00 00 ef 	movb   $0xef,0x235d(%eax)
f0103c0a:	c1 ea 10             	shr    $0x10,%edx
f0103c0d:	66 89 90 5e 23 00 00 	mov    %dx,0x235e(%eax)
	SETGATE(idt[T_OFLOW], 1, GD_KT, OFLOW_Handler, 0);
f0103c14:	c7 c2 34 43 10 f0    	mov    $0xf0104334,%edx
f0103c1a:	66 89 90 60 23 00 00 	mov    %dx,0x2360(%eax)
f0103c21:	66 c7 80 62 23 00 00 	movw   $0x8,0x2362(%eax)
f0103c28:	08 00 
f0103c2a:	c6 80 64 23 00 00 00 	movb   $0x0,0x2364(%eax)
f0103c31:	c6 80 65 23 00 00 8f 	movb   $0x8f,0x2365(%eax)
f0103c38:	c1 ea 10             	shr    $0x10,%edx
f0103c3b:	66 89 90 66 23 00 00 	mov    %dx,0x2366(%eax)
	SETGATE(idt[T_BOUND], 1, GD_KT, BOUND_Handler, 0);
f0103c42:	c7 c2 3a 43 10 f0    	mov    $0xf010433a,%edx
f0103c48:	66 89 90 68 23 00 00 	mov    %dx,0x2368(%eax)
f0103c4f:	66 c7 80 6a 23 00 00 	movw   $0x8,0x236a(%eax)
f0103c56:	08 00 
f0103c58:	c6 80 6c 23 00 00 00 	movb   $0x0,0x236c(%eax)
f0103c5f:	c6 80 6d 23 00 00 8f 	movb   $0x8f,0x236d(%eax)
f0103c66:	c1 ea 10             	shr    $0x10,%edx
f0103c69:	66 89 90 6e 23 00 00 	mov    %dx,0x236e(%eax)
	SETGATE(idt[T_ILLOP], 1, GD_KT, ILLOP_Handler, 0);
f0103c70:	c7 c2 40 43 10 f0    	mov    $0xf0104340,%edx
f0103c76:	66 89 90 70 23 00 00 	mov    %dx,0x2370(%eax)
f0103c7d:	66 c7 80 72 23 00 00 	movw   $0x8,0x2372(%eax)
f0103c84:	08 00 
f0103c86:	c6 80 74 23 00 00 00 	movb   $0x0,0x2374(%eax)
f0103c8d:	c6 80 75 23 00 00 8f 	movb   $0x8f,0x2375(%eax)
f0103c94:	c1 ea 10             	shr    $0x10,%edx
f0103c97:	66 89 90 76 23 00 00 	mov    %dx,0x2376(%eax)
	SETGATE(idt[T_DEVICE], 1, GD_KT, DEVICE_Handler, 0);
f0103c9e:	c7 c2 46 43 10 f0    	mov    $0xf0104346,%edx
f0103ca4:	66 89 90 78 23 00 00 	mov    %dx,0x2378(%eax)
f0103cab:	66 c7 80 7a 23 00 00 	movw   $0x8,0x237a(%eax)
f0103cb2:	08 00 
f0103cb4:	c6 80 7c 23 00 00 00 	movb   $0x0,0x237c(%eax)
f0103cbb:	c6 80 7d 23 00 00 8f 	movb   $0x8f,0x237d(%eax)
f0103cc2:	c1 ea 10             	shr    $0x10,%edx
f0103cc5:	66 89 90 7e 23 00 00 	mov    %dx,0x237e(%eax)
	SETGATE(idt[T_DBLFLT], 1, GD_KT, DBLFLT_Handler, 0);
f0103ccc:	c7 c2 4c 43 10 f0    	mov    $0xf010434c,%edx
f0103cd2:	66 89 90 80 23 00 00 	mov    %dx,0x2380(%eax)
f0103cd9:	66 c7 80 82 23 00 00 	movw   $0x8,0x2382(%eax)
f0103ce0:	08 00 
f0103ce2:	c6 80 84 23 00 00 00 	movb   $0x0,0x2384(%eax)
f0103ce9:	c6 80 85 23 00 00 8f 	movb   $0x8f,0x2385(%eax)
f0103cf0:	c1 ea 10             	shr    $0x10,%edx
f0103cf3:	66 89 90 86 23 00 00 	mov    %dx,0x2386(%eax)
	SETGATE(idt[T_TSS], 1, GD_KT, TSS_Handler, 0);
f0103cfa:	c7 c2 50 43 10 f0    	mov    $0xf0104350,%edx
f0103d00:	66 89 90 90 23 00 00 	mov    %dx,0x2390(%eax)
f0103d07:	66 c7 80 92 23 00 00 	movw   $0x8,0x2392(%eax)
f0103d0e:	08 00 
f0103d10:	c6 80 94 23 00 00 00 	movb   $0x0,0x2394(%eax)
f0103d17:	c6 80 95 23 00 00 8f 	movb   $0x8f,0x2395(%eax)
f0103d1e:	c1 ea 10             	shr    $0x10,%edx
f0103d21:	66 89 90 96 23 00 00 	mov    %dx,0x2396(%eax)
	SETGATE(idt[T_SEGNP], 1, GD_KT, SEGNP_Handler, 0);
f0103d28:	c7 c2 54 43 10 f0    	mov    $0xf0104354,%edx
f0103d2e:	66 89 90 98 23 00 00 	mov    %dx,0x2398(%eax)
f0103d35:	66 c7 80 9a 23 00 00 	movw   $0x8,0x239a(%eax)
f0103d3c:	08 00 
f0103d3e:	c6 80 9c 23 00 00 00 	movb   $0x0,0x239c(%eax)
f0103d45:	c6 80 9d 23 00 00 8f 	movb   $0x8f,0x239d(%eax)
f0103d4c:	c1 ea 10             	shr    $0x10,%edx
f0103d4f:	66 89 90 9e 23 00 00 	mov    %dx,0x239e(%eax)
	SETGATE(idt[T_STACK], 1, GD_KT, STACK_Handler, 0);
f0103d56:	c7 c2 58 43 10 f0    	mov    $0xf0104358,%edx
f0103d5c:	66 89 90 a0 23 00 00 	mov    %dx,0x23a0(%eax)
f0103d63:	66 c7 80 a2 23 00 00 	movw   $0x8,0x23a2(%eax)
f0103d6a:	08 00 
f0103d6c:	c6 80 a4 23 00 00 00 	movb   $0x0,0x23a4(%eax)
f0103d73:	c6 80 a5 23 00 00 8f 	movb   $0x8f,0x23a5(%eax)
f0103d7a:	c1 ea 10             	shr    $0x10,%edx
f0103d7d:	66 89 90 a6 23 00 00 	mov    %dx,0x23a6(%eax)
	SETGATE(idt[T_GPFLT], 1, GD_KT, GPFLT_Handler, 0);
f0103d84:	c7 c2 5c 43 10 f0    	mov    $0xf010435c,%edx
f0103d8a:	66 89 90 a8 23 00 00 	mov    %dx,0x23a8(%eax)
f0103d91:	66 c7 80 aa 23 00 00 	movw   $0x8,0x23aa(%eax)
f0103d98:	08 00 
f0103d9a:	c6 80 ac 23 00 00 00 	movb   $0x0,0x23ac(%eax)
f0103da1:	c6 80 ad 23 00 00 8f 	movb   $0x8f,0x23ad(%eax)
f0103da8:	c1 ea 10             	shr    $0x10,%edx
f0103dab:	66 89 90 ae 23 00 00 	mov    %dx,0x23ae(%eax)
	SETGATE(idt[T_PGFLT], 1, GD_KT, PGFLT_Handler, 0);
f0103db2:	c7 c1 60 43 10 f0    	mov    $0xf0104360,%ecx
f0103db8:	66 89 88 b0 23 00 00 	mov    %cx,0x23b0(%eax)
f0103dbf:	66 c7 80 b2 23 00 00 	movw   $0x8,0x23b2(%eax)
f0103dc6:	08 00 
f0103dc8:	c6 80 b4 23 00 00 00 	movb   $0x0,0x23b4(%eax)
f0103dcf:	c6 80 b5 23 00 00 8f 	movb   $0x8f,0x23b5(%eax)
f0103dd6:	89 cb                	mov    %ecx,%ebx
f0103dd8:	c1 eb 10             	shr    $0x10,%ebx
f0103ddb:	66 89 98 b6 23 00 00 	mov    %bx,0x23b6(%eax)
	SETGATE(idt[T_FPERR], 1, GD_KT, FPERR_Handler, 0);
f0103de2:	c7 c2 64 43 10 f0    	mov    $0xf0104364,%edx
f0103de8:	66 89 90 c0 23 00 00 	mov    %dx,0x23c0(%eax)
f0103def:	66 c7 80 c2 23 00 00 	movw   $0x8,0x23c2(%eax)
f0103df6:	08 00 
f0103df8:	c6 80 c4 23 00 00 00 	movb   $0x0,0x23c4(%eax)
f0103dff:	c6 80 c5 23 00 00 8f 	movb   $0x8f,0x23c5(%eax)
f0103e06:	c1 ea 10             	shr    $0x10,%edx
f0103e09:	66 89 90 c6 23 00 00 	mov    %dx,0x23c6(%eax)
	SETGATE(idt[T_ALIGN], 1, GD_KT, ALIGN_Handler, 0);
f0103e10:	c7 c2 68 43 10 f0    	mov    $0xf0104368,%edx
f0103e16:	66 89 90 c8 23 00 00 	mov    %dx,0x23c8(%eax)
f0103e1d:	66 c7 80 ca 23 00 00 	movw   $0x8,0x23ca(%eax)
f0103e24:	08 00 
f0103e26:	c6 80 cc 23 00 00 00 	movb   $0x0,0x23cc(%eax)
f0103e2d:	c6 80 cd 23 00 00 8f 	movb   $0x8f,0x23cd(%eax)
f0103e34:	c1 ea 10             	shr    $0x10,%edx
f0103e37:	66 89 90 ce 23 00 00 	mov    %dx,0x23ce(%eax)
	SETGATE(idt[T_MCHK], 1, GD_KT, MCHK_Handler, 0);
f0103e3e:	c7 c2 6c 43 10 f0    	mov    $0xf010436c,%edx
f0103e44:	66 89 90 d0 23 00 00 	mov    %dx,0x23d0(%eax)
f0103e4b:	66 c7 80 d2 23 00 00 	movw   $0x8,0x23d2(%eax)
f0103e52:	08 00 
f0103e54:	c6 80 d4 23 00 00 00 	movb   $0x0,0x23d4(%eax)
f0103e5b:	c6 80 d5 23 00 00 8f 	movb   $0x8f,0x23d5(%eax)
f0103e62:	c1 ea 10             	shr    $0x10,%edx
f0103e65:	66 89 90 d6 23 00 00 	mov    %dx,0x23d6(%eax)
	SETGATE(idt[T_SIMDERR], 1, GD_KT, PGFLT_Handler, 0);
f0103e6c:	66 89 88 d8 23 00 00 	mov    %cx,0x23d8(%eax)
f0103e73:	66 c7 80 da 23 00 00 	movw   $0x8,0x23da(%eax)
f0103e7a:	08 00 
f0103e7c:	c6 80 dc 23 00 00 00 	movb   $0x0,0x23dc(%eax)
f0103e83:	c6 80 dd 23 00 00 8f 	movb   $0x8f,0x23dd(%eax)
f0103e8a:	66 89 98 de 23 00 00 	mov    %bx,0x23de(%eax)
	SETGATE(idt[T_SYSCALL], 0, GD_KT, SYSCALL_Handler, 3);
f0103e91:	c7 c2 74 43 10 f0    	mov    $0xf0104374,%edx
f0103e97:	66 89 90 c0 24 00 00 	mov    %dx,0x24c0(%eax)
f0103e9e:	66 c7 80 c2 24 00 00 	movw   $0x8,0x24c2(%eax)
f0103ea5:	08 00 
f0103ea7:	c6 80 c4 24 00 00 00 	movb   $0x0,0x24c4(%eax)
f0103eae:	c6 80 c5 24 00 00 ee 	movb   $0xee,0x24c5(%eax)
f0103eb5:	c1 ea 10             	shr    $0x10,%edx
f0103eb8:	66 89 90 c6 24 00 00 	mov    %dx,0x24c6(%eax)
	trap_init_percpu();
f0103ebf:	e8 eb fb ff ff       	call   f0103aaf <trap_init_percpu>
}
f0103ec4:	5b                   	pop    %ebx
f0103ec5:	5d                   	pop    %ebp
f0103ec6:	c3                   	ret    

f0103ec7 <print_regs>:
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
	}
}

void print_regs(struct PushRegs *regs) // 打印寄存器的值，print_trapframe()的辅助函数
{
f0103ec7:	55                   	push   %ebp
f0103ec8:	89 e5                	mov    %esp,%ebp
f0103eca:	56                   	push   %esi
f0103ecb:	53                   	push   %ebx
f0103ecc:	e8 96 c2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103ed1:	81 c3 4f 91 08 00    	add    $0x8914f,%ebx
f0103ed7:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103eda:	83 ec 08             	sub    $0x8,%esp
f0103edd:	ff 36                	pushl  (%esi)
f0103edf:	8d 83 10 96 f7 ff    	lea    -0x869f0(%ebx),%eax
f0103ee5:	50                   	push   %eax
f0103ee6:	e8 b0 fb ff ff       	call   f0103a9b <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103eeb:	83 c4 08             	add    $0x8,%esp
f0103eee:	ff 76 04             	pushl  0x4(%esi)
f0103ef1:	8d 83 1f 96 f7 ff    	lea    -0x869e1(%ebx),%eax
f0103ef7:	50                   	push   %eax
f0103ef8:	e8 9e fb ff ff       	call   f0103a9b <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103efd:	83 c4 08             	add    $0x8,%esp
f0103f00:	ff 76 08             	pushl  0x8(%esi)
f0103f03:	8d 83 2e 96 f7 ff    	lea    -0x869d2(%ebx),%eax
f0103f09:	50                   	push   %eax
f0103f0a:	e8 8c fb ff ff       	call   f0103a9b <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103f0f:	83 c4 08             	add    $0x8,%esp
f0103f12:	ff 76 0c             	pushl  0xc(%esi)
f0103f15:	8d 83 3d 96 f7 ff    	lea    -0x869c3(%ebx),%eax
f0103f1b:	50                   	push   %eax
f0103f1c:	e8 7a fb ff ff       	call   f0103a9b <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103f21:	83 c4 08             	add    $0x8,%esp
f0103f24:	ff 76 10             	pushl  0x10(%esi)
f0103f27:	8d 83 4c 96 f7 ff    	lea    -0x869b4(%ebx),%eax
f0103f2d:	50                   	push   %eax
f0103f2e:	e8 68 fb ff ff       	call   f0103a9b <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103f33:	83 c4 08             	add    $0x8,%esp
f0103f36:	ff 76 14             	pushl  0x14(%esi)
f0103f39:	8d 83 5b 96 f7 ff    	lea    -0x869a5(%ebx),%eax
f0103f3f:	50                   	push   %eax
f0103f40:	e8 56 fb ff ff       	call   f0103a9b <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103f45:	83 c4 08             	add    $0x8,%esp
f0103f48:	ff 76 18             	pushl  0x18(%esi)
f0103f4b:	8d 83 6a 96 f7 ff    	lea    -0x86996(%ebx),%eax
f0103f51:	50                   	push   %eax
f0103f52:	e8 44 fb ff ff       	call   f0103a9b <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103f57:	83 c4 08             	add    $0x8,%esp
f0103f5a:	ff 76 1c             	pushl  0x1c(%esi)
f0103f5d:	8d 83 79 96 f7 ff    	lea    -0x86987(%ebx),%eax
f0103f63:	50                   	push   %eax
f0103f64:	e8 32 fb ff ff       	call   f0103a9b <cprintf>
}
f0103f69:	83 c4 10             	add    $0x10,%esp
f0103f6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103f6f:	5b                   	pop    %ebx
f0103f70:	5e                   	pop    %esi
f0103f71:	5d                   	pop    %ebp
f0103f72:	c3                   	ret    

f0103f73 <print_trapframe>:
{
f0103f73:	55                   	push   %ebp
f0103f74:	89 e5                	mov    %esp,%ebp
f0103f76:	57                   	push   %edi
f0103f77:	56                   	push   %esi
f0103f78:	53                   	push   %ebx
f0103f79:	83 ec 14             	sub    $0x14,%esp
f0103f7c:	e8 e6 c1 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103f81:	81 c3 9f 90 08 00    	add    $0x8909f,%ebx
f0103f87:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("TRAP frame at %p\n", tf);
f0103f8a:	56                   	push   %esi
f0103f8b:	8d 83 af 97 f7 ff    	lea    -0x86851(%ebx),%eax
f0103f91:	50                   	push   %eax
f0103f92:	e8 04 fb ff ff       	call   f0103a9b <cprintf>
	print_regs(&tf->tf_regs);
f0103f97:	89 34 24             	mov    %esi,(%esp)
f0103f9a:	e8 28 ff ff ff       	call   f0103ec7 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103f9f:	83 c4 08             	add    $0x8,%esp
f0103fa2:	0f b7 46 20          	movzwl 0x20(%esi),%eax
f0103fa6:	50                   	push   %eax
f0103fa7:	8d 83 ca 96 f7 ff    	lea    -0x86936(%ebx),%eax
f0103fad:	50                   	push   %eax
f0103fae:	e8 e8 fa ff ff       	call   f0103a9b <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103fb3:	83 c4 08             	add    $0x8,%esp
f0103fb6:	0f b7 46 24          	movzwl 0x24(%esi),%eax
f0103fba:	50                   	push   %eax
f0103fbb:	8d 83 dd 96 f7 ff    	lea    -0x86923(%ebx),%eax
f0103fc1:	50                   	push   %eax
f0103fc2:	e8 d4 fa ff ff       	call   f0103a9b <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103fc7:	8b 56 28             	mov    0x28(%esi),%edx
	if (trapno < ARRAY_SIZE(excnames))
f0103fca:	83 c4 10             	add    $0x10,%esp
f0103fcd:	83 fa 13             	cmp    $0x13,%edx
f0103fd0:	0f 86 e9 00 00 00    	jbe    f01040bf <print_trapframe+0x14c>
	return "(unknown trap)";
f0103fd6:	83 fa 30             	cmp    $0x30,%edx
f0103fd9:	8d 83 88 96 f7 ff    	lea    -0x86978(%ebx),%eax
f0103fdf:	8d 8b 94 96 f7 ff    	lea    -0x8696c(%ebx),%ecx
f0103fe5:	0f 45 c1             	cmovne %ecx,%eax
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103fe8:	83 ec 04             	sub    $0x4,%esp
f0103feb:	50                   	push   %eax
f0103fec:	52                   	push   %edx
f0103fed:	8d 83 f0 96 f7 ff    	lea    -0x86910(%ebx),%eax
f0103ff3:	50                   	push   %eax
f0103ff4:	e8 a2 fa ff ff       	call   f0103a9b <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103ff9:	83 c4 10             	add    $0x10,%esp
f0103ffc:	39 b3 40 2b 00 00    	cmp    %esi,0x2b40(%ebx)
f0104002:	0f 84 c3 00 00 00    	je     f01040cb <print_trapframe+0x158>
	cprintf("  err  0x%08x", tf->tf_err);
f0104008:	83 ec 08             	sub    $0x8,%esp
f010400b:	ff 76 2c             	pushl  0x2c(%esi)
f010400e:	8d 83 11 97 f7 ff    	lea    -0x868ef(%ebx),%eax
f0104014:	50                   	push   %eax
f0104015:	e8 81 fa ff ff       	call   f0103a9b <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f010401a:	83 c4 10             	add    $0x10,%esp
f010401d:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0104021:	0f 85 c9 00 00 00    	jne    f01040f0 <print_trapframe+0x17d>
				tf->tf_err & 1 ? "protection" : "not-present");
f0104027:	8b 46 2c             	mov    0x2c(%esi),%eax
		cprintf(" [%s, %s, %s]\n",
f010402a:	89 c2                	mov    %eax,%edx
f010402c:	83 e2 01             	and    $0x1,%edx
f010402f:	8d 8b a3 96 f7 ff    	lea    -0x8695d(%ebx),%ecx
f0104035:	8d 93 ae 96 f7 ff    	lea    -0x86952(%ebx),%edx
f010403b:	0f 44 ca             	cmove  %edx,%ecx
f010403e:	89 c2                	mov    %eax,%edx
f0104040:	83 e2 02             	and    $0x2,%edx
f0104043:	8d 93 ba 96 f7 ff    	lea    -0x86946(%ebx),%edx
f0104049:	8d bb c0 96 f7 ff    	lea    -0x86940(%ebx),%edi
f010404f:	0f 44 d7             	cmove  %edi,%edx
f0104052:	83 e0 04             	and    $0x4,%eax
f0104055:	8d 83 c5 96 f7 ff    	lea    -0x8693b(%ebx),%eax
f010405b:	8d bb da 97 f7 ff    	lea    -0x86826(%ebx),%edi
f0104061:	0f 44 c7             	cmove  %edi,%eax
f0104064:	51                   	push   %ecx
f0104065:	52                   	push   %edx
f0104066:	50                   	push   %eax
f0104067:	8d 83 1f 97 f7 ff    	lea    -0x868e1(%ebx),%eax
f010406d:	50                   	push   %eax
f010406e:	e8 28 fa ff ff       	call   f0103a9b <cprintf>
f0104073:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104076:	83 ec 08             	sub    $0x8,%esp
f0104079:	ff 76 30             	pushl  0x30(%esi)
f010407c:	8d 83 2e 97 f7 ff    	lea    -0x868d2(%ebx),%eax
f0104082:	50                   	push   %eax
f0104083:	e8 13 fa ff ff       	call   f0103a9b <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104088:	83 c4 08             	add    $0x8,%esp
f010408b:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010408f:	50                   	push   %eax
f0104090:	8d 83 3d 97 f7 ff    	lea    -0x868c3(%ebx),%eax
f0104096:	50                   	push   %eax
f0104097:	e8 ff f9 ff ff       	call   f0103a9b <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010409c:	83 c4 08             	add    $0x8,%esp
f010409f:	ff 76 38             	pushl  0x38(%esi)
f01040a2:	8d 83 50 97 f7 ff    	lea    -0x868b0(%ebx),%eax
f01040a8:	50                   	push   %eax
f01040a9:	e8 ed f9 ff ff       	call   f0103a9b <cprintf>
	if ((tf->tf_cs & 3) != 0)
f01040ae:	83 c4 10             	add    $0x10,%esp
f01040b1:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f01040b5:	75 50                	jne    f0104107 <print_trapframe+0x194>
}
f01040b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01040ba:	5b                   	pop    %ebx
f01040bb:	5e                   	pop    %esi
f01040bc:	5f                   	pop    %edi
f01040bd:	5d                   	pop    %ebp
f01040be:	c3                   	ret    
		return excnames[trapno];
f01040bf:	8b 84 93 60 20 00 00 	mov    0x2060(%ebx,%edx,4),%eax
f01040c6:	e9 1d ff ff ff       	jmp    f0103fe8 <print_trapframe+0x75>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01040cb:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f01040cf:	0f 85 33 ff ff ff    	jne    f0104008 <print_trapframe+0x95>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01040d5:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01040d8:	83 ec 08             	sub    $0x8,%esp
f01040db:	50                   	push   %eax
f01040dc:	8d 83 02 97 f7 ff    	lea    -0x868fe(%ebx),%eax
f01040e2:	50                   	push   %eax
f01040e3:	e8 b3 f9 ff ff       	call   f0103a9b <cprintf>
f01040e8:	83 c4 10             	add    $0x10,%esp
f01040eb:	e9 18 ff ff ff       	jmp    f0104008 <print_trapframe+0x95>
		cprintf("\n");
f01040f0:	83 ec 0c             	sub    $0xc,%esp
f01040f3:	8d 83 c7 94 f7 ff    	lea    -0x86b39(%ebx),%eax
f01040f9:	50                   	push   %eax
f01040fa:	e8 9c f9 ff ff       	call   f0103a9b <cprintf>
f01040ff:	83 c4 10             	add    $0x10,%esp
f0104102:	e9 6f ff ff ff       	jmp    f0104076 <print_trapframe+0x103>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104107:	83 ec 08             	sub    $0x8,%esp
f010410a:	ff 76 3c             	pushl  0x3c(%esi)
f010410d:	8d 83 5f 97 f7 ff    	lea    -0x868a1(%ebx),%eax
f0104113:	50                   	push   %eax
f0104114:	e8 82 f9 ff ff       	call   f0103a9b <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104119:	83 c4 08             	add    $0x8,%esp
f010411c:	0f b7 46 40          	movzwl 0x40(%esi),%eax
f0104120:	50                   	push   %eax
f0104121:	8d 83 6e 97 f7 ff    	lea    -0x86892(%ebx),%eax
f0104127:	50                   	push   %eax
f0104128:	e8 6e f9 ff ff       	call   f0103a9b <cprintf>
f010412d:	83 c4 10             	add    $0x10,%esp
}
f0104130:	eb 85                	jmp    f01040b7 <print_trapframe+0x144>

f0104132 <page_fault_handler>:
	assert(curenv && curenv->env_status == ENV_RUNNING);
	env_run(curenv); // 返回用户态
}

void page_fault_handler(struct Trapframe *tf) // 特殊处理页错误中断
{
f0104132:	55                   	push   %ebp
f0104133:	89 e5                	mov    %esp,%ebp
f0104135:	57                   	push   %edi
f0104136:	56                   	push   %esi
f0104137:	53                   	push   %ebx
f0104138:	83 ec 0c             	sub    $0xc,%esp
f010413b:	e8 27 c0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104140:	81 c3 e0 8e 08 00    	add    $0x88ee0,%ebx
f0104146:	8b 75 08             	mov    0x8(%ebp),%esi
f0104149:	0f 20 d0             	mov    %cr2,%eax
	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0) // 处于内核模式
f010414c:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0104150:	74 38                	je     f010418a <page_fault_handler+0x58>
	}
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104152:	ff 76 30             	pushl  0x30(%esi)
f0104155:	50                   	push   %eax
f0104156:	c7 c7 48 f3 18 f0    	mov    $0xf018f348,%edi
f010415c:	8b 07                	mov    (%edi),%eax
f010415e:	ff 70 48             	pushl  0x48(%eax)
f0104161:	8d 83 54 99 f7 ff    	lea    -0x866ac(%ebx),%eax
f0104167:	50                   	push   %eax
f0104168:	e8 2e f9 ff ff       	call   f0103a9b <cprintf>
			curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010416d:	89 34 24             	mov    %esi,(%esp)
f0104170:	e8 fe fd ff ff       	call   f0103f73 <print_trapframe>
	env_destroy(curenv);
f0104175:	83 c4 04             	add    $0x4,%esp
f0104178:	ff 37                	pushl  (%edi)
f010417a:	e8 ba f7 ff ff       	call   f0103939 <env_destroy>
}
f010417f:	83 c4 10             	add    $0x10,%esp
f0104182:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104185:	5b                   	pop    %ebx
f0104186:	5e                   	pop    %esi
f0104187:	5f                   	pop    %edi
f0104188:	5d                   	pop    %ebp
f0104189:	c3                   	ret    
		panic("page_fault_handler(): kernel-mode page faults");
f010418a:	83 ec 04             	sub    $0x4,%esp
f010418d:	8d 83 24 99 f7 ff    	lea    -0x866dc(%ebx),%eax
f0104193:	50                   	push   %eax
f0104194:	68 0d 01 00 00       	push   $0x10d
f0104199:	8d 83 81 97 f7 ff    	lea    -0x8687f(%ebx),%eax
f010419f:	50                   	push   %eax
f01041a0:	e8 0c bf ff ff       	call   f01000b1 <_panic>

f01041a5 <trap>:
{
f01041a5:	55                   	push   %ebp
f01041a6:	89 e5                	mov    %esp,%ebp
f01041a8:	57                   	push   %edi
f01041a9:	56                   	push   %esi
f01041aa:	53                   	push   %ebx
f01041ab:	83 ec 0c             	sub    $0xc,%esp
f01041ae:	e8 b4 bf ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01041b3:	81 c3 6d 8e 08 00    	add    $0x88e6d,%ebx
f01041b9:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::
f01041bc:	fc                   	cld    
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01041bd:	9c                   	pushf  
f01041be:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f01041bf:	f6 c4 02             	test   $0x2,%ah
f01041c2:	74 1f                	je     f01041e3 <trap+0x3e>
f01041c4:	8d 83 8d 97 f7 ff    	lea    -0x86873(%ebx),%eax
f01041ca:	50                   	push   %eax
f01041cb:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01041d1:	50                   	push   %eax
f01041d2:	68 e5 00 00 00       	push   $0xe5
f01041d7:	8d 83 81 97 f7 ff    	lea    -0x8687f(%ebx),%eax
f01041dd:	50                   	push   %eax
f01041de:	e8 ce be ff ff       	call   f01000b1 <_panic>
	cprintf("Incoming TRAP frame at %p\n", tf);
f01041e3:	83 ec 08             	sub    $0x8,%esp
f01041e6:	56                   	push   %esi
f01041e7:	8d 83 a6 97 f7 ff    	lea    -0x8685a(%ebx),%eax
f01041ed:	50                   	push   %eax
f01041ee:	e8 a8 f8 ff ff       	call   f0103a9b <cprintf>
	if ((tf->tf_cs & 3) == 3) // 通过tf_cs的低位判断权限级别，进而判断现在处于用户模式(=3)还是内核模式(=0)
f01041f3:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01041f7:	83 e0 03             	and    $0x3,%eax
f01041fa:	83 c4 10             	add    $0x10,%esp
f01041fd:	66 83 f8 03          	cmp    $0x3,%ax
f0104201:	75 1d                	jne    f0104220 <trap+0x7b>
		assert(curenv);
f0104203:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f0104209:	8b 00                	mov    (%eax),%eax
f010420b:	85 c0                	test   %eax,%eax
f010420d:	74 5d                	je     f010426c <trap+0xc7>
		curenv->env_tf = *tf;
f010420f:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104214:	89 c7                	mov    %eax,%edi
f0104216:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104218:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f010421e:	8b 30                	mov    (%eax),%esi
	last_tf = tf;
f0104220:	89 b3 40 2b 00 00    	mov    %esi,0x2b40(%ebx)
	switch (tf->tf_trapno)
f0104226:	8b 46 28             	mov    0x28(%esi),%eax
f0104229:	83 f8 0e             	cmp    $0xe,%eax
f010422c:	74 5d                	je     f010428b <trap+0xe6>
f010422e:	83 f8 30             	cmp    $0x30,%eax
f0104231:	0f 84 9f 00 00 00    	je     f01042d6 <trap+0x131>
f0104237:	83 f8 03             	cmp    $0x3,%eax
f010423a:	0f 84 88 00 00 00    	je     f01042c8 <trap+0x123>
	print_trapframe(tf);
f0104240:	83 ec 0c             	sub    $0xc,%esp
f0104243:	56                   	push   %esi
f0104244:	e8 2a fd ff ff       	call   f0103f73 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104249:	83 c4 10             	add    $0x10,%esp
f010424c:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104251:	0f 84 a0 00 00 00    	je     f01042f7 <trap+0x152>
		env_destroy(curenv);
f0104257:	83 ec 0c             	sub    $0xc,%esp
f010425a:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f0104260:	ff 30                	pushl  (%eax)
f0104262:	e8 d2 f6 ff ff       	call   f0103939 <env_destroy>
f0104267:	83 c4 10             	add    $0x10,%esp
f010426a:	eb 2b                	jmp    f0104297 <trap+0xf2>
		assert(curenv);
f010426c:	8d 83 c1 97 f7 ff    	lea    -0x8683f(%ebx),%eax
f0104272:	50                   	push   %eax
f0104273:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f0104279:	50                   	push   %eax
f010427a:	68 ec 00 00 00       	push   $0xec
f010427f:	8d 83 81 97 f7 ff    	lea    -0x8687f(%ebx),%eax
f0104285:	50                   	push   %eax
f0104286:	e8 26 be ff ff       	call   f01000b1 <_panic>
		page_fault_handler(tf);
f010428b:	83 ec 0c             	sub    $0xc,%esp
f010428e:	56                   	push   %esi
f010428f:	e8 9e fe ff ff       	call   f0104132 <page_fault_handler>
f0104294:	83 c4 10             	add    $0x10,%esp
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0104297:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f010429d:	8b 00                	mov    (%eax),%eax
f010429f:	85 c0                	test   %eax,%eax
f01042a1:	74 06                	je     f01042a9 <trap+0x104>
f01042a3:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01042a7:	74 69                	je     f0104312 <trap+0x16d>
f01042a9:	8d 83 78 99 f7 ff    	lea    -0x86688(%ebx),%eax
f01042af:	50                   	push   %eax
f01042b0:	8d 83 93 92 f7 ff    	lea    -0x86d6d(%ebx),%eax
f01042b6:	50                   	push   %eax
f01042b7:	68 fe 00 00 00       	push   $0xfe
f01042bc:	8d 83 81 97 f7 ff    	lea    -0x8687f(%ebx),%eax
f01042c2:	50                   	push   %eax
f01042c3:	e8 e9 bd ff ff       	call   f01000b1 <_panic>
		monitor(tf);
f01042c8:	83 ec 0c             	sub    $0xc,%esp
f01042cb:	56                   	push   %esi
f01042cc:	e8 42 c6 ff ff       	call   f0100913 <monitor>
f01042d1:	83 c4 10             	add    $0x10,%esp
f01042d4:	eb c1                	jmp    f0104297 <trap+0xf2>
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx,
f01042d6:	83 ec 08             	sub    $0x8,%esp
f01042d9:	ff 76 04             	pushl  0x4(%esi)
f01042dc:	ff 36                	pushl  (%esi)
f01042de:	ff 76 10             	pushl  0x10(%esi)
f01042e1:	ff 76 18             	pushl  0x18(%esi)
f01042e4:	ff 76 14             	pushl  0x14(%esi)
f01042e7:	ff 76 1c             	pushl  0x1c(%esi)
f01042ea:	e8 9c 00 00 00       	call   f010438b <syscall>
f01042ef:	89 46 1c             	mov    %eax,0x1c(%esi)
f01042f2:	83 c4 20             	add    $0x20,%esp
f01042f5:	eb a0                	jmp    f0104297 <trap+0xf2>
		panic("unhandled trap in kernel");
f01042f7:	83 ec 04             	sub    $0x4,%esp
f01042fa:	8d 83 c8 97 f7 ff    	lea    -0x86838(%ebx),%eax
f0104300:	50                   	push   %eax
f0104301:	68 d3 00 00 00       	push   $0xd3
f0104306:	8d 83 81 97 f7 ff    	lea    -0x8687f(%ebx),%eax
f010430c:	50                   	push   %eax
f010430d:	e8 9f bd ff ff       	call   f01000b1 <_panic>
	env_run(curenv); // 返回用户态
f0104312:	83 ec 0c             	sub    $0xc,%esp
f0104315:	50                   	push   %eax
f0104316:	e8 8c f6 ff ff       	call   f01039a7 <env_run>
f010431b:	90                   	nop

f010431c <DIVIDE_Handler>:
 * TRAPHANDLER(name, num):是一个宏，等效于一个从name标记的地址开始的几行指令
 * name是你为这个num的中断设置的中断处理程序的函数名，num由inc\trap.h定义
 * 经过下面的设置，这个汇编文件里存在很多个以handler为名的函数，可以在C中使用void XXX_Hander()去声明函数，
 * 这时，这个hander函数的地址将被链接到下面对应hander的行。
 */
TRAPHANDLER_NOEC(DIVIDE_Handler, T_DIVIDE)
f010431c:	6a 00                	push   $0x0
f010431e:	6a 00                	push   $0x0
f0104320:	eb 58                	jmp    f010437a <_alltraps>

f0104322 <DEBUG_Handler>:
TRAPHANDLER_NOEC(DEBUG_Handler, T_DEBUG)
f0104322:	6a 00                	push   $0x0
f0104324:	6a 01                	push   $0x1
f0104326:	eb 52                	jmp    f010437a <_alltraps>

f0104328 <NMI_Handler>:
TRAPHANDLER_NOEC(NMI_Handler, T_NMI)
f0104328:	6a 00                	push   $0x0
f010432a:	6a 02                	push   $0x2
f010432c:	eb 4c                	jmp    f010437a <_alltraps>

f010432e <BRKPT_Handler>:
TRAPHANDLER_NOEC(BRKPT_Handler, T_BRKPT)
f010432e:	6a 00                	push   $0x0
f0104330:	6a 03                	push   $0x3
f0104332:	eb 46                	jmp    f010437a <_alltraps>

f0104334 <OFLOW_Handler>:
TRAPHANDLER_NOEC(OFLOW_Handler, T_OFLOW)
f0104334:	6a 00                	push   $0x0
f0104336:	6a 04                	push   $0x4
f0104338:	eb 40                	jmp    f010437a <_alltraps>

f010433a <BOUND_Handler>:
TRAPHANDLER_NOEC(BOUND_Handler, T_BOUND)
f010433a:	6a 00                	push   $0x0
f010433c:	6a 05                	push   $0x5
f010433e:	eb 3a                	jmp    f010437a <_alltraps>

f0104340 <ILLOP_Handler>:
TRAPHANDLER_NOEC(ILLOP_Handler, T_ILLOP)
f0104340:	6a 00                	push   $0x0
f0104342:	6a 06                	push   $0x6
f0104344:	eb 34                	jmp    f010437a <_alltraps>

f0104346 <DEVICE_Handler>:
TRAPHANDLER_NOEC(DEVICE_Handler, T_DEVICE)
f0104346:	6a 00                	push   $0x0
f0104348:	6a 07                	push   $0x7
f010434a:	eb 2e                	jmp    f010437a <_alltraps>

f010434c <DBLFLT_Handler>:
TRAPHANDLER(DBLFLT_Handler, T_DBLFLT)
f010434c:	6a 08                	push   $0x8
f010434e:	eb 2a                	jmp    f010437a <_alltraps>

f0104350 <TSS_Handler>:

TRAPHANDLER(TSS_Handler, T_TSS)
f0104350:	6a 0a                	push   $0xa
f0104352:	eb 26                	jmp    f010437a <_alltraps>

f0104354 <SEGNP_Handler>:
TRAPHANDLER(SEGNP_Handler, T_SEGNP)
f0104354:	6a 0b                	push   $0xb
f0104356:	eb 22                	jmp    f010437a <_alltraps>

f0104358 <STACK_Handler>:
TRAPHANDLER(STACK_Handler, T_STACK)
f0104358:	6a 0c                	push   $0xc
f010435a:	eb 1e                	jmp    f010437a <_alltraps>

f010435c <GPFLT_Handler>:
TRAPHANDLER(GPFLT_Handler, T_GPFLT)
f010435c:	6a 0d                	push   $0xd
f010435e:	eb 1a                	jmp    f010437a <_alltraps>

f0104360 <PGFLT_Handler>:
TRAPHANDLER(PGFLT_Handler, T_PGFLT)
f0104360:	6a 0e                	push   $0xe
f0104362:	eb 16                	jmp    f010437a <_alltraps>

f0104364 <FPERR_Handler>:

TRAPHANDLER(FPERR_Handler, T_FPERR)
f0104364:	6a 10                	push   $0x10
f0104366:	eb 12                	jmp    f010437a <_alltraps>

f0104368 <ALIGN_Handler>:
TRAPHANDLER(ALIGN_Handler, T_ALIGN)
f0104368:	6a 11                	push   $0x11
f010436a:	eb 0e                	jmp    f010437a <_alltraps>

f010436c <MCHK_Handler>:
TRAPHANDLER(MCHK_Handler, T_MCHK)
f010436c:	6a 12                	push   $0x12
f010436e:	eb 0a                	jmp    f010437a <_alltraps>

f0104370 <SIMDERR_Handler>:
TRAPHANDLER(SIMDERR_Handler, T_SIMDERR)
f0104370:	6a 13                	push   $0x13
f0104372:	eb 06                	jmp    f010437a <_alltraps>

f0104374 <SYSCALL_Handler>:

TRAPHANDLER_NOEC(SYSCALL_Handler, T_SYSCALL)
f0104374:	6a 00                	push   $0x0
f0104376:	6a 30                	push   $0x30
f0104378:	eb 00                	jmp    f010437a <_alltraps>

f010437a <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
.globl		_start
_alltraps:
	pushl	%ds		/* 后面要将GD_KD加载到%ds和%es，先保存旧的 */
f010437a:	1e                   	push   %ds
	pushl	%es
f010437b:	06                   	push   %es
	pushal			/* 直接推送整个TrapFrame */
f010437c:	60                   	pusha  
	movw 	$GD_KD, %ax /* 不能直接设置，因此先复制到%ax */
f010437d:	66 b8 10 00          	mov    $0x10,%ax
  	movw 	%ax, %ds
f0104381:	8e d8                	mov    %eax,%ds
  	movw 	%ax, %es
f0104383:	8e c0                	mov    %eax,%es
	pushl 	%esp	/* %esp指向Trapframe顶部，作为参数传递给trap */
f0104385:	54                   	push   %esp
	call	trap	/* 调用c程序trap，执行中断处理程序 */
f0104386:	e8 1a fe ff ff       	call   f01041a5 <trap>

f010438b <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010438b:	55                   	push   %ebp
f010438c:	89 e5                	mov    %esp,%ebp
f010438e:	53                   	push   %ebx
f010438f:	83 ec 14             	sub    $0x14,%esp
f0104392:	e8 d0 bd ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104397:	81 c3 89 8c 08 00    	add    $0x88c89,%ebx
f010439d:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) // 根据系统调用编号，调用相应的处理函数，枚举值即为inc\syscall.h中定义的值
f01043a0:	83 f8 01             	cmp    $0x1,%eax
f01043a3:	74 4d                	je     f01043f2 <syscall+0x67>
f01043a5:	83 f8 01             	cmp    $0x1,%eax
f01043a8:	72 11                	jb     f01043bb <syscall+0x30>
f01043aa:	83 f8 02             	cmp    $0x2,%eax
f01043ad:	74 4a                	je     f01043f9 <syscall+0x6e>
f01043af:	83 f8 03             	cmp    $0x3,%eax
f01043b2:	74 52                	je     f0104406 <syscall+0x7b>
		return sys_getenvid();
	case SYS_env_destroy:
		return sys_env_destroy((envid_t)a1);
	case NSYSCALLS:
	default:
		return -E_INVAL;
f01043b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01043b9:	eb 32                	jmp    f01043ed <syscall+0x62>
	user_mem_assert(curenv, s, len, PTE_U);
f01043bb:	6a 04                	push   $0x4
f01043bd:	ff 75 10             	pushl  0x10(%ebp)
f01043c0:	ff 75 0c             	pushl  0xc(%ebp)
f01043c3:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f01043c9:	ff 30                	pushl  (%eax)
f01043cb:	e8 5e ee ff ff       	call   f010322e <user_mem_assert>
	cprintf("%.*s", len, s);
f01043d0:	83 c4 0c             	add    $0xc,%esp
f01043d3:	ff 75 0c             	pushl  0xc(%ebp)
f01043d6:	ff 75 10             	pushl  0x10(%ebp)
f01043d9:	8d 83 a4 99 f7 ff    	lea    -0x8665c(%ebx),%eax
f01043df:	50                   	push   %eax
f01043e0:	e8 b6 f6 ff ff       	call   f0103a9b <cprintf>
f01043e5:	83 c4 10             	add    $0x10,%esp
		return 0;
f01043e8:	b8 00 00 00 00       	mov    $0x0,%eax
	}
}
f01043ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01043f0:	c9                   	leave  
f01043f1:	c3                   	ret    
	return cons_getc();
f01043f2:	e8 6b c1 ff ff       	call   f0100562 <cons_getc>
		return sys_cgetc();
f01043f7:	eb f4                	jmp    f01043ed <syscall+0x62>
	return curenv->env_id;
f01043f9:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f01043ff:	8b 00                	mov    (%eax),%eax
f0104401:	8b 40 48             	mov    0x48(%eax),%eax
		return sys_getenvid();
f0104404:	eb e7                	jmp    f01043ed <syscall+0x62>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104406:	83 ec 04             	sub    $0x4,%esp
f0104409:	6a 01                	push   $0x1
f010440b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010440e:	50                   	push   %eax
f010440f:	ff 75 0c             	pushl  0xc(%ebp)
f0104412:	e8 18 ef ff ff       	call   f010332f <envid2env>
f0104417:	83 c4 10             	add    $0x10,%esp
f010441a:	85 c0                	test   %eax,%eax
f010441c:	78 cf                	js     f01043ed <syscall+0x62>
	if (e == curenv)
f010441e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104421:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f0104427:	8b 00                	mov    (%eax),%eax
f0104429:	39 c2                	cmp    %eax,%edx
f010442b:	74 2d                	je     f010445a <syscall+0xcf>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010442d:	83 ec 04             	sub    $0x4,%esp
f0104430:	ff 72 48             	pushl  0x48(%edx)
f0104433:	ff 70 48             	pushl  0x48(%eax)
f0104436:	8d 83 c4 99 f7 ff    	lea    -0x8663c(%ebx),%eax
f010443c:	50                   	push   %eax
f010443d:	e8 59 f6 ff ff       	call   f0103a9b <cprintf>
f0104442:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104445:	83 ec 0c             	sub    $0xc,%esp
f0104448:	ff 75 f4             	pushl  -0xc(%ebp)
f010444b:	e8 e9 f4 ff ff       	call   f0103939 <env_destroy>
f0104450:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104453:	b8 00 00 00 00       	mov    $0x0,%eax
		return sys_env_destroy((envid_t)a1);
f0104458:	eb 93                	jmp    f01043ed <syscall+0x62>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010445a:	83 ec 08             	sub    $0x8,%esp
f010445d:	ff 70 48             	pushl  0x48(%eax)
f0104460:	8d 83 a9 99 f7 ff    	lea    -0x86657(%ebx),%eax
f0104466:	50                   	push   %eax
f0104467:	e8 2f f6 ff ff       	call   f0103a9b <cprintf>
f010446c:	83 c4 10             	add    $0x10,%esp
f010446f:	eb d4                	jmp    f0104445 <syscall+0xba>

f0104471 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
			   int type, uintptr_t addr)
{
f0104471:	55                   	push   %ebp
f0104472:	89 e5                	mov    %esp,%ebp
f0104474:	57                   	push   %edi
f0104475:	56                   	push   %esi
f0104476:	53                   	push   %ebx
f0104477:	83 ec 14             	sub    $0x14,%esp
f010447a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010447d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104480:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104483:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104486:	8b 32                	mov    (%edx),%esi
f0104488:	8b 01                	mov    (%ecx),%eax
f010448a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010448d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r)
f0104494:	eb 2f                	jmp    f01044c5 <stab_binsearch+0x54>
	{
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104496:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0104499:	39 c6                	cmp    %eax,%esi
f010449b:	7f 49                	jg     f01044e6 <stab_binsearch+0x75>
f010449d:	0f b6 0a             	movzbl (%edx),%ecx
f01044a0:	83 ea 0c             	sub    $0xc,%edx
f01044a3:	39 f9                	cmp    %edi,%ecx
f01044a5:	75 ef                	jne    f0104496 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr)
f01044a7:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01044aa:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01044ad:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01044b1:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01044b4:	73 35                	jae    f01044eb <stab_binsearch+0x7a>
		{
			*region_left = m;
f01044b6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01044b9:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f01044bb:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f01044be:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r)
f01044c5:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01044c8:	7f 4e                	jg     f0104518 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f01044ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01044cd:	01 f0                	add    %esi,%eax
f01044cf:	89 c3                	mov    %eax,%ebx
f01044d1:	c1 eb 1f             	shr    $0x1f,%ebx
f01044d4:	01 c3                	add    %eax,%ebx
f01044d6:	d1 fb                	sar    %ebx
f01044d8:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01044db:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01044de:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f01044e2:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f01044e4:	eb b3                	jmp    f0104499 <stab_binsearch+0x28>
			l = true_m + 1;
f01044e6:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f01044e9:	eb da                	jmp    f01044c5 <stab_binsearch+0x54>
		}
		else if (stabs[m].n_value > addr)
f01044eb:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01044ee:	76 14                	jbe    f0104504 <stab_binsearch+0x93>
		{
			*region_right = m - 1;
f01044f0:	83 e8 01             	sub    $0x1,%eax
f01044f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01044f6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01044f9:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f01044fb:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104502:	eb c1                	jmp    f01044c5 <stab_binsearch+0x54>
		}
		else
		{
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104504:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104507:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104509:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010450d:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f010450f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104516:	eb ad                	jmp    f01044c5 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0104518:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010451c:	74 16                	je     f0104534 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else
	{
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010451e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104521:	8b 00                	mov    (%eax),%eax
			 l > *region_left && stabs[l].n_type != type;
f0104523:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104526:	8b 0e                	mov    (%esi),%ecx
f0104528:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010452b:	8b 75 ec             	mov    -0x14(%ebp),%esi
f010452e:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0104532:	eb 12                	jmp    f0104546 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0104534:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104537:	8b 00                	mov    (%eax),%eax
f0104539:	83 e8 01             	sub    $0x1,%eax
f010453c:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010453f:	89 07                	mov    %eax,(%edi)
f0104541:	eb 16                	jmp    f0104559 <stab_binsearch+0xe8>
			 l--)
f0104543:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0104546:	39 c1                	cmp    %eax,%ecx
f0104548:	7d 0a                	jge    f0104554 <stab_binsearch+0xe3>
			 l > *region_left && stabs[l].n_type != type;
f010454a:	0f b6 1a             	movzbl (%edx),%ebx
f010454d:	83 ea 0c             	sub    $0xc,%edx
f0104550:	39 fb                	cmp    %edi,%ebx
f0104552:	75 ef                	jne    f0104543 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0104554:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104557:	89 07                	mov    %eax,(%edi)
	}
}
f0104559:	83 c4 14             	add    $0x14,%esp
f010455c:	5b                   	pop    %ebx
f010455d:	5e                   	pop    %esi
f010455e:	5f                   	pop    %edi
f010455f:	5d                   	pop    %ebp
f0104560:	c3                   	ret    

f0104561 <debuginfo_eip>:
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104561:	55                   	push   %ebp
f0104562:	89 e5                	mov    %esp,%ebp
f0104564:	57                   	push   %edi
f0104565:	56                   	push   %esi
f0104566:	53                   	push   %ebx
f0104567:	83 ec 4c             	sub    $0x4c,%esp
f010456a:	e8 f8 bb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010456f:	81 c3 b1 8a 08 00    	add    $0x88ab1,%ebx
f0104575:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104578:	8d 83 dc 99 f7 ff    	lea    -0x86624(%ebx),%eax
f010457e:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f0104580:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0104587:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f010458a:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0104591:	8b 45 08             	mov    0x8(%ebp),%eax
f0104594:	89 47 10             	mov    %eax,0x10(%edi)
	info->eip_fn_narg = 0;
f0104597:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM)
f010459e:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01045a3:	0f 86 34 01 00 00    	jbe    f01046dd <debuginfo_eip+0x17c>
	{
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01045a9:	c7 c0 de 21 11 f0    	mov    $0xf01121de,%eax
f01045af:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f01045b2:	c7 c0 19 f7 10 f0    	mov    $0xf010f719,%eax
f01045b8:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stab_end = __STAB_END__;
f01045bb:	c7 c6 18 f7 10 f0    	mov    $0xf010f718,%esi
		stabs = __STAB_BEGIN__;
f01045c1:	c7 c0 f8 6b 10 f0    	mov    $0xf0106bf8,%eax
f01045c7:	89 45 bc             	mov    %eax,-0x44(%ebp)
			user_mem_check(curenv, (void *)stabstr, (uintptr_t)stabstr_end - (uintptr_t)stabstr, PTE_U) < 0)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01045ca:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f01045cd:	39 4d b4             	cmp    %ecx,-0x4c(%ebp)
f01045d0:	0f 83 75 02 00 00    	jae    f010484b <debuginfo_eip+0x2ea>
f01045d6:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f01045da:	0f 85 72 02 00 00    	jne    f0104852 <debuginfo_eip+0x2f1>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01045e0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01045e7:	2b 75 bc             	sub    -0x44(%ebp),%esi
f01045ea:	c1 fe 02             	sar    $0x2,%esi
f01045ed:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f01045f3:	83 e8 01             	sub    $0x1,%eax
f01045f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01045f9:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01045fc:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01045ff:	83 ec 08             	sub    $0x8,%esp
f0104602:	ff 75 08             	pushl  0x8(%ebp)
f0104605:	6a 64                	push   $0x64
f0104607:	8b 75 bc             	mov    -0x44(%ebp),%esi
f010460a:	89 f0                	mov    %esi,%eax
f010460c:	e8 60 fe ff ff       	call   f0104471 <stab_binsearch>
	if (lfile == 0)
f0104611:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104614:	83 c4 10             	add    $0x10,%esp
f0104617:	85 c0                	test   %eax,%eax
f0104619:	0f 84 3a 02 00 00    	je     f0104859 <debuginfo_eip+0x2f8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010461f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104622:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104625:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104628:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010462b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010462e:	83 ec 08             	sub    $0x8,%esp
f0104631:	ff 75 08             	pushl  0x8(%ebp)
f0104634:	6a 24                	push   $0x24
f0104636:	89 f0                	mov    %esi,%eax
f0104638:	e8 34 fe ff ff       	call   f0104471 <stab_binsearch>

	if (lfun <= rfun)
f010463d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104640:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104643:	83 c4 10             	add    $0x10,%esp
f0104646:	39 d0                	cmp    %edx,%eax
f0104648:	0f 8f 1e 01 00 00    	jg     f010476c <debuginfo_eip+0x20b>
	{
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010464e:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104651:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104654:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104657:	8b 36                	mov    (%esi),%esi
f0104659:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f010465c:	2b 4d b4             	sub    -0x4c(%ebp),%ecx
f010465f:	39 ce                	cmp    %ecx,%esi
f0104661:	73 06                	jae    f0104669 <debuginfo_eip+0x108>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104663:	03 75 b4             	add    -0x4c(%ebp),%esi
f0104666:	89 77 08             	mov    %esi,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104669:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010466c:	8b 4e 08             	mov    0x8(%esi),%ecx
f010466f:	89 4f 10             	mov    %ecx,0x10(%edi)
		addr -= info->eip_fn_addr;
f0104672:	29 4d 08             	sub    %ecx,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0104675:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104678:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010467b:	83 ec 08             	sub    $0x8,%esp
f010467e:	6a 3a                	push   $0x3a
f0104680:	ff 77 08             	pushl  0x8(%edi)
f0104683:	e8 4e 0a 00 00       	call   f01050d6 <strfind>
f0104688:	2b 47 08             	sub    0x8(%edi),%eax
f010468b:	89 47 0c             	mov    %eax,0xc(%edi)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr); // 根据%eip的值作为地址查找
f010468e:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104691:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104694:	83 c4 08             	add    $0x8,%esp
f0104697:	ff 75 08             	pushl  0x8(%ebp)
f010469a:	6a 44                	push   $0x44
f010469c:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f010469f:	89 d8                	mov    %ebx,%eax
f01046a1:	e8 cb fd ff ff       	call   f0104471 <stab_binsearch>
	if (lline <= rline)									  // 二分查找，left<=right即终止
f01046a6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01046a9:	83 c4 10             	add    $0x10,%esp
f01046ac:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f01046af:	0f 8f ce 00 00 00    	jg     f0104783 <debuginfo_eip+0x222>
	{
		info->eip_line = stabs[lline].n_desc;
f01046b5:	89 d0                	mov    %edx,%eax
f01046b7:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01046ba:	c1 e2 02             	shl    $0x2,%edx
f01046bd:	0f b7 4c 13 06       	movzwl 0x6(%ebx,%edx,1),%ecx
f01046c2:	89 4f 04             	mov    %ecx,0x4(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile && stabs[lline].n_type != N_SOL && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01046c5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01046c8:	8d 54 13 04          	lea    0x4(%ebx,%edx,1),%edx
f01046cc:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f01046d0:	bb 01 00 00 00       	mov    $0x1,%ebx
f01046d5:	89 7d 0c             	mov    %edi,0xc(%ebp)
f01046d8:	e9 c0 00 00 00       	jmp    f010479d <debuginfo_eip+0x23c>
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0)
f01046dd:	6a 04                	push   $0x4
f01046df:	6a 10                	push   $0x10
f01046e1:	68 00 00 20 00       	push   $0x200000
f01046e6:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f01046ec:	ff 30                	pushl  (%eax)
f01046ee:	e8 b4 ea ff ff       	call   f01031a7 <user_mem_check>
f01046f3:	83 c4 10             	add    $0x10,%esp
f01046f6:	85 c0                	test   %eax,%eax
f01046f8:	0f 88 3f 01 00 00    	js     f010483d <debuginfo_eip+0x2dc>
		stabs = usd->stabs;
f01046fe:	8b 0d 00 00 20 00    	mov    0x200000,%ecx
f0104704:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stab_end = usd->stab_end;
f0104707:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f010470d:	a1 08 00 20 00       	mov    0x200008,%eax
f0104712:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0104715:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f010471b:	89 55 b8             	mov    %edx,-0x48(%ebp)
		if (user_mem_check(curenv, (void *)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, PTE_U) < 0 ||
f010471e:	6a 04                	push   $0x4
f0104720:	89 f0                	mov    %esi,%eax
f0104722:	29 c8                	sub    %ecx,%eax
f0104724:	50                   	push   %eax
f0104725:	51                   	push   %ecx
f0104726:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f010472c:	ff 30                	pushl  (%eax)
f010472e:	e8 74 ea ff ff       	call   f01031a7 <user_mem_check>
f0104733:	83 c4 10             	add    $0x10,%esp
f0104736:	85 c0                	test   %eax,%eax
f0104738:	0f 88 06 01 00 00    	js     f0104844 <debuginfo_eip+0x2e3>
			user_mem_check(curenv, (void *)stabstr, (uintptr_t)stabstr_end - (uintptr_t)stabstr, PTE_U) < 0)
f010473e:	6a 04                	push   $0x4
f0104740:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0104743:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f0104746:	29 ca                	sub    %ecx,%edx
f0104748:	52                   	push   %edx
f0104749:	51                   	push   %ecx
f010474a:	c7 c0 48 f3 18 f0    	mov    $0xf018f348,%eax
f0104750:	ff 30                	pushl  (%eax)
f0104752:	e8 50 ea ff ff       	call   f01031a7 <user_mem_check>
		if (user_mem_check(curenv, (void *)stabs, (uintptr_t)stab_end - (uintptr_t)stabs, PTE_U) < 0 ||
f0104757:	83 c4 10             	add    $0x10,%esp
f010475a:	85 c0                	test   %eax,%eax
f010475c:	0f 89 68 fe ff ff    	jns    f01045ca <debuginfo_eip+0x69>
			return -1;
f0104762:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104767:	e9 f9 00 00 00       	jmp    f0104865 <debuginfo_eip+0x304>
		info->eip_fn_addr = addr;
f010476c:	8b 45 08             	mov    0x8(%ebp),%eax
f010476f:	89 47 10             	mov    %eax,0x10(%edi)
		lline = lfile;
f0104772:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104775:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104778:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010477b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010477e:	e9 f8 fe ff ff       	jmp    f010467b <debuginfo_eip+0x11a>
		info->eip_line = 0;
f0104783:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
		return -1;
f010478a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010478f:	e9 d1 00 00 00       	jmp    f0104865 <debuginfo_eip+0x304>
f0104794:	83 e8 01             	sub    $0x1,%eax
f0104797:	83 ea 0c             	sub    $0xc,%edx
f010479a:	88 5d c4             	mov    %bl,-0x3c(%ebp)
f010479d:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile && stabs[lline].n_type != N_SOL && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01047a0:	39 c6                	cmp    %eax,%esi
f01047a2:	7f 24                	jg     f01047c8 <debuginfo_eip+0x267>
f01047a4:	0f b6 0a             	movzbl (%edx),%ecx
f01047a7:	80 f9 84             	cmp    $0x84,%cl
f01047aa:	74 46                	je     f01047f2 <debuginfo_eip+0x291>
f01047ac:	80 f9 64             	cmp    $0x64,%cl
f01047af:	75 e3                	jne    f0104794 <debuginfo_eip+0x233>
f01047b1:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f01047b5:	74 dd                	je     f0104794 <debuginfo_eip+0x233>
f01047b7:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01047ba:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01047be:	74 3b                	je     f01047fb <debuginfo_eip+0x29a>
f01047c0:	8b 75 c0             	mov    -0x40(%ebp),%esi
f01047c3:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01047c6:	eb 33                	jmp    f01047fb <debuginfo_eip+0x29a>
f01047c8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01047cb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01047ce:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
			 lline < rfun && stabs[lline].n_type == N_PSYM;
			 lline++)
			info->eip_fn_narg++;

	return 0;
f01047d1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f01047d6:	39 da                	cmp    %ebx,%edx
f01047d8:	0f 8d 87 00 00 00    	jge    f0104865 <debuginfo_eip+0x304>
		for (lline = lfun + 1;
f01047de:	83 c2 01             	add    $0x1,%edx
f01047e1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01047e4:	89 d0                	mov    %edx,%eax
f01047e6:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01047e9:	8b 75 bc             	mov    -0x44(%ebp),%esi
f01047ec:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
f01047f0:	eb 32                	jmp    f0104824 <debuginfo_eip+0x2c3>
f01047f2:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01047f5:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01047f9:	75 1d                	jne    f0104818 <debuginfo_eip+0x2b7>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01047fb:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01047fe:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0104801:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0104804:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0104807:	8b 75 b4             	mov    -0x4c(%ebp),%esi
f010480a:	29 f0                	sub    %esi,%eax
f010480c:	39 c2                	cmp    %eax,%edx
f010480e:	73 bb                	jae    f01047cb <debuginfo_eip+0x26a>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104810:	89 f0                	mov    %esi,%eax
f0104812:	01 d0                	add    %edx,%eax
f0104814:	89 07                	mov    %eax,(%edi)
f0104816:	eb b3                	jmp    f01047cb <debuginfo_eip+0x26a>
f0104818:	8b 75 c0             	mov    -0x40(%ebp),%esi
f010481b:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010481e:	eb db                	jmp    f01047fb <debuginfo_eip+0x29a>
			info->eip_fn_narg++;
f0104820:	83 47 14 01          	addl   $0x1,0x14(%edi)
		for (lline = lfun + 1;
f0104824:	39 c3                	cmp    %eax,%ebx
f0104826:	7e 38                	jle    f0104860 <debuginfo_eip+0x2ff>
			 lline < rfun && stabs[lline].n_type == N_PSYM;
f0104828:	0f b6 0a             	movzbl (%edx),%ecx
f010482b:	83 c0 01             	add    $0x1,%eax
f010482e:	83 c2 0c             	add    $0xc,%edx
f0104831:	80 f9 a0             	cmp    $0xa0,%cl
f0104834:	74 ea                	je     f0104820 <debuginfo_eip+0x2bf>
	return 0;
f0104836:	b8 00 00 00 00       	mov    $0x0,%eax
f010483b:	eb 28                	jmp    f0104865 <debuginfo_eip+0x304>
			return -1;
f010483d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104842:	eb 21                	jmp    f0104865 <debuginfo_eip+0x304>
			return -1;
f0104844:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104849:	eb 1a                	jmp    f0104865 <debuginfo_eip+0x304>
		return -1;
f010484b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104850:	eb 13                	jmp    f0104865 <debuginfo_eip+0x304>
f0104852:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104857:	eb 0c                	jmp    f0104865 <debuginfo_eip+0x304>
		return -1;
f0104859:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010485e:	eb 05                	jmp    f0104865 <debuginfo_eip+0x304>
	return 0;
f0104860:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104865:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104868:	5b                   	pop    %ebx
f0104869:	5e                   	pop    %esi
f010486a:	5f                   	pop    %edi
f010486b:	5d                   	pop    %ebp
f010486c:	c3                   	ret    

f010486d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
f010486d:	55                   	push   %ebp
f010486e:	89 e5                	mov    %esp,%ebp
f0104870:	57                   	push   %edi
f0104871:	56                   	push   %esi
f0104872:	53                   	push   %ebx
f0104873:	83 ec 2c             	sub    $0x2c,%esp
f0104876:	e8 0c ea ff ff       	call   f0103287 <__x86.get_pc_thunk.cx>
f010487b:	81 c1 a5 87 08 00    	add    $0x887a5,%ecx
f0104881:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0104884:	89 c7                	mov    %eax,%edi
f0104886:	89 d6                	mov    %edx,%esi
f0104888:	8b 45 08             	mov    0x8(%ebp),%eax
f010488b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010488e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104891:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
f0104894:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104897:	bb 00 00 00 00       	mov    $0x0,%ebx
f010489c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f010489f:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f01048a2:	39 d3                	cmp    %edx,%ebx
f01048a4:	72 09                	jb     f01048af <printnum+0x42>
f01048a6:	39 45 10             	cmp    %eax,0x10(%ebp)
f01048a9:	0f 87 83 00 00 00    	ja     f0104932 <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01048af:	83 ec 0c             	sub    $0xc,%esp
f01048b2:	ff 75 18             	pushl  0x18(%ebp)
f01048b5:	8b 45 14             	mov    0x14(%ebp),%eax
f01048b8:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01048bb:	53                   	push   %ebx
f01048bc:	ff 75 10             	pushl  0x10(%ebp)
f01048bf:	83 ec 08             	sub    $0x8,%esp
f01048c2:	ff 75 dc             	pushl  -0x24(%ebp)
f01048c5:	ff 75 d8             	pushl  -0x28(%ebp)
f01048c8:	ff 75 d4             	pushl  -0x2c(%ebp)
f01048cb:	ff 75 d0             	pushl  -0x30(%ebp)
f01048ce:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01048d1:	e8 1a 0a 00 00       	call   f01052f0 <__udivdi3>
f01048d6:	83 c4 18             	add    $0x18,%esp
f01048d9:	52                   	push   %edx
f01048da:	50                   	push   %eax
f01048db:	89 f2                	mov    %esi,%edx
f01048dd:	89 f8                	mov    %edi,%eax
f01048df:	e8 89 ff ff ff       	call   f010486d <printnum>
f01048e4:	83 c4 20             	add    $0x20,%esp
f01048e7:	eb 13                	jmp    f01048fc <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01048e9:	83 ec 08             	sub    $0x8,%esp
f01048ec:	56                   	push   %esi
f01048ed:	ff 75 18             	pushl  0x18(%ebp)
f01048f0:	ff d7                	call   *%edi
f01048f2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f01048f5:	83 eb 01             	sub    $0x1,%ebx
f01048f8:	85 db                	test   %ebx,%ebx
f01048fa:	7f ed                	jg     f01048e9 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01048fc:	83 ec 08             	sub    $0x8,%esp
f01048ff:	56                   	push   %esi
f0104900:	83 ec 04             	sub    $0x4,%esp
f0104903:	ff 75 dc             	pushl  -0x24(%ebp)
f0104906:	ff 75 d8             	pushl  -0x28(%ebp)
f0104909:	ff 75 d4             	pushl  -0x2c(%ebp)
f010490c:	ff 75 d0             	pushl  -0x30(%ebp)
f010490f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104912:	89 f3                	mov    %esi,%ebx
f0104914:	e8 f7 0a 00 00       	call   f0105410 <__umoddi3>
f0104919:	83 c4 14             	add    $0x14,%esp
f010491c:	0f be 84 06 e6 99 f7 	movsbl -0x8661a(%esi,%eax,1),%eax
f0104923:	ff 
f0104924:	50                   	push   %eax
f0104925:	ff d7                	call   *%edi
}
f0104927:	83 c4 10             	add    $0x10,%esp
f010492a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010492d:	5b                   	pop    %ebx
f010492e:	5e                   	pop    %esi
f010492f:	5f                   	pop    %edi
f0104930:	5d                   	pop    %ebp
f0104931:	c3                   	ret    
f0104932:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104935:	eb be                	jmp    f01048f5 <printnum+0x88>

f0104937 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104937:	55                   	push   %ebp
f0104938:	89 e5                	mov    %esp,%ebp
f010493a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010493d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104941:	8b 10                	mov    (%eax),%edx
f0104943:	3b 50 04             	cmp    0x4(%eax),%edx
f0104946:	73 0a                	jae    f0104952 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104948:	8d 4a 01             	lea    0x1(%edx),%ecx
f010494b:	89 08                	mov    %ecx,(%eax)
f010494d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104950:	88 02                	mov    %al,(%edx)
}
f0104952:	5d                   	pop    %ebp
f0104953:	c3                   	ret    

f0104954 <printfmt>:
{
f0104954:	55                   	push   %ebp
f0104955:	89 e5                	mov    %esp,%ebp
f0104957:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f010495a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010495d:	50                   	push   %eax
f010495e:	ff 75 10             	pushl  0x10(%ebp)
f0104961:	ff 75 0c             	pushl  0xc(%ebp)
f0104964:	ff 75 08             	pushl  0x8(%ebp)
f0104967:	e8 05 00 00 00       	call   f0104971 <vprintfmt>
}
f010496c:	83 c4 10             	add    $0x10,%esp
f010496f:	c9                   	leave  
f0104970:	c3                   	ret    

f0104971 <vprintfmt>:
{
f0104971:	55                   	push   %ebp
f0104972:	89 e5                	mov    %esp,%ebp
f0104974:	57                   	push   %edi
f0104975:	56                   	push   %esi
f0104976:	53                   	push   %ebx
f0104977:	83 ec 2c             	sub    $0x2c,%esp
f010497a:	e8 e8 b7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010497f:	81 c3 a1 86 08 00    	add    $0x886a1,%ebx
f0104985:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104988:	8b 7d 10             	mov    0x10(%ebp),%edi
f010498b:	e9 c3 03 00 00       	jmp    f0104d53 <.L35+0x48>
		padc = ' ';
f0104990:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0104994:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f010499b:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f01049a2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f01049a9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01049ae:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f01049b1:	8d 47 01             	lea    0x1(%edi),%eax
f01049b4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01049b7:	0f b6 17             	movzbl (%edi),%edx
f01049ba:	8d 42 dd             	lea    -0x23(%edx),%eax
f01049bd:	3c 55                	cmp    $0x55,%al
f01049bf:	0f 87 16 04 00 00    	ja     f0104ddb <.L22>
f01049c5:	0f b6 c0             	movzbl %al,%eax
f01049c8:	89 d9                	mov    %ebx,%ecx
f01049ca:	03 8c 83 70 9a f7 ff 	add    -0x86590(%ebx,%eax,4),%ecx
f01049d1:	ff e1                	jmp    *%ecx

f01049d3 <.L69>:
f01049d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f01049d6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f01049da:	eb d5                	jmp    f01049b1 <vprintfmt+0x40>

f01049dc <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f01049dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f01049df:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01049e3:	eb cc                	jmp    f01049b1 <vprintfmt+0x40>

f01049e5 <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f01049e5:	0f b6 d2             	movzbl %dl,%edx
f01049e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
f01049eb:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f01049f0:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01049f3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01049f7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f01049fa:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01049fd:	83 f9 09             	cmp    $0x9,%ecx
f0104a00:	77 55                	ja     f0104a57 <.L23+0xf>
			for (precision = 0;; ++fmt)
f0104a02:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0104a05:	eb e9                	jmp    f01049f0 <.L29+0xb>

f0104a07 <.L26>:
			precision = va_arg(ap, int);
f0104a07:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a0a:	8b 00                	mov    (%eax),%eax
f0104a0c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104a0f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a12:	8d 40 04             	lea    0x4(%eax),%eax
f0104a15:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f0104a18:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0104a1b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104a1f:	79 90                	jns    f01049b1 <vprintfmt+0x40>
				width = precision, precision = -1;
f0104a21:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104a24:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104a27:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0104a2e:	eb 81                	jmp    f01049b1 <vprintfmt+0x40>

f0104a30 <.L27>:
f0104a30:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a33:	85 c0                	test   %eax,%eax
f0104a35:	ba 00 00 00 00       	mov    $0x0,%edx
f0104a3a:	0f 49 d0             	cmovns %eax,%edx
f0104a3d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f0104a40:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104a43:	e9 69 ff ff ff       	jmp    f01049b1 <vprintfmt+0x40>

f0104a48 <.L23>:
f0104a48:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0104a4b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104a52:	e9 5a ff ff ff       	jmp    f01049b1 <vprintfmt+0x40>
f0104a57:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104a5a:	eb bf                	jmp    f0104a1b <.L26+0x14>

f0104a5c <.L33>:
			lflag++;
f0104a5c:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f0104a60:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0104a63:	e9 49 ff ff ff       	jmp    f01049b1 <vprintfmt+0x40>

f0104a68 <.L30>:
			putch(va_arg(ap, int), putdat);
f0104a68:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a6b:	8d 78 04             	lea    0x4(%eax),%edi
f0104a6e:	83 ec 08             	sub    $0x8,%esp
f0104a71:	56                   	push   %esi
f0104a72:	ff 30                	pushl  (%eax)
f0104a74:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104a77:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0104a7a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0104a7d:	e9 ce 02 00 00       	jmp    f0104d50 <.L35+0x45>

f0104a82 <.L32>:
			err = va_arg(ap, int);
f0104a82:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a85:	8d 78 04             	lea    0x4(%eax),%edi
f0104a88:	8b 00                	mov    (%eax),%eax
f0104a8a:	99                   	cltd   
f0104a8b:	31 d0                	xor    %edx,%eax
f0104a8d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104a8f:	83 f8 06             	cmp    $0x6,%eax
f0104a92:	7f 27                	jg     f0104abb <.L32+0x39>
f0104a94:	8b 94 83 b0 20 00 00 	mov    0x20b0(%ebx,%eax,4),%edx
f0104a9b:	85 d2                	test   %edx,%edx
f0104a9d:	74 1c                	je     f0104abb <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f0104a9f:	52                   	push   %edx
f0104aa0:	8d 83 a5 92 f7 ff    	lea    -0x86d5b(%ebx),%eax
f0104aa6:	50                   	push   %eax
f0104aa7:	56                   	push   %esi
f0104aa8:	ff 75 08             	pushl  0x8(%ebp)
f0104aab:	e8 a4 fe ff ff       	call   f0104954 <printfmt>
f0104ab0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104ab3:	89 7d 14             	mov    %edi,0x14(%ebp)
f0104ab6:	e9 95 02 00 00       	jmp    f0104d50 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
f0104abb:	50                   	push   %eax
f0104abc:	8d 83 fe 99 f7 ff    	lea    -0x86602(%ebx),%eax
f0104ac2:	50                   	push   %eax
f0104ac3:	56                   	push   %esi
f0104ac4:	ff 75 08             	pushl  0x8(%ebp)
f0104ac7:	e8 88 fe ff ff       	call   f0104954 <printfmt>
f0104acc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104acf:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0104ad2:	e9 79 02 00 00       	jmp    f0104d50 <.L35+0x45>

f0104ad7 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f0104ad7:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ada:	83 c0 04             	add    $0x4,%eax
f0104add:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104ae0:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ae3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104ae5:	85 ff                	test   %edi,%edi
f0104ae7:	8d 83 f7 99 f7 ff    	lea    -0x86609(%ebx),%eax
f0104aed:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104af0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104af4:	0f 8e b5 00 00 00    	jle    f0104baf <.L36+0xd8>
f0104afa:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104afe:	75 08                	jne    f0104b08 <.L36+0x31>
f0104b00:	89 75 0c             	mov    %esi,0xc(%ebp)
f0104b03:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0104b06:	eb 6d                	jmp    f0104b75 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104b08:	83 ec 08             	sub    $0x8,%esp
f0104b0b:	ff 75 cc             	pushl  -0x34(%ebp)
f0104b0e:	57                   	push   %edi
f0104b0f:	e8 7e 04 00 00       	call   f0104f92 <strnlen>
f0104b14:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104b17:	29 c2                	sub    %eax,%edx
f0104b19:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0104b1c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104b1f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104b23:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104b26:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104b29:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0104b2b:	eb 10                	jmp    f0104b3d <.L36+0x66>
					putch(padc, putdat);
f0104b2d:	83 ec 08             	sub    $0x8,%esp
f0104b30:	56                   	push   %esi
f0104b31:	ff 75 e0             	pushl  -0x20(%ebp)
f0104b34:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0104b37:	83 ef 01             	sub    $0x1,%edi
f0104b3a:	83 c4 10             	add    $0x10,%esp
f0104b3d:	85 ff                	test   %edi,%edi
f0104b3f:	7f ec                	jg     f0104b2d <.L36+0x56>
f0104b41:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104b44:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0104b47:	85 d2                	test   %edx,%edx
f0104b49:	b8 00 00 00 00       	mov    $0x0,%eax
f0104b4e:	0f 49 c2             	cmovns %edx,%eax
f0104b51:	29 c2                	sub    %eax,%edx
f0104b53:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0104b56:	89 75 0c             	mov    %esi,0xc(%ebp)
f0104b59:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0104b5c:	eb 17                	jmp    f0104b75 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f0104b5e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104b62:	75 30                	jne    f0104b94 <.L36+0xbd>
					putch(ch, putdat);
f0104b64:	83 ec 08             	sub    $0x8,%esp
f0104b67:	ff 75 0c             	pushl  0xc(%ebp)
f0104b6a:	50                   	push   %eax
f0104b6b:	ff 55 08             	call   *0x8(%ebp)
f0104b6e:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104b71:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f0104b75:	83 c7 01             	add    $0x1,%edi
f0104b78:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0104b7c:	0f be c2             	movsbl %dl,%eax
f0104b7f:	85 c0                	test   %eax,%eax
f0104b81:	74 52                	je     f0104bd5 <.L36+0xfe>
f0104b83:	85 f6                	test   %esi,%esi
f0104b85:	78 d7                	js     f0104b5e <.L36+0x87>
f0104b87:	83 ee 01             	sub    $0x1,%esi
f0104b8a:	79 d2                	jns    f0104b5e <.L36+0x87>
f0104b8c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104b8f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104b92:	eb 32                	jmp    f0104bc6 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f0104b94:	0f be d2             	movsbl %dl,%edx
f0104b97:	83 ea 20             	sub    $0x20,%edx
f0104b9a:	83 fa 5e             	cmp    $0x5e,%edx
f0104b9d:	76 c5                	jbe    f0104b64 <.L36+0x8d>
					putch('?', putdat);
f0104b9f:	83 ec 08             	sub    $0x8,%esp
f0104ba2:	ff 75 0c             	pushl  0xc(%ebp)
f0104ba5:	6a 3f                	push   $0x3f
f0104ba7:	ff 55 08             	call   *0x8(%ebp)
f0104baa:	83 c4 10             	add    $0x10,%esp
f0104bad:	eb c2                	jmp    f0104b71 <.L36+0x9a>
f0104baf:	89 75 0c             	mov    %esi,0xc(%ebp)
f0104bb2:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0104bb5:	eb be                	jmp    f0104b75 <.L36+0x9e>
				putch(' ', putdat);
f0104bb7:	83 ec 08             	sub    $0x8,%esp
f0104bba:	56                   	push   %esi
f0104bbb:	6a 20                	push   $0x20
f0104bbd:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f0104bc0:	83 ef 01             	sub    $0x1,%edi
f0104bc3:	83 c4 10             	add    $0x10,%esp
f0104bc6:	85 ff                	test   %edi,%edi
f0104bc8:	7f ed                	jg     f0104bb7 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f0104bca:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104bcd:	89 45 14             	mov    %eax,0x14(%ebp)
f0104bd0:	e9 7b 01 00 00       	jmp    f0104d50 <.L35+0x45>
f0104bd5:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104bd8:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104bdb:	eb e9                	jmp    f0104bc6 <.L36+0xef>

f0104bdd <.L31>:
f0104bdd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0104be0:	83 f9 01             	cmp    $0x1,%ecx
f0104be3:	7e 40                	jle    f0104c25 <.L31+0x48>
		return va_arg(*ap, long long);
f0104be5:	8b 45 14             	mov    0x14(%ebp),%eax
f0104be8:	8b 50 04             	mov    0x4(%eax),%edx
f0104beb:	8b 00                	mov    (%eax),%eax
f0104bed:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104bf0:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104bf3:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bf6:	8d 40 08             	lea    0x8(%eax),%eax
f0104bf9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
f0104bfc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104c00:	79 55                	jns    f0104c57 <.L31+0x7a>
				putch('-', putdat);
f0104c02:	83 ec 08             	sub    $0x8,%esp
f0104c05:	56                   	push   %esi
f0104c06:	6a 2d                	push   $0x2d
f0104c08:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
f0104c0b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104c0e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104c11:	f7 da                	neg    %edx
f0104c13:	83 d1 00             	adc    $0x0,%ecx
f0104c16:	f7 d9                	neg    %ecx
f0104c18:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
f0104c1b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104c20:	e9 10 01 00 00       	jmp    f0104d35 <.L35+0x2a>
	else if (lflag)
f0104c25:	85 c9                	test   %ecx,%ecx
f0104c27:	75 17                	jne    f0104c40 <.L31+0x63>
		return va_arg(*ap, int);
f0104c29:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c2c:	8b 00                	mov    (%eax),%eax
f0104c2e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104c31:	99                   	cltd   
f0104c32:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104c35:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c38:	8d 40 04             	lea    0x4(%eax),%eax
f0104c3b:	89 45 14             	mov    %eax,0x14(%ebp)
f0104c3e:	eb bc                	jmp    f0104bfc <.L31+0x1f>
		return va_arg(*ap, long);
f0104c40:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c43:	8b 00                	mov    (%eax),%eax
f0104c45:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104c48:	99                   	cltd   
f0104c49:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104c4c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c4f:	8d 40 04             	lea    0x4(%eax),%eax
f0104c52:	89 45 14             	mov    %eax,0x14(%ebp)
f0104c55:	eb a5                	jmp    f0104bfc <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
f0104c57:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104c5a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
f0104c5d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104c62:	e9 ce 00 00 00       	jmp    f0104d35 <.L35+0x2a>

f0104c67 <.L37>:
f0104c67:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0104c6a:	83 f9 01             	cmp    $0x1,%ecx
f0104c6d:	7e 18                	jle    f0104c87 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
f0104c6f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c72:	8b 10                	mov    (%eax),%edx
f0104c74:	8b 48 04             	mov    0x4(%eax),%ecx
f0104c77:	8d 40 08             	lea    0x8(%eax),%eax
f0104c7a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104c7d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104c82:	e9 ae 00 00 00       	jmp    f0104d35 <.L35+0x2a>
	else if (lflag)
f0104c87:	85 c9                	test   %ecx,%ecx
f0104c89:	75 1a                	jne    f0104ca5 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
f0104c8b:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c8e:	8b 10                	mov    (%eax),%edx
f0104c90:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104c95:	8d 40 04             	lea    0x4(%eax),%eax
f0104c98:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104c9b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104ca0:	e9 90 00 00 00       	jmp    f0104d35 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0104ca5:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ca8:	8b 10                	mov    (%eax),%edx
f0104caa:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104caf:	8d 40 04             	lea    0x4(%eax),%eax
f0104cb2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104cb5:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104cba:	eb 79                	jmp    f0104d35 <.L35+0x2a>

f0104cbc <.L34>:
f0104cbc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0104cbf:	83 f9 01             	cmp    $0x1,%ecx
f0104cc2:	7e 15                	jle    f0104cd9 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
f0104cc4:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cc7:	8b 10                	mov    (%eax),%edx
f0104cc9:	8b 48 04             	mov    0x4(%eax),%ecx
f0104ccc:	8d 40 08             	lea    0x8(%eax),%eax
f0104ccf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104cd2:	b8 08 00 00 00       	mov    $0x8,%eax
f0104cd7:	eb 5c                	jmp    f0104d35 <.L35+0x2a>
	else if (lflag)
f0104cd9:	85 c9                	test   %ecx,%ecx
f0104cdb:	75 17                	jne    f0104cf4 <.L34+0x38>
		return va_arg(*ap, unsigned int);
f0104cdd:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ce0:	8b 10                	mov    (%eax),%edx
f0104ce2:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104ce7:	8d 40 04             	lea    0x4(%eax),%eax
f0104cea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104ced:	b8 08 00 00 00       	mov    $0x8,%eax
f0104cf2:	eb 41                	jmp    f0104d35 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0104cf4:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cf7:	8b 10                	mov    (%eax),%edx
f0104cf9:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104cfe:	8d 40 04             	lea    0x4(%eax),%eax
f0104d01:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104d04:	b8 08 00 00 00       	mov    $0x8,%eax
f0104d09:	eb 2a                	jmp    f0104d35 <.L35+0x2a>

f0104d0b <.L35>:
			putch('0', putdat);
f0104d0b:	83 ec 08             	sub    $0x8,%esp
f0104d0e:	56                   	push   %esi
f0104d0f:	6a 30                	push   $0x30
f0104d11:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0104d14:	83 c4 08             	add    $0x8,%esp
f0104d17:	56                   	push   %esi
f0104d18:	6a 78                	push   $0x78
f0104d1a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
f0104d1d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d20:	8b 10                	mov    (%eax),%edx
f0104d22:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0104d27:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
f0104d2a:	8d 40 04             	lea    0x4(%eax),%eax
f0104d2d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104d30:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
f0104d35:	83 ec 0c             	sub    $0xc,%esp
f0104d38:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0104d3c:	57                   	push   %edi
f0104d3d:	ff 75 e0             	pushl  -0x20(%ebp)
f0104d40:	50                   	push   %eax
f0104d41:	51                   	push   %ecx
f0104d42:	52                   	push   %edx
f0104d43:	89 f2                	mov    %esi,%edx
f0104d45:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d48:	e8 20 fb ff ff       	call   f010486d <printnum>
			break;
f0104d4d:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0104d50:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
f0104d53:	83 c7 01             	add    $0x1,%edi
f0104d56:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104d5a:	83 f8 25             	cmp    $0x25,%eax
f0104d5d:	0f 84 2d fc ff ff    	je     f0104990 <vprintfmt+0x1f>
			if (ch == '\0')
f0104d63:	85 c0                	test   %eax,%eax
f0104d65:	0f 84 91 00 00 00    	je     f0104dfc <.L22+0x21>
			putch(ch, putdat);
f0104d6b:	83 ec 08             	sub    $0x8,%esp
f0104d6e:	56                   	push   %esi
f0104d6f:	50                   	push   %eax
f0104d70:	ff 55 08             	call   *0x8(%ebp)
f0104d73:	83 c4 10             	add    $0x10,%esp
f0104d76:	eb db                	jmp    f0104d53 <.L35+0x48>

f0104d78 <.L38>:
f0104d78:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0104d7b:	83 f9 01             	cmp    $0x1,%ecx
f0104d7e:	7e 15                	jle    f0104d95 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
f0104d80:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d83:	8b 10                	mov    (%eax),%edx
f0104d85:	8b 48 04             	mov    0x4(%eax),%ecx
f0104d88:	8d 40 08             	lea    0x8(%eax),%eax
f0104d8b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104d8e:	b8 10 00 00 00       	mov    $0x10,%eax
f0104d93:	eb a0                	jmp    f0104d35 <.L35+0x2a>
	else if (lflag)
f0104d95:	85 c9                	test   %ecx,%ecx
f0104d97:	75 17                	jne    f0104db0 <.L38+0x38>
		return va_arg(*ap, unsigned int);
f0104d99:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d9c:	8b 10                	mov    (%eax),%edx
f0104d9e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104da3:	8d 40 04             	lea    0x4(%eax),%eax
f0104da6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104da9:	b8 10 00 00 00       	mov    $0x10,%eax
f0104dae:	eb 85                	jmp    f0104d35 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0104db0:	8b 45 14             	mov    0x14(%ebp),%eax
f0104db3:	8b 10                	mov    (%eax),%edx
f0104db5:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104dba:	8d 40 04             	lea    0x4(%eax),%eax
f0104dbd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104dc0:	b8 10 00 00 00       	mov    $0x10,%eax
f0104dc5:	e9 6b ff ff ff       	jmp    f0104d35 <.L35+0x2a>

f0104dca <.L25>:
			putch(ch, putdat);
f0104dca:	83 ec 08             	sub    $0x8,%esp
f0104dcd:	56                   	push   %esi
f0104dce:	6a 25                	push   $0x25
f0104dd0:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104dd3:	83 c4 10             	add    $0x10,%esp
f0104dd6:	e9 75 ff ff ff       	jmp    f0104d50 <.L35+0x45>

f0104ddb <.L22>:
			putch('%', putdat);
f0104ddb:	83 ec 08             	sub    $0x8,%esp
f0104dde:	56                   	push   %esi
f0104ddf:	6a 25                	push   $0x25
f0104de1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104de4:	83 c4 10             	add    $0x10,%esp
f0104de7:	89 f8                	mov    %edi,%eax
f0104de9:	eb 03                	jmp    f0104dee <.L22+0x13>
f0104deb:	83 e8 01             	sub    $0x1,%eax
f0104dee:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0104df2:	75 f7                	jne    f0104deb <.L22+0x10>
f0104df4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104df7:	e9 54 ff ff ff       	jmp    f0104d50 <.L35+0x45>
}
f0104dfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104dff:	5b                   	pop    %ebx
f0104e00:	5e                   	pop    %esi
f0104e01:	5f                   	pop    %edi
f0104e02:	5d                   	pop    %ebp
f0104e03:	c3                   	ret    

f0104e04 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104e04:	55                   	push   %ebp
f0104e05:	89 e5                	mov    %esp,%ebp
f0104e07:	53                   	push   %ebx
f0104e08:	83 ec 14             	sub    $0x14,%esp
f0104e0b:	e8 57 b3 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104e10:	81 c3 10 82 08 00    	add    $0x88210,%ebx
f0104e16:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e19:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
f0104e1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104e1f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104e23:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104e26:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104e2d:	85 c0                	test   %eax,%eax
f0104e2f:	74 2b                	je     f0104e5c <vsnprintf+0x58>
f0104e31:	85 d2                	test   %edx,%edx
f0104e33:	7e 27                	jle    f0104e5c <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
f0104e35:	ff 75 14             	pushl  0x14(%ebp)
f0104e38:	ff 75 10             	pushl  0x10(%ebp)
f0104e3b:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104e3e:	50                   	push   %eax
f0104e3f:	8d 83 17 79 f7 ff    	lea    -0x886e9(%ebx),%eax
f0104e45:	50                   	push   %eax
f0104e46:	e8 26 fb ff ff       	call   f0104971 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104e4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104e4e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104e54:	83 c4 10             	add    $0x10,%esp
}
f0104e57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104e5a:	c9                   	leave  
f0104e5b:	c3                   	ret    
		return -E_INVAL;
f0104e5c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104e61:	eb f4                	jmp    f0104e57 <vsnprintf+0x53>

f0104e63 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
f0104e63:	55                   	push   %ebp
f0104e64:	89 e5                	mov    %esp,%ebp
f0104e66:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104e69:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104e6c:	50                   	push   %eax
f0104e6d:	ff 75 10             	pushl  0x10(%ebp)
f0104e70:	ff 75 0c             	pushl  0xc(%ebp)
f0104e73:	ff 75 08             	pushl  0x8(%ebp)
f0104e76:	e8 89 ff ff ff       	call   f0104e04 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104e7b:	c9                   	leave  
f0104e7c:	c3                   	ret    

f0104e7d <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104e7d:	55                   	push   %ebp
f0104e7e:	89 e5                	mov    %esp,%ebp
f0104e80:	57                   	push   %edi
f0104e81:	56                   	push   %esi
f0104e82:	53                   	push   %ebx
f0104e83:	83 ec 1c             	sub    $0x1c,%esp
f0104e86:	e8 dc b2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104e8b:	81 c3 95 81 08 00    	add    $0x88195,%ebx
f0104e91:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104e94:	85 c0                	test   %eax,%eax
f0104e96:	74 13                	je     f0104eab <readline+0x2e>
		cprintf("%s", prompt);
f0104e98:	83 ec 08             	sub    $0x8,%esp
f0104e9b:	50                   	push   %eax
f0104e9c:	8d 83 a5 92 f7 ff    	lea    -0x86d5b(%ebx),%eax
f0104ea2:	50                   	push   %eax
f0104ea3:	e8 f3 eb ff ff       	call   f0103a9b <cprintf>
f0104ea8:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104eab:	83 ec 0c             	sub    $0xc,%esp
f0104eae:	6a 00                	push   $0x0
f0104eb0:	e8 4a b8 ff ff       	call   f01006ff <iscons>
f0104eb5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104eb8:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0104ebb:	bf 00 00 00 00       	mov    $0x0,%edi
f0104ec0:	eb 46                	jmp    f0104f08 <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0104ec2:	83 ec 08             	sub    $0x8,%esp
f0104ec5:	50                   	push   %eax
f0104ec6:	8d 83 c8 9b f7 ff    	lea    -0x86438(%ebx),%eax
f0104ecc:	50                   	push   %eax
f0104ecd:	e8 c9 eb ff ff       	call   f0103a9b <cprintf>
			return NULL;
f0104ed2:	83 c4 10             	add    $0x10,%esp
f0104ed5:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0104eda:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104edd:	5b                   	pop    %ebx
f0104ede:	5e                   	pop    %esi
f0104edf:	5f                   	pop    %edi
f0104ee0:	5d                   	pop    %ebp
f0104ee1:	c3                   	ret    
			if (echoing)
f0104ee2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104ee6:	75 05                	jne    f0104eed <readline+0x70>
			i--;
f0104ee8:	83 ef 01             	sub    $0x1,%edi
f0104eeb:	eb 1b                	jmp    f0104f08 <readline+0x8b>
				cputchar('\b');
f0104eed:	83 ec 0c             	sub    $0xc,%esp
f0104ef0:	6a 08                	push   $0x8
f0104ef2:	e8 e7 b7 ff ff       	call   f01006de <cputchar>
f0104ef7:	83 c4 10             	add    $0x10,%esp
f0104efa:	eb ec                	jmp    f0104ee8 <readline+0x6b>
			buf[i++] = c;
f0104efc:	89 f0                	mov    %esi,%eax
f0104efe:	88 84 3b e0 2b 00 00 	mov    %al,0x2be0(%ebx,%edi,1)
f0104f05:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0104f08:	e8 e1 b7 ff ff       	call   f01006ee <getchar>
f0104f0d:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0104f0f:	85 c0                	test   %eax,%eax
f0104f11:	78 af                	js     f0104ec2 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104f13:	83 f8 08             	cmp    $0x8,%eax
f0104f16:	0f 94 c2             	sete   %dl
f0104f19:	83 f8 7f             	cmp    $0x7f,%eax
f0104f1c:	0f 94 c0             	sete   %al
f0104f1f:	08 c2                	or     %al,%dl
f0104f21:	74 04                	je     f0104f27 <readline+0xaa>
f0104f23:	85 ff                	test   %edi,%edi
f0104f25:	7f bb                	jg     f0104ee2 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104f27:	83 fe 1f             	cmp    $0x1f,%esi
f0104f2a:	7e 1c                	jle    f0104f48 <readline+0xcb>
f0104f2c:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0104f32:	7f 14                	jg     f0104f48 <readline+0xcb>
			if (echoing)
f0104f34:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104f38:	74 c2                	je     f0104efc <readline+0x7f>
				cputchar(c);
f0104f3a:	83 ec 0c             	sub    $0xc,%esp
f0104f3d:	56                   	push   %esi
f0104f3e:	e8 9b b7 ff ff       	call   f01006de <cputchar>
f0104f43:	83 c4 10             	add    $0x10,%esp
f0104f46:	eb b4                	jmp    f0104efc <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f0104f48:	83 fe 0a             	cmp    $0xa,%esi
f0104f4b:	74 05                	je     f0104f52 <readline+0xd5>
f0104f4d:	83 fe 0d             	cmp    $0xd,%esi
f0104f50:	75 b6                	jne    f0104f08 <readline+0x8b>
			if (echoing)
f0104f52:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104f56:	75 13                	jne    f0104f6b <readline+0xee>
			buf[i] = 0;
f0104f58:	c6 84 3b e0 2b 00 00 	movb   $0x0,0x2be0(%ebx,%edi,1)
f0104f5f:	00 
			return buf;
f0104f60:	8d 83 e0 2b 00 00    	lea    0x2be0(%ebx),%eax
f0104f66:	e9 6f ff ff ff       	jmp    f0104eda <readline+0x5d>
				cputchar('\n');
f0104f6b:	83 ec 0c             	sub    $0xc,%esp
f0104f6e:	6a 0a                	push   $0xa
f0104f70:	e8 69 b7 ff ff       	call   f01006de <cputchar>
f0104f75:	83 c4 10             	add    $0x10,%esp
f0104f78:	eb de                	jmp    f0104f58 <readline+0xdb>

f0104f7a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104f7a:	55                   	push   %ebp
f0104f7b:	89 e5                	mov    %esp,%ebp
f0104f7d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104f80:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f85:	eb 03                	jmp    f0104f8a <strlen+0x10>
		n++;
f0104f87:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0104f8a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104f8e:	75 f7                	jne    f0104f87 <strlen+0xd>
	return n;
}
f0104f90:	5d                   	pop    %ebp
f0104f91:	c3                   	ret    

f0104f92 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104f92:	55                   	push   %ebp
f0104f93:	89 e5                	mov    %esp,%ebp
f0104f95:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104f98:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104f9b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fa0:	eb 03                	jmp    f0104fa5 <strnlen+0x13>
		n++;
f0104fa2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104fa5:	39 d0                	cmp    %edx,%eax
f0104fa7:	74 06                	je     f0104faf <strnlen+0x1d>
f0104fa9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104fad:	75 f3                	jne    f0104fa2 <strnlen+0x10>
	return n;
}
f0104faf:	5d                   	pop    %ebp
f0104fb0:	c3                   	ret    

f0104fb1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104fb1:	55                   	push   %ebp
f0104fb2:	89 e5                	mov    %esp,%ebp
f0104fb4:	53                   	push   %ebx
f0104fb5:	8b 45 08             	mov    0x8(%ebp),%eax
f0104fb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104fbb:	89 c2                	mov    %eax,%edx
f0104fbd:	83 c1 01             	add    $0x1,%ecx
f0104fc0:	83 c2 01             	add    $0x1,%edx
f0104fc3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0104fc7:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104fca:	84 db                	test   %bl,%bl
f0104fcc:	75 ef                	jne    f0104fbd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104fce:	5b                   	pop    %ebx
f0104fcf:	5d                   	pop    %ebp
f0104fd0:	c3                   	ret    

f0104fd1 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104fd1:	55                   	push   %ebp
f0104fd2:	89 e5                	mov    %esp,%ebp
f0104fd4:	53                   	push   %ebx
f0104fd5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104fd8:	53                   	push   %ebx
f0104fd9:	e8 9c ff ff ff       	call   f0104f7a <strlen>
f0104fde:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0104fe1:	ff 75 0c             	pushl  0xc(%ebp)
f0104fe4:	01 d8                	add    %ebx,%eax
f0104fe6:	50                   	push   %eax
f0104fe7:	e8 c5 ff ff ff       	call   f0104fb1 <strcpy>
	return dst;
}
f0104fec:	89 d8                	mov    %ebx,%eax
f0104fee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104ff1:	c9                   	leave  
f0104ff2:	c3                   	ret    

f0104ff3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104ff3:	55                   	push   %ebp
f0104ff4:	89 e5                	mov    %esp,%ebp
f0104ff6:	56                   	push   %esi
f0104ff7:	53                   	push   %ebx
f0104ff8:	8b 75 08             	mov    0x8(%ebp),%esi
f0104ffb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104ffe:	89 f3                	mov    %esi,%ebx
f0105000:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105003:	89 f2                	mov    %esi,%edx
f0105005:	eb 0f                	jmp    f0105016 <strncpy+0x23>
		*dst++ = *src;
f0105007:	83 c2 01             	add    $0x1,%edx
f010500a:	0f b6 01             	movzbl (%ecx),%eax
f010500d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105010:	80 39 01             	cmpb   $0x1,(%ecx)
f0105013:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0105016:	39 da                	cmp    %ebx,%edx
f0105018:	75 ed                	jne    f0105007 <strncpy+0x14>
	}
	return ret;
}
f010501a:	89 f0                	mov    %esi,%eax
f010501c:	5b                   	pop    %ebx
f010501d:	5e                   	pop    %esi
f010501e:	5d                   	pop    %ebp
f010501f:	c3                   	ret    

f0105020 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105020:	55                   	push   %ebp
f0105021:	89 e5                	mov    %esp,%ebp
f0105023:	56                   	push   %esi
f0105024:	53                   	push   %ebx
f0105025:	8b 75 08             	mov    0x8(%ebp),%esi
f0105028:	8b 55 0c             	mov    0xc(%ebp),%edx
f010502b:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010502e:	89 f0                	mov    %esi,%eax
f0105030:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105034:	85 c9                	test   %ecx,%ecx
f0105036:	75 0b                	jne    f0105043 <strlcpy+0x23>
f0105038:	eb 17                	jmp    f0105051 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010503a:	83 c2 01             	add    $0x1,%edx
f010503d:	83 c0 01             	add    $0x1,%eax
f0105040:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0105043:	39 d8                	cmp    %ebx,%eax
f0105045:	74 07                	je     f010504e <strlcpy+0x2e>
f0105047:	0f b6 0a             	movzbl (%edx),%ecx
f010504a:	84 c9                	test   %cl,%cl
f010504c:	75 ec                	jne    f010503a <strlcpy+0x1a>
		*dst = '\0';
f010504e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105051:	29 f0                	sub    %esi,%eax
}
f0105053:	5b                   	pop    %ebx
f0105054:	5e                   	pop    %esi
f0105055:	5d                   	pop    %ebp
f0105056:	c3                   	ret    

f0105057 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105057:	55                   	push   %ebp
f0105058:	89 e5                	mov    %esp,%ebp
f010505a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010505d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105060:	eb 06                	jmp    f0105068 <strcmp+0x11>
		p++, q++;
f0105062:	83 c1 01             	add    $0x1,%ecx
f0105065:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0105068:	0f b6 01             	movzbl (%ecx),%eax
f010506b:	84 c0                	test   %al,%al
f010506d:	74 04                	je     f0105073 <strcmp+0x1c>
f010506f:	3a 02                	cmp    (%edx),%al
f0105071:	74 ef                	je     f0105062 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105073:	0f b6 c0             	movzbl %al,%eax
f0105076:	0f b6 12             	movzbl (%edx),%edx
f0105079:	29 d0                	sub    %edx,%eax
}
f010507b:	5d                   	pop    %ebp
f010507c:	c3                   	ret    

f010507d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010507d:	55                   	push   %ebp
f010507e:	89 e5                	mov    %esp,%ebp
f0105080:	53                   	push   %ebx
f0105081:	8b 45 08             	mov    0x8(%ebp),%eax
f0105084:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105087:	89 c3                	mov    %eax,%ebx
f0105089:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010508c:	eb 06                	jmp    f0105094 <strncmp+0x17>
		n--, p++, q++;
f010508e:	83 c0 01             	add    $0x1,%eax
f0105091:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105094:	39 d8                	cmp    %ebx,%eax
f0105096:	74 16                	je     f01050ae <strncmp+0x31>
f0105098:	0f b6 08             	movzbl (%eax),%ecx
f010509b:	84 c9                	test   %cl,%cl
f010509d:	74 04                	je     f01050a3 <strncmp+0x26>
f010509f:	3a 0a                	cmp    (%edx),%cl
f01050a1:	74 eb                	je     f010508e <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01050a3:	0f b6 00             	movzbl (%eax),%eax
f01050a6:	0f b6 12             	movzbl (%edx),%edx
f01050a9:	29 d0                	sub    %edx,%eax
}
f01050ab:	5b                   	pop    %ebx
f01050ac:	5d                   	pop    %ebp
f01050ad:	c3                   	ret    
		return 0;
f01050ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01050b3:	eb f6                	jmp    f01050ab <strncmp+0x2e>

f01050b5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01050b5:	55                   	push   %ebp
f01050b6:	89 e5                	mov    %esp,%ebp
f01050b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01050bb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01050bf:	0f b6 10             	movzbl (%eax),%edx
f01050c2:	84 d2                	test   %dl,%dl
f01050c4:	74 09                	je     f01050cf <strchr+0x1a>
		if (*s == c)
f01050c6:	38 ca                	cmp    %cl,%dl
f01050c8:	74 0a                	je     f01050d4 <strchr+0x1f>
	for (; *s; s++)
f01050ca:	83 c0 01             	add    $0x1,%eax
f01050cd:	eb f0                	jmp    f01050bf <strchr+0xa>
			return (char *) s;
	return 0;
f01050cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01050d4:	5d                   	pop    %ebp
f01050d5:	c3                   	ret    

f01050d6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01050d6:	55                   	push   %ebp
f01050d7:	89 e5                	mov    %esp,%ebp
f01050d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01050dc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01050e0:	eb 03                	jmp    f01050e5 <strfind+0xf>
f01050e2:	83 c0 01             	add    $0x1,%eax
f01050e5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01050e8:	38 ca                	cmp    %cl,%dl
f01050ea:	74 04                	je     f01050f0 <strfind+0x1a>
f01050ec:	84 d2                	test   %dl,%dl
f01050ee:	75 f2                	jne    f01050e2 <strfind+0xc>
			break;
	return (char *) s;
}
f01050f0:	5d                   	pop    %ebp
f01050f1:	c3                   	ret    

f01050f2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01050f2:	55                   	push   %ebp
f01050f3:	89 e5                	mov    %esp,%ebp
f01050f5:	57                   	push   %edi
f01050f6:	56                   	push   %esi
f01050f7:	53                   	push   %ebx
f01050f8:	8b 7d 08             	mov    0x8(%ebp),%edi
f01050fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01050fe:	85 c9                	test   %ecx,%ecx
f0105100:	74 13                	je     f0105115 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105102:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105108:	75 05                	jne    f010510f <memset+0x1d>
f010510a:	f6 c1 03             	test   $0x3,%cl
f010510d:	74 0d                	je     f010511c <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010510f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105112:	fc                   	cld    
f0105113:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105115:	89 f8                	mov    %edi,%eax
f0105117:	5b                   	pop    %ebx
f0105118:	5e                   	pop    %esi
f0105119:	5f                   	pop    %edi
f010511a:	5d                   	pop    %ebp
f010511b:	c3                   	ret    
		c &= 0xFF;
f010511c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105120:	89 d3                	mov    %edx,%ebx
f0105122:	c1 e3 08             	shl    $0x8,%ebx
f0105125:	89 d0                	mov    %edx,%eax
f0105127:	c1 e0 18             	shl    $0x18,%eax
f010512a:	89 d6                	mov    %edx,%esi
f010512c:	c1 e6 10             	shl    $0x10,%esi
f010512f:	09 f0                	or     %esi,%eax
f0105131:	09 c2                	or     %eax,%edx
f0105133:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0105135:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105138:	89 d0                	mov    %edx,%eax
f010513a:	fc                   	cld    
f010513b:	f3 ab                	rep stos %eax,%es:(%edi)
f010513d:	eb d6                	jmp    f0105115 <memset+0x23>

f010513f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010513f:	55                   	push   %ebp
f0105140:	89 e5                	mov    %esp,%ebp
f0105142:	57                   	push   %edi
f0105143:	56                   	push   %esi
f0105144:	8b 45 08             	mov    0x8(%ebp),%eax
f0105147:	8b 75 0c             	mov    0xc(%ebp),%esi
f010514a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010514d:	39 c6                	cmp    %eax,%esi
f010514f:	73 35                	jae    f0105186 <memmove+0x47>
f0105151:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105154:	39 c2                	cmp    %eax,%edx
f0105156:	76 2e                	jbe    f0105186 <memmove+0x47>
		s += n;
		d += n;
f0105158:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010515b:	89 d6                	mov    %edx,%esi
f010515d:	09 fe                	or     %edi,%esi
f010515f:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105165:	74 0c                	je     f0105173 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105167:	83 ef 01             	sub    $0x1,%edi
f010516a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f010516d:	fd                   	std    
f010516e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105170:	fc                   	cld    
f0105171:	eb 21                	jmp    f0105194 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105173:	f6 c1 03             	test   $0x3,%cl
f0105176:	75 ef                	jne    f0105167 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105178:	83 ef 04             	sub    $0x4,%edi
f010517b:	8d 72 fc             	lea    -0x4(%edx),%esi
f010517e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105181:	fd                   	std    
f0105182:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105184:	eb ea                	jmp    f0105170 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105186:	89 f2                	mov    %esi,%edx
f0105188:	09 c2                	or     %eax,%edx
f010518a:	f6 c2 03             	test   $0x3,%dl
f010518d:	74 09                	je     f0105198 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010518f:	89 c7                	mov    %eax,%edi
f0105191:	fc                   	cld    
f0105192:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105194:	5e                   	pop    %esi
f0105195:	5f                   	pop    %edi
f0105196:	5d                   	pop    %ebp
f0105197:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105198:	f6 c1 03             	test   $0x3,%cl
f010519b:	75 f2                	jne    f010518f <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010519d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01051a0:	89 c7                	mov    %eax,%edi
f01051a2:	fc                   	cld    
f01051a3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01051a5:	eb ed                	jmp    f0105194 <memmove+0x55>

f01051a7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01051a7:	55                   	push   %ebp
f01051a8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01051aa:	ff 75 10             	pushl  0x10(%ebp)
f01051ad:	ff 75 0c             	pushl  0xc(%ebp)
f01051b0:	ff 75 08             	pushl  0x8(%ebp)
f01051b3:	e8 87 ff ff ff       	call   f010513f <memmove>
}
f01051b8:	c9                   	leave  
f01051b9:	c3                   	ret    

f01051ba <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01051ba:	55                   	push   %ebp
f01051bb:	89 e5                	mov    %esp,%ebp
f01051bd:	56                   	push   %esi
f01051be:	53                   	push   %ebx
f01051bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01051c2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01051c5:	89 c6                	mov    %eax,%esi
f01051c7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01051ca:	39 f0                	cmp    %esi,%eax
f01051cc:	74 1c                	je     f01051ea <memcmp+0x30>
		if (*s1 != *s2)
f01051ce:	0f b6 08             	movzbl (%eax),%ecx
f01051d1:	0f b6 1a             	movzbl (%edx),%ebx
f01051d4:	38 d9                	cmp    %bl,%cl
f01051d6:	75 08                	jne    f01051e0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01051d8:	83 c0 01             	add    $0x1,%eax
f01051db:	83 c2 01             	add    $0x1,%edx
f01051de:	eb ea                	jmp    f01051ca <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f01051e0:	0f b6 c1             	movzbl %cl,%eax
f01051e3:	0f b6 db             	movzbl %bl,%ebx
f01051e6:	29 d8                	sub    %ebx,%eax
f01051e8:	eb 05                	jmp    f01051ef <memcmp+0x35>
	}

	return 0;
f01051ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01051ef:	5b                   	pop    %ebx
f01051f0:	5e                   	pop    %esi
f01051f1:	5d                   	pop    %ebp
f01051f2:	c3                   	ret    

f01051f3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01051f3:	55                   	push   %ebp
f01051f4:	89 e5                	mov    %esp,%ebp
f01051f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01051f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01051fc:	89 c2                	mov    %eax,%edx
f01051fe:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105201:	39 d0                	cmp    %edx,%eax
f0105203:	73 09                	jae    f010520e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105205:	38 08                	cmp    %cl,(%eax)
f0105207:	74 05                	je     f010520e <memfind+0x1b>
	for (; s < ends; s++)
f0105209:	83 c0 01             	add    $0x1,%eax
f010520c:	eb f3                	jmp    f0105201 <memfind+0xe>
			break;
	return (void *) s;
}
f010520e:	5d                   	pop    %ebp
f010520f:	c3                   	ret    

f0105210 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105210:	55                   	push   %ebp
f0105211:	89 e5                	mov    %esp,%ebp
f0105213:	57                   	push   %edi
f0105214:	56                   	push   %esi
f0105215:	53                   	push   %ebx
f0105216:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105219:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010521c:	eb 03                	jmp    f0105221 <strtol+0x11>
		s++;
f010521e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0105221:	0f b6 01             	movzbl (%ecx),%eax
f0105224:	3c 20                	cmp    $0x20,%al
f0105226:	74 f6                	je     f010521e <strtol+0xe>
f0105228:	3c 09                	cmp    $0x9,%al
f010522a:	74 f2                	je     f010521e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010522c:	3c 2b                	cmp    $0x2b,%al
f010522e:	74 2e                	je     f010525e <strtol+0x4e>
	int neg = 0;
f0105230:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105235:	3c 2d                	cmp    $0x2d,%al
f0105237:	74 2f                	je     f0105268 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105239:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010523f:	75 05                	jne    f0105246 <strtol+0x36>
f0105241:	80 39 30             	cmpb   $0x30,(%ecx)
f0105244:	74 2c                	je     f0105272 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105246:	85 db                	test   %ebx,%ebx
f0105248:	75 0a                	jne    f0105254 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010524a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f010524f:	80 39 30             	cmpb   $0x30,(%ecx)
f0105252:	74 28                	je     f010527c <strtol+0x6c>
		base = 10;
f0105254:	b8 00 00 00 00       	mov    $0x0,%eax
f0105259:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010525c:	eb 50                	jmp    f01052ae <strtol+0x9e>
		s++;
f010525e:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0105261:	bf 00 00 00 00       	mov    $0x0,%edi
f0105266:	eb d1                	jmp    f0105239 <strtol+0x29>
		s++, neg = 1;
f0105268:	83 c1 01             	add    $0x1,%ecx
f010526b:	bf 01 00 00 00       	mov    $0x1,%edi
f0105270:	eb c7                	jmp    f0105239 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105272:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105276:	74 0e                	je     f0105286 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0105278:	85 db                	test   %ebx,%ebx
f010527a:	75 d8                	jne    f0105254 <strtol+0x44>
		s++, base = 8;
f010527c:	83 c1 01             	add    $0x1,%ecx
f010527f:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105284:	eb ce                	jmp    f0105254 <strtol+0x44>
		s += 2, base = 16;
f0105286:	83 c1 02             	add    $0x2,%ecx
f0105289:	bb 10 00 00 00       	mov    $0x10,%ebx
f010528e:	eb c4                	jmp    f0105254 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0105290:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105293:	89 f3                	mov    %esi,%ebx
f0105295:	80 fb 19             	cmp    $0x19,%bl
f0105298:	77 29                	ja     f01052c3 <strtol+0xb3>
			dig = *s - 'a' + 10;
f010529a:	0f be d2             	movsbl %dl,%edx
f010529d:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01052a0:	3b 55 10             	cmp    0x10(%ebp),%edx
f01052a3:	7d 30                	jge    f01052d5 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01052a5:	83 c1 01             	add    $0x1,%ecx
f01052a8:	0f af 45 10          	imul   0x10(%ebp),%eax
f01052ac:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01052ae:	0f b6 11             	movzbl (%ecx),%edx
f01052b1:	8d 72 d0             	lea    -0x30(%edx),%esi
f01052b4:	89 f3                	mov    %esi,%ebx
f01052b6:	80 fb 09             	cmp    $0x9,%bl
f01052b9:	77 d5                	ja     f0105290 <strtol+0x80>
			dig = *s - '0';
f01052bb:	0f be d2             	movsbl %dl,%edx
f01052be:	83 ea 30             	sub    $0x30,%edx
f01052c1:	eb dd                	jmp    f01052a0 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f01052c3:	8d 72 bf             	lea    -0x41(%edx),%esi
f01052c6:	89 f3                	mov    %esi,%ebx
f01052c8:	80 fb 19             	cmp    $0x19,%bl
f01052cb:	77 08                	ja     f01052d5 <strtol+0xc5>
			dig = *s - 'A' + 10;
f01052cd:	0f be d2             	movsbl %dl,%edx
f01052d0:	83 ea 37             	sub    $0x37,%edx
f01052d3:	eb cb                	jmp    f01052a0 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f01052d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01052d9:	74 05                	je     f01052e0 <strtol+0xd0>
		*endptr = (char *) s;
f01052db:	8b 75 0c             	mov    0xc(%ebp),%esi
f01052de:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01052e0:	89 c2                	mov    %eax,%edx
f01052e2:	f7 da                	neg    %edx
f01052e4:	85 ff                	test   %edi,%edi
f01052e6:	0f 45 c2             	cmovne %edx,%eax
}
f01052e9:	5b                   	pop    %ebx
f01052ea:	5e                   	pop    %esi
f01052eb:	5f                   	pop    %edi
f01052ec:	5d                   	pop    %ebp
f01052ed:	c3                   	ret    
f01052ee:	66 90                	xchg   %ax,%ax

f01052f0 <__udivdi3>:
f01052f0:	55                   	push   %ebp
f01052f1:	57                   	push   %edi
f01052f2:	56                   	push   %esi
f01052f3:	53                   	push   %ebx
f01052f4:	83 ec 1c             	sub    $0x1c,%esp
f01052f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01052fb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01052ff:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105303:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0105307:	85 d2                	test   %edx,%edx
f0105309:	75 35                	jne    f0105340 <__udivdi3+0x50>
f010530b:	39 f3                	cmp    %esi,%ebx
f010530d:	0f 87 bd 00 00 00    	ja     f01053d0 <__udivdi3+0xe0>
f0105313:	85 db                	test   %ebx,%ebx
f0105315:	89 d9                	mov    %ebx,%ecx
f0105317:	75 0b                	jne    f0105324 <__udivdi3+0x34>
f0105319:	b8 01 00 00 00       	mov    $0x1,%eax
f010531e:	31 d2                	xor    %edx,%edx
f0105320:	f7 f3                	div    %ebx
f0105322:	89 c1                	mov    %eax,%ecx
f0105324:	31 d2                	xor    %edx,%edx
f0105326:	89 f0                	mov    %esi,%eax
f0105328:	f7 f1                	div    %ecx
f010532a:	89 c6                	mov    %eax,%esi
f010532c:	89 e8                	mov    %ebp,%eax
f010532e:	89 f7                	mov    %esi,%edi
f0105330:	f7 f1                	div    %ecx
f0105332:	89 fa                	mov    %edi,%edx
f0105334:	83 c4 1c             	add    $0x1c,%esp
f0105337:	5b                   	pop    %ebx
f0105338:	5e                   	pop    %esi
f0105339:	5f                   	pop    %edi
f010533a:	5d                   	pop    %ebp
f010533b:	c3                   	ret    
f010533c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105340:	39 f2                	cmp    %esi,%edx
f0105342:	77 7c                	ja     f01053c0 <__udivdi3+0xd0>
f0105344:	0f bd fa             	bsr    %edx,%edi
f0105347:	83 f7 1f             	xor    $0x1f,%edi
f010534a:	0f 84 98 00 00 00    	je     f01053e8 <__udivdi3+0xf8>
f0105350:	89 f9                	mov    %edi,%ecx
f0105352:	b8 20 00 00 00       	mov    $0x20,%eax
f0105357:	29 f8                	sub    %edi,%eax
f0105359:	d3 e2                	shl    %cl,%edx
f010535b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010535f:	89 c1                	mov    %eax,%ecx
f0105361:	89 da                	mov    %ebx,%edx
f0105363:	d3 ea                	shr    %cl,%edx
f0105365:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0105369:	09 d1                	or     %edx,%ecx
f010536b:	89 f2                	mov    %esi,%edx
f010536d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105371:	89 f9                	mov    %edi,%ecx
f0105373:	d3 e3                	shl    %cl,%ebx
f0105375:	89 c1                	mov    %eax,%ecx
f0105377:	d3 ea                	shr    %cl,%edx
f0105379:	89 f9                	mov    %edi,%ecx
f010537b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010537f:	d3 e6                	shl    %cl,%esi
f0105381:	89 eb                	mov    %ebp,%ebx
f0105383:	89 c1                	mov    %eax,%ecx
f0105385:	d3 eb                	shr    %cl,%ebx
f0105387:	09 de                	or     %ebx,%esi
f0105389:	89 f0                	mov    %esi,%eax
f010538b:	f7 74 24 08          	divl   0x8(%esp)
f010538f:	89 d6                	mov    %edx,%esi
f0105391:	89 c3                	mov    %eax,%ebx
f0105393:	f7 64 24 0c          	mull   0xc(%esp)
f0105397:	39 d6                	cmp    %edx,%esi
f0105399:	72 0c                	jb     f01053a7 <__udivdi3+0xb7>
f010539b:	89 f9                	mov    %edi,%ecx
f010539d:	d3 e5                	shl    %cl,%ebp
f010539f:	39 c5                	cmp    %eax,%ebp
f01053a1:	73 5d                	jae    f0105400 <__udivdi3+0x110>
f01053a3:	39 d6                	cmp    %edx,%esi
f01053a5:	75 59                	jne    f0105400 <__udivdi3+0x110>
f01053a7:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01053aa:	31 ff                	xor    %edi,%edi
f01053ac:	89 fa                	mov    %edi,%edx
f01053ae:	83 c4 1c             	add    $0x1c,%esp
f01053b1:	5b                   	pop    %ebx
f01053b2:	5e                   	pop    %esi
f01053b3:	5f                   	pop    %edi
f01053b4:	5d                   	pop    %ebp
f01053b5:	c3                   	ret    
f01053b6:	8d 76 00             	lea    0x0(%esi),%esi
f01053b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f01053c0:	31 ff                	xor    %edi,%edi
f01053c2:	31 c0                	xor    %eax,%eax
f01053c4:	89 fa                	mov    %edi,%edx
f01053c6:	83 c4 1c             	add    $0x1c,%esp
f01053c9:	5b                   	pop    %ebx
f01053ca:	5e                   	pop    %esi
f01053cb:	5f                   	pop    %edi
f01053cc:	5d                   	pop    %ebp
f01053cd:	c3                   	ret    
f01053ce:	66 90                	xchg   %ax,%ax
f01053d0:	31 ff                	xor    %edi,%edi
f01053d2:	89 e8                	mov    %ebp,%eax
f01053d4:	89 f2                	mov    %esi,%edx
f01053d6:	f7 f3                	div    %ebx
f01053d8:	89 fa                	mov    %edi,%edx
f01053da:	83 c4 1c             	add    $0x1c,%esp
f01053dd:	5b                   	pop    %ebx
f01053de:	5e                   	pop    %esi
f01053df:	5f                   	pop    %edi
f01053e0:	5d                   	pop    %ebp
f01053e1:	c3                   	ret    
f01053e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01053e8:	39 f2                	cmp    %esi,%edx
f01053ea:	72 06                	jb     f01053f2 <__udivdi3+0x102>
f01053ec:	31 c0                	xor    %eax,%eax
f01053ee:	39 eb                	cmp    %ebp,%ebx
f01053f0:	77 d2                	ja     f01053c4 <__udivdi3+0xd4>
f01053f2:	b8 01 00 00 00       	mov    $0x1,%eax
f01053f7:	eb cb                	jmp    f01053c4 <__udivdi3+0xd4>
f01053f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105400:	89 d8                	mov    %ebx,%eax
f0105402:	31 ff                	xor    %edi,%edi
f0105404:	eb be                	jmp    f01053c4 <__udivdi3+0xd4>
f0105406:	66 90                	xchg   %ax,%ax
f0105408:	66 90                	xchg   %ax,%ax
f010540a:	66 90                	xchg   %ax,%ax
f010540c:	66 90                	xchg   %ax,%ax
f010540e:	66 90                	xchg   %ax,%ax

f0105410 <__umoddi3>:
f0105410:	55                   	push   %ebp
f0105411:	57                   	push   %edi
f0105412:	56                   	push   %esi
f0105413:	53                   	push   %ebx
f0105414:	83 ec 1c             	sub    $0x1c,%esp
f0105417:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f010541b:	8b 74 24 30          	mov    0x30(%esp),%esi
f010541f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0105423:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105427:	85 ed                	test   %ebp,%ebp
f0105429:	89 f0                	mov    %esi,%eax
f010542b:	89 da                	mov    %ebx,%edx
f010542d:	75 19                	jne    f0105448 <__umoddi3+0x38>
f010542f:	39 df                	cmp    %ebx,%edi
f0105431:	0f 86 b1 00 00 00    	jbe    f01054e8 <__umoddi3+0xd8>
f0105437:	f7 f7                	div    %edi
f0105439:	89 d0                	mov    %edx,%eax
f010543b:	31 d2                	xor    %edx,%edx
f010543d:	83 c4 1c             	add    $0x1c,%esp
f0105440:	5b                   	pop    %ebx
f0105441:	5e                   	pop    %esi
f0105442:	5f                   	pop    %edi
f0105443:	5d                   	pop    %ebp
f0105444:	c3                   	ret    
f0105445:	8d 76 00             	lea    0x0(%esi),%esi
f0105448:	39 dd                	cmp    %ebx,%ebp
f010544a:	77 f1                	ja     f010543d <__umoddi3+0x2d>
f010544c:	0f bd cd             	bsr    %ebp,%ecx
f010544f:	83 f1 1f             	xor    $0x1f,%ecx
f0105452:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105456:	0f 84 b4 00 00 00    	je     f0105510 <__umoddi3+0x100>
f010545c:	b8 20 00 00 00       	mov    $0x20,%eax
f0105461:	89 c2                	mov    %eax,%edx
f0105463:	8b 44 24 04          	mov    0x4(%esp),%eax
f0105467:	29 c2                	sub    %eax,%edx
f0105469:	89 c1                	mov    %eax,%ecx
f010546b:	89 f8                	mov    %edi,%eax
f010546d:	d3 e5                	shl    %cl,%ebp
f010546f:	89 d1                	mov    %edx,%ecx
f0105471:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105475:	d3 e8                	shr    %cl,%eax
f0105477:	09 c5                	or     %eax,%ebp
f0105479:	8b 44 24 04          	mov    0x4(%esp),%eax
f010547d:	89 c1                	mov    %eax,%ecx
f010547f:	d3 e7                	shl    %cl,%edi
f0105481:	89 d1                	mov    %edx,%ecx
f0105483:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105487:	89 df                	mov    %ebx,%edi
f0105489:	d3 ef                	shr    %cl,%edi
f010548b:	89 c1                	mov    %eax,%ecx
f010548d:	89 f0                	mov    %esi,%eax
f010548f:	d3 e3                	shl    %cl,%ebx
f0105491:	89 d1                	mov    %edx,%ecx
f0105493:	89 fa                	mov    %edi,%edx
f0105495:	d3 e8                	shr    %cl,%eax
f0105497:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010549c:	09 d8                	or     %ebx,%eax
f010549e:	f7 f5                	div    %ebp
f01054a0:	d3 e6                	shl    %cl,%esi
f01054a2:	89 d1                	mov    %edx,%ecx
f01054a4:	f7 64 24 08          	mull   0x8(%esp)
f01054a8:	39 d1                	cmp    %edx,%ecx
f01054aa:	89 c3                	mov    %eax,%ebx
f01054ac:	89 d7                	mov    %edx,%edi
f01054ae:	72 06                	jb     f01054b6 <__umoddi3+0xa6>
f01054b0:	75 0e                	jne    f01054c0 <__umoddi3+0xb0>
f01054b2:	39 c6                	cmp    %eax,%esi
f01054b4:	73 0a                	jae    f01054c0 <__umoddi3+0xb0>
f01054b6:	2b 44 24 08          	sub    0x8(%esp),%eax
f01054ba:	19 ea                	sbb    %ebp,%edx
f01054bc:	89 d7                	mov    %edx,%edi
f01054be:	89 c3                	mov    %eax,%ebx
f01054c0:	89 ca                	mov    %ecx,%edx
f01054c2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f01054c7:	29 de                	sub    %ebx,%esi
f01054c9:	19 fa                	sbb    %edi,%edx
f01054cb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f01054cf:	89 d0                	mov    %edx,%eax
f01054d1:	d3 e0                	shl    %cl,%eax
f01054d3:	89 d9                	mov    %ebx,%ecx
f01054d5:	d3 ee                	shr    %cl,%esi
f01054d7:	d3 ea                	shr    %cl,%edx
f01054d9:	09 f0                	or     %esi,%eax
f01054db:	83 c4 1c             	add    $0x1c,%esp
f01054de:	5b                   	pop    %ebx
f01054df:	5e                   	pop    %esi
f01054e0:	5f                   	pop    %edi
f01054e1:	5d                   	pop    %ebp
f01054e2:	c3                   	ret    
f01054e3:	90                   	nop
f01054e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01054e8:	85 ff                	test   %edi,%edi
f01054ea:	89 f9                	mov    %edi,%ecx
f01054ec:	75 0b                	jne    f01054f9 <__umoddi3+0xe9>
f01054ee:	b8 01 00 00 00       	mov    $0x1,%eax
f01054f3:	31 d2                	xor    %edx,%edx
f01054f5:	f7 f7                	div    %edi
f01054f7:	89 c1                	mov    %eax,%ecx
f01054f9:	89 d8                	mov    %ebx,%eax
f01054fb:	31 d2                	xor    %edx,%edx
f01054fd:	f7 f1                	div    %ecx
f01054ff:	89 f0                	mov    %esi,%eax
f0105501:	f7 f1                	div    %ecx
f0105503:	e9 31 ff ff ff       	jmp    f0105439 <__umoddi3+0x29>
f0105508:	90                   	nop
f0105509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105510:	39 dd                	cmp    %ebx,%ebp
f0105512:	72 08                	jb     f010551c <__umoddi3+0x10c>
f0105514:	39 f7                	cmp    %esi,%edi
f0105516:	0f 87 21 ff ff ff    	ja     f010543d <__umoddi3+0x2d>
f010551c:	89 da                	mov    %ebx,%edx
f010551e:	89 f0                	mov    %esi,%eax
f0105520:	29 f8                	sub    %edi,%eax
f0105522:	19 ea                	sbb    %ebp,%edx
f0105524:	e9 14 ff ff ff       	jmp    f010543d <__umoddi3+0x2d>
