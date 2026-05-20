return {
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    branch = 'main',
    build = ':TSUpdate',

    config = function()
      require('nvim-treesitter').setup()

      require('nvim-treesitter').install {
        'bash',
        'c',
        'html',
        'lua',
        'markdown',
        'vim',
        'vimdoc',
      }

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'bash', 'c', 'html', 'lua', 'markdown', 'vim', 'vimdoc' },
        callback = function()
          vim.treesitter.start()
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'bash', 'c', 'html', 'lua', 'markdown', 'vim', 'vimdoc' },
        callback = function()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
