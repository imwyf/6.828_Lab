
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:

const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	57                   	push   %edi
  80003e:	56                   	push   %esi
  80003f:	53                   	push   %ebx
  800040:	83 ec 0c             	sub    $0xc,%esp
  800043:	e8 4d 00 00 00       	call   800095 <__x86.get_pc_thunk.bx>
  800048:	81 c3 b8 1f 00 00    	add    $0x1fb8,%ebx
  80004e:	8b 75 08             	mov    0x8(%ebp),%esi
  800051:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())]; // ENVX()得到id在Env[]数组中对应的下标
  800054:	e8 f3 00 00 00       	call   80014c <sys_getenvid>
  800059:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800061:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800067:	c7 c2 44 20 80 00    	mov    $0x802044,%edx
  80006d:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006f:	85 f6                	test   %esi,%esi
  800071:	7e 08                	jle    80007b <libmain+0x41>
		binaryname = argv[0];
  800073:	8b 07                	mov    (%edi),%eax
  800075:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	57                   	push   %edi
  80007f:	56                   	push   %esi
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0f 00 00 00       	call   800099 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5f                   	pop    %edi
  800093:	5d                   	pop    %ebp
  800094:	c3                   	ret    

00800095 <__x86.get_pc_thunk.bx>:
  800095:	8b 1c 24             	mov    (%esp),%ebx
  800098:	c3                   	ret    

00800099 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	53                   	push   %ebx
  80009d:	83 ec 10             	sub    $0x10,%esp
  8000a0:	e8 f0 ff ff ff       	call   800095 <__x86.get_pc_thunk.bx>
  8000a5:	81 c3 5b 1f 00 00    	add    $0x1f5b,%ebx
	sys_env_destroy(0);
  8000ab:	6a 00                	push   $0x0
  8000ad:	e8 45 00 00 00       	call   8000f7 <sys_env_destroy>
}
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b8:	c9                   	leave  
  8000b9:	c3                   	ret    

008000ba <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ba:	55                   	push   %ebp
  8000bb:	89 e5                	mov    %esp,%ebp
  8000bd:	57                   	push   %edi
  8000be:	56                   	push   %esi
  8000bf:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cb:	89 c3                	mov    %eax,%ebx
  8000cd:	89 c7                	mov    %eax,%edi
  8000cf:	89 c6                	mov    %eax,%esi
  8000d1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d3:	5b                   	pop    %ebx
  8000d4:	5e                   	pop    %esi
  8000d5:	5f                   	pop    %edi
  8000d6:	5d                   	pop    %ebp
  8000d7:	c3                   	ret    

008000d8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	57                   	push   %edi
  8000dc:	56                   	push   %esi
  8000dd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000de:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e8:	89 d1                	mov    %edx,%ecx
  8000ea:	89 d3                	mov    %edx,%ebx
  8000ec:	89 d7                	mov    %edx,%edi
  8000ee:	89 d6                	mov    %edx,%esi
  8000f0:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f2:	5b                   	pop    %ebx
  8000f3:	5e                   	pop    %esi
  8000f4:	5f                   	pop    %edi
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	57                   	push   %edi
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 1c             	sub    $0x1c,%esp
  800100:	e8 ac 02 00 00       	call   8003b1 <__x86.get_pc_thunk.ax>
  800105:	05 fb 1e 00 00       	add    $0x1efb,%eax
  80010a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80010d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800112:	8b 55 08             	mov    0x8(%ebp),%edx
  800115:	b8 03 00 00 00       	mov    $0x3,%eax
  80011a:	89 cb                	mov    %ecx,%ebx
  80011c:	89 cf                	mov    %ecx,%edi
  80011e:	89 ce                	mov    %ecx,%esi
  800120:	cd 30                	int    $0x30
	if(check && ret > 0)
  800122:	85 c0                	test   %eax,%eax
  800124:	7f 08                	jg     80012e <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800126:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800129:	5b                   	pop    %ebx
  80012a:	5e                   	pop    %esi
  80012b:	5f                   	pop    %edi
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80012e:	83 ec 0c             	sub    $0xc,%esp
  800131:	50                   	push   %eax
  800132:	6a 03                	push   $0x3
  800134:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800137:	8d 83 a6 f0 ff ff    	lea    -0xf5a(%ebx),%eax
  80013d:	50                   	push   %eax
  80013e:	6a 23                	push   $0x23
  800140:	8d 83 c3 f0 ff ff    	lea    -0xf3d(%ebx),%eax
  800146:	50                   	push   %eax
  800147:	e8 69 02 00 00       	call   8003b5 <_panic>

