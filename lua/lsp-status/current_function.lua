-- Utilities
local lsp_util = require('vim.lsp.util')
local util = require('lsp-status/util')
local redraw = require('lsp-status/redraw')

local _config = {}

local function init(_, config)
  _config = config
end

-- the symbol kinds which are valid scopes
local scope_kinds = {
 Class = true,
 Function = true,
 Method = true,
 Struct = true,
 Enum = true,
 Interface = true,
 Namespace = true,
 Module = true,
}

-- Find current function context
local function current_function_callback(_, _, result, _, _)
  vim.b.lsp_current_function = ''
  if type(result) ~= 'table' then
    return
  end

  local function_symbols = util.filter(util.extract_symbols(result),
    function(_, v)
      return scope_kinds[v.kind]
    end)

  if not function_symbols or #function_symbols == 0 then
    redraw.redraw()
    return
  end

  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  for i = #function_symbols, 1, -1 do
    local sym = function_symbols[i]
    if
      (sym.range and util.in_range(cursor_pos, sym.range))
      or (_config.select_symbol and _config.select_symbol(cursor_pos, sym.raw_item))
    then
      local fn_name = sym.text
      if _config.kind_labels and _config.kind_labels[sym.kind] then
        fn_name = _config.kind_labels[sym.kind] .. ' ' .. fn_name
      end

      vim.b.lsp_current_function = fn_name
      redraw.redraw()
      return
    end
  end
end

local function update_current_function()
  local params = { textDocument = lsp_util.make_text_document_params() }
  vim.lsp.buf_request(0, 'textDocument/documentSymbol', params, current_function_callback)
end

local M = {
  update = update_current_function,
  _init = init
}

return M
