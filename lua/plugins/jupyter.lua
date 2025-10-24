-- Jupyter notebook support for Neovim (equivalent to EIN in Emacs)
return {
  {
    'benlubas/molten-nvim',
    version = '^1.0.0',
    build = ':UpdateRemotePlugins',
    init = function()
      -- Configuration variables (matching your Emacs EIN settings)
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = true
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_output_show_more = true
      vim.g.molten_use_border_highlights = true
      vim.g.molten_virt_lines_off_by_1 = true
      
      -- Default notebook directory (matching your Emacs setting)
      vim.g.molten_notebook_dir = vim.fn.expand('~/notebooks')
    end,
    config = function()
      -- Jupyter keybindings (matching your Emacs EIN keybindings)
      local function molten_keymaps()
        vim.keymap.set('n', '<localleader>,', '<cmd>MoltenEvaluateOperator<cr>', { desc = 'Molten: Evaluate operator', silent = true })
        vim.keymap.set('n', '<localleader>.', '<cmd>MoltenEvaluateLine<cr><cmd>MoltenNext<cr>', { desc = 'Molten: Evaluate line and move', silent = true })
        vim.keymap.set('v', '<localleader>,', ':<C-u>MoltenEvaluateVisual<cr>gv', { desc = 'Molten: Evaluate selection', silent = true })
        vim.keymap.set('n', '<localleader>b', '<cmd>MoltenEvaluateOperator<cr>ip', { desc = 'Molten: Evaluate paragraph', silent = true })
        vim.keymap.set('n', '<localleader>a', '<cmd>MoltenEvaluateOperator<cr>G', { desc = 'Molten: Evaluate all', silent = true })
        
        -- Cell navigation and management
        vim.keymap.set('n', '<localleader>n', '<cmd>MoltenNext<cr>', { desc = 'Molten: Next cell', silent = true })
        vim.keymap.set('n', '<localleader>p', '<cmd>MoltenPrev<cr>', { desc = 'Molten: Previous cell', silent = true })
        
        -- Kernel management
        vim.keymap.set('n', '<localleader>k', '<cmd>MoltenInit<cr>', { desc = 'Molten: Initialize kernel', silent = true })
        vim.keymap.set('n', '<localleader>K', '<cmd>MoltenDeinit<cr>', { desc = 'Molten: Deinitialize kernel', silent = true })
        vim.keymap.set('n', '<localleader>r', '<cmd>MoltenRestart<cr>', { desc = 'Molten: Restart kernel', silent = true })
        vim.keymap.set('n', '<localleader>I', '<cmd>MoltenInterrupt<cr>', { desc = 'Molten: Interrupt kernel', silent = true })
        
        -- Output management
        vim.keymap.set('n', '<localleader>o', '<cmd>MoltenShowOutput<cr>', { desc = 'Molten: Show output', silent = true })
        vim.keymap.set('n', '<localleader>h', '<cmd>MoltenHideOutput<cr>', { desc = 'Molten: Hide output', silent = true })
        vim.keymap.set('n', '<localleader>d', '<cmd>MoltenDelete<cr>', { desc = 'Molten: Delete cell', silent = true })
        
        -- Import/Export
        vim.keymap.set('n', '<localleader>e', '<cmd>MoltenExportOutput<cr>', { desc = 'Molten: Export output', silent = true })
        vim.keymap.set('n', '<localleader>i', '<cmd>MoltenImportOutput<cr>', { desc = 'Molten: Import output', silent = true })
      end
      
      -- Set up molten keymaps for Python files and jupyter files
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'python', 'jupyter' },
        callback = molten_keymaps,
      })
      
      -- Global keymaps for Jupyter management
      vim.keymap.set('n', '<leader>jk', '<cmd>MoltenInit<cr>', { desc = 'Jupyter: Start kernel' })
      vim.keymap.set('n', '<leader>jK', '<cmd>MoltenDeinit<cr>', { desc = 'Jupyter: Stop kernel' })
      vim.keymap.set('n', '<leader>jr', '<cmd>MoltenRestart<cr>', { desc = 'Jupyter: Restart kernel' })
      vim.keymap.set('n', '<leader>ji', '<cmd>MoltenInfo<cr>', { desc = 'Jupyter: Info' })
      
      -- Add which-key groups
      local ok, wk = pcall(require, 'which-key')
      if ok then
        wk.add({
          { '<leader>j', group = '[J]upyter' },
        })
      end
    end,
  },
  
  
  -- Additional Jupyter support
  {
    'ahmedkhalf/jupyter-nvim',
    build = ':UpdateRemotePlugins',
    config = function()
      require('jupyter-nvim').setup {
        -- Default notebook directory
        notebook_dir = '~/notebooks',
        -- Use molten for execution
        use_molten = true,
      }
    end,
  },
  
  -- Python/IPython REPL integration
  {
    'Vigemus/iron.nvim',
    config = function()
      local iron = require('iron.core')
      local view = require('iron.view')

      iron.setup {
        config = {
          scratch_repl = true,
          close_window_on_exit = true,
          repl_definition = {
            python = {
              command = { 'ipython' },
              format = require('iron.fts.python').ipython,
            },
          },
          repl_open_cmd = view.bottom(40),
        },
        keymaps = {
          send_motion = '<localleader>sc',
          visual_send = '<localleader>sc',
          send_file = '<localleader>sf',
          send_line = '<localleader>sl',
          send_mark = '<localleader>sm',
          mark_motion = '<localleader>mc',
          mark_visual = '<localleader>mc',
          remove_mark = '<localleader>md',
          cr = '<localleader>s<cr>',
          interrupt = '<localleader>s<space>',
          exit = '<localleader>sq',
          clear = '<localleader>cl',
        },
        highlight = {
          italic = true
        },
      }
      
      -- REPL keymaps
      vim.keymap.set('n', '<leader>rs', '<cmd>IronRepl<cr>', { desc = 'REPL: Start' })
      vim.keymap.set('n', '<leader>rr', '<cmd>IronRestart<cr>', { desc = 'REPL: Restart' })
      vim.keymap.set('n', '<leader>rf', '<cmd>IronFocus<cr>', { desc = 'REPL: Focus' })
      vim.keymap.set('n', '<leader>rh', '<cmd>IronHide<cr>', { desc = 'REPL: Hide' })
      
      -- Add which-key groups
      local ok, wk = pcall(require, 'which-key')
      if ok then
        wk.add({
          { '<leader>r', group = '[R]EPL' },
        })
      end
    end,
  },
}