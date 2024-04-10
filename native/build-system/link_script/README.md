# [链接脚本（linker script）](https://sourceware.org/binutils/docs/ld/Scripts.html)

转载自：http://linux.chinaunix.net/techdoc/beginner/2009/08/12/1129972.shtml。这里复制调整了格式，防止原文丢失。

链接脚本用于指导链接器如何将输入文件内的 cection 放入输出文件内，并控制输出文件内各部分在程序地址空间的布局。

链接器有个默认的内置脚本，GUN ld 可以使用 `ld -verbose` 查看，使用 `-T <file>` 可以指定自定义的链接脚本，用于代替默认脚本。也可以用其增加自定义的链接命令.

## 脚本格式
链接脚本由一系列命令组成, 每个命令由一个关键字(一般在其后紧跟相关参数)或一条对符号的赋值语句组成. 命令由分号‘;’分隔开.
文件名或格式名内如果包含分号’;'或其他分隔符, 则要用引号‘”’将名字全称引用起来. 无法处理含引号的文件名.
之间的是注释。
 
## 简单脚本命令

- ENTRY(SYMBOL) ：将符号SYMBOL的值设置成入口地址。
    入口地址(entry point)是指进程执行的第一条用户空间的指令在进程地址空间的地址，ld有多种方法设置进程入口地址, 按一下顺序: (编号越前, 优先级越高)
    1. ld命令行的-e选项
    2. 链接脚本的ENTRY(SYMBOL)命令
    3. 如果定义了start符号, 使用start符号值
    4. 如果存在.text section, 使用.text section的第一字节的位置值
    5. 使用值0

- INCLUDE filename : 包含其他名为filename的链接脚本。相当于c程序内的的#include指令, 用以包含另一个链接脚本。
    脚本搜索路径由-L选项指定. INCLUDE指令可以嵌套使用, 最大深度为10. 即: 文件1内INCLUDE文件2, 文件2内INCLUDE文件3… , 文件10内INCLUDE文件11. 那么文件11内不能再出现 INCLUDE指令了.

- INPUT(files): 将括号内的文件做为链接过程的输入文件
    ld首先在当前目录下寻找该文件, 如果没找到, 则在由-L指定的搜索路径下搜索. file可以为 -lfile形式，就象命令行的-l选项一样. 如果该命令出现在暗含的脚本内, 则该命令内的file在链接过程中的顺序由该暗含的脚本在命令行内的顺序决定.

- GROUP(files) : 指定需要重复搜索符号定义的多个输入文件
    file必须是库文件, 且file文件作为一组被ld重复扫描，直到不在有新的未定义的引用出现。

- OUTPUT(FILENAME) : 定义输出文件的名字
    同ld的-o选项, 不过-o选项的优先级更高. 所以它可以用来定义默认的输出文件名. 如a.out

- SEARCH_DIR(PATH) ：定义搜索路径，
    同ld的-L选项, 不过由-L指定的路径要比它定义的优先被搜索。

- STARTUP(filename) : 指定filename为第一个输入文件
    在链接过程中, 每个输入文件是有顺序的. 此命令设置文件filename为第一个输入文件。

- OUTPUT_FORMAT(BFDNAME) : 设置输出文件使用的BFD格式
    同ld选项-o format BFDNAME, 不过ld选项优先级更高.

- OUTPUT_FORMAT(DEFAULT,BIG,LITTLE) : 定义三种输出文件的格式(大小端)
    若有命令行选项-EB, 则使用第2个BFD格式; 若有命令行选项-EL，则使用第3个BFD格式.否则默认选第一个BFD格式.

- TARGET(BFDNAME)：设置输入文件的BFD格式
    同ld选项-b BFDNAME. 若使用了TARGET命令, 但未使用OUTPUT_FORMAT命令, 则最用一个TARGET命令设置的BFD格式将被作为输出文件的BFD格式.

- ASSERT(EXP, MESSAGE)：如果EXP不为真，终止链接过程

- EXTERN(SYMBOL SYMBOL …)：在输出文件中增加未定义的符号，如同链接器选项-u

- FORCE_COMMON_ALLOCATION：为common symbol(通用符号)分配空间，即使用了-r链接选项也为其分配

- NOCROSSREFS(SECTION SECTION …)：检查列出的输出section，如果发现他们之间有相互引用，则报错。对于某些系统，特别是内存较紧张的嵌入式系统，某些section是不能同时存在内存中的，所以他们之间不能相互引用。

- OUTPUT_ARCH(BFDARCH)：设置输出文件的machine architecture(体系结构)，BFDARCH为被BFD库使用的名字之一。可以用命令objdump -f查看。

