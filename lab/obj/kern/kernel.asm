
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
f0100015:	b8 00 c0 18 00       	mov    $0x18c000,%eax
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
f0100034:	bc 00 90 11 f0       	mov    $0xf0119000,%esp

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
f010004c:	81 c3 d4 af 08 00    	add    $0x8afd4,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c0 10 e0 18 f0    	mov    $0xf018e010,%eax
f0100058:	c7 c2 00 d1 18 f0    	mov    $0xf018d100,%edx
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 d2 46 00 00       	call   f010473b <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 4e 05 00 00       	call   f01005bc <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 60 9b f7 ff    	lea    -0x864a0(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 07 36 00 00       	call   f0103689 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100082:	e8 2a 13 00 00       	call   f01013b1 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100087:	e8 99 31 00 00       	call   f0103225 <env_init>
	trap_init();
f010008c:	e8 ab 36 00 00       	call   f010373c <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f0100091:	83 c4 08             	add    $0x8,%esp
f0100094:	6a 00                	push   $0x0
f0100096:	ff b3 f4 ff ff ff    	pushl  -0xc(%ebx)
f010009c:	e8 bd 32 00 00       	call   f010335e <env_create>
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a1:	83 c4 04             	add    $0x4,%esp
f01000a4:	c7 c0 48 d3 18 f0    	mov    $0xf018d348,%eax
f01000aa:	ff 30                	pushl  (%eax)
f01000ac:	e8 27 35 00 00       	call   f01035d8 <env_run>

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
f01000bf:	81 c3 61 af 08 00    	add    $0x8af61,%ebx
f01000c5:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f01000c8:	c7 c0 00 e0 18 f0    	mov    $0xf018e000,%eax
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
f01000f2:	8d 83 7b 9b f7 ff    	lea    -0x86485(%ebx),%eax
f01000f8:	50                   	push   %eax
f01000f9:	e8 8b 35 00 00       	call   f0103689 <cprintf>
	vcprintf(fmt, ap);
f01000fe:	83 c4 08             	add    $0x8,%esp
f0100101:	56                   	push   %esi
f0100102:	57                   	push   %edi
f0100103:	e8 4a 35 00 00       	call   f0103652 <vcprintf>
	cprintf("\n");
f0100108:	8d 83 cf aa f7 ff    	lea    -0x85531(%ebx),%eax
f010010e:	89 04 24             	mov    %eax,(%esp)
f0100111:	e8 73 35 00 00       	call   f0103689 <cprintf>
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
f0100125:	81 c3 fb ae 08 00    	add    $0x8aefb,%ebx
	va_list ap;

	va_start(ap, fmt);
f010012b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f010012e:	83 ec 04             	sub    $0x4,%esp
f0100131:	ff 75 0c             	pushl  0xc(%ebp)
f0100134:	ff 75 08             	pushl  0x8(%ebp)
f0100137:	8d 83 93 9b f7 ff    	lea    -0x8646d(%ebx),%eax
f010013d:	50                   	push   %eax
f010013e:	e8 46 35 00 00       	call   f0103689 <cprintf>
	vcprintf(fmt, ap);
f0100143:	83 c4 08             	add    $0x8,%esp
f0100146:	56                   	push   %esi
f0100147:	ff 75 10             	pushl  0x10(%ebp)
f010014a:	e8 03 35 00 00       	call   f0103652 <vcprintf>
	cprintf("\n");
f010014f:	8d 83 cf aa f7 ff    	lea    -0x85531(%ebx),%eax
f0100155:	89 04 24             	mov    %eax,(%esp)
f0100158:	e8 2c 35 00 00       	call   f0103689 <cprintf>
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
f0100194:	81 c3 8c ae 08 00    	add    $0x8ae8c,%ebx
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
f01001df:	81 c3 41 ae 08 00    	add    $0x8ae41,%ebx
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
f010022f:	0f b6 84 13 e0 9c f7 	movzbl -0x86320(%ebx,%edx,1),%eax
f0100236:	ff 
f0100237:	0b 83 e0 20 00 00    	or     0x20e0(%ebx),%eax
	shift ^= togglecode[data];
f010023d:	0f b6 8c 13 e0 9b f7 	movzbl -0x86420(%ebx,%edx,1),%ecx
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
f0100282:	8d 83 ad 9b f7 ff    	lea    -0x86453(%ebx),%eax
f0100288:	50                   	push   %eax
f0100289:	e8 fb 33 00 00       	call   f0103689 <cprintf>
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
f01002c9:	0f b6 84 13 e0 9c f7 	movzbl -0x86320(%ebx,%edx,1),%eax
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
f0100315:	81 c3 0b ad 08 00    	add    $0x8ad0b,%ebx
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
f01004ea:	e8 99 42 00 00       	call   f0104788 <memmove>
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
f0100522:	05 fe aa 08 00       	add    $0x8aafe,%eax
	if (serial_exists)
f0100527:	80 b8 14 23 00 00 00 	cmpb   $0x0,0x2314(%eax)
f010052e:	75 02                	jne    f0100532 <serial_intr+0x15>
f0100530:	f3 c3                	repz ret 
{
f0100532:	55                   	push   %ebp
f0100533:	89 e5                	mov    %esp,%ebp
f0100535:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100538:	8d 80 4b 51 f7 ff    	lea    -0x8aeb5(%eax),%eax
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
f0100550:	05 d0 aa 08 00       	add    $0x8aad0,%eax
	cons_intr(kbd_proc_data);
f0100555:	8d 80 b5 51 f7 ff    	lea    -0x8ae4b(%eax),%eax
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
f010056e:	81 c3 b2 aa 08 00    	add    $0x8aab2,%ebx
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
f01005ca:	81 c3 56 aa 08 00    	add    $0x8aa56,%ebx
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
f01006cd:	8d 83 b9 9b f7 ff    	lea    -0x86447(%ebx),%eax
f01006d3:	50                   	push   %eax
f01006d4:	e8 b0 2f 00 00       	call   f0103689 <cprintf>
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
f0100717:	81 c3 09 a9 08 00    	add    $0x8a909,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010071d:	83 ec 04             	sub    $0x4,%esp
f0100720:	8d 83 e0 9d f7 ff    	lea    -0x86220(%ebx),%eax
f0100726:	50                   	push   %eax
f0100727:	8d 83 fe 9d f7 ff    	lea    -0x86202(%ebx),%eax
f010072d:	50                   	push   %eax
f010072e:	8d b3 03 9e f7 ff    	lea    -0x861fd(%ebx),%esi
f0100734:	56                   	push   %esi
f0100735:	e8 4f 2f 00 00       	call   f0103689 <cprintf>
f010073a:	83 c4 0c             	add    $0xc,%esp
f010073d:	8d 83 a8 9e f7 ff    	lea    -0x86158(%ebx),%eax
f0100743:	50                   	push   %eax
f0100744:	8d 83 0c 9e f7 ff    	lea    -0x861f4(%ebx),%eax
f010074a:	50                   	push   %eax
f010074b:	56                   	push   %esi
f010074c:	e8 38 2f 00 00       	call   f0103689 <cprintf>
f0100751:	83 c4 0c             	add    $0xc,%esp
f0100754:	8d 83 15 9e f7 ff    	lea    -0x861eb(%ebx),%eax
f010075a:	50                   	push   %eax
f010075b:	8d 83 1b 9e f7 ff    	lea    -0x861e5(%ebx),%eax
f0100761:	50                   	push   %eax
f0100762:	56                   	push   %esi
f0100763:	e8 21 2f 00 00       	call   f0103689 <cprintf>
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
f0100782:	81 c3 9e a8 08 00    	add    $0x8a89e,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100788:	8d 83 25 9e f7 ff    	lea    -0x861db(%ebx),%eax
f010078e:	50                   	push   %eax
f010078f:	e8 f5 2e 00 00       	call   f0103689 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100794:	83 c4 08             	add    $0x8,%esp
f0100797:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f010079d:	8d 83 d0 9e f7 ff    	lea    -0x86130(%ebx),%eax
f01007a3:	50                   	push   %eax
f01007a4:	e8 e0 2e 00 00       	call   f0103689 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007a9:	83 c4 0c             	add    $0xc,%esp
f01007ac:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007b2:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007b8:	50                   	push   %eax
f01007b9:	57                   	push   %edi
f01007ba:	8d 83 f8 9e f7 ff    	lea    -0x86108(%ebx),%eax
f01007c0:	50                   	push   %eax
f01007c1:	e8 c3 2e 00 00       	call   f0103689 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007c6:	83 c4 0c             	add    $0xc,%esp
f01007c9:	c7 c0 79 4b 10 f0    	mov    $0xf0104b79,%eax
f01007cf:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007d5:	52                   	push   %edx
f01007d6:	50                   	push   %eax
f01007d7:	8d 83 1c 9f f7 ff    	lea    -0x860e4(%ebx),%eax
f01007dd:	50                   	push   %eax
f01007de:	e8 a6 2e 00 00       	call   f0103689 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007e3:	83 c4 0c             	add    $0xc,%esp
f01007e6:	c7 c0 00 d1 18 f0    	mov    $0xf018d100,%eax
f01007ec:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007f2:	52                   	push   %edx
f01007f3:	50                   	push   %eax
f01007f4:	8d 83 40 9f f7 ff    	lea    -0x860c0(%ebx),%eax
f01007fa:	50                   	push   %eax
f01007fb:	e8 89 2e 00 00       	call   f0103689 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100800:	83 c4 0c             	add    $0xc,%esp
f0100803:	c7 c6 10 e0 18 f0    	mov    $0xf018e010,%esi
f0100809:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010080f:	50                   	push   %eax
f0100810:	56                   	push   %esi
f0100811:	8d 83 64 9f f7 ff    	lea    -0x8609c(%ebx),%eax
f0100817:	50                   	push   %eax
f0100818:	e8 6c 2e 00 00       	call   f0103689 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010081d:	83 c4 08             	add    $0x8,%esp
			ROUNDUP(end - entry, 1024) / 1024);
f0100820:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f0100826:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100828:	c1 fe 0a             	sar    $0xa,%esi
f010082b:	56                   	push   %esi
f010082c:	8d 83 88 9f f7 ff    	lea    -0x86078(%ebx),%eax
f0100832:	50                   	push   %eax
f0100833:	e8 51 2e 00 00       	call   f0103689 <cprintf>
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
f0100853:	81 c3 cd a7 08 00    	add    $0x8a7cd,%ebx

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
f0100863:	8d 83 3e 9e f7 ff    	lea    -0x861c2(%ebx),%eax
f0100869:	89 45 b8             	mov    %eax,-0x48(%ebp)
		int *args = ebp + 2;		 // 从偏移量2开始存储的是上个函数的参数
		for (int i = 0; i < 5; ++i)	 // 练习要求打印5个参数
			cprintf("%x ", args[i]); // 输出参数，注：args[i]和args+i是一样的效果
f010086c:	8d 83 54 9e f7 ff    	lea    -0x861ac(%ebx),%eax
f0100872:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		cprintf("ebp %x, eip %x, args ", ebp, eip);
f0100875:	83 ec 04             	sub    $0x4,%esp
f0100878:	ff 75 c0             	pushl  -0x40(%ebp)
f010087b:	57                   	push   %edi
f010087c:	ff 75 b8             	pushl  -0x48(%ebp)
f010087f:	e8 05 2e 00 00       	call   f0103689 <cprintf>
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
f010089c:	e8 e8 2d 00 00       	call   f0103689 <cprintf>
f01008a1:	83 c6 04             	add    $0x4,%esi
		for (int i = 0; i < 5; ++i)	 // 练习要求打印5个参数
f01008a4:	83 c4 10             	add    $0x10,%esp
f01008a7:	3b 75 c4             	cmp    -0x3c(%ebp),%esi
f01008aa:	75 ea                	jne    f0100896 <mon_backtrace+0x51>
f01008ac:	8b 7d bc             	mov    -0x44(%ebp),%edi
		cprintf("\n");
f01008af:	83 ec 0c             	sub    $0xc,%esp
f01008b2:	8d 83 cf aa f7 ff    	lea    -0x85531(%ebx),%eax
f01008b8:	50                   	push   %eax
f01008b9:	e8 cb 2d 00 00       	call   f0103689 <cprintf>

		// 显示每个%eip对应的函数名、源文件名和行号
		struct Eipdebuginfo info;
		if (!debuginfo_eip(eip, &info)) // 读取debug信息，找到信息，则debuginfo_eip返回0
f01008be:	83 c4 08             	add    $0x8,%esp
f01008c1:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008c4:	50                   	push   %eax
f01008c5:	8b 75 c0             	mov    -0x40(%ebp),%esi
f01008c8:	56                   	push   %esi
f01008c9:	e8 61 33 00 00       	call   f0103c2f <debuginfo_eip>
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
f01008ea:	8d 83 58 9e f7 ff    	lea    -0x861a8(%ebx),%eax
f01008f0:	50                   	push   %eax
f01008f1:	e8 93 2d 00 00       	call   f0103689 <cprintf>
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
f0100921:	81 c3 ff a6 08 00    	add    $0x8a6ff,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100927:	8d 83 b4 9f f7 ff    	lea    -0x8604c(%ebx),%eax
f010092d:	50                   	push   %eax
f010092e:	e8 56 2d 00 00       	call   f0103689 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100933:	8d 83 d8 9f f7 ff    	lea    -0x86028(%ebx),%eax
f0100939:	89 04 24             	mov    %eax,(%esp)
f010093c:	e8 48 2d 00 00       	call   f0103689 <cprintf>

	if (tf != NULL)
f0100941:	83 c4 10             	add    $0x10,%esp
f0100944:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100948:	74 0e                	je     f0100958 <monitor+0x45>
		print_trapframe(tf);
f010094a:	83 ec 0c             	sub    $0xc,%esp
f010094d:	ff 75 08             	pushl  0x8(%ebp)
f0100950:	e8 9d 2e 00 00       	call   f01037f2 <print_trapframe>
f0100955:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100958:	8d bb 6d 9e f7 ff    	lea    -0x86193(%ebx),%edi
f010095e:	eb 4a                	jmp    f01009aa <monitor+0x97>
f0100960:	83 ec 08             	sub    $0x8,%esp
f0100963:	0f be c0             	movsbl %al,%eax
f0100966:	50                   	push   %eax
f0100967:	57                   	push   %edi
f0100968:	e8 91 3d 00 00       	call   f01046fe <strchr>
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
f010099b:	8d 83 72 9e f7 ff    	lea    -0x8618e(%ebx),%eax
f01009a1:	50                   	push   %eax
f01009a2:	e8 e2 2c 00 00       	call   f0103689 <cprintf>
f01009a7:	83 c4 10             	add    $0x10,%esp
	while (1)
	{
		buf = readline("K> ");
f01009aa:	8d 83 69 9e f7 ff    	lea    -0x86197(%ebx),%eax
f01009b0:	89 c6                	mov    %eax,%esi
f01009b2:	83 ec 0c             	sub    $0xc,%esp
f01009b5:	56                   	push   %esi
f01009b6:	e8 0b 3b 00 00       	call   f01044c6 <readline>
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
f01009e6:	e8 13 3d 00 00       	call   f01046fe <strchr>
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
f0100a24:	e8 77 3c 00 00       	call   f01046a0 <strcmp>
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
f0100a44:	8d 83 8f 9e f7 ff    	lea    -0x86171(%ebx),%eax
f0100a4a:	50                   	push   %eax
f0100a4b:	e8 39 2c 00 00       	call   f0103689 <cprintf>
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
f0100a95:	81 c3 8b a5 08 00    	add    $0x8a58b,%ebx
f0100a9b:	89 c7                	mov    %eax,%edi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a9d:	50                   	push   %eax
f0100a9e:	e8 5f 2b 00 00       	call   f0103602 <mc146818_read>
f0100aa3:	89 c6                	mov    %eax,%esi
f0100aa5:	83 c7 01             	add    $0x1,%edi
f0100aa8:	89 3c 24             	mov    %edi,(%esp)
f0100aab:	e8 52 2b 00 00       	call   f0103602 <mc146818_read>
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
f0100ac9:	81 c3 57 a5 08 00    	add    $0x8a557,%ebx
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
f0100b05:	c7 c0 10 e0 18 f0    	mov    $0xf018e010,%eax
f0100b0b:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100b10:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b15:	89 83 18 23 00 00    	mov    %eax,0x2318(%ebx)
f0100b1b:	eb bd                	jmp    f0100ada <boot_alloc+0x1d>
		return nextfree;
f0100b1d:	8b 83 18 23 00 00    	mov    0x2318(%ebx),%eax
f0100b23:	eb db                	jmp    f0100b00 <boot_alloc+0x43>
		panic("out of memory(4MB) : boot_alloc() in pmap.c \n"); // 调用预先定义的assert
f0100b25:	83 ec 04             	sub    $0x4,%esp
f0100b28:	8d 83 00 a0 f7 ff    	lea    -0x86000(%ebx),%eax
f0100b2e:	50                   	push   %eax
f0100b2f:	6a 68                	push   $0x68
f0100b31:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
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
f0100b42:	e8 0b 26 00 00       	call   f0103152 <__x86.get_pc_thunk.cx>
f0100b47:	81 c1 d9 a4 08 00    	add    $0x8a4d9,%ecx
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
f0100b63:	c7 c3 04 e0 18 f0    	mov    $0xf018e004,%ebx
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
f0100b99:	8d 81 30 a0 f7 ff    	lea    -0x85fd0(%ecx),%eax
f0100b9f:	50                   	push   %eax
f0100ba0:	68 a3 02 00 00       	push   $0x2a3
f0100ba5:	8d 81 75 a8 f7 ff    	lea    -0x8578b(%ecx),%eax
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
f0100bc3:	e8 92 25 00 00       	call   f010315a <__x86.get_pc_thunk.di>
f0100bc8:	81 c7 58 a4 08 00    	add    $0x8a458,%edi
f0100bce:	89 7d c4             	mov    %edi,-0x3c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bd1:	84 c0                	test   %al,%al
f0100bd3:	0f 85 dd 02 00 00    	jne    f0100eb6 <check_page_free_list+0x2fc>
	if (!page_free_list)
f0100bd9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100bdc:	83 b8 1c 23 00 00 00 	cmpl   $0x0,0x231c(%eax)
f0100be3:	74 0c                	je     f0100bf1 <check_page_free_list+0x37>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100be5:	c7 45 d4 00 04 00 00 	movl   $0x400,-0x2c(%ebp)
f0100bec:	e9 2f 03 00 00       	jmp    f0100f20 <check_page_free_list+0x366>
		panic("'page_free_list' is a null pointer!");
f0100bf1:	83 ec 04             	sub    $0x4,%esp
f0100bf4:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100bf7:	8d 83 54 a0 f7 ff    	lea    -0x85fac(%ebx),%eax
f0100bfd:	50                   	push   %eax
f0100bfe:	68 db 01 00 00       	push   $0x1db
f0100c03:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0100c09:	50                   	push   %eax
f0100c0a:	e8 a2 f4 ff ff       	call   f01000b1 <_panic>
f0100c0f:	50                   	push   %eax
f0100c10:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100c13:	8d 83 30 a0 f7 ff    	lea    -0x85fd0(%ebx),%eax
f0100c19:	50                   	push   %eax
f0100c1a:	6a 56                	push   $0x56
f0100c1c:	8d 83 81 a8 f7 ff    	lea    -0x8577f(%ebx),%eax
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
f0100c64:	e8 d2 3a 00 00       	call   f010473b <memset>
f0100c69:	83 c4 10             	add    $0x10,%esp
f0100c6c:	eb ba                	jmp    f0100c28 <check_page_free_list+0x6e>
	first_free_page = (char *)boot_alloc(0);
f0100c6e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c73:	e8 45 fe ff ff       	call   f0100abd <boot_alloc>
f0100c78:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c7b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100c7e:	8b 97 1c 23 00 00    	mov    0x231c(%edi),%edx
		assert(pp >= pages);
f0100c84:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0100c8a:	8b 08                	mov    (%eax),%ecx
		assert(pp < pages + npages);
f0100c8c:	c7 c0 04 e0 18 f0    	mov    $0xf018e004,%eax
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
f0100cad:	8d 83 8f a8 f7 ff    	lea    -0x85771(%ebx),%eax
f0100cb3:	50                   	push   %eax
f0100cb4:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0100cba:	50                   	push   %eax
f0100cbb:	68 f8 01 00 00       	push   $0x1f8
f0100cc0:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0100cc6:	50                   	push   %eax
f0100cc7:	e8 e5 f3 ff ff       	call   f01000b1 <_panic>
		assert(pp < pages + npages);
f0100ccc:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100ccf:	8d 83 b0 a8 f7 ff    	lea    -0x85750(%ebx),%eax
f0100cd5:	50                   	push   %eax
f0100cd6:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0100cdc:	50                   	push   %eax
f0100cdd:	68 f9 01 00 00       	push   $0x1f9
f0100ce2:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0100ce8:	50                   	push   %eax
f0100ce9:	e8 c3 f3 ff ff       	call   f01000b1 <_panic>
		assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0100cee:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100cf1:	8d 83 78 a0 f7 ff    	lea    -0x85f88(%ebx),%eax
f0100cf7:	50                   	push   %eax
f0100cf8:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0100cfe:	50                   	push   %eax
f0100cff:	68 fa 01 00 00       	push   $0x1fa
f0100d04:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0100d0a:	50                   	push   %eax
f0100d0b:	e8 a1 f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != 0);
f0100d10:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d13:	8d 83 c4 a8 f7 ff    	lea    -0x8573c(%ebx),%eax
f0100d19:	50                   	push   %eax
f0100d1a:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0100d20:	50                   	push   %eax
f0100d21:	68 fd 01 00 00       	push   $0x1fd
f0100d26:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0100d2c:	50                   	push   %eax
f0100d2d:	e8 7f f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d32:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d35:	8d 83 d5 a8 f7 ff    	lea    -0x8572b(%ebx),%eax
f0100d3b:	50                   	push   %eax
f0100d3c:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0100d42:	50                   	push   %eax
f0100d43:	68 fe 01 00 00       	push   $0x1fe
f0100d48:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0100d4e:	50                   	push   %eax
f0100d4f:	e8 5d f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d54:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d57:	8d 83 a8 a0 f7 ff    	lea    -0x85f58(%ebx),%eax
f0100d5d:	50                   	push   %eax
f0100d5e:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0100d64:	50                   	push   %eax
f0100d65:	68 ff 01 00 00       	push   $0x1ff
f0100d6a:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0100d70:	50                   	push   %eax
f0100d71:	e8 3b f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d76:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d79:	8d 83 ee a8 f7 ff    	lea    -0x85712(%ebx),%eax
f0100d7f:	50                   	push   %eax
f0100d80:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0100d86:	50                   	push   %eax
f0100d87:	68 00 02 00 00       	push   $0x200
f0100d8c:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
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
f0100e16:	8d 83 30 a0 f7 ff    	lea    -0x85fd0(%ebx),%eax
f0100e1c:	50                   	push   %eax
f0100e1d:	6a 56                	push   $0x56
f0100e1f:	8d 83 81 a8 f7 ff    	lea    -0x8577f(%ebx),%eax
f0100e25:	50                   	push   %eax
f0100e26:	e8 86 f2 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f0100e2b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e2e:	8d 83 cc a0 f7 ff    	lea    -0x85f34(%ebx),%eax
f0100e34:	50                   	push   %eax
f0100e35:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0100e3b:	50                   	push   %eax
f0100e3c:	68 01 02 00 00       	push   $0x201
f0100e41:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
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
f0100e5e:	8d 83 10 a1 f7 ff    	lea    -0x85ef0(%ebx),%eax
f0100e64:	50                   	push   %eax
f0100e65:	e8 1f 28 00 00       	call   f0103689 <cprintf>
}
f0100e6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e6d:	5b                   	pop    %ebx
f0100e6e:	5e                   	pop    %esi
f0100e6f:	5f                   	pop    %edi
f0100e70:	5d                   	pop    %ebp
f0100e71:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e72:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e75:	8d 83 08 a9 f7 ff    	lea    -0x856f8(%ebx),%eax
f0100e7b:	50                   	push   %eax
f0100e7c:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0100e82:	50                   	push   %eax
f0100e83:	68 09 02 00 00       	push   $0x209
f0100e88:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0100e8e:	50                   	push   %eax
f0100e8f:	e8 1d f2 ff ff       	call   f01000b1 <_panic>
	assert(nfree_extmem > 0);
f0100e94:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e97:	8d 83 1a a9 f7 ff    	lea    -0x856e6(%ebx),%eax
f0100e9d:	50                   	push   %eax
f0100e9e:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0100ea4:	50                   	push   %eax
f0100ea5:	68 0a 02 00 00       	push   $0x20a
f0100eaa:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0100eb0:	50                   	push   %eax
f0100eb1:	e8 fb f1 ff ff       	call   f01000b1 <_panic>
	if (!page_free_list)
f0100eb6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100eb9:	8b 80 1c 23 00 00    	mov    0x231c(%eax),%eax
f0100ebf:	85 c0                	test   %eax,%eax
f0100ec1:	0f 84 2a fd ff ff    	je     f0100bf1 <check_page_free_list+0x37>
		struct PageInfo **tp[2] = {&pp1, &pp2};
f0100ec7:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100eca:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100ecd:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ed0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100ed3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100ed6:	c7 c3 0c e0 18 f0    	mov    $0xf018e00c,%ebx
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
f0100f13:	89 87 1c 23 00 00    	mov    %eax,0x231c(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f19:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f20:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100f23:	8b b0 1c 23 00 00    	mov    0x231c(%eax),%esi
f0100f29:	c7 c7 0c e0 18 f0    	mov    $0xf018e00c,%edi
	if (PGNUM(pa) >= npages)
f0100f2f:	c7 c0 04 e0 18 f0    	mov    $0xf018e004,%eax
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
f0100f46:	e8 0b 22 00 00       	call   f0103156 <__x86.get_pc_thunk.si>
f0100f4b:	81 c6 d5 a0 08 00    	add    $0x8a0d5,%esi
f0100f51:	89 75 e4             	mov    %esi,-0x1c(%ebp)
	page_free_list = NULL; // page_free_list是static的，不会被初始化，必须给一个初始值
f0100f54:	c7 86 1c 23 00 00 00 	movl   $0x0,0x231c(%esi)
f0100f5b:	00 00 00 
	for (size_t i = 1; i < npages_basemem; i++) // 将内存中的pages数组初始化为链表，头指针是page_free_list
f0100f5e:	8b be 20 23 00 00    	mov    0x2320(%esi),%edi
f0100f64:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f69:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100f6e:	b8 01 00 00 00       	mov    $0x1,%eax
		pages[i].pp_ref = 0;
f0100f73:	c7 c6 0c e0 18 f0    	mov    $0xf018e00c,%esi
	for (size_t i = 1; i < npages_basemem; i++) // 将内存中的pages数组初始化为链表，头指针是page_free_list
f0100f79:	eb 1f                	jmp    f0100f9a <page_init+0x5d>
		pages[i].pp_ref = 0;
f0100f7b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100f82:	89 d1                	mov    %edx,%ecx
f0100f84:	03 0e                	add    (%esi),%ecx
f0100f86:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100f8c:	89 19                	mov    %ebx,(%ecx)
	for (size_t i = 1; i < npages_basemem; i++) // 将内存中的pages数组初始化为链表，头指针是page_free_list
f0100f8e:	83 c0 01             	add    $0x1,%eax
		page_free_list = &pages[i]; // pages中包含了整个内存中的页，page_free_list指向其中空闲的页组成的链表的头部
f0100f91:	89 d3                	mov    %edx,%ebx
f0100f93:	03 1e                	add    (%esi),%ebx
f0100f95:	ba 01 00 00 00       	mov    $0x1,%edx
	for (size_t i = 1; i < npages_basemem; i++) // 将内存中的pages数组初始化为链表，头指针是page_free_list
f0100f9a:	39 c7                	cmp    %eax,%edi
f0100f9c:	77 dd                	ja     f0100f7b <page_init+0x3e>
f0100f9e:	84 d2                	test   %dl,%dl
f0100fa0:	75 3c                	jne    f0100fde <page_init+0xa1>
	for (size_t i = PGNUM(PADDR(boot_alloc(0))); i < npages; i++) // PADDR()将虚拟地址转化为物理地址，boot_alloc(0)得到nextfree的位置(即pages end),PGNUM()求出需要几页才能到达该地址
f0100fa2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fa7:	e8 11 fb ff ff       	call   f0100abd <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100fac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100fb1:	76 36                	jbe    f0100fe9 <page_init+0xac>
	return (physaddr_t)kva - KERNBASE;
f0100fb3:	05 00 00 00 10       	add    $0x10000000,%eax
f0100fb8:	c1 e8 0c             	shr    $0xc,%eax
f0100fbb:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100fbe:	8b 9e 1c 23 00 00    	mov    0x231c(%esi),%ebx
f0100fc4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100fcb:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100fd0:	c7 c7 04 e0 18 f0    	mov    $0xf018e004,%edi
		pages[i].pp_ref = 0;
f0100fd6:	c7 c6 0c e0 18 f0    	mov    $0xf018e00c,%esi
	for (size_t i = PGNUM(PADDR(boot_alloc(0))); i < npages; i++) // PADDR()将虚拟地址转化为物理地址，boot_alloc(0)得到nextfree的位置(即pages end),PGNUM()求出需要几页才能到达该地址
f0100fdc:	eb 42                	jmp    f0101020 <page_init+0xe3>
f0100fde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100fe1:	89 98 1c 23 00 00    	mov    %ebx,0x231c(%eax)
f0100fe7:	eb b9                	jmp    f0100fa2 <page_init+0x65>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100fe9:	50                   	push   %eax
f0100fea:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100fed:	8d 83 34 a1 f7 ff    	lea    -0x85ecc(%ebx),%eax
f0100ff3:	50                   	push   %eax
f0100ff4:	68 02 01 00 00       	push   $0x102
f0100ff9:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0100fff:	50                   	push   %eax
f0101000:	e8 ac f0 ff ff       	call   f01000b1 <_panic>
		pages[i].pp_ref = 0;
f0101005:	89 d1                	mov    %edx,%ecx
f0101007:	03 0e                	add    (%esi),%ecx
f0101009:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f010100f:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0101011:	89 d3                	mov    %edx,%ebx
f0101013:	03 1e                	add    (%esi),%ebx
	for (size_t i = PGNUM(PADDR(boot_alloc(0))); i < npages; i++) // PADDR()将虚拟地址转化为物理地址，boot_alloc(0)得到nextfree的位置(即pages end),PGNUM()求出需要几页才能到达该地址
f0101015:	83 c0 01             	add    $0x1,%eax
f0101018:	83 c2 08             	add    $0x8,%edx
f010101b:	b9 01 00 00 00       	mov    $0x1,%ecx
f0101020:	39 07                	cmp    %eax,(%edi)
f0101022:	77 e1                	ja     f0101005 <page_init+0xc8>
f0101024:	84 c9                	test   %cl,%cl
f0101026:	75 08                	jne    f0101030 <page_init+0xf3>
}
f0101028:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010102b:	5b                   	pop    %ebx
f010102c:	5e                   	pop    %esi
f010102d:	5f                   	pop    %edi
f010102e:	5d                   	pop    %ebp
f010102f:	c3                   	ret    
f0101030:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101033:	89 98 1c 23 00 00    	mov    %ebx,0x231c(%eax)
f0101039:	eb ed                	jmp    f0101028 <page_init+0xeb>

f010103b <page_alloc>:
{
f010103b:	55                   	push   %ebp
f010103c:	89 e5                	mov    %esp,%ebp
f010103e:	56                   	push   %esi
f010103f:	53                   	push   %ebx
f0101040:	e8 22 f1 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0101045:	81 c3 db 9f 08 00    	add    $0x89fdb,%ebx
	if (page_free_list) // page_free_list指向空闲页组成的链表的头部
f010104b:	8b b3 1c 23 00 00    	mov    0x231c(%ebx),%esi
f0101051:	85 f6                	test   %esi,%esi
f0101053:	74 1a                	je     f010106f <page_alloc+0x34>
		page_free_list = page_free_list->pp_link; // 链表next行进
f0101055:	8b 06                	mov    (%esi),%eax
f0101057:	89 83 1c 23 00 00    	mov    %eax,0x231c(%ebx)
		if (alloc_flags & ALLOC_ZERO)
f010105d:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101061:	75 15                	jne    f0101078 <page_alloc+0x3d>
		result->pp_ref = 0;
f0101063:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
		result->pp_link = NULL; // 确保page_free就可以检查错误
f0101069:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
}
f010106f:	89 f0                	mov    %esi,%eax
f0101071:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101074:	5b                   	pop    %ebx
f0101075:	5e                   	pop    %esi
f0101076:	5d                   	pop    %ebp
f0101077:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0101078:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f010107e:	89 f2                	mov    %esi,%edx
f0101080:	2b 10                	sub    (%eax),%edx
f0101082:	89 d0                	mov    %edx,%eax
f0101084:	c1 f8 03             	sar    $0x3,%eax
f0101087:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010108a:	89 c1                	mov    %eax,%ecx
f010108c:	c1 e9 0c             	shr    $0xc,%ecx
f010108f:	c7 c2 04 e0 18 f0    	mov    $0xf018e004,%edx
f0101095:	3b 0a                	cmp    (%edx),%ecx
f0101097:	73 1a                	jae    f01010b3 <page_alloc+0x78>
			memset(page2kva(result), 0, PGSIZE); // page2kva(p)：求得页p的地址，方法就是先求出p的索引i，用i*4096得到地址
f0101099:	83 ec 04             	sub    $0x4,%esp
f010109c:	68 00 10 00 00       	push   $0x1000
f01010a1:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01010a3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010a8:	50                   	push   %eax
f01010a9:	e8 8d 36 00 00       	call   f010473b <memset>
f01010ae:	83 c4 10             	add    $0x10,%esp
f01010b1:	eb b0                	jmp    f0101063 <page_alloc+0x28>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010b3:	50                   	push   %eax
f01010b4:	8d 83 30 a0 f7 ff    	lea    -0x85fd0(%ebx),%eax
f01010ba:	50                   	push   %eax
f01010bb:	6a 56                	push   $0x56
f01010bd:	8d 83 81 a8 f7 ff    	lea    -0x8577f(%ebx),%eax
f01010c3:	50                   	push   %eax
f01010c4:	e8 e8 ef ff ff       	call   f01000b1 <_panic>

f01010c9 <page_free>:
{
f01010c9:	55                   	push   %ebp
f01010ca:	89 e5                	mov    %esp,%ebp
f01010cc:	53                   	push   %ebx
f01010cd:	83 ec 04             	sub    $0x4,%esp
f01010d0:	e8 92 f0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01010d5:	81 c3 4b 9f 08 00    	add    $0x89f4b,%ebx
f01010db:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref != 0 || pp->pp_link != NULL) // 还有人在使用这个page时，调用了释放函数
f01010de:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01010e3:	75 18                	jne    f01010fd <page_free+0x34>
f01010e5:	83 38 00             	cmpl   $0x0,(%eax)
f01010e8:	75 13                	jne    f01010fd <page_free+0x34>
	pp->pp_link = page_free_list;
f01010ea:	8b 8b 1c 23 00 00    	mov    0x231c(%ebx),%ecx
f01010f0:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp;
f01010f2:	89 83 1c 23 00 00    	mov    %eax,0x231c(%ebx)
}
f01010f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010fb:	c9                   	leave  
f01010fc:	c3                   	ret    
		panic("can't free this page, this page is in used: page_free() in pmap.c \n");
f01010fd:	83 ec 04             	sub    $0x4,%esp
f0101100:	8d 83 58 a1 f7 ff    	lea    -0x85ea8(%ebx),%eax
f0101106:	50                   	push   %eax
f0101107:	68 29 01 00 00       	push   $0x129
f010110c:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0101112:	50                   	push   %eax
f0101113:	e8 99 ef ff ff       	call   f01000b1 <_panic>

