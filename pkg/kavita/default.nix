{ ... }:
final: prev: {
  kavita.server = final.callPackage ./server.nix {};
  kavita.ui = final.callPackage ./ui.nix {};
}
