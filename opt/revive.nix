{
  lib,
  pkgs,
  config,
  ...
}:
with pkgs;
with lib;
with lib.types; let
  cfg = config.revive;
  mapping = mkOptionType {
    name = "mapping";
    check = x:
      builtins.isAttrs x && path.check x.src or "" && path.check x.dst or "";
  };

  specs =
    filterAttrs (n: v: v.seal != null && (v.boxes != [] || v.scrolls != []))
    cfg.specifications;

  pairs = concatLists (mapAttrsToList (name: cfg: let
    prefix = toString cfg.seal;
    user = cfg.user;
    group = cfg.group;
    convert = type: mapping:
      {
        inherit type;
        runUser = user;
        runGroup = group;
        user = mapping.user or user;
        group = mapping.group or group;
        mode = mapping.mode or "g-rwx,o-rwx";
        dst = builtins.toPath (toString mapping.dst);
      }
      // (optionalAttrs (mapping ? src) {
        src = builtins.toPath "${prefix}/${toString mapping.src}";
      });
  in
    (map (convert "box") cfg.boxes) ++ (map (convert "scroll") cfg.scrolls))
  specs);
in {
  options.revive = {
    enable = mkOption {
      type = bool;
      default = true;
    };
    specifications = mkOption {
      type = attrsOf (submodule ({...}: {
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
          mode = mkOption {
            type = str;
            default = "g-rwx,o-rwx";
          };
          boxes = mkOption {
            type = listOf mapping;
            default = [];
          };
          scrolls = mkOption {
            type = listOf mapping;
            default = [];
          };
        };
      }));
      default = {};
    };
  };

  config = mkIf (cfg.enable && cfg.specifications != {}) {
    system.activationScripts.revive =
      stringAfter ["etc" "users" "groups"]
      ((concatStringsSep "\n" (mapAttrsToList (name: cfg: let
            seal = toString cfg.seal;
            user = cfg.user;
            group = cfg.group;
            mode = cfg.mode;
          in ''
            echo Setup seal for ${name}
            mkdir -p ${seal}
            ${coreutils}/bin/chmod ${mode} ${seal}
            ${coreutils}/bin/chown ${user}:${group} ${seal}
          '')
          specs))
        + (concatMapStringsSep "\n" (pair: let
            inherit (pair) runUser runGroup user type group mode src dst;
            run = "${util-linux}/bin/runuser -u ${runUser} -g ${runGroup} --";
          in ''
            echo Reviving ${dst} from ${
              if pair ? src
              then src
              else "no where"
            }
            ${
              if type == "scroll"
              then ''
                ${run} mkdir -p '${dirOf src}'
                ${run} touch '${src}'
              ''
              else ''
                ${run} mkdir -p '${src}'
              ''
            }
            ${coreutils}/bin/chown ${user}:${group} '${src}'
            ${
              if type == "scroll"
              then ''
                ${run} mkdir -p '${dirOf dst}'
                ${run} touch '${dst}'
              ''
              else ''
                ${run} mkdir -p '${dst}'
              ''
            }
            ${util-linux}/bin/mountpoint -q '${dst}' && ${util-linux}/bin/umount '${dst}'
            ${util-linux}/bin/mountpoint -q '${dst}' || ${util-linux}/bin/mount --bind '${src}' '${dst}'
            ${coreutils}/bin/chmod ${mode} '${dst}'
            ${coreutils}/bin/chown ${user}:${group} '${dst}'
          '')
          pairs));
  };
}
