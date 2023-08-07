# GN & ninga

## 构建系统

软件开发中我们将程序由代码编译、链接、打包成包或者可执行程序，当代码比较少时，例如只是写一写算法程序，我们可以直接编译。如
```
gcc helloworld.c
```
但是当程序变得复杂时，例如编写一个软件，各个源文件之间的依赖关系变得不是那么好写了，同时庞大的文件数量我们并不想每次构建程序都手写一次，我们总是希望将复杂的关系写成文件或者脚本，然后可以随时就能很见到的执行编译。这样，构建系统出现了，例如 Make 构建工具。需要注意的是，构建系统并不是取代gcc这样的工具链，而是定义编译规则，最终还是会调用工具链编译代码。

然而，当软件规模进一步扩大，特别是有多平台支持需求的时候，编写  Makefile 将是一件繁琐和乏味的事情，而且极容易出错。这时就出现了生成Makefile的工具，比如cmake、AutoMake等等，这种构建系统称作元构建系统（meta build system）。构建和编译软件的步骤是：

./configure
make
make install

第一步 `./configure` 就是调用 AutoTool 工具，根据系统环境（Linux的版本众多，软件安装情况也不一样），生成GNU Makefile。


```
[构建规则] -- 元构建系统（CMake/AutoTool） --> [构建文件(编译指令和依赖关系)] --构建系统 (Make)--> 程序 --打包，封装等---> 软件
```

### Chromium 中的构建系统

元构建系统有很多，几年前的 chromium 开源项目采用的是GYP(Generate Your Projects）构建系统，而不是常见的 CMake。软件工程师根据 GYP 规则编写构建工程文件（通常以gyp, gypi为后缀），GYP工具根据gyp文件生成GNU Makefile。然而对于 chromium 这样的大型项目来说，make 的构建过程太慢了，于是 chromium 项目又整出了Ninja构建系统，用于取代GNU make，据谷歌官方的说法是速度有了好几倍的提升。

同时也推出了一个新的元构建系统 gn，用于生成构建文件。因为元构建系统就是用来生成构建文件的，除非深入研究，我们不用再深入了解 Makefile 和 gpy 怎么写了，因为只是一种中间输出。我们只需要会用 ninga 的构建指令即可。

GN文件相当于gyp文件的下一代，和GYP差别不大，但是总体上比原来的GYP文件更清晰。

## GN 构建系统

GN是一种元构建系统，来代替 GYP 生成 Ninja 构建文件（Ninja build files），相较GYP而言，具有如下优点：

- 可读性更好，更容易编写和维护。
- 速度更快，谷歌官方给的数据是20倍的速度提升。
- 修改GN文件后，执行ninja构建时会自动更新 Ninja 构建文件。
- 更简单的模块依赖，提供了public_deps, data_deps等，在GYP中，只有一种目标依赖，导致依赖关系错综复杂，容易引入不必要的模块依赖。
- 提供了更好的工具查询模块依赖图谱。这在GYP构建系统中是一个噩梦，要查一个目标依赖哪些模块或者一个模块被哪些目标依赖几乎是不可能的。
- 更好的调试支持。在GN中，只需要一条print语句就可以解决。

缺点:
为 chromium 项目编写的专用构建系统，并不容易在其他项目使用。好的是高版本的 CMake 已经可以生成 Ninga 构建文件了。

由于 GN 是为 Chromium 构建设计的项目，并没有对自动最小的脚本做特殊处理，所以想要用于其它项目的门槛比较高。甚至不同项目会根据需要对 GN 进行定制，因此需要查看具体项目的 gn 构建文档。当然，为了方便使用，[gn 项目](https://gn.googlesource.com/gn/)的 `examples/simple_build` 目录提供了一个最小的 GN 配置。


**gn 和 gclient 是为 chromium 专门构建的脚本工具，想要使用可以使用 CMake 代替**

### 运行GN

要运行 gn 有两种方式

方法一适合在有 `depot_tools` 的系统与 `depot_tools` 配合使用，兼容性更好。
方法二适合仅使用 gn 程序，方便创建自己的 gn 项目，或者用于学习 gn 测试。

#### 方式一：使用[depot_tools](https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up)中的 gn.

与其他构建系统（例如 CMake）是装在用户的机器上的不同，**GN 也是随项目一起进行版本控制和分发的。** 即 gn 直接包含在项目里，例如 webrtc/chromium 项目的 gn 位于项目目录的 `buildtools/[mac/linux/win]` 目录中。`mac/linux/win`分别是苹果、linux和 Windows 的目录，具体在那个一个目录，要看你的电脑是什么平台，之前说过了，根据你的开发电脑不同，gn 能够下载不同的依赖。 depot_tools 下的 gn 并不是 gn 构建程序。实际上是一个用户查找 gn 的脚本。该脚本的查找过程是：

- 先检查项目是否是 gclient 的项目，如果是
    - 则使用 gclient 项目 DEPS 配置的目录。例如 chromium 在 `src/third_party/gn/` 目录。但是 `webrtc` 配置是在 `src/buildtools/[mac/linux/win]` 目录，所以需要改一下脚本。

- 如果不存在，则查看是否配置了 `CHROMIUM_BUILDTOOLS_PATH` 环境变，配置了，则拼接上 `/[mac/linux/win]/` 目录下的 gn.

- 如果没有配置 `CHROMIUM_BUILDTOOLS_PATH` 会再次查找是否为 gclient 项目，不是，则结束查找，如果是：
    - 则使用 gclient solution 配置文件中指定项目目录下的 `buildtools` 是否存在，如果存在使用 `buildtools/[mac/linux/win]/` 目录下的 gn.
    - 如果 `buildtools//[mac/linux/win]/` 目录下的` 没有 gn, 则查看 `.gclient` 同级目录下是否有 `buildtools/[mac/linux/win]/`。

- 以上都没有，则报错。


然而遗憾的是，depot_tools 目录下并没有 gn 程序。因此需要配置 `CHROMIUM_BUILDTOOLS_PATH` 为 `chromium` 或 `webrtc` 等现有项目的目录，也可以根据官方文档，直接使用[自己编译 gn](https://gn.googlesource.com/gn/)). 然后将 `CHROMIUM_BUILDTOOLS_PATH` 设置为编译好的 gn 目录。

另外，因为是使用 `depot_tools` 的 gn，要先[配置好 depot_tools 的 环境](https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html#_setting_up)。

#### 方法二：自己编译 gn

这个[官网文档有](https://gn.googlesource.com/gn/)，就不介绍了。编译好后，将其路径加到 `PATH` 中。



### 生成构建文件

在GYP中，有两个特定的目录Debug和Release目录，分别用于生成Debug版本和Release版本。在GN中，采用了更灵活的方式，你随便指定一个目录，比如为了测试，定义一个test输出目录，可以采用如下的命令：

```shell
gn gen out/test
```



> 参考文档

[一篇很好的讲解 gn 作用的文章](https://blog.csdn.net/weixin_44701535/article/details/88355958)
[gn 编译安装](https://gn.googlesource.com/gn/)

[gn 快速入门](https://gn.googlesource.com/gn/+/HEAD/docs/quick_start.md)

[gn 语言](https://chromium.googlesource.com/chromium/src/tools/gn/+/48062805e19b4697c5fbd926dc649c78b6aaa138/docs/language.md)

[gn 参考手册](https://gn.googlesource.com/gn/+/master/docs/reference.md)