local messages = {}
local function init(_messages, _)
  messages = _messages
end

local function progress_callback(_, _, msg, client_id, buffnr)
  if not messages[buffnr] then
    messages[buffnr] = {}
  end

  if not messages[buffnr][client_id] then
    messages[buffnr][client_id] = {}
  end

  if not messages[buffnr][client_id].progress then
    messages[buffnr][client_id].progress = {}
  end

  local val = msg.value
  if val.kind then
    if val.kind == 'begin' then
      messages[buffnr][client_id].progress[msg.token] = {
        title = val.title,
        message = val.message,
        percentage = val.percentage,
        spinner = 1,
      }
    elseif val.kind == 'report' then
      messages[buffnr][client_id].progress[msg.token].message = val.message
      messages[buffnr][client_id].progress[msg.token].percentage = val.percentage
      messages[buffnr][client_id].progress[msg.token].spinner = messages[buffnr][client_id].progress[msg.token].spinner + 1
    elseif val.kind == 'end' then
      messages[buffnr][client_id].progress[msg.token].message = val.message
      messages[buffnr][client_id].progress[msg.token].done = true
      messages[buffnr][client_id].progress[msg.token].spinner = nil
    end
  else
    table.insert(messages[buffnr][client_id], { content = val, show_once = true })
  end

  vim.api.nvim_command('doautocmd User LspMessageUpdate')
end

local M = {
  progress_callback = progress_callback,
  _init = init
}

return M
