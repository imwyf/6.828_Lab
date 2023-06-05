
obj/user/breakpoint:     file format elf32-i386


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
  80003c:	57                   	push   %edi
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	83 ec 0c             	sub    $0xc,%esp
  800042:	e8 4d 00 00 00       	call   800094 <__x86.get_pc_thunk.bx>
  800047:	81 c3 b9 1f 00 00    	add    $0x1fb9,%ebx
  80004d:	8b 75 08             	mov    0x8(%ebp),%esi
  800050:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())]; // ENVX()得到id在Env[]数组中对应的下标
  800053:	e8 f3 00 00 00       	call   80014b <sys_getenvid>
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800060:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800066:	c7 c2 44 20 80 00    	mov    $0x802044,%edx
  80006c:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006e:	85 f6                	test   %esi,%esi
  800070:	7e 08                	jle    80007a <libmain+0x41>
		binaryname = argv[0];
  800072:	8b 07                	mov    (%edi),%eax
  800074:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80007a:	83 ec 08             	sub    $0x8,%esp
  80007d:	57                   	push   %edi
  80007e:	56                   	push   %esi
  80007f:	e8 af ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800084:	e8 0f 00 00 00       	call   800098 <exit>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80008f:	5b                   	pop    %ebx
  800090:	5e                   	pop    %esi
  800091:	5f                   	pop    %edi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <__x86.get_pc_thunk.bx>:
  800094:	8b 1c 24             	mov    (%esp),%ebx
  800097:	c3                   	ret    

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	53                   	push   %ebx
  80009c:	83 ec 10             	sub    $0x10,%esp
  80009f:	e8 f0 ff ff ff       	call   800094 <__x86.get_pc_thunk.bx>
  8000a4:	81 c3 5c 1f 00 00    	add    $0x1f5c,%ebx
	sys_env_destroy(0);
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 45 00 00 00       	call   8000f6 <sys_env_destroy>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b7:	c9                   	leave  
  8000b8:	c3                   	ret    

008000b9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	57                   	push   %edi
  8000bd:	56                   	push   %esi
  8000be:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ca:	89 c3                	mov    %eax,%ebx
  8000cc:	89 c7                	mov    %eax,%edi
  8000ce:	89 c6                	mov    %eax,%esi
  8000d0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e7:	89 d1                	mov    %edx,%ecx
  8000e9:	89 d3                	mov    %edx,%ebx
  8000eb:	89 d7                	mov    %edx,%edi
  8000ed:	89 d6                	mov    %edx,%esi
  8000ef:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f1:	5b                   	pop    %ebx
  8000f2:	5e                   	pop    %esi
  8000f3:	5f                   	pop    %edi
  8000f4:	5d                   	pop    %ebp
  8000f5:	c3                   	ret    

008000f6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f6:	55                   	push   %ebp
  8000f7:	89 e5                	mov    %esp,%ebp
  8000f9:	57                   	push   %edi
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	83 ec 1c             	sub    $0x1c,%esp
  8000ff:	e8 ac 02 00 00       	call   8003b0 <__x86.get_pc_thunk.ax>
  800104:	05 fc 1e 00 00       	add    $0x1efc,%eax
  800109:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80010c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800111:	8b 55 08             	mov    0x8(%ebp),%edx
  800114:	b8 03 00 00 00       	mov    $0x3,%eax
  800119:	89 cb                	mov    %ecx,%ebx
  80011b:	89 cf                	mov    %ecx,%edi
  80011d:	89 ce                	mov    %ecx,%esi
  80011f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800121:	85 c0                	test   %eax,%eax
  800123:	7f 08                	jg     80012d <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800125:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800128:	5b                   	pop    %ebx
  800129:	5e                   	pop    %esi
  80012a:	5f                   	pop    %edi
  80012b:	5d                   	pop    %ebp
  80012c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	50                   	push   %eax
  800131:	6a 03                	push   $0x3
  800133:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800136:	8d 83 a6 f0 ff ff    	lea    -0xf5a(%ebx),%eax
  80013c:	50                   	push   %eax
  80013d:	6a 23                	push   $0x23
  80013f:	8d 83 c3 f0 ff ff    	lea    -0xf3d(%ebx),%eax
  800145:	50                   	push   %eax
  800146:	e8 69 02 00 00       	call   8003b4 <_panic>

0080014b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 02 00 00 00       	mov    $0x2,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_yield>:

void
sys_yield(void)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800170:	ba 00 00 00 00       	mov    $0x0,%edx
  800175:	b8 0a 00 00 00       	mov    $0xa,%eax
  80017a:	89 d1                	mov    %edx,%ecx
  80017c:	89 d3                	mov    %edx,%ebx
  80017e:	89 d7                	mov    %edx,%edi
  800180:	89 d6                	mov    %edx,%esi
  800182:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800184:	5b                   	pop    %ebx
  800185:	5e                   	pop    %esi
  800186:	5f                   	pop    %edi
  800187:	5d                   	pop    %ebp
  800188:	c3                   	ret    

00800189 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	57                   	push   %edi
  80018d:	56                   	push   %esi
  80018e:	53                   	push   %ebx
  80018f:	83 ec 1c             	sub    $0x1c,%esp
  800192:	e8 19 02 00 00       	call   8003b0 <__x86.get_pc_thunk.ax>
  800197:	05 69 1e 00 00       	add    $0x1e69,%eax
  80019c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80019f:	be 00 00 00 00       	mov    $0x0,%esi
  8001a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	b8 04 00 00 00       	mov    $0x4,%eax
  8001af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b2:	89 f7                	mov    %esi,%edi
  8001b4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b6:	85 c0                	test   %eax,%eax
  8001b8:	7f 08                	jg     8001c2 <sys_page_alloc+0x39>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bd:	5b                   	pop    %ebx
  8001be:	5e                   	pop    %esi
  8001bf:	5f                   	pop    %edi
  8001c0:	5d                   	pop    %ebp
  8001c1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c2:	83 ec 0c             	sub    $0xc,%esp
  8001c5:	50                   	push   %eax
  8001c6:	6a 04                	push   $0x4
  8001c8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8001cb:	8d 83 a6 f0 ff ff    	lea    -0xf5a(%ebx),%eax
  8001d1:	50                   	push   %eax
  8001d2:	6a 23                	push   $0x23
  8001d4:	8d 83 c3 f0 ff ff    	lea    -0xf3d(%ebx),%eax
  8001da:	50                   	push   %eax
  8001db:	e8 d4 01 00 00       	call   8003b4 <_panic>

008001e0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 1c             	sub    $0x1c,%esp
  8001e9:	e8 c2 01 00 00       	call   8003b0 <__x86.get_pc_thunk.ax>
  8001ee:	05 12 1e 00 00       	add    $0x1e12,%eax
  8001f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8001f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fc:	b8 05 00 00 00       	mov    $0x5,%eax
  800201:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800204:	8b 7d 14             	mov    0x14(%ebp),%edi
  800207:	8b 75 18             	mov    0x18(%ebp),%esi
  80020a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7f 08                	jg     800218 <sys_page_map+0x38>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800210:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800213:	5b                   	pop    %ebx
  800214:	5e                   	pop    %esi
  800215:	5f                   	pop    %edi
  800216:	5d                   	pop    %ebp
  800217:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 05                	push   $0x5
  80021e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800221:	8d 83 a6 f0 ff ff    	lea    -0xf5a(%ebx),%eax
  800227:	50                   	push   %eax
  800228:	6a 23                	push   $0x23
  80022a:	8d 83 c3 f0 ff ff    	lea    -0xf3d(%ebx),%eax
  800230:	50                   	push   %eax
  800231:	e8 7e 01 00 00       	call   8003b4 <_panic>

00800236 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	57                   	push   %edi
  80023a:	56                   	push   %esi
  80023b:	53                   	push   %ebx
  80023c:	83 ec 1c             	sub    $0x1c,%esp
  80023f:	e8 6c 01 00 00       	call   8003b0 <__x86.get_pc_thunk.ax>
  800244:	05 bc 1d 00 00       	add    $0x1dbc,%eax
  800249:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80024c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800251:	8b 55 08             	mov    0x8(%ebp),%edx
  800254:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800257:	b8 06 00 00 00       	mov    $0x6,%eax
  80025c:	89 df                	mov    %ebx,%edi
  80025e:	89 de                	mov    %ebx,%esi
  800260:	cd 30                	int    $0x30
	if(check && ret > 0)
  800262:	85 c0                	test   %eax,%eax
  800264:	7f 08                	jg     80026e <sys_page_unmap+0x38>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800266:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800269:	5b                   	pop    %ebx
  80026a:	5e                   	pop    %esi
  80026b:	5f                   	pop    %edi
  80026c:	5d                   	pop    %ebp
  80026d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80026e:	83 ec 0c             	sub    $0xc,%esp
  800271:	50                   	push   %eax
  800272:	6a 06                	push   $0x6
  800274:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800277:	8d 83 a6 f0 ff ff    	lea    -0xf5a(%ebx),%eax
  80027d:	50                   	push   %eax
  80027e:	6a 23                	push   $0x23
  800280:	8d 83 c3 f0 ff ff    	lea    -0xf3d(%ebx),%eax
  800286:	50                   	push   %eax
  800287:	e8 28 01 00 00       	call   8003b4 <_panic>

