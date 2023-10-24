{
  fn,
  config,
  inputs,
  lib,
  self,
  ...
}:
with lib; {
  system.stateVersion = "23.05";
  time.timeZone = "Asia/Shanghai";

  documentation.enable = false;

  nix.settings.trusted-users = ["cloud"];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  systemd.services.sshd.preStart =
    mkAfter
    (flip concatMapStrings config.services.openssh.hostKeys (k: ''
      if [ -s "${k.path}.pub" ]; then
        ssh-keygen -s ${config.sops.secrets.sshca.path} -I ${config.networking.hostName} -h ${k.path}.pub
      fi
    ''));
  services.openssh.extraConfig = flip concatMapStrings config.services.openssh.hostKeys (k: ''
    HostCertificate ${k.path}-cert.pub
  '');

  users.mutableUsers = false;
  users.users.cloud = {
    uid = 1000;
    createHome = true;
    isNormalUser = true;
    extraGroups = ["wheel"];
    hashedPasswordFile = config.sops.secrets.hashed-password.path;
    openssh.authorizedKeys.keys = [inputs.values.secret.ssh.auth];
  };
  home-manager.extraSpecialArgs = { inherit fn inputs; };
  home-manager.users.cloud = {...}:{ imports = [ self.mod.impl.neko ]; };

  security.sudo.wheelNeedsPassword = false;

  sops.roles = ["institute"];
  sops.age.keyFile = "/pack/crux/sops/age.key";
  sops.age.sshKeyPaths = [];
  sops.gnupg.sshKeyPaths = [];
  sops.secrets.hashed-password.neededForUsers = true;
}
