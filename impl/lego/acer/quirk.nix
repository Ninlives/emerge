{ ... }: 
{
  boot.kernelPatches = [ { patch = ./force_8bpc.patch; } ];
  boot.kernelParams = [
    "drm.debug=0x1ff"
  ];
}
