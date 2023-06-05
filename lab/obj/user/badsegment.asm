
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:

const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	57                   	push   %edi
  800042:	56                   	push   %esi
  800043:	53                   	push   %ebx
  800044:	83 ec 0c             	sub    $0xc,%esp
  800047:	e8 4d 00 00 00       	call   800099 <__x86.get_pc_thunk.bx>
  80004c:	81 c3 b4 1f 00 00    	add    $0x1fb4,%ebx
  800052:	8b 75 08             	mov    0x8(%ebp),%esi
  800055:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())]; // ENVX()得到id在Env[]数组中对应的下标
  800058:	e8 f3 00 00 00       	call   800150 <sys_getenvid>
  80005d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800062:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800065:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  80006b:	c7 c2 44 20 80 00    	mov    $0x802044,%edx
  800071:	89 02                	mov    %eax,(%edx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 f6                	test   %esi,%esi
  800075:	7e 08                	jle    80007f <libmain+0x41>
		binaryname = argv[0];
  800077:	8b 07                	mov    (%edi),%eax
  800079:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80007f:	83 ec 08             	sub    $0x8,%esp
  800082:	57                   	push   %edi
  800083:	56                   	push   %esi
  800084:	e8 aa ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800089:	e8 0f 00 00 00       	call   80009d <exit>
}
  80008e:	83 c4 10             	add    $0x10,%esp
  800091:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800094:	5b                   	pop    %ebx
  800095:	5e                   	pop    %esi
  800096:	5f                   	pop    %edi
  800097:	5d                   	pop    %ebp
  800098:	c3                   	ret    

00800099 <__x86.get_pc_thunk.bx>:
  800099:	8b 1c 24             	mov    (%esp),%ebx
  80009c:	c3                   	ret    

0080009d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009d:	55                   	push   %ebp
  80009e:	89 e5                	mov    %esp,%ebp
  8000a0:	53                   	push   %ebx
  8000a1:	83 ec 10             	sub    $0x10,%esp
  8000a4:	e8 f0 ff ff ff       	call   800099 <__x86.get_pc_thunk.bx>
  8000a9:	81 c3 57 1f 00 00    	add    $0x1f57,%ebx
	sys_env_destroy(0);
  8000af:	6a 00                	push   $0x0
  8000b1:	e8 45 00 00 00       	call   8000fb <sys_env_destroy>
}
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	57                   	push   %edi
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cf:	89 c3                	mov    %eax,%ebx
  8000d1:	89 c7                	mov    %eax,%edi
  8000d3:	89 c6                	mov    %eax,%esi
  8000d5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5f                   	pop    %edi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	57                   	push   %edi
  8000e0:	56                   	push   %esi
  8000e1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ec:	89 d1                	mov    %edx,%ecx
  8000ee:	89 d3                	mov    %edx,%ebx
  8000f0:	89 d7                	mov    %edx,%edi
  8000f2:	89 d6                	mov    %edx,%esi
  8000f4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f6:	5b                   	pop    %ebx
  8000f7:	5e                   	pop    %esi
  8000f8:	5f                   	pop    %edi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	57                   	push   %edi
  8000ff:	56                   	push   %esi
  800100:	53                   	push   %ebx
  800101:	83 ec 1c             	sub    $0x1c,%esp
  800104:	e8 ac 02 00 00       	call   8003b5 <__x86.get_pc_thunk.ax>
  800109:	05 f7 1e 00 00       	add    $0x1ef7,%eax
  80010e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800111:	b9 00 00 00 00       	mov    $0x0,%ecx
  800116:	8b 55 08             	mov    0x8(%ebp),%edx
  800119:	b8 03 00 00 00       	mov    $0x3,%eax
  80011e:	89 cb                	mov    %ecx,%ebx
  800120:	89 cf                	mov    %ecx,%edi
  800122:	89 ce                	mov    %ecx,%esi
  800124:	cd 30                	int    $0x30
	if(check && ret > 0)
  800126:	85 c0                	test   %eax,%eax
  800128:	7f 08                	jg     800132 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800132:	83 ec 0c             	sub    $0xc,%esp
  800135:	50                   	push   %eax
  800136:	6a 03                	push   $0x3
  800138:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80013b:	8d 83 b6 f0 ff ff    	lea    -0xf4a(%ebx),%eax
  800141:	50                   	push   %eax
  800142:	6a 23                	push   $0x23
  800144:	8d 83 d3 f0 ff ff    	lea    -0xf2d(%ebx),%eax
  80014a:	50                   	push   %eax
  80014b:	e8 69 02 00 00       	call   8003b9 <_panic>

