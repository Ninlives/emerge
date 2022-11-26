{ config, pkgs, ... }: {
  # programs.gnupg.agent.enable = true;
  # programs.gnupg.agent.enableSSHSupport = true;
  services.pcscd.enable = true;
  # environment.shellInit = ''
  #   export GPG_TTY="$(tty)"
  #   gpg-connect-agent /bye
  #   export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  # '';

  services.udev.packages = [ pkgs.yubikey-personalization ];
}
