return {
  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons", -- optional dependency
    },
    opts = {
      -- configurations go here
    },
  },
  -- {
  --   "wellle/context.vim",
  -- },
  {
    "Bekaboo/dropbar.nvim",
  },
  {
    "MunifTanjim/nui.nvim",
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      { "<leader>E", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
      { "<leader>e", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
    },
  },
  -- {
  --   "romgrk/barbar.nvim",
  -- },
}
