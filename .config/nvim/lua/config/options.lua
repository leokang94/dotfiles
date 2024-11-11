local opt = vim.opt

-- tab/indent
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
opt.linebreak = true
opt.breakindent = true

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
opt.scrolloff = 5
opt.mouse:append("a")
opt.spell = false
opt.spelllang = "en_us,cjk"
opt.clipboard = "unnamedplus"

opt.updatetime = 250
opt.guicursor = {
	"n-v-c:block",
	"i-ci-ve:ver25",
	"r-cr:hor20",
	"o:hor50",
	"a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor",
	"sm:block-blinkwait175-blinkoff150-blinkon175",
}

-- keymapping delay
opt.timeoutlen = 1000
opt.ttimeoutlen = 10
opt.smoothscroll = true

-- Folding
opt.foldlevel = 99

opt.foldmethod = "expr"
opt.foldexpr = "v:lua.require'lazyvim.util'.ui.foldexpr()"
opt.foldtext = ""
opt.fillchars = "fold: "

vim.o.formatexpr = "v:lua.require'lazyvim.util'.format.formatexpr()"

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0
