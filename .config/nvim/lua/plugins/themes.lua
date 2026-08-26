return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = true,
        float = {
          transparent = true,
          solid = false,
        },
      })
    end,
  },
  {
    "NTBBloodbath/doom-one.nvim",
    config = function()
      -- Enable transparent background
      vim.g.doom_one_transparent_background = true
      -- Pumblend transparency
      vim.g.doom_one_pumblend_enable = true
      vim.g.doom_one_pumblend_transparency = 0
    end,
  },
  {
    "Mofiqul/dracula.nvim",

    config = function()
      require("dracula").setup({
        show_end_of_buffer = true, -- default false
        transparent_bg = true, -- default false
        italic_comment = true, -- default false
        overrides = {},
      })
    end,
  },
  {
    "sainnhe/everforest",
    config = function()
      vim.g.everforest_enable_italic = 1
      vim.g.everforest_transparent_background = 1
      vim.g.everforest_disable_background = 1
    end,
  },
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = true,
    opts = {
      transparent_mode = true,
      contrast = "soft",
    },
  },
  {
    "rebelot/kanagawa.nvim",
    opts = {
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none",
            },
          },
        },
      },
      transparent = true,
      terminalColors = false,
      overrides = function()
        return {
          -- Main UI
          Normal = { bg = "none" },
          NormalNC = { bg = "none" },
          SignColumn = { bg = "none" },
          LineNr = { bg = "none" },
          CursorLineNr = { bg = "none" },
          VertSplit = { bg = "none" },

          -- Floating windows
          NormalFloat = { bg = "none" },
          FloatBorder = { bg = "none" },

          -- Sidebars
          NvimTreeNormal = { bg = "none" },
          NvimTreeNormalNC = { bg = "none" },
          TelescopeNormal = { bg = "none" },
          TelescopeBorder = { bg = "none" },

          -- Statusline / Winbar
          StatusLine = { bg = "#282727" },
          StatusLineNC = { bg = "none" },
          WinBar = { bg = "none" },
          WinBarNC = { bg = "none" },
        }
      end,
      theme = "dragon",
      background = {
        dark = "dragon",
        light = "lotus",
      },
    },
  },
  {
    "marko-cerovac/material.nvim",
    opts = {
      disable = {
        background = true,
      },
    },
  },
  {
    "loctvl842/monokai-pro.nvim",
    config = function()
      require("monokai-pro").setup({
        transparent_background = true,
        terminal_colors = true,
        devicons = true, -- highlight the icons of `nvim-web-devicons`
        styles = {
          comment = { italic = true },
          keyword = { italic = true }, -- any other keyword
          type = { italic = true }, -- (preferred) int, long, char, etc
          storageclass = { italic = true }, -- static, register, volatile, etc
          structure = { italic = true }, -- struct, union, enum, etc
          parameter = { italic = true }, -- parameter pass in function
          annotation = { italic = true },
          tag_attribute = { italic = true }, -- attribute of tag in reactjs
        },
        filter = "spectrum", -- classic | octagon | pro | machine | ristretto | spectrum
        -- Enable this will disable filter option
        day_night = {
          enable = false, -- turn off by default
          day_filter = "pro", -- classic | octagon | pro | machine | ristretto | spectrum
          night_filter = "spectrum", -- classic | octagon | pro | machine | ristretto | spectrum
        },
        inc_search = "background", -- underline | background
        background_clear = {
          "float_win",
          "toggleterm",
          "telescope",
          "which-key",
          "renamer",
          "notify",
          "float_win",
          "toggleterm",
          "telescope",
          "which-key",
          "renamer",
          "neo-tree",
          "nvim-tree",
          "bufferline",
        },
        plugins = {
          bufferline = {
            underline_selected = false,
            underline_visible = false,
          },
          indent_blankline = {
            context_highlight = "default", -- default | pro
            context_start_underline = false,
          },
        },
      })
    end,
  },
  {
    "AlexvZyl/nordic.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("nordic").setup({
        on_palette = function() end,
        after_palette = function() end,
        on_highlight = function() end,
        bold_keywords = false,
        italic_comments = true,
        transparent = {
          bg = true,
          float = true,
        },
      })
    end,
  },
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
      require("onedark").setup({
        style = "darker",
        transparent = true,
      })
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      styles = {
        bold = true,
        italic = true,
        transparency = true,
      },
    },
  },
  {
    "maxmx03/solarized.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = {
        enabled = true, -- Master switch to enable transparency
        pmenu = true, -- Popup menu (e.g., autocomplete suggestions)
        normal = true, -- Main editor window background
        normalfloat = true, -- Floating windows
        neotree = true, -- Neo-tree file explorer
        nvimtree = true, -- Nvim-tree file explorer
        whichkey = true, -- Which-key popup
        telescope = true, -- Telescope fuzzy finder
        lazy = true, -- Lazy plugin manager UI
        mason = true, -- Mason manage external tooling
      },
    },
  },
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("solarized-osaka").setup({
        transparent = true,
        terminal_colors = false,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          sidebars = "transparent", -- style for sidebars, see below
          floats = "transparent", -- style for floating windows
        },
        on_colors = function() end,
        on_highlights = function() end,
      })
    end,
  },
  {
    "tiagovla/tokyodark.nvim",
    opts = {
      transparent_background = true,
    },
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = true, -- Enable this to disable setting the background color
      terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
      styles = {
        -- Background styles. Can be "dark", "transparent" or "normal"
        sidebars = "transparent", -- style for sidebars, see below
        floats = "transparent", -- style for floating windows
      },
    },
  },
  {
    "tiesen243/vercel.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("vercel").setup({
        theme = "dark", -- String: Sets the theme to light or dark (Default: light)
        transparent = true, -- Boolean: Sets the background to transparent (Default: false)
        italics = {
          comments = true, -- Boolean: Italicizes comments (Default: true)
          keywords = true, -- Boolean: Italicizes keywords (Default: true)
          functions = true, -- Boolean: Italicizes functions (Default: true)
          strings = true, -- Boolean: Italicizes strings (Default: true)
          variables = true, -- Boolean: Italicizes variables (Default: true)
          bufferline = false, -- Boolean: Italicizes bufferline (Default: false)
        },
        overrides = {}, -- A dictionary of group names, can be a function returning a dictionary or a table.
      })
    end,
  },
  {
    "Gentleman-Programming/gentleman-kanagawa-blur",
    name = "gentleman-kanagawa-blur",
    priority = 1000,
    opts = {
      variant = "blur",
    },
  },
  {
    "sainnhe/gruvbox-material",
    config = function()
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_transparent_background = 1
      vim.g.gruvbox_material_disable_background = 1
    end,
  },
  {
    "ember-theme/nvim",
    name = "ember",
    priority = 1000,
    config = function()
      require("ember").setup({
        variant = "ember",
        styles = {
          comments = { italic = true },
          keywords = { bold = true },
          functions = {},
          types = { bold = true },
        },
        transparent = true, -- transparent editor background
        transparent_floats = nil, -- follows `transparent` by default; set explicitly to override
        dark_variant = "ember", -- used by `ember-auto` when background = "dark"
        light_variant = "ember-light", -- used by `ember-auto` when background = "light"
        on_colors = nil, -- function(palette) - modify palette before theme builds
        on_highlights = nil, -- function(highlights, theme) - modify highlight groups
      })
    end,
  },
  {
    "ficcdaf/ashen.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
    },
  },
  {
    "datsfilipe/vesper.nvim",
    name = "vesper",
    lazy = false,
    priority = 1000,
    config = function()
      require("vesper").setup({
        transparent = true,
      })
    end,
  },
  {
    "EdenEast/nightfox.nvim",
    name = "nightfox",
    lazy = false,
    priority = 1000,
    config = function()
      require("nightfox").setup({
        options = {
          transparent = true,
          terminal_colors = false,
        },
      })
    end,
  },
  {
    "sainnhe/sonokai",
    name = "sonokai",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.sonokai_transparent_background = 1
      vim.g.sonokai_disable_background = 1
    end,
  },
  {
    "OldJobobo/retro-82.nvim",
    priority = 1000,
    config = function()
      require("retro82").setup({
        transparent = true,
        terminal_colors = false,
      })
    end,
  },
  {
    "ribru17/bamboo.nvim",
    name = "bamboo",
    lazy = false,
    priority = 1000,
    config = function()
      require("bamboo").setup({
        transparent = true,
      })
      require("bamboo").load()
    end,
  },
  {
    "uhs-robert/oasis.nvim",
    name = "oasis",
    priority = 1000,
    config = function()
      require("oasis").setup({
        transparent = true,
      })
    end,
  },
}
