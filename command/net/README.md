> 查看 /etc/hosts 文件

127.0.0.1	localhost
::1	localhost ip6-localhost ip6-loopback
fe00::0	ip6-localnet
ff00::0	ip6-mcastprefix
ff02::1	ip6-allnodes
ff02::2	ip6-allrouters
172.17.0.2	fe9dac62ee46  # docker 已为该容器添加了一条主机配置项。

### 使用容器


再看看容器的网络配置情况。

> 查看网络配置 # ip a
如果没有，看下一条，安装

```
# lo 的换回接口
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: tunl0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN group default qlen 1
    link/ipip 0.0.0.0 brd 0.0.0.0
3: ip6tnl0@NONE: <NOARP> mtu 1452 qdisc noop state DOWN group default qlen 1
    link/tunnel6 :: brd ::
# 标准 eth0 网络接口。
100: eth0@if101: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```

> 安装一些常用的命令

apt-get update
//ifconfig
//apt install net-tools  ifconfig 已经好多年没有维护了，你需要使用ip命令。
// ip 套件
apt install iproute2
//ping
apt install iputils-ping
//

> 查看进程
ps -aux

### 退出容器 exit

一旦退出了shell， 容器也就随之停止了。
