{ lib, pkgs }:
with lib;
fix (self: {

  system = "x86_64-linux";
  path.entry = "${self.user.home}/Emerge";
  path.secrets = "${self.user.home}/Secrets";

  sops.keys = [ "${self.path.entry}/bombe/keys/users" "${self.path.entry}/bombe/keys/hosts"];

  proxy = {
    mark = 187;
    group = "outcha";
    user = "outcha";
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

  user = {
    name = "mlatus";
    home = "/home/mlatus";
    groups = [
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
})
