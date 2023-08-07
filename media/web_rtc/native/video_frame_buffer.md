# VideoFrameBuffer

```
                                            VideoFrameBuffer
                                                   ^
                                                   |
                                ┌------------------┴------------------┐
                        PlanarYuvBuffer                          BiplanarYuvBuffer
                            ^                                         ^
                            |                                         |
            ┌---------------┴---------------┐                         |
        PlanarYuv8Buffer             PlanarYuv16BBuffer      BiplanarYuv8Buffer
            ^                                 ^                       ^
            |                                 |                       |
  ┌---------┴---------------┐                 |                       |
I420BufferInterface  I444BufferInterface  I010BufferInterface  NV12BufferInterface
   ^
   |
I420ABufferInterface
```



```
                                            VideoSourceInterface
                                                   ^
                                                   |
                    MediaStreamTrack         VideoSourceBase         ObserverInterface
                            ^                      ^                       ^
                            |                      |                       |
                             ----------------- VideoTrack ------------------
                                                   ^
                                ┌------------------┴------------------┐
                        PlanarYuvBuffer                          BiplanarYuvBuffer
                            ^                                         ^
                            |                                         |
            ┌---------------┴---------------┐                         |
        PlanarYuv8Buffer             PlanarYuv16BBuffer      BiplanarYuv8Buffer
            ^                                 ^                       ^
            |                                 |                       |
  ┌---------┴---------------┐                 |                       |
I420BufferInterface  I444BufferInterface  I010BufferInterface  NV12BufferInterface
   ^
   |
I420ABufferInterface
```
