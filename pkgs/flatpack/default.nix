{ config, pkgs, lib, ... }:

{
  services.flatpak.remotes = lib.mkOptionDefault [ {
    name = "flathub";
    location = "https://mirrors.ustc.edu.cn/flathub";
  } ];
  services.flatpak.packages = [
    "com.tencent.WeChat"
    "com.qq.QQ"
    "com.baidu.NetDisk"
  ];
}
