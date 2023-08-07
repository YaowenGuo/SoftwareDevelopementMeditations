# 直播

## 直播事件


muteLocalMic()  在 onRoomInfo 和 onMicApproved 调用，都没有起作用。 需要查一下原因。
```java
public native void muteLocalMic();
```

```java
public native void unMuteLocalMic();
```

1. muteLocal 出发 onDeviceEvent 
2. 远程 mute 则触发 onMicMute



## 回放

onConnected（仅直播）/onMediaInfo（仅回放） 连接后的第一个回调。

onRoomInfo 在拖动时会被再次回调。

