# 配置脚本 configure

在使用make编译源代码之前，configure会根据自己所依赖的库而在目标机器上进行匹配。

configure 的脚本文件约定使用 `configure` 命名，放在库的根目录下，一般是一个 shell 脚本，用于根据所在的系统环境生成 `Makefile` 文件。

有时候我们使用 `GNU build system` 帮助生成 `configure` 脚本，该工具就是 `Aototools`。

Autotools包含的命令有autoconf，automake，libtool。

configure 参数解释: https://blog.csdn.net/sunjing_/article/details/79146827
