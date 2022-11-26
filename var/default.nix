{ lib, pkgs }:
with lib;
recursiveUpdate (fix (self: {

  system = "x86_64-linux";
  path.entry = "${self.user.home}/Emerge";
  path.secrets = "${self.user.home}/Secrets";

  proxy = {
    mark = 187;
    group = "outcha";
    user = "outcha";
    address = "127.0.0.1";
  };

  user = {
    name = "mlatus";
    home = "/home/mlatus";
    groups =
      [ "users" "pulseaudio" "audio" "video" "power" "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  net = {
    default = {
      subnet = "172.16.0.0";
      prefixLength = "12";
      server.address = "172.16.0.1";
      local.address = "172.16.0.2";
      home.address = "172.16.0.3";
    };
  };

})) (import ./ports.nix)
