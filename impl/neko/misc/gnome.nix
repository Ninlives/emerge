{ config, lib, pkgs, var, inputs, nixosConfig, ... }:
let
  inherit (var) proxy;
  inherit (lib) concatMapStringsSep optionalAttrs;
  inherit (lib.hm.gvariant) mkTuple;
in with pkgs;
with pkgs.gnomeExtensions;
with pkgs.nixos-cn.gnome-extensions;
with pkgs.nixos-cn.gnome-themes; {
  home.packages = [
    dash-to-dock
    mpris-indicator-button
    appindicator
    steal-my-focus
    dynamic-panel-transparent
    pixel-saver
    #compiz-windows-effect
    x11gestures

    bibata-cursors
    gruvbox-icon
    flat-remix-gtk
    flat-remix-gnome
  ];

  xdg.configFile."gtk-3.0/bookmarks".text = ''
    file:///space/Share Share
  '';

  dconf.settings = optionalAttrs (!nixosConfig.powersave.enable) {
    "org/gnome/settings-daemon/plugins/power" = {
      idle-dim = false;
      sleep-inactive-ac-type = "nothing";
    };
  } // {
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-schedule-automatic = true;
    };

    "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
    ];
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
      {
        binding = "<Super>period";
        command = "drop-down-kitty";
        name = "terminal";
      };

    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source = [ "<Shift>space" ];
      switch-input-source-backward = [ "<Primary><Shift>space" ];
    };

    "org/gnome/desktop/peripherals/touchpad".tap-to-click = true;

    "org/gnome/desktop/input-sources" = {
      sources = map mkTuple [
        [ "xkb" "us" ]
        [ "ibus" "rime" ]
        [ "ibus" "anthy" ]
        [ "ibus" "uniemoji" ]
        [ "ibus" "m17n:t:lsymbol" ]
      ];
    };

    "system/proxy".mode = "manual";
    "system/proxy/socks" = {
      host = proxy.address;
      port = proxy.port.acl;
    };

    # "org/gnome/desktop/sound".allow-volume-above-100-percent = true;

    "org/gnome/shell".welcome-dialog-last-shown-version = "40.1";

    # Applications

    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };

    # Appearance

    "org/gnome/shell".favorite-apps = [
      "org.gnome.Settings.desktop"
      "org.gnome.Nautilus.desktop"
      "thunderbird.desktop"
      "virt-manager.desktop"
      "FeelUOwn.desktop"
      "telegramdesktop.desktop"
      "org.qutebrowser.qutebrowser.desktop"
      "steam.desktop"
    ];

    "org/gnome/shell/extensions/user-theme".name = "Flat-Remix-Green-Dark";

    "org/gnome/desktop/interface" = {
      cursor-theme = "Bibata-Modern-Classic";
      gtk-theme = "Flat-Remix-GTK-Green-Dark";
      icon-theme = "Gruvbox";

      clock-show-weekday = true;
      show-battery-percentage = true;
    };
    "org/gnome/desktop/calendar".show-weekdate = true;
    "org/gnome/desktop/background".picture-uri =
      "file://${inputs.data.content.resources + /wallpapers/gojira.jpg}";

    # Extensions

    "org/gnome/shell".disable-user-extensions = false;
    "org/gnome/shell".enabled-extensions = [
      "user-theme@gnome-shell-extensions.gcampax.github.com"
      "alternate-tab@gnome-shell-extensions.gcampax.github.com"
      "dash-to-dock@micxgx.gmail.com"
      "dynamic-panel-transparency@rockon999.github.io"
      "native-window-placement@gnome-shell-extensions.gcampax.github.com"
      "nohotcorner@azuri.free.fr"
      "steal-my-focus@kagesenshi.org"
      "windowsNavigator@gnome-shell-extensions.gcampax.github.com"
      "appindicatorsupport@rgcjonas.gmail.com"
      "mprisindicatorbutton@JasonLG1979.github.io"
      "pixel-saver@deadalnix.me"
      "compiz-windows-effect@hermes83.github.com"
      "x11gestures@joseexposito.github.io"
    ];

    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "BOTTOM";
      isolate-monitors = true;
      isolate-workspaces = true;
      show-trash = false;
      click-action = "minimize-or-previews";
    };

    "org/gnome/shell/extensions/dynamic-panel-transparency" = {
      enable-opacity = true;
      maximized-opacity = 255;
      unmaximized-opacity = 0;
    };

    "org/gnome/shell/extensions/ncom/github/hermes83/compiz-windows-effect" = {
      js-engine = false;
    };
  };
}
