{ lib, config, ... }: {
  services.nfs.server = {
    enable = true;
    exports = ''
      /chest/Data/kavita 127.0.0.1(rw,insecure)
    '';
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
  };
  revive.specifications.system.boxes = [{
    dst = /chest/Data/kavita;
    user = config.users.users.kavita.name;
    group = config.users.groups.kavita.name;
  }];
}
