/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <inc/mmu.h>
#include <inc/error.h>
#include <inc/string.h>
#include <inc/assert.h>

#include <kern/pmap.h>
#include <kern/kclock.h>
#include <kern/env.h>
#include <kern/cpu.h>

// These variables are set by i386_detect_memory()
size_t npages;				  // Amount of physical memory (in pages)
static size_t npages_basemem; // Amount of base memory (in pages)

// These variables are set in mem_init()
pde_t *kern_pgdir;						// Kernel's initial page directory
struct PageInfo *pages;					// Physical page state array
static struct PageInfo *page_free_list; // Free list of physical pages

// --------------------------------------------------------------
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
}

static void
i386_detect_memory(void)
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
	extmem = nvram_read(NVRAM_EXTLO);
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
		totalmem = 16 * 1024 + ext16mem;
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
	npages_basemem = basemem / (PGSIZE / 1024);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
			totalmem, basemem, totalmem - basemem);
}

// --------------------------------------------------------------
// Set up memory mappings above UTOP.
// --------------------------------------------------------------

static void mem_init_mp(void);
static void boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm);
static void check_page_free_list(bool only_low_memory);
static void check_page_alloc(void);
static void check_kern_pgdir(void);
static physaddr_t check_va2pa(pde_t *pgdir, uintptr_t va);
static void check_page(void);
static void check_page_installed_pgdir(void);

// 仅在JOS设置其虚拟内存系统时使用的简单的物理内存分配器，之后使用page_alloc()分配
// 分配一个足以容纳n字节的内存区间：用一个地址nextfree来确定可以使用的内存的顶部，并且返回可以使用的内存的底部地址result
// 可使用内存区间为[result, nextfree], 且区间长度是4096的倍数
static void *
boot_alloc(uint32_t n)
{
	static char *nextfree; // virtual address of next byte of free memory，static意味着nextfree不会随着函数返回被重置，是全局变量
	char *result;

	if (!nextfree) // nextfree初始化，只有第一次运行会执行
	{
		extern char end[]; // linker会获取内核代码的最后一个字节的位置，将end指向这个地址，因此end指向内核代码结尾

		nextfree = ROUNDUP((char *)end, PGSIZE); // 内核使用的第一块内存必须远离内核代码结尾

		/* ROUNDUP(a,n)：将数a舍入到最近的n的倍数
		 * 假设end是4097，ROUNDUP(end, PGSIZE)得到end=4096*2，这样才能容纳4097
		 */
	}

	// LAB 2: Your code here.
	if (n == 0) // 不分配内存，直接返回
	{
		return nextfree;
	}

	// n是无符号数，不考虑<0情形
	result = nextfree;				// 将更新前的nextfree赋给result
	nextfree += ROUNDUP(n, PGSIZE); // +=:在原来的基础上再分配

	// 如果内存不足，boot_alloc应该会死机
	if (nextfree > (char *)0xf0400000) // >4MB
	{
		panic("out of memory(4MB) : boot_alloc() in pmap.c \n"); // 调用预先定义的assert
		nextfree = result;										 // 分配失败，回调nextfree
		return NULL;
	}
	return result;
}

// 内存空间的布局
/* *************  0x00400000  ************* (4MB)
 *
 * ////////////////////////////////////////
 *
 * *************  0x00158000  ************* <<-- pages end
 *											(struct PageInfo)--|
 *													.		   |
 *													. 		   |---> npages个
 *											 		.		   |
 *								 			(struct PageInfo)--|
 * *************  0x00118000  ************* <<-- pages start
 *
 * *************  0x00117000  ************* <<-- kern_pgdir
 * 			    [舍入空出来的空间]
 * ***********  end(内核代码尾部)  **********
 *
 * 				   [内核代码]
 *
 * *************  0x00100000  *************	(1MB)
 *
 *
 *
 *
 *
 * 			   [BIOS使用的内存]
 *
 *
 *
 * *************  0x000a0000  *************       <<-- BASEMEM
 *
 * *************  0x00000000  *************	(0MB) <<-- KERNBASE
 */
