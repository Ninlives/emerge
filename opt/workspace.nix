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
    chestVolume = mkOption {
      type = str;
      default = "chest";
    };
    hostName = mkOption {
      type = str;
      default = "nixos";
    };
  };
}
