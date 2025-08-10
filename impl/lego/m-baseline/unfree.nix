{
  lib,
  config,
  ...
}:
with lib; {
  options.allowUnfreePackageNames = mkOption {
    type = with types; listOf str;
    default = [];
  };

  config = {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (getName pkg) config.allowUnfreePackageNames;
  };
}
