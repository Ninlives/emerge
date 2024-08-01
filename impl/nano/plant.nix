{
  self,
  args,
  pkgs,
  config,
  ...
}: {
  nixpkgs.overlays = self.overlays';
  system.build.plant = with pkgs; let
    ssh = "${openssh}/bin/ssh -t";
    nix = "${nixMeta}/bin/nix --extra-experimental-features 'nix-command flakes'";

    entry = args.fs.entry;
    hat = "${entry}/hat";
    pack = "${entry}/pack";

    directory = args.target.directory;
    boot = "${directory}/boot";

    target= "${args.target.user}@${args.target.host}";
    host= args.target.host;
  in
  {
    seed = writeShellScript "seed" ''
      set -ex
      ${ssh} "${target}" "mkdir -m 777 -p '${boot}'"
      ${rsync}/bin/rsync -ravhP --chmod=a+w --progress "${config.system.build.kexecBoot}/" "${target}":"${boot}"
      ${ssh} "${target}" \
        "${boot}/busybox tar xzf '${boot}/kexec.tar.gz' -C '${boot}' && sudo ${boot}/run"
    '';

    bud = writeShellScript "bud" ''
      set -ex
      key=$1
      echo "Reaching the target..."
      until [[ "$(${ssh} \
                  -o UserKnownHostsFile=/dev/null \
                  -o StrictHostKeyChecking=no \
                  -o ConnectTimeout=10 \
                  root@${host} \
                  cat /etc/is_kexec)" == "true" ]];do
        echo "Not reachable, waiting..."
        sleep 5
      done

      ssh_(){
        ${ssh} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "root@${host}" "$@"
      }
      export NIX_SSHOPTS='-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

      echo "Populating directories..."
      ssh_ "mkdir -p /mnt && \
            mount '${args.fs.device}' /mnt && \
            mkdir -p /mnt/${hat} /mnt/${pack}"

      echo "Uploading sops key..."
      ssh_ "umask 077;mkdir -p /mnt/${pack}/crux/sops;cat > /mnt/${pack}/crux/sops/age.key" < "$key"

      echo "Uploading system closure..."
      ${nix} copy --substitute-on-destination --to "ssh://root@${host}?remote-store=local?root=/mnt/${entry}" "${config.system.build.physeter.kexecHat}"
      ${nix} copy --substitute-on-destination --to "ssh://root@${host}?remote-store=local?root=/mnt/${entry}" "${config.system.build.physeter.kexecShoot}"

      ssh_ "mkdir -p /mnt/${entry}/nix/var/nix/profiles/hat && \
            nix-env --store /mnt/${entry} -p /mnt/${entry}/nix/var/nix/profiles/hat/physeter \
                    --set ${config.system.build.physeter.kexecHat} && \
            ${config.system.build.mvLink}/bin/mv-link /mnt/${entry}/nix/var/nix/profiles/hat /mnt/${hat} && \
            /mnt/${entry}/${config.system.build.physeter.kexecShoot}"
    '';

    grow = writeShellScript "grow" ''
      set -ex
      echo "Uploading system closure..."
      ${nix} copy --substitute-on-destination --to "ssh://cloud@${host}" "${config.system.build.physeter.kexecHat}"

      echo "Switching..."
      ${ssh} "cloud@${host}" "sudo nix-env -p /nix/var/nix/profiles/hat/physeter --set '${config.system.build.physeter.kexecHat}' && \
                            sudo ${config.system.build.mvLink}/bin/mv-link /nix/var/nix/profiles/hat /hat && \
                            sudo ${config.system.build.physeter.kexecHat}/smoke"
    '';

    harvest = writeShellScript "harvest" ''
      set -ex
      ${ssh} "${target}" "sudo ${directory}/hat/physeter/take"
    '';
  };
}
