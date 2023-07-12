
obj/user/evilhello.debug:     file format elf32-i386


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
  80002c:	e8 1e 00 00 00       	call   80004f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  800040:	00 
  800041:	c7 04 24 0c 00 10 f0 	movl   $0xf010000c,(%esp)
  800048:	e8 5e 00 00 00       	call   8000ab <sys_cputs>
}
  80004d:	c9                   	leave  
  80004e:	c3                   	ret    

0080004f <libmain>:

const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void libmain(int argc, char **argv)
{
  80004f:	55                   	push   %ebp
  800050:	89 e5                	mov    %esp,%ebp
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	83 ec 10             	sub    $0x10,%esp
  800057:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())]; // ENVX()得到id在Env[]数组中对应的下标
  80005d:	e8 d8 00 00 00       	call   80013a <sys_getenvid>
  800062:	25 ff 03 00 00       	and    $0x3ff,%eax
  800067:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800074:	85 db                	test   %ebx,%ebx
  800076:	7e 07                	jle    80007f <libmain+0x30>
		binaryname = argv[0];
  800078:	8b 06                	mov    (%esi),%eax
  80007a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800083:	89 1c 24             	mov    %ebx,(%esp)
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 07 00 00 00       	call   800097 <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    

00800097 <exit>:
 */

#include <inc/lib.h>

void exit(void)
{
  800097:	55                   	push   %ebp
  800098:	89 e5                	mov    %esp,%ebp
  80009a:	83 ec 18             	sub    $0x18,%esp
	// close_all();
	sys_env_destroy(0);
  80009d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a4:	e8 3f 00 00 00       	call   8000e8 <sys_env_destroy>
}
  8000a9:	c9                   	leave  
  8000aa:	c3                   	ret    

008000ab <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bc:	89 c3                	mov    %eax,%ebx
  8000be:	89 c7                	mov    %eax,%edi
  8000c0:	89 c6                	mov    %eax,%esi
  8000c2:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c4:	5b                   	pop    %ebx
  8000c5:	5e                   	pop    %esi
  8000c6:	5f                   	pop    %edi
  8000c7:	5d                   	pop    %ebp
  8000c8:	c3                   	ret    

008000c9 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	57                   	push   %edi
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d9:	89 d1                	mov    %edx,%ecx
  8000db:	89 d3                	mov    %edx,%ebx
  8000dd:	89 d7                	mov    %edx,%edi
  8000df:	89 d6                	mov    %edx,%esi
  8000e1:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5f                   	pop    %edi
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    

008000e8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	57                   	push   %edi
  8000ec:	56                   	push   %esi
  8000ed:	53                   	push   %ebx
  8000ee:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8000f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f6:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fe:	89 cb                	mov    %ecx,%ebx
  800100:	89 cf                	mov    %ecx,%edi
  800102:	89 ce                	mov    %ecx,%esi
  800104:	cd 30                	int    $0x30
	if(check && ret > 0)
  800106:	85 c0                	test   %eax,%eax
  800108:	7e 28                	jle    800132 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80010e:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800115:	00 
  800116:	c7 44 24 08 0a 11 80 	movl   $0x80110a,0x8(%esp)
  80011d:	00 
  80011e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800125:	00 
  800126:	c7 04 24 27 11 80 00 	movl   $0x801127,(%esp)
  80012d:	e8 ae 02 00 00       	call   8003e0 <_panic>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800132:	83 c4 2c             	add    $0x2c,%esp
  800135:	5b                   	pop    %ebx
  800136:	5e                   	pop    %esi
  800137:	5f                   	pop    %edi
  800138:	5d                   	pop    %ebp
  800139:	c3                   	ret    

0080013a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	57                   	push   %edi
  80013e:	56                   	push   %esi
  80013f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800140:	ba 00 00 00 00       	mov    $0x0,%edx
  800145:	b8 02 00 00 00       	mov    $0x2,%eax
  80014a:	89 d1                	mov    %edx,%ecx
  80014c:	89 d3                	mov    %edx,%ebx
  80014e:	89 d7                	mov    %edx,%edi
  800150:	89 d6                	mov    %edx,%esi
  800152:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800154:	5b                   	pop    %ebx
  800155:	5e                   	pop    %esi
  800156:	5f                   	pop    %edi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    

00800159 <sys_yield>:

void
sys_yield(void)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	57                   	push   %edi
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015f:	ba 00 00 00 00       	mov    $0x0,%edx
  800164:	b8 0b 00 00 00       	mov    $0xb,%eax
  800169:	89 d1                	mov    %edx,%ecx
  80016b:	89 d3                	mov    %edx,%ebx
  80016d:	89 d7                	mov    %edx,%edi
  80016f:	89 d6                	mov    %edx,%esi
  800171:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800173:	5b                   	pop    %ebx
  800174:	5e                   	pop    %esi
  800175:	5f                   	pop    %edi
  800176:	5d                   	pop    %ebp
  800177:	c3                   	ret    