可通过 `man -S 1 ld` 查看ld的联机帮助, 里面也包括了对这些命令的介绍.
 
## 对符号的赋值

在目标文件内定义的符号可以在链接脚本内被赋值. (注意和C语言中赋值的不同!) 此时该符号被定义为全局的. 每个符号都对应了一个地址, 此处的赋值是更改这个符号对应的地址.
举例. 通过下面的程序查看变量a的地址:
a.c文件
```C
#include <stdio.h>
int a = 100;
int main(){
    printf( "&a=%p\n", &a );
    return 0;
}
```
编译，运行结果：
```shell
$ gcc -Wall -o a-without-lds.exe a.c
$ ./a.out
&a = 0×601020
```

a.lds文件
```
a = 3;
```
编译，运行结果：
```
$ gcc -Wall -o a-with-lds.exe a.c a.lds
$ ./a.out
&a = 0×3
```

注意: 对符号的赋值只对全局变量起作用!
对于一些简单的赋值语句，我们可以使用任何c语言语法的赋值操作:
```
SYMBOL = EXPRESSION ;
SYMBOL += EXPRESSION ;
SYMBOL -= EXPRESSION ;
SYMBOL *= EXPRESSION ;
SYMBOL /= EXPRESSION ;
SYMBOL >= EXPRESSION ;
SYMBOL &= EXPRESSION ;
SYMBOL |= EXPRESSION ;
```
除了第一类表达式外, 使用其他表达式需要SYMBOL已经被在某目标文件的源码中被定义。
. 是一个特殊的符号，它是定位器，一个位置指针，指向程序地址空间内的某位置(或某section内的偏移，如果它在SECTIONS命令内的某section描述内)，该符号只能在SECTIONS命令内使用。
注意：赋值语句包含4个语法元素：符号名、操作符、表达式、分号；一个也不能少。
被赋值后，符号所属的section被设值为表达式EXPRESSION所属的SECTION(参看11. 脚本内的表达式)
赋值语句可以出现在链接脚本的三处地方：SECTIONS命令内，SECTIONS命令内的section描述内和全局位置。
示例1：
```C
floating_point = 0; 
SECTIONS
{
    .text : {
        *(.text)
        _etext = .; 
    }
    _bdata = (. + 3) & ~ 4; 
    .data : { *(.data) }
}
```
PROVIDE 关键字用于定义这类符号：在目标文件内被引用，但没有在任何目标文件内被定义的符号。
示例2：
```C
SECTIONS
{
    .text : {
        *(.text)
        _etext = .;
        PROVIDE(etext = .);
    }
}
```
这里，当目标文件内引用了etext符号，却没有定义它时，etext 符号对应的地址被定义为 .text section之后的第一个字节的地址。
 
## SECTIONS 命令

SECTIONS命令告诉 ld 如何把输入文件的sections映射到输出文件的各个 section: 如何将输入section合为输出section; 如何把输出section放入程序地址空间(VMA)和进程地址空间(LMA).
该命令格式如下:
```
SECTIONS
{
    SECTIONS-COMMAND
    SECTIONS-COMMAND
    …
}
```
SECTION-COMMAND 有四种:
(1) ENTRY命令
(2) 符号赋值语句
(3) 一个输出 section 的描述(output section description)
(4) 一个 section 叠加描述(overlay description)

如果整个链接脚本内没有 SECTIONS 命令, 那么 ld 将所有同名输入 section 合成为一个输出 section 内, 各输入 section 的顺序为它们被链接器发现的顺序。如果某输入section没有在SECTIONS命令中提到, 那么该section将被直接拷贝成输出section。

### 简单例子
在介绍链接描述文件的命令之前, 先看看下述的简单例子:
以下脚本将输出文件的text section定位在0×10000, data section定位在0×8000000:
```
SECTIONS
{
    . = 0×10000;
    .text : { *(.text) }
    . = 0×8000000;
    .data : { *(.data) }
    .bss : { *(.bss) }
}
```
'.' 号是链接脚本中一个特殊的符号: 定位器符号，用以表示当前位置。
解释一下上述的例子:
- `. = 0×10000` 把定位器符号置为0×10000 (若不指定, 则该符号的初始值为0).
- `.text : { *(.text) }` 将所有(*符号代表任意输入文件) 输入文件的 `.text section` 合并成一个 `.text section`, 该 section 的地址由定位器符号的值指定, 即 0×10000.
- `. = 0×8000000` 把定位器符号置为 0×8000000
- `.data : { *(.data) }` 将所有输入文件的 .data section 合并成一个.data section, 该 section的地址被置为 0×8000000.
- `.bss : { *(.bss) }` 将所有输入文件的 .bss section 合并成一个 .bss section，该 section 的地址被置为 0×8000000+.data section 的大小.
  
