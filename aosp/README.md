# 开发环境

```
sudo apt-get install git gnupg flex bison build-essential zip curl zlib1g-dev  x11proto-core-dev libx11-dev  libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig
```
删掉了 `libc6-dev-i386` 和 `lib32z1-dev`， `git-core` 替换为 `git`。

Debian 软件源选中所有软件源，然后安装 repo。
```
sudo apt install repo
```

sudo apt-get install qemu-system-arm qemu-user-static binfmt-support

repo init --partial-clone -u https://mirrors.tuna.tsinghua.edu.cn/git/AOSP/platform/manifest

repo sync
```
➜  aosp lunch aosp_cf_arm64_phone-trunk_staging-userdebug

============================================
PLATFORM_VERSION_CODENAME=Baklava
PLATFORM_VERSION=Baklava
TARGET_PRODUCT=aosp_cf_arm64_phone
TARGET_BUILD_VARIANT=userdebug
TARGET_ARCH=arm64
TARGET_ARCH_VARIANT=armv8-a
TARGET_CPU_VARIANT=cortex-a53
TARGET_2ND_ARCH=arm
TARGET_2ND_ARCH_VARIANT=armv8-a
TARGET_2ND_CPU_VARIANT=cortex-a53
HOST_OS=linux
HOST_OS_EXTRA=Linux-6.8.0-40-generic-x86_64-Ubuntu-22.04.3-LTS
HOST_CROSS_OS=linux_musl
BUILD_ID=MAIN
OUT_DIR=out
============================================

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Wondering whether to use user, userdebug or eng?

  user        The builds that ship to users. Reduced debugability.
  userdebug   High fidelity to user builds but with some debugging options
              enabled. Best suited for performance testing or day-to-day use
              with debugging enabled.
  eng         More debugging options enabled and faster build times, but
              runtime performance tradeoffs. Best suited for day-to-day
              local development when not doing performance testing.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```
