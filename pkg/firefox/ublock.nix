{ stdenv
, python3
, zip
, nodejs
, fetchFromGitHub
}:
let
  assetsMain = fetchFromGitHub {
    name = "main";
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "94a72ad81631e8d4c965c2ae607f8c394494b3d1";
    sha256 = "sha256-qBcixh2M82oRAXaPzbzilBVjpsi+SHku5oahhNwZsS4=";
  };

  assetsProd = fetchFromGitHub {
    name = "prod";
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "4e8ab43f052b352411b06f6b9a03e3c0280c23eb";
    sha256 = "sha256-IVeyPZBzlqCR1ueXyvUodBP/aqg54zIqlZkEirFgjIs=";
  };
in
stdenv.mkDerivation {
  pname = "uBlock";
  version = "unstable-2023-08-10";

  src = fetchFromGitHub {
    owner = "gorhill";
    repo = "uBlock";
    rev = "5ec0550581f0bdf9b4f41fbf8b0c4bb6ca521ad5";
    sha256 = "0lsmkyyxjdjwq67nfyn0ikpygqkpi28zs8x9cxv6csfzpadyqlxz";
  };

  nativeBuildInputs = [ python3 zip ];
  postPatch = ''
    mkdir -p dist/build/uAssets
    cp -r --no-preserve=all "${assetsMain}" dist/build/uAssets/main
    cp -r --no-preserve=all "${assetsProd}" dist/build/uAssets/prod
    patchShebangs .
  '';

  buildFlags = [ "firefox" ];

  installPhase = ''
    install -D -v -m644 dist/build/uBlock0.firefox.xpi $out/share/mozilla/extensions/uBlock.xpi
  '';
}
