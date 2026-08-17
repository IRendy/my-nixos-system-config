{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./flatpack
  ];
  nixpkgs.overlays = [
    (final: prev: {
      ncmdump = final.callPackage ./ncmdump/package.nix { };
      ncmdump-go = final.callPackage ./ncmdump-go/package.nix { };
      ch341ser = final.callPackage ./ch341ser/package.nix { };
    })
  ];
}