0080028c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	57                   	push   %edi
  800290:	56                   	push   %esi
  800291:	53                   	push   %ebx
  800292:	83 ec 1c             	sub    $0x1c,%esp
  800295:	e8 16 01 00 00       	call   8003b0 <__x86.get_pc_thunk.ax>
  80029a:	05 66 1d 00 00       	add    $0x1d66,%eax
  80029f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8002a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ad:	b8 08 00 00 00       	mov    $0x8,%eax
  8002b2:	89 df                	mov    %ebx,%edi
  8002b4:	89 de                	mov    %ebx,%esi
  8002b6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002b8:	85 c0                	test   %eax,%eax
  8002ba:	7f 08                	jg     8002c4 <sys_env_set_status+0x38>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bf:	5b                   	pop    %ebx
  8002c0:	5e                   	pop    %esi
  8002c1:	5f                   	pop    %edi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c4:	83 ec 0c             	sub    $0xc,%esp
  8002c7:	50                   	push   %eax
  8002c8:	6a 08                	push   $0x8
  8002ca:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002cd:	8d 83 a6 f0 ff ff    	lea    -0xf5a(%ebx),%eax
  8002d3:	50                   	push   %eax
  8002d4:	6a 23                	push   $0x23
  8002d6:	8d 83 c3 f0 ff ff    	lea    -0xf3d(%ebx),%eax
  8002dc:	50                   	push   %eax
  8002dd:	e8 d2 00 00 00       	call   8003b4 <_panic>

008002e2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
  8002e8:	83 ec 1c             	sub    $0x1c,%esp
  8002eb:	e8 c0 00 00 00       	call   8003b0 <__x86.get_pc_thunk.ax>
  8002f0:	05 10 1d 00 00       	add    $0x1d10,%eax
  8002f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8002f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	b8 09 00 00 00       	mov    $0x9,%eax
  800308:	89 df                	mov    %ebx,%edi
  80030a:	89 de                	mov    %ebx,%esi
  80030c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80030e:	85 c0                	test   %eax,%eax
  800310:	7f 08                	jg     80031a <sys_env_set_pgfault_upcall+0x38>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800312:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80031a:	83 ec 0c             	sub    $0xc,%esp
  80031d:	50                   	push   %eax
  80031e:	6a 09                	push   $0x9
  800320:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800323:	8d 83 a6 f0 ff ff    	lea    -0xf5a(%ebx),%eax
  800329:	50                   	push   %eax
  80032a:	6a 23                	push   $0x23
  80032c:	8d 83 c3 f0 ff ff    	lea    -0xf3d(%ebx),%eax
  800332:	50                   	push   %eax
  800333:	e8 7c 00 00 00       	call   8003b4 <_panic>

00800338 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	57                   	push   %edi
  80033c:	56                   	push   %esi
  80033d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80033e:	8b 55 08             	mov    0x8(%ebp),%edx
  800341:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800344:	b8 0b 00 00 00       	mov    $0xb,%eax
  800349:	be 00 00 00 00       	mov    $0x0,%esi
  80034e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800351:	8b 7d 14             	mov    0x14(%ebp),%edi
  800354:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	57                   	push   %edi
  80035f:	56                   	push   %esi
  800360:	53                   	push   %ebx
  800361:	83 ec 1c             	sub    $0x1c,%esp
  800364:	e8 47 00 00 00       	call   8003b0 <__x86.get_pc_thunk.ax>
  800369:	05 97 1c 00 00       	add    $0x1c97,%eax
  80036e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800371:	b9 00 00 00 00       	mov    $0x0,%ecx
  800376:	8b 55 08             	mov    0x8(%ebp),%edx
  800379:	b8 0c 00 00 00       	mov    $0xc,%eax
  80037e:	89 cb                	mov    %ecx,%ebx
  800380:	89 cf                	mov    %ecx,%edi
  800382:	89 ce                	mov    %ecx,%esi
  800384:	cd 30                	int    $0x30
	if(check && ret > 0)
  800386:	85 c0                	test   %eax,%eax
  800388:	7f 08                	jg     800392 <sys_ipc_recv+0x37>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80038a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80038d:	5b                   	pop    %ebx
  80038e:	5e                   	pop    %esi
  80038f:	5f                   	pop    %edi
  800390:	5d                   	pop    %ebp
  800391:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800392:	83 ec 0c             	sub    $0xc,%esp
  800395:	50                   	push   %eax
  800396:	6a 0c                	push   $0xc
  800398:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80039b:	8d 83 a6 f0 ff ff    	lea    -0xf5a(%ebx),%eax
  8003a1:	50                   	push   %eax
  8003a2:	6a 23                	push   $0x23
  8003a4:	8d 83 c3 f0 ff ff    	lea    -0xf3d(%ebx),%eax
  8003aa:	50                   	push   %eax
  8003ab:	e8 04 00 00 00       	call   8003b4 <_panic>

008003b0 <__x86.get_pc_thunk.ax>:
  8003b0:	8b 04 24             	mov    (%esp),%eax
  8003b3:	c3                   	ret    

008003b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	57                   	push   %edi
  8003b8:	56                   	push   %esi
  8003b9:	53                   	push   %ebx
  8003ba:	83 ec 0c             	sub    $0xc,%esp
  8003bd:	e8 d2 fc ff ff       	call   800094 <__x86.get_pc_thunk.bx>
  8003c2:	81 c3 3e 1c 00 00    	add    $0x1c3e,%ebx
	va_list ap;

	va_start(ap, fmt);
  8003c8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003cb:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  8003d1:	8b 38                	mov    (%eax),%edi
  8003d3:	e8 73 fd ff ff       	call   80014b <sys_getenvid>
  8003d8:	83 ec 0c             	sub    $0xc,%esp
  8003db:	ff 75 0c             	pushl  0xc(%ebp)
  8003de:	ff 75 08             	pushl  0x8(%ebp)
  8003e1:	57                   	push   %edi
  8003e2:	50                   	push   %eax
  8003e3:	8d 83 d4 f0 ff ff    	lea    -0xf2c(%ebx),%eax
  8003e9:	50                   	push   %eax
  8003ea:	e8 d1 00 00 00       	call   8004c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003ef:	83 c4 18             	add    $0x18,%esp
  8003f2:	56                   	push   %esi
  8003f3:	ff 75 10             	pushl  0x10(%ebp)
  8003f6:	e8 63 00 00 00       	call   80045e <vcprintf>
	cprintf("\n");
  8003fb:	8d 83 f8 f0 ff ff    	lea    -0xf08(%ebx),%eax
  800401:	89 04 24             	mov    %eax,(%esp)
  800404:	e8 b7 00 00 00       	call   8004c0 <cprintf>
  800409:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80040c:	cc                   	int3   
  80040d:	eb fd                	jmp    80040c <_panic+0x58>

0080040f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80040f:	55                   	push   %ebp
  800410:	89 e5                	mov    %esp,%ebp
  800412:	56                   	push   %esi
  800413:	53                   	push   %ebx
  800414:	e8 7b fc ff ff       	call   800094 <__x86.get_pc_thunk.bx>
  800419:	81 c3 e7 1b 00 00    	add    $0x1be7,%ebx
  80041f:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  800422:	8b 16                	mov    (%esi),%edx
  800424:	8d 42 01             	lea    0x1(%edx),%eax
  800427:	89 06                	mov    %eax,(%esi)
  800429:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042c:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800430:	3d ff 00 00 00       	cmp    $0xff,%eax
  800435:	74 0b                	je     800442 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800437:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80043b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80043e:	5b                   	pop    %ebx
  80043f:	5e                   	pop    %esi
  800440:	5d                   	pop    %ebp
  800441:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	68 ff 00 00 00       	push   $0xff
  80044a:	8d 46 08             	lea    0x8(%esi),%eax
  80044d:	50                   	push   %eax
  80044e:	e8 66 fc ff ff       	call   8000b9 <sys_cputs>
		b->idx = 0;
  800453:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	eb d9                	jmp    800437 <putch+0x28>

0080045e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80045e:	55                   	push   %ebp
  80045f:	89 e5                	mov    %esp,%ebp
  800461:	53                   	push   %ebx
  800462:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800468:	e8 27 fc ff ff       	call   800094 <__x86.get_pc_thunk.bx>
  80046d:	81 c3 93 1b 00 00    	add    $0x1b93,%ebx
	struct printbuf b;

	b.idx = 0;
  800473:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80047a:	00 00 00 
	b.cnt = 0;
  80047d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800484:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800487:	ff 75 0c             	pushl  0xc(%ebp)
  80048a:	ff 75 08             	pushl  0x8(%ebp)
  80048d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800493:	50                   	push   %eax
  800494:	8d 83 0f e4 ff ff    	lea    -0x1bf1(%ebx),%eax
  80049a:	50                   	push   %eax
  80049b:	e8 38 01 00 00       	call   8005d8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004a0:	83 c4 08             	add    $0x8,%esp
  8004a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004af:	50                   	push   %eax
  8004b0:	e8 04 fc ff ff       	call   8000b9 <sys_cputs>

	return b.cnt;
}
  8004b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004be:	c9                   	leave  
  8004bf:	c3                   	ret    

