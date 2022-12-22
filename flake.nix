{
  description =
    "My personal config files for my daily environment, configured for Asus Flow X13. Now with flakes!";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.external.url = "github:nixos-cn/flakes";
  inputs.data.url = "github:Ninlives/data";
  inputs.terrasops.url = "github:NickCao/terrasops";
  inputs.terranix.url = "github:Ninlives/terranix";
  inputs.resign.url = "github:NickCao/resign";

  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      fn  = import ./fn  { inherit lib var pkgs; };
      var = import ./var { inherit lib pkgs; };
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in import ./def { inherit fn lib var pkgs self inputs; };
}