00800178 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	57                   	push   %edi
  80017c:	56                   	push   %esi
  80017d:	53                   	push   %ebx
  80017e:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800181:	be 00 00 00 00       	mov    $0x0,%esi
  800186:	b8 04 00 00 00       	mov    $0x4,%eax
  80018b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018e:	8b 55 08             	mov    0x8(%ebp),%edx
  800191:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800194:	89 f7                	mov    %esi,%edi
  800196:	cd 30                	int    $0x30
	if(check && ret > 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	7e 28                	jle    8001c4 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80019c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001a7:	00 
  8001a8:	c7 44 24 08 0a 11 80 	movl   $0x80110a,0x8(%esp)
  8001af:	00 
  8001b0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001b7:	00 
  8001b8:	c7 04 24 27 11 80 00 	movl   $0x801127,(%esp)
  8001bf:	e8 1c 02 00 00       	call   8003e0 <_panic>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c4:	83 c4 2c             	add    $0x2c,%esp
  8001c7:	5b                   	pop    %ebx
  8001c8:	5e                   	pop    %esi
  8001c9:	5f                   	pop    %edi
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    

008001cc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	57                   	push   %edi
  8001d0:	56                   	push   %esi
  8001d1:	53                   	push   %ebx
  8001d2:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8001d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001eb:	85 c0                	test   %eax,%eax
  8001ed:	7e 28                	jle    800217 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ef:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f3:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001fa:	00 
  8001fb:	c7 44 24 08 0a 11 80 	movl   $0x80110a,0x8(%esp)
  800202:	00 
  800203:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80020a:	00 
  80020b:	c7 04 24 27 11 80 00 	movl   $0x801127,(%esp)
  800212:	e8 c9 01 00 00       	call   8003e0 <_panic>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800217:	83 c4 2c             	add    $0x2c,%esp
  80021a:	5b                   	pop    %ebx
  80021b:	5e                   	pop    %esi
  80021c:	5f                   	pop    %edi
  80021d:	5d                   	pop    %ebp
  80021e:	c3                   	ret    

0080021f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	57                   	push   %edi
  800223:	56                   	push   %esi
  800224:	53                   	push   %ebx
  800225:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800228:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022d:	b8 06 00 00 00       	mov    $0x6,%eax
  800232:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800235:	8b 55 08             	mov    0x8(%ebp),%edx
  800238:	89 df                	mov    %ebx,%edi
  80023a:	89 de                	mov    %ebx,%esi
  80023c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80023e:	85 c0                	test   %eax,%eax
  800240:	7e 28                	jle    80026a <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800242:	89 44 24 10          	mov    %eax,0x10(%esp)
  800246:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80024d:	00 
  80024e:	c7 44 24 08 0a 11 80 	movl   $0x80110a,0x8(%esp)
  800255:	00 
  800256:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80025d:	00 
  80025e:	c7 04 24 27 11 80 00 	movl   $0x801127,(%esp)
  800265:	e8 76 01 00 00       	call   8003e0 <_panic>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80026a:	83 c4 2c             	add    $0x2c,%esp
  80026d:	5b                   	pop    %ebx
  80026e:	5e                   	pop    %esi
  80026f:	5f                   	pop    %edi
  800270:	5d                   	pop    %ebp
  800271:	c3                   	ret    

00800272 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	57                   	push   %edi
  800276:	56                   	push   %esi
  800277:	53                   	push   %ebx
  800278:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  80027b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800280:	b8 08 00 00 00       	mov    $0x8,%eax
  800285:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800288:	8b 55 08             	mov    0x8(%ebp),%edx
  80028b:	89 df                	mov    %ebx,%edi
  80028d:	89 de                	mov    %ebx,%esi
  80028f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800291:	85 c0                	test   %eax,%eax
  800293:	7e 28                	jle    8002bd <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800295:	89 44 24 10          	mov    %eax,0x10(%esp)
  800299:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a0:	00 
  8002a1:	c7 44 24 08 0a 11 80 	movl   $0x80110a,0x8(%esp)
  8002a8:	00 
  8002a9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b0:	00 
  8002b1:	c7 04 24 27 11 80 00 	movl   $0x801127,(%esp)
  8002b8:	e8 23 01 00 00       	call   8003e0 <_panic>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002bd:	83 c4 2c             	add    $0x2c,%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5f                   	pop    %edi
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    

008002c5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  8002ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d3:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002db:	8b 55 08             	mov    0x8(%ebp),%edx
  8002de:	89 df                	mov    %ebx,%edi
  8002e0:	89 de                	mov    %ebx,%esi
  8002e2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002e4:	85 c0                	test   %eax,%eax
  8002e6:	7e 28                	jle    800310 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ec:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f3:	00 
  8002f4:	c7 44 24 08 0a 11 80 	movl   $0x80110a,0x8(%esp)
  8002fb:	00 
  8002fc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800303:	00 
  800304:	c7 04 24 27 11 80 00 	movl   $0x801127,(%esp)
  80030b:	e8 d0 00 00 00       	call   8003e0 <_panic>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800310:	83 c4 2c             	add    $0x2c,%esp
  800313:	5b                   	pop    %ebx
  800314:	5e                   	pop    %esi
  800315:	5f                   	pop    %edi
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	57                   	push   %edi
  80031c:	56                   	push   %esi
  80031d:	53                   	push   %ebx
  80031e:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800321:	bb 00 00 00 00       	mov    $0x0,%ebx
  800326:	b8 0a 00 00 00       	mov    $0xa,%eax
  80032b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032e:	8b 55 08             	mov    0x8(%ebp),%edx
  800331:	89 df                	mov    %ebx,%edi
  800333:	89 de                	mov    %ebx,%esi
  800335:	cd 30                	int    $0x30
	if(check && ret > 0)
  800337:	85 c0                	test   %eax,%eax
  800339:	7e 28                	jle    800363 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80033f:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800346:	00 
  800347:	c7 44 24 08 0a 11 80 	movl   $0x80110a,0x8(%esp)
  80034e:	00 
  80034f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800356:	00 
  800357:	c7 04 24 27 11 80 00 	movl   $0x801127,(%esp)
  80035e:	e8 7d 00 00 00       	call   8003e0 <_panic>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800363:	83 c4 2c             	add    $0x2c,%esp
  800366:	5b                   	pop    %ebx
  800367:	5e                   	pop    %esi
  800368:	5f                   	pop    %edi
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	57                   	push   %edi
  80036f:	56                   	push   %esi
  800370:	53                   	push   %ebx
	asm volatile("int %1\n"
  800371:	be 00 00 00 00       	mov    $0x0,%esi
  800376:	b8 0c 00 00 00       	mov    $0xc,%eax
  80037b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80037e:	8b 55 08             	mov    0x8(%ebp),%edx
  800381:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800384:	8b 7d 14             	mov    0x14(%ebp),%edi
  800387:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800389:	5b                   	pop    %ebx
  80038a:	5e                   	pop    %esi
  80038b:	5f                   	pop    %edi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	57                   	push   %edi
  800392:	56                   	push   %esi
  800393:	53                   	push   %ebx
  800394:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("int %1\n"
  800397:	b9 00 00 00 00       	mov    $0x0,%ecx
  80039c:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a4:	89 cb                	mov    %ecx,%ebx
  8003a6:	89 cf                	mov    %ecx,%edi
  8003a8:	89 ce                	mov    %ecx,%esi
  8003aa:	cd 30                	int    $0x30
	if(check && ret > 0)
  8003ac:	85 c0                	test   %eax,%eax
  8003ae:	7e 28                	jle    8003d8 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003b4:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003bb:	00 
  8003bc:	c7 44 24 08 0a 11 80 	movl   $0x80110a,0x8(%esp)
  8003c3:	00 
  8003c4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003cb:	00 
  8003cc:	c7 04 24 27 11 80 00 	movl   $0x801127,(%esp)
  8003d3:	e8 08 00 00 00       	call   8003e0 <_panic>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003d8:	83 c4 2c             	add    $0x2c,%esp
  8003db:	5b                   	pop    %ebx
  8003dc:	5e                   	pop    %esi
  8003dd:	5f                   	pop    %edi
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	56                   	push   %esi
  8003e4:	53                   	push   %ebx
  8003e5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003e8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003eb:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8003f1:	e8 44 fd ff ff       	call   80013a <sys_getenvid>
  8003f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800400:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800404:	89 74 24 08          	mov    %esi,0x8(%esp)
  800408:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040c:	c7 04 24 38 11 80 00 	movl   $0x801138,(%esp)
  800413:	e8 c1 00 00 00       	call   8004d9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800418:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80041c:	8b 45 10             	mov    0x10(%ebp),%eax
  80041f:	89 04 24             	mov    %eax,(%esp)
  800422:	e8 51 00 00 00       	call   800478 <vcprintf>
	cprintf("\n");
  800427:	c7 04 24 5b 11 80 00 	movl   $0x80115b,(%esp)
  80042e:	e8 a6 00 00 00       	call   8004d9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800433:	cc                   	int3   
  800434:	eb fd                	jmp    800433 <_panic+0x53>

00800436 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
  800439:	53                   	push   %ebx
  80043a:	83 ec 14             	sub    $0x14,%esp
  80043d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800440:	8b 13                	mov    (%ebx),%edx
  800442:	8d 42 01             	lea    0x1(%edx),%eax
  800445:	89 03                	mov    %eax,(%ebx)
  800447:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80044a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80044e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800453:	75 19                	jne    80046e <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800455:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80045c:	00 
  80045d:	8d 43 08             	lea    0x8(%ebx),%eax
  800460:	89 04 24             	mov    %eax,(%esp)
  800463:	e8 43 fc ff ff       	call   8000ab <sys_cputs>
		b->idx = 0;
  800468:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80046e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800472:	83 c4 14             	add    $0x14,%esp
  800475:	5b                   	pop    %ebx
  800476:	5d                   	pop    %ebp
  800477:	c3                   	ret    

00800478 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
  80047b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800481:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800488:	00 00 00 
	b.cnt = 0;
  80048b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800492:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800495:	8b 45 0c             	mov    0xc(%ebp),%eax
  800498:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80049c:	8b 45 08             	mov    0x8(%ebp),%eax
  80049f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004a3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ad:	c7 04 24 36 04 80 00 	movl   $0x800436,(%esp)
  8004b4:	e8 b5 01 00 00       	call   80066e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004b9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004c9:	89 04 24             	mov    %eax,(%esp)
  8004cc:	e8 da fb ff ff       	call   8000ab <sys_cputs>

	return b.cnt;
}
  8004d1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004d7:	c9                   	leave  
  8004d8:	c3                   	ret    

008004d9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004d9:	55                   	push   %ebp
  8004da:	89 e5                	mov    %esp,%ebp
  8004dc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004df:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e9:	89 04 24             	mov    %eax,(%esp)
  8004ec:	e8 87 ff ff ff       	call   800478 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004f1:	c9                   	leave  
  8004f2:	c3                   	ret    
  8004f3:	66 90                	xchg   %ax,%ax
  8004f5:	66 90                	xchg   %ax,%ax
  8004f7:	66 90                	xchg   %ax,%ax
  8004f9:	66 90                	xchg   %ax,%ax
  8004fb:	66 90                	xchg   %ax,%ax
  8004fd:	66 90                	xchg   %ax,%ax
  8004ff:	90                   	nop

00800500 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
  800503:	57                   	push   %edi
  800504:	56                   	push   %esi
  800505:	53                   	push   %ebx
  800506:	83 ec 3c             	sub    $0x3c,%esp
  800509:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80050c:	89 d7                	mov    %edx,%edi
  80050e:	8b 45 08             	mov    0x8(%ebp),%eax
  800511:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800514:	8b 45 0c             	mov    0xc(%ebp),%eax
  800517:	89 c3                	mov    %eax,%ebx
  800519:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80051c:	8b 45 10             	mov    0x10(%ebp),%eax
  80051f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  800522:	b9 00 00 00 00       	mov    $0x0,%ecx
  800527:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80052d:	39 d9                	cmp    %ebx,%ecx
  80052f:	72 05                	jb     800536 <printnum+0x36>
  800531:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800534:	77 69                	ja     80059f <printnum+0x9f>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800536:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800539:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80053d:	83 ee 01             	sub    $0x1,%esi
  800540:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800544:	89 44 24 08          	mov    %eax,0x8(%esp)
  800548:	8b 44 24 08          	mov    0x8(%esp),%eax
  80054c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800550:	89 c3                	mov    %eax,%ebx
  800552:	89 d6                	mov    %edx,%esi
  800554:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800557:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80055a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80055e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800562:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800565:	89 04 24             	mov    %eax,(%esp)
  800568:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80056b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056f:	e8 ec 08 00 00       	call   800e60 <__udivdi3>
  800574:	89 d9                	mov    %ebx,%ecx
  800576:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80057a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80057e:	89 04 24             	mov    %eax,(%esp)
  800581:	89 54 24 04          	mov    %edx,0x4(%esp)
  800585:	89 fa                	mov    %edi,%edx
  800587:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80058a:	e8 71 ff ff ff       	call   800500 <printnum>
  80058f:	eb 1b                	jmp    8005ac <printnum+0xac>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800591:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800595:	8b 45 18             	mov    0x18(%ebp),%eax
  800598:	89 04 24             	mov    %eax,(%esp)
  80059b:	ff d3                	call   *%ebx
  80059d:	eb 03                	jmp    8005a2 <printnum+0xa2>
  80059f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while (--width > 0)
  8005a2:	83 ee 01             	sub    $0x1,%esi
  8005a5:	85 f6                	test   %esi,%esi
  8005a7:	7f e8                	jg     800591 <printnum+0x91>
  8005a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8005b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005be:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c5:	89 04 24             	mov    %eax,(%esp)
  8005c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005cf:	e8 bc 09 00 00       	call   800f90 <__umoddi3>
  8005d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d8:	0f be 80 5d 11 80 00 	movsbl 0x80115d(%eax),%eax
  8005df:	89 04 24             	mov    %eax,(%esp)
  8005e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005e5:	ff d0                	call   *%eax
}
  8005e7:	83 c4 3c             	add    $0x3c,%esp
  8005ea:	5b                   	pop    %ebx
  8005eb:	5e                   	pop    %esi
  8005ec:	5f                   	pop    %edi
  8005ed:	5d                   	pop    %ebp
  8005ee:	c3                   	ret    

008005ef <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005ef:	55                   	push   %ebp
  8005f0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005f2:	83 fa 01             	cmp    $0x1,%edx
  8005f5:	7e 0e                	jle    800605 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005f7:	8b 10                	mov    (%eax),%edx
  8005f9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005fc:	89 08                	mov    %ecx,(%eax)
  8005fe:	8b 02                	mov    (%edx),%eax
  800600:	8b 52 04             	mov    0x4(%edx),%edx
  800603:	eb 22                	jmp    800627 <getuint+0x38>
	else if (lflag)
  800605:	85 d2                	test   %edx,%edx
  800607:	74 10                	je     800619 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800609:	8b 10                	mov    (%eax),%edx
  80060b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80060e:	89 08                	mov    %ecx,(%eax)
  800610:	8b 02                	mov    (%edx),%eax
  800612:	ba 00 00 00 00       	mov    $0x0,%edx
  800617:	eb 0e                	jmp    800627 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800619:	8b 10                	mov    (%eax),%edx
  80061b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80061e:	89 08                	mov    %ecx,(%eax)
  800620:	8b 02                	mov    (%edx),%eax
  800622:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800627:	5d                   	pop    %ebp
  800628:	c3                   	ret    

00800629 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800629:	55                   	push   %ebp
  80062a:	89 e5                	mov    %esp,%ebp
  80062c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80062f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800633:	8b 10                	mov    (%eax),%edx
  800635:	3b 50 04             	cmp    0x4(%eax),%edx
  800638:	73 0a                	jae    800644 <sprintputch+0x1b>
		*b->buf++ = ch;
  80063a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80063d:	89 08                	mov    %ecx,(%eax)
  80063f:	8b 45 08             	mov    0x8(%ebp),%eax
  800642:	88 02                	mov    %al,(%edx)
}
  800644:	5d                   	pop    %ebp
  800645:	c3                   	ret    

