-- Gather diagnostics
local function get_all_diagnostics()
  local result = {}
  local levels = {
    errors = 'Error',
    warnings = 'Warning',
    info = 'Information',
    hints = 'Hint'
  }

  for k, level in pairs(levels) do
    result[k] = vim.lsp.util.buf_diagnostics_count(level)
  end

  return result
end

return get_all_diagnostics
