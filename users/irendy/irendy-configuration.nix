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
      "input"
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
        rustup
        cargo

        bluetui # bluetooth

        wifitui # network

        bspwm # desktop
        sxhkd
        kitty
        alacritty
        picom
        polybar
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
        xan
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

        # etc.
        # overlays
        ncmdump
        ncmdump-go
        ch341ser
        emacs-git

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
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.12"
  ];

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
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
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
