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
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.external = {
    url = "github:nixos-cn/flakes";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.data.url = "github:Ninlives/data";

  outputs = { self, nixpkgs, home-manager, flake-utils, external, sops-nix, data
    }@inputs:
    let
      variables = import ./library/components/variables.nix inputs;
      functions = import ./library/components/functions.nix (inputs // variables);
      args = inputs // variables // functions;
      hosts = import ./library/components/hosts.nix args;
      apps = import ./library/components/apps.nix (args // hosts);
      packages = import ./library/components/packages.nix args;
    in {
      inherit (hosts) nixosConfigurations;
      inherit (apps) apps devShell;
      inherit (packages) legacyPackages packages;
    };
}
