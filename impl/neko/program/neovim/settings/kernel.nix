{lib, ...}: let
  inherit (lib.hm.dag) entryAfter;
in {
  programs.neovim.settings.c = entryAfter ["basic"] {
    config =
      /*
      vim
      */
      ''
        autocmd BufNewFile,BufRead *.c,*.h,*.patch set tabstop=8 | set noexpandtab
      '';
  };
}