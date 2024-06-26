return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = function(_, opts)
      vim.filetype.add({
        -- Detect and apply filetypes based on certain patterns of the filenames
        pattern = {
          -- INFO: Match filenames like - ".env.example", ".env.local" and so on
          ["%.env%.[%w_.-]+"] = "sh",
        },
      })
    end,
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = {
          "lua",
          "javascript",
          "typescript",
          "tsx",
          "jsdoc",
          "styled",
          "css",
          "html",
          "json",
          "markdown",
          "markdown_inline",
          "bash",
          "vim",
          "yaml",
          "regex",
          "git_config",
          "git_rebase",
          "gitattributes",
          "gitcommit",
          "gitignore",
        },
        sync_install = false,
        highlight = {
          enable = true,
        },
        indent = { enable = true },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    after = "nvim-treesitter",
    config = function()
      require("treesitter-context").setup({})
    end,
  },
  {},
}
