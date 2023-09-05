{
  inputs,
  pkgs,
  ...
}: let
  email = inputs.values.secret.email.opensource;
in {
  programs = {
    git = {
      enable = true;
      userName = email.name;
      userEmail = email.address;
      extraConfig = {
        commit.template = builtins.toFile "template" ''
          ##################################################

          ########################################################################


          Signed-off-by: "${email.name}" <${email.address}>
        '';
        sendemail.thread = true;
        sendemail.chainReplyTo = false;
        sendemail.sendmailcmd = "${pkgs.msmtp}/bin/sendmail";
      };
    };
  };
}