0080014c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	57                   	push   %edi
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
	asm volatile("int %1\n"
  800152:	ba 00 00 00 00       	mov    $0x0,%edx
  800157:	b8 02 00 00 00       	mov    $0x2,%eax
  80015c:	89 d1                	mov    %edx,%ecx
  80015e:	89 d3                	mov    %edx,%ebx
  800160:	89 d7                	mov    %edx,%edi
  800162:	89 d6                	mov    %edx,%esi
  800164:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800166:	5b                   	pop    %ebx
  800167:	5e                   	pop    %esi
  800168:	5f                   	pop    %edi
  800169:	5d                   	pop    %ebp
  80016a:	c3                   	ret    

0080016b <sys_yield>:

void
sys_yield(void)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	57                   	push   %edi
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
	asm volatile("int %1\n"
  800171:	ba 00 00 00 00       	mov    $0x0,%edx
  800176:	b8 0a 00 00 00       	mov    $0xa,%eax
  80017b:	89 d1                	mov    %edx,%ecx
  80017d:	89 d3                	mov    %edx,%ebx
  80017f:	89 d7                	mov    %edx,%edi
  800181:	89 d6                	mov    %edx,%esi
  800183:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800185:	5b                   	pop    %ebx
  800186:	5e                   	pop    %esi
  800187:	5f                   	pop    %edi
  800188:	5d                   	pop    %ebp
  800189:	c3                   	ret    

0080018a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	57                   	push   %edi
  80018e:	56                   	push   %esi
  80018f:	53                   	push   %ebx
  800190:	83 ec 1c             	sub    $0x1c,%esp
  800193:	e8 19 02 00 00       	call   8003b1 <__x86.get_pc_thunk.ax>
  800198:	05 68 1e 00 00       	add    $0x1e68,%eax
  80019d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8001a0:	be 00 00 00 00       	mov    $0x0,%esi
  8001a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ab:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b3:	89 f7                	mov    %esi,%edi
  8001b5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	7f 08                	jg     8001c3 <sys_page_alloc+0x39>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001be:	5b                   	pop    %ebx
  8001bf:	5e                   	pop    %esi
  8001c0:	5f                   	pop    %edi
  8001c1:	5d                   	pop    %ebp
  8001c2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c3:	83 ec 0c             	sub    $0xc,%esp
  8001c6:	50                   	push   %eax
  8001c7:	6a 04                	push   $0x4
  8001c9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8001cc:	8d 83 a6 f0 ff ff    	lea    -0xf5a(%ebx),%eax
  8001d2:	50                   	push   %eax
  8001d3:	6a 23                	push   $0x23
  8001d5:	8d 83 c3 f0 ff ff    	lea    -0xf3d(%ebx),%eax
  8001db:	50                   	push   %eax
  8001dc:	e8 d4 01 00 00       	call   8003b5 <_panic>

008001e1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	57                   	push   %edi
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
  8001e7:	83 ec 1c             	sub    $0x1c,%esp
  8001ea:	e8 c2 01 00 00       	call   8003b1 <__x86.get_pc_thunk.ax>
  8001ef:	05 11 1e 00 00       	add    $0x1e11,%eax
  8001f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8001f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fd:	b8 05 00 00 00       	mov    $0x5,%eax
  800202:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800205:	8b 7d 14             	mov    0x14(%ebp),%edi
  800208:	8b 75 18             	mov    0x18(%ebp),%esi
  80020b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80020d:	85 c0                	test   %eax,%eax
  80020f:	7f 08                	jg     800219 <sys_page_map+0x38>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800211:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800214:	5b                   	pop    %ebx
  800215:	5e                   	pop    %esi
  800216:	5f                   	pop    %edi
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800219:	83 ec 0c             	sub    $0xc,%esp
  80021c:	50                   	push   %eax
  80021d:	6a 05                	push   $0x5
  80021f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800222:	8d 83 a6 f0 ff ff    	lea    -0xf5a(%ebx),%eax
  800228:	50                   	push   %eax
  800229:	6a 23                	push   $0x23
  80022b:	8d 83 c3 f0 ff ff    	lea    -0xf3d(%ebx),%eax
  800231:	50                   	push   %eax
  800232:	e8 7e 01 00 00       	call   8003b5 <_panic>

00800237 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 1c             	sub    $0x1c,%esp
  800240:	e8 6c 01 00 00       	call   8003b1 <__x86.get_pc_thunk.ax>
  800245:	05 bb 1d 00 00       	add    $0x1dbb,%eax
  80024a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80024d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800252:	8b 55 08             	mov    0x8(%ebp),%edx
  800255:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800258:	b8 06 00 00 00       	mov    $0x6,%eax
  80025d:	89 df                	mov    %ebx,%edi
  80025f:	89 de                	mov    %ebx,%esi
  800261:	cd 30                	int    $0x30
	if(check && ret > 0)
  800263:	85 c0                	test   %eax,%eax
  800265:	7f 08                	jg     80026f <sys_page_unmap+0x38>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80026f:	83 ec 0c             	sub    $0xc,%esp
  800272:	50                   	push   %eax
  800273:	6a 06                	push   $0x6
  800275:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800278:	8d 83 a6 f0 ff ff    	lea    -0xf5a(%ebx),%eax
  80027e:	50                   	push   %eax
  80027f:	6a 23                	push   $0x23
  800281:	8d 83 c3 f0 ff ff    	lea    -0xf3d(%ebx),%eax
  800287:	50                   	push   %eax
  800288:	e8 28 01 00 00       	call   8003b5 <_panic>

0080028d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	57                   	push   %edi
  800291:	56                   	push   %esi
  800292:	53                   	push   %ebx
  800293:	83 ec 1c             	sub    $0x1c,%esp
  800296:	e8 16 01 00 00       	call   8003b1 <__x86.get_pc_thunk.ax>
  80029b:	05 65 1d 00 00       	add    $0x1d65,%eax
  8002a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8002a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ae:	b8 08 00 00 00       	mov    $0x8,%eax
  8002b3:	89 df                	mov    %ebx,%edi
  8002b5:	89 de                	mov    %ebx,%esi
  8002b7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002b9:	85 c0                	test   %eax,%eax
  8002bb:	7f 08                	jg     8002c5 <sys_env_set_status+0x38>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5f                   	pop    %edi
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c5:	83 ec 0c             	sub    $0xc,%esp
  8002c8:	50                   	push   %eax
  8002c9:	6a 08                	push   $0x8
  8002cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002ce:	8d 83 a6 f0 ff ff    	lea    -0xf5a(%ebx),%eax
  8002d4:	50                   	push   %eax
  8002d5:	6a 23                	push   $0x23
  8002d7:	8d 83 c3 f0 ff ff    	lea    -0xf3d(%ebx),%eax
  8002dd:	50                   	push   %eax
  8002de:	e8 d2 00 00 00       	call   8003b5 <_panic>

008002e3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
  8002e9:	83 ec 1c             	sub    $0x1c,%esp
  8002ec:	e8 c0 00 00 00       	call   8003b1 <__x86.get_pc_thunk.ax>
  8002f1:	05 0f 1d 00 00       	add    $0x1d0f,%eax
  8002f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8002f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800301:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800304:	b8 09 00 00 00       	mov    $0x9,%eax
  800309:	89 df                	mov    %ebx,%edi
  80030b:	89 de                	mov    %ebx,%esi
  80030d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80030f:	85 c0                	test   %eax,%eax
  800311:	7f 08                	jg     80031b <sys_env_set_pgfault_upcall+0x38>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800313:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800316:	5b                   	pop    %ebx
  800317:	5e                   	pop    %esi
  800318:	5f                   	pop    %edi
  800319:	5d                   	pop    %ebp
  80031a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80031b:	83 ec 0c             	sub    $0xc,%esp
  80031e:	50                   	push   %eax
  80031f:	6a 09                	push   $0x9
  800321:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800324:	8d 83 a6 f0 ff ff    	lea    -0xf5a(%ebx),%eax
  80032a:	50                   	push   %eax
  80032b:	6a 23                	push   $0x23
  80032d:	8d 83 c3 f0 ff ff    	lea    -0xf3d(%ebx),%eax
  800333:	50                   	push   %eax
  800334:	e8 7c 00 00 00       	call   8003b5 <_panic>

00800339 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	57                   	push   %edi
  80033d:	56                   	push   %esi
  80033e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80033f:	8b 55 08             	mov    0x8(%ebp),%edx
  800342:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800345:	b8 0b 00 00 00       	mov    $0xb,%eax
  80034a:	be 00 00 00 00       	mov    $0x0,%esi
  80034f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800352:	8b 7d 14             	mov    0x14(%ebp),%edi
  800355:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800357:	5b                   	pop    %ebx
  800358:	5e                   	pop    %esi
  800359:	5f                   	pop    %edi
  80035a:	5d                   	pop    %ebp
  80035b:	c3                   	ret    

0080035c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	57                   	push   %edi
  800360:	56                   	push   %esi
  800361:	53                   	push   %ebx
  800362:	83 ec 1c             	sub    $0x1c,%esp
  800365:	e8 47 00 00 00       	call   8003b1 <__x86.get_pc_thunk.ax>
  80036a:	05 96 1c 00 00       	add    $0x1c96,%eax
  80036f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800372:	b9 00 00 00 00       	mov    $0x0,%ecx
  800377:	8b 55 08             	mov    0x8(%ebp),%edx
  80037a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80037f:	89 cb                	mov    %ecx,%ebx
  800381:	89 cf                	mov    %ecx,%edi
  800383:	89 ce                	mov    %ecx,%esi
  800385:	cd 30                	int    $0x30
	if(check && ret > 0)
  800387:	85 c0                	test   %eax,%eax
  800389:	7f 08                	jg     800393 <sys_ipc_recv+0x37>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80038b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80038e:	5b                   	pop    %ebx
  80038f:	5e                   	pop    %esi
  800390:	5f                   	pop    %edi
  800391:	5d                   	pop    %ebp
  800392:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800393:	83 ec 0c             	sub    $0xc,%esp
  800396:	50                   	push   %eax
  800397:	6a 0c                	push   $0xc
  800399:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80039c:	8d 83 a6 f0 ff ff    	lea    -0xf5a(%ebx),%eax
  8003a2:	50                   	push   %eax
  8003a3:	6a 23                	push   $0x23
  8003a5:	8d 83 c3 f0 ff ff    	lea    -0xf3d(%ebx),%eax
  8003ab:	50                   	push   %eax
  8003ac:	e8 04 00 00 00       	call   8003b5 <_panic>

008003b1 <__x86.get_pc_thunk.ax>:
  8003b1:	8b 04 24             	mov    (%esp),%eax
  8003b4:	c3                   	ret    

008003b5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
  8003b8:	57                   	push   %edi
  8003b9:	56                   	push   %esi
  8003ba:	53                   	push   %ebx
  8003bb:	83 ec 0c             	sub    $0xc,%esp
  8003be:	e8 d2 fc ff ff       	call   800095 <__x86.get_pc_thunk.bx>
  8003c3:	81 c3 3d 1c 00 00    	add    $0x1c3d,%ebx
	va_list ap;

	va_start(ap, fmt);
  8003c9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003cc:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  8003d2:	8b 38                	mov    (%eax),%edi
  8003d4:	e8 73 fd ff ff       	call   80014c <sys_getenvid>
  8003d9:	83 ec 0c             	sub    $0xc,%esp
  8003dc:	ff 75 0c             	pushl  0xc(%ebp)
  8003df:	ff 75 08             	pushl  0x8(%ebp)
  8003e2:	57                   	push   %edi
  8003e3:	50                   	push   %eax
  8003e4:	8d 83 d4 f0 ff ff    	lea    -0xf2c(%ebx),%eax
  8003ea:	50                   	push   %eax
  8003eb:	e8 d1 00 00 00       	call   8004c1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003f0:	83 c4 18             	add    $0x18,%esp
  8003f3:	56                   	push   %esi
  8003f4:	ff 75 10             	pushl  0x10(%ebp)
  8003f7:	e8 63 00 00 00       	call   80045f <vcprintf>
	cprintf("\n");
  8003fc:	8d 83 f8 f0 ff ff    	lea    -0xf08(%ebx),%eax
  800402:	89 04 24             	mov    %eax,(%esp)
  800405:	e8 b7 00 00 00       	call   8004c1 <cprintf>
  80040a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80040d:	cc                   	int3   
  80040e:	eb fd                	jmp    80040d <_panic+0x58>

00800410 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	56                   	push   %esi
  800414:	53                   	push   %ebx
  800415:	e8 7b fc ff ff       	call   800095 <__x86.get_pc_thunk.bx>
  80041a:	81 c3 e6 1b 00 00    	add    $0x1be6,%ebx
  800420:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  800423:	8b 16                	mov    (%esi),%edx
  800425:	8d 42 01             	lea    0x1(%edx),%eax
  800428:	89 06                	mov    %eax,(%esi)
  80042a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042d:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800431:	3d ff 00 00 00       	cmp    $0xff,%eax
  800436:	74 0b                	je     800443 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800438:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80043c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80043f:	5b                   	pop    %ebx
  800440:	5e                   	pop    %esi
  800441:	5d                   	pop    %ebp
  800442:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800443:	83 ec 08             	sub    $0x8,%esp
  800446:	68 ff 00 00 00       	push   $0xff
  80044b:	8d 46 08             	lea    0x8(%esi),%eax
  80044e:	50                   	push   %eax
  80044f:	e8 66 fc ff ff       	call   8000ba <sys_cputs>
		b->idx = 0;
  800454:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80045a:	83 c4 10             	add    $0x10,%esp
  80045d:	eb d9                	jmp    800438 <putch+0x28>

0080045f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80045f:	55                   	push   %ebp
  800460:	89 e5                	mov    %esp,%ebp
  800462:	53                   	push   %ebx
  800463:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800469:	e8 27 fc ff ff       	call   800095 <__x86.get_pc_thunk.bx>
  80046e:	81 c3 92 1b 00 00    	add    $0x1b92,%ebx
	struct printbuf b;

	b.idx = 0;
  800474:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80047b:	00 00 00 
	b.cnt = 0;
  80047e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800485:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800488:	ff 75 0c             	pushl  0xc(%ebp)
  80048b:	ff 75 08             	pushl  0x8(%ebp)
  80048e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800494:	50                   	push   %eax
  800495:	8d 83 10 e4 ff ff    	lea    -0x1bf0(%ebx),%eax
  80049b:	50                   	push   %eax
  80049c:	e8 38 01 00 00       	call   8005d9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004a1:	83 c4 08             	add    $0x8,%esp
  8004a4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004b0:	50                   	push   %eax
  8004b1:	e8 04 fc ff ff       	call   8000ba <sys_cputs>

	return b.cnt;
}
  8004b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004bf:	c9                   	leave  
  8004c0:	c3                   	ret    

008004c1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004c1:	55                   	push   %ebp
  8004c2:	89 e5                	mov    %esp,%ebp
  8004c4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004c7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004ca:	50                   	push   %eax
  8004cb:	ff 75 08             	pushl  0x8(%ebp)
  8004ce:	e8 8c ff ff ff       	call   80045f <vcprintf>
	va_end(ap);

	return cnt;
}
  8004d3:	c9                   	leave  
  8004d4:	c3                   	ret    

