local messages = {}

local function init(_messages, _)
  messages = _messages
end

local M = {
  ['textDocument/clangd.fileStatus'] = function(_, _, statusMessage, _, buffnr)
    table.insert(messages[buffnr].clangd, {
      uri = statusMessage.uri,
      content = statusMessage.state,
      show_once = true
    })
    vim.api.nvim_command('doautocmd User LspMessageUpdate')
  end,
  _init = init
}

return M
