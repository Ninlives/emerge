{ ... }:
final: prev: {
  firefox-extra = {
    addons = with final; {
      tridactyl = callPackage ./tridactyl.nix { };
      bitwarden = callPackage ./bitwarden.nix { };
      ublock = callPackage ./ublock.nix { };
    };
    csshacks = final.fetchFromGitHub {
      owner = "MrOtherGuy";
      repo = "firefox-csshacks";
      rev = "05ad86ab51cc1550459d3cac6d8a8acc00bb4570";
      sha256 = "1cc5nqwm9858kzkk84f7f1qkvvmcqkh3dkrf6w9s34m54m5dn8ws";
    };
  };
}
