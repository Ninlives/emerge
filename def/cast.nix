{ fn, pkgs, self }:
with pkgs;
fn.mkApp {
  drv = let
    node = self.nixosConfigurations.echo.config;
    def = node.system.build.toplevel;
    key = "/var/lib/sops/key";
    dir = "/var/lib/sops";
    host = node.secrets.decrypted.v2ray.host;
  in writeShellScriptBin "upload" ''
    export PATH=${makeBinPath [ git openssh coreutils nix keyutils ]}
    set -e
    tmp=$(mktemp -d)
    chmod 700 "$tmp"
    reboot=0
    if [[ "$1" == "-r" ]];then
      reboot=1
      shift
    fi
    keyFile=$1
    shift
    key="$tmp/key"

    function cleanup() {
      set +e
      rm -rf "$tmp"
      while true;do
        echo 'Removing keyfile on server...'
        ssh root@${host} 'if [[ -e ${key} ]];then rm ${key};fi' \
        && break || (echo 'Failed, try again.'; sleep 1)
      done
    }
    trap cleanup EXIT

    function getpass(){
      if ! key_id=$(keyctl request user emerge:ssh_keypass @s 2> /dev/null);then
        echo -n 'Input passphrase: ' >&2
        read -s ssh_keypass
        echo "$ssh_keypass"|keyctl padd user emerge:ssh_keypass @s > /dev/null
        echo "$ssh_keypass"
      else
        echo $(keyctl pipe "$key_id")
      fi
    }

    clearpass(){
      if key_id=$(keyctl request user emerge:ssh_keypass @s 2> /dev/null);then
        keyctl revoke "$key_id"
      fi
    }

    cp "$keyFile" "$key"
    echo Decrypt Key File
    ssh-keygen -p -P "$(getpass)" -N "" -f "$key" || { clearpass; exit 1; }
    ssh root@${host} 'mkdir -p ${dir};if [[ -e ${key} ]];then rm ${key};fi'
    scp "$key" root@${host}:${key}
    rm "$key"
    nix copy -s --to ssh://root@${host} "${def}"

    if [[ $reboot -eq 1 ]];then
      ssh root@${host} ${def}/bin/switch-to-configuration boot
      ssh root@${host} reboot
    else
      ssh root@${host} ${def}/bin/switch-to-configuration switch
    fi
  '';
}
