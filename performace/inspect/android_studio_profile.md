# Android Studio Profile

- CPU profiler helps track down runtime performance issues.
- Memory profiler helps track memory allocations.
- Energy profiler tracks energy usage, which can contribute to battery drain.
- Network profiler

这些工具可以在Android 5.0 (API级别21)及更高版本上使用。


## Profileable

Profileable 是Android q(10)中引入的一个 manifest 配置，它可以指定设备用户是否可以通过 Android Studio、Simpleperf和Perfetto等工具来分析该应用程序。

在 profilable 出现之前，开发人员只能在分析 Android 上可调试的应用程序，可调式应用增加了显著的性能消耗。这些性能消耗可能会使分析结果无效，特别是当它们与时间有关时。Profileable 的引入是的开发人员可以选择允许APP暴漏信息给分析工具，同时产生很少的性能损失。一个 profileable APK 本质上是一个在 `AndroidManifest.xml` 文件的 ` <application>` 节点上配置了 `<profileable android:shell="true"/>` 的 release apk.

[表1总结了可调试和可分析应用程序之间的区别。](https://developer.android.com/studio/profile)
