# FFmpeg (Fast Forward Moving Picture Expert Group 动态图像专家组)

FFmpeg 是软件领域里少数开源软件成为其领域的唯一选择的软件之一，淘汰了所有的对手。 FFmpeg 是一个开源跨平台多媒体库，提供录制、转换、以及流化视频的完整解决方案。既可以作为音视频处理工具使用，由于开发源代码，也可以作为音视频处理的开发组件。

FFmpeg 的历史：

FFmpeg 最初由法国程序员 Fabrice Bellard 在 2000 年的时开发出初版。2004 年 Michael Niedermayer 开始接手项目，并未其添加路径子系统 libavfilter，使得项目功能更加完善。

FFmpeg 包含几部分（库名中的 av: audio 和 video 的缩写）：

- 组件
- 开发库
    - libavformat： 实现了绝大多数多媒体格式的封装、解封装。如 MP4、FLV、KV、TS等文件格式封装，RTMP,RTSP,MMS,HLS等网络协议封装格式。具体可以在编译是配置，还可以扩展自己的封装格式。
    - libavutil: 其它库用到的工具库。
    - libswscale：图像缩放或者像素格式转换。
    - libswresample：允许操作音频重采样，音频通道布局转换、布局调整。
    - libavcodec：实现了绝大多数的编解码格式，如 MPEG4,JPG,MJPEG,三方编码 H.264(AVC), H.265(HEVC), mp3(mp2lame)。一些具有版权的编解码没有支持，但是得益于良好的封装，可以快速添加扩展，一些具有版权的编解码厂商也会实现用于 ffmpeg 的插件。
    - libavdevice：输入设备，操作摄像头等视频设备 , Android 中是不支持该操作, 需要手动关闭; 输出设备，如屏幕，如果要编译播放视频的 ffplay 工具，就需要依赖该模块。该设备模块播放声音和视频都又依赖 libsdl 模块。
    - libavfilter: 通用的音频、视频、字幕滤镜处理系统。
    - libpostproc: 该模块用于进行后期处理，当我们使用filter的时候，需要打开这个模块，filter会用到这个模块的一些基础函数。

- 命令行工具: 开发库之上构建的应用。
    - ffmpeg: 转封装，转码
    - ffplay：播放器（使用的是 avformat,avcodec）
    - ffprob: 多媒体分析工具。可以获取音视频的参数，媒体容器的参数等，媒体时长，符合码率等。


## 快速上手

可以[自定义编译](compile.md)或者从软件仓库安装。就可以立即使用。


参考内容:

https://blog.csdn.net/thezprogram/article/details/100029831
https://juejin.im/post/6844904048303276045#heading-9

ffmpeg参数讲解 https://blog.csdn.net/shulianghan/article/details/104351312
https://blog.csdn.net/yu540135101/article/details/105183294/
