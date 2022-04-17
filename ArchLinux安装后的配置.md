# ArchLinux安装后的配置

脚本中只是进行了简单的安装，后续输入法、bash等等的配置都需要进行配置。

### 添加ArchLinuxCN 存储库

该仓库是由archlinux中文社区驱动的一个非官方的软件仓库。我们使用的很多软件都需要使用这个库去下载，比如typora。

```text
# 编辑/etc/pacman.conf
sudo vim /etc/pacman.conf
--------------------------------------
# 在最后添加
[archlinuxcn]
Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch   
# 这是中科大的源，你也可以选择清华、阿里等，当我推荐中科大，因为我喜欢
```

然后更新GPG密钥

```text
sudo pacman -S archlinuxcn-keyring
```

**注** ： 如果以上更新密钥步骤出现错误，就是那种连着一串ERROR的情况，请执行以下步骤

```text
sudo rm -rf /etc/pacman.c/gnupg
sudo pacman-key --init
sudo pacman-key --populate archlinux archlinuxcn
sudo pacman -Syy
```

### 中文输入法

```text
sudo pacman -S fcitx fcitx-im fcitx-configtool
yay -S fcitx-sogoupinyin
vim ~/.xprofile
-------------------------------
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
```

重启，这时候会看到系统托盘会有一个键盘的图标。

### 配置oh-my-bash

```
git clone https://github.com/ohmybash/oh-my-bash.git
cd oh-my-bash/tools
./install.sh
```

可以在[oh-my-bash](https://github.com/ohmybash/oh-my-bash/wiki/Themes) 官网查找喜欢的主题，然后在`~/.bashrc`下进行主题的更改

![image-20220417165101670](https://klelee-image.oss-cn-qingdao.aliyuncs.com/image/image-20220417165101670.png)

持续更新~



----------------------------------

### 与我联系

如有疑问，欢迎加入QQ群提问：219261838

我的邮箱：klelee@outlook.com

我的主页：klelee.com

