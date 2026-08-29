-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Deno LSP: only attaches in folders that have deno.json / deno.jsonc
        denols = {
          root_dir = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc"),
        },
        -- vtsls (LazyVim's default TS server): must NOT attach where denols does
        vtsls = {
          root_dir = require("lspconfig.util").root_pattern("package.json"),
          single_file_support = false,
        },
      },
    },
  },
}
