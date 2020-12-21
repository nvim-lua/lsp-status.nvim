local util = require('lsp-status/util')

local messages = {}
---@private
local function init(_messages, _)
  messages = _messages
end

---@private
local function ensure_init(id)
  util.ensure_init(messages, id, 'pyls_ms')
end

local handlers =  {
  ['python/setStatusBarMessage'] = function(_, _, message, client_id)
    ensure_init(client_id)
    messages[client_id].static_message = { content = message[1] }
    vim.api.nvim_command('doautocmd <nomodeline> User LspMessageUpdate')
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
    vim.api.nvim_command('doautocmd <nomodeline> User LspMessageUpdate')
  end,
  ['python/endProgress'] = function(_, _, _, client_id)
    messages[client_id].progress[1] = nil
    vim.api.nvim_command('doautocmd <nomodeline> User LspMessageUpdate')
  end,
}

--- Return the handler {LSP Method: handler} table for `MPLS`'s progress and statusbar message
--- extensions
--@returns Table of extension method handlers, to be added to your `pyls_ms` config
local function setup()
  return handlers
end

local M = {
  _init = init,
  setup = setup
}

M = vim.tbl_extend('error', M, handlers)

return M
