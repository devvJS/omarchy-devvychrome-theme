-- Devvychrome Neovim colorscheme entry point.
--
-- This file is symlinked from ~/.config/nvim/lua/plugins/theme.lua via
-- ~/.config/omarchy/current/theme/neovim.lua. Lazy.nvim detects the
-- file change when omarchy-theme-set is run and fires LazyReload, which
-- the omarchy-theme-hotreload plugin handles.
--
-- The colorscheme itself lives in colors/devvychrome.lua, installed to
-- ~/.config/nvim/colors/devvychrome.lua. No external plugin is required.

return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "devvychrome",
    },
  },
}
