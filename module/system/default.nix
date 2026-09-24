{ config, lib, pkgs, ... }:
{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;
  networking.hostName = "irendy-nixos";

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      qt6Packages.fcitx5-qt
      fcitx5-mozc
      qt6Packages.fcitx5-chinese-addons
      fcitx5-nord
      fcitx5-lua
      fcitx5-m17n
      fcitx5-hangul
      fcitx5-pinyin-moegirl
    ];
  };

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  programs.nix-ld.enable = true;
  virtualisation.docker = {
    enable = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.adwaita-mono
    nerd-fonts.fira-mono
    nerd-fonts.fira-code
    nerd-fonts.noto
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.hurmit
    nerd-fonts.hack
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    fira-code
    fira-code-symbols
    arkpandora_ttf
    lxgw-neoxihei
    jetbrains-mono
    # noto-fonts-cjk
    # source-han-sans
    # source-han-sans-japanese
    # source-han-serif-japanese

    vista-fonts
    carlito
    corefonts
    dejavu_fonts
    courier-prime
    liberation_ttf_v2
    wine64Packages.fonts
    nerd-fonts.symbols-only
    font-awesome_6
    open-sans
  ];
  fonts.fontconfig.useEmbeddedBitmaps = true;
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];
  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    GLFW_IM_MODULE = "ibus";
  };

  services.openssh.enable = true;

  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "nerver";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };
  powerManagement.enable = true;
  # Open ports in the firewall.
  # 8080 HTTP, 53318 qrcp
  networking.firewall.allowedTCPPorts = [ 8080 53318 ];
  networking.firewall.allowedUDPPorts = [ 8080 53318 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
