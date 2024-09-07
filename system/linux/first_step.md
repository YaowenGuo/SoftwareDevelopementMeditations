# 第一步

Arm64 的 Linux 内核镜像中，解压部分不再作为内核一部分（arch/arm64/boot 不再包含 compressed 目录），启动流程更加简洁直白。

vmlinux 是 linux 编译得到的内核文件，它是一个 elf 格式的**动态目标**文件。**这意味着 Linux 内核的代码都是地址无关的**。注意这里的 `地址无关`，因为它在其后的加载过程中起作用。

```shell
$ readelf -h out/arm64/vmlinux
ELF Header:
  ...
  Type:                              DYN (Shared object file)
  ...
```
其包含了内核和调试信息，用于调试定位内核问题。
```shell
$ file vmlinux
vmlinux: ELF 64-bit LSB pie executable, ARM aarch64, version 1 (SYSV), statically linked, BuildID[sha1]=a69c2ff2121b0132f0f4b94a3846c7fe0aa0ffb6, with debug_info, not stripped
```
**但是该文件并不能直接被引导启动。引导程序并不识别 ELF 文件（至少我见到的是这样）。** Linux 中的脚本使用该文件生成用于启动的文件。例如 Arm64 的 Image 生成脚本
```shell
# out/arch/arm64/boot/.Image.cmd
savedcmd_arch/arm64/boot/Image := llvm-objcopy-18  -O binary -R .note -R .note.gnu.build-id -R .comment -S vmlinux arch/arm64/boot/Image
```
可以看到 Image 是使用 objcopy 将 vmlinux 中的内容直接拷贝生成的文件。如果 使用 `readelf -h` 查看 Image 文件，会发现这是一个 `PE/COFF` 文件。

```shell
$ readelf -h out/arch/arm64/boot/Image

File: out/arch/arm64/boot/Image
Format: COFF-ARM64
```

Linux 内核会使用不同的压缩算法压缩镜像，zImage/Image.gz 是内核的一种压缩形式，它是将vmlinux文件使用 gzip 压缩算法进行压缩得到的。在 `arch/arm64/boot` 目录下也有生成对应的生成指令。

