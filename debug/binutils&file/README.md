# binutils

- [addr2line](addr2line.md): 调试用，给定地址和带调试信息的可执行文件，通过其中的调试信息得到地址有关联的源文件和行号
- ar: 创建、修改和提取归档
- cxxfilt: 符号名还原工具
- install-name-tool:  - LLVM tool for manipulating install-names and rpaths
- [nm](nm.md): 列出给定对象文件中出现的符号
- objcopy: 目标复制和编辑工具
- [objdump](objdump.md): 打印输出目标（二进制）文件，反汇编
- ranlib: 创建一个归档的内容索引并存储在归档内；索引列出其成员中可重定位的对象文件定义的所有符号
- [readelf](readelf.md): 显示有关 ELF 二进制文件的信息
- size: 列出给定对象文件每个部分的尺寸和总尺寸，代码段、数据段、总大小等。
- strings: 对每个给定的文件输出不短于指定长度 (默认为 4) 的所有可打印字符序列；对于对象文件默认只打印初始化和加载部分的字符串，否则扫描整个文件
- strip: 移除对象文件中的符号,进行文件压缩

LLVM 提供了一套同样功能的替代程序，名字增加了 `llvm-` 前缀。这里使用 llvm 项目的 binutils, 文档 https://llvm.org/docs/CommandGuide/llvm-readelf.html。LLVM 的 binutils 输出不同平台的文件输出格式不同。例如输出 ELF 的 文件头。

The `objdump` program is just one of many tools you should learn how to use; a debugger like `gdb`, memory profilers like `valgrind` or `purify`, and of course the `compiler` itself are others that you should spend time to learn more about;

其中 `addr2line`, `nm`, `dwarfdump` 都依赖于调试信息。

## 其它：

- [elf 文件格式](elf.md)
- [dwarfdump](dwarfdump.md)

memory profilers like valgrind or purify


C++ 符号转成原始名称

```
c++filt -n <samble>
nm your_object_file | c++filt
```