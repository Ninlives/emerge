{ ... }: {
  hack.specialisation = {
    pci-passthru.configuration = {
      boot.loader.grub.configurationName = "PCI passthrough";
      powersave.enable = false;
      nvidia.asPrimaryGPU = true;
      boot.kernelParams = [ "intel_iommu=on" "iommu=pt" ];
    };
  };
}
