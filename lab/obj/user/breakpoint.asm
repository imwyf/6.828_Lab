
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:

const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	83 ec 10             	sub    $0x10,%esp
  800041:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800044:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())]; // ENVX()得到id在Env[]数组中对应的下标
  800047:	e8 d8 00 00 00       	call   800124 <sys_getenvid>
  80004c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800051:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800054:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800059:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005e:	85 db                	test   %ebx,%ebx
  800060:	7e 07                	jle    800069 <libmain+0x30>
		binaryname = argv[0];
  800062:	8b 06                	mov    (%esi),%eax
  800064:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800069:	89 74 24 04          	mov    %esi,0x4(%esp)
  80006d:	89 1c 24             	mov    %ebx,(%esp)
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 07 00 00 00       	call   800081 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	5b                   	pop    %ebx
  80007e:	5e                   	pop    %esi
  80007f:	5d                   	pop    %ebp
  800080:	c3                   	ret    

00800081 <exit>:
 */

#include <inc/lib.h>

void exit(void)
{
  800081:	55                   	push   %ebp
  800082:	89 e5                	mov    %esp,%ebp
  800084:	83 ec 18             	sub    $0x18,%esp
	// close_all();
	sys_env_destroy(0);
  800087:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80008e:	e8 3f 00 00 00       	call   8000d2 <sys_env_destroy>
}
  800093:	c9                   	leave  
  800094:	c3                   	ret    

00800095 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800095:	55                   	push   %ebp
  800096:	89 e5                	mov    %esp,%ebp
  800098:	57                   	push   %edi
  800099:	56                   	push   %esi
  80009a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80009b:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a6:	89 c3                	mov    %eax,%ebx
  8000a8:	89 c7                	mov    %eax,%edi
  8000aa:	89 c6                	mov    %eax,%esi
  8000ac:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ae:	5b                   	pop    %ebx
  8000af:	5e                   	pop    %esi
  8000b0:	5f                   	pop    %edi
  8000b1:	5d                   	pop    %ebp
  8000b2:	c3                   	ret    

008000b3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	57                   	push   %edi
  8000b7:	56                   	push   %esi
  8000b8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000be:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c3:	89 d1                	mov    %edx,%ecx
  8000c5:	89 d3                	mov    %edx,%ebx
  8000c7:	89 d7                	mov    %edx,%edi
  8000c9:	89 d6                	mov    %edx,%esi
  8000cb:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
  8000d8:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8000db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e0:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e8:	89 cb                	mov    %ecx,%ebx
  8000ea:	89 cf                	mov    %ecx,%edi
  8000ec:	89 ce                	mov    %ecx,%esi
  8000ee:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f0:	85 c0                	test   %eax,%eax
  8000f2:	7e 28                	jle    80011c <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000f8:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8000ff:	00 
  800100:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  800107:	00 
  800108:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80010f:	00 
  800110:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  800117:	e8 ae 02 00 00       	call   8003ca <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011c:	83 c4 2c             	add    $0x2c,%esp
  80011f:	5b                   	pop    %ebx
  800120:	5e                   	pop    %esi
  800121:	5f                   	pop    %edi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	57                   	push   %edi
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012a:	ba 00 00 00 00       	mov    $0x0,%edx
  80012f:	b8 02 00 00 00       	mov    $0x2,%eax
  800134:	89 d1                	mov    %edx,%ecx
  800136:	89 d3                	mov    %edx,%ebx
  800138:	89 d7                	mov    %edx,%edi
  80013a:	89 d6                	mov    %edx,%esi
  80013c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_yield>:

