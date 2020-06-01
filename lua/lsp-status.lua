local _config = {}
local default_config = {
  kind_labels = {},
  indicator_errors = '',
  indicator_warnings = '',
  indicator_info = '🛈',
  indicator_hint = '❗',
  indicator_ok = '',
  spinner_frames = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' },
  status_symbol = ' 🇻',
  select_symbol = nil
}

_config = vim.deepcopy(default_config)
local messages = {}

-- Diagnostics
--- Get all diagnostics for the current buffer.
--- Convenience function to retrieve all diagnostic counts for the current buffer.
--@returns `{ 'Error': error_count, 'Warning': warning_count', 'Info': info_count, 'Hint': hint_count `}
local function diagnostics() -- luacheck: no unused
  error() -- Stub for docs
end
local diagnostics = require('lsp-status/diagnostics')

-- Messaging
local messaging = require('lsp-status/messaging')

-- LSP extensions
local pyls_ms = require('lsp-status/extensions/pyls_ms')
local clangd = require('lsp-status/extensions/clangd')
local extension_callbacks = {
  pyls_ms = pyls_ms,
  clangd = clangd
}

-- Find current enclosing function
local current_function = require('lsp-status/current_function')

-- Out-of-the-box statusline component
local statusline = require('lsp-status/statusline')

local function configure(config)
  _config = vim.tbl_extend('keep', config, _config, default_config)
  pyls_ms._init(messages, _config)
  clangd._init(messages, _config)
  messaging._init(messages, _config)
  current_function._init(messages, _config)
end

local function on_attach(client)
  -- Register the client for messages
  messaging.register_client(client.id, client.name)

  -- Set up autocommands to refresh the statusline when information changes
  vim.api.nvim_command('augroup lsp_aucmds')
  vim.api.nvim_command('au! * <buffer>')
  vim.api.nvim_command('au User LspDiagnosticsChanged redrawstatus!')
  vim.api.nvim_command('au User LspMessageUpdate redrawstatus!')
  vim.api.nvim_command('au User LspStatusUpdate redrawstatus!')
  vim.api.nvim_command('augroup END')

  -- If the client is a documentSymbolProvider, set up an autocommand
  -- to update the containing symbol
  if client.resolved_capabilities.document_symbol then
    vim.api.nvim_command('augroup lsp_aucmds')
    vim.api.nvim_command(
      'au CursorHold <buffer> lua require("lsp-status").update_current_function()'
    )
    vim.api.nvim_command('augroup END')
  end
end

configure(_config)

local M = {
  update_current_function = current_function.update,
  diagnostics = diagnostics,
  messages = messaging.messages,
  register_progress = messaging.register_progress,
  register_client = messaging.register_client,
  extensions = extension_callbacks,
  config = configure,
  on_attach = on_attach,
  status = statusline.status,
  capabilities = messaging.capabilities
}

return M
