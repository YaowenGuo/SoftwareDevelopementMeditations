## 多媒体开发

由于性能和硬件关联问题，音视频开发绝大多数都是使用 C/C++ 开发的。

音视频主要设计到几个方面：

1. 音视频同步，编解码：FFmpeg（软解码）， H264 编码原理。
2. MediaCodec 硬解码
3. Rtmp 协议实现直播拉流（看直播）
4. 硬编码下实现直播推流
5. 音视频编辑技术
6. 特效制作： OpenGL ES
7. WebRTC 实现 PTP 语音通话
8. 多人视频会议（降噪，回声消除）。

```
音/视频采样 ---> 处理/编辑 --> 编码(封装) -------┐
                                           传输(推送/拉取)
播放       <--处理/编辑   <--解码(解封装)<------┘
```

`采样(输入)`: 采样也就是摄像头的传感器和录音的传感器捕捉到的物理变化转为为数据记录下来。因为具体牵涉到硬件，不同的平台会有不同的处理，许多应用都有音视频采集能力，如 ffmpeg、webrtc 等，但都是要判断不同系统，调用系统的方法获取数据。

`播放(输出)`: 输出就是将采集到的图片或者视频显示到屏幕、将采集到声音输出的扬声器。同样涉及硬件，同时不同的系统对与多媒体的输出也会有上层的 API 可用使用，以方便开发者。

处理/编辑：
    音频的处理包括 3A ()处理，变声，混音等。
    视频的处理包括加特效，滤镜等。
    有些场景需要实时性，例如在音视频通话中，就需要实时处理噪音或者美颜效果。而有些编辑特效可以在现有的视频上处理。

编码/解码：
    编解码是一对操作。音视频的数据量太大了，无论用于网络传输还是存放在磁盘里，都会占用大量的资源。为了减少对资源的占用，于是编解码器应运而生，编码器对原始的音视频数据进行了有规则的压缩处理，在不影响体验效果的情况下降低数据量。音视频的数据具有独立的特性，使用的编解码也是完全独立的。而解码器则是把压缩的数据进行还原，方便播放，不同的编解码算法，编解码质量不同，速度也不同。

传输：
    主要指网络传输。由于音视频的数据量巨大，在传输是需要对抗各种网络问题。特别是在实时通话时，需要考虑的更更多。涉及技术细节有传输延时，网络抖动，丢包处理，p2p传输，NAT打洞 ......

封装：
    封装和编码是两个完全独立的概念，对于实时通话，数据可以直接通过网络传输。我们只对数据进行压缩即可。然而对于需要存储的音视频数据。我们需要将其保存的文件中，这被称为封装。不同于普通的数据（顺序存储即可）音视频数据需要保存额外的信息，例如音频需要保存采样率、采样位深，由于压缩后的数据大小也会不同，还需要保存帧大小。此外，当播放时我肯可能会快进到某个进度，这就需要能够快速定位到某个时间的数据。因此需要针对音视频设计独特的存储格式；也被成为封装。

音视频同步：
    当同时具有音视频时，在播放时还涉及到音画同步，我们有时候会看到一些视频的对话和画面中人物的口型对不上的问题。音视频数据需要独立的设备处理，不同的设备处理速度不同，就需要在播放时处理这种不同步的问题。

## 视频

如同眼睛和耳朵是两套系统，视频的视频和音频是两套独立的数据格式。这些数据被按照约定的格式（封装规范）存储在文件中，这些文件被称为封装格式。

```
         ┌ 音频
视频文件 -┤
         └ 视频
```

> 封装格式

常用视频封装格式有：
- mp4、RMVB、AVI、FLV。

常用的音频封装格式有：
- mp3、、zip


> 编码格式

视频：
- H264/ABC、H265/HEVC、H266/VVC、AV1

音频：
- AAC(MP4 文件中常用的音频编码格式)、Opus.


## 视频

https://www.techsmith.com/blog/frame-rate-beginners-guide/#:~:text=Most%20feature%20films%20and%20TV,toward%20a%20more%20cinematic%2024fps.

https://mp.weixin.qq.com/s/GeLMneMIgKIXpXp5iMqFzQ

### 视频的一些数据

> 帧 (Frame)

帧就是视频播放中的一张图片，视频的播放是逐帧显示图片。

> 帧率(Frame rate)

每秒显示帧数(Frames per Second，简：FPS）或“赫兹”（Hz）。

由于人类眼睛的特殊生理结构，如果所看画面之帧率高于16的时候，就会认为是连贯的，此现象称之为视觉停留。这也就是为什么电影胶片是一格一格拍摄出来，然后快速播放的。

每秒的帧数(fps)或者说帧率表示图形处理器处理场时每秒钟能够更新的次数。高的帧率可以得到更流畅、更逼真的动画。一般来说30fps就是可以接受的，但是将性能提升至60fps则可以明显提升交互感和逼真感，但是一般来说超过75fps一般就不容易察觉到有明显的流畅度提升了。如果帧率超过屏幕刷新率只会浪费图形处理的能力，因为监视器不能以这么快的速度更新，这样超过刷新率的帧率就浪费掉了。24FPS、30FPS、60FPS.



常见的帧率有：

- [音视频基础知识](principle/README.md)
    - [音频](principle/audio/README.md)
    - [视频](principle/video/README.md)

- [Ffmpeg](ffmpeg/README.md)
- [录屏](https://www.jianshu.com/p/8b313692ac85)
