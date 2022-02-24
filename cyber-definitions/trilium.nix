{ config, ... }: {
  services.trilium-server = {
    enable = true;
    port = 24134;
    nginx = {
      enable = true;
      hostName = "n.jojosprite.top";
    };
  };
  services.nginx.virtualHosts.${config.services.trilium-server.nginx.hostName} = {
    forceSSL = true;
    enableACME = true;
  };
}
