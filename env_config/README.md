# 工作环境配置

## 扩容

 sudo lvextend -l +100%FREE /dev/mapper/fedora-root

 sudo xfs_growfs /

 df -h /

## 软件安装


zsh:
sudo dnf install zsh -y
chsh -s /bin/zsh 
或者为所有用户：
sudo sed -i 's/^SHELL=.*/SHELL=\/bin\/zsh/' /etc/default/useradd

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


ghostty + nvim + zsh 

sudo dnf install -y neovim zsh 

ssh

dnf copr enable scottames/ghostty
dnf install ghostty

starship:
curl -sS https://starship.rs/install.sh | sh 


## ssh

sudo dnf install openssh-server -y
sudo systemctl enable --now sshd
sudo systemctl status sshd
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload

## Niri + DMS (DankMaterialShell)

sudo dnf copr enable avengemedia/dms
sudo dnf install niri dms
systemctl --user add-wants niri.service dms

## nvim

lua/config/options.lua
```
-- 让拼写检查忽略驼峰命名（CamelCase）
vim.opt.spelloptions:append("camel")
-- cjk 代表中日韩字符，设置后 Neovim 会忽略这些区域的字符检查。
vim.opt.spelllang = { "en", "cjk" }
```

## ssh 兼容服务器版本过老，git 拉不下来

解决方案（推荐，影响最小）：把 crypto policy 切到 LEGACY 或 DEFAULT:SHA1，恢复对 SHA-1 / ssh-rsa 的支持。

1. 看当前 policy

update-crypto-policies --show

2. 允许 SHA-1（足以让 ssh-rsa 工作，不用降到 LEGACY）
  sudo update-crypto-policies --set DEFAULT:SHA1

3. 让本 shell 立刻生效（或者 logout 再登）
  source /etc/profile.d/*crypto*.sh 2>/dev/null


## 快捷键

### AS

下载 MacOs 快捷键插件。

 1. 按 Ctrl+Shift+A（IntelliJ Find Action），输入 Registry，回车
    - 或者菜单：Help → Find Action → Registry...
  2. 在 Registry 列表里搜索 keymap.windows.as.meta
  3. 勾上这个选项
  4. 重启 Android Studio（registry 改动通常需要重启才完全生效）

### Ghostty

