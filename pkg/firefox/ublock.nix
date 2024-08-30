{
  stdenv,
  python3,
  zip,
  nodejs,
  fetchFromGitHub,
}: let
  assetsMain = fetchFromGitHub {
    name = "main";
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "b9e359aa08c1985a4512d1ba7a75f12db6f1b8a0";
    sha256 = "sha256-JoZgXbSoMIZm/pqLZT/gCz/PtpN8Y/hrSfUC1A01Jlk=";
  };

  assetsProd = fetchFromGitHub {
    name = "prod";
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "6d527a0910be91fe1db4052f7971722ee3d52a9a";
    sha256 = "sha256-XPP3nZZiSyjGWllvCcZ4PFAP28ToUaom/u5yeLvxGyQ=";
  };
in
  stdenv.mkDerivation {
    pname = "uBlock";
    version = "unstable-2024-08-12";

    src = fetchFromGitHub {
      owner = "gorhill";
      repo = "uBlock";
      rev = "9ced01ebf7f0c4a8961b572f5c14c2c3330f1131";
      sha256 = "1fif1jf73srlwmw2yw59c6k1vsinxiar8q62gg16k7p1gs0bxmv6";
    };

    nativeBuildInputs = [python3 zip];
    postPatch = ''
      mkdir -p dist/build/uAssets
      cp -r --no-preserve=all "${assetsMain}" dist/build/uAssets/main
      cp -r --no-preserve=all "${assetsProd}" dist/build/uAssets/prod
      patchShebangs .
    '';

    buildFlags = ["firefox"];

    installPhase = ''
      install -D -v -m644 dist/build/uBlock0.firefox.xpi $out/share/mozilla/extensions/uBlock.xpi
    '';
  }
