{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "git+https://mirrors.nju.edu.cn/git/nixpkgs.git?ref=nixos-26.05&shallow=1";
    #home-manager.url = "github:nix-community/home-manager/release-26.05";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.irendy-nixos = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
      ];
    };
  };
}