void mem_init(void)
{
	uint32_t cr0;
	size_t n;

	i386_detect_memory(); // 通过定义在kern/kclock.c的一系列汇编指令获取硬件信息

	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// 先使用boot分配器分配一页
	kern_pgdir = (pde_t *)boot_alloc(PGSIZE); // 第一次运行，会舍入一部分
	memset(kern_pgdir, 0, PGSIZE);			  // 内存初始化为0

	//////////////////////////////////////////////////////////////////////
	// 递归地将PD作为页表插入其自身，以在虚拟地址UVPT处形成虚拟页表。
	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P; // 暂时不需要理解，只需要知道kern_pgdir处有一个页表目录

	//////////////////////////////////////////////////////////////////////
	// 这里需要我们分配一个有npages个struct PageInfo的数组，并存储在(即赋给)pages，之后用0把这些内存初始化。
	// pages：数组，物理内存有几页，pages就有几个元素，page[i]代表地址空间内第i页内存
	// npages：在前面i386_detect_memory()中求得，代表物理内存页的数量上限
	// struct PageInfo：内存页的引用信息
	// Your code goes here:
	pages = (struct PageInfo *)boot_alloc(npages * sizeof(struct PageInfo)); // sizeof求得PageInfo占多少字节，返回结果记得强转成pages对应的类型
	memset(pages, 0, npages * sizeof(struct PageInfo));						 // memset(d,c,l):从指针d开始，用字符c填充l个长度的内存

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(NENV * sizeof(struct Env));
	//////////////////////////////////////////////////////////////////////
	// 我们分配了pages用的空间后，接下来需要调用page_init()初始化pages
	page_init(); // 初始化之后，所有的内存管理都将通过page_*函数进行

	check_page_free_list(1);
	check_page_alloc();
	check_page();

	//////////////////////////////////////////////////////////////////////
	// Now we set up virtual memory

	//////////////////////////////////////////////////////////////////////
	// 将分配器的pages数组映射到地址UPAGES处，并且设置对用户只读
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, npages * sizeof(struct PageInfo), PADDR(pages), PTE_U);

	//////////////////////////////////////////////////////////////////////
	// Map the 'envs' array read-only by the user at linear address UENVS
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// 将 'envs' 数组映射到地址UENVS处，用户只读
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, NENV * sizeof(struct Env), PADDR(envs), PTE_U);
	// //////////////////////////////////////////////////////////////////////
	// Use the physical memory that 'bootstack' refers to as the kernel
	// stack.  The kernel stack grows down from virtual address KSTACKTOP.
	// We consider the entire range from [KSTACKTOP-PTSIZE, KSTACKTOP)
	// to be the kernel stack, but break this into two pieces:
	//     * [KSTACKTOP-KSTKSIZE, KSTACKTOP) -- backed by physical memory
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	// 将内核的栈bootstack映射到地址KSTACKTOP - KSTKSIZE处，用户不可读写，
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);

	//////////////////////////////////////////////////////////////////////
	// Map all of physical memory at KERNBASE.
	// Ie.  the VA range [KERNBASE, 2^32) should map to
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	// 将[KERNBASE,0xffffffff]全部映射到物理地址0的上方，用户不可读写。
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_W);

	// Initialize the SMP-related parts of the memory map
	mem_init_mp();

	// Check that the initial page directory has been set up correctly.
	check_kern_pgdir();

	// Switch from the minimal entry page directory to the full kern_pgdir
	// page table we just created.	Our instruction pointer should be
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));

	check_page_free_list(0);

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_MP;
	cr0 &= ~(CR0_TS | CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}

