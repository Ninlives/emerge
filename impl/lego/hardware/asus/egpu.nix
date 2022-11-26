{ config, pkgs, var, ... }: with pkgs; let
  inherit (var) user;
  send = summary: body: "${util-linux}/bin/runuser -u ${user.name} ${libnotify}/bin/notify-send '${summary}' '${body}'";
  activate-egpu = writeShellScriptBin "activate-egpu" ''
    echo 1 > /sys/devices/platform/asus-nb-wmi/egpu_enable
    echo 1 > /sys/bus/pci/rescan

    if ${pciutils}/bin/lspci|${gnugrep}/bin/grep -q '6800M';then
      ${send "Activate E-GPU" "Success"}
    else
      ${send "Activate E-GPU" "Fail"}
    fi
  '';

  deactivate-egpu = writeShellScriptBin "deactivate-egpu" ''
    echo 0 > /sys/devices/platform/asus-nb-wmi/egpu_enable
    echo 1 > /sys/bus/pci/rescan
    ${send "Deactivate E-GPU" "Finished"}
  '';
in {
  environment.systemPackages = [ activate-egpu deactivate-egpu ];
  security.sudo.extraRules = [{
    users = [ user.name ];
    commands = [
      {
        command = "${activate-egpu}/bin/activate-egpu";
        options = [ "NOPASSWD" ];
      }
      {
        command = "${deactivate-egpu}/bin/deactivate-egpu";
        options = [ "NOPASSWD" ];
      }
    ];
  }];
  security.sudo.extraConfig = ''
    Defaults!${activate-egpu}/bin/activate-egpu,${deactivate-egpu}/bin/deactivate-egpu env_keep+=DBUS_SESSION_BUS_ADDRESS
  '';
}
