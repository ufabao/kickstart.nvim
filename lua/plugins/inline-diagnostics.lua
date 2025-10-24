-- Inline diagnostic display (equivalent to flycheck-inline in Emacs)
return {
  {
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    event = 'LspAttach',
    config = function()
      local lsp_lines = require('lsp_lines')
      
      -- Setup lsp_lines
      lsp_lines.setup()
      
      -- Disable virtual_text since lsp_lines handles it
      vim.diagnostic.config({
        virtual_text = false,
        virtual_lines = { only_current_line = true }
      })
      
      -- Toggle function for lsp_lines
      local function toggle_lsp_lines()
        local current_config = vim.diagnostic.config()
        if current_config.virtual_lines then
          vim.diagnostic.config({ virtual_lines = false, virtual_text = true })
          vim.notify('LSP Lines: OFF', vim.log.levels.INFO)
        else
          vim.diagnostic.config({ virtual_lines = { only_current_line = true }, virtual_text = false })
          vim.notify('LSP Lines: ON', vim.log.levels.INFO)
        end
      end
      
      -- Keybinding to toggle inline diagnostics
      vim.keymap.set('n', '<leader>td', toggle_lsp_lines, { desc = '[T]oggle [D]iagnostic Lines' })
    end,
  },
  
  -- Alternative: trouble.nvim for better diagnostic display
  {
    'folke/trouble.nvim',
    opts = {
      focus = true,
      modes = {
        lsp = {
          win = { position = "right" }
        }
      }
    },
    cmd = 'Trouble',
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics (Trouble)' },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics (Trouble)' },
      { '<leader>cs', '<cmd>Trouble symbols toggle<cr>', desc = 'Symbols (Trouble)' },
      { '<leader>cS', '<cmd>Trouble lsp toggle<cr>', desc = 'LSP references/definitions/... (Trouble)' },
      { '<leader>xL', '<cmd>Trouble loclist toggle<cr>', desc = 'Location List (Trouble)' },
      { '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', desc = 'Quickfix List (Trouble)' },
      {
        '[q',
        function()
          if require('trouble').is_open() then
            require('trouble').prev({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = 'Previous Trouble/Quickfix Item',
      },
      {
        ']q',
        function()
          if require('trouble').is_open() then
            require('trouble').next({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = 'Next Trouble/Quickfix Item',
      },
    },
  },
}