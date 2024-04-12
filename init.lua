-- Variables
local icons = { default_icon = { icon = "󰈚", name = "Default" } }

-- Global settings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.airline_powerline_fonts = 1
vim.g.spellfile_URL = 'http://ftp.vim.org/vim/runtime/spell'

-- Install package manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system { 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'tpope/vim-fugitive', -- Git related plugins
  'tpope/vim-rhubarb', -- Git related plugins
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth 

  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'folke/neodev.nvim',
      'mfussenegger/nvim-jdtls',
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets', 'f3fora/cmp-spell'
    },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },

  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '[c', require('gitsigns').prev_hunk, { buffer = bufnr, desc = 'Go to Previous Hunk' })
        vim.keymap.set('n', ']c', require('gitsigns').next_hunk, { buffer = bufnr, desc = 'Go to Next Hunk' })
        vim.keymap.set('n', '<leader>,H', require('gitsigns').preview_hunk, { buffer = bufnr, desc = 'Preview [H]unk' })
      end,
    },
  },

  {
    -- Themes
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function() vim.cmd.colorscheme 'onedark' end,

    --   'rmehri01/onenord.nvim',
    --   priority = 1000,
    --   config = function() vim.cmd.colorscheme 'onenord' end
  },

  { "vigoux/notifier.nvim", config = function() require'notifier'.setup({ }) end },

  { 'numToStr/Comment.nvim', opts = {} },

  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },

  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = function() return vim.fn.executable 'make' == 1 end,
  },
  "nvim-telescope/telescope-file-browser.nvim",

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    build = ':TSUpdate',
  },

  'nvim-treesitter/playground',

  'mfussenegger/nvim-dap',
  'theHamsta/nvim-dap-virtual-text',
  'leoluz/nvim-dap-go',
  'nvim-telescope/telescope-dap.nvim',
  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
    opts = {
      handlers = {},
      ensure_installed = { codelldb = {} }
    }
  },

  'norcalli/nvim-colorizer.lua',
  'smithbm2316/centerpad.nvim',

  { 'nvim-tree/nvim-web-devicons', opts = {override = icons} },

  --   "aurum77/live-server.nvim",
  --   run = function() require"live_server.util".install() end,
  --   cmd = { "LiveServer", "LiveServerStart", "LiveServerStop" },
  -- },
  -- 'vigoux/LanguageTool.nvim',
}, {}) -- eop

-- Variables
local tel = require('telescope')
local telbuiltin = require('telescope.builtin')
local telthemes = require('telescope.themes')
local telactions = require("telescope.actions")
local telfiles = require("telescope").extensions.file_browser.actions
local dap = require("dap")
local cmp = require('cmp')
local luasnip = require('luasnip')
local centerpad = require('centerpad')
local mason_lspconfig = require('mason-lspconfig')
local dap_widgets = require('dap.ui.widgets')
local servers = {
  clangd = {},
  pyright = {},
  tsserver = {},
  rust_analyzer = {},
  kotlin_language_server = {},
  html = { filetype = { 'html', 'ejs' } },
  lua_ls = { Lua = { telemetry = { enable = false } } },
}

local capabilities = require('cmp_nvim_lsp')
  .default_capabilities(vim.lsp.protocol.make_client_capabilities())
