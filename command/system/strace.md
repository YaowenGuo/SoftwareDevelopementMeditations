strace. Prints a trace of each system call invoked by a running program and its children. It is a fascinating tool for the curious student. Compile your program with -static to get a cleaner trace without a lot of output related to shared libraries.

> 追踪命令的执行过程

如果使用strace命令去跟踪执行git status命令时的磁盘访问，会看到延目录一次向上递归的过过程

$strace -e 'trace=file'  git status


strace

strace只能看syscall, malloc不是syscall而是c库，最后去call brk()/mmap()

https://www.jianshu.com/p/4ddf472226cc
https://blog.csdn.net/Danny_llp/article/details/120882548
