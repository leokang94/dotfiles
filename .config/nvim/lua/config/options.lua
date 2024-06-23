local opt = vim.opt

-- tab/indent
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.wrap = false

-- search
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- visual
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.showmode = false

-- etc
opt.encoding = "utf-8"
opt.cmdheight = 1
opt.scrolloff = 10
opt.mouse:append("a")
opt.spell = false
opt.spelllang = "en_us,cjk"
opt.clipboard = "unnamedplus"

if vim.fn.has("nvim-0.10") == 1 then
	opt.smoothscroll = true
end

-- Folding
opt.foldlevel = 99

if vim.fn.has("nvim-0.9.0") == 1 then
	opt.statuscolumn = [[%!v:lua.require'lazyvim.util'.ui.statuscolumn()]]
	opt.foldtext = "v:lua.require'lazyvim.util'.ui.foldtext()"
end

-- HACK: causes freezes on <= 0.9, so only enable on >= 0.10 for now
if vim.fn.has("nvim-0.10") == 1 then
	opt.foldmethod = "expr"
	opt.foldexpr = "v:lua.require'lazyvim.util'.ui.foldexpr()"
	opt.foldtext = ""
	opt.fillchars = "fold: "
else
	opt.foldmethod = "indent"
end

vim.o.formatexpr = "v:lua.require'lazyvim.util'.format.formatexpr()"

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0
