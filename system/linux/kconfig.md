# Kernel 的配置和编译

Linux 的配置系统用于为构建系统 Kbuild 提供编译指导，同时为 C/ASM 提供宏定义，以影响编译流程和结果。

Kconfig 使用 `Kconfig` 来定义配置项，配置选项以树状的结构组织。Kconfig 可以被解析，并以各种前端展示，方便用户交互。Kconfig 的配置文件为 `Kconfig`，在根目录下包含一个 Kconfig 文件，用于定义和导入各个子目录下的 `Kconfig`。

内核的每个目录下都有一个 `Kconfig` 文件，用于配置内核的编译。该文件编写了内核的配置条目和依赖关系，该文件能够被多种前端解析，用于用户交互式的配置，最终生成 .config 的配置文件，Kbuild 系统使用该 `.config` 进行构建最终的目标。

Kconfig 的配置选项以树状的结构组织。

```
+- Code maturity level options
|  +- Prompt for development and/or incomplete code/drivers
+- General setup
|  +- Networking support
|  +- System V IPC
|  +- BSD Process Accounting
|  +- Sysctl support
+- Loadable module support
|  +- Enable loadable module support
|     +- Set version information on all module symbols
|     +- Kernel module loader
+- ...
```

## 使用

Linux 的配置和编译都使用 make 来完成。

> 配置

- make config:基于文本模式的交互配置

- make menuconfig:基于文本模式的菜单模式(推荐使用)

- make oldconfig:使用已有的.config,但会询问新增的配置项

- make xconfig:图形化的配置(需要安装图形化系统)

> 清理

- make clean:只清理所有产生的文件

- make mrproper:清理所有产生的文件与config配置文件

- make distclean:清理所有产生的文件与config配置文件，并且编辑过的与补丁文件



`make menuconfig` 根据 Kconfig 的配置生成 `.config` 等文件。

```shell
$ tree out/arm_tmp
out/arm_tmp
|-- Makefile
|-- include
|   |-- config
|   |   |-- 64BIT
|   |   |-- 9P_FS
|   |   ...
|   |   |-- auto.conf          # Kconfig 配置生成的变量
|   |   `-- auto.conf.cmd      # auto.conf 配置的依赖，以及导入 auto.conf 的定义。
|   `-- generated
|       |-- autoconf.h
|       `-- rustc_cfg
|-- scripts
|   |-- basic
|   |   `-- fixdep
|   `-- kconfig
|       |-- confdata.o
|       |-- expr.o
|       |-- lexer.lex.c
|       |-- lexer.lex.o
|       |-- lxdialog
|       |   |-- checklist.o
|       |   |-- inputbox.o
|       |   |-- menubox.o
|       |   |-- textbox.o
|       |   |-- util.o
|       |   `-- yesno.o
|       |-- mconf
|       |-- mconf-bin
|       |-- mconf-cflags
|       |-- mconf-libs
|       |-- mconf.o
|       |-- menu.o
|       |-- mnconf-common.o
|       |-- parser.tab.c
|       |-- parser.tab.h
|       |-- parser.tab.o
|       |-- preprocess.o
|       |-- symbol.o
|       `-- util.o
`-- source -> /Users/lim/projects/linux
```

- scripts 目录下是 Kconfig 自身的程序和脚本，执行的 menuconfig 就是该目录下编译生成的程序。

- 其中 `include/generated/autoconf.h` 生成了 C 语言的宏定义。用于在编译时指导编译内容。

- `include/config/auto.conf` 用于 Makefile 的处理，在 Makefile 中可以看到类似 `obj-$(CONFIG_GENERIC_CALIBRATE_DELAY)` 的配置。
- include/config/ 下空的头文件用于 kbuild 期间的配置依赖性跟踪。

## 定义菜单名

```
mainmenu "Linux/$(ARCH) $(KERNELVERSION) Kernel Configuration"
```

## 导入文件

Kconfig 的导入是完全将内容导入，没有层级的概念，因此所有子目录的 `Kconfig` 也都是以根目录的相对位置。例如根目录下的 `Kconfig` 导入 init 目录下的文件。
```
source "init/Kconfig"
```
init 目录、arch 目录下的 Kconfig 导入路径都是相对于根目录的。
```
source "arch/Kconfig"
source "arch/$(SRCARCH)/Kconfig"
```

## 菜单

使用 `menu/endmenu` 来定义一个菜单

```
menu "Network device support"
      depends on NET

config NETDEVICES
      ...

endmenu
```

## 配置项（菜单项）

使用 `config` 定义一个配置项，它这样定义的：
```
config MODVERSIONS
      bool "Set version information on all module symbols"
      depends on MODULES
      help
        Usually, modules have to be recompiled whenever you switch to a new
        kernel.  ...
```

