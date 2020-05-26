local util = require('lsp-status/util')

local messages = {}

local function init(_messages, _)
  messages = _messages
end

local function ensure_init(id)
  util.ensure_init(messages, id, 'clangd')
end

local callbacks = {
  ['textDocument/clangd.fileStatus'] = function(_, _, statusMessage, client_id)
    ensure_init(client_id)
    messages[client_id].status = { uri = statusMessage.uri, content = statusMessage.state }
    vim.api.nvim_command('doautocmd User LspMessageUpdate')
  end,
}

local function setup()
  return callbacks
end

local M = {
  _init = init,
  setup = setup
}

M = vim.tbl_extend('error', M, callbacks)

return M