00800150 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	57                   	push   %edi
  800154:	56                   	push   %esi
  800155:	53                   	push   %ebx
	asm volatile("int %1\n"
  800156:	ba 00 00 00 00       	mov    $0x0,%edx
  80015b:	b8 02 00 00 00       	mov    $0x2,%eax
  800160:	89 d1                	mov    %edx,%ecx
  800162:	89 d3                	mov    %edx,%ebx
  800164:	89 d7                	mov    %edx,%edi
  800166:	89 d6                	mov    %edx,%esi
  800168:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016a:	5b                   	pop    %ebx
  80016b:	5e                   	pop    %esi
  80016c:	5f                   	pop    %edi
  80016d:	5d                   	pop    %ebp
  80016e:	c3                   	ret    

0080016f <sys_yield>:

void
sys_yield(void)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	57                   	push   %edi
  800173:	56                   	push   %esi
  800174:	53                   	push   %ebx
	asm volatile("int %1\n"
  800175:	ba 00 00 00 00       	mov    $0x0,%edx
  80017a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80017f:	89 d1                	mov    %edx,%ecx
  800181:	89 d3                	mov    %edx,%ebx
  800183:	89 d7                	mov    %edx,%edi
  800185:	89 d6                	mov    %edx,%esi
  800187:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800189:	5b                   	pop    %ebx
  80018a:	5e                   	pop    %esi
  80018b:	5f                   	pop    %edi
  80018c:	5d                   	pop    %ebp
  80018d:	c3                   	ret    

0080018e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	57                   	push   %edi
  800192:	56                   	push   %esi
  800193:	53                   	push   %ebx
  800194:	83 ec 1c             	sub    $0x1c,%esp
  800197:	e8 19 02 00 00       	call   8003b5 <__x86.get_pc_thunk.ax>
  80019c:	05 64 1e 00 00       	add    $0x1e64,%eax
  8001a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8001a4:	be 00 00 00 00       	mov    $0x0,%esi
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001af:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b7:	89 f7                	mov    %esi,%edi
  8001b9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001bb:	85 c0                	test   %eax,%eax
  8001bd:	7f 08                	jg     8001c7 <sys_page_alloc+0x39>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c2:	5b                   	pop    %ebx
  8001c3:	5e                   	pop    %esi
  8001c4:	5f                   	pop    %edi
  8001c5:	5d                   	pop    %ebp
  8001c6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	6a 04                	push   $0x4
  8001cd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8001d0:	8d 83 b6 f0 ff ff    	lea    -0xf4a(%ebx),%eax
  8001d6:	50                   	push   %eax
  8001d7:	6a 23                	push   $0x23
  8001d9:	8d 83 d3 f0 ff ff    	lea    -0xf2d(%ebx),%eax
  8001df:	50                   	push   %eax
  8001e0:	e8 d4 01 00 00       	call   8003b9 <_panic>

008001e5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	57                   	push   %edi
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	83 ec 1c             	sub    $0x1c,%esp
  8001ee:	e8 c2 01 00 00       	call   8003b5 <__x86.get_pc_thunk.ax>
  8001f3:	05 0d 1e 00 00       	add    $0x1e0d,%eax
  8001f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8001fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	b8 05 00 00 00       	mov    $0x5,%eax
  800206:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800209:	8b 7d 14             	mov    0x14(%ebp),%edi
  80020c:	8b 75 18             	mov    0x18(%ebp),%esi
  80020f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800211:	85 c0                	test   %eax,%eax
  800213:	7f 08                	jg     80021d <sys_page_map+0x38>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80021d:	83 ec 0c             	sub    $0xc,%esp
  800220:	50                   	push   %eax
  800221:	6a 05                	push   $0x5
  800223:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800226:	8d 83 b6 f0 ff ff    	lea    -0xf4a(%ebx),%eax
  80022c:	50                   	push   %eax
  80022d:	6a 23                	push   $0x23
  80022f:	8d 83 d3 f0 ff ff    	lea    -0xf2d(%ebx),%eax
  800235:	50                   	push   %eax
  800236:	e8 7e 01 00 00       	call   8003b9 <_panic>

0080023b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	57                   	push   %edi
  80023f:	56                   	push   %esi
  800240:	53                   	push   %ebx
  800241:	83 ec 1c             	sub    $0x1c,%esp
  800244:	e8 6c 01 00 00       	call   8003b5 <__x86.get_pc_thunk.ax>
  800249:	05 b7 1d 00 00       	add    $0x1db7,%eax
  80024e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	8b 55 08             	mov    0x8(%ebp),%edx
  800259:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025c:	b8 06 00 00 00       	mov    $0x6,%eax
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7f 08                	jg     800273 <sys_page_unmap+0x38>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	50                   	push   %eax
  800277:	6a 06                	push   $0x6
  800279:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80027c:	8d 83 b6 f0 ff ff    	lea    -0xf4a(%ebx),%eax
  800282:	50                   	push   %eax
  800283:	6a 23                	push   $0x23
  800285:	8d 83 d3 f0 ff ff    	lea    -0xf2d(%ebx),%eax
  80028b:	50                   	push   %eax
  80028c:	e8 28 01 00 00       	call   8003b9 <_panic>

00800291 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	57                   	push   %edi
  800295:	56                   	push   %esi
  800296:	53                   	push   %ebx
  800297:	83 ec 1c             	sub    $0x1c,%esp
  80029a:	e8 16 01 00 00       	call   8003b5 <__x86.get_pc_thunk.ax>
  80029f:	05 61 1d 00 00       	add    $0x1d61,%eax
  8002a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8002a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8002af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b2:	b8 08 00 00 00       	mov    $0x8,%eax
  8002b7:	89 df                	mov    %ebx,%edi
  8002b9:	89 de                	mov    %ebx,%esi
  8002bb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002bd:	85 c0                	test   %eax,%eax
  8002bf:	7f 08                	jg     8002c9 <sys_env_set_status+0x38>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c4:	5b                   	pop    %ebx
  8002c5:	5e                   	pop    %esi
  8002c6:	5f                   	pop    %edi
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c9:	83 ec 0c             	sub    $0xc,%esp
  8002cc:	50                   	push   %eax
  8002cd:	6a 08                	push   $0x8
  8002cf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002d2:	8d 83 b6 f0 ff ff    	lea    -0xf4a(%ebx),%eax
  8002d8:	50                   	push   %eax
  8002d9:	6a 23                	push   $0x23
  8002db:	8d 83 d3 f0 ff ff    	lea    -0xf2d(%ebx),%eax
  8002e1:	50                   	push   %eax
  8002e2:	e8 d2 00 00 00       	call   8003b9 <_panic>

008002e7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
  8002ed:	83 ec 1c             	sub    $0x1c,%esp
  8002f0:	e8 c0 00 00 00       	call   8003b5 <__x86.get_pc_thunk.ax>
  8002f5:	05 0b 1d 00 00       	add    $0x1d0b,%eax
  8002fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8002fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800302:	8b 55 08             	mov    0x8(%ebp),%edx
  800305:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800308:	b8 09 00 00 00       	mov    $0x9,%eax
  80030d:	89 df                	mov    %ebx,%edi
  80030f:	89 de                	mov    %ebx,%esi
  800311:	cd 30                	int    $0x30
	if(check && ret > 0)
  800313:	85 c0                	test   %eax,%eax
  800315:	7f 08                	jg     80031f <sys_env_set_pgfault_upcall+0x38>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800317:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80031a:	5b                   	pop    %ebx
  80031b:	5e                   	pop    %esi
  80031c:	5f                   	pop    %edi
  80031d:	5d                   	pop    %ebp
  80031e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80031f:	83 ec 0c             	sub    $0xc,%esp
  800322:	50                   	push   %eax
  800323:	6a 09                	push   $0x9
  800325:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800328:	8d 83 b6 f0 ff ff    	lea    -0xf4a(%ebx),%eax
  80032e:	50                   	push   %eax
  80032f:	6a 23                	push   $0x23
  800331:	8d 83 d3 f0 ff ff    	lea    -0xf2d(%ebx),%eax
  800337:	50                   	push   %eax
  800338:	e8 7c 00 00 00       	call   8003b9 <_panic>

0080033d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	57                   	push   %edi
  800341:	56                   	push   %esi
  800342:	53                   	push   %ebx
	asm volatile("int %1\n"
  800343:	8b 55 08             	mov    0x8(%ebp),%edx
  800346:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800349:	b8 0b 00 00 00       	mov    $0xb,%eax
  80034e:	be 00 00 00 00       	mov    $0x0,%esi
  800353:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800356:	8b 7d 14             	mov    0x14(%ebp),%edi
  800359:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80035b:	5b                   	pop    %ebx
  80035c:	5e                   	pop    %esi
  80035d:	5f                   	pop    %edi
  80035e:	5d                   	pop    %ebp
  80035f:	c3                   	ret    

00800360 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	57                   	push   %edi
  800364:	56                   	push   %esi
  800365:	53                   	push   %ebx
  800366:	83 ec 1c             	sub    $0x1c,%esp
  800369:	e8 47 00 00 00       	call   8003b5 <__x86.get_pc_thunk.ax>
  80036e:	05 92 1c 00 00       	add    $0x1c92,%eax
  800373:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800376:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037b:	8b 55 08             	mov    0x8(%ebp),%edx
  80037e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800383:	89 cb                	mov    %ecx,%ebx
  800385:	89 cf                	mov    %ecx,%edi
  800387:	89 ce                	mov    %ecx,%esi
  800389:	cd 30                	int    $0x30
	if(check && ret > 0)
  80038b:	85 c0                	test   %eax,%eax
  80038d:	7f 08                	jg     800397 <sys_ipc_recv+0x37>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80038f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800392:	5b                   	pop    %ebx
  800393:	5e                   	pop    %esi
  800394:	5f                   	pop    %edi
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800397:	83 ec 0c             	sub    $0xc,%esp
  80039a:	50                   	push   %eax
  80039b:	6a 0c                	push   $0xc
  80039d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8003a0:	8d 83 b6 f0 ff ff    	lea    -0xf4a(%ebx),%eax
  8003a6:	50                   	push   %eax
  8003a7:	6a 23                	push   $0x23
  8003a9:	8d 83 d3 f0 ff ff    	lea    -0xf2d(%ebx),%eax
  8003af:	50                   	push   %eax
  8003b0:	e8 04 00 00 00       	call   8003b9 <_panic>

008003b5 <__x86.get_pc_thunk.ax>:
  8003b5:	8b 04 24             	mov    (%esp),%eax
  8003b8:	c3                   	ret    

008003b9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	57                   	push   %edi
  8003bd:	56                   	push   %esi
  8003be:	53                   	push   %ebx
  8003bf:	83 ec 0c             	sub    $0xc,%esp
  8003c2:	e8 d2 fc ff ff       	call   800099 <__x86.get_pc_thunk.bx>
  8003c7:	81 c3 39 1c 00 00    	add    $0x1c39,%ebx
	va_list ap;

	va_start(ap, fmt);
  8003cd:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003d0:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  8003d6:	8b 38                	mov    (%eax),%edi
  8003d8:	e8 73 fd ff ff       	call   800150 <sys_getenvid>
  8003dd:	83 ec 0c             	sub    $0xc,%esp
  8003e0:	ff 75 0c             	pushl  0xc(%ebp)
  8003e3:	ff 75 08             	pushl  0x8(%ebp)
  8003e6:	57                   	push   %edi
  8003e7:	50                   	push   %eax
  8003e8:	8d 83 e4 f0 ff ff    	lea    -0xf1c(%ebx),%eax
  8003ee:	50                   	push   %eax
  8003ef:	e8 d1 00 00 00       	call   8004c5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003f4:	83 c4 18             	add    $0x18,%esp
  8003f7:	56                   	push   %esi
  8003f8:	ff 75 10             	pushl  0x10(%ebp)
  8003fb:	e8 63 00 00 00       	call   800463 <vcprintf>
	cprintf("\n");
  800400:	8d 83 08 f1 ff ff    	lea    -0xef8(%ebx),%eax
  800406:	89 04 24             	mov    %eax,(%esp)
  800409:	e8 b7 00 00 00       	call   8004c5 <cprintf>
  80040e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800411:	cc                   	int3   
  800412:	eb fd                	jmp    800411 <_panic+0x58>

00800414 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800414:	55                   	push   %ebp
  800415:	89 e5                	mov    %esp,%ebp
  800417:	56                   	push   %esi
  800418:	53                   	push   %ebx
  800419:	e8 7b fc ff ff       	call   800099 <__x86.get_pc_thunk.bx>
  80041e:	81 c3 e2 1b 00 00    	add    $0x1be2,%ebx
  800424:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  800427:	8b 16                	mov    (%esi),%edx
  800429:	8d 42 01             	lea    0x1(%edx),%eax
  80042c:	89 06                	mov    %eax,(%esi)
  80042e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800431:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800435:	3d ff 00 00 00       	cmp    $0xff,%eax
  80043a:	74 0b                	je     800447 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80043c:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800440:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800443:	5b                   	pop    %ebx
  800444:	5e                   	pop    %esi
  800445:	5d                   	pop    %ebp
  800446:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800447:	83 ec 08             	sub    $0x8,%esp
  80044a:	68 ff 00 00 00       	push   $0xff
  80044f:	8d 46 08             	lea    0x8(%esi),%eax
  800452:	50                   	push   %eax
  800453:	e8 66 fc ff ff       	call   8000be <sys_cputs>
		b->idx = 0;
  800458:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80045e:	83 c4 10             	add    $0x10,%esp
  800461:	eb d9                	jmp    80043c <putch+0x28>

00800463 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800463:	55                   	push   %ebp
  800464:	89 e5                	mov    %esp,%ebp
  800466:	53                   	push   %ebx
  800467:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80046d:	e8 27 fc ff ff       	call   800099 <__x86.get_pc_thunk.bx>
  800472:	81 c3 8e 1b 00 00    	add    $0x1b8e,%ebx
	struct printbuf b;

	b.idx = 0;
  800478:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80047f:	00 00 00 
	b.cnt = 0;
  800482:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800489:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80048c:	ff 75 0c             	pushl  0xc(%ebp)
  80048f:	ff 75 08             	pushl  0x8(%ebp)
  800492:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800498:	50                   	push   %eax
  800499:	8d 83 14 e4 ff ff    	lea    -0x1bec(%ebx),%eax
  80049f:	50                   	push   %eax
  8004a0:	e8 38 01 00 00       	call   8005dd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004a5:	83 c4 08             	add    $0x8,%esp
  8004a8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004ae:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004b4:	50                   	push   %eax
  8004b5:	e8 04 fc ff ff       	call   8000be <sys_cputs>

	return b.cnt;
}
  8004ba:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004c3:	c9                   	leave  
  8004c4:	c3                   	ret    

008004c5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004c5:	55                   	push   %ebp
  8004c6:	89 e5                	mov    %esp,%ebp
  8004c8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004cb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004ce:	50                   	push   %eax
  8004cf:	ff 75 08             	pushl  0x8(%ebp)
  8004d2:	e8 8c ff ff ff       	call   800463 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004d7:	c9                   	leave  
  8004d8:	c3                   	ret    

008004d9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void *), void *putdat,
		 unsigned long long num, unsigned base, int width, int padc)
{
  8004d9:	55                   	push   %ebp
  8004da:	89 e5                	mov    %esp,%ebp
  8004dc:	57                   	push   %edi
  8004dd:	56                   	push   %esi
  8004de:	53                   	push   %ebx
  8004df:	83 ec 2c             	sub    $0x2c,%esp
  8004e2:	e8 02 06 00 00       	call   800ae9 <__x86.get_pc_thunk.cx>
  8004e7:	81 c1 19 1b 00 00    	add    $0x1b19,%ecx
  8004ed:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8004f0:	89 c7                	mov    %eax,%edi
  8004f2:	89 d6                	mov    %edx,%esi
  8004f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004fd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base)
  800500:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800503:	bb 00 00 00 00       	mov    $0x0,%ebx
  800508:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80050b:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  80050e:	39 d3                	cmp    %edx,%ebx
  800510:	72 09                	jb     80051b <printnum+0x42>
  800512:	39 45 10             	cmp    %eax,0x10(%ebp)
  800515:	0f 87 83 00 00 00    	ja     80059e <printnum+0xc5>
	{
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80051b:	83 ec 0c             	sub    $0xc,%esp
  80051e:	ff 75 18             	pushl  0x18(%ebp)
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800527:	53                   	push   %ebx
  800528:	ff 75 10             	pushl  0x10(%ebp)
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	ff 75 dc             	pushl  -0x24(%ebp)
  800531:	ff 75 d8             	pushl  -0x28(%ebp)
  800534:	ff 75 d4             	pushl  -0x2c(%ebp)
  800537:	ff 75 d0             	pushl  -0x30(%ebp)
  80053a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80053d:	e8 2e 09 00 00       	call   800e70 <__udivdi3>
  800542:	83 c4 18             	add    $0x18,%esp
  800545:	52                   	push   %edx
  800546:	50                   	push   %eax
  800547:	89 f2                	mov    %esi,%edx
  800549:	89 f8                	mov    %edi,%eax
  80054b:	e8 89 ff ff ff       	call   8004d9 <printnum>
  800550:	83 c4 20             	add    $0x20,%esp
  800553:	eb 13                	jmp    800568 <printnum+0x8f>
	}
	else
	{
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	56                   	push   %esi
  800559:	ff 75 18             	pushl  0x18(%ebp)
  80055c:	ff d7                	call   *%edi
  80055e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800561:	83 eb 01             	sub    $0x1,%ebx
  800564:	85 db                	test   %ebx,%ebx
  800566:	7f ed                	jg     800555 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800568:	83 ec 08             	sub    $0x8,%esp
  80056b:	56                   	push   %esi
  80056c:	83 ec 04             	sub    $0x4,%esp
  80056f:	ff 75 dc             	pushl  -0x24(%ebp)
  800572:	ff 75 d8             	pushl  -0x28(%ebp)
  800575:	ff 75 d4             	pushl  -0x2c(%ebp)
  800578:	ff 75 d0             	pushl  -0x30(%ebp)
  80057b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80057e:	89 f3                	mov    %esi,%ebx
  800580:	e8 0b 0a 00 00       	call   800f90 <__umoddi3>
  800585:	83 c4 14             	add    $0x14,%esp
  800588:	0f be 84 06 0a f1 ff 	movsbl -0xef6(%esi,%eax,1),%eax
  80058f:	ff 
  800590:	50                   	push   %eax
  800591:	ff d7                	call   *%edi
}
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800599:	5b                   	pop    %ebx
  80059a:	5e                   	pop    %esi
  80059b:	5f                   	pop    %edi
  80059c:	5d                   	pop    %ebp
  80059d:	c3                   	ret    
  80059e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005a1:	eb be                	jmp    800561 <printnum+0x88>

