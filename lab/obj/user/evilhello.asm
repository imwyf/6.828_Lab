
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 2c 00 00 00       	call   80005d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 1a 00 00 00       	call   800059 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800045:	6a 64                	push   $0x64
  800047:	68 0c 00 10 f0       	push   $0xf010000c
  80004c:	e8 88 00 00 00       	call   8000d9 <sys_cputs>
}
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800057:	c9                   	leave  
  800058:	c3                   	ret    

00800059 <__x86.get_pc_thunk.bx>:
  800059:	8b 1c 24             	mov    (%esp),%ebx
  80005c:	c3                   	ret    

0080005d <libmain>:

const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void libmain(int argc, char **argv)
{
  80005d:	55                   	push   %ebp
  80005e:	89 e5                	mov    %esp,%ebp
  800060:	57                   	push   %edi
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	e8 ee ff ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  80006b:	81 c3 95 1f 00 00    	add    $0x1f95,%ebx
  800071:	8b 75 08             	mov    0x8(%ebp),%esi
  800074:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())]; // ENVX()得到id在Env[]数组中对应的下标
  800077:	e8 ef 00 00 00       	call   80016b <sys_getenvid>
  80007c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800081:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800084:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  80008a:	c7 c2 44 20 80 00    	mov    $0x802044,%edx
  800090:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800092:	85 f6                	test   %esi,%esi
  800094:	7e 08                	jle    80009e <libmain+0x41>
		binaryname = argv[0];
  800096:	8b 07                	mov    (%edi),%eax
  800098:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80009e:	83 ec 08             	sub    $0x8,%esp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	e8 8b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a8:	e8 0b 00 00 00       	call   8000b8 <exit>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 10             	sub    $0x10,%esp
  8000bf:	e8 95 ff ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  8000c4:	81 c3 3c 1f 00 00    	add    $0x1f3c,%ebx
	sys_env_destroy(0);
  8000ca:	6a 00                	push   $0x0
  8000cc:	e8 45 00 00 00       	call   800116 <sys_env_destroy>
}
  8000d1:	83 c4 10             	add    $0x10,%esp
  8000d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000d7:	c9                   	leave  
  8000d8:	c3                   	ret    

008000d9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	57                   	push   %edi
  8000dd:	56                   	push   %esi
  8000de:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000df:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ea:	89 c3                	mov    %eax,%ebx
  8000ec:	89 c7                	mov    %eax,%edi
  8000ee:	89 c6                	mov    %eax,%esi
  8000f0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f2:	5b                   	pop    %ebx
  8000f3:	5e                   	pop    %esi
  8000f4:	5f                   	pop    %edi
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	57                   	push   %edi
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800102:	b8 01 00 00 00       	mov    $0x1,%eax
  800107:	89 d1                	mov    %edx,%ecx
  800109:	89 d3                	mov    %edx,%ebx
  80010b:	89 d7                	mov    %edx,%edi
  80010d:	89 d6                	mov    %edx,%esi
  80010f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800111:	5b                   	pop    %ebx
  800112:	5e                   	pop    %esi
  800113:	5f                   	pop    %edi
  800114:	5d                   	pop    %ebp
  800115:	c3                   	ret    

00800116 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	57                   	push   %edi
  80011a:	56                   	push   %esi
  80011b:	53                   	push   %ebx
  80011c:	83 ec 1c             	sub    $0x1c,%esp
  80011f:	e8 ac 02 00 00       	call   8003d0 <__x86.get_pc_thunk.ax>
  800124:	05 dc 1e 00 00       	add    $0x1edc,%eax
  800129:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80012c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800131:	8b 55 08             	mov    0x8(%ebp),%edx
  800134:	b8 03 00 00 00       	mov    $0x3,%eax
  800139:	89 cb                	mov    %ecx,%ebx
  80013b:	89 cf                	mov    %ecx,%edi
  80013d:	89 ce                	mov    %ecx,%esi
  80013f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800141:	85 c0                	test   %eax,%eax
  800143:	7f 08                	jg     80014d <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800145:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800148:	5b                   	pop    %ebx
  800149:	5e                   	pop    %esi
  80014a:	5f                   	pop    %edi
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80014d:	83 ec 0c             	sub    $0xc,%esp
  800150:	50                   	push   %eax
  800151:	6a 03                	push   $0x3
  800153:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800156:	8d 83 c6 f0 ff ff    	lea    -0xf3a(%ebx),%eax
  80015c:	50                   	push   %eax
  80015d:	6a 23                	push   $0x23
  80015f:	8d 83 e3 f0 ff ff    	lea    -0xf1d(%ebx),%eax
  800165:	50                   	push   %eax
  800166:	e8 69 02 00 00       	call   8003d4 <_panic>