008004d5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
  8004d8:	57                   	push   %edi
  8004d9:	56                   	push   %esi
  8004da:	53                   	push   %ebx
  8004db:	83 ec 2c             	sub    $0x2c,%esp
  8004de:	e8 02 06 00 00       	call   800ae5 <__x86.get_pc_thunk.cx>
  8004e3:	81 c1 1d 1b 00 00    	add    $0x1b1d,%ecx
  8004e9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8004ec:	89 c7                	mov    %eax,%edi
  8004ee:	89 d6                	mov    %edx,%esi
  8004f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004f9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  8004fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8004ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800504:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800507:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  80050a:	39 d3                	cmp    %edx,%ebx
  80050c:	72 09                	jb     800517 <printnum+0x42>
  80050e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800511:	0f 87 83 00 00 00    	ja     80059a <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800517:	83 ec 0c             	sub    $0xc,%esp
  80051a:	ff 75 18             	pushl  0x18(%ebp)
  80051d:	8b 45 14             	mov    0x14(%ebp),%eax
  800520:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800523:	53                   	push   %ebx
  800524:	ff 75 10             	pushl  0x10(%ebp)
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	ff 75 dc             	pushl  -0x24(%ebp)
  80052d:	ff 75 d8             	pushl  -0x28(%ebp)
  800530:	ff 75 d4             	pushl  -0x2c(%ebp)
  800533:	ff 75 d0             	pushl  -0x30(%ebp)
  800536:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800539:	e8 22 09 00 00       	call   800e60 <__udivdi3>
  80053e:	83 c4 18             	add    $0x18,%esp
  800541:	52                   	push   %edx
  800542:	50                   	push   %eax
  800543:	89 f2                	mov    %esi,%edx
  800545:	89 f8                	mov    %edi,%eax
  800547:	e8 89 ff ff ff       	call   8004d5 <printnum>
  80054c:	83 c4 20             	add    $0x20,%esp
  80054f:	eb 13                	jmp    800564 <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800551:	83 ec 08             	sub    $0x8,%esp
  800554:	56                   	push   %esi
  800555:	ff 75 18             	pushl  0x18(%ebp)
  800558:	ff d7                	call   *%edi
  80055a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80055d:	83 eb 01             	sub    $0x1,%ebx
  800560:	85 db                	test   %ebx,%ebx
  800562:	7f ed                	jg     800551 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	56                   	push   %esi
  800568:	83 ec 04             	sub    $0x4,%esp
  80056b:	ff 75 dc             	pushl  -0x24(%ebp)
  80056e:	ff 75 d8             	pushl  -0x28(%ebp)
  800571:	ff 75 d4             	pushl  -0x2c(%ebp)
  800574:	ff 75 d0             	pushl  -0x30(%ebp)
  800577:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80057a:	89 f3                	mov    %esi,%ebx
  80057c:	e8 ff 09 00 00       	call   800f80 <__umoddi3>
  800581:	83 c4 14             	add    $0x14,%esp
  800584:	0f be 84 06 fa f0 ff 	movsbl -0xf06(%esi,%eax,1),%eax
  80058b:	ff 
  80058c:	50                   	push   %eax
  80058d:	ff d7                	call   *%edi
}
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800595:	5b                   	pop    %ebx
  800596:	5e                   	pop    %esi
  800597:	5f                   	pop    %edi
  800598:	5d                   	pop    %ebp
  800599:	c3                   	ret    
  80059a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80059d:	eb be                	jmp    80055d <printnum+0x88>