// Modify mappings in kern_pgdir to support SMP
//   - Map the per-CPU stacks in the region [KSTACKTOP-PTSIZE, KSTACKTOP)
//
static void
mem_init_mp(void)
{
	// Map per-CPU stacks starting at KSTACKTOP, for up to 'NCPU' CPUs.
	//
	// For CPU i, use the physical memory that 'percpu_kstacks[i]' refers
	// to as its kernel stack. CPU i's kernel stack grows down from virtual
	// address kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP), and is
	// divided into two pieces, just like the single stack you set up in
	// mem_init:
	//     * [kstacktop_i - KSTKSIZE, kstacktop_i)
	//          -- backed by physical memory
	//     * [kstacktop_i - (KSTKSIZE + KSTKGAP), kstacktop_i - KSTKSIZE)
	//          -- not backed; so if the kernel overflows its stack,
	//             it will fault rather than overwrite another CPU's stack.
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:

}

// --------------------------------------------------------------
// Tracking of physical pages.
// The 'pages' array has one 'struct PageInfo' entry per physical page.
// Pages are reference counted, and free pages are kept on a linked list.
// --------------------------------------------------------------

/* pages是一个数组，里面的元素是PageInfo，存着引用计数和next指针；其中一些元素(空闲页)组成一个链表，若pages[i]在链表内(next指针有值)，说明第i页内存是空闲的，用其索引i来找到对应的第i页内存
 * 这样的结构，就是页表的第二层“页”，因此，只需要沿着链表，就可以索引到每一个空闲内存页，一旦其不空闲，将其next指针置null，踢出链表即可
 */
void page_init(void)
{
	// LAB 4:
	// Change your code to mark the physical page at MPENTRY_PADDR
	// as in use

	// npages_basemem：[KERNBASE,BASEMEM]的内存一共有npages_basemem页，因此将pages数组的前npages_basemem个元素加入链表
	page_free_list = NULL; // page_free_list是static的，不会被初始化，必须给一个初始值

	for (int i = 1; i < npages_basemem; i++) // 将内存中的pages数组初始化为链表，头指针是page_free_list
	{
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i]; // pages中包含了整个内存中的页，page_free_list指向其中空闲的页组成的链表的头部
	}

	// 由于[BASEMEM,pages start]的内存已经被占用，不能使用，因此链表直接跳过这部分
	for (int i = PGNUM(PADDR(boot_alloc(0))); i < npages; i++) // PADDR()将虚拟地址转化为物理地址，boot_alloc(0)得到nextfree的位置(即pages end),PGNUM()求出需要几页才能到达该地址
	{
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}

// 分配一个物理页面，如果alloc_flags==0,则用“\0”字节填充整个返回的物理页,且不增加页面的引用计数。如果分配失败，返回NULL
struct PageInfo *
page_alloc(int alloc_flags)
{
	struct PageInfo *result;
	if (page_free_list) // page_free_list指向空闲页组成的链表的头部
	{
		result = page_free_list;
		page_free_list = page_free_list->pp_link; // 链表next行进
		if (alloc_flags & ALLOC_ZERO)
		{
			memset(page2kva(result), 0, PGSIZE); // page2kva(p)：求得页p的地址，方法就是先求出p的索引i，用i*4096得到地址
		}
		result->pp_ref = 0;
		result->pp_link = NULL; // 确保page_free就可以检查错误
		return result;
	}
	else
	{
		return NULL;
	}
}

// 将页面返回到空闲列表，只有当pp->pp_ref达到0时，才应调用此函数。
void page_free(struct PageInfo *pp)
{
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link != NULL) // 还有人在使用这个page时，调用了释放函数
	{
		panic("can't free this page, this page is in used: page_free() in pmap.c \n");
	}
	pp->pp_link = page_free_list;
	page_free_list = pp;
}

// 减少页面上的引用计数，计数为0就释放它
void page_decref(struct PageInfo *pp)
{
	if (--pp->pp_ref == 0)
		page_free(pp);
}

