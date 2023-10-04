{pkgs, ...}: let
  restore-network =
    pkgs.writers.writePython3 "restore-network" {flakeIgnore = ["E501"];}
    ./restore_routes.py;
in {
  systemd.network.enable = true;
  networking.dhcpcd.enable = false;

  boot.initrd.postMountCommands = ''
    mkdir -m 755 -p /mnt-root/root/network
    cp *.json /mnt-root/root/network/
  '';

  systemd.services.restore-network = {
    before = ["network-pre.target"];
    wants = ["network-pre.target"];
    wantedBy = ["multi-user.target"];
    script = ''
      while read opt; do
        if [[ $opt = restore_routes.main_ip=* ]]; then
          MAIN_IP="''${opt#restore_routes.main_ip=}"
        fi
      done <<< $(xargs -n1 -a /proc/cmdline)
      echo MAIN_IP=$MAIN_IP
      ${restore-network} /root/network/addrs.json /root/network/routes-v4.json /root/network/routes-v6.json /etc/systemd/network "$MAIN_IP"
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    unitConfig.ConditionPathExists = [
      "/root/network/addrs.json"
      "/root/network/routes-v4.json"
      "/root/network/routes-v6.json"
    ];
  };
}