f0101118 <page_decref>:
{
f0101118:	55                   	push   %ebp
f0101119:	89 e5                	mov    %esp,%ebp
f010111b:	83 ec 08             	sub    $0x8,%esp
f010111e:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101121:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101125:	83 e8 01             	sub    $0x1,%eax
f0101128:	66 89 42 04          	mov    %ax,0x4(%edx)
f010112c:	66 85 c0             	test   %ax,%ax
f010112f:	74 02                	je     f0101133 <page_decref+0x1b>
}
f0101131:	c9                   	leave  
f0101132:	c3                   	ret    
		page_free(pp);
f0101133:	83 ec 0c             	sub    $0xc,%esp
f0101136:	52                   	push   %edx
f0101137:	e8 8d ff ff ff       	call   f01010c9 <page_free>
f010113c:	83 c4 10             	add    $0x10,%esp
}
f010113f:	eb f0                	jmp    f0101131 <page_decref+0x19>

f0101141 <pgdir_walk>:
{
f0101141:	55                   	push   %ebp
f0101142:	89 e5                	mov    %esp,%ebp
f0101144:	57                   	push   %edi
f0101145:	56                   	push   %esi
f0101146:	53                   	push   %ebx
f0101147:	83 ec 0c             	sub    $0xc,%esp
f010114a:	e8 18 f0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010114f:	81 c3 d1 9e 08 00    	add    $0x89ed1,%ebx
f0101155:	8b 75 0c             	mov    0xc(%ebp),%esi
	pde_t *pde = &pgdir[PDX(va)]; // 先由PDX(va)得到该地址对应的目录索引，并在目录中索引得到对应条目(一个32位地址),解引用pde即可得到对应条目
f0101158:	89 f7                	mov    %esi,%edi
f010115a:	c1 ef 16             	shr    $0x16,%edi
f010115d:	c1 e7 02             	shl    $0x2,%edi
f0101160:	03 7d 08             	add    0x8(%ebp),%edi
	if (*pde && PTE_P) // 当“va”的PTE所在的页存在，该页对应的条目在目录中的值就!=0
f0101163:	8b 07                	mov    (%edi),%eax
f0101165:	85 c0                	test   %eax,%eax
f0101167:	74 45                	je     f01011ae <pgdir_walk+0x6d>
		pte_tab = (pte_t *)KADDR(PTE_ADDR(*pde)); // PTE_ADDR()获得该条目对应的页的物理地址，KADDR()把物理地址转为虚拟地址
f0101169:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010116e:	89 c2                	mov    %eax,%edx
f0101170:	c1 ea 0c             	shr    $0xc,%edx
f0101173:	c7 c1 04 e0 18 f0    	mov    $0xf018e004,%ecx
f0101179:	39 11                	cmp    %edx,(%ecx)
f010117b:	76 18                	jbe    f0101195 <pgdir_walk+0x54>
		result = &pte_tab[PTX(va)];				  // 页里存的就是PTE表，用PTX(va)得到页索引，索引到对应的pte的地址
f010117d:	c1 ee 0a             	shr    $0xa,%esi
f0101180:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101186:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
}
f010118d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101190:	5b                   	pop    %ebx
f0101191:	5e                   	pop    %esi
f0101192:	5f                   	pop    %edi
f0101193:	5d                   	pop    %ebp
f0101194:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101195:	50                   	push   %eax
f0101196:	8d 83 30 a0 f7 ff    	lea    -0x85fd0(%ebx),%eax
f010119c:	50                   	push   %eax
f010119d:	68 44 01 00 00       	push   $0x144
f01011a2:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01011a8:	50                   	push   %eax
f01011a9:	e8 03 ef ff ff       	call   f01000b1 <_panic>
		if (!create)
f01011ae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01011b2:	74 6a                	je     f010121e <pgdir_walk+0xdd>
		struct PageInfo *pp = page_alloc(ALLOC_ZERO); // 分配新的一页来存储PTE表
f01011b4:	83 ec 0c             	sub    $0xc,%esp
f01011b7:	6a 01                	push   $0x1
f01011b9:	e8 7d fe ff ff       	call   f010103b <page_alloc>
		if (!pp) // 如果pp == NULL，分配失败
f01011be:	83 c4 10             	add    $0x10,%esp
f01011c1:	85 c0                	test   %eax,%eax
f01011c3:	74 63                	je     f0101228 <pgdir_walk+0xe7>
	return (pp - pages) << PGSHIFT;
f01011c5:	c7 c1 0c e0 18 f0    	mov    $0xf018e00c,%ecx
f01011cb:	89 c2                	mov    %eax,%edx
f01011cd:	2b 11                	sub    (%ecx),%edx
f01011cf:	c1 fa 03             	sar    $0x3,%edx
f01011d2:	c1 e2 0c             	shl    $0xc,%edx
		*pde = page2pa(pp) | PTE_P | PTE_W | PTE_U; // 更新目录的条目，以指向新分配的页
f01011d5:	83 ca 07             	or     $0x7,%edx
f01011d8:	89 17                	mov    %edx,(%edi)
		pp->pp_ref++;
f01011da:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f01011df:	2b 01                	sub    (%ecx),%eax
f01011e1:	c1 f8 03             	sar    $0x3,%eax
f01011e4:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01011e7:	89 c1                	mov    %eax,%ecx
f01011e9:	c1 e9 0c             	shr    $0xc,%ecx
f01011ec:	c7 c2 04 e0 18 f0    	mov    $0xf018e004,%edx
f01011f2:	3b 0a                	cmp    (%edx),%ecx
f01011f4:	73 12                	jae    f0101208 <pgdir_walk+0xc7>
		result = &pte_tab[PTX(va)];
f01011f6:	c1 ee 0a             	shr    $0xa,%esi
f01011f9:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01011ff:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0101206:	eb 85                	jmp    f010118d <pgdir_walk+0x4c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101208:	50                   	push   %eax
f0101209:	8d 83 30 a0 f7 ff    	lea    -0x85fd0(%ebx),%eax
f010120f:	50                   	push   %eax
f0101210:	6a 56                	push   $0x56
f0101212:	8d 83 81 a8 f7 ff    	lea    -0x8577f(%ebx),%eax
f0101218:	50                   	push   %eax
f0101219:	e8 93 ee ff ff       	call   f01000b1 <_panic>
			return NULL;
f010121e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101223:	e9 65 ff ff ff       	jmp    f010118d <pgdir_walk+0x4c>
			return NULL;
f0101228:	b8 00 00 00 00       	mov    $0x0,%eax
f010122d:	e9 5b ff ff ff       	jmp    f010118d <pgdir_walk+0x4c>

f0101232 <boot_map_region>:
{
f0101232:	55                   	push   %ebp
f0101233:	89 e5                	mov    %esp,%ebp
f0101235:	57                   	push   %edi
f0101236:	56                   	push   %esi
f0101237:	53                   	push   %ebx
f0101238:	83 ec 1c             	sub    $0x1c,%esp
f010123b:	89 c7                	mov    %eax,%edi
f010123d:	89 d6                	mov    %edx,%esi
f010123f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (size_t i = 0; i < size; i += PGSIZE) // 以页为单位操作映射
f0101242:	bb 00 00 00 00       	mov    $0x0,%ebx
		*pte = (pa + i) | PTE_P | perm;							 // 物理地址写入PTE,完成映射
f0101247:	8b 45 0c             	mov    0xc(%ebp),%eax
f010124a:	83 c8 01             	or     $0x1,%eax
f010124d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (size_t i = 0; i < size; i += PGSIZE) // 以页为单位操作映射
f0101250:	eb 25                	jmp    f0101277 <boot_map_region+0x45>
f0101252:	8d 04 33             	lea    (%ebx,%esi,1),%eax
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101255:	0f 01 38             	invlpg (%eax)
		pte_t *pte = pgdir_walk(pgdir, (const void *)va + i, 1); // 得到虚拟地址对应的pte
f0101258:	83 ec 04             	sub    $0x4,%esp
f010125b:	6a 01                	push   $0x1
f010125d:	50                   	push   %eax
f010125e:	57                   	push   %edi
f010125f:	e8 dd fe ff ff       	call   f0101141 <pgdir_walk>
		*pte = (pa + i) | PTE_P | perm;							 // 物理地址写入PTE,完成映射
f0101264:	89 da                	mov    %ebx,%edx
f0101266:	03 55 08             	add    0x8(%ebp),%edx
f0101269:	0b 55 e0             	or     -0x20(%ebp),%edx
f010126c:	89 10                	mov    %edx,(%eax)
	for (size_t i = 0; i < size; i += PGSIZE) // 以页为单位操作映射
f010126e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101274:	83 c4 10             	add    $0x10,%esp
f0101277:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010127a:	72 d6                	jb     f0101252 <boot_map_region+0x20>
}
f010127c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010127f:	5b                   	pop    %ebx
f0101280:	5e                   	pop    %esi
f0101281:	5f                   	pop    %edi
f0101282:	5d                   	pop    %ebp
f0101283:	c3                   	ret    

f0101284 <page_lookup>:
{
f0101284:	55                   	push   %ebp
f0101285:	89 e5                	mov    %esp,%ebp
f0101287:	56                   	push   %esi
f0101288:	53                   	push   %ebx
f0101289:	e8 d9 ee ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010128e:	81 c3 92 9d 08 00    	add    $0x89d92,%ebx
f0101294:	8b 75 10             	mov    0x10(%ebp),%esi
	pte_t *pte = pgdir_walk(pgdir, va, 0); // 得到“va”的PTE的指针
f0101297:	83 ec 04             	sub    $0x4,%esp
f010129a:	6a 00                	push   $0x0
f010129c:	ff 75 0c             	pushl  0xc(%ebp)
f010129f:	ff 75 08             	pushl  0x8(%ebp)
f01012a2:	e8 9a fe ff ff       	call   f0101141 <pgdir_walk>
	if (pte == NULL)					   // 若PTE不存在，则“va”没有映射到对应的物理地址
f01012a7:	83 c4 10             	add    $0x10,%esp
f01012aa:	85 c0                	test   %eax,%eax
f01012ac:	74 3f                	je     f01012ed <page_lookup+0x69>
	if (pte_store)
f01012ae:	85 f6                	test   %esi,%esi
f01012b0:	74 02                	je     f01012b4 <page_lookup+0x30>
		*pte_store = pte;
f01012b2:	89 06                	mov    %eax,(%esi)
f01012b4:	8b 00                	mov    (%eax),%eax
f01012b6:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012b9:	c7 c2 04 e0 18 f0    	mov    $0xf018e004,%edx
f01012bf:	39 02                	cmp    %eax,(%edx)
f01012c1:	76 12                	jbe    f01012d5 <page_lookup+0x51>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01012c3:	c7 c2 0c e0 18 f0    	mov    $0xf018e00c,%edx
f01012c9:	8b 12                	mov    (%edx),%edx
f01012cb:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01012ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012d1:	5b                   	pop    %ebx
f01012d2:	5e                   	pop    %esi
f01012d3:	5d                   	pop    %ebp
f01012d4:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01012d5:	83 ec 04             	sub    $0x4,%esp
f01012d8:	8d 83 9c a1 f7 ff    	lea    -0x85e64(%ebx),%eax
f01012de:	50                   	push   %eax
f01012df:	6a 4f                	push   $0x4f
f01012e1:	8d 83 81 a8 f7 ff    	lea    -0x8577f(%ebx),%eax
f01012e7:	50                   	push   %eax
f01012e8:	e8 c4 ed ff ff       	call   f01000b1 <_panic>
		return NULL;
f01012ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01012f2:	eb da                	jmp    f01012ce <page_lookup+0x4a>

f01012f4 <page_remove>:
{
f01012f4:	55                   	push   %ebp
f01012f5:	89 e5                	mov    %esp,%ebp
f01012f7:	53                   	push   %ebx
f01012f8:	83 ec 18             	sub    $0x18,%esp
f01012fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store); // 得到“va”对应的页面，和指向对应的pte的指针pte_store
f01012fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101301:	50                   	push   %eax
f0101302:	53                   	push   %ebx
f0101303:	ff 75 08             	pushl  0x8(%ebp)
f0101306:	e8 79 ff ff ff       	call   f0101284 <page_lookup>
	if (pp)
f010130b:	83 c4 10             	add    $0x10,%esp
f010130e:	85 c0                	test   %eax,%eax
f0101310:	74 18                	je     f010132a <page_remove+0x36>
		page_decref(pp);
f0101312:	83 ec 0c             	sub    $0xc,%esp
f0101315:	50                   	push   %eax
f0101316:	e8 fd fd ff ff       	call   f0101118 <page_decref>
f010131b:	0f 01 3b             	invlpg (%ebx)
		*pte_store = 0;
f010131e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101321:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0101327:	83 c4 10             	add    $0x10,%esp
}
f010132a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010132d:	c9                   	leave  
f010132e:	c3                   	ret    

f010132f <page_insert>:
{
f010132f:	55                   	push   %ebp
f0101330:	89 e5                	mov    %esp,%ebp
f0101332:	57                   	push   %edi
f0101333:	56                   	push   %esi
f0101334:	53                   	push   %ebx
f0101335:	83 ec 10             	sub    $0x10,%esp
f0101338:	e8 1d 1e 00 00       	call   f010315a <__x86.get_pc_thunk.di>
f010133d:	81 c7 e3 9c 08 00    	add    $0x89ce3,%edi
f0101343:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101346:	8b 75 10             	mov    0x10(%ebp),%esi
	pte_t *pte = pgdir_walk(pgdir, va, 1); // 得到pte的指针，create=1,代表有必要会创建新的页
f0101349:	6a 01                	push   $0x1
f010134b:	56                   	push   %esi
f010134c:	ff 75 08             	pushl  0x8(%ebp)
f010134f:	e8 ed fd ff ff       	call   f0101141 <pgdir_walk>
	if (pte == NULL)
f0101354:	83 c4 10             	add    $0x10,%esp
f0101357:	85 c0                	test   %eax,%eax
f0101359:	74 4f                	je     f01013aa <page_insert+0x7b>
	pp->pp_ref++;
f010135b:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P)
f0101360:	f6 00 01             	testb  $0x1,(%eax)
f0101363:	75 34                	jne    f0101399 <page_insert+0x6a>
	boot_map_region(pgdir, (uintptr_t)va, PGSIZE, page2pa(pp), perm);
f0101365:	83 ec 08             	sub    $0x8,%esp
f0101368:	ff 75 14             	pushl  0x14(%ebp)
	return (pp - pages) << PGSHIFT;
f010136b:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101371:	2b 18                	sub    (%eax),%ebx
f0101373:	c1 fb 03             	sar    $0x3,%ebx
f0101376:	c1 e3 0c             	shl    $0xc,%ebx
f0101379:	53                   	push   %ebx
f010137a:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010137f:	89 f2                	mov    %esi,%edx
f0101381:	8b 45 08             	mov    0x8(%ebp),%eax
f0101384:	e8 a9 fe ff ff       	call   f0101232 <boot_map_region>
	return 0;
f0101389:	83 c4 10             	add    $0x10,%esp
f010138c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101391:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101394:	5b                   	pop    %ebx
f0101395:	5e                   	pop    %esi
f0101396:	5f                   	pop    %edi
f0101397:	5d                   	pop    %ebp
f0101398:	c3                   	ret    
		page_remove(pgdir, va);
f0101399:	83 ec 08             	sub    $0x8,%esp
f010139c:	56                   	push   %esi
f010139d:	ff 75 08             	pushl  0x8(%ebp)
f01013a0:	e8 4f ff ff ff       	call   f01012f4 <page_remove>
f01013a5:	83 c4 10             	add    $0x10,%esp
f01013a8:	eb bb                	jmp    f0101365 <page_insert+0x36>
		return -E_NO_MEM;
f01013aa:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01013af:	eb e0                	jmp    f0101391 <page_insert+0x62>

f01013b1 <mem_init>:
{
f01013b1:	55                   	push   %ebp
f01013b2:	89 e5                	mov    %esp,%ebp
f01013b4:	57                   	push   %edi
f01013b5:	56                   	push   %esi
f01013b6:	53                   	push   %ebx
f01013b7:	83 ec 3c             	sub    $0x3c,%esp
f01013ba:	e8 4a f3 ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f01013bf:	05 61 9c 08 00       	add    $0x89c61,%eax
f01013c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	basemem = nvram_read(NVRAM_BASELO);
f01013c7:	b8 15 00 00 00       	mov    $0x15,%eax
f01013cc:	e8 b6 f6 ff ff       	call   f0100a87 <nvram_read>
f01013d1:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01013d3:	b8 17 00 00 00       	mov    $0x17,%eax
f01013d8:	e8 aa f6 ff ff       	call   f0100a87 <nvram_read>
f01013dd:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01013df:	b8 34 00 00 00       	mov    $0x34,%eax
f01013e4:	e8 9e f6 ff ff       	call   f0100a87 <nvram_read>
f01013e9:	c1 e0 06             	shl    $0x6,%eax
	if (ext16mem)
f01013ec:	85 c0                	test   %eax,%eax
f01013ee:	0f 85 cd 00 00 00    	jne    f01014c1 <mem_init+0x110>
		totalmem = 1 * 1024 + extmem;
f01013f4:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01013fa:	85 f6                	test   %esi,%esi
f01013fc:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f01013ff:	89 c1                	mov    %eax,%ecx
f0101401:	c1 e9 02             	shr    $0x2,%ecx
f0101404:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101407:	c7 c2 04 e0 18 f0    	mov    $0xf018e004,%edx
f010140d:	89 0a                	mov    %ecx,(%edx)
	npages_basemem = basemem / (PGSIZE / 1024);
f010140f:	89 da                	mov    %ebx,%edx
f0101411:	c1 ea 02             	shr    $0x2,%edx
f0101414:	89 97 20 23 00 00    	mov    %edx,0x2320(%edi)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010141a:	89 c2                	mov    %eax,%edx
f010141c:	29 da                	sub    %ebx,%edx
f010141e:	52                   	push   %edx
f010141f:	53                   	push   %ebx
f0101420:	50                   	push   %eax
f0101421:	8d 87 bc a1 f7 ff    	lea    -0x85e44(%edi),%eax
f0101427:	50                   	push   %eax
f0101428:	89 fb                	mov    %edi,%ebx
f010142a:	e8 5a 22 00 00       	call   f0103689 <cprintf>
	kern_pgdir = (pde_t *)boot_alloc(PGSIZE); // 第一次运行，会舍入一部分
f010142f:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101434:	e8 84 f6 ff ff       	call   f0100abd <boot_alloc>
f0101439:	c7 c6 08 e0 18 f0    	mov    $0xf018e008,%esi
f010143f:	89 06                	mov    %eax,(%esi)
	memset(kern_pgdir, 0, PGSIZE);			  // 内存初始化为0
f0101441:	83 c4 0c             	add    $0xc,%esp
f0101444:	68 00 10 00 00       	push   $0x1000
f0101449:	6a 00                	push   $0x0
f010144b:	50                   	push   %eax
f010144c:	e8 ea 32 00 00       	call   f010473b <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P; // 暂时不需要理解，只需要知道kern_pgdir处有一个页表目录
f0101451:	8b 06                	mov    (%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0101453:	83 c4 10             	add    $0x10,%esp
f0101456:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010145b:	76 6e                	jbe    f01014cb <mem_init+0x11a>
	return (physaddr_t)kva - KERNBASE;
f010145d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101463:	83 ca 05             	or     $0x5,%edx
f0101466:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *)boot_alloc(npages * sizeof(struct PageInfo)); // sizeof求得PageInfo占多少字节，返回结果记得强转成pages对应的类型
f010146c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010146f:	c7 c3 04 e0 18 f0    	mov    $0xf018e004,%ebx
f0101475:	8b 03                	mov    (%ebx),%eax
f0101477:	c1 e0 03             	shl    $0x3,%eax
f010147a:	e8 3e f6 ff ff       	call   f0100abd <boot_alloc>
f010147f:	c7 c6 0c e0 18 f0    	mov    $0xf018e00c,%esi
f0101485:	89 06                	mov    %eax,(%esi)
	memset(pages, 0, npages * sizeof(struct PageInfo));						 // memset(d,c,l):从指针d开始，用字符c填充l个长度的内存
f0101487:	83 ec 04             	sub    $0x4,%esp
f010148a:	8b 13                	mov    (%ebx),%edx
f010148c:	c1 e2 03             	shl    $0x3,%edx
f010148f:	52                   	push   %edx
f0101490:	6a 00                	push   $0x0
f0101492:	50                   	push   %eax
f0101493:	89 fb                	mov    %edi,%ebx
f0101495:	e8 a1 32 00 00       	call   f010473b <memset>
	page_init(); // 初始化之后，所有的内存管理都将通过page_*函数进行
f010149a:	e8 9e fa ff ff       	call   f0100f3d <page_init>
	check_page_free_list(1);
f010149f:	b8 01 00 00 00       	mov    $0x1,%eax
f01014a4:	e8 11 f7 ff ff       	call   f0100bba <check_page_free_list>
	if (!pages)
f01014a9:	83 c4 10             	add    $0x10,%esp
f01014ac:	83 3e 00             	cmpl   $0x0,(%esi)
f01014af:	74 36                	je     f01014e7 <mem_init+0x136>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014b4:	8b 80 1c 23 00 00    	mov    0x231c(%eax),%eax
f01014ba:	be 00 00 00 00       	mov    $0x0,%esi
f01014bf:	eb 49                	jmp    f010150a <mem_init+0x159>
		totalmem = 16 * 1024 + ext16mem;
f01014c1:	05 00 40 00 00       	add    $0x4000,%eax
f01014c6:	e9 34 ff ff ff       	jmp    f01013ff <mem_init+0x4e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01014cb:	50                   	push   %eax
f01014cc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01014cf:	8d 83 34 a1 f7 ff    	lea    -0x85ecc(%ebx),%eax
f01014d5:	50                   	push   %eax
f01014d6:	68 a2 00 00 00       	push   $0xa2
f01014db:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01014e1:	50                   	push   %eax
f01014e2:	e8 ca eb ff ff       	call   f01000b1 <_panic>
		panic("'pages' is a null pointer!");
f01014e7:	83 ec 04             	sub    $0x4,%esp
f01014ea:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01014ed:	8d 83 2b a9 f7 ff    	lea    -0x856d5(%ebx),%eax
f01014f3:	50                   	push   %eax
f01014f4:	68 1c 02 00 00       	push   $0x21c
f01014f9:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01014ff:	50                   	push   %eax
f0101500:	e8 ac eb ff ff       	call   f01000b1 <_panic>
		++nfree;
f0101505:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101508:	8b 00                	mov    (%eax),%eax
f010150a:	85 c0                	test   %eax,%eax
f010150c:	75 f7                	jne    f0101505 <mem_init+0x154>
	assert((pp0 = page_alloc(0)));
f010150e:	83 ec 0c             	sub    $0xc,%esp
f0101511:	6a 00                	push   $0x0
f0101513:	e8 23 fb ff ff       	call   f010103b <page_alloc>
f0101518:	89 c3                	mov    %eax,%ebx
f010151a:	83 c4 10             	add    $0x10,%esp
f010151d:	85 c0                	test   %eax,%eax
f010151f:	0f 84 3b 02 00 00    	je     f0101760 <mem_init+0x3af>
	assert((pp1 = page_alloc(0)));
f0101525:	83 ec 0c             	sub    $0xc,%esp
f0101528:	6a 00                	push   $0x0
f010152a:	e8 0c fb ff ff       	call   f010103b <page_alloc>
f010152f:	89 c7                	mov    %eax,%edi
f0101531:	83 c4 10             	add    $0x10,%esp
f0101534:	85 c0                	test   %eax,%eax
f0101536:	0f 84 46 02 00 00    	je     f0101782 <mem_init+0x3d1>
	assert((pp2 = page_alloc(0)));
f010153c:	83 ec 0c             	sub    $0xc,%esp
f010153f:	6a 00                	push   $0x0
f0101541:	e8 f5 fa ff ff       	call   f010103b <page_alloc>
f0101546:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101549:	83 c4 10             	add    $0x10,%esp
f010154c:	85 c0                	test   %eax,%eax
f010154e:	0f 84 50 02 00 00    	je     f01017a4 <mem_init+0x3f3>
	assert(pp1 && pp1 != pp0);
f0101554:	39 fb                	cmp    %edi,%ebx
f0101556:	0f 84 6a 02 00 00    	je     f01017c6 <mem_init+0x415>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010155c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010155f:	39 c7                	cmp    %eax,%edi
f0101561:	0f 84 81 02 00 00    	je     f01017e8 <mem_init+0x437>
f0101567:	39 c3                	cmp    %eax,%ebx
f0101569:	0f 84 79 02 00 00    	je     f01017e8 <mem_init+0x437>
	return (pp - pages) << PGSHIFT;
f010156f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101572:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101578:	8b 08                	mov    (%eax),%ecx
	assert(page2pa(pp0) < npages * PGSIZE);
f010157a:	c7 c0 04 e0 18 f0    	mov    $0xf018e004,%eax
f0101580:	8b 10                	mov    (%eax),%edx
f0101582:	c1 e2 0c             	shl    $0xc,%edx
f0101585:	89 d8                	mov    %ebx,%eax
f0101587:	29 c8                	sub    %ecx,%eax
f0101589:	c1 f8 03             	sar    $0x3,%eax
f010158c:	c1 e0 0c             	shl    $0xc,%eax
f010158f:	39 d0                	cmp    %edx,%eax
f0101591:	0f 83 73 02 00 00    	jae    f010180a <mem_init+0x459>
f0101597:	89 f8                	mov    %edi,%eax
f0101599:	29 c8                	sub    %ecx,%eax
f010159b:	c1 f8 03             	sar    $0x3,%eax
f010159e:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages * PGSIZE);
f01015a1:	39 c2                	cmp    %eax,%edx
f01015a3:	0f 86 83 02 00 00    	jbe    f010182c <mem_init+0x47b>
f01015a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015ac:	29 c8                	sub    %ecx,%eax
f01015ae:	c1 f8 03             	sar    $0x3,%eax
f01015b1:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages * PGSIZE);
f01015b4:	39 c2                	cmp    %eax,%edx
f01015b6:	0f 86 92 02 00 00    	jbe    f010184e <mem_init+0x49d>
	fl = page_free_list;
f01015bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015bf:	8b 88 1c 23 00 00    	mov    0x231c(%eax),%ecx
f01015c5:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f01015c8:	c7 80 1c 23 00 00 00 	movl   $0x0,0x231c(%eax)
f01015cf:	00 00 00 
	assert(!page_alloc(0));
f01015d2:	83 ec 0c             	sub    $0xc,%esp
f01015d5:	6a 00                	push   $0x0
f01015d7:	e8 5f fa ff ff       	call   f010103b <page_alloc>
f01015dc:	83 c4 10             	add    $0x10,%esp
f01015df:	85 c0                	test   %eax,%eax
f01015e1:	0f 85 89 02 00 00    	jne    f0101870 <mem_init+0x4bf>
	page_free(pp0);
f01015e7:	83 ec 0c             	sub    $0xc,%esp
f01015ea:	53                   	push   %ebx
f01015eb:	e8 d9 fa ff ff       	call   f01010c9 <page_free>
	page_free(pp1);
f01015f0:	89 3c 24             	mov    %edi,(%esp)
f01015f3:	e8 d1 fa ff ff       	call   f01010c9 <page_free>
	page_free(pp2);
f01015f8:	83 c4 04             	add    $0x4,%esp
f01015fb:	ff 75 d0             	pushl  -0x30(%ebp)
f01015fe:	e8 c6 fa ff ff       	call   f01010c9 <page_free>
	assert((pp0 = page_alloc(0)));
f0101603:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010160a:	e8 2c fa ff ff       	call   f010103b <page_alloc>
f010160f:	89 c7                	mov    %eax,%edi
f0101611:	83 c4 10             	add    $0x10,%esp
f0101614:	85 c0                	test   %eax,%eax
f0101616:	0f 84 76 02 00 00    	je     f0101892 <mem_init+0x4e1>
	assert((pp1 = page_alloc(0)));
f010161c:	83 ec 0c             	sub    $0xc,%esp
f010161f:	6a 00                	push   $0x0
f0101621:	e8 15 fa ff ff       	call   f010103b <page_alloc>
f0101626:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101629:	83 c4 10             	add    $0x10,%esp
f010162c:	85 c0                	test   %eax,%eax
f010162e:	0f 84 80 02 00 00    	je     f01018b4 <mem_init+0x503>
	assert((pp2 = page_alloc(0)));
f0101634:	83 ec 0c             	sub    $0xc,%esp
f0101637:	6a 00                	push   $0x0
f0101639:	e8 fd f9 ff ff       	call   f010103b <page_alloc>
f010163e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101641:	83 c4 10             	add    $0x10,%esp
f0101644:	85 c0                	test   %eax,%eax
f0101646:	0f 84 8a 02 00 00    	je     f01018d6 <mem_init+0x525>
	assert(pp1 && pp1 != pp0);
f010164c:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f010164f:	0f 84 a3 02 00 00    	je     f01018f8 <mem_init+0x547>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101655:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101658:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010165b:	0f 84 b9 02 00 00    	je     f010191a <mem_init+0x569>
f0101661:	39 c7                	cmp    %eax,%edi
f0101663:	0f 84 b1 02 00 00    	je     f010191a <mem_init+0x569>
	assert(!page_alloc(0));
f0101669:	83 ec 0c             	sub    $0xc,%esp
f010166c:	6a 00                	push   $0x0
f010166e:	e8 c8 f9 ff ff       	call   f010103b <page_alloc>
f0101673:	83 c4 10             	add    $0x10,%esp
f0101676:	85 c0                	test   %eax,%eax
f0101678:	0f 85 be 02 00 00    	jne    f010193c <mem_init+0x58b>
f010167e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101681:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101687:	89 f9                	mov    %edi,%ecx
f0101689:	2b 08                	sub    (%eax),%ecx
f010168b:	89 c8                	mov    %ecx,%eax
f010168d:	c1 f8 03             	sar    $0x3,%eax
f0101690:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101693:	89 c1                	mov    %eax,%ecx
f0101695:	c1 e9 0c             	shr    $0xc,%ecx
f0101698:	c7 c2 04 e0 18 f0    	mov    $0xf018e004,%edx
f010169e:	3b 0a                	cmp    (%edx),%ecx
f01016a0:	0f 83 b8 02 00 00    	jae    f010195e <mem_init+0x5ad>
	memset(page2kva(pp0), 1, PGSIZE);
f01016a6:	83 ec 04             	sub    $0x4,%esp
f01016a9:	68 00 10 00 00       	push   $0x1000
f01016ae:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01016b0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01016b5:	50                   	push   %eax
f01016b6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016b9:	e8 7d 30 00 00       	call   f010473b <memset>
	page_free(pp0);
f01016be:	89 3c 24             	mov    %edi,(%esp)
f01016c1:	e8 03 fa ff ff       	call   f01010c9 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01016c6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01016cd:	e8 69 f9 ff ff       	call   f010103b <page_alloc>
f01016d2:	83 c4 10             	add    $0x10,%esp
f01016d5:	85 c0                	test   %eax,%eax
f01016d7:	0f 84 97 02 00 00    	je     f0101974 <mem_init+0x5c3>
	assert(pp && pp0 == pp);
f01016dd:	39 c7                	cmp    %eax,%edi
f01016df:	0f 85 b1 02 00 00    	jne    f0101996 <mem_init+0x5e5>
	return (pp - pages) << PGSHIFT;
f01016e5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016e8:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f01016ee:	89 fa                	mov    %edi,%edx
f01016f0:	2b 10                	sub    (%eax),%edx
f01016f2:	c1 fa 03             	sar    $0x3,%edx
f01016f5:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01016f8:	89 d1                	mov    %edx,%ecx
f01016fa:	c1 e9 0c             	shr    $0xc,%ecx
f01016fd:	c7 c0 04 e0 18 f0    	mov    $0xf018e004,%eax
f0101703:	3b 08                	cmp    (%eax),%ecx
f0101705:	0f 83 ad 02 00 00    	jae    f01019b8 <mem_init+0x607>
	return (void *)(pa + KERNBASE);
f010170b:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101711:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101717:	80 38 00             	cmpb   $0x0,(%eax)
f010171a:	0f 85 ae 02 00 00    	jne    f01019ce <mem_init+0x61d>
f0101720:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101723:	39 d0                	cmp    %edx,%eax
f0101725:	75 f0                	jne    f0101717 <mem_init+0x366>
	page_free_list = fl;
f0101727:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010172a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010172d:	89 8b 1c 23 00 00    	mov    %ecx,0x231c(%ebx)
	page_free(pp0);
f0101733:	83 ec 0c             	sub    $0xc,%esp
f0101736:	57                   	push   %edi
f0101737:	e8 8d f9 ff ff       	call   f01010c9 <page_free>
	page_free(pp1);
f010173c:	83 c4 04             	add    $0x4,%esp
f010173f:	ff 75 d0             	pushl  -0x30(%ebp)
f0101742:	e8 82 f9 ff ff       	call   f01010c9 <page_free>
	page_free(pp2);
f0101747:	83 c4 04             	add    $0x4,%esp
f010174a:	ff 75 cc             	pushl  -0x34(%ebp)
f010174d:	e8 77 f9 ff ff       	call   f01010c9 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101752:	8b 83 1c 23 00 00    	mov    0x231c(%ebx),%eax
f0101758:	83 c4 10             	add    $0x10,%esp
f010175b:	e9 95 02 00 00       	jmp    f01019f5 <mem_init+0x644>
	assert((pp0 = page_alloc(0)));
