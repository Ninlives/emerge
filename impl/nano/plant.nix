{
  args,
  pkgs,
  config,
  ...
}: {
  system.build.plant = with pkgs; let
    ssh = "${openssh}/bin/ssh";
    nix = "${nixVersions.unstable}/bin/nix --extra-experimental-features 'nix-command flakes'";

    entry = args.fs.entry;
    boot = "${entry}/boot";
    hat = "${entry}/hat";
    pack = "${entry}/pack";
  in
    writeShellScript "plant" ''
      set -ex
      action=$1
      target="${args.target.user}@${args.target.host}"
      host="${args.target.host}"

      if [[ "$action" == "seed" ]];then
        ${ssh} "$target" "mkdir -m 777 -p '${boot}'"
        ${rsync}/bin/rsync -ravhP --chmod=a+w --progress "${config.system.build.kexecBoot}/" "$target":"${boot}"
        ${ssh} "$target" \
          "${boot}/busybox tar xzf '${boot}/kexec.tar.gz' -C '${boot}' && sudo ${boot}/run"

      elif [[ "$action" == "bud" ]];then
        key=$2
        echo "Reaching the target..."
        until [[ "$(${ssh} \
                    -o UserKnownHostsFile=/dev/null \
                    -o StrictHostKeyChecking=no \
                    -o ConnectTimeout=5 \
                    root@$host \
                    cat /etc/is_kexec)" == "true" ]];do
          echo "Not reachable, waiting..."
          sleep 2
        done

        ssh_(){
          ${ssh} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "root@$host" "$@"
        }
        export NIX_SSHOPTS='-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

        echo "Populating directories..."
        ssh_ "mkdir -p /mnt && \
              mount '${args.fs.device}' /mnt && \
              mkdir -p /mnt/${hat} /mnt/${pack}"

        echo "Uploading sops key..."
        ssh_ "umask 077;mkdir -p /mnt/${pack}/crux/sops;cat > /mnt/${pack}/crux/sops/age.key" < "$key"

        echo "Uploading system closure..."
        ${nix} copy --to "ssh://root@$host?remote-store=local?root=/mnt/${entry}" "${config.system.build.physeter}"

        ssh_ "mkdir -p /mnt/${entry}/nix/var/nix/profiles/hat && \
              nix-env --store /mnt/${entry} -p /mnt/${entry}/nix/var/nix/profiles/hat/physeter \
                      --set ${config.system.build.physeter}"

        ssh_ "physester-mv-link /mnt/${entry}/nix/var/nix/profiles/hat /mnt/${hat}"

      elif [[ "$action" == "grow" ]];then
        echo "Uploading system closure..."
        ${nix} copy --to "ssh://cloud@$host" "${config.system.build.physeter}"

        echo "Switching..."
        ${ssh} "cloud@$host" sudo nix-env -p /nix/var/nix/profiles/hat/physeter --set "${config.system.build.physeter}"
        ${ssh} "physester-mv-link /nix/var/nix/profiles/hat /hat"
      fi
    '';
}
