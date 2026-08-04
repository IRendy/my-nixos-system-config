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

      nmap # network
      net-tools
      wireshark
      bind

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
      
      uv # dev
      ruff
      nixfmt
      gcc
      gfortran
      gnumake
      azure-sdk-for-cpp.cmake
      xmake
      python314
      python314Packages.tkinter
      zig
      rustup
      nodejs
      pnpm
      android-tools
      jdk
      go
      marksman
      ruby
      # mongodb
      openssl # web dev
      # nginx

      # virtualbox
      # chromium

      # hplipWithPlugin # printer

      #rtl-sdr # amateur radio - ham
      #qsstv
      #gnuradio


      # godot # game development
      # blender aseprite

      #claude-code # agent

      vscodium # editor
      # emacs
      helix
      neovim

      wpsoffice-cn # office
      libreoffice
      gimp
      # wechat-uos # IM
      # wechat

      # yazi # yazi
      file
      ffmpeg
      resvg
      jq
      poppler
      ripgrep
      fzf
      imagemagick
      
      ranger # btw
      dust
      obs-studio

      fzf# improve
      zoxide
      just
      fd
      eza
      lazygit
      tmux
      font-manager

      qbittorrent # entertainment
      netease-cloud-music-gtk
      yacreader
      # osdlyrics
      mpv
      audacious
      cmatrix
      termusic
      # activate-linux
      # cowsay
      # figlet
      # toilet
      
      anki-bin # study
      stellarium
      qgis
      bc
      goldendict-ng
      zotero
      gogui
      # gns3-gui
      # octave
      # wolfram-engine

      #trustedqsl # amateur radio
      unixcw
      aldo

      p7zip  # archive
      zip
      unzip
      rar
      unrar

      # etc.
     
    ]) ++ (with pkgs.perl5Packages; [
      DateTime
    ]) ++ (with pkgs.haskellPackages; [
      ghc
      cabal-install
      haskell-language-server
    ]);

  };
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
      yazi = lib.importTOML ./packages/yazi/settings.toml;
      keymap = lib.importTOML ./packages/yazi/keymap.toml;
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

