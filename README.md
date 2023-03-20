# NixOS 22.11 (Raccoon) 配置安装教程

```
┌💁  jcleng @ 💻  nixos in 📁  caddy-pl on 🌿  main •1 ✗
└❯ neofetch
          ▗▄▄▄       ▗▄▄▄▄    ▄▄▄▖            jcleng@nixos
          ▜███▙       ▜███▙  ▟███▛            ------------
           ▜███▙       ▜███▙▟███▛             OS: NixOS 22.11.2804.b26d52c9feb (Raccoon) x86_64
            ▜███▙       ▜██████▛              Host: LENOVO 20FRS0UM00
     ▟█████████████████▙ ▜████▛     ▟▙        Kernel: 5.15.95
    ▟███████████████████▙ ▜███▙    ▟██▙       Uptime: 12 hours, 17 mins
           ▄▄▄▄▖           ▜███▙  ▟███▛       Packages: 1951 (nix-system), 564 (nix-user), 42 (flatpak)
          ▟███▛             ▜██▛ ▟███▛        Shell: bash 5.1.16
         ▟███▛               ▜▛ ▟███▛         Resolution: 2560x1440
▟███████████▛                  ▟██████████▙   Terminal: vscode
▜██████████▛                  ▟███████████▛   CPU: Intel i5-6300U (4) @ 3.000GHz
      ▟███▛ ▟▙               ▟███▛            GPU: Intel Skylake GT2 [HD Graphics 520]
     ▟███▛ ▟██▙             ▟███▛             Memory: 1852MiB / 7825MiB
    ▟███▛  ▜███▙           ▝▀▀▀▀
    ▜██▛    ▜███▙ ▜██████████████████▛
     ▜▛     ▟████▙ ▜████████████████▛
           ▟██████▙       ▜███▙
          ▟███▛▜███▙       ▜███▙
         ▟███▛  ▜███▙       ▜███▙
         ▝▀▀▀    ▀▀▀▀▘       ▀▀▀▘




```

## 启动镜像进入图形化界面
> 烧写图形版nixos-graphical镜像到U盘
> 在linux里面
```shell
sudo dd if=nix.iso of=/dev/sdc bs=4M conv=fsync
```
* 默认的启动项进不去就可以试一试第二个选项(nomodeset)
* 启动进入命令行,默认是root用户
* 用户名`root`密码为空
* `Alt+F8`或者输入`nixos-help`显示自带手册文档,`Ctrl-z`退出

## 网络
* 网络必须要配置通,默认打开kde桌面环境是已经自动连接网络了的,安装过程需要下载文件,查看状态`ip a`,手动配置网络`ifconfig`来配置,这里不做多介绍
* 要在图形安装程序上手动配置网络，请首先使用`systemctl stop network manager`禁用网络管理器
* 如需使用ssh,开启ssh守护进程`systemctl start sshd`
* 没有图形化界面连接wifi,查看网卡名`ip a`,连接`wpa_supplicant -B -i 网卡名 -c <(wpa_passphrase 'wifi名' 'wifi密码')`

## 分区安装盘,换了个1tb的固态,全部使用ext4(由lvm和btrfs切换回来)

```shell
# 查看挂载的磁盘
lsblk

# parted请谨慎操作,会格式化磁盘
# 转换硬盘gpt格式
parted /dev/nvme0n1 -- mklabel gpt
# 查看是否是gpt,查看Disklabel type类型
fdisk -l

# 只要两个分区EFI和/主分区即可安装,其实就是运行parted /dev/nvme0n1命令,然后按照提示进行一步一步操作即可; 分区名称,分区类型,起点,终点

parted /dev/nvme0n1 -- mkpart uefi_esp fat32 1MiB 512MiB
parted /dev/nvme0n1 -- mkpart primary_ext ext4 512MiB -1MiB

# 查看分区情况
lsblk -a
# 设置启动分区, 先查看EFI编号(Number),再执行,应该就是1
parted -l
parted /dev/nvme0n1 -- set 编号 boot on
# 查看分区信息,能看到efi分区的Flags是[boot, esp]
parted -l


# 开始格式化分区
# efi分区格式化为fat32
mkfs.fat -F 32 /dev/nvme0n1p1
# 主分区全部格式化为ext4
mkfs.ext4 -L nixos /dev/nvme0n1p2

# 查看结果,File列里面
parted -l

# uefi类型挂载
mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot


# 转移原来的sda1分区所有/下文件
mkdir -p /old/mnt
mount /dev/sda1 /old/mnt
cp -aR /old/mnt /
# 注意重新修改挂载点
vi /mnt/etc/nixos/hardware-configuration.nix
```

