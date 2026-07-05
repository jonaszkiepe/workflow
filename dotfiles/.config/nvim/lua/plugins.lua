local config = require("configs")
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
}) end
vim.opt.rtp:prepend(lazypath)


require("lazy").setup({
    {
        "jonaszkiepe/kanagawa.nvim",
        config = config.kanagawa
    },
	{
        "alexghergh/nvim-tmux-navigation",
        config = config.nvim_tmux_navigation
    },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "plenary.nvim" },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = config.treesitter
    },
	{
        "williamboman/mason.nvim",
        config = config.mason,
    },
	{
        "williamboman/mason-lspconfig.nvim",
        config = config.mason_lspconfig,
        dependencies = { "mason.nvim" }},
    {
        "neovim/nvim-lspconfig",
        dependencies = { "cmp-nvim-lsp", "nvim-lsp-file-operations" }
    },
    {
        "hrsh7th/nvim-cmp",
        config = config.nvim_cmp,
        dependencies = {"cmp-buffer", "cmp-path", "l3mon4d3/luasnip"}
    },
    {
        "lervag/vimtex",
        lazy = false,
        init = function()
            vim.g.vimtex_view_method = "zathura"
        end
    },
    {
      "gruvw/strudel.nvim",
      build = "npm ci",
    config = config.strudel,
    },
})
