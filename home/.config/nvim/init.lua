vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Keep plugin management minimal: mini.nvim provides independent picker and
-- explorer modules, so no Neovim distribution or general plugin manager is
-- needed. A stable release compatible with Neovim 0.9+ is installed once.
local mini_path = vim.fn.stdpath("data") .. "/site/pack/deps/start/mini.nvim"
local uv = vim.uv or vim.loop

if not uv.fs_stat(mini_path) then
  vim.fn.mkdir(vim.fn.fnamemodify(mini_path, ":h"), "p")
  local output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=v0.17.0",
    "--single-branch",
    "https://github.com/nvim-mini/mini.nvim",
    mini_path,
  })

  if vim.v.shell_error ~= 0 then
    error("Failed to install mini.nvim:\n" .. output)
  end
end

vim.cmd.packadd("mini.nvim")

vim.opt.ignorecase = true
vim.opt.smartcase = true

local pick = require("mini.pick")
pick.setup()

local function pick_project_files()
  local cwd = vim.fn.getcwd()
  local git_root_output = vim.fn.systemlist({ "git", "-C", cwd, "rev-parse", "--show-toplevel" })
  local git_root = vim.v.shell_error == 0 and git_root_output[1] or nil

  if git_root and git_root ~= "" then
    -- Include tracked and untracked files (including dotfiles), while honoring
    -- .gitignore, from the project root even when Neovim starts in a subdir.
    pick.builtin.files({ tool = "git" }, { source = { cwd = git_root } })
  else
    pick.builtin.files({ tool = "rg" }, { source = { cwd = cwd } })
  end
end

vim.keymap.set("n", "<C-p>", pick_project_files, { desc = "Find project files" })

local files = require("mini.files")
files.setup({
  mappings = {
    -- `l` opens a selected file and closes the explorer; `L` keeps it open.
    go_in = "L",
    go_in_plus = "l",
  },
  options = {
    permanent_delete = false,
    use_as_default_explorer = true,
  },
})

local function toggle_file_explorer()
  if files.close() then
    return
  end

  local path = vim.api.nvim_buf_get_name(0)
  files.open(path ~= "" and path or vim.fn.getcwd(), false)
end

vim.keymap.set("n", "<leader>e", toggle_file_explorer, { desc = "Toggle file explorer" })