0080016b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	57                   	push   %edi
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
	asm volatile("int %1\n"
  800171:	ba 00 00 00 00       	mov    $0x0,%edx
  800176:	b8 02 00 00 00       	mov    $0x2,%eax
  80017b:	89 d1                	mov    %edx,%ecx
  80017d:	89 d3                	mov    %edx,%ebx
  80017f:	89 d7                	mov    %edx,%edi
  800181:	89 d6                	mov    %edx,%esi
  800183:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800185:	5b                   	pop    %ebx
  800186:	5e                   	pop    %esi
  800187:	5f                   	pop    %edi
  800188:	5d                   	pop    %ebp
  800189:	c3                   	ret    

0080018a <sys_yield>:

void
sys_yield(void)
{
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	57                   	push   %edi
  80018e:	56                   	push   %esi
  80018f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800190:	ba 00 00 00 00       	mov    $0x0,%edx
  800195:	b8 0a 00 00 00       	mov    $0xa,%eax
  80019a:	89 d1                	mov    %edx,%ecx
  80019c:	89 d3                	mov    %edx,%ebx
  80019e:	89 d7                	mov    %edx,%edi
  8001a0:	89 d6                	mov    %edx,%esi
  8001a2:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001a4:	5b                   	pop    %ebx
  8001a5:	5e                   	pop    %esi
  8001a6:	5f                   	pop    %edi
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    

008001a9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 1c             	sub    $0x1c,%esp
  8001b2:	e8 19 02 00 00       	call   8003d0 <__x86.get_pc_thunk.ax>
  8001b7:	05 49 1e 00 00       	add    $0x1e49,%eax
  8001bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8001bf:	be 00 00 00 00       	mov    $0x0,%esi
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ca:	b8 04 00 00 00       	mov    $0x4,%eax
  8001cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d2:	89 f7                	mov    %esi,%edi
  8001d4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001d6:	85 c0                	test   %eax,%eax
  8001d8:	7f 08                	jg     8001e2 <sys_page_alloc+0x39>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001dd:	5b                   	pop    %ebx
  8001de:	5e                   	pop    %esi
  8001df:	5f                   	pop    %edi
  8001e0:	5d                   	pop    %ebp
  8001e1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e2:	83 ec 0c             	sub    $0xc,%esp
  8001e5:	50                   	push   %eax
  8001e6:	6a 04                	push   $0x4
  8001e8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8001eb:	8d 83 c6 f0 ff ff    	lea    -0xf3a(%ebx),%eax
  8001f1:	50                   	push   %eax
  8001f2:	6a 23                	push   $0x23
  8001f4:	8d 83 e3 f0 ff ff    	lea    -0xf1d(%ebx),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 d4 01 00 00       	call   8003d4 <_panic>

00800200 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	57                   	push   %edi
  800204:	56                   	push   %esi
  800205:	53                   	push   %ebx
  800206:	83 ec 1c             	sub    $0x1c,%esp
  800209:	e8 c2 01 00 00       	call   8003d0 <__x86.get_pc_thunk.ax>
  80020e:	05 f2 1d 00 00       	add    $0x1df2,%eax
  800213:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800216:	8b 55 08             	mov    0x8(%ebp),%edx
  800219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021c:	b8 05 00 00 00       	mov    $0x5,%eax
  800221:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800224:	8b 7d 14             	mov    0x14(%ebp),%edi
  800227:	8b 75 18             	mov    0x18(%ebp),%esi
  80022a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80022c:	85 c0                	test   %eax,%eax
  80022e:	7f 08                	jg     800238 <sys_page_map+0x38>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800230:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800233:	5b                   	pop    %ebx
  800234:	5e                   	pop    %esi
  800235:	5f                   	pop    %edi
  800236:	5d                   	pop    %ebp
  800237:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800238:	83 ec 0c             	sub    $0xc,%esp
  80023b:	50                   	push   %eax
  80023c:	6a 05                	push   $0x5
  80023e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800241:	8d 83 c6 f0 ff ff    	lea    -0xf3a(%ebx),%eax
  800247:	50                   	push   %eax
  800248:	6a 23                	push   $0x23
  80024a:	8d 83 e3 f0 ff ff    	lea    -0xf1d(%ebx),%eax
  800250:	50                   	push   %eax
  800251:	e8 7e 01 00 00       	call   8003d4 <_panic>

00800256 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	57                   	push   %edi
  80025a:	56                   	push   %esi
  80025b:	53                   	push   %ebx
  80025c:	83 ec 1c             	sub    $0x1c,%esp
  80025f:	e8 6c 01 00 00       	call   8003d0 <__x86.get_pc_thunk.ax>
  800264:	05 9c 1d 00 00       	add    $0x1d9c,%eax
  800269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	8b 55 08             	mov    0x8(%ebp),%edx
  800274:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800277:	b8 06 00 00 00       	mov    $0x6,%eax
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30
	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7f 08                	jg     80028e <sys_page_unmap+0x38>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800286:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800289:	5b                   	pop    %ebx
  80028a:	5e                   	pop    %esi
  80028b:	5f                   	pop    %edi
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80028e:	83 ec 0c             	sub    $0xc,%esp
  800291:	50                   	push   %eax
  800292:	6a 06                	push   $0x6
  800294:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800297:	8d 83 c6 f0 ff ff    	lea    -0xf3a(%ebx),%eax
  80029d:	50                   	push   %eax
  80029e:	6a 23                	push   $0x23
  8002a0:	8d 83 e3 f0 ff ff    	lea    -0xf1d(%ebx),%eax
  8002a6:	50                   	push   %eax
  8002a7:	e8 28 01 00 00       	call   8003d4 <_panic>

008002ac <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	57                   	push   %edi
  8002b0:	56                   	push   %esi
  8002b1:	53                   	push   %ebx
  8002b2:	83 ec 1c             	sub    $0x1c,%esp
  8002b5:	e8 16 01 00 00       	call   8003d0 <__x86.get_pc_thunk.ax>
  8002ba:	05 46 1d 00 00       	add    $0x1d46,%eax
  8002bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8002c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cd:	b8 08 00 00 00       	mov    $0x8,%eax
  8002d2:	89 df                	mov    %ebx,%edi
  8002d4:	89 de                	mov    %ebx,%esi
  8002d6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d8:	85 c0                	test   %eax,%eax
  8002da:	7f 08                	jg     8002e4 <sys_env_set_status+0x38>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002df:	5b                   	pop    %ebx
  8002e0:	5e                   	pop    %esi
  8002e1:	5f                   	pop    %edi
  8002e2:	5d                   	pop    %ebp
  8002e3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e4:	83 ec 0c             	sub    $0xc,%esp
  8002e7:	50                   	push   %eax
  8002e8:	6a 08                	push   $0x8
  8002ea:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002ed:	8d 83 c6 f0 ff ff    	lea    -0xf3a(%ebx),%eax
  8002f3:	50                   	push   %eax
  8002f4:	6a 23                	push   $0x23
  8002f6:	8d 83 e3 f0 ff ff    	lea    -0xf1d(%ebx),%eax
  8002fc:	50                   	push   %eax
  8002fd:	e8 d2 00 00 00       	call   8003d4 <_panic>

00800302 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800302:	55                   	push   %ebp
  800303:	89 e5                	mov    %esp,%ebp
  800305:	57                   	push   %edi
  800306:	56                   	push   %esi
  800307:	53                   	push   %ebx
  800308:	83 ec 1c             	sub    $0x1c,%esp
  80030b:	e8 c0 00 00 00       	call   8003d0 <__x86.get_pc_thunk.ax>
  800310:	05 f0 1c 00 00       	add    $0x1cf0,%eax
  800315:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800318:	bb 00 00 00 00       	mov    $0x0,%ebx
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800323:	b8 09 00 00 00       	mov    $0x9,%eax
  800328:	89 df                	mov    %ebx,%edi
  80032a:	89 de                	mov    %ebx,%esi
  80032c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80032e:	85 c0                	test   %eax,%eax
  800330:	7f 08                	jg     80033a <sys_env_set_pgfault_upcall+0x38>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800332:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800335:	5b                   	pop    %ebx
  800336:	5e                   	pop    %esi
  800337:	5f                   	pop    %edi
  800338:	5d                   	pop    %ebp
  800339:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80033a:	83 ec 0c             	sub    $0xc,%esp
  80033d:	50                   	push   %eax
  80033e:	6a 09                	push   $0x9
  800340:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800343:	8d 83 c6 f0 ff ff    	lea    -0xf3a(%ebx),%eax
  800349:	50                   	push   %eax
  80034a:	6a 23                	push   $0x23
  80034c:	8d 83 e3 f0 ff ff    	lea    -0xf1d(%ebx),%eax
  800352:	50                   	push   %eax
  800353:	e8 7c 00 00 00       	call   8003d4 <_panic>

00800358 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	57                   	push   %edi
  80035c:	56                   	push   %esi
  80035d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80035e:	8b 55 08             	mov    0x8(%ebp),%edx
  800361:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800364:	b8 0b 00 00 00       	mov    $0xb,%eax
  800369:	be 00 00 00 00       	mov    $0x0,%esi
  80036e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800371:	8b 7d 14             	mov    0x14(%ebp),%edi
  800374:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800376:	5b                   	pop    %ebx
  800377:	5e                   	pop    %esi
  800378:	5f                   	pop    %edi
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	57                   	push   %edi
  80037f:	56                   	push   %esi
  800380:	53                   	push   %ebx
  800381:	83 ec 1c             	sub    $0x1c,%esp
  800384:	e8 47 00 00 00       	call   8003d0 <__x86.get_pc_thunk.ax>
  800389:	05 77 1c 00 00       	add    $0x1c77,%eax
  80038e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800391:	b9 00 00 00 00       	mov    $0x0,%ecx
  800396:	8b 55 08             	mov    0x8(%ebp),%edx
  800399:	b8 0c 00 00 00       	mov    $0xc,%eax
  80039e:	89 cb                	mov    %ecx,%ebx
  8003a0:	89 cf                	mov    %ecx,%edi
  8003a2:	89 ce                	mov    %ecx,%esi
  8003a4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	7f 08                	jg     8003b2 <sys_ipc_recv+0x37>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ad:	5b                   	pop    %ebx
  8003ae:	5e                   	pop    %esi
  8003af:	5f                   	pop    %edi
  8003b0:	5d                   	pop    %ebp
  8003b1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b2:	83 ec 0c             	sub    $0xc,%esp
  8003b5:	50                   	push   %eax
  8003b6:	6a 0c                	push   $0xc
  8003b8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8003bb:	8d 83 c6 f0 ff ff    	lea    -0xf3a(%ebx),%eax
  8003c1:	50                   	push   %eax
  8003c2:	6a 23                	push   $0x23
  8003c4:	8d 83 e3 f0 ff ff    	lea    -0xf1d(%ebx),%eax
  8003ca:	50                   	push   %eax
  8003cb:	e8 04 00 00 00       	call   8003d4 <_panic>

008003d0 <__x86.get_pc_thunk.ax>:
  8003d0:	8b 04 24             	mov    (%esp),%eax
  8003d3:	c3                   	ret    

008003d4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
  8003d7:	57                   	push   %edi
  8003d8:	56                   	push   %esi
  8003d9:	53                   	push   %ebx
  8003da:	83 ec 0c             	sub    $0xc,%esp
  8003dd:	e8 77 fc ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  8003e2:	81 c3 1e 1c 00 00    	add    $0x1c1e,%ebx
	va_list ap;

	va_start(ap, fmt);
  8003e8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003eb:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  8003f1:	8b 38                	mov    (%eax),%edi
  8003f3:	e8 73 fd ff ff       	call   80016b <sys_getenvid>
  8003f8:	83 ec 0c             	sub    $0xc,%esp
  8003fb:	ff 75 0c             	pushl  0xc(%ebp)
  8003fe:	ff 75 08             	pushl  0x8(%ebp)
  800401:	57                   	push   %edi
  800402:	50                   	push   %eax
  800403:	8d 83 f4 f0 ff ff    	lea    -0xf0c(%ebx),%eax
  800409:	50                   	push   %eax
  80040a:	e8 d1 00 00 00       	call   8004e0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80040f:	83 c4 18             	add    $0x18,%esp
  800412:	56                   	push   %esi
  800413:	ff 75 10             	pushl  0x10(%ebp)
  800416:	e8 63 00 00 00       	call   80047e <vcprintf>
	cprintf("\n");
  80041b:	8d 83 18 f1 ff ff    	lea    -0xee8(%ebx),%eax
  800421:	89 04 24             	mov    %eax,(%esp)
  800424:	e8 b7 00 00 00       	call   8004e0 <cprintf>
  800429:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80042c:	cc                   	int3   
  80042d:	eb fd                	jmp    80042c <_panic+0x58>

0080042f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
  800432:	56                   	push   %esi
  800433:	53                   	push   %ebx
  800434:	e8 20 fc ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  800439:	81 c3 c7 1b 00 00    	add    $0x1bc7,%ebx
  80043f:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  800442:	8b 16                	mov    (%esi),%edx
  800444:	8d 42 01             	lea    0x1(%edx),%eax
  800447:	89 06                	mov    %eax,(%esi)
  800449:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80044c:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800450:	3d ff 00 00 00       	cmp    $0xff,%eax
  800455:	74 0b                	je     800462 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800457:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80045b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80045e:	5b                   	pop    %ebx
  80045f:	5e                   	pop    %esi
  800460:	5d                   	pop    %ebp
  800461:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	68 ff 00 00 00       	push   $0xff
  80046a:	8d 46 08             	lea    0x8(%esi),%eax
  80046d:	50                   	push   %eax
  80046e:	e8 66 fc ff ff       	call   8000d9 <sys_cputs>
		b->idx = 0;
  800473:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800479:	83 c4 10             	add    $0x10,%esp
  80047c:	eb d9                	jmp    800457 <putch+0x28>

0080047e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80047e:	55                   	push   %ebp
  80047f:	89 e5                	mov    %esp,%ebp
  800481:	53                   	push   %ebx
  800482:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800488:	e8 cc fb ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  80048d:	81 c3 73 1b 00 00    	add    $0x1b73,%ebx
	struct printbuf b;

	b.idx = 0;
  800493:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80049a:	00 00 00 
	b.cnt = 0;
  80049d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004a4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004a7:	ff 75 0c             	pushl  0xc(%ebp)
  8004aa:	ff 75 08             	pushl  0x8(%ebp)
  8004ad:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004b3:	50                   	push   %eax
  8004b4:	8d 83 2f e4 ff ff    	lea    -0x1bd1(%ebx),%eax
  8004ba:	50                   	push   %eax
  8004bb:	e8 38 01 00 00       	call   8005f8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004c0:	83 c4 08             	add    $0x8,%esp
  8004c3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004c9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004cf:	50                   	push   %eax
  8004d0:	e8 04 fc ff ff       	call   8000d9 <sys_cputs>

	return b.cnt;
}
  8004d5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004de:	c9                   	leave  
  8004df:	c3                   	ret    

008004e0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004e6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004e9:	50                   	push   %eax
  8004ea:	ff 75 08             	pushl  0x8(%ebp)
  8004ed:	e8 8c ff ff ff       	call   80047e <vcprintf>
	va_end(ap);

	return cnt;
}
  8004f2:	c9                   	leave  
  8004f3:	c3                   	ret    

