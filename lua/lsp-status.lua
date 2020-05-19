local lsp_util = require('vim.lsp.util')
local util = require('lsp-status/util')

local _config = {}
local default_config = {
  kind_labels = {}
}

_config = vim.deepcopy(default_config)
local messages = {}

-- Progress messages
local progress = require('lsp-status/progress')
progress._init(messages, _config)

local function register_progress()
  vim.lsp.callbacks['$/progress'] = progress.progress_callback
end


-- Client registration for messages
local function register_client(client_name, bufnr)
  local buf = bufnr or vim.fn.bufnr()
  if not messages[buf] then
    messages[buf] = {}
  end

  if not messages[buf][client_name] then
    messages[buf][client_name] = {}
  end
end

-- Miscellaneous LSP extensions
local pyls_ms = require('lsp-status/extensions/pyls_ms')
pyls_ms._init(messages, _config)
local clangd = require('lsp-status/extensions/clangd')
clangd._init(messages, _config)
local extension_callbacks = {
  pyls_ms = pyls_ms,
  clangd = clangd
}

-- Find current function context
local function current_function_callback(_, _, result, _, _)
  vim.b.lsp_current_function = ''
  local function_symbols = util.filter(util.extract_symbols(result),
    function(_, v)
      return v.kind == 'Class' or v.kind == 'Function' or v.kind == 'Method'
    end)

  if not function_symbols or #function_symbols == 0 then
    vim.api.nvim_command('doautocmd User LspStatusUpdate')
    return
  end

  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  for _, sym in ipairs(function_symbols) do
    if
      sym.range and
      util.in_range(cursor_pos, sym.range)
    then
      local fn_name = sym.text
      if _config.kind_labels[sym.kind] then
        fn_name = _config.kind_labels[sym.kind] .. ' ' .. fn_name
      end

      vim.b.lsp_current_function = fn_name
      vim.api.nvim_command('doautocmd User LspStatusUpdate')
      return
    end
  end
end

local function update_current_function()
  local params = { textDocument = lsp_util.make_text_document_params() }
  vim.lsp.buf_request(0, 'textDocument/documentSymbol', params, current_function_callback)
end

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

-- Process messages
local function get_messages()
  local buf = vim.fn.bufnr()
  if not messages[buf] then
    return {}
  end

  local buf_clients = messages[buf]
  local buf_messages = {}
  local msg_remove = {}
  local progress_remove = {}
  for client, msgs in pairs(buf_clients) do
    for i, msg in ipairs(msgs) do
      if msg.show_once then
        table.insert(msg_remove, { client = client, idx = i })
      end

      table.insert(buf_messages, { name = client, content = msg.content })
    end

    local progress_contexts = buf_clients[client].progress
    if progress_contexts then
      for token, ctx in pairs(progress_contexts) do
        table.insert(buf_messages, { name = client,
          title = ctx.title,
          message = ctx.message,
          percentage = ctx.percentage,
          progress = true,
          spinner = ctx.spinner,
        })

        if ctx.done then
          table.insert(progress_remove, { client = client, token = token })
        end
      end
    end
  end

  for _, item in ipairs(msg_remove) do
    table.remove(messages[buf][item.client], item.idx)
  end

  for _, item in ipairs(progress_remove) do
    messages[buf][item.client].progress[item.token] = nil
  end

  return buf_messages
end

local function configure(config)
  _config = vim.tbl_extend('keep', _config, config, default_config)
  pyls_ms._init(messages, _config)
  clangd._init(messages, _config)
  progress._init(messages, _config)
end

local M = {
  update_current_function = update_current_function,
  diagnostics = get_all_diagnostics,
  messages = get_messages,
  register_progress = register_progress,
  register_client = register_client,
  extension_callbacks = extension_callbacks,
  config = configure
}

return M