008004c0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004c6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004c9:	50                   	push   %eax
  8004ca:	ff 75 08             	pushl  0x8(%ebp)
  8004cd:	e8 8c ff ff ff       	call   80045e <vcprintf>
	va_end(ap);

	return cnt;
}
  8004d2:	c9                   	leave  
  8004d3:	c3                   	ret    

008004d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
  8004d7:	57                   	push   %edi
  8004d8:	56                   	push   %esi
  8004d9:	53                   	push   %ebx
  8004da:	83 ec 2c             	sub    $0x2c,%esp
  8004dd:	e8 02 06 00 00       	call   800ae4 <__x86.get_pc_thunk.cx>
  8004e2:	81 c1 1e 1b 00 00    	add    $0x1b1e,%ecx
  8004e8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8004eb:	89 c7                	mov    %eax,%edi
  8004ed:	89 d6                	mov    %edx,%esi
  8004ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004f8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  8004fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8004fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800503:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800506:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800509:	39 d3                	cmp    %edx,%ebx
  80050b:	72 09                	jb     800516 <printnum+0x42>
  80050d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800510:	0f 87 83 00 00 00    	ja     800599 <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800516:	83 ec 0c             	sub    $0xc,%esp
  800519:	ff 75 18             	pushl  0x18(%ebp)
  80051c:	8b 45 14             	mov    0x14(%ebp),%eax
  80051f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800522:	53                   	push   %ebx
  800523:	ff 75 10             	pushl  0x10(%ebp)
  800526:	83 ec 08             	sub    $0x8,%esp
  800529:	ff 75 dc             	pushl  -0x24(%ebp)
  80052c:	ff 75 d8             	pushl  -0x28(%ebp)
  80052f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800532:	ff 75 d0             	pushl  -0x30(%ebp)
  800535:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800538:	e8 23 09 00 00       	call   800e60 <__udivdi3>
  80053d:	83 c4 18             	add    $0x18,%esp
  800540:	52                   	push   %edx
  800541:	50                   	push   %eax
  800542:	89 f2                	mov    %esi,%edx
  800544:	89 f8                	mov    %edi,%eax
  800546:	e8 89 ff ff ff       	call   8004d4 <printnum>
  80054b:	83 c4 20             	add    $0x20,%esp
  80054e:	eb 13                	jmp    800563 <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	56                   	push   %esi
  800554:	ff 75 18             	pushl  0x18(%ebp)
  800557:	ff d7                	call   *%edi
  800559:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80055c:	83 eb 01             	sub    $0x1,%ebx
  80055f:	85 db                	test   %ebx,%ebx
  800561:	7f ed                	jg     800550 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	56                   	push   %esi
  800567:	83 ec 04             	sub    $0x4,%esp
  80056a:	ff 75 dc             	pushl  -0x24(%ebp)
  80056d:	ff 75 d8             	pushl  -0x28(%ebp)
  800570:	ff 75 d4             	pushl  -0x2c(%ebp)
  800573:	ff 75 d0             	pushl  -0x30(%ebp)
  800576:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800579:	89 f3                	mov    %esi,%ebx
  80057b:	e8 00 0a 00 00       	call   800f80 <__umoddi3>
  800580:	83 c4 14             	add    $0x14,%esp
  800583:	0f be 84 06 fa f0 ff 	movsbl -0xf06(%esi,%eax,1),%eax
  80058a:	ff 
  80058b:	50                   	push   %eax
  80058c:	ff d7                	call   *%edi
}
  80058e:	83 c4 10             	add    $0x10,%esp
  800591:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800594:	5b                   	pop    %ebx
  800595:	5e                   	pop    %esi
  800596:	5f                   	pop    %edi
  800597:	5d                   	pop    %ebp
  800598:	c3                   	ret    
  800599:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80059c:	eb be                	jmp    80055c <printnum+0x88>

0080059e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80059e:	55                   	push   %ebp
  80059f:	89 e5                	mov    %esp,%ebp
  8005a1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005a4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005a8:	8b 10                	mov    (%eax),%edx
  8005aa:	3b 50 04             	cmp    0x4(%eax),%edx
  8005ad:	73 0a                	jae    8005b9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005af:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005b2:	89 08                	mov    %ecx,(%eax)
  8005b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b7:	88 02                	mov    %al,(%edx)
}
  8005b9:	5d                   	pop    %ebp
  8005ba:	c3                   	ret    

008005bb <printfmt>:
{
  8005bb:	55                   	push   %ebp
  8005bc:	89 e5                	mov    %esp,%ebp
  8005be:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8005c1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005c4:	50                   	push   %eax
  8005c5:	ff 75 10             	pushl  0x10(%ebp)
  8005c8:	ff 75 0c             	pushl  0xc(%ebp)
  8005cb:	ff 75 08             	pushl  0x8(%ebp)
  8005ce:	e8 05 00 00 00       	call   8005d8 <vprintfmt>
}
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	c9                   	leave  
  8005d7:	c3                   	ret    

