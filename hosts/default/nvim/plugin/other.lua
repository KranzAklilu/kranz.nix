-- Lualine
require("lualine").setup({
    icons_enabled = true,
    theme = 'onedark',
})

-- Colorscheme
vim.cmd.colorscheme 'carbonfox'

-- Comment
require("Comment").setup()
