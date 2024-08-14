{pkgs, lib, ...}:
let
  inherit (pkgs.buildFHSEnv {
    name = "mask";
    targetPkgs = p: with p; [
      gcc
      flex
      bison
      (isl.overrideAttrs rec {
        version = "0.22";
        src = fetchurl {
          urls = [
            "mirror://sourceforge/libisl/isl-${version}.tar.xz"
            "https://libisl.sourceforge.io/isl-${version}.tar.xz"
          ];
          hash = "sha256-bIvFbEd6/+y6nFniyfAmlnrIutAbUb3QeRbbQKUXufo=";
        };
      })
      libmpc
      mpfr
      gmp
      zlib
      zstd
      parted
      multipath-tools
      (builtins.getFlake "github:NixOS/nixpkgs/99fcf0ee74957231ff0471228e9a59f976a0266b").legacyPackages.${pkgs.system}.go_1_17
      # Kernel
      perl
      bc
      nettools
      openssl
      openssl.dev
      rsync
      python3Minimal
      kmod
      bc
    ];
  }) fhsenv;
in
{
  environment.stub-ld.enable = false;
  environment.etc."ld.so.conf".source = "${pkgs.glibc}/etc/ld.so.conf";
  environment.etc."ld.so.cache".source = "${pkgs.glibc}/etc/ld.so.cache";
  environment.shellInit = ''
    export PATH=$PATH:/usr/bin:/bin
  '';
  boot.postBootCommands = with lib; ''
    ${concatMapStringsSep "\n" (comp: ''
      rm -rf "/${comp}"
      ln -s "${fhsenv}/${comp}" "/${comp}"
    '') ["bin" "lib" "lib64" "usr"]}

    tmpGlibcEtc=$(mktemp --directory)
    mkdir -p "$tmpGlibcEtc/upper"
    mkdir -p "$tmpGlibcEtc/work"

    mount -t overlay \
      -o lowerdir=${pkgs.glibc}/etc,upperdir=$tmpGlibcEtc/upper,workdir=$tmpGlibcEtc/work \
      overlay ${pkgs.glibc}/etc

    cat > /etc/ld.so.conf <<EOF
    /lib
    /lib/x86_64-linux-gnu
    /lib64
    /usr/lib
    /usr/lib/x86_64-linux-gnu
    /usr/lib64
    /lib/i386-linux-gnu
    /lib32
    /usr/lib/i386-linux-gnu
    /usr/lib32
    /run/opengl-driver/lib
    /run/opengl-driver-32/lib
    EOF

    ${pkgs.glibc.bin}/bin/ldconfig -f /etc/ld.so.conf -C ${pkgs.glibc}/etc/ld.so.cache
  '';
}
