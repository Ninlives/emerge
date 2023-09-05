{
  nixosConfig,
  inputs,
  ...
}: let
  inherit (nixosConfig.lib) proxy;
in {
  dconf.settings = {
    "system/proxy".mode = "manual";
    "system/proxy/socks" = {
      host = proxy.address;
      port = proxy.port.acl;
    };
    "org/gnome/desktop/background".picture-uri = "file://${inputs.data.content.resources "wallpapers/gruvbox.png"}";
    "org/gnome/desktop/background".picture-uri-dark = "file://${inputs.data.content.resources "wallpapers/gruvbox.png"}";
  };
}
