# 检查

通过检查性能，你可以了解应用程序中发生了什么，并确保它符合你的期望。

Android提供了几个工具，你可以用来检查你的应用程序的性能。在开始时，我们建议您在检查期间一次只关注一个方面。

这些领域包括：
- 应用启动
- 渲染缓慢（jank）
- 屏幕过渡和导航事件
- 长期运行的工作
- 背景中的操作，例如I/O和网络

或者，您可以检查应用程序工作流的关键用户流程。这可以帮助你全面了解性能和预期不一致的地方。

检查性能有两种主要方法，手动和自动。在检查一个新领域时，很可能从手动调试开始。

<<<<
性能是对资源利用的另一个视角审查：对性能的本质其实是对资源的利用，这些资源包括硬件资源： CPU、内存、电量、网络 以及软件资源（操作系统系统资源）线程数量、文件描述符、网络连接数量。其中软件资源的本质也是硬件资源，其是对应用可使用硬件资源的进一步限制。例如线程的数量限制本质是对可使用内存的限制。文件描述符也是对内存和 IO 资源的限制。
>>>>

解决性能问题涉及确定您的应用程序使CPU，内存，图形，网络或设备电池等资源效率低下的领域。

## 手动

在决定要检查应用的哪个区域之后，你可以使用各种工具来确定到底发生了什么。最全面的检查Android 9及以后设备性能的工具是[Perfetto](https://perfetto.dev/)。Perfetto为您提供尽可能详细的跟踪信息。通过使用强大的过滤器，您可以根据需要调整细节级别。有关如何从Android设备捕获跟踪的详细信息，请参阅快速入门:[在Android上记录跟踪指南](https://perfetto.dev/docs/quickstart/android-tracing)。

Android Studio内置的Android profiler也可以提供一些关于应用性能的有价值的见解，这些细节级别可能仅限于你的应用，或者在低于Android 9的设备上运行时。



## 自动

除了手动检查之外，您还可以设置自动测试来收集和聚合性能数据。这有助于您了解用户实际看到的内容，并确定何时可能出现回归。有关为应用程序设置自动性能测试的更多信息，请参阅对应用程序进行[基准测试]()。


Android Studio Profiling: https://developer.android.com/studio/profile

Perfetto 的文档：https://perfetto.dev/
perfetto 快速入门： https://perfetto.dev/docs/quickstart/android-tracing
有关性能调试的深入系列。https://www.youtube.com/playlist?list=PLWz5rJ2EKKc-xjSI-rWn9SViXivBhQUnp