008005a3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005a3:	55                   	push   %ebp
  8005a4:	89 e5                	mov    %esp,%ebp
  8005a6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005a9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005ad:	8b 10                	mov    (%eax),%edx
  8005af:	3b 50 04             	cmp    0x4(%eax),%edx
  8005b2:	73 0a                	jae    8005be <sprintputch+0x1b>
		*b->buf++ = ch;
  8005b4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005b7:	89 08                	mov    %ecx,(%eax)
  8005b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005bc:	88 02                	mov    %al,(%edx)
}
  8005be:	5d                   	pop    %ebp
  8005bf:	c3                   	ret    

008005c0 <printfmt>:
{
  8005c0:	55                   	push   %ebp
  8005c1:	89 e5                	mov    %esp,%ebp
  8005c3:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8005c6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005c9:	50                   	push   %eax
  8005ca:	ff 75 10             	pushl  0x10(%ebp)
  8005cd:	ff 75 0c             	pushl  0xc(%ebp)
  8005d0:	ff 75 08             	pushl  0x8(%ebp)
  8005d3:	e8 05 00 00 00       	call   8005dd <vprintfmt>
}
  8005d8:	83 c4 10             	add    $0x10,%esp
  8005db:	c9                   	leave  
  8005dc:	c3                   	ret    