008004f4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	57                   	push   %edi
  8004f8:	56                   	push   %esi
  8004f9:	53                   	push   %ebx
  8004fa:	83 ec 2c             	sub    $0x2c,%esp
  8004fd:	e8 02 06 00 00       	call   800b04 <__x86.get_pc_thunk.cx>
  800502:	81 c1 fe 1a 00 00    	add    $0x1afe,%ecx
  800508:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80050b:	89 c7                	mov    %eax,%edi
  80050d:	89 d6                	mov    %edx,%esi
  80050f:	8b 45 08             	mov    0x8(%ebp),%eax
  800512:	8b 55 0c             	mov    0xc(%ebp),%edx
  800515:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800518:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  80051b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80051e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800523:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800526:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800529:	39 d3                	cmp    %edx,%ebx
  80052b:	72 09                	jb     800536 <printnum+0x42>
  80052d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800530:	0f 87 83 00 00 00    	ja     8005b9 <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800536:	83 ec 0c             	sub    $0xc,%esp
  800539:	ff 75 18             	pushl  0x18(%ebp)
  80053c:	8b 45 14             	mov    0x14(%ebp),%eax
  80053f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800542:	53                   	push   %ebx
  800543:	ff 75 10             	pushl  0x10(%ebp)
  800546:	83 ec 08             	sub    $0x8,%esp
  800549:	ff 75 dc             	pushl  -0x24(%ebp)
  80054c:	ff 75 d8             	pushl  -0x28(%ebp)
  80054f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800552:	ff 75 d0             	pushl  -0x30(%ebp)
  800555:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800558:	e8 23 09 00 00       	call   800e80 <__udivdi3>
  80055d:	83 c4 18             	add    $0x18,%esp
  800560:	52                   	push   %edx
  800561:	50                   	push   %eax
  800562:	89 f2                	mov    %esi,%edx
  800564:	89 f8                	mov    %edi,%eax
  800566:	e8 89 ff ff ff       	call   8004f4 <printnum>
  80056b:	83 c4 20             	add    $0x20,%esp
  80056e:	eb 13                	jmp    800583 <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	56                   	push   %esi
  800574:	ff 75 18             	pushl  0x18(%ebp)
  800577:	ff d7                	call   *%edi
  800579:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80057c:	83 eb 01             	sub    $0x1,%ebx
  80057f:	85 db                	test   %ebx,%ebx
  800581:	7f ed                	jg     800570 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	56                   	push   %esi
  800587:	83 ec 04             	sub    $0x4,%esp
  80058a:	ff 75 dc             	pushl  -0x24(%ebp)
  80058d:	ff 75 d8             	pushl  -0x28(%ebp)
  800590:	ff 75 d4             	pushl  -0x2c(%ebp)
  800593:	ff 75 d0             	pushl  -0x30(%ebp)
  800596:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800599:	89 f3                	mov    %esi,%ebx
  80059b:	e8 00 0a 00 00       	call   800fa0 <__umoddi3>
  8005a0:	83 c4 14             	add    $0x14,%esp
  8005a3:	0f be 84 06 1a f1 ff 	movsbl -0xee6(%esi,%eax,1),%eax
  8005aa:	ff 
  8005ab:	50                   	push   %eax
  8005ac:	ff d7                	call   *%edi
}
  8005ae:	83 c4 10             	add    $0x10,%esp
  8005b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005b4:	5b                   	pop    %ebx
  8005b5:	5e                   	pop    %esi
  8005b6:	5f                   	pop    %edi
  8005b7:	5d                   	pop    %ebp
  8005b8:	c3                   	ret    
  8005b9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005bc:	eb be                	jmp    80057c <printnum+0x88>

008005be <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005be:	55                   	push   %ebp
  8005bf:	89 e5                	mov    %esp,%ebp
  8005c1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005c4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005c8:	8b 10                	mov    (%eax),%edx
  8005ca:	3b 50 04             	cmp    0x4(%eax),%edx
  8005cd:	73 0a                	jae    8005d9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005cf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005d2:	89 08                	mov    %ecx,(%eax)
  8005d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d7:	88 02                	mov    %al,(%edx)
}
  8005d9:	5d                   	pop    %ebp
  8005da:	c3                   	ret    

008005db <printfmt>:
{
  8005db:	55                   	push   %ebp
  8005dc:	89 e5                	mov    %esp,%ebp
  8005de:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8005e1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005e4:	50                   	push   %eax
  8005e5:	ff 75 10             	pushl  0x10(%ebp)
  8005e8:	ff 75 0c             	pushl  0xc(%ebp)
  8005eb:	ff 75 08             	pushl  0x8(%ebp)
  8005ee:	e8 05 00 00 00       	call   8005f8 <vprintfmt>
}
  8005f3:	83 c4 10             	add    $0x10,%esp
  8005f6:	c9                   	leave  
  8005f7:	c3                   	ret    

