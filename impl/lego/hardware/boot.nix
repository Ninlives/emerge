{ config, pkgs, lib, ... }:
let
  inherit (pkgs) fetchFromGitHub fixedsys-excelsior terminus_font;

  falloutTheme = fetchFromGitHub {
    owner = "Ninlives";
    repo = "fallout-grub-theme";
    rev = "70dbb3959d090f6bcd7acfffd1245ba88e0a19ea";
    sha256 = "11wrfjxvxsyf23ipjfgqx2hkhw9lid8dmadqssyxkrj14m7wdvjn";
  };

in {
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.grub.extraPrepareConfig = ''
    test -d /boot/grub/fallout && rm -rf /boot/grub/fallout
    cp -rpf ${falloutTheme}/. /boot/grub/fallout/
  '';
  boot.loader.grub.extraConfig = ''
    set theme=($drive1)//grub/fallout/theme.txt
  '';
  boot.loader.grub.memtest86.enable = true;

  boot.loader.grub.splashImage = "${falloutTheme}/background.png";
  boot.loader.grub.backgroundColor = "#7EBAE4";
  boot.loader.timeout = 65535;

  boot.loader.grub.font =
    "${fixedsys-excelsior}/share/fonts/truetype/fixedsys-excelsior-3.00.ttf";

  boot.cleanTmpDir = true;

  console.font = "ter-i32b";
  console.packages = [ terminus_font ];
  console.earlySetup = true;

  revive.specifications.system.boxes = [
    {
      src = /Log;
      dst = /var/log;
    }
    {
      src = /Cache/fwupd;
      dst = /var/cache/fwupd;
    }
    {
      src = /Data/fwupd;
      dst = /var/lib/fwupd;
    }
  ];
}