0080059f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80059f:	55                   	push   %ebp
  8005a0:	89 e5                	mov    %esp,%ebp
  8005a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005a5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005a9:	8b 10                	mov    (%eax),%edx
  8005ab:	3b 50 04             	cmp    0x4(%eax),%edx
  8005ae:	73 0a                	jae    8005ba <sprintputch+0x1b>
		*b->buf++ = ch;
  8005b0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005b3:	89 08                	mov    %ecx,(%eax)
  8005b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b8:	88 02                	mov    %al,(%edx)
}
  8005ba:	5d                   	pop    %ebp
  8005bb:	c3                   	ret    

008005bc <printfmt>:
{
  8005bc:	55                   	push   %ebp
  8005bd:	89 e5                	mov    %esp,%ebp
  8005bf:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8005c2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005c5:	50                   	push   %eax
  8005c6:	ff 75 10             	pushl  0x10(%ebp)
  8005c9:	ff 75 0c             	pushl  0xc(%ebp)
  8005cc:	ff 75 08             	pushl  0x8(%ebp)
  8005cf:	e8 05 00 00 00       	call   8005d9 <vprintfmt>
}
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	c9                   	leave  
  8005d8:	c3                   	ret    

008005d9 <vprintfmt>:
{
  8005d9:	55                   	push   %ebp
  8005da:	89 e5                	mov    %esp,%ebp
  8005dc:	57                   	push   %edi
  8005dd:	56                   	push   %esi
  8005de:	53                   	push   %ebx
  8005df:	83 ec 2c             	sub    $0x2c,%esp
  8005e2:	e8 ae fa ff ff       	call   800095 <__x86.get_pc_thunk.bx>
  8005e7:	81 c3 19 1a 00 00    	add    $0x1a19,%ebx
  8005ed:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005f0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005f3:	e9 c3 03 00 00       	jmp    8009bb <.L35+0x48>
		padc = ' ';
  8005f8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8005fc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800603:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  80060a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800611:	b9 00 00 00 00       	mov    $0x0,%ecx
  800616:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800619:	8d 47 01             	lea    0x1(%edi),%eax
  80061c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80061f:	0f b6 17             	movzbl (%edi),%edx
  800622:	8d 42 dd             	lea    -0x23(%edx),%eax
  800625:	3c 55                	cmp    $0x55,%al
  800627:	0f 87 16 04 00 00    	ja     800a43 <.L22>
  80062d:	0f b6 c0             	movzbl %al,%eax
  800630:	89 d9                	mov    %ebx,%ecx
  800632:	03 8c 83 b4 f1 ff ff 	add    -0xe4c(%ebx,%eax,4),%ecx
  800639:	ff e1                	jmp    *%ecx

0080063b <.L69>:
  80063b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80063e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800642:	eb d5                	jmp    800619 <vprintfmt+0x40>

00800644 <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800644:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800647:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80064b:	eb cc                	jmp    800619 <vprintfmt+0x40>

0080064d <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80064d:	0f b6 d2             	movzbl %dl,%edx
  800650:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
  800653:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800658:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80065b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80065f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800662:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800665:	83 f9 09             	cmp    $0x9,%ecx
  800668:	77 55                	ja     8006bf <.L23+0xf>
			for (precision = 0;; ++fmt)
  80066a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80066d:	eb e9                	jmp    800658 <.L29+0xb>

0080066f <.L26>:
			precision = va_arg(ap, int);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8b 00                	mov    (%eax),%eax
  800674:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8d 40 04             	lea    0x4(%eax),%eax
  80067d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800680:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800683:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800687:	79 90                	jns    800619 <vprintfmt+0x40>
				width = precision, precision = -1;
  800689:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80068c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80068f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800696:	eb 81                	jmp    800619 <vprintfmt+0x40>

00800698 <.L27>:
  800698:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80069b:	85 c0                	test   %eax,%eax
  80069d:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a2:	0f 49 d0             	cmovns %eax,%edx
  8006a5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ab:	e9 69 ff ff ff       	jmp    800619 <vprintfmt+0x40>

008006b0 <.L23>:
  8006b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8006b3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006ba:	e9 5a ff ff ff       	jmp    800619 <vprintfmt+0x40>
  8006bf:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006c2:	eb bf                	jmp    800683 <.L26+0x14>

008006c4 <.L33>:
			lflag++;
  8006c4:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8006cb:	e9 49 ff ff ff       	jmp    800619 <vprintfmt+0x40>

008006d0 <.L30>:
			putch(va_arg(ap, int), putdat);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8d 78 04             	lea    0x4(%eax),%edi
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	56                   	push   %esi
  8006da:	ff 30                	pushl  (%eax)
  8006dc:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006df:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8006e2:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8006e5:	e9 ce 02 00 00       	jmp    8009b8 <.L35+0x45>

008006ea <.L32>:
			err = va_arg(ap, int);
  8006ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ed:	8d 78 04             	lea    0x4(%eax),%edi
  8006f0:	8b 00                	mov    (%eax),%eax
  8006f2:	99                   	cltd   
  8006f3:	31 d0                	xor    %edx,%eax
  8006f5:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006f7:	83 f8 08             	cmp    $0x8,%eax
  8006fa:	7f 27                	jg     800723 <.L32+0x39>
  8006fc:	8b 94 83 20 00 00 00 	mov    0x20(%ebx,%eax,4),%edx
  800703:	85 d2                	test   %edx,%edx
  800705:	74 1c                	je     800723 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  800707:	52                   	push   %edx
  800708:	8d 83 1b f1 ff ff    	lea    -0xee5(%ebx),%eax
  80070e:	50                   	push   %eax
  80070f:	56                   	push   %esi
  800710:	ff 75 08             	pushl  0x8(%ebp)
  800713:	e8 a4 fe ff ff       	call   8005bc <printfmt>
  800718:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80071b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80071e:	e9 95 02 00 00       	jmp    8009b8 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  800723:	50                   	push   %eax
  800724:	8d 83 12 f1 ff ff    	lea    -0xeee(%ebx),%eax
  80072a:	50                   	push   %eax
  80072b:	56                   	push   %esi
  80072c:	ff 75 08             	pushl  0x8(%ebp)
  80072f:	e8 88 fe ff ff       	call   8005bc <printfmt>
  800734:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800737:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80073a:	e9 79 02 00 00       	jmp    8009b8 <.L35+0x45>

0080073f <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  80073f:	8b 45 14             	mov    0x14(%ebp),%eax
  800742:	83 c0 04             	add    $0x4,%eax
  800745:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80074d:	85 ff                	test   %edi,%edi
  80074f:	8d 83 0b f1 ff ff    	lea    -0xef5(%ebx),%eax
  800755:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800758:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80075c:	0f 8e b5 00 00 00    	jle    800817 <.L36+0xd8>
  800762:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800766:	75 08                	jne    800770 <.L36+0x31>
  800768:	89 75 0c             	mov    %esi,0xc(%ebp)
  80076b:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80076e:	eb 6d                	jmp    8007dd <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800770:	83 ec 08             	sub    $0x8,%esp
  800773:	ff 75 cc             	pushl  -0x34(%ebp)
  800776:	57                   	push   %edi
  800777:	e8 85 03 00 00       	call   800b01 <strnlen>
  80077c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80077f:	29 c2                	sub    %eax,%edx
  800781:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800784:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800787:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80078b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80078e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800791:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800793:	eb 10                	jmp    8007a5 <.L36+0x66>
					putch(padc, putdat);
  800795:	83 ec 08             	sub    $0x8,%esp
  800798:	56                   	push   %esi
  800799:	ff 75 e0             	pushl  -0x20(%ebp)
  80079c:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80079f:	83 ef 01             	sub    $0x1,%edi
  8007a2:	83 c4 10             	add    $0x10,%esp
  8007a5:	85 ff                	test   %edi,%edi
  8007a7:	7f ec                	jg     800795 <.L36+0x56>
  8007a9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007ac:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8007af:	85 d2                	test   %edx,%edx
  8007b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b6:	0f 49 c2             	cmovns %edx,%eax
  8007b9:	29 c2                	sub    %eax,%edx
  8007bb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8007be:	89 75 0c             	mov    %esi,0xc(%ebp)
  8007c1:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8007c4:	eb 17                	jmp    8007dd <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  8007c6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007ca:	75 30                	jne    8007fc <.L36+0xbd>
					putch(ch, putdat);
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	ff 75 0c             	pushl  0xc(%ebp)
  8007d2:	50                   	push   %eax
  8007d3:	ff 55 08             	call   *0x8(%ebp)
  8007d6:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007d9:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8007dd:	83 c7 01             	add    $0x1,%edi
  8007e0:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8007e4:	0f be c2             	movsbl %dl,%eax
  8007e7:	85 c0                	test   %eax,%eax
  8007e9:	74 52                	je     80083d <.L36+0xfe>
  8007eb:	85 f6                	test   %esi,%esi
  8007ed:	78 d7                	js     8007c6 <.L36+0x87>
  8007ef:	83 ee 01             	sub    $0x1,%esi
  8007f2:	79 d2                	jns    8007c6 <.L36+0x87>
  8007f4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8007f7:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8007fa:	eb 32                	jmp    80082e <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  8007fc:	0f be d2             	movsbl %dl,%edx
  8007ff:	83 ea 20             	sub    $0x20,%edx
  800802:	83 fa 5e             	cmp    $0x5e,%edx
  800805:	76 c5                	jbe    8007cc <.L36+0x8d>
					putch('?', putdat);
  800807:	83 ec 08             	sub    $0x8,%esp
  80080a:	ff 75 0c             	pushl  0xc(%ebp)
  80080d:	6a 3f                	push   $0x3f
  80080f:	ff 55 08             	call   *0x8(%ebp)
  800812:	83 c4 10             	add    $0x10,%esp
  800815:	eb c2                	jmp    8007d9 <.L36+0x9a>
  800817:	89 75 0c             	mov    %esi,0xc(%ebp)
  80081a:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80081d:	eb be                	jmp    8007dd <.L36+0x9e>
				putch(' ', putdat);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	56                   	push   %esi
  800823:	6a 20                	push   $0x20
  800825:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800828:	83 ef 01             	sub    $0x1,%edi
  80082b:	83 c4 10             	add    $0x10,%esp
  80082e:	85 ff                	test   %edi,%edi
  800830:	7f ed                	jg     80081f <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800832:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800835:	89 45 14             	mov    %eax,0x14(%ebp)
  800838:	e9 7b 01 00 00       	jmp    8009b8 <.L35+0x45>
  80083d:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800840:	8b 75 0c             	mov    0xc(%ebp),%esi
  800843:	eb e9                	jmp    80082e <.L36+0xef>

00800845 <.L31>:
  800845:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800848:	83 f9 01             	cmp    $0x1,%ecx
  80084b:	7e 40                	jle    80088d <.L31+0x48>
		return va_arg(*ap, long long);
  80084d:	8b 45 14             	mov    0x14(%ebp),%eax
  800850:	8b 50 04             	mov    0x4(%eax),%edx
  800853:	8b 00                	mov    (%eax),%eax
  800855:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800858:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80085b:	8b 45 14             	mov    0x14(%ebp),%eax
  80085e:	8d 40 08             	lea    0x8(%eax),%eax
  800861:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
  800864:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800868:	79 55                	jns    8008bf <.L31+0x7a>
				putch('-', putdat);
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	56                   	push   %esi
  80086e:	6a 2d                	push   $0x2d
  800870:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  800873:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800876:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800879:	f7 da                	neg    %edx
  80087b:	83 d1 00             	adc    $0x0,%ecx
  80087e:	f7 d9                	neg    %ecx
  800880:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
  800883:	b8 0a 00 00 00       	mov    $0xa,%eax
  800888:	e9 10 01 00 00       	jmp    80099d <.L35+0x2a>
	else if (lflag)
  80088d:	85 c9                	test   %ecx,%ecx
  80088f:	75 17                	jne    8008a8 <.L31+0x63>
		return va_arg(*ap, int);
  800891:	8b 45 14             	mov    0x14(%ebp),%eax
  800894:	8b 00                	mov    (%eax),%eax
  800896:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800899:	99                   	cltd   
  80089a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80089d:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a0:	8d 40 04             	lea    0x4(%eax),%eax
  8008a3:	89 45 14             	mov    %eax,0x14(%ebp)
  8008a6:	eb bc                	jmp    800864 <.L31+0x1f>
		return va_arg(*ap, long);
  8008a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ab:	8b 00                	mov    (%eax),%eax
  8008ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b0:	99                   	cltd   
  8008b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b7:	8d 40 04             	lea    0x4(%eax),%eax
  8008ba:	89 45 14             	mov    %eax,0x14(%ebp)
  8008bd:	eb a5                	jmp    800864 <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  8008bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008c2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
  8008c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008ca:	e9 ce 00 00 00       	jmp    80099d <.L35+0x2a>

008008cf <.L37>:
  8008cf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8008d2:	83 f9 01             	cmp    $0x1,%ecx
  8008d5:	7e 18                	jle    8008ef <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8008d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008da:	8b 10                	mov    (%eax),%edx
  8008dc:	8b 48 04             	mov    0x4(%eax),%ecx
  8008df:	8d 40 08             	lea    0x8(%eax),%eax
  8008e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8008e5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008ea:	e9 ae 00 00 00       	jmp    80099d <.L35+0x2a>
	else if (lflag)
  8008ef:	85 c9                	test   %ecx,%ecx
  8008f1:	75 1a                	jne    80090d <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8008f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f6:	8b 10                	mov    (%eax),%edx
  8008f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008fd:	8d 40 04             	lea    0x4(%eax),%eax
  800900:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800903:	b8 0a 00 00 00       	mov    $0xa,%eax
  800908:	e9 90 00 00 00       	jmp    80099d <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  80090d:	8b 45 14             	mov    0x14(%ebp),%eax
  800910:	8b 10                	mov    (%eax),%edx
  800912:	b9 00 00 00 00       	mov    $0x0,%ecx
  800917:	8d 40 04             	lea    0x4(%eax),%eax
  80091a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80091d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800922:	eb 79                	jmp    80099d <.L35+0x2a>

00800924 <.L34>:
  800924:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800927:	83 f9 01             	cmp    $0x1,%ecx
  80092a:	7e 15                	jle    800941 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  80092c:	8b 45 14             	mov    0x14(%ebp),%eax
  80092f:	8b 10                	mov    (%eax),%edx
  800931:	8b 48 04             	mov    0x4(%eax),%ecx
  800934:	8d 40 08             	lea    0x8(%eax),%eax
  800937:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80093a:	b8 08 00 00 00       	mov    $0x8,%eax
  80093f:	eb 5c                	jmp    80099d <.L35+0x2a>
	else if (lflag)
  800941:	85 c9                	test   %ecx,%ecx
  800943:	75 17                	jne    80095c <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800945:	8b 45 14             	mov    0x14(%ebp),%eax
  800948:	8b 10                	mov    (%eax),%edx
  80094a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80094f:	8d 40 04             	lea    0x4(%eax),%eax
  800952:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800955:	b8 08 00 00 00       	mov    $0x8,%eax
  80095a:	eb 41                	jmp    80099d <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  80095c:	8b 45 14             	mov    0x14(%ebp),%eax
  80095f:	8b 10                	mov    (%eax),%edx
  800961:	b9 00 00 00 00       	mov    $0x0,%ecx
  800966:	8d 40 04             	lea    0x4(%eax),%eax
  800969:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80096c:	b8 08 00 00 00       	mov    $0x8,%eax
  800971:	eb 2a                	jmp    80099d <.L35+0x2a>

00800973 <.L35>:
			putch('0', putdat);
  800973:	83 ec 08             	sub    $0x8,%esp
  800976:	56                   	push   %esi
  800977:	6a 30                	push   $0x30
  800979:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80097c:	83 c4 08             	add    $0x8,%esp
  80097f:	56                   	push   %esi
  800980:	6a 78                	push   $0x78
  800982:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800985:	8b 45 14             	mov    0x14(%ebp),%eax
  800988:	8b 10                	mov    (%eax),%edx
  80098a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80098f:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800992:	8d 40 04             	lea    0x4(%eax),%eax
  800995:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800998:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  80099d:	83 ec 0c             	sub    $0xc,%esp
  8009a0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8009a4:	57                   	push   %edi
  8009a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8009a8:	50                   	push   %eax
  8009a9:	51                   	push   %ecx
  8009aa:	52                   	push   %edx
  8009ab:	89 f2                	mov    %esi,%edx
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	e8 20 fb ff ff       	call   8004d5 <printnum>
			break;
  8009b5:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8009b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  8009bb:	83 c7 01             	add    $0x1,%edi
  8009be:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8009c2:	83 f8 25             	cmp    $0x25,%eax
  8009c5:	0f 84 2d fc ff ff    	je     8005f8 <vprintfmt+0x1f>
			if (ch == '\0')
  8009cb:	85 c0                	test   %eax,%eax
  8009cd:	0f 84 91 00 00 00    	je     800a64 <.L22+0x21>
			putch(ch, putdat);
  8009d3:	83 ec 08             	sub    $0x8,%esp
  8009d6:	56                   	push   %esi
  8009d7:	50                   	push   %eax
  8009d8:	ff 55 08             	call   *0x8(%ebp)
  8009db:	83 c4 10             	add    $0x10,%esp
  8009de:	eb db                	jmp    8009bb <.L35+0x48>

008009e0 <.L38>:
  8009e0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8009e3:	83 f9 01             	cmp    $0x1,%ecx
  8009e6:	7e 15                	jle    8009fd <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8009e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009eb:	8b 10                	mov    (%eax),%edx
  8009ed:	8b 48 04             	mov    0x4(%eax),%ecx
  8009f0:	8d 40 08             	lea    0x8(%eax),%eax
  8009f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009f6:	b8 10 00 00 00       	mov    $0x10,%eax
  8009fb:	eb a0                	jmp    80099d <.L35+0x2a>
	else if (lflag)
  8009fd:	85 c9                	test   %ecx,%ecx
  8009ff:	75 17                	jne    800a18 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  800a01:	8b 45 14             	mov    0x14(%ebp),%eax
  800a04:	8b 10                	mov    (%eax),%edx
  800a06:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a0b:	8d 40 04             	lea    0x4(%eax),%eax
  800a0e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a11:	b8 10 00 00 00       	mov    $0x10,%eax
  800a16:	eb 85                	jmp    80099d <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800a18:	8b 45 14             	mov    0x14(%ebp),%eax
  800a1b:	8b 10                	mov    (%eax),%edx
  800a1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a22:	8d 40 04             	lea    0x4(%eax),%eax
  800a25:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a28:	b8 10 00 00 00       	mov    $0x10,%eax
  800a2d:	e9 6b ff ff ff       	jmp    80099d <.L35+0x2a>

00800a32 <.L25>:
			putch(ch, putdat);
  800a32:	83 ec 08             	sub    $0x8,%esp
  800a35:	56                   	push   %esi
  800a36:	6a 25                	push   $0x25
  800a38:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a3b:	83 c4 10             	add    $0x10,%esp
  800a3e:	e9 75 ff ff ff       	jmp    8009b8 <.L35+0x45>

00800a43 <.L22>:
			putch('%', putdat);
  800a43:	83 ec 08             	sub    $0x8,%esp
  800a46:	56                   	push   %esi
  800a47:	6a 25                	push   $0x25
  800a49:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a4c:	83 c4 10             	add    $0x10,%esp
  800a4f:	89 f8                	mov    %edi,%eax
  800a51:	eb 03                	jmp    800a56 <.L22+0x13>
  800a53:	83 e8 01             	sub    $0x1,%eax
  800a56:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800a5a:	75 f7                	jne    800a53 <.L22+0x10>
  800a5c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a5f:	e9 54 ff ff ff       	jmp    8009b8 <.L35+0x45>
}
  800a64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a67:	5b                   	pop    %ebx
  800a68:	5e                   	pop    %esi
  800a69:	5f                   	pop    %edi
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	53                   	push   %ebx
  800a70:	83 ec 14             	sub    $0x14,%esp
  800a73:	e8 1d f6 ff ff       	call   800095 <__x86.get_pc_thunk.bx>
  800a78:	81 c3 88 15 00 00    	add    $0x1588,%ebx
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  800a84:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a87:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a8b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a8e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a95:	85 c0                	test   %eax,%eax
  800a97:	74 2b                	je     800ac4 <vsnprintf+0x58>
  800a99:	85 d2                	test   %edx,%edx
  800a9b:	7e 27                	jle    800ac4 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  800a9d:	ff 75 14             	pushl  0x14(%ebp)
  800aa0:	ff 75 10             	pushl  0x10(%ebp)
  800aa3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800aa6:	50                   	push   %eax
  800aa7:	8d 83 9f e5 ff ff    	lea    -0x1a61(%ebx),%eax
  800aad:	50                   	push   %eax
  800aae:	e8 26 fb ff ff       	call   8005d9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ab3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ab6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800abc:	83 c4 10             	add    $0x10,%esp
}
  800abf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac2:	c9                   	leave  
  800ac3:	c3                   	ret    
		return -E_INVAL;
  800ac4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ac9:	eb f4                	jmp    800abf <vsnprintf+0x53>

