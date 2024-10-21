require('gitsigns').setup {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        -- This is the function that runs, AFTER loading
        --[[ "Jump to next hunk" ]]
        vim.keymap.set('n', ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            require('gitsigns').next_hunk()
          end)
          return '<Ignore>'
        end, { desc = 'Jump to next hunk' })
        vim.keymap.set('n', '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            require('gitsigns').prev_hunk()
          end)
          return '<Ignore>'
        end, { desc = 'Jump to prev hunk' })
        vim.keymap.set('n', '<leader>rh', require('gitsigns').reset_hunk, { desc = 'Reset hunk' })
        vim.keymap.set('n', '<leader>ph', require('gitsigns').preview_hunk, { desc = 'Preview hunk' })
        vim.keymap.set('n', '<leader>th', require('gitsigns').toggle_deleted, { desc = 'Toggle deleted' })
      end,
}
