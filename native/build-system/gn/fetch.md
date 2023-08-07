# dept tools 的 fetch

fetch 命令对应于 `depot tools` 目录下的 `fetch.py`, 是是为了生成 `gclient` 需要的`.gclient`项目配置信息，方便使用 `gclient sync` 同步整个项目代码。并且能够检出仓库，执行 `gclient sync` 同步好整个项目。

```
fetch [option1 [option2 ...]] <config> [--property=value [--property2=value2 ...]]
```

如
```
fetch --nohooks webrtc_android
```
就会在当前目录下生成一个

## 支持的选项参数 `option`

```
-h, --help, help   Print this message.
--nohooks          Don't run hooks after checkout.
--force            (dangerous) Don't look for existing .gclient file.
-n, --dry-run      Don't run commands, only print them.
--no-history       Perform shallow clones, don't fetch the full git history.
```

## config

`<config>` 是 `depot_tools/fetch_configs` 下的一个 python 脚本文件，是关于一个项目的配置信息。例如 `webrtc_android` 就对应于一个 `webrtc_android.py`

写法也很简单，


以 chromium 项目为例 `depot_tools/fetch_configs/chromium.py` 的配置格式为。

```python
class Chromium(config_util.Config):
  """Basic Config class for Chromium."""

  @staticmethod
  def fetch_spec(props):
    url = 'https://chromium.googlesource.com/external/gyp.git'
    solution = { 'name'   :'gyp',
                 'url'    : url,
                 'managed'   : False,
                 'custom_deps': {},
    }
    // spec 指定的 json 格式只需要和 .gclient 的格式一致即可。
    spec = {
      'solutions': [solution],
    }
    return {
      'type': 'gclient_git',
      'gclient_git_spec': spec,
    }

  // 指定 gclient 下载的仓库根目录名。
  // 如果是 git, 类似于
  // git <repository> src
  @staticmethod
  def expected_root(_props):
    return 'src'


def main(argv=None):
  return Chromium().handle_args(argv)


if __name__ == '__main__':
  sys.exit(main(sys.argv))
```

- solution 的内容就是 `.gclient` 文件内 `solution` 对应的结构，具体查看[gclient](gclient.md)

- type: 支持三种：
    - gclient:
    - gclient_git: client 仓库，谷歌的项目一般是这种。
    - git: 纯 git 仓库

- [type]_spec: 指定和 `.gclient` 的 json 格式的配置。

- 指定的 property 配处理成和 solution 同级的 json 数据。例如，
```
$ fetch --nohooks  fetch_test  --target_os=linux,android,mac
```

`--target_os=linux,android,mac`对应于

```json
{
  ...
  "gclient_git_spec": {
    "solutions": [
      ...
    ],
    "target_os": [
      "linux",
      "android",
      "mac"
    ]
  }
}
```

## 支持的属性参数 `--property`

参数的值可以通过逗号 `,` 分割多个，例如 `--target_os=linux,android,mac`。