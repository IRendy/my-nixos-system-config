{ config, pkgs, ... }:

{
  home.username = "irendy";
  home.homeDirectory = "/home/irendy";

  home.packages = with pkgs; [
    htop
    neofetch

    nmap # network
    net-tools
    wireshark
    bind

    
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

  ];
  home.pointerCursor = {
    x11.enable = true;
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
  };

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}