008005dd <vprintfmt>:
{
  8005dd:	55                   	push   %ebp
  8005de:	89 e5                	mov    %esp,%ebp
  8005e0:	57                   	push   %edi
  8005e1:	56                   	push   %esi
  8005e2:	53                   	push   %ebx
  8005e3:	83 ec 2c             	sub    $0x2c,%esp
  8005e6:	e8 ae fa ff ff       	call   800099 <__x86.get_pc_thunk.bx>
  8005eb:	81 c3 15 1a 00 00    	add    $0x1a15,%ebx
  8005f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005f4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005f7:	e9 c3 03 00 00       	jmp    8009bf <.L35+0x48>
		padc = ' ';
  8005fc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800600:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800607:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  80060e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800615:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  80061d:	8d 47 01             	lea    0x1(%edi),%eax
  800620:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800623:	0f b6 17             	movzbl (%edi),%edx
  800626:	8d 42 dd             	lea    -0x23(%edx),%eax
  800629:	3c 55                	cmp    $0x55,%al
  80062b:	0f 87 16 04 00 00    	ja     800a47 <.L22>
  800631:	0f b6 c0             	movzbl %al,%eax
  800634:	89 d9                	mov    %ebx,%ecx
  800636:	03 8c 83 c4 f1 ff ff 	add    -0xe3c(%ebx,%eax,4),%ecx
  80063d:	ff e1                	jmp    *%ecx

0080063f <.L69>:
  80063f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800642:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800646:	eb d5                	jmp    80061d <vprintfmt+0x40>

00800648 <.L28>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800648:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80064b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80064f:	eb cc                	jmp    80061d <vprintfmt+0x40>

00800651 <.L29>:
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800651:	0f b6 d2             	movzbl %dl,%edx
  800654:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0;; ++fmt)
  800657:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
  80065c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80065f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800663:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800666:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800669:	83 f9 09             	cmp    $0x9,%ecx
  80066c:	77 55                	ja     8006c3 <.L23+0xf>
			for (precision = 0;; ++fmt)
  80066e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800671:	eb e9                	jmp    80065c <.L29+0xb>

00800673 <.L26>:
			precision = va_arg(ap, int);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8b 00                	mov    (%eax),%eax
  800678:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8d 40 04             	lea    0x4(%eax),%eax
  800681:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  800684:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800687:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80068b:	79 90                	jns    80061d <vprintfmt+0x40>
				width = precision, precision = -1;
  80068d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800690:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800693:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80069a:	eb 81                	jmp    80061d <vprintfmt+0x40>

0080069c <.L27>:
  80069c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80069f:	85 c0                	test   %eax,%eax
  8006a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a6:	0f 49 d0             	cmovns %eax,%edx
  8006a9:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006af:	e9 69 ff ff ff       	jmp    80061d <vprintfmt+0x40>

008006b4 <.L23>:
  8006b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8006b7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006be:	e9 5a ff ff ff       	jmp    80061d <vprintfmt+0x40>
  8006c3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006c6:	eb bf                	jmp    800687 <.L26+0x14>

008006c8 <.L33>:
			lflag++;
  8006c8:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *)fmt++) // 遇到%后，根据后面跟的字符控制输出格式
  8006cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8006cf:	e9 49 ff ff ff       	jmp    80061d <vprintfmt+0x40>

008006d4 <.L30>:
			putch(va_arg(ap, int), putdat);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8d 78 04             	lea    0x4(%eax),%edi
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	56                   	push   %esi
  8006de:	ff 30                	pushl  (%eax)
  8006e0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8006e3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8006e6:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8006e9:	e9 ce 02 00 00       	jmp    8009bc <.L35+0x45>

008006ee <.L32>:
			err = va_arg(ap, int);
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8d 78 04             	lea    0x4(%eax),%edi
  8006f4:	8b 00                	mov    (%eax),%eax
  8006f6:	99                   	cltd   
  8006f7:	31 d0                	xor    %edx,%eax
  8006f9:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006fb:	83 f8 08             	cmp    $0x8,%eax
  8006fe:	7f 27                	jg     800727 <.L32+0x39>
  800700:	8b 94 83 20 00 00 00 	mov    0x20(%ebx,%eax,4),%edx
  800707:	85 d2                	test   %edx,%edx
  800709:	74 1c                	je     800727 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
  80070b:	52                   	push   %edx
  80070c:	8d 83 2b f1 ff ff    	lea    -0xed5(%ebx),%eax
  800712:	50                   	push   %eax
  800713:	56                   	push   %esi
  800714:	ff 75 08             	pushl  0x8(%ebp)
  800717:	e8 a4 fe ff ff       	call   8005c0 <printfmt>
  80071c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80071f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800722:	e9 95 02 00 00       	jmp    8009bc <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
  800727:	50                   	push   %eax
  800728:	8d 83 22 f1 ff ff    	lea    -0xede(%ebx),%eax
  80072e:	50                   	push   %eax
  80072f:	56                   	push   %esi
  800730:	ff 75 08             	pushl  0x8(%ebp)
  800733:	e8 88 fe ff ff       	call   8005c0 <printfmt>
  800738:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80073b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80073e:	e9 79 02 00 00       	jmp    8009bc <.L35+0x45>

