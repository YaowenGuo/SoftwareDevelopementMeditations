# lldb remote debug


## 1. 获取 lldb-server

如果已经使用 AS 调试过程序，在手机的 /data/local/tmp 已经有了 lldb-server，不用再往手机添加。没有的话，可以在下载的 ndk 的 `toolchains/llvm/prebuilt/<平台类型，如darwin-x86_64>/lib64/clang/9.0.8/` 目录下找到。

然后 push 到手机上。

```
$ adb push lldb-server /data/local/tmp/
$ adb shell
cd /data/local/tmp
chmod 755 lldb-server
```

## 2. 启动 lldb-server

继续在 adb shell 中执行
```
./lldb-server p --server --listen unix-abstract:///data/local/tmp/debug.sock
```

## 3. 启动 lldb 作为客户端

在另一个终端执行

```
$ lldb
platform list # 查看支持连接平台的插件
platform select remote-android # 选择连接安卓设备
platform status # 查看连接状态
platform connect unix-abstract-connect:///data/local/tmp/debug.sock
```
注意，**上一步启动时 lldb-server 使用的 scheme 是 `unix-abstract`，客户端连接则是 `unix-abstract-connect`**

## 4. 关联到调试程序

> 方式一：启动程序
```
file <target_binary> # 指定将要调试的二进制文件,注意是相对于WorkingDir的路径
br set -f app_core.cpp -l 128 # 意思就是在app_core.cpp的128行处打个断点
run # 运行程序
```
> 方式二：关联到已经运行着的程序

```
file  <target_binary> # 指定将要调试的二进制文件,注意是相对于WorkingDir的路径
platform process list # 查看一直远端的进程, 找到目标进程pid, 或者名称
attach <pid>
```

也可以用 `$ adb shell  "<package name>"` 查看进程 id。然后就可以执行 lldb 的各种调试命令了。

## Android Studio 执行的脚本

```
$ adb shell cat /data/local/tmp/lldb-server | run-as com.fenbi.android.servant sh -c 'cat > /data/data/com.fenbi.android.servant/lldb/bin/lldb-server && chmod 700 /data/data/com.fenbi.android.servant/lldb/bin/lldb-server'

$ adb shell cat /data/local/tmp/start_lldb_server.sh | run-as com.fenbi.android.servant sh -c 'cat > /data/data/com.fenbi.android.servant/lldb/bin/start_lldb_server.sh && chmod 700 /data/data/com.fenbi.android.servant/lldb/bin/start_lldb_server.sh'

Starting LLDB server: /data/data/com.fenbi.android.servant/lldb/bin/start_lldb_server.sh /data/data/com.fenbi.android.servant/lldb unix-abstract /com.fenbi.android.servant-0 platform-1625240005240.sock "lldb process:gdb-remote packets"

run-as com.fenbi.android.servant sh -c '/data/data/com.fenbi.android.servant/lldb/bin/start_lldb_server.sh /data/data/com.fenbi.android.servant/lldb unix-abstract /com.fenbi.android.servant-0 platform-1625240005240.sock "lldb process:gdb-remote packets"'
```


```
start_lldb_server.sh lldb unix-abstract /com.fenbi.android.shouna-0 platform-1668420239240.sock "lldb process:gdb-remote packets"

platform connect unix-abstract-connect:///com.fenbi.android.shouna-0/platform-1668420239240.sock

```