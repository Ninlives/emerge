final: prev: {
  firefox-extra = {
    addons = with final; {
      tridactyl = callPackage ./tridactyl.nix {};
      bitwarden = callPackage ./bitwarden.nix {};
      ublock = callPackage ./ublock.nix {};
    };
    csshacks = final.fetchFromGitHub {
      owner = "MrOtherGuy";
      repo = "firefox-csshacks";
      rev = "b169686cc34df107929101fa345e5b7e3c2040f1";
      sha256 = "1vqgzpsj11vzgnwpkj2iw237p19r8ix25b1w899jkcjyrzk60qs5";
    };
  };
}
