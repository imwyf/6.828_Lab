
obj/user/faultwritekernel:     file format elf32-i386


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
  800045:	57                   	push   %edi
  800046:	56                   	push   %esi
  800047:	53                   	push   %ebx
  800048:	83 ec 0c             	sub    $0xc,%esp
  80004b:	e8 4d 00 00 00       	call   80009d <__x86.get_pc_thunk.bx>
  800050:	81 c3 b0 1f 00 00    	add    $0x1fb0,%ebx
  800056:	8b 75 08             	mov    0x8(%ebp),%esi
  800059:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())]; // ENVX()得到id在Env[]数组中对应的下标
  80005c:	e8 f3 00 00 00       	call   800154 <sys_getenvid>
  800061:	25 ff 03 00 00       	and    $0x3ff,%eax
  800066:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800069:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  80006f:	c7 c2 44 20 80 00    	mov    $0x802044,%edx
  800075:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800077:	85 f6                	test   %esi,%esi
  800079:	7e 08                	jle    800083 <libmain+0x41>
		binaryname = argv[0];
  80007b:	8b 07                	mov    (%edi),%eax
  80007d:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800083:	83 ec 08             	sub    $0x8,%esp
  800086:	57                   	push   %edi
  800087:	56                   	push   %esi
  800088:	e8 a6 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008d:	e8 0f 00 00 00       	call   8000a1 <exit>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800098:	5b                   	pop    %ebx
  800099:	5e                   	pop    %esi
  80009a:	5f                   	pop    %edi
  80009b:	5d                   	pop    %ebp
  80009c:	c3                   	ret    

0080009d <__x86.get_pc_thunk.bx>:
  80009d:	8b 1c 24             	mov    (%esp),%ebx
  8000a0:	c3                   	ret    

008000a1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	53                   	push   %ebx
  8000a5:	83 ec 10             	sub    $0x10,%esp
  8000a8:	e8 f0 ff ff ff       	call   80009d <__x86.get_pc_thunk.bx>
  8000ad:	81 c3 53 1f 00 00    	add    $0x1f53,%ebx
	sys_env_destroy(0);
  8000b3:	6a 00                	push   $0x0
  8000b5:	e8 45 00 00 00       	call   8000ff <sys_env_destroy>
}
  8000ba:	83 c4 10             	add    $0x10,%esp
  8000bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c0:	c9                   	leave  
  8000c1:	c3                   	ret    

008000c2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	57                   	push   %edi
  8000c6:	56                   	push   %esi
  8000c7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d3:	89 c3                	mov    %eax,%ebx
  8000d5:	89 c7                	mov    %eax,%edi
  8000d7:	89 c6                	mov    %eax,%esi
  8000d9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000db:	5b                   	pop    %ebx
  8000dc:	5e                   	pop    %esi
  8000dd:	5f                   	pop    %edi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	57                   	push   %edi
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f0:	89 d1                	mov    %edx,%ecx
  8000f2:	89 d3                	mov    %edx,%ebx
  8000f4:	89 d7                	mov    %edx,%edi
  8000f6:	89 d6                	mov    %edx,%esi
  8000f8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	5f                   	pop    %edi
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	57                   	push   %edi
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
  800105:	83 ec 1c             	sub    $0x1c,%esp
  800108:	e8 ac 02 00 00       	call   8003b9 <__x86.get_pc_thunk.ax>
  80010d:	05 f3 1e 00 00       	add    $0x1ef3,%eax
  800112:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800115:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011a:	8b 55 08             	mov    0x8(%ebp),%edx
  80011d:	b8 03 00 00 00       	mov    $0x3,%eax
  800122:	89 cb                	mov    %ecx,%ebx
  800124:	89 cf                	mov    %ecx,%edi
  800126:	89 ce                	mov    %ecx,%esi
  800128:	cd 30                	int    $0x30
	if(check && ret > 0)
  80012a:	85 c0                	test   %eax,%eax
  80012c:	7f 08                	jg     800136 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	6a 03                	push   $0x3
  80013c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80013f:	8d 83 b6 f0 ff ff    	lea    -0xf4a(%ebx),%eax
  800145:	50                   	push   %eax
  800146:	6a 23                	push   $0x23
  800148:	8d 83 d3 f0 ff ff    	lea    -0xf2d(%ebx),%eax
  80014e:	50                   	push   %eax
  80014f:	e8 69 02 00 00       	call   8003bd <_panic>

00800154 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	57                   	push   %edi
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015a:	ba 00 00 00 00       	mov    $0x0,%edx
  80015f:	b8 02 00 00 00       	mov    $0x2,%eax
  800164:	89 d1                	mov    %edx,%ecx
  800166:	89 d3                	mov    %edx,%ebx
  800168:	89 d7                	mov    %edx,%edi
  80016a:	89 d6                	mov    %edx,%esi
  80016c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016e:	5b                   	pop    %ebx
  80016f:	5e                   	pop    %esi
  800170:	5f                   	pop    %edi
  800171:	5d                   	pop    %ebp
  800172:	c3                   	ret    

00800173 <sys_yield>:

