
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 29 00 00 00       	call   80005a <libmain>
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
  80003a:	e8 17 00 00 00       	call   800056 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	sys_cputs((char*)1, 1);
  800045:	6a 01                	push   $0x1
  800047:	6a 01                	push   $0x1
  800049:	e8 88 00 00 00       	call   8000d6 <sys_cputs>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800054:	c9                   	leave  
  800055:	c3                   	ret    

00800056 <__x86.get_pc_thunk.bx>:
  800056:	8b 1c 24             	mov    (%esp),%ebx
  800059:	c3                   	ret    

0080005a <libmain>:

const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void libmain(int argc, char **argv)
{
  80005a:	55                   	push   %ebp
  80005b:	89 e5                	mov    %esp,%ebp
  80005d:	57                   	push   %edi
  80005e:	56                   	push   %esi
  80005f:	53                   	push   %ebx
  800060:	83 ec 0c             	sub    $0xc,%esp
  800063:	e8 ee ff ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800068:	81 c3 98 1f 00 00    	add    $0x1f98,%ebx
  80006e:	8b 75 08             	mov    0x8(%ebp),%esi
  800071:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())]; // ENVX()得到id在Env[]数组中对应的下标
  800074:	e8 ef 00 00 00       	call   800168 <sys_getenvid>
  800079:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800081:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800087:	c7 c2 44 20 80 00    	mov    $0x802044,%edx
  80008d:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008f:	85 f6                	test   %esi,%esi
  800091:	7e 08                	jle    80009b <libmain+0x41>
		binaryname = argv[0];
  800093:	8b 07                	mov    (%edi),%eax
  800095:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80009b:	83 ec 08             	sub    $0x8,%esp
  80009e:	57                   	push   %edi
  80009f:	56                   	push   %esi
  8000a0:	e8 8e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a5:	e8 0b 00 00 00       	call   8000b5 <exit>
}
  8000aa:	83 c4 10             	add    $0x10,%esp
  8000ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b0:	5b                   	pop    %ebx
  8000b1:	5e                   	pop    %esi
  8000b2:	5f                   	pop    %edi
  8000b3:	5d                   	pop    %ebp
  8000b4:	c3                   	ret    

008000b5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	53                   	push   %ebx
  8000b9:	83 ec 10             	sub    $0x10,%esp
  8000bc:	e8 95 ff ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8000c1:	81 c3 3f 1f 00 00    	add    $0x1f3f,%ebx
	sys_env_destroy(0);
  8000c7:	6a 00                	push   $0x0
  8000c9:	e8 45 00 00 00       	call   800113 <sys_env_destroy>
}
  8000ce:	83 c4 10             	add    $0x10,%esp
  8000d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000d4:	c9                   	leave  
  8000d5:	c3                   	ret    

008000d6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000e7:	89 c3                	mov    %eax,%ebx
  8000e9:	89 c7                	mov    %eax,%edi
  8000eb:	89 c6                	mov    %eax,%esi
  8000ed:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ef:	5b                   	pop    %ebx
  8000f0:	5e                   	pop    %esi
  8000f1:	5f                   	pop    %edi
  8000f2:	5d                   	pop    %ebp
  8000f3:	c3                   	ret    

008000f4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	57                   	push   %edi
  8000f8:	56                   	push   %esi
  8000f9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ff:	b8 01 00 00 00       	mov    $0x1,%eax
  800104:	89 d1                	mov    %edx,%ecx
  800106:	89 d3                	mov    %edx,%ebx
  800108:	89 d7                	mov    %edx,%edi
  80010a:	89 d6                	mov    %edx,%esi
  80010c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	57                   	push   %edi
  800117:	56                   	push   %esi
  800118:	53                   	push   %ebx
  800119:	83 ec 1c             	sub    $0x1c,%esp
  80011c:	e8 ac 02 00 00       	call   8003cd <__x86.get_pc_thunk.ax>
  800121:	05 df 1e 00 00       	add    $0x1edf,%eax
  800126:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800129:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012e:	8b 55 08             	mov    0x8(%ebp),%edx
  800131:	b8 03 00 00 00       	mov    $0x3,%eax
  800136:	89 cb                	mov    %ecx,%ebx
  800138:	89 cf                	mov    %ecx,%edi
  80013a:	89 ce                	mov    %ecx,%esi
  80013c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80013e:	85 c0                	test   %eax,%eax
  800140:	7f 08                	jg     80014a <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800142:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5f                   	pop    %edi
  800148:	5d                   	pop    %ebp
  800149:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80014a:	83 ec 0c             	sub    $0xc,%esp
  80014d:	50                   	push   %eax
  80014e:	6a 03                	push   $0x3
  800150:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800153:	8d 83 c6 f0 ff ff    	lea    -0xf3a(%ebx),%eax
  800159:	50                   	push   %eax
  80015a:	6a 23                	push   $0x23
  80015c:	8d 83 e3 f0 ff ff    	lea    -0xf1d(%ebx),%eax
  800162:	50                   	push   %eax
  800163:	e8 69 02 00 00       	call   8003d1 <_panic>

00800168 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80016e:	ba 00 00 00 00       	mov    $0x0,%edx
  800173:	b8 02 00 00 00       	mov    $0x2,%eax
  800178:	89 d1                	mov    %edx,%ecx
  80017a:	89 d3                	mov    %edx,%ebx
  80017c:	89 d7                	mov    %edx,%edi
  80017e:	89 d6                	mov    %edx,%esi
  800180:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800182:	5b                   	pop    %ebx
  800183:	5e                   	pop    %esi
  800184:	5f                   	pop    %edi
  800185:	5d                   	pop    %ebp
  800186:	c3                   	ret    

00800187 <sys_yield>:

void
sys_yield(void)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80018d:	ba 00 00 00 00       	mov    $0x0,%edx
  800192:	b8 0a 00 00 00       	mov    $0xa,%eax
  800197:	89 d1                	mov    %edx,%ecx
  800199:	89 d3                	mov    %edx,%ebx
  80019b:	89 d7                	mov    %edx,%edi
  80019d:	89 d6                	mov    %edx,%esi
  80019f:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 1c             	sub    $0x1c,%esp
  8001af:	e8 19 02 00 00       	call   8003cd <__x86.get_pc_thunk.ax>
  8001b4:	05 4c 1e 00 00       	add    $0x1e4c,%eax
  8001b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8001bc:	be 00 00 00 00       	mov    $0x0,%esi
  8001c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c7:	b8 04 00 00 00       	mov    $0x4,%eax
  8001cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001cf:	89 f7                	mov    %esi,%edi
  8001d1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001d3:	85 c0                	test   %eax,%eax
  8001d5:	7f 08                	jg     8001df <sys_page_alloc+0x39>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001da:	5b                   	pop    %ebx
  8001db:	5e                   	pop    %esi
  8001dc:	5f                   	pop    %edi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001df:	83 ec 0c             	sub    $0xc,%esp
  8001e2:	50                   	push   %eax
  8001e3:	6a 04                	push   $0x4
  8001e5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8001e8:	8d 83 c6 f0 ff ff    	lea    -0xf3a(%ebx),%eax
  8001ee:	50                   	push   %eax
  8001ef:	6a 23                	push   $0x23
  8001f1:	8d 83 e3 f0 ff ff    	lea    -0xf1d(%ebx),%eax
  8001f7:	50                   	push   %eax
  8001f8:	e8 d4 01 00 00       	call   8003d1 <_panic>

