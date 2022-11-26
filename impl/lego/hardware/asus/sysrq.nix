{ config, ... }: {
  services.udev.extraHwdb = ''
    evdev:input:b0003v0B05p19B6*
     KEYBOARD_KEY_7004c=sysrq
  '';
  boot.kernel.sysctl."kernel.sysrq" = 244;
}