void
sys_yield(void)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	57                   	push   %edi
  800177:	56                   	push   %esi
  800178:	53                   	push   %ebx
	asm volatile("int %1\n"
  800179:	ba 00 00 00 00       	mov    $0x0,%edx
  80017e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800183:	89 d1                	mov    %edx,%ecx
  800185:	89 d3                	mov    %edx,%ebx
  800187:	89 d7                	mov    %edx,%edi
  800189:	89 d6                	mov    %edx,%esi
  80018b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80018d:	5b                   	pop    %ebx
  80018e:	5e                   	pop    %esi
  80018f:	5f                   	pop    %edi
  800190:	5d                   	pop    %ebp
  800191:	c3                   	ret    

00800192 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800192:	55                   	push   %ebp
  800193:	89 e5                	mov    %esp,%ebp
  800195:	57                   	push   %edi
  800196:	56                   	push   %esi
  800197:	53                   	push   %ebx
  800198:	83 ec 1c             	sub    $0x1c,%esp
  80019b:	e8 19 02 00 00       	call   8003b9 <__x86.get_pc_thunk.ax>
  8001a0:	05 60 1e 00 00       	add    $0x1e60,%eax
  8001a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8001a8:	be 00 00 00 00       	mov    $0x0,%esi
  8001ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b3:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bb:	89 f7                	mov    %esi,%edi
  8001bd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001bf:	85 c0                	test   %eax,%eax
  8001c1:	7f 08                	jg     8001cb <sys_page_alloc+0x39>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c6:	5b                   	pop    %ebx
  8001c7:	5e                   	pop    %esi
  8001c8:	5f                   	pop    %edi
  8001c9:	5d                   	pop    %ebp
  8001ca:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cb:	83 ec 0c             	sub    $0xc,%esp
  8001ce:	50                   	push   %eax
  8001cf:	6a 04                	push   $0x4
  8001d1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8001d4:	8d 83 b6 f0 ff ff    	lea    -0xf4a(%ebx),%eax
  8001da:	50                   	push   %eax
  8001db:	6a 23                	push   $0x23
  8001dd:	8d 83 d3 f0 ff ff    	lea    -0xf2d(%ebx),%eax
  8001e3:	50                   	push   %eax
  8001e4:	e8 d4 01 00 00       	call   8003bd <_panic>

008001e9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	57                   	push   %edi
  8001ed:	56                   	push   %esi
  8001ee:	53                   	push   %ebx
  8001ef:	83 ec 1c             	sub    $0x1c,%esp
  8001f2:	e8 c2 01 00 00       	call   8003b9 <__x86.get_pc_thunk.ax>
  8001f7:	05 09 1e 00 00       	add    $0x1e09,%eax
  8001fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8001ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800205:	b8 05 00 00 00       	mov    $0x5,%eax
  80020a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80020d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800210:	8b 75 18             	mov    0x18(%ebp),%esi
  800213:	cd 30                	int    $0x30
	if(check && ret > 0)
  800215:	85 c0                	test   %eax,%eax
  800217:	7f 08                	jg     800221 <sys_page_map+0x38>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021c:	5b                   	pop    %ebx
  80021d:	5e                   	pop    %esi
  80021e:	5f                   	pop    %edi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800221:	83 ec 0c             	sub    $0xc,%esp
  800224:	50                   	push   %eax
  800225:	6a 05                	push   $0x5
  800227:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80022a:	8d 83 b6 f0 ff ff    	lea    -0xf4a(%ebx),%eax
  800230:	50                   	push   %eax
  800231:	6a 23                	push   $0x23
  800233:	8d 83 d3 f0 ff ff    	lea    -0xf2d(%ebx),%eax
  800239:	50                   	push   %eax
  80023a:	e8 7e 01 00 00       	call   8003bd <_panic>

0080023f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	57                   	push   %edi
  800243:	56                   	push   %esi
  800244:	53                   	push   %ebx
  800245:	83 ec 1c             	sub    $0x1c,%esp
  800248:	e8 6c 01 00 00       	call   8003b9 <__x86.get_pc_thunk.ax>
  80024d:	05 b3 1d 00 00       	add    $0x1db3,%eax
  800252:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800255:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025a:	8b 55 08             	mov    0x8(%ebp),%edx
  80025d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800260:	b8 06 00 00 00       	mov    $0x6,%eax
  800265:	89 df                	mov    %ebx,%edi
  800267:	89 de                	mov    %ebx,%esi
  800269:	cd 30                	int    $0x30
	if(check && ret > 0)
  80026b:	85 c0                	test   %eax,%eax
  80026d:	7f 08                	jg     800277 <sys_page_unmap+0x38>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80026f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	50                   	push   %eax
  80027b:	6a 06                	push   $0x6
  80027d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800280:	8d 83 b6 f0 ff ff    	lea    -0xf4a(%ebx),%eax
  800286:	50                   	push   %eax
  800287:	6a 23                	push   $0x23
  800289:	8d 83 d3 f0 ff ff    	lea    -0xf2d(%ebx),%eax
  80028f:	50                   	push   %eax
  800290:	e8 28 01 00 00       	call   8003bd <_panic>

00800295 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	57                   	push   %edi
  800299:	56                   	push   %esi
  80029a:	53                   	push   %ebx
  80029b:	83 ec 1c             	sub    $0x1c,%esp
  80029e:	e8 16 01 00 00       	call   8003b9 <__x86.get_pc_thunk.ax>
  8002a3:	05 5d 1d 00 00       	add    $0x1d5d,%eax
  8002a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8002ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b6:	b8 08 00 00 00       	mov    $0x8,%eax
  8002bb:	89 df                	mov    %ebx,%edi
  8002bd:	89 de                	mov    %ebx,%esi
  8002bf:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002c1:	85 c0                	test   %eax,%eax
  8002c3:	7f 08                	jg     8002cd <sys_env_set_status+0x38>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c8:	5b                   	pop    %ebx
  8002c9:	5e                   	pop    %esi
  8002ca:	5f                   	pop    %edi
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cd:	83 ec 0c             	sub    $0xc,%esp
  8002d0:	50                   	push   %eax
  8002d1:	6a 08                	push   $0x8
  8002d3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002d6:	8d 83 b6 f0 ff ff    	lea    -0xf4a(%ebx),%eax
  8002dc:	50                   	push   %eax
  8002dd:	6a 23                	push   $0x23
  8002df:	8d 83 d3 f0 ff ff    	lea    -0xf2d(%ebx),%eax
  8002e5:	50                   	push   %eax
  8002e6:	e8 d2 00 00 00       	call   8003bd <_panic>

008002eb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
  8002f1:	83 ec 1c             	sub    $0x1c,%esp
  8002f4:	e8 c0 00 00 00       	call   8003b9 <__x86.get_pc_thunk.ax>
  8002f9:	05 07 1d 00 00       	add    $0x1d07,%eax
  8002fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800301:	bb 00 00 00 00       	mov    $0x0,%ebx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030c:	b8 09 00 00 00       	mov    $0x9,%eax
  800311:	89 df                	mov    %ebx,%edi
  800313:	89 de                	mov    %ebx,%esi
  800315:	cd 30                	int    $0x30
	if(check && ret > 0)
  800317:	85 c0                	test   %eax,%eax
  800319:	7f 08                	jg     800323 <sys_env_set_pgfault_upcall+0x38>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80031b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80031e:	5b                   	pop    %ebx
  80031f:	5e                   	pop    %esi
  800320:	5f                   	pop    %edi
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800323:	83 ec 0c             	sub    $0xc,%esp
  800326:	50                   	push   %eax
  800327:	6a 09                	push   $0x9
  800329:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80032c:	8d 83 b6 f0 ff ff    	lea    -0xf4a(%ebx),%eax
  800332:	50                   	push   %eax
  800333:	6a 23                	push   $0x23
  800335:	8d 83 d3 f0 ff ff    	lea    -0xf2d(%ebx),%eax
  80033b:	50                   	push   %eax
  80033c:	e8 7c 00 00 00       	call   8003bd <_panic>

00800341 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800341:	55                   	push   %ebp
  800342:	89 e5                	mov    %esp,%ebp
  800344:	57                   	push   %edi
  800345:	56                   	push   %esi
  800346:	53                   	push   %ebx
	asm volatile("int %1\n"
  800347:	8b 55 08             	mov    0x8(%ebp),%edx
  80034a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80034d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800352:	be 00 00 00 00       	mov    $0x0,%esi
  800357:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80035a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80035d:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80035f:	5b                   	pop    %ebx
  800360:	5e                   	pop    %esi
  800361:	5f                   	pop    %edi
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	57                   	push   %edi
  800368:	56                   	push   %esi
  800369:	53                   	push   %ebx
  80036a:	83 ec 1c             	sub    $0x1c,%esp
  80036d:	e8 47 00 00 00       	call   8003b9 <__x86.get_pc_thunk.ax>
  800372:	05 8e 1c 00 00       	add    $0x1c8e,%eax
  800377:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80037a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037f:	8b 55 08             	mov    0x8(%ebp),%edx
  800382:	b8 0c 00 00 00       	mov    $0xc,%eax
  800387:	89 cb                	mov    %ecx,%ebx
  800389:	89 cf                	mov    %ecx,%edi
  80038b:	89 ce                	mov    %ecx,%esi
  80038d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80038f:	85 c0                	test   %eax,%eax
  800391:	7f 08                	jg     80039b <sys_ipc_recv+0x37>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800393:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800396:	5b                   	pop    %ebx
  800397:	5e                   	pop    %esi
  800398:	5f                   	pop    %edi
  800399:	5d                   	pop    %ebp
  80039a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80039b:	83 ec 0c             	sub    $0xc,%esp
  80039e:	50                   	push   %eax
  80039f:	6a 0c                	push   $0xc
  8003a1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8003a4:	8d 83 b6 f0 ff ff    	lea    -0xf4a(%ebx),%eax
  8003aa:	50                   	push   %eax
  8003ab:	6a 23                	push   $0x23
  8003ad:	8d 83 d3 f0 ff ff    	lea    -0xf2d(%ebx),%eax
  8003b3:	50                   	push   %eax
  8003b4:	e8 04 00 00 00       	call   8003bd <_panic>

008003b9 <__x86.get_pc_thunk.ax>:
  8003b9:	8b 04 24             	mov    (%esp),%eax
  8003bc:	c3                   	ret    

008003bd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	57                   	push   %edi
  8003c1:	56                   	push   %esi
  8003c2:	53                   	push   %ebx
  8003c3:	83 ec 0c             	sub    $0xc,%esp
  8003c6:	e8 d2 fc ff ff       	call   80009d <__x86.get_pc_thunk.bx>
  8003cb:	81 c3 35 1c 00 00    	add    $0x1c35,%ebx
	va_list ap;

	va_start(ap, fmt);
  8003d1:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003d4:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  8003da:	8b 38                	mov    (%eax),%edi
  8003dc:	e8 73 fd ff ff       	call   800154 <sys_getenvid>
  8003e1:	83 ec 0c             	sub    $0xc,%esp
  8003e4:	ff 75 0c             	pushl  0xc(%ebp)
  8003e7:	ff 75 08             	pushl  0x8(%ebp)
  8003ea:	57                   	push   %edi
  8003eb:	50                   	push   %eax
  8003ec:	8d 83 e4 f0 ff ff    	lea    -0xf1c(%ebx),%eax
  8003f2:	50                   	push   %eax
  8003f3:	e8 d1 00 00 00       	call   8004c9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003f8:	83 c4 18             	add    $0x18,%esp
  8003fb:	56                   	push   %esi
  8003fc:	ff 75 10             	pushl  0x10(%ebp)
  8003ff:	e8 63 00 00 00       	call   800467 <vcprintf>
	cprintf("\n");
  800404:	8d 83 08 f1 ff ff    	lea    -0xef8(%ebx),%eax
  80040a:	89 04 24             	mov    %eax,(%esp)
  80040d:	e8 b7 00 00 00       	call   8004c9 <cprintf>
  800412:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800415:	cc                   	int3   
  800416:	eb fd                	jmp    800415 <_panic+0x58>

00800418 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800418:	55                   	push   %ebp
  800419:	89 e5                	mov    %esp,%ebp
  80041b:	56                   	push   %esi
  80041c:	53                   	push   %ebx
  80041d:	e8 7b fc ff ff       	call   80009d <__x86.get_pc_thunk.bx>
  800422:	81 c3 de 1b 00 00    	add    $0x1bde,%ebx
  800428:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  80042b:	8b 16                	mov    (%esi),%edx
  80042d:	8d 42 01             	lea    0x1(%edx),%eax
  800430:	89 06                	mov    %eax,(%esi)
  800432:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800435:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800439:	3d ff 00 00 00       	cmp    $0xff,%eax
  80043e:	74 0b                	je     80044b <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800440:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800444:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800447:	5b                   	pop    %ebx
  800448:	5e                   	pop    %esi
  800449:	5d                   	pop    %ebp
  80044a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80044b:	83 ec 08             	sub    $0x8,%esp
  80044e:	68 ff 00 00 00       	push   $0xff
  800453:	8d 46 08             	lea    0x8(%esi),%eax
  800456:	50                   	push   %eax
  800457:	e8 66 fc ff ff       	call   8000c2 <sys_cputs>
		b->idx = 0;
  80045c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800462:	83 c4 10             	add    $0x10,%esp
  800465:	eb d9                	jmp    800440 <putch+0x28>

00800467 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800467:	55                   	push   %ebp
  800468:	89 e5                	mov    %esp,%ebp
  80046a:	53                   	push   %ebx
  80046b:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800471:	e8 27 fc ff ff       	call   80009d <__x86.get_pc_thunk.bx>
  800476:	81 c3 8a 1b 00 00    	add    $0x1b8a,%ebx
	struct printbuf b;

	b.idx = 0;
  80047c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800483:	00 00 00 
	b.cnt = 0;
  800486:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80048d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800490:	ff 75 0c             	pushl  0xc(%ebp)
  800493:	ff 75 08             	pushl  0x8(%ebp)
  800496:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80049c:	50                   	push   %eax
  80049d:	8d 83 18 e4 ff ff    	lea    -0x1be8(%ebx),%eax
  8004a3:	50                   	push   %eax
  8004a4:	e8 38 01 00 00       	call   8005e1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004a9:	83 c4 08             	add    $0x8,%esp
  8004ac:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004b2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004b8:	50                   	push   %eax
  8004b9:	e8 04 fc ff ff       	call   8000c2 <sys_cputs>

	return b.cnt;
}
  8004be:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004c7:	c9                   	leave  
  8004c8:	c3                   	ret    

008004c9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004c9:	55                   	push   %ebp
  8004ca:	89 e5                	mov    %esp,%ebp
  8004cc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004cf:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004d2:	50                   	push   %eax
  8004d3:	ff 75 08             	pushl  0x8(%ebp)
  8004d6:	e8 8c ff ff ff       	call   800467 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004db:	c9                   	leave  
  8004dc:	c3                   	ret    

008004dd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  8004dd:	55                   	push   %ebp
  8004de:	89 e5                	mov    %esp,%ebp
  8004e0:	57                   	push   %edi
  8004e1:	56                   	push   %esi
  8004e2:	53                   	push   %ebx
  8004e3:	83 ec 2c             	sub    $0x2c,%esp
  8004e6:	e8 02 06 00 00       	call   800aed <__x86.get_pc_thunk.cx>
  8004eb:	81 c1 15 1b 00 00    	add    $0x1b15,%ecx
  8004f1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8004f4:	89 c7                	mov    %eax,%edi
  8004f6:	89 d6                	mov    %edx,%esi
  8004f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004fe:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800501:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  800504:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800507:	bb 00 00 00 00       	mov    $0x0,%ebx
  80050c:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80050f:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800512:	39 d3                	cmp    %edx,%ebx
  800514:	72 09                	jb     80051f <printnum+0x42>
  800516:	39 45 10             	cmp    %eax,0x10(%ebp)
  800519:	0f 87 83 00 00 00    	ja     8005a2 <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80051f:	83 ec 0c             	sub    $0xc,%esp
  800522:	ff 75 18             	pushl  0x18(%ebp)
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80052b:	53                   	push   %ebx
  80052c:	ff 75 10             	pushl  0x10(%ebp)
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	ff 75 dc             	pushl  -0x24(%ebp)
  800535:	ff 75 d8             	pushl  -0x28(%ebp)
  800538:	ff 75 d4             	pushl  -0x2c(%ebp)
  80053b:	ff 75 d0             	pushl  -0x30(%ebp)
  80053e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800541:	e8 2a 09 00 00       	call   800e70 <__udivdi3>
  800546:	83 c4 18             	add    $0x18,%esp
  800549:	52                   	push   %edx
  80054a:	50                   	push   %eax
  80054b:	89 f2                	mov    %esi,%edx
  80054d:	89 f8                	mov    %edi,%eax
  80054f:	e8 89 ff ff ff       	call   8004dd <printnum>
  800554:	83 c4 20             	add    $0x20,%esp
  800557:	eb 13                	jmp    80056c <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800559:	83 ec 08             	sub    $0x8,%esp
  80055c:	56                   	push   %esi
  80055d:	ff 75 18             	pushl  0x18(%ebp)
  800560:	ff d7                	call   *%edi
  800562:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800565:	83 eb 01             	sub    $0x1,%ebx
  800568:	85 db                	test   %ebx,%ebx
  80056a:	7f ed                	jg     800559 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	56                   	push   %esi
  800570:	83 ec 04             	sub    $0x4,%esp
  800573:	ff 75 dc             	pushl  -0x24(%ebp)
  800576:	ff 75 d8             	pushl  -0x28(%ebp)
  800579:	ff 75 d4             	pushl  -0x2c(%ebp)
  80057c:	ff 75 d0             	pushl  -0x30(%ebp)
  80057f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800582:	89 f3                	mov    %esi,%ebx
  800584:	e8 07 0a 00 00       	call   800f90 <__umoddi3>
  800589:	83 c4 14             	add    $0x14,%esp
  80058c:	0f be 84 06 0a f1 ff 	movsbl -0xef6(%esi,%eax,1),%eax
  800593:	ff 
  800594:	50                   	push   %eax
  800595:	ff d7                	call   *%edi
}
  800597:	83 c4 10             	add    $0x10,%esp
  80059a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80059d:	5b                   	pop    %ebx
  80059e:	5e                   	pop    %esi
  80059f:	5f                   	pop    %edi
  8005a0:	5d                   	pop    %ebp
  8005a1:	c3                   	ret    
  8005a2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005a5:	eb be                	jmp    800565 <printnum+0x88>

