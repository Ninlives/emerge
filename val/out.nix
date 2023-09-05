{
  fn,
  self,
  inputs,
  ...
}: {
  flake.overlays' = map import (fn.dotNixFromRecursive ../pkg);
  perSystem = {
    system,
    config,
    inputs',
    ...
  }: {
    formatter = inputs'.nixpkgs.legacyPackages.alejandra;
    legacyPackages = import inputs.nixpkgs {
      inherit system;
      overlays = self.overlays';
    };
    _module.args.pkgs = config.legacyPackages;
  };

  # infections.nemo = username: homeDirectory:
  #   let
  #     ttyOnly = lib.nixosSystem {
  #       inherit (var) system;
  #       modules = [ ];
  #     };
  #   in inputs.home-manager.lib.homeManagerConfiguration {
  #     inherit pkgs;
  #     extraSpecialArgs = {
  #       inherit fn var self inputs;
  #       nixosConfig = ttyOnly.config;
  #     };
  #     modules = (fn.dotNixFromRecursive ../impl/neko)
  #       ++ [{ home = { inherit username homeDirectory; }; }];
  #   };
}