void
sys_yield(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
  800168:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80016b:	be 00 00 00 00       	mov    $0x0,%esi
  800170:	b8 04 00 00 00       	mov    $0x4,%eax
  800175:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800178:	8b 55 08             	mov    0x8(%ebp),%edx
  80017b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017e:	89 f7                	mov    %esi,%edi
  800180:	cd 30                	int    $0x30
	if(check && ret > 0)
  800182:	85 c0                	test   %eax,%eax
  800184:	7e 28                	jle    8001ae <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800186:	89 44 24 10          	mov    %eax,0x10(%esp)
  80018a:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800191:	00 
  800192:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  800199:	00 
  80019a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001a1:	00 
  8001a2:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  8001a9:	e8 1c 02 00 00       	call   8003ca <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ae:	83 c4 2c             	add    $0x2c,%esp
  8001b1:	5b                   	pop    %ebx
  8001b2:	5e                   	pop    %esi
  8001b3:	5f                   	pop    %edi
  8001b4:	5d                   	pop    %ebp
  8001b5:	c3                   	ret    

008001b6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	57                   	push   %edi
  8001ba:	56                   	push   %esi
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8001bf:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001cd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	7e 28                	jle    800201 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001dd:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001e4:	00 
  8001e5:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  8001ec:	00 
  8001ed:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001f4:	00 
  8001f5:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  8001fc:	e8 c9 01 00 00       	call   8003ca <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800201:	83 c4 2c             	add    $0x2c,%esp
  800204:	5b                   	pop    %ebx
  800205:	5e                   	pop    %esi
  800206:	5f                   	pop    %edi
  800207:	5d                   	pop    %ebp
  800208:	c3                   	ret    

00800209 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800212:	bb 00 00 00 00       	mov    $0x0,%ebx
  800217:	b8 06 00 00 00       	mov    $0x6,%eax
  80021c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021f:	8b 55 08             	mov    0x8(%ebp),%edx
  800222:	89 df                	mov    %ebx,%edi
  800224:	89 de                	mov    %ebx,%esi
  800226:	cd 30                	int    $0x30
	if(check && ret > 0)
  800228:	85 c0                	test   %eax,%eax
  80022a:	7e 28                	jle    800254 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80022c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800230:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800237:	00 
  800238:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  80023f:	00 
  800240:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800247:	00 
  800248:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  80024f:	e8 76 01 00 00       	call   8003ca <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800254:	83 c4 2c             	add    $0x2c,%esp
  800257:	5b                   	pop    %ebx
  800258:	5e                   	pop    %esi
  800259:	5f                   	pop    %edi
  80025a:	5d                   	pop    %ebp
  80025b:	c3                   	ret    

0080025c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	57                   	push   %edi
  800260:	56                   	push   %esi
  800261:	53                   	push   %ebx
  800262:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800265:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026a:	b8 08 00 00 00       	mov    $0x8,%eax
  80026f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800272:	8b 55 08             	mov    0x8(%ebp),%edx
  800275:	89 df                	mov    %ebx,%edi
  800277:	89 de                	mov    %ebx,%esi
  800279:	cd 30                	int    $0x30
	if(check && ret > 0)
  80027b:	85 c0                	test   %eax,%eax
  80027d:	7e 28                	jle    8002a7 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800283:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80028a:	00 
  80028b:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  800292:	00 
  800293:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80029a:	00 
  80029b:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  8002a2:	e8 23 01 00 00       	call   8003ca <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002a7:	83 c4 2c             	add    $0x2c,%esp
  8002aa:	5b                   	pop    %ebx
  8002ab:	5e                   	pop    %esi
  8002ac:	5f                   	pop    %edi
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	57                   	push   %edi
  8002b3:	56                   	push   %esi
  8002b4:	53                   	push   %ebx
  8002b5:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8002b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bd:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c8:	89 df                	mov    %ebx,%edi
  8002ca:	89 de                	mov    %ebx,%esi
  8002cc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002ce:	85 c0                	test   %eax,%eax
  8002d0:	7e 28                	jle    8002fa <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002d6:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002dd:	00 
  8002de:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  8002e5:	00 
  8002e6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002ed:	00 
  8002ee:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  8002f5:	e8 d0 00 00 00       	call   8003ca <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002fa:	83 c4 2c             	add    $0x2c,%esp
  8002fd:	5b                   	pop    %ebx
  8002fe:	5e                   	pop    %esi
  8002ff:	5f                   	pop    %edi
  800300:	5d                   	pop    %ebp
  800301:	c3                   	ret    

00800302 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800302:	55                   	push   %ebp
  800303:	89 e5                	mov    %esp,%ebp
  800305:	57                   	push   %edi
  800306:	56                   	push   %esi
  800307:	53                   	push   %ebx
  800308:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80030b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800310:	b8 0a 00 00 00       	mov    $0xa,%eax
  800315:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	89 df                	mov    %ebx,%edi
  80031d:	89 de                	mov    %ebx,%esi
  80031f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800321:	85 c0                	test   %eax,%eax
  800323:	7e 28                	jle    80034d <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800325:	89 44 24 10          	mov    %eax,0x10(%esp)
  800329:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800330:	00 
  800331:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  800338:	00 
  800339:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800340:	00 
  800341:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  800348:	e8 7d 00 00 00       	call   8003ca <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80034d:	83 c4 2c             	add    $0x2c,%esp
  800350:	5b                   	pop    %ebx
  800351:	5e                   	pop    %esi
  800352:	5f                   	pop    %edi
  800353:	5d                   	pop    %ebp
  800354:	c3                   	ret    

00800355 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	57                   	push   %edi
  800359:	56                   	push   %esi
  80035a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80035b:	be 00 00 00 00       	mov    $0x0,%esi
  800360:	b8 0c 00 00 00       	mov    $0xc,%eax
  800365:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800368:	8b 55 08             	mov    0x8(%ebp),%edx
  80036b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80036e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800371:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800373:	5b                   	pop    %ebx
  800374:	5e                   	pop    %esi
  800375:	5f                   	pop    %edi
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    

00800378 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	57                   	push   %edi
  80037c:	56                   	push   %esi
  80037d:	53                   	push   %ebx
  80037e:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800381:	b9 00 00 00 00       	mov    $0x0,%ecx
  800386:	b8 0d 00 00 00       	mov    $0xd,%eax
  80038b:	8b 55 08             	mov    0x8(%ebp),%edx
  80038e:	89 cb                	mov    %ecx,%ebx
  800390:	89 cf                	mov    %ecx,%edi
  800392:	89 ce                	mov    %ecx,%esi
  800394:	cd 30                	int    $0x30
	if(check && ret > 0)
  800396:	85 c0                	test   %eax,%eax
  800398:	7e 28                	jle    8003c2 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80039a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80039e:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003a5:	00 
  8003a6:	c7 44 24 08 ea 10 80 	movl   $0x8010ea,0x8(%esp)
  8003ad:	00 
  8003ae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003b5:	00 
  8003b6:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  8003bd:	e8 08 00 00 00       	call   8003ca <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003c2:	83 c4 2c             	add    $0x2c,%esp
  8003c5:	5b                   	pop    %ebx
  8003c6:	5e                   	pop    %esi
  8003c7:	5f                   	pop    %edi
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	56                   	push   %esi
  8003ce:	53                   	push   %ebx
  8003cf:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003d5:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8003db:	e8 44 fd ff ff       	call   800124 <sys_getenvid>
  8003e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e3:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ea:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003ee:	89 74 24 08          	mov    %esi,0x8(%esp)
  8003f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f6:	c7 04 24 18 11 80 00 	movl   $0x801118,(%esp)
  8003fd:	e8 c1 00 00 00       	call   8004c3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800402:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800406:	8b 45 10             	mov    0x10(%ebp),%eax
  800409:	89 04 24             	mov    %eax,(%esp)
  80040c:	e8 51 00 00 00       	call   800462 <vcprintf>
	cprintf("\n");
  800411:	c7 04 24 3b 11 80 00 	movl   $0x80113b,(%esp)
  800418:	e8 a6 00 00 00       	call   8004c3 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80041d:	cc                   	int3   
  80041e:	eb fd                	jmp    80041d <_panic+0x53>

00800420 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	53                   	push   %ebx
  800424:	83 ec 14             	sub    $0x14,%esp
  800427:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80042a:	8b 13                	mov    (%ebx),%edx
  80042c:	8d 42 01             	lea    0x1(%edx),%eax
  80042f:	89 03                	mov    %eax,(%ebx)
  800431:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800434:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800438:	3d ff 00 00 00       	cmp    $0xff,%eax
  80043d:	75 19                	jne    800458 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80043f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800446:	00 
  800447:	8d 43 08             	lea    0x8(%ebx),%eax
  80044a:	89 04 24             	mov    %eax,(%esp)
  80044d:	e8 43 fc ff ff       	call   800095 <sys_cputs>
		b->idx = 0;
  800452:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800458:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80045c:	83 c4 14             	add    $0x14,%esp
  80045f:	5b                   	pop    %ebx
  800460:	5d                   	pop    %ebp
  800461:	c3                   	ret    

00800462 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80046b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800472:	00 00 00 
	b.cnt = 0;
  800475:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80047c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80047f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800482:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800486:	8b 45 08             	mov    0x8(%ebp),%eax
  800489:	89 44 24 08          	mov    %eax,0x8(%esp)
  80048d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800493:	89 44 24 04          	mov    %eax,0x4(%esp)
  800497:	c7 04 24 20 04 80 00 	movl   $0x800420,(%esp)
  80049e:	e8 ab 01 00 00       	call   80064e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004a3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ad:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004b3:	89 04 24             	mov    %eax,(%esp)
  8004b6:	e8 da fb ff ff       	call   800095 <sys_cputs>

	return b.cnt;
}
  8004bb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004c1:	c9                   	leave  
  8004c2:	c3                   	ret    

008004c3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004c3:	55                   	push   %ebp
  8004c4:	89 e5                	mov    %esp,%ebp
  8004c6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004c9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d3:	89 04 24             	mov    %eax,(%esp)
  8004d6:	e8 87 ff ff ff       	call   800462 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004db:	c9                   	leave  
  8004dc:	c3                   	ret    
  8004dd:	66 90                	xchg   %ax,%ax
  8004df:	90                   	nop

008004e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	57                   	push   %edi
  8004e4:	56                   	push   %esi
  8004e5:	53                   	push   %ebx
  8004e6:	83 ec 3c             	sub    $0x3c,%esp
  8004e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ec:	89 d7                	mov    %edx,%edi
  8004ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f7:	89 c3                	mov    %eax,%ebx
  8004f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8004ff:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  800502:	b9 00 00 00 00       	mov    $0x0,%ecx
  800507:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80050d:	39 d9                	cmp    %ebx,%ecx
  80050f:	72 05                	jb     800516 <printnum+0x36>
  800511:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800514:	77 69                	ja     80057f <printnum+0x9f>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800516:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800519:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80051d:	83 ee 01             	sub    $0x1,%esi
  800520:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800524:	89 44 24 08          	mov    %eax,0x8(%esp)
  800528:	8b 44 24 08          	mov    0x8(%esp),%eax
  80052c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800530:	89 c3                	mov    %eax,%ebx
  800532:	89 d6                	mov    %edx,%esi
  800534:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800537:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80053a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80053e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800542:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800545:	89 04 24             	mov    %eax,(%esp)
  800548:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80054b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054f:	e8 ec 08 00 00       	call   800e40 <__udivdi3>
  800554:	89 d9                	mov    %ebx,%ecx
  800556:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80055a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80055e:	89 04 24             	mov    %eax,(%esp)
  800561:	89 54 24 04          	mov    %edx,0x4(%esp)
  800565:	89 fa                	mov    %edi,%edx
  800567:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80056a:	e8 71 ff ff ff       	call   8004e0 <printnum>
  80056f:	eb 1b                	jmp    80058c <printnum+0xac>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800571:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800575:	8b 45 18             	mov    0x18(%ebp),%eax
  800578:	89 04 24             	mov    %eax,(%esp)
  80057b:	ff d3                	call   *%ebx
  80057d:	eb 03                	jmp    800582 <printnum+0xa2>
  80057f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  800582:	83 ee 01             	sub    $0x1,%esi
  800585:	85 f6                	test   %esi,%esi
  800587:	7f e8                	jg     800571 <printnum+0x91>
  800589:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80058c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800590:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800594:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800597:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80059a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80059e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a5:	89 04 24             	mov    %eax,(%esp)
  8005a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005af:	e8 bc 09 00 00       	call   800f70 <__umoddi3>
  8005b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b8:	0f be 80 3d 11 80 00 	movsbl 0x80113d(%eax),%eax
  8005bf:	89 04 24             	mov    %eax,(%esp)
  8005c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005c5:	ff d0                	call   *%eax
}
  8005c7:	83 c4 3c             	add    $0x3c,%esp
  8005ca:	5b                   	pop    %ebx
  8005cb:	5e                   	pop    %esi
  8005cc:	5f                   	pop    %edi
  8005cd:	5d                   	pop    %ebp
  8005ce:	c3                   	ret    

