# adb 使用


启动 app 带参数

```shell
adb shell am start -d 'fbgwy://fenbi.com/interview_mock/prepare?userJamId=38'
```


过滤日志

```
adb logcat | grep "tinker"
```

## 查看 tombstones

新版的手机除非 root，否则无法查看 `/data` 目录下的内容。也就无法获取 `ANR` 和 `tombstones` 崩溃信息。因此 adb 提供了一个额外的指令来下载这些文件到本地。

```
adb bugreport
```
该指令会生成一个 zip 文件到本地。解压就能获取各种崩溃信息的文件。在 `FS/data` 下分别有 anr 和 tombstones 文件夹，里面便是对应文件。

解析 tombstone： https://stackoverflow.com/questions/28105054/default-tombstones-location-in-android
其它生成方式： https://developer.android.com/studio/debug/bug-report?hl=zh-cn