008005a7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005a7:	55                   	push   %ebp
  8005a8:	89 e5                	mov    %esp,%ebp
  8005aa:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005ad:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005b1:	8b 10                	mov    (%eax),%edx
  8005b3:	3b 50 04             	cmp    0x4(%eax),%edx
  8005b6:	73 0a                	jae    8005c2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005b8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005bb:	89 08                	mov    %ecx,(%eax)
  8005bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c0:	88 02                	mov    %al,(%edx)
}
  8005c2:	5d                   	pop    %ebp
  8005c3:	c3                   	ret    

008005c4 <printfmt>:
{
  8005c4:	55                   	push   %ebp
  8005c5:	89 e5                	mov    %esp,%ebp
  8005c7:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8005ca:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005cd:	50                   	push   %eax
  8005ce:	ff 75 10             	pushl  0x10(%ebp)
  8005d1:	ff 75 0c             	pushl  0xc(%ebp)
  8005d4:	ff 75 08             	pushl  0x8(%ebp)
  8005d7:	e8 05 00 00 00       	call   8005e1 <vprintfmt>
}
  8005dc:	83 c4 10             	add    $0x10,%esp
  8005df:	c9                   	leave  
  8005e0:	c3                   	ret    

008005e1 <vprintfmt>:
{
  8005e1:	55                   	push   %ebp
  8005e2:	89 e5                	mov    %esp,%ebp
  8005e4:	57                   	push   %edi
  8005e5:	56                   	push   %esi
  8005e6:	53                   	push   %ebx
  8005e7:	83 ec 2c             	sub    $0x2c,%esp
  8005ea:	e8 ae fa ff ff       	call   80009d <__x86.get_pc_thunk.bx>
  8005ef:	81 c3 11 1a 00 00    	add    $0x1a11,%ebx
  8005f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005f8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005fb:	e9 c3 03 00 00       	jmp    8009c3 <.L35+0x48>
		padc = ' ';
  800600:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800604:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80060b:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  800612:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800619:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800621:	8d 47 01             	lea    0x1(%edi),%eax
  800624:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800627:	0f b6 17             	movzbl (%edi),%edx
  80062a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80062d:	3c 55                	cmp    $0x55,%al
  80062f:	0f 87 16 04 00 00    	ja     800a4b <.L22>
  800635:	0f b6 c0             	movzbl %al,%eax
  800638:	89 d9                	mov    %ebx,%ecx
  80063a:	03 8c 83 c4 f1 ff ff 	add    -0xe3c(%ebx,%eax,4),%ecx
  800641:	ff e1                	jmp    *%ecx

00800643 <.L69>:
  800643:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800646:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80064a:	eb d5                	jmp    800621 <vprintfmt+0x40>

0080064c <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80064c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80064f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800653:	eb cc                	jmp    800621 <vprintfmt+0x40>

00800655 <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800655:	0f b6 d2             	movzbl %dl,%edx
  800658:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
  80065b:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800660:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800663:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800667:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80066a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80066d:	83 f9 09             	cmp    $0x9,%ecx
  800670:	77 55                	ja     8006c7 <.L23+0xf>
			for (precision = 0;; ++fmt)
  800672:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800675:	eb e9                	jmp    800660 <.L29+0xb>

00800677 <.L26>:
			precision = va_arg(ap, int);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8b 00                	mov    (%eax),%eax
  80067c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8d 40 04             	lea    0x4(%eax),%eax
  800685:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800688:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80068b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80068f:	79 90                	jns    800621 <vprintfmt+0x40>
				width = precision, precision = -1;
  800691:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800694:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800697:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80069e:	eb 81                	jmp    800621 <vprintfmt+0x40>

008006a0 <.L27>:
  8006a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006a3:	85 c0                	test   %eax,%eax
  8006a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8006aa:	0f 49 d0             	cmovns %eax,%edx
  8006ad:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b3:	e9 69 ff ff ff       	jmp    800621 <vprintfmt+0x40>

008006b8 <.L23>:
  8006b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8006bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006c2:	e9 5a ff ff ff       	jmp    800621 <vprintfmt+0x40>
  8006c7:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006ca:	eb bf                	jmp    80068b <.L26+0x14>

008006cc <.L33>:
			lflag++;
  8006cc:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8006d3:	e9 49 ff ff ff       	jmp    800621 <vprintfmt+0x40>

008006d8 <.L30>:
			putch(va_arg(ap, int), putdat);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8d 78 04             	lea    0x4(%eax),%edi
  8006de:	83 ec 08             	sub    $0x8,%esp
  8006e1:	56                   	push   %esi
  8006e2:	ff 30                	pushl  (%eax)
  8006e4:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006e7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8006ea:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8006ed:	e9 ce 02 00 00       	jmp    8009c0 <.L35+0x45>

008006f2 <.L32>:
			err = va_arg(ap, int);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8d 78 04             	lea    0x4(%eax),%edi
  8006f8:	8b 00                	mov    (%eax),%eax
  8006fa:	99                   	cltd   
  8006fb:	31 d0                	xor    %edx,%eax
  8006fd:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006ff:	83 f8 08             	cmp    $0x8,%eax
  800702:	7f 27                	jg     80072b <.L32+0x39>
  800704:	8b 94 83 20 00 00 00 	mov    0x20(%ebx,%eax,4),%edx
  80070b:	85 d2                	test   %edx,%edx
  80070d:	74 1c                	je     80072b <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  80070f:	52                   	push   %edx
  800710:	8d 83 2b f1 ff ff    	lea    -0xed5(%ebx),%eax
  800716:	50                   	push   %eax
  800717:	56                   	push   %esi
  800718:	ff 75 08             	pushl  0x8(%ebp)
  80071b:	e8 a4 fe ff ff       	call   8005c4 <printfmt>
  800720:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800723:	89 7d 14             	mov    %edi,0x14(%ebp)
  800726:	e9 95 02 00 00       	jmp    8009c0 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  80072b:	50                   	push   %eax
  80072c:	8d 83 22 f1 ff ff    	lea    -0xede(%ebx),%eax
  800732:	50                   	push   %eax
  800733:	56                   	push   %esi
  800734:	ff 75 08             	pushl  0x8(%ebp)
  800737:	e8 88 fe ff ff       	call   8005c4 <printfmt>
  80073c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80073f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800742:	e9 79 02 00 00       	jmp    8009c0 <.L35+0x45>

00800747 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	83 c0 04             	add    $0x4,%eax
  80074d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800750:	8b 45 14             	mov    0x14(%ebp),%eax
  800753:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800755:	85 ff                	test   %edi,%edi
  800757:	8d 83 1b f1 ff ff    	lea    -0xee5(%ebx),%eax
  80075d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800760:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800764:	0f 8e b5 00 00 00    	jle    80081f <.L36+0xd8>
  80076a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80076e:	75 08                	jne    800778 <.L36+0x31>
  800770:	89 75 0c             	mov    %esi,0xc(%ebp)
  800773:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800776:	eb 6d                	jmp    8007e5 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800778:	83 ec 08             	sub    $0x8,%esp
  80077b:	ff 75 cc             	pushl  -0x34(%ebp)
  80077e:	57                   	push   %edi
  80077f:	e8 85 03 00 00       	call   800b09 <strnlen>
  800784:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800787:	29 c2                	sub    %eax,%edx
  800789:	89 55 c8             	mov    %edx,-0x38(%ebp)
  80078c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80078f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800793:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800796:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800799:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80079b:	eb 10                	jmp    8007ad <.L36+0x66>
					putch(padc, putdat);
  80079d:	83 ec 08             	sub    $0x8,%esp
  8007a0:	56                   	push   %esi
  8007a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a4:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8007a7:	83 ef 01             	sub    $0x1,%edi
  8007aa:	83 c4 10             	add    $0x10,%esp
  8007ad:	85 ff                	test   %edi,%edi
  8007af:	7f ec                	jg     80079d <.L36+0x56>
  8007b1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007b4:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8007b7:	85 d2                	test   %edx,%edx
  8007b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007be:	0f 49 c2             	cmovns %edx,%eax
  8007c1:	29 c2                	sub    %eax,%edx
  8007c3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8007c6:	89 75 0c             	mov    %esi,0xc(%ebp)
  8007c9:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8007cc:	eb 17                	jmp    8007e5 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  8007ce:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007d2:	75 30                	jne    800804 <.L36+0xbd>
					putch(ch, putdat);
  8007d4:	83 ec 08             	sub    $0x8,%esp
  8007d7:	ff 75 0c             	pushl  0xc(%ebp)
  8007da:	50                   	push   %eax
  8007db:	ff 55 08             	call   *0x8(%ebp)
  8007de:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007e1:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8007e5:	83 c7 01             	add    $0x1,%edi
  8007e8:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8007ec:	0f be c2             	movsbl %dl,%eax
  8007ef:	85 c0                	test   %eax,%eax
  8007f1:	74 52                	je     800845 <.L36+0xfe>
  8007f3:	85 f6                	test   %esi,%esi
  8007f5:	78 d7                	js     8007ce <.L36+0x87>
  8007f7:	83 ee 01             	sub    $0x1,%esi
  8007fa:	79 d2                	jns    8007ce <.L36+0x87>
  8007fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8007ff:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800802:	eb 32                	jmp    800836 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  800804:	0f be d2             	movsbl %dl,%edx
  800807:	83 ea 20             	sub    $0x20,%edx
  80080a:	83 fa 5e             	cmp    $0x5e,%edx
  80080d:	76 c5                	jbe    8007d4 <.L36+0x8d>
					putch('?', putdat);
  80080f:	83 ec 08             	sub    $0x8,%esp
  800812:	ff 75 0c             	pushl  0xc(%ebp)
  800815:	6a 3f                	push   $0x3f
  800817:	ff 55 08             	call   *0x8(%ebp)
  80081a:	83 c4 10             	add    $0x10,%esp
  80081d:	eb c2                	jmp    8007e1 <.L36+0x9a>
  80081f:	89 75 0c             	mov    %esi,0xc(%ebp)
  800822:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800825:	eb be                	jmp    8007e5 <.L36+0x9e>
				putch(' ', putdat);
  800827:	83 ec 08             	sub    $0x8,%esp
  80082a:	56                   	push   %esi
  80082b:	6a 20                	push   $0x20
  80082d:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800830:	83 ef 01             	sub    $0x1,%edi
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	85 ff                	test   %edi,%edi
  800838:	7f ed                	jg     800827 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  80083a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80083d:	89 45 14             	mov    %eax,0x14(%ebp)
  800840:	e9 7b 01 00 00       	jmp    8009c0 <.L35+0x45>
  800845:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800848:	8b 75 0c             	mov    0xc(%ebp),%esi
  80084b:	eb e9                	jmp    800836 <.L36+0xef>

0080084d <.L31>:
  80084d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800850:	83 f9 01             	cmp    $0x1,%ecx
  800853:	7e 40                	jle    800895 <.L31+0x48>
		return va_arg(*ap, long long);
  800855:	8b 45 14             	mov    0x14(%ebp),%eax
  800858:	8b 50 04             	mov    0x4(%eax),%edx
  80085b:	8b 00                	mov    (%eax),%eax
  80085d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800860:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800863:	8b 45 14             	mov    0x14(%ebp),%eax
  800866:	8d 40 08             	lea    0x8(%eax),%eax
  800869:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
  80086c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800870:	79 55                	jns    8008c7 <.L31+0x7a>
				putch('-', putdat);
  800872:	83 ec 08             	sub    $0x8,%esp
  800875:	56                   	push   %esi
  800876:	6a 2d                	push   $0x2d
  800878:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  80087b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80087e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800881:	f7 da                	neg    %edx
  800883:	83 d1 00             	adc    $0x0,%ecx
  800886:	f7 d9                	neg    %ecx
  800888:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
  80088b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800890:	e9 10 01 00 00       	jmp    8009a5 <.L35+0x2a>
	else if (lflag)
  800895:	85 c9                	test   %ecx,%ecx
  800897:	75 17                	jne    8008b0 <.L31+0x63>
		return va_arg(*ap, int);
  800899:	8b 45 14             	mov    0x14(%ebp),%eax
  80089c:	8b 00                	mov    (%eax),%eax
  80089e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008a1:	99                   	cltd   
  8008a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a8:	8d 40 04             	lea    0x4(%eax),%eax
  8008ab:	89 45 14             	mov    %eax,0x14(%ebp)
  8008ae:	eb bc                	jmp    80086c <.L31+0x1f>
		return va_arg(*ap, long);
  8008b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b3:	8b 00                	mov    (%eax),%eax
  8008b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b8:	99                   	cltd   
  8008b9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bf:	8d 40 04             	lea    0x4(%eax),%eax
  8008c2:	89 45 14             	mov    %eax,0x14(%ebp)
  8008c5:	eb a5                	jmp    80086c <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  8008c7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008ca:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
  8008cd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008d2:	e9 ce 00 00 00       	jmp    8009a5 <.L35+0x2a>

008008d7 <.L37>:
  8008d7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8008da:	83 f9 01             	cmp    $0x1,%ecx
  8008dd:	7e 18                	jle    8008f7 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8008df:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e2:	8b 10                	mov    (%eax),%edx
  8008e4:	8b 48 04             	mov    0x4(%eax),%ecx
  8008e7:	8d 40 08             	lea    0x8(%eax),%eax
  8008ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8008ed:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008f2:	e9 ae 00 00 00       	jmp    8009a5 <.L35+0x2a>
	else if (lflag)
  8008f7:	85 c9                	test   %ecx,%ecx
  8008f9:	75 1a                	jne    800915 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8008fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fe:	8b 10                	mov    (%eax),%edx
  800900:	b9 00 00 00 00       	mov    $0x0,%ecx
  800905:	8d 40 04             	lea    0x4(%eax),%eax
  800908:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80090b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800910:	e9 90 00 00 00       	jmp    8009a5 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800915:	8b 45 14             	mov    0x14(%ebp),%eax
  800918:	8b 10                	mov    (%eax),%edx
  80091a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80091f:	8d 40 04             	lea    0x4(%eax),%eax
  800922:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800925:	b8 0a 00 00 00       	mov    $0xa,%eax
  80092a:	eb 79                	jmp    8009a5 <.L35+0x2a>

0080092c <.L34>:
  80092c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80092f:	83 f9 01             	cmp    $0x1,%ecx
  800932:	7e 15                	jle    800949 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  800934:	8b 45 14             	mov    0x14(%ebp),%eax
  800937:	8b 10                	mov    (%eax),%edx
  800939:	8b 48 04             	mov    0x4(%eax),%ecx
  80093c:	8d 40 08             	lea    0x8(%eax),%eax
  80093f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800942:	b8 08 00 00 00       	mov    $0x8,%eax
  800947:	eb 5c                	jmp    8009a5 <.L35+0x2a>
	else if (lflag)
  800949:	85 c9                	test   %ecx,%ecx
  80094b:	75 17                	jne    800964 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  80094d:	8b 45 14             	mov    0x14(%ebp),%eax
  800950:	8b 10                	mov    (%eax),%edx
  800952:	b9 00 00 00 00       	mov    $0x0,%ecx
  800957:	8d 40 04             	lea    0x4(%eax),%eax
  80095a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80095d:	b8 08 00 00 00       	mov    $0x8,%eax
  800962:	eb 41                	jmp    8009a5 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800964:	8b 45 14             	mov    0x14(%ebp),%eax
  800967:	8b 10                	mov    (%eax),%edx
  800969:	b9 00 00 00 00       	mov    $0x0,%ecx
  80096e:	8d 40 04             	lea    0x4(%eax),%eax
  800971:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800974:	b8 08 00 00 00       	mov    $0x8,%eax
  800979:	eb 2a                	jmp    8009a5 <.L35+0x2a>

0080097b <.L35>:
			putch('0', putdat);
  80097b:	83 ec 08             	sub    $0x8,%esp
  80097e:	56                   	push   %esi
  80097f:	6a 30                	push   $0x30
  800981:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800984:	83 c4 08             	add    $0x8,%esp
  800987:	56                   	push   %esi
  800988:	6a 78                	push   $0x78
  80098a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80098d:	8b 45 14             	mov    0x14(%ebp),%eax
  800990:	8b 10                	mov    (%eax),%edx
  800992:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800997:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80099a:	8d 40 04             	lea    0x4(%eax),%eax
  80099d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009a0:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  8009a5:	83 ec 0c             	sub    $0xc,%esp
  8009a8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8009ac:	57                   	push   %edi
  8009ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8009b0:	50                   	push   %eax
  8009b1:	51                   	push   %ecx
  8009b2:	52                   	push   %edx
  8009b3:	89 f2                	mov    %esi,%edx
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	e8 20 fb ff ff       	call   8004dd <printnum>
			break;
  8009bd:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8009c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  8009c3:	83 c7 01             	add    $0x1,%edi
  8009c6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8009ca:	83 f8 25             	cmp    $0x25,%eax
  8009cd:	0f 84 2d fc ff ff    	je     800600 <vprintfmt+0x1f>
			if (ch == '\0')
  8009d3:	85 c0                	test   %eax,%eax
  8009d5:	0f 84 91 00 00 00    	je     800a6c <.L22+0x21>
			putch(ch, putdat);
  8009db:	83 ec 08             	sub    $0x8,%esp
  8009de:	56                   	push   %esi
  8009df:	50                   	push   %eax
  8009e0:	ff 55 08             	call   *0x8(%ebp)
  8009e3:	83 c4 10             	add    $0x10,%esp
  8009e6:	eb db                	jmp    8009c3 <.L35+0x48>

008009e8 <.L38>:
  8009e8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8009eb:	83 f9 01             	cmp    $0x1,%ecx
  8009ee:	7e 15                	jle    800a05 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8009f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f3:	8b 10                	mov    (%eax),%edx
  8009f5:	8b 48 04             	mov    0x4(%eax),%ecx
  8009f8:	8d 40 08             	lea    0x8(%eax),%eax
  8009fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009fe:	b8 10 00 00 00       	mov    $0x10,%eax
  800a03:	eb a0                	jmp    8009a5 <.L35+0x2a>
	else if (lflag)
  800a05:	85 c9                	test   %ecx,%ecx
  800a07:	75 17                	jne    800a20 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  800a09:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0c:	8b 10                	mov    (%eax),%edx
  800a0e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a13:	8d 40 04             	lea    0x4(%eax),%eax
  800a16:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a19:	b8 10 00 00 00       	mov    $0x10,%eax
  800a1e:	eb 85                	jmp    8009a5 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800a20:	8b 45 14             	mov    0x14(%ebp),%eax
  800a23:	8b 10                	mov    (%eax),%edx
  800a25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a2a:	8d 40 04             	lea    0x4(%eax),%eax
  800a2d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a30:	b8 10 00 00 00       	mov    $0x10,%eax
  800a35:	e9 6b ff ff ff       	jmp    8009a5 <.L35+0x2a>

00800a3a <.L25>:
			putch(ch, putdat);
  800a3a:	83 ec 08             	sub    $0x8,%esp
  800a3d:	56                   	push   %esi
  800a3e:	6a 25                	push   $0x25
  800a40:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a43:	83 c4 10             	add    $0x10,%esp
  800a46:	e9 75 ff ff ff       	jmp    8009c0 <.L35+0x45>

00800a4b <.L22>:
			putch('%', putdat);
  800a4b:	83 ec 08             	sub    $0x8,%esp
  800a4e:	56                   	push   %esi
  800a4f:	6a 25                	push   $0x25
  800a51:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a54:	83 c4 10             	add    $0x10,%esp
  800a57:	89 f8                	mov    %edi,%eax
  800a59:	eb 03                	jmp    800a5e <.L22+0x13>
  800a5b:	83 e8 01             	sub    $0x1,%eax
  800a5e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800a62:	75 f7                	jne    800a5b <.L22+0x10>
  800a64:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a67:	e9 54 ff ff ff       	jmp    8009c0 <.L35+0x45>
}
  800a6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a6f:	5b                   	pop    %ebx
  800a70:	5e                   	pop    %esi
  800a71:	5f                   	pop    %edi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	53                   	push   %ebx
  800a78:	83 ec 14             	sub    $0x14,%esp
  800a7b:	e8 1d f6 ff ff       	call   80009d <__x86.get_pc_thunk.bx>
  800a80:	81 c3 80 15 00 00    	add    $0x1580,%ebx
  800a86:	8b 45 08             	mov    0x8(%ebp),%eax
  800a89:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  800a8c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a8f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a93:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a9d:	85 c0                	test   %eax,%eax
  800a9f:	74 2b                	je     800acc <vsnprintf+0x58>
  800aa1:	85 d2                	test   %edx,%edx
  800aa3:	7e 27                	jle    800acc <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  800aa5:	ff 75 14             	pushl  0x14(%ebp)
  800aa8:	ff 75 10             	pushl  0x10(%ebp)
  800aab:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800aae:	50                   	push   %eax
  800aaf:	8d 83 a7 e5 ff ff    	lea    -0x1a59(%ebx),%eax
  800ab5:	50                   	push   %eax
  800ab6:	e8 26 fb ff ff       	call   8005e1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800abb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800abe:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ac4:	83 c4 10             	add    $0x10,%esp
}
  800ac7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aca:	c9                   	leave  
  800acb:	c3                   	ret    
		return -E_INVAL;
  800acc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ad1:	eb f4                	jmp    800ac7 <vsnprintf+0x53>

