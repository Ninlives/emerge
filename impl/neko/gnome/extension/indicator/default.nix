{ pkgs, ... }:
let
  indicator = pkgs.runCommand "indicator" { } ''
    mkdir -p $out/share/gnome-shell/extensions
    cp -r --no-preserve=all ${./src} $out/share/gnome-shell/extensions/indicator@mlatus
    ${pkgs.glib.dev}/bin/glib-compile-schemas $out/share/gnome-shell/extensions/indicator@mlatus/schemas
  '';
in {
  home.packages = [ indicator ];
  dconf.settings."org/gnome/shell".enabled-extensions = [ "indicator@mlatus" ];
}
