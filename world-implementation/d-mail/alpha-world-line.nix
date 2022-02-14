{ config, lib, pkgs, modules, inputs, system, out-of-world, specialArgs, ... }:
let
  inherit (config.lib.conf) entry;
  inherit (out-of-world.function) dotNixFilesFrom;
  eval = inputs.nixpkgs.lib.nixosSystem {
    inherit system specialArgs;
    modules = modules ++ [{ disabledModules = dotNixFilesFrom ./.; }];
  };
in { _module.args.alpha-world-line = eval.config; }
