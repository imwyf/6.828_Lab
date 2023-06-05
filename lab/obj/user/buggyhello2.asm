
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 30 00 00 00       	call   800061 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 1e 00 00 00       	call   80005d <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	sys_cputs(hello, 1024*1024);
  800045:	68 00 00 10 00       	push   $0x100000
  80004a:	ff b3 0c 00 00 00    	pushl  0xc(%ebx)
  800050:	e8 88 00 00 00       	call   8000dd <sys_cputs>
}
  800055:	83 c4 10             	add    $0x10,%esp
  800058:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80005b:	c9                   	leave  
  80005c:	c3                   	ret    

0080005d <__x86.get_pc_thunk.bx>:
  80005d:	8b 1c 24             	mov    (%esp),%ebx
  800060:	c3                   	ret    

00800061 <libmain>:

const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void libmain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	57                   	push   %edi
  800065:	56                   	push   %esi
  800066:	53                   	push   %ebx
  800067:	83 ec 0c             	sub    $0xc,%esp
  80006a:	e8 ee ff ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80006f:	81 c3 91 1f 00 00    	add    $0x1f91,%ebx
  800075:	8b 75 08             	mov    0x8(%ebp),%esi
  800078:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())]; // ENVX()得到id在Env[]数组中对应的下标
  80007b:	e8 ef 00 00 00       	call   80016f <sys_getenvid>
  800080:	25 ff 03 00 00       	and    $0x3ff,%eax
  800085:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800088:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  80008e:	c7 c2 44 20 80 00    	mov    $0x802044,%edx
  800094:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800096:	85 f6                	test   %esi,%esi
  800098:	7e 08                	jle    8000a2 <libmain+0x41>
		binaryname = argv[0];
  80009a:	8b 07                	mov    (%edi),%eax
  80009c:	89 83 10 00 00 00    	mov    %eax,0x10(%ebx)

	// call user main routine
	umain(argc, argv);
  8000a2:	83 ec 08             	sub    $0x8,%esp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	e8 87 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ac:	e8 0b 00 00 00       	call   8000bc <exit>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	53                   	push   %ebx
  8000c0:	83 ec 10             	sub    $0x10,%esp
  8000c3:	e8 95 ff ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8000c8:	81 c3 38 1f 00 00    	add    $0x1f38,%ebx
	sys_env_destroy(0);
  8000ce:	6a 00                	push   $0x0
  8000d0:	e8 45 00 00 00       	call   80011a <sys_env_destroy>
}
  8000d5:	83 c4 10             	add    $0x10,%esp
  8000d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000db:	c9                   	leave  
  8000dc:	c3                   	ret    

008000dd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000dd:	55                   	push   %ebp
  8000de:	89 e5                	mov    %esp,%ebp
  8000e0:	57                   	push   %edi
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ee:	89 c3                	mov    %eax,%ebx
  8000f0:	89 c7                	mov    %eax,%edi
  8000f2:	89 c6                	mov    %eax,%esi
  8000f4:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f6:	5b                   	pop    %ebx
  8000f7:	5e                   	pop    %esi
  8000f8:	5f                   	pop    %edi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <sys_cgetc>:

