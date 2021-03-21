local timer = nil
local text = ''
local redraw = ''

--- Timer callback function
local function timer_callback()
  -- Check if need to redraw
  if redraw then
    redraw = false
    -- Schedule the command when it's safe to call it
    local new_state = require('lsp-status/statusline').get_lsp_statusline()
    print(new_state)
    if new_state ~= text then
      text = new_state
      vim.b.lsp_status_statusline = text
      vim.api.nvim_command('redrawstatus!')
    end
  end
end

--- Function to register a timer to update statusline
-- This function is called on attach of a LSP Server and will pull updates for
-- status line on a specific every interval of time. It will also schedule the
-- redraw of the status line on the main loop. This will reduce the lag for
-- servers that constantly update the messages like `rust-analyzer`. It will
-- set use the variable timer to schedule the updates.
-- TODO: This could error if the lsp is disconnected, the timer should be
-- stopped
local function register_timer()
  -- Guard the for an already defined timer
  if timer ~= nil then
    return
  end
  timer = vim.loop.new_timer()
  redraw = true
  -- Execute the timer every 100 milliseconds
  -- NOTE: This could be 30 to get a 30 updates per seconds, but set to 100 to
  -- copy coc.nvim status interval
  timer:start(0, 100, vim.schedule_wrap(timer_callback))
end

local M = {
  timer = timer,
  redraw = redraw,
  text = text,
  register_timer = register_timer,
}

return M
