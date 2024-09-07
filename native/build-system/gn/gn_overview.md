
```
.
├── BUILD.gn               # 编译入口点
├── .gn                    # .gn 项目根编译配置。指定配置文件目录地方，有该文件的目录被作为项目根目录。 就是这个文件指定了 ‘build/BUILDCONFIG.gn’ 作为配置文件。
├── build                  # 配置目录，必须有
│   ├── BUILD.gn
│   ├── BUILDCONFIG.gn     # 主构建配置文件，必须有
│   └── toolchain
│       └── BUILD.gn
├── 代码
|  ...
```

1. `.gn` 首先导入了 `//build/dotfile_settings.gni`, 该文件定义了一些可以执行脚本的白名单。import 导入会执行该脚本中的内容。

2. `.gn` 接着导入 `BUILDCONFIG.gn`。
    1. 用于设置全局的一些变量，如 `is_linux`,`is_max`,`target_os` 等。
    2. 设置 toolchain.
