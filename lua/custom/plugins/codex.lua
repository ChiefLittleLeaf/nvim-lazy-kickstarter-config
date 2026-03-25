return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      terminal = {},
    },
    config = function(_, opts)
      require('snacks').setup(opts)

      local function project_root()
        local cwd = vim.fn.expand '%:p:h'
        if cwd == '' then
          cwd = vim.loop.cwd()
        end

        local git_root = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(cwd) .. ' rev-parse --show-toplevel')[1]
        if vim.v.shell_error == 0 and git_root and git_root ~= '' then
          return git_root
        end

        return vim.loop.cwd()
      end

      local function shellescape_multiline(text)
        return vim.fn.shellescape(text)
      end

      local function open_codex(opts2)
        opts2 = opts2 or {}
        local root = opts2.cwd or project_root()
        local prompt = opts2.prompt

        local cmd = 'codex'
        if prompt and prompt ~= '' then
          cmd = cmd .. ' ' .. shellescape_multiline(prompt)
        end

        if opts2.float then
          require('snacks').terminal.toggle(cmd, {
            cwd = root,
            win = {
              position = 'float',
              border = 'rounded',
              width = 0.9,
              height = 0.9,
            },
          })
        else
          vim.cmd 'vsplit'
          vim.cmd 'wincmd L'
          vim.cmd 'vertical resize 70'
          require('snacks').terminal.open(cmd, {
            cwd = root,
          })
          vim.cmd 'startinsert'
        end
      end

      local function current_file_context()
        local name = vim.api.nvim_buf_get_name(0)
        if name == '' then
          return 'Current buffer has no file name.'
        end

        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local content = table.concat(lines, '\n')

        return table.concat({
          'Review this file.',
          '',
          'Path: ' .. name,
          '',
          'Please focus on:',
          '- correctness bugs',
          '- risky edge cases',
          '- bad assumptions',
          '- maintainability problems',
          '- missing tests',
          '',
          'File contents:',
          '```',
          content,
          '```',
        }, '\n')
      end

      local function visual_selection_text()
        local mode = vim.fn.mode()
        if mode ~= 'v' and mode ~= 'V' and mode ~= '\022' then
          return nil
        end

        local start_pos = vim.fn.getpos 'v'
        local end_pos = vim.fn.getpos '.'
        local start_line = start_pos[2]
        local start_col = start_pos[3]
        local end_line = end_pos[2]
        local end_col = end_pos[3]

        if start_line > end_line or (start_line == end_line and start_col > end_col) then
          start_line, end_line = end_line, start_line
          start_col, end_col = end_col, start_col
        end

        local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
        if #lines == 0 then
          return nil
        end

        lines[1] = string.sub(lines[1], start_col)
        lines[#lines] = string.sub(lines[#lines], 1, end_col)

        return table.concat(lines, '\n')
      end

      local function git_diff_prompt()
        local root = project_root()
        local diff = vim.fn.systemlist('git -C ' .. vim.fn.shellescape(root) .. ' diff -- .')
        if vim.v.shell_error ~= 0 then
          return nil, root
        end

        local text = table.concat(diff, '\n')
        if text == '' then
          text = '(No unstaged diff found.)'
        end

        local prompt = table.concat({
          'Review this git diff.',
          '',
          'Focus on:',
          '- correctness issues',
          '- regressions',
          '- risky changes',
          '- missing tests',
          '- API or behavior changes',
          '',
          'Git diff:',
          '```diff',
          text,
          '```',
        }, '\n')

        return prompt, root
      end

      vim.api.nvim_create_user_command('Codex', function()
        open_codex()
      end, {})

      vim.api.nvim_create_user_command('CodexFloat', function()
        open_codex { float = true }
      end, {})

      vim.api.nvim_create_user_command('CodexHere', function()
        open_codex { cwd = project_root() }
      end, {})

      vim.api.nvim_create_user_command('CodexReview', function()
        open_codex {
          cwd = project_root(),
          prompt = current_file_context(),
        }
      end, {})

      vim.api.nvim_create_user_command('CodexDiff', function()
        local prompt, root = git_diff_prompt()
        if not prompt then
          vim.notify('Failed to get git diff', vim.log.levels.ERROR)
          return
        end

        open_codex {
          cwd = root,
          prompt = prompt,
        }
      end, {})

      vim.keymap.set('n', '<leader>ac', '<cmd>Codex<cr>', {
        desc = 'Open Codex split',
      })

      vim.keymap.set('n', '<leader>aC', '<cmd>CodexFloat<cr>', {
        desc = 'Open Codex float',
      })

      vim.keymap.set('n', '<leader>ar', '<cmd>CodexReview<cr>', {
        desc = 'Review current file with Codex',
      })

      vim.keymap.set('n', '<leader>ad', '<cmd>CodexDiff<cr>', {
        desc = 'Review git diff with Codex',
      })

      vim.keymap.set('v', '<leader>as', function()
        local selected = visual_selection_text()
        if not selected or selected == '' then
          vim.notify('No visual selection found', vim.log.levels.WARN)
          return
        end

        local file = vim.api.nvim_buf_get_name(0)
        local prompt = table.concat({
          'Analyze this selected code.',
          '',
          'Path: ' .. (file ~= '' and file or '[No Name]'),
          '',
          'Focus on correctness, clarity, edge cases, and better alternatives.',
          '',
          'Selected code:',
          '```',
          selected,
          '```',
        }, '\n')

        open_codex {
          cwd = project_root(),
          prompt = prompt,
        }
      end, {
        desc = 'Send selection to Codex',
      })
    end,
  },
}
