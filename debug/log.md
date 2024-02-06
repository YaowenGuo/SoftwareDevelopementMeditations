# 日志

1. 日志系统
    1. 标准
    2. 等级
    3. 过滤

2. logcat 查看

3. Android Studio 查看

4. 理解日志

4. 文件保存。

5. 获取日志上报


对于任何软件来说，日志都是不可或缺的一部分。在调试时，日志能帮助我们更好的了解应用运行过程中发生了什么；对于生产环境，日志更好的记录了用户的操作以及问题发生时的错误，更好的帮助我们重建崩溃场景。成熟的日志系统可不是简单的将信息输出而已，其需要处理各种异常场景，确保工作的同时不能影响整个系统的性能：

1. 处理多个进程的日志输出。
2. 处理大量的写入，同时不能影响系统性能。
3. 需要性能优越，不能阻塞应用程序。
4. 需要考虑日志的最大占用空间，不能无限的写入占用过多的磁盘空间。
5. 最好能在用户发生问题时上报日志。

## 日志系统

Android 使用的是一个集中式日志系统来记录所有的日志，这意味着所有的应用日志都记录在同一个地方。为了实现这一点，系统启动了一个 logd 进程来处理日志的任务。logd 进程使用 socket 与外界通信。同时为访问和写入日志提供了接口和库：

> 对于写入日志：
为 Native 提供了 `liblog.so`，其提供 `__android_log_print` 函数。
为Java 封装了 android.util.Log 接口。

