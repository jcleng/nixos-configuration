# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.theme = pkgs.nixos-grub2-theme;
  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "zh_CN.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };
  # Fcitx输入法
  i18n.inputMethod = {
    enabled = "fcitx5";
    # enabled = "ibus";
  };

  # fcitx拼音包
  i18n.inputMethod.fcitx.engines = with pkgs.fcitx-engines; [ libpinyin rime ];
  i18n.inputMethod.fcitx5.addons = with pkgs; [ fcitx5-rime ];
  i18n.inputMethod.fcitx5.enableRimeData = true;
  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the Plasma 5 Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  #i3
  services.xserver.windowManager.i3.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  nix.settings.trusted-users = [ "root" "jcleng" ];
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jcleng = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      firefox
      #     thunderbird
    ];
  };
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "libdwarf-20181024"
  ];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    # wget
    # firefox
    nano
    zsh
    # fcitx5-configtool
    # fcitx5-with-addons
    # fcitx5-chinese-addons
    #
    aria2
    ark
    # etcher
    gerbera
    git
    gparted
    groff
    libreoffice
    lsd
    neofetch
    okular
    vscode
    chromium
    vlc
    mpv
    clash
    gimp
    htop
    wqy_microhei
    wqy_zenhei
    fira-code
    # latte-dock
    # source-han-sans-simplified-chinese
    appimage-run
    docker-compose
    # google-chrome
    # wine
    # xface dock
    # plank
    # 快捷打开
    # albert
    # xfce.xfwm4-themes
    # xfce.xfce4-icon-theme
    # elementary-xfce-icon-theme
    # micro
    android-tools
    # wezterm
    neovim

    # redis-desktop-manager
    # gammy
    # lite-xl
    obs-studio
    kdeconnect
    noto-fonts-emoji
    # vivaldi
    # vivaldi-ffmpeg-codecs
    # vivaldi-widevine
    ibus-theme-tools
    firefox-devedition-bin-unwrapped
    # dbeaver
    # jdk17
    # openjdk17
    jdk11
    php80
    jetbrains-mono
    # vagrant
    arandr
    ntfs3g
    tmux
    tree
    bpytop
    nodejs-16_x
    # winetricks
    # nwjs
    # x11docker
    # tini
    xorg.xhost
    unzip
    # partition-manager
    filelight
    # microsoft-edge
    cmatrix
    # geekbench
    pciutils
    lazydocker
    # termius
    flatpak-builder
    p7zip
    unrar-wrapper
    gpick
    # mars-mips
    virt-manager
    nixpkgs-fmt
    usbutils
    file
    inetutils
    #nvtop-amd
    #linuxPackages.amdgpu-pro
    minikube
    kubectl
    bridge-utils
    # hostapd
    bind
    wireshark
    scrcpy
    alacritty
    ttyd
    youtube-dl
    # vivaldi
    go
    # xcaddy
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
  # flatpak
  services.flatpak.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;
  # 修改为下面: virtualisation.docker.extraOptions = "-H tcp://0.0.0.0:39012";
  virtualisation.docker.daemon.settings = {
    hosts = [
      "0.0.0.0:39012"
    ];
    registry-mirrors = [
      "https://dockerproxy.com"
    ];
  };
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.onBoot = "start";
  # virtualisation.libvirtd.allowedBridges=[
  #   "virbr0"
  #   "br0"
  # ];
  # networking.bridges = {
  #   br0 = {
  #     interfaces = [
  #       "wlp4s0"
  #     ];
  #   };
  # };
  #services.jellyfin.enable = true;
  #services.jellyfin.user = "jcleng";

  virtualisation.podman.enable = true;

  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.guest.enable = true;
  # 支持usb的扩展包
  # virtualisation.virtualbox.host.enableExtensionPack = true;

  networking.hosts = {
    "116.204.106.129" = [ "www.xxx.icu" ];
  };
  programs.sway.enable = true;
  # virtualisation.anbox.enable = true;
  services.code-server.enable = true;
  services.code-server.host = "0.0.0.0";
  services.code-server.port = 8187;
  services.code-server.hashedPassword = "$argon2id$v=19$m=102400,t=2,p=8$tSm+xxxxxxxxx/g44K5fQ$WDyus6py50bVFIPkjA28lQ";
  services.code-server.user = "jcleng";
  services.code-server.group = "users";

  # Enable cron service
  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/1 * * * * jcleng date >> /tmp/cron.log"
      "*/60 * * * * jcleng /home/jcleng/下载/aliyunpan-v0.2.6-linux-amd64/aliyunpan token update -mode 2"
    ];
  };
}
