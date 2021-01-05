local config = {}

local function init(_, _config)
  config = vim.tbl_extend('force', config, _config)
end

local diagnostics = require('lsp-status/diagnostics')
local messages = require('lsp-status/messaging').messages
local aliases = {
  pyls_ms = 'MPLS',
}

local function statusline_lsp(bufnr)
  bufnr = bufnr or 0
  if #vim.lsp.buf_get_clients(bufnr) == 0 then
    return ''
  end

  local buf_diagnostics = diagnostics(bufnr)
  local buf_messages = messages()
  local only_hint = true
  local some_diagnostics = false
  local status_parts = {}
  if buf_diagnostics.errors and buf_diagnostics.errors > 0 then
    table.insert(status_parts, config.indicator_errors .. config.indicator_separator .. buf_diagnostics.errors)
    only_hint = false
    some_diagnostics = true
  end

  if buf_diagnostics.warnings and buf_diagnostics.warnings > 0 then
    table.insert(status_parts, config.indicator_warnings .. config.indicator_separator .. buf_diagnostics.warnings)
    only_hint = false
    some_diagnostics = true
  end

  if buf_diagnostics.info and buf_diagnostics.info > 0 then
    table.insert(status_parts, config.indicator_info .. config.indicator_separator .. buf_diagnostics.info)
    only_hint = false
    some_diagnostics = true
  end

  if buf_diagnostics.hints and buf_diagnostics.hints > 0 then
    table.insert(status_parts, config.indicator_hint .. config.indicator_separator .. buf_diagnostics.hints)
    some_diagnostics = true
  end

  local msgs = {}
  for _, msg in ipairs(buf_messages) do
    local name = aliases[msg.name] or msg.name
    local client_name = '[' .. name .. ']'
    local contents = ''
    if msg.progress then
      contents = msg.title
      if msg.message then
        contents = contents .. ' ' .. msg.message
      end

      if msg.percentage then
        contents = contents .. ' (' .. msg.percentage .. ')'
      end

      if msg.spinner then
        contents = config.spinner_frames[(msg.spinner % #config.spinner_frames) + 1] .. ' ' .. contents
      end
    elseif msg.status then
      contents = msg.content
      if msg.uri then
        local filename = vim.uri_to_fname(msg.uri)
        filename = vim.fn.fnamemodify(filename, ':~:.')
        local space = math.min(60, math.floor(0.6 * vim.fn.winwidth(0)))
        if #filename > space then
          filename = vim.fn.pathshorten(filename)
        end

        contents = '(' .. filename .. ') ' .. contents
      end
    else
      contents = msg.content
    end

    table.insert(msgs, client_name .. ' ' .. contents)
  end

  local base_status = vim.trim(table.concat(status_parts, ' ') .. ' ' .. table.concat(msgs, ' '))
  local symbol = config.status_symbol .. ((some_diagnostics and only_hint) and '' or ' ')
  if config.current_function then
    local current_function = vim.b.lsp_current_function
    if current_function and current_function ~= '' then
      symbol = symbol .. '(' .. current_function .. ') '
    end
  end

  if base_status ~= '' then
    return symbol .. base_status .. ' '
  end

  return symbol .. config.indicator_ok .. ' '
end

local M = {
  _init = init,
  status = statusline_lsp
}

return M
