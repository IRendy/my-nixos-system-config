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

    cyberchef # ctf
    stegsolve
    qrrs
    qrtool
    zbar
    (cutter.withPlugins (
      ps: with ps; [
        jsdec
        rz-ghidra
      ]
    ))
    radare2
    ghidra

    hexyl # hex viewer
    hexedit # hex editor
    sxiv # image viewer

    gimp # image editor
    # krita

    uv # dev
    ruff
    nixfmt
    # gcc
    gfortran
    gnumake
    azure-sdk-for-cpp.cmake
    xmake
    (python314.withPackages (
      python-pkgs: with python-pkgs; [
        xlrd
        openpyxl
        pandas
        numpy
        polars
        dask
        pyarrow
        matplotlib
        numba
        tkinter
      ]
    ))
    zig
    rustup
    nodejs
    pnpm
    android-tools
    apktool
    apksigner
    jdk
    go
    marksman
    ruby
    lua
    racket
    purescript
    openssl # cybersafe
    # mongodb # web dev
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

    # emacs # editor
    tree-sitter

    wpsoffice-cn # office
    libreoffice
    # yazi # yazi
    file
    ffmpeg
    resvg
    jq
    # poppler
    poppler-utils
    ripgrep
    fzf
    imagemagick

    ranger # btw
    dust
    obs-studio
    fzf # improve
    zoxide
    just
    fd
    eza
    lazygit
    tmux
    zellij

    # qbittorrent # entertainment
    qbittorrent-enhanced
    netease-cloud-music-gtk
    yacreader # manga
    # osdlyrics
    mpv
    audacious
    cmatrix
    termusic
    # cowsay
    # figlet
    # toilet
    gnugo # game
    lutris
    wineWow64Packages.stable
    winetricks

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
  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
    extraPackages = epkgs: [
      #   epkgs.magit
    ];
    extraConfig = ''
      (setq standard-indent 2)
    '';
  };
  programs.helix = {
    enable = true;
    extraPackages = [ pkgs.marksman ];
  };
  # programs.git = {
  #   enable = true;
  #   userName = "IRendy";
  #   userEmail = "irendy@qq.com";
  # };

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
