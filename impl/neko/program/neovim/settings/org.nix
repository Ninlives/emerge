{lib, ...}: let
  inherit (lib.hm.dag) entryAfter;
in {
  programs.neovim.settings.org = entryAfter ["tree-sitter" "which-key"] {
    plugins = p: with p; [orgmode];
    lua =
      /*
      lua
      */
      ''
        vim.o.conceallevel = 1
        local now = require('orgmode.objects.date'):now()
        local orgmode = require('orgmode')
        orgmode.setup({
          org_agenda_files = {'~/Documents/Org/**/*'},
          org_default_notes_file = '~/Documents/Org/refile.org',
          win_split_mode = 'float',
          org_capture_templates = {
            t = { description = 'Task', template = '* TODO %?\n  %u', target = '~/Documents/Org/todo.org' },
            l = {
              description = 'Logging',
              template = '* %?\n  %T',
              target = string.format('~/Documents/Org/logging/%sww%s.org', now['year'], now:get_week_number())
            }
          }
        })
        require('nvim-treesitter.configs').setup {
          highlight = {
            additional_vim_regex_highlighting = {'org'},
          },
        }
      '';
  };
}
