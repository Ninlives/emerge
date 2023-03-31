{
  description =
    "My personal config files for my daily environment, configured for Asus Flow X13. Now with flakes!";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  inputs.sops-nix = {
    url = "github:Ninlives/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.jovian = {
    url = "github:Jovian-Experiments/Jovian-NixOS";
    flake = false;
  };
  inputs.lanzaboote.url = "github:nix-community/lanzaboote";

  inputs.data.url = "github:Ninlives/data";
  inputs.values.url = "git+ssh://git@github.com/Ninlives/values.git";

  inputs.terrasops.url = "github:NickCao/terrasops";
  inputs.terranix.url = "github:Ninlives/terranix";
  inputs.resign.url = "github:NickCao/resign";
  inputs.deckbd = {
    url = "github:Ninlives/deckbd";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      fn  = import ./fn  { inherit lib var pkgs; };
      var = import ./var { inherit lib pkgs; };
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in import ./def { inherit fn lib var pkgs self inputs; };
}