00800acb <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ad1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ad4:	50                   	push   %eax
  800ad5:	ff 75 10             	pushl  0x10(%ebp)
  800ad8:	ff 75 0c             	pushl  0xc(%ebp)
  800adb:	ff 75 08             	pushl  0x8(%ebp)
  800ade:	e8 89 ff ff ff       	call   800a6c <vsnprintf>
	va_end(ap);

	return rc;
}
  800ae3:	c9                   	leave  
  800ae4:	c3                   	ret    

00800ae5 <__x86.get_pc_thunk.cx>:
  800ae5:	8b 0c 24             	mov    (%esp),%ecx
  800ae8:	c3                   	ret    

00800ae9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800aef:	b8 00 00 00 00       	mov    $0x0,%eax
  800af4:	eb 03                	jmp    800af9 <strlen+0x10>
		n++;
  800af6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800af9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800afd:	75 f7                	jne    800af6 <strlen+0xd>
	return n;
}
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b07:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0f:	eb 03                	jmp    800b14 <strnlen+0x13>
		n++;
  800b11:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b14:	39 d0                	cmp    %edx,%eax
  800b16:	74 06                	je     800b1e <strnlen+0x1d>
  800b18:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b1c:	75 f3                	jne    800b11 <strnlen+0x10>
	return n;
}
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	53                   	push   %ebx
  800b24:	8b 45 08             	mov    0x8(%ebp),%eax
  800b27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b2a:	89 c2                	mov    %eax,%edx
  800b2c:	83 c1 01             	add    $0x1,%ecx
  800b2f:	83 c2 01             	add    $0x1,%edx
  800b32:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b36:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b39:	84 db                	test   %bl,%bl
  800b3b:	75 ef                	jne    800b2c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b3d:	5b                   	pop    %ebx
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	53                   	push   %ebx
  800b44:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b47:	53                   	push   %ebx
  800b48:	e8 9c ff ff ff       	call   800ae9 <strlen>
  800b4d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b50:	ff 75 0c             	pushl  0xc(%ebp)
  800b53:	01 d8                	add    %ebx,%eax
  800b55:	50                   	push   %eax
  800b56:	e8 c5 ff ff ff       	call   800b20 <strcpy>
	return dst;
}
  800b5b:	89 d8                	mov    %ebx,%eax
  800b5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b60:	c9                   	leave  
  800b61:	c3                   	ret    

