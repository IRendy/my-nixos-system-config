{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "git+https://mirrors.nju.edu.cn/git/nixpkgs.git?ref=nixos-26.05&shallow=1";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
      };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.irendy-nixos = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix

        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.irendy = import ./users/irendy/irendy-home.nix;
        }
      ];
    };
    packages.x86_64-linux.ncmdump = nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/ncmdump/package.nix {};
  };
}
