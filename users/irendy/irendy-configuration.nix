{ config, lib, pkgs, ... }:

{
  users.users.irendy = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" ];
    packages =  (with pkgs; [
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
      # nomacs

      vscodium # editor
      # emacs
      helix
      neovim

      
      p7zip  # archive
      zip
      unzip
      rar
      unrar

      # etc.
      ncmdump
      ch341ser
     
    ]) ++ (with pkgs.perl5Packages; [
      DateTime
    ]) ++ (with pkgs.haskellPackages; [
      ghc
      cabal-install
      haskell-language-server
    ]);
  };

  nixpkgs.overlays = [
    (final: prev: {
      ncmdump = final.callPackage ../../pkgs/ncmdump/package.nix {};
      ch341ser = final.callPackage ../../pkgs/ch341ser/package.nix {};
    })
  ];
  programs.tcpdump.enable = true;
  programs.arp-scan.enable = true;
  programs.traceroute.enable = true;
  programs.firefox.enable = true;
  # programs.chromium.enable = true;
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
      inherit (pkgs.yaziPlugins) mount git rsync sshfs;
    };
    settings = {
      yazi = lib.importTOML ../../pkgs/yazi/settings.toml;
      keymap = lib.importTOML ../../pkgs/yazi/keymap.toml;
    };
  };
  networking.hosts = {
    "101.42.138.7" = ["server1"];
  };
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

