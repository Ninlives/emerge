{ config, ... }: {
  services.vikunja = {
    enable = true;
    frontendScheme = "https";
    frontendHostname = "t.jojosprite.top";
    settings = {
      timezone = "PRC";
    };
  };

  services.nginx.virtualHosts.${config.services.vikunja.frontendHostname} = {
    forceSSL = true;
    enableACME = true;
  };
}
