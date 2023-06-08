{ fn, ... }:
final: prev: {
  jellyfinPlugins = {
    anilist = final.callPackage ./anilist { inherit fn; };
    bookshelf = final.callPackage ./bookshelf { inherit fn; };
  };
}
