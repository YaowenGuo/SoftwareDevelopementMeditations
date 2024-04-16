# 第一步

vmlinux 是 linux 的内核文件，这是一个可执行文件，可以查看该文件的入口地址。

```shell
$ readelf -h out/arm64/vmlinux
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
    /*
    * 固定格式，留给 bootloader 的起始头。
    */
    efi_signature_nop			// ELF 启动配置，如果非 ELF 则为空的
    b	primary_entry			// 跳到 primary_entry 执行
    .quad	0				    // 镜像加载的偏移，支持地址随机化时这里不为 0. 必须以小字段存储
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

继续看主入口（）的代码

```assemble
	/*
	 * The following callee saved general purpose registers are used on the
	 * primary lowlevel boot path:
	 *
	 *  Register   Scope                      Purpose
	 *  x19        primary_entry() .. start_kernel()        whether we entered with the MMU on
	 *  x20        primary_entry() .. __primary_switch()    CPU boot mode
	 *  x21        primary_entry() .. start_kernel()        FDT pointer passed at boot in x0
	 */
SYM_CODE_START(primary_entry)
	bl	record_mmu_state
	bl	preserve_boot_args

	adrp	x1, early_init_stack
	mov	sp, x1
	mov	x29, xzr
	adrp	x0, init_idmap_pg_dir
	mov	x1, xzr
	bl	__pi_create_init_idmap

	/*
	 * If the page tables have been populated with non-cacheable
	 * accesses (MMU disabled), invalidate those tables again to
	 * remove any speculatively loaded cache lines.
	 */
	cbnz	x19, 0f
	dmb     sy
	mov	x1, x0				// end of used region
	adrp    x0, init_idmap_pg_dir
	adr_l	x2, dcache_inval_poc
	blr	x2
	b	1f

	/*
	 * If we entered with the MMU and caches on, clean the ID mapped part
	 * of the primary boot code to the PoC so we can safely execute it with
	 * the MMU off.
	 */
0:	adrp	x0, __idmap_text_start
	adr_l	x1, __idmap_text_end
	adr_l	x2, dcache_clean_poc
	blr	x2

1:	mov	x0, x19
	bl	init_kernel_el			// w0=cpu_boot_mode
	mov	x20, x0

	/*
	 * The following calls CPU setup code, see arch/arm64/mm/proc.S for
	 * details.
	 * On return, the CPU will be ready for the MMU to be turned on and
	 * the TCR will have been set.
	 */
	bl	__cpu_setup			// initialise processor
	b	__primary_switch
SYM_CODE_END(primary_entry)
```


```assemble
	__INIT
SYM_CODE_START_LOCAL(record_mmu_state)
	mrs	x19, CurrentEL                  # 将当前异常级别读取到 x19 寄存器
	cmp	x19, #CurrentEL_EL2             # 比较当前异常级别是否为 EL2
	mrs	x19, sctlr_el1                  # 将系统控制寄存器 EL1 (sctlr_el1) 的值加载到 x19 中
	b.ne	0f                          # 如果当前异常级别不为 EL2 就不用加载 EL2 了,跳过下一行代码。
	mrs	x19, sctlr_el2                  # 加载系统控制寄存器 EL1 到 x19
