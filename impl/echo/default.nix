{
  fn,
  config,
  inputs,
  ...
}: let
  dp = inputs.values.secret;
in {
  imports =
    [
      ./nano.nix
      ./machine.nix
      ./restic.nix
      ./science.nix
      ./vaultwarden.nix
      ./vikunja.nix
      ./kavita.nix
      ./freshrss.nix
      ./misskey
      ./postgresql.nix
      ./matrix.nix
    ]
    ++ (fn.dotNixFrom ../taco);

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "${dp.email.private.address}";
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
  revive.specifications.system.scrolls = [
    {
      src = /Cache/machine-id;
      dst = /etc/machine-id;
    }
  ];

  networking.firewall.allowedTCPPorts = [80 443];
  networking.firewall.allowedUDPPorts = [443];
  services.nginx.enable = true;
}
