{ lib, var }: {
  mkApp = { drv, name ? drv.pname or drv.name
    , exePath ? drv.passthru.exePath or "/bin/${name}" }: {
      type = "app";
      program = "${drv}${exePath}";
    };

  mkCube = { specialArgs, modules }:
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
            default = { };
          };
        }];
      };

      spec-d-mails =
        (mapAttrs (_: v: builtins.attrValues v.configuration.d-mail)
          alpha-world-line.config.specialisation) // {
            garden = builtins.attrValues (alpha-world-line.config.d-mail);
          };

    in alpha-world-line.extendModules {
      specialArgs = specialArgs;
      modules = [
        {
          options.specialisation-name = mkOption {
            type = str;
            default = "garden";
          };
        }
        {
          specialisation =
            mapAttrs (name: _: { configuration.specialisation-name = name; })
            alpha-world-line.config.specialisation;
        }
      ] ++ mapAttrsToList (name: d-mails:
        { config, lib, ... }:
        lib.mkIf (config.specialisation-name == name) (mkMerge (map (d-mail:
          if isFunction d-mail then d-mail alpha-world-line else d-mail)
          d-mails))) spec-d-mails;
    };
}