008005d8 <vprintfmt>:
{
  8005d8:	55                   	push   %ebp
  8005d9:	89 e5                	mov    %esp,%ebp
  8005db:	57                   	push   %edi
  8005dc:	56                   	push   %esi
  8005dd:	53                   	push   %ebx
  8005de:	83 ec 2c             	sub    $0x2c,%esp
  8005e1:	e8 ae fa ff ff       	call   800094 <__x86.get_pc_thunk.bx>
  8005e6:	81 c3 1a 1a 00 00    	add    $0x1a1a,%ebx
  8005ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005ef:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005f2:	e9 c3 03 00 00       	jmp    8009ba <.L35+0x48>
		padc = ' ';
  8005f7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8005fb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800602:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  800609:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800610:	b9 00 00 00 00       	mov    $0x0,%ecx
  800615:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800618:	8d 47 01             	lea    0x1(%edi),%eax
  80061b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80061e:	0f b6 17             	movzbl (%edi),%edx
  800621:	8d 42 dd             	lea    -0x23(%edx),%eax
  800624:	3c 55                	cmp    $0x55,%al
  800626:	0f 87 16 04 00 00    	ja     800a42 <.L22>
  80062c:	0f b6 c0             	movzbl %al,%eax
  80062f:	89 d9                	mov    %ebx,%ecx
  800631:	03 8c 83 b4 f1 ff ff 	add    -0xe4c(%ebx,%eax,4),%ecx
  800638:	ff e1                	jmp    *%ecx

0080063a <.L69>:
  80063a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80063d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800641:	eb d5                	jmp    800618 <vprintfmt+0x40>

00800643 <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800643:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800646:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80064a:	eb cc                	jmp    800618 <vprintfmt+0x40>

0080064c <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80064c:	0f b6 d2             	movzbl %dl,%edx
  80064f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
  800652:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800657:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80065a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80065e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800661:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800664:	83 f9 09             	cmp    $0x9,%ecx
  800667:	77 55                	ja     8006be <.L23+0xf>
			for (precision = 0;; ++fmt)
  800669:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80066c:	eb e9                	jmp    800657 <.L29+0xb>

0080066e <.L26>:
			precision = va_arg(ap, int);
  80066e:	8b 45 14             	mov    0x14(%ebp),%eax
  800671:	8b 00                	mov    (%eax),%eax
  800673:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8d 40 04             	lea    0x4(%eax),%eax
  80067c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80067f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800682:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800686:	79 90                	jns    800618 <vprintfmt+0x40>
				width = precision, precision = -1;
  800688:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80068b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80068e:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800695:	eb 81                	jmp    800618 <vprintfmt+0x40>

00800697 <.L27>:
  800697:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80069a:	85 c0                	test   %eax,%eax
  80069c:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a1:	0f 49 d0             	cmovns %eax,%edx
  8006a4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006aa:	e9 69 ff ff ff       	jmp    800618 <vprintfmt+0x40>

008006af <.L23>:
  8006af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8006b2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006b9:	e9 5a ff ff ff       	jmp    800618 <vprintfmt+0x40>
  8006be:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006c1:	eb bf                	jmp    800682 <.L26+0x14>

008006c3 <.L33>:
			lflag++;
  8006c3:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8006ca:	e9 49 ff ff ff       	jmp    800618 <vprintfmt+0x40>

008006cf <.L30>:
			putch(va_arg(ap, int), putdat);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8d 78 04             	lea    0x4(%eax),%edi
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	56                   	push   %esi
  8006d9:	ff 30                	pushl  (%eax)
  8006db:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006de:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8006e1:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8006e4:	e9 ce 02 00 00       	jmp    8009b7 <.L35+0x45>

008006e9 <.L32>:
			err = va_arg(ap, int);
  8006e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ec:	8d 78 04             	lea    0x4(%eax),%edi
  8006ef:	8b 00                	mov    (%eax),%eax
  8006f1:	99                   	cltd   
  8006f2:	31 d0                	xor    %edx,%eax
  8006f4:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006f6:	83 f8 08             	cmp    $0x8,%eax
  8006f9:	7f 27                	jg     800722 <.L32+0x39>
  8006fb:	8b 94 83 20 00 00 00 	mov    0x20(%ebx,%eax,4),%edx
  800702:	85 d2                	test   %edx,%edx
  800704:	74 1c                	je     800722 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  800706:	52                   	push   %edx
  800707:	8d 83 1b f1 ff ff    	lea    -0xee5(%ebx),%eax
  80070d:	50                   	push   %eax
  80070e:	56                   	push   %esi
  80070f:	ff 75 08             	pushl  0x8(%ebp)
  800712:	e8 a4 fe ff ff       	call   8005bb <printfmt>
  800717:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80071a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80071d:	e9 95 02 00 00       	jmp    8009b7 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  800722:	50                   	push   %eax
  800723:	8d 83 12 f1 ff ff    	lea    -0xeee(%ebx),%eax
  800729:	50                   	push   %eax
  80072a:	56                   	push   %esi
  80072b:	ff 75 08             	pushl  0x8(%ebp)
  80072e:	e8 88 fe ff ff       	call   8005bb <printfmt>
  800733:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800736:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800739:	e9 79 02 00 00       	jmp    8009b7 <.L35+0x45>

0080073e <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  80073e:	8b 45 14             	mov    0x14(%ebp),%eax
  800741:	83 c0 04             	add    $0x4,%eax
  800744:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80074c:	85 ff                	test   %edi,%edi
  80074e:	8d 83 0b f1 ff ff    	lea    -0xef5(%ebx),%eax
  800754:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800757:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80075b:	0f 8e b5 00 00 00    	jle    800816 <.L36+0xd8>
  800761:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800765:	75 08                	jne    80076f <.L36+0x31>
  800767:	89 75 0c             	mov    %esi,0xc(%ebp)
  80076a:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80076d:	eb 6d                	jmp    8007dc <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  80076f:	83 ec 08             	sub    $0x8,%esp
  800772:	ff 75 cc             	pushl  -0x34(%ebp)
  800775:	57                   	push   %edi
  800776:	e8 85 03 00 00       	call   800b00 <strnlen>
  80077b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80077e:	29 c2                	sub    %eax,%edx
  800780:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800783:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800786:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80078a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80078d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800790:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800792:	eb 10                	jmp    8007a4 <.L36+0x66>
					putch(padc, putdat);
  800794:	83 ec 08             	sub    $0x8,%esp
  800797:	56                   	push   %esi
  800798:	ff 75 e0             	pushl  -0x20(%ebp)
  80079b:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80079e:	83 ef 01             	sub    $0x1,%edi
  8007a1:	83 c4 10             	add    $0x10,%esp
  8007a4:	85 ff                	test   %edi,%edi
  8007a6:	7f ec                	jg     800794 <.L36+0x56>
  8007a8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007ab:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8007ae:	85 d2                	test   %edx,%edx
  8007b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b5:	0f 49 c2             	cmovns %edx,%eax
  8007b8:	29 c2                	sub    %eax,%edx
  8007ba:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8007bd:	89 75 0c             	mov    %esi,0xc(%ebp)
  8007c0:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8007c3:	eb 17                	jmp    8007dc <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  8007c5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007c9:	75 30                	jne    8007fb <.L36+0xbd>
					putch(ch, putdat);
  8007cb:	83 ec 08             	sub    $0x8,%esp
  8007ce:	ff 75 0c             	pushl  0xc(%ebp)
  8007d1:	50                   	push   %eax
  8007d2:	ff 55 08             	call   *0x8(%ebp)
  8007d5:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007d8:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8007dc:	83 c7 01             	add    $0x1,%edi
  8007df:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8007e3:	0f be c2             	movsbl %dl,%eax
  8007e6:	85 c0                	test   %eax,%eax
  8007e8:	74 52                	je     80083c <.L36+0xfe>
  8007ea:	85 f6                	test   %esi,%esi
  8007ec:	78 d7                	js     8007c5 <.L36+0x87>
  8007ee:	83 ee 01             	sub    $0x1,%esi
  8007f1:	79 d2                	jns    8007c5 <.L36+0x87>
  8007f3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8007f6:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8007f9:	eb 32                	jmp    80082d <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8007fb:	0f be d2             	movsbl %dl,%edx
  8007fe:	83 ea 20             	sub    $0x20,%edx
  800801:	83 fa 5e             	cmp    $0x5e,%edx
  800804:	76 c5                	jbe    8007cb <.L36+0x8d>
					putch('?', putdat);
  800806:	83 ec 08             	sub    $0x8,%esp
  800809:	ff 75 0c             	pushl  0xc(%ebp)
  80080c:	6a 3f                	push   $0x3f
  80080e:	ff 55 08             	call   *0x8(%ebp)
  800811:	83 c4 10             	add    $0x10,%esp
  800814:	eb c2                	jmp    8007d8 <.L36+0x9a>
  800816:	89 75 0c             	mov    %esi,0xc(%ebp)
  800819:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80081c:	eb be                	jmp    8007dc <.L36+0x9e>
				putch(' ', putdat);
  80081e:	83 ec 08             	sub    $0x8,%esp
  800821:	56                   	push   %esi
  800822:	6a 20                	push   $0x20
  800824:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800827:	83 ef 01             	sub    $0x1,%edi
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	85 ff                	test   %edi,%edi
  80082f:	7f ed                	jg     80081e <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800831:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800834:	89 45 14             	mov    %eax,0x14(%ebp)
  800837:	e9 7b 01 00 00       	jmp    8009b7 <.L35+0x45>
  80083c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80083f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800842:	eb e9                	jmp    80082d <.L36+0xef>

00800844 <.L31>:
  800844:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800847:	83 f9 01             	cmp    $0x1,%ecx
  80084a:	7e 40                	jle    80088c <.L31+0x48>
		return va_arg(*ap, long long);
  80084c:	8b 45 14             	mov    0x14(%ebp),%eax
  80084f:	8b 50 04             	mov    0x4(%eax),%edx
  800852:	8b 00                	mov    (%eax),%eax
  800854:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800857:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80085a:	8b 45 14             	mov    0x14(%ebp),%eax
  80085d:	8d 40 08             	lea    0x8(%eax),%eax
  800860:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
  800863:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800867:	79 55                	jns    8008be <.L31+0x7a>
				putch('-', putdat);
  800869:	83 ec 08             	sub    $0x8,%esp
  80086c:	56                   	push   %esi
  80086d:	6a 2d                	push   $0x2d
  80086f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  800872:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800875:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800878:	f7 da                	neg    %edx
  80087a:	83 d1 00             	adc    $0x0,%ecx
  80087d:	f7 d9                	neg    %ecx
  80087f:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
  800882:	b8 0a 00 00 00       	mov    $0xa,%eax
  800887:	e9 10 01 00 00       	jmp    80099c <.L35+0x2a>
	else if (lflag)
  80088c:	85 c9                	test   %ecx,%ecx
  80088e:	75 17                	jne    8008a7 <.L31+0x63>
		return va_arg(*ap, int);
  800890:	8b 45 14             	mov    0x14(%ebp),%eax
  800893:	8b 00                	mov    (%eax),%eax
  800895:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800898:	99                   	cltd   
  800899:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80089c:	8b 45 14             	mov    0x14(%ebp),%eax
  80089f:	8d 40 04             	lea    0x4(%eax),%eax
  8008a2:	89 45 14             	mov    %eax,0x14(%ebp)
  8008a5:	eb bc                	jmp    800863 <.L31+0x1f>
		return va_arg(*ap, long);
  8008a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008aa:	8b 00                	mov    (%eax),%eax
  8008ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008af:	99                   	cltd   
  8008b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b6:	8d 40 04             	lea    0x4(%eax),%eax
  8008b9:	89 45 14             	mov    %eax,0x14(%ebp)
  8008bc:	eb a5                	jmp    800863 <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  8008be:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008c1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
  8008c4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008c9:	e9 ce 00 00 00       	jmp    80099c <.L35+0x2a>

008008ce <.L37>:
  8008ce:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8008d1:	83 f9 01             	cmp    $0x1,%ecx
  8008d4:	7e 18                	jle    8008ee <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8008d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d9:	8b 10                	mov    (%eax),%edx
  8008db:	8b 48 04             	mov    0x4(%eax),%ecx
  8008de:	8d 40 08             	lea    0x8(%eax),%eax
  8008e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8008e4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008e9:	e9 ae 00 00 00       	jmp    80099c <.L35+0x2a>
	else if (lflag)
  8008ee:	85 c9                	test   %ecx,%ecx
  8008f0:	75 1a                	jne    80090c <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8008f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f5:	8b 10                	mov    (%eax),%edx
  8008f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008fc:	8d 40 04             	lea    0x4(%eax),%eax
  8008ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800902:	b8 0a 00 00 00       	mov    $0xa,%eax
  800907:	e9 90 00 00 00       	jmp    80099c <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  80090c:	8b 45 14             	mov    0x14(%ebp),%eax
  80090f:	8b 10                	mov    (%eax),%edx
  800911:	b9 00 00 00 00       	mov    $0x0,%ecx
  800916:	8d 40 04             	lea    0x4(%eax),%eax
  800919:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80091c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800921:	eb 79                	jmp    80099c <.L35+0x2a>

00800923 <.L34>:
  800923:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800926:	83 f9 01             	cmp    $0x1,%ecx
  800929:	7e 15                	jle    800940 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  80092b:	8b 45 14             	mov    0x14(%ebp),%eax
  80092e:	8b 10                	mov    (%eax),%edx
  800930:	8b 48 04             	mov    0x4(%eax),%ecx
  800933:	8d 40 08             	lea    0x8(%eax),%eax
  800936:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800939:	b8 08 00 00 00       	mov    $0x8,%eax
  80093e:	eb 5c                	jmp    80099c <.L35+0x2a>
	else if (lflag)
  800940:	85 c9                	test   %ecx,%ecx
  800942:	75 17                	jne    80095b <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800944:	8b 45 14             	mov    0x14(%ebp),%eax
  800947:	8b 10                	mov    (%eax),%edx
  800949:	b9 00 00 00 00       	mov    $0x0,%ecx
  80094e:	8d 40 04             	lea    0x4(%eax),%eax
  800951:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800954:	b8 08 00 00 00       	mov    $0x8,%eax
  800959:	eb 41                	jmp    80099c <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  80095b:	8b 45 14             	mov    0x14(%ebp),%eax
  80095e:	8b 10                	mov    (%eax),%edx
  800960:	b9 00 00 00 00       	mov    $0x0,%ecx
  800965:	8d 40 04             	lea    0x4(%eax),%eax
  800968:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80096b:	b8 08 00 00 00       	mov    $0x8,%eax
  800970:	eb 2a                	jmp    80099c <.L35+0x2a>

00800972 <.L35>:
			putch('0', putdat);
  800972:	83 ec 08             	sub    $0x8,%esp
  800975:	56                   	push   %esi
  800976:	6a 30                	push   $0x30
  800978:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80097b:	83 c4 08             	add    $0x8,%esp
  80097e:	56                   	push   %esi
  80097f:	6a 78                	push   $0x78
  800981:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800984:	8b 45 14             	mov    0x14(%ebp),%eax
  800987:	8b 10                	mov    (%eax),%edx
  800989:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80098e:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800991:	8d 40 04             	lea    0x4(%eax),%eax
  800994:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800997:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  80099c:	83 ec 0c             	sub    $0xc,%esp
  80099f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8009a3:	57                   	push   %edi
  8009a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8009a7:	50                   	push   %eax
  8009a8:	51                   	push   %ecx
  8009a9:	52                   	push   %edx
  8009aa:	89 f2                	mov    %esi,%edx
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	e8 20 fb ff ff       	call   8004d4 <printnum>
			break;
  8009b4:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8009b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  8009ba:	83 c7 01             	add    $0x1,%edi
  8009bd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8009c1:	83 f8 25             	cmp    $0x25,%eax
  8009c4:	0f 84 2d fc ff ff    	je     8005f7 <vprintfmt+0x1f>
			if (ch == '\0')
  8009ca:	85 c0                	test   %eax,%eax
  8009cc:	0f 84 91 00 00 00    	je     800a63 <.L22+0x21>
			putch(ch, putdat);
  8009d2:	83 ec 08             	sub    $0x8,%esp
  8009d5:	56                   	push   %esi
  8009d6:	50                   	push   %eax
  8009d7:	ff 55 08             	call   *0x8(%ebp)
  8009da:	83 c4 10             	add    $0x10,%esp
  8009dd:	eb db                	jmp    8009ba <.L35+0x48>

008009df <.L38>:
  8009df:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8009e2:	83 f9 01             	cmp    $0x1,%ecx
  8009e5:	7e 15                	jle    8009fc <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8009e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ea:	8b 10                	mov    (%eax),%edx
  8009ec:	8b 48 04             	mov    0x4(%eax),%ecx
  8009ef:	8d 40 08             	lea    0x8(%eax),%eax
  8009f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009f5:	b8 10 00 00 00       	mov    $0x10,%eax
  8009fa:	eb a0                	jmp    80099c <.L35+0x2a>
	else if (lflag)
  8009fc:	85 c9                	test   %ecx,%ecx
  8009fe:	75 17                	jne    800a17 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  800a00:	8b 45 14             	mov    0x14(%ebp),%eax
  800a03:	8b 10                	mov    (%eax),%edx
  800a05:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a0a:	8d 40 04             	lea    0x4(%eax),%eax
  800a0d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a10:	b8 10 00 00 00       	mov    $0x10,%eax
  800a15:	eb 85                	jmp    80099c <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800a17:	8b 45 14             	mov    0x14(%ebp),%eax
  800a1a:	8b 10                	mov    (%eax),%edx
  800a1c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a21:	8d 40 04             	lea    0x4(%eax),%eax
  800a24:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a27:	b8 10 00 00 00       	mov    $0x10,%eax
  800a2c:	e9 6b ff ff ff       	jmp    80099c <.L35+0x2a>

00800a31 <.L25>:
			putch(ch, putdat);
  800a31:	83 ec 08             	sub    $0x8,%esp
  800a34:	56                   	push   %esi
  800a35:	6a 25                	push   $0x25
  800a37:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a3a:	83 c4 10             	add    $0x10,%esp
  800a3d:	e9 75 ff ff ff       	jmp    8009b7 <.L35+0x45>

00800a42 <.L22>:
			putch('%', putdat);
  800a42:	83 ec 08             	sub    $0x8,%esp
  800a45:	56                   	push   %esi
  800a46:	6a 25                	push   $0x25
  800a48:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a4b:	83 c4 10             	add    $0x10,%esp
  800a4e:	89 f8                	mov    %edi,%eax
  800a50:	eb 03                	jmp    800a55 <.L22+0x13>
  800a52:	83 e8 01             	sub    $0x1,%eax
  800a55:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800a59:	75 f7                	jne    800a52 <.L22+0x10>
  800a5b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a5e:	e9 54 ff ff ff       	jmp    8009b7 <.L35+0x45>
}
  800a63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a66:	5b                   	pop    %ebx
  800a67:	5e                   	pop    %esi
  800a68:	5f                   	pop    %edi
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	53                   	push   %ebx
  800a6f:	83 ec 14             	sub    $0x14,%esp
  800a72:	e8 1d f6 ff ff       	call   800094 <__x86.get_pc_thunk.bx>
  800a77:	81 c3 89 15 00 00    	add    $0x1589,%ebx
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  800a83:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a86:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a8a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a94:	85 c0                	test   %eax,%eax
  800a96:	74 2b                	je     800ac3 <vsnprintf+0x58>
  800a98:	85 d2                	test   %edx,%edx
  800a9a:	7e 27                	jle    800ac3 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  800a9c:	ff 75 14             	pushl  0x14(%ebp)
  800a9f:	ff 75 10             	pushl  0x10(%ebp)
  800aa2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800aa5:	50                   	push   %eax
  800aa6:	8d 83 9e e5 ff ff    	lea    -0x1a62(%ebx),%eax
  800aac:	50                   	push   %eax
  800aad:	e8 26 fb ff ff       	call   8005d8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ab2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ab5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800abb:	83 c4 10             	add    $0x10,%esp
}
  800abe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac1:	c9                   	leave  
  800ac2:	c3                   	ret    
		return -E_INVAL;
  800ac3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ac8:	eb f4                	jmp    800abe <vsnprintf+0x53>