008005f8 <vprintfmt>:
{
  8005f8:	55                   	push   %ebp
  8005f9:	89 e5                	mov    %esp,%ebp
  8005fb:	57                   	push   %edi
  8005fc:	56                   	push   %esi
  8005fd:	53                   	push   %ebx
  8005fe:	83 ec 2c             	sub    $0x2c,%esp
  800601:	e8 53 fa ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  800606:	81 c3 fa 19 00 00    	add    $0x19fa,%ebx
  80060c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80060f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800612:	e9 c3 03 00 00       	jmp    8009da <.L35+0x48>
		padc = ' ';
  800617:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80061b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800622:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  800629:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800630:	b9 00 00 00 00       	mov    $0x0,%ecx
  800635:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800638:	8d 47 01             	lea    0x1(%edi),%eax
  80063b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80063e:	0f b6 17             	movzbl (%edi),%edx
  800641:	8d 42 dd             	lea    -0x23(%edx),%eax
  800644:	3c 55                	cmp    $0x55,%al
  800646:	0f 87 16 04 00 00    	ja     800a62 <.L22>
  80064c:	0f b6 c0             	movzbl %al,%eax
  80064f:	89 d9                	mov    %ebx,%ecx
  800651:	03 8c 83 d4 f1 ff ff 	add    -0xe2c(%ebx,%eax,4),%ecx
  800658:	ff e1                	jmp    *%ecx

0080065a <.L69>:
  80065a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80065d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800661:	eb d5                	jmp    800638 <vprintfmt+0x40>

00800663 <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800663:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800666:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80066a:	eb cc                	jmp    800638 <vprintfmt+0x40>

0080066c <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80066c:	0f b6 d2             	movzbl %dl,%edx
  80066f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
  800672:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800677:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80067a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80067e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800681:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800684:	83 f9 09             	cmp    $0x9,%ecx
  800687:	77 55                	ja     8006de <.L23+0xf>
			for (precision = 0;; ++fmt)
  800689:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80068c:	eb e9                	jmp    800677 <.L29+0xb>

0080068e <.L26>:
			precision = va_arg(ap, int);
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8b 00                	mov    (%eax),%eax
  800693:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800696:	8b 45 14             	mov    0x14(%ebp),%eax
  800699:	8d 40 04             	lea    0x4(%eax),%eax
  80069c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80069f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8006a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006a6:	79 90                	jns    800638 <vprintfmt+0x40>
				width = precision, precision = -1;
  8006a8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ae:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8006b5:	eb 81                	jmp    800638 <vprintfmt+0x40>

008006b7 <.L27>:
  8006b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ba:	85 c0                	test   %eax,%eax
  8006bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c1:	0f 49 d0             	cmovns %eax,%edx
  8006c4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ca:	e9 69 ff ff ff       	jmp    800638 <vprintfmt+0x40>

008006cf <.L23>:
  8006cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8006d2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006d9:	e9 5a ff ff ff       	jmp    800638 <vprintfmt+0x40>
  8006de:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006e1:	eb bf                	jmp    8006a2 <.L26+0x14>

008006e3 <.L33>:
			lflag++;
  8006e3:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8006ea:	e9 49 ff ff ff       	jmp    800638 <vprintfmt+0x40>

008006ef <.L30>:
			putch(va_arg(ap, int), putdat);
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8d 78 04             	lea    0x4(%eax),%edi
  8006f5:	83 ec 08             	sub    $0x8,%esp
  8006f8:	56                   	push   %esi
  8006f9:	ff 30                	pushl  (%eax)
  8006fb:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006fe:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800701:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800704:	e9 ce 02 00 00       	jmp    8009d7 <.L35+0x45>

00800709 <.L32>:
			err = va_arg(ap, int);
  800709:	8b 45 14             	mov    0x14(%ebp),%eax
  80070c:	8d 78 04             	lea    0x4(%eax),%edi
  80070f:	8b 00                	mov    (%eax),%eax
  800711:	99                   	cltd   
  800712:	31 d0                	xor    %edx,%eax
  800714:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800716:	83 f8 08             	cmp    $0x8,%eax
  800719:	7f 27                	jg     800742 <.L32+0x39>
  80071b:	8b 94 83 20 00 00 00 	mov    0x20(%ebx,%eax,4),%edx
  800722:	85 d2                	test   %edx,%edx
  800724:	74 1c                	je     800742 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  800726:	52                   	push   %edx
  800727:	8d 83 3b f1 ff ff    	lea    -0xec5(%ebx),%eax
  80072d:	50                   	push   %eax
  80072e:	56                   	push   %esi
  80072f:	ff 75 08             	pushl  0x8(%ebp)
  800732:	e8 a4 fe ff ff       	call   8005db <printfmt>
  800737:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80073a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80073d:	e9 95 02 00 00       	jmp    8009d7 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  800742:	50                   	push   %eax
  800743:	8d 83 32 f1 ff ff    	lea    -0xece(%ebx),%eax
  800749:	50                   	push   %eax
  80074a:	56                   	push   %esi
  80074b:	ff 75 08             	pushl  0x8(%ebp)
  80074e:	e8 88 fe ff ff       	call   8005db <printfmt>
  800753:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800756:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800759:	e9 79 02 00 00       	jmp    8009d7 <.L35+0x45>

0080075e <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  80075e:	8b 45 14             	mov    0x14(%ebp),%eax
  800761:	83 c0 04             	add    $0x4,%eax
  800764:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800767:	8b 45 14             	mov    0x14(%ebp),%eax
  80076a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80076c:	85 ff                	test   %edi,%edi
  80076e:	8d 83 2b f1 ff ff    	lea    -0xed5(%ebx),%eax
  800774:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800777:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80077b:	0f 8e b5 00 00 00    	jle    800836 <.L36+0xd8>
  800781:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800785:	75 08                	jne    80078f <.L36+0x31>
  800787:	89 75 0c             	mov    %esi,0xc(%ebp)
  80078a:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80078d:	eb 6d                	jmp    8007fc <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  80078f:	83 ec 08             	sub    $0x8,%esp
  800792:	ff 75 cc             	pushl  -0x34(%ebp)
  800795:	57                   	push   %edi
  800796:	e8 85 03 00 00       	call   800b20 <strnlen>
  80079b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80079e:	29 c2                	sub    %eax,%edx
  8007a0:	89 55 c8             	mov    %edx,-0x38(%ebp)
  8007a3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8007a6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007ad:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007b0:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8007b2:	eb 10                	jmp    8007c4 <.L36+0x66>
					putch(padc, putdat);
  8007b4:	83 ec 08             	sub    $0x8,%esp
  8007b7:	56                   	push   %esi
  8007b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8007bb:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8007be:	83 ef 01             	sub    $0x1,%edi
  8007c1:	83 c4 10             	add    $0x10,%esp
  8007c4:	85 ff                	test   %edi,%edi
  8007c6:	7f ec                	jg     8007b4 <.L36+0x56>
  8007c8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007cb:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8007ce:	85 d2                	test   %edx,%edx
  8007d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d5:	0f 49 c2             	cmovns %edx,%eax
  8007d8:	29 c2                	sub    %eax,%edx
  8007da:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8007dd:	89 75 0c             	mov    %esi,0xc(%ebp)
  8007e0:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8007e3:	eb 17                	jmp    8007fc <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  8007e5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007e9:	75 30                	jne    80081b <.L36+0xbd>
					putch(ch, putdat);
  8007eb:	83 ec 08             	sub    $0x8,%esp
  8007ee:	ff 75 0c             	pushl  0xc(%ebp)
  8007f1:	50                   	push   %eax
  8007f2:	ff 55 08             	call   *0x8(%ebp)
  8007f5:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007f8:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8007fc:	83 c7 01             	add    $0x1,%edi
  8007ff:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800803:	0f be c2             	movsbl %dl,%eax
  800806:	85 c0                	test   %eax,%eax
  800808:	74 52                	je     80085c <.L36+0xfe>
  80080a:	85 f6                	test   %esi,%esi
  80080c:	78 d7                	js     8007e5 <.L36+0x87>
  80080e:	83 ee 01             	sub    $0x1,%esi
  800811:	79 d2                	jns    8007e5 <.L36+0x87>
  800813:	8b 75 0c             	mov    0xc(%ebp),%esi
  800816:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800819:	eb 32                	jmp    80084d <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  80081b:	0f be d2             	movsbl %dl,%edx
  80081e:	83 ea 20             	sub    $0x20,%edx
  800821:	83 fa 5e             	cmp    $0x5e,%edx
  800824:	76 c5                	jbe    8007eb <.L36+0x8d>
					putch('?', putdat);
  800826:	83 ec 08             	sub    $0x8,%esp
  800829:	ff 75 0c             	pushl  0xc(%ebp)
  80082c:	6a 3f                	push   $0x3f
  80082e:	ff 55 08             	call   *0x8(%ebp)
  800831:	83 c4 10             	add    $0x10,%esp
  800834:	eb c2                	jmp    8007f8 <.L36+0x9a>
  800836:	89 75 0c             	mov    %esi,0xc(%ebp)
  800839:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80083c:	eb be                	jmp    8007fc <.L36+0x9e>
				putch(' ', putdat);
  80083e:	83 ec 08             	sub    $0x8,%esp
  800841:	56                   	push   %esi
  800842:	6a 20                	push   $0x20
  800844:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800847:	83 ef 01             	sub    $0x1,%edi
  80084a:	83 c4 10             	add    $0x10,%esp
  80084d:	85 ff                	test   %edi,%edi
  80084f:	7f ed                	jg     80083e <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800851:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800854:	89 45 14             	mov    %eax,0x14(%ebp)
  800857:	e9 7b 01 00 00       	jmp    8009d7 <.L35+0x45>
  80085c:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80085f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800862:	eb e9                	jmp    80084d <.L36+0xef>

00800864 <.L31>:
  800864:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800867:	83 f9 01             	cmp    $0x1,%ecx
  80086a:	7e 40                	jle    8008ac <.L31+0x48>
		return va_arg(*ap, long long);
  80086c:	8b 45 14             	mov    0x14(%ebp),%eax
  80086f:	8b 50 04             	mov    0x4(%eax),%edx
  800872:	8b 00                	mov    (%eax),%eax
  800874:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800877:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80087a:	8b 45 14             	mov    0x14(%ebp),%eax
  80087d:	8d 40 08             	lea    0x8(%eax),%eax
  800880:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
  800883:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800887:	79 55                	jns    8008de <.L31+0x7a>
				putch('-', putdat);
  800889:	83 ec 08             	sub    $0x8,%esp
  80088c:	56                   	push   %esi
  80088d:	6a 2d                	push   $0x2d
  80088f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  800892:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800895:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800898:	f7 da                	neg    %edx
  80089a:	83 d1 00             	adc    $0x0,%ecx
  80089d:	f7 d9                	neg    %ecx
  80089f:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
  8008a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008a7:	e9 10 01 00 00       	jmp    8009bc <.L35+0x2a>
	else if (lflag)
  8008ac:	85 c9                	test   %ecx,%ecx
  8008ae:	75 17                	jne    8008c7 <.L31+0x63>
		return va_arg(*ap, int);
  8008b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b3:	8b 00                	mov    (%eax),%eax
  8008b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b8:	99                   	cltd   
  8008b9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bf:	8d 40 04             	lea    0x4(%eax),%eax
  8008c2:	89 45 14             	mov    %eax,0x14(%ebp)
  8008c5:	eb bc                	jmp    800883 <.L31+0x1f>
		return va_arg(*ap, long);
  8008c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ca:	8b 00                	mov    (%eax),%eax
  8008cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008cf:	99                   	cltd   
  8008d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d6:	8d 40 04             	lea    0x4(%eax),%eax
  8008d9:	89 45 14             	mov    %eax,0x14(%ebp)
  8008dc:	eb a5                	jmp    800883 <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  8008de:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008e1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
  8008e4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008e9:	e9 ce 00 00 00       	jmp    8009bc <.L35+0x2a>

008008ee <.L37>:
  8008ee:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8008f1:	83 f9 01             	cmp    $0x1,%ecx
  8008f4:	7e 18                	jle    80090e <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8008f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f9:	8b 10                	mov    (%eax),%edx
  8008fb:	8b 48 04             	mov    0x4(%eax),%ecx
  8008fe:	8d 40 08             	lea    0x8(%eax),%eax
  800901:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800904:	b8 0a 00 00 00       	mov    $0xa,%eax
  800909:	e9 ae 00 00 00       	jmp    8009bc <.L35+0x2a>
	else if (lflag)
  80090e:	85 c9                	test   %ecx,%ecx
  800910:	75 1a                	jne    80092c <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  800912:	8b 45 14             	mov    0x14(%ebp),%eax
  800915:	8b 10                	mov    (%eax),%edx
  800917:	b9 00 00 00 00       	mov    $0x0,%ecx
  80091c:	8d 40 04             	lea    0x4(%eax),%eax
  80091f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800922:	b8 0a 00 00 00       	mov    $0xa,%eax
  800927:	e9 90 00 00 00       	jmp    8009bc <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  80092c:	8b 45 14             	mov    0x14(%ebp),%eax
  80092f:	8b 10                	mov    (%eax),%edx
  800931:	b9 00 00 00 00       	mov    $0x0,%ecx
  800936:	8d 40 04             	lea    0x4(%eax),%eax
  800939:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80093c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800941:	eb 79                	jmp    8009bc <.L35+0x2a>

00800943 <.L34>:
  800943:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800946:	83 f9 01             	cmp    $0x1,%ecx
  800949:	7e 15                	jle    800960 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  80094b:	8b 45 14             	mov    0x14(%ebp),%eax
  80094e:	8b 10                	mov    (%eax),%edx
  800950:	8b 48 04             	mov    0x4(%eax),%ecx
  800953:	8d 40 08             	lea    0x8(%eax),%eax
  800956:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800959:	b8 08 00 00 00       	mov    $0x8,%eax
  80095e:	eb 5c                	jmp    8009bc <.L35+0x2a>
	else if (lflag)
  800960:	85 c9                	test   %ecx,%ecx
  800962:	75 17                	jne    80097b <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800964:	8b 45 14             	mov    0x14(%ebp),%eax
  800967:	8b 10                	mov    (%eax),%edx
  800969:	b9 00 00 00 00       	mov    $0x0,%ecx
  80096e:	8d 40 04             	lea    0x4(%eax),%eax
  800971:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800974:	b8 08 00 00 00       	mov    $0x8,%eax
  800979:	eb 41                	jmp    8009bc <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  80097b:	8b 45 14             	mov    0x14(%ebp),%eax
  80097e:	8b 10                	mov    (%eax),%edx
  800980:	b9 00 00 00 00       	mov    $0x0,%ecx
  800985:	8d 40 04             	lea    0x4(%eax),%eax
  800988:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80098b:	b8 08 00 00 00       	mov    $0x8,%eax
  800990:	eb 2a                	jmp    8009bc <.L35+0x2a>

00800992 <.L35>:
			putch('0', putdat);
  800992:	83 ec 08             	sub    $0x8,%esp
  800995:	56                   	push   %esi
  800996:	6a 30                	push   $0x30
  800998:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80099b:	83 c4 08             	add    $0x8,%esp
  80099e:	56                   	push   %esi
  80099f:	6a 78                	push   $0x78
  8009a1:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8009a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a7:	8b 10                	mov    (%eax),%edx
  8009a9:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8009ae:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8009b1:	8d 40 04             	lea    0x4(%eax),%eax
  8009b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009b7:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  8009bc:	83 ec 0c             	sub    $0xc,%esp
  8009bf:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8009c3:	57                   	push   %edi
  8009c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8009c7:	50                   	push   %eax
  8009c8:	51                   	push   %ecx
  8009c9:	52                   	push   %edx
  8009ca:	89 f2                	mov    %esi,%edx
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	e8 20 fb ff ff       	call   8004f4 <printnum>
			break;
  8009d4:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8009d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  8009da:	83 c7 01             	add    $0x1,%edi
  8009dd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8009e1:	83 f8 25             	cmp    $0x25,%eax
  8009e4:	0f 84 2d fc ff ff    	je     800617 <vprintfmt+0x1f>
			if (ch == '\0')
  8009ea:	85 c0                	test   %eax,%eax
  8009ec:	0f 84 91 00 00 00    	je     800a83 <.L22+0x21>
			putch(ch, putdat);
  8009f2:	83 ec 08             	sub    $0x8,%esp
  8009f5:	56                   	push   %esi
  8009f6:	50                   	push   %eax
  8009f7:	ff 55 08             	call   *0x8(%ebp)
  8009fa:	83 c4 10             	add    $0x10,%esp
  8009fd:	eb db                	jmp    8009da <.L35+0x48>

008009ff <.L38>:
  8009ff:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800a02:	83 f9 01             	cmp    $0x1,%ecx
  800a05:	7e 15                	jle    800a1c <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  800a07:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0a:	8b 10                	mov    (%eax),%edx
  800a0c:	8b 48 04             	mov    0x4(%eax),%ecx
  800a0f:	8d 40 08             	lea    0x8(%eax),%eax
  800a12:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a15:	b8 10 00 00 00       	mov    $0x10,%eax
  800a1a:	eb a0                	jmp    8009bc <.L35+0x2a>
	else if (lflag)
  800a1c:	85 c9                	test   %ecx,%ecx
  800a1e:	75 17                	jne    800a37 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  800a20:	8b 45 14             	mov    0x14(%ebp),%eax
  800a23:	8b 10                	mov    (%eax),%edx
  800a25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a2a:	8d 40 04             	lea    0x4(%eax),%eax
  800a2d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a30:	b8 10 00 00 00       	mov    $0x10,%eax
  800a35:	eb 85                	jmp    8009bc <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800a37:	8b 45 14             	mov    0x14(%ebp),%eax
  800a3a:	8b 10                	mov    (%eax),%edx
  800a3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a41:	8d 40 04             	lea    0x4(%eax),%eax
  800a44:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a47:	b8 10 00 00 00       	mov    $0x10,%eax
  800a4c:	e9 6b ff ff ff       	jmp    8009bc <.L35+0x2a>

00800a51 <.L25>:
			putch(ch, putdat);
  800a51:	83 ec 08             	sub    $0x8,%esp
  800a54:	56                   	push   %esi
  800a55:	6a 25                	push   $0x25
  800a57:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a5a:	83 c4 10             	add    $0x10,%esp
  800a5d:	e9 75 ff ff ff       	jmp    8009d7 <.L35+0x45>

00800a62 <.L22>:
			putch('%', putdat);
  800a62:	83 ec 08             	sub    $0x8,%esp
  800a65:	56                   	push   %esi
  800a66:	6a 25                	push   $0x25
  800a68:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a6b:	83 c4 10             	add    $0x10,%esp
  800a6e:	89 f8                	mov    %edi,%eax
  800a70:	eb 03                	jmp    800a75 <.L22+0x13>
  800a72:	83 e8 01             	sub    $0x1,%eax
  800a75:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800a79:	75 f7                	jne    800a72 <.L22+0x10>
  800a7b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a7e:	e9 54 ff ff ff       	jmp    8009d7 <.L35+0x45>
}
  800a83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5f                   	pop    %edi
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	53                   	push   %ebx
  800a8f:	83 ec 14             	sub    $0x14,%esp
  800a92:	e8 c2 f5 ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  800a97:	81 c3 69 15 00 00    	add    $0x1569,%ebx
  800a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  800aa3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800aa6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800aaa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800aad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ab4:	85 c0                	test   %eax,%eax
  800ab6:	74 2b                	je     800ae3 <vsnprintf+0x58>
  800ab8:	85 d2                	test   %edx,%edx
  800aba:	7e 27                	jle    800ae3 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  800abc:	ff 75 14             	pushl  0x14(%ebp)
  800abf:	ff 75 10             	pushl  0x10(%ebp)
  800ac2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ac5:	50                   	push   %eax
  800ac6:	8d 83 be e5 ff ff    	lea    -0x1a42(%ebx),%eax
  800acc:	50                   	push   %eax
  800acd:	e8 26 fb ff ff       	call   8005f8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ad2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ad5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800adb:	83 c4 10             	add    $0x10,%esp
}
  800ade:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ae1:	c9                   	leave  
  800ae2:	c3                   	ret    
		return -E_INVAL;
  800ae3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ae8:	eb f4                	jmp    800ade <vsnprintf+0x53>

