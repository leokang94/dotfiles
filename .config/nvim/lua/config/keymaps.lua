local mapKey = require("utils.keyMapper").mapKey

-- pane navigation
mapKey("<C-A-h>", "<C-w>h")
mapKey("<C-A-j>", "<C-w>j")
mapKey("<C-A-k>", "<C-w>k")
mapKey("<C-A-l>", "<C-w>l")

-- pane resize
mapKey("<C-A->>", ":vertical resize +5<CR>")
mapKey("<C-A-<>", ":vertical resize -5<CR>")
mapKey("<C-A-=>", ":horizontal resize +5<CR>")
mapKey("<C-A-->", ":horizontal resize -5<CR>")

-- open nvim tree (with edgy)
mapKey("<leader>e", ":NvimTreeToggle<CR>")

-- tab navigation
mapKey("<A-Right>", ":tabnext<CR>")
mapKey("<A-Left>", ":tabprevious<CR>")
