-- Comprehensive Bazel build system integration for Neovim
-- Matches the functionality from Doom Emacs config

return {
  -- Basic Bazel syntax support
  {
    'google/vim-ft-bzl',
    ft = { 'bzl', 'bazel' },
  },
  
  -- Extended Bazel functionality
  {
    'bazelbuild/vim-bazel',
    ft = { 'bzl', 'bazel', 'BUILD' },
    config = function()
      -- Bazel build configurations (matching Emacs setup)
      local bazel_configs = {
        { name = 'gcc-debug', flags = '--config=gcc --compilation_mode=dbg' },
        { name = 'gcc-release', flags = '--config=gcc --compilation_mode=opt' },
        { name = 'clang-debug', flags = '--config=clang --compilation_mode=dbg' },
        { name = 'clang-release', flags = '--config=clang --compilation_mode=opt' },
        { name = 'default-debug', flags = '--compilation_mode=dbg' },
        { name = 'default-release', flags = '--compilation_mode=opt' },
      }

      local default_config = 'default-debug'
      local current_config = default_config

      local common_flags = {
        '--jobs=auto',
        '--verbose_failures',
        '--sandbox_debug',
      }

      -- Get Bazel targets
      local function get_bazel_targets()
        local targets = {}
        local handle = io.popen('bazel query //... --output=label 2>/dev/null')
        if handle then
          for line in handle:lines() do
            if line and line ~= '' then
              table.insert(targets, line)
            end
          end
          handle:close()
        end
        return targets
      end

      -- Format Bazel command
      local function format_bazel_command(action, target, config_flags, extra_flags)
        local common_flags_str = table.concat(common_flags, ' ')
        local cmd = string.format('bazel %s %s %s %s %s', 
          action, 
          target or '', 
          config_flags or '', 
          common_flags_str,
          extra_flags or '')
        return cmd:gsub('%s+', ' '):gsub('^%s*(.-)%s*$', '%1')
      end

      -- Get config flags by name
      local function get_config_flags(config_name)
        for _, config in ipairs(bazel_configs) do
          if config.name == config_name then
            return config.flags
          end
        end
        return ''
      end

      -- Bazel build with completion
      local function bazel_build_with_completion()
        local targets = get_bazel_targets()
        vim.ui.select(targets, {
          prompt = 'Build target: ',
        }, function(target)
          if target then
            local config_flags = get_config_flags(current_config)
            local cmd = format_bazel_command('build', target, config_flags, nil)
            vim.cmd('compiler! make | make! ' .. cmd)
            vim.notify('Building ' .. target .. ' with config: ' .. current_config, vim.log.levels.INFO)
          end
        end)
      end

      -- Bazel build with config selection
      local function bazel_build_advanced()
        local targets = get_bazel_targets()
        vim.ui.select(targets, {
          prompt = 'Build target: ',
        }, function(target)
          if target then
            local config_names = {}
            for _, config in ipairs(bazel_configs) do
              table.insert(config_names, config.name)
            end
            
            vim.ui.select(config_names, {
              prompt = 'Build configuration (current: ' .. current_config .. '): ',
            }, function(config)
              if config then
                current_config = config
                vim.ui.input({
                  prompt = 'Extra flags (optional): ',
                }, function(extra_flags)
                  local config_flags = get_config_flags(config)
                  local cmd = format_bazel_command('build', target, config_flags, extra_flags)
                  vim.cmd('compiler! make | make! ' .. cmd)
                  vim.notify('Building ' .. target .. ' with config: ' .. config, vim.log.levels.INFO)
                end)
              end
            end)
          end
        end)
      end

      -- Bazel test functions
      local function bazel_test_with_completion()
        local targets = get_bazel_targets()
        vim.ui.select(targets, {
          prompt = 'Test target: ',
        }, function(target)
          if target then
            local config_flags = get_config_flags(current_config)
            local cmd = format_bazel_command('test', target, config_flags, '--test_output=all')
            vim.cmd('compiler! make | make! ' .. cmd)
          end
        end)
      end

      -- Bazel run functions
      local function bazel_run_with_completion()
        local targets = get_bazel_targets()
        vim.ui.select(targets, {
          prompt = 'Run target: ',
        }, function(target)
          if target then
            local config_flags = get_config_flags(current_config)
            local cmd = format_bazel_command('run', target, config_flags, nil)
            vim.cmd('compiler! make | make! ' .. cmd)
          end
        end)
      end

      -- Set default config
      local function set_default_config()
        local config_names = {}
        for _, config in ipairs(bazel_configs) do
          table.insert(config_names, config.name)
        end
        
        vim.ui.select(config_names, {
          prompt = 'Set default configuration (current: ' .. current_config .. '): ',
        }, function(config)
          if config then
            current_config = config
            vim.notify('Default configuration set to: ' .. config, vim.log.levels.INFO)
          end
        end)
      end

      -- Show current config
      local function show_current_config()
        vim.notify('Current Bazel configuration: ' .. current_config, vim.log.levels.INFO)
      end

      -- Clean functions
      local function bazel_clean()
        vim.cmd('compiler! make | make! bazel clean')
      end

      local function bazel_clean_expunge()
        vim.ui.input({
          prompt = 'This will remove the entire Bazel working tree. Continue? (y/N): ',
        }, function(input)
          if input and (input:lower() == 'y' or input:lower() == 'yes') then
            vim.cmd('compiler! make | make! bazel clean --expunge')
          end
        end)
      end

      -- List targets
      local function bazel_list_targets()
        local targets = get_bazel_targets()
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, targets)
        vim.api.nvim_buf_set_name(buf, 'Bazel Targets')
        vim.api.nvim_win_set_buf(0, buf)
      end

      -- Query function
      local function bazel_query()
        vim.ui.input({
          prompt = 'Bazel query: ',
        }, function(query)
          if query and query ~= '' then
            vim.cmd("compiler! make | make! bazel query '" .. query .. "'")
          end
        end)
      end

      -- Info function
      local function bazel_info()
        vim.cmd('compiler! make | make! bazel info')
      end

      -- Refresh compile_commands.json
      local function refresh_compile_commands()
        vim.cmd('compiler! make | make! bazel run //:refresh_compile_commands')
        vim.notify('Refreshing compile_commands.json...', vim.log.levels.INFO)
      end

      -- Global keybindings (matching Emacs SPC B prefix)
      vim.keymap.set('n', '<leader>bb', bazel_build_with_completion, { desc = 'Bazel: Build target' })
      vim.keymap.set('n', '<leader>bB', bazel_build_advanced, { desc = 'Bazel: Build (advanced)' })
      vim.keymap.set('n', '<leader>br', bazel_run_with_completion, { desc = 'Bazel: Run target' })
      vim.keymap.set('n', '<leader>bt', bazel_test_with_completion, { desc = 'Bazel: Test target' })
      vim.keymap.set('n', '<leader>bc', set_default_config, { desc = 'Bazel: Set default config' })
      vim.keymap.set('n', '<leader>bs', show_current_config, { desc = 'Bazel: Show current config' })
      vim.keymap.set('n', '<leader>bx', bazel_clean, { desc = 'Bazel: Clean' })
      vim.keymap.set('n', '<leader>bX', bazel_clean_expunge, { desc = 'Bazel: Clean (expunge)' })
      vim.keymap.set('n', '<leader>bl', bazel_list_targets, { desc = 'Bazel: List targets' })
      vim.keymap.set('n', '<leader>bq', bazel_query, { desc = 'Bazel: Query' })
      vim.keymap.set('n', '<leader>bi', bazel_info, { desc = 'Bazel: Info' })
      vim.keymap.set('n', '<leader>bg', refresh_compile_commands, { desc = 'Bazel: Refresh compile_commands' })

      -- Add which-key groups
      local ok, wk = pcall(require, 'which-key')
      if ok then
        wk.add({
          { '<leader>b', group = '[B]azel' },
        })
      end

      -- File associations
      vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
        pattern = { 'BUILD', 'BUILD.bazel', '*.bzl', 'WORKSPACE', 'WORKSPACE.bazel' },
        callback = function()
          vim.opt_local.filetype = 'bzl'
        end,
      })
    end,
  },
}