00800aea <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800af0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800af3:	50                   	push   %eax
  800af4:	ff 75 10             	pushl  0x10(%ebp)
  800af7:	ff 75 0c             	pushl  0xc(%ebp)
  800afa:	ff 75 08             	pushl  0x8(%ebp)
  800afd:	e8 89 ff ff ff       	call   800a8b <vsnprintf>
	va_end(ap);

	return rc;
}
  800b02:	c9                   	leave  
  800b03:	c3                   	ret    

00800b04 <__x86.get_pc_thunk.cx>:
  800b04:	8b 0c 24             	mov    (%esp),%ecx
  800b07:	c3                   	ret    

00800b08 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b13:	eb 03                	jmp    800b18 <strlen+0x10>
		n++;
  800b15:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800b18:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b1c:	75 f7                	jne    800b15 <strlen+0xd>
	return n;
}
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b26:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b29:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2e:	eb 03                	jmp    800b33 <strnlen+0x13>
		n++;
  800b30:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b33:	39 d0                	cmp    %edx,%eax
  800b35:	74 06                	je     800b3d <strnlen+0x1d>
  800b37:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b3b:	75 f3                	jne    800b30 <strnlen+0x10>
	return n;
}
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	53                   	push   %ebx
  800b43:	8b 45 08             	mov    0x8(%ebp),%eax
  800b46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b49:	89 c2                	mov    %eax,%edx
  800b4b:	83 c1 01             	add    $0x1,%ecx
  800b4e:	83 c2 01             	add    $0x1,%edx
  800b51:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b55:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b58:	84 db                	test   %bl,%bl
  800b5a:	75 ef                	jne    800b4b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b5c:	5b                   	pop    %ebx
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	53                   	push   %ebx
  800b63:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b66:	53                   	push   %ebx
  800b67:	e8 9c ff ff ff       	call   800b08 <strlen>
  800b6c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b6f:	ff 75 0c             	pushl  0xc(%ebp)
  800b72:	01 d8                	add    %ebx,%eax
  800b74:	50                   	push   %eax
  800b75:	e8 c5 ff ff ff       	call   800b3f <strcpy>
	return dst;
}
  800b7a:	89 d8                	mov    %ebx,%eax
  800b7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b7f:	c9                   	leave  
  800b80:	c3                   	ret    

