{ pkgs, config, ... }: with pkgs;
{
  services.asusd = {
    enable = true;
    enableUserService = true;
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
}
