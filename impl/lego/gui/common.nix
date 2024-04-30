{
  pkgs,
  config,
  ...
}: {
  sound.enable = true;
  sound.mediaKeys.enable = true;

  services.xserver.dpi = 144;
  services.libinput = {
    enable = true;
    touchpad.disableWhileTyping = true;
    touchpad.naturalScrolling = true;
  };

  users.users.${config.profile.user.name}.extraGroups = ["input"];
  # services.xserver.desktopManager.xterm.enable = false;

  environment.sessionVariables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    GLFW_IM_MODULE = "ibus";
  };

  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [rime anthy];
  };
}
