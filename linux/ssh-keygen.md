如果你已经有了一套名为 id_rsa 的公秘钥，将要生成另外一个公钥，比如 aysee ，你也可以使用任何你喜欢的名字。

步骤如下：

1. 生成一个新的自定义名称的公钥：

```shell
ssh-keygen -t rsa -C "YOUR_EMAIL@YOUREMAIL.COM" -f ~/.ssh/aysee
```

执行命令后，生成命名的公钥和生成默认公钥的步骤一样。

执行完成后，会在 `~/.ssh/` 目录下生成一个 aysee 和 aysee.pub 文件。

2. 在 SSH 用户配置文件 ~/.ssh/config 中指定对应服务所使用的公秘钥名称，如果没有 config 文件的话就新建一个，并输入以下内容：

```shell
Host github.com www.github.com
IdentityFile ~/.ssh/aysee
```
3. 添加 aysee.pub 到你的git服务器网站上。

4. 测试配置文件是否正常工作

```
ssh -T git@gitcafe.com
```

如果，正常的话，会出现如下提示：

```
Hi USERNAME! You've successfully authenticated, but github does not provide shell access.
```
如果出现如下提示，则说明有权限问题：

```
Permission denied (publickey)
```
如果有权限问题的情况下，你对项目执行push操作的时候，会得到如下提示：

```
Warning: Permanently added the RSA host key for IP address '192.30.252.129' to the list of known hosts.
Permission denied (publickey).
fatal: Could not read from remote repository.
 
Please make sure you have the correct access rights
and the repository exists.
```
　　

多用户时出现权限问题的原因：
github使用SSH与客户端连接。如果是单用户（first），生成密钥对后，将公钥保存至 GitHub ，每次连接时SSH客户端发送本地私钥（默认~/.ssh/id_rsa）到服务端验证。单用户情况下，连接的服务器上保存的公钥和发送的私钥自然是配对的。但是如果是 多用户 （first，second），我们在连接到second的帐号时，second保存的是自己的公钥，但是SSH客户端依然发送默认私钥，即first的私钥，那么这个验证自然无法通过。

 
### 解决ssh权限问题

通常一台电脑生成一个ssh不会有这个问题，当一台电脑生成多个ssh的时候，就可能遇到这个问题，解决步骤如下：

1、查看系统ssh-key代理,执行如下命令

```shell
$ ssh-add -l
```
以上命令如果输出 `The agent has no identities.` 则表示没有代理。如果系统有代理，可以执行下面的命令清除代理:

```shell
$ ssh-add -D
```
2、然后依次将不同的ssh添加代理，执行命令如下：

```
$ ssh-add ~/.ssh/id_rsa
$ ssh-add ~/.ssh/aysee
```
你会分别得到如下提示：

```
2048 8e:71:ad:88:78:80:b2:d9:e1:2d:1d:e4:be:6b:db:8e /Users/aysee/.ssh/id_rsa (RSA)
```
和

```
2048 8e:71:ad:88:78:80:b2:d9:e1:2d:1d:e4:be:6b:db:8e /Users/aysee/.ssh/id_rsa (RSA)
2048 a7:f4:0d:f1:b1:76:0b:bf:ed:9f:53:8c:3f:4c:f4:d6 /Users/aysee/.ssh/aysee (RSA)
```
如果使用 ssh-add ~/.ssh/id_rsa的时候报如下错误，则需要先运行一下 ssh-agent bash 命令后再执行 ssh-add ...等命令

```
Could not open a connection to your authentication agent.
```
　　

3、配置 ~/.ssh/config 文件

如果没有就在~/.ssh目录创建config文件，该文件用于配置私钥对应的服务器

```

# Default github user(first@mail.com)
 
Host github.com
HostName github.com
User git
IdentityFile C:/Users/username/.ssh/id_rsa
 
# aysee (company_email@mail.com)
Host github-aysee
HostName github.com
User git
IdentityFile C:/Users/username/.ssh/aysee
```


Host随意即可，方便自己记忆，后续在添加remote是还需要用到。 配置完成后，在连接非默认帐号的github仓库时，远程库的地址要对应地做一些修改，比如现在添加second帐号下的一个仓库test，则需要这样添加：

```
git remote add test git@github-aysee:ay-seeing/test.git 
#并非原来的git@github.com:ay-seeing/test.git
```
ay-seeing 是github的用户名

 

4、测试 ssh

```
ssh -T git@github.com
```
你会得到如下提示，表示这个ssh公钥已经获得了权限

Hi USERNAME! You've successfully authenticated, but github does not provide shell access.