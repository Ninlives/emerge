{ lib, ... }: with lib; {
  options.sops.profiles = mkOption {
    type = with types; listOf str;
    default = [ ];
  };
}
