
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
   boot.loader.systemd-boot.enable = true;
   boot.loader.efi.canTouchEfiVariables = true;

   networking.hostName = "jcleng"; # Define your hostname.
   # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
   networking.proxy.default = "http://127.0.0.1:54321/";
   networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

# 网络管理
networking.networkmanager.enable = true;

  
  # $ nix search wget
   environment.systemPackages = with pkgs; [
     wget vim vscode dillo firefox fcitx fcitx-configtool git zsh tmux mkpasswd vimer
   ];

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
# 密码，先安装mkpasswd，然后mkpasswd -m sha-512 123456
users.users.jcleng.password = "jcleng@ai";

  
   services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
   services.xserver.enable = true;
   services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
   services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
   services.xserver.displayManager.sddm.enable = true;
   services.xserver.desktopManager.plasma5.enable = true;

   services.xserver.desktopManager.xfce.enable = true;
   
   i18n.inputMethod = {
    enabled = "fcitx";
   };
  # fcitx拼音包
   i18n.inputMethod.fcitx.engines = with pkgs.fcitx-engines; [ cloudpinyin libpinyin rime ];
  # 时区
   time.timeZone = "Asia/Shanghai";
  # 地区
  i18n.supportedLocales = [ "zh_CN.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.consoleKeyMap = "us";

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
  system.stateVersion = "19.03"; # Did you read the comment?
nixpkgs.config = {
  # 开启Unfree
  allowUnfree = true;
  # 支持损坏的包
  allowBroken = true;
};
}
