local messages = {}
local function init(_messages, _)
  messages = _messages
end

local callbacks =  {
  ['python/setStatusBarMessage'] = function(_, _, message, buffnr)
    table.insert(messages[buffnr].pyls_ms, { content = message[1] })
    vim.api.nvim_command('doautocmd User LspMessageUpdate')
  end,
  ['python/beginProgress'] = function(_, _, _, buffnr)
    if not messages[buffnr] then
      messages[buffnr] = {}
    end

    if not messages[buffnr].pyls_ms then
      messages[buffnr].pyls_ms = {}
    end

    if not messages[buffnr].pyls_ms.progress then
      messages[buffnr].pyls_ms.progress = {}
    end

    if not messages[buffnr].pyls_ms.progress[1] then
      messages[buffnr].pyls_ms.progress[1] = { spinner = 1, title = 'MPLS' }
    end
  end,
  ['python/reportProgress'] = function(_, _, message, buffnr)
    messages[buffnr].pyls_ms.progress[1].spinner = messages[buffnr].pyls_ms.progress[1].spinner + 1
    messages[buffnr].pyls_ms.progress[1].title = message[1]
    vim.api.nvim_command('doautocmd User LspMessageUpdate')
  end,
  ['python/endProgress'] = function(_, _, _, buffnr)
    messages[buffnr].pyls_ms.progress[1] = nil
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
