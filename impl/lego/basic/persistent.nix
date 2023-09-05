{config, ...}: let
  inherit (config.profile.disk) persist;
  inherit (config.home-manager.users.${config.profile.user.name}) persistent;
  home = path: "${config.profile.user.home}/${path}";
in {
  revive.specifications.system.seal = "/${persist}/System";
  revive.specifications.user = {
    seal = "/${persist}/User";
    user = config.profile.user.name;
    group = config.users.groups.users.name;
  };
  fileSystems."/${persist}".neededForBoot = true;

  revive.specifications.user.boxes =
    [
      {
        src = /Home/Emerge;
        dst = home "Emerge";
      }
      {
        src = /Home/Secrets;
        dst = home "Secrets";
      }
    ]
    ++ persistent.boxes;
  revive.specifications.user.scrolls = persistent.scrolls;
}
