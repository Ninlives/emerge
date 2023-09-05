{
  pkgs,
  config,
  ...
}: {
  boot.kernelPackages = pkgs.linuxPackages_latest;

  sops.age.keyFile = "${config.lib.path.persistent.static}/sops/age.key";
  sops.age.sshKeyPaths = [];
  sops.gnupg.sshKeyPaths = [];

  nix.settings.auto-optimise-store = true;

  users.mutableUsers = false;

  users.users.mlatus = {
    uid = 1000;
    createHome = true;
    isNormalUser = true;
    extraGroups = ["systemd-journal"];
    passwordFile = config.sops.secrets.hashed-password.path;
  };
  sops.secrets.hashed-password.neededForUsers = true;

  time.timeZone = "Asia/Shanghai";

  system.stateVersion = "22.11";
}
