# webrtc 支持鸿蒙

主要是涉及到硬件调用的模块需要重写，以及编译工具链需要使用鸿蒙的。

- modules/audio_device
- modules/video_capture
- third_party
 BUILD.gn
 build_android.sh
 build_harmony.sh
 rtc_base/platform_thread.cc
 rtc_base/platform_thread_types.cc
 webrtc.gni
## 配置编译系统


### 1.1 配置目标系统和目标 cpu

gn 使用 target_os 和 target_cpu 来指定目标系统和 cpu，如果没有指定，它们在 `build/config/BUILDCONFIG.gn` 文件中配置为 host 系统的一样的值。可以通过参数指定，


```gn

```


### 1.2 工具链

src/build



commit 39a444b8d570e6a5520db55fbe687aea2685462d (HEAD -> harmony)
Author: guoyaowen <guoyw01@fenbi.com>
Date:   Fri Feb 6 10:53:02 2026 +0800

    Fix video capture error on harmony 6.0.

commit 8633fbfb50a188aae616faf1c219b31ea05b138a
Author: guoyaowen <guoyw01@fenbi.com>
Date:   Thu Dec 4 17:49:21 2025 +0800

    Fix audio orientation can't change when use free microphone queue.

commit f5e37d8f5d410fd901340d2adfe0fa8184319ffe (live)
Author: guoyaowen <guoyw01@fenbi.com>
Date:   Thu May 8 20:35:06 2025 +0800

    :Support ohos.

commit 1502c07c128fbbe07ee0e792c9396dbbfa21c5f6
Author: jiaohq <jiaohq01@fenbi.com>
Date:   Tue Jul 23 19:21:07 2024 +0800

    mod: add arg is_ios_arm64_sim
