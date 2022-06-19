{ config, pkgs, constant, out-of-world, ... }:
let
  inherit (out-of-world) files;
  inherit (constant) user;
  inherit (pkgs) nixFlakes writeText;
in {
  nix.settings.sandbox = true;
  nix.nixPath = [ "nixpkgs=${pkgs.path}" ];
  nix.settings.trusted-users = [ user.name ];
  nix.settings.substituters = [
    "https://mirror.sjtu.edu.cn/nix-channels/store?priority=0"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=5"
    "https://nixos-cn.cachix.org"
    "https://data.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "nixos-cn.cachix.org-1:L0jEaL6w7kwQOPlLoCR3ADx+E3Q8SEFEcB9Jaibl0Xg="
    "data.cachix.org-1:we/1k8A3S5cx8aM9wb6ig/DWL1cidVQluhJwD8V3VXM="
  ];
  nix.settings.auto-optimise-store = true;
}
