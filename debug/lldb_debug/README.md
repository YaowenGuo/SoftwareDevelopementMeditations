# Debug

**无论如何在程序中都不要修改代码来用于调试。这意味着花更多的时间来修改代码从新编译，前者分散注意力，后者在程序较大时非常浪费时间。**


lldb 有命令行参数和内部调试指令，命令行参数是在启动 lldb 的时候指定的：

```
$ lldb -h
```
内部指令是启动 lldb 后交给 lldb 执行的指令：
```
(lldb) help
```
注意提示符 `$` 和 `(lldb)` 的不同。它们有些作用是相同的，大部分则不是。例如命令 `lldb <file>` 和如下的指令等效
```
$ lldb
(lldb) file <file>
```
其中 `file` 是要运行的可执行文件。留意上面的 `lldb -h` 和 `(lldb) help` 输出你就会发现，它们绝大多数是不同的。我们主要看 lldb 的命令。

## LLDB 的 TUI

lldb 可以在启动后使用 `gui` 切换到终端 UI 模式，该模式讲控制台分为三个区域：代码区、线程区、变量区。 

## LLDB 调试指令
与 GDB 形式各异的指令集不同，LLDB 力求使命令语法更加结构化。命令被组织为如下格式：

```
<noun> <verb> [-options [option-value]] [argument [argument...]]
# <名词> <动词> [-选项 [值]] [参数 [参数...]]
```
基本命令的命令语法非常简单，参数、选项和选项值都用空格分隔，并且使用单引号或双引号(成对)来保护参数中的空白。如果需要在参数中放入反斜杠或双引号字符，则在参数中使用反斜杠。这使得命令语法更加规则，但这也意味着您可能必须在lldb中引用一些在gdb中不需要引用的参数。

在lldb中还有另外一个特殊的引号——反引号。如果在参数或选项值周围加上反引号，lldb 将通过表达式解析器运行该文本，并将表达式的结果传递给命令。例如，如果 len 是一个局部int变量，值为5，则命令
```shell
(lldb) memory read -c `len` 0x12345
```
将接收计数选项的值5，而不是字符串len。

选项可以放在命令行的任何位置。如果有想要透传的参数是以`-`开头，那么你必须通过添加选项终止符 `--` 来告诉 lldb 此时已经完成了当前命令的选项，其后的内容不再视为 lldb 的选项。例如，如果你想启动一个进程，并为进程启动命令提供 `--stop-at-entry` 选项，但是你希望将 `-program arg` 作为进程的参数值启动进程，那么你需要输入:
```shell
(lldb) process launch --stop-at-entry -- -program_arg value
```

help 命令可以用于查看帮助文档，并进一步提供更详细的参数来查看子命令甚至选项的帮助信息。
```shell
help breakpoint
```
显示关于断点的文档。可以进一步添加参数，查看更详细的参数，例如：
```shell
(lldb) help breakpoint name
(lldb) help breakpoint name list
```
当看到语法中指定的命令的参数在尖括号中(如<breakpt-id>)时，这表明这是某种常见的参数类型，您可以从命令系统获得进一步的帮助。例如：
```shell
(lldb) help <breakpt-id>
  <breakpt-id> -- Breakpoints are identified using major and minor numbers; the major number...
```

## 确定调试程序

要调试，首先要指定调试的程序，大致有两种类型：
- 新启动一个程序，然后由 lldb 启动该程序
- 已经在运行的程序，将 lldb 附加到该进程上

### 新启动程序

使用 lldb 启动一个程序
```shell
$ lldb <executable program>
```
或者启动 lldb 后，在 lldb 中使用 `target create` 加载一个程序。

```shell
(lldb) target create <executable program>
或者使用 target create 的别名 file
$ (lldb) target create <executable program>
```

要在 lldb 中启动程序，我们使用进程启动命令或其内置别名之一。

```shell
(lldb) process launch
(lldb) run
(lldb) r
```

### 附加到正在运行的程序上

可以使用进程 ID 或进程名来将 lldb 附加到正在运行的进程上，
```
$ lldb -p <pid>
# 或者
$ lldb -n <process-name>
```
或者在 lldb 启动后，使用 `process attach` 指令，lldb 还支持 “–waitfor” 选项，该选项等待具有该名称的下一个进程出现，并附加到其之上。

