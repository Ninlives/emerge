{
  lib,
  ...
}: let
  inherit (lib.hm.dag) entryAfter;
in {
  programs.neovim.settings.which-key = entryAfter ["basic"] {
    plugins = p: [p.which-key-nvim];

    lua = /* lua */ ''
      vim.o.timeoutlen = 0
      require('which-key').register({
        b = {
          name = "+buffer" ,
            ["1"] = { "b1",     "buffer 1" },
            ["2"] = { "b2",     "buffer 2" },
            d     = { "bd",     "delete-buffer" },
            f     = { "bfirst", "first-buffer" },
            l     = { "blast",  "last-buffer" },
            n     = { "bnext",  "next-buffer" },
            p     = { "bprevious", "previous-buffer" },
            ["?"] = { "Buffers",   "fzf-buffer" },
        },

        t = {
          name = "+tab",
          e = { "tabnew", "new-tab" },
          c = { "tabc", "close-tab" },
          o = { "tabo", "close-other-tabs" },
          t = { "tabn", "next-tab" },
          p = { "tabp", "previous-tab" },
          f = { "tabf", "first-tab" },
          l = { "tabl", "last-tab" },
          m = {
            name = "+move",
            j = { "-tabm", "move-tab-left" },
            k = { "+tabm", "move-tab-right" },
          }
        },

        w = {
          name = "+window",
          e = {
            name = "+new",
            h = { "new", "new-window-horizontal" },
            v = { "vnew", "new-window-vertical" },
          },
          s = {
            name = "+split",
            h = { "split", "split-window-horizontal" },
            v = { "vsplit", "split-window-vertical" },
          },
          o = { "only", "close-other-windows" },
          w = { "<C-W>w", "next-window" },
          h = { "<C-W>h", "window-left" },
          j = { "<C-W>j", "window-below" },
          l = { "<C-W>l", "window-right" },
          k = { "<C-W>k", "window-up" },
          H = { "<C-W>5<", "expand-window-left" },
          J = { ":resize +5", "expand-window-below" },
          L = { "<C-W>5>", "expand-window-right" },
          K = { ":resize -5", "expand-window-up" },
          ["="] = { "<C-W>=", "balance-window" },
          m = {
            name = "+move",
            r = { "<C-W>r", "rotate-window" },
            x = { "<C-W>x", "exchange-window" },
          }
        }
      }, { prefix = "<leader>" })
    '';
  };
}