00800ad3 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ad9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800adc:	50                   	push   %eax
  800add:	ff 75 10             	pushl  0x10(%ebp)
  800ae0:	ff 75 0c             	pushl  0xc(%ebp)
  800ae3:	ff 75 08             	pushl  0x8(%ebp)
  800ae6:	e8 89 ff ff ff       	call   800a74 <vsnprintf>
	va_end(ap);

	return rc;
}
  800aeb:	c9                   	leave  
  800aec:	c3                   	ret    

00800aed <__x86.get_pc_thunk.cx>:
  800aed:	8b 0c 24             	mov    (%esp),%ecx
  800af0:	c3                   	ret    

00800af1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800af7:	b8 00 00 00 00       	mov    $0x0,%eax
  800afc:	eb 03                	jmp    800b01 <strlen+0x10>
		n++;
  800afe:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800b01:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b05:	75 f7                	jne    800afe <strlen+0xd>
	return n;
}
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b12:	b8 00 00 00 00       	mov    $0x0,%eax
  800b17:	eb 03                	jmp    800b1c <strnlen+0x13>
		n++;
  800b19:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b1c:	39 d0                	cmp    %edx,%eax
  800b1e:	74 06                	je     800b26 <strnlen+0x1d>
  800b20:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b24:	75 f3                	jne    800b19 <strnlen+0x10>
	return n;
}
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	53                   	push   %ebx
  800b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b32:	89 c2                	mov    %eax,%edx
  800b34:	83 c1 01             	add    $0x1,%ecx
  800b37:	83 c2 01             	add    $0x1,%edx
  800b3a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b3e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b41:	84 db                	test   %bl,%bl
  800b43:	75 ef                	jne    800b34 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b45:	5b                   	pop    %ebx
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	53                   	push   %ebx
  800b4c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b4f:	53                   	push   %ebx
  800b50:	e8 9c ff ff ff       	call   800af1 <strlen>
  800b55:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b58:	ff 75 0c             	pushl  0xc(%ebp)
  800b5b:	01 d8                	add    %ebx,%eax
  800b5d:	50                   	push   %eax
  800b5e:	e8 c5 ff ff ff       	call   800b28 <strcpy>
	return dst;
}
  800b63:	89 d8                	mov    %ebx,%eax
  800b65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b68:	c9                   	leave  
  800b69:	c3                   	ret    

