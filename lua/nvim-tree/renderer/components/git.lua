local notify = require "nvim-tree.notify"
local explorer_node = require "nvim-tree.explorer.node"

local M = {
  SIGN_GROUP = "NvimTreeGitSigns",
}

local function build_icons_table(i)
  local icons = {
    staged = { icon = i.staged, hl = "NvimTreeGitStaged", ord = 1 },
    unstaged = { icon = i.unstaged, hl = "NvimTreeGitDirty", ord = 2 },
    renamed = { icon = i.renamed, hl = "NvimTreeGitRenamed", ord = 3 },
    deleted = { icon = i.deleted, hl = "NvimTreeGitDeleted", ord = 4 },
    unmerged = { icon = i.unmerged, hl = "NvimTreeGitMerge", ord = 5 },
    untracked = { icon = i.untracked, hl = "NvimTreeGitNew", ord = 6 },
    ignored = { icon = i.ignored, hl = "NvimTreeGitIgnored", ord = 7 },
  }
  return {
    ["M "] = { icons.staged },
    [" M"] = { icons.unstaged },
    ["C "] = { icons.staged },
    [" C"] = { icons.unstaged },
    ["CM"] = { icons.unstaged },
    [" T"] = { icons.unstaged },
    ["T "] = { icons.staged },
    ["MM"] = { icons.staged, icons.unstaged },
    ["MD"] = { icons.staged },
    ["A "] = { icons.staged },
    ["AD"] = { icons.staged },
    [" A"] = { icons.untracked },
    -- not sure about this one
    ["AA"] = { icons.unmerged, icons.untracked },
    ["AU"] = { icons.unmerged, icons.untracked },
    ["AM"] = { icons.staged, icons.unstaged },
    ["??"] = { icons.untracked },
    ["R "] = { icons.renamed },
    [" R"] = { icons.renamed },
    ["RM"] = { icons.unstaged, icons.renamed },
    ["UU"] = { icons.unmerged },
    ["UD"] = { icons.unmerged },
    ["UA"] = { icons.unmerged },
    [" D"] = { icons.deleted },
    ["D "] = { icons.deleted },
    ["RD"] = { icons.deleted },
    ["DD"] = { icons.deleted },
    ["DU"] = { icons.deleted, icons.unmerged },
    ["!!"] = { icons.ignored },
    dirty = { icons.unstaged },
  }
end

local function nil_() end

local function warn_status(git_status)
  notify.warn(
    'Unrecognized git state "'
      .. git_status
      .. '". Please open up an issue on https://github.com/nvim-tree/nvim-tree.lua/issues with this message.'
  )
end

local function get_icons_(node)
  local git_status = explorer_node.get_git_status(node)
  if git_status == nil then
    return nil
  end

  local inserted = {}
  local iconss = {}

  for _, s in pairs(git_status) do
    local icons = M.git_icons[s]
    if not icons then
      if not M.config.highlight_git then
        warn_status(s)
      end
      return nil
    end

    for _, icon in pairs(icons) do
      if not inserted[icon] then
        table.insert(iconss, icon)
        inserted[icon] = true
      end
    end
  end

  return iconss
end

local git_hl = {
  ["M "] = "NvimTreeFileStaged",
  ["C "] = "NvimTreeFileStaged",
  ["AA"] = "NvimTreeFileStaged",
  ["AD"] = "NvimTreeFileStaged",
  ["MD"] = "NvimTreeFileStaged",
  ["T "] = "NvimTreeFileStaged",
  ["TT"] = "NvimTreeFileStaged",
  [" M"] = "NvimTreeFileDirty",
  ["CM"] = "NvimTreeFileDirty",
  [" C"] = "NvimTreeFileDirty",
  [" T"] = "NvimTreeFileDirty",
  ["MM"] = "NvimTreeFileDirty",
  ["AM"] = "NvimTreeFileDirty",
  dirty = "NvimTreeFileDirty",
  ["A "] = "NvimTreeFileNew",
  ["??"] = "NvimTreeFileNew",
  ["AU"] = "NvimTreeFileMerge",
  ["UU"] = "NvimTreeFileMerge",
  ["UD"] = "NvimTreeFileMerge",
  ["DU"] = "NvimTreeFileMerge",
  ["UA"] = "NvimTreeFileMerge",
  [" D"] = "NvimTreeFileDeleted",
  ["DD"] = "NvimTreeFileDeleted",
  ["RD"] = "NvimTreeFileDeleted",
  ["D "] = "NvimTreeFileDeleted",
  ["R "] = "NvimTreeFileRenamed",
  ["RM"] = "NvimTreeFileRenamed",
  [" R"] = "NvimTreeFileRenamed",
  ["!!"] = "NvimTreeFileIgnored",
  [" A"] = "none",
}

function M.setup_signs(i)
  vim.fn.sign_define("NvimTreeGitDirty", { text = i.unstaged, texthl = "NvimTreeGitDirty" })
  vim.fn.sign_define("NvimTreeGitStaged", { text = i.staged, texthl = "NvimTreeGitStaged" })
  vim.fn.sign_define("NvimTreeGitMerge", { text = i.unmerged, texthl = "NvimTreeGitMerge" })
  vim.fn.sign_define("NvimTreeGitRenamed", { text = i.renamed, texthl = "NvimTreeGitRenamed" })
  vim.fn.sign_define("NvimTreeGitNew", { text = i.untracked, texthl = "NvimTreeGitNew" })
  vim.fn.sign_define("NvimTreeGitDeleted", { text = i.deleted, texthl = "NvimTreeGitDeleted" })
  vim.fn.sign_define("NvimTreeGitIgnored", { text = i.ignored, texthl = "NvimTreeGitIgnored" })
end

local function get_highlight_(node)
  local git_status = explorer_node.get_git_status(node)
  if git_status == nil then
    return
  end

  return git_hl[git_status[1]]
end

function M.setup(opts)
  M.config = opts.renderer

  M.git_icons = build_icons_table(opts.renderer.icons.glyphs.git)

  M.setup_signs(opts.renderer.icons.glyphs.git)

  if opts.renderer.icons.show.git then
    M.get_icons = get_icons_
  else
    M.get_icons = nil_
  end

  if opts.renderer.highlight_git then
    M.get_highlight = get_highlight_
  else
    M.get_highlight = nil_
  end

  M.git_show_on_open_dirs = opts.git.show_on_open_dirs
end

return M
