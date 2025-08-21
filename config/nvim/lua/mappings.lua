require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<leader>sle", function()
  vim.opt.spelllang = "en"
  vim.cmd("echo 'Spell language set to English'")
end, {desc = "Spelling language Eglish"})

map("n", "<leader>slr", function()
  vim.opt.spelllang = "ru"
  vim.cmd("echo 'Spell language set to Russian'")
end, {desc = "Spelling language Russian"})

map("n", "<leader>slb", function()
  vim.opt.spelllang = "en,ru"
  vim.cmd("echo 'Spell language set to English and Russian'")
end, {desc = "Spelling language Eglish and Russian"})
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
