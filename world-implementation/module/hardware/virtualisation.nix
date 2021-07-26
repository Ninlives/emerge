{ pkgs, constant, ... }:
let
  inherit (pkgs) qemu_kvm virtmanager spice-gtk;
  inherit (constant) user;
in {
  revive.specifications.no-snapshot.boxes = [ /var/lib/libvirt ];
  users.users.${user.name}.extraGroups = [ "libvirtd" "kvm" ];

  virtualisation.libvirtd = {
    enable = true;
    qemuPackage = qemu_kvm;
    onBoot = "ignore";
  };
  security.wrappers.spice-client-glib-usb-acl-helper.source =
    "${spice-gtk}/bin/spice-client-glib-usb-acl-helper";
  environment.systemPackages = [ virtmanager spice-gtk ];
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_msrs=1
  '';
}
