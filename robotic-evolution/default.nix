{ config, pkgs, lib, ... }:
with pkgs;
with lib;
let
  fetch = { url, rev, sha256 }:
    fetchgit {
      deepClone = false;
      fetchSubmodules = false;
      leaveDotGit = false;
      inherit url rev sha256;
    };
in {
  device = "cmi";
  flavor = "lineageos";
  androidVersion = 11;
  variant = "user";
  ccache.enable = true;

  apps.fdroid.enable = true;

  apps.chromium.enable = false;
  webview.chromium.enable = false;
  apps.bromite.enable = true;
  webview.bromite.enable = true;
  webview.bromite.availableByDefault = true;

  source.dirs."device/xiaomi/sm8250-common".src = fetch {
    url = "https://github.com/Ninlives/android_device_xiaomi_sm8250-common.git";
    rev = "db164334b419c730c9363885ddab42a6a78cc515";
    sha256 = "sha256-DnQLk4QyiHzTzEZPjH27UFjRdro1nPIW/o001sGtD+g=";
  };

  source.dirs."hardware/xiaomi".src = fetch {
    url = "https://github.com/LineageOS/android_hardware_xiaomi.git";
    rev = "d865b86327017fcc5be6658943f38163eb5e2c1f";
    sha256 = "sha256-og8aoAMqgR/rHr+eRqfP8Ica+b37RsztwHH51ZSyhUc=";
  };

  source.dirs."kernel/xiaomi/sm8250".src = fetch {
    url = "https://github.com/LineageOS/android_kernel_xiaomi_sm8250.git";
    rev = "fb71bf0e032c5b6a7d87981a0c60772a52dd013a";
    sha256 = "sha256-eGZ9DxOJWaPgHjz/3YL3m1VQyx1HrftHMwdVpWSOE1Y=";
  };

  source.dirs."vendor/xiaomi/sm8250-common".src = fetch {
    url = "https://github.com/Ninlives/android_vendor_sm8250-common.git";
    rev = "6e505e74e8f842c90ebbfacdcb34b20cc22986f6";
    sha256 = "sha256-f0PcEf5xbHH6pOKqnd2ZmnJPHbuH99JmSlGcoSfXzRI=";
  };

  source.dirs."vendor/lineage".src = fetch {
    url = "https://github.com/LineageOS/android_vendor_lineage.git";
    rev = "9887e1f75199cb37af46f13b53b3b5a8464d8466";
    sha256 = "sha256-rtb2IFwgSSH0GSFKBhZ+SuAsZuoOngc8b5YHuQXFKVc=";
  };

  source.dirs."device/xiaomi/cmi".src = fetch {
    url = "https://github.com/Ninlives/android_device_xiaomi_cmi.git";
    rev = "d81af0769c4114404b5519409569d6d56c5af80a";
    sha256 = "sha256-O5mLPxrC/MWy9eRg7m7oc4MMvQnAYkmSdCQfyK71GLc=";
  };
  source.dirs."vendor/xiaomi/cmi".src = fetch {
    url = "https://github.com/Ninlives/android_vendor_xiaomi_cmi.git";
    rev = "39ca0278b48e19b17c7b302214717647f842b294";
    sha256 = "sha256-heWzvrZcqllxZWtysPf2XmTHEJpn8VVu4c8+5MGK1pM=";
  };
}
