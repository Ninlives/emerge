final: prev: {
  gruvbox-plus-icon-pack = with final; let
    variant = "Gruvbox-Plus-Dark";
    iconDir = "$out/share/icons/${variant}";
  in
    stdenvNoCC.mkDerivation rec {
      pname = "gruvbox-plus-icon-pack";
      version = "unstable-2025-08-06";

      src = fetchFromGitHub {
        owner = "SylEleuth";
        repo = pname;
        rev = "55eeb97f7040d1d561975e9f04c0d45344eb03b6";
        sha256 = "1ahii3lwmd044ihpiiyljk3vl9ssdgdw2fmn2sxia16mq46vazdr";
      };

      nativeBuildInputs = [gtk3];
      propagatedBuildInputs = [libsForQt5.breeze-icons gnome-icon-theme hicolor-icon-theme];

      installPhase = ''
        cd ${variant}
        mkdir -p ${iconDir}
        rm icon-theme.cache
        cp -r * ${iconDir}
        gtk-update-icon-cache ${iconDir}
      '';

      dontDropIconThemeCache = true;
      dontCheckForBrokenSymlinks = true;
    };
}
