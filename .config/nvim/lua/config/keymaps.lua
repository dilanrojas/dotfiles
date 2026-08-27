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
