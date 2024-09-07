# webrtc 支持鸿蒙

## 配置编译系统

### 1.1 配置目标系统和目标 cpu

gn 使用 target_os 和 target_cpu 来指定目标系统和 cpu，如果没有指定，它们在 `build/config/BUILDCONFIG.gn` 文件中配置为 host 系统的一样的值。可以通过参数指定，


```gn

```


### 1.2 工具链
