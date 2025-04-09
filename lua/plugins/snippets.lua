return {
  'L3MON4D3/LuaSnip',
  dependencies = { 'rafamadriz/friendly-snippets' },
  config = function()
    require('luasnip.loaders.from_vscode').lazy_load()

    local ls = require 'luasnip'
    ls.add_snippets('cpp', {
      ls.snippet('class', {
        ls.text_node 'class ',
        ls.insert_node(1, 'name'),
        ls.text_node ' {\npublic:\n\t',
        ls.insert_node(2),
        ls.text_node '\n};',
      }),
    })
  end,
}
