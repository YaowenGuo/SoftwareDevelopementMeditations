# 文件

UNIX 系统中除进程之外的一切皆是文件，而 Linux 保持了这一特性。

## Directory Structure

为了便于管理文件，便引入了目录的概念，目录使文件可被分类管理，且目录的引入使 Unix 的文件系统形成一个层级结构的目录树。Linux 上的文件是以目录树如下：

```
/              # 跟目录
|-- boot       # 启动目录
|-- dev        # 存放设备文件
|-- etc        # 存放系统配置文件
|-- home       # 用户目录
|-- media      # 可卸载存储介质挂载点
|-- mnt        # 文件系统临时挂载点
|-- opt        # 附加的应用程序包
|-- proc       # Linux 上的虚拟文件系统，用于访问内核的各种信息。
|-- root       # root 用户主目录
|-- run
|-- srv        # 存放服务相关数据
|-- sys        # sys 虚拟文件系统挂载点
|-- tmp        # 存放临时文件
|-- usr        # usr是Unix Software Resource的缩写，即“UNIX操作系统软件资源”所放置的目录。
|   |-- bin    # 存放用户二进制文件
|   |-- games
|   |-- include
|   |-- lib    # 动态共享库
|   |-- libexec
|   |-- local
|   |-- sbin   # 存放系统二进制文件
|   |-- share
|   `-- src
`-- var        # 存放邮件、系统日志等变化文件
```
 
 
- etc不是什么缩写，是and so on的意思 来源于 法语的 et cetera 翻译成中文就是 等等 的意思. 后来FHS规定用来放配置文件，就解释为："Editable Text Configuration" 
 
- /usr：系统级的目录，可以理解为C:/Windows/，/usr/lib理解为C:/Windows/System32。

- /usr/local：用户级的程序目录，可以理解为C:/Progrem Files/。用户自己编译的软件默认会安装到这个目录下。

- /opt：用户级的程序目录，可以理解为D:/Software，opt有可选的意思，这里可以用于放置第三方大型软件（或游戏），当你不需要时，直接rm -rf掉即可。在硬盘容量不够时，也可将/opt单独挂载到其他磁盘上使用。

**/opt 和 /usr/local 的区别其实并不太大，/opt 主要更能区分一些经常删除和更新的程序。**

 源码放哪里？
/usr/src：系统级的源码目录。
/usr/local/src：用户级的源码目录。

Linux 与其他类 UNIX 系统一样并不区分文件与目录：目录是记录了其他文件名的文件。使用命令 mkdir 创建目录时，若期望创建的目录的名称与现有的文件名（或目录名）重复，则会创建失败。

参考 https://www.cnblogs.com/love-yh/p/8966438.html


## 硬链接和软链接

文件其实有两个部分组成：

- 用户数据 (user data)：即文件数据块 (data block)，数据块是记录文件真实内容的地方；

- 元数据 (metadata)：文件的附加属性，如文件名、大小、创建时间、所有者等信息。

在 Linux 中，元数据中的 inode 号（inode 是文件元数据的一部分但其并不包含文件名，inode 号即索引节点号）才是文件的唯一标识而非文件名。文件名仅是为了方便人们的记忆和使用，系统或程序通过 inode 号寻找正确的文件数据块。在 Linux 系统中查看 inode 号可使用命令 `stat` 或 `ls -i`。

```shell
$ stat /home/harris/source/glibc-2.16.0.tar.xz 
  File: `/home/harris/source/glibc-2.16.0.tar.xz'
  Size: 9990512   	 Blocks: 19520      IO Block: 4096   regular file 
 Device: 807h/2055d 	 Inode: 2485677     Links: 1 
 Access: (0600/-rw-------)  Uid: ( 1000/  harris)   Gid: ( 1000/  harris) 
 ... 
 ... 
$ mv /home/harris/source/glibc-2.16.0.tar.xz /home/harris/Desktop/glibc.tar.xz 
$ ls -i -F /home/harris/Desktop/glibc.tar.xz 
 2485677 /home/harris/Desktop/glibc.tar.xz
