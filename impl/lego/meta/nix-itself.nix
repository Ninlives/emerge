{
  pkgs,
  config,
  ...
}: {
  nix.nixPath = ["nixpkgs=${toString pkgs.path}"];
  nix.package = pkgs.nixVersions.unstable;

  nix.settings.sandbox = true;
  nix.settings.keep-going = true;
  nix.settings.trusted-users = [config.profile.user.name];

  nix.settings.auto-optimise-store = true;
  nix.settings.system-features = ["benchmark" "big-parallel" "kvm" "nixos-test" "recursive-nix"];
  nix.settings.experimental-features = ["recursive-nix" "flakes" "nix-command" "configurable-impure-env"];
  nix.settings.flake-registry =
    pkgs.writeText "flake-empty.json"
    (builtins.toJSON {
      flakes = [];
      version = 2;
    });
  nix.settings.narinfo-cache-negative-ttl = 86400;
}
