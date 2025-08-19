{pkgs, ...}: {
  /*
  udev rules makes XBox wireless controller
  unusable in Steam
  */
  services.udev.packages = [ pkgs.via ];
  hardware.keyboard.qmk.enable = true;
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="02c0", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';
}
