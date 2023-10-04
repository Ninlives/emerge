{ pkgs, ... }: {
  /* udev rules makes XBox wireless controller
     unusable in Steam */
  # services.udev.packages = [ pkgs.via ];
  # hardware.keyboard.qmk.enable = true;
}
