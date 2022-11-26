{ pkgs, ... }:
let
  inherit (pkgs) runCommand cpio acpica-tools;
  acpi_override = runCommand "acpi_override" { } ''
    ${acpica-tools}/bin/iasl -p $PWD/dsdt ${./dsdt.dsl}
    mkdir -p kernel/firmware/acpi
    cp dsdt.aml kernel/firmware/acpi/dsdt.aml
    find kernel | ${cpio}/bin/cpio -H newc --create > $out
  '';
in {
  boot.initrd.prepend = [ "${acpi_override}" ];
  boot.kernelParams = [ "mem_sleep_default=deep" ];
}
