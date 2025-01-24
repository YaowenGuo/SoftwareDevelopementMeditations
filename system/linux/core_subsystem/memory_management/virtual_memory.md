# Linux 虚拟内存的实现

Linux 没有使用不同数据结构分别描述进程和线程，而是使用 `task_struct` 数据结构统一描述一个执行的任务（这样看起来更加优雅，毕竟对于内核来说都是一个要调度的单位），其属性 `struct mm_struct  *mm` 表示该线程的地址空间，使用同一地址空间的 Task 属于同一进程。

- 指向同一个 mm 的 Task 属于同一进程。不同进程使用不同的 `struct mm_struct`。

- 内核线程对应的 task_struct 结构中的 mm 域指向 Null，所以内核线程之间调度是不涉及地址空间切换的。

当一个内核线程被调度时，它会发现自己的虚拟地址空间为 Null，而是直接复用上一个用户态线程的虚拟地址空间（相当于在当前用户线程所在的进程执行任务），这样做有很多好处，可以避免内核线程之间调度时地址空间的切换开销。最重要的是由于地址空间没有变化，避免了缓存失效，大大提高了运行速度。


**父进程与子进程的区别，进程与线程的区别，以及内核线程与用户态线程的区别其实都是围绕着这个 mm_struct 展开的。**


In the Linux kernel, init_mm is a special instance of the mm_struct structure that plays a crucial role in managing the memory space for the kernel. Here’s a detailed explanation of its role and features:

> 1. Initialization of init_mm
init_mm is the first mm_struct created during the kernel initialization process. It is used to manage the memory space of the kernel itself. The init_mm structure is statically initialized in the kernel source code and is used to set up the initial memory management context for the kernel.

> 2. Role of init_mm
- Kernel Memory Management: init_mm is used to manage the kernel’s address space. It contains information about the kernel’s virtual memory layout, including the page tables and memory regions.
- Global Page Directory: The pgd (page global directory) field of init_mm points to the global page directory (swapper_pg_dir). This page directory is used to map the kernel’s virtual addresses to physical addresses.
- Memory Initialization: During the kernel boot process, init_mm is used to initialize the kernel’s memory management subsystem. This includes setting up the initial page tables and memory regions.

> 3. Initialization Code
The init_mm structure is initialized in the mm/init-mm.c file. Here is a snippet of the initialization code:

```C
struct mm_struct init_mm = {
	.mm_mt		= MTREE_INIT_EXT(mm_mt, MM_MT_FLAGS, init_mm.mmap_lock),
	.pgd		= swapper_pg_dir,
	.mm_users	= ATOMIC_INIT(2),
	.mm_count	= ATOMIC_INIT(1),
	.write_protect_seq = SEQCNT_ZERO(init_mm.write_protect_seq),
	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
	.arg_lock	=  __SPIN_LOCK_UNLOCKED(init_mm.arg_lock),
	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
	.user_ns	= &init_user_ns,
	.cpu_bitmap	= CPU_BITS_NONE,
#ifdef CONFIG_IOMMU_SVA
	.pasid		= INVALID_IOASID,
#endif
INIT_MM_CONTEXT(init_mm)
};
```
This code sets up the initial state of init_mm, including the page directory pointer and various counters.

> 4. Setting Up Initial Memory Regions

The setup_initial_init_mm function is used to set up the initial memory regions for the kernel. This function is called during the kernel boot process and initializes fields such as start_code, end_code, end_data, and brk

```C
void setup_initial_init_mm(void *start_code, void *end_code,
void *end_data, void *brk)
{
	init_mm.start_code = (unsigned long)start_code;
	init_mm.end_code = (unsigned long)end_code;
	init_mm.end_data = (unsigned long)end_data;
	init_mm.brk = (unsigned long)brk;
}
```

> 5. Usage in Kernel Initialization
During the kernel boot process, init_mm is used to manage the kernel’s address space. This includes setting up the initial page tables and memory regions. The init_mm structure is used by the kernel to manage its own memory, ensuring that the kernel has a valid memory management context from the very beginning.

> Summary
init_mm is a crucial component of the Linux kernel’s memory management subsystem. It is used to manage the kernel’s address space, set up the initial page tables, and ensure that the kernel has a valid memory management context during the boot process. The init_mm structure is statically initialized and used to initialize the kernel’s memory management subsystem.


[进程管理中的active_mm是做什么的？](https://www.cnblogs.com/linhaostudy/p/18234020)