00800aca <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ad0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ad3:	50                   	push   %eax
  800ad4:	ff 75 10             	pushl  0x10(%ebp)
  800ad7:	ff 75 0c             	pushl  0xc(%ebp)
  800ada:	ff 75 08             	pushl  0x8(%ebp)
  800add:	e8 89 ff ff ff       	call   800a6b <vsnprintf>
	va_end(ap);

	return rc;
}
  800ae2:	c9                   	leave  
  800ae3:	c3                   	ret    

00800ae4 <__x86.get_pc_thunk.cx>:
  800ae4:	8b 0c 24             	mov    (%esp),%ecx
  800ae7:	c3                   	ret    

00800ae8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800aee:	b8 00 00 00 00       	mov    $0x0,%eax
  800af3:	eb 03                	jmp    800af8 <strlen+0x10>
		n++;
  800af5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800af8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800afc:	75 f7                	jne    800af5 <strlen+0xd>
	return n;
}
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b06:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b09:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0e:	eb 03                	jmp    800b13 <strnlen+0x13>
		n++;
  800b10:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b13:	39 d0                	cmp    %edx,%eax
  800b15:	74 06                	je     800b1d <strnlen+0x1d>
  800b17:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b1b:	75 f3                	jne    800b10 <strnlen+0x10>
	return n;
}
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	53                   	push   %ebx
  800b23:	8b 45 08             	mov    0x8(%ebp),%eax
  800b26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b29:	89 c2                	mov    %eax,%edx
  800b2b:	83 c1 01             	add    $0x1,%ecx
  800b2e:	83 c2 01             	add    $0x1,%edx
  800b31:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b35:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b38:	84 db                	test   %bl,%bl
  800b3a:	75 ef                	jne    800b2b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b3c:	5b                   	pop    %ebx
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	53                   	push   %ebx
  800b43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b46:	53                   	push   %ebx
  800b47:	e8 9c ff ff ff       	call   800ae8 <strlen>
  800b4c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b4f:	ff 75 0c             	pushl  0xc(%ebp)
  800b52:	01 d8                	add    %ebx,%eax
  800b54:	50                   	push   %eax
  800b55:	e8 c5 ff ff ff       	call   800b1f <strcpy>
	return dst;
}
  800b5a:	89 d8                	mov    %ebx,%eax
  800b5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b5f:	c9                   	leave  
  800b60:	c3                   	ret    

