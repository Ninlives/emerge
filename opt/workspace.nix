{ lib, var, ... }: with lib; with lib.types; {
  options.workspace = {
    identity = mkOption {
      type = str;
      default = "private";
    };
    user.name = mkOption {
      type = str;
      default = "mlatus";
    };
    user.home = mkOption {
      type = path;
      default = "/home/mlatus";
    };
    user.uid = mkOption {
      type = int;
      default = 1000;
    };
    disk.persist = mkOption {
      type = str;
      default = "garden";
    };
    disk.swap = mkOption {
      type = str;
      default = "chest";
    };
    email.account.default = mkOption {
      type = str;
      default = "private";
    };
    hostname = mkOption {
      type = str;
      default = "nixos";
    };
    proxy.default = mkOption {
      type = str;
      default = "v2ray-trojan";
    };
  };
}