00800b81 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	8b 75 08             	mov    0x8(%ebp),%esi
  800b89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8c:	89 f3                	mov    %esi,%ebx
  800b8e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b91:	89 f2                	mov    %esi,%edx
  800b93:	eb 0f                	jmp    800ba4 <strncpy+0x23>
		*dst++ = *src;
  800b95:	83 c2 01             	add    $0x1,%edx
  800b98:	0f b6 01             	movzbl (%ecx),%eax
  800b9b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b9e:	80 39 01             	cmpb   $0x1,(%ecx)
  800ba1:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800ba4:	39 da                	cmp    %ebx,%edx
  800ba6:	75 ed                	jne    800b95 <strncpy+0x14>
	}
	return ret;
}
  800ba8:	89 f0                	mov    %esi,%eax
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	56                   	push   %esi
  800bb2:	53                   	push   %ebx
  800bb3:	8b 75 08             	mov    0x8(%ebp),%esi
  800bb6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bbc:	89 f0                	mov    %esi,%eax
  800bbe:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bc2:	85 c9                	test   %ecx,%ecx
  800bc4:	75 0b                	jne    800bd1 <strlcpy+0x23>
  800bc6:	eb 17                	jmp    800bdf <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bc8:	83 c2 01             	add    $0x1,%edx
  800bcb:	83 c0 01             	add    $0x1,%eax
  800bce:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800bd1:	39 d8                	cmp    %ebx,%eax
  800bd3:	74 07                	je     800bdc <strlcpy+0x2e>
  800bd5:	0f b6 0a             	movzbl (%edx),%ecx
  800bd8:	84 c9                	test   %cl,%cl
  800bda:	75 ec                	jne    800bc8 <strlcpy+0x1a>
		*dst = '\0';
  800bdc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bdf:	29 f0                	sub    %esi,%eax
}
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800beb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bee:	eb 06                	jmp    800bf6 <strcmp+0x11>
		p++, q++;
  800bf0:	83 c1 01             	add    $0x1,%ecx
  800bf3:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800bf6:	0f b6 01             	movzbl (%ecx),%eax
  800bf9:	84 c0                	test   %al,%al
  800bfb:	74 04                	je     800c01 <strcmp+0x1c>
  800bfd:	3a 02                	cmp    (%edx),%al
  800bff:	74 ef                	je     800bf0 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c01:	0f b6 c0             	movzbl %al,%eax
  800c04:	0f b6 12             	movzbl (%edx),%edx
  800c07:	29 d0                	sub    %edx,%eax
}
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	53                   	push   %ebx
  800c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c12:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c15:	89 c3                	mov    %eax,%ebx
  800c17:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c1a:	eb 06                	jmp    800c22 <strncmp+0x17>
		n--, p++, q++;
  800c1c:	83 c0 01             	add    $0x1,%eax
  800c1f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c22:	39 d8                	cmp    %ebx,%eax
  800c24:	74 16                	je     800c3c <strncmp+0x31>
  800c26:	0f b6 08             	movzbl (%eax),%ecx
  800c29:	84 c9                	test   %cl,%cl
  800c2b:	74 04                	je     800c31 <strncmp+0x26>
  800c2d:	3a 0a                	cmp    (%edx),%cl
  800c2f:	74 eb                	je     800c1c <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c31:	0f b6 00             	movzbl (%eax),%eax
  800c34:	0f b6 12             	movzbl (%edx),%edx
  800c37:	29 d0                	sub    %edx,%eax
}
  800c39:	5b                   	pop    %ebx
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    
		return 0;
  800c3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c41:	eb f6                	jmp    800c39 <strncmp+0x2e>

00800c43 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	8b 45 08             	mov    0x8(%ebp),%eax
  800c49:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c4d:	0f b6 10             	movzbl (%eax),%edx
  800c50:	84 d2                	test   %dl,%dl
  800c52:	74 09                	je     800c5d <strchr+0x1a>
		if (*s == c)
  800c54:	38 ca                	cmp    %cl,%dl
  800c56:	74 0a                	je     800c62 <strchr+0x1f>
	for (; *s; s++)
  800c58:	83 c0 01             	add    $0x1,%eax
  800c5b:	eb f0                	jmp    800c4d <strchr+0xa>
			return (char *) s;
	return 0;
  800c5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c6e:	eb 03                	jmp    800c73 <strfind+0xf>
  800c70:	83 c0 01             	add    $0x1,%eax
  800c73:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c76:	38 ca                	cmp    %cl,%dl
  800c78:	74 04                	je     800c7e <strfind+0x1a>
  800c7a:	84 d2                	test   %dl,%dl
  800c7c:	75 f2                	jne    800c70 <strfind+0xc>
			break;
	return (char *) s;
}
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
  800c86:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c89:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c8c:	85 c9                	test   %ecx,%ecx
  800c8e:	74 13                	je     800ca3 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c90:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c96:	75 05                	jne    800c9d <memset+0x1d>
  800c98:	f6 c1 03             	test   $0x3,%cl
  800c9b:	74 0d                	je     800caa <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca0:	fc                   	cld    
  800ca1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ca3:	89 f8                	mov    %edi,%eax
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    
		c &= 0xFF;
  800caa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cae:	89 d3                	mov    %edx,%ebx
  800cb0:	c1 e3 08             	shl    $0x8,%ebx
  800cb3:	89 d0                	mov    %edx,%eax
  800cb5:	c1 e0 18             	shl    $0x18,%eax
  800cb8:	89 d6                	mov    %edx,%esi
  800cba:	c1 e6 10             	shl    $0x10,%esi
  800cbd:	09 f0                	or     %esi,%eax
  800cbf:	09 c2                	or     %eax,%edx
  800cc1:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800cc3:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800cc6:	89 d0                	mov    %edx,%eax
  800cc8:	fc                   	cld    
  800cc9:	f3 ab                	rep stos %eax,%es:(%edi)
  800ccb:	eb d6                	jmp    800ca3 <memset+0x23>

00800ccd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cdb:	39 c6                	cmp    %eax,%esi
  800cdd:	73 35                	jae    800d14 <memmove+0x47>
  800cdf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ce2:	39 c2                	cmp    %eax,%edx
  800ce4:	76 2e                	jbe    800d14 <memmove+0x47>
		s += n;
		d += n;
  800ce6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ce9:	89 d6                	mov    %edx,%esi
  800ceb:	09 fe                	or     %edi,%esi
  800ced:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cf3:	74 0c                	je     800d01 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cf5:	83 ef 01             	sub    $0x1,%edi
  800cf8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800cfb:	fd                   	std    
  800cfc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cfe:	fc                   	cld    
  800cff:	eb 21                	jmp    800d22 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d01:	f6 c1 03             	test   $0x3,%cl
  800d04:	75 ef                	jne    800cf5 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d06:	83 ef 04             	sub    $0x4,%edi
  800d09:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d0c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d0f:	fd                   	std    
  800d10:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d12:	eb ea                	jmp    800cfe <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d14:	89 f2                	mov    %esi,%edx
  800d16:	09 c2                	or     %eax,%edx
  800d18:	f6 c2 03             	test   $0x3,%dl
  800d1b:	74 09                	je     800d26 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d1d:	89 c7                	mov    %eax,%edi
  800d1f:	fc                   	cld    
  800d20:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d26:	f6 c1 03             	test   $0x3,%cl
  800d29:	75 f2                	jne    800d1d <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d2b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d2e:	89 c7                	mov    %eax,%edi
  800d30:	fc                   	cld    
  800d31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d33:	eb ed                	jmp    800d22 <memmove+0x55>

00800d35 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d38:	ff 75 10             	pushl  0x10(%ebp)
  800d3b:	ff 75 0c             	pushl  0xc(%ebp)
  800d3e:	ff 75 08             	pushl  0x8(%ebp)
  800d41:	e8 87 ff ff ff       	call   800ccd <memmove>
}
  800d46:	c9                   	leave  
  800d47:	c3                   	ret    

