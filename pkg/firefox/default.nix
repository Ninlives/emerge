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
      rev = "9a9dd88871104528422ada76ebb7e35ca3c2bc6b";
      sha256 = "0k4w38v4jaygqm3xzjnx469jh64m43pqb6s6dwpdcylx9nbm2hvv";
    };
  };
}