00800743 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800743:	8b 45 14             	mov    0x14(%ebp),%eax
  800746:	83 c0 04             	add    $0x4,%eax
  800749:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80074c:	8b 45 14             	mov    0x14(%ebp),%eax
  80074f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800751:	85 ff                	test   %edi,%edi
  800753:	8d 83 1b f1 ff ff    	lea    -0xee5(%ebx),%eax
  800759:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80075c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800760:	0f 8e b5 00 00 00    	jle    80081b <.L36+0xd8>
  800766:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80076a:	75 08                	jne    800774 <.L36+0x31>
  80076c:	89 75 0c             	mov    %esi,0xc(%ebp)
  80076f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800772:	eb 6d                	jmp    8007e1 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800774:	83 ec 08             	sub    $0x8,%esp
  800777:	ff 75 cc             	pushl  -0x34(%ebp)
  80077a:	57                   	push   %edi
  80077b:	e8 85 03 00 00       	call   800b05 <strnlen>
  800780:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800783:	29 c2                	sub    %eax,%edx
  800785:	89 55 c8             	mov    %edx,-0x38(%ebp)
  800788:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80078b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80078f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800792:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800795:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800797:	eb 10                	jmp    8007a9 <.L36+0x66>
					putch(padc, putdat);
  800799:	83 ec 08             	sub    $0x8,%esp
  80079c:	56                   	push   %esi
  80079d:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a0:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8007a3:	83 ef 01             	sub    $0x1,%edi
  8007a6:	83 c4 10             	add    $0x10,%esp
  8007a9:	85 ff                	test   %edi,%edi
  8007ab:	7f ec                	jg     800799 <.L36+0x56>
  8007ad:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007b0:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8007b3:	85 d2                	test   %edx,%edx
  8007b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ba:	0f 49 c2             	cmovns %edx,%eax
  8007bd:	29 c2                	sub    %eax,%edx
  8007bf:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8007c2:	89 75 0c             	mov    %esi,0xc(%ebp)
  8007c5:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8007c8:	eb 17                	jmp    8007e1 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
  8007ca:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007ce:	75 30                	jne    800800 <.L36+0xbd>
					putch(ch, putdat);
  8007d0:	83 ec 08             	sub    $0x8,%esp
  8007d3:	ff 75 0c             	pushl  0xc(%ebp)
  8007d6:	50                   	push   %eax
  8007d7:	ff 55 08             	call   *0x8(%ebp)
  8007da:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007dd:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8007e1:	83 c7 01             	add    $0x1,%edi
  8007e4:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8007e8:	0f be c2             	movsbl %dl,%eax
  8007eb:	85 c0                	test   %eax,%eax
  8007ed:	74 52                	je     800841 <.L36+0xfe>
  8007ef:	85 f6                	test   %esi,%esi
  8007f1:	78 d7                	js     8007ca <.L36+0x87>
  8007f3:	83 ee 01             	sub    $0x1,%esi
  8007f6:	79 d2                	jns    8007ca <.L36+0x87>
  8007f8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8007fb:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8007fe:	eb 32                	jmp    800832 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
  800800:	0f be d2             	movsbl %dl,%edx
  800803:	83 ea 20             	sub    $0x20,%edx
  800806:	83 fa 5e             	cmp    $0x5e,%edx
  800809:	76 c5                	jbe    8007d0 <.L36+0x8d>
					putch('?', putdat);
  80080b:	83 ec 08             	sub    $0x8,%esp
  80080e:	ff 75 0c             	pushl  0xc(%ebp)
  800811:	6a 3f                	push   $0x3f
  800813:	ff 55 08             	call   *0x8(%ebp)
  800816:	83 c4 10             	add    $0x10,%esp
  800819:	eb c2                	jmp    8007dd <.L36+0x9a>
  80081b:	89 75 0c             	mov    %esi,0xc(%ebp)
  80081e:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800821:	eb be                	jmp    8007e1 <.L36+0x9e>
				putch(' ', putdat);
  800823:	83 ec 08             	sub    $0x8,%esp
  800826:	56                   	push   %esi
  800827:	6a 20                	push   $0x20
  800829:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  80082c:	83 ef 01             	sub    $0x1,%edi
  80082f:	83 c4 10             	add    $0x10,%esp
  800832:	85 ff                	test   %edi,%edi
  800834:	7f ed                	jg     800823 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
  800836:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800839:	89 45 14             	mov    %eax,0x14(%ebp)
  80083c:	e9 7b 01 00 00       	jmp    8009bc <.L35+0x45>
  800841:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800844:	8b 75 0c             	mov    0xc(%ebp),%esi
  800847:	eb e9                	jmp    800832 <.L36+0xef>

00800849 <.L31>:
  800849:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80084c:	83 f9 01             	cmp    $0x1,%ecx
  80084f:	7e 40                	jle    800891 <.L31+0x48>
		return va_arg(*ap, long long);
  800851:	8b 45 14             	mov    0x14(%ebp),%eax
  800854:	8b 50 04             	mov    0x4(%eax),%edx
  800857:	8b 00                	mov    (%eax),%eax
  800859:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80085c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80085f:	8b 45 14             	mov    0x14(%ebp),%eax
  800862:	8d 40 08             	lea    0x8(%eax),%eax
  800865:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long)num < 0)
  800868:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80086c:	79 55                	jns    8008c3 <.L31+0x7a>
				putch('-', putdat);
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	56                   	push   %esi
  800872:	6a 2d                	push   $0x2d
  800874:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long)num;
  800877:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80087a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80087d:	f7 da                	neg    %edx
  80087f:	83 d1 00             	adc    $0x0,%ecx
  800882:	f7 d9                	neg    %ecx
  800884:	83 c4 10             	add    $0x10,%esp
			base = 10; // base代表进制数
  800887:	b8 0a 00 00 00       	mov    $0xa,%eax
  80088c:	e9 10 01 00 00       	jmp    8009a1 <.L35+0x2a>
	else if (lflag)
  800891:	85 c9                	test   %ecx,%ecx
  800893:	75 17                	jne    8008ac <.L31+0x63>
		return va_arg(*ap, int);
  800895:	8b 45 14             	mov    0x14(%ebp),%eax
  800898:	8b 00                	mov    (%eax),%eax
  80089a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80089d:	99                   	cltd   
  80089e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a4:	8d 40 04             	lea    0x4(%eax),%eax
  8008a7:	89 45 14             	mov    %eax,0x14(%ebp)
  8008aa:	eb bc                	jmp    800868 <.L31+0x1f>
		return va_arg(*ap, long);
  8008ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8008af:	8b 00                	mov    (%eax),%eax
  8008b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b4:	99                   	cltd   
  8008b5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bb:	8d 40 04             	lea    0x4(%eax),%eax
  8008be:	89 45 14             	mov    %eax,0x14(%ebp)
  8008c1:	eb a5                	jmp    800868 <.L31+0x1f>
			num = getint(&ap, lflag); // 在lflag的控制下，从va_list获取整数
  8008c3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008c6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10; // base代表进制数
  8008c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008ce:	e9 ce 00 00 00       	jmp    8009a1 <.L35+0x2a>

008008d3 <.L37>:
  8008d3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8008d6:	83 f9 01             	cmp    $0x1,%ecx
  8008d9:	7e 18                	jle    8008f3 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
  8008db:	8b 45 14             	mov    0x14(%ebp),%eax
  8008de:	8b 10                	mov    (%eax),%edx
  8008e0:	8b 48 04             	mov    0x4(%eax),%ecx
  8008e3:	8d 40 08             	lea    0x8(%eax),%eax
  8008e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8008e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008ee:	e9 ae 00 00 00       	jmp    8009a1 <.L35+0x2a>
	else if (lflag)
  8008f3:	85 c9                	test   %ecx,%ecx
  8008f5:	75 1a                	jne    800911 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
  8008f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fa:	8b 10                	mov    (%eax),%edx
  8008fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800901:	8d 40 04             	lea    0x4(%eax),%eax
  800904:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800907:	b8 0a 00 00 00       	mov    $0xa,%eax
  80090c:	e9 90 00 00 00       	jmp    8009a1 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800911:	8b 45 14             	mov    0x14(%ebp),%eax
  800914:	8b 10                	mov    (%eax),%edx
  800916:	b9 00 00 00 00       	mov    $0x0,%ecx
  80091b:	8d 40 04             	lea    0x4(%eax),%eax
  80091e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800921:	b8 0a 00 00 00       	mov    $0xa,%eax
  800926:	eb 79                	jmp    8009a1 <.L35+0x2a>

