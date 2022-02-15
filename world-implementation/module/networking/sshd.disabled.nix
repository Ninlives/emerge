{ config, pkgs, constant, lib, ... }:
let
  dp = config.secrets.decrypted;
  net = constant.net.default;
  wireguardUnits = map (i: "wireguard-${i}.service")
    (builtins.attrNames config.networking.wireguard.interfaces);
in {
  hack.specialisation.server.configuration = {
    boot.loader.grub.configurationName = "Server";
    nvidia.asPrimaryGPU = false;
    services.openssh = {
      enable = true;
      passwordAuthentication = false;
      forwardX11 = true;
      listenAddresses = [{
        addr = net.local.address;
        port = dp.h-port;
      }];
      hostKeys = [
        {
          type = "rsa";
          bits = 4096;
          path = "/var/lib/ssh/ssh_host_rsa_key";
        }
        {
          type = "ed25519";
          path = "/var/lib/ssh/ssh_host_ed25519_key";
        }
      ];
    };
    networking.firewall.allowedTCPPorts = [ dp.ssh.port ];
    systemd.services.sshd.after = wireguardUnits;
    services.logind.lidSwitchExternalPower = "lock";
    revive.specifications.system.boxes = [{
      src = /chest/System/Data/ssh;
      dst = /var/lib/ssh;
    }];

    programs.gnupg.agent.pinentryFlavor = "curses";
    users.users.${constant.user.name}.openssh.authorizedKeys.keys =
      [ dp.h-auth ];
    home-manager.users.${constant.user.name}.dconf.settings."org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type =
      "nothing";
  };
}
