# VIM

VIM 和 emacs 是命令行的两大编辑器。 VIM 被称为神的编辑器，而 emacs 被称为编辑器之神。

默认模式，用于执行移动光标、删除、复制等命令。VIM 能加速编辑的操作都是定义在这里的。
插入模式: 编辑内容
命令模式: 用于执行保存、退出、搜索等高级命令（如 :wq）
视觉模式: (Visual mode)处理选中、块选中、块编辑等操作。

![VIM mode](images/vim_mode.png)

插入模式（Insert Mode）、普通模式（Normal Mode）和命令行模式（Command-line Mode）

```                 进入之后
                      ▽
        ESC/Ctrl+c    ▽      :
插入模式  ---------- 普通模式 ------------ 命令行模式
          i、a、o      ▽                    ▽
                    v/V/Ctrl+v          :wq 退出 vim
                      ▽                    ▽
                   视觉模式
```

**ESC 键通常不是这么好按，可以使用组合键代替：`Ctrl + c` 或`者 Ctrl + [`**



## 编辑模式

- i: insert。i 在光标所在字母之前插入，I 在当前行首插入。
- a: append。a 在光标所在字母后插入，A 在行末插入。
- o: 下一行插入一行。O 上一行插入一行。

- r: 替换。R 持续替换

- c: change， 删除同时进入插入模式 cw(change word), `ci)` 产出括号中的内容，开始输入。cc 删除一行同时保持缩进，同时进入插入模式。

## 视觉模式

v: 字符选择，可以移动光标选中。
V: 行选中，上下移动光标直接选中整行。
Ctrl + v: 块选中，移动光标选中一个矩形的块。


## 默认模式

### 定位

定位快捷键可以在普通模式和视觉模式下使用，可以在前面组合数据表示 n 个这样的操作。例如 2h 向左移动两个字符。2$ 移动下一行的末尾。**不带数字子的快捷键只是 1<字符>的简写。**

| 命令  | 作用                 |
| ---- | -------------------- |
| h    | 方向左键              |
| j    | 方向下键             |
| k    | 方向上键             |
| l    | 方向右键              |
| 0	  | 移至行首              |
| $	  | 移至行尾              |
| b   | Move to the beginning of the word |
| B   | Move to the beginning of blank delimited word |
| e   | Move to the end of the word |
| E   | Move to the end of Blank delimited word |
| w   | Move to next word |
| W   | Move to next blank delimited word |
| (   | The start of sentence |
| )   | The end of sentence.(End with.) |
| {   | Move to a paragraph forward |
| }   | Move to a paragraph back. |
| [	向后（向上）跳转到前一个特定文本边界（如代码块开头、注释起始等）。
| ]	向前（向下）跳转到下一个特定文本边界（如代码块结尾、注释结束等）。
| G   | Move to the last line of the file (1G/gg 到第一行) |
| nG  | Move to nth line of the file (or :n)|
| H   | Move to top of screen |
| M   | Move to middle of screen |
| L   | Move to bottom of screen |
| %   | Move to associated ( ), { }, [ ] |
| ctrl-f | Next page |
| ctrl-b | Backup page |
| ctrl-d |（down）可以向后翻半页 |
| ctlr-u |（up）可以向上翻半页。 |
| ctlr-] | 光标选中在一个 tag 上，跳转到子函数 |
| ctlr-o | 返回 |


**注意大写 G 和小写 g 的区别，大小 G 是前跟数字。而小写 g 是 goto 指令，后跟目标。**

### 后置命令

f: find 单个字符
s: search 多个字符


在 Vim 中，f、F、t 和 T 是用于在当前行内快速移动光标的快捷键，它们的区别主要在于查找方向和光标停留位置。

命令	方向	 光标停留位置	   示例（假设当前光标在行首）
f{char}	向前	直接停在目标字符上	行内容：Hello, world! → f, 光标停在 ,
t{char}	向后	直接停在目标字符上	行内容：Hello, world! → Fw 光标停在 w
| fc  | Move forward to c。 Find, 还有 T 也用于快速移动光标|
| Fc  | Move back to c |
| tc  | Move forward to c |
| Tc  | Move back to c |



#### 删除命令

| 命令       | 作用                    |
| --------- | ----------------------- |
| x	        | 删除光标所在处字符         |
| nx	    | 删除光标所在处后n个字符     |
| dd	    | 删除光标所在行，ndd删除n行  |
| dw        | 从光标处删除到一个单词的词末 |
| d$        | 删除当前光标到行末         |
| d3w       | 删除三行                  |
| 2dd       | 删除两行                  |
| :x,yd	    | 删除x开始到y结束的行,包括x,y行 |

此处可以观察到 操作+操作对象 的使用规则，通过后面的计数操作，功能会更加强大，即 操作+number+操作对象

复制和剪切命令

| 命令       | 作用              |
| --------- | ----------------- |
| yy,y	    | 复制当前行          |
| nyy,ny	| 复制当前行及以下共n行 |
| dd	    | 剪切当前行          |
| ndd	    | 剪切当前行及以下共n行 |
| p,p	    | 粘贴在当前行下或行上  |
| p,p	    | 粘贴在当前行下或行上  |


替换和取消命令

| 命令       | 作用              |
| --------- | ----------------- |
| r	        | 取代光标所在处字符   |
| r	        | 从光标所在处开始替换字符，esc结束 |
| u	        | 取消上一步操作      |

### 选中（View 也叫视觉模式）

v 键开始选中
V 直接选中一行。    



## 命令模式

### 打开新文件

:e <文件名> 打开一个新文件。旧文件并没有被关闭，而是在缓冲区里。
:ls 列出打开的文件
:b<编号> 回到文件。
:b <file name> 回到文件
:bn 切换下一个缓冲区
:bp 切换上一个缓冲区

:vs <file>  再打开一列打开新文件。
control + w 再按一下 


| 命令       | 作用         |
| --------- | ------------ |
| :set nu   | 显示行号      |
| :set nonu	| 取消行号      |

搜索和替换命令

- /string : 向前搜索指定字符串
- ?string : 向后搜索。搜索时忽略大小写:set ic
    n: 搜索指定字符串的下一个出现位置，N: 往前找
    :nohl 取消高亮
- :s/old/new/g	s 前加 `%` 全文替换指定字符串，不加只替换当前行，g,替换不询问，c，每次替换都询问确认
- :x,ys/old/new/g	替换x行到y行的所有字符串，g: 替换不询问，c: 每次替换都询问确认

保存退出

| 命令       | 作用              |
| ----------| ----------------- |
| ZZ 或者 :wq| 保存退出           |
| wq!	    | 写入，附加!，强制。只有所有者或root才能使用。 如果忘记  root 打开，可以使用指令 :w !sudo tee %|
| q!	    | 退出，不保存       |
| w	        | 仅写入            |

- :r 文件名	将其他文件到导入到当前文件
- !命令	直接在vi中执行系统命令，:r  !命令，将命令执行的结果导入到文件
- :map 快捷键　触发命令	:map ^p 1#<ESC>
- :map ^B 0x


可以直接执行make族命令，在运行make命令前一定要设置autowrite,vim 可以自动保存文件。