00800646 <printfmt>:
{
  800646:	55                   	push   %ebp
  800647:	89 e5                	mov    %esp,%ebp
  800649:	83 ec 18             	sub    $0x18,%esp
	va_start(ap, fmt);
  80064c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80064f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800653:	8b 45 10             	mov    0x10(%ebp),%eax
  800656:	89 44 24 08          	mov    %eax,0x8(%esp)
  80065a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800661:	8b 45 08             	mov    0x8(%ebp),%eax
  800664:	89 04 24             	mov    %eax,(%esp)
  800667:	e8 02 00 00 00       	call   80066e <vprintfmt>
}
  80066c:	c9                   	leave  
  80066d:	c3                   	ret    

0080066e <vprintfmt>:
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	57                   	push   %edi
  800672:	56                   	push   %esi
  800673:	53                   	push   %ebx
  800674:	83 ec 3c             	sub    $0x3c,%esp
  800677:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80067a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80067d:	eb 14                	jmp    800693 <vprintfmt+0x25>
			if (ch == '\0')
  80067f:	85 c0                	test   %eax,%eax
  800681:	0f 84 b3 03 00 00    	je     800a3a <vprintfmt+0x3cc>
			putch(ch, putdat);
  800687:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80068b:	89 04 24             	mov    %eax,(%esp)
  80068e:	ff 55 08             	call   *0x8(%ebp)
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  800691:	89 f3                	mov    %esi,%ebx
  800693:	8d 73 01             	lea    0x1(%ebx),%esi
  800696:	0f b6 03             	movzbl (%ebx),%eax
  800699:	83 f8 25             	cmp    $0x25,%eax
  80069c:	75 e1                	jne    80067f <vprintfmt+0x11>
  80069e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8006a2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8006a9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8006b0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8006b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8006bc:	eb 1d                	jmp    8006db <vprintfmt+0x6d>
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006be:	89 de                	mov    %ebx,%esi
			padc = '-';
  8006c0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8006c4:	eb 15                	jmp    8006db <vprintfmt+0x6d>
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006c6:	89 de                	mov    %ebx,%esi
			padc = '0';
  8006c8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8006cc:	eb 0d                	jmp    8006db <vprintfmt+0x6d>
				width = precision, precision = -1;
  8006ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006d4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006db:	8d 5e 01             	lea    0x1(%esi),%ebx
  8006de:	0f b6 0e             	movzbl (%esi),%ecx
  8006e1:	0f b6 c1             	movzbl %cl,%eax
  8006e4:	83 e9 23             	sub    $0x23,%ecx
  8006e7:	80 f9 55             	cmp    $0x55,%cl
  8006ea:	0f 87 2a 03 00 00    	ja     800a1a <vprintfmt+0x3ac>
  8006f0:	0f b6 c9             	movzbl %cl,%ecx
  8006f3:	ff 24 8d a0 12 80 00 	jmp    *0x8012a0(,%ecx,4)
  8006fa:	89 de                	mov    %ebx,%esi
  8006fc:	b9 00 00 00 00       	mov    $0x0,%ecx
				precision = precision * 10 + ch - '0';
  800701:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800704:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800708:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80070b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80070e:	83 fb 09             	cmp    $0x9,%ebx
  800711:	77 36                	ja     800749 <vprintfmt+0xdb>
			for (precision = 0;; ++fmt)
  800713:	83 c6 01             	add    $0x1,%esi
			}
  800716:	eb e9                	jmp    800701 <vprintfmt+0x93>
			precision = va_arg(ap, int);
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8d 48 04             	lea    0x4(%eax),%ecx
  80071e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800721:	8b 00                	mov    (%eax),%eax
  800723:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800726:	89 de                	mov    %ebx,%esi
			goto process_precision;
  800728:	eb 22                	jmp    80074c <vprintfmt+0xde>
  80072a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80072d:	85 c9                	test   %ecx,%ecx
  80072f:	b8 00 00 00 00       	mov    $0x0,%eax
  800734:	0f 49 c1             	cmovns %ecx,%eax
  800737:	89 45 dc             	mov    %eax,-0x24(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80073a:	89 de                	mov    %ebx,%esi
  80073c:	eb 9d                	jmp    8006db <vprintfmt+0x6d>
  80073e:	89 de                	mov    %ebx,%esi
			altflag = 1;
  800740:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
  800747:	eb 92                	jmp    8006db <vprintfmt+0x6d>
  800749:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
			if (width < 0)
  80074c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800750:	79 89                	jns    8006db <vprintfmt+0x6d>
  800752:	e9 77 ff ff ff       	jmp    8006ce <vprintfmt+0x60>
			lflag++;
  800757:	83 c2 01             	add    $0x1,%edx
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80075a:	89 de                	mov    %ebx,%esi
			goto reswitch;
  80075c:	e9 7a ff ff ff       	jmp    8006db <vprintfmt+0x6d>
			putch(va_arg(ap, int), putdat);
  800761:	8b 45 14             	mov    0x14(%ebp),%eax
  800764:	8d 50 04             	lea    0x4(%eax),%edx
  800767:	89 55 14             	mov    %edx,0x14(%ebp)
  80076a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80076e:	8b 00                	mov    (%eax),%eax
  800770:	89 04 24             	mov    %eax,(%esp)
  800773:	ff 55 08             	call   *0x8(%ebp)
			break;
  800776:	e9 18 ff ff ff       	jmp    800693 <vprintfmt+0x25>
			err = va_arg(ap, int);
  80077b:	8b 45 14             	mov    0x14(%ebp),%eax
  80077e:	8d 50 04             	lea    0x4(%eax),%edx
  800781:	89 55 14             	mov    %edx,0x14(%ebp)
  800784:	8b 00                	mov    (%eax),%eax
  800786:	99                   	cltd   
  800787:	31 d0                	xor    %edx,%eax
  800789:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80078b:	83 f8 0f             	cmp    $0xf,%eax
  80078e:	7f 0b                	jg     80079b <vprintfmt+0x12d>
  800790:	8b 14 85 00 14 80 00 	mov    0x801400(,%eax,4),%edx
  800797:	85 d2                	test   %edx,%edx
  800799:	75 20                	jne    8007bb <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
  80079b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079f:	c7 44 24 08 75 11 80 	movl   $0x801175,0x8(%esp)
  8007a6:	00 
  8007a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ae:	89 04 24             	mov    %eax,(%esp)
  8007b1:	e8 90 fe ff ff       	call   800646 <printfmt>
  8007b6:	e9 d8 fe ff ff       	jmp    800693 <vprintfmt+0x25>
				printfmt(putch, putdat, "%s", p);
  8007bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007bf:	c7 44 24 08 7e 11 80 	movl   $0x80117e,0x8(%esp)
  8007c6:	00 
  8007c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ce:	89 04 24             	mov    %eax,(%esp)
  8007d1:	e8 70 fe ff ff       	call   800646 <printfmt>
  8007d6:	e9 b8 fe ff ff       	jmp    800693 <vprintfmt+0x25>
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8007db:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8007de:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
  8007e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e7:	8d 50 04             	lea    0x4(%eax),%edx
  8007ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ed:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8007ef:	85 f6                	test   %esi,%esi
  8007f1:	b8 6e 11 80 00       	mov    $0x80116e,%eax
  8007f6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8007f9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007fd:	0f 84 97 00 00 00    	je     80089a <vprintfmt+0x22c>
  800803:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800807:	0f 8e 9b 00 00 00    	jle    8008a8 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
  80080d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800811:	89 34 24             	mov    %esi,(%esp)
  800814:	e8 cf 02 00 00       	call   800ae8 <strnlen>
  800819:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80081c:	29 c2                	sub    %eax,%edx
  80081e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
  800821:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800825:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800828:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80082b:	8b 75 08             	mov    0x8(%ebp),%esi
  80082e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800831:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800833:	eb 0f                	jmp    800844 <vprintfmt+0x1d6>
					putch(padc, putdat);
  800835:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800839:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80083c:	89 04 24             	mov    %eax,(%esp)
  80083f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800841:	83 eb 01             	sub    $0x1,%ebx
  800844:	85 db                	test   %ebx,%ebx
  800846:	7f ed                	jg     800835 <vprintfmt+0x1c7>
  800848:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80084b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80084e:	85 d2                	test   %edx,%edx
  800850:	b8 00 00 00 00       	mov    $0x0,%eax
  800855:	0f 49 c2             	cmovns %edx,%eax
  800858:	29 c2                	sub    %eax,%edx
  80085a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80085d:	89 d7                	mov    %edx,%edi
  80085f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800862:	eb 50                	jmp    8008b4 <vprintfmt+0x246>
				if (altflag && (ch < ' ' || ch > '~'))
  800864:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800868:	74 1e                	je     800888 <vprintfmt+0x21a>
  80086a:	0f be d2             	movsbl %dl,%edx
  80086d:	83 ea 20             	sub    $0x20,%edx
  800870:	83 fa 5e             	cmp    $0x5e,%edx
  800873:	76 13                	jbe    800888 <vprintfmt+0x21a>
					putch('?', putdat);
  800875:	8b 45 0c             	mov    0xc(%ebp),%eax
  800878:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800883:	ff 55 08             	call   *0x8(%ebp)
  800886:	eb 0d                	jmp    800895 <vprintfmt+0x227>
					putch(ch, putdat);
  800888:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80088f:	89 04 24             	mov    %eax,(%esp)
  800892:	ff 55 08             	call   *0x8(%ebp)
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800895:	83 ef 01             	sub    $0x1,%edi
  800898:	eb 1a                	jmp    8008b4 <vprintfmt+0x246>
  80089a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80089d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8008a0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8008a3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8008a6:	eb 0c                	jmp    8008b4 <vprintfmt+0x246>
  8008a8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8008ab:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8008ae:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8008b1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8008b4:	83 c6 01             	add    $0x1,%esi
  8008b7:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8008bb:	0f be c2             	movsbl %dl,%eax
  8008be:	85 c0                	test   %eax,%eax
  8008c0:	74 27                	je     8008e9 <vprintfmt+0x27b>
  8008c2:	85 db                	test   %ebx,%ebx
  8008c4:	78 9e                	js     800864 <vprintfmt+0x1f6>
  8008c6:	83 eb 01             	sub    $0x1,%ebx
  8008c9:	79 99                	jns    800864 <vprintfmt+0x1f6>
  8008cb:	89 f8                	mov    %edi,%eax
  8008cd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8008d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d3:	89 c3                	mov    %eax,%ebx
  8008d5:	eb 1a                	jmp    8008f1 <vprintfmt+0x283>
				putch(' ', putdat);
  8008d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008db:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008e2:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8008e4:	83 eb 01             	sub    $0x1,%ebx
  8008e7:	eb 08                	jmp    8008f1 <vprintfmt+0x283>
  8008e9:	89 fb                	mov    %edi,%ebx
  8008eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8008f1:	85 db                	test   %ebx,%ebx
  8008f3:	7f e2                	jg     8008d7 <vprintfmt+0x269>
  8008f5:	89 75 08             	mov    %esi,0x8(%ebp)
  8008f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008fb:	e9 93 fd ff ff       	jmp    800693 <vprintfmt+0x25>
	if (lflag >= 2)
  800900:	83 fa 01             	cmp    $0x1,%edx
  800903:	7e 16                	jle    80091b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800905:	8b 45 14             	mov    0x14(%ebp),%eax
  800908:	8d 50 08             	lea    0x8(%eax),%edx
  80090b:	89 55 14             	mov    %edx,0x14(%ebp)
  80090e:	8b 50 04             	mov    0x4(%eax),%edx
  800911:	8b 00                	mov    (%eax),%eax
  800913:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800916:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800919:	eb 32                	jmp    80094d <vprintfmt+0x2df>
	else if (lflag)
  80091b:	85 d2                	test   %edx,%edx
  80091d:	74 18                	je     800937 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  80091f:	8b 45 14             	mov    0x14(%ebp),%eax
  800922:	8d 50 04             	lea    0x4(%eax),%edx
  800925:	89 55 14             	mov    %edx,0x14(%ebp)
  800928:	8b 30                	mov    (%eax),%esi
  80092a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  80092d:	89 f0                	mov    %esi,%eax
  80092f:	c1 f8 1f             	sar    $0x1f,%eax
  800932:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800935:	eb 16                	jmp    80094d <vprintfmt+0x2df>
		return va_arg(*ap, int);
  800937:	8b 45 14             	mov    0x14(%ebp),%eax
  80093a:	8d 50 04             	lea    0x4(%eax),%edx
  80093d:	89 55 14             	mov    %edx,0x14(%ebp)
  800940:	8b 30                	mov    (%eax),%esi
  800942:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800945:	89 f0                	mov    %esi,%eax
  800947:	c1 f8 1f             	sar    $0x1f,%eax
  80094a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  80094d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800950:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			base = 10; // base代表进制数
  800953:	b9 0a 00 00 00       	mov    $0xa,%ecx
			if ((long long)num < 0)
  800958:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80095c:	0f 89 80 00 00 00    	jns    8009e2 <vprintfmt+0x374>
				putch('-', putdat);
  800962:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800966:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80096d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  800970:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800973:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800976:	f7 d8                	neg    %eax
  800978:	83 d2 00             	adc    $0x0,%edx
  80097b:	f7 da                	neg    %edx
			base = 10; // base代表进制数
  80097d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800982:	eb 5e                	jmp    8009e2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
  800984:	8d 45 14             	lea    0x14(%ebp),%eax
  800987:	e8 63 fc ff ff       	call   8005ef <getuint>
			base = 10;
  80098c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800991:	eb 4f                	jmp    8009e2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
  800993:	8d 45 14             	lea    0x14(%ebp),%eax
  800996:	e8 54 fc ff ff       	call   8005ef <getuint>
			base = 8;
  80099b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8009a0:	eb 40                	jmp    8009e2 <vprintfmt+0x374>
			putch('0', putdat);
  8009a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009a6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009ad:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8009b0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009b4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009bb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8009be:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c1:	8d 50 04             	lea    0x4(%eax),%edx
  8009c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8009c7:	8b 00                	mov    (%eax),%eax
  8009c9:	ba 00 00 00 00       	mov    $0x0,%edx
			base = 16;
  8009ce:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8009d3:	eb 0d                	jmp    8009e2 <vprintfmt+0x374>
			num = getuint(&ap, lflag);
  8009d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8009d8:	e8 12 fc ff ff       	call   8005ef <getuint>
			base = 16;
  8009dd:	b9 10 00 00 00       	mov    $0x10,%ecx
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  8009e2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  8009e6:	89 74 24 10          	mov    %esi,0x10(%esp)
  8009ea:	8b 75 dc             	mov    -0x24(%ebp),%esi
  8009ed:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8009f1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8009f5:	89 04 24             	mov    %eax,(%esp)
  8009f8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009fc:	89 fa                	mov    %edi,%edx
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	e8 fa fa ff ff       	call   800500 <printnum>
			break;
  800a06:	e9 88 fc ff ff       	jmp    800693 <vprintfmt+0x25>
			putch(ch, putdat);
  800a0b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a0f:	89 04 24             	mov    %eax,(%esp)
  800a12:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a15:	e9 79 fc ff ff       	jmp    800693 <vprintfmt+0x25>
			putch('%', putdat);
  800a1a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a1e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a25:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a28:	89 f3                	mov    %esi,%ebx
  800a2a:	eb 03                	jmp    800a2f <vprintfmt+0x3c1>
  800a2c:	83 eb 01             	sub    $0x1,%ebx
  800a2f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800a33:	75 f7                	jne    800a2c <vprintfmt+0x3be>
  800a35:	e9 59 fc ff ff       	jmp    800693 <vprintfmt+0x25>
}
  800a3a:	83 c4 3c             	add    $0x3c,%esp
  800a3d:	5b                   	pop    %ebx
  800a3e:	5e                   	pop    %esi
  800a3f:	5f                   	pop    %edi
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	83 ec 28             	sub    $0x28,%esp
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  800a4e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a51:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a55:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a5f:	85 c0                	test   %eax,%eax
  800a61:	74 30                	je     800a93 <vsnprintf+0x51>
  800a63:	85 d2                	test   %edx,%edx
  800a65:	7e 2c                	jle    800a93 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  800a67:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a6e:	8b 45 10             	mov    0x10(%ebp),%eax
  800a71:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a75:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a78:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7c:	c7 04 24 29 06 80 00 	movl   $0x800629,(%esp)
  800a83:	e8 e6 fb ff ff       	call   80066e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a88:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a8b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a91:	eb 05                	jmp    800a98 <vsnprintf+0x56>
		return -E_INVAL;
  800a93:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a98:	c9                   	leave  
  800a99:	c3                   	ret    

