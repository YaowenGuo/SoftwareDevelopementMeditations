# Directory Structure

```
|-
    |- /etc 
    |- /usr  # usr是Unix Software Resource的缩写，即“UNIX操作系统软件资源”所放置的目录。
    |- /opt 

```
 
 
 - etc不是什么缩写，是and so on的意思 来源于 法语的 et cetera 翻译成中文就是 等等 的意思. 后来FHS规定用来放配置文件，就解释为："Editable Text Configuration" 
 

 ## 程序安装目录比较

 /usr：系统级的目录，可以理解为C:/Windows/，/usr/lib理解为C:/Windows/System32。

 /usr/local：用户级的程序目录，可以理解为C:/Progrem Files/。用户自己编译的软件默认会安装到这个目录下。

 /opt：用户级的程序目录，可以理解为D:/Software，opt有可选的意思，这里可以用于放置第三方大型软件（或游戏），当你不需要时，直接rm -rf掉即可。在硬盘容量不够时，也可将/opt单独挂载到其他磁盘上使用。

 源码放哪里？
/usr/src：系统级的源码目录。
/usr/local/src：用户级的源码目录。


/opt 和 /usr/local 的区别其实并不太大，/opt 主要更能区分一些经常删除和更新的程序。

参考 https://www.cnblogs.com/love-yh/p/8966438.html

