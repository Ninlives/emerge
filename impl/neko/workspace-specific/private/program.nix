{ config, lib, pkgs, nixosConfig, ... }: {
  config = lib.mkIf (nixosConfig.workspace.identity == "private") {
    programs.qutebrowser.enable = true;

    home.packages = with pkgs; [ tdesktop ];
    persistent.boxes = [
      {
        src = /Programs/telegram;
        dst = ".local/share/TelegramDesktop";
      }
    ];
  };
}
