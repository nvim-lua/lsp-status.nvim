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

-- Process messages
local function get_messages()
  local buf = vim.fn.bufnr()
  if not messages[buf] then
    return {}
  end

  local buf_clients = messages[buf]
  local buf_messages = {}
  local msg_remove = {}
  local progress_remove = {}
  for client, msgs in pairs(buf_clients) do
    for i, msg in ipairs(msgs) do
      if msg.show_once then
        table.insert(msg_remove, { client = client, idx = i })
      end

      table.insert(buf_messages, { name = client, content = msg.content })
    end

    local progress_contexts = buf_clients[client].progress
    if progress_contexts then
      for token, ctx in pairs(progress_contexts) do
        table.insert(buf_messages, { name = client,
          title = ctx.title,
          message = ctx.message,
          percentage = ctx.percentage,
          progress = true,
          spinner = ctx.spinner,
        })

        if ctx.done then
          table.insert(progress_remove, { client = client, token = token })
        end
      end
    end
  end

  for _, item in ipairs(msg_remove) do
    table.remove(messages[buf][item.client], item.idx)
  end

  for _, item in ipairs(progress_remove) do
    messages[buf][item.client].progress[item.token] = nil
  end

  return buf_messages
end

local function register_progress()
  vim.lsp.callbacks['$/progress'] = progress_callback
end

-- Client registration for messages
local function register_client(client_name, bufnr)
  local buf = bufnr or vim.fn.bufnr()
  if not messages[buf] then
    messages[buf] = {}
  end

  if not messages[buf][client_name] then
    messages[buf][client_name] = {}
  end
end

local M = {
  progress_callback = progress_callback,
  messages = get_messages,
  register_progress = register_progress,
  register_client = register_client,
  _init = init,
}

return M
