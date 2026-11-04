{ config, ... }: {
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."tailscale/desktop".path;
    extraUpFlags = ["--ssh"];
  };
  revive.specifications.system.boxes = [
    {
      src = /Programs/tailscale;
      dst = /var/lib/tailscale;
    }
  ];
}
