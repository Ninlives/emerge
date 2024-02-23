{
  pkgs,
  inputs,
  ...
}: let
  restore-network =
    pkgs.writers.writePython3 "restore-network" {flakeIgnore = ["E501"];}
    ./restore_routes.py;
in {
  systemd.network.enable = true;
  networking.useDHCP = false;

  boot.initrd.postMountCommands = ''
    mkdir -m 755 -p /mnt-root/root/network
    cp *.json /mnt-root/root/network/
  '';

  systemd.services.restore-network = {
    before = ["network-pre.target"];
    wants = ["network-pre.target"];
    wantedBy = ["multi-user.target"];
    script = ''
      ${restore-network} /root/network/addrs.json /root/network/routes-v4.json /root/network/routes-v6.json /etc/systemd/network
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

  networking.proxy.default = inputs.values.secret.proxy.institute;
  networking.proxy.noProxy = "127.0.0.1,localhost,${inputs.values.secret.workstation.host}";
}
