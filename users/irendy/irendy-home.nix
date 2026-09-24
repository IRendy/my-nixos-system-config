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
    carapace
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
programs.waybar = {
  enable = true;
#   settings = {
#     mainBar = {  # ← 建议显式命名 bar，避免多 bar 时混淆
#       layer = "top";
#       modules-left = [ "sway/workspaces" "sway/mode" ];
#       modules-center = [ "sway/window" ];
#       modules-right = [ "battery" "clock#data" "clock#time" ];

#       # ✅ 必须补充以下模块配置
#       "sway/workspaces" = {
#         disable-scroll = false;
#         all-outputs = true;
#         format = "{name}";
#       };

#       "sway/mode" = {
#         format = "<span style=\"italic\">{}</span>";
#       };

#       "sway/window" = {
#         max-length = 50;
#         rewrite = {
#           "" = "Desktop";  # 无窗口时的默认文本
#         };
#       };

#       battery = {
#         bat = "BAT0";      # ← 根据你的实际电池名称修改
#         adapter = "ACAD";  # ← 根据你的实际适配器名称修改
#         format = "{capacity}% {icon}";
#         format-icons = ["" "" "" "" ""];
#       };

#       "clock#data" = {     # 自定义实例名需用引号包裹
#         format = "{:%Y-%m-%d}";
#         tooltip-format = "{:%Y-%m-%d | %H:%M}";
#       };

#       "clock#time" = {
#         format = "{:%H:%M}";
#         interval = 30;
#       };
#     };
#   };

#   # 💡 别忘了样式，否则 Waybar 几乎不可见
#   style = ''
#   /* ========== 全局基础 ========== */
#   * {
#     font-family: "JetBrains Mono", "Sarasa Term SC", sans-serif;
#     font-size: 14px;
#     border: none;
#     border-radius: 0;
#     min-height: 0;
#   }

#   window#waybar {
#     background: #282c34;
#     color: #abb2bf;
#     transition-property: background-color;
#     transition-duration: .3s;
#   }

#   /* ========== 左侧：工作区 & 模式 ========== */
#   #workspaces button {
#     padding: 0 10px;
#     background: transparent;
#     color: #abb2bf;
#     border-bottom: 2px solid transparent;
#     transition: all 0.2s ease;
#   }

#   #workspaces button:hover {
#     background: #3e4451;
#     color: #fff;
#   }

#   #workspaces button.active {
#     background: #61afef;
#     color: #282c34;
#     border-bottom: 2px solid #61afef;
#     font-weight: bold;
#   }

#   #mode {
#     padding: 0 12px;
#     margin-left: 8px;
#     background: #e06c75;
#     color: #282c34;
#     border-radius: 4px;
#     font-style: italic;
#   }

#   /* ========== 中间：窗口标题 ========== */
#   #window {
#     padding: 0 16px;
#     color: #98c379;
#     font-weight: 500;
#   }

#   /* ========== 右侧：电量 & 时间 ========== */
#   #battery,
#   #clock-time {
#     padding: 0 8px;
#   }

#   /* ✅ 解决日期与时钟太近的问题 */
#   #clock-data {
#     margin-right: 16px;
#   }

#   #battery {
#     color: #d19a66;
#   }

#   #battery.warning {
#     color: #e5c07b;
#     animation: blink 1s linear infinite alternate;
#   }

#   #battery.critical {
#     color: #e06c75;
#     animation: blink 0.5s linear infinite alternate;
#   }

#   #clock-data {
#     color: #c678dd;
#   }

#   #clock-time {
#     color: #56b6c2;
#     font-weight: bold;
#   }

#   /* ========== 动画 ========== */
#   @keyframes blink {
#     to { opacity: 0.3; }
#   }
# '';
};
  # programs.git = {
  #   enable = true;
  #   userName = "IRendy";
  #   userEmail = "irendy@qq.com";
  # };

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
