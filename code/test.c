#include <stdio.h>

// int main() {
//     long _end = 0xffff800082390000;
//     long size = ((((1 + ((((((48) - 4) / (12 - 3)) - 1)) > 3 ? ((((((_end)) - 1) >> (((12 - 3) * (4 - (2)) + 3) + 3 * (12 - 3))) - (((((((-(((1)) << (((48)) - 1)))) + (0x80000000))))) >> (((12 - 3) * (4 - (2)) + 3) + 3 * (12 - 3))) + 1) + (1)) : 0) + ((((((48) - 4) / (12 - 3)) - 1)) > 2 ? ((((((_end)) - 1) >> (((12 - 3) * (4 - (2)) + 3) + 2 * (12 - 3))) - (((((((-(((1)) << (((48)) - 1)))) + (0x80000000))))) >> (((12 - 3) * (4 - (2)) + 3) + 2 * (12 - 3))) + 1) + (1)) : 0) + ((((((48) - 4) / (12 - 3)) - 1)) > 1 ? ((((((_end)) - 1) >> (((12 - 3) * (4 - (2)) + 3) + 1 * (12 - 3))) - (((((((-(((1)) << (((48)) - 1)))) + (0x80000000))))) >> (((12 - 3) * (4 - (2)) + 3) + 1 * (12 - 3))) + 1) + (1)) : 0))) + 3) * (1 << 12));
    
//     long shift = 1L << 47;
//     long value = - shift;
//     printf("%lX\n", shift);
//     printf("%lX\n", value);
//     return 0;

// }

// #define __AC(X,Y)	(X##Y)
// #define _AC(X,Y)	__AC(X,Y)
// #define _UL(x)		(_AC(x, UL))
// #define UL(x)		(_UL(x))
// #define SZ_8M				0x00800000
// #define FIXADDR_TOP		(-UL(SZ_8M))
// // #define FIXADDR_SIZE		(__end_of_permanent_fixed_addresses << PAGE_SHIFT)
// // #define FIXADDR_START		(FIXADDR_TOP - FIXADDR_SIZE)

// int main() {
//     printf("%lX\n", FIXADDR_TOP);
//     return 0;
// }
#define MODULES_VADDR ((-((((1UL))) << (((48)) - 1))))

enum fixed_addresses {
	FIX_HOLE,

	/*
	 * Reserve a virtual window for the FDT that is a page bigger than the
	 * maximum supported size. The additional space ensures that any FDT
	 * that does not exceed MAX_FDT_SIZE can be mapped regardless of
	 * whether it crosses any page boundary.
	 */
	FIX_FDT_END,
	FIX_FDT,

	FIX_EARLYCON_MEM_BASE,
	FIX_TEXT_POKE0,

#ifdef CONFIG_ACPI_APEI_GHES
	/* Used for GHES mapping from assorted contexts */
	FIX_APEI_GHES_IRQ,
	FIX_APEI_GHES_SEA,
#ifdef CONFIG_ARM_SDE_INTERFACE
	FIX_APEI_GHES_SDEI_NORMAL,
	FIX_APEI_GHES_SDEI_CRITICAL,
#endif
#endif /* CONFIG_ACPI_APEI_GHES */

#ifdef CONFIG_UNMAP_KERNEL_AT_EL0
#ifdef CONFIG_RELOCATABLE
	FIX_ENTRY_TRAMP_TEXT4,	/* one extra slot for the data page */
#endif
	FIX_ENTRY_TRAMP_TEXT3,
	FIX_ENTRY_TRAMP_TEXT2,
	FIX_ENTRY_TRAMP_TEXT1,
#define TRAMP_VALIAS		(__fix_to_virt(FIX_ENTRY_TRAMP_TEXT1))
#endif /* CONFIG_UNMAP_KERNEL_AT_EL0 */