00800928 <.L34>:
  800928:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  80092b:	83 f9 01             	cmp    $0x1,%ecx
  80092e:	7e 15                	jle    800945 <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
  800930:	8b 45 14             	mov    0x14(%ebp),%eax
  800933:	8b 10                	mov    (%eax),%edx
  800935:	8b 48 04             	mov    0x4(%eax),%ecx
  800938:	8d 40 08             	lea    0x8(%eax),%eax
  80093b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80093e:	b8 08 00 00 00       	mov    $0x8,%eax
  800943:	eb 5c                	jmp    8009a1 <.L35+0x2a>
	else if (lflag)
  800945:	85 c9                	test   %ecx,%ecx
  800947:	75 17                	jne    800960 <.L34+0x38>
		return va_arg(*ap, unsigned int);
  800949:	8b 45 14             	mov    0x14(%ebp),%eax
  80094c:	8b 10                	mov    (%eax),%edx
  80094e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800953:	8d 40 04             	lea    0x4(%eax),%eax
  800956:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800959:	b8 08 00 00 00       	mov    $0x8,%eax
  80095e:	eb 41                	jmp    8009a1 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800960:	8b 45 14             	mov    0x14(%ebp),%eax
  800963:	8b 10                	mov    (%eax),%edx
  800965:	b9 00 00 00 00       	mov    $0x0,%ecx
  80096a:	8d 40 04             	lea    0x4(%eax),%eax
  80096d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800970:	b8 08 00 00 00       	mov    $0x8,%eax
  800975:	eb 2a                	jmp    8009a1 <.L35+0x2a>

00800977 <.L35>:
			putch('0', putdat);
  800977:	83 ec 08             	sub    $0x8,%esp
  80097a:	56                   	push   %esi
  80097b:	6a 30                	push   $0x30
  80097d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800980:	83 c4 08             	add    $0x8,%esp
  800983:	56                   	push   %esi
  800984:	6a 78                	push   $0x78
  800986:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800989:	8b 45 14             	mov    0x14(%ebp),%eax
  80098c:	8b 10                	mov    (%eax),%edx
  80098e:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800993:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800996:	8d 40 04             	lea    0x4(%eax),%eax
  800999:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80099c:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc); // 以相反的顺序打印一个数字（base <= 16），使用指定的 putch 函数和关联的指针 putdat。
  8009a1:	83 ec 0c             	sub    $0xc,%esp
  8009a4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8009a8:	57                   	push   %edi
  8009a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8009ac:	50                   	push   %eax
  8009ad:	51                   	push   %ecx
  8009ae:	52                   	push   %edx
  8009af:	89 f2                	mov    %esi,%edx
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	e8 20 fb ff ff       	call   8004d9 <printnum>
			break;
  8009b9:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8009bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *)fmt++) != '%') // 没遇到%时，直接把普通字符输出到putch()函数
  8009bf:	83 c7 01             	add    $0x1,%edi
  8009c2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8009c6:	83 f8 25             	cmp    $0x25,%eax
  8009c9:	0f 84 2d fc ff ff    	je     8005fc <vprintfmt+0x1f>
			if (ch == '\0')
  8009cf:	85 c0                	test   %eax,%eax
  8009d1:	0f 84 91 00 00 00    	je     800a68 <.L22+0x21>
			putch(ch, putdat);
  8009d7:	83 ec 08             	sub    $0x8,%esp
  8009da:	56                   	push   %esi
  8009db:	50                   	push   %eax
  8009dc:	ff 55 08             	call   *0x8(%ebp)
  8009df:	83 c4 10             	add    $0x10,%esp
  8009e2:	eb db                	jmp    8009bf <.L35+0x48>

008009e4 <.L38>:
  8009e4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
  8009e7:	83 f9 01             	cmp    $0x1,%ecx
  8009ea:	7e 15                	jle    800a01 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
  8009ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ef:	8b 10                	mov    (%eax),%edx
  8009f1:	8b 48 04             	mov    0x4(%eax),%ecx
  8009f4:	8d 40 08             	lea    0x8(%eax),%eax
  8009f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009fa:	b8 10 00 00 00       	mov    $0x10,%eax
  8009ff:	eb a0                	jmp    8009a1 <.L35+0x2a>
	else if (lflag)
  800a01:	85 c9                	test   %ecx,%ecx
  800a03:	75 17                	jne    800a1c <.L38+0x38>
		return va_arg(*ap, unsigned int);
  800a05:	8b 45 14             	mov    0x14(%ebp),%eax
  800a08:	8b 10                	mov    (%eax),%edx
  800a0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a0f:	8d 40 04             	lea    0x4(%eax),%eax
  800a12:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a15:	b8 10 00 00 00       	mov    $0x10,%eax
  800a1a:	eb 85                	jmp    8009a1 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
  800a1c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a1f:	8b 10                	mov    (%eax),%edx
  800a21:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a26:	8d 40 04             	lea    0x4(%eax),%eax
  800a29:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a2c:	b8 10 00 00 00       	mov    $0x10,%eax
  800a31:	e9 6b ff ff ff       	jmp    8009a1 <.L35+0x2a>

00800a36 <.L25>:
			putch(ch, putdat);
  800a36:	83 ec 08             	sub    $0x8,%esp
  800a39:	56                   	push   %esi
  800a3a:	6a 25                	push   $0x25
  800a3c:	ff 55 08             	call   *0x8(%ebp)
			break;
  800a3f:	83 c4 10             	add    $0x10,%esp
  800a42:	e9 75 ff ff ff       	jmp    8009bc <.L35+0x45>

00800a47 <.L22>:
			putch('%', putdat);
  800a47:	83 ec 08             	sub    $0x8,%esp
  800a4a:	56                   	push   %esi
  800a4b:	6a 25                	push   $0x25
  800a4d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a50:	83 c4 10             	add    $0x10,%esp
  800a53:	89 f8                	mov    %edi,%eax
  800a55:	eb 03                	jmp    800a5a <.L22+0x13>
  800a57:	83 e8 01             	sub    $0x1,%eax
  800a5a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800a5e:	75 f7                	jne    800a57 <.L22+0x10>
  800a60:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a63:	e9 54 ff ff ff       	jmp    8009bc <.L35+0x45>
}
  800a68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a6b:	5b                   	pop    %ebx
  800a6c:	5e                   	pop    %esi
  800a6d:	5f                   	pop    %edi
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <vsnprintf>:

int vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	53                   	push   %ebx
  800a74:	83 ec 14             	sub    $0x14,%esp
  800a77:	e8 1d f6 ff ff       	call   800099 <__x86.get_pc_thunk.bx>
  800a7c:	81 c3 84 15 00 00    	add    $0x1584,%ebx
  800a82:	8b 45 08             	mov    0x8(%ebp),%eax
  800a85:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf + n - 1, 0};
  800a88:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a8b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a8f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a92:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a99:	85 c0                	test   %eax,%eax
  800a9b:	74 2b                	je     800ac8 <vsnprintf+0x58>
  800a9d:	85 d2                	test   %edx,%edx
  800a9f:	7e 27                	jle    800ac8 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void *)sprintputch, &b, fmt, ap);
  800aa1:	ff 75 14             	pushl  0x14(%ebp)
  800aa4:	ff 75 10             	pushl  0x10(%ebp)
  800aa7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800aaa:	50                   	push   %eax
  800aab:	8d 83 a3 e5 ff ff    	lea    -0x1a5d(%ebx),%eax
  800ab1:	50                   	push   %eax
  800ab2:	e8 26 fb ff ff       	call   8005dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ab7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800aba:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ac0:	83 c4 10             	add    $0x10,%esp
}
  800ac3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac6:	c9                   	leave  
  800ac7:	c3                   	ret    
		return -E_INVAL;
  800ac8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800acd:	eb f4                	jmp    800ac3 <vsnprintf+0x53>

00800acf <snprintf>:

