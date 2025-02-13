{
  pkgs,
  config,
  lib,
  inputs',
  ...
}:
let
  anPkgs = inputs'.parasyteOS.packages;
in
{
  boot.isContainer = true;
  environment.systemPackages = [
    pkgs.neofetch
    pkgs.tmux
    anPkgs.dive
  ];

  users.users.system = {
    isSystemUser = true;
    uid = 1000;
    group = "system";
  };
  users.groups.system.gid = 1000;
  users.users.${config.profile.user.name}.uid = lib.mkForce 1001;

  nixpkgs.overlays = [
    (final: prev: {
      mesa = prev.mesa.overrideAttrs (p: {
        mesonFlags =
          p.mesonFlags
          ++ [(lib.mesonOption "freedreno-kmds" "kgsl,msm")];
      });
    })
  ];
  hardware.graphics.enable = true;

  sops.age.keyFile = "/home/sops/age.key";
  sops.useTmpfs = true;
}
