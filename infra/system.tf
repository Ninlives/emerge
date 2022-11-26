provider "shell" {
  interpreter = [ "/usr/bin/env", "bash", "-c" ]
  enable_parallelism = true
}

resource "shell_script" "netboot" {
  lifecycle_commands {
    create = "${path.module}/scripts/netboot/create.sh"
    delete = "${path.module}/scripts/netboot/delete.sh"
  }
  sensitive_environment = {
    GITHUB_TOKEN = local.secrets.api-key.github
  }
}

resource "shell_script" "init-system" {
  lifecycle_commands {
    create = "${path.module}/scripts/init-system/create.sh"
    delete = "${path.module}/scripts/init-system/delete.sh"
  }
  environment = {
    SERVER_PUB = "age1s6hznqs4cukna8ernacyh29fx6znpucmplvt3udvd7xxexwymg3suz0x37"
  }
  sensitive_environment = {
    GITHUB_TOKEN = local.secrets.api-key.github
    SIGN_KEY     = local.secrets.sign-key
  }
}

data "shell_script" "system" {
  lifecycle_commands {
    read = <<-EOT
      jq --null-input \
        --arg path "$(nix eval --raw emerge#nixosConfigurations.echo.config.system.build.toplevel.outPath)" \
          '{ "path": $path }'
    EOT
  }
}

locals {
  system-path = data.shell_script.system.output["path"]
}

resource "shell_script" "switch" {
  lifecycle_commands {
    create = <<-EOT
      set -e
      if [[ "${local.system-path}" == "${shell_script.init-system.output.system-path}" ]];then
        echo Same as init, no need to switch
      else
        nix build --no-link emerge#nixosConfigurations.echo.config.system.build.toplevel
        nix copy --to ssh://root@${vultr_instance.server.main_ip} ${local.system-path}
        ssh root@${vultr_instance.server.main_ip} '${local.system-path}/bin/switch-to-configuration boot && reboot'
      fi
      echo '{ "path": "${local.system-path}" }'
    EOT
    delete = <<-EOT
      echo No-op for switch.
    EOT
  }
  triggers = {
    when_value_changed = local.system-path
  }
}
