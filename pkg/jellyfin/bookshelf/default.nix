{
  buildDotnetModule,
  fetchFromGitHub,
  importYAML,
}:
buildDotnetModule rec {
  pname = "bookshelf";
  version = "unstable-2023-05-30";
  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-plugin-bookshelf";
    rev = "18e4e05d8c1d6afee9a6ec2617348cd4edf65d04";
    sha256 = "0qsjhlwb25bsyf4yzvj892gzji48c5gbjvny369q8j8hc34l3447";
  };
  nugetDeps = ./deps.nix;
  passthru.artifacts = (importYAML "${src}/build.yaml").artifacts;
}
