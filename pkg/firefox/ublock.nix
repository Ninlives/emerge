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
    rev = "83c1bc2e8758da8dc0c183a46d8440f3471ff7cf";
    sha256 = "05p5fr7h0sf5w77gx49jwqrrfafs63y5465i98iq2chv4cwj2cdd";
  };

  assetsProd = fetchFromGitHub {
    name = "prod";
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "e66de4a73d733b15fc708691b314e2bc926287d1";
    sha256 = "sha256-U+d+H5o7I/msjBER7kJgE7PHDkqOt8b5yuzZaFRF37g=";
  };
in
  stdenv.mkDerivation {
    pname = "uBlock";
    version = "unstable-2026-01-03";

    src = fetchFromGitHub {
      owner = "gorhill";
      repo = "uBlock";
      rev = "b9833670211d83e72c3a855984a3d544945de1e3";
      sha256 = "sha256-aCDR/v0yE5m3IVYCyIzcGguuS95Er7rEWB3Xmwt2aZo=";
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
