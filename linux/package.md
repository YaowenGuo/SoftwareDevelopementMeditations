# Debian

[在 ARM 架构的机器上下载 AMD64 架构的包](https://copyprogramming.com/howto/how-to-install-i386-amd64-packages-on-arm-or-any-other-arch-from-ubuntu-ports)

```
dpkg --add-architecture amd64
apt update
apt download surfshark:amd64
```
