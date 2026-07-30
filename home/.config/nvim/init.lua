vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- nvim-tree recommends disabling netrw before plugins are loaded to avoid
-- startup races over directory buffers.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

-- Keep plugin management minimal: install a few pinned, independent plugins
-- as native start packages rather than introducing a Neovim distribution.
local package_root = vim.fn.stdpath("data") .. "/site/pack/deps/start"
local uv = vim.uv or vim.loop

local function ensure_plugin(name, source, version)
  local path = package_root .. "/" .. name
  if not uv.fs_stat(path) then
    vim.fn.mkdir(package_root, "p")
    local output = vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "--branch=" .. version,
      "--single-branch",
      source,
      path,
    })

    if vim.v.shell_error ~= 0 then
      error("Failed to install " .. name .. ":\n" .. output)
    end
  end

  vim.cmd.packadd(name)
end

ensure_plugin("mini.nvim", "https://github.com/nvim-mini/mini.nvim", "v0.17.0")
ensure_plugin("nvim-web-devicons", "https://github.com/nvim-tree/nvim-web-devicons", "v0.100")
ensure_plugin("nvim-tree.lua", "https://github.com/nvim-tree/nvim-tree.lua", "v1.18.0")

vim.opt.ignorecase = true
vim.opt.smartcase = true

local pick = require("mini.pick")
pick.setup()

-- Include hidden project files in ripgrep searches while still honoring ignore
-- files; explicitly exclude Git's internal directory.
vim.env.RIPGREP_CONFIG_PATH = vim.fn.stdpath("config") .. "/ripgreprc"

local function project_root()
  local cwd = vim.fn.getcwd()
  local git_root_output = vim.fn.systemlist({ "git", "-C", cwd, "rev-parse", "--show-toplevel" })
  local git_root = vim.v.shell_error == 0 and git_root_output[1] or nil
  return git_root and git_root ~= "" and git_root or cwd, git_root ~= nil
end

local function pick_project_files()
  local root, in_git = project_root()
  if in_git then
    -- Include tracked and untracked files (including dotfiles), while honoring
    -- .gitignore, from the project root even when Neovim starts in a subdir.
    pick.builtin.files({ tool = "git" }, { source = { cwd = root } })
  else
    pick.builtin.files({ tool = "rg" }, { source = { cwd = root } })
  end
end

local function grep_project()
  local root = project_root()
  pick.builtin.grep_live({ tool = "rg" }, { source = { cwd = root } })
end

vim.keymap.set("n", "<C-p>", pick_project_files, { desc = "Find project files" })
vim.keymap.set("n", "<leader>fg", grep_project, { desc = "Grep project contents" })

require("nvim-tree").setup({
  disable_netrw = true,
  sync_root_with_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = {
      enable = false,
    },
  },
  view = {
    side = "left",
    width = 32,
    preserve_window_proportions = true,
  },
  renderer = {
    group_empty = true,
    highlight_opened_files = "name",
    indent_markers = {
      enable = true,
    },
  },
  filters = {
    dotfiles = false,
    git_ignored = true,
  },
  filesystem_watchers = {
    enable = true,
  },
  tab = {
    sync = {
      open = true,
      close = true,
    },
  },
})

local tree_api = require("nvim-tree.api")

vim.keymap.set("n", "<leader>e", function()
  tree_api.tree.toggle({ find_file = true, focus = true })
end, { desc = "Toggle file tree" })

-- Keep the tree visible as a project sidebar while leaving focus in the editor.
vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Open persistent project tree",
  callback = function()
    if #vim.api.nvim_list_uis() == 0 then
      return
    end

    local editor_window = vim.api.nvim_get_current_win()
    tree_api.tree.open({ find_file = vim.fn.argc() > 0 })
    if vim.api.nvim_win_is_valid(editor_window) then
      vim.api.nvim_set_current_win(editor_window)
    end
  end,
})
