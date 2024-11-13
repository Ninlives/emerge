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
        require('which-key').add({
          { "<leader>b", group = "buffer" },
          { "<leader>b1", ":b1<CR>", desc = "buffer 1" },
          { "<leader>b2", ":b2<CR>", desc = "buffer 2" },
          { "<leader>b?", ":Buffers<CR>", desc = "fzf-buffer" },
          { "<leader>bd", ":bd<CR>", desc = "delete-buffer" },
          { "<leader>bf", ":bfirst<CR>", desc = "first-buffer" },
          { "<leader>bl", ":blast<CR>", desc = "last-buffer" },
          { "<leader>bn", ":bnext<CR>", desc = "next-buffer" },
          { "<leader>bp", ":bprevious<CR>", desc = "previous-buffer" },

          { "<leader>t", group = "tab" },
          { "<leader>tc", ":tabc<CR>", desc = "close-tab" },
          { "<leader>te", ":tabnew<CR>", desc = "new-tab" },
          { "<leader>tf", ":tabf<CR>", desc = "first-tab" },
          { "<leader>tl", ":tabl<CR>", desc = "last-tab" },
          { "<leader>tm", group = "move" },
          { "<leader>tmj", ":-tabm<CR>", desc = "move-tab-left" },
          { "<leader>tmk", ":+tabm<CR>", desc = "move-tab-right" },
          { "<leader>to", ":tabo<CR>", desc = "close-other-tabs" },
          { "<leader>tp", ":tabp<CR>", desc = "previous-tab" },
          { "<leader>tt", ":tabn<CR>", desc = "next-tab" },

          { "<leader>w", group = "window" },
          { "<leader>w=", "<C-W>=", desc = "balance-window" },
          { "<leader>wH", "<C-W>5<", desc = "expand-window-left" },
          { "<leader>wJ", ":resize +5<CR>", desc = "expand-window-below" },
          { "<leader>wK", ":resize -5<CR>", desc = "expand-window-up" },
          { "<leader>wL", "<C-W>5>", desc = "expand-window-right" },
          { "<leader>we", group = "new" },
          { "<leader>weh", ":new<CR>", desc = "new-window-horizontal" },
          { "<leader>wev", ":vnew<CR>", desc = "new-window-vertical" },
          { "<leader>wh", "<C-W>h", desc = "window-left" },
          { "<leader>wj", "<C-W>j", desc = "window-below" },
          { "<leader>wk", "<C-W>k", desc = "window-up" },
          { "<leader>wl", "<C-W>l", desc = "window-right" },
          { "<leader>wm", group = "move" },
          { "<leader>wmr", "<C-W>r", desc = "rotate-window" },
          { "<leader>wmx", "<C-W>x", desc = "exchange-window" },
          { "<leader>wo", ":only<CR>", desc = "close-other-windows" },
          { "<leader>ws", group = "split" },
          { "<leader>wsh", ":split<CR>", desc = "split-window-horizontal" },
          { "<leader>wsv", ":vsplit<CR>", desc = "split-window-vertical" },
          { "<leader>ww", "<C-W>w", desc = "next-window" },
        })
      '';
  };
}
