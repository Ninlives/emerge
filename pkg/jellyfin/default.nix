{ fn, ... }:
final: prev: {
  jellyfinPlugins = {
    anilist = final.callPackage ./anilist.nix { inherit fn; };
  };
}
