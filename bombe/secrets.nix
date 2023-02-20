{ config, pkgs, lib, inputs, ... }:
with lib; {
  options.secrets.decrypted = mkOption {
    type = types.attrs;
    default = { };
  };
  config = { secrets.decrypted = inputs.values.secret; };
}
