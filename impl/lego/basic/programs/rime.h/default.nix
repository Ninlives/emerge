{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (pkgs) coreutils librime rime-data writeShellScript;
  inherit (lib.generators) toYAML;
in {
  xdg.configFile = {
    "ibus/rime/default.custom.yaml".text =
      toYAML {} {patch.schema_list = [{schema = "luna_pinyin";}];};
    "ibus/rime/luna_pinyin.custom.yaml".text =
      toYAML {} {patch."translator/dictionary" = "luna_pinyin.extended";};
    "ibus/rime/luna_pinyin.extended.dict.yaml".text = toYAML {} {
      name = "luna_pinyin.extended";
      version = "1.0";
      sort = "by_weight";
      use_preset_vocabulary = true;
      import_tables = ["luna_pinyin" "zhwiki"];
    };
    "ibus/rime/zhwiki.dict.yaml".source = inputs.data.content.zhwiki-dict;
  };

  systemd.user.services.deploy-rime = {
    Unit = {
      Description = "Deploy rime";
    };

    Install = {WantedBy = ["default.target"];};

    Service = {
      ExecStart = "${writeShellScript "deploy" ''
        if [[ -d "${config.xdg.configHome}/ibus/rime/build" ]];then
          ${coreutils}/bin/rm -rf ${config.xdg.configHome}/ibus/rime/build
        fi
        ${librime}/bin/rime_deployer --build '${config.xdg.configHome}/ibus/rime' '${rime-data}/share/rime-data' '${config.xdg.configHome}/ibus/rime/build'
      ''}";
      Type = "oneshot";
    };
  };

  persistent.boxes = [
    {
      src = /Programs/rime;
      dst = ".config/ibus/rime";
    }
  ];
}
