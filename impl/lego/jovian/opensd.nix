{
  config,
  pkgs,
  lib,
  ...
}: {
  hardware.uinput.enable = true;
  users.users.opensd = {
    isSystemUser = true;
    home = "/var/lib/opensd";
    createHome = true;
    group = config.users.groups.opensd.name;
  };
  users.groups.opensd = {};
  services.udev.packages = [pkgs.opensd];
  systemd.services.opensd = with lib.generators; let
    cfgRoot = "/var/lib/opensd/.config/opensd";
    mkKeyValue = mkKeyValueDefault {} " = ";
    cfgINI = builtins.toFile "config.ini" (toINI {inherit mkKeyValue;} {
      Daemon.Profile = "navigate.profile";
    });
    mkPrfl = name: bindings:
      builtins.toFile "opensd.profile" (toINI {inherit mkKeyValue;} {
        Profile.Name = name;
        Features = {
          ForceFeedback = true;
          MotionDevice = true;
          MouseDevice = true;
          LizardMode = false;
          StickFiltering = true;
          TrackpadFiltering = true;
        };
        Bindings =
          {
            RPadRelX = "Mouse REL_X";
            RPadRelY = "Mouse REL_Y";
            RPadTouch = "None";
            RPadPress = "Mouse BTN_LEFT";
            LPadPress = "Mouse BTN_RIGHT";
            LPadRelX = "Mouse REL_HWHEEL_HI_RES";
            LPadRelY = "Mouse REL_WHEEL_HI_RES";
            L4 = "Profile navigate.profile";
            R4 = "Profile numpad.profile";
          }
          // bindings;
      });
    navigate = mkPrfl "Navigate" {
      DpadUp = "Mouse KEY_UP";
      DpadLeft = "Mouse KEY_LEFT";
      DpadDown = "Mouse KEY_DOWN";
      DpadRight = "Mouse KEY_RIGHT";
      Y = "None";
      X = "None";
      A = "Mouse KEY_ENTER";
      B = "Mouse KEY_ESC";
      L1 = "Mouse KEY_LEFTMETA";
      R1 = "None";
      L2 = "Mouse BTN_RIGHT";
      R2 = "Mouse BTN_LEFT";
    };
    numpad = mkPrfl "Numpad" {
      DpadUp = "Mouse KEY_1";
      DpadLeft = "Mouse KEY_2";
      DpadDown = "Mouse KEY_3";
      DpadRight = "Mouse KEY_4";
      Y = "Mouse KEY_5";
      X = "Mouse KEY_6";
      A = "Mouse KEY_7";
      B = "Mouse KEY_8";
      L1 = "Mouse KEY_9";
      R1 = "Mouse KEY_0";
      L2 = "Mouse KEY_BACKSPACE";
      R2 = "Mouse KEY_ENTER";
    };
  in {
    wantedBy = ["multi-user.target"];
    script = ''
      exec ${pkgs.opensd}/bin/opensdd -l info
    '';
    preStart = ''
      rm -rf ${cfgRoot}
      mkdir -p ${cfgRoot}/profiles
      ln -s ${cfgINI} ${cfgRoot}/config.ini
      ln -s ${navigate} ${cfgRoot}/profiles/navigate.profile
      ln -s ${numpad} ${cfgRoot}/profiles/numpad.profile
    '';
    serviceConfig = with config.users; {
      User = users.opensd.name;
      SupplementaryGroups = [groups.uinput.name groups.input.name];
      Restart = "on-failure";
      RestartSec = 1;
    };
  };
}
