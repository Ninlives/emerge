{ var, pkgs, self, config, ... }: {
  nix.nixPath = [ "nixpkgs=${pkgs.path}" ];
  nix.package = pkgs.nixVersions.unstable;

  nix.settings.sandbox = true;
  nix.settings.keep-going = true;
  nix.settings.trusted-users = [ config.workspace.user.name ];
  nix.settings.substituters = [
    "https://mirror.sjtu.edu.cn/nix-channels/store?priority=0"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=5"
    "https://nixos-cn.cachix.org"
    "https://emerge.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "nixos-cn.cachix.org-1:L0jEaL6w7kwQOPlLoCR3ADx+E3Q8SEFEcB9Jaibl0Xg="
    "emerge.cachix.org-1:Zvw8m0TXudK0MtylBFvUZCUEHlOfTgfvE2bbIexGhVw="
  ];
  nix.settings.auto-optimise-store = true;
  nix.settings.system-features =
    [ "benchmark" "big-parallel" "kvm" "nixos-test" "recursive-nix" ];
  nix.settings.experimental-features =
    [ "recursive-nix" "flakes" "nix-command" ];
  nix.settings.flake-registry = pkgs.writeText "flake-empty.json"
    (builtins.toJSON {
      flakes = [ ];
      version = 2;
    });

  nix.registry = {
    self.flake = self;
    emerge.to = {
      type = "git";
      url = "file://${config.workspace.user.home}/Emerge";
    };
  };

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "emerge" ''
      app=$1
      shift
      nix run emerge#$app -- $@
    '')
  ];

  nixpkgs.config.allowUnfree = true;
}
