return {
  {
    'saghen/blink.cmp',
    version = false, -- latest/main
    dependencies = {
      'saghen/blink.lib',
      'rafamadriz/friendly-snippets',
    },
    opts = {
      keymap = { preset = 'default' },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      fuzzy = {
        implementation = 'prefer_rust_with_warning',
      },
    },
  },
}
