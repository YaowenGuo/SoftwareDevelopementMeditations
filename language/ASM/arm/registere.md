# 寄存器

```
R：Register；寄存器
PC：Program Counter；程序计数器
CPSR：Current Program Status Register；当前程序状态寄存器
SPSR：Saved Program Status Register；保存的程序状态寄存器
SP：Stack Pointer；数据栈指针
LR：Link Register；连接寄存器
SB：静态基址寄存器
SL：数据栈限制指针
FP：帧指针
IP：Intra-Procedure-call Scratch Register；内部程序调用暂存寄存器
```

ARM共有37个寄存器，可以工作在7种不同的模式。以下根据上图进行分类的说明：

<待添加图片>


[寄存器](https://blog.csdn.net/weixin_42135087/article/details/111263720)

ARM32 的寄存器
![ARM32 Register](images/register)

在 armv7 上PC是一个通用寄存器R15，在armv8上 PC 不再是一个寄存器，它不能直接被修改。必需使用一些隐式的指令来改变，如 PC-relative load

## 特殊寄存器

WZR/XZR
寄存器r31是一个特殊的寄存器：
Zero Register: 在大多数情况下，作为源寄存器使用时， r31读出来的值 是0; 作为目标寄存器使用时， 丢弃结果。 WZR(word zero rigiser)或者XZR(64位）

```
mov	w0, wzr
```
