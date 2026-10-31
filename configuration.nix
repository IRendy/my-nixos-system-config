{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./module/system/default.nix
    ./users/irendy/irendy-configuration.nix
    ./hosts/Thinkpad_X230/default.nix
  ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  nix.settings.substituters = [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    # "https://mirrors.cqupt.edu.cn/nix-channels/store"
    # "https://mirror.nju.edu.cn/nix-channels/store"
    "https://mirror.sjtu.edu.cn/nix-channels/store"
    # "https://mirrors.cernet.edu.cn/nix-channels/store"
  ];

  system.stateVersion = "26.05";
}
