# Arch_install

### 基本介绍

arch Linux 安装脚本！网上流传的Arch安装脚本众多，但是别人写的，始终会存在很多小问题，就拿我之前使用的一条脚本来说，脚本中很多地方直接使用bash，然后众所周知，arch安装环境总使用的shell解释器是zsh。好不尴尬。因此，我写了我自己的安装脚本。

## 使用脚本安装arch Linux

### 安装前的准备

#### 联网

进入到安装界面之后，输入iwctl(回车)进入联网环境

![](https://klelee-image.oss-cn-qingdao.aliyuncs.com/image/image-20220213072420324.png)

```
$ iwctl   //会进入联网模式
[iwd]# help    //可以查看帮助
[iwd]# device list    //列出你的无线设备名称，一般以wlan0命名
[iwd]# station <device> scan    //扫描当前环境下的网络
[iwd]# station <device> get-networks    //会显示你扫描到的所有网络
[iwd]# station <device> connect <network name>
password:输入密码
[iwd]# exit    //退出当前模式，回到安装模式
```

网络测试

```
ping baidu.com
```

#### 临时修改源

```
echo "Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
```

为了下载git然后从远程拉取安装脚本，所以临时修改安装源！

#### 安装git

```
pacman -Sy git
```

#### 从gitee拉取安装脚本

```
git clone https://gitee.com/klelee/arch_install.sh
```

### 开始安装

```
mv ./arch_install/archInstall_klelee.sh ./ && chmod 777 archInstall_klelee.sh && ./archInstall_klelee.sh
```

#### Are you ready?

输入`y`继续

#### Do you want to do partioning? [y/N]

输入`y`确认。询问你是不是要进行分区，一般来说我们都是需要进行分区的！这里使用的分区工具是cfdisk，需要手动输入分区大小。

需要分出来两个区，分别是efi分区和根分区

| 分区    | 大小     |
| ------- | -------- |
| EFI分区 | 300M     |
| 根分区  | 剩余空间 |

```
cfdisk /dev/sda
```

分区表类型选择gpt

![image-20220213075824970](https://klelee-image.oss-cn-qingdao.aliyuncs.com/image/image-20220213075824970.png)

这就是cfdisk的分区界面，new就是新建分区

![image-20220213075842493](https://klelee-image.oss-cn-qingdao.aliyuncs.com/image/image-20220213075842493.png)

选择new之后会提示输入新建分区大小，首先建立efi分区300M，回车确认

![image-20220213080017196](https://klelee-image.oss-cn-qingdao.aliyuncs.com/image/image-20220213080017196.png)

选择分区类型

![image-20220213080042158](https://klelee-image.oss-cn-qingdao.aliyuncs.com/image/image-20220213080042158.png)

EFI分区当然选择，EFI System

![image-20220213080113786](https://klelee-image.oss-cn-qingdao.aliyuncs.com/image/image-20220213080113786.png)

然后新建根分区。（以前的旧图，请忽略swap分区）

![image-20220213080213271](https://klelee-image.oss-cn-qingdao.aliyuncs.com/image/image-20220213080213271.png)

新建好之后，选择Write写入，输入yes确认写入

![image-20220213080240703](https://klelee-image.oss-cn-qingdao.aliyuncs.com/image/image-20220213080240703.png)

然后回来之后选择Quit退出分区工具。

#### Do you want to format you disk?

输入`y`继续。询问是否需要格式化分区，只是客气一下，这里必须同意！

#### Which is your root partition(example /dev/sda2)?

询问那块分区是你的根分区，在询问之前会打印出你的分区情况

![image-20220213080418890](https://klelee-image.oss-cn-qingdao.aliyuncs.com/image/image-20220213080418890.png)

根据大小判断，上面图中因为有swap的缘故，根分区是第三块分区，因此输入`/dev/sda3`继续

#### Which is your EFI partition(example /dev/sda1)?

同上EFI分区`/dev/sda1`继续

#### Enter the username:

输入你的用户名：比如我`klelee`

#### Enter the hostname:

输入你的主机名：比如我：`arch`

为root用户和普通用户设置密码

为普通用户设置sudo权限：需要使用vim取消注释下面这行：

```
# %wheel ALL=(ALL) ALL
```



#### Choose a Desktop Environment to install

选择一个你想安装的桌面环境，比如安装KDE：输入`3`继续

后续配置会自动进行！



后续配置请参阅： [ArchLinux安装后的配置](./ArchLinux安装后的配置) 





----------------------------------

### 与我联系

如有疑问，欢迎加入QQ群提问：219261838

我的邮箱：klelee@outlook.com

我的主页：klelee.com
