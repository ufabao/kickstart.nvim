-- Doom Emacs-style Neovim Configuration
-- Set <space> as the leader key (like Doom's SPC)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ===== APPEARANCE CONFIGURATION =====
-- Set to true if you have a Nerd Font installed (matching Doom's JetBrains Mono Nerd Font)
vim.g.have_nerd_font = true

-- ===== GENERAL SETTINGS =====
vim.opt.number = true
vim.opt.relativenumber = true -- Matching Doom's relative line numbers
vim.opt.mouse = 'a'
vim.opt.showmode = false

-- Clipboard integration
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.confirm = true

-- C/C++ indentation matching Doom config
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.autoindent = true

-- ===== AUTOCOMMANDS =====
-- Terminal configuration
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd 'startinsert'
  end,
})

-- Highlight yanking
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- ===== LAZY.NVIM SETUP =====
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- ===== PLUGIN CONFIGURATION =====
require('lazy').setup({
  -- Core plugins
  'tpope/vim-sleuth',

  -- Git integration
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
    },
  },

  -- Which-key for keybind discovery (like Doom's which-key)
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
      local wk = require 'which-key'
      wk.setup {
        delay = 0,
        icons = {
          mappings = vim.g.have_nerd_font,
          keys = vim.g.have_nerd_font and {} or {
            Up = '<Up> ',
            Down = '<Down> ',
            Left = '<Left> ',
            Right = '<Right> ',
            C = '<C-…> ',
            M = '<M-…> ',
            S = '<S-…> ',
            CR = '<CR> ',
            Esc = '<Esc> ',
            BS = '<BS> ',
            Space = '<Space> ',
            Tab = '<Tab> ',
          },
        },
      }

      -- Register Doom-style key groups
      wk.add {
        { '<leader>b', group = '[B]uffer' },
        { '<leader>B', group = '[B]azel' },
        { '<leader>c', group = '[C]ode' },
        { '<leader>d', group = '[D]iagnostics' },
        { '<leader>f', group = '[F]ile' },
        { '<leader>g', group = '[G]it' },
        { '<leader>h', group = '[H]elp' },
        { '<leader>o', group = '[O]pen' },
        { '<leader>p', group = '[P]roject' },
        { '<leader>q', group = '[Q]uit' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>w', group = '[W]indow' },
      }
    end,
  },

  -- Tokyo Night theme (matching Doom config)
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      require('tokyonight').setup {
        styles = {
          comments = { italic = false },
        },
      }
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },

  -- Telescope (fuzzy finder, similar to Doom's ivy/counsel)
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
    end,
  },

  -- Neo-tree file explorer
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('neo-tree').setup {
        close_if_last_window = true,
        window = {
          position = 'left',
          width = 30,
        },
      }
    end,
  },

  -- LSP Configuration
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'hrsh7th/cmp-nvim-lsp',
      'folke/neodev.nvim',
    },
    config = function()
      -- Setup neodev for Neovim Lua development
      require('neodev').setup()

      -- LSP attach configuration
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Doom-style LSP keybindings
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Leader-based code actions (Doom style)
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('<leader>cr', vim.lsp.buf.rename, '[C]ode [R]ename')
          map('<leader>cf', vim.lsp.buf.format, '[C]ode [F]ormat')

          -- Diagnostics (Doom style)
          map('<leader>cd', vim.diagnostic.open_float, '[C]ode [D]iagnostic')
          map('[d', vim.diagnostic.goto_prev, 'Previous diagnostic')
          map(']d', vim.diagnostic.goto_next, 'Next diagnostic')
        end,
      })

      -- Configure diagnostics
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        },
        virtual_text = {
          source = 'if_many',
          spacing = 2,
        },
      }

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Server configurations (matching Doom's C++ setup)
      local servers = {
        clangd = {
          cmd = {
            'clangd',
            '--background-index',
            '--clang-tidy',
            '--header-insertion=never',
            '--completion-style=detailed',
            '--function-arg-placeholders',
            '--fallback-style=llvm',
          },
        },
        pyright = {},
        rust_analyzer = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
        cmake = {}, -- CMake LSP matching Doom config
      }

      -- Install and setup servers
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, { 'stylua' })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  -- Autocompletion (matching Doom's company-mode behavior)
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp-signature-help',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = {
          completeopt = 'menu,menuone,noinsert',
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<Tab>'] = cmp.mapping.confirm { select = true },
          ['<C-Space>'] = cmp.mapping.complete {},
          ['<CR>'] = cmp.mapping.confirm { select = true },
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'nvim_lsp_signature_help' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        },
      }
    end,
  },

  -- Treesitter for syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'bash', 'c', 'cpp', 'cmake', 'lua', 'python', 'rust', 'markdown', 'vim', 'vimdoc' },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
      }
    end,
  },

  -- Formatting
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        cpp = { 'clang_format' },
        c = { 'clang_format' },
        python = { 'black' },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = 'fallback',
      },
    },
  },

  -- Mini.nvim collection
  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      require('mini.statusline').setup { use_icons = vim.g.have_nerd_font }
    end,
  },

  -- Todo comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  -- Toggleterm for terminal integration
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      require('toggleterm').setup {
        size = function(term)
          if term.direction == 'horizontal' then
            return 15
          elseif term.direction == 'vertical' then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = nil, -- We'll use custom mappings
        direction = 'horizontal',
        shade_terminals = true,
        start_in_insert = true,
      }
    end,
  },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- ===== DOOM-STYLE KEYMAPPINGS =====