int
sys_cgetc(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	57                   	push   %edi
  8000ff:	56                   	push   %esi
  800100:	53                   	push   %ebx
	asm volatile("int %1\n"
  800101:	ba 00 00 00 00       	mov    $0x0,%edx
  800106:	b8 01 00 00 00       	mov    $0x1,%eax
  80010b:	89 d1                	mov    %edx,%ecx
  80010d:	89 d3                	mov    %edx,%ebx
  80010f:	89 d7                	mov    %edx,%edi
  800111:	89 d6                	mov    %edx,%esi
  800113:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5f                   	pop    %edi
  800118:	5d                   	pop    %ebp
  800119:	c3                   	ret    

0080011a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	57                   	push   %edi
  80011e:	56                   	push   %esi
  80011f:	53                   	push   %ebx
  800120:	83 ec 1c             	sub    $0x1c,%esp
  800123:	e8 ac 02 00 00       	call   8003d4 <__x86.get_pc_thunk.ax>
  800128:	05 d8 1e 00 00       	add    $0x1ed8,%eax
  80012d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800130:	b9 00 00 00 00       	mov    $0x0,%ecx
  800135:	8b 55 08             	mov    0x8(%ebp),%edx
  800138:	b8 03 00 00 00       	mov    $0x3,%eax
  80013d:	89 cb                	mov    %ecx,%ebx
  80013f:	89 cf                	mov    %ecx,%edi
  800141:	89 ce                	mov    %ecx,%esi
  800143:	cd 30                	int    $0x30
	if(check && ret > 0)
  800145:	85 c0                	test   %eax,%eax
  800147:	7f 08                	jg     800151 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800149:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800151:	83 ec 0c             	sub    $0xc,%esp
  800154:	50                   	push   %eax
  800155:	6a 03                	push   $0x3
  800157:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80015a:	8d 83 d4 f0 ff ff    	lea    -0xf2c(%ebx),%eax
  800160:	50                   	push   %eax
  800161:	6a 23                	push   $0x23
  800163:	8d 83 f1 f0 ff ff    	lea    -0xf0f(%ebx),%eax
  800169:	50                   	push   %eax
  80016a:	e8 69 02 00 00       	call   8003d8 <_panic>

0080016f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	57                   	push   %edi
  800173:	56                   	push   %esi
  800174:	53                   	push   %ebx
	asm volatile("int %1\n"
  800175:	ba 00 00 00 00       	mov    $0x0,%edx
  80017a:	b8 02 00 00 00       	mov    $0x2,%eax
  80017f:	89 d1                	mov    %edx,%ecx
  800181:	89 d3                	mov    %edx,%ebx
  800183:	89 d7                	mov    %edx,%edi
  800185:	89 d6                	mov    %edx,%esi
  800187:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800189:	5b                   	pop    %ebx
  80018a:	5e                   	pop    %esi
  80018b:	5f                   	pop    %edi
  80018c:	5d                   	pop    %ebp
  80018d:	c3                   	ret    

0080018e <sys_yield>:

void
sys_yield(void)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	57                   	push   %edi
  800192:	56                   	push   %esi
  800193:	53                   	push   %ebx
	asm volatile("int %1\n"
  800194:	ba 00 00 00 00       	mov    $0x0,%edx
  800199:	b8 0a 00 00 00       	mov    $0xa,%eax
  80019e:	89 d1                	mov    %edx,%ecx
  8001a0:	89 d3                	mov    %edx,%ebx
  8001a2:	89 d7                	mov    %edx,%edi
  8001a4:	89 d6                	mov    %edx,%esi
  8001a6:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 1c             	sub    $0x1c,%esp
  8001b6:	e8 19 02 00 00       	call   8003d4 <__x86.get_pc_thunk.ax>
  8001bb:	05 45 1e 00 00       	add    $0x1e45,%eax
  8001c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8001c3:	be 00 00 00 00       	mov    $0x0,%esi
  8001c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ce:	b8 04 00 00 00       	mov    $0x4,%eax
  8001d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d6:	89 f7                	mov    %esi,%edi
  8001d8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001da:	85 c0                	test   %eax,%eax
  8001dc:	7f 08                	jg     8001e6 <sys_page_alloc+0x39>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e1:	5b                   	pop    %ebx
  8001e2:	5e                   	pop    %esi
  8001e3:	5f                   	pop    %edi
  8001e4:	5d                   	pop    %ebp
  8001e5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e6:	83 ec 0c             	sub    $0xc,%esp
  8001e9:	50                   	push   %eax
  8001ea:	6a 04                	push   $0x4
  8001ec:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8001ef:	8d 83 d4 f0 ff ff    	lea    -0xf2c(%ebx),%eax
  8001f5:	50                   	push   %eax
  8001f6:	6a 23                	push   $0x23
  8001f8:	8d 83 f1 f0 ff ff    	lea    -0xf0f(%ebx),%eax
  8001fe:	50                   	push   %eax
  8001ff:	e8 d4 01 00 00       	call   8003d8 <_panic>

00800204 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	57                   	push   %edi
  800208:	56                   	push   %esi
  800209:	53                   	push   %ebx
  80020a:	83 ec 1c             	sub    $0x1c,%esp
  80020d:	e8 c2 01 00 00       	call   8003d4 <__x86.get_pc_thunk.ax>
  800212:	05 ee 1d 00 00       	add    $0x1dee,%eax
  800217:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80021a:	8b 55 08             	mov    0x8(%ebp),%edx
  80021d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800220:	b8 05 00 00 00       	mov    $0x5,%eax
  800225:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800228:	8b 7d 14             	mov    0x14(%ebp),%edi
  80022b:	8b 75 18             	mov    0x18(%ebp),%esi
  80022e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800230:	85 c0                	test   %eax,%eax
  800232:	7f 08                	jg     80023c <sys_page_map+0x38>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800234:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800237:	5b                   	pop    %ebx
  800238:	5e                   	pop    %esi
  800239:	5f                   	pop    %edi
  80023a:	5d                   	pop    %ebp
  80023b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	50                   	push   %eax
  800240:	6a 05                	push   $0x5
  800242:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800245:	8d 83 d4 f0 ff ff    	lea    -0xf2c(%ebx),%eax
  80024b:	50                   	push   %eax
  80024c:	6a 23                	push   $0x23
  80024e:	8d 83 f1 f0 ff ff    	lea    -0xf0f(%ebx),%eax
  800254:	50                   	push   %eax
  800255:	e8 7e 01 00 00       	call   8003d8 <_panic>

0080025a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80025a:	55                   	push   %ebp
  80025b:	89 e5                	mov    %esp,%ebp
  80025d:	57                   	push   %edi
  80025e:	56                   	push   %esi
  80025f:	53                   	push   %ebx
  800260:	83 ec 1c             	sub    $0x1c,%esp
  800263:	e8 6c 01 00 00       	call   8003d4 <__x86.get_pc_thunk.ax>
  800268:	05 98 1d 00 00       	add    $0x1d98,%eax
  80026d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027b:	b8 06 00 00 00       	mov    $0x6,%eax
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7f 08                	jg     800292 <sys_page_unmap+0x38>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80028a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028d:	5b                   	pop    %ebx
  80028e:	5e                   	pop    %esi
  80028f:	5f                   	pop    %edi
  800290:	5d                   	pop    %ebp
  800291:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 06                	push   $0x6
  800298:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80029b:	8d 83 d4 f0 ff ff    	lea    -0xf2c(%ebx),%eax
  8002a1:	50                   	push   %eax
  8002a2:	6a 23                	push   $0x23
  8002a4:	8d 83 f1 f0 ff ff    	lea    -0xf0f(%ebx),%eax
  8002aa:	50                   	push   %eax
  8002ab:	e8 28 01 00 00       	call   8003d8 <_panic>

008002b0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 1c             	sub    $0x1c,%esp
  8002b9:	e8 16 01 00 00       	call   8003d4 <__x86.get_pc_thunk.ax>
  8002be:	05 42 1d 00 00       	add    $0x1d42,%eax
  8002c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8002c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d1:	b8 08 00 00 00       	mov    $0x8,%eax
  8002d6:	89 df                	mov    %ebx,%edi
  8002d8:	89 de                	mov    %ebx,%esi
  8002da:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	7f 08                	jg     8002e8 <sys_env_set_status+0x38>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e3:	5b                   	pop    %ebx
  8002e4:	5e                   	pop    %esi
  8002e5:	5f                   	pop    %edi
  8002e6:	5d                   	pop    %ebp
  8002e7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	50                   	push   %eax
  8002ec:	6a 08                	push   $0x8
  8002ee:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002f1:	8d 83 d4 f0 ff ff    	lea    -0xf2c(%ebx),%eax
  8002f7:	50                   	push   %eax
  8002f8:	6a 23                	push   $0x23
  8002fa:	8d 83 f1 f0 ff ff    	lea    -0xf0f(%ebx),%eax
  800300:	50                   	push   %eax
  800301:	e8 d2 00 00 00       	call   8003d8 <_panic>

00800306 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 1c             	sub    $0x1c,%esp
  80030f:	e8 c0 00 00 00       	call   8003d4 <__x86.get_pc_thunk.ax>
  800314:	05 ec 1c 00 00       	add    $0x1cec,%eax
  800319:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80031c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800327:	b8 09 00 00 00       	mov    $0x9,%eax
  80032c:	89 df                	mov    %ebx,%edi
  80032e:	89 de                	mov    %ebx,%esi
  800330:	cd 30                	int    $0x30
	if(check && ret > 0)
  800332:	85 c0                	test   %eax,%eax
  800334:	7f 08                	jg     80033e <sys_env_set_pgfault_upcall+0x38>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800336:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800339:	5b                   	pop    %ebx
  80033a:	5e                   	pop    %esi
  80033b:	5f                   	pop    %edi
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80033e:	83 ec 0c             	sub    $0xc,%esp
  800341:	50                   	push   %eax
  800342:	6a 09                	push   $0x9
  800344:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800347:	8d 83 d4 f0 ff ff    	lea    -0xf2c(%ebx),%eax
  80034d:	50                   	push   %eax
  80034e:	6a 23                	push   $0x23
  800350:	8d 83 f1 f0 ff ff    	lea    -0xf0f(%ebx),%eax
  800356:	50                   	push   %eax
  800357:	e8 7c 00 00 00       	call   8003d8 <_panic>

0080035c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	57                   	push   %edi
  800360:	56                   	push   %esi
  800361:	53                   	push   %ebx
	asm volatile("int %1\n"
  800362:	8b 55 08             	mov    0x8(%ebp),%edx
  800365:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800368:	b8 0b 00 00 00       	mov    $0xb,%eax
  80036d:	be 00 00 00 00       	mov    $0x0,%esi
  800372:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800375:	8b 7d 14             	mov    0x14(%ebp),%edi
  800378:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80037a:	5b                   	pop    %ebx
  80037b:	5e                   	pop    %esi
  80037c:	5f                   	pop    %edi
  80037d:	5d                   	pop    %ebp
  80037e:	c3                   	ret    

0080037f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
  800382:	57                   	push   %edi
  800383:	56                   	push   %esi
  800384:	53                   	push   %ebx
  800385:	83 ec 1c             	sub    $0x1c,%esp
  800388:	e8 47 00 00 00       	call   8003d4 <__x86.get_pc_thunk.ax>
  80038d:	05 73 1c 00 00       	add    $0x1c73,%eax
  800392:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800395:	b9 00 00 00 00       	mov    $0x0,%ecx
  80039a:	8b 55 08             	mov    0x8(%ebp),%edx
  80039d:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003a2:	89 cb                	mov    %ecx,%ebx
  8003a4:	89 cf                	mov    %ecx,%edi
  8003a6:	89 ce                	mov    %ecx,%esi
  8003a8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8003aa:	85 c0                	test   %eax,%eax
  8003ac:	7f 08                	jg     8003b6 <sys_ipc_recv+0x37>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b1:	5b                   	pop    %ebx
  8003b2:	5e                   	pop    %esi
  8003b3:	5f                   	pop    %edi
  8003b4:	5d                   	pop    %ebp
  8003b5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b6:	83 ec 0c             	sub    $0xc,%esp
  8003b9:	50                   	push   %eax
  8003ba:	6a 0c                	push   $0xc
  8003bc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8003bf:	8d 83 d4 f0 ff ff    	lea    -0xf2c(%ebx),%eax
  8003c5:	50                   	push   %eax
  8003c6:	6a 23                	push   $0x23
  8003c8:	8d 83 f1 f0 ff ff    	lea    -0xf0f(%ebx),%eax
  8003ce:	50                   	push   %eax
  8003cf:	e8 04 00 00 00       	call   8003d8 <_panic>

008003d4 <__x86.get_pc_thunk.ax>:
  8003d4:	8b 04 24             	mov    (%esp),%eax
  8003d7:	c3                   	ret    

008003d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	57                   	push   %edi
  8003dc:	56                   	push   %esi
  8003dd:	53                   	push   %ebx
  8003de:	83 ec 0c             	sub    $0xc,%esp
  8003e1:	e8 77 fc ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8003e6:	81 c3 1a 1c 00 00    	add    $0x1c1a,%ebx
	va_list ap;

	va_start(ap, fmt);
  8003ec:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003ef:	c7 c0 10 20 80 00    	mov    $0x802010,%eax
  8003f5:	8b 38                	mov    (%eax),%edi
  8003f7:	e8 73 fd ff ff       	call   80016f <sys_getenvid>
  8003fc:	83 ec 0c             	sub    $0xc,%esp
  8003ff:	ff 75 0c             	pushl  0xc(%ebp)
  800402:	ff 75 08             	pushl  0x8(%ebp)
  800405:	57                   	push   %edi
  800406:	50                   	push   %eax
  800407:	8d 83 00 f1 ff ff    	lea    -0xf00(%ebx),%eax
  80040d:	50                   	push   %eax
  80040e:	e8 d1 00 00 00       	call   8004e4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800413:	83 c4 18             	add    $0x18,%esp
  800416:	56                   	push   %esi
  800417:	ff 75 10             	pushl  0x10(%ebp)
  80041a:	e8 63 00 00 00       	call   800482 <vcprintf>
	cprintf("\n");
  80041f:	8d 83 c8 f0 ff ff    	lea    -0xf38(%ebx),%eax
  800425:	89 04 24             	mov    %eax,(%esp)
  800428:	e8 b7 00 00 00       	call   8004e4 <cprintf>
  80042d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800430:	cc                   	int3   
  800431:	eb fd                	jmp    800430 <_panic+0x58>

00800433 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800433:	55                   	push   %ebp
  800434:	89 e5                	mov    %esp,%ebp
  800436:	56                   	push   %esi
  800437:	53                   	push   %ebx
  800438:	e8 20 fc ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80043d:	81 c3 c3 1b 00 00    	add    $0x1bc3,%ebx
  800443:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  800446:	8b 16                	mov    (%esi),%edx
  800448:	8d 42 01             	lea    0x1(%edx),%eax
  80044b:	89 06                	mov    %eax,(%esi)
  80044d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800450:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800454:	3d ff 00 00 00       	cmp    $0xff,%eax
  800459:	74 0b                	je     800466 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80045b:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80045f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800462:	5b                   	pop    %ebx
  800463:	5e                   	pop    %esi
  800464:	5d                   	pop    %ebp
  800465:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	68 ff 00 00 00       	push   $0xff
  80046e:	8d 46 08             	lea    0x8(%esi),%eax
  800471:	50                   	push   %eax
  800472:	e8 66 fc ff ff       	call   8000dd <sys_cputs>
		b->idx = 0;
  800477:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80047d:	83 c4 10             	add    $0x10,%esp
  800480:	eb d9                	jmp    80045b <putch+0x28>

00800482 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800482:	55                   	push   %ebp
  800483:	89 e5                	mov    %esp,%ebp
  800485:	53                   	push   %ebx
  800486:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80048c:	e8 cc fb ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  800491:	81 c3 6f 1b 00 00    	add    $0x1b6f,%ebx
	struct printbuf b;

	b.idx = 0;
  800497:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80049e:	00 00 00 
	b.cnt = 0;
  8004a1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004a8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004ab:	ff 75 0c             	pushl  0xc(%ebp)
  8004ae:	ff 75 08             	pushl  0x8(%ebp)
  8004b1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004b7:	50                   	push   %eax
  8004b8:	8d 83 33 e4 ff ff    	lea    -0x1bcd(%ebx),%eax
  8004be:	50                   	push   %eax
  8004bf:	e8 38 01 00 00       	call   8005fc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004c4:	83 c4 08             	add    $0x8,%esp
  8004c7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004cd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004d3:	50                   	push   %eax
  8004d4:	e8 04 fc ff ff       	call   8000dd <sys_cputs>

	return b.cnt;
}
  8004d9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004e2:	c9                   	leave  
  8004e3:	c3                   	ret    

008004e4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004ea:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004ed:	50                   	push   %eax
  8004ee:	ff 75 08             	pushl  0x8(%ebp)
  8004f1:	e8 8c ff ff ff       	call   800482 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004f6:	c9                   	leave  
  8004f7:	c3                   	ret    

008004f8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  8004f8:	55                   	push   %ebp
  8004f9:	89 e5                	mov    %esp,%ebp
  8004fb:	57                   	push   %edi
  8004fc:	56                   	push   %esi
  8004fd:	53                   	push   %ebx
  8004fe:	83 ec 2c             	sub    $0x2c,%esp
  800501:	e8 02 06 00 00       	call   800b08 <__x86.get_pc_thunk.cx>
  800506:	81 c1 fa 1a 00 00    	add    $0x1afa,%ecx
  80050c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80050f:	89 c7                	mov    %eax,%edi
  800511:	89 d6                	mov    %edx,%esi
  800513:	8b 45 08             	mov    0x8(%ebp),%eax
  800516:	8b 55 0c             	mov    0xc(%ebp),%edx
  800519:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80051c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  80051f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800522:	bb 00 00 00 00       	mov    $0x0,%ebx
  800527:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80052a:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  80052d:	39 d3                	cmp    %edx,%ebx
  80052f:	72 09                	jb     80053a <printnum+0x42>
  800531:	39 45 10             	cmp    %eax,0x10(%ebp)
  800534:	0f 87 83 00 00 00    	ja     8005bd <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80053a:	83 ec 0c             	sub    $0xc,%esp
  80053d:	ff 75 18             	pushl  0x18(%ebp)
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800546:	53                   	push   %ebx
  800547:	ff 75 10             	pushl  0x10(%ebp)
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	ff 75 dc             	pushl  -0x24(%ebp)
  800550:	ff 75 d8             	pushl  -0x28(%ebp)
  800553:	ff 75 d4             	pushl  -0x2c(%ebp)
  800556:	ff 75 d0             	pushl  -0x30(%ebp)
  800559:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80055c:	e8 1f 09 00 00       	call   800e80 <__udivdi3>
  800561:	83 c4 18             	add    $0x18,%esp
  800564:	52                   	push   %edx
  800565:	50                   	push   %eax
  800566:	89 f2                	mov    %esi,%edx
  800568:	89 f8                	mov    %edi,%eax
  80056a:	e8 89 ff ff ff       	call   8004f8 <printnum>
  80056f:	83 c4 20             	add    $0x20,%esp
  800572:	eb 13                	jmp    800587 <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800574:	83 ec 08             	sub    $0x8,%esp
  800577:	56                   	push   %esi
  800578:	ff 75 18             	pushl  0x18(%ebp)
  80057b:	ff d7                	call   *%edi
  80057d:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800580:	83 eb 01             	sub    $0x1,%ebx
  800583:	85 db                	test   %ebx,%ebx
  800585:	7f ed                	jg     800574 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	56                   	push   %esi
  80058b:	83 ec 04             	sub    $0x4,%esp
  80058e:	ff 75 dc             	pushl  -0x24(%ebp)
  800591:	ff 75 d8             	pushl  -0x28(%ebp)
  800594:	ff 75 d4             	pushl  -0x2c(%ebp)
  800597:	ff 75 d0             	pushl  -0x30(%ebp)
  80059a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80059d:	89 f3                	mov    %esi,%ebx
  80059f:	e8 fc 09 00 00       	call   800fa0 <__umoddi3>
  8005a4:	83 c4 14             	add    $0x14,%esp
  8005a7:	0f be 84 06 24 f1 ff 	movsbl -0xedc(%esi,%eax,1),%eax
  8005ae:	ff 
  8005af:	50                   	push   %eax
  8005b0:	ff d7                	call   *%edi
}
  8005b2:	83 c4 10             	add    $0x10,%esp
  8005b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005b8:	5b                   	pop    %ebx
  8005b9:	5e                   	pop    %esi
  8005ba:	5f                   	pop    %edi
  8005bb:	5d                   	pop    %ebp
  8005bc:	c3                   	ret    
  8005bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005c0:	eb be                	jmp    800580 <printnum+0x88>

008005c2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005c2:	55                   	push   %ebp
  8005c3:	89 e5                	mov    %esp,%ebp
  8005c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005c8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005cc:	8b 10                	mov    (%eax),%edx
  8005ce:	3b 50 04             	cmp    0x4(%eax),%edx
  8005d1:	73 0a                	jae    8005dd <sprintputch+0x1b>
		*b->buf++ = ch;
  8005d3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005d6:	89 08                	mov    %ecx,(%eax)
  8005d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005db:	88 02                	mov    %al,(%edx)
}
  8005dd:	5d                   	pop    %ebp
  8005de:	c3                   	ret    

008005df <printfmt>:
{
  8005df:	55                   	push   %ebp
  8005e0:	89 e5                	mov    %esp,%ebp
  8005e2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8005e5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005e8:	50                   	push   %eax
  8005e9:	ff 75 10             	pushl  0x10(%ebp)
  8005ec:	ff 75 0c             	pushl  0xc(%ebp)
  8005ef:	ff 75 08             	pushl  0x8(%ebp)
  8005f2:	e8 05 00 00 00       	call   8005fc <vprintfmt>
}
  8005f7:	83 c4 10             	add    $0x10,%esp
  8005fa:	c9                   	leave  
  8005fb:	c3                   	ret    

008005fc <vprintfmt>:
{
  8005fc:	55                   	push   %ebp
  8005fd:	89 e5                	mov    %esp,%ebp
  8005ff:	57                   	push   %edi
  800600:	56                   	push   %esi
  800601:	53                   	push   %ebx
  800602:	83 ec 2c             	sub    $0x2c,%esp
  800605:	e8 53 fa ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80060a:	81 c3 f6 19 00 00    	add    $0x19f6,%ebx
  800610:	8b 75 0c             	mov    0xc(%ebp),%esi
  800613:	8b 7d 10             	mov    0x10(%ebp),%edi
  800616:	e9 c3 03 00 00       	jmp    8009de <.L35+0x48>
		padc = ' ';
  80061b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80061f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800626:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  80062d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800634:	b9 00 00 00 00       	mov    $0x0,%ecx
  800639:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80063c:	8d 47 01             	lea    0x1(%edi),%eax
  80063f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800642:	0f b6 17             	movzbl (%edi),%edx
  800645:	8d 42 dd             	lea    -0x23(%edx),%eax
  800648:	3c 55                	cmp    $0x55,%al
  80064a:	0f 87 16 04 00 00    	ja     800a66 <.L22>
  800650:	0f b6 c0             	movzbl %al,%eax
  800653:	89 d9                	mov    %ebx,%ecx
  800655:	03 8c 83 dc f1 ff ff 	add    -0xe24(%ebx,%eax,4),%ecx
  80065c:	ff e1                	jmp    *%ecx

0080065e <.L69>:
  80065e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800661:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800665:	eb d5                	jmp    80063c <vprintfmt+0x40>

00800667 <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800667:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80066a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80066e:	eb cc                	jmp    80063c <vprintfmt+0x40>

00800670 <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800670:	0f b6 d2             	movzbl %dl,%edx
  800673:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
  800676:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  80067b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80067e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800682:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800685:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800688:	83 f9 09             	cmp    $0x9,%ecx
  80068b:	77 55                	ja     8006e2 <.L23+0xf>
			for (precision = 0;; ++fmt)
  80068d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800690:	eb e9                	jmp    80067b <.L29+0xb>

00800692 <.L26>:
			precision = va_arg(ap, int);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8b 00                	mov    (%eax),%eax
  800697:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8d 40 04             	lea    0x4(%eax),%eax
  8006a0:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8006a6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006aa:	79 90                	jns    80063c <vprintfmt+0x40>
				width = precision, precision = -1;
  8006ac:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b2:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8006b9:	eb 81                	jmp    80063c <vprintfmt+0x40>

008006bb <.L27>:
  8006bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006be:	85 c0                	test   %eax,%eax
  8006c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c5:	0f 49 d0             	cmovns %eax,%edx
  8006c8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ce:	e9 69 ff ff ff       	jmp    80063c <vprintfmt+0x40>

008006d3 <.L23>:
  8006d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8006d6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006dd:	e9 5a ff ff ff       	jmp    80063c <vprintfmt+0x40>
  8006e2:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006e5:	eb bf                	jmp    8006a6 <.L26+0x14>

008006e7 <.L33>:
			lflag++;
  8006e7:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8006ee:	e9 49 ff ff ff       	jmp    80063c <vprintfmt+0x40>

008006f3 <.L30>:
			putch(va_arg(ap, int), putdat);
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8d 78 04             	lea    0x4(%eax),%edi
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	56                   	push   %esi
  8006fd:	ff 30                	pushl  (%eax)
  8006ff:	ff 55 08             	call   *0x8(%ebp)
			break;
  800702:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800705:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800708:	e9 ce 02 00 00       	jmp    8009db <.L35+0x45>

0080070d <.L32>:
			err = va_arg(ap, int);
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8d 78 04             	lea    0x4(%eax),%edi
  800713:	8b 00                	mov    (%eax),%eax
  800715:	99                   	cltd   
  800716:	31 d0                	xor    %edx,%eax
  800718:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80071a:	83 f8 08             	cmp    $0x8,%eax
  80071d:	7f 27                	jg     800746 <.L32+0x39>
  80071f:	8b 94 83 20 00 00 00 	mov    0x20(%ebx,%eax,4),%edx
  800726:	85 d2                	test   %edx,%edx
  800728:	74 1c                	je     800746 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  80072a:	52                   	push   %edx
  80072b:	8d 83 45 f1 ff ff    	lea    -0xebb(%ebx),%eax
  800731:	50                   	push   %eax
  800732:	56                   	push   %esi
  800733:	ff 75 08             	pushl  0x8(%ebp)
  800736:	e8 a4 fe ff ff       	call   8005df <printfmt>
  80073b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80073e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800741:	e9 95 02 00 00       	jmp    8009db <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  800746:	50                   	push   %eax
  800747:	8d 83 3c f1 ff ff    	lea    -0xec4(%ebx),%eax
  80074d:	50                   	push   %eax
  80074e:	56                   	push   %esi
  80074f:	ff 75 08             	pushl  0x8(%ebp)
  800752:	e8 88 fe ff ff       	call   8005df <printfmt>
  800757:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80075a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80075d:	e9 79 02 00 00       	jmp    8009db <.L35+0x45>

00800762 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800762:	8b 45 14             	mov    0x14(%ebp),%eax
  800765:	83 c0 04             	add    $0x4,%eax
  800768:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800770:	85 ff                	test   %edi,%edi
  800772:	8d 83 35 f1 ff ff    	lea    -0xecb(%ebx),%eax
  800778:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80077b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80077f:	0f 8e b5 00 00 00    	jle    80083a <.L36+0xd8>
  800785:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800789:	75 08                	jne    800793 <.L36+0x31>
  80078b:	89 75 0c             	mov    %esi,0xc(%ebp)
  80078e:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800791:	eb 6d                	jmp    800800 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800793:	83 ec 08             	sub    $0x8,%esp
  800796:	ff 75 cc             	pushl  -0x34(%ebp)
  800799:	57                   	push   %edi
  80079a:	e8 85 03 00 00       	call   800b24 <strnlen>
  80079f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007a2:	29 c2                	sub    %eax,%edx
  8007a4:	89 55 c8             	mov    %edx,-0x38(%ebp)
  8007a7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8007aa:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007b1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007b4:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8007b6:	eb 10                	jmp    8007c8 <.L36+0x66>
					putch(padc, putdat);
  8007b8:	83 ec 08             	sub    $0x8,%esp
  8007bb:	56                   	push   %esi
  8007bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8007bf:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8007c2:	83 ef 01             	sub    $0x1,%edi
  8007c5:	83 c4 10             	add    $0x10,%esp
  8007c8:	85 ff                	test   %edi,%edi
  8007ca:	7f ec                	jg     8007b8 <.L36+0x56>
  8007cc:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007cf:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8007d2:	85 d2                	test   %edx,%edx
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d9:	0f 49 c2             	cmovns %edx,%eax
  8007dc:	29 c2                	sub    %eax,%edx
  8007de:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8007e1:	89 75 0c             	mov    %esi,0xc(%ebp)
  8007e4:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8007e7:	eb 17                	jmp    800800 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  8007e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007ed:	75 30                	jne    80081f <.L36+0xbd>
					putch(ch, putdat);
  8007ef:	83 ec 08             	sub    $0x8,%esp
  8007f2:	ff 75 0c             	pushl  0xc(%ebp)
  8007f5:	50                   	push   %eax
  8007f6:	ff 55 08             	call   *0x8(%ebp)
  8007f9:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007fc:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800800:	83 c7 01             	add    $0x1,%edi
  800803:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800807:	0f be c2             	movsbl %dl,%eax
  80080a:	85 c0                	test   %eax,%eax
  80080c:	74 52                	je     800860 <.L36+0xfe>
  80080e:	85 f6                	test   %esi,%esi
  800810:	78 d7                	js     8007e9 <.L36+0x87>
  800812:	83 ee 01             	sub    $0x1,%esi
  800815:	79 d2                	jns    8007e9 <.L36+0x87>
  800817:	8b 75 0c             	mov    0xc(%ebp),%esi
  80081a:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80081d:	eb 32                	jmp    800851 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  80081f:	0f be d2             	movsbl %dl,%edx
  800822:	83 ea 20             	sub    $0x20,%edx
  800825:	83 fa 5e             	cmp    $0x5e,%edx
  800828:	76 c5                	jbe    8007ef <.L36+0x8d>
					putch('?', putdat);
  80082a:	83 ec 08             	sub    $0x8,%esp
  80082d:	ff 75 0c             	pushl  0xc(%ebp)
  800830:	6a 3f                	push   $0x3f
  800832:	ff 55 08             	call   *0x8(%ebp)
  800835:	83 c4 10             	add    $0x10,%esp
  800838:	eb c2                	jmp    8007fc <.L36+0x9a>
  80083a:	89 75 0c             	mov    %esi,0xc(%ebp)
  80083d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800840:	eb be                	jmp    800800 <.L36+0x9e>
				putch(' ', putdat);
  800842:	83 ec 08             	sub    $0x8,%esp
  800845:	56                   	push   %esi
  800846:	6a 20                	push   $0x20
  800848:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  80084b:	83 ef 01             	sub    $0x1,%edi
  80084e:	83 c4 10             	add    $0x10,%esp
  800851:	85 ff                	test   %edi,%edi
  800853:	7f ed                	jg     800842 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800855:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800858:	89 45 14             	mov    %eax,0x14(%ebp)
  80085b:	e9 7b 01 00 00       	jmp    8009db <.L35+0x45>
  800860:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800863:	8b 75 0c             	mov    0xc(%ebp),%esi
  800866:	eb e9                	jmp    800851 <.L36+0xef>

00800868 <.L31>:
  800868:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80086b:	83 f9 01             	cmp    $0x1,%ecx
  80086e:	7e 40                	jle    8008b0 <.L31+0x48>
		return va_arg(*ap, long long);
  800870:	8b 45 14             	mov    0x14(%ebp),%eax
  800873:	8b 50 04             	mov    0x4(%eax),%edx
  800876:	8b 00                	mov    (%eax),%eax
  800878:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80087b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80087e:	8b 45 14             	mov    0x14(%ebp),%eax
  800881:	8d 40 08             	lea    0x8(%eax),%eax
  800884:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
  800887:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80088b:	79 55                	jns    8008e2 <.L31+0x7a>
				putch('-', putdat);
  80088d:	83 ec 08             	sub    $0x8,%esp
  800890:	56                   	push   %esi
  800891:	6a 2d                	push   $0x2d
  800893:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  800896:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800899:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80089c:	f7 da                	neg    %edx
  80089e:	83 d1 00             	adc    $0x0,%ecx
  8008a1:	f7 d9                	neg    %ecx
  8008a3:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
  8008a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008ab:	e9 10 01 00 00       	jmp    8009c0 <.L35+0x2a>
	else if (lflag)
  8008b0:	85 c9                	test   %ecx,%ecx
  8008b2:	75 17                	jne    8008cb <.L31+0x63>
		return va_arg(*ap, int);
  8008b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b7:	8b 00                	mov    (%eax),%eax
  8008b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008bc:	99                   	cltd   
  8008bd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c3:	8d 40 04             	lea    0x4(%eax),%eax
  8008c6:	89 45 14             	mov    %eax,0x14(%ebp)
  8008c9:	eb bc                	jmp    800887 <.L31+0x1f>
		return va_arg(*ap, long);
  8008cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ce:	8b 00                	mov    (%eax),%eax
  8008d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008d3:	99                   	cltd   
  8008d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008da:	8d 40 04             	lea    0x4(%eax),%eax
  8008dd:	89 45 14             	mov    %eax,0x14(%ebp)
  8008e0:	eb a5                	jmp    800887 <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  8008e2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008e5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
  8008e8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008ed:	e9 ce 00 00 00       	jmp    8009c0 <.L35+0x2a>

008008f2 <.L37>:
  8008f2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8008f5:	83 f9 01             	cmp    $0x1,%ecx
  8008f8:	7e 18                	jle    800912 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8008fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fd:	8b 10                	mov    (%eax),%edx
  8008ff:	8b 48 04             	mov    0x4(%eax),%ecx
  800902:	8d 40 08             	lea    0x8(%eax),%eax
  800905:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800908:	b8 0a 00 00 00       	mov    $0xa,%eax
  80090d:	e9 ae 00 00 00       	jmp    8009c0 <.L35+0x2a>
	else if (lflag)
  800912:	85 c9                	test   %ecx,%ecx
  800914:	75 1a                	jne    800930 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  800916:	8b 45 14             	mov    0x14(%ebp),%eax
  800919:	8b 10                	mov    (%eax),%edx
  80091b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800920:	8d 40 04             	lea    0x4(%eax),%eax
  800923:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800926:	b8 0a 00 00 00       	mov    $0xa,%eax
  80092b:	e9 90 00 00 00       	jmp    8009c0 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800930:	8b 45 14             	mov    0x14(%ebp),%eax
  800933:	8b 10                	mov    (%eax),%edx
  800935:	b9 00 00 00 00       	mov    $0x0,%ecx
  80093a:	8d 40 04             	lea    0x4(%eax),%eax
  80093d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800940:	b8 0a 00 00 00       	mov    $0xa,%eax
  800945:	eb 79                	jmp    8009c0 <.L35+0x2a>

00800947 <.L34>:
  800947:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80094a:	83 f9 01             	cmp    $0x1,%ecx
  80094d:	7e 15                	jle    800964 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  80094f:	8b 45 14             	mov    0x14(%ebp),%eax
  800952:	8b 10                	mov    (%eax),%edx
  800954:	8b 48 04             	mov    0x4(%eax),%ecx
  800957:	8d 40 08             	lea    0x8(%eax),%eax
  80095a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80095d:	b8 08 00 00 00       	mov    $0x8,%eax
  800962:	eb 5c                	jmp    8009c0 <.L35+0x2a>
	else if (lflag)
  800964:	85 c9                	test   %ecx,%ecx
  800966:	75 17                	jne    80097f <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800968:	8b 45 14             	mov    0x14(%ebp),%eax
  80096b:	8b 10                	mov    (%eax),%edx
  80096d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800972:	8d 40 04             	lea    0x4(%eax),%eax
  800975:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800978:	b8 08 00 00 00       	mov    $0x8,%eax
  80097d:	eb 41                	jmp    8009c0 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  80097f:	8b 45 14             	mov    0x14(%ebp),%eax
  800982:	8b 10                	mov    (%eax),%edx
  800984:	b9 00 00 00 00       	mov    $0x0,%ecx
  800989:	8d 40 04             	lea    0x4(%eax),%eax
  80098c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80098f:	b8 08 00 00 00       	mov    $0x8,%eax
  800994:	eb 2a                	jmp    8009c0 <.L35+0x2a>

00800996 <.L35>:
			putch('0', putdat);
  800996:	83 ec 08             	sub    $0x8,%esp
  800999:	56                   	push   %esi
  80099a:	6a 30                	push   $0x30
  80099c:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80099f:	83 c4 08             	add    $0x8,%esp
  8009a2:	56                   	push   %esi
  8009a3:	6a 78                	push   $0x78
  8009a5:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8009a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ab:	8b 10                	mov    (%eax),%edx
  8009ad:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8009b2:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8009b5:	8d 40 04             	lea    0x4(%eax),%eax
  8009b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009bb:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  8009c0:	83 ec 0c             	sub    $0xc,%esp
  8009c3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8009c7:	57                   	push   %edi
  8009c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8009cb:	50                   	push   %eax
  8009cc:	51                   	push   %ecx
  8009cd:	52                   	push   %edx
  8009ce:	89 f2                	mov    %esi,%edx
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	e8 20 fb ff ff       	call   8004f8 <printnum>
			break;
  8009d8:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8009db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  8009de:	83 c7 01             	add    $0x1,%edi
  8009e1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8009e5:	83 f8 25             	cmp    $0x25,%eax
  8009e8:	0f 84 2d fc ff ff    	je     80061b <vprintfmt+0x1f>
			if (ch == '\0')
  8009ee:	85 c0                	test   %eax,%eax
  8009f0:	0f 84 91 00 00 00    	je     800a87 <.L22+0x21>
			putch(ch, putdat);
  8009f6:	83 ec 08             	sub    $0x8,%esp
  8009f9:	56                   	push   %esi
  8009fa:	50                   	push   %eax
  8009fb:	ff 55 08             	call   *0x8(%ebp)
  8009fe:	83 c4 10             	add    $0x10,%esp
  800a01:	eb db                	jmp    8009de <.L35+0x48>

00800a03 <.L38>:
  800a03:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  800a06:	83 f9 01             	cmp    $0x1,%ecx
  800a09:	7e 15                	jle    800a20 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  800a0b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0e:	8b 10                	mov    (%eax),%edx
  800a10:	8b 48 04             	mov    0x4(%eax),%ecx
  800a13:	8d 40 08             	lea    0x8(%eax),%eax
  800a16:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a19:	b8 10 00 00 00       	mov    $0x10,%eax
  800a1e:	eb a0                	jmp    8009c0 <.L35+0x2a>
	else if (lflag)
  800a20:	85 c9                	test   %ecx,%ecx
  800a22:	75 17                	jne    800a3b <.L38+0x38>
		return va_arg(*ap, unsigned int);
  800a24:	8b 45 14             	mov    0x14(%ebp),%eax
  800a27:	8b 10                	mov    (%eax),%edx
  800a29:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a2e:	8d 40 04             	lea    0x4(%eax),%eax
  800a31:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a34:	b8 10 00 00 00       	mov    $0x10,%eax
  800a39:	eb 85                	jmp    8009c0 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800a3b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a3e:	8b 10                	mov    (%eax),%edx
  800a40:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a45:	8d 40 04             	lea    0x4(%eax),%eax
  800a48:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a4b:	b8 10 00 00 00       	mov    $0x10,%eax
  800a50:	e9 6b ff ff ff       	jmp    8009c0 <.L35+0x2a>

00800a55 <.L25>:
			putch(ch, putdat);
  800a55:	83 ec 08             	sub    $0x8,%esp
  800a58:	56                   	push   %esi
  800a59:	6a 25                	push   $0x25
  800a5b:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a5e:	83 c4 10             	add    $0x10,%esp
  800a61:	e9 75 ff ff ff       	jmp    8009db <.L35+0x45>

00800a66 <.L22>:
			putch('%', putdat);
  800a66:	83 ec 08             	sub    $0x8,%esp
  800a69:	56                   	push   %esi
  800a6a:	6a 25                	push   $0x25
  800a6c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a6f:	83 c4 10             	add    $0x10,%esp
  800a72:	89 f8                	mov    %edi,%eax
  800a74:	eb 03                	jmp    800a79 <.L22+0x13>
  800a76:	83 e8 01             	sub    $0x1,%eax
  800a79:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800a7d:	75 f7                	jne    800a76 <.L22+0x10>
  800a7f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a82:	e9 54 ff ff ff       	jmp    8009db <.L35+0x45>
}
  800a87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a8a:	5b                   	pop    %ebx
  800a8b:	5e                   	pop    %esi
  800a8c:	5f                   	pop    %edi
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	53                   	push   %ebx
  800a93:	83 ec 14             	sub    $0x14,%esp
  800a96:	e8 c2 f5 ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  800a9b:	81 c3 65 15 00 00    	add    $0x1565,%ebx
  800aa1:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  800aa7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800aaa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800aae:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ab1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ab8:	85 c0                	test   %eax,%eax
  800aba:	74 2b                	je     800ae7 <vsnprintf+0x58>
  800abc:	85 d2                	test   %edx,%edx
  800abe:	7e 27                	jle    800ae7 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  800ac0:	ff 75 14             	pushl  0x14(%ebp)
  800ac3:	ff 75 10             	pushl  0x10(%ebp)
  800ac6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ac9:	50                   	push   %eax
  800aca:	8d 83 c2 e5 ff ff    	lea    -0x1a3e(%ebx),%eax
  800ad0:	50                   	push   %eax
  800ad1:	e8 26 fb ff ff       	call   8005fc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ad6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ad9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800adf:	83 c4 10             	add    $0x10,%esp
}
  800ae2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ae5:	c9                   	leave  
  800ae6:	c3                   	ret    
		return -E_INVAL;
  800ae7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800aec:	eb f4                	jmp    800ae2 <vsnprintf+0x53>

00800aee <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800af4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800af7:	50                   	push   %eax
  800af8:	ff 75 10             	pushl  0x10(%ebp)
  800afb:	ff 75 0c             	pushl  0xc(%ebp)
  800afe:	ff 75 08             	pushl  0x8(%ebp)
  800b01:	e8 89 ff ff ff       	call   800a8f <vsnprintf>
	va_end(ap);

	return rc;
}
  800b06:	c9                   	leave  
  800b07:	c3                   	ret    

