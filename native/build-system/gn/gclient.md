# GClient

GClient 是一个跨平台的 git 仓库管理工具。可以有多个 git 仓库组成一个 solution(工程)。一个项目可能引用不同的其他项目作为一个模块，例如网络请求。不同于一些包管理工具，gclient 要求这些模块必须是一个 git 仓库。之所以这样是因为 gclient 处理的 Native 平台项目，Native 代码通常不同平台上依赖于不同的代码，而 gclient 能够根据不同平台检出不同的仓库。

gclient 包装了基础的代码仓库管理命令，以提供对目录树中多个子工作目录的更新、状态查询、和 diff 差异命令。类比一下 repo 或 git submoudles。 相比之下 gclient 支持根据平台检出不同依赖。例如根据要开发的项目是 IOS 还是安卓检出不同的依赖库和工具链。

## 2.相关概念

- hooks: 当gclient拉完代码后执行的额外脚本；
- solution: 一个包含DEPS文件的仓库，可以认为是一个完整的项目；
- DEPS: 一个特殊的文件，规定了项目依赖关系；
- .gclient：一个特殊文件，规定了要拉取的solution，可由gclient config命令创建出来；
- include_rules：指定当前目录下哪些目录/文件可以被其他代码include包含，哪些不可以被include。


## gclient config

该命令会生成 `.gclient` 文件，用于初始化要拉取的 `solution`。`.gclient` 用于记录 Solution 的仓库地址，以及目标平台。在子目录下执行 gclient 指令时，也是递归寻找父目录中的 `.gclient` 文件所在的目录作为项目根目录。`.gclient` 文件是 python 脚本格式，内部定义了一个如下格式名为 `solution` 的列表：


```
solutions = [
  { "name"        : "src", # 项目要检出到的目录名
    "url"         : "https://chromium.googlesource.com/chromium/src.git", # 项目检出的仓库。
    "custom_deps" : {
      # To use the trunk of a component instead of what's in DEPS:
      #"src/component": "https://github.com/luci/luci-go",
      # To exclude a component from your working copy:
      #"src/data/really_large_component": None, // 路径需要加上项目的目录名，如 src.
    }
  },
]

target_os = []
```

> solutions 列表的每一项都是一个 python 字典对象。

- name: checkout 出源码的目录名。跟 `.gclient` 放在同一目录。
- url: 项目检出的仓库。 gclient期望检出的解决方案将包含一个名为DEPS的文件，该文件又定义了必须检出的特定部分，以创建用于构建和开发解决方案的软件的工作目录布局。

- deps_file： 一个文件名，而不是路径。存在于 name 定义的项目目录下，用于定义依赖项列表。 此标记是可选的，默认为DEPS。

- custom_deps： 一个包含可选字段的字典类型，可选字段用于覆盖 DEPS 文件中的条目。可以用于定制使用本地目录，以避免检出和更新特定组件，或将给定组件的本地工作目录副本同步到其他特定版本，分支或树的头部。 它也可以用于附加DEPS文件中不存在的新条目。

- target_os 和 target_os_only 这个可选的条目可以指出特殊的平台，根据平台来checkout出不同代码，如 `target_os = ['android']` 如果target_os_only值为True的化，那么，仅仅checkout出对应的代码。

> cache_dir


## .gclient_entries 文件

`gclient_entries` 文件在执行 `gclient sync` 时生成。它包含 gclient 已经同步的条目，用于告诉gclient 不用再次同步（减少同步过程，可以理解为缓存条目）。

仅定义了一个 `entries` python 格式的字典。跟 `DEPS` 中 `deps` 格式一样。

## DEPS 文件

include_rules 定义了包含路径。

deps 定义了要下载的组件的目录和下载地址。


### 同步 gclient sync

该命令用于同步solution的各个仓库，它有一些参数：

- `-f、--force`: 强制更新未更改的模块；
- `--with_branch_heads`： 除了clone默认refspecs外，还会clone "branch_heads" refspecs;
- `--with_tags`: 除了默认的refspec之外，还可以clone git tags;
- `--no-history`： 不拉取git提交历史信息；
- `--revision <version>`: 将代码切换到 version 版本 ;
- `--nohooks`：拉取代码之后不执行hooks。

- 拉取代码主要是根据DEPS文件来进行，也可以由 `deps_file` 定制的文件名。该文件定义了项目不同组件必须检出的依赖。DEPS文件是一个Python脚本，它定义了一个名为 `deps` 的字典。

```
deps = {
  "src/outside": "https://outside-server/one/repo.git@12345677890123456778901234567789012345677890",
  "src/component": "https://dont-use-github.com/its/unreliable.git@0000000000000000000000000000000000000000",
  "src/relative": "/another/repo.git@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
}
```

每一项由 `"检出目录": "git 仓库地址@提交节点"` 组成。检出目录是相对于 .gclient 文件的相对路径。该值是将从中检出该目录的URL。 如果没有地址方案（即没有http：前缀），则该值必须以斜杠开头并且相对于检出方案仓库的根的路径。节点 id 如果没有指定，则会下载该仓库的最新节点。

