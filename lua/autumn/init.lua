local util = require("autumn.util")
local theme = require("autumn.theme")
local config = require("autumn.config")

local M = {}

---@param opts Config|nil
function M.load(opts)
  if opts then
    require("autumn.config").extend(opts)
  end
  util.load(theme.setup())
end

M.setup = config.setup

-- keep for backward compatibility
M.colorscheme = M.load

return M
