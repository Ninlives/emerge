{ config, inputs, ... }:
let
  dp = inputs.values.secret;
  hostname = dp.host.private.services.syncstorage.fqdn;
  plh = config.sops.placeholder;
  tpl = config.sops.templates;
in {
  services.firefox-syncserver = {
    enable = true;
    secrets = tpl.syncstorage.path;
    singleNode = {
      inherit hostname;
      enable = true;
      enableTLS = true;
      enableNginx = true;
      capacity = 10;
    };
    settings = {
      inherit (dp.host.private.services.syncstorage) port;
      syncstorage.enabled = true;
      tokenserver.enabled = true;
    };
  };

  sops.templates.syncstorage.content = ''
    SYNC_MASTER_SECRET=${plh."syncstorage/master-secret"}
    SYNC_TOKENSERVER__FXA_METRICS_HASH_SECRET=${plh."syncstorage/fxa-metrics-hash-secret"}
  '';
}