// 给定指向页面目录的指针“pgdir”，返回指向虚拟地址“va”的页表条目（PTE）的指针，下面是一些变量的含义
// pgdir:指向页表目录(一个数组)，里面每个条目都是32位地址，指向第二层的"页"
// pte_tab:指向页(也是一个数组)，里面每个条目都是PTE
// result:最后得到的PTE的地址
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
	pde_t *pde = &pgdir[PDX(va)]; // 先由PDX(va)得到该地址对应的目录索引，并在目录中索引得到对应条目(一个32位地址),解引用pde即可得到对应条目
	pte_t *pte_tab;
	pte_t *result;

	if (*pde && PTE_P) // 当“va”的PTE所在的页存在，该页对应的条目在目录中的值就!=0
	{
		pte_tab = (pte_t *)KADDR(PTE_ADDR(*pde)); // PTE_ADDR()获得该条目对应的页的物理地址，KADDR()把物理地址转为虚拟地址
		result = &pte_tab[PTX(va)];				  // 页里存的就是PTE表，用PTX(va)得到页索引，索引到对应的pte的地址
	}
	else // 当页不存在，肯定不存在映射
	{
		if (!create)
			return NULL;

		struct PageInfo *pp = page_alloc(ALLOC_ZERO); // 分配新的一页来存储PTE表

		if (!pp) // 如果pp == NULL，分配失败
			return NULL;

		*pde = page2pa(pp) | PTE_P | PTE_W | PTE_U; // 更新目录的条目，以指向新分配的页
		pp->pp_ref++;
		pte_tab = page2kva(pp); // page2kva()：直接由新建的页得到其地址
		result = &pte_tab[PTX(va)];
	}
	return result; // 返回PTE的指针，这只是找到PTE的位置，写入PTE才是完成映射
}

// 在以pgdir为根的页表中将虚拟地址[va，va + size）映射到物理地址[pa，pa + size）。大小是PGSIZE的倍数，并且va和pa都是页面对齐的
static void boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	for (int i = 0; i < size; i += PGSIZE) // 以页为单位操作映射
	{
		tlb_invalidate(pgdir, (void *)va + i);					 // 使TLB无效
		pte_t *pte = pgdir_walk(pgdir, (const void *)va + i, 1); // 得到虚拟地址对应的pte
		*pte = (pa + i) | PTE_P | perm;							 // 物理地址写入PTE,完成映射
	}
}

// 将物理页面“pp”映射到虚拟地址“va”。页表条目的权限（低12位）应该设置为'perm | PTE_P'
int page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1); // 得到pte的指针，create=1,代表有必要会创建新的页
	if (pte == NULL)
		return -E_NO_MEM;

	pp->pp_ref++;

	if (*pte & PTE_P)
		page_remove(pgdir, va);

	boot_map_region(pgdir, (uintptr_t)va, PGSIZE, page2pa(pp), perm);
	return 0;
}

// 返回映射到虚拟地址“va”的页面。如果pte_store不为零，那么我们将此页面的 pte_t 地址存储在其中
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0); // 得到“va”的PTE的指针
	if (pte == NULL)					   // 若PTE不存在，则“va”没有映射到对应的物理地址
		return NULL;

	if (pte_store)
	{
		*pte_store = pte;
	}
	return pa2page(PTE_ADDR(*pte)); // PTE_ADDR(*pte)：根据pte得到物理地址，pa2page()：根据物理地址得到页面
}

// 在虚拟地址“va”处取消对物理页面的映射。如果该地址上没有物理页面，则不执行任何操作
void page_remove(pde_t *pgdir, void *va)
{
	// Fill this function in
	pte_t *pte_store;
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store); // 得到“va”对应的页面，和指向对应的pte的指针pte_store

	if (pp)
	{
		page_decref(pp);
		tlb_invalidate(pgdir, va); // 如果从页表中删除条目，则TLB必须无效
		*pte_store = 0;
	}
}

// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void tlb_invalidate(pde_t *pgdir, void *va)
{
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
		invlpg(va);
}

