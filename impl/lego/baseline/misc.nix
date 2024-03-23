{
  config,
  pkgs,
  lib,
  ...
}: {
  system.nixos.tags = [config.boot.kernelPackages.kernel.version];
  system.nixos.label = with lib;
    concatStringsSep "-" ([config.profile.identity]
      ++ (sort (x: y: x < y) config.system.nixos.tags));

  system.stateVersion = "22.05";
  boot.binfmt.emulatedSystems = ["aarch64-linux"];
}
