{
  config,
  inputs,
  pkgs,
  ...
}: let
  dp = inputs.values.secret;
  scrt = config.sops.secrets;
  bitwarden-cli-wrapper = with pkgs; let
    bw = "${pkgs.bitwarden-cli}/bin/bw";
  in
    writeShellApplication {
      name = "bw";
      runtimeInputs = [keyutils jq gnused pinentry-gnome3];
      text = ''
        need_reset=0
        if key_id=$(keyctl search @u user bw:session 2> /dev/null);then
            BW_SESSION=$(keyctl pipe "$key_id")
            export BW_SESSION
            if [[ $(${bw} status|jq -r '.["status"]') != "unlocked" ]];then
                keyctl revoke "$key_id"
                need_reset=1
            fi
        else
            need_reset=1
            if [[ $(${bw} status | jq -r '.["status"]') == "unauthenticated" ]];then
              BW_CLIENTID=$(cat '${scrt."vaultwarden/client-id".path}')
              BW_CLIENTSECRET=$(cat '${scrt."vaultwarden/client-secret".path}')
              export BW_CLIENTID
              export BW_CLIENTSECRET
              ${bw} config server 'https://${dp.host.private.services.vaultwarden.fqdn}' > /dev/null
              ${bw} login --apikey
            fi
        fi

        ask_password(){
        (cat <<EOC
        SETPROMPT Vaultwarden
        SETDESC Master Password:
        GETPIN
        EOC
        )| pinentry | sed -n 's/D \(.*\)/\1/p'
        }

        if [[ "$need_reset" == "1" ]];then
            password=$(ask_password)
            [[ -z "$password" ]] && exit 1
            session_key=$(echo "$password" | ${bw} unlock --raw 2> /dev/null)
            key_id=$(echo "$session_key" | keyctl padd user bw:session @s)
            keyctl link "$key_id" @u || true
            keyctl setperm "$key_id" 0x3f3f0000 || true
            BW_SESSION="$session_key"
            export BW_SESSION
        fi

        ${bw} "$@"
      '';
    };
in {
  nixpkgs.overlays = [(final: prev: {inherit bitwarden-cli-wrapper;})];
  sops.secrets."vaultwarden/client-id".owner = config.profile.user.name;
  sops.secrets."vaultwarden/client-secret".owner = config.profile.user.name;
}
