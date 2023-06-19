{ pkgs, config, lib, ... }: {
  config = lib.mkIf (config.workspace.identity == "private") {
    environment.systemPackages = [ pkgs.thunderbird ];
    sops.profiles = [ "private" ];
  };
}
