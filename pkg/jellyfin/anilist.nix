{ buildDotnetModule, fetchFromGitHub, fn }:
buildDotnetModule rec {
  pname = "anilist";
  version = "5.0.0.0";
  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-plugin-anilist";
    rev = "e222c3b6e551265d5eeccd0bc10170d562f5bb9a";
    sha256 = "10c4cgr0xzl37ia4gbj4hac6wadvlp0khr4i4yjc13ayz4kha4nk";
  };
  nugetDeps = ./anilist-deps.nix;
  passthru.artifacts = (fn.importYAML "${src}/build.yaml").artifacts;
}
