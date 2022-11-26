data "sops_file" "secrets" {
  source_file = "${path.module}/../bombe/data/server/infra.yaml"
}

locals {
  secrets = yamldecode(data.sops_file.secrets.raw)
}