```shell
(lldb) process attach --pid 123
(lldb) process attach --name Sketch
(lldb) process attach --name Sketch --waitfor
```
在启动或附加到进程之后，进程可能会在某处停止
```shell
(lldb) process attach -p 12345
Process 46915 Attaching
Process 46915 Stopped
1 of 3 threads stopped with reasons:
* thread #1: tid = 0x2c03, 0x00007fff85cac76a, where = libSystem.B.dylib`__getdirentries64 + 10, stop reason = signal = SIGSTOP, queue = com.apple.main-thread
```
注意输出中 `1 of 3 threads stopped with reasons:` 那行以及后面的几行。在多线程环境中，在内核实际将控制返回给调试器之前，多个线程遇到断点是很常见的。在这种情况下，您将看到列在stop消息中由于某些有趣的原因而停止的所有线程。

## 断点

### 添加断点

使用行号添加断点:
```shell
(lldb) breakpoint set --file foo.c --line 12
(lldb) breakpoint set -f foo.c -l 12
```

使用函数名添加断点:
```shell
(lldb) breakpoint set --name foo
(lldb) breakpoint set -n foo
```

也可以多次使用 `-name` 选项在一组函数上设置断点。这很方便，因为它允许您设置常见的条件或命令，而不必多次指定它们:
```shell
(lldb) breakpoint set --name foo --name bar
```

按名称设置断点在 LLDB 中甚至更加专门化，因为您可以通过方法名称指定希望在函数中设置断点。要在所有名为foo的C++方法上设置断点，可以输入:
```shell
(lldb) breakpoint set --method foo
(lldb) breakpoint set -M foo
```

可以使用 “–shlib <path>” (“-s <path>” for short) 将任何断点限制为特定的可执行映像 :
```shell
(lldb) breakpoint set --shlib foo.dylib --name foo
(lldb) breakpoint set -s foo.dylib -n foo
```
也可以重复使用 `–shlib` 选项来指定多个共享库。

与gdb一样，lldb命令解释器对命令名进行最短唯一字符串匹配，因此下面两个命令都将执行相同的命令:
```shell
(lldb) breakpoint set -n "-[SKTGraphicView alignLeftEdges:]"
(lldb) br s -n "-[SKTGraphicView alignLeftEdges:]"
```

LLDB还支持源文件名、符号名、文件名等的命令补全。补全是通过按 TAB 键完成。命令中的不同选项可以有不同的补全，例如，breakpoint 中的 “–file <path>” 选项补全为源文件，“–shlib <path>” 选项补全为当前加载的共享库，等等。我们甚至可以这样做，如果已经指定了 “–shlib <path>”，并且在“–file <path>”进行补全，将只列出加载的的共享库中的源文件。

### 查看断点：
```shell
(lldb) breakpoint list
Current breakpoints:
1: name = 'alignLeftEdges:', locations = 1, resolved = 1
1.1: where = Sketch`-[SKTGraphicView alignLeftEdges:] + 33 at /Projects/Sketch/SKTGraphicView.m:1405, address = 0x0000000100010d5b, resolved, hit count = 0
```

注意，设置断点会创建一个逻辑断点，该断点可以解析到一个或多个位置。例如，按选择器中断将在程序中类中实现该选择器的所有方法上设置断点。类似地，如果文件和行被内联在代码中的不同位置，则文件和行断点可能会导致多个位置。

逻辑断点有一个整数 id，断点内的位置也有一个id(两着通过 `.` 链接，如上面例子中的1.1)。

此外，逻辑断点仍然是活动的，因此，如果另一个共享库要加载具有alignLeftEdges 接口的另一个实现，则新的位置将添加到断点1(例如，断点 1.2 将设置在新加载的实现上)。

断点清单中的另一信息是断点位置是否被确定。当一个位置对应的文件地址被加载到你正在调试的程序中时，这个位置就被确定了。例如，如果在共享库中设置了一个断点，然后该共享被卸载，那么该断点将保留，但将不再被定位。

