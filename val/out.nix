{
  fn,
  lib,
  self,
  inputs,
  withSystem,
  ...
}: let
  ovlFromRecursive = dir:
    with fn;
      filesFromWithRecursive dir [disabledFilter dotNixFilter (f: f.type != "regular" || (baseNameOf f.path) != "config.nix")] [
        disabledFilter
        defNixFilter
      ];
in {
  flake.overlays' = map import (ovlFromRecursive ../pkg);
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
      config = import ../pkg/config.nix {inherit lib;};
    };
    _module.args.pkgs = config.legacyPackages;
  };

  flake.droidPackages = withSystem "x86_64-linux" ({
    system,
    inputs',
    ...
  }:
    inputs'
    .nixpkgs
    .legacyPackages
    .pkgsCross
    .aarch64-android-prebuilt
    .extend (final: prev: {
      openssl = prev.openssl.override {
        enableKTLS = false;
      };
    }));

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
