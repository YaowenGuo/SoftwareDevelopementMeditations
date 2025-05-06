# 压缩指令

文件压缩工具一般只能压缩单个文件，对于目录的压缩其实是隐藏了。如下命令等效
```shell
tar -xzvf filename
gzip -cd filename | tar xvf -
gunzip -c filename | tar xvf -
```

(-"会指示 tar 命令从 stdin 输入）

.tar.gz = .tgz
tar tzvf <file> # 预览压缩包中的文件，但并未实际解压缩

gzip (.tar.gz, .tgz)
bzip2 (.bz2) 

```shell
bzip2 -cd filename | tar xvf -
tar xyvf filename
```


## zip

需要说明的是 zip 是一个打包压缩命令，会包含目录一起压缩，如果想要不包含目录，需要使用 `-r` 参数

```
zip test.zip test.txt  #添加压缩文件
zip test.zip test1.txt  #移动文件到压缩包
zip -d test.zip test.txt    #删除test.txt

zip -r test.zip ./*          #压缩当前全部文件到test.zip
zip test2.zip test2/*   #打包目录
zip test3.zip tests/* -x tests/ln.log  #压缩目录,除了tests/ln.log

zip -r test.zip ./* -P 123  #设置密码(明文设置密码不太安全)
zip -r test.zip ./* -e   #交互设置密码(安全)

#设置压缩比
#-0不压缩，-9最高压缩，默认为-6
zip test.zip test.txt -6
```

常用参数

```
#常用命令选项
-d   从压缩文件内删除指定的文件。
-m   把文件移到压缩文件中。
-0-9 压缩比
-r   递归处理，所有文件和子目录一并处理。
-x<范本样式>   压缩时排除符合条件的文件。
-c   交互为每一个文件设置注释
-z   交互多行注释,英文句话.来表示结束
-e   交互设置密码
-P   直接设置密码
```
## rar

01-.tar格式
解包：$ tar xvf FileName.tar
打包：$ tar cvf FileName.tar DirName（注：tar是打包，不是压缩！）

02-.gz格式
解压1：$ gunzip FileName.gz
解压2：$ gzip -d FileName.gz
压 缩：$ gzip FileName

03-.tar.gz格式
解压：$ tar zxvf FileName.tar.gz
压缩：$ tar zcvf FileName.tar.gz DirName

04-.bz2格式
解压1：$ bzip2 -d FileName.bz2
解压2：$ bunzip2 FileName.bz2
压 缩： $ bzip2 -z FileName

05-.tar.bz2格式
解压：$ tar jxvf FileName.tar.bz2
压缩：$ tar jcvf FileName.tar.bz2 DirName

06-.bz格式
解压1：$ bzip2 -d FileName.bz
解压2：$ bunzip2 FileName.bz

07-.tar.bz格式
解压：$ tar jxvf FileName.tar.bz

08-.Z格式
解压：$ uncompress FileName.Z
压缩：$ compress FileName

09-.tar.Z格式
解压：$ tar Zxvf FileName.tar.Z
压缩：$ tar Zcvf FileName.tar.Z DirName

10-.tgz格式
解压：$ tar zxvf FileName.tgz

11-.tar.tgz格式
解压：$ tar zxvf FileName.tar.tgz
压缩：$ tar zcvf FileName.tar.tgz FileName

12-.zip格式
解压：$ unzip FileName.zip
压缩：$ zip FileName.zip DirName

13-.lha格式
解压：$ lha -e FileName.lha
压缩：$ lha -a FileName.lha FileName

14-.rar格式
unrar e /tmp/test.rar /home/test
解压：$ rar x FileName.rar
压缩：$ rar e FileName.rar     
rar请到：http://www.rarsoft.com/download.htm 下载！
解压后请将rar_static拷贝到/usr/bin目录（其他由$PATH环境变量
指定的目录也行）：$ cp rar_static /usr/bin/rar


https://hera-webapp.fenbi.com/android/notification/list/v2?unread=0&msgType=%5B10%5D&score=-1&num=20&version=6.17.58.100&vendor=fenbi&app=gwy&av=117&kav=108&hav=113&apcid=2&deviceId=uVD7HyfphpJz8s3Vn1kjBA==&client_context_id=67EB107BB1825A4D8E8F