008001fd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	57                   	push   %edi
  800201:	56                   	push   %esi
  800202:	53                   	push   %ebx
  800203:	83 ec 1c             	sub    $0x1c,%esp
  800206:	e8 c2 01 00 00       	call   8003cd <__x86.get_pc_thunk.ax>
  80020b:	05 f5 1d 00 00       	add    $0x1df5,%eax
  800210:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800213:	8b 55 08             	mov    0x8(%ebp),%edx
  800216:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800219:	b8 05 00 00 00       	mov    $0x5,%eax
  80021e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800221:	8b 7d 14             	mov    0x14(%ebp),%edi
  800224:	8b 75 18             	mov    0x18(%ebp),%esi
  800227:	cd 30                	int    $0x30
	if(check && ret > 0)
  800229:	85 c0                	test   %eax,%eax
  80022b:	7f 08                	jg     800235 <sys_page_map+0x38>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80022d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800230:	5b                   	pop    %ebx
  800231:	5e                   	pop    %esi
  800232:	5f                   	pop    %edi
  800233:	5d                   	pop    %ebp
  800234:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	50                   	push   %eax
  800239:	6a 05                	push   $0x5
  80023b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80023e:	8d 83 c6 f0 ff ff    	lea    -0xf3a(%ebx),%eax
  800244:	50                   	push   %eax
  800245:	6a 23                	push   $0x23
  800247:	8d 83 e3 f0 ff ff    	lea    -0xf1d(%ebx),%eax
  80024d:	50                   	push   %eax
  80024e:	e8 7e 01 00 00       	call   8003d1 <_panic>

00800253 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	57                   	push   %edi
  800257:	56                   	push   %esi
  800258:	53                   	push   %ebx
  800259:	83 ec 1c             	sub    $0x1c,%esp
  80025c:	e8 6c 01 00 00       	call   8003cd <__x86.get_pc_thunk.ax>
  800261:	05 9f 1d 00 00       	add    $0x1d9f,%eax
  800266:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800269:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026e:	8b 55 08             	mov    0x8(%ebp),%edx
  800271:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800274:	b8 06 00 00 00       	mov    $0x6,%eax
  800279:	89 df                	mov    %ebx,%edi
  80027b:	89 de                	mov    %ebx,%esi
  80027d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80027f:	85 c0                	test   %eax,%eax
  800281:	7f 08                	jg     80028b <sys_page_unmap+0x38>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800283:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800286:	5b                   	pop    %ebx
  800287:	5e                   	pop    %esi
  800288:	5f                   	pop    %edi
  800289:	5d                   	pop    %ebp
  80028a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80028b:	83 ec 0c             	sub    $0xc,%esp
  80028e:	50                   	push   %eax
  80028f:	6a 06                	push   $0x6
  800291:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800294:	8d 83 c6 f0 ff ff    	lea    -0xf3a(%ebx),%eax
  80029a:	50                   	push   %eax
  80029b:	6a 23                	push   $0x23
  80029d:	8d 83 e3 f0 ff ff    	lea    -0xf1d(%ebx),%eax
  8002a3:	50                   	push   %eax
  8002a4:	e8 28 01 00 00       	call   8003d1 <_panic>

008002a9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 1c             	sub    $0x1c,%esp
  8002b2:	e8 16 01 00 00       	call   8003cd <__x86.get_pc_thunk.ax>
  8002b7:	05 49 1d 00 00       	add    $0x1d49,%eax
  8002bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8002bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ca:	b8 08 00 00 00       	mov    $0x8,%eax
  8002cf:	89 df                	mov    %ebx,%edi
  8002d1:	89 de                	mov    %ebx,%esi
  8002d3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d5:	85 c0                	test   %eax,%eax
  8002d7:	7f 08                	jg     8002e1 <sys_env_set_status+0x38>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dc:	5b                   	pop    %ebx
  8002dd:	5e                   	pop    %esi
  8002de:	5f                   	pop    %edi
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e1:	83 ec 0c             	sub    $0xc,%esp
  8002e4:	50                   	push   %eax
  8002e5:	6a 08                	push   $0x8
  8002e7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002ea:	8d 83 c6 f0 ff ff    	lea    -0xf3a(%ebx),%eax
  8002f0:	50                   	push   %eax
  8002f1:	6a 23                	push   $0x23
  8002f3:	8d 83 e3 f0 ff ff    	lea    -0xf1d(%ebx),%eax
  8002f9:	50                   	push   %eax
  8002fa:	e8 d2 00 00 00       	call   8003d1 <_panic>

008002ff <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	57                   	push   %edi
  800303:	56                   	push   %esi
  800304:	53                   	push   %ebx
  800305:	83 ec 1c             	sub    $0x1c,%esp
  800308:	e8 c0 00 00 00       	call   8003cd <__x86.get_pc_thunk.ax>
  80030d:	05 f3 1c 00 00       	add    $0x1cf3,%eax
  800312:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800315:	bb 00 00 00 00       	mov    $0x0,%ebx
  80031a:	8b 55 08             	mov    0x8(%ebp),%edx
  80031d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800320:	b8 09 00 00 00       	mov    $0x9,%eax
  800325:	89 df                	mov    %ebx,%edi
  800327:	89 de                	mov    %ebx,%esi
  800329:	cd 30                	int    $0x30
	if(check && ret > 0)
  80032b:	85 c0                	test   %eax,%eax
  80032d:	7f 08                	jg     800337 <sys_env_set_pgfault_upcall+0x38>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80032f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800332:	5b                   	pop    %ebx
  800333:	5e                   	pop    %esi
  800334:	5f                   	pop    %edi
  800335:	5d                   	pop    %ebp
  800336:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800337:	83 ec 0c             	sub    $0xc,%esp
  80033a:	50                   	push   %eax
  80033b:	6a 09                	push   $0x9
  80033d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800340:	8d 83 c6 f0 ff ff    	lea    -0xf3a(%ebx),%eax
  800346:	50                   	push   %eax
  800347:	6a 23                	push   $0x23
  800349:	8d 83 e3 f0 ff ff    	lea    -0xf1d(%ebx),%eax
  80034f:	50                   	push   %eax
  800350:	e8 7c 00 00 00       	call   8003d1 <_panic>

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
  80035b:	8b 55 08             	mov    0x8(%ebp),%edx
  80035e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800361:	b8 0b 00 00 00       	mov    $0xb,%eax
  800366:	be 00 00 00 00       	mov    $0x0,%esi
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
  80037e:	83 ec 1c             	sub    $0x1c,%esp
  800381:	e8 47 00 00 00       	call   8003cd <__x86.get_pc_thunk.ax>
  800386:	05 7a 1c 00 00       	add    $0x1c7a,%eax
  80038b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80038e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800393:	8b 55 08             	mov    0x8(%ebp),%edx
  800396:	b8 0c 00 00 00       	mov    $0xc,%eax
  80039b:	89 cb                	mov    %ecx,%ebx
  80039d:	89 cf                	mov    %ecx,%edi
  80039f:	89 ce                	mov    %ecx,%esi
  8003a1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8003a3:	85 c0                	test   %eax,%eax
  8003a5:	7f 08                	jg     8003af <sys_ipc_recv+0x37>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003aa:	5b                   	pop    %ebx
  8003ab:	5e                   	pop    %esi
  8003ac:	5f                   	pop    %edi
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8003af:	83 ec 0c             	sub    $0xc,%esp
  8003b2:	50                   	push   %eax
  8003b3:	6a 0c                	push   $0xc
  8003b5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8003b8:	8d 83 c6 f0 ff ff    	lea    -0xf3a(%ebx),%eax
  8003be:	50                   	push   %eax
  8003bf:	6a 23                	push   $0x23
  8003c1:	8d 83 e3 f0 ff ff    	lea    -0xf1d(%ebx),%eax
  8003c7:	50                   	push   %eax
  8003c8:	e8 04 00 00 00       	call   8003d1 <_panic>

