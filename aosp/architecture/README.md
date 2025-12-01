# 架构

## AOSP architecture

The software stack for AOSP contains the following layers:

![AOSP architecture](img/android-stack.png)


HAL：硬件抽象层。有些应用程序需要硬件支持，比如显示器、相机、蓝牙等。这些硬件需要供应商提供 HAL 实现，应用层通过 HAL 接口与硬件进行交互。


## Graphics


各种渲染 -> Surface(生产方) ---> SurfaceFlinger(消费方) -> 显示硬件

- Surface 和 Window 不是绑定关系，Surface 物理绘图表面。例如每个 SurfaceView 都有一个 Surface。Window 是逻辑概念，是应用程序的一个窗口，可以包含多个 Surface。

- TextureView：不创建独立 Surface，而是作为 View 层次的一部分共享主 Surface

```
应用进程
├── Activity 1 → Window 1 → Surface 1 (独立)
├── Activity 2 → Window 2 → Surface 2 (独立) 
├── Dialog 1 → Window 3 → Surface 3 (独立)
└── Toast → Window 4 → Surface 4 (独立)
    ↓
SurfaceFlinger (系统服务)
    ↓
显示屏
```

### VSync 

VSYNC 全称为 Vertical Synchronization，垂直同步信号。它是显示控制器在显示完一帧数据后，向图形处理单元（GPU）发送的一个信号，表示可以开始下一帧数据的填充。

1. 内核图形驱动执行中断处理，驱动将事件传到 Hardware Composer (HWC) HAL 回调路径，内核中断是如何传递到 HWC 的？

2. SurfaceFlinger + HWC HAL：接收到 per-display VSYNC 回调 (注册监听 poll() / epoll() vblank)，写入 DispSync，预测下一帧节奏，安排合成线程和应用帧调度

3. 应用使用 DisplayEventReceiver 在主线程 Looper 里监听这个 FD（Looper.addFd()）。当 socket 有数据可读，唤醒主线程，在 onVsync()/handleMessage() 内部回调到 Choreographer.doFrame.


- 重点：每帧 VSYNC 不走 Binder（避免过高开销），而是使用已建立的轻量级本地 socket (BitTube)；Binder 只用于建立通道与管理生命周期。


### VSync 与 Buffer 切换时机

时间线：

1. 硬件 VSYNC（vblank 中断）本质表示：上一帧最后一行像素已经扫描完，显示控制器进入垂直消隐区（Vertical Blank Interval）的开始。

2. front/back buffer 的切换（page flip 指针生效、plane/CRTC 重新指向新缓冲）通常被安排在这段垂直消隐区内，在下一帧真正开始扫描之前。换句话说：你在上一帧显示期间提前“预约”了 page flip，它在 VSYNC 边界生效。

3. 软件里看到的“vsync 回调”常是经过预测/延迟的节拍事件，它代表“请开始准备下一帧”，而不是“刚刚完成了 page flip”。

4. 如果应用没准备好新缓冲，VSYNC 仍会按时发生，只是没有新的 page flip，旧 front buffer 会继续被扫描一帧（出现重复帧）。

5. VRR（可变刷新率）下 VSYNC 间隔可以变化；page flip 仍在扫描启动前那一刻完成（逻辑保持不变，只是周期变量）。

- Vertical Active： 正在逐行读取 front buffer 并发送像素的时间段。
- Vertical Blank (VBlank)：一帧扫描结束与下一帧开始之间的间隔；此时不会往屏幕输出新像素，是做模式切换、page flip 的窗口。

### SurfaceFlinger