//
// Reserve size bytes in the MMIO region and map [pa,pa+size) at this
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
	// Where to start the next region.  Initially, this is the
	// beginning of the MMIO region.  Because this is static, its
	// value will be preserved between calls to mmio_map_region
	// (just like nextfree in boot_alloc).
	static uintptr_t base = MMIOBASE;

	// Reserve size bytes of virtual memory starting at base and
	// map physical pages [pa,pa+size) to virtual addresses
	// [base,base+size).  Since this is device memory and not
	// regular DRAM, you'll have to tell the CPU that it isn't
	// safe to cache access to this memory.  Luckily, the page
	// tables provide bits for this purpose; simply create the
	// mapping with PTE_PCD|PTE_PWT (cache-disable and
	// write-through) in addition to PTE_W.  (If you're interested
	// in more details on this, see section 10.5 of IA32 volume
	// 3A.)
	//
	// Be sure to round size up to a multiple of PGSIZE and to
	// handle if this reservation would overflow MMIOLIM (it's
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	panic("mmio_map_region not implemented");
}

static uintptr_t user_mem_check_addr;

//
// Check that an environment is allowed to access the range of memory
// [va, va+len) with permissions 'perm | PTE_P'.
// Normally 'perm' will contain PTE_U at least, but this is not required.
// 'va' and 'len' need not be page-aligned; you must test every page that
// contains any of that range.  You will test either 'len/PGSIZE',
// 'len/PGSIZE + 1', or 'len/PGSIZE + 2' pages.
//
// A user program can access a virtual address if (1) the address is below
// ULIM, and (2) the page table gives it permission.  These are exactly
// the tests you should implement here.
//
// If there is an error, set the 'user_mem_check_addr' variable to the first
// erroneous virtual address.
//
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	// 先做个页面对齐
	const void *start = ROUNDDOWN(va, PGSIZE);
	const void *end = ROUNDUP(va + len, PGSIZE);
	for (; start < end; start += PGSIZE) // 遍历每一页
	{
		pte_t *pte = pgdir_walk(env->env_pgdir, start, 0);	   // 找到pte,pte只能在ULIM下方，因此若pte存在，则地址存在
		if (!pte || (*pte & (perm | PTE_P)) != (perm | PTE_P)) // 确认权限，&操作可以得到那几个权限位来判断
		{
			user_mem_check_addr = (uintptr_t)MAX(start, va); // 第一个错误的虚拟地址
			return -E_FAULT;								 // 提前返回
		}
	}
	return 0;
}

//
// Checks that environment 'env' is allowed to access the range
// of memory [va, va+len) with permissions 'perm | PTE_U | PTE_P'.
// If it can, then the function simply returns.
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
	if (user_mem_check(env, va, len, perm | PTE_U) < 0)
	{
		cprintf("[%08x] user_mem_check assertion failure for "
				"va %08x\n",
				env->env_id, user_mem_check_addr);
		env_destroy(env); // may not return
	}
}

// --------------------------------------------------------------
// Checking functions.
// --------------------------------------------------------------

// Check that the pages on the page_free_list are reasonable.
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");

	if (only_low_memory)
	{
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = {&pp1, &pp2};
		for (pp = page_free_list; pp; pp = pp->pp_link)
		{
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
		*tp[0] = pp2;
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *)boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link)
	{
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
		assert(pp < pages + npages);
		assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}

// Check the physical page allocator (page_alloc(), page_free(),
// and page_init()).
//
static void
check_page_alloc(void)
{
	struct PageInfo *pp, *pp0, *pp1, *pp2;
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
	assert((pp1 = page_alloc(0)));
	assert((pp2 = page_alloc(0)));

	assert(pp0);
	assert(pp1 && pp1 != pp0);
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
	assert(page2pa(pp0) < npages * PGSIZE);
	assert(page2pa(pp1) < npages * PGSIZE);
	assert(page2pa(pp2) < npages * PGSIZE);

	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;

	// should be no free memory
	assert(!page_alloc(0));

	// free and re-allocate?
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
	assert((pp1 = page_alloc(0)));
	assert((pp2 = page_alloc(0)));
	assert(pp0);
	assert(pp1 && pp1 != pp0);
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
	assert(!page_alloc(0));

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;

	// free the pages we took
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
		--nfree;
	assert(nfree == 0);

	cprintf("check_page_alloc() succeeded!\n");
}

