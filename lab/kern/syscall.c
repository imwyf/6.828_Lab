/*
 * @Author: imwyf 1185095602@qq.com
 * @Date: 2023-05-26 16:31:18
 * @LastEditors: imwyf 1185095602@qq.com
 * @LastEditTime: 2023-07-12 20:37:12
 * @FilePath: /imwyf/6.828/lab/kern/syscall.c
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>

#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/trap.h>
#include <kern/syscall.h>
#include <kern/console.h>
#include <kern/sched.h>

// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.
	// LAB 3: Your code here.
	// 跟随syscall调用链我们可以知道，s = %edx，len = %ecx
	user_mem_assert(curenv, s, len, PTE_U);

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
}

// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
}

// Destroy a given environment (possibly the currently running environment).
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
	if (e == curenv)
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
	env_destroy(e);
	return 0;
}

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
}

// Allocate a new environment.
// Returns envid of new environment, or < 0 on error.  Errors are:
//	-E_NO_FREE_ENV if no free environment is available.
//	-E_NO_MEM on memory exhaustion.
// 由本进程创建一个"空白"的子进程.
// 返回新环境的envid，或出现错误时返回＜0。错误为：
// -如果没有可用的环境，则为E_NO_FREE_ENV。
// -内存耗尽时的E_NO_MEM。
static envid_t
sys_exofork(void)
{
	// Create the new environment with env_alloc(), from kern/env.c.
	// It should be left as env_alloc created it, except that
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env *new_env; // 新的环境
	int Ecode = env_alloc(&new_env, curenv->env_id);
	if (Ecode) // 如果发生错误就返回error code
		return Ecode;

	new_env->env_status = ENV_NOT_RUNNABLE;
	new_env->env_tf = curenv->env_tf; // 拷贝父进程的trapframe
	new_env->env_tf.tf_regs.reg_eax = 0;
	return new_env->env_id; // 返回子进程的id
}

// Set envid's env_status to status, which must be ENV_RUNNABLE
// or ENV_NOT_RUNNABLE.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if status is not a valid status for an environment.
// 将envid的env_status设置为status，该状态必须是env_RUNNABLE或env_NOT_RUNNABLE。
// 成功时返回0，出错时返回<0。错误为：
// -E_BAD_ENV如果环境envid当前不存在，或者调用者没有更改envid的权限。
// —E_INVAL，如果状态不是环境的有效状态。
static int
sys_env_set_status(envid_t envid, int status)
{
	// Hint: Use the 'envid2env' function from kern/env.c to translate an
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	struct Env *e;
	int Ecode = envid2env(envid, &e, 1);
	if (Ecode)
		return Ecode;
	if ((status != ENV_RUNNABLE) && (status != ENV_NOT_RUNNABLE)) // 检查status是合法的
		return -E_INVAL;
	e->env_status = status; // 设置状态
	return 0;
}

// Set the page fault upcall for 'envid' by modifying the corresponding struct
// Env's 'env_pgfault_upcall' field.  When 'envid' causes a page fault, the
// kernel will push a fault record onto the exception stack, then branch to
// 'func'.
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
// 通过修改相应结构Env的“env_pgfault_upcall”字段，为“envid”页面错误处理程序。
// 当“envid”导致页面错误时，内核会将错误记录推送到异常堆栈，然后进入到“func”。
// 成功时返回0，出错时返回<0。错误为：
// -E_BAD_ENV，如果环境envid当前不存在，或者调用者没有更改envid的权限
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e;
	int Ecode = envid2env(envid, &e, 1);
	if (Ecode)
		return Ecode;
	e->env_pgfault_upcall = func;
	return 0;
}

// Allocate a page of memory and map it at 'va' with permission
// 'perm' in the address space of 'envid'.
// The page's contents are set to 0.
// If a page is already mapped at 'va', that page is unmapped as a
// side effect.
//
// perm -- PTE_U | PTE_P must be set, PTE_AVAIL | PTE_W may or may not be set,
//         but no other bits may be set.  See PTE_SYSCALL in inc/mmu.h.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
//	-E_INVAL if perm is inappropriate (see above).
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
// 分配一页内存，并在“envid”的地址空间中以“perm”权限将其映射到“va”。页面的内容设置为0。
// PTE_U|PTE_P必须被设置，PTE_AVAIL|PTE_W可以被设置也可以不被设置，
// 成功时返回0，出错时返回<0。错误为：
//-E_BAD_ENV，如果环境envid当前不存在，或者调用者没有更改envid的权限。
// 如果va>=UTOP，或va未页面对齐，则为E_INVAL。
//-如果perm不合适，则为E_INVAL。
//-如果没有内存来分配新页面，则为E_NO_MEM
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	// Hint: This function is a wrapper around page_alloc() and
	//   page_insert() from kern/pmap.c.
	//   Most of the new code you write should be to check the
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	struct Env *e;
	int Ecode;
	if ((Ecode = envid2env(envid, &e, 1))) // 得到Env结构
		return Ecode;

	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || perm & ~PTE_SYSCALL) // 检查perm
		return -E_INVAL;
	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE != 0) // 检查va
		return -E_INVAL;

	struct PageInfo *p = page_alloc(ALLOC_ZERO);
	if (!p) // 没有内存，分配页面失败
		return -E_NO_MEM;

	Ecode = page_insert(e->env_pgdir, p, va, perm);
	if (Ecode)
	{
		page_decref(p); // 释放p
		return Ecode;
	}
	return 0;
}

// Map the page of memory at 'srcva' in srcenvid's address space
// at 'dstva' in dstenvid's address space with permission 'perm'.
// Perm has the same restrictions as in sys_page_alloc, except
// that it also must not grant write access to a read-only
// page.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if srcenvid and/or dstenvid doesn't currently exist,
//		or the caller doesn't have permission to change one of them.
//	-E_INVAL if srcva >= UTOP or srcva is not page-aligned,
//		or dstva >= UTOP or dstva is not page-aligned.
//	-E_INVAL is srcva is not mapped in srcenvid's address space.
//	-E_INVAL if perm is inappropriate (see sys_page_alloc).
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
//		address space.
//	-E_NO_MEM if there's no memory to allocate any necessary page tables.
// 将srcenvid地址空间中“srcva”处的内存页映射到dstenvid地址空间中的“dstva”处。Perm具有与sys_page_alloc中相同的限制.
// 成功时返回0，出错时返回<0错误为：
// -E_BAD_ENV，如果srcenvid和/或dstenvid当前不存在，或者调用方无权更改其中一个。
//  如果srcva>=UTOP或srcva未页面对齐，或者dstva>=UTUP或dstva未页面对齐则为E_INVAL。
// -E_INVAL是srcva未映射到srcenvid的地址空间中。
// -如果perm不合适，则为E_INVAL（请参阅sys_page_alloc）。
// -E_INVAL if（perm&PTE_W），但srcva在srcenvid的地址空间中是只读的。
// -如果没有内存来分配任何必要的页面数据，则为E_NO_MEM
static int
sys_page_map(envid_t srcenvid, void *srcva,
			 envid_t dstenvid, void *dstva, int perm)
{
	// Hint: This function is a wrapper around page_lookup() and
	//   page_insert() from kern/pmap.c.
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	struct Env *src;
	struct Env *dst;
	int Ecode;
	if ((Ecode = envid2env(srcenvid, &src, 1))) // 得到Env结构
		return Ecode;
	if ((Ecode = envid2env(dstenvid, &dst, 1)))
		return Ecode;

	if (((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)) || (perm & ~PTE_SYSCALL)) // 检查perm
		return -E_INVAL;
	if ((uintptr_t)srcva >= UTOP || (uintptr_t)srcva % PGSIZE != 0 // 检查va
		|| (uintptr_t)dstva >= UTOP || (uintptr_t)dstva % PGSIZE != 0)
		return -E_INVAL;

	pte_t *pte;
	struct PageInfo *p = page_lookup(src->env_pgdir, srcva, &pte); // 找到src对应的页面
	if (!p)														   // 没有权限
		return -E_INVAL;

	if (!(*pte | PTE_W) && (perm & PTE_W)) // srcva在srcenvid的地址空间中是只读的。
		return -E_INVAL;
	Ecode = page_insert(dst->env_pgdir, p, dstva, perm); // 把src对应的页面也映射到dst上，这样两者都映射到同一个页面
	if (Ecode)
		return Ecode;
	return 0;
}

// Unmap the page of memory at 'va' in the address space of 'envid'.
// If no page is mapped, the function silently succeeds.
//
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
// 取消映射“envid”地址空间中“va”处的内存页。
// 成功时返回0，出错时返回<0。错误为：
// -E_BAD_ENV，如果环境envid当前不存在，或者调用者没有更改envid的权限。
// 如果va>=UTOP，或va未页面对齐，则为E_INVAL。
static int
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().
	// LAB 4: Your code here.
	struct Env *e;
	int Ecode;
	if ((Ecode = envid2env(envid, &e, 1))) // 得到Env结构
		return Ecode;

	if ((uintptr_t)va >= UTOP || (uintptr_t)va % PGSIZE != 0)
		return -E_INVAL;

	page_remove(e->env_pgdir, va);
	return 0;
}

// Try to send 'value' to the target env 'envid'.
// If srcva < UTOP, then also send page currently mapped at 'srcva',
// so that receiver gets a duplicate mapping of the same page.
//
// The send fails with a return value of -E_IPC_NOT_RECV if the
// target is not blocked, waiting for an IPC.
//
// The send also can fail for the other reasons listed below.
//
// Otherwise, the send succeeds, and the target's ipc fields are
// updated as follows:
//    env_ipc_recving is set to 0 to block future sends;
//    env_ipc_from is set to the sending envid;
//    env_ipc_value is set to the 'value' parameter;
//    env_ipc_perm is set to 'perm' if a page was transferred, 0 otherwise.
// The target environment is marked runnable again, returning 0
// from the paused sys_ipc_recv system call.  (Hint: does the
// sys_ipc_recv function ever actually return?)
//
// If the sender wants to send a page but the receiver isn't asking for one,
// then no page mapping is transferred, but no error occurs.
// The ipc only happens when no errors occur.
//
// Returns 0 on success, < 0 on error.
// Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist.
//		(No need to check permissions.)
//	-E_IPC_NOT_RECV if envid is not currently blocked in sys_ipc_recv,
//		or another environment managed to send first.
//	-E_INVAL if srcva < UTOP but srcva is not page-aligned.
//	-E_INVAL if srcva < UTOP and perm is inappropriate
//		(see sys_page_alloc).
//	-E_INVAL if srcva < UTOP but srcva is not mapped in the caller's
//		address space.
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in the
//		current environment's address space.
//	-E_NO_MEM if there's not enough memory to map srcva in envid's
//		address space.
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here
	struct Env *dst;
	struct PageInfo *pp;
	pte_t *pte;
	int Ecode;

	if ((Ecode = envid2env(envid, &dst, 0)) < 0)
		return Ecode;

	if (!dst->env_ipc_recving)
		return -E_IPC_NOT_RECV;

	if ((uintptr_t)srcva >= UTOP)
	{
		perm = 0;
	}
	else if ((uintptr_t)srcva < UTOP)
	{
		if ((uintptr_t)srcva % PGSIZE != 0)
			return -E_INVAL;

		if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U))
			return -E_INVAL;

		if (perm & ~PTE_SYSCALL)
			return -E_INVAL;

		if (!(pp = page_lookup(curenv->env_pgdir, srcva, &pte)))
			return -E_INVAL;

		if ((perm & PTE_W) && !(*pte & PTE_W))
			return -E_INVAL;

		if ((uintptr_t)dst->env_ipc_dstva < UTOP)
		{
			if ((Ecode = page_insert(dst->env_pgdir, pp, dst->env_ipc_dstva, perm)) < 0)
				return Ecode;
		}
		else
			perm = 0;
	}

	dst->env_ipc_recving = false;
	dst->env_ipc_from = curenv->env_id;
	dst->env_ipc_value = value;
	dst->env_ipc_perm = perm;
	dst->env_status = ENV_RUNNABLE;

	dst->env_tf.tf_regs.reg_eax = 0;

	return 0;
}

// Block until a value is ready.  Record that you want to receive
// using the env_ipc_recving and env_ipc_dstva fields of struct Env,
// mark yourself not runnable, and then give up the CPU.
//
// If 'dstva' is < UTOP, then you are willing to receive a page of data.
// 'dstva' is the virtual address at which the sent page should be mapped.
//
// This function only returns on error, but the system call will eventually
// return 0 on success.
// Return < 0 on error.  Errors are:
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uintptr_t)dstva < UTOP && (uintptr_t)dstva % PGSIZE != 0)
		return -E_INVAL;

	curenv->env_ipc_recving = true;
	curenv->env_ipc_dstva = dstva;
	curenv->env_status = ENV_NOT_RUNNABLE;
	sched_yield();
	return 0;
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) // 根据系统调用编号，调用相应的处理函数，枚举值即为inc\syscall.h中定义的值
	{
	case SYS_cputs:
		sys_cputs((char *)a1, (size_t)a2);
		return 0;
	case SYS_cgetc:
		return sys_cgetc();
	case SYS_getenvid:
		return sys_getenvid();
	case SYS_env_destroy:
		return sys_env_destroy((envid_t)a1);
	case SYS_yield:
		sys_yield();
		return 0;
	case SYS_exofork:
		return sys_exofork();
	case SYS_env_set_status:
		return sys_env_set_status((envid_t)a1, (int)a2);
	case SYS_page_alloc:
		return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
	case SYS_page_map:
		return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
	case SYS_page_unmap:
		return sys_page_unmap((envid_t)a1, (void *)a2);
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
	case SYS_ipc_try_send:
		return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned int)a4);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *)a1);
	case NSYSCALLS:
	default:
		return -E_INVAL;
	}
}