00800b62 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
  800b67:	8b 75 08             	mov    0x8(%ebp),%esi
  800b6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6d:	89 f3                	mov    %esi,%ebx
  800b6f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b72:	89 f2                	mov    %esi,%edx
  800b74:	eb 0f                	jmp    800b85 <strncpy+0x23>
		*dst++ = *src;
  800b76:	83 c2 01             	add    $0x1,%edx
  800b79:	0f b6 01             	movzbl (%ecx),%eax
  800b7c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b7f:	80 39 01             	cmpb   $0x1,(%ecx)
  800b82:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800b85:	39 da                	cmp    %ebx,%edx
  800b87:	75 ed                	jne    800b76 <strncpy+0x14>
	}
	return ret;
}
  800b89:	89 f0                	mov    %esi,%eax
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
  800b94:	8b 75 08             	mov    0x8(%ebp),%esi
  800b97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b9d:	89 f0                	mov    %esi,%eax
  800b9f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ba3:	85 c9                	test   %ecx,%ecx
  800ba5:	75 0b                	jne    800bb2 <strlcpy+0x23>
  800ba7:	eb 17                	jmp    800bc0 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ba9:	83 c2 01             	add    $0x1,%edx
  800bac:	83 c0 01             	add    $0x1,%eax
  800baf:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800bb2:	39 d8                	cmp    %ebx,%eax
  800bb4:	74 07                	je     800bbd <strlcpy+0x2e>
  800bb6:	0f b6 0a             	movzbl (%edx),%ecx
  800bb9:	84 c9                	test   %cl,%cl
  800bbb:	75 ec                	jne    800ba9 <strlcpy+0x1a>
		*dst = '\0';
  800bbd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bc0:	29 f0                	sub    %esi,%eax
}
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bcf:	eb 06                	jmp    800bd7 <strcmp+0x11>
		p++, q++;
  800bd1:	83 c1 01             	add    $0x1,%ecx
  800bd4:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800bd7:	0f b6 01             	movzbl (%ecx),%eax
  800bda:	84 c0                	test   %al,%al
  800bdc:	74 04                	je     800be2 <strcmp+0x1c>
  800bde:	3a 02                	cmp    (%edx),%al
  800be0:	74 ef                	je     800bd1 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800be2:	0f b6 c0             	movzbl %al,%eax
  800be5:	0f b6 12             	movzbl (%edx),%edx
  800be8:	29 d0                	sub    %edx,%eax
}
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	53                   	push   %ebx
  800bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf6:	89 c3                	mov    %eax,%ebx
  800bf8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800bfb:	eb 06                	jmp    800c03 <strncmp+0x17>
		n--, p++, q++;
  800bfd:	83 c0 01             	add    $0x1,%eax
  800c00:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c03:	39 d8                	cmp    %ebx,%eax
  800c05:	74 16                	je     800c1d <strncmp+0x31>
  800c07:	0f b6 08             	movzbl (%eax),%ecx
  800c0a:	84 c9                	test   %cl,%cl
  800c0c:	74 04                	je     800c12 <strncmp+0x26>
  800c0e:	3a 0a                	cmp    (%edx),%cl
  800c10:	74 eb                	je     800bfd <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c12:	0f b6 00             	movzbl (%eax),%eax
  800c15:	0f b6 12             	movzbl (%edx),%edx
  800c18:	29 d0                	sub    %edx,%eax
}
  800c1a:	5b                   	pop    %ebx
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    
		return 0;
  800c1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c22:	eb f6                	jmp    800c1a <strncmp+0x2e>