00800a9a <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800aa0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800aa3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aa7:	8b 45 10             	mov    0x10(%ebp),%eax
  800aaa:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab8:	89 04 24             	mov    %eax,(%esp)
  800abb:	e8 82 ff ff ff       	call   800a42 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ac0:	c9                   	leave  
  800ac1:	c3                   	ret    
  800ac2:	66 90                	xchg   %ax,%ax
  800ac4:	66 90                	xchg   %ax,%ax
  800ac6:	66 90                	xchg   %ax,%ax
  800ac8:	66 90                	xchg   %ax,%ax
  800aca:	66 90                	xchg   %ax,%ax
  800acc:	66 90                	xchg   %ax,%ax
  800ace:	66 90                	xchg   %ax,%ax

00800ad0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ad6:	b8 00 00 00 00       	mov    $0x0,%eax
  800adb:	eb 03                	jmp    800ae0 <strlen+0x10>
		n++;
  800add:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800ae0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ae4:	75 f7                	jne    800add <strlen+0xd>
	return n;
}
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aee:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800af1:	b8 00 00 00 00       	mov    $0x0,%eax
  800af6:	eb 03                	jmp    800afb <strnlen+0x13>
		n++;
  800af8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800afb:	39 d0                	cmp    %edx,%eax
  800afd:	74 06                	je     800b05 <strnlen+0x1d>
  800aff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b03:	75 f3                	jne    800af8 <strnlen+0x10>
	return n;
}
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	53                   	push   %ebx
  800b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b11:	89 c2                	mov    %eax,%edx
  800b13:	83 c2 01             	add    $0x1,%edx
  800b16:	83 c1 01             	add    $0x1,%ecx
  800b19:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b1d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b20:	84 db                	test   %bl,%bl
  800b22:	75 ef                	jne    800b13 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b24:	5b                   	pop    %ebx
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	53                   	push   %ebx
  800b2b:	83 ec 08             	sub    $0x8,%esp
  800b2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b31:	89 1c 24             	mov    %ebx,(%esp)
  800b34:	e8 97 ff ff ff       	call   800ad0 <strlen>
	strcpy(dst + len, src);
  800b39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b40:	01 d8                	add    %ebx,%eax
  800b42:	89 04 24             	mov    %eax,(%esp)
  800b45:	e8 bd ff ff ff       	call   800b07 <strcpy>
	return dst;
}
  800b4a:	89 d8                	mov    %ebx,%eax
  800b4c:	83 c4 08             	add    $0x8,%esp
  800b4f:	5b                   	pop    %ebx
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
  800b57:	8b 75 08             	mov    0x8(%ebp),%esi
  800b5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5d:	89 f3                	mov    %esi,%ebx
  800b5f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b62:	89 f2                	mov    %esi,%edx
  800b64:	eb 0f                	jmp    800b75 <strncpy+0x23>
		*dst++ = *src;
  800b66:	83 c2 01             	add    $0x1,%edx
  800b69:	0f b6 01             	movzbl (%ecx),%eax
  800b6c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b6f:	80 39 01             	cmpb   $0x1,(%ecx)
  800b72:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800b75:	39 da                	cmp    %ebx,%edx
  800b77:	75 ed                	jne    800b66 <strncpy+0x14>
	}
	return ret;
}
  800b79:	89 f0                	mov    %esi,%eax
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	8b 75 08             	mov    0x8(%ebp),%esi
  800b87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b8d:	89 f0                	mov    %esi,%eax
  800b8f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b93:	85 c9                	test   %ecx,%ecx
  800b95:	75 0b                	jne    800ba2 <strlcpy+0x23>
  800b97:	eb 1d                	jmp    800bb6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b99:	83 c0 01             	add    $0x1,%eax
  800b9c:	83 c2 01             	add    $0x1,%edx
  800b9f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800ba2:	39 d8                	cmp    %ebx,%eax
  800ba4:	74 0b                	je     800bb1 <strlcpy+0x32>
  800ba6:	0f b6 0a             	movzbl (%edx),%ecx
  800ba9:	84 c9                	test   %cl,%cl
  800bab:	75 ec                	jne    800b99 <strlcpy+0x1a>
  800bad:	89 c2                	mov    %eax,%edx
  800baf:	eb 02                	jmp    800bb3 <strlcpy+0x34>
  800bb1:	89 c2                	mov    %eax,%edx
		*dst = '\0';
  800bb3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800bb6:	29 f0                	sub    %esi,%eax
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bc5:	eb 06                	jmp    800bcd <strcmp+0x11>
		p++, q++;
  800bc7:	83 c1 01             	add    $0x1,%ecx
  800bca:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800bcd:	0f b6 01             	movzbl (%ecx),%eax
  800bd0:	84 c0                	test   %al,%al
  800bd2:	74 04                	je     800bd8 <strcmp+0x1c>
  800bd4:	3a 02                	cmp    (%edx),%al
  800bd6:	74 ef                	je     800bc7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bd8:	0f b6 c0             	movzbl %al,%eax
  800bdb:	0f b6 12             	movzbl (%edx),%edx
  800bde:	29 d0                	sub    %edx,%eax
}
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	53                   	push   %ebx
  800be6:	8b 45 08             	mov    0x8(%ebp),%eax
  800be9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bec:	89 c3                	mov    %eax,%ebx
  800bee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800bf1:	eb 06                	jmp    800bf9 <strncmp+0x17>
		n--, p++, q++;
  800bf3:	83 c0 01             	add    $0x1,%eax
  800bf6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800bf9:	39 d8                	cmp    %ebx,%eax
  800bfb:	74 15                	je     800c12 <strncmp+0x30>
  800bfd:	0f b6 08             	movzbl (%eax),%ecx
  800c00:	84 c9                	test   %cl,%cl
  800c02:	74 04                	je     800c08 <strncmp+0x26>
  800c04:	3a 0a                	cmp    (%edx),%cl
  800c06:	74 eb                	je     800bf3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c08:	0f b6 00             	movzbl (%eax),%eax
  800c0b:	0f b6 12             	movzbl (%edx),%edx
  800c0e:	29 d0                	sub    %edx,%eax
  800c10:	eb 05                	jmp    800c17 <strncmp+0x35>
		return 0;
  800c12:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c17:	5b                   	pop    %ebx
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c20:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c24:	eb 07                	jmp    800c2d <strchr+0x13>
		if (*s == c)
  800c26:	38 ca                	cmp    %cl,%dl
  800c28:	74 0f                	je     800c39 <strchr+0x1f>
	for (; *s; s++)
  800c2a:	83 c0 01             	add    $0x1,%eax
  800c2d:	0f b6 10             	movzbl (%eax),%edx
  800c30:	84 d2                	test   %dl,%dl
  800c32:	75 f2                	jne    800c26 <strchr+0xc>
			return (char *) s;
	return 0;
  800c34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c45:	eb 07                	jmp    800c4e <strfind+0x13>
		if (*s == c)
  800c47:	38 ca                	cmp    %cl,%dl
  800c49:	74 0a                	je     800c55 <strfind+0x1a>
	for (; *s; s++)
  800c4b:	83 c0 01             	add    $0x1,%eax
  800c4e:	0f b6 10             	movzbl (%eax),%edx
  800c51:	84 d2                	test   %dl,%dl
  800c53:	75 f2                	jne    800c47 <strfind+0xc>
			break;
	return (char *) s;
}
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c60:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c63:	85 c9                	test   %ecx,%ecx
  800c65:	74 36                	je     800c9d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c67:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c6d:	75 28                	jne    800c97 <memset+0x40>
  800c6f:	f6 c1 03             	test   $0x3,%cl
  800c72:	75 23                	jne    800c97 <memset+0x40>
		c &= 0xFF;
  800c74:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c78:	89 d3                	mov    %edx,%ebx
  800c7a:	c1 e3 08             	shl    $0x8,%ebx
  800c7d:	89 d6                	mov    %edx,%esi
  800c7f:	c1 e6 18             	shl    $0x18,%esi
  800c82:	89 d0                	mov    %edx,%eax
  800c84:	c1 e0 10             	shl    $0x10,%eax
  800c87:	09 f0                	or     %esi,%eax
  800c89:	09 c2                	or     %eax,%edx
  800c8b:	89 d0                	mov    %edx,%eax
  800c8d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c8f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c92:	fc                   	cld    
  800c93:	f3 ab                	rep stos %eax,%es:(%edi)
  800c95:	eb 06                	jmp    800c9d <memset+0x46>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9a:	fc                   	cld    
  800c9b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c9d:	89 f8                	mov    %edi,%eax
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800caf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cb2:	39 c6                	cmp    %eax,%esi
  800cb4:	73 35                	jae    800ceb <memmove+0x47>
  800cb6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cb9:	39 d0                	cmp    %edx,%eax
  800cbb:	73 2e                	jae    800ceb <memmove+0x47>
		s += n;
		d += n;
  800cbd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800cc0:	89 d6                	mov    %edx,%esi
  800cc2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cc4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cca:	75 13                	jne    800cdf <memmove+0x3b>
  800ccc:	f6 c1 03             	test   $0x3,%cl
  800ccf:	75 0e                	jne    800cdf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cd1:	83 ef 04             	sub    $0x4,%edi
  800cd4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cd7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800cda:	fd                   	std    
  800cdb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cdd:	eb 09                	jmp    800ce8 <memmove+0x44>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cdf:	83 ef 01             	sub    $0x1,%edi
  800ce2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ce5:	fd                   	std    
  800ce6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ce8:	fc                   	cld    
  800ce9:	eb 1d                	jmp    800d08 <memmove+0x64>
  800ceb:	89 f2                	mov    %esi,%edx
  800ced:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cef:	f6 c2 03             	test   $0x3,%dl
  800cf2:	75 0f                	jne    800d03 <memmove+0x5f>
  800cf4:	f6 c1 03             	test   $0x3,%cl
  800cf7:	75 0a                	jne    800d03 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800cf9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800cfc:	89 c7                	mov    %eax,%edi
  800cfe:	fc                   	cld    
  800cff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d01:	eb 05                	jmp    800d08 <memmove+0x64>
		else
			asm volatile("cld; rep movsb\n"
  800d03:	89 c7                	mov    %eax,%edi
  800d05:	fc                   	cld    
  800d06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    

00800d0c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d12:	8b 45 10             	mov    0x10(%ebp),%eax
  800d15:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d20:	8b 45 08             	mov    0x8(%ebp),%eax
  800d23:	89 04 24             	mov    %eax,(%esp)
  800d26:	e8 79 ff ff ff       	call   800ca4 <memmove>
}
  800d2b:	c9                   	leave  
  800d2c:	c3                   	ret    