008003cd <__x86.get_pc_thunk.ax>:
  8003cd:	8b 04 24             	mov    (%esp),%eax
  8003d0:	c3                   	ret    

008003d1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	57                   	push   %edi
  8003d5:	56                   	push   %esi
  8003d6:	53                   	push   %ebx
  8003d7:	83 ec 0c             	sub    $0xc,%esp
  8003da:	e8 77 fc ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8003df:	81 c3 21 1c 00 00    	add    $0x1c21,%ebx
	va_list ap;

	va_start(ap, fmt);
  8003e5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003e8:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  8003ee:	8b 38                	mov    (%eax),%edi
  8003f0:	e8 73 fd ff ff       	call   800168 <sys_getenvid>
  8003f5:	83 ec 0c             	sub    $0xc,%esp
  8003f8:	ff 75 0c             	pushl  0xc(%ebp)
  8003fb:	ff 75 08             	pushl  0x8(%ebp)
  8003fe:	57                   	push   %edi
  8003ff:	50                   	push   %eax
  800400:	8d 83 f4 f0 ff ff    	lea    -0xf0c(%ebx),%eax
  800406:	50                   	push   %eax
  800407:	e8 d1 00 00 00       	call   8004dd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80040c:	83 c4 18             	add    $0x18,%esp
  80040f:	56                   	push   %esi
  800410:	ff 75 10             	pushl  0x10(%ebp)
  800413:	e8 63 00 00 00       	call   80047b <vcprintf>
	cprintf("\n");
  800418:	8d 83 18 f1 ff ff    	lea    -0xee8(%ebx),%eax
  80041e:	89 04 24             	mov    %eax,(%esp)
  800421:	e8 b7 00 00 00       	call   8004dd <cprintf>
  800426:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800429:	cc                   	int3   
  80042a:	eb fd                	jmp    800429 <_panic+0x58>

0080042c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	56                   	push   %esi
  800430:	53                   	push   %ebx
  800431:	e8 20 fc ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800436:	81 c3 ca 1b 00 00    	add    $0x1bca,%ebx
  80043c:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  80043f:	8b 16                	mov    (%esi),%edx
  800441:	8d 42 01             	lea    0x1(%edx),%eax
  800444:	89 06                	mov    %eax,(%esi)
  800446:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800449:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  80044d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800452:	74 0b                	je     80045f <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800454:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800458:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80045b:	5b                   	pop    %ebx
  80045c:	5e                   	pop    %esi
  80045d:	5d                   	pop    %ebp
  80045e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	68 ff 00 00 00       	push   $0xff
  800467:	8d 46 08             	lea    0x8(%esi),%eax
  80046a:	50                   	push   %eax
  80046b:	e8 66 fc ff ff       	call   8000d6 <sys_cputs>
		b->idx = 0;
  800470:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800476:	83 c4 10             	add    $0x10,%esp
  800479:	eb d9                	jmp    800454 <putch+0x28>

0080047b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80047b:	55                   	push   %ebp
  80047c:	89 e5                	mov    %esp,%ebp
  80047e:	53                   	push   %ebx
  80047f:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800485:	e8 cc fb ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  80048a:	81 c3 76 1b 00 00    	add    $0x1b76,%ebx
	struct printbuf b;

	b.idx = 0;
  800490:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800497:	00 00 00 
	b.cnt = 0;
  80049a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004a4:	ff 75 0c             	pushl  0xc(%ebp)
  8004a7:	ff 75 08             	pushl  0x8(%ebp)
  8004aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004b0:	50                   	push   %eax
  8004b1:	8d 83 2c e4 ff ff    	lea    -0x1bd4(%ebx),%eax
  8004b7:	50                   	push   %eax
  8004b8:	e8 38 01 00 00       	call   8005f5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004bd:	83 c4 08             	add    $0x8,%esp
  8004c0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004c6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004cc:	50                   	push   %eax
  8004cd:	e8 04 fc ff ff       	call   8000d6 <sys_cputs>

	return b.cnt;
}
  8004d2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004db:	c9                   	leave  
  8004dc:	c3                   	ret    

008004dd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004dd:	55                   	push   %ebp
  8004de:	89 e5                	mov    %esp,%ebp
  8004e0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004e3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004e6:	50                   	push   %eax
  8004e7:	ff 75 08             	pushl  0x8(%ebp)
  8004ea:	e8 8c ff ff ff       	call   80047b <vcprintf>
	va_end(ap);

	return cnt;
}
  8004ef:	c9                   	leave  
  8004f0:	c3                   	ret    

008004f1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  8004f1:	55                   	push   %ebp
  8004f2:	89 e5                	mov    %esp,%ebp
  8004f4:	57                   	push   %edi
  8004f5:	56                   	push   %esi
  8004f6:	53                   	push   %ebx
  8004f7:	83 ec 2c             	sub    $0x2c,%esp
  8004fa:	e8 02 06 00 00       	call   800b01 <__x86.get_pc_thunk.cx>
  8004ff:	81 c1 01 1b 00 00    	add    $0x1b01,%ecx
  800505:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800508:	89 c7                	mov    %eax,%edi
  80050a:	89 d6                	mov    %edx,%esi
  80050c:	8b 45 08             	mov    0x8(%ebp),%eax
  80050f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800512:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800515:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  800518:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80051b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800520:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800523:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  800526:	39 d3                	cmp    %edx,%ebx
  800528:	72 09                	jb     800533 <printnum+0x42>
  80052a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80052d:	0f 87 83 00 00 00    	ja     8005b6 <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800533:	83 ec 0c             	sub    $0xc,%esp
  800536:	ff 75 18             	pushl  0x18(%ebp)
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80053f:	53                   	push   %ebx
  800540:	ff 75 10             	pushl  0x10(%ebp)
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	ff 75 dc             	pushl  -0x24(%ebp)
  800549:	ff 75 d8             	pushl  -0x28(%ebp)
  80054c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80054f:	ff 75 d0             	pushl  -0x30(%ebp)
  800552:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800555:	e8 26 09 00 00       	call   800e80 <__udivdi3>
  80055a:	83 c4 18             	add    $0x18,%esp
  80055d:	52                   	push   %edx
  80055e:	50                   	push   %eax
  80055f:	89 f2                	mov    %esi,%edx
  800561:	89 f8                	mov    %edi,%eax
  800563:	e8 89 ff ff ff       	call   8004f1 <printnum>
  800568:	83 c4 20             	add    $0x20,%esp
  80056b:	eb 13                	jmp    800580 <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	56                   	push   %esi
  800571:	ff 75 18             	pushl  0x18(%ebp)
  800574:	ff d7                	call   *%edi
  800576:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800579:	83 eb 01             	sub    $0x1,%ebx
  80057c:	85 db                	test   %ebx,%ebx
  80057e:	7f ed                	jg     80056d <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	56                   	push   %esi
  800584:	83 ec 04             	sub    $0x4,%esp
  800587:	ff 75 dc             	pushl  -0x24(%ebp)
  80058a:	ff 75 d8             	pushl  -0x28(%ebp)
  80058d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800590:	ff 75 d0             	pushl  -0x30(%ebp)
  800593:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800596:	89 f3                	mov    %esi,%ebx
  800598:	e8 03 0a 00 00       	call   800fa0 <__umoddi3>
  80059d:	83 c4 14             	add    $0x14,%esp
  8005a0:	0f be 84 06 1a f1 ff 	movsbl -0xee6(%esi,%eax,1),%eax
  8005a7:	ff 
  8005a8:	50                   	push   %eax
  8005a9:	ff d7                	call   *%edi
}
  8005ab:	83 c4 10             	add    $0x10,%esp
  8005ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005b1:	5b                   	pop    %ebx
  8005b2:	5e                   	pop    %esi
  8005b3:	5f                   	pop    %edi
  8005b4:	5d                   	pop    %ebp
  8005b5:	c3                   	ret    
  8005b6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005b9:	eb be                	jmp    800579 <printnum+0x88>

