{ ... }: {
  services.fwupd.enable = true;
  revive.specifications.system.boxes = [
    {
      src = /Log;
      dst = /var/log;
    }
    {
      src = /Cache/fwupd;
      dst = /var/cache/fwupd;
    }
    {
      src = /Data/fwupd;
      dst = /var/lib/fwupd;
    }
  ];
}
