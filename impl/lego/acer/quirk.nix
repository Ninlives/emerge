{ ... }: 
{
  boot.kernelPatches = [ { patch = ./force_8bpc.patch; } ];
}
