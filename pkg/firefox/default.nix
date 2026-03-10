final: prev: {
  firefox-extra = {
    addons = with final;
      let
        pinned = (builtins.getFlake "github:NixOS/nixpkgs/6aa2bb6a818d12d4cf296f736263011611cf2610")
                  .legacyPackages.${final.stdenv.hostPlatform.system};
      in
    {
      tridactyl = callPackage ./tridactyl.nix {};
      bitwarden = pinned.callPackage ./bitwarden.nix {};
      ublock = callPackage ./ublock.nix {};
    };
    csshacks = final.fetchFromGitHub {
      owner = "MrOtherGuy";
      repo = "firefox-csshacks";
      rev = "ab752a5b27561e61587e54bec0126194794ae2ca";
      sha256 = "0ix37xkr4dp6fkmlw6541v5kdj1pd40wqq5yl5bcx6plxin2slqm";
    };
  };
}
