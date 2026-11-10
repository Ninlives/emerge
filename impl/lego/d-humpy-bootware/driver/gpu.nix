{ stdenv
, kernel
, kernelModuleMakeFlags
}:

stdenv.mkDerivation {
  pname = "virtio-gpu-p";
  inherit (kernel) version src hardeningDisable;

  enableParallelBuilding = true;

  nativeBuildInputs = kernel.moduleBuildDependencies;

  patches = [
    ./virtio-gpu-p.patch
    ./virtio-gpu-guest-alloc.patch
  ];

  makeFlags = kernelModuleMakeFlags ++ [
    "INSTALL_MOD_PATH=$(out)"
    "M=$(PWD)/drivers/gpu/drm/virtio/"
  ];

  buildFlags = [ "modules" ];
  installTargets = [ "modules_install" ];
}