00800d2d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d38:	89 d6                	mov    %edx,%esi
  800d3a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d3d:	eb 1a                	jmp    800d59 <memcmp+0x2c>
		if (*s1 != *s2)
  800d3f:	0f b6 02             	movzbl (%edx),%eax
  800d42:	0f b6 19             	movzbl (%ecx),%ebx
  800d45:	38 d8                	cmp    %bl,%al
  800d47:	74 0a                	je     800d53 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800d49:	0f b6 c0             	movzbl %al,%eax
  800d4c:	0f b6 db             	movzbl %bl,%ebx
  800d4f:	29 d8                	sub    %ebx,%eax
  800d51:	eb 0f                	jmp    800d62 <memcmp+0x35>
		s1++, s2++;
  800d53:	83 c2 01             	add    $0x1,%edx
  800d56:	83 c1 01             	add    $0x1,%ecx
	while (n-- > 0) {
  800d59:	39 f2                	cmp    %esi,%edx
  800d5b:	75 e2                	jne    800d3f <memcmp+0x12>
	}

	return 0;
  800d5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d6f:	89 c2                	mov    %eax,%edx
  800d71:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d74:	eb 07                	jmp    800d7d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d76:	38 08                	cmp    %cl,(%eax)
  800d78:	74 07                	je     800d81 <memfind+0x1b>
	for (; s < ends; s++)
  800d7a:	83 c0 01             	add    $0x1,%eax
  800d7d:	39 d0                	cmp    %edx,%eax
  800d7f:	72 f5                	jb     800d76 <memfind+0x10>
			break;
	return (void *) s;
}
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d8f:	eb 03                	jmp    800d94 <strtol+0x11>
		s++;
  800d91:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800d94:	0f b6 0a             	movzbl (%edx),%ecx
  800d97:	80 f9 09             	cmp    $0x9,%cl
  800d9a:	74 f5                	je     800d91 <strtol+0xe>
  800d9c:	80 f9 20             	cmp    $0x20,%cl
  800d9f:	74 f0                	je     800d91 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800da1:	80 f9 2b             	cmp    $0x2b,%cl
  800da4:	75 0a                	jne    800db0 <strtol+0x2d>
		s++;
  800da6:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800da9:	bf 00 00 00 00       	mov    $0x0,%edi
  800dae:	eb 11                	jmp    800dc1 <strtol+0x3e>
  800db0:	bf 00 00 00 00       	mov    $0x0,%edi
	else if (*s == '-')
  800db5:	80 f9 2d             	cmp    $0x2d,%cl
  800db8:	75 07                	jne    800dc1 <strtol+0x3e>
		s++, neg = 1;
  800dba:	8d 52 01             	lea    0x1(%edx),%edx
  800dbd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dc1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800dc6:	75 15                	jne    800ddd <strtol+0x5a>
  800dc8:	80 3a 30             	cmpb   $0x30,(%edx)
  800dcb:	75 10                	jne    800ddd <strtol+0x5a>
  800dcd:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800dd1:	75 0a                	jne    800ddd <strtol+0x5a>
		s += 2, base = 16;
  800dd3:	83 c2 02             	add    $0x2,%edx
  800dd6:	b8 10 00 00 00       	mov    $0x10,%eax
  800ddb:	eb 10                	jmp    800ded <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800ddd:	85 c0                	test   %eax,%eax
  800ddf:	75 0c                	jne    800ded <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800de1:	b0 0a                	mov    $0xa,%al
	else if (base == 0 && s[0] == '0')
  800de3:	80 3a 30             	cmpb   $0x30,(%edx)
  800de6:	75 05                	jne    800ded <strtol+0x6a>
		s++, base = 8;
  800de8:	83 c2 01             	add    $0x1,%edx
  800deb:	b0 08                	mov    $0x8,%al
		base = 10;
  800ded:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800df5:	0f b6 0a             	movzbl (%edx),%ecx
  800df8:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800dfb:	89 f0                	mov    %esi,%eax
  800dfd:	3c 09                	cmp    $0x9,%al
  800dff:	77 08                	ja     800e09 <strtol+0x86>
			dig = *s - '0';
  800e01:	0f be c9             	movsbl %cl,%ecx
  800e04:	83 e9 30             	sub    $0x30,%ecx
  800e07:	eb 20                	jmp    800e29 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800e09:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800e0c:	89 f0                	mov    %esi,%eax
  800e0e:	3c 19                	cmp    $0x19,%al
  800e10:	77 08                	ja     800e1a <strtol+0x97>
			dig = *s - 'a' + 10;
  800e12:	0f be c9             	movsbl %cl,%ecx
  800e15:	83 e9 57             	sub    $0x57,%ecx
  800e18:	eb 0f                	jmp    800e29 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800e1a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800e1d:	89 f0                	mov    %esi,%eax
  800e1f:	3c 19                	cmp    $0x19,%al
  800e21:	77 16                	ja     800e39 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800e23:	0f be c9             	movsbl %cl,%ecx
  800e26:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e29:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800e2c:	7d 0f                	jge    800e3d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800e2e:	83 c2 01             	add    $0x1,%edx
  800e31:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800e35:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800e37:	eb bc                	jmp    800df5 <strtol+0x72>
  800e39:	89 d8                	mov    %ebx,%eax
  800e3b:	eb 02                	jmp    800e3f <strtol+0xbc>
  800e3d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800e3f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e43:	74 05                	je     800e4a <strtol+0xc7>
		*endptr = (char *) s;
  800e45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e48:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800e4a:	f7 d8                	neg    %eax
  800e4c:	85 ff                	test   %edi,%edi
  800e4e:	0f 44 c3             	cmove  %ebx,%eax
}
  800e51:	5b                   	pop    %ebx
  800e52:	5e                   	pop    %esi
  800e53:	5f                   	pop    %edi
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    
  800e56:	66 90                	xchg   %ax,%ax
  800e58:	66 90                	xchg   %ax,%ax
  800e5a:	66 90                	xchg   %ax,%ax
  800e5c:	66 90                	xchg   %ax,%ax
  800e5e:	66 90                	xchg   %ax,%ax

