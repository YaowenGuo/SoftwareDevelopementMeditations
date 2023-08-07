# 压缩指令

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


