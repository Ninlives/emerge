{ pkgs, var, ... }:
let
  inherit (pkgs) qemu_kvm virtmanager spice-gtk;
in {
  revive.specifications.system.boxes = [{
    src = /Programs/libvirt;
    dst = /var/lib/libvirt;
  }];
  users.users.${var.user.name}.extraGroups = [ "libvirtd" "kvm" ];

  virtualisation.libvirtd = {
    enable = true;
    qemu.package = qemu_kvm;
    onBoot = "ignore";
  };
  security.wrappers.spice-client-glib-usb-acl-helper = {
    source = "${spice-gtk}/bin/spice-client-glib-usb-acl-helper";
    owner = "root";
    group = "root";
    setuid = true;
  };
  environment.systemPackages = [ virtmanager spice-gtk ];
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_msrs=1
  '';

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