00800c24 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c2e:	0f b6 10             	movzbl (%eax),%edx
  800c31:	84 d2                	test   %dl,%dl
  800c33:	74 09                	je     800c3e <strchr+0x1a>
		if (*s == c)
  800c35:	38 ca                	cmp    %cl,%dl
  800c37:	74 0a                	je     800c43 <strchr+0x1f>
	for (; *s; s++)
  800c39:	83 c0 01             	add    $0x1,%eax
  800c3c:	eb f0                	jmp    800c2e <strchr+0xa>
			return (char *) s;
	return 0;
  800c3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c4f:	eb 03                	jmp    800c54 <strfind+0xf>
  800c51:	83 c0 01             	add    $0x1,%eax
  800c54:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c57:	38 ca                	cmp    %cl,%dl
  800c59:	74 04                	je     800c5f <strfind+0x1a>
  800c5b:	84 d2                	test   %dl,%dl
  800c5d:	75 f2                	jne    800c51 <strfind+0xc>
			break;
	return (char *) s;
}
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c6a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c6d:	85 c9                	test   %ecx,%ecx
  800c6f:	74 13                	je     800c84 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c71:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c77:	75 05                	jne    800c7e <memset+0x1d>
  800c79:	f6 c1 03             	test   $0x3,%cl
  800c7c:	74 0d                	je     800c8b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c81:	fc                   	cld    
  800c82:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c84:	89 f8                	mov    %edi,%eax
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    
		c &= 0xFF;
  800c8b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c8f:	89 d3                	mov    %edx,%ebx
  800c91:	c1 e3 08             	shl    $0x8,%ebx
  800c94:	89 d0                	mov    %edx,%eax
  800c96:	c1 e0 18             	shl    $0x18,%eax
  800c99:	89 d6                	mov    %edx,%esi
  800c9b:	c1 e6 10             	shl    $0x10,%esi
  800c9e:	09 f0                	or     %esi,%eax
  800ca0:	09 c2                	or     %eax,%edx
  800ca2:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ca4:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ca7:	89 d0                	mov    %edx,%eax
  800ca9:	fc                   	cld    
  800caa:	f3 ab                	rep stos %eax,%es:(%edi)
  800cac:	eb d6                	jmp    800c84 <memset+0x23>

