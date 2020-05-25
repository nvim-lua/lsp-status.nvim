local messages = {}

local function init(_messages, _)
  messages = _messages
end

local callbacks = {
  ['textDocument/clangd.fileStatus'] = function(_, _, statusMessage, _, buffnr)
    table.insert(messages[buffnr].clangd, {
      uri = statusMessage.uri,
      content = statusMessage.state,
      show_once = true
    })
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
