{ ... }@inputs:
with inputs;
with nixpkgs.lib;
with out-of-world;
with pkgs;
let
  mkFilter = name: action:
    writeShellScriptBin name ''
      export PATH=${
        makeBinPath [ sops nixFlakes nixfmt coreutils findutils gawk gnupg ]
      }
      export sopsPGPKeyDirs='${toString sopsPGPKeyDirs}'
      source ${
        sops-nix.packages.${system}.sops-import-keys-hook
      }/nix-support/setup-hook
      ${action}
    '';
  sops-git-filter-clean = mkFilter "sops-git-filter-clean" ''
    # <<<sh>>>
    content=$(cat)
    sopsImportKeysHook && \
    (nix eval --json --expr "$content"|sops --input-type=json -e /dev/stdin|nix eval --expr "builtins.fromJSON '''""$(cat)""'''"|nixfmt) \
    || exit 1
    # >>>sh<<<
  '';
  sops-git-filter-smudge = mkFilter "sops-git-filter-smudge" ''
    # <<<sh>>>
    content=$(cat)
    encfile=$(mktemp --suffix ".json")
    sopsImportKeysHook && \
    (nix eval --json --expr "$content" > $encfile) && (sops --input-type=json -d $encfile|nix eval --expr "builtins.fromJSON '''""$(cat)""'''"|nixfmt) \
    || (echo $content|nixfmt)
    # >>>sh<<<
  '';
  sops-git-diff = writeShellScriptBin "sops-git-diff" ''
    export PATH=${makeBinPath [ nixFlakes nixfmt coreutils ]}
    # <<<sh>>>
    nix eval --json --expr "$(cat $1)"|nix eval --expr "builtins.fromJSON '''""$(cat)""'''"|nixfmt
    # >>>sh<<<
  '';
in {
  nixosConfigurations.mlatus = mkNixOS "local" [
    dirs.world.top-level
    dirs.secrets
    sops-nix.nixosModules.sops

    ({ config, ... }: {
      sops.encryptedSSHKeyPaths = [ "/chest/System/Data/sops/local" ];
      system.activationScripts.pre-sops.deps =
        mkIf config.revive.enable [ "revive" ];
      users.users.${constant.user.name}.extraGroups =
        [ config.users.groups.keys.name ];

      home-manager.users.${constant.user.name} = import dirs.home.top-level;
    })
    {
      home-manager.users.${constant.user.name}.home.packages =
        [ sops-git-filter-clean sops-git-filter-smudge sops-git-diff ];
    }
  ];

  nixosConfigurations.cyber = nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = specialArgs // { profile = "server"; };
    modules = [
      dirs.cyber.top-level
      dirs.secrets
      (dirs.world.option + /secrets.nix)
      sops-nix.nixosModules.sops
      external.nixosModules.nixos-cn
      ({ ... }: { sops.gnupg.sshKeyPaths = [ "/var/lib/sops/key" ]; })
    ];
  };
}