-- Clear search highlights
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Window navigation (Doom style)
vim.keymap.set('n', '<leader>wh', '<C-w>h', { desc = '[W]indow left' })
vim.keymap.set('n', '<leader>wj', '<C-w>j', { desc = '[W]indow down' })
vim.keymap.set('n', '<leader>wk', '<C-w>k', { desc = '[W]indow up' })
vim.keymap.set('n', '<leader>wl', '<C-w>l', { desc = '[W]indow right' })
vim.keymap.set('n', '<leader>ws', '<C-w>s', { desc = '[W]indow [S]plit horizontal' })
vim.keymap.set('n', '<leader>wv', '<C-w>v', { desc = '[W]indow split [V]ertical' })
vim.keymap.set('n', '<leader>wc', '<C-w>c', { desc = '[W]indow [C]lose' })
vim.keymap.set('n', '<leader>wo', '<C-w>o', { desc = '[W]indow [O]nly' })

-- Buffer management (Doom style)
vim.keymap.set('n', '<leader>bb', '<cmd>Telescope buffers<CR>', { desc = '[B]uffer [B]rowse' })
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = '[B]uffer [D]elete' })
vim.keymap.set('n', '<leader>bn', '<cmd>bnext<CR>', { desc = '[B]uffer [N]ext' })
vim.keymap.set('n', '<leader>bp', '<cmd>bprevious<CR>', { desc = '[B]uffer [P]revious' })
vim.keymap.set('n', '<leader>bk', '<cmd>bdelete!<CR>', { desc = '[B]uffer [K]ill' })

-- File operations (Doom style)
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = '[F]ind [F]ile' })
vim.keymap.set('n', '<leader>fr', '<cmd>Telescope oldfiles<CR>', { desc = '[F]ind [R]ecent' })
vim.keymap.set('n', '<leader>fs', '<cmd>w<CR>', { desc = '[F]ile [S]ave' })
vim.keymap.set('n', '<leader>fS', '<cmd>wa<CR>', { desc = '[F]ile [S]ave all' })

