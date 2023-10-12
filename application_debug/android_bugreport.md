# bugreport

1. capture
2. reading: https://source.android.com/docs/core/tests/debug/read-bug-reports#memory
3. native crash: https://source.android.com/docs/core/tests/debug/native-crash?hl=zh-cn

在任何类型的开发中都存在 bug, 收集应用的崩溃信息、应用的运行状态，系统状态、资源使用情况以及日志有进行重建现场，分析问题原因至关重要，帮助定位并修复bug。Android 提供了 **bug 报告** 功能用于收集这些信息。bug 报告对于识别和解决问题至关重要，其包含了设备的日志、堆栈追踪以及其它相关信息帮助开发者发现、修复应用的 bug。


## 生成 bug 报告

生成 bug 报告有两种方式：

1. 使用设备或者模拟器上开发者选项中提供的 [`Take bug report`](https://developer.android.com/studio/debug/bug-report) 功能（Android 4.2 开始支持），该功能会将报告生成到 `/bugreports`, 生成报告后也会有一个通知，你可以将其分享导出数据。

2. 使用 `adb bugreport <目标文件>` 指令生成报告。如果没有指定生成文件的目录，会生成到当前目录。

### 保存旧的错误报告

默认情况下，错误报告保存在 /bugreports上，可以使用以下命令查看：

```shell
$ adb shell ls /bugreports/
bugreport-foo-bar.xxx.YYYY-MM-DD-HH-MM-SS-dumpstate_log-yyy.txt
bugreport-foo-bar.xxx.YYYY-MM-DD-HH-MM-SS.zip
dumpstate-stats.txt
```
可以使用 `adb pull` 将文件下载到本地：

```
$ adb pull /bugreports/bugreport-foo-bar.xxx.YYYY-MM-DD-HH-MM-SS.zip
```

### bug 报告的内容





bug 报告时一个 zip 格式的压缩文件，其名字默认格式为 `bugreport-BUILD_ID-DATE.zip`。压缩包中包含了多个文件。

- bugreport-BUILD_ID-DATE.txt  : bug 报告文件，其内容包含其中包含系统服务的诊断输出(dumpsys)，错误日志(dumpstate)以及系统日志（logcat, 包括设备抛出错误时的堆栈跟踪以及所有应用程序使用 Log类写入的日志）。其内容是普通文本格式，方便查看和使用查找特定内容。
- version.txt：包含安卓系统的元数据字符。
- systrace.txt：只有 `systrace` 开启了的情况下才有，用于定位性能问题。

此外，`dumpstate` 工具将相关的文件从设备的文件系统复制到zip文件中的 FS 目录下。例如，设备中的 `/dirA/dirB/fileC `文件生成 zip 中 `FS/FS/dirA/dirB/fileC` 文件。其一般包括：

```
FS
├── cache
│   └── recovery
├── data
│   ├── anr                     # * ANR 报告
│   ├── misc                    #
│   └── tombstones              # * 崩溃报告
├── linkerconfig
└── proc                        # * proc 文件系统，很过系统和应用相关信息保存在这里。
```

## bug 报告内容


### logcat



[堆栈示例](https://source.android.com/docs/core/tests/debug)
https://source.android.com/docs/core/tests/debug/native-crash?hl=zh-cn

The following sections detail bug report components, describe common problems, and give helpful tips and grep commands for finding logs associated with those bugs. Most sections also include examples for grep command and output and/or dumpsys output.

## tools

System: /system/bin
bugreport
debuggerd
dumpsys, dumpstate

要使用 debuggerd，您需要使用 Android Debug Bridge (ADB) 工具来与设备进行通信。以下是一些使用 debuggerd 的常见命令和用法：

1. 启动 debuggerd：在终端或命令行中输入 adb shell debuggerd。
2. 生成崩溃报告：当设备崩溃时，debuggerd 会自动生成一个崩溃报告。您可以使用以下命令查看崩溃报告：adb pull /sdcard/bugreport.txt。
3. 手动触发崩溃报告：您可以使用以下命令手动触发一个崩溃报告：adb shell debuggerd -b。
4. 通过 ADB 控制调试器：您可以使用以下命令启动调试器：adb shell debuggerd -b <pid>。然后，您可以使用其他 ADB 命令与调试器进行通信，例如 adb forward tcp:8000 tcp:8000（将本地 8000 端口与设备上的 8000 端口连接起来）。
请注意，使用 debuggerd 需要一些系统级的知识和权限。如果您是开发人员，请参考 Android 官方文档和相关开发指南，以了解更多关于 debuggerd 的详细信息和用法。


## 如何从用户获取这些信息？

Google play 和 firebase 之外的选择？如何自己实现？