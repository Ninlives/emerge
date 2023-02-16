{ fn, lib, pkgs, config, ... }:
with fn;
with lib;
with lib.types;
let
  home = path: "${config.home.homeDirectory}/${path}";
  mapRevive = p:
    if builtins.isAttrs p then
      p // { dst = home p.dst; }
    else {
      inherit (p) src;
      dst = home p.dst;
    };
in {
  options.persistent = {
    boxes = mkOption {
      type = listOf (either str attrs);
      default = [ ];
    };
    scrolls = mkOption {
      type = listOf (either str attrs);
      default = [ ];
    };
  };

  config = {
    requestNixOSConfig.persistent-boxes.revive.specifications.user.boxes =
      map mapRevive config.persistent.boxes;
    requestNixOSConfig.persistent-scrolls.revive.specifications.user.scrolls =
      map mapRevive config.persistent.scrolls;
  };
}
