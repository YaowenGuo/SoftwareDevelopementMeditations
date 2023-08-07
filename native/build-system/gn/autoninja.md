# autoninja

autoninja 是 deptools 脚本，实际上是 ninja 的检查和辅助信息打印工具。并且会上传编译数据到 google 用于反馈信息。

`autoninja` 的参数都会传递给 `ninja`，并做一些额外的检查，和数据上报。

```
autoninja -C out/ios_64
```

以统计的格式输出编译。可以设置环境变量

```
export NINJA_SUMMARIZE_BUILD=1
```

则输出格式为

```
metric           	count 	avg (us) 	total (ms)
.ninja parse     	1217  	1675.5  	2039.1
canonicalize str 	251268	0.2     	39.0
canonicalize path	251635	0.1     	21.5
lookup node      	255672	0.2     	44.2
.ninja_log load  	1     	2106.0  	2.1
.ninja_deps load 	1     	19838.0 	19.8
node stat        	12377 	3.0     	36.7
depfile load     	1     	658.0   	0.7
StartEdge        	23    	1297.1  	29.8
FinishCommand    	13    	390.7   	5.1
```

增加了 `-o/--offline` 参数，

`autoninja.py` 检测是否使用 `goma` 进行远程编译加速。分别对应于 `use_goma=true` 和 `use_rbe=true` 参数：

```
gn gen out/ios_64 --args='target_os="ios" target_cpu="arm64" ios_enable_code_signing=false use_goma=true use_rbe=true'
```

`autoninja.py` 只是用于自动优化编译参数，并不是执行编译。而是将优化后的命令行参数返回，编译还是在 `autoninja` 的 `if eval "$command"; then` 执行的。

## goma 

goma 是 chromium 内部使用一个分布式编译服务，用于加速编译。客户端在 `{$dept_tools}/.cipd_bin` 目录下。

[文档](https://chromium.googlesource.com/infra/goma/client/)

如果经常为 webrtc 和 chromium 项目做贡献，可以[向 google 申请使用编译服务]()。


## 总结

autoninja 做了一些检查和优化工作。例如使用 `goma` 进行分布式编译加速。自动优化编译参数，例如执行:

```shell
$ autoninja.py -C out/ios_64
```

在我的机器上优化后结果为

```shell
$ /opt/depot_tools/ninja -C out/ios_64 -j 10 -d stats
```