00800b6a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
  800b6f:	8b 75 08             	mov    0x8(%ebp),%esi
  800b72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b75:	89 f3                	mov    %esi,%ebx
  800b77:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b7a:	89 f2                	mov    %esi,%edx
  800b7c:	eb 0f                	jmp    800b8d <strncpy+0x23>
		*dst++ = *src;
  800b7e:	83 c2 01             	add    $0x1,%edx
  800b81:	0f b6 01             	movzbl (%ecx),%eax
  800b84:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b87:	80 39 01             	cmpb   $0x1,(%ecx)
  800b8a:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800b8d:	39 da                	cmp    %ebx,%edx
  800b8f:	75 ed                	jne    800b7e <strncpy+0x14>
	}
	return ret;
}
  800b91:	89 f0                	mov    %esi,%eax
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
  800b9c:	8b 75 08             	mov    0x8(%ebp),%esi
  800b9f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ba5:	89 f0                	mov    %esi,%eax
  800ba7:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bab:	85 c9                	test   %ecx,%ecx
  800bad:	75 0b                	jne    800bba <strlcpy+0x23>
  800baf:	eb 17                	jmp    800bc8 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bb1:	83 c2 01             	add    $0x1,%edx
  800bb4:	83 c0 01             	add    $0x1,%eax
  800bb7:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800bba:	39 d8                	cmp    %ebx,%eax
  800bbc:	74 07                	je     800bc5 <strlcpy+0x2e>
  800bbe:	0f b6 0a             	movzbl (%edx),%ecx
  800bc1:	84 c9                	test   %cl,%cl
  800bc3:	75 ec                	jne    800bb1 <strlcpy+0x1a>
		*dst = '\0';
  800bc5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bc8:	29 f0                	sub    %esi,%eax
}
  800bca:	5b                   	pop    %ebx
  800bcb:	5e                   	pop    %esi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bd7:	eb 06                	jmp    800bdf <strcmp+0x11>
		p++, q++;
  800bd9:	83 c1 01             	add    $0x1,%ecx
  800bdc:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800bdf:	0f b6 01             	movzbl (%ecx),%eax
  800be2:	84 c0                	test   %al,%al
  800be4:	74 04                	je     800bea <strcmp+0x1c>
  800be6:	3a 02                	cmp    (%edx),%al
  800be8:	74 ef                	je     800bd9 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bea:	0f b6 c0             	movzbl %al,%eax
  800bed:	0f b6 12             	movzbl (%edx),%edx
  800bf0:	29 d0                	sub    %edx,%eax
}
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	53                   	push   %ebx
  800bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bfe:	89 c3                	mov    %eax,%ebx
  800c00:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c03:	eb 06                	jmp    800c0b <strncmp+0x17>
		n--, p++, q++;
  800c05:	83 c0 01             	add    $0x1,%eax
  800c08:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c0b:	39 d8                	cmp    %ebx,%eax
  800c0d:	74 16                	je     800c25 <strncmp+0x31>
  800c0f:	0f b6 08             	movzbl (%eax),%ecx
  800c12:	84 c9                	test   %cl,%cl
  800c14:	74 04                	je     800c1a <strncmp+0x26>
  800c16:	3a 0a                	cmp    (%edx),%cl
  800c18:	74 eb                	je     800c05 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c1a:	0f b6 00             	movzbl (%eax),%eax
  800c1d:	0f b6 12             	movzbl (%edx),%edx
  800c20:	29 d0                	sub    %edx,%eax
}
  800c22:	5b                   	pop    %ebx
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    
		return 0;
  800c25:	b8 00 00 00 00       	mov    $0x0,%eax
  800c2a:	eb f6                	jmp    800c22 <strncmp+0x2e>

