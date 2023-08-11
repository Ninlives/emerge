{ buildNpmPackage
, fetchFromGitHub
, python3
}:
buildNpmPackage rec {
  pname = "bitwarden";
  version = "unstable";
  src = fetchFromGitHub {
    owner = "bitwarden";
    repo = "clients";
    rev = "a7cce1a3ad89bfa1f12b08aa69358ae10a4e7b6b";
    sha256 = "1fn68mfh8j7x38b8d3g1r37p754m5vmxysdxwydwgxih3gxkklh6";
  };
  npmDepsHash = "sha256-BQBUmQsxtEM72Q9qWCS/4i+Tzp3V9jT30urhuMuUE0M=";
  npmWorkspace = "apps/browser";
  makeCacheWritable = true;

  nativeBuildInputs = [ python3 ];
  npmBuildScript = "dist:firefox";
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  installPhase = ''
    install -v -D -m644 apps/browser/dist/*.zip $out/share/mozilla/extensions/${pname}.xpi
  '';
}
