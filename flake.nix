{
  description =
    "My personal config files for my daily environment, configured for Dell Inspiron 7590. Now with flakes!";

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
  inputs.d-mail.url = "github:Ninlives/D-mail";

  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      fn  = import ./fn  { inherit lib var; };
      var = import ./var { inherit lib pkgs; };
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in import ./def { inherit fn lib var pkgs self inputs; };
}
