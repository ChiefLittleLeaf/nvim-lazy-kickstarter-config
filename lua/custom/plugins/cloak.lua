return {
  'laytan/cloak.nvim',
  config = function()
    require('cloak').setup {
      enabled = true,
      -- NOTE: Keep this incase i need to flip the config
      --cloak_character = '*',
      cloak_character = '🍖🥔',
      -- The applied highlight group (colors) on the cloaking, see `:h highlight`.
      highlight_group = 'Comment',
      patterns = {
        {
          -- Match any file starting with ".env".
          -- This can be a table to match multiple file patterns.
          file_pattern = {
            '*.env*',
            '*.toml*',
            '*.conf*',
            '*.config*',
            '*.cfg*',
          },
          -- Match an equals sign and any character after it.
          -- This can also be a table of patterns to cloak,
          -- example: cloak_pattern = { ":.+", "-.+" } for yaml files.
          cloak_pattern = '=.+',
        },
      },
    }
  end,
}