f0101760:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101763:	8d 83 46 a9 f7 ff    	lea    -0x856ba(%ebx),%eax
f0101769:	50                   	push   %eax
f010176a:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0101770:	50                   	push   %eax
f0101771:	68 24 02 00 00       	push   $0x224
f0101776:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f010177c:	50                   	push   %eax
f010177d:	e8 2f e9 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101782:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101785:	8d 83 5c a9 f7 ff    	lea    -0x856a4(%ebx),%eax
f010178b:	50                   	push   %eax
f010178c:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0101792:	50                   	push   %eax
f0101793:	68 25 02 00 00       	push   $0x225
f0101798:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f010179e:	50                   	push   %eax
f010179f:	e8 0d e9 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f01017a4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017a7:	8d 83 72 a9 f7 ff    	lea    -0x8568e(%ebx),%eax
f01017ad:	50                   	push   %eax
f01017ae:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01017b4:	50                   	push   %eax
f01017b5:	68 26 02 00 00       	push   $0x226
f01017ba:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01017c0:	50                   	push   %eax
f01017c1:	e8 eb e8 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f01017c6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017c9:	8d 83 88 a9 f7 ff    	lea    -0x85678(%ebx),%eax
f01017cf:	50                   	push   %eax
f01017d0:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01017d6:	50                   	push   %eax
f01017d7:	68 29 02 00 00       	push   $0x229
f01017dc:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01017e2:	50                   	push   %eax
f01017e3:	e8 c9 e8 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017e8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017eb:	8d 83 f8 a1 f7 ff    	lea    -0x85e08(%ebx),%eax
f01017f1:	50                   	push   %eax
f01017f2:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01017f8:	50                   	push   %eax
f01017f9:	68 2a 02 00 00       	push   $0x22a
f01017fe:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0101804:	50                   	push   %eax
f0101805:	e8 a7 e8 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp0) < npages * PGSIZE);
f010180a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010180d:	8d 83 18 a2 f7 ff    	lea    -0x85de8(%ebx),%eax
f0101813:	50                   	push   %eax
f0101814:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f010181a:	50                   	push   %eax
f010181b:	68 2b 02 00 00       	push   $0x22b
f0101820:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0101826:	50                   	push   %eax
f0101827:	e8 85 e8 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp1) < npages * PGSIZE);
f010182c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010182f:	8d 83 38 a2 f7 ff    	lea    -0x85dc8(%ebx),%eax
f0101835:	50                   	push   %eax
f0101836:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f010183c:	50                   	push   %eax
f010183d:	68 2c 02 00 00       	push   $0x22c
f0101842:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0101848:	50                   	push   %eax
f0101849:	e8 63 e8 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp2) < npages * PGSIZE);
f010184e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101851:	8d 83 58 a2 f7 ff    	lea    -0x85da8(%ebx),%eax
f0101857:	50                   	push   %eax
f0101858:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f010185e:	50                   	push   %eax
f010185f:	68 2d 02 00 00       	push   $0x22d
f0101864:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f010186a:	50                   	push   %eax
f010186b:	e8 41 e8 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0101870:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101873:	8d 83 9a a9 f7 ff    	lea    -0x85666(%ebx),%eax
f0101879:	50                   	push   %eax
f010187a:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0101880:	50                   	push   %eax
f0101881:	68 34 02 00 00       	push   $0x234
f0101886:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f010188c:	50                   	push   %eax
f010188d:	e8 1f e8 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0101892:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101895:	8d 83 46 a9 f7 ff    	lea    -0x856ba(%ebx),%eax
f010189b:	50                   	push   %eax
f010189c:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01018a2:	50                   	push   %eax
f01018a3:	68 3b 02 00 00       	push   $0x23b
f01018a8:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01018ae:	50                   	push   %eax
f01018af:	e8 fd e7 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f01018b4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018b7:	8d 83 5c a9 f7 ff    	lea    -0x856a4(%ebx),%eax
f01018bd:	50                   	push   %eax
f01018be:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01018c4:	50                   	push   %eax
f01018c5:	68 3c 02 00 00       	push   $0x23c
f01018ca:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01018d0:	50                   	push   %eax
f01018d1:	e8 db e7 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f01018d6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018d9:	8d 83 72 a9 f7 ff    	lea    -0x8568e(%ebx),%eax
f01018df:	50                   	push   %eax
f01018e0:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01018e6:	50                   	push   %eax
f01018e7:	68 3d 02 00 00       	push   $0x23d
f01018ec:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01018f2:	50                   	push   %eax
f01018f3:	e8 b9 e7 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f01018f8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018fb:	8d 83 88 a9 f7 ff    	lea    -0x85678(%ebx),%eax
f0101901:	50                   	push   %eax
f0101902:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0101908:	50                   	push   %eax
f0101909:	68 3f 02 00 00       	push   $0x23f
f010190e:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0101914:	50                   	push   %eax
f0101915:	e8 97 e7 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010191a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010191d:	8d 83 f8 a1 f7 ff    	lea    -0x85e08(%ebx),%eax
f0101923:	50                   	push   %eax
f0101924:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f010192a:	50                   	push   %eax
f010192b:	68 40 02 00 00       	push   $0x240
f0101930:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0101936:	50                   	push   %eax
f0101937:	e8 75 e7 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f010193c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010193f:	8d 83 9a a9 f7 ff    	lea    -0x85666(%ebx),%eax
f0101945:	50                   	push   %eax
f0101946:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f010194c:	50                   	push   %eax
f010194d:	68 41 02 00 00       	push   $0x241
f0101952:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0101958:	50                   	push   %eax
f0101959:	e8 53 e7 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010195e:	50                   	push   %eax
f010195f:	8d 83 30 a0 f7 ff    	lea    -0x85fd0(%ebx),%eax
f0101965:	50                   	push   %eax
f0101966:	6a 56                	push   $0x56
f0101968:	8d 83 81 a8 f7 ff    	lea    -0x8577f(%ebx),%eax
f010196e:	50                   	push   %eax
f010196f:	e8 3d e7 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101974:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101977:	8d 83 a9 a9 f7 ff    	lea    -0x85657(%ebx),%eax
f010197d:	50                   	push   %eax
f010197e:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0101984:	50                   	push   %eax
f0101985:	68 46 02 00 00       	push   $0x246
f010198a:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0101990:	50                   	push   %eax
f0101991:	e8 1b e7 ff ff       	call   f01000b1 <_panic>
	assert(pp && pp0 == pp);
f0101996:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101999:	8d 83 c7 a9 f7 ff    	lea    -0x85639(%ebx),%eax
f010199f:	50                   	push   %eax
f01019a0:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01019a6:	50                   	push   %eax
f01019a7:	68 47 02 00 00       	push   $0x247
f01019ac:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01019b2:	50                   	push   %eax
f01019b3:	e8 f9 e6 ff ff       	call   f01000b1 <_panic>
f01019b8:	52                   	push   %edx
f01019b9:	8d 83 30 a0 f7 ff    	lea    -0x85fd0(%ebx),%eax
f01019bf:	50                   	push   %eax
f01019c0:	6a 56                	push   $0x56
f01019c2:	8d 83 81 a8 f7 ff    	lea    -0x8577f(%ebx),%eax
f01019c8:	50                   	push   %eax
f01019c9:	e8 e3 e6 ff ff       	call   f01000b1 <_panic>
		assert(c[i] == 0);
f01019ce:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01019d1:	8d 83 d7 a9 f7 ff    	lea    -0x85629(%ebx),%eax
f01019d7:	50                   	push   %eax
f01019d8:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01019de:	50                   	push   %eax
f01019df:	68 4a 02 00 00       	push   $0x24a
f01019e4:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01019ea:	50                   	push   %eax
f01019eb:	e8 c1 e6 ff ff       	call   f01000b1 <_panic>
		--nfree;
f01019f0:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01019f3:	8b 00                	mov    (%eax),%eax
f01019f5:	85 c0                	test   %eax,%eax
f01019f7:	75 f7                	jne    f01019f0 <mem_init+0x63f>
	assert(nfree == 0);
f01019f9:	85 f6                	test   %esi,%esi
f01019fb:	0f 85 55 08 00 00    	jne    f0102256 <mem_init+0xea5>
	cprintf("check_page_alloc() succeeded!\n");
f0101a01:	83 ec 0c             	sub    $0xc,%esp
f0101a04:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a07:	8d 83 78 a2 f7 ff    	lea    -0x85d88(%ebx),%eax
f0101a0d:	50                   	push   %eax
f0101a0e:	e8 76 1c 00 00       	call   f0103689 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101a13:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a1a:	e8 1c f6 ff ff       	call   f010103b <page_alloc>
f0101a1f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101a22:	83 c4 10             	add    $0x10,%esp
f0101a25:	85 c0                	test   %eax,%eax
f0101a27:	0f 84 4b 08 00 00    	je     f0102278 <mem_init+0xec7>
	assert((pp1 = page_alloc(0)));
f0101a2d:	83 ec 0c             	sub    $0xc,%esp
f0101a30:	6a 00                	push   $0x0
f0101a32:	e8 04 f6 ff ff       	call   f010103b <page_alloc>
f0101a37:	89 c7                	mov    %eax,%edi
f0101a39:	83 c4 10             	add    $0x10,%esp
f0101a3c:	85 c0                	test   %eax,%eax
f0101a3e:	0f 84 56 08 00 00    	je     f010229a <mem_init+0xee9>
	assert((pp2 = page_alloc(0)));
f0101a44:	83 ec 0c             	sub    $0xc,%esp
f0101a47:	6a 00                	push   $0x0
f0101a49:	e8 ed f5 ff ff       	call   f010103b <page_alloc>
f0101a4e:	89 c6                	mov    %eax,%esi
f0101a50:	83 c4 10             	add    $0x10,%esp
f0101a53:	85 c0                	test   %eax,%eax
f0101a55:	0f 84 61 08 00 00    	je     f01022bc <mem_init+0xf0b>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a5b:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0101a5e:	0f 84 7a 08 00 00    	je     f01022de <mem_init+0xf2d>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a64:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101a67:	0f 84 93 08 00 00    	je     f0102300 <mem_init+0xf4f>
f0101a6d:	39 c7                	cmp    %eax,%edi
f0101a6f:	0f 84 8b 08 00 00    	je     f0102300 <mem_init+0xf4f>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a75:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a78:	8b 88 1c 23 00 00    	mov    0x231c(%eax),%ecx
f0101a7e:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101a81:	c7 80 1c 23 00 00 00 	movl   $0x0,0x231c(%eax)
f0101a88:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a8b:	83 ec 0c             	sub    $0xc,%esp
f0101a8e:	6a 00                	push   $0x0
f0101a90:	e8 a6 f5 ff ff       	call   f010103b <page_alloc>
f0101a95:	83 c4 10             	add    $0x10,%esp
f0101a98:	85 c0                	test   %eax,%eax
f0101a9a:	0f 85 82 08 00 00    	jne    f0102322 <mem_init+0xf71>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *)0x0, &ptep) == NULL);
f0101aa0:	83 ec 04             	sub    $0x4,%esp
f0101aa3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101aa6:	50                   	push   %eax
f0101aa7:	6a 00                	push   $0x0
f0101aa9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101aac:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0101ab2:	ff 30                	pushl  (%eax)
f0101ab4:	e8 cb f7 ff ff       	call   f0101284 <page_lookup>
f0101ab9:	83 c4 10             	add    $0x10,%esp
f0101abc:	85 c0                	test   %eax,%eax
f0101abe:	0f 85 80 08 00 00    	jne    f0102344 <mem_init+0xf93>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101ac4:	6a 02                	push   $0x2
f0101ac6:	6a 00                	push   $0x0
f0101ac8:	57                   	push   %edi
f0101ac9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101acc:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0101ad2:	ff 30                	pushl  (%eax)
f0101ad4:	e8 56 f8 ff ff       	call   f010132f <page_insert>
f0101ad9:	83 c4 10             	add    $0x10,%esp
f0101adc:	85 c0                	test   %eax,%eax
f0101ade:	0f 89 82 08 00 00    	jns    f0102366 <mem_init+0xfb5>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101ae4:	83 ec 0c             	sub    $0xc,%esp
f0101ae7:	ff 75 d0             	pushl  -0x30(%ebp)
f0101aea:	e8 da f5 ff ff       	call   f01010c9 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101aef:	6a 02                	push   $0x2
f0101af1:	6a 00                	push   $0x0
f0101af3:	57                   	push   %edi
f0101af4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101af7:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0101afd:	ff 30                	pushl  (%eax)
f0101aff:	e8 2b f8 ff ff       	call   f010132f <page_insert>
f0101b04:	83 c4 20             	add    $0x20,%esp
f0101b07:	85 c0                	test   %eax,%eax
f0101b09:	0f 85 79 08 00 00    	jne    f0102388 <mem_init+0xfd7>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b0f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101b12:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0101b18:	8b 18                	mov    (%eax),%ebx
	return (pp - pages) << PGSHIFT;
f0101b1a:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101b20:	8b 08                	mov    (%eax),%ecx
f0101b22:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0101b25:	8b 13                	mov    (%ebx),%edx
f0101b27:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b2d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b30:	29 c8                	sub    %ecx,%eax
f0101b32:	c1 f8 03             	sar    $0x3,%eax
f0101b35:	c1 e0 0c             	shl    $0xc,%eax
f0101b38:	39 c2                	cmp    %eax,%edx
f0101b3a:	0f 85 6a 08 00 00    	jne    f01023aa <mem_init+0xff9>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b40:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b45:	89 d8                	mov    %ebx,%eax
f0101b47:	e8 f1 ef ff ff       	call   f0100b3d <check_va2pa>
f0101b4c:	89 fa                	mov    %edi,%edx
f0101b4e:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101b51:	c1 fa 03             	sar    $0x3,%edx
f0101b54:	c1 e2 0c             	shl    $0xc,%edx
f0101b57:	39 d0                	cmp    %edx,%eax
f0101b59:	0f 85 6d 08 00 00    	jne    f01023cc <mem_init+0x101b>
	assert(pp1->pp_ref == 1);
f0101b5f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101b64:	0f 85 84 08 00 00    	jne    f01023ee <mem_init+0x103d>
	assert(pp0->pp_ref == 1);
f0101b6a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b6d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b72:	0f 85 98 08 00 00    	jne    f0102410 <mem_init+0x105f>
	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101b78:	6a 02                	push   $0x2
f0101b7a:	68 00 10 00 00       	push   $0x1000
f0101b7f:	56                   	push   %esi
f0101b80:	53                   	push   %ebx
f0101b81:	e8 a9 f7 ff ff       	call   f010132f <page_insert>
f0101b86:	83 c4 10             	add    $0x10,%esp
f0101b89:	85 c0                	test   %eax,%eax
f0101b8b:	0f 85 a1 08 00 00    	jne    f0102432 <mem_init+0x1081>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b91:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b96:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101b99:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0101b9f:	8b 00                	mov    (%eax),%eax
f0101ba1:	e8 97 ef ff ff       	call   f0100b3d <check_va2pa>
f0101ba6:	c7 c2 0c e0 18 f0    	mov    $0xf018e00c,%edx
f0101bac:	89 f1                	mov    %esi,%ecx
f0101bae:	2b 0a                	sub    (%edx),%ecx
f0101bb0:	89 ca                	mov    %ecx,%edx
f0101bb2:	c1 fa 03             	sar    $0x3,%edx
f0101bb5:	c1 e2 0c             	shl    $0xc,%edx
f0101bb8:	39 d0                	cmp    %edx,%eax
f0101bba:	0f 85 94 08 00 00    	jne    f0102454 <mem_init+0x10a3>
	assert(pp2->pp_ref == 1);
f0101bc0:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101bc5:	0f 85 ab 08 00 00    	jne    f0102476 <mem_init+0x10c5>

	// should be no free memory
	assert(!page_alloc(0));
f0101bcb:	83 ec 0c             	sub    $0xc,%esp
f0101bce:	6a 00                	push   $0x0
f0101bd0:	e8 66 f4 ff ff       	call   f010103b <page_alloc>
f0101bd5:	83 c4 10             	add    $0x10,%esp
f0101bd8:	85 c0                	test   %eax,%eax
f0101bda:	0f 85 b8 08 00 00    	jne    f0102498 <mem_init+0x10e7>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101be0:	6a 02                	push   $0x2
f0101be2:	68 00 10 00 00       	push   $0x1000
f0101be7:	56                   	push   %esi
f0101be8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101beb:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0101bf1:	ff 30                	pushl  (%eax)
f0101bf3:	e8 37 f7 ff ff       	call   f010132f <page_insert>
f0101bf8:	83 c4 10             	add    $0x10,%esp
f0101bfb:	85 c0                	test   %eax,%eax
f0101bfd:	0f 85 b7 08 00 00    	jne    f01024ba <mem_init+0x1109>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c03:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c08:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101c0b:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0101c11:	8b 00                	mov    (%eax),%eax
f0101c13:	e8 25 ef ff ff       	call   f0100b3d <check_va2pa>
f0101c18:	c7 c2 0c e0 18 f0    	mov    $0xf018e00c,%edx
f0101c1e:	89 f1                	mov    %esi,%ecx
f0101c20:	2b 0a                	sub    (%edx),%ecx
f0101c22:	89 ca                	mov    %ecx,%edx
f0101c24:	c1 fa 03             	sar    $0x3,%edx
f0101c27:	c1 e2 0c             	shl    $0xc,%edx
f0101c2a:	39 d0                	cmp    %edx,%eax
f0101c2c:	0f 85 aa 08 00 00    	jne    f01024dc <mem_init+0x112b>
	assert(pp2->pp_ref == 1);
f0101c32:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c37:	0f 85 c1 08 00 00    	jne    f01024fe <mem_init+0x114d>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c3d:	83 ec 0c             	sub    $0xc,%esp
f0101c40:	6a 00                	push   $0x0
f0101c42:	e8 f4 f3 ff ff       	call   f010103b <page_alloc>
f0101c47:	83 c4 10             	add    $0x10,%esp
f0101c4a:	85 c0                	test   %eax,%eax
f0101c4c:	0f 85 ce 08 00 00    	jne    f0102520 <mem_init+0x116f>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c52:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101c55:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0101c5b:	8b 10                	mov    (%eax),%edx
f0101c5d:	8b 02                	mov    (%edx),%eax
f0101c5f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101c64:	89 c3                	mov    %eax,%ebx
f0101c66:	c1 eb 0c             	shr    $0xc,%ebx
f0101c69:	c7 c1 04 e0 18 f0    	mov    $0xf018e004,%ecx
f0101c6f:	3b 19                	cmp    (%ecx),%ebx
f0101c71:	0f 83 cb 08 00 00    	jae    f0102542 <mem_init+0x1191>
	return (void *)(pa + KERNBASE);
f0101c77:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c7c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
f0101c7f:	83 ec 04             	sub    $0x4,%esp
f0101c82:	6a 00                	push   $0x0
f0101c84:	68 00 10 00 00       	push   $0x1000
f0101c89:	52                   	push   %edx
f0101c8a:	e8 b2 f4 ff ff       	call   f0101141 <pgdir_walk>
f0101c8f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101c92:	8d 51 04             	lea    0x4(%ecx),%edx
f0101c95:	83 c4 10             	add    $0x10,%esp
f0101c98:	39 d0                	cmp    %edx,%eax
f0101c9a:	0f 85 be 08 00 00    	jne    f010255e <mem_init+0x11ad>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W | PTE_U) == 0);
f0101ca0:	6a 06                	push   $0x6
f0101ca2:	68 00 10 00 00       	push   $0x1000
f0101ca7:	56                   	push   %esi
f0101ca8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cab:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0101cb1:	ff 30                	pushl  (%eax)
f0101cb3:	e8 77 f6 ff ff       	call   f010132f <page_insert>
f0101cb8:	83 c4 10             	add    $0x10,%esp
f0101cbb:	85 c0                	test   %eax,%eax
f0101cbd:	0f 85 bd 08 00 00    	jne    f0102580 <mem_init+0x11cf>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101cc3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cc6:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0101ccc:	8b 18                	mov    (%eax),%ebx
f0101cce:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cd3:	89 d8                	mov    %ebx,%eax
f0101cd5:	e8 63 ee ff ff       	call   f0100b3d <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101cda:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101cdd:	c7 c2 0c e0 18 f0    	mov    $0xf018e00c,%edx
f0101ce3:	89 f1                	mov    %esi,%ecx
f0101ce5:	2b 0a                	sub    (%edx),%ecx
f0101ce7:	89 ca                	mov    %ecx,%edx
f0101ce9:	c1 fa 03             	sar    $0x3,%edx
f0101cec:	c1 e2 0c             	shl    $0xc,%edx
f0101cef:	39 d0                	cmp    %edx,%eax
f0101cf1:	0f 85 ab 08 00 00    	jne    f01025a2 <mem_init+0x11f1>
	assert(pp2->pp_ref == 1);
f0101cf7:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101cfc:	0f 85 c2 08 00 00    	jne    f01025c4 <mem_init+0x1213>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U);
f0101d02:	83 ec 04             	sub    $0x4,%esp
f0101d05:	6a 00                	push   $0x0
f0101d07:	68 00 10 00 00       	push   $0x1000
f0101d0c:	53                   	push   %ebx
f0101d0d:	e8 2f f4 ff ff       	call   f0101141 <pgdir_walk>
f0101d12:	83 c4 10             	add    $0x10,%esp
f0101d15:	f6 00 04             	testb  $0x4,(%eax)
f0101d18:	0f 84 c8 08 00 00    	je     f01025e6 <mem_init+0x1235>
	assert(kern_pgdir[0] & PTE_U);
f0101d1e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d21:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0101d27:	8b 00                	mov    (%eax),%eax
f0101d29:	f6 00 04             	testb  $0x4,(%eax)
f0101d2c:	0f 84 d6 08 00 00    	je     f0102608 <mem_init+0x1257>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101d32:	6a 02                	push   $0x2
f0101d34:	68 00 10 00 00       	push   $0x1000
f0101d39:	56                   	push   %esi
f0101d3a:	50                   	push   %eax
f0101d3b:	e8 ef f5 ff ff       	call   f010132f <page_insert>
f0101d40:	83 c4 10             	add    $0x10,%esp
f0101d43:	85 c0                	test   %eax,%eax
f0101d45:	0f 85 df 08 00 00    	jne    f010262a <mem_init+0x1279>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_W);
f0101d4b:	83 ec 04             	sub    $0x4,%esp
f0101d4e:	6a 00                	push   $0x0
f0101d50:	68 00 10 00 00       	push   $0x1000
f0101d55:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d58:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0101d5e:	ff 30                	pushl  (%eax)
f0101d60:	e8 dc f3 ff ff       	call   f0101141 <pgdir_walk>
f0101d65:	83 c4 10             	add    $0x10,%esp
f0101d68:	f6 00 02             	testb  $0x2,(%eax)
f0101d6b:	0f 84 db 08 00 00    	je     f010264c <mem_init+0x129b>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0101d71:	83 ec 04             	sub    $0x4,%esp
f0101d74:	6a 00                	push   $0x0
f0101d76:	68 00 10 00 00       	push   $0x1000
f0101d7b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d7e:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0101d84:	ff 30                	pushl  (%eax)
f0101d86:	e8 b6 f3 ff ff       	call   f0101141 <pgdir_walk>
f0101d8b:	83 c4 10             	add    $0x10,%esp
f0101d8e:	f6 00 04             	testb  $0x4,(%eax)
f0101d91:	0f 85 d7 08 00 00    	jne    f010266e <mem_init+0x12bd>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void *)PTSIZE, PTE_W) < 0);
f0101d97:	6a 02                	push   $0x2
f0101d99:	68 00 00 40 00       	push   $0x400000
f0101d9e:	ff 75 d0             	pushl  -0x30(%ebp)
f0101da1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101da4:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0101daa:	ff 30                	pushl  (%eax)
f0101dac:	e8 7e f5 ff ff       	call   f010132f <page_insert>
f0101db1:	83 c4 10             	add    $0x10,%esp
f0101db4:	85 c0                	test   %eax,%eax
f0101db6:	0f 89 d4 08 00 00    	jns    f0102690 <mem_init+0x12df>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W) == 0);
f0101dbc:	6a 02                	push   $0x2
f0101dbe:	68 00 10 00 00       	push   $0x1000
f0101dc3:	57                   	push   %edi
f0101dc4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dc7:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0101dcd:	ff 30                	pushl  (%eax)
f0101dcf:	e8 5b f5 ff ff       	call   f010132f <page_insert>
f0101dd4:	83 c4 10             	add    $0x10,%esp
f0101dd7:	85 c0                	test   %eax,%eax
f0101dd9:	0f 85 d3 08 00 00    	jne    f01026b2 <mem_init+0x1301>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0101ddf:	83 ec 04             	sub    $0x4,%esp
f0101de2:	6a 00                	push   $0x0
f0101de4:	68 00 10 00 00       	push   $0x1000
f0101de9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dec:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0101df2:	ff 30                	pushl  (%eax)
f0101df4:	e8 48 f3 ff ff       	call   f0101141 <pgdir_walk>
f0101df9:	83 c4 10             	add    $0x10,%esp
f0101dfc:	f6 00 04             	testb  $0x4,(%eax)
f0101dff:	0f 85 cf 08 00 00    	jne    f01026d4 <mem_init+0x1323>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e05:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e08:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0101e0e:	8b 18                	mov    (%eax),%ebx
f0101e10:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e15:	89 d8                	mov    %ebx,%eax
f0101e17:	e8 21 ed ff ff       	call   f0100b3d <check_va2pa>
f0101e1c:	89 c2                	mov    %eax,%edx
f0101e1e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e21:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e24:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101e2a:	89 f9                	mov    %edi,%ecx
f0101e2c:	2b 08                	sub    (%eax),%ecx
f0101e2e:	89 c8                	mov    %ecx,%eax
f0101e30:	c1 f8 03             	sar    $0x3,%eax
f0101e33:	c1 e0 0c             	shl    $0xc,%eax
f0101e36:	39 c2                	cmp    %eax,%edx
f0101e38:	0f 85 b8 08 00 00    	jne    f01026f6 <mem_init+0x1345>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e3e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e43:	89 d8                	mov    %ebx,%eax
f0101e45:	e8 f3 ec ff ff       	call   f0100b3d <check_va2pa>
f0101e4a:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101e4d:	0f 85 c5 08 00 00    	jne    f0102718 <mem_init+0x1367>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101e53:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101e58:	0f 85 dc 08 00 00    	jne    f010273a <mem_init+0x1389>
	assert(pp2->pp_ref == 0);
f0101e5e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e63:	0f 85 f3 08 00 00    	jne    f010275c <mem_init+0x13ab>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101e69:	83 ec 0c             	sub    $0xc,%esp
f0101e6c:	6a 00                	push   $0x0
f0101e6e:	e8 c8 f1 ff ff       	call   f010103b <page_alloc>
f0101e73:	83 c4 10             	add    $0x10,%esp
f0101e76:	39 c6                	cmp    %eax,%esi
f0101e78:	0f 85 00 09 00 00    	jne    f010277e <mem_init+0x13cd>
f0101e7e:	85 c0                	test   %eax,%eax
f0101e80:	0f 84 f8 08 00 00    	je     f010277e <mem_init+0x13cd>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101e86:	83 ec 08             	sub    $0x8,%esp
f0101e89:	6a 00                	push   $0x0
f0101e8b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e8e:	c7 c3 08 e0 18 f0    	mov    $0xf018e008,%ebx
f0101e94:	ff 33                	pushl  (%ebx)
f0101e96:	e8 59 f4 ff ff       	call   f01012f4 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e9b:	8b 1b                	mov    (%ebx),%ebx
f0101e9d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101ea2:	89 d8                	mov    %ebx,%eax
f0101ea4:	e8 94 ec ff ff       	call   f0100b3d <check_va2pa>
f0101ea9:	83 c4 10             	add    $0x10,%esp
f0101eac:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101eaf:	0f 85 eb 08 00 00    	jne    f01027a0 <mem_init+0x13ef>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101eb5:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101eba:	89 d8                	mov    %ebx,%eax
f0101ebc:	e8 7c ec ff ff       	call   f0100b3d <check_va2pa>
f0101ec1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101ec4:	c7 c2 0c e0 18 f0    	mov    $0xf018e00c,%edx
f0101eca:	89 f9                	mov    %edi,%ecx
f0101ecc:	2b 0a                	sub    (%edx),%ecx
f0101ece:	89 ca                	mov    %ecx,%edx
f0101ed0:	c1 fa 03             	sar    $0x3,%edx
f0101ed3:	c1 e2 0c             	shl    $0xc,%edx
f0101ed6:	39 d0                	cmp    %edx,%eax
f0101ed8:	0f 85 e4 08 00 00    	jne    f01027c2 <mem_init+0x1411>
	assert(pp1->pp_ref == 1);
f0101ede:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ee3:	0f 85 fb 08 00 00    	jne    f01027e4 <mem_init+0x1433>
	assert(pp2->pp_ref == 0);
f0101ee9:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101eee:	0f 85 12 09 00 00    	jne    f0102806 <mem_init+0x1455>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, 0) == 0);
f0101ef4:	6a 00                	push   $0x0
f0101ef6:	68 00 10 00 00       	push   $0x1000
f0101efb:	57                   	push   %edi
f0101efc:	53                   	push   %ebx
f0101efd:	e8 2d f4 ff ff       	call   f010132f <page_insert>
f0101f02:	83 c4 10             	add    $0x10,%esp
f0101f05:	85 c0                	test   %eax,%eax
f0101f07:	0f 85 1b 09 00 00    	jne    f0102828 <mem_init+0x1477>
	assert(pp1->pp_ref);
f0101f0d:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101f12:	0f 84 32 09 00 00    	je     f010284a <mem_init+0x1499>
	assert(pp1->pp_link == NULL);
f0101f18:	83 3f 00             	cmpl   $0x0,(%edi)
f0101f1b:	0f 85 4b 09 00 00    	jne    f010286c <mem_init+0x14bb>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void *)PGSIZE);
f0101f21:	83 ec 08             	sub    $0x8,%esp
f0101f24:	68 00 10 00 00       	push   $0x1000
f0101f29:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f2c:	c7 c3 08 e0 18 f0    	mov    $0xf018e008,%ebx
f0101f32:	ff 33                	pushl  (%ebx)
f0101f34:	e8 bb f3 ff ff       	call   f01012f4 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f39:	8b 1b                	mov    (%ebx),%ebx
f0101f3b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f40:	89 d8                	mov    %ebx,%eax
f0101f42:	e8 f6 eb ff ff       	call   f0100b3d <check_va2pa>
f0101f47:	83 c4 10             	add    $0x10,%esp
f0101f4a:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f4d:	0f 85 3b 09 00 00    	jne    f010288e <mem_init+0x14dd>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101f53:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f58:	89 d8                	mov    %ebx,%eax
f0101f5a:	e8 de eb ff ff       	call   f0100b3d <check_va2pa>
f0101f5f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f62:	0f 85 48 09 00 00    	jne    f01028b0 <mem_init+0x14ff>
	assert(pp1->pp_ref == 0);
f0101f68:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101f6d:	0f 85 5f 09 00 00    	jne    f01028d2 <mem_init+0x1521>
	assert(pp2->pp_ref == 0);
f0101f73:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f78:	0f 85 76 09 00 00    	jne    f01028f4 <mem_init+0x1543>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101f7e:	83 ec 0c             	sub    $0xc,%esp
f0101f81:	6a 00                	push   $0x0
f0101f83:	e8 b3 f0 ff ff       	call   f010103b <page_alloc>
f0101f88:	83 c4 10             	add    $0x10,%esp
f0101f8b:	85 c0                	test   %eax,%eax
f0101f8d:	0f 84 83 09 00 00    	je     f0102916 <mem_init+0x1565>
f0101f93:	39 c7                	cmp    %eax,%edi
f0101f95:	0f 85 7b 09 00 00    	jne    f0102916 <mem_init+0x1565>

	// should be no free memory
	assert(!page_alloc(0));
f0101f9b:	83 ec 0c             	sub    $0xc,%esp
f0101f9e:	6a 00                	push   $0x0
f0101fa0:	e8 96 f0 ff ff       	call   f010103b <page_alloc>
f0101fa5:	83 c4 10             	add    $0x10,%esp
f0101fa8:	85 c0                	test   %eax,%eax
f0101faa:	0f 85 88 09 00 00    	jne    f0102938 <mem_init+0x1587>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101fb0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fb3:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0101fb9:	8b 08                	mov    (%eax),%ecx
f0101fbb:	8b 11                	mov    (%ecx),%edx
f0101fbd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101fc3:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0101fc9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0101fcc:	2b 18                	sub    (%eax),%ebx
f0101fce:	89 d8                	mov    %ebx,%eax
f0101fd0:	c1 f8 03             	sar    $0x3,%eax
f0101fd3:	c1 e0 0c             	shl    $0xc,%eax
f0101fd6:	39 c2                	cmp    %eax,%edx
f0101fd8:	0f 85 7c 09 00 00    	jne    f010295a <mem_init+0x15a9>
	kern_pgdir[0] = 0;
f0101fde:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101fe4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101fe7:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101fec:	0f 85 8a 09 00 00    	jne    f010297c <mem_init+0x15cb>
	pp0->pp_ref = 0;
f0101ff2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101ff5:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101ffb:	83 ec 0c             	sub    $0xc,%esp
f0101ffe:	50                   	push   %eax
f0101fff:	e8 c5 f0 ff ff       	call   f01010c9 <page_free>
	va = (void *)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102004:	83 c4 0c             	add    $0xc,%esp
f0102007:	6a 01                	push   $0x1
f0102009:	68 00 10 40 00       	push   $0x401000
f010200e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102011:	c7 c3 08 e0 18 f0    	mov    $0xf018e008,%ebx
f0102017:	ff 33                	pushl  (%ebx)
f0102019:	e8 23 f1 ff ff       	call   f0101141 <pgdir_walk>
f010201e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102021:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102024:	8b 1b                	mov    (%ebx),%ebx
f0102026:	8b 53 04             	mov    0x4(%ebx),%edx
f0102029:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f010202f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102032:	c7 c1 04 e0 18 f0    	mov    $0xf018e004,%ecx
f0102038:	8b 09                	mov    (%ecx),%ecx
f010203a:	89 d0                	mov    %edx,%eax
f010203c:	c1 e8 0c             	shr    $0xc,%eax
f010203f:	83 c4 10             	add    $0x10,%esp
f0102042:	39 c8                	cmp    %ecx,%eax
f0102044:	0f 83 54 09 00 00    	jae    f010299e <mem_init+0x15ed>
	assert(ptep == ptep1 + PTX(va));
f010204a:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102050:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0102053:	0f 85 61 09 00 00    	jne    f01029ba <mem_init+0x1609>
	kern_pgdir[PDX(va)] = 0;
f0102059:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f0102060:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102063:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	return (pp - pages) << PGSHIFT;
f0102069:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010206c:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0102072:	2b 18                	sub    (%eax),%ebx
f0102074:	89 d8                	mov    %ebx,%eax
f0102076:	c1 f8 03             	sar    $0x3,%eax
f0102079:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010207c:	89 c2                	mov    %eax,%edx
f010207e:	c1 ea 0c             	shr    $0xc,%edx
f0102081:	39 d1                	cmp    %edx,%ecx
f0102083:	0f 86 53 09 00 00    	jbe    f01029dc <mem_init+0x162b>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102089:	83 ec 04             	sub    $0x4,%esp
f010208c:	68 00 10 00 00       	push   $0x1000
f0102091:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0102096:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010209b:	50                   	push   %eax
f010209c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010209f:	e8 97 26 00 00       	call   f010473b <memset>
	page_free(pp0);
f01020a4:	83 c4 04             	add    $0x4,%esp
f01020a7:	ff 75 d0             	pushl  -0x30(%ebp)
f01020aa:	e8 1a f0 ff ff       	call   f01010c9 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01020af:	83 c4 0c             	add    $0xc,%esp
f01020b2:	6a 01                	push   $0x1
f01020b4:	6a 00                	push   $0x0
f01020b6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020b9:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f01020bf:	ff 30                	pushl  (%eax)
f01020c1:	e8 7b f0 ff ff       	call   f0101141 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f01020c6:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f01020cc:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01020cf:	2b 10                	sub    (%eax),%edx
f01020d1:	c1 fa 03             	sar    $0x3,%edx
f01020d4:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01020d7:	89 d1                	mov    %edx,%ecx
f01020d9:	c1 e9 0c             	shr    $0xc,%ecx
f01020dc:	83 c4 10             	add    $0x10,%esp
f01020df:	c7 c0 04 e0 18 f0    	mov    $0xf018e004,%eax
f01020e5:	3b 08                	cmp    (%eax),%ecx
f01020e7:	0f 83 08 09 00 00    	jae    f01029f5 <mem_init+0x1644>
	return (void *)(pa + KERNBASE);
f01020ed:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *)page2kva(pp0);
f01020f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01020f6:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for (i = 0; i < NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01020fc:	f6 00 01             	testb  $0x1,(%eax)
f01020ff:	0f 85 09 09 00 00    	jne    f0102a0e <mem_init+0x165d>
f0102105:	83 c0 04             	add    $0x4,%eax
	for (i = 0; i < NPTENTRIES; i++)
f0102108:	39 d0                	cmp    %edx,%eax
f010210a:	75 f0                	jne    f01020fc <mem_init+0xd4b>
	kern_pgdir[0] = 0;
f010210c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010210f:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0102115:	8b 00                	mov    (%eax),%eax
f0102117:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010211d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102120:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102126:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102129:	89 93 1c 23 00 00    	mov    %edx,0x231c(%ebx)

	// free the pages we took
	page_free(pp0);
f010212f:	83 ec 0c             	sub    $0xc,%esp
f0102132:	50                   	push   %eax
f0102133:	e8 91 ef ff ff       	call   f01010c9 <page_free>
	page_free(pp1);
f0102138:	89 3c 24             	mov    %edi,(%esp)
f010213b:	e8 89 ef ff ff       	call   f01010c9 <page_free>
	page_free(pp2);
f0102140:	89 34 24             	mov    %esi,(%esp)
f0102143:	e8 81 ef ff ff       	call   f01010c9 <page_free>

	cprintf("check_page() succeeded!\n");
f0102148:	8d 83 b8 aa f7 ff    	lea    -0x85548(%ebx),%eax
f010214e:	89 04 24             	mov    %eax,(%esp)
f0102151:	e8 33 15 00 00       	call   f0103689 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0102156:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f010215c:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010215e:	83 c4 10             	add    $0x10,%esp
f0102161:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102166:	0f 86 c4 08 00 00    	jbe    f0102a30 <mem_init+0x167f>
f010216c:	83 ec 08             	sub    $0x8,%esp
f010216f:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102171:	05 00 00 00 10       	add    $0x10000000,%eax
f0102176:	50                   	push   %eax
f0102177:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010217c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102181:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102184:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f010218a:	8b 00                	mov    (%eax),%eax
f010218c:	e8 a1 f0 ff ff       	call   f0101232 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102191:	c7 c0 00 10 11 f0    	mov    $0xf0111000,%eax
f0102197:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010219a:	83 c4 10             	add    $0x10,%esp
f010219d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021a2:	0f 86 a4 08 00 00    	jbe    f0102a4c <mem_init+0x169b>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01021a8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01021ab:	c7 c3 08 e0 18 f0    	mov    $0xf018e008,%ebx
f01021b1:	83 ec 08             	sub    $0x8,%esp
f01021b4:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f01021b6:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01021b9:	05 00 00 00 10       	add    $0x10000000,%eax
f01021be:	50                   	push   %eax
f01021bf:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01021c4:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01021c9:	8b 03                	mov    (%ebx),%eax
f01021cb:	e8 62 f0 ff ff       	call   f0101232 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0x100000000 - KERNBASE, 0, PTE_U);
f01021d0:	83 c4 08             	add    $0x8,%esp
f01021d3:	6a 04                	push   $0x4
f01021d5:	6a 00                	push   $0x0
f01021d7:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01021dc:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01021e1:	8b 03                	mov    (%ebx),%eax
f01021e3:	e8 4a f0 ff ff       	call   f0101232 <boot_map_region>
	pgdir = kern_pgdir;