可以操作逻辑断点，或者断点确定的任何一个特定位置，删除、禁用、设置条件以及忽略计数。例如，如果我们想添加一个命令，用于命中断点时输出 backtrace，我们可以这样做：
```shell
(lldb) breakpoint command add 1.1
Enter your debugger command(s). Type 'DONE' to end.
> bt
> DONE
```
缺省情况下，`command add` 命令采用 lldb 命令行命令。也可以通过  “–command” 选项显式地指定这一点。如果您希望使用 Python 脚本来实现，需要指定 “–script” 参数。

1. 临时断点，触发一次就会被删除：`-o <boolean> ( --one-shot <boolean> )` 
2. gdb 中 catch 捕获点在 lldb 中被合并到 breadpoint 中，使用选项指定，例如异常 `break set -E C++`

### 条件断点

指定断点是可以使用 `-c <expr> ` 参数为断点指定一个表达式，只有表达式为 true 时才触发断点。

help expression？

条件中断也极其灵活，不仅可以测试相等或不相等的变量。在condition中可以使用哪些表达式呢？在有效的C条件语句中几乎可以使用任何表达式。无论使用什么表达式，都需要具有布尔值，即真（非O）或假（0）。包括：
- 相等、逻辑和不相等运算符（《、《=、=三、！ 、2、2=、&&、|等），例如：
```
break 180 if string==NULL && i < o
```
- 按位和移位运算符（&、I、^、＞>、<<等），例如：
```
break test.c:34 if (x & y) == 1
```
- 算术运算符（+、、X、/、%），例如：
```
break myfunc if i % (j + 3) 1= 0
```

## 断点命名

断点携带两个维度的信息:一维指定在哪里设置断点，另一维指定在遇到断点时如何作出反应。后一维信息(如命令、条件、命中计数、自动继续...)我们称之为断点选项。

希望将一组选项应用于多个断点是相当常见的。例如，您可能想要检查 self == nil，如果是，则在许多方法上打印 backtracen 并继续。一种方便的方法是创建所有的断点，使用：
```
(lldb) breakpoint modify -c "self == nil" -C bt --auto-continue 1 2 3
```
这还行，但是你必须为每一个新创建的的断点重复此操作，如果你想改变选项，你必须记住所有使用这种方式设置的断点。

断点名称为这个问题提供了一个方便的解决方案。方法是使用名称将希望以这种方式影响的断点收集到一个组中。所以当你设置断点的时候应当这样：

```
(lldb) breakpoint set -N SelfNil
```
然后，当您设置了所有的断点后，您可以使用名称设置或修改选项来收集所有相关的断点。
```
(lldb) breakpoint modify -c "self == nil" -C bt --auto-continue SelfNil
```
这样做更好，但是存在这样的问题:当添加新的断点时，它们不会拾取这些修改，并且这些选项只存在于实际断点的上下文中，因此它们很难存储和重用。

一个更好的解决方案是创建一个完全配置的断点名称

```
(lldb) breakpoint name configure -c "self == nil" -C bt --auto-continue SelfNil
```
然后，您可以将该名称应用于您的断点，并且它们都将拾取这些选项。从名称到断点的连接仍然是活动的，因此当您更改在名称上配置的选项时，所有断点都将获取这些更改。这样就可以很容易地使用配置的名称来试验您的选项。

您可以在.lldbinit文件中设置断点名称，这样您就可以使用它们来指定您认为有用的行为，并在以后的会话中重新应用它们。

还可以从断点上设置的选项中创建断点名称

```
(lldb) breakpoint name configure -B 1 SelfNil
```
这使得将行为从一个断点复制到一组其他断点变得容易。



## 监视点

让我们看一个监视点非常有用的示例场景。假设有两个int变量x和y，在代码中的某一处执行p=&y，而你的意图是执行p=&x。这可能会导致y神秘地改变代码中某处的值。导致程序错误的实际位置可能隐藏得很好，因此断点的用处不会太大。然而，通过设置监视点，可以立刻知道y在何时何处修改了值。

监视点的好处甚至还不止这些，它不仅仅限于监视变量。事实上，可以监视涉及变量的表达式。每当表达式修改值时，GDB都会中断。作为一个示例，来看如下代码。

