{ inputs, nixosConfig, lib, config, pkgs, ... }:
with lib;
let
  email = inputs.values.secret.email.${nixosConfig.workspace.email.account.default};
  gruvbox = pkgs.fetchFromGitHub {
    owner = "shuber2";
    repo = "mutt-gruvbox";
    rev = "91853cfee609ecad5d2cb7dce821a7dfe6d780ef";
    sha256 = "sha256-TFxVG2kp5IDmkhYuzhprEz2IE28AEMAi/rUHILa7OPU=";
  };
in {
  programs.neomutt = {
    enable = mkIf email.imap.enable true;
    vimKeys = true;
    settings = {
      pager = "'${config.programs.neovim.finalPackage}/bin/nvim -R'";
      prompt_after = "no";
    };
    extraConfig = ''
      source ${gruvbox}/colors-gruvbox-shuber.muttrc
      source ${gruvbox}/colors-gruvbox-shuber-extended.muttrc
    '';
  };
}
