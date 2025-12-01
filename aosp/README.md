# 开发环境

## repo 清华源

```
mkdir ~/bin
curl https://mirrors.tuna.tsinghua.edu.cn/git/git-repo  > ~/bin/repo
chmod a+x ~/bin/repo
export PATH=~/bin:$PATH
```
可以将如下内容复制到你的 `~/.bashrc` 里，并重启终端或者执行 `source ~/.bashrc`

```
export REPO_URL='https://mirrors.tuna.tsinghua.edu.cn/git/git-repo'
```


##  download aosp

设置下载的目标版本
```
mkdir aosp && cd aosp

repo init -u https://mirrors.tuna.tsinghua.edu.cn/git/AOSP/platform/manifest -b android-latest-release
# 同步代码
repo sync
```

开始编译

```
. build/envsetup.sh
lunch aosp_cf_arm64_only_phone-aosp_current-userdebug
m
```