// Checks that the kernel part of virtual address space
// has been set up roughly correctly (by mem_init()).
//
// This function doesn't test every corner case,
// but it is a pretty good sanity check.
//

static void
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV * sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++)
	{
		switch (i)
		{
		case PDX(UVPT):
		case PDX(KSTACKTOP - 1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE))
			{
				assert(pgdir[i] & PTE_P);
				assert(pgdir[i] & PTE_W);
			}
			else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
}

// This function returns the physical address of the page containing 'va',
// defined by the page directory 'pgdir'.  The hardware normally performs
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t *)KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}

// check page_insert, page_remove, &c
static void
check_page(void)
{
	struct PageInfo *pp, *pp0, *pp1, *pp2;
	struct PageInfo *fl;
	pte_t *ptep, *ptep1;
	void *va;
	uintptr_t mm1, mm2;
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
	assert((pp1 = page_alloc(0)));
	assert((pp2 = page_alloc(0)));

	assert(pp0);
	assert(pp1 && pp1 != pp0);
	assert(pp2 && pp2 != pp1 && pp2 != pp0);

	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;

	// should be no free memory
	assert(!page_alloc(0));

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *)0x0, &ptep) == NULL);

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
	assert(pp1->pp_ref == 1);
	assert(pp0->pp_ref == 1);
	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
	assert(pp2->pp_ref == 1);

	// should be no free memory
	assert(!page_alloc(0));

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
	assert(pp2->pp_ref == 1);

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
	assert(pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W | PTE_U) == 0);
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
	assert(pp2->pp_ref == 1);
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U);
	assert(kern_pgdir[0] & PTE_U);

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_W);
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void *)PTSIZE, PTE_W) < 0);

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W) == 0);
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
	assert(pp2->pp_ref == 0);

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
	assert(pp1->pp_ref == 1);
	assert(pp2->pp_ref == 0);

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, 0) == 0);
	assert(pp1->pp_ref);
	assert(pp1->pp_link == NULL);

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void *)PGSIZE);
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
	assert(pp1->pp_ref == 0);
	assert(pp2->pp_ref == 0);

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);

	// should be no free memory
	assert(!page_alloc(0));

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
	kern_pgdir[0] = 0;
	assert(pp0->pp_ref == 1);
	pp0->pp_ref = 0;

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
	va = (void *)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
	ptep1 = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
	assert(ptep == ptep1 + PTX(va));
	kern_pgdir[PDX(va)] = 0;
	pp0->pp_ref = 0;

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *)page2kva(pp0);
	for (i = 0; i < NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
	pp0->pp_ref = 0;

	// give free list back
	page_free_list = fl;

	// free the pages we took
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
	assert(check_va2pa(kern_pgdir, mm2) == 0);
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;

	cprintf("check_page() succeeded!\n");
}

// check page_insert, page_remove, &c, with an installed kern_pgdir
static void
check_page_installed_pgdir(void)
{
	struct PageInfo *pp, *pp0, *pp1, *pp2;
	struct PageInfo *fl;
	pte_t *ptep, *ptep1;
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
	assert((pp1 = page_alloc(0)));
	assert((pp2 = page_alloc(0)));
	page_free(pp0);
	memset(page2kva(pp1), 1, PGSIZE);
	memset(page2kva(pp2), 2, PGSIZE);
	page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W);
	assert(pp1->pp_ref == 1);
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
	page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W);
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
	assert(pp2->pp_ref == 1);
	assert(pp1->pp_ref == 0);
	*(uint32_t *)PGSIZE = 0x03030303U;
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
	page_remove(kern_pgdir, (void *)PGSIZE);
	assert(pp2->pp_ref == 0);

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
	kern_pgdir[0] = 0;
	assert(pp0->pp_ref == 1);
	pp0->pp_ref = 0;

	// free the pages we took
	page_free(pp0);

	cprintf("check_page_installed_pgdir() succeeded!\n");
}
