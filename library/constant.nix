{ lib, pkgs }:
with lib;
with pkgs; {
  proxy = rec {
    mark = 187;
    group = "outcha";
    user = group;
    address = "127.0.0.1";
    port = {
      local = 1080;
      redir = 1081;
      acl = 1082;
      dns = 1083;
      reverse = 1084;
      wormhole = 1085;
    };
  };

  user = rec {
    name = "mlatus";
    config = {
      isNormalUser = true;
      home = "/home/${name}";
      createHome = true;
      extraGroups = [
        "users"
        "pulseaudio"
        "audio"
        "video"
        "power"
        "wheel"
        "networkmanager"
      ];
      shell = pkgs.zsh;
    };
  };

  net = {
    default = {
      subnet = "172.16.0.0/12";
      server = {
        address = "172.16.0.1";
        prefixLength = "12";
      };
      local = {
        address = "172.16.0.2";
        prefixLength = "12";
      };
    };
  };
}
