# linux文件传输主要有以下几种方法
1. ftp
2. samba服务
3. sftp
4. scp

他们的使用有些场景下可以相互替换，有时情况下则只能使用某种服务。
前三种需要配置，scp则直接可以使用
# scp(source copy)
scp进行远程文件拷贝，数据传输使用ssh,并且和ssh使用相同的认证方式，提供相同的安全保证。与rcp 不同的是，scp 在需要进行验证时会要求你输入密码或口令。
```bash
scp [源用户名@ip地址：][路径]源文件/文件夹　　[源用户名@ip：]新文件名/目录
```
其中本地用户的用户名和ip是可以有scp自己获取的，所以可以省略。例如：
```bash
scp root@172.19.2.75:/home/root/full.tar.gz home/daisy/full.tar.gz
scp /home/daisy/full.tar.gz root@172.19.2.75:/home/root
```
而如果远端的用户名被省略，则会提醒输入。

### 参数

可能有用的几个参数 :
-v 和大多数 linux 命令中的 -v 意思一样 , 用来显示进度 . 可以用来查看连接 , 认证 , 或是配置错误 .
-C 使能压缩选项 .
-P 选择端口 . 注意 -p 已经被 rcp 使用 .
-4 强行使用 IPV4 地址 .
-6 强行使用 IPV6 地址 .
-r 递归拷贝整个文件夹（包含子文件夹）
如——
copy 本地的档案到远程的机器上
scp /etc/lilo.conf
会将本地的 /etc/lilo.conf 这个档案 copy 到使用者my 的家目录下。

### 注意两点：
1.如果远程服务器防火墙有特殊限制，scp便要走特殊端口，具体用什么端口视情况而定，命令格式如下：
#scp -p 4588 remote@www.abc.com:/usr/local/sin.sh /home/administrator
2.使用scp要注意所使用的用户是否具有可读取远程服务器相应文件的权限。

### ssh-keygen

产生公开钥 (pulib key) 和私人钥 (private key)，以保障 ssh 联机的安性， 当 ssh 连 shd 服务器，会交换公开钥上，系统会检查 /etc/ssh_know_hosts 内储存的 key，如果找到客户端就用这个 key 产生一个随机产生的session key 传给服务器，两端都用这个 key 来继续完成 ssh 剩下来的阶段。
它会产生 identity.pub、identity 两个档案，私人钥存放于identity，公开钥 存放于 identity.pub 中，接下来使用 scp 将 identity.pub copy 到远程机器的家目录下.ssh下的authorized_keys。 .ssh/authorized_keys(这个 authorized_keys 档案相当于协议的 rhosts 档案)， 之后使用者能够不用密码去登入。RSA的认证绝对是比 rhosts 认证更来的安全可靠。
执行：
scp identity.pub .tw:.ssh/authorized_keys
若在使用 ssh-keygen 产生钥匙对时没有输入密码，则如上所示不需输入密码即可从 去登入 在此，这里输入的密码可以跟帐号的密码不同，也可以不输入密码。


可以看到，使用scp进行文件拷贝，是要知道源文件的路径的。如过想从远端拷贝文件到本地，对于不知道准确的路径名（可能会记错）或者知道路径却不知道文件名。这时候希望
先到远端电脑看一下文件。这就牵涉到登录远端远端。在Unix和类Unix之间访问，使用ｓｓｈ是最便捷的方式了。[可以查看file_transfor_ssh来查看详细使用方法]（https://github.com/YaowenGuo/LinuxNote/edit/master/file_transfor_ssh.md)

