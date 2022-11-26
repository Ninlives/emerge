{ lib
, stdenv
, fetchFromGitLab
, cmake
, e2fsprogs
, fontconfig
, libGL
, libglvnd
, pkg-config
, rustPlatform
, udev
, xorg
, xwayland
, systemd
}:

rustPlatform.buildRustPackage rec {
  pname = "asusctl";
  version = "4.5.0";

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  src = fetchFromGitLab {
    owner = "asus-linux";
    repo = "asusctl";
    rev = version;
    sha256 = "sha256-hkNVgMugTllDqnanVU1rdb7viRG4U1f588rLA55yCbY=";
  };

  cargoSha256 = "sha256-0hPY1+ZlJZfqnWZ+GX1IkhsjU0J0CjrRkegA1DD2yC4=";

  buildInputs = [
    udev
    fontconfig
    xwayland
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    e2fsprogs
    libGL
    libglvnd
    systemd
  ];

  postPatch = ''
    files="
      daemon/src/config.rs
      daemon/src/ctrl_anime/config.rs
      daemon-user/src/daemon.rs
      daemon-user/src/ctrl_anime.rs
      daemon-user/src/user_config.rs
      rog-control-center/src/main.rs
    "
    for file in $files; do
      sed -i -e s,/usr/share,$out/share, $file
    done

    sed -i -e s,/usr/bin/chattr,${e2fsprogs}/bin/chattr, daemon/src/ctrl_platform.rs
  '';

  postInstall = ''
    mkdir -p $out/share/rog-gui/layouts $out/share/icons/hicolor/512x512/apps \
             $out/share/asusd/anime/custom $out/share/icons/hicolor/scalable/status

    install -Dm644 $src/data/asusd.conf $out/share/dbus-1/system.d/asusd.conf
    install -Dm644 $src/rog-aura/data/layouts/*  $out/share/rog-gui/layouts/

    install -Dm644 $src/rog-control-center/data/rog-control-center.desktop $out/share/applications/rog-control-center.desktop
    install -Dm644 $src/rog-control-center/data/rog-control-center.png $out/share/icons/hicolor/512x512/apps/rog-control-center.png

    install -Dm644 $src/data/icons/asus_notif_* $out/share/icons/hicolor/512x512/apps/
    install -Dm644 $src/data/icons/scalable/* $out/share/icons/hicolor/scalable/status/

    install -Dm644 $src/rog-anime/data/anime/asus/rog/Sunset.gif $out/share/asusd/anime/asus/rog/Sunset.gif
    install -Dm644 $src/rog-anime/data/anime/asus/gaming/Controller.gif $out/share/asusd/anime/asus/gaming/Controller.gif
    install -Dm644 $src/rog-anime/data/anime/custom/* $out/share/asusd/anime/custom

    install -Dm644 $src/data/asusd-ledmodes.toml $out/share/asusd/data/asusd-ledmodes.toml

    install -Dm644 $src/data/asusd.rules $out/lib/udev/rules.d/99-asusd.rules
    sed -i -e s,systemctl,${systemd}/bin/systemctl, $out/lib/udev/rules.d/99-asusd.rules
  '';

  postFixup = ''
    patchelf --set-rpath  "$(patchelf --print-rpath $out/bin/rog-control-center):${lib.makeLibraryPath buildInputs}" $out/bin/rog-control-center
  '';

  meta = with lib; {
    description = "A control daemon, CLI tools, and a collection of crates for interacting with ASUS ROG laptops";
    homepage = "https://gitlab.com/asus-linux/asusctl";
    license = licenses.mpl20;
    maintainers = [ maintainers.aacebedo ];
  };
}
