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
    version = "unstable-2022-07-20";
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
    version = "unstable-2023-07-07";
    src = fetchFromGitHub {
      owner = "tiagofumo";
      repo = "vim-nerdtree-syntax-highlight";
      rev = "35e70334a2ff6e89b82a145d1ac889e82d1ddb4e";
      sha256 = "0rkr3w7mcc7ha5g6m4lg0ik52v10hrx1mn2ahxnvb30h0isdyzb8";
    };
  };
}
