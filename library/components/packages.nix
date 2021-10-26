{ ... }@inputs:
with inputs;
with nixpkgs.lib;
with out-of-world; {
  legacyPackages.${system} = import nixpkgs {
    inherit system;
    overlays = mergedOverlays;
    config = nixpkgsConfig;
  };

  packages.${system} = {
    image = let
      os = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          (dirs.cyber.top-level + /image.nix)
          (dirs.world.option + /secrets.nix)
          (dirs.secrets + /token.nix)
        ];
      };
    in os.config.system.build.image;
  };
}
