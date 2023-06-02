/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 * TRAPHANDLER(name, num):是一个宏，等效于一个从name标记的地址开始的几行指令
 * name是你为这个num的中断设置的中断处理程序的函数名，num由inc\trap.h定义
 * 经过下面的设置，这个汇编文件里存在很多个以handler为名的函数，可以在C中使用void XXX_Hander()去声明函数，
 * 这时，这个hander函数的地址将被链接到下面对应hander的行。
 */
TRAPHANDLER_NOEC(DIVIDE_Handler, T_DIVIDE)
TRAPHANDLER_NOEC(DEBUG_Handler, T_DEBUG)
TRAPHANDLER_NOEC(NMI_Handler, T_NMI)
TRAPHANDLER_NOEC(BRKPT_Handler, T_BRKPT)
TRAPHANDLER_NOEC(OFLOW_Handler, T_OFLOW)
TRAPHANDLER_NOEC(BOUND_Handler, T_BOUND)
TRAPHANDLER_NOEC(ILLOP_Handler, T_ILLOP)
TRAPHANDLER_NOEC(DEVICE_Handler, T_DEVICE)
TRAPHANDLER(DBLFLT_Handler, T_DBLFLT)

TRAPHANDLER(TSS_Handler, T_TSS)
TRAPHANDLER(SEGNP_Handler, T_SEGNP)
TRAPHANDLER(STACK_Handler, T_STACK)
TRAPHANDLER(GPFLT_Handler, T_GPFLT)
TRAPHANDLER(PGFLT_Handler, T_PGFLT)

TRAPHANDLER(FPERR_Handler, T_FPERR)
TRAPHANDLER(ALIGN_Handler, T_ALIGN)
TRAPHANDLER(MCHK_Handler, T_MCHK)
TRAPHANDLER(SIMDERR_Handler, T_SIMDERR)

TRAPHANDLER_NOEC(SYSCALL_Handler, T_SYSCALL)


/*
 * Lab 3: Your code here for _alltraps
 */
.globl		_start
_alltraps:
	pushl	%ds		/* 后面要将GD_KD加载到%ds和%es，先保存旧的 */
	pushl	%es
	pushal			/* 直接推送整个TrapFrame */
	movw 	$GD_KD, %ax /* 不能直接设置，因此先复制到%ax */
  	movw 	%ax, %ds
  	movw 	%ax, %es
	pushl 	%esp	/* %esp指向Trapframe顶部，作为参数传递给trap */
	call	trap	/* 调用c程序trap，执行中断处理程序 */
