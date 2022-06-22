{ config, lib, modules, inputs, specialArgs, fn, var, ... }:
let
  eval = inputs.nixpkgs.lib.nixosSystem {
    inherit specialArgs;
    inherit (var) system;
    modules = modules ++ [{ disabledModules = fn.dotNixFrom ./.; }];
  };
in { _module.args.alpha-world-line = eval.config; }