int snprintf(char *buf, int n, const char *fmt, ...)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ad5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ad8:	50                   	push   %eax
  800ad9:	ff 75 10             	pushl  0x10(%ebp)
  800adc:	ff 75 0c             	pushl  0xc(%ebp)
  800adf:	ff 75 08             	pushl  0x8(%ebp)
  800ae2:	e8 89 ff ff ff       	call   800a70 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ae7:	c9                   	leave  
  800ae8:	c3                   	ret    

00800ae9 <__x86.get_pc_thunk.cx>:
  800ae9:	8b 0c 24             	mov    (%esp),%ecx
  800aec:	c3                   	ret    

00800aed <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800af3:	b8 00 00 00 00       	mov    $0x0,%eax
  800af8:	eb 03                	jmp    800afd <strlen+0x10>
		n++;
  800afa:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800afd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b01:	75 f7                	jne    800afa <strlen+0xd>
	return n;
}
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b13:	eb 03                	jmp    800b18 <strnlen+0x13>
		n++;
  800b15:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b18:	39 d0                	cmp    %edx,%eax
  800b1a:	74 06                	je     800b22 <strnlen+0x1d>
  800b1c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b20:	75 f3                	jne    800b15 <strnlen+0x10>
	return n;
}
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	53                   	push   %ebx
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b2e:	89 c2                	mov    %eax,%edx
  800b30:	83 c1 01             	add    $0x1,%ecx
  800b33:	83 c2 01             	add    $0x1,%edx
  800b36:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800b3a:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b3d:	84 db                	test   %bl,%bl
  800b3f:	75 ef                	jne    800b30 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800b41:	5b                   	pop    %ebx
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	53                   	push   %ebx
  800b48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b4b:	53                   	push   %ebx
  800b4c:	e8 9c ff ff ff       	call   800aed <strlen>
  800b51:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800b54:	ff 75 0c             	pushl  0xc(%ebp)
  800b57:	01 d8                	add    %ebx,%eax
  800b59:	50                   	push   %eax
  800b5a:	e8 c5 ff ff ff       	call   800b24 <strcpy>
	return dst;
}
  800b5f:	89 d8                	mov    %ebx,%eax
  800b61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b64:	c9                   	leave  
  800b65:	c3                   	ret    

00800b66 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
  800b6b:	8b 75 08             	mov    0x8(%ebp),%esi
  800b6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b71:	89 f3                	mov    %esi,%ebx
  800b73:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b76:	89 f2                	mov    %esi,%edx
  800b78:	eb 0f                	jmp    800b89 <strncpy+0x23>
		*dst++ = *src;
  800b7a:	83 c2 01             	add    $0x1,%edx
  800b7d:	0f b6 01             	movzbl (%ecx),%eax
  800b80:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b83:	80 39 01             	cmpb   $0x1,(%ecx)
  800b86:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800b89:	39 da                	cmp    %ebx,%edx
  800b8b:	75 ed                	jne    800b7a <strncpy+0x14>
	}
	return ret;
}
  800b8d:	89 f0                	mov    %esi,%eax
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
  800b98:	8b 75 08             	mov    0x8(%ebp),%esi
  800b9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ba1:	89 f0                	mov    %esi,%eax
  800ba3:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ba7:	85 c9                	test   %ecx,%ecx
  800ba9:	75 0b                	jne    800bb6 <strlcpy+0x23>
  800bab:	eb 17                	jmp    800bc4 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800bad:	83 c2 01             	add    $0x1,%edx
  800bb0:	83 c0 01             	add    $0x1,%eax
  800bb3:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800bb6:	39 d8                	cmp    %ebx,%eax
  800bb8:	74 07                	je     800bc1 <strlcpy+0x2e>
  800bba:	0f b6 0a             	movzbl (%edx),%ecx
  800bbd:	84 c9                	test   %cl,%cl
  800bbf:	75 ec                	jne    800bad <strlcpy+0x1a>
		*dst = '\0';
  800bc1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800bc4:	29 f0                	sub    %esi,%eax
}
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bd3:	eb 06                	jmp    800bdb <strcmp+0x11>
		p++, q++;
  800bd5:	83 c1 01             	add    $0x1,%ecx
  800bd8:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800bdb:	0f b6 01             	movzbl (%ecx),%eax
  800bde:	84 c0                	test   %al,%al
  800be0:	74 04                	je     800be6 <strcmp+0x1c>
  800be2:	3a 02                	cmp    (%edx),%al
  800be4:	74 ef                	je     800bd5 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800be6:	0f b6 c0             	movzbl %al,%eax
  800be9:	0f b6 12             	movzbl (%edx),%edx
  800bec:	29 d0                	sub    %edx,%eax
}
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	53                   	push   %ebx
  800bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bfa:	89 c3                	mov    %eax,%ebx
  800bfc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800bff:	eb 06                	jmp    800c07 <strncmp+0x17>
		n--, p++, q++;
  800c01:	83 c0 01             	add    $0x1,%eax
  800c04:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c07:	39 d8                	cmp    %ebx,%eax
  800c09:	74 16                	je     800c21 <strncmp+0x31>
  800c0b:	0f b6 08             	movzbl (%eax),%ecx
  800c0e:	84 c9                	test   %cl,%cl
  800c10:	74 04                	je     800c16 <strncmp+0x26>
  800c12:	3a 0a                	cmp    (%edx),%cl
  800c14:	74 eb                	je     800c01 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c16:	0f b6 00             	movzbl (%eax),%eax
  800c19:	0f b6 12             	movzbl (%edx),%edx
  800c1c:	29 d0                	sub    %edx,%eax
}
  800c1e:	5b                   	pop    %ebx
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    
		return 0;
  800c21:	b8 00 00 00 00       	mov    $0x0,%eax
  800c26:	eb f6                	jmp    800c1e <strncmp+0x2e>

00800c28 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c32:	0f b6 10             	movzbl (%eax),%edx
  800c35:	84 d2                	test   %dl,%dl
  800c37:	74 09                	je     800c42 <strchr+0x1a>
		if (*s == c)
  800c39:	38 ca                	cmp    %cl,%dl
  800c3b:	74 0a                	je     800c47 <strchr+0x1f>
	for (; *s; s++)
  800c3d:	83 c0 01             	add    $0x1,%eax
  800c40:	eb f0                	jmp    800c32 <strchr+0xa>
			return (char *) s;
	return 0;
  800c42:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c53:	eb 03                	jmp    800c58 <strfind+0xf>
  800c55:	83 c0 01             	add    $0x1,%eax
  800c58:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800c5b:	38 ca                	cmp    %cl,%dl
  800c5d:	74 04                	je     800c63 <strfind+0x1a>
  800c5f:	84 d2                	test   %dl,%dl
  800c61:	75 f2                	jne    800c55 <strfind+0xc>
			break;
	return (char *) s;
}
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c71:	85 c9                	test   %ecx,%ecx
  800c73:	74 13                	je     800c88 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c75:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c7b:	75 05                	jne    800c82 <memset+0x1d>
  800c7d:	f6 c1 03             	test   $0x3,%cl
  800c80:	74 0d                	je     800c8f <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c85:	fc                   	cld    
  800c86:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c88:	89 f8                	mov    %edi,%eax
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    
		c &= 0xFF;
  800c8f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c93:	89 d3                	mov    %edx,%ebx
  800c95:	c1 e3 08             	shl    $0x8,%ebx
  800c98:	89 d0                	mov    %edx,%eax
  800c9a:	c1 e0 18             	shl    $0x18,%eax
  800c9d:	89 d6                	mov    %edx,%esi
  800c9f:	c1 e6 10             	shl    $0x10,%esi
  800ca2:	09 f0                	or     %esi,%eax
  800ca4:	09 c2                	or     %eax,%edx
  800ca6:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ca8:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800cab:	89 d0                	mov    %edx,%eax
  800cad:	fc                   	cld    
  800cae:	f3 ab                	rep stos %eax,%es:(%edi)
  800cb0:	eb d6                	jmp    800c88 <memset+0x23>

