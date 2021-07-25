{ ... }@inputs:
with inputs; rec {
  inherit (nixpkgs.legacyPackages.${system}) pkgs;
  out-of-world = import ../out-of-world.nix {
    inherit (nixpkgs) lib;
    inherit constant;
  };
  constant = import ../constant.nix {
    inherit (nixpkgs) lib;
    inherit (nixpkgs.legacyPackages.${system}) pkgs;
  };
  system = "x86_64-linux";
  entry = "${constant.user.config.home}/Emerge";
  secrets = "${constant.user.config.home}/Secrets";
  sopsPGPKeyDirs =
    [ "${entry}/secrets/keys/users" "${entry}/secrets/keys/hosts" ];
  specialArgs = {
    inherit out-of-world constant system inputs;
    allSpecialArgs = specialArgs;
  };

  mergedOverlays = [
    external.overlay
    (final: prev: { re-export = external.legacyPackages.${system}.re-export; })
  ] ++ map import (out-of-world.function.dotNixFilesFrom ../../overlays);
  nixpkgsConfig = {
    allowUnfree = true;
    android_sdk.accept_license = true;
    allowUnsupportedSystem = true;
  };
}