[此外还有其它镜像格式](https://www.elecfans.com/emb/202306172112776.html)

vmlinux 包含了内核执行的详细信息和调试信息，可以通过该文件的查看程序的入口地址。
```shell
$ readelf -h out/vmlinux
...
  Machine:                           AArch64
  Version:                           0x1
  Entry point address:               0xFFFF800080000000
  ...
```

如果查看 `vmlinux` 同目录下的 System.map 文件，你会发现这个地址的符号为 `_text`，或者使用 nm 查看 vmlinux 也可以找到相同的符号。
```
ffff800080000000 T _text
fff8000000000000
      0x80000000
```
以 `_` 开头的符号是 Linux 内部使用的符号，这个由链接脚本定义，在 `arch/arm64/kernel/vmlinux.lds.S` 文件中

```C
ENTRY(_text)            # 定义入口地址符号为 _text

SECTIONS
{
	. = KIMAGE_VADDR;   # 将起始地址定为 KIMAGE_VADDR

	.head.text : {
		_text = .;      # _text 符号的地址赋值为 KIMAGE_VADDR，说明该段的起始地址为入口。
		HEAD_TEXT
	}
}
```

在 `arch/arm64/include/asm/memory.h` 中定义了宏 `KIMAGE_VADDR` 其最终展开为

```
#define KIMAGE_VADDR  (-(UL(1) << ((VA_BITS_MIN) - 1))) + 0x80000000
```

`CONFIG_ARM64_VA_BITS` 在 Kconfig 中配置，可以在 `.config` 查看到配置的结果为 `52`。此时 `VA_BITS_MIN` 为 48，`UL(1)` 表示 1UL（无符号长整型），`-(UL(1) << ((VA_BITS_MIN) - 1))` 表示将 1 左移 48 位，取补码，恰好为 `0xFFFF 8000 0000 0000`。计算结果就是 vmlinux 的入口地址，分毫不差。

既然入口地址确定了为 `head.text` 段的起始地址，看下段内容 `HEAD_TEXT`，

```C
// include/asm-generic/vmlinux.lds.h
#define HEAD_TEXT  KEEP(*(.head.text)) # 表示该段内容为 .head.text，KEEP 表示不允许被删除。
// include/linux/init.h
#define __HEAD		.section	".head.text","ax" // 段被定义为 __HEAD 宏
```

`__HEAD` 正是 ARM64 的 `head.S` 段标记。

```assemble
    __HEAD                      // 定义了段 .section	".head.text"
```
## Head 的约定

[Linux 要求指定了与启动器的对接约定，](https://docs.kernel.org/arch/arm64/booting.html)。

```
u32 code0;                    /* Executable code */
u32 code1;                    /* Executable code */
u64 text_offset;              /* Image load offset, little endian */
u64 image_size;               /* Effective Image size, little endian */
u64 flags;                    /* kernel flags, little endian */
u64 res2      = 0;            /* reserved */
u64 res3      = 0;            /* reserved */
u64 res4      = 0;            /* reserved */
u32 magic     = 0x644d5241;   /* Magic number, little endian, "ARM\x64" */
u32 res5;                     /* reserved (used for PE COFF offset) */
```

对应到 ARM64 的 head.S 中的实现为：
```assemble
    /*
    * 固定格式，留给 bootloader 的起始头。
    */
    efi_signature_nop			// ELF 启动配置，如果非 ELF 则为空的
    b	primary_entry			// 跳到 primary_entry 执行。对应第二个 Executable code，当使用 EFI 启动时，被跳过
    .quad	0				    // 预留的 8 字节，对应 text_offset，由 BootLoader 负责填充。使用 QEMU 启动时发现并没有填充，为 0。
    le64sym	_kernel_size_le		// 内核镜像的有效大小,little-endian
    le64sym	_kernel_flags_le	// 内核的标识字符串 flags, little-endian
    .quad	0				    // reserved
    .quad	0				    // reserved
    .quad	0				    // reserved
    .ascii	ARM64_IMAGE_MAGIC	// 魔数 ARM64
    .long	.Lpe_header_offset	// Offset to the PE header.

    __EFI_PE_HEADER

    .section ".idmap.text","a"
```

同时，要求启动器在跳转到 Linux 之前保证:
- MMU = off: MMU 必须是关闭的。
- D-cache = off: 数据缓存是关闭状态。
- I-cache = on or off：数据缓存可以开或者关。
- x0 = physical address to the FDT blob.： x0 寄存器存放设备树的物理内存地址。

还记得前面说的，Linux 内核是 `地址无关` 的吗，b 指令就是一个地址无关指令，其跳转地址是相对地址，可以跳转到当前 PC 偏移量 ±128M 的范围，也就意味着 primary_entry 不能被放到超过 128M 的偏移位置。

该实现同时兼容了 BIOS/UIFI 引导程序启动。我们看到 `efi_signature_nop` 就是用于产生 `PE/COFF` 文件的标志符号 'MZ'：

```assemble
	.macro	efi_signature_nop
#ifdef CONFIG_EFI
.L_head:
	/*
	 * This ccmp instruction has no meaningful effect except that
	 * its opcode forms the magic "MZ" signature required by UEFI.
	 */
	ccmp	x18, #0, #0xd, pl
#else
	/*
	 * Bootloaders may inspect the opcode at the start of the kernel
	 * image to decide if the kernel is capable of booting via UEFI.
	 * So put an ordinary NOP here, not the "MZ.." pseudo-nop above.
	 */
	nop
#endif
	.endm
```

这一写法巧妙的兼容了 Linux 的启动约定和 UEFI/BIOS 对启动文件的要求。

在进入 Linux 的主程序 start_kernel 之前，ARM64 经历了如下的汇编调用:

1. primary_entry
	1. record_mmu_state 			：记录 MMU 的状态
	2. preserve_boot_args 			：参数的保存 x0 .. x3 保存到 boot_args[0~3]
	3. __pi_create_init_idmap 		：创建恒等映射
	4. init_kernel_el				：根据启动的异常级别设置内核，
	5. __cpu_setup					：为开启 MMU 做准备
	6. __primary_switch				：主要切换工作
		1. __enable_mmu				：开启 MMU 开启MMU(__enable_mmu)前，CPU访问的是物理地址，__enable_mmu之后，CPU访问的是虚拟地址。这个虚拟地址最高位为0，使用的是TTBR0，而此时TTBR0执行的页表是init_idmap_pg_dir。而reserved_pg_dir这个时候还没有填充。
		2. __pi_early_map_kernel	：尝试建立 fixmap 表
		3. __primary_switched
			1. set_cpu_boot_mode_flag：设置 __boot_cpu_mode 变量
			2. kasan_early_init		：kasan 的早期初始化
			3. finalise_el2			：
			4. start_kernel  		：跳转到 start_kernel 执行，进入 C 代码。

这部分代码主要为了才进入 Linux 主要流程 start_kernel 之前完成两项工作：

1. 开启 MMU
2. 初始化中断向量表
3. 初始化设置 CPU ？


## ARM64 初始化的入口：primary_entry

primary_entry 是各种启动方式跳转的地址，是 Arm64 Linux Kernel 启动的入口。在 primary_entry 执行过程中，有几个寄存器保存了特殊的数据，用于在其它函数中传递状态。如果要修改代码需要特别注意，不能覆盖这些数据。

| 寄存器 | 作用域  | 目的  |
| ----- | ------ | ----- |
| x19   | primary_entry() .. start_kernel() | 进入 Linux 时 MMU 是否是开启的，在 record_mmu_state 中保存。 |
| x20   | primary_entry() .. __primary_switch() | CPU 的启动模式。 |
| x21   | primary_entry() .. start_kernel() | x0 传进来的 FDT 设备树地址。 |

```assemble
SYM_CODE_START(primary_entry)
	bl	record_mmu_state			// 将 MMU 是否开启的状态保存到 X19 中，0 为没有开启，非 0 为开启了。
	bl	preserve_boot_args			// 将 X0~X3 的启动参数保存到  boot_args[0~3] 中

	adrp	x1, early_init_stack 	// 要进行 C 的函数调用了，使用一个临时的栈。
	mov	sp, x1
	mov	x29, xzr
	adrp	x0, init_idmap_pg_dir 	// 恒等映射的地址
	mov	x1, xzr
	bl	__pi_create_init_idmap		// 创建等等映射。

	cbnz	x19, 0f 				// x19 保存的是 MMU 是否开启的状态，MMU 开启了就 调到标签 0 的地方执行。
	/*
	 * MMU 未开启执行此段。应该是 Arm64 的特殊缓存方式导致需要清理下创建恒等映射时期的缓存。
	 * TODO Arm64 缓存方面的知识
	 */
	dmb     sy						// 内存屏障指令，保证后继指令正确。
	mov	x1, x0						// x0 存放了 __pi_create_init_idmap 访问的结束地址
	adrp    x0, init_idmap_pg_dir  	// init_idmap_pg_dir 作为开始地址
	adr_l	x2, dcache_inval_poc	// 获取 dcache_inval_poc 的地址 
	blr	x2							// 调用 dcache_inval_poc 清理缓存
	b	1f

	/*
	 * MMU 开启进入内核时执行此段，只清理 __idmap_text 的部分。
	 */
0:	adrp	x0, __idmap_text_start
	adr_l	x1, __idmap_text_end
	adr_l	x2, dcache_clean_poc
	blr	x2

1:	mov	x0, x19
	bl	init_kernel_el				// 根据启动的异常级别设置内核
	mov	x20, x0

	/*
	 * 设置 CPU 为 MMU 开启做好准备。然后 __primary_switch 开启 MMU 并
	 * 做最后的设置，然后开始进入的 Linux 初始化的主流程 start_kernel。
	 */
	bl	__cpu_setup					// initialise processor
	b	__primary_switch			// 开启 MMU 并做设置。然后进入 start_kernel
SYM_CODE_END(primary_entry)
```

### 记录 MMU 的状态

虽然启动协议要求 Bootloader 保证在进入 Linux 时 MMU 是关闭的，但内核并没有完全信任 Bootloader 将 MMU 关闭作为必须得，而是会检查 MMU 的状态，并设置到需要的状态。Bootloader 保证了 MMU 是关闭的，就会减少很多操作

record_mmu_state 做的操作是，根据当前异常级别来检查当前异常级别的字节序：

- 如果字节序不正确，则直接关闭 MMU 并且设置正确的字节序。返回的 MMU 状态也是关闭的。

- 字节正确就检查数据缓存是否开着，开着就返回 MMU 的状态，否则直接返回 MMU 是关闭的状态。

Arm64 上有四个异常级别，三个系统控制寄存器。 SCTLR_EL1、SCTLR_EL2、SCTLR_EL3
这里只说明用到的系统控制寄存器的标志位：

25 位表示当前异常级的字节序：0 小字段，1 大字段。
2 位表示数据缓存。这是EL0和EL1上数据高速缓存的使能位。数据访问可缓存普通内存将被缓存。1 表示开启。
0 位表示 MMU 的开关。

```assemble
	__INIT
SYM_CODE_START_LOCAL(record_mmu_state)
	mrs	x19, CurrentEL                  // 将当前异常级别读取到 x19 寄存器
	cmp	x19, #CurrentEL_EL2             // 比较当前异常级别是否为 EL2
	mrs	x19, sctlr_el1                  // 将系统控制寄存器 EL1 (sctlr_el1) 的值加载到 x19 中
	b.ne	0f                          // 如果当前异常级别不为 EL2 就不用加载 EL2 了,跳过下一行代码。
	mrs	x19, sctlr_el2                  // 加载系统控制寄存器 EL1 到 x19
0:	// 这两行检查字节序，如果 CPU 当前的字节序和内核编译的不一致，则跳到 1 设置正确的字节序。
CPU_LE( tbnz x19, #SCTLR_ELx_EE_SHIFT, 1f)// 小字段才存在，字节序为大字段跳到 1
CPU_BE( tbz	x19, #SCTLR_ELx_EE_SHIFT, 1f)// 大字段才存在，字节序为小字段跳到 1
	tst	x19, #SCTLR_ELx_C				// Z := (C == 0)
	and	x19, x19, #SCTLR_ELx_M			// isolate M bit
	csel	x19, xzr, x19, eq			// clear x19 if Z 如果 cache 是关的，不保存 MMU 的状态，清零。开启才保存 MMU 的状态。
	ret

	/*
	 * 设置正确的字节序，保证 init_kernel_el 之前的字节序访问都是正确的。
	 * 这意味着 MMU 必须关闭，否则恒等映射最终将被解析为错误的字节顺序。
	 */
1:	eor	x19, x19, #SCTLR_ELx_EE			// 更正字节序
	bic	x19, x19, #SCTLR_ELx_M			// 关闭 MMU
	b.ne	2f							// 当前异常级为 EL1 跳转到 2f
	pre_disable_mmu_workaround			// 关闭 MMU 的一些准备操作
	msr	sctlr_el2, x19					// 设置 sctlr_el2 
	b	3f
2:	pre_disable_mmu_workaround
	msr	sctlr_el1, x19
3:	isb
	mov	x19, xzr						// MMU 处于关闭状态。
	ret
SYM_CODE_END(record_mmu_state)
```

## 保存启动参数 preserve_boot_args

Linux 的 [Arm64 启动协议](https://docs.kernel.org/arch/arm64/booting.html)规定，进入 Linux 内核时，X0 寄存器存放 设备树 blob (dtb)在系统 RAM 中的物理地址。R1~R3 是 0，作为保留使用。Arm64 的C 调用协议使用 X0~X10 作为函数传参使用，在初始化设备树之前，有一些列的函数调用，因此需要将 R0~R3 寄存器中的值先保存起来。preserve_boot_args 就是用来将 X0~X3 寄存器的值保存到 boot_args[0~3] 中的。并将 MMU 的状态存放到了 mmu_enabled_at_boot

```
SYM_CODE_START_LOCAL(preserve_boot_args)
	mov	x21, x0						// start_kernel() 中 X21 保存 FDT 设备树地址，就是这里赋值的。

	adr_l	x0, boot_args			// record the contents of
	stp	x21, x1, [x0]				// x0 .. x3 at kernel entry
	stp	x2, x3, [x0, #16]			

	cbnz	x19, 0f				// skip cache invalidation if MMU is on
	dmb	sy						// needed before dc ivac with MMU off

	add	x1, x0, #0x20			// 4 x 8 bytes
	b	dcache_inval_poc		// tail call
0:	str_l   x19, mmu_enabled_at_boot, x0
	ret
SYM_CODE_END(preserve_boot_args)
```

## 恒等映射 idmap(identity mapping) 

关于映射是一个很大的话题，放到专门的[地址映射](address_map.md)中说明

## init_kernel_el

init_kernel_el 会根据当前异常级来开启异常处理，仅支持 EL1 和 EL2 异常进入。
如果是 EL1: 开启异常处理，但是没有初始化 EL1 的异常向量表。
如果是 EL2: 开启异常处理，初始化 EL2 的异常向量表。


由异常级 EL2 或 EL1 进入，配置 CPU 在选定的默认状态下以内核可以支持的最高异常级运行。如果最高是 EL2, 先配置 EL2, 再将至 EL1 配置。

由 x0 返回 EL1 或 EL2 启动 x0 分别返回 BOOT_CPU_MODE_EL1 或 BOOT_CPU_MODE_EL2，同时高 32 位包含可能得上下文标志位。这些标志位没有
存在于 __boot_cpu_mode 中。
分别对应的则返回BOOT CPU MODE EL1或BOOT CPU MODE EL2 in x0，其中前32位包含潜在的上下文标志。这些标志不存储在引导cpu模式中。
```
/*
 * Since we cannot always rely on ERET synchronizing writes to sysregs (e.g. if
 * SCTLR_ELx.EOS is clear), we place an ISB prior to ERET.
 *
 * x0: whether we are being called from the primary boot path with the MMU on
 */
SYM_FUNC_START(init_kernel_el)
	mrs	x1, CurrentEL
	cmp	x1, #CurrentEL_EL2					// 判断当前异常级是否为 EL2
	b.eq	init_el2						// 是的话，跳转到 init_el2

SYM_INNER_LABEL(init_el1, SYM_L_LOCAL)		// SYM_INNER_LABEL 用在 SYM_FUNC_START 内部，用于声明一个全局的符号。
	mov_q	x0, INIT_SCTLR_EL1_MMU_OFF
	pre_disable_mmu_workaround
	msr	sctlr_el1, x0
	isb
	mov_q	x0, INIT_PSTATE_EL1
	msr	spsr_el1, x0
	msr	elr_el1, lr
	mov	w0, #BOOT_CPU_MODE_EL1
	eret

SYM_INNER_LABEL(init_el2, SYM_L_LOCAL)
	msr	elr_el2, lr

	// clean all HYP code to the PoC if we booted at EL2 with the MMU on
	cbz	x0, 0f
	adrp	x0, __hyp_idmap_text_start
	adr_l	x1, __hyp_text_end
	adr_l	x2, dcache_clean_poc
	blr	x2

	mov_q	x0, INIT_SCTLR_EL2_MMU_OFF
	pre_disable_mmu_workaround
	msr	sctlr_el2, x0
	isb
0:
	mov_q	x0, HCR_HOST_NVHE_FLAGS

	/*
	 * Compliant CPUs advertise their VHE-onlyness with
	 * ID_AA64MMFR4_EL1.E2H0 < 0. HCR_EL2.E2H can be
	 * RES1 in that case. Publish the E2H bit early so that
	 * it can be picked up by the init_el2_state macro.
	 *
	 * Fruity CPUs seem to have HCR_EL2.E2H set to RAO/WI, but
	 * don't advertise it (they predate this relaxation).
	 */
	mrs_s	x1, SYS_ID_AA64MMFR4_EL1
	tbz	x1, #(ID_AA64MMFR4_EL1_E2H0_SHIFT + ID_AA64MMFR4_EL1_E2H0_WIDTH - 1), 1f

	orr	x0, x0, #HCR_E2H
1:
	msr	hcr_el2, x0
	isb

	init_el2_state

	/* Hypervisor stub */
	adr_l	x0, __hyp_stub_vectors
	msr	vbar_el2, x0
	isb

	mov_q	x1, INIT_SCTLR_EL1_MMU_OFF

	mrs	x0, hcr_el2
	and	x0, x0, #HCR_E2H
	cbz	x0, 2f

	/* Set a sane SCTLR_EL1, the VHE way */
	msr_s	SYS_SCTLR_EL12, x1
	mov	x2, #BOOT_CPU_FLAG_E2H
	b	3f

2:
	msr	sctlr_el1, x1
	mov	x2, xzr
3:
	__init_el2_nvhe_prepare_eret

	mov	w0, #BOOT_CPU_MODE_EL2
	orr	x0, x0, x2
	eret
SYM_FUNC_END(init_kernel_el)
```

## __cpu_setup



## __primary_switch

init_task 是系统的第一个进程，也别称为 0 号(idel)进程。也是唯一一个没有通过fork或者kernel_thread产生的进程。其由内核代码 `init/init_task`直接静态定义，在内核初始化过程中逐步初始化。

准确地讲，0号进程不能完全等同于idle进程。idle 进程由rest_init->cpu_startup_entry->do_idle()生成的，运行在内核态，顾名思义，如果cpu不需要调度跑任务就进入到idle。0号进程包含了kernel启动初期和idle任务，kernel启动初期只执行一次，当所有的初始化完成后，就蜕化为idle进程，所以大家常将idle进程叫做0号进程。

```
/*
 * The following fragment of code is executed with the MMU enabled.
 *
 *   x0 = __pa(KERNEL_START)
 */
SYM_FUNC_START_LOCAL(__primary_switched)
	adr_l	x4, init_task
	init_cpu_task x4, x5, x6

	adr_l	x8, vectors			// load VBAR_EL1 with virtual
	msr	vbar_el1, x8			// vector table address
	isb

	stp	x29, x30, [sp, #-16]!
	mov	x29, sp

	str_l	x21, __fdt_pointer, x5		// Save FDT pointer

	adrp	x4, _text			// Save the offset between
	sub	x4, x4, x0			// the kernel virtual and
	str_l	x4, kimage_voffset, x5		// physical mappings

	mov	x0, x20
	bl	set_cpu_boot_mode_flag

#if defined(CONFIG_KASAN_GENERIC) || defined(CONFIG_KASAN_SW_TAGS)
	bl	kasan_early_init
#endif
	mov	x0, x20
	bl	finalise_el2			// Prefer VHE if possible
	ldp	x29, x30, [sp], #16
	bl	start_kernel
	ASM_BUG()
SYM_FUNC_END(__primary_switched)
```

TODO：

创建恒等映射之后，为什么要让缓存失效？Arm64 缓存相关的知识。

Arm64 上的内存一致性：ARMv8体系结构实现了一个弱一致性内存模型，内存的访问次序可能和程序预期的次序不一样。

Linux 的 bootloader 对于服务器常见是的 bios/uefi 加载，对于嵌入式典型的则是 u-boot，当然也可能是 Hypervisor 和 secure monitor，或者可能只是准备最小引导环境的少量指令。