{ pkgs, lib, ... }: {
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };
  systemd.user.services.kdeconnect-indicator.Unit.PartOf = lib.mkForce [ ];
  systemd.user.services.kdeconnect-indicator.Unit.After =
    [ "graphical-session.target" ];
  systemd.user.services.kdeconnect-indicator.Service.ExecStartPre =
    "${pkgs.coreutils}/bin/sleep 20";
  nixosConfig.kdeconnect-ports = {
    networking.firewall.allowedTCPPorts = [ 22 ];
    networking.firewall.allowedTCPPortRanges = [{
      from = 1714;
      to = 1764;
    }];
    networking.firewall.allowedUDPPortRanges = [{
      from = 1714;
      to = 1764;
    }];
  };
  persistent.boxes = [
    {
      src = /Programs/kdeconnect/config/main;
      dst = ".config/kdeconnect";
    }
    {
      src = /Programs/kdeconnect/config/kde.org;
      dst = ".config/kde.org";
    }
    {
      src = /Programs/kdeconnect/data/kpeople;
      dst = ".local/share/kpeople";
    }
    {
      src = /Programs/kdeconnect/data/kpeoplevcard;
      dst = ".local/share/kpeoplevcard";
    }
  ];
}
