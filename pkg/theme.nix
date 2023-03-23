{ ... }:
final: prev: {
  gruvbox-plus-icon-pack = with final;
    let
      iconDir = "$out/share/icons/GruvboxPlus";
    in
    stdenvNoCC.mkDerivation rec {
      pname = "gruvbox-plus-icon-pack";
      version = "3.1";

      src = fetchFromGitHub {
        owner = "SylEleuth";
        repo = pname;
        rev = "b616f6fca3c15f61f3a5ddb819858e26965a967e";
        sha256 = "sha256-cqTC284yQok+I2WS38JHObVKYamK4Chmwbq2zSfhE4U=";
      };

      nativeBuildInputs = [ gtk3 ];
      propagatedBuildInputs = [ breeze-icons gnome-icon-theme hicolor-icon-theme ];

      installPhase = ''
        mkdir -p ${iconDir}
        rm README.md
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