	/*
	 * Temporary boot-time mappings, used by early_ioremap(),
	 * before ioremap() is functional.
	 */
// #define NR_FIX_BTMAPS		(SZ_256K / PAGE_SIZE)
// #define FIX_BTMAPS_SLOTS	7
// #define TOTAL_FIX_BTMAPS	(NR_FIX_BTMAPS * FIX_BTMAPS_SLOTS)
	__end_of_permanent_fixed_addresses,
	FIX_BTMAP_END = __end_of_permanent_fixed_addresses,
	// FIX_BTMAP_BEGIN = FIX_BTMAP_END + TOTAL_FIX_BTMAPS - 1,

	/*
	 * Used for kernel page table creation, so unmapped memory may be used
	 * for tables.
	 */
	FIX_PTE,
	FIX_PMD,
	FIX_PUD,
	FIX_P4D,
	FIX_PGD,

	__end_of_fixed_addresses
};


// int main() {
//     enum fixed_addresses end =  __end_of_permanent_fixed_addresses;
//     enum fixed_addresses bitmap =  FIX_BTMAP_END;

//     printf("__end_of_permanent_fixed_addresses: %d\n", end);
//     printf("FIX_BTMAP_END: %d\n", bitmap);
//     printf("MODULES_VADDR: %lx\n", MODULES_VADDR);

//     return 0;
// }


// #include <iostream>
// #include <thread>
// #include <functional>
 
// // 待执行的函数，接受一个整数作为参数
// void functionToCall(int param) {
//     std::cout << "Function called with parameter: " << param << std::endl;
// }
//      // 创建一个将要传递给thread的函数，绑定特定参数
//     auto boundFunction = std::bind(functionToCall, 42);
 
//     // 在新线程中调用绑定的函数
//     std::thread newThread(boundFunction);
// int main() {

 
//     // 等待线程完成
//     newThread.join();
 
//     return 0;
// }

#include <stdio.h>

#define __COUNT_ARGS(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, _20, N, ...) N
#define COUNT_ARGS(...) __COUNT_ARGS(, ##__VA_ARGS__, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0)

#define CALL_ENGINE_CALLBACK(...) __CALL_ENGINE_CALLBACK(__VA_ARGS__)
#define __CALL_ENGINE_CALLBACK(...)  __CALL_ENGINE_CALLBACK_IMPL(COUNT_ARGS(__VA_ARGS__), __VA_ARGS__)
#define __CALL_ENGINE_CALLBACK_IMPL(num, ...) CALL_ENGINE_CALLBACK_
#define CALL_ENGINE_CALLBACK_1(fun) fun
#define CALL_ENGINE_CALLBACK_2(fun, argv) fun + argv

#define PP_REMOVE_PARENS(T) PP_REMOVE_PARENS_IMPL T
#define PP_REMOVE_PARENS_IMPL(...) __VA_ARGS__

// #define FOO(A, B) int foo(A x, B y)
// #define BAR(A, B) FOO(PP_REMOVE_PARENS(A), PP_REMOVE_PARENS(B))

// FOO(bool, IntPair)                  // -> int foo(bool x, IntPair y)
// BAR((bool), (std::pair<int, int>))  // -> int foo(bool x, std::pair<int, int> y)

int main(int argc, char *argv[])
{
    int count1 = CALL_ENGINE_CALLBACK(1);                                                                              // count1 = 0
    int count2 = CALL_ENGINE_CALLBACK(1, 3);                                                                       // count2 = 3
    int count3 = COUNT_ARGS(1, 2, 3, 4, 5, 6, 7);                                                           // count3 = 7
    int count4 = COUNT_ARGS("Hello", 'a', 3.14);                                                            // count4 = 3
    int count5 = COUNT_ARGS(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20);         // count5 = 20
    int count6 = COUNT_ARGS(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 46, 76); // count6 = 20

    printf("count1 = %d\n", count1);
    printf("count2 = %d\n", count2);
    printf("count3 = %d\n", count3);
    printf("count4 = %d\n", count4);
    printf("count5 = %d\n", count5);
    printf("count6 = %d\n", count6);

    return 0;
}