链接器每读完一个 section 描述后, 将定位器符号的值*增加*该section的大小. 注意: 此处没有考虑对齐约束。**对定位器符号进行赋值来修改定位器的值将影响随后的 Secontion 的起始地址。**

### 丢弃 section

对于.foo： { *(.foo) }，如果没有任何一个输入文件包含 .foo section，那么链接器将不会创建.foo输出section。但是如果在这些输出 section 描述内包含了非输入 section 描述命令(如符号赋值语句)，那么链接器将总是创建该输出section。
另外，有一个特殊的输出 section，名为 `/DISCARD/`，被该section引 用的任何输入 section 将不会出现在输出文件内，这就是DISCARD的意思吧。如果/DISCARD/ section 被它自己引用呢？想想看。
```
DISCARDS
/DISCARD/ : {
	*(.interp .dynamic)
	*(.dynsym .dynstr .hash .gnu.hash)
}
```
 
### 输出section描述

输出section描述具有如下格式:

```
SECTION-NAME [ADDRESS] [(TYPE)] : [AT(LMA)] {
    OUTPUT-SECTION-COMMAND
    OUTPUT-SECTION-COMMAND
    …
} [>REGION] [AT>LMA_REGION] [:PHDR HDR ...] [=FILLEXP]
```
`[]` 内的内容为可选选项, 一般不需要.
SECTION-NAME：section名字.SECTION-NAME后的空白、圆括号、冒号是必须的，换行符和其他空格是可选的。

1. 输出section名字

    输出section名字必须符合输出文件格式要求，比如：a.out 格式的文件只允许存在 .text、.data 和 .bss section名。而有的格式只允许存在数字名字，那么此时应该用引号将所有名字内的数字组合在一起；另外，还有一些格式允许任何序列的字符存在于 section 名字内，此时如果名字内包含特殊字符(比如空格、逗号等)，那么需要用引号将其组合在一起。

2. 输出section地址

    输出section地址 [ADDRESS] 是一个表达式，它的值用于设置 VMA。如果没有该选项且有 REGION 选项，那么链接器将根据 REGION 设置VMA；如果也没有REGION 选项，那么链接器将根据定位符号 ‘.’ 的值设置该 section 的VMA，将定位符号的值调整到满足输出 section 对齐要求后的值，这时输出 section的对齐要求为：该输出section描述内用到的所有输入 section 的对齐要求中最严格的对齐要求。

    `.text . : { *(.text) }` 和 `.text : { *(.text) }`

    这两个描述是截然不同的，第一个将 .text section 的 VMA 设置为**定位符号的值**，而第二个则是设置成定位符号的修调值，满足对齐要求后的。
    ADDRESS 可以是一个任意表达式，比如，ALIGN(0×10) 这将把该 section 的VMA设置成定位符号的修调值，满足16字节对齐后的。
    **注意：设置ADDRESS值，将更改定位符号的值。**

3. section 输出描述 OUTPUT-SECTION-COMMAND 为以下四种之一：
   - 符号赋值语句
   - 输入 section 描述
   - 直接包含的数据值
   - 一些特殊的输出section关键字 
 
#### 1、符号赋值语

