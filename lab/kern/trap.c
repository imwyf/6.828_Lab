#include <inc/mmu.h>
#include <inc/x86.h>
#include <inc/assert.h>

#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/env.h>
#include <kern/syscall.h>

void handle0();

static struct Taskstate ts;

/* For debugging, so print_trapframe can distinguish between printing
 * a saved trapframe and printing the current trapframe and print some
 * additional information in the latter case.
 */
static struct Trapframe *last_tf;

/* Interrupt descriptor table.  (Must be built at run time because
 * shifted function addresses can't be represented in relocation records.)
 */
struct Gatedesc idt[256] = {{0}};
struct Pseudodesc idt_pd = {
	sizeof(idt) - 1, (uint32_t)idt};

static const char *trapname(int trapno) // 根据trapno返回对应的中断的名字
{
	static const char *const excnames[] = {
		"Divide error",
		"Debug",
		"Non-Maskable Interrupt",
		"Breakpoint",
		"Overflow",
		"BOUND Range Exceeded",
		"Invalid Opcode",
		"Device Not Available",
		"Double Fault",
		"Coprocessor Segment Overrun",
		"Invalid TSS",
		"Segment Not Present",
		"Stack Fault",
		"General Protection",
		"Page Fault",
		"(unknown trap)",
		"x87 FPU Floating-Point Error",
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
	return "(unknown trap)";
}

/* 触发中断的流程：
 * 1.trap_init()先将entrytrap.S中声明的Handler函数入口添加进IDT表
 * 2.int触发中断，从IDT表定义的入口执行，进入Handler函数，分配空间后调用_alltraps
 * 3._alltraps把寄存器push进堆栈，然后调用trap(), 并将Trapframe的指针作为参数出给函数
 * 4.trap()先做一些检查，然后转发调用trap_dispatch()
 * 5.trap_dispatch()里读出Trapframe的中断号，switch case调用对应的处理函数
 */
void trap_init(void)
{
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	// 先声明那些定义在trapentry.S的handlerX函数
	void DIVIDE_Handler();
	void DEBUG_Handler();
	void NMI_Handler();
	void BRKPT_Handler();
	void OFLOW_Handler();
	void BOUND_Handler();
	void ILLOP_Handler();
	void DEVICE_Handler();
	void DBLFLT_Handler();

	SETGATE(idt[T_DIVIDE], 1, GD_KT, DIVIDE_Handler, 0); // SETGATE设置一个idt条目
	SETGATE(idt[T_DEBUG], 1, GD_KT, DEBUG_Handler, 3);
	SETGATE(idt[T_NMI], 1, GD_KT, NMI_Handler, 0);
	SETGATE(idt[T_BRKPT], 1, GD_KT, BRKPT_Handler, 3);
	SETGATE(idt[T_OFLOW], 1, GD_KT, OFLOW_Handler, 0);
	SETGATE(idt[T_BOUND], 1, GD_KT, BOUND_Handler, 0);
	SETGATE(idt[T_ILLOP], 1, GD_KT, ILLOP_Handler, 0);
	SETGATE(idt[T_DEVICE], 1, GD_KT, DEVICE_Handler, 0);
	SETGATE(idt[T_DBLFLT], 1, GD_KT, DBLFLT_Handler, 0);

	void TSS_Handler();
	void SEGNP_Handler();
	void STACK_Handler();
	void GPFLT_Handler();
	void PGFLT_Handler();

	SETGATE(idt[T_TSS], 1, GD_KT, TSS_Handler, 0);
	SETGATE(idt[T_SEGNP], 1, GD_KT, SEGNP_Handler, 0);
	SETGATE(idt[T_STACK], 1, GD_KT, STACK_Handler, 0);
	SETGATE(idt[T_GPFLT], 1, GD_KT, GPFLT_Handler, 0);
	SETGATE(idt[T_PGFLT], 1, GD_KT, PGFLT_Handler, 0);

	void FPERR_Handler();
	void ALIGN_Handler();
	void MCHK_Handler();
	void PGFLT_Handler();
	SETGATE(idt[T_FPERR], 1, GD_KT, FPERR_Handler, 0);
	SETGATE(idt[T_ALIGN], 1, GD_KT, ALIGN_Handler, 0);
	SETGATE(idt[T_MCHK], 1, GD_KT, MCHK_Handler, 0);
	SETGATE(idt[T_SIMDERR], 1, GD_KT, PGFLT_Handler, 0);

	void SYSCALL_Handler();
	SETGATE(idt[T_SYSCALL], 0, GD_KT, SYSCALL_Handler, 3);

	// Per-CPU setup
	trap_init_percpu();
}

void trap_init_percpu(void) // 初始化TSS和IDT
{
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
	ts.ts_ss0 = GD_KD;
	ts.ts_iomb = sizeof(struct Taskstate);

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t)(&ts),
							  sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}

void print_trapframe(struct Trapframe *tf) // 打印保存的trapframe和打印当前trapframe
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
		cprintf("  cr2  0x%08x\n", rcr2());
	cprintf("  err  0x%08x", tf->tf_err);
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
				tf->tf_err & 4 ? "user" : "kernel",
				tf->tf_err & 2 ? "write" : "read",
				tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
	cprintf("  eip  0x%08x\n", tf->tf_eip);
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
	if ((tf->tf_cs & 3) != 0)
	{
		cprintf("  esp  0x%08x\n", tf->tf_esp);
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
	}
}

void print_regs(struct PushRegs *regs) // 打印寄存器的值，print_trapframe()的辅助函数
{
	cprintf("  edi  0x%08x\n", regs->reg_edi);
	cprintf("  esi  0x%08x\n", regs->reg_esi);
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
	cprintf("  edx  0x%08x\n", regs->reg_edx);
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
	cprintf("  eax  0x%08x\n", regs->reg_eax);
}

// 实际的中断处理函数
static void trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch (tf->tf_trapno)
	{
	case T_PGFLT:
		page_fault_handler(tf);
		return;
	case T_BRKPT:
		monitor(tf);
		return;
	case T_SYSCALL:
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx,
									  tf->tf_regs.reg_ecx, tf->tf_regs.reg_ebx,
									  tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		return;
	default:
		break;
	}
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
	if (tf->tf_cs == GD_KT)
		panic("unhandled trap in kernel");
	else
	{
		env_destroy(curenv);
		return;
	}
}

void trap(struct Trapframe *tf) // 中断处理程序，先做一些权限判断，然后转发调用trap_dispatch()来处理中断
{
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::
					 : "cc");

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));

	cprintf("Incoming TRAP frame at %p\n", tf);

	if ((tf->tf_cs & 3) == 3) // 通过tf_cs的低位判断权限级别，进而判断现在处于用户模式(=3)还是内核模式(=0)
	{
		// 确认在用户模式
		assert(curenv);

		// 将陷阱帧（当前在内核堆栈上）复制到“curenv->env_tf”中，这是因为处于用户模式下，无法写入内核堆栈
		curenv->env_tf = *tf;
		// 忽略内核堆栈上的陷阱帧，只使用复制到用户堆栈的陷阱帧
		tf = &curenv->env_tf;
	}
	// 内核模式下，直接使用堆栈上的陷阱帧，因此tf就不需要改变了

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	// 记录一下真正使用的tf是哪个
	last_tf = tf;

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
	env_run(curenv); // 返回用户态
}

void page_fault_handler(struct Trapframe *tf) // 特殊处理页错误中断
{
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.
	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0) // 处于内核模式
	{
		panic("page_fault_handler(): kernel-mode page faults");
	}
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
			curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
	env_destroy(curenv);
}
