{ config, lib, pkgs, ... }:
with lib;
with lib.types; {
  options.requestNixosConfig = mkOption {
    type = attrsOf attrs;
    default = { };
  };
}
