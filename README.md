# NixOS Linux(19.03) 配置安装教程
> [官方手册](https://nixos.org/nixos/manual/)
> [Linux中国 知乎文章 NixOS Linux： 先配置后安装的 Linux](https://zhuanlan.zhihu.com/p/30286477)
> [官方下载页面](https://nixos.org/nixos/download.html)
> [softpedia下载地址](https://linux.softpedia.com/get/System/Operating-Systems/Linux-Distributions/NixOS-27710.shtml)
> 推荐先安装`Internet Download Manager (IDM)`多线程下载,下载更快一些
## 启动镜像进入图形化界面
> 烧写图形版nixos-graphical镜像到U盘
* 默认的启动项进不去就可以试一试第二个选项(nomodeset)
* 启动进入命令行,默认是root用户
* 用户名`root`密码为空
* `Alt+F8`或者输入`nixos-help`显示自带手册文档,`Ctrl-z`退出
* `systemctl start display-manager`等待进入KED(虚拟机的话很慢),`loadkeys`切换键盘布局,neo2布局直接输入`loadkeys de neo`

## 网络
* 网络必须要配置通,默认打开kde桌面环境是已经自动连接网络了的,安装过程需要下载文件,查看状态`ip a`,手动配置网络`ifconfig`来配置,这里不做多介绍
* 要在图形安装程序上手动配置网络，请首先使用`systemctl stop network manager`禁用网络管理器
* 如需使用ssh,开启ssh守护进程`systemctl start sshd`
* 没有图形化界面连接wifi`wpa_supplicant -B -i interface -c <(wpa_passphrase 'SSID' 'key')`

## 分区安装盘
* 查看挂载的磁盘`lsblk`
* 转换硬盘gpt格式`parted /dev/sda -- mklabel gpt`
* 查看是否是gpt,`fdisk -l`
* 注意: parted请谨慎操作,会格式化C盘
* 只要两个分区EFI和/主分区即可安装
* 创建efi分区,前面预留512M EFI分区,后面留8GB(用作swap分区,也可以直接-1MiB不要swap分区,视情况而定),创建sda1系统主分区
`parted /dev/sda -- mkpart primary 512MiB -8GiB`
* 查看分区情况`lsblk -a`,多出sda1,sda1 = 全部大小 - 512M - 8G(1MiB)
* 修正格式EFI分区`parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB`
* 查看分区情况`lsblk -a`,多出sda2
* 设置EFI分区为boot分区,`parted -l`查看EFI编号(Number)
* parted /dev/sda -- set 编号 boot on
* 删除分区,进入`parted`命令,里面打印`print`,获取到编号,使用`rm 编号`,删除分区,`Ctrl-c`退出parted

## 格式化安装盘
* 主分区是ext4格式`mkfs.ext4 -L nixos /dev/sda1`
* EFI是fat格式`mkfs.fat -F 32 -n boot /dev/sda2`
* swap是swap格式(没有就略过)`mkswap -L swap /dev/sda3`
* 进入`parted`命令,里面打印`print`,查看File system

## 安装系统
* 挂载分区`mount /dev/disk/by-label/nixos /mnt`或者`mount /dev/sda1`
* 挂载EFI引导分区`mkdir -p /mnt/boot`,`mount /dev/disk/by-label/boot /mnt/boot`或者`mount /dev/sda2`
* 开启swap`swapon /dev/sda3`
* 现在需要一个配置文件,来配置系统安装默认安装的数据以及安装配置`/mnt/etc/nixos/configuration.nix`
* 创建配置`nixos-generate-config --root /mnt`
* 编辑`nano /mnt/etc/nixos/configuration.nix`
```
# 配置EFI启动,修改/添加
boot.loader.systemd-boot.enable = true;
# EFI安装grub的硬盘配置为nodev
boot.loader.grub.devices = "nodev";
# 有其他系统如win10,自动添加到grub
boot.loader.grub.useOSProber = true;
# 到最后记得取消注释无线网卡配置,xserver,KDE桌面
```
* 开始安装`nixos-install`
* 等待,完成之后`reboot`

## 安装软件
* 修改配置文件,然后`nixos-rebuild switch`

## 创建用户
* 创建用户`useradd -m jcleng`
* 为该用户设置密码`passwd jcleng`
