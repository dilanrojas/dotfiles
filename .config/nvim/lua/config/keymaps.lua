-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Map <leader>rj to Run Java
vim.keymap.set("n", "<leader>jr", function()
  -- 1. Save the current file
  vim.cmd("silent w")

  -- 2. Clear the terminal and run the command
  -- Note: This assumes you are in the project root
  local run_cmd = "clear && java -cp target/classes Main"

  -- 3. Execute in a horizontal split terminal
  vim.cmd("split | term " .. run_cmd)

  -- 4. Automatically enter insert mode to interact with the menu
  vim.cmd("startinsert")
end, { desc = "Clear console and Run Java Main" })

vim.keymap.set("n", "<leader>ww", function()
  vim.cmd("noautocmd w")
end, { desc = "Save file without formatting" })

vim.keymap.set("x", "<leader>p", '"_dP')

vim.keymap.set("n", "<leader>op", function()
  vim.cmd("topleft vertical 46split")
  vim.cmd("terminal")

  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()

  vim.defer_fn(function()
    local job = vim.api.nvim_buf_get_var(buf, "terminal_job_id")
    vim.fn.chansend(job, "opencode .\n")

    -- Force a terminal resize after OpenCode starts
    vim.defer_fn(function()
      if not vim.api.nvim_win_is_valid(win) then
        return
      end

      local width = vim.api.nvim_win_get_width(win)
      if width > 1 then
        vim.api.nvim_win_set_width(win, width - 1)
        vim.api.nvim_win_set_width(win, width)
      end
    end, 300)
  end, 500)

  vim.cmd("startinsert")
end)
