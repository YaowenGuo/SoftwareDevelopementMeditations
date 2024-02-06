# 查看数据

- 查看栈内变量
frame

- 查看寄存器
rigieter

- 查看内存
memory

```
(lldb) memory read --size 4 --format x --count 4 0xbffff3c0
(lldb) me r -s4 -fx -c4 0xbffff3c0
```