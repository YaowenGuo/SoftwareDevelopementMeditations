scp 用于在电脑之间拷贝文件

## 文件名之间空格的文件

最后同时 在空格前加 斜杠，整个文件目录加引号才行

scp -r root@192.168.0.51:"/home/xxj/Documents/files/xx\ xx\ jj.tar.gz" ./