f01021e8:	8b 33                	mov    (%ebx),%esi
	n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
f01021ea:	c7 c0 04 e0 18 f0    	mov    $0xf018e004,%eax
f01021f0:	8b 00                	mov    (%eax),%eax
f01021f2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01021f5:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01021fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102201:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102204:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f010220a:	8b 00                	mov    (%eax),%eax
f010220c:	89 45 c0             	mov    %eax,-0x40(%ebp)
	if ((uint32_t)kva < KERNBASE)
f010220f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102212:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0102218:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE)
f010221b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102220:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0102223:	0f 86 84 08 00 00    	jbe    f0102aad <mem_init+0x16fc>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102229:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010222f:	89 f0                	mov    %esi,%eax
f0102231:	e8 07 e9 ff ff       	call   f0100b3d <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102236:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f010223d:	0f 86 2a 08 00 00    	jbe    f0102a6d <mem_init+0x16bc>
f0102243:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0102246:	39 d0                	cmp    %edx,%eax
f0102248:	0f 85 3d 08 00 00    	jne    f0102a8b <mem_init+0x16da>
	for (i = 0; i < n; i += PGSIZE)
f010224e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102254:	eb ca                	jmp    f0102220 <mem_init+0xe6f>
	assert(nfree == 0);
f0102256:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102259:	8d 83 e1 a9 f7 ff    	lea    -0x8561f(%ebx),%eax
f010225f:	50                   	push   %eax
f0102260:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102266:	50                   	push   %eax
f0102267:	68 57 02 00 00       	push   $0x257
f010226c:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102272:	50                   	push   %eax
f0102273:	e8 39 de ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0102278:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010227b:	8d 83 46 a9 f7 ff    	lea    -0x856ba(%ebx),%eax
f0102281:	50                   	push   %eax
f0102282:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102288:	50                   	push   %eax
f0102289:	68 b6 02 00 00       	push   $0x2b6
f010228e:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102294:	50                   	push   %eax
f0102295:	e8 17 de ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f010229a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010229d:	8d 83 5c a9 f7 ff    	lea    -0x856a4(%ebx),%eax
f01022a3:	50                   	push   %eax
f01022a4:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01022aa:	50                   	push   %eax
f01022ab:	68 b7 02 00 00       	push   $0x2b7
f01022b0:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01022b6:	50                   	push   %eax
f01022b7:	e8 f5 dd ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f01022bc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022bf:	8d 83 72 a9 f7 ff    	lea    -0x8568e(%ebx),%eax
f01022c5:	50                   	push   %eax
f01022c6:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01022cc:	50                   	push   %eax
f01022cd:	68 b8 02 00 00       	push   $0x2b8
f01022d2:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01022d8:	50                   	push   %eax
f01022d9:	e8 d3 dd ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f01022de:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022e1:	8d 83 88 a9 f7 ff    	lea    -0x85678(%ebx),%eax
f01022e7:	50                   	push   %eax
f01022e8:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01022ee:	50                   	push   %eax
f01022ef:	68 bb 02 00 00       	push   $0x2bb
f01022f4:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01022fa:	50                   	push   %eax
f01022fb:	e8 b1 dd ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102300:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102303:	8d 83 f8 a1 f7 ff    	lea    -0x85e08(%ebx),%eax
f0102309:	50                   	push   %eax
f010230a:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102310:	50                   	push   %eax
f0102311:	68 bc 02 00 00       	push   $0x2bc
f0102316:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f010231c:	50                   	push   %eax
f010231d:	e8 8f dd ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102322:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102325:	8d 83 9a a9 f7 ff    	lea    -0x85666(%ebx),%eax
f010232b:	50                   	push   %eax
f010232c:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102332:	50                   	push   %eax
f0102333:	68 c3 02 00 00       	push   $0x2c3
f0102338:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f010233e:	50                   	push   %eax
f010233f:	e8 6d dd ff ff       	call   f01000b1 <_panic>
	assert(page_lookup(kern_pgdir, (void *)0x0, &ptep) == NULL);
f0102344:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102347:	8d 83 98 a2 f7 ff    	lea    -0x85d68(%ebx),%eax
f010234d:	50                   	push   %eax
f010234e:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102354:	50                   	push   %eax
f0102355:	68 c6 02 00 00       	push   $0x2c6
f010235a:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102360:	50                   	push   %eax
f0102361:	e8 4b dd ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102366:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102369:	8d 83 cc a2 f7 ff    	lea    -0x85d34(%ebx),%eax
f010236f:	50                   	push   %eax
f0102370:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102376:	50                   	push   %eax
f0102377:	68 c9 02 00 00       	push   $0x2c9
f010237c:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102382:	50                   	push   %eax
f0102383:	e8 29 dd ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102388:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010238b:	8d 83 fc a2 f7 ff    	lea    -0x85d04(%ebx),%eax
f0102391:	50                   	push   %eax
f0102392:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102398:	50                   	push   %eax
f0102399:	68 cd 02 00 00       	push   $0x2cd
f010239e:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01023a4:	50                   	push   %eax
f01023a5:	e8 07 dd ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023aa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023ad:	8d 83 2c a3 f7 ff    	lea    -0x85cd4(%ebx),%eax
f01023b3:	50                   	push   %eax
f01023b4:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01023ba:	50                   	push   %eax
f01023bb:	68 ce 02 00 00       	push   $0x2ce
f01023c0:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01023c6:	50                   	push   %eax
f01023c7:	e8 e5 dc ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01023cc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023cf:	8d 83 54 a3 f7 ff    	lea    -0x85cac(%ebx),%eax
f01023d5:	50                   	push   %eax
f01023d6:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01023dc:	50                   	push   %eax
f01023dd:	68 cf 02 00 00       	push   $0x2cf
f01023e2:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01023e8:	50                   	push   %eax
f01023e9:	e8 c3 dc ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f01023ee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023f1:	8d 83 ec a9 f7 ff    	lea    -0x85614(%ebx),%eax
f01023f7:	50                   	push   %eax
f01023f8:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01023fe:	50                   	push   %eax
f01023ff:	68 d0 02 00 00       	push   $0x2d0
f0102404:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f010240a:	50                   	push   %eax
f010240b:	e8 a1 dc ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f0102410:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102413:	8d 83 fd a9 f7 ff    	lea    -0x85603(%ebx),%eax
f0102419:	50                   	push   %eax
f010241a:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102420:	50                   	push   %eax
f0102421:	68 d1 02 00 00       	push   $0x2d1
f0102426:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f010242c:	50                   	push   %eax
f010242d:	e8 7f dc ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0102432:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102435:	8d 83 84 a3 f7 ff    	lea    -0x85c7c(%ebx),%eax
f010243b:	50                   	push   %eax
f010243c:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102442:	50                   	push   %eax
f0102443:	68 d3 02 00 00       	push   $0x2d3
f0102448:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f010244e:	50                   	push   %eax
f010244f:	e8 5d dc ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102454:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102457:	8d 83 c0 a3 f7 ff    	lea    -0x85c40(%ebx),%eax
f010245d:	50                   	push   %eax
f010245e:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102464:	50                   	push   %eax
f0102465:	68 d4 02 00 00       	push   $0x2d4
f010246a:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102470:	50                   	push   %eax
f0102471:	e8 3b dc ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102476:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102479:	8d 83 0e aa f7 ff    	lea    -0x855f2(%ebx),%eax
f010247f:	50                   	push   %eax
f0102480:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102486:	50                   	push   %eax
f0102487:	68 d5 02 00 00       	push   $0x2d5
f010248c:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102492:	50                   	push   %eax
f0102493:	e8 19 dc ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102498:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010249b:	8d 83 9a a9 f7 ff    	lea    -0x85666(%ebx),%eax
f01024a1:	50                   	push   %eax
f01024a2:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01024a8:	50                   	push   %eax
f01024a9:	68 d8 02 00 00       	push   $0x2d8
f01024ae:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01024b4:	50                   	push   %eax
f01024b5:	e8 f7 db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f01024ba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024bd:	8d 83 84 a3 f7 ff    	lea    -0x85c7c(%ebx),%eax
f01024c3:	50                   	push   %eax
f01024c4:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01024ca:	50                   	push   %eax
f01024cb:	68 db 02 00 00       	push   $0x2db
f01024d0:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01024d6:	50                   	push   %eax
f01024d7:	e8 d5 db ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024dc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024df:	8d 83 c0 a3 f7 ff    	lea    -0x85c40(%ebx),%eax
f01024e5:	50                   	push   %eax
f01024e6:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01024ec:	50                   	push   %eax
f01024ed:	68 dc 02 00 00       	push   $0x2dc
f01024f2:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01024f8:	50                   	push   %eax
f01024f9:	e8 b3 db ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f01024fe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102501:	8d 83 0e aa f7 ff    	lea    -0x855f2(%ebx),%eax
f0102507:	50                   	push   %eax
f0102508:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f010250e:	50                   	push   %eax
f010250f:	68 dd 02 00 00       	push   $0x2dd
f0102514:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f010251a:	50                   	push   %eax
f010251b:	e8 91 db ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102520:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102523:	8d 83 9a a9 f7 ff    	lea    -0x85666(%ebx),%eax
f0102529:	50                   	push   %eax
f010252a:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102530:	50                   	push   %eax
f0102531:	68 e1 02 00 00       	push   $0x2e1
f0102536:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f010253c:	50                   	push   %eax
f010253d:	e8 6f db ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102542:	50                   	push   %eax
f0102543:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102546:	8d 83 30 a0 f7 ff    	lea    -0x85fd0(%ebx),%eax
f010254c:	50                   	push   %eax
f010254d:	68 e4 02 00 00       	push   $0x2e4
f0102552:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102558:	50                   	push   %eax
f0102559:	e8 53 db ff ff       	call   f01000b1 <_panic>
	assert(pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
f010255e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102561:	8d 83 f0 a3 f7 ff    	lea    -0x85c10(%ebx),%eax
f0102567:	50                   	push   %eax
f0102568:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f010256e:	50                   	push   %eax
f010256f:	68 e5 02 00 00       	push   $0x2e5
f0102574:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f010257a:	50                   	push   %eax
f010257b:	e8 31 db ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W | PTE_U) == 0);
f0102580:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102583:	8d 83 30 a4 f7 ff    	lea    -0x85bd0(%ebx),%eax
f0102589:	50                   	push   %eax
f010258a:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102590:	50                   	push   %eax
f0102591:	68 e8 02 00 00       	push   $0x2e8
f0102596:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f010259c:	50                   	push   %eax
f010259d:	e8 0f db ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01025a2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025a5:	8d 83 c0 a3 f7 ff    	lea    -0x85c40(%ebx),%eax
f01025ab:	50                   	push   %eax
f01025ac:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01025b2:	50                   	push   %eax
f01025b3:	68 e9 02 00 00       	push   $0x2e9
f01025b8:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01025be:	50                   	push   %eax
f01025bf:	e8 ed da ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f01025c4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025c7:	8d 83 0e aa f7 ff    	lea    -0x855f2(%ebx),%eax
f01025cd:	50                   	push   %eax
f01025ce:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01025d4:	50                   	push   %eax
f01025d5:	68 ea 02 00 00       	push   $0x2ea
f01025da:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01025e0:	50                   	push   %eax
f01025e1:	e8 cb da ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U);
f01025e6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025e9:	8d 83 74 a4 f7 ff    	lea    -0x85b8c(%ebx),%eax
f01025ef:	50                   	push   %eax
f01025f0:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01025f6:	50                   	push   %eax
f01025f7:	68 eb 02 00 00       	push   $0x2eb
f01025fc:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102602:	50                   	push   %eax
f0102603:	e8 a9 da ff ff       	call   f01000b1 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102608:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010260b:	8d 83 1f aa f7 ff    	lea    -0x855e1(%ebx),%eax
f0102611:	50                   	push   %eax
f0102612:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102618:	50                   	push   %eax
f0102619:	68 ec 02 00 00       	push   $0x2ec
f010261e:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102624:	50                   	push   %eax
f0102625:	e8 87 da ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f010262a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010262d:	8d 83 84 a3 f7 ff    	lea    -0x85c7c(%ebx),%eax
f0102633:	50                   	push   %eax
f0102634:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f010263a:	50                   	push   %eax
f010263b:	68 ef 02 00 00       	push   $0x2ef
f0102640:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102646:	50                   	push   %eax
f0102647:	e8 65 da ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_W);
f010264c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010264f:	8d 83 a8 a4 f7 ff    	lea    -0x85b58(%ebx),%eax
f0102655:	50                   	push   %eax
f0102656:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f010265c:	50                   	push   %eax
f010265d:	68 f0 02 00 00       	push   $0x2f0
f0102662:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102668:	50                   	push   %eax
f0102669:	e8 43 da ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f010266e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102671:	8d 83 dc a4 f7 ff    	lea    -0x85b24(%ebx),%eax
f0102677:	50                   	push   %eax
f0102678:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f010267e:	50                   	push   %eax
f010267f:	68 f1 02 00 00       	push   $0x2f1
f0102684:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f010268a:	50                   	push   %eax
f010268b:	e8 21 da ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void *)PTSIZE, PTE_W) < 0);
f0102690:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102693:	8d 83 14 a5 f7 ff    	lea    -0x85aec(%ebx),%eax
f0102699:	50                   	push   %eax
f010269a:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01026a0:	50                   	push   %eax
f01026a1:	68 f4 02 00 00       	push   $0x2f4
f01026a6:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01026ac:	50                   	push   %eax
f01026ad:	e8 ff d9 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W) == 0);
f01026b2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026b5:	8d 83 4c a5 f7 ff    	lea    -0x85ab4(%ebx),%eax
f01026bb:	50                   	push   %eax
f01026bc:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01026c2:	50                   	push   %eax
f01026c3:	68 f7 02 00 00       	push   $0x2f7
f01026c8:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01026ce:	50                   	push   %eax
f01026cf:	e8 dd d9 ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f01026d4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026d7:	8d 83 dc a4 f7 ff    	lea    -0x85b24(%ebx),%eax
f01026dd:	50                   	push   %eax
f01026de:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01026e4:	50                   	push   %eax
f01026e5:	68 f8 02 00 00       	push   $0x2f8
f01026ea:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01026f0:	50                   	push   %eax
f01026f1:	e8 bb d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01026f6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026f9:	8d 83 88 a5 f7 ff    	lea    -0x85a78(%ebx),%eax
f01026ff:	50                   	push   %eax
f0102700:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102706:	50                   	push   %eax
f0102707:	68 fb 02 00 00       	push   $0x2fb
f010270c:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102712:	50                   	push   %eax
f0102713:	e8 99 d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102718:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010271b:	8d 83 b4 a5 f7 ff    	lea    -0x85a4c(%ebx),%eax
f0102721:	50                   	push   %eax
f0102722:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102728:	50                   	push   %eax
f0102729:	68 fc 02 00 00       	push   $0x2fc
f010272e:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102734:	50                   	push   %eax
f0102735:	e8 77 d9 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 2);
f010273a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010273d:	8d 83 35 aa f7 ff    	lea    -0x855cb(%ebx),%eax
f0102743:	50                   	push   %eax
f0102744:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f010274a:	50                   	push   %eax
f010274b:	68 fe 02 00 00       	push   $0x2fe
f0102750:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102756:	50                   	push   %eax
f0102757:	e8 55 d9 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f010275c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010275f:	8d 83 46 aa f7 ff    	lea    -0x855ba(%ebx),%eax
f0102765:	50                   	push   %eax
f0102766:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f010276c:	50                   	push   %eax
f010276d:	68 ff 02 00 00       	push   $0x2ff
f0102772:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102778:	50                   	push   %eax
f0102779:	e8 33 d9 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f010277e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102781:	8d 83 e4 a5 f7 ff    	lea    -0x85a1c(%ebx),%eax
f0102787:	50                   	push   %eax
f0102788:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f010278e:	50                   	push   %eax
f010278f:	68 02 03 00 00       	push   $0x302
f0102794:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f010279a:	50                   	push   %eax
f010279b:	e8 11 d9 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01027a0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027a3:	8d 83 08 a6 f7 ff    	lea    -0x859f8(%ebx),%eax
f01027a9:	50                   	push   %eax
f01027aa:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01027b0:	50                   	push   %eax
f01027b1:	68 06 03 00 00       	push   $0x306
f01027b6:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01027bc:	50                   	push   %eax
f01027bd:	e8 ef d8 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01027c2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027c5:	8d 83 b4 a5 f7 ff    	lea    -0x85a4c(%ebx),%eax
f01027cb:	50                   	push   %eax
f01027cc:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01027d2:	50                   	push   %eax
f01027d3:	68 07 03 00 00       	push   $0x307
f01027d8:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01027de:	50                   	push   %eax
f01027df:	e8 cd d8 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f01027e4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027e7:	8d 83 ec a9 f7 ff    	lea    -0x85614(%ebx),%eax
f01027ed:	50                   	push   %eax
f01027ee:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01027f4:	50                   	push   %eax
f01027f5:	68 08 03 00 00       	push   $0x308
f01027fa:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102800:	50                   	push   %eax
f0102801:	e8 ab d8 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102806:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102809:	8d 83 46 aa f7 ff    	lea    -0x855ba(%ebx),%eax
f010280f:	50                   	push   %eax
f0102810:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102816:	50                   	push   %eax
f0102817:	68 09 03 00 00       	push   $0x309
f010281c:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102822:	50                   	push   %eax
f0102823:	e8 89 d8 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, 0) == 0);
f0102828:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010282b:	8d 83 2c a6 f7 ff    	lea    -0x859d4(%ebx),%eax
f0102831:	50                   	push   %eax
f0102832:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102838:	50                   	push   %eax
f0102839:	68 0c 03 00 00       	push   $0x30c
f010283e:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102844:	50                   	push   %eax
f0102845:	e8 67 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref);
f010284a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010284d:	8d 83 57 aa f7 ff    	lea    -0x855a9(%ebx),%eax
f0102853:	50                   	push   %eax
f0102854:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f010285a:	50                   	push   %eax
f010285b:	68 0d 03 00 00       	push   $0x30d
f0102860:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102866:	50                   	push   %eax
f0102867:	e8 45 d8 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_link == NULL);
f010286c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010286f:	8d 83 63 aa f7 ff    	lea    -0x8559d(%ebx),%eax
f0102875:	50                   	push   %eax
f0102876:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f010287c:	50                   	push   %eax
f010287d:	68 0e 03 00 00       	push   $0x30e
f0102882:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102888:	50                   	push   %eax
f0102889:	e8 23 d8 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010288e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102891:	8d 83 08 a6 f7 ff    	lea    -0x859f8(%ebx),%eax
f0102897:	50                   	push   %eax
f0102898:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f010289e:	50                   	push   %eax
f010289f:	68 12 03 00 00       	push   $0x312
f01028a4:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01028aa:	50                   	push   %eax
f01028ab:	e8 01 d8 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01028b0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028b3:	8d 83 64 a6 f7 ff    	lea    -0x8599c(%ebx),%eax
f01028b9:	50                   	push   %eax
f01028ba:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01028c0:	50                   	push   %eax
f01028c1:	68 13 03 00 00       	push   $0x313
f01028c6:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01028cc:	50                   	push   %eax
f01028cd:	e8 df d7 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f01028d2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028d5:	8d 83 78 aa f7 ff    	lea    -0x85588(%ebx),%eax
f01028db:	50                   	push   %eax
f01028dc:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01028e2:	50                   	push   %eax
f01028e3:	68 14 03 00 00       	push   $0x314
f01028e8:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01028ee:	50                   	push   %eax
f01028ef:	e8 bd d7 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f01028f4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028f7:	8d 83 46 aa f7 ff    	lea    -0x855ba(%ebx),%eax
f01028fd:	50                   	push   %eax
f01028fe:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102904:	50                   	push   %eax
f0102905:	68 15 03 00 00       	push   $0x315
f010290a:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102910:	50                   	push   %eax
f0102911:	e8 9b d7 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102916:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102919:	8d 83 8c a6 f7 ff    	lea    -0x85974(%ebx),%eax
f010291f:	50                   	push   %eax
f0102920:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102926:	50                   	push   %eax
f0102927:	68 18 03 00 00       	push   $0x318
f010292c:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102932:	50                   	push   %eax
f0102933:	e8 79 d7 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102938:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010293b:	8d 83 9a a9 f7 ff    	lea    -0x85666(%ebx),%eax
f0102941:	50                   	push   %eax
f0102942:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102948:	50                   	push   %eax
f0102949:	68 1b 03 00 00       	push   $0x31b
f010294e:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102954:	50                   	push   %eax
f0102955:	e8 57 d7 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010295a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010295d:	8d 83 2c a3 f7 ff    	lea    -0x85cd4(%ebx),%eax
f0102963:	50                   	push   %eax
f0102964:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f010296a:	50                   	push   %eax
f010296b:	68 1e 03 00 00       	push   $0x31e
f0102970:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102976:	50                   	push   %eax
f0102977:	e8 35 d7 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f010297c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010297f:	8d 83 fd a9 f7 ff    	lea    -0x85603(%ebx),%eax
f0102985:	50                   	push   %eax
f0102986:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f010298c:	50                   	push   %eax
f010298d:	68 20 03 00 00       	push   $0x320
f0102992:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102998:	50                   	push   %eax
f0102999:	e8 13 d7 ff ff       	call   f01000b1 <_panic>
f010299e:	52                   	push   %edx
f010299f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029a2:	8d 83 30 a0 f7 ff    	lea    -0x85fd0(%ebx),%eax
f01029a8:	50                   	push   %eax
f01029a9:	68 27 03 00 00       	push   $0x327
f01029ae:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01029b4:	50                   	push   %eax
f01029b5:	e8 f7 d6 ff ff       	call   f01000b1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01029ba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029bd:	8d 83 89 aa f7 ff    	lea    -0x85577(%ebx),%eax
f01029c3:	50                   	push   %eax
f01029c4:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01029ca:	50                   	push   %eax
f01029cb:	68 28 03 00 00       	push   $0x328
f01029d0:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01029d6:	50                   	push   %eax
f01029d7:	e8 d5 d6 ff ff       	call   f01000b1 <_panic>
f01029dc:	50                   	push   %eax
f01029dd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029e0:	8d 83 30 a0 f7 ff    	lea    -0x85fd0(%ebx),%eax
f01029e6:	50                   	push   %eax
f01029e7:	6a 56                	push   $0x56
f01029e9:	8d 83 81 a8 f7 ff    	lea    -0x8577f(%ebx),%eax
f01029ef:	50                   	push   %eax
f01029f0:	e8 bc d6 ff ff       	call   f01000b1 <_panic>
f01029f5:	52                   	push   %edx
f01029f6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029f9:	8d 83 30 a0 f7 ff    	lea    -0x85fd0(%ebx),%eax
f01029ff:	50                   	push   %eax
f0102a00:	6a 56                	push   $0x56
f0102a02:	8d 83 81 a8 f7 ff    	lea    -0x8577f(%ebx),%eax
f0102a08:	50                   	push   %eax
f0102a09:	e8 a3 d6 ff ff       	call   f01000b1 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102a0e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a11:	8d 83 a1 aa f7 ff    	lea    -0x8555f(%ebx),%eax
f0102a17:	50                   	push   %eax
f0102a18:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102a1e:	50                   	push   %eax
f0102a1f:	68 32 03 00 00       	push   $0x332
f0102a24:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102a2a:	50                   	push   %eax
f0102a2b:	e8 81 d6 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a30:	50                   	push   %eax
f0102a31:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a34:	8d 83 34 a1 f7 ff    	lea    -0x85ecc(%ebx),%eax
f0102a3a:	50                   	push   %eax
f0102a3b:	68 bf 00 00 00       	push   $0xbf
f0102a40:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102a46:	50                   	push   %eax
f0102a47:	e8 65 d6 ff ff       	call   f01000b1 <_panic>
f0102a4c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a4f:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
f0102a55:	8d 83 34 a1 f7 ff    	lea    -0x85ecc(%ebx),%eax
f0102a5b:	50                   	push   %eax
f0102a5c:	68 cc 00 00 00       	push   $0xcc
f0102a61:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102a67:	50                   	push   %eax
f0102a68:	e8 44 d6 ff ff       	call   f01000b1 <_panic>
f0102a6d:	ff 75 c0             	pushl  -0x40(%ebp)
f0102a70:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a73:	8d 83 34 a1 f7 ff    	lea    -0x85ecc(%ebx),%eax
f0102a79:	50                   	push   %eax
f0102a7a:	68 6e 02 00 00       	push   $0x26e
f0102a7f:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102a85:	50                   	push   %eax
f0102a86:	e8 26 d6 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102a8b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a8e:	8d 83 b0 a6 f7 ff    	lea    -0x85950(%ebx),%eax
f0102a94:	50                   	push   %eax
f0102a95:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102a9b:	50                   	push   %eax
f0102a9c:	68 6e 02 00 00       	push   $0x26e
f0102aa1:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102aa7:	50                   	push   %eax
f0102aa8:	e8 04 d6 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102aad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ab0:	c7 c0 48 d3 18 f0    	mov    $0xf018d348,%eax
f0102ab6:	8b 00                	mov    (%eax),%eax
f0102ab8:	89 45 cc             	mov    %eax,-0x34(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0102abb:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102abe:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
f0102ac3:	8d 98 00 00 40 21    	lea    0x21400000(%eax),%ebx
f0102ac9:	89 fa                	mov    %edi,%edx
f0102acb:	89 f0                	mov    %esi,%eax
f0102acd:	e8 6b e0 ff ff       	call   f0100b3d <check_va2pa>
f0102ad2:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102ad9:	76 22                	jbe    f0102afd <mem_init+0x174c>
f0102adb:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0102ade:	39 d0                	cmp    %edx,%eax
f0102ae0:	75 39                	jne    f0102b1b <mem_init+0x176a>
f0102ae2:	81 c7 00 10 00 00    	add    $0x1000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0102ae8:	81 ff 00 80 c1 ee    	cmp    $0xeec18000,%edi
f0102aee:	75 d9                	jne    f0102ac9 <mem_init+0x1718>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102af0:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102af3:	c1 e7 0c             	shl    $0xc,%edi
f0102af6:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102afb:	eb 57                	jmp    f0102b54 <mem_init+0x17a3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102afd:	ff 75 cc             	pushl  -0x34(%ebp)
f0102b00:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b03:	8d 83 34 a1 f7 ff    	lea    -0x85ecc(%ebx),%eax
f0102b09:	50                   	push   %eax
f0102b0a:	68 73 02 00 00       	push   $0x273
f0102b0f:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102b15:	50                   	push   %eax
f0102b16:	e8 96 d5 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102b1b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b1e:	8d 83 e4 a6 f7 ff    	lea    -0x8591c(%ebx),%eax
f0102b24:	50                   	push   %eax
f0102b25:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102b2b:	50                   	push   %eax
f0102b2c:	68 73 02 00 00       	push   $0x273
f0102b31:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102b37:	50                   	push   %eax
f0102b38:	e8 74 d5 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102b3d:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102b43:	89 f0                	mov    %esi,%eax
f0102b45:	e8 f3 df ff ff       	call   f0100b3d <check_va2pa>
f0102b4a:	39 c3                	cmp    %eax,%ebx
f0102b4c:	75 51                	jne    f0102b9f <mem_init+0x17ee>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102b4e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102b54:	39 fb                	cmp    %edi,%ebx
f0102b56:	72 e5                	jb     f0102b3d <mem_init+0x178c>
f0102b58:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102b5d:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102b60:	81 c7 00 80 00 20    	add    $0x20008000,%edi
f0102b66:	89 da                	mov    %ebx,%edx
f0102b68:	89 f0                	mov    %esi,%eax
f0102b6a:	e8 ce df ff ff       	call   f0100b3d <check_va2pa>
f0102b6f:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102b72:	39 c2                	cmp    %eax,%edx
f0102b74:	75 4b                	jne    f0102bc1 <mem_init+0x1810>
f0102b76:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102b7c:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102b82:	75 e2                	jne    f0102b66 <mem_init+0x17b5>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102b84:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102b89:	89 f0                	mov    %esi,%eax
f0102b8b:	e8 ad df ff ff       	call   f0100b3d <check_va2pa>
f0102b90:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b93:	75 4e                	jne    f0102be3 <mem_init+0x1832>
	for (i = 0; i < NPDENTRIES; i++)
f0102b95:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b9a:	e9 8f 00 00 00       	jmp    f0102c2e <mem_init+0x187d>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102b9f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ba2:	8d 83 18 a7 f7 ff    	lea    -0x858e8(%ebx),%eax
f0102ba8:	50                   	push   %eax
f0102ba9:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102baf:	50                   	push   %eax
f0102bb0:	68 76 02 00 00       	push   $0x276
f0102bb5:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102bbb:	50                   	push   %eax
f0102bbc:	e8 f0 d4 ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102bc1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bc4:	8d 83 40 a7 f7 ff    	lea    -0x858c0(%ebx),%eax
f0102bca:	50                   	push   %eax
f0102bcb:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102bd1:	50                   	push   %eax
f0102bd2:	68 7a 02 00 00       	push   $0x27a
f0102bd7:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102bdd:	50                   	push   %eax
f0102bde:	e8 ce d4 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102be3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102be6:	8d 83 88 a7 f7 ff    	lea    -0x85878(%ebx),%eax
f0102bec:	50                   	push   %eax
f0102bed:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102bf3:	50                   	push   %eax
f0102bf4:	68 7b 02 00 00       	push   $0x27b
f0102bf9:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102bff:	50                   	push   %eax
f0102c00:	e8 ac d4 ff ff       	call   f01000b1 <_panic>
			assert(pgdir[i] & PTE_P);
f0102c05:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102c09:	74 52                	je     f0102c5d <mem_init+0x18ac>
	for (i = 0; i < NPDENTRIES; i++)
f0102c0b:	83 c0 01             	add    $0x1,%eax
f0102c0e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102c13:	0f 87 bb 00 00 00    	ja     f0102cd4 <mem_init+0x1923>
		switch (i)
f0102c19:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102c1e:	72 0e                	jb     f0102c2e <mem_init+0x187d>
f0102c20:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102c25:	76 de                	jbe    f0102c05 <mem_init+0x1854>
f0102c27:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102c2c:	74 d7                	je     f0102c05 <mem_init+0x1854>
			if (i >= PDX(KERNBASE))
f0102c2e:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102c33:	77 4a                	ja     f0102c7f <mem_init+0x18ce>
				assert(pgdir[i] == 0);
f0102c35:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102c39:	74 d0                	je     f0102c0b <mem_init+0x185a>
f0102c3b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c3e:	8d 83 f3 aa f7 ff    	lea    -0x8550d(%ebx),%eax
f0102c44:	50                   	push   %eax
f0102c45:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102c4b:	50                   	push   %eax
f0102c4c:	68 8f 02 00 00       	push   $0x28f
f0102c51:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102c57:	50                   	push   %eax
f0102c58:	e8 54 d4 ff ff       	call   f01000b1 <_panic>
			assert(pgdir[i] & PTE_P);
f0102c5d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c60:	8d 83 d1 aa f7 ff    	lea    -0x8552f(%ebx),%eax
f0102c66:	50                   	push   %eax
f0102c67:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102c6d:	50                   	push   %eax
f0102c6e:	68 86 02 00 00       	push   $0x286
f0102c73:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102c79:	50                   	push   %eax
f0102c7a:	e8 32 d4 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0102c7f:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102c82:	f6 c2 01             	test   $0x1,%dl
f0102c85:	74 2b                	je     f0102cb2 <mem_init+0x1901>
				assert(pgdir[i] & PTE_W);
f0102c87:	f6 c2 02             	test   $0x2,%dl
f0102c8a:	0f 85 7b ff ff ff    	jne    f0102c0b <mem_init+0x185a>
f0102c90:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c93:	8d 83 e2 aa f7 ff    	lea    -0x8551e(%ebx),%eax
f0102c99:	50                   	push   %eax
f0102c9a:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102ca0:	50                   	push   %eax
f0102ca1:	68 8c 02 00 00       	push   $0x28c
f0102ca6:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102cac:	50                   	push   %eax
f0102cad:	e8 ff d3 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0102cb2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cb5:	8d 83 d1 aa f7 ff    	lea    -0x8552f(%ebx),%eax
f0102cbb:	50                   	push   %eax
f0102cbc:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102cc2:	50                   	push   %eax
f0102cc3:	68 8b 02 00 00       	push   $0x28b
f0102cc8:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102cce:	50                   	push   %eax
f0102ccf:	e8 dd d3 ff ff       	call   f01000b1 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102cd4:	83 ec 0c             	sub    $0xc,%esp
f0102cd7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102cda:	8d 87 b8 a7 f7 ff    	lea    -0x85848(%edi),%eax
f0102ce0:	50                   	push   %eax
f0102ce1:	89 fb                	mov    %edi,%ebx
f0102ce3:	e8 a1 09 00 00       	call   f0103689 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102ce8:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0102cee:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102cf0:	83 c4 10             	add    $0x10,%esp
f0102cf3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102cf8:	0f 86 44 02 00 00    	jbe    f0102f42 <mem_init+0x1b91>
	return (physaddr_t)kva - KERNBASE;
f0102cfe:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102d03:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102d06:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d0b:	e8 aa de ff ff       	call   f0100bba <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102d10:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS | CR0_EM);
f0102d13:	83 e0 f3             	and    $0xfffffff3,%eax
f0102d16:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102d1b:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102d1e:	83 ec 0c             	sub    $0xc,%esp
f0102d21:	6a 00                	push   $0x0
f0102d23:	e8 13 e3 ff ff       	call   f010103b <page_alloc>
f0102d28:	89 c6                	mov    %eax,%esi
f0102d2a:	83 c4 10             	add    $0x10,%esp
f0102d2d:	85 c0                	test   %eax,%eax
f0102d2f:	0f 84 29 02 00 00    	je     f0102f5e <mem_init+0x1bad>
	assert((pp1 = page_alloc(0)));
f0102d35:	83 ec 0c             	sub    $0xc,%esp
f0102d38:	6a 00                	push   $0x0
f0102d3a:	e8 fc e2 ff ff       	call   f010103b <page_alloc>
f0102d3f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102d42:	83 c4 10             	add    $0x10,%esp
f0102d45:	85 c0                	test   %eax,%eax
f0102d47:	0f 84 33 02 00 00    	je     f0102f80 <mem_init+0x1bcf>
	assert((pp2 = page_alloc(0)));
