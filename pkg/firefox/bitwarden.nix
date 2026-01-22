{
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  python3,
}:
buildNpmPackage rec {
  pname = "bitwarden";
  version = "v2025.12.1";
  src = fetchFromGitHub {
    owner = "bitwarden";
    repo = "clients";
    rev = "82470bdff16bb4f1e24035ccca9ed506e827c6d2";
    sha256 = "11111111111117phnz7pxyd0jis6lfnpscn9c25allxam6phady6";
  };
  npmDepsHash = "sha256-22222222222222222222222222RvSFOM2mtlrJ8E6fs=";
  npmWorkspace = "apps/browser";
  makeCacheWritable = true;
  npmFlags = ["--legacy-peer-deps"];

  # https://github.com/NixOS/nixpkgs/issues/474535
  nodejs = nodejs_22;

  nativeBuildInputs = [python3];
  npmBuildScript = "dist:firefox";
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  installPhase = ''
    install -v -D -m644 apps/browser/dist/*.zip $out/share/mozilla/extensions/${pname}.xpi
  '';
}
