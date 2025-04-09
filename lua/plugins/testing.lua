return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'antoinemadec/FixCursorHold.nvim',
      -- Adapters:
      'alfaix/neotest-gtest',
      'rouge8/neotest-rust',
      'nvim-neotest/neotest-python',
    },

    opts = function()
      local adapters_loaded = {}
      local adapters_to_load = {
        gtest = 'neotest-gtest',
        rust = 'neotest-rust',
        python = 'neotest-python',
      }

      for key, module_name in pairs(adapters_to_load) do
        local ok, adapter = pcall(require, module_name)
        if ok then
          adapters_loaded[key] = adapter
        else
          vim.notify('Failed to load ' .. module_name .. ' adapter: ' .. tostring(adapter), vim.log.levels.WARN) -- WARN might be better than ERROR
        end
      end

      -- Return the options table
      local options = {
        adapters = {}, -- Initialize adapters table
        status = { virtual_text = true },
        output = { open_on_run = true },
        quickfix = { enabled = true, open = false },
      }

      if adapters_loaded.gtest then
        options.adapters['neotest-gtest'] = adapters_loaded.gtest.setup {}
      end
      if adapters_loaded.rust then
        -- neotest-rust often just needs to be loaded, or requires setup{}
        options.adapters['neotest-rust'] = {} -- Or just {} or adapters_loaded.rust depending on docs
        -- options.adapters.rustaceanvim = { -- Example if using rustaceanvim integration
        --   args = { "--nocapture" }
        -- }
      end
      if adapters_loaded.python then
        -- neotest-python setup, potentially specifying runners or args
        options.adapters['neotest-python'] = {}
        -- runner = "pytest", -- Often default, but can specify
        -- dap = { justMyCode = false }, -- Example DAP config if using nvim-dap
        -- pytest_xml_dir = "/tmp/pytest_xml_reports" -- Example option

        -- Or simply: options.adapters["neotest-python"] = {} if defaults work
      end

      return options
    end,

    config = function(_, opts)
      require('neotest').setup(opts)
      -- Keymaps from previous example...
      local map = vim.keymap.set
      map('n', '<leader>tn', function()
        require('neotest').run.run()
      end, { desc = 'Neotest Run Nearest' })
      map('n', '<leader>tf', function()
        require('neotest').run.run(vim.fn.expand '%')
      end, { desc = 'Neotest Run File' })
      map('n', '<leader>tS', function()
        require('neotest').run.stop()
      end, { desc = 'Neotest Stop' })
      map('n', '<leader>ts', function()
        require('neotest').summary.toggle()
      end, { desc = 'Neotest Summary' })
      map('n', '<leader>to', function()
        require('neotest').output.open { enter = true }
      end, { desc = 'Neotest Output' })
    end,
  },
}