008005bb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005bb:	55                   	push   %ebp
  8005bc:	89 e5                	mov    %esp,%ebp
  8005be:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005c1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005c5:	8b 10                	mov    (%eax),%edx
  8005c7:	3b 50 04             	cmp    0x4(%eax),%edx
  8005ca:	73 0a                	jae    8005d6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8005cc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005cf:	89 08                	mov    %ecx,(%eax)
  8005d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d4:	88 02                	mov    %al,(%edx)
}
  8005d6:	5d                   	pop    %ebp
  8005d7:	c3                   	ret    

008005d8 <printfmt>:
{
  8005d8:	55                   	push   %ebp
  8005d9:	89 e5                	mov    %esp,%ebp
  8005db:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8005de:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005e1:	50                   	push   %eax
  8005e2:	ff 75 10             	pushl  0x10(%ebp)
  8005e5:	ff 75 0c             	pushl  0xc(%ebp)
  8005e8:	ff 75 08             	pushl  0x8(%ebp)
  8005eb:	e8 05 00 00 00       	call   8005f5 <vprintfmt>
}
  8005f0:	83 c4 10             	add    $0x10,%esp
  8005f3:	c9                   	leave  
  8005f4:	c3                   	ret    

008005f5 <vprintfmt>:
{
  8005f5:	55                   	push   %ebp
  8005f6:	89 e5                	mov    %esp,%ebp
  8005f8:	57                   	push   %edi
  8005f9:	56                   	push   %esi
  8005fa:	53                   	push   %ebx
  8005fb:	83 ec 2c             	sub    $0x2c,%esp
  8005fe:	e8 53 fa ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800603:	81 c3 fd 19 00 00    	add    $0x19fd,%ebx
  800609:	8b 75 0c             	mov    0xc(%ebp),%esi
  80060c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80060f:	e9 c3 03 00 00       	jmp    8009d7 <.L35+0x48>
		padc = ' ';
  800614:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800618:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80061f:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  800626:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80062d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800632:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800635:	8d 47 01             	lea    0x1(%edi),%eax
  800638:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80063b:	0f b6 17             	movzbl (%edi),%edx
  80063e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800641:	3c 55                	cmp    $0x55,%al
  800643:	0f 87 16 04 00 00    	ja     800a5f <.L22>
  800649:	0f b6 c0             	movzbl %al,%eax
  80064c:	89 d9                	mov    %ebx,%ecx
  80064e:	03 8c 83 d4 f1 ff ff 	add    -0xe2c(%ebx,%eax,4),%ecx
  800655:	ff e1                	jmp    *%ecx

00800657 <.L69>:
  800657:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80065a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80065e:	eb d5                	jmp    800635 <vprintfmt+0x40>

00800660 <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800660:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800663:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800667:	eb cc                	jmp    800635 <vprintfmt+0x40>

00800669 <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800669:	0f b6 d2             	movzbl %dl,%edx
  80066c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
  80066f:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  800674:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800677:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80067b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80067e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800681:	83 f9 09             	cmp    $0x9,%ecx
  800684:	77 55                	ja     8006db <.L23+0xf>
			for (precision = 0;; ++fmt)
  800686:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800689:	eb e9                	jmp    800674 <.L29+0xb>

0080068b <.L26>:
			precision = va_arg(ap, int);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8b 00                	mov    (%eax),%eax
  800690:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8d 40 04             	lea    0x4(%eax),%eax
  800699:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80069c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80069f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006a3:	79 90                	jns    800635 <vprintfmt+0x40>
				width = precision, precision = -1;
  8006a5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ab:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8006b2:	eb 81                	jmp    800635 <vprintfmt+0x40>

008006b4 <.L27>:
  8006b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006b7:	85 c0                	test   %eax,%eax
  8006b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8006be:	0f 49 d0             	cmovns %eax,%edx
  8006c1:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c7:	e9 69 ff ff ff       	jmp    800635 <vprintfmt+0x40>

008006cc <.L23>:
  8006cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8006cf:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006d6:	e9 5a ff ff ff       	jmp    800635 <vprintfmt+0x40>
  8006db:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006de:	eb bf                	jmp    80069f <.L26+0x14>

008006e0 <.L33>:
			lflag++;
  8006e0:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8006e7:	e9 49 ff ff ff       	jmp    800635 <vprintfmt+0x40>

008006ec <.L30>:
			putch(va_arg(ap, int), putdat);
  8006ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ef:	8d 78 04             	lea    0x4(%eax),%edi
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	56                   	push   %esi
  8006f6:	ff 30                	pushl  (%eax)
  8006f8:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006fb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8006fe:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800701:	e9 ce 02 00 00       	jmp    8009d4 <.L35+0x45>

00800706 <.L32>:
			err = va_arg(ap, int);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8d 78 04             	lea    0x4(%eax),%edi
  80070c:	8b 00                	mov    (%eax),%eax
  80070e:	99                   	cltd   
  80070f:	31 d0                	xor    %edx,%eax
  800711:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800713:	83 f8 08             	cmp    $0x8,%eax
  800716:	7f 27                	jg     80073f <.L32+0x39>
  800718:	8b 94 83 20 00 00 00 	mov    0x20(%ebx,%eax,4),%edx
  80071f:	85 d2                	test   %edx,%edx
  800721:	74 1c                	je     80073f <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  800723:	52                   	push   %edx
  800724:	8d 83 3b f1 ff ff    	lea    -0xec5(%ebx),%eax
  80072a:	50                   	push   %eax
  80072b:	56                   	push   %esi
  80072c:	ff 75 08             	pushl  0x8(%ebp)
  80072f:	e8 a4 fe ff ff       	call   8005d8 <printfmt>
  800734:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800737:	89 7d 14             	mov    %edi,0x14(%ebp)
  80073a:	e9 95 02 00 00       	jmp    8009d4 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  80073f:	50                   	push   %eax
  800740:	8d 83 32 f1 ff ff    	lea    -0xece(%ebx),%eax
  800746:	50                   	push   %eax
  800747:	56                   	push   %esi
  800748:	ff 75 08             	pushl  0x8(%ebp)
  80074b:	e8 88 fe ff ff       	call   8005d8 <printfmt>
  800750:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800753:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800756:	e9 79 02 00 00       	jmp    8009d4 <.L35+0x45>

0080075b <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  80075b:	8b 45 14             	mov    0x14(%ebp),%eax
  80075e:	83 c0 04             	add    $0x4,%eax
  800761:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800764:	8b 45 14             	mov    0x14(%ebp),%eax
  800767:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800769:	85 ff                	test   %edi,%edi
  80076b:	8d 83 2b f1 ff ff    	lea    -0xed5(%ebx),%eax
  800771:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800774:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800778:	0f 8e b5 00 00 00    	jle    800833 <.L36+0xd8>
  80077e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800782:	75 08                	jne    80078c <.L36+0x31>
  800784:	89 75 0c             	mov    %esi,0xc(%ebp)
  800787:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80078a:	eb 6d                	jmp    8007f9 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  80078c:	83 ec 08             	sub    $0x8,%esp
  80078f:	ff 75 cc             	pushl  -0x34(%ebp)
  800792:	57                   	push   %edi
  800793:	e8 85 03 00 00       	call   800b1d <strnlen>
  800798:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80079b:	29 c2                	sub    %eax,%edx
  80079d:	89 55 c8             	mov    %edx,-0x38(%ebp)
  8007a0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8007a3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007aa:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007ad:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8007af:	eb 10                	jmp    8007c1 <.L36+0x66>
					putch(padc, putdat);
  8007b1:	83 ec 08             	sub    $0x8,%esp
  8007b4:	56                   	push   %esi
  8007b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8007b8:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8007bb:	83 ef 01             	sub    $0x1,%edi
  8007be:	83 c4 10             	add    $0x10,%esp
  8007c1:	85 ff                	test   %edi,%edi
  8007c3:	7f ec                	jg     8007b1 <.L36+0x56>
  8007c5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007c8:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8007cb:	85 d2                	test   %edx,%edx
  8007cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d2:	0f 49 c2             	cmovns %edx,%eax
  8007d5:	29 c2                	sub    %eax,%edx
  8007d7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8007da:	89 75 0c             	mov    %esi,0xc(%ebp)
  8007dd:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8007e0:	eb 17                	jmp    8007f9 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  8007e2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007e6:	75 30                	jne    800818 <.L36+0xbd>
					putch(ch, putdat);
  8007e8:	83 ec 08             	sub    $0x8,%esp
  8007eb:	ff 75 0c             	pushl  0xc(%ebp)
  8007ee:	50                   	push   %eax
  8007ef:	ff 55 08             	call   *0x8(%ebp)
  8007f2:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007f5:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8007f9:	83 c7 01             	add    $0x1,%edi
  8007fc:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800800:	0f be c2             	movsbl %dl,%eax
  800803:	85 c0                	test   %eax,%eax
  800805:	74 52                	je     800859 <.L36+0xfe>
  800807:	85 f6                	test   %esi,%esi
  800809:	78 d7                	js     8007e2 <.L36+0x87>
  80080b:	83 ee 01             	sub    $0x1,%esi
  80080e:	79 d2                	jns    8007e2 <.L36+0x87>
  800810:	8b 75 0c             	mov    0xc(%ebp),%esi
  800813:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800816:	eb 32                	jmp    80084a <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  800818:	0f be d2             	movsbl %dl,%edx
  80081b:	83 ea 20             	sub    $0x20,%edx
  80081e:	83 fa 5e             	cmp    $0x5e,%edx
  800821:	76 c5                	jbe    8007e8 <.L36+0x8d>
					putch('?', putdat);
  800823:	83 ec 08             	sub    $0x8,%esp
  800826:	ff 75 0c             	pushl  0xc(%ebp)
  800829:	6a 3f                	push   $0x3f
  80082b:	ff 55 08             	call   *0x8(%ebp)
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	eb c2                	jmp    8007f5 <.L36+0x9a>
  800833:	89 75 0c             	mov    %esi,0xc(%ebp)
  800836:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800839:	eb be                	jmp    8007f9 <.L36+0x9e>
				putch(' ', putdat);
  80083b:	83 ec 08             	sub    $0x8,%esp
  80083e:	56                   	push   %esi
  80083f:	6a 20                	push   $0x20
  800841:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800844:	83 ef 01             	sub    $0x1,%edi
  800847:	83 c4 10             	add    $0x10,%esp
  80084a:	85 ff                	test   %edi,%edi
  80084c:	7f ed                	jg     80083b <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  80084e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800851:	89 45 14             	mov    %eax,0x14(%ebp)
  800854:	e9 7b 01 00 00       	jmp    8009d4 <.L35+0x45>
  800859:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80085c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80085f:	eb e9                	jmp    80084a <.L36+0xef>

00800861 <.L31>:
  800861:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800864:	83 f9 01             	cmp    $0x1,%ecx
  800867:	7e 40                	jle    8008a9 <.L31+0x48>
		return va_arg(*ap, long long);
  800869:	8b 45 14             	mov    0x14(%ebp),%eax
  80086c:	8b 50 04             	mov    0x4(%eax),%edx
  80086f:	8b 00                	mov    (%eax),%eax
  800871:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800874:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800877:	8b 45 14             	mov    0x14(%ebp),%eax
  80087a:	8d 40 08             	lea    0x8(%eax),%eax
  80087d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
  800880:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800884:	79 55                	jns    8008db <.L31+0x7a>
				putch('-', putdat);
  800886:	83 ec 08             	sub    $0x8,%esp
  800889:	56                   	push   %esi
  80088a:	6a 2d                	push   $0x2d
  80088c:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  80088f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800892:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800895:	f7 da                	neg    %edx
  800897:	83 d1 00             	adc    $0x0,%ecx
  80089a:	f7 d9                	neg    %ecx
  80089c:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
  80089f:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008a4:	e9 10 01 00 00       	jmp    8009b9 <.L35+0x2a>
	else if (lflag)
  8008a9:	85 c9                	test   %ecx,%ecx
  8008ab:	75 17                	jne    8008c4 <.L31+0x63>
		return va_arg(*ap, int);
  8008ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b0:	8b 00                	mov    (%eax),%eax
  8008b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b5:	99                   	cltd   
  8008b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bc:	8d 40 04             	lea    0x4(%eax),%eax
  8008bf:	89 45 14             	mov    %eax,0x14(%ebp)
  8008c2:	eb bc                	jmp    800880 <.L31+0x1f>
		return va_arg(*ap, long);
  8008c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c7:	8b 00                	mov    (%eax),%eax
  8008c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008cc:	99                   	cltd   
  8008cd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d3:	8d 40 04             	lea    0x4(%eax),%eax
  8008d6:	89 45 14             	mov    %eax,0x14(%ebp)
  8008d9:	eb a5                	jmp    800880 <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  8008db:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008de:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
  8008e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008e6:	e9 ce 00 00 00       	jmp    8009b9 <.L35+0x2a>

008008eb <.L37>:
  8008eb:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8008ee:	83 f9 01             	cmp    $0x1,%ecx
  8008f1:	7e 18                	jle    80090b <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8008f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f6:	8b 10                	mov    (%eax),%edx
  8008f8:	8b 48 04             	mov    0x4(%eax),%ecx
  8008fb:	8d 40 08             	lea    0x8(%eax),%eax
  8008fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800901:	b8 0a 00 00 00       	mov    $0xa,%eax
  800906:	e9 ae 00 00 00       	jmp    8009b9 <.L35+0x2a>
	else if (lflag)
  80090b:	85 c9                	test   %ecx,%ecx
  80090d:	75 1a                	jne    800929 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  80090f:	8b 45 14             	mov    0x14(%ebp),%eax
  800912:	8b 10                	mov    (%eax),%edx
  800914:	b9 00 00 00 00       	mov    $0x0,%ecx
  800919:	8d 40 04             	lea    0x4(%eax),%eax
  80091c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80091f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800924:	e9 90 00 00 00       	jmp    8009b9 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800929:	8b 45 14             	mov    0x14(%ebp),%eax
  80092c:	8b 10                	mov    (%eax),%edx
  80092e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800933:	8d 40 04             	lea    0x4(%eax),%eax
  800936:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800939:	b8 0a 00 00 00       	mov    $0xa,%eax
  80093e:	eb 79                	jmp    8009b9 <.L35+0x2a>

00800940 <.L34>:
  800940:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800943:	83 f9 01             	cmp    $0x1,%ecx
  800946:	7e 15                	jle    80095d <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  800948:	8b 45 14             	mov    0x14(%ebp),%eax
  80094b:	8b 10                	mov    (%eax),%edx
  80094d:	8b 48 04             	mov    0x4(%eax),%ecx
  800950:	8d 40 08             	lea    0x8(%eax),%eax
  800953:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800956:	b8 08 00 00 00       	mov    $0x8,%eax
  80095b:	eb 5c                	jmp    8009b9 <.L35+0x2a>
	else if (lflag)
  80095d:	85 c9                	test   %ecx,%ecx
  80095f:	75 17                	jne    800978 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800961:	8b 45 14             	mov    0x14(%ebp),%eax
  800964:	8b 10                	mov    (%eax),%edx
  800966:	b9 00 00 00 00       	mov    $0x0,%ecx
  80096b:	8d 40 04             	lea    0x4(%eax),%eax
  80096e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800971:	b8 08 00 00 00       	mov    $0x8,%eax
  800976:	eb 41                	jmp    8009b9 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800978:	8b 45 14             	mov    0x14(%ebp),%eax
  80097b:	8b 10                	mov    (%eax),%edx
  80097d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800982:	8d 40 04             	lea    0x4(%eax),%eax
  800985:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800988:	b8 08 00 00 00       	mov    $0x8,%eax
  80098d:	eb 2a                	jmp    8009b9 <.L35+0x2a>

0080098f <.L35>:
			putch('0', putdat);
  80098f:	83 ec 08             	sub    $0x8,%esp
  800992:	56                   	push   %esi
  800993:	6a 30                	push   $0x30
  800995:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800998:	83 c4 08             	add    $0x8,%esp
  80099b:	56                   	push   %esi
  80099c:	6a 78                	push   $0x78
  80099e:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8009a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a4:	8b 10                	mov    (%eax),%edx
  8009a6:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8009ab:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8009ae:	8d 40 04             	lea    0x4(%eax),%eax
  8009b1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009b4:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  8009b9:	83 ec 0c             	sub    $0xc,%esp
  8009bc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8009c0:	57                   	push   %edi
  8009c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8009c4:	50                   	push   %eax
  8009c5:	51                   	push   %ecx
  8009c6:	52                   	push   %edx
  8009c7:	89 f2                	mov    %esi,%edx
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	e8 20 fb ff ff       	call   8004f1 <printnum>
			break;
  8009d1:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8009d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  8009d7:	83 c7 01             	add    $0x1,%edi
  8009da:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8009de:	83 f8 25             	cmp    $0x25,%eax
  8009e1:	0f 84 2d fc ff ff    	je     800614 <vprintfmt+0x1f>
			if (ch == '\0')
  8009e7:	85 c0                	test   %eax,%eax
  8009e9:	0f 84 91 00 00 00    	je     800a80 <.L22+0x21>
			putch(ch, putdat);
  8009ef:	83 ec 08             	sub    $0x8,%esp
  8009f2:	56                   	push   %esi
  8009f3:	50                   	push   %eax
  8009f4:	ff 55 08             	call   *0x8(%ebp)
  8009f7:	83 c4 10             	add    $0x10,%esp
  8009fa:	eb db                	jmp    8009d7 <.L35+0x48>

008009fc <.L38>:
  8009fc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8009ff:	83 f9 01             	cmp    $0x1,%ecx
  800a02:	7e 15                	jle    800a19 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  800a04:	8b 45 14             	mov    0x14(%ebp),%eax
  800a07:	8b 10                	mov    (%eax),%edx
  800a09:	8b 48 04             	mov    0x4(%eax),%ecx
  800a0c:	8d 40 08             	lea    0x8(%eax),%eax
  800a0f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a12:	b8 10 00 00 00       	mov    $0x10,%eax
  800a17:	eb a0                	jmp    8009b9 <.L35+0x2a>
	else if (lflag)
  800a19:	85 c9                	test   %ecx,%ecx
  800a1b:	75 17                	jne    800a34 <.L38+0x38>
		return va_arg(*ap, unsigned int);
  800a1d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a20:	8b 10                	mov    (%eax),%edx
  800a22:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a27:	8d 40 04             	lea    0x4(%eax),%eax
  800a2a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a2d:	b8 10 00 00 00       	mov    $0x10,%eax
  800a32:	eb 85                	jmp    8009b9 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800a34:	8b 45 14             	mov    0x14(%ebp),%eax
  800a37:	8b 10                	mov    (%eax),%edx
  800a39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a3e:	8d 40 04             	lea    0x4(%eax),%eax
  800a41:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a44:	b8 10 00 00 00       	mov    $0x10,%eax
  800a49:	e9 6b ff ff ff       	jmp    8009b9 <.L35+0x2a>

00800a4e <.L25>:
			putch(ch, putdat);
  800a4e:	83 ec 08             	sub    $0x8,%esp
  800a51:	56                   	push   %esi
  800a52:	6a 25                	push   $0x25
  800a54:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a57:	83 c4 10             	add    $0x10,%esp
  800a5a:	e9 75 ff ff ff       	jmp    8009d4 <.L35+0x45>

00800a5f <.L22>:
			putch('%', putdat);
  800a5f:	83 ec 08             	sub    $0x8,%esp
  800a62:	56                   	push   %esi
  800a63:	6a 25                	push   $0x25
  800a65:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a68:	83 c4 10             	add    $0x10,%esp
  800a6b:	89 f8                	mov    %edi,%eax
  800a6d:	eb 03                	jmp    800a72 <.L22+0x13>
  800a6f:	83 e8 01             	sub    $0x1,%eax
  800a72:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800a76:	75 f7                	jne    800a6f <.L22+0x10>
  800a78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a7b:	e9 54 ff ff ff       	jmp    8009d4 <.L35+0x45>
}
  800a80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a83:	5b                   	pop    %ebx
  800a84:	5e                   	pop    %esi
  800a85:	5f                   	pop    %edi
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	53                   	push   %ebx
  800a8c:	83 ec 14             	sub    $0x14,%esp
  800a8f:	e8 c2 f5 ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800a94:	81 c3 6c 15 00 00    	add    $0x156c,%ebx
  800a9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  800aa0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800aa3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800aa7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800aaa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ab1:	85 c0                	test   %eax,%eax
  800ab3:	74 2b                	je     800ae0 <vsnprintf+0x58>
  800ab5:	85 d2                	test   %edx,%edx
  800ab7:	7e 27                	jle    800ae0 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  800ab9:	ff 75 14             	pushl  0x14(%ebp)
  800abc:	ff 75 10             	pushl  0x10(%ebp)
  800abf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ac2:	50                   	push   %eax
  800ac3:	8d 83 bb e5 ff ff    	lea    -0x1a45(%ebx),%eax
  800ac9:	50                   	push   %eax
  800aca:	e8 26 fb ff ff       	call   8005f5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800acf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ad2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ad8:	83 c4 10             	add    $0x10,%esp
}
  800adb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ade:	c9                   	leave  
  800adf:	c3                   	ret    
		return -E_INVAL;
  800ae0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ae5:	eb f4                	jmp    800adb <vsnprintf+0x53>

