{ pkgs, config, ... }: {
  sound.enable = true;
  sound.mediaKeys.enable = true;

  services.xserver = {
    enable = true;
    dpi = 144;
    libinput = {
      enable = true;
      touchpad.disableWhileTyping = true;
      touchpad.naturalScrolling = true;
    };
  };

  users.users.${config.workspace.user.name}.extraGroups = [ "input" ];
  # services.xserver.desktopManager.xterm.enable = false;

  environment.sessionVariables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    GLFW_IM_MODULE = "ibus";
  };

  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = [ pkgs.ibus-engines.rime ];
  };
}
