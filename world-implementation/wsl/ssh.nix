{ config, pkgs, constant, ... }: with pkgs; let
  ss = "${pkgs.iproute2}/bin/ss";
  pageant = "${pkgs.nixos-cn.wsl2-ssh-pageant}/bin/windows_${pkgs.nixos-cn.wsl2-ssh-pageant.GOARCH}/wsl2-ssh-pageant.exe";
  socat = "${pkgs.socat}/bin/socat";
in {
  environment.interactiveShellInit = ''
    # <<<sh>>>
    if [[ -n "$__WSL_INSIDE_NIXOS" ]];then
      export GPG_TTY="$(tty)"
      export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
      if ! ${ss} -a | grep -q "$SSH_AUTH_SOCK"; then
        rm -f "$SSH_AUTH_SOCK"
        mkdir -p $(dirname $SSH_AUTH_SOCK)
        (setsid nohup ${socat} UNIX-LISTEN:"$SSH_AUTH_SOCK,fork" EXEC:"${pageant}" >/dev/null 2>&1 &)
      fi

      export GPG_AGENT_SOCK="$HOME/.gnupg/S.gpg-agent"
      export GPG_AGENT_SOCK_ALT="/run/user/$UID/gnupg/S.gpg-agent"
      if ! ${ss} -a | grep -q "$GPG_AGENT_SOCK"; then
        rm -rf "$GPG_AGENT_SOCK"
        mkdir -p $(dirname $GPG_AGENT_SOCK)
        mkdir -p $(dirname $GPG_AGENT_SOCK_ALT)
        (setsid nohup ${socat} UNIX-LISTEN:"$GPG_AGENT_SOCK,fork" EXEC:"${pageant} --gpg S.gpg-agent" >/dev/null 2>&1 &)
        (setsid nohup ${socat} UNIX-LISTEN:"$GPG_AGENT_SOCK_ALT,fork" EXEC:"${pageant} --gpg S.gpg-agent" >/dev/null 2>&1 &)
      fi
    fi
    # >>>sh<<<
  '';
  programs.ssh.extraConfig = ''
    Host *
      ForwardAgent yes
  '';
}
