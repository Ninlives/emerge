{ ... }:
final: prev: {
  gruvbox-plus-icon-pack = with final;
    let
      iconDir = "$out/share/icons/GruvboxPlus";
    in
    stdenvNoCC.mkDerivation rec {
      pname = "gruvbox-plus-icon-pack";
      version = "unstable-2023-04-13";

      src = fetchFromGitHub {
        owner = "SylEleuth";
        repo = pname;
        rev = "4f5382f0073eaba7829e19ed3feb438b5d73c747";
        sha256 = "07svbaa1h5hxx1krlkd968w2006najazx7x873rmakrbgrh3rvmn";
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