f0102d4d:	83 ec 0c             	sub    $0xc,%esp
f0102d50:	6a 00                	push   $0x0
f0102d52:	e8 e4 e2 ff ff       	call   f010103b <page_alloc>
f0102d57:	89 c7                	mov    %eax,%edi
f0102d59:	83 c4 10             	add    $0x10,%esp
f0102d5c:	85 c0                	test   %eax,%eax
f0102d5e:	0f 84 3e 02 00 00    	je     f0102fa2 <mem_init+0x1bf1>
	page_free(pp0);
f0102d64:	83 ec 0c             	sub    $0xc,%esp
f0102d67:	56                   	push   %esi
f0102d68:	e8 5c e3 ff ff       	call   f01010c9 <page_free>
	return (pp - pages) << PGSHIFT;
f0102d6d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d70:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0102d76:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102d79:	2b 08                	sub    (%eax),%ecx
f0102d7b:	89 c8                	mov    %ecx,%eax
f0102d7d:	c1 f8 03             	sar    $0x3,%eax
f0102d80:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102d83:	89 c1                	mov    %eax,%ecx
f0102d85:	c1 e9 0c             	shr    $0xc,%ecx
f0102d88:	83 c4 10             	add    $0x10,%esp
f0102d8b:	c7 c2 04 e0 18 f0    	mov    $0xf018e004,%edx
f0102d91:	3b 0a                	cmp    (%edx),%ecx
f0102d93:	0f 83 2b 02 00 00    	jae    f0102fc4 <mem_init+0x1c13>
	memset(page2kva(pp1), 1, PGSIZE);
f0102d99:	83 ec 04             	sub    $0x4,%esp
f0102d9c:	68 00 10 00 00       	push   $0x1000
f0102da1:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102da3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102da8:	50                   	push   %eax
f0102da9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102dac:	e8 8a 19 00 00       	call   f010473b <memset>
	return (pp - pages) << PGSHIFT;
f0102db1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102db4:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0102dba:	89 f9                	mov    %edi,%ecx
f0102dbc:	2b 08                	sub    (%eax),%ecx
f0102dbe:	89 c8                	mov    %ecx,%eax
f0102dc0:	c1 f8 03             	sar    $0x3,%eax
f0102dc3:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102dc6:	89 c1                	mov    %eax,%ecx
f0102dc8:	c1 e9 0c             	shr    $0xc,%ecx
f0102dcb:	83 c4 10             	add    $0x10,%esp
f0102dce:	c7 c2 04 e0 18 f0    	mov    $0xf018e004,%edx
f0102dd4:	3b 0a                	cmp    (%edx),%ecx
f0102dd6:	0f 83 fe 01 00 00    	jae    f0102fda <mem_init+0x1c29>
	memset(page2kva(pp2), 2, PGSIZE);
f0102ddc:	83 ec 04             	sub    $0x4,%esp
f0102ddf:	68 00 10 00 00       	push   $0x1000
f0102de4:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102de6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102deb:	50                   	push   %eax
f0102dec:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102def:	e8 47 19 00 00       	call   f010473b <memset>
	page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W);
f0102df4:	6a 02                	push   $0x2
f0102df6:	68 00 10 00 00       	push   $0x1000
f0102dfb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102dfe:	53                   	push   %ebx
f0102dff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e02:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0102e08:	ff 30                	pushl  (%eax)
f0102e0a:	e8 20 e5 ff ff       	call   f010132f <page_insert>
	assert(pp1->pp_ref == 1);
f0102e0f:	83 c4 20             	add    $0x20,%esp
f0102e12:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102e17:	0f 85 d3 01 00 00    	jne    f0102ff0 <mem_init+0x1c3f>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102e1d:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102e24:	01 01 01 
f0102e27:	0f 85 e5 01 00 00    	jne    f0103012 <mem_init+0x1c61>
	page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W);
f0102e2d:	6a 02                	push   $0x2
f0102e2f:	68 00 10 00 00       	push   $0x1000
f0102e34:	57                   	push   %edi
f0102e35:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e38:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0102e3e:	ff 30                	pushl  (%eax)
f0102e40:	e8 ea e4 ff ff       	call   f010132f <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102e45:	83 c4 10             	add    $0x10,%esp
f0102e48:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102e4f:	02 02 02 
f0102e52:	0f 85 dc 01 00 00    	jne    f0103034 <mem_init+0x1c83>
	assert(pp2->pp_ref == 1);
f0102e58:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102e5d:	0f 85 f3 01 00 00    	jne    f0103056 <mem_init+0x1ca5>
	assert(pp1->pp_ref == 0);
f0102e63:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102e66:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102e6b:	0f 85 07 02 00 00    	jne    f0103078 <mem_init+0x1cc7>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102e71:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102e78:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102e7b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e7e:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0102e84:	89 f9                	mov    %edi,%ecx
f0102e86:	2b 08                	sub    (%eax),%ecx
f0102e88:	89 c8                	mov    %ecx,%eax
f0102e8a:	c1 f8 03             	sar    $0x3,%eax
f0102e8d:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102e90:	89 c1                	mov    %eax,%ecx
f0102e92:	c1 e9 0c             	shr    $0xc,%ecx
f0102e95:	c7 c2 04 e0 18 f0    	mov    $0xf018e004,%edx
f0102e9b:	3b 0a                	cmp    (%edx),%ecx
f0102e9d:	0f 83 f7 01 00 00    	jae    f010309a <mem_init+0x1ce9>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ea3:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102eaa:	03 03 03 
f0102ead:	0f 85 fd 01 00 00    	jne    f01030b0 <mem_init+0x1cff>
	page_remove(kern_pgdir, (void *)PGSIZE);
f0102eb3:	83 ec 08             	sub    $0x8,%esp
f0102eb6:	68 00 10 00 00       	push   $0x1000
f0102ebb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ebe:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0102ec4:	ff 30                	pushl  (%eax)
f0102ec6:	e8 29 e4 ff ff       	call   f01012f4 <page_remove>
	assert(pp2->pp_ref == 0);
f0102ecb:	83 c4 10             	add    $0x10,%esp
f0102ece:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102ed3:	0f 85 f9 01 00 00    	jne    f01030d2 <mem_init+0x1d21>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ed9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102edc:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0102ee2:	8b 08                	mov    (%eax),%ecx
f0102ee4:	8b 11                	mov    (%ecx),%edx
f0102ee6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102eec:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0102ef2:	89 f7                	mov    %esi,%edi
f0102ef4:	2b 38                	sub    (%eax),%edi
f0102ef6:	89 f8                	mov    %edi,%eax
f0102ef8:	c1 f8 03             	sar    $0x3,%eax
f0102efb:	c1 e0 0c             	shl    $0xc,%eax
f0102efe:	39 c2                	cmp    %eax,%edx
f0102f00:	0f 85 ee 01 00 00    	jne    f01030f4 <mem_init+0x1d43>
	kern_pgdir[0] = 0;
f0102f06:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102f0c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102f11:	0f 85 ff 01 00 00    	jne    f0103116 <mem_init+0x1d65>
	pp0->pp_ref = 0;
f0102f17:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102f1d:	83 ec 0c             	sub    $0xc,%esp
f0102f20:	56                   	push   %esi
f0102f21:	e8 a3 e1 ff ff       	call   f01010c9 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102f26:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f29:	8d 83 4c a8 f7 ff    	lea    -0x857b4(%ebx),%eax
f0102f2f:	89 04 24             	mov    %eax,(%esp)
f0102f32:	e8 52 07 00 00       	call   f0103689 <cprintf>
}
f0102f37:	83 c4 10             	add    $0x10,%esp
f0102f3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f3d:	5b                   	pop    %ebx
f0102f3e:	5e                   	pop    %esi
f0102f3f:	5f                   	pop    %edi
f0102f40:	5d                   	pop    %ebp
f0102f41:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f42:	50                   	push   %eax
f0102f43:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f46:	8d 83 34 a1 f7 ff    	lea    -0x85ecc(%ebx),%eax
f0102f4c:	50                   	push   %eax
f0102f4d:	68 dd 00 00 00       	push   $0xdd
f0102f52:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102f58:	50                   	push   %eax
f0102f59:	e8 53 d1 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0102f5e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f61:	8d 83 46 a9 f7 ff    	lea    -0x856ba(%ebx),%eax
f0102f67:	50                   	push   %eax
f0102f68:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102f6e:	50                   	push   %eax
f0102f6f:	68 4d 03 00 00       	push   $0x34d
f0102f74:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102f7a:	50                   	push   %eax
f0102f7b:	e8 31 d1 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102f80:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f83:	8d 83 5c a9 f7 ff    	lea    -0x856a4(%ebx),%eax
f0102f89:	50                   	push   %eax
f0102f8a:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102f90:	50                   	push   %eax
f0102f91:	68 4e 03 00 00       	push   $0x34e
f0102f96:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102f9c:	50                   	push   %eax
f0102f9d:	e8 0f d1 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0102fa2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fa5:	8d 83 72 a9 f7 ff    	lea    -0x8568e(%ebx),%eax
f0102fab:	50                   	push   %eax
f0102fac:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0102fb2:	50                   	push   %eax
f0102fb3:	68 4f 03 00 00       	push   $0x34f
f0102fb8:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0102fbe:	50                   	push   %eax
f0102fbf:	e8 ed d0 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102fc4:	50                   	push   %eax
f0102fc5:	8d 83 30 a0 f7 ff    	lea    -0x85fd0(%ebx),%eax
f0102fcb:	50                   	push   %eax
f0102fcc:	6a 56                	push   $0x56
f0102fce:	8d 83 81 a8 f7 ff    	lea    -0x8577f(%ebx),%eax
f0102fd4:	50                   	push   %eax
f0102fd5:	e8 d7 d0 ff ff       	call   f01000b1 <_panic>
f0102fda:	50                   	push   %eax
f0102fdb:	8d 83 30 a0 f7 ff    	lea    -0x85fd0(%ebx),%eax
f0102fe1:	50                   	push   %eax
f0102fe2:	6a 56                	push   $0x56
f0102fe4:	8d 83 81 a8 f7 ff    	lea    -0x8577f(%ebx),%eax
f0102fea:	50                   	push   %eax
f0102feb:	e8 c1 d0 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102ff0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ff3:	8d 83 ec a9 f7 ff    	lea    -0x85614(%ebx),%eax
f0102ff9:	50                   	push   %eax
f0102ffa:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0103000:	50                   	push   %eax
f0103001:	68 54 03 00 00       	push   $0x354
f0103006:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f010300c:	50                   	push   %eax
f010300d:	e8 9f d0 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103012:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103015:	8d 83 d8 a7 f7 ff    	lea    -0x85828(%ebx),%eax
f010301b:	50                   	push   %eax
f010301c:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0103022:	50                   	push   %eax
f0103023:	68 55 03 00 00       	push   $0x355
f0103028:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f010302e:	50                   	push   %eax
f010302f:	e8 7d d0 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103034:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103037:	8d 83 fc a7 f7 ff    	lea    -0x85804(%ebx),%eax
f010303d:	50                   	push   %eax
f010303e:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0103044:	50                   	push   %eax
f0103045:	68 57 03 00 00       	push   $0x357
f010304a:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0103050:	50                   	push   %eax
f0103051:	e8 5b d0 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0103056:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103059:	8d 83 0e aa f7 ff    	lea    -0x855f2(%ebx),%eax
f010305f:	50                   	push   %eax
f0103060:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0103066:	50                   	push   %eax
f0103067:	68 58 03 00 00       	push   $0x358
f010306c:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0103072:	50                   	push   %eax
f0103073:	e8 39 d0 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f0103078:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010307b:	8d 83 78 aa f7 ff    	lea    -0x85588(%ebx),%eax
f0103081:	50                   	push   %eax
f0103082:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0103088:	50                   	push   %eax
f0103089:	68 59 03 00 00       	push   $0x359
f010308e:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0103094:	50                   	push   %eax
f0103095:	e8 17 d0 ff ff       	call   f01000b1 <_panic>
f010309a:	50                   	push   %eax
f010309b:	8d 83 30 a0 f7 ff    	lea    -0x85fd0(%ebx),%eax
f01030a1:	50                   	push   %eax
f01030a2:	6a 56                	push   $0x56
f01030a4:	8d 83 81 a8 f7 ff    	lea    -0x8577f(%ebx),%eax
f01030aa:	50                   	push   %eax
f01030ab:	e8 01 d0 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01030b0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030b3:	8d 83 20 a8 f7 ff    	lea    -0x857e0(%ebx),%eax
f01030b9:	50                   	push   %eax
f01030ba:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01030c0:	50                   	push   %eax
f01030c1:	68 5b 03 00 00       	push   $0x35b
f01030c6:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01030cc:	50                   	push   %eax
f01030cd:	e8 df cf ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f01030d2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030d5:	8d 83 46 aa f7 ff    	lea    -0x855ba(%ebx),%eax
f01030db:	50                   	push   %eax
f01030dc:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01030e2:	50                   	push   %eax
f01030e3:	68 5d 03 00 00       	push   $0x35d
f01030e8:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f01030ee:	50                   	push   %eax
f01030ef:	e8 bd cf ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01030f4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030f7:	8d 83 2c a3 f7 ff    	lea    -0x85cd4(%ebx),%eax
f01030fd:	50                   	push   %eax
f01030fe:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0103104:	50                   	push   %eax
f0103105:	68 60 03 00 00       	push   $0x360
f010310a:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0103110:	50                   	push   %eax
f0103111:	e8 9b cf ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f0103116:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103119:	8d 83 fd a9 f7 ff    	lea    -0x85603(%ebx),%eax
f010311f:	50                   	push   %eax
f0103120:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0103126:	50                   	push   %eax
f0103127:	68 62 03 00 00       	push   $0x362
f010312c:	8d 83 75 a8 f7 ff    	lea    -0x8578b(%ebx),%eax
f0103132:	50                   	push   %eax
f0103133:	e8 79 cf ff ff       	call   f01000b1 <_panic>

f0103138 <tlb_invalidate>:
{
f0103138:	55                   	push   %ebp
f0103139:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010313b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010313e:	0f 01 38             	invlpg (%eax)
}
f0103141:	5d                   	pop    %ebp
f0103142:	c3                   	ret    

f0103143 <user_mem_check>:
{
f0103143:	55                   	push   %ebp
f0103144:	89 e5                	mov    %esp,%ebp
}
f0103146:	b8 00 00 00 00       	mov    $0x0,%eax
f010314b:	5d                   	pop    %ebp
f010314c:	c3                   	ret    

f010314d <user_mem_assert>:
{
f010314d:	55                   	push   %ebp
f010314e:	89 e5                	mov    %esp,%ebp
}
f0103150:	5d                   	pop    %ebp
f0103151:	c3                   	ret    

f0103152 <__x86.get_pc_thunk.cx>:
f0103152:	8b 0c 24             	mov    (%esp),%ecx
f0103155:	c3                   	ret    

f0103156 <__x86.get_pc_thunk.si>:
f0103156:	8b 34 24             	mov    (%esp),%esi
f0103159:	c3                   	ret    

f010315a <__x86.get_pc_thunk.di>:
f010315a:	8b 3c 24             	mov    (%esp),%edi
f010315d:	c3                   	ret    

f010315e <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010315e:	55                   	push   %ebp
f010315f:	89 e5                	mov    %esp,%ebp
f0103161:	53                   	push   %ebx
f0103162:	e8 eb ff ff ff       	call   f0103152 <__x86.get_pc_thunk.cx>
f0103167:	81 c1 b9 7e 08 00    	add    $0x87eb9,%ecx
f010316d:	8b 55 08             	mov    0x8(%ebp),%edx
f0103170:	8b 5d 10             	mov    0x10(%ebp),%ebx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103173:	85 d2                	test   %edx,%edx
f0103175:	74 41                	je     f01031b8 <envid2env+0x5a>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103177:	89 d0                	mov    %edx,%eax
f0103179:	25 ff 03 00 00       	and    $0x3ff,%eax
f010317e:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103181:	c1 e0 05             	shl    $0x5,%eax
f0103184:	03 81 28 23 00 00    	add    0x2328(%ecx),%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010318a:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f010318e:	74 3a                	je     f01031ca <envid2env+0x6c>
f0103190:	39 50 48             	cmp    %edx,0x48(%eax)
f0103193:	75 35                	jne    f01031ca <envid2env+0x6c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103195:	84 db                	test   %bl,%bl
f0103197:	74 12                	je     f01031ab <envid2env+0x4d>
f0103199:	8b 91 24 23 00 00    	mov    0x2324(%ecx),%edx
f010319f:	39 c2                	cmp    %eax,%edx
f01031a1:	74 08                	je     f01031ab <envid2env+0x4d>
f01031a3:	8b 5a 48             	mov    0x48(%edx),%ebx
f01031a6:	39 58 4c             	cmp    %ebx,0x4c(%eax)
f01031a9:	75 2f                	jne    f01031da <envid2env+0x7c>
		*env_store = 0;
		return -E_BAD_ENV;
	}

	*env_store = e;
f01031ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01031ae:	89 03                	mov    %eax,(%ebx)
	return 0;
f01031b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01031b5:	5b                   	pop    %ebx
f01031b6:	5d                   	pop    %ebp
f01031b7:	c3                   	ret    
		*env_store = curenv;
f01031b8:	8b 81 24 23 00 00    	mov    0x2324(%ecx),%eax
f01031be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01031c1:	89 01                	mov    %eax,(%ecx)
		return 0;
f01031c3:	b8 00 00 00 00       	mov    $0x0,%eax
f01031c8:	eb eb                	jmp    f01031b5 <envid2env+0x57>
		*env_store = 0;
f01031ca:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031cd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01031d3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01031d8:	eb db                	jmp    f01031b5 <envid2env+0x57>
		*env_store = 0;
f01031da:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031dd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01031e3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01031e8:	eb cb                	jmp    f01031b5 <envid2env+0x57>

f01031ea <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01031ea:	55                   	push   %ebp
f01031eb:	89 e5                	mov    %esp,%ebp
f01031ed:	e8 17 d5 ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f01031f2:	05 2e 7e 08 00       	add    $0x87e2e,%eax
	asm volatile("lgdt (%0)" : : "r" (p));
f01031f7:	8d 80 e0 1f 00 00    	lea    0x1fe0(%eax),%eax
f01031fd:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103200:	b8 23 00 00 00       	mov    $0x23,%eax
f0103205:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103207:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103209:	b8 10 00 00 00       	mov    $0x10,%eax
f010320e:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103210:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103212:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103214:	ea 1b 32 10 f0 08 00 	ljmp   $0x8,$0xf010321b
	asm volatile("lldt %0" : : "r" (sel));
f010321b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103220:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103223:	5d                   	pop    %ebp
f0103224:	c3                   	ret    

f0103225 <env_init>:
{
f0103225:	55                   	push   %ebp
f0103226:	89 e5                	mov    %esp,%ebp
	env_init_percpu();
f0103228:	e8 bd ff ff ff       	call   f01031ea <env_init_percpu>
}
f010322d:	5d                   	pop    %ebp
f010322e:	c3                   	ret    

f010322f <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010322f:	55                   	push   %ebp
f0103230:	89 e5                	mov    %esp,%ebp
f0103232:	56                   	push   %esi
f0103233:	53                   	push   %ebx
f0103234:	e8 2e cf ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103239:	81 c3 e7 7d 08 00    	add    $0x87de7,%ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010323f:	8b b3 2c 23 00 00    	mov    0x232c(%ebx),%esi
f0103245:	85 f6                	test   %esi,%esi
f0103247:	0f 84 03 01 00 00    	je     f0103350 <env_alloc+0x121>
	if (!(p = page_alloc(ALLOC_ZERO)))
f010324d:	83 ec 0c             	sub    $0xc,%esp
f0103250:	6a 01                	push   $0x1
f0103252:	e8 e4 dd ff ff       	call   f010103b <page_alloc>
f0103257:	83 c4 10             	add    $0x10,%esp
f010325a:	85 c0                	test   %eax,%eax
f010325c:	0f 84 f5 00 00 00    	je     f0103357 <env_alloc+0x128>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103262:	8b 46 5c             	mov    0x5c(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103265:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010326a:	0f 86 c7 00 00 00    	jbe    f0103337 <env_alloc+0x108>
	return (physaddr_t)kva - KERNBASE;
f0103270:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103276:	83 ca 05             	or     $0x5,%edx
f0103279:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010327f:	8b 46 48             	mov    0x48(%esi),%eax
f0103282:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103287:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f010328c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103291:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103294:	89 f2                	mov    %esi,%edx
f0103296:	2b 93 28 23 00 00    	sub    0x2328(%ebx),%edx
f010329c:	c1 fa 05             	sar    $0x5,%edx
f010329f:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01032a5:	09 d0                	or     %edx,%eax
f01032a7:	89 46 48             	mov    %eax,0x48(%esi)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01032aa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032ad:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f01032b0:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f01032b7:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f01032be:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01032c5:	83 ec 04             	sub    $0x4,%esp
f01032c8:	6a 44                	push   $0x44
f01032ca:	6a 00                	push   $0x0
f01032cc:	56                   	push   %esi
f01032cd:	e8 69 14 00 00       	call   f010473b <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01032d2:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f01032d8:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f01032de:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f01032e4:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f01032eb:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f01032f1:	8b 46 44             	mov    0x44(%esi),%eax
f01032f4:	89 83 2c 23 00 00    	mov    %eax,0x232c(%ebx)
	*newenv_store = e;
f01032fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01032fd:	89 30                	mov    %esi,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01032ff:	8b 4e 48             	mov    0x48(%esi),%ecx
f0103302:	8b 83 24 23 00 00    	mov    0x2324(%ebx),%eax
f0103308:	83 c4 10             	add    $0x10,%esp
f010330b:	ba 00 00 00 00       	mov    $0x0,%edx
f0103310:	85 c0                	test   %eax,%eax
f0103312:	74 03                	je     f0103317 <env_alloc+0xe8>
f0103314:	8b 50 48             	mov    0x48(%eax),%edx
f0103317:	83 ec 04             	sub    $0x4,%esp
f010331a:	51                   	push   %ecx
f010331b:	52                   	push   %edx
f010331c:	8d 83 45 ab f7 ff    	lea    -0x854bb(%ebx),%eax
f0103322:	50                   	push   %eax
f0103323:	e8 61 03 00 00       	call   f0103689 <cprintf>
	return 0;
f0103328:	83 c4 10             	add    $0x10,%esp
f010332b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103330:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103333:	5b                   	pop    %ebx
f0103334:	5e                   	pop    %esi
f0103335:	5d                   	pop    %ebp
f0103336:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103337:	50                   	push   %eax
f0103338:	8d 83 34 a1 f7 ff    	lea    -0x85ecc(%ebx),%eax
f010333e:	50                   	push   %eax
f010333f:	68 b9 00 00 00       	push   $0xb9
f0103344:	8d 83 3a ab f7 ff    	lea    -0x854c6(%ebx),%eax
f010334a:	50                   	push   %eax
f010334b:	e8 61 cd ff ff       	call   f01000b1 <_panic>
		return -E_NO_FREE_ENV;
f0103350:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103355:	eb d9                	jmp    f0103330 <env_alloc+0x101>
		return -E_NO_MEM;
f0103357:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010335c:	eb d2                	jmp    f0103330 <env_alloc+0x101>

f010335e <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010335e:	55                   	push   %ebp
f010335f:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f0103361:	5d                   	pop    %ebp
f0103362:	c3                   	ret    

f0103363 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103363:	55                   	push   %ebp
f0103364:	89 e5                	mov    %esp,%ebp
f0103366:	57                   	push   %edi
f0103367:	56                   	push   %esi
f0103368:	53                   	push   %ebx
f0103369:	83 ec 2c             	sub    $0x2c,%esp
f010336c:	e8 f6 cd ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103371:	81 c3 af 7c 08 00    	add    $0x87caf,%ebx
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103377:	8b 93 24 23 00 00    	mov    0x2324(%ebx),%edx
f010337d:	3b 55 08             	cmp    0x8(%ebp),%edx
f0103380:	75 17                	jne    f0103399 <env_free+0x36>
		lcr3(PADDR(kern_pgdir));
f0103382:	c7 c0 08 e0 18 f0    	mov    $0xf018e008,%eax
f0103388:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010338a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010338f:	76 46                	jbe    f01033d7 <env_free+0x74>
	return (physaddr_t)kva - KERNBASE;
f0103391:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103396:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103399:	8b 45 08             	mov    0x8(%ebp),%eax
f010339c:	8b 48 48             	mov    0x48(%eax),%ecx
f010339f:	b8 00 00 00 00       	mov    $0x0,%eax
f01033a4:	85 d2                	test   %edx,%edx
f01033a6:	74 03                	je     f01033ab <env_free+0x48>
f01033a8:	8b 42 48             	mov    0x48(%edx),%eax
f01033ab:	83 ec 04             	sub    $0x4,%esp
f01033ae:	51                   	push   %ecx
f01033af:	50                   	push   %eax
f01033b0:	8d 83 5a ab f7 ff    	lea    -0x854a6(%ebx),%eax
f01033b6:	50                   	push   %eax
f01033b7:	e8 cd 02 00 00       	call   f0103689 <cprintf>
f01033bc:	83 c4 10             	add    $0x10,%esp
f01033bf:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	if (PGNUM(pa) >= npages)
f01033c6:	c7 c0 04 e0 18 f0    	mov    $0xf018e004,%eax
f01033cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (PGNUM(pa) >= npages)
f01033cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01033d2:	e9 9f 00 00 00       	jmp    f0103476 <env_free+0x113>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033d7:	50                   	push   %eax
f01033d8:	8d 83 34 a1 f7 ff    	lea    -0x85ecc(%ebx),%eax
f01033de:	50                   	push   %eax
f01033df:	68 68 01 00 00       	push   $0x168
f01033e4:	8d 83 3a ab f7 ff    	lea    -0x854c6(%ebx),%eax
f01033ea:	50                   	push   %eax
f01033eb:	e8 c1 cc ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01033f0:	50                   	push   %eax
f01033f1:	8d 83 30 a0 f7 ff    	lea    -0x85fd0(%ebx),%eax
f01033f7:	50                   	push   %eax
f01033f8:	68 77 01 00 00       	push   $0x177
f01033fd:	8d 83 3a ab f7 ff    	lea    -0x854c6(%ebx),%eax
f0103403:	50                   	push   %eax
f0103404:	e8 a8 cc ff ff       	call   f01000b1 <_panic>
f0103409:	83 c6 04             	add    $0x4,%esi
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010340c:	39 fe                	cmp    %edi,%esi
f010340e:	74 24                	je     f0103434 <env_free+0xd1>
			if (pt[pteno] & PTE_P)
f0103410:	f6 06 01             	testb  $0x1,(%esi)
f0103413:	74 f4                	je     f0103409 <env_free+0xa6>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103415:	83 ec 08             	sub    $0x8,%esp
f0103418:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010341b:	01 f0                	add    %esi,%eax
f010341d:	c1 e0 0a             	shl    $0xa,%eax
f0103420:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103423:	50                   	push   %eax
f0103424:	8b 45 08             	mov    0x8(%ebp),%eax
f0103427:	ff 70 5c             	pushl  0x5c(%eax)
f010342a:	e8 c5 de ff ff       	call   f01012f4 <page_remove>
f010342f:	83 c4 10             	add    $0x10,%esp
f0103432:	eb d5                	jmp    f0103409 <env_free+0xa6>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103434:	8b 45 08             	mov    0x8(%ebp),%eax
f0103437:	8b 40 5c             	mov    0x5c(%eax),%eax
f010343a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010343d:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103444:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103447:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010344a:	3b 10                	cmp    (%eax),%edx
f010344c:	73 6f                	jae    f01034bd <env_free+0x15a>
		page_decref(pa2page(pa));
f010344e:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103451:	c7 c0 0c e0 18 f0    	mov    $0xf018e00c,%eax
f0103457:	8b 00                	mov    (%eax),%eax
f0103459:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010345c:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010345f:	50                   	push   %eax
f0103460:	e8 b3 dc ff ff       	call   f0101118 <page_decref>
f0103465:	83 c4 10             	add    $0x10,%esp
f0103468:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f010346c:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010346f:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103474:	74 5f                	je     f01034d5 <env_free+0x172>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103476:	8b 45 08             	mov    0x8(%ebp),%eax
f0103479:	8b 40 5c             	mov    0x5c(%eax),%eax
f010347c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010347f:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0103482:	a8 01                	test   $0x1,%al
f0103484:	74 e2                	je     f0103468 <env_free+0x105>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103486:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010348b:	89 c2                	mov    %eax,%edx
f010348d:	c1 ea 0c             	shr    $0xc,%edx
f0103490:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0103493:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103496:	39 11                	cmp    %edx,(%ecx)
f0103498:	0f 86 52 ff ff ff    	jbe    f01033f0 <env_free+0x8d>
	return (void *)(pa + KERNBASE);
f010349e:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034a4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034a7:	c1 e2 14             	shl    $0x14,%edx
f01034aa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01034ad:	8d b8 00 10 00 f0    	lea    -0xffff000(%eax),%edi
f01034b3:	f7 d8                	neg    %eax
f01034b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01034b8:	e9 53 ff ff ff       	jmp    f0103410 <env_free+0xad>
		panic("pa2page called with invalid pa");
f01034bd:	83 ec 04             	sub    $0x4,%esp
f01034c0:	8d 83 9c a1 f7 ff    	lea    -0x85e64(%ebx),%eax
f01034c6:	50                   	push   %eax
f01034c7:	6a 4f                	push   $0x4f
f01034c9:	8d 83 81 a8 f7 ff    	lea    -0x8577f(%ebx),%eax
f01034cf:	50                   	push   %eax
f01034d0:	e8 dc cb ff ff       	call   f01000b1 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01034d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01034d8:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01034db:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034e0:	76 57                	jbe    f0103539 <env_free+0x1d6>
	e->env_pgdir = 0;
f01034e2:	8b 55 08             	mov    0x8(%ebp),%edx
f01034e5:	c7 42 5c 00 00 00 00 	movl   $0x0,0x5c(%edx)
	return (physaddr_t)kva - KERNBASE;
f01034ec:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f01034f1:	c1 e8 0c             	shr    $0xc,%eax
f01034f4:	c7 c2 04 e0 18 f0    	mov    $0xf018e004,%edx
f01034fa:	3b 02                	cmp    (%edx),%eax
f01034fc:	73 54                	jae    f0103552 <env_free+0x1ef>
	page_decref(pa2page(pa));
f01034fe:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103501:	c7 c2 0c e0 18 f0    	mov    $0xf018e00c,%edx
f0103507:	8b 12                	mov    (%edx),%edx
f0103509:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010350c:	50                   	push   %eax
f010350d:	e8 06 dc ff ff       	call   f0101118 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103512:	8b 45 08             	mov    0x8(%ebp),%eax
f0103515:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f010351c:	8b 83 2c 23 00 00    	mov    0x232c(%ebx),%eax
f0103522:	8b 55 08             	mov    0x8(%ebp),%edx
f0103525:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f0103528:	89 93 2c 23 00 00    	mov    %edx,0x232c(%ebx)
}
f010352e:	83 c4 10             	add    $0x10,%esp
f0103531:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103534:	5b                   	pop    %ebx
f0103535:	5e                   	pop    %esi
f0103536:	5f                   	pop    %edi
f0103537:	5d                   	pop    %ebp
f0103538:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103539:	50                   	push   %eax
f010353a:	8d 83 34 a1 f7 ff    	lea    -0x85ecc(%ebx),%eax
f0103540:	50                   	push   %eax
f0103541:	68 85 01 00 00       	push   $0x185
f0103546:	8d 83 3a ab f7 ff    	lea    -0x854c6(%ebx),%eax
f010354c:	50                   	push   %eax
f010354d:	e8 5f cb ff ff       	call   f01000b1 <_panic>
		panic("pa2page called with invalid pa");
f0103552:	83 ec 04             	sub    $0x4,%esp
f0103555:	8d 83 9c a1 f7 ff    	lea    -0x85e64(%ebx),%eax
f010355b:	50                   	push   %eax
f010355c:	6a 4f                	push   $0x4f
f010355e:	8d 83 81 a8 f7 ff    	lea    -0x8577f(%ebx),%eax
f0103564:	50                   	push   %eax
f0103565:	e8 47 cb ff ff       	call   f01000b1 <_panic>

f010356a <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f010356a:	55                   	push   %ebp
f010356b:	89 e5                	mov    %esp,%ebp
f010356d:	53                   	push   %ebx
f010356e:	83 ec 10             	sub    $0x10,%esp
f0103571:	e8 f1 cb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103576:	81 c3 aa 7a 08 00    	add    $0x87aaa,%ebx
	env_free(e);
f010357c:	ff 75 08             	pushl  0x8(%ebp)
f010357f:	e8 df fd ff ff       	call   f0103363 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0103584:	8d 83 04 ab f7 ff    	lea    -0x854fc(%ebx),%eax
f010358a:	89 04 24             	mov    %eax,(%esp)
f010358d:	e8 f7 00 00 00       	call   f0103689 <cprintf>
f0103592:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0103595:	83 ec 0c             	sub    $0xc,%esp
f0103598:	6a 00                	push   $0x0
f010359a:	e8 74 d3 ff ff       	call   f0100913 <monitor>
f010359f:	83 c4 10             	add    $0x10,%esp
f01035a2:	eb f1                	jmp    f0103595 <env_destroy+0x2b>

f01035a4 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01035a4:	55                   	push   %ebp
f01035a5:	89 e5                	mov    %esp,%ebp
f01035a7:	53                   	push   %ebx
f01035a8:	83 ec 08             	sub    $0x8,%esp
f01035ab:	e8 b7 cb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01035b0:	81 c3 70 7a 08 00    	add    $0x87a70,%ebx
	asm volatile(
f01035b6:	8b 65 08             	mov    0x8(%ebp),%esp
f01035b9:	61                   	popa   
f01035ba:	07                   	pop    %es
f01035bb:	1f                   	pop    %ds
f01035bc:	83 c4 08             	add    $0x8,%esp
f01035bf:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01035c0:	8d 83 70 ab f7 ff    	lea    -0x85490(%ebx),%eax
f01035c6:	50                   	push   %eax
f01035c7:	68 ae 01 00 00       	push   $0x1ae
f01035cc:	8d 83 3a ab f7 ff    	lea    -0x854c6(%ebx),%eax
f01035d2:	50                   	push   %eax
f01035d3:	e8 d9 ca ff ff       	call   f01000b1 <_panic>

f01035d8 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01035d8:	55                   	push   %ebp
f01035d9:	89 e5                	mov    %esp,%ebp
f01035db:	53                   	push   %ebx
f01035dc:	83 ec 08             	sub    $0x8,%esp
f01035df:	e8 83 cb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01035e4:	81 c3 3c 7a 08 00    	add    $0x87a3c,%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	panic("env_run not yet implemented");
f01035ea:	8d 83 7c ab f7 ff    	lea    -0x85484(%ebx),%eax
f01035f0:	50                   	push   %eax
f01035f1:	68 cd 01 00 00       	push   $0x1cd
f01035f6:	8d 83 3a ab f7 ff    	lea    -0x854c6(%ebx),%eax
f01035fc:	50                   	push   %eax
f01035fd:	e8 af ca ff ff       	call   f01000b1 <_panic>

f0103602 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103602:	55                   	push   %ebp
f0103603:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103605:	8b 45 08             	mov    0x8(%ebp),%eax
f0103608:	ba 70 00 00 00       	mov    $0x70,%edx
f010360d:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010360e:	ba 71 00 00 00       	mov    $0x71,%edx
f0103613:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103614:	0f b6 c0             	movzbl %al,%eax
}
f0103617:	5d                   	pop    %ebp
f0103618:	c3                   	ret    

f0103619 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103619:	55                   	push   %ebp
f010361a:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010361c:	8b 45 08             	mov    0x8(%ebp),%eax
f010361f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103624:	ee                   	out    %al,(%dx)
f0103625:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103628:	ba 71 00 00 00       	mov    $0x71,%edx
f010362d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010362e:	5d                   	pop    %ebp
f010362f:	c3                   	ret    

f0103630 <putch>:
#include <inc/stdio.h>
#include <inc/stdarg.h>

