{ config, ... }:
let dp = config.secrets.decrypted;
in {
  programs.chromium.extraOpts = {
    AuthServerAllowlist = "*.${dp.workstation.host}";
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
}
