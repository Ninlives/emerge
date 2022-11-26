{ inputs, var, config, pkgs, lib, ... }:
let
  substitueContent = file: subst:
    with lib;
    let
      split = pred: list:
        (foldl (ir: e:
          if (pred ir.index e) then {
            index = ir.index + 1;
            result = ir.result ++ [ e ];
          } else {
            index = ir.index + 1;
            inherit (ir) result;
          }) {
            index = 0;
            result = [ ];
          } list).result;
      mod = a: b: a - b * (a / b);
      pat = split (index: _: mod index 2 == 0) subst;
      rep = split (index: _: mod index 2 == 1) subst;
    in replaceStrings pat rep (readFile file);

  dbusSession = "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${toString config.users.users.${var.user.name}.uid}/bus";

  modeChange = pkgs.writeShellScript "mode-change" ''
    case $1 in
      LAPTOP)
        action=stop
        ;;
      TABLET)
        action=start
        ;;
      *)
        echo "Unknown mode '$1'"
        exit 1
        ;;
      esac
    ${config.systemd.package}/bin/systemctl --user $action disable-touchpad
    ${pkgs.dconf}/bin/dconf write /org/gnome/shell/extensions/indicator/mode "'$1'"
  '';
in {
  imports = [ inputs.kmonad.nixosModules.default ];

  services.kmonad = {
    enable = true;
    keyboards.qwerty = {
      device =
        "/dev/input/by-id/usb-ASUSTeK_Computer_Inc._N-KEY_Device-if02-event-kbd";
      defcfg = {
        enable = true;
        fallthrough = true;
        allowCommands = true;
      };
      config = substitueContent ./qwerty.kbd [
        "mode-change" "${dbusSession} ${modeChange}"
      ];
    };

    keyboards.extra = {
      device =
        "/dev/input/by-id/usb-ASUSTeK_Computer_Inc._N-KEY_Device-event-if00";
      defcfg = {
        enable = true;
        fallthrough = true;
        allowCommands = true;
      };
      config = substitueContent ./extra.kbd [
        "asusctl" "${dbusSession} ${pkgs.asusctl}/bin/asusctl"
      ];
    };
  };

  systemd.user.services.disable-touchpad.script = ''
    ${pkgs.evtest}/bin/evtest --grab /dev/input/by-path/platform-AMDI0010:01-event-mouse > /dev/null
  '';
  systemd.services.kmonad-qwerty.serviceConfig.User = lib.mkForce var.user.name;
  systemd.services.kmonad-extra.serviceConfig.User = lib.mkForce var.user.name;

  services.xserver = {
    xkbOptions = "compose:ralt";
    layout = "us";
  };
  users.users.${var.user.name}.extraGroups = [ "input" "uinput" ];
}