00800d48 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
  800d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d50:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d53:	89 c6                	mov    %eax,%esi
  800d55:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d58:	39 f0                	cmp    %esi,%eax
  800d5a:	74 1c                	je     800d78 <memcmp+0x30>
		if (*s1 != *s2)
  800d5c:	0f b6 08             	movzbl (%eax),%ecx
  800d5f:	0f b6 1a             	movzbl (%edx),%ebx
  800d62:	38 d9                	cmp    %bl,%cl
  800d64:	75 08                	jne    800d6e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800d66:	83 c0 01             	add    $0x1,%eax
  800d69:	83 c2 01             	add    $0x1,%edx
  800d6c:	eb ea                	jmp    800d58 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800d6e:	0f b6 c1             	movzbl %cl,%eax
  800d71:	0f b6 db             	movzbl %bl,%ebx
  800d74:	29 d8                	sub    %ebx,%eax
  800d76:	eb 05                	jmp    800d7d <memcmp+0x35>
	}

	return 0;
  800d78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	8b 45 08             	mov    0x8(%ebp),%eax
  800d87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d8a:	89 c2                	mov    %eax,%edx
  800d8c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d8f:	39 d0                	cmp    %edx,%eax
  800d91:	73 09                	jae    800d9c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d93:	38 08                	cmp    %cl,(%eax)
  800d95:	74 05                	je     800d9c <memfind+0x1b>
	for (; s < ends; s++)
  800d97:	83 c0 01             	add    $0x1,%eax
  800d9a:	eb f3                	jmp    800d8f <memfind+0xe>
			break;
	return (void *) s;
}
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800daa:	eb 03                	jmp    800daf <strtol+0x11>
		s++;
  800dac:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800daf:	0f b6 01             	movzbl (%ecx),%eax
  800db2:	3c 20                	cmp    $0x20,%al
  800db4:	74 f6                	je     800dac <strtol+0xe>
  800db6:	3c 09                	cmp    $0x9,%al
  800db8:	74 f2                	je     800dac <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800dba:	3c 2b                	cmp    $0x2b,%al
  800dbc:	74 2e                	je     800dec <strtol+0x4e>
	int neg = 0;
  800dbe:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800dc3:	3c 2d                	cmp    $0x2d,%al
  800dc5:	74 2f                	je     800df6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dc7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dcd:	75 05                	jne    800dd4 <strtol+0x36>
  800dcf:	80 39 30             	cmpb   $0x30,(%ecx)
  800dd2:	74 2c                	je     800e00 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dd4:	85 db                	test   %ebx,%ebx
  800dd6:	75 0a                	jne    800de2 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800dd8:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ddd:	80 39 30             	cmpb   $0x30,(%ecx)
  800de0:	74 28                	je     800e0a <strtol+0x6c>
		base = 10;
  800de2:	b8 00 00 00 00       	mov    $0x0,%eax
  800de7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800dea:	eb 50                	jmp    800e3c <strtol+0x9e>
		s++;
  800dec:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800def:	bf 00 00 00 00       	mov    $0x0,%edi
  800df4:	eb d1                	jmp    800dc7 <strtol+0x29>
		s++, neg = 1;
  800df6:	83 c1 01             	add    $0x1,%ecx
  800df9:	bf 01 00 00 00       	mov    $0x1,%edi
  800dfe:	eb c7                	jmp    800dc7 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e00:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e04:	74 0e                	je     800e14 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800e06:	85 db                	test   %ebx,%ebx
  800e08:	75 d8                	jne    800de2 <strtol+0x44>
		s++, base = 8;
  800e0a:	83 c1 01             	add    $0x1,%ecx
  800e0d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800e12:	eb ce                	jmp    800de2 <strtol+0x44>
		s += 2, base = 16;
  800e14:	83 c1 02             	add    $0x2,%ecx
  800e17:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e1c:	eb c4                	jmp    800de2 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800e1e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e21:	89 f3                	mov    %esi,%ebx
  800e23:	80 fb 19             	cmp    $0x19,%bl
  800e26:	77 29                	ja     800e51 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800e28:	0f be d2             	movsbl %dl,%edx
  800e2b:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e2e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e31:	7d 30                	jge    800e63 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800e33:	83 c1 01             	add    $0x1,%ecx
  800e36:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e3a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800e3c:	0f b6 11             	movzbl (%ecx),%edx
  800e3f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e42:	89 f3                	mov    %esi,%ebx
  800e44:	80 fb 09             	cmp    $0x9,%bl
  800e47:	77 d5                	ja     800e1e <strtol+0x80>
			dig = *s - '0';
  800e49:	0f be d2             	movsbl %dl,%edx
  800e4c:	83 ea 30             	sub    $0x30,%edx
  800e4f:	eb dd                	jmp    800e2e <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800e51:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e54:	89 f3                	mov    %esi,%ebx
  800e56:	80 fb 19             	cmp    $0x19,%bl
  800e59:	77 08                	ja     800e63 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800e5b:	0f be d2             	movsbl %dl,%edx
  800e5e:	83 ea 37             	sub    $0x37,%edx
  800e61:	eb cb                	jmp    800e2e <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800e63:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e67:	74 05                	je     800e6e <strtol+0xd0>
		*endptr = (char *) s;
  800e69:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e6c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800e6e:	89 c2                	mov    %eax,%edx
  800e70:	f7 da                	neg    %edx
  800e72:	85 ff                	test   %edi,%edi
  800e74:	0f 45 c2             	cmovne %edx,%eax
}
  800e77:	5b                   	pop    %ebx
  800e78:	5e                   	pop    %esi
  800e79:	5f                   	pop    %edi
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    
  800e7c:	66 90                	xchg   %ax,%ax
  800e7e:	66 90                	xchg   %ax,%ax

00800e80 <__udivdi3>:
  800e80:	55                   	push   %ebp
  800e81:	57                   	push   %edi
  800e82:	56                   	push   %esi
  800e83:	53                   	push   %ebx
  800e84:	83 ec 1c             	sub    $0x1c,%esp
  800e87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e8b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e93:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e97:	85 d2                	test   %edx,%edx
  800e99:	75 35                	jne    800ed0 <__udivdi3+0x50>
  800e9b:	39 f3                	cmp    %esi,%ebx
  800e9d:	0f 87 bd 00 00 00    	ja     800f60 <__udivdi3+0xe0>
  800ea3:	85 db                	test   %ebx,%ebx
  800ea5:	89 d9                	mov    %ebx,%ecx
  800ea7:	75 0b                	jne    800eb4 <__udivdi3+0x34>
  800ea9:	b8 01 00 00 00       	mov    $0x1,%eax
  800eae:	31 d2                	xor    %edx,%edx
  800eb0:	f7 f3                	div    %ebx
  800eb2:	89 c1                	mov    %eax,%ecx
  800eb4:	31 d2                	xor    %edx,%edx
  800eb6:	89 f0                	mov    %esi,%eax
  800eb8:	f7 f1                	div    %ecx
  800eba:	89 c6                	mov    %eax,%esi
  800ebc:	89 e8                	mov    %ebp,%eax
  800ebe:	89 f7                	mov    %esi,%edi
  800ec0:	f7 f1                	div    %ecx
  800ec2:	89 fa                	mov    %edi,%edx
  800ec4:	83 c4 1c             	add    $0x1c,%esp
  800ec7:	5b                   	pop    %ebx
  800ec8:	5e                   	pop    %esi
  800ec9:	5f                   	pop    %edi
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    
  800ecc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	39 f2                	cmp    %esi,%edx
  800ed2:	77 7c                	ja     800f50 <__udivdi3+0xd0>
  800ed4:	0f bd fa             	bsr    %edx,%edi
  800ed7:	83 f7 1f             	xor    $0x1f,%edi
  800eda:	0f 84 98 00 00 00    	je     800f78 <__udivdi3+0xf8>
  800ee0:	89 f9                	mov    %edi,%ecx
  800ee2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ee7:	29 f8                	sub    %edi,%eax
  800ee9:	d3 e2                	shl    %cl,%edx
  800eeb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800eef:	89 c1                	mov    %eax,%ecx
  800ef1:	89 da                	mov    %ebx,%edx
  800ef3:	d3 ea                	shr    %cl,%edx
  800ef5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ef9:	09 d1                	or     %edx,%ecx
  800efb:	89 f2                	mov    %esi,%edx
  800efd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f01:	89 f9                	mov    %edi,%ecx
  800f03:	d3 e3                	shl    %cl,%ebx
  800f05:	89 c1                	mov    %eax,%ecx
  800f07:	d3 ea                	shr    %cl,%edx
  800f09:	89 f9                	mov    %edi,%ecx
  800f0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f0f:	d3 e6                	shl    %cl,%esi
  800f11:	89 eb                	mov    %ebp,%ebx
  800f13:	89 c1                	mov    %eax,%ecx
  800f15:	d3 eb                	shr    %cl,%ebx
  800f17:	09 de                	or     %ebx,%esi
  800f19:	89 f0                	mov    %esi,%eax
  800f1b:	f7 74 24 08          	divl   0x8(%esp)
  800f1f:	89 d6                	mov    %edx,%esi
  800f21:	89 c3                	mov    %eax,%ebx
  800f23:	f7 64 24 0c          	mull   0xc(%esp)
  800f27:	39 d6                	cmp    %edx,%esi
  800f29:	72 0c                	jb     800f37 <__udivdi3+0xb7>
  800f2b:	89 f9                	mov    %edi,%ecx
  800f2d:	d3 e5                	shl    %cl,%ebp
  800f2f:	39 c5                	cmp    %eax,%ebp
  800f31:	73 5d                	jae    800f90 <__udivdi3+0x110>
  800f33:	39 d6                	cmp    %edx,%esi
  800f35:	75 59                	jne    800f90 <__udivdi3+0x110>
  800f37:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f3a:	31 ff                	xor    %edi,%edi
  800f3c:	89 fa                	mov    %edi,%edx
  800f3e:	83 c4 1c             	add    $0x1c,%esp
  800f41:	5b                   	pop    %ebx
  800f42:	5e                   	pop    %esi
  800f43:	5f                   	pop    %edi
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    
  800f46:	8d 76 00             	lea    0x0(%esi),%esi
  800f49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800f50:	31 ff                	xor    %edi,%edi
  800f52:	31 c0                	xor    %eax,%eax
  800f54:	89 fa                	mov    %edi,%edx
  800f56:	83 c4 1c             	add    $0x1c,%esp
  800f59:	5b                   	pop    %ebx
  800f5a:	5e                   	pop    %esi
  800f5b:	5f                   	pop    %edi
  800f5c:	5d                   	pop    %ebp
  800f5d:	c3                   	ret    
  800f5e:	66 90                	xchg   %ax,%ax
  800f60:	31 ff                	xor    %edi,%edi
  800f62:	89 e8                	mov    %ebp,%eax
  800f64:	89 f2                	mov    %esi,%edx
  800f66:	f7 f3                	div    %ebx
  800f68:	89 fa                	mov    %edi,%edx
  800f6a:	83 c4 1c             	add    $0x1c,%esp
  800f6d:	5b                   	pop    %ebx
  800f6e:	5e                   	pop    %esi
  800f6f:	5f                   	pop    %edi
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    
  800f72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f78:	39 f2                	cmp    %esi,%edx
  800f7a:	72 06                	jb     800f82 <__udivdi3+0x102>
  800f7c:	31 c0                	xor    %eax,%eax
  800f7e:	39 eb                	cmp    %ebp,%ebx
  800f80:	77 d2                	ja     800f54 <__udivdi3+0xd4>
  800f82:	b8 01 00 00 00       	mov    $0x1,%eax
  800f87:	eb cb                	jmp    800f54 <__udivdi3+0xd4>
  800f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f90:	89 d8                	mov    %ebx,%eax
  800f92:	31 ff                	xor    %edi,%edi
  800f94:	eb be                	jmp    800f54 <__udivdi3+0xd4>
  800f96:	66 90                	xchg   %ax,%ax
  800f98:	66 90                	xchg   %ax,%ax
  800f9a:	66 90                	xchg   %ax,%ax
  800f9c:	66 90                	xchg   %ax,%ax
  800f9e:	66 90                	xchg   %ax,%ax

