return {
  {
    "folke/snacks.nvim",
    -- Make all snacks floating UI (picker, input) fully transparent
    init = function()
      local function transparent()
        -- Make the tree connector/guide lines themselves invisible
        vim.api.nvim_set_hl(0, "SnacksPickerTree", { fg = "NONE", bg = "NONE" })
        -- Directory icon fallback (used when mini.icons is unavailable)
        vim.api.nvim_set_hl(0, "Directory", { bg = "NONE" })
      end
      -- Run on ColorScheme (theme switches) and once at VimEnter, which fires
      -- during startup *before* the first redraw, so there is no visible flash.
      vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
        pattern = "*",
        callback = transparent,
      })
    end,
    opts = {
      picker = {
        sources = {
          explorer = {
            layout = { layout = { position = "right" } },
          },
        },
      },
      dashboard = {
        preset = {
          header = [[
   ▄████████    ▄████████  ▄████████    ▄█    █▄    
  ███    ███   ███    ███ ███    ███   ███    ███   
  ███    ███   ███    ███ ███    █▀    ███    ███   
  ███    ███  ▄███▄▄▄▄██▀ ███         ▄███▄▄▄▄███▄▄ 
▀███████████ ▀▀███▀▀▀▀▀   ███        ▀▀███▀▀▀▀███▀  
  ███    ███ ▀███████████ ███    █▄    ███    ███   
  ███    ███   ███    ███ ███    ███   ███    ███   
  ███    █▀    ███    ███ ████████▀    ███    █▀    
               ███    ███                           
   ]],
        },
      },
    },
  },

  {
    "akinsho/bufferline.nvim",
    enabled = true,
  },

  -- Smooth cursor (buggy)
  -- {
  --   "sphamba/smear-cursor.nvim",
  --   opts = {},
  -- },
}