查看前面的[对符号的赋值](##对符号的赋值)，这里就不累述。
 
#### 2、输入 section 描述：

输入 section 描述定义了哪些 section 被输出到当前的 section 中。输入section描述基本语法：
```
FILENAME([EXCLUDE_FILE (FILENAME1 FILENAME2 ...) SECTION1 SECTION2 ...)
```
- FILENAME 可以是一个特定的文件的名字，也可以是一个字符串模式。
- SECTION 可以是一个特定的section名字，也可以是一个字符串模式

例子是最能说明问题，

`*(.text)` ：表示所有输入文件的.text section

`*(EXCLUDE_FILE (*crtend.o *otherfile.o) .ctors)` ：表示除crtend.o、otherfile.o 文件外的所有输入文件的.ctors section。

`data.o(.data)` ：表示data.o文件的.data section

`data.o` ：表示data.o文件的所有section

`*(.text .data)` ：表示所有文件的.text section和.data section，顺序是：第一个文件的.text section，第一个文件的.data section，第二个文件的.text section，第二个文件的.data section，...

`*(.text) *(.data)` ：表示所有文件的.text section和.data section，顺序是：第一个文件的.text section，第二个文件的.text section，...，最后一个文件的.text section，第一个文件的.data section，第二个文件的.data section，...，最后一个文件的.data section

下面看链接器是如何找到对应的文件的。

当FILENAME是一个特定的文件名时，链接器会查看它是否在链接命令行内出现或在INPUT命令中出现。
当FILENAME是一个字符串模式时，链接器仅仅只查看它是否在链接命令行内出现。
注意：如果链接器发现某文件在INPUT命令内出现，那么它会在-L指定的路径内搜寻该文件。

字符串模式内可存在以下通配符：
- `*` ：表示任意多个字符
- `?` ：表示任意一个字符
- `[CHARS]` ：表示任意一个CHARS内的字符，可用-号表示范围，如：a-z
- `:` 表示引用下一个紧跟的字符
  
在文件名内，通配符不匹配文件夹分隔符 `/`，但当字符串模式仅包含通配符`*`时除外。
***任何一个文件的任意section只能在SECTIONS命令内出现一次。***
看如下例子
```
SECTIONS {
    .data : { *(.data) }
    .data1 : { data.o(.data) }
}
```
data.o文件的.data section 在第一个 OUTPUT-SECTION-COMMAND 命令内被使用了，那么在第二个 OUTPUT-SECTION-COMMAND命令内将不会再被使用，也就是说即使链接器不报错，输出文件的 .data1 section 的内容也是空的。
再次强调：链接器依次扫描每个 OUTPUT-SECTION-COMMAND 命令内的文件名，任何一个文件的任何一个section都只能使用一次。
读者可以用-M链接命令选项来产生一个map文件，它包含了所有输入section到输出section的组合信息。
再看个例子，
```
SECTIONS {
    .text : { *(.text) }
    .DATA : { [A-Z]*(.data) }
    .data : { *(.data) }
    .bss : { *(.bss) }
}
```
这个例子中说明，所有文件的输入.text section组成输出.text section；所有以大写字母开头的文件的.data section组成输出.DATA section，其他文件的.data section组成输出.data section；所有文件的输入.bss section组成输出.bss section。
可以用SORT()关键字对满足字符串模式的所有名字进行递增排序，如SORT(.text*)。
 

#### 通用符号(common symbol)的输入section

在许多目标文件格式中，通用符号并没有占用一个section。链接器认为：输入文件的所有通用符号在名为COMMON的section内。
例子，
```
.bss { *(.bss) *(COMMON) }
```
这个例子中将所有输入文件的所有通用符号放入输出.bss section内。可以看到COMMOM section的使用方法跟其他section的使用方法是一样的。
有些目标文件格式把通用符号分成几类。例如，在MIPS elf目标文件格式中，把通用符号分成standard common symbols(标准通用符号)和small common symbols(微通用符号，不知道这么译对不对？)，此时链接器认为所有standard common symbols在COMMON section内，而small common symbols在.scommon section内。

在一些以前的链接脚本内可以看见[COMMON]，相当于*(COMMON)，不建议继续使用这种陈旧的方式。
 
#### 输入section和垃圾回收

在链接命令行内使用了选项–gc-sections后，链接器可能将某些它认为没用的section过滤掉，此时就有必要强制链接器保留一些特定的 section，可用KEEP()关键字达此目的。如 `KEEP(*(.text))`或`KEEP(SORT(*)(.text))`

最后我们看个简单的输入section相关例子：

```
SECTIONS {
    outputa 0×10000 : {
        all.o
        foo.o (.input1)
    }
    outputb : {
        foo.o (.input2)
        foo1.o (.input1)
    }
    outputc : {
        *(.input1)
        *(.input2)
    }
}
```

本例中，将 all.o 文件的所有section和foo.o文件的所有(一个文件内可以有多个同名section).input1 section依次放入输出 outputa section内，该section的VMA是0×10000；将foo.o文件的所有.input2 section和foo1.o文件的所有.input1 section依次放入输出outputb section内，该section的VMA是当前定位器符号的修调值(对齐后)；将其他文件(非all.o、foo.o、foo1.o)文件的 .input1 section和 .input2 section 放入输出outputc section内。
 
#### 直接包含数据值

可以显示地在输出section内填入你想要填入的信息(这样是不是可以自己通过链接脚本写程序？当然是简单的程序)。
```
BYTE(EXPRESSION) 1 字节
SHORT(EXPRESSION) 2 字节
LOGN(EXPRESSION) 4 字节
QUAD(EXPRESSION) 8 字节
SQUAD(EXPRESSION) 64位处理器的代码时，8 字节
```
输出文件的字节顺序 big endianness 或 little endianness，可以由输出目标文件的格式决定；如果输出目标文件的格式不能决定字节顺序，那么字节顺序与第一个输入文件的字节顺序相同。如：BYTE(1)、LANG(addr)。

注意，这些命令只能放在输出section描述内，其他地方不行。

错误：SECTIONS { .text : { *(.text) } LONG(1) .data : { *(.data) } }

正确：SECTIONS { .text : { *(.text) LONG(1) } .data : { *(.data) } }

在当前输出section内可能存在未描述的存储区域(比如由于对齐造成的空隙)，可以用FILL(EXPRESSION)命令决定这些存储区域的内容， EXPRESSION的前两字节有效，这两字节在必要时可以重复被使用以填充这类存储区域。如FILE(0×9090)。在输出section描述中可以有 `=FILEEXP` 属性，它的作用如同FILE()命令，但是FILE命令只作用于该 FILE 指令之后的 section 区域，而 `=FILEEXP` 属性作用于整个输出section区域，且 FILE 命令的优先级更高！
 
#### 特殊的输出 section 关键字

在输出section描述OUTPUT-SECTION-COMMAND中还可以使用一些特殊的输出section关键字。

- CREATE_OBJECT_SYMBOLS ：为每个输入文件建立一个符号，符号名为输入文件的名字。每个符号所在的section是出现该关键字的section。

- CONSTRUCTORS ：与c++内的(全局对象的)构造函数和(全局对像的)析构函数相关，下面将它们简称为全局构造和全局析构。
    对于a.out目标文件格式，链接器用一些不寻常的方法实现c++的全局构造和全局析构。
    当链接器生成的目标文件格式不支持任意section名字时，比如说ECOFF、XCOFF格式，链接器将通过名字来识别全局构造和全局析构，对于这些文件格式，链接器把与全局构造和全局析构的相关信息放入出现 CONSTRUCTORS关键字的输出section内。
    符号__CTORS_LIST__表示全局构造信息的的开始处，__CTORS_END__表示全局构造信息的结束处。
    符号__DTORS_LIST__表示全局构造信息的的开始处，__DTORS_END__表示全局构造信息的结束处。
    这两块信息的开始处是一字长的信息，表示该块信息有多少项数据，然后以值为零的一字长数据结束。
    一般来说，GNU C++在函数__main内安排全局构造代码的运行，而__main函数被初始化代码(在main函数调用之前执行)调用。是不是对于某些目标文件格式才这样？？？

对于支持任意section名的目标文件格式，比如COFF、ELF格式，GNU C++将全局构造和全局析构信息分别放入.ctors section和.dtors section内，然后在链接脚本内加入如下，
```
__CTOR_LIST__ = .;
LONG((__CTOR_END__ – __CTOR_LIST__) / 4 – 2)
*(.ctors)
LONG(0)
__CTOR_END__ = .;
__DTOR_LIST__ = .;
LONG((__DTOR_END__ – __DTOR_LIST__) / 4 – 2)
*(.dtors)
LONG(0)
__DTOR_END__ = .;
```
如果使用GNU C++提供的初始化优先级支持(它能控制每个全局构造函数调用的先后顺序)，那么请在链接脚本内把CONSTRUCTORS替换成SORT (CONSTRUCTS)，把*(.ctors)换成*(SORT(.ctors))，把*(.dtors)换成*(SORT(.dtors))。一般来说，默认的链接脚本已作好的这些工作。
修改定位器


### 输出section描述（进阶）
我们再回顾以下输出section描述的文法：
```
SECTION-NAME [ADDRESS] [(TYPE)] : [AT(LMA)]
{
    OUTPUT-SECTION-COMMAND
    OUTPUT-SECTION-COMMAND
    …
} [>REGION] [AT>LMA_REGION] [:PHDR HDR ...] [=FILLEXP]
```
前面我们介绍了SECTION、ADDRESS、OUTPUT-SECTION-COMMAND相关信息，下面我们将介绍其他属性。
 
#### 1、输出section的类型

可以通过[(TYPE)]设置输出section的类型。如果没有指定TYPE类型，那么链接器根据输出section引用的输入section的类型设置该输出section的类型。它可以为以下五种值，
- NOLOAD ：该section在程序运行时，不被载入内存。
- DSECT,COPY,INFO,OVERLAY ：这些类型很少被使用，为了向后兼容才被保留下来。这种类型的section必须被标记为“不可加载的”，以便在程序运行不为它们分配内存。
默认值是多少呢？Puzzle!
 
#### 2、输出 section 的LMA 

默认情况下，LMA等于VMA，但可以通过[AT(LMA)]项，即关键字AT()指定LMA。
用关键字AT()指定，括号内包含表达式，表达式的值用于设置LMA。如果不用AT()关键字，那么可用AT>LMA_REGION表达式设置指定该section加载地址的范围。这个属性主要用于构件ROM境象。
例子，
```
SECTIONS
{
    .text 0×1000 : {_etext = . ;*(.text);  }
    .mdata 0×2000 : AT ( ADDR (.text) + SIZEOF (.text) ) { 
        _data = . ; *(.data); _edata = . ; 
    }
    .bss 0×3000 : { 
        _bstart = . ;
        *(.bss) *(COMMON) ;
        _bend = . ;
    }
}
```

#### 3、设置输出 section 所在的程序段

可以通过[:PHDR HDR ...]项将输出section放入预先定义的程序段(program segment)内。如果某个输出section设置了它所在的一个或多个程序段，那么接下来定义的输出section的默认程序段与该输出 section的相同。除非再次显示地指定。
```
PHDRS { text PT_LOAD ; }
SECTIONS { .text : { *(.text) } :text }
```
可以通过:NONE指定链接器不把该section放入任何程序段内。详情请查看PHDRS命令
 
#### 4、设置输出section的填充模版

这个在前面提到过，任何输出section描述内的未指定的内存区域，链接器用该模版填充该区域。我们可以通过[=FILLEXP]项设置填充值。用法：=FILEEXP，前两字节有效，当区域大于两字节时，重复使用这两字节以将其填满。
```
SECTIONS { 
    .text : { 
        *(.text)
    } =0×9090 
}
```
 
### 覆盖图(overlay)描述

覆盖图描述使两个或多个不同的section占用同一块程序地址空间。覆盖图管理代码负责将section的拷入和拷出。考虑这种情况，当某存储块的访问速度比其他存储块要快时，那么如果将section拷到该存储块来执行或访问，那么速度将会有所提高，覆盖图描述就很适合这种情形。文法如下，
```
SECTIONS {
    …
    OVERLAY [START] : [NOCROSSREFS] [AT ( LDADDR )]
    {
        SECNAME1 {
            OUTPUT-SECTION-COMMAND
            OUTPUT-SECTION-COMMAND
            …
        } [:PHDR...] [=FILL]

        SECNAME2 {
            OUTPUT-SECTION-COMMAND
            OUTPUT-SECTION-COMMAND
            …
        } [:PHDR...] [=FILL]
        …
    } [>REGION] [:PHDR...] [=FILL]
    …
}
```

由以上文法可以看出，同一覆盖图内的section具有相同的VMA。这里VMA由[START] 决定。SECNAME2的LMA为SECTNAME1的LMA加上SECNAME1的大小，同理计算SECNAME2,3,4…的LMA。SECNAME1的LMA由LDADDR决定，如果它没有被指定，那么由START决定，如果它也没有被指定，那么由当前定位符号的值决定。
NOCROSSREFS关键字说明各section之间不能交叉引用，否则报错。
对于OVERLAY描述的每个section，链接器将定义两个符号__load_start_SECNAME和__load_stop_SECNAME，这两个符号的值分别代表SECNAME section的LMA地址的开始和结束。
链接器处理完OVERLAY描述语句后，将定位符号的值加上所有覆盖图内section大小的最大值。
示例：
```
SECTIONS{
    …
    OVERLAY 0×1000 : AT (0×4000)
    {
        .text0 { o1
        …
        . = . + 0×1000; 
        .data : {
            *(.data) 
        } :data
        .dynamic : {
            *(.dynamic)
        } :data :dynamic
        …
    }
}
```


## 表达式

lds 中表达式的文法与C语言的表达式文法一致，表达式的值都是整型，如果ld的运行主机和生成文件的目标机都是32位，则表达式是32位数据，否则是64位数据。
以下是一些常用的表达式：
```
_fourk_1 = 4K; 
_fourk_2 = 4096; 
_fourk_3 = 0×1000; 
_fourk_4 = 01000; 
```
注意：1K=1024 1M=1024*1024
 
### 1、符号名
没有被引号”"包围的符号，以字母、下划线或’.'开头，可包含字母、下划线、’.'和’-'。当符号名被引号包围时，符号名可以与关键字相同。如，
“SECTION”=9;
“with a space” = “also with a space” + 10;
 
### 2、定位符号’.'

只在SECTIONS命令内有效，代表一个程序地址空间内的地址。
注意：在链接时，当定位符用在SECTIONS命令的输出section描述内时，它代表的是该section的当前**偏移**，而不是程序地址空间的绝对地址。当然当程序载入后，符号最后的地址还是程序地址空间的绝对地址。
示例11.2_1：
```
SECTIONS
{
    output :
    {
        file1(.text)
        . = . + 1000;
        file2(.text)
        . += 1000;
        file3(.text)
    } = 0×1234;
}
```
其中由于对定位符的赋值而产生的空隙由0×1234填充。其他的内容应该容易理解吧。
示例11.2_2：
```
SECTIONS
{
    . = 0×100
    .text: {
        *(.text)
        . = 0×200
    }
    . = 0×500
    .data: {
    *(.data)
        . += 0×600
    }
} 
```
.text section在程序地址空间的开始位置是0x100
示例11.2_3
文件src\a.c
```
#include <stdio.h>
int a = 100;
int b=0;
int c=0;
int d=1;
int main()
{
    printf( "&a=%p\n", &a );
    printf( "&b=%p\n", &b );
    printf( "&c=%p\n", &c );
    printf( "&d=%p\n", &d );
    return 0;
}
```
文件 lds\a.lds
```
a = 10; 
SECTIONS
{
    b = 11;
    .text :
    {
        *(.text)
        c = .; 
        . = 10000;
        d = .;
    }
    _bdata = (. + 3) & ~ 4; 
    .data : { *(.data) }
}
```
在没有使用a.lds情况下编译
```
gcc -Wall -o a-without-lds.exe ./src/a.c
```
运行./a-without-lds.exe 结果：
```
&a=0x601020
&b=0x601038
&c=0x60103c
&d=0x601024
```
在使用a.lds情况下编译
```
gcc -Wall -o a-with-lds.exe ./src/a.c ./lds/a.lds
```
运行./a-with-lds.exe 结果：
```
&a=0xa
&b=0xb
&c=0x400638
&d=0x402b20
```
### 3、表达式的操作符

在lds中，表达式的操作符与C语言一致。
优先级 结合顺序 操作符
```
1 left ! – ~ (1)
2 left * / %
3 left + -
4 left >>  =
5 left &
6 left |
7 left &&
8 left ||
9 right ? :
10 right &= += -= *= /= (2)
```
(1)表示前缀符，(2)表示赋值符。
 
### 4、表达式的计算

链接器延迟计算大部分表达式的值。
但是，对待与链接过程紧密相关的表达式，链接器会立即计算表达式，如果不能计算则报错。比如，对于section的VMA地址、内存区域块的开始地址和大小，与其相关的表达式应该立即被计算。
例子，
```
SECTIONS
{
.text 9+this_isnt_constant :
{ *(.text) }
}
```
这个例子中，9+this_isnt_constant表达式的值用于设置.text section的VMA地址，因此需要立即运算，但是由于this_isnt_constant变量的值不确定，所以此时链接器无法确立表达式的值，此时链接器会报错。
 
### 5、相对值与绝对值

在输出section描述内的表达式，链接器取其相对值，相对与该section的开始位置的偏移
在SECTIONS命令内且非输出section描述内的表达式，链接器取其绝对值
通过ABSOLUTE关键字可以将相对值转化成绝对值，即在原来值的基础上加上表达式所在section的VMA值。
示例
```
SECTIONS
{
    .data : { 
        *(.data) ;
        _edata = ABSOLUTE(.); 
    }
}
```
该例子中，_edata符号的值是.data section的末尾位置(绝对值，在程序地址空间内)。
 
### 6、内建函数
lds中有以下一些内建函数：
```
ABSOLUTE(EXP) ：转换成绝对值
ADDR(SECTION) ：返回某section的VMA值。
ALIGN(EXP) ：返回定位符’.'的按照EXP进行对齐后的修调值，对齐后的修调值算法为：(. + EXP – 1) & ~(EXP – 1)。
BLOCK(EXP) ：如同ALIGN(EXP)，为了向前兼容。
DEFINED(SYMBOL) ：如果符号SYMBOL在全局符号表内，且被定义了，那么返回1，否则返回0。
```
示例：
```
SECTIONS { …
    .text : {
        begin = DEFINED(begin) ? begin : . ;
        …
    }
    …
}
```
LOADADDR(SECTION) ：返回三SECTION的LMA
MAX(EXP1,EXP2) ：返回大者
MIN(EXP1,EXP2) ：返回小者
NEXT(EXP) ：返回下一个能被使用的地址，该地址是EXP的倍数，类似于ALIGN(EXP)。除非使用了MEMORY命令定义了一些非连续的内存块，否则NEXT(EXP)与ALIGH(EXP)一定相同。
SIZEOF(SECTION) ：返回SECTION的大小。当SECTION没有被分配时，即此时SECTION的大小还不能确定时，链接器会报错。
SIZEOF_HEADERS ：返回输出文件头部的字节数。这些信息出现在输出文件的开始处。当设置第一个段的开始地址时，你可以使用这个数字。如果你选择了加速分页，当产生一个ELF输出文件时，如果链接器脚本使用SIZEOF_HEADERS内建函数，链接器必须在它
算出所有段地址和长度之前计算程序头部的数值。如果链接器后来发现它需要附加程序头，它将报告一个“not enough room for 
program headers”错误。为了避免这样的错误，你必须避免使用SIZEOF_HEADERS函数，或者你必须修改你的链接器脚本去避免强制
链接器去使用附加程序头，或者你必须使用PHDRS命令去定义你自己的程序头


## 版本号命令

当使用ELF目标文件格式时，链接器支持带版本号的符号。版本号也只限于ELF文件格式。读者可以发现仅仅在共享库中，符号的版本号属性才有意义。动态加载器使用符号的版本号为应用程序选择共享库内的一个函数的特定实现版本。可以在链接脚本内直接使用版本号命令，也可以将版本号命令实现于一个特定版本号描述文件(用链接选项–version-script指定该文件)。
该命令的文法如下:
```
VERSION { version-script-commands }
```
以下讨论用gcc
 
### 1. 带版本号的符号的定义(共享库内)

文件b.c内容如下，
```C
int getVersion() {
    return 1;
}
```
写链接器的版本控制脚本，本例中为 b.lds，内容如下
```
VER1.0 {
    getVersion;
};
VER2.0 {
};
```
```shell
$gcc -c b.c
$gcc -shared -Wl,--version-script=b.lds -o libb.so b.o
```
可以在{}内填入要绑定的符号，本例中getVersion符号就与VER1.0绑定了。
那么如果有一个应用程序链接到该库的getVersion符号，那么它链接的就是VER1.0版本的getVersion符号
如果我们对b.c文件进行了升级，更改如下：
```
int getVersion() {
return 101;
}
```
这里我对getVersion()进行了更改，其返回值的意义也进行改变，也就是它和前不兼容：
为了程序的安全，我们把b.lds更改为，
```
VER1.0{
};
VER2.0{
    getVersion;
};
```
然后生成新的libb.so文件。
这时如果我们运行app.exe(它已经链接到VER1.0版本的getVersion())，就会发现该应用程序不能运行了。
提示信息如下：
```
./app.exe: relocation error: ./app.exe: symbol getVersion, version VER1.0 not defined in file libb.so with link time reference
```
因为库内没有VER1.0版本的getVersion()，只有VER2.0版本的getVersion()。
 
### 2、参看链接的符号的版本

对上面生成的app.exe执行以下命令：
```
nm app.exe | grep getVersion
```
结果
```
U new_true@@VER1.0
```
用nm命令发现app链接到VER1.0版本的getVersion


### 3、 GNU的扩充

在GNU中，允许在程序文件内绑定 *符号* 到 *带版本号的别名符号*

文件b.c内容如下，
```
int old_getVersion()
{
    return 1;
}
int new_getVersion()
{
    return 101;
}
```
__asm__(".symver old_getVersion,getVersion@VER1.0");
__asm__(".symver new_getVersion,getVersion@@VER2.0");

其中，对于VER1.0版本号的getVersion别名符号是old_getVersion；
对于VER2.0版本号的getVersion别名符号是new_getVersion，
在链接时，默认的版本号为VER2.0
供链接器用的版本控制脚本b.lds内容如下，

```
VER1.0{
};
VER2.0{
};
```

版本控制文件内必须包含版本VER1.0和版本VER2.0的定义，因为在b.c文件内有对他们的引用
再次执行以下命令编译链接b.c和app.c
```
gcc -c src/b.c
gcc -shared -Wl,--version-script=./lds/b.lds -o libb.so b.o
gcc -o app.exe ./src/app.c libb.so
```
运行：
./app.exe
结果：
Version=0x65
说明app.exe的确是链接的VER2.0的getVersion，即new_getVersion()
 
我们再对app.c进行修改，以使它链接的VER1.0的getVersion，即old_getVersion()
app.c文件：
```C
#include
__asm__(".symver getVersion,getVersion@VER1.0");
extern int getVersion();
int main()
{
    printf("Version=%p\n", getVersion());
    return 0;
}
```
再次编译链接b.c和app.c
运行：
./app.exe
结果：
Version=0x1
说明此次app.exe的确是链接的VER1.0的getVersion，即old_getVersion()


## 暗含的链接脚本

输入文件可以是目标文件，也可以是链接脚本，此时的链接脚本被称为`暗含的链接脚本`。如果链接器不认识某个输入文件，那么该文件被当作链接脚本被解析。更进一步，如果发现它的格式又不是链接脚本的格式，那么链接器报错。

一个暗含的链接脚本不会替换默认的链接脚本，仅仅是增加新的链接而已。一般来说，暗含的链接脚本符号分配命令或 INPUT、GROUP、VERSION命令。在链接命令行中，每个输入文件的顺序都被固定好了，暗含的链接脚本在链接命令行内占住一个位置，这个位置决定了由该链接脚本指定的输入文件在链接过程中的顺序。典型的暗含的链接脚本是libc.so文件，在GNU/linux内一般存在/usr/lib目录下。
