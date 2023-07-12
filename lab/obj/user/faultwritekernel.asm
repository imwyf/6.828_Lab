
obj/user/faultwritekernel.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:

const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	83 ec 10             	sub    $0x10,%esp
  80004a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())]; // ENVX()得到id在Env[]数组中对应的下标
  800050:	e8 d8 00 00 00       	call   80012d <sys_getenvid>
  800055:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800062:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800067:	85 db                	test   %ebx,%ebx
  800069:	7e 07                	jle    800072 <libmain+0x30>
		binaryname = argv[0];
  80006b:	8b 06                	mov    (%esi),%eax
  80006d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800072:	89 74 24 04          	mov    %esi,0x4(%esp)
  800076:	89 1c 24             	mov    %ebx,(%esp)
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 07 00 00 00       	call   80008a <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	5b                   	pop    %ebx
  800087:	5e                   	pop    %esi
  800088:	5d                   	pop    %ebp
  800089:	c3                   	ret    

0080008a <exit>:
 */

#include <inc/lib.h>

void exit(void)
{
  80008a:	55                   	push   %ebp
  80008b:	89 e5                	mov    %esp,%ebp
  80008d:	83 ec 18             	sub    $0x18,%esp
	// close_all();
	sys_env_destroy(0);
  800090:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800097:	e8 3f 00 00 00       	call   8000db <sys_env_destroy>
}
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7e 28                	jle    800125 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800101:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800108:	00 
  800109:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  800110:	00 
  800111:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800118:	00 
  800119:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  800120:	e8 ae 02 00 00       	call   8003d3 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800125:	83 c4 2c             	add    $0x2c,%esp
  800128:	5b                   	pop    %ebx
  800129:	5e                   	pop    %esi
  80012a:	5f                   	pop    %edi
  80012b:	5d                   	pop    %ebp
  80012c:	c3                   	ret    

