{ lib, ... }:
with lib;
with lib.types; {
  options.requestNixOSConfig = mkOption {
    type = attrsOf attrs;
    default = { };
  };
}
