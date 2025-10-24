-- Enhanced terminal integration (equivalent to VTerm in Emacs)
return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      require('toggleterm').setup({
        size = function(term)
          if term.direction == 'horizontal' then
            return 15
          elseif term.direction == 'vertical' then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        persist_size = true,
        persist_mode = true,
        direction = 'horizontal', -- 'vertical' | 'horizontal' | 'tab' | 'float'
        close_on_exit = true,
        shell = vim.o.shell,
        auto_scroll = true,
        float_opts = {
          border = 'curved',
          winblend = 3,
          highlights = {
            border = 'Normal',
            background = 'Normal',
          },
        },
        winbar = {
          enabled = false,
          name_formatter = function(term)
            return term.name
          end
        },
      })

      -- Terminal keymaps and functions
      local Terminal = require('toggleterm.terminal').Terminal

      -- Main toggleable terminal (matching your current setup)
      local main_terminal = Terminal:new({
        cmd = vim.o.shell,
        direction = 'horizontal',
        size = 10,
        close_on_exit = true,
        auto_scroll = true,
      })

      local function toggle_main_terminal()
        main_terminal:toggle()
      end

      -- Floating terminal
      local float_terminal = Terminal:new({
        direction = 'float',
        float_opts = {
          border = 'double',
        },
        close_on_exit = true,
        auto_scroll = true,
      })

      local function toggle_float_terminal()
        float_terminal:toggle()
      end

      -- Vertical terminal
      local vertical_terminal = Terminal:new({
        direction = 'vertical',
        size = vim.o.columns * 0.4,
        close_on_exit = true,
        auto_scroll = true,
      })

      local function toggle_vertical_terminal()
        vertical_terminal:toggle()
      end

      -- Specialized terminals for development
      local lazygit_terminal = Terminal:new({
        cmd = 'lazygit',
        dir = 'git_dir',
        direction = 'float',
        float_opts = {
          border = 'double',
        },
        close_on_exit = true,
        on_open = function(term)
          vim.cmd('startinsert!')
          vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', {noremap = true, silent = true})
        end,
        on_close = function(_)
          vim.cmd('startinsert!')
        end,
      })

      local function toggle_lazygit()
        lazygit_terminal:toggle()
      end

      -- htop terminal
      local htop_terminal = Terminal:new({
        cmd = 'htop',
        direction = 'float',
        float_opts = {
          border = 'double',
        },
        close_on_exit = true,
        on_open = function(term)
          vim.cmd('startinsert!')
          vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', {noremap = true, silent = true})
        end,
      })

      local function toggle_htop()
        htop_terminal:toggle()
      end

      -- Python REPL terminal
      local python_terminal = Terminal:new({
        cmd = 'python3',
        direction = 'horizontal',
        size = 15,
        close_on_exit = true,
        auto_scroll = true,
      })

      local function toggle_python()
        python_terminal:toggle()
      end

      -- Node REPL terminal
      local node_terminal = Terminal:new({
        cmd = 'node',
        direction = 'horizontal',
        size = 15,
        close_on_exit = true,
        auto_scroll = true,
      })

      local function toggle_node()
        node_terminal:toggle()
      end

      -- Key mappings (preserving your existing <leader>q mapping)
      vim.keymap.set('n', '<leader>q', toggle_main_terminal, { desc = 'Terminal: Toggle main' })
      vim.keymap.set('t', '<leader>q', toggle_main_terminal, { desc = 'Terminal: Toggle main' })
      
      -- Additional terminal mappings
      vim.keymap.set('n', '<leader>tf', toggle_float_terminal, { desc = 'Terminal: Toggle float' })
      vim.keymap.set('n', '<leader>tv', toggle_vertical_terminal, { desc = 'Terminal: Toggle vertical' })
      vim.keymap.set('n', '<leader>tg', toggle_lazygit, { desc = 'Terminal: Lazygit' })
      vim.keymap.set('n', '<leader>th', toggle_htop, { desc = 'Terminal: htop' })
      vim.keymap.set('n', '<leader>tp', toggle_python, { desc = 'Terminal: Python REPL' })
      vim.keymap.set('n', '<leader>tn', toggle_node, { desc = 'Terminal: Node REPL' })

      -- Terminal window navigation (matching your Emacs setup)
      local function set_terminal_keymaps()
        local opts = {buffer = 0}
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
        vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
      end

      -- Apply terminal keymaps to all terminal buffers
      vim.api.nvim_create_autocmd('TermOpen', {
        pattern = 'term://*',
        callback = set_terminal_keymaps,
      })

      -- Auto insert mode for terminals (matching your existing setup)
      vim.api.nvim_create_autocmd({'TermOpen', 'BufEnter'}, {
        pattern = 'term://*',
        callback = function()
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
          if vim.api.nvim_get_mode().mode == 'n' then
            vim.cmd('startinsert')
          end
        end,
      })

      -- Auto close terminal when process exits (matching your existing setup)
      vim.api.nvim_create_autocmd('TermClose', {
        pattern = 'term://*',
        callback = function()
          if vim.v.event.status == 0 then
            vim.api.nvim_buf_delete(0, { force = true })
          end
        end,
      })

      -- Add which-key groups
      local ok, wk = pcall(require, 'which-key')
      if ok then
        wk.add({
          { '<leader>t', group = '[T]erminal' },
        })
      end
    end,
  },

  -- Terminal file manager integration
  {
    'is0n/fm-nvim',
    config = function()
      require('fm-nvim').setup({
        ui = {
          default = 'float',
          float = {
            border = 'rounded',
            float_hl = 'Normal',
            border_hl = 'FloatBorder',
            blend = 0,
            height = 0.8,
            width = 0.8,
            x = 0.5,
            y = 0.5,
          },
        },
        cmds = {
          ranger_cmd = 'ranger',
          nnn_cmd = 'nnn -P p',
          lf_cmd = 'lf',
          vifm_cmd = 'vifm',
        },
        mappings = {
          vert_split = '<C-v>',
          horz_split = '<C-h>',
          tabedit = '<C-t>',
          edit = '<C-e>',
          ESC = '<ESC>',
        },
      })

      -- File manager keymaps
      vim.keymap.set('n', '<leader>fr', '<cmd>Ranger<cr>', { desc = 'File manager: Ranger' })
      vim.keymap.set('n', '<leader>fn', '<cmd>Nnn<cr>', { desc = 'File manager: nnn' })
      vim.keymap.set('n', '<leader>fl', '<cmd>Lf<cr>', { desc = 'File manager: lf' })

      -- Add which-key groups
      local ok, wk = pcall(require, 'which-key')
      if ok then
        wk.add({
          { '<leader>f', group = '[F]ile manager' },
        })
      end
    end,
  },
}