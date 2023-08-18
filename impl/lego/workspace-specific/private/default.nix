{ config, lib, fn, ... }: {
  imports = fn.dotNixFromRecursive ./system;
  config = lib.mkIf (config.workspace.identity == "private") {
    sops.profiles = [ "private" ];
    home-manager.users.${config.workspace.user.name} = { ... }: {
      imports = fn.dotNixFromRecursive ./home;
    };
  };
}
