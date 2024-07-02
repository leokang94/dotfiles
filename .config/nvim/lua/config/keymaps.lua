local mapKey = require("utils.keyMapper").mapKey

-- pane navigation
-- mapKey("<C-h>", ":wincmd h<CR>")
-- mapKey("<C-j>", ":wincmd j<CR>")
-- mapKey("<C-k>", ":wincmd k<CR>")
-- mapKey("<C-l>", ":wincmd l<CR>")

mapKey("<C-h>", "<C-w>h")
mapKey("<C-j>", "<C-w>j")
mapKey("<C-k>", "<C-w>k")
mapKey("<C-l>", "<C-w>l")

-- pane resize
mapKey("<C-=>", ":vertical resize +5<CR>")
mapKey("<C-->", ":vertical resize -5<CR>")
mapKey("<C-+>", ":horizontal resize +5<CR>")
mapKey("<C-_>", ":horizontal resize -5<CR>")

-- rename
mapKey("<leader>rn", function()
	return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true })

mapKey("<leader>rn", function()
	require("rip-substitute").sub()
end, { expr = true }, { "x" })

-- open nvim tree (with edgy)
mapKey("<leader>e", ":NvimTreeToggle<CR>")

-- tab navigation
mapKey("<A-Right>", ":tabnext<CR>")
mapKey("<A-Left>", ":tabprevious<CR>")
