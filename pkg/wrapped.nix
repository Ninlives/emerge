final: prev: let
  inherit (final) fakeFS;
in {
  nixMeta = final.nixVersions.latest;
  hledger-web = (builtins.getFlake "github:NixOS/nixpkgs/ebe4301cbd8f81c4f8d3244b3632338bbeb6d49c")
    .legacyPackages.${final.stdenv.hostPlatform.system}.hledger-web; # 1.32.3

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
