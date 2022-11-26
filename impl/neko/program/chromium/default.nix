{ pkgs, ... }: {
  programs.chromium = {
    enable = true;
    commandLineArgs = [ "--edge-touch-filtering" "--force-tablet-mode" ];
  };
  persistent.boxes = [
    {
      src = /Programs/chromium;
      dst = ".config/chromium";
    }
  ];
}
