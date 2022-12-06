{ fn, var, self, pkgs, inputs }:
with pkgs;
let
  terrasops =
    "${inputs.terrasops.packages.${var.system}.default}/bin/terrasops";
  terra = linkFarm "terra" {
    "config.tf.json" = self.terraformConfigurations.zero;
    ".terraform.lock.hcl" = ../infra/.terraform.lock.hcl;
  };
in fn.mkApp {
  drv = writeShellScriptBin "cast" ''
    set -e

    export SOPS_AGE_KEY_FILE=${var.path.secrets}/keys/vultr/age.key 
    export TF_LOG=DEBUG
    export TF_DATA_DIR=${var.path.entry}/infra/.terraform

    ${terrasops} -rules ${var.path.entry}/.sops.yaml -state ${var.path.entry}/infra/tfstate.json &
    sleep 3
    TF_SOPS_PID=$(pidof ${terrasops})

    function cleanup(){
      ${coreutils}/bin/kill $TF_SOPS_PID
    }
    trap cleanup EXIT

    ${terraform}/bin/terraform -chdir="${terra}" "$@"
  '';
}
