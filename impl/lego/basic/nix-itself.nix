{
  pkgs,
  self,
  config,
  lib,
  ...
}: {
  nix.nixPath = ["nixpkgs=${toString pkgs.path}"];
  nix.package = pkgs.nixVersions.unstable;

  nix.settings.sandbox = true;
  nix.settings.keep-going = true;
  nix.settings.trusted-users = [config.profile.user.name];
  nix.settings.substituters = lib.mkForce [
    "https://c.lackof.buzz"
    "https://emerge.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "emerge.cachix.org-1:Zvw8m0TXudK0MtylBFvUZCUEHlOfTgfvE2bbIexGhVw="
  ];
  nix.settings.auto-optimise-store = true;
  nix.settings.system-features = ["benchmark" "big-parallel" "kvm" "nixos-test" "recursive-nix"];
  nix.settings.experimental-features = ["recursive-nix" "flakes" "nix-command"];
  nix.settings.flake-registry =
    pkgs.writeText "flake-empty.json"
    (builtins.toJSON {
      flakes = [];
      version = 2;
    });
  nix.settings.narinfo-cache-negative-ttl = 86400;

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