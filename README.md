# NixOS Linux(19.03) 配置安装教程

> [官方手册](https://nixos.org/nixos/manual/)

> [Linux中国 知乎文章 NixOS Linux： 先配置后安装的 Linux](https://zhuanlan.zhihu.com/p/30286477)

> [官方下载页面](https://nixos.org/nixos/download.html)

> [softpedia下载地址](https://linux.softpedia.com/get/System/Operating-Systems/Linux-Distributions/NixOS-27710.shtml)

> 推荐先安装`Internet Download Manager (IDM)`多线程下载,下载更快一些

## 启动镜像进入图形化界面
> 烧写图形版nixos-graphical镜像到U盘
> 在linux里面
```shell
sudo dd if=nix.iso of=/dev/sdc
```
* 默认的启动项进不去就可以试一试第二个选项(nomodeset)
* 启动进入命令行,默认是root用户
* 用户名`root`密码为空
* `Alt+F8`或者输入`nixos-help`显示自带手册文档,`Ctrl-z`退出
* `systemctl start display-manager`等待进入KED(虚拟机的话很慢),`loadkeys`切换键盘布局,neo2布局直接输入`loadkeys de neo`

## 网络
* 网络必须要配置通,默认打开kde桌面环境是已经自动连接网络了的,安装过程需要下载文件,查看状态`ip a`,手动配置网络`ifconfig`来配置,这里不做多介绍
* 要在图形安装程序上手动配置网络，请首先使用`systemctl stop network manager`禁用网络管理器
* 如需使用ssh,开启ssh守护进程`systemctl start sshd`
* 没有图形化界面连接wifi,查看网卡名`ip a`,连接`wpa_supplicant -B -i 网卡名 -c <(wpa_passphrase 'wifi名' 'wifi密码')`

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
* 挂载分区`mount /dev/disk/by-label/nixos /mnt`或者`mount /dev/sda1 /mnt`
* 挂载EFI引导分区`mkdir -p /mnt/boot`,`mount /dev/disk/by-label/boot /mnt/boot`或者`mount /dev/sda2 /mnt/boot`
* 开启swap`swapon /dev/sda3`
* 现在需要一个配置文件,来配置系统安装默认安装的数据以及安装配置`/mnt/etc/nixos/configuration.nix`
* 创建配置`nixos-generate-config --root /mnt`
* 编辑`nano /mnt/etc/nixos/configuration.nix`

* 开始安装`nixos-install`
* 等待,完成之后`reboot`


## 配置说明 configuration.nix
> 位置:安装之前`/mnt/etc/nixos/configuration.nix`,安装之后`/etc/nixos/configuration.nix`
> [官方配置详解](https://nixos.org/nixos/manual/options.html)
> 查看当前启动系统引导类型
```shell
# 存在就是UEFI,不存在就是BIOS
ls /sys/firmware/efi
```
> 配置之后请`nixos-rebuild switch`默认设为默认选项,`nixos-rebuild test`不设为默认选项,重载配置,每一次配置之后就会生成一个grub引导,方便回滚
> 基础配置
```config
{ config, pkgs, ... }: {
  imports = [
    # 使用默认的硬件配置
    ./hardware-configuration.nix
  ];

  boot.loader.grub.device = "/dev/sda";   # (for BIOS systems only,硬盘位置)
  boot.loader.systemd-boot.enable = true; # (for UEFI systems only)
  boot.loader.grub.efiSupport = true;     # grub是否支持efi

  # Enable the OpenSSH server.
  services.sshd.enable = true;
}
```
> 常用配置
```
# 有其他系统如win10,自动添加到grub
boot.loader.grub.useOSProber = true;

# 配置wifi
networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
## 生成wifi密钥配置，psk2的才支持自动生成
wpa_passphrase wanlaimeng wanlaimeng168 > /etc/wpa_supplicant.conf
## restart服务
systemctl restart wpa_supplicant.service

# 有线网络管理,不同时使用networking.wireless
networking.networkmanager.enable = true;

# 配置代理服务器
# curl -o csnet https://csnet.aite.xyz/files/csnet_client/csnet_client_linux_amd64
# chmod 777 ./csnet
# networking.proxy.default = "http://127.0.0.1:54321/";
networking.proxy.default = "http://user:password@proxy:port/";
networking.proxy.noProxy = "127.0.0.1,localhost";

# 普通用户配置
# 用户名:jcleng
# 密码:123456
# 用户使用nix配置,useradd等操作会在重启时失效
users.mutableUsers = true;
users.users.jcleng = {
  isNormalUser = true;
  home = "/home/jcleng";
  description = "jcleng"; # 用户全名
  extraGroups = [ "wheel" "networkmanager" ]; # root组和网络组
  # openssh.authorizedKeys.keys = [ "ssh-dss AAAAB3Nza... alice@foobar" ];
};
# 在命令行设置密码
# passwd jcleng
# 或者，配置密码
users.users.jcleng.password = "123456";

# 主机名称
networking.hostName = "jcleng";

# 支持图形化请开启xserver服务
services.xserver.enable = true;
services.xserver.layout = "us";

# 开启xserver服务之后才能使桌面环境,镜像里面带有plasma5,那就开启第一个plasma5,其他的自行安装
services.xserver.desktopManager.plasma5.enable = true;
services.xserver.desktopManager.xfce.enable = true;
services.xserver.desktopManager.gnome3.enable = true;
services.xserver.desktopManager.mate.enable = true;
services.xserver.windowManager.xmonad.enable = true;
services.xserver.windowManager.twm.enable = true;
services.xserver.windowManager.icewm.enable = true;
services.xserver.windowManager.i3.enable = true;

# 登录管理器,推荐使用第一个
services.xserver.displayManager.sddm.enable = true;
services.xserver.displayManager.slim.enable = true;

# NVIDIA 显卡驱动
services.xserver.videoDrivers = [ "nvidia" ];

# 触摸板
services.xserver.libinput.enable = true;

# 地区配置
i18n.supportedLocales = [ "zh_CN.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
i18n.defaultLocale = "zh_CN.UTF-8";
i18n.consoleKeyMap = "us";

# Fcitx输入法
i18n.inputMethod = {
  enabled = "fcitx";
};

# fcitx拼音包
i18n.inputMethod.fcitx.engines = with pkgs.fcitx-engines; [ cloudpinyin libpinyin rime ];

# 时区配置
time.timeZone = "Asia/Shanghai";

# 字体配置
fonts = {
  fontconfig.enable = true;
  enableFontDir = true;
  enableGhostscriptFonts = true;
  fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    wqy_microhei
    wqy_zenhei
  ];
};

# 安装软件,默认安装时没有浏览器/网络管理器等的
environment.systemPackages = with pkgs; [
  wget
  vim
  firefox
  git
  fcitx
  fcitx-configtool
];

# 修改配置之后必须
nixos-rebuild switch
```
## 安装软件
> su命令行使用
```
# 安装vscode
# 先开启allowUnfree
nixpkgs.config = {
  # 开启Unfree
  allowUnfree = true;
  allowBroken = true;
};
# 重新加载配置(重启)
nixos-rebuild switch
# 安装
nix-env -i vscode

# 安装软件(proxychains4是一个命令行使用代理的软甲,需要先安装)
nix-env -i nodejs
# proxychains4 nix-env -i nodejs

# 清除packages命令
nix-collect-garbage

# 查看已安装的包
nix-env -qaP '*' --description

# 整个系统回滚
nixos-rebuild switch --rollback

```
## 升级
```
# 查看升级通道
nix-channel --list
# 添加
nix-channel --add https://nixos.org/channels/nixos-19.03 nixos
# 升级到最新
nixos-rebuild switch --upgrade
```