- vars：定义字符串变量，一般用于替代公共的字符串，然后通过Var来获取实际的值:

```
vars = {
    'chromium_git': 'https://chromium.googlesource.com'
}

deps = {
    'src/chrome/browser/resources/media_router/extension/src': Var('chromium_git') + '/media_router.git' + '@' + '475baa8b2eb0a7a9dd1c96c9c7a6a8d9035cc8d7',
    'src/buildtools': Var('chromium_git') + '/chromium/buildtools.git' + '@' +  Var('buildtools_revision')
}
```

deps 可以包含条件，满足条件才下载

```
deps = {
  src/third_party/android_ndk': {
      'url': 'https://chromium.googlesource.com/android_ndk.git@401019bf85744311b26c88ced255cd53401af8b7',
      'condition': 'checkout_android',
  }
}
```

condition 在 gclient 中限定，用户指示目标平台。

```python
    def get_builtin_vars(self):
    return {
        'checkout_android': 'android' in self.target_os,
        'checkout_chromeos': 'chromeos' in self.target_os,
        'checkout_fuchsia': 'fuchsia' in self.target_os,
        'checkout_ios': 'ios' in self.target_os,
        'checkout_linux': 'unix' in self.target_os,
        'checkout_mac': 'mac' in self.target_os,
        'checkout_win': 'win' in self.target_os,
        'host_os': _detect_host_os(),

        'checkout_arm': 'arm' in self.target_cpu,
        'checkout_arm64': 'arm64' in self.target_cpu,
        'checkout_x86': 'x86' in self.target_cpu,
        'checkout_mips': 'mips' in self.target_cpu,
        'checkout_mips64': 'mips64' in self.target_cpu,
        'checkout_ppc': 'ppc' in self.target_cpu,
        'checkout_s390': 's390' in self.target_cpu,
        'checkout_x64': 'x64' in self.target_cpu,
        'host_cpu': detect_host_arch.HostArch(),
    }
```


- Hooks：DEPS包含可选的内容 hooks，也有重要的作用，它表示在sync, update或者recert后，执行一个hook操作,也即执行对应的脚本；

```
hooks = [
  {
    # This clobbers when necessary (based on get_landmines.py). It should be
    # an early hook but it will need to be run after syncing Chromium and
    # setting up the links, so the script actually exists.
    'name': 'landmines',
    'pattern': '.',
    'action': [
        'python',
        'src/build/landmines.py',
        '--landmine-scripts',
        'src/tools_webrtc/get_landmines.py',
        '--src-dir',
        'src',
    ],
  },
  ...
}
```
每个hook有几个重要项:
 pattern 是一个正则表达式，用来匹配工程目录下的文件，一旦匹配成功，action项就会执行

 action 描述一个根据特定参数运行的命令行。这个命令在每次gclient时，无论多少文件匹配，至多运行一次。这个命令和.gclient在同一目录下运行。如果第一个参数是"python"，那么，当前的python解释器将被使用。如果包含字符串 "$matching_files"，它将该字符串扩展为匹配出的文件列表。

 name 可选，标记出hook所属的组，可以被用来覆盖和重新组织。



- deps_os：根据不同的平台定义不同的依赖工程，可选的包括：

```
deps_os = {
  "win": {
    "src/chrome/tools/test/reference_build/chrome_win":
      "/trunk/deps/reference_builds/chrome_win@197743",
.....
  },

  "ios": {
    "src/third_party/GTM":
      (Var("googlecode_url") % "google-toolbox-for-mac") + "/trunk@" +
      Var("gtm_revision"),
....
   },
...
}
```

和 `.gclient` 中 `target_os` 的对应关系如下， 支持的平台有（第二列是可用的平台标识符，第一列是 target_os 指定的）：
```
DEPS_OS_CHOICES = {
  "aix6": "unix",
  "win32": "win",
  "win": "win",
  "cygwin": "win",
  "darwin": "mac",
  "mac": "mac",
  "unix": "unix",
  "linux": "unix",
  "linux2": "unix",
  "linux3": "unix",
  "android": "android",
  "ios": "ios",
  "fuchsia": "fuchsia",
  "chromeos": "chromeos",
}
```

[GClient 使用](https://www.cnblogs.com/xl2432/p/11596695.html)


## 其他指令

> 获取 gclient 的根目录，在项目的任意子目录中执行：

```
$ gclient root
```

> 指定 `.gclient` 文件内容

```
$ gclient config --spec 'solutions = [
  {
    "name": "src",
    "url": "https://webrtc.googlesource.com/src.git",
    "deps_file": "DEPS",
    "managed": False,
    "custom_deps": {},
  },
]
target_os = ["linux", "android", "mac"]
'
```

> gclient runhooks

执行hooks。当你拉取代码时使用了--nohooks参数时，就可以使用该命令来手动执行hooks。

> gclient recurse

在每个仓库中都执行一条 git 命令

> gclient fetch

相当于每个仓库都执行了git fetch操作。

类似还有 `gclient status`, `gclient diff`等。


## 同步指定版本

进行同步时，可以指定特定分支。如需同步M74分支：

# gclient sync -r cc1b32545db7823b85f5a83a92ed5f85970492c9