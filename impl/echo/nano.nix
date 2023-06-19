{ lib, var, inputs, config, ... }:
with lib;
let
  inherit (config.lib.path) persistent;
  dp = inputs.values.secret;
  netboot-config = { config, pkgs, modulesPath, ... }: let
    build = config.system.build;
    kernelTarget = pkgs.stdenv.hostPlatform.linux-kernel.target;
  in {
    imports = [
      (modulesPath + "/profiles/minimal.nix")
      (modulesPath + "/profiles/qemu-guest.nix")
      (modulesPath + "/installer/netboot/netboot.nix")
    ];
    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      supportedFilesystems = [ "btrfs" ];
    };

    networking.useNetworkd = true;
    networking.firewall.enable = false;

    services = {
      udisks2.enable = false;
      getty.autologinUser = "root";
    };

    environment.systemPackages = with pkgs; [ age wget jq restic ];
    systemd.services.install-system = {
      wantedBy = [ "multi-user.target" ];
      path = [ "/run/current-system/sw" ];
      script = ''
        set -x
        set -e
        while read opt; do
          if [[ $opt = systemurl=* ]]; then
            SYSTEM_URL="''${opt#systemurl=}"
          fi
          if [[ $opt = systempath=* ]]; then
            SYSTEM_PATH="''${opt#systempath=}"
          fi
        done <<< $(xargs -n1 -a /proc/cmdline)
        sfdisk /dev/vda <<EOT
        label: gpt
        type="BIOS boot",        name="BOOT",  size=2M
        type="Linux filesystem", name="NIXOS", size=+
        EOT

        sleep 2

        NIXOS=/dev/disk/by-partlabel/NIXOS
        mkfs.btrfs --force $NIXOS
        mkdir -p /fsroot
        mount $NIXOS /fsroot

        btrfs subvol create /fsroot/boot
        btrfs subvol create /fsroot/nix
        btrfs subvol create /fsroot/${persistent.volume}
        btrfs subvol create /fsroot/tmp

        OPTS=compress-force=zstd,space_cache=v2
        mkdir -p /mnt/{boot,nix,${persistent.root}}
        mount -o subvol=boot,$OPTS  $NIXOS /mnt/boot
        mount -o subvol=nix,$OPTS   $NIXOS /mnt/nix
        mount -o subvol=${persistent.volume},$OPTS $NIXOS /mnt/${persistent.root}

        mkdir -p /tmp
        curl -s http://169.254.169.254/latest/user-data -o /tmp/sensitive-data.json
        INSTANCE_ID=$(curl -s http://169.254.169.254/v1/instance-v2-id)
        API_KEY=$(jq -r -e '.["api-key"]' /tmp/sensitive-data.json)
        curl -s "https://api.vultr.com/v2/instances/$INSTANCE_ID" \
          -X PATCH \
          -H "Authorization: Bearer $API_KEY" \
          -H "Content-Type: application/json" \
          --data '{ "user_data" : "SmFja3BvdCEK" }'

        function create_sensitive_file(){
          mkdir -p "$(dirname "$1")" 
          chmod 700 "$(dirname "$1")"
          touch "$1"
          chmod 600 "$1"
        }

        AGE_KEY=/mnt/${persistent.static}/sops/age.key
        create_sensitive_file "$AGE_KEY"
        jq -r -e '.["age-key"]' /tmp/sensitive-data.json > "$AGE_KEY"

        B2_ENV=/mnt/${persistent.static}/b2/env
        create_sensitive_file "$B2_ENV"
        cat > "$B2_ENV" <<EOF
        B2_ACCOUNT_ID="$(jq -r -e '.["b2-id"]' /tmp/sensitive-data.json)"
        B2_ACCOUNT_KEY="$(jq -r -e '.["b2-key"]' /tmp/sensitive-data.json)"
        EOF

        jq -r -e '.["restic-passwd"]' /tmp/sensitive-data.json > /tmp/restic-passwd
        source "$B2_ENV"
        export B2_ACCOUNT_ID
        export B2_ACCOUNT_KEY
        restic --password-file /tmp/restic-passwd -r b2:mlatus-chest:echo restore latest --target /mnt
        mkdir -p /mnt/${persistent.root}
        mv /mnt/${persistent.snapshot.root}/* /mnt/${persistent.root}
        rmdir /mnt/${persistent.snapshot.root}

        mkdir -p /mnt/${persistent.cache}/store
        wget "''${SYSTEM_URL}" -O /mnt/${persistent.cache}/system
        age --decrypt -i "$AGE_KEY" -o /mnt/${persistent.cache}/system.tar.gz /mnt/${persistent.cache}/system
        tar xvzf /mnt/${persistent.cache}/system.tar.gz -C /mnt/${persistent.cache}/store

        nixos-install --root /mnt --system "''${SYSTEM_PATH}" \
          --no-channel-copy --no-root-passwd \
          --option extra-substituters "file:///mnt/${persistent.cache}/store" \
          --option extra-trusted-public-keys "${dp.nix.store.pubkey}"

        reboot
      '';
    };

    system.build.netboot = pkgs.runCommand "netboot" { } ''
      mkdir -p $out
      ln -s ${build.kernel}/${kernelTarget}         $out/${kernelTarget}
      ln -s ${build.netbootRamdisk}/initrd          $out/initrd
      ln -s ${build.netbootIpxeScript}/netboot.ipxe $out/ipxe
    '';
    system.stateVersion = "22.05";
  };
in {
  options.nano = mkOption {
    type = types.package;
    default = (inputs.nixpkgs.lib.nixosSystem {
      inherit (var) system;
      modules = [ netboot-config ];
    }).config.system.build.netboot;
  };
}
