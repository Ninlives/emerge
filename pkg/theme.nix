{ ... }:
final: prev: {
  gruvbox-plus-icon-pack = with final;
    let
      iconDir = "$out/share/icons/GruvboxPlus";
    in
    stdenvNoCC.mkDerivation rec {
      pname = "gruvbox-plus-icon-pack";
      version = "unstable-2023-05-22";

      src = fetchFromGitHub {
        owner = "SylEleuth";
        repo = pname;
        rev = "52c19def06bc78b5c5823f3261368e0b366230a5";
        sha256 = "0ykkysh6i08lz8jah7q0kd6zqxbif3wqwn5262959p7gyiks5x76";
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
