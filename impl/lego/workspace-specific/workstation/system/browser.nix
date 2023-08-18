{ config, inputs, ... }:
let dp = inputs.values.secret;
in {
  programs.firefox.policies = {
    DisableFirefoxAccounts = true;
    Authentication = {
      SPNEGO = [ ".${dp.workstation.host}" ];
      Delegated = [ "*.${dp.workstation.host}" ];
    };
  };
  krb5 = {
    enable = true;
    libdefaults = {
      default_realm = dp.workstation.realm;
      dns_lookup_realm = false;
      ticket_lifetime = "24h";
      renew_lifetime = "7d";
      forwardable = true;
      rdns = false;
    };
  };
  home-manager.users.${config.workspace.user.name} = { ... }: {
    home.file.".mozilla/firefox/zero/user.js".text =
      config.lib.firefox.mkUserJs { "network.proxy.type" = 4; };
  };
}
