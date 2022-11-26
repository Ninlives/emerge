{ ... }:
final: prev:
let inherit (final) fakeFS;
in {
  idea-community = fakeFS {
    drv = prev.jetbrains.idea-community;
    fakeHome = "$HOME/.local/fakefs/java";
  };
  android-studio = fakeFS {
    drv = final.androidStudioPackages.stable;
    fakeHome = "$HOME/.local/fakefs/android-studio";
  };
  zoom-us = fakeFS { drv = prev.zoom-us; };
  steam-wrapped = fakeFS {
    drv = prev.steam;
  };

  feeluown = fakeFS { drv = final.re-export.feeluown; };
  thunderbird = fakeFS { drv = prev.thunderbird; };
}