local on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then desc = 'LSP: ' .. desc end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('gD', vim.lsp.buf.type_definition, '[G]oto Type [D]efinition')
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

  nmap('<leader>c', vim.lsp.buf.code_action, '[C]ode Action')
  nmap('<leader>r', telbuiltin.lsp_references, '[R]eferences')
  nmap('<leader>s', telbuiltin.lsp_document_symbols, 'Document [S]ymbols')

  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('<leader>,s', telbuiltin.lsp_dynamic_workspace_symbols, 'Workspace [S]ymbols')
  nmap('<leader>,a', vim.lsp.buf.add_workspace_folder, 'Workspace [A]dd Folder')
  nmap('<leader>,r', vim.lsp.buf.remove_workspace_folder, 'Workspace [R]emove Folder')
  nmap('<leader>,l', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, 'Workspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end


-- Setting options
vim.o.incsearch = true
vim.o.undofile = true
vim.wo.signcolumn = 'no'
vim.o.completeopt = 'menuone,noselect'
vim.o.mouse = 'a'
vim.o.termguicolors = true
-- vim.o.hlsearch = false

vim.o.ignorecase = true
vim.o.clipboard = 'unnamedplus'
vim.o.smartcase = true

vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300

vim.o.breakindent = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.scrolloff = 8
vim.o.number = true
vim.o.relativenumber = true

vim.o.foldmethod = "manual"
vim.o.foldlevel = 2
vim.o.foldnestmax = 10
vim.o.foldenable = true
-- vim.o.foldmethod = "indent"
-- vim.o.foldenable = false

vim.o.encoding = 'utf-8'
vim.opt.spell = false
vim.opt.spelllang = {"pt", "en_us"}
vim.opt.spellcapcheck = ""
vim.opt.spelloptions = "camel"
-- vim.opt.spellsuggest = "best"

vim.o.laststatus = 0


-- Basic Keymaps
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Moving lines up and down
vim.keymap.set('n', '<A-j>', '<cmd>m+<CR>==')
vim.keymap.set('n', '<A-k>', '<cmd>m-2<CR>==')
vim.keymap.set('i', '<A-j>', '<Esc><cmd>m+<CR>==gi')
vim.keymap.set('i', '<A-k>', '<Esc><cmd>m-2<CR>==gi')
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv")

-- Fast replace all
vim.keymap.set('n', '<leader>p',
  ':%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>', {desc = "Re[p]lace"})
vim.keymap.set('n', '<leader>P',
  ':s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>', {desc = "Re[P]lace in line"})

-- Delete character in insert mode
vim.keymap.set('i', '<c-l>', '<c-o>dl')
vim.keymap.set('i', '<c-h>', '<c-o>dh')

-- Move through vimgrep
vim.keymap.set('n', '<leader>N', ':cn', {desc = "Move through Vimgrep"})

-- Maximize and minimize windows
vim.keymap.set('n', '<c-W>M', '<c-W>|<c-W>_', {desc = "Maximize Window"})
vim.keymap.set('n', '<c-W>m', '<c-W>=', {desc = "Minimize Window"})

-- toggle configs

local function toggle_spell() vim.o.spell = not vim.o.spell end
local function toggle_padding(pad)
  centerpad.toggle({ leftpad = pad, rightpad = pad })
end
local function toggle_number()
  vim.o.number = not vim.o.number
  vim.o.relativenumber = not vim.o.relativenumber
end
local function toggle_signcolumn()
  vim.o.signcolumn = vim.o.signcolumn == 'yes' and 'no' or 'yes'
end

-- vim.wo.signcolumn = 'auto'
vim.keymap.set("n", ",p", toggle_spell, {desc = "Toggle spelling"})
vim.keymap.set("n", ",n", toggle_number, {desc = "Toggle number"})
vim.keymap.set('n', ',z', function () toggle_padding(20) end, { desc = "Toggle padding [20]" })
vim.keymap.set('n', ',x', function () toggle_padding(5) end, { desc = "Toggle padding [5]" })
vim.keymap.set('n', ',s', toggle_signcolumn, { desc = "Toggle signcolumn" })

-- Debugger
vim.keymap.set('n', '<F1>', dap.step_over, {desc = "Step over"})
vim.keymap.set('n', '<F2>', dap.step_into, {desc = "Step into"})
vim.keymap.set('n', '<F3>', dap.step_out, {desc  = "Step out"})
vim.keymap.set('n', '<F4>', function () dap_widgets.centered_float(dap_widgets.scopes) end, {desc = "Open debug scope"})
vim.keymap.set('n', '<F5>', dap.continue, {desc = "Continue to next breakpoint or start debug session"})
vim.keymap.set('n', '<F6>', dap.repl.toggle, {desc = "Toggle console"})
vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, {desc = "Toggle breakpoint"})
vim.keymap.set('n', '<F7>', dap_widgets.hover, {desc = "Open debug panel"})