008005cf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005cf:	55                   	push   %ebp
  8005d0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005d2:	83 fa 01             	cmp    $0x1,%edx
  8005d5:	7e 0e                	jle    8005e5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005d7:	8b 10                	mov    (%eax),%edx
  8005d9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005dc:	89 08                	mov    %ecx,(%eax)
  8005de:	8b 02                	mov    (%edx),%eax
  8005e0:	8b 52 04             	mov    0x4(%edx),%edx
  8005e3:	eb 22                	jmp    800607 <getuint+0x38>
	else if (lflag)
  8005e5:	85 d2                	test   %edx,%edx
  8005e7:	74 10                	je     8005f9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005e9:	8b 10                	mov    (%eax),%edx
  8005eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005ee:	89 08                	mov    %ecx,(%eax)
  8005f0:	8b 02                	mov    (%edx),%eax
  8005f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f7:	eb 0e                	jmp    800607 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005f9:	8b 10                	mov    (%eax),%edx
  8005fb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005fe:	89 08                	mov    %ecx,(%eax)
  800600:	8b 02                	mov    (%edx),%eax
  800602:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800607:	5d                   	pop    %ebp
  800608:	c3                   	ret    

00800609 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800609:	55                   	push   %ebp
  80060a:	89 e5                	mov    %esp,%ebp
  80060c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80060f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800613:	8b 10                	mov    (%eax),%edx
  800615:	3b 50 04             	cmp    0x4(%eax),%edx
  800618:	73 0a                	jae    800624 <sprintputch+0x1b>
		*b->buf++ = ch;
  80061a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80061d:	89 08                	mov    %ecx,(%eax)
  80061f:	8b 45 08             	mov    0x8(%ebp),%eax
  800622:	88 02                	mov    %al,(%edx)
}
  800624:	5d                   	pop    %ebp
  800625:	c3                   	ret    

00800626 <printfmt>:
{
  800626:	55                   	push   %ebp
  800627:	89 e5                	mov    %esp,%ebp
  800629:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  80062c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80062f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800633:	8b 45 10             	mov    0x10(%ebp),%eax
  800636:	89 44 24 08          	mov    %eax,0x8(%esp)
  80063a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80063d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800641:	8b 45 08             	mov    0x8(%ebp),%eax
  800644:	89 04 24             	mov    %eax,(%esp)
  800647:	e8 02 00 00 00       	call   80064e <vprintfmt>
}
  80064c:	c9                   	leave  
  80064d:	c3                   	ret    