-- Search operations (Doom style)
vim.keymap.set('n', '<leader>sg', '<cmd>Telescope live_grep<CR>', { desc = '[S]earch [G]rep' })
vim.keymap.set('n', '<leader>sb', '<cmd>Telescope current_buffer_fuzzy_find<CR>', { desc = '[S]earch [B]uffer' })
vim.keymap.set('n', '<leader>sh', '<cmd>Telescope help_tags<CR>', { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', '<cmd>Telescope keymaps<CR>', { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sd', '<cmd>Telescope diagnostics<CR>', { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>ss', '<cmd>Telescope builtin<CR>', { desc = '[S]earch [S]elect' })
vim.keymap.set('n', '<leader>sw', '<cmd>Telescope grep_string<CR>', { desc = '[S]earch [W]ord' })

-- Project operations (Doom style)
vim.keymap.set('n', '<leader>pf', '<cmd>Telescope find_files<CR>', { desc = '[P]roject [F]ind file' })
vim.keymap.set('n', '<leader>pg', '<cmd>Telescope live_grep<CR>', { desc = '[P]roject [G]rep' })

-- Open operations (Doom style) - KEY MAPPINGS YOU REQUESTED
vim.keymap.set('n', '<leader>op', '<cmd>Neotree toggle<CR>', { desc = '[O]pen [P]roject tree' })
vim.keymap.set('n', '<leader>ot', '<cmd>ToggleTerm<CR>', { desc = '[O]pen [T]erminal' })
vim.keymap.set('n', '<leader>oT', '<cmd>ToggleTerm direction=vertical<CR>', { desc = '[O]pen [T]erminal vertical' })

-- File navigation (Doom Emacs style "SPC .")
vim.keymap.set('n', '<leader>.', '<cmd>Telescope find_files<CR>', { desc = 'Find files (like Doom SPC .)' })

-- Git operations (basic, can be extended)
vim.keymap.set('n', '<leader>gg', '<cmd>!git status<CR>', { desc = '[G]it status' })

-- Quit operations (Doom style)
vim.keymap.set('n', '<leader>qq', '<cmd>qa<CR>', { desc = '[Q]uit [Q]uit all' })
vim.keymap.set('n', '<leader>qQ', '<cmd>qa!<CR>', { desc = '[Q]uit force [Q]uit all' })

-- Toggle operations
vim.keymap.set('n', '<leader>tn', '<cmd>set relativenumber!<CR>', { desc = '[T]oggle relative [N]umbers' })
vim.keymap.set('n', '<leader>tw', '<cmd>set wrap!<CR>', { desc = '[T]oggle [W]rap' })

-- Help operations
vim.keymap.set('n', '<leader>hh', '<cmd>Telescope help_tags<CR>', { desc = '[H]elp [H]elp' })
vim.keymap.set('n', '<leader>hm', '<cmd>Telescope man_pages<CR>', { desc = '[H]elp [M]an pages' })

-- Terminal mode mappings
vim.keymap.set('t', '<C-n>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('t', '<leader>ot', '<cmd>ToggleTerm<CR>', { desc = 'Toggle terminal' })

-- Insert mode navigation (Emacs style Ctrl-F to move forward)
vim.keymap.set('i', '<C-f>', '<Right>', { desc = 'Move cursor forward in insert mode' })

-- ===== BAZEL BUILD SYSTEM INTEGRATION (Matching Doom config) =====
-- Bazel configuration variables
vim.g.bazel_config = 'default-debug'
vim.g.bazel_configs = {
  ['gcc-debug'] = '--config=gcc --compilation_mode=dbg',
  ['gcc-release'] = '--config=gcc --compilation_mode=opt',
  ['clang-debug'] = '--config=clang --compilation_mode=dbg',
  ['clang-release'] = '--config=clang --compilation_mode=opt',
  ['default-debug'] = '--compilation_mode=dbg',
  ['default-release'] = '--compilation_mode=opt',
}

-- Bazel functions
local function bazel_build()
  local target = vim.fn.input('Build target: ', '//...')
  if target ~= '' then
    local config = vim.g.bazel_configs[vim.g.bazel_config] or ''
    vim.cmd('!bazel build ' .. target .. ' ' .. config)
  end
end

local function bazel_test()
  local target = vim.fn.input('Test target: ', '//...')
  if target ~= '' then
    local config = vim.g.bazel_configs[vim.g.bazel_config] or ''
    vim.cmd('!bazel test ' .. target .. ' ' .. config .. ' --test_output=all')
  end
end

local function bazel_run()
  local target = vim.fn.input('Run target: ', '')
  if target ~= '' then
    local config = vim.g.bazel_configs[vim.g.bazel_config] or ''
    vim.cmd('!bazel run ' .. target .. ' ' .. config)
  end
end

local function bazel_set_config()
  local configs = {}
  for k, _ in pairs(vim.g.bazel_configs) do
    table.insert(configs, k)
  end

  vim.ui.select(configs, {
    prompt = 'Select Bazel configuration:',
  }, function(choice)
    if choice then
      vim.g.bazel_config = choice
      print('Bazel config set to: ' .. choice)
    end
  end)
end

-- Bazel keymappings (Doom style)
vim.keymap.set('n', '<leader>Bb', bazel_build, { desc = '[B]azel [b]uild' })
vim.keymap.set('n', '<leader>Bt', bazel_test, { desc = '[B]azel [t]est' })
vim.keymap.set('n', '<leader>Br', bazel_run, { desc = '[B]azel [r]un' })
vim.keymap.set('n', '<leader>Bc', bazel_set_config, { desc = '[B]azel [c]onfig' })
vim.keymap.set('n', '<leader>Bx', '<cmd>!bazel clean<CR>', { desc = '[B]azel clean' })
vim.keymap.set('n', '<leader>Bg', '<cmd>!bazel run //:refresh_compile_commands<CR>', { desc = '[B]azel [g]enerate compile_commands' })

-- C++ specific keybindings
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c', 'cpp' },
  callback = function()
    vim.keymap.set('n', '<A-o>', '<cmd>ClangdSwitchSourceHeader<CR>', { buffer = true, desc = 'Switch source/header' })
  end,
})
