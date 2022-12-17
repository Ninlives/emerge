{ pkgs, config, ... }: let
    freq = pkgs.writeShellScript "freq" ''
      if [[ "$1" == "powersave" ]]; then
        ${config.boot.kernelPackages.cpupower}/bin/cpupower frequency-set --governor powersave
      elif [[ "$1" == "performance" ]]; then
        ${config.boot.kernelPackages.cpupower}/bin/cpupower frequency-set --governor performance
      fi
    '';
  in {
  powerManagement.powertop.enable = true;
  systemd.services.powertop.wantedBy = [ "suspend.target" ];
  systemd.services.powertop.after = [ "suspend.target" ];

  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${freq} powersave"
    SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${freq} performance"
  '';
  systemd.services.freq-set = {
    wantedBy = [ "local-fs.target" "suspend.target" ];
    after = [ "local-fs.target" "suspend.target" "asusd.service" "graphical.target" ];

    description = "Frequency governor setting.";
    path = [ pkgs.kmod ];
    script = ''
      echo AC Power $(cat /sys/class/power_supply/AC0/online)
      if [[ $(cat /sys/class/power_supply/AC0/online) == "0" ]]; then
        echo Power Save
        ${freq} powersave
      else
        echo performance
        ${freq} performance
      fi
    '';
    serviceConfig.Type = "oneshot";
  };
}