0080064e <vprintfmt>:
{
  80064e:	55                   	push   %ebp
  80064f:	89 e5                	mov    %esp,%ebp
  800651:	57                   	push   %edi
  800652:	56                   	push   %esi
  800653:	53                   	push   %ebx
  800654:	83 ec 3c             	sub    $0x3c,%esp
  800657:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80065a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80065d:	eb 14                	jmp    800673 <vprintfmt+0x25>
			if (ch == '\0')
  80065f:	85 c0                	test   %eax,%eax
  800661:	0f 84 b3 03 00 00    	je     800a1a <vprintfmt+0x3cc>
			putch(ch, putdat);
  800667:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80066b:	89 04 24             	mov    %eax,(%esp)
  80066e:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  800671:	89 f3                	mov    %esi,%ebx
  800673:	8d 73 01             	lea    0x1(%ebx),%esi
  800676:	0f b6 03             	movzbl (%ebx),%eax
  800679:	83 f8 25             	cmp    $0x25,%eax
  80067c:	75 e1                	jne    80065f <vprintfmt+0x11>
  80067e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800682:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800689:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800690:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800697:	ba 00 00 00 00       	mov    $0x0,%edx
  80069c:	eb 1d                	jmp    8006bb <vprintfmt+0x6d>
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80069e:	89 de                	mov    %ebx,%esi
			padc = '-';
  8006a0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8006a4:	eb 15                	jmp    8006bb <vprintfmt+0x6d>
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006a6:	89 de                	mov    %ebx,%esi
			padc = '0';
  8006a8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8006ac:	eb 0d                	jmp    8006bb <vprintfmt+0x6d>
				width = precision, precision = -1;
  8006ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006b1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006b4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006bb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8006be:	0f b6 0e             	movzbl (%esi),%ecx
  8006c1:	0f b6 c1             	movzbl %cl,%eax
  8006c4:	83 e9 23             	sub    $0x23,%ecx
  8006c7:	80 f9 55             	cmp    $0x55,%cl
  8006ca:	0f 87 2a 03 00 00    	ja     8009fa <vprintfmt+0x3ac>
  8006d0:	0f b6 c9             	movzbl %cl,%ecx
  8006d3:	ff 24 8d 80 12 80 00 	jmp    *0x801280(,%ecx,4)
  8006da:	89 de                	mov    %ebx,%esi
  8006dc:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  8006e1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8006e4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8006e8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006eb:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8006ee:	83 fb 09             	cmp    $0x9,%ebx
  8006f1:	77 36                	ja     800729 <vprintfmt+0xdb>
			for (precision = 0;; ++fmt)
  8006f3:	83 c6 01             	add    $0x1,%esi
			}
  8006f6:	eb e9                	jmp    8006e1 <vprintfmt+0x93>
			precision = va_arg(ap, int);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8d 48 04             	lea    0x4(%eax),%ecx
  8006fe:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800701:	8b 00                	mov    (%eax),%eax
  800703:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800706:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800708:	eb 22                	jmp    80072c <vprintfmt+0xde>
  80070a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80070d:	85 c9                	test   %ecx,%ecx
  80070f:	b8 00 00 00 00       	mov    $0x0,%eax
  800714:	0f 49 c1             	cmovns %ecx,%eax
  800717:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80071a:	89 de                	mov    %ebx,%esi
  80071c:	eb 9d                	jmp    8006bb <vprintfmt+0x6d>
  80071e:	89 de                	mov    %ebx,%esi
			altflag = 1;
  800720:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800727:	eb 92                	jmp    8006bb <vprintfmt+0x6d>
  800729:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  80072c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800730:	79 89                	jns    8006bb <vprintfmt+0x6d>
  800732:	e9 77 ff ff ff       	jmp    8006ae <vprintfmt+0x60>
			lflag++;
  800737:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80073a:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80073c:	e9 7a ff ff ff       	jmp    8006bb <vprintfmt+0x6d>
			putch(va_arg(ap, int), putdat);
  800741:	8b 45 14             	mov    0x14(%ebp),%eax
  800744:	8d 50 04             	lea    0x4(%eax),%edx
  800747:	89 55 14             	mov    %edx,0x14(%ebp)
  80074a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80074e:	8b 00                	mov    (%eax),%eax
  800750:	89 04 24             	mov    %eax,(%esp)
  800753:	ff 55 08             	call   *0x8(%ebp)
			break;
  800756:	e9 18 ff ff ff       	jmp    800673 <vprintfmt+0x25>
			err = va_arg(ap, int);
  80075b:	8b 45 14             	mov    0x14(%ebp),%eax
  80075e:	8d 50 04             	lea    0x4(%eax),%edx
  800761:	89 55 14             	mov    %edx,0x14(%ebp)
  800764:	8b 00                	mov    (%eax),%eax
  800766:	99                   	cltd   
  800767:	31 d0                	xor    %edx,%eax
  800769:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80076b:	83 f8 0f             	cmp    $0xf,%eax
  80076e:	7f 0b                	jg     80077b <vprintfmt+0x12d>
  800770:	8b 14 85 e0 13 80 00 	mov    0x8013e0(,%eax,4),%edx
  800777:	85 d2                	test   %edx,%edx
  800779:	75 20                	jne    80079b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80077b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80077f:	c7 44 24 08 55 11 80 	movl   $0x801155,0x8(%esp)
  800786:	00 
  800787:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80078b:	8b 45 08             	mov    0x8(%ebp),%eax
  80078e:	89 04 24             	mov    %eax,(%esp)
  800791:	e8 90 fe ff ff       	call   800626 <printfmt>
  800796:	e9 d8 fe ff ff       	jmp    800673 <vprintfmt+0x25>
				printfmt(putch, putdat, "%s", p);
  80079b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80079f:	c7 44 24 08 5e 11 80 	movl   $0x80115e,0x8(%esp)
  8007a6:	00 
  8007a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ae:	89 04 24             	mov    %eax,(%esp)
  8007b1:	e8 70 fe ff ff       	call   800626 <printfmt>
  8007b6:	e9 b8 fe ff ff       	jmp    800673 <vprintfmt+0x25>
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8007bb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8007be:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  8007c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c7:	8d 50 04             	lea    0x4(%eax),%edx
  8007ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cd:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8007cf:	85 f6                	test   %esi,%esi
  8007d1:	b8 4e 11 80 00       	mov    $0x80114e,%eax
  8007d6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8007d9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007dd:	0f 84 97 00 00 00    	je     80087a <vprintfmt+0x22c>
  8007e3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8007e7:	0f 8e 9b 00 00 00    	jle    800888 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ed:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007f1:	89 34 24             	mov    %esi,(%esp)
  8007f4:	e8 cf 02 00 00       	call   800ac8 <strnlen>
  8007f9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8007fc:	29 c2                	sub    %eax,%edx
  8007fe:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800801:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800805:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800808:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80080b:	8b 75 08             	mov    0x8(%ebp),%esi
  80080e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800811:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800813:	eb 0f                	jmp    800824 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800815:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800819:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80081c:	89 04 24             	mov    %eax,(%esp)
  80081f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800821:	83 eb 01             	sub    $0x1,%ebx
  800824:	85 db                	test   %ebx,%ebx
  800826:	7f ed                	jg     800815 <vprintfmt+0x1c7>
  800828:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80082b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80082e:	85 d2                	test   %edx,%edx
  800830:	b8 00 00 00 00       	mov    $0x0,%eax
  800835:	0f 49 c2             	cmovns %edx,%eax
  800838:	29 c2                	sub    %eax,%edx
  80083a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80083d:	89 d7                	mov    %edx,%edi
  80083f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800842:	eb 50                	jmp    800894 <vprintfmt+0x246>
				if (altflag && (ch < ' ' || ch > '~'))
  800844:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800848:	74 1e                	je     800868 <vprintfmt+0x21a>
  80084a:	0f be d2             	movsbl %dl,%edx
  80084d:	83 ea 20             	sub    $0x20,%edx
  800850:	83 fa 5e             	cmp    $0x5e,%edx
  800853:	76 13                	jbe    800868 <vprintfmt+0x21a>
					putch('?', putdat);
  800855:	8b 45 0c             	mov    0xc(%ebp),%eax
  800858:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800863:	ff 55 08             	call   *0x8(%ebp)
  800866:	eb 0d                	jmp    800875 <vprintfmt+0x227>
					putch(ch, putdat);
  800868:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80086f:	89 04 24             	mov    %eax,(%esp)
  800872:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800875:	83 ef 01             	sub    $0x1,%edi
  800878:	eb 1a                	jmp    800894 <vprintfmt+0x246>
  80087a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80087d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800880:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800883:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800886:	eb 0c                	jmp    800894 <vprintfmt+0x246>
  800888:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80088b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80088e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800891:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800894:	83 c6 01             	add    $0x1,%esi
  800897:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80089b:	0f be c2             	movsbl %dl,%eax
  80089e:	85 c0                	test   %eax,%eax
  8008a0:	74 27                	je     8008c9 <vprintfmt+0x27b>
  8008a2:	85 db                	test   %ebx,%ebx
  8008a4:	78 9e                	js     800844 <vprintfmt+0x1f6>
  8008a6:	83 eb 01             	sub    $0x1,%ebx
  8008a9:	79 99                	jns    800844 <vprintfmt+0x1f6>
  8008ab:	89 f8                	mov    %edi,%eax
  8008ad:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8008b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b3:	89 c3                	mov    %eax,%ebx
  8008b5:	eb 1a                	jmp    8008d1 <vprintfmt+0x283>
				putch(' ', putdat);
  8008b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008bb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008c2:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8008c4:	83 eb 01             	sub    $0x1,%ebx
  8008c7:	eb 08                	jmp    8008d1 <vprintfmt+0x283>
  8008c9:	89 fb                	mov    %edi,%ebx
  8008cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ce:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8008d1:	85 db                	test   %ebx,%ebx
  8008d3:	7f e2                	jg     8008b7 <vprintfmt+0x269>
  8008d5:	89 75 08             	mov    %esi,0x8(%ebp)
  8008d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008db:	e9 93 fd ff ff       	jmp    800673 <vprintfmt+0x25>
	if (lflag >= 2)
  8008e0:	83 fa 01             	cmp    $0x1,%edx
  8008e3:	7e 16                	jle    8008fb <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8008e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e8:	8d 50 08             	lea    0x8(%eax),%edx
  8008eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8008ee:	8b 50 04             	mov    0x4(%eax),%edx
  8008f1:	8b 00                	mov    (%eax),%eax
  8008f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008f9:	eb 32                	jmp    80092d <vprintfmt+0x2df>
	else if (lflag)
  8008fb:	85 d2                	test   %edx,%edx
  8008fd:	74 18                	je     800917 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8008ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800902:	8d 50 04             	lea    0x4(%eax),%edx
  800905:	89 55 14             	mov    %edx,0x14(%ebp)
  800908:	8b 30                	mov    (%eax),%esi
  80090a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80090d:	89 f0                	mov    %esi,%eax
  80090f:	c1 f8 1f             	sar    $0x1f,%eax
  800912:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800915:	eb 16                	jmp    80092d <vprintfmt+0x2df>
		return va_arg(*ap, int);
  800917:	8b 45 14             	mov    0x14(%ebp),%eax
  80091a:	8d 50 04             	lea    0x4(%eax),%edx
  80091d:	89 55 14             	mov    %edx,0x14(%ebp)
  800920:	8b 30                	mov    (%eax),%esi
  800922:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800925:	89 f0                	mov    %esi,%eax
  800927:	c1 f8 1f             	sar    $0x1f,%eax
  80092a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  80092d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800930:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10; // base代表进制数
  800933:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long)num < 0)
  800938:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80093c:	0f 89 80 00 00 00    	jns    8009c2 <vprintfmt+0x374>
				putch('-', putdat);
  800942:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800946:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80094d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  800950:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800953:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800956:	f7 d8                	neg    %eax
  800958:	83 d2 00             	adc    $0x0,%edx
  80095b:	f7 da                	neg    %edx
			base = 10; // base代表进制数
  80095d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800962:	eb 5e                	jmp    8009c2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
  800964:	8d 45 14             	lea    0x14(%ebp),%eax
  800967:	e8 63 fc ff ff       	call   8005cf <getuint>
			base = 10;
  80096c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800971:	eb 4f                	jmp    8009c2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
  800973:	8d 45 14             	lea    0x14(%ebp),%eax
  800976:	e8 54 fc ff ff       	call   8005cf <getuint>
			base = 8;
  80097b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800980:	eb 40                	jmp    8009c2 <vprintfmt+0x374>
			putch('0', putdat);
  800982:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800986:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80098d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800990:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800994:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80099b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80099e:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a1:	8d 50 04             	lea    0x4(%eax),%edx
  8009a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a7:	8b 00                	mov    (%eax),%eax
  8009a9:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  8009ae:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8009b3:	eb 0d                	jmp    8009c2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
  8009b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8009b8:	e8 12 fc ff ff       	call   8005cf <getuint>
			base = 16;
  8009bd:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  8009c2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8009c6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8009ca:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8009cd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8009d1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009d5:	89 04 24             	mov    %eax,(%esp)
  8009d8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009dc:	89 fa                	mov    %edi,%edx
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	e8 fa fa ff ff       	call   8004e0 <printnum>
			break;
  8009e6:	e9 88 fc ff ff       	jmp    800673 <vprintfmt+0x25>
			putch(ch, putdat);
  8009eb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009ef:	89 04 24             	mov    %eax,(%esp)
  8009f2:	ff 55 08             	call   *0x8(%ebp)
			break;
  8009f5:	e9 79 fc ff ff       	jmp    800673 <vprintfmt+0x25>
			putch('%', putdat);
  8009fa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009fe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a05:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a08:	89 f3                	mov    %esi,%ebx
  800a0a:	eb 03                	jmp    800a0f <vprintfmt+0x3c1>
  800a0c:	83 eb 01             	sub    $0x1,%ebx
  800a0f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800a13:	75 f7                	jne    800a0c <vprintfmt+0x3be>
  800a15:	e9 59 fc ff ff       	jmp    800673 <vprintfmt+0x25>
}
  800a1a:	83 c4 3c             	add    $0x3c,%esp
  800a1d:	5b                   	pop    %ebx
  800a1e:	5e                   	pop    %esi
  800a1f:	5f                   	pop    %edi
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	83 ec 28             	sub    $0x28,%esp
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  800a2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a31:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a35:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a38:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a3f:	85 c0                	test   %eax,%eax
  800a41:	74 30                	je     800a73 <vsnprintf+0x51>
  800a43:	85 d2                	test   %edx,%edx
  800a45:	7e 2c                	jle    800a73 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  800a47:	8b 45 14             	mov    0x14(%ebp),%eax
  800a4a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a4e:	8b 45 10             	mov    0x10(%ebp),%eax
  800a51:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a55:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a58:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a5c:	c7 04 24 09 06 80 00 	movl   $0x800609,(%esp)
  800a63:	e8 e6 fb ff ff       	call   80064e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a68:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a6b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a71:	eb 05                	jmp    800a78 <vsnprintf+0x56>
		return -E_INVAL;
  800a73:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a78:	c9                   	leave  
  800a79:	c3                   	ret    

