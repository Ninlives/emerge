{ pkgs, nixosConfig, lib, ... }:
let
  inherit (pkgs) touchegg writeShellScript crow-translate dbus substituteAll;
  translate = writeShellScript "translate" ''
    ${dbus}/bin/dbus-send --session --type=method_call --dest=io.crow_translate.CrowTranslate /io/crow_translate/CrowTranslate/MainWindow io.crow_translate.CrowTranslate.MainWindow.translateSelection
  '';
in lib.mkIf nixosConfig.services.xserver.enable {
  xdg.configFile = {
    "autostart/touchegg.desktop".source =
      "${touchegg}/etc/xdg/autostart/touchegg.desktop";
    "autostart/crow.desktop".source =
      "${crow-translate}/share/applications/io.crow_translate.CrowTranslate.desktop";
    "touchegg/touchegg.conf".source = substituteAll {
      src = ./file/touchegg/conf.xml;
      inherit translate;
    };
  };

  home.packages = [ crow-translate ];
  persistent.boxes = [{
    src = /Programs/crow-translate;
    dst = ".config/Crow Translate";
  }];
}
