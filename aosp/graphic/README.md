# 图形系统



## 安卓的实现

![安卓图形系统](README_img/android_window_render_architecture.svg)


## 应用测管理

Activity:
attach 就已经创建了 PhoneWindow。

ActivityThread.handleResumeActivity 调用 Activity.onResume 后调用 makeVisible 中调用  wm.addView(mDecor, getWindow().getAttributes()); 添加 WiewRootImpl。

应用侧窗口对应的是 WindowManagerImpl（这个名字起的很怪，我都感觉它和 PhoneWindow 命名取反了，起始是架构演进的历史问题，名字没有改。），





[Protetto 帮助理解图形架构:一帧从 app 到上屏的  systrace 图示](https://mp.weixin.qq.com/s/qHG4bwqqmxyWfWA9-GXy-w)