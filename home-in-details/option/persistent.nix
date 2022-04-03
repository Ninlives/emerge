{ config, lib, pkgs, out-of-world, ... }:
with lib;
with lib.types;
let
  inherit (out-of-world.function) home;
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
    requestNixosConfig.persistent-boxes.revive.specifications.user.boxes =
      map mapRevive config.persistent.boxes;
    requestNixosConfig.persistent-scrolls.revive.specifications.user.scrolls =
      map mapRevive config.persistent.scrolls;
  };
}