00800e60 <__udivdi3>:
  800e60:	55                   	push   %ebp
  800e61:	57                   	push   %edi
  800e62:	56                   	push   %esi
  800e63:	83 ec 0c             	sub    $0xc,%esp
  800e66:	8b 44 24 28          	mov    0x28(%esp),%eax
  800e6a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800e6e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800e72:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800e76:	85 c0                	test   %eax,%eax
  800e78:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e7c:	89 ea                	mov    %ebp,%edx
  800e7e:	89 0c 24             	mov    %ecx,(%esp)
  800e81:	75 2d                	jne    800eb0 <__udivdi3+0x50>
  800e83:	39 e9                	cmp    %ebp,%ecx
  800e85:	77 61                	ja     800ee8 <__udivdi3+0x88>
  800e87:	85 c9                	test   %ecx,%ecx
  800e89:	89 ce                	mov    %ecx,%esi
  800e8b:	75 0b                	jne    800e98 <__udivdi3+0x38>
  800e8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800e92:	31 d2                	xor    %edx,%edx
  800e94:	f7 f1                	div    %ecx
  800e96:	89 c6                	mov    %eax,%esi
  800e98:	31 d2                	xor    %edx,%edx
  800e9a:	89 e8                	mov    %ebp,%eax
  800e9c:	f7 f6                	div    %esi
  800e9e:	89 c5                	mov    %eax,%ebp
  800ea0:	89 f8                	mov    %edi,%eax
  800ea2:	f7 f6                	div    %esi
  800ea4:	89 ea                	mov    %ebp,%edx
  800ea6:	83 c4 0c             	add    $0xc,%esp
  800ea9:	5e                   	pop    %esi
  800eaa:	5f                   	pop    %edi
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    
  800ead:	8d 76 00             	lea    0x0(%esi),%esi
  800eb0:	39 e8                	cmp    %ebp,%eax
  800eb2:	77 24                	ja     800ed8 <__udivdi3+0x78>
  800eb4:	0f bd e8             	bsr    %eax,%ebp
  800eb7:	83 f5 1f             	xor    $0x1f,%ebp
  800eba:	75 3c                	jne    800ef8 <__udivdi3+0x98>
  800ebc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ec0:	39 34 24             	cmp    %esi,(%esp)
  800ec3:	0f 86 9f 00 00 00    	jbe    800f68 <__udivdi3+0x108>
  800ec9:	39 d0                	cmp    %edx,%eax
  800ecb:	0f 82 97 00 00 00    	jb     800f68 <__udivdi3+0x108>
  800ed1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed8:	31 d2                	xor    %edx,%edx
  800eda:	31 c0                	xor    %eax,%eax
  800edc:	83 c4 0c             	add    $0xc,%esp
  800edf:	5e                   	pop    %esi
  800ee0:	5f                   	pop    %edi
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    
  800ee3:	90                   	nop
  800ee4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ee8:	89 f8                	mov    %edi,%eax
  800eea:	f7 f1                	div    %ecx
  800eec:	31 d2                	xor    %edx,%edx
  800eee:	83 c4 0c             	add    $0xc,%esp
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    
  800ef5:	8d 76 00             	lea    0x0(%esi),%esi
  800ef8:	89 e9                	mov    %ebp,%ecx
  800efa:	8b 3c 24             	mov    (%esp),%edi
  800efd:	d3 e0                	shl    %cl,%eax
  800eff:	89 c6                	mov    %eax,%esi
  800f01:	b8 20 00 00 00       	mov    $0x20,%eax
  800f06:	29 e8                	sub    %ebp,%eax
  800f08:	89 c1                	mov    %eax,%ecx
  800f0a:	d3 ef                	shr    %cl,%edi
  800f0c:	89 e9                	mov    %ebp,%ecx
  800f0e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f12:	8b 3c 24             	mov    (%esp),%edi
  800f15:	09 74 24 08          	or     %esi,0x8(%esp)
  800f19:	89 d6                	mov    %edx,%esi
  800f1b:	d3 e7                	shl    %cl,%edi
  800f1d:	89 c1                	mov    %eax,%ecx
  800f1f:	89 3c 24             	mov    %edi,(%esp)
  800f22:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f26:	d3 ee                	shr    %cl,%esi
  800f28:	89 e9                	mov    %ebp,%ecx
  800f2a:	d3 e2                	shl    %cl,%edx
  800f2c:	89 c1                	mov    %eax,%ecx
  800f2e:	d3 ef                	shr    %cl,%edi
  800f30:	09 d7                	or     %edx,%edi
  800f32:	89 f2                	mov    %esi,%edx
  800f34:	89 f8                	mov    %edi,%eax
  800f36:	f7 74 24 08          	divl   0x8(%esp)
  800f3a:	89 d6                	mov    %edx,%esi
  800f3c:	89 c7                	mov    %eax,%edi
  800f3e:	f7 24 24             	mull   (%esp)
  800f41:	39 d6                	cmp    %edx,%esi
  800f43:	89 14 24             	mov    %edx,(%esp)
  800f46:	72 30                	jb     800f78 <__udivdi3+0x118>
  800f48:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f4c:	89 e9                	mov    %ebp,%ecx
  800f4e:	d3 e2                	shl    %cl,%edx
  800f50:	39 c2                	cmp    %eax,%edx
  800f52:	73 05                	jae    800f59 <__udivdi3+0xf9>
  800f54:	3b 34 24             	cmp    (%esp),%esi
  800f57:	74 1f                	je     800f78 <__udivdi3+0x118>
  800f59:	89 f8                	mov    %edi,%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	e9 7a ff ff ff       	jmp    800edc <__udivdi3+0x7c>
  800f62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f68:	31 d2                	xor    %edx,%edx
  800f6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6f:	e9 68 ff ff ff       	jmp    800edc <__udivdi3+0x7c>
  800f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f78:	8d 47 ff             	lea    -0x1(%edi),%eax
  800f7b:	31 d2                	xor    %edx,%edx
  800f7d:	83 c4 0c             	add    $0xc,%esp
  800f80:	5e                   	pop    %esi
  800f81:	5f                   	pop    %edi
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    
  800f84:	66 90                	xchg   %ax,%ax
  800f86:	66 90                	xchg   %ax,%ax
  800f88:	66 90                	xchg   %ax,%ax
  800f8a:	66 90                	xchg   %ax,%ax
  800f8c:	66 90                	xchg   %ax,%ax
  800f8e:	66 90                	xchg   %ax,%ax

