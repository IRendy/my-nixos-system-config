{ config, pkgs, ... }:

{
  home.username = "irendy";
  home.homeDirectory = "/home/irendy";

  home.packages = with pkgs; [
    htop

    nmap # network
    net-tools
    wireshark
    bind
    
    uv # dev
    ruff
    nixfmt
    # gcc
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
    lua
    cargo-tauri
    openssl # web dev
    # mongodb
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
    # unixcw
    # aldo

  ];
  home.pointerCursor = {
    x11.enable = true;
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
  };
  # programs.git = {
  #   enable = true;
  #   userName = "IRendy";
  #   userEmail = "irendy@qq.com";
  # };

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}

