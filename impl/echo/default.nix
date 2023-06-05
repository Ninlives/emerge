{ config, fn, ... }:
let dp = config.secrets.decrypted;
in {
  imports = [
    ./nano.nix
    ./machine.nix
    ./restic.nix
    ./science.nix
    ./tunnel.nix
    ./vaultwarden.nix
    ./vikunja.nix
    ./kavita.nix
    ./jellyfin.nix
    ./freshrss.nix
  ] ++ (fn.dotNixFrom ../taco);

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "${dp.email}";
  security.acme.defaults.renewInterval = "weekly";
  users.users.acme.uid = 999;
  users.groups.acme.gid = 999;
  revive.specifications.system.boxes = [
    {
      src = /Cache/acme;
      dst = /var/lib/acme;
      user = config.users.users.acme.name;
      group = config.users.groups.acme.name;
    }
    {
      src = /Cache/log;
      dst = /var/log;
    }
  ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 443 ];
  services.nginx.enable = true;
}
