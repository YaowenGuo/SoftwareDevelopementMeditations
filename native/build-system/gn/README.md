# 编译 WebRTC 需要的一些工具

当我们需要编译 WebRTC 或者学习其它谷歌的项目的时候，很大程度会接触到谷歌的一套开发工具。以 WebRTC 为例：


1. [安装 depot tools](https://webrtc.googlesource.com/src/+/main/docs/native-code/development/prerequisite-sw/index.md)

2. 拉取项目
```
fetch --nohooks webrtc_android
```
3. 拉取代码

```
gclient sync
```

4. 生成 ninja 的编译文件
```
gn gen out/Debug --args='target_os="android" target_cpu="arm"'
```

5. 编译

```
autoninja -C out/Debug
```

[这些流程可以在这里找到](https://webrtc.googlesource.com/src/+/main/docs/native-code/android/index.md)

各个工具的文档

- [gclient](gclient.md)
- [什么是构建系统?](build_system_overview.md)
- [gn 简单入门](gn_getstart.md)
- [gn 的工具链和跨平台编译](gn_cross_compiling.md)
- [autoninja](autoninja.md)
