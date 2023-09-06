{nixosConfig, ...}: {
  home.file.".mozilla/firefox/zero/user.js".text =
    nixosConfig.lib.firefox.mkUserJs {"network.proxy.type" = 4;};
}
