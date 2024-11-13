{
  runCommand,
  vimUtils,
  vimPlugins,
  haskell,
  lib,
  fetchFromGitHub,
}: let
  inherit (vimUtils) buildVimPlugin;
in {
  cmp-rime = buildVimPlugin {
    pname = "cmp-rime";
    version = "unstable-2022-07-20";
    src = fetchFromGitHub {
      owner = "Ninlives";
      repo = "cmp-rime";
      rev = "2b1747b06efe237fa2cb39567dfc1a4b8eea4480";
      sha256 = "1m2w3v4r597x81ws6xn8v127928bw2v8x8h8f6ny064zrjlpzaxa";
    };
  };

  cmp-punc = buildVimPlugin {
    pname = "cmp-punc";
    version = "local";
    src = ./cmp-punc;
  };
}
