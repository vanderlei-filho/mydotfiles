return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",          -- Lua
          "pyright",         -- Python
          "jedi_language_server", -- Python
          "clangd",          -- C and C++
          "texlab",          -- Latex
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")

      -- Auto-formatting setup
      local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

      local function setup_format_on_save(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ bufnr = bufnr })
            end,
          })
        end
      end

      -- Configure LSPs with auto-formatting on save:
      -- Lua
      lspconfig.lua_ls.setup({
        on_attach = function(client, bufnr)
          setup_format_on_save(client, bufnr)
        end,
      })

      -- Python
      lspconfig.pyright.setup({})
      lspconfig.jedi_language_server.setup({
        on_attach = function(client, bufnr)
          setup_format_on_save(client, bufnr)
        end,
      })

      -- C/C++
      lspconfig.clangd.setup({
        cmd = {
          "clangd",
          "--background-index",
          "--suggest-missing-includes",
          "--header-insertion=iwyu",
          "--query-driver=/Library/Developer/CommandLineTools/usr/bin/cc*,/usr/local/bin/mpic*,/opt/homebrew/bin/mpic*",
        },
        on_attach = function(client, bufnr)
          setup_format_on_save(client, bufnr)
        end,
      })

      -- Rust
      lspconfig.rust_analyzer.setup({
        on_attach = function(client, bufnr)
          setup_format_on_save(client, bufnr)
        end,
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy",
            },
            inlayHints = {
              parameterHints = true,
              typeHints = true,
            },
          },
        },
      })

      -- Latex
      lspconfig.texlab.setup({
        on_attach = function(client, bufnr)
          -- Enable diagnostics but avoid conflicts with Vimtex build
          client.server_capabilities.documentFormattingProvider = true
          setup_format_on_save(client, bufnr)
        end,
        settings = {
          texlab = {
            build = {
              executable = "latexmk",
              args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
              onSave = false, -- Disable automatic builds (Vimtex will handle this)
            },
            forwardSearch = {
              executable = "", -- Disable texlab forward search to avoid conflicts with Vimtex
            },
            lint = {
              onChange = true, -- Enable real-time diagnostics for errors and warnings
            },
          },
        },
      })

      -- Keymaps
      vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "Show LSP definition" })
      vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Show LSP code action" })
      vim.keymap.set("n", "<leader>lf", function()
        vim.lsp.buf.format({ async = true })
      end, { desc = "Format buffer using LSP" }) -- Manual formatting
    end,
  },
}
