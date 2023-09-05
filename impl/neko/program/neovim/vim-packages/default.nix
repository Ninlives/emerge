{
  runCommand,
  vimUtils,
  vimPlugins,
  haskell,
  lib,
  fetchFromGitHub,
}: let
  inherit (vimUtils) buildVimPluginFrom2Nix;
in {
  cmp-rime = buildVimPluginFrom2Nix {
    pname = "cmp-rime";
    version = "git";
    src = fetchFromGitHub {
      owner = "Ninlives";
      repo = "cmp-rime";
      rev = "2b1747b06efe237fa2cb39567dfc1a4b8eea4480";
      sha256 = "1m2w3v4r597x81ws6xn8v127928bw2v8x8h8f6ny064zrjlpzaxa";
    };
  };

  cmp-punc = buildVimPluginFrom2Nix {
    pname = "cmp-punc";
    version = "local";
    src = ./cmp-punc;
  };

  vibusen = buildVimPluginFrom2Nix {
    pname = "vibusen.vim";
    version = "unstable-2020-04-01";
    src = fetchFromGitHub {
      owner = "lsrdg";
      repo = "vibusen.vim";
      rev = "9d944ea023253d35351e672eb2742ddcf1445355";
      sha256 = "1n2s8b7kya8dnn1d5b0dc8yadl92iwf58s7sb5950b6yyi3i3q7f";
    };
  };

  mundo = buildVimPluginFrom2Nix {
    pname = "vim-mundo";
    version = "unstable-2022-11-05";
    src = fetchFromGitHub {
      owner = "simnalamburt";
      repo = "vim-mundo";
      rev = "b53d35fb5ca9923302b9ef29e618ab2db4cc675e";
      sha256 = "1dwrarcxrh8in78igm036lpvyww60c93vmmlk8h054i3v2p8vv59";
    };
  };

  nerdtree-syntax-highlight = buildVimPluginFrom2Nix {
    pname = "vim-nerdtree-syntax-highlight";
    version = "unstable-2021-01-11";
    src = fetchFromGitHub {
      owner = "tiagofumo";
      repo = "vim-nerdtree-syntax-highlight";
      rev = "5178ee4d7f4e7761187df30bb709f703d91df18a";
      sha256 = "0i690a9sd3a9193mdm150q5yx43mihpzkm0k5glllsmnwpngrq1a";
    };
  };
}