```
如上，使用命令 mv 移动并重命名文件 glibc-2.16.0.tar.xz，其结果不影响文件的用户数据及 inode 号，文件移动前后 inode 号均为：2485677。

为解决文件的共享使用，Linux 系统引入了两种链接：

- 硬链接 (hard link)
- 软链接（又称符号链接，即 soft link 或 symbolic link）。

链接为 Linux 系统解决了文件的共享使用，还带来了隐藏文件路径、增加权限安全及节省存储等好处。

### 硬链接

若一个 inode 号对应多个文件元数据，则称这些文件为硬链接。换言之，硬链接就是同一个文件使用了多个别名。硬链接可由命令 link 或 ln 创建。如下是对文件 oldfile 创建硬链接。

```shell
$ link oldfile newfile 
$ ln oldfile newfile
```

由于硬链接是有着相同 inode 号仅文件名不同的文件，因此硬链接存在以下几点特性：

- 文件有相同的 inode 及 data block；

- 只能对已存在的文件进行创建；inode 是随着文件的存在而存在，因此只有当文件存在时才可创建硬链接。

- 不能交叉文件系统（不同文件系统创建硬链接）进行硬链接的创建；inode 号仅在各文件系统下是唯一的，当 Linux 挂载多个文件系统后将出现 inode 号重复的现象。因此硬链接创建时不可跨文件系统

- 不能对目录进行创建，只可对文件创建；硬链接不能对目录创建是受限于文件系统的设计。文件系统中的目录均隐藏了两个个特殊的目录：当前目录（.）与父目录（..）。查看这两个特殊目录的 inode 号可知其实这两目录就是两个硬链接。若系统允许对目录创建硬链接，则会产生目录环。

- 删除一个硬链接文件并不影响其他有相同 inode 号的文件。


### 软连接

若文件用户数据块中存放的内容是另一文件的路径名的指向，则该文件就是软连接。软链接就是一个普通文件，只是数据块内容有点特殊。软链接有着自己的 inode 号以及用户数据块。因此软链接的创建与使用没有类似硬链接的诸多限制：

- 软链接有自己的文件属性及权限等；

- 可对不存在的文件或目录创建软链接；

- 软链接可交叉文件系统；

- 软链接可对文件或目录创建；

- 创建软链接时，链接计数 i_nlink 不会增加；

- 删除软链接并不影响被指向的文件，但若被指向的原文件被删除，则相关软连接被称为死链接（即 dangling link，若被指向路径文件被重新创建，死链接可恢复为正常的软链接）。

当然软链接的用户数据也可以是另一个软链接的路径，其解析过程是递归的。但需注意：软链接创建时原文件的路径指向使用绝对路径较好。使用相对路径创建的软链接被移动后该软链接文件将成为一个死链接（如下所示的软链接 a 使用了相对路径，因此不宜被移动），因为链接数据块中记录的亦是相对路径指向。
```shell
$ ls -li 
 total 2136 
 656627 lrwxrwxrwx 1 harris harris       8 Sep  1 14:37 a -> data.txt
 656662 lrwxrwxrwx 1 harris harris       1 Sep  1 14:37 b -> a 
 656228 -rw------- 1 harris harris 2186738 Sep  1 14:37 data.txt 6
```

### 链接相关命令

在 Linux 中查看当前系统已挂着的文件系统类型，除上述使用的命令 df，还可使用命令 mount 或查看文件 /proc/mounts。

```shell
$ mount 
/dev/sda7 on / type ext4 (rw,errors=remount-ro) 
proc on /proc type proc (rw,noexec,nosuid,nodev) 
sysfs on /sys type sysfs (rw,noexec,nosuid,nodev) 
... 
... 
none on /run/shm type tmpfs (rw,nosuid,nodev)
```

命令 ls 或 stat 可帮助我们区分软链接与其他文件并查看文件 inode 号，但较好的方式还是使用 find 命令，其不仅可查找某文件的软链接，还可以用于查找相同 inode 的所有硬链接。
使用命令 find 查找软链接与硬链接，查找在路径 /home 下的文件 data.txt 的软链接。
```shell
$ find /home -lname data.txt 
/home/harris/debug/test2/a 
```

查看路径 /home 有相同 inode 的所有硬链接
```shell
$ find /home -samefile /home/harris/debug/test3/old.file 
 /home/harris/debug/test3/hard.link 
 /home/harris/debug/test3/old.file 

 $ find /home -inum 660650 
 /home/harris/debug/test3/hard.link 
 /home/harris/debug/test3/old.file 
```
列出路径 /home/harris/debug/ 下的所有软链接文件
```shell
$ find /home/harris/debug/ -type l -ls 
656662 0 lrwxrwxrwx 1 harris harris 1 Sep 1 14:37 /home/harris/debug/test2/b -> a
656627 0 lrwxrwxrwx 1 harris harris 8 Sep 1 14:37 /home/harris/debug/test2/a -> data.txt
789467 0 lrwxrwxrwx 1 root root 8 Sep 1 18:00 /home/harris/debug/test/soft.link -> old.file 
789496 0 lrwxrwxrwx 1 root root 7 Sep 1 18:01 /home/harris/debug/test/soft.link.dir -> old.dir
```
系统根据磁盘的大小默认设定了 inode 的值，如若必要，可在格式文件系统前对该值进行修改。如键入命令 `mkfs -t ext4 -I 512/dev/sda4`，将使磁盘设备 /dev/sda4 格式成 inode 大小是 512 字节的 ext4 文件系统。

查看磁盘分区 /dev/sda7 上的 inode 值
```shell
$ dumpe2fs -h /dev/sda7 | grep "Inode size"
 dumpe2fs 1.42 (29-Nov-2011) 
 Inode size: 	          256 

$ tune2fs -l /dev/sda7 | grep "Inode size"
 Inode size: 	          256
```