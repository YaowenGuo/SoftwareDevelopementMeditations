# 开发环境

安卓额外的软件包

```
unzip zip rsync
```

## repo 清华源

将如下内容复制到你的 `~/.bashrc` 里，并重启终端或者执行 `source ~/.bashrc`，升级 `repo` 版本也会从清华源下载。
```
# repo 也设置成国内源 
export REPO_URL='https://mirrors.tuna.tsinghua.edu.cn/git/git-repo'

mkdir ~/bin
curl https://mirrors.tuna.tsinghua.edu.cn/git/git-repo  > ~/bin/repo
chmod a+x ~/bin/repo
export PATH=~/bin:$PATH
```

或者使用中科大的源



##  download aosp

设置下载的目标版本
```
mkdir aosp && cd aosp


repo --trace init --depth=1 -u https://mirrors.tuna.tsinghua.edu.cn/git/AOSP/platform/manifest -b android-latest-release


# 已经下载过，想改成不同版本的代码也是用该命令。--depth=1 浅克隆，加快下载速度， --trace 显示 init 的过程，卡住不动能分析哪里卡住了。
repo --trace init --depth=1 -u https://mirrors.ustc.edu.cn/aosp/platform/manifest -b android-latest-release



# 同步代码
repo sync -j $(nproc)
```

开始编译
```shell
sudo dnf groupinstall "Development Tools" -y
sudo dnf install git gnupg2 flex bison zip curl unzip -y
sudo dnf install glibc-devel zlib-devel -y
sudo dnf install glibc-devel.i686 zlib-devel.i686 -y
sudo dnf install xorg-x11-proto-devel libX11-devel mesa-libGL-devel -y
sudo dnf install fontconfig libxml2 libxslt -y
sudo dnf install openssl -y
```

```shell
. build/envsetup.sh
lunch sdk_phone64_x86_64-aosp_current-userdebug
m -j $(nproc)
```
## lunch 目标

lunch 后的内容以中划线分为三部分 PRODUCT-RELEASE-VARIANT，具体查看：lunch --help

产品目标：
sdk_phone/tablate/car 用于模拟器
aosp_cf_  用于 Cuttlefish 更接近真机
aosp_<代号>，真机 例如 aosp_shiba（Pixel 8）、aosp_husky（Pixel 8 Pro）
aosp_<架构> 验证编译或者历史遗留。如 aosp_arm64、aosp_x86。

release：发布配置（只有新格式有）

- trunk_staging：主线开发分支，跟着 main 或最新源码编译时一般选这个
- next：下一个版本的功能预览
- ap3a、ap4a、bp1a 这类：对应具体发布版本的配置。拉的是某个 release tag 的源码时，选和它对应的那一个

variant：编译类型

- eng  开发版，带 root 和调试工具，没有优化  底层开发、调试 
- userdebug 和正式版接近，同时可以 root 和调试。 日常开发推荐。
- user      正式发布版，权限受限。


查看有哪些组合可用，使用 list_products, list_releases, or list_variants 指令查看。
// 手机：
export TARGET_PRODUCT=aosp_cf_arm64_only_phone
才能执行
list_releases

使用命令查看是否是内存问题：

dmesg -T | tail -200 | grep -i -E 'killed process|out of memory|oom'
如果是内存不足，会有 Out of memory.

# 2. 对所有仓库执行完全清理
repo forall -c 'git reset --hard HEAD && git clean -fdx'

orb config set rosetta true