00800fa0 <__umoddi3>:
  800fa0:	55                   	push   %ebp
  800fa1:	57                   	push   %edi
  800fa2:	56                   	push   %esi
  800fa3:	53                   	push   %ebx
  800fa4:	83 ec 1c             	sub    $0x1c,%esp
  800fa7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800fab:	8b 74 24 30          	mov    0x30(%esp),%esi
  800faf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800fb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800fb7:	85 ed                	test   %ebp,%ebp
  800fb9:	89 f0                	mov    %esi,%eax
  800fbb:	89 da                	mov    %ebx,%edx
  800fbd:	75 19                	jne    800fd8 <__umoddi3+0x38>
  800fbf:	39 df                	cmp    %ebx,%edi
  800fc1:	0f 86 b1 00 00 00    	jbe    801078 <__umoddi3+0xd8>
  800fc7:	f7 f7                	div    %edi
  800fc9:	89 d0                	mov    %edx,%eax
  800fcb:	31 d2                	xor    %edx,%edx
  800fcd:	83 c4 1c             	add    $0x1c,%esp
  800fd0:	5b                   	pop    %ebx
  800fd1:	5e                   	pop    %esi
  800fd2:	5f                   	pop    %edi
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    
  800fd5:	8d 76 00             	lea    0x0(%esi),%esi
  800fd8:	39 dd                	cmp    %ebx,%ebp
  800fda:	77 f1                	ja     800fcd <__umoddi3+0x2d>
  800fdc:	0f bd cd             	bsr    %ebp,%ecx
  800fdf:	83 f1 1f             	xor    $0x1f,%ecx
  800fe2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fe6:	0f 84 b4 00 00 00    	je     8010a0 <__umoddi3+0x100>
  800fec:	b8 20 00 00 00       	mov    $0x20,%eax
  800ff1:	89 c2                	mov    %eax,%edx
  800ff3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ff7:	29 c2                	sub    %eax,%edx
  800ff9:	89 c1                	mov    %eax,%ecx
  800ffb:	89 f8                	mov    %edi,%eax
  800ffd:	d3 e5                	shl    %cl,%ebp
  800fff:	89 d1                	mov    %edx,%ecx
  801001:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801005:	d3 e8                	shr    %cl,%eax
  801007:	09 c5                	or     %eax,%ebp
  801009:	8b 44 24 04          	mov    0x4(%esp),%eax
  80100d:	89 c1                	mov    %eax,%ecx
  80100f:	d3 e7                	shl    %cl,%edi
  801011:	89 d1                	mov    %edx,%ecx
  801013:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801017:	89 df                	mov    %ebx,%edi
  801019:	d3 ef                	shr    %cl,%edi
  80101b:	89 c1                	mov    %eax,%ecx
  80101d:	89 f0                	mov    %esi,%eax
  80101f:	d3 e3                	shl    %cl,%ebx
  801021:	89 d1                	mov    %edx,%ecx
  801023:	89 fa                	mov    %edi,%edx
  801025:	d3 e8                	shr    %cl,%eax
  801027:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80102c:	09 d8                	or     %ebx,%eax
  80102e:	f7 f5                	div    %ebp
  801030:	d3 e6                	shl    %cl,%esi
  801032:	89 d1                	mov    %edx,%ecx
  801034:	f7 64 24 08          	mull   0x8(%esp)
  801038:	39 d1                	cmp    %edx,%ecx
  80103a:	89 c3                	mov    %eax,%ebx
  80103c:	89 d7                	mov    %edx,%edi
  80103e:	72 06                	jb     801046 <__umoddi3+0xa6>
  801040:	75 0e                	jne    801050 <__umoddi3+0xb0>
  801042:	39 c6                	cmp    %eax,%esi
  801044:	73 0a                	jae    801050 <__umoddi3+0xb0>
  801046:	2b 44 24 08          	sub    0x8(%esp),%eax
  80104a:	19 ea                	sbb    %ebp,%edx
  80104c:	89 d7                	mov    %edx,%edi
  80104e:	89 c3                	mov    %eax,%ebx
  801050:	89 ca                	mov    %ecx,%edx
  801052:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801057:	29 de                	sub    %ebx,%esi
  801059:	19 fa                	sbb    %edi,%edx
  80105b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80105f:	89 d0                	mov    %edx,%eax
  801061:	d3 e0                	shl    %cl,%eax
  801063:	89 d9                	mov    %ebx,%ecx
  801065:	d3 ee                	shr    %cl,%esi
  801067:	d3 ea                	shr    %cl,%edx
  801069:	09 f0                	or     %esi,%eax
  80106b:	83 c4 1c             	add    $0x1c,%esp
  80106e:	5b                   	pop    %ebx
  80106f:	5e                   	pop    %esi
  801070:	5f                   	pop    %edi
  801071:	5d                   	pop    %ebp
  801072:	c3                   	ret    
  801073:	90                   	nop
  801074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801078:	85 ff                	test   %edi,%edi
  80107a:	89 f9                	mov    %edi,%ecx
  80107c:	75 0b                	jne    801089 <__umoddi3+0xe9>
  80107e:	b8 01 00 00 00       	mov    $0x1,%eax
  801083:	31 d2                	xor    %edx,%edx
  801085:	f7 f7                	div    %edi
  801087:	89 c1                	mov    %eax,%ecx
  801089:	89 d8                	mov    %ebx,%eax
  80108b:	31 d2                	xor    %edx,%edx
  80108d:	f7 f1                	div    %ecx
  80108f:	89 f0                	mov    %esi,%eax
  801091:	f7 f1                	div    %ecx
  801093:	e9 31 ff ff ff       	jmp    800fc9 <__umoddi3+0x29>
  801098:	90                   	nop
  801099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010a0:	39 dd                	cmp    %ebx,%ebp
  8010a2:	72 08                	jb     8010ac <__umoddi3+0x10c>
  8010a4:	39 f7                	cmp    %esi,%edi
  8010a6:	0f 87 21 ff ff ff    	ja     800fcd <__umoddi3+0x2d>
  8010ac:	89 da                	mov    %ebx,%edx
  8010ae:	89 f0                	mov    %esi,%eax
  8010b0:	29 f8                	sub    %edi,%eax
  8010b2:	19 ea                	sbb    %ebp,%edx
  8010b4:	e9 14 ff ff ff       	jmp    800fcd <__umoddi3+0x2d>