00800cae <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cb9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cbc:	39 c6                	cmp    %eax,%esi
  800cbe:	73 35                	jae    800cf5 <memmove+0x47>
  800cc0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cc3:	39 c2                	cmp    %eax,%edx
  800cc5:	76 2e                	jbe    800cf5 <memmove+0x47>
		s += n;
		d += n;
  800cc7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cca:	89 d6                	mov    %edx,%esi
  800ccc:	09 fe                	or     %edi,%esi
  800cce:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cd4:	74 0c                	je     800ce2 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cd6:	83 ef 01             	sub    $0x1,%edi
  800cd9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800cdc:	fd                   	std    
  800cdd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cdf:	fc                   	cld    
  800ce0:	eb 21                	jmp    800d03 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ce2:	f6 c1 03             	test   $0x3,%cl
  800ce5:	75 ef                	jne    800cd6 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ce7:	83 ef 04             	sub    $0x4,%edi
  800cea:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ced:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800cf0:	fd                   	std    
  800cf1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cf3:	eb ea                	jmp    800cdf <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf5:	89 f2                	mov    %esi,%edx
  800cf7:	09 c2                	or     %eax,%edx
  800cf9:	f6 c2 03             	test   $0x3,%dl
  800cfc:	74 09                	je     800d07 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cfe:	89 c7                	mov    %eax,%edi
  800d00:	fc                   	cld    
  800d01:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d07:	f6 c1 03             	test   $0x3,%cl
  800d0a:	75 f2                	jne    800cfe <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d0c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d0f:	89 c7                	mov    %eax,%edi
  800d11:	fc                   	cld    
  800d12:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d14:	eb ed                	jmp    800d03 <memmove+0x55>

00800d16 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d19:	ff 75 10             	pushl  0x10(%ebp)
  800d1c:	ff 75 0c             	pushl  0xc(%ebp)
  800d1f:	ff 75 08             	pushl  0x8(%ebp)
  800d22:	e8 87 ff ff ff       	call   800cae <memmove>
}
  800d27:	c9                   	leave  
  800d28:	c3                   	ret    

00800d29 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
  800d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d31:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d34:	89 c6                	mov    %eax,%esi
  800d36:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d39:	39 f0                	cmp    %esi,%eax
  800d3b:	74 1c                	je     800d59 <memcmp+0x30>
		if (*s1 != *s2)
  800d3d:	0f b6 08             	movzbl (%eax),%ecx
  800d40:	0f b6 1a             	movzbl (%edx),%ebx
  800d43:	38 d9                	cmp    %bl,%cl
  800d45:	75 08                	jne    800d4f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800d47:	83 c0 01             	add    $0x1,%eax
  800d4a:	83 c2 01             	add    $0x1,%edx
  800d4d:	eb ea                	jmp    800d39 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800d4f:	0f b6 c1             	movzbl %cl,%eax
  800d52:	0f b6 db             	movzbl %bl,%ebx
  800d55:	29 d8                	sub    %ebx,%eax
  800d57:	eb 05                	jmp    800d5e <memcmp+0x35>
	}

	return 0;
  800d59:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    

00800d62 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	8b 45 08             	mov    0x8(%ebp),%eax
  800d68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d6b:	89 c2                	mov    %eax,%edx
  800d6d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d70:	39 d0                	cmp    %edx,%eax
  800d72:	73 09                	jae    800d7d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d74:	38 08                	cmp    %cl,(%eax)
  800d76:	74 05                	je     800d7d <memfind+0x1b>
	for (; s < ends; s++)
  800d78:	83 c0 01             	add    $0x1,%eax
  800d7b:	eb f3                	jmp    800d70 <memfind+0xe>
			break;
	return (void *) s;
}
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	57                   	push   %edi
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
  800d85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d88:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d8b:	eb 03                	jmp    800d90 <strtol+0x11>
		s++;
  800d8d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d90:	0f b6 01             	movzbl (%ecx),%eax
  800d93:	3c 20                	cmp    $0x20,%al
  800d95:	74 f6                	je     800d8d <strtol+0xe>
  800d97:	3c 09                	cmp    $0x9,%al
  800d99:	74 f2                	je     800d8d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800d9b:	3c 2b                	cmp    $0x2b,%al
  800d9d:	74 2e                	je     800dcd <strtol+0x4e>
	int neg = 0;
  800d9f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800da4:	3c 2d                	cmp    $0x2d,%al
  800da6:	74 2f                	je     800dd7 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800da8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dae:	75 05                	jne    800db5 <strtol+0x36>
  800db0:	80 39 30             	cmpb   $0x30,(%ecx)
  800db3:	74 2c                	je     800de1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800db5:	85 db                	test   %ebx,%ebx
  800db7:	75 0a                	jne    800dc3 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800db9:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800dbe:	80 39 30             	cmpb   $0x30,(%ecx)
  800dc1:	74 28                	je     800deb <strtol+0x6c>
		base = 10;
  800dc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800dcb:	eb 50                	jmp    800e1d <strtol+0x9e>
		s++;
  800dcd:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800dd0:	bf 00 00 00 00       	mov    $0x0,%edi
  800dd5:	eb d1                	jmp    800da8 <strtol+0x29>
		s++, neg = 1;
  800dd7:	83 c1 01             	add    $0x1,%ecx
  800dda:	bf 01 00 00 00       	mov    $0x1,%edi
  800ddf:	eb c7                	jmp    800da8 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800de1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800de5:	74 0e                	je     800df5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800de7:	85 db                	test   %ebx,%ebx
  800de9:	75 d8                	jne    800dc3 <strtol+0x44>
		s++, base = 8;
  800deb:	83 c1 01             	add    $0x1,%ecx
  800dee:	bb 08 00 00 00       	mov    $0x8,%ebx
  800df3:	eb ce                	jmp    800dc3 <strtol+0x44>
		s += 2, base = 16;
  800df5:	83 c1 02             	add    $0x2,%ecx
  800df8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800dfd:	eb c4                	jmp    800dc3 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800dff:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e02:	89 f3                	mov    %esi,%ebx
  800e04:	80 fb 19             	cmp    $0x19,%bl
  800e07:	77 29                	ja     800e32 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800e09:	0f be d2             	movsbl %dl,%edx
  800e0c:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e0f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e12:	7d 30                	jge    800e44 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800e14:	83 c1 01             	add    $0x1,%ecx
  800e17:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e1b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800e1d:	0f b6 11             	movzbl (%ecx),%edx
  800e20:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e23:	89 f3                	mov    %esi,%ebx
  800e25:	80 fb 09             	cmp    $0x9,%bl
  800e28:	77 d5                	ja     800dff <strtol+0x80>
			dig = *s - '0';
  800e2a:	0f be d2             	movsbl %dl,%edx
  800e2d:	83 ea 30             	sub    $0x30,%edx
  800e30:	eb dd                	jmp    800e0f <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800e32:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e35:	89 f3                	mov    %esi,%ebx
  800e37:	80 fb 19             	cmp    $0x19,%bl
  800e3a:	77 08                	ja     800e44 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800e3c:	0f be d2             	movsbl %dl,%edx
  800e3f:	83 ea 37             	sub    $0x37,%edx
  800e42:	eb cb                	jmp    800e0f <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800e44:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e48:	74 05                	je     800e4f <strtol+0xd0>
		*endptr = (char *) s;
  800e4a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e4d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800e4f:	89 c2                	mov    %eax,%edx
  800e51:	f7 da                	neg    %edx
  800e53:	85 ff                	test   %edi,%edi
  800e55:	0f 45 c2             	cmovne %edx,%eax
}
  800e58:	5b                   	pop    %ebx
  800e59:	5e                   	pop    %esi
  800e5a:	5f                   	pop    %edi
  800e5b:	5d                   	pop    %ebp
  800e5c:	c3                   	ret    
  800e5d:	66 90                	xchg   %ax,%ax
  800e5f:	90                   	nop

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
