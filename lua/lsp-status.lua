local _config = {}
local default_config = {
  kind_labels = {},
  current_function = true,
  indicator_separator = ' ',
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

--- Configure lsp-status.nvim.
--- Currently supported configuration variables are:
--- - `kind_labels`: A map from LSP symbol kinds to label symbols. Used to decorate the current
--- function name. Default: `{}`
--- - `select_symbol`: A callback of the form `function(cursor_pos, document_symbol)` that should
--- return `true` if `document_symbol` (a `DocumentSymbol`) should be accepted as the symbol
--- currently containing the cursor.
--- - `indicator_errors`: Symbol to place next to the error count in `status`. Default: '',
--- - `indicator_warnings`: Symbol to place next to the warning count in `status`. Default: '',
--- - `indicator_info`: Symbol to place next to the info count in `status`. Default: '🛈',
--- - `indicator_hint`: Symbol to place next to the hint count in `status`. Default: '❗',
--- - `indicator_ok`: Symbol to show in `status` if there are no diagnostics. Default: '',
--- - `spinner_frames`: Animation frames for progress spinner in `status`. Default: { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' },
--- - `status_symbol`: Symbol to start the statusline segment in `status`. Default: ' 🇻',
---
--@param config: (required, table) Table of values; keys are as listed above. Accept defaults by
--- omitting the relevant key.
local function config(user_config)
  _config = vim.tbl_extend('keep', user_config, _config, default_config)
  pyls_ms._init(messages, _config)
  clangd._init(messages, _config)
  messaging._init(messages, _config)
  if _config.current_function then current_function._init(messages, _config) end
  statusline._init(messages, _config)
  statusline = vim.tbl_extend('keep', statusline, statusline._get_component_functions())
end

--- Register a new server for messages.
--- Use this function either as your server's `on_attach` or inside your server's `on_attach`. It
--- registers the server with `lsp-status` for progress message handling and current function
--- updating
---
--@param client: (required, vim.lsp.client)
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
  if _config.current_function and client.resolved_capabilities.document_symbol then
    vim.api.nvim_command('augroup lsp_aucmds')
    vim.api.nvim_command(
      'au CursorHold <buffer> lua require("lsp-status").update_current_function()'
    )
    vim.api.nvim_command('augroup END')
  end
end

config(_config)

-- Stubs for documentation
--- Update the current function symbol.
--- Generally, you don't need to call this manually - |lsp-status.on_attach| sets up its use for you.
--- Sets the `b:lsp_current_function` variable.
local function update_current_function() -- luacheck: no unused
  error()
end

--- Return the current set of messages from all servers. Messages are either progress messages,
--- file status messages, or "normal" messages.
--- Progress messages are tables of the form
--- `{
---      name = Server name,
---      title = Progress item title,
---      message = Current progress message (if any),
---      percentage = Current progress percentage (if any),
---      progress = true,
---      spinner = Spinner frames index,
---    }`
---
--- File status messages are tables of the form
--- `{
---      name = Server name,
---      content = Message content,
---      uri = File URI,
---      status = true
---    }`
--- Normal messages are tables of the form
--- `{ name = Server name, content = Message contents }`
---
--@returns list of messages
local function messages() -- luacheck: no unused
  error()
end

--- Register the progress callback with Neovim's LSP client.
--- Call once before starting any servers
local function register_progress() -- luacheck: no unused
  error()
end

--- Register a new server to receive messages.
--- Generally, you don't need to call this manually - `on_attach` sets it up for you
---
--@param id: (required, number) Client ID
--@param name: (required, string) Client name
local function register_client(id, name) -- luacheck: no unused
  error()
end

--- Out-of-the-box statusline component.
--- Returns a statusline component with (1) a leading glyph, (2) the current function information,
--- and (3) diagnostic information. Call in your statusline definition.
--- Usable out of the box, but intended more as an example/template for modification to customize
--- to your own needs
---
--@returns: statusline component string
local function status() -- luacheck: no unused
  error()
end

--- Table of client capabilities including progress message capability.
--- Assign or extend your server's capabilities table with this
local function capabilities() -- luacheck: no unused
  error()
end

local M = {
  update_current_function = current_function.update,
  diagnostics = diagnostics,
  messages = messaging.messages,
  register_progress = messaging.register_progress,
  register_client = messaging.register_client,
  extensions = extension_callbacks,
  config = config,
  on_attach = on_attach,
  status = statusline.status,
  status_errors = statusline.errors,
  status_warnings = statusline.warnings,
  status_info = statusline.info,
  status_hints = statusline.hints,
  capabilities = messaging.capabilities
}

return M
