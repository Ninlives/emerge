{
  lib,
  pkgs,
  self,
  inputs,
  config,
  ...
}:
with lib; {
  profile.identity = "cloud";
  profile.user.name = "cloud";
  profile.user.uid = 1000;
  profile.disk.persist = "pack";

  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  # virtualisation.libvirtd.enable = true;
  # environment.systemPackages = [pkgs.virt-manager];

  system.stateVersion = "23.05";

  documentation.enable = false;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
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
  users.users.${config.profile.user.name}.openssh.authorizedKeys.keys = [inputs.values.secret.ssh.auth];

  home-manager.users.${config.profile.user.name} = {...}: {
    imports = [self.mod.impl.neko];
    programs = {
      git = {
        enable = true;
        userName = inputs.values.secret.email.opensource.name;
        userEmail = inputs.values.secret.email.opensource.address;
      };
    };
  };

  security.sudo.wheelNeedsPassword = false;

  sops.roles = ["institute"];
  sops.age.keyFile = "/pack/Crux/Data/sops/age.key";
  sops.age.sshKeyPaths = [];
  sops.gnupg.sshKeyPaths = [];
  sops.secrets.hashed-password.neededForUsers = true;

  systemd.services.display-manager.enable = false;
  # services.xrdp.enable = true;
  # services.xrdp.defaultWindowManager = "${pkgs.gnome.gnome-session}/bin/gnome-session";
  # services.xrdp.openFirewall = true;

  boot.supportedFilesystems.vfat = true;

  networking.firewall.allowedTCPPortRanges = [
    {
      from = 5900;
      to = 9900;
    }
  ];
  virtualisation.podman.enable = true;

  services.nix-serve = {
    enable = true;
    openFirewall = true;
    secretKeyFile = config.sops.secrets."cache/private-key".path;
  };
}
