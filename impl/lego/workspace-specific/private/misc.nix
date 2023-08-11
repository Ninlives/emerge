{ config, lib, ... }: {
  config = lib.mkIf (config.workspace.identity == "private") {
    sops.profiles = [ "private" ];
  };
}
