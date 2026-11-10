{
  pkgs,
  inputs,
  ...
}: {
  dconf.settings = {
    "system/proxy".mode = "auto";
    "org/gnome/desktop/background".picture-uri = "file://${inputs.data.content.resources "wallpapers/jez.jpg"}";
    "org/gnome/desktop/background".picture-uri-dark = "file://${inputs.data.content.resources "wallpapers/jez.jpg"}";
  };

  persistent.boxes = [
    {
      src = /Data/certificates;
      dst = ".cert";
    }
    {
      src = /Data/global-protect/nm-openconnect-auth-dialog;
      dst = ".local/share/nm-openconnect-auth-dialog";
    }
  ];
  persistent.scrolls = [
    {
      src = /Data/global-protect/openconnect_saml_cookies;
      dst = ".local/share/openconnect_saml_cookies";
    }
  ];
}
