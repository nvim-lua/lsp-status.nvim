local util = require('lsp-status/util')

local messages = {}
local function init(_messages, _)
  messages = _messages
end

local function ensure_init(id)
  util.ensure_init(messages, id, 'pyls_ms')
end

local callbacks =  {
  ['python/setStatusBarMessage'] = function(_, _, message, client_id)
    ensure_init(client_id)
    messages[client_id].static_message = { content = message[1] }
    vim.api.nvim_command('doautocmd User LspMessageUpdate')
  end,
  ['python/beginProgress'] = function(_, _, _, client_id)
    ensure_init(client_id)
    if not messages[client_id].progress[1] then
      messages[client_id].progress[1] = { spinner = 1, title = 'MPLS' }
    end
  end,
  ['python/reportProgress'] = function(_, _, message, client_id)
    messages[client_id].progress[1].spinner = messages[client_id].progress[1].spinner + 1
    messages[client_id].progress[1].title = message[1]
    vim.api.nvim_command('doautocmd User LspMessageUpdate')
  end,
  ['python/endProgress'] = function(_, _, _, client_id)
    messages[client_id].progress[1] = nil
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
