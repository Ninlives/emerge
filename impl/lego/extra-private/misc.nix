{...}: {
  sops.roles = ["private"];
  services.smartdns.enable = true;
  networking.hostName = "nixos";
  networking.resolvconf.useLocalResolver = true;
}