00800b08 <__x86.get_pc_thunk.cx>:
  800b08:	8b 0c 24             	mov    (%esp),%ecx
  800b0b:	c3                   	ret    

00800b0c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b12:	b8 00 00 00 00       	mov    $0x0,%eax
  800b17:	eb 03                	jmp    800b1c <strlen+0x10>
		n++;
  800b19:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800b1c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b20:	75 f7                	jne    800b19 <strlen+0xd>
	return n;
}
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b32:	eb 03                	jmp    800b37 <strnlen+0x13>
		n++;
  800b34:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b37:	39 d0                	cmp    %edx,%eax
  800b39:	74 06                	je     800b41 <strnlen+0x1d>
  800b3b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b3f:	75 f3                	jne    800b34 <strnlen+0x10>
	return n;
}
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	53                   	push   %ebx
  800b47:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b4d:	89 c2                	mov    %eax,%edx
  800b4f:	83 c1 01             	add    $0x1,%ecx
  800b52:	83 c2 01             	add    $0x1,%edx
  800b55:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b59:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b5c:	84 db                	test   %bl,%bl
  800b5e:	75 ef                	jne    800b4f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b60:	5b                   	pop    %ebx
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	53                   	push   %ebx
  800b67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b6a:	53                   	push   %ebx
  800b6b:	e8 9c ff ff ff       	call   800b0c <strlen>
  800b70:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b73:	ff 75 0c             	pushl  0xc(%ebp)
  800b76:	01 d8                	add    %ebx,%eax
  800b78:	50                   	push   %eax
  800b79:	e8 c5 ff ff ff       	call   800b43 <strcpy>
	return dst;
}
  800b7e:	89 d8                	mov    %ebx,%eax
  800b80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b83:	c9                   	leave  
  800b84:	c3                   	ret    