0:
CPU_LE( tbnz	x19, #SCTLR_ELx_EE_SHIFT, 1f	)
CPU_BE( tbz	x19, #SCTLR_ELx_EE_SHIFT, 1f	)
	tst	x19, #SCTLR_ELx_C		// Z := (C == 0)
	and	x19, x19, #SCTLR_ELx_M		// isolate M bit
	csel	x19, xzr, x19, eq		// clear x19 if Z
	ret

	/*
	 * Set the correct endianness early so all memory accesses issued
	 * before init_kernel_el() occur in the correct byte order. Note that
	 * this means the MMU must be disabled, or the active ID map will end
	 * up getting interpreted with the wrong byte order.
	 */
1:	eor	x19, x19, #SCTLR_ELx_EE
	bic	x19, x19, #SCTLR_ELx_M
	b.ne	2f
	pre_disable_mmu_workaround
	msr	sctlr_el2, x19
	b	3f
2:	pre_disable_mmu_workaround
	msr	sctlr_el1, x19
3:	isb
	mov	x19, xzr
	ret
SYM_CODE_END(record_mmu_state)
```

## 恒等映射 idmap(identity mapping )

This document describes the virtual memory layout used by the AArch64
Linux kernel. The architecture allows up to 4 levels of translation
tables with a 4KB page size and up to 3 levels with a 64KB page size.

AArch64 Linux uses either 3 levels or 4 levels of translation tables
with the 4KB page configuration, allowing 39-bit (512GB) or 48-bit
(256TB) virtual addresses, respectively, for both user and kernel. With
64KB pages, only 2 levels of translation tables, allowing 42-bit (4TB)
virtual address, are used but the memory layout is the same.

ARMv8.2 adds optional support for Large Virtual Address space. This is
only available when running with a 64KB page size and expands the
number of descriptors in the first level of translation.

User addresses have bits 63:48 set to 0 while the kernel addresses have
the same bits set to 1. TTBRx selection is given by bit 63 of the
virtual address. The swapper_pg_dir contains only kernel (global)
mappings while the user pgd contains only user (non-global) mappings.
The swapper_pg_dir address is written to TTBR1 and never written to
TTBR0.


AArch64 Linux memory layout with 4KB pages + 4 levels (48-bit)::
```
 Start			End			Size		Use
 -----------------------------------------------------------------------
 0000000000000000	0000ffffffffffff	 256TB		user
 ffff000000000000	ffff7fffffffffff	 128TB		kernel logical memory map
[ffff600000000000	ffff7fffffffffff]	  32TB		[kasan shadow region]
 ffff800000000000	ffff80007fffffff	   2GB		modules
 ffff800080000000	fffffbffefffffff	 124TB		vmalloc
 fffffbfff0000000	fffffbfffdffffff	 224MB		fixed mappings (top down)
 fffffbfffe000000	fffffbfffe7fffff	   8MB		[guard region]
 fffffbfffe800000	fffffbffff7fffff	  16MB		PCI I/O space
 fffffbffff800000	fffffbffffffffff	   8MB		[guard region]
 fffffc0000000000	fffffdffffffffff	   2TB		vmemmap
 fffffe0000000000	ffffffffffffffff	   2TB		[guard region]
```

```
  [Nr] Name              Type            Address          Off    Size   ES Flg Lk Inf Al
  [ 1] .head.text        PROGBITS        ffff800080000000 010000 010000 00  AX  0   0 65536
  [ 2] .text             PROGBITS        ffff800080010000 020000 10f0000 00  AX  0   0 65536
  [ 3] .rodata           PROGBITS        ffff800081100000 1110000 a62468 00 WAMS  0   0 4096
  [ 4] .rodata1          PROGBITS        ffff800081b62468 1b72468 000000 00  WA  0   0  1
  [ 5] .pci_fixup        PROGBITS        ffff800081b62470 1b72470 002e10 00   A  0   0 16
  [ 6] .builtin_fw       PROGBITS        ffff800081b65280 1b75280 000000 00   A  0   0  8
  [ 7] __ksymtab         PROGBITS        ffff800081b65280 1b75280 00ff54 00   A  0   0  4
  [ 8] __ksymtab_gpl     PROGBITS        ffff800081b751d4 1b851d4 018054 00   A  0   0  4
  [ 9] __kcrctab         PROGBITS        ffff800081b8d228 1b9d228 000000 00   A  0   0  1
  [10] __kcrctab_gpl     PROGBITS        ffff800081b8d228 1b9d228 000000 00   A  0   0  1
  [11] __ksymtab_strings PROGBITS        ffff800081b8d228 1b9d228 04471a 01 AMS  0   0  1
  [12] __init_rodata     PROGBITS        ffff800081bd1942 1be1942 000000 00   A  0   0  1
  [13] __param           PROGBITS        ffff800081bd1948 1be1948 004ba0 00   A  0   0  8
  [14] __modver          PROGBITS        ffff800081bd64e8 1be64e8 000828 00  WA  0   0  8
  [15] __ex_table        PROGBITS        ffff800081bd6d10 1be6d10 003060 00   A  0   0  4
  [16] .notes            NOTE            ffff800081bd9d70 1be9d70 000054 00   A  0   0  4
  [17] .hyp.rodata       PROGBITS        ffff800081bda000 1bea000 005000 00 WAMS  0   0  8
  [18] .got              PROGBITS        ffff800081bdf000 1bef000 000068 00  WA  0   0  8
  [19] .rodata.text      PROGBITS        ffff800081bdf800 1bef800 005800 00  AX  0   0 2048
  [20] .init.text        PROGBITS        ffff800081bf0000 1c00000 08f014 00  AX  0   0  4
  [21] .exit.text        PROGBITS        ffff800081c7f014 1c8f014 00b2e8 00  AX  0   0  4
  [22] .altinstructions  PROGBITS        ffff800081c8a2fc 1c9a2fc 0721e0 00   A  0   0  1
  [23] .init.data        PROGBITS        ffff800081d08000 1d18000 0dab90 00 WAMS  0   0 4096
  [24] .data..percpu     PROGBITS        ffff800081de3000 1df3000 00e1e8 00  WA  0   0 64
  [25] .hyp.data..percpu PROGBITS        ffff800081df2000 1e02000 002480 00  WA  0   0 16
  [26] .hyp.reloc        PROGBITS        ffff800081df4480 1e04480 000280 00   A  0   0  4
  [27] .rela.dyn         RELA            ffff800081df4700 1e04700 000090 18   A  0   0  8
  [28] .relr.dyn         RELR            ffff800081df4790 1e04790 023bc0 08   A  0   0  8
  [29] .data             PROGBITS        ffff800081e20000 1e30000 48bb00 00  WA  0   0 4096
  [30] __bug_table       PROGBITS        ffff8000822abb00 22bbb00 028ff8 00  WA  0   0  4
  [31] .mmuoff.data.write PROGBITS       ffff8000822d5000 22e5000 000008 00  WA  0   0 2048
  [32] .mmuoff.data.read PROGBITS        ffff8000822d5800 22e5800 000008 00  WA  0   0  8
  [33] .pecoff_edata_padding PROGBITS    ffff8000822d5808 22e5808 0001f8 00  WA  0   0  1
  [34] .sbss             PROGBITS        ffff8000822d6000 22e5a00 000000 00  WA  0   0  1
  [35] .bss              NOBITS          ffff8000822d6000 22e6000 0bb388 00  WA  0   0 4096
```