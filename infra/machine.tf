provider "vultr" {
  api_key = local.secrets.api-key.vultr
}

locals {
  init-system = shell_script.init-system.output
}

resource "vultr_startup_script" "install" {
  name = "install"
  type = "pxe"
  script = base64encode(<<EOT
  #!ipxe
  set cmdline systempath=${local.init-system.system-path} systemurl=${local.init-system.system-url}
  chain ${shell_script.netboot.output.ipxe-url}
  EOT
  )
}

resource "vultr_instance" "server" {
  region    = "cdg"
  plan      = "vc2-1c-2gb"
  os_id     = 159
  user_data = <<-EOT
    {
      "age-key": "${local.secrets.server-age-key}",
      "restic-passwd": "${local.secrets.restic-passwd}",
      "b2-id": "${b2_application_key.chest.application_key_id}",
      "b2-key": "${b2_application_key.chest.application_key}"
    } 
  EOT
  script_id = vultr_startup_script.install.id
}

output "main_server_ip" {
  value = vultr_instance.server.main_ip
}

resource "vultr_dns_domain" "main" {
  domain = local.secrets.fqdn
  ip     = vultr_instance.server.main_ip
}

resource "vultr_dns_record" "vaultwarden" {
  domain = "${vultr_dns_domain.main.id}"
  name   = "w"
  data   = vultr_instance.server.main_ip
  type   = "A"
}

resource "vultr_dns_record" "vikunja" {
  domain = "${vultr_dns_domain.main.id}"
  name   = "t"
  data   = vultr_instance.server.main_ip
  type   = "A"
}

resource "vultr_dns_record" "libreddit" {
  domain = "${vultr_dns_domain.main.id}"
  name   = "r"
  data   = vultr_instance.server.main_ip
  type   = "A"
}

resource "vultr_dns_record" "wire" {
  domain = "${vultr_dns_domain.main.id}"
  name   = "d"
  data   = vultr_instance.server.main_ip
  type   = "A"
}

resource "vultr_dns_record" "immich" {
  domain = "${vultr_dns_domain.main.id}"
  name   = "i"
  data   = vultr_instance.server.main_ip
  type   = "A"
}
