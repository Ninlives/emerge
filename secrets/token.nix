{ ... }: {
  secrets.decrypted = import ./encrypt // {
    h-auth = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFnTuV16kTR18LPUzQBb0yhPwp0xAJXR/fRFsTrLQ5C cardno:000615452495";
  };
}
