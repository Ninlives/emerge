{
  buildNpmPackage,
  fetchFromGitHub,
  python3,
}:
buildNpmPackage rec {
  pname = "bitwarden";
  version = "unstable-2026-01-02";
  src = fetchFromGitHub {
    owner = "bitwarden";
    repo = "clients";
    rev = "d9d8b4ba55809858dc3ce2d8b1ea512253abe678";
    sha256 = "sha256-i+hLslZ2i94r04vaOzx9e55AR8aXa9sSK8el+Dcp05A=";
  };
  npmDepsHash = "sha256-44444444444444444444444444aXa9sSK8el+Dcp05A=";
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