0080012d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	57                   	push   %edi
  800131:	56                   	push   %esi
  800132:	53                   	push   %ebx
	asm volatile("int %1\n"
  800133:	ba 00 00 00 00       	mov    $0x0,%edx
  800138:	b8 02 00 00 00       	mov    $0x2,%eax
  80013d:	89 d1                	mov    %edx,%ecx
  80013f:	89 d3                	mov    %edx,%ebx
  800141:	89 d7                	mov    %edx,%edi
  800143:	89 d6                	mov    %edx,%esi
  800145:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800147:	5b                   	pop    %ebx
  800148:	5e                   	pop    %esi
  800149:	5f                   	pop    %edi
  80014a:	5d                   	pop    %ebp
  80014b:	c3                   	ret    

0080014c <sys_yield>:

void
sys_yield(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	57                   	push   %edi
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
	asm volatile("int %1\n"
  800152:	ba 00 00 00 00       	mov    $0x0,%edx
  800157:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015c:	89 d1                	mov    %edx,%ecx
  80015e:	89 d3                	mov    %edx,%ebx
  800160:	89 d7                	mov    %edx,%edi
  800162:	89 d6                	mov    %edx,%esi
  800164:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800166:	5b                   	pop    %ebx
  800167:	5e                   	pop    %esi
  800168:	5f                   	pop    %edi
  800169:	5d                   	pop    %ebp
  80016a:	c3                   	ret    

0080016b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	57                   	push   %edi
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
  800171:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800174:	be 00 00 00 00       	mov    $0x0,%esi
  800179:	b8 04 00 00 00       	mov    $0x4,%eax
  80017e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800181:	8b 55 08             	mov    0x8(%ebp),%edx
  800184:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800187:	89 f7                	mov    %esi,%edi
  800189:	cd 30                	int    $0x30
	if(check && ret > 0)
  80018b:	85 c0                	test   %eax,%eax
  80018d:	7e 28                	jle    8001b7 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800193:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80019a:	00 
  80019b:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  8001a2:	00 
  8001a3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001aa:	00 
  8001ab:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  8001b2:	e8 1c 02 00 00       	call   8003d3 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b7:	83 c4 2c             	add    $0x2c,%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5f                   	pop    %edi
  8001bd:	5d                   	pop    %ebp
  8001be:	c3                   	ret    

008001bf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bf:	55                   	push   %ebp
  8001c0:	89 e5                	mov    %esp,%ebp
  8001c2:	57                   	push   %edi
  8001c3:	56                   	push   %esi
  8001c4:	53                   	push   %ebx
  8001c5:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8001c8:	b8 05 00 00 00       	mov    $0x5,%eax
  8001cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d9:	8b 75 18             	mov    0x18(%ebp),%esi
  8001dc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001de:	85 c0                	test   %eax,%eax
  8001e0:	7e 28                	jle    80020a <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001e6:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001ed:	00 
  8001ee:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  8001f5:	00 
  8001f6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001fd:	00 
  8001fe:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  800205:	e8 c9 01 00 00       	call   8003d3 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80020a:	83 c4 2c             	add    $0x2c,%esp
  80020d:	5b                   	pop    %ebx
  80020e:	5e                   	pop    %esi
  80020f:	5f                   	pop    %edi
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    

00800212 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	57                   	push   %edi
  800216:	56                   	push   %esi
  800217:	53                   	push   %ebx
  800218:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80021b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800220:	b8 06 00 00 00       	mov    $0x6,%eax
  800225:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800228:	8b 55 08             	mov    0x8(%ebp),%edx
  80022b:	89 df                	mov    %ebx,%edi
  80022d:	89 de                	mov    %ebx,%esi
  80022f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800231:	85 c0                	test   %eax,%eax
  800233:	7e 28                	jle    80025d <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800235:	89 44 24 10          	mov    %eax,0x10(%esp)
  800239:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800240:	00 
  800241:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  800248:	00 
  800249:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800250:	00 
  800251:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  800258:	e8 76 01 00 00       	call   8003d3 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80025d:	83 c4 2c             	add    $0x2c,%esp
  800260:	5b                   	pop    %ebx
  800261:	5e                   	pop    %esi
  800262:	5f                   	pop    %edi
  800263:	5d                   	pop    %ebp
  800264:	c3                   	ret    

00800265 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	57                   	push   %edi
  800269:	56                   	push   %esi
  80026a:	53                   	push   %ebx
  80026b:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80026e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800273:	b8 08 00 00 00       	mov    $0x8,%eax
  800278:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027b:	8b 55 08             	mov    0x8(%ebp),%edx
  80027e:	89 df                	mov    %ebx,%edi
  800280:	89 de                	mov    %ebx,%esi
  800282:	cd 30                	int    $0x30
	if(check && ret > 0)
  800284:	85 c0                	test   %eax,%eax
  800286:	7e 28                	jle    8002b0 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800288:	89 44 24 10          	mov    %eax,0x10(%esp)
  80028c:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800293:	00 
  800294:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  80029b:	00 
  80029c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002a3:	00 
  8002a4:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  8002ab:	e8 23 01 00 00       	call   8003d3 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002b0:	83 c4 2c             	add    $0x2c,%esp
  8002b3:	5b                   	pop    %ebx
  8002b4:	5e                   	pop    %esi
  8002b5:	5f                   	pop    %edi
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    

008002b8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	57                   	push   %edi
  8002bc:	56                   	push   %esi
  8002bd:	53                   	push   %ebx
  8002be:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8002c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c6:	b8 09 00 00 00       	mov    $0x9,%eax
  8002cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d1:	89 df                	mov    %ebx,%edi
  8002d3:	89 de                	mov    %ebx,%esi
  8002d5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d7:	85 c0                	test   %eax,%eax
  8002d9:	7e 28                	jle    800303 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002db:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002df:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002e6:	00 
  8002e7:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  8002ee:	00 
  8002ef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f6:	00 
  8002f7:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  8002fe:	e8 d0 00 00 00       	call   8003d3 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800303:	83 c4 2c             	add    $0x2c,%esp
  800306:	5b                   	pop    %ebx
  800307:	5e                   	pop    %esi
  800308:	5f                   	pop    %edi
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	57                   	push   %edi
  80030f:	56                   	push   %esi
  800310:	53                   	push   %ebx
  800311:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800314:	bb 00 00 00 00       	mov    $0x0,%ebx
  800319:	b8 0a 00 00 00       	mov    $0xa,%eax
  80031e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	89 df                	mov    %ebx,%edi
  800326:	89 de                	mov    %ebx,%esi
  800328:	cd 30                	int    $0x30
	if(check && ret > 0)
  80032a:	85 c0                	test   %eax,%eax
  80032c:	7e 28                	jle    800356 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800332:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800339:	00 
  80033a:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  800341:	00 
  800342:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800349:	00 
  80034a:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  800351:	e8 7d 00 00 00       	call   8003d3 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800356:	83 c4 2c             	add    $0x2c,%esp
  800359:	5b                   	pop    %ebx
  80035a:	5e                   	pop    %esi
  80035b:	5f                   	pop    %edi
  80035c:	5d                   	pop    %ebp
  80035d:	c3                   	ret    

0080035e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	57                   	push   %edi
  800362:	56                   	push   %esi
  800363:	53                   	push   %ebx
	asm volatile("int %1\n"
  800364:	be 00 00 00 00       	mov    $0x0,%esi
  800369:	b8 0c 00 00 00       	mov    $0xc,%eax
  80036e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800371:	8b 55 08             	mov    0x8(%ebp),%edx
  800374:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800377:	8b 7d 14             	mov    0x14(%ebp),%edi
  80037a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80037c:	5b                   	pop    %ebx
  80037d:	5e                   	pop    %esi
  80037e:	5f                   	pop    %edi
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	57                   	push   %edi
  800385:	56                   	push   %esi
  800386:	53                   	push   %ebx
  800387:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80038a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800394:	8b 55 08             	mov    0x8(%ebp),%edx
  800397:	89 cb                	mov    %ecx,%ebx
  800399:	89 cf                	mov    %ecx,%edi
  80039b:	89 ce                	mov    %ecx,%esi
  80039d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80039f:	85 c0                	test   %eax,%eax
  8003a1:	7e 28                	jle    8003cb <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003a3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003a7:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003ae:	00 
  8003af:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  8003b6:	00 
  8003b7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003be:	00 
  8003bf:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  8003c6:	e8 08 00 00 00       	call   8003d3 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003cb:	83 c4 2c             	add    $0x2c,%esp
  8003ce:	5b                   	pop    %ebx
  8003cf:	5e                   	pop    %esi
  8003d0:	5f                   	pop    %edi
  8003d1:	5d                   	pop    %ebp
  8003d2:	c3                   	ret    

008003d3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	56                   	push   %esi
  8003d7:	53                   	push   %ebx
  8003d8:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003db:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003de:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8003e4:	e8 44 fd ff ff       	call   80012d <sys_getenvid>
  8003e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ec:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003f7:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ff:	c7 04 24 18 11 80 00 	movl   $0x801118,(%esp)
  800406:	e8 c1 00 00 00       	call   8004cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80040b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80040f:	8b 45 10             	mov    0x10(%ebp),%eax
  800412:	89 04 24             	mov    %eax,(%esp)
  800415:	e8 51 00 00 00       	call   80046b <vcprintf>
	cprintf("\n");
  80041a:	c7 04 24 3b 11 80 00 	movl   $0x80113b,(%esp)
  800421:	e8 a6 00 00 00       	call   8004cc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800426:	cc                   	int3   
  800427:	eb fd                	jmp    800426 <_panic+0x53>

00800429 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	53                   	push   %ebx
  80042d:	83 ec 14             	sub    $0x14,%esp
  800430:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800433:	8b 13                	mov    (%ebx),%edx
  800435:	8d 42 01             	lea    0x1(%edx),%eax
  800438:	89 03                	mov    %eax,(%ebx)
  80043a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800441:	3d ff 00 00 00       	cmp    $0xff,%eax
  800446:	75 19                	jne    800461 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800448:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80044f:	00 
  800450:	8d 43 08             	lea    0x8(%ebx),%eax
  800453:	89 04 24             	mov    %eax,(%esp)
  800456:	e8 43 fc ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  80045b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800461:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800465:	83 c4 14             	add    $0x14,%esp
  800468:	5b                   	pop    %ebx
  800469:	5d                   	pop    %ebp
  80046a:	c3                   	ret    

0080046b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80046b:	55                   	push   %ebp
  80046c:	89 e5                	mov    %esp,%ebp
  80046e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800474:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80047b:	00 00 00 
	b.cnt = 0;
  80047e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800485:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800488:	8b 45 0c             	mov    0xc(%ebp),%eax
  80048b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80048f:	8b 45 08             	mov    0x8(%ebp),%eax
  800492:	89 44 24 08          	mov    %eax,0x8(%esp)
  800496:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80049c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a0:	c7 04 24 29 04 80 00 	movl   $0x800429,(%esp)
  8004a7:	e8 b2 01 00 00       	call   80065e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004ac:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004bc:	89 04 24             	mov    %eax,(%esp)
  8004bf:	e8 da fb ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  8004c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004ca:	c9                   	leave  
  8004cb:	c3                   	ret    

008004cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004cc:	55                   	push   %ebp
  8004cd:	89 e5                	mov    %esp,%ebp
  8004cf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004dc:	89 04 24             	mov    %eax,(%esp)
  8004df:	e8 87 ff ff ff       	call   80046b <vcprintf>
	va_end(ap);

	return cnt;
}
  8004e4:	c9                   	leave  
  8004e5:	c3                   	ret    
  8004e6:	66 90                	xchg   %ax,%ax
  8004e8:	66 90                	xchg   %ax,%ax
  8004ea:	66 90                	xchg   %ax,%ax
  8004ec:	66 90                	xchg   %ax,%ax
  8004ee:	66 90                	xchg   %ax,%ax

008004f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	57                   	push   %edi
  8004f4:	56                   	push   %esi
  8004f5:	53                   	push   %ebx
  8004f6:	83 ec 3c             	sub    $0x3c,%esp
  8004f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004fc:	89 d7                	mov    %edx,%edi
  8004fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800501:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800504:	8b 45 0c             	mov    0xc(%ebp),%eax
  800507:	89 c3                	mov    %eax,%ebx
  800509:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80050c:	8b 45 10             	mov    0x10(%ebp),%eax
  80050f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  800512:	b9 00 00 00 00       	mov    $0x0,%ecx
  800517:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80051d:	39 d9                	cmp    %ebx,%ecx
  80051f:	72 05                	jb     800526 <printnum+0x36>
  800521:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800524:	77 69                	ja     80058f <printnum+0x9f>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800526:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800529:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80052d:	83 ee 01             	sub    $0x1,%esi
  800530:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800534:	89 44 24 08          	mov    %eax,0x8(%esp)
  800538:	8b 44 24 08          	mov    0x8(%esp),%eax
  80053c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800540:	89 c3                	mov    %eax,%ebx
  800542:	89 d6                	mov    %edx,%esi
  800544:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800547:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80054a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80054e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800552:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800555:	89 04 24             	mov    %eax,(%esp)
  800558:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80055b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055f:	e8 ec 08 00 00       	call   800e50 <__udivdi3>
  800564:	89 d9                	mov    %ebx,%ecx
  800566:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80056a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80056e:	89 04 24             	mov    %eax,(%esp)
  800571:	89 54 24 04          	mov    %edx,0x4(%esp)
  800575:	89 fa                	mov    %edi,%edx
  800577:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80057a:	e8 71 ff ff ff       	call   8004f0 <printnum>
  80057f:	eb 1b                	jmp    80059c <printnum+0xac>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800581:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800585:	8b 45 18             	mov    0x18(%ebp),%eax
  800588:	89 04 24             	mov    %eax,(%esp)
  80058b:	ff d3                	call   *%ebx
  80058d:	eb 03                	jmp    800592 <printnum+0xa2>
  80058f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800592:	83 ee 01             	sub    $0x1,%esi
  800595:	85 f6                	test   %esi,%esi
  800597:	7f e8                	jg     800581 <printnum+0x91>
  800599:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80059c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005a4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ae:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b5:	89 04 24             	mov    %eax,(%esp)
  8005b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005bf:	e8 bc 09 00 00       	call   800f80 <__umoddi3>
  8005c4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005c8:	0f be 80 3d 11 80 00 	movsbl 0x80113d(%eax),%eax
  8005cf:	89 04 24             	mov    %eax,(%esp)
  8005d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005d5:	ff d0                	call   *%eax
}
  8005d7:	83 c4 3c             	add    $0x3c,%esp
  8005da:	5b                   	pop    %ebx
  8005db:	5e                   	pop    %esi
  8005dc:	5f                   	pop    %edi
  8005dd:	5d                   	pop    %ebp
  8005de:	c3                   	ret    

008005df <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005df:	55                   	push   %ebp
  8005e0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005e2:	83 fa 01             	cmp    $0x1,%edx
  8005e5:	7e 0e                	jle    8005f5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005e7:	8b 10                	mov    (%eax),%edx
  8005e9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005ec:	89 08                	mov    %ecx,(%eax)
  8005ee:	8b 02                	mov    (%edx),%eax
  8005f0:	8b 52 04             	mov    0x4(%edx),%edx
  8005f3:	eb 22                	jmp    800617 <getuint+0x38>
	else if (lflag)
  8005f5:	85 d2                	test   %edx,%edx
  8005f7:	74 10                	je     800609 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005f9:	8b 10                	mov    (%eax),%edx
  8005fb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005fe:	89 08                	mov    %ecx,(%eax)
  800600:	8b 02                	mov    (%edx),%eax
  800602:	ba 00 00 00 00       	mov    $0x0,%edx
  800607:	eb 0e                	jmp    800617 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800609:	8b 10                	mov    (%eax),%edx
  80060b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80060e:	89 08                	mov    %ecx,(%eax)
  800610:	8b 02                	mov    (%edx),%eax
  800612:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800617:	5d                   	pop    %ebp
  800618:	c3                   	ret    

00800619 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800619:	55                   	push   %ebp
  80061a:	89 e5                	mov    %esp,%ebp
  80061c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80061f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800623:	8b 10                	mov    (%eax),%edx
  800625:	3b 50 04             	cmp    0x4(%eax),%edx
  800628:	73 0a                	jae    800634 <sprintputch+0x1b>
		*b->buf++ = ch;
  80062a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80062d:	89 08                	mov    %ecx,(%eax)
  80062f:	8b 45 08             	mov    0x8(%ebp),%eax
  800632:	88 02                	mov    %al,(%edx)
}
  800634:	5d                   	pop    %ebp
  800635:	c3                   	ret    

00800636 <printfmt>:
{
  800636:	55                   	push   %ebp
  800637:	89 e5                	mov    %esp,%ebp
  800639:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  80063c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80063f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800643:	8b 45 10             	mov    0x10(%ebp),%eax
  800646:	89 44 24 08          	mov    %eax,0x8(%esp)
  80064a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80064d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800651:	8b 45 08             	mov    0x8(%ebp),%eax
  800654:	89 04 24             	mov    %eax,(%esp)
  800657:	e8 02 00 00 00       	call   80065e <vprintfmt>
}
  80065c:	c9                   	leave  
  80065d:	c3                   	ret    

0080065e <vprintfmt>:
{
  80065e:	55                   	push   %ebp
  80065f:	89 e5                	mov    %esp,%ebp
  800661:	57                   	push   %edi
  800662:	56                   	push   %esi
  800663:	53                   	push   %ebx
  800664:	83 ec 3c             	sub    $0x3c,%esp
  800667:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80066a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80066d:	eb 14                	jmp    800683 <vprintfmt+0x25>
			if (ch == '\0')
  80066f:	85 c0                	test   %eax,%eax
  800671:	0f 84 b3 03 00 00    	je     800a2a <vprintfmt+0x3cc>
			putch(ch, putdat);
  800677:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067b:	89 04 24             	mov    %eax,(%esp)
  80067e:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  800681:	89 f3                	mov    %esi,%ebx
  800683:	8d 73 01             	lea    0x1(%ebx),%esi
  800686:	0f b6 03             	movzbl (%ebx),%eax
  800689:	83 f8 25             	cmp    $0x25,%eax
  80068c:	75 e1                	jne    80066f <vprintfmt+0x11>
  80068e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800692:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800699:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8006a0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8006a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ac:	eb 1d                	jmp    8006cb <vprintfmt+0x6d>
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006ae:	89 de                	mov    %ebx,%esi
			padc = '-';
  8006b0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8006b4:	eb 15                	jmp    8006cb <vprintfmt+0x6d>
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006b6:	89 de                	mov    %ebx,%esi
			padc = '0';
  8006b8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8006bc:	eb 0d                	jmp    8006cb <vprintfmt+0x6d>
				width = precision, precision = -1;
  8006be:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006c4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006cb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8006ce:	0f b6 0e             	movzbl (%esi),%ecx
  8006d1:	0f b6 c1             	movzbl %cl,%eax
  8006d4:	83 e9 23             	sub    $0x23,%ecx
  8006d7:	80 f9 55             	cmp    $0x55,%cl
  8006da:	0f 87 2a 03 00 00    	ja     800a0a <vprintfmt+0x3ac>
  8006e0:	0f b6 c9             	movzbl %cl,%ecx
  8006e3:	ff 24 8d 80 12 80 00 	jmp    *0x801280(,%ecx,4)
  8006ea:	89 de                	mov    %ebx,%esi
  8006ec:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  8006f1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8006f4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8006f8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006fb:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8006fe:	83 fb 09             	cmp    $0x9,%ebx
  800701:	77 36                	ja     800739 <vprintfmt+0xdb>
			for (precision = 0;; ++fmt)
  800703:	83 c6 01             	add    $0x1,%esi
			}
  800706:	eb e9                	jmp    8006f1 <vprintfmt+0x93>
			precision = va_arg(ap, int);
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8d 48 04             	lea    0x4(%eax),%ecx
  80070e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800711:	8b 00                	mov    (%eax),%eax
  800713:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800716:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800718:	eb 22                	jmp    80073c <vprintfmt+0xde>
  80071a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80071d:	85 c9                	test   %ecx,%ecx
  80071f:	b8 00 00 00 00       	mov    $0x0,%eax
  800724:	0f 49 c1             	cmovns %ecx,%eax
  800727:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80072a:	89 de                	mov    %ebx,%esi
  80072c:	eb 9d                	jmp    8006cb <vprintfmt+0x6d>
  80072e:	89 de                	mov    %ebx,%esi
			altflag = 1;
  800730:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800737:	eb 92                	jmp    8006cb <vprintfmt+0x6d>
  800739:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  80073c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800740:	79 89                	jns    8006cb <vprintfmt+0x6d>
  800742:	e9 77 ff ff ff       	jmp    8006be <vprintfmt+0x60>
			lflag++;
  800747:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80074a:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80074c:	e9 7a ff ff ff       	jmp    8006cb <vprintfmt+0x6d>
			putch(va_arg(ap, int), putdat);
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	8d 50 04             	lea    0x4(%eax),%edx
  800757:	89 55 14             	mov    %edx,0x14(%ebp)
  80075a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80075e:	8b 00                	mov    (%eax),%eax
  800760:	89 04 24             	mov    %eax,(%esp)
  800763:	ff 55 08             	call   *0x8(%ebp)
			break;
  800766:	e9 18 ff ff ff       	jmp    800683 <vprintfmt+0x25>
			err = va_arg(ap, int);
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8d 50 04             	lea    0x4(%eax),%edx
  800771:	89 55 14             	mov    %edx,0x14(%ebp)
  800774:	8b 00                	mov    (%eax),%eax
  800776:	99                   	cltd   
  800777:	31 d0                	xor    %edx,%eax
  800779:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80077b:	83 f8 0f             	cmp    $0xf,%eax
  80077e:	7f 0b                	jg     80078b <vprintfmt+0x12d>
  800780:	8b 14 85 e0 13 80 00 	mov    0x8013e0(,%eax,4),%edx
  800787:	85 d2                	test   %edx,%edx
  800789:	75 20                	jne    8007ab <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80078b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80078f:	c7 44 24 08 55 11 80 	movl   $0x801155,0x8(%esp)
  800796:	00 
  800797:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	89 04 24             	mov    %eax,(%esp)
  8007a1:	e8 90 fe ff ff       	call   800636 <printfmt>
  8007a6:	e9 d8 fe ff ff       	jmp    800683 <vprintfmt+0x25>
				printfmt(putch, putdat, "%s", p);
  8007ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007af:	c7 44 24 08 5e 11 80 	movl   $0x80115e,0x8(%esp)
  8007b6:	00 
  8007b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007be:	89 04 24             	mov    %eax,(%esp)
  8007c1:	e8 70 fe ff ff       	call   800636 <printfmt>
  8007c6:	e9 b8 fe ff ff       	jmp    800683 <vprintfmt+0x25>
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8007cb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8007ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007d1:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	8d 50 04             	lea    0x4(%eax),%edx
  8007da:	89 55 14             	mov    %edx,0x14(%ebp)
  8007dd:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8007df:	85 f6                	test   %esi,%esi
  8007e1:	b8 4e 11 80 00       	mov    $0x80114e,%eax
  8007e6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8007e9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007ed:	0f 84 97 00 00 00    	je     80088a <vprintfmt+0x22c>
  8007f3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8007f7:	0f 8e 9b 00 00 00    	jle    800898 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007fd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800801:	89 34 24             	mov    %esi,(%esp)
  800804:	e8 cf 02 00 00       	call   800ad8 <strnlen>
  800809:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80080c:	29 c2                	sub    %eax,%edx
  80080e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800811:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800815:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800818:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80081b:	8b 75 08             	mov    0x8(%ebp),%esi
  80081e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800821:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800823:	eb 0f                	jmp    800834 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800825:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800829:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80082c:	89 04 24             	mov    %eax,(%esp)
  80082f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800831:	83 eb 01             	sub    $0x1,%ebx
  800834:	85 db                	test   %ebx,%ebx
  800836:	7f ed                	jg     800825 <vprintfmt+0x1c7>
  800838:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80083b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80083e:	85 d2                	test   %edx,%edx
  800840:	b8 00 00 00 00       	mov    $0x0,%eax
  800845:	0f 49 c2             	cmovns %edx,%eax
  800848:	29 c2                	sub    %eax,%edx
  80084a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80084d:	89 d7                	mov    %edx,%edi
  80084f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800852:	eb 50                	jmp    8008a4 <vprintfmt+0x246>
				if (altflag && (ch < ' ' || ch > '~'))
  800854:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800858:	74 1e                	je     800878 <vprintfmt+0x21a>
  80085a:	0f be d2             	movsbl %dl,%edx
  80085d:	83 ea 20             	sub    $0x20,%edx
  800860:	83 fa 5e             	cmp    $0x5e,%edx
  800863:	76 13                	jbe    800878 <vprintfmt+0x21a>
					putch('?', putdat);
  800865:	8b 45 0c             	mov    0xc(%ebp),%eax
  800868:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800873:	ff 55 08             	call   *0x8(%ebp)
  800876:	eb 0d                	jmp    800885 <vprintfmt+0x227>
					putch(ch, putdat);
  800878:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80087f:	89 04 24             	mov    %eax,(%esp)
  800882:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800885:	83 ef 01             	sub    $0x1,%edi
  800888:	eb 1a                	jmp    8008a4 <vprintfmt+0x246>
  80088a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80088d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800890:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800893:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800896:	eb 0c                	jmp    8008a4 <vprintfmt+0x246>
  800898:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80089b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80089e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8008a1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8008a4:	83 c6 01             	add    $0x1,%esi
  8008a7:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8008ab:	0f be c2             	movsbl %dl,%eax
  8008ae:	85 c0                	test   %eax,%eax
  8008b0:	74 27                	je     8008d9 <vprintfmt+0x27b>
  8008b2:	85 db                	test   %ebx,%ebx
  8008b4:	78 9e                	js     800854 <vprintfmt+0x1f6>
  8008b6:	83 eb 01             	sub    $0x1,%ebx
  8008b9:	79 99                	jns    800854 <vprintfmt+0x1f6>
  8008bb:	89 f8                	mov    %edi,%eax
  8008bd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8008c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c3:	89 c3                	mov    %eax,%ebx
  8008c5:	eb 1a                	jmp    8008e1 <vprintfmt+0x283>
				putch(' ', putdat);
  8008c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008cb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008d2:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8008d4:	83 eb 01             	sub    $0x1,%ebx
  8008d7:	eb 08                	jmp    8008e1 <vprintfmt+0x283>
  8008d9:	89 fb                	mov    %edi,%ebx
  8008db:	8b 75 08             	mov    0x8(%ebp),%esi
  8008de:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8008e1:	85 db                	test   %ebx,%ebx
  8008e3:	7f e2                	jg     8008c7 <vprintfmt+0x269>
  8008e5:	89 75 08             	mov    %esi,0x8(%ebp)
  8008e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008eb:	e9 93 fd ff ff       	jmp    800683 <vprintfmt+0x25>
	if (lflag >= 2)
  8008f0:	83 fa 01             	cmp    $0x1,%edx
  8008f3:	7e 16                	jle    80090b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8008f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f8:	8d 50 08             	lea    0x8(%eax),%edx
  8008fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8008fe:	8b 50 04             	mov    0x4(%eax),%edx
  800901:	8b 00                	mov    (%eax),%eax
  800903:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800906:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800909:	eb 32                	jmp    80093d <vprintfmt+0x2df>
	else if (lflag)
  80090b:	85 d2                	test   %edx,%edx
  80090d:	74 18                	je     800927 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  80090f:	8b 45 14             	mov    0x14(%ebp),%eax
  800912:	8d 50 04             	lea    0x4(%eax),%edx
  800915:	89 55 14             	mov    %edx,0x14(%ebp)
  800918:	8b 30                	mov    (%eax),%esi
  80091a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80091d:	89 f0                	mov    %esi,%eax
  80091f:	c1 f8 1f             	sar    $0x1f,%eax
  800922:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800925:	eb 16                	jmp    80093d <vprintfmt+0x2df>
		return va_arg(*ap, int);
  800927:	8b 45 14             	mov    0x14(%ebp),%eax
  80092a:	8d 50 04             	lea    0x4(%eax),%edx
  80092d:	89 55 14             	mov    %edx,0x14(%ebp)
  800930:	8b 30                	mov    (%eax),%esi
  800932:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800935:	89 f0                	mov    %esi,%eax
  800937:	c1 f8 1f             	sar    $0x1f,%eax
  80093a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  80093d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800940:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10; // base代表进制数
  800943:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long)num < 0)
  800948:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80094c:	0f 89 80 00 00 00    	jns    8009d2 <vprintfmt+0x374>
				putch('-', putdat);
  800952:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800956:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80095d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  800960:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800963:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800966:	f7 d8                	neg    %eax
  800968:	83 d2 00             	adc    $0x0,%edx
  80096b:	f7 da                	neg    %edx
			base = 10; // base代表进制数
  80096d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800972:	eb 5e                	jmp    8009d2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
  800974:	8d 45 14             	lea    0x14(%ebp),%eax
  800977:	e8 63 fc ff ff       	call   8005df <getuint>
			base = 10;
  80097c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800981:	eb 4f                	jmp    8009d2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
  800983:	8d 45 14             	lea    0x14(%ebp),%eax
  800986:	e8 54 fc ff ff       	call   8005df <getuint>
			base = 8;
  80098b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800990:	eb 40                	jmp    8009d2 <vprintfmt+0x374>
			putch('0', putdat);
  800992:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800996:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80099d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009a0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009a4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009ab:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8009ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b1:	8d 50 04             	lea    0x4(%eax),%edx
  8009b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b7:	8b 00                	mov    (%eax),%eax
  8009b9:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  8009be:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8009c3:	eb 0d                	jmp    8009d2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
  8009c5:	8d 45 14             	lea    0x14(%ebp),%eax
  8009c8:	e8 12 fc ff ff       	call   8005df <getuint>
			base = 16;
  8009cd:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  8009d2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8009d6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8009da:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8009dd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8009e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009e5:	89 04 24             	mov    %eax,(%esp)
  8009e8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009ec:	89 fa                	mov    %edi,%edx
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	e8 fa fa ff ff       	call   8004f0 <printnum>
			break;
  8009f6:	e9 88 fc ff ff       	jmp    800683 <vprintfmt+0x25>
			putch(ch, putdat);
  8009fb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009ff:	89 04 24             	mov    %eax,(%esp)
  800a02:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a05:	e9 79 fc ff ff       	jmp    800683 <vprintfmt+0x25>
			putch('%', putdat);
  800a0a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a0e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a15:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a18:	89 f3                	mov    %esi,%ebx
  800a1a:	eb 03                	jmp    800a1f <vprintfmt+0x3c1>
  800a1c:	83 eb 01             	sub    $0x1,%ebx
  800a1f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800a23:	75 f7                	jne    800a1c <vprintfmt+0x3be>
  800a25:	e9 59 fc ff ff       	jmp    800683 <vprintfmt+0x25>
}
  800a2a:	83 c4 3c             	add    $0x3c,%esp
  800a2d:	5b                   	pop    %ebx
  800a2e:	5e                   	pop    %esi
  800a2f:	5f                   	pop    %edi
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	83 ec 28             	sub    $0x28,%esp
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  800a3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a41:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a45:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a48:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a4f:	85 c0                	test   %eax,%eax
  800a51:	74 30                	je     800a83 <vsnprintf+0x51>
  800a53:	85 d2                	test   %edx,%edx
  800a55:	7e 2c                	jle    800a83 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  800a57:	8b 45 14             	mov    0x14(%ebp),%eax
  800a5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a5e:	8b 45 10             	mov    0x10(%ebp),%eax
  800a61:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a65:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a68:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6c:	c7 04 24 19 06 80 00 	movl   $0x800619,(%esp)
  800a73:	e8 e6 fb ff ff       	call   80065e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a78:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a7b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a81:	eb 05                	jmp    800a88 <vsnprintf+0x56>
		return -E_INVAL;
  800a83:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a88:	c9                   	leave  
  800a89:	c3                   	ret    

