{ config, pkgs, fn, var, ... }:
let
  home = path: "${config.workspace.user.home}/${path}";
in
{
  revive.specifications.system.seal = "/chest/System";
  revive.specifications.user = {
    seal = "/chest/User";
    user = config.workspace.user.name;
    group = config.users.groups.users.name;
  };
  fileSystems."/chest".neededForBoot = true;

  revive.specifications.user.boxes = [
    {
      src = /Home/Emerge;
      dst = home "Emerge";
    }
    {
      src = /Home/Secrets;
      dst = home "Secrets";
    }
  ];
}
