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
local function current_function_callback(_, result)
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

local function first_capable_client(bufnr, capability)
  local clients = vim.lsp.buf_get_clients(bufnr)
  for _, client in pairs(clients) do
    if client.resolved_capabilities[capability] then
      return client
    end
  end
end

local function update_current_function()
  local client = first_capable_client(0, "document_symbol")
  if client then
    local params = { textDocument = lsp_util.make_text_document_params() }
    client.request('textDocument/documentSymbol', params, util.mk_handler(current_function_callback), 0)
  else
    -- clear current function so we don't show stale information
    vim.b.lsp_current_function = ''
    redraw.redraw()
  end
end

local M = {
  update = update_current_function,
  _init = init
}

return M