其最终会在 .config 中生成一个 `CONFIG_MODVERSIONS=y/n` 一行信息。当然是否最终生成还要根据其是否依赖其它配置项。

每行都以一个关键字开头，后面可以跟着几个参数。接下来缩进的行表示该配置的属性，属性可以是配置选项的类型、输入提示、依赖项、帮助文本和默认值。一个配置选项可以用相同的名称定义多次，但是每个定义只能有一个输入提示符，并且类型不能冲突。

每个条目都有自己的依赖项。这些依赖关系用于确定条目的可见性。任何子条目只有在其父条目也可见时才可见。

### 配置项属性

一个配置项可以有多种属性。并非所有属性都可以在任何地方都能使用(参见语法)。

- 类型定义： bool、tristate、string、hex、int

    每个配置选项必须有一个类型。只有两种基本类型: tristate、string，其他类型是基于这两种。bool 的取值为 y 或 n, tristate 的取值为 y/n/m；hex 为十六进制数字、可以省略 0x；

    类型定义的输入提示可选，以下两种方式等效：
    ```
    bool "Networking support"
    ```
    或者
    ```
    bool
    prompt "Networking support"
    ```

    大部分模块都有三种选择：

    - Y - 将该模块编译进内核
    - M - 将模块编译成外部模块
    - N - 不编译该模块

- 输入提示：“prompt” <prompt> [“if” <expr>]
  
    每个菜单项最多只能有一个提示符，用于显示给用户。可选地，使用 if 为提示添加可选的依赖项。

- 默认值：“default” <expr> [“if” <expr>]

    一个配置选项可以有任意数量的默认值。可以通过可选的 if 为该默认值添加依赖，只有依赖成立默认值才可见。如果多个默认值可见，则只有第一个定义的值有效。默认值并不局限于定义它们的菜单项。这意味着默认值可以在其他地方定义，也可以被先定义的覆盖。如果用户没有设置其他值，则配置项使用默认值。如果输入提示符是可见的，则默认值将呈现给用户，并且用户可以覆盖该值。

    默认值故意默认为 n，以避免使构建膨胀。除了少数例外，新的配置选项不应该改变这一点。这样做的目的是使oldconfig在每个版本之间尽可能少地添加配置。

    注意：
        应该使用 `default y/m` 的内容包括：
        a. 对于过去总是构建的东西，新的Kconfig选项应该是 "default y"。
        b. 新的隐藏/显示其它 Kconfig 选项的开关选项（不会生成任何代码），应为“default y”，以便人们会看到其他选项。
        c. 驱动程序的子驱动行为或类似选项应为 "default n"。这允许您提供明智的默认值
        d. 每个人都期望的硬件或基础设施，如 CONFIG_NET 或 CONFIG_BLOCK。这些都是罕见的例外。

- 类型定义+默认值
    ```
    "def_bool"/"def_tristate" <expr> ["if" <expr>]
    ```
    这是类型定义加值的速记符号。这个默认值的依赖项可以随 if 一起添加。

- 依赖: “depends on” <expr>
    这为这个菜单项定义了一个依赖项。如果定义了多个依赖项，则使用 `&&` 来连接它们。以下两种方式等效：
    ```
    bool "foo" if BAR
    default y if BAR
    ```
    和
    ```
    depends on BAR
    bool "foo"
    default y
    ```

- 反向依赖：“select” <symbol> [“if” <expr>] ？
    
- 弱反向依赖：“imply” <symbol> [“if” <expr>] ？


- 限位配置可见：“visible if” <expr>
  
    此属性仅适用于菜单块，如果条件为false，则不会向用户显示该菜单块(但是，其中包含的符号仍然可以由其他符号选择)。它类似于单个菜单项的条件提示属性。visible的默认值为true。

- 数值范围: “range” <symbol> <symbol> [“if” <expr>]
  
    这允许限制int和十六进制符号的可输入值的范围。用户只能输入一个大于或等于第一个符号，小于或等于第二个符号的值。

- 帮助文本: “help”
    
    定义一个帮助文本。帮助文本的结束由缩进级别决定，这意味着它在第一行结束，这一行的缩进比帮助文本的第一行小。

- 模块属性:  “modules” ？
    
    声明该符号用作 MODULES 符号，这为所有配置符号启用了第三种模块化状态。最多只能设置一个符号的modules 选项。


## 调试

经常用到的寻找配置：

1. 已知 make menuconfig 中有一个配置项，如何在在 Kconfig 中找到？进一步找到 Makefile 的作用点？
    焦点选中，按键 H 进入到该项的 Help 页面会显示详细的位置信息。
    或者使用 grep -nR <字符串> 搜索
    找到 Kconfig 后，一般作用于同一目录下的 Makefile 或者 C 文件。
2. 已知 Makefile 中使用到了一个配置，如何在 Kconfig 中找到？
    grep 同一目录下的 Kconfig 文件。


    
