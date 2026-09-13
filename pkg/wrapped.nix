final: prev: let
  inherit (final) fakeFS;
in {
  nixMeta = final.nixVersions.latest;
  hledger-web = (builtins.getFlake "github:NixOS/nixpkgs/ee09932cedcef15aaf476f9343d1dea2cb77e261")
    .legacyPackages.${final.stdenv.hostPlatform.system}.hledger-web; # 1.50.2

  idea-community = fakeFS {
    drv = prev.jetbrains.idea-community;
    fakeHome = "$HOME/.local/fakefs/java";
  };
  android-studio = fakeFS {
    drv = final.androidStudioPackages.stable;
    fakeHome = "$HOME/.local/fakefs/android-studio";
  };
  zoom-us = fakeFS {drv = prev.zoom-us;};
  wechat-uos = fakeFS {drv = prev.wechat-uos;};

  feeluown = fakeFS {drv = final.re-export.feeluown;};
  thunderbird = fakeFS {drv = prev.thunderbird;};
}
