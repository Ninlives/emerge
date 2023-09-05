{lib, ...}:
with lib; {
  options.sops.roles = mkOption {
    type = with types; listOf str;
    default = [];
  };
}
