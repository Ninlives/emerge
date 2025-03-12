final: prev: {
  gruvbox-plus-icon-pack = with final; let
    variant = "Gruvbox-Plus-Dark";
    iconDir = "$out/share/icons/${variant}";
  in
    stdenvNoCC.mkDerivation rec {
      pname = "gruvbox-plus-icon-pack";
      version = "unstable-2025-01";

      src = fetchFromGitHub {
        owner = "SylEleuth";
        repo = pname;
        rev = "d41c375cc8d3f6c92a8b6de3bc33edb041935881";
        sha256 = "sha256-Qqrwi7JNnFQZKTtFeE6icRVQ4du1faPqHUAO50c0mGk=";
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
    };
}
