# C 内嵌汇编

C 语言可以通过几种不同的方式嵌入汇编，或者知识编译器生成汇编的方式。

## 关键字

register 指示编译器尽可能的将变量存在CPU内部寄存器中，而不是使用内存访问。

egister变量必须是能被CPU所接受的类型。这通常意味着register变量必须是一个单个的值，并且长度应该小于或者等于整型的长度。不过，有些机器的寄存器也能存放浮点数。

.因为register变量可能不存放在内存中，所以不能用“&”来获取register变量的地址。由于寄存器的数量有限，而且某些寄存器只能接受特定类型的数据（如指针和浮点数），因此真正起作用的register修饰符的数目和类型都依赖于运行程序的机器，而任何多余的register修饰符都将被编译程序所忽略。在某些情况下，把变量保存在寄存器中反而会降低程序的运行速度。因为被占用的寄存器不能再用于其它目的；或者变量被使用的次数不够多，不足以装入和存储变量所带来的额外开销。

　　3.早期的C编译程序不会把变量保存在寄存器中，除非你命令它这样做，这时register修饰符是C语言的一种很有价值的补充。然而，随着编译程序设计技术的进步，在决定那些变量应该被存到寄存器中时，现在的C编译环境能比程序员做出更好的决定。实际上，许多编译程序都会忽略register修饰符，因为尽管它完全合法，但它仅仅是暗示而不是命令。

```C
register int my_variable;
```

register 只是建议，如果想要强制编译器使用寄存器，可以使用 asm 关键字，同时指定寄存器名字。

```C
register int my_variable asm("r0");
```

## 嵌入 ASM

```c
asm [ volatile ] ( ``AssemblerInstructions`` )
```


带有C/C++表达式的内联汇编格式：

__asm__ __volatile__(“Instructionlist”:Output:Input:Clobber/Modify)

__asm__

__asm__是GCC关键字asm的宏定义：

#define __asm__ asm

__asm__或asm用来声明一个内联汇编表达式，所以任何一个内联汇编表达式都以它开头，是必不可少的。

__volatile__

__volatile__是GCC关键字volatile的宏定义：

#define __volatile__ volatile

__volatile__或volatile是可选的，如果用了它，则向GCC声明不允许对该内联汇编优化，否则，当使用优化选项（-o）进行编译时GCC会根据字自己的判断决定是否将内联汇编表达式的指令优化掉。

Instruction list

a. Instruction list是汇编指令序列，它可以是空，比如：

__asm__ __volatile__（“”）；或__asm__ （“”）；是合法的内联汇编表达式，但是它们没有意义。

b. 但是__asm__ __volatile__（“” ：：: ”memory”）,它向GCC声明，内存做了改动，GCC在编译的时候，会将此因素考虑进去。在访问IO端口和IO内存时；会用到内存屏障：

include/linux/compiler-gcc.h:

#define barrier() __asm____volatile__("": : :"memory")

它就是防止编译器对读写IO端口和IO内存指令的优化而实际的错误。

c. Instructionlist中有多条指令的时候，可以在一对引号中列出全部指令；也可以将一条或几条指令放在一对引号中，所有指令放在多对引号中。如果是前者，可以将所有指令放在一行，则必须用分号（;）或换行符（/n）将它们分开：

static inline int atomic_add_return(int i, atomic_t *v)

__asm__ __volatile__("@ atomic_add_return\n"     // @开始的内容是注释

"1: ldrex %0, [%2]\n"            // 1：是代码中的局部标签

" add %0, %0, %3\n"

" strex %1, %0, [%2]\n"

" teq %1, #0\n"

" bne 1b"                    //向后跳转到1处执行，b表示backward; bne 1f,表示向前跳转到1

: "=&r" (result), "=&r" (tmp)             // %0, %1

: "r" (&v->counter), "Ir" (i)              //%2, %3

: "cc");

Output

用来指定当前内联汇编的输出

Input

用来指定当前内联汇编的输入。

Output和Input中，格式为形如”constraint”(variable)的列表,用逗号分隔。如：

: "=&r" (result), "=&r" (tmp)

: "r" (&v->counter), "Ir" (i)

Clobber/Modify

有时候，当你想通知GCC当前内联汇编语句可能对某些寄存器和内存进行修改，希望GCC将这一点考虑进去，此时就可以在Clobber/Modify域中进行声明这些寄存器和内存。

这种情况一般发生在一个寄存器出现在Instructionlist，但不是有Output/Input操作表达式所指 定的，也不是在一些Output/Input操作表达式使用“r”约束时有GCC为其选择的，同时此寄存器被Instructionlist修改，而这个寄存器只是供当前内联汇编使用的情况。

例如：

__asm__ (“mov R0, #0x34” ::: “R0”)

寄存器R0出现在Instructionlist中，且被mov指令修改，但却未被任何Output/Input操作表达式指定，所以需要在Clobber/Modify域中指定“R0”，让GCC知道这一点。

因为你在Output/Input操作表达式所指定的寄存器，或当你为一些Output/Input表达式使用“r”约束，上GCC为你选择一个寄存器，寄存器对这些寄存器是非常清楚的， 它知道这些寄存器是被修改的，不需要在Clobber/Modify域中在声明它们。除此之外，GCC对剩下的寄存器中那些会被当前内联汇编修改一无所知。所以，如果当前内联汇编修改了这些寄存器，就最好在Clobber/Modify域中声明，让GCC针对这些寄存器做相应的处理，否则可能会造成寄存器 的不一致，造成程序执行错误。

如果一个内联汇编语句的Clobber/Modify域存在"memory"，那么GCC会保证在此内联汇编之前，如果某个内存的内容被装入了寄存器，那么在这个内联汇编之后，如果需要使用这个内存处的内容，就会直接到这个内存处重新读取，而不是使用被存放在寄存器中的拷贝。因为这个时候寄存器中的拷贝已经很可能和内存处的内容不一致了。

这只是使用"memory"时，GCC会保证做到的一点，但这并不是全部。因为使用"memory"是向GCC声明内存发生了变化，而内存发生变化带来的影响并不止这一点。




intmain(int __argc, char* __argv[])
{
int* __p =(int*)__argc;
(*__p) =9999;
__asm__("":::"memory");
if((*__p)== 9999)
return 5;
return (*__p);
}

本例中，如果没有那条内联汇编语句，那个if语句的判断条件就完全是一句废话。GCC在优化时会意识到这一点，而直接只生成return5的汇编代码，而不会再生成if语句的相关代码，而不会生成return(*__p)的相关代码。但你加上了这条内联汇编语句，它除了声明内存变化之外，什么都没有做。但GCC此时就不能简单的认为它不需要判断都知道(*__p)一定与9999相等，它只有老老实实生成这条if语句的汇编代码，一起相关的两个return语句相关代码。

另外在linux内核中内存屏障也是基于它实现的include/asm/system.h中

#define barrier() _asm__volatile_("": : :"memory")

主要是保证程序的执行遵循顺序一致性。呵呵，有的时候你写代码的顺序，不一定是最终执行的顺序，这个是处理器有关的。