00800b61 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
  800b66:	8b 75 08             	mov    0x8(%ebp),%esi
  800b69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6c:	89 f3                	mov    %esi,%ebx
  800b6e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b71:	89 f2                	mov    %esi,%edx
  800b73:	eb 0f                	jmp    800b84 <strncpy+0x23>
		*dst++ = *src;
  800b75:	83 c2 01             	add    $0x1,%edx
  800b78:	0f b6 01             	movzbl (%ecx),%eax
  800b7b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b7e:	80 39 01             	cmpb   $0x1,(%ecx)
  800b81:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800b84:	39 da                	cmp    %ebx,%edx
  800b86:	75 ed                	jne    800b75 <strncpy+0x14>
	}
	return ret;
}
  800b88:	89 f0                	mov    %esi,%eax
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    

00800b8e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
  800b93:	8b 75 08             	mov    0x8(%ebp),%esi
  800b96:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b99:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b9c:	89 f0                	mov    %esi,%eax
  800b9e:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ba2:	85 c9                	test   %ecx,%ecx
  800ba4:	75 0b                	jne    800bb1 <strlcpy+0x23>
  800ba6:	eb 17                	jmp    800bbf <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ba8:	83 c2 01             	add    $0x1,%edx
  800bab:	83 c0 01             	add    $0x1,%eax
  800bae:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800bb1:	39 d8                	cmp    %ebx,%eax
  800bb3:	74 07                	je     800bbc <strlcpy+0x2e>
  800bb5:	0f b6 0a             	movzbl (%edx),%ecx
  800bb8:	84 c9                	test   %cl,%cl
  800bba:	75 ec                	jne    800ba8 <strlcpy+0x1a>
		*dst = '\0';
  800bbc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bbf:	29 f0                	sub    %esi,%eax
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bce:	eb 06                	jmp    800bd6 <strcmp+0x11>
		p++, q++;
  800bd0:	83 c1 01             	add    $0x1,%ecx
  800bd3:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800bd6:	0f b6 01             	movzbl (%ecx),%eax
  800bd9:	84 c0                	test   %al,%al
  800bdb:	74 04                	je     800be1 <strcmp+0x1c>
  800bdd:	3a 02                	cmp    (%edx),%al
  800bdf:	74 ef                	je     800bd0 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800be1:	0f b6 c0             	movzbl %al,%eax
  800be4:	0f b6 12             	movzbl (%edx),%edx
  800be7:	29 d0                	sub    %edx,%eax
}
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	53                   	push   %ebx
  800bef:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf5:	89 c3                	mov    %eax,%ebx
  800bf7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800bfa:	eb 06                	jmp    800c02 <strncmp+0x17>
		n--, p++, q++;
  800bfc:	83 c0 01             	add    $0x1,%eax
  800bff:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c02:	39 d8                	cmp    %ebx,%eax
  800c04:	74 16                	je     800c1c <strncmp+0x31>
  800c06:	0f b6 08             	movzbl (%eax),%ecx
  800c09:	84 c9                	test   %cl,%cl
  800c0b:	74 04                	je     800c11 <strncmp+0x26>
  800c0d:	3a 0a                	cmp    (%edx),%cl
  800c0f:	74 eb                	je     800bfc <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c11:	0f b6 00             	movzbl (%eax),%eax
  800c14:	0f b6 12             	movzbl (%edx),%edx
  800c17:	29 d0                	sub    %edx,%eax
}
  800c19:	5b                   	pop    %ebx
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    
		return 0;
  800c1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c21:	eb f6                	jmp    800c19 <strncmp+0x2e>

00800c23 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	8b 45 08             	mov    0x8(%ebp),%eax
  800c29:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c2d:	0f b6 10             	movzbl (%eax),%edx
  800c30:	84 d2                	test   %dl,%dl
  800c32:	74 09                	je     800c3d <strchr+0x1a>
		if (*s == c)
  800c34:	38 ca                	cmp    %cl,%dl
  800c36:	74 0a                	je     800c42 <strchr+0x1f>
	for (; *s; s++)
  800c38:	83 c0 01             	add    $0x1,%eax
  800c3b:	eb f0                	jmp    800c2d <strchr+0xa>
			return (char *) s;
	return 0;
  800c3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c4e:	eb 03                	jmp    800c53 <strfind+0xf>
  800c50:	83 c0 01             	add    $0x1,%eax
  800c53:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c56:	38 ca                	cmp    %cl,%dl
  800c58:	74 04                	je     800c5e <strfind+0x1a>
  800c5a:	84 d2                	test   %dl,%dl
  800c5c:	75 f2                	jne    800c50 <strfind+0xc>
			break;
	return (char *) s;
}
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c69:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c6c:	85 c9                	test   %ecx,%ecx
  800c6e:	74 13                	je     800c83 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c70:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c76:	75 05                	jne    800c7d <memset+0x1d>
  800c78:	f6 c1 03             	test   $0x3,%cl
  800c7b:	74 0d                	je     800c8a <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c80:	fc                   	cld    
  800c81:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c83:	89 f8                	mov    %edi,%eax
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    
		c &= 0xFF;
  800c8a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c8e:	89 d3                	mov    %edx,%ebx
  800c90:	c1 e3 08             	shl    $0x8,%ebx
  800c93:	89 d0                	mov    %edx,%eax
  800c95:	c1 e0 18             	shl    $0x18,%eax
  800c98:	89 d6                	mov    %edx,%esi
  800c9a:	c1 e6 10             	shl    $0x10,%esi
  800c9d:	09 f0                	or     %esi,%eax
  800c9f:	09 c2                	or     %eax,%edx
  800ca1:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ca3:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ca6:	89 d0                	mov    %edx,%eax
  800ca8:	fc                   	cld    
  800ca9:	f3 ab                	rep stos %eax,%es:(%edi)
  800cab:	eb d6                	jmp    800c83 <memset+0x23>

00800cad <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cb8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cbb:	39 c6                	cmp    %eax,%esi
  800cbd:	73 35                	jae    800cf4 <memmove+0x47>
  800cbf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cc2:	39 c2                	cmp    %eax,%edx
  800cc4:	76 2e                	jbe    800cf4 <memmove+0x47>
		s += n;
		d += n;
  800cc6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cc9:	89 d6                	mov    %edx,%esi
  800ccb:	09 fe                	or     %edi,%esi
  800ccd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cd3:	74 0c                	je     800ce1 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cd5:	83 ef 01             	sub    $0x1,%edi
  800cd8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800cdb:	fd                   	std    
  800cdc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cde:	fc                   	cld    
  800cdf:	eb 21                	jmp    800d02 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ce1:	f6 c1 03             	test   $0x3,%cl
  800ce4:	75 ef                	jne    800cd5 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ce6:	83 ef 04             	sub    $0x4,%edi
  800ce9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cec:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800cef:	fd                   	std    
  800cf0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cf2:	eb ea                	jmp    800cde <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf4:	89 f2                	mov    %esi,%edx
  800cf6:	09 c2                	or     %eax,%edx
  800cf8:	f6 c2 03             	test   $0x3,%dl
  800cfb:	74 09                	je     800d06 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cfd:	89 c7                	mov    %eax,%edi
  800cff:	fc                   	cld    
  800d00:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d06:	f6 c1 03             	test   $0x3,%cl
  800d09:	75 f2                	jne    800cfd <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d0b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d0e:	89 c7                	mov    %eax,%edi
  800d10:	fc                   	cld    
  800d11:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d13:	eb ed                	jmp    800d02 <memmove+0x55>

00800d15 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d18:	ff 75 10             	pushl  0x10(%ebp)
  800d1b:	ff 75 0c             	pushl  0xc(%ebp)
  800d1e:	ff 75 08             	pushl  0x8(%ebp)
  800d21:	e8 87 ff ff ff       	call   800cad <memmove>
}
  800d26:	c9                   	leave  
  800d27:	c3                   	ret    