00800a8a <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a90:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a93:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a97:	8b 45 10             	mov    0x10(%ebp),%eax
  800a9a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa8:	89 04 24             	mov    %eax,(%esp)
  800aab:	e8 82 ff ff ff       	call   800a32 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ab0:	c9                   	leave  
  800ab1:	c3                   	ret    
  800ab2:	66 90                	xchg   %ax,%ax
  800ab4:	66 90                	xchg   %ax,%ax
  800ab6:	66 90                	xchg   %ax,%ax
  800ab8:	66 90                	xchg   %ax,%ax
  800aba:	66 90                	xchg   %ax,%ax
  800abc:	66 90                	xchg   %ax,%ax
  800abe:	66 90                	xchg   %ax,%ax

00800ac0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ac6:	b8 00 00 00 00       	mov    $0x0,%eax
  800acb:	eb 03                	jmp    800ad0 <strlen+0x10>
		n++;
  800acd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800ad0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ad4:	75 f7                	jne    800acd <strlen+0xd>
	return n;
}
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ade:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae6:	eb 03                	jmp    800aeb <strnlen+0x13>
		n++;
  800ae8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aeb:	39 d0                	cmp    %edx,%eax
  800aed:	74 06                	je     800af5 <strnlen+0x1d>
  800aef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800af3:	75 f3                	jne    800ae8 <strnlen+0x10>
	return n;
}
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	53                   	push   %ebx
  800afb:	8b 45 08             	mov    0x8(%ebp),%eax
  800afe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b01:	89 c2                	mov    %eax,%edx
  800b03:	83 c2 01             	add    $0x1,%edx
  800b06:	83 c1 01             	add    $0x1,%ecx
  800b09:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b0d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b10:	84 db                	test   %bl,%bl
  800b12:	75 ef                	jne    800b03 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b14:	5b                   	pop    %ebx
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	53                   	push   %ebx
  800b1b:	83 ec 08             	sub    $0x8,%esp
  800b1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b21:	89 1c 24             	mov    %ebx,(%esp)
  800b24:	e8 97 ff ff ff       	call   800ac0 <strlen>
	strcpy(dst + len, src);
  800b29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b30:	01 d8                	add    %ebx,%eax
  800b32:	89 04 24             	mov    %eax,(%esp)
  800b35:	e8 bd ff ff ff       	call   800af7 <strcpy>
	return dst;
}
  800b3a:	89 d8                	mov    %ebx,%eax
  800b3c:	83 c4 08             	add    $0x8,%esp
  800b3f:	5b                   	pop    %ebx
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
  800b47:	8b 75 08             	mov    0x8(%ebp),%esi
  800b4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4d:	89 f3                	mov    %esi,%ebx
  800b4f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b52:	89 f2                	mov    %esi,%edx
  800b54:	eb 0f                	jmp    800b65 <strncpy+0x23>
		*dst++ = *src;
  800b56:	83 c2 01             	add    $0x1,%edx
  800b59:	0f b6 01             	movzbl (%ecx),%eax
  800b5c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b5f:	80 39 01             	cmpb   $0x1,(%ecx)
  800b62:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800b65:	39 da                	cmp    %ebx,%edx
  800b67:	75 ed                	jne    800b56 <strncpy+0x14>
	}
	return ret;
}
  800b69:	89 f0                	mov    %esi,%eax
  800b6b:	5b                   	pop    %ebx
  800b6c:	5e                   	pop    %esi
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	8b 75 08             	mov    0x8(%ebp),%esi
  800b77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b7d:	89 f0                	mov    %esi,%eax
  800b7f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b83:	85 c9                	test   %ecx,%ecx
  800b85:	75 0b                	jne    800b92 <strlcpy+0x23>
  800b87:	eb 1d                	jmp    800ba6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b89:	83 c0 01             	add    $0x1,%eax
  800b8c:	83 c2 01             	add    $0x1,%edx
  800b8f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800b92:	39 d8                	cmp    %ebx,%eax
  800b94:	74 0b                	je     800ba1 <strlcpy+0x32>
  800b96:	0f b6 0a             	movzbl (%edx),%ecx
  800b99:	84 c9                	test   %cl,%cl
  800b9b:	75 ec                	jne    800b89 <strlcpy+0x1a>
  800b9d:	89 c2                	mov    %eax,%edx
  800b9f:	eb 02                	jmp    800ba3 <strlcpy+0x34>
  800ba1:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800ba3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ba6:	29 f0                	sub    %esi,%eax
}
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bb5:	eb 06                	jmp    800bbd <strcmp+0x11>
		p++, q++;
  800bb7:	83 c1 01             	add    $0x1,%ecx
  800bba:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800bbd:	0f b6 01             	movzbl (%ecx),%eax
  800bc0:	84 c0                	test   %al,%al
  800bc2:	74 04                	je     800bc8 <strcmp+0x1c>
  800bc4:	3a 02                	cmp    (%edx),%al
  800bc6:	74 ef                	je     800bb7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bc8:	0f b6 c0             	movzbl %al,%eax
  800bcb:	0f b6 12             	movzbl (%edx),%edx
  800bce:	29 d0                	sub    %edx,%eax
}
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	53                   	push   %ebx
  800bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bdc:	89 c3                	mov    %eax,%ebx
  800bde:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800be1:	eb 06                	jmp    800be9 <strncmp+0x17>
		n--, p++, q++;
  800be3:	83 c0 01             	add    $0x1,%eax
  800be6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800be9:	39 d8                	cmp    %ebx,%eax
  800beb:	74 15                	je     800c02 <strncmp+0x30>
  800bed:	0f b6 08             	movzbl (%eax),%ecx
  800bf0:	84 c9                	test   %cl,%cl
  800bf2:	74 04                	je     800bf8 <strncmp+0x26>
  800bf4:	3a 0a                	cmp    (%edx),%cl
  800bf6:	74 eb                	je     800be3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bf8:	0f b6 00             	movzbl (%eax),%eax
  800bfb:	0f b6 12             	movzbl (%edx),%edx
  800bfe:	29 d0                	sub    %edx,%eax
  800c00:	eb 05                	jmp    800c07 <strncmp+0x35>
		return 0;
  800c02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c07:	5b                   	pop    %ebx
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c14:	eb 07                	jmp    800c1d <strchr+0x13>
		if (*s == c)
  800c16:	38 ca                	cmp    %cl,%dl
  800c18:	74 0f                	je     800c29 <strchr+0x1f>
	for (; *s; s++)
  800c1a:	83 c0 01             	add    $0x1,%eax
  800c1d:	0f b6 10             	movzbl (%eax),%edx
  800c20:	84 d2                	test   %dl,%dl
  800c22:	75 f2                	jne    800c16 <strchr+0xc>
			return (char *) s;
	return 0;
  800c24:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c35:	eb 07                	jmp    800c3e <strfind+0x13>
		if (*s == c)
  800c37:	38 ca                	cmp    %cl,%dl
  800c39:	74 0a                	je     800c45 <strfind+0x1a>
	for (; *s; s++)
  800c3b:	83 c0 01             	add    $0x1,%eax
  800c3e:	0f b6 10             	movzbl (%eax),%edx
  800c41:	84 d2                	test   %dl,%dl
  800c43:	75 f2                	jne    800c37 <strfind+0xc>
			break;
	return (char *) s;
}
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c50:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c53:	85 c9                	test   %ecx,%ecx
  800c55:	74 36                	je     800c8d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c57:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c5d:	75 28                	jne    800c87 <memset+0x40>
  800c5f:	f6 c1 03             	test   $0x3,%cl
  800c62:	75 23                	jne    800c87 <memset+0x40>
		c &= 0xFF;
  800c64:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c68:	89 d3                	mov    %edx,%ebx
  800c6a:	c1 e3 08             	shl    $0x8,%ebx
  800c6d:	89 d6                	mov    %edx,%esi
  800c6f:	c1 e6 18             	shl    $0x18,%esi
  800c72:	89 d0                	mov    %edx,%eax
  800c74:	c1 e0 10             	shl    $0x10,%eax
  800c77:	09 f0                	or     %esi,%eax
  800c79:	09 c2                	or     %eax,%edx
  800c7b:	89 d0                	mov    %edx,%eax
  800c7d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c7f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c82:	fc                   	cld    
  800c83:	f3 ab                	rep stos %eax,%es:(%edi)
  800c85:	eb 06                	jmp    800c8d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c8a:	fc                   	cld    
  800c8b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c8d:	89 f8                	mov    %edi,%eax
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ca2:	39 c6                	cmp    %eax,%esi
  800ca4:	73 35                	jae    800cdb <memmove+0x47>
  800ca6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ca9:	39 d0                	cmp    %edx,%eax
  800cab:	73 2e                	jae    800cdb <memmove+0x47>
		s += n;
		d += n;
  800cad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800cb0:	89 d6                	mov    %edx,%esi
  800cb2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cba:	75 13                	jne    800ccf <memmove+0x3b>
  800cbc:	f6 c1 03             	test   $0x3,%cl
  800cbf:	75 0e                	jne    800ccf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cc1:	83 ef 04             	sub    $0x4,%edi
  800cc4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cc7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800cca:	fd                   	std    
  800ccb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ccd:	eb 09                	jmp    800cd8 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ccf:	83 ef 01             	sub    $0x1,%edi
  800cd2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800cd5:	fd                   	std    
  800cd6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cd8:	fc                   	cld    
  800cd9:	eb 1d                	jmp    800cf8 <memmove+0x64>
  800cdb:	89 f2                	mov    %esi,%edx
  800cdd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cdf:	f6 c2 03             	test   $0x3,%dl
  800ce2:	75 0f                	jne    800cf3 <memmove+0x5f>
  800ce4:	f6 c1 03             	test   $0x3,%cl
  800ce7:	75 0a                	jne    800cf3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ce9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800cec:	89 c7                	mov    %eax,%edi
  800cee:	fc                   	cld    
  800cef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cf1:	eb 05                	jmp    800cf8 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800cf3:	89 c7                	mov    %eax,%edi
  800cf5:	fc                   	cld    
  800cf6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d02:	8b 45 10             	mov    0x10(%ebp),%eax
  800d05:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d10:	8b 45 08             	mov    0x8(%ebp),%eax
  800d13:	89 04 24             	mov    %eax,(%esp)
  800d16:	e8 79 ff ff ff       	call   800c94 <memmove>
}
  800d1b:	c9                   	leave  
  800d1c:	c3                   	ret    