## 虚拟机安装,通常不是uefi启动

```shell
# 查看挂载的磁盘
lsblk

# parted请谨慎操作,会格式化磁盘
# 转换硬盘msdos格式
parted /dev/sdb
mklabel msdos
q
# 查看是否是gpt,查看Disklabel type类型
fdisk -l

# 只要一个主分区
parted /dev/sdb
mkpart primary
ext4
1MiB
-1MiB
q

# 查看分区情况
lsblk -a

# 开始格式化分区
mkfs.ext4 -L nixos /dev/sdb1

# 查看结果,File列里面
parted -l

# 挂载
mount /dev/sdb1 /mnt

# 查看
lsblk

# 配置文件修改引导盘: /mnt/etc/nixos/configuration.nix
boot.loader.grub.device = "/dev/sdb"; # or "nodev" for efi only
```


* 配置文件生成

```shell
nixos-generate-config --root /mnt/
```

* 常规修改配置

```shell
nano /mnt/etc/nixos/configuration.nix
```
* 安装

```shell
nixos-install --root /mnt
```

* chroot进系统改普通用户密码

```shell
nix-enter --root /mnt
```



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

# 配置wifi,networkmanager二选一, 推荐networkmanager
# networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
## 运行命令生成wifi密钥配置，psk2的才支持自动生成: wpa_passphrase wanlaimeng wanlaimeng168 > /etc/wpa_supplicant.conf
## 如果是在cli连接wifi,自动生成密码之后,  restart服务 systemctl restart wpa_supplicant.service

# 有线网络管理,不同时使用networking.wireless,这个右下角会显示
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

# 开启声音，这个右下角会显示
sound.enable = true;
hardware.pulseaudio.enable = true;

# 支持图形化请开启xserver服务
services.xserver.enable = true;
services.xserver.layout = "us";

# 开启xserver服务之后才能使桌面环境,镜像里面带有plasma5(安装的时候直接从local获取不下载,快一点),那就开启第一个plasma5,其他的自行安装
services.xserver.desktopManager.plasma5.enable = true;
# services.xserver.desktopManager.xfce.enable = true;
# services.xserver.desktopManager.gnome3.enable = true;
# services.xserver.desktopManager.mate.enable = true;
# services.xserver.windowManager.xmonad.enable = true;
# services.xserver.windowManager.twm.enable = true;
# services.xserver.windowManager.icewm.enable = true;
# services.xserver.windowManager.i3.enable = true;

# 登录管理器,推荐使用第一个
services.xserver.displayManager.sddm.enable = true;
# services.xserver.displayManager.slim.enable = true;

# NVIDIA 显卡驱动
services.xserver.videoDrivers = [ "nvidia" ];

# 触摸板
services.xserver.libinput.enable = true;

