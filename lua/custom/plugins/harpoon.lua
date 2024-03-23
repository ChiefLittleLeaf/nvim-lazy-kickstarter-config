return {
  -- Harpoon plugin configuration
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    lazy = false,
    --[[TODO: Figure out why its not working well with treesitter
    config = function()
      require("harpoon").setup({})

      local function toggle_telescope_with_harpoon(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        require("telescope.pickers")
          .new({}, {
            prompt_title = "Harpoon",
            finder = require("telescope.finders").new_table({
              results = file_paths,
            }),
            previewer = require("telescope.config").values.file_previewer({}),
            sorter = require("telescope.config").values.generic_sorter({}),
          })
          :find()
      end
      vim.keymap.set("n", "<leader>A", function()
        local harpoon = require("harpoon")
        toggle_telescope_with_harpoon(harpoon:list())
      end, { desc = "Open harpoon window" })
    end,]]
    --
    keys = {
      {
        '<leader>a',
        function()
          require('harpoon'):list():append()
        end,
        desc = 'harpoon file',
      },
      {
        '<C-e>',
        function()
          local harpoon = require 'harpoon'
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = 'harpoon quick menu',
      },
      {
        '<C-h>',
        function()
          require('harpoon'):list():select(1)
        end,
        desc = 'harpoon to file 1',
      },
      {
        '<C-t>',
        function()
          require('harpoon'):list():select(2)
        end,
        desc = 'harpoon to file 2',
      },
      {
        '<C-s>',
        function()
          require('harpoon'):list():select(3)
        end,
        desc = 'harpoon to file 3',
      },
      {
        '<C-s>',
        function()
          require('harpoon'):list():select(3)
        end,
        desc = 'harpoon to file 4',
      },
    },
  },
}