00800cb2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	57                   	push   %edi
  800cb6:	56                   	push   %esi
  800cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cba:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cbd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800cc0:	39 c6                	cmp    %eax,%esi
  800cc2:	73 35                	jae    800cf9 <memmove+0x47>
  800cc4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cc7:	39 c2                	cmp    %eax,%edx
  800cc9:	76 2e                	jbe    800cf9 <memmove+0x47>
		s += n;
		d += n;
  800ccb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cce:	89 d6                	mov    %edx,%esi
  800cd0:	09 fe                	or     %edi,%esi
  800cd2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cd8:	74 0c                	je     800ce6 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800cda:	83 ef 01             	sub    $0x1,%edi
  800cdd:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ce0:	fd                   	std    
  800ce1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ce3:	fc                   	cld    
  800ce4:	eb 21                	jmp    800d07 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ce6:	f6 c1 03             	test   $0x3,%cl
  800ce9:	75 ef                	jne    800cda <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ceb:	83 ef 04             	sub    $0x4,%edi
  800cee:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cf1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800cf4:	fd                   	std    
  800cf5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800cf7:	eb ea                	jmp    800ce3 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cf9:	89 f2                	mov    %esi,%edx
  800cfb:	09 c2                	or     %eax,%edx
  800cfd:	f6 c2 03             	test   $0x3,%dl
  800d00:	74 09                	je     800d0b <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d02:	89 c7                	mov    %eax,%edi
  800d04:	fc                   	cld    
  800d05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d0b:	f6 c1 03             	test   $0x3,%cl
  800d0e:	75 f2                	jne    800d02 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d10:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d13:	89 c7                	mov    %eax,%edi
  800d15:	fc                   	cld    
  800d16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d18:	eb ed                	jmp    800d07 <memmove+0x55>

00800d1a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800d1d:	ff 75 10             	pushl  0x10(%ebp)
  800d20:	ff 75 0c             	pushl  0xc(%ebp)
  800d23:	ff 75 08             	pushl  0x8(%ebp)
  800d26:	e8 87 ff ff ff       	call   800cb2 <memmove>
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
  800d32:	8b 45 08             	mov    0x8(%ebp),%eax
  800d35:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d38:	89 c6                	mov    %eax,%esi
  800d3a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d3d:	39 f0                	cmp    %esi,%eax
  800d3f:	74 1c                	je     800d5d <memcmp+0x30>
		if (*s1 != *s2)
  800d41:	0f b6 08             	movzbl (%eax),%ecx
  800d44:	0f b6 1a             	movzbl (%edx),%ebx
  800d47:	38 d9                	cmp    %bl,%cl
  800d49:	75 08                	jne    800d53 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800d4b:	83 c0 01             	add    $0x1,%eax
  800d4e:	83 c2 01             	add    $0x1,%edx
  800d51:	eb ea                	jmp    800d3d <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800d53:	0f b6 c1             	movzbl %cl,%eax
  800d56:	0f b6 db             	movzbl %bl,%ebx
  800d59:	29 d8                	sub    %ebx,%eax
  800d5b:	eb 05                	jmp    800d62 <memcmp+0x35>
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
  800d74:	39 d0                	cmp    %edx,%eax
  800d76:	73 09                	jae    800d81 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d78:	38 08                	cmp    %cl,(%eax)
  800d7a:	74 05                	je     800d81 <memfind+0x1b>
	for (; s < ends; s++)
  800d7c:	83 c0 01             	add    $0x1,%eax
  800d7f:	eb f3                	jmp    800d74 <memfind+0xe>
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
  800d89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d8f:	eb 03                	jmp    800d94 <strtol+0x11>
		s++;
  800d91:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d94:	0f b6 01             	movzbl (%ecx),%eax
  800d97:	3c 20                	cmp    $0x20,%al
  800d99:	74 f6                	je     800d91 <strtol+0xe>
  800d9b:	3c 09                	cmp    $0x9,%al
  800d9d:	74 f2                	je     800d91 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800d9f:	3c 2b                	cmp    $0x2b,%al
  800da1:	74 2e                	je     800dd1 <strtol+0x4e>
	int neg = 0;
  800da3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800da8:	3c 2d                	cmp    $0x2d,%al
  800daa:	74 2f                	je     800ddb <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dac:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800db2:	75 05                	jne    800db9 <strtol+0x36>
  800db4:	80 39 30             	cmpb   $0x30,(%ecx)
  800db7:	74 2c                	je     800de5 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800db9:	85 db                	test   %ebx,%ebx
  800dbb:	75 0a                	jne    800dc7 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800dbd:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800dc2:	80 39 30             	cmpb   $0x30,(%ecx)
  800dc5:	74 28                	je     800def <strtol+0x6c>
		base = 10;
  800dc7:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcc:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800dcf:	eb 50                	jmp    800e21 <strtol+0x9e>
		s++;
  800dd1:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800dd4:	bf 00 00 00 00       	mov    $0x0,%edi
  800dd9:	eb d1                	jmp    800dac <strtol+0x29>
		s++, neg = 1;
  800ddb:	83 c1 01             	add    $0x1,%ecx
  800dde:	bf 01 00 00 00       	mov    $0x1,%edi
  800de3:	eb c7                	jmp    800dac <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800de5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800de9:	74 0e                	je     800df9 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800deb:	85 db                	test   %ebx,%ebx
  800ded:	75 d8                	jne    800dc7 <strtol+0x44>
		s++, base = 8;
  800def:	83 c1 01             	add    $0x1,%ecx
  800df2:	bb 08 00 00 00       	mov    $0x8,%ebx
  800df7:	eb ce                	jmp    800dc7 <strtol+0x44>
		s += 2, base = 16;
  800df9:	83 c1 02             	add    $0x2,%ecx
  800dfc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e01:	eb c4                	jmp    800dc7 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800e03:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e06:	89 f3                	mov    %esi,%ebx
  800e08:	80 fb 19             	cmp    $0x19,%bl
  800e0b:	77 29                	ja     800e36 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800e0d:	0f be d2             	movsbl %dl,%edx
  800e10:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e13:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e16:	7d 30                	jge    800e48 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800e18:	83 c1 01             	add    $0x1,%ecx
  800e1b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e1f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800e21:	0f b6 11             	movzbl (%ecx),%edx
  800e24:	8d 72 d0             	lea    -0x30(%edx),%esi
  800e27:	89 f3                	mov    %esi,%ebx
  800e29:	80 fb 09             	cmp    $0x9,%bl
  800e2c:	77 d5                	ja     800e03 <strtol+0x80>
			dig = *s - '0';
  800e2e:	0f be d2             	movsbl %dl,%edx
  800e31:	83 ea 30             	sub    $0x30,%edx
  800e34:	eb dd                	jmp    800e13 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800e36:	8d 72 bf             	lea    -0x41(%edx),%esi
  800e39:	89 f3                	mov    %esi,%ebx
  800e3b:	80 fb 19             	cmp    $0x19,%bl
  800e3e:	77 08                	ja     800e48 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800e40:	0f be d2             	movsbl %dl,%edx
  800e43:	83 ea 37             	sub    $0x37,%edx
  800e46:	eb cb                	jmp    800e13 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800e48:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e4c:	74 05                	je     800e53 <strtol+0xd0>
		*endptr = (char *) s;
  800e4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e51:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800e53:	89 c2                	mov    %eax,%edx
  800e55:	f7 da                	neg    %edx
  800e57:	85 ff                	test   %edi,%edi
  800e59:	0f 45 c2             	cmovne %edx,%eax
}
  800e5c:	5b                   	pop    %ebx
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    
  800e61:	66 90                	xchg   %ax,%ax
  800e63:	66 90                	xchg   %ax,%ax
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
