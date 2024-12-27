-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
-- clangd fix
vim.g.neovide_transparency = 0.6
vim.g.neovide_window_blurred = true
-- floating window
vim.g.neovide_floating_shadow = true
vim.g.neovide_floating_z_height = 10
vim.g.neovide_light_angle_degrees = 45
vim.g.neovide_light_radius = 5

vim.opt.termguicolors = true

-- for neovide gui clipboard copy & paste support
vim.cmd([[
  " system clipboard
  nmap <c-S-c> "+y
  vmap <c-S-c> "+y
  nmap <c-S-v> "+p
  inoremap <c-S-v> <c-S-r>+
  cnoremap <c-S-v> <c-S-r>+
  " use <c-r> to insert original character without triggering things like auto-pairs
  inoremap <c-S-r> <c-S-v>

  ]])

require("lspconfig").clangd.setup({
  cmd = {
    "clangd",
    "--offset-encoding=utf-16",
  },
})
