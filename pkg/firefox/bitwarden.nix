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
    rev = "253a4e573c51d06d32303c21fcd1b7d2ea89d2f2";
    sha256 = "sha256-Xzo8dmpsSHqg8SLmh9mvcf1BAK6pPUlaUm3TjDlwS5E=";
  };
  npmDepsHash = "sha256-22222222222222222222222222RvSFOM2mtlrJ8E6fs=";
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
