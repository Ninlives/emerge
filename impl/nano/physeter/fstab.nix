{
  config,
  args,
  ...
}: {
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
    seal = "/pack/storage";
    user = config.users.users.cloud.name;
    group = config.users.groups.users.name;
  };
  revive.specifications.crux.seal = "/pack/crux";
  revive.specifications.storage.boxes = [
    {
      src = /cloud;
      dst = "${config.users.users.cloud.home}/Storage";
    }
  ];
}