// putch通过调用console.c中的cputchar来实现输出字符串到控制台。
static void putch(int ch, int *cnt)
{
f0103630:	55                   	push   %ebp
f0103631:	89 e5                	mov    %esp,%ebp
f0103633:	53                   	push   %ebx
f0103634:	83 ec 10             	sub    $0x10,%esp
f0103637:	e8 2b cb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010363c:	81 c3 e4 79 08 00    	add    $0x879e4,%ebx
	cputchar(ch);
f0103642:	ff 75 08             	pushl  0x8(%ebp)
f0103645:	e8 94 d0 ff ff       	call   f01006de <cputchar>
	*cnt++;
}
f010364a:	83 c4 10             	add    $0x10,%esp
f010364d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103650:	c9                   	leave  
f0103651:	c3                   	ret    

f0103652 <vcprintf>:

// 将格式fmt和可变参数列表ap一起传给printfmt.c中的vprintfmt处理
int vcprintf(const char *fmt, va_list ap)
{
f0103652:	55                   	push   %ebp
f0103653:	89 e5                	mov    %esp,%ebp
f0103655:	53                   	push   %ebx
f0103656:	83 ec 14             	sub    $0x14,%esp
f0103659:	e8 09 cb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010365e:	81 c3 c2 79 08 00    	add    $0x879c2,%ebx
	int cnt = 0;
f0103664:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	vprintfmt((void *)putch, &cnt, fmt, ap); // 用一个指向putch的函数指针来告诉vprintfmt，处理后的数据应该交给putch来输出
f010366b:	ff 75 0c             	pushl  0xc(%ebp)
f010366e:	ff 75 08             	pushl  0x8(%ebp)
f0103671:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103674:	50                   	push   %eax
f0103675:	8d 83 10 86 f7 ff    	lea    -0x879f0(%ebx),%eax
f010367b:	50                   	push   %eax
f010367c:	e8 39 09 00 00       	call   f0103fba <vprintfmt>
	return cnt;
}
f0103681:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103684:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103687:	c9                   	leave  
f0103688:	c3                   	ret    

f0103689 <cprintf>:

// 这个函数作为实现打印功能的主要函数，暴露给其他程序。其第一个参数是包含输出格式的字符串，后面是可变参数列表。
int cprintf(const char *fmt, ...)
{
f0103689:	55                   	push   %ebp
f010368a:	89 e5                	mov    %esp,%ebp
f010368c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);		 // 获取可变参数列表ap
f010368f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap); // 传参
f0103692:	50                   	push   %eax
f0103693:	ff 75 08             	pushl  0x8(%ebp)
f0103696:	e8 b7 ff ff ff       	call   f0103652 <vcprintf>
	va_end(ap);

	return cnt;
}
f010369b:	c9                   	leave  
f010369c:	c3                   	ret    

f010369d <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010369d:	55                   	push   %ebp
f010369e:	89 e5                	mov    %esp,%ebp
f01036a0:	57                   	push   %edi
f01036a1:	56                   	push   %esi
f01036a2:	53                   	push   %ebx
f01036a3:	83 ec 04             	sub    $0x4,%esp
f01036a6:	e8 bc ca ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01036ab:	81 c3 75 79 08 00    	add    $0x87975,%ebx
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f01036b1:	c7 83 64 2b 00 00 00 	movl   $0xf0000000,0x2b64(%ebx)
f01036b8:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f01036bb:	66 c7 83 68 2b 00 00 	movw   $0x10,0x2b68(%ebx)
f01036c2:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f01036c4:	66 c7 83 c6 2b 00 00 	movw   $0x68,0x2bc6(%ebx)
f01036cb:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f01036cd:	c7 c0 00 a3 11 f0    	mov    $0xf011a300,%eax
f01036d3:	66 c7 40 28 67 00    	movw   $0x67,0x28(%eax)
f01036d9:	8d b3 60 2b 00 00    	lea    0x2b60(%ebx),%esi
f01036df:	66 89 70 2a          	mov    %si,0x2a(%eax)
f01036e3:	89 f2                	mov    %esi,%edx
f01036e5:	c1 ea 10             	shr    $0x10,%edx
f01036e8:	88 50 2c             	mov    %dl,0x2c(%eax)
f01036eb:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
f01036ef:	83 e2 f0             	and    $0xfffffff0,%edx
f01036f2:	83 ca 09             	or     $0x9,%edx
f01036f5:	83 e2 9f             	and    $0xffffff9f,%edx
f01036f8:	83 ca 80             	or     $0xffffff80,%edx
f01036fb:	88 55 f3             	mov    %dl,-0xd(%ebp)
f01036fe:	88 50 2d             	mov    %dl,0x2d(%eax)
f0103701:	0f b6 48 2e          	movzbl 0x2e(%eax),%ecx
f0103705:	83 e1 c0             	and    $0xffffffc0,%ecx
f0103708:	83 c9 40             	or     $0x40,%ecx
f010370b:	83 e1 7f             	and    $0x7f,%ecx
f010370e:	88 48 2e             	mov    %cl,0x2e(%eax)
f0103711:	c1 ee 18             	shr    $0x18,%esi
f0103714:	89 f1                	mov    %esi,%ecx
f0103716:	88 48 2f             	mov    %cl,0x2f(%eax)
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103719:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
f010371d:	83 e2 ef             	and    $0xffffffef,%edx
f0103720:	88 50 2d             	mov    %dl,0x2d(%eax)
	asm volatile("ltr %0" : : "r" (sel));
f0103723:	b8 28 00 00 00       	mov    $0x28,%eax
f0103728:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f010372b:	8d 83 e8 1f 00 00    	lea    0x1fe8(%ebx),%eax
f0103731:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103734:	83 c4 04             	add    $0x4,%esp
f0103737:	5b                   	pop    %ebx
f0103738:	5e                   	pop    %esi
f0103739:	5f                   	pop    %edi
f010373a:	5d                   	pop    %ebp
f010373b:	c3                   	ret    

f010373c <trap_init>:
{
f010373c:	55                   	push   %ebp
f010373d:	89 e5                	mov    %esp,%ebp
	trap_init_percpu();
f010373f:	e8 59 ff ff ff       	call   f010369d <trap_init_percpu>
}
f0103744:	5d                   	pop    %ebp
f0103745:	c3                   	ret    

f0103746 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103746:	55                   	push   %ebp
f0103747:	89 e5                	mov    %esp,%ebp
f0103749:	56                   	push   %esi
f010374a:	53                   	push   %ebx
f010374b:	e8 17 ca ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103750:	81 c3 d0 78 08 00    	add    $0x878d0,%ebx
f0103756:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103759:	83 ec 08             	sub    $0x8,%esp
f010375c:	ff 36                	pushl  (%esi)
f010375e:	8d 83 98 ab f7 ff    	lea    -0x85468(%ebx),%eax
f0103764:	50                   	push   %eax
f0103765:	e8 1f ff ff ff       	call   f0103689 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010376a:	83 c4 08             	add    $0x8,%esp
f010376d:	ff 76 04             	pushl  0x4(%esi)
f0103770:	8d 83 a7 ab f7 ff    	lea    -0x85459(%ebx),%eax
f0103776:	50                   	push   %eax
f0103777:	e8 0d ff ff ff       	call   f0103689 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010377c:	83 c4 08             	add    $0x8,%esp
f010377f:	ff 76 08             	pushl  0x8(%esi)
f0103782:	8d 83 b6 ab f7 ff    	lea    -0x8544a(%ebx),%eax
f0103788:	50                   	push   %eax
f0103789:	e8 fb fe ff ff       	call   f0103689 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010378e:	83 c4 08             	add    $0x8,%esp
f0103791:	ff 76 0c             	pushl  0xc(%esi)
f0103794:	8d 83 c5 ab f7 ff    	lea    -0x8543b(%ebx),%eax
f010379a:	50                   	push   %eax
f010379b:	e8 e9 fe ff ff       	call   f0103689 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01037a0:	83 c4 08             	add    $0x8,%esp
f01037a3:	ff 76 10             	pushl  0x10(%esi)
f01037a6:	8d 83 d4 ab f7 ff    	lea    -0x8542c(%ebx),%eax
f01037ac:	50                   	push   %eax
f01037ad:	e8 d7 fe ff ff       	call   f0103689 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01037b2:	83 c4 08             	add    $0x8,%esp
f01037b5:	ff 76 14             	pushl  0x14(%esi)
f01037b8:	8d 83 e3 ab f7 ff    	lea    -0x8541d(%ebx),%eax
f01037be:	50                   	push   %eax
f01037bf:	e8 c5 fe ff ff       	call   f0103689 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01037c4:	83 c4 08             	add    $0x8,%esp
f01037c7:	ff 76 18             	pushl  0x18(%esi)
f01037ca:	8d 83 f2 ab f7 ff    	lea    -0x8540e(%ebx),%eax
f01037d0:	50                   	push   %eax
f01037d1:	e8 b3 fe ff ff       	call   f0103689 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01037d6:	83 c4 08             	add    $0x8,%esp
f01037d9:	ff 76 1c             	pushl  0x1c(%esi)
f01037dc:	8d 83 01 ac f7 ff    	lea    -0x853ff(%ebx),%eax
f01037e2:	50                   	push   %eax
f01037e3:	e8 a1 fe ff ff       	call   f0103689 <cprintf>
}
f01037e8:	83 c4 10             	add    $0x10,%esp
f01037eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01037ee:	5b                   	pop    %ebx
f01037ef:	5e                   	pop    %esi
f01037f0:	5d                   	pop    %ebp
f01037f1:	c3                   	ret    

f01037f2 <print_trapframe>:
{
f01037f2:	55                   	push   %ebp
f01037f3:	89 e5                	mov    %esp,%ebp
f01037f5:	57                   	push   %edi
f01037f6:	56                   	push   %esi
f01037f7:	53                   	push   %ebx
f01037f8:	83 ec 14             	sub    $0x14,%esp
f01037fb:	e8 67 c9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103800:	81 c3 20 78 08 00    	add    $0x87820,%ebx
f0103806:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("TRAP frame at %p\n", tf);
f0103809:	56                   	push   %esi
f010380a:	8d 83 37 ad f7 ff    	lea    -0x852c9(%ebx),%eax
f0103810:	50                   	push   %eax
f0103811:	e8 73 fe ff ff       	call   f0103689 <cprintf>
	print_regs(&tf->tf_regs);
f0103816:	89 34 24             	mov    %esi,(%esp)
f0103819:	e8 28 ff ff ff       	call   f0103746 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010381e:	83 c4 08             	add    $0x8,%esp
f0103821:	0f b7 46 20          	movzwl 0x20(%esi),%eax
f0103825:	50                   	push   %eax
f0103826:	8d 83 52 ac f7 ff    	lea    -0x853ae(%ebx),%eax
f010382c:	50                   	push   %eax
f010382d:	e8 57 fe ff ff       	call   f0103689 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103832:	83 c4 08             	add    $0x8,%esp
f0103835:	0f b7 46 24          	movzwl 0x24(%esi),%eax
f0103839:	50                   	push   %eax
f010383a:	8d 83 65 ac f7 ff    	lea    -0x8539b(%ebx),%eax
f0103840:	50                   	push   %eax
f0103841:	e8 43 fe ff ff       	call   f0103689 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103846:	8b 56 28             	mov    0x28(%esi),%edx
	if (trapno < ARRAY_SIZE(excnames))
f0103849:	83 c4 10             	add    $0x10,%esp
f010384c:	83 fa 13             	cmp    $0x13,%edx
f010384f:	0f 86 e9 00 00 00    	jbe    f010393e <print_trapframe+0x14c>
	return "(unknown trap)";
f0103855:	83 fa 30             	cmp    $0x30,%edx
f0103858:	8d 83 10 ac f7 ff    	lea    -0x853f0(%ebx),%eax
f010385e:	8d 8b 1c ac f7 ff    	lea    -0x853e4(%ebx),%ecx
f0103864:	0f 45 c1             	cmovne %ecx,%eax
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103867:	83 ec 04             	sub    $0x4,%esp
f010386a:	50                   	push   %eax
f010386b:	52                   	push   %edx
f010386c:	8d 83 78 ac f7 ff    	lea    -0x85388(%ebx),%eax
f0103872:	50                   	push   %eax
f0103873:	e8 11 fe ff ff       	call   f0103689 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103878:	83 c4 10             	add    $0x10,%esp
f010387b:	39 b3 40 2b 00 00    	cmp    %esi,0x2b40(%ebx)
f0103881:	0f 84 c3 00 00 00    	je     f010394a <print_trapframe+0x158>
	cprintf("  err  0x%08x", tf->tf_err);
f0103887:	83 ec 08             	sub    $0x8,%esp
f010388a:	ff 76 2c             	pushl  0x2c(%esi)
f010388d:	8d 83 99 ac f7 ff    	lea    -0x85367(%ebx),%eax
f0103893:	50                   	push   %eax
f0103894:	e8 f0 fd ff ff       	call   f0103689 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103899:	83 c4 10             	add    $0x10,%esp
f010389c:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f01038a0:	0f 85 c9 00 00 00    	jne    f010396f <print_trapframe+0x17d>
			tf->tf_err & 1 ? "protection" : "not-present");
f01038a6:	8b 46 2c             	mov    0x2c(%esi),%eax
		cprintf(" [%s, %s, %s]\n",
f01038a9:	89 c2                	mov    %eax,%edx
f01038ab:	83 e2 01             	and    $0x1,%edx
f01038ae:	8d 8b 2b ac f7 ff    	lea    -0x853d5(%ebx),%ecx
f01038b4:	8d 93 36 ac f7 ff    	lea    -0x853ca(%ebx),%edx
f01038ba:	0f 44 ca             	cmove  %edx,%ecx
f01038bd:	89 c2                	mov    %eax,%edx
f01038bf:	83 e2 02             	and    $0x2,%edx
f01038c2:	8d 93 42 ac f7 ff    	lea    -0x853be(%ebx),%edx
f01038c8:	8d bb 48 ac f7 ff    	lea    -0x853b8(%ebx),%edi
f01038ce:	0f 44 d7             	cmove  %edi,%edx
f01038d1:	83 e0 04             	and    $0x4,%eax
f01038d4:	8d 83 4d ac f7 ff    	lea    -0x853b3(%ebx),%eax
f01038da:	8d bb 62 ad f7 ff    	lea    -0x8529e(%ebx),%edi
f01038e0:	0f 44 c7             	cmove  %edi,%eax
f01038e3:	51                   	push   %ecx
f01038e4:	52                   	push   %edx
f01038e5:	50                   	push   %eax
f01038e6:	8d 83 a7 ac f7 ff    	lea    -0x85359(%ebx),%eax
f01038ec:	50                   	push   %eax
f01038ed:	e8 97 fd ff ff       	call   f0103689 <cprintf>
f01038f2:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01038f5:	83 ec 08             	sub    $0x8,%esp
f01038f8:	ff 76 30             	pushl  0x30(%esi)
f01038fb:	8d 83 b6 ac f7 ff    	lea    -0x8534a(%ebx),%eax
f0103901:	50                   	push   %eax
f0103902:	e8 82 fd ff ff       	call   f0103689 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103907:	83 c4 08             	add    $0x8,%esp
f010390a:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010390e:	50                   	push   %eax
f010390f:	8d 83 c5 ac f7 ff    	lea    -0x8533b(%ebx),%eax
f0103915:	50                   	push   %eax
f0103916:	e8 6e fd ff ff       	call   f0103689 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010391b:	83 c4 08             	add    $0x8,%esp
f010391e:	ff 76 38             	pushl  0x38(%esi)
f0103921:	8d 83 d8 ac f7 ff    	lea    -0x85328(%ebx),%eax
f0103927:	50                   	push   %eax
f0103928:	e8 5c fd ff ff       	call   f0103689 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010392d:	83 c4 10             	add    $0x10,%esp
f0103930:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0103934:	75 50                	jne    f0103986 <print_trapframe+0x194>
}
f0103936:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103939:	5b                   	pop    %ebx
f010393a:	5e                   	pop    %esi
f010393b:	5f                   	pop    %edi
f010393c:	5d                   	pop    %ebp
f010393d:	c3                   	ret    
		return excnames[trapno];
f010393e:	8b 84 93 60 20 00 00 	mov    0x2060(%ebx,%edx,4),%eax
f0103945:	e9 1d ff ff ff       	jmp    f0103867 <print_trapframe+0x75>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010394a:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f010394e:	0f 85 33 ff ff ff    	jne    f0103887 <print_trapframe+0x95>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103954:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103957:	83 ec 08             	sub    $0x8,%esp
f010395a:	50                   	push   %eax
f010395b:	8d 83 8a ac f7 ff    	lea    -0x85376(%ebx),%eax
f0103961:	50                   	push   %eax
f0103962:	e8 22 fd ff ff       	call   f0103689 <cprintf>
f0103967:	83 c4 10             	add    $0x10,%esp
f010396a:	e9 18 ff ff ff       	jmp    f0103887 <print_trapframe+0x95>
		cprintf("\n");
f010396f:	83 ec 0c             	sub    $0xc,%esp
f0103972:	8d 83 cf aa f7 ff    	lea    -0x85531(%ebx),%eax
f0103978:	50                   	push   %eax
f0103979:	e8 0b fd ff ff       	call   f0103689 <cprintf>
f010397e:	83 c4 10             	add    $0x10,%esp
f0103981:	e9 6f ff ff ff       	jmp    f01038f5 <print_trapframe+0x103>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103986:	83 ec 08             	sub    $0x8,%esp
f0103989:	ff 76 3c             	pushl  0x3c(%esi)
f010398c:	8d 83 e7 ac f7 ff    	lea    -0x85319(%ebx),%eax
f0103992:	50                   	push   %eax
f0103993:	e8 f1 fc ff ff       	call   f0103689 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103998:	83 c4 08             	add    $0x8,%esp
f010399b:	0f b7 46 40          	movzwl 0x40(%esi),%eax
f010399f:	50                   	push   %eax
f01039a0:	8d 83 f6 ac f7 ff    	lea    -0x8530a(%ebx),%eax
f01039a6:	50                   	push   %eax
f01039a7:	e8 dd fc ff ff       	call   f0103689 <cprintf>
f01039ac:	83 c4 10             	add    $0x10,%esp
}
f01039af:	eb 85                	jmp    f0103936 <print_trapframe+0x144>

f01039b1 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01039b1:	55                   	push   %ebp
f01039b2:	89 e5                	mov    %esp,%ebp
f01039b4:	57                   	push   %edi
f01039b5:	56                   	push   %esi
f01039b6:	53                   	push   %ebx
f01039b7:	83 ec 0c             	sub    $0xc,%esp
f01039ba:	e8 a8 c7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01039bf:	81 c3 61 76 08 00    	add    $0x87661,%ebx
f01039c5:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01039c8:	fc                   	cld    
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01039c9:	9c                   	pushf  
f01039ca:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01039cb:	f6 c4 02             	test   $0x2,%ah
f01039ce:	74 1f                	je     f01039ef <trap+0x3e>
f01039d0:	8d 83 09 ad f7 ff    	lea    -0x852f7(%ebx),%eax
f01039d6:	50                   	push   %eax
f01039d7:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f01039dd:	50                   	push   %eax
f01039de:	68 a8 00 00 00       	push   $0xa8
f01039e3:	8d 83 22 ad f7 ff    	lea    -0x852de(%ebx),%eax
f01039e9:	50                   	push   %eax
f01039ea:	e8 c2 c6 ff ff       	call   f01000b1 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f01039ef:	83 ec 08             	sub    $0x8,%esp
f01039f2:	56                   	push   %esi
f01039f3:	8d 83 2e ad f7 ff    	lea    -0x852d2(%ebx),%eax
f01039f9:	50                   	push   %eax
f01039fa:	e8 8a fc ff ff       	call   f0103689 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01039ff:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103a03:	83 e0 03             	and    $0x3,%eax
f0103a06:	83 c4 10             	add    $0x10,%esp
f0103a09:	66 83 f8 03          	cmp    $0x3,%ax
f0103a0d:	75 1d                	jne    f0103a2c <trap+0x7b>
		// Trapped from user mode.
		assert(curenv);
f0103a0f:	c7 c0 44 d3 18 f0    	mov    $0xf018d344,%eax
f0103a15:	8b 00                	mov    (%eax),%eax
f0103a17:	85 c0                	test   %eax,%eax
f0103a19:	74 68                	je     f0103a83 <trap+0xd2>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103a1b:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103a20:	89 c7                	mov    %eax,%edi
f0103a22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103a24:	c7 c0 44 d3 18 f0    	mov    $0xf018d344,%eax
f0103a2a:	8b 30                	mov    (%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103a2c:	89 b3 40 2b 00 00    	mov    %esi,0x2b40(%ebx)
	print_trapframe(tf);
f0103a32:	83 ec 0c             	sub    $0xc,%esp
f0103a35:	56                   	push   %esi
f0103a36:	e8 b7 fd ff ff       	call   f01037f2 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103a3b:	83 c4 10             	add    $0x10,%esp
f0103a3e:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103a43:	74 5d                	je     f0103aa2 <trap+0xf1>
		env_destroy(curenv);
f0103a45:	83 ec 0c             	sub    $0xc,%esp
f0103a48:	c7 c6 44 d3 18 f0    	mov    $0xf018d344,%esi
f0103a4e:	ff 36                	pushl  (%esi)
f0103a50:	e8 15 fb ff ff       	call   f010356a <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103a55:	8b 06                	mov    (%esi),%eax
f0103a57:	83 c4 10             	add    $0x10,%esp
f0103a5a:	85 c0                	test   %eax,%eax
f0103a5c:	74 06                	je     f0103a64 <trap+0xb3>
f0103a5e:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103a62:	74 59                	je     f0103abd <trap+0x10c>
f0103a64:	8d 83 ac ae f7 ff    	lea    -0x85154(%ebx),%eax
f0103a6a:	50                   	push   %eax
f0103a6b:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0103a71:	50                   	push   %eax
f0103a72:	68 c0 00 00 00       	push   $0xc0
f0103a77:	8d 83 22 ad f7 ff    	lea    -0x852de(%ebx),%eax
f0103a7d:	50                   	push   %eax
f0103a7e:	e8 2e c6 ff ff       	call   f01000b1 <_panic>
		assert(curenv);
f0103a83:	8d 83 49 ad f7 ff    	lea    -0x852b7(%ebx),%eax
f0103a89:	50                   	push   %eax
f0103a8a:	8d 83 9b a8 f7 ff    	lea    -0x85765(%ebx),%eax
f0103a90:	50                   	push   %eax
f0103a91:	68 ae 00 00 00       	push   $0xae
f0103a96:	8d 83 22 ad f7 ff    	lea    -0x852de(%ebx),%eax
f0103a9c:	50                   	push   %eax
f0103a9d:	e8 0f c6 ff ff       	call   f01000b1 <_panic>
		panic("unhandled trap in kernel");
f0103aa2:	83 ec 04             	sub    $0x4,%esp
f0103aa5:	8d 83 50 ad f7 ff    	lea    -0x852b0(%ebx),%eax
f0103aab:	50                   	push   %eax
f0103aac:	68 97 00 00 00       	push   $0x97
f0103ab1:	8d 83 22 ad f7 ff    	lea    -0x852de(%ebx),%eax
f0103ab7:	50                   	push   %eax
f0103ab8:	e8 f4 c5 ff ff       	call   f01000b1 <_panic>
	env_run(curenv);
f0103abd:	83 ec 0c             	sub    $0xc,%esp
f0103ac0:	50                   	push   %eax
f0103ac1:	e8 12 fb ff ff       	call   f01035d8 <env_run>

f0103ac6 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103ac6:	55                   	push   %ebp
f0103ac7:	89 e5                	mov    %esp,%ebp
f0103ac9:	57                   	push   %edi
f0103aca:	56                   	push   %esi
f0103acb:	53                   	push   %ebx
f0103acc:	83 ec 0c             	sub    $0xc,%esp
f0103acf:	e8 93 c6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103ad4:	81 c3 4c 75 08 00    	add    $0x8754c,%ebx
f0103ada:	8b 7d 08             	mov    0x8(%ebp),%edi
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103add:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ae0:	ff 77 30             	pushl  0x30(%edi)
f0103ae3:	50                   	push   %eax
f0103ae4:	c7 c6 44 d3 18 f0    	mov    $0xf018d344,%esi
f0103aea:	8b 06                	mov    (%esi),%eax
f0103aec:	ff 70 48             	pushl  0x48(%eax)
f0103aef:	8d 83 d8 ae f7 ff    	lea    -0x85128(%ebx),%eax
f0103af5:	50                   	push   %eax
f0103af6:	e8 8e fb ff ff       	call   f0103689 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103afb:	89 3c 24             	mov    %edi,(%esp)
f0103afe:	e8 ef fc ff ff       	call   f01037f2 <print_trapframe>
	env_destroy(curenv);
f0103b03:	83 c4 04             	add    $0x4,%esp
f0103b06:	ff 36                	pushl  (%esi)
f0103b08:	e8 5d fa ff ff       	call   f010356a <env_destroy>
}
f0103b0d:	83 c4 10             	add    $0x10,%esp
f0103b10:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103b13:	5b                   	pop    %ebx
f0103b14:	5e                   	pop    %esi
f0103b15:	5f                   	pop    %edi
f0103b16:	5d                   	pop    %ebp
f0103b17:	c3                   	ret    

f0103b18 <syscall>:
f0103b18:	55                   	push   %ebp
f0103b19:	89 e5                	mov    %esp,%ebp
f0103b1b:	53                   	push   %ebx
f0103b1c:	83 ec 08             	sub    $0x8,%esp
f0103b1f:	e8 43 c6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103b24:	81 c3 fc 74 08 00    	add    $0x874fc,%ebx
f0103b2a:	8d 83 fc ae f7 ff    	lea    -0x85104(%ebx),%eax
f0103b30:	50                   	push   %eax
f0103b31:	6a 49                	push   $0x49
f0103b33:	8d 83 14 af f7 ff    	lea    -0x850ec(%ebx),%eax
f0103b39:	50                   	push   %eax
f0103b3a:	e8 72 c5 ff ff       	call   f01000b1 <_panic>

f0103b3f <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
			   int type, uintptr_t addr)
{
f0103b3f:	55                   	push   %ebp
f0103b40:	89 e5                	mov    %esp,%ebp
f0103b42:	57                   	push   %edi
f0103b43:	56                   	push   %esi
f0103b44:	53                   	push   %ebx
f0103b45:	83 ec 14             	sub    $0x14,%esp
f0103b48:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103b4b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103b4e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103b51:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103b54:	8b 32                	mov    (%edx),%esi
f0103b56:	8b 01                	mov    (%ecx),%eax
f0103b58:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103b5b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r)
f0103b62:	eb 2f                	jmp    f0103b93 <stab_binsearch+0x54>
	{
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0103b64:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0103b67:	39 c6                	cmp    %eax,%esi
f0103b69:	7f 49                	jg     f0103bb4 <stab_binsearch+0x75>
f0103b6b:	0f b6 0a             	movzbl (%edx),%ecx
f0103b6e:	83 ea 0c             	sub    $0xc,%edx
f0103b71:	39 f9                	cmp    %edi,%ecx
f0103b73:	75 ef                	jne    f0103b64 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr)
f0103b75:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103b78:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103b7b:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103b7f:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103b82:	73 35                	jae    f0103bb9 <stab_binsearch+0x7a>
		{
			*region_left = m;
f0103b84:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103b87:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0103b89:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0103b8c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r)
f0103b93:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0103b96:	7f 4e                	jg     f0103be6 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0103b98:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103b9b:	01 f0                	add    %esi,%eax
f0103b9d:	89 c3                	mov    %eax,%ebx
f0103b9f:	c1 eb 1f             	shr    $0x1f,%ebx
f0103ba2:	01 c3                	add    %eax,%ebx
f0103ba4:	d1 fb                	sar    %ebx
f0103ba6:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103ba9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103bac:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0103bb0:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0103bb2:	eb b3                	jmp    f0103b67 <stab_binsearch+0x28>
			l = true_m + 1;
f0103bb4:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0103bb7:	eb da                	jmp    f0103b93 <stab_binsearch+0x54>
		}
		else if (stabs[m].n_value > addr)
f0103bb9:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103bbc:	76 14                	jbe    f0103bd2 <stab_binsearch+0x93>
		{
			*region_right = m - 1;
f0103bbe:	83 e8 01             	sub    $0x1,%eax
f0103bc1:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103bc4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103bc7:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0103bc9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103bd0:	eb c1                	jmp    f0103b93 <stab_binsearch+0x54>
		}
		else
		{
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103bd2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103bd5:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0103bd7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103bdb:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0103bdd:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103be4:	eb ad                	jmp    f0103b93 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0103be6:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103bea:	74 16                	je     f0103c02 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else
	{
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103bec:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103bef:	8b 00                	mov    (%eax),%eax
			 l > *region_left && stabs[l].n_type != type;
f0103bf1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103bf4:	8b 0e                	mov    (%esi),%ecx
f0103bf6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103bf9:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0103bfc:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0103c00:	eb 12                	jmp    f0103c14 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0103c02:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103c05:	8b 00                	mov    (%eax),%eax
f0103c07:	83 e8 01             	sub    $0x1,%eax
f0103c0a:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103c0d:	89 07                	mov    %eax,(%edi)
f0103c0f:	eb 16                	jmp    f0103c27 <stab_binsearch+0xe8>
			 l--)
f0103c11:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0103c14:	39 c1                	cmp    %eax,%ecx
f0103c16:	7d 0a                	jge    f0103c22 <stab_binsearch+0xe3>
			 l > *region_left && stabs[l].n_type != type;
f0103c18:	0f b6 1a             	movzbl (%edx),%ebx
f0103c1b:	83 ea 0c             	sub    $0xc,%edx
f0103c1e:	39 fb                	cmp    %edi,%ebx
f0103c20:	75 ef                	jne    f0103c11 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0103c22:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103c25:	89 07                	mov    %eax,(%edi)
	}
}
f0103c27:	83 c4 14             	add    $0x14,%esp
f0103c2a:	5b                   	pop    %ebx
f0103c2b:	5e                   	pop    %esi
f0103c2c:	5f                   	pop    %edi
f0103c2d:	5d                   	pop    %ebp
f0103c2e:	c3                   	ret    

f0103c2f <debuginfo_eip>:
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103c2f:	55                   	push   %ebp
f0103c30:	89 e5                	mov    %esp,%ebp
f0103c32:	57                   	push   %edi
f0103c33:	56                   	push   %esi
f0103c34:	53                   	push   %ebx
f0103c35:	83 ec 4c             	sub    $0x4c,%esp
f0103c38:	e8 1d f5 ff ff       	call   f010315a <__x86.get_pc_thunk.di>
f0103c3d:	81 c7 e3 73 08 00    	add    $0x873e3,%edi
f0103c43:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103c46:	8d 87 23 af f7 ff    	lea    -0x850dd(%edi),%eax
f0103c4c:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0103c4e:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0103c55:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0103c58:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0103c5f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c62:	89 46 10             	mov    %eax,0x10(%esi)
	info->eip_fn_narg = 0;