00800c2c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c32:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c36:	0f b6 10             	movzbl (%eax),%edx
  800c39:	84 d2                	test   %dl,%dl
  800c3b:	74 09                	je     800c46 <strchr+0x1a>
		if (*s == c)
  800c3d:	38 ca                	cmp    %cl,%dl
  800c3f:	74 0a                	je     800c4b <strchr+0x1f>
	for (; *s; s++)
  800c41:	83 c0 01             	add    $0x1,%eax
  800c44:	eb f0                	jmp    800c36 <strchr+0xa>
			return (char *) s;
	return 0;
  800c46:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	8b 45 08             	mov    0x8(%ebp),%eax
  800c53:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c57:	eb 03                	jmp    800c5c <strfind+0xf>
  800c59:	83 c0 01             	add    $0x1,%eax
  800c5c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c5f:	38 ca                	cmp    %cl,%dl
  800c61:	74 04                	je     800c67 <strfind+0x1a>
  800c63:	84 d2                	test   %dl,%dl
  800c65:	75 f2                	jne    800c59 <strfind+0xc>
			break;
	return (char *) s;
}
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c72:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c75:	85 c9                	test   %ecx,%ecx
  800c77:	74 13                	je     800c8c <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c79:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c7f:	75 05                	jne    800c86 <memset+0x1d>
  800c81:	f6 c1 03             	test   $0x3,%cl
  800c84:	74 0d                	je     800c93 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c89:	fc                   	cld    
  800c8a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c8c:	89 f8                	mov    %edi,%eax
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    
		c &= 0xFF;
  800c93:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c97:	89 d3                	mov    %edx,%ebx
  800c99:	c1 e3 08             	shl    $0x8,%ebx
  800c9c:	89 d0                	mov    %edx,%eax
  800c9e:	c1 e0 18             	shl    $0x18,%eax
  800ca1:	89 d6                	mov    %edx,%esi
  800ca3:	c1 e6 10             	shl    $0x10,%esi
  800ca6:	09 f0                	or     %esi,%eax
  800ca8:	09 c2                	or     %eax,%edx
  800caa:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800cac:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800caf:	89 d0                	mov    %edx,%eax
  800cb1:	fc                   	cld    
  800cb2:	f3 ab                	rep stos %eax,%es:(%edi)
  800cb4:	eb d6                	jmp    800c8c <memset+0x23>

00800cb6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cc1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cc4:	39 c6                	cmp    %eax,%esi
  800cc6:	73 35                	jae    800cfd <memmove+0x47>
  800cc8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ccb:	39 c2                	cmp    %eax,%edx
  800ccd:	76 2e                	jbe    800cfd <memmove+0x47>
		s += n;
		d += n;
  800ccf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cd2:	89 d6                	mov    %edx,%esi
  800cd4:	09 fe                	or     %edi,%esi
  800cd6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cdc:	74 0c                	je     800cea <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cde:	83 ef 01             	sub    $0x1,%edi
  800ce1:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ce4:	fd                   	std    
  800ce5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ce7:	fc                   	cld    
  800ce8:	eb 21                	jmp    800d0b <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cea:	f6 c1 03             	test   $0x3,%cl
  800ced:	75 ef                	jne    800cde <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800cef:	83 ef 04             	sub    $0x4,%edi
  800cf2:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cf5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800cf8:	fd                   	std    
  800cf9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cfb:	eb ea                	jmp    800ce7 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cfd:	89 f2                	mov    %esi,%edx
  800cff:	09 c2                	or     %eax,%edx
  800d01:	f6 c2 03             	test   $0x3,%dl
  800d04:	74 09                	je     800d0f <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d06:	89 c7                	mov    %eax,%edi
  800d08:	fc                   	cld    
  800d09:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d0f:	f6 c1 03             	test   $0x3,%cl
  800d12:	75 f2                	jne    800d06 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d14:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d17:	89 c7                	mov    %eax,%edi
  800d19:	fc                   	cld    
  800d1a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d1c:	eb ed                	jmp    800d0b <memmove+0x55>

00800d1e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d21:	ff 75 10             	pushl  0x10(%ebp)
  800d24:	ff 75 0c             	pushl  0xc(%ebp)
  800d27:	ff 75 08             	pushl  0x8(%ebp)
  800d2a:	e8 87 ff ff ff       	call   800cb6 <memmove>
}
  800d2f:	c9                   	leave  
  800d30:	c3                   	ret    

