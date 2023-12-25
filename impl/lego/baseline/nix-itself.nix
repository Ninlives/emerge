{
  pkgs,
  self,
  config,
  lib,
  ...
}: {
  nix.settings.substituters = lib.mkForce [
    "https://c.lackof.buzz"
    "https://emerge.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "emerge.cachix.org-1:Zvw8m0TXudK0MtylBFvUZCUEHlOfTgfvE2bbIexGhVw="
  ];

  nix.registry = {
    self.flake = self;
    emerge.to = {
      type = "git";
      url = "file://${config.profile.user.home}/Emerge";
    };
  };

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "emerge" ''
      app=$1
      shift
      nix run emerge#$app -- $@
    '')
  ];
}
