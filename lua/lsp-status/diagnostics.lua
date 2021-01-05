-- Gather diagnostics
local function get_all_diagnostics(bufnr)
  local result = {}
  local levels = {
    errors = 'Error',
    warnings = 'Warning',
    info = 'Information',
    hints = 'Hint'
  }

  for k, level in pairs(levels) do
    result[k] = vim.lsp.diagnostic.get_count(bufnr, level)
  end

  return result
end

return get_all_diagnostics
