{ lib, config, ... }: with lib; {
  boot.kernel.sysctl = {
    "net.ipv6.conf.ethernet.use_tempaddr" = 0;
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.ip_forward" = 1;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  systemd.services.sshd.preStart = mkAfter
    (flip concatMapStrings config.services.openssh.hostKeys (k: ''
      if [ -s "${k.path}.pub" ]; then
        ssh-keygen -s ${config.sops.secrets.sshca.path} -I ${config.networking.hostName} -h ${k.path}.pub
      fi
    ''));
  services.openssh.extraConfig =
    flip concatMapStrings config.services.openssh.hostKeys (k: ''
      HostCertificate ${k.path}-cert.pub
    '');

  users.users.root.openssh.authorizedKeys.keys =
    [ config.secrets.decrypted.ssh.auth ];
}
