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
    hash = "sha256-yER9LDFwTQkOdjB84UhEiWUDE+5Qa2vlRzq1/Qc/soY=";
  };
  npmDepsHash = "sha256-hczwOG30ad5oaTU7APPrW+a7LmjPch+P4dZSb7B+2eU=";
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
