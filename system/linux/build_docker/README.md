1. 创建

```
cd <Dockerfile 所在目录>
docker build -t albertguo88/linux_build:latest .

docker run --privileged=true  -itd --cap-add=SYS_PTRACE --cap-add=SYS_ADMIN --security-opt seccomp=unconfined --security-opt apparmor=unconfined -v $HOME/projects/:/Users/lim/projects -w /Users/lim/projects/linux/ --name linux_build albertguo88/linux_build /bin/bash

docker exec -it linux_build /bin/bash
``` 

[docker中运行lldb出现错误：process launch failed: 'A' packet returned an error: 8](https://javamana.com/2021/12/202112200008292891.html)

想要使用 lldb 调试，需要给 run 增加 `--cap-add=SYS_PTRACE --security-opt seccomp=unconfined --security-opt apparmor=unconfined` 参数。

**使用 debootstrap 创建根文件系统镜像需要挂载磁盘，需要使用 docker 使用 --privileged=true 权限，否则文件出现，mount 时出现文件不存在的问题。**

## 编译

1. 下载代码

```
git clone --depth=10 --single-branch https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
```

2. config

```
# copy system config
# cp /boot/config-$(uname -r) .config 
make menuconfig LLVM=-16
```
可以继续修改其它参数，例如需要指定调试信息时

```

```

3. make
```
make -j$(nproc) LLVM=-16
```

4. install ?

```
make modules_install
make install
update-initramfs -c -k 4.17-rc2  # 将内核启用来作为引导
update-grub # 更新 grub
```

- 编译生成的是 vmlinux，只有安装时才压缩为 vmlinuz
[关于vmlinux，vmlinuz，bzImage，zImage的区别和联系？](https://www.zhihu.com/question/478487561/answer/2049118223?utm_source=zhihu)
- 实体机安装位置在 `/sys/kernel/btf/vmlinux`, docker 镜像中的系统安装位置在 `/boot/vmlinuz` 目录。

Linux 源代码树包含了一个可以解压缩这个文件的工具—— extract-vmlinux：


```shell
# scripts/extract-vmlinux /boot/vmlinuz-$(uname -r) > vmlinux

# file vmlinux

vmlinux: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically

linked, stripped
```