-- Diagnostics 
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Telescope
vim.keymap.set('n', '<leader>/', function()
  telbuiltin.current_buffer_fuzzy_find(telthemes.get_dropdown({ previewer = false }))
end, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>?', telbuiltin.oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', telbuiltin.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>f', telbuiltin.find_files, { desc = 'Search [F]iles' })
vim.keymap.set('n', '<leader>h', telbuiltin.help_tags, { desc = 'Search [H]elp' })
vim.keymap.set('n', '<leader>w', telbuiltin.grep_string, { desc = 'Search current [W]ord' })
vim.keymap.set('n', '<leader>g', telbuiltin.live_grep, { desc = 'Search by [G]rep' })
vim.keymap.set('n', '<leader>d', telbuiltin.diagnostics, { desc = 'Search [D]iagnostics' })
vim.keymap.set('n', '<leader>K', telbuiltin.keymaps, { desc = 'Search [K]eymaps' })
vim.keymap.set('n', '<leader>,F', telbuiltin.git_files, { desc = 'Search Git [F]iles' })
vim.keymap.set('n', '<leader>,S', telbuiltin.git_status, { desc = 'Search Git [S]tatus' })
vim.keymap.set( "n", "<leader>n", ":Telescope file_browser initial_mode=normal path=%:p:h select_buffer=true<CR>", { noremap = true, desc="Open Telescope File Browser" })

-- Commands
-- Highlight on yank 
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank() end,
  group = highlight_group,
  pattern = '*',
})

-- Closes a popup of dap
vim.api.nvim_command("autocmd FileType dap-float nnoremap <buffer><silent> <esc> <cmd>close!<CR>")

-- Setup
require('colorizer').setup(--[[ { css = {rgb_fn = true} } ]])
require('onedark').setup({ style = 'cool', transparent = true, highlights = { WinSeparator = { fg = "#282C34" } }})
require('onedark').load()

-- require('live_server').setup()

-- Telescope
tel.setup({
  defaults = {
    initial_mode = "normal",
    mappings = { i = { ['<C-u>'] = false, ['<C-d>'] = false, } }
  },
  extensions = {
    file_browser = {
      previewer = false,
      mappings = {
        n = {
          ["h"] = telfiles.goto_parent_dir,
          ["l"] = telactions.select_default,
          ["H"] = telfiles.toggle_hidden,
        }
      }
    }
  }
})

tel.load_extension('dap')
tel.load_extension("file_browser")
pcall(tel.load_extension, 'fzf') -- Enable telescope fzf native

-- Treesitter
vim.treesitter.language.register('html', 'ejs')
require('nvim-treesitter.configs').setup({
  ensure_installed = {
    'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash'
  },
  auto_install = false,
  sync_install = false,
  ignore_install = {},
  modules = {},
  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
      goto_next_end = { [']M'] = '@function.outer', [']['] = '@class.outer' },
      goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
      goto_previous_end = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
    },
    swap = {
      enable = true,
      swap_next = { ['<leader>a'] = '@parameter.inner' },
      swap_previous = { ['<leader>A'] = '@parameter.inner' },
    },
  },
})

require("dap-go").setup()
require("nvim-dap-virtual-text") .setup({ show_stop_reason = true })

require('neodev').setup({library = { types = true }})

-- mason_lspconfig
mason_lspconfig.setup({ ensure_installed = vim.tbl_keys(servers) })
mason_lspconfig.setup_handlers({ function(server_name)
  require('lspconfig')[server_name].setup {
    capabilities = capabilities, on_attach = on_attach, settings = servers[server_name],
  }
end, })

require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup({})

-- nvim-cmp
cmp.setup({
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete({}),
    ['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  experimental = {ghost_text = true},
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    {
        name = 'spell',
        option = { keep_all_entries = false, enable_in_context = function() return true end },
    }
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