00800b85 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	56                   	push   %esi
  800b89:	53                   	push   %ebx
  800b8a:	8b 75 08             	mov    0x8(%ebp),%esi
  800b8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b90:	89 f3                	mov    %esi,%ebx
  800b92:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b95:	89 f2                	mov    %esi,%edx
  800b97:	eb 0f                	jmp    800ba8 <strncpy+0x23>
		*dst++ = *src;
  800b99:	83 c2 01             	add    $0x1,%edx
  800b9c:	0f b6 01             	movzbl (%ecx),%eax
  800b9f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ba2:	80 39 01             	cmpb   $0x1,(%ecx)
  800ba5:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800ba8:	39 da                	cmp    %ebx,%edx
  800baa:	75 ed                	jne    800b99 <strncpy+0x14>
	}
	return ret;
}
  800bac:	89 f0                	mov    %esi,%eax
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	8b 75 08             	mov    0x8(%ebp),%esi
  800bba:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bbd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800bc0:	89 f0                	mov    %esi,%eax
  800bc2:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bc6:	85 c9                	test   %ecx,%ecx
  800bc8:	75 0b                	jne    800bd5 <strlcpy+0x23>
  800bca:	eb 17                	jmp    800be3 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bcc:	83 c2 01             	add    $0x1,%edx
  800bcf:	83 c0 01             	add    $0x1,%eax
  800bd2:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800bd5:	39 d8                	cmp    %ebx,%eax
  800bd7:	74 07                	je     800be0 <strlcpy+0x2e>
  800bd9:	0f b6 0a             	movzbl (%edx),%ecx
  800bdc:	84 c9                	test   %cl,%cl
  800bde:	75 ec                	jne    800bcc <strlcpy+0x1a>
		*dst = '\0';
  800be0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800be3:	29 f0                	sub    %esi,%eax
}
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bef:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bf2:	eb 06                	jmp    800bfa <strcmp+0x11>
		p++, q++;
  800bf4:	83 c1 01             	add    $0x1,%ecx
  800bf7:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800bfa:	0f b6 01             	movzbl (%ecx),%eax
  800bfd:	84 c0                	test   %al,%al
  800bff:	74 04                	je     800c05 <strcmp+0x1c>
  800c01:	3a 02                	cmp    (%edx),%al
  800c03:	74 ef                	je     800bf4 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c05:	0f b6 c0             	movzbl %al,%eax
  800c08:	0f b6 12             	movzbl (%edx),%edx
  800c0b:	29 d0                	sub    %edx,%eax
}
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	53                   	push   %ebx
  800c13:	8b 45 08             	mov    0x8(%ebp),%eax
  800c16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c19:	89 c3                	mov    %eax,%ebx
  800c1b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c1e:	eb 06                	jmp    800c26 <strncmp+0x17>
		n--, p++, q++;
  800c20:	83 c0 01             	add    $0x1,%eax
  800c23:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c26:	39 d8                	cmp    %ebx,%eax
  800c28:	74 16                	je     800c40 <strncmp+0x31>
  800c2a:	0f b6 08             	movzbl (%eax),%ecx
  800c2d:	84 c9                	test   %cl,%cl
  800c2f:	74 04                	je     800c35 <strncmp+0x26>
  800c31:	3a 0a                	cmp    (%edx),%cl
  800c33:	74 eb                	je     800c20 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c35:	0f b6 00             	movzbl (%eax),%eax
  800c38:	0f b6 12             	movzbl (%edx),%edx
  800c3b:	29 d0                	sub    %edx,%eax
}
  800c3d:	5b                   	pop    %ebx
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    
		return 0;
  800c40:	b8 00 00 00 00       	mov    $0x0,%eax
  800c45:	eb f6                	jmp    800c3d <strncmp+0x2e>

