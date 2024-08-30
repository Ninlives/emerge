{
  buildNpmPackage,
  fetchFromGitHub,
  python3,
}:
buildNpmPackage rec {
  pname = "bitwarden";
  version = "unstable-2024-08-15";
  src = fetchFromGitHub {
    owner = "bitwarden";
    repo = "clients";
    rev = "92f87dad9a81362b57cde2ede98afbf80556f75b";
    sha256 = "1fxkjs1vfh2r17phnz7pxyd0jis6lfnpscn9c25allxam6phady6";
  };
  npmDepsHash = "sha256-u1Jct5R7cUGEDoQmkel1Noeq1SJDi/LfxyVMfpRle90=";
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
