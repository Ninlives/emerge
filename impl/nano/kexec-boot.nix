{
  config,
  lib,
  modulesPath,
  pkgs,
  args,
  ...
}: let
  # does not link with iptables enabled
  iprouteStatic = pkgs.pkgsStatic.iproute2.override {iptables = null; elfutils = null;};
in {
  imports = [
    (modulesPath + "/installer/netboot/netboot-minimal.nix")
  ];

  system.build.kexecRun = pkgs.replaceVars {
    src = ./kexec-run.sh;
    isExecutable = true;

    host = args.target.host;
    busybox = "${args.target.directory}/boot/busybox";
    ip = "${args.target.directory}/boot/ip";
    kexec = "${args.target.directory}/boot/kexec";

    initrd = "${args.target.directory}/boot/initrd";
    bzImage = "${args.target.directory}/boot/bzImage";

    init = "${config.system.build.toplevel}/init";
    kernelParams = lib.escapeShellArgs config.boot.kernelParams;
  };

  system.build.kexecBoot = pkgs.runCommand "kexec-tarball" {} ''
    mkdir kexec $out
    cp "${pkgs.pkgsStatic.busybox}/bin/busybox" $out/busybox
    cp "${config.system.build.netbootRamdisk}/${config.system.boot.loader.initrdFile}" kexec/initrd
    cp "${config.system.build.kernel}/${config.system.boot.loader.kernelFile}" kexec/bzImage
    cp "${config.system.build.kexecRun}" kexec/run
    cp "${pkgs.pkgsStatic.kexec-tools}/bin/kexec" kexec/kexec
    cp "${iprouteStatic}/bin/ip" kexec/ip
    ${lib.optionalString (pkgs.hostPlatform == pkgs.buildPlatform) ''
      kexec/ip -V
      kexec/kexec --version
    ''}
    cd kexec
    tar -czvf $out/kexec.tar.gz *
  '';

  # for detection if we are on kexec
  environment.etc.is_kexec.text = "true";
}
