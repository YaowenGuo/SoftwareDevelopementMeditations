# Linux VFS

查看内核文档 Documentation/filesystems/ 是一个不错的方式。

Linux 有着极其丰富的文件系统，大体上可分如下几类：

网络文件系统，如 nfs、cifs 等；
磁盘文件系统，如 ext4、ext3 等；
特殊文件系统，如 proc、sysfs、ramfs、tmpfs 等。
实现以上这些文件系统并在 Linux 下共存的基础就是 Linux VFS（Virtual File System 又称 Virtual Filesystem Switch），即虚拟文件系统。VFS 作为一个通用的文件系统，抽象了文件系统的四个基本概念：文件、目录项 (dentry)、索引节点 (inode) 及挂载点，其在内核中为用户空间层的文件系统提供了相关的接口（见 图 3.所示 VFS 在 Linux 系统的架构）。VFS 实现了 open()、read() 等系统调并使得 cp 等用户空间程序可跨文件系统。VFS 真正实现了上述内容中：在 Linux 中除进程之外一切皆是文件。


Linux VFS 存在四个基本对象：超级块对象 (superblock object)、索引节点对象 (inode object)、目录项对象 (dentry object) 及文件对象 (file object)。超级块对象代表一个已安装的文件系统；索引节点对象代表一个文件；目录项对象代表一个目录项，如设备文件 event5 在路径 /dev/input/event5 中，其存在四个目录项对象：/ 、dev/ 、input/ 及 event5。文件对象代表由进程打开的文件。这四个对象与进程及磁盘文件间的关系如图 4. 所示，其中 d_inode 即为硬链接。为文件路径的快速解析，Linux VFS 设计了目录项缓存（Directory Entry Cache，即 dcache）。



Linux 文件系统中的 inode
在 Linux 中，索引节点结构存在于系统内存及磁盘，其可区分成 VFS inode 与实际文件系统的 inode。VFS inode 作为实际文件系统中 inode 的抽象，定义了结构体 inode 与其相关的操作 inode_operations（见内核源码 include/linux/fs.h）。

清单 10. VFS 中的 inode 与 inode_operations 结构体
 struct inode { 
    ... 
    const struct inode_operations   *i_op; // 索引节点操作
    unsigned long           i_ino;      // 索引节点号
    atomic_t                i_count;    // 引用计数器
    unsigned int            i_nlink;    // 硬链接数目
    ... 
 } 

 struct inode_operations { 
    ... 
    int (*create) (struct inode *,struct dentry *,int, struct nameidata *); 
    int (*link) (struct dentry *,struct inode *,struct dentry *); 
    int (*unlink) (struct inode *,struct dentry *); 
    int (*symlink) (struct inode *,struct dentry *,const char *); 
    int (*mkdir) (struct inode *,struct dentry *,int); 
    int (*rmdir) (struct inode *,struct dentry *); 
    ... 
 }
如清单 10. 所见，每个文件存在两个计数器：i_count 与 i_nlink，即引用计数与硬链接计数。结构体 inode 中的 i_count 用于跟踪文件被访问的数量，而 i_nlink 则是上述使用 ls -l 等命令查看到的文件硬链接数。或者说 i_count 跟踪文件在内存中的情况，而 i_nlink 则是磁盘计数器。当文件被删除时，则 i_nlink 先被设置成 0。文件的这两个计数器使得 Linux 系统升级或程序更新变的容易。系统或程序可在不关闭的情况下（即文件 i_count 不为 0），将新文件以同样的文件名进行替换，新文件有自己的 inode 及 data block，旧文件会在相关进程关闭后被完整的删除。

清单 11. 文件系统 ext4 中的 inode
 struct ext4_inode { 
    ... 
    __le32  i_atime;        // 文件内容最后一次访问时间
    __le32  i_ctime;        // inode 修改时间
    __le32  i_mtime;        // 文件内容最后一次修改时间
    __le16  i_links_count;  // 硬链接计数
    __le32  i_blocks_lo;    // Block 计数
    __le32  i_block[EXT4_N_BLOCKS];  // 指向具体的 block 
    ... 
 };
清单 11. 展示的是文件系统 ext4 中对 inode 的定义（见内核源码 fs/ext4/ext4.h）。其中三个时间的定义可对应与命令 stat 中查看到三个时间。i_links_count 不仅用于文件的硬链接计数，也用于目录的子目录数跟踪（目录并不显示硬链接数，命令 ls -ld 查看到的是子目录数）。由于文件系统 ext3 对 i_links_count 有限制，其最大数为：32000（该限制在 ext4 中被取消）。尝试在 ext3 文件系统上验证目录子目录及普通文件硬链接最大数可见 清单 12. 的错误信息。因此实际文件系统的 inode 之间及与 VFS inode 相较是有差异的。

清单 12. 文件系统 ext3 中 i_links_count 的限制

 mkdir: cannot create directory `dir_31999': Too many links 


 ln: failed to create hard link to `old.file': Too many links

