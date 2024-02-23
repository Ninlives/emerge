{lib, ...}: let
  inherit (lib.hm.dag) entryAfter;
in {
  programs.neovim.settings.which-key = entryAfter ["basic"] {
    plugins = p: [p.which-key-nvim];

    lua =
      /*
      lua
      */
      ''
        vim.o.timeoutlen = 0
        require('which-key').register({
          b = {
            name = "+buffer" ,
              ["1"] = { ":b1<CR>",     "buffer 1" },
              ["2"] = { ":b2<CR>",     "buffer 2" },
              d     = { ":bd<CR>",     "delete-buffer" },
              f     = { ":bfirst<CR>", "first-buffer" },
              l     = { ":blast<CR>",  "last-buffer" },
              n     = { ":bnext<CR>",  "next-buffer" },
              p     = { ":bprevious<CR>", "previous-buffer" },
              ["?"] = { ":Buffers<CR>",   "fzf-buffer" },
          },

          t = {
            name = "+tab",
            e = { ":tabnew<CR>", "new-tab" },
            c = { ":tabc<CR>", "close-tab" },
            o = { ":tabo<CR>", "close-other-tabs" },
            t = { ":tabn<CR>", "next-tab" },
            p = { ":tabp<CR>", "previous-tab" },
            f = { ":tabf<CR>", "first-tab" },
            l = { ":tabl<CR>", "last-tab" },
            m = {
              name = "+move",
              j = { ":-tabm<CR>", "move-tab-left" },
              k = { ":+tabm<CR>", "move-tab-right" },
            }
          },

          w = {
            name = "+window",
            e = {
              name = "+new",
              h = { ":new<CR>", "new-window-horizontal" },
              v = { ":vnew<CR>", "new-window-vertical" },
            },
            s = {
              name = "+split",
              h = { ":split<CR>", "split-window-horizontal" },
              v = { ":vsplit<CR>", "split-window-vertical" },
            },
            o = { ":only<CR>", "close-other-windows" },
            w = { "<C-W>w", "next-window" },
            h = { "<C-W>h", "window-left" },
            j = { "<C-W>j", "window-below" },
            l = { "<C-W>l", "window-right" },
            k = { "<C-W>k", "window-up" },
            H = { "<C-W>5<", "expand-window-left" },
            J = { ":resize +5<CR>", "expand-window-below" },
            L = { "<C-W>5>", "expand-window-right" },
            K = { ":resize -5<CR>", "expand-window-up" },
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
