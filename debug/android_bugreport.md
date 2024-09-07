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

## 查看 tombstones

### 崩溃日志

Bugs are a reality in any type of development—and bug reports are critical to identifying and solving problems. All versions of Android support capturing bug reports with Android Debug Bridge (adb); Android versions 4.2 and higher support a [Developer Option](http://developer.android.com/tools/device.html#developer-device-options) for taking bug reports and sharing via email, Drive, etc.



Unix 系统一般都提供了[core dump](core_dump.md) 功能来定位 Native 的崩溃问题。Core Dump 依赖于系统设置，无法用于生产环境提供调试信息。因此很多应用 SDK 都提供了不同形式的 unwind stack 的功能，用于记录线上问题。同时 Core Dump 也仅能用于纯 Native 的程序，对 Java 这种混合程序作用有限。为了解决以上问题，Android 提供 tombstone 功能，用于输出崩溃信息。

Provide apps direct access to tombstone traces

Previously, the only way to get access to this information was through the Android Debug Bridge (adb). Starting in Android 12 (API level 31), you can access your app's native crash tombstone as a protocol buffer through the ApplicationExitInfo.getTraceInputStream() method. The protocol buffer is serialized using this schema. 

Here’s an example of how to implement this in your app:

```Java
ActivityManager activityManager: ActivityManager = getSystemService(Context.ACTIVITY_SERVICE);
MutableList<ApplicationExitInfo> exitReasons = activityManager.getHistoricalProcessExitReasons(/* packageName = */ null, /* pid = */ 0, /* maxNum = */ 5);
for (ApplicationExitInfo aei: exitReasons) {
    if (aei.getReason() == REASON_CRASH_NATIVE) {
        // Get the tombstone input stream.
        InputStream trace = aei.getTraceInputStream();
        // The tombstone parser built with protoc uses the tombstone schema, then parses the trace.
        Tombstone tombstone = Tombstone.parseFrom(trace);
    }
}
```

或者在未崩溃时主动获取一个 stombstone: Getting a stack trace/tombstone from a running process

You can use the debuggerd tool to get a stack dump from a running process. From the command line, invoke debuggerd using a process ID (PID) to dump a full tombstone to stdout. To get just the stack for every thread in the process, include the -b or --backtrace flag.


新版的手机除非 root，否则无法查看 `/data` 目录下的内容。也就无法获取 `ANR` 和 `tombstones` 崩溃信息。因此 adb 提供了一个额外的指令来下载这些文件到本地。

```
adb bugreport
```
该指令会生成一个 zip 文件到本地。解压就能获取各种崩溃信息的文件。在 `FS/data` 下分别有 anr 和 tombstones 文件夹，里面便是对应文件。

解析 tombstone： https://stackoverflow.com/questions/28105054/default-tombstones-location-in-android
其它生成方式： https://developer.android.com/studio/debug/bug-report?hl=zh-cn



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


## 郭耀文
https://bugly.tds.qq.com/v2/exception/crash/issues/detail?productId=900004178&pid=1&token=58e51ac6f49c4b896e619bae063d6880&feature=C024E3958388AF0AA23047BDDDD53932&cId=d28b0d61-71fb-4527-bf4a-2e2c2fb0d613



https://bugly.tds.qq.com/v2/exception/crash/issues/detail?productId=900004178&pid=1&token=63294c2049d41d4d4d1cd269ab7c9d0c&feature=2A69A58243B501DFA7CA125B13553893&cId=81ee09e0-6e02-47d1-b2e8-e9cefd74c7a3

http://gerrit.corp.fenbi.com/#/c/android-module-video/+/161275
http://gerrit.corp.fenbi.com/#/c/android-app-gwy/+/161276
修复线程不安全引起的崩溃
https://bugly.tds.qq.com/v2/exception/crash/issues/list?productId=900004178&pid=1&token=e8686b9d991486c8d65e10319c71600c


https://bugly.tds.qq.com/v2/exception/crash/issues/detail?productId=900004178&pid=1&token=63294c2049d41d4d4d1cd269ab7c9d0c&feature=75E714A50FCAD2DED1D4EA42D849225C&cId=08520649-e1cf-4915-be8f-6890b00e4c83


http://gerrit.corp.fenbi.com/#/c/android-module-ocr/+/161316
http://gerrit.corp.fenbi.com/#/c/android-app-gwy/+/161317
修复安卓低版本阴影设置超过 25 时引起的崩溃
https://stackoverflow.com/questions/23048567/android-signal-11-rs-cpp-error-blur-radius-out-of-0-25-pixel-bound

https://bugly.tds.qq.com/v2/exception/crash/issues/detail?productId=900004178&pid=1&token=63294c2049d41d4d4d1cd269ab7c9d0c&feature=EEFE14E8ECDFF9A37A4FA9A4D905B883&cId=1177623b-dd1f-4ef6-8536-68dac70df321



https://bugly.tds.qq.com/v2/exception/crash/issues/detail?productId=900004178&pid=1&token=63294c2049d41d4d4d1cd269ab7c9d0c&feature=F6A92BBC309DBAC1ED52409FAA0A1AAA&cId=ca73cf10-ba6a-4e13-b7e7-559be67aac07
升级 IM SDK
