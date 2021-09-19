{ ... }@inputs:
with inputs;
with nixpkgs.lib;
with out-of-world; {
  nixosConfigurations.mlatus = mkNixOS [
    dirs.world.top-level
    dirs.secrets
    sops-nix.nixosModules.sops

    ({ config, ... }: {
      sops.encryptedSSHKeyPaths = [ "/var/lib/sops/local" ];
      system.activationScripts.pre-sops.deps =
        mkIf config.revive.enable [ "revive" ];
      users.users.${constant.user.name}.extraGroups =
        [ config.users.groups.keys.name ];

      home-manager.users.${constant.user.name} = import dirs.home.top-level;
    })
  ];

  nixosConfigurations.wsl = mkNixOS [
    dirs.world.wsl
    ({ config, ... }: {
      home-manager.users.${constant.user.name} = import dirs.home.wsl;
    })
  ];

  nixosConfigurations.cyber = nixpkgs.lib.nixosSystem {
    inherit system specialArgs;
    modules = [
      dirs.cyber.top-level
      dirs.secrets
      (dirs.world.option + /secrets.nix)
      sops-nix.nixosModules.sops
      external.nixosModules.nixos-cn
      ({ ... }: { sops.sshKeyPaths = [ "/var/lib/sops/key" ]; })
    ];
  };
}
