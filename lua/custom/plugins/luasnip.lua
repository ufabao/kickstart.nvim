return {
  'L3MON4D3/LuaSnip',
  version = 'v2.*',
  build = 'make install_jsregexp',
  dependencies = {
    'rafamadriz/friendly-snippets',
    'hrsh7th/nvim-cmp',
    'saadparwaiz1/cmp_luasnip',
  },
  config = function()
    local ls = require 'luasnip'

    -- Load friendly-snippets
    require('luasnip.loaders.from_vscode').lazy_load()

    -- Define a C++ class snippet
    ls.add_snippets('cpp', {
      ls.snippet({
        trigger = 'class',
        name = 'C++ Class Declaration',
        dscr = 'Create a C++ class with standard structure',
      }, {
        ls.text_node 'class ',
        ls.insert_node(1, 'ClassName'),
        ls.text_node ' {',
        ls.text_node { '', 'public:' },
        ls.text_node { '', '    ' },
        ls.insert_node(2),
        ls.text_node { '', '};' },
      }),
    })

    -- For auto-expanding snippets
    vim.keymap.set({ 'i', 's' }, '<Tab>', function()
      if ls.expand_or_jumpable() then
        return '<Plug>luasnip-expand-or-jump'
      else
        return '<Tab>'
      end
    end, { silent = true, expr = true })
  end,
}
