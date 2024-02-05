{
  config,
  lib,
  pkgs,
  args,
  ...
}: let
  # does not link with iptables enabled
  iprouteStatic = pkgs.pkgsStatic.iproute2.override {iptables = null;};
  runOn = prefix:
    pkgs.substituteAll {
      src = ../kexec-run.sh;
      isExecutable = true;

      host = args.target.host;
      busybox = "${prefix}/${pkgs.pkgsStatic.busybox}/bin/busybox";
      ip = "${prefix}/${iprouteStatic}/bin/ip";
      kexec = "${prefix}/${pkgs.pkgsStatic.kexec-tools}/bin/kexec";

      initrd = "${prefix}/${config.system.build.initialRamdisk}/initrd";
      bzImage = "${prefix}/${config.system.build.kernel}/${config.system.boot.loader.kernelFile}";

      init = "${config.system.build.toplevel}/init";
      kernelParams = lib.escapeShellArgs config.boot.kernelParams;
    };

  take = runOn args.fs.entry;
  smoke = runOn "";
  shoot = runOn "/mnt/${args.fs.entry}";
in {
  system.build.kexecHat = pkgs.runCommand "hat" {} ''
    mkdir -p $out
    ln -s ${args.fs.entry}/${take} $out/take
    ln -s ${smoke} $out/smoke
  '';
  system.build.kexecShoot = shoot;
}
