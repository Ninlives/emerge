{ lib, config, pkgs, inputs, nixosConfig, ... }: lib.mkIf nixosConfig.services.xserver.enable {
  home.packages = with pkgs; [
    # GUI
    # zoom-us
    # teams
    # keepassxc
    tdesktop
    # element-desktop
    # libreoffice
  ];

  home.file.".face".source = inputs.data.content.resources "avatar.jpg";

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
