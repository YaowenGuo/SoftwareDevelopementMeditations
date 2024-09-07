# Gn 最小配置

更多文档可以查看 https://gn.googlesource.com/gn/+/master/docs/language.md
一个 PPT,有点老，不过可以用 https://docs.google.com/presentation/d/15Zwb53JcncHfEwHpnG_PoIbbzQ3GQi_cpujYwbpcbZo/edit#slide=id.g1199fa62d0_1_63


[一个 GN 构建项目至少包括：](https://gn.googlesource.com/gn/+/master/docs/standalone.md)

```
.
├── BUILD.gn               # 编译入口点
├── .gn                    # .gn 项目根编译配置。指定配置文件目录地方，就是这个文件指定了。有该文件的目录被作为项目根目录。 ‘build/BUILDCONFIG.gn’ 作为配置文件。
├── build                  # 配置目录，必须有
│   ├── BUILD.gn
│   ├── BUILDCONFIG.gn     # 主构建配置文件，必须有
│   └── toolchain
│       └── BUILD.gn
├── 代码
|  ...
```

1. 首先加载 `<输出目录>/args.gn` 该文件会在首次构建是生成，将 `--args` 指定的参数保存在其中。以便此后更改和加载。

2. gn 首先执行 `.gn` 进行配置
  - 根据 .gn 中的指定顺序，执行 `import` 和 `buildconfig` 中的内容。
  - `//build/config/BUILDCONFIG.gn` 文件可能会在运行中执行多次。从未改变了 `current_os` 的值。
  - `.gn` 也是作为项目的根目录，在子目录中执行 `gn` 指令会递归向外寻找该文件，并将其目录作为运行的根目录。
  - 在子目录中添加 `.gn` 文件, 将会是子目录作为一个项目配置独立的构建。这有一些好处和坏处，需要格外注意。 如果你这样文件的子目录，但是又不想使用（想使用根项目的配置），可以使用 `--root` 和 `--dotfile` 设置想要的。

3. 然后进入 `BUILD.gn` 开始构建。

4. 定义 toolchain 的单独文件。将不同平台的 toolchain 分为单独的文件定义有诸多好处，Chrome 将其放在 `//build/toolchain/<platform>/BUILD.gn` 中。


### .gn

.gn 是项目的根配置文件。

```
# 指定配置文件所在的位置，必须要。
buildconfig = "//build/BUILDCONFIG.gn"

# 指定 gn 脚本的指定环境
script_executable = "python3"
```

## 编译类型

编译的类型有可执行程序和库(共享库、静态库)。分别对应于：

```
# 创建可执行程序
executable("tutorial") {
  sources = [
    "tutorial.cc",
  ]
}

# 编译为共享库
shared_library("tutorial") {
  # 执行代码。
  sources = [
    "hello_shared.cc",
    "hello_shared.h",
  ]
}

# 编译为静态库
static_library("tutorial") {
  sources = [
    "hello_static.cc",
    "hello_static.h",
  ]
}
```

gn 内置了许多构建类型，可以根据需要选择：

Built-in target types
- executable, shared_library, static_library
- loadable_module: like a shared library but loaded at runtime
- source_set: compiles source files with no intermediate library

- group: a named group of targets (deps but no sources)
- copy
- action, action _foreach: run a script
- bundle_data, create_bundle: Mac & iOS


Common Chrome-defined ones
- component: shared library or source set depending on mode
- test
- app: executable or iOS application + bundle
- android_apk, generate_jni, etc.: Lots of Android ones!


### 如何设置默认的构建目标

**在根构建文件中声明一个名为 `“default”, ` 的 group target，GN 就会将其作为 `Ninja` 的默认构建目标，而不是构建所有的目标。**
Can I control what targets are built by default?
Yes! If you create a group target called “default” in the top-level (root) build file, i.e., “//:default”, GN will tell Ninja to build that by default, rather than building everything.

### 查看构建目标

如果你并不知道有哪些构建目标呢？可以使用如下指定查看构建目标

```
$ gn ls out/test
enable_teleporter is true
//:hello
//:hello_shared
//:hello_static
//:tools
//tutorial:tutorial

```

也可以过滤部分目标。它支持一些有限的模式匹配，也支持按类型过滤。

```
$ gn ls out/Default “//base/*”
//base:base
//base:base_i18n_perftests
//base:base_i18n_perftests_run
//base:base_paths
//base:base_perftests
//base:base_perftests_run
//base:base_static
//base:base_unittests
```



### 编译参数

可以向目标添加各种编译器配置设置。这些将应用于目标中文件。

```
executable(“doom_melon”) {
  sources = [ “doom_melon.cc” ]

  cflags = [ “-Wall” ]
  defines = [ “EVIL_BIT=1” ]
  include_dirs = [ “.” ]

  deps = [ “//base” ]
}

```



## 构建

gn 构建目录可以随意指定，而不限制构建类型，例如是 release 还是 debug，必须通过另外增加参数指定。

`gen` 子命令用于生成 `ninja` 编译脚本。 如生成 ninja 脚本到 `out/test`

```
gn gen out/test
```
`--args="[]"` 用于添加参数

例如：

```
gn gen out/test --args='target_os="linux" target_cpu="x64"'
```
GN 能够生成不同构建版本，这些版本通过构建参数控制。GN 的构建参数保存在构建目录中，而不是全局地在构建系统中。可以根据需要通过构建参数在不同目录构建不同的版本。

You can set variables in that file:

- The default is a debug build. To do a release build add is_debug = false
- The default is a static build. To do a component build add is_component_build = true
- The default is a developer build. To do an official build, set is_official_build = true
- The default is Chromium branding. To do Chrome branding, set is_chrome_branded = true

### 清理

```
gn clean out/test
```


## 依赖

添加依赖可以在任何 `executable`、`execshared_libraryutable`、`static_library`的作用域内使用 `deps` 数组，如 `executable`

```
executable("hello") {
  sources = [
    "hello.cc",
  ]

  deps = [
    ":hello_shared",
    ":hello_static",
  ]
}
```

以 `:` 开头的表示当前文件的构建目标。

依赖可以指定不同的目录，使用 `//` 表示项目的根目录（即 .gn 所在的目录），用于区分系统根。例如 `//chrome/browser:version`，寻找 `chrome/browser/BUILD.gn` 中的 `version` 库。

当 `BUILD.gn` 仅有一个和目录同名的构建目标时，可以使用缩写。例如 `//base` 代替 `//base:base`。


### 运行时依赖

一些测试需要在运行时加载数据，或者一些目标的构建仅需要某些依赖存在即可，而不被任何构建步骤所需要，例如链接时。

`data` 和 `data_deps` 为了自动开关被划分为独立的系统。当测试版本分发时，数据文件和依赖也会自动被分发。



## group

在GN中，组只是没有编译或链接的依赖项的集合

```
group("tools") {
  deps = [
    # This will expand to the name "//tutorial:tutorial" which is the full name
    # of our new target. Run "gn help labels" for more.
    "//tutorial",
  ]
}
```


## config

默认情况下，每个构建目标都有一些适用于的构建设置。 这些设置通常默认配配置列表。 可以使用 “print” 命令查看此信息，这对于调试非常有用：

```
executable("hello") {
  ...
  print(configs)
  deps = [
    # Apply ICU’s public_configs.
    “:icu”,
  ]
}

config(“icu_dirs”) {
  include_dirs = [ “include” ]
}


shared_library(“icu”) {
  public_configs = [ “:icu_dirs” ]

  configs = [
    defines = [ “EVIL_BIT=1” ]
  ]
}

```
`public_configs` 同时应用于当前目标以及依赖于它的目标。

In this case, ICU may require additional include directories for its headers to work. All targets that depend on ICU will need to get this include directory.


```
$ gn gen out
["//build:compiler_defaults", "//build:executable_ldconfig"]
Done. Made 5 targets from 5 files in 9ms
```

也可以在用字符串中格式化变量。 它使用符号 "$" 来引用变量：
```
print("The configs for the target $target_name are $configs")
```

### 添加自定义配置

除了系统内置的，我们也能添加自定义的配置。

```
config("my_lib_config") {
  defines = [ "ENABLE_DOOM_MELON" ]
  include_dirs = [ "//third_party/something" ]
}
```

要将配置的设置应用于目标，只需将其添加到 `configs` 列表中：

```
static_library("hello_shared") {
  ...
  # Note "+=" here is usually required, see "default configs" below.
  configs += [
    ":my_lib_config",
  ]
}
```

通过将配置的标签放在public_configs列表中，可以将配置应用于依赖于当前配置的所有目标：

```
static_library("hello_shared") {
  ...
  public_configs += [
    ":my_lib_config",
  ]
}
```

公共配置也适用于当前目标，所以没有必要在这两个地方列出配置。

## 条件和表达式

条件语句类似于 C，

```
if (is_linux || (is_win && target_cpu == "x86")) {
  sources -= [ "something.cc" ]
} else if (...) {
  ...
} else {
  ...
}
```

此外还要循环和

#### 表达式

例如添加和删除配置，可以使用 `+=`、`-=` 分别添加和删除配置。

```
executable("hello") {
  ...
  configs -= [ "//build:no_exceptions" ]  # Remove global default.
  configs += [ "//build:exceptions" ]  # Replace with a different one.
}
```

查看有哪些系统 `config` 可用，可以查看项目中配置文件 `build/BUILD.gn` 的 `config` 命令定义的配置。


## 构建参数

gn 可以任意指定构建目录，那如何区分 Debug版本和Release版本呢？GN通过传递参数来解决。也就是说，现在只通过输出目录是无法确定到底是Debug版本和Release版本，而要取决于传递的构建参数。使用如下命令参加参数。
构建参数用于指定 gn 构建脚本可以配置的部分。例如目标平台，调试或者release。

```shell
$ gn gen out --args='target_os="mac"'
```

构建参数会在输出目录生成 `args.gn` 文件。例如上面的命令生成在 `out/args.gn` 文件。
```
# out/args.gn
target_os = "mac"
```

虽然知道在 `args.gn` 目录下，但是 out 目录是输出目录，最好不要直接编辑。你可以使用 gn args 命令生成。

```shell
$ gn args out
```

该指令会直接打开一个编辑器，用于编辑。你可以以键值对的方式添加构建参数。添加的格式是：

```
<key> = <value>
```

如：

```
is_debug = false
```

如果你不知道有哪些参数可以使用，可以使用下面的命令列出可用的构建参数和它们的缺省值：

```shell
$ gn args --list out
```

### 自定义构建参数

如果你在自己编写构建脚本时，除了系统的构建参数外，也可以自定义构建参数。使用 declare_args 命令在 `BUILD.gn` 文件中添加

```c
declare_args() {
  enable_teleporter = true
  enable_doom_melon = false
}

if (enable_teleporter) {
  print("enable_teleporter is true")
} else {
  print("enable_teleporter is false")
}
```

这里使用 `enable_teleporter` 控制输出的内容。除了这里设置的默认值，你还可以使用 `gn gen out --args=XXX` 命令行或者 `gn args out` 命令覆盖 `BUILD.gn` 的默认值。其优先级为

```
--args=XXX 命令参数  >  args.gn 文件 >  BUILD.gn 的默认值
```

需要说明的是，指定 `--args` 参数形式会覆盖 `args.gn` 文件，如果不添加 `--args` 参数则不会覆盖 `args.gn` 文件。

### 为项目设置默认构建参数

`declare_args` 是一个构建中的默认值。`args.gn` 是指定构建时设置的临时值。加入项目中使用的一个库的参数默认值不符合要求，而对于项目来说，又期望有一个默认值，使所有人构建在不指定参数时，都保持一致如何设置呢？

可以在项目根配置 `.gn` 文件中使用 `default_args`设置。

```
default_args = {
  is_component_build = false

  mac_sdk_min = "10.12"
}
```

### 共享变量

Shared variables are put in a *.gni file and imported.

```
declare_args() {
  # Controls Chrome branding.
  is_chrome_branded = false
}

enable_crashing = is_win
```

```
import(“//foo/build.gni”)

executable(“doom_melon”) {
  if (is_chrome_branded) {
    …
  }
  if (enable_crashing) {
    …
  }
}
```

An imported file can have declare_args, or regular variables.

在本例中导入 `buid.gn` 将在当前文件中引入两个变量:一个(is_chrome_branded)可能被用户覆盖，另一个(enable_crashing)是常量。




### args 的覆盖顺序

在 `.gn`  文件中先定义了 `config`



## 定义宏

构建目标的作用域内可以使用 `defines` 定义源码中要使用的宏。如

```c
shared_library("hello_shared") {
  sources = [
    "hello_shared.cc",
    "hello_shared.h",
  ]

  defines = [
    "HELLO_SHARED_IMPLEMENTATION",
    "ENABLE_DOOM_MELON=0",
  ]
}
```

参数设置

```
gn help defines
...

gn gen out/arm64 defines = [ "AWESOME_FEATURE", "LOG_LEVEL=3" ]
```

## 构建流程如何？

如果你想要查看构建的详细流程，可以在详细模式下运行 gn，以查看有关其操作的大量消息。 为此使用 `-v` 参数。


### desc 子命令

您可以运行 `gn desc <build_dir> <targetname>`来获取有关给定目标的信息，其中 `build_dir` 必须制定，因为标志和有效目标都依赖于输出目录的配置（因为 gn 可以输出任意的构建目录）。

```
$ gn desc out //:hello
$ gn desc out //tutorial:tutorial
```

deps 打印给定目标的所有信息。如果想要展示某一项，可以在命令行添加参数。假设您想知道您的 `HELLO_SHARED_IMPLEMENTATION` 定义来自 `hello_shared` 目标的宏定义位置，需要添加  `defines` 参数：

```
$ gn desc out //:hello_shared defines --blame
...lots of other stuff omitted...
From //:hello_shared
  HELLO_SHARED_IMPLEMENTATION
```

`--blame` 查看具体如何定义的。


查看依赖树需要 `deps` 参数，使用 `--tree` 标志将导致任何依赖项以树的形式打印出来，如下所示

```
$ gn desc out //:hello deps --tree
//:hello_shared
//:hello_static
```

`cflags` 查看编译参数， 还有 `defines`、`include` 等。有关更多信息，请参见 `gn help desc`。


### 依赖路径

可以使用 `gn path` 来查找目标之间的依赖路径。这可以回答为什么某些东西依赖于其他东西，或者公共依赖路径在哪里被破坏。

```
$ gn path out/Default //content/browser //cc/base:base
       //content/browser //cc/base
//content/browser:browser --[private]-->
//cc:cc --[private]-->
//cc/base:base

Showing one of 118 unique non-data paths.
0 of them are public.
Use --all to print all paths.

```

公共依赖除了传递配置外，还传递包含头的能力。

In this case, you can see there are no public paths because //cc depends privately on //cc/base. So content/browser can’t use cc/base’s headers. If a file in content/browser includes a file from //cc/base, “gn check” will throw an error. You’ll either need to add an explicit dependency or make the private dependency public.

Use --all to see all of them. Watch out, there are too many paths between chrome and base to hold in memory!


### 被依赖的组件

deps 查看依赖哪些组件，refs 则是查看被哪些组件依赖。

```
> gn refs out/Default //cc
//ash:ash
//ash/mus:lib
//blimp/client:blimp_client
...


> gn refs out/Default //cc --tree
//media/blink:blink
  //media/blink:media_blink_unittests
    //media/blink:media_blink_unittests_run
...


> gn refs out/Default //base/macros.h
//base:base
```

In the third example it shows passing a source file name. GN will find the target or targets that list that file in the sources.

还可以查询生成的问题是由哪个目标生成的。例如 `out/arm64/obj/rtc_base/base_java__errorprone.errorprone.stamp` 文件中在 mac 构建中找不到，但是 linux 中能够正确生成，想要查看是如何生成的，可以在 linux 上执行。

```
$ gn refs out/arm64 out/arm64/obj/rtc_base/base_java__errorprone.errorprone.stamp
//rtc_base:base_java__errorprone
```


### 文件依赖检测

check 可以分析源文件的导入依赖，运行“ gn check”将打开源文件，扫描包含文件，并验证它们是否与依赖关系图匹配。仅检测 .gn 中 `check_targets`列出的白名单目录的内容。



## 构建流程

构建有哪些默认标志，他们是如何被设置的？让我们看看整个流程.

1. 当 `gn` 执行时，递归向上查找 `.gn` 文件，改目录作为项目的根目录。并且解析 `.gn` 文件的配置。

2. 加载 `.gn` 中 `buildconfig` 设置的 `BUILDCONFIG` 文件，此时运行环境设置完成。其它所有文件的执行都拷贝一个独立的执行环境。这意味着，在 `BUILDCONFIG` 中设置的变量是全局的并且隐式的在所有 `BUILD` 文件中有效。


所有BUILD文件都以未定义的顺序并行运行。 这意味着目标除了标签以外不能引用其他任何东西（因为它可能尚未加载）。

在 `例如，BUILDCONFIG` 中设置的变量

```
is_linux = host_os == "linux" && current_os == "linux" && target_os == "linux"
is_mac = host_os == "mac" && current_os == "mac" && target_os == "mac"
```

例如，BUILDCONFIG 文件适用于设置每种目标类型的默认 configs。

```
# All binary targets will get this list of configs by default.
_shared_binary_target_configs = [ "//build:compiler_defaults" ]

# Apply that default list to the binary target types.
set_defaults("executable") {
  configs = _shared_binary_target_configs

  # Executables get this additional configuration.
  configs += [ "//build:executable_ldconfig" ]
}
set_defaults("static_library") {
  configs = _shared_binary_target_configs
}
set_defaults("shared_library") {
  configs = _shared_binary_target_configs
}
set_defaults("source_set") {
  configs = _shared_binary_target_configs
}
```
这将为每个目标预填充 configs 变量。

可以在 `BUILD.gn` 文件中打印设置的内容

```
executable("hello") {
  print(configs)
  ...
}
```

```
$ gn gen out/Default
["//build:compiler_defaults", "//build:executable_ldconfig"]
...
```


## 模板和 Action

模板用于创建新的目标类型。

```
template(“grit”) {
  …
}

grit(“components_strings”) {
  source = “components.grd”
  outputs = [ … ]
}

```

可以编写自定义目标类型，这些目标类型可以展开来执行自定义操作。当你有一个脚本被多次调用时，编写一个模板来抽象调用脚本的细节是一个好主意。

通常会在 `.gni` 文件中实现模板，以便可以在许多地方使用它。更多文档可以查看 `gn help template`。

### Action

Action 用于运行 python 脚本。

```
action(“myaction”) {
  script = “myscript.py”
  inputs = [ “myfile.txt” ]
  outputs = [
    …
  ]
}
```

`script` 用于指定脚本文件。 input 是脚本依赖的文件，output 是脚本产生的文件。Ninja 将使用这些文件来计算 action 是否需要更新。

GN将阻止您将输出文件写入源目录。 您必须将其放在构建目录中的某个位置。

```
action(“myaction”) {
  script = “myscript.py”
  inputs = [ “myfile.txt” ]
  outputs = [
    “generated.txt”,  # Error!
    target_out_dir + “/generated.txt”,
  ]
  args = [
    “-i”,
    rebase_path(inputs[0],
                root_build_dir)
    rebase_path(outputs[0],
                root_build_dir)
  ]
}

```
target_out_dir 是内建的指定构建目录的变量。

Args are what is passed to the script. GN doesn’t pass inputs or outputs to the script automatically. You have to specify 100% of what gets passed in the “args” variable.

rebase_path 函数将第一个参数转换为相对于第二个参数的文件路径。

通常，您使用rebase_path来创建相对于root_build_dir的路径，root_build_dir是所有脚本调用的工作目录。 这将是您传递给“ gn gen”的构建目录。



### action_foreach

action_foreach runs a script over each source.

```
action_foreach(“process_idl”) {
  script = “idl_compiler.py”
  inputs = [ “static_input.txt” ]
  sources = [
    “a.idl”,
    “b.idl”,
  ]

    outputs = [
    “$target_gen_dir/{{source_name_part}}.h”
  ]
  args = [
    “--input={{source}}”
  ]


```

action_foreach will generate many script calls, one for each element of the sources array.

The “inputs” are files required by the script for each invocation, the “sources” are what will be iterated over.

To make action_foreach work, there are some magic patterns that can be used in the outputs and args that expand to various components of the current source file name.

Here, we generate an output file name based on the source file name in the generated file directory and with a different extension.

All of the possibilities are discussed in “gn help”
