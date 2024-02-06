# 渲染

ExoPlayer 使用 Renderer 负责所有的显示。ExoPlayerImpl 加载数据后，将数据分类，根据类型传递给不同类型的 Renderer。

- 视频传递给：MediaCodecVideoRenderer
- 音频传递给：MediaCodecAudioRenderer
- 文字传递给：TextRenderer
- 图片传递给：ImageRenderer
- CameraMotionRenderer
- MetadataRenderer

另外两个 DecoderAudioRenderer 和 DecoderVideoRenderer 是抽象类，应该是留给用户的接口。

**Renderer 得到的是原始数据，根据需要自己负责处理编解码等处理工作**

## Video

在 MediaCodecVideoRenderer 中， SynchronousMediaCodecAdapter 负责将视频解码。如果是 TextureView, 会创建一个 Surface，将 Surface 直接传递给硬解码器，直接渲染。

解码后

MediaCodecVideoRenderer.processOutputBuffer 中处理后继