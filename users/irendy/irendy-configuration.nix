{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ../../pkgs ];
  users.users.irendy = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
      "input"
      "kvm"
      "video"
      "render"
      "libvirtd"
    ];
    packages =
      (with pkgs; [
        # zsh # system
        fish
        elvish
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
        ntfs3g
        inxi # hardware test
        lshw
        gnupg # Privacy
        # pinentry-all
        pinentry-rofi
        # ventoy
        hledger # finance
        hledger-web
        hledger-ui

        # dev
        # rustup
        rustc
        rust-analyzer
        rustfmt
        cargo
        clippy
        rustPlatform.rustLibSrc
        R
        ruff
        carapace
        nixfmt
        # gcc
        gfortran
        gnumake
        cmake
        xmake
        clang-tools
        bear
        dotnet-sdk
        uv
        (python314.withPackages (
          python-pkgs: with python-pkgs; [
            python-lsp-server
            xlrd
            openpyxl
            pandas
            numpy
            pyyaml
            flask
            django
            requests
            websockets
            beautifulsoup4
            lxml
            modelscope
            tqdm
            matplotlib
            tkinter
            rich
            click
            loguru
          ]
        ))
        zig
        nodejs
        pnpm
        android-tools
        scrcpy
        aapt
        apktool
        apksigner
        jdk
        go
        marksman
        ruby
        lua
        racket
        purescript
        flutter
        openssl # cybersafe
        # mongodb # web dev
        # nginx
        # virtualbox
        # chromium
        # hplipWithPlugin # printer
        # godot # game development
        # blender aseprite
        #claude-code # agent

        # emacs # editor
        tree-sitter
        prettier
        libxml2
        taplo
        stylua

        bluetui # bluetooth

        wifitui # network

        bspwm # desktop
        sxhkd
        kitty
        alacritty
        picom
        polybar
        betterlockscreen
        wl-clipboard # wayland sway
        xwayland
        swaybg
        waybar
        mako
        swappy
        cage # wayland cage
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
        csvlens
        visidata

        p7zip # archive
        peazip
        zip
        unzip
        rar
        unrar

        flatpak # pkgs manager

        # libuchardet # tools
        (qgis.override {
          extraPythonPackages = ps: [
            ps.pyproj
            ps.skyfield
            ps.timezonefinder
          ];
        })
        wineWow64Packages.stable
        winetricks
        appimage-run
        filezilla

        # etc.
        # overlays
        ncmdump
        ncmdump-go
        # ch341ser
        # emacs-git

      ])
      ++ (with pkgs.perl5Packages; [ DateTime ])
      ++ (with pkgs.haskellPackages; [
        ghc
        cabal-install
        haskell-language-server
      ]);
  };
  nixpkgs.config.permittedInsecurePackages = [ "ventoy-1.1.12" ];

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    ohMyZsh = {
      enable = true;
      theme = "michelebologna";
      plugins = [
        "sudo"
        "git"
        "zoxide"
        "eza"
        "fzf"
        "extract"
        "z"
      ];
    };
    syntaxHighlighting.enable = true;
    shellAliases = {
      cls = "clear";
      lgens = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      delgens = "sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system";
    };
    shellInit = ''
      export DEFAULT_USER="$USER"
      export EDITOR='hx'
      zstyle ':omz:update' mode disabled
      export RUSTUP_DIST_SERVER="https://rsproxy.cn"
      export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"
      export GO111MODULE=on
      export GOPROXY=https://goproxy.cn
      export PUB_HOSTED_URL="https://mirrors.tuna.tsinghua.edu.cn/dart-pub"
      export FLUTTER_STORAGE_BASE_URL="https://mirrors.tuna.tsinghua.edu.cn/flutter"
      export CHROME_EXECUTABLE=$(which chromium)
      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }
    '';
    interactiveShellInit = ''
      export PATH=$HOME/.nix-profile/bin:$PATH
      export PATH=$HOME/.npm-global/bin:$PATH
      export PATH=$HOME/.cargo/bin:$PATH
      export PATH=$HOME/.local/bin:$PATH
      export PATH=$HOME/go/bin:$PATH
    '';

  };
  programs.tcpdump.enable = true;
  programs.arp-scan.enable = true;
  programs.traceroute.enable = true;
  programs.firefox.enable = true;
  programs.chromium.enable = true;
  programs.i3lock.enable = true;
  security.pam.services.i3lock-color.enable = true;
  programs.wireshark.enable = true;
  programs.bat.enable = true;
  programs.virt-manager.enable = true;
  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs = pkgs: [
        pkgs.icu
        pkgs.libxcrypt-legacy
      ];
    };
  };
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  programs.steam = {
    enable = true;
  };
  programs.clash-verge = {
    enable = true;
    package = pkgs.clash-verge-rev;
    serviceMode = true;
    tunMode = true;
  };
  programs.thunderbird.enable = true;
  programs.localsend = {
    enable = true;
    openFirewall = true;
  };
  programs.yazi = {
    enable = true;
    plugins = {
      inherit (pkgs.yaziPlugins) mount lazygit;
      baidu = ../../pkgs/yazi/plugins/baidu.yazi;
    };
    settings = import ../../pkgs/yazi/settings.nix;
  };
  networking.hosts = {
    "101.42.138.7" = [ "server1" ];
  };
  services.flatpak.enable = true;
  services.gnome.gnome-keyring.enable = true;
  boot.supportedFilesystems = [ "ntfs" ];
  systemd.tmpfiles.rules = [
    "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware"
  ];

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