00800d31 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	8b 45 08             	mov    0x8(%ebp),%eax
  800d39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d3c:	89 c6                	mov    %eax,%esi
  800d3e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d41:	39 f0                	cmp    %esi,%eax
  800d43:	74 1c                	je     800d61 <memcmp+0x30>
		if (*s1 != *s2)
  800d45:	0f b6 08             	movzbl (%eax),%ecx
  800d48:	0f b6 1a             	movzbl (%edx),%ebx
  800d4b:	38 d9                	cmp    %bl,%cl
  800d4d:	75 08                	jne    800d57 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800d4f:	83 c0 01             	add    $0x1,%eax
  800d52:	83 c2 01             	add    $0x1,%edx
  800d55:	eb ea                	jmp    800d41 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800d57:	0f b6 c1             	movzbl %cl,%eax
  800d5a:	0f b6 db             	movzbl %bl,%ebx
  800d5d:	29 d8                	sub    %ebx,%eax
  800d5f:	eb 05                	jmp    800d66 <memcmp+0x35>
	}

	return 0;
  800d61:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d73:	89 c2                	mov    %eax,%edx
  800d75:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d78:	39 d0                	cmp    %edx,%eax
  800d7a:	73 09                	jae    800d85 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d7c:	38 08                	cmp    %cl,(%eax)
  800d7e:	74 05                	je     800d85 <memfind+0x1b>
	for (; s < ends; s++)
  800d80:	83 c0 01             	add    $0x1,%eax
  800d83:	eb f3                	jmp    800d78 <memfind+0xe>
			break;
	return (void *) s;
}
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    

00800d87 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d87:	55                   	push   %ebp
  800d88:	89 e5                	mov    %esp,%ebp
  800d8a:	57                   	push   %edi
  800d8b:	56                   	push   %esi
  800d8c:	53                   	push   %ebx
  800d8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d90:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d93:	eb 03                	jmp    800d98 <strtol+0x11>
		s++;
  800d95:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d98:	0f b6 01             	movzbl (%ecx),%eax
  800d9b:	3c 20                	cmp    $0x20,%al
  800d9d:	74 f6                	je     800d95 <strtol+0xe>
  800d9f:	3c 09                	cmp    $0x9,%al
  800da1:	74 f2                	je     800d95 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800da3:	3c 2b                	cmp    $0x2b,%al
  800da5:	74 2e                	je     800dd5 <strtol+0x4e>
	int neg = 0;
  800da7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800dac:	3c 2d                	cmp    $0x2d,%al
  800dae:	74 2f                	je     800ddf <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800db0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800db6:	75 05                	jne    800dbd <strtol+0x36>
  800db8:	80 39 30             	cmpb   $0x30,(%ecx)
  800dbb:	74 2c                	je     800de9 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dbd:	85 db                	test   %ebx,%ebx
  800dbf:	75 0a                	jne    800dcb <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800dc1:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800dc6:	80 39 30             	cmpb   $0x30,(%ecx)
  800dc9:	74 28                	je     800df3 <strtol+0x6c>
		base = 10;
  800dcb:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800dd3:	eb 50                	jmp    800e25 <strtol+0x9e>
		s++;
  800dd5:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800dd8:	bf 00 00 00 00       	mov    $0x0,%edi
  800ddd:	eb d1                	jmp    800db0 <strtol+0x29>
		s++, neg = 1;
  800ddf:	83 c1 01             	add    $0x1,%ecx
  800de2:	bf 01 00 00 00       	mov    $0x1,%edi
  800de7:	eb c7                	jmp    800db0 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800de9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ded:	74 0e                	je     800dfd <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800def:	85 db                	test   %ebx,%ebx
  800df1:	75 d8                	jne    800dcb <strtol+0x44>
		s++, base = 8;
  800df3:	83 c1 01             	add    $0x1,%ecx
  800df6:	bb 08 00 00 00       	mov    $0x8,%ebx
  800dfb:	eb ce                	jmp    800dcb <strtol+0x44>
		s += 2, base = 16;
  800dfd:	83 c1 02             	add    $0x2,%ecx
  800e00:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e05:	eb c4                	jmp    800dcb <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800e07:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e0a:	89 f3                	mov    %esi,%ebx
  800e0c:	80 fb 19             	cmp    $0x19,%bl
  800e0f:	77 29                	ja     800e3a <strtol+0xb3>
			dig = *s - 'a' + 10;
  800e11:	0f be d2             	movsbl %dl,%edx
  800e14:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e17:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e1a:	7d 30                	jge    800e4c <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800e1c:	83 c1 01             	add    $0x1,%ecx
  800e1f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e23:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800e25:	0f b6 11             	movzbl (%ecx),%edx
  800e28:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e2b:	89 f3                	mov    %esi,%ebx
  800e2d:	80 fb 09             	cmp    $0x9,%bl
  800e30:	77 d5                	ja     800e07 <strtol+0x80>
			dig = *s - '0';
  800e32:	0f be d2             	movsbl %dl,%edx
  800e35:	83 ea 30             	sub    $0x30,%edx
  800e38:	eb dd                	jmp    800e17 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800e3a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e3d:	89 f3                	mov    %esi,%ebx
  800e3f:	80 fb 19             	cmp    $0x19,%bl
  800e42:	77 08                	ja     800e4c <strtol+0xc5>
			dig = *s - 'A' + 10;
  800e44:	0f be d2             	movsbl %dl,%edx
  800e47:	83 ea 37             	sub    $0x37,%edx
  800e4a:	eb cb                	jmp    800e17 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800e4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e50:	74 05                	je     800e57 <strtol+0xd0>
		*endptr = (char *) s;
  800e52:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e55:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800e57:	89 c2                	mov    %eax,%edx
  800e59:	f7 da                	neg    %edx
  800e5b:	85 ff                	test   %edi,%edi
  800e5d:	0f 45 c2             	cmovne %edx,%eax
}
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    
  800e65:	66 90                	xchg   %ax,%ax
  800e67:	66 90                	xchg   %ax,%ax
  800e69:	66 90                	xchg   %ax,%ax
  800e6b:	66 90                	xchg   %ax,%ax
  800e6d:	66 90                	xchg   %ax,%ax
  800e6f:	90                   	nop

00800e70 <__udivdi3>:
  800e70:	55                   	push   %ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 1c             	sub    $0x1c,%esp
  800e77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e7b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e83:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e87:	85 d2                	test   %edx,%edx
  800e89:	75 35                	jne    800ec0 <__udivdi3+0x50>
  800e8b:	39 f3                	cmp    %esi,%ebx
  800e8d:	0f 87 bd 00 00 00    	ja     800f50 <__udivdi3+0xe0>
  800e93:	85 db                	test   %ebx,%ebx
  800e95:	89 d9                	mov    %ebx,%ecx
  800e97:	75 0b                	jne    800ea4 <__udivdi3+0x34>
  800e99:	b8 01 00 00 00       	mov    $0x1,%eax
  800e9e:	31 d2                	xor    %edx,%edx
  800ea0:	f7 f3                	div    %ebx
  800ea2:	89 c1                	mov    %eax,%ecx
  800ea4:	31 d2                	xor    %edx,%edx
  800ea6:	89 f0                	mov    %esi,%eax
  800ea8:	f7 f1                	div    %ecx
  800eaa:	89 c6                	mov    %eax,%esi
  800eac:	89 e8                	mov    %ebp,%eax
  800eae:	89 f7                	mov    %esi,%edi
  800eb0:	f7 f1                	div    %ecx
  800eb2:	89 fa                	mov    %edi,%edx
  800eb4:	83 c4 1c             	add    $0x1c,%esp
  800eb7:	5b                   	pop    %ebx
  800eb8:	5e                   	pop    %esi
  800eb9:	5f                   	pop    %edi
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    
  800ebc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	39 f2                	cmp    %esi,%edx
  800ec2:	77 7c                	ja     800f40 <__udivdi3+0xd0>
  800ec4:	0f bd fa             	bsr    %edx,%edi
  800ec7:	83 f7 1f             	xor    $0x1f,%edi
  800eca:	0f 84 98 00 00 00    	je     800f68 <__udivdi3+0xf8>
  800ed0:	89 f9                	mov    %edi,%ecx
  800ed2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ed7:	29 f8                	sub    %edi,%eax
  800ed9:	d3 e2                	shl    %cl,%edx
  800edb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800edf:	89 c1                	mov    %eax,%ecx
  800ee1:	89 da                	mov    %ebx,%edx
  800ee3:	d3 ea                	shr    %cl,%edx
  800ee5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ee9:	09 d1                	or     %edx,%ecx
  800eeb:	89 f2                	mov    %esi,%edx
  800eed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ef1:	89 f9                	mov    %edi,%ecx
  800ef3:	d3 e3                	shl    %cl,%ebx
  800ef5:	89 c1                	mov    %eax,%ecx
  800ef7:	d3 ea                	shr    %cl,%edx
  800ef9:	89 f9                	mov    %edi,%ecx
  800efb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800eff:	d3 e6                	shl    %cl,%esi
  800f01:	89 eb                	mov    %ebp,%ebx
  800f03:	89 c1                	mov    %eax,%ecx
  800f05:	d3 eb                	shr    %cl,%ebx
  800f07:	09 de                	or     %ebx,%esi
  800f09:	89 f0                	mov    %esi,%eax
  800f0b:	f7 74 24 08          	divl   0x8(%esp)
  800f0f:	89 d6                	mov    %edx,%esi
  800f11:	89 c3                	mov    %eax,%ebx
  800f13:	f7 64 24 0c          	mull   0xc(%esp)
  800f17:	39 d6                	cmp    %edx,%esi
  800f19:	72 0c                	jb     800f27 <__udivdi3+0xb7>
  800f1b:	89 f9                	mov    %edi,%ecx
  800f1d:	d3 e5                	shl    %cl,%ebp
  800f1f:	39 c5                	cmp    %eax,%ebp
  800f21:	73 5d                	jae    800f80 <__udivdi3+0x110>
  800f23:	39 d6                	cmp    %edx,%esi
  800f25:	75 59                	jne    800f80 <__udivdi3+0x110>
  800f27:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f2a:	31 ff                	xor    %edi,%edi
  800f2c:	89 fa                	mov    %edi,%edx
  800f2e:	83 c4 1c             	add    $0x1c,%esp
  800f31:	5b                   	pop    %ebx
  800f32:	5e                   	pop    %esi
  800f33:	5f                   	pop    %edi
  800f34:	5d                   	pop    %ebp
  800f35:	c3                   	ret    
  800f36:	8d 76 00             	lea    0x0(%esi),%esi
  800f39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800f40:	31 ff                	xor    %edi,%edi
  800f42:	31 c0                	xor    %eax,%eax
  800f44:	89 fa                	mov    %edi,%edx
  800f46:	83 c4 1c             	add    $0x1c,%esp
  800f49:	5b                   	pop    %ebx
  800f4a:	5e                   	pop    %esi
  800f4b:	5f                   	pop    %edi
  800f4c:	5d                   	pop    %ebp
  800f4d:	c3                   	ret    
  800f4e:	66 90                	xchg   %ax,%ax
  800f50:	31 ff                	xor    %edi,%edi
  800f52:	89 e8                	mov    %ebp,%eax
  800f54:	89 f2                	mov    %esi,%edx
  800f56:	f7 f3                	div    %ebx
  800f58:	89 fa                	mov    %edi,%edx
  800f5a:	83 c4 1c             	add    $0x1c,%esp
  800f5d:	5b                   	pop    %ebx
  800f5e:	5e                   	pop    %esi
  800f5f:	5f                   	pop    %edi
  800f60:	5d                   	pop    %ebp
  800f61:	c3                   	ret    
  800f62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f68:	39 f2                	cmp    %esi,%edx
  800f6a:	72 06                	jb     800f72 <__udivdi3+0x102>
  800f6c:	31 c0                	xor    %eax,%eax
  800f6e:	39 eb                	cmp    %ebp,%ebx
  800f70:	77 d2                	ja     800f44 <__udivdi3+0xd4>
  800f72:	b8 01 00 00 00       	mov    $0x1,%eax
  800f77:	eb cb                	jmp    800f44 <__udivdi3+0xd4>
  800f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f80:	89 d8                	mov    %ebx,%eax
  800f82:	31 ff                	xor    %edi,%edi
  800f84:	eb be                	jmp    800f44 <__udivdi3+0xd4>
  800f86:	66 90                	xchg   %ax,%ax
  800f88:	66 90                	xchg   %ax,%ax
  800f8a:	66 90                	xchg   %ax,%ax
  800f8c:	66 90                	xchg   %ax,%ax
  800f8e:	66 90                	xchg   %ax,%ax

