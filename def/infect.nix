{ fn, pkgs, self }:
with pkgs;
fn.mkApp {
  drv = let
    nix = "${pkgs.nix}/bin/nix";
  in writeShellScriptBin "infect" ''
    gen=$(\
      ${nix} build --no-link --print-out-paths \
        $(${nix} eval --raw '${self}#homeInfections.nemo' \
                      --apply 'f: (f "'$USER'" "'$HOME'").activationPackage.drvPath')^out\
    )
    ${gen}/activate
  '';
}
