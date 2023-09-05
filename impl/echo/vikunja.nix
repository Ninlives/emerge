{
  config,
  inputs,
  ...
}: let
  dp = inputs.values.secret;
  plh = config.sops.placeholder;
  tpl = config.sops.templates;
in {
  services.vikunja = {
    enable = true;
    frontendScheme = "https";
    frontendHostname = "${dp.host.private.services.vikunja.fqdn}";
    settings = {
      timezone = "PRC";
      # mailer = {
      #   enabled = false;
      #   host = dp.mail-server.host;
      #   port = 587;
      #   fromemail = "vikunja@${dp.mail-server.domain}";
      # };
    };
    environmentFiles = [tpl.vikunja.path];
  };

  sops.templates.vikunja.content = ''
    VIKUNJA_MAILER_USERNAME='${plh."vikunja/smtp-username"}'
    VIKUNJA_MAILER_PASSWORD='${plh."vikunja/smtp-password"}'
  '';

  services.nginx.virtualHosts.${config.services.vikunja.frontendHostname} = {
    forceSSL = true;
    enableACME = true;
  };

  revive.specifications.system.boxes = [
    {
      src = /Services/vikunja;
      dst = /var/lib/private/vikunja;
    }
  ];
}
