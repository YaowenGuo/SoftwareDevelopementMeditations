# Kernel 构建系统

输出内核与模块符号
输出内核头文件，用户头文件
编译 dts 设备树文件
安装编译生成的文件到系统
....
可以说 Kbuild 系统几乎覆盖了整个内核的配置、编译、安装、系统裁剪等等。

随着内核的发展，Linux 支持的平台越来越多，结构越来越复杂，Make 已经无法完全支持 Linux 内核的构建。为了能够简单的构建、支持交叉编译，Linux 对 Make 进行了扩展、发展出来 Linux 内核的构建系统 Kbuild。简单来说，Kbuild 是 make 的一个扩展。

Linux 构建系统包含五部分
```
Makefile                    the top Makefile.
.config                     the kernel configuration file.
arch/$(SRCARCH)/Makefile    the arch Makefile.
scripts/Makefile.*          common rules etc. for all kbuild Makefiles.
kbuild Makefiles            exist in every subdirectory
```

- 顶层的 Makefile 读取 `.config` 文件，该文件由内核配置流程生成。

- 顶层的 Makefile 主要负责构建两种产物：vmlinux(常驻内核映像) 和模块（任何模块文件）。它递归进入到内核源代码树的子目录来构建这些目标。

- 访问的子目录列表取决于内核配置。顶层的 Makefile 使用 `arch/$(SRCARCH)/Makefile` 路径显式的导入体系结构的 Makefile。体系结构的 Makefile 向顶层 Makefile  提供特定于体系结构的信息。
  
- 每个子目录都有一个kbuild Makefile，它执行从上面传递下来的命令。kbuild Makefile 使用来自 .config 文件的信息来构造 kbuild 用来构建任何内置或模块化目标的各种文件列表。

- scripts/Makefile.* 包含通用的规则等，其用于基于 kbuild makefiles 文件构建内核。不同的后缀表示不同的类型，例如 `Makefile.clean` 定义了清理工作，`Makefile.lib` 用于编译库文件。`Makefile.host` 编译主机的辅助脚本程序的。

## 各自的职责

根据使用内核的场景，开发人员的需要了解内核构建系统的不同程度可以分为四种：

- **用户** 即构建内核的人。这些人使用如 `make menuconfig`、`make` 等命令。他们通常不阅读或编辑任何内核 Makefiles (或任何其他源文件)。

- **普通开发人员** 是从事设备驱动程序、文件系统和网络协议等功能的人员。这些人需要为他们正在开发的子系统维护 kbuild Makefiles。为了有效地做到这一点，他们需要对内核 Makefiles 有一些全面的了解，加上对kbuild 公共接口的详细了解。

- **Arch开发人员** 是在整个体系结构上工作的人，比如sparc或x86。Arch开发人员需要了解体系结构的 Makefile 和 kbuild Makefiles。

- **Kbuild开发人员** 是从事内核构建系统本身工作的人。这些人需要了解内核 Makefiles 的所有方面。

本文档主要面向普通开发人员和 Arch 开发人员。
