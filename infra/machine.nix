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
    region = "cdg";
    plan = "vc2-1c-2gb";
    os_id = 159;
    user_data = ''
      {
        "age-key": "${ref.local.secrets.server-age-key}",
        "restic-passwd": "${ref.local.secrets.restic-passwd}",
        "b2-id": "${
          config.resource.b2_application_key.chest "application_key_id"
        }",
        "b2-key": "${
          config.resource.b2_application_key.chest "application_key"
        }"
      } 
    '';
    script_id = config.resource.vultr_startup_script.install "id";
  };
  resource.vultr_dns_domain.main = {
    domain = dp.host;
    ip = config.resource.vultr_instance.server "main_ip";
  };
  resource.vultr_dns_record = mapAttrs (name: value: {
    domain = config.resource.vultr_dns_domain.main "id";
    name = value.subdomain;
    data = config.resource.vultr_instance.server "main_ip";
    type = "A";
  }) (filterAttrs (_: v: v ? subdomain) dp);
}
