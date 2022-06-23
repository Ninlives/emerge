{ lib, var }:
{
  mkApp =
    { drv
    , name ? drv.pname or drv.name
    , exePath ? drv.passthru.exePath or "/bin/${name}"
    }:
    {
      type = "app";
      program = "${drv}${exePath}";
    };

  mkCube =
    { specialArgs
    , modules }:
    with lib;
    with lib.types;
    let
      function = mkOptionType {
        name = "function";
        description = "function";
        check = isFunction;
        merge = mergeOneOption;
      };
      alpha-world-line = lib.nixosSystem {
        inherit specialArgs;
        inherit (var) system;
        modules = modules ++ [{
          options.d-mail = mkOption {
            type = attrsOf (either attrs function);
            default = {};
          };
        }];
      };
    in
    alpha-world-line.extendModules {
      specialArgs = specialArgs // { inherit alpha-world-line; };
      modules = builtins.attrValues (alpha-world-line.config.d-mail);
    };
}
