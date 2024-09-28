FROM debian:latest

LABEL Description="This image is used to build linux kernel." Vendor="GuoYaowen" Version="0.2"

# 避免 tzdata 以交互方式提醒用户选择使用位置卡死构建。
# 以非交互安装。
ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update && apt-get install -y \
make \
flex \
bison \
lld \
bc \
libssl-dev \
iputils-ping \
curl \
wget \
git \
vim \
clang \
lldb \
libelf-dev \
dwarves \
sudo \
debootstrap \
&& mkdir -p /Users/lim/projects \
