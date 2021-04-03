local config = {}
local function init(_, _config) config = vim.tbl_extend('force', config, _config) end

local last_redraw = nil
local timer_going = false

local function redraw_callback(now)
  last_redraw = now or vim.loop.now()
  vim.api.nvim_command('redrawstatus!')
  timer_going = false
end

local wrapped_redraw_callback = vim.schedule_wrap(redraw_callback)
local timer = vim.loop.new_timer()
local function redraw()
  local now = vim.loop.now()
  if last_redraw == nil or now - last_redraw >= config.update_interval then
    vim.loop.timer_stop(timer)
    redraw_callback(now)
  elseif not timer_going then
    timer_going = true
    vim.loop.timer_start(timer, config.update_interval + last_redraw - now, 0,
                         wrapped_redraw_callback)
  end
end

local M = {redraw = redraw, _init = init}

return M
