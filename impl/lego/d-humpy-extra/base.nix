{
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  dp = inputs.values.secret;
in {
  zramSwap.enable = true;
  environment.sessionVariables = {
    WEBKIT_DISABLE_COMPOSITING_MODE=1;
    WEBKIT_DISABLE_DMABUF_RENDERER=1;
  };

  allowUnfreePackageNames = ["teams"];
  profile.identity = "institute";
  profile.user.name = dp.workstation.username;
  profile.disk.persist = "yurta";
  profile.proxy.default = "v2ray-fallback";

  sops.roles = ["work"];
  networking.hostName = dp.workstation.hostname;
  networking.timeServers = [ "corp.${inputs.values.secret.workstation.host}" ];
  networking.networkmanager.plugins = [pkgs.networkmanager-openconnect];

  nix.settings.substituters = lib.mkForce [
    "https://c.lackof.buzz"
  ];

  system.activationScripts.update-ca-certs = stringAfter ["etc"] ''
    mkdir -p /etc/ssl/ca-anchors
    cat /etc/ssl/certs/ca-certificates.crt > /etc/ssl/ca-anchors/ca-certificates.crt
    rm /etc/ssl/certs/ca-certificates.crt
    rm /etc/ssl/certs/ca-bundle.crt

    for cert in $(find /etc/ssl/ca-anchors -name '*.crt');do
      cat "$cert" >> /etc/ssl/certs/ca-certificates.crt
    done
    cp /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-bundle.crt
  '';

  revive.specifications.system.boxes = [
    {
      src = /Data/ca-anchors;
      dst = /etc/ssl/ca-anchors;
    }
  ];
}
