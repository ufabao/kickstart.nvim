-- Enhanced code folding and workspace management (matching Emacs capabilities)
return {
  -- Advanced code folding
  {
    'kevinhwang91/nvim-ufo',
    dependencies = {
      'kevinhwang91/promise-async',
      {
        'luukvbaal/statuscol.nvim',
        config = function()
          local builtin = require('statuscol.builtin')
          require('statuscol').setup({
            relculright = true,
            segments = {
              { text = { builtin.foldfunc }, click = 'v:lua.ScFa' },
              { text = { '%s' }, click = 'v:lua.ScSa' },
              { text = { builtin.lnumfunc, ' ' }, click = 'v:lua.ScLa' },
            },
          })
        end,
      },
    },
    event = 'BufReadPost',
    config = function()
      -- Enhanced folding options (matching your Emacs fold settings)
      vim.opt.foldcolumn = '1'
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99
      vim.opt.foldenable = true
      vim.opt.fillchars = {
        foldopen = '',
        foldclose = '',
        fold = ' ',
        foldsep = ' ',
        diff = '╱',
        eob = ' ',
      }

      -- LSP and Treesitter-based folding
      local ufo = require('ufo')
      
      -- Provider selector function
      local function provider_selector(bufnr, filetype, buftype)
        -- Use LSP folding for these filetypes if available
        local lsp_filetypes = { 'c', 'cpp', 'rust', 'python', 'javascript', 'typescript', 'lua' }
        
        if vim.tbl_contains(lsp_filetypes, filetype) then
          return { 'lsp', 'indent' }
        end
        
        -- Use treesitter for supported files
        return { 'treesitter', 'indent' }
      end

      ufo.setup({
        provider_selector = provider_selector,
        open_fold_hl_timeout = 400,
        close_fold_kinds_for_ft = {
          default = {'imports', 'comment'},
          json = {'array'},
          c = {'comment', 'region'},
          cpp = {'comment', 'region'},
          python = {'comment'},
        },
        preview = {
          win_config = {
            border = {'', '─', '', '', '', '─', '', ''},
            winhighlight = 'Normal:Folded',
            winblend = 0,
          },
          mappings = {
            scrollU = '<C-u>',
            scrollD = '<C-d>',
            jumpTop = '[',
            jumpBot = ']',
          },
        },
        fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
          local newVirtText = {}
          local suffix = (' 󰁂 %d '):format(endLnum - lnum)
          local sufWidth = vim.fn.strdisplaywidth(suffix)
          local targetWidth = width - sufWidth
          local curWidth = 0
          for _, chunk in ipairs(virtText) do
            local chunkText = chunk[1]
            local chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if targetWidth > curWidth + chunkWidth then
              table.insert(newVirtText, chunk)
            else
              chunkText = truncate(chunkText, targetWidth - curWidth)
              local hlGroup = chunk[2]
              table.insert(newVirtText, {chunkText, hlGroup})
              chunkWidth = vim.fn.strdisplaywidth(chunkText)
              if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
              end
              break
            end
            curWidth = curWidth + chunkWidth
          end
          table.insert(newVirtText, {suffix, 'MoreMsg'})
          return newVirtText
        end,
      })

      -- Folding keymaps (matching Emacs-style bindings)
      vim.keymap.set('n', 'zR', ufo.openAllFolds, { desc = 'Open all folds' })
      vim.keymap.set('n', 'zM', ufo.closeAllFolds, { desc = 'Close all folds' })
      vim.keymap.set('n', 'zr', ufo.openFoldsExceptKinds, { desc = 'Open folds except kinds' })
      vim.keymap.set('n', 'zm', ufo.closeFoldsWith, { desc = 'Close folds with' })
      vim.keymap.set('n', 'zK', function()
        local winid = ufo.peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end, { desc = 'Peek folded lines or hover' })

      -- Additional folding commands
      vim.keymap.set('n', '<leader>zf', '<cmd>set foldmethod=manual<cr>zf', { desc = 'Create fold' })
      vim.keymap.set('n', '<leader>zd', 'zd', { desc = 'Delete fold' })
      vim.keymap.set('n', '<leader>zE', 'zE', { desc = 'Eliminate all folds' })
      vim.keymap.set('n', '<leader>zi', 'zi', { desc = 'Toggle fold enable' })
    end,
  },

  -- Workspace/session management (equivalent to Emacs workspaces)
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = {
      dir = vim.fn.expand(vim.fn.stdpath('state') .. '/sessions/'),
      options = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp' },
      pre_save = nil,
    },
    config = function(_, opts)
      require('persistence').setup(opts)
      
      -- Session management keymaps
      vim.keymap.set('n', '<leader>qs', function() require('persistence').load() end, { desc = 'Restore session' })
      vim.keymap.set('n', '<leader>ql', function() require('persistence').load({ last = true }) end, { desc = 'Restore last session' })
      vim.keymap.set('n', '<leader>qd', function() require('persistence').stop() end, { desc = 'Don\'t save current session' })
      vim.keymap.set('n', '<leader>qw', function() require('persistence').save() end, { desc = 'Save session' })
    end,
  },

  -- Project management
  {
    'ahmedkhalf/project.nvim',
    config = function()
      require('project_nvim').setup({
        detection_methods = { 'lsp', 'pattern' },
        patterns = { '.git', '_darcs', '.hg', '.bzr', '.svn', 'Makefile', 'package.json', 'Cargo.toml', 'WORKSPACE', 'BUILD' },
        ignore_lsp = {},
        exclude_dirs = {},
        show_hidden = false,
        silent_chdir = true,
        scope_chdir = 'global',
        datapath = vim.fn.stdpath('data'),
      })

      -- Project keymaps
      vim.keymap.set('n', '<leader>pp', '<cmd>Telescope projects<cr>', { desc = 'Switch project' })
      
      -- Integrate with telescope
      local ok, telescope = pcall(require, 'telescope')
      if ok then
        telescope.load_extension('projects')
      end
    end,
  },

  -- Enhanced window management
  {
    'anuvyklack/windows.nvim',
    dependencies = {
      'anuvyklack/middleclass',
      'anuvyklack/animation.nvim',
    },
    config = function()
      require('windows').setup({
        autowidth = {
          enable = true,
          winwidth = 5,
          filetype = {
            help = 2,
          },
        },
        ignore = {
          buftype = { 'quickfix' },
          filetype = { 'NvimTree', 'neo-tree', 'undotree', 'gundo' }
        },
        animation = {
          enable = true,
          duration = 300,
          fps = 30,
          easing = 'in_out_sine',
        }
      })

      -- Window management keymaps
      vim.keymap.set('n', '<leader>wm', '<cmd>WindowsMaximize<cr>', { desc = 'Maximize window' })
      vim.keymap.set('n', '<leader>w_', '<cmd>WindowsMaximizeVertically<cr>', { desc = 'Maximize vertically' })
      vim.keymap.set('n', '<leader>w|', '<cmd>WindowsMaximizeHorizontally<cr>', { desc = 'Maximize horizontally' })
      vim.keymap.set('n', '<leader>w=', '<cmd>WindowsEqualize<cr>', { desc = 'Equalize windows' })
      vim.keymap.set('n', '<leader>wt', '<cmd>WindowsToggleAutowidth<cr>', { desc = 'Toggle auto width' })
    end,
  },

  -- Buffer management (matching Emacs buffer switching)
  {
    'j-morano/buffer_manager.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('buffer_manager').setup({
        select_menu_item_commands = {
          v = {
            key = '<C-v>',
            command = 'vsplit'
          },
          h = {
            key = '<C-h>',
            command = 'split'
          }
        },
        focus_alternate_buffer = false,
        short_file_names = true,
        short_term_names = true,
        loop_nav = true,
      })

      -- Buffer management keymaps
      vim.keymap.set('n', '<leader>bb', function() require('buffer_manager.ui').toggle_quick_menu() end, { desc = 'Buffer manager' })
      vim.keymap.set('n', '<leader>bn', function() require('buffer_manager.nav').nav_next() end, { desc = 'Next buffer' })
      vim.keymap.set('n', '<leader>bp', function() require('buffer_manager.nav').nav_prev() end, { desc = 'Previous buffer' })
    end,
  },

  -- Add which-key groups for all new keymaps
  {
    'folke/which-key.nvim',
    opts = function(_, opts)
      if not opts.spec then opts.spec = {} end
      
      local new_groups = {
        { '<leader>q', group = '[Q]uit/Session' },
        { '<leader>w', group = '[W]indows' },
        { '<leader>p', group = '[P]rojects' },
        { '<leader>z', group = '[Z] Folding' },
      }
      
      for _, group in ipairs(new_groups) do
        table.insert(opts.spec, group)
      end
      
      return opts
    end,
  },
}