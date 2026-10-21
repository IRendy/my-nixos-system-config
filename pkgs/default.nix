{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # ./flatpack
  ];
  nixpkgs.overlays = [
    (final: prev: {
      ncmdump = final.callPackage ./ncmdump/package.nix { };
      ncmdump-go = final.callPackage ./ncmdump-go/package.nix { };
      ch341ser = final.callPackage ./ch341ser/package.nix { };
    })
    (import (builtins.fetchGit {
      url = "https://github.com/nix-community/emacs-overlay.git";
      ref = "master";
      rev = "7905f782c495294a79af87feba4ed2b755d9923d"; # change the revision
  }))
  ];
}
