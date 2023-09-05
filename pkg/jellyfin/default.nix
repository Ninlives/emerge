final: prev: {
  jellyfinPlugins = {
    anilist = final.callPackage ./anilist {};
    bookshelf = final.callPackage ./bookshelf {};
  };
}
