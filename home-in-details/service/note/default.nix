{ config, out-of-world, inputs, system, ... }:
let inherit (out-of-world.function) home;
in {
  imports = [ inputs.emanote.homeManagerModule ];
  services.emanote = {
    enable = true;
    notes = [ (home "Documents/Zettelkasten") ];
    package = inputs.emanote.defaultPackage.${system};
  };
}
