### 2.7

挂载
├─vdb1                    vfat        efi                                        
├─vdb2                    ext4        boot            
├─vdb3                    btrfs       /           
└─vdb4                                swap
```shell
sudo mount -v -t btrfs /dev/vdb3 $LFS
sudo mount -v -t ext4  /dev/vdb2 $LFS/boot
sudo mount -v -t vfat   /dev/vdb1 $LFS/boot/efi
sudo /sbin/swapon -v /dev/vdb4
```

### 4.4

- [/etc/zsh/ | ~.]zshenv	所有 Zsh 实例（全局）	系统级环境变量（所有用户、所有场景生效）。
- [/etc/zsh/ | ~.]zprofile	登录 Shell（全局）	系统级登录配置（类似 /etc/profile）。
- [/etc/zsh/ | ~.]zshrc	交互式 Shell（全局）	系统级别名、函数、Shell 选项。
- [/etc/zsh/ | ~.]zlogin	登录 Shell（全局）	系统级登录后执行的命令。
- [/etc/zsh/ | ~.]zlogout	退出登录 Shell（全局）	系统级退出时执行的命令。


```shell
cat > ~/.zprofile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/zsh
EOF
```

```shell
cat > ~/.zshrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
EOF
```

```shell
cat >> ~/.zshrc << "EOF"
export MAKEFLAGS=-j$(nproc)
EOF
```


**The build**
is the machine where we build programs. Note that this machine is also referred to as the “host.”

**The host**
is the machine/system where the built programs will run. Note that this use of “host” is not the same as in other sections.

**The target**
is only used for compilers. It is the machine the compiler produces code for. It may be different from both the build and the host.

```
Stage	Build	Host	Target	Action
1	A	A	B	Build cross-compiler cc1 using ccA on machine A.
2	A	B	C	Build cross-compiler cc2 using cc1 on machine A.
3	B	C	C	Build compiler ccC using cc2 on machine B.
```

Then, all the programs needed by machine C can be compiled using cc2 on the fast machine B. Note that unless B can run programs produced for C, there is no way to test the newly built programs until machine C itself is running. For example, to run a test suite on ccC, we may want to add a fourth stage:

```

Stage	Build	Host	Target	Action
4	C	C	C	Rebuild and test ccC using ccC on machine C
```

确定交叉编译三元组：
```shell
./config.guess
# 或者
gcc -dumpmachine
```
确定动态连接器：
```shell
# 可在当前系统执行的任意文件
readelf -l <name of binary> | grep interpreter
```


### L1

```shell
case $(uname -m) in
    aarch64) ln -sfv .  x86-64.so.2 $LFS/lib64
            ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
    ;;
esac
```

## 7.3

```shell
sudo mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts
sudo mount -vt proc proc $LFS/proc
sudo mount -vt sysfs sysfs $LFS/sys
sudo mount -vt tmpfs tmpfs $LFS/run

if [ -h $LFS/dev/shm ]; then
  install -v -d -m 1777 $LFS$(realpath /dev/shm)
else
  sudo mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
fi
```

```shell
sudo chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin     \
    MAKEFLAGS="-j$(nproc)"      \
    TESTSUITEFLAGS="-j$(nproc)" \
    /bin/bash --login



sudo mv -v $LFS/usr/bin/chroot $LFS/usr/sbin

sudo mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sudo sed -i 's/"1"/"8"/'                    $LFS/usr/share/man/man8/chroot.8


for i in bin lib sbin; do
  sudo ln -sv usr/$i $LFS/$i
done
```

检查虚拟文件系统是否被挂载

```shell
findmnt | grep $LFS
└─/mnt/lfs                     /dev/vdb3                         btrfs       rw,relatime,discard=async,space_cache=v2,subvolid=5,subvol=/
  ├─/mnt/lfs/boot              /dev/vdb2                         ext4        rw,relatime
  │ └─/mnt/lfs/boot/efi        /dev/vdb1                         vfat        rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,errors=remount-ro
  ├─/mnt/lfs/dev               udev                              devtmpfs    rw,nosuid,relatime,size=3999820k,nr_inodes=999955,mode=755,inode64
  │ ├─/mnt/lfs/dev/pts         devpts                            devpts      rw,relatime,gid=5,mode=620,ptmxmode=000
  │ └─/mnt/lfs/dev/shm         tmpfs                             tmpfs       rw,nosuid,nodev,relatime,inode64
  └─/mnt/lfs/proc              proc                              proc        rw,relatime
```