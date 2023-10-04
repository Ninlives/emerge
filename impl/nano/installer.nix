{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  # We are stateless, so just default to latest.
  system.stateVersion = config.system.nixos.version;

  # IPMI SOL console redirection stuff
  boot.kernelParams =
    ["console=tty0"]
    ++ (lib.optional (pkgs.stdenv.hostPlatform.isAarch32 || pkgs.stdenv.hostPlatform.isAarch64) "console=ttyAMA0,115200")
    ++ (lib.optional (pkgs.stdenv.hostPlatform.isRiscV) "console=ttySIF0,115200")
    ++ ["console=ttyS0,115200"];

  documentation.enable = false;
  # Not really needed. Saves a few bytes and the only service we are running is sshd, which we want to be reachable.
  networking.firewall.enable = false;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  users.users.root.openssh.authorizedKeys.keys = [inputs.values.secret.ssh.auth];
}
