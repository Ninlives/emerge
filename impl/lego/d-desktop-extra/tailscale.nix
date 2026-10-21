{ config, ... }: {
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."tailscale/desktop".path;
    extraUpFlags = ["--ssh"];
  };
}