`liblog` 共享库及其头文件 `<android/log.h>` 提供了日志系统的 C/C++ 的基础日志接口。所有语言层级的日志接口（包括 android.util.Log）最终都是调用 `__android_log_write`。默认情况下它调用 `__android_log_logd_logger`, 其将日志通过 socket 发送到 logd。从 API 30 开始，日志方法可以通过 `__android_set_log_writer` 方法进行修改以写入到其它地方。更多的信息可以查看 [NDK 文档](https://developer.android.com/ndk/reference/group/logging).


> 对于读取日志提供了 logcat 客户端，也可以使用 Android Studio 的 locat UI 化窗口访问。

### 日志类型

Android 日志并不会保存到文件，日志系统定义了一组固定的环形结构缓冲区，由系统进程logd维护。这些缓冲区挂载在 `/dev/log` 目录下。不同的日志缓冲区写入的是不同类型的日志，主要有：main system radio events crash。
- main: 主日志，存储大多数应用程序日志。
- system：系统日志，存储来自Android操作系统的消息。使用 android.util.Slog 打印。
- crash：存储崩溃日志。每个日志条目都有一个优先级、一个标识日志来源的标记和实际的日志消息。
- radio：用于电话相关信息，设备节点 `/dev/log/radio`。
- events：事件日志，用于系统事件信息，二进制格式，使用android.util.EventLog打印，设备节点 `/dev/log/event`。

### 日志标准

[安卓系统上的日志实现了多种标准](https://source.android.com/docs/core/tests/debug/understanding-logging)，通过 logcat 查看时这些日志被混合在一起而显得非常复杂。实现的主要标准如下：

| 来源	                    | 示例	                     | 堆栈级别准则           |
| ------------------------ | ------------------------- | --------------------  |
| RFC 5424（syslog 标准）	|  Linux 内核、许多 Unix 应用  | 内核、系统守护程序、liblog.so|
| android.util.Log	       | Android 框架 + 应用日志记录  | Android 框架和系统应用  |
| java.util.logging.Level  | Java 中的常规日志记录	      | 非系统应用             |


### 日志级别

尽管这些标准都有类似的级别结构，但它们在粒度上存在差异。各个标准的近似等效项如下所示：

| RFC5424级别 | RFC 5424 严重性  | RFC 5424 说明	| android.util.Log	| java.util.logging.Level |
| ---------- | --------------- | --------------- | ------------------ | ----------------------- |
| 0	         | 紧急             | 系统无法使用	    |  Log.e / Log.wtf	| SEVERE                   |
| 1	         | 警报             | 必须立即采取措施	 | Log.e / Log.wtf	 | SEVERE                   |
| 2	         | 严重             | 严重情况	        | Log.e / Log.wtf	| SEVERE                  |
| 3	         | 错误             | 错误情况	        | Log.e	            | SEVERE                  |
| 4	         | 警告             | 警告情况	        | Log.w	            | WARNING                 |
| 5	         | 注意             | 正常，但值得注意	 |  Log.w	         | WARNING                 |
| 6	         | 参考             | 提供参考信息	    | Log.i	            | INFO                     |
| 7	         | 调试             | 调试级消息	    | Log.d	            | CONFIG，FINE             |
| -	         | -               | 提供详细消息	    | Log.v	            | FINER/FINEST             |
|
|


### 日志过滤

> 1. 编译期过滤

根据编译设置，可以将日志在编译时删除，不会被编译到最终的软件中。例如以下 ProGuard 示例为 android.util.Log 移除了 INFO 级别以下的所有日志记录

```
# This allows proguard to strip isLoggable() blocks containing only <=INFO log
# code from release builds.
-assumenosideeffects class android.util.Log {
  static *** i(...);
  static *** d(...);
  static *** v(...);
  static *** isLoggable(...);
}
-maximumremovedandroidloglevel 4
```

> 2. 系统属性过滤

liblog 查询一组系统属性，以确定要发送到 logd 的最小严重性级别。如果您的日志有MyApp标签，则检查以下属性，并期望包含最低严重性的第一个字母(V, D, I, W, E或S以禁用所有日志)

- log.tag.MyApp
- persist.log.tag.MyApp
- log.tag
- persist.log.tag

在运行时可以调整日志，以提供特定级别的日志记录，如下所示：


```
adb shell setprop log.tag.FOO_TAG VERBOSE
```

log.tag.* 属性会在重启时重置。此外，还有永久变体在重启后保持不变。请参阅下文：

```
adb shell setprop persist.log.tag.FOO_TAG VERBOSE
```

> 3. 应用级过滤

如果没有系统的过滤，liblog 会使用 __android_log_set_minimum_priority 指定的最低优先级。默认值是 INFO。

> 4. 输出时过滤

logcat 支持在输出内容是进行过滤，可以减少从 logd 显示的日志量。详细的使用方法在下文 logcat 命令行中说明。

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


在调试环境中，可以使用 Android studio 的 Logcat 面板或者 adb logcat 命令行查看。

## 查看 Log

可以使用 adb logcat 命令行查看安卓的日志，另外 AndroidSudio 提供了 logcat 的 UI 窗口。两种方式都能提供各自的便利性。

### [logcat 命令行](https://developer.android.com/tools/logcat)

logcat 实际上是安卓系统的一个程序。不同版本支持的参数功能会因版本而有差异。要查看正在使用的设备的logcat帮助，可以连接设别执行 `adb logcat --help` 查看。

请注意，因为logcat是操作系统开发人员和应用程序开发人员的工具(应用程序开发人员希望使用Android Studio代替)，许多选项只能 root 用户使用。

```
Usage: logcat [options] [filterspecs]
```

```
通用参数:
  -b, --buffer=<buffer>       用于指定循环缓冲区，可选参数为：main system radio events crash default all
                              此外，`kernel` 用于用 `userdebug` 和 `eng` 构建类型的系统，`security` 用于
                              设备所有者安装。可以指定多个 -b 参数或者逗号分割的列表。个缓冲区会交织在移除输出。
                              默认是 `default` 参数，与 `-b main,system,crash,kernel` 等同。

  -L, --last                  从 pstore 输出上内核崩溃重启的日志。pstore 是一种在内核崩溃是将日志写入到 pstore
                              的机制，对于内核调试非常有用。
  -c, --clear                 清空日志并退出。如果指定了-f，则清除指定的文件及其相关的旋转日志文件。如果指定了 -L
                              清空 psotre 日志。
  -d                          输出日志后立即退出而不是继续等待输出。
  --pid=<pid>                 只输出 pid 指定的日志。
  --wrap                      休眠两小时或者缓冲区即将封装先发生。通过提供即将封装的唤醒来提高查询效率

用于控制格式的参数：
  -v, --format=<format>       Sets log print format verb and adverbs, where <format> is one of:
                                brief help long process raw tag thread threadtime time
                              Modifying adverbs can be added:
                                color descriptive epoch monotonic printable uid usec UTC year zone
                              Multiple -v parameters or comma separated list of format and format
                              modifiers are allowed.
  -D, --dividers              在每个日志缓冲区之间输出分割。
  -B, --binary                使用二进制输出日志。

Outfile files:
  -f, --file=<file>           输出日志到指定文件。
  -r, --rotate-kbytes=<n>     每 n kb 轮换日志。需要 `-f` 参数。
  -n, --rotate-count=<count>  设置日志轮转的最大值，默认是 4.
  --id=<id>                   如果用于日志文件的签名<id>更改，则清空相关文件并继续。

控制 Logd:
 这些选项将控制消息发送到设备上的 Logd 守护程序，如果适用，打印其返回消息，然后退出。它们与 `-L` 不能一起使用，因为
 这些属性不适用于 `pstore`。
  -g, --buffer-size           获得 logd 内的环缓冲区的大小。
  -G, --buffer-size=<size>    设置 logd 中环形缓冲区的大小。后缀可以是K或M。这可以使用-b单独控制每个缓冲区的大小。
  -S, --statistics            输出统计。`--pid` 可用于提供pid特定的统计信息。
  -P, --prune='<list> ...'    设置 logd 裁剪的黑白名单。通过 `UID/PID` 或 `/PID` 指定服务。以引号包括。
  -p, --prune                 输出 logd 的裁剪白名单和黑名单。格式为 `UID/PID` 或 `/PID`。如果使用 `~` 前缀则
                              衡量为最快的裁剪。 否则衡量速度更慢。所有的 Activity 中最老的优先。特殊符号 `~!` 
                              表示对当前统计数据确定的最复杂UID进行自动更快的修剪。 


过滤:
  -s                          将默认过滤器设置为静默。跟过滤规则 '*:S' 等效。
  -e, --regex=<expr>          仅输出日志信息与 `<expr>` 匹配的行，`<expr>` 是 ECMAScript 格式的正则表达式。
  -m, --max-count=<count>     指定输出日志的行数。输出指定数量行的信息后退出。可以与 `--regex` 组合或单独工作。
  --print                     此选项仅在同时使用 `--regex` 和 `--max-count`时才生效。使用 `--print`, logcat
                              将打印所有消息，即使它们与正则表达式不匹配。Logcat 将在打印匹配正则表达式的最大计数行
                              数后退出。
  -t <count>                  只打印最近的`<count>`行(隐含-d)。
  -t '<time>'                 打印自指定时间以来的行 (隐含-d).
  -T <count>                  只打印最近的`<count>`行 (不隐含 -d).
  -T '<time>'                 打印自指定时间以来的行 (不隐含 -d).
                              count是纯数字，时间是 `MM-DD hh:mm:ss.mmm...`, `YYYY-MM-DD hh:mm:ss.mmm...`
                              或 `sssss.mmm...` 格式。

过滤规则是一系列的 `<tag>[:priority]`

`<tag>` 是日志组件的 `tag` (或者 `*` 表示所有)，严重等级是：
  V    Verbose (default for <tag>)
  D    Debug (default for '*')
  I    Info
  W    Warn
  E    Error
  F    Fatal
  S    Silent (suppress all output)

单独的 '*' 表示 '*:D'，单独的 <tag> 表示 <tag>:V。如果没有 '*' 或指定了 '-s'，所有的过滤器
默认是 '*:V'。

如果没有在命令行中指定过滤，则从 `ANDROID_LOG_TAGS` 设置过滤规则。

如果没有在命令行中指定 `-v`，格式将从 `ANDROID_PRINTF_LOG` 设置或默认为 `threadtime`。

-v <format>, --format=<format> options:
  设置日志输出格式的动词或副词，`<format>` 可以是：
    brief long process raw tag thread threadtime time
  可以添加独立修饰的副词：
    color descriptive epoch monotonic printable uid usec UTC year zone

单一格式动词：
  brief      — Display priority/tag and PID of the process issuing the message.
  long       — Display all metadata fields, separate messages with blank lines.
  process    — Display PID only.
  raw        — Display the raw log message, with no other metadata fields.
  tag        — Display the priority/tag only.
  thread     — Display priority, PID and TID of process issuing the message.
  threadtime — Display the date, invocation time, priority, tag, and the PID
               and TID of the thread issuing the message. (the default format).
  time       — Display the date, invocation time, priority/tag, and PID of the
             process issuing the message.

副词修饰语可以组合使用：
  color       — Display in highlighted color to match priority. i.e. VERBOSE
                DEBUG INFO WARNING ERROR FATAL
  descriptive — events logs only, descriptions from event-log-tags database.
  epoch       — Display time as seconds since Jan 1 1970.
  monotonic   — Display time as cpu seconds since last boot.
  printable   — Ensure that any binary logging content is escaped.
  uid         — If permitted, display the UID or Android ID of logged process.
  usec        — Display time down the microsecond precision.
  UTC         — Display time as UTC.
  year        — Add the year to the displayed time.
  zone        — Add the local timezone to the displayed time.
  "<zone>"    — Print using this public named timezone (experimental).
```

#### 过滤输出

过滤器表达式的格式为 `tag:priority ...`，其中tag表示感兴趣的标签，priority 表示要为该标签报告的最低优先级。tag 指定的优先级或以上的消息被输出。过滤器表达式中可以指定任意数量的 `tag:priority`, 只需使用空格分割即可。


过滤表达式可以使用通配符 `*`，下面的这个过滤器示例，抑制 ActivityManager 的 “Info” 或更高优先级以及 MyApp 的 “Debug” 或更高的之外的所有日志消息:

```shell
adb logcat ActivityManager:I MyApp:D *:S
```
表达式最后的 `*:S` 将所有 tag 的日志优先级设置为 "silent"，这确保了只有 "ActivityManager" 和 "MyApp"的日志可以输出。使用 `*:S` 可确保日志输出限制在表达式显式指定的过滤器，从而让表达式成为一个允许输出的表达式。

另外：在一些 shell 中，"*" 是保留字符。在这些 shell 中，需要使用引号包括过滤表达式，例如: adb logcat "ActivityManager:I MyApp:D *:S"

如果你频繁使用某一过滤表达式，可以在你的开发计算机上导出环境变量 `ANDROID_LOG_TAGS` 作为默认的过滤表达式。

```shell
export ANDROID_LOG_TAGS="ActivityManager:I MyApp:D *:S"
```

通过远程 shell 或者 adb shell logcat 使用 logcat 是，ANDROID_LOG_TAGS 过滤器并不会导入到给模拟器或设备。

#### 控制日志输出格式

logcat 不允许任意格式化输出内容或者任意指定输出哪些属性，只能从预定义的几种格式中选择一种。使用 `-v <format>` 指定以下格式中的其中一个：brief、long、process、raw、tag、threadtime（默认格式）。关于这些参数输出的哪些信息的内容可以使用 `logcat -h` 查看，这里不再一一赘述。需要说明的是，任何一种方式都会输出消息。这些格式只是控制消息之外的内容和输出格式。

尽管输出格式比较固定，但是，logcat 可以根据需要指定任意多的修饰符，只要它们有意义。Logca t忽略没有意义的修饰符。

#### 格式修饰符

格式修饰符更改 logcat 输出。要指定格式修饰符，使用 -v 选项，如下所示

```shell
adb logcat -b all -v color -d
```
格式修饰符在 logcat 的帮助文档中说的非常详细，不再展开，可以使用 `logcat -v -h` 查看。

### [Android Studio Logcat 窗口](https://developer.android.com/studio/debug/logcat)

安卓的 logcat 窗口非常易用，其功能跟命令行差别不大，具体可以查看官方文档。


参考：
https://source.android.com/docs/core/tests/debug/understanding-logging
关于日志系统的内部实现：
https://blog.csdn.net/u012873121/article/details/127989315
https://zhuanlan.zhihu.com/p/540550996
https://elinux.org/Android_Logging_System