00800f90 <__umoddi3>:
  800f90:	55                   	push   %ebp
  800f91:	57                   	push   %edi
  800f92:	56                   	push   %esi
  800f93:	83 ec 14             	sub    $0x14,%esp
  800f96:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f9a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f9e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800fa2:	89 c7                	mov    %eax,%edi
  800fa4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa8:	8b 44 24 30          	mov    0x30(%esp),%eax
  800fac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800fb0:	89 34 24             	mov    %esi,(%esp)
  800fb3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	89 c2                	mov    %eax,%edx
  800fbb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fbf:	75 17                	jne    800fd8 <__umoddi3+0x48>
  800fc1:	39 fe                	cmp    %edi,%esi
  800fc3:	76 4b                	jbe    801010 <__umoddi3+0x80>
  800fc5:	89 c8                	mov    %ecx,%eax
  800fc7:	89 fa                	mov    %edi,%edx
  800fc9:	f7 f6                	div    %esi
  800fcb:	89 d0                	mov    %edx,%eax
  800fcd:	31 d2                	xor    %edx,%edx
  800fcf:	83 c4 14             	add    $0x14,%esp
  800fd2:	5e                   	pop    %esi
  800fd3:	5f                   	pop    %edi
  800fd4:	5d                   	pop    %ebp
  800fd5:	c3                   	ret    
  800fd6:	66 90                	xchg   %ax,%ax
  800fd8:	39 f8                	cmp    %edi,%eax
  800fda:	77 54                	ja     801030 <__umoddi3+0xa0>
  800fdc:	0f bd e8             	bsr    %eax,%ebp
  800fdf:	83 f5 1f             	xor    $0x1f,%ebp
  800fe2:	75 5c                	jne    801040 <__umoddi3+0xb0>
  800fe4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fe8:	39 3c 24             	cmp    %edi,(%esp)
  800feb:	0f 87 e7 00 00 00    	ja     8010d8 <__umoddi3+0x148>
  800ff1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ff5:	29 f1                	sub    %esi,%ecx
  800ff7:	19 c7                	sbb    %eax,%edi
  800ff9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ffd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801001:	8b 44 24 08          	mov    0x8(%esp),%eax
  801005:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801009:	83 c4 14             	add    $0x14,%esp
  80100c:	5e                   	pop    %esi
  80100d:	5f                   	pop    %edi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    
  801010:	85 f6                	test   %esi,%esi
  801012:	89 f5                	mov    %esi,%ebp
  801014:	75 0b                	jne    801021 <__umoddi3+0x91>
  801016:	b8 01 00 00 00       	mov    $0x1,%eax
  80101b:	31 d2                	xor    %edx,%edx
  80101d:	f7 f6                	div    %esi
  80101f:	89 c5                	mov    %eax,%ebp
  801021:	8b 44 24 04          	mov    0x4(%esp),%eax
  801025:	31 d2                	xor    %edx,%edx
  801027:	f7 f5                	div    %ebp
  801029:	89 c8                	mov    %ecx,%eax
  80102b:	f7 f5                	div    %ebp
  80102d:	eb 9c                	jmp    800fcb <__umoddi3+0x3b>
  80102f:	90                   	nop
  801030:	89 c8                	mov    %ecx,%eax
  801032:	89 fa                	mov    %edi,%edx
  801034:	83 c4 14             	add    $0x14,%esp
  801037:	5e                   	pop    %esi
  801038:	5f                   	pop    %edi
  801039:	5d                   	pop    %ebp
  80103a:	c3                   	ret    
  80103b:	90                   	nop
  80103c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801040:	8b 04 24             	mov    (%esp),%eax
  801043:	be 20 00 00 00       	mov    $0x20,%esi
  801048:	89 e9                	mov    %ebp,%ecx
  80104a:	29 ee                	sub    %ebp,%esi
  80104c:	d3 e2                	shl    %cl,%edx
  80104e:	89 f1                	mov    %esi,%ecx
  801050:	d3 e8                	shr    %cl,%eax
  801052:	89 e9                	mov    %ebp,%ecx
  801054:	89 44 24 04          	mov    %eax,0x4(%esp)
  801058:	8b 04 24             	mov    (%esp),%eax
  80105b:	09 54 24 04          	or     %edx,0x4(%esp)
  80105f:	89 fa                	mov    %edi,%edx
  801061:	d3 e0                	shl    %cl,%eax
  801063:	89 f1                	mov    %esi,%ecx
  801065:	89 44 24 08          	mov    %eax,0x8(%esp)
  801069:	8b 44 24 10          	mov    0x10(%esp),%eax
  80106d:	d3 ea                	shr    %cl,%edx
  80106f:	89 e9                	mov    %ebp,%ecx
  801071:	d3 e7                	shl    %cl,%edi
  801073:	89 f1                	mov    %esi,%ecx
  801075:	d3 e8                	shr    %cl,%eax
  801077:	89 e9                	mov    %ebp,%ecx
  801079:	09 f8                	or     %edi,%eax
  80107b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80107f:	f7 74 24 04          	divl   0x4(%esp)
  801083:	d3 e7                	shl    %cl,%edi
  801085:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801089:	89 d7                	mov    %edx,%edi
  80108b:	f7 64 24 08          	mull   0x8(%esp)
  80108f:	39 d7                	cmp    %edx,%edi
  801091:	89 c1                	mov    %eax,%ecx
  801093:	89 14 24             	mov    %edx,(%esp)
  801096:	72 2c                	jb     8010c4 <__umoddi3+0x134>
  801098:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80109c:	72 22                	jb     8010c0 <__umoddi3+0x130>
  80109e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8010a2:	29 c8                	sub    %ecx,%eax
  8010a4:	19 d7                	sbb    %edx,%edi
  8010a6:	89 e9                	mov    %ebp,%ecx
  8010a8:	89 fa                	mov    %edi,%edx
  8010aa:	d3 e8                	shr    %cl,%eax
  8010ac:	89 f1                	mov    %esi,%ecx
  8010ae:	d3 e2                	shl    %cl,%edx
  8010b0:	89 e9                	mov    %ebp,%ecx
  8010b2:	d3 ef                	shr    %cl,%edi
  8010b4:	09 d0                	or     %edx,%eax
  8010b6:	89 fa                	mov    %edi,%edx
  8010b8:	83 c4 14             	add    $0x14,%esp
  8010bb:	5e                   	pop    %esi
  8010bc:	5f                   	pop    %edi
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    
  8010bf:	90                   	nop
  8010c0:	39 d7                	cmp    %edx,%edi
  8010c2:	75 da                	jne    80109e <__umoddi3+0x10e>
  8010c4:	8b 14 24             	mov    (%esp),%edx
  8010c7:	89 c1                	mov    %eax,%ecx
  8010c9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8010cd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8010d1:	eb cb                	jmp    80109e <__umoddi3+0x10e>
  8010d3:	90                   	nop
  8010d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010d8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8010dc:	0f 82 0f ff ff ff    	jb     800ff1 <__umoddi3+0x61>
  8010e2:	e9 1a ff ff ff       	jmp    801001 <__umoddi3+0x71>