00800c47 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c51:	0f b6 10             	movzbl (%eax),%edx
  800c54:	84 d2                	test   %dl,%dl
  800c56:	74 09                	je     800c61 <strchr+0x1a>
		if (*s == c)
  800c58:	38 ca                	cmp    %cl,%dl
  800c5a:	74 0a                	je     800c66 <strchr+0x1f>
	for (; *s; s++)
  800c5c:	83 c0 01             	add    $0x1,%eax
  800c5f:	eb f0                	jmp    800c51 <strchr+0xa>
			return (char *) s;
	return 0;
  800c61:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c72:	eb 03                	jmp    800c77 <strfind+0xf>
  800c74:	83 c0 01             	add    $0x1,%eax
  800c77:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c7a:	38 ca                	cmp    %cl,%dl
  800c7c:	74 04                	je     800c82 <strfind+0x1a>
  800c7e:	84 d2                	test   %dl,%dl
  800c80:	75 f2                	jne    800c74 <strfind+0xc>
			break;
	return (char *) s;
}
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c8d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c90:	85 c9                	test   %ecx,%ecx
  800c92:	74 13                	je     800ca7 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c94:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c9a:	75 05                	jne    800ca1 <memset+0x1d>
  800c9c:	f6 c1 03             	test   $0x3,%cl
  800c9f:	74 0d                	je     800cae <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ca1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca4:	fc                   	cld    
  800ca5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ca7:	89 f8                	mov    %edi,%eax
  800ca9:	5b                   	pop    %ebx
  800caa:	5e                   	pop    %esi
  800cab:	5f                   	pop    %edi
  800cac:	5d                   	pop    %ebp
  800cad:	c3                   	ret    
		c &= 0xFF;
  800cae:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cb2:	89 d3                	mov    %edx,%ebx
  800cb4:	c1 e3 08             	shl    $0x8,%ebx
  800cb7:	89 d0                	mov    %edx,%eax
  800cb9:	c1 e0 18             	shl    $0x18,%eax
  800cbc:	89 d6                	mov    %edx,%esi
  800cbe:	c1 e6 10             	shl    $0x10,%esi
  800cc1:	09 f0                	or     %esi,%eax
  800cc3:	09 c2                	or     %eax,%edx
  800cc5:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800cc7:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800cca:	89 d0                	mov    %edx,%eax
  800ccc:	fc                   	cld    
  800ccd:	f3 ab                	rep stos %eax,%es:(%edi)
  800ccf:	eb d6                	jmp    800ca7 <memset+0x23>

