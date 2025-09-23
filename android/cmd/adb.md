# adb 使用


启动 app 带参数

```shell
adb shell am start -d 'shame://{path}?userJamId=38'
```


过滤日志

```
adb logcat | grep "tinker"
```
