return {
  { "echasnovski/mini.comment", enabled = false },
  {
    "numToStr/Comment.nvim",
    opts = {
      -- add any options here
    },
    cofig = function()
      require("Comment").setup()
    end,
    lazy = false,
  },
}
