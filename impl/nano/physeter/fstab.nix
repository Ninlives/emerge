{
  config,
  args,
  ...
}:
let
  inherit (config.home-manager.users.${config.profile.user.name}) persistent;
in
{
  fileSystems = {
    "/" = {
      fsType = "tmpfs";
      options = ["defaults" "mode=755"];
    };

    "/mnt" = {
      inherit (args.fs) device;
      fsType = args.fs.type;
      neededForBoot = true;
    };

    "/hat" = {
      depends = ["/mnt"];
      device = "/mnt/${args.fs.entry}/hat";
      fsType = "none";
      options = ["bind"];
    };

    "/nix" = {
      depends = ["/mnt"];
      device = "/mnt/${args.fs.entry}/nix";
      fsType = "none";
      options = ["bind"];
    };

    "/pack" = {
      depends = ["/mnt"];
      device = "/mnt/${args.fs.entry}/pack";
      fsType = "none";
      options = ["bind"];
      neededForBoot = true;
    };
  };
  boot.loader.grub.enable = false;

  revive.specifications.storage = {
    seal = "/pack/Shed";
    user = config.users.users.cloud.name;
    group = config.users.groups.users.name;
  };
  revive.specifications.crux.seal = "/pack/Crux";
  revive.specifications.storage.boxes = [
    {
      src = /Storage;
      dst = "${config.users.users.cloud.home}/Storage";
    }
  ] ++ persistent.boxes;
}