00800a7a <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a80:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a83:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a87:	8b 45 10             	mov    0x10(%ebp),%eax
  800a8a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a91:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a95:	8b 45 08             	mov    0x8(%ebp),%eax
  800a98:	89 04 24             	mov    %eax,(%esp)
  800a9b:	e8 82 ff ff ff       	call   800a22 <vsnprintf>
	va_end(ap);

	return rc;
}
  800aa0:	c9                   	leave  
  800aa1:	c3                   	ret    
  800aa2:	66 90                	xchg   %ax,%ax
  800aa4:	66 90                	xchg   %ax,%ax
  800aa6:	66 90                	xchg   %ax,%ax
  800aa8:	66 90                	xchg   %ax,%ax
  800aaa:	66 90                	xchg   %ax,%ax
  800aac:	66 90                	xchg   %ax,%ax
  800aae:	66 90                	xchg   %ax,%ax

00800ab0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ab6:	b8 00 00 00 00       	mov    $0x0,%eax
  800abb:	eb 03                	jmp    800ac0 <strlen+0x10>
		n++;
  800abd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800ac0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ac4:	75 f7                	jne    800abd <strlen+0xd>
	return n;
}
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ace:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad6:	eb 03                	jmp    800adb <strnlen+0x13>
		n++;
  800ad8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800adb:	39 d0                	cmp    %edx,%eax
  800add:	74 06                	je     800ae5 <strnlen+0x1d>
  800adf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800ae3:	75 f3                	jne    800ad8 <strnlen+0x10>
	return n;
}
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	53                   	push   %ebx
  800aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800aee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800af1:	89 c2                	mov    %eax,%edx
  800af3:	83 c2 01             	add    $0x1,%edx
  800af6:	83 c1 01             	add    $0x1,%ecx
  800af9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800afd:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b00:	84 db                	test   %bl,%bl
  800b02:	75 ef                	jne    800af3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b04:	5b                   	pop    %ebx
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	53                   	push   %ebx
  800b0b:	83 ec 08             	sub    $0x8,%esp
  800b0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b11:	89 1c 24             	mov    %ebx,(%esp)
  800b14:	e8 97 ff ff ff       	call   800ab0 <strlen>
	strcpy(dst + len, src);
  800b19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b1c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b20:	01 d8                	add    %ebx,%eax
  800b22:	89 04 24             	mov    %eax,(%esp)
  800b25:	e8 bd ff ff ff       	call   800ae7 <strcpy>
	return dst;
}
  800b2a:	89 d8                	mov    %ebx,%eax
  800b2c:	83 c4 08             	add    $0x8,%esp
  800b2f:	5b                   	pop    %ebx
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
  800b37:	8b 75 08             	mov    0x8(%ebp),%esi
  800b3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3d:	89 f3                	mov    %esi,%ebx
  800b3f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b42:	89 f2                	mov    %esi,%edx
  800b44:	eb 0f                	jmp    800b55 <strncpy+0x23>
		*dst++ = *src;
  800b46:	83 c2 01             	add    $0x1,%edx
  800b49:	0f b6 01             	movzbl (%ecx),%eax
  800b4c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b4f:	80 39 01             	cmpb   $0x1,(%ecx)
  800b52:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800b55:	39 da                	cmp    %ebx,%edx
  800b57:	75 ed                	jne    800b46 <strncpy+0x14>
	}
	return ret;
}
  800b59:	89 f0                	mov    %esi,%eax
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	8b 75 08             	mov    0x8(%ebp),%esi
  800b67:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b6d:	89 f0                	mov    %esi,%eax
  800b6f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b73:	85 c9                	test   %ecx,%ecx
  800b75:	75 0b                	jne    800b82 <strlcpy+0x23>
  800b77:	eb 1d                	jmp    800b96 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b79:	83 c0 01             	add    $0x1,%eax
  800b7c:	83 c2 01             	add    $0x1,%edx
  800b7f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800b82:	39 d8                	cmp    %ebx,%eax
  800b84:	74 0b                	je     800b91 <strlcpy+0x32>
  800b86:	0f b6 0a             	movzbl (%edx),%ecx
  800b89:	84 c9                	test   %cl,%cl
  800b8b:	75 ec                	jne    800b79 <strlcpy+0x1a>
  800b8d:	89 c2                	mov    %eax,%edx
  800b8f:	eb 02                	jmp    800b93 <strlcpy+0x34>
  800b91:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800b93:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b96:	29 f0                	sub    %esi,%eax
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ba5:	eb 06                	jmp    800bad <strcmp+0x11>
		p++, q++;
  800ba7:	83 c1 01             	add    $0x1,%ecx
  800baa:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800bad:	0f b6 01             	movzbl (%ecx),%eax
  800bb0:	84 c0                	test   %al,%al
  800bb2:	74 04                	je     800bb8 <strcmp+0x1c>
  800bb4:	3a 02                	cmp    (%edx),%al
  800bb6:	74 ef                	je     800ba7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bb8:	0f b6 c0             	movzbl %al,%eax
  800bbb:	0f b6 12             	movzbl (%edx),%edx
  800bbe:	29 d0                	sub    %edx,%eax
}
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	53                   	push   %ebx
  800bc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcc:	89 c3                	mov    %eax,%ebx
  800bce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800bd1:	eb 06                	jmp    800bd9 <strncmp+0x17>
		n--, p++, q++;
  800bd3:	83 c0 01             	add    $0x1,%eax
  800bd6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800bd9:	39 d8                	cmp    %ebx,%eax
  800bdb:	74 15                	je     800bf2 <strncmp+0x30>
  800bdd:	0f b6 08             	movzbl (%eax),%ecx
  800be0:	84 c9                	test   %cl,%cl
  800be2:	74 04                	je     800be8 <strncmp+0x26>
  800be4:	3a 0a                	cmp    (%edx),%cl
  800be6:	74 eb                	je     800bd3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800be8:	0f b6 00             	movzbl (%eax),%eax
  800beb:	0f b6 12             	movzbl (%edx),%edx
  800bee:	29 d0                	sub    %edx,%eax
  800bf0:	eb 05                	jmp    800bf7 <strncmp+0x35>
		return 0;
  800bf2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf7:	5b                   	pop    %ebx
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800c00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c04:	eb 07                	jmp    800c0d <strchr+0x13>
		if (*s == c)
  800c06:	38 ca                	cmp    %cl,%dl
  800c08:	74 0f                	je     800c19 <strchr+0x1f>
	for (; *s; s++)
  800c0a:	83 c0 01             	add    $0x1,%eax
  800c0d:	0f b6 10             	movzbl (%eax),%edx
  800c10:	84 d2                	test   %dl,%dl
  800c12:	75 f2                	jne    800c06 <strchr+0xc>
			return (char *) s;
	return 0;
  800c14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c25:	eb 07                	jmp    800c2e <strfind+0x13>
		if (*s == c)
  800c27:	38 ca                	cmp    %cl,%dl
  800c29:	74 0a                	je     800c35 <strfind+0x1a>
	for (; *s; s++)
  800c2b:	83 c0 01             	add    $0x1,%eax
  800c2e:	0f b6 10             	movzbl (%eax),%edx
  800c31:	84 d2                	test   %dl,%dl
  800c33:	75 f2                	jne    800c27 <strfind+0xc>
			break;
	return (char *) s;
}
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c43:	85 c9                	test   %ecx,%ecx
  800c45:	74 36                	je     800c7d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c47:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c4d:	75 28                	jne    800c77 <memset+0x40>
  800c4f:	f6 c1 03             	test   $0x3,%cl
  800c52:	75 23                	jne    800c77 <memset+0x40>
		c &= 0xFF;
  800c54:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c58:	89 d3                	mov    %edx,%ebx
  800c5a:	c1 e3 08             	shl    $0x8,%ebx
  800c5d:	89 d6                	mov    %edx,%esi
  800c5f:	c1 e6 18             	shl    $0x18,%esi
  800c62:	89 d0                	mov    %edx,%eax
  800c64:	c1 e0 10             	shl    $0x10,%eax
  800c67:	09 f0                	or     %esi,%eax
  800c69:	09 c2                	or     %eax,%edx
  800c6b:	89 d0                	mov    %edx,%eax
  800c6d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c6f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c72:	fc                   	cld    
  800c73:	f3 ab                	rep stos %eax,%es:(%edi)
  800c75:	eb 06                	jmp    800c7d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c7a:	fc                   	cld    
  800c7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c7d:	89 f8                	mov    %edi,%eax
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c92:	39 c6                	cmp    %eax,%esi
  800c94:	73 35                	jae    800ccb <memmove+0x47>
  800c96:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c99:	39 d0                	cmp    %edx,%eax
  800c9b:	73 2e                	jae    800ccb <memmove+0x47>
		s += n;
		d += n;
  800c9d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ca0:	89 d6                	mov    %edx,%esi
  800ca2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ca4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800caa:	75 13                	jne    800cbf <memmove+0x3b>
  800cac:	f6 c1 03             	test   $0x3,%cl
  800caf:	75 0e                	jne    800cbf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cb1:	83 ef 04             	sub    $0x4,%edi
  800cb4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cb7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800cba:	fd                   	std    
  800cbb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cbd:	eb 09                	jmp    800cc8 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cbf:	83 ef 01             	sub    $0x1,%edi
  800cc2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800cc5:	fd                   	std    
  800cc6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cc8:	fc                   	cld    
  800cc9:	eb 1d                	jmp    800ce8 <memmove+0x64>
  800ccb:	89 f2                	mov    %esi,%edx
  800ccd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ccf:	f6 c2 03             	test   $0x3,%dl
  800cd2:	75 0f                	jne    800ce3 <memmove+0x5f>
  800cd4:	f6 c1 03             	test   $0x3,%cl
  800cd7:	75 0a                	jne    800ce3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cd9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800cdc:	89 c7                	mov    %eax,%edi
  800cde:	fc                   	cld    
  800cdf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ce1:	eb 05                	jmp    800ce8 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800ce3:	89 c7                	mov    %eax,%edi
  800ce5:	fc                   	cld    
  800ce6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cf2:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cf9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d00:	8b 45 08             	mov    0x8(%ebp),%eax
  800d03:	89 04 24             	mov    %eax,(%esp)
  800d06:	e8 79 ff ff ff       	call   800c84 <memmove>
}
  800d0b:	c9                   	leave  
  800d0c:	c3                   	ret    