00800ae7 <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800aed:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800af0:	50                   	push   %eax
  800af1:	ff 75 10             	pushl  0x10(%ebp)
  800af4:	ff 75 0c             	pushl  0xc(%ebp)
  800af7:	ff 75 08             	pushl  0x8(%ebp)
  800afa:	e8 89 ff ff ff       	call   800a88 <vsnprintf>
	va_end(ap);

	return rc;
}
  800aff:	c9                   	leave  
  800b00:	c3                   	ret    

00800b01 <__x86.get_pc_thunk.cx>:
  800b01:	8b 0c 24             	mov    (%esp),%ecx
  800b04:	c3                   	ret    

00800b05 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b10:	eb 03                	jmp    800b15 <strlen+0x10>
		n++;
  800b12:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800b15:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b19:	75 f7                	jne    800b12 <strlen+0xd>
	return n;
}
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b23:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b26:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2b:	eb 03                	jmp    800b30 <strnlen+0x13>
		n++;
  800b2d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b30:	39 d0                	cmp    %edx,%eax
  800b32:	74 06                	je     800b3a <strnlen+0x1d>
  800b34:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b38:	75 f3                	jne    800b2d <strnlen+0x10>
	return n;
}
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	53                   	push   %ebx
  800b40:	8b 45 08             	mov    0x8(%ebp),%eax
  800b43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b46:	89 c2                	mov    %eax,%edx
  800b48:	83 c1 01             	add    $0x1,%ecx
  800b4b:	83 c2 01             	add    $0x1,%edx
  800b4e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b52:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b55:	84 db                	test   %bl,%bl
  800b57:	75 ef                	jne    800b48 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	53                   	push   %ebx
  800b60:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b63:	53                   	push   %ebx
  800b64:	e8 9c ff ff ff       	call   800b05 <strlen>
  800b69:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b6c:	ff 75 0c             	pushl  0xc(%ebp)
  800b6f:	01 d8                	add    %ebx,%eax
  800b71:	50                   	push   %eax
  800b72:	e8 c5 ff ff ff       	call   800b3c <strcpy>
	return dst;
}
  800b77:	89 d8                	mov    %ebx,%eax
  800b79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b7c:	c9                   	leave  
  800b7d:	c3                   	ret    

