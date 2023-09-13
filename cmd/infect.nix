{
  fn,
  self,
  ...
}: {
  perSystem = {pkgs, ...}: {
    apps.infect = fn.mkApp {
      drv = let
        nix = "${pkgs.nix}/bin/nix";
      in
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
  };
}
