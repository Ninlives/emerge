{
  fn,
  self,
  ...
}: {
  perSystem = {pkgs, ...}: let
        nix = "${pkgs.nix}/bin/nix";
  in {
    apps.infect = fn.mkApp {
      drv =
        with pkgs;
          writeShellScriptBin "infect" ''
            gen=$(\
              ${nix} build --no-link --print-out-paths \
                $(${nix} eval --raw '${self}#pathogen.ipomoea' \
                              --apply 'f: (f "'$USER'" "'$HOME'").activationPackage.drvPath')^out\
            )
            HOME_MANAGER_BACKUP_EXT=overridden_by_hm $gen/activate
          '';
    };
    apps.plant =
      fn.mkApp {
        drv = with pkgs; writeShellScriptBin "plant" ''
          set -ex
          user=$1
          host=$2
          device=$3
          type=$4
          entry=$5
          shift 5
          fn='f: (f {
            fs.device = "'$device'";
            fs.type = "'$type'";
            fs.entry = "'$entry'";
            target.user = "'$user'";
            target.host = "'$host'";
          }).config.system.build.plant.drvPath'
          plant=$(\
            ${nix} build --no-link --print-out-paths \
              $(${nix} eval --raw '${self}#pathogen.physeter' \
                            --apply "$fn")^out)

          $plant "$@"
        '';
      };
  };
}
