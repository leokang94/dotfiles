local mapKey = require("utils.keyMapper").mapKey

-- pane navigation
mapKey("<C-h>", ":wincmd h<CR>")
mapKey("<C-j>", ":wincmd j<CR>")
mapKey("<C-k>", ":wincmd k<CR>")
mapKey("<C-l>", ":wincmd l<CR>")

-- open nvim tree (with edgy)
mapKey("<leader>e", function()
	require("edgy").toggle()
end)
