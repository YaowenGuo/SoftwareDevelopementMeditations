# Native 代码

[历史上的版本记录，在 docs/release-notes.md](https://chromium.googlesource.com/external/webrtc/+/refs/heads/master/docs/release-notes.md)。 现在 WebRTC 这个文件不再更新了，新版本号和 Chromium 保持一致。[查看版本可以在 discuss-webrtc 搜索 Release Note](https://groups.google.com/g/discuss-webrtc/search?q=Release%20Notes), 2021/11/15 已经发布 M96 版本了。


[WebRTC Native API 旧文档](https://webrtc.github.io/webrtc-org/native-code/native-apis/)
[新文档地址](https://webrtc.googlesource.com/src/+/refs/heads/master/docs/native-code/index.md)



## 目录结构

```
.
├── BUILD.gn
├── CODE_OF_CONDUCT.md
├── DEPS
├── DIR_METADATA
├── ENG_REVIEW_OWNERS
├── LICENSE
├── OWNERS
├── PATENTS
├── PRESUBMIT.py
├── README.chromium
├── README.md
├── WATCHLISTS
├── abseil-in-webrtc.md
├── api // 定义了对外保留的接口部分，是可以别外部程序调用的部分。
│   ├── BUILD.gn
│   ├── DEPS
│   ├── OWNERS
│   ├── README.md
├── audio
├-- base
```