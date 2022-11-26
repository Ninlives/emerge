{ pkgs, ... }: {
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.sensor.iio.enable = true;

  # boot.kernelParams = [
  #   "initcall_blacklist=acpi_cpufreq_init"
  # ];
  # boot.kernelModules = [ "amd-pstate" ];

  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
    amdvlk
  ];
  hardware.opengl.extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
  environment.variables.AMD_VULKAN_ICD = "RADV";

  hardware.cpu.amd.updateMicrocode = true;
}
