{pkgs, ...}: {
  home.packages = with pkgs; [tdesktop];
  persistent.boxes = [
    {
      src = /Programs/telegram;
      dst = ".local/share/TelegramDesktop";
    }
  ];
}
