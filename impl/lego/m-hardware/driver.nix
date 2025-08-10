{ ... }: {
  services.pulseaudio.enable = false;
  services.pipewire.alsa.support32Bit = true;
  hardware.graphics.enable32Bit = true;
  services.pulseaudio.support32Bit = true;

  hardware.xpadneo.enable = true;

  revive.specifications.system.boxes = [
    {
      src = /Data/network-connections;
      dst = /etc/NetworkManager/system-connections;
    }
    {
      src = /Data/bluetooth;
      dst = /var/lib/bluetooth;
    }
  ];
}
