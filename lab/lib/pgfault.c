/*
 * @Author: imwyf 1185095602@qq.com
 * @Date: 2023-06-05 10:09:06
 * @LastEditors: imwyf 1185095602@qq.com
 * @LastEditTime: 2023-06-24 14:31:54
 * @FilePath: /imwyf/6.828/lab/lib/pgfault.c
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
// User-level page fault handler support.
// Rather than register the C page fault handler directly with the
// kernel as the page fault handler, we register the assembly language
// wrapper in pfentry.S, which in turns calls the registered C
// function.

#include <inc/lib.h>

// Assembly language pgfault entrypoint defined in lib/pfentry.S.
extern void _pgfault_upcall(void);

// Pointer to currently installed C-language pgfault handler.
void (*_pgfault_handler)(struct UTrapframe *utf);

//
// Set the page fault handler function.
// If there isn't one yet, _pgfault_handler will be 0.
// The first time we register a handler, we need to
// allocate an exception stack (one page of memory with its top
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
	int r;

	if (_pgfault_handler == 0)
	{
		// First time through!
		// LAB 4: Your code here.
		int Ecode;
		envid_t curenv_id = sys_getenvid();
		Ecode = sys_page_alloc(curenv_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W); // 分配用户异常堆栈
		if (Ecode)
			panic("sys_page_alloc error!");
		Ecode = sys_env_set_pgfault_upcall(curenv_id, _pgfault_upcall); // 设置了页面错误处理程序的入口，即汇编程序_pgfault_upcall
		if (Ecode)
			panic("sys_env_set_pgfault_upcall error!");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler; // 汇编程序_pgfault_upcall会转发调用这个真正的处理程序
}