00800d0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	56                   	push   %esi
  800d11:	53                   	push   %ebx
  800d12:	8b 55 08             	mov    0x8(%ebp),%edx
  800d15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d18:	89 d6                	mov    %edx,%esi
  800d1a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d1d:	eb 1a                	jmp    800d39 <memcmp+0x2c>
		if (*s1 != *s2)
  800d1f:	0f b6 02             	movzbl (%edx),%eax
  800d22:	0f b6 19             	movzbl (%ecx),%ebx
  800d25:	38 d8                	cmp    %bl,%al
  800d27:	74 0a                	je     800d33 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d29:	0f b6 c0             	movzbl %al,%eax
  800d2c:	0f b6 db             	movzbl %bl,%ebx
  800d2f:	29 d8                	sub    %ebx,%eax
  800d31:	eb 0f                	jmp    800d42 <memcmp+0x35>
		s1++, s2++;
  800d33:	83 c2 01             	add    $0x1,%edx
  800d36:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800d39:	39 f2                	cmp    %esi,%edx
  800d3b:	75 e2                	jne    800d1f <memcmp+0x12>
	}

	return 0;
  800d3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d4f:	89 c2                	mov    %eax,%edx
  800d51:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d54:	eb 07                	jmp    800d5d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d56:	38 08                	cmp    %cl,(%eax)
  800d58:	74 07                	je     800d61 <memfind+0x1b>
	for (; s < ends; s++)
  800d5a:	83 c0 01             	add    $0x1,%eax
  800d5d:	39 d0                	cmp    %edx,%eax
  800d5f:	72 f5                	jb     800d56 <memfind+0x10>
			break;
	return (void *) s;
}
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d6f:	eb 03                	jmp    800d74 <strtol+0x11>
		s++;
  800d71:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800d74:	0f b6 0a             	movzbl (%edx),%ecx
  800d77:	80 f9 09             	cmp    $0x9,%cl
  800d7a:	74 f5                	je     800d71 <strtol+0xe>
  800d7c:	80 f9 20             	cmp    $0x20,%cl
  800d7f:	74 f0                	je     800d71 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800d81:	80 f9 2b             	cmp    $0x2b,%cl
  800d84:	75 0a                	jne    800d90 <strtol+0x2d>
		s++;
  800d86:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800d89:	bf 00 00 00 00       	mov    $0x0,%edi
  800d8e:	eb 11                	jmp    800da1 <strtol+0x3e>
  800d90:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800d95:	80 f9 2d             	cmp    $0x2d,%cl
  800d98:	75 07                	jne    800da1 <strtol+0x3e>
		s++, neg = 1;
  800d9a:	8d 52 01             	lea    0x1(%edx),%edx
  800d9d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800da1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800da6:	75 15                	jne    800dbd <strtol+0x5a>
  800da8:	80 3a 30             	cmpb   $0x30,(%edx)
  800dab:	75 10                	jne    800dbd <strtol+0x5a>
  800dad:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800db1:	75 0a                	jne    800dbd <strtol+0x5a>
		s += 2, base = 16;
  800db3:	83 c2 02             	add    $0x2,%edx
  800db6:	b8 10 00 00 00       	mov    $0x10,%eax
  800dbb:	eb 10                	jmp    800dcd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	75 0c                	jne    800dcd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800dc1:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800dc3:	80 3a 30             	cmpb   $0x30,(%edx)
  800dc6:	75 05                	jne    800dcd <strtol+0x6a>
		s++, base = 8;
  800dc8:	83 c2 01             	add    $0x1,%edx
  800dcb:	b0 08                	mov    $0x8,%al
		base = 10;
  800dcd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800dd5:	0f b6 0a             	movzbl (%edx),%ecx
  800dd8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800ddb:	89 f0                	mov    %esi,%eax
  800ddd:	3c 09                	cmp    $0x9,%al
  800ddf:	77 08                	ja     800de9 <strtol+0x86>
			dig = *s - '0';
  800de1:	0f be c9             	movsbl %cl,%ecx
  800de4:	83 e9 30             	sub    $0x30,%ecx
  800de7:	eb 20                	jmp    800e09 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800de9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800dec:	89 f0                	mov    %esi,%eax
  800dee:	3c 19                	cmp    $0x19,%al
  800df0:	77 08                	ja     800dfa <strtol+0x97>
			dig = *s - 'a' + 10;
  800df2:	0f be c9             	movsbl %cl,%ecx
  800df5:	83 e9 57             	sub    $0x57,%ecx
  800df8:	eb 0f                	jmp    800e09 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800dfa:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800dfd:	89 f0                	mov    %esi,%eax
  800dff:	3c 19                	cmp    $0x19,%al
  800e01:	77 16                	ja     800e19 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800e03:	0f be c9             	movsbl %cl,%ecx
  800e06:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e09:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800e0c:	7d 0f                	jge    800e1d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800e0e:	83 c2 01             	add    $0x1,%edx
  800e11:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800e15:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800e17:	eb bc                	jmp    800dd5 <strtol+0x72>
  800e19:	89 d8                	mov    %ebx,%eax
  800e1b:	eb 02                	jmp    800e1f <strtol+0xbc>
  800e1d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800e1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e23:	74 05                	je     800e2a <strtol+0xc7>
		*endptr = (char *) s;
  800e25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e28:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800e2a:	f7 d8                	neg    %eax
  800e2c:	85 ff                	test   %edi,%edi
  800e2e:	0f 44 c3             	cmove  %ebx,%eax
}
  800e31:	5b                   	pop    %ebx
  800e32:	5e                   	pop    %esi
  800e33:	5f                   	pop    %edi
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    
  800e36:	66 90                	xchg   %ax,%ax
  800e38:	66 90                	xchg   %ax,%ax
  800e3a:	66 90                	xchg   %ax,%ax
  800e3c:	66 90                	xchg   %ax,%ax
  800e3e:	66 90                	xchg   %ax,%ax

