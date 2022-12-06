{ config, lib, pkgs, var, inputs, nixosConfig, ... }:
let
  inherit (var) proxy;
  inherit (lib) concatMapStringsSep optionalAttrs mkIf;
  inherit (lib.hm.gvariant) mkTuple;
in with pkgs;
with pkgs.gnomeExtensions;
with pkgs.nixos-cn.gnome-extensions;
with pkgs.nixos-cn.gnome-themes; 
mkIf nixosConfig.services.xserver.desktopManager.gnome.enable {
  home.packages = [
    dash-to-dock
    mpris-indicator-button
    appindicator
    steal-my-focus
    dynamic-panel-transparent
    pixel-saver
    x11gestures

    bibata-cursors
    gruvbox-gtk-theme
    gtk-engine-murrine
    gnome-themes-extra
  ];

  xdg.configFile."gtk-3.0/bookmarks".text = ''
    file:///chest/Share Share
  '';

  xdg.configFile."gtk-4.0".source = "${gruvbox-gtk-theme}/share/themes/Gruvbox-Dark-B/gtk-4.0";

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/power" = {
      idle-dim = false;
      sleep-inactive-ac-type = "nothing";
      power-button-action = "nothing";
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-schedule-automatic = true;
    };

    "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
    ];
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
      {
        binding = "<Super>space";
        command = "drop-down-kitty";
        name = "Terminal";
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
      ];
    };

    "system/proxy".mode = "manual";
    "system/proxy/socks" = {
      host = proxy.address;
      port = proxy.port.acl;
    };

    "org/gnome/desktop/sound".allow-volume-above-100-percent = true;
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
      "bitwarden.desktop"
      "FeelUOwn.desktop"
      "org.telegram.desktop.desktop"
      "org.qutebrowser.qutebrowser.desktop"
      "chromium-browser.desktop"
      "steam.desktop"
    ];

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      cursor-theme = "Bibata-Modern-Classic";
      icon-theme = "Gruvbox-Dark";
      gtk-theme = "Gruvbox-Dark-B";

      clock-show-weekday = true;
      show-battery-percentage = true;

      text-scaling-factor = 1.5;
    };
    "org/gnome/shell/extensions/user-theme".name = "Gruvbox-Dark-B";
    "org/gnome/desktop/calendar".show-weekdate = true;
    "org/gnome/desktop/background".picture-uri =
      "file://${inputs.data.content.resources "wallpapers/gruvbox.png"}";
    "org/gnome/desktop/background".picture-uri-dark =
      "file://${inputs.data.content.resources "wallpapers/gruvbox.png"}";
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };

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
      "x11gestures@joseexposito.github.io"
      "asusctl-gex@asus-linux.org"
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
  };
}
