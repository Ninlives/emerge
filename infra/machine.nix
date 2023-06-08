{ config, lib, ... }:
with lib;
let
  inherit (config) ref;
  inherit (config.resource.shell_script) init-system;
  dp = config.secrets.decrypted;
  system-path = init-system "output.system-path";
  system-url = init-system "output.system-url";
  ipxe-url = config.resource.shell_script.netboot "output.ipxe-url";
in {
  provider.vultr.api_key = ref.local.secrets.api-key.vultr;
  provider.cloudflare.api_token = ref.local.secrets.api-key.cloudflare.key;
  resource.vultr_startup_script.install = {
    name = "install";
    type = "pxe";
    script = ''
      ''${base64encode(<<EOT
      #!ipxe
      set cmdline systempath=${system-path} systemurl=${system-url}
      chain ${ipxe-url}
      EOT
      )}'';
  };
  resource.vultr_instance.server = {
    region = "nrt";
    plan = "vc2-1c-2gb";
    os_id = 159;
    user_data = ''
      {
        "api-key": "${ref.local.secrets.api-key.vultr}",
        "age-key": "${ref.local.secrets.server-age-key}",
        "restic-passwd": "${ref.local.secrets.restic-password}",
        "b2-id": "${
          config.resource.b2_application_key.chest "application_key_id"
        }",
        "b2-key": "${
          config.resource.b2_application_key.chest "application_key"
        }"
      } 
    '';
    script_id = config.resource.vultr_startup_script.install "id";
    lifecycle.ignore_changes = [
      "user_data"
    ];
  };
  resource.vultr_dns_domain.main = {
    domain = dp.ptr;
    ip = config.resource.vultr_instance.server "main_ip";
  };
  resource.cloudflare_zone.main = {
    account_id = ref.local.secrets.api-key.cloudflare.account;
    zone = dp.host;
    jump_start = false;
    plan = "free";
    type = "full";
  };
  resource.cloudflare_record = mapAttrs (name: value: {
    zone_id = config.resource.cloudflare_zone.main "id";
    name = value.subdomain;
    value = config.resource.vultr_instance.server "main_ip";
    type = "A";
    ttl  = 1;
    proxied = true;
  }) (filterAttrs (_: v: v ? subdomain) dp);
  resource.cloudflare_page_rule.acme = {
    zone_id = config.resource.cloudflare_zone.main "id";
    target   = "*.${dp.host}/.well-known/acme-challenge/*";
    priority = 1;
    actions = {
      automatic_https_rewrites = "off";
      ssl                      = "off";
    };
  };
  output.cloudflare_nameservers.value = config.resource.cloudflare_zone.main "name_servers";
}
