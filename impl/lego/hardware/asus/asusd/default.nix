{ pkgs, config, ... }:
let asusctl = pkgs.callPackage ./asusctl.pkg.nix { systemd = config.systemd.package; };
in {
  nixpkgs.overlays = [(final: prev: { inherit asusctl; })];
  environment.systemPackages = [ asusctl ];
  systemd.services.asusd = {
    description = "ASUS Notebook Control";
    wantedBy = [ "multi-user.target" ];
    startLimitIntervalSec = 200;
    startLimitBurst = 2;
    environment."IS_SERVICE" = "1";
    serviceConfig = {
      ExecStart = "${asusctl}/bin/asusd";
      Restart = "on-failure";
      RestartSec = 1;
      Type = "dbus";
      BusName = "org.asuslinux.Daemon";
      SELinuxContext = "system_u:system_r:unconfined_t:s0";
    };
  };
  systemd.user.services.asusd-user = {
    description = "ASUS User Daemon";
    wantedBy = [ "default.target" ];
    startLimitIntervalSec = 200;
    startLimitBurst = 2;
    serviceConfig = {
      ExecStart = "${asusctl}/bin/asusd-user";
      Restart = "always";
      RestartSec = 1;
    };
  };
  systemd.user.services.asus-init-setting = {
    description = "Init settings";
    wantedBy = [ "default.target" ];
    after = [ "asusd-user.service" ];
    script = ''
      ${asusctl}/bin/asusctl --chg-limit 72
      ${asusctl}/bin/asusctl led-pow-2 sleep -k false
      ${asusctl}/bin/asusctl --kbd-bright high
    '';
    serviceConfig = {
      Restart = "on-failure";
      Type = "oneshot";
    };
  };
  services.dbus.packages = [ asusctl ];
  environment.etc."asusd/asusd-ledmodes.toml".source =
    "${asusctl}/share/asusd/data/asusd-ledmodes.toml";
}