00800cd1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cdc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cdf:	39 c6                	cmp    %eax,%esi
  800ce1:	73 35                	jae    800d18 <memmove+0x47>
  800ce3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ce6:	39 c2                	cmp    %eax,%edx
  800ce8:	76 2e                	jbe    800d18 <memmove+0x47>
		s += n;
		d += n;
  800cea:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ced:	89 d6                	mov    %edx,%esi
  800cef:	09 fe                	or     %edi,%esi
  800cf1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cf7:	74 0c                	je     800d05 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cf9:	83 ef 01             	sub    $0x1,%edi
  800cfc:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800cff:	fd                   	std    
  800d00:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d02:	fc                   	cld    
  800d03:	eb 21                	jmp    800d26 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d05:	f6 c1 03             	test   $0x3,%cl
  800d08:	75 ef                	jne    800cf9 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d0a:	83 ef 04             	sub    $0x4,%edi
  800d0d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d10:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d13:	fd                   	std    
  800d14:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d16:	eb ea                	jmp    800d02 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d18:	89 f2                	mov    %esi,%edx
  800d1a:	09 c2                	or     %eax,%edx
  800d1c:	f6 c2 03             	test   $0x3,%dl
  800d1f:	74 09                	je     800d2a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d21:	89 c7                	mov    %eax,%edi
  800d23:	fc                   	cld    
  800d24:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d2a:	f6 c1 03             	test   $0x3,%cl
  800d2d:	75 f2                	jne    800d21 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d2f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d32:	89 c7                	mov    %eax,%edi
  800d34:	fc                   	cld    
  800d35:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d37:	eb ed                	jmp    800d26 <memmove+0x55>

