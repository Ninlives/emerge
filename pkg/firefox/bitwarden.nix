{
  buildNpmPackage,
  fetchFromGitHub,
  python3,
}:
buildNpmPackage rec {
  pname = "bitwarden";
  version = "unstable";
  src = fetchFromGitHub {
    owner = "bitwarden";
    repo = "clients";
    rev = "f9f85dcb39f768bd516521ffba8b2ff74e4a70ed";
    sha256 = "sha256-nCjcwe+7Riml/J0hAVv/t6/oHIDPhwFD5A3iQ/LNR5Y=";
  };
  npmDepsHash = "sha256-GJl9pVwFWEg9yku9IXLcu2XMJZz+ZoQOxCf1TrW715Y=";
  npmWorkspace = "apps/browser";
  makeCacheWritable = true;
  npmFlags = ["--legacy-peer-deps"];

  nativeBuildInputs = [python3];
  npmBuildScript = "dist:firefox";
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  installPhase = ''
    install -v -D -m644 apps/browser/dist/*.zip $out/share/mozilla/extensions/${pname}.xpi
  '';
}