f0103c65:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM)
f0103c6c:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0103c71:	0f 87 28 01 00 00    	ja     f0103d9f <debuginfo_eip+0x170>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103c77:	a1 00 00 20 00       	mov    0x200000,%eax
f0103c7c:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stab_end = usd->stab_end;
f0103c7f:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0103c84:	8b 1d 08 00 20 00    	mov    0x200008,%ebx
f0103c8a:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0103c8d:	8b 1d 0c 00 20 00    	mov    0x20000c,%ebx
f0103c93:	89 5d bc             	mov    %ebx,-0x44(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103c96:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0103c99:	39 4d b4             	cmp    %ecx,-0x4c(%ebp)
f0103c9c:	0f 83 f2 01 00 00    	jae    f0103e94 <debuginfo_eip+0x265>
f0103ca2:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0103ca6:	0f 85 ef 01 00 00    	jne    f0103e9b <debuginfo_eip+0x26c>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103cac:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103cb3:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f0103cb6:	29 d8                	sub    %ebx,%eax
f0103cb8:	c1 f8 02             	sar    $0x2,%eax
f0103cbb:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0103cc1:	83 e8 01             	sub    $0x1,%eax
f0103cc4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103cc7:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103cca:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103ccd:	ff 75 08             	pushl  0x8(%ebp)
f0103cd0:	6a 64                	push   $0x64
f0103cd2:	89 d8                	mov    %ebx,%eax
f0103cd4:	e8 66 fe ff ff       	call   f0103b3f <stab_binsearch>
	if (lfile == 0)
f0103cd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103cdc:	83 c4 08             	add    $0x8,%esp
f0103cdf:	85 c0                	test   %eax,%eax
f0103ce1:	0f 84 bb 01 00 00    	je     f0103ea2 <debuginfo_eip+0x273>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103ce7:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103cea:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103ced:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103cf0:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103cf3:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103cf6:	ff 75 08             	pushl  0x8(%ebp)
f0103cf9:	6a 24                	push   $0x24
f0103cfb:	89 d8                	mov    %ebx,%eax
f0103cfd:	e8 3d fe ff ff       	call   f0103b3f <stab_binsearch>

	if (lfun <= rfun)
f0103d02:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103d05:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103d08:	83 c4 08             	add    $0x8,%esp
f0103d0b:	39 d0                	cmp    %edx,%eax
f0103d0d:	0f 8f b2 00 00 00    	jg     f0103dc5 <debuginfo_eip+0x196>
	{
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103d13:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0103d16:	8d 1c 8b             	lea    (%ebx,%ecx,4),%ebx
f0103d19:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0103d1c:	8b 0b                	mov    (%ebx),%ecx
f0103d1e:	89 cb                	mov    %ecx,%ebx
f0103d20:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0103d23:	2b 4d b4             	sub    -0x4c(%ebp),%ecx
f0103d26:	39 cb                	cmp    %ecx,%ebx
f0103d28:	73 06                	jae    f0103d30 <debuginfo_eip+0x101>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103d2a:	03 5d b4             	add    -0x4c(%ebp),%ebx
f0103d2d:	89 5e 08             	mov    %ebx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103d30:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0103d33:	8b 4b 08             	mov    0x8(%ebx),%ecx
f0103d36:	89 4e 10             	mov    %ecx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0103d39:	29 4d 08             	sub    %ecx,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0103d3c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103d3f:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103d42:	83 ec 08             	sub    $0x8,%esp
f0103d45:	6a 3a                	push   $0x3a
f0103d47:	ff 76 08             	pushl  0x8(%esi)
f0103d4a:	89 fb                	mov    %edi,%ebx
f0103d4c:	e8 ce 09 00 00       	call   f010471f <strfind>
f0103d51:	2b 46 08             	sub    0x8(%esi),%eax
f0103d54:	89 46 0c             	mov    %eax,0xc(%esi)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr); // 根据%eip的值作为地址查找
f0103d57:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103d5a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103d5d:	83 c4 08             	add    $0x8,%esp
f0103d60:	ff 75 08             	pushl  0x8(%ebp)
f0103d63:	6a 44                	push   $0x44
f0103d65:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0103d68:	89 f8                	mov    %edi,%eax
f0103d6a:	e8 d0 fd ff ff       	call   f0103b3f <stab_binsearch>
	if (lline <= rline)									  // 二分查找，left<=right即终止
f0103d6f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103d72:	83 c4 10             	add    $0x10,%esp
f0103d75:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0103d78:	7f 62                	jg     f0103ddc <debuginfo_eip+0x1ad>
	{
		info->eip_line = stabs[lline].n_desc;
f0103d7a:	89 d0                	mov    %edx,%eax
f0103d7c:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103d7f:	c1 e2 02             	shl    $0x2,%edx
f0103d82:	0f b7 4c 17 06       	movzwl 0x6(%edi,%edx,1),%ecx
f0103d87:	89 4e 04             	mov    %ecx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile && stabs[lline].n_type != N_SOL && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103d8a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103d8d:	8d 54 17 04          	lea    0x4(%edi,%edx,1),%edx
f0103d91:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0103d95:	bf 01 00 00 00       	mov    $0x1,%edi
f0103d9a:	89 75 0c             	mov    %esi,0xc(%ebp)
f0103d9d:	eb 59                	jmp    f0103df8 <debuginfo_eip+0x1c9>
		stabstr_end = __STABSTR_END__;
f0103d9f:	c7 c0 74 0b 11 f0    	mov    $0xf0110b74,%eax
f0103da5:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0103da8:	c7 c0 99 e1 10 f0    	mov    $0xf010e199,%eax
f0103dae:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0103db1:	c7 c0 98 e1 10 f0    	mov    $0xf010e198,%eax
		stabs = __STAB_BEGIN__;
f0103db7:	c7 c3 40 61 10 f0    	mov    $0xf0106140,%ebx
f0103dbd:	89 5d b8             	mov    %ebx,-0x48(%ebp)
f0103dc0:	e9 d1 fe ff ff       	jmp    f0103c96 <debuginfo_eip+0x67>
		info->eip_fn_addr = addr;
f0103dc5:	8b 45 08             	mov    0x8(%ebp),%eax
f0103dc8:	89 46 10             	mov    %eax,0x10(%esi)
		lline = lfile;
f0103dcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103dce:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103dd1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103dd4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103dd7:	e9 66 ff ff ff       	jmp    f0103d42 <debuginfo_eip+0x113>
		info->eip_line = 0;
f0103ddc:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
		return -1;
f0103de3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103de8:	e9 c1 00 00 00       	jmp    f0103eae <debuginfo_eip+0x27f>
f0103ded:	83 e8 01             	sub    $0x1,%eax
f0103df0:	83 ea 0c             	sub    $0xc,%edx
f0103df3:	89 f9                	mov    %edi,%ecx
f0103df5:	88 4d c4             	mov    %cl,-0x3c(%ebp)
f0103df8:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile && stabs[lline].n_type != N_SOL && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103dfb:	39 c3                	cmp    %eax,%ebx
f0103dfd:	7f 24                	jg     f0103e23 <debuginfo_eip+0x1f4>
f0103dff:	0f b6 0a             	movzbl (%edx),%ecx
f0103e02:	80 f9 84             	cmp    $0x84,%cl
f0103e05:	74 42                	je     f0103e49 <debuginfo_eip+0x21a>
f0103e07:	80 f9 64             	cmp    $0x64,%cl
f0103e0a:	75 e1                	jne    f0103ded <debuginfo_eip+0x1be>
f0103e0c:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0103e10:	74 db                	je     f0103ded <debuginfo_eip+0x1be>
f0103e12:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103e15:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103e19:	74 37                	je     f0103e52 <debuginfo_eip+0x223>
f0103e1b:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103e1e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103e21:	eb 2f                	jmp    f0103e52 <debuginfo_eip+0x223>
f0103e23:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103e26:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103e29:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
			 lline < rfun && stabs[lline].n_type == N_PSYM;
			 lline++)
			info->eip_fn_narg++;

	return 0;
f0103e2c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0103e31:	39 da                	cmp    %ebx,%edx
f0103e33:	7d 79                	jge    f0103eae <debuginfo_eip+0x27f>
		for (lline = lfun + 1;
f0103e35:	83 c2 01             	add    $0x1,%edx
f0103e38:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103e3b:	89 d0                	mov    %edx,%eax
f0103e3d:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103e40:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0103e43:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0103e47:	eb 32                	jmp    f0103e7b <debuginfo_eip+0x24c>
f0103e49:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103e4c:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103e50:	75 1d                	jne    f0103e6f <debuginfo_eip+0x240>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103e52:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103e55:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0103e58:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103e5b:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0103e5e:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0103e61:	29 f8                	sub    %edi,%eax
f0103e63:	39 c2                	cmp    %eax,%edx
f0103e65:	73 bf                	jae    f0103e26 <debuginfo_eip+0x1f7>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103e67:	89 f8                	mov    %edi,%eax
f0103e69:	01 d0                	add    %edx,%eax
f0103e6b:	89 06                	mov    %eax,(%esi)
f0103e6d:	eb b7                	jmp    f0103e26 <debuginfo_eip+0x1f7>
f0103e6f:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103e72:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103e75:	eb db                	jmp    f0103e52 <debuginfo_eip+0x223>
			info->eip_fn_narg++;
f0103e77:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0103e7b:	39 c3                	cmp    %eax,%ebx
f0103e7d:	7e 2a                	jle    f0103ea9 <debuginfo_eip+0x27a>
			 lline < rfun && stabs[lline].n_type == N_PSYM;
f0103e7f:	0f b6 0a             	movzbl (%edx),%ecx
f0103e82:	83 c0 01             	add    $0x1,%eax
f0103e85:	83 c2 0c             	add    $0xc,%edx
f0103e88:	80 f9 a0             	cmp    $0xa0,%cl
f0103e8b:	74 ea                	je     f0103e77 <debuginfo_eip+0x248>
	return 0;
f0103e8d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e92:	eb 1a                	jmp    f0103eae <debuginfo_eip+0x27f>
		return -1;
f0103e94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103e99:	eb 13                	jmp    f0103eae <debuginfo_eip+0x27f>
f0103e9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ea0:	eb 0c                	jmp    f0103eae <debuginfo_eip+0x27f>
		return -1;
f0103ea2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ea7:	eb 05                	jmp    f0103eae <debuginfo_eip+0x27f>
	return 0;
f0103ea9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103eae:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103eb1:	5b                   	pop    %ebx
f0103eb2:	5e                   	pop    %esi
f0103eb3:	5f                   	pop    %edi
f0103eb4:	5d                   	pop    %ebp
f0103eb5:	c3                   	ret    

f0103eb6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
f0103eb6:	55                   	push   %ebp
f0103eb7:	89 e5                	mov    %esp,%ebp
f0103eb9:	57                   	push   %edi
f0103eba:	56                   	push   %esi
f0103ebb:	53                   	push   %ebx
f0103ebc:	83 ec 2c             	sub    $0x2c,%esp
f0103ebf:	e8 8e f2 ff ff       	call   f0103152 <__x86.get_pc_thunk.cx>
f0103ec4:	81 c1 5c 71 08 00    	add    $0x8715c,%ecx
f0103eca:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0103ecd:	89 c7                	mov    %eax,%edi
f0103ecf:	89 d6                	mov    %edx,%esi
f0103ed1:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ed4:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103ed7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103eda:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
f0103edd:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103ee0:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103ee5:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0103ee8:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0103eeb:	39 d3                	cmp    %edx,%ebx
f0103eed:	72 09                	jb     f0103ef8 <printnum+0x42>
f0103eef:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103ef2:	0f 87 83 00 00 00    	ja     f0103f7b <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103ef8:	83 ec 0c             	sub    $0xc,%esp
f0103efb:	ff 75 18             	pushl  0x18(%ebp)
f0103efe:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f01:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0103f04:	53                   	push   %ebx
f0103f05:	ff 75 10             	pushl  0x10(%ebp)
f0103f08:	83 ec 08             	sub    $0x8,%esp
f0103f0b:	ff 75 dc             	pushl  -0x24(%ebp)
f0103f0e:	ff 75 d8             	pushl  -0x28(%ebp)
f0103f11:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103f14:	ff 75 d0             	pushl  -0x30(%ebp)
f0103f17:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103f1a:	e8 21 0a 00 00       	call   f0104940 <__udivdi3>
f0103f1f:	83 c4 18             	add    $0x18,%esp
f0103f22:	52                   	push   %edx
f0103f23:	50                   	push   %eax
f0103f24:	89 f2                	mov    %esi,%edx
f0103f26:	89 f8                	mov    %edi,%eax
f0103f28:	e8 89 ff ff ff       	call   f0103eb6 <printnum>
f0103f2d:	83 c4 20             	add    $0x20,%esp
f0103f30:	eb 13                	jmp    f0103f45 <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103f32:	83 ec 08             	sub    $0x8,%esp
f0103f35:	56                   	push   %esi
f0103f36:	ff 75 18             	pushl  0x18(%ebp)
f0103f39:	ff d7                	call   *%edi
f0103f3b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0103f3e:	83 eb 01             	sub    $0x1,%ebx
f0103f41:	85 db                	test   %ebx,%ebx
f0103f43:	7f ed                	jg     f0103f32 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103f45:	83 ec 08             	sub    $0x8,%esp
f0103f48:	56                   	push   %esi
f0103f49:	83 ec 04             	sub    $0x4,%esp
f0103f4c:	ff 75 dc             	pushl  -0x24(%ebp)
f0103f4f:	ff 75 d8             	pushl  -0x28(%ebp)
f0103f52:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103f55:	ff 75 d0             	pushl  -0x30(%ebp)
f0103f58:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103f5b:	89 f3                	mov    %esi,%ebx
f0103f5d:	e8 fe 0a 00 00       	call   f0104a60 <__umoddi3>
f0103f62:	83 c4 14             	add    $0x14,%esp
f0103f65:	0f be 84 06 2d af f7 	movsbl -0x850d3(%esi,%eax,1),%eax
f0103f6c:	ff 
f0103f6d:	50                   	push   %eax
f0103f6e:	ff d7                	call   *%edi
}
f0103f70:	83 c4 10             	add    $0x10,%esp
f0103f73:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f76:	5b                   	pop    %ebx
f0103f77:	5e                   	pop    %esi
f0103f78:	5f                   	pop    %edi
f0103f79:	5d                   	pop    %ebp
f0103f7a:	c3                   	ret    
f0103f7b:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103f7e:	eb be                	jmp    f0103f3e <printnum+0x88>

f0103f80 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103f80:	55                   	push   %ebp
f0103f81:	89 e5                	mov    %esp,%ebp
f0103f83:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103f86:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103f8a:	8b 10                	mov    (%eax),%edx
f0103f8c:	3b 50 04             	cmp    0x4(%eax),%edx
f0103f8f:	73 0a                	jae    f0103f9b <sprintputch+0x1b>
		*b->buf++ = ch;
f0103f91:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103f94:	89 08                	mov    %ecx,(%eax)
f0103f96:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f99:	88 02                	mov    %al,(%edx)
}
f0103f9b:	5d                   	pop    %ebp
f0103f9c:	c3                   	ret    

f0103f9d <printfmt>:
{
f0103f9d:	55                   	push   %ebp
f0103f9e:	89 e5                	mov    %esp,%ebp
f0103fa0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0103fa3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103fa6:	50                   	push   %eax
f0103fa7:	ff 75 10             	pushl  0x10(%ebp)
f0103faa:	ff 75 0c             	pushl  0xc(%ebp)
f0103fad:	ff 75 08             	pushl  0x8(%ebp)
f0103fb0:	e8 05 00 00 00       	call   f0103fba <vprintfmt>
}
f0103fb5:	83 c4 10             	add    $0x10,%esp
f0103fb8:	c9                   	leave  
f0103fb9:	c3                   	ret    

f0103fba <vprintfmt>:
{
f0103fba:	55                   	push   %ebp
f0103fbb:	89 e5                	mov    %esp,%ebp
f0103fbd:	57                   	push   %edi
f0103fbe:	56                   	push   %esi
f0103fbf:	53                   	push   %ebx
f0103fc0:	83 ec 2c             	sub    $0x2c,%esp
f0103fc3:	e8 9f c1 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103fc8:	81 c3 58 70 08 00    	add    $0x87058,%ebx
f0103fce:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103fd1:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103fd4:	e9 c3 03 00 00       	jmp    f010439c <.L35+0x48>
		padc = ' ';
f0103fd9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0103fdd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0103fe4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f0103feb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0103ff2:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103ff7:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f0103ffa:	8d 47 01             	lea    0x1(%edi),%eax
f0103ffd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104000:	0f b6 17             	movzbl (%edi),%edx
f0104003:	8d 42 dd             	lea    -0x23(%edx),%eax
f0104006:	3c 55                	cmp    $0x55,%al
f0104008:	0f 87 16 04 00 00    	ja     f0104424 <.L22>
f010400e:	0f b6 c0             	movzbl %al,%eax
f0104011:	89 d9                	mov    %ebx,%ecx
f0104013:	03 8c 83 b8 af f7 ff 	add    -0x85048(%ebx,%eax,4),%ecx
f010401a:	ff e1                	jmp    *%ecx

f010401c <.L69>:
f010401c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f010401f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0104023:	eb d5                	jmp    f0103ffa <vprintfmt+0x40>

f0104025 <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f0104025:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0104028:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f010402c:	eb cc                	jmp    f0103ffa <vprintfmt+0x40>

f010402e <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f010402e:	0f b6 d2             	movzbl %dl,%edx
f0104031:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
f0104034:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f0104039:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010403c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104040:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0104043:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104046:	83 f9 09             	cmp    $0x9,%ecx
f0104049:	77 55                	ja     f01040a0 <.L23+0xf>
			for (precision = 0;; ++fmt)
f010404b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f010404e:	eb e9                	jmp    f0104039 <.L29+0xb>

f0104050 <.L26>:
			precision = va_arg(ap, int);
f0104050:	8b 45 14             	mov    0x14(%ebp),%eax
f0104053:	8b 00                	mov    (%eax),%eax
f0104055:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104058:	8b 45 14             	mov    0x14(%ebp),%eax
f010405b:	8d 40 04             	lea    0x4(%eax),%eax
f010405e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f0104061:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0104064:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104068:	79 90                	jns    f0103ffa <vprintfmt+0x40>
				width = precision, precision = -1;
f010406a:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010406d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104070:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0104077:	eb 81                	jmp    f0103ffa <vprintfmt+0x40>

f0104079 <.L27>:
f0104079:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010407c:	85 c0                	test   %eax,%eax
f010407e:	ba 00 00 00 00       	mov    $0x0,%edx
f0104083:	0f 49 d0             	cmovns %eax,%edx
f0104086:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f0104089:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010408c:	e9 69 ff ff ff       	jmp    f0103ffa <vprintfmt+0x40>

f0104091 <.L23>:
f0104091:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0104094:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010409b:	e9 5a ff ff ff       	jmp    f0103ffa <vprintfmt+0x40>
f01040a0:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01040a3:	eb bf                	jmp    f0104064 <.L26+0x14>

f01040a5 <.L33>:
			lflag++;
f01040a5:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
f01040a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01040ac:	e9 49 ff ff ff       	jmp    f0103ffa <vprintfmt+0x40>

f01040b1 <.L30>:
			putch(va_arg(ap, int), putdat);
f01040b1:	8b 45 14             	mov    0x14(%ebp),%eax
f01040b4:	8d 78 04             	lea    0x4(%eax),%edi
f01040b7:	83 ec 08             	sub    $0x8,%esp
f01040ba:	56                   	push   %esi
f01040bb:	ff 30                	pushl  (%eax)
f01040bd:	ff 55 08             	call   *0x8(%ebp)
			break;
f01040c0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01040c3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01040c6:	e9 ce 02 00 00       	jmp    f0104399 <.L35+0x45>

f01040cb <.L32>:
			err = va_arg(ap, int);
f01040cb:	8b 45 14             	mov    0x14(%ebp),%eax
f01040ce:	8d 78 04             	lea    0x4(%eax),%edi
f01040d1:	8b 00                	mov    (%eax),%eax
f01040d3:	99                   	cltd   
f01040d4:	31 d0                	xor    %edx,%eax
f01040d6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01040d8:	83 f8 06             	cmp    $0x6,%eax
f01040db:	7f 27                	jg     f0104104 <.L32+0x39>
f01040dd:	8b 94 83 b0 20 00 00 	mov    0x20b0(%ebx,%eax,4),%edx
f01040e4:	85 d2                	test   %edx,%edx
f01040e6:	74 1c                	je     f0104104 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f01040e8:	52                   	push   %edx
f01040e9:	8d 83 ad a8 f7 ff    	lea    -0x85753(%ebx),%eax
f01040ef:	50                   	push   %eax
f01040f0:	56                   	push   %esi
f01040f1:	ff 75 08             	pushl  0x8(%ebp)
f01040f4:	e8 a4 fe ff ff       	call   f0103f9d <printfmt>
f01040f9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01040fc:	89 7d 14             	mov    %edi,0x14(%ebp)
f01040ff:	e9 95 02 00 00       	jmp    f0104399 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
f0104104:	50                   	push   %eax
f0104105:	8d 83 45 af f7 ff    	lea    -0x850bb(%ebx),%eax
f010410b:	50                   	push   %eax
f010410c:	56                   	push   %esi
f010410d:	ff 75 08             	pushl  0x8(%ebp)
f0104110:	e8 88 fe ff ff       	call   f0103f9d <printfmt>
f0104115:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104118:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010411b:	e9 79 02 00 00       	jmp    f0104399 <.L35+0x45>

f0104120 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f0104120:	8b 45 14             	mov    0x14(%ebp),%eax
f0104123:	83 c0 04             	add    $0x4,%eax
f0104126:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104129:	8b 45 14             	mov    0x14(%ebp),%eax
f010412c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f010412e:	85 ff                	test   %edi,%edi
f0104130:	8d 83 3e af f7 ff    	lea    -0x850c2(%ebx),%eax
f0104136:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104139:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010413d:	0f 8e b5 00 00 00    	jle    f01041f8 <.L36+0xd8>
f0104143:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104147:	75 08                	jne    f0104151 <.L36+0x31>
f0104149:	89 75 0c             	mov    %esi,0xc(%ebp)
f010414c:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010414f:	eb 6d                	jmp    f01041be <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104151:	83 ec 08             	sub    $0x8,%esp
f0104154:	ff 75 cc             	pushl  -0x34(%ebp)
f0104157:	57                   	push   %edi
f0104158:	e8 7e 04 00 00       	call   f01045db <strnlen>
f010415d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104160:	29 c2                	sub    %eax,%edx
f0104162:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0104165:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104168:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010416c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010416f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104172:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0104174:	eb 10                	jmp    f0104186 <.L36+0x66>
					putch(padc, putdat);
f0104176:	83 ec 08             	sub    $0x8,%esp
f0104179:	56                   	push   %esi
f010417a:	ff 75 e0             	pushl  -0x20(%ebp)
f010417d:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0104180:	83 ef 01             	sub    $0x1,%edi
f0104183:	83 c4 10             	add    $0x10,%esp
f0104186:	85 ff                	test   %edi,%edi
f0104188:	7f ec                	jg     f0104176 <.L36+0x56>
f010418a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010418d:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0104190:	85 d2                	test   %edx,%edx
f0104192:	b8 00 00 00 00       	mov    $0x0,%eax
f0104197:	0f 49 c2             	cmovns %edx,%eax
f010419a:	29 c2                	sub    %eax,%edx
f010419c:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010419f:	89 75 0c             	mov    %esi,0xc(%ebp)
f01041a2:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01041a5:	eb 17                	jmp    f01041be <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f01041a7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01041ab:	75 30                	jne    f01041dd <.L36+0xbd>
					putch(ch, putdat);
f01041ad:	83 ec 08             	sub    $0x8,%esp
f01041b0:	ff 75 0c             	pushl  0xc(%ebp)
f01041b3:	50                   	push   %eax
f01041b4:	ff 55 08             	call   *0x8(%ebp)
f01041b7:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01041ba:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f01041be:	83 c7 01             	add    $0x1,%edi
f01041c1:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f01041c5:	0f be c2             	movsbl %dl,%eax
f01041c8:	85 c0                	test   %eax,%eax
f01041ca:	74 52                	je     f010421e <.L36+0xfe>
f01041cc:	85 f6                	test   %esi,%esi
f01041ce:	78 d7                	js     f01041a7 <.L36+0x87>
f01041d0:	83 ee 01             	sub    $0x1,%esi
f01041d3:	79 d2                	jns    f01041a7 <.L36+0x87>
f01041d5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01041d8:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01041db:	eb 32                	jmp    f010420f <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f01041dd:	0f be d2             	movsbl %dl,%edx
f01041e0:	83 ea 20             	sub    $0x20,%edx
f01041e3:	83 fa 5e             	cmp    $0x5e,%edx
f01041e6:	76 c5                	jbe    f01041ad <.L36+0x8d>
					putch('?', putdat);
f01041e8:	83 ec 08             	sub    $0x8,%esp
f01041eb:	ff 75 0c             	pushl  0xc(%ebp)
f01041ee:	6a 3f                	push   $0x3f
f01041f0:	ff 55 08             	call   *0x8(%ebp)
f01041f3:	83 c4 10             	add    $0x10,%esp
f01041f6:	eb c2                	jmp    f01041ba <.L36+0x9a>
f01041f8:	89 75 0c             	mov    %esi,0xc(%ebp)
f01041fb:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01041fe:	eb be                	jmp    f01041be <.L36+0x9e>
				putch(' ', putdat);
f0104200:	83 ec 08             	sub    $0x8,%esp
f0104203:	56                   	push   %esi
f0104204:	6a 20                	push   $0x20
f0104206:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f0104209:	83 ef 01             	sub    $0x1,%edi
f010420c:	83 c4 10             	add    $0x10,%esp
f010420f:	85 ff                	test   %edi,%edi
f0104211:	7f ed                	jg     f0104200 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f0104213:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104216:	89 45 14             	mov    %eax,0x14(%ebp)
f0104219:	e9 7b 01 00 00       	jmp    f0104399 <.L35+0x45>
f010421e:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104221:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104224:	eb e9                	jmp    f010420f <.L36+0xef>

f0104226 <.L31>:
f0104226:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0104229:	83 f9 01             	cmp    $0x1,%ecx
f010422c:	7e 40                	jle    f010426e <.L31+0x48>
		return va_arg(*ap, long long);
f010422e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104231:	8b 50 04             	mov    0x4(%eax),%edx
f0104234:	8b 00                	mov    (%eax),%eax
f0104236:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104239:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010423c:	8b 45 14             	mov    0x14(%ebp),%eax
f010423f:	8d 40 08             	lea    0x8(%eax),%eax
f0104242:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
f0104245:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104249:	79 55                	jns    f01042a0 <.L31+0x7a>
				putch('-', putdat);
f010424b:	83 ec 08             	sub    $0x8,%esp
f010424e:	56                   	push   %esi
f010424f:	6a 2d                	push   $0x2d
f0104251:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
f0104254:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104257:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010425a:	f7 da                	neg    %edx
f010425c:	83 d1 00             	adc    $0x0,%ecx
f010425f:	f7 d9                	neg    %ecx
f0104261:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
f0104264:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104269:	e9 10 01 00 00       	jmp    f010437e <.L35+0x2a>
	else if (lflag)
f010426e:	85 c9                	test   %ecx,%ecx
f0104270:	75 17                	jne    f0104289 <.L31+0x63>
		return va_arg(*ap, int);
f0104272:	8b 45 14             	mov    0x14(%ebp),%eax
f0104275:	8b 00                	mov    (%eax),%eax
f0104277:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010427a:	99                   	cltd   
f010427b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010427e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104281:	8d 40 04             	lea    0x4(%eax),%eax
f0104284:	89 45 14             	mov    %eax,0x14(%ebp)
f0104287:	eb bc                	jmp    f0104245 <.L31+0x1f>
		return va_arg(*ap, long);
f0104289:	8b 45 14             	mov    0x14(%ebp),%eax
f010428c:	8b 00                	mov    (%eax),%eax
f010428e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104291:	99                   	cltd   
f0104292:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104295:	8b 45 14             	mov    0x14(%ebp),%eax
f0104298:	8d 40 04             	lea    0x4(%eax),%eax
f010429b:	89 45 14             	mov    %eax,0x14(%ebp)
f010429e:	eb a5                	jmp    f0104245 <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
f01042a0:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01042a3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
f01042a6:	b8 0a 00 00 00       	mov    $0xa,%eax
f01042ab:	e9 ce 00 00 00       	jmp    f010437e <.L35+0x2a>

f01042b0 <.L37>:
f01042b0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01042b3:	83 f9 01             	cmp    $0x1,%ecx
f01042b6:	7e 18                	jle    f01042d0 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
f01042b8:	8b 45 14             	mov    0x14(%ebp),%eax
f01042bb:	8b 10                	mov    (%eax),%edx
f01042bd:	8b 48 04             	mov    0x4(%eax),%ecx
f01042c0:	8d 40 08             	lea    0x8(%eax),%eax
f01042c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01042c6:	b8 0a 00 00 00       	mov    $0xa,%eax
f01042cb:	e9 ae 00 00 00       	jmp    f010437e <.L35+0x2a>
	else if (lflag)
f01042d0:	85 c9                	test   %ecx,%ecx
f01042d2:	75 1a                	jne    f01042ee <.L37+0x3e>
		return va_arg(*ap, unsigned int);
f01042d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01042d7:	8b 10                	mov    (%eax),%edx
f01042d9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01042de:	8d 40 04             	lea    0x4(%eax),%eax
f01042e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01042e4:	b8 0a 00 00 00       	mov    $0xa,%eax
f01042e9:	e9 90 00 00 00       	jmp    f010437e <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f01042ee:	8b 45 14             	mov    0x14(%ebp),%eax
f01042f1:	8b 10                	mov    (%eax),%edx
f01042f3:	b9 00 00 00 00       	mov    $0x0,%ecx
f01042f8:	8d 40 04             	lea    0x4(%eax),%eax
f01042fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01042fe:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104303:	eb 79                	jmp    f010437e <.L35+0x2a>

f0104305 <.L34>:
f0104305:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0104308:	83 f9 01             	cmp    $0x1,%ecx
f010430b:	7e 15                	jle    f0104322 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
f010430d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104310:	8b 10                	mov    (%eax),%edx
f0104312:	8b 48 04             	mov    0x4(%eax),%ecx
f0104315:	8d 40 08             	lea    0x8(%eax),%eax
f0104318:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010431b:	b8 08 00 00 00       	mov    $0x8,%eax
f0104320:	eb 5c                	jmp    f010437e <.L35+0x2a>
	else if (lflag)
f0104322:	85 c9                	test   %ecx,%ecx
f0104324:	75 17                	jne    f010433d <.L34+0x38>
		return va_arg(*ap, unsigned int);
f0104326:	8b 45 14             	mov    0x14(%ebp),%eax
f0104329:	8b 10                	mov    (%eax),%edx
f010432b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104330:	8d 40 04             	lea    0x4(%eax),%eax
f0104333:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0104336:	b8 08 00 00 00       	mov    $0x8,%eax
f010433b:	eb 41                	jmp    f010437e <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f010433d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104340:	8b 10                	mov    (%eax),%edx
f0104342:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104347:	8d 40 04             	lea    0x4(%eax),%eax
f010434a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010434d:	b8 08 00 00 00       	mov    $0x8,%eax
f0104352:	eb 2a                	jmp    f010437e <.L35+0x2a>

f0104354 <.L35>:
			putch('0', putdat);
f0104354:	83 ec 08             	sub    $0x8,%esp
f0104357:	56                   	push   %esi
f0104358:	6a 30                	push   $0x30
f010435a:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f010435d:	83 c4 08             	add    $0x8,%esp
f0104360:	56                   	push   %esi
f0104361:	6a 78                	push   $0x78
f0104363:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
f0104366:	8b 45 14             	mov    0x14(%ebp),%eax
f0104369:	8b 10                	mov    (%eax),%edx
f010436b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0104370:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
f0104373:	8d 40 04             	lea    0x4(%eax),%eax
f0104376:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104379:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
f010437e:	83 ec 0c             	sub    $0xc,%esp
f0104381:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0104385:	57                   	push   %edi
f0104386:	ff 75 e0             	pushl  -0x20(%ebp)
f0104389:	50                   	push   %eax
f010438a:	51                   	push   %ecx
f010438b:	52                   	push   %edx
f010438c:	89 f2                	mov    %esi,%edx
f010438e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104391:	e8 20 fb ff ff       	call   f0103eb6 <printnum>
			break;
f0104396:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0104399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
f010439c:	83 c7 01             	add    $0x1,%edi
f010439f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01043a3:	83 f8 25             	cmp    $0x25,%eax
f01043a6:	0f 84 2d fc ff ff    	je     f0103fd9 <vprintfmt+0x1f>
			if (ch == '\0')
f01043ac:	85 c0                	test   %eax,%eax
f01043ae:	0f 84 91 00 00 00    	je     f0104445 <.L22+0x21>
			putch(ch, putdat);
f01043b4:	83 ec 08             	sub    $0x8,%esp
f01043b7:	56                   	push   %esi
f01043b8:	50                   	push   %eax
f01043b9:	ff 55 08             	call   *0x8(%ebp)
f01043bc:	83 c4 10             	add    $0x10,%esp
f01043bf:	eb db                	jmp    f010439c <.L35+0x48>

f01043c1 <.L38>:
f01043c1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01043c4:	83 f9 01             	cmp    $0x1,%ecx
f01043c7:	7e 15                	jle    f01043de <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
f01043c9:	8b 45 14             	mov    0x14(%ebp),%eax
f01043cc:	8b 10                	mov    (%eax),%edx
f01043ce:	8b 48 04             	mov    0x4(%eax),%ecx
f01043d1:	8d 40 08             	lea    0x8(%eax),%eax
f01043d4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01043d7:	b8 10 00 00 00       	mov    $0x10,%eax
f01043dc:	eb a0                	jmp    f010437e <.L35+0x2a>
	else if (lflag)
f01043de:	85 c9                	test   %ecx,%ecx
f01043e0:	75 17                	jne    f01043f9 <.L38+0x38>
		return va_arg(*ap, unsigned int);
f01043e2:	8b 45 14             	mov    0x14(%ebp),%eax
f01043e5:	8b 10                	mov    (%eax),%edx
f01043e7:	b9 00 00 00 00       	mov    $0x0,%ecx
f01043ec:	8d 40 04             	lea    0x4(%eax),%eax
f01043ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01043f2:	b8 10 00 00 00       	mov    $0x10,%eax
f01043f7:	eb 85                	jmp    f010437e <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f01043f9:	8b 45 14             	mov    0x14(%ebp),%eax
f01043fc:	8b 10                	mov    (%eax),%edx
f01043fe:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104403:	8d 40 04             	lea    0x4(%eax),%eax
f0104406:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104409:	b8 10 00 00 00       	mov    $0x10,%eax
f010440e:	e9 6b ff ff ff       	jmp    f010437e <.L35+0x2a>

f0104413 <.L25>:
			putch(ch, putdat);
f0104413:	83 ec 08             	sub    $0x8,%esp
f0104416:	56                   	push   %esi
f0104417:	6a 25                	push   $0x25
f0104419:	ff 55 08             	call   *0x8(%ebp)
			break;
f010441c:	83 c4 10             	add    $0x10,%esp
f010441f:	e9 75 ff ff ff       	jmp    f0104399 <.L35+0x45>

f0104424 <.L22>:
			putch('%', putdat);
f0104424:	83 ec 08             	sub    $0x8,%esp
f0104427:	56                   	push   %esi
f0104428:	6a 25                	push   $0x25
f010442a:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010442d:	83 c4 10             	add    $0x10,%esp
f0104430:	89 f8                	mov    %edi,%eax
f0104432:	eb 03                	jmp    f0104437 <.L22+0x13>
f0104434:	83 e8 01             	sub    $0x1,%eax
f0104437:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010443b:	75 f7                	jne    f0104434 <.L22+0x10>
f010443d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104440:	e9 54 ff ff ff       	jmp    f0104399 <.L35+0x45>
}
f0104445:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104448:	5b                   	pop    %ebx
f0104449:	5e                   	pop    %esi
f010444a:	5f                   	pop    %edi
f010444b:	5d                   	pop    %ebp
f010444c:	c3                   	ret    

f010444d <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010444d:	55                   	push   %ebp
f010444e:	89 e5                	mov    %esp,%ebp
f0104450:	53                   	push   %ebx
f0104451:	83 ec 14             	sub    $0x14,%esp
f0104454:	e8 0e bd ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104459:	81 c3 c7 6b 08 00    	add    $0x86bc7,%ebx
f010445f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104462:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
f0104465:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104468:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010446c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010446f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104476:	85 c0                	test   %eax,%eax
f0104478:	74 2b                	je     f01044a5 <vsnprintf+0x58>
f010447a:	85 d2                	test   %edx,%edx
f010447c:	7e 27                	jle    f01044a5 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
f010447e:	ff 75 14             	pushl  0x14(%ebp)
f0104481:	ff 75 10             	pushl  0x10(%ebp)
f0104484:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104487:	50                   	push   %eax
f0104488:	8d 83 60 8f f7 ff    	lea    -0x870a0(%ebx),%eax
f010448e:	50                   	push   %eax
f010448f:	e8 26 fb ff ff       	call   f0103fba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104494:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104497:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010449a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010449d:	83 c4 10             	add    $0x10,%esp
}
f01044a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01044a3:	c9                   	leave  
f01044a4:	c3                   	ret    
		return -E_INVAL;
f01044a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01044aa:	eb f4                	jmp    f01044a0 <vsnprintf+0x53>

f01044ac <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
f01044ac:	55                   	push   %ebp
f01044ad:	89 e5                	mov    %esp,%ebp
f01044af:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01044b2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01044b5:	50                   	push   %eax
f01044b6:	ff 75 10             	pushl  0x10(%ebp)
f01044b9:	ff 75 0c             	pushl  0xc(%ebp)
f01044bc:	ff 75 08             	pushl  0x8(%ebp)
f01044bf:	e8 89 ff ff ff       	call   f010444d <vsnprintf>
	va_end(ap);

	return rc;
}
f01044c4:	c9                   	leave  
f01044c5:	c3                   	ret    

f01044c6 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01044c6:	55                   	push   %ebp
f01044c7:	89 e5                	mov    %esp,%ebp
f01044c9:	57                   	push   %edi
f01044ca:	56                   	push   %esi
f01044cb:	53                   	push   %ebx
f01044cc:	83 ec 1c             	sub    $0x1c,%esp
f01044cf:	e8 93 bc ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01044d4:	81 c3 4c 6b 08 00    	add    $0x86b4c,%ebx
f01044da:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01044dd:	85 c0                	test   %eax,%eax
f01044df:	74 13                	je     f01044f4 <readline+0x2e>
		cprintf("%s", prompt);
f01044e1:	83 ec 08             	sub    $0x8,%esp
f01044e4:	50                   	push   %eax
f01044e5:	8d 83 ad a8 f7 ff    	lea    -0x85753(%ebx),%eax
f01044eb:	50                   	push   %eax
f01044ec:	e8 98 f1 ff ff       	call   f0103689 <cprintf>
f01044f1:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01044f4:	83 ec 0c             	sub    $0xc,%esp
f01044f7:	6a 00                	push   $0x0
f01044f9:	e8 01 c2 ff ff       	call   f01006ff <iscons>
f01044fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104501:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0104504:	bf 00 00 00 00       	mov    $0x0,%edi
f0104509:	eb 46                	jmp    f0104551 <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f010450b:	83 ec 08             	sub    $0x8,%esp
f010450e:	50                   	push   %eax
f010450f:	8d 83 10 b1 f7 ff    	lea    -0x84ef0(%ebx),%eax
f0104515:	50                   	push   %eax
f0104516:	e8 6e f1 ff ff       	call   f0103689 <cprintf>
			return NULL;
f010451b:	83 c4 10             	add    $0x10,%esp
f010451e:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0104523:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104526:	5b                   	pop    %ebx
f0104527:	5e                   	pop    %esi
f0104528:	5f                   	pop    %edi
f0104529:	5d                   	pop    %ebp
f010452a:	c3                   	ret    
			if (echoing)
f010452b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010452f:	75 05                	jne    f0104536 <readline+0x70>
			i--;
f0104531:	83 ef 01             	sub    $0x1,%edi
f0104534:	eb 1b                	jmp    f0104551 <readline+0x8b>
				cputchar('\b');
f0104536:	83 ec 0c             	sub    $0xc,%esp
f0104539:	6a 08                	push   $0x8
f010453b:	e8 9e c1 ff ff       	call   f01006de <cputchar>
f0104540:	83 c4 10             	add    $0x10,%esp
f0104543:	eb ec                	jmp    f0104531 <readline+0x6b>
			buf[i++] = c;
