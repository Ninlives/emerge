{ config, pkgs, inputs, ... }: {
  home.packages = with pkgs; [
    # GUI
    zoom-us
    teams
    keepassxc
    tdesktop
    element-desktop
    # libreoffice
  ];
  services.flameshot.enable = true;

  home.file.".face".source = inputs.data.content.resources + /avatar.jpg;

  xdg.mimeApps.associations.removed."application/pdf" = "draw.desktop";
  xdg.mimeApps.associations.added."application/vnd.openxmlformats-officedocument.presentationml.presentation" =
    "impress.desktop";
  xdg.mimeApps.associations.added."application/msword" = "writer.desktop";

  persistent.boxes = [
    {
      src = /Programs/telegram;
      dst = ".local/share/TelegramDesktop";
    }
    {
      src = /Programs/element;
      dst = ".config/Element";
    }
  ];
}
