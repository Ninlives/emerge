{ config, pkgs, fn, var, ... }: {
  revive.specifications.system.seal = "/chest/System";
  revive.specifications.user = {
    seal = "/chest/User";
    user = var.user.name;
    group = config.users.groups.users.name;
  };
  fileSystems."/chest".neededForBoot = true;

  revive.specifications.user.boxes = [
    {
      src = /Home/Emerge;
      dst = var.path.entry;
    }
    {
      src = /Home/Secrets;
      dst = var.path.secrets;
    }
  ];
}