f0104545:	89 f0                	mov    %esi,%eax
f0104547:	88 84 3b e0 2b 00 00 	mov    %al,0x2be0(%ebx,%edi,1)
f010454e:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0104551:	e8 98 c1 ff ff       	call   f01006ee <getchar>
f0104556:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0104558:	85 c0                	test   %eax,%eax
f010455a:	78 af                	js     f010450b <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010455c:	83 f8 08             	cmp    $0x8,%eax
f010455f:	0f 94 c2             	sete   %dl
f0104562:	83 f8 7f             	cmp    $0x7f,%eax
f0104565:	0f 94 c0             	sete   %al
f0104568:	08 c2                	or     %al,%dl
f010456a:	74 04                	je     f0104570 <readline+0xaa>
f010456c:	85 ff                	test   %edi,%edi
f010456e:	7f bb                	jg     f010452b <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104570:	83 fe 1f             	cmp    $0x1f,%esi
f0104573:	7e 1c                	jle    f0104591 <readline+0xcb>
f0104575:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f010457b:	7f 14                	jg     f0104591 <readline+0xcb>
			if (echoing)
f010457d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104581:	74 c2                	je     f0104545 <readline+0x7f>
				cputchar(c);
f0104583:	83 ec 0c             	sub    $0xc,%esp
f0104586:	56                   	push   %esi
f0104587:	e8 52 c1 ff ff       	call   f01006de <cputchar>
f010458c:	83 c4 10             	add    $0x10,%esp
f010458f:	eb b4                	jmp    f0104545 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f0104591:	83 fe 0a             	cmp    $0xa,%esi
f0104594:	74 05                	je     f010459b <readline+0xd5>
f0104596:	83 fe 0d             	cmp    $0xd,%esi
f0104599:	75 b6                	jne    f0104551 <readline+0x8b>
			if (echoing)
f010459b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010459f:	75 13                	jne    f01045b4 <readline+0xee>
			buf[i] = 0;
f01045a1:	c6 84 3b e0 2b 00 00 	movb   $0x0,0x2be0(%ebx,%edi,1)
f01045a8:	00 
			return buf;
f01045a9:	8d 83 e0 2b 00 00    	lea    0x2be0(%ebx),%eax
f01045af:	e9 6f ff ff ff       	jmp    f0104523 <readline+0x5d>
				cputchar('\n');
f01045b4:	83 ec 0c             	sub    $0xc,%esp
f01045b7:	6a 0a                	push   $0xa
f01045b9:	e8 20 c1 ff ff       	call   f01006de <cputchar>
f01045be:	83 c4 10             	add    $0x10,%esp
f01045c1:	eb de                	jmp    f01045a1 <readline+0xdb>

f01045c3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01045c3:	55                   	push   %ebp
f01045c4:	89 e5                	mov    %esp,%ebp
f01045c6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01045c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01045ce:	eb 03                	jmp    f01045d3 <strlen+0x10>
		n++;
f01045d0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f01045d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01045d7:	75 f7                	jne    f01045d0 <strlen+0xd>
	return n;
}
f01045d9:	5d                   	pop    %ebp
f01045da:	c3                   	ret    

f01045db <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01045db:	55                   	push   %ebp
f01045dc:	89 e5                	mov    %esp,%ebp
f01045de:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01045e1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01045e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01045e9:	eb 03                	jmp    f01045ee <strnlen+0x13>
		n++;
f01045eb:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01045ee:	39 d0                	cmp    %edx,%eax
f01045f0:	74 06                	je     f01045f8 <strnlen+0x1d>
f01045f2:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01045f6:	75 f3                	jne    f01045eb <strnlen+0x10>
	return n;
}
f01045f8:	5d                   	pop    %ebp
f01045f9:	c3                   	ret    

f01045fa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01045fa:	55                   	push   %ebp
f01045fb:	89 e5                	mov    %esp,%ebp
f01045fd:	53                   	push   %ebx
f01045fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0104601:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104604:	89 c2                	mov    %eax,%edx
f0104606:	83 c1 01             	add    $0x1,%ecx
f0104609:	83 c2 01             	add    $0x1,%edx
f010460c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0104610:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104613:	84 db                	test   %bl,%bl
f0104615:	75 ef                	jne    f0104606 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104617:	5b                   	pop    %ebx
f0104618:	5d                   	pop    %ebp
f0104619:	c3                   	ret    

f010461a <strcat>:

char *
strcat(char *dst, const char *src)
{
f010461a:	55                   	push   %ebp
f010461b:	89 e5                	mov    %esp,%ebp
f010461d:	53                   	push   %ebx
f010461e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104621:	53                   	push   %ebx
f0104622:	e8 9c ff ff ff       	call   f01045c3 <strlen>
f0104627:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010462a:	ff 75 0c             	pushl  0xc(%ebp)
f010462d:	01 d8                	add    %ebx,%eax
f010462f:	50                   	push   %eax
f0104630:	e8 c5 ff ff ff       	call   f01045fa <strcpy>
	return dst;
}
f0104635:	89 d8                	mov    %ebx,%eax
f0104637:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010463a:	c9                   	leave  
f010463b:	c3                   	ret    

f010463c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010463c:	55                   	push   %ebp
f010463d:	89 e5                	mov    %esp,%ebp
f010463f:	56                   	push   %esi
f0104640:	53                   	push   %ebx
f0104641:	8b 75 08             	mov    0x8(%ebp),%esi
f0104644:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104647:	89 f3                	mov    %esi,%ebx
f0104649:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010464c:	89 f2                	mov    %esi,%edx
f010464e:	eb 0f                	jmp    f010465f <strncpy+0x23>
		*dst++ = *src;
f0104650:	83 c2 01             	add    $0x1,%edx
f0104653:	0f b6 01             	movzbl (%ecx),%eax
f0104656:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104659:	80 39 01             	cmpb   $0x1,(%ecx)
f010465c:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f010465f:	39 da                	cmp    %ebx,%edx
f0104661:	75 ed                	jne    f0104650 <strncpy+0x14>
	}
	return ret;
}
f0104663:	89 f0                	mov    %esi,%eax
f0104665:	5b                   	pop    %ebx
f0104666:	5e                   	pop    %esi
f0104667:	5d                   	pop    %ebp
f0104668:	c3                   	ret    

f0104669 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104669:	55                   	push   %ebp
f010466a:	89 e5                	mov    %esp,%ebp
f010466c:	56                   	push   %esi
f010466d:	53                   	push   %ebx
f010466e:	8b 75 08             	mov    0x8(%ebp),%esi
f0104671:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104674:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104677:	89 f0                	mov    %esi,%eax
f0104679:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010467d:	85 c9                	test   %ecx,%ecx
f010467f:	75 0b                	jne    f010468c <strlcpy+0x23>
f0104681:	eb 17                	jmp    f010469a <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104683:	83 c2 01             	add    $0x1,%edx
f0104686:	83 c0 01             	add    $0x1,%eax
f0104689:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f010468c:	39 d8                	cmp    %ebx,%eax
f010468e:	74 07                	je     f0104697 <strlcpy+0x2e>
f0104690:	0f b6 0a             	movzbl (%edx),%ecx
f0104693:	84 c9                	test   %cl,%cl
f0104695:	75 ec                	jne    f0104683 <strlcpy+0x1a>
		*dst = '\0';
f0104697:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010469a:	29 f0                	sub    %esi,%eax
}
f010469c:	5b                   	pop    %ebx
f010469d:	5e                   	pop    %esi
f010469e:	5d                   	pop    %ebp
f010469f:	c3                   	ret    

f01046a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01046a0:	55                   	push   %ebp
f01046a1:	89 e5                	mov    %esp,%ebp
f01046a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01046a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01046a9:	eb 06                	jmp    f01046b1 <strcmp+0x11>
		p++, q++;
f01046ab:	83 c1 01             	add    $0x1,%ecx
f01046ae:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01046b1:	0f b6 01             	movzbl (%ecx),%eax
f01046b4:	84 c0                	test   %al,%al
f01046b6:	74 04                	je     f01046bc <strcmp+0x1c>
f01046b8:	3a 02                	cmp    (%edx),%al
f01046ba:	74 ef                	je     f01046ab <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01046bc:	0f b6 c0             	movzbl %al,%eax
f01046bf:	0f b6 12             	movzbl (%edx),%edx
f01046c2:	29 d0                	sub    %edx,%eax
}
f01046c4:	5d                   	pop    %ebp
f01046c5:	c3                   	ret    

f01046c6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01046c6:	55                   	push   %ebp
f01046c7:	89 e5                	mov    %esp,%ebp
f01046c9:	53                   	push   %ebx
f01046ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01046cd:	8b 55 0c             	mov    0xc(%ebp),%edx
f01046d0:	89 c3                	mov    %eax,%ebx
f01046d2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01046d5:	eb 06                	jmp    f01046dd <strncmp+0x17>
		n--, p++, q++;
f01046d7:	83 c0 01             	add    $0x1,%eax
f01046da:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01046dd:	39 d8                	cmp    %ebx,%eax
f01046df:	74 16                	je     f01046f7 <strncmp+0x31>
f01046e1:	0f b6 08             	movzbl (%eax),%ecx
f01046e4:	84 c9                	test   %cl,%cl
f01046e6:	74 04                	je     f01046ec <strncmp+0x26>
f01046e8:	3a 0a                	cmp    (%edx),%cl
f01046ea:	74 eb                	je     f01046d7 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01046ec:	0f b6 00             	movzbl (%eax),%eax
f01046ef:	0f b6 12             	movzbl (%edx),%edx
f01046f2:	29 d0                	sub    %edx,%eax
}
f01046f4:	5b                   	pop    %ebx
f01046f5:	5d                   	pop    %ebp
f01046f6:	c3                   	ret    
		return 0;
f01046f7:	b8 00 00 00 00       	mov    $0x0,%eax
f01046fc:	eb f6                	jmp    f01046f4 <strncmp+0x2e>

f01046fe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01046fe:	55                   	push   %ebp
f01046ff:	89 e5                	mov    %esp,%ebp
f0104701:	8b 45 08             	mov    0x8(%ebp),%eax
f0104704:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104708:	0f b6 10             	movzbl (%eax),%edx
f010470b:	84 d2                	test   %dl,%dl
f010470d:	74 09                	je     f0104718 <strchr+0x1a>
		if (*s == c)
f010470f:	38 ca                	cmp    %cl,%dl
f0104711:	74 0a                	je     f010471d <strchr+0x1f>
	for (; *s; s++)
f0104713:	83 c0 01             	add    $0x1,%eax
f0104716:	eb f0                	jmp    f0104708 <strchr+0xa>
			return (char *) s;
	return 0;
f0104718:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010471d:	5d                   	pop    %ebp
f010471e:	c3                   	ret    

f010471f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010471f:	55                   	push   %ebp
f0104720:	89 e5                	mov    %esp,%ebp
f0104722:	8b 45 08             	mov    0x8(%ebp),%eax
f0104725:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104729:	eb 03                	jmp    f010472e <strfind+0xf>
f010472b:	83 c0 01             	add    $0x1,%eax
f010472e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0104731:	38 ca                	cmp    %cl,%dl
f0104733:	74 04                	je     f0104739 <strfind+0x1a>
f0104735:	84 d2                	test   %dl,%dl
f0104737:	75 f2                	jne    f010472b <strfind+0xc>
			break;
	return (char *) s;
}
f0104739:	5d                   	pop    %ebp
f010473a:	c3                   	ret    

f010473b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010473b:	55                   	push   %ebp
f010473c:	89 e5                	mov    %esp,%ebp
f010473e:	57                   	push   %edi
f010473f:	56                   	push   %esi
f0104740:	53                   	push   %ebx
f0104741:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104744:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104747:	85 c9                	test   %ecx,%ecx
f0104749:	74 13                	je     f010475e <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010474b:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104751:	75 05                	jne    f0104758 <memset+0x1d>
f0104753:	f6 c1 03             	test   $0x3,%cl
f0104756:	74 0d                	je     f0104765 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104758:	8b 45 0c             	mov    0xc(%ebp),%eax
f010475b:	fc                   	cld    
f010475c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010475e:	89 f8                	mov    %edi,%eax
f0104760:	5b                   	pop    %ebx
f0104761:	5e                   	pop    %esi
f0104762:	5f                   	pop    %edi
f0104763:	5d                   	pop    %ebp
f0104764:	c3                   	ret    
		c &= 0xFF;
f0104765:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104769:	89 d3                	mov    %edx,%ebx
f010476b:	c1 e3 08             	shl    $0x8,%ebx
f010476e:	89 d0                	mov    %edx,%eax
f0104770:	c1 e0 18             	shl    $0x18,%eax
f0104773:	89 d6                	mov    %edx,%esi
f0104775:	c1 e6 10             	shl    $0x10,%esi
f0104778:	09 f0                	or     %esi,%eax
f010477a:	09 c2                	or     %eax,%edx
f010477c:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f010477e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0104781:	89 d0                	mov    %edx,%eax
f0104783:	fc                   	cld    
f0104784:	f3 ab                	rep stos %eax,%es:(%edi)
f0104786:	eb d6                	jmp    f010475e <memset+0x23>

f0104788 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104788:	55                   	push   %ebp
f0104789:	89 e5                	mov    %esp,%ebp
f010478b:	57                   	push   %edi
f010478c:	56                   	push   %esi
f010478d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104790:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104793:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104796:	39 c6                	cmp    %eax,%esi
f0104798:	73 35                	jae    f01047cf <memmove+0x47>
f010479a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010479d:	39 c2                	cmp    %eax,%edx
f010479f:	76 2e                	jbe    f01047cf <memmove+0x47>
		s += n;
		d += n;
f01047a1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01047a4:	89 d6                	mov    %edx,%esi
f01047a6:	09 fe                	or     %edi,%esi
f01047a8:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01047ae:	74 0c                	je     f01047bc <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01047b0:	83 ef 01             	sub    $0x1,%edi
f01047b3:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01047b6:	fd                   	std    
f01047b7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01047b9:	fc                   	cld    
f01047ba:	eb 21                	jmp    f01047dd <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01047bc:	f6 c1 03             	test   $0x3,%cl
f01047bf:	75 ef                	jne    f01047b0 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01047c1:	83 ef 04             	sub    $0x4,%edi
f01047c4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01047c7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01047ca:	fd                   	std    
f01047cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01047cd:	eb ea                	jmp    f01047b9 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01047cf:	89 f2                	mov    %esi,%edx
f01047d1:	09 c2                	or     %eax,%edx
f01047d3:	f6 c2 03             	test   $0x3,%dl
f01047d6:	74 09                	je     f01047e1 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01047d8:	89 c7                	mov    %eax,%edi
f01047da:	fc                   	cld    
f01047db:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01047dd:	5e                   	pop    %esi
f01047de:	5f                   	pop    %edi
f01047df:	5d                   	pop    %ebp
f01047e0:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01047e1:	f6 c1 03             	test   $0x3,%cl
f01047e4:	75 f2                	jne    f01047d8 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01047e6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01047e9:	89 c7                	mov    %eax,%edi
f01047eb:	fc                   	cld    
f01047ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01047ee:	eb ed                	jmp    f01047dd <memmove+0x55>

f01047f0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01047f0:	55                   	push   %ebp
f01047f1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01047f3:	ff 75 10             	pushl  0x10(%ebp)
f01047f6:	ff 75 0c             	pushl  0xc(%ebp)
f01047f9:	ff 75 08             	pushl  0x8(%ebp)
f01047fc:	e8 87 ff ff ff       	call   f0104788 <memmove>
}
f0104801:	c9                   	leave  
f0104802:	c3                   	ret    

f0104803 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104803:	55                   	push   %ebp
f0104804:	89 e5                	mov    %esp,%ebp
f0104806:	56                   	push   %esi
f0104807:	53                   	push   %ebx
f0104808:	8b 45 08             	mov    0x8(%ebp),%eax
f010480b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010480e:	89 c6                	mov    %eax,%esi
f0104810:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104813:	39 f0                	cmp    %esi,%eax
f0104815:	74 1c                	je     f0104833 <memcmp+0x30>
		if (*s1 != *s2)
f0104817:	0f b6 08             	movzbl (%eax),%ecx
f010481a:	0f b6 1a             	movzbl (%edx),%ebx
f010481d:	38 d9                	cmp    %bl,%cl
f010481f:	75 08                	jne    f0104829 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0104821:	83 c0 01             	add    $0x1,%eax
f0104824:	83 c2 01             	add    $0x1,%edx
f0104827:	eb ea                	jmp    f0104813 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0104829:	0f b6 c1             	movzbl %cl,%eax
f010482c:	0f b6 db             	movzbl %bl,%ebx
f010482f:	29 d8                	sub    %ebx,%eax
f0104831:	eb 05                	jmp    f0104838 <memcmp+0x35>
	}

	return 0;
f0104833:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104838:	5b                   	pop    %ebx
f0104839:	5e                   	pop    %esi
f010483a:	5d                   	pop    %ebp
f010483b:	c3                   	ret    

f010483c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010483c:	55                   	push   %ebp
f010483d:	89 e5                	mov    %esp,%ebp
f010483f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104842:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104845:	89 c2                	mov    %eax,%edx
f0104847:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010484a:	39 d0                	cmp    %edx,%eax
f010484c:	73 09                	jae    f0104857 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f010484e:	38 08                	cmp    %cl,(%eax)
f0104850:	74 05                	je     f0104857 <memfind+0x1b>
	for (; s < ends; s++)
f0104852:	83 c0 01             	add    $0x1,%eax
f0104855:	eb f3                	jmp    f010484a <memfind+0xe>
			break;
	return (void *) s;
}
f0104857:	5d                   	pop    %ebp
f0104858:	c3                   	ret    

f0104859 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104859:	55                   	push   %ebp
f010485a:	89 e5                	mov    %esp,%ebp
f010485c:	57                   	push   %edi
f010485d:	56                   	push   %esi
f010485e:	53                   	push   %ebx
f010485f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104862:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104865:	eb 03                	jmp    f010486a <strtol+0x11>
		s++;
f0104867:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f010486a:	0f b6 01             	movzbl (%ecx),%eax
f010486d:	3c 20                	cmp    $0x20,%al
f010486f:	74 f6                	je     f0104867 <strtol+0xe>
f0104871:	3c 09                	cmp    $0x9,%al
f0104873:	74 f2                	je     f0104867 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0104875:	3c 2b                	cmp    $0x2b,%al
f0104877:	74 2e                	je     f01048a7 <strtol+0x4e>
	int neg = 0;
f0104879:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f010487e:	3c 2d                	cmp    $0x2d,%al
f0104880:	74 2f                	je     f01048b1 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104882:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0104888:	75 05                	jne    f010488f <strtol+0x36>
f010488a:	80 39 30             	cmpb   $0x30,(%ecx)
f010488d:	74 2c                	je     f01048bb <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010488f:	85 db                	test   %ebx,%ebx
f0104891:	75 0a                	jne    f010489d <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104893:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f0104898:	80 39 30             	cmpb   $0x30,(%ecx)
f010489b:	74 28                	je     f01048c5 <strtol+0x6c>
		base = 10;
f010489d:	b8 00 00 00 00       	mov    $0x0,%eax
f01048a2:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01048a5:	eb 50                	jmp    f01048f7 <strtol+0x9e>
		s++;
f01048a7:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01048aa:	bf 00 00 00 00       	mov    $0x0,%edi
f01048af:	eb d1                	jmp    f0104882 <strtol+0x29>
		s++, neg = 1;
f01048b1:	83 c1 01             	add    $0x1,%ecx
f01048b4:	bf 01 00 00 00       	mov    $0x1,%edi
f01048b9:	eb c7                	jmp    f0104882 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01048bb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01048bf:	74 0e                	je     f01048cf <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01048c1:	85 db                	test   %ebx,%ebx
f01048c3:	75 d8                	jne    f010489d <strtol+0x44>
		s++, base = 8;
f01048c5:	83 c1 01             	add    $0x1,%ecx
f01048c8:	bb 08 00 00 00       	mov    $0x8,%ebx
f01048cd:	eb ce                	jmp    f010489d <strtol+0x44>
		s += 2, base = 16;
f01048cf:	83 c1 02             	add    $0x2,%ecx
f01048d2:	bb 10 00 00 00       	mov    $0x10,%ebx
f01048d7:	eb c4                	jmp    f010489d <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01048d9:	8d 72 9f             	lea    -0x61(%edx),%esi
f01048dc:	89 f3                	mov    %esi,%ebx
f01048de:	80 fb 19             	cmp    $0x19,%bl
f01048e1:	77 29                	ja     f010490c <strtol+0xb3>
			dig = *s - 'a' + 10;
f01048e3:	0f be d2             	movsbl %dl,%edx
f01048e6:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01048e9:	3b 55 10             	cmp    0x10(%ebp),%edx
f01048ec:	7d 30                	jge    f010491e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01048ee:	83 c1 01             	add    $0x1,%ecx
f01048f1:	0f af 45 10          	imul   0x10(%ebp),%eax
f01048f5:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01048f7:	0f b6 11             	movzbl (%ecx),%edx
f01048fa:	8d 72 d0             	lea    -0x30(%edx),%esi
f01048fd:	89 f3                	mov    %esi,%ebx
f01048ff:	80 fb 09             	cmp    $0x9,%bl
f0104902:	77 d5                	ja     f01048d9 <strtol+0x80>
			dig = *s - '0';
f0104904:	0f be d2             	movsbl %dl,%edx
f0104907:	83 ea 30             	sub    $0x30,%edx
f010490a:	eb dd                	jmp    f01048e9 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f010490c:	8d 72 bf             	lea    -0x41(%edx),%esi
f010490f:	89 f3                	mov    %esi,%ebx
f0104911:	80 fb 19             	cmp    $0x19,%bl
f0104914:	77 08                	ja     f010491e <strtol+0xc5>
			dig = *s - 'A' + 10;
f0104916:	0f be d2             	movsbl %dl,%edx
f0104919:	83 ea 37             	sub    $0x37,%edx
f010491c:	eb cb                	jmp    f01048e9 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f010491e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104922:	74 05                	je     f0104929 <strtol+0xd0>
		*endptr = (char *) s;
f0104924:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104927:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0104929:	89 c2                	mov    %eax,%edx
f010492b:	f7 da                	neg    %edx
f010492d:	85 ff                	test   %edi,%edi
f010492f:	0f 45 c2             	cmovne %edx,%eax
}
f0104932:	5b                   	pop    %ebx
f0104933:	5e                   	pop    %esi
f0104934:	5f                   	pop    %edi
f0104935:	5d                   	pop    %ebp
f0104936:	c3                   	ret    
f0104937:	66 90                	xchg   %ax,%ax
f0104939:	66 90                	xchg   %ax,%ax
f010493b:	66 90                	xchg   %ax,%ax
f010493d:	66 90                	xchg   %ax,%ax
f010493f:	90                   	nop

f0104940 <__udivdi3>:
f0104940:	55                   	push   %ebp
f0104941:	57                   	push   %edi
f0104942:	56                   	push   %esi
f0104943:	53                   	push   %ebx
f0104944:	83 ec 1c             	sub    $0x1c,%esp
f0104947:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010494b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010494f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0104953:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0104957:	85 d2                	test   %edx,%edx
f0104959:	75 35                	jne    f0104990 <__udivdi3+0x50>
f010495b:	39 f3                	cmp    %esi,%ebx
f010495d:	0f 87 bd 00 00 00    	ja     f0104a20 <__udivdi3+0xe0>
f0104963:	85 db                	test   %ebx,%ebx
f0104965:	89 d9                	mov    %ebx,%ecx
f0104967:	75 0b                	jne    f0104974 <__udivdi3+0x34>
f0104969:	b8 01 00 00 00       	mov    $0x1,%eax
f010496e:	31 d2                	xor    %edx,%edx
f0104970:	f7 f3                	div    %ebx
f0104972:	89 c1                	mov    %eax,%ecx
f0104974:	31 d2                	xor    %edx,%edx
f0104976:	89 f0                	mov    %esi,%eax
f0104978:	f7 f1                	div    %ecx
f010497a:	89 c6                	mov    %eax,%esi
f010497c:	89 e8                	mov    %ebp,%eax
f010497e:	89 f7                	mov    %esi,%edi
f0104980:	f7 f1                	div    %ecx
f0104982:	89 fa                	mov    %edi,%edx
f0104984:	83 c4 1c             	add    $0x1c,%esp
f0104987:	5b                   	pop    %ebx
f0104988:	5e                   	pop    %esi
f0104989:	5f                   	pop    %edi
f010498a:	5d                   	pop    %ebp
f010498b:	c3                   	ret    
f010498c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104990:	39 f2                	cmp    %esi,%edx
f0104992:	77 7c                	ja     f0104a10 <__udivdi3+0xd0>
f0104994:	0f bd fa             	bsr    %edx,%edi
f0104997:	83 f7 1f             	xor    $0x1f,%edi
f010499a:	0f 84 98 00 00 00    	je     f0104a38 <__udivdi3+0xf8>
f01049a0:	89 f9                	mov    %edi,%ecx
f01049a2:	b8 20 00 00 00       	mov    $0x20,%eax
f01049a7:	29 f8                	sub    %edi,%eax
f01049a9:	d3 e2                	shl    %cl,%edx
f01049ab:	89 54 24 08          	mov    %edx,0x8(%esp)
f01049af:	89 c1                	mov    %eax,%ecx
f01049b1:	89 da                	mov    %ebx,%edx
f01049b3:	d3 ea                	shr    %cl,%edx
f01049b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01049b9:	09 d1                	or     %edx,%ecx
f01049bb:	89 f2                	mov    %esi,%edx
f01049bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01049c1:	89 f9                	mov    %edi,%ecx
f01049c3:	d3 e3                	shl    %cl,%ebx
f01049c5:	89 c1                	mov    %eax,%ecx
f01049c7:	d3 ea                	shr    %cl,%edx
f01049c9:	89 f9                	mov    %edi,%ecx
f01049cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01049cf:	d3 e6                	shl    %cl,%esi
f01049d1:	89 eb                	mov    %ebp,%ebx
f01049d3:	89 c1                	mov    %eax,%ecx
f01049d5:	d3 eb                	shr    %cl,%ebx
f01049d7:	09 de                	or     %ebx,%esi
f01049d9:	89 f0                	mov    %esi,%eax
f01049db:	f7 74 24 08          	divl   0x8(%esp)
f01049df:	89 d6                	mov    %edx,%esi
f01049e1:	89 c3                	mov    %eax,%ebx
f01049e3:	f7 64 24 0c          	mull   0xc(%esp)
f01049e7:	39 d6                	cmp    %edx,%esi
f01049e9:	72 0c                	jb     f01049f7 <__udivdi3+0xb7>
f01049eb:	89 f9                	mov    %edi,%ecx
f01049ed:	d3 e5                	shl    %cl,%ebp
f01049ef:	39 c5                	cmp    %eax,%ebp
f01049f1:	73 5d                	jae    f0104a50 <__udivdi3+0x110>
f01049f3:	39 d6                	cmp    %edx,%esi
f01049f5:	75 59                	jne    f0104a50 <__udivdi3+0x110>
f01049f7:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01049fa:	31 ff                	xor    %edi,%edi
f01049fc:	89 fa                	mov    %edi,%edx
f01049fe:	83 c4 1c             	add    $0x1c,%esp
f0104a01:	5b                   	pop    %ebx
f0104a02:	5e                   	pop    %esi
f0104a03:	5f                   	pop    %edi
f0104a04:	5d                   	pop    %ebp
f0104a05:	c3                   	ret    
f0104a06:	8d 76 00             	lea    0x0(%esi),%esi
f0104a09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0104a10:	31 ff                	xor    %edi,%edi
f0104a12:	31 c0                	xor    %eax,%eax
f0104a14:	89 fa                	mov    %edi,%edx
f0104a16:	83 c4 1c             	add    $0x1c,%esp
f0104a19:	5b                   	pop    %ebx
f0104a1a:	5e                   	pop    %esi
f0104a1b:	5f                   	pop    %edi
f0104a1c:	5d                   	pop    %ebp
f0104a1d:	c3                   	ret    
f0104a1e:	66 90                	xchg   %ax,%ax
f0104a20:	31 ff                	xor    %edi,%edi
f0104a22:	89 e8                	mov    %ebp,%eax
f0104a24:	89 f2                	mov    %esi,%edx
f0104a26:	f7 f3                	div    %ebx
f0104a28:	89 fa                	mov    %edi,%edx
f0104a2a:	83 c4 1c             	add    $0x1c,%esp
f0104a2d:	5b                   	pop    %ebx
f0104a2e:	5e                   	pop    %esi
f0104a2f:	5f                   	pop    %edi
f0104a30:	5d                   	pop    %ebp
f0104a31:	c3                   	ret    
f0104a32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104a38:	39 f2                	cmp    %esi,%edx
f0104a3a:	72 06                	jb     f0104a42 <__udivdi3+0x102>
f0104a3c:	31 c0                	xor    %eax,%eax
f0104a3e:	39 eb                	cmp    %ebp,%ebx
f0104a40:	77 d2                	ja     f0104a14 <__udivdi3+0xd4>
f0104a42:	b8 01 00 00 00       	mov    $0x1,%eax
f0104a47:	eb cb                	jmp    f0104a14 <__udivdi3+0xd4>
f0104a49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104a50:	89 d8                	mov    %ebx,%eax
f0104a52:	31 ff                	xor    %edi,%edi
f0104a54:	eb be                	jmp    f0104a14 <__udivdi3+0xd4>
f0104a56:	66 90                	xchg   %ax,%ax
f0104a58:	66 90                	xchg   %ax,%ax
f0104a5a:	66 90                	xchg   %ax,%ax
f0104a5c:	66 90                	xchg   %ax,%ax
f0104a5e:	66 90                	xchg   %ax,%ax

f0104a60 <__umoddi3>:
f0104a60:	55                   	push   %ebp
f0104a61:	57                   	push   %edi
f0104a62:	56                   	push   %esi
f0104a63:	53                   	push   %ebx
f0104a64:	83 ec 1c             	sub    $0x1c,%esp
f0104a67:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0104a6b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0104a6f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0104a73:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104a77:	85 ed                	test   %ebp,%ebp
f0104a79:	89 f0                	mov    %esi,%eax
f0104a7b:	89 da                	mov    %ebx,%edx
f0104a7d:	75 19                	jne    f0104a98 <__umoddi3+0x38>
f0104a7f:	39 df                	cmp    %ebx,%edi
f0104a81:	0f 86 b1 00 00 00    	jbe    f0104b38 <__umoddi3+0xd8>
f0104a87:	f7 f7                	div    %edi
f0104a89:	89 d0                	mov    %edx,%eax
f0104a8b:	31 d2                	xor    %edx,%edx
f0104a8d:	83 c4 1c             	add    $0x1c,%esp
f0104a90:	5b                   	pop    %ebx
f0104a91:	5e                   	pop    %esi
f0104a92:	5f                   	pop    %edi
f0104a93:	5d                   	pop    %ebp
f0104a94:	c3                   	ret    
f0104a95:	8d 76 00             	lea    0x0(%esi),%esi
f0104a98:	39 dd                	cmp    %ebx,%ebp
f0104a9a:	77 f1                	ja     f0104a8d <__umoddi3+0x2d>
f0104a9c:	0f bd cd             	bsr    %ebp,%ecx
f0104a9f:	83 f1 1f             	xor    $0x1f,%ecx
f0104aa2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104aa6:	0f 84 b4 00 00 00    	je     f0104b60 <__umoddi3+0x100>
f0104aac:	b8 20 00 00 00       	mov    $0x20,%eax
f0104ab1:	89 c2                	mov    %eax,%edx
f0104ab3:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104ab7:	29 c2                	sub    %eax,%edx
f0104ab9:	89 c1                	mov    %eax,%ecx
f0104abb:	89 f8                	mov    %edi,%eax
f0104abd:	d3 e5                	shl    %cl,%ebp
f0104abf:	89 d1                	mov    %edx,%ecx
f0104ac1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104ac5:	d3 e8                	shr    %cl,%eax
f0104ac7:	09 c5                	or     %eax,%ebp
f0104ac9:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104acd:	89 c1                	mov    %eax,%ecx
f0104acf:	d3 e7                	shl    %cl,%edi
f0104ad1:	89 d1                	mov    %edx,%ecx
f0104ad3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104ad7:	89 df                	mov    %ebx,%edi
f0104ad9:	d3 ef                	shr    %cl,%edi
f0104adb:	89 c1                	mov    %eax,%ecx
f0104add:	89 f0                	mov    %esi,%eax
f0104adf:	d3 e3                	shl    %cl,%ebx
f0104ae1:	89 d1                	mov    %edx,%ecx
f0104ae3:	89 fa                	mov    %edi,%edx
f0104ae5:	d3 e8                	shr    %cl,%eax
f0104ae7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104aec:	09 d8                	or     %ebx,%eax
f0104aee:	f7 f5                	div    %ebp
f0104af0:	d3 e6                	shl    %cl,%esi
f0104af2:	89 d1                	mov    %edx,%ecx
f0104af4:	f7 64 24 08          	mull   0x8(%esp)
f0104af8:	39 d1                	cmp    %edx,%ecx
f0104afa:	89 c3                	mov    %eax,%ebx
f0104afc:	89 d7                	mov    %edx,%edi
f0104afe:	72 06                	jb     f0104b06 <__umoddi3+0xa6>
f0104b00:	75 0e                	jne    f0104b10 <__umoddi3+0xb0>
f0104b02:	39 c6                	cmp    %eax,%esi
f0104b04:	73 0a                	jae    f0104b10 <__umoddi3+0xb0>
f0104b06:	2b 44 24 08          	sub    0x8(%esp),%eax
f0104b0a:	19 ea                	sbb    %ebp,%edx
f0104b0c:	89 d7                	mov    %edx,%edi
f0104b0e:	89 c3                	mov    %eax,%ebx
f0104b10:	89 ca                	mov    %ecx,%edx
f0104b12:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0104b17:	29 de                	sub    %ebx,%esi
f0104b19:	19 fa                	sbb    %edi,%edx
f0104b1b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0104b1f:	89 d0                	mov    %edx,%eax
f0104b21:	d3 e0                	shl    %cl,%eax
f0104b23:	89 d9                	mov    %ebx,%ecx
f0104b25:	d3 ee                	shr    %cl,%esi
f0104b27:	d3 ea                	shr    %cl,%edx
f0104b29:	09 f0                	or     %esi,%eax
f0104b2b:	83 c4 1c             	add    $0x1c,%esp
f0104b2e:	5b                   	pop    %ebx
f0104b2f:	5e                   	pop    %esi
f0104b30:	5f                   	pop    %edi
f0104b31:	5d                   	pop    %ebp
f0104b32:	c3                   	ret    
f0104b33:	90                   	nop
f0104b34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104b38:	85 ff                	test   %edi,%edi
f0104b3a:	89 f9                	mov    %edi,%ecx
f0104b3c:	75 0b                	jne    f0104b49 <__umoddi3+0xe9>
f0104b3e:	b8 01 00 00 00       	mov    $0x1,%eax
f0104b43:	31 d2                	xor    %edx,%edx
f0104b45:	f7 f7                	div    %edi
f0104b47:	89 c1                	mov    %eax,%ecx
f0104b49:	89 d8                	mov    %ebx,%eax
f0104b4b:	31 d2                	xor    %edx,%edx
f0104b4d:	f7 f1                	div    %ecx
f0104b4f:	89 f0                	mov    %esi,%eax
f0104b51:	f7 f1                	div    %ecx
f0104b53:	e9 31 ff ff ff       	jmp    f0104a89 <__umoddi3+0x29>
f0104b58:	90                   	nop
f0104b59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104b60:	39 dd                	cmp    %ebx,%ebp
f0104b62:	72 08                	jb     f0104b6c <__umoddi3+0x10c>
f0104b64:	39 f7                	cmp    %esi,%edi
f0104b66:	0f 87 21 ff ff ff    	ja     f0104a8d <__umoddi3+0x2d>
f0104b6c:	89 da                	mov    %ebx,%edx
f0104b6e:	89 f0                	mov    %esi,%eax
f0104b70:	29 f8                	sub    %edi,%eax
f0104b72:	19 ea                	sbb    %ebp,%edx
f0104b74:	e9 14 ff ff ff       	jmp    f0104a8d <__umoddi3+0x2d>
