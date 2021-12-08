-- Gather diagnostics
local levels = {
  errors = vim.diagnostic.severity.ERROR,
  warnings = vim.diagnostic.severity.WARN,
  info = vim.diagnostic.severity.INFO,
  hints = vim.diagnostic.severity.HINT,
}

local function get_all_diagnostics(bufnr)
  local result = {}
  for k, level in pairs(levels) do
    result[k] = #vim.diagnostic.get(bufnr, { severity = level })
  end

  return result
end

return get_all_diagnostics