00800e40 <__udivdi3>:
  800e40:	55                   	push   %ebp
  800e41:	57                   	push   %edi
  800e42:	56                   	push   %esi
  800e43:	83 ec 0c             	sub    $0xc,%esp
  800e46:	8b 44 24 28          	mov    0x28(%esp),%eax
  800e4a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800e4e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800e52:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800e56:	85 c0                	test   %eax,%eax
  800e58:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e5c:	89 ea                	mov    %ebp,%edx
  800e5e:	89 0c 24             	mov    %ecx,(%esp)
  800e61:	75 2d                	jne    800e90 <__udivdi3+0x50>
  800e63:	39 e9                	cmp    %ebp,%ecx
  800e65:	77 61                	ja     800ec8 <__udivdi3+0x88>
  800e67:	85 c9                	test   %ecx,%ecx
  800e69:	89 ce                	mov    %ecx,%esi
  800e6b:	75 0b                	jne    800e78 <__udivdi3+0x38>
  800e6d:	b8 01 00 00 00       	mov    $0x1,%eax
  800e72:	31 d2                	xor    %edx,%edx
  800e74:	f7 f1                	div    %ecx
  800e76:	89 c6                	mov    %eax,%esi
  800e78:	31 d2                	xor    %edx,%edx
  800e7a:	89 e8                	mov    %ebp,%eax
  800e7c:	f7 f6                	div    %esi
  800e7e:	89 c5                	mov    %eax,%ebp
  800e80:	89 f8                	mov    %edi,%eax
  800e82:	f7 f6                	div    %esi
  800e84:	89 ea                	mov    %ebp,%edx
  800e86:	83 c4 0c             	add    $0xc,%esp
  800e89:	5e                   	pop    %esi
  800e8a:	5f                   	pop    %edi
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    
  800e8d:	8d 76 00             	lea    0x0(%esi),%esi
  800e90:	39 e8                	cmp    %ebp,%eax
  800e92:	77 24                	ja     800eb8 <__udivdi3+0x78>
  800e94:	0f bd e8             	bsr    %eax,%ebp
  800e97:	83 f5 1f             	xor    $0x1f,%ebp
  800e9a:	75 3c                	jne    800ed8 <__udivdi3+0x98>
  800e9c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ea0:	39 34 24             	cmp    %esi,(%esp)
  800ea3:	0f 86 9f 00 00 00    	jbe    800f48 <__udivdi3+0x108>
  800ea9:	39 d0                	cmp    %edx,%eax
  800eab:	0f 82 97 00 00 00    	jb     800f48 <__udivdi3+0x108>
  800eb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb8:	31 d2                	xor    %edx,%edx
  800eba:	31 c0                	xor    %eax,%eax
  800ebc:	83 c4 0c             	add    $0xc,%esp
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    
  800ec3:	90                   	nop
  800ec4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ec8:	89 f8                	mov    %edi,%eax
  800eca:	f7 f1                	div    %ecx
  800ecc:	31 d2                	xor    %edx,%edx
  800ece:	83 c4 0c             	add    $0xc,%esp
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    
  800ed5:	8d 76 00             	lea    0x0(%esi),%esi
  800ed8:	89 e9                	mov    %ebp,%ecx
  800eda:	8b 3c 24             	mov    (%esp),%edi
  800edd:	d3 e0                	shl    %cl,%eax
  800edf:	89 c6                	mov    %eax,%esi
  800ee1:	b8 20 00 00 00       	mov    $0x20,%eax
  800ee6:	29 e8                	sub    %ebp,%eax
  800ee8:	89 c1                	mov    %eax,%ecx
  800eea:	d3 ef                	shr    %cl,%edi
  800eec:	89 e9                	mov    %ebp,%ecx
  800eee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ef2:	8b 3c 24             	mov    (%esp),%edi
  800ef5:	09 74 24 08          	or     %esi,0x8(%esp)
  800ef9:	89 d6                	mov    %edx,%esi
  800efb:	d3 e7                	shl    %cl,%edi
  800efd:	89 c1                	mov    %eax,%ecx
  800eff:	89 3c 24             	mov    %edi,(%esp)
  800f02:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f06:	d3 ee                	shr    %cl,%esi
  800f08:	89 e9                	mov    %ebp,%ecx
  800f0a:	d3 e2                	shl    %cl,%edx
  800f0c:	89 c1                	mov    %eax,%ecx
  800f0e:	d3 ef                	shr    %cl,%edi
  800f10:	09 d7                	or     %edx,%edi
  800f12:	89 f2                	mov    %esi,%edx
  800f14:	89 f8                	mov    %edi,%eax
  800f16:	f7 74 24 08          	divl   0x8(%esp)
  800f1a:	89 d6                	mov    %edx,%esi
  800f1c:	89 c7                	mov    %eax,%edi
  800f1e:	f7 24 24             	mull   (%esp)
  800f21:	39 d6                	cmp    %edx,%esi
  800f23:	89 14 24             	mov    %edx,(%esp)
  800f26:	72 30                	jb     800f58 <__udivdi3+0x118>
  800f28:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f2c:	89 e9                	mov    %ebp,%ecx
  800f2e:	d3 e2                	shl    %cl,%edx
  800f30:	39 c2                	cmp    %eax,%edx
  800f32:	73 05                	jae    800f39 <__udivdi3+0xf9>
  800f34:	3b 34 24             	cmp    (%esp),%esi
  800f37:	74 1f                	je     800f58 <__udivdi3+0x118>
  800f39:	89 f8                	mov    %edi,%eax
  800f3b:	31 d2                	xor    %edx,%edx
  800f3d:	e9 7a ff ff ff       	jmp    800ebc <__udivdi3+0x7c>
  800f42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f48:	31 d2                	xor    %edx,%edx
  800f4a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f4f:	e9 68 ff ff ff       	jmp    800ebc <__udivdi3+0x7c>
  800f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f58:	8d 47 ff             	lea    -0x1(%edi),%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	83 c4 0c             	add    $0xc,%esp
  800f60:	5e                   	pop    %esi
  800f61:	5f                   	pop    %edi
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    
  800f64:	66 90                	xchg   %ax,%ax
  800f66:	66 90                	xchg   %ax,%ax
  800f68:	66 90                	xchg   %ax,%ax
  800f6a:	66 90                	xchg   %ax,%ax
  800f6c:	66 90                	xchg   %ax,%ax
  800f6e:	66 90                	xchg   %ax,%ax