00800d1d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	89 d6                	mov    %edx,%esi
  800d2a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d2d:	eb 1a                	jmp    800d49 <memcmp+0x2c>
		if (*s1 != *s2)
  800d2f:	0f b6 02             	movzbl (%edx),%eax
  800d32:	0f b6 19             	movzbl (%ecx),%ebx
  800d35:	38 d8                	cmp    %bl,%al
  800d37:	74 0a                	je     800d43 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d39:	0f b6 c0             	movzbl %al,%eax
  800d3c:	0f b6 db             	movzbl %bl,%ebx
  800d3f:	29 d8                	sub    %ebx,%eax
  800d41:	eb 0f                	jmp    800d52 <memcmp+0x35>
		s1++, s2++;
  800d43:	83 c2 01             	add    $0x1,%edx
  800d46:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800d49:	39 f2                	cmp    %esi,%edx
  800d4b:	75 e2                	jne    800d2f <memcmp+0x12>
	}

	return 0;
  800d4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d5f:	89 c2                	mov    %eax,%edx
  800d61:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d64:	eb 07                	jmp    800d6d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d66:	38 08                	cmp    %cl,(%eax)
  800d68:	74 07                	je     800d71 <memfind+0x1b>
	for (; s < ends; s++)
  800d6a:	83 c0 01             	add    $0x1,%eax
  800d6d:	39 d0                	cmp    %edx,%eax
  800d6f:	72 f5                	jb     800d66 <memfind+0x10>
			break;
	return (void *) s;
}
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d7f:	eb 03                	jmp    800d84 <strtol+0x11>
		s++;
  800d81:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800d84:	0f b6 0a             	movzbl (%edx),%ecx
  800d87:	80 f9 09             	cmp    $0x9,%cl
  800d8a:	74 f5                	je     800d81 <strtol+0xe>
  800d8c:	80 f9 20             	cmp    $0x20,%cl
  800d8f:	74 f0                	je     800d81 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800d91:	80 f9 2b             	cmp    $0x2b,%cl
  800d94:	75 0a                	jne    800da0 <strtol+0x2d>
		s++;
  800d96:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800d99:	bf 00 00 00 00       	mov    $0x0,%edi
  800d9e:	eb 11                	jmp    800db1 <strtol+0x3e>
  800da0:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800da5:	80 f9 2d             	cmp    $0x2d,%cl
  800da8:	75 07                	jne    800db1 <strtol+0x3e>
		s++, neg = 1;
  800daa:	8d 52 01             	lea    0x1(%edx),%edx
  800dad:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800db1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800db6:	75 15                	jne    800dcd <strtol+0x5a>
  800db8:	80 3a 30             	cmpb   $0x30,(%edx)
  800dbb:	75 10                	jne    800dcd <strtol+0x5a>
  800dbd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800dc1:	75 0a                	jne    800dcd <strtol+0x5a>
		s += 2, base = 16;
  800dc3:	83 c2 02             	add    $0x2,%edx
  800dc6:	b8 10 00 00 00       	mov    $0x10,%eax
  800dcb:	eb 10                	jmp    800ddd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	75 0c                	jne    800ddd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800dd1:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800dd3:	80 3a 30             	cmpb   $0x30,(%edx)
  800dd6:	75 05                	jne    800ddd <strtol+0x6a>
		s++, base = 8;
  800dd8:	83 c2 01             	add    $0x1,%edx
  800ddb:	b0 08                	mov    $0x8,%al
		base = 10;
  800ddd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800de5:	0f b6 0a             	movzbl (%edx),%ecx
  800de8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800deb:	89 f0                	mov    %esi,%eax
  800ded:	3c 09                	cmp    $0x9,%al
  800def:	77 08                	ja     800df9 <strtol+0x86>
			dig = *s - '0';
  800df1:	0f be c9             	movsbl %cl,%ecx
  800df4:	83 e9 30             	sub    $0x30,%ecx
  800df7:	eb 20                	jmp    800e19 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800df9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800dfc:	89 f0                	mov    %esi,%eax
  800dfe:	3c 19                	cmp    $0x19,%al
  800e00:	77 08                	ja     800e0a <strtol+0x97>
			dig = *s - 'a' + 10;
  800e02:	0f be c9             	movsbl %cl,%ecx
  800e05:	83 e9 57             	sub    $0x57,%ecx
  800e08:	eb 0f                	jmp    800e19 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800e0a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800e0d:	89 f0                	mov    %esi,%eax
  800e0f:	3c 19                	cmp    $0x19,%al
  800e11:	77 16                	ja     800e29 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800e13:	0f be c9             	movsbl %cl,%ecx
  800e16:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e19:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800e1c:	7d 0f                	jge    800e2d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800e1e:	83 c2 01             	add    $0x1,%edx
  800e21:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800e25:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800e27:	eb bc                	jmp    800de5 <strtol+0x72>
  800e29:	89 d8                	mov    %ebx,%eax
  800e2b:	eb 02                	jmp    800e2f <strtol+0xbc>
  800e2d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800e2f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e33:	74 05                	je     800e3a <strtol+0xc7>
		*endptr = (char *) s;
  800e35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e38:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800e3a:	f7 d8                	neg    %eax
  800e3c:	85 ff                	test   %edi,%edi
  800e3e:	0f 44 c3             	cmove  %ebx,%eax
}
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5f                   	pop    %edi
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    
  800e46:	66 90                	xchg   %ax,%ax
  800e48:	66 90                	xchg   %ax,%ax
  800e4a:	66 90                	xchg   %ax,%ax
  800e4c:	66 90                	xchg   %ax,%ax
  800e4e:	66 90                	xchg   %ax,%ax

