_default:
    @just --list

switch:
    sudo nixos-rebuild switch

boot:
    sudo nixos-rebuild boot

dry-activate:
    sudo nixos-rebuild dry-activate

update:
    sudo nix flake update

clean:
    nix-collect-garbage
