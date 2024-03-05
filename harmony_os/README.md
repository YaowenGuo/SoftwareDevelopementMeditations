# 入门

1. Ability

Ability是应用所具备能力的抽象，也是应用程序的重要组成部分。一个应用可以具备多种能力（即可以包含多个Ability）。HarmonyOS 支持应用以 Ability 为单位进行部署。

Ability分为两种类型，每种类型为开发者提供了不同的模板，以便实现不同的业务功能。
- FA（Feature Ability）支持Page Ability模板，以提供与用户交互的能力。一个Page Ability可以含有一个或多个页面（即Page）。
- PA（Particle Ability）


1. 应用包结构

.
├── AppScope
├── build-profile.json5               // 应用级配置信息，包括签名、产品配置等。
├── entry
│   ├── build
│   ├── build-profile.json5
│   ├── hvigorfile.ts
│   ├── obfuscation-rules.txt
│   ├── oh-package.json5
│   └── src
│       ├── main
│       │   ├── ets               // ArkTS源码
│       │   │   ├── entryability  // 应用/服务的入口。相当于 AndroidManifest.xml
│       │   │   └── pages         // 页面
│       │   ├── module.json5
│       │   └── resources         // 资源文件
│       │       ├── base
│       │       │   ├── element   // 字符颜色资源
│       │       │   │   ├── color.json
│       │       │   │   └── string.json
│       │       │   ├── media     // 媒体文件
│       │       │   │   ├── icon.png
│       │       │   │   └── startIcon.png
│       │       │   └── profile
│       │       │       └── main_pages.json // 页面的路由
│       ├── mock
│       │   └── mock-config.json5
├── hvigorfile.ts          // 应用级编译构建任务脚本。


跳转页面
```
router.push({ url: 'pages/second' })
```
返回
```
router.back()
```
