/*
 * @Author: imwyf 1185095602@qq.com
 * @Date: 2023-06-05 10:09:15
 * @LastEditors: imwyf 1185095602@qq.com
 * @LastEditTime: 2023-06-22 13:35:19
 * @FilePath: /imwyf/6.828/lab/inc/env.h
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
/*
 * @Author: imwyf 1185095602@qq.com
 * @Date: 2023-05-26 16:31:18
 * @LastEditors: imwyf 1185095602@qq.com
 * @LastEditTime: 2023-06-05 10:10:26
 * @FilePath: /imwyf/6.828/lab/inc/env.h
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
/* See COPYRIGHT for copyright information. */

#ifndef JOS_INC_ENV_H
#define JOS_INC_ENV_H

#include <inc/types.h>
#include <inc/trap.h>
#include <inc/memlayout.h>

typedef int32_t envid_t;

// An environment ID 'envid_t' has three parts:
//
// +1+---------------21-----------------+--------10--------+
// |0|          Uniqueifier             |   Environment    |
// | |                                  |      Index       |
// +------------------------------------+------------------+
//                                       \--- ENVX(eid) --/
//
// The environment index ENVX(eid) equals the environment's index in the
// 'envs[]' array.  The uniqueifier distinguishes environments that were
// created at different times, but share the same environment index.
//
// All real environments are greater than 0 (so the sign bit is zero).
// envid_ts less than 0 signify errors.  The envid_t == 0 is special, and
// stands for the current environment.

#define LOG2NENV 10
#define NENV (1 << LOG2NENV)
#define ENVX(envid) ((envid) & (NENV - 1))

// Values of env_status in struct Env
enum
{
	ENV_FREE = 0,
	ENV_DYING,
	ENV_RUNNABLE,
	ENV_RUNNING,
	ENV_NOT_RUNNABLE
};

// Special environment types
enum EnvType
{
	ENV_TYPE_USER = 0,
};

struct Env
{
	struct Trapframe env_tf; // 保存的寄存器值，当从用户模式切换到内核模式时，内核会保存这些内容，以便以后恢复环境
	struct Env *env_link;	 // Next 指针
	envid_t env_id;			 // 该id唯一地标识使用此Env结构的环境，在用户环境终止后，内核可以将相同的Env结构重新分配给不同的环境，但新环境将具有与旧环境不同的id
	envid_t env_parent_id;	 // 创建该环境的环境的id
	enum EnvType env_type;	 // 用来区分特殊环境的，对于大多数环境，它的值是ENV_TYPE_USER
	unsigned env_status;	 // 指示环境的状态：有五种
							 // ENV_FREE:指示Env结构处于非活动状态，因此处于Env_free_list上
							 // ENV_RUNNABLE:指示Env结构等待在处理器上运行
							 // ENV_RUNNING:指示Env结构是当前运行的环境
							 // ENV_NOT_RUNNABLE:指示Env结构尚未准备好运行：例如，它正在等待来自另一个环境的进程间通信（IPC）
							 // ENV_DYING:指示环境结构表示僵尸环境，僵尸环境将在进入到内核时被释放
	uint32_t env_runs;		 // Number of times environment has run
	int env_cpunum;			 // The CPU that the env is running on

	// Address space
	pde_t *env_pgdir; // 此变量保存此环境的页表目录的虚拟地址。

	// Exception handling
	void *env_pgfault_upcall; // Page fault upcall entry point

	// Lab 4 IPC
	bool env_ipc_recving;	// Env is blocked receiving
	void *env_ipc_dstva;	// VA at which to map received page
	uint32_t env_ipc_value; // Data value sent to us
	envid_t env_ipc_from;	// envid of the sender
	int env_ipc_perm;		// Perm of page mapping received
};

#endif // !JOS_INC_ENV_H
