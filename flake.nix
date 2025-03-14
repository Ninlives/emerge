{
  description = "My personal config files for my daily environment, configured for Steam Deck. Now with flakes!";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.home-manager = {
    url = "github:Ninlives/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.jovian = {
    url = "github:Jovian-Experiments/Jovian-NixOS";
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
  inputs.paisa.url = "github:Ninlives/paisa";
  inputs.parasyteOS.url = "github:parasyteOS/flake/upstream";

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    fn = import ./fn {inherit lib;};
  in
    flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = {inherit fn;};
    } ({...}: {
      systems = ["x86_64-linux"];
      imports = (fn.dotNixFromRecursive ./cmd) ++ (fn.dotNixFromRecursive ./val);
    });
}
