{...}: {
  lib.path.persistent = rec {
    label = "NIXOS";
    volume = "chest";
    root = "/chest";
    cache = "${root}/Cache";
    static = "${root}/Static";
    data = "${root}/Data";
    services = "${root}/Services";
    snapshot = {
      root = "${root}/Snapshot";
      data = "${snapshot.root}/Data";
      services = "${snapshot.root}/Services";
    };
  };
}
