{ config, pkgs, fn, var, ... }:
let
  inherit (config.workspace.disk) persist;
  home = path: "${config.workspace.user.home}/${path}";
in
{
  revive.specifications.system.seal = "/${persist}/System";
  revive.specifications.user = {
    seal = "/${persist}/User";
    user = config.workspace.user.name;
    group = config.users.groups.users.name;
  };
  fileSystems."/${persist}".neededForBoot = true;

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