00800d28 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d30:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d33:	89 c6                	mov    %eax,%esi
  800d35:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d38:	39 f0                	cmp    %esi,%eax
  800d3a:	74 1c                	je     800d58 <memcmp+0x30>
		if (*s1 != *s2)
  800d3c:	0f b6 08             	movzbl (%eax),%ecx
  800d3f:	0f b6 1a             	movzbl (%edx),%ebx
  800d42:	38 d9                	cmp    %bl,%cl
  800d44:	75 08                	jne    800d4e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800d46:	83 c0 01             	add    $0x1,%eax
  800d49:	83 c2 01             	add    $0x1,%edx
  800d4c:	eb ea                	jmp    800d38 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800d4e:	0f b6 c1             	movzbl %cl,%eax
  800d51:	0f b6 db             	movzbl %bl,%ebx
  800d54:	29 d8                	sub    %ebx,%eax
  800d56:	eb 05                	jmp    800d5d <memcmp+0x35>
	}

	return 0;
  800d58:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d5d:	5b                   	pop    %ebx
  800d5e:	5e                   	pop    %esi
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    

00800d61 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	8b 45 08             	mov    0x8(%ebp),%eax
  800d67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d6a:	89 c2                	mov    %eax,%edx
  800d6c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d6f:	39 d0                	cmp    %edx,%eax
  800d71:	73 09                	jae    800d7c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d73:	38 08                	cmp    %cl,(%eax)
  800d75:	74 05                	je     800d7c <memfind+0x1b>
	for (; s < ends; s++)
  800d77:	83 c0 01             	add    $0x1,%eax
  800d7a:	eb f3                	jmp    800d6f <memfind+0xe>
			break;
	return (void *) s;
}
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d8a:	eb 03                	jmp    800d8f <strtol+0x11>
		s++;
  800d8c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d8f:	0f b6 01             	movzbl (%ecx),%eax
  800d92:	3c 20                	cmp    $0x20,%al
  800d94:	74 f6                	je     800d8c <strtol+0xe>
  800d96:	3c 09                	cmp    $0x9,%al
  800d98:	74 f2                	je     800d8c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800d9a:	3c 2b                	cmp    $0x2b,%al
  800d9c:	74 2e                	je     800dcc <strtol+0x4e>
	int neg = 0;
  800d9e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800da3:	3c 2d                	cmp    $0x2d,%al
  800da5:	74 2f                	je     800dd6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800da7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dad:	75 05                	jne    800db4 <strtol+0x36>
  800daf:	80 39 30             	cmpb   $0x30,(%ecx)
  800db2:	74 2c                	je     800de0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800db4:	85 db                	test   %ebx,%ebx
  800db6:	75 0a                	jne    800dc2 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800db8:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800dbd:	80 39 30             	cmpb   $0x30,(%ecx)
  800dc0:	74 28                	je     800dea <strtol+0x6c>
		base = 10;
  800dc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800dca:	eb 50                	jmp    800e1c <strtol+0x9e>
		s++;
  800dcc:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800dcf:	bf 00 00 00 00       	mov    $0x0,%edi
  800dd4:	eb d1                	jmp    800da7 <strtol+0x29>
		s++, neg = 1;
  800dd6:	83 c1 01             	add    $0x1,%ecx
  800dd9:	bf 01 00 00 00       	mov    $0x1,%edi
  800dde:	eb c7                	jmp    800da7 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800de0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800de4:	74 0e                	je     800df4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800de6:	85 db                	test   %ebx,%ebx
  800de8:	75 d8                	jne    800dc2 <strtol+0x44>
		s++, base = 8;
  800dea:	83 c1 01             	add    $0x1,%ecx
  800ded:	bb 08 00 00 00       	mov    $0x8,%ebx
  800df2:	eb ce                	jmp    800dc2 <strtol+0x44>
		s += 2, base = 16;
  800df4:	83 c1 02             	add    $0x2,%ecx
  800df7:	bb 10 00 00 00       	mov    $0x10,%ebx
  800dfc:	eb c4                	jmp    800dc2 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800dfe:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e01:	89 f3                	mov    %esi,%ebx
  800e03:	80 fb 19             	cmp    $0x19,%bl
  800e06:	77 29                	ja     800e31 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800e08:	0f be d2             	movsbl %dl,%edx
  800e0b:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e0e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e11:	7d 30                	jge    800e43 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800e13:	83 c1 01             	add    $0x1,%ecx
  800e16:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e1a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800e1c:	0f b6 11             	movzbl (%ecx),%edx
  800e1f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e22:	89 f3                	mov    %esi,%ebx
  800e24:	80 fb 09             	cmp    $0x9,%bl
  800e27:	77 d5                	ja     800dfe <strtol+0x80>
			dig = *s - '0';
  800e29:	0f be d2             	movsbl %dl,%edx
  800e2c:	83 ea 30             	sub    $0x30,%edx
  800e2f:	eb dd                	jmp    800e0e <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800e31:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e34:	89 f3                	mov    %esi,%ebx
  800e36:	80 fb 19             	cmp    $0x19,%bl
  800e39:	77 08                	ja     800e43 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800e3b:	0f be d2             	movsbl %dl,%edx
  800e3e:	83 ea 37             	sub    $0x37,%edx
  800e41:	eb cb                	jmp    800e0e <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800e43:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e47:	74 05                	je     800e4e <strtol+0xd0>
		*endptr = (char *) s;
  800e49:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e4c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800e4e:	89 c2                	mov    %eax,%edx
  800e50:	f7 da                	neg    %edx
  800e52:	85 ff                	test   %edi,%edi
  800e54:	0f 45 c2             	cmovne %edx,%eax
}
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    
  800e5c:	66 90                	xchg   %ax,%ax
  800e5e:	66 90                	xchg   %ax,%ax

00800e60 <__udivdi3>:
  800e60:	55                   	push   %ebp
  800e61:	57                   	push   %edi
  800e62:	56                   	push   %esi
  800e63:	53                   	push   %ebx
  800e64:	83 ec 1c             	sub    $0x1c,%esp
  800e67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e6b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e73:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e77:	85 d2                	test   %edx,%edx
  800e79:	75 35                	jne    800eb0 <__udivdi3+0x50>
  800e7b:	39 f3                	cmp    %esi,%ebx
  800e7d:	0f 87 bd 00 00 00    	ja     800f40 <__udivdi3+0xe0>
  800e83:	85 db                	test   %ebx,%ebx
  800e85:	89 d9                	mov    %ebx,%ecx
  800e87:	75 0b                	jne    800e94 <__udivdi3+0x34>
  800e89:	b8 01 00 00 00       	mov    $0x1,%eax
  800e8e:	31 d2                	xor    %edx,%edx
  800e90:	f7 f3                	div    %ebx
  800e92:	89 c1                	mov    %eax,%ecx
  800e94:	31 d2                	xor    %edx,%edx
  800e96:	89 f0                	mov    %esi,%eax
  800e98:	f7 f1                	div    %ecx
  800e9a:	89 c6                	mov    %eax,%esi
  800e9c:	89 e8                	mov    %ebp,%eax
  800e9e:	89 f7                	mov    %esi,%edi
  800ea0:	f7 f1                	div    %ecx
  800ea2:	89 fa                	mov    %edi,%edx
  800ea4:	83 c4 1c             	add    $0x1c,%esp
  800ea7:	5b                   	pop    %ebx
  800ea8:	5e                   	pop    %esi
  800ea9:	5f                   	pop    %edi
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    
  800eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	39 f2                	cmp    %esi,%edx
  800eb2:	77 7c                	ja     800f30 <__udivdi3+0xd0>
  800eb4:	0f bd fa             	bsr    %edx,%edi
  800eb7:	83 f7 1f             	xor    $0x1f,%edi
  800eba:	0f 84 98 00 00 00    	je     800f58 <__udivdi3+0xf8>
  800ec0:	89 f9                	mov    %edi,%ecx
  800ec2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ec7:	29 f8                	sub    %edi,%eax
  800ec9:	d3 e2                	shl    %cl,%edx
  800ecb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ecf:	89 c1                	mov    %eax,%ecx
  800ed1:	89 da                	mov    %ebx,%edx
  800ed3:	d3 ea                	shr    %cl,%edx
  800ed5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ed9:	09 d1                	or     %edx,%ecx
  800edb:	89 f2                	mov    %esi,%edx
  800edd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ee1:	89 f9                	mov    %edi,%ecx
  800ee3:	d3 e3                	shl    %cl,%ebx
  800ee5:	89 c1                	mov    %eax,%ecx
  800ee7:	d3 ea                	shr    %cl,%edx
  800ee9:	89 f9                	mov    %edi,%ecx
  800eeb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800eef:	d3 e6                	shl    %cl,%esi
  800ef1:	89 eb                	mov    %ebp,%ebx
  800ef3:	89 c1                	mov    %eax,%ecx
  800ef5:	d3 eb                	shr    %cl,%ebx
  800ef7:	09 de                	or     %ebx,%esi
  800ef9:	89 f0                	mov    %esi,%eax
  800efb:	f7 74 24 08          	divl   0x8(%esp)
  800eff:	89 d6                	mov    %edx,%esi
  800f01:	89 c3                	mov    %eax,%ebx
  800f03:	f7 64 24 0c          	mull   0xc(%esp)
  800f07:	39 d6                	cmp    %edx,%esi
  800f09:	72 0c                	jb     800f17 <__udivdi3+0xb7>
  800f0b:	89 f9                	mov    %edi,%ecx
  800f0d:	d3 e5                	shl    %cl,%ebp
  800f0f:	39 c5                	cmp    %eax,%ebp
  800f11:	73 5d                	jae    800f70 <__udivdi3+0x110>
  800f13:	39 d6                	cmp    %edx,%esi
  800f15:	75 59                	jne    800f70 <__udivdi3+0x110>
  800f17:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f1a:	31 ff                	xor    %edi,%edi
  800f1c:	89 fa                	mov    %edi,%edx
  800f1e:	83 c4 1c             	add    $0x1c,%esp
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    
  800f26:	8d 76 00             	lea    0x0(%esi),%esi
  800f29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800f30:	31 ff                	xor    %edi,%edi
  800f32:	31 c0                	xor    %eax,%eax
  800f34:	89 fa                	mov    %edi,%edx
  800f36:	83 c4 1c             	add    $0x1c,%esp
  800f39:	5b                   	pop    %ebx
  800f3a:	5e                   	pop    %esi
  800f3b:	5f                   	pop    %edi
  800f3c:	5d                   	pop    %ebp
  800f3d:	c3                   	ret    
  800f3e:	66 90                	xchg   %ax,%ax
  800f40:	31 ff                	xor    %edi,%edi
  800f42:	89 e8                	mov    %ebp,%eax
  800f44:	89 f2                	mov    %esi,%edx
  800f46:	f7 f3                	div    %ebx
  800f48:	89 fa                	mov    %edi,%edx
  800f4a:	83 c4 1c             	add    $0x1c,%esp
  800f4d:	5b                   	pop    %ebx
  800f4e:	5e                   	pop    %esi
  800f4f:	5f                   	pop    %edi
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    
  800f52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f58:	39 f2                	cmp    %esi,%edx
  800f5a:	72 06                	jb     800f62 <__udivdi3+0x102>
  800f5c:	31 c0                	xor    %eax,%eax
  800f5e:	39 eb                	cmp    %ebp,%ebx
  800f60:	77 d2                	ja     800f34 <__udivdi3+0xd4>
  800f62:	b8 01 00 00 00       	mov    $0x1,%eax
  800f67:	eb cb                	jmp    800f34 <__udivdi3+0xd4>
  800f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f70:	89 d8                	mov    %ebx,%eax
  800f72:	31 ff                	xor    %edi,%edi
  800f74:	eb be                	jmp    800f34 <__udivdi3+0xd4>
  800f76:	66 90                	xchg   %ax,%ax
  800f78:	66 90                	xchg   %ax,%ax
  800f7a:	66 90                	xchg   %ax,%ax
  800f7c:	66 90                	xchg   %ax,%ax
  800f7e:	66 90                	xchg   %ax,%ax

