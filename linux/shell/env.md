# shell 变量

## 定义和使用

shell 中的变量定义和使用不同，使用的时候必须用 `$` 前缀标识，表示获取一个变量的内容，否则杯认为一个字符串。

```shell
# 定义, ```等号两侧不能使用空格分割```，否则会被当成一个命令。
name='value'

# 使用
echo $name

```

变量的值都是字符串型的，即使是数字。如果有空格，则需要使用引号括起来，单引号和双引号都行，但一定要配对。


## 环境变量

在这里首先说一下环境变量和普通 `shell` 变量的区别：

shell中的变量使用 `变量名=值` 定义后就可以直接使用了。而要想成为环境变量，即允许子进程（在当前环境中启动的程序或脚本）中使用该变量，需要使用 `export` 关键字导出。

```shell
export $<变量名>
```

或定义的同时导出

```shell
export 变量名=值
```


## set，env和export这三个命令的区别

- `declare` 同 `set` 一样, 显示当前 `shell` 的变量，包括当前用户的变量;

- `env` 命令显示当前用户的变量;

- `export` 命令显示当前导出成用户变量的shell变量。


　　每种(bash/zsh/sh) `shell` 有自己特有的变量（set 显示的变量)，这个和用户变量是不同的，当前用户变量和你用什么 `shell` 无关，不管你用什么 `shell` 都在，比如HOME,SHELL等这些变量，
　　但shell自己的变量不同shell是不同的，比如BASH_ARGC，BASH等，这些变量只有set才会显示，是bash特有的，export 不加参数的时候，显示哪些变量被导出成了用户变量，因为一个shell 自己的变量可以通过export “导出”变成一个用户变量。


### 使用 `env` 命令显示环境变量（可能包换不同 `shell` `export` 的变量）

```shell
$ env
```


### 使用set命令显示所有本地定义的Shell变量

```shell
$ set 
```

使用 `unset` 命令来清除环境变量

set可以设置某个环境变量的值。清除环境变量的值用 `unset` 命令。如果未指定值，则该变量值将被设为NULL。示例如下：

```shell
$ export TEST="Test..." #增加一个环境变量TEST

$ env | grep TEST #此命令有输入，证明环境变量TEST已经存在了

TEST=Test...

$ unset TEST #删除环境变量TEST，注意变量前没有$。

$ env | grep TEST #此命令没有输出，证明环境变量TEST已经存在了
```

### 使用 `readonly` 命令设置只读变量

如果使用了 `readonly` 命令的话，变量就不可以被修改或清除了。示例如下：

```shell
$ export TEST="Test..." #增加一个环境变量TEST

$ readonly TEST #将环境变量TEST设为只读

$ unset TEST #会发现此变量不能被删除

-bash: unset: TEST: cannot unset: readonly variable

$ TEST="New" #会发现此也变量不能被修改

-bash: TEST: readonly variable
```


## Linux的变量种类

按变量的生存周期来划分，Linux变量可分为两类：

1. 永久的：需要修改配置文件 expoort 的，变量永久生效。

2. 临时的：在 bash 终端中或者在文件中没有 `export` 的，变量在关闭shell，或者脚本执行完时失效。



## 作用域

Linux下环境变量设置的三种方法：

添加或者修改变量是有一定得作用域得，如想将一个路径加入到 `$PATH` 中，可以像下面这样做：

1、控制台中设置，（适用于使用别人的电脑完成一些工作），因为他只对当前的shell 起作用，换一个shell设置就无效了：

```bash
$export PATH="$PATH":/NEW_PATH  (关闭shell Path会还原为原来的path)
```


2、修改 `/etc/profile` 文件，如果你的计算机仅仅作为开发使用时推存使用这种方法，因为所有用户的shell都有权使用这个环境变量，可能会给系统带来安全性问题。这里是针对所有的用户的所有shell修改。

在 `/etc/profile` 的最下面添加： `export  PATH="$PATH:<NEW_PATH>"`


注：修改文件后要想马上生效还要运行 `source /etc/profile` 不然只能在下次重进此用户时生效。



