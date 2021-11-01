final: prev: {
  texmacs = let
    orig = final.path + /pkgs/applications/editors/texmacs;
    common = final.callPackage (orig + /common.nix) {
      tex = final.texlive.combined.scheme-full;
      extraFonts = true;
      chineseFonts = true;
      japaneseFonts = true;
      koreanFonts = true;
    };
  in with final;
  stdenv.mkDerivation {
    name = prev.texmacs.name;

    src = prev.texmacs.src;

    cmakeFlags = [ "-DTEXMACS_GUI=Qt4" ];

    enableParallelBuilding = true;

    nativeBuildInputs = [ cmake pkgconfig ];
    buildInputs = [
      guile_1_8
      qt4
      makeWrapper
      ghostscriptX
      freetype
      libjpeg
      sqlite
      git
      python3
    ];
    NIX_LDFLAGS = [ "-lz" ];

    postInstall = "wrapProgram $out/bin/texmacs --suffix PATH : ${
        lib.makeBinPath [
          ghostscriptX
          aspell
          texlive.combined.scheme-full
          git
          python3
          xorg.xmodmap
          which
        ]
      }";

    inherit (common) postPatch;
  };
}
