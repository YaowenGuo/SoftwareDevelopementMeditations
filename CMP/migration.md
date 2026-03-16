# 迁移

## 项目结构
```
.
├── androidApp    安卓现有的 app 目录。
├── harmonyApp    增加鸿蒙目录，鸿蒙应用直接拷贝到这个目录下。
├── iosApp        以后 ios 项目移到这个目录下。
├── module
├── business
├── lib
├── tools
└── share         跨端目录、module、business、lib 下改造成跨平台应用时，移动到这个目录下。
    ├── module
    |   ├── module1
    |   ├── module2
    |   ...
    ├── business
    |   ├── business1
    |   ...
    └── lib
        ├── ubb
        ├── network/src      模块迁移示例，比如原有的 network 模块。
            ├── androidMain  原先安卓network 代码直接复制到这里来。
            ├── ohosarm64    鸿蒙特有代码
            ├── iosMain      IOS 特有代码
            ├── commonMain   跨端公共代码  新增加或者安卓代码修改后，复制到这里来。
        ...
```
