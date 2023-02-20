{ pkgs, lib, ... }: {
  d-mail.match-touchscreen-accurately = alpha-world-line:
    let
      xcnf =
        alpha-world-line.config.environment.etc."X11/xorg.conf.d/90-jovian.conf".text;
      patched-xcnf = builtins.readFile (pkgs.runCommandLocal "patch" {
        passAsFile = [ "xcnf" ];
        inherit xcnf;
      } ''
        cat $xcnfPath > $out
        sed -i '/Identifier "Steam Deck main display touch screen"/a MatchProduct "FTS3528:00 2808:1015"' $out
      '');
    in {
      environment.etc."X11/xorg.conf.d/90-jovian.conf".text = lib.mkForce patched-xcnf;
    };
}
