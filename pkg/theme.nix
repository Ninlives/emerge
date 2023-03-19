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
        rev = "0d35e18f91764b34fd78b10ef2eedd0e51d70be1";
        sha256 = "sha256-PhA3BwVIC5y9Xwibnqn/g9Fo4qr4a5dTWbzalC2LZPM=";
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
        # make onscreen keyboard happy
        find -name 'keyboard.svg'|xargs rm
        find -name 'keyboard-symbolic.svg'|xargs rm
        cp -r * ${iconDir}
        gtk-update-icon-cache ${iconDir}
      '';

      dontDropIconThemeCache = true;
    };
}