# 地区配置
i18n.supportedLocales = [ "zh_CN.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
i18n.defaultLocale = "zh_CN.UTF-8";
# 如果是 21.05版本+ 是 i18n.console = { KeyMap = "us" }
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


### 安装21.05版本出现 /nix/store/...: No such file or directory issues: https://github.com/NixOS/nixpkgs/issues/126141
# 这样处理: https://github.com/NixOS/nixpkgs/issues/126141#issuecomment-877883570
sudo nix-build '<nixpkgs/nixos>' -A config.system.build.toplevel -I nixos-config=/mnt/etc/nixos/configuration.nix
sudo nixos-install
```
## 安装软件
> [在线包查看](https://nixos.org/nixos/packages.html)

> su命令行使用
```
# 搜索(-u生成缓存，搜索更快)
nix search -u
nix search wget
nix-env -aqP | grep vscode
# 安装vscode
# 先开启allowUnfree
nixpkgs.config = {
  # 开启Unfree
  allowUnfree = true;
  # 支持损坏的包
  allowBroken = true;
};
# 开启之后还要对单独的用户进行配置
nano ~/.config/nixpkgs/config.nix
{
  allowUnfree = true;
  allowBroken = true;
}

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
# 很多时候下载会出现断开 --keep-going
nix-env -i nodejs linux php openjdk --keep-going
```
### 搭建环境等
```shell
# 命令路径在`which php`(/home/jcleng/.nix-profile/bin/php)
# /home/jcleng/.nix-profile/lib/openjdk
nix-env -i openjdk neofetch php google-chrome gedit tilix tmux
```
> 感受
```
# 确实带有nix-pkg包管理工具的发行版确实可以是一个好的发行版，但是对于想要编译安装的软件往往达不到理想的要求，太繁琐，门槛太高，何不在其他发行版安装nixpkg包管理工具呢
```

### 最近更新了清华源[清华 Nix 镜像使用帮助](https://mirrors.tuna.tsinghua.edu.cn/help/nix/)

```shell
# 我在ubuntu安装了nix包管理工具,国内源网络已经很快了
# 国内源帮助: https://mirrors.tuna.tsinghua.edu.cn/help/nix/
# ustc源 https://mirrors.ustc.edu.cn/nix-channels/store
nix-channel --add https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixpkgs-unstable nixpkgs
nix-channel --add https://mirrors.ustc.edu.cn/nix-channels/nixos-21.05/ nixos
# nix-channel --add https://mirrors.ustc.edu.cn/nix-channels/nixpkgs-21.05-darwin/ darwin

# 单独安装的 Nix ,可执行目录
~/.nix-profile/bin

# 配置
cat ~/.bash_profile
export PATH="$PATH:/home/leng/.nix-profile/bin"

# 缓存源地址修改
cat ~/.config/nix/nix.conf
substituters = https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store

cat ~/.config/nixpkgs/config.nix

{
  allowUnfree = true;
  allowBroken = true;
  allowUnsupportedSystem = true;
  allowInsecurePredicate = (pkg: true);
  allowUnfreePredicate = (pkg: false);
  #packageOverrides = pkgs: {
  #  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
  #    inherit pkgs;
  #  };
  #};
}

# 更新一下
nix-channel --update

# 如果提示  SSL peer certificate or SSH remote key was not OK (60)
# 配置NIX_SSL_CERT_FILE环境变量值为/etc/ssl/certs/ca-bundle.crt 参考: https://github.com/NixOS/nixpkgs/issues/70939
echo $NIX_SSL_CERT_FILE
/etc/ssl/certs/ca-bundle.crt

# 确保在 nix show-config 命令结果中的substituters中,只有tsinghua源

...省略
substitute = true
substituters = https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store
...省略

# 测试安装(可明确看到 from 'https://mirrors.tuna.tsinghua.edu.cn/' 即换源成功)
nix-env -i hello

# 安装完成即可执行
hello
# Hello, world!

# 搜索软件
nix-env -qa 'hello'
nix-env -qa 'neofetch'
# 安装
nix-env -i neofetch
```

- 更加详细的搜索&&安装

```shell
# 更加详细的搜索数据,(之前的搜索不能搜索到php73)参考博客 https://www.domenkozar.com/2014/01/02/getting-started-with-nix-package-manager/
nix-env -qaP | grep php

# 结果

...

nixpkgs.php73                                                            php-with-extensions-7.3.25
nixpkgs.php                                                              php-with-extensions-7.4.13
nixpkgs.php80                                                            php-with-extensions-8.0.0
nixpkgs.php73Extensions.xdebug                                           php-xdebug-3.0.1
nixpkgs.php74Extensions.xdebug                                           php-xdebug-3.0.1
nixpkgs.php80Extensions.xdebug

...

# 安装php8(使用第二列的id名称)
nix-env -i php-with-extensions-8.0.0

# 其他
# 配置NIX_PATH变量环境 配置之后才能nix search命令
export NIX_PATH=/home/leng/.nix-defexpr/channels
echo $NIX_PATH

# 安装search的包
# * nixpkgs.xorg.xf86inputlibinput (xf86-input-libinput)

nix-env -iA nixpkgs.xorg.xf86inputlibinput
```

#### 在macos上配置安装nix包管理工具

```shell
# 下载
aria2c https://mirrors.tuna.tsinghua.edu.cn/nix/nix-2.3.9/nix-2.3.9-x86_64-darwin.tar.xz
# 安装
./install --darwin-use-unencrypted-nix-store-volume
# 输入用户密码
# 安装完成提示
modifying /Users/jcleng/.bash_profile...
modifying /Users/jcleng/.zshrc...
Installation finished!  To ensure that the necessary environment
variables are set, either log in again, or type

  . /Users/jcleng/.nix-profile/etc/profile.d/nix.sh

in your shell.
# 重新登录或者执行
sh /Users/jcleng/.nix-profile/etc/profile.d/nix.sh


# 执行仍nix命令无效,请往下看,我这边是fish,这里nix默认只写入了.bash_profile和.zshrc,那么手动写入进fish,查看 nix.sh 里面的变量环境
cat /Users/jcleng/.nix-profile/etc/profile.d/nix.sh

# 有那些
# NIX_LINK=$HOME/.nix-profile 基本路径
export NIX_PATH=${NIX_PATH:+$NIX_PATH:}$HOME/.nix-defexpr/channels
export NIX_PROFILES="/nix/var/nix/profiles/default $HOME/.nix-profile"
export NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
export NIX_SSL_CERT_FILE=/etc/ssl/ca-bundle.pem
export NIX_SSL_CERT_FILE="$NIX_LINK/etc/ca-bundle.crt"
export MANPATH="$NIX_LINK/share/man:$MANPATH"
export PATH="$NIX_LINK/bin:$PATH"

# 编辑fish配置文件
vim /Users/jcleng/.config/fish/conf.d/omf.fish


# 对应新增
set -x NIX_PATH /Users/jcleng/.nix-defexpr/channels
set -x NIX_PROFILES /nix/var/nix/profiles/default /Users/jcleng/.nix-profile
# 如果本机没有的话,就使用自带的
set -x NIX_SSL_CERT_FILE /Users/jcleng/.nix-profile/etc/ssl/certs/ca-bundle.crt
set -x MANPATH /Users/jcleng/.nix-profile/share/man $MANPATH
# 最重要的可执行命令路径
set -x PATH /Users/jcleng/.nix-profile/bin $PATH
# 我之前已经有 PATH 了,那么直接追加一个
set -x PATH /Users/jcleng/.nix-profile/bin /Users/jcleng/Downloads/flutter/bin /usr/local/axe/bin $PATH

# 配置保存,然后fish重新打开, 再执行nix命令即可
nix


# 创建一个php71环境
nix-env -p /nix/var/nix/profiles/per-user/leng/dev-php71 -i nix git
# 切换当前环境
nix-env --switch-profile /nix/var/nix/profiles/per-user/leng/dev-php71
# 默认环境(重启shell生效)
nix-env --switch-profile /nix/var/nix/profiles/per-user/leng/profile

```
- 版本共存和回滚

```shell
# 多个版本共存
## 先设置之前的为 active false, 否则提示(i.e., can’t have two active at the same time), 切换的话需执行这里2条命令即可
nix-env --set-flag active false php-with-extensions-7.3.25
nix-env --set-flag active true php-with-extensions-8.0.0
# 切换,最好 false 在前
nix-env --set-flag active false php-with-extensions-8.0.0
nix-env --set-flag active true php-with-extensions-7.3.25

# nur切换
ls -l /home/jcleng/.nix-profile/bin/php
# lrwxrwxrwx 1 jcleng jcleng 62 Jan  1  1970 /home/jcleng/.nix-profile/bin/php -> /nix/store/499zg22sagzbbg27z5hlb466qpj88va6-php-7.1.33/bin/php*
nix-env --set-flag active false php-7.1.33
nix-env --set-flag active true php-7.1.33

## 然后再安装不同的版本
nix-env --preserve-installed -i php-with-extensions-8.0.0

# 查看记录
nix-env --list-generations
# 删除记录
nix-env --delete-generations 3 4 8
# 删除记录, 只保留5个
nix-env --delete-generations +5
# 删除30d前记录
nix-env --delete-generations 30d
# 删除所有 只保留current
nix-env --delete-generations old
# 回滚指定记录
nix-env {--switch-generation | -G} {generation}
# 回滚上一条记录
nix-env --rollback
```

- [镜像下载大文件频繁出错/断流](https://github.com/tuna/issues/issues/797#issuecomment-742458245)

```shell
# 可以换一个地址
# 切换镜像地址
nix-channel --add https://mirrors.bfsu.edu.cn/nix-channels/nixpkgs-unstable nixpkgs

# 编辑源
cat ~/.config/nix/nix.conf
# substituters = https://mirrors.bfsu.edu.cn/nix-channels/store

# 更新
nix-channel --update
```

- 配置nix包镜像代理

```shell
# 代理机器安装nix-serve,运行:
nix-serve -p 8080
```

```shell
# 客户端编辑配置文件binary-caches设置为代理服务器的地址
cat ~/.config/nix/nix.conf
# substituters注释掉,修改为binary-caches
# substituters = https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store
binary-caches = http://192.168.1.91:8080/
require-sigs = false

# 保存之后执行
# substituters配置已经是代理服务器的地址
nix show-config
nix-channel --update
```

- nur使用

```shell
# 格式化.nix文件插件`jnoortheen.nix-ide` `bbenoist.nix`(vscode)
# .nix文件换行符号用lf
nix-env -iA nixpkgs.nixpkgs-fmt

# 前提安装proxychains4来走proxy
nix-env -iA nixpkgs.proxychains
# 配置 /etc/proxychains4.conf
socks5  127.0.0.1 54321
# 测试
proxychains4 curl google.com
# 别名 vim ~/.config/fish/config.fish
alias nix-env='proxychains4 nix-env'
alias nix='proxychains4 nix'
alias nix-channel='proxychains4 nix-channel'


# 使用NUR
https://github.com/nix-community/NUR

cat ~/.config/nixpkgs/config.nix

{
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}

# 测试安装nur.repos.mic92.hello-nur
nix-env -f '<nixpkgs>' -iA nur.repos.mic92.hello-nur
# nur包列表
https://nur.nix-community.org/repos/izorkin/

# 搜索
http://nur.nix-community.org/repos/
## 配置~/.config/nixpkgs/config.nix文件之后使用 -f '<nixpkgs>' 搜索
nix search php71 -f '<nixpkgs>' -u

# php相关
http://nur.nix-community.org/repos/izorkin/
# 安装php71
nix-env -f '<nixpkgs>' -iA nur.repos.izorkin.php71
# 环境
nix-shell -p nur.repos.izorkin.php73

# 注意在wsl上可能会遇到安装无法使用busybox的情况,导致busybox的命令都无法使用 https://github.com/nix-community/NUR/issues/319


# nur或者直接添加仓库的channel
nix-channel --add https://github.com/nix-community/NUR/archive/master.tar.gz nur

# 有的aur包已经提供了cachix,使用cachix use添加缓存仓库
nix-env -iA nixpkgs.cachix
# https://github.com/Izorkin/nur-packages
cachix use izorkin
# https://github.com/fossar/nix-phps
cachix use fossar
# nix-community
cachix use nix-community
# 使用cachix use命令之后,会提示已经修改了~/.config/nix/nix.conf配置文件, https://cache.nixos.org 这个可以修改为国内源(删除)
cat ~/.config/nix/nix.conf

substituters = https://cache.nixos.org https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://izorkin.cachix.org https://nix-community.cachix.org
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= fossar.cachix.org-1:Zv6FuqIboeHPWQS7ysLCJ7UT7xExb4OE8c4LyGb5AsE= izorkin.cachix.org-1:hwG3g4ZCbuC1eOZjGtQ/ESxwBxigCHs205Kz1iuMiJA= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=

nix-env -f '<nixpkgs>' -iA nur.repos.mic92.hello-nur 会直接看到:

nix-env -f '<nixpkgs>' -iA nur.repos.mic92.hello-nur...
...

nix-env -f '<nixpkgs>' -iA nur.repos.izorkin.php71 会直接看到:

...
copying path '/nix/store/k7yvdrvf0vzl27gmfqvi2ya3r2qgbz20-php-7.1.33-debug' from 'https://izorkin.cachix.org'...
...

```

- 引导配置,原文

```nix
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # 传统模式(比如服务器上),efi设置nodev
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

```

### `cache.nixos.org`缓存非常慢,或者老是出错,自建http服务代理一下



```
# 参考文章

FAQ/Private Cache Proxy
https://nixos.wiki/wiki/FAQ/Private_Cache_Proxy


How to make a local NixOS cache server
https://dataswamp.org/~solene/2022-06-02-nixos-local-cache.html
```


- `cache.jcleng.net`替换为域名

```nix
  services.nginx = {
    enable = true;
    appendHttpConfig = ''
      proxy_cache_path /tmp/pkgcache levels=1:2 keys_zone=cachecache:100m max_size=20g inactive=365d use_temp_path=off;

      # Cache only success status codes; in particular we don't want to cache 404s.
      # See https://serverfault.com/a/690258/128321
      map $status $cache_header {
        200     "public";
        302     "public";
        default "no-cache";
      }
      access_log /tmp/nginx_access.log;
    '';

    virtualHosts."cache.jcleng.net" = {
      locations."/" = {
        root = "/var/public-nix-cache";
        extraConfig = ''
          expires max;
          add_header Cache-Control $cache_header always;
          # Ask the upstream server if a file isn't available locally
          error_page 404 = @fallback;
        '';
      };

      extraConfig = ''
        # Using a variable for the upstream endpoint to ensure that it is
        # resolved at runtime as opposed to once when the config file is loaded
        # and then cached forever (we don't want that):
        # see https://tenzer.dk/nginx-with-dynamic-upstreams/
        # This fixes errors like
        #   nginx: [emerg] host not found in upstream "upstream.example.com"
        # when the upstream host is not reachable for a short time when
        # nginx is started.
        resolver 114.114.114.114;
        set $upstream_endpoint http://cache.nixos.org;
      '';

      locations."@fallback" = {
        proxyPass = "$upstream_endpoint";
        extraConfig = ''
          proxy_cache cachecache;
          proxy_cache_valid  200 302  60d;
          expires max;
          add_header Cache-Control $cache_header always;
        '';
      };

      # We always want to copy cache.nixos.org's nix-cache-info file,
      # and ignore our own, because `nix-push` by default generates one
      # without `Priority` field, and thus that file by default has priority
      # 50 (compared to cache.nixos.org's `Priority: 40`), which will make
      # download clients prefer `cache.nixos.org` over our binary cache.
      locations."= /nix-cache-info" = {
        # Note: This is duplicated with the `@fallback` above,
        # would be nicer if we could redirect to the @fallback instead.
        proxyPass = "$upstream_endpoint";
        extraConfig = ''
          proxy_cache cachecache;
          proxy_cache_valid  200 302  60d;
          expires max;
          add_header Cache-Control $cache_header always;
        '';
      };
    };
  };

```

- caddy服务端代理

```caddyfile
cache.jcleng.net:80 {
   reverse_proxy /* https://cache.nixos.org {
      header_up Host cache.nixos.org
      header_up X-Real-IP {remote}
      header_up X-Forwarded-For {remote}
      header_up X-Forwarded-Port {server_port}
      header_up X-Forwarded-Proto "http"
   }
}
```

- 使用

```shell
sudo nixos-rebuild switch --option substituters http://cache.jcleng.net
```

```nix
nix.binaryCaches = [ "http://cache.jcleng.net" ];
```

code ~/.config/nix/nix.conf

```conf
require-sigs = false
experimental-features = nix-command flakes
substituters = http://cache.jcleng.net https://cache.nixos.org
binary-caches = http://cache.jcleng.net
```