3、修改 `~/.bashrc` 文件，这种方法更为安全，它可以把使用这些环境变量的权限控制到用户级别，由于在用户目录下，其他用户并没有这个变量，或者可以不同。

在下面添加：

```shell
Export  PATH="$PATH:<NEW_PATH>"
```

这里需要注意用户下面的 配置可能根据使用的 `shell` 不同而使用不同的配置文件，如 `bash` 使用 `.bash_profile` 和 `.bashrc`。而 `zsh` 使用 `.zshrc`。


## `.bash_profile` 和 `.bashrc` 区别

- 当shell是登录时，会读取.bash_profile文件，如在系统启动，远程登录或使用 `su -` 切换用户时;

- 当 `shell` 是交互式非登录启动时，都会读取 .bashrc 文件，如在图形界面中打开终端，或bash shell调用另一个bash shell时。均属于非登录的情况。

一般来说都会在 .bash_profile 里调用 .bashrc 脚本以便统一配置用户环境。


4.常用的环境变量

```
PATH 决定了shell将到哪些目录中寻找命令或程序

HOME 当前用户主目录

HISTSIZE　历史记录数

LOGNAME 当前用户的登录名

HOSTNAME　指主机的名称

SHELL 　　当前用户Shell类型

LANGUGE 　语言相关的环境变量，多语言可以修改此环境变量

MAIL　　　当前用户的邮件存放目录

PS1　　　基本提示符，对于root用户是#，对于普通用户是$
```


## 疑点解析

### shell 与 export命令

用户登录到Linux系统后，系统将启动一个用户shell。在这个shell中，可以使用shell命令或声明变量，也可以创建并运行 shell 脚本程序。运行shell脚本程序时，系统将创建一个子shell。此时，系统中将有两个shell，一个是登录时系统启动的shell，另一个是系统为运行脚本程序创建的 shell。当一个脚本程序运行完毕，它的脚本shell将终止，可以返回到执行该脚本之前的shell。从这种意义上来说，用户可以有许多 shell，每个shell都是由某个shell（称为父shell）派生的。
 
如果在一个shell脚本程序中定义了一个变量，当该脚本程序运行时，这个定义的变量只是该脚本程序内的一个局部变量，其他的shell不能引用它，要使某个变量的值可以在其他 shell 中被改变，可以使用export命令对已定义的变量进行输出。 export 命令将使系统在创建每一个新的shell 时定义这个变量的一个拷贝。这个过程称之为变量输出。




## source命令：

source命令(从 C Shell 而来)是bash shell的内置命令;也称为点命令(.，从Bourne Shell而来)，两者是等价的。

用法：

```shell
source filename 或 . filename
```

功能：使 `Shell` 读入指定的 `Shell` 程序文件并依次执行文件中的所有语句
source命令通常用于重新执行刚修改的初始化文件，使之立即生效，而不必注销并重新登录。


source filename 与 bash filename 及 ./filename 执行脚本的区别在那里呢？

1. `bash filename` 与 `./filename` 执行脚本是没有区别的。`./filename` 是因为当前目录没有在PATH中，所以 "." 是用来表示当前目录的。
2. `bash filename` 重新建立一个子shell，在子 `shell` 中执行脚本里面的语句，该子 shell 继承父 shell 的环境变量，但子 shell` 新建的、改变的变量不会被带回父shell，除非使用 `export` 。
3. `source filename` 这个命令其实只是简单地读取脚本里面的语句依次在当前 shell 里面执行，没有建立新的子 shell。那么脚本里面所有新建、改变变量的语句都会保存在当前shell里面。


举例说明：

1. 新建一个test.sh脚本，内容为:A=1
2. 然后使其可执行chmod +x test.sh
3. 运行sh test.sh后，echo $A，显示为空，因为A=1并未传回给当前shell
4. 运行./test.sh后，也是一样的效果
5. 运行 source test.sh 或者 . test.sh，然后echo $A，则会显示1，说明A=1的变量在当前shell中。