00800f90 <__umoddi3>:
  800f90:	55                   	push   %ebp
  800f91:	57                   	push   %edi
  800f92:	56                   	push   %esi
  800f93:	53                   	push   %ebx
  800f94:	83 ec 1c             	sub    $0x1c,%esp
  800f97:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f9b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f9f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800fa3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800fa7:	85 ed                	test   %ebp,%ebp
  800fa9:	89 f0                	mov    %esi,%eax
  800fab:	89 da                	mov    %ebx,%edx
  800fad:	75 19                	jne    800fc8 <__umoddi3+0x38>
  800faf:	39 df                	cmp    %ebx,%edi
  800fb1:	0f 86 b1 00 00 00    	jbe    801068 <__umoddi3+0xd8>
  800fb7:	f7 f7                	div    %edi
  800fb9:	89 d0                	mov    %edx,%eax
  800fbb:	31 d2                	xor    %edx,%edx
  800fbd:	83 c4 1c             	add    $0x1c,%esp
  800fc0:	5b                   	pop    %ebx
  800fc1:	5e                   	pop    %esi
  800fc2:	5f                   	pop    %edi
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    
  800fc5:	8d 76 00             	lea    0x0(%esi),%esi
  800fc8:	39 dd                	cmp    %ebx,%ebp
  800fca:	77 f1                	ja     800fbd <__umoddi3+0x2d>
  800fcc:	0f bd cd             	bsr    %ebp,%ecx
  800fcf:	83 f1 1f             	xor    $0x1f,%ecx
  800fd2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fd6:	0f 84 b4 00 00 00    	je     801090 <__umoddi3+0x100>
  800fdc:	b8 20 00 00 00       	mov    $0x20,%eax
  800fe1:	89 c2                	mov    %eax,%edx
  800fe3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fe7:	29 c2                	sub    %eax,%edx
  800fe9:	89 c1                	mov    %eax,%ecx
  800feb:	89 f8                	mov    %edi,%eax
  800fed:	d3 e5                	shl    %cl,%ebp
  800fef:	89 d1                	mov    %edx,%ecx
  800ff1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ff5:	d3 e8                	shr    %cl,%eax
  800ff7:	09 c5                	or     %eax,%ebp
  800ff9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ffd:	89 c1                	mov    %eax,%ecx
  800fff:	d3 e7                	shl    %cl,%edi
  801001:	89 d1                	mov    %edx,%ecx
  801003:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801007:	89 df                	mov    %ebx,%edi
  801009:	d3 ef                	shr    %cl,%edi
  80100b:	89 c1                	mov    %eax,%ecx
  80100d:	89 f0                	mov    %esi,%eax
  80100f:	d3 e3                	shl    %cl,%ebx
  801011:	89 d1                	mov    %edx,%ecx
  801013:	89 fa                	mov    %edi,%edx
  801015:	d3 e8                	shr    %cl,%eax
  801017:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80101c:	09 d8                	or     %ebx,%eax
  80101e:	f7 f5                	div    %ebp
  801020:	d3 e6                	shl    %cl,%esi
  801022:	89 d1                	mov    %edx,%ecx
  801024:	f7 64 24 08          	mull   0x8(%esp)
  801028:	39 d1                	cmp    %edx,%ecx
  80102a:	89 c3                	mov    %eax,%ebx
  80102c:	89 d7                	mov    %edx,%edi
  80102e:	72 06                	jb     801036 <__umoddi3+0xa6>
  801030:	75 0e                	jne    801040 <__umoddi3+0xb0>
  801032:	39 c6                	cmp    %eax,%esi
  801034:	73 0a                	jae    801040 <__umoddi3+0xb0>
  801036:	2b 44 24 08          	sub    0x8(%esp),%eax
  80103a:	19 ea                	sbb    %ebp,%edx
  80103c:	89 d7                	mov    %edx,%edi
  80103e:	89 c3                	mov    %eax,%ebx
  801040:	89 ca                	mov    %ecx,%edx
  801042:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801047:	29 de                	sub    %ebx,%esi
  801049:	19 fa                	sbb    %edi,%edx
  80104b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80104f:	89 d0                	mov    %edx,%eax
  801051:	d3 e0                	shl    %cl,%eax
  801053:	89 d9                	mov    %ebx,%ecx
  801055:	d3 ee                	shr    %cl,%esi
  801057:	d3 ea                	shr    %cl,%edx
  801059:	09 f0                	or     %esi,%eax
  80105b:	83 c4 1c             	add    $0x1c,%esp
  80105e:	5b                   	pop    %ebx
  80105f:	5e                   	pop    %esi
  801060:	5f                   	pop    %edi
  801061:	5d                   	pop    %ebp
  801062:	c3                   	ret    
  801063:	90                   	nop
  801064:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801068:	85 ff                	test   %edi,%edi
  80106a:	89 f9                	mov    %edi,%ecx
  80106c:	75 0b                	jne    801079 <__umoddi3+0xe9>
  80106e:	b8 01 00 00 00       	mov    $0x1,%eax
  801073:	31 d2                	xor    %edx,%edx
  801075:	f7 f7                	div    %edi
  801077:	89 c1                	mov    %eax,%ecx
  801079:	89 d8                	mov    %ebx,%eax
  80107b:	31 d2                	xor    %edx,%edx
  80107d:	f7 f1                	div    %ecx
  80107f:	89 f0                	mov    %esi,%eax
  801081:	f7 f1                	div    %ecx
  801083:	e9 31 ff ff ff       	jmp    800fb9 <__umoddi3+0x29>
  801088:	90                   	nop
  801089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801090:	39 dd                	cmp    %ebx,%ebp
  801092:	72 08                	jb     80109c <__umoddi3+0x10c>
  801094:	39 f7                	cmp    %esi,%edi
  801096:	0f 87 21 ff ff ff    	ja     800fbd <__umoddi3+0x2d>
  80109c:	89 da                	mov    %ebx,%edx
  80109e:	89 f0                	mov    %esi,%eax
  8010a0:	29 f8                	sub    %edi,%eax
  8010a2:	19 ea                	sbb    %ebp,%edx
  8010a4:	e9 14 ff ff ff       	jmp    800fbd <__umoddi3+0x2d>
