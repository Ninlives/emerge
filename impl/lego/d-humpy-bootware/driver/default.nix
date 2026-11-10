{ config, ... }: {
   boot.extraModulePackages = [ (config.boot.kernelPackages.callPackage ./gpu.nix { }) ];
   boot.kernelModules = [ "virtio_gpu_p" ];
   boot.initrd.availableKernelModules = [ "virtio_gpu_p" ];
   boot.blacklistedKernelModules = [ "virtio_gpu" ];
}
