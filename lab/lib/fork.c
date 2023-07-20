/*
 * @Author: imwyf 1185095602@qq.com
 * @Date: 2023-06-05 10:09:06
 * @LastEditors: imwyf 1185095602@qq.com
 * @LastEditTime: 2023-07-20 19:34:26
 * @FilePath: /imwyf/6.828/lab/lib/fork.c
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW 0x800

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);		  // 做个对齐
	if (!(uvpt[PGNUM(addr)] & PTE_COW) || // 检查是否是copy-on-write的
		!(err & FEC_WR))				  // 检查是否是写入引发的错误
	{
		panic("pgfault error");
	}

	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	int Ecode;
	envid_t curenvid = sys_getenvid();
	Ecode = sys_page_alloc(curenvid, PFTEMP, PTE_U | PTE_P | PTE_W); // 分配一页内存到PFTEMP
	if (Ecode)
	{
		panic("sys_page_alloc error");
	}

	memmove(PFTEMP, addr, PGSIZE); // 将旧页面移动到PFTEMP处

	Ecode = sys_page_map(curenvid, PFTEMP, curenvid, addr, PTE_P | PTE_U | PTE_W); // 将新页面映射到旧页面原来的地址，代替旧页面
	if (Ecode)
	{
		panic("sys_page_map error");
	}

	Ecode = sys_page_unmap(curenvid, PFTEMP); // 取消映射新页面的地址
	if (Ecode)
	{
		panic("sys_page_unmap error");
	}
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	int Ecode;
	envid_t curenvid = sys_getenvid();
	void *addr = (void *)(pn * PGSIZE);
	if (uvpt[pn] & PTE_W || uvpt[pn] & PTE_COW) // 页面是copy-on-write的
	{
		Ecode = sys_page_map(curenvid, addr, envid, addr, PTE_U | PTE_P | PTE_COW); // 映射到子进程的地址空间,设置PTE_COW
		if (Ecode)
		{
			panic("sys_page_map error");
		}
		Ecode = sys_page_map(curenvid, addr, curenvid, addr, PTE_U | PTE_P | PTE_COW); // 父进程本身的映射重新设置PTE_COW
		if (Ecode)
		{
			panic("sys_page_map error");
		}
	}
	else
	{
		Ecode = sys_page_map(curenvid, addr, envid, addr, PTE_U | PTE_P); // 映射到子进程的地址空间，不设置PTE_COW
		if (Ecode)
		{
			panic("sys_page_map error");
		}
	}
	if (uvpt[pn] & (PTE_SHARE)) // 新增对PTE_SHARE的处理
	{
		Ecode = sys_page_map(0, (void *)addr, envid, (void *)addr, uvpt[pn] & PTE_SYSCALL);
		if (Ecode)
			return Ecode;
	}
	return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);		// 安装pgfault（）作为页面错误处理程序。
	envid_t new_env_id = sys_exofork(); // 创建一个新进程作为子进程

	if (new_env_id > 0) // 成功创建，父进程返回id>0
	{
		for (int pn = 0; pn < PGNUM(UTOP) - 1;) // 遍历UTOP下的每一页,除了用户异常堆栈
		{
			uint32_t pde = uvpd[pn / NPDENTRIES]; // 1024张PTE表的的索引
			if (!(pde & PTE_P))					  // 无法访问
			{
				pn += NPDENTRIES; // 找下一张PTE表
			}
			else // 找到能访问的PTE表
			{
				int next_pde = MIN(pn + NPDENTRIES, PGNUM(UTOP) - 1);
				for (; pn < next_pde; pn++) // 遍历PTE表中的PTE条目
				{
					uint32_t pte = uvpt[pn];
					if (pte & PTE_P && pte & PTE_U) // 允许写入
					{
						int Ecode = duppage(new_env_id, pn);
						if (Ecode)
							panic("duppage error");
					}
				}
			}
		}
		int Ecode;
		// 接下来还需要先父进程一样处理用户异常堆栈
		Ecode = sys_page_alloc(new_env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W); // 分配用户异常堆栈
		if (Ecode)
			panic("sys_page_alloc error!");
		// 将子进程的处理程序也设置为pgfault
		extern void _pgfault_upcall(void);								 // 声明_pgfault_upcall
		Ecode = sys_env_set_pgfault_upcall(new_env_id, _pgfault_upcall); // 设置了页面错误处理程序的入口，即汇编程序_pgfault_upcall
		if (Ecode)
			panic("sys_env_set_pgfault_upcall error!");
		Ecode = sys_env_set_status(new_env_id, ENV_RUNNABLE); // 将子程序设置为可运行
		if (Ecode)
			panic("sys_env_set_status error!");
	}
	else if (new_env_id == 0) // 子进程返回id==0
	{
		thisenv = &envs[ENVX(sys_getenvid())];
	}
	else
		panic("fork error");

	return new_env_id;
}

// Challenge!
int sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}
