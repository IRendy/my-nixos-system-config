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
    inkscape
    # krita

    wpsoffice-cn # office
    libreoffice
    # yazi
    file
    ffmpeg
    resvg
    jq
    # poppler
    poppler-utils
    ripgrep
    fzf
    imagemagick
    ghostscript

    ranger # btw
    dust
    obs-studio
    fzf # improve
    zoxide
    just
    fd
    eza
    lazygit
    jjui
    tmux
    zellij

    qbittorrent # entertainment
    librewolf
    netease-cloud-music-gtk
    yacreader # manga
    # osdlyrics
    mpv
    audacious
    cmatrix
    termusic
    deadbeef
    # cowsay
    # ponysay
    # figlet
    # toilet
    # gnugo # game
    # lutris
    wineWow64Packages.stable
    winetricks

    anki-bin # study
    stellarium
    qgis
    bc
    goldendict-ng
    zotero
    # gogui
    # gns3-gui
    # octave
    # wolfram-engine
    #trustedqsl # amateur radio
    # unixcw
    # aldo
    #rtl-sdr
    #qsstv
    #gnuradio

    # gnucash # finance

  ];
  home.pointerCursor = {
    x11.enable = true;
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
  };
  # programs.emacs = {
  #   enable = true;
  #   package = pkgs.emacs;
  #   extraPackages = epkgs: [
  #     #   epkgs.magit
  #   ];
  #   extraConfig = ''
  #     (setq standard-indent 2)
  #   '';
  # };
  programs.helix = {
    enable = true;
    extraPackages = [ pkgs.marksman ];
  };
  programs.waybar = {
    enable = true;
  };
  # programs.git = {
  #   enable = true;
  #   userName = "IRendy";
  #   userEmail = "irendy@qq.com";
  # };

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
