{
  config,
  lib,
  pkgs,
  args,
  ...
}: let
  # does not link with iptables enabled
  iprouteStatic = pkgs.pkgsStatic.iproute2.override {iptables = null;};
in {
  system.build.kexecHat = pkgs.substituteAll {
    src = ../kexec-run.sh;
    isExecutable = true;

    host = args.target.host;
    busybox = "${args.fs.entry}/${pkgs.pkgsStatic.busybox}/bin/busybox";
    ip = "${args.fs.entry}/${iprouteStatic}/bin/ip";
    kexec = "${args.fs.entry}/${pkgs.pkgsStatic.kexec-tools}/bin/kexec";

    initrd = "${args.fs.entry}/${config.system.build.initialRamdisk}/initrd";
    bzImage = "${args.fs.entry}/${config.system.build.kernel}/${config.system.boot.loader.kernelFile}";

    init = "${config.system.build.toplevel}/init";
    kernelParams = lib.escapeShellArgs config.boot.kernelParams;
  };
}