00800b7e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	8b 75 08             	mov    0x8(%ebp),%esi
  800b86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b89:	89 f3                	mov    %esi,%ebx
  800b8b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b8e:	89 f2                	mov    %esi,%edx
  800b90:	eb 0f                	jmp    800ba1 <strncpy+0x23>
		*dst++ = *src;
  800b92:	83 c2 01             	add    $0x1,%edx
  800b95:	0f b6 01             	movzbl (%ecx),%eax
  800b98:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b9b:	80 39 01             	cmpb   $0x1,(%ecx)
  800b9e:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800ba1:	39 da                	cmp    %ebx,%edx
  800ba3:	75 ed                	jne    800b92 <strncpy+0x14>
	}
	return ret;
}
  800ba5:	89 f0                	mov    %esi,%eax
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
  800bb0:	8b 75 08             	mov    0x8(%ebp),%esi
  800bb3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bb9:	89 f0                	mov    %esi,%eax
  800bbb:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bbf:	85 c9                	test   %ecx,%ecx
  800bc1:	75 0b                	jne    800bce <strlcpy+0x23>
  800bc3:	eb 17                	jmp    800bdc <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bc5:	83 c2 01             	add    $0x1,%edx
  800bc8:	83 c0 01             	add    $0x1,%eax
  800bcb:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800bce:	39 d8                	cmp    %ebx,%eax
  800bd0:	74 07                	je     800bd9 <strlcpy+0x2e>
  800bd2:	0f b6 0a             	movzbl (%edx),%ecx
  800bd5:	84 c9                	test   %cl,%cl
  800bd7:	75 ec                	jne    800bc5 <strlcpy+0x1a>
		*dst = '\0';
  800bd9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bdc:	29 f0                	sub    %esi,%eax
}
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800beb:	eb 06                	jmp    800bf3 <strcmp+0x11>
		p++, q++;
  800bed:	83 c1 01             	add    $0x1,%ecx
  800bf0:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800bf3:	0f b6 01             	movzbl (%ecx),%eax
  800bf6:	84 c0                	test   %al,%al
  800bf8:	74 04                	je     800bfe <strcmp+0x1c>
  800bfa:	3a 02                	cmp    (%edx),%al
  800bfc:	74 ef                	je     800bed <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800bfe:	0f b6 c0             	movzbl %al,%eax
  800c01:	0f b6 12             	movzbl (%edx),%edx
  800c04:	29 d0                	sub    %edx,%eax
}
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	53                   	push   %ebx
  800c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c12:	89 c3                	mov    %eax,%ebx
  800c14:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c17:	eb 06                	jmp    800c1f <strncmp+0x17>
		n--, p++, q++;
  800c19:	83 c0 01             	add    $0x1,%eax
  800c1c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c1f:	39 d8                	cmp    %ebx,%eax
  800c21:	74 16                	je     800c39 <strncmp+0x31>
  800c23:	0f b6 08             	movzbl (%eax),%ecx
  800c26:	84 c9                	test   %cl,%cl
  800c28:	74 04                	je     800c2e <strncmp+0x26>
  800c2a:	3a 0a                	cmp    (%edx),%cl
  800c2c:	74 eb                	je     800c19 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c2e:	0f b6 00             	movzbl (%eax),%eax
  800c31:	0f b6 12             	movzbl (%edx),%edx
  800c34:	29 d0                	sub    %edx,%eax
}
  800c36:	5b                   	pop    %ebx
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    
		return 0;
  800c39:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3e:	eb f6                	jmp    800c36 <strncmp+0x2e>

