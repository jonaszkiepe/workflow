local kanagawa = function()
    vim.cmd.colorscheme("kanagawa-wave")
end


local nvim_tmux_navigation = function()
    require("nvim-tmux-navigation").setup({
        disable_when_zoomed = true,
        keybindings = {
            left = "<M-h>",
            down = "<M-j>",
            up = "<M-k>",
            right = "<M-l>",
            last_active = "<M-\\>",
            next = "<M-Space>",
        },
    })
end


local nvim_cmp = function()
    local cmp = require("cmp")
    cmp.setup({
        completion = {
            completeopt = "menu,menuone,preview,noselect",
        },
        snippet = {
            expand = function(args)
                require("luasnip").lsp_expand(args.body)
            end,
        },
        window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["Enter"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "buffer" },
            { name = "path" },
        }),
    })
end


local mason = function()
    require("mason").setup()
end


local mason_lspconfig = function()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    require("mason").setup()
    require("mason-lspconfig").setup({
        automatic_enable = false,
    })

    local servers = require("mason-lspconfig").get_installed_servers()

    for _, server in ipairs(servers) do
        vim.lsp.config(server, {
            capabilities = capabilities,
        })
        vim.lsp.enable(server)
    end
end


local treesitter = function()
    require("nvim-treesitter.configs").setup({
        auto_install = true,
        highlight = { enable = true }
    })
end

local strudel = function()
    require("strudel").setup()
end

return {
    kanagawa = kanagawa,
    nvim_tmux_navigation = nvim_tmux_navigation,
    nvim_cmp = nvim_cmp,
    treesitter = treesitter,
    mason = mason,
    mason_lspconfig = mason_lspconfig,
    strudel = strudel,
}

