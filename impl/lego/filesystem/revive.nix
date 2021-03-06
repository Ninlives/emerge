{ config, lib, pkgs, ... }:
with pkgs;
with lib;
with lib.types;
let
  cfg = config.revive;
  mount = "${utillinux}/bin/mount";
  mapping = mkOptionType {
    name = "mapping";
    check = x:
      builtins.isAttrs x && x ? src && x ? dst && path.check x.src
      && path.check x.dst;
  };
  pathToMapping = p:
    if builtins.isAttrs p then
      p
    else {
      src = p;
      dst = p;
    };
  pathsToMappings = map pathToMapping;
in {
  options.revive = {
    enable = mkOption {
      type = bool;
      default = true;
    };
    specifications = mkOption {
      type = attrsOf (submodule ({ ... }: {
        options = {
          seal = mkOption {
            type = nullOr path;
            default = null;
          };
          user = mkOption {
            type = str;
            default = "root";
          };
          group = mkOption {
            type = str;
            default = "root";
          };
          boxes = mkOption {
            type = listOf (either mapping path);
            default = [ ];
            apply = pathsToMappings;
          };
          scrolls = mkOption {
            type = listOf (either mapping path);
            default = [ ];
            apply = pathsToMappings;
          };
        };
      }));
      default = { };
    };
  };

  config = mkIf (cfg.enable && cfg.specifications != { }) {
    system.activationScripts.revive = stringAfter [ "etc" "users" "groups" ]
      (concatStringsSep "\n" (mapAttrsToList (name: icfg:
        let
          prefix = toString icfg.seal;
          user = icfg.user;
          group = icfg.group;
          run = "${utillinux}/bin/runuser -u ${user} -g ${group} --";
        in (concatMapStringsSep "\n" (mapping:
          let
            src = builtins.toPath "${prefix}/${toString mapping.src}";
            dst = toString mapping.dst;
          in ''
            echo Reviving ${dst} from ${src}
            mkdir -p '${src}' 
            chown ${user} '${src}' 
            chgrp ${group} '${src}' 
            ${run} mkdir -p '${dst}'
            mount --bind '${src}' '${dst}'
          '') icfg.boxes) + (concatMapStringsSep "\n" (mapping:
            let
              src = builtins.toPath "${prefix}/${toString mapping.src}";
              dst = toString mapping.dst;
            in ''
              echo Reviving ${dst} from ${src}
              mkdir -p '${dirOf src}'
              touch '${src}' 
              chown ${user} '${src}' 
              chgrp ${group} '${src}' 
              ${run} mkdir -p '${dirOf dst}'
              ${run} touch '${dst}'
              mount --bind '${src}' '${dst}'
            '') icfg.scrolls)) (filterAttrs
              (n: v: v.seal != null && (v.boxes != [ ] || v.scrolls != [ ]))
              cfg.specifications)));
  };
}
