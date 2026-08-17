{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../../pkgs
  ];
  users.users.irendy = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
    ];
    packages =
      (with pkgs; [
        zsh # system
        iwd
        fastfetch
        brightnessctl
        pavucontrol
        libpulseaudio
        pulseaudio
        # portaudio
        usbutils
        pciutils
        btop
        tree
        sqlite
        xev
        acpi
        inxi # hardware test
        lshw

        bluetui # bluetooth

        bspwm # desktop
        sxhkd
        kitty
        picom
        polybar
        dunst
        feh
        rofi
        xclip
        flameshot
        libnotify
        udiskie
        xprop
        chromium
        # nomacs

        vscodium # editor
        # emacs
        helix
        neovim

        p7zip # archive
        zip
        unzip
        rar
        unrar

        flatpak # pkgs manager

        # libuchardet # tools

        # etc.
        ncmdump
        ncmdump-go
        ch341ser

      ])
      ++ (with pkgs.perl5Packages; [
        DateTime
      ])
      ++ (with pkgs.haskellPackages; [
        ghc
        cabal-install
        haskell-language-server
      ]);
  };

  programs.tcpdump.enable = true;
  programs.arp-scan.enable = true;
  programs.traceroute.enable = true;
  programs.firefox.enable = true;
  programs.chromium.enable = true;
  programs.steam = {
    enable = true;
  };
  programs.wireshark.enable = true;
  programs.bat.enable = true;
  programs.clash-verge.enable = true;
  programs.thunderbird.enable = true;
  programs.localsend = {
    enable = true;
    openFirewall = true;
  };
  programs.yazi = {
    enable = true;
    plugins = {
      inherit (pkgs.yaziPlugins) mount lazygit smart-enter;
    };
    settings = import ../../pkgs/yazi/settings.nix;
  };
  networking.hosts = {
    "101.42.138.7" = [ "server1" ];
  };
  services.flatpak.enable = true;
  # services.nginx.enable = true;
  # services.mongodb.enable = true;
  # services.gns3-server = {
  #   enable = true;
  #   package = pkgs.gns3-server;
  #   dynamips.enable = true;
  #   # ssl.enable = true;
  #   # auth.enable = true;
  #   ubridge.enable = true;
  #   ubridge.package = pkgs.ubridge;
  #   vpcs.enable = true;
  #   vpcs.package = pkgs.vpcs;
  # };

}