00800f70 <__umoddi3>:
  800f70:	55                   	push   %ebp
  800f71:	57                   	push   %edi
  800f72:	56                   	push   %esi
  800f73:	83 ec 14             	sub    $0x14,%esp
  800f76:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f7a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f7e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800f82:	89 c7                	mov    %eax,%edi
  800f84:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f88:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f8c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f90:	89 34 24             	mov    %esi,(%esp)
  800f93:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f97:	85 c0                	test   %eax,%eax
  800f99:	89 c2                	mov    %eax,%edx
  800f9b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f9f:	75 17                	jne    800fb8 <__umoddi3+0x48>
  800fa1:	39 fe                	cmp    %edi,%esi
  800fa3:	76 4b                	jbe    800ff0 <__umoddi3+0x80>
  800fa5:	89 c8                	mov    %ecx,%eax
  800fa7:	89 fa                	mov    %edi,%edx
  800fa9:	f7 f6                	div    %esi
  800fab:	89 d0                	mov    %edx,%eax
  800fad:	31 d2                	xor    %edx,%edx
  800faf:	83 c4 14             	add    $0x14,%esp
  800fb2:	5e                   	pop    %esi
  800fb3:	5f                   	pop    %edi
  800fb4:	5d                   	pop    %ebp
  800fb5:	c3                   	ret    
  800fb6:	66 90                	xchg   %ax,%ax
  800fb8:	39 f8                	cmp    %edi,%eax
  800fba:	77 54                	ja     801010 <__umoddi3+0xa0>
  800fbc:	0f bd e8             	bsr    %eax,%ebp
  800fbf:	83 f5 1f             	xor    $0x1f,%ebp
  800fc2:	75 5c                	jne    801020 <__umoddi3+0xb0>
  800fc4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fc8:	39 3c 24             	cmp    %edi,(%esp)
  800fcb:	0f 87 e7 00 00 00    	ja     8010b8 <__umoddi3+0x148>
  800fd1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fd5:	29 f1                	sub    %esi,%ecx
  800fd7:	19 c7                	sbb    %eax,%edi
  800fd9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fdd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fe1:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fe5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fe9:	83 c4 14             	add    $0x14,%esp
  800fec:	5e                   	pop    %esi
  800fed:	5f                   	pop    %edi
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    
  800ff0:	85 f6                	test   %esi,%esi
  800ff2:	89 f5                	mov    %esi,%ebp
  800ff4:	75 0b                	jne    801001 <__umoddi3+0x91>
  800ff6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ffb:	31 d2                	xor    %edx,%edx
  800ffd:	f7 f6                	div    %esi
  800fff:	89 c5                	mov    %eax,%ebp
  801001:	8b 44 24 04          	mov    0x4(%esp),%eax
  801005:	31 d2                	xor    %edx,%edx
  801007:	f7 f5                	div    %ebp
  801009:	89 c8                	mov    %ecx,%eax
  80100b:	f7 f5                	div    %ebp
  80100d:	eb 9c                	jmp    800fab <__umoddi3+0x3b>
  80100f:	90                   	nop
  801010:	89 c8                	mov    %ecx,%eax
  801012:	89 fa                	mov    %edi,%edx
  801014:	83 c4 14             	add    $0x14,%esp
  801017:	5e                   	pop    %esi
  801018:	5f                   	pop    %edi
  801019:	5d                   	pop    %ebp
  80101a:	c3                   	ret    
  80101b:	90                   	nop
  80101c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801020:	8b 04 24             	mov    (%esp),%eax
  801023:	be 20 00 00 00       	mov    $0x20,%esi
  801028:	89 e9                	mov    %ebp,%ecx
  80102a:	29 ee                	sub    %ebp,%esi
  80102c:	d3 e2                	shl    %cl,%edx
  80102e:	89 f1                	mov    %esi,%ecx
  801030:	d3 e8                	shr    %cl,%eax
  801032:	89 e9                	mov    %ebp,%ecx
  801034:	89 44 24 04          	mov    %eax,0x4(%esp)
  801038:	8b 04 24             	mov    (%esp),%eax
  80103b:	09 54 24 04          	or     %edx,0x4(%esp)
  80103f:	89 fa                	mov    %edi,%edx
  801041:	d3 e0                	shl    %cl,%eax
  801043:	89 f1                	mov    %esi,%ecx
  801045:	89 44 24 08          	mov    %eax,0x8(%esp)
  801049:	8b 44 24 10          	mov    0x10(%esp),%eax
  80104d:	d3 ea                	shr    %cl,%edx
  80104f:	89 e9                	mov    %ebp,%ecx
  801051:	d3 e7                	shl    %cl,%edi
  801053:	89 f1                	mov    %esi,%ecx
  801055:	d3 e8                	shr    %cl,%eax
  801057:	89 e9                	mov    %ebp,%ecx
  801059:	09 f8                	or     %edi,%eax
  80105b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80105f:	f7 74 24 04          	divl   0x4(%esp)
  801063:	d3 e7                	shl    %cl,%edi
  801065:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801069:	89 d7                	mov    %edx,%edi
  80106b:	f7 64 24 08          	mull   0x8(%esp)
  80106f:	39 d7                	cmp    %edx,%edi
  801071:	89 c1                	mov    %eax,%ecx
  801073:	89 14 24             	mov    %edx,(%esp)
  801076:	72 2c                	jb     8010a4 <__umoddi3+0x134>
  801078:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80107c:	72 22                	jb     8010a0 <__umoddi3+0x130>
  80107e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801082:	29 c8                	sub    %ecx,%eax
  801084:	19 d7                	sbb    %edx,%edi
  801086:	89 e9                	mov    %ebp,%ecx
  801088:	89 fa                	mov    %edi,%edx
  80108a:	d3 e8                	shr    %cl,%eax
  80108c:	89 f1                	mov    %esi,%ecx
  80108e:	d3 e2                	shl    %cl,%edx
  801090:	89 e9                	mov    %ebp,%ecx
  801092:	d3 ef                	shr    %cl,%edi
  801094:	09 d0                	or     %edx,%eax
  801096:	89 fa                	mov    %edi,%edx
  801098:	83 c4 14             	add    $0x14,%esp
  80109b:	5e                   	pop    %esi
  80109c:	5f                   	pop    %edi
  80109d:	5d                   	pop    %ebp
  80109e:	c3                   	ret    
  80109f:	90                   	nop
  8010a0:	39 d7                	cmp    %edx,%edi
  8010a2:	75 da                	jne    80107e <__umoddi3+0x10e>
  8010a4:	8b 14 24             	mov    (%esp),%edx
  8010a7:	89 c1                	mov    %eax,%ecx
  8010a9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8010ad:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8010b1:	eb cb                	jmp    80107e <__umoddi3+0x10e>
  8010b3:	90                   	nop
  8010b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010b8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8010bc:	0f 82 0f ff ff ff    	jb     800fd1 <__umoddi3+0x61>
  8010c2:	e9 1a ff ff ff       	jmp    800fe1 <__umoddi3+0x71>
