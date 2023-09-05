{
  fn,
  lib,
  config,
  ...
}:
with fn;
with lib;
with lib.types; let
  home = path: "${config.home.homeDirectory}/${path}";
  mapping = mkOptionType {
    name = "mapping";
    check = x:
      builtins.isAttrs x && x ? src && path.check x.src && x ? dst && str.check x.dst;
  };
  applyMapping = m:
    if hasPrefix config.home.homeDirectory m.dst
    then m
    else m // {dst = home m.dst;};
  apply = map applyMapping;
in {
  options.persistent = {
    boxes = mkOption {
      type = listOf mapping;
      default = [];
      inherit apply;
    };
    scrolls = mkOption {
      type = listOf mapping;
      default = [];
      inherit apply;
    };
  };
}
