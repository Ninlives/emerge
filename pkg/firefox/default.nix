final: prev: {
  firefox-extra = {
    addons = with final;
      let
        pinned = (builtins.getFlake "github:NixOS/nixpkgs/d23fedd87fcd067b1d160323fae0d0e4f995527d")
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
