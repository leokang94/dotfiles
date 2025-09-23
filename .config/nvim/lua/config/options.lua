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
vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

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
vim.wo.foldlevel = 99
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"

vim.o.formatexpr = "v:lua.require'lazyvim.util'.format.formatexpr()"

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

vim.opt.diffopt = {
	"internal", -- 내부 diff 알고리즘 사용
	"filler", -- 변경되지 않은 줄에 대해서도 빈 줄을 채워 표시
	"closeoff", -- diff 영역이 끝날 때, 변경되지 않은 줄을 완전히 숨기지 않고 약간의 컨텍스트를 제공
	"context:12", -- 변경된 줄 주변으로 12줄의 컨텍스트를 표시
	"algorithm:histogram", -- diff 알고리즘으로 histogram 방식 사용
	"linematch:200", -- (git diff의 linematch와 유사) 줄 단위로 변경된 블록을 찾을 때, 200줄 이내에서 일치하는 줄을 찾아 더 정확하게 비교
	"indent-heuristic", -- 들여쓰기 변경을 감지하여 diff를 더 효율적으로 표시
	-- "iwhite",   -- 공백 문자 변경을 무시 (토글 가능)
}
