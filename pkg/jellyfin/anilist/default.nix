{
  buildDotnetModule,
  fetchFromGitHub,
  importYAML,
}:
buildDotnetModule rec {
  pname = "anilist";
  version = "unstable-2023-01-19";
  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-plugin-anilist";
    rev = "8c18a1359991ab946b87d415b0a317ffe3a865ef";
    sha256 = "19y8xzpabyzk94d3x98d5kbndrhzgb6yzf3qr3pl7jwam1krazwz";
  };
  nugetDeps = ./deps.nix;
  passthru.artifacts = (importYAML "${src}/build.yaml").artifacts;
}