00800c40 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	8b 45 08             	mov    0x8(%ebp),%eax
  800c46:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c4a:	0f b6 10             	movzbl (%eax),%edx
  800c4d:	84 d2                	test   %dl,%dl
  800c4f:	74 09                	je     800c5a <strchr+0x1a>
		if (*s == c)
  800c51:	38 ca                	cmp    %cl,%dl
  800c53:	74 0a                	je     800c5f <strchr+0x1f>
	for (; *s; s++)
  800c55:	83 c0 01             	add    $0x1,%eax
  800c58:	eb f0                	jmp    800c4a <strchr+0xa>
			return (char *) s;
	return 0;
  800c5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	8b 45 08             	mov    0x8(%ebp),%eax
  800c67:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c6b:	eb 03                	jmp    800c70 <strfind+0xf>
  800c6d:	83 c0 01             	add    $0x1,%eax
  800c70:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c73:	38 ca                	cmp    %cl,%dl
  800c75:	74 04                	je     800c7b <strfind+0x1a>
  800c77:	84 d2                	test   %dl,%dl
  800c79:	75 f2                	jne    800c6d <strfind+0xc>
			break;
	return (char *) s;
}
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
  800c83:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c86:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c89:	85 c9                	test   %ecx,%ecx
  800c8b:	74 13                	je     800ca0 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c8d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c93:	75 05                	jne    800c9a <memset+0x1d>
  800c95:	f6 c1 03             	test   $0x3,%cl
  800c98:	74 0d                	je     800ca7 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9d:	fc                   	cld    
  800c9e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ca0:	89 f8                	mov    %edi,%eax
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    
		c &= 0xFF;
  800ca7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cab:	89 d3                	mov    %edx,%ebx
  800cad:	c1 e3 08             	shl    $0x8,%ebx
  800cb0:	89 d0                	mov    %edx,%eax
  800cb2:	c1 e0 18             	shl    $0x18,%eax
  800cb5:	89 d6                	mov    %edx,%esi
  800cb7:	c1 e6 10             	shl    $0x10,%esi
  800cba:	09 f0                	or     %esi,%eax
  800cbc:	09 c2                	or     %eax,%edx
  800cbe:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800cc0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800cc3:	89 d0                	mov    %edx,%eax
  800cc5:	fc                   	cld    
  800cc6:	f3 ab                	rep stos %eax,%es:(%edi)
  800cc8:	eb d6                	jmp    800ca0 <memset+0x23>