我们想在每当i大于4时得到通知。因此在main（）的入口处放一个断点，以便让主在作用域中，并设置一个监视点以指出主何时大于4。不能在上设置监视点，因为在程序运行之前，i不存在。
因此必须先在main（）上设置断点，然后在i上设置监视点。
```
(gdb) break main
  Breakpoint 1 at 0x80483b4: file test2.c, line 6. 
(gdb) run
  Starting program: test2

  Breakpoint 1, main () at test2.c:6
```
既然i已经在作用域中了，现在设置监视点并通知GDB继续执行程序。我们完全可以料到，在第9行时会出现主>4的情况。
```
(gdb) watch i › 4
  Hardware watchpoint 2: i › 4
(gdb) continue
  Continuing.
```

### RAW

lldb 命令解析器支持原始指令，在命令参数去掉选项后，其余的命令字符串将不进行解析，直接传递给命令。这对于那些参数可能是一些复杂表达式的命令来说很方便，因为反斜杠保护可能会很麻烦。

在 lldb 中出入 help <子命令> 可以查看这个命令是否是原始命令。

**唯一要注意的是，由于原始命令仍然可以有选项，如果您的命令字符串中有 `-`，你必须在 lldb 命令和你的命令之间插入 `--` 以表示之后的字符串不再是选项。**

例如 `expression` 命令就是一个命令。因为它接收复杂的表达式求值。

```shell
expr my_struct->a = my_array[3]
expr -f bin -- (index * 8) + 5
expr unsigned int $foo = 5
expr char c[] = \"foo\"; c[0]
```

lldb还有一个内置的Python解释器，可以通过script命令访问。调试器的所有功能都可以在Python解释器中作为类使用，因此可以通过使用lldb-Python库编写Python函数，然后将脚本加载到正在运行的会话中，并使用script命令访问它们，从而可以使用define命令在gdb中引入更复杂的命令。在概述了lldb的命令语法之后，我们继续介绍标准调试会话的各个阶段。


## 设置

### 别名

还可以为常用命令设置别名，如果你讨厌打字:
```shell
(lldb) breakpoint set --file foo.c --line 12
```
还可以这样:
```shell
(lldb) command alias bfl breakpoint set -f %1 -l %2
(lldb) bfl foo.c 12
```
lldb 为常用命令内置了一些别名(例如step, next和continue)，但并没有尝试穷尽所有，因为根据其经验，使用一两个字母代替基本命令，并制定它们的选项，比使用各种别名，并不停键入它们更方便。

但是，lldb 仍然允许用户自由地自定义 lldb 的命令集，lldb 在启动时会读取 `~/.lldbinit` 文件，所以你可以将所有别名存储在那里，以使其一直可用。你的别名也显示在帮助命令中，以提醒自己已经设置了什么。

一个值得注意的别名是 `b`，根据大众的需求，lldb 包含了 gdb break 命令的弱模拟。但其也不完全相同(例如，它不会处理foo.c::bar)。其方便从 gdb 到 lldb 的过度，因此它被别名为 b。如果你真的想学习 lldb 命令集，它反而会妨碍其断点命令的使用（你不能使用 b 作为 lldb 的断点指令）。幸运的是，如果你不喜欢某个 lldb 的内置别名，你可以通过运行轻松地摆脱它：
```
(lldb) command unalias b
```



## [调试指令](view_data.md)


## 保存常用命令

为避免在每个调试会话开始之后键入，您可以将此命令保存到文件中（例如 lldb.cmd ），然后像这样启动lldb：
启动文件可以用于保存断点和调试状态，每次启动gdb自动加载它。该文件名为.gdbinit。可以将一个文件放在主目录用于一般用途，另一个文件包含在该项目中用于特殊用途。
```
$ lldb -S lldb.cmd
```

如果已经启动gdb，但是修改了.gdbinit 可以使用sources ~/.gdbinti重新加载该启动文件。



## script

lldb 使用 script 支持内置的 python 解析代替 gdb 的宏。


## 参考

 https://lldb.llvm.org/use/tutorial.html