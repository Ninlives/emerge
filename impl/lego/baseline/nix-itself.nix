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
      nix_flags=()
      while [[ $# -gt 1 ]];do
        case $1 in
          --option)
            nix_flags+=("$1" "$2" "$3")
            shift 3
            ;;
          -*)
            nix_flags+=("$1")
            shift
            ;;
          *)
            break
            ;;
        esac
      done
      app=$1
      shift
      nix run "''${nix_flags[@]}" "emerge#$app" -- "$@"
    '')
  ];
}