00800cca <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cd8:	39 c6                	cmp    %eax,%esi
  800cda:	73 35                	jae    800d11 <memmove+0x47>
  800cdc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cdf:	39 c2                	cmp    %eax,%edx
  800ce1:	76 2e                	jbe    800d11 <memmove+0x47>
		s += n;
		d += n;
  800ce3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ce6:	89 d6                	mov    %edx,%esi
  800ce8:	09 fe                	or     %edi,%esi
  800cea:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cf0:	74 0c                	je     800cfe <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cf2:	83 ef 01             	sub    $0x1,%edi
  800cf5:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800cf8:	fd                   	std    
  800cf9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800cfb:	fc                   	cld    
  800cfc:	eb 21                	jmp    800d1f <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cfe:	f6 c1 03             	test   $0x3,%cl
  800d01:	75 ef                	jne    800cf2 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d03:	83 ef 04             	sub    $0x4,%edi
  800d06:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d09:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d0c:	fd                   	std    
  800d0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d0f:	eb ea                	jmp    800cfb <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d11:	89 f2                	mov    %esi,%edx
  800d13:	09 c2                	or     %eax,%edx
  800d15:	f6 c2 03             	test   $0x3,%dl
  800d18:	74 09                	je     800d23 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d1a:	89 c7                	mov    %eax,%edi
  800d1c:	fc                   	cld    
  800d1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d23:	f6 c1 03             	test   $0x3,%cl
  800d26:	75 f2                	jne    800d1a <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d28:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d2b:	89 c7                	mov    %eax,%edi
  800d2d:	fc                   	cld    
  800d2e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d30:	eb ed                	jmp    800d1f <memmove+0x55>

00800d32 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d35:	ff 75 10             	pushl  0x10(%ebp)
  800d38:	ff 75 0c             	pushl  0xc(%ebp)
  800d3b:	ff 75 08             	pushl  0x8(%ebp)
  800d3e:	e8 87 ff ff ff       	call   800cca <memmove>
}
  800d43:	c9                   	leave  
  800d44:	c3                   	ret    

00800d45 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	56                   	push   %esi
  800d49:	53                   	push   %ebx
  800d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d50:	89 c6                	mov    %eax,%esi
  800d52:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d55:	39 f0                	cmp    %esi,%eax
  800d57:	74 1c                	je     800d75 <memcmp+0x30>
		if (*s1 != *s2)
  800d59:	0f b6 08             	movzbl (%eax),%ecx
  800d5c:	0f b6 1a             	movzbl (%edx),%ebx
  800d5f:	38 d9                	cmp    %bl,%cl
  800d61:	75 08                	jne    800d6b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800d63:	83 c0 01             	add    $0x1,%eax
  800d66:	83 c2 01             	add    $0x1,%edx
  800d69:	eb ea                	jmp    800d55 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800d6b:	0f b6 c1             	movzbl %cl,%eax
  800d6e:	0f b6 db             	movzbl %bl,%ebx
  800d71:	29 d8                	sub    %ebx,%eax
  800d73:	eb 05                	jmp    800d7a <memcmp+0x35>
	}

	return 0;
  800d75:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	8b 45 08             	mov    0x8(%ebp),%eax
  800d84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d87:	89 c2                	mov    %eax,%edx
  800d89:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d8c:	39 d0                	cmp    %edx,%eax
  800d8e:	73 09                	jae    800d99 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d90:	38 08                	cmp    %cl,(%eax)
  800d92:	74 05                	je     800d99 <memfind+0x1b>
	for (; s < ends; s++)
  800d94:	83 c0 01             	add    $0x1,%eax
  800d97:	eb f3                	jmp    800d8c <memfind+0xe>
			break;
	return (void *) s;
}
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	57                   	push   %edi
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
  800da1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800da7:	eb 03                	jmp    800dac <strtol+0x11>
		s++;
  800da9:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800dac:	0f b6 01             	movzbl (%ecx),%eax
  800daf:	3c 20                	cmp    $0x20,%al
  800db1:	74 f6                	je     800da9 <strtol+0xe>
  800db3:	3c 09                	cmp    $0x9,%al
  800db5:	74 f2                	je     800da9 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800db7:	3c 2b                	cmp    $0x2b,%al
  800db9:	74 2e                	je     800de9 <strtol+0x4e>
	int neg = 0;
  800dbb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800dc0:	3c 2d                	cmp    $0x2d,%al
  800dc2:	74 2f                	je     800df3 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dc4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dca:	75 05                	jne    800dd1 <strtol+0x36>
  800dcc:	80 39 30             	cmpb   $0x30,(%ecx)
  800dcf:	74 2c                	je     800dfd <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dd1:	85 db                	test   %ebx,%ebx
  800dd3:	75 0a                	jne    800ddf <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800dd5:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800dda:	80 39 30             	cmpb   $0x30,(%ecx)
  800ddd:	74 28                	je     800e07 <strtol+0x6c>
		base = 10;
  800ddf:	b8 00 00 00 00       	mov    $0x0,%eax
  800de4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800de7:	eb 50                	jmp    800e39 <strtol+0x9e>
		s++;
  800de9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800dec:	bf 00 00 00 00       	mov    $0x0,%edi
  800df1:	eb d1                	jmp    800dc4 <strtol+0x29>
		s++, neg = 1;
  800df3:	83 c1 01             	add    $0x1,%ecx
  800df6:	bf 01 00 00 00       	mov    $0x1,%edi
  800dfb:	eb c7                	jmp    800dc4 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dfd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e01:	74 0e                	je     800e11 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800e03:	85 db                	test   %ebx,%ebx
  800e05:	75 d8                	jne    800ddf <strtol+0x44>
		s++, base = 8;
  800e07:	83 c1 01             	add    $0x1,%ecx
  800e0a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800e0f:	eb ce                	jmp    800ddf <strtol+0x44>
		s += 2, base = 16;
  800e11:	83 c1 02             	add    $0x2,%ecx
  800e14:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e19:	eb c4                	jmp    800ddf <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800e1b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e1e:	89 f3                	mov    %esi,%ebx
  800e20:	80 fb 19             	cmp    $0x19,%bl
  800e23:	77 29                	ja     800e4e <strtol+0xb3>
			dig = *s - 'a' + 10;
  800e25:	0f be d2             	movsbl %dl,%edx
  800e28:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e2b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e2e:	7d 30                	jge    800e60 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800e30:	83 c1 01             	add    $0x1,%ecx
  800e33:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e37:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800e39:	0f b6 11             	movzbl (%ecx),%edx
  800e3c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e3f:	89 f3                	mov    %esi,%ebx
  800e41:	80 fb 09             	cmp    $0x9,%bl
  800e44:	77 d5                	ja     800e1b <strtol+0x80>
			dig = *s - '0';
  800e46:	0f be d2             	movsbl %dl,%edx
  800e49:	83 ea 30             	sub    $0x30,%edx
  800e4c:	eb dd                	jmp    800e2b <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800e4e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e51:	89 f3                	mov    %esi,%ebx
  800e53:	80 fb 19             	cmp    $0x19,%bl
  800e56:	77 08                	ja     800e60 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800e58:	0f be d2             	movsbl %dl,%edx
  800e5b:	83 ea 37             	sub    $0x37,%edx
  800e5e:	eb cb                	jmp    800e2b <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800e60:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e64:	74 05                	je     800e6b <strtol+0xd0>
		*endptr = (char *) s;
  800e66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e69:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800e6b:	89 c2                	mov    %eax,%edx
  800e6d:	f7 da                	neg    %edx
  800e6f:	85 ff                	test   %edi,%edi
  800e71:	0f 45 c2             	cmovne %edx,%eax
}
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5f                   	pop    %edi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    
  800e79:	66 90                	xchg   %ax,%ax
  800e7b:	66 90                	xchg   %ax,%ax
  800e7d:	66 90                	xchg   %ax,%ax
  800e7f:	90                   	nop

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
