local theme = require("autumn.theme")
local config = require("autumn.config")

local M = {}

function M.autocmds(config)
  local group = vim.api.nvim_create_augroup("autumn", { clear = true })

  vim.api.nvim_create_autocmd("ColorSchemePre", {
    group = group,
    callback = function()
      vim.api.nvim_del_augroup_by_id(group)
    end,
  })
  local function set_whl()
    local win = vim.api.nvim_get_current_win()
    local whl = vim.split(vim.wo[win].winhighlight, ",")
    vim.list_extend(whl, { "Normal:NormalSB", "SignColumn:SignColumnSB" })
    whl = vim.tbl_filter(function(hl)
      return hl ~= ""
    end, whl)
    vim.opt_local.winhighlight = table.concat(whl, ",")
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = table.concat(config.sidebars, ","),
    callback = set_whl,
  })
  if vim.tbl_contains(config.sidebars, "terminal") then
    vim.api.nvim_create_autocmd("TermOpen", {
      group = group,
      callback = set_whl,
    })
  end
end

function M.syntax(syntax)
  for group, hl in pairs(syntax) do
    if hl.style then
      if type(hl.style) == "table" then
        hl = vim.tbl_extend("force", hl, hl.style)
      elseif hl.style:lower() ~= "none" then
        -- handle old string style definitions
        for s in string.gmatch(hl.style, "([^,]+)") do
          hl[s] = true
        end
      end
      hl.style = nil
    end
    vim.api.nvim_set_hl(0, group, hl)
  end
end

function M.terminal(colors)
  -- dark
  vim.g.terminal_color_0 = colors.black
  vim.g.terminal_color_8 = colors.terminal_black

  -- light
  vim.g.terminal_color_7 = colors.fg_dark
  vim.g.terminal_color_15 = colors.fg

  -- colors
  vim.g.terminal_color_1 = colors.red
  vim.g.terminal_color_9 = colors.red

  vim.g.terminal_color_2 = colors.green
  vim.g.terminal_color_10 = colors.green

  vim.g.terminal_color_3 = colors.yellow
  vim.g.terminal_color_11 = colors.yellow

  vim.g.terminal_color_4 = colors.blue
  vim.g.terminal_color_12 = colors.blue

  vim.g.terminal_color_5 = colors.magenta
  vim.g.terminal_color_13 = colors.magenta

  vim.g.terminal_color_6 = colors.cyan
  vim.g.terminal_color_14 = colors.cyan
end

function M.load(opts)
  if opts then
    config.extend(opts)
  end
  local t = theme.setup()

  -- only needed to clear when not the default colorscheme
  if vim.g.colors_name then
    vim.cmd("hi clear")
  end

  vim.o.termguicolors = true
  vim.g.colors_name = "autumn"

  M.syntax(t.highlights)

  M.terminal(t.colors)

  M.autocmds(t.config)

  vim.defer_fn(function()
    M.syntax(t.defer)
  end, 100)
end

M.setup = config.setup

return M
