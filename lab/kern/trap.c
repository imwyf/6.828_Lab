#include <inc/mmu.h>
#include <inc/x86.h>
#include <inc/assert.h>

#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/env.h>
#include <kern/syscall.h>
#include <kern/sched.h>
#include <kern/kclock.h>
#include <kern/picirq.h>
#include <kern/cpu.h>
#include <kern/spinlock.h>

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
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
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

	// IRQ_Handler
	void IRQ_TIMER_Handler();
	void IRQ_KBD_Handler();
	void IRQ_SERIAL_Handler();
	void IRQ_SPURIOUS_Handler();
	void IRQ_IDE_Handler();
	void IRQ_ERROR_Handler();
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 1, GD_KT, IRQ_TIMER_Handler, 0);
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 1, GD_KT, IRQ_KBD_Handler, 0);
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 1, GD_KT, IRQ_SERIAL_Handler, 0);
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 1, GD_KT, IRQ_SPURIOUS_Handler, 0);
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 1, GD_KT, IRQ_IDE_Handler, 0);
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 1, GD_KT, IRQ_ERROR_Handler, 0);

	// Per-CPU setup
	trap_init_percpu();
}

void trap_init_percpu(void) // 初始化TSS和IDT
{
	// The example code here sets up the Task State Segment (TSS) and
	// the TSS descriptor for CPU 0. But it is incorrect if we are
	// running on other CPUs because each CPU has its own kernel stack.
	// Fix the code so that it works for all CPUs.
	//
	// Hints:
	//   - The macro "thiscpu" always refers to the current CPU's
	//     struct CpuInfo;
	//   - The ID of the current CPU is given by cpunum() or
	//     thiscpu->cpu_id;
	//   - Use "thiscpu->cpu_ts" as the TSS for the current CPU,
	//     rather than the global "ts" variable;
	//   - Use gdt[(GD_TSS0 >> 3) + i] for CPU i's TSS descriptor;
	//   - You mapped the per-CPU kernel stacks in mem_init_mp()
	//   - Initialize cpu_ts.ts_iomb to prevent unauthorized environments
	//     from doing IO (0 is not the correct value!)
	//
	// ltr sets a 'busy' flag in the TSS selector, so if you
	// accidentally load the same TSS on more than one CPU, you'll
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	size_t i = cpunum();								   // 拿到现在运行的cpuid
	struct Taskstate *ts = &cpus[i].cpu_ts;				   // 这里这样取cpuinfo，因为直接用thiscpu会爆出triple fault
	ts->ts_esp0 = (uintptr_t)percpu_kstacks[i] + KSTKSIZE; // esp0: 指代当前 CPU 的 stack 的起始位置
	ts->ts_ss0 = GD_KD;									   // 表示 esp0 这个位置存储的是 kernel 的 data
	ts->ts_iomb = sizeof(struct Taskstate);

	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t)ts, sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;

	ltr(GD_TSS0 + (i << 3));

	lidt(&idt_pd);
}

void print_trapframe(struct Trapframe *tf) // 打印保存的trapframe和打印当前trapframe
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
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
	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS)
	{
		cprintf("Spurious interrupt on irq 7\n");
		print_trapframe(tf);
		return;
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER)
	{
		lapic_eoi();
		sched_yield();
		return;
	}
	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.

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

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
		asm volatile("hlt");

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	// assert(!(read_eflags() & FL_IF));

	// 通过tf_cs的低位判断权限级别，进而判断现在处于用户模式(=3)还是内核模式(=0)
	if ((tf->tf_cs & 3) == 3)
	{
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING)
		{
			env_free(curenv);
			curenv = NULL;
			sched_yield();
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
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

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
		env_run(curenv); // 返回用户态
	else
		sched_yield();
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

	// Call the environment's page fault upcall, if one exists.  Set up a
	// page fault stack frame on the user exception stack (below
	// UXSTACKTOP), then branch to curenv->env_pgfault_upcall.
	//
	// The page fault upcall might cause another page fault, in which case
	// we branch to the page fault upcall recursively, pushing another
	// page fault stack frame on top of the user exception stack.
	//
	// It is convenient for our code which returns from a page fault
	// (lib/pfentry.S) to have one word of scratch space at the top of the
	// trap-time stack; it allows us to more easily restore the eip/esp. In
	// the non-recursive case, we don't have to worry about this because
	// the top of the regular user stack is free.  In the recursive case,
	// this means we have to leave an extra word between the current top of
	// the exception stack and the new stack frame because the exception
	// stack _is_ the trap-time stack.
	//
	// If there's no page fault upcall, the environment didn't allocate a
	// page for its exception stack or can't write to it, or the exception
	// stack overflows, then destroy the environment that caused the fault.
	// Note that the grade script assumes you will first check for the page
	// fault upcall and print the "user fault va" message below if there is
	// none.  The remaining three checks can be combined into a single test.
	//
	// Hints:
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	// 现在处于用户模式
	if (curenv->env_pgfault_upcall != NULL) // 用户模式下的页面错误处理程序如果有设置
	{
		uintptr_t addr;

		if (tf->tf_esp >= UXSTACKTOP - PGSIZE && tf->tf_esp < UXSTACKTOP) // 如果发生异常时用户环境已经在用户异常堆栈上运行
			addr = tf->tf_esp - sizeof(struct UTrapframe) - sizeof(int);  // 在tf->tf_esp处设置页面错误堆栈帧UTrapframe
		else
			addr = UXSTACKTOP - sizeof(struct UTrapframe) - sizeof(int); // 栈帧的区间[UXSTACKTOP - sizeof(struct UTrapframe) - sizeof(int),UXSTACKTOP]
		user_mem_assert(curenv, (void *)addr, sizeof(struct UTrapframe) + sizeof(int), PTE_P | PTE_U | PTE_W);

		// 在UXSTACKTOP设置一个用户模式下的页面错误堆栈帧UTrapframe，为了可以从页面错误处理程序中返回到引发错误的程序
		struct UTrapframe *utf = (struct UTrapframe *)addr;
		utf->utf_fault_va = fault_va;
		utf->utf_err = tf->tf_err;
		utf->utf_regs = tf->tf_regs;
		utf->utf_eip = tf->tf_eip;
		utf->utf_eflags = tf->tf_eflags;
		utf->utf_esp = tf->tf_esp;

		tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall; // 设置页面错误处理程序入口
		tf->tf_esp = (uintptr_t)utf;						// 修改esp移动到设置好的用户异常堆栈
		env_run(curenv);									// 重新运行本进程，env_run会pop出tf，来运行页面错误处理程序
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
			curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
	env_destroy(curenv);
}