00800e50 <__udivdi3>:
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	83 ec 0c             	sub    $0xc,%esp
  800e56:	8b 44 24 28          	mov    0x28(%esp),%eax
  800e5a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800e5e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800e62:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800e66:	85 c0                	test   %eax,%eax
  800e68:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e6c:	89 ea                	mov    %ebp,%edx
  800e6e:	89 0c 24             	mov    %ecx,(%esp)
  800e71:	75 2d                	jne    800ea0 <__udivdi3+0x50>
  800e73:	39 e9                	cmp    %ebp,%ecx
  800e75:	77 61                	ja     800ed8 <__udivdi3+0x88>
  800e77:	85 c9                	test   %ecx,%ecx
  800e79:	89 ce                	mov    %ecx,%esi
  800e7b:	75 0b                	jne    800e88 <__udivdi3+0x38>
  800e7d:	b8 01 00 00 00       	mov    $0x1,%eax
  800e82:	31 d2                	xor    %edx,%edx
  800e84:	f7 f1                	div    %ecx
  800e86:	89 c6                	mov    %eax,%esi
  800e88:	31 d2                	xor    %edx,%edx
  800e8a:	89 e8                	mov    %ebp,%eax
  800e8c:	f7 f6                	div    %esi
  800e8e:	89 c5                	mov    %eax,%ebp
  800e90:	89 f8                	mov    %edi,%eax
  800e92:	f7 f6                	div    %esi
  800e94:	89 ea                	mov    %ebp,%edx
  800e96:	83 c4 0c             	add    $0xc,%esp
  800e99:	5e                   	pop    %esi
  800e9a:	5f                   	pop    %edi
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    
  800e9d:	8d 76 00             	lea    0x0(%esi),%esi
  800ea0:	39 e8                	cmp    %ebp,%eax
  800ea2:	77 24                	ja     800ec8 <__udivdi3+0x78>
  800ea4:	0f bd e8             	bsr    %eax,%ebp
  800ea7:	83 f5 1f             	xor    $0x1f,%ebp
  800eaa:	75 3c                	jne    800ee8 <__udivdi3+0x98>
  800eac:	8b 74 24 04          	mov    0x4(%esp),%esi
  800eb0:	39 34 24             	cmp    %esi,(%esp)
  800eb3:	0f 86 9f 00 00 00    	jbe    800f58 <__udivdi3+0x108>
  800eb9:	39 d0                	cmp    %edx,%eax
  800ebb:	0f 82 97 00 00 00    	jb     800f58 <__udivdi3+0x108>
  800ec1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec8:	31 d2                	xor    %edx,%edx
  800eca:	31 c0                	xor    %eax,%eax
  800ecc:	83 c4 0c             	add    $0xc,%esp
  800ecf:	5e                   	pop    %esi
  800ed0:	5f                   	pop    %edi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    
  800ed3:	90                   	nop
  800ed4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ed8:	89 f8                	mov    %edi,%eax
  800eda:	f7 f1                	div    %ecx
  800edc:	31 d2                	xor    %edx,%edx
  800ede:	83 c4 0c             	add    $0xc,%esp
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    
  800ee5:	8d 76 00             	lea    0x0(%esi),%esi
  800ee8:	89 e9                	mov    %ebp,%ecx
  800eea:	8b 3c 24             	mov    (%esp),%edi
  800eed:	d3 e0                	shl    %cl,%eax
  800eef:	89 c6                	mov    %eax,%esi
  800ef1:	b8 20 00 00 00       	mov    $0x20,%eax
  800ef6:	29 e8                	sub    %ebp,%eax
  800ef8:	89 c1                	mov    %eax,%ecx
  800efa:	d3 ef                	shr    %cl,%edi
  800efc:	89 e9                	mov    %ebp,%ecx
  800efe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f02:	8b 3c 24             	mov    (%esp),%edi
  800f05:	09 74 24 08          	or     %esi,0x8(%esp)
  800f09:	89 d6                	mov    %edx,%esi
  800f0b:	d3 e7                	shl    %cl,%edi
  800f0d:	89 c1                	mov    %eax,%ecx
  800f0f:	89 3c 24             	mov    %edi,(%esp)
  800f12:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f16:	d3 ee                	shr    %cl,%esi
  800f18:	89 e9                	mov    %ebp,%ecx
  800f1a:	d3 e2                	shl    %cl,%edx
  800f1c:	89 c1                	mov    %eax,%ecx
  800f1e:	d3 ef                	shr    %cl,%edi
  800f20:	09 d7                	or     %edx,%edi
  800f22:	89 f2                	mov    %esi,%edx
  800f24:	89 f8                	mov    %edi,%eax
  800f26:	f7 74 24 08          	divl   0x8(%esp)
  800f2a:	89 d6                	mov    %edx,%esi
  800f2c:	89 c7                	mov    %eax,%edi
  800f2e:	f7 24 24             	mull   (%esp)
  800f31:	39 d6                	cmp    %edx,%esi
  800f33:	89 14 24             	mov    %edx,(%esp)
  800f36:	72 30                	jb     800f68 <__udivdi3+0x118>
  800f38:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f3c:	89 e9                	mov    %ebp,%ecx
  800f3e:	d3 e2                	shl    %cl,%edx
  800f40:	39 c2                	cmp    %eax,%edx
  800f42:	73 05                	jae    800f49 <__udivdi3+0xf9>
  800f44:	3b 34 24             	cmp    (%esp),%esi
  800f47:	74 1f                	je     800f68 <__udivdi3+0x118>
  800f49:	89 f8                	mov    %edi,%eax
  800f4b:	31 d2                	xor    %edx,%edx
  800f4d:	e9 7a ff ff ff       	jmp    800ecc <__udivdi3+0x7c>
  800f52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f58:	31 d2                	xor    %edx,%edx
  800f5a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5f:	e9 68 ff ff ff       	jmp    800ecc <__udivdi3+0x7c>
  800f64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f68:	8d 47 ff             	lea    -0x1(%edi),%eax
  800f6b:	31 d2                	xor    %edx,%edx
  800f6d:	83 c4 0c             	add    $0xc,%esp
  800f70:	5e                   	pop    %esi
  800f71:	5f                   	pop    %edi
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    
  800f74:	66 90                	xchg   %ax,%ax
  800f76:	66 90                	xchg   %ax,%ax
  800f78:	66 90                	xchg   %ax,%ax
  800f7a:	66 90                	xchg   %ax,%ax
  800f7c:	66 90                	xchg   %ax,%ax
  800f7e:	66 90                	xchg   %ax,%ax

