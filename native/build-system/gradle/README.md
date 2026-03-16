# Gradle

首先明确 Gradle 是一个构建工具，而且定位一个通用构建自动化工具和依赖管理框架。不针对特定语言和平台，而是提供一套平台。这是Gradle设计哲学的关键：“核心提供机制，插件提供策略”。

Gradle 提供的核心能力：
- 任务模型
- 依赖管理
- 构建生命周期


## Gradle 安装

- 如果运行已有 gralde 项目，项目中会携带一个和具体版本绑定的脚本。目的就不会因为版本兼容性的问题引起编译错误。这也是为什么下载完项目就可以直接运行的原因。

- 如果是新创建项目，需要单独下载 gradle，并设置环境变量，使用 gradle 命令创建项目。

项目结构
├── gradlew / gradlew.bat   项目中 gradle 应该使用的命令。
├── gradle                  项目中携带的 gradle 版本。
│   ├── libs.versions.toml  定义项目依赖的文件
│   └── wrapper             项目中携带的 gradle 程序
├── gradle.properties       项目的一些属性
├── local.properties        个人需要修改的项目属性
├── settings.gradle.kts     项目的整体设置
├── build.gradle.kts        项目整体配置
├── build                   编译后的输出
├── ...                     子模块
├── ...


## gradle home 

在用户目录下的 .gradle 目录。 gradle wrapper 下载的内容都会下载到这个目录下，这样如果同一台机器上已经下载了同一版本的 gradle 后，就不用再次下载了。

.gradle
   |- init.d 初始化脚本，在该目录下的脚本，任何项目的 gradle 被执行时，该目录下的脚本都会执行。适合做一些所有项目都要执行的工作。



### 初始化脚本

`<USER_HOME>/.gradle/init.d` 目录下添加 `.gradle` 结尾的文件。例如 `build-announcements.gradle` 在构建成功或者失败后，桌面显示一条通知。

要对所有构建都起作用的一个合适的钩子是 `projectsLoaded`

```groovy
gradle.projectsLoaded { Gradle gradle ->
	gradle.rootProject {
		apply plugin: 'build-announcements'
	}
}
```

**一些回调必须在一个上下文环境中才有，例如这里的 `projectsLoaded` 在项目内的脚本中不会触发。因为项目创建发生在初始化阶段。**




## 启动守护进程(daemon)。

3.0 默认使用 Daemon，执行 gradle 等指令时，默认就会启动一个 Daemon 进程，而不必单独启动。 JVM 的启动非常慢，因此 启动一个 Deamon JVM。每次 Gradle 不再启动 JVM，而是将指令发给 Deamon，以此来加快运行速度。

有兼容性问题，例如 gradle 版本不一致，运行内存更大。如果不兼容，会再次启动一个 Daemon 进程。

默认 Daemon 运行三个小时就会自动关闭。

可以使用 --no-deamon 来禁用 daemon 进程。

gradlew stop


## 执行命令

gradle 命令本身是一个脚本，由它再启动 Gradle 构建程序。 gradle 的构建脚本名默人为 `build.gradle`，当执行 gradle 命令时，脚本就会在命令执行的目录查找 `build.gradle` 文件。 先写个 `Hello World` 示例：

```
// build.gradle
task helloWorld() {
    doLast {
        println 'Hello world!'
    }
}
```

然后在当前目录下即可运行.
```
$ gradle -q helloWorld
```

`-q` 意为 `quiet`，使 gradle 仅输出 task 的输出。它是可选的。
