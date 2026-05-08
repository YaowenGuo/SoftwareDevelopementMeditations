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