00800f80 <__umoddi3>:
  800f80:	55                   	push   %ebp
  800f81:	57                   	push   %edi
  800f82:	56                   	push   %esi
  800f83:	83 ec 14             	sub    $0x14,%esp
  800f86:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f8a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f8e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800f92:	89 c7                	mov    %eax,%edi
  800f94:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f98:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f9c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fa0:	89 34 24             	mov    %esi,(%esp)
  800fa3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	89 c2                	mov    %eax,%edx
  800fab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800faf:	75 17                	jne    800fc8 <__umoddi3+0x48>
  800fb1:	39 fe                	cmp    %edi,%esi
  800fb3:	76 4b                	jbe    801000 <__umoddi3+0x80>
  800fb5:	89 c8                	mov    %ecx,%eax
  800fb7:	89 fa                	mov    %edi,%edx
  800fb9:	f7 f6                	div    %esi
  800fbb:	89 d0                	mov    %edx,%eax
  800fbd:	31 d2                	xor    %edx,%edx
  800fbf:	83 c4 14             	add    $0x14,%esp
  800fc2:	5e                   	pop    %esi
  800fc3:	5f                   	pop    %edi
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    
  800fc6:	66 90                	xchg   %ax,%ax
  800fc8:	39 f8                	cmp    %edi,%eax
  800fca:	77 54                	ja     801020 <__umoddi3+0xa0>
  800fcc:	0f bd e8             	bsr    %eax,%ebp
  800fcf:	83 f5 1f             	xor    $0x1f,%ebp
  800fd2:	75 5c                	jne    801030 <__umoddi3+0xb0>
  800fd4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fd8:	39 3c 24             	cmp    %edi,(%esp)
  800fdb:	0f 87 e7 00 00 00    	ja     8010c8 <__umoddi3+0x148>
  800fe1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fe5:	29 f1                	sub    %esi,%ecx
  800fe7:	19 c7                	sbb    %eax,%edi
  800fe9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fed:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800ff1:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ff5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800ff9:	83 c4 14             	add    $0x14,%esp
  800ffc:	5e                   	pop    %esi
  800ffd:	5f                   	pop    %edi
  800ffe:	5d                   	pop    %ebp
  800fff:	c3                   	ret    
  801000:	85 f6                	test   %esi,%esi
  801002:	89 f5                	mov    %esi,%ebp
  801004:	75 0b                	jne    801011 <__umoddi3+0x91>
  801006:	b8 01 00 00 00       	mov    $0x1,%eax
  80100b:	31 d2                	xor    %edx,%edx
  80100d:	f7 f6                	div    %esi
  80100f:	89 c5                	mov    %eax,%ebp
  801011:	8b 44 24 04          	mov    0x4(%esp),%eax
  801015:	31 d2                	xor    %edx,%edx
  801017:	f7 f5                	div    %ebp
  801019:	89 c8                	mov    %ecx,%eax
  80101b:	f7 f5                	div    %ebp
  80101d:	eb 9c                	jmp    800fbb <__umoddi3+0x3b>
  80101f:	90                   	nop
  801020:	89 c8                	mov    %ecx,%eax
  801022:	89 fa                	mov    %edi,%edx
  801024:	83 c4 14             	add    $0x14,%esp
  801027:	5e                   	pop    %esi
  801028:	5f                   	pop    %edi
  801029:	5d                   	pop    %ebp
  80102a:	c3                   	ret    
  80102b:	90                   	nop
  80102c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801030:	8b 04 24             	mov    (%esp),%eax
  801033:	be 20 00 00 00       	mov    $0x20,%esi
  801038:	89 e9                	mov    %ebp,%ecx
  80103a:	29 ee                	sub    %ebp,%esi
  80103c:	d3 e2                	shl    %cl,%edx
  80103e:	89 f1                	mov    %esi,%ecx
  801040:	d3 e8                	shr    %cl,%eax
  801042:	89 e9                	mov    %ebp,%ecx
  801044:	89 44 24 04          	mov    %eax,0x4(%esp)
  801048:	8b 04 24             	mov    (%esp),%eax
  80104b:	09 54 24 04          	or     %edx,0x4(%esp)
  80104f:	89 fa                	mov    %edi,%edx
  801051:	d3 e0                	shl    %cl,%eax
  801053:	89 f1                	mov    %esi,%ecx
  801055:	89 44 24 08          	mov    %eax,0x8(%esp)
  801059:	8b 44 24 10          	mov    0x10(%esp),%eax
  80105d:	d3 ea                	shr    %cl,%edx
  80105f:	89 e9                	mov    %ebp,%ecx
  801061:	d3 e7                	shl    %cl,%edi
  801063:	89 f1                	mov    %esi,%ecx
  801065:	d3 e8                	shr    %cl,%eax
  801067:	89 e9                	mov    %ebp,%ecx
  801069:	09 f8                	or     %edi,%eax
  80106b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80106f:	f7 74 24 04          	divl   0x4(%esp)
  801073:	d3 e7                	shl    %cl,%edi
  801075:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801079:	89 d7                	mov    %edx,%edi
  80107b:	f7 64 24 08          	mull   0x8(%esp)
  80107f:	39 d7                	cmp    %edx,%edi
  801081:	89 c1                	mov    %eax,%ecx
  801083:	89 14 24             	mov    %edx,(%esp)
  801086:	72 2c                	jb     8010b4 <__umoddi3+0x134>
  801088:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80108c:	72 22                	jb     8010b0 <__umoddi3+0x130>
  80108e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801092:	29 c8                	sub    %ecx,%eax
  801094:	19 d7                	sbb    %edx,%edi
  801096:	89 e9                	mov    %ebp,%ecx
  801098:	89 fa                	mov    %edi,%edx
  80109a:	d3 e8                	shr    %cl,%eax
  80109c:	89 f1                	mov    %esi,%ecx
  80109e:	d3 e2                	shl    %cl,%edx
  8010a0:	89 e9                	mov    %ebp,%ecx
  8010a2:	d3 ef                	shr    %cl,%edi
  8010a4:	09 d0                	or     %edx,%eax
  8010a6:	89 fa                	mov    %edi,%edx
  8010a8:	83 c4 14             	add    $0x14,%esp
  8010ab:	5e                   	pop    %esi
  8010ac:	5f                   	pop    %edi
  8010ad:	5d                   	pop    %ebp
  8010ae:	c3                   	ret    
  8010af:	90                   	nop
  8010b0:	39 d7                	cmp    %edx,%edi
  8010b2:	75 da                	jne    80108e <__umoddi3+0x10e>
  8010b4:	8b 14 24             	mov    (%esp),%edx
  8010b7:	89 c1                	mov    %eax,%ecx
  8010b9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8010bd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8010c1:	eb cb                	jmp    80108e <__umoddi3+0x10e>
  8010c3:	90                   	nop
  8010c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010c8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8010cc:	0f 82 0f ff ff ff    	jb     800fe1 <__umoddi3+0x61>
  8010d2:	e9 1a ff ff ff       	jmp    800ff1 <__umoddi3+0x71>
