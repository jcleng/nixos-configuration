#           ▗▄▄▄       ▗▄▄▄▄    ▄▄▄▖            jcleng@nixos
#           ▜███▙       ▜███▙  ▟███▛            ------------
#            ▜███▙       ▜███▙▟███▛             OS: NixOS 21.05 (Okapi) x86_6
#             ▜███▙       ▜██████▛              Host: 20FRS0UM00 ThinkPad X1
#      ▟█████████████████▙ ▜████▛     ▟▙        Kernel: 5.10.48
#     ▟███████████████████▙ ▜███▙    ▟██▙       Uptime: 3 days, 1 hour, 49 mi
#            ▄▄▄▄▖           ▜███▙  ▟███▛       Packages: 887 (nix-system), 1
#           ▟███▛             ▜██▛ ▟███▛        Shell: zsh 5.8
#          ▟███▛               ▜▛ ▟███▛         Resolution: 2560x1440
# ▟███████████▛                  ▟██████████▙   DE: Plasma
# ▜██████████▛                  ▟███████████▛   WM: KWin
#       ▟███▛ ▟▙               ▟███▛            Theme: Breeze [GTK2/3]
#      ▟███▛ ▟██▙             ▟███▛             Icons: breeze [GTK2/3]
#     ▟███▛  ▜███▙           ▝▀▀▀▀              Terminal: .konsole-wrappe
#     ▜██▛    ▜███▙ ▜██████████████████▛        CPU: Intel i5-6300U (4) @ 3.0
#      ▜▛     ▟████▙ ▜████████████████▛         GPU: Intel Skylake GT2 [HD Gr
#            ▟██████▙       ▜███▙               Memory: 4007MiB / 7832MiB
#           ▟███▛▜███▙       ▜███▙
#          ▟███▛  ▜███▙       ▜███▙
#          ▝▀▀▀    ▀▀▀▀▘       ▀▀▀▘


# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # /home/jcleng/./nix/my_nix_config.nix
    ];

  # Use the systemd-boot EFI boot loader.ok
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nix.binaryCaches = [ "https://mirrors.ustc.edu.cn/nix-channels/store/" "https://cache.nixos.org/" ];


  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;
  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [ "zh_CN.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
  i18n.defaultLocale = "zh_CN.UTF-8";

  # Fcitx输入法
  i18n.inputMethod = {
    enabled = "fcitx";
  };

  # fcitx拼音包
  i18n.inputMethod.fcitx.engines = with pkgs.fcitx-engines; [ libpinyin rime ];
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the Plasma 5 Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;


  # Configure keymap in X11
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  # Enable bluetooth
  hardware.bluetooth.enable = true;
  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };
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
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    firefox
    nano
    zsh
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
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
  # hosts
  networking.hosts = {
    "127.0.0.1" = [ "lxx.db.net" "lxx.fast.net" ];
    "192.168.1.235" = [ "phone.test.net" ];
    "192.168.0.2" = [ "fileserver.local" "nameserver.local" ];
  };
  # zsh
  environment.shells = [ pkgs.bashInteractive pkgs.zsh ];
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  nix.trustedUsers = [ "root" "jcleng" ];
}
