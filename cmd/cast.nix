{
  fn,
  self,
  ...
}: {
  perSystem = {
    inputs',
    pkgs,
    ...
  }: let
    terrasops = "${inputs'.terrasops.packages.default}/bin/terrasops";
    terra = pkgs.linkFarm "terra" {
      "config.tf.json" = self.terraformConfigurations.zero;
      ".terraform.lock.hcl" = ../infra/.terraform.lock.hcl;
    };
  in {
    apps.cast = fn.mkApp {
      drv = with pkgs;
        writeShellScriptBin "cast" ''
          set -e

          export SOPS_AGE_KEY_FILE=$HOME/Secrets/keys/infra/age.key
          export TF_LOG=DEBUG
          export TF_DATA_DIR=$HOME/Emerge/infra/.terraform

          ${terrasops} -rules $HOME/Emerge/.sops.yaml -state $HOME/Emerge/infra/tfstate.json &
          sleep 3
          TF_SOPS_PID=$(pidof ${terrasops})

          function cleanup(){
            ${coreutils}/bin/kill $TF_SOPS_PID
          }
          trap cleanup EXIT

          if [[ "$1" == "update" ]];then
            ln -s "${self.terraformConfigurations.zero}" config.tf.json
            ${opentofu}/bin/tofu init -upgrade
          else
            ${opentofu}/bin/tofu -chdir="${terra}" "$@"
          fi
        '';
    };
  };
}
