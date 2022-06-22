{ config, lib, var, ... }: {
  sops.encryptedSSHKeyPaths = [ "/var/lib/sops/local" ];

  system.activationScripts.pre-sops.deps =
    lib.mkIf config.revive.enable [ "revive" ];

  users.users.${var.user.name}.extraGroups = [ config.users.groups.keys.name ];

  revive.specifications.system.boxes = [{
    src = /Data/sops;
    dst = /var/lib/sops;
  }];
}
