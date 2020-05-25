local _config = {}
local default_config = {
  kind_labels = {}
}

_config = vim.deepcopy(default_config)
local messages = {}

-- Diagnostics
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


local function configure(config)
  _config = vim.tbl_extend('keep', config, _config, default_config)
  pyls_ms._init(messages, _config)
  clangd._init(messages, _config)
  messaging._init(messages, _config)
  current_function._init(messages, _config)
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
}

return M