00800f80 <__umoddi3>:
  800f80:	55                   	push   %ebp
  800f81:	57                   	push   %edi
  800f82:	56                   	push   %esi
  800f83:	53                   	push   %ebx
  800f84:	83 ec 1c             	sub    $0x1c,%esp
  800f87:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f8b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f8f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f97:	85 ed                	test   %ebp,%ebp
  800f99:	89 f0                	mov    %esi,%eax
  800f9b:	89 da                	mov    %ebx,%edx
  800f9d:	75 19                	jne    800fb8 <__umoddi3+0x38>
  800f9f:	39 df                	cmp    %ebx,%edi
  800fa1:	0f 86 b1 00 00 00    	jbe    801058 <__umoddi3+0xd8>
  800fa7:	f7 f7                	div    %edi
  800fa9:	89 d0                	mov    %edx,%eax
  800fab:	31 d2                	xor    %edx,%edx
  800fad:	83 c4 1c             	add    $0x1c,%esp
  800fb0:	5b                   	pop    %ebx
  800fb1:	5e                   	pop    %esi
  800fb2:	5f                   	pop    %edi
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    
  800fb5:	8d 76 00             	lea    0x0(%esi),%esi
  800fb8:	39 dd                	cmp    %ebx,%ebp
  800fba:	77 f1                	ja     800fad <__umoddi3+0x2d>
  800fbc:	0f bd cd             	bsr    %ebp,%ecx
  800fbf:	83 f1 1f             	xor    $0x1f,%ecx
  800fc2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fc6:	0f 84 b4 00 00 00    	je     801080 <__umoddi3+0x100>
  800fcc:	b8 20 00 00 00       	mov    $0x20,%eax
  800fd1:	89 c2                	mov    %eax,%edx
  800fd3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fd7:	29 c2                	sub    %eax,%edx
  800fd9:	89 c1                	mov    %eax,%ecx
  800fdb:	89 f8                	mov    %edi,%eax
  800fdd:	d3 e5                	shl    %cl,%ebp
  800fdf:	89 d1                	mov    %edx,%ecx
  800fe1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fe5:	d3 e8                	shr    %cl,%eax
  800fe7:	09 c5                	or     %eax,%ebp
  800fe9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fed:	89 c1                	mov    %eax,%ecx
  800fef:	d3 e7                	shl    %cl,%edi
  800ff1:	89 d1                	mov    %edx,%ecx
  800ff3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ff7:	89 df                	mov    %ebx,%edi
  800ff9:	d3 ef                	shr    %cl,%edi
  800ffb:	89 c1                	mov    %eax,%ecx
  800ffd:	89 f0                	mov    %esi,%eax
  800fff:	d3 e3                	shl    %cl,%ebx
  801001:	89 d1                	mov    %edx,%ecx
  801003:	89 fa                	mov    %edi,%edx
  801005:	d3 e8                	shr    %cl,%eax
  801007:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80100c:	09 d8                	or     %ebx,%eax
  80100e:	f7 f5                	div    %ebp
  801010:	d3 e6                	shl    %cl,%esi
  801012:	89 d1                	mov    %edx,%ecx
  801014:	f7 64 24 08          	mull   0x8(%esp)
  801018:	39 d1                	cmp    %edx,%ecx
  80101a:	89 c3                	mov    %eax,%ebx
  80101c:	89 d7                	mov    %edx,%edi
  80101e:	72 06                	jb     801026 <__umoddi3+0xa6>
  801020:	75 0e                	jne    801030 <__umoddi3+0xb0>
  801022:	39 c6                	cmp    %eax,%esi
  801024:	73 0a                	jae    801030 <__umoddi3+0xb0>
  801026:	2b 44 24 08          	sub    0x8(%esp),%eax
  80102a:	19 ea                	sbb    %ebp,%edx
  80102c:	89 d7                	mov    %edx,%edi
  80102e:	89 c3                	mov    %eax,%ebx
  801030:	89 ca                	mov    %ecx,%edx
  801032:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801037:	29 de                	sub    %ebx,%esi
  801039:	19 fa                	sbb    %edi,%edx
  80103b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80103f:	89 d0                	mov    %edx,%eax
  801041:	d3 e0                	shl    %cl,%eax
  801043:	89 d9                	mov    %ebx,%ecx
  801045:	d3 ee                	shr    %cl,%esi
  801047:	d3 ea                	shr    %cl,%edx
  801049:	09 f0                	or     %esi,%eax
  80104b:	83 c4 1c             	add    $0x1c,%esp
  80104e:	5b                   	pop    %ebx
  80104f:	5e                   	pop    %esi
  801050:	5f                   	pop    %edi
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    
  801053:	90                   	nop
  801054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801058:	85 ff                	test   %edi,%edi
  80105a:	89 f9                	mov    %edi,%ecx
  80105c:	75 0b                	jne    801069 <__umoddi3+0xe9>
  80105e:	b8 01 00 00 00       	mov    $0x1,%eax
  801063:	31 d2                	xor    %edx,%edx
  801065:	f7 f7                	div    %edi
  801067:	89 c1                	mov    %eax,%ecx
  801069:	89 d8                	mov    %ebx,%eax
  80106b:	31 d2                	xor    %edx,%edx
  80106d:	f7 f1                	div    %ecx
  80106f:	89 f0                	mov    %esi,%eax
  801071:	f7 f1                	div    %ecx
  801073:	e9 31 ff ff ff       	jmp    800fa9 <__umoddi3+0x29>
  801078:	90                   	nop
  801079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801080:	39 dd                	cmp    %ebx,%ebp
  801082:	72 08                	jb     80108c <__umoddi3+0x10c>
  801084:	39 f7                	cmp    %esi,%edi
  801086:	0f 87 21 ff ff ff    	ja     800fad <__umoddi3+0x2d>
  80108c:	89 da                	mov    %ebx,%edx
  80108e:	89 f0                	mov    %esi,%eax
  801090:	29 f8                	sub    %edi,%eax
  801092:	19 ea                	sbb    %ebp,%edx
  801094:	e9 14 ff ff ff       	jmp    800fad <__umoddi3+0x2d>
