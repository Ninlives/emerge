{ config, pkgs, lib, var, nixosConfig, ... }:
with pkgs;
let
  inherit (lib) optionalAttrs optionalString;
  inherit (var.proxy) address port;
  inherit (config.home) homeDirectory;
  histdb = fetchFromGitHub {
    owner = "larkery";
    repo = "zsh-histdb";
    rev = "30797f0c50c31c8d8de32386970c5d480e5ab35d";
    sha256 = "sha256-PQIFF8kz+baqmZWiSr+wc4EleZ/KD8Y+lxW2NT35/bg=";
  };
in {
  home.packages = [ sqlite ];
  home.file.".bashrc".text = ''
    export HISTFILE=${homeDirectory}/.local/history/bash_history
  '';
  home.file.".bash_profile".text = ''
    exec ${zsh}/bin/zsh
  '';
  persistent.boxes = [
    {
      src = /Programs/shell/history;
      dst = ".local/history";
    }
    {
      src = /Programs/shell/zsh/z;
      dst = ".local/z";
    }
    {
      src = /Programs/shell/zsh/config;
      dst = ".config/zsh";
    }
  ];

  programs = {
    zsh = rec {
      enable = true;
      dotDir = ".config/zsh";
      enableCompletion = true;
      enableAutosuggestions = true;
      history.path = "${homeDirectory}/.local/history/zsh_history";

      shellAliases = {
        vdiff = "nvim -d";
        etr = "trans en:zh -shell";
        ztr = "trans zh:en -shell";
        axel = "axel -n 128 -a";
        a = "ranger";
        ssr = "all_proxy=socks5://${address}:${toString port.local}";
        open = "xdg-open";
      };

      sessionVariables = {
        HISTDB_FILE = "${homeDirectory}/${dotDir}/zsh-history.db";
        _ZL_DATA = "${homeDirectory}/${dotDir}/zlua";
      };

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "extract"
          "colored-man-pages"
        ];

        custom = toString (runCommandLocal "custom" { redirPort = port.redir; } ''
          mkdir -p $out
          cp -r ${./config}/. $out/.
          find $out -type f -print0 | while read -d "" f;do
            substituteAllInPlace "$f"
          done
        '');
        theme = "lam";
      };

      initExtra = ''
        ${optionalString nixosConfig.services.xserver.enable "${keyutils}/bin/keyctl new_session shell > /dev/null"}
        # <<<sh>>>
        source ${zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        source ${zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
        source ${zsh-autopair}/share/zsh/zsh-autopair/autopair.zsh
        source ${histdb}/sqlite-history.zsh
        ZVM_INIT_MODE=sourcing
        source ${zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

        ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_UNDERLINE
        ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
        ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_BEAM

        _zsh_autosuggest_strategy_histdb_top() {
          local query="select commands.argv from
                       history left join commands on history.command_id = commands.rowid
                       left join places on history.place_id = places.rowid
                       where commands.argv LIKE '$(sql_escape $1)%' and history.exit_status = 0
                       order by places.dir != '$(sql_escape $PWD)', history.start_time desc limit 1"
          suggestion=$(_histdb_query "$query")
        }
        ZSH_AUTOSUGGEST_STRATEGY=histdb_top

        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down
        zvm_bindkey vicmd 'k' history-substring-search-up
        zvm_bindkey vicmd 'j' history-substring-search-down
        # >>>sh<<<
      '';

    };
    z-lua = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
