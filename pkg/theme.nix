final: prev: {
  gruvbox-plus-icon-pack = with final; let
    variant = "Gruvbox-Plus-Dark";
    iconDir = "$out/share/icons/${variant}";
  in
    stdenvNoCC.mkDerivation rec {
      pname = "gruvbox-plus-icon-pack";
      version = "unstable-2023-07-17";

      src = fetchFromGitHub {
        owner = "SylEleuth";
        repo = pname;
        rev = "4eb713e4dd227a12307ab36c1737cbcc04ae3915";
        sha256 = "0lw8ry5hvrkan51xrcrix0vx5h962gnv6vr49ggwmm22b0g2s3gk";
      };

      nativeBuildInputs = [gtk3];
      propagatedBuildInputs = [breeze-icons gnome-icon-theme hicolor-icon-theme];

      installPhase = ''
        cd ${variant}
        mkdir -p ${iconDir}
        rm icon-theme.cache
        # name contains space breaks cache generation
        find|grep ' '|while read broken;do
          mv "$broken" "''${broken// /_}"
        done
        cp -r * ${iconDir}
        gtk-update-icon-cache ${iconDir}
      '';

      dontDropIconThemeCache = true;
    };
}