00800d39 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d3c:	ff 75 10             	pushl  0x10(%ebp)
  800d3f:	ff 75 0c             	pushl  0xc(%ebp)
  800d42:	ff 75 08             	pushl  0x8(%ebp)
  800d45:	e8 87 ff ff ff       	call   800cd1 <memmove>
}
  800d4a:	c9                   	leave  
  800d4b:	c3                   	ret    

00800d4c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
  800d51:	8b 45 08             	mov    0x8(%ebp),%eax
  800d54:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d57:	89 c6                	mov    %eax,%esi
  800d59:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d5c:	39 f0                	cmp    %esi,%eax
  800d5e:	74 1c                	je     800d7c <memcmp+0x30>
		if (*s1 != *s2)
  800d60:	0f b6 08             	movzbl (%eax),%ecx
  800d63:	0f b6 1a             	movzbl (%edx),%ebx
  800d66:	38 d9                	cmp    %bl,%cl
  800d68:	75 08                	jne    800d72 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800d6a:	83 c0 01             	add    $0x1,%eax
  800d6d:	83 c2 01             	add    $0x1,%edx
  800d70:	eb ea                	jmp    800d5c <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800d72:	0f b6 c1             	movzbl %cl,%eax
  800d75:	0f b6 db             	movzbl %bl,%ebx
  800d78:	29 d8                	sub    %ebx,%eax
  800d7a:	eb 05                	jmp    800d81 <memcmp+0x35>
	}

	return 0;
  800d7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800d8e:	89 c2                	mov    %eax,%edx
  800d90:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d93:	39 d0                	cmp    %edx,%eax
  800d95:	73 09                	jae    800da0 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d97:	38 08                	cmp    %cl,(%eax)
  800d99:	74 05                	je     800da0 <memfind+0x1b>
	for (; s < ends; s++)
  800d9b:	83 c0 01             	add    $0x1,%eax
  800d9e:	eb f3                	jmp    800d93 <memfind+0xe>
			break;
	return (void *) s;
}
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	57                   	push   %edi
  800da6:	56                   	push   %esi
  800da7:	53                   	push   %ebx
  800da8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dae:	eb 03                	jmp    800db3 <strtol+0x11>
		s++;
  800db0:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800db3:	0f b6 01             	movzbl (%ecx),%eax
  800db6:	3c 20                	cmp    $0x20,%al
  800db8:	74 f6                	je     800db0 <strtol+0xe>
  800dba:	3c 09                	cmp    $0x9,%al
  800dbc:	74 f2                	je     800db0 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800dbe:	3c 2b                	cmp    $0x2b,%al
  800dc0:	74 2e                	je     800df0 <strtol+0x4e>
	int neg = 0;
  800dc2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800dc7:	3c 2d                	cmp    $0x2d,%al
  800dc9:	74 2f                	je     800dfa <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dcb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800dd1:	75 05                	jne    800dd8 <strtol+0x36>
  800dd3:	80 39 30             	cmpb   $0x30,(%ecx)
  800dd6:	74 2c                	je     800e04 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dd8:	85 db                	test   %ebx,%ebx
  800dda:	75 0a                	jne    800de6 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ddc:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800de1:	80 39 30             	cmpb   $0x30,(%ecx)
  800de4:	74 28                	je     800e0e <strtol+0x6c>
		base = 10;
  800de6:	b8 00 00 00 00       	mov    $0x0,%eax
  800deb:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800dee:	eb 50                	jmp    800e40 <strtol+0x9e>
		s++;
  800df0:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800df3:	bf 00 00 00 00       	mov    $0x0,%edi
  800df8:	eb d1                	jmp    800dcb <strtol+0x29>
		s++, neg = 1;
  800dfa:	83 c1 01             	add    $0x1,%ecx
  800dfd:	bf 01 00 00 00       	mov    $0x1,%edi
  800e02:	eb c7                	jmp    800dcb <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e04:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e08:	74 0e                	je     800e18 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800e0a:	85 db                	test   %ebx,%ebx
  800e0c:	75 d8                	jne    800de6 <strtol+0x44>
		s++, base = 8;
  800e0e:	83 c1 01             	add    $0x1,%ecx
  800e11:	bb 08 00 00 00       	mov    $0x8,%ebx
  800e16:	eb ce                	jmp    800de6 <strtol+0x44>
		s += 2, base = 16;
  800e18:	83 c1 02             	add    $0x2,%ecx
  800e1b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e20:	eb c4                	jmp    800de6 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800e22:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e25:	89 f3                	mov    %esi,%ebx
  800e27:	80 fb 19             	cmp    $0x19,%bl
  800e2a:	77 29                	ja     800e55 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800e2c:	0f be d2             	movsbl %dl,%edx
  800e2f:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e32:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e35:	7d 30                	jge    800e67 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800e37:	83 c1 01             	add    $0x1,%ecx
  800e3a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e3e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800e40:	0f b6 11             	movzbl (%ecx),%edx
  800e43:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e46:	89 f3                	mov    %esi,%ebx
  800e48:	80 fb 09             	cmp    $0x9,%bl
  800e4b:	77 d5                	ja     800e22 <strtol+0x80>
			dig = *s - '0';
  800e4d:	0f be d2             	movsbl %dl,%edx
  800e50:	83 ea 30             	sub    $0x30,%edx
  800e53:	eb dd                	jmp    800e32 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800e55:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e58:	89 f3                	mov    %esi,%ebx
  800e5a:	80 fb 19             	cmp    $0x19,%bl
  800e5d:	77 08                	ja     800e67 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800e5f:	0f be d2             	movsbl %dl,%edx
  800e62:	83 ea 37             	sub    $0x37,%edx
  800e65:	eb cb                	jmp    800e32 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800e67:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e6b:	74 05                	je     800e72 <strtol+0xd0>
		*endptr = (char *) s;
  800e6d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e70:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800e72:	89 c2                	mov    %eax,%edx
  800e74:	f7 da                	neg    %edx
  800e76:	85 ff                	test   %edi,%edi
  800e78:	0f 45 c2             	cmovne %edx,%eax
}
  800e7b:	5b                   	pop    %ebx
  800e7c:	5e                   	pop    %esi
  800e7d:	5f                   	pop    %edi
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

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
