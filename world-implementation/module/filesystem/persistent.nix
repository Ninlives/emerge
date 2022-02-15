{ config, pkgs, constant, ... }:
let inherit (constant) user;
in {
  revive.specifications.system.seal = "/chest/System";
  revive.specifications.user = {
    seal = "/chest/User";
    user = user.name;
    group = config.users.groups.users.name;
  };
  fileSystems."/chest".neededForBoot = true;

  revive.specifications.user.boxes = [{
    src = /Programs/adb;
    dst = "${user.config.home}/.android";
  }];
  revive.specifications.system.boxes = [{
    src = /Data/sops;
    dst = /var/lib/